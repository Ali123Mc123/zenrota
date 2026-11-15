-- Chores, the rules both sides share: scattering pieces over an area, the stroke rhythm and staged looks.
-- No game natives here, so the server, the client and the tests run the same code.
Chores = Chores or {}

-- Distance on the ground plane.
function Chores.flat(a, b)
    return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)
end

-- Area helpers ---------------------------------------------------------------------------------------

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

local function inPolygon(x, y, points)
    local inside, j = false, #points
    for i = 1, #points do
        local a, b = points[i], points[j]
        if (a.y > y) ~= (b.y > y) and x < (b.x - a.x) * (y - a.y) / (b.y - a.y) + a.x then inside = not inside end
        j = i
    end
    return inside
end

-- The flat rectangle around a shape: low corner, high corner.
local function bounds(shape)
    if shape.shape == 'polygon' then
        local lo, hi = { x = math.huge, y = math.huge }, { x = -math.huge, y = -math.huge }
        for _, p in ipairs(shape.points) do
            lo.x, lo.y, hi.x, hi.y = math.min(lo.x, p.x), math.min(lo.y, p.y), math.max(hi.x, p.x), math.max(hi.y, p.y)
        end
        return lo, hi
    end
    local c = shape.center
    local r = shape.shape == 'box' and math.sqrt(shape.size.x ^ 2 + shape.size.y ^ 2) * 0.5 or (shape.radius or 1.0)
    return { x = c.x - r, y = c.y - r }, { x = c.x + r, y = c.y + r }
end

-- Inside the shape and at least edge metres from its border.
local function within(shape, x, y, edge)
    if shape.shape == 'polygon' then return inPolygon(x, y, shape.points) and edgeDistance(shape.points, x, y) >= edge end
    local c = shape.center
    if shape.shape == 'box' then
        local rot = math.rad(-(shape.rotation or 0.0))
        local dx, dy = x - c.x, y - c.y
        local lx, ly = dx * math.cos(rot) - dy * math.sin(rot), dx * math.sin(rot) + dy * math.cos(rot)
        return math.abs(lx) <= shape.size.x * 0.5 - edge and math.abs(ly) <= shape.size.y * 0.5 - edge
    end
    return math.sqrt((x - c.x) ^ 2 + (y - c.y) ^ 2) <= (shape.radius or 1.0) - edge
end

local function apart(points, x, y, spacing)
    for _, p in ipairs(points) do
        if (p.x - x) ^ 2 + (p.y - y) ^ 2 < spacing * spacing then return false end
    end
    return true
end

-- Up to count spots inside a shape (polygon, box or sphere), spacing apart and edge away from the border.
-- opts: { spacing, edge, rng = function() -> 0..1, avoid = { {x,y} } }
function Chores.scatter(shape, count, opts)
    opts = opts or {}
    local rng, spacing, edge = opts.rng or math.random, opts.spacing or 2.0, opts.edge or 1.0
    local lo, hi = bounds(shape)
    local out, taken, tries = {}, { table.unpack(opts.avoid or {}) }, 0
    while #out < count and tries < count * 40 do
        tries = tries + 1
        local x, y = lo.x + rng() * (hi.x - lo.x), lo.y + rng() * (hi.y - lo.y)
        if within(shape, x, y, edge) and apart(taken, x, y, spacing) then
            out[#out + 1] = { x = x, y = y }
            taken[#taken + 1] = out[#out]
        end
    end
    return out
end

-- The heights a shape spans: top, bottom (the client looks for the ground between them).
function Chores.heights(shape)
    if shape.shape == 'polygon' then return shape.maxZ, shape.minZ end
    local c = shape.center
    local half = shape.shape == 'box' and shape.size.z * 0.5 or (shape.radius or 1.0)
    return c.z + half, c.z - half
end

-- Strokes --------------------------------------------------------------------------------------------

-- One key press in a chain of strokes: the keys take turns and come neither too quick nor too slow.
-- A press that comes too quick is a fault and starts the wait over, so mashing never counts; after a long
-- pause the press counts as the first of a new chain. chain: { key, at, count } -> accepted, why.
function Chores.stroke(chain, key, now, rules)
    local gap = chain.at and now - chain.at
    if gap and gap < rules.minGapMs then
        chain.at = now
        return false, 'quick'
    end
    if gap and gap <= rules.maxGapMs and key == chain.key then return false, 'same' end
    chain.key, chain.at, chain.count = key, now, (chain.count or 0) + 1
    return true, gap and gap > rules.maxGapMs and 'fresh' or nil
end

-- Looks ----------------------------------------------------------------------------------------------

-- Which of a staged set to show: 1..stages as done goes from 0 to total (an empty, half and full bag).
function Chores.stageOf(done, total, stages)
    if total <= 0 or done >= total then return stages end
    return 1 + math.floor(done * (stages - 1) / total)
end

-- The model of a look at a state: look = { models = { first choice, fallbacks... }, states = { 'large', ... } }.
-- A model made in states is named <model>_<state>; one without them stands for every state.
-- exists(name) says whether the game has the model. -> name, whether it shows the state
function Chores.model(look, index, exists)
    for _, name in ipairs(look.models or {}) do
        local state = look.states and look.states[index]
        if state and exists(name .. '_' .. state) then return name .. '_' .. state, true end
        if exists(name) then return name, not look.states end
    end
end
