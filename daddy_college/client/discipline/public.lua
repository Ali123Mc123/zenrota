-- Public detention on the client: the start point and the bins in the world, taking the first job there, the way
-- to the start, and the countdown when the student leaves the areas. The jobs themselves are in jobs.lua.
if not Core.ModuleEnabled('discipline') then return end

local cfg = Config.Discipline
local t = DL.locale.t
local serving -- the server's state while serving in public, nil otherwise

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:discipline:' .. name, false, data))
end

local function firstModel(names)
    for _, name in ipairs(names or {}) do
        if IsModelInCdimage(joaat(name)) then return name end
    end
end

-- Jobs --------------------------------------------------------------------------------------------------

-- The job's pieces come through the chores package (client/discipline/jobs.lua).
local function take()
    local result = call('jobTake')
    if not result.ok then return Core.HandleResult(result, 'discipline') end
    Core.NotifyL('discipline.job_taken_' .. result.job.kind, 'inform', result.job.count)
end

local function drop()
    local result = call('jobDrop')
    if not result.ok then return Core.HandleResult(result, 'discipline') end
    Core.NotifyL('discipline.job_dropped', 'inform')
end

-- The start point and the bins: props everyone sees, the options only for a student serving in public.
-- The editor's spots of a kind, or the ones in Config.Discipline.Places while none is drawn.
local function spots(kind)
    local list, places = Core.World.entities({ kind = kind }), cfg.Places or {}
    if #list > 0 then return list end
    if kind == 'discipline_start' and places.Start then return { { uid = 'cfg_start', label = t('discipline.start_label'), coords = places.Start, revision = 1 } } end
    if kind ~= 'discipline_bin' then return list end
    for i, at in ipairs(places.Bins or {}) do
        list[#list + 1] = { uid = 'cfg_bin_' .. i, coords = at, revision = 1, model = places.BinProps == false and false or nil }
    end
    return list
end

local function sync()
    local defs = {}
    for _, spot in ipairs(spots('discipline_start')) do
        local model = (spot.model or '') ~= '' and spot.model or firstModel(cfg.Models.start)
        defs[#defs + 1] = { uid = 'discipline:start:' .. spot.uid, label = spot.label, coords = spot.coords, revision = spot.revision,
            presentation = model and 'prop' or 'point', model = model, distance = cfg.Public.StartReach, options = {
                { name = 'discipline_job_take', label = t('discipline.job_take'), icon = 'fa-solid fa-broom', distance = cfg.Public.StartReach,
                    canInteract = function() return serving ~= nil and not serving.job end, onSelect = function() CreateThread(take) end },
                { name = 'discipline_no_detention', label = t('discipline.no_detention_label'), icon = 'fa-solid fa-circle-info', distance = cfg.Public.StartReach,
                    canInteract = function() return serving == nil end, onSelect = function() Core.NotifyL('discipline.no_detention', 'inform') end },
                { name = 'discipline_job_drop', label = t('discipline.job_drop'), icon = 'fa-solid fa-xmark', distance = cfg.Public.StartReach,
                    canInteract = function() return serving ~= nil and serving.job ~= nil end, onSelect = function() CreateThread(drop) end },
            } }
    end
    -- Bins: only a prop when one is placed; the bag goes in with [E] (client/discipline/jobs.lua).
    for _, spot in ipairs(spots('discipline_bin')) do
        local model = spot.model ~= false and ((spot.model or '') ~= '' and spot.model or firstModel(cfg.Models.bin)) or nil
        if model then defs[#defs + 1] = { uid = 'discipline:bin:' .. spot.uid, coords = spot.coords, revision = spot.revision, presentation = 'prop', model = model } end
    end
    Core.World.anchors.sync('discipline_public', defs)
end

Core.World.subscribe(sync)

-- Serving ----------------------------------------------------------------------------------------------

RegisterNetEvent('daddy_college:discipline:begin', function(data)
    if data.mode ~= 'public' then return end
    serving = data
    if not data.start then return end
    if data.startMode == 'teleport' then return TriggerEvent('daddy_college:discipline:teleport', data.start) end
    Core.Waypoint.mark(t('discipline.start_label'), data.start, 'discipline:start', true, 'task')
end)

RegisterNetEvent('daddy_college:discipline:sync', function(data)
    if data.mode == 'public' then serving = data end
end)

RegisterNetEvent('daddy_college:discipline:release', function()
    serving = nil
    Core.Nui.Send('outOfBounds:hide', {})
end)

-- Outside the areas: the countdown the server keeps, on the same barrier-tape warning as leaving the campus.
RegisterNetEvent('daddy_college:discipline:leave', function(data)
    if not data.seconds then return Core.Nui.Send('outOfBounds:hide', {}) end
    Core.Nui.Send('outOfBounds:show', { total = cfg.Public.LeaveSeconds, remaining = data.seconds,
        tag = t('discipline.leave_tag'), banner = t('discipline.leave_banner'), action = t('discipline.leave_action') })
end)

-- A teacher asked the tablet where a student serving detention is.
RegisterNetEvent('daddy_college:discipline:mark', function(where)
    Core.Waypoint.mark(where.name, where, 'discipline:mark', true, 'incident')
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then Core.World.anchors.clear('discipline_public') end
end)
