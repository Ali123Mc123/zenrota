Audio = {}

local currentStage = 0
local submixStage2 = nil
local submixStage3 = nil
local submixesReady = false
local currentTargetSubmix = -1
local heartbeatSoundId = -1
local isHeartbeatPlaying = false
local lastTinnitusTime = 0

local function logAudio(msg)
    if Config.DebugAudio or (Config.Audio and Config.Audio.Debug) then
        print(string.format('^3[daddy_alcohol:audio] %s^7', msg))
    end
end

--- Initialize PMA-Voice RadioFX Audio Submixes for voice chat muffling
local function initVoiceSubmixes()
    if submixesReady then return end

    local cfg = Config.Audio.PmaVoice or {}
    local stage2Freq = cfg.Stage2FreqHi or 950.0
    local stage3Freq = cfg.Stage3FreqHi or 480.0

    -- Stage 2 (Moderate): Mild Low-Pass Voice Muffle
    submixStage2 = CreateAudioSubmix('DrunkVoiceStage2')
    SetAudioSubmixEffectRadioFx(submixStage2, 0)
    SetAudioSubmixEffectParamInt(submixStage2, 0, GetHashKey('default'), 1)
    SetAudioSubmixEffectParamFloat(submixStage2, 0, GetHashKey('freq_low'), 120.0)
    SetAudioSubmixEffectParamFloat(submixStage2, 0, GetHashKey('freq_hi'), stage2Freq)
    SetAudioSubmixEffectParamFloat(submixStage2, 0, GetHashKey('fudge'), 0.3)
    SetAudioSubmixEffectParamFloat(submixStage2, 0, GetHashKey('rm_mix'), 0.08)
    AddAudioSubmixOutput(submixStage2, 0)

    -- Stage 3 (Heavy): Deep Low-Pass Voice Muffle (Underwater/slurred speech feel)
    submixStage3 = CreateAudioSubmix('DrunkVoiceStage3')
    SetAudioSubmixEffectRadioFx(submixStage3, 0)
    SetAudioSubmixEffectParamInt(submixStage3, 0, GetHashKey('default'), 1)
    SetAudioSubmixEffectParamFloat(submixStage3, 0, GetHashKey('freq_low'), 80.0)
    SetAudioSubmixEffectParamFloat(submixStage3, 0, GetHashKey('freq_hi'), stage3Freq)
    SetAudioSubmixEffectParamFloat(submixStage3, 0, GetHashKey('fudge'), 0.6)
    SetAudioSubmixEffectParamFloat(submixStage3, 0, GetHashKey('rm_mix'), 0.15)
    AddAudioSubmixOutput(submixStage3, 0)

    submixesReady = true
    logAudio('PMA-Voice Audio submixes created successfully')

    -- Register submixes with pma-voice if available
    pcall(function()
        if exports['pma-voice'] and exports['pma-voice'].registerCustomSubmix then
            exports['pma-voice']:registerCustomSubmix(function()
                return { 'drunk_moderate', submixStage2 }
            end)
            exports['pma-voice']:registerCustomSubmix(function()
                return { 'drunk_heavy', submixStage3 }
            end)
        end
    end)
end

--- Apply muffled submix to all active players around the drunk client
local function applySubmixToNearbyPlayers(targetSubmix)
    local myServerId = GetPlayerServerId(PlayerId())
    for _, ply in ipairs(GetActivePlayers()) do
        local sId = GetPlayerServerId(ply)
        if sId ~= myServerId and sId > 0 then
            MumbleSetSubmixForServerId(sId, targetSubmix)
        end
    end
end

--- Update voice muffling based on stage
---@param stage number
function Audio.ApplyStage(stage, profile)
    if stage == currentStage then return end
    currentStage = stage

    initVoiceSubmixes()

    local pmaCfg = Config.Audio.PmaVoice
    if not pmaCfg or not pmaCfg.Enabled then return end

    local targetSubmix = -1
    if stage == 2 then
        targetSubmix = submixStage2
        logAudio('Applied Stage 2 Voice Muffle')
    elseif stage >= 3 then
        targetSubmix = submixStage3
        logAudio('Applied Stage 3 Heavy Voice Muffle')
    else
        targetSubmix = -1
        logAudio('Restored normal voice audio')
    end

    if targetSubmix ~= currentTargetSubmix then
        currentTargetSubmix = targetSubmix
        applySubmixToNearbyPlayers(currentTargetSubmix)

        -- Broadcast StateBag submix so others can optionally hear drunk slurring
        if targetSubmix == submixStage2 then
            TriggerServerEvent('daddy_alcohol:server:setVoiceSubmix', 'drunk_moderate')
        elseif targetSubmix == submixStage3 then
            TriggerServerEvent('daddy_alcohol:server:setVoiceSubmix', 'drunk_heavy')
        else
            TriggerServerEvent('daddy_alcohol:server:setVoiceSubmix', nil)
        end
    end
