-- Elevators: a target at every stop opens the floor menu; the screen fades, the player rides, the floor loads, the screen comes back.
local L = Locales[Config.Locale] or Locales.en
local busy, held = false, false

local function t(key) return L[key] or Locales.en[key] or key end

-- Puts the ped on the stop (and tells FeloxAC it is our teleport).
local function place(ped, c)
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityVelocity(ped, 0.0, 0.0, 0.0)
    SetEntityCoords(ped, c.x, c.y, c.z, false, false, false, false)
    SetEntityHeading(ped, c.w)
end

-- True once there is ground just under the stop (the floor's collision is there, not only the map's around it).
local function grounded(c)
    local found, z = GetGroundZFor_3dCoord(c.x, c.y, c.z + 0.5, false)
    return found and c.z - z >= -0.5 and c.z - z < 2.0
end

-- Holds the player still until the floor (and its interior) is there under them, so nobody falls through the map.
local function land(c)
    local ped = cache.ped
    held = true
    FreezeEntityPosition(ped, true)
    place(ped, c)
    SetGameplayCamRelativeHeading(0.0)
    local stop = GetGameTimer() + Config.LandMs
    local interior = GetInteriorAtCoords(c.x, c.y, c.z)
    if interior ~= 0 then
        PinInteriorInMemory(interior)
        while not IsInteriorReady(interior) and GetGameTimer() < stop do Wait(0) end
    end
    while not (HasCollisionLoadedAroundEntity(ped) and grounded(c)) and GetGameTimer() < stop do
        RequestCollisionAtCoord(c.x, c.y, c.z)
        Wait(0)
    end
    place(ped, c) -- the floor may have come in under a ped that sank while it loaded
    if interior ~= 0 then UnpinInterior(interior) end
    FreezeEntityPosition(ped, false)
    held = false
end

-- After the fade: a ped that still drops through a floor that came in late is put back on the stop before it falls far
-- (a long fall killed it, and the dead woke up on the infirmary bed).
local function guard(c)
    local ped = cache.ped
    local stop = GetGameTimer() + (Config.GuardMs or 4000)
    while GetGameTimer() < stop do
        local at = GetEntityCoords(ped)
        -- falling, near the stop and already below its floor (walking down the stairs is not a fall)
        if c.z - at.z > 1.5 and #(vec2(at.x, at.y) - vec2(c.x, c.y)) < 4.0 and (IsPedFalling(ped) or GetEntityVelocity(ped).z < -3.0) then
            FreezeEntityPosition(ped, true)
            place(ped, c)
            local wait = GetGameTimer() + 2000
            while not grounded(c) and GetGameTimer() < wait do
                RequestCollisionAtCoord(c.x, c.y, c.z)
                Wait(0)
            end
            place(ped, c)
            FreezeEntityPosition(ped, false)
        end
        Wait(0)
    end
end

local function ride(floor)
    if busy then return end
    busy = true
    DoScreenFadeOut(Config.FadeMs)
    while not IsScreenFadedOut() do Wait(0) end
    local ok = pcall(land, floor.coords)
    if not ok and held then FreezeEntityPosition(cache.ped, false) held = false end
    Wait(Config.RideMs)
    if Config.Sound then PlaySoundFrontend(-1, Config.Sound.name, Config.Sound.set, true) end
    DoScreenFadeIn(Config.FadeMs)
    if ok then guard(floor.coords) end
    busy = false
end

local function openMenu(elevator, here)
    local options = {}
    for i, floor in ipairs(elevator.floors) do
        local current = i == here
        options[#options + 1] = {
            title = floor.label, description = current and t('here') or t('go'),
            icon = current and 'location-dot' or 'elevator', disabled = current,
            onSelect = function() CreateThread(function() ride(floor) end) end,
        }
    end
    lib.registerContext({ id = 'daddy_elevator', title = elevator.label or t('title'), options = options })
    lib.showContext('daddy_elevator')
end

local function canUse()
    return not busy and not IsPedInAnyVehicle(cache.ped, false) and not IsEntityDead(cache.ped)
end

for _, elevator in ipairs(Config.Elevators) do
    for i, floor in ipairs(elevator.floors) do
        local c = floor.coords
        exports.ox_target:addSphereZone({
            name = ('daddy_elevator:%s:%d'):format(elevator.id, i),
            coords = vec3(c.x, c.y, c.z), radius = Config.Radius,
            options = { {
                name = 'daddy_elevator', label = t('target'), icon = 'fa-solid fa-elevator', distance = 2.0,
                canInteract = canUse,
                onSelect = function() openMenu(elevator, i) end,
            } },
        })
    end
end

-- A ring on the floor shows where each stop is; it is drawn only for the stops near the player.
local marker = Config.Marker
if marker then
    local stops = {}
    for _, elevator in ipairs(Config.Elevators) do
        for _, floor in ipairs(elevator.floors) do stops[#stops + 1] = { at = vec3(floor.coords.x, floor.coords.y, floor.coords.z) } end
    end

    -- The floor under a stop (its coords are a standing player's, about a metre above it).
    local function floorOf(stop)
        if stop.floor then return stop.floor end
        local found, z = GetGroundZFor_3dCoord(stop.at.x, stop.at.y, stop.at.z + 0.3, false)
        if found and stop.at.z - z < 2.0 then stop.floor = z + 0.03 end
        return stop.floor or stop.at.z - 0.95
    end

    CreateThread(function()
        local c = marker.color
        while true do
            local me, near = GetEntityCoords(cache.ped), {}
            for _, stop in ipairs(stops) do
                if #(me - stop.at) <= marker.distance then near[#near + 1] = stop end
            end
            if #near == 0 or busy then
                Wait(1000)
            else
                local again = GetGameTimer() + 1000
                while GetGameTimer() < again do
                    for _, stop in ipairs(near) do
                        DrawMarker(25, stop.at.x, stop.at.y, floorOf(stop), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, marker.size, marker.size, 1.0,
                            c[1], c[2], c[3], c[4], false, false, 2, false, nil, nil, false)
                    end
                    Wait(0)
                end
            end
        end
    end)
end

-- A stop mid-ride never leaves the screen black or the player frozen.
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if held then FreezeEntityPosition(cache.ped, false) end
    if busy then DoScreenFadeIn(0) end
end)
