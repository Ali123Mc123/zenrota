-- The camera: a scripted camera the player can walk with (the game's own phone camera freezes them in place). The back
-- lens sits just in front of the head and looks where the mouse looks (standing, the body turns to it); the front lens
-- is held out at arm's length at head height, turned back on the face (the head looks into it), and swings a little
-- around them with the mouse, on the side of the hand that holds it out. The back lens holds the phone up with GTA's
-- own photo pose (both hands, as before), the front lens in GTA's selfie pose. The wheel zooms with a real field of view, so the picture stays sharp: 0.6x to 5x
-- behind, a narrower range in front. Filters are the game's own timecycle looks (Config.Camera.Filters), so the kept
-- picture has them; the flash is a light in front of the lens for the moment of the shot. Portrait mode blurs what is
-- behind the subject (the game's depth of field, focused on what the lens points at). The HUD, the radar, the feed
-- and the player's own phone (for them only) are hidden while it is up; it will not open (and closes) while the
-- player ragdolls, swims, climbs, falls or is down. The page draws its controls over the view and takes
-- the picture (screenshot-basic), cut and made small by the page, sent as a latent upload. A video call uses the same
-- lenses without the controls (video mode: the phone stays up, the mouse stays on it).
local RESOURCE = GetCurrentResourceName()
local cfg = Config.Camera

Camera = { on = false, video = false }

local cam
local selfie = false
local gen = 0
local zoom = 1.0
local filter = 1
local flash = false
local depth = false         -- portrait mode
local focus = 3.0           -- portrait's focus distance, eased
local yaw, pitch = 0.0, 0.0 -- the front lens's swing around the player
local sweep                 -- Face ID in setup: the front lens swings round the face once { from, ms }
local smooth                -- the head's place, eased (walking would shake the lens)

local HEAD = 31086
local HANDS = { 28422, 60309 } -- the photo pose holds the phone up with both
local NEAR = 0.16              -- the back lens's least distance in front of the head
local reach, wall = NEAR, nil  -- where it sits now (eased), and a wall that keeps it closer
local BACK = { min = 0.6, max = 5.0, base = 55.0 }
local FRONT = { min = 0.75, max = 1.6, base = 62.0 }

local function tell(kind, extra)
    local msg = { action = 'camera', kind = kind }
    for k, v in pairs(extra or {}) do msg[k] = v end
    SendNUIMessage(msg)
end

-- A zoom factor as a field of view, the way a lens narrows.
local function fovOf(z, base)
    return math.deg(2 * math.atan(math.tan(math.rad(base / 2)) / z))
end

local function lens() return selfie and FRONT or BACK end

-- The filter's look: a timecycle modifier on the game's main slot (the only one with a strength; the extra slot is
-- other scripts', and SET_EXTRA_TIMECYCLE_MODIFIER_STRENGTH is really the moon's phase), or a screen effect. What was
-- on the main slot before (a drunk look, a weather script's) is kept and put back when the filter goes.
local current, saved, ours
local function applyFilter()
    if current and current.effect then AnimpostfxStop(current.effect) end
    current = nil
    local f = Camera.on and cfg.Filters[filter] or nil
    if f and f.timecycle then
        if saved == nil then
            local idx = GetTimecycleModifierIndex()
            saved = idx ~= -1 and GetTimecycleModifierNameByIndex and { name = GetTimecycleModifierNameByIndex(idx), strength = GetTimecycleModifierStrength and GetTimecycleModifierStrength() or 1.0 } or false
        end
        ClearTimecycleModifier()
        SetTimecycleModifier(f.timecycle)
        SetTimecycleModifierStrength(f.strength or 1.0)
        ours = GetTimecycleModifierIndex()
    elseif saved ~= nil then
        ClearTimecycleModifier()
        if saved and saved.name then
            SetTimecycleModifier(saved.name)
            SetTimecycleModifierStrength(saved.strength)
        end
        saved, ours = nil, nil
    end
    if f and f.effect then AnimpostfxPlay(f.effect, 0, true) end
    current = f
end

-- Portrait's depth of field: the face, in front (the values Qbox's own character preview uses at that distance);
-- behind, whatever the middle of the picture lands on, up to 25 m, eased so the focus breathes rather than jumps.
local function setDepth(on)
    depth = on == true
    if cam then SetCamUseShallowDofMode(cam, depth) end
end

local function dof(ped, frames)
    if not depth or not cam then return end
    SetUseHiDof()
    if selfie then
        SetCamNearDof(cam, 0.4)
        SetCamFarDof(cam, 1.8)
        SetCamDofStrength(cam, 0.7)
        return
    end
    if frames % 8 == 0 then
        local c = GetCamCoord(cam)
        local r = GetCamRot(cam, 2)
        local dir = vector3(-math.sin(math.rad(r.z)) * math.cos(math.rad(r.x)), math.cos(math.rad(r.z)) * math.cos(math.rad(r.x)), math.sin(math.rad(r.x)))
        local to = c + dir * 25.0
        local _, hit, at = GetShapeTestResult(StartExpensiveSynchronousShapeTestLosProbe(c.x, c.y, c.z, to.x, to.y, to.z, -1, ped, 7))
        local d = hit == 1 and #(at - c) or 8.0
        focus = focus + (math.max(0.6, d) - focus) * 0.5
    end
    SetCamNearDof(cam, math.max(0.3, focus * 0.7))
    SetCamFarDof(cam, focus * 1.35 + 0.6)
    SetCamDofStrength(cam, 0.9)
end

-- What stops the camera: the player can't hold a phone up like this.
local function unable(ped)
    return IsPedRagdoll(ped) or IsPedSwimming(ped) or IsPedClimbing(ped) or IsPedFalling(ped) or IsPedInParachuteFreeFall(ped)
        or IsPedInCover(ped, false) or IsEntityDead(ped) or IsPedBeingStunned(ped, 0) or IsPedInMeleeCombat(ped)
end

-- The hand follows the lens (client/pose.lua): the back lens holds the phone up in front, the front lens at arm's
-- length with the head looking into it.
local function pose()
    local ped = PlayerPedId()
    Pose.set('selfie', selfie)
    if selfie then TaskLookAtCoord(ped, GetCamCoord(cam), -1, 2048, 3) else TaskClearLookAt(ped) end
end

-- First person hides the player's own head from them, so a lens turned on the face would look through it: while the
-- camera is up the view is third person, and the player's own view comes back after.
local views
local function thirdPerson()
    views = { foot = GetFollowPedCamViewMode(), car = GetFollowVehicleCamViewMode() }
    if views.foot == 4 then SetFollowPedCamViewMode(1) end
    if views.car == 4 then SetFollowVehicleCamViewMode(1) end
end

local function ownView()
    if not views then return end
    if views.foot == 4 then SetFollowPedCamViewMode(4) end
    if views.car == 4 then SetFollowVehicleCamViewMode(4) end
    views = nil
end

local place

local function setSelfie(on)
    selfie = on
    zoom, yaw, pitch, smooth, focus = 1.0, 0.0, 0.0, nil, 3.0
    reach, wall = NEAR, nil
    if cam then
        -- PointCamAtCoord (selfie) locks the cam target until StopCamPointing is called; without it SetCamRot is ignored.
        if not selfie then StopCamPointing(cam) end
        SetCamFov(cam, fovOf(zoom, lens().base))
        place(PlayerPedId())
    end
    pose()
    tell('flip', { selfie = selfie })
    tell('zoom', { value = zoom })
end

-- Keys while the controls are up: left click or Enter take the picture, right click or Up turns the camera, Left and
-- Right change the mode, the wheel zooms, Z and X go through the filters, E the flash, R the self-timer, Q opens a code
-- the camera sees, holding Alt shows the cursor (for the page's buttons), Esc, Backspace or Down close it. The game's
-- attack, aim, melee, weapon wheel, view change, looking back, the car's weapons and radio, and pause stay off;
-- walking stays (running only with the back lens).
local OFF = { 0, 14, 15, 16, 17, 19, 20, 24, 25, 26, 37, 38, 44, 45, 47, 51, 58, 68, 69, 70, 73, 81, 82, 83, 84, 85, 91, 92, 99, 100, 106, 114, 140, 141, 142, 143, 199, 200, 257, 261, 262, 263, 264 }

local cursor = false

-- The back lens sits just past the hands that hold the phone up, so they stay out of the picture (on foot; in a car
-- the hands are on the wheel), and never beyond a wall the player stands against.
local function backReach(ped, dx, dy)
    local far = NEAR
    if not IsPedInAnyVehicle(ped, false) then
        for _, bone in ipairs(HANDS) do
            local p = GetPedBoneCoords(ped, bone, 0.0, 0.0, 0.0)
            far = math.max(far, (p.x - smooth.x) * dx + (p.y - smooth.y) * dy + 0.14)
        end
    end
    far = math.min(far, 0.6)
    if far > NEAR and GetFrameCount() % 6 == 0 then
        local z = smooth.z + 0.03
        local _, hit, at = GetShapeTestResult(StartExpensiveSynchronousShapeTestLosProbe(smooth.x, smooth.y, z, smooth.x + dx * 0.75, smooth.y + dy * 0.75, z, 19, ped, 7))
        wall = hit == 1 and math.max(NEAR, #(at - vector3(smooth.x, smooth.y, z)) - 0.12) or nil
    end
    reach = reach + (math.min(far, wall or far) - reach) * 0.3
    return reach
end

function place(ped)
    local head = GetPedBoneCoords(ped, HEAD, 0.0, 0.0, 0.0)
    smooth = smooth and (smooth + (head - smooth) * 0.35) or head
    if selfie then
        if sweep then
            local p = (GetGameTimer() - sweep.from) / sweep.ms
            if p >= 1.0 then
                sweep, yaw = nil, 0.0
            else
                yaw = math.sin(p * math.pi * 2) * 38.0
            end
        end
        local heading = math.rad(GetEntityHeading(ped) + yaw)
        local dist = 0.72 + (1.0 - zoom) * 0.25
        -- Out on the side of the right hand, which holds the phone out, so the picture comes from where the phone is.
        local side = 0.2
        local off = vector3(-math.sin(heading) * dist + math.cos(heading) * side, math.cos(heading) * dist + math.sin(heading) * side,
            0.04 + math.sin(math.rad(pitch)) * dist)
        SetCamCoord(cam, smooth.x + off.x, smooth.y + off.y, smooth.z + off.z)
        PointCamAtCoord(cam, smooth.x, smooth.y, smooth.z + 0.02)
    else
        local rot = GetGameplayCamRot(2)
        local h = math.rad(rot.z)
        local dx, dy = -math.sin(h), math.cos(h)
        local d = backReach(ped, dx, dy)
        SetCamCoord(cam, smooth.x + dx * d, smooth.y + dy * d, smooth.z + 0.03)
        SetCamRot(cam, rot.x, 0.0, rot.z, 2)
        -- Standing, the body turns to where the lens looks.
        if not IsPedInAnyVehicle(ped, false) and GetEntitySpeed(ped) < 0.3 then
            local diff = ((rot.z - GetEntityHeading(ped) + 540.0) % 360.0) - 180.0
            if math.abs(diff) > 25.0 then SetEntityHeading(ped, GetEntityHeading(ped) + diff * 0.08) end
        end
    end
end

local function loop(mine)
    CreateThread(function()
        local frames = 0
        while Camera.on and gen == mine do
            local ped = PlayerPedId()
            frames = frames + 1
            -- In front, the head keeps looking into the lens as it swings.
            if selfie and frames % 30 == 0 and cam then TaskLookAtCoord(ped, GetCamCoord(cam), -1, 2048, 3) end
            if not Camera.video and frames % 10 == 0 and unable(ped) then
                local wasVideo = Camera.video
                Camera.stop(true)
                if not wasVideo then
                    tell('closed')
                    PhoneUI.focus(true)
                end
                break
            end
            -- Another script took the main timecycle slot (a drunk look coming on): the filter goes back on top.
            if ours and frames % 30 == 0 and GetTimecycleModifierIndex() ~= ours then applyFilter() end
            HideHudAndRadarThisFrame()
            ThefeedHideThisFrame()
            HideHelpTextThisFrame()
            local prop = PhoneUI.propEntity and PhoneUI.propEntity()
            if prop and DoesEntityExist(prop) then SetEntityLocallyInvisible(prop) end
            DisableOnFootFirstPersonViewThisUpdate()
            DisableVehicleFirstPersonCamThisFrame()
            place(ped)
            dof(ped, frames)
            if not Camera.video then
                for _, control in ipairs(OFF) do DisableControlAction(0, control, true) end
                DisablePlayerFiring(PlayerId(), true)

                -- Hold Alt for the HUD cursor; keep it up while left mouse is held so quick clicks finish cleanly.
                local alt = IsDisabledControlPressed(0, 19) or IsControlPressed(0, 19) or (cursor and IsDisabledControlPressed(0, 24))
                if alt ~= cursor then
                    cursor = alt
                    if alt then SetCursorLocation(0.5, 0.5) end
                    PhoneUI.focus(alt)
                end

                if selfie then
                    DisableControlAction(0, 21, true)
                    DisableControlAction(0, 22, true)
                end
                if cursor or selfie then
                    DisableControlAction(0, 1, true)
                    DisableControlAction(0, 2, true)
                end
                if selfie and not cursor then
                    yaw = math.max(-50.0, math.min(50.0, yaw - GetDisabledControlNormal(0, 1) * 8.0))
                    pitch = math.max(-18.0, math.min(25.0, pitch - GetDisabledControlNormal(0, 2) * 6.0))
                end
                local l = lens()
                local z = zoom
                if not cursor then
                    if IsDisabledControlJustPressed(0, 15) then z = zoom * 1.12 elseif IsDisabledControlJustPressed(0, 14) then z = zoom / 1.12 end
                end
                z = math.max(l.min, math.min(l.max, z))
                if z ~= zoom then
                    zoom = z
                    tell('zoom', { value = math.floor(zoom * 10 + 0.5) / 10 })
                end
                SetCamFov(cam, GetCamFov(cam) + (fovOf(zoom, l.base) - GetCamFov(cam)) * 0.25)

                if cursor then
                    if IsDisabledControlJustPressed(0, 200) then
                        Camera.stop()
                        tell('closed')
                    end
                elseif IsDisabledControlJustPressed(0, 24) or IsControlJustPressed(0, 176) then
                    tell('shoot')
                elseif IsDisabledControlJustPressed(0, 25) or IsControlJustPressed(0, 172) then
                    setSelfie(not selfie)
                elseif IsControlJustPressed(0, 174) then
                    tell('mode', { dir = -1 })
                elseif IsControlJustPressed(0, 175) then
                    tell('mode', { dir = 1 })
                elseif IsDisabledControlJustPressed(0, 20) or IsDisabledControlJustPressed(0, 73) then
                    filter = (filter - 1 + (IsDisabledControlJustPressed(0, 20) and -1 or 1)) % #cfg.Filters + 1
                    applyFilter()
                    tell('filter', { id = cfg.Filters[filter].id })
                elseif IsDisabledControlJustPressed(0, 38) then
                    flash = not flash
                    tell('flash', { on = flash })
                elseif IsDisabledControlJustPressed(0, 45) then
                    tell('timer')
                elseif IsDisabledControlJustPressed(0, 44) then
                    tell('open')
                elseif IsDisabledControlJustPressed(0, 200) or IsControlJustPressed(0, 194) or IsControlJustPressed(0, 173) then
                    Camera.stop()
                    tell('closed')
                end
            end
            Wait(0)
        end
    end)
end

local function rig(withSelfie)
    thirdPerson()
    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
    smooth = nil
    reach, wall = NEAR, nil
    selfie = withSelfie == true
    zoom, yaw, pitch = 1.0, 0.0, 0.0
    place(PlayerPedId())
    SetCamFov(cam, fovOf(zoom, lens().base))
    RenderScriptCams(true, true, 250, true, true)
    if GetResourceState('wais-primehud') == 'started' then exports['wais-primehud']:showHud() end
    pose()
end

-- now: the resource is stopping, so nothing waits (a timer would never run).
local function unrig(now)
    applyFilter()
    depth = false
    if cam then
        -- Portrait's depth of field goes off before the blend back, and the camera goes once the blend is over: one
        -- destroyed mid-blend could leave the game's own view blurred.
        local old = cam
        cam = nil
        SetCamUseShallowDofMode(old, false)
        SetCamDofStrength(old, 0.0)
        RenderScriptCams(false, not now, 250, true, true)
        if GetResourceState('wais-primehud') == 'started' then exports['wais-primehud']:hideHud() end
        if now then
            pcall(function() exports['FeloxAC']:destroyCam(old) end) --[[FeloxAC:auto]]
            DestroyCam(old, false)
        else
            SetTimeout(400, function()
                if DoesCamExist(old) then pcall(function() exports['FeloxAC']:destroyCam(old) end) --[[FeloxAC:auto]] DestroyCam(old, false) end
            end)
        end
    end
    local ped = PlayerPedId()
    TaskClearLookAt(ped)
    ownView()
    if cursor then
        cursor = false
        PhoneUI.focus(false)
    end
end

-- mode 'shoot': the full-screen camera with its controls (the mouse aims); 'video': a video call's camera behind the
-- phone (the phone stays up with the cursor).
function Camera.start(withSelfie, mode)
    if Camera.on or not PhoneUI.open or (mode ~= 'video' and unable(PlayerPedId())) then return false end
    Camera.on, Camera.video, cursor = true, mode == 'video', false
    gen = gen + 1
    Pose.set({ camera = true, selfie = withSelfie == true or Camera.video })
    if not Camera.video then PhoneUI.focus(false) end
    rig(withSelfie or Camera.video)
    if not Camera.video then
        filter = 1
        applyFilter()
        tell('zoom', { value = 1.0 })
        tell('filter', { id = cfg.Filters[1] and cfg.Filters[1].id or 'natural' })
    end
    loop(gen)
    return true
end

-- quiet: the phone itself is closing (it says nothing back to the page).
function Camera.stop(quiet)
    if not Camera.on then return end
    local wasVideo = Camera.video
    Camera.on, Camera.video = false, false
    gen = gen + 1
    unrig()
    PhoneUI.setCamera(false)
    if not quiet and not wasVideo then PhoneUI.focus(true) end
end

RegisterNUICallback('phone:cameraOpen', function(data, cb)
    local ok = Camera.start(data.selfie == true, 'shoot')
    if ok then setDepth(data.mode == 'depth') end
    cb({ ok = ok })
end)

RegisterNUICallback('phone:cameraClose', function(_, cb)
    if not Camera.video then Camera.stop() end
    cb({ ok = true })
end)

-- The page's own buttons (with Alt held): flip, a filter by its place, zoom to a lens (0.5x, 1x, 2x, 3x); and the
-- mode the page moved to (portrait's depth of field).
RegisterNUICallback('phone:cameraSet', function(data, cb)
    cb({ ok = true })
    if not Camera.on or Camera.video then return end
    if data.mode then setDepth(data.mode == 'depth') end
    if data.flip then setSelfie(not selfie) end
    if data.filter then
        if data.filter == 'next' then filter = filter % #cfg.Filters + 1 end
        for i, f in ipairs(cfg.Filters) do
            if f.id == data.filter then filter = i end
        end
        applyFilter()
        tell('filter', { id = cfg.Filters[filter].id })
    end
    if tonumber(data.zoom) then
        local l = lens()
        zoom = math.max(l.min, math.min(l.max, tonumber(data.zoom)))
        tell('zoom', { value = zoom })
    end
    if data.flash ~= nil then flash = data.flash == true end
end)

-- A video call's camera: the front lens behind the phone (lib/video.ts reads the game's frame); flip turns it round.
RegisterNUICallback('phone:videoCam', function(data, cb)
    if data.on then
        if Camera.on and not Camera.video then Camera.stop(true) end
        cb({ ok = Camera.on and Camera.video or Camera.start(true, 'video') })
    else
        if Camera.video then Camera.stop(true) end
        cb({ ok = true })
    end
end)

-- Face ID in setup: the front lens held up to the face (as a video call's camera), swinging round it once while the
-- page draws the scan from the game's picture; off puts it away.
RegisterNUICallback('phone:faceScan', function(data, cb)
    if not data.on then
        sweep = nil
        if Camera.video then Camera.stop(true) end
        return cb({ ok = true })
    end
    if Camera.on and not Camera.video then Camera.stop(true) end
    local ok = (Camera.on and Camera.video) or Camera.start(true, 'video')
    if ok then
        if not selfie then setSelfie(true) end
        sweep = { from = GetGameTimer(), ms = math.floor(math.max(1500, math.min(8000, tonumber(data.ms) or 3600))) }
    end
    cb({ ok = ok == true })
end)

RegisterNUICallback('phone:videoFlip', function(_, cb)
    cb({ ok = true })
    if Camera.video then setSelfie(not selfie) end
end)

-- A picture of the game's frame; the page cuts it to the mode's shape. With the flash on, a light in front of the
-- lens for a moment first (the picture is taken in it). The callback answers once, whichever comes first. A small mark
-- in the top left corner, drawn until then, tells the page the frame is this one (lib/camera.ts unmark).
RegisterNUICallback('phone:capture', function(data, cb)
    if GetResourceState('screenshot-basic') ~= 'started' then return cb({ ok = false }) end
    local answered = false
    local function answer(result)
        if answered then return end
        answered = true
        cb(result)
    end
    CreateThread(function()
        while not answered do
            DrawRect(0.004, 0.006, 0.008, 0.012, 255, 0, 255, 255)
            Wait(0)
        end
    end)
    local function take()
        CreateThread(function()
            for _ = 1, 5 do Wait(0) end -- the game's copy runs a few frames behind
            exports['screenshot-basic']:requestScreenshot({ encoding = 'jpg', quality = 0.97 }, function(image)
                answer({ ok = type(image) == 'string', image = image })
            end)
        end)
    end
    if (flash or data.flash) and cam then
        CreateThread(function()
            local untilAt = GetGameTimer() + 380
            local shot = false
            while GetGameTimer() < untilAt do
                local c = GetCamCoord(cam)
                local r = GetCamRot(cam, 2)
                local dir = vector3(-math.sin(math.rad(r.z)) * math.cos(math.rad(r.x)), math.cos(math.rad(r.z)) * math.cos(math.rad(r.x)), math.sin(math.rad(r.x)))
                DrawSpotLight(c.x, c.y, c.z, dir.x, dir.y, dir.z, 255, 250, 240, 12.0, 6.0, 0.0, 40.0, 30.0)
                DrawLightWithRange(c.x + dir.x * 0.4, c.y + dir.y * 0.4, c.z + dir.z * 0.4, 255, 250, 240, 3.0, 2.0)
                if not shot and GetGameTimer() > untilAt - 260 then
                    shot = true
                    take()
                end
                Wait(0)
            end
        end)
    else
        take()
    end
    SetTimeout(6000, function() answer({ ok = false }) end)
end)

-- Where the player is (the street and the area), for a Campus Media post.
RegisterNUICallback('phone:place', function(_, cb)
    local c = GetEntityCoords(PlayerPedId())
    local s1 = GetStreetNameAtCoord(c.x, c.y, c.z)
    local zone = GetLabelText(GetNameOfZone(c.x, c.y, c.z))
    local street = GetStreetNameFromHashKey(s1)
    cb({ ok = true, place = (zone ~= 'NULL' and zone ~= '') and (street ~= '' and street .. ', ' .. zone or zone) or street })
end)

-- Uploads (a photo for the gallery, a scanned page, a picture for a contact or the profile, a voice clip): a latent
-- event at a gentle rate, answered by the server once it is kept. The page waits for the answer.
local uploads, useq = {}, 0

RegisterNUICallback('phone:upload', function(data, cb)
    if not PhoneUI.open or type(data) ~= 'table' or type(data.kind) ~= 'string' then return cb({ ok = false, error = 'validation' }) end
    useq = useq + 1
    local token = useq
    uploads[token] = cb
    TriggerLatentServerEvent(RESOURCE .. ':upload', 250000, token, data.kind, data.data or {})
    SetTimeout(30000, function()
        local pending = uploads[token]
        if pending then
            uploads[token] = nil
            pending({ ok = false, error = 'timeout' })
        end
    end)
end)

RegisterNetEvent(RESOURCE .. ':uploaded', function(token, result)
    local pending = uploads[token]
    if not pending then return end
    uploads[token] = nil
    pending(type(result) == 'table' and result or { ok = false, error = 'server_error' })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE or not Camera.on then return end
    -- Off first, so the filter and its timecycle go with it.
    Camera.on = false
    unrig(true)
end)
