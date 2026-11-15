local Utils = require 'modules.utils.client'
local Target = require 'modules.target.client'
local lib = lib

-- Constants

local JOB_KEY = 'moonshine'
local config = lib.load(('escrow.jobs.%s.config'):format(JOB_KEY))

local job = {}

local state = {
    npc = { entity = nil, blip = nil },
    bisonNetId = nil,
    bisonBlip = nil,
    distillation = { point = nil, blip = nil, radiusBlip = nil, },
    fakeStill = nil,
    stillTargetZones = {},
    stills = {},
    boxInHand = nil,
    deliveryLocation = { point = nil, blip = nil },
    tableTargetZone = nil,
    crushingCrateTargetZones = {},
    blendingBarrelTargetZone = nil,
    isPlayerBusy = false,
    grapeObject = nil,
    particleFxHandle = nil,
    heldProp = nil
}

local stillModel = 'prop_still'
local vehicleModel = 'bison'
local boxModel = 'v_ret_ml_beerbla1'

local fruitCrushingCrateModel1_empty = 'prop_ld_crate_01'
local fruitCrushingCrateModel1_full = '3fe_crate_02b'

local fruitCrushingCrateModel2_empty = '3fe_crate_02a'
local fruitCrushingCrateModel2_full = '3fe_crate_02b'

local fruitBlendingBarrelModel = 'prop_barrel_03a'

local holdBoxOffsets = {
    vector3(-0.22, -1.0, 0.45),
    vector3(0.18, -1.0, 0.45),

    vector3(-0.22, -1.45, 0.45),
    vector3(0.18, -1.45, 0.45),

    { coords = vector3(-0.45, -1.875, 0.45), rotation = vector3(0.0, 0.0, 0.0), },
    { coords = vector3(0.0, -1.875, 0.45),   rotation = vector3(0.0, 0.0, 0.0), },
    { coords = vector3(0.45, -1.875, 0.45),  rotation = vector3(0.0, 0.0, 0.0), },

    { coords = vector3(-0.45, -2.25, 0.45),  rotation = vector3(0.0, 0.0, 0.0), },
    { coords = vector3(0.0, -2.25, 0.45),    rotation = vector3(0.0, 0.0, 0.0), },
    { coords = vector3(0.45, -2.25, 0.45),   rotation = vector3(0.0, 0.0, 0.0), },
}

local function stopWaterEffect()
    if state.particleFxHandle then
        StopParticleFxLooped(state.particleFxHandle, false)
        state.particleFxHandle = nil
    end
end

local function startWaterEffect(ped)
    stopWaterEffect()
    local dict = 'core'
    local name = 'water_cannon_spray'
    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do Wait(0) end

    UseParticleFxAssetNextCall(dict)

    local boneIndex = GetPedBoneIndex(ped, 18905)
    state.particleFxHandle = StartParticleFxLoopedOnEntityBone(
        name, ped, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        boneIndex, 0.2, false, false, false
    )
    RemoveNamedPtfxAsset(dict)
end

local function removeBoxFromPlayerHand()
    if state.boxInHand then
        ClearPedTasks(cache.ped)
        if DoesEntityExist(state.boxInHand) then
            DeleteEntity(state.boxInHand)
        end
    end
    state.boxInHand = false
end

local function giveBoxToPed(entity)
    local holdProp = { model = boxModel, coords = vector3(0.05, 0.1, -0.3), rot = vector3(300.0, 250.0, 20.0) }

    local model = holdProp.model
    local object = Utils.createObject(model, vector3(0.0, 0.0, 0.0), nil, false, true, false)
    local pedId = entity or cache.ped
    local boneIndex = GetPedBoneIndex(pedId, 57005)

    AttachEntityToEntity(object, pedId, boneIndex,
        holdProp.coords.x, holdProp.coords.y, holdProp.coords.z,
        holdProp.rot.x, holdProp.rot.y, holdProp.rot.z,
        true, true, false, true, 1, true)

    local animDict = 'anim@heists@box_carry@'
    local animName = 'idle'
    local flag = nil
    lib.requestAnimDict(animDict)
    TaskPlayAnim(pedId, animDict, animName, 8.0, 8.0, -1, 49, 0.0, false, false, false)
    RemoveAnimDict(animDict)

    return object
end

