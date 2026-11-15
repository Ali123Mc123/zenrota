-- One DUI budget for every product (6-tahta-video-sanat.md 3.6, v2): at most daddy:dui_max pages (10) and
-- daddy:dui_mpx megapixels of them (8). When it is full a parked page gives way first, then the farthest page that is
-- at least 5 s old and that the newcomer is 30 % closer than (or of lower priority); nothing else gives way, so two
-- boards never take a page from each other back and forth. A page without a size counts half a megapixel.
local MAX = GetConvarInt('daddy:dui_max', 10)
local MPX = GetConvarInt('daddy:dui_mpx', 8) * 1000000
local YOUNG_MS, CLOSER, PARKED, UNSIZED = 5000, 0.7, 1e8, 500000
local leases, count, pixels = {}, 0, 0
local START, named = ('%x'):format(GetGameTimer()), 0

local function key(resource, id) return resource .. '|' .. id end

local function drop(k)
    local lease = leases[k]
    if lease then count, pixels = count - 1, pixels - lease.pixels end
    leases[k] = nil
end

local function sizeOf(o)
    local w, h = type(o) == 'table' and tonumber(o.width), type(o) == 'table' and tonumber(o.height)
    return (w and h and w > 0 and h > 0) and math.floor(w * h) or UNSIZED
end

-- Who gives way to a newcomer: parked first (the longest parked), then the farthest old enough and far enough.
local function victim(distance, priority, now)
    local best, bestParked, bestDistance
    for k, lease in pairs(leases) do
        local parked = lease.parked or lease.distance >= PARKED
        local eligible = parked or (now - lease.at >= YOUNG_MS and (lease.priority < priority or distance <= lease.distance * CLOSER))
        if eligible then
            local better = not best or (parked and not bestParked) or (parked == bestParked and lease.distance > bestDistance)
            if better then best, bestParked, bestDistance = k, parked, lease.distance end
        end
    end
    return best
end

-- acquire(id, distance, { width, height, priority }) -> granted. The same id again renews it (distance, size).
exports('acquireDui', function(id, distance, options)
    local resource = GetInvokingResource()
    local k = key(resource, id)
    distance = tonumber(distance) or 0
    local now = GetGameTimer()
    local lease = leases[k]
    if lease then
        lease.distance, lease.parked = distance, distance >= PARKED
        if type(options) == 'table' then
            local size = sizeOf(options)
            pixels, lease.pixels = pixels - lease.pixels + size, size
            lease.priority = tonumber(options.priority) or lease.priority
        end
        return true
    end
    local size, priority = sizeOf(options), type(options) == 'table' and tonumber(options.priority) or 0
    while count >= MAX or (pixels + size > MPX and count > 0) do
        local far = victim(distance, priority, now)
        if not far then return false end
        local other = leases[far]
        drop(far)
        TriggerEvent('daddy_lib:dui:revoke', other.resource, other.id)
    end
    leases[k] = { resource = resource, id = id, distance = distance, pixels = size, priority = priority, at = now, parked = distance >= PARKED }
    count, pixels = count + 1, pixels + size
    return true
end)

exports('releaseDui', function(id)
    drop(key(GetInvokingResource(), id))
end)

-- A page on about:blank keeps its lease but is the first to give way.
exports('parkDui', function(id)
    local lease = leases[key(GetInvokingResource(), id)]
    if lease then lease.parked = true end
    return lease ~= nil
end)

-- A runtime texture dictionary name nobody used this session (a dictionary binds to the first DUI made under it).
exports('duiName', function(prefix)
    named = named + 1
    return ('%s_%s_%d'):format(tostring(prefix or 'dui'), START, named)
end)

exports('duiBudget', function() return MAX - count, MAX, MPX - pixels, MPX end)

-- Video decoders for every product (daddy:dui_video, 1): screens ask with a score each tick (imports/dui/shared.lua).
local SELF = GetCurrentResourceName()
local ARBITER = assert(load(LoadResourceFile(SELF, 'imports/dui/shared.lua'), ('@@%s/imports/dui/shared.lua'):format(SELF)))()
local video = ARBITER.arbiter({ slots = GetConvarInt('daddy:dui_video', 1) })

exports('videoLease', function(id, score)
    return video.want(key(GetInvokingResource(), id), score, GetGameTimer())
end)

exports('videoRelease', function(id)
    video.drop(key(GetInvokingResource(), id), GetGameTimer())
end)

exports('videoBudget', function() return video.count() end)

AddEventHandler('onClientResourceStop', function(resource)
    for k, lease in pairs(leases) do
        if lease.resource == resource then drop(k) end
    end
    local prefix = resource .. '|'
    video.dropWhere(function(k) return k:sub(1, #prefix) == prefix end, GetGameTimer())
end)
