local Utils = require "modules.utils.client"
local lib = lib

-- Constants
local JOB_KEY = "plane_drug_delivery"
local config = lib.load(("escrow.jobs.%s.config"):format(JOB_KEY))

local job = {}

local state = {
    blips = {},
    planeSpawnPoint = nil,
    loadingZonePoint = nil,
    returnPoint = nil,
    dropPoints = {},
    planeNetId = nil,
    packagesLoaded = 0,
    dropPointsCompleted = 0,
    carryingBox = nil,
    dropCheckThreadRunning = false,
    deliveredDropPoints = {}, -- Track delivered drop points by index
    packageBoxNetIds = {},    -- Track spawned package boxes
    packageBoxSpawnPoint = nil,
}

local BOX_PROP_MODEL = 'prop_mp_drug_package'
local PACKAGE_SMOKE_PTFX_ASSET = 'core'
local PACKAGE_SMOKE_PTFX_NAME = 'exp_grd_flare'

-- Helper functions

local function addBlipRadius(center, radius, color)
    local blip = AddBlipForRadius(center.x, center.y, center.z, radius)
    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, color or 5)
    SetBlipAlpha(blip, 32)
    SetBlipAsShortRange(blip, true)
    return blip
end

local function createBlips()
    local planeSpawn = client.currentJob.game.area.plane_spawn
    local loadingZone = client.currentJob.game.area.loading_zone
    local dropPoints = client.currentJob.game.area.drop_points

    -- Plane spawn blip
    state.blips["plane_spawn"] = Utils.addBlip(
        vector3(planeSpawn.x, planeSpawn.y, planeSpawn.z),
        config.blips.plane,
        true, true
    )

    -- Loading zone blip
    state.blips["loading_zone"] = Utils.addBlip(
        loadingZone,
        config.blips.loading_zone, false, true
    )

    -- Drop point blips
    for i, dropPoint in ipairs(dropPoints) do
        local blip = Utils.addBlip(dropPoint.coords, config.blips.drop_point, false, true)
        state.blips["drop_" .. i] = blip
    end
end

local function removeBlip(blipKey)
    if state.blips[blipKey] then
        RemoveBlip(state.blips[blipKey])
        state.blips[blipKey] = nil
    end
end

-- Spawn plane (only for lobby owner)
local function spawnPlane()
    local planeModel = config.game.plane_model
    local planeSpawn = client.currentJob.game.area.plane_spawn

    lib.requestModel(planeModel)

    local plane = CreateVehicle(
        GetHashKey(planeModel),
        planeSpawn.x, planeSpawn.y, planeSpawn.z, planeSpawn.w,
        true, true
    )

    while not DoesEntityExist(plane) do Wait(0) end

    SetEntityCoords(plane, planeSpawn.x, planeSpawn.y, planeSpawn.z, false, false, false, true)
    SetEntityHeading(plane, planeSpawn.w)

    local planeNetId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(plane) then
            NetworkRegisterEntityAsNetworked(plane)
        else
            local netId = VehToNet(plane)
            if NetworkDoesNetworkIdExist(netId) then
                return netId
            end
        end
    end, false, false)

    SetModelAsNoLongerNeeded(planeModel)

    -- Give vehicle keys
    Jobs.giveVehicleKey(GetVehicleNumberPlateText(plane), plane)

    TriggerServerEvent(_e("server:jobs:plane_drug_delivery:onPlaneSpawned"), client.lobby.id, planeNetId)
end

