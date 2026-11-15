-- /showroom [model ...]: a test of the hall's light and framing, not the dealership. The camera goes into the hall,
-- cars stand in the five bays at the hall's angle, the selected bay gets the script key and rim lights; left and
-- right walk the row, Backspace leaves. Off unless the convar daddy_showroom_preview is 1.
local FALLBACK = { 'comet2', 'zentorno', 'elegy2', 'adder', 'italigtb' }
local LIGHT = { 240, 244, 255 }
local active = false

local function at(x, y, z)
    return Hall.position + vector3(x, y, z)
end

-- The camera's place in front of a bay and the point it looks at (a few degrees down).
local function shot(bay)
    local c = Hall.camera
    local reach = Hall.bayLine - Hall.rail
    return at(bay, Hall.rail, c.height), at(bay, Hall.bayLine, c.height + reach * math.tan(math.rad(c.pitch)))
end

local function loadModel(name)
    local hash = joaat(name)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then return nil end
    RequestModel(hash)
    local stop = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < stop do Wait(0) end
    return HasModelLoaded(hash) and hash or nil
end

-- A local car standing on the hall floor in its bay, lights on, put into the hall's room.
local function spawn(hash, bay, interior, room)
    local min = GetModelDimensions(hash)
    local p = at(bay, Hall.bayLine, -min.z)
    pcall(function() exports['FeloxAC']:CreateVehicle(hash) end) --[[FeloxAC:auto]]
    local car = CreateVehicle(hash, p.x, p.y, p.z, Hall.carHeading + 0.0, false, false)
    FreezeEntityPosition(car, true)
    SetVehicleLights(car, 2)
    SetVehicleDirtLevel(car, 0.0)
    ForceRoomForEntity(car, interior, room)
    SetModelAsNoLongerNeeded(hash)
    return car
end

local function spot(from, to, distance, brightness, radius, shadow)
    local d = norm(to - from)
    if shadow then
        DrawSpotLightWithShadow(from.x, from.y, from.z, d.x, d.y, d.z, LIGHT[1], LIGHT[2], LIGHT[3], distance, brightness, 0.0, radius, 1.0, shadow)
    else
        DrawSpotLight(from.x, from.y, from.z, d.x, d.y, d.z, LIGHT[1], LIGHT[2], LIGHT[3], distance, brightness, 0.0, radius, 1.0)
    end
end

-- The selected bay: a key light from the front and two rims from behind; its neighbours get a low key only.
local function bayLights(bay)
    local back = Hall.size[2] / 2
    spot(at(bay, Hall.bayLine - 4.6, 5.2), at(bay, Hall.bayLine, 0.5), 12.0, 9.0, 30.0, 1)
    spot(at(bay - 2.4, back - 0.8, 5.0), at(bay, Hall.bayLine, 0.8), 10.0, 5.0, 24.0, 2)
    spot(at(bay + 2.4, back - 0.8, 5.0), at(bay, Hall.bayLine, 0.8), 10.0, 5.0, 24.0, 3)
    for _, side in ipairs({ -1, 1 }) do
        spot(at(bay + side * 6, Hall.bayLine - 4.6, 5.2), at(bay + side * 6, Hall.bayLine, 0.5), 12.0, 3.0, 30.0)
    end
end

local function smooth(t)
    return t * t * (3 - 2 * t)
end

RegisterCommand('showroom', function(_, args)
    if active or GetConvarInt('daddy_showroom_preview', 0) ~= 1 then return end
    active = true
    -- The interior (its proxy) is known before the hall streams in; without one the focus never goes there. The
    -- hall's ymap streams only near it: bring the focus there, then wait for the interior.
    local interior = GetInteriorAtCoords(Hall.position.x, Hall.position.y, Hall.position.z + 1.0)
    if interior == 0 then
        active = false
        return
    end
    local index = math.ceil(#Hall.bays / 2)
    local from, look = shot(Hall.bays[index])
    SetFocusPosAndVel(from.x, from.y, from.z, 0.0, 0.0, 0.0)
    local room, stop = joaat(Hall.room), GetGameTimer() + 8000
    PinInteriorInMemory(interior)
    while not IsInteriorReady(interior) and GetGameTimer() < stop do Wait(0) end

    local cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', from.x, from.y, from.z, 0.0, 0.0, 0.0, Hall.camera.fov + 0.0, false, 2)
    pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
    PointCamAtCoord(cam, look.x, look.y, look.z)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 600, true, false)
    if GetResourceState('wais-primehud') == 'started' then exports['wais-primehud']:showHud() end
    ForceRoomForGameViewport(interior, room)
    DisplayRadar(false)

    local names = #args > 0 and args or (IsModelInCdimage(joaat('pogt3rs')) and { 'mbagt', 'pogt4', 'pogt3rs', 'chc8', 'nsr35' } or FALLBACK)
    local cars = {}
    for i, bay in ipairs(Hall.bays) do
        local hash = loadModel(names[(i - 1) % #names + 1])
        if hash then cars[#cars + 1] = spawn(hash, bay, interior, room) end
    end

    local x, moveFrom, moveTo, moveStart = Hall.bays[index], nil, nil, 0
    while active do
        DisableAllControlActions(0)
        HideHudAndRadarThisFrame()
        local step = (IsDisabledControlJustPressed(0, 175) and 1) or (IsDisabledControlJustPressed(0, 174) and -1) or 0
        if step ~= 0 and Hall.bays[index + step] then
            index = index + step
            moveFrom, moveTo, moveStart = x, Hall.bays[index], GetGameTimer()
        end
        if moveTo then
            local t = math.min(1.0, (GetGameTimer() - moveStart) / 800)
            x = moveFrom + (moveTo - moveFrom) * smooth(t)
            if t >= 1.0 then moveTo = nil end
            local p, l = shot(x)
            SetCamCoord(cam, p.x, p.y, p.z)
            PointCamAtCoord(cam, l.x, l.y, l.z)
            SetFocusPosAndVel(p.x, p.y, p.z, 0.0, 0.0, 0.0)
        end
        bayLights(x)
        if IsDisabledControlJustPressed(0, 177) or IsDisabledControlJustPressed(0, 194) then active = false end
        Wait(0)
    end

    for _, car in ipairs(cars) do DeleteEntity(car) end
    RenderScriptCams(false, true, 500, true, false)
    if GetResourceState('wais-primehud') == 'started' then exports['wais-primehud']:hideHud() end
    pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]]
    DestroyCam(cam, false)
    ClearFocus()
    ClearRoomForGameViewport()
    UnpinInterior(interior)
    DisplayRadar(true)
end, false)
