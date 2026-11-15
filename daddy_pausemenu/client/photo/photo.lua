-- Photo mode: the player's own camera around their character (free or orbiting), framings, lenses, hand shake,
-- poses and filters. The page shows the design's panel; this side owns the camera and checks every value.
local RESOURCE = GetCurrentResourceName()
local P = PMShared.Photo
local cfg = Config.Photo or {}
local freecam = DL.freecam
local t = DL.locale.t

local HEAD = 31086
local MIN_FOV, MAX_FOV = P.vfov(135) - 0.05, P.vfov(24) + 0.05
local LIMITS = { minFov = MIN_FOV, maxFov = MAX_FOV }
-- Free camera options, one table for every frame (DL.freecam.step only reads it): speeds are set before each step.
local STEP = { moveSpeed = 0.0, fast = 3.0, slow = 0.25, lookSpeed = 0.0, minFov = MIN_FOV, maxFov = MAX_FOV }
local MAX_DIST = (cfg.MaxDistance or 8.0) + 0.0
local MAX_MS = (cfg.MaxSeconds or 300) * 1000
local SPEED = (cfg.Speed or 1.5) + 0.0
local LOOK = (cfg.LookSpeed or 8.0) + 0.0
local APERTURE = (cfg.Aperture or 2.8) + 0.0
local DOF_STRENGTH = math.max(0.2, 1.0 - (APERTURE - 1.4) / 16.0)
local ZOOM = 1.08 -- one wheel notch
-- Framing positions tried around the ped (degrees off its front) when a wall is in the way.
local YAWS = { 0, 35, -35, 70, -70, 180 }

local S = P.defaults() -- the player's choices; kept between visits (the pose starts over)
local run = { on = false }
local session, lastHit = 0, -600000

local function round1(n)
    return math.floor(n * 10 + 0.5) / 10
end

local function poseAnim(i)
    local id = P.POSES[i + 1]
    return (cfg.Poses or {})[id] or P.POSE_ANIMS[id]
end

local function filterMod(i)
    local id = P.FILTERS[i + 1]
    return (cfg.Filters or {})[id] or P.FILTER_MODS[id]
end

-- Why photo mode may not run now (nil when it may): down, cuffed, in a moving car, falling, or just hurt.
local function denied(ped)
    local st = LocalPlayer.state
    if IsEntityDead(ped) or IsPedDeadOrDying(ped, true) or st.isDead or st.laststand then return 'dead' end
    if IsPedCuffed(ped) or st.isCuffed or st.handcuffed then return 'cuffed' end
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 and GetEntitySpeed(veh) > (cfg.MaxVehicleSpeed or 1.0) then return 'vehicle' end
    if IsPedRagdoll(ped) or IsPedFalling(ped) or IsPedSwimming(ped) or IsPedClimbing(ped) then return 'busy' end
    if GetGameTimer() - lastHit < (cfg.DamageCooldown or 30) * 1000 then return 'damaged' end
end

-- The camera stays within reach of the player's head, never sees through a wall from it, and stays off the ground.
local lastHead, lastPos, lastClamped
local function clampPos(ped, pos)
    local head = GetPedBoneCoords(ped, HEAD, 0.0, 0.0, 0.0)
    if lastClamped and lastHead and lastPos and #(head - lastHead) < 0.005 and #(pos - lastPos) < 0.005 then
        return lastClamped
    end
    lastHead, lastPos = head, pos
    local d = pos - head
    local len = #d
    if len < 0.01 then
        lastClamped = pos
        return pos
    end
    if len > MAX_DIST then pos = head + d * (MAX_DIST / len) end
    local probe = StartExpensiveSynchronousShapeTestLosProbe(head.x, head.y, head.z, pos.x, pos.y, pos.z, 17, ped, 7)
    local _, hit, hitPos = GetShapeTestResult(probe)
    if hit == 1 then pos = hitPos - d * (0.25 / len) end
    local ok, ground = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z + 0.5, false)
    if ok and ground > pos.z - 0.15 and ground < pos.z + 0.5 then pos = vector3(pos.x, pos.y, ground + 0.15) end
    lastClamped = pos
    return pos
