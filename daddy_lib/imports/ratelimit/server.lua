-- Token buckets per player and kind: { read = { capacity = 40, refill = 4 } }. take() costs 1 token unless told
-- (since 1.16.0: take(source, kind, cost), e.g. 1 + bytes / 64); a refusal says how many ms until it would pass. A
-- cost above the capacity passes on a full bucket and leaves a debt, so nothing waits forever.
local ratelimit = {}

function ratelimit.new(rules)
    local buckets = {}
    local limiter = {}

    local function bucketOf(source, kind, rule, now)
        buckets[source] = buckets[source] or {}
        local bucket = buckets[source][kind] or { tokens = rule.capacity, at = now }
        buckets[source][kind] = bucket
        bucket.tokens = math.min(rule.capacity, bucket.tokens + (now - bucket.at) * rule.refill)
        bucket.at = now
        return bucket
    end

    local function waitFor(rule, tokens, need)
        if rule.refill <= 0 then return math.huge end
        return math.ceil((need - tokens) * 1000 / rule.refill)
    end

    -- true, or false and the ms until it would pass.
    function limiter.take(source, kind, cost)
        local rule = rules[kind]
        if not rule then return true end
        cost = math.max(0, tonumber(cost) or 1)
        local bucket = bucketOf(source, kind, rule, GetGameTimer() / 1000)
        local need = math.min(cost, rule.capacity)
        if bucket.tokens < need then return false, waitFor(rule, bucket.tokens, need) end
        bucket.tokens = bucket.tokens - cost
        return true
    end

    -- ms until take(source, kind, cost) would pass (0: now); nothing is taken.
    function limiter.wait(source, kind, cost)
        local rule = rules[kind]
        if not rule then return 0 end
        cost = math.max(0, tonumber(cost) or 1)
        local bucket = bucketOf(source, kind, rule, GetGameTimer() / 1000)
        local need = math.min(cost, rule.capacity)
        if bucket.tokens >= need then return 0 end
        return waitFor(rule, bucket.tokens, need)
    end

    function limiter.forget(source)
        buckets[source] = nil
    end

    return limiter
end

return ratelimit
