-- A knockout bracket, with no game natives: the draw with byes, results moving winners on, and what is left to play.
-- bracket = { rounds = { { { a, b, winner }, ... }, ... } }; a side is an entrant key or false (a bye).
GameRules = GameRules or {}
local Bracket = {}
GameRules.bracket = Bracket

-- The smallest power of two that holds n (at least 2).
local function slots(n)
    local s = 2
    while s < n do s = s * 2 end
    return s
end

-- A random draw: entrants shuffled into the first round, byes filling the gaps; a bye's opponent goes straight on.
function Bracket.draw(entrants, random)
    local list = {}
    for i, e in ipairs(entrants) do list[i] = e end
    for i = #list, 2, -1 do
        local j = random(i)
        list[i], list[j] = list[j], list[i]
    end
    local size = slots(#list)
    local rounds, n = {}, size
    while n >= 2 do
        local round = {}
        for i = 1, n / 2 do round[i] = { a = nil, b = nil } end
        rounds[#rounds + 1] = round
        n = n / 2
    end
    -- Byes go to the second side of the first pairs, so no pair is two byes.
    local byes = size - #list
    local k = 1
    for i, pair in ipairs(rounds[1]) do
        pair.a = list[k]
        k = k + 1
        if i <= byes then pair.b = false else pair.b = list[k] k = k + 1 end
    end
    local bracket = { rounds = rounds }
    for i, pair in ipairs(rounds[1]) do
        if pair.b == false then Bracket.report(bracket, 1, i, pair.a) end
    end
    return bracket
end

-- A pair's winner moves on. -> the champion when that was the final, else nil.
function Bracket.report(bracket, round, index, winner)
    local pair = bracket.rounds[round] and bracket.rounds[round][index]
    if not pair or pair.winner or (winner ~= pair.a and winner ~= pair.b) then return nil, 'validation' end
    pair.winner = winner
    local nextRound = bracket.rounds[round + 1]
    if not nextRound then
        bracket.champion = winner
        return winner
    end
    local slot = nextRound[math.ceil(index / 2)]
    if index % 2 == 1 then slot.a = winner else slot.b = winner end
    return nil
end

-- The pairs that can be played now: both sides known, no winner yet. -> { { round, index, a, b } }
function Bracket.open(bracket)
    local out = {}
    for r, round in ipairs(bracket.rounds) do
        for i, pair in ipairs(round) do
            if pair.a and pair.b and not pair.winner then out[#out + 1] = { round = r, index = i, a = pair.a, b = pair.b } end
        end
    end
    return out
end

-- The open pair of two entrants, in either order, or nil.
function Bracket.pairOf(bracket, x, y)
    for _, p in ipairs(Bracket.open(bracket)) do
        if (p.a == x and p.b == y) or (p.a == y and p.b == x) then return p end
    end
end
