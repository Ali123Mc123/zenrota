local config = Config or {}

local spawnedPeds = {}
local spawnedBlips = {}

local function registerMetadataDisplay()
    if not config.useDisplayMetadata then return end
    if GetResourceState('ox_inventory') ~= 'started' then return end

    local ok, err = pcall(function()
        exports.ox_inventory:displayMetadata({
            name = locale('item_metadata.vehicle_name'),
            plate = locale('item_metadata.plate_number'),
            owner = locale('item_metadata.owner'),
            expires = locale('item_metadata.expires')
        })
    end)

    if not ok then
        lib.print.warn(('Failed to register ox_inventory metadata display: %s'):format(err))
    end
end

local openCounter = nil

-- The rental counter is our own NUI (web/): the list of cars, the hours and the price, recover and return.
local function openRentalMenu(id)
    openCounter = id
    local vehicles = {}
    for _, vehicle in ipairs(config.vehicles[id] or {}) do
        vehicles[#vehicles + 1] = {
            name = vehicle.name,
            description = vehicle.description,
            model = vehicle.model,
            price = vehicle.price,
            image = vehicle.image,
        }
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        vehicles = vehicles,
        min = config.minRentTime,
        max = config.maxRentTime,
        currency = locale('currency.symbol'),
        texts = {
            kicker = locale('ui.kicker'),
            title = locale('rental_menu.title'),
            close = locale('ui.close'),
            vehicles = locale('vehicle_menu.title'),
            perHour = locale('vehicle_menu.per_hour'),
            hours = locale('rental_time_menu.title'),
            hour = locale('ui.hour'),
            total = locale('ui.total'),
            rent = locale('ui.rent'),
            pay = config.moneytype == 'cash' and locale('ui.pay_cash') or locale('ui.pay_bank'),
            recover = locale('rental_menu.subtitle_recover_vehicle'),
            recoverDesc = locale('rental_menu.description_recover_vehicle'),
            ['return'] = locale('rental_menu.subtitle_return_vehicle'),
            returnDesc = locale('rental_menu.description_return_vehicle'),
            info = locale('rental_menu.information'),
        },
    })
end

local function closeRentalMenu()
    openCounter = nil
    SetNuiFocus(false, false)
end

RegisterNUICallback('close', function(_, cb)
    closeRentalMenu()
    cb('ok')
end)

RegisterNUICallback('rent', function(data, cb)
    local id = openCounter
    closeRentalMenu()
    cb('ok')
    if not id then return end
    local vehicle = (config.vehicles[id] or {})[tonumber(data.index)]
    if not vehicle then return end
    local hours = math.floor(tonumber(data.hours) or config.minRentTime)
    hours = math.max(config.minRentTime, math.min(config.maxRentTime, hours))
    TriggerServerEvent('fz-rental:rentVehicle', id, vehicle.name, vehicle.model, vehicle.price, hours)
end)

RegisterNUICallback('recover', function(_, cb)
    local id = openCounter
    closeRentalMenu()
    cb('ok')
    if id then TriggerServerEvent('fz-rental:recoverVehicle', id) end
end)

RegisterNUICallback('return', function(_, cb)
    closeRentalMenu()
    cb('ok')
    TriggerServerEvent('fz-rental:returnVehicle')
end)


RegisterNetEvent('fz-rental:notify', function(message, type)
    lib.notify({
        description = message,
        type = type,
        duration = 5000
    })
end)

local function setFuelFull(vehicle)
    if not DoesEntityExist(vehicle) then
        lib.print.error('Vehicle does not exist')
        return
    end
    if config.fuelSystem == 'ox_fuel' then
        Entity(vehicle).state.fuel = 100.0
    elseif config.fuelSystem == 'savana-fuel' then
        exports["savana-fuel"]:SetFuel(vehicle, 100)
    else
        lib.print.error('Invalid fuel system, supports only ox_fuel or savana-fuel')
        return
    end
end

RegisterNetEvent('fz-rental:spawnVehicle', function(id, name, model, rentalduration)
    local pedId = config.peds[id]
    local playerPed = PlayerPedId()
    local coords = pedId.spawncoords
    local modelHash = GetHashKey(model)
    if not IsModelValid(modelHash) then
        lib.print.error('Invalid vehicle model: ' .. model)
        return
    end
    lib.requestModel(modelHash, 10000)
    pcall(function() exports['FeloxAC']:CreateVehicle(modelHash) end) --[[FeloxAC:auto]]
    local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, coords.w, true, false)
    setFuelFull(vehicle)
    SetPedIntoVehicle(playerPed, vehicle, -1)
    local plate = GetVehicleNumberPlateText(vehicle)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local timeout = GetGameTimer() + 5000
    while not NetworkDoesEntityExistWithNetworkId(netId) do
        if GetGameTimer() > timeout then
            lib.print.error('Vehicle failed to register with server')
            return
        end
        Wait(50)
    end
    TriggerServerEvent('fz-rental:giveKeys', plate)
    TriggerServerEvent('fz-rental:giveRentalPapers', netId, name, model, plate, rentalduration)
