-- Map blips: every sprite is swept, each blip gets a category (shared/map_categories.lua) and a name from, in order,
-- the SetBlipMeta export, GTA's own name of a place (read back through a scaleform echo, client/map/names.lua), the
-- shim other resources can load, the game (when FiveM adds GET_BLIP_DISPLAY_NAME), or the page's category name. No
-- native reads a blip's name today (research E section 2.4).
local Cfg = Config.Map or {}
local SPRITE_MAX = 1023 -- b3258 has 0..965; room for newer builds
-- 4/5/9 wanted, area and radius rings (no size getter), 6 the player, 7 north, 8 the waypoint (both drawn by the page).
local SKIP = { [4] = true, [5] = true, [6] = true, [7] = true, [8] = true, [9] = true }
-- Screens that show the blip list (map screen and home web mini map).
local SCREENS = { map = true, pause = true }
-- citizenfx/fivem PR 4196; nil until FiveM ships it. Resolved once: a missing native is looked up again on every read.
local displayName = _G.GetBlipDisplayName

local cats = PMMap.build(Cfg)
local hide = {}
for _, v in ipairs(type(Cfg.HideDisplay) == 'table' and Cfg.HideDisplay or { 0 }) do hide[v] = true end

local names, metas = {}, {}
-- What the page has: [blip] = record, their count, the entity blips among them, and whether the next sweep must send.
local tracked, trackedN, moving, unsent = {}, 0, {}, true
local labels, displays = {}, {}
local info = {} -- PMMap.categorize only reads it: one table for every blip

PM.Map = PM.Map or {}
PM.Map.cats = cats

local function round1(v) return math.floor(v * 10 + 0.5) / 10 end

function PM.Map.BlipsShown()
    return PM.IsOpen() and SCREENS[PM.Screen()] == true
end

-- The page's list is unknown once its screen is gone: the next visit starts with a full list.
local function forget()
    tracked, trackedN, moving, unsent = {}, 0, {}, true
end

-- True until a sweep sends the full list again: the feed then sweeps at once (a quick map, home, map flip that its
-- 100 ms tick never saw would otherwise leave the moving blips still until the next timed sweep).
function PM.Map.BlipsUnsent() return unsent end

-- The game's default label, only for blips no category covers ('BLIP_108' is "Devin", not a bank: E verifier V7).
local function gameLabel(sprite)
    local v = labels[sprite]
    if v == nil then
        local key = 'BLIP_' .. sprite
        v = DoesTextLabelExist(key) and PMMap.label(GetLabelText(key)) or false
        labels[sprite] = v
    end
    return v or nil
end

-- place: a blip the list can show (not a player, alert or entity blip), so GTA's name of it is worth reading.
local function nameOf(blip, sprite, cat, colour, place)
    local meta = metas[blip]
    if meta and meta.label then return meta.label end
    -- The name the blip's own resource set (shim), reported the moment it was set: before GTA's name read back, whose
    -- cache is by handle. A resource that removes its blips and makes new ones (F3 blips toggled off and on) gets the
    -- same handles in another order; the cache then put "Benzin İstasyonu #25" on station 23 until it read again.
    local named = names[blip]
    if named and named.label then return named.label end
    -- GTA's own name (what its legend shows, names.lua). A categorised blip that only carries its sprite's default
    -- label ('BLIP_108' is "Devin", E verifier V7) keeps the category name.
    if place and PM.Map.GameName then
        local game = PM.Map.GameName(blip, sprite, colour)
        if game and (cat == 'other' or game ~= gameLabel(sprite)) then return game end
    end
    if displayName then
        local ok, text = pcall(displayName, blip)
        if ok then
            text = PMMap.label(text)
            if text then return text end
        end
    end
    if cat == 'other' then return gameLabel(sprite) end
end

-- The blip's record, or the page's own one (and true) when nothing in it changed.
local function read(blip, sprite)
    local display = GetBlipInfoIdDisplay(blip)
    -- The getter's numbering is unproven (E test 4): unknown values are logged, not hidden.
    if Cfg.Debug and not displays[display] then
        displays[display] = true
        print(('[daddy_pausemenu] map: blip display %s (sprite %s)'):format(display, sprite))
    end
    if hide[display] or GetBlipAlpha(blip) == 0 then return nil end
    local meta = metas[blip]
    if meta and meta.hidden then return nil end
    local et = GetBlipInfoIdType(blip) -- 1 vehicle, 2 ped, 3 object, 4 coord, 6 pickup, 7 radius
    if et == 7 then return nil end
    local c = GetBlipInfoIdCoord(blip)
    local ent = (et >= 1 and et <= 3) and GetBlipInfoIdEntityIndex(blip) or 0
    local player = et == 2 and ent ~= 0 and IsPedAPlayer(ent)
    local hex, colour = PMMap.colourHex(GetBlipColour(blip))
    local short = IsBlipShortRange(blip)
    local named = names[blip]
    info.meta, info.player, info.sprite, info.colour, info.short = meta and meta.category, player, sprite, colour, short
    info.resource = named and named.resource
    local cat = PMMap.categorize(cats, info)
    local group = meta and meta.group -- a sub-group the list shows as its own filter (GPS departments)
    local name = nameOf(blip, sprite, cat, colour, not player and not (et >= 1 and et <= 3) and cat ~= 'alerts' and cat ~= 'players')
    if player and not name then name = GetPlayerName(NetworkGetPlayerIndexFromPed(ent)) end
    local x, y, rot = round1(c.x), round1(c.y), GetBlipRotation(blip)
    local old = tracked[blip]
    if old and old.x == x and old.y == y and old.rot == rot and old.s == sprite and old.c == colour and old.hex == hex
        and old.cat == cat and old.g == group and old.name == name and old.sr == short and old.et == et then
        return old, true
    end
    return {
        id = blip, x = x, y = y, s = sprite, c = colour, hex = hex, cat = cat, g = group, name = name,
        sr = short, rot = rot, et = et, d = sprite == 161, m = et >= 1 and et <= 3,
    }, false
