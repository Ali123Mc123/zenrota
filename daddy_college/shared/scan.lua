-- Scanner gates on both sides: a point in a gate's own axes, and whether a walk through it can be believed.
ScanGeometry = {}
local Geometry = ScanGeometry

-- A point in a gate's own axes: across (to its right) and along (forward, the way it faces: into the campus).
-- gate: { x, y, w = heading in degrees }
function Geometry.toGate(gate, x, y)
    local h = math.rad(gate.w or 0.0)
    local dx, dy = x - gate.x, y - gate.y
    return dx * math.cos(h) + dy * math.sin(h), -dx * math.sin(h) + dy * math.cos(h)
end

-- Whether a player stands in a gate's frame (with a little slack for the server's position).
function Geometry.within(gate, box, x, y, slack)
    local across, along = Geometry.toGate(gate, x, y)
    slack = slack or 0.0
    return math.abs(across) <= box.width * 0.5 + slack and math.abs(along) <= box.depth * 0.5 + slack
end

-- Whether the server may believe a player just walked through a gate the way they say ('in' = forward):
-- they stand off its middle by no more than the box and a step or two past it, on the side they went to.
function Geometry.passed(gate, box, x, y, way)
    local across, along = Geometry.toGate(gate, x, y)
    if math.abs(across) > box.width * 0.5 + 1.0 or math.abs(along) > box.depth * 0.5 + 2.5 then return false end
    if way == 'in' then return along > -0.3 end
    if way == 'out' then return along < 0.3 end
    return false
end
