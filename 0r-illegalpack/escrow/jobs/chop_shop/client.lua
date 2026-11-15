local Utils = require 'modules.utils.client'
local Target = require 'modules.target.client'
local DigiScanner = require 'modules.digiscanner.client'
local lib = lib

-- Constants

local JOB_KEY = 'chop_shop'
local config = lib.load(('escrow.jobs.%s.config'):format(JOB_KEY))

local job = {}

local state = {
    vehiclePoint = nil,
    vehicleLocationBlip = nil,
    vehicleNetId = nil,
    targetDropOffPoint = nil,
    dropOffPointBlip = nil,
    spawnedPartsInHand = {},
    partDropOffPoint = nil,
}

local chopParts = {
    ['door_dside_f'] = { part = 0, prop = 'prop_car_door_01' },
    ['door_dside_r'] = {
        part = 2,
        prop = 'prop_car_door_01',
        condition = function(v) return GetVehicleMaxNumberOfPassengers(v) > 1 end
    },
    ['door_pside_r'] = {
        part = 3,
        prop = 'prop_car_door_01',
        condition = function(v) return GetVehicleMaxNumberOfPassengers(v) > 1 end
    },
    ['door_pside_f'] = { part = 1, prop = 'prop_car_door_01' },
    ['bonnet'] = { part = 4, prop = 'prop_car_bonnet_02' },
    ['wheel_lf'] = { part = 0, prop = 'prop_wheel_01', isWheel = true },
    ['wheel_lr'] = { part = 4, prop = 'prop_wheel_01', isWheel = true },
    ['wheel_rr'] = { part = 5, prop = 'prop_wheel_01', isWheel = true },
    ['wheel_rf'] = { part = 1, prop = 'prop_wheel_01', isWheel = true },
}

local function deleteSpawnedParts()
    for _, value in pairs(state.spawnedPartsInHand) do
        SetEntityAsMissionEntity(value, true, true)
        DeleteEntity(value)
    end
    ClearPedTasks(cache.ped)
    state.spawnedPartsInHand = {}
end

local function setStepTarget(vehicle)
    if client.lobby.owner ~= cache.serverId then return end
    local targetCount = 0

    for boneName, _ in pairs(chopParts) do
        local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
        if boneIndex ~= -1 then
            targetCount = targetCount + 1
        end
    end

    lib.callback.await(_e('server:jobs:setStepTarget'), false,
        JOB_KEY, client.lobby.id, 4, targetCount, true)
end

local function waitForVehicle(netId)
    return lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(netId) then
            local veh = NetToVeh(netId)
            if DoesEntityExist(veh) then return veh end
        end
    end, false, false)
end

local function spawnCarPartInHand(partName, isWheel)
    local playerPed = cache.ped
    local boneIndex = GetPedBoneIndex(playerPed, not isWheel and 57005 or 4089)
    local prop = Utils.createObject(partName,
        GetEntityCoords(playerPed), nil,
        false, true, false)

    local xOffset, yOffset, zOffset = 0.1, 0.5, -0.3
    local xRot, yRot, zRot = 0.0, 0.0, 90.0

    if isWheel then
        xOffset, yOffset, zOffset = 0.1, 0.08, 0.25
        xRot, yRot, zRot = 190.0, 0.0, 0.0
    end

    AttachEntityToEntity(prop, playerPed, boneIndex,
        xOffset, yOffset, zOffset,
        xRot, yRot, zRot,
        true, true, false, true, 1, true)
    return prop
end

local function createVehicleLocationPoint()
    local coords = client.currentJob.game.location.vehicle_location
    if client.lobby.owner == cache.serverId then
        state.vehiclePoint = lib.points.new({
            coords = coords,
            distance = 50.0,
            onEnter = function(self)
                self:remove()
                state.vehiclePoint = nil
                lib.callback.await(_e('server:jobs:onStepDone'), false, client.lobby.id, 1)
                -- Utils.triggerPoliceAlert('chop_shop_vehicle', locale("chop_shop_vehicle"))
            end
        })
    end

    state.vehicleLocationBlip = Utils.addBlip(coords, config.blips.vehicle_location, true)
end

local function spawnVehicleOnLocationPoint()
    if client.lobby.owner == cache.serverId then
        lib.callback.await(_e('server:jobs:chop_shop:spawnVehicle'), false, client.lobby.id)
    end
end

local function findDropOffLocation()
    if client.lobby.owner == cache.serverId then
        lib.callback.await(_e('server:jobs:chop_shop:setLobbyTargetDropOffCoord'), false, client.lobby.id)
    end
end

