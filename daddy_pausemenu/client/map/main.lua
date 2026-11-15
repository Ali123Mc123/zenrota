-- Map module: the player, blips, waypoint and GPS route length for the places screen and the home mini map (GTA's own
-- map is the full map, GTA's radar the mini map). Its thread runs while map or pause shows; blips only on map.
local Cfg = Config.Map or {}
local PLAYER_MS, MOVE_MS, BLIP_MS, ROUTE_MS, ZONE_MS = 100, 250, 1500, 1000, 1000

local active, token = false, 0
local lastRoute, routeUntil, lastZone = nil, 0, nil
local lastX, lastY, lastH, lastVeh = nil, nil, nil, nil
local lastProbe = 0

local function round1(v) return math.floor(v * 10 + 0.5) / 10 end

-- The places list: the filter line's category order and the categories All leaves out.
local function config()
    return {
        categories = PM.Map.cats.list,
        order = PMMap.order(Cfg.Order or Cfg.Chips, PM.Map.cats), -- Chips: configs from before the groups
        folded = PMMap.known(Cfg.Folded or { 'other' }, PM.Map.cats),
        metric = ShouldUseMetricMeasurements(),
    }
end

-- Sent only when it changed: the page eases toward the last one it got.
local function pushPlayer()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local ent = veh ~= 0 and veh or ped
    local c = GetEntityCoords(ent)
    local x, y, h, inVeh = round1(c.x), round1(c.y), round1(GetEntityHeading(ent)), veh ~= 0
    if x ~= lastX or y ~= lastY or h ~= lastH or inVeh ~= lastVeh then
        lastX, lastY, lastH, lastVeh = x, y, h, inVeh
        PM.Send('pm:map:player', { x = x, y = y, h = h, veh = inVeh })
    end
    return c
end

local function zoneAt(x, y, z)
    local code = GetNameOfZone(x, y, z)
    local label = GetLabelText(code)
    return (label ~= 'NULL' and label ~= '') and label or code
end

local function streetAt(x, y, z)
    local s1, s2 = GetStreetNameAtCoord(x, y, z)
    return s1 ~= 0 and GetStreetNameFromHashKey(s1) or nil, s2 ~= 0 and GetStreetNameFromHashKey(s2) or nil
end

local function pushZone(c)
    local zone = zoneAt(c.x, c.y, c.z)
    if zone == lastZone then return end
    lastZone = zone
    PM.Send('pm:map:zone', { zone = zone, street = (streetAt(c.x, c.y, c.z)) })
end

local function waypoint()
    if not IsWaypointActive() then return nil end
    local blip = GetFirstBlipInfoId(GetWaypointBlipEnumId())
    if blip == 0 or not DoesBlipExist(blip) then return nil end
    local c = GetBlipInfoIdCoord(blip)
    return { x = round1(c.x), y = round1(c.y) }
end

local function pushRoute(force)
    local wp = waypoint()
    local total = wp and GetGpsBlipRouteLength() or 0
    local key = wp and ('%s:%s:%s'):format(wp.x, wp.y, total) or 'none'
    if key == lastRoute and not force then return end
    lastRoute = key
    PM.Send('pm:map:route', { waypoint = wp, route = wp and { len = total, found = GetGpsBlipRouteFound(), pts = {} } or nil })
end

local function feed(my)
    local nextMove, nextBlips, nextRoute, nextZone = 0, 0, 0, 0
    while active and token == my do
        local now = GetGameTimer()
        local c = pushPlayer()
        -- Only the places screen shows the blips: elsewhere the sweeps wait, and run on its first tick.
        local blips = PM.Map.BlipsShown()
        if not blips then
            nextMove, nextBlips = 0, 0
        elseif now >= nextMove then
            nextMove = now + MOVE_MS
            PM.Map.PushMoving()
        end
        -- Right after a click the game is still plotting: check every tick for a while.
        if now >= nextRoute or now < routeUntil then
            nextRoute = now + ROUTE_MS
            pushRoute(false)
        end
        if now >= nextZone then
            nextZone = now + ZONE_MS
            pushZone(c)
        end
        if blips and (now >= nextBlips or PM.Map.BlipsUnsent()) then
            nextBlips = now + BLIP_MS
            PM.Map.PushBlips()
        end
        Wait(PLAYER_MS)
    end
end

PM.OnOpen(function()
    PM.Send('pm:map:config', config())
end)

PM.OnScreen(function(screen)
    local on = screen == 'map' or screen == 'pause'
    if on == active then return end
    active = on
    if not on then return end
    token = token + 1
    lastRoute, lastZone = nil, nil
    lastX, lastY, lastH, lastVeh = nil, nil, nil, nil -- each start sends the player once (the page centres on it)
    local my = token
    CreateThread(function() feed(my) end)
end)

PM.Callback('pm:map:setWaypoint', function(data)
    local x, y = PMMap.point(data.x, data.y)
    if not x then return { ok = false, error = 'validation' } end
    SetNewWaypoint(x, y)
    PlaySoundFrontend(-1, 'WAYPOINT_SET', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    lastRoute, routeUntil = nil, GetGameTimer() + 3000
    return { ok = true }
end)

PM.Callback('pm:map:clearWaypoint', function()
    if IsWaypointActive() then SetWaypointOff() end
    lastRoute, routeUntil = nil, GetGameTimer() + 1000
    return { ok = true }
end)

-- Zone and street under a map point. Height from the heightmap bottom: the top can be a roof or a bridge (E verifier).
PM.Callback('pm:map:probe', function(data)
    local x, y = PMMap.point(data.x, data.y)
    if not x then return { ok = false, error = 'validation' } end
    local now = GetGameTimer()
    if now - lastProbe < 100 then return { ok = false, error = 'rate_limited' } end
    lastProbe = now
    local z = GetHeightmapBottomZForPosition(x, y)
    local street, cross = streetAt(x, y, z)
    return { ok = true, data = { zone = zoneAt(x, y, z), street = street, cross = cross } }
end)

-- The full map: GTA's own, and the places screen again when it closes.
PM.Callback('pm:map:frontend', function(data)
    local back = data.back == 'pause' and 'pause' or 'map' -- the screen it was opened from comes back after
    PM.Debug('full map: GTA frontend, back to %s', back)
    return { ok = PM.OpenFrontend('FE_MENU_VERSION_MP_PAUSE', true, back) }
end)
