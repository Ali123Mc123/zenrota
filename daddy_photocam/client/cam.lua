-- The camera itself: a quick look that circles the character, and a free camera that stays near it and never passes
-- through a wall, a floor or into another interior. Input moves a goal; the shown camera eases toward it every frame,
-- and opening and closing blend from and back to the game camera.
Cam = {}

local cam, mode, closing
local ped, frozen
local pos, pitch, yaw, roll, fov = vector3(0, 0, 0), 0.0, 0.0, 0.0, 50.0
local goal = { pitch = 0.0, yaw = 0.0, roll = 0.0, fov = 50.0, dist = 3.0 }
local dist, center = 3.0, nil
local vel, pull = vector3(0, 0, 0), vector3(0, 0, 0)
local dof = 0.0
local hiddenSince
local nextSight = 0

local PROBE = 1 | 16 -- world and objects
local ZERO = vector3(0, 0, 0)

local function head()
    return GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.0)
end

local function direction(p, y)
    local x, z = math.rad(p), math.rad(y)
    local c = math.abs(math.cos(x))
    return vector3(-math.sin(z) * c, math.cos(z) * c, math.sin(x))
end

-- Share of the way to the goal covered this frame, the same at any frame rate.
local function ease(dt, rate) return 1.0 - math.exp(-dt * rate) end

local function clampFov(value) return math.max(Config.Free.MinFov, math.min(Config.Free.MaxFov, value)) end

-- Where a ray from a to b first hits the world, or nil.
local function hit(a, b)
    local ray = StartExpensiveSynchronousShapeTestLosProbe(a.x, a.y, a.z, b.x, b.y, b.z, PROBE, ped, 7)
    local _, didHit, at = GetShapeTestResult(ray)
    return (didHit == 1 or didHit == true) and at or nil
end

-- Inside the same interior as the character (0 = outside) or the one the camera is already in, so it never
-- crosses into another building; overlapping interiors (custom maps) do not lock it in place.
local function sameRoom(at, from)
    local room = GetInteriorAtCoords(at.x, at.y, at.z)
    return room == GetInteriorFromEntity(ped) or (from ~= nil and room == GetInteriorAtCoords(from.x, from.y, from.z))
end

-- Keeps a point within the allowed distance of the character.
local function clamp(at)
    local base = GetEntityCoords(ped)
    local off = at - base
    local flat = vector3(off.x, off.y, 0.0)
    local d, max = #flat, Config.Free.MaxDistance
    if d > max then flat = flat * (max / d) end
    local z = math.max(-Config.Free.MaxHeight, math.min(Config.Free.MaxHeight, off.z))
    return base + vector3(flat.x, flat.y, z)
end

-- One step from a to b: refused if it would end in a wall or another room.
local function step(a, b)
    b = clamp(b)
    local move = b - a
    local len = #move
    if len < 0.0001 then return a end
    if hit(a, b + move / len * Config.Free.WallGap) or not sameRoom(b, a) then return nil end
    return b
end

-- Slides along a wall: the whole step, else each axis on its own.
local function move(a, b)
    local whole = step(a, b)
    if whole then return whole end
    local at = a
    for _, axis in ipairs({ vector3(b.x - a.x, 0, 0), vector3(0, b.y - a.y, 0), vector3(0, 0, b.z - a.z) }) do
        at = step(at, at + axis) or at
    end
    return at
end

local function apply()
    SetCamCoord(cam, pos.x, pos.y, pos.z)
    SetCamRot(cam, pitch, roll, yaw, 2)
    SetCamFov(cam, fov + 0.0)
    SetFocusPosAndVel(pos.x, pos.y, pos.z, 0.0, 0.0, 0.0)
end

