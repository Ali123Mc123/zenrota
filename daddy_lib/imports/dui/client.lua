-- DUI leases from the shared budget; onRevoke runs if another surface takes the slot.
local dui = {}
local handlers = {}

AddEventHandler('daddy_lib:dui:revoke', function(resource, id)
    local handler = resource == DL.resource and handlers[id]
    handlers[id] = nil
    if handler then handler() end
end)

-- Also refreshes the distance of a lease already held. options (since 1.16.0): { width, height, priority } for the
-- megapixel budget; an older service takes the lease without them.
function dui.acquire(id, distance, onRevoke, options)
    local granted = exports.daddy_lib:acquireDui(id, distance, options)
    if granted and onRevoke then handlers[id] = onRevoke end
    return granted
end

function dui.release(id)
    handlers[id] = nil
    exports.daddy_lib:releaseDui(id)
end

-- A page parked on about:blank keeps its lease but gives way first (an older service: a far distance does the same).
function dui.park(id)
    local done = pcall(function() return exports.daddy_lib:parkDui(id) end)
    if not done then exports.daddy_lib:acquireDui(id, 1e9) end
end

-- A runtime texture dictionary name used once this session: CreateRuntimeTxd binds a name to the first DUI only.
local START, named = ('%x'):format(GetGameTimer()), 0
function dui.name(prefix)
    local done, name = pcall(function() return exports.daddy_lib:duiName(prefix) end)
    if done and type(name) == 'string' then return name end
    named = named + 1
    return ('%s_%s_%d'):format(prefix, START, named)
end

-- Blank first, destroyed a frame later, so CEF lets go of the page cleanly; now: both at once (a stop has no frame).
function dui.retire(handle, now)
    if not handle then return end
    SetDuiUrl(handle, 'about:blank')
    if now then return DestroyDui(handle) end
    SetTimeout(0, function() DestroyDui(handle) end)
end

-- The video decoder lease (since 1.15.0; one for every product, daddy:dui_video): ask with a score every tick (in the
-- room +100, playing +50, -1 a metre); true while held. Without the lib's service a local lease of one slot stands in.
local fallback
function dui.video(id, score)
    local done, held = pcall(function() return exports.daddy_lib:videoLease(id, score) end)
    if done then return held == true end
    fallback = fallback or dui.arbiter({ slots = 1 })
    return fallback.want(id, score, GetGameTimer())
end

function dui.videoRelease(id)
    if fallback then fallback.drop(id, GetGameTimer()) end
    pcall(function() exports.daddy_lib:videoRelease(id) end)
end

return dui
