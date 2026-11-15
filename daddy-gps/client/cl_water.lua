local GPSBroken = false
local WasConnected = false
local WasConnectedBeforeBreak = false

local function IsGPSBroken()
    if not Config.WaterDamage.Enabled then return false end
    return GPSBroken
end

local function BreakGPS()
    if not Config.WaterDamage.Enabled then return end
    if GPSBroken then return end
    
    GPSBroken = true
    WasConnectedBeforeBreak = WasConnected or GPS_Client.IsOpen
    
    if Config.Debug then
        print('[daddy-gps:water] GPS damaged by water!')
    end
    
    -- Disconnect from server
    TriggerServerEvent('daddy:gps:leave')
    
    -- Reset all client state
    GPS_Client.IsOpen = false
    GPS_Client.CachedCallsign = nil
    
    if LocalPlayer and LocalPlayer.state and LocalPlayer.state.set then
        LocalPlayer.state:set('callsign', '', true)
    end
    
    TriggerEvent('daddy:gps:disconnected')
    WasConnected = false
    
    -- Force close NUI and reset UI state
    TriggerEvent('daddy:gps:forceCloseUI')
end

local function RepairGPS()
    if not GPSBroken then return end
    
    GPSBroken = false
    
    if Config.Debug then
        print('[daddy-gps:water] GPS repaired!')
    end
    
    Framework.Notify(nil, L('notify.gps_repaired', 'GPS device repaired successfully!'), 'success')
    
    -- Auto-reconnect if was previously connected
    if WasConnectedBeforeBreak then
        WasConnectedBeforeBreak = false
        SetTimeout(500, function()
            TriggerEvent('daddy:gps:attemptReconnect')
        end)
    end
end

AddEventHandler('daddy:gps:connected', function()
    WasConnected = true
end)

AddEventHandler('daddy:gps:disconnected', function()
    WasConnected = false
end)

CreateThread(function()
    if not Config.WaterDamage.Enabled then 
        return 
    end
    
    while true do
        Wait(4000) -- Check every 2 seconds
        
        local success, result = pcall(function()
            local ped = PlayerPedId()
            
            if ped and ped ~= 0 then
                local inVehicle = IsPedInAnyVehicle(ped, false)
                
                if not inVehicle then
                    -- Only trigger when actually swimming (submerged level > 0.5)
                    -- This prevents puddles and shallow water from breaking GPS
                    local isSwimming = IsPedSwimming(ped)
                    local submergedLevel = GetEntitySubmergedLevel(ped)
                    
                    if isSwimming and submergedLevel > 0.5 and not GPSBroken then
                        -- print('[daddy-gps:water] BREAKING GPS NOW! (Swimming, submerged: ' .. tostring(submergedLevel) .. ')')
                        BreakGPS()
                    end
                end
            end
        end)
        
        if not success then
            print('[daddy-gps:water] Error in water detection:', result)
        end
    end
end)

AddEventHandler('gameEventTriggered', function(event, data)
    if event == "CEventNetworkEntityDamage" then
        local victim = data[1]
        local isDead = data[4] == 1
        
        if isDead and victim == PlayerPedId() then
            print('[daddy-gps:water] Player died. WasConnected:', WasConnected)
            if WasConnected then
                print('[daddy-gps:water] Triggering disconnect due to death')
                TriggerServerEvent('daddy:gps:leave')
                TriggerEvent('daddy:gps:disconnected')
                WasConnected = false
            end
        end
    end
end)

exports('IsGPSBroken', IsGPSBroken)
exports('RepairGPS', RepairGPS)
exports('IsInWater', function() 
    local ped = PlayerPedId()
    if ped and ped ~= 0 then
        return IsPedSwimming(ped) and GetEntitySubmergedLevel(ped) > 0.5
    end
    return false
end)