-- Spawn package boxes at loading zone (only for lobby owner)
local function spawnPackageBoxes()
    local loadingZone = client.currentJob.game.area.loading_zone
    local boxCount = client.currentJob.steps[2].progress.target
    local boxes = {}

    lib.requestModel(BOX_PROP_MODEL)

    -- Pyramid layout for 20 boxes (4-layer pyramid):
    -- Bottom layer: 3x3 = 9 boxes (z=0.0)
    -- Middle layer: 3x2 = 6 boxes (z=0.5)
    -- Upper layer: 2x2 = 4 boxes (z=1.0)
    -- Top: 1 box (z=1.5)
    -- First box is at exact loading zone coordinates (0, 0, 0)
    local pyramidLayout = {
        -- Bottom layer (9 boxes) - 3x3, first box at origin
        { x = 0.0, y = 0.0, z = 0.0 }, { x = 0.5, y = 0.0, z = 0.0 }, { x = 1.0, y = 0.0, z = 0.0 },
        { x = 0.0, y = 0.5, z = 0.0 }, { x = 0.5, y = 0.5, z = 0.0 }, { x = 1.0, y = 0.5, z = 0.0 },
        { x = 0.0, y = 1.0,  z = 0.0 }, { x = 0.5, y = 1.0, z = 0.0 }, { x = 1.0, y = 1.0, z = 0.0 },

        -- Middle layer (6 boxes) - 3x2
        { x = 0.0, y = 0.25, z = 0.3 }, { x = 0.5, y = 0.25, z = 0.3 }, { x = 1.0, y = 0.25, z = 0.3 },
        { x = 0.0,  y = 0.75, z = 0.3 }, { x = 0.5, y = 0.75, z = 0.3 }, { x = 1.0, y = 0.75, z = 0.3 },

        -- Upper layer (4 boxes) - 2x2
        { x = 0.25, y = 0.25, z = 0.6 }, { x = 0.75, y = 0.25, z = 0.6 },
        { x = 0.25, y = 0.75, z = 0.6 }, { x = 0.75, y = 0.75, z = 0.6 },

        -- Top (1 box)
        { x = 0.5,  y = 0.5,  z = 0.85 },
    }

    -- Spawn in reverse order so top boxes are removed first
    for i = math.min(boxCount, #pyramidLayout), 1, -1 do
        local offset = pyramidLayout[i]

        local boxCoords = vector3(
            loadingZone.x + offset.x,
            loadingZone.y + offset.y,
            loadingZone.z + offset.z
        )

        local boxObj = CreateObject(GetHashKey(BOX_PROP_MODEL),
            boxCoords.x, boxCoords.y, boxCoords.z,
            true, true, false)

        while not DoesEntityExist(boxObj) do Wait(0) end

        FreezeEntityPosition(boxObj, true)

        -- Network the box
        local boxNetId = lib.waitFor(function()
            if not NetworkGetEntityIsNetworked(boxObj) then
                NetworkRegisterEntityAsNetworked(boxObj)
            else
                local netId = ObjToNet(boxObj)
                if NetworkDoesNetworkIdExist(netId) then
                    return netId
                end
            end
        end, false, false)

        table.insert(boxes, boxNetId)
    end

    SetModelAsNoLongerNeeded(BOX_PROP_MODEL)

    -- Send networkIds to server
    TriggerServerEvent(_e("server:jobs:plane_drug_delivery:onPackageBoxesSpawned"), client.lobby.id, boxes)
end

-- Set waypoint to next sequential drop point (uses state.deliveredDropPoints)
local function setWaypointToNextDropPoint()
    -- Find the first undelivered drop point (sequential order)
    for i, dropPoint in ipairs(client.currentJob.game.area.drop_points) do
        if not state.deliveredDropPoints[i] then
            SetNewWaypoint(dropPoint.coords.x, dropPoint.coords.y)
            return true
        end
    end
    return false
end

-- Thread to check for drop point proximity and draw markers
local function startDropCheckThread()
    if state.dropCheckThreadRunning then return end
    state.dropCheckThreadRunning = true

    CreateThread(function()
        while state.dropCheckThreadRunning and client.currentJob do
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)

            if not client.currentJob then break end

            -- Draw markers for all undelivered drop points
            for i, dropPoint in ipairs(client.currentJob.game.area.drop_points) do
                if not state.deliveredDropPoints[i] then
                    local dropCoords = dropPoint.coords
                    DrawMarker(
                        7,                -- Marker type (inverted cone)
                        dropCoords.x, dropCoords.y, dropCoords.z,
                        0.0, 0.0, 0.0,    -- Direction
                        0.0, 0.0, 0.0,    -- Rotation
                        15.0, 15.0, 15.0, -- Scale (minimalist)
                        255, 0, 0, 40,    -- RGBA (red, semi-transparent)
                        false, true, 2, false, nil, nil, false
                    )
                end
            end

            -- Check if player is in the plane
            if vehicle ~= 0 and state.planeNetId then
                local planeEntity = NetToVeh(state.planeNetId)
                if DoesEntityExist(planeEntity) and vehicle == planeEntity then
                    local planeCoords = GetEntityCoords(vehicle)
                    local altitude = planeCoords.z

                    -- Check each drop point
                    for i, dropPoint in ipairs(client.currentJob.game.area.drop_points) do
                        if not state.deliveredDropPoints[i] then
                            local dropCoords = dropPoint.coords
                            local horizontalDist = #(vector2(planeCoords.x, planeCoords.y) - vector2(dropCoords.x, dropCoords.y))
                            local altitudeDiff = math.abs(altitude - dropCoords.z)

                            -- Check if within drop radius and altitude range
                            if horizontalDist <= config.game.drop_radius and
                                altitude >= config.game.drop_altitude_min and
                                altitude <= config.game.drop_altitude_max and
                                altitudeDiff <= 100.0 then
                                -- Attempt delivery
                                local success = lib.callback.await(_e('server:jobs:plane_drug_delivery:deliverPackage'),
                                    false, client.lobby.id, i)

                                if success then
                                    -- Note: Delivery is now handled by server event 'onPackageDelivered'
                                    -- which will sync to all clients and set the new waypoint
                                    -- This local handling is kept for visual effects only

                                    -- Spawn and drop package
                                    local packageCoords = vector3(planeCoords.x, planeCoords.y, planeCoords.z - 2.0)
                                    lib.requestModel(BOX_PROP_MODEL)
                                    local packageObj = CreateObject(GetHashKey(BOX_PROP_MODEL),
                                        packageCoords.x, packageCoords.y, packageCoords.z, false, false, false)

                                    lib.requestNamedPtfxAsset(PACKAGE_SMOKE_PTFX_ASSET)
                                    UseParticleFxAssetNextCall(PACKAGE_SMOKE_PTFX_ASSET)
                                    local packageSmoke = StartParticleFxLoopedOnEntity(
                                        PACKAGE_SMOKE_PTFX_NAME,
                                        packageObj,
                                        0.0, 0.0, 0.0,
                                        0.0, 0.0, 0.0,
                                        0.8,
                                        false, false, false
                                    )
                                    SetParticleFxLoopedColour(packageSmoke, 1.0, 0.0, 0.0, false)

                                    SetEntityVelocity(packageObj, 0.0, 0.0, -5.0)

                                    -- Delete package after 5 seconds
                                    SetTimeout(5000, function()
                                        if packageSmoke then
                                            StopParticleFxLooped(packageSmoke, false)
                                        end
                                        if DoesEntityExist(packageObj) then
                                            DeleteEntity(packageObj)
                                        end
                                    end)

                                    Utils.notify(locale('plane_drug_delivery.package_dropped'), 'success')

                                    Wait(2000) -- Cooldown between drops
                                end
                            end
                        end
                    end
                end
            end
            Wait(0)
        end
    end)
