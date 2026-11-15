local PlayerAddictions = { nane = 0, koko = 0, meth = 0, nostress = 0, cigar = 0 }
local LastEffectTimes = { nane = 0, koko = 0, meth = 0, nostress = 0, cigar = 0 }

LevelEffects = {
    nane = {},
    koko = {
        [25] = {
            notificationKey = 'koko_craving_low',
            interval = 108000,
            effect = function()
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.055)
                Wait(550)
                StopGameplayCamShaking(true)
            end
        },
        [50] = {
            notificationKey = 'koko_craving_medium',
            interval = 81000,
            effect = function()
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.165)
                AnimpostfxPlay('FocusOut', 825, false)
                Wait(825)
                StopGameplayCamShaking(true)
                AnimpostfxStop('FocusOut')
            end
        },
        [75] = {
            notificationKey = 'koko_craving_high',
            interval = 54000,
            effect = function()
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.275)
                AnimpostfxPlay('DrugsTrevorClownsFightIn', 1100, false)
                SetTimecycleModifier('spectator5')
                SetTimecycleModifierStrength(0.165)
                SetTimeout(1650, ClearTimecycleModifier)
                Wait(1100)
                StopGameplayCamShaking(true)
                AnimpostfxStop('DrugsTrevorClownsFightIn')
                AnimpostfxStop('DrugsTrevorClownsFight')
            end
        },
        [100] = {
            notificationKey = 'koko_craving_critical',
            interval = 27000,
            effect = function()
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.44)
                AnimpostfxPlay('DrugsTrevorClownsFight', 2200, false)
                local ped = PlayerPedId()
                local health = GetEntityHealth(ped)
                if health > 150 then pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]] SetEntityHealth(ped, health - 10) end
                if math.random(1, 100) <= 30 then
                    SetPedToRagdoll(ped, 2000, 2000, 0, false, false, false)
                end
                Wait(2200)
                StopGameplayCamShaking(true)
                AnimpostfxStop('DrugsTrevorClownsFight')
                AnimpostfxStop('DrugsTrevorClownsFightIn')
            end
        }
    },
    meth = {
        [25] = {
            notificationKey = 'meth_craving_low',
            interval = 108000,
            effect = function()
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.055)
                Wait(550)
                StopGameplayCamShaking(true)
            end
        },
        [50] = {
            notificationKey = 'meth_craving_medium',
            interval = 81000,
            effect = function()
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.165)
                AnimpostfxPlay('FocusOut', 550, false)
                Wait(550)
                StopGameplayCamShaking(true)
                AnimpostfxStop('FocusOut')
            end
        },
        [75] = {
            notificationKey = 'meth_craving_high',
            interval = 54000,
            effect = function()
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.275)
                AnimpostfxPlay('DrugsMichaelAliensFight', 1100, false)
                Wait(1100)
                StopGameplayCamShaking(true)
                AnimpostfxStop('DrugsMichaelAliensFight')
                AnimpostfxStop('DrugsMichaelAliensFightIn')
            end
        },
        [100] = {
            notificationKey = 'meth_craving_critical',
            interval = 27000,
            effect = function()
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.44)
                AnimpostfxPlay('DrugsTrevorClownsFight', 1650, false)
                Wait(1650)
                StopGameplayCamShaking(true)
                AnimpostfxStop('DrugsTrevorClownsFight')
                AnimpostfxStop('DrugsTrevorClownsFightIn')
            end
        }
    },
    nostress = {
        [25] = {
            notificationKey = 'nostress_craving_low',
            interval = 108000,
            effect = function()
                AnimpostfxPlay('PPFilter', 550, false)
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.055); Wait(550); StopGameplayCamShaking(true)
            end
        },
        [50] = {
            notificationKey = 'nostress_craving_medium',
            interval = 81000,
            effect = function()
                AnimpostfxPlay('PPFilter', 1100, false)
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.11); Wait(1100); StopGameplayCamShaking(true)
            end
        },
        [75] = {
            notificationKey = 'nostress_craving_high',
            interval = 54000,
            effect = function()
                AnimpostfxPlay('PPFilter', 1650, false)
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.22); Wait(1650); StopGameplayCamShaking(true)
            end
        },
        [100] = {
            notificationKey = 'nostress_craving_critical',
            interval = 27000,
            effect = function()
                AnimpostfxPlay('PPFilter', 2200, false)
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.44); Wait(2200); StopGameplayCamShaking(true)
            end
        }
    },
    cigar = {
        [25] = {
            notificationKey = 'cigar_craving_low',
            interval = 5400000,
            effect = function()
                AnimpostfxPlay('FocusIn', 700, false)
                ShakeGameplayCam('JOLT_SHAKE', 0.08)
                Wait(700)
                StopGameplayCamShaking(true)
            end
        },
        [50] = {
            notificationKey = 'cigar_craving_medium',
            interval = 3600000,
            effect = function()
                AnimpostfxPlay('InchPickup', 1200, false)
                ShakeGameplayCam('JOLT_SHAKE', 0.16)
                Wait(300)
                ShakeGameplayCam('JOLT_SHAKE', 0.12)
                Wait(900)
                StopGameplayCamShaking(true)
            end
        },
        [75] = {
            notificationKey = 'cigar_craving_high',
            interval = 2400000,
            effect = function()
                AnimpostfxPlay('DeathFailNeutralIn', 3000, false)
                StartAudioScene('MP_LEADERBOARD_SCENE')
                
                SendNUIMessage({
                    action = "playSound",
                    sound = "cough_1.wav",
                    volume = 0.10
                })
                
                local ped = PlayerPedId()
                if not IsPedInAnyVehicle(ped, false) and not IsPedRagdoll(ped) then
                    lib.requestAnimDict('timetable@gardener@smoking_joint')
                    TaskPlayAnim(ped, 'timetable@gardener@smoking_joint', 'idle_cough', 8.0, -8.0, 3000, 49, 0, false, false, false)
                end
                
                ShakeGameplayCam('JOLT_SHAKE', 0.28)
                Wait(400)
                ShakeGameplayCam('JOLT_SHAKE', 0.22)
                Wait(1000)
                
                SendNUIMessage({
                    action = "playSound",
                    sound = "cough_2.ogg",
                    volume = 0.10
                })
                ShakeGameplayCam('JOLT_SHAKE', 0.25)
                Wait(400)
                ShakeGameplayCam('JOLT_SHAKE', 0.18)
                
                local playerId = PlayerId()
                local currStam = GetPlayerStamina(playerId)
                SetPlayerStamina(playerId, math.max(0.0, currStam - 40.0))
                
                Wait(1200)
                StopGameplayCamShaking(true)
                StopAudioScene('MP_LEADERBOARD_SCENE')
            end
        },
        [100] = {
            notificationKey = 'cigar_craving_critical',
            interval = 1800000,
            effect = function()
                AnimpostfxPlay('InchPickup', 4500, false)
                AnimpostfxPlay('DeathFailNeutralIn', 4000, false)
                StartAudioScene('MP_LEADERBOARD_SCENE')

                SendNUIMessage({
                    action = "showVignette",
                    duration = 5000
                })
                
                SendNUIMessage({
                    action = "playSound",
                    sound = "cough_1.wav",
                    volume = 0.10
                })
                
                local ped = PlayerPedId()
                if not IsPedInAnyVehicle(ped, false) and not IsPedRagdoll(ped) then
                    lib.requestAnimDict('timetable@gardener@smoking_joint')
                    TaskPlayAnim(ped, 'timetable@gardener@smoking_joint', 'idle_cough', 8.0, -8.0, 4000, 49, 0, false, false, false)
                end

                CreateThread(function()
                    local headBone = GetPedBoneIndex(ped, 31086)
                    RequestNamedPtfxAsset("core")
                    local ptfxTimeout = 0
                    while not HasNamedPtfxAssetLoaded("core") and ptfxTimeout < 30 do
                        ptfxTimeout = ptfxTimeout + 1
                        Wait(50)
                    end
                    if HasNamedPtfxAssetLoaded("core") then
                        UseParticleFxAssetNextCall("core")
                        local ptfx = StartParticleFxLoopedOnEntityBone("exp_grd_grenade_smoke", ped, 0.0, 0.10, -0.01, 0.0, 0.0, 0.0, headBone, 0.07, false, false, false)
                        SetParticleFxLoopedColour(ptfx, 0.2, 0.18, 0.18, false)
                        Wait(1400)
                        StopParticleFxLooped(ptfx, false)
                        RemoveNamedPtfxAsset("core")
                    end
                end)

                CreateThread(function()
                    if not IsPedInAnyVehicle(ped, false) then
                        lib.requestAnimSet("move_m@drunk@moderatedrunk")
                        SetPedMovementClipset(ped, "move_m@drunk@moderatedrunk", 1.0)
                        ShakeGameplayCam('DRUNK_SHAKE', 0.8)
                        Wait(4500)
                        ResetPedMovementClipset(ped, 0.5)
                        StopGameplayCamShaking(true)
                    end
                end)

                ShakeGameplayCam('JOLT_SHAKE', 0.45)
                Wait(400)
                ShakeGameplayCam('JOLT_SHAKE', 0.40)
                Wait(900)
                
                SendNUIMessage({
                    action = "playSound",
                    sound = "cough_2.ogg",
                    volume = 0.10
                })
                ShakeGameplayCam('JOLT_SHAKE', 0.38)
                Wait(400)
                ShakeGameplayCam('JOLT_SHAKE', 0.30)
                Wait(900)
                
                SendNUIMessage({
                    action = "playSound",
                    sound = "cough_1.wav",
                    volume = 0.10
                })
                ShakeGameplayCam('JOLT_SHAKE', 0.35)
                Wait(400)
                ShakeGameplayCam('JOLT_SHAKE', 0.25)
                
                local playerId = PlayerId()
                SetPlayerStamina(playerId, 0.0)
                local health = GetEntityHealth(ped)
                if health > 120 then
                    pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
                    SetEntityHealth(ped, health - 5)
                end
                
                Wait(1000)
                StopGameplayCamShaking(true)
                StopAudioScene('MP_LEADERBOARD_SCENE')
            end
        }
    }
}

