-- Shapes and zones, the same maths on client and server.
--   zone:  { points = { {x=, y=} }, minZ =, maxZ = }
--   shape: { shape = 'point'|'sphere'|'box'|'polygon', center, size, rotation, radius, points, minZ, maxZ, heading }
local geo = {}

local SHAPES = { point = true, sphere = true, box = true, polygon = true }
local POINT_RADIUS = 1.0

local function num(value, fallback)
    local n = tonumber(value)
    if n ~= n then return fallback end
    return n or fallback
end

-- vector2/3/4, {x,y,z,w} or {1,2,3,4} -> { x, y, z, w }.
local function vec(value)
    local kind = type(value)
    if kind == 'vector3' or kind == 'vector4' or kind == 'vector2' then
        return { x = value.x, y = value.y, z = kind ~= 'vector2' and value.z or 0.0, w = kind == 'vector4' and value.w or nil }
    end
    if kind ~= 'table' then return nil end
    local x, y = num(value.x) or num(value[1]), num(value.y) or num(value[2])
    if not x or not y then return nil end
    return { x = x, y = y, z = num(value.z) or num(value[3]) or 0.0, w = num(value.w) or num(value[4]) }
end
geo.vec = vec

local function xy(point)
    return tonumber(point.x or point[1]), tonumber(point.y or point[2])
end

local function readPoints(value)
    if type(value) == 'string' then value = value ~= '' and json.decode(value) or nil end
    if type(value) ~= 'table' then return nil end
    local out = {}
    for i, point in ipairs(value) do
        local p = vec(point)
        if not p then return nil end
        out[i] = { x = p.x, y = p.y }
    end
    return #out > 0 and out or nil
end

-- Zones ---------------------------------------------------------------------

function geo.inPolygon(x, y, points)
    local inside, j = false, #points
    for i = 1, #points do
        local xi, yi = xy(points[i])
        local xj, yj = xy(points[j])
        if (yi > y) ~= (yj > y) and x < (xj - xi) * (y - yi) / (yj - yi) + xi then inside = not inside end
        j = i
    end
    return inside
end

function geo.inZone(zone, coords)
    if not zone or not zone.points or #zone.points < 3 then return false end
    if zone.minZ and coords.z < zone.minZ then return false end
    if zone.maxZ and coords.z > zone.maxZ then return false end
    return geo.inPolygon(coords.x, coords.y, zone.points)
end

