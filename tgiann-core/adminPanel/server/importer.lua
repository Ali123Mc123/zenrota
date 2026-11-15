-- tgiann-core admin lib: imports records pasted as JSON (the panel's own export, { "<key>": record }, or a data file,
-- { "records": { ... } }). A tab uses it with import = { action = "lib:import", ... }. Keys that already exist are
-- asked about first (the panel answers with values.duplicates): skip, replace, or keep both under "<key>_2".
-- values.into = a record key: the pasted record (the only one) replaces that record, whatever key it was exported with.
local schema = AdminPanel.schema
local MAX_RECORDS = 1000

---@param duplicates any
---@param key string
---@return "skip"|"replace"|"both"|nil
local function duplicateAction(duplicates, key)
    local action = type(duplicates) == "table" and duplicates[key] or duplicates
    if action == "skip" or action == "replace" or action == "both" then return action end
end

---@param file string
---@param key string
---@return string
local function freeKey(file, key)
    local spec = schema.files[file]
    for n = 2, 99 do
        local suffix = "_" .. n
        local candidate = key:sub(1, spec.keyMax - #suffix) .. suffix
        if not AdminPanel.records[file][candidate] then return candidate end
    end
    return key
end

---@param file string
---@param record table
---@return string
local function labelOf(file, record)
    local path = schema.files[file].labelPath or "label"
    local v = AdminPanel.ValuesAt(record, path)[1]
    return type(v) == "table" and AdminPanel.Text(v) or tostring(v or "")
end

---Section patches that turn the current record into `record` (sections the paste lacks are removed when optional).
---@param file string
---@param key string
---@param record table
---@return table[]|nil patches
---@return string|nil errKey
---@return string|nil reason
local function replacePatches(file, key, record)
    local out = {}
    local current = AdminPanel.records[file][key]
    for section, sectionSpec in pairs(schema.files[file].sections) do
        local raw
        if record[section] ~= nil then
            raw = { file = file, action = "set", key = key, section = section, value = record[section] }
        elseif current[section] ~= nil and sectionSpec.optional then
            raw = { file = file, action = "remove", key = key, section = section }
        end
        if raw then
            local clean, errKey, reason = AdminPanel.ValidatePatch(raw)
            if not clean then return nil, errKey, ("%s: %s"):format(key, tostring(reason)) end
            out[#out + 1] = clean
        end
    end
    return out
end

---@param text string
---@return table|nil records key -> record
local function parse(text)
    local ok, data = pcall(json.decode, text)
    if not ok or type(data) ~= "table" then return nil end
    if type(data.records) == "table" and next(data.records) and data.version then data = data.records end
    local count = 0
    for key, record in pairs(data) do
        if type(key) ~= "string" or type(record) ~= "table" then return nil end
        count = count + 1
    end
    if count == 0 or count > MAX_RECORDS then return nil end
    return data
end

---@param src number
---@param file string
---@param values table { text, duplicates?, into? }
---@return table result { ok, conflicts?, msgKey?, msgArgs? }
local function import(src, file, values)
    local spec = schema.files[file]
    if not spec or spec.kind == "settings" or spec.store == "script" then return { ok = false, msgKey = "ADMIN_ERR_INVALID" } end
    local records = type(values.text) == "string" and parse(values.text)
    if not records then return { ok = false, msgKey = "ADMIN_IMPORT_INVALID" } end

    if type(values.into) == "string" then
        if not AdminPanel.records[file][values.into] then return { ok = false, msgKey = "ADMIN_ERR_MISSING" } end
        local only, extra = next(records)
        if next(records, only) then return { ok = false, msgKey = "ADMIN_IMPORT_ONE" } end
        records = { [values.into] = extra }
        values.duplicates = "replace"
    end

    local duplicates = values.duplicates
    if duplicates == nil then
        local conflicts = {}
        for key, record in pairs(records) do
            local current = AdminPanel.records[file][key]
            if current then conflicts[#conflicts + 1] = { key = key, label = labelOf(file, record), current = labelOf(file, current) } end
        end
        if #conflicts > 0 then
            table.sort(conflicts, function(a, b) return a.key < b.key end)
            return { ok = false, conflicts = conflicts }
        end
    end

    -- every record is checked before anything is written: one bad record refuses the whole paste
    local patches, applied = {}, {}
    local keys = {}
    for key in pairs(records) do keys[#keys + 1] = key end
    table.sort(keys)
    for _, key in ipairs(keys) do
        local record = records[key]
        local action = AdminPanel.records[file][key] and duplicateAction(duplicates, key) or "create"
        if action == "both" then
            key = freeKey(file, key)
            action = "create"
        end
        if action == "create" then
            local clean, errKey, reason = AdminPanel.ValidatePatch({ file = file, action = "create", key = key, value = record })
            if not clean then
                print(("^3[%s] import refused (%s): %s^7"):format(cache.resource, tostring(errKey), tostring(reason)))
                return { ok = false, msgKey = errKey or "ADMIN_IMPORT_INVALID", msgArgs = { key } }
            end
            patches[#patches + 1] = clean
            applied[#applied + 1] = key
        elseif action == "replace" then
            local list, errKey, reason = replacePatches(file, key, record)
            if not list then
                print(("^3[%s] import refused (%s): %s^7"):format(cache.resource, tostring(errKey), tostring(reason)))
                return { ok = false, msgKey = errKey or "ADMIN_IMPORT_INVALID", msgArgs = { key } }
            end
            for _, patch in ipairs(list) do patches[#patches + 1] = patch end
            applied[#applied + 1] = key
        end
    end
    AdminPanel.CommitMany(file, patches)
    for _, patch in ipairs(patches) do
        for _, fn in ipairs(AdminPanel.hooks.applied[file] or {}) do
            local ok, err = pcall(fn, patch, src)
            if not ok then print(("^1[%s] admin side effect failed: %s^7"):format(cache.resource, tostring(err))) end
        end
    end
    return { ok = true, msgKey = "ADMIN_IMPORT_DONE", msgArgs = { #applied } }
end

-- latent upload (a pasted catalog is bigger than a regular event allows), small or latent answer
RegisterNetEvent(AdminPanel.EventName("import"))
AddEventHandler(AdminPanel.EventName("import"), function(requestId, file, values)
    local src = source
    if type(requestId) ~= "number" then return end
    local result
    if not AdminPanel.IsAdmin(src) then
        result = { ok = false, msgKey = "ADMIN_ERR_NO_PERM" }
    elseif type(file) ~= "string" or type(values) ~= "table" then
        result = { ok = false, msgKey = "ADMIN_ERR_INVALID" }
    else
        result = import(src, file, values)
    end
    TriggerLatentClientEvent(AdminPanel.EventName("importResult"), src, 500000, requestId, result)
end)