end

-- Names and metas of blips that are gone.
local function prune()
    for blip in pairs(names) do
        if not DoesBlipExist(blip) then names[blip] = nil end
    end
    for blip in pairs(metas) do
        if not DoesBlipExist(blip) then metas[blip] = nil end
    end
    if PM.Map.PruneNames then PM.Map.PruneNames() end
end

-- GTA's name of a shown place changed (names.lua): the feed sweeps on its next tick and resends.
function PM.Map.NamesChanged() unsent = true end

-- Full sweep, in four slices of 256 sprites (never a Wait inside one sprite: the iterator is global game state).
-- The list goes to the page only when it differs from what the page has.
function PM.Map.PushBlips()
    local list, seen, movers, n, m, same = {}, {}, {}, 0, 0, true
    local own = GetMainPlayerBlipId()
    for first = 0, SPRITE_MAX, 256 do
        for sprite = first, math.min(first + 255, SPRITE_MAX) do
            if not SKIP[sprite] then
                local blip, guard = GetFirstBlipInfoId(sprite), 0
                while blip ~= 0 and guard < 4096 and DoesBlipExist(blip) do
                    -- The focus helpers (focus.lua) are never places, whatever alpha they carry.
                    if blip ~= own and not seen[blip] and not (PM.Map.IsFocusAnchor and PM.Map.IsFocusAnchor(blip)) then
                        local rec, kept = read(blip, sprite)
                        if rec then
                            n = n + 1
                            list[n] = rec
                            seen[blip] = rec
                            same = same and kept
                            if rec.m or rec.cat == 'players' then -- GPS players are coord blips that move
                                m = m + 1
                                movers[m] = rec
                            end
                        end
                    end
                    guard = guard + 1
                    blip = GetNextBlipInfoId(sprite)
                end
            end
        end
        Wait(0)
    end
    prune()
    -- Closed or another screen by now: nothing to send, and the next visit sends in full.
    if not PM.Map.BlipsShown() then return forget() end
    same = same and n == trackedN and not unsent
    tracked, trackedN, moving, unsent = seen, n, movers, false
    if same then return end
    PM.Send('pm:map:blips', { list = list })
end

-- Entity blips (players, units, vehicles) between sweeps: only the ones that moved.
function PM.Map.PushMoving()
    local moved, n = nil, 0
    for i = 1, #moving do
        local rec = moving[i]
        local blip = rec.id
        if DoesBlipExist(blip) then
            local c = GetBlipInfoIdCoord(blip)
            local x, y, rot = round1(c.x), round1(c.y), GetBlipRotation(blip)
            if x ~= rec.x or y ~= rec.y or rot ~= rec.rot then
                rec.x, rec.y, rec.rot = x, y, rot
                n = n + 1
                moved = moved or {}
                moved[n] = { blip, x, y, rot }
            end
        end
    end
    if n > 0 then PM.Send('pm:map:blipsMove', { list = moved }) end
end

PM.OnScreen(function(screen)
    if not SCREENS[screen] then forget() end
end)

-- The shim (shim/blipnames.lua inside another resource) reports the names that resource gives its blips. Scripts that
-- rename player or unit blips often send the same text again: that costs nothing.
AddEventHandler('daddy_pausemenu:map:blipName', function(blip, text)
    if math.type(blip) ~= 'integer' then return end
    local resource, old = GetInvokingResource(), names[blip]
    if old and old.raw == text and old.resource == resource then return end
    local label = PMMap.label(text)
    names[blip] = label and { label = label, resource = resource, raw = text } or nil
end)

-- Shimmed resources send their names again after a restart of this one.
CreateThread(function()
    Wait(1000)
    TriggerEvent('daddy_pausemenu:map:collectBlipNames')
end)

-- exports.daddy_pausemenu:SetBlipMeta(blip, { label = 'Fleeca', category = 'bank', group = 'Downtown', hidden = false })
-- group: the list shows these blips under their own filter inside the category (GPS units by department).
exports('SetBlipMeta', function(blip, meta)
    if math.type(blip) ~= 'integer' or type(meta) ~= 'table' then return false end
    metas[blip] = {
        label = PMMap.label(meta.label),
        category = cats.known[meta.category] and meta.category or nil,
        group = PMMap.label(meta.group),
        hidden = meta.hidden == true,
        resource = GetInvokingResource(),
    }
    return true
end)

-- A stopped resource's blips are gone, and GTA hands their handles to new blips (of any resource): its labels go too,
-- or a restarted qb-radialmenu leaves "Benzin İstasyonu #24" on some other blip.
AddEventHandler('onClientResourceStop', function(resource)
    for blip, meta in pairs(metas) do
        if meta.resource == resource then metas[blip] = nil end
    end
    for blip, named in pairs(names) do
        if named.resource == resource then names[blip] = nil end
    end
end)

exports('ClearBlipMeta', function(blip)
    if math.type(blip) == 'integer' then metas[blip] = nil end
end)