end

-- Job lifecycle functions

function job.start()
    createBlips()
    job.onStepStart(1)

    return true
end

function job.stop()
    job.cleanup()

    return true
end

function job.cleanup()
    -- Stop threads
    state.dropCheckThreadRunning = false

    -- Remove all blips
    for _, blip in pairs(state.blips) do
        if blip then RemoveBlip(blip) end
    end
    state.blips = {}

    -- Remove points
    if state.planeSpawnPoint then
        state.planeSpawnPoint:remove()
        state.planeSpawnPoint = nil
    end

    if state.packageBoxSpawnPoint then
        state.packageBoxSpawnPoint:remove()
        state.packageBoxSpawnPoint = nil
    end

    if state.loadingZonePoint then
        state.loadingZonePoint:remove()
        state.loadingZonePoint = nil
    end

    if state.returnPoint then
        state.returnPoint:remove()
        state.returnPoint = nil
    end

    for _, point in pairs(state.dropPoints) do
        if point then point:remove() end
    end
    state.dropPoints = {}

    -- Delete carrying box if exists
    if state.carryingBox then
        local ped = PlayerPedId()
        ClearPedTasks(ped)
        DeleteEntity(state.carryingBox)
        state.carryingBox = nil
    end

    -- Reset state
    state.planeNetId = nil
    state.packagesLoaded = 0
    state.dropPointsCompleted = 0
    state.deliveredDropPoints = {}
    state.packageBoxNetIds = {}
