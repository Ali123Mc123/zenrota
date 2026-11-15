local Locales = {}

local function loadLocale()
    local lang = GetConvar('qb_locale', 'tr')
    local file = LoadResourceFile(GetCurrentResourceName(), ('locales/%s.json'):format(lang))
    if not file then
        file = LoadResourceFile(GetCurrentResourceName(), 'locales/tr.json')
    end

    if file then
        Locales = json.decode(file)
    end
end

function locale(str, args)
    if not str then return "" end
    local parts = {}
    for part in str:gmatch("([^.]+)") do
        table.insert(parts, part)
    end

    local current = Locales
    for _, part in ipairs(parts) do
        if current[part] then
            current = current[part]
        else
            return str
        end
    end

    if type(current) == 'string' then
        if args and type(args) == 'table' then
            for k, v in pairs(args) do
                current = current:gsub("%%{" .. k .. "}", tostring(v))
            end
        end
        return current
    end

    return str
end

loadLocale()
