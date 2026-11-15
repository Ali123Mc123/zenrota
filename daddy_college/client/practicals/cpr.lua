-- The first aid station: a manikin lying along the mat (its chest and head move), a training arm for the bandage.
-- Without the props resource a ped lies on the mat and plays the game's partner clips. The player kneels where an
-- admin tuned it in the game (tune.lua), else beside the chest pad with where their hands come down measured and the
-- student moved onto the pad; the clips play where they kneel. The checks are cards on screen, a compression is a click on the chest (or Space): one stroke of the clip on
-- every client, held still between clicks. After the set's compressions, a rescue breath is the mouse held on the head
-- (or E held). The chest pad follows the student's hands on every client. The trainer on screen is views/practicals/Cpr.vue.
local PC = Core.PracticalClient
if not PC then return end

local cfg = PC.cfg
local Frame = PracticalFrame
local def = cfg.Kinds.first_aid_station
local L, A = def.Layout, def.Anims
local CAL = (cfg.Calibration or {}).cpr
-- The compression clip from its way down (from) to back up (cut), as phases 0-1.
local PRESS = { from = CAL and CAL.press and CAL.press.from or 0.3, cut = CAL and CAL.press and CAL.press.cut or 0.85 }
local REACH = L.reach or 0.70 -- how far in front of the student the ready clip's hands come down, until measured
-- The ready clip's hands as measured on a ped model (its own x, y), kept so the next game kneels in the right spot.
local reaches = {}

-- The manikin's frame: its origin, with the manikin sitting on its spot on the mat's top, turned along the mat (180
-- more when the editor found room to kneel only on the other side). Kept in the station's frame once the model is
-- known (a new frame when the body is measured again).
local function body(view)
    local frame = view.frame
    if frame.manikin then return frame.manikin end
    local spot, h = PC.on(view, L.manikin.on), PC.heading(view, L.manikin.heading + (frame.side == 'left' and 180.0 or 0.0))
    local model = PC.hasProps() and PC.model(L.manikin.model)
    local origin = model and PC.seat(model, spot, h) or spot
    local manikin = { x = origin.x, y = origin.y, z = origin.z, h = h }
    if model then frame.manikin = manikin end
    return manikin
end

local function at(view, v) return PC.point(body(view), v) end

-- The lying ped (the fallback): a transition, then a loop, as one task.
local function partnerPlays(ped, ...)
    if ped and DoesEntityExist(ped) then PC.sequence(ped, ...) end
end

-- The chest pad follows the student's hands on every client (section 5.6): pressed by how far the hand bones are under
-- where they touch it, up a few millimetres while a breath goes in; a click when a compression is deep enough. No
-- network: each client reads the hands of the ped it sees.
local function follow(view)
    local entity = view.objects.chest
    if view.following or not entity then return end
    view.following = true
    CreateThread(function()
        local _, max = PC.box(GetEntityModel(entity))
        local rest = at(view, L.chest.at)
        local touch = rest.z + max.z + ((CAL or {}).hands or 0.05)
        local deep, rise = false, 0.0
        -- only while compressions or breaths can happen and the student's ped is here (the next event starts it again)
        while view.built and not view.gone and DoesEntityExist(entity) and view.scene and view.scene.state == 'active'
            and (view.scene.phase == 'press' or view.scene.phase == 'breath') do
            local ped = PC.userPed(view.scene)
            if not ped then break end
            local z = (GetPedBoneCoords(ped, 57005, 0.0, 0.0, 0.0).z + GetPedBoneCoords(ped, 18905, 0.0, 0.0, 0.0).z) / 2
            local depth = Frame.depth(touch, z, L.chest.travel)
            rise = rise + ((view.breathing and (L.chest.rise or 0.007) or 0.0) - rise) * math.min(1.0, (GetFrameTime() or 0.016) / 0.3)
            SetEntityCoordsNoOffset(entity, rest.x, rest.y, rest.z - depth + rise, false, false, false)
            if depth >= 0.04 then
                if not deep then PC.sound('press', rest) end
                deep = true
            elseif depth < 0.01 then
                deep = false
            end
            Wait(0)
        end
        if DoesEntityExist(entity) then SetEntityCoordsNoOffset(entity, rest.x, rest.y, rest.z, false, false, false) end
        view.following = false
    end)