local nostressActiveUntil = 0
RegisterNetEvent('addiction:client:UseDrug:nostress', function()
    nostressActiveUntil = GetGameTimer() + 120000
end)

CreateThread(function()
    while true do
        Wait(5000)
        local currentTime = GetGameTimer()
        local isNoStressActive = (currentTime < nostressActiveUntil)
        for drugType, amount in pairs(PlayerAddictions) do
            local threshold = GetAddictionLevelThreshold(amount)
            if threshold > 0 and LevelEffects[drugType] and LevelEffects[drugType][threshold] then
                local effects = LevelEffects[drugType][threshold]
                local activeInterval = effects.interval
                if drugType == 'cigar' and isNoStressActive then
                    activeInterval = 300000
                end
                if currentTime - (LastEffectTimes[drugType] or 0) >= activeInterval then
                    LastEffectTimes[drugType] = currentTime
                    exports.qbx_core:Notify(locale(effects.notificationKey), 'error')
                    effects.effect()
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        local cigarLevel = PlayerAddictions.cigar or 0
        if cigarLevel >= 50 then
            local isNoStressActive = (GetGameTimer() < nostressActiveUntil)
            local volume = 0.05
            local sleepTime = 3600000

            if cigarLevel >= 90 then
                volume = 0.10
                sleepTime = 1800000
            elseif cigarLevel >= 70 then
                volume = 0.08
                sleepTime = 2400000
            end

            if isNoStressActive then
                sleepTime = 300000
            end

            SendNUIMessage({
                action = "playSound",
                sound = "clicker.wav",
                volume = volume
            })

            Wait(sleepTime)
        else
            SendNUIMessage({ action = "stopSound" })
            Wait(4000)
        end
    end
end)

