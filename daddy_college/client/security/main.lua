-- Security on the client: countdowns, being brought back, the alarm, gate guards, the exit permit in hand and
-- the player options of security and the principal. Every decision is made on the server.
if not Core.ModuleEnabled('security') then return end

local cfg = Config.Security
local t = DL.locale.t

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:security:' .. name, false, data))
end

-- Countdowns -----------------------------------------------------------------------------------------

-- Outside without a permit: the seconds before being brought back. nil hides it.
RegisterNetEvent('daddy_college:security:outOfBounds', function(data)
    if not data then return Core.Nui.Send('outOfBounds:hide', {}) end
    data.tag, data.banner, data.action = false, false, false
    Core.Nui.Send('outOfBounds:tick', data)
end)

-- A permit ran out: the grace before the detention, on the same overlay with its own words.
RegisterNetEvent('daddy_college:security:grace', function(data)
    if not data then return Core.Nui.Send('outOfBounds:hide', {}) end
    data.tag, data.banner = t('security.permit_expired'), t('security.oob_banner')
    data.action = t('security.permit_expired_grace_action', cfg.Permit.GraceMinutes, math.floor(cfg.Permit.OverstaySeconds / 60))
    Core.Nui.Send('outOfBounds:tick', data)
end)

RegisterNetEvent('daddy_college:security:sound', function(kind)
    if kind == 'urgent' then return PlaySoundFrontend(-1, 'CHECKPOINT_MISSED', 'HUD_MINI_GAME_SOUNDSET', true) end
    PlaySoundFrontend(-1, 'Event_Start_Text', 'GTAO_FM_Events_Soundset', true)
end)

RegisterNetEvent('daddy_college:security:bringBack', function(data)
    CreateThread(function()
        local ped = cache.ped
        DoScreenFadeOut(data.fadeMs)
        while not IsScreenFadedOut() do Wait(0) end
        Core.Nui.Send('outOfBounds:hide', {})
        DetachEntity(ped, true, true)
        ClearPedTasksImmediately(ped)
        local c = data.coords
        RequestCollisionAtCoord(c.x, c.y, c.z)
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoords(ped, c.x, c.y, c.z, false, false, false, false)
        SetEntityHeading(ped, c.w or 0.0)
        Wait(400)
        DoScreenFadeIn(data.fadeMs)
        Core.NotifyL('security.oob_returned', 'warning')
    end)
end)

-- The alarm rings only for those on the campus.
local ringing = false

RegisterNetEvent('daddy_college:alarm:toggle', function(active)
    ringing = active == true
    if not ringing then return SendNUIMessage({ action = 'playAlarm', data = { active = false } }) end
    CreateThread(function()
        local playing = false
        while ringing do
            local inside = Core.OnCampus()
            if inside ~= playing then
                playing = inside
                SendNUIMessage({ action = 'playAlarm', data = { active = inside } })
            end
            Wait(600)
        end
        SendNUIMessage({ action = 'playAlarm', data = { active = false } })
    end)
end)

-- Exit permits ---------------------------------------------------------------------------------------

Core.Command(cfg.Commands.exit, function()
    local result = call('usePermit')
    if not result.ok then Core.HandleResult(result, 'security') end
end)

RegisterNetEvent('daddy_college:permit:show', function(payload) Core.Nui.Send('permit:show', payload) end)
RegisterNetEvent('daddy_college:permit:hide', function(id) Core.Nui.Send('permit:hide', { showId = id }) end)


local function checkPermit(target)
    local result = call('checkPermit', { targetId = target })
    if not result.ok then return Core.HandleResult(result, 'security') end
    if result.expires then return Core.NotifyL('security.permit_check_ok', 'success', result.name, result.expires) end
    Core.NotifyL('security.permit_check_no', 'error', result.name)
end

-- The principal writes a pass out on the pad; the student it is for stays fixed while the pad is open.
local passFor

