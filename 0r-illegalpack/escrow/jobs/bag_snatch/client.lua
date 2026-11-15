local Utils = require 'modules.utils.client'
local Target = require 'modules.target.client'
local lib = lib

-- Constants

local JOB_KEY = 'bag_snatch'
local config = lib.load(('escrow.jobs.%s.config'):format(JOB_KEY))

local job = {}

local state = {
    vehicleBoxZones = {},
    parkingLotBlip = nil,
    parkingLotPoint = nil,
    deliveryNpc = {
        netId = nil,
        entity = nil,
        zone = nil,
        blip = nil,
        point = nil
    },
    bags = {},        -- { [index] = bag }
    vehicleBlips = {} -- { [index] = blip }
}

local function deleteVehicleBoxZones()
    for _, zoneName in pairs(state.vehicleBoxZones) do
        if zoneName then
            Target.removeZone(zoneName)
        end
    end
    state.vehicleBoxZones = {}
end

local function deleteSpawnedDeliveryNPC()
    local deliveryZone = state.deliveryNpc.zone
    local deliveryBlip = state.deliveryNpc.blip

    if deliveryZone then
        Target.removeZone(deliveryZone)
    end

    if deliveryBlip and DoesBlipExist(deliveryBlip) then
        RemoveBlip(deliveryBlip)
    end

    if state.deliveryNpc.point then
        state.deliveryNpc.point:remove()
        state.deliveryNpc.point = nil
    end

    state.deliveryNpc = {}
end

local function deleteSpawnedBags()
    for _, v in pairs(state.bags) do
        if v and DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
    state.bags = {}
end

local function removeParkingLotBlip()
    if state.parkingLotBlip and DoesBlipExist(state.parkingLotBlip) then
        RemoveBlip(state.parkingLotBlip)
    end
    state.parkingLotBlip = nil
end

local function removeParkingVehiclesBlip()
    for _, v in pairs(state.vehicleBlips) do
        if v and DoesBlipExist(v) then
            RemoveBlip(v)
        end
    end
    state.vehicleBlips = {}
end

local function spawnGroundBag(coords)
    local model = config.game.bagObjects[1].model
    local bag = Utils.createObject(model, coords, false, false, true, false)
    SetEntityHeading(bag, (GetEntityHeading(cache.ped) + 180.0) % 360)
    PlaceObjectOnGroundProperly(bag)
    return bag
end

