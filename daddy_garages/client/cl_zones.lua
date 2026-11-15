-- Where the garages are for this player: the list (config + the server's extra ones), blips, the soft ring, the hint
-- and the key while standing in one (or a valet with target options), and jg's client events and export.
Zones = { list = {}, inside = nil }
local Z = Zones

-- Every garage, and the ones this player may use (job, gang and private ones only for their people).
function Z.all()
    return Core.garages(GlobalState['daddy_garages:extra'])
end

local function usable(garage)
    if garage.kind == 'job' then
        local job = Bridge.fw.job()
        return not garage.job or (job ~= nil and Core.contains(garage.job, job.name))
    end
    if garage.kind == 'gang' then
        local gang = Bridge.fw.gang()
        return not garage.gang or (gang ~= nil and Core.contains(garage.gang, gang.name))
    end
    if garage.kind == 'private' then return Core.contains(garage.owners, Bridge.fw.identifier()) end
    return true
end

-- Blips ------------------------------------------------------------------------------------------------------------------
local blips = {}

local function clearBlips()
    for _, blip in ipairs(blips) do RemoveBlip(blip) end
    blips = {}
end

local function drawBlips()
    clearBlips()
    if not Config.Blips.Show then return end
    for _, g in pairs(Z.list) do
        if g.blip then
            local style = Config.Blips[g.kind] or Config.Blips.public or {}
            local blip = AddBlipForCoord(g.coords.x, g.coords.y, g.coords.z)
            SetBlipSprite(blip, g.blip.sprite or style.sprite or 357)
            SetBlipColour(blip, g.blip.colour or style.colour or 0)
            SetBlipScale(blip, (g.blip.scale or style.scale or 0.6) + 0.0)
            SetBlipAsShortRange(blip, Config.Blips.ShortRange ~= false)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(g.label)
            EndTextCommandSetBlipName(blip)
            blips[#blips + 1] = blip
        end
    end
end

-- Targets (valets) are made near the player and removed far away.
local valets = {}

local function refresh()
    local list = {}
    for id, g in pairs(Z.all()) do
        if usable(g) then list[id] = g end
    end
    Z.list = list
    drawBlips()
    local targets = Bridge.targets()
    if targets then
        for id, handle in pairs(valets) do
            if not list[id] then targets.remove(handle) valets[id] = nil end
        end
    end
end

-- The list follows the server's extra garages and the player's job and gang.
AddStateBagChangeHandler('daddy_garages:extra', 'global', function() SetTimeout(0, refresh) end)
Bridge.fw.onChange(function() SetTimeout(500, refresh) end)
AddEventHandler('onClientResourceStart', function(name)
    if name == GetCurrentResourceName() then SetTimeout(1000, refresh) end
end)
AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    clearBlips()
    local targets = Bridge.targets()
    if targets then for _, handle in pairs(valets) do targets.remove(handle) end end
    if Showroom.active() then Showroom.stop(0) end
    SetNuiFocus(false, false)
    -- Scripts cache jg's exports until jg stops; this one stopping counts the same.
    TriggerEvent('onClientResourceStop', 'jg-advancedgarages')
end)

-- Standing in a garage ----------------------------------------------------------------------------------------------------
do
    local nearMarkers = {}

    -- What E does here: park the car you drive, or open the garage (impound lots only open).
    local function kindAt(garage)
        local veh = cache.vehicle
        if garage.kind ~= 'impound' and veh and GetPedInVehicleSeat(veh, -1) == cache.ped then return 'park' end
        return garage.kind == 'impound' and 'impound' or 'open'
    end

    local function act(garage, kind)
        if kind == 'park' then Garage.park(garage.id) else Garage.open(garage.id) end
    end

    -- A garage's reach is a box: 'distance' wide, Zone.Height tall (floors above and below stay out).
    local function inside(g, here)
        local half = g.distance * (Config.Zone.Scale or 1.0) * 0.5
        return math.abs(here.x - g.coords.x) <= half and math.abs(here.y - g.coords.y) <= half
            and math.abs(here.z - g.coords.z) <= Config.Zone.Height * 0.5
    end

    -- Every half second: the nearest garage in reach, the hint, and the valets near the player (target mode).
    CreateThread(function()
        local shown
        while true do
            local here = GetEntityCoords(cache.ped)
            local nearest, best = nil, math.huge
            local targets = Bridge.targets()
            local markers, showMarkers, markerDist, markerHeight = {}, Config.Markers.Show, Config.Markers.Distance, Config.Markers.Height
            for id, g in pairs(Z.list) do
                local dist = #(here - g.coords)
                if dist < best and inside(g, here) then nearest, best = g, dist end
                if showMarkers and g.markers and dist < markerDist and math.abs(here.z - g.coords.z) < markerHeight then
                    markers[#markers + 1] = g
                end
                if targets then
                    if dist < 60.0 and not valets[id] then
                        valets[id] = targets.add(g, { open = function() Garage.open(g.id) end, park = function() Garage.park(g.id) end })
                    elseif dist > 80.0 and valets[id] then
                        targets.remove(valets[id])
                        valets[id] = nil
                    end
                end
            end
            nearMarkers = markers
            Z.inside = nearest
            local kind = nearest and not targets and not Page.open and not Garage.busy and not Showroom.active() and kindAt(nearest) or nil
            local key = kind and (nearest.id .. kind) or nil
            if key ~= shown then
                shown = key
                Bridge.hint(kind, nearest)
            end
            Wait(500)
        end
    end)

    -- Each frame only while inside one: the key, and the soft ring of nearby garages.
    CreateThread(function()
        while true do
            local wait = 500
            if #nearMarkers > 0 then
                wait = 0
                for i = 1, #nearMarkers do
                    local g = nearMarkers[i]
                    DrawMarker(25, g.coords.x, g.coords.y, g.coords.z - 0.95, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.2, 2.2, 1.0, 255, 255, 255, 60, false, false, 2, false, nil, nil, false)
                end
            end
            local g = Z.inside
            if g and not Bridge.targets() and not Page.open and not Garage.busy and not Showroom.active() then
                wait = 0
                if IsControlJustPressed(0, Config.Interact.Key) then act(g, kindAt(g)) end
            end
            Wait(wait)
        end
    end)
end

-- jg-advancedgarages compatibility (client) -------------------------------------------------------------------------------
do
    local JG = 'jg-advancedgarages'

    -- A script opens a garage: a known one by id, or its own (a house) with a type and a spawn point.
    RegisterNetEvent(('%s:client:open-garage'):format(JG), function(garageId, vehicleType, spawn)
        if Z.list[tostring(garageId)] or not spawn then
            Garage.open(garageId)
        else
            Garage.open(garageId, { type = vehicleType or 'car', spawn = Core.plain(Core.vec4(spawn)) })
        end
    end)

    RegisterNetEvent(('%s:client:store-vehicle'):format(JG), function(garageId)
        Garage.park(garageId)
    end)

    -- exports['jg-advancedgarages']:getAvailableGarageLocations(): { name, label, type, coords }.
    local function locations()
        local out = {}
        for id, g in pairs(Z.list) do
            out[#out + 1] = { name = id, label = g.label, type = g.type, coords = g.coords }
        end
        return out
    end

    AddEventHandler(('__cfx_export_%s_getAvailableGarageLocations'):format(JG), function(setCB) setCB(locations) end)
    exports('getAvailableGarageLocations', locations)
end
