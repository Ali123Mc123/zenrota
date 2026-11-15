-- ═══════════════════════════════════════════════════════════════════════════════
-- Daddy Marketplace - Locale System
-- Language files live in /locales. English ('en') is the fallback for missing keys.
-- ═══════════════════════════════════════════════════════════════════════════════

Daddy = Daddy or {}
Daddy.Locale = {}

local activeLocale = {}
local fallbackLocale = {}
local mergedLocale = {}

--- @param lang string language code from Config.Locale (e.g. 'en')
function Daddy.Locale.Init(lang)
    lang = lang or 'en'
    fallbackLocale = (Locales and Locales['en']) or {}

    if Locales and Locales[lang] then
        activeLocale = Locales[lang]
    else
        activeLocale = fallbackLocale
        print('^1[Daddy Marketplace] ^7Locale "' .. lang .. '" not found, falling back to "en"^7')
    end

    mergedLocale = {}
    for k, v in pairs(fallbackLocale) do mergedLocale[k] = v end
    for k, v in pairs(activeLocale) do mergedLocale[k] = v end
end

--- Translate a key; extra arguments are applied with string.format (%s, %d)
function Daddy.Locale.Get(key, ...)
    local text = activeLocale[key] or fallbackLocale[key] or key

    if select('#', ...) > 0 then
        local ok, formatted = pcall(string.format, text, ...)
        if ok then return formatted end
    end

    return text
end

_L = function(key, ...)
    return Daddy.Locale.Get(key, ...)
end

--- All strings (active language on top of English) for the NUI
function Daddy.Locale.GetAll()
    return mergedLocale
end
