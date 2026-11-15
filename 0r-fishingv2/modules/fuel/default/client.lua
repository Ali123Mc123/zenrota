local Config <const> = require 'config.main'

local resourceName = "default"
local configValue = Config.Fuel
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

Fuel = Fuel or {}

---This will get the fuel level of the vehicle.
---@param vehicle number The vehicle entity ID.
---@return number fuel The fuel level of the vehicle.
Fuel.GetFuel = function(vehicle)
    if not DoesEntityExist(vehicle) then return 0.0 end
    return GetVehicleFuelLevel(vehicle)
end

---This will set the fuel level of the vehicle.
---@param vehicle number The vehicle entity ID.
---@param fuel number The fuel level to set.
---@return nil
Fuel.SetFuel = function(vehicle, fuel)
    if not DoesEntityExist(vehicle) then return end
    return SetVehicleFuelLevel(vehicle, fuel)
end