CreateThread(function()
    while Settings.Withdrawal.Enabled do
        Wait(Settings.Withdrawal.Interval)
        for drugType, amount in pairs(PlayerAddictions) do
            if drugType ~= 'nane' and amount >= Settings.Withdrawal.MinLevel then
                if math.random(1, 100) <= 25 then
                    PlayWithdrawalSymptoms()
                end
            end
        end
    end
end)

RegisterNetEvent('addiction:client:LoadAddictions', function(data)
    AnimpostfxStopAll()
    ClearTimecycleModifier()
    local now = GetGameTimer()
    for k in pairs(LastEffectTimes) do
        LastEffectTimes[k] = now
    end
    if data then
        for k, v in pairs(data) do
            if PlayerAddictions[k] ~= nil then
                PlayerAddictions[k] = v
            end
        end
    end
end)

RegisterNetEvent('addiction:client:UpdateAddiction', function(drugType, amount)
    PlayerAddictions[drugType] = amount
    LastEffectTimes[drugType] = GetGameTimer()
    if drugType == 'cigar' and amount < 50 then
        SendNUIMessage({ action = "stopSound" })
    end
    local label = locale('drug_' .. drugType) or (Settings.Drugs[drugType] and Settings.Drugs[drugType].label) or drugType:upper()
    exports.qbx_core:Notify(locale('addiction_level', label:upper(), amount, GetLevelText(amount)), 'inform')
end)

