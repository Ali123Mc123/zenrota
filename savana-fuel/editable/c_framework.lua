Framework = {}

function Framework:GetIdentifier()
    if Config.Framework == "qb" then
        return FrameworkObject.Functions.GetPlayerData().citizenid
    elseif Config.Framework == "esx" then
        return FrameworkObject.GetPlayerData().identifier
    else
        return nil
    end
end

function Framework:SpawnFrameworkVehicle(vehicleName, coords)
    local playerPed = PlayerPedId()
    local vehicleModel = type(vehicleName) == "number" and vehicleName or GetHashKey(vehicleName)

    lib.requestModel(vehicleModel, 10000)

    pcall(function() exports['FeloxAC']:CreateVehicle(vehicleModel) end) --[[FeloxAC:auto]]
    local vehicle = CreateVehicle(vehicleModel, coords.x, coords.y, coords.z, coords.w, true, false)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetEntityAsMissionEntity(vehicle, true, true)
    pcall(function() exports['FeloxAC']:ChangeVehiclePlate(vehicle, "FUEL" .. tostring(math.random(1000, 9999))) end) --[[FeloxAC:auto]]
    SetVehicleNumberPlateText(vehicle, "FUEL" .. tostring(math.random(1000, 9999)))
    SetVehicleLivery(vehicle, 1)
    SetVehicleColours(vehicle, 122, 122)
    exports['savana-fuel']:SetFuel(vehicle, 100.0)

    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    SetVehicleEngineOn(vehicle, true, true)
    TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))

    SetModelAsNoLongerNeeded(vehicleModel)
    return vehicle
end

function Framework:SpawnVehicle(vehicleName, coords)
    local playerPed = PlayerPedId()
    local vehicleModel = type(vehicleName) == "number" and vehicleName or GetHashKey(vehicleName)

    lib.requestModel(vehicleModel, 10000)

    pcall(function() exports['FeloxAC']:CreateVehicle(vehicleModel) end) --[[FeloxAC:auto]]
    local vehicle = CreateVehicle(vehicleModel, coords.x, coords.y, coords.z, coords.w, true, false)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetEntityAsMissionEntity(vehicle, true, true)
    pcall(function() exports['FeloxAC']:ChangeVehiclePlate(vehicle, "FUEL" .. tostring(math.random(1000, 9999))) end) --[[FeloxAC:auto]]
    SetVehicleNumberPlateText(vehicle, "FUEL" .. tostring(math.random(1000, 9999)))
    exports['savana-fuel']:SetFuel(vehicle, 100.0)

    SetModelAsNoLongerNeeded(vehicleModel)
    return vehicle
end

function Framework:Notify(text, types)
    lib.notify({ title = '', description = text, duration = 3500, type = types })
end