end

-- A compression: the pad follows the hands (started once per game).
local function press(view) follow(view) end

local function tilt(view, on)
    local head, m = view.objects.head, body(view)
    if not head then return end
    local p = at(view, L.head.at + vector3(0.0, 0.0, on and L.head.lift or 0.0))
    SetEntityCoordsNoOffset(head, p.x, p.y, p.z, false, false, false)
    SetEntityRotation(head, on and -L.head.tilt or 0.0, 0.0, m.h, 2, true)
    -- the body whose neck collar follows the tilted head (the seam stays covered), the new one up before the old goes
    local old, model = view.objects.manikin, PC.model(on and L.head.tilted or L.manikin.model)
    if not model or not old or GetEntityModel(old) == joaat(model) then return end
    view.objects.manikin = nil
    if PC.object(view, 'manikin', model, vector3(m.x, m.y, m.z), m.h, true) then
        if DoesEntityExist(old) then DeleteEntity(old) end
    else
        view.objects.manikin = old
    end
end

-- Compressions -----------------------------------------------------------------------------------------------------
-- The press clip loops as the student's task (others' games get it) and is held at the top of a stroke on each client;
-- one click plays one stroke (on the student's client at once, on the others' with the press event).

local function pressDict(ped) return (not IsPedMale(ped) and A.press.female) or A.press.dict end

local function holdPress(ped)
    local dict = pressDict(ped)
    if not IsEntityPlayingAnim(ped, dict, A.press.clip, 3) then return false end
    SetEntityAnimCurrentTime(ped, dict, A.press.clip, PRESS.from)
    SetEntityAnimSpeed(ped, dict, A.press.clip, 0.0)
    return true
end

local strokes = {}
local function stroke(ped, speed)
    if not ped or not DoesEntityExist(ped) then return end
    local dict, clip = pressDict(ped), A.press.clip
    if not IsEntityPlayingAnim(ped, dict, clip, 3) then return end
    SetEntityAnimCurrentTime(ped, dict, clip, PRESS.from)
    SetEntityAnimSpeed(ped, dict, clip, speed)
    local token = (strokes[ped] or 0) + 1
    strokes[ped] = token
    CreateThread(function()
        local untilMs = GetGameTimer() + 2000
        while strokes[ped] == token and GetGameTimer() < untilMs do
            local t = IsEntityPlayingAnim(ped, dict, clip, 3) and GetEntityAnimCurrentTime(ped, dict, clip)
            if not t or t >= PRESS.cut or t < PRESS.from - 0.02 then break end
            Wait(0)
        end
        if strokes[ped] == token then
            strokes[ped] = nil
            holdPress(ped)
        end
    end)
end

-- The press pose: the clip looped (after a transition when one is given), held at the top once it plays.
local pressLoop = { dict = A.press.dict, female = A.press.female, clip = A.press.clip, loop = true }
local function pressPose(transition)
    if transition then PC.sequence(cache.ped, transition, pressLoop) else PC.sequence(cache.ped, pressLoop) end
    CreateThread(function()
        local untilMs = GetGameTimer() + 4000
        while GetGameTimer() < untilMs and not holdPress(cache.ped) do Wait(50) end
    end)
end

local game = {}
PC.games.cpr = game

-- The CPR clips' origin (section 5.6): turned from the manikin by Calibration.cpr.turn and placed so char_b's chest at
-- the bottom of a compression is our chest pad, on the floor the student kneels on. nil without the numbers.
function game.origin(view)
    if not CAL then return nil end
    local _, _, _, o = Frame.kneel(body(view), L.chest.at, CAL)
    return { x = o.x, y = o.y, z = view.frame.floor.z, h = o.h }
