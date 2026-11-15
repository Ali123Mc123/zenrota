local currentAlcohol = 0
local currentStage = 0
local currentDrinkType = 'shot'
local isBlackedOut = false
local loadedAnimSet = nil
local activePostFx = nil
local lastBlackoutTime = 0
local lastStumbleTime = 0
local isNauseous = false
local nextNauseaCheck = 0

--- Calculate drunk stage using hysteresis to avoid edge flickering
---@param points number
---@param current number
---@return number 0 to 4
local function getStageWithHysteresis(points, current)
    local t = Config.Thresholds
    local margin = t.Margin or 4

    if points >= t.Level4 then
        return 4
    elseif points >= (current == 4 and (t.Level4 - margin) or t.Level3) then
        return 3
    elseif points >= (current == 3 and (t.Level3 - margin) or t.Level2) then
        return 2
    elseif points >= (current == 2 and (t.Level2 - margin) or t.Level1) then
        return 1
    elseif points >= (current == 1 and (t.Level1 - margin) or 1) then
        if points <= 0 then return 0 end
        return current > 0 and 1 or 0
    end
    return 0
end

--- Apply or clear movement clipset safely
---@param animset string?
local function setMovementClipset(animset)
    local ped = cache.ped or PlayerPedId()
    if loadedAnimSet == animset then return end

    if animset then
        lib.requestAnimSet(animset)
        SetPedMovementClipset(ped, animset, 1.0)
        loadedAnimSet = animset
    else
        ResetPedMovementClipset(ped, 0.0)
        loadedAnimSet = nil
    end
end

--- Apply or clear postfx safely
---@param fxName string?
local function setPostFx(fxName)
    if activePostFx == fxName then return end
    if activePostFx then
        AnimpostfxStop(activePostFx)
        activePostFx = nil
    end
    if fxName then
        AnimpostfxPlay(fxName, 0, true)
        activePostFx = fxName
    end
end

--- Check if player ped is in a valid state to pass out
---@param ped number
---@return boolean
local function canBlackout(ped)
    if isBlackedOut then return false end
    if IsPedDeadOrDying(ped, true) then return false end
    if IsPedRagdoll(ped) then return false end
    if IsPedFalling(ped) then return false end
    if IsPedClimbing(ped) then return false end
    if IsPedSwimming(ped) or IsPedSwimmingUnderWater(ped) then return false end
    return true
end

--- Clear all local client effects (visual, physical, audio)
local function clearAllEffects()
    local ped = cache.ped or PlayerPedId()
    ClearTimecycleModifier()
    if activePostFx then
        AnimpostfxStop(activePostFx)
        activePostFx = nil
    end
    AnimpostfxStop("DrugsMichaelAliensFightIn")
    AnimpostfxStop("DrugsTrevorClownsFightIn")
    ShakeGameplayCam("DRUNK_SHAKE", 0.0)
    StopGameplayCamShaking(true)
    setMovementClipset(nil)
    SetPedIsDrunk(ped, false)
    SetPedMotionBlur(ped, false)
    Audio.Clear()
    currentAlcohol = 0
    currentStage = 0
    isBlackedOut = false
    isNauseous = false
    nextNauseaCheck = 0
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then
        SetVehicleSteerBias(veh, 0.0)
    end
end

