-- Balloon date spots, with no game natives: the dater stands on the place, the others on a half moon in front.
GameRules = GameRules or {}
local Balloon = {}
GameRules.balloon = Balloon

-- Spot i of n on the arc round c = { x, y, w } (w = the way the dater looks): x, y and the heading facing the dater.
function Balloon.spot(c, i, n, radius, arc)
    local w = c.w or 0.0
    local a = n > 1 and w - arc / 2 + arc * (i - 1) / (n - 1) or w
    local r = math.rad(a)
    return c.x - math.sin(r) * radius, c.y + math.cos(r) * radius, (a + 180.0) % 360
end
