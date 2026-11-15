-- Reads the product's Locales table: Locales.en = { ... }, Locales.tr = { ... }.
local locale = {}

function locale.language()
    local wanted = Config and Config.Locale or 'en'
    return Locales and Locales[wanted] and wanted or 'en'
end

function locale.table()
    return Locales and Locales[locale.language()] or {}
end

local function lookup(node, key, ...)
    for part in key:gmatch('[^.]+') do
        node = type(node) == 'table' and node[part] or nil
    end
    if type(node) ~= 'string' then return key end
    return select('#', ...) > 0 and node:format(...) or node
end

-- t('errors.not_found', ...) -> formatted string, or the key if missing.
function locale.t(key, ...)
    return lookup(locale.table(), key, ...)
end

-- The lib's own texts (placement HUD, prompts), in the product's language.
local libTexts

local function readLibLocale(language)
    local source = LoadResourceFile('daddy_lib', ('locales/%s.lua'):format(language))
    if not source then return nil end
    local env = setmetatable({ Locales = {} }, { __index = _G })
    local chunk = load(source, ('@@daddy_lib/locales/%s.lua'):format(language), 't', env)
    return chunk and pcall(chunk) and env.Locales[language] or nil
end

function locale.lib(key, ...)
    libTexts = libTexts or readLibLocale(locale.language()) or readLibLocale('en') or {}
    return lookup(libTexts, key, ...)
end

return locale
