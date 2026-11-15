-- tgiann-core admin lib: JSON writer for the data files. Object keys are written a-z and lists keep their order,
-- so saving a file only changes the lines of what was edited (readable diffs, no key shuffling).
AdminPanel.Json = {}

local ESCAPES = { ['"'] = '\\"', ["\\"] = "\\\\", ["\b"] = "\\b", ["\f"] = "\\f", ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t" }

---@param s string
---@return string
local function quote(s)
    return '"' .. s:gsub('[%c"\\]', function(c) return ESCAPES[c] or ("\\u%04x"):format(c:byte()) end) .. '"'
end

---@param n number
---@return string
local function number(n)
    if n ~= n or n == math.huge or n == -math.huge then return "null" end
    if math.type(n) == "integer" then return ("%d"):format(n) end
    local s = ("%.14g"):format(n)
    -- a whole float stays a float ("80.0"), as the panel sent it
    if not s:find("[%.eEn]") then s = s .. ".0" end
    return s
end

---A table with only the keys 1..n (or none) is a list.
---@param t table
---@return boolean
local function isList(t)
    local count = 0
    for k in pairs(t) do
        if type(k) ~= "number" then return false end
        count = count + 1
    end
    for i = 1, count do
        if t[i] == nil then return false end
    end
    return true
end

local encode

---@param t table
---@param indent string
---@return string
local function encodeTable(t, indent)
    local inner = indent .. "  "
    local parts = {}
    if isList(t) then
        if #t == 0 then return "[]" end
        for i = 1, #t do parts[i] = inner .. encode(t[i], inner) end
        return "[\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "]"
    end
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = tostring(k) end
    table.sort(keys)
    for i, k in ipairs(keys) do
        local v = t[k]
        if v == nil then v = t[tonumber(k)] end
        parts[i] = inner .. quote(k) .. ": " .. encode(v, inner)
    end
    return "{\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "}"
end

---@param v any
---@param indent string
---@return string
encode = function(v, indent)
    local kind = type(v)
    if kind == "table" then return encodeTable(v, indent) end
    if kind == "string" then return quote(v) end
    if kind == "number" then return number(v) end
    if kind == "boolean" then return tostring(v) end
    return "null"
end

---Pretty JSON with sorted object keys.
---@param value any
---@return string
function AdminPanel.Json.Encode(value)
    return encode(value, "") .. "\n"
end
