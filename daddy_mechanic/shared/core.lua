-- Small helpers both sides use.

Core = {}

local function find(node, key)
    for part in key:gmatch('[^.]+') do
        node = type(node) == 'table' and node[part] or nil
    end
    return type(node) == 'string' and node or nil
end

function Core.t(key, ...)
    local text = find(Locales and Locales[Config.Locale], key) or find(Locales and Locales.en, key) or key
    return select('#', ...) > 0 and text:format(...) or text
end

function Core.locale()
    return Locales and (Locales[Config.Locale] or Locales.en) or {}
end

function Core.int(value, lo, hi)
    if type(value) ~= 'number' or value ~= value or value % 1 ~= 0 then return nil end
    if (lo and value < lo) or (hi and value > hi) then return nil end
    return math.floor(value)
end

function Core.num(value, fallback)
    local n = tonumber(value)
    if not n or n ~= n or n == math.huge or n == -math.huge then return fallback end
    return n
end

function Core.plate(value)
    if type(value) ~= 'string' then return nil end
    local plate = value:match('^%s*(.-)%s*$')
    return plate ~= '' and plate:upper() or nil
end

function Core.decode(value)
    if type(value) == 'table' then return value end
    if type(value) ~= 'string' or value == '' then return {} end
    local ok, out = pcall(json.decode, value)
    return ok and type(out) == 'table' and out or {}
end

function Core.has(list, value)
    for _, item in ipairs(list or {}) do
        if item == value then return true end
    end
    return false
end

function Core.stashes(shopId, shop)
    local list = shop.stashes or (shop.stash and { shop.stash }) or {}
    for i, s in ipairs(list) do
        s.id = s.id or ('daddy_mechanic:%s%s'):format(shopId, i > 1 and (':' .. i) or '')
    end
    return list
end
