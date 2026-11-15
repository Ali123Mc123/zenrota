-- The garage's camera engine: one scripted camera set every frame. Moves run along Catmull-Rom paths with an ease,
-- either in the world or round a car (as orbits, so the path never cuts through it). A path may start or end at the
-- game camera, read again every frame, so a scene leaves and hands back the game's own view without a seam. At rest
-- the camera can breathe: a slow, uncut sway of a few degrees. While it renders, the HUD and the controls rest.
-- A pose is { from, at, fov }: where the camera stands and the point it looks at; the rotation follows from the two.
Director = {}
local D = { cam = nil, pose = nil, move = nil, sway = 0.0, swayTo = 0.0, dof = 1.0 }

local EASE = {
    linear = function(t) return t end,
    smooth = function(t) return t * t * (3 - 2 * t) end,
    inOutSine = function(t) return -(math.cos(math.pi * t) - 1) / 2 end,
    outCubic = function(t) return 1 - (1 - t) ^ 3 end,
}

local function catmull(a, b, c, d, t)
    local t2, t3 = t * t, t * t * t
    return 0.5 * (2 * b + (c - a) * t + (2 * a - 5 * b + 4 * c - d) * t2 + (3 * b - a - 3 * c + d) * t3)
end

-- One channel at u through segment i; the ends get phantom points so the path starts and stops true.
local function channel(points, key, i, u)
    local p1, p2 = points[i][key], points[i + 1][key]
    local p0 = points[i - 1] and points[i - 1][key] or p1 * 2 - p2
    local p3 = points[i + 2] and points[i + 2][key] or p2 * 2 - p1
    if type(p1) == 'number' then return catmull(p0, p1, p2, p3, u) end
    return vector3(catmull(p0.x, p1.x, p2.x, p3.x, u), catmull(p0.y, p1.y, p2.y, p3.y, u), catmull(p0.z, p1.z, p2.z, p3.z, u))
end

-- The segment and its own progress at eased progress e: the segments share the time by how far they travel.
local function locate(shares, e)
    local start = 0
    for i, share in ipairs(shares) do
        if e <= start + share or i == #shares then return i, math.min(1, math.max(0, (e - start) / share)) end
        start = start + share
    end
end

local function weigh(points, length)
    local out, total = {}, 0
    for i = 2, #points do
        out[i - 1] = math.max(1e-3, length(points[i - 1], points[i]))
        total = total + out[i - 1]
    end
    for i = 1, #out do out[i] = out[i] / total end
    return out
end

-- The game camera ---------------------------------------------------------------------------------------------------------

local function forward(pitch, heading)
    local p, h = math.rad(pitch), math.rad(heading)
    return vector3(-math.sin(h) * math.cos(p), math.cos(h) * math.cos(p), math.sin(p))
end

