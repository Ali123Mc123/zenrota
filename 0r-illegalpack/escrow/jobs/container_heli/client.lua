local Utils = require "modules.utils.client"
local Target = require "modules.target.client"
local lib = lib

-- Constants

local JOB_KEY = "container_heli"
local config = lib.load(("escrow.jobs.%s.config"):format(JOB_KEY))

local job = {}

local state = {
    blips = {},
    heliSpawnPoint = nil,
    containerSpawnPoint = nil,
    heliNetIds = {},
    containerNetIds = {},
    attachedContainerIndex = nil,
    heliThreadRunning = false,
    temporaryContainers = {}, -- Track temporary containers created for attachment
    droppedContainers = {},   -- Track containers that were dropped at delivery (to delete on cleanup)
    containersDelivered = 0,
    totalContainers = 0,
    isDelivering = false,           -- Prevent multiple deliveries at once
    deliveredContainerIndices = {}, -- Track which container indices have been delivered
}

-- Helper function to set waypoint to delivery point
local function setWaypointToDelivery()
    local deliveryPoint = client.currentJob.game.area.delivery_point
    SetNewWaypoint(deliveryPoint.x, deliveryPoint.y)
end

-- Helper function to set waypoint to nearest available container
-- Uses container_positions from config instead of network entities to avoid crashes
local function setWaypointToNearestContainer(helicopterCoords)
    local nearestContainer = nil
    local nearestDistance = math.huge
    local containerPositions = client.currentJob.game.area.container_positions

    for i, containerCoords in pairs(containerPositions) do
        -- Skip if this container was already delivered
        if not state.deliveredContainerIndices[i] then
            local coords = vector3(containerCoords.x, containerCoords.y, containerCoords.z)
            local distance = #(helicopterCoords - coords)

            if distance < nearestDistance then
                nearestDistance = distance
                nearestContainer = coords
            end
        end
    end

    if nearestContainer then
        SetNewWaypoint(nearestContainer.x, nearestContainer.y)
    end

    return nearestContainer ~= nil
end

-- Helper function to find nearest available container to helicopter
local function findNearestAvailableContainer(helicopterCoords)
    local nearestContainer = nil
    local nearestIndex = nil
    local nearestDistance = math.huge
    local containersInDrawRange = {} -- Konteynerlar outline çizimi için

    -- Configurable thresholds
    local interactXYDistance = 50.0 -- Horizontal distance for interaction (E key)
    local interactZDistance = 30.0  -- Vertical distance for interaction (E key)
    local drawDistance = 150.0      -- Distance to draw outline

    for i, containerNetId in pairs(state.containerNetIds) do
        if NetworkDoesEntityExistWithNetworkId(containerNetId) then
            local containerEntity = NetToObj(containerNetId)
            if DoesEntityExist(containerEntity) and not IsEntityAttached(containerEntity) then
                -- Skip if already delivered
                if not state.deliveredContainerIndices[i] then
                    local containerCoords = GetEntityCoords(containerEntity)

                    -- Calculate horizontal (XY) distance
                    local dx = helicopterCoords.x - containerCoords.x
                    local dy = helicopterCoords.y - containerCoords.y
                    local xyDistance = math.sqrt(dx * dx + dy * dy)

                    -- Calculate vertical (Z) distance
                    local zDistance = math.abs(helicopterCoords.z - containerCoords.z)
                    local totalDistance = math.sqrt(dx * dx + dy * dy +
                    (helicopterCoords.z - containerCoords.z) * (helicopterCoords.z - containerCoords.z))

                    -- Check if within draw distance for outline
                    if totalDistance <= drawDistance then
                        table.insert(containersInDrawRange, { entity = containerEntity, index = i })
                    end

                    -- Check if within interaction thresholds for E key
                    if xyDistance <= interactXYDistance and zDistance <= interactZDistance then
                        local combinedDistance = xyDistance + (zDistance * 0.5)

                        if combinedDistance < nearestDistance then
                            nearestDistance = combinedDistance
                            nearestContainer = containerEntity
                            nearestIndex = i
                        end
                    end
                end
            end
        end
    end

    return nearestContainer, nearestIndex, containersInDrawRange
end

