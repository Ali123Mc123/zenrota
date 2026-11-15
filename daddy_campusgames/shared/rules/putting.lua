-- Mini golf, with no game natives: a ball rolling on a flat green, slowed by the grass, bouncing off walls and
-- obstacles, dropping into the cup when slow enough. The same input always gives the same path, so the server
-- runs it once and every client plays the path back.
GameRules = GameRules or {}
local Putting = {}
GameRules.putting = Putting

local G = 9.81
local DT = 1 / 240        -- small steps: a ball at full speed moves less than its radius per step
local SAMPLE = 12          -- a path point every 12 steps (50 ms)

local function len(x, y) return math.sqrt(x * x + y * y) end

-- The point of segment a-b nearest to p.
local function nearest(ax, ay, bx, by, px, py)
    local dx, dy = bx - ax, by - ay
    local l2 = dx * dx + dy * dy
    local t = l2 > 0 and math.max(0, math.min(1, ((px - ax) * dx + (py - ay) * dy) / l2)) or 0
    return ax + t * dx, ay + t * dy
end

local function inside(points, x, y)
    local hit, j = false, #points
    for i = 1, #points do
        local a, b = points[i], points[j]
        if (a.y > y) ~= (b.y > y) and x < (b.x - a.x) * (y - a.y) / (b.y - a.y) + a.x then hit = not hit end
        j = i
    end
    return hit
end

-- Bounce off a point (wall or obstacle edge) the ball overlaps: pushed out to touching, its speed along the
-- normal turned back and damped. -> true when it bounced.
local function bounce(ball, qx, qy, reach, restitution)
    local nx, ny = ball.x - qx, ball.y - qy
    local d = len(nx, ny)
    if d >= reach or d == 0 then return false end
    nx, ny = nx / d, ny / d
    ball.x, ball.y = qx + nx * reach, qy + ny * reach
    local vn = ball.vx * nx + ball.vy * ny
    if vn < 0 then
        ball.vx, ball.vy = ball.vx - (1 + restitution) * vn * nx, ball.vy - (1 + restitution) * vn * ny
        return true
    end
    return false
end

