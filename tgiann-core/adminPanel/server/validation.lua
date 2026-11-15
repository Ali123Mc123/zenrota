-- tgiann-core admin lib: checks every patch against the schema (types, keys, actions) and returns its clean copy.
assert(AdminPanel and AdminPanel.schema, "tgiann-core admin lib: AdminPanel.Define(schema) must run in a shared script before the server part")

local schema = AdminPanel.schema
local ERR = "ADMIN_ERR_INVALID"
local NAME = "^[%w_%-%.:]+$"

local validate

---@param v any
---@param min number
---@param max number
local function inRange(v, min, max)
    return type(v) == "number" and v == v and v >= (min or -1e12) and v <= (max or 1e12)
end

local TYPES = {}

TYPES.text = function(spec, v)
    if type(v) ~= "string" then return nil, "must be text" end
    if #v < (spec.min or 1) or #v > (spec.max or 120) then return nil, ("must be %d - %d characters"):format(spec.min or 1, spec.max or 120) end
    return v
end

-- a text per language of the script ({ tr = "...", en = "..." }); a plain string fills every language, empty
-- languages are left out (AdminPanel.Text falls back), at least one is needed
TYPES.langText = function(spec, v)
    if type(v) ~= "string" and type(v) ~= "table" then return nil, "must be a text per language" end
    local out, any = {}, false
    for _, code in ipairs(AdminPanel.Languages()) do
        local text = type(v) == "string" and v or v[code]
        if text ~= nil and type(text) ~= "string" then return nil, ("%s must be text"):format(code) end
        if text and text ~= "" then
            if #text > (spec.max or 120) then return nil, ("%s must be up to %d characters"):format(code, spec.max or 120) end
            out[code] = text
            any = true
        end
    end
    if not any then
        if spec.optional then return nil end
        return nil, "needs a text in at least one language"
    end
    return out
end

TYPES.number = function(spec, v)
    if not inRange(v, spec.min, spec.max) then return nil, ("must be a number %s - %s"):format(tostring(spec.min), tostring(spec.max)) end
    if spec.integer and math.floor(v) ~= v then return nil, "must be a whole number" end
    return v
end

TYPES.bool = function(spec, v)
    if type(v) ~= "boolean" then return nil, "must be true or false" end
    -- trueOnly flags are stored only when set
    if spec.trueOnly and not v then return nil end
    return v
end

TYPES.name = function(spec, v)
    if v == false and spec.allowFalse then return false end
    if type(v) ~= "string" or #v < 1 or #v > (spec.max or 64) or not v:match(spec.pattern or NAME) then return nil, "must be a name (letters, digits, _ - . :)" end
    return v
end

