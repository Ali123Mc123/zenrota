currentZone = nil
myIdentifier = nil
menuOpened = false
ownedCache = {}
currentJob = nil
isFueling = false
totalFilled = 0

function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if scale < 0.5 then
        scale = 0.5
    end

    if onScreen then
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function HandleManagementZone(managementCoords)
    managementCoords = vector3(managementCoords.x, managementCoords.y, managementCoords.z)
    if currentZone == nil then return end
    if menuOpened then return end

    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local distance = #(playerCoords - managementCoords)

    if not myIdentifier then
        myIdentifier = Framework:GetIdentifier()
    end

    if ownedCache[currentZone] and ownedCache[currentZone].owned then
        if ownedCache[currentZone].identifier == myIdentifier then
            if distance < 18.0 then
                DrawMarker(1, managementCoords.x, managementCoords.y, managementCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    0.0, 1.5, 1.5, 0.5, 255, 255, 0, 100, false, true, 2, true, nil, nil, false)
                if distance < 1.5 then
                    Draw3DText(managementCoords.x, managementCoords.y, managementCoords.z + 0.4,
                        Config.Strings.Management)
                    if IsControlJustReleased(0, 38) then
                        ownedCache[currentZone] = lib.callback.await('savana-fuel:server:getStationOwnedInfo', false,
                            currentZone)
                        if ownedCache[currentZone] and ownedCache[currentZone].identifier == myIdentifier then
                            OpenManagementMenu()
                        end
                    end
                end
            end
        end
    else
        if distance < 18.0 then
            DrawMarker(1, managementCoords.x, managementCoords.y, managementCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                1.5, 1.5, 0.5, 255, 255, 0, 100, false, true, 2, true, nil, nil, false)
            if distance < 1.5 then
                Draw3DText(managementCoords.x, managementCoords.y, managementCoords.z + 0.4, Config.Strings.Buystation)
                if IsControlJustReleased(0, 38) then
                    ownedCache[currentZone] = lib.callback.await('savana-fuel:server:getStationOwnedInfo', false,
                        currentZone)
                    if not ownedCache[currentZone].owned then
                        OpenBuyMenu()
                    end
                end
            end
        end
    end
end

function HandleJobListZone(jobListCoords)
    jobListCoords = vector3(jobListCoords.x, jobListCoords.y, jobListCoords.z)
    if currentZone == nil then return end
    if menuOpened then return end

    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local distance = #(playerCoords - jobListCoords)

    if ownedCache[currentZone] and ownedCache[currentZone].owned then
        if distance < 18.0 then
            DrawMarker(1, jobListCoords.x, jobListCoords.y, jobListCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5,
                0.5, 255, 255, 0, 100, false, true, 2, true, nil, nil, false)
            if distance < 1.5 then
                Draw3DText(jobListCoords.x, jobListCoords.y, jobListCoords.z + 0.4, Config.Strings.Joblist)
                if IsControlJustReleased(0, 38) then
                    ownedCache[currentZone] = lib.callback.await('savana-fuel:server:getStationOwnedInfo', false,
                        currentZone)
                    if ownedCache[currentZone] and ownedCache[currentZone].owned then
                        OpenJobListMenu()
                    end
                end
            end
        end
    end
end

RegisterNetEvent('savana-fuel:client:syncCache', function(cache)
    ownedCache = cache
end)

function OpenBuyMenu()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openBuyStationMenu",
        stationPrice = Config.GasStations[currentZone].price,
        stationId = currentZone,
        scriptName = GetCurrentResourceName()
    })
    menuOpened = true
end

function OpenJobListMenu()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openJobListMenu",
        stationInfo = lib.callback.await('savana-fuel:server:getStationInfo', false, currentZone),
        scriptName = GetCurrentResourceName()
    })
    menuOpened = true
end

local function getTruckCapacityPercent(level)
    level = tonumber(level) or 0
    if level <= 0 then return 0 end
    local capConfig = Config.UpgradePrice and Config.UpgradePrice["TruckCapacity"]
    if not capConfig then return 0 end
    local lvlStr = tostring(math.min(level, 5))
    local item = capConfig[lvlStr] or capConfig["5"]
    return (item and tonumber(item.value)) or 0
end

local function getRelationshipDiscountPercent(level)
    level = tonumber(level) or 0
    if level <= 0 then return 0 end
    local relConfig = Config.UpgradePrice and Config.UpgradePrice["Relationship"]
    if not relConfig then return 0 end
    local lvlStr = tostring(math.min(level, 5))
    local item = relConfig[lvlStr] or relConfig["5"]
    return (item and tonumber(item.value)) or 0