RegisterNetEvent('addiction:client:NewLevel', function(drugType, level)
    local drugLabel = Settings.Drugs[drugType] and Settings.Drugs[drugType].label or drugType
    if drugType == 'cigar' and level == 'critical' then
        exports.qbx_core:Notify(locale('new_level_critical_cigar'), 'error', 15000)
    else
        exports.qbx_core:Notify(locale('new_level_' .. level, drugLabel), 'error', 10000)
    end

    if drugType == 'nane' then return end

    if level == 'critical' then
        AnimpostfxPlay('DeathFailMPIn', 3300, false)
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 1.1)
        SetTimeout(3300, function()
            StopGameplayCamShaking(true)
            AnimpostfxStop('DeathFailMPIn')
        end)
    elseif level == 'high' then
        AnimpostfxPlay('DrugsTrevorClownsFightIn', 2200, false)
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.55)
        SetTimeout(2200, function()
            StopGameplayCamShaking(true)
            AnimpostfxStop('DrugsTrevorClownsFightIn')
            AnimpostfxStop('DrugsTrevorClownsFight')
        end)
    end
end)

RegisterNetEvent('addiction:client:Overdose', function()
    PlayOverdoseEffect()
    exports.qbx_core:Notify(locale('overdose_warning'), 'error')
end)

-- Assuming 'cache' is defined globally or in an accessible scope, e.g., by ox_lib itself.
-- The local declaration 'local cache = exports.ox_lib:cache()' has been removed as per instruction.
local isUsingDrug = false
RegisterNetEvent('addiction:client:UseDrug', function(drugType, ignoreAddiction)
    if isUsingDrug then return end

    -- drugType null ise "koko" varsay (failsafe)
    local typeToUse = drugType or "koko"
    local config = Settings.Drugs[typeToUse]
    if not config then return end

    isUsingDrug = true
    local successBar = lib.progressBar({
        duration = 5000,
        label = config.label .. ' kullanılıyor...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = false, car = false, mouse = false, combat = true },
        anim = {
            dict = 'mp_suicide',
            clip = 'pill',
            flag = 49
        }
    })


    if successBar then
        local success, newAmount, newLevel = lib.callback.await('addiction:server:usedItem', false, typeToUse,
            ignoreAddiction)
        if success then
            TriggerEvent('addiction:client:UseDrug:' .. typeToUse)
            exports.qbx_core:Notify(config.label .. ' kullandın.', 'success')

            -- Apply special bonuses
            if config.armor then
                pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
                SetPedArmour(PlayerPedId(), config.armor)
            end

            -- Apply Special Effect Functions
            if config.effect then
                local effectFunc = _G[config.effect]
                if effectFunc then
                    CreateThread(function()
                        effectFunc(config.duration, PlayerAddictions[typeToUse] or 0)
                    end)
                end
            end
        end
    end
    isUsingDrug = false
end)

