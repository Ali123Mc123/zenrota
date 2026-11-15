-- Transit on the client: clerks at the stops, the departure board, the ride and the arrival scene.
local cinematic = Config.Cinematic
local world = World.client()
Transit = { world = world }

local inBoard, boardCam = false, nil
local ride

-- Stops ------------------------------------------------------------------------------------------------

local function stops() return world.entities({ kind = 'transit_stop' }) end

-- A stop as the board shows it; the server checks the ride again.
local function boardStop(record, current)
    local s = record.settings or {}
    local configured = s.arrival ~= nil
    return {
        id = record.uid, label = record.label, icon = s.icon, routeCode = s.routeCode, category = s.category, description = s.description,
        image = s.image, durationMinutes = s.durationMinutes, distanceKm = s.distanceKm, price = s.price or 0, status = s.status or 'active',
        scenePreset = s.scenePreset, configured = configured, isCurrent = record.uid == current,
        available = configured and s.status ~= 'offline' and record.uid ~= current,
    }
end

-- The board ------------------------------------------------------------------------------------------

local function enterCam(ped)
    if not ped or not DoesEntityExist(ped) then return end
    local head = GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.0)
    local from = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.7, 0.0)
    local at = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 0.0)
    boardCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    pcall(function() exports['FeloxAC']:createCam(boardCam) end) --[[FeloxAC:auto]]
    SetCamCoord(boardCam, from.x, from.y, head.z)
    PointCamAtCoord(boardCam, at.x, at.y, head.z)
    SetCamFov(boardCam, 55.0)
    SetCamActive(boardCam, true)
    RenderScriptCams(true, true, Config.FadeMs, true, true)
end

local function exitCam()
    if not boardCam then return end
    RenderScriptCams(false, true, Config.FadeMs, true, true)
    local cam = boardCam
    boardCam = nil
    SetTimeout(Config.FadeMs, function() pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]] DestroyCam(cam, true) end)
end

