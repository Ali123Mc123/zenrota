-- Car pictures (/carphotos, admins): the server sends the models; the hall shows them one by one (Hall.studio), the page
-- reads the game frame, frames the car with the hall around it (16:9, Config.Photos.Size) and makes a webp, which goes
-- to the server and into this resource's images/ folder. Backspace stops after the car being shot.
local run, waiting, saved = nil, {}, {}
local nextId = 0

-- The page's answer for one picture (its webp as a data URL, or an error), at most 10 s.
local function ask(action, data)
    nextId = nextId + 1
    local id, p = nextId, promise.new()
    waiting[id] = p
    data.id = id
    Page.send(action, data)
    SetTimeout(10000, function()
        if waiting[id] then
            waiting[id] = nil
            p:resolve({ error = 'timeout' })
        end
    end)
    return Citizen.Await(p)
end

Page.on('dealer:photo:done', function(d)
    local p = waiting[tonumber(d.id)]
    if p then
        waiting[tonumber(d.id)] = nil
        p:resolve(d)
    end
end)

RegisterNetEvent('daddy_dealerships:photo:saved', function(model, ok)
    local p = saved[model]
    if p then
        saved[model] = nil
        p:resolve(ok == true)
    end
end)

local function shoot(model, box)
    run.done = run.done + 1
    Page.send('dealer:photos:step', { done = run.done, name = GetLabelText(GetDisplayNameFromVehicleModel(joaat(model))), model = model })
    local res = ask('dealer:photo', { box = box, size = Config.Photos.Size })
    if type(res.data) ~= 'string' then
        run.failed[#run.failed + 1] = model
        return print(('[%s] picture %s: %s'):format(Bridge.resource, model, tostring(res.error)))
    end
    local p = promise.new()
    saved[model] = p
    TriggerLatentServerEvent('daddy_dealerships:photo:save', 2000000, model, res.data)
    SetTimeout(15000, function()
        if saved[model] == p then
            saved[model] = nil
            p:resolve(false)
        end
    end)
    if Citizen.Await(p) then run.saved = run.saved + 1 else run.failed[#run.failed + 1] = model end
end

RegisterNetEvent('daddy_dealerships:photos', function(id, models)
    if run or Hall.active or Panel.active or type(models) ~= 'table' or not Page.await(5000) then return end
    run = { done = 0, saved = 0, failed = {}, stop = false }
    Page.send('dealer:photos', { total = #models })
    CreateThread(function()
        while run do
            if IsControlJustPressed(0, 177) then run.stop = true end
            Wait(0)
        end
    end)
    -- the page binds the game frame with its first read (black until then)
    ask('dealer:photo', { prime = true })
    local ok = Hall.studio(id, models, shoot, function() return run.stop end)
    Page.send('dealer:photos:end')
    TriggerServerEvent('daddy_dealerships:photos:done')
    if not ok then
        Page.notice('msg.no_hall', 'error')
    else
        Page.notice('msg.photos_done', 'success', run.saved, Bridge.resource)
        if #run.failed > 0 then print(('[%s] pictures not taken: %s'):format(Bridge.resource, table.concat(run.failed, ', '))) end
    end
    run = nil
end)

RegisterNetEvent('daddy_dealerships:photos:stop', function()
    if run then run.stop = true end
end)
