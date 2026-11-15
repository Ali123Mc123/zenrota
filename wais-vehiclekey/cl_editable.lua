function checkDead()
    return exports.qbx_medical:IsDead() or exports.qbx_medical:IsLaststand()
end

function sendDispatch()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = cache.vehicle or getNearVehicle(10.0)

    exports.daddy_dispatch:Raise("vehicle_theft", {
        title = "Araç Hırsızlığı Girişimi",
        coords = coords,
        to = { "police", "bcso", "sasp", "pbsd", "cppd", "sapr" },
    })
end

function deleteLockpick()
    exports.qbx_core:Notify("Maymuncuk Kırıldı!", "error")
    TriggerServerEvent("vehiclekeys:server:removeLockpick")
    lockpickAttempt = 0
end

function UseLockpick(vehicle)
    math.randomseed(GetGameTimer())
    local ped = PlayerPedId()
    local currentVehicle = vehicle
    local pedIsInVehicle = IsPedInAnyVehicle(ped)
    lockpickAttempt = lockpickAttempt + 1


    -- maymuncuk minigame'i: tgg-minigames Lockpick (zorluk aşağıdaki çağrıda)
    local function finish(success)
        if not success then
            exports.qbx_core:Notify("Kilit açma aleti kullanımı başarısız oldu!", "error")
            if lockpickAttempt >= 2 then
                deleteLockpick()
            end
            lockpickAttempt = 0
            return
        end

        if pedIsInVehicle and not checkKeysExist(currentVehicle, GetVehicleNumberPlateText(currentVehicle)) then
            local plate = GetVehicleNumberPlateText(currentVehicle)

            TriggerServerEvent('wais-vehiclekey:server:lockVehicle', NetworkGetNetworkIdFromEntity(currentVehicle), 1)
            -- TriggerServerEvent('vehiclekeys:server:giveKey', plate)
            ownedPlates[plate] = true
            exports.qbx_core:Notify("Araç kilidi başarıyla açıldı!", "success")
            lockpickAttempt = 0
            deleteLockpick()
        elseif not pedIsInVehicle then
            if currentVehicle == nil then return exports.qbx_core:Notify("Yakınında araç yok!", "error") end
            local doorStatus = Entity(currentVehicle).state.doorslockstate or GetVehicleDoorLockStatus(currentVehicle)
            if doorStatus == 1 then return exports.qbx_core:Notify("Kapı zaten açık!", "error") end

            local plate = GetVehicleNumberPlateText(currentVehicle)

            TriggerServerEvent('wais-vehiclekey:server:lockVehicle', NetworkGetNetworkIdFromEntity(currentVehicle), 1)
            -- TriggerServerEvent('vehiclekeys:server:giveKey', plate)
            ownedPlates[plate] = true
            exports.qbx_core:Notify("Araç kilidi başarıyla açıldı!", "success")
            lockpickAttempt = 0
            deleteLockpick()
        end
    end

    local ok, success = pcall(function()
        return exports['tgg-minigames']:Lockpick({
            slowMovementThreshold = 7, -- yavaş çevirme sayılan en yüksek hız (bölüm/saniye)
            sections = 36,             -- daire üzerindeki konum sayısı
            lightShakeTolerance = 6,   -- hafif titremenin başladığı uzaklık (± bölüm)
            successZoneTolerance = 2,  -- başarı bölgesi (± bölüm)
        })
    end)
    if not ok then print(('[wais-vehiclekey] tgg-minigames Lockpick hata: %s'):format(success)) end
    finish(ok and success == true)
end

exports('UseLockpick', function()
    UseLockpick()
end)
