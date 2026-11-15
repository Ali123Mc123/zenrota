-- Client side of the old dispatches' names (the manifest provides them): tgiann-policealert's Alert, ps-dispatch's
-- CustomAlert and named alerts, glxs-dispatch's named alerts and calls; and our own client exports.

-- exports['<resource>']:name(...) reaches fn for each resource we stand in for.
local function exportAs(resources, name, fn)
    for _, resource in ipairs(resources) do
        AddEventHandler(('__cfx_export_%s_%s'):format(resource, name), function(setCB) setCB(fn) end)
    end
end

-- tgiann-policealert: Alert({ jobs, label, code, coords, icon, bgAnimate, blip, gender, vehicle, custom }).
exportAs({ 'tgiann-policealert' }, 'Alert', function(data)
    if type(data) ~= 'table' then return false end
    local context = {}
    if data.gender then context[#context + 1] = 'gender' end
    if type(data.vehicle) == 'table' and (data.vehicle.label or data.vehicle.plate or data.vehicle.color) then context[#context + 1] = 'vehicle' end
    local fields = {}
    for _, row in ipairs(type(data.custom) == 'table' and data.custom or {}) do
        local right = row.labelRight ~= nil and tostring(row.labelRight) or nil
        if right then fields[#fields + 1] = { icon = Core.iconOf(row.icon) or 'info', text = row.labelLeft and (row.labelLeft .. ': ' .. right) or right } end
    end
    Context.raise(Core.typeOfCode(data.code) or 'custom', {
        title = data.label, code = data.code, coords = data.coords, to = type(data.jobs) == 'table' and data.jobs or nil,
        icon = Core.iconOf(data.icon), priority = data.bgAnimate and 1 or nil, context = context, fields = fields,
        blip = tonumber(data.blip) and { sprite = tonumber(data.blip), colour = 1 } or nil,
    })
    return true
end)

-- ps-dispatch: CustomAlert({ coords, message, code, icon, priority, jobs, alert / sprite, color, radius ... }).
exportAs({ 'ps-dispatch' }, 'CustomAlert', function(data)
    if type(data) ~= 'table' then return false end
    local alert = type(data.alert) == 'table' and data.alert or data
    Context.raise(Core.typeOfCode(data.code) or 'custom', {
        title = data.message or data.codeName, code = data.code or data.dispatchCode, coords = data.coords,
        priority = tonumber(data.priority), icon = Core.iconOf(data.icon), to = type(data.jobs) == 'table' and data.jobs or nil,
        message = data.description, fuzz = tonumber(alert.radius), context = {},
        blip = tonumber(alert.sprite) and { sprite = tonumber(alert.sprite), colour = tonumber(alert.color) or 1 } or nil,
    })
    return true
end)

-- Named alerts of ps-dispatch and glxs-dispatch, each to one of our types. An argument may add a camera id or text.
local NAMED = {
    Shooting = 'shooting', VehicleShooting = 'vehicle_shooting', SpeedingVehicle = 'reckless_driving',
    RecklessDriving = 'reckless_driving', StreetRacing = 'street_racing', VehicleTheft = 'vehicle_theft',
    AttemptedCarTheft = 'vehicle_theft', BoatTheft = 'vehicle_theft', CarJacking = 'carjacking', Carjacking = 'carjacking',
    CarBoosting = 'car_boosting', Fight = 'fight', Explosion = 'explosion', Fire = 'fire',
    SuspiciousActivity = 'suspicious_activity', DrugSale = 'drug_sale', PrisonBreak = 'prison_break',
    OfficerDown = 'officer_down', OfficerBackup = 'officer_backup', OfficerInDistress = 'officer_distress',
    OfficerDistress = 'officer_distress', EmsDown = 'ems_down', InjuriedPerson = 'player_down', PlayerDown = 'player_down',
    DeceasedPerson = 'civilian_dead', CivilianDead = 'civilian_dead', StoreRobbery = 'store_robbery',
    HouseRobbery = 'house_robbery', BankRobbery = 'bank_robbery', FleecaBankRobbery = 'bank_robbery',
    PacificBankRobbery = 'pacific_bank_robbery', PaletoBankRobbery = 'paleto_bank_robbery',
    VangelicoRobbery = 'vangelico_robbery', ArtGalleryRobbery = 'art_gallery_robbery', HumaneRobery = 'humane_labs_robbery',
    HumaneLabsRobbery = 'humane_labs_robbery', UnionRobbery = 'union_robbery', UndergroundRobbery = 'underground_robbery',
    BobcatSecurityHeist = 'bobcat_robbery', BobcatRobbery = 'bobcat_robbery', TrainRobbery = 'train_robbery',
    VanRobbery = 'van_robbery', YachtHeist = 'yacht_robbery', YachtRobbery = 'yacht_robbery',
    DrugBoatRobbery = 'drug_boat_robbery', SignRobbery = 'sign_robbery',
}

for name, typeName in pairs(NAMED) do
    local fn = function(arg)
        local fields = {}
        if type(arg) == 'number' then fields[1] = { icon = 'info', text = 'CAM ' .. arg } end
        if type(arg) == 'table' and (arg.information or arg.message) then fields[1] = { icon = 'info', text = tostring(arg.information or arg.message) } end
        Context.raise(typeName, { fields = fields })
        return true
    end
    exportAs({ 'ps-dispatch', 'glxs-dispatch' }, name, fn)
    exports(name, fn)
end

-- glxs-dispatch's citizen calls: Call911(message), Call911Anonymous(message), Call311(message).
local function call(number, anonymous)
    return function(message)
        local p = GetEntityCoords(PlayerPedId())
        local street, area = Context.street(p)
        TriggerServerEvent('daddy_dispatch:citizen', number, tostring(message or Core.t('alerts.call_911')), anonymous, street or area)
        return true
    end
end
exportAs({ 'glxs-dispatch' }, 'Call911', call('911', false))
exportAs({ 'glxs-dispatch' }, 'Call911A', call('911', true))
exportAs({ 'glxs-dispatch' }, 'Call911Anonymous', call('911', true))
exportAs({ 'glxs-dispatch' }, 'Call311', call('311', false))
exportAs({ 'glxs-dispatch' }, 'IsInCombat', function() return GetGameTimer() - Sound.shotAt < 10000 end)
exportAs({ 'glxs-dispatch' }, 'IsCombatMuteActive', function() return Prefs.duck and GetGameTimer() - Sound.shotAt < 10000 end)

-- Our own client exports.
-- Raise(type, extra): an alert of a Config.Alerts type from this player (extra: title, code, coords, fields, message ...).
exports('Raise', function(typeName, extra)
    if type(typeName) ~= 'string' then return false end
    Context.raise(typeName, type(extra) == 'table' and extra or {})
    return true
end)

-- IsPaused(): this player's dispatch is paused. IsUnit(): on duty for the dispatch. GetStatus(): their status.
exports('IsPaused', function() return Pause.on() end)
exports('IsUnit', function() return Me.unit == true end)
exports('GetStatus', function() return Me.status end)