end

-- The aim point of the selected framing: lock-on and orbit look at it, the distance is measured to it.
local function target(ped)
    local f = P.FRAMINGS[S.fr + 1]
    local b = GetPedBoneCoords(ped, f.bone, 0.0, 0.0, 0.0)
    return vector3(b.x, b.y, b.z + f.aimZ)
end

-- The selected framing in front of the player, or around them when a wall is in the way.
local function presetPose(ped)
    local f = P.FRAMINGS[S.fr + 1]
    local aim = target(ped)
    local flat = math.sqrt(math.max(0.01, f.dist * f.dist - f.camZ * f.camZ))
    local fwd = GetEntityForwardVector(ped)
    local best, bestGap
    for _, deg in ipairs(YAWS) do
        local r = math.rad(deg)
        local dir = vector3(fwd.x * math.cos(r) - fwd.y * math.sin(r), fwd.x * math.sin(r) + fwd.y * math.cos(r), 0.0)
        local want = aim + dir * flat + vector3(0.0, 0.0, f.camZ)
        local pos = clampPos(ped, want)
        local gap = #(pos - want)
        if not best or gap < bestGap then best, bestGap = pos, gap end
        if gap < 0.05 then break end
    end
    return best, CharCam.RotTo(best, aim)
end

-- Eased move of the camera to a pose (framings, entering photo mode); input waits until it lands.
local function fly(pos, rot, ms)
    local from = freecam.pose()
    if from then run.flight = { from = from, pos = pos, rot = rot, t0 = GetGameTimer(), ms = ms } end
    run.orbit = nil
end

local function flightStep()
    local f = run.flight
    local k = math.min(1.0, (GetGameTimer() - f.t0) / f.ms)
    local e = k < 0.5 and 4 * k * k * k or 1 - (-2 * k + 2) ^ 3 / 2
    local a, b = f.from.rotation, f.rot
    local yaw = a.z + ((b.z - a.z + 540.0) % 360.0 - 180.0) * e
    if k >= 1.0 then run.flight = nil end
    return f.from.coords + (f.pos - f.from.coords) * e, vector3(a.x + (b.x - a.x) * e, 0.0, yaw)
end

local function orbitFrom(pos, tgt)
    local d = pos - tgt
    local r = math.max(0.5, #d)
    run.orbit = { yaw = math.deg(math.atan(-d.x, d.y)), pitch = math.deg(math.asin(math.max(-1.0, math.min(1.0, d.z / r)))), r = r }
end

local function orbitPos(tgt)
    local o = run.orbit
    local y, p = math.rad(o.yaw), math.rad(o.pitch)
    return tgt + vector3(-math.sin(y) * math.cos(p), math.cos(y) * math.cos(p), math.sin(p)) * o.r
end

-- Mouse look needs the right button while the panel has the cursor; hidden or on a pad it is always on.
local function looking()
    return run.hidden or not IsUsingKeyboard(0) or IsDisabledControlPressed(0, 25) or IsDisabledControlPressed(0, 68)
end

local function applyShake()
    local c = run.cam
    if not c or not DoesCamExist(c) then return end
    local amp = P.shakeAmp(S.shake, cfg.ShakeScale)
    if amp <= 0 then StopCamShaking(c, true)
    elseif IsCamShaking(c) then SetCamShakeAmplitude(c, amp + 0.0)
    else ShakeCam(c, 'HAND_SHAKE', amp + 0.0) end
end

-- The look the player had before photo mode comes back when it ends.
local function saveTc()
    local idx = GetTimecycleModifierIndex()
    run.savedTc = idx ~= -1 and { GetTimecycleModifierNameByIndex(idx), GetTimecycleModifierStrength() } or false
end

local function restoreTc()
    if not run.tc then return end
    run.tc = false
    local saved = run.savedTc
    if saved and saved[1] and saved[1] ~= '' then
        SetTimecycleModifier(saved[1])
        SetTimecycleModifierStrength((saved[2] or 1.0) + 0.0)
    else
        ClearTimecycleModifier()
    end
end

local function setFilter(i)
    if i == 0 then
        restoreTc()
        return true
    end
    local mod = filterMod(i)
    if type(mod) ~= 'table' or type(mod[1]) ~= 'string' then return false, 'validation' end
    SetTimecycleModifier(mod[1])
    SetTimecycleModifierStrength((mod[2] or 1.0) + 0.0)
    run.tc = true
    return true
end

-- Only our own clip is stopped (never ClearPedTasks: cuffs and medical anims belong to others).
local function stopPose()
    local p = run.pose
    run.pose = nil
    if not p then return end
    local ped = PlayerPedId()
    if IsEntityPlayingAnim(ped, p[1], p[2], 3) then StopAnimTask(ped, p[1], p[2], 2.0) end
    RemoveAnimDict(p[1])
end

-- Plays pose i (0 = none). Answers true, false + error code, or nil when a newer choice took over meanwhile.
local function setPose(i)
    run.poseToken = (run.poseToken or 0) + 1
    local token, current = run.poseToken, run
    stopPose()
    if i == 0 then return true end
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, true) then return false, 'pose_vehicle' end
    local anim = poseAnim(i)
    if type(anim) ~= 'table' or type(anim[1]) ~= 'string' or type(anim[2]) ~= 'string' then return false, 'pose_failed' end
    RequestAnimDict(anim[1])
    local deadline = GetGameTimer() + 2000
    while not HasAnimDictLoaded(anim[1]) and GetGameTimer() < deadline do Wait(0) end
    if current ~= run or token ~= run.poseToken or not run.on then
        RemoveAnimDict(anim[1])
        return nil
    end
    if not HasAnimDictLoaded(anim[1]) then return false, 'pose_failed' end
    TaskPlayAnim(ped, anim[1], anim[2], 4.0, -4.0, -1, anim[3] or 1, 0.0, false, false, false)
    run.pose = anim
    return true