--- Play complete vomiting sequence with verified GTA V Trevor anim, sound & particle fx
---@param ped number?
local function playVomitAnimation(ped)
    ped = ped or (cache.ped or PlayerPedId())
    local inVeh = IsPedInAnyVehicle(ped, false)

    if inVeh then
        PlayPedAmbientSpeechNative(ped, "CHOKE", "SPEECH_PARAMS_FORCE")
        ShakeGameplayCam("DRUNK_SHAKE", 1.8)
        return
    end

    local animDict = 'missheistpaletoscore1leadinout'
    local animName = 'trv_puking_leadout'
    local ptfxAsset = 'scr_paletoscore'
    local ptfxName = 'scr_trev_puke'

    -- Request animation dictionary
    RequestAnimDict(animDict)
    local timeout = GetGameTimer() + 3000
    while not HasAnimDictLoaded(animDict) and GetGameTimer() < timeout do
        Wait(10)
    end

    local animLoaded = HasAnimDictLoaded(animDict)
    print(string.format('^3[daddy_alcohol:debug] Vomit animDict %s loaded: %s^7', animDict, tostring(animLoaded)))

    if animLoaded then
        ClearPedTasksImmediately(ped)
        -- Flag 0: plays full body bending forward hands on knees
        TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, 5000, 0, 0.0, false, false, false)

        -- Load & trigger particle effect from mouth (bone 31086 = SKEL_Head)
        RequestNamedPtfxAsset(ptfxAsset)
        local ptfxTimeout = GetGameTimer() + 1500
        while not HasNamedPtfxAssetLoaded(ptfxAsset) and GetGameTimer() < ptfxTimeout do
            Wait(10)
        end

        local pfx = nil
        if HasNamedPtfxAssetLoaded(ptfxAsset) then
            UseParticleFxAssetNextCall(ptfxAsset)
            pfx = StartParticleFxLoopedOnPedBone(ptfxName, ped, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 31086, 1.0, false, false, false)
        end

        PlayPedAmbientSpeechNative(ped, "CHOKE", "SPEECH_PARAMS_FORCE")

        CreateThread(function()
            Wait(2500)
            if pfx and DoesParticleFxLoopedExist(pfx) then
                StopParticleFxLooped(pfx, false)
            end
            if HasNamedPtfxAssetLoaded(ptfxAsset) then
                RemoveNamedPtfxAsset(ptfxAsset)
            end
            Wait(2500)
            ClearPedTasks(ped)
            RemoveAnimDict(animDict)
        end)
    else
        -- Fallback: cylex_animmenuv2 emote
        pcall(function()
            if exports['cylex_animmenuv2'] then
                exports['cylex_animmenuv2']:playEmote('puke')
                CreateThread(function()
                    Wait(4500)
                    exports['cylex_animmenuv2']:playEmote('c')
                end)
            end
        end)
        PlayPedAmbientSpeechNative(ped, "CHOKE", "SPEECH_PARAMS_FORCE")
    end
end

--- Blackout routine
local function triggerBlackout()
    local ped = cache.ped or PlayerPedId()
    if not canBlackout(ped) then return end

    local now = GetGameTimer()
    if now - lastBlackoutTime < (Config.Blackout.CooldownMs or 180000) then
        return
    end

    lastBlackoutTime = now
    isBlackedOut = true

    CreateThread(function()
        exports.qbx_core:Notify('Aşırı alkolden dolayı gözlerin kararıyor ve sızıyorsun...', 'error', 4000)
        Audio.PlayVomit(ped)

        Wait(1200)
        DoScreenFadeOut(1200)
        Wait(1500)

        Audio.ApplyStage(4, currentDrinkType)
        SetPedToRagdoll(ped, Config.Blackout.DurationMs, Config.Blackout.DurationMs, 0, true, true, false)

        Wait(Config.Blackout.DurationMs)

        DoScreenFadeIn(1500)
        Wait(1000)

        local health = GetEntityHealth(ped)
        if health > 115 then
            pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
            SetEntityHealth(ped, health - (Config.Blackout.WakeupDamage or 10))
        end

        exports.qbx_core:Notify('Zonklayan bir baş ağrısıyla yavaşça kendine geldin.', 'inform', 5000)
        Audio.PlayVomit(ped)

        TriggerServerEvent('daddy_alcohol:server:blackoutWakeup')
        isBlackedOut = false
    end)
end

--- Central update for visual, audio and physical effects
---@param points number
---@param drinkType string?
local function updateAlcoholEffects(points, drinkType)
    currentAlcohol = math.max(0, math.min(Config.MaxAlcohol, points))
    local newStage = getStageWithHysteresis(currentAlcohol, currentStage)
    local ped = cache.ped or PlayerPedId()

    if drinkType and Config.VisualProfiles[drinkType] then
        currentDrinkType = drinkType
    end

    if newStage == 0 then
        clearAllEffects()
        return
    end

    currentStage = newStage

    local profile = Config.VisualProfiles[currentDrinkType] or Config.VisualProfiles['shot']

    -- 1. Apply movement clipset
    local clipset = profile.clipset and profile.clipset[currentStage]
    setMovementClipset(clipset)

    -- 2. Apply Timecycle modifier & strength
    if profile.timecycle then
        SetTimecycleModifier(profile.timecycle)
        local strength = (profile.strength and profile.strength[currentStage]) or 0.6
        SetTimecycleModifierStrength(strength)
    else
        ClearTimecycleModifier()
    end

    -- 3. Apply PostFX
    local postfx = profile.postfx and profile.postfx[currentStage]
    setPostFx(postfx)

    -- 4. Apply Camera shake
    local shakeAmt = (profile.shake and profile.shake[currentStage]) or 0.5
    ShakeGameplayCam("DRUNK_SHAKE", shakeAmt)

    -- 5. Motion blur & ped drunk flag
    if currentStage >= 2 then
        SetPedIsDrunk(ped, true)
        SetPedMotionBlur(ped, true)
    else
        SetPedIsDrunk(ped, false)
        SetPedMotionBlur(ped, false)
    end

    -- 6. Audio manager stage update (PMA-Voice submix + Heartbeat)
    Audio.ApplyStage(currentStage, currentDrinkType)
    Audio.UpdateHeartbeat(currentAlcohol)

    -- 7. Blackout check
    if currentStage == 4 and Config.Blackout.Enabled and not isBlackedOut then
        triggerBlackout()
    end