-- A hole for the simulation from the green's corners: every edge is a wall unless listed open (1 = from the first
-- corner to the second). Obstacles are circles { x, y, r } or walls { ax, ay, bx, by }.
function Putting.compile(points, open, cup, obstacles)
    local isOpen = {}
    for _, i in ipairs(open or {}) do isOpen[tonumber(i)] = true end
    local walls, circles = {}, {}
    for i = 1, #points do
        local a, b = points[i], points[i % #points + 1]
        if not isOpen[i] then walls[#walls + 1] = { a.x, a.y, b.x, b.y } end
    end
    for _, o in ipairs(obstacles or {}) do
        if o.r then circles[#circles + 1] = { o.x, o.y, o.r } else walls[#walls + 1] = { o.ax, o.ay, o.bx, o.by } end
    end
    return { points = points, walls = walls, circles = circles, cup = cup, open = next(isOpen) ~= nil }
end

-- An obstacle place as the simulation sees it: a spot is a post of the default radius, a sphere a circle,
-- a box its four sides (turned by its rotation).
function Putting.obstacle(record, postRadius)
    local c = record.coords
    if record.shape == 'box' and record.size then
        local hx, hy, r = record.size.x / 2, record.size.y / 2, math.rad(record.rotation or 0)
        local cs, sn = math.cos(r), math.sin(r)
        local corners = {}
        for i, k in ipairs({ { -1, -1 }, { 1, -1 }, { 1, 1 }, { -1, 1 } }) do
            local lx, ly = k[1] * hx, k[2] * hy
            corners[i] = { c.x + lx * cs - ly * sn, c.y + lx * sn + ly * cs }
        end
        local out = {}
        for i = 1, 4 do
            local a, b = corners[i], corners[i % 4 + 1]
            out[i] = { ax = a[1], ay = a[2], bx = b[1], by = b[2] }
        end
        return out
    end
    return { { x = c.x, y = c.y, r = record.shape == 'sphere' and record.radius or postRadius } }
end

-- The holes of a course: hole zones whose nearest course is this one (within range), in number order, each with
-- the obstacles standing on its green. courses / holes / obstacles are world records.
function Putting.holesOf(course, courses, holes, obstacles, range, postRadius)
    local function dist(a, b) return len(a.x - b.x, a.y - b.y) end
    local function middle(zone)
        local sx, sy = 0, 0
        for _, p in ipairs(zone.points) do sx, sy = sx + p.x, sy + p.y end
        return { x = sx / #zone.points, y = sy / #zone.points }
    end
    local out = {}
    for _, zone in ipairs(holes) do
        local m, best, owner = middle(zone), range, nil
        for _, c in ipairs(courses) do
            local d = dist(m, c.coords)
            if d <= best then best, owner = d, c.uid end
        end
        local tee, cup = zone.settings.tee, zone.settings.cup
        if owner == course.uid and tee and cup and #zone.points >= 3 then
            local list = {}
            for _, o in ipairs(obstacles) do
                if inside(zone.points, o.coords.x, o.coords.y) then
                    for _, part in ipairs(Putting.obstacle(o, postRadius)) do list[#list + 1] = part end
                end
            end
            out[#out + 1] = { uid = zone.uid, number = zone.settings.number or 1, par = zone.settings.par or 3, tee = tee, cup = cup,
                z = (tee.z + cup.z) / 2, points = zone.points, open = zone.settings.open, obstacles = list }
        end
    end
    table.sort(out, function(a, b) return a.number < b.number end)
    return out
end

-- The power needle: 0..1..0 back and forth, speed in sweeps a second from a start phase (0-2).
function Putting.power(ms, speed, phase)
    local x = (ms / 1000 * speed + phase) % 2
    return x < 1 and x or 2 - x
end

-- The direction of a heading in degrees (0 = north, counter-clockwise, as the game counts).
function Putting.direction(heading)
    local r = math.rad(heading)
    return -math.sin(r), math.cos(r)
end

-- Rolls a ball. opts: radius, friction, restitution, cupRadius, captureSpeed, stopSpeed, maxSeconds.
-- -> { path = { {x, y}, ... } every 50 ms, rest = { x, y }, holed, out, hits = { ms, ... } }
function Putting.roll(hole, start, heading, speed, opts)
    local dx, dy = Putting.direction(heading)
    local ball = { x = start.x, y = start.y, vx = dx * speed, vy = dy * speed }
    local r, decel = opts.radius, opts.friction * G
    local path, hits = { { start.x, start.y } }, {}
    local steps = math.floor(opts.maxSeconds / DT)
    local out = { path = path, hits = hits }
    for i = 1, steps do
        local v = len(ball.vx, ball.vy)
        if v < opts.stopSpeed then break end
        local slow = math.max(0, v - decel * DT) / v
        ball.vx, ball.vy = ball.vx * slow, ball.vy * slow
        ball.x, ball.y = ball.x + ball.vx * DT, ball.y + ball.vy * DT
        local hit = false
        for _, w in ipairs(hole.walls) do
            local qx, qy = nearest(w[1], w[2], w[3], w[4], ball.x, ball.y)
            hit = bounce(ball, qx, qy, r, opts.restitution) or hit
        end
        for _, c in ipairs(hole.circles) do
            local cx, cy, cr = c[1], c[2], c[3]
            local nx, ny = ball.x - cx, ball.y - cy
            local d = len(nx, ny)
            if d > 0 and d < cr + r then hit = bounce(ball, cx + nx / d * cr, cy + ny / d * cr, r, opts.restitution) or hit end
        end
        if hit and #hits < 20 then hits[#hits + 1] = math.floor(i * DT * 1000) end
        local cup = hole.cup
        if len(ball.x - cup.x, ball.y - cup.y) < opts.cupRadius then
            if len(ball.vx, ball.vy) < opts.captureSpeed then
                ball.x, ball.y, out.holed = cup.x, cup.y, true
                path[#path + 1] = { cup.x, cup.y }
                break
            end
            ball.vx, ball.vy = ball.vx * 0.985, ball.vy * 0.985 -- the lip takes a little off a fast ball
        end
        if hole.open and not inside(hole.points, ball.x, ball.y) then
            out.out = true
            path[#path + 1] = { ball.x, ball.y }
            break
        end
        if i % SAMPLE == 0 then path[#path + 1] = { ball.x, ball.y } end
    end
    if not out.holed and not out.out then
        local last = path[#path]
        if last[1] ~= ball.x or last[2] ~= ball.y then path[#path + 1] = { ball.x, ball.y } end
    end
    out.rest = { x = ball.x, y = ball.y }
    return out
end

-- How long a path plays (ms).
function Putting.duration(result) return (#result.path - 1) * DT * SAMPLE * 1000 end
