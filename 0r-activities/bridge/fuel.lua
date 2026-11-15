FuelBridge = {}

local providers = { 'savana-fuel', 'ox_fuel', 'lc_fuel', 'cdn-fuel', 'ps-fuel', 'lj-fuel', 'qb-fuel', 'LegacyFuel' }
local reported = {}

local function report(provider, problem)
    if reported[provider] then return end
    reported[provider] = true
    print(('[0r-activities] Fuel integration (%s): %s; using native fuel.'):format(provider, tostring(problem)))
end

local function callExport(resource, name, vehicle, level)
    local resourceExports = exports[resource]
    return resourceExports[name](resourceExports, vehicle, level)
end

local function selectedProvider(settings)
    local selected = settings.system or 'auto'
    if selected == 'native' or selected == 'custom' then return selected end
    for _, resource in ipairs(providers) do
        if (selected == 'auto' or selected == resource) and GetResourceState(resource) == 'started' then
            return resource
        end
    end
    if selected ~= 'auto' then report(tostring(selected), 'resource unavailable or unsupported') end
    return 'native'
end

local function setNativeFuel(vehicle, level)
    local state = Entity(vehicle).state
    local replicate = NetworkGetEntityIsNetworked(vehicle) and NetworkHasControlOfEntity(vehicle)
    SetVehicleFuelLevel(vehicle, level)
    state:set('fuel', level, replicate)
    if DecorIsRegisteredAsType('_FUEL_LEVEL', 1) then DecorSetFloat(vehicle, '_FUEL_LEVEL', level) end
end

function FuelBridge.Set(vehicle, level)
    if type(vehicle) ~= 'number' or vehicle == 0 or vehicle % 1 ~= 0
        or not DoesEntityExist(vehicle) or GetEntityType(vehicle) ~= 2
        or type(level) ~= 'number' or level ~= level or math.abs(level) == math.huge then return false end
    level = math.max(0.0, math.min(100.0, level))
    -- DaddyRP: yakit verilen arac aktivite aracidir; surucu koltuguna oturan herkes anahtar alsin.
    if VehicleKeyBridge and VehicleKeyBridge.Mark then VehicleKeyBridge.Mark(vehicle) end
    setNativeFuel(vehicle, level)

    local settings = ActivitiesConfig and ActivitiesConfig.fuel
    settings = type(settings) == 'table' and settings or {}
    local provider = selectedProvider(settings)
    if provider == 'native' or provider == 'ox_fuel' then return true, provider end

    local ok, result
    if provider == 'custom' then
        if type(settings.custom) ~= 'function' then
            report(provider, 'put your client fuel code inside the fuel.custom function')
            return true, 'native'
        end
        ok, result = pcall(settings.custom, vehicle, level)
    else
        ok, result = pcall(callExport, provider, 'SetFuel', vehicle, level)
    end
    if not ok or result == false then
        if DoesEntityExist(vehicle) then setNativeFuel(vehicle, level) end
        report(provider, ok and 'setter returned false' or result)
        return true, 'native'
    end
    return true, provider
end

function FuelBridge.Fill(vehicle)
    return FuelBridge.Set(vehicle, 100.0)
end

Activities.fillBoatFuel = FuelBridge.Fill
