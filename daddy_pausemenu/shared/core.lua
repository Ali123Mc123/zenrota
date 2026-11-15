-- Pause menu data both sides share: screens, menu items and the player's interface prefs. No natives, so tests run it.
PMShared = {}

PMShared.SCREENS = { pause = true, map = true, settings = true, stats = true, photo = true, rules = true }
PMShared.MENU = { 'resume', 'map', 'settings', 'stats', 'photo', 'rules', 'leave' }

-- Interface prefs, in the UI's order (indices are 0-based, as the UI keeps them).
-- Menu languages a player can pick (Settings > Display; 0 keeps Config.Locale). Each one needs locales/<code>.lua and
-- an entry in the settings list `langs` (tools/pausemenu/settings-texts.json).
PMShared.LANGS = { 'en', 'tr' }
PMShared.MOTIONS = { 'full', 'reduced', 'off' }
PMShared.SCALES = { 85, 90, 95, 100, 105 }
PMShared.ACCENTS = { '#c8102e', '#ff7a3d', '#ffd23f', '#9be15d', '#e3cda6', '#e8a33d', '#6c7bff', '#9b7bff', '#e04dff', '#ff3b30' }

local DEFAULT_ACCENT = '#c8102e'

local function indexOf(list, value)
    for i = 1, #list do
        if list[i] == value then return i - 1 end
    end
end

local function isHex(value)
    return type(value) == 'string' and value:match('^#%x%x%x%x%x%x$') ~= nil
end
PMShared.isHex = isHex

-- Whole number in [lo, hi], or nil.
local function int(value, lo, hi)
    value = tonumber(value)
    if not value or value ~= value or value % 1 ~= 0 or value < lo or value > hi then return nil end
    return math.floor(value)
end

local function flag(value)
    if value == true or value == 1 then return 1 end
    if value == false or value == 0 then return 0 end
end

-- Config.Menu with unknown ids and repeats dropped; every item when nothing valid is left.
function PMShared.menu(list)
    local out, seen = {}, {}
    for _, id in ipairs(type(list) == 'table' and list or {}) do
        if indexOf(PMShared.MENU, id) and not seen[id] then
            seen[id] = true
            out[#out + 1] = id
        end
    end
    if #out == 0 then
        for i = 1, #PMShared.MENU do out[i] = PMShared.MENU[i] end
    end
    return out
end

-- First-use prefs from Config.Theme: { lang, scale, accent, accentC, charcam, blur, motion }. accent = #ACCENTS means accentC.
function PMShared.defaultPrefs(theme)
    theme = type(theme) == 'table' and theme or {}
    local hex = isHex(theme.accent) and theme.accent:lower() or DEFAULT_ACCENT
    local preset = indexOf(PMShared.ACCENTS, hex)
    return {
        lang = 0,
        scale = indexOf(PMShared.SCALES, tonumber(theme.scale)) or 3,
        accent = preset or #PMShared.ACCENTS,
        accentC = preset and DEFAULT_ACCENT or hex,
        charcam = theme.charCam == false and 0 or 1,
        blur = theme.blur == false and 0 or 1,
        motion = indexOf(PMShared.MOTIONS, theme.motion) or 0,
    }
end

-- Prefs from the UI or from storage, checked field by field; a bad field keeps its default. With
-- Config.Theme.langChoice off every player gets the server's language.
function PMShared.normalizePrefs(input, theme)
    local out = PMShared.defaultPrefs(theme)
    if type(input) ~= 'table' then return out end
    if type(theme) ~= 'table' or theme.langChoice ~= false then out.lang = int(input.lang, 0, #PMShared.LANGS) or out.lang end
    out.scale = int(input.scale, 0, #PMShared.SCALES - 1) or out.scale
    out.accent = int(input.accent, 0, #PMShared.ACCENTS) or out.accent
    out.accentC = isHex(input.accentC) and input.accentC:lower() or out.accentC
    out.charcam = flag(input.charcam) or out.charcam
    out.blur = flag(input.blur) or out.blur
    out.motion = int(input.motion, 0, #PMShared.MOTIONS - 1) or out.motion
    return out
end

-- Footer links: only http(s) addresses reach the UI.
function PMShared.link(value)
    if type(value) ~= 'string' or #value > 512 or not value:match('^https?://[%w%-%.]+') then return '' end
    return value
end

-- Rule keys as locale key parts (lowercase words), in order, at most 24.
function PMShared.rules(list)
    local out = {}
    for _, key in ipairs(type(list) == 'table' and list or {}) do
        if type(key) == 'string' and key:match('^[a-z][a-z0-9_]*$') and #out < 24 then out[#out + 1] = key end
    end
    return out
end