end

-- The spots an admin tuned in the game (client/practicals/tune.lua): { press = { x, y, h }, breath = ... } in the
-- manikin's frame, h from the manikin's heading. nil until one is saved; then no measuring.
CreateThread(function()
    local result = PC.call('tuned')
    if result.ok then PC.tuned = result.data.tuned end
end)
RegisterNetEvent('daddy_college:practicals:tuned', function(tuned) PC.tuned = tuned end)

-- A spot in the manikin's frame in the world (on the floor, and the heading), and a world point and heading back.
function game.spot(view, s)
    local m = body(view)
    local p = PC.point(m, vector3(s.x, s.y, 0.0))
    return vector3(p.x, p.y, view.frame.floor.z), (m.h + s.h) % 360.0
end

function game.toSpot(view, p, heading)
    local m = body(view)
    local x, y = Frame.turn(-m.h, p.x - m.x, p.y - m.y)
    return { x = x, y = y, h = (heading - m.h) % 360.0 }
end

-- Where the hands go (part 'press': the chest pad's top) or the face (part 'breath': over the head's mouth).
function game.target(view, part)
    if part == 'breath' then return at(view, L.head.at + vector3(0.0, 0.06, 0.08)) end
    return at(view, L.chest.at + vector3(0.0, 0.0, 0.03))
end

-- Where the student kneels and the way they face: the tuned spot, else on their side of the manikin, facing it, the
-- ready clip's hands (as measured on this ped model, else REACH straight ahead) on the chest pad.
local function side() return L.kneel.x >= 0 and 1 or -1 end

function game.measuredKneel(view)
    local m, pad = body(view), at(view, L.chest.at)
    local h = (m.h + (side() > 0 and 90.0 or -90.0)) % 360.0
    local r = reaches[GetEntityModel(cache.ped)] or vector2(0.0, REACH)
    local dx, dy = Frame.turn(h, r.x, r.y)
    return vector3(pad.x - dx, pad.y - dy, view.frame.floor.z), h
end

function game.kneel(view)
    if PC.tuned and PC.tuned.press then return game.spot(view, PC.tuned.press) end
    return game.measuredKneel(view)
end

-- What the kneeling did, in F8 (to send when the hands still miss).
local function note(text, ...) print(('[daddy_college] cpr: ' .. text):format(...)) end

-- How each transition clip (the kneel, over the head, back to the chest) moves the student by its own root motion,
-- per clip and ped model ({ x, y } in the frame it starts in, h), measured the first time it plays; the student then
-- starts that much before the tuned spot so the clip ends on it.
local drifts = {}
local function driftKey(clip) return GetEntityModel(cache.ped) .. ':' .. clip.clip end

-- Where a transition into a part starts so it ends on the part's tuned spot (the spot itself until its drift is known).
local function startFor(view, part, clip)
    local p, h = game.spot(view, PC.tuned[part])
    local d = drifts[driftKey(clip)]
    if not d then return p, h end
    local h0 = (h - d.h) % 360.0
    local dx, dy = Frame.turn(h0, d.x, d.y)
    return vector3(p.x - dx, p.y - dy, p.z), h0
end

