-- Texts from the product's Locales table in Config.Locale; a key missing there falls back to English.
do
    Core = Core or {}

    local locale = {}
    Core.locale = locale

    function locale.language()
        local wanted = Config and Config.Locale or 'en'
        return Locales and Locales[wanted] and wanted or 'en'
    end

    function locale.table()
        return Locales and Locales[locale.language()] or {}
    end

    local function find(node, key)
        for part in key:gmatch('[^.]+') do
            node = type(node) == 'table' and node[part] or nil
        end
        return type(node) == 'string' and node or nil
    end

    -- t('bot.failed', ...) -> the formatted text, or the key when no language has it.
    function locale.t(key, ...)
        local text = find(locale.table(), key) or find(Locales and Locales.en, key)
        if not text then return key end
        return select('#', ...) > 0 and text:format(...) or text
    end
end

-- Other Daddy resources Multichar talks to, by the names set in config/cfg_main.lua; nil while one is not started.
do
    Core = Core or {}

    local product = {}
    Core.product = product

    local NAMES = {
        onboarding = function() return (Config.Onboarding or {}).Resource or 'daddy_onboarding' end,
        pausemenu = function() return (Config.PauseMenu or {}).Resource or 'daddy_pausemenu' end,
    }

    function product.resource(id)
        local name = NAMES[id] and NAMES[id]()
        return type(name) == 'string' and GetResourceState(name) == 'started' and name or nil
    end
end

-- Core: the product's own helpers (util, locale, product links; migrate, rate limits, admin transport, bot on the server).
do
    Core = Core or {}

    local util = {}
    Core.util = util

    -- Trimmed text, nil when empty; maxLength cuts it.
    function util.trim(value, maxLength)
        if type(value) ~= 'string' then return nil end
        local out = value:match('^%s*(.-)%s*$')
        if out == '' then return nil end
        return maxLength and out:sub(1, maxLength) or out
    end

    -- JSON text (or a table) as a table; {} for anything else.
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
end
