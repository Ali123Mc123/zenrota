local Config <const> = require 'config.main'

local resourceName = "cdn-fuel"
local configValue = Config.Fuel
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end
--print("Fuel: Loading cdn-fuel")
--if GetResourceState('cdn-fuel') ~= 'started' then return end
Fuel = Fuel or {}

Fuel.GetFuel = function(vehicle)
    if not DoesEntityExist(vehicle) then return 0.0 end
    return exports['cdn-fuel']:GetFuel(vehicle)
end

Fuel.SetFuel = function(vehicle, fuel)
    if not DoesEntityExist(vehicle) then return end
    return exports['cdn-fuel']:SetFuel(vehicle, fuel)
end