end

function job.onStepStart(stepIndex)
    if stepIndex == 1 then
        -- Step 1: Get to the airfield and take a plane
        local planeSpawn = client.currentJob.game.area.plane_spawn
        SetNewWaypoint(planeSpawn.x, planeSpawn.y)

        -- Create plane spawn point (only for lobby owner)
        if client.lobby.owner == cache.serverId then
            state.planeSpawnPoint = lib.points.new({
                coords = vector3(planeSpawn.x, planeSpawn.y, planeSpawn.z),
                distance = 50.0,
                onEnter = function()
                    if not state.planeNetId then
                        spawnPlane()
                    end
                end
            })
        end
        return true
    elseif stepIndex == 2 then
        -- Step 2: Load drug packages onto the plane
        local loadingZone = client.currentJob.game.area.loading_zone
        SetNewWaypoint(loadingZone.x, loadingZone.y)

        -- Spawn package boxes (only for lobby owner)
        if client.lobby.owner == cache.serverId then
            state.packageBoxSpawnPoint = lib.points.new({
                coords = loadingZone,
                distance = 50.0,
                onEnter = function(self)
                    if #state.packageBoxNetIds == 0 then
                        spawnPackageBoxes()
                    end
                    self:remove()
                    state.packageBoxSpawnPoint = nil
                end
            })
        end

        -- Thread for picking up boxes from spawned entities
        CreateThread(function()
            local textui = false
            local highestBox = nil

            while client.currentJob and not client.currentJob.steps[2].done do
                local wait = 1000

                if not state.carryingBox then
                    local ped = PlayerPedId()
                    local pedCoords = GetEntityCoords(ped)
                    local loadingZone = client.currentJob.game.area.loading_zone
                    local loadingRadius = client.currentJob.game.area.loading_radius
                    local distToLoadingZone = #(pedCoords - loadingZone)

                    highestBox = nil

                    -- Only allow pickup if player is in loading zone
                    if distToLoadingZone <= loadingRadius then
                        local highestZ = -9999.0

                        -- Find the highest box (top of pyramid)
                        for i, boxNetId in ipairs(state.packageBoxNetIds) do
                            if NetworkDoesEntityExistWithNetworkId(boxNetId) then
                                local boxEntity = NetToObj(boxNetId)
                                if DoesEntityExist(boxEntity) then
                                    local boxCoords = GetEntityCoords(boxEntity)

                                    -- Pick the highest box
                                    if boxCoords.z > highestZ then
                                        highestZ = boxCoords.z
                                        highestBox = {
                                            entity = boxEntity,
                                            netId = boxNetId,
                                            index = i,
                                            coords =
                                                boxCoords
                                        }
                                    end
                                end
                            end
                        end
                    end

                    if highestBox then
                        wait = 0

                        DrawMarker(
                            28,                                                                  -- Marker type (cylinder)
                            highestBox.coords.x, highestBox.coords.y, highestBox.coords.z + 0.5, -- Slightly above the box
                            0.0, 0.0, 0.0,                                                       -- Direction
                            0.0, 0.0, 0.0,                                                       -- Rotation
                            .1, .1, .1,                                                          -- Scale
                            255, 255, 255, 255,                                                  -- RGBA (white, semi-transparent)
                            false, true, 2, false, nil, nil, false
                        )

                        if not textui then
                            textui = true
                            Utils.showTextUI(locale('plane_drug_delivery.pick_up_package'))
                        end

                        if IsControlJustPressed(0, 38) then -- E key
                            -- Remove from local state first
                            for i, boxNetId in ipairs(state.packageBoxNetIds) do
                                if boxNetId == highestBox.netId then
                                    table.remove(state.packageBoxNetIds, i)
                                    break
                                end
                            end

                            -- Notify server to delete this box
                            TriggerServerEvent(_e("server:jobs:plane_drug_delivery:pickUpPackageBox"), client.lobby.id,
                                highestBox.netId)

                            -- Spawn new box to attach to player (horizontal, two hands)
                            lib.requestModel(BOX_PROP_MODEL)
                            local carriedBox = CreateObject(GetHashKey(BOX_PROP_MODEL), 0, 0, 0, true, true, true)

                            -- Attach to player - horizontal position for two-handed carry
                            AttachEntityToEntity(carriedBox, ped, GetPedBoneIndex(ped, 60309),
                                0.15, 0.0, 0.2,  -- Position: slightly forward, centered, at chest height
                                0.0, 90.0, 90.0, -- Rotation: horizontal (rotated 90 degrees)
                                true, true, false, true, 1, true)

                            -- Animation
                            lib.requestAnimDict('anim@heists@box_carry@')
                            TaskPlayAnim(ped, 'anim@heists@box_carry@', 'idle', 8.0, -8.0, -1, 49, 0, false, false, false)

                            state.carryingBox = carriedBox
                            Utils.hideTextUI()
                            textui = false
                            highestBox = nil
                        end
                    else
                        if textui then
                            textui = false
                            Utils.hideTextUI()
                        end
                    end
                else
                    wait = 500
                end

                Wait(wait)
            end

            if textui then
                Utils.hideTextUI()
            end
        end)

        -- Point for loading boxes into plane
        CreateThread(function()
            while client.currentJob and not client.currentJob.steps[2].done do
                Wait(0)

                if state.carryingBox and state.planeNetId then
                    local ped = PlayerPedId()
                    local pedCoords = GetEntityCoords(ped)
                    local planeEntity = NetToVeh(state.planeNetId)

                    if DoesEntityExist(planeEntity) then
                        local planeCoords = GetEntityCoords(planeEntity)
                        local dist = #(pedCoords - planeCoords)

                        if dist <= 5.0 then
                            Utils.showTextUI(locale('plane_drug_delivery.load_package'))

                            if IsControlJustPressed(0, 38) then -- E key
                                if not Utils.checkSkill(config.game.skillCheck, 'loading') then
                                    ClearPedTasks(ped)
                                    if state.carryingBox and DoesEntityExist(state.carryingBox) then
                                        DeleteEntity(state.carryingBox)
                                    end
                                    state.carryingBox = nil
                                    Utils.hideTextUI()
                                    Utils.notify(locale('plane_drug_delivery.loading_failed'), 'error')
                                    return
                                end

                                -- Progress bar
                                if Utils.progressBar({
                                        duration = 3000,
                                        label = 'Loading package...',
                                        useWhileDead = false,
                                        canCancel = true,
                                        disable = {
                                            move = true,
                                            car = true,
                                            combat = true,
                                        },
                                    }) then
                                    -- Delete box
                                    ClearPedTasks(ped)
                                    DeleteEntity(state.carryingBox)
                                    state.carryingBox = nil
                                    Utils.hideTextUI()

                                    -- Notify server
                                    lib.callback.await(_e('server:jobs:plane_drug_delivery:loadPackage'), false,
                                        client.lobby.id)
                                else
                                    ClearPedTasks(ped)
                                    if state.carryingBox and DoesEntityExist(state.carryingBox) then
                                        DeleteEntity(state.carryingBox)
                                    end
                                    state.carryingBox = nil
                                    Utils.hideTextUI()
                                    Utils.notify(locale('plane_drug_delivery.loading_cancelled'), 'error')
                                end
                            end
                        else
                            Utils.hideTextUI()
                        end
                    end
                else
                    Wait(500)
                end
            end
        end)

        return true
    elseif stepIndex == 3 then
        -- Step 3: Deliver packages to drop points (sequential order)

        setWaypointToNextDropPoint()
        startDropCheckThread()

        return true
    elseif stepIndex == 4 then
        -- Step 4: Return the plane to the airfield
        local returnPoint = client.currentJob.game.area.return_point
        SetNewWaypoint(returnPoint.x, returnPoint.y)

        -- Stop drop check thread
        state.dropCheckThreadRunning = false

        state.returnPoint = lib.points.new({
            coords = returnPoint,
            distance = client.currentJob.game.area.return_radius,
            onEnter = function()
                Utils.showTextUI(locale('plane_drug_delivery.return_plane'))
            end,
            onExit = function()
                Utils.hideTextUI()
            end,
            nearby = function()
                -- Check if player is in the plane
                local ped = PlayerPedId()
                local vehicle = GetVehiclePedIsIn(ped, false)

                if vehicle ~= 0 and state.planeNetId then
                    local planeEntity = NetToVeh(state.planeNetId)
                    if DoesEntityExist(planeEntity) and vehicle == planeEntity then
                        if IsControlJustPressed(0, 38) then -- E key
                            Utils.hideTextUI()
                            state.returnPoint:remove()
                            state.returnPoint = nil
                            lib.callback.await(_e('server:jobs:finishJob'), false, client.lobby.id)
                        end
                    end
                end
            end
        })

        return true
    end

    return false
