local QBCore = exports['qb-core']:GetCoreObject()
ownedPlates, jackedVehicle = {}, {}
lockpickAttempt = 0

-- ownedPlates her degistiginde artar. onDriverSeat dongusu checkKeysExist
-- sonucunu bu sayaca gore onbellekler; boylece anahtar durumu degismedikce
-- sunucuya tekrar sorulmaz (bkz. onDriverSeat).
keysVersion = 0

-----------------------------------------------------------------------------------------
-- EVENT'S --
-----------------------------------------------------------------------------------------

RegisterNetEvent('wais-vehiclekey:send:ownedPlates', function(owned)
    ownedPlates = owned
    keysVersion = keysVersion + 1
end)

AddStateBagChangeHandler('doorslockstate', false, function(bagName, _, value)
    if bagName ~= nil then
        local entity = GetEntityFromStateBagName(bagName)
        SetVehicleDoorsLocked(entity, value)
    end
end)

RegisterNetEvent('vehiclekeys:client:SetOwner', function(plate)
    if not plate then return end
    local ped = PlayerPedId()
    local vehicle = cache.vehicle
    local trimmed = plate:gsub("%s+", "")
    ownedPlates[trimmed] = true
    ownedPlates[plate] = true
    keysVersion = keysVersion + 1
    TriggerServerEvent('vehiclekeys:server:giveKey', trimmed)
    if IsPedInAnyVehicle(ped, false) and vehicle and vehicle ~= 0 then
        local curPlate = GetVehicleNumberPlateText(vehicle)
        if curPlate and (curPlate == plate or curPlate:gsub("%s+", "") == trimmed) then
            SetVehicleEngineOn(vehicle, true, false, true)
            SetVehicleUndriveable(vehicle, false)
        end
    end
end)

RegisterNetEvent('vehiclekeys:client:jackVehicle', function(vehicle)
    local ped = PlayerPedId()
    local plate = GetVehicleNumberPlateText(vehicle)

    if IsPedInAnyVehicle(ped) and vehicle ~= 0 and vehicle == cache.vehicle then
        SetVehicleEngineOn(vehicle, true, false, true)
        jackedVehicle[vehicle] = true
    end
end)

RegisterNetEvent('vehiclekeys:client:hotwireVehicle', function(plate)
    local ped = PlayerPedId()
    local vehicle = cache.vehicle

    if IsPedInAnyVehicle(ped) and GetVehicleNumberPlateText(vehicle) == plate then
        SetVehicleEngineOn(vehicle, true, false, true)
        SetVehicleUndriveable(vehicle, false)
    end
end)

RegisterNetEvent('wais:check:nearPlayer', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle, vehCoords = getNearVehicle(10.0)
    local playerId, playerPed, playerCoords = lib.getClosestPlayer(coords, 3.0)

    if playerId ~= nil and playerId > 0 then
        if vehicle ~= nil and vehicle > 0 then
            local plate = GetVehicleNumberPlateText(vehicle)
            if checkKeysExist(vehicle, GetVehicleNumberPlateText(vehicle)) then
                if playerId ~= nil and playerId ~= 0 and vehicle ~= 0 then
                    TriggerServerEvent('wais:share:vehiclekey', GetPlayerServerId(playerId), plate)
                end
            else
                exports.qbx_core:Notify("Bu aracın anahtarına sahip değilsin!", "error")
            end
        else
            exports.qbx_core:Notify("Yakınında araç yok!", "error")
        end
    else
        exports.qbx_core:Notify("Yakınında oyuncu yok!", "error")
    end
end)

RegisterNetEvent('lockpicks:UseLockpick', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle, vehCoords = getNearVehicle(5.0)
    if vehicle ~= nil and vehicle > 0 then
        local plate = GetVehicleNumberPlateText(vehicle)
        if not checkKeysExist(vehicle, GetVehicleNumberPlateText(vehicle)) then
            if vehicle ~= 0 then
                local animDict = "veh@break_in@0h@p_m_one@"
                lib.requestAnimDict(animDict)

                if lib.progressCircle({
                        duration = 15000,
                        label = "Maymuncukla Kilit Açılıyor...",
                        position = 'bottom',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                            move = true,
                            combat = true,
                        },
                        anim = {
                            dict = animDict,
                            clip = "low_force_entry_ds",
                        },
                    }) then
                    ClearPedTasks(ped)
                    sendDispatch()
                    UseLockpick(vehicle)
                else
                    ClearPedTasks(ped)
                    exports.qbx_core:Notify("Kilit açma aletini kullanmayı iptal ettin!", "error")
                end
                RemoveAnimDict(animDict)
            end
        else
            exports.qbx_core:Notify("Bu aracın anahtarına zaten sahipsin!", "error")
        end
    else
        exports.qbx_core:Notify("Yakınında araç yok!", "error")
    end
end)

