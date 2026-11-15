local Utils = require 'modules.utils.client'
local Target = require 'modules.target.client'
local lib = lib

-- Constants

local JOB_KEY = 'gun_smuggling'
local config = lib.load(('escrow.jobs.%s.config'):format(JOB_KEY))

local job = {}

local state = {
    npc = nil,
    npcBlip = nil,
    truckBlip = nil,
    containerPoints = {},
    containerBlips = {},
    truckNetId = nil,
    trailerNetId = nil,
    forkliftNetId = nil,
    containerBoxZones = {},
    containerSceneObjects = {},
    fakeContainers = {},
    forkliftThread = false,
    crateCoords = {},
    attachedToForklift = nil,
    deliveryPoints = {},
    deliveryBlips = {},
    finishPoint = nil,
}

local ContainerAnimation <const> = {
    objects = { 'tr_prop_tr_grinder_01a', 'ch_p_m_bag_var02_arm_s' },
    names = { 'action', 'action_container', 'action_lock', 'action_angle_grinder', 'action_bag' }
}

local function deleteSpawnedNPC()
    if DoesEntityExist(state.npc) then
        DeleteEntity(state.npc)
    end
    if state.npcBlip then
        RemoveBlip(state.npcBlip)
    end
    state.npc = nil
    state.npcBlip = nil
end

local function createContactNpc()
    local model = config.game.npc_model
    local npcLocation = client.currentJob.game.location.npc_location
    lib.requestModel(model)

    local npcEntity = CreatePed(4, model, npcLocation.x, npcLocation.y, npcLocation.z, npcLocation.w or 0.0, false,
        false)
    while not DoesEntityExist(npcEntity) do
        Wait(0)
    end
    FreezeEntityPosition(npcEntity, true)
    SetPedDiesWhenInjured(npcEntity, false)
    SetEntityInvincible(npcEntity, true)
    TaskSetBlockingOfNonTemporaryEvents(npcEntity, true)
    SetBlockingOfNonTemporaryEvents(npcEntity, true)
    SetModelAsNoLongerNeeded(model)

    state.npc = npcEntity

    state.npcBlip = Utils.addBlip(npcEntity, config.blips.contact_npc, true)

    return true
end

local function addTargetToNpc()
    local npc = state.npc

    if not DoesEntityExist(npc) then
        return lib.print.warn('Debug: gun_smuggling contact npc not spawned!')
    end

    Target.addLocalEntity(npc, { {
        label = locale('gun_smuggling.spawn_truck'),
        icon = 'fa-solid fa-truck-front',
        distance = 2.0,
        canInteract = function()
            if not client.lobby then
                return false
            end
            if not client.currentJob then
                return false
            end
            local isOwner = client.lobby.owner == cache.serverId
            local isStepDone = client.currentJob.steps[1].done
            return isOwner and not isStepDone
        end,
        onSelect = function()
            job.spawnTruck()
            Target.removeLocalEntity(npc)
        end
    } })
end

local function spawnForklift(coords)
    local forkliftModel = config.game.forklift_model
    lib.requestModel(forkliftModel)

    local forklift = CreateVehicle(forkliftModel,
        coords.x, coords.y, coords.z, coords.w or 0.0,
        true, true)

    while not DoesEntityExist(forklift) do Wait(0) end

    local forkliftNetId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(forklift) then
            NetworkRegisterEntityAsNetworked(forklift)
        else
            local netId = VehToNet(forklift)
            if NetworkDoesNetworkIdExist(netId) then
                return netId
            end
        end
    end, false, false)

    SetModelAsNoLongerNeeded(forkliftModel)

    return forkliftNetId
end

local function createContainer(index, data, isDone)
    local containerModel = data.model
    lib.requestModel(containerModel)

    local containerEnt = CreateObject(containerModel, data.coords.x, data.coords.y, data.coords.z, true, true, false)
    while not DoesEntityExist(containerEnt) do
        Wait(0)
    end

    SetEntityRotation(containerEnt, 0.0, 0.0, data.coords.w or 0.0, 2, false)
    FreezeEntityPosition(containerEnt, true)
    PlaceObjectOnGroundProperly(containerEnt)
    SetModelAsNoLongerNeeded(containerModel)

    local containerNetId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(containerEnt) then
            NetworkRegisterEntityAsNetworked(containerEnt)
        else
            local netId = ObjToNet(containerEnt)
            if NetworkDoesNetworkIdExist(netId) then
                return netId
            end
        end
    end, false, false)

    lib.callback.await(_e('server:jobs:gun_smuggling:onContainerSpawned'), false,
        client.lobby.id, index, containerNetId, isDone)