end

function job.onStepDone(stepIndex)
    -- Cleanup for completed steps
    if stepIndex == 1 then
        if state.planeSpawnPoint then
            state.planeSpawnPoint:remove()
            state.planeSpawnPoint = nil
        end
    elseif stepIndex == 2 then
        if state.packageBoxSpawnPoint then
            state.packageBoxSpawnPoint:remove()
            state.packageBoxSpawnPoint = nil
        end
        removeBlip("loading_zone")

        -- Clean up any remaining package boxes when step is complete
        TriggerServerEvent(_e("server:jobs:plane_drug_delivery:cleanupPackageBoxes"), client.lobby.id)
        state.packageBoxNetIds = {}
    elseif stepIndex == 3 then
        state.dropCheckThreadRunning = false
    end

    return job.onStepStart(stepIndex + 1)
end

-- Network events

RegisterNetEvent(_e('client:jobs:plane_drug_delivery:onPlaneSpawned'), function(planeNetId)
    state.planeNetId = planeNetId

    -- Add plane blip for all players
    if NetworkDoesNetworkIdExist(planeNetId) then
        local plane = NetToVeh(planeNetId)
        if DoesEntityExist(plane) then
            Jobs.giveVehicleKey(GetVehicleNumberPlateText(plane), plane)
        end
    end
end)

