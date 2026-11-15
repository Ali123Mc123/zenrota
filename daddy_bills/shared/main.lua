Bills = {}

function L(key, ...)
    local text = (Locales[Config.Locale] or Locales.en)[key] or Locales.en[key] or key
    if select('#', ...) > 0 then return text:format(...) end
    return text
end

function Bills.trim(value, max)
    if type(value) ~= 'string' then return nil end
    value = value:gsub('^%s+', ''):gsub('%s+$', ''):gsub('[%c<>]', '')
    if value == '' or #value > max then return nil end
    return value
end

function Bills.int(value, min, max)
    if math.type(value) ~= 'integer' then
        if type(value) ~= 'number' or value ~= value or value % 1 ~= 0 then return nil end
        value = math.tointeger(value)
        if not value then return nil end
    end
    if value < min or value > max then return nil end
    return value
end

function Bills.num(value, min, max, decimals)
    if type(value) ~= 'number' or value ~= value or value == math.huge or value == -math.huge then return nil end
    if value < min or value > max then return nil end
    local scale = 10 ^ (decimals or 0)
    return math.floor(value * scale + 0.5) / scale
end

function Bills.oneOf(value, list)
    for i = 1, #list do
        if list[i] == value then return value end
    end
    return nil
end

function Bills.number(id)
    return ('%s%06d'):format(Config.NumberPrefix, id)
end
