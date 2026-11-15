-- Clock sampling maths, the same everywhere: a ping's round trip and offset, the best of a round, whether the game's
-- timer drifted from the wall clock (a freeze) and whether two readings of the server's time agree.
local clock = {}

clock.SAMPLES, clock.GAP, clock.TIMEOUT = 5, 200, 2000     -- pings per round, ms between them, ms to wait for the last
clock.EVERY, clock.RETRY, clock.CHECK = 300000, 15000, 2000 -- a new round every 5 min (15 s after a failed one); freeze check
clock.FREEZE, clock.AGREE = 1500, 20                        -- timer drift that means a freeze; network clock tolerance (ms)

local WRAP, HALF = 4294967296, 2147483648

-- a - b in ms, right across a 32-bit timer wrap.
local function diff(a, b)
    return (a - b + HALF) % WRAP - HALF
end
clock.diff = diff

-- A ping sent and answered on this side's timer, with the server's time in the answer: offset = server - own timer.
function clock.sample(sent, back, server)
    local trip = math.max(0, diff(back, sent))
    return { trip = trip, offset = server + trip / 2 - back }
end

-- The sample with the shortest round trip (the first of equals), or nil.
function clock.best(samples)
    local best
    for _, sample in ipairs(samples or {}) do
        if not best or sample.trip < best.trip then best = sample end
    end
    return best
end

-- The timer moved more or less than the wall clock (whole seconds) by over limit ms since the base: the game froze or
-- was minimised. Without a wall clock (0) nothing counts as a freeze.
function clock.drifted(baseGame, baseCloud, game, cloud, limit)
    if type(baseCloud) ~= 'number' or type(cloud) ~= 'number' or baseCloud <= 0 or cloud <= 0 then return false end
    return math.abs(diff(game, baseGame) - (cloud - baseCloud) * 1000) > limit
end

-- Two readings of the server's time agree within tolerance ms.
function clock.agrees(a, b, tolerance)
    return math.abs(diff(a, b)) <= tolerance
end

return clock
