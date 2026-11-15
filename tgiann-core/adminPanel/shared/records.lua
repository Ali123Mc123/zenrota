-- tgiann-core admin lib: the records of the script (wire form, the shape of the JSON files) and the one way
-- they change, on both sides: load a whole file or apply one patch, then rebuild the script's runtime table.

---Language codes of the script (its languages/*.lua fill config.langs), sorted; a langText value holds one text
---per code.
---@return string[]
function AdminPanel.Languages()
    local out = {}
    local langs = type(config) == "table" and type(config.langs) == "table" and config.langs or {}
    for code in pairs(langs) do out[#out + 1] = code end
    if #out == 0 then out[1] = "en" end
    table.sort(out)
    return out
end

---The text of a langText value in the server language (config.lang), else English, else the first one written.
---A plain string (an older file) is returned as it is.
---@param value string|table<string, string>|nil
---@return string
function AdminPanel.Text(value)
    if type(value) ~= "table" then return value or "" end
    local lang = type(config) == "table" and config.lang or nil
    if lang and value[lang] and value[lang] ~= "" then return value[lang] end
    if value.en and value.en ~= "" then return value.en end
    for _, code in ipairs(AdminPanel.Languages()) do
        if value[code] and value[code] ~= "" then return value[code] end
    end
    return ""
end

---@param file string
---@param key string
---@return table|nil
function AdminPanel.Get(file, key)
    return AdminPanel.records[file] and AdminPanel.records[file][key]
end

---Values of a settings file.
---@param file string
---@return table
function AdminPanel.Settings(file)
    return AdminPanel.records[file] and AdminPanel.records[file].main or {}
end

---@param file string
---@return table<string, table>
function AdminPanel.All(file)
    return AdminPanel.records[file] or {}
end

---Reads one data file of the schema. Same reader for the server load and the client file mode.
---@param file string
---@return table<string, table> records
---@return number version
function AdminPanel.ReadFile(file)
    local spec = AdminPanel.schema.files[file]
    local raw = LoadResourceFile(cache.resource, spec.path)
    local data = raw and json.decode(raw) or nil
    if type(data) ~= "table" then return {}, 1 end
    local records = data.records
    return type(records) == "table" and records or {}, tonumber(data.version) or 1
end

---Settings missing from a settings file (new in an update, or no file yet) start at spec.defaults.
---@param file string
---@param records table<string, table>
---@return table<string, table> records
---@return boolean filled a default was added
function AdminPanel.WithDefaults(file, records)
    local spec = AdminPanel.schema.files[file]
    if spec.kind ~= "settings" then return records, false end
    local main = type(records.main) == "table" and records.main or {}
    local filled = records.main == nil
    for section, value in pairs(spec.defaults or {}) do
        if main[section] == nil then
            main[section] = value
            filled = true
        end
    end
    return { main = main }, filled
end

---@param file string
---@param key string
local function apply(file, key)
    local fn = AdminPanel.hooks.apply[file]
    if not fn then return end
    local ok, err = pcall(fn, key, AdminPanel.records[file][key])
    if not ok then print(("^1[%s] admin apply %s.%s failed: %s^7"):format(cache.resource, file, key, tostring(err))) end
end

---Replaces every record of a file and rebuilds its runtime table.
---@param file string
---@param records table<string, table>
function AdminPanel.Load(file, records)
    local old = AdminPanel.records[file] or {}
    AdminPanel.records[file] = records
    for key in pairs(old) do
        if not records[key] then apply(file, key) end
    end
    for key in pairs(records) do apply(file, key) end
end

---true while AdminPanel.ApplyPatches runs (OnApply hooks may skip a rebuild until the OnBatch hooks)
AdminPanel.batching = false

---Applies many validated patches of one file, then the file's OnBatch hooks once.
---@param file string
---@param patches table[]
function AdminPanel.ApplyPatches(file, patches)
    AdminPanel.batching = true
    for _, patch in ipairs(patches) do AdminPanel.ApplyPatch(patch) end
    AdminPanel.batching = false
    for _, fn in ipairs(AdminPanel.hooks.batch[file] or {}) do fn() end
end

---Values at a path of a record. A dotted path reads into sections ("armory.shop"), "[]" walks every entry of a
---list ("stations[].globalSets": the globalSets of every station).
---@param record any
---@param path string
---@return any[]
function AdminPanel.ValuesAt(record, path)
    local out = {}
    local parts = {}
    for part in path:gmatch("[^%.]+") do parts[#parts + 1] = part end
    local function walk(v, i)
        if i > #parts then
            if v ~= nil then out[#out + 1] = v end
            return
        end
        if type(v) ~= "table" then return end
        local part = parts[i]
        if part:sub(-2) == "[]" then
            local list = v[part:sub(1, -3)]
            if type(list) ~= "table" then return end
            for _, entry in ipairs(list) do walk(entry, i + 1) end
            return
        end
        walk(v[part], i + 1)
    end
    walk(record, 1)
    return out
end

---Applies one validated patch to the records and the runtime table. Patches are idempotent replaces.
---rename: the record moves from key to value (the new key).
---@param patch { file: string, action: string, key: string, section?: string, value?: any }
function AdminPanel.ApplyPatch(patch)
    local records = AdminPanel.records[patch.file]
    if not records then return end
    if patch.action == "rename" then
        local record = records[patch.key]
        if not record or records[patch.value] then return end
        records[patch.key] = nil
        records[patch.value] = record
        apply(patch.file, patch.key)
        apply(patch.file, patch.value)
        return
    end
    if patch.action == "create" then
        records[patch.key] = patch.value
    elseif patch.action == "delete" then
        records[patch.key] = nil
    else
        local record = records[patch.key]
        if not record then return end
        if patch.action == "set" then record[patch.section] = patch.value else record[patch.section] = nil end
    end
    apply(patch.file, patch.key)
end