TYPES.names = function(spec, v)
    if type(v) ~= "table" or #v > (spec.max or 50) then return nil, ("must be a list of up to %d names"):format(spec.max or 50) end
    local out, seen = {}, {}
    for i = 1, #v do
        local name = TYPES.name(spec, v[i])
        if not name then return nil, ("entry %d must be a name"):format(i) end
        if not seen[name] then
            seen[name] = true
            out[#out + 1] = name
        end
    end
    if #out < (spec.min or 0) then return nil, ("needs at least %d entries"):format(spec.min) end
    return out
end

TYPES.refs = function(spec, v)
    local list, reason = TYPES.names({ max = spec.max or 500 }, v)
    if not list then return nil, reason end
    local records = AdminPanel.records[spec.file]
    for _, key in ipairs(list) do
        if not records[key] then return nil, ("'%s' does not exist in %s"):format(key, spec.file) end
    end
    return list
end

TYPES.enum = function(spec, v)
    if spec.list then
        -- values picked in a settings file of the panel (enabled accounts)
        local values = AdminPanel.Settings(spec.list.file)[spec.list.path]
        for _, allowed in ipairs(type(values) == "table" and values or {}) do
            if allowed == v then return v end
        end
        return nil, ("must be one of %s.%s"):format(spec.list.file, spec.list.path)
    end
    if spec.file then
        if type(v) == "string" and AdminPanel.records[spec.file][v] then return v end
        return nil, ("must be a record of %s"):format(spec.file)
    end
    for _, allowed in ipairs(spec.values or {}) do
        if allowed == v then return v end
    end
    return nil, "must be one of the listed values"
end

---@param spec table
---@param v any
---@param withW boolean
local function vec(spec, v, withW)
    local limit = spec.limit or 20000
    if type(v) ~= "table" or not inRange(v.x, -limit, limit) or not inRange(v.y, -limit, limit) or not inRange(v.z, -limit, limit) then
        return nil, ("must be { x, y, z } within %s"):format(limit)
    end
    if not withW then return { x = v.x, y = v.y, z = v.z } end
    if not inRange(v.w, -360, 360) then return nil, "heading must be -360 - 360" end
    return { x = v.x, y = v.y, z = v.z, w = v.w }
end
TYPES.vec3 = function(spec, v) return vec(spec, v, false) end
TYPES.vec4 = function(spec, v) return vec(spec, v, true) end

TYPES.amount = function(spec, v)
    if type(v) == "table" then
        local a, b = v[1], v[2]
        if not inRange(a, spec.min, spec.max) or not inRange(b, spec.min, spec.max) or math.floor(a) ~= a or math.floor(b) ~= b or a > b then
            return nil, ("range must be whole numbers %s - %s, min <= max"):format(tostring(spec.min), tostring(spec.max))
        end
        return { a, b }
    end
    return TYPES.number({ min = spec.min, max = spec.max, integer = true }, v)
end

---@param fields table<string, table>
---@param v table
---@param path string
local function fieldsOf(fields, v, path)
    local out = {}
    for key, fieldSpec in pairs(fields) do
        local value = v[key]
        if value == nil then
            if not fieldSpec.optional then return nil, fieldSpec.err, ("%s.%s is required"):format(path, key) end
        else
            local clean, errKey, reason = validate(fieldSpec, value, path .. "." .. key)
            if clean == nil and reason then return nil, errKey, reason end
            out[key] = clean
        end
    end
    return out
end

TYPES.object = function(spec, v, path)
    if type(v) ~= "table" then return nil, "must be a table" end
    local out, errKey, reason = fieldsOf(spec.fields, v, path)
    if not out then return nil, reason, errKey end
    for _, rule in ipairs(spec.lte or {}) do
        local a, b = out[rule[1]], out[rule[2]]
        if a and b and a > b then return nil, ("%s cannot be above %s"):format(rule[1], rule[2]), rule[3] end
    end
    return out
end

TYPES.list = function(spec, v, path)
    if type(v) ~= "table" or #v > (spec.max or 50) or #v < (spec.min or 0) then return nil, ("must be a list of %d - %d entries"):format(spec.min or 0, spec.max or 50) end
    local out, seen = {}, {}
    for i = 1, #v do
        local clean, errKey, reason = validate(spec.of, v[i], ("%s[%d]"):format(path, i))
        if clean == nil then return nil, reason or "invalid entry", errKey end
        -- unique = a row field no two rows may share (one price per slot)
        local value = spec.unique and clean[spec.unique]
        if value ~= nil and value ~= false then
            if seen[value] then return nil, ("%s is listed twice"):format(tostring(value)), "ADMIN_ERR_DUPLICATE" end
            seen[value] = true
        end
        out[i] = clean
    end
    return out
end

-- names to values (an account's symbol): keys are names, every value checked against `of`
TYPES.map = function(spec, v, path)
    if type(v) ~= "table" then return nil, "must be a table" end
    local out, count = {}, 0
    for key, value in pairs(v) do
        if not TYPES.name({ pattern = spec.keyPattern }, key) then return nil, "keys must be names" end
        local clean, errKey, reason = validate(spec.of, value, ("%s.%s"):format(path, key))
        if clean == nil then return nil, reason or "invalid entry", errKey end
        out[key] = clean
        count = count + 1
    end
    if count > (spec.max or 50) then return nil, ("must have up to %d entries"):format(spec.max or 50) end
    return out
end

TYPES.variant = function(spec, v, path)
    local by = spec.by or "type"
    if type(v) ~= "table" or type(v[by]) ~= "string" or not spec.variants[v[by]] then return nil, ("%s must be one of the variants"):format(by) end
    local out, errKey, reason = fieldsOf(spec.variants[v[by]], v, path)
    if not out then return nil, reason, errKey end
    out[by] = v[by]
    return out
end

---@param spec table
---@param v any
---@param path string
---@return any clean nil when refused (or a dropped trueOnly flag)
---@return string|nil errKey
---@return string|nil reason
validate = function(spec, v, path)
    local check = TYPES[spec.type]
    if not check then return nil, ERR, ("%s: unknown type %s"):format(path, tostring(spec.type)) end
    local clean, reason, errKey = check(spec, v, path)
    if clean == nil and reason then return nil, errKey or spec.err or ERR, ("%s %s"):format(path, reason) end
    return clean
end

---@param file string
---@param key any
local function validKey(file, key)
    local spec = schema.files[file]
    return type(key) == "string" and #key >= 1 and #key <= spec.keyMax and key:match(spec.keyPattern) ~= nil
end

---Checks a patch and returns its cleaned copy.
---@param patch any
---@return table|nil clean
---@return string|nil errKey
---@return string|nil reason
function AdminPanel.ValidatePatch(patch)
    if type(patch) ~= "table" then return nil, ERR, "patch must be a table" end
    local spec = schema.files[patch.file]
    if not spec then return nil, ERR, "unknown file" end
    if not validKey(patch.file, patch.key) then return nil, "ADMIN_ERR_KEY", ("key must match %s, up to %d characters"):format(spec.keyPattern, spec.keyMax) end
    local exists = AdminPanel.records[patch.file][patch.key] ~= nil
    local action = patch.action
    if spec.kind == "settings" and (patch.key ~= "main" or action == "create" or action == "delete") then
        return nil, ERR, "a settings file only has its values, nothing is created or deleted"
    end

    if action == "create" then
        if exists then return nil, "ADMIN_ERR_EXISTS", "a record with this key already exists" end
        if type(patch.value) ~= "table" then return nil, ERR, "create needs a full record" end
        local record = {}
        for section, sectionSpec in pairs(spec.sections) do
            local value = patch.value[section]
            if value == nil then
                if not sectionSpec.optional then return nil, sectionSpec.err or ERR, section .. " is required" end
            else
                local clean, errKey, reason = validate(sectionSpec, value, section)
                if clean == nil and reason then return nil, errKey, reason end
                record[section] = clean
            end
        end
        return { file = patch.file, action = action, key = patch.key, value = record }
    end

    if not exists then return nil, "ADMIN_ERR_MISSING", "no record with this key" end
    if action == "delete" then return { file = patch.file, action = action, key = patch.key } end
    if action == "rename" then
        -- the record moves to a new key; references to it follow (server/commit.lua)
        if spec.kind == "settings" then return nil, ERR, "a settings file has no keys to rename" end
        if not validKey(patch.file, patch.value) then return nil, "ADMIN_ERR_KEY", ("new key must match %s, up to %d characters"):format(spec.keyPattern, spec.keyMax) end
        if AdminPanel.records[patch.file][patch.value] ~= nil then return nil, "ADMIN_ERR_EXISTS", "a record with the new key already exists" end
        return { file = patch.file, action = action, key = patch.key, value = patch.value }
    end

    local sectionSpec = spec.sections[patch.section]
    if not sectionSpec then return nil, ERR, "unknown section" end
    if action == "remove" then
        if not sectionSpec.optional then return nil, ERR, "this section cannot be removed" end
        return { file = patch.file, action = action, key = patch.key, section = patch.section }
    end
    if action ~= "set" then return nil, ERR, "action must be create, set, remove, delete or rename" end
    local clean, errKey, reason = validate(sectionSpec, patch.value, patch.section)
    if clean == nil then
        -- a dropped trueOnly flag or an emptied optional value means "remove"
        if reason then return nil, errKey, reason end
        if not sectionSpec.optional then return nil, ERR, patch.section .. " is required" end
        return { file = patch.file, action = "remove", key = patch.key, section = patch.section }
    end
    return { file = patch.file, action = action, key = patch.key, section = patch.section, value = clean }
end
