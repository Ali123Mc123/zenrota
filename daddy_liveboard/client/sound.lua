-- Sound and decoder maths of the media screens (6-tahta-video-sanat.md 3.3: sound, media page and decoder), plain
-- functions without natives so the tests run them. client/media.lua feeds them every 200 ms.
BoardSound = {}

local function clamp(value, low, high) return math.max(low, math.min(high, value)) end

-- Metres from p to the nearest point of a board's rectangle: upright, centred on its coords, facing its heading.
function BoardSound.nearest(board, p)
    local c, rad = board.coords, math.rad(board.heading + 90.0)
    local rx, ry = math.cos(rad), math.sin(rad)
    local u = clamp((p.x - c.x) * rx + (p.y - c.y) * ry, -board.width * 0.5, board.width * 0.5)
    local v = clamp(p.z - c.z, -board.height * 0.5, board.height * 0.5)
    local dx, dy, dz = p.x - (c.x + rx * u), p.y - (c.y + ry * u), p.z - (c.z + v)
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

-- Full up to near, silent from far, a curve between.
function BoardSound.curve(d, near, far, k)
    if d <= near then return 1.0 end
    if d >= far or far <= near then return 0.0 end
    return ((far - d) / (far - near)) ^ (k or 1.6)
end

-- 1 inside a floor area, easing to 0 over `width` metres past its edge (d: metres outside, 0 inside).
function BoardSound.edge(d, width)
    if d <= 0 then return 1.0 end
    if d >= width then return 0.0 end
    local t = 1.0 - d / width
    return t * t * (3.0 - 2.0 * t)
end

-- Same room 1, another room of the screen's building `other`, out of it (or in one, for a screen outdoors) `outside`.
-- A room never seen (nil or 0) counts as the same room.
function BoardSound.room(screenInterior, screenRoom, interior, room, other, outside)
    if not screenInterior or screenInterior == 0 then return (interior or 0) == 0 and 1.0 or outside end
    if interior ~= screenInterior then return outside end
    if not screenRoom or screenRoom == 0 or room == screenRoom then return 1.0 end
    return other
end

function BoardSound.db(value) return 10 ^ (value / 20) end

-- The heard part of one board: distance curve x floor-area edge x room.
function BoardSound.board(d, near, far, k, edge, room)
    return BoardSound.curve(d, near, far, k) * (edge or 1.0) * (room or 1.0)
end

-- Screen volume x own volume x ducking x the best board's part; 0..1.
function BoardSound.gain(volume, personal, duck, factor)
    return clamp((volume or 0) * (personal or 0) * (duck or 1) * (factor or 0), 0.0, 1.0)
end

-- A new gain goes to the page when it moved more than `step`, or every `resend` ms anyway.
function BoardSound.due(gain, sent, sentAt, now, step, resend)
    if sent == nil or sentAt == nil then return true end
    return math.abs(gain - sent) > step or now - sentAt >= resend
end

-- The decoder score of a screen: in its room +inZone, playing +playing, minus perMeter for each metre to its board.
function BoardSound.score(inZone, playing, distance, weights)
    return (inZone and weights.InZone or 0) + (playing and weights.Playing or 0) - distance * weights.PerMeter
end
