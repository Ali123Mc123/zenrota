AddEventHandler('krypton-farming:client:minigameResult', function(success, token, perfect)
    DebugPrint('[Harvest] Minigame result received:', success, 'token:', token, 'perfect:', perfect)
    if ClientState.minigameToken and token and token ~= ClientState.minigameToken then
        DebugPrint('[Harvest] Token mismatch - potential abuse detected. Expected:', ClientState.minigameToken, 'Got:', token)
        TriggerServerEvent('krypton-farming:server:logSuspiciousActivity', 'invalid_minigame_token', { expected = ClientState.minigameToken, received = token })
        return
    end
    if ClientState.minigameTimeout then
        ClearTimeout(ClientState.minigameTimeout)
        ClientState.minigameTimeout = nil
    end
    if ClientState.minigamePromise then
        -- Return result with perfect flag: { success = bool, perfect = bool }
        ClientState.minigamePromise:resolve({ success = success, perfect = perfect or false })
        ClientState.minigamePromise = nil
    else
        DebugPrint('[Harvest] WARNING: minigamePromise was nil when result arrived!')
    end
end)

function StartMinigameAsync(difficulty, currentStep, totalSteps)
    local p = promise.new()
    ClientState.minigamePromise = p

    ClientState.minigameToken = (ClientState.minigameToken or 0) + 1
    local token = ClientState.minigameToken

    if ClientState.minigameTimeout then
        ClearTimeout(ClientState.minigameTimeout)
        ClientState.minigameTimeout = nil
    end
    
    Wait(100)
    
    local perfectZoneData = nil
    if Config.Minigame and Config.Minigame.perfectZone and Config.Minigame.perfectZone.enabled then
        perfectZoneData = Config.Minigame.perfectZone
    end
    
    SetNuiFocus(true, false)
    SendNUIMessage({
        action = 'startMinigame',
        data = {
            difficulty = difficulty,
            nonce = GetGameTimer(),
            token = token,
            perfectZone = perfectZoneData,
            currentStep = currentStep or 1,
            totalSteps = totalSteps or 1
        }
    })
    
    -- Safety Timeout for minigame (15 seconds max)
    ClientState.minigameTimeout = SetTimeout(15000, function()
        if ClientState.minigamePromise and ClientState.minigameToken == token then
            DebugPrint('[Harvest] Minigame timeout - auto-failing')
            ClientState.minigamePromise:resolve({ success = false, perfect = false })
            ClientState.minigamePromise = nil
            SetNuiFocus(false, false)
        end
        ClientState.minigameTimeout = nil
    end)
    
    return Citizen.Await(p)
end

RegisterNUICallback('actionComplete', function(data, cb)
    if ClientState.actionPromise then
        ClientState.actionPromise:resolve(true)
        ClientState.actionPromise = nil
    end
    cb('ok')
end)

function StartActionAsync(text, duration)
    local p = promise.new()
    ClientState.actionPromise = p
    
    SendNUIMessage({
        action = 'startAction',
        data = { 
            text = text,
            duration = duration
        }
    })
    
    local animationTimeout = SetTimeout(duration + 1000, function()
        if ClientState.actionPromise then
            ClientState.actionPromise:resolve(true)
            ClientState.actionPromise = nil
        end
        local playerPed = PlayerPedId()
        if IsEntityPlayingAnim(playerPed, animDict, animName, 3) then
            ClearPedTasks(playerPed)
            if Config.Debug then
            end
        end
    end)
    
    local result = Citizen.Await(p)
    ClearTimeout(animationTimeout)
    return result
end