local function addBlipRadius(center, radius)
    local blip = AddBlipForRadius(center.x, center.y, center.z, radius)
    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, 5)
    SetBlipAlpha(blip, 32)
    SetBlipAsShortRange(blip, true)
    return blip
end

local function deleteSpawnedNPC()
    if DoesEntityExist(state.npc.entity) then
        DeleteEntity(state.npc.entity)
    end
    if state.npc.blip then
        RemoveBlip(state.npc.blip)
    end
    state.npc = {}
end

local function createContactNpc()
    local model = config.game.npc_model
    local npcLocation = client.currentJob.game.location.npc_location
    lib.requestModel(model)

    local npcEntity = CreatePed(4, model, npcLocation.x, npcLocation.y, npcLocation.z, npcLocation.w or 0.0,
        false, false)
    while not DoesEntityExist(npcEntity) do Wait(0) end

    FreezeEntityPosition(npcEntity, true)
    SetPedDiesWhenInjured(npcEntity, false)
    SetEntityInvincible(npcEntity, true)
    TaskSetBlockingOfNonTemporaryEvents(npcEntity, true)
    SetBlockingOfNonTemporaryEvents(npcEntity, true)
    SetModelAsNoLongerNeeded(model)

    state.npc.entity = npcEntity

    state.npc.blip = Utils.addBlip(npcEntity, config.blips.contact_npc, true)

    return true
end

local function addTargetToNpc()
    local npc = state.npc.entity

    if not DoesEntityExist(npc) then
        return lib.print.warn('Debug: moonshine contact npc not spawned!')
    end

    Target.addLocalEntity(npc, { {
        label = locale('moonshine.spawn_vehicle'),
        icon = 'fa-solid fa-truck-pickup',
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
            job.spawnBison()
            Target.removeLocalEntity(npc)
        end
    } })
end

local function createDistillationPoint()
    local location = client.currentJob.game.location.distillation_location

    state.distillation.blip = Utils.addBlip(location.coords, config.blips.distillation, true)
    state.distillation.radiusBlip = addBlipRadius(location.coords, location.radius)

    if client.lobby.owner == cache.serverId then
        state.distillation.point = lib.points.new({
            coords = location.coords,
            distance = 25.0,
            onEnter = function(self)
                self:remove()
                state.distillation.point = nil
                lib.callback.await(_e('server:jobs:onStepDone'), false, client.lobby.id, 2)
                -- Utils.triggerPoliceAlert('moonshine', locale("moonshine"))
            end,
        })
    end
end

local function createPackageTable()
    if client.lobby.owner ~= cache.serverId then return end

    local model = config.game.table_model
    local coords = client.currentJob.game.location.table_location
    local table = Utils.createObject(model, coords, vector3(0.0, 0.0, coords.w or 0.0), true, true, false)
    PlaceObjectOnGroundProperly(table)

    local tableNetId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(table) then
            NetworkRegisterEntityAsNetworked(table)
        else
            local netId = ObjToNet(table)
            if NetworkDoesNetworkIdExist(netId) then
                return netId
            end
        end
    end, false, false)

    lib.callback.await(_e('server:jobs:moonshine:onTableSpawned'),
        false, client.lobby.id, tableNetId, coords)
end

local function createCrushingCrates()
    if client.lobby.owner ~= cache.serverId then return end

    local locations = client.currentJob.game.location.crushing_crate_locations

    local netIds = {}

    for index, coords in pairs(locations) do
        local model = fruitCrushingCrateModel2_empty
        if index == 1 then
            model = fruitCrushingCrateModel1_empty
        end
        local object = Utils.createObject(model, coords, vector3(0.0, 0.0, coords.w or 0.0), true, true, false)
        PlaceObjectOnGroundProperly(object)

        local objectNetId = lib.waitFor(function()
            if not NetworkGetEntityIsNetworked(object) then
                NetworkRegisterEntityAsNetworked(object)
            else
                local netId = ObjToNet(object)
                if NetworkDoesNetworkIdExist(netId) then
                    return netId
                end
            end
        end, false, false)

        table.insert(netIds, objectNetId)
    end

    lib.callback.await(_e('server:jobs:moonshine:onCrushingCratesSpawned'),
        false, client.lobby.id, netIds, locations)
end