RegisterNetEvent(_e('client:jobs:plane_drug_delivery:onPackageBoxesSpawned'), function(lobbyId, boxes)
    if not client.currentJob then return end
    state.packageBoxNetIds = boxes
end)

RegisterNetEvent(_e('client:jobs:plane_drug_delivery:onPackageBoxPickedUp'), function(boxNetId)
    -- Remove from local list
    for i, netId in ipairs(state.packageBoxNetIds) do
        if netId == boxNetId then
            table.remove(state.packageBoxNetIds, i)
            break
        end
    end
end)

RegisterNetEvent(_e('client:jobs:plane_drug_delivery:onPackageLoaded'), function()
    state.packagesLoaded = state.packagesLoaded + 1
end)

-- Server notification: package delivered (sync to all clients)
RegisterNetEvent(_e('client:jobs:plane_drug_delivery:onPackageDelivered'), function(dropPointIndex)
    -- Mark as delivered in local state
    state.deliveredDropPoints[dropPointIndex] = true
    state.dropPointsCompleted = state.dropPointsCompleted + 1

    -- Remove the blip
    removeBlip("drop_" .. dropPointIndex)

    -- Set waypoint to next sequential drop point (in order)
    if state.dropPointsCompleted < #client.currentJob.game.area.drop_points then
        setWaypointToNextDropPoint()
    end
end)

--[[ Register ]]
Jobs.register(JOB_KEY, job)