local function playRummageAnimation()
    local ped = cache.ped
    local dict = 'amb@world_human_bum_wash@male@low@idle_a'
    local anim = 'idle_c'
    lib.playAnim(ped, dict, anim)
    local success = Utils.progressBar({
        duration = 4000,
        label = locale('progress'),
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

    ClearPedTasks(ped)
    if not success then return false end

    return true
end

-- Add a blip for a vehicle at the specified coordinates
function job.addVehicleBlip(index, coords)
    local blip = Utils.addBlip(coords, config.blips.parking_lot)
    state.vehicleBlips[index] = blip
    return blip
end

-- Delete bag associated with a vehicle
function job.deleteBagInVehicle(index, vehicle)
    local bag = state.bags[index]
    if DoesEntityExist(bag) then
        DeleteEntity(bag)
    end
    state.bags[index] = false
end

function job.spawnBagOnVehicle(vehicle, coords)
    local bagData = config.game.bagObjects[math.random(#config.game.bagObjects)]
    local bagCoords = vector3(bagData.offset.x, bagData.offset.y, bagData.offset.z)

    local bag = Utils.createObject(bagData.model, coords, nil, true, false, false)
    local exist = lib.waitFor(function()
        if DoesEntityExist(bag) then
            return bag
        end
    end, nil, 10000)
    if not exist then
        return false
    end

    SetEntityCollision(bag, false, false)

    AttachEntityToEntity(bag, vehicle, GetEntityBoneIndexByName(vehicle, 'seat_pside_f'), bagCoords.x, bagCoords.y,
        bagCoords.z, bagData.rotation.x, bagData.rotation.y, bagData.rotation.z, false, false, false, false, 2, true)

    table.insert(state.bags, bag)
    return true
end

-- Add target interaction for smashing a vehicle window
function job.addWindowSmashTarget(vehicle, netId, index)
    local boneIndex = GetEntityBoneIndexByName(vehicle, 'window_rf')
    local bonePos = GetWorldPositionOfEntityBone(vehicle, boneIndex)

    if boneIndex == -1 or not bonePos then
        -- fallback to left front door position
        bonePos = GetOffsetFromEntityInWorldCoords(vehicle, 0.9, 0.5, 0.5)
    end

    local zoneName = ('bag_snatch_smash_zone_%s'):format(index)
    state.vehicleBoxZones[index] = zoneName

    Target.addBoxZone(zoneName, {
        coords = bonePos,
        name = zoneKey,
        size = vector3(1.0, 1.0, 1.5),
        debug = false,
        options = { {
            label = locale('bag_snatch.smash_window') .. ' #' .. index,
            icon = 'fa-solid fa-briefcase',
            distance = 1.5,
            canInteract = function()
                return client.currentJob and client.currentJob.steps[2].done ~= true
            end,
            onSelect = function()
                local playerPed = cache.ped
                local vehicle = lib.getClosestVehicle(GetEntityCoords(playerPed), 2.0)
                if not vehicle then
                    return Utils.notify(locale('no_vehicle_nearby'), 'error')
                end

                if GetSelectedPedWeapon(playerPed) ~= GetHashKey('weapon_crowbar') then
                    return Utils.notify(locale('you_do_not_have_required_items', 'Weapon Crowbar'), 'error')
                end

                if not Utils.checkSkill(config.game.skillCheck, 'smash_window') then return end

                local response = lib.callback.await(_e('server:jobs:bag_snatch:canWindowSmash'),
                    false, client.lobby.id, index)
                if not response then return end
                if response.error then
                    if response.remove then
                        Target.removeZone(zoneName)
                        state.vehicleBoxZones[index] = nil
                        if state.vehicleBlips[index] then
                            RemoveBlip(state.vehicleBlips[index])
                            state.vehicleBlips[index] = nil
                        end
                    end
                    return Utils.notify(response.error, 'error')
                end

                Target.removeZone(zoneName)
                state.vehicleBoxZones[index] = nil
                if state.vehicleBlips[index] then
                    RemoveBlip(state.vehicleBlips[index])
                    state.vehicleBlips[index] = nil
                end

                if math.random() <= config.game.police_alert_chance then
                    Utils.triggerPoliceAlert('smashed_window', locale("smashed_window"))
                end

                lib.playAnim(playerPed, 'anim@veh@plane@dodo@ds@enter_exit', 'd_force_entry')
                Citizen.Wait(800)
                SmashVehicleWindow(vehicle, 1)
                PlaySoundFromEntity(-1, 'GLASS_SMASH', vehicle, 0, false, 0)
                Citizen.Wait(1000)
                ClearPedTasks(playerPed)

                job.deleteBagInVehicle(index, vehicle)
                lib.callback.await(_e('server:jobs:bag_snatch:onWindowSmash'), false, client.lobby.id, index, netId)
            end
        } }
    })
end

function job.handleVehiclesNetId(netIds)
    if not netIds or
        not client.currentJob or
        not client.currentJob.game or
        not client.currentJob.game.parking_lot
    then
        return
    end

    local parkingLotPlaces = client.currentJob.game.parking_lot.places

    for index, netId in pairs(netIds) do
        local coords = parkingLotPlaces[index]
        local vehicle = lib.waitFor(function()
            if NetworkDoesEntityExistWithNetworkId(netId) then
                return NetToVeh(netId)
            end
        end, false, false)
        if vehicle then
            SetEntityInvincible(vehicle, true)
            SetVehicleDoorsLocked(vehicle, 2)
            SetVehicleDoorsLockedForAllPlayers(vehicle, true)
            PlaceObjectOnGroundProperly(vehicle)
            if coords then
                job.addVehicleBlip(index, coords)
                job.addWindowSmashTarget(vehicle, netId, index)
                job.spawnBagOnVehicle(vehicle, coords)
            end
        end
    end
end

function job.cleanup()
    removeParkingLotBlip()
    removeParkingVehiclesBlip()
    deleteSpawnedBags()
    deleteSpawnedDeliveryNPC()
    deleteVehicleBoxZones()

    if state.parkingLotPoint then
        state.parkingLotPoint:remove()
        state.parkingLotPoint = nil
    end

    if state.deliveryNpc.point then
        state.deliveryNpc.point:remove()
        state.deliveryNpc.point = nil
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
    local isOwner = client.lobby.owner == cache.serverId
    if stepIndex <= 1 then
        state.parkingLotBlip = Utils.addBlip(client.currentJob.game.parking_lot.center, config.blips.parking_lot, true)

        if isOwner then
            state.parkingLotPoint = lib.points.new({
                coords = client.currentJob.game.parking_lot.center,
                distance = client.currentJob.game.parking_lot.distance,
                onEnter = function(self)
                    self:remove()
                    state.parkingLotPoint = nil
                    lib.callback.await(_e('server:jobs:onStepDone'), false, client.lobby.id, 1)
                end
            })
        end

        return true
    elseif stepIndex == 2 then
        if isOwner then
            local response = lib.callback.await(_e('server:jobs:bag_snatch:spawnVehicles'), false, client.lobby.id)
            if not response then
                return false
            end
        end
        return true
    end

    Utils.notify(locale('jobs.job_done'), 'success')
    if isOwner then
        lib.callback.await(_e('server:jobs:finishJob'), false, client.lobby.id)
    end

    return false
end

function job.onStepDone(stepIndex)
    if stepIndex == 1 then
        removeParkingLotBlip()
    elseif stepIndex == 2 then
        deleteSpawnedBags()
        removeParkingVehiclesBlip()
        deleteVehicleBoxZones()
    end

    return job.onStepStart(stepIndex + 1)
end

-- Events

RegisterNetEvent(_e('client:jobs:bag_snatch:onWindowSmashed'), function(windowIndex, netId)
    if not NetworkDoesEntityExistWithNetworkId(netId) then
        return
    end
    local vehicle = NetToVeh(netId)
    if DoesEntityExist(vehicle) then
        SmashVehicleWindow(vehicle, 1)
        PlaySoundFromEntity(-1, 'GLASS_SMASH', vehicle, 0, false, 0)
    end
    if DoesBlipExist(state.vehicleBlips[windowIndex]) then
        RemoveBlip(state.vehicleBlips[windowIndex])
    end
    state.vehicleBlips[windowIndex] = false

    if state.vehicleBoxZones[windowIndex] then
        Target.removeZone(state.vehicleBoxZones[windowIndex])
    end

    job.deleteBagInVehicle(windowIndex, vehicle)
end)

lib.callback.register(_e('client:jobs:bag_snatch:onStolenBagOpen'), function()
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    local forwardCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.7, 0.0)

    local bag = spawnGroundBag(forwardCoords)
    if not playRummageAnimation() then return false end
    DeleteEntity(bag)

    return true
end)

RegisterNetEvent(_e('client:jobs:bag_snatch:setVehiclesNetId'), function(netIds)
    Citizen.CreateThread(function()
        job.handleVehiclesNetId(netIds)
    end)
end)

-- Initialize and register the job
Jobs.register(JOB_KEY, job)