local function createBlendingBarrel()
    if client.lobby.owner ~= cache.serverId then return end

    local model = fruitBlendingBarrelModel
    local coords = client.currentJob.game.location.blending_barrel_location
    local object = Utils.createObject(model, coords, vector3(0.0, 0.0, coords.w or 0.0), true, true, false)
    PlaceObjectOnGroundProperly(object)

    local objectNetId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(object) then
            NetworkRegisterEntityAsNetworked(object)
        else
            local netId = ObjToNet(object)
            if NetworkDoesNetworkIdExist(netId) then
                return netId
            end
        end
    end, false, false)

    lib.callback.await(_e('server:jobs:moonshine:onBlendingBarrelSpawned'),
        false, client.lobby.id, objectNetId, coords)
end

local function createDeliveryPoint()
    local coords                 = client.currentJob.game.delivery_location

    state.deliveryLocation.blip  = Utils.addBlip(coords, config.blips.delivery)
    state.deliveryLocation.point = lib.points.new({
        coords = vector3(coords),
        distance = 10.0,
        onEnter = function(self)
            local vehicle = cache.vehicle
            if vehicle and cache.seat == -1 and VehToNet(vehicle) == state.bisonNetId then
                state.deliveryLocation.point = nil
                self:remove()
                lib.callback.await(_e('server:jobs:onStepDone'), false, client.lobby.id, 4)
            end
        end
    })
end

function job.spawnBison()
    local vehicleSpawnCoords = client.currentJob.game.location.vehicle_spawn_location --[[@as vector4]]
    lib.requestModel(vehicleModel)

    local bison = CreateVehicle(vehicleModel,
        vehicleSpawnCoords.x, vehicleSpawnCoords.y, vehicleSpawnCoords.z, vehicleSpawnCoords.w or 0.0,
        true, true)
    while not DoesEntityExist(bison) do Wait(0) end

    SetEntityCoords(bison, vehicleSpawnCoords.x, vehicleSpawnCoords.y, vehicleSpawnCoords.z)
    SetVehicleOnGroundProperly(bison)
    Utils.setFuel(bison, 100.0)

    local bisonNetId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(bison) then
            NetworkRegisterEntityAsNetworked(bison)
        else
            local netId = VehToNet(bison)
            if NetworkDoesNetworkIdExist(netId) then
                return netId
            end
        end
    end, false, false)

    SetModelAsNoLongerNeeded(vehicleModel)

    lib.callback.await(_e('server:jobs:moonshine:onBisonSpawned'),
        false, client.lobby.id, bisonNetId)
end

function job.cleanup()
    deleteSpawnedNPC()
    if state.bisonBlip then
        RemoveBlip(state.bisonBlip)
        state.bisonBlip = nil
    end
    if state.fakeStill then
        DeleteEntity(state.fakeStill)
        state.fakeStill = nil
    end
    if state.stillTargetZones then
        for _, value in pairs(state.stillTargetZones) do
            Target.removeZone(value)
        end
        state.stillTargetZones = {}
    end
    if state.tableTargetZone then
        Target.removeZone(state.tableTargetZone)
        state.tableTargetZone = nil
    end
    if state.crushingCrateTargetZones then
        for _, value in pairs(state.crushingCrateTargetZones) do
            Target.removeZone(value)
        end
        state.crushingCrateTargetZones = {}
    end
    if state.blendingBarrelTargetZone then
        Target.removeZone(state.blendingBarrelTargetZone)
        state.blendingBarrelTargetZone = nil
    end
    if state.boxInHand then
        removeBoxFromPlayerHand()
    end
    if state.deliveryLocation.blip then
        RemoveBlip(state.deliveryLocation.blip)
        state.deliveryLocation.blip = nil
    end
    if state.deliveryLocation.point then
        state.deliveryLocation.point:remove()
        state.deliveryLocation.point = nil
    end
    if state.distillation.blip then
        RemoveBlip(state.distillation.blip)
        state.distillation.blip = nil
    end
    if state.distillation.radiusBlip then
        RemoveBlip(state.distillation.radiusBlip)
        state.distillation.radiusBlip = nil
    end
    if state.distillation.point then
        state.distillation.point:remove()
        state.distillation.point = nil
    end
    if state.heldProp then
        DeleteEntity(state.heldProp)
        state.heldProp = nil
        ClearPedTasks(cache.ped)
    end
    state.stills = {}
    state.isPlayerBusy = false
    stopWaterEffect()
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
        createDistillationPoint()
        return true
    elseif stepIndex == 3 then
        createPackageTable()
        createCrushingCrates()
        createBlendingBarrel()
        return true
    elseif stepIndex == 4 then
        createDeliveryPoint()
        return true
    end

    if client.lobby.owner == cache.serverId then
        lib.callback.await(_e('server:jobs:finishJob'), false, client.lobby.id)
    end

    return false
