-- The station camera (10-cpr-deney.md section 6): each step has its shot (config Kinds.*.Shots), solved once when it
-- comes in: a capsule from the target keeps it in front of walls, rays to the points that matter keep heads out of
-- the way, and those points must land in the part of the screen the page leaves free. A blocked shot turns 25 and 50
-- degrees, goes steeper, and last looks down from above. Shots ease into each other; the page's marks follow every
-- frame while they move. Which shot plays follows what the page is told (PC.state).
local PC = Core.PracticalClient
if not PC then return end

local cfg = PC.cfg
local C, S = cfg.Camera, PracticalShots
local active, token = nil, 0 -- the camera that renders, and the newest shot asked for

local function yes(v) return v == true or v == 1 end

local function gameOf(view) return PC.games[(cfg.Kinds[view.kind] or {}).game] end

-- The station's named points (its layout's own, see game.points) and the middle of its top.
local function pointsOf(view)
    local out = { centre = PC.on(view, vector3(0.0, 0.0, 0.0)) }
    local game = gameOf(view)
    if game and game.points then
        for _, p in ipairs(game.points(view)) do out[p.name] = p.at end
    end
    return out
end

-- The way the student faces at this station and their side (-1: the other side, the shots mirrored).
local function facingOf(view)
    local game = gameOf(view)
    if game and game.facing then
        local h, side = game.facing(view)
        if h then return h, side or 1 end
    end
    return GetEntityHeading(cache.ped), 1
end

-- Where the page covers the screen: what it said, else the kind's default.
local function panelsOf(view) return PC.panels or (C.Panels or {})[view.kind] or {} end

