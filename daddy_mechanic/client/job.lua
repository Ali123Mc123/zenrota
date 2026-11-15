-- The order card and the fit key.

Job = { busy = false }

local jobs, current, sent, loaded = {}, nil, nil, false

local function active()
    for _, j in ipairs(jobs) do
        if j.id == current then return j end
    end
    return jobs[1]
end

function Job.pick(id) current = id end

local function nearShop(job)
    local shop = Config.Shops[job.shop]
    if not shop then return false end
    local me = GetEntityCoords(cache.ped)
    for _, p in ipairs(shop.points) do
        if #(me - p) <= Config.JobCard.Distance then return true end
    end
    return false
end

local function carOf(job)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 6.0, false)
    return vehicle and Core.plate(GetVehicleNumberPlateText(vehicle)) == job.plate and vehicle or nil
end

local function nextOf(job)
    local short
    for _, e in ipairs(job.left) do
        if not e.item or Bridge.count(e.item) >= e.need then return e end
        short = short or e
    end
    return nil, short
end

local function keyName()
    local name = GetControlInstructionalButton(0, joaat('mechfit') | 0x80000000, true)
    return type(name) == 'string' and name:match('^t_(.+)') or Config.FitKey or ''
end

local function card(job)
    local rows, byItem = {}, {}
    for _, e in ipairs(job.left) do
        if e.item then
            local r = byItem[e.item]
            if not r then
                r = { label = e.itemLabel, need = 0, have = Bridge.count(e.item) }
                byItem[e.item] = r
                rows[#rows + 1] = r
            end
            r.need = r.need + e.need
        end
    end
    local hint, nextLabel = 'go', nil
    if carOf(job) then
        local nxt = nextOf(job)
        hint, nextLabel = nxt and 'next' or 'missing', nxt and Core.t('categories.' .. nxt.category)
    end
    return { id = job.id, plate = job.plate, customer = job.customer, done = job.count - #job.left, count = job.count,
        rows = rows, hint = hint, next = nextLabel, key = Config.FitKey and keyName() or nil }
end

local function show(data)
    local text = data and json.encode(data) or ''
    if text == sent then return end
    sent = text
    SendNUIMessage({ action = 'mech:job', job = data })
end

RegisterNetEvent('daddy_mechanic:job', function(list)
    jobs = type(list) == 'table' and list or {}
end)

CreateThread(function()
    while not Bridge.job() do Wait(2000) end
    while true do
        if #jobs > 0 or not loaded then
            jobs, loaded = lib.callback.await('daddy_mechanic:myJobs', false) or {}, true
        end
        Wait(60000)
    end
end)

CreateThread(function()
    while true do
        local job = #jobs > 0 and active()
        local visible = job and not Menu.isOpen() and not Tablet.isOpen() and nearShop(job)
        show(visible and card(job) or nil)
        Wait(1000)
    end
end)

function Job.start(vehicle, id, category)
    if Job.busy or Install.busy then return Core.t('msg.busy') end
    Job.busy = true
    local ok, why = lib.callback.await('daddy_mechanic:fitStart', false, id, category, VehToNet(vehicle))
    if not ok then
        Job.busy = false
        return why or Core.t('msg.failed')
    end
    current = id
end

local function entryOf(id, category)
    for _, job in ipairs(jobs) do
        if job.id == id then
            for _, e in ipairs(job.left) do
                if e.category == category then return e end
            end
        end
    end
end

local function work(vehicle, id, category)
    local e = entryOf(id, category)
    local result = Install.run(vehicle, 'order', category, Core.t('categories.' .. category), { tint = e and e.tint })
    if result then
        local ok, finished = lib.callback.await('daddy_mechanic:fitFinish', false, VehToNet(vehicle))
        if not ok then Bridge.notify(nil, finished or Core.t('msg.failed'), 'error')
        else Bridge.notify(nil, Core.t(finished and 'msg.order_done' or 'msg.fitted', id), 'success') end
    elseif result == false and Config.Install.BreakOnFail and lib.callback.await('daddy_mechanic:breakPart', false, 'order', category) then
        Bridge.notify(nil, Core.t('msg.part_broke'), 'error')
    end
end

function Job.work(vehicle, id, category, after)
    Job.busy = true
    CreateThread(function()
        local ok, err = pcall(work, vehicle, id, category)
        if not ok then print(('^1[daddy_mechanic] order fit: %s^0'):format(err)) end
        Job.busy = false
        if after and not Bridge.down() then after() end
    end)
end

local function fitNext()
    local job = #jobs > 0 and active()
    if not job or #job.left == 0 or Job.busy or Install.busy or cache.vehicle or Bridge.down() then return end
    if Menu.isOpen() or Tablet.isOpen() or not nearShop(job) then return end
    local vehicle = carOf(job)
    if not vehicle then return Bridge.notify(nil, Core.t('msg.go_to_car'), 'error') end
    local nxt, short = nextOf(job)
    if not nxt then return Bridge.notify(nil, Core.t('msg.no_parts', short.itemLabel, short.need), 'error') end
    local why = Job.start(vehicle, job.id, nxt.category)
    if why then return Bridge.notify(nil, why, 'error') end
    Job.work(vehicle, job.id, nxt.category)
end

if Config.FitKey then
    RegisterCommand('mechfit', fitNext, false)
    RegisterKeyMapping('mechfit', Core.t('ui.fit_key'), 'keyboard', Config.FitKey)
end
