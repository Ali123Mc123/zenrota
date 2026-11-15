-- Moves the Rig: Catmull-Rom moves with one global ease, retargets mid-move, shot lists with cut dips,
-- idle sway and rack focus. Reduced motion turns moves into cuts inside a short dip; off makes them hard cuts.
Director = {}

local LEVELS = { [0] = 'full', [1] = 'reduced', [2] = 'off', full = 'full', reduced = 'reduced', off = 'off' }
local DIP_MS, RAMP_MS, HOLD_MS = 150, 1500, 250

local move, sway, rest, restAt = nil, nil, nil, 0
local track, aim = nil, nil -- a point the resting camera keeps where it was in the picture (the character's head)
local token, awake, listing, ownFade = 0, false, false, false
local dips = 0

-- The player's camera motion setting: full | reduced | off.
function Director.motion()
    local prefs = type(MC) == 'table' and type(MC.prefs) == 'table' and MC.prefs or {}
    return LEVELS[prefs.motion] or LEVELS[(Config.Theme or {}).Motion] or 'full'
end

local function wake()
    if awake then return end
    awake = true
    Frame.on('cam', Director.update)
end

local function sleep()
    if not awake then return end
    awake = false
    Frame.off('cam')
end

-- Settles on a pose: the sway starts from here and ramps in.
local function settle(pose, onDone)
    move, rest, restAt, aim = nil, CamMath.copy(pose), GetGameTimer(), nil
    if sway or track then wake() end
    if onDone then CreateThread(onDone) end
end

-- A short game fade around a cut; when someone else holds the screen black it is a plain cut.
local function dip(ms, t, apply)
    if (IsScreenFadedOut() or IsScreenFadingOut()) and not ownFade then
        apply()
        return true, false
    end
    ownFade, dips = true, dips + 1
    local mine = dips
    DoScreenFadeOut(math.floor(ms / 2))
    local deadline = GetGameTimer() + ms + 600
    while not IsScreenFadedOut() and GetGameTimer() < deadline do Wait(0) end
    if t ~= token then
        if ownFade and dips == mine then
            ownFade = false
            DoScreenFadeIn(math.floor(ms / 2))
        end
        return false
    end
    apply()
    return true, true
end

local function undip(ms, t, faded)
    if not faded or t ~= token then return end
    ownFade = false
    DoScreenFadeIn(math.floor(ms / 2))
end

-- Reduced or off motion: straight to the end pose, inside a dip for reduced.
local function jump(pose, onDone, withDip)
    local t = token
    if not withDip then
        Rig.set(pose)
        return settle(pose, onDone)
    end
    CreateThread(function()
        local ok, faded = dip(DIP_MS, t, function() Rig.set(pose) end)
        if not ok then return end
        settle(pose, onDone)
        undip(DIP_MS, t, faded)
    end)
end

-- Starts a move along unwrapped poses; the caller has bumped the token when it interrupts.
local function launch(points, ms, ease, opts)
    ms = math.max(0, tonumber(ms) or 0)
    local first, last = points[1], points[#points]
    local level = Director.motion()
    if not Rig.active() then Rig.start(first) end
    if opts.subject then Rig.subject(opts.subject, level == 'full' and ms or 0) end
    if level ~= 'full' or ms <= 0 or #points == 1 then
        move = nil
        return jump(last, opts.onDone, level == 'reduced' and ms > 0 and not opts.instant)
    end
    move = { points = points, shares = CamMath.chordShares(points), ms = ms, ease = ease or 'smooth', t0 = GetGameTimer(), onDone = opts.onDone }
    rest = nil
    Rig.set(first)
    wake()
end

local function cancel()
    token = token + 1
    move, listing = nil, false
end

-- Plays a move { keys, ms, ease }: opts { from = 'first'|'current', anchor, subject, onDone }.
function Director.play(mv, opts)
    opts = type(opts) == 'table' and opts or {}
    if type(mv) ~= 'table' then return false end
    local points = CamMath.path(mv.keys, opts.anchor)
    if #points == 0 then return false end
    if opts.from == 'current' and Rig.active() then
        table.insert(points, 1, Rig.pose())
        for i = 2, #points do
            points[i].rx, points[i].rz = CamMath.unwrap(points[i - 1].rx, points[i].rx), CamMath.unwrap(points[i - 1].rz, points[i].rz)
        end
    end
    local interrupting = move ~= nil
    cancel()
    launch(points, mv.ms, mv.ease or (interrupting and opts.from == 'current' and 'outCubic' or nil), opts)
    return true
end

-- From the current pose to a new one, any time; opts { arc (mid pulled off the anchor), anchor, mid, ease, subject, onDone }.
function Director.retarget(target, ms, opts)
    opts = type(opts) == 'table' and opts or {}
    local to = CamMath.pose(target)
    if not to then return false end
    local from = Rig.active() and Rig.pose() or to
    to.rx, to.rz = CamMath.unwrap(from.rx, to.rx), CamMath.unwrap(from.rz, to.rz)
    local points = { from }
    local mid = opts.mid or (opts.anchor and tonumber(opts.arc) and CamMath.arcMid(from, to, opts.anchor, opts.arc))
    if mid and CamMath.dist(from, to) > 0.05 then
        points[2] = { x = mid.x, y = mid.y, z = mid.z, rx = (from.rx + to.rx) / 2, ry = 0, rz = (from.rz + to.rz) / 2, fov = (from.fov + to.fov) / 2 }
    end
    points[#points + 1] = to
    local ease = opts.ease or (move and 'outCubic' or 'smooth')
    cancel()
    launch(points, ms, ease, opts)
    return true
end

-- One shot: a cut to its first key (a dip unless cut = false; hard with motion off), then the move or a still hold.
local function shot(mv, i, t, opts, level, wrapped)
    local points = CamMath.path(mv.keys, opts.anchor)
    local first = points[1]
    if not first then return end
    local function cutTo()
        Rig.set(first)
        SetFocusPosAndVel(first.x + 0.0, first.y + 0.0, first.z + 0.0, 0.0, 0.0, 0.0)
    end
    if mv.cut ~= false and (i > 1 or wrapped) and level ~= 'off' then
        local ms = level == 'reduced' and DIP_MS or (tonumber(opts.dipMs) or 600)
        local ok, faded = dip(ms, t, cutTo)
        if not ok then return end
        Wait(HOLD_MS)
        undip(ms, t, faded)
    else
        cutTo()
    end
    if t ~= token then return end
    if opts.onShot then CreateThread(function() opts.onShot(i) end) end
    if level == 'full' and #points > 1 then
        launch(points, mv.ms, mv.ease, {})
        while t == token and move do Wait(50) end
        return
    end
    local stop = GetGameTimer() + (tonumber(mv.ms) or 0)
    while t == token and GetGameTimer() < stop do Wait(50) end
end

-- Film shots in a thread: a shot { ms, ease, keys } split at cut keys, or moves; opts { loop, dipMs, onShot, onDone, anchor }.
function Director.playList(list, opts)
    opts = type(opts) == 'table' and opts or {}
    local moves = type(list) == 'table' and (list.keys and CamMath.splitShots(list) or list) or {}
    if #moves == 0 then return false end
    cancel()
    listing = true
    local t = token
    CreateThread(function()
        local level, wrapped = Director.motion(), false
        repeat
            for i, mv in ipairs(moves) do
                if t ~= token then return end
                shot(mv, i, t, opts, level, wrapped)
                Wait(0)
            end
            wrapped = true
        until not opts.loop or t ~= token
        if t ~= token then return end
        listing = false
        if opts.onDone then opts.onDone() end
    end)
    return true
end

-- Idle sway { x, z, yaw, period } after moves settle (full motion only); false turns it off.
function Director.idle(cfg)
    sway = type(cfg) == 'table' and cfg or nil
    if sway and not move and Rig.active() then
        if not rest then rest, restAt, aim = Rig.pose(), GetGameTimer(), nil end
        wake()
    elseif not sway and rest and not move then
        Rig.set(rest)
    end
end

function Director.busy()
    return move ~= nil or listing
end

-- Stops moves, lists and sway; the camera stays where it is. A dip in progress leaves the screen to the caller.
function Director.stop()
    cancel()
    sway, rest, ownFade = nil, nil, false
    sleep()
end

local function drift(now)
    local p = CamMath.copy(rest)
    if sway and Director.motion() == 'full' then
        local ramp = math.min(1, (now - restAt) / RAMP_MS)
        local side, up, turn = CamMath.sway(sway, now / 1000, ramp)
        local rx, ry = CamMath.right(rest.rz)
        p.x, p.y, p.z, p.rz = rest.x + rx * side, rest.y + ry * side, rest.z + up, rest.rz + turn
    end
    -- The camera turns after the tracked point (slowly), so it stays where it sat when the camera came to rest.
    local target = track and track()
    if target then
        local pitch, yaw = CamMath.lookRot(p.x, p.y, p.z, target.x, target.y, target.z)
        if not aim then aim = { yaw = yaw - p.rz, pitch = pitch - p.rx, dz = 0.0, dx = 0.0 } end
        local wz = (yaw - aim.yaw - p.rz + 540.0) % 360.0 - 180.0
        local wx = pitch - aim.pitch - p.rx
        -- Gently, and not for small moves (a dancing or nodding head would rock the picture).
        local function ease(d, w) return math.abs(w - d) < 2.0 and d or d + (w - d) * 0.012 end
        aim.dz, aim.dx = ease(aim.dz, wz), ease(aim.dx, wx * 0.5)
        p.rz, p.rx = p.rz + aim.dz, p.rx + aim.dx
    end
    Rig.set(p)
end

-- The resting camera follows fn() (a world point) or stops following (nil).
function Director.track(fn)
    track, aim = fn, nil
    if fn and rest and Rig.active() then wake() end
end

-- Frame 'cam': one spline sample and one SetCamParams; sleeps when nothing moves.
function Director.update(now)
    now = type(now) == 'number' and now or GetGameTimer()
    if not Rig.active() then
        move, rest = nil, nil
        return sleep()
    end
    local m = move
    if m then
        local u = (now - m.t0) / m.ms
        if u >= 1 then
            Rig.set(m.points[#m.points])
            return settle(m.points[#m.points], m.onDone)
        end
        return Rig.set(CamMath.spline(m.points, m.shares, CamMath.ease(m.ease, u)))
    end
    if rest and ((sway and Director.motion() == 'full') or track) then return drift(now) end
    sleep()
end

-- Frames an actor into its box of the stage (Config.Theme.ActorBox): a medium shot from the head to the knees,
-- with the camera tried around the actor when a wall is in the way (the pause menu's charcam maths).
PedFrame = {}

local HEAD, CHEST, PELVIS, LKNEE, RKNEE, LFOOT, RFOOT = 31086, 24818, 11816, 63931, 36864, 14201, 52301
local YAWS = { 0, 25, -25, 50, -50, 75, -75, 100, -100 }
local MARGIN, MIN_REACH, FOV = 1.1, 1.2, 38.0
local GROUP_WIDEN = 520 -- stage pixels a group may take left of the actor box

local function boxOf(side)
    local boxes = (Config.Theme or {}).ActorBox or {}
    return boxes[side] or boxes.right or { x = 1040, y = 120, w = 700, h = 880 }
end

local function screen()
    local w, h = GetActualScreenResolution()
    return w, h, GetAspectRatio(false)
end

-- Ground position, heading, the top of the head and the knees, in world z.
local function body(ped)
    -- Where the body is seen (between the head and the hips), not the ped's root: a scene animation can carry them apart.
    local head = GetPedBoneCoords(ped, HEAD, 0.0, 0.0, 0.0)
    local hips = GetPedBoneCoords(ped, PELVIS, 0.0, 0.0, 0.0)
    local pos = (head + hips) / 2
    local l, r = GetPedBoneCoords(ped, LKNEE, 0.0, 0.0, 0.0), GetPedBoneCoords(ped, RKNEE, 0.0, 0.0, 0.0)
    local top, bottom = head.z + 0.14, math.min(l.z, r.z)
    if top - bottom < 0.6 then bottom = top - 1.3 end
    -- Standing: the picture is held between the chest and the waist, a little above the middle of the body.
    local centre = top - 0.58
    -- Sitting (the knees up near the hips): from the waist up, so the camera looks over a table, not under it.
    if top - bottom < 0.95 then -- seated or crouched: down to the feet at most, the camera at eye height looking a little down
        local lf, rf = GetPedBoneCoords(ped, LFOOT, 0.0, 0.0, 0.0), GetPedBoneCoords(ped, RFOOT, 0.0, 0.0, 0.0)
        bottom, centre = math.max(math.min(lf.z, rf.z), top - 1.25), top - 0.25
    end
    -- Leaning over (CPR, an engine): it faces where its head leans, whatever way its root turns.
    local lean = vector2(head.x - hips.x, head.y - hips.y)
    local h = #lean > 0.2 and math.deg(math.atan(-lean.x, lean.y)) or GetEntityHeading(ped)
    return { x = pos.x, y = pos.y, h = h, top = top, bottom = bottom, centre = centre }
end

-- The first point along the ground line from (x0, y0) to (x1, y1) inside one of the boxes { x, y, h, hw, hl }
-- (scene cars, known before they are made); its distance, or nil.
local function boxHit(boxes, x0, y0, x1, y1)
    local len = math.sqrt((x1 - x0) ^ 2 + (y1 - y0) ^ 2)
    for d = 0.3, len, 0.2 do
        local px, py = x0 + (x1 - x0) * d / len, y0 + (y1 - y0) * d / len
        for _, b in ipairs(boxes) do
            local r = math.rad(b.h)
            local dx, dy = px - b.x, py - b.y
            local lx, ly = dx * math.cos(r) + dy * math.sin(r), -dx * math.sin(r) + dy * math.cos(r)
            if math.abs(lx) < b.hw and math.abs(ly) < b.hl then return d end
        end
    end
    return nil
end

-- Free distance from the chest towards a camera spot, stopping short of what is in the way.
local function clearance(ped, chest, x, y, want, boxes)
    local probe = StartExpensiveSynchronousShapeTestLosProbe(chest.x, chest.y, chest.z, x, y, chest.z, 1 | 2, ped, 7) -- the map and cars (a car in front turns the camera to the side); props and people never push it in
    local _, hit, at = GetShapeTestResult(probe)
    local free, blocked = want, false
    if hit == 1 then free, blocked = math.min(want, #(at - chest) - 0.25), true end
    local d = boxes and boxHit(boxes, chest.x, chest.y, x, y)
    if d and d - 0.4 < free then free, blocked = d - 0.4, true end
    return free, blocked
end

-- The way round the body the camera looks from: the first clear one, or view (a world heading kept from an earlier
-- shot, so a reframe never swings the camera round).
local function aim(ped, chest, b, plan, boxes, view)
    local frame = { x = b.x, y = b.y, z = 0, h = b.h }
    local yaw, reach = 0, -1
    for _, deg in ipairs(view and { view - b.h } or YAWS) do
        local r = math.rad(deg)
        local x, y = CamMath.toWorld(frame, math.sin(r) * plan.dist, math.cos(r) * plan.dist, 0)
        local free, hit = clearance(ped, chest, x, y, plan.dist, boxes)
        if free > reach then yaw, reach = deg, free end
        if not hit or free >= plan.dist * 0.85 then break end
    end
    return yaw, reach
end

-- Closer than planned (a wall or a car in the way): a wider lens keeps the whole body in its box.
local function lens(fov, plan, reach)
    if reach >= plan.dist then return fov end
    return math.min(70.0, 2.0 * math.deg(math.atan(math.tan(math.rad(fov) / 2.0) * plan.dist / math.max(reach, 0.5))))
end

-- Camera pose for a ped in its ActorBox (side = a box name); zoom scales the fov at the same distance (near / wide).
function PedFrame.shot(ped, side, fov, zoom, boxes, view)
    if not ped or not DoesEntityExist(ped) then return nil end
    fov = tonumber(fov) or FOV
    local w, h, aspect = screen()
    local b = body(ped)
    local plan = Framing.plan(b, boxOf(side), w, h, aspect, fov, MARGIN)
    local chest = GetPedBoneCoords(ped, CHEST, 0.0, 0.0, 0.0)
    local yaw, reach = aim(ped, chest, b, plan, boxes, view)
    reach = math.max(reach, MIN_REACH)
    local pose = Framing.pose(b, plan, reach, yaw, lens(fov, plan, reach) * (tonumber(zoom) or 1))
    pose.view = b.h + yaw
    return pose
end

-- The same shot for an empty spot: a standing body on the ground point, no probes.
function PedFrame.at(pos, heading, side, fov, zoom)
    fov = tonumber(fov) or FOV
    local w, h, aspect = screen()
    local b = { x = pos.x, y = pos.y, h = heading or 0.0, top = pos.z + 1.79, bottom = pos.z + 0.5 }
    local plan = Framing.plan(b, boxOf(side), w, h, aspect, fov, MARGIN)
    return Framing.pose(b, plan, plan.dist, 0, fov * (tonumber(zoom) or 1))
end

-- A seated body on a floor point (the same box as a seated ped's bones give).
-- Heights over the floor of a low body (seated, crouched) and where the camera stands.
local LOW = { seat = { top = 1.34, bottom = 0.09, centre = 0.94 }, crouch = { top = 1.2, bottom = 0.1, centre = 1.05 } }

function PedFrame.seat(floor, heading, side, fov, zoom, kind, boxes, ped, view)
    fov = tonumber(fov) or FOV
    local k = LOW[kind] or LOW.seat
    local w, h, aspect = screen()
    local b = { x = floor.x, y = floor.y, h = heading or 0.0, top = floor.z + k.top, bottom = floor.z + k.bottom, centre = floor.z + k.centre }
    local plan = Framing.plan(b, boxOf(side), w, h, aspect, fov, MARGIN)
    local chest = vector3(floor.x, floor.y, b.centre)
    local yaw, reach = aim(ped or 0, chest, b, plan, boxes, view)
    reach = math.max(reach, MIN_REACH)
    local pose = Framing.pose(b, plan, reach, yaw, lens(fov, plan, reach) * (tonumber(zoom) or 1))
    pose.view = b.h + yaw
    return pose
end

-- Several peds in the box at once (the focused character with its partner or crew): their middle is the body, as
-- tall as the tallest, and the camera stands far enough back for their whole width (heading: the way they face).
function PedFrame.group(peds, heading, side, fov, zoom)
    fov = tonumber(fov) or FOV
    local w, h, aspect = screen()
    local r = math.rad(tonumber(heading) or 0.0)
    local rx, ry = math.cos(r), math.sin(r) -- the group's right hand
    local fx, fy = -ry, rx -- forward
    local first, n = nil, 0
    local minL, maxL, front, top, bottom = math.huge, -math.huge, -math.huge, -math.huge, math.huge
    for _, ped in ipairs(peds) do
        if DoesEntityExist(ped) then
            local b = body(ped)
            first = first or b
            local dx, dy = b.x - first.x, b.y - first.y
            local l = dx * rx + dy * ry
            minL, maxL, front = math.min(minL, l), math.max(maxL, l), math.max(front, dx * fx + dy * fy)
            top, bottom, n = math.max(top, b.top), math.min(bottom, b.bottom), n + 1
        end
    end
    if n == 0 then return nil end
    -- Measured from the front-most of them (the nearest to the camera), across the middle of their width.
    local mid = (minL + maxL) / 2
    local g = { x = first.x + rx * mid + fx * front, y = first.y + ry * mid + fy * front, h = heading, top = top, bottom = bottom }
    -- A group may spread left of the actor box, over the middle of the picture.
    local one = boxOf(side)
    local bx, by, bw, bh = one.x or one[1], one.y or one[2], one.w or one[3], one.h or one[4]
    local box = { x = math.max(80, bx - GROUP_WIDEN), y = by, w = bw + math.min(GROUP_WIDEN, bx - 80), h = bh }
    local plan = Framing.plan(g, box, w, h, aspect, fov, MARGIN)
    local need = (maxL - minL + 0.6) * MARGIN / (2 * math.tan(math.rad(fov) / 2) * aspect * (box.w / 1920))
    return Framing.pose(g, plan, math.max(plan.dist, need), 0, fov * (tonumber(zoom) or 1))
end

-- The product's one scripted camera: poses, depth of field with rack focus, motion blur and the hand back to gameplay.
Rig = {}

local cam, current = nil, nil
local dof, dofOn = nil, false
local focus = { from = 3.0, to = 3.0, t0 = 0, ms = 0 }

function Rig.active()
    return cam ~= nil and DoesCamExist(cam)
end

-- The camera handle, for steps that attach it to an entity (cutscene follow shots).
function Rig.handle()
    return Rig.active() and cam or nil
end

local function apply(p)
    SetCamParams(cam, p.x + 0.0, p.y + 0.0, p.z + 0.0, p.rx + 0.0, (p.ry or 0) + 0.0, p.rz + 0.0, p.fov + 0.0, 0, 1, 1, 2)
end

-- Starts rendering our camera at a pose or key; an existing camera just moves there.
function Rig.start(pose)
    pose = CamMath.pose(pose)
    if not pose then return false end
    if Rig.active() then return Rig.set(pose) end
    cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pose.x + 0.0, pose.y + 0.0, pose.z + 0.0, pose.rx + 0.0, pose.ry + 0.0, pose.rz + 0.0, pose.fov + 0.0, false, 2)
    pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
    SetCamNearClip(cam, 0.05)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
    current = CamMath.copy(pose)
    return true
end

-- One SetCamParams per call: Rig.set(pose) or Rig.set(x, y, z, rx, ry, rz, fov).
function Rig.set(x, y, z, rx, ry, rz, fov)
    if not Rig.active() then return false end
    local p = type(x) == 'table' and x or { x = x, y = y, z = z, rx = rx, ry = ry, rz = rz, fov = fov }
    current = p
    apply(p)
    return true
end

-- The pose on screen: ours, or the rendered game camera when we have none.
function Rig.pose()
    if Rig.active() and current then return CamMath.copy(current) end
    local pos, rot = GetFinalRenderedCamCoord(), GetFinalRenderedCamRot(2)
    return { x = pos.x, y = pos.y, z = pos.z, rx = rot.x, ry = rot.y, rz = rot.z, fov = GetFinalRenderedCamFov() }
end

-- Subject distance now: it glides from the old subject to the new one (rack focus).
local function subjectNow()
    if focus.ms <= 0 then return focus.to end
    local t = CamMath.ease('smooth', (GetGameTimer() - focus.t0) / focus.ms)
    return CamMath.lerp(focus.from, focus.to, t)
end

function Rig.subject(dist, ms)
    dist = tonumber(dist)
    if not dist then return end
    focus = { from = subjectNow(), to = dist, t0 = GetGameTimer(), ms = math.max(0, tonumber(ms) or 0) }
end

local function dofOff()
    if dofOn then
        dofOn = false
        Frame.off('dof')
    end
    if Rig.active() then
        SetCamUseShallowDofMode(cam, false)
        SetCamDofStrength(cam, 0.0)
    end
end

-- Shallow depth of field needs SetUseHiDof every frame; the sharp band follows the subject.
local function dofFrame()
    if not Rig.active() or not dof then return dofOff() end
    local d = subjectNow()
    SetUseHiDof()
    SetCamUseShallowDofMode(cam, true)
    SetCamNearDof(cam, math.max(0.05, d - (tonumber(dof.near) or 1.0)))
    SetCamFarDof(cam, d + (tonumber(dof.far) or 2.0))
    SetCamDofStrength(cam, (tonumber(dof.strength) or 0.8) + 0.0)
end

-- cfg = { near, far, strength } around the subject, or false.
function Rig.dof(cfg)
    dof = type(cfg) == 'table' and cfg or nil
    if not dof or not Rig.active() then return dofOff() end
    if not dofOn then
        dofOn = true
        Frame.on('dof', dofFrame)
    end
end

function Rig.blur(v)
    if Rig.active() then SetCamMotionBlurStrength(cam, (tonumber(v) or 0.0) + 0.0) end
end

-- Eases back to the gameplay camera over ms; the camera is destroyed once the blend is over.
function Rig.toGameplay(ms)
    ms = math.max(0, math.floor(tonumber(ms) or 0))
    dofOff()
    local c = cam
    cam, current, dof = nil, nil, nil
    if not c or not DoesCamExist(c) then return end
    RenderScriptCams(false, ms > 0, ms, true, false)
    if ms == 0 then return DestroyCam(c, false) end
    SetTimeout(ms + 100, function()
        if DoesCamExist(c) then pcall(function() exports['FeloxAC']:destroyCam(c) end) --[[FeloxAC:auto]] DestroyCam(c, false) end
    end)
end

-- Immediate cut back to the game camera.
function Rig.release()
    dofOff()
    local c = cam
    cam, current, dof = nil, nil, nil
    if not c then return end
    RenderScriptCams(false, false, 0, true, false)
    if DoesCamExist(c) then pcall(function() exports['FeloxAC']:destroyCam(c) end) --[[FeloxAC:auto]] DestroyCam(c, false) end
end
