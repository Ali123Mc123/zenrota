-- The first aid station tuned by an admin, once (cfg.Commands.tune): by a station the player kneels in the CPR clips,
-- each pose held still, with where the hands (or the face) come down in red and where they should be in green. The
-- arrows move the player in their own frame (Shift five times as far), Q/E turn them, Z/X scrub the clip, Tab goes to
-- the next pose, G puts red on green, R goes back to the measured spot, Enter saves for everyone (server/practicals/
-- tune.lua), Backspace or Esc leaves. Ready and compression share a spot, the breaths have their own.
local PC = Core.PracticalClient
local command = PC and (PC.cfg.Commands or {}).tune
if not command then return end

local t = DL.locale.t
local Frame = PracticalFrame
local A = PC.cfg.Kinds.first_aid_station.Anims
local POSES = {
    { name = 'ready', def = A.ready, phase = 0.0, part = 'press' },
    { name = 'press', def = A.press, phase = 0.5, part = 'press' },
    { name = 'breath', def = A.breath, phase = 0.3, part = 'breath' },
}
local R_HAND, L_HAND, HEAD = 57005, 18905, 31086
local KEY = { up = 172, down = 173, left = 174, right = 175, turnLeft = 44, turnRight = 38, back = 20, on = 73, nextPose = 37,
    auto = 47, reset = 45, save = 191, leave = 194, esc = 200, fast = 21 }
local tuning = false

local function nearest()
    local here, best, bestD = GetEntityCoords(cache.ped), nil, 4.0
    for _, view in pairs(PC.views) do
        if view.kind == 'first_aid_station' and view.frame then
            local d = #(here - PC.games.cpr.target(view, 'press'))
            if d < bestD then best, bestD = view, d end
        end
    end
    return best
end

local function dictOf(def) return (not IsPedMale(cache.ped) and def.female) or def.dict end

-- The pose's clip held still at its phase (played again when it is not playing).
local function hold(pose)
    if not PC.phase(cache.ped, pose.def) then
        PC.sequence(cache.ped, { def = pose.def, from = pose.phase })
        local untilMs = GetGameTimer() + 2000
        while not PC.phase(cache.ped, pose.def) and GetGameTimer() < untilMs do Wait(0) end
    end
    SetEntityAnimCurrentTime(cache.ped, dictOf(pose.def), pose.def.clip, pose.phase)
    SetEntityAnimSpeed(cache.ped, dictOf(pose.def), pose.def.clip, 0.0)
end

-- Where the pose puts the hands (their middle), or the face for the breaths.
local function measured(pose)
    if pose.part == 'breath' then return GetPedBoneCoords(cache.ped, HEAD, 0.0, 0.0, 0.0) end
    return (GetPedBoneCoords(cache.ped, R_HAND, 0.0, 0.0, 0.0) + GetPedBoneCoords(cache.ped, L_HAND, 0.0, 0.0, 0.0)) / 2
end

local function dot(at, r, g, b)
    DrawMarker(28, at.x, at.y, at.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.02, 0.02, 0.02, r, g, b, 230, false, false, 2, false, nil, nil, false)
end

local function label(at, text)
    SetDrawOrigin(at.x, at.y, at.z + 0.05, 0)
    SetTextScale(0.0, 0.3)
    SetTextFont(4)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

