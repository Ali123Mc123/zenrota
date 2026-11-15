-- Client: fuel and keys of a car that just came out. Each entry is { id, resource, ... }; the first that runs wins
-- unless Config.Bridge names one.

-- Fuel: get(vehicle) -> 0-100, set(vehicle, value).
do
    local function exportFuel(resource)
        return {
            id = resource,
            resource = resource,
            get = function(vehicle) return exports[resource]:GetFuel(vehicle) end,
            set = function(vehicle, value) exports[resource]:SetFuel(vehicle, value + 0.0) end,
        }
    end

    local FUELS = {
        {
            id = 'ox_fuel',
            resource = 'ox_fuel',
            get = function(vehicle) return Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle) end,
            set = function(vehicle, value) Entity(vehicle).state:set('fuel', value + 0.0, true) end,
        },
        exportFuel('savana-fuel'),
        exportFuel('LegacyFuel'),
        exportFuel('ps-fuel'),
        exportFuel('lj-fuel'),
        exportFuel('cdn-fuel'),
        exportFuel('okokGasStation'),
    }

    local NATIVE = {
        id = 'none',
        get = function(vehicle) return GetVehicleFuelLevel(vehicle) end,
        set = function(vehicle, value) SetVehicleFuelLevel(vehicle, value + 0.0) end,
    }

    local chosen
    local function fuel()
        chosen = chosen or Bridge.pick('Fuel', FUELS) or NATIVE
        return chosen
    end

    Bridge.fuel = {
        get = function(vehicle)
            local ok, value = pcall(fuel().get, vehicle)
            return ok and tonumber(value) or GetVehicleFuelLevel(vehicle)
        end,
        set = function(vehicle, value)
            local ok = pcall(fuel().set, vehicle, math.max(0.0, math.min(100.0, tonumber(value) or 100.0)))
            if not ok then SetVehicleFuelLevel(vehicle, (tonumber(value) or 100.0) + 0.0) end
        end,
    }
end

-- Keys: give(vehicle, plate) right after the car came out.
do
    local KEYS = {
        { id = 'MrNewbVehicleKeys', resource = 'MrNewbVehicleKeys', give = function(vehicle) exports.MrNewbVehicleKeys:GiveKeys(vehicle) end },
        { id = 'wasabi_carlock', resource = 'wasabi_carlock', give = function(_, plate) exports.wasabi_carlock:GiveKey(plate) end },
        { id = 'qs-vehiclekeys', resource = 'qs-vehiclekeys', give = function(vehicle, plate) exports['qs-vehiclekeys']:GiveKeys(plate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), true) end },
        { id = 'Renewed-Vehiclekeys', resource = 'Renewed-Vehiclekeys', give = function(_, plate) exports['Renewed-Vehiclekeys']:addKey(plate) end },
        { id = 'jaksam-vehicles-keys', resource = 'vehicles_keys', give = function(_, plate) TriggerServerEvent('vehicles_keys:selfGiveVehicleKeys', plate) end },
        -- qbx_vehiclekeys gives keys on the server (bridge/framework.lua is not needed for that; see server/sv_vehicles).
        { id = 'qbx_vehiclekeys', resource = 'qbx_vehiclekeys', give = function() end },
        -- The qb-vehiclekeys event, also heard by scripts made after it (wais-vehiclekey ...).
        { id = 'qb-vehiclekeys', resource = 'qb-vehiclekeys', give = function(_, plate) TriggerEvent('vehiclekeys:client:SetOwner', plate) end },
        { id = 'wais-vehiclekey', resource = 'wais-vehiclekey', give = function(_, plate) TriggerEvent('vehiclekeys:client:SetOwner', plate) end },
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