end

function job.onStepDone(stepIndex)
    if stepIndex == 1 then
        if state.npc.blip then
            RemoveBlip(state.npc.blip)
            state.npc.blip = nil
        end
    elseif stepIndex == 2 then
    elseif stepIndex == 3 then
    end

    return job.onStepStart(stepIndex + 1)
end

function job.placeStill()
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    local distillation_location = client.currentJob.game.location.distillation_location
    local distance = #(coords - distillation_location.coords)

    if distance > distillation_location.radius then
        Utils.notify(locale('moonshine.can_not_place_here'), 'error')
        return
    end

    local stillCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
    local stillObject = Utils.createObject(stillModel, stillCoords, nil, true, false, false)
    state.fakeStill = stillObject
    SetEntityHeading(stillObject, (GetEntityHeading(cache.ped) + 180.0) % 360)
    PlaceObjectOnGroundProperly(stillObject)
    local stillRotation = GetEntityRotation(stillObject)

    if shared.isResourceStart(config.game.object_gizmo_resource_name) then
        local data = exports.object_gizmo:useGizmo(stillObject)
        if data then
            stillCoords = data.position
            stillRotation = data.rotation
            SetEntityCoords(stillObject, stillCoords.x, stillCoords.y, stillCoords.z)
        end
        DeleteEntity(state.fakeStill)
        state.fakeStill = nil
    end

    local stillNetObject = Utils.createObject(stillModel, stillCoords, stillRotation, true, true, false)
    local stillNetId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(stillNetObject) then
            NetworkRegisterEntityAsNetworked(stillNetObject)
        else
            local netId = ObjToNet(stillNetObject)
            if NetworkDoesNetworkIdExist(netId) then
                return netId
            end
        end
    end, false, false)

    lib.callback.await(_e('server:jobs:moonshine:onStillSpawned'),
        false, client.lobby.id, stillNetId, stillCoords, stillRotation)
end

function job.addItemsToPot(stillIndex)
    local response = lib.callback.await(_e('server:jobs:moonshine:addItemsToPot'),
        false, client.lobby.id, stillIndex)
    if not response then return end
    if response.error then
        Utils.notify(response.error, 'error')
    end
end

function job.openRecipePage(stillIndex)
    if not client.currentJob.game.stills[stillIndex].itemsInPot then return end
    if client.currentJob.game.stills[stillIndex].recipePrepared then return end

    client.sendReactMessage('ui:moonshine:setStillIndex', stillIndex)
    client.sendReactMessage('ui:setPage', 'prepare_recipe')
    client.sendReactMessage('ui:setVisible', true)
    SetNuiFocus(true, true)
end

function job.startCooking(stillIndex)
    if not client.currentJob.game.stills[stillIndex].itemsInPot then return end
    if not client.currentJob.game.stills[stillIndex].recipePrepared then return end
    if client.currentJob.game.stills[stillIndex].cookingStarted then return end

    local response = lib.callback.await(_e('server:jobs:moonshine:startCooking'),
        false, client.lobby.id, stillIndex)
    if not response then return end

    Utils.notify(locale('moonshine.cooking_started'), 'success')
end

function job.collectProduct(stillIndex)
    if not client.currentJob.game.stills[stillIndex].itemsInPot then return end
    if not client.currentJob.game.stills[stillIndex].recipePrepared then return end
    if not client.currentJob.game.stills[stillIndex].cookingStarted then return end

    local response = lib.callback.await(_e('server:jobs:moonshine:collectProduct'),
        false, client.lobby.id, stillIndex)
    if not response then return end
    if response.error then
        return Utils.notify(response.error, 'error')
    end

    Utils.notify(locale('moonshine.product_collected'), 'success')
end

