-- Bottle spin, with no game natives: where the seats are, whom the bottle points at and where it stops.
GameRules = GameRules or {}
local Bottle = {}
GameRules.bottle = Bottle

-- The angle of seat i of n around the bottle (degrees, 0 = the place's heading).
function Bottle.seatAngle(i, n, heading)
    return ((heading or 0) + (i - 1) * 360 / n) % 360
end

-- The point of a seat on a ring of the radius around the center: x, y, and the heading that faces the center.
function Bottle.seat(center, radius, angle)
    local r = math.rad(angle)
    local x, y = center.x + math.sin(-r) * radius, center.y + math.cos(-r) * radius
    return x, y, (angle + 180) % 360
end

-- A spin over the players' seat angles: the player it ends on (never the spinner when skipSelf), the angle it stops
-- at inside that seat's slice, and the time. random(n) gives 1..n, rnd() 0..1.
function Bottle.spin(angles, spinner, from, opts, random, rnd)
    local choices = {}
    for i = 1, #angles do
        if not (opts.skipSelf and i == spinner) then choices[#choices + 1] = i end
    end
    local target = choices[random(#choices)]
    local stop = (angles[target] + (rnd() * 2 - 1) * opts.slice * 0.3) % 360
    local turns = opts.turns[1] + random(opts.turns[2] - opts.turns[1] + 1) - 1
    local ms = math.floor((opts.seconds[1] + rnd() * (opts.seconds[2] - opts.seconds[1])) * 1000)
    return target, from + turns * 360 + ((stop - from) % 360), ms
end

-- The angle at a moment of a spin from `from` to `to` over ms: slows down to a stop (cubic ease-out).
function Bottle.angleAt(from, to, ms, elapsed)
    local t = math.min(math.max(elapsed / ms, 0), 1)
    return from + (to - from) * (1 - (1 - t) ^ 3)
end

-- A player's own question: one line, trimmed, at most max characters; nil when empty or not text.
function Bottle.ownText(text, max)
    if type(text) ~= 'string' or not utf8.len(text) then return nil end
    text = text:gsub('%c', ' '):gsub('%s+', ' '):gsub('^ ', ''):gsub(' $', '')
    local cut = utf8.offset(text, max + 1)
    if cut then text = text:sub(1, cut - 1) end
    return text ~= '' and text or nil
end
