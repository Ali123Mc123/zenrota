-- The video decoder lease as plain rules (6-tahta-video-sanat.md 3.3): screens ask with a score every tick; free slots
-- go to the best; a holder keeps its slot until a rival leads it by `lead` points for `leadMs`; a request not renewed
-- for `staleMs` lapses. services/client/dui.lua runs one for every product; a product falls back to its own.
local dui = {}

function dui.arbiter(options)
    options = options or {}
    local slots = math.max(0, math.floor(tonumber(options.slots) or 1))
    local lead, leadMs, staleMs = options.lead or 20, options.leadMs or 3000, options.staleMs or 2500
    local wants, holds = {}, {} -- key -> { score, at, ahead }; key -> true
    local self = {}

    local function best(skip)
        local found
        for key, want in pairs(wants) do
            if not skip[key] and (not found or want.score > wants[found].score) then found = key end
        end
        return found
    end

    local function settle(now)
        for key, want in pairs(wants) do
            if now - want.at > staleMs then wants[key], holds[key] = nil, nil end
        end
        local held = 0
        for _ in pairs(holds) do held = held + 1 end
        while held < slots do
            local key = best(holds)
            if not key then break end
            holds[key], wants[key].ahead, held = true, nil, held + 1
        end
        local weakest
        for key in pairs(holds) do
            if not weakest or wants[key].score < wants[weakest].score then weakest = key end
        end
        local rival = best(holds)
        for key, want in pairs(wants) do
            if key ~= rival then want.ahead = nil end
        end
        if not (weakest and rival) then return end
        local r = wants[rival]
        if r.score < wants[weakest].score + lead then
            r.ahead = nil
            return
        end
        r.ahead = r.ahead or now
        if now - r.ahead >= leadMs then
            holds[weakest], holds[rival], r.ahead = nil, true, nil
        end
    end

    -- Asks (and renews) with a score; true while the key holds a slot.
    function self.want(key, score, now)
        local want = wants[key] or {}
        want.score, want.at = tonumber(score) or 0, now
        wants[key] = want
        settle(now)
        return holds[key] == true
    end

    function self.drop(key, now)
        wants[key], holds[key] = nil, nil
        settle(now)
    end

    -- Drops every key for which match(key) is true (a stopped resource).
    function self.dropWhere(match, now)
        for key in pairs(wants) do
            if match(key) then wants[key], holds[key] = nil, nil end
        end
        settle(now)
    end

    function self.holding(key) return holds[key] == true end

    function self.count()
        local n = 0
        for _ in pairs(holds) do n = n + 1 end
        return n, slots
    end

    return self
end

return dui