end

local function spawnCrateObject(coords, attachTrail)
    local model = config.game.crate_model
    if attachTrail then
        model = config.game.crate_on_trail_model
    end
    lib.requestModel(model)
    local crate = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    while not DoesEntityExist(crate) do Wait(0) end
    SetEntityRotation(crate, 0.0, 0.0, coords.w or 0.0 - 90.0, 2, false)
    FreezeEntityPosition(crate, true)
    PlaceObjectOnGroundProperly(crate)
    SetModelAsNoLongerNeeded(model)

    local crateNetId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(crate) then
            NetworkRegisterEntityAsNetworked(crate)
        else
            local netId = ObjToNet(crate)
            if NetworkDoesNetworkIdExist(netId) then
                return netId
            end
        end
    end, false, false)

    return crateNetId, crate
end

local function addContainerBoxZone(index, data)
    local zoneKey = ('illegalpack.gun_smuggling.boxzone_%d'):format(index)
    Target.addBoxZone(zoneKey, {
        coords = vector3(data.coords.x, data.coords.y, data.coords.z + 1.5),
        rotation = data.coords.w or 0.0,
        name = zoneKey,
        size = vector3(3.0, 4.0, 3.0),
        debug = false,
        canInteract = function()
            return client.currentJob and client.currentJob.steps[2].done
        end,
        options = { {
            label = locale('gun_smuggling.force_open'),
            icon = 'fa-solid fa-box',
            distance = 1.5,
            onSelect = function()
                Target.removeZone(zoneKey)
                state.containerBoxZones[index] = nil
                if lib.callback.await(_e('server:jobs:gun_smuggling:canOpenContainer'), false, client.lobby.id, index) then
                    local crateNetId, _ = spawnCrateObject(data.coords)

                    lib.callback.await(_e('server:jobs:gun_smuggling:onCrateSpawned'), false,
                        client.lobby.id, index, crateNetId, data.coords)

                    job.openContainer(index, data)
                end
            end
        } }
    })
    state.containerBoxZones[index] = zoneKey
end

local function createContainerPoints()
    local location = client.currentJob.game.location
    local createdContainerCount = 0

    for index, container in pairs(location.containers) do
        state.containerBlips[index] = Utils.addBlip(container.coords, config.blips.container, true)
        if client.lobby.owner == cache.serverId then
            state.containerPoints[index] = lib.points.new({
                coords = container.coords,
                distance = 50.0,
                onEnter = function(self)
                    self:remove()
                    state.containerPoints[index] = nil
                    createdContainerCount = createdContainerCount + 1
                    createContainer(index, container, createdContainerCount == #location.containers)
                    if createdContainerCount == 1 then
                        local forkliftNetId = spawnForklift(location.forklift_location)
                        lib.callback.await(_e('server:jobs:gun_smuggling:onForkliftSpawned'),
                            false, client.lobby.id, forkliftNetId)

                        Utils.triggerPoliceAlert('gun_smuggling', locale("gun_smuggling"))
                    end
                end,
            })
        end
    end
end

local function startForkliftThread()
    if state.forkliftThread then return end
    state.forkliftThread = true
    Citizen.CreateThread(function()
        while state.forkliftThread do
            local wait = 500
            local vehicle = cache.vehicle
            if vehicle and cache.seat == -1 then
                local model = GetEntityModel(vehicle)
                if model == joaat(config.game.forklift_model) then
                    local vehicleFrontSide = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 1.5, 0.0)
                    if not state.attachedToForklift then
                        for crateIndex, coords in pairs(state.crateCoords) do
                            if coords then
                                local distance = #(vehicleFrontSide - vector3(coords))
                                if distance <= 2.5 then
                                    local closestCrate = GetClosestObjectOfType(
                                        vehicleFrontSide.x, vehicleFrontSide.y, vehicleFrontSide.z,
                                        2.5, config.game.crate_model, false, false, false)
                                    if DoesEntityExist(closestCrate) then
                                        state.crateCoords[crateIndex] = false
                                        local response = lib.callback.await(
                                            _e('server:jobs:gun_smuggling:onCrateAttachVehicle'),
                                            false, client.lobby.id, crateIndex, VehToNet(vehicle))
                                        if response then
                                            Utils.notify(locale('gun_smuggling.attached_forklift'), 'success')
                                            state.attachedToForklift = crateIndex
                                        end
                                        break
                                    end
                                end
                            end
                        end
                    else
                        local trailer = NetToVeh(state.trailerNetId)
                        if DoesEntityExist(trailer) then
                            local vehicleCoords  = GetEntityCoords(vehicle)

                            local minDim, maxDim = GetModelDimensions(GetEntityModel(trailer))
                            local trailerLength  = maxDim.y - minDim.y

                            local trailerFront   = GetOffsetFromEntityInWorldCoords(trailer, 0.0, trailerLength / 2, 0.0)
                            local trailerBack    = GetOffsetFromEntityInWorldCoords(trailer, 0.0, -trailerLength / 2, 0.0)
                            local trailerCenter  = GetEntityCoords(trailer)

                            local distFront      = #(vehicleCoords - trailerFront)
                            local distBack       = #(vehicleCoords - trailerBack)
                            local distCenter     = #(vehicleCoords - trailerCenter)

                            if distFront <= 4.1 or distBack <= 4.1 or distCenter <= 4.1 then
                                lib.callback.await(
                                    _e('server:jobs:gun_smuggling:onCrateAttachTrail'),
                                    false, client.lobby.id, state.attachedToForklift)
                                state.attachedToForklift = nil
                            end
                        end
                    end
                end
            end
            Wait(wait)
        end
    end)
