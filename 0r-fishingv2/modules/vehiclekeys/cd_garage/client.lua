local Config <const> = require 'config.main'

local resourceName = "cd_garage"
local configValue = Config.VehicleKey
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate then return false end
    TriggerEvent('cd_garage:AddKeys', plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    return true
end