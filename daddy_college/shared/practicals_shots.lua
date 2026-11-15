-- Camera shots at the stations, without natives (10-cpr-deney.md section 6): a shot looks at a named point from a
-- yaw (from the way the student faces: 0 behind them, 180 facing them), a pitch (negative looks down), a distance and
-- a field of view. Here: where such a camera stands, where a point lands on its screen, whether the points that
-- matter sit in the free part of the screen, and the turns the solver tries when the first pose is blocked.
PracticalShots = {}
local S = PracticalShots

-- The yaw and pitch offsets tried in order: the shot, turned 25 and 50 degrees either way, then 15 degrees steeper.
S.TRIES = { { 0, 0 }, { 25, 0 }, { -25, 0 }, { 50, 0 }, { -50, 0 }, { 0, -15 } }
S.TOP = -85.0 -- the last try looks down from above at this pitch

-- The camera of a shot looking along heading (the game's degrees) at pitch, dist from target. -> x, y, z
function S.pose(target, heading, pitch, dist)
    local h, p = math.rad(heading), math.rad(pitch)
    local fx, fy, fz = -math.sin(h) * math.cos(p), math.cos(h) * math.cos(p), math.sin(p)
    return target.x - fx * dist, target.y - fy * dist, target.z - fz * dist
end

-- The heading a shot looks along: the student's facing plus its yaw (mirrored when the student is on the other side).
function S.heading(facing, side, yaw) return (facing + (yaw or 0.0) * (side or 1)) % 360.0 end

-- Where point p lands on the screen of a camera at cam looking at look (0-1 across and down) and how deep it is;
-- nil behind the camera. fov is the game's vertical field of view, aspect the screen's width over height.
function S.project(cam, look, fov, aspect, p)
    local fx, fy, fz = look.x - cam.x, look.y - cam.y, look.z - cam.z
    local n = math.sqrt(fx * fx + fy * fy + fz * fz)
    if n < 1e-6 then return nil end
    fx, fy, fz = fx / n, fy / n, fz / n
    local rx, ry = fy, -fx
    local rn = math.sqrt(rx * rx + ry * ry)
    if rn < 1e-6 then return nil end
    rx, ry = rx / rn, ry / rn
    local ux, uy, uz = ry * fz, -rx * fz, rx * fy - ry * fx
    local dx, dy, dz = p.x - cam.x, p.y - cam.y, p.z - cam.z
    local depth = dx * fx + dy * fy + dz * fz
    if depth < 0.02 then return nil end
    local t = math.tan(math.rad(fov) / 2)
    return 0.5 + (dx * rx + dy * ry) / depth / (2 * t * aspect), 0.5 - (dx * ux + dy * uy + dz * uz) / depth / (2 * t), depth
end

-- Is a screen point in the free part: inside the edge margin and outside every panel { x0, y0, x1, y1 } (0-1).
function S.free(zone, x, y)
    local m = zone.edge or 0.08
    if x < m or x > 1 - m or y < m or y > 1 - m then return false end
    for _, r in ipairs(zone.panels or {}) do
        if x >= r.x0 and x <= r.x1 and y >= r.y0 and y <= r.y1 then return false end
    end
    return true
end

-- How many of the points the camera puts in the free part, and whether that is all of them.
function S.framed(points, cam, look, fov, aspect, zone)
    local inside = 0
    for _, p in ipairs(points) do
        local x, y = S.project(cam, look, fov, aspect, p)
        if x and S.free(zone, x, y) then inside = inside + 1 end
    end
    return inside == #points, inside
end

-- The field of view that frames all the points, from the shot's own up to widen degrees wider (5 at a time). -> fov | nil
function S.fit(points, cam, look, fov, aspect, zone, widen)
    for add = 0, widen or 10, 5 do
        if S.framed(points, cam, look, fov + add, aspect, zone) then return fov + add end
    end
    return nil
end
