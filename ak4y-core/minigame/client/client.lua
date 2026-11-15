-- Minigame result storage
local minigame1Result = nil
local minigame1Resolve = nil
local minigame2Result = nil
local minigame2Resolve = nil

RegisterNUICallback('hackResult', function(data, cb)
    cb('ok')
    SetNuiFocus(false, false)
    
    local success = data.success == true
    minigame1Result = success
    
    if minigame1Resolve then
        minigame1Resolve(success)
        minigame1Resolve = nil
    end
    
    if data.success then
        -- print("^2[ak4y-core]^7 Minigame hack successful! Result: true")
        TriggerEvent('ak4y-core:minigame:hackDone', true)
    else
        -- print("^1[ak4y-core]^7 Minigame hack failed! Result: false")
        TriggerEvent('ak4y-core:minigame:hackDone', false)
    end
end)

RegisterNUICallback('closeHackMinigame', function(data, cb)
    cb('ok')
    SetNuiFocus(false, false)
end)

function StartMinigame1()
    minigame1Result = nil
    minigame1Resolve = nil
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openHackMinigame'
    })
    
    -- Wait for result
    local promise = {}
    promise.result = nil
    promise.resolved = false
    
    minigame1Resolve = function(result)
        promise.result = result
        promise.resolved = true
    end
    
    -- Wait for result with timeout (60 seconds max)
    local timeout = GetGameTimer() + 60000
    while not promise.resolved do
        Wait(0)
        if GetGameTimer() > timeout then
            minigame1Resolve = nil
            SetNuiFocus(false, false)
            return false
        end
    end
    
    return promise.result
end

exports('StartMinigame1', StartMinigame1)
exports('StartMinigame', StartMinigame1) -- Backward compatibility

RegisterCommand('testminigame', function()
    local result = exports['ak4y-core']:StartMinigame1()
    -- print("^3[TEST]^7 Minigame1 Result: " .. tostring(result))
end, false)

-- Firewall Minigame
RegisterNUICallback('firewallResult', function(data, cb)
    cb('ok')
    SetNuiFocus(false, false)
    
    local success = data.success == true
    minigame2Result = success
    
    if minigame2Resolve then
        minigame2Resolve(success)
        minigame2Resolve = nil
    end
    
    if data.success then
        -- print("^2[ak4y-core]^7 Firewall minigame successful! Result: true")
        TriggerEvent('ak4y-core:minigame:firewallDone', true)
    else
        -- print("^1[ak4y-core]^7 Firewall minigame failed! Result: false")
        TriggerEvent('ak4y-core:minigame:firewallDone', false)
    end
end)

RegisterNUICallback('closeFirewallMinigame', function(data, cb)
    cb('ok')
    SetNuiFocus(false, false)
end)

function StartMinigame2()
    minigame2Result = nil
    minigame2Resolve = nil
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openFirewallMinigame'
    })
    
    -- Wait for result
    local promise = {}
    promise.result = nil
    promise.resolved = false
    
    minigame2Resolve = function(result)
        promise.result = result
        promise.resolved = true
    end
    
    -- Wait for result with timeout (60 seconds max)
    local timeout = GetGameTimer() + 60000
    while not promise.resolved do
        Wait(0)
        if GetGameTimer() > timeout then
            minigame2Resolve = nil
            SetNuiFocus(false, false)
            return false
        end
    end
    
    return promise.result
end

exports('StartMinigame2', StartMinigame2)
exports('StartFirewallMinigame', StartMinigame2) -- Backward compatibility

RegisterCommand('testminigame2', function()
    local result = exports['ak4y-core']:StartMinigame2()
    -- print("^3[TEST]^7 Minigame2 Result: " .. tostring(result))
end, false)

