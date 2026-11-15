local util = {}

function util.trim(value, maxLength)
    if type(value) ~= 'string' then return nil end
    local out = value:match('^%s*(.-)%s*$')
    if out == '' then return nil end
    return maxLength and out:sub(1, maxLength) or out
end

function util.clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

function util.decodeJson(value)
    if type(value) == 'table' then return value end
    if type(value) ~= 'string' or value == '' then return {} end
    local ok, decoded = pcall(json.decode, value)
    return ok and type(decoded) == 'table' and decoded or {}
end

-- A database flag as a boolean: oxmysql gives TINYINT(1) as true/false, other drivers as 0/1.
function util.flag(value)
    return value == true or value == 1 or value == '1'
end

function util.contains(list, value)
    for _, item in ipairs(list or {}) do
        if item == value then return true end
    end
    return false
end

return util
