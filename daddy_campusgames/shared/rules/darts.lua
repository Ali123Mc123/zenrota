-- Darts, with no game natives: where a dart lands on the board, what it scores and how a game goes on.
-- Board coordinates are metres from the bull, x to the right and y up as the thrower sees it.
GameRules = GameRules or {}
local Darts = {}
GameRules.darts = Darts

local ORDER = { 20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5 }
local R = { bull = 0.00635, outer = 0.0159, tripleIn = 0.099, tripleOut = 0.107, doubleIn = 0.162, doubleOut = 0.170 }
Darts.RADIUS = R.doubleOut

-- -> value, multiplier (0 miss, 1, 2, 3; the bull is 2 x 25), the number hit (25 for either bull, 0 for a miss)
function Darts.score(x, y)
    local r = math.sqrt(x * x + y * y)
    if r <= R.bull then return 50, 2, 25 end
    if r <= R.outer then return 25, 1, 25 end
    if r > R.doubleOut then return 0, 0, 0 end
    local angle = math.deg(math.atan(x, y)) % 360 -- 0 at the top, clockwise
    local number = ORDER[math.floor(((angle + 9) % 360) / 18) + 1]
    local mult = (r >= R.tripleIn and r <= R.tripleOut) and 3 or (r >= R.doubleIn) and 2 or 1
    return number * mult, mult, number
end

-- The middle of a number's treble (or of its single when treble is false); the bull for 21 and up. -> x, y
function Darts.aim(number, treble)
    for i, n in ipairs(ORDER) do
        if n == number then
            local r, a = treble and (R.tripleIn + R.tripleOut) / 2 or 0.13, math.rad((i - 1) * 18)
            return math.sin(a) * r, math.cos(a) * r
        end
    end
    return 0.0, 0.0
end

-- The sway on top of the aim at t seconds: a slow figure the player fights; holding the breath calms it for a
-- while, then it shakes. -> dx, dy
function Darts.sway(p, t, holdAt)
    local factor = 1.0
    if holdAt and t >= holdAt then factor = (t - holdAt <= p.hold) and p.calm or p.shake end
    return p.a * factor * math.sin(p.f1 * t + p.p1), p.a * factor * math.sin(p.f2 * t + p.p2)
end

-- A new player's line for the mode.
function Darts.start(mode)
    if mode == '301' then return { left = 301 } end
    if mode == 'around_clock' then return { target = 1 } end
    if mode == 'high_score' then return { total = 0, visits = 0 } end
    return { left = 501 }
end

-- One dart into a visit. line = the player's line, visit = { darts, before }. -> what happened:
-- { value, mult, number, bust, won, over } (over = the visit is done).
function Darts.throw(mode, line, visit, value, mult, number, opts)
    visit.darts = visit.darts + 1
    local out = { value = value, mult = mult, number = number }
    if mode == '501' or mode == '301' then
        local left = line.left - value
        local doubleOut = opts.doubleOut
        if left < 0 or (doubleOut and left == 1) or (left == 0 and doubleOut and mult ~= 2) then
            line.left, out.bust = visit.before, true
        else
            line.left = left
            out.won = left == 0
        end
    elseif mode == 'around_clock' then
        if number == line.target or (line.target == 21 and number == 25) then line.target = line.target + 1 end
        out.won = line.target > 21
    else
        line.total = line.total + value
    end
    out.over = out.bust or out.won or visit.darts >= 3
    if out.over and mode == 'high_score' then line.visits = line.visits + 1 end
    return out
end

-- A new visit for the line (remembers where an x01 visit started, for a bust).
function Darts.visit(line) return { darts = 0, before = line.left } end

-- The ranking number of a line: lower is better for x01 (points left), higher for the others.
function Darts.rankScore(mode, line)
    if mode == 'around_clock' then return line.target end
    if mode == 'high_score' then return line.total end
    return -line.left
end