local function givePermit(target)
    local form = call('permitForm', { targetId = target })
    if not form.ok then return Core.HandleResult(form, 'security') end
    passFor = target
    Core.Nui.Open('security.permit', { name = form.name, number = form.number, className = form.className, issuer = form.issuer,
        minutes = cfg.Permit.Request.DefaultMinutes, max = cfg.Permit.MaxMinutes })
end

Core.Nui.SafeCallback('security:issuePermit', function(data)
    if not passFor then return { ok = false, error = 'player_offline' } end
    local result = call('givePermit', { targetId = passFor, minutes = tonumber(data.minutes), reason = tostring(data.reason or '') })
    if not result.ok then Core.HandleResult(result, 'security') end
    return result
end)
Core.Nui.OnClose('security.permit', function() passFor = nil end)

-- Security checks a player's permit; the principal hands one out. Commands with [id] or the nearest player.
local reach = cfg.CommandReach
Core.Command(cfg.PlayerCommands.checkPermit, function(args)
    if not Core.IsSecurity() then return Core.NotifyL('common.no_permission', 'error') end
    local target = Core.CommandTarget(args, reach)
    if target then checkPermit(target) end
end)
Core.Command(cfg.PlayerCommands.givePermit, function(args)
    if not Core.IsPrincipalOrMaster() then return Core.NotifyL('common.no_permission', 'error') end
    local target = Core.CommandTarget(args, reach)
    if target then givePermit(target) end
end)

-- At Student Affairs: ask for a permit, collect an approved one.
Core.Affairs.RegisterAction('security:permitRequest', { order = 70, icon = 'fa-solid fa-file-pen', label = 'security.affairs_permit_request', panel = true,
    visible = function(context) return cfg.Permit.Request.Enabled and context.isStudent == true and context.permitStatus ~= 'approved' end })

Core.Affairs.RegisterAction('security:permitCollect', { order = 71, icon = 'fa-solid fa-file-circle-check', label = 'security.affairs_permit_collect',
    visible = function(context) return context.isStudent == true and context.permitStatus == 'approved' end,
    run = function()
        local result = call('collectPermit')
        if not result.ok then Core.HandleResult(result, 'security') end
    end })

-- Gate guards ----------------------------------------------------------------------------------------

local function showGuards()
    local defs = {}
    if GlobalState['daddy_college:guards'] then
        for _, guard in ipairs(Core.World.entities({ kind = 'security_guard' })) do
            defs[#defs + 1] = {
                uid = 'guard:' .. guard.uid, presentation = 'ped', coords = guard.coords, revision = guard.revision, label = guard.label,
                model = (guard.model or '') ~= '' and guard.model or cfg.Guard.Model, scenario = (guard.scenario or '') ~= '' and guard.scenario or cfg.Guard.Scenario,
                distance = cfg.Guard.Distance,
                options = { { name = 'guard_gate', label = t('security.guard_show_permit'), icon = 'fa-solid fa-file-circle-check', distance = cfg.Guard.Distance,
                    onSelect = function()
                        CreateThread(function()
                            local result = call('guardGate', { uid = guard.uid })
                            if result.ok then return Core.NotifyL('security.guard_opened', 'success', result.seconds) end
                            Core.HandleResult(result, 'security')
                        end)
                    end } },
            }
        end
    end
    Core.World.anchors.sync('security_guards', defs)
end

Core.World.subscribe(showGuards)
AddStateBagChangeHandler('daddy_college:guards', 'global', function() SetTimeout(0, showGuards) end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    Core.Nui.Send('outOfBounds:hide', {})
end)

-- Group trips: the member's trip chip, and the teacher's list paper shown around.
RegisterNetEvent('daddy_college:trip:state', function(trip) Core.Nui.Send('trip:state', trip or { gone = true }) end)
RegisterNetEvent('daddy_college:trip:show', function(payload) Core.Nui.Send('trip:show', payload) end)
RegisterNetEvent('daddy_college:trip:hide', function(id) Core.Nui.Send('trip:hide', { showId = id }) end)