local function tune(view)
    local game = PC.games.cpr
    local spot, heading = game.kneel(view)
    local spots = { press = game.toSpot(view, spot, heading) }
    spots.breath = PC.tuned and PC.tuned.breath and { x = PC.tuned.breath.x, y = PC.tuned.breath.y, h = PC.tuned.breath.h }
        or { x = spots.press.x, y = spots.press.y, h = spots.press.h }
    local index, shown, told = 1, nil, false
    local pose = POSES[index]
    -- the manikin while nobody trains (the station shows only its bag then)
    local dressed = { objects = {} }
    if not view.objects.manikin then game.dress(dressed, view) end

    -- the player on a spot (a move may stop the clip: said once in F8 after a nudge, the loop plays it again)
    local function put(s, nudge)
        local p, h = game.spot(view, s)
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoordsNoOffset(cache.ped, p.x, p.y, GetEntityCoords(cache.ped).z, false, false, false)
        SetEntityHeading(cache.ped, h)
        if not nudge or told then return end
        told = true
        Wait(0)
        print(('[daddy_college] cpr tune: moving the player %s the clip'):format(PC.phase(cache.ped, pose.def) and 'kept' or 'stopped'))
    end
    local function pressed(key) return IsDisabledControlJustPressed(0, key) end

    PC.walkTo(spot, heading)
    hold(pose)
    while tuning do
        DisableAllControlActions(0)
        EnableControlAction(0, 1, true) -- look around
        EnableControlAction(0, 2, true)
        EnableControlAction(0, 249, true) -- push to talk
        local s = spots[pose.part]
        local step = IsDisabledControlPressed(0, KEY.fast) and 5 or 1
        local moved
        if pressed(KEY.up) or pressed(KEY.down) or pressed(KEY.left) or pressed(KEY.right) then
            local dx = (pressed(KEY.right) and 1 or 0) - (pressed(KEY.left) and 1 or 0)
            local dy = (pressed(KEY.up) and 1 or 0) - (pressed(KEY.down) and 1 or 0)
            local mx, my = Frame.turn(s.h, dx * 0.01 * step, dy * 0.01 * step)
            s.x, s.y, moved = s.x + mx, s.y + my, true
        elseif pressed(KEY.turnLeft) or pressed(KEY.turnRight) then
            s.h, moved = (s.h + (pressed(KEY.turnLeft) and step or -step)) % 360.0, true
        elseif pressed(KEY.back) or pressed(KEY.on) then
            pose.phase = math.max(0.0, math.min(0.99, pose.phase + (pressed(KEY.on) and 0.05 or -0.05)))
            hold(pose)
        elseif pressed(KEY.nextPose) then
            local part = pose.part
            index = index % #POSES + 1
            pose = POSES[index]
            if pose.part ~= part then put(spots[pose.part]) end
            hold(pose)
        elseif pressed(KEY.auto) then
            local m, g, c = measured(pose), game.target(view, pose.part), GetEntityCoords(cache.ped)
            local fixed = game.toSpot(view, vector3(c.x + g.x - m.x, c.y + g.y - m.y, 0.0), GetEntityHeading(cache.ped))
            s.x, s.y, moved = fixed.x, fixed.y, true
        elseif pressed(KEY.reset) then
            local p, h = game.measuredKneel(view)
            local fresh = pose.part == 'press' and game.toSpot(view, p, h) or spots.press
            s.x, s.y, s.h, moved = fresh.x, fresh.y, fresh.h, true
        elseif pressed(KEY.save) then
            local result = PC.call('tune', { press = spots.press, breath = spots.breath })
            if result.ok then
                Core.NotifyL('practicals.tune_saved', 'success')
                print(('[daddy_college] cpr tune saved: press = { x = %.3f, y = %.3f, h = %.1f }, breath = { x = %.3f, y = %.3f, h = %.1f }'):format(
                    spots.press.x, spots.press.y, spots.press.h, spots.breath.x, spots.breath.y, spots.breath.h))
            else
                Core.HandleResult(result, 'practicals')
            end
        elseif pressed(KEY.leave) or pressed(KEY.esc) or IsEntityDead(cache.ped)
            or #(GetEntityCoords(cache.ped) - game.target(view, 'press')) > 6.0 then
            tuning = false
        end
        if moved then put(s, true) end
        if tuning and not PC.phase(cache.ped, pose.def) then hold(pose) end

        -- red: where the pose puts the hands (the face); green: where they should be; the gap in cm
        local m, g = measured(pose), game.target(view, pose.part)
        local miss = #(vector2(g.x - m.x, g.y - m.y))
        dot(m, 255, 60, 60)
        dot(g, 60, 220, 90)
        DrawLine(m.x, m.y, m.z, g.x, g.y, g.z, 255, 255, 255, 200)
        label(m, ('%.0f cm'):format(miss * 100))
        local text = t('practicals.tune_panel', t('practicals.tune_pose_' .. pose.name), index,
            t(pose.part == 'breath' and 'practicals.tune_face' or 'practicals.tune_hands', ('%.0f'):format(miss * 100)),
            ('%.2f'):format(s.x), ('%.2f'):format(s.y), ('%.0f'):format(s.h), ('%.2f'):format(pose.phase))
        if text ~= shown then
            shown = text
            lib.showTextUI(text, { position = 'left-center' })
        end
        Wait(0)
    end
    lib.hideTextUI()
    for name in pairs(dressed.objects) do PC.remove(dressed, name) end
    if A.exit then PC.anim(A.exit) else ClearPedTasks(cache.ped) end
end

RegisterCommand(command, function()
    if tuning then
        tuning = false
        return
    end
    if PC.playing then return end
    local result = PC.call('tuned')
    if not result.ok or not result.data.admin then return Core.HandleResult({ ok = false, error = 'no_permission' }, 'practicals') end
    local view = nearest()
    if not view then return Core.NotifyL('practicals.tune_far', 'error') end
    if view.scene and view.scene.user then return Core.NotifyL('practicals.tune_busy', 'error') end
    tuning = true
    CreateThread(function()
        local ok, err = pcall(tune, view)
        if not ok then
            tuning = false
            lib.hideTextUI()
            print(('^1[daddy_college] cpr tune: %s^7'):format(err))
        end
    end)
end, false)