end

-- Drunk driving thread with INVERTED STEERING (sağa basınca sola, sola basınca sağa gitme)
CreateThread(function()
    local lastVehicle = nil
    local driftDirection = 0.0
    local nextDriftChange = 0
    local nextHornTime = 0

    while true do
        if currentStage >= 2 and Config.DrunkDriving.Enabled and not isBlackedOut then
            local ped = cache.ped or PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)

            if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
                lastVehicle = veh
                local speed = GetEntitySpeed(veh)

                -- Only affect moving vehicles (> 1.0 m/s ~ 3.6 km/h)
                if speed > 1.0 then
                    local now = GetGameTimer()

                    -- Update random drift/wobble direction periodically
                    if now >= nextDriftChange then
                        local wobbleStr = Config.DrunkDriving.WobbleStrength or 0.75
                        if math.random() < (Config.DrunkDriving.SteerWobbleChance or 0.40) then
                            driftDirection = (math.random() > 0.5) and (wobbleStr * 0.5) or (-wobbleStr * 0.5)
                        else
                            driftDirection = 0.0
                        end
                        nextDriftChange = now + math.random(1500, 3000)
                    end

                    -- Read steering inputs
                    local isSteeringLeft = IsControlPressed(0, 63) -- A key or left stick
                    local isSteeringRight = IsControlPressed(0, 64) -- D key or right stick
                    local analogSteer = GetDisabledControlNormal(0, 59) -- Analog steering axis

                    if currentStage >= 3 and Config.DrunkDriving.InvertSteering then
                        -- STAGE 3 (Heavy - 70+ points): 100% INVERTED STEERING CONTROLS!
                        DisableControlAction(0, 59, true)
                        DisableControlAction(0, 63, true)
                        DisableControlAction(0, 64, true)

                        if isSteeringLeft or analogSteer < -0.15 then
                            -- Steer Left pressed -> Force vehicle to turn RIGHT!
                            SetVehicleSteerBias(veh, 0.90)
                        elseif isSteeringRight or analogSteer > 0.15 then
                            -- Steer Right pressed -> Force vehicle to turn LEFT!
                            SetVehicleSteerBias(veh, -0.90)
                        else
                            -- Driving straight: apply drift wobble
                            if driftDirection ~= 0.0 then
                                SetVehicleSteerBias(veh, driftDirection)
                            end
                        end

                        -- Involuntary horn honking in heavy stage
                        if now >= nextHornTime and math.random() < (Config.DrunkDriving.RandomHornChance or 0.10) then
                            StartVehicleHorn(veh, 600, "NORMAL", false)
                            nextHornTime = now + math.random(8000, 20000)
                        end

                    elseif currentStage == 2 then
                        -- STAGE 2 (Moderate - 40-69 points): Gentle steering drift/wobble (no inverted controls)
                        local invertChance = Config.DrunkDriving.ModerateInvertChance or 0.0
                        if invertChance > 0 and (isSteeringLeft or isSteeringRight) and math.random() < invertChance then
                            DisableControlAction(0, 59, true)
                            DisableControlAction(0, 63, true)
                            DisableControlAction(0, 64, true)

                            if isSteeringLeft then
                                SetVehicleSteerBias(veh, 0.70) -- Pull right
                            elseif isSteeringRight then
                                SetVehicleSteerBias(veh, -0.70) -- Pull left
                            end
                        else
                            if driftDirection ~= 0.0 then
                                SetVehicleSteerBias(veh, driftDirection * 0.6)
                            end
                        end
                    end
                end

                Wait(0) -- Must run per frame while driving to reliably invert steering inputs
            else
                if lastVehicle then
                    SetVehicleSteerBias(lastVehicle, 0.0)
                    lastVehicle = nil
                end
                Wait(1500)
            end
        else
            if lastVehicle then
                SetVehicleSteerBias(lastVehicle, 0.0)
                lastVehicle = nil
            end
            Wait(2500)
        end
    end
end)

