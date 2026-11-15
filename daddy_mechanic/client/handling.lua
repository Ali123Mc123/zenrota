-- Car data on this client: handling, engine sound and wear.

local function baseOf(vehicle)
    local state = Entity(vehicle).state
    if state.dmechBase then return state.dmechBase end
    local out = {}
    for _, field in ipairs(Tuning.fields) do out[field] = GetVehicleHandlingFloat(vehicle, 'CHandlingData', field) end
    out.flags = GetVehicleHandlingInt(vehicle, 'CCarHandlingData', 'strAdvancedFlags')
    state:set('dmechBase', out, true)
    return out
end

local FULL_AUTO, MANUAL, DIRECT_SHIFT, ELECTRIC = 0x200, 0x400, 0x800, 0x1000
local function gearbox(vehicle, base, manual)
    if GetGameBuildNumber() < 3095 or not base.flags or base.flags & ELECTRIC ~= 0 then return end
    local flags = manual and (base.flags & ~FULL_AUTO & ~DIRECT_SHIFT | MANUAL) or base.flags
    if GetVehicleHandlingInt(vehicle, 'CCarHandlingData', 'strAdvancedFlags') ~= flags then
        SetVehicleHandlingInt(vehicle, 'CCarHandlingData', 'strAdvancedFlags', flags)
    end
end

local function powerWheels(vehicle, bias)
    if GetVehicleNumberOfWheels(vehicle) < 4 then return end
    SetVehicleWheelIsPowered(vehicle, 0, bias > 0.0)
    SetVehicleWheelIsPowered(vehicle, 1, bias > 0.0)
    for wheel = 2, 5 do SetVehicleWheelIsPowered(vehicle, wheel, bias < 1.0) end
end

local function wearOf(data)
    local out = {}
    for part, health in pairs(data.service or {}) do out[part] = (tonumber(health) or 100) / 100 end
    return out
end

function ApplyCarData(vehicle, data)
    if not DoesEntityExist(vehicle) then return end
    data = data or {}
    local sound = Tuning.sound(data.tuning, Config.Tuning)
    if sound then ForceUseAudioGameObject(vehicle, sound) end
    if NetworkGetEntityOwner(vehicle) ~= PlayerId() then return end
    local base = baseOf(vehicle)
    local values = Tuning.compute(base, data.tuning, Config.Tuning, wearOf(data))
    for field, value in pairs(values) do SetVehicleHandlingFloat(vehicle, 'CHandlingData', field, value + 0.0) end
    local box = data.tuning and data.tuning.gearbox and Config.Tuning.gearbox and Config.Tuning.gearbox[data.tuning.gearbox]
    gearbox(vehicle, base, box and box.manual)
    powerWheels(vehicle, values.fDriveBiasFront)
    SetVehicleModKit(vehicle, 0)
    for _, slot in ipairs({ 11, 12, 13, 15 }) do SetVehicleMod(vehicle, slot, GetVehicleMod(vehicle, slot), false) end
    ToggleVehicleMod(vehicle, 18, IsToggleModOn(vehicle, 18))
end

local function carOf(bagName)
    local vehicle = GetEntityFromStateBagName(bagName)
    for _ = 1, 20 do
        if vehicle ~= 0 then return vehicle end
        Wait(100)
        vehicle = GetEntityFromStateBagName(bagName)
    end
    return 0
end

AddStateBagChangeHandler('dmech', nil, function(bagName, _, data)
    local vehicle = carOf(bagName)
    if vehicle ~= 0 then ApplyCarData(vehicle, data) end
end)

lib.onCache('seat', function(seat)
    if seat ~= -1 or not cache.vehicle then return end
    local vehicle = cache.vehicle
    SetTimeout(500, function()
        if not DoesEntityExist(vehicle) then return end
        local data = Entity(vehicle).state.dmech
        local box = data and data.tuning and data.tuning.gearbox
        if box and Config.Tuning.gearbox and Config.Tuning.gearbox[box] and Config.Tuning.gearbox[box].manual then
            Bridge.notify(nil, Core.t('msg.manual_gearbox'), 'info')
        end
        if data then return ApplyCarData(vehicle, data) end
        lib.callback('daddy_mechanic:sync', false, function() end, VehToNet(vehicle))
    end)
end)

