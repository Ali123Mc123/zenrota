local Utils = require 'modules.utils.client'
local Target = require 'modules.target.client'
local lib = lib

-- Constants

local JOB_KEY = 'illegal_delivery'
local config = lib.load(('escrow.jobs.%s.config'):format(JOB_KEY))

local job = {}

local state = {
    locationPoint = nil,
    locationBlip = nil,
    dropOffBlips = {},
    dropOffPoints = {},
    getBoxTarget = nil,
    getBoxTargetZone = nil,
    boxInHand = nil,
    vehicleNetId = nil,
    deliveryPeds = {},
}

local boxPileModel = 'h4_prop_h4_boxpile_01b'
local boxModel = 'prop_cs_cardbox_01'
local holdBoxOffsets = {
    vector3(-0.8, -0.25, -0.13),
    vector3(-0.4, -0.25, -0.13),
    vector3(0.0, -0.25, -0.13),
    vector3(0.4, -0.25, -0.13),
    vector3(0.8, -0.25, -0.13),

    vector3(-0.8, -0.70, -0.13),
    vector3(-0.4, -0.70, -0.13),
    vector3(0.0, -0.70, -0.13),
    vector3(0.4, -0.70, -0.13),
    vector3(0.8, -0.70, -0.13),

    vector3(-0.8, -1.15, -0.13),
    vector3(-0.4, -1.15, -0.13),
    vector3(0.0, -1.15, -0.13),
    vector3(0.4, -1.15, -0.13),
    vector3(0.8, -1.15, -0.13),
}

local function toggleVehicleDoor(open)
    local vehicle = NetworkDoesEntityExistWithNetworkId(state.vehicleNetId) and NetToVeh(state.vehicleNetId)
    if vehicle and DoesEntityExist(vehicle) then
        if NetworkGetEntityOwner(vehicle) == cache.playerId then
            for i = 2, 3 do
                if open then
                    SetVehicleDoorOpen(vehicle, i, false, false)
                else
                    SetVehicleDoorShut(vehicle, i, false, false)
                end
            end
        else
            TriggerServerEvent('illegalpack:server:toggleEntityDoor', VehToNet(vehicle), { 2, 3 }, open)
        end
    end
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
    local holdProp = {
        model = 'prop_cs_cardbox_01', coords = vector3(0.05, 0.1, -0.3), rot = vector3(300.0, 250.0, 20.0)
    }

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

local function onSelectGetBox()
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

        local vehicle = waitTaskVehicle(state.vehicleNetId)
        if DoesEntityExist(vehicle) then
            local textUI = false

            while client.currentJob do
                local wait = 500
                if not DoesEntityExist(vehicle) then
                    vehicle = waitTaskVehicle(state.vehicleNetId)
                end
                if vehicle then
                    local playerPos = GetEntityCoords(cache.ped)

                    local targetPos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -2.5, 0.0)
                    local distFromTarget = #(playerPos - targetPos)
                    local nearTarget = distFromTarget < 2.5

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

local function createLocationPoint()
    local location = client.currentJob.game.location
    if client.lobby.owner == cache.serverId then
        state.locationPoint = lib.points.new({
            coords = location.vehicle_location,
            distance = 75.0,
            onEnter = function(self)
                Utils.triggerPoliceAlert('illegal_delivery', locale("illegal_delivery"))

                local response = lib.callback.await(_e('server:jobs:illegal_delivery:onVehicleSpawn'),
                    false, client.lobby.id)
                if not response then
                    lib.print.warn('Debug: delivery vehicle not spawned!')
                end
                self:remove()
                state.locationPoint = nil
            end
        })
    end

    state.locationBlip = Utils.addBlip(location.vehicle_location, config.blips.location, true)
end