-- Started capsule tests from the target out to each camera point (the map and objects, not the station's body).
local function capsules(view, target, cams)
    local probes = {}
    for i, cam in ipairs(cams) do
        probes[i] = StartShapeTestCapsule(target.x, target.y, target.z, cam.x, cam.y, cam.z, C.Radius, 1 | 16, view.body or 0, 4)
    end
    local out, untilMs = {}, GetGameTimer() + 500
    repeat
        local waiting = false
        for i, probe in ipairs(probes) do
            if not out[i] then
                local status, hit, at = GetShapeTestResult(probe)
                if status == 1 then waiting = true
                else out[i] = { done = probe ~= 0 and status == 2, hit = yes(hit), at = at } end
            end
        end
        if waiting then Wait(0) end
    until not waiting or GetGameTimer() > untilMs
    return out
end

-- Does a ped (the student or anyone) stand between the camera and any of the points.
local function headInWay(cam, keys)
    for _, p in ipairs(keys) do
        local d = p - cam
        local to = cam + d * math.max(0.0, 1.0 - 0.03 / math.max(#d, 0.03))
        local ray = StartExpensiveSynchronousShapeTestLosProbe(cam.x, cam.y, cam.z, to.x, to.y, to.z, 1 | 8 | 16, 0, 7)
        local _, hit, _, _, entity = GetShapeTestResult(ray)
        if yes(hit) and entity and entity ~= 0 and GetEntityType(entity) == 1 then return true end
    end
    return false
end

-- A shot of this station solved here. -> { cam, look, fov, close, how, framed } | nil
function PC.solve(view, name)
    local shot = ((cfg.Kinds[view.kind] or {}).Shots or {})[name]
    if not shot or not view.frame then return nil end
    local pts = pointsOf(view)
    local look = (pts[shot.target] or pts.centre) + vector3(0.0, 0.0, shot.up or 0.0)
    local keys = {}
    for _, key in ipairs(shot.keys or {}) do if pts[key] then keys[#keys + 1] = pts[key] end end
    if #keys == 0 then keys[1] = look end
    local facing, side = facingOf(view)
    local zone, aspect = { edge = C.Edge, panels = panelsOf(view) }, GetAspectRatio(false)
    local heading = S.heading(facing, side, shot.yaw)
    -- every turn, each also pulled back a quarter (when only the framing fails), then from above
    local tries = {}
    for n, t in ipairs(S.TRIES) do
        for _, far in ipairs({ 1.0, 1.25 }) do
            local how = far > 1.0 and 'back' or (n == 1 and 'shot' or 'turned')
            tries[#tries + 1] = { how = how, h = heading + t[1], p = shot.pitch + t[2], d = shot.dist * far }
        end
    end
    tries[#tries + 1] = { how = 'top', h = heading, p = S.TOP, d = shot.dist }
    local cams = {}
    for i, t in ipairs(tries) do cams[i] = vector3(S.pose(look, t.h, t.p, t.d)) end
    local hits = capsules(view, look, cams)
    local best
    for i, t in ipairs(tries) do
        local cam, hit = cams[i], hits[i]
        if hit and hit.done and hit.hit and hit.at then cam = vector3(PracticalFrame.pullIn(look, cam, hit.at, C.Margin, 0.0)) end
        if hit and hit.done and #(cam - look) >= math.min(C.Nearest, t.d) and not headInWay(cam, keys) then
            local fov = S.fit(keys, cam, look, shot.fov, aspect, zone, C.Widen)
            local pose = { cam = cam, look = look, fov = fov or shot.fov + (C.Widen or 0.0), how = t.how, framed = fov ~= nil, keys = keys }
            if fov then return pose end
            local _, inside = S.framed(keys, cam, look, pose.fov, aspect, zone)
            if not best or inside > best.inside then best, pose.inside = pose, inside end
        end
    end
    if best then return best end
    -- nothing free: the kind's fixed camera, pulled in front of a wall like the rest
    local fixed, game = (cfg.Kinds[view.kind] or {}).Camera, gameOf(view)
    if not fixed then return nil end
    -- given in the game's own frame when it has one (the manikin's), else on the top
    local function place(v) return game and game.at and game.at(view, v) or PC.on(view, v) end
    local cam, at = place(fixed.on), place(fixed.look)
    local hit = capsules(view, at, { cam })[1]
    if hit and hit.hit and hit.at then cam = vector3(PracticalFrame.pullIn(at, cam, hit.at, C.Margin, 0.3)) end
    return { cam = cam, look = at, fov = fixed.Fov or shot.fov, how = 'fixed', framed = false, keys = keys, head = headInWay(cam, keys) }
end

-- The page's marks drawn again where the world points are now (while a shot moves).
local function follow(before, cam, ms)
    CreateThread(function()
        local untilMs = GetGameTimer() + ms + 100
        while GetGameTimer() < untilMs and active == cam do
            PC.reproject()
            Wait(0)
        end
        PC.reproject()
        if before and DoesCamExist(before) then pcall(function() exports['FeloxAC']:destroyCam(before) end) --[[FeloxAC:auto]] DestroyCam(before, false) end
    end)
end

-- Depth of field on a close shot, while it renders (Camera.Dof).
local function focus(cam, dist)
    SetCamUseShallowDofMode(cam, true)
    SetCamNearDof(cam, math.max(0.05, dist - 0.25))
    SetCamFarDof(cam, dist + 0.6)
    SetCamDofStrength(cam, 0.6)
    CreateThread(function()
        while active == cam do
            SetUseHiDof()
            Wait(0)
        end
    end)
end

-- Plays a shot of this station (eases in from the game camera the first time). Blocks while it solves.
function PC.shot(view, name)
    if not C.Enabled then return end
    token = token + 1
    local mine = token
    local pose = PC.solve(view, name)
    if not pose or mine ~= token then return end
    if PC.playing then PC.playing.shotName = name end
    local dist = #(pose.cam - pose.look)
    local cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pose.cam.x, pose.cam.y, pose.cam.z, 0.0, 0.0, 0.0, pose.fov, false, 2)
    pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
    PointCamAtCoord(cam, pose.look.x, pose.look.y, pose.look.z)
    if dist < C.Close then
        SetCamNearClip(cam, C.NearClip)
        if C.Dof then focus(cam, dist) end
    end
    local before = active
    active = cam
    if before and DoesCamExist(before) then
        SetCamActiveWithInterp(cam, before, C.MoveMs, 1, 1)
        follow(before, cam, C.MoveMs)
    else
        SetCamActive(cam, true)
        RenderScriptCams(true, true, C.EaseMs, true, false)
        if GetResourceState('wais-primehud') == 'started' then exports['wais-primehud']:showHud() end
        follow(nil, cam, C.EaseMs)
        Wait(C.EaseMs + 50)
    end
end

-- The first shot by its older name (callers from before the shots): the overview, whatever points it was given.
function PC.camera(view) return PC.shot(view, 'overview') end

-- Back to the game camera (the game ended, the resource stops).
function PC.cameraOff()
    token = token + 1
    PC.panels = nil
    if not active then return end
    local cam = active
    active = nil
    RenderScriptCams(false, true, C.EaseMs, true, false)
    if GetResourceState('wais-primehud') == 'started' then exports['wais-primehud']:hideHud() end
    pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]]
    DestroyCam(cam, false)
end

-- The page says where its panels cover the screen ({ x0, y0, x1, y1 } in 0-1), for the shots after it.
RegisterNUICallback('practicals:panels', function(data, cb)
    cb({ ok = true })
    local list = {}
    for _, r in ipairs(type(data) == 'table' and type(data.rects) == 'table' and data.rects or {}) do
        local x0, y0, x1, y1 = tonumber(r.x0), tonumber(r.y0), tonumber(r.x1), tonumber(r.y1)
        if x0 and y0 and x1 and y1 and #list < 8 then list[#list + 1] = { x0 = x0, y0 = y0, x1 = x1, y1 = y1 } end
    end
    if PC.playing then PC.panels = list end
end)

-- Director ----------------------------------------------------------------------------------------------------
-- The shot for what the page was told so far (s, merged) and just now (data); a second value holds it that long.

local DIRECT = {
    lab_mix = function(s, data)
        if s.result then return 'result' end
        if type(data.last) == 'table' and data.last.op then return 'result', C.ResultMs end
        if s.pouring then return 'pour' end
        if s.heating then return 'heat' end
        if s.stirring then return 'stir' end
        return 'overview'
    end,
    cpr = function(s)
        if s.result or s.phase == 'done' then return 'result' end
        if s.breathing or s.phase == 'breath' then return 'breath' end
        if s.phase == 'press' then return 'press' end
        return 'overview'
    end,
}

local decide

-- Looks again after ms (the hold over) unless a newer hold came first.
local function later(mine, ms)
    mine.directStamp = (mine.directStamp or 0) + 1
    local stamp = mine.directStamp
    mine.holdUntil = GetGameTimer() + ms
    SetTimeout(ms, function()
        if PC.playing ~= mine or mine.directStamp ~= stamp then return end
        mine.holdUntil = nil
        decide(mine, {})
    end)
end

function decide(mine, data, ended)
    local pick = DIRECT[mine.game and mine.game.game]
    if not pick or not active then return end
    local name, holdMs = pick(mine.seen, data)
    -- held: after a pour, heat or stir until its result comes (a second at most), and on that result
    if name == 'overview' and (mine.holdUntil or 0) > GetGameTimer() then return end
    if ended and name == 'overview' then return later(mine, 1000) end
    if holdMs then later(mine, holdMs) else mine.holdUntil = nil end
    if name ~= mine.shotName then
        mine.shotName = name
        CreateThread(function() PC.shot(mine.view, name) end)
    end
end

-- Every state the page gets passes here (main.lua PC.state, PC.open).
function PC.direct(data)
    local mine = PC.playing
    if not mine or type(data) ~= 'table' then return end
    local seen = mine.seen or {}
    mine.seen = seen
    local ended = (seen.pouring and data.pouring == false) or (seen.heating and data.heating == false) or (seen.stirring and data.stirring == false)
    for k, v in pairs(data) do seen[k] = v end
    decide(mine, data, ended and data.last == nil)
end
