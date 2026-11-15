-- ============================================================================
-- Daddy GPS - Client Main
-- ============================================================================
-- GPS state management, position updates to server.
-- The main player blip is NEVER touched — it stays as GTA's default.
-- Other officers' blips are managed by the blip render/event systems.
-- ============================================================================

GPS_Client = {
    IsOpen         = false,
    CachedCallsign = nil,
    CachedProfile  = nil, -- { department, officerName, callsign }
    CachedUnits    = nil, -- last known unit list for instant reopen
}



-- ============================================================================
-- Position Update Thread
-- ============================================================================
-- Export referansı cache'lendi, her iterasyonda proxy tablo araması yapılmaz
local _isGPSBroken = exports['daddy-gps']

-- Lookup table: GTA vehicle class → GPS vType ID
-- Listelenmeyenler 2 (generic vehicle) olarak düşer
local CLASS_TO_VTYPE = {
    [8]  = 3, -- Motorcycle
    [14] = 4, -- Boat
    [15] = 5, -- Helicopter
    [16] = 6, -- Plane
}

CreateThread(function()
    while true do
        if GPS_Client.IsOpen and not _isGPSBroken:IsGPSBroken() then
            local ped      = PlayerPedId()
            local coords   = GetEntityCoords(ped)
            local heading  = GetEntityHeading(ped)
            local vType    = 1
            local siren    = false
            local vehNetId = 0
            local vehSeat  = -2

            -- GetVehiclePedIsIn araçta değilken 0 döndürür,
            -- IsPedInAnyVehicle ayrı çağrısına gerek yoktur.
            local veh      = GetVehiclePedIsIn(ped, false)
            if veh ~= 0 then
                heading = GetEntityHeading(veh)
                local cls = GetVehicleClass(veh)
                vType = CLASS_TO_VTYPE[cls] or 2

                if NetworkGetEntityIsNetworked(veh) then
                    vehNetId = NetworkGetNetworkIdFromEntity(veh)
                end

                -- Seat index: -1 = driver, 0+ = passengers
                for s = -1, GetVehicleMaxNumberOfPassengers(veh) - 1 do
                    if GetPedInVehicleSeat(veh, s) == ped then
                        vehSeat = s
                        break
                    end
                end

                -- vehSeat döngüde tespit edildiğinden GetPedInVehicleSeat(-1) tekrar çağrılmaz.
                -- not not: eski artifactlarda native 1 döndürebilir; sunucu == true kontrolü için normalize edilir.
                if cls == 18 and vehSeat == -1 then
                    siren = not not IsVehicleSirenOn(veh)
                end
            end

            TriggerServerEvent('daddy:gps:update', {
                x        = coords.x,
                y        = coords.y,
                z        = coords.z,
                h        = heading,
                vType    = vType,
                siren    = siren,
                vehNetId = vehNetId,
                vehSeat  = vehSeat,
            })

            Wait(3500)
        else
            Wait(6000)
        end
    end
end)


-- ============================================================================
-- GPS Disconnect Handler
-- ============================================================================

AddEventHandler('daddy:gps:disconnected', function()
    GPS_Client.IsOpen = false
    GPS_Client.CachedCallsign = nil
    if LocalPlayer and LocalPlayer.state and LocalPlayer.state.set then
        LocalPlayer.state:set('callsign', '', true)
    end
end)

-- ============================================================================
-- Resource Stop Cleanup
-- ============================================================================

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end

    if GPS_Client.IsOpen then
        TriggerEvent('daddy:gps:disconnected')
        GPS_Client.IsOpen = false
        GPS_Client.CachedCallsign = nil

        if LocalPlayer and LocalPlayer.state and LocalPlayer.state.set then
            LocalPlayer.state:set('callsign', 0, true)
        end
    end
end)

-- ============================================================================
-- Exports
-- ============================================================================

function GetCallsign()
    if GPS_Client.CachedCallsign ~= nil then
        return GPS_Client.CachedCallsign
    end
    if LocalPlayer and LocalPlayer.state then
        return LocalPlayer.state.callsign
    end
    return nil
end

function GetCurrentProfile()
    if not GPS_Client.IsOpen then return nil end
    return { callsign = GPS_Client.CachedCallsign }
end

function GetGpsState()
    return {
        isOpen = GPS_Client.IsOpen,
        isConnected = IsConnected,
        callsign = GPS_Client.CachedCallsign,
    }
end

exports('GetCallsign', GetCallsign)
exports('GetCurrentProfile', GetCurrentProfile)
exports('GetGpsState', GetGpsState)