RegisterNetEvent('addiction:client:UseAntidote', function(drugType, antidoteItem)
    if lib.progressBar({
            duration = 5000,
            label = locale('antidote_using'),
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, mouse = false, combat = true },
            anim = { dict = "mp_suicide", clip = "pill" },
        }) then
        local success = lib.callback.await('addiction:server:useAntidote', false, drugType, antidoteItem)
        if success then
            AnimpostfxStopAll()
            ClearTimecycleModifier()
            StopGameplayCamShaking(true)
            exports.qbx_core:Notify(locale('antidote_success'), 'success')
        end
    end
end)

local function showDrugDetails(drugType, config)
    local currentAmount = PlayerAddictions[drugType] or 0
    local levels = {
        {
            key = 'none',
            range = '0% - 24%',
            title = locale('level_none'),
            icon = 'check-circle',
            color = 'green',
            extra = (drugType == 'cigar') and 'Ciğerlerin henüz bu ağır dumanla tanışmamış. Vücudunda olağan kan akışı devam ediyor.' or nil
        },
        {
            key = 'low',
            range = '25% - 49%',
            title = locale('level_low'),
            icon = 'exclamation-circle',
            color = 'blue',
            extra = (drugType == 'cigar') and 'Vücudun Hush\'ın zehriyle uyanıyor; kas dokuların sertleşiyor ve yumrukların normalin katbekat üzerinde yıkıcı bir hasar gücüne ulaşıyor. Duman kesildiğinde ise parmaklarında hafif titremeler ve o ağır dumanı arayış başlıyor.' or nil
        },
        {
            key = 'medium',
            range = '50% - 74%',
            title = locale('level_medium'),
            icon = 'exclamation-triangle',
            color = 'yellow',
            extra = (drugType == 'cigar') and 'Zehir damarlarına kök salıyor. Elindeki DD84 adeta bir uzvun gibi hafifliyor, savurduğun darbeler kemik çatlatacak kadar ölümcülleşiyor. Zihninin derinliklerinde ara sıra tekinsiz click tıkırtıları yankılanıyor; yoksunluk bastırdığında boğazın kuruyor, öksürükle sarsılıyorsun.' or nil
        },
        {
            key = 'high',
            range = '75% - 99%',
            title = locale('level_high'),
            icon = 'biohazard',
            color = 'orange',
            extra = (drugType == 'cigar') and 'Katran ruhunu karartmış durumda. DD84 ile savurduğun her vuruş yıkıcı bir güce ulaşıyor fakat bedeli ağırlaşıyor: Fısıltılar ve click sesleri artık daha yakından duyuluyor. Kriz anlarında nefesin tıkanıyor, göğsün ezilircesine sıkışıyor ve derin sarsıntılar bedenini tüketiyor.' or nil
        },
        {
            key = 'critical',
            range = '100%',
            title = locale('level_critical'),
            icon = 'skull',
            color = 'red',
            extra = (drugType == 'cigar') and 'ÖLÜMCÜL TOKSİN EŞİĞİ!\nDD84 ellerinde bir ölüm fermanına dönüşmüş, vurulan darbenin affı yok. Fakat beden bu dehşeti daha fazla taşıyamıyor; görüşün kararıyor, ciğerlerinden dumanlar boşanıyor ve sarhoş gibi sendeleyerek yere yığılıyorsun.\n\n⚠️ Bu sessizlik sonun olabilir: 7 gün içinde panzehir bulunup zehir vücuttan sökülmezse, karakterin için yolun sonu gelecek (CK)!' or nil
        }
    }

    local menuOptions = {
        {
            title = string.format('Mevcut Durum: %d%% (%s)', currentAmount, GetLevelText(currentAmount)),
            description = 'Aşağıdan tüm seviyelerin getirdiği etki ve yan etkileri inceleyebilirsiniz.',
            progress = currentAmount,
            colorScheme = GetLevelColor(currentAmount),
            icon = 'chart-line',
            iconColor = GetLevelColor(currentAmount)
        }
    }

    for i = 1, #levels do
        local lvl = levels[i]
        local desc = locale('desc_' .. drugType .. '_' .. lvl.key) or locale('level_' .. lvl.key .. '_desc')
        if lvl.extra then
            desc = desc .. '\n\n' .. lvl.extra
        end
        table.insert(menuOptions, {
            title = string.format('%s | %s', lvl.range, lvl.title),
            description = desc,
            icon = lvl.icon,
            iconColor = lvl.color
        })
    end

    lib.registerContext({
        id = 'addiction_drug_details_' .. drugType,
        title = config.label .. ' - Seviye Detayları',
        menu = 'addiction_menu',
        options = menuOptions
    })
    lib.showContext('addiction_drug_details_' .. drugType)
