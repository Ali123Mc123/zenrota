-- Discipline on the client: the panel, and serving detention (status overlay, task spot, restrictions).
-- The timer here is only for show; the server sends the real one.
if not Core.ModuleEnabled('discipline') then return end

local cfg = Config.Discipline
local t = DL.locale.t
local serving, busy, token = nil, false, 0

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:discipline:' .. name, false, data))
end

-- Some errors carry the limits they broke.
local function fail(result)
    if result.error == 'bad_duration' then return Core.NotifyL('discipline.bad_duration', 'error', result.min, result.max) end
    if result.error == 'bad_reason' then return Core.NotifyL('discipline.bad_reason', 'error', result.min) end
    Core.HandleResult(result, 'discipline')
end

-- Panel ----------------------------------------------------------------------------------------------

-- Issuing, approving and the history live in the staff tablet's Discipline app.
local function tablet() if Core.OpenTablet then Core.OpenTablet('discipline') end end
Core.Command(cfg.Commands.panel, tablet)
Core.Command(cfg.Commands.history, tablet)

-- At the Student Affairs desk: the discipline ranking in a panel of the talk.
Core.Affairs.RegisterAction('discipline:board', { order = 45, icon = 'fa-solid fa-gavel', label = 'discipline.ui.points_blip', panel = true,
    visible = function(context) return context.isStudent == true end })

-- Serving --------------------------------------------------------------------------------------------

-- Out of any vehicle or attachment, then to the spot behind a short fade.
local function teleport(pos)
    local ped = cache.ped
    DoScreenFadeOut(400)
    while not IsScreenFadedOut() do Wait(0) end
    DetachEntity(ped, true, true)
    ClearPedTasksImmediately(ped)
    RequestCollisionAtCoord(pos.x, pos.y, pos.z)
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(ped, pos.x, pos.y, pos.z, false, false, false, false)
    SetEntityHeading(ped, pos.w or 0.0)
    FreezeEntityPosition(ped, false)
    Wait(300)
    DoScreenFadeIn(500)
end

local function overlay()
    if not serving then return end
    Core.Nui.Send('discipline:status', {
        remaining = serving.remaining, total = serving.total, reason = serving.reason, tasksDone = serving.tasksDone,
        hasTask = serving.task ~= nil or serving.job ~= nil, nextIn = serving.nextIn or 0, mode = serving.mode, jobsTotal = serving.jobsTotal,
        reduction = serving.mode == 'public' and 0 or serving.reduction,
    })
end

local function work(task)
    if busy or not serving then return end
    busy = true
    local kind = cfg.Tasks.Kinds[task.kind] or cfg.Tasks.Kinds.sweep
    SetEntityHeading(cache.ped, task.coords.w or GetEntityHeading(cache.ped))
    local done = Core.Progress({
        duration = cfg.Tasks.Duration, label = t('discipline.progress_' .. task.kind), kind = task.kind, canCancel = true,
        disable = { move = true, car = true, combat = true }, anim = kind.anim, prop = kind.prop,
    })
    ClearPedTasks(cache.ped)
    if not done then
        busy = false
        return
    end
    local result = call('completeTask', { taskId = task.id })
    busy = false
    if not result.ok then return fail(result) end
    if (result.reduced or 0) > 0 then Core.NotifyL('discipline.task_done', 'success', result.reduced) else Core.NotifyL('discipline.task_done_notime', 'success') end
    if not result.finished then Core.NotifyL('discipline.task_next', 'inform', result.nextIn) end
end

-- The task spot: a blip, a marker and the work option.
local function showTask(task)
    Core.World.anchors.remove('discipline:task')
    if not task then return end
    local kind = cfg.Tasks.Kinds[task.kind] or cfg.Tasks.Kinds.sweep
    local blip = cfg.Tasks.Blip
    Core.World.anchors.set('discipline:task', {
        presentation = 'point', coords = task.coords, label = t('discipline.task_label'), distance = cfg.Tasks.Distance, marker = cfg.Tasks.Marker,
        blip = { sprite = blip.sprite, color = blip.color, scale = blip.scale, label = t('discipline.task_label') },
        options = { { name = 'discipline_task', label = t('discipline.target_' .. task.kind), icon = kind.icon, distance = cfg.Tasks.Distance,
            onSelect = function() CreateThread(function() work(task) end) end } },
    })
end

-- While serving: no vehicles, no weapons, and the overlay counts down between server updates.
local function guard(mine)
    CreateThread(function()
        while token == mine do
            local ped = cache.ped
            if cfg.Restrictions.NoVehicle and IsPedInAnyVehicle(ped, false) then
                TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, false), 16)
                Core.NotifyL('discipline.no_vehicle', 'error')
            end
            if cfg.Restrictions.NoWeapons then
                local _, weapon = GetCurrentPedWeapon(ped, true)
                if weapon ~= `WEAPON_UNARMED` then
                    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                    Core.NotifyL('discipline.no_weapons', 'error')
                end
            end
            Wait(500)
        end
    end)
    if cfg.Restrictions.NoWeapons then
        CreateThread(function()
            while token == mine do
                DisablePlayerFiring(cache.playerId, true)
                Wait(0)
            end
        end)
    end
    CreateThread(function()
        while true do
            Wait(1000)
            if token ~= mine or not serving then return end
            serving.remaining = math.max(serving.remaining - 1, 0)
            serving.nextIn = math.max((serving.nextIn or 0) - 1, 0)
            Core.Nui.Send('discipline:tick', { remaining = serving.remaining, nextIn = serving.nextIn })
        end
    end)
end

RegisterNetEvent('daddy_college:discipline:begin', function(data)
    token = token + 1
    serving = data
    showTask(data.task)
    overlay()
    guard(token)
    if data.room then CreateThread(function() teleport(data.room) end) end
end)

RegisterNetEvent('daddy_college:discipline:sync', function(data)
    if not serving then return end
    local had = serving.task and serving.task.id
    serving = data
    if (data.task and data.task.id) ~= had then
        showTask(data.task)
        if data.task and not had then Core.NotifyL('discipline.task_ready', 'inform') end
    end
    overlay()
end)

RegisterNetEvent('daddy_college:discipline:teleport', function(pos)
    CreateThread(function() teleport(pos) end)
end)

RegisterNetEvent('daddy_college:discipline:release', function(pos)
    token = token + 1
    serving, busy = nil, false
    showTask(nil)
    Core.Nui.Send('discipline:statusHide', {})
    if pos then CreateThread(function() teleport(pos) end) end
end)

Core.OnLogin(function() TriggerServerEvent('daddy_college:discipline:ready') end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then Core.World.anchors.remove('discipline:task') end
end)