-- A transition into a part's loop that ends on the part's tuned spot: the student starts where it ends there (once its
-- drift is known) and play() starts it; once the loop plays (ready()) the drift is kept and the student put on the spot
-- when they are not on it (again() plays the loop when the move stops it). Without a tuned spot just play().
local function into(view, mine, part, clip, ready, play, again)
    if not (PC.tuned and PC.tuned[part]) then return play() end
    local ped = cache.ped
    local from, fromH = GetEntityCoords(ped), GetEntityHeading(ped)
    if drifts[driftKey(clip)] then
        local p, h = startFor(view, part, clip)
        from, fromH = vector3(p.x, p.y, from.z), h
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoordsNoOffset(ped, from.x, from.y, from.z, false, false, false)
        SetEntityHeading(ped, fromH)
    end
    play()
    CreateThread(function()
        local untilMs = GetGameTimer() + 5000
        repeat
            Wait(50)
            if mine.over then return end
            if GetGameTimer() > untilMs then return note('%s: the loop after it did not start in 5 s', clip.clip) end
        until ready()
        Wait(200)
        if mine.over or not ready() then return end
        local c, ch = GetEntityCoords(ped), GetEntityHeading(ped)
        local lx, ly = Frame.turn(-fromH, c.x - from.x, c.y - from.y)
        drifts[driftKey(clip)] = { x = lx, y = ly, h = (ch - fromH + 180.0) % 360.0 - 180.0 }
        local p, h = game.spot(view, PC.tuned[part])
        local off, turn = #(vector2(c.x - p.x, c.y - p.y)), math.abs((ch - h + 180.0) % 360.0 - 180.0)
        if off < 0.02 and turn < 2.0 then return note('%s ended on the tuned spot', clip.clip) end
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoordsNoOffset(ped, p.x, p.y, c.z, false, false, false)
        SetEntityHeading(ped, h)
        Wait(0)
        local kept = ready() and true or false
        if not kept then again() end
        note('%s left the student %.0f cm and %.0f deg off the tuned spot: put back, the loop %s; the next one starts before it',
            clip.clip, off * 100, turn, kept and 'kept playing' or 'stopped and was played again')
    end)
end

-- The ready clip's hands onto the chest pad (no tuned spot): once the clip plays, where its hands are is measured and
-- the ped moved by the miss, the clip played again when the move stopped it. A ped that is not in the clip has its
-- hands by its side, so a reach that is not in front of it moves nothing and is not kept.
local function align(view, heading)
    local ped, untilMs = cache.ped, GetGameTimer() + 4000
    while not PC.phase(ped, A.ready) do
        if GetGameTimer() > untilMs then return note('the ready clip did not start in 4 s, nothing moved') end
        Wait(50)
    end
    Wait(500)
    local sx, sy, ox, oy, n = 0.0, 0.0, 0.0, 0.0, 0
    untilMs = GetGameTimer() + 300
    while GetGameTimer() < untilMs do
        local r, l = GetPedBoneCoords(ped, 57005, 0.0, 0.0, 0.0), GetPedBoneCoords(ped, 18905, 0.0, 0.0, 0.0)
        local x, y, z = (r.x + l.x) / 2, (r.y + l.y) / 2, (r.z + l.z) / 2
        local o = GetOffsetFromEntityGivenWorldCoords(ped, x, y, z)
        sx, sy, ox, oy, n = sx + x, sy + y, ox + o.x, oy + o.y, n + 1
        Wait(0)
    end
    local reach = vector2(ox / n, oy / n)
    if reach.y < 0.3 or reach.y > 1.1 or math.abs(reach.x) > 0.5 then
        return note('hands at x %.2f y %.2f from the student, not in front: nothing moved', reach.x, reach.y)
    end
    reaches[GetEntityModel(ped)] = reach
    local pad, c = at(view, L.chest.at), GetEntityCoords(ped)
    local dx, dy = pad.x - sx / n, pad.y - sy / n
    local miss = math.sqrt(dx * dx + dy * dy)
    if miss < 0.025 then return note('hands at x %.2f y %.2f, %.1f cm from the pad: no move needed', reach.x, reach.y, miss * 100) end
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoordsNoOffset(ped, c.x + dx, c.y + dy, c.z, false, false, false)
    SetEntityHeading(ped, heading)
    Wait(0)
    local kept = PC.phase(ped, A.ready) ~= nil
    if not kept then PC.sequence(ped, A.ready) end
    note('hands at x %.2f y %.2f, %.1f cm from the pad: moved, the clip %s', reach.x, reach.y, miss * 100, kept and 'kept playing' or 'stopped and was played again')