RegisterNetEvent('wais-vehiclekey:client:policeUnlock', function()
    local vehicle, vehCoords = getNearVehicle(5.0)
    if vehicle ~= nil and vehicle > 0 then
        local animDict = "veh@break_in@0h@p_m_one@"
        lib.requestAnimDict(animDict)

        if lib.progressCircle({
                duration = 10000,
                label = "Araç Kapısı Kırılıyor...",
                position = 'bottom',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true,
                },
                anim = {
                    dict = animDict,
                    clip = "low_force_entry_ds",
                },
            }) then
            ClearPedTasks(cache.ped)
            TriggerServerEvent('wais-vehiclekey:server:policeUnlock', NetworkGetNetworkIdFromEntity(vehicle))
        else
            ClearPedTasks(cache.ped)
            exports.qbx_core:Notify("İşlem iptal edildi!", "error")
        end
        RemoveAnimDict(animDict)
    else
        exports.qbx_core:Notify("Yakınında araç yok!", "error")
    end
end)

-----------------------------------------------------------------------------------------
-- CALLBACK'S --
-----------------------------------------------------------------------------------------

lib.callback.register('wais:isValidPlate', function(plate)
    return ownedPlates[plate] or false
end)

lib.callback.register('wais:share:vehiclekey:cl', function(plate)
    if not plate then return false end
    local ped = PlayerPedId()
    local vehicle = cache.vehicle
    local trimmed = plate:gsub("%s+", "")
    ownedPlates[trimmed] = true
    ownedPlates[plate] = true
    keysVersion = keysVersion + 1
    TriggerServerEvent('vehiclekeys:server:giveKey', trimmed)

    if IsPedInAnyVehicle(ped, false) and vehicle and vehicle ~= 0 then
        local curPlate = GetVehicleNumberPlateText(vehicle)
        if curPlate and (curPlate == plate or curPlate:gsub("%s+", "") == trimmed) then
            SetVehicleEngineOn(vehicle, true, false, true)
            SetVehicleUndriveable(vehicle, false)
        end
    end

    return true
end)

-----------------------------------------------------------------------------------------
-- FUNCTION'S --
-----------------------------------------------------------------------------------------

local function tryEnteringLoop(vehicle)
    if Entity(vehicle).state.doorslockstate ~= nil then return end
    if IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1)) then return end
    local lockState = GetVehicleDoorLockStatus(vehicle)
    local newLockStatus = (lockState % 2) + 1
    TriggerServerEvent('wais-vehiclekey:server:lockVehicle', NetworkGetNetworkIdFromEntity(vehicle), newLockStatus)
end

local function onDriverSeat()
    local ped = PlayerPedId()
    local vehicle = cache.vehicle
    if not vehicle or vehicle == 0 then return end
    local plate = GetVehicleNumberPlateText(vehicle)
    if checkKeysExist(vehicle, plate) then return end

    CreateThread(function()
        -- checkKeysExist sunucuya lib.callback ile gidiyor (daddy-fakeplate
        -- plaka cozumlemesi). Her 100 ms'de sormak, anahtarsiz her surucu
        -- basina saniyede 10 sunucu sorgusu demek. Sonucu onbellekle; yalniz
        -- plaka metni degistiginde ya da oyuncunun anahtarlari guncellendiginde
        -- (keysVersion) yeniden sor.
        local lastPlateText, lastKeysVersion, resolvedHasKey = nil, -1, false

        while cache.vehicle ~= 0 and cache.seat == -1 do
            if not DoesEntityExist(vehicle) then break end

            local plateText = GetVehicleNumberPlateText(vehicle)
            if plateText ~= lastPlateText or keysVersion ~= lastKeysVersion then
                lastPlateText, lastKeysVersion = plateText, keysVersion
                resolvedHasKey = checkKeysExist(vehicle, plateText)
            end

            if resolvedHasKey or jackedVehicle[vehicle] ~= nil then
                SetVehicleEngineOn(vehicle, true, false, true)
                SetVehicleUndriveable(vehicle, false)
                break
            else
                SetVehicleEngineOn(vehicle, false, false, true)
                SetVehicleUndriveable(vehicle, true)
            end
            Wait(100)
        end
    end)
end

lib.onCache('seat', function(newSeat, oldSeat)
    if (newSeat) and newSeat == -1 then
        Wait(0)
        onDriverSeat()
    end
end)

lib.onCache('vehicle', function(newVehicle, oldVehicle)
    if (newVehicle) and newVehicle ~= 0 and newVehicle ~= oldVehicle then
        lockpickAttempt = 0
    end
end)

local function doVehicleAnimation(vehicle)
    SetVehicleLights(vehicle, 2)
    Wait(250)
    SetVehicleLights(vehicle, 1)
    Wait(200)
    SetVehicleLights(vehicle, 0)
    Wait(300)
end