-- The free camera starts where the game camera is, or as close as the walls allow.
local function startPose()
    local from, wanted = head(), GetGameplayCamCoord()
    local blocked = hit(from, wanted)
    local dir = wanted - from
    pos = blocked and (blocked - dir / math.max(#dir, 0.01) * Config.Free.WallGap) or wanted
    if not sameRoom(pos) then pos = from end
    local rot = GetGameplayCamRot(2)
    pitch, yaw = rot.x, rot.z
    goal.pitch, goal.yaw = pitch, yaw
    vel, pull = ZERO, ZERO
end

local function destroy(c)
    pcall(function() exports['FeloxAC']:destroyCam(c) end) --[[FeloxAC:auto]]
    DestroyCam(c, false)
end

function Cam.open(kind)
    if cam then return false end
    if closing then destroy(closing) closing = nil end -- the last camera was still blending back
    ped, mode = PlayerPedId(), kind
    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
    local rot = GetGameplayCamRot(2)
    roll, goal.roll, dof, hiddenSince = 0.0, 0.0, 0.0, nil
    fov = clampFov(GetGameplayCamFov())
    if kind == 'look' then
        -- From the game camera's own distance, so the look starts where the eye already is.
        center, pos = head(), GetGameplayCamCoord()
        dist = math.max(Config.Look.MinDistance, math.min(Config.Look.MaxDistance, #(pos - center)))
        goal.dist, goal.fov = dist, Config.Look.Fov
        pitch, yaw = rot.x, rot.z
        goal.pitch, goal.yaw = pitch, yaw
    else
        startPose()
        goal.fov = fov
        pull = direction(pitch, yaw) * -Config.Free.OpenPull -- drifts back a little: you can tell it opened
        if not IsPedInAnyVehicle(ped, false) then
            frozen = not IsEntityPositionFrozen(ped)
            FreezeEntityPosition(ped, true)
        end
    end
    apply()
    SetCamActive(cam, true)
    RenderScriptCams(true, true, Config.Blend.Open, true, true)
    return true
end

-- Blends back to the game camera; the old camera lives until the blend ends.
function Cam.close()
    if not cam then return end
    local old = cam
    cam, mode = nil, nil
    RenderScriptCams(false, true, Config.Blend.Close, true, true)
    ClearFocus()
    if frozen and DoesEntityExist(ped) then FreezeEntityPosition(ped, false) end
    frozen, closing = nil, old
    SetTimeout(Config.Blend.Close + 100, function()
        if closing == old then
            destroy(old)
            closing = nil
        end
    end)
end

function Cam.mode() return mode end

-- Mouse look: the axes of this frame turn the goal.
local function look(speed)
    speed = speed * math.max(0.03, math.min(1.0, goal.fov / 50.0)) -- zoomed in, the mouse turns finer
    goal.pitch = math.max(-89.0, math.min(89.0, goal.pitch - GetDisabledControlNormal(0, 2) * speed))
    goal.yaw = goal.yaw - GetDisabledControlNormal(0, 1) * speed
end

-- Rotation, zoom and tilt follow their goals.
local function follow(dt)
    local a = ease(dt, Config.Smooth.Look)
    pitch = pitch + (goal.pitch - pitch) * a
    yaw = yaw + (goal.yaw - yaw) * a
    local z = ease(dt, Config.Smooth.Zoom)
    fov = fov + (goal.fov - fov) * z
    roll = roll + (goal.roll - roll) * z
end

-- Hold V: circle the character, the wheel moves closer or further, walls pull the camera in at once.
local function tickLook(dt)
    look(Config.Free.LookSpeed)
    if IsDisabledControlPressed(0, 15) then goal.dist = goal.dist - 0.25 end
    if IsDisabledControlPressed(0, 14) then goal.dist = goal.dist + 0.25 end
    goal.dist = math.max(Config.Look.MinDistance, math.min(Config.Look.MaxDistance, goal.dist))
    follow(dt)
    center = center + (head() - center) * ease(dt, Config.Smooth.Move)
    local dir = direction(pitch, yaw)
    local want = goal.dist
    local blocked = hit(center, center - dir * (want + 0.2))
    if blocked then want = math.max(0.3, #(blocked - center) - 0.2) end
    dist = want < dist and want or dist + (want - dist) * ease(dt, Config.Smooth.Move)
    pos = center - dir * dist
    apply()
end

-- The character out of the camera's sight (round a corner) for a while: the camera comes back.
local function watchSight()
    if not Config.Free.ReturnWhenHidden or GetGameTimer() < nextSight then return end
    nextSight = GetGameTimer() + 200
    if hit(head(), pos) then
        hiddenSince = hiddenSince or GetGameTimer()
        if GetGameTimer() - hiddenSince > Config.Free.HiddenSeconds * 1000 then
            startPose()
            hiddenSince = nil
        end
    else
        hiddenSince = nil
    end
end

-- Free camera: WASD, E/Q up and down, Shift fast, Ctrl slow; it speeds up and slows down instead of jumping.
local function tickFree(dt, mouse)
    if mouse then look(Config.Free.LookSpeed) end
    follow(dt)
    local fwd = direction(pitch, yaw)
    local right = vector3(fwd.y, -fwd.x, 0.0)
    local speed = Config.Free.Speed
    if IsDisabledControlPressed(0, 21) then speed = speed * 3.0 elseif IsDisabledControlPressed(0, 36) then speed = speed * 0.3 end
    local go = ZERO
    if IsDisabledControlPressed(0, 32) then go = go + fwd end
    if IsDisabledControlPressed(0, 33) then go = go - fwd end
    if IsDisabledControlPressed(0, 34) then go = go - right end
    if IsDisabledControlPressed(0, 35) then go = go + right end
    if IsDisabledControlPressed(0, 38) then go = go + vector3(0, 0, 1) end
    if IsDisabledControlPressed(0, 44) then go = go - vector3(0, 0, 1) end
    local want = #go > 0 and go / #go * speed or ZERO
    vel = vel + (want - vel) * ease(dt, Config.Smooth.Move)
    local shift = vel * dt
    if #pull > 0.001 then
        local part = pull * ease(dt, Config.Smooth.Move * 0.5)
        pull, shift = pull - part, shift + part
    end
    if #shift > 0.0001 then
        local to = move(pos, pos + shift)
        if #(to - (pos + shift)) > 0.001 then vel, pull = (to - pos) / math.max(dt, 0.001), ZERO end -- a wall stops it
        pos = to
    end
    -- The character moved away (a lift, a ride, a push): the camera comes back instead of staying behind.
    local off = pos - GetEntityCoords(ped)
    if #vector3(off.x, off.y, 0.0) > Config.Free.MaxDistance + 1.0 or math.abs(off.z) > Config.Free.MaxHeight + 1.0 then startPose() end
    watchSight()
    apply()
    if dof > 0.0 then
        local d = #(pos - head())
        SetCamUseShallowDofMode(cam, true)
        SetCamNearDof(cam, math.max(0.1, d - 0.8))
        SetCamFarDof(cam, d + 0.8 + (1.0 - dof) * 12.0)
        SetCamDofStrength(cam, dof)
        SetUseHiDof()
    end
end

function Cam.tick(mouse)
    if not cam then return end
    local dt = math.min(GetFrameTime(), 0.1)
    if mode == 'look' then tickLook(dt) else tickFree(dt, mouse) end
end

-- The zoom moves by a share of the view, so a step stays even from wide angle down to the closest zoom.
function Cam.zoom(delta)
    goal.fov = clampFov(goal.fov * (1.0 + delta * 0.04))
    return goal.fov
end

function Cam.set(key, value)
    value = tonumber(value) or 0.0
    if key == 'fov' then goal.fov = clampFov(value)
    elseif key == 'roll' then goal.roll = math.max(-Config.Free.MaxRoll, math.min(Config.Free.MaxRoll, value))
    elseif key == 'dof' then
        dof = math.max(0.0, math.min(1.0, value))
        if cam and dof == 0.0 then SetCamUseShallowDofMode(cam, false) end
    end
end

function Cam.state()
    return { fov = goal.fov, roll = goal.roll, dof = dof, minFov = Config.Free.MinFov, maxFov = Config.Free.MaxFov, maxRoll = Config.Free.MaxRoll }
end

function Cam.roll(delta)
    Cam.set('roll', goal.roll + delta)
    return goal.roll
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if cam or closing then RenderScriptCams(false, false, 0, true, true) end
    if cam then destroy(cam) end
    if closing then destroy(closing) end
    ClearFocus()
    if frozen and DoesEntityExist(ped) then FreezeEntityPosition(ped, false) end
    cam, closing, mode = nil, nil, nil
end)
