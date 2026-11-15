-- Character camera (a pref, off by default): frames the player into the home screen's ped box. The other screens leave
-- the game camera alone; the sub screens blur the scene behind them (the game's screen blur).
CharCam = {}

local RESOURCE = GetCurrentResourceName()
local P = PMShared.Photo
local cfg = Config.CharCam or {}
local FOV = (cfg.Fov or 40.0) + 0.0
local SWITCH_MS, IN_MS, OUT_MS = cfg.SwitchMs or 400, cfg.EaseInMs or 650, cfg.EaseOutMs or 450
local BLUR_MS = (cfg.BlurMs or 400) + 0.0
local HEAD, CHEST, LFOOT, RFOOT = 31086, 24818, 14201, 52301
-- Camera positions tried around the ped (degrees off its front) when a wall is in the way.
local YAWS = { 0, 25, -25, 50, -50 }

local cam, framed = nil, nil
local running, session, blurred = false, 0, false
local mine = {}

local function track(c)
    mine[c] = true
    PM.ClaimCam(c)
    return c
end

local function forget(c)
    mine[c] = nil
    PM.ReleaseCam(c)
end

local function destroyLater(c, ms)
    SetTimeout(ms, function()
        if c == cam then return end
        if DoesCamExist(c) then pcall(function() exports['FeloxAC']:destroyCam(c) end) --[[FeloxAC:auto]] DestroyCam(c, false) end
        forget(c)
    end)
end

local function newCam(pos, rot, fov)
    return track(CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, rot.x, 0.0, rot.z, fov + 0.0, false, 2))
end

-- Pitch and heading (rotation order 2) that look from one point at another.
local function rotTo(from, to)
    local d = to - from
    return vector3(math.deg(math.atan(d.z, math.sqrt(d.x * d.x + d.y * d.y))), 0.0, math.deg(math.atan(-d.x, d.y)))
end
CharCam.RotTo = rotTo

local function blur(on)
    if on == blurred then return end
    blurred = on
    if on then TriggerScreenblurFadeIn(BLUR_MS) else TriggerScreenblurFadeOut(BLUR_MS) end
end

-- Coming back from a first-person view is a cut: easing would fly the camera into the head.
local function firstPerson()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then return GetFollowVehicleCamViewMode() == 4 end
    return GetFollowPedCamViewMode() == 4
end

local function canFrame()
    return false
end

-- Top of the head and the soles, in world z.
local function body(ped)
    local head = GetPedBoneCoords(ped, HEAD, 0.0, 0.0, 0.0)
    local l, r = GetPedBoneCoords(ped, LFOOT, 0.0, 0.0, 0.0), GetPedBoneCoords(ped, RFOOT, 0.0, 0.0, 0.0)
    local top, bottom = head.z + 0.14, math.min(l.z, r.z) - 0.1
    if top - bottom < 1.0 then bottom = top - 1.0 end
    return top, bottom
end

