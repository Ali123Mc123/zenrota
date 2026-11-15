local function playPlateAnimation(vehicle)
    TaskStartScenarioInPlace(cache.ped, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
    local success = lib.progressBar({
        duration = 6000,
        label = 'Plaka değiştiriliyor...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    })
    ClearPedTasks(cache.ped)
    return success
end

-- Export for fakeplate item
local function useFakePlate(data)
    local coords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(coords, 4.5, false)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        lib.notify({title = 'Hata', description = 'Yakınlarda araç bulunamadı!', type = 'error'})
        return
    end

    if GetVehicleClass(vehicle) == 18 then
        lib.notify({title = 'Hata', description = 'Polis ve acil durum araçlarına sahte plaka takılamaz!', type = 'error'})
        return
    end

    local distance = #(coords - GetEntityCoords(vehicle))
    if distance > 4.5 then
        lib.notify({title = 'Hata', description = 'Araca daha yakın olmalısınız!', type = 'error'})
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if not netId or netId == 0 then
        lib.notify({title = 'Hata', description = 'Araç ağı algılanamadı!', type = 'error'})
        return
    end

    -- Trigger server to verify ownership and generate/apply a unique fake plate
    lib.callback('daddy-fakeplate:server:applyFakePlate', false, function(success, msg, fakePlate)
        if success then
            if playPlateAnimation(vehicle) then
                if not DoesEntityExist(vehicle) then
                    lib.notify({title = 'Hata', description = 'Araç artık mevcut değil!', type = 'error'})
                    return
                end

                local confirmed, applyErr = lib.callback.await('daddy-fakeplate:server:confirmApplyFakePlate', false, NetworkGetNetworkIdFromEntity(vehicle), fakePlate)
                if confirmed then
                    lib.notify({title = 'Başarılı', description = 'Sahte plaka başarıyla takıldı: ' .. fakePlate, type = 'success'})
                else
                    lib.notify({title = 'Hata', description = applyErr or 'İşlem tamamlanamadı!', type = 'error'})
                end
            else
                lib.notify({title = 'İptal Edildi', description = 'İşlem iptal edildi.', type = 'info'})
            end
        else
            lib.notify({title = 'Hata', description = msg or 'Plaka takılamadı!', type = 'error'})
        end
    end, netId)
end

-- Export for platerestorekit item
local function usePlateRestoreKit(data)
    local coords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(coords, 4.5, false)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        lib.notify({title = 'Hata', description = 'Yakınlarda araç bulunamadı!', type = 'error'})
        return
    end

    if GetVehicleClass(vehicle) == 18 then
        lib.notify({title = 'Hata', description = 'Polis ve acil durum araçlarında bu işlem yapılamaz!', type = 'error'})
        return
    end

    local distance = #(coords - GetEntityCoords(vehicle))
    if distance > 4.5 then
        lib.notify({title = 'Hata', description = 'Araca daha yakın olmalısınız!', type = 'error'})
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if not netId or netId == 0 then
        lib.notify({title = 'Hata', description = 'Araç ağı algılanamadı!', type = 'error'})
        return
    end

    lib.callback('daddy-fakeplate:server:removeFakePlate', false, function(success, msg, originalPlate)
        if success then
            if playPlateAnimation(vehicle) then
                if not DoesEntityExist(vehicle) then
                    lib.notify({title = 'Hata', description = 'Araç artık mevcut değil!', type = 'error'})
                    return
                end

                local confirmed, removeErr = lib.callback.await('daddy-fakeplate:server:confirmRemoveFakePlate', false, NetworkGetNetworkIdFromEntity(vehicle), originalPlate)
                if confirmed then
                    lib.notify({title = 'Başarılı', description = 'Sahte plaka söküldü. Orijinal plaka geri takıldı: ' .. originalPlate, type = 'success'})
                else
                    lib.notify({title = 'Hata', description = removeErr or 'İşlem tamamlanamadı!', type = 'error'})
                end
            else
                lib.notify({title = 'İptal Edildi', description = 'İşlem iptal edildi.', type = 'info'})
            end
        else
            lib.notify({title = 'Hata', description = msg or 'Plaka sökülemedi!', type = 'error'})
        end
    end, netId)
end

-- Sync vehicle plate visual change client side
RegisterNetEvent('daddy-fakeplate:client:setPlate', function(netId, plateText)
    if not NetworkDoesNetworkIdExist(netId) then return end
    local vehicle = NetToVeh(netId)
    if DoesEntityExist(vehicle) then
        pcall(function() exports['FeloxAC']:ChangeVehiclePlate(vehicle, plateText) end) --[[FeloxAC:auto]]
        SetVehicleNumberPlateText(vehicle, plateText)
    end
end)

-- Exports registration
exports('useFakePlate', useFakePlate)
exports('usePlateRestoreKit', usePlateRestoreKit)

local function GetOriginalPlate(fakePlate)
    if not fakePlate or fakePlate == "" then return nil end
    return lib.callback.await('daddy-fakeplate:server:getOriginalPlate', false, fakePlate)
end

local function GetFakePlate(originalPlate)
    if not originalPlate or originalPlate == "" then return nil end
    return lib.callback.await('daddy-fakeplate:server:getFakePlate', false, originalPlate)
end

exports('GetOriginalPlate', GetOriginalPlate)
exports('GetFakePlate', GetFakePlate)