local function createGetBoxZone()
    local location = client.currentJob.game.location
    local zoneKey = 'illegalpack.illegal_delivery.getbox'

    state.getBoxTargetZone = zoneKey
    if client.lobby.owner == cache.serverId then
        state.getBoxTarget = Utils.createObject(boxPileModel, location.get_box_zone, nil, true, true, false)
    end

    Target.addBoxZone(zoneKey, {
        coords = location.get_box_zone,
        name = zoneKey,
        size = vector3(3.0, 3.0, 3.0),
        options = { {
            label = locale('deliver'),
            icon = 'fa-solid fa-boxes-stacked',
            distance = 1.5,
            onSelect = function()
                toggleVehicleDoor(true)
                onSelectGetBox()
            end
        } }
    })
end

local function createDeliveryPed(coords)
    local models = {
        'u_m_m_aldinapoli', 'a_f_m_eastsa_02', 'a_m_m_farmer_01', 'a_f_y_business_02',
        'a_m_m_hasjew_01', 'a_f_y_yoga_01', 'g_f_y_vagos_01', 'g_m_y_korlieut_01',
        'g_f_y_ballas_01', 'g_m_y_mexgoon_03',
    }

    local model = models[math.random(#models)]

    if IsModelValid(model) then
        lib.requestModel(model)
        local createdPed = CreatePed(4, model,
            coords.x, coords.y, coords.z - 1.0, coords.w or 0.0,
            false, false)
        if DoesEntityExist(createdPed) then
            SetPedDefaultComponentVariation(createdPed)
            SetPedDiesWhenInjured(createdPed, false)
            SetEntityInvincible(createdPed, true)
            FreezeEntityPosition(createdPed, true)
            TaskSetBlockingOfNonTemporaryEvents(createdPed, true)
            SetBlockingOfNonTemporaryEvents(createdPed, true)
            SetModelAsNoLongerNeeded(model)
            return createdPed
        end
        SetModelAsNoLongerNeeded(model)
        return nil
    end
end

local function createDeliveryPoints()
    local drop_off_points = client.currentJob.game.drop_off_points
    local points = {}
    state.dropOffBlips = state.dropOffBlips or {}
    local target = client.currentJob.steps[3].progress.target

    for index = 1, target do
        local coords = drop_off_points[index]
        local deliveryPed = createDeliveryPed(coords)
        if state.deliveryPeds[index] then
            DeleteEntity(state.deliveryPeds[index])
        end
        state.deliveryPeds[index] = deliveryPed
        points[index] = lib.points.new({
            coords = coords,
            distance = 2.5,
            onEnter = function()
                Utils.showTextUI('[E] ' .. locale('deliver'))
            end,
            onExit = function()
                Utils.hideTextUI()
            end,
            nearby = function(self)
                if IsControlJustPressed(0, 38) then
                    if not state.boxInHand then
                        Utils.notify(locale('illegal_delivery.donot_have_box'))
                        Wait(500)
                        return
                    end

                    local response = lib.callback.await(_e('server:jobs:illegal_delivery:onBoxDelivered'),
                        false, client.lobby.id, index)
                    if not response then return end


                    if response.error then
                        Utils.notify(response.error, 'error')
                    end

                    if response.remove then
                        Utils.hideTextUI()
                        removeBoxFromPlayerHand()
                    end
                    Wait(1000)
                end
            end
        })
        state.dropOffBlips[index] = Utils.addBlip(coords, config.blips.delivery, index == 1)
    end
    state.dropOffPoints = points
end

local function createGetBoxFromVehicle()
    Citizen.CreateThread(function()
        Citizen.Wait(2000)
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

        local vehicle = waitTaskVehicle(state.vehicleNetId)
        if DoesEntityExist(vehicle) then
            local textUI = false

            while client.currentJob do
                local wait = 500
                if not DoesEntityExist(vehicle) then
                    vehicle = waitTaskVehicle(state.vehicleNetId)
                end
                if vehicle then
                    local playerPos = GetEntityCoords(cache.ped)

                    local targetPos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -2.5, 0.0)
                    local distFromTarget = #(playerPos - targetPos)
                    local isPedOnFoot = not IsPedInAnyVehicle(cache.ped, false)
                    local nearTarget = distFromTarget < 2.5 and isPedOnFoot

                    if nearTarget and not textUI then
                        Utils.showTextUI('[E] ' .. locale(state.boxInHand and 'put_box' or 'illegal_delivery.pick_box'))
                        textUI = true
                    elseif not nearTarget and textUI then
                        Utils.hideTextUI()
                        textUI = false
                    end

                    if nearTarget then
                        wait = 5
                        if IsControlJustPressed(0, 38) then
                            toggleVehicleDoor(true)
                            Utils.hideTextUI()
                            textUI = false
                            if state.boxInHand then
                                removeBoxFromPlayerHand()
                                job.onBoxPlaceInVehicle(vehicle)
                            else
                                if lib.callback.await(_e('server:illegal_delivery:canPickBox'), false, client.lobby.id) then
                                    state.boxInHand = giveBoxToPed(cache.ped)
                                end
                            end
                            Citizen.Wait(1000)
                        end
                    end
                end

                Citizen.Wait(wait)
            end
        end
    end)
end

local function createFinishPoint()
    local location = client.currentJob.game.location

    state.locationPoint = lib.points.new({
        coords = location.vehicle_location,
        distance = 10.0,
        onEnter = function()
            local ped = cache.ped
            local vehicle = cache.vehicle
            if vehicle and GetPedInVehicleSeat(vehicle, -1) == ped then
                textUI = true
                Utils.showTextUI(('[E] %s'):format(locale('illegal_delivery.park_vehicle')))
            end
        end,
        onExit = function()
            textUI = false
            Utils.hideTextUI()
        end,
        nearby = function(self)
            local vehicle = cache.vehicle
            if vehicle then
                if IsControlJustPressed(0, 38) then
                    local ped = cache.ped
                    if GetPedInVehicleSeat(vehicle, -1) == ped then
                        Utils.hideTextUI()
                        TaskLeaveVehicle(ped, vehicle, 0)
                        while cache.vehicle do Wait(0) end
                        Citizen.Wait(1000)
                        lib.callback.await(_e('server:jobs:onStepDone'), false, client.lobby.id, 4)
                        self:remove()
                        state.locationPoint = nil
                    end
                end
            elseif textUI then
                Utils.hideTextUI()
            end
        end
    })

    state.locationBlip = Utils.addBlip(location.vehicle_location, config.blips.location, true)
end

function job.onBoxPlaceInVehicle(vehicle)
    local vehicleNetId = VehToNet(vehicle)
    lib.callback.await(_e('server:jobs:illegal_delivery:requestBoxPlacement'), false, client.lobby.id, vehicleNetId)
end

function job.cleanup()
    if state.locationPoint then
        state.locationPoint:remove()
        state.locationPoint = nil
    end
    if state.locationBlip then
        RemoveBlip(state.locationBlip)
        state.locationBlip = nil
    end
    if state.dropOffBlips then
        for _, value in pairs(state.dropOffBlips) do
            if value then
                RemoveBlip(value)
            end
        end
        state.dropOffBlips = {}
    end
    if state.getBoxTarget then
        DeleteEntity(state.getBoxTarget)
        state.getBoxTarget = nil
    end
    if state.getBoxTargetZone then
        Target.removeZone(state.getBoxTargetZone)
        state.getBoxTargetZone = nil
    end
    if state.boxInHand then
        removeBoxFromPlayerHand()
    end
    if state.dropOffPoints then
        for _, value in pairs(state.dropOffPoints) do
            if value then
                value:remove()
            end
        end
        state.dropOffPoints = {}
    end
    if state.deliveryPeds then
        for _, value in pairs(state.deliveryPeds) do
            DeleteEntity(value)
        end
        state.deliveryPeds = {}
    end
    state.vehicleNetId = nil
end

function job.start()
    job.onStepStart(1)
    return true
end

function job.stop()
    job.cleanup()
    Utils.hideTextUI()
    return true
end

function job.onStepStart(stepIndex)
    if stepIndex <= 1 then
        createLocationPoint()
        return true
    elseif stepIndex == 2 then
        createGetBoxZone()
        return true
    elseif stepIndex == 3 then
        createDeliveryPoints()
        createGetBoxFromVehicle()
        return true
    elseif stepIndex == 4 then
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
        if state.locationBlip then
            RemoveBlip(state.locationBlip)
            state.locationBlip = nil
        end
    elseif stepIndex == 2 then
        Target.removeZone(state.getBoxTargetZone)
        state.getBoxTargetZone = nil
        toggleVehicleDoor(false)
        if state.boxInHand then
            removeBoxFromPlayerHand()
        end
    elseif stepIndex == 3 then
        if state.dropOffPoints then
            for _, value in pairs(state.dropOffPoints) do
                if value then
                    value:remove()
                end
            end
            state.dropOffPoints = {}
        end
        if state.dropOffBlips then
            for _, value in pairs(state.dropOffBlips) do
                if value then
                    RemoveBlip(value)
                end
            end
            state.dropOffBlips = {}
        end
        toggleVehicleDoor(false)
    end

    return job.onStepStart(stepIndex + 1)
end

--events

RegisterNetEvent(_e('client:jobs:illegal_delivery:onVehicleSpawned'), function(netId)
    Citizen.CreateThread(function()
        state.vehicleNetId = netId
        local vehicle = lib.waitFor(function()
            if NetworkDoesEntityExistWithNetworkId(netId) then
                local veh = NetToVeh(netId)
                if DoesEntityExist(veh) then return veh end
            end
        end, false, false)
        if not vehicle then return end

        Jobs.giveVehicleKey(GetVehicleNumberPlateText(vehicle), vehicle)
        Utils.addBlip(vehicle, config.blips.vehicle)
    end)
end)

RegisterNetEvent(_e('client:jobs:illegal_delivery:createBoxOnVehicle'), function(vehicleNetId, lobbyId, index)
    local vehicle = NetToVeh(vehicleNetId)
    if not DoesEntityExist(vehicle) then return end

    local coords = GetEntityCoords(vehicle)
    local holdOffset = holdBoxOffsets[index]

    lib.requestModel(boxModel)
    local box = CreateObject(boxModel, coords.x, coords.y, coords.z, true, true, false)
    while not DoesEntityExist(box) do Wait(0) end

    SetEntityCollision(box, false, false)
    SetEntityCompletelyDisableCollision(box, true)
    SetEntityVisible(box, false)
    SetModelAsNoLongerNeeded(boxModel)

    AttachEntityToEntity(box, vehicle, nil,
        holdOffset.x, holdOffset.y, holdOffset.z,
        0.0, 0.0, 90.0,
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

    lib.callback.await(_e('server:jobs:illegal_delivery:onBoxPlacedInVehicle'), false, lobbyId, index, boxNetId)
end)

RegisterNetEvent(_e('client:jobs:illegal_delivery:onBoxDelivered'), function(index)
    Utils.notify(locale('illegal_delivery.box_delivered'), 'success')

    if state.deliveryPeds[index] then
        DeleteEntity(state.deliveryPeds[index])
        state.deliveryPeds[index] = nil
    end

    if state.dropOffBlips[index] then
        RemoveBlip(state.dropOffBlips[index])
        state.dropOffBlips[index] = nil
    end
    if state.dropOffPoints[index] then
        state.dropOffPoints[index]:remove()
        state.dropOffPoints[index] = nil
    end
end)

RegisterNetEvent(_e('client:jobs:illegal_delivery:triggerPoliceAlert'), function()
    Utils.triggerPoliceAlert('illegal_delivery', locale("illegal_delivery"))
    Utils.notify(locale('chop_shop.police_alerted'), 'warning')
end)

--[[ Register ]]
Jobs.register(JOB_KEY, job)