end

function OpenManagementMenu()
    local stationInfo = lib.callback.await('savana-fuel:server:getStationInfo', false, currentZone)

    local PackagePrices = {}

    for k, v in pairs(Config.ReFuelPrices) do
        PackagePrices[k] = { import = v.import, export = v.export, fuel = v.fuel }
    end

    if stationInfo and (tonumber(stationInfo.truckCapacityLevel) or 0) > 0 then
        local capPercent = getTruckCapacityPercent(stationInfo.truckCapacityLevel)
        local getPercent = capPercent + 100

        for k, v in pairs(PackagePrices) do
            PackagePrices[k].import = v.import * getPercent / 100
            PackagePrices[k].export = v.export * getPercent / 100
            PackagePrices[k].fuel = v.fuel * getPercent / 100
        end
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openManagementMenu",
        stationId = currentZone,
        scriptName = GetCurrentResourceName(),
        UpgradePrice = Config.UpgradePrice,
        stationInfo = stationInfo,
        DefaultCapacity = Config.DefaultFuelInventoryCapacity,
        MaxGasPrice = Config.MaxGasPrice,
        ReFuelPrices = PackagePrices
    })
    menuOpened = true
end

function OpenFuelMenu(vehicle)
    if not currentZone or not Config.GasStations[currentZone] then
        Framework:Notify(Config.Strings.onlyStationPump, "error")
        return
    end

    local stationInfo = lib.callback.await('savana-fuel:server:getStationInfo', false, currentZone)
    local veh = NetToVeh(vehicle)

    totalFilled = 0
    isFueling = false

    if not stationInfo then
        stationInfo = {}
        stationInfo = {
            fuelStock = Config.DefaultFuelInventoryCapacity,
            fuelPrice = Config.DefaultGasPrice
        }
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openFuelMenu",
        scriptName = GetCurrentResourceName(),
        fuelInVehicle = GetFuel(veh),
        vehicle = VehToNet(veh),
        stationInfo = stationInfo
    })
    menuOpened = true

    local response = lib.callback.await('savana-fuel:server:addVisitor', false, currentZone)
end