local function addBlipRadius(center, radius)
    local blip = AddBlipForRadius(center.x, center.y, center.z, radius)
    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, config.blips.area.color or 5)
    SetBlipAlpha(blip, 32)
    SetBlipAsShortRange(blip, true)
    return blip
end

local function createBlips()
    local heliSpawn = client.currentJob.game.area.heli_spawn
    local containerPositions = client.currentJob.game.area.container_positions
    local deliveryPoint = client.currentJob.game.area.delivery_point

    -- heli blip
    state.blips["heli"] = Utils.addBlip(vector3(heliSpawn.x, heliSpawn.y, heliSpawn.z), config.blips.heli, true)
    -- container blips
    for i, pos in pairs(containerPositions) do
        local blip = Utils.addBlip(vector3(pos.x, pos.y, pos.z), config.blips.container)
        state.blips["container_" .. i] = blip
    end
    -- delivery blip
    state.blips["delivery"] = Utils.addBlip(deliveryPoint, config.blips.delivery)
end

-- Client-side spawn function for helis
local function spawnHelis()
    local heliCount = math.min(2, #client.lobby.members)
    local heliModel = config.game.heli_model
    local heliSpawn = client.currentJob.game.area.heli_spawn
    local helis = {}

    lib.requestModel(heliModel)

    for i = 1, heliCount do
        local offsetX = (i - 1) * 15.0
        local spawnCoords = vector4(
            heliSpawn.x + offsetX,
            heliSpawn.y,
            heliSpawn.z,
            heliSpawn.w
        )

        local heli = CreateVehicle(GetHashKey(heliModel),
            spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w,
            true, true)
        while not DoesEntityExist(heli) do Wait(0) end

        SetEntityCoords(heli, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false, true)

        local heliNetId = lib.waitFor(function()
            if not NetworkGetEntityIsNetworked(heli) then
                NetworkRegisterEntityAsNetworked(heli)
            else
                local netId = VehToNet(heli)
                if NetworkDoesNetworkIdExist(netId) then
                    return netId
                end
            end
        end, false, false)

        -- Give vehicle keys
        Jobs.giveVehicleKey(GetVehicleNumberPlateText(heli), heli)
        helis[i] = heliNetId
    end
    SetModelAsNoLongerNeeded(heliModel)

    TriggerServerEvent(_e("server:jobs:container_heli:onHelisSpawned"), client.lobby.id, helis)
end

-- Client-side spawn function for containers
local function spawnContainers()
    local containerModel = config.game.container_model
    local containerPositions = client.currentJob.game.area.container_positions
    local containers = {}

    lib.requestModel(containerModel)

    for i = 1, #containerPositions do
        local containerCoords = containerPositions[i]
        if not containerCoords then
            break
        end

        local container = CreateObject(GetHashKey(containerModel), containerCoords.x, containerCoords.y,
            containerCoords.z, true, true, false)
        while not DoesEntityExist(container) do Wait(0) end

        SetEntityCoords(container, containerCoords.x, containerCoords.y, containerCoords.z, false, false, false, true)
        SetEntityHeading(container, containerCoords.w)
        SetEntityAsMissionEntity(container, true, true)
        FreezeEntityPosition(container, true)

        local netId = lib.waitFor(function()
            if not NetworkGetEntityIsNetworked(container) then
                NetworkRegisterEntityAsNetworked(container)
            else
                local netId = ObjToNet(container)
                if NetworkDoesNetworkIdExist(netId) then
                    return netId
                end
            end
        end, false, false)

        table.insert(containers, netId)
    end

    SetModelAsNoLongerNeeded(containerModel)

    -- Send networkIds to server
    TriggerServerEvent(_e("server:jobs:container_heli:onContainersSpawned"), client.lobby.id, containers)
end

-- Create spawn point that triggers when player gets close
local function createSpawnPoint()
    if client.lobby.owner ~= cache.serverId then return end

    local heliSpawn = client.currentJob.game.area.heli_spawn

    state.heliSpawnPoint = lib.points.new({
        coords = vector3(heliSpawn.x, heliSpawn.y, heliSpawn.z),
        distance = 100.0, -- 100 units
        onEnter = function(self)
            spawnHelis()
            self:remove()
            state.heliSpawnPoint = nil
        end,
    })

    state.containerSpawnPoint = lib.points.new({
        coords = vector3(heliSpawn.x, heliSpawn.y, heliSpawn.z),
        distance = 100.0, -- 100 units
        onEnter = function(self)
            spawnContainers()
            self:remove()
            state.containerSpawnPoint = nil
        end,
    })
end

function job.cleanup()
    if state.heliSpawnPoint then
        state.heliSpawnPoint:remove()
        state.heliSpawnPoint = nil
    end
    if state.containerSpawnPoint then
        state.containerSpawnPoint:remove()
        state.containerSpawnPoint = nil
    end
    if state.blips then
        for _, blip in pairs(state.blips) do
            RemoveBlip(blip)
        end
        state.blips = {}
    end

    state.containerNetIds = {}
    state.heliNetIds = {}
    state.heliThreadRunning = false
    state.attachedContainerIndex = nil
    state.isDelivering = false
    state.deliveredContainerIndices = {}

    -- Clean up temporary containers
    for _, tempContainerNetId in pairs(state.temporaryContainers) do
        if NetworkDoesEntityExistWithNetworkId(tempContainerNetId) then
            local tempEntity = NetToObj(tempContainerNetId)
            if DoesEntityExist(tempEntity) then
                DeleteEntity(tempEntity)
            end
        end
    end
    state.temporaryContainers = {}

    -- Clean up dropped containers
    for _, droppedContainerNetId in pairs(state.droppedContainers) do
        if NetworkDoesEntityExistWithNetworkId(droppedContainerNetId) then
            local droppedEntity = NetToObj(droppedContainerNetId)
            if DoesEntityExist(droppedEntity) then
                DeleteEntity(droppedEntity)
            end
        end
    end
    state.droppedContainers = {}
    state.containersDelivered = 0
    state.totalContainers = 0
end

function job.start()
    job.onStepStart(1)
    return true
end

function job.stop()
    job.cleanup()
    return true
end

-- Main helicopter thread for container attach/detach logic
local function usingHeliThread()
    if state.heliThreadRunning then return end

    state.heliThreadRunning = true

    Citizen.CreateThread(function()
        local outlineDrawn = {}
        local textui = false

        while client.currentJob and not client.currentJob.steps[2].done and state.heliThreadRunning do
            local wait = 1000

            if cache.vehicle then
                local vehicle = cache.vehicle
                local isJobHeli = false
                local heliNetId = nil

                -- Check if current vehicle is a job helicopter
                for _, netId in pairs(state.heliNetIds) do
                    if NetworkDoesEntityExistWithNetworkId(netId) then
                        local heliEntity = NetToVeh(netId)
                        if DoesEntityExist(heliEntity) and vehicle == heliEntity then
                            isJobHeli = true
                            heliNetId = netId
                            break
                        end
                    end
                end

                if isJobHeli then
                    local helicopterEntity = vehicle
                    local helicopterCoords = GetEntityCoords(helicopterEntity)
                    local deliveryPoint = client.currentJob.game.area.delivery_point
                    local deliveryRadius = client.currentJob.game.area.delivery_radius or 15.0

                    -- Check if a container is currently attached
                    local hasAttachedContainer = false
                    for i, tempContainerNetId in pairs(state.temporaryContainers) do
                        if tempContainerNetId and NetworkDoesEntityExistWithNetworkId(tempContainerNetId) then
                            local tempContainerEntity = NetToObj(tempContainerNetId)
                            if DoesEntityExist(tempContainerEntity) and IsEntityAttached(tempContainerEntity) then
                                hasAttachedContainer = true
                                state.attachedContainerIndex = i

                                -- Check if near delivery point
                                local distance = #(helicopterCoords - deliveryPoint)

                                if distance < deliveryRadius then
                                    wait = 0
                                    if not textui then
                                        textui = true
                                        Utils.showTextUI(locale("container_heli.detach_container"))
                                    end

                                    if IsControlJustPressed(0, 38) and not state.isDelivering then -- E key
                                        state.isDelivering = true
                                        Utils.hideTextUI()
                                        textui = false

                                        TriggerServerEvent(
                                            _e("server:jobs:container_heli:detachContainer"), {
                                                lobbyId = client.lobby.id,
                                                containerIndex = i,
                                            })

                                        -- Detach the container and place it on the ground, don't delete it
                                        if state.temporaryContainers[i] then
                                            local tempNetId = state.temporaryContainers[i]
                                            if NetworkDoesEntityExistWithNetworkId(tempNetId) then
                                                local tempEntity = NetToObj(tempNetId)
                                                if DoesEntityExist(tempEntity) then
                                                    DetachEntity(tempEntity, true, true)
                                                    -- Place on ground and unfreeze so it stays there
                                                    FreezeEntityPosition(tempEntity, false)
                                                    -- Track as dropped container for cleanup later
                                                    table.insert(state.droppedContainers, tempNetId)
                                                end
                                            end
                                            state.temporaryContainers[i] = nil
                                        end

                                        -- Mark this container as delivered
                                        state.deliveredContainerIndices[i] = true
                                        state.attachedContainerIndex = nil
                                        state.containersDelivered = state.containersDelivered + 1

                                        -- Update progress
                                        client.currentJob.steps[2].progress.current = state.containersDelivered

                                        Citizen.Wait(1000)
                                        state.isDelivering = false
                                    end
                                else
                                    if textui then
                                        textui = false
                                        Utils.hideTextUI()
                                    end
                                end
                                break
                            end
                        end
                    end

                    -- If no container attached, find nearest available container to attach
                    if not hasAttachedContainer then
                        local containerEntity, containerIndex, containersInDrawRange = findNearestAvailableContainer(
                        helicopterCoords)

                        -- Draw outlines for all containers in draw range
                        local currentDrawnContainers = {}
                        for _, containerData in ipairs(containersInDrawRange) do
                            local entity = containerData.entity
                            currentDrawnContainers[entity] = true
                            if not outlineDrawn[entity] then
                                outlineDrawn[entity] = true
                                SetEntityDrawOutline(entity, true)
                            end
                            wait = 0
                        end

                        -- Remove outlines from containers no longer in range
                        for entity, _ in pairs(outlineDrawn) do
                            if not currentDrawnContainers[entity] and DoesEntityExist(entity) then
                                SetEntityDrawOutline(entity, false)
                                outlineDrawn[entity] = nil
                            end
                        end

                        -- Check if nearest container is close enough for interaction
                        if containerEntity and containerIndex then
                            wait = 0

                            if not textui then
                                textui = true
                                Utils.showTextUI(locale("container_heli.attach_container"))
                            end

                            if IsControlJustPressed(0, 38) then -- E key
                                Utils.hideTextUI()
                                textui = false

                                TriggerServerEvent(
                                    _e("server:jobs:container_heli:attachContainer"), {
                                        lobbyId = client.lobby.id,
                                        containerIndex = containerIndex,
                                        heliNetId = heliNetId,
                                    })

                                Citizen.Wait(1000)
                            end
                        else
                            -- No container close enough for interaction, hide textui
                            if textui then
                                textui = false
                                Utils.hideTextUI()
                            end
                        end
                    end
                end
            else
                -- Not in vehicle, hide textui if shown
                if textui then
                    textui = false
                    Utils.hideTextUI()
                end
            end

            Citizen.Wait(wait)
        end

        -- Cleanup outlines when thread ends
        for entity, _ in pairs(outlineDrawn) do
            if DoesEntityExist(entity) then
                SetEntityDrawOutline(entity, false)
            end
        end

        state.heliThreadRunning = false
    end)
end

-- Create return point for helicopters after all containers delivered
local function createHeliReturnPoint()
    local heliSpawn = client.currentJob.game.area.heli_spawn
    local returnPoint = vector3(heliSpawn.x, heliSpawn.y, heliSpawn.z)
    local returnRadius = 30.0
    local outlineDistance = 150.0

    -- Add blip for return point
    if state.blips["delivery"] then
        RemoveBlip(state.blips["delivery"])
        state.blips["delivery"] = nil
    end

    -- Remove container blips
    for key, blip in pairs(state.blips) do
        if key:find("container_") then
            RemoveBlip(blip)
            state.blips[key] = nil
        end
    end

    state.blips["return"] = Utils.addBlip(returnPoint, {
        sprite = 43,
        color = 2,
        text = locale("container_heli.blips.return_heli")
    })

    -- Set waypoint to return point
    SetNewWaypoint(returnPoint.x, returnPoint.y)

    -- Spawn temporary ghost helicopter for visual reference
    local heliModel = config.game.heli_model
    lib.requestModel(heliModel)

    local ghostHeli = CreateVehicle(GetHashKey(heliModel),
        returnPoint.x, returnPoint.y, returnPoint.z, heliSpawn.w,
        false, false)

    while not DoesEntityExist(ghostHeli) do Wait(0) end

    -- Make it non-collidable and transparent
    SetEntityCollision(ghostHeli, false, false)
    SetEntityAlpha(ghostHeli, 100, false) -- Saydam yap
    SetEntityAsMissionEntity(ghostHeli, true, true)
    FreezeEntityPosition(ghostHeli, true)
    SetEntityInvincible(ghostHeli, true)
    SetVehicleDoorsLocked(ghostHeli, 2) -- Lock doors

    SetModelAsNoLongerNeeded(heliModel)

    -- Create detection zone for helicopter return with E key interaction and outline
    Citizen.CreateThread(function()
        local textui = false
        local playerReturned = false
        local outlineDrawn = false

        while client.currentJob and not client.currentJob.steps[3].done and not playerReturned do
            local wait = 1000

            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local playerCoords = GetEntityCoords(playerPed)
            local distanceToReturn = #(playerCoords - returnPoint)

            -- Draw outline when within 150 units
            if distanceToReturn < outlineDistance then
                wait = 0
                if not outlineDrawn and DoesEntityExist(ghostHeli) then
                    SetEntityDrawOutline(ghostHeli, true)
                    outlineDrawn = true
                end
            else
                if outlineDrawn and DoesEntityExist(ghostHeli) then
                    SetEntityDrawOutline(ghostHeli, false)
                    outlineDrawn = false
                end
            end

            -- Check if player is in a job helicopter
            if vehicle and vehicle ~= 0 then
                local isJobHeli = false
                for _, heliNetId in pairs(state.heliNetIds) do
                    if NetworkDoesEntityExistWithNetworkId(heliNetId) then
                        local heliEntity = NetToVeh(heliNetId)
                        if vehicle == heliEntity then
                            isJobHeli = true
                            break
                        end
                    end
                end

                if isJobHeli then
                    local vehicleCoords = GetEntityCoords(vehicle)
                    local distance = #(vehicleCoords - returnPoint)

                    if distance < returnRadius then
                        wait = 0
                        if not textui then
                            textui = true
                            Utils.showTextUI(locale("container_heli.return_heli"))
                        end

                        if IsControlJustPressed(0, 38) then -- E key
                            Utils.hideTextUI()
                            textui = false
                            playerReturned = true

                            -- Delete the helicopter locally
                            if DoesEntityExist(vehicle) then
                                DeleteEntity(vehicle)
                            end

                            -- Notify server that player returned heli
                            TriggerServerEvent(_e("server:jobs:container_heli:playerReturned"), {
                                lobbyId = client.lobby.id,
                                playerId = cache.serverId
                            })
                        end
                    else
                        if textui then
                            textui = false
                            Utils.hideTextUI()
                        end
                    end
                else
                    if textui then
                        textui = false
                        Utils.hideTextUI()
                    end
                end
            else
                if textui then
                    textui = false
                    Utils.hideTextUI()
                end
            end

            Citizen.Wait(wait)
        end

        -- Cleanup
        if textui then
            Utils.hideTextUI()
        end

        -- Remove outline and delete ghost heli
        if DoesEntityExist(ghostHeli) then
            SetEntityDrawOutline(ghostHeli, false)
            DeleteEntity(ghostHeli)
        end
    end)
end

function job.onStepStart(stepIndex)
    if stepIndex == 1 then
        createBlips()
        createSpawnPoint()
        return true
    elseif stepIndex == 2 then
        -- Start the heli thread for container management
        usingHeliThread()
        -- Set initial waypoint to nearest container at step start
        Citizen.CreateThread(function()
            -- Wait a moment for containers to be spawned
            Citizen.Wait(2000)
            if client.currentJob and state.containerNetIds and #state.containerNetIds > 0 then
                setWaypointToNearestContainer(vector3(0, 0, 0))
            end
        end)
        return true
    elseif stepIndex == 3 then
        Utils.notify(locale("container_heli.all_containers_delivered"), "success")
        Utils.triggerPoliceAlert("container_heli", locale("container_heli.label"))
        createHeliReturnPoint()
        return true
    elseif stepIndex == 4 then
        lib.callback.await(_e('server:jobs:finishJob'), false, client.lobby.id)
        return true
    end

    return false
end

function job.onStepDone(stepIndex)
    -- Server handles step completion, client just starts next step
    return job.onStepStart(stepIndex + 1)
end

-- Events

RegisterNetEvent(_e("client:jobs:container_heli:onHelisSpawned"), function(lobbyId, helis)
    if not client.currentJob then return end
    client.currentJob.game.helis = helis

    state.heliNetIds = helis
end)

RegisterNetEvent(_e("client:jobs:container_heli:onContainersSpawned"), function(lobbyId, containers)
    if not client.currentJob then return end
    client.currentJob.game.containers = containers

    state.containerNetIds = containers
    state.totalContainers = #containers

    -- Update step 2 progress target
    client.currentJob.steps[2].progress.target = state.totalContainers
end)

-- Server response: container attached
RegisterNetEvent(_e("client:jobs:container_heli:containerAttached"), function(params)
    local containerIndex = params.containerIndex
    local heliNetId = params.heliNetId

    if not client.currentJob then return end

    -- Create temporary container for attachment
    if NetworkDoesEntityExistWithNetworkId(heliNetId) and state.containerNetIds[containerIndex] then
        local heliEntity = NetToVeh(heliNetId)
        local originalContainerEntity = NetToObj(state.containerNetIds[containerIndex])

        if DoesEntityExist(heliEntity) and DoesEntityExist(originalContainerEntity) then
            -- Get original container position and rotation
            local originalCoords = GetEntityCoords(originalContainerEntity)
            local originalHeading = GetEntityHeading(originalContainerEntity)
            local containerModel = config.game.container_model

            -- Request model
            lib.requestModel(containerModel)

            -- Create temporary container at the same position
            local tempContainer = CreateObject(GetHashKey(containerModel),
                originalCoords.x, originalCoords.y, originalCoords.z,
                true, true, false)

            while not DoesEntityExist(tempContainer) do Wait(0) end

            SetEntityHeading(tempContainer, originalHeading)
            SetEntityAsMissionEntity(tempContainer, true, true)

            -- Network the temporary container
            local tempNetId = lib.waitFor(function()
                if not NetworkGetEntityIsNetworked(tempContainer) then
                    NetworkRegisterEntityAsNetworked(tempContainer)
                else
                    local netId = ObjToNet(tempContainer)
                    if NetworkDoesNetworkIdExist(netId) then
                        return netId
                    end
                end
            end, false, false)

            SetModelAsNoLongerNeeded(containerModel)

            -- Store temporary container netId
            state.temporaryContainers[containerIndex] = tempNetId

            -- Attach temporary container to helicopter
            AttachEntityToEntity(tempContainer, heliEntity,
                0, 0.0, -5.0, -2.5,
                0.0, 0.0, 0.0,
                false, false, false, false, 2, true)
            state.attachedContainerIndex = containerIndex

            -- Notify server about temporary container creation
            TriggerServerEvent(_e("server:jobs:container_heli:temporaryContainerCreated"), {
                lobbyId = client.lobby.id,
                containerIndex = containerIndex,
                tempNetId = tempNetId
            })

            -- Set waypoint to delivery point when container is attached
            setWaypointToDelivery()
        end
    end
end)

-- Server response: container detached (sync for other players)
RegisterNetEvent(_e("client:jobs:container_heli:containerDetached"), function(params)
    local containerIndex = params.containerIndex

    -- Mark this container as delivered for all clients
    state.deliveredContainerIndices[containerIndex] = true

    -- Set waypoint to nearest available container after delivery
    local playerPed = PlayerPedId()
    local heli = GetVehiclePedIsIn(playerPed, false)
    if heli and heli ~= 0 then
        local heliCoords = GetEntityCoords(heli)
        setWaypointToNearestContainer(heliCoords)
    else
        -- If not in heli, try to find any available container
        setWaypointToNearestContainer(vector3(0, 0, 0))
    end
end)

-- Server notification: step 2 completed
RegisterNetEvent(_e("client:jobs:container_heli:step2Complete"), function()
    if not client.currentJob then return end
    -- Server already called onStepDone, just start step 3
    job.onStepStart(3)
end)

--[[ Register ]]
Jobs.register(JOB_KEY, job)
