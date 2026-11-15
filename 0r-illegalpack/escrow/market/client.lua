local data_market_items = lib.load('escrow.market.config')

local Utils = require 'modules.utils.client'
local Target = require 'modules.target.client'

--[[ state ]]

Market = {}

local orderDroneObjectNetId = nil
local orderBagObjectNetId = nil

--[[ functions ]]

local function deleteDroneObject()
    if orderDroneObjectNetId then
        local orderDroneObject = NetToObj(orderDroneObjectNetId)
        if orderDroneObject and DoesEntityExist(orderDroneObject) then
            DeleteEntity(orderDroneObject)
            SetEntityAsNoLongerNeeded(orderDroneObject)
        end
    end
    orderDroneObjectNetId = nil
end

local function deleteBagObject()
    if orderBagObjectNetId then
        local orderBagObject = NetToObj(orderBagObjectNetId)
        if orderBagObject and DoesEntityExist(orderBagObject) then
            DeleteEntity(orderBagObject)
            SetEntityAsNoLongerNeeded(orderBagObject)
        end
    end
    orderBagObjectNetId = nil
end

local function dropLootableBag()
    local function getBagObject()
        return lib.waitFor(function()
            if orderBagObjectNetId then
                local obj = NetToObj(orderBagObjectNetId)
                if obj and DoesEntityExist(obj) then
                    return obj
                end
            end
        end, false, false)
    end

    local orderBagObject = getBagObject()
    if not orderBagObject then return end
    FreezeEntityPosition(orderBagObject, false)
    DetachEntity(orderBagObject, true, true)
    SetEntityDynamic(orderBagObject, true)
    ActivatePhysics(orderBagObject)

    Target.addLocalEntity(orderBagObject, { {
        label = locale('market.collect'),
        icon = 'fa-solid fa-briefcase',
        distance = 2.0,
        onSelect = function()
            lib.playAnim(cache.ped, 'pickup_object', 'pickup_low')
            lib.callback.await(_e('server:market:collectLootableBag'), false)
            Citizen.Wait(1000)
            deleteBagObject()
        end,
    } })
end

Market.onUnload = function()
    deleteBagObject()
    deleteDroneObject()
end

Market.getDataItems = function()
    return data_market_items
end

--[[ events ]]

RegisterNUICallback('nui:market:payCart', function(data, resultCallback)
    -- local response = lib.callback.await(_e('server:market:payCart'), false, data)
    -- if response.error then
    --     client.sendReactAlert(response.error, 'error')
    --     return resultCallback(false)
    -- end
    -- client.sendReactAlert(locale('market.order_delivered'), 'success')
    -- client.hideUI()
    -- resultCallback(response.pendingDelivery)
    Utils.notify('illegal işlerde kullanılan malzemeleri temin edebilmek için blackmarket ile iletişime geçin.', 'error')
    resultCallback(false)
end)

RegisterNetEvent(_e('client:market:spawnDeliveryDrone'), function(data)
    if not lib.callback.await(_e('server:market:getPlayerDelivery'), false) then
        return
    end

    local playerPed = cache.ped
    local playerCoords = GetEntityCoords(playerPed)
    local spawnRadius = 50.0
    local spawnAngle = math.rad(math.random(0, 360))
    local spawnPos = vector3(
        playerCoords.x + math.cos(spawnAngle) * spawnRadius,
        playerCoords.y + math.sin(spawnAngle) * spawnRadius,
        playerCoords.z + 10.0
    )

    local droneModel = Config.DroneDelivery.objectModel
    local bagModel = Config.DroneDelivery.bagModel
    local drone = Utils.createObject(droneModel, spawnPos, nil, true, true, false)

    orderDroneObjectNetId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(drone) then
            NetworkRegisterEntityAsNetworked(drone)
        else
            local netId = ObjToNet(drone)
            if NetworkDoesNetworkIdExist(netId) then
                return netId
            end
        end
    end, false, false)

    SetEntityAsMissionEntity(drone, true, true)

    Utils.addBlip(drone, Config.DroneDelivery.blip)

    local bag = Utils.createObject(bagModel, spawnPos, nil, true, true, false)

    orderBagObjectNetId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(bag) then
            NetworkRegisterEntityAsNetworked(bag)
        else
            local netId = ObjToNet(bag)
            if NetworkDoesNetworkIdExist(netId) then
                return netId
            end
        end
    end, false, false)

    SetEntityAsMissionEntity(bag, true, true)

    AttachEntityToEntity(bag, drone, 0, 0.0, 0.0, -0.5, 0.0, 0.0, 0.0, false, false, false, false, 2, true)

    Citizen.CreateThread(function()
        local moveSpeed = 3.5
        local reachedTarget = false

        while orderDroneObjectNetId and not reachedTarget do
            local drone = NetToObj(orderDroneObjectNetId)
            if not drone or not DoesEntityExist(drone) then
                Citizen.Wait(100)
                goto continue
            end

            local droneCoords = GetEntityCoords(drone)
            local playerCoords = GetEntityCoords(cache.ped)
            local distanceToPlayer = #(playerCoords - droneCoords)

            if distanceToPlayer < 5.0 then
                reachedTarget = true
                break
            end

            local targetPos = vector3(playerCoords.x, playerCoords.y, playerCoords.z + 4.0)
            local direction = targetPos - droneCoords
            local moveVector = direction / #direction * moveSpeed * 0.02
            SetEntityCoords(drone, droneCoords + moveVector, false, false, false, true)

            Citizen.Wait(0)
            ::continue::
        end

        Citizen.Wait(3000)
        dropLootableBag()
        client.sendReactMessage('ui:setOrderInfo', nil)
        Citizen.Wait(1000)
        deleteDroneObject()
    end)
end)