-- Stumble and ragdoll thread (Stage 3+)
CreateThread(function()
    while true do
        if currentStage >= 3 and Config.Ragdoll.Enabled and not isBlackedOut then
            local ped = cache.ped or PlayerPedId()
            local now = GetGameTimer()

            if now - lastStumbleTime >= (Config.Ragdoll.CooldownMs or 8000) then
                if not IsPedInAnyVehicle(ped, false)
                    and not IsPedRagdoll(ped)
                    and not IsPedDeadOrDying(ped, true)
                    and not IsPedFalling(ped)
                    and not IsPedClimbing(ped)
                    and not IsPedSwimming(ped)
                    and not IsPedSwimmingUnderWater(ped) then

                    if IsPedSprinting(ped) or IsPedRunning(ped) then
                        if math.random() < Config.Ragdoll.StumbleChanceRunning then
                            lastStumbleTime = now
                            SetPedToRagdoll(ped, 2500, 2500, 0, true, true, false)
                            Audio.PlayHiccup(ped)
                        end
                    elseif IsPedWalking(ped) then
                        if math.random() < Config.Ragdoll.StumbleChanceWalking then
                            lastStumbleTime = now
                            SetPedToRagdoll(ped, 1500, 1500, 0, true, true, false)
                        end
                    end
                end
            end
            Wait(1500)
        else
            Wait(3500)
        end
    end
end)

-- Hiccups thread (Stage 1 & 2)
CreateThread(function()
    while true do
        if currentStage >= 1 and currentStage <= 2 and not isBlackedOut and Config.Audio.Hiccups.Enabled then
            local ped = cache.ped or PlayerPedId()
            if not IsPedDeadOrDying(ped, true) then
                Audio.PlayHiccup(ped)
            end
            local waitMs = math.random(Config.Audio.Hiccups.IntervalMin, Config.Audio.Hiccups.IntervalMax)
            Wait(waitMs)
        else
            Wait(5000)
        end
    end
end)

-- Nausea & Vomit Minigame thread (75+ alcohol)
CreateThread(function()
    while true do
        if currentAlcohol >= (Config.Nausea and Config.Nausea.MinAlcohol or 75) and not isBlackedOut and not isNauseous and (Config.Nausea and Config.Nausea.Enabled) then
            local now = GetGameTimer()
            if nextNauseaCheck == 0 then
                -- Initial nausea check starts earlier (15-30s) so the player doesn't wait minutes
                nextNauseaCheck = now + math.random(15000, 30000)
            end

            if now >= nextNauseaCheck then
                local ped = cache.ped or PlayerPedId()

                if not IsPedDeadOrDying(ped, true)
                    and not IsPedRagdoll(ped)
                    and not IsPedFalling(ped)
                    and not IsPedClimbing(ped)
                    and not IsPedSwimming(ped)
                    and not IsPedSwimmingUnderWater(ped) then

                    isNauseous = true

                    -- 1. Warning signs: Groan, camera shake, warning notification
                    Audio.PlayBurp(ped)
                    ShakeGameplayCam("DRUNK_SHAKE", 1.0)
                    exports.qbx_core:Notify('Miden fena bulanıyor! Kusmamak için kendini tut!', 'error', 3000)

                    Wait(800)

                    -- 2. Trigger quick ox_lib skill check
                    local skillCfg = Config.Nausea.SkillCheck or {}
                    local diff = skillCfg.difficulty or { { areaSize = 38, speedMultiplier = 1.6 } }
                    local inputs = skillCfg.inputs or { 'e' }
                    local success = lib.skillCheck(diff, inputs)

                    if success then
                        -- Player passed: nausea subsided
                        exports.qbx_core:Notify('Derin bir nefes aldın ve mideni yatıştırdın.', 'inform', 3500)
                        nextNauseaCheck = GetGameTimer() + (Config.Nausea.SuccessCooldown or 150000)
                    else
                        -- Player failed: forced vomiting animation, ptfx, and sound
                        playVomitAnimation(ped)
                        Audio.PlayVomit(ped)
                        ShakeGameplayCam("DRUNK_SHAKE", 1.8)

                        -- Hangover damage from retching
                        local health = GetEntityHealth(ped)
                        local damage = Config.Nausea.FailedDamage or 5
                        if health > (100 + damage) then
                            SetEntityHealth(ped, health - damage)
                        end

                        -- Server authoritative reduction of alcohol points
                        TriggerServerEvent('daddy_alcohol:server:vomited')

                        local reduction = Config.Nausea.FailedAlcoholReduction or 5
                        exports.qbx_core:Notify(string.format('Kendini tutamadın ve kustun... Miden biraz rahatladı (-%s Alkol).', reduction), 'inform', 4500)

                        nextNauseaCheck = GetGameTimer() + math.random(Config.Nausea.IntervalMin or 60000, Config.Nausea.IntervalMax or 120000)
                    end

                    isNauseous = false
                else
                    nextNauseaCheck = now + 15000
                end
            end
            Wait(2000)
        else
            nextNauseaCheck = 0
            Wait(4000)
        end
    end
end)