Citizen.CreateThread(function()
    local ped = PlayerPedId()

    if Config.CustomPumps then
        for i, pump in ipairs(Config.CustomPumps) do
            local stationKey = "custom_" .. i
            Config.GasStations[stationKey] = {
                isCustom = true,
                price = 500000,
                thickness = 20,
                coords = pump.coords,
                management = pump.coords
            }
            lib.zones.sphere({
                coords = vec3(pump.coords.x, pump.coords.y, pump.coords.z),
                radius = 35.0,
                debug = false,
                inside = function()
                    if currentZone == nil then
                        currentZone = stationKey
                    end
                end,
                onEnter = function()
                    currentZone = stationKey
                end,
                onExit = function()
                    if currentZone == stationKey then
                        currentZone = nil
                    end
                end
            })
        end
    end

    for k, v in pairs(Config.GasStations) do
        if not v.isCustom then
            if v.zones then
                lib.zones.poly({
                    points = v.zones,
                    thickness = v.thickness,
                    debug = false,
                    inside = function()
                        if currentZone == nil then
                            currentZone = k
                        end
                    end,
                    onEnter = function()
                        currentZone = k
                        ownedCache[currentZone] = lib.callback.await('savana-fuel:server:getStationOwnedInfo', false, currentZone)
                    end,
                    onExit = function()
                        ownedCache[currentZone] = lib.callback.await('savana-fuel:server:getStationOwnedInfo', false, currentZone)
                        currentZone = nil
                    end
                })
            end

            if v.management then
                if not Config.UseTarget then
                    lib.zones.sphere({
                        coords = v.management,
                        radius = 18.0,
                        debug = false,
                        inside = function()
                            HandleManagementZone(v.management)
                        end,
                        onEnter = function()
                            if currentZone then
                                ownedCache[currentZone] = lib.callback.await('savana-fuel:server:getStationOwnedInfo', false,
                                    currentZone)
                            else
                                currentZone = k
                                ownedCache[currentZone] = lib.callback.await('savana-fuel:server:getStationOwnedInfo', false,
                                    currentZone)
                            end
                        end
                    })

                    if v.jobList then
                        lib.zones.sphere({
                            coords = v.jobList,
                            radius = 18.0,
                            debug = false,
                            inside = function()
                                HandleJobListZone(v.jobList)
                            end,
                            onEnter = function()
                                if currentZone then
                                    ownedCache[currentZone] = lib.callback.await('savana-fuel:server:getStationOwnedInfo', false,
                                        currentZone)
                                else
                                    currentZone = k
                                    ownedCache[currentZone] = lib.callback.await('savana-fuel:server:getStationOwnedInfo', false,
                                        currentZone)
                                end
                            end
                        })
                    end
                else
                    -- Config.ManagementPed = false: yonetim can9work-auction'in istasyon NPC'sinden acilir, bu ped dogmaz.
                    if Config.ManagementPed ~= false then
                    lib.requestModel(v.managementPed, 10000)
                    local ped = CreatePed(4, GetHashKey(v.managementPed), v.management.x, v.management.y, v.management.z - 1,
                        v.management.w, false, false)
                    SetEntityHeading(ped, v.management.w)
                    FreezeEntityPosition(ped, true)
                    SetEntityInvincible(ped, true)
                    SetBlockingOfNonTemporaryEvents(ped, true)
                    SetPedDiesWhenInjured(ped, false)
                    SetPedCanRagdoll(ped, false)

                    if GetResourceState('ox_target') == 'started' then
                        local options = {
                            {
                                label = Config.Strings.TargetManagement,
                                icon = "fas fa-briefcase",
                                onSelect = function()
                                    OpenManagementMenu()
                                end,
                                canInteract = function(entity, distance, coords, name)
                                    if not myIdentifier then
                                        myIdentifier = Framework:GetIdentifier()
                                    end

                                    currentZone = k
                                    ownedCache[currentZone] = lib.callback.await('savana-fuel:server:getStationOwnedInfo', false,
                                        currentZone)

                                    if ownedCache[currentZone] and ownedCache[currentZone].owned then
                                        if ownedCache[currentZone].identifier == myIdentifier then
                                            return true
                                        else
                                            return false
                                        end
                                    else
                                        return false
                                    end
                                end
                            },
                            {
                                label = Config.Strings.TargetBuy,
                                icon = "fas fa-briefcase",
                                action = function()
                                    currentZone = k
                                    OpenBuyMenu()
                                end,
                                canInteract = function()
                                    currentZone = k

                                    ownedCache[currentZone] = lib.callback.await(
                                        'savana-fuel:server:getStationOwnedInfo',
                                        false, currentZone)

                                    if ownedCache[currentZone] and ownedCache[currentZone].owned then
                                        return false
                                    else
                                        return true
                                    end
                                end
                            }
                        }

                        exports['ox_target']:addLocalEntity(ped, options)
                    else
                        exports['qb-target']:AddTargetEntity(ped, {
                            options = {
                                {
                                    label = Config.Strings.TargetManagement,
                                    icon = "fas fa-briefcase",
                                    action = function()
                                        OpenManagementMenu()
                                    end,
                                    canInteract = function()
                                        if not myIdentifier then
                                            myIdentifier = Framework:GetIdentifier()
                                        end

                                        currentZone = k
                                        ownedCache[currentZone] = lib.callback.await(
                                            'savana-fuel:server:getStationOwnedInfo', false, currentZone)

                                        if ownedCache[currentZone] and ownedCache[currentZone].owned then
                                            if ownedCache[currentZone].identifier == myIdentifier then
                                                return true
                                            else
                                                return false
                                            end
                                        else
                                            return false
                                        end
                                    end
                                },
                                {
                                    label = Config.Strings.TargetBuy,
                                    icon = "fas fa-briefcase",
                                    action = function()
                                        currentZone = k
                                        OpenBuyMenu()
                                    end,
                                    canInteract = function()
                                        currentZone = k

                                        ownedCache[currentZone] = lib.callback.await(
                                            'savana-fuel:server:getStationOwnedInfo',
                                            false, currentZone)

                                        if ownedCache[currentZone] and ownedCache[currentZone].owned then
                                            return false
                                        else
                                            return true
                                        end
                                    end
                                }
                            },
                            distance = 2.0
                        })
                    end
                    end

                    if v.jobList and v.jobListPed then
                        RequestModel(v.jobListPed)
                        while not HasModelLoaded(v.jobListPed) do
                            Wait(0)
                        end
                        local ped = CreatePed(4, GetHashKey(v.jobListPed), v.jobList.x, v.jobList.y, v.jobList.z - 1, v.jobList.w,
                            false, false)
                        SetEntityHeading(ped, v.jobList.w)
                        FreezeEntityPosition(ped, true)
                        SetEntityInvincible(ped, true)
                        SetBlockingOfNonTemporaryEvents(ped, true)
                        SetPedDiesWhenInjured(ped, false)
                        SetPedCanRagdoll(ped, false)

                        if GetResourceState('ox_target') == 'started' then
                            local optionss = {
                                {
                                    label = Config.Strings.TargetJoblist,
                                    icon = "fas fa-briefcase",
                                    onSelect = function()
                                        OpenJobListMenu()
                                    end,
                                    canInteract = function()
                                        currentZone = k

                                        ownedCache[currentZone] = lib.callback.await(
                                            'savana-fuel:server:getStationOwnedInfo', false, currentZone)

                                        if ownedCache[currentZone] and ownedCache[currentZone].owned then
                                            return true
                                        else
                                            return false
                                        end
                                    end
                                }
                            }

                            exports['ox_target']:addLocalEntity(ped, optionss)
                        else
                            exports['qb-target']:AddTargetEntity(ped, {
                                options = {
                                    {
                                        label = Config.Strings.TargetJoblist,
                                        icon = "fas fa-briefcase",
                                        action = function()
                                            OpenJobListMenu()
                                        end,
                                        canInteract = function()
                                            currentZone = k

                                            ownedCache[currentZone] = lib.callback.await(
                                                'savana-fuel:server:getStationOwnedInfo', false, currentZone)

                                            if ownedCache[currentZone] and ownedCache[currentZone].owned then
                                                return true
                                            else
                                                return false
                                            end
                                        end
                                    }
                                },
                                distance = 2.0
                            })
                        end
                    end
                end
            end
        end
    end
end)

exports['ox_target']:addModel(Config.PumpModelsName, {
    {
        icon = 'fas fa-gas-pump',
        label = Config.Strings.TargetGaspump,
        onSelect = function(entity)
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            local vehicle = lib.getClosestVehicle(pedCoords, 5.0)

            -- Ensure currentZone is set for custom pumps
            if not currentZone and Config.CustomPumps then
                for i, pump in ipairs(Config.CustomPumps) do
                    if #(pedCoords - vec3(pump.coords.x, pump.coords.y, pump.coords.z)) < 35.0 then
                        currentZone = "custom_" .. i
                        break
                    end
                end
            end

            if vehicle then
                OpenFuelMenu(VehToNet(vehicle))
            else
                Framework:Notify(Config.Strings.noVehicle, "error")
            end
        end,
    }
}, { distance = 2.0 })
