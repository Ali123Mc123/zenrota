Gangs = {}

function L(key, ...)
    local text = (Locales[Config.Locale] or Locales.en)[key] or Locales.en[key] or key
    if select('#', ...) > 0 then return text:format(...) end
    return text
end

function Gangs.trim(value, max)
    if type(value) ~= 'string' then return nil end
    value = value:gsub('^%s+', ''):gsub('%s+$', ''):gsub('[%c<>]', '')
    if value == '' or #value > max then return nil end
    return value
end

function Gangs.int(value, min, max)
    if math.type(value) ~= 'integer' then
        if type(value) ~= 'number' or value ~= value or value % 1 ~= 0 then return nil end
        value = math.tointeger(value)
        if not value then return nil end
    end
    if value < min or value > max then return nil end
    return value
end

function Gangs.oneOf(value, list)
    for i = 1, #list do
        if list[i] == value then return value end
    end
    return nil
end

-- the limits of a level, the last level for anything above it
function Gangs.level(n)
    return Config.Levels[n] or Config.Levels[#Config.Levels]
end

Gangs.PermissionSet = {}
for _, name in ipairs(Config.Permissions) do Gangs.PermissionSet[name] = true end

-- a #rrggbb colour or nil
function Gangs.color(value)
    return type(value) == 'string' and value:match('^#%x%x%x%x%x%x$') and value:lower() or nil
end
