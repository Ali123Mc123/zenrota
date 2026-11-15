-- Seats round a game place, with no game natives: on a rug or a round table a ring facing in, at a long table two
-- rows facing it. Shapes: floor | table | long. The sizes come from Config.Seating.
GameRules = GameRules or {}
local Seats = {}
GameRules.seats = Seats

function Seats.shape(settings)
    local s = settings and settings.surface
    return (s == 'table' or s == 'long') and s or 'floor'
end

-- Seat i of n round c = { x, y, w }: x, y on the ground and the heading a sitting player faces.
function Seats.pose(shape, i, n, c)
    local cfg, w = Config.Seating, c.w or 0
    if shape == 'long' then
        local perSide = math.ceil(n / 2)
        local side = i <= perSide and 1 or -1
        local along = ((i - 1) % perSide - (perSide - 1) / 2) * cfg.Long.Spacing
        local h = math.rad(w)
        local x = c.x + math.cos(h) * along - math.sin(h) * side * cfg.Long.Half
        local y = c.y + math.sin(h) * along + math.cos(h) * side * cfg.Long.Half
        return x, y, (w + (side == 1 and 180 or 0)) % 360
    end
    local r = math.max(cfg.Radius[shape] or cfg.Radius.floor, n * cfg.Spacing / (2 * math.pi))
    local a = math.rad(w + (i - 1) * 360 / n)
    return c.x + math.sin(-a) * r, c.y + math.cos(-a) * r, (math.deg(a) + 180) % 360
end

-- How far from the middle the seats go (for reach checks).
function Seats.reach(shape, n)
    local cfg = Config.Seating
    if shape == 'long' then return math.ceil(n / 2) * cfg.Long.Spacing / 2 + cfg.Long.Half end
    return math.max(cfg.Radius[shape] or cfg.Radius.floor, n * cfg.Spacing / (2 * math.pi))
end