-- Camera pose that puts the whole ped into the stage box: distance from the box height, aim shifted so the ped
-- lands at the box centre (L = d * tan(hHalf) * (2s - 1)), walls tried around the ped.
local function shot(ped, box)
    local w, h = GetActualScreenResolution()
    local sx, sy, share = P.boxOnScreen(box, w, h)
    local top, bottom = body(ped)
    local want = P.fitDistance((top - bottom) * (cfg.Margin or 1.1), share, FOV)
    local chest = GetPedBoneCoords(ped, CHEST, 0.0, 0.0, 0.0)
    local yaw, reach = 0.0, -1.0
    for _, deg in ipairs(YAWS) do
        local r = math.rad(deg)
        local pos = GetOffsetFromEntityInWorldCoords(ped, math.sin(r) * want, math.cos(r) * want, 0.0)
        local probe = StartExpensiveSynchronousShapeTestLosProbe(chest.x, chest.y, chest.z, pos.x, pos.y, chest.z, 17, ped, 7)
        local _, hit, hitPos = GetShapeTestResult(probe)
        local free = hit == 1 and math.min(want, #(hitPos - chest) - 0.25) or want
        if free > reach then yaw, reach = r, free end
        if hit ~= 1 then break end
    end
    if reach < (cfg.MinDistance or 1.4) then return nil end
    local centre = (top + bottom) / 2
    local at = GetOffsetFromEntityInWorldCoords(ped, math.sin(yaw) * reach, math.cos(yaw) * reach, 0.0)
    local pos = vector3(at.x, at.y, centre + (cfg.Height or 0.0))
    local side = P.shift(reach, FOV, GetAspectRatio(false), sx)
    local aimAt = GetOffsetFromEntityInWorldCoords(ped, side * math.cos(yaw), -side * math.sin(yaw), 0.0)
    local aim = vector3(aimAt.x, aimAt.y, centre - reach * math.tan(math.rad(FOV) / 2) * (1 - 2 * sy))
    return pos, rotTo(pos, aim)
end

local function loop(id)
    local hideOthers = cfg.HideOthers == true
    local nearby, scanAt = {}, 0
    while running and session == id do
        local ped = PlayerPedId()
        -- No fidgeting while posing for the menu.
        SetPedCanPlayAmbientIdles(ped, true, false)
        if hideOthers then
            local now = GetGameTimer()
            if now >= scanAt then
                scanAt = now + 250
                nearby = {}
                local here = GetEntityCoords(ped)
                for _, player in ipairs(GetActivePlayers()) do
                    local other = GetPlayerPed(player)
                    if other ~= ped and DoesEntityExist(other) and #(GetEntityCoords(other) - here) < 6.0 then
                        nearby[#nearby + 1] = other
                    end
                end
            end
            for _, other in ipairs(nearby) do
                if DoesEntityExist(other) then SetEntityLocallyInvisible(other) end
            end
            Wait(0)
        else
            Wait(250)
        end
    end
end

-- The backdrop of a screen: the sub screens blur the scene behind them (Background Blur pref).
local function backdrop(screen)
    blur(P.SUB[screen] == true and (PM.prefs or {}).blur == 1)
end

-- Our camera goes and the game camera comes back (eased unless first person); the blur is left as it is.
-- from = { coords, rotation, fov }: ease out from that pose (photo mode's last view).
local function release(from)
    running, framed = false, nil
    session = session + 1
    local c = cam
    cam = nil
    if not c and from then
        c = newCam(from.coords, from.rotation, from.fov)
        SetCamActive(c, true)
        RenderScriptCams(true, false, 0, true, false)
    end
    if not c then return end
    local cut = firstPerson()
    local function out()
        RenderScriptCams(false, not cut, cut and 0 or OUT_MS, true, false)
        destroyLater(c, OUT_MS + 100)
    end
    -- A camera made this frame has to show once before the game can ease away from it.
    if from then CreateThread(function() Wait(0) out() end) else out() end
end

-- Frames the ped for a menu screen. from = { coords, rotation, fov }: start there (photo mode handing back).
function CharCam.SetScreen(screen, from)
    if screen == 'photo' then
        -- Photo mode owns the camera there, and the design has no blur on it.
        blur(false)
        return
    end
    local ped = PlayerPedId()
    if running and cam and framed == screen and canFrame(ped, true) then return backdrop(screen) end
    local box = P.box(screen)
    local pos, rot
    if box and canFrame(ped, from ~= nil) then pos, rot = shot(ped, box) end
    if not pos then
        release(from)
        return backdrop(screen)
    end
    local new = newCam(pos, rot, FOV)
    if cam then
        SetCamActiveWithInterp(new, cam, SWITCH_MS, 1, 1)
        destroyLater(cam, SWITCH_MS + 100)
    elseif from then
        local start = newCam(from.coords, from.rotation, from.fov)
        SetCamActive(start, true)
        RenderScriptCams(true, false, 0, true, false)
        SetCamActiveWithInterp(new, start, SWITCH_MS, 1, 1)
        destroyLater(start, SWITCH_MS + 100)
    else
        SetCamActive(new, true)
        RenderScriptCams(true, true, IN_MS, true, false)
    end
    cam, framed = new, screen
    backdrop(screen)
    if not running then
        running, session = true, session + 1
        local id = session
        CreateThread(function() loop(id) end)
    end
end

-- Back to the game camera without blur (menu closed). from: ease out from that pose (photo mode's last view).
function CharCam.Stop(from)
    blur(false)
    release(from)
end

-- Photo mode takes the running camera over (it starts from the rendered view); returns the handle to drop.
function CharCam.Handoff()
    blur(false)
    if not running or not cam then return nil end
    running, framed = false, nil
    session = session + 1
    local c = cam
    cam = nil
    return c
end

function CharCam.Drop(c)
    if c then destroyLater(c, 0) end
end

function CharCam.Running()
    return running and cam ~= nil
end

-- Prefs changed (char cam or blur toggled in Settings > Pause Menu): the open screen follows at once.
function CharCam.Refresh()
    local screen = PM.IsOpen() and PM.Screen()
    if not screen then return end
    CharCam.SetScreen(screen)
end

-- Hard cleanup (resource stop): every camera we made goes, the game camera comes back at once.
function CharCam.Shutdown()
    local active = false
    for c in pairs(mine) do
        if DoesCamExist(c) then
            active = active or IsCamActive(c)
            pcall(function() exports['FeloxAC']:destroyCam(c) end) --[[FeloxAC:auto]]
            DestroyCam(c, false)
        end
        PM.ReleaseCam(c)
    end
    mine, cam, framed, running = {}, nil, nil, false
    session = session + 1
    if active then RenderScriptCams(false, false, 0, true, false) end
    if blurred then
        blurred = false
        TriggerScreenblurFadeOut(0.0)
    end
end

PM.OnScreen(function(screen)
    if screen then CharCam.SetScreen(screen) else CharCam.Stop() end
end)

PM.OnPrefs(function() CharCam.Refresh() end)

AddEventHandler('onResourceStop', function(resource)
    if resource == RESOURCE then CharCam.Shutdown() end
end)
