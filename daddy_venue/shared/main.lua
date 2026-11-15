Venue = {}

function L(key, ...)
    local text = (Locales[Config.Locale] or Locales.en)[key] or Locales.en[key] or key
    if select('#', ...) > 0 then return text:format(...) end
    return text
end

-- the text a customer sees when a kiosk does not open
function Venue.closedText(data)
    if data.error == 'hours' then return data.hours and L('closed_hours', data.hours) or L('closed_today') end
    if data.error == 'closed' then return L('closed') end
    return L('no_kiosk')
end

function Venue.objectName(kind)
    local key = 'obj_' .. tostring(kind)
    local pack = Locales[Config.Locale] or Locales.en
    local def = Config.Build and Config.Build.Objects[kind]
    return pack[key] or (def and def.label) or Locales.en[key] or tostring(kind)
end

function Venue.decorName(item)
    return (Locales[Config.Locale] or Locales.en)['decor_' .. item.key] or item.label
end

Venue.Errors = { 'forbidden', 'not_found', 'invalid', 'no_funds', 'no_stock', 'closed', 'busy', 'expired', 'limit', 'taken', 'locked', 'disabled' }

function Venue.trim(value, max)
    if type(value) ~= 'string' then return nil end
    value = value:gsub('^%s+', ''):gsub('%s+$', ''):gsub('[%c<>]', '')
    if value == '' or #value > max then return nil end
    return value
end

function Venue.int(value, min, max)
    if math.type(value) ~= 'integer' then
        if type(value) ~= 'number' or value ~= value or value % 1 ~= 0 then return nil end
        value = math.tointeger(value)
        if not value then return nil end
    end
    if value < min or value > max then return nil end
    return value
end

function Venue.num(value, min, max, decimals)
    if type(value) ~= 'number' or value ~= value or value == math.huge or value == -math.huge then return nil end
    if value < min or value > max then return nil end
    local scale = 10 ^ (decimals or 0)
    return math.floor(value * scale + 0.5) / scale
end

-- oxmysql returns TINYINT(1) columns as booleans, plain numbers elsewhere
function Venue.flag(value)
    return value == true or value == 1
end

function Venue.bool(value)
    if type(value) ~= 'boolean' then return nil end
    return value
end

function Venue.oneOf(value, list)
    for i = 1, #list do
        if list[i] == value then return value end
    end
    return nil
end

function Venue.time(value)
    if type(value) ~= 'string' then return nil end
    local h, m = value:match('^(%d%d):(%d%d)$')
    h, m = tonumber(h), tonumber(m)
    if not h or h > 23 or m > 59 then return nil end
    return value
end

function Venue.accent(value)
    if type(value) ~= 'string' then return nil end
    local r, g, b = value:match('^(%d%d?%d?) (%d%d?%d?) (%d%d?%d?)$')
    if not r or tonumber(r) > 255 or tonumber(g) > 255 or tonumber(b) > 255 then return nil end
    return value
end

function Venue.set(list)
    local out = {}
    for i = 1, #list do out[list[i]] = true end
    return out
end