end

-- Periodic thread to ensure incoming players in range also get the voice submix while drunk
CreateThread(function()
    while true do
        if currentTargetSubmix ~= -1 then
            applySubmixToNearbyPlayers(currentTargetSubmix)
            Wait(1000)
        else
            Wait(3000)
        end
    end
end)

--- Start or stop managed heartbeat loop
---@param alcoholLevel number
function Audio.UpdateHeartbeat(alcoholLevel)
    local cfg = Config.Audio.Heartbeat
    if not cfg or not cfg.Enabled then
        Audio.StopHeartbeat()
        return
    end

    local shouldPlay = alcoholLevel >= (cfg.MinAlcohol or 80)

    if shouldPlay and not isHeartbeatPlaying then
        heartbeatSoundId = GetSoundId()
        PlaySoundFrontend(heartbeatSoundId, cfg.SoundName or "Heartbeat_Loop", cfg.SoundSet or "Special_Abilities_Sounds", true)
        isHeartbeatPlaying = true
        logAudio('Started heartbeat loop')
    elseif not shouldPlay and isHeartbeatPlaying then
        Audio.StopHeartbeat()
    end
end

--- Stop heartbeat loop cleanly
function Audio.StopHeartbeat()
    if isHeartbeatPlaying and heartbeatSoundId ~= -1 then
        StopSound(heartbeatSoundId)
        ReleaseSoundId(heartbeatSoundId)
        heartbeatSoundId = -1
        isHeartbeatPlaying = false
        logAudio('Stopped heartbeat loop')
    end
end

--- Play ear ringing (tinnitus) accent with cooldown
---@param force boolean?
function Audio.PlayTinnitus(force)
    local cfg = Config.Audio.Tinnitus
    if not cfg or not cfg.Enabled then return end

    local now = GetGameTimer()
    if not force and (now - lastTinnitusTime < (cfg.CooldownMs or 45000)) then
        return
    end

    lastTinnitusTime = now
    logAudio('Playing tinnitus sound')
    CreateThread(function()
        PlaySoundFrontend(-1, cfg.SoundName or "Bed", cfg.SoundSet or "WastedSounds", true)
    end)
end

--- Play hiccup vocal and camera twitch
---@param ped number
function Audio.PlayHiccup(ped)
    if not Config.Audio.Hiccups.Enabled then return end
    PlayPedAmbientSpeechNative(ped, "GENERIC_SHOCK", "SPEECH_PARAMS_FORCE")
    ShakeGameplayCam("DRUNK_SHAKE", 0.55)
end

--- Play burp vocal
---@param ped number
function Audio.PlayBurp(ped)
    if not Config.Audio.BurpOnBeer then return end
    PlayPedAmbientSpeechNative(ped, "GENERIC_GROAN", "SPEECH_PARAMS_FORCE")
end

--- Play vomit sound effect
---@param ped number
function Audio.PlayVomit(ped)
    ped = ped or (cache.ped or PlayerPedId())
    PlayPedAmbientSpeechNative(ped, "CHOKE", "SPEECH_PARAMS_FORCE")
    PlayPedAmbientSpeechNative(ped, "GENERIC_GROAN", "SPEECH_PARAMS_FORCE")
end

--- Complete cleanup of all audio states
function Audio.Clear()
    if currentTargetSubmix ~= -1 then
        applySubmixToNearbyPlayers(-1)
        currentTargetSubmix = -1
        TriggerServerEvent('daddy_alcohol:server:setVoiceSubmix', nil)
    end
    Audio.StopHeartbeat()
    currentStage = 0
    logAudio('Audio manager cleared successfully')
end

-- Ensure complete voice cleanup on resource stop
AddEventHandler('onResourceStop', function(resName)
    if resName ~= GetCurrentResourceName() then return end
    Audio.Clear()
end)