end

local function snapshot()
    local fov = run.fovTo or P.vfov(P.LENSES[S.foc + 1])
    return {
        fr = S.fr, mv = S.mv, lock = S.lock, spd = S.spd, foc = P.lensIndex(fov), shake = S.shake, pose = S.pose, filt = S.filt,
        fov = round1(fov), mm = round1(P.focal(fov)), dist = round1(run.dist or 0.0),
        hidden = run.hidden == true, hideAll = cfg.HideAll == true,
    }
end

-- Panel shown: KeepInput lets the camera move under the cursor (other resources' key bindings fire too, risk R3);
-- with Config.Photo.KeepInput off the page keeps the keyboard and the camera moves while the panel is hidden.
local PANEL_INPUT = cfg.KeepInput == false and 'ui' or 'keep'

-- Hidden: the page gives up focus and the game gets every input; H (read here) brings the panel back.
local function setHidden(on)
    run.hidden = on
    run.inputAt = GetGameTimer()
    if PM.IsOpen() then PM.SetInput(on and 'game' or PANEL_INPUT) end
end

local function apply(key, value)
    if key == 'pose' then
        local ok, err = setPose(value)
        if ok then S.pose = value end
        return ok, err
    end
    if key == 'filt' then
        local ok, err = setFilter(value)
        if ok then S.filt = value end
        return ok, err
    end
    S[key] = value
    if key == 'fr' then
        local pos, rot = presetPose(PlayerPedId())
        fly(pos, rot, 600)
    elseif key == 'mv' then
        run.orbit = nil
    elseif key == 'foc' then
        run.fovTo = P.vfov(P.LENSES[value + 1])
    elseif key == 'shake' then
        applyShake()
    end
    return true
end

-- One frame of camera control; returns an error code when photo mode has to end.
local function frame(ped, dt, now)
    if now >= run.checkAt then
        run.checkAt = now + 250
        local why = denied(ped) or (now - run.started > MAX_MS and 'time') or nil
        if why then return why end
    end
    if PM.Input() == 'game' and now - run.inputAt > 300 and IsDisabledControlJustPressed(0, 74) then
        setHidden(not run.hidden)
        PM.Send('pm:photo:state', { hidden = run.hidden })
    end
    local tgt = target(ped)
    local pos, rot
    if run.flight then
        pos, rot = flightStep()
    elseif S.mv == 1 then
        if not run.orbit then
            local pose = freecam.pose()
            if not pose then return 'unavailable' end -- the camera was taken from us (DestroyAllCams, freecam stopped)
            orbitFrom(pose.coords, tgt)
        end
        local o, k = run.orbit, P.speed(S.spd) * dt
        o.yaw = o.yaw + GetDisabledControlNormal(0, 30) * 60.0 * k
        o.r = math.max(0.5, math.min(MAX_DIST, o.r + GetDisabledControlNormal(0, 31) * 1.5 * k))
        o.pitch = o.pitch + ((IsDisabledControlPressed(0, 38) and 1.0 or 0.0) - (IsDisabledControlPressed(0, 44) and 1.0 or 0.0)) * 40.0 * k
        if looking() then
            local look = LOOK * run.fov / 50.0
            o.yaw = o.yaw - GetDisabledControlNormal(0, 1) * look
            o.pitch = o.pitch + GetDisabledControlNormal(0, 2) * look
        end
        o.pitch = math.max(-40.0, math.min(80.0, o.pitch))
        pos = orbitPos(tgt)
    else
        STEP.moveSpeed = SPEED * P.speed(S.spd) * dt
        STEP.lookSpeed = (looking() and S.lock ~= 1) and LOOK * run.fov / 50.0 or 0.0
        pos, rot = freecam.step(STEP)
        if not pos then return 'unavailable' end
    end
    pos = clampPos(ped, pos)
    if not run.flight and (S.lock == 1 or S.mv == 1) then rot = CharCam.RotTo(pos, tgt) end
    if not run.flight then
        if IsDisabledControlJustPressed(0, 241) then run.fovTo = math.max(MIN_FOV, run.fovTo / ZOOM) end
        if IsDisabledControlJustPressed(0, 242) then run.fovTo = math.min(MAX_FOV, run.fovTo * ZOOM) end
    end
    run.fov = run.fov + (run.fovTo - run.fov) * math.min(1.0, dt * 12.0)
    freecam.place(pos, rot, run.fov, LIMITS)
    run.dist = #(pos - tgt)
    -- Portrait depth of field while the camera looks at the player (lock-on or orbit).
    local c = run.cam
    if c and cfg.Dof ~= false then
        if S.lock == 1 or S.mv == 1 then
            local near, far = P.dofPlanes(run.dist, run.fov, APERTURE)
            SetUseHiDof()
            SetCamUseShallowDofMode(c, true)
            SetCamNearDof(c, near)
            SetCamFarDof(c, far)
            SetCamDofStrength(c, DOF_STRENGTH)
            run.dofOn = true
        elseif run.dofOn then
            SetCamUseShallowDofMode(c, false)
            SetCamDofStrength(c, 0.0)
            run.dofOn = false
        end
    end
    if cfg.HideOthers then
        if now >= (run.scanAt or 0) then
            run.scanAt = now + 250
            local nearby = {}
            for _, player in ipairs(GetActivePlayers()) do
                local other = GetPlayerPed(player)
                if other ~= ped and DoesEntityExist(other) and #(GetEntityCoords(other) - pos) < 15.0 then
                    nearby[#nearby + 1] = other
                end
            end
            run.nearby = nearby
        end
        for _, other in ipairs(run.nearby or {}) do
            if DoesEntityExist(other) then SetEntityLocallyInvisible(other) end
        end
    end
    if now >= run.pushAt then
        run.pushAt = now + 100
        local d, f = round1(run.dist), round1(run.fov)
        if d ~= run.sentDist or f ~= run.sentFov then
            run.sentDist, run.sentFov = d, f
            S.foc = P.lensIndex(run.fovTo)
            PM.Send('pm:photo:state', { dist = d, fov = f, mm = round1(P.focal(run.fov)), foc = S.foc })
        end
    end
end

-- Photo mode has to end (down, hurt, time is up): back to the home screen with the reason.
local function bounce(why)
    if not PM.IsOpen() or PM.Screen() ~= 'photo' then return end
    PM.Show('pause')
    PM.Toast(t('photo.errors.' .. why))
end

local function loop(id)
    Wait(0)
    -- DL.freecam keeps its handle to itself; the camera rendering now is it (shake and depth of field need it).
    local c = GetRenderingCam()
    if run.on and session == id and c ~= -1 and DoesCamExist(c) then
        run.cam = c
        PM.ClaimCam(c)
        applyShake()
    end
    while run.on and session == id do
        DisableAllControlActions(0)
        local why = frame(PlayerPedId(), GetFrameTime(), GetGameTimer())
        if why then return bounce(why) end
        Wait(0)
    end
end

local function start()
    local ped = PlayerPedId()
    local why = denied(ped)
    if why then return false, why end
    if freecam.active() then return false, 'unavailable' end
    -- From whatever is on screen now (the character camera mid-move included), so the cut is invisible.
    local handed = CharCam.Handoff()
    local fov = math.max(MIN_FOV, math.min(MAX_FOV, GetFinalRenderedCamFov()))
    local ok = freecam.start({
        coords = GetFinalRenderedCamCoord(), rotation = GetFinalRenderedCamRot(2), fov = fov,
        freezePed = not IsPedInAnyVehicle(ped, false), minFov = MIN_FOV, maxFov = MAX_FOV,
    })
    CharCam.Drop(handed)
    if not ok then return false, 'unavailable' end
    session = session + 1
    S.pose = 0
    local now = GetGameTimer()
    run = { on = true, started = now, inputAt = now, hidden = false, fov = fov, fovTo = P.vfov(P.LENSES[S.foc + 1]), dist = 0.0, pushAt = 0, checkAt = now + 250 }
    saveTc()
    if S.filt > 0 then setFilter(S.filt) end
    local pos, rot = presetPose(ped)
    fly(pos, rot, 700)
    PM.SetInput(PANEL_INPUT)
    PM.Send('pm:photo:state', snapshot())
    local id = session
    CreateThread(function() loop(id) end)
    return true
end

-- next: the screen we go to (the character camera takes over from our last view), nil when the menu closes.
local function stop(nextScreen)
    if not run.on then return end
    run.on = false
    session = session + 1
    local pose = freecam.pose()
    if run.cam then
        if DoesCamExist(run.cam) then StopCamShaking(run.cam, true) end
        PM.ReleaseCam(run.cam)
        run.cam = nil
    end
    stopPose()
    restoreTc()
    freecam.stop()
    if nextScreen then CharCam.SetScreen(nextScreen, pose) else CharCam.Stop(pose) end
    if PM.IsOpen() then PM.SetInput('ui') end
end

PM.RegisterScreen('photo', {
    enter = function()
        local ok, why = start()
        -- Not now: home with the reason, once the screen change that brought us here has finished.
        if not ok then SetTimeout(0, function() bounce(why) end) end
    end,
    leave = function(nextScreen) stop(nextScreen) end,
})

PM.Callback('pm:photo:set', function(data)
    local value = P.normalize(data.key, data.value)
    if not run.on or not value then return { ok = false, error = 'validation' } end
    local ok, err = apply(data.key, value)
    if ok == nil and not err then return { ok = true } end
    if not ok then return { ok = false, error = err } end
    return { ok = true, data = snapshot() }
end)

PM.Callback('pm:photo:reset', function()
    if not run.on then return { ok = false, error = 'validation' } end
    S = P.defaults()
    setPose(0)
    restoreTc()
    applyShake()
    run.fovTo = P.vfov(P.LENSES[S.foc + 1])
    local pos, rot = presetPose(PlayerPedId())
    fly(pos, rot, 600)
    setHidden(false)
    return { ok = true, data = snapshot() }
end)

PM.Callback('pm:photo:hide', function(data)
    if not run.on then return { ok = false, error = 'validation' } end
    setHidden(data.hidden == true)
    return { ok = true, data = { hidden = run.hidden } }
end)

-- Being hurt keeps photo mode shut for a while (no spectating a fight from a free camera).
AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' and args[1] == PlayerPedId() then lastHit = GetGameTimer() end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE then return end
    if run.on then stop(nil) end
    stopPose()
    restoreTc()
    CharCam.Shutdown()
end)
