-- The mechanic tablet.

local tablet = { open = false, netId = nil, prop = nil }

Tablet = { isOpen = function() return tablet.open end }

local function hold()
    local model = `prop_cs_tablet`
    lib.requestModel(model)
    lib.requestAnimDict('amb@code_human_in_bus_passenger_idles@female@tablet@base')
    tablet.prop = CreateObject(model, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(tablet.prop, cache.ped, GetPedBoneIndex(cache.ped, 60309), 0.03, 0.002, -0.0, 10.0, 160.0, 0.0, true, false, false, false, 2, true)
    SetModelAsNoLongerNeeded(model)
    TaskPlayAnim(cache.ped, 'amb@code_human_in_bus_passenger_idles@female@tablet@base', 'base', 3.0, 3.0, -1, 49, 0, false, false, false)
end

local function putAway()
    if tablet.prop and DoesEntityExist(tablet.prop) then DeleteEntity(tablet.prop) end
    tablet.prop = nil
    StopAnimTask(cache.ped, 'amb@code_human_in_bus_passenger_idles@female@tablet@base', 'base', 2.0)
end

local function close()
    if not tablet.open then return end
    tablet.open = false
    UiFocus(false)
    SendNUIMessage({ action = 'mech:tabletClose' })
    putAway()
    HideHud(false)
end

local function open(view, tab)
    if tablet.open or tablet.opening then return end
    local shop, why
    if view == 'staff' then
        tablet.opening = true
        shop, why = lib.callback.await('daddy_mechanic:staffInfo', false)
        tablet.opening = false
        if not shop then return Bridge.notify(nil, why or Core.t('msg.staff_only'), 'error') end
    end
    tablet.open = true
    if not cache.vehicle then hold() end
    HideHud(true)
    SendNUIMessage({ action = 'mech:tablet', view = view, tab = tab, shop = shop })
    UiFocus(true)
end

local function answer(cb, ok, result)
    cb({ ok = ok == true, error = not ok and (result or Core.t('msg.failed')) or nil, value = ok and result or nil })
end

local function closestCar()
    return lib.getClosestVehicle(GetEntityCoords(cache.ped), 6.0, true)
end

local function byHand(vehicle, source, job, label, tab, after, breakArgs)
    if Install.busy or Job.busy then return false end
    close()
    CreateThread(function()
        local result = Install.run(vehicle, source, job, label)
        if result then
            pcall(after)
        elseif result == false and Config.Install.BreakOnFail then
            lib.callback.await('daddy_mechanic:breakPart', false, table.unpack(breakArgs))
            Bridge.notify(nil, Core.t('msg.part_broke'), 'error')
        end
        if not Bridge.down() then open('staff', tab) end
    end)
    return true
end

local function fit(id, category, plate)
    local vehicle = closestCar()
    if not vehicle or Core.plate(GetVehicleNumberPlateText(vehicle)) ~= plate then return Core.t('msg.no_car') end
    local why = Job.start(vehicle, id, category)
    if why then return why end
    close()
    Job.work(vehicle, id, category, function() open('staff', 'orders') end)
end

local function onCar(source, job, label, call, args, breakArgs)
    local vehicle = tablet.netId and NetToVeh(tablet.netId) or 0
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false, Core.t('msg.no_car_near') end
    local started = byHand(vehicle, source, job, label, 'car', function()
        local ok, why = lib.callback.await(call, false, tablet.netId, table.unpack(args))
        Bridge.notify(nil, ok and Core.t('msg.fitted_part', label) or why or Core.t('msg.failed'), ok and 'success' or 'error')
    end, breakArgs)
    if not started then return false, Core.t('msg.busy') end
    return true
end

local CALLS = {
    orders = function() return true, lib.callback.await('daddy_mechanic:orders', false) or {} end,
    claim = function(d)
        local ok, why = lib.callback.await('daddy_mechanic:claim', false, d.id)
        if ok then Job.pick(d.id) end
        return ok, why
    end,
    release = function(d) return lib.callback.await('daddy_mechanic:release', false, d.id) end,
    cancel = function(d) return lib.callback.await('daddy_mechanic:cancelOrder', false, d.id, d.shop) end,
    fit = function(d)
        local why = fit(d.id, d.category, d.plate)
        return why == nil, why
    end,

    car = function()
        local vehicle = closestCar()
        if not vehicle then return false, Core.t('msg.no_car_near') end
        tablet.netId = VehToNet(vehicle)
        local service, why = lib.callback.await('daddy_mechanic:serviceInfo', false, tablet.netId)
        if not service then return false, why end
        local tuning = lib.callback.await('daddy_mechanic:tuningInfo', false, tablet.netId) or { groups = {}, picks = {} }
        local parts = {}
        for id, cfg in pairs(Config.Servicing.Parts) do parts[#parts + 1] = { id = id, item = cfg.item } end
        table.sort(parts, function(a, b) return a.id < b.id end)
        for _, g in ipairs(tuning.groups or {}) do
            for _, p in ipairs(g.parts or {}) do
                if p.item then p.have = Bridge.count(p.item) end
            end
        end
        return true, {
            name = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))), plate = GetVehicleNumberPlateText(vehicle),
            km = service.km, wear = service.service, history = service.history, parts = parts, warn = Config.Servicing.Warn,
            serviceOn = Config.Servicing.Enabled == true, groups = tuning.groups, picks = tuning.picks,
        }
    end,
    service = function(d)
        if not Config.Servicing.Parts[d.part] then return false end
        if not lib.callback.await('daddy_mechanic:hasPart', false, Config.Servicing.Parts[d.part].item) then return false, Core.t('msg.no_item') end
        return onCar('service', d.part, Core.t('parts.' .. d.part), 'daddy_mechanic:service', { d.part }, { 'service', d.part })
    end,
    tune = function(d)
        if not d.id then return lib.callback.await('daddy_mechanic:fitTune', false, tablet.netId, d.group, false) end
        local part = Config.Tuning[d.group] and Config.Tuning[d.group][d.id]
        if not part then return false end
        if part.item and not lib.callback.await('daddy_mechanic:hasPart', false, part.item) then return false, Core.t('msg.no_item') end
        return onCar('tune', d.group, Core.t('tune.' .. d.id), 'daddy_mechanic:fitTune', { d.group, d.id }, { 'tune', d.group, d.id })
    end,

    invoices = function() return true, lib.callback.await('daddy_mechanic:shopInvoices', false) or {} end,
    void = function(d) return lib.callback.await('daddy_mechanic:voidInvoice', false, d.id) end,
    nearby = function() return true, lib.callback.await('daddy_mechanic:nearby', false) or {} end,
    send = function(d) return lib.callback.await('daddy_mechanic:sendInvoice', false, d.target, d.lines) end,

    mine = function()
        return true, {
            invoices = lib.callback.await('daddy_mechanic:myInvoices', false) or {},
            orders = lib.callback.await('daddy_mechanic:myOrders', false) or {},
        }
    end,
    pay = function(d) return lib.callback.await('daddy_mechanic:payInvoice', false, d.id, d.account) end,

    manage = function()
        local info = lib.callback.await('daddy_mechanic:manage', false)
        return info ~= nil, info
    end,
    till = function(d) return lib.callback.await('daddy_mechanic:till', false, d.way, d.amount) end,
    hire = function(d) return lib.callback.await('daddy_mechanic:hire', false, d.target) end,
    rank = function(d) return lib.callback.await('daddy_mechanic:rank', false, d.id, d.grade) end,

    history = function(d)
        local info = lib.callback.await('daddy_mechanic:history', false, d.filter)
        return info ~= nil, info
    end,
    stats = function(d)
        local info = lib.callback.await('daddy_mechanic:stats', false, d.period)
        return info ~= nil, info
    end,
    settings = function()
        local info = lib.callback.await('daddy_mechanic:settings', false)
        return info ~= nil, info
    end,
    saveSettings = function(d) return lib.callback.await('daddy_mechanic:saveSettings', false, d.perms, d.commission, d.people) end,
}

RegisterNUICallback('tablet', function(data, cb)
    local call = tablet.open and type(data) == 'table' and CALLS[data.call]
    if not call then return answer(cb, false) end
    answer(cb, call(data))
end)

RegisterNUICallback('tabletClose', function(_, cb)
    cb({})
    close()
end)

RegisterCommand(Config.StaffCommand, function() open('staff') end, false)
RegisterCommand(Config.InvoiceCommand, function() open('mine', 'mine') end, false)
RegisterNetEvent('daddy_mechanic:tablet', function() open('staff') end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    putAway()
    if tablet.open then
        UiFocus(false)
        HideHud(false)
    end
end)

exports('openDesk', function(view) open(view == 'mine' and 'mine' or 'staff', view == 'mine' and 'mine' or 'orders') end)
exports('closeDesk', close)

lib.callback.register('daddy_mechanic:jobOffer', function(shop, from)
    return lib.alertDialog({ header = Core.t('ui.job_offer'), content = Core.t('ui.job_offer_text', from, shop), centered = true, cancel = true }) == 'confirm'
end)