end

local function showLevelInfo()
    local options = {}
    for drugType, config in pairs(Settings.Drugs) do
        table.insert(options, {
            title = config.label .. ' Detaylı Seviyeleri',
            description = string.format('%s maddesinin tüm seviye etkilerini, bonuslarını ve krizlerini gör.', config.label),
            icon = 'cannabis',
            iconColor = 'orange',
            onSelect = function()
                showDrugDetails(drugType, config)
            end
        })
    end

    table.insert(options, {
        title = 'Genel Seviye Açıklamaları',
        description = 'Sistemdeki genel bağımlılık seviye tanımları.',
        icon = 'info-circle',
        iconColor = 'blue',
        onSelect = function()
            lib.registerContext({
                id = 'addiction_general_info_menu',
                title = locale('level_info'),
                menu = 'addiction_info_menu',
                options = {
                    { title = '0% - 24% | ' .. locale('level_none'), description = locale('level_none_desc'), icon = 'check-circle', iconColor = 'green' },
                    { title = '25% - 49% | ' .. locale('level_low'), description = locale('level_low_desc'), icon = 'exclamation-circle', iconColor = 'blue' },
                    { title = '50% - 74% | ' .. locale('level_medium'), description = locale('level_medium_desc'), icon = 'exclamation-triangle', iconColor = 'yellow' },
                    { title = '75% - 99% | ' .. locale('level_high'), description = locale('level_high_desc'), icon = 'biohazard', iconColor = 'orange' },
                    { title = '100% | ' .. locale('level_critical'), description = locale('level_critical_desc'), icon = 'skull', iconColor = 'red' }
                }
            })
            lib.showContext('addiction_general_info_menu')
        end
    })

    lib.registerContext({
        id = 'addiction_info_menu',
        title = locale('level_info'),
        menu = 'addiction_menu',
        options = options
    })
    lib.showContext('addiction_info_menu')
end

RegisterCommand('bagimlilik', function()
    local options = {}
    for drugType, config in pairs(Settings.Drugs) do
        local amount = PlayerAddictions[drugType] or 0
        local levelName = GetLevelName(amount)
        local customKey = 'desc_' .. drugType .. '_' .. levelName
        local descText = locale(customKey) or locale('level_' .. levelName .. '_desc')
        table.insert(options, {
            title = config.label,
            description = string.format('%d%% - %s\n%s\n\n👉 Detaylı tüm seviyeleri ve etkileri görmek için tıkla.', amount, GetLevelText(amount), descText),
            icon = 'cannabis',
            iconColor = GetLevelColor(amount),
            progress = amount,
            colorScheme = GetLevelColor(amount),
            onSelect = function()
                showDrugDetails(drugType, config)
            end
        })
    end

    table.insert(options, {
        title = locale('level_info'),
        description = locale('level_info_desc'),
        icon = 'info-circle',
        onSelect = function()
            showLevelInfo()
        end
    })

    lib.registerContext({
        id = 'addiction_menu',
        title = locale('addiction_status'),
        options = options
    })
    lib.showContext('addiction_menu')
end, false)

