-- Capture the flag, with no game natives: the halves of the field, who may tag whom, and when a flag scores.
GameRules = GameRules or {}
local Ctf = {}
GameRules.ctf = Ctf

local function d2(a, b) return (a.x - b.x) ^ 2 + (a.y - b.y) ^ 2 end

-- The team whose half a point is in: the half nearer that team's base (the line is halfway between the bases).
function Ctf.half(bases, point)
    return d2(point, bases[1]) <= d2(point, bases[2]) and 1 or 2
end

-- May a player of team `tagger` tag a player of team `target` standing at `point`? A flag carrier anywhere; anyone
-- else only in the tagger's own half when ownHalfOnly.
function Ctf.canTag(bases, tagger, target, carrying, point, ownHalfOnly)
    if tagger == target then return false end
    if carrying or not ownHalfOnly then return true end
    return Ctf.half(bases, point) == tagger
end

-- A carrier scores at their own base, and only while their own flag is home.
function Ctf.scores(carrierTeam, flags, point, bases, reach)
    return flags[carrierTeam].at == 'base' and d2(point, bases[carrierTeam]) <= reach * reach
end

function Ctf.other(team) return team == 1 and 2 or 1 end

-- Places of the two teams from their flags: the more flags first, equal flags share first.
function Ctf.places(score)
    if score[1] == score[2] then return { 1, 1 } end
    return score[1] > score[2] and { 1, 2 } or { 2, 1 }
end