end

-- A point from the manikin's origin; the manikin's parts where build puts them (the editor's ghosts).
game.at = at
function game.parts(view)
    local m, out = body(view), {}
    local manikin = PC.model(L.manikin.model)
    if not manikin then return out end
    out[1] = { key = 'manikin', model = manikin, at = PC.seat(manikin, PC.on(view, L.manikin.on), m.h), heading = m.h }
    for _, name in ipairs({ 'chest', 'head' }) do
        local model = PC.model(L[name].model)
        if model then out[#out + 1] = { key = name, model = model, at = at(view, L[name].at), heading = m.h } end
    end
    return out
end

-- The manikin's body, chest pad and head into a table's objects (the station's own, or the tuning's while nobody
-- trains). -> false without the props resource
function game.dress(into, view)
    local h, manikin = body(view).h, PC.hasProps() and PC.model(L.manikin.model)
    if not manikin then return false end
    PC.object(into, 'manikin', manikin, PC.on(view, L.manikin.on), h)
    PC.object(into, 'chest', PC.model(L.chest.model), at(view, L.chest.at), h, true)
    PC.object(into, 'head', PC.model(L.head.model), at(view, L.head.at), h, true)
    return true
end

function game.build(view)
    local h = body(view).h
    if game.dress(view, view) then
        if def.Bandage ~= false then PC.object(view, 'arm', PC.model(L.arm.model), at(view, L.arm.at), h) end
        return
    end
    -- The fallback: a ped lying on the mat.
    local model = L.fallbackPed.model
    if not pcall(lib.requestModel, model, 3000) then return end
    local p = at(view, L.fallbackPed.at)
    pcall(function() exports['FeloxAC']:CreatePed(joaat(model)) end) --[[FeloxAC:auto]]
    local ped = CreatePed(4, joaat(model), p.x, p.y, p.z, (h + L.fallbackPed.heading) % 360.0, false, false)
    SetModelAsNoLongerNeeded(joaat(model))
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    FreezeEntityPosition(ped, true)
    view.objects.partner = ped
    PC.origins[ped] = game.origin(view) -- the partner clips at the same origin as the student's
    partnerPlays(ped, A.partnerReady)
end

function game.apply(view, scene, event)
    local partner = view.objects.partner
    if scene.state == 'active' then follow(view) end
    if event.op == 'press' and event.right then
        if partner then partnerPlays(partner, A.partnerPress, A.partnerReady) else press(view) end
        -- the stroke on the student's ped as this client sees it (the student's own client strokes on the click)
        if not PC.mine(view) then stroke(PC.userPed(scene), 1.4) end
    elseif event.op == 'breathIn' then
        view.breathing = true
        if partner then partnerPlays(partner, A.partnerBreath) end
        tilt(view, true)
    elseif event.op == 'breath' then
        view.breathing = false
        if scene.phase ~= 'breath' then
            if partner then partnerPlays(partner, A.partnerReady) end
            tilt(view, false)
        end
    end
    -- The arm wrapped once the bandage is done.
    if view.objects.arm and scene.wrapped and not view.wrapped then
        view.wrapped = true
        PC.object(view, 'arm', PC.model(L.arm.done, L.arm.model), at(view, L.arm.at), body(view).h)
    end
    if scene.state == 'idle' then view.wrapped = false end
end

function game.clear(view)
    view.wrapped, view.breathing = false, false
    local partner = view.objects.partner
    if partner then PC.origins[partner] = nil end
    if partner and DoesEntityExist(partner) then DeleteEntity(partner) end
    view.objects.partner = nil
end

-- Someone new watches: the pose's loop starts again at the clips' origin so their game gets the task (section 5.8).
function game.resync(_, mine)
    if mine.pose == 'breath' then PC.sequence(cache.ped, A.breath)
    elseif mine.pose == 'press' then pressPose()
    elseif mine.pose == 'ready' then PC.sequence(cache.ped, A.ready) end
end

-- The way the student faces here: across the manikin from their side (the camera's shots turn from it).
function game.facing(view) return (body(view).h + (L.kneel.x >= 0 and 90.0 or -90.0)) % 360.0, 1 end

-- Named points for /practicaldebug (the camera's shots look at them too).
function game.points(view)
    return { { name = 'manikin', at = at(view, vector3(0, 0, 0)) }, { name = 'chest', at = at(view, L.chest.at) },
        { name = 'head pivot', at = at(view, L.head.at) },
        { name = 'kneel', at = (game.kneel(view)), r = 255, g = 80, b = 80 },
        { name = 'camera', at = at(view, def.Camera.on), r = 255, g = 255, b = 0 } }
end

-- Playing --------------------------------------------------------------------------------------------------------

local function marksFor(view)
    return PC.marks({ { id = 'chest', kind = 'chest', at = game.target(view, 'press'), r = 0.07 },
        { id = 'head', kind = 'head', at = game.target(view, 'breath'), r = 0.06 } })
end

function game.play(view, mine)
    local data = mine.game.data
    -- kneel beside the chest pad (slid along the manikin when someone stands there), or where the kneel clip ends on the
    -- tuned spot; the clips play where the student is
    local spot, heading = game.kneel(view)
    if PC.tuned and PC.tuned.press then spot, heading = startFor(view, 'press', A.kneel) end
    local ax, ay = Frame.turn(body(view).h, 0.0, 1.0)
    local kneel = PC.freeSpot(view, spot, vector3(ax, ay, 0.0))
    if not kneel then return Core.NotifyL('practicals.spot_taken', 'error') end
    PC.walkTo(kneel, heading)
    PC.origins[cache.ped] = nil
    -- the pose the student is in: 'ready' (hands on the chest), 'press' (compressing), 'breath' (over the head), 'bandage'
    local pose = 'ready'
    mine.pose = pose
    -- the chest's loops (ready or compressing) and the breath's, played again after a move stops them
    local function atChest() return PC.phase(cache.ped, A.ready) or PC.phase(cache.ped, pressLoop) end
    local function chestAgain() if pose == 'press' then pressPose() else PC.sequence(cache.ped, A.ready) end end
    local function atHead() return PC.phase(cache.ped, A.breath) end
    local function headAgain() PC.sequence(cache.ped, A.breath) end
    local function backToChest() into(view, mine, 'press', A.toPress, atChest, function() pressPose(A.toPress) end, chestAgain) end
    into(view, mine, 'press', A.kneel, atChest, function() PC.sequence(cache.ped, A.kneel, A.ready) end, chestAgain)
    PC.shot(view, 'overview')
    local phase = #data.checks > 0 and 'checks' or 'press'
    PC.open(mine, 'practicals.cpr', { checks = data.checks, bandage = data.bandage, compressions = data.compressions, breaths = data.breaths,
        cycles = data.cycles, rate = data.rate, breathMs = data.breathMs, phase = phase, seconds = data.seconds })
    -- the hands onto the pad while the checks are read (once the ready clip plays), unless an admin tuned the spot
    if not (PC.tuned and PC.tuned.press) then align(view, heading) end
    local marks = marksFor(view)
    local lastPress, breathAt, holdingHead = nil, nil, false
    local count = 0 -- compressions in this set, as the server counted them
    local roll

    local function setPose(next)
        pose = next
        mine.pose = next
    end

    local function enter(next)
        phase = next
        if next == 'press' then
            lastPress, count = nil, 0
            if pose == 'breath' then
                backToChest()
            elseif pose ~= 'press' then
                pressPose()
            end
            setPose('press')
        elseif next == 'bandage' then
            setPose('bandage')
            PC.anim(A.bandage, true)
            local model = PC.model(L.roll.model)
            if model and pcall(lib.requestModel, model, 2000) then
                local c = GetEntityCoords(cache.ped)
                pcall(function() exports['FeloxAC']:CreateObject(joaat(model)) end) --[[FeloxAC:auto]]
                roll = CreateObject(joaat(model), c.x, c.y, c.z, false, false, false)
                SetModelAsNoLongerNeeded(joaat(model))
                PC.attach(roll, cache.ped, def.Hand)
            end
        end
        PC.state({ phase = next })
    end
    if phase == 'press' then enter('press') end

    -- Each click is one compression: one stroke of the clip (as fast as the clicks come), then held at the top. The
    -- set's last compression asks for the breaths; more clicks wait for them.
    local function compress(t)
        if phase ~= 'press' then return end
        if count >= data.compressions then return PC.state({ needBreath = GetGameTimer() }) end
        local ms = lastPress and t - lastPress or 0
        lastPress = t
        if pose ~= 'press' then pressPose() setPose('press') end
        stroke(cache.ped, ms > 0 and math.max(0.8, math.min(2.2, 560 / ms)) or 1.4)
        press(view)
        PC.send('press', { ms = ms }, function(out)
            if not out then return end
            if out.right and out.n then count = out.n end
            PC.state({ press = out, gapMs = ms })
        end)
    end

    -- A breath only once the set's compressions are done (or between the set's breaths): over the head, then its loop
    -- for as long as the breath is held.
    local function breatheIn(t)
        if breathAt or (phase ~= 'press' and phase ~= 'breath') then return end
        if phase == 'press' and count < data.compressions then return PC.state({ notYet = GetGameTimer() }) end
        breathAt = t
        if pose ~= 'breath' then
            setPose('breath')
            into(view, mine, 'breath', A.toBreath, atHead, function() PC.sequence(cache.ped, A.toBreath, A.breath) end, headAgain)
        end
        PC.send('breathStart', {}, function(out)
            if not out then
                breathAt = nil
                if phase == 'press' then
                    backToChest()
                    setPose('press')
                end
                return
            end
            phase = 'breath'
            PC.state({ phase = 'breath', breathing = true, count = out.count })
        end)
    end

    local function breatheOut(t)
        if not breathAt then return end
        local ms = t - breathAt
        breathAt = nil
        PC.state({ breathing = false })
        PC.send('breathEnd', { ms = ms }, function(out)
            if not out then return end
            PC.state({ breath = out })
            if out.phase ~= 'breath' then SetTimeout(700, function() if not mine.over then enter(out.phase) end end) end
        end)
    end

    while not PC.stopped(mine) do
        for _, e in ipairs(PC.events()) do
            if e.type == 'quit' then PC.leave(mine)
            elseif e.type == 'pick' then
                -- a card picked on screen: a check or a bandage step
                local op = phase == 'bandage' and 'bandage' or 'check'
                PC.send(op, { id = tonumber(e.id) }, function(out)
                    if not out then return end
                    PC.state({ card = { id = tonumber(e.id), right = out.right } })
                    if out.phase ~= phase then SetTimeout(600, function() if not mine.over then enter(out.phase) end end) end
                end)
            elseif e.type == 'key' and e.key == 'press' then compress(e.at)
            elseif e.type == 'key' and e.key == 'breathDown' then breatheIn(e.at)
            elseif e.type == 'key' and e.key == 'breathUp' then breatheOut(e.at)
            elseif e.type == 'down' and e.button ~= 2 then
                local m = PC.markAt(marks, e.x, e.y)
                if m and m.kind == 'chest' then compress(e.at)
                elseif m and m.kind == 'head' then holdingHead = true breatheIn(e.at) end
            elseif e.type == 'up' and holdingHead then
                holdingHead = false
                breatheOut(e.at)
            end
        end
        Wait(0)
    end
    strokes[cache.ped] = nil
    if roll and DoesEntityExist(roll) then DeleteEntity(roll) end
end