function getNearVehicle(distance)
    -- DaddyRP: in a vehicle, L works on that one (a truck's trailer is often the closest).
    if cache.vehicle and cache.vehicle ~= 0 then return cache.vehicle, GetEntityCoords(cache.vehicle) end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    return lib.getClosestVehicle(coords, distance, true)
end

function checkKeysExist(vehicle, plate)
    if not plate then return false end

    local trimmed = plate:gsub("%s+", "")

    -- 1. Direct RAM check first (0.00ms, no network call!)
    if ownedPlates[trimmed] or ownedPlates[plate] then
        return true
    end

    -- 2. Check daddy-fakeplate ONLY if started and key not found directly
    if GetResourceState('daddy-fakeplate') == 'started' then
        local originalPlate = exports['daddy-fakeplate']:GetOriginalPlate(trimmed)
        if originalPlate then
            local trimmedOriginal = originalPlate:gsub("%s+", "")
            if ownedPlates[trimmedOriginal] or ownedPlates[originalPlate] then
                return true
            end
        end
    end

    return false
end

-----------------------------------------------------------------------------------------
-- COMMAND'S --
-----------------------------------------------------------------------------------------

lib.addKeybind({
    name = 'kilit',
    description = 'Araç anahtarı Kilit/Aç',
    defaultKey = 'L',
    onPressed = function(self)
        if checkDead() then
            exports.qbx_core:Notify("Ölüyken bu işlemi yapamazsın!", "error")
            return
        end

        local vehicle, coords = getNearVehicle(10.0)
        if vehicle ~= nil then
            local plate = GetVehicleNumberPlateText(vehicle)
            plate = plate:gsub("%s+", "")
            if checkKeysExist(vehicle, plate) then
                local bagState = Entity(vehicle).state.doorslockstate or GetVehicleDoorLockStatus(vehicle)
                if GetVehicleDoorLockStatus(vehicle) ~= bagState then SetVehicleDoorsLocked(vehicle, bagState) end
                local newLockStatus = (GetVehicleDoorLockStatus(vehicle) % 2) + 1

                lib.playAnim(cache.ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49)
                TriggerServerEvent('wais-vehiclekey:server:lockVehicle', NetworkGetNetworkIdFromEntity(vehicle),
                    newLockStatus)
                doVehicleAnimation(vehicle)
                ClearPedTasks(cache.ped)
                exports.qbx_core:Notify(
                    ('%s Plakalı araç %s!'):format(plate, newLockStatus == 2 and "Kilitlendi" or "Açıldı"),
                    (newLockStatus == 2 and "error" or "success"))
                TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 8, newLockStatus == 2 and "lock" or "unlock", 0.6)
            else
                exports.qbx_core:Notify("Bu aracın anahtarına sahip değilsin!", "error")
            end
        else
            exports.qbx_core:Notify("Yakınında araç yok!", "error")
        end
    end
})

-----------------------------------------------------------------------------------------
-- THREAD'S --
-----------------------------------------------------------------------------------------

CreateThread(function()
    while true do
        local vehicle = GetVehiclePedIsTryingToEnter(cache.ped)
        if vehicle ~= 0 then
            tryEnteringLoop(vehicle)
        end
        Wait(100)
    end
end)

CreateThread(function()
    while true do
        local sleep = 5000
        local ped = PlayerPedId()
        SetPedStayInVehicleWhenJacked(ped, true)
        SetPedCanBeDraggedOut(ped, false)
        SetPedConfigFlag(ped, 27, true)
        SetPedConfigFlag(ped, 133, false)
        SetPedConfigFlag(ped, 177, true)

        Wait(sleep)
    end
end)

-----------------------------------------------------------------------------------------
-- EXPORT'S --
-----------------------------------------------------------------------------------------

local function hasKeyFor(vehicleOrPlate)
    if type(vehicleOrPlate) == 'string' then
        return checkKeysExist(nil, vehicleOrPlate)
    end
    if not vehicleOrPlate or not DoesEntityExist(vehicleOrPlate) then return false end
    return checkKeysExist(vehicleOrPlate, GetVehicleNumberPlateText(vehicleOrPlate))
end

exports("HasKey", hasKeyFor)
exports("HasKeys", hasKeyFor)

-----------------------------------------------------------------------------------------
-- QB-VEHICLEKEYS / QBX_VEHICLEKEYS UYUMLULUGU --
-- Diger scriptler anahtari qb/qbx yollariyla verir; burada wais'e yonlendirilir.
-----------------------------------------------------------------------------------------

local function removeKey(plate)
    if not plate then return end
    local trimmed = plate:gsub("%s+", "")
    ownedPlates[trimmed] = nil
    ownedPlates[plate] = nil
    keysVersion = keysVersion + 1
    TriggerServerEvent('wais-vehiclekey:server:removeKey', trimmed)
end

RegisterNetEvent('qb-vehiclekeys:client:AddKeys', function(plate)
    TriggerEvent('vehiclekeys:client:SetOwner', plate)
end)

RegisterNetEvent('qb-vehiclekeys:client:RemoveKeys', removeKey)
RegisterNetEvent('wais-vehiclekey:client:removeKey', removeKey)

local function provideExport(resource, name, fn)
    AddEventHandler(('__cfx_export_%s_%s'):format(resource, name), function(setCB) setCB(fn) end)
end

for _, res in ipairs({ 'qb-vehiclekeys', 'qbx_vehiclekeys' }) do
    provideExport(res, 'HasKeys', hasKeyFor)
    provideExport(res, 'HasKey', hasKeyFor)
end
