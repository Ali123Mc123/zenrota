local Config <const> = require 'config.main'

local resourceName = "wais-vehiclekey"
local configValue = Config.VehicleKey
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

VehicleKey = VehicleKey or {}

-- DaddyRP: the key comes from the server (wais-vehiclekey's GiveKeys after it checks the player drives that boat);
-- the local event alone was often lost and the rented boat had no key.
VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate then return false end
    TriggerEvent('vehiclekeys:client:SetOwner', plate)
    if vehicle and vehicle ~= 0 then TriggerServerEvent(Scriptname .. ':server:boatKey', NetworkGetNetworkIdFromEntity(vehicle)) end
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    return true
end