local function createPartDropOffPoint(boneName)
    local coords = client.currentJob.game.drop_off_location.drop_off
    local textUI = false
    state.partDropOffPoint = lib.points.new({
        coords = coords,
        distance = 15.0,
        nearby = function(self)
            DrawMarker(
                20,
                coords.x, coords.y, coords.z,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                0.5, 0.5, 0.5,
                255, 0, 0, 150,
                true, true, 2, nil, nil, false
            )
            if self.currentDistance <= 2.5 then
                if not textUI then
                    textUI = true
                    Utils.showTextUI(('[E] %s'):format(locale('chop_shop.destroy_part')))
                end
                if IsControlJustPressed(0, 38) then
                    self:remove()
                    state.partDropOffPoint = nil
                    deleteSpawnedParts()
                    ClearPedTasks(cache.ped)
                    Utils.hideTextUI()
                    lib.callback.await(_e('server:jobs:chop_shop:onPartDestroy'), false, client.lobby.id, boneName)
                end
            elseif textUI then
                textUI = false
                Utils.hideTextUI()
            end
        end
    })
end

local function createDropOffPoint(coords)
    local textUI = false
    state.targetDropOffPoint = lib.points.new({
        coords = coords,
        distance = 10.0,
        onEnter = function()
            local ped = cache.ped
            local vehicle = cache.vehicle
            if vehicle and GetPedInVehicleSeat(vehicle, -1) == ped then
                textUI = true
                Utils.showTextUI(('[E] %s'):format(locale('chop_shop.park_vehicle')))
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
                        lib.callback.await(_e('server:jobs:onStepDone'), false, client.lobby.id, 3)
                        self:remove()
                        state.targetDropOffPoint = nil
                    end
                end
            elseif textUI then
                Utils.hideTextUI()
            end
        end
    })

    state.dropOffPointBlip = Utils.addBlip(coords, config.blips.drop_off_location, true)
end

local function freezeLockVehicle(vehicle)
    if not DoesEntityExist(vehicle) then return end

    FreezeEntityPosition(vehicle, true)
    SetVehicleDoorsShut(vehicle, true)
end

local function chopToPart(vehicle, boneName)
    local data = chopParts[boneName]
    if not data then return end

    if data.condition and not data.condition(vehicle) then return end

    if not lib.callback.await(_e('server:jobs:chop_shop:canPartChop'), false, client.lobby.id, boneName) then
        return
    end

    local ped = cache.ped
    if not data.isWheel then
        SetVehicleDoorOpen(vehicle, data.part, false, false)
    end
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_WELDING', 0, true)
    Wait(10000)

    ClearPedTasksImmediately(ped)
    local prop = spawnCarPartInHand(data.prop, data.isWheel)
    table.insert(state.spawnedPartsInHand, prop)

    local holdAnim = {
        dict = 'anim@heists@box_carry@',
        clip = 'idle'
    }
    lib.requestAnimDict(holdAnim.dict)
    TaskPlayAnim(ped, holdAnim.dict, holdAnim.clip,
        8.0, -8.0, -1, 50, 0,
        false, false, false)
    RemoveAnimDict(holdAnim.dict)

    if data.isWheel then
        SetVehicleTyreBurst(vehicle, data.part, true, 1000.0)
    else
        SetVehicleDoorBroken(vehicle, data.part, true)
    end

    lib.callback.await(_e('server:jobs:chop_shop:onPartChop'), false, client.lobby.id, boneName)
    createPartDropOffPoint(boneName)
end

local function getClosestVehiclePart(vehicle, playerCoords)
    local closestPart, closestCoords
    local minDist = 1.5

    for boneName, _ in pairs(chopParts) do
        if client.currentJob and client.currentJob.game and client.currentJob.game.dropped_vehicle_parts and not client.currentJob.game.dropped_vehicle_parts[boneName] then
            local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
            if boneIndex ~= -1 then
                local boneCoords = GetWorldPositionOfEntityBone(vehicle, boneIndex)
                local dist = #(playerCoords - boneCoords)
                if dist < minDist then
                    minDist = dist
                    closestPart = boneName
                    closestCoords = boneCoords
                end
            end
        end
    end

    return closestPart, closestCoords
end

local function addChopTargetsToVehicle(netId)
    Citizen.CreateThread(function()
        local vehicle = waitForVehicle(netId)

        while client.currentJob do
            local wait = #state.spawnedPartsInHand > 0 and 1000 or 1
            Citizen.Wait(wait)

            if not DoesEntityExist(vehicle) then
                vehicle = waitForVehicle(netId)
            end

            local playerPed = cache.ped
            local playerCoords = GetEntityCoords(playerPed)

            if #state.spawnedPartsInHand <= 0 then
                local closestPart, coords = getClosestVehiclePart(vehicle, playerCoords)
                if closestPart and coords then
                    Utils.drawText3D(coords, '~g~E~w~ - ' .. locale('chop_shop.chop_part'))

                    if IsControlJustReleased(0, 38) then
                        chopToPart(vehicle, closestPart)
                    end
                end
            end
        end
    end)