function createJob(jobInfo)
    local stationId = currentZone
    if not stationId or not Config.GasStations[stationId] then
        Framework:Notify("İstasyon verisi bulunamadı.", "error")
        return
    end
    local currentStation = Config.GasStations[stationId]

    local trailerVeh = Framework:SpawnVehicle(Config.TrailerModel, currentStation.trailerCoord)
    local truckVeh = Framework:SpawnFrameworkVehicle(Config.TruckModel, currentStation.truckCoord)

    local deliveryLocation = Config.DeliveryLocations[math.random(1, #Config.DeliveryLocations)]

    local blipDelivery = AddBlipForCoord(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
    SetBlipSprite(blipDelivery, 1)
    SetBlipColour(blipDelivery, 5)
    SetBlipScale(blipDelivery, 0.8)
    SetBlipAsShortRange(blipDelivery, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Teslimat Noktası")
    EndTextCommandSetBlipName(blipDelivery)

    SetNewWaypoint(deliveryLocation.x, deliveryLocation.y)

    Framework:Notify(Config.Strings.newJob, "success")

    currentJob = true

    local status = "waiting"
    local canContinue = true
    local distanceTraveled = 0
    local cachedTruckCoords = GetEntityCoords(truckVeh)

    while true do
        sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())

        distanceTraveled = distanceTraveled + #(cachedTruckCoords - GetEntityCoords(truckVeh))
        cachedTruckCoords = GetEntityCoords(truckVeh)

        canContinue = true

        local truckCoords = GetEntityCoords(truckVeh)
        local distance = #(playerCoords - truckCoords)

        if distance > 10.0 then
            Framework:Notify(Config.Strings.getBackTruck, "error")
            canContinue = false
            sleep = 3500
        end

        local trailerCoords = GetEntityCoords(trailerVeh)
        local distance = #(playerCoords - trailerCoords)

        if distance > 10.0 then
            Framework:Notify(Config.Strings.attachTrailer, "error")
            canContinue = false
            sleep = 3500
        end

        if canContinue then
            local distance = #(playerCoords - deliveryLocation)

            if distance < 100.0 and status == "waiting" then
                sleep = 0

                if distance < 30.0 then
                    Draw3DText(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z + 0.4, Config.Strings.loadFuel)
                end

                DrawMarker(1, deliveryLocation.x, deliveryLocation.y, deliveryLocation.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0,
                    0.0, 5.0, 5.0, 0.5, 255, 255, 0, 100, false, true, 2, true, nil, nil, false)
            end

            if distance < 5.0 and status == "waiting" then
                if IsControlJustReleased(0, 38) then
                    status = "delivered"
                    Framework:Notify(Config.Strings.goBackStation, "success")
                    RemoveBlip(blipDelivery)
                    SetNewWaypoint(currentStation.truckCoord.x, currentStation.truckCoord.y)
                end
            end

            if status == "delivered" then
                local truckCoords = GetEntityCoords(truckVeh)
                local distance = #(truckCoords - vector3(currentStation.truckCoord.x, currentStation.truckCoord.y, currentStation.truckCoord.z))

                if distance < 100.0 then
                    sleep = 0

                    if distance < 30.0 then
                        Draw3DText(currentStation.truckCoord.x, currentStation.truckCoord.y,
                            currentStation.truckCoord.z + 0.4, Config.Strings.importMarker)
                    end

                    DrawMarker(1, currentStation.truckCoord.x, currentStation.truckCoord.y,
                        currentStation.truckCoord.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 0.5, 255, 255, 0, 100,
                        false, true, 2, true, nil, nil, false)
                end

                if distance < 5.0 then
                    if IsControlJustReleased(0, 38) then
                        Framework:Notify(Config.Strings.delivered, "success")
                        status = "completed"
                        break
                    end
                end
            end
        end

        Wait(sleep)
    end

    if status == "completed" then
        local response = lib.callback.await('savana-fuel:server:addFuelToStation', false, stationId, jobInfo,
            distanceTraveled)
        DeleteVehicle(truckVeh)
        DeleteVehicle(trailerVeh)
        local response = lib.callback.await('savana-fuel:server:jobReward', false, jobInfo)
        Framework:Notify("" .. Config.Strings.completed .. "" .. jobInfo.reward, "success")
    end

    currentJob = nil
end

function createImportJob(packageInfo)
    local stationId = currentZone
    if not stationId or not Config.GasStations[stationId] then
        Framework:Notify("İstasyon verisi bulunamadı.", "error")
        return
    end
    local currentStation = Config.GasStations[stationId]

    local trailerVeh = Framework:SpawnVehicle(Config.TrailerModel, currentStation.trailerCoord)
    local truckVeh = Framework:SpawnFrameworkVehicle(Config.TruckModel, currentStation.truckCoord)

    local deliveryLocation = Config.DeliveryLocations[math.random(1, #Config.DeliveryLocations)]

    local blipDelivery = AddBlipForCoord(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
    SetBlipSprite(blipDelivery, 1)
    SetBlipColour(blipDelivery, 5)
    SetBlipScale(blipDelivery, 0.8)
    SetBlipAsShortRange(blipDelivery, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Teslimat Noktası")
    EndTextCommandSetBlipName(blipDelivery)

    SetNewWaypoint(deliveryLocation.x, deliveryLocation.y)

    Framework:Notify(Config.Strings.newJob, "success")

    currentJob = true

    local status = "waiting"
    local canContinue = true
    local distanceTraveled = 0
    local cachedTruckCoords = GetEntityCoords(truckVeh)

    while true do
        sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())

        distanceTraveled = distanceTraveled + #(cachedTruckCoords - GetEntityCoords(truckVeh))
        cachedTruckCoords = GetEntityCoords(truckVeh)

        canContinue = true

        local truckCoords = GetEntityCoords(truckVeh)
        local distance = #(playerCoords - truckCoords)

        if distance > 10.0 then
            Framework:Notify(Config.Strings.getBackTruck, "error")
            canContinue = false
            sleep = 3500
        end

        local trailerCoords = GetEntityCoords(trailerVeh)
        local distance = #(playerCoords - trailerCoords)

        if distance > 10.0 then
            Framework:Notify(Config.Strings.attachTrailer, "error")
            canContinue = false
            sleep = 3500
        end

        if canContinue then
            local distance = #(playerCoords - deliveryLocation)

            if distance < 100.0 and status == "waiting" then
                sleep = 0

                if distance < 30.0 then
                    Draw3DText(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z + 0.4, Config.Strings.loadFuel)
                end

                DrawMarker(1, deliveryLocation.x, deliveryLocation.y, deliveryLocation.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0,
                    0.0, 5.0, 5.0, 0.5, 255, 255, 0, 100, false, true, 2, true, nil, nil, false)
            end

            if distance < 5.0 and status == "waiting" then
                if IsControlJustReleased(0, 38) then
                    status = "delivered"
                    Framework:Notify(Config.Strings.goBackStation, "success")
                    RemoveBlip(blipDelivery)
                    SetNewWaypoint(currentStation.truckCoord.x, currentStation.truckCoord.y)
                end
            end

            if status == "delivered" then
                local truckCoords = GetEntityCoords(truckVeh)
                local distance = #(truckCoords - vector3(currentStation.truckCoord.x, currentStation.truckCoord.y, currentStation.truckCoord.z))

                if distance < 100.0 then
                    sleep = 0

                    if distance < 30.0 then
                        Draw3DText(currentStation.truckCoord.x, currentStation.truckCoord.y,
                            currentStation.truckCoord.z + 0.4, Config.Strings.unloadFuel)
                    end

                    DrawMarker(1, currentStation.truckCoord.x, currentStation.truckCoord.y,
                        currentStation.truckCoord.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 0.5, 255, 255, 0, 100,
                        false, true, 2, true, nil, nil, false)
                end

                if distance < 5.0 then
                    if IsControlJustReleased(0, 38) then
                        Framework:Notify(Config.Strings.delivered, "success")
                        status = "completed"
                        break
                    end
                end
            end
        end

        Wait(sleep)
    end

    if status == "completed" then
        local response = lib.callback.await('savana-fuel:server:addFuelToStation', false, stationId, packageInfo,
            distanceTraveled)
        DeleteVehicle(truckVeh)
        DeleteVehicle(trailerVeh)
    end

    currentJob = nil
end

function createExportJob(packageInfo)
    local stationId = currentZone
    if not stationId or not Config.GasStations[stationId] then
        Framework:Notify("İstasyon verisi bulunamadı.", "error")
        return
    end
    local currentStation = Config.GasStations[stationId]

    local trailerVeh = Framework:SpawnVehicle(Config.TrailerModel, currentStation.trailerCoord)
    local truckVeh = Framework:SpawnFrameworkVehicle(Config.TruckModel, currentStation.truckCoord)

    local deliveryLocation = Config.DeliveryLocations[math.random(1, #Config.DeliveryLocations)]

    local blipDelivery = AddBlipForCoord(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
    SetBlipSprite(blipDelivery, 1)
    SetBlipColour(blipDelivery, 5)
    SetBlipScale(blipDelivery, 0.8)
    SetBlipAsShortRange(blipDelivery, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Teslimat Noktası")
    EndTextCommandSetBlipName(blipDelivery)

    SetNewWaypoint(deliveryLocation.x, deliveryLocation.y)

    Framework:Notify(Config.Strings.newJob, "success")

    currentJob = true

    local status = "waiting"
    local canContinue = true
    local distanceTraveled = 0
    local cachedTruckCoords = GetEntityCoords(truckVeh)

    while true do
        sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())

        distanceTraveled = distanceTraveled + #(cachedTruckCoords - GetEntityCoords(truckVeh))
        cachedTruckCoords = GetEntityCoords(truckVeh)

        canContinue = true

        local truckCoords = GetEntityCoords(truckVeh)
        local distance = #(playerCoords - truckCoords)

        if distance > 10.0 then
            Framework:Notify(Config.Strings.getBackTruck, "error")
            canContinue = false
            sleep = 3500
        end

        local trailerCoords = GetEntityCoords(trailerVeh)
        local distance = #(playerCoords - trailerCoords)

        if distance > 10.0 then
            Framework:Notify(Config.Strings.attachTrailer, "error")
            canContinue = false
            sleep = 3500
        end

        if canContinue then
            local distance = #(playerCoords - deliveryLocation)

            if distance < 100.0 and status == "waiting" then
                sleep = 0

                if distance < 30.0 then
                    Draw3DText(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z + 0.4,
                        Config.Strings.exportFuel)
                end

                DrawMarker(1, deliveryLocation.x, deliveryLocation.y, deliveryLocation.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0,
                    0.0, 5.0, 5.0, 0.5, 255, 255, 0, 100, false, true, 2, true, nil, nil, false)
            end

            if distance < 5.0 and status == "waiting" then
                if IsControlJustReleased(0, 38) then
                    status = "delivered"
                    Framework:Notify(Config.Strings.goBackStation, "success")
                    RemoveBlip(blipDelivery)
                    SetNewWaypoint(currentStation.truckCoord.x, currentStation.truckCoord.y)
                end
            end

            if status == "delivered" then
                local truckCoords = GetEntityCoords(truckVeh)
                local distance = #(truckCoords - vector3(currentStation.truckCoord.x, currentStation.truckCoord.y, currentStation.truckCoord.z))

                if distance < 100.0 then
                    sleep = 0

                    if distance < 30.0 then
                        Draw3DText(currentStation.truckCoord.x, currentStation.truckCoord.y,
                            currentStation.truckCoord.z + 0.4, Config.Strings.parkMarker)
                    end
                    DrawMarker(1, currentStation.truckCoord.x, currentStation.truckCoord.y,
                        currentStation.truckCoord.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 0.5, 255, 255, 0, 100,
                        false, true, 2, true, nil, nil, false)
                end

                if distance < 5.0 then
                    if IsControlJustReleased(0, 38) then
                        Framework:Notify(Config.Strings.delivered, "success")
                        status = "completed"
                        break
                    end
                end
            end
        end

        Wait(sleep)
    end

    if status == "completed" then
        local response = lib.callback.await('savana-fuel:server:finishExportJob', false, stationId, packageInfo,
            distanceTraveled)
        DeleteVehicle(truckVeh)
        DeleteVehicle(trailerVeh)
    end

    currentJob = nil
end

RegisterNUICallback('buyStation', function(data, cb)
    local identifier = Framework:GetIdentifier()
    local response = lib.callback.await('savana-fuel:server:buyStation', false, currentZone, identifier)

    if response then
        SetNuiFocus(false, false)
        menuOpened = false
        ownedCache[currentZone] = { owned = true, identifier = identifier }
    end

    cb(response)
end)

RegisterNUICallback('setFuelPrice', function(data, cb)
    local response = lib.callback.await('savana-fuel:server:setFuelPrice', false, currentZone, data.price)
    cb(response)
end)

RegisterNUICallback('deposit', function(data, cb)
    local response = lib.callback.await('savana-fuel:server:deposit', false, currentZone, data.amount)
    cb(response)
    if response then
        SendNUIMessage({
            action = "updateBalance",
            stationInfo = lib.callback.await('savana-fuel:server:getStationInfo', false, currentZone)
        })
    end
end)

RegisterNUICallback('withdraw', function(data, cb)
    local response = lib.callback.await('savana-fuel:server:withdraw', false, currentZone, data.amount)
    cb(response)
    if response then
        SendNUIMessage({
            action = "updateBalance",
            stationInfo = lib.callback.await('savana-fuel:server:getStationInfo', false, currentZone)
        })
    end
end)

RegisterNUICallback('getJob', function(data, cb)
    local truckCoord = Config.GasStations[currentZone].truckCoord
    local trailerCoord = Config.GasStations[currentZone].trailerCoord

    local freeForTruck = IsSpawnPointClear(truckCoord, 5.001)
    local freeForTrailer = IsSpawnPointClear(trailerCoord, 5.001)

    if not freeForTruck or not freeForTrailer then
        Framework:Notify("Araç veya Treyler doğma alanı dolu! Lütfen alanı boşaltın.", "error")
        cb(false)
        return
    end

    local response = lib.callback.await('savana-fuel:server:getJob', false, currentZone, data)

    if response then
        SetNuiFocus(false, false)
        menuOpened = false
    end

    cb(response)

    if response then
        createJob(data.job)
    end
end)

RegisterNUICallback('importFuel', function(data, cb)
    local truckCoord = Config.GasStations[currentZone].truckCoord
    local trailerCoord = Config.GasStations[currentZone].trailerCoord

    local freeForTruck = IsSpawnPointClear(truckCoord, 5.001)
    local freeForTrailer = IsSpawnPointClear(trailerCoord, 5.001)

    if not freeForTruck or not freeForTrailer then
        Framework:Notify("Araç veya Treyler doğma alanı dolu! Lütfen alanı boşaltın.", "error")
        cb(false)
        return
    end

    local stationInfo = lib.callback.await('savana-fuel:server:getStationInfo', false, currentZone)

    local PackagePrices = {}

    for k, v in pairs(Config.ReFuelPrices) do
        PackagePrices[k] = { import = v.import, export = v.export, fuel = v.fuel }
    end

    if stationInfo and (tonumber(stationInfo.truckCapacityLevel) or 0) > 0 then
        local capPercent = getTruckCapacityPercent(stationInfo.truckCapacityLevel)
        local getPercent = capPercent + 100

        for k, v in pairs(PackagePrices) do
            PackagePrices[k].import = v.import * getPercent / 100
            PackagePrices[k].export = v.export * getPercent / 100
            PackagePrices[k].fuel = v.fuel * getPercent / 100
        end
    end

    local response = lib.callback.await('savana-fuel:server:importFuel', false, PackagePrices[data.package], currentZone)

    if response then
        SetNuiFocus(false, false)
        menuOpened = false
    end

    cb(response)
    if response then
        createImportJob(PackagePrices[data.package])
    end
end)

RegisterNUICallback('exportFuel', function(data, cb)
    local truckCoord = Config.GasStations[currentZone].truckCoord
    local trailerCoord = Config.GasStations[currentZone].trailerCoord

    local freeForTruck = IsSpawnPointClear(truckCoord, 5.001)
    local freeForTrailer = IsSpawnPointClear(trailerCoord, 5.001)

    if not freeForTruck or not freeForTrailer then
        Framework:Notify("Araç veya Treyler doğma alanı dolu! Lütfen alanı boşaltın.", "error")
        cb(false)
        return
    end

    local stationInfo = lib.callback.await('savana-fuel:server:getStationInfo', false, currentZone)

    local PackagePrices = {}

    for k, v in pairs(Config.ReFuelPrices) do
        PackagePrices[k] = { import = v.import, export = v.export, fuel = v.fuel }
    end

    if stationInfo and (tonumber(stationInfo.truckCapacityLevel) or 0) > 0 then
        local capPercent = getTruckCapacityPercent(stationInfo.truckCapacityLevel)
        local getPercent = capPercent + 100

        for k, v in pairs(PackagePrices) do
            PackagePrices[k].import = v.import * getPercent / 100
            PackagePrices[k].export = v.export * getPercent / 100
            PackagePrices[k].fuel = v.fuel * getPercent / 100
        end
    end

    local response = lib.callback.await('savana-fuel:server:exportFuel', false, currentZone, PackagePrices[data.package])
    if response then
        SetNuiFocus(false, false)
        menuOpened = false
    end
    cb(response)

    if response then
        createExportJob(PackagePrices[data.package])
    end
end)

RegisterNUICallback('transferStation', function(data, cb)
    local response = lib.callback.await('savana-fuel:server:transferStation', false, currentZone, data.playerId)
    if response then
        SetNuiFocus(false, false)
        menuOpened = false
    end
    cb(response)
    if response then
        ownedCache[currentZone] = lib.callback.await('savana-fuel:server:getStationOwnedInfo', false, currentZone)
    end
end)

RegisterNUICallback('upgradeInventory', function(data, cb)
    local response = lib.callback.await('savana-fuel:server:upgradeInventory', false, currentZone)

    if response then
        OpenManagementMenu()
        cb(true)
    else
        cb(false)
    end
end)

RegisterNUICallback('upgradeTruckCapacity', function(data, cb)
    local response = lib.callback.await('savana-fuel:server:upgradeTruckCapacity', false, currentZone)

    if response then
        OpenManagementMenu()
        cb(true)
    else
        cb(false)
    end
end)

RegisterNUICallback('upgradeRelationship', function(data, cb)
    local response = lib.callback.await('savana-fuel:server:upgradeRelationship', false, currentZone)

    if response then
        OpenManagementMenu()
        cb(true)
    else
        cb(false)
    end
end)

local function getTruckCapacityPercent(level)
    level = tonumber(level) or 0
    if level <= 0 then return 0 end
    local capConfig = Config.UpgradePrice and Config.UpgradePrice["TruckCapacity"]
    if not capConfig then return 0 end
    local lvlStr = tostring(math.min(level, 5))
    local item = capConfig[lvlStr] or capConfig["5"]
    return (item and tonumber(item.value)) or 0
end

local function getRelationshipDiscountPercent(level)
    level = tonumber(level) or 0
    if level <= 0 then return 0 end
    local relConfig = Config.UpgradePrice and Config.UpgradePrice["Relationship"]
    if not relConfig then return 0 end
    local lvlStr = tostring(math.min(level, 5))
    local item = relConfig[lvlStr] or relConfig["5"]
    return (item and tonumber(item.value)) or 0
end

RegisterNUICallback('createJob', function(data, cb)
    local stationInfo = lib.callback.await('savana-fuel:server:getStationInfo', false, currentZone)

    local PackagePrices = {}

    for k, v in pairs(Config.ReFuelPrices) do
        PackagePrices[k] = { import = v.import, export = v.export, fuel = v.fuel }
    end

    if stationInfo and (tonumber(stationInfo.truckCapacityLevel) or 0) > 0 then
        local capPercent = getTruckCapacityPercent(stationInfo.truckCapacityLevel)
        local getPercent = capPercent + 100

        for k, v in pairs(PackagePrices) do
            PackagePrices[k].import = v.import * getPercent / 100
            PackagePrices[k].export = v.export * getPercent / 100
            PackagePrices[k].fuel = v.fuel * getPercent / 100
        end
    end

    local myPackage = PackagePrices[data.package]
    if not myPackage then
        cb(false)
        return
    end

    if stationInfo and (tonumber(stationInfo.relationshipLevel) or 0) > 0 then
        local discountPercent = getRelationshipDiscountPercent(stationInfo.relationshipLevel)
        local price = myPackage.import
        local discount = price * discountPercent / 100

        price = price - discount
        myPackage.import = myPackage.import - discount
    end

    local response = lib.callback.await('savana-fuel:server:createJob', false, currentZone, data.title, data.reward,
        myPackage)

    if response then
        OpenManagementMenu()
    end

    cb(response)
end)

-- cancelJob
RegisterNUICallback('cancelJob', function(data, cb)
    local response = lib.callback.await('savana-fuel:server:cancelJob', false, currentZone, data.jobId)

    if response then
        OpenManagementMenu()
    end
    cb(response)
end)

RegisterNUICallback('startFuel', function(data, cb)
    if not isFueling then
        local ped = PlayerPedId()
        if not HasAnimDictLoaded("timetable@gardener@filling_can") then
            RequestAnimDict("timetable@gardener@filling_can")

            while not HasAnimDictLoaded("timetable@gardener@filling_can") do
                Wait(10)
            end
        end
        TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, false, false,
            false)
        isFueling = true

        while isFueling do
            local veh = NetToVeh(data.vehicle)
            if totalFilled >= data.fuelAmount then
                isFueling = false
                ClearPedTasks(ped)
                RemoveAnimDict("timetable@gardener@filling_can")
                break
            end

            totalFilled = totalFilled + 1

            SendNUIMessage({
                action = "updateFueling",
                fuel = GetFuel(veh) + totalFilled,
                totalFilled = totalFilled,
                fuelPrice = data.pricePerLitre,
            })
            Wait(Config.FuelTickTime)
        end
    end
end)

RegisterNUICallback('stopFuel', function(data, cb)
    if isFueling then
        local ped = PlayerPedId()
        isFueling = false
        ClearPedTasks(ped)
        Wait(1000)
        cb(true)
    else
        Wait(1000)
        cb(false)
    end
end)

RegisterNUICallback('payFuel', function(data, cb)
    local veh = NetToVeh(data.vehicle)
    local response = lib.callback.await('savana-fuel:server:payFuel', false, currentZone, totalFilled)

    cb(response.status)

    if response.status then
        SetFuel(veh, GetFuel(veh) + totalFilled)
        SetNuiFocus(false, false)
        menuOpened = false

        Framework:Notify(
            "" ..
            Config.Strings.paid ..
            " " .. response.totalCost .. " " ..
            Config.Strings.paidFor .. " " .. totalFilled .. " " .. Config.Strings.lFuel .. " ", "success")
    else
        Framework:Notify(response.message, "error")
    end
end)

RegisterNUICallback('close', function(data, cb)
    menuOpened = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNetEvent('savana-fuel:client:syncCache')
AddEventHandler('savana-fuel:client:syncCache', function(_ownedCache)
    ownedCache = _ownedCache
end)

function CreateBlip(coords)
    if not Config.BlipConfig.enabled then return end
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, Config.BlipConfig.sprite)
    SetBlipColour(blip, Config.BlipConfig.color)
    SetBlipScale(blip, Config.BlipConfig.size)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BlipConfig.text)
    EndTextCommandSetBlipName(blip)
    return blip
end

if Config.ShowNearestGasStationOnly then
    Citizen.CreateThread(function()
        local currentGasBlip = 0

        while true do
            local coords = GetEntityCoords(PlayerPedId())
            local closest = 1000
            local closestCoords

            for _, gasStationCoords in pairs(Config.GasStations) do
                if gasStationCoords.management then
                    local dstcheck = GetDistanceBetweenCoords(coords,
                        vector3(gasStationCoords.management.x, gasStationCoords.management.y, gasStationCoords.management.z))

                    if dstcheck < closest then
                        closest = dstcheck
                        closestCoords = vector3(gasStationCoords.management.x, gasStationCoords.management.y,
                            gasStationCoords.management.z)
                    end
                end
            end

            if DoesBlipExist(currentGasBlip) then
                RemoveBlip(currentGasBlip)
            end

            if closestCoords then
                currentGasBlip = CreateBlip(closestCoords)
            end

            Citizen.Wait(10000)
        end
    end)
else
    Citizen.CreateThread(function()
        for _, gasStationCoords in pairs(Config.GasStations) do
            if gasStationCoords.management then
                CreateBlip(vector3(gasStationCoords.management.x, gasStationCoords.management.y,
                    gasStationCoords.management.z))
            end
        end
    end)
end

function FindNearestFuelPump()
    local coords = GetEntityCoords(PlayerPedId())
    local fuelPumps = {}
    local handle, object = FindFirstObject()
    local success

    repeat
        if Config.PumpModels[GetEntityModel(object)] then
            table.insert(fuelPumps, object)
        end

        success, object = FindNextObject(handle, object)
    until not success

    EndFindObject(handle)

    local pumpObject = 0
    local pumpDistance = 1000

    for _, fuelPumpObject in pairs(fuelPumps) do
        local dstcheck = #(coords - GetEntityCoords(fuelPumpObject))

        if dstcheck < pumpDistance then
            pumpDistance = dstcheck
            pumpObject = fuelPumpObject
        end
    end

    return pumpObject, pumpDistance
end

CreateThread(function()
    while true do
        Wait(250)

        local pumpObject, pumpDistance = FindNearestFuelPump()

        if pumpDistance < 2.5 then
            isNearPump = pumpObject
        else
            isNearPump = nil

            Wait(math.ceil(pumpDistance * 20))
        end
    end
end)

Citizen.CreateThread(function()
    DecorRegister(Config.FuelDecor, 1)

    for index = 1, #Config.NoFuel do
        if type(Config.NoFuel[index]) == 'string' then
            Config.NoFuel[GetHashKey(Config.NoFuel[index])] = true
        else
            Config.NoFuel[Config.NoFuel[index]] = true
        end
    end

    for index = #Config.NoFuel, 1, -1 do
        table.remove(Config.NoFuel, index)
    end

    while true do
        Citizen.Wait(1000)

        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped) then
            local vehicle = GetVehiclePedIsIn(ped)

            if Config.NoFuel[GetEntityModel(vehicle)] then
                inBlacklisted = true
            else
                inBlacklisted = false
            end

            if not inBlacklisted and GetPedInVehicleSeat(vehicle, -1) == ped then
                ManageFuelUsage(vehicle)
            end
        else
            if fuelSynced then
                fuelSynced = false
            end

            if inBlacklisted then
                inBlacklisted = false
            end
        end
    end
end)

RegisterNetEvent('can9work-auction/other/updateCache', function(zoneId, identifier)
    local isOwner = lib.callback.await('can9work_auction:server:checkOwnership', false, zoneId)

    if not isOwner then
        ownedCache[zoneId] = { owned = true, identifier = identifier }
    else
        print("Bu istasyon zaten ihale ile size tanımlandı!")
    end
end)

exports("GetStationCoords", function()
    local coords = {}
    for _, station in pairs(Config.GasStations) do
        if station.management then
            coords[#coords + 1] = station.management
        end
    end
    return coords
end)

-- can9work-auction'in istasyon NPC'sinden yonetim menusu (Config.ManagementPed = false iken yonetim pedi yok).
-- Sahiplik sunucuda kontrol edilir; sahibi olmayan acsa da islemler reddedilir.
exports("OpenStationManagement", function(stationId)
    stationId = tonumber(tostring(stationId):match("(%d+)$")) -- 3 ya da gas_3
    if not stationId or not Config.GasStations[stationId] then return false end
    currentZone = stationId
    OpenManagementMenu()
    return true
end)