function job.onBoxPlaceInVehicle(vehicle)
    local vehicleNetId = VehToNet(vehicle)
    lib.callback.await(_e('server:jobs:moonshine:onPackagePlacedVehicle'), false, client.lobby.id, vehicleNetId)
end

function job.packageMoonshine()
    if state.boxInHand then return end
    if not client.currentJob then return end
    if client.currentJob and client.currentJob.steps[4].done then return end

    local response = lib.callback.await(_e('server:jobs:moonshine:packageMoonshine'),
        false, client.lobby.id)
    if not response then return end
    if response.error then
        return Utils.notify(response.error, 'error')
    end

    Utils.notify(locale('moonshine.moonshine_packed'), 'success', 5000)

    state.boxInHand = giveBoxToPed(cache.ped)

    Citizen.CreateThread(function()
        local waitTaskVehicle = function(netId)
            local vehicle = lib.waitFor(function()
                if not client.currentJob then return false end
                if NetworkDoesEntityExistWithNetworkId(netId) then
                    local veh = NetToVeh(netId)
                    if DoesEntityExist(veh) then return veh end
                end
            end, false, false)
            return vehicle
        end

        local vehicle = waitTaskVehicle(state.bisonNetId)

        if DoesEntityExist(vehicle) then
            local textUI = false

            while client.currentJob do
                local wait = 500
                if not DoesEntityExist(vehicle) then
                    vehicle = waitTaskVehicle(state.bisonNetId)
                end
                if vehicle then
                    local playerPos = GetEntityCoords(cache.ped)

                    local targetPos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -2.5, 0.0)
                    local distFromTarget = #(playerPos - targetPos)
                    local nearTarget = distFromTarget < 1.5

                    if nearTarget and not textUI then
                        Utils.showTextUI('[E] ' .. locale('put_box'))
                        textUI = true
                    elseif not nearTarget and textUI then
                        Utils.hideTextUI()
                        textUI = false
                    end

                    if nearTarget then
                        wait = 5
                        if IsControlJustPressed(0, 38) then
                            Utils.hideTextUI()
                            removeBoxFromPlayerHand()
                            job.onBoxPlaceInVehicle(vehicle)
                            break
                        end
                    end
                end

                Citizen.Wait(wait)
            end
        end
    end)
end

