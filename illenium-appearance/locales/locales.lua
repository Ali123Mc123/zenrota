Locales = {}

-- the menu language: Config.Locale, else the convar
function LocaleName()
    return Config.Locale or GetConvar("illenium-appearance:locale", "en")
end

function _L(key)
    local lang = LocaleName()
    if not Locales[lang] then
        lang = "en"
    end
    local value = Locales[lang]
    for k in key:gmatch("[^.]+") do
        value = value[k]
        if not value then
            print("Missing locale for: " .. key)
            return ""
        end
    end
    return value
end
