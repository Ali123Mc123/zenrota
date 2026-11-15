-- Rules every game shares, with no game natives: the server, the client and the tests run the same code.
GameRules = GameRules or {}

-- ISO week of a time shifted by the server's offset (hours from UTC): '2026-W42'.
function GameRules.weekKey(ts, offsetHours)
    ts = (ts or os.time()) + math.floor((offsetHours or 0) * 3600 + 0.5)
    local wday = os.date('!*t', ts).wday - 1
    local weekday = wday == 0 and 7 or wday
    local thursday = os.date('!*t', ts + (4 - weekday) * 86400)
    return ('%d-W%02d'):format(thursday.year, math.floor((thursday.yday - 1) / 7) + 1)
end

-- The 0-100 score of a finishing place (1 = first); 0 for a player who did not finish.
function GameRules.placeScore(place, scores)
    if not place or place < 1 then return 0 end
    return scores[place] or 25
end

-- Places from scores (higher is better unless lowWins); equal scores share a place.
-- entries = { { id, score } } -> { [id] = place }
function GameRules.places(entries, lowWins)
    local list = {}
    for i, e in ipairs(entries) do list[i] = e end
    table.sort(list, function(a, b)
        if a.score == b.score then return tostring(a.id) < tostring(b.id) end
        if lowWins then return a.score < b.score end
        return a.score > b.score
    end)
    local out, place = {}, 0
    for i, e in ipairs(list) do
        if i == 1 or e.score ~= list[i - 1].score then place = i end
        out[e.id] = place
    end
    return out
end

-- Two teams as even as can be: ids shuffled by the given random function, then dealt in turn.
function GameRules.balance(ids, random)
    local list = {}
    for i, id in ipairs(ids) do list[i] = id end
    for i = #list, 2, -1 do
        local j = random(i)
        list[i], list[j] = list[j], list[i]
    end
    local teams = {}
    for i, id in ipairs(list) do teams[id] = (i % 2 == 1) and 1 or 2 end
    return teams
end