exports('GetPlayerAddiction', function(drugType)
    if drugType then
        return PlayerAddictions[drugType] or 0
    end
    return PlayerAddictions
end)

exports('IsDrugged', function()
    for _, amount in pairs(PlayerAddictions) do
        if amount >= (Settings.Thresholds.Low or 25) then
            return true
        end
    end
    return false
end)

lib.callback.register('consumables:client:kokoStatus', function()
    return LocalPlayer.state.kokoActive or false
end)

RegisterNetEvent('addiction:client:TestSound', function(soundName, volume)
    local testSounds = {
        ['clicker'] = 'clicker.wav',
        ['cough1'] = 'cough_1.wav',
        ['cough2'] = 'cough_2.ogg'
    }

    local targetVol = math.min(0.10, math.max(0.01, volume or 0.10))

    if soundName then
        local lower = string.lower(soundName)
        if lower == 'stop' then
            SendNUIMessage({ action = "stopSound" })
            exports.qbx_core:Notify('Ses durduruldu.', 'inform')
            return
        end

        local file = testSounds[lower] or lower
        SendNUIMessage({
            action = "playSound",
            sound = file,
            volume = targetVol
        })
        exports.qbx_core:Notify(string.format('Ses çalınıyor: %s (Ses: %.2f)', file, targetVol), 'success')
    else
        local options = {
            {
                title = 'Clicker Sesi (clicker.wav)',
                description = 'Vol: 0.10 | Hush %50+ arkaplan sesi',
                icon = 'volume-high',
                onSelect = function()
                    SendNUIMessage({ action = "playSound", sound = "clicker.wav", volume = targetVol })
                end
            },
            {
                title = 'Öksürük 1 (cough_1.wav)',
                description = 'Vol: 0.10 | Kriz anı derin öksürük',
                icon = 'head-side-cough',
                onSelect = function()
                    SendNUIMessage({ action = "playSound", sound = "cough_1.wav", volume = targetVol })
                end
            },
            {
                title = 'Öksürük 2 (cough_2.ogg)',
                description = 'Vol: 0.10 | Kriz anı boğulma öksürüğü',
                icon = 'head-side-cough',
                onSelect = function()
                    SendNUIMessage({ action = "playSound", sound = "cough_2.ogg", volume = targetVol })
                end
            },
            {
                title = 'Katran Dumanı & Vertigo Test Et',
                description = 'Ağızdan çıkan katran dumanı ve kamera vertigo yakınlaşması',
                icon = 'smog',
                iconColor = 'orange',
                onSelect = function()
                    TriggerEvent('addiction:client:TestCigarEffect', 100)
                end
            },
            {
                title = 'Sesi Durdur',
                description = 'Çalmakta olan tüm sesleri keser',
                icon = 'stop',
                iconColor = 'red',
                onSelect = function()
                    SendNUIMessage({ action = "stopSound" })
                end
            }
        }

        lib.registerContext({
            id = 'addiction_test_sound_menu',
            title = 'Ses Test Menüsü',
            options = options
        })
        lib.showContext('addiction_test_sound_menu')
    end
end)

RegisterNetEvent('addiction:client:TestCigarEffect', function(lvl)
    local targetLvl = tonumber(lvl) or 100
    if LevelEffects.cigar and LevelEffects.cigar[targetLvl] then
        exports.qbx_core:Notify(string.format('Hush %%d krizi tetikleniyor...', targetLvl), 'inform')
        LevelEffects.cigar[targetLvl].effect()
    else
        exports.qbx_core:Notify('Geçersiz seviye! (25, 50, 75 veya 100)', 'error')
    end
end)

RegisterCommand('testcigar', function(source, args)
    local lvl = args[1] or 100
    TriggerEvent('addiction:client:TestCigarEffect', lvl)
end, false)

RegisterCommand('testsound', function(source, args)
    TriggerEvent('addiction:client:TestSound', args[1], tonumber(args[2]))
end, false)
