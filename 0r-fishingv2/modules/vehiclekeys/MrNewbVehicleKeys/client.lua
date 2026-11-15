local Config <const> = require 'config.main'

local resourceName = "MrNewbVehicleKeys"
local configValue = Config.VehicleKey
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not vehicle and not DoesEntityExist(vehicle) then return false end
    exports.MrNewbVehicleKeys:GiveKeysByPlate(plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    if not vehicle and not DoesEntityExist(vehicle) then return false end
    exports.MrNewbVehicleKeys:RemoveKeysByPlate(plate)
end