end)

RegisterNetEvent('fz-rental:spawnRecoveredVehicle', function(id, name, model, plate, rentalduration)
    local pedId = config.peds[id]
    local playerPed = PlayerPedId()
    local coords = pedId.spawncoords
    local modelHash = GetHashKey(model)
    if not IsModelValid(modelHash) then
        lib.print.error('Invalid vehicle model: ' .. model)
        return
    end
    lib.requestModel(modelHash, 10000)
    pcall(function() exports['FeloxAC']:CreateVehicle(modelHash) end) --[[FeloxAC:auto]]
    local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, coords.w, true, false)
    setFuelFull(vehicle)
    SetPedIntoVehicle(playerPed, vehicle, -1)
    pcall(function() exports['FeloxAC']:ChangeVehiclePlate(vehicle, plate) end) --[[FeloxAC:auto]]
    SetVehicleNumberPlateText(vehicle, plate)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local timeout = GetGameTimer() + 5000
    while not NetworkDoesEntityExistWithNetworkId(netId) do
        if GetGameTimer() > timeout then
            lib.print.error('Vehicle failed to register with server')
            return
        end
        Wait(50)
    end
    -- Server'daki netId'yi güncelle — iade ve kilit sorununu önler
    TriggerServerEvent('fz-rental:updateVehicleNetId', netId)
    TriggerServerEvent('fz-rental:giveKeys', plate)
    TriggerEvent('fz-rental:notify', locale('success.vehicle_recovered'), 'success')
end)

local function spawnPeds()
    for id, current in pairs(config.peds) do
        lib.requestModel(current.model, 10000)
        pcall(function() exports['FeloxAC']:CreatePed(current.model) end) --[[FeloxAC:auto]]
        local ped = CreatePed(0, current.model, current.coords.x, current.coords.y, current.coords.z, current.coords.w, false, false)
        SetModelAsNoLongerNeeded(current.model)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, current.scenario, 0, true)
        table.insert(spawnedPeds, ped)
        if config.useTarget then
            exports.ox_target:addLocalEntity(ped, {{
                name = 'open_rental' .. id,
                icon = 'fa-solid fa-car',
                label = locale('info.open_rental_target'),
                distance = 1.5,
                debug = false,
                onSelect = function()
                    openRentalMenu(id)
                end
            }})
        else
            local options = current.zoneOptions
            if options then
                lib.zones.box({
                    name = 'rental_zone_' .. id,
                    coords = current.coords.xyz,
                    size = vec3(2, 2, 3),
                    rotation = current.coords.w,
                    debug = options.debugPoly,
                    onEnter = function()
                        lib.showTextUI(locale('info.open_rental_textui'))
                    end,
                    onExit = function()
                        lib.hideTextUI()
                    end,
                    inside = function()
                        if IsControlJustPressed(0, config.keybind) then
                            openRentalMenu(id)
                            lib.hideTextUI()
                        end
                    end,
                })
            end
        end
    end
end

local function deletePeds()
    for _, ped in ipairs(spawnedPeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end

local function spawnBlips()
    if config.useBlips then
        for _, pedData in pairs(config.peds) do
            local blip = AddBlipForCoord(pedData.coords.x, pedData.coords.y, pedData.coords.z)
            SetBlipSprite(blip, pedData.blip and pedData.blip.sprite or 1)
            SetBlipDisplay(blip, pedData.blip and pedData.blip.display or 4)
            SetBlipScale(blip, pedData.blip and pedData.blip.scale or 1.0)
            SetBlipColour(blip, pedData.blip and pedData.blip.colour or 1)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(pedData.blip.label)
            EndTextCommandSetBlipName(blip)
            table.insert(spawnedBlips, blip)
        end
    end
end

local function deleteBlips()
    for _, blip in ipairs(spawnedBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    registerMetadataDisplay()
    spawnPeds()
    spawnBlips()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    registerMetadataDisplay()
    spawnPeds()
    spawnBlips()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    deleteBlips()
    deletePeds()
    if openCounter then
        SendNUIMessage({ action = 'close' })
        closeRentalMenu()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    deletePeds()
    deleteBlips()
    if openCounter then closeRentalMenu() end
end)