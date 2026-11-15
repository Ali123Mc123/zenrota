local vehicleHashes = {}

Citizen.CreateThread(function()
    for _, vehName in ipairs(Settings.AllowedVehicles) do
        vehicleHashes[GetHashKey(vehName)] = true
    end
end)

RegisterNetEvent('can9work-pdepo:client:CheckVehicle', function()
    local playerData = exports.qbx_core:GetPlayerData()
    if not playerData or not playerData.job or playerData.job.type ~= 'leo' then
        lib.notify({
            title = 'Hata',
            description = 'Bu işlemi gerçekleştirmek için yetkiniz yok.',
            type = 'error'
        })
        return
    end

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if veh == 0 then
        lib.notify({
            title = 'Hata',
            description = 'Bu komutu kullanmak için uygun bir polis aracının içinde olmalısın.',
            type = 'error'
        })
        return
    end

    local model = GetEntityModel(veh)

    if vehicleHashes[model] then
        local plate = GetVehicleNumberPlateText(veh)
        if plate then
            TriggerServerEvent('can9work-pdepo:server:OpenStash', plate)
        end
    else
        lib.notify({
            title = 'Hata',
            description = 'Bu aracın özel polis deposu bulunmuyor.',
            type = 'error'
        })
    end
end)

RegisterNetEvent('can9work-pdepo:client:doOpen', function(stashId)
    exports.ox_inventory:openInventory('stash', stashId)
end)
