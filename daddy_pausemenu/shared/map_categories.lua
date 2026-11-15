-- Map blips: which sprite is a police station or a garage, each category's colour, the player and dispatch rules,
-- and the checks for map input. No natives, so tests run it. Category names and glyphs live in locales (map.*).
PMMap = {}

-- Legend order. color: '#rrggbb', 'accent' (the menu accent) or 'blip' (the blip's own game colour).
PMMap.CATEGORIES = {
    { id = 'police', color = '#4aa8ff', sprites = { 60, 137, 526, 41, 42, 43, 56, 3, 15, 16 } },
    { id = 'medical', color = '#ff5a5a', sprites = { 61, 153, 403 } },
    { id = 'garage', color = '#ffd23f', sprites = { 357, 360, 356, 359, 524, 856 } },
    { id = 'bank', color = '#52e0a0', sprites = { 108, 207, 500, 272, 276, 277, 278 } },
    { id = 'jobs', color = 'accent', sprites = { 487, 407, 459, 380, 827, 270, 477, 318, 566, 85 } },
    { id = 'shop', color = '#ffa94d', sprites = { 52, 59, 93, 402, 628 } },
    { id = 'clothing', color = '#c792ff', sprites = { 73, 366, 102 } },
    { id = 'barber', color = '#ff8fc7', sprites = { 71 } },
    { id = 'tattoo', color = '#b4a8ff', sprites = { 75 } },
    { id = 'weapons', color = '#d9dde8', sprites = { 110, 313, 567 } },
    { id = 'fuel', color = '#f4a261', sprites = { 361, 415 } },
    { id = 'mechanic', color = '#ff7b54', sprites = { 72, 446, 643, 544 } },
    { id = 'carwash', color = '#4fd1c5', sprites = { 100, 931 } },
    { id = 'dealer', color = '#a3e635', sprites = { 326, 523, 225, 410, 251, 810 } },
    { id = 'impound', color = '#d4a373', sprites = { 68, 317 } },
    { id = 'airport', color = '#7dd3fc', sprites = { 90, 138, 307 } },
    { id = 'transport', color = '#94a3b8', sprites = { 513, 795, 36, 198 } },
    { id = 'housing', color = '#e9b872', sprites = { 40, 350, 374, 375, 475, 476, 492, 557, 436, 267 } },
    { id = 'leisure', color = '#f472b6', sprites = { 121, 135, 679, 680, 74, 109, 122, 197 } },
    { id = 'players', color = '#ffffff', sprites = {} },
    { id = 'alerts', color = '#ff3b30', sprites = { 161 } },
    { id = 'other', color = 'blip', sprites = {} },
}

-- Blips named through the shim take their creator's category when the sprite says nothing.
PMMap.RESOURCES = {
    qbx_garages = 'garage', qbx_police = 'police', qbx_ambulancejob = 'medical', qbx_customs = 'mechanic',
    qbx_mechanicjob = 'mechanic', qbx_carwash = 'carwash', qbx_vehicleshop = 'dealer', qbx_vehiclesales = 'dealer',
    qbx_cityhall = 'jobs', qbx_newsjob = 'jobs', qbx_scrapyard = 'jobs', qbx_vineyard = 'jobs',
    ox_fuel = 'fuel', ['Renewed-Banking'] = 'bank', ['illenium-appearance'] = 'clothing',
}

-- The design's map colours; the page recolours the game's own map textures with them.
PMMap.PALETTE = {
    sea = '#14213d', land = '#3a4163', outline = '#6b78aa', block = '#262c47', park = '#1f4a47',
    road = '#4f5a88', highway = '#8794c6',
}

-- Blip colour ids 0..85 (docs.fivem.net blip colours).
local COLOURS = {}
do
    local list = 'fefefe e03232 71cb71 5db6e5 fefefe eec64e c25050 9c6eaf fe7ac3 f59d79 b18f83 8dcea7 '
        .. '70a8ae d3d1e7 8f7e98 6ac4bf d5c398 ea8e50 97cae9 b26287 8f8d79 a6755e afa8a8 e78d9a '
        .. 'bbd65b 0c7b56 7ac3fe ab3ce6 cda80c 4561ab 29a5b8 b89b7b c8e0fe f0f096 ed8ca1 f98a8a '
        .. 'fbeea5 fefefe 2c6db8 9a9a9a 4c4c4c f29d9d 6cb7d6 afedae ffa75f f1f1f1 ecf029 ff9a18 '
        .. 'f644a5 e03a3a 8a6de3 ff8b5c 416c41 b3ddf3 3a6479 a0a0a0 847232 65b9e7 4b4175 e13b3b '
        .. 'f0cb58 cd3f98 cfcfcf 276a9f d87b1b 8e8393 f0cb57 65b9e7 65b9e7 79cd79 efca57 efca57 '
        .. '3d3d3d efca57 65b9e7 e03232 782323 65b9e7 3a6479 e03232 65b9e7 f2a40c a4ccaa a854f2 '
        .. '65b9e7 3d3d3d'
    local i = 0
    for hex in list:gmatch('%x+') do
        COLOURS[i] = '#' .. hex
        i = i + 1
    end
end

local function isHex(v)
    return type(v) == 'string' and v:match('^#%x%x%x%x%x%x$') ~= nil
end

local function color(v)
    if v == 'accent' or v == 'blip' then return v end
    if isHex(v) then return v:lower() end
end

-- One letter (any UTF-8 character) or two ASCII ones.
local function glyph(v)
    if type(v) == 'string' and #v >= 1 and #v <= 4 then return v end
end

-- Whole number in [lo, hi], or the fallback.
function PMMap.count(v, fallback, lo, hi)
    v = tonumber(v)
    if not v or v ~= v or v % 1 ~= 0 or v < lo or v > hi then return fallback end
    return math.floor(v)
end

-- Categories with Config.Map overrides: { list = { { id, color, glyph? } }, sprite = { [n] = id },
-- resource = { [name] = id }, known = { [id] = true } }.
function PMMap.build(cfg)
    cfg = type(cfg) == 'table' and cfg or {}
    local over = type(cfg.Categories) == 'table' and cfg.Categories or {}
    local out = { list = {}, sprite = {}, resource = {}, known = {} }
    for _, cat in ipairs(PMMap.CATEGORIES) do
        local o = type(over[cat.id]) == 'table' and over[cat.id] or {}
        out.known[cat.id] = true
        out.list[#out.list + 1] = { id = cat.id, color = color(o.color) or cat.color, glyph = glyph(o.glyph) }
        for _, sprite in ipairs(cat.sprites) do out.sprite[sprite] = cat.id end
    end
    for name, id in pairs(PMMap.RESOURCES) do out.resource[name] = id end
    for sprite, id in pairs(type(cfg.Sprites) == 'table' and cfg.Sprites or {}) do
        local n = PMMap.count(sprite, nil, 0, 4095)
        if n and out.known[id] then out.sprite[n] = id end
    end
    for name, id in pairs(type(cfg.Resources) == 'table' and cfg.Resources or {}) do
        if type(name) == 'string' and out.known[id] then out.resource[name] = id end
    end
    return out
end

-- info = { meta = id?, player = bool, sprite = n, colour = id, short = bool, resource = name? }
function PMMap.categorize(cats, info)
    if info.meta and cats.known[info.meta] then return info.meta end
    if info.player then return 'players' end
    local id = cats.sprite[info.sprite]
    -- qbx dispatch alerts reuse the station sprites, in red and long range.
    if (id == 'police' or id == 'medical') and info.colour == 1 and not info.short then return 'alerts' end
    if id then return id end
    return info.resource and cats.resource[info.resource] or 'other'
end

-- GET_BLIP_COLOUR: an id from the table (hex, id) or a 0xRRGGBBAA int, negative when R >= 128 (hex, -1).
function PMMap.colourHex(col)
    col = math.floor(tonumber(col) or 0)
    if col >= 0 and col <= 255 then return COLOURS[col] or '#ffffff', col end
    return ('#%06x'):format((col & 0xFFFFFFFF) >> 8), -1
end

-- The listed known ids without repeats, and no default fill (Config.Map.Folded).
function PMMap.known(list, cats)
    local out, seen = {}, {}
    for _, id in ipairs(type(list) == 'table' and list or {}) do
        if cats.known[id] and not seen[id] then
            seen[id] = true
            out[#out + 1] = id
        end
    end
    return out
end

-- The whole legend order: the listed known ids first (Config.Map.Order, or the old Chips), then every other category
-- in PMMap.CATEGORIES order. Players and alerts are never places.
function PMMap.order(list, cats)
    local out, seen = {}, { players = true, alerts = true }
    for _, id in ipairs(PMMap.known(list, cats)) do
        if not seen[id] then
            seen[id] = true
            out[#out + 1] = id
        end
    end
    for _, cat in ipairs(PMMap.CATEGORIES) do
        if not seen[cat.id] then
            seen[cat.id] = true
            out[#out + 1] = cat.id
        end
    end
    return out
end

function PMMap.palette(input)
    input = type(input) == 'table' and input or {}
    local out = {}
    for key, hex in pairs(PMMap.PALETTE) do out[key] = isHex(input[key]) and input[key]:lower() or hex end
    return out
end

-- A point clicked on the map: finite world x, y inside the playable area (Cayo Perico included), or nil.
function PMMap.point(x, y)
    x, y = tonumber(x), tonumber(y)
    if not x or not y or x ~= x or y ~= y then return nil end
    if x < -6000 or x > 7000 or y < -7000 or y > 9000 then return nil end
    return x + 0.0, y + 0.0
end

-- A blip name from another resource: GTA colour codes (~r~) and padding dropped, 64 bytes at most, nil when empty.
function PMMap.label(text)
    if type(text) ~= 'string' then return nil end
    text = text:gsub('~[^~]*~', ''):gsub('^%s+', ''):gsub('%s+$', '')
    if text == '' then return nil end
    if #text <= 64 then return text end
    -- Cut on a character boundary: a trailing, possibly incomplete UTF-8 sequence goes.
    return (text:sub(1, 64):gsub('[\192-\255][\128-\191]*$', ''))
end

-- The blip name in an echo's answer (client/map/names.lua): prefix .. name, of which GTA's string getter keeps cap
-- bytes. A cut answer loses a split UTF-8 character and a split ~x~ token; whole tokens go first, so a cut after a
-- leading ~g~ keeps the name. nil: not an answer to us; false: the blip has no name.
function PMMap.echoName(s, prefix, cap)
    if type(s) ~= 'string' or type(prefix) ~= 'string' or s:sub(1, #prefix) ~= prefix then return nil end
    local cut = #s >= (cap or 63)
    s = s:sub(#prefix + 1)
    if cut then
        for _ = 1, 3 do
            if utf8.len(s) then break end
            s = s:sub(1, -2)
        end
        s = s:gsub('~[^~]*~', ''):gsub('~[^~]*$', '')
    end
    if s == 'NULL' then return false end
    return PMMap.label(s) or false
end
