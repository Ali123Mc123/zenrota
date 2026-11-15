local function isPlayerInWater()
    local ped = PlayerPedId()
    return IsPedSwimming(ped) or IsPedSwimmingUnderWater(ped) or IsEntityInWater(ped)
end

RegisterCommand('ptekne', function()
    lib.callback('can9work:ptekne:server:CheckJob', false, function(isLeo)
        if not isLeo then
            exports.qbx_core:Notify('Sadece kolluk kuvvetleri bu komutu kullanabilir!', 'error')
            return
        end

        if not isPlayerInWater() then
            exports.qbx_core:Notify('Denizde olmalısınız!', 'warning')
            return
        end

        if lib.progressBar({
            duration = 7000,
            label = 'P.Tekne çağrılıyor...',
            useWhileDead = false,
            canCancel = true,
            disable = { combat = true }
        }) then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            TriggerServerEvent('can9work:ptekne:server:SpawnBoat', {
                x = coords.x, y = coords.y, z = coords.z, w = heading
            })
            exports.qbx_core:Notify('P.Tekne çağrıldı!', 'success')
        else
            exports.qbx_core:Notify('Çağırma işlemi iptal edildi!', 'error')
        end
    end)
end)
