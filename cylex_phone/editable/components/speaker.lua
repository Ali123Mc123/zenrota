local speakerCallEffect = -1
local activeSpeakerCalls = {} -- [callerId] = { callId = callId, callerServerId = id, targetServerId = id, voiceTargets = {} }

if Config.Voice.Script == "mumble" and Config.Voice.CallEffects then
    speakerCallEffect = MumbleCreateSubmix("phone_speaker")
    MumbleAddSubmixEffect(speakerCallEffect, {
        type = "freeverb",
        roomSize = 0.2,
        damping = 0.5,
        wetLevel = 0.1,
        dryLevel = 0.9,
        width = 1.0,
        freezeMode = 0
    })
end

RegisterNetEvent('cylex_phone:client:addToSpeakerCall')
AddEventHandler('cylex_phone:client:addToSpeakerCall', function(callId, callerServerId, targetServerId)
    local playerId = GetPlayerServerId(PlayerId())
    
    if activeSpeakerCalls[callerServerId] then
        print("Already listening to caller " .. callerServerId .. "'s speaker call")
        return
    end
    
    activeSpeakerCalls[callerServerId] = {
        callId = callId,
        callerServerId = callerServerId,
        targetServerId = targetServerId,
        voiceTargets = {}
    }
    
    print("^2[Speaker] ^7Added to speaker call from caller " .. callerServerId .. " (Call: " .. callId .. ", Target: " .. targetServerId .. ")")
    
    if Config.Voice.Script == "pma" then
        exports['pma-voice']:addPlayerToCall(callId)
    elseif Config.Voice.Script == "mumble" then
        MumbleSetVolumeOverrideByServerId(callerServerId, 0.8)
        MumbleSetVolumeOverrideByServerId(targetServerId, 0.8)
        
        if speakerCallEffect ~= -1 then
            MumbleSetSubmixForServerId(callerServerId, speakerCallEffect)
            MumbleSetSubmixForServerId(targetServerId, speakerCallEffect)
        end
        
        activeSpeakerCalls[callerServerId].voiceTargets[callerServerId] = true
        activeSpeakerCalls[callerServerId].voiceTargets[targetServerId] = true
        
    elseif Config.Voice.Script == "salty" then
        TriggerServerEvent("phone:voice:addToCall", callId)
    elseif Config.Voice.Script == "toko" then
        exports['toko-voip']:addPlayerToRadio(callId)
    end
end)

RegisterNetEvent('cylex_phone:client:removeFromSpeakerCall')
AddEventHandler('cylex_phone:client:removeFromSpeakerCall', function(callerServerId)
    print('^1[Speaker] ^7Removing from speaker call of caller: ' .. tostring(callerServerId))
    
    if callerServerId and activeSpeakerCalls[callerServerId] then
        local callData = activeSpeakerCalls[callerServerId]
        
        if Config.Voice.Script == "pma" then
            exports['pma-voice']:removePlayerFromCall()
        elseif Config.Voice.Script == "mumble" then
            for serverId, _ in pairs(callData.voiceTargets) do
                MumbleSetVolumeOverrideByServerId(serverId, -1.0)
                MumbleSetSubmixForServerId(serverId, -1)
            end
        elseif Config.Voice.Script == "salty" then
            TriggerServerEvent("phone:voice:removeFromCall")
        end
        
        activeSpeakerCalls[callerServerId] = nil
        print("^1[Speaker] ^7Removed from caller " .. callerServerId .. "'s speaker call")
        
    else
        if Config.Voice.Script == "pma" then
            exports['pma-voice']:removePlayerFromCall()
        elseif Config.Voice.Script == "mumble" then
            for cId, callData in pairs(activeSpeakerCalls) do
                for serverId, _ in pairs(callData.voiceTargets) do
                    MumbleSetVolumeOverrideByServerId(serverId, -1.0)
                    MumbleSetSubmixForServerId(serverId, -1)
                end
            end
        elseif Config.Voice.Script == "salty" then
            TriggerServerEvent("phone:voice:removeFromCall")
        end
        
        activeSpeakerCalls = {}
        print("^1[Speaker] ^7Removed from all speaker calls")
    end

    voiceTargets = {}
    currentCallId = nil
    speakerMode = false
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for callerId, callData in pairs(activeSpeakerCalls) do
            if Config.Voice.Script == "mumble" then
                for serverId, _ in pairs(callData.voiceTargets) do
                    MumbleSetVolumeOverrideByServerId(serverId, -1.0)
                    MumbleSetSubmixForServerId(serverId, -1)
                end
            end
        end
        activeSpeakerCalls = {}
    end
end)