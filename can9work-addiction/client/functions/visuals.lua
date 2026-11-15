local healing = false
local smokingWeed = false

-- Yardımcı: Bağımlılık seviyesine göre efekt gücü hesaplar (0.4 - 1.0 arası)
local function GetEffectStrength(amount)
    local base = 0.4
    local scaled = (amount / 100) * 0.6
    return math.min(1.0, base + scaled)
end

-- "Vuruş" efekti: Kullanıcı isteğiyle tüketim esnasındaki görsel ekran efektleri devre dışı bırakılmıştır.
local function PlayDrugHit(effectName)
    -- Tüketim görsel efekti iptal edildi
end

function TrevorEffect(strength)
    -- Tüketim renk efekti iptal edildi
end

function AlienEffect(strength)
    -- Tüketim renk efekti iptal edildi
end

function ClearDrugEffects()
    ClearTimecycleModifier()
    AnimpostfxStopAll()
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
end

function MethBagEffect(duration, amount)
    local startStamina = duration and (duration / 1000) or 60
    local playerId = PlayerId()

    while startStamina > 0 do
        SetRunSprintMultiplierForPlayer(playerId, 1.49)
        if startStamina % 10 == 0 and startStamina > 0 then
            exports.qbx_core:Notify(locale('effect_remaining', startStamina), 'inform')
        end
        Wait(1000)
        RestorePlayerStamina(playerId, 1.0)
        startStamina = startStamina - 1
    end

    ClearDrugEffects()
end

function EcstasyEffect(duration, amount)
    LocalPlayer.state:set('kokoActive', true, false)

    local startStamina = duration and (duration / 1000) or 60
    local playerId = PlayerId()
    local ped = PlayerPedId()

    while startStamina > 0 do
        if startStamina % 10 == 0 and startStamina > 0 then
            exports.qbx_core:Notify(locale('effect_remaining', startStamina), 'inform')
        end
        Wait(1000)
        startStamina = startStamina - 1
        RestorePlayerStamina(playerId, 1.0)
    end

    if IsPedRunning(ped) and math.random(1, 100) < (amount or 0) then
        SetPedToRagdoll(ped, math.random(1000, 3000), math.random(1000, 3000), 3, false, false, false)
    end
    ClearDrugEffects()
    LocalPlayer.state:set('kokoActive', false, false)
end

function CrackBaggyEffect(duration, amount)
    local startStamina = duration and (duration / 1000) or 60
    local playerId = PlayerId()
    local ped = PlayerPedId()

    while startStamina > 0 do
        SetRunSprintMultiplierForPlayer(playerId, 1.3)
        if startStamina % 10 == 0 and startStamina > 0 then
            exports.qbx_core:Notify(locale('effect_remaining', startStamina), 'inform')
        end
        Wait(1000)
        RestorePlayerStamina(playerId, 1.0)
        startStamina = startStamina - 1

        if math.random(1, 100) < (amount / 2) and IsPedRunning(ped) then
            SetPedToRagdoll(ped, math.random(1000, 2000), math.random(1000, 2000), 3, false, false, false)
        end
    end

    ClearDrugEffects()
end

function CokeBaggyEffect(duration, amount)
    LocalPlayer.state:set('kokoActive', true, false)
    exports.qbx_core:Notify(locale('koko_effect_started'), 'success')

    local startStamina = duration and (duration / 1000) or 60
    local playerId = PlayerId()
    local ped = PlayerPedId()

    while startStamina > 0 do
        if startStamina % 10 == 0 and startStamina > 0 then
            exports.qbx_core:Notify(locale('effect_remaining', startStamina), 'inform')
        end
        Wait(1000)
        RestorePlayerStamina(playerId, 1.0)
        startStamina = startStamina - 1

        if math.random(1, 100) < 10 and IsPedRunning(ped) then
            SetPedToRagdoll(ped, math.random(1000, 3000), math.random(1000, 3000), 3, false, false, false)
        end
    end

    ClearDrugEffects()
    LocalPlayer.state:set('kokoActive', false, false)
    exports.qbx_core:Notify(locale('koko_effect_ended'), 'inform')
end

function HealOxy()
    if not healing then
        healing = true
    else
        return
    end

    local count = 9
    local ped = PlayerPedId()
    while count > 0 do
        SetEntityHealth(ped, GetEntityHealth(ped) + 6)
        Wait(1000)
        count = count - 1
    end
    healing = false
end

function SmokeWeed(duration, amount)
    smokingWeed = true
    local totalDuration = duration or 60000
    local relieveInterval = 10000
    local maxRelieveCount = math.floor(totalDuration / relieveInterval)
    local currentRelieveCount = 0

    CreateThread(function()

        while smokingWeed do
            local remaining = (maxRelieveCount - currentRelieveCount) * (relieveInterval / 1000)
            if remaining > 0 then
                exports.qbx_core:Notify(locale('effect_remaining', math.floor(remaining)), 'inform')
            end
            Wait(relieveInterval)
            TriggerServerEvent('hud:server:RelieveStress', math.random(15, 18))
            currentRelieveCount = currentRelieveCount + 1
            if currentRelieveCount >= maxRelieveCount then
                smokingWeed = false
                ClearDrugEffects()
            end
        end
    end)
end

function PlayOverdoseEffect()
    AnimpostfxPlay('DeathFailMPIn', 2750, false)
    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.55)
    SetTimeout(2750, function() StopGameplayCamShaking(true) end)

    local ped = PlayerPedId()
    SetPedToRagdoll(ped, 3300, 3300, 0, false, false, false)

    if math.random(1, 100) <= Settings.Overdose.DeathChance then
        pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
        SetEntityHealth(ped, 0)
    else
        pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
        SetEntityHealth(ped, GetEntityHealth(ped) - 50)
    end
end

-- Bağımlılık & Yoksunluk Efektleri (%10 Şiddetlendirilmiş)
function PlayWithdrawalSymptoms()
    if not Settings.Withdrawal.Enabled then return end

    exports.qbx_core:Notify(locale('withdrawal_symptoms'), 'warning')

    if Settings.Withdrawal.Shake then
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.11)
        SetTimeout(1650, function() StopGameplayCamShaking(true) end)
    end

    if Settings.Withdrawal.Blur then
        AnimpostfxPlay('FocusOut', 3300, false)
    end

    if Settings.Withdrawal.SlowWalk then
        local ped = PlayerPedId()
        lib.requestAnimSet("move_m@drunk@verydrunk", 10000)
        SetPedMovementClipset(ped, "move_m@drunk@verydrunk", 1.0)

        SetTimeout(11000, function()
            ResetPedMovementClipset(PlayerPedId(), 0)
        end)
    end
end