-- Center of the points and the radius that covers them all.
function geo.bounds(points)
    local cx, cy, cz = 0.0, 0.0, 0.0
    for _, point in ipairs(points) do
        local x, y = xy(point)
        cx, cy, cz = cx + x, cy + y, cz + (tonumber(point.z) or 0.0)
    end
    local n = math.max(1, #points)
    local center = vector3(cx / n, cy / n, cz / n)
    local radius = 0.0
    for _, point in ipairs(points) do
        local x, y = xy(point)
        radius = math.max(radius, #(vector2(x, y) - center.xy))
    end
    return center, radius
end

-- Cleans user input into a zone, or nil. Heights default to the points' z +/- margin.
function geo.zone(raw, margin)
    if type(raw) ~= 'table' or type(raw.points) ~= 'table' then return nil end
    local points, low, high = {}, math.huge, -math.huge
    for i = 1, math.min(#raw.points, 16) do
        local x, y = xy(raw.points[i])
        local z = tonumber(raw.points[i].z)
        if not x or not y then return nil end
        points[#points + 1] = { x = x, y = y }
        if z then low, high = math.min(low, z), math.max(high, z) end
    end
    if #points < 3 then return nil end
    margin = margin or 3.0
    local minZ = tonumber(raw.minZ) or (low < math.huge and low - margin) or nil
    local maxZ = tonumber(raw.maxZ) or (high > -math.huge and high + margin) or nil
    return { points = points, minZ = minZ, maxZ = maxZ }
end

-- Shapes --------------------------------------------------------------------

-- Any record (DB row, config entry, NUI form, shape) -> a shape, or nil.
-- Without a shape name it guesses: polygon, sphere, box, point.
function geo.shape(raw)
    if type(raw) ~= 'table' then return nil end
    local kind = SHAPES[tostring(raw.shape or ''):lower()] and tostring(raw.shape):lower() or nil
    local points = readPoints(raw.points or raw.points_json)
    local center = vec(raw.center) or vec(raw.coords)
        or (raw.center_x and vec({ raw.center_x, raw.center_y, raw.center_z }))
        or (raw.pos_x and vec({ raw.pos_x, raw.pos_y, raw.pos_z }))
    local size = vec(raw.size) or (raw.size_x and vec({ raw.size_x, raw.size_y, raw.size_z }))
    local radius = num(raw.radius)

    if not kind then
        kind = points and #points >= 3 and 'polygon' or radius and radius > 0 and 'sphere' or size and 'box' or center and 'point'
        if not kind then return nil end
    end
    if kind == 'polygon' and (not points or #points < 3) then return nil end
    if kind ~= 'polygon' and not center then return nil end

    return {
        shape = kind,
        center = center and { x = center.x, y = center.y, z = center.z } or nil,
        heading = (num(raw.heading) or (center and center.w) or 0.0) % 360.0,
        size = kind == 'box' and (size or { x = 1.0, y = 1.0, z = 2.0 }) or size,
        rotation = num(raw.rotation, 0.0),
        radius = (kind == 'sphere' or kind == 'point') and (radius or num(raw.interact_distance) or POINT_RADIUS) or radius,
        points = points,
        minZ = num(raw.minZ) or num(raw.min_z),
        maxZ = num(raw.maxZ) or num(raw.max_z),
    }
end

-- Entity anchors stand on the ground, so their box is lifted by half its height.
function geo.fromRecord(record)
    local shape = geo.shape(record)
    local isZone = record.center ~= nil or record.center_x ~= nil
    if shape and not isZone and shape.shape == 'box' then
        shape.center.z = shape.center.z + shape.size.z * 0.5
    end
    return shape
end

-- Point into the box's own axes.
local function boxLocal(shape, x, y)
    local dx, dy = x - shape.center.x, y - shape.center.y
    local rot = math.rad(-(shape.rotation or 0.0))
    if rot == 0.0 then return dx, dy end
    return dx * math.cos(rot) - dy * math.sin(rot), dx * math.sin(rot) + dy * math.cos(rot)
end

local function point3(x, y, z)
    if type(x) ~= 'number' then
        local v = vec(x)
        if not v then return nil end
        return v.x, v.y, v.z
    end
    return x, y, z or 0.0
end

function geo.contains(shape, x, y, z)
    x, y, z = point3(x, y, z)
    if type(shape) ~= 'table' or not x then return false end
    if shape.shape == 'polygon' then
        if shape.minZ and z < shape.minZ then return false end
        if shape.maxZ and z > shape.maxZ then return false end
        return geo.inPolygon(x, y, shape.points)
    end
    local c = shape.center
    if shape.shape == 'box' then
        local lx, ly = boxLocal(shape, x, y)
        return math.abs(lx) <= shape.size.x * 0.5 and math.abs(ly) <= shape.size.y * 0.5 and math.abs(z - c.z) <= shape.size.z * 0.5
    end
    local r = shape.radius or POINT_RADIUS
    return (x - c.x) ^ 2 + (y - c.y) ^ 2 + (z - c.z) ^ 2 <= r * r
end

local function edgeDistance(points, x, y)
    local best, j = math.huge, #points
    for i = 1, #points do
        local ax, ay, bx, by = points[j].x, points[j].y, points[i].x, points[i].y
        local dx, dy = bx - ax, by - ay
        local len = dx * dx + dy * dy
        local t = len > 0 and math.max(0, math.min(1, ((x - ax) * dx + (y - ay) * dy) / len)) or 0
        best = math.min(best, math.sqrt((x - ax - t * dx) ^ 2 + (y - ay - t * dy) ^ 2))
        j = i
    end
    return best
end

-- Distance to the surface; 0 inside.
function geo.distance(shape, x, y, z)
    x, y, z = point3(x, y, z)
    if type(shape) ~= 'table' or not x then return math.huge end
    if geo.contains(shape, x, y, z) then return 0.0 end
    if shape.shape == 'polygon' then
        local vertical = shape.minZ and z < shape.minZ and shape.minZ - z or shape.maxZ and z > shape.maxZ and z - shape.maxZ or 0.0
        if geo.inPolygon(x, y, shape.points) then return vertical end
        return math.sqrt(edgeDistance(shape.points, x, y) ^ 2 + vertical ^ 2)
    end
    local c = shape.center
    if shape.shape == 'box' then
        local lx, ly = boxLocal(shape, x, y)
        local ox = math.max(0.0, math.abs(lx) - shape.size.x * 0.5)
        local oy = math.max(0.0, math.abs(ly) - shape.size.y * 0.5)
        local oz = math.max(0.0, math.abs(z - c.z) - shape.size.z * 0.5)
        return math.sqrt(ox * ox + oy * oy + oz * oz)
    end
    return math.max(0.0, math.sqrt((x - c.x) ^ 2 + (y - c.y) ^ 2 + (z - c.z) ^ 2) - (shape.radius or POINT_RADIUS))
end

function geo.centroid(shape)
    if shape.shape ~= 'polygon' then return shape.center and { x = shape.center.x, y = shape.center.y, z = shape.center.z } end
    local sx, sy = 0.0, 0.0
    for _, p in ipairs(shape.points) do sx, sy = sx + p.x, sy + p.y end
    local low = shape.minZ or 0.0
    return { x = sx / #shape.points, y = sy / #shape.points, z = (low + (shape.maxZ or low)) * 0.5 }
end

-- A sphere around the whole shape, for streaming: center, radius.
function geo.extent(shape)
    local center = geo.centroid(shape)
    if not center then return nil, 0.0 end
    if shape.shape == 'box' then
        local s = shape.size
        return center, math.sqrt((s.x * 0.5) ^ 2 + (s.y * 0.5) ^ 2 + (s.z * 0.5) ^ 2)
    end
    if shape.shape == 'polygon' then
        local far = 0.0
        for _, p in ipairs(shape.points) do far = math.max(far, (p.x - center.x) ^ 2 + (p.y - center.y) ^ 2) end
        return center, math.sqrt(far + (((shape.maxZ or 0.0) - (shape.minZ or 0.0)) * 0.5) ^ 2)
    end
    return center, shape.radius or POINT_RADIUS
end

-- Same shape within a centimetre.
function geo.equals(a, b)
    if a == b then return true end
    if type(a) ~= 'table' or type(b) ~= 'table' or a.shape ~= b.shape then return false end
    local function same(x, y) return (x == nil and y == nil) or (x ~= nil and y ~= nil and math.abs(x - y) <= 0.01) end
    local function sameVec(x, y) return (x == nil and y == nil) or (x ~= nil and y ~= nil and same(x.x, y.x) and same(x.y, y.y) and same(x.z, y.z)) end
    if not (sameVec(a.center, b.center) and sameVec(a.size, b.size) and same(a.radius, b.radius)) then return false end
    if not (same(a.rotation or 0, b.rotation or 0) and same(a.heading or 0, b.heading or 0) and same(a.minZ, b.minZ) and same(a.maxZ, b.maxZ)) then return false end
    if (a.points == nil) ~= (b.points == nil) or (a.points and #a.points ~= #b.points) then return false end
    for i, p in ipairs(a.points or {}) do
        if not same(p.x, b.points[i].x) or not same(p.y, b.points[i].y) then return false end
    end
    return true
end

-- Can this shape be saved: ok, field, reason.
function geo.validate(shape, limits)
    limits = limits or {}
    local minSize, maxSize, maxPoints = limits.minSize or 0.5, limits.maxSize or 1000.0, limits.maxPoints or 64
    local minZ, maxZ, maxXY = limits.minZ or -100.0, limits.maxZ or 2000.0, limits.maxXY or 20000.0
    if type(shape) ~= 'table' or not SHAPES[shape.shape] then return false, 'shape' end

    local function onMap(x, y, z) return math.abs(x) <= maxXY and math.abs(y) <= maxXY and (not z or (z >= minZ and z <= maxZ)) end

    if shape.shape == 'polygon' then
        if #shape.points < 3 then return false, 'points', 'too_few' end
        if #shape.points > maxPoints then return false, 'points', 'too_many' end
        for _, p in ipairs(shape.points) do
            if not onMap(p.x, p.y) then return false, 'points', 'out_of_bounds' end
        end
        if not shape.minZ or not shape.maxZ or shape.minZ >= shape.maxZ then return false, 'maxZ', 'must_exceed_min' end
        if shape.minZ < minZ or shape.maxZ > maxZ then return false, 'minZ', 'out_of_bounds' end
        return true
    end
    local c = shape.center
    if not onMap(c.x, c.y, c.z) then return false, 'center', 'out_of_bounds' end
    if shape.shape == 'box' then
        for _, key in ipairs({ 'x', 'y', 'z' }) do
            if shape.size[key] < minSize or shape.size[key] > maxSize then return false, 'size', 'out_of_range' end
        end
    elseif shape.radius and (shape.radius < (shape.shape == 'sphere' and minSize or 0.01) or shape.radius > maxSize) then
        return false, 'radius', 'out_of_range'
    end
    return true
end

return geo
