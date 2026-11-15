local translationCache = {}

local function getTranslation(data, key)
    local current = data
    for k in key:gmatch("([^%.]+)") do
        local lowKey = k:lower()
        if current and type(current) == 'table' and current[lowKey] then
            current = current[lowKey]
        else
            return key
        end
    end
    return current
end

function GetTranslations()
    local locale = Settings.Locale or 'tr'
    if translationCache[locale] then
        return translationCache[locale]
    end

    local file = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. locale .. '.json')
    if not file then 
        return {} 
    end

    local status, data = pcall(json.decode, file)
    if not status or not data then
        return {}
    end

    translationCache[locale] = data
    return data
end

function _L(key, ...)
    local data = GetTranslations()
    if not data then return key end

    local text = getTranslation(data, key)
    if type(text) ~= 'string' then return key end

    local params = { ... }
    if #params > 0 then
        if type(params[1]) == 'table' then
            for k, v in pairs(params[1]) do
                text = text:gsub('{' .. k .. '}', tostring(v))
            end
        else
            if text:find('%%') then
                text = string.format(text, table.unpack(params))
            end
        end
    end

    return text
end