-- Server sync event
RegisterNetEvent('daddy_alcohol:client:syncAlcohol', function(newPoints, reason, drinkType)
    updateAlcoholEffects(newPoints, drinkType)
end)

-- Burp event
RegisterNetEvent('daddy_alcohol:client:playBurp', function()
    local ped = cache.ped or PlayerPedId()
    Wait(1200)
    Audio.PlayBurp(ped)
end)

-- Tinnitus event
RegisterNetEvent('daddy_alcohol:client:playTinnitus', function()
    Audio.PlayTinnitus(true)
end)

-- Death cleanup
AddEventHandler('gameEventTriggered', function(event, data)
    if event == "CEventNetworkEntityDamage" then
        local victim = data[1]
        local ped = cache.ped or PlayerPedId()
        if victim == ped and IsPedDeadOrDying(ped, true) then
            clearAllEffects()
            TriggerServerEvent('daddy_alcohol:server:playerDied')
        end
    end
end)

-- Revive cleanup & server reset
local function onPlayerRevived()
    clearAllEffects()
    TriggerServerEvent('daddy_alcohol:server:playerRevived')
end

RegisterNetEvent('qbx_medical:client:playerRevived', onPlayerRevived)
RegisterNetEvent('hospital:client:Revive', onPlayerRevived)
RegisterNetEvent('hospital:client:RevivePlayer', onPlayerRevived)
RegisterNetEvent('esx_ambulancejob:revive', onPlayerRevived)

AddEventHandler('onResourceStop', function(resName)
    if resName ~= GetCurrentResourceName() then return end
    clearAllEffects()
end)

-- Debug and test commands
RegisterCommand('testvomit', function()
    local ped = cache.ped or PlayerPedId()
    print('^2[daddy_alcohol:debug] Testing vomit sequence...^7')
    Audio.PlayBurp(ped)
    ShakeGameplayCam("DRUNK_SHAKE", 1.8)
    playVomitAnimation(ped)
    Audio.PlayVomit(ped)
    exports.qbx_core:Notify('Test: Kusma animasyonu ve efektleri oynatılıyor!', 'inform', 4000)
end, false)

RegisterCommand('vomittest', function()
    ExecuteCommand('testvomit')
end, false)

RegisterCommand('testnausea', function()
    local ped = cache.ped or PlayerPedId()
    print('^2[daddy_alcohol:debug] Testing nausea minigame...^7')
    Audio.PlayBurp(ped)
    ShakeGameplayCam("DRUNK_SHAKE", 1.0)
    exports.qbx_core:Notify('Miden fena bulanıyor! Kusmamak için kendini tut!', 'error', 3000)
    Wait(800)
    local skillCfg = Config.Nausea.SkillCheck or {}
    local diff = skillCfg.difficulty or { { areaSize = 38, speedMultiplier = 1.6 } }
    local inputs = skillCfg.inputs or { 'e' }
    local success = lib.skillCheck(diff, inputs)
    if success then
        exports.qbx_core:Notify('Derin bir nefes aldın ve mideni yatıştırdın.', 'inform', 3500)
    else
        playVomitAnimation(ped)
        Audio.PlayVomit(ped)
        ShakeGameplayCam("DRUNK_SHAKE", 1.8)
        TriggerServerEvent('daddy_alcohol:server:vomited')
        exports.qbx_core:Notify('Kendini tutamadın ve kustun... Miden biraz rahatladı (-5 Alkol).', 'inform', 4500)
    end
end, false)

-- Client exports
exports('GetAlcoholLevel', function()
    return currentAlcohol
end)

exports('GetAlcoholStage', function()
    return currentStage
end)

exports('GetDrinkType', function()
    return currentDrinkType
end)

exports('ClearAlcoholEffects', function()
    clearAllEffects()
end)

exports('PlayVomit', function()
    local ped = cache.ped or PlayerPedId()
    playVomitAnimation(ped)
    Audio.PlayVomit(ped)
end)

-- Backward compatibility alias (only clears local visuals, server state remains authoritative)
exports('ClearAlcohol', function()
    clearAllEffects()
end)
