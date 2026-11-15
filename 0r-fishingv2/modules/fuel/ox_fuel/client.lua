local Config <const> = require 'config.main'

local resourceName = "ox_fuel"
local configValue = Config.Fuel
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end
--print("Fuel: Loading ox_fuel")
Fuel = Fuel or {}

Fuel.GetFuel = function(vehicle)
    if not DoesEntityExist(vehicle) then return 0.0 end
    return Entity(vehicle).state.fuel
end

Fuel.SetFuel = function(vehicle, newFuel, type)
    if not DoesEntityExist(vehicle) then return end
    local fuel = Entity(vehicle).state.fuel

    if fuel then
        Entity(vehicle).state.fuel = fuel + newFuel
    else
        Entity(vehicle).state.fuel = newFuel
    end
    
    return Entity(vehicle).state.fuel
end
