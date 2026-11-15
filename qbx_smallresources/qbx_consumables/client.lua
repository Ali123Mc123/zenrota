local alcoholCount = 0
local relieveCount = 0
local healing = false
local smokingWeed = false
local kokoActive = false

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    if kokoActive then
        kokoActive = false
        LocalPlayer.state:set('kokoActive', false, false)
    end
end)

RegisterNetEvent('consumables:client:UseIfak', function(item)
    if lib.progressBar({
            duration = 5000,
            label = locale('progress.ifaks'),
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = false,
                car = false,
                mouse = false,
                combat = true
            },
            anim = {
                dict = 'missheistdockssetup1clipboard@base',
                clip = 'base',
                flag = 49
            }
        }) then
        if kokoActive then
            exports.qbx_core:Notify('Zaten aktif bir İfak etkisi var!', 'error')
            return
        end
        local used = lib.callback.await('consumables:server:usedItem', false, 'ifaks')
        if not used then return end

        kokoActive = true
        LocalPlayer.state:set('kokoActive', true, false)
        exports.qbx_core:Notify('İfak kullanıldı - Recoil devre dışı!', 'success')

        CreateThread(function()
            local timeLeft = 120
            while timeLeft > 0 and kokoActive do
                Wait(10000)
                timeLeft = timeLeft - 10
                if timeLeft < 60 and kokoActive then
                    exports.qbx_core:Notify(('İfak etkisinin bitmesine %s saniye kaldı!'):format(timeLeft), 'inform')
                end
            end
            
            if kokoActive then
                kokoActive = false
                LocalPlayer.state:set('kokoActive', false, false)
                exports.qbx_core:Notify('İfak etkisi bitti - Recoil normale döndü!', 'inform')
            end
        end)
    else
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
    end
end)

local redbullEndTime = 0
local isRedbullThreadRunning = false

RegisterNetEvent('consumables:client:redbull', function()
    if lib.progressBar({
            duration = 7000,
            label = locale('progress.redbull'),
            useWhileDead = false,
            canCancel = true,
            disable = { move = false, car = false, mouse = false, combat = true },
            anim = {
                dict = 'mp_player_intdrink',
                clip = 'loop_bottle',
                flag = 49
            },
            prop = {
                model = `bzzz_new_snacks_energy_a`,
                pos = vec3(0.12, 0.008, 0.03),
                rot = vec3(240.0, -60.0, 0.0),
                bone = 18905
            }
        }) then
        local used = lib.callback.await('consumables:server:usedItem', false, 'redbull')
        if not used then return end

        lib.notify({ description = '1 Dakika boyunca enerjin fullendi!' })
        redbullEndTime = GetGameTimer() + (60 * 1000)

        if not isRedbullThreadRunning then
            isRedbullThreadRunning = true
            CreateThread(function()
                local playerId = PlayerId()
                while GetGameTimer() < redbullEndTime do
                    RestorePlayerStamina(playerId, 1.0)
                    SetRunSprintMultiplierForPlayer(playerId, 1.05)
                    Wait(200)
                end
                SetRunSprintMultiplierForPlayer(playerId, 1.0)
                SetPlayerStamina(playerId, 0.0)
                lib.notify({ description = 'Enerjin normale döndü.' })
                isRedbullThreadRunning = false
            end)
        end
    else
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
    end
end)

local pdRedbullEndTime = 0
local isPdRedbullThreadRunning = false

RegisterNetEvent('consumables:client:pd_redbull', function()
    if lib.progressBar({
            duration = 7000,
            label = 'Polis Enerji İçeceği içiyorsun...',
            useWhileDead = false,
            canCancel = true,
            disable = { move = false, car = false, mouse = false, combat = true },
            anim = {
                dict = 'mp_player_intdrink',
                clip = 'loop_bottle',
                flag = 49
            },
            prop = {
                model = `bzzz_new_snacks_energy_a`,
                pos = vec3(0.12, 0.008, 0.03),
                rot = vec3(240.0, -60.0, 0.0),
                bone = 18905
            }
        }) then
        local used = lib.callback.await('consumables:server:usedItem', false, 'pd_redbull')
        if not used then return end

        lib.notify({ description = '3 Dakika boyunca enerjin fullendi!' })
        pdRedbullEndTime = GetGameTimer() + (180 * 1000)

        if not isPdRedbullThreadRunning then
            isPdRedbullThreadRunning = true
            CreateThread(function()
                local playerId = PlayerId()
                while GetGameTimer() < pdRedbullEndTime do
                    RestorePlayerStamina(playerId, 1.0)
                    SetRunSprintMultiplierForPlayer(playerId, 1.05)
                    Wait(200)
                end
                SetRunSprintMultiplierForPlayer(playerId, 1.0)
                SetPlayerStamina(playerId, 0.0)
                lib.notify({ description = 'Enerjin normale döndü.' })
                isPdRedbullThreadRunning = false
            end)
        end
    else
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
    end
end)

RegisterNetEvent('qbx_consumables:client:UseArmour', function(itemName)
    if GetPedArmour(cache.ped) < 100 then
        local ped = cache.ped

        Wait(100)

        if lib.progressBar({
                duration = 7000,
                label = 'Çelik yelek kuşanıyorsun...',
                useWhileDead = false,
                canCancel = true,
                disable = { move = false, car = false, mouse = false, combat = true },
                anim = {
                    dict = 'missmic4',
                    clip = 'michael_tux_fidget',
                    flag = 48
                }
            }) then
            local used = lib.callback.await('consumables:server:usedItem', false, itemName)
            if not used then return end

            SetPlayerMaxArmour(cache.playerId, 100)
            pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
            SetPedArmour(ped, 100)
            exports.qbx_core:Notify('Zırh kuşanıldı.', 'success')
        else
            exports.qbx_core:Notify(locale('error.canceled'), 'error')
        end
    else
        exports.qbx_core:Notify('Zaten Zırhın Var', 'error')
    end
end)

RegisterNetEvent('consumables:client:sigara', function()
    local ped = cache.ped
    local dict = "amb@world_human_smoking@male@male_a@base"
    local anim = "base"
    local propModel = "prop_cs_ciggy_01"
    local duration = 5000

    lib.requestAnimDict(dict)
    lib.requestModel(propModel)

    local x, y, z = table.unpack(GetEntityCoords(ped))
    pcall(function() exports['FeloxAC']:CreateObject(GetHashKey(propModel)) end) --[[FeloxAC:auto]]
    local cig = CreateObject(GetHashKey(propModel), x, y, z + 0.2, true, true, false)
    AttachEntityToEntity(cig, ped, GetPedBoneIndex(ped, 28422), 0.01, 0.01, 0.0, 10.0, 0.0, 0.0, true, true, false, true
    , 1, true)

    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 49, 0, false, false, false)

    if lib.progressBar({
            duration = duration,
            label = 'Sigaranı yakıyorsun...',
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, mouse = false, combat = true }
        }) then
        local used = lib.callback.await('consumables:server:usedItem', false, 'sigara')
        if not used then
            ClearPedTasks(ped)
            DeleteObject(cig)
            return
        end
        exports.qbx_core:Notify('Sigaranı içiyorsun...', 'success')
        ClearPedTasks(ped)
        DeleteObject(cig)
    else
        ClearPedTasks(ped)
        DeleteObject(cig)
        exports.qbx_core:Notify('Sigara içmeyi bıraktın.', 'error')
    end
end)