end

local function onCrateDeliver(index)
    if not client.currentJob then return end
    if client.currentJob.steps[5].done then return end

    Citizen.CreateThread(function()
        Utils.progressBar({
            duration = 5000,
            label = locale('gun_smuggling.being_delivered'),
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
                combat = true,
                move = true,
                sprint = true
            }
        })

        lib.callback.await(_e('server:jobs:gun_smuggling:onCrateDeliver'),
            false, client.lobby.id, index)

        if index and state.deliveryBlips[index] then
            RemoveBlip(state.deliveryBlips[index])
            state.deliveryBlips[index] = false
        end
    end)
end

local function createDeliveryPoints()
    for i = 1, client.currentJob.steps[5].progress.target do
        local coords = client.currentJob.game.delivery_locations[i]
        if coords then
            local blip              = Utils.addBlip(coords, config.blips.delivery, true)
            local point             = lib.points.new({
                coords = vector3(coords),
                distance = 5.0,
                onEnter = function(self)
                    local vehicle = cache.vehicle
                    if vehicle and cache.seat == -1 and VehToNet(vehicle) == state.truckNetId then
                        state.deliveryPoints[i] = false
                        onCrateDeliver(i)
                        self:remove()
                    end
                end
            })
            state.deliveryPoints[i] = point
            state.deliveryBlips[i]  = blip
        end
    end
end

local function createFinishPoint()
    local location = client.currentJob.game.location

    state.finishPoint = lib.points.new({
        coords = vector3(location.truck_spawn_location),
        distance = 5.0,
        onEnter = function(self)
            local vehicle = cache.vehicle
            if vehicle and cache.seat == -1 and VehToNet(vehicle) == state.truckNetId then
                self:remove()
                TaskLeaveVehicle(cache.ped, vehicle, 0)
                Citizen.Wait(1000)
                lib.callback.await(_e('server:jobs:onStepDone'), false, client.lobby.id, 6)
            end
        end,
    })

    state.npcBlip = Utils.addBlip(location.truck_spawn_location, config.blips.contact_npc, true)
end

