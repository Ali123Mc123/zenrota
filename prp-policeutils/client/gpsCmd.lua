local isRemoving = false

local function ProcessGpsRemoval()
    if isRemoving then return end

    local ped = PlayerPedId()

    if IsPedDeadOrDying(ped, true) or IsPedFatallyInjured(ped) or LocalPlayer.state.isDead then
        lib.notify({
            title = 'GPS Sökme',
            description = 'Bu durumdayken GPS sökemezsiniz.',
            type = 'error'
        })
        return
    end

    local veh = GetVehiclePedIsIn(ped, false)
    if not veh or veh == 0 or not DoesEntityExist(veh) then
        lib.notify({
            title = 'GPS Sökme',
            description = 'Bu komutu kullanmak için bir aracın içinde ve sürücü koltuğunda olmalısınız.',
            type = 'error'
        })
        return
    end

    if GetPedInVehicleSeat(veh, -1) ~= ped then
        lib.notify({
            title = 'GPS Sökme',
            description = 'GPS sökme işlemini yalnızca aracı süren kişi (sürücü) yapabilir.',
            type = 'error'
        })
        return
    end

    if IsEntityAttachedToAnyPed(ped) or LocalPlayer.state.isCuffed or LocalPlayer.state.isEscorted then
        lib.notify({
            title = 'GPS Sökme',
            description = 'Kucaktayken, kelepçeliyken veya birine bağlıyken GPS sökemezsiniz.',
            type = 'error'
        })
        return
    end

    local vehNetId = NetworkGetNetworkIdFromEntity(veh)
    if not vehNetId or vehNetId == 0 then
        lib.notify({
            title = 'GPS Sökme',
            description = 'Araç ağ kimliği (netId) alınamadı.',
            type = 'error'
        })
        return
    end

    local hasGps = lib.callback.await('prp-policeutils:hasGpsInstalled', false, vehNetId)
    if not hasGps then
        lib.notify({
            title = 'GPS Sökme',
            description = 'Bu araçta takılı bir GPS takip cihazı bulunamadı.',
            type = 'error'
        })
        return
    end

    isRemoving = true
    local success = lib.progressBar({
        duration = 15000,
        label = 'GPS Cihazı Sökülüyor...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
        },
    })
    isRemoving = false

    if success then
        local currentPed = PlayerPedId()
        local currentVeh = GetVehiclePedIsIn(currentPed, false)
        if currentVeh == veh and GetPedInVehicleSeat(currentVeh, -1) == currentPed and not IsPedDeadOrDying(currentPed, true) and not LocalPlayer.state.isDead and not IsEntityAttachedToAnyPed(currentPed) then
            TriggerServerEvent('prp-policeutils:server:cikarGps', vehNetId)
        else
            lib.notify({
                title = 'GPS Sökme',
                description = 'Sürücü koltuğundan ayrıldığınız için işlem iptal edildi.',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'GPS Sökme',
            description = 'GPS sökme işlemi iptal edildi.',
            type = 'warning'
        })
    end
end

RegisterCommand('gpscikar', function()
    ProcessGpsRemoval()
end, false)

RegisterCommand('gpsçıkar', function()
    ProcessGpsRemoval()
end, false)
