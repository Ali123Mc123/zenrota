-- Ink rules (6-tahta-video-sanat.md 3.2, 3.8): the budgets of both sides, who may send which kind, op states and a
-- cost bucket. Past a budget the client waits, the server answers 'slow' with the wait; only a page holding 8 MB of
-- unbaked ink refuses new ink until a bake makes room.
Ink = Ink or {}
local rules = {}

rules.VERSION = '0.4.0' -- the engine copy a product logs at start

-- The client: one ops call every 200 ms or at 24 ops / 16 KB, 8 KB/s with a 64 KB burst, live ink every 200 ms
-- (<= 2 KB), an op without its seq after 5 s is sent again with the same key.
rules.CLIENT = {
    BATCH_MS = 200, BATCH_OPS = 24, BATCH_BYTES = 16384,
    RATE = 8192, BURST = 65536,
    LIVE_MS = 200, LIVE_BYTES = 2048,
    RESEND_MS = 5000,
}

-- The server. Sizes are base64 bytes, times ms unless named.
rules.SERVER = {
    TOKENS = 2000, REFILL = 200, PER_TOKEN = 64, -- cost bucket per player: 1 + bytes / 64 per op (~12.8 KB/s)
    OPS_BURST = 40, OPS_RATE = 20,               -- ops per author: 40 at once, then 20 a second (a hand draws far less)
    BATCH = 32,                                  -- ops read from one call (more wait for the next one)
    LIVE_RATE = 5, LIVE_BYTES = 2048,            -- live ink per author and page: 5 a second, merged past that
    PUSH_MS = 100, PACKET = 49152,               -- one packet per page every 100 ms, at most 48 KB of ops in it
    SAVE_MS = 2000,                              -- one batched write every 2 s
    CHECK_MS = 10000, OPEN_SLACK = 15.0, KEEP_SLACK = 5.0, -- room rule: an open reaches 15 m past it, a subscriber keeps 5 m
    SUBS = 8,                                    -- pages one player follows at once (the oldest goes)
    RIGHTS_MS = 5000,                            -- a player's role on a board is cached this long
    IDLE_MS = 900000, SWEEP_MS = 60000,          -- a page nobody follows leaves memory after 15 min
    EVENTS = 256,                                -- recent events kept per page for gap fills
    INLINE = 49152, LATENT_BPS = 262144,         -- open replies above 48 KB go latent at 256 KB/s
    FLIGHT = 3, FLIGHT_BYTES = 2097152,          -- latent replies on their way to one player at once, and their bytes
    SAME_MS = 15000,                             -- a whole page or a picture sent to a player is not sent again this soon
    AUTHOR_SLOW = 524288, SLOW_COST = 4,         -- an author past 512 KB of unbaked ops pays 4x (only they slow down)
    VALVE = 4194304, ALARM = 8388608,            -- a page tail past 4 MB: everyone pays 4x and its heaviest authors wait
    VALVE_WAIT = 2000,                           -- for a bake; past 8 MB new ink is refused ('full'; undo, erase go on)
    CLEAR_UNDO = 1800,                           -- s a clear can be undone
}

-- capacity, refill a second: opens (and gap fills), ops calls, live chunks, clears (3, then one every 20 s), the laser.
rules.BUCKETS = { open = { 8, 1 }, ops = { 10, 6 }, live = { 10, 8 }, clear = { 3, 0.05 }, laser = { 15, 12 } }

-- Op states as stored: live, undone by its author, deleted by someone else, baked into tiles, under a clear made
-- final, an object's old version (rep).
rules.STATE = { LIVE = 0, UNDONE = 1, DELETED = 2, BAKED = 3, CLEARED = 4, STALE = 5 }

-- LiveBoard: full = the lesson's teacher, the principal, admins; limited = students called to the board.
rules.KINDS = {
    full = { 'pen', 'marker', 'brush', 'airbrush', 'eraser', 'line', 'arrow', 'rect', 'ellipse', 'del', 'undel', 'clear', 'text', 'image' },
    limited = { 'pen', 'marker', 'line', 'arrow', 'rect', 'ellipse', 'del', 'undel', 'text' },
}

-- Role -> set of kinds; a product may pass its own lists (Art Studio gives painters brushes and erasers).
function rules.kinds(custom)
    local out = {}
    for _, role in ipairs({ 'full', 'limited' }) do
        local set = {}
        for _, kind in ipairs((custom and custom[role]) or rules.KINDS[role]) do set[kind] = true end
        out[role] = set
    end
    return out
end

function rules.allows(kinds, role, kind)
    local set = (role == 'full' or role == 'limited') and kinds[role]
    return set and set[kind] == true or false
end

-- Tokens an op costs: 1 + bytes / 64, times 4 for an author with too much unbaked ink.
function rules.cost(bytes, slow)
    local S = rules.SERVER
    return (1 + bytes // S.PER_TOKEN) * (slow and S.SLOW_COST or 1)
end

-- A token bucket per key: take(key, cost, now ms) -> true, 0 | false, ms to wait. A cost above the capacity goes
-- through on a full bucket and leaves a debt, so nothing waits forever.
function rules.bucket(capacity, refill)
    local held, bucket = {}, {}
    function bucket.take(key, cost, now)
        local t = held[key]
        if not t then
            t = { capacity, now }
            held[key] = t
        end
        local tokens = math.min(capacity, t[1] + math.max(0, now - t[2]) * refill / 1000)
        t[2] = math.max(t[2], now)
        local need = math.min(cost, capacity)
        if tokens >= need then
            t[1] = tokens - cost
            return true, 0
        end
        t[1] = tokens
        return false, math.ceil((need - tokens) * 1000 / refill)
    end
    -- What a take guessed was off by delta (a reply turned out bigger: more; smaller: back); may leave a debt.
    function bucket.adjust(key, delta, now)
        local t = held[key]
        if not t or delta == 0 then return end
        local tokens = math.min(capacity, t[1] + math.max(0, now - t[2]) * refill / 1000)
        t[1], t[2] = math.min(capacity, tokens - delta), math.max(t[2], now)
    end
    function bucket.forget(key) held[key] = nil end
    return bucket
end

Ink.rules = rules
return rules