-- Where the game camera is now (it keeps following the player while ours renders); it looks at a point as far ahead
-- as the player is from it.
function Director.game()
    local from, rot = GetGameplayCamCoord(), GetGameplayCamRot(2)
    local ped = GetEntityCoords(PlayerPedId())
    local reach = math.max(2.0, #(ped - from))
    return { from = from, at = from + forward(rot.x, rot.z) * reach, fov = GetGameplayCamFov() }
end

-- Turns the game camera (behind the player) to look the way a pose looks, so a move into it stays short.
function Director.aimGame(pose)
    if not pose then return end
    local d = pose.at - pose.from
    local heading = math.deg(math.atan(-d.x, d.y))
    local pitch = math.deg(math.atan(d.z, math.sqrt(d.x * d.x + d.y * d.y)))
    SetGameplayCamRelativeHeading((heading - GetEntityHeading(PlayerPedId()) + 540.0) % 360.0 - 180.0)
    SetGameplayCamRelativePitch(math.max(-20.0, math.min(10.0, pitch)), 1.0)
end

-- Orbits round an entity --------------------------------------------------------------------------------------------------
-- A spot in the entity's frame as distance, elevation and azimuth (0 at its nose, 90 its left side) round its middle.

local function middle(entity)
    local min, max = GetModelDimensions(GetEntityModel(entity))
    return vector3(0.0, (min.y + max.y) / 2, (min.z + max.z) / 2)
end

local function toOrbit(entity, pivot, pos)
    local p = GetOffsetFromEntityGivenWorldCoords(entity, pos.x, pos.y, pos.z) - pivot
    local flat = math.sqrt(p.x * p.x + p.y * p.y)
    return math.max(#p, 0.5), math.deg(math.atan(p.z, math.max(flat, 1e-3))), math.deg(math.atan(-p.x, p.y))
end

local function fromOrbit(entity, pivot, r, e, a)
    local er, ar = math.rad(e), math.rad(a)
    local flat = r * math.cos(er)
    local p = pivot + vector3(-flat * math.sin(ar), flat * math.cos(ar), r * math.sin(er))
    return GetOffsetFromEntityInWorldCoords(entity, p.x, p.y, p.z)
end

local function unwrap(prev, a)
    while a - prev > 180.0 do a = a - 360.0 end
    while a - prev < -180.0 do a = a + 360.0 end
    return a
end

-- A pose as the numbers an orbit path blends: log distance, elevation, azimuth (near the one before), the look point
-- in the entity's frame, fov.
local function orbitKey(entity, pivot, pose, prevA)
    local r, e, a = toOrbit(entity, pivot, pose.from)
    return { r = math.log(r), e = e, a = prevA and unwrap(prevA, a) or a, at = GetOffsetFromEntityGivenWorldCoords(entity, pose.at.x, pose.at.y, pose.at.z), fov = pose.fov }
end

-- The camera ----------------------------------------------------------------------------------------------------------

-- The breath: the camera sways round the point it looks at, a couple of degrees over 14 s, a few centimetres up and down.
local function breathe(p)
    if D.sway < 0.001 then return p end
    local t = GetGameTimer() / 1000.0
    local turn = math.rad(2.2 * math.sin(t * math.pi * 2 / 14.0)) * D.sway
    local lift = 0.05 * math.sin(t * math.pi * 2 / 9.0) * D.sway
    local d = p.from - p.at
    local c, s = math.cos(turn), math.sin(turn)
    return { from = p.at + vector3(d.x * c - d.y * s, d.x * s + d.y * c, d.z + lift), at = p.at, fov = p.fov }
end

-- The camera to a pose: pitch and heading from where it stands to what it looks at, depth of field around that point.
local function apply(p)
    D.pose = p
    p = breathe(p)
    local d = p.at - p.from
    local pitch = math.deg(math.atan(d.z, math.sqrt(d.x * d.x + d.y * d.y)))
    local heading = math.deg(math.atan(-d.x, d.y))
    SetCamParams(D.cam, p.from.x, p.from.y, p.from.z, pitch, 0.0, heading, p.fov + 0.0, 0, 1, 1, 2)
    if Config.Showroom.DepthOfField then
        local dist = #d
        SetCamUseShallowDofMode(D.cam, D.dof > 0.01)
        SetCamNearDof(D.cam, math.max(0.1, dist * 0.55))
        SetCamFarDof(D.cam, dist * 1.8)
        SetCamDofStrength(D.cam, 0.55 * D.dof)
    end
end

-- One frame: the move's sample (or the pose at rest, for the breath), the HUD and the controls resting.
local function update()
    local m = D.move
    D.sway = D.sway + (D.swayTo - D.sway) * math.min(1.0, GetFrameTime() * 1.2)
    if Config.Showroom.DepthOfField then SetUseHiDof() end
    HideHudAndRadarThisFrame()
    DisableAllControlActions(0)
    if not m then
        if D.pose then apply(D.pose) end
        return
    end
    local t = math.min(1.0, (GetGameTimer() - m.t0) / m.ms)
    local e = m.ease(t)
    D.dof = m.dof[1] + (m.dof[2] - m.dof[1]) * e
    -- A move round an entity that is gone ends where it is; what waits on it still runs.
    local pose = m.sample(e)
    if not pose then
        D.move = nil
        if m.onDone then m.onDone() end
        return
    end
    apply(pose)
    if t >= 1 then
        D.move = nil
        if m.onDone then m.onDone() end
    end
end

-- A move over ms with sample(e) giving the pose at eased progress e; dof is the depth of field's strength at its start
-- and end (0 at the game camera, which has none).
local function run(sample, ms, ease, onDone, dof)
    -- A move of 0 ms is over at its first sample.
    D.move = { sample = sample, ms = math.max(1, ms), ease = EASE[ease] or EASE.smooth, t0 = GetGameTimer() - (ms <= 0 and 1 or 0), onDone = onDone, dof = dof or { D.dof, 1.0 } }
    if ms <= 0 then update() end
end

-- Starts rendering our camera at a pose (the game camera's own when none is given, so the switch cannot be seen).
function Director.start(pose)
    if not D.cam then
        D.cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', false)
        D.gen = (D.gen or 0) + 1
        local gen = D.gen
        CreateThread(function()
            while D.cam and gen == D.gen do
                update()
                Wait(0)
            end
        end)
    end
    D.move, D.sway, D.swayTo = nil, 0.0, 0.0
    D.dof = pose and 1.0 or 0.0
    apply(pose or Director.game())
    SetCamActive(D.cam, true)
    RenderScriptCams(true, false, 0, true, true)
    if GetResourceState('wais-primehud') == 'started' then exports['wais-primehud']:showHud() end
end

-- Back to the game camera over ms (0 cuts); the camera goes once the blend is over.
function Director.stop(ms)
    D.move = nil
    local cam = D.cam
    D.cam, D.pose = nil, nil
    if not cam then return end
    RenderScriptCams(false, (ms or 0) > 0, ms or 0, true, true)
    if GetResourceState('wais-primehud') == 'started' then exports['wais-primehud']:hideHud() end
    SetTimeout((ms or 0) + 50, function() if DoesCamExist(cam) then pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]] DestroyCam(cam, false) end end)
end

-- A hard cut: the picture changes in one frame.
function Director.cut(pose)
    D.move, D.dof = nil, 1.0
    if D.cam then apply(pose) end
end

-- From where the camera is to a pose (through mid poses, if given) over ms, in the world.
function Director.to(pose, ms, ease, onDone, mids)
    if not D.cam or not D.pose then return onDone and onDone() end
    local points = { D.pose }
    for _, p in ipairs(mids or {}) do points[#points + 1] = p end
    points[#points + 1] = pose
    local shares = weigh(points, function(a, b) return #(b.from - a.from) + 0.3 * #(b.at - a.at) + 0.02 * math.abs(b.fov - a.fov) end)
    run(function(e)
        local i, u = locate(shares, e)
        return { from = channel(points, 'from', i, u), at = channel(points, 'at', i, u), fov = channel(points, 'fov', i, u) }
    end, ms or 0, ease, onDone)
end

-- From where the camera is through poses round an entity, as orbits that follow it if it moves. The last pose may be
-- 'game': the game camera, read every frame, so the move ends exactly where it stands (then Director.stop cuts unseen).
-- A move that cannot start still runs onDone, so what waits on it never hangs.
function Director.around(entity, poses, ms, ease, onDone)
    if not D.cam or not D.pose or not DoesEntityExist(entity) then return onDone and onDone() end
    local pivot = middle(entity)
    local live = poses[#poses] == 'game'
    local keys = { orbitKey(entity, pivot, D.pose) }
    for i, pose in ipairs(poses) do
        if pose ~= 'game' or i < #poses then keys[#keys + 1] = orbitKey(entity, pivot, pose == 'game' and Director.game() or pose, keys[#keys].a) end
    end
    if live then keys[#keys + 1] = orbitKey(entity, pivot, Director.game(), keys[#keys].a) end
    local shares = weigh(keys, function(a, b) return math.abs(b.a - a.a) / 40.0 + math.abs(b.e - a.e) / 30.0 + math.abs(b.r - a.r) + #(b.at - a.at) * 0.3 end)
    run(function(e)
        if not DoesEntityExist(entity) then return nil end
        if live then keys[#keys] = orbitKey(entity, pivot, Director.game(), keys[#keys - 1].a) end
        local i, u = locate(shares, e)
        local at = channel(keys, 'at', i, u)
        local from = fromOrbit(entity, pivot, math.exp(channel(keys, 'r', i, u)), channel(keys, 'e', i, u), channel(keys, 'a', i, u))
        local pose = { from = from, at = GetOffsetFromEntityInWorldCoords(entity, at.x, at.y, at.z), fov = channel(keys, 'fov', i, u) }
        -- The last stretch lands on the game camera's own pose, not on a curve that only passes near it.
        if live and e > 0.97 then
            local g, w = Director.game(), (e - 0.97) / 0.03
            pose = { from = pose.from + (g.from - pose.from) * w, at = pose.at + (g.at - pose.at) * w, fov = pose.fov + (g.fov - pose.fov) * w }
        end
        return pose
    end, ms or 0, ease, onDone, { D.dof, live and 0.0 or 1.0 })
end

-- From where the camera is to the game camera over ms, in the world (when there is no car to go round), on a low arc
-- of lift metres so it passes over the player rather than through them.
function Director.toGame(ms, ease, onDone, lift)
    if not D.cam or not D.pose then return onDone and onDone() end
    local start = D.pose
    run(function(e)
        local g = Director.game()
        local up = vector3(0.0, 0.0, math.sin(math.pi * e) * (lift or 0.0))
        return { from = start.from + (g.from - start.from) * e + up, at = start.at + (g.at - start.at) * e, fov = start.fov + (g.fov - start.fov) * e }
    end, ms or 0, ease, onDone, { D.dof, 0.0 })
end

-- Stops a move where the camera is.
function Director.hold()
    D.move = nil
end

-- The breath on or off; it eases in and out over a second or two, never with a jump.
function Director.drift(on)
    D.swayTo = on and 1.0 or 0.0
end

function Director.pose() return D.pose end

function Director.moving() return D.move ~= nil end

function Director.active() return D.cam ~= nil end
