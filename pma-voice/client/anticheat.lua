local maxProximity = 150.0
local maxAllowedProximity = maxProximity + 10.0
local checkInterval = 5000
local proximityViolationCount = 0
local maxViolationsBeforeBan = 3
local lastViolationTime = 0
local violationResetTime = 30000

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(500)
    end
    
    Wait(5000)
    
    while true do
        Wait(checkInterval)
        
        local proximity = MumbleGetTalkerProximity()
        local currentTime = GetGameTimer()
        
        if currentTime - lastViolationTime > violationResetTime then
            proximityViolationCount = 0
        end
        
        if proximity > maxAllowedProximity then
            proximityViolationCount = proximityViolationCount + 1
            lastViolationTime = currentTime
            
            if proximityViolationCount >= maxViolationsBeforeBan then
                TriggerServerEvent('pma-voice:server:cheater', proximity, proximityViolationCount)
                proximityViolationCount = 0 
            end
        end
    end
end)
