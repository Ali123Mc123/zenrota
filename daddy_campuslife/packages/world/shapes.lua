-- Geometry for the place editor, kept free of game calls so it can be tested: a box from three clicks, polygon
-- area and crossing sides, grid snapping. Points are { x, y, z } tables.
World = World or {}
World.shapes = {}

local shapes = World.shapes

function shapes.snap(value, step)
    return math.floor(value / step + 0.5) * step
end

-- The box drawn by two corners of one side (a, b) and a point that sets the depth: rotation is the side's angle,
-- size.x its length, size.y the depth; base is the floor center. Nil while a side is too short.
function shapes.box(a, b, depthPoint, height)
    local dx, dy = b.x - a.x, b.y - a.y
    local length = math.sqrt(dx * dx + dy * dy)
    if length < 0.05 then return nil end
    local ux, uy = dx / length, dy / length
    local depth = depthPoint and ((depthPoint.x - a.x) * -uy + (depthPoint.y - a.y) * ux) or 0.0
    local floor = math.min(a.z, b.z)
    local base = { x = a.x + ux * length * 0.5 - uy * depth * 0.5, y = a.y + uy * length * 0.5 + ux * depth * 0.5, z = floor }
    return {
        base = base, rotation = math.deg(math.atan(dy, dx)) % 360,
        size = { x = length, y = math.abs(depth), z = height },
        center = { x = base.x, y = base.y, z = floor + height * 0.5 },
    }
end

-- Floor area of an outline in square metres.
function shapes.area(points)
    local sum = 0.0
    for i, a in ipairs(points) do
        local b = points[i % #points + 1]
        sum = sum + a.x * b.y - b.x * a.y
    end
    return math.abs(sum) * 0.5
end

local function side(a, b, c)
    return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
end

local function cross(a, b, c, d)
    return side(a, b, c) * side(a, b, d) < 0 and side(c, d, a) * side(c, d, b) < 0
end

-- Whether two sides of the closed outline cross each other.
function shapes.crossing(points)
    local n = #points
    if n < 4 then return false end
    for i = 1, n do
        local a, b = points[i], points[i % n + 1]
        for j = i + 2, n do
            if not (i == 1 and j == n) and cross(a, b, points[j], points[j % n + 1]) then return true end
        end
    end
    return false
end

-- The middle of the outline's corners.
function shapes.middle(points)
    local x, y, z = 0.0, 0.0, 0.0
    for _, p in ipairs(points) do x, y, z = x + p.x, y + p.y, z + (p.z or 0.0) end
    local n = math.max(#points, 1)
    return { x = x / n, y = y / n, z = z / n }
end

-- Lowest and highest corner.
function shapes.heights(points)
    local low, high
    for _, p in ipairs(points) do
        local z = p.z or 0.0
        low, high = math.min(low or z, z), math.max(high or z, z)
    end
    return low, high
end