function job.fruitCrushing(index)
    if state.isPlayerBusy then return end

    local targetCoords = client.currentJob.game.location.crushing_crate_locations[index]

    local response = lib.callback.await(_e('server:jobs:moonshine:onFruitCrushing'),
        false, client.lobby.id, { index = index, coords = targetCoords })
    if response and response.error then
        return Utils.notify(response.error, 'error')
    end

    state.isPlayerBusy = true
    local animDict = 'move_m@generic'
    local animName = 'walk_up_slope'
    local playerPed = cache.ped
    FreezeEntityPosition(playerPed, true)
    SetEntityCoordsNoOffset(playerPed,
        targetCoords.x, targetCoords.y, targetCoords.z + 1.0,
        true, true, false)
    SetEntityHeading(playerPed, targetCoords.w + (index ~= 1 and 90.0 or 90.0))
    lib.playAnim(playerPed, animDict, animName, nil, nil, -1, 1)

    if not Utils.checkSkill(config.game.skillCheck, 'crushing') then
        ClearPedTasks(playerPed)
        FreezeEntityPosition(playerPed, false)
        state.isPlayerBusy = false
        return
    end

    local success = Utils.progressBar({
        duration = 10000,
        label = locale('progress'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = { car = true, combat = true, move = true, sprint = true },
    })
    ClearPedTasks(playerPed)
    FreezeEntityPosition(playerPed, false)
    state.isPlayerBusy = false

    if not success then
        return
    end

    local response = lib.callback.await(_e('server:jobs:moonshine:onFruitCrushed'),
        false, client.lobby.id, { index = index, coords = targetCoords })
    if response and response.error then
        Utils.notify(response.error, 'error')
    end
end

function job.fruitBlending()
    if state.isPlayerBusy then return end
    state.isPlayerBusy = true

    local animDict = 'missfbi3_toothpull'
    local animName = 'pull_tooth_loop_weak_player'
    local playerPed = cache.ped

    FreezeEntityPosition(playerPed, true)

    local objectCoords = client.currentJob.game.location.blending_barrel_location

    local targetObject = GetClosestObjectOfType(
        objectCoords.x, objectCoords.y, objectCoords.z,
        1.0, fruitBlendingBarrelModel, false, false, false)
    local targetCoords = GetOffsetFromEntityInWorldCoords(targetObject, 0.35, 0.8, 0.0)

    SetEntityCoordsNoOffset(playerPed,
        targetCoords.x, targetCoords.y, targetCoords.z + 0.50,
        true, true, false)
    SetEntityHeading(playerPed, (GetEntityHeading(targetObject) + 180.0) % 360)

    local animDict = 'missfbi3_toothpull'
    local animName = 'pull_tooth_loop_weak_player'
    lib.playAnim(playerPed, animDict, animName, nil, nil, -1, 1)

    local propModel = 'prop_tool_shovel5'
    lib.requestModel(propModel)
    local coords = GetEntityCoords(playerPed)
    state.heldProp = CreateObject(propModel, coords.x, coords.y, coords.z, true, true, false)
    AttachEntityToEntity(
        state.heldProp, playerPed,
        nil,               -- El kemiği
        -0.85, 0.85, 0.05, -- Pos offset
        45.0, 0.0, 75.0,   -- Rot offset
        true, true, false, true, 1, true
    )
    SetModelAsNoLongerNeeded(propModel)
    startWaterEffect(playerPed)

    if not Utils.checkSkill(config.game.skillCheck, 'blending') then
        FreezeEntityPosition(playerPed, false)
        ClearPedTasks(playerPed)
        state.isPlayerBusy = false
        DeleteEntity(state.heldProp)
        state.heldProp = nil
        stopWaterEffect()
        return
    end

    local success = Utils.progressBar({
        duration = 5000,
        label = locale('progress'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = { car = true, combat = true, move = true, sprint = true },
    })

    FreezeEntityPosition(playerPed, false)
    ClearPedTasks(playerPed)
    state.isPlayerBusy = false
    DeleteEntity(state.heldProp)
    state.heldProp = nil
    stopWaterEffect()

    if not success then
        return
    end

    local response = lib.callback.await(_e('server:jobs:moonshine:onFruitBlended'),
        false, client.lobby.id)
    if response and response.error then
        Utils.notify(response.error, 'error')
    end
end

-- Events

RegisterNUICallback('nui:moonshine:onSuccessPrepareRecipe', function(stillIndex, resultCallback)
    client.sendReactMessage('ui:moonshine:setStillIndex', nil)
    client.hideUI()
    client.sendReactMessage('ui:setPage', 'home')

    lib.callback.await(_e('server:jobs:moonshine:setStillRecipePrepared'),
        false, client.lobby.id, stillIndex)

    resultCallback(true)
end)

RegisterNetEvent(_e('client:jobs:moonshine:onBisonSpawned'), function(bisonNetId, memberIndex)
    Citizen.CreateThread(function()
        state.bisonNetId = bisonNetId

        local bison = lib.waitFor(function()
            if NetworkDoesEntityExistWithNetworkId(bisonNetId) then
                local entity = NetToVeh(bisonNetId)
                if DoesEntityExist(entity) then
                    return entity
                end
            end
        end, false, false)

        if bison and DoesEntityExist(bison) then
            Jobs.giveVehicleKey(GetVehicleNumberPlateText(bison), bison)
            state.bisonBlip = Utils.addBlip(bison, config.blips.vehicle)
            if memberIndex == 1 then
                SetPedIntoVehicle(cache.ped, bison, -1)
            end
        end
    end)
end)



RegisterNetEvent(_e('client:jobs:moonshine:onStillSpawned'), function(index, coords, rotation, stills)
    if not client.currentJob then return end

    client.currentJob.game.stills = stills
    state.stills[index] = { coords = coords, rotation = rotation, fired = false }
    local stillIndex = index

    local zoneKey = 'illegalpack.moonshine.still_' .. #state.stillTargetZones + 1
    table.insert(state.stillTargetZones, zoneKey)

    Target.addBoxZone(zoneKey, {
        coords = coords,
        rotation = rotation,
        name = zoneKey,
        size = vector3(2.0, 2.0, 2.5),
        options = {
            {
                label = locale('moonshine.add_items_to_pot'),
                icon = 'fa-regular fa-circle',
                distance = 1.5,
                canInteract = function()
                    return not client.currentJob.game.stills[stillIndex].itemsInPot
                end,
                onSelect = function()
                    job.addItemsToPot(stillIndex)
                end
            },
            {
                label = locale('moonshine.prepare_recipe'),
                icon = 'fa-regular fa-circle',
                distance = 1.5,
                canInteract = function()
                    return not client.currentJob.game.stills[stillIndex].recipePrepared
                end,
                onSelect = function()
                    job.openRecipePage(stillIndex)
                end
            },
            {
                label = locale('moonshine.start_cooking'),
                icon = 'fa-regular fa-circle',
                distance = 1.5,
                canInteract = function()
                    return not client.currentJob.game.stills[stillIndex].cookingStarted
                end,
                onSelect = function()
                    job.startCooking(stillIndex)
                end
            },
            {
                label = locale('moonshine.collect_product'),
                icon = 'fa-regular fa-circle',
                distance = 1.5,
                onSelect = function()
                    job.collectProduct(stillIndex)
                end
            },
        }
    })
end)

RegisterNetEvent(_e('client:jobs:moonshine:onUsedMoonshineStill'), function()
    if not client.currentJob then return end
    if client.currentJob.name ~= JOB_KEY then return end
    if not client.currentJob.steps[2].done then return end
    if client.currentJob.steps[3].done then return end

    job.placeStill()
end)

RegisterNetEvent(_e('client:jobs:moonshine:onStillsUpdated'), function(newStills)
    if not client.currentJob then return end

    client.currentJob.game.stills = newStills

    Utils.notify(locale('moonshine.still_updated'), 'success')
end)

RegisterNetEvent(_e('client:jobs:moonshine:onTableSpawned'), function(coords)
    if not client.currentJob then return end

    local zoneKey = 'illegalpack.moonshine.table'
    state.tableTargetZone = zoneKey

    Target.addBoxZone(zoneKey, {
        coords = coords,
        rotation = vector3(0.0, 0.0, coords.w or 0.0),
        name = zoneKey,
        size = vector3(2.5, 2.0, 2.5),
        options = {
            {
                label = locale('moonshine.package'),
                icon = 'fa-regular fa-circle',
                distance = 1.5,
                canInteract = function()
                    return not state.boxInHand and client.currentJob and not client.currentJob.steps[4].done
                end,
                onSelect = function()
                    job.packageMoonshine()
                end
            },
        }
    })
end)

RegisterNetEvent(_e('client:jobs:moonshine:createBoxOnVehicle'), function(vehicleNetId, lobbyId, index)
    local vehicle = NetToVeh(vehicleNetId)
    if not DoesEntityExist(vehicle) then return end

    local coords = GetEntityCoords(vehicle)
    local holdOffset = holdBoxOffsets[index]
    if not holdOffset then return end

    lib.requestModel(boxModel)
    local box = CreateObject(boxModel, coords.x, coords.y, coords.z, true, true, false)
    while not DoesEntityExist(box) do Wait(0) end

    SetEntityCollision(box, false, false)
    SetEntityCompletelyDisableCollision(box, true)
    SetEntityVisible(box, false)
    SetModelAsNoLongerNeeded(boxModel)

    local holdOffsetCoords = type(holdOffset) == 'table' and holdOffset.coords or holdOffset
    local holdOffsetRot = type(holdOffset) == 'table' and holdOffset.rotation or vector3(0.0, 0.0, 90.0)

    AttachEntityToEntity(box, vehicle, nil,
        holdOffsetCoords.x, holdOffsetCoords.y, holdOffsetCoords.z,
        holdOffsetRot.x, holdOffsetRot.y, holdOffsetRot.z,
        false, false, false, false, 0, true
    )

    local boxNetId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(box) then
            NetworkRegisterEntityAsNetworked(box)
        else
            local netId = ObjToNet(box)
            if NetworkDoesNetworkIdExist(netId) then
                return netId
            end
        end
    end, false, false)
    SetEntityVisible(box, true)

    lib.callback.await(_e('server:jobs:moonshine:onBoxPlacedInVehicle'), false, lobbyId, index, boxNetId)
end)

RegisterNetEvent(_e('client:jobs:moonshine:onCrushingCratesSpawned'), function(locations)
    if not client.currentJob then return end

    for key, coords in pairs(locations) do
        local zoneKey = 'illegalpack.moonshine.crushingcrate_' .. key
        table.insert(state.crushingCrateTargetZones, zoneKey)

        local size = vector3(1.2, 1.2, 1.5)
        if key == 1 then
            size = vector3(2.2, 1.1, 1.25)
        end

        Target.addBoxZone(zoneKey, {
            coords = coords,
            rotation = vector3(0.0, 0.0, coords.w or 0.0),
            name = zoneKey,
            size = size,
            debug = false,
            options = {
                {
                    label = locale('moonshine.fruit_crushing'),
                    icon = 'fa-regular fa-circle',
                    distance = 1.5,
                    canInteract = function()
                        return not state.boxInHand and client.currentJob and not state.isPlayerBusy
                    end,
                    onSelect = function()
                        job.fruitCrushing(key)
                    end
                },
            }
        })
    end
end)

RegisterNetEvent(_e('client:jobs:moonshine:onBlendingBarrelSpawned'), function(coords)
    if not client.currentJob then return end

    local zoneKey = 'illegalpack.moonshine.blendingbarrel'
    state.blendingBarrelTargetZone = zoneKey

    Target.addBoxZone(zoneKey, {
        coords = coords,
        rotation = vector3(0.0, 0.0, coords.w or 0.0),
        name = zoneKey,
        size = vector3(1.5, 1.0, 1.0),
        options = {
            {
                label = locale('moonshine.fruit_blending'),
                icon = 'fa-regular fa-circle',
                distance = 1.5,
                canInteract = function()
                    return not state.boxInHand and client.currentJob and not state.isPlayerBusy
                end,
                onSelect = function()
                    job.fruitBlending()
                end
            },
        }
    })
end)

lib.callback.register(_e('client:jobs:moonshine:swapCrushingCrateModel'), function(lobbyId, oldNetId, data)
    local entity = NetToEnt(oldNetId)
    local newNetId = nil
    local coords = data.coords

    if DoesEntityExist(entity) then
        DeleteEntity(entity)

        local model = fruitCrushingCrateModel2_full
        if data.index == 1 then
            model = fruitCrushingCrateModel1_full
        end
        local object = Utils.createObject(model, coords, vector3(0.0, 0.0, coords.w or 0.0), true, true, false)
        PlaceObjectOnGroundProperly(object)

        newNetId = lib.waitFor(function()
            if not NetworkGetEntityIsNetworked(object) then
                NetworkRegisterEntityAsNetworked(object)
            else
                local netId = ObjToNet(object)
                if NetworkDoesNetworkIdExist(netId) then
                    return netId
                end
            end
        end, false, false)
    end

    return newNetId
end)

lib.callback.register(_e('client:jobs:moonshine:resetCrushingCrateModel'), function(lobbyId, oldNetId, data)
    local entity = NetToEnt(oldNetId)
    local newNetId = nil
    local coords = data.coords

    if DoesEntityExist(entity) then
        DeleteEntity(entity)

        local model = fruitCrushingCrateModel2_empty
        if data.index == 1 then
            model = fruitCrushingCrateModel1_empty
        end
        local object = Utils.createObject(model, coords, vector3(0.0, 0.0, coords.w or 0.0), true, true, false)
        PlaceObjectOnGroundProperly(object)

        newNetId = lib.waitFor(function()
            if not NetworkGetEntityIsNetworked(object) then
                NetworkRegisterEntityAsNetworked(object)
            else
                local netId = ObjToNet(object)
                if NetworkDoesNetworkIdExist(netId) then
                    return netId
                end
            end
        end, false, false)
    end

    return newNetId
end)

--[[ Register ]]
Jobs.register(JOB_KEY, job)

-- Other

Citizen.CreateThread(function()
    if not shared.isResourceStart('3fe_woodbox') then
        local noresource_1 = 'prop_ld_crate_01'
        local noresource_2 = 'prop_crate_05a'

        fruitCrushingCrateModel1_empty = noresource_1
        fruitCrushingCrateModel1_full = noresource_1
        fruitCrushingCrateModel2_empty = noresource_2
        fruitCrushingCrateModel2_full = noresource_2
    end
end)
