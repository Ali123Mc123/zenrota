local engineSwapNames = {
    -- [1] = "I4 Turbo 2.5L",
    -- [2] = "V6 3.3L",
    -- [3] = "V8 6.5L",
    [1] = "V12 6.0L"
}

local brakeNames = {
    [1] = "Seramik Frenler"
}

RegisterNetEvent('can9work:engineControl:CheckVehicleTuning', function()
    local playerData = QBX.PlayerData
    if not playerData or not playerData.job or playerData.job.type ~= 'leo' then
        exports.qbx_core:Notify('Bu özelliği sadece kolluk kuvvetleri kullanabilir!', 'error')
        return
    end

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle ~= 0 then
        local plate = GetVehicleNumberPlateText(vehicle)
        if plate then
            plate = string.gsub(plate, "^%s*(.-)%s*$", "%1")

            if lib.progressBar({
                    duration = 4000,
                    label = 'Araç tuning kontrol ediliyor...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = true,
                        combat = true
                    }
                }) then
                TriggerServerEvent('can9work:engineControl:server:CheckTuning', plate)
            else
                exports.qbx_core:Notify('Kontrol iptal edildi!', 'error')
            end
        else
            exports.qbx_core:Notify('Araç plakası okunamadı!', 'error')
        end
    else
        exports.qbx_core:Notify('Bir araçta olmalısınız!', 'warning')
    end
end)

RegisterNetEvent('can9work:engineControl:client:ShowMenu', function(tuningConfig)
    local menuOptions = {}

    if tuningConfig.engineSwaps and tuningConfig.engineSwaps > 0 then
        table.insert(menuOptions, {
            title = 'Motor Değişimi',
            description = engineSwapNames[tuningConfig.engineSwaps] or "Bilinmeyen Motor",
            icon = 'engine'
        })
    end

    if tuningConfig.brakes and tuningConfig.brakes > 0 then
        table.insert(menuOptions, {
            title = 'Frenler',
            description = brakeNames[tuningConfig.brakes] or "Özel Frenler",
            icon = 'circle-stop'
        })
    end

    if #menuOptions > 0 then
        lib.registerContext({
            id = 'vehicle_tuning_menu',
            title = 'Araç Tuning Bilgileri',
            options = menuOptions
        })
        lib.showContext('vehicle_tuning_menu')
    else
        exports.qbx_core:Notify('Bu araçta tuning bulunamadı!', 'info')
    end
end)
