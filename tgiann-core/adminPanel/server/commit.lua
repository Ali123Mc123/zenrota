-- tgiann-core admin lib: the write path. A patch from the panel is checked (admin, rate, schema, delete use,
-- script rules), committed (records + runtime tables), saved and sent only to who needs it (sync = "all":
-- every client, sync = "admin": open panels).
local schema = AdminPanel.schema
local ERR = "ADMIN_ERR_INVALID"

---@param patch table
local function broadcast(patch)
    if schema.files[patch.file].sync == "admin" then
        for src in pairs(AdminPanel.watchers) do
            TriggerLatentClientEvent(AdminPanel.EventName("adminPatch"), src, 500000, patch)
        end
        return
    end
    TriggerLatentClientEvent(AdminPanel.EventName("patch"), -1, 500000, patch)
end

---Applies an already valid patch, saves and sends it. Scripts call it for patches they make themselves.
---@param patch table
function AdminPanel.Commit(patch)
    AdminPanel.MarkChanged(patch)
    AdminPanel.ApplyPatch(patch)
    local dataFile = AdminPanel.files[patch.file]
    if dataFile then dataFile:queueSave() end
    broadcast(patch)
end

---Applies many already valid patches of one file (a script's import): one save, one broadcast.
---@param file string
---@param patches table[]
function AdminPanel.CommitMany(file, patches)
    if #patches == 0 then return end
    for _, patch in ipairs(patches) do AdminPanel.MarkChanged(patch) end
    AdminPanel.ApplyPatches(file, patches)
    local dataFile = AdminPanel.files[file]
    if dataFile then dataFile:queueSave() end
    if schema.files[file].sync == "admin" then
        for src in pairs(AdminPanel.watchers) do
            TriggerLatentClientEvent(AdminPanel.EventName("adminPatches"), src, 500000, file, patches)
        end
        return
    end
    TriggerLatentClientEvent(AdminPanel.EventName("patches"), -1, 500000, file, patches)
end

---Records of `file` whose `path` holds `key` (a value or a list containing it). The path may be dotted into a section
---("armory.shop") and walk lists with "[]" ("stations[].globalSets").
---@param file string
---@param path string
---@param key string
---@return string[]
function AdminPanel.UsedBy(file, path, key)
    local out = {}
    for recordKey, record in pairs(AdminPanel.records[file] or {}) do
        for _, v in ipairs(AdminPanel.ValuesAt(record, path)) do
            local hit = v == key
            if not hit and type(v) == "table" then
                for _, item in ipairs(v) do
                    if item == key then
                        hit = true
                        break
                    end
                end
            end
            if hit then
                out[#out + 1] = recordKey
                break
            end
        end
    end
    return out
end

---@param v any
---@return any
local function copy(v)
    if type(v) ~= "table" then return v end
    local out = {}
    for k, x in pairs(v) do out[k] = copy(x) end
    return out
end

---A copy of the section a path starts in, with `old` replaced by `new` wherever the path points at it (nil drops it
---from a list and clears a single value).
---@param record table
---@param path string
---@param old string
---@param new string|nil
---@return boolean changed
---@return string section
---@return any value the new section value
local function rewrite(record, path, old, new)
    local parts = {}
    for part in path:gmatch("[^%.]+") do parts[#parts + 1] = part end
    local section = parts[1]:gsub("%[%]$", "")
    local holder = { [section] = copy(record[section]) }
    local changed = false
    local function walk(t, i)
        local part = parts[i]
        local isList = part:sub(-2) == "[]"
        local name = isList and part:sub(1, -3) or part
        local v = t[name]
        if isList then
            if type(v) ~= "table" or i == #parts then return end
            for _, entry in ipairs(v) do
                if type(entry) == "table" then walk(entry, i + 1) end
            end
            return
        end
        if i < #parts then
            if type(v) == "table" then walk(v, i + 1) end
            return
        end
        if v == old then
            t[name] = new
            changed = true
        elseif type(v) == "table" then
            local list, hit = {}, false
            for _, x in ipairs(v) do
                if x == old then
                    hit = true
                    if new ~= nil then list[#list + 1] = new end
                else
                    list[#list + 1] = x
                end
            end
            if hit then
                t[name] = list
                changed = true
            end
        end
    end
    walk(holder, 1)
    return changed, section, holder[section]
end

---Points every reference to a record at its new key (the file's usedBy paths and every top level refs / enum section
---of that file), or drops it (new = nil: only the usedBy entries with cascade = true).
---@param file string
---@param old string
---@param new string|nil
local function repoint(file, old, new)
    local uses = {}
    for _, use in ipairs(schema.files[file].usedBy or {}) do uses[#uses + 1] = use end
    if new ~= nil then
        for other, spec in pairs(schema.files) do
            for section, sectionSpec in pairs(spec.sections) do
                if (sectionSpec.type == "refs" or sectionSpec.type == "enum") and sectionSpec.file == file then
                    uses[#uses + 1] = { file = other, path = section }
                end
            end
        end
    end
    for _, use in ipairs(uses) do
        if new ~= nil or use.cascade then
            for recordKey, record in pairs(AdminPanel.records[use.file] or {}) do
                local changed, section, value = rewrite(record, use.path, old, new)
                if changed then
                    AdminPanel.Commit(value == nil
                        and { file = use.file, action = "remove", key = recordKey, section = section }
                        or { file = use.file, action = "set", key = recordKey, section = section, value = value })
                end
            end
        end
    end
end

---Delete refusals (usedBy) and cascades (refs with cascade = true) from the schema.
---@param patch table
---@return boolean ok
---@return string|nil errKey
---@return string|nil reason
local function crossCheck(patch)
    if patch.action ~= "delete" then return true end
    for _, use in ipairs(schema.files[patch.file].usedBy or {}) do
        -- cascade = true: the delete drops the key from those records instead of being refused
        for _, user in ipairs(use.cascade and {} or AdminPanel.UsedBy(use.file, use.path, patch.key)) do
            -- a record pointing at itself goes with it
            if use.file ~= patch.file or user ~= patch.key then
                return false, use.err or "ADMIN_ERR_IN_USE", ("used by %s '%s'"):format(use.file, user)
            end
        end
    end
    return true
end

---@param patch table
local function cascade(patch)
    if patch.action == "rename" then return repoint(patch.file, patch.key, patch.value) end
    if patch.action ~= "delete" then return end
    repoint(patch.file, patch.key, nil)
    for file, spec in pairs(schema.files) do
        for section, sectionSpec in pairs(spec.sections) do
            if sectionSpec.type == "refs" and sectionSpec.file == patch.file and sectionSpec.cascade then
                for _, key in ipairs(AdminPanel.UsedBy(file, section, patch.key)) do
                    local list = {}
                    for _, id in ipairs(AdminPanel.records[file][key][section]) do
                        if id ~= patch.key then list[#list + 1] = id end
                    end
                    AdminPanel.Commit({ file = file, action = "set", key = key, section = section, value = list })
                end
            end
        end
    end
end

---@param patch table
---@return boolean ok
---@return string|nil errKey
---@return string|nil reason
local function runRules(patch)
    local rules = AdminPanel.hooks.rule[patch.file]
    if not rules then return true end
    -- rules see the record as it would be after the patch
    local current = AdminPanel.records[patch.file][patch.key]
    local record = nil
    if patch.action == "rename" then
        record = current
    elseif patch.action == "create" then
        record = patch.value
    elseif patch.action ~= "delete" then
        record = {}
        for k, v in pairs(current) do record[k] = v end
        if patch.action == "set" then record[patch.section] = patch.value else record[patch.section] = nil end
    end
    for _, rule in ipairs(rules) do
        local ok, errKey, reason = rule(record, patch.key, patch)
        if not ok then return false, errKey or ERR, reason or "refused by a rule" end
    end
    return true
end

-- 30 writes per 10 seconds per admin
local budget = AdminPanelWriteBudget:new(30, 10)

---@param src number
---@param patch any
---@return boolean ok
---@return string|nil errKey
local function applyPatch(src, patch)
    if not AdminPanel.IsAdmin(src) then return false, "ADMIN_ERR_NO_PERM" end
    if not AdminPanel.ready then return false, "ADMIN_ERR_TIMEOUT" end
    if not budget:take(src) then return false, "ADMIN_ERR_RATE_LIMIT" end
    local clean, errKey, reason = AdminPanel.ValidatePatch(patch)
    local ok = clean ~= nil
    if clean then ok, errKey, reason = crossCheck(clean) end
    if ok and clean then ok, errKey, reason = runRules(clean) end
    if not ok or not clean then
        print(("^3[%s] admin patch rejected by %s (%s): %s^7 %s"):format(cache.resource, GetPlayerName(src) or src, tostring(errKey), tostring(reason), json.encode(patch)))
        return false, errKey
    end
    AdminPanel.Commit(clean)
    cascade(clean)
    for _, fn in ipairs(AdminPanel.hooks.applied[clean.file] or {}) do
        local hookOk, err = pcall(fn, clean, src)
        if not hookOk then print(("^1[%s] admin side effect failed: %s^7"):format(cache.resource, tostring(err))) end
    end
    return true
end

-- latent upload: a long list must not overflow a regular event
RegisterNetEvent(AdminPanel.EventName("applyPatch"))
AddEventHandler(AdminPanel.EventName("applyPatch"), function(requestId, patch)
    local src = source
    if type(requestId) ~= "number" then return end
    local ok, errKey = applyPatch(src, patch)
    TriggerClientEvent(AdminPanel.EventName("patchResult"), src, requestId, ok, errKey)
end)

AddEventHandler("playerDropped", function()
    budget:forget(source)
end)