end

function job.cleanup()
    if state.vehiclePoint then
        state.vehiclePoint:remove()
        state.vehiclePoint = nil
    end
    if state.vehicleLocationBlip then
        RemoveBlip(state.vehicleLocationBlip)
        state.vehicleLocationBlip = nil
    end
    if state.targetDropOffPoint then
        state.targetDropOffPoint:remove()
        state.targetDropOffPoint = nil
    end
    if state.dropOffPointBlip then
        RemoveBlip(state.dropOffPointBlip)
        state.dropOffPointBlip = nil
    end
    if state.spawnedPartsInHand then
        deleteSpawnedParts()
    end
    if state.partDropOffPoint then
        state.partDropOffPoint:remove()
        state.partDropOffPoint = nil
    end
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
        createVehicleLocationPoint()
        return true
    elseif stepIndex == 2 then
        spawnVehicleOnLocationPoint()
        return true
    elseif stepIndex == 3 then
        findDropOffLocation()
        return true
    elseif stepIndex == 4 then
        local netId = lib.callback.await(_e('server:jobs:chop_shop:getVehicleNetId'), false, client.lobby.id)
        if not netId then return false end

        local vehicle = waitForVehicle(netId)

        freezeLockVehicle(vehicle)
        setStepTarget(vehicle)
        addChopTargetsToVehicle(netId)
        return true
    end

    if client.lobby.owner == cache.serverId then
        lib.callback.await(_e('server:jobs:finishJob'), false, client.lobby.id)
    end

    return false
end

function job.onStepDone(stepIndex)
    if stepIndex == 1 then
        Citizen.CreateThread(function()
            Citizen.Wait(30000)
            if client.currentJob and client.currentJob.name == JOB_KEY then
                Utils.triggerPoliceAlert('chop_shop', locale("chop_shop"))
                Utils.notify(locale('chop_shop.police_alerted'), 'warning')
            end
        end)
    elseif stepIndex == 2 then
        RemoveBlip(state.vehicleLocationBlip)
        state.vehicleLocationBlip = nil
    elseif stepIndex == 3 then
        if state.targetDropOffPoint then
            state.targetDropOffPoint:remove()
            state.targetDropOffPoint = nil
        end
    end

    return job.onStepStart(stepIndex + 1)
end

--[[ events ]]

RegisterNetEvent(_e('client:jobs:chop_shop:onVehicleSpawned'), function(vehicleNetId)
    Citizen.CreateThread(function()
        state.vehicleNetId = vehicleNetId
        local vehicle = waitForVehicle(vehicleNetId)

        SetVehicleDoorsLocked(vehicle, 2)
        -- SetVehicleDoorsLockedForAllPlayers(vehicle, true)
        DigiScanner.scan(client.currentJob.game.location.key_location, JOB_KEY)
    end)
end)

RegisterNetEvent('client:onDigiScannerCompleted', function(who)
    if who ~= JOB_KEY then return end
    if not Utils.checkSkill(config.game.skillCheck, 'digiscanner') then
        Utils.notify(locale('chop_shop.digiscanner_failed'), 'error')
        Citizen.Wait(500)
        DigiScanner.scan(client.currentJob.game.location.key_location, JOB_KEY)
        return
    end

    local success = Utils.progressBar({
        duration = 4000,
        label = locale('progress'),
        position = 'middle',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            combat = true,
            move = true,
            sprint = true
        },
    })
    if not success then
        Utils.notify(locale('chop_shop.digiscanner_failed'), 'error')
        return
    end

    Utils.notify(locale('chop_shop.digiscanner_comleted'), 'success')

    Citizen.CreateThread(function()
        local vehicleNetId = state.vehicleNetId
        local vehicle = waitForVehicle(vehicleNetId)
        Citizen.Wait(500)

        local plate = GetVehicleNumberPlateText(vehicle)
        if plate then
            plate = string.gsub(plate, "^%s*(.-)%s*$", "%1")
            Jobs.giveVehicleKey(plate, vehicle)
        end

        SetVehicleDoorsLocked(vehicle, 1)
        lib.callback.await(_e('server:jobs:onStepDone'), false, client.lobby.id, 2)
    end)
end)

RegisterNetEvent(_e('client:jobs:chop_shop:onAvailableDropOffLocationSet'), function(targetCoords)
    client.currentJob.game.drop_off_location = targetCoords
    createDropOffPoint(targetCoords.vehicle_lock)
end)

--[[ Register ]]
Jobs.register(JOB_KEY, job)
