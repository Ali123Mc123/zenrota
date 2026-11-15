-- The room rule on both sides (6-tahta-video-sanat.md 3.2): a canvas's floor area, else Config.Radius on its floor;
-- slack m past it (an open reaches 15 m further, a watcher keeps 5 m). The write rule: in the floor area and within
-- reach of the canvas (Config.Interact.ServerTolerance past half its size).
Room = {}

local shapes = setmetatable({}, { __mode = 'k' }) -- canvas -> its floor area as a polygon

function Room.inside(c, coords, slack)
    slack = slack or 0.0
    if c.zone then
        if slack <= 0 then return DL.geo.inZone(c.zone, coords) end
        local shape = shapes[c]
        if not shape then
            shape = { shape = 'polygon', points = c.zone.points, minZ = c.zone.minZ, maxZ = c.zone.maxZ }
            shapes[c] = shape
        end
        return DL.geo.distance(shape, coords) <= slack
    end
    return math.abs(coords.z - c.coords.z) <= Config.Height + slack and #(coords.xy - c.coords.xy) <= Config.Radius + slack
end

function Room.reach(c)
    return (Config.Interact.ServerTolerance or 4.0) + math.max(c.width, c.height) * 0.5
end

function Room.near(c, coords)
    if c.zone and not DL.geo.inZone(c.zone, coords) then return false end
    return #(coords - c.coords) <= Room.reach(c)
end