function job.openContainer(index, data)
    lib.callback.await(_e('server:jobs:gun_smuggling:setContainerOpened'), false, client.lobby.id, index)

    local ped = cache.ped
    local pedCoords = GetEntityCoords(ped)
    local pedRotation = GetEntityRotation(ped)

    local animDict = 'anim@scripted@player@mission@tunf_train_ig1_container_p1@male@'
    local ptfxAsset = 'scr_tn_tr'

    lib.requestAnimDict(animDict)
    lib.requestNamedPtfxAsset(ptfxAsset)

    for i = 1, #ContainerAnimation.objects do
        local model = ContainerAnimation.objects[i]
        lib.requestModel(model)
        local object = CreateObject(model, pedCoords.x, pedCoords.y, pedCoords.z, true, true, false)
        table.insert(state.containerSceneObjects, object)
        SetModelAsNoLongerNeeded(model)
    end

    local sceneObject = GetClosestObjectOfType(pedCoords.x, pedCoords.y, pedCoords.z, 2.5, data.model, false, false,
        false)
    NetworkRegisterEntityAsNetworked(sceneObject)

    local scene = NetworkCreateSynchronisedScene(GetEntityCoords(sceneObject), GetEntityRotation(sceneObject),
        2, false, false, -1, 0, 1.0)

    NetworkAddPedToSynchronisedScene(ped, scene, animDict,
        ContainerAnimation.names[1],
        1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(sceneObject, scene, animDict,
        ContainerAnimation.names[2],
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(state.containerSceneObjects[1], scene, animDict,
        ContainerAnimation.names[4],
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(state.containerSceneObjects[2], scene, animDict,
        ContainerAnimation.names[5],
        1.0, 1.0, 1)

    SetEntityCoords(ped, GetEntityCoords(sceneObject))
    NetworkStartSynchronisedScene(scene)
    Wait(4000)
    UseParticleFxAssetNextCall(ptfxAsset)
    local sparks = StartParticleFxLoopedOnEntity('scr_tn_tr_angle_grinder_sparks', state.containerSceneObjects[1], 0.0,
        0.25, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false, 1065353216, 1065353216, 1065353216, 1)
    Wait(1000)
    StopParticleFxLooped(sparks, 1)
    Wait(GetAnimDuration(animDict, 'action') * 1000 - 5000)

    lib.callback.await(_e('server:jobs:gun_smuggling:onContainerOpened'), false, client.lobby.id, index, data,
        GetEntityCoords(sceneObject), GetEntityRotation(sceneObject))

    ClearPedTasks(ped)

    RemoveAnimDict(animDict)
    RemoveNamedPtfxAsset(ptfxAsset)
    for _, v in pairs(state.containerSceneObjects) do
        DeleteEntity(v)
    end
    state.containerSceneObjects = {}
end

function job.spawnTruck()
    local truckModel = config.game.truck_model
    local truckSpawnCoords = client.currentJob.game.location.truck_spawn_location --[[@as vector4]]

    local trailerModel = config.game.trailer_model
    local trailerSpawnCoords = client.currentJob.game.location.trailer_spawn_location --[[@as vector4]]

    lib.requestModel(truckModel)
    lib.requestModel(trailerModel)

    local truck = CreateVehicle(truckModel, truckSpawnCoords.x, truckSpawnCoords.y, truckSpawnCoords.z,
        truckSpawnCoords.w or 0.0, true, true)
    while not DoesEntityExist(truck) do
        Wait(0)
    end

    SetEntityCoords(truck, truckSpawnCoords.x, truckSpawnCoords.y, truckSpawnCoords.z)
    SetVehicleOnGroundProperly(truck)
    Utils.setFuel(truck, 100.0)

    local truckNetId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(truck) then
            NetworkRegisterEntityAsNetworked(truck)
        else
            local netId = VehToNet(truck)
            if NetworkDoesNetworkIdExist(netId) then
                return netId
            end
        end
    end, false, false)

    local trailer = CreateVehicle(trailerModel, trailerSpawnCoords.x, trailerSpawnCoords.y, trailerSpawnCoords.z,
        trailerSpawnCoords.w or 0.0, true, true)
    while not DoesEntityExist(trailer) do
        Wait(0)
    end

    local trailerNetId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(trailer) then
            NetworkRegisterEntityAsNetworked(trailer)
        else
            local netId = VehToNet(trailer)
            if NetworkDoesNetworkIdExist(netId) then
                return netId
            end
        end
    end, false, false)

    while not IsVehicleAttachedToTrailer(truck) do
        AttachVehicleToTrailer(truck, trailer, 2.0)
        Wait(0)
    end

    SetModelAsNoLongerNeeded(truckModel)
    SetModelAsNoLongerNeeded(trailerModel)

    lib.callback.await(_e('server:jobs:gun_smuggling:onTruckSpawned'), false, client.lobby.id,
        truckNetId, trailerNetId)
end

function job.cleanup()
    deleteSpawnedNPC()
    if state.truckBlip then
        RemoveBlip(state.truckBlip)
        state.truckBlip = nil
    end
    if state.containerPoints then
        for _, value in pairs(state.containerPoints) do
            value:remove()
        end
        state.containerPoints = {}
    end
    if state.containerBlips then
        for _, value in pairs(state.containerBlips) do
            RemoveBlip(value)
        end
        state.containerBlips = {}
    end
    if state.containerBoxZones then
        for _, value in pairs(state.containerBoxZones) do
            Target.removeZone(value)
        end
        state.containerBoxZones = {}
    end
    if state.containerSceneObjects then
        for _, v in pairs(state.containerSceneObjects) do
            DeleteEntity(v)
        end
        state.containerSceneObjects = {}
    end
    if state.fakeContainers then
        for _, lobbyFakeContainers in pairs(state.fakeContainers) do
            for _, value in pairs(lobbyFakeContainers) do
                DeleteEntity(value.visible)
                DeleteEntity(value.hidden)
            end
        end
        state.fakeContainers = {}
    end
    if state.deliveryPoints then
        for _, value in pairs(state.deliveryPoints) do
            if value then value:remove() end
        end
        state.deliveryPoints = {}
    end
    if state.deliveryBlips then
        for _, value in pairs(state.deliveryBlips) do
            if value then RemoveBlip(value) end
        end
        state.deliveryBlips = {}
    end
    if state.finishPoint then
        state.finishPoint:remove()
    end
    state.truckNetId = nil
    state.forkliftThread = false
    state.crateCoords = {}
    state.attachedToForklift = nil
    state.truckNetId = nil
    state.trailerNetId = nil
    state.forkliftNetId = nil
end

function job.start()
    job.onStepStart(1)
    return true
end

function job.stop()
    job.cleanup()
    return true
end

function job.onStepStart(stepIndex)
    if stepIndex <= 1 then
        createContactNpc()
        addTargetToNpc()
        return true
    elseif stepIndex == 2 then
        createContainerPoints()
        return true
    elseif stepIndex == 3 then
        local location = client.currentJob.game.location
        for index, container in pairs(location.containers) do
            addContainerBoxZone(index, container)
        end
        return true
    elseif stepIndex == 4 then
        startForkliftThread()
        return true
    elseif stepIndex == 5 then
        createDeliveryPoints()
        return true
    elseif stepIndex == 6 then
        createFinishPoint()
        return true
    end

    if client.lobby.owner == cache.serverId then
        lib.callback.await(_e('server:jobs:finishJob'), false, client.lobby.id)
    end

    return false
end

function job.onStepDone(stepIndex)
    if stepIndex == 1 then
        if state.npcBlip then
            RemoveBlip(state.npcBlip)
            state.npcBlip = nil
        end
    elseif stepIndex == 2 then
        if state.containerPoints then
            for _, value in pairs(state.containerPoints) do
                value:remove()
            end
            state.containerPoints = {}
        end
    elseif stepIndex == 3 then
        if state.containerBoxZones then
            for _, value in pairs(state.containerBoxZones) do
                Target.removeZone(value)
            end
            state.containerBoxZones = {}
        end
        if state.containerBlips then
            for _, value in pairs(state.containerBlips) do
                RemoveBlip(value)
            end
            state.containerBlips = {}
        end
    elseif stepIndex == 4 then
        state.forkliftThread = false
    end

    return job.onStepStart(stepIndex + 1)
end

-- Events

RegisterNetEvent(_e('client:jobs:gun_smuggling:onTruckSpawned'), function(truckNetId, trailerNetId, memberIndex)
    Citizen.CreateThread(function()
        state.trailerNetId = trailerNetId
        state.truckNetId = truckNetId

        local truck = lib.waitFor(function()
            if NetworkDoesEntityExistWithNetworkId(truckNetId) then
                local entity = NetToVeh(truckNetId)
                if DoesEntityExist(entity) then
                    return entity
                end
            end
        end, false, false)

        if truck and DoesEntityExist(truck) then
            Jobs.giveVehicleKey(GetVehicleNumberPlateText(truck), truck)
            state.truckBlip = Utils.addBlip(truck, config.blips.truck)
            if memberIndex == 1 then
                SetPedIntoVehicle(cache.ped, truck, -1)
            end
        end
    end)
end)

RegisterNetEvent(_e('client:jobs:gun_smuggling:onContainerOpened'),
    function(lobbyId, index, data, sceneCoords, sceneRotation)
        local animDict = 'anim@scripted@player@mission@tunf_train_ig1_container_p1@male@'

        lib.requestAnimDict(animDict)
        lib.requestModel(data.model)

        local container = CreateObject(data.model, sceneCoords, false, false, false)
        SetEntityRotation(container, 0.0, 0.0, sceneRotation.z or 0.0, 2, false)
        SetEntityVisible(container, false)
        while not DoesEntityExist(container) do Wait(0) end

        local scene = CreateSynchronizedScene(sceneCoords, sceneRotation,
            2, true, false, 1065353216, 0, 1065353216)
        PlaySynchronizedEntityAnim(container, scene, ContainerAnimation.names[2], animDict,
            1.0, -1.0, 0, 1148846080)

        ForceEntityAiAndAnimationUpdate(container)
        SetSynchronizedScenePhase(scene, 0.99)
        SetEntityCollision(container, false, true)
        FreezeEntityPosition(container, true)
        SetEntityVisible(container, true)

        lib.requestModel(config.game.fakecontainer_model)
        local hidden = CreateObject(config.game.fakecontainer_model, sceneCoords, false, false, false)
        FreezeEntityPosition(hidden, true)
        SetEntityInvincible(hidden, true)
        SetEntityCoords(hidden, sceneCoords.x, sceneCoords.y, sceneCoords.z)
        SetEntityRotation(hidden, 0.0, 0.0, sceneRotation.z or 0.0, 2, false)
        SetEntityVisible(hidden, false)
        SetModelAsNoLongerNeeded(config.game.fakecontainer_model)

        if not state.fakeContainers[lobbyId] then
            state.fakeContainers[lobbyId] = {}
        end
        state.fakeContainers[lobbyId][index] = { visible = container, hidden = hidden }

        RemoveAnimDict(animDict)
        SetModelAsNoLongerNeeded(data.model)
    end)

RegisterNetEvent(_e('client:jobs:gun_smuggling:onStop'), function(lobbyId)
    if state.fakeContainers[lobbyId] then
        for _, value in pairs(state.fakeContainers[lobbyId]) do
            DeleteEntity(value.visible)
            DeleteEntity(value.hidden)
        end
    end
    state.fakeContainers[lobbyId] = nil
end)

RegisterNetEvent(_e('client:jobs:gun_smuggling:onCrateSpawned'), function(index, coords)
    state.crateCoords[index] = coords
end)

RegisterNetEvent(_e('client:jobs:gun_smuggling:onCrateAttachedVehicle'), function(index)
    state.crateCoords[index] = false
end)

RegisterNetEvent(_e('client:jobs:gun_smuggling:attachCrate'), function(lobbyId, netId, index)
    local entity = NetToEnt(netId)
    if DoesEntityExist(entity) then
        local coords = GetEntityCoords(entity)
        local objectCoords = GetOffsetFromEntityInWorldCoords(entity, 0.0, 2.0, 0.0)
        local crateNetId, crate = spawnCrateObject(objectCoords)

        AttachEntityToEntity(crate, entity, GetEntityBoneIndexByName(entity, 'forks'),
            0.0, 1.2, -0.6, 0.0, 0.0, 0.0,
            false, false, false, false, 2, true)

        lib.callback.await(_e('server:jobs:gun_smuggling:onCrateSpawned'), false,
            lobbyId, index, crateNetId, false)
    end
end)

RegisterNetEvent(_e('client:jobs:gun_smuggling:attachCrateToTrailer'), function(lobbyId, netId, index)
    local entity = NetToEnt(netId)
    if DoesEntityExist(entity) then
        local objectCoords = GetEntityCoords(entity)
        local crateNetId, crate = spawnCrateObject(objectCoords, true)

        local offset = vector3(0.0, 6.5 - (index * 2.5), 0.4)

        AttachEntityToEntity(crate, entity, nil,
            offset.x, offset.y, offset.z,
            0.0, 0.0, 0.0,
            false, false, false, false, 2, true)

        lib.callback.await(_e('server:jobs:gun_smuggling:onCrateSpawned'), false,
            lobbyId, index, crateNetId, false)
    end
end)

RegisterNetEvent(_e('client:jobs:gun_smuggling:onForkliftSpawned'), function(forkliftNetId)
    state.forkliftNetId = forkliftNetId

    local forklift = lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(forkliftNetId) then
            local entity = NetToVeh(forkliftNetId)
            if DoesEntityExist(entity) then
                return entity
            end
        end
    end, false, false)

    if forklift and DoesEntityExist(forklift) then
        Jobs.giveVehicleKey(GetVehicleNumberPlateText(forklift), forklift)
    end
end)

--[[ Register ]]
Jobs.register(JOB_KEY, job)

-- Other

Citizen.CreateThread(function()
    if not shared.isResourceStart('3fe_woodbox') then
        if config.game.crate_model == '3fe_lj_woodbox' then
            config.game.crate_model = 'xm_prop_crates_weapon_mix_01a'
        end
        if config.game.crate_on_trail_model == '3fe_lj_woodbox2' then
            config.game.crate_on_trail_model = 'xm_prop_crates_weapon_mix_01a'
        end
    end
end)
