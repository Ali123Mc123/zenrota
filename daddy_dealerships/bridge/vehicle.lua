-- Client: fuel and keys of a car that was just bought. Each entry is { id, resource, ... }; the first that runs wins
-- unless Config.Bridge names one.

-- Fuel: set(vehicle, value).
do
    local function exportFuel(resource)
        return { id = resource, resource = resource, set = function(vehicle, value) exports[resource]:SetFuel(vehicle, value + 0.0) end }
    end

    local FUELS = {
        { id = 'ox_fuel', resource = 'ox_fuel', set = function(vehicle, value) Entity(vehicle).state:set('fuel', value + 0.0, true) end },
        exportFuel('savana-fuel'),
        exportFuel('LegacyFuel'),
        exportFuel('ps-fuel'),
        exportFuel('lj-fuel'),
        exportFuel('cdn-fuel'),
        exportFuel('okokGasStation'),
    }

    local chosen
    Bridge.fuel = {
        set = function(vehicle, value)
            chosen = chosen or Bridge.pick('Fuel', FUELS) or false
            local ok = chosen and pcall(chosen.set, vehicle, value)
            if not ok then SetVehicleFuelLevel(vehicle, value + 0.0) end
        end,
    }
end

-- Keys: give(vehicle, plate) once the car is the buyer's.
do
    local KEYS = {
        { id = 'MrNewbVehicleKeys', resource = 'MrNewbVehicleKeys', give = function(vehicle) exports.MrNewbVehicleKeys:GiveKeys(vehicle) end },
        { id = 'wasabi_carlock', resource = 'wasabi_carlock', give = function(_, plate) exports.wasabi_carlock:GiveKey(plate) end },
        { id = 'qs-vehiclekeys', resource = 'qs-vehiclekeys', give = function(vehicle, plate) exports['qs-vehiclekeys']:GiveKeys(plate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), true) end },
        { id = 'Renewed-Vehiclekeys', resource = 'Renewed-Vehiclekeys', give = function(_, plate) exports['Renewed-Vehiclekeys']:addKey(plate) end },
        -- qbx_vehiclekeys gives keys on the server (server/sv_buy.lua).
        { id = 'qbx_vehiclekeys', resource = 'qbx_vehiclekeys', give = function() end },
        { id = 'qb-vehiclekeys', resource = 'qb-vehiclekeys', give = function(_, plate) TriggerEvent('vehiclekeys:client:SetOwner', plate) end },
    }

    local chosen
    Bridge.keys = {
        give = function(vehicle, plate)
            chosen = chosen or Bridge.pick('Keys', KEYS) or false
            if chosen then
                local ok, err = pcall(chosen.give, vehicle, plate)
                if not ok then Bridge.warn('keys (%s): %s', chosen.id, err) end
            end
        end,
    }
end