local function openBoard(record)
    if inBoard or Nui.isOpen() then return end
    if IsPedInAnyVehicle(cache.ped, false) then return Nui.notify('transit.in_vehicle', 'error') end
    local list = {}
    for _, stop in ipairs(stops()) do
        -- a departure-only stop (settings.departOnly) is left off every other board
        if not (stop.settings or {}).departOnly or stop.uid == record.uid then list[#list + 1] = boardStop(stop, record.uid) end
    end
    table.sort(list, function(a, b) return a.label < b.label end)
    inBoard = true
    local status = lib.callback.await('daddy_transit:board', false) or {}
    FreezeEntityPosition(cache.ped, true)
    enterCam(world.anchors.entity('transit:' .. record.uid))
    Nui.open('transit.board', { currentStopId = record.uid, currentStopLabel = record.label, stops = list, scene = cinematic.Enabled,
        driverOnDuty = status.driverOnDuty == true })
end

Nui.onClose('transit.board', function()
    if not inBoard then return end
    inBoard = false
    FreezeEntityPosition(cache.ped, false)
    exitCam()
end)

-- Every active stop gets its clerk with the ride option.
world.subscribe(function()
    local defs = {}
    for _, record in ipairs(stops()) do
        if (record.settings.status or 'active') ~= 'offline' then
            local uid = 'transit:' .. record.uid
            defs[#defs + 1] = {
                uid = uid, label = record.label, coords = record.coords, revision = record.revision, presentation = 'ped',
                model = record.model, scenario = record.scenario, distance = 2.0,
                options = { {
                    name = 'transit_ride', label = DL.locale.t('transit.target_ride'), icon = 'fa-solid fa-bus', distance = 2.0,
                    canInteract = function() return not inBoard and not Nui.isOpen() and not IsPedInAnyVehicle(cache.ped, false) end,
                    onSelect = function() CreateThread(function() openBoard(record) end) end,
                } },
            }
        end
    end
    world.anchors.sync('transit', defs)
    if inBoard then Nui.close() end
end)

-- The ride ---------------------------------------------------------------------------------------------

local function teleport(destination)
    local a = DL.geo.vec(destination and destination.arrival)
    if not a then return false end
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(cache.ped, a.x, a.y, a.z, false, false, false, true)
    SetEntityHeading(cache.ped, a.w or 0.0)
    return true
end

local function awaitCollision(destination)
    local a = DL.geo.vec(destination.arrival)
    local timeout = GetGameTimer() + 4000
    RequestCollisionAtCoord(a.x, a.y, a.z)
    while not HasCollisionLoadedAroundEntity(cache.ped) and GetGameTimer() < timeout do Wait(50) end
end

local function fadeRide(destination)
    DoScreenFadeOut(Config.FadeMs)
    while not IsScreenFadedOut() do Wait(0) end
    if not teleport(destination) then
        DoScreenFadeIn(Config.FadeMs)
        return Nui.notify('transit.unavailable', 'error')
    end
    awaitCollision(destination)
    Wait(250)
    DoScreenFadeIn(Config.FadeMs)
    Nui.notify('transit.arrived', 'inform', destination.label)
end

-- The scene's own end is counted from when it starts drawing, so a slow load never cuts it short.
local function armFailsafe()
    local token = {}
    ride.failsafe = token
    SetTimeout(cinematic.FailsafeMs, function()
        if ride and ride.failsafe == token and ride.done then
            Nui.send('transit:collisionReady')
            ride.done:resolve(false)
            ride.done = nil
        end
    end)
end

RegisterNUICallback('transit:cinematicReady', function(_, cb)
    cb({ ok = true })
    if not ride then return end
    if ride.ready then
        ride.ready:resolve(true)
        ride.ready = nil
    end
    armFailsafe()
end)

RegisterNUICallback('transit:cinematicDone', function(_, cb)
    cb({ ok = true })
    if ride and ride.done then
        ride.done:resolve(true)
        ride.done = nil
    end
end)

Nui.onClose('transit.cinematic', function()
    if not ride then return end
    if ride.ready then ride.ready:resolve(false) end
    if ride.done then ride.done:resolve(false) end
    ride.ready, ride.done = nil, nil
end)

local function sceneRide(destination, scene)
    ride = { ready = promise.new(), done = promise.new() }
    FreezeEntityPosition(cache.ped, true)
    DoScreenFadeOut(250)
    while not IsScreenFadedOut() do Wait(0) end
    if not teleport(destination) then
        ride = nil
        FreezeEntityPosition(cache.ped, false)
        DoScreenFadeIn(Config.FadeMs)
        return Nui.notify('transit.unavailable', 'error')
    end
    local current, ready, done = ride, ride.ready, ride.done
    Nui.open('transit.cinematic', scene, false)
    CreateThread(function()
        awaitCollision(destination)
        Nui.send('transit:collisionReady')
    end)
    -- The scene is warmed up on the board; this only keeps the screen from staying black.
    SetTimeout(3200, function()
        if current.ready then
            current.ready:resolve(false)
            current.ready = nil
        end
    end)
    Citizen.Await(ready)
    DoScreenFadeIn(400)
    if not current.failsafe then armFailsafe() end
    Citizen.Await(done)
    ride = nil
    Nui.close()
    FreezeEntityPosition(cache.ped, false)
    Nui.notify('transit.arrived', 'inform', destination.label)
end

local REASONS = { not_rider = 'transit.not_rider', stop_riders = 'transit.stop_riders', driver_on_duty = 'transit.driver_on_duty', unavailable = 'transit.unavailable',
    too_far = 'transit.too_far', cooldown = 'transit.cooldown', no_money = 'transit.no_money' }

RegisterNUICallback('transit:quote', function(data, cb)
    data = type(data) == 'table' and data or {}
    cb(lib.callback.await('daddy_transit:quote', false, data.targetStopId) or { ok = false })
end)

RegisterNUICallback('transit:confirm', function(data, cb)
    data = type(data) == 'table' and data or {}
    local result = lib.callback.await('daddy_transit:ride', false, data.sourceStopId, data.targetStopId)
    if type(result) ~= 'table' or not result.ok then
        local reason = type(result) == 'table' and result.error or 'unavailable'
        cb({ ok = false, error = reason, message = DL.locale.t(REASONS[reason] or 'transit.unavailable') })
        return
    end
    cb({ ok = true })
    CreateThread(function()
        Wait(650) -- the ticket is stamped first
        Nui.close()
        if cinematic.Enabled then sceneRide(result.destination, result.cinematic) else fadeRide(result.destination) end
    end)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if boardCam then RenderScriptCams(false, false, 0, true, true) end
    FreezeEntityPosition(cache.ped, false)
end)
