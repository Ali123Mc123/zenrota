-- Media timelines: what a screen plays, as plain data with the same rules on the server, the client and the page.
-- TS twin: daddy_lib/web/packages/media-kit/src/timeline.ts; both run docs/yeni-sistemler/tests/tahta/timeline-cases.json.
-- Times are server ms (GetGameTimer on the server, DL.clock.now on a client), positions are seconds.
--   state = { rev, item = { id, dur, start, live, still }, play = 'idle'|'playing'|'paused'|'ended', anchor, pos,
--             after = 'stop'|'loop'|'next', error }
-- The functions that change a state change the table given, bump its rev and return it; nil means refused.
local timeline = {}

timeline.LEAD = 1500  -- a show starts this long after it is sent: everyone loads, then all start at one server ms
timeline.RESUME = 600 -- seeks and resumes start this long ahead
timeline.MAX = 10800  -- 3 h: the longest length, and how far a seek goes while the length is unknown

local WRAP, HALF = 4294967296, 2147483648

-- a - b in ms, right across a 32-bit timer wrap (for times less than 24 days apart).
function timeline.diff(a, b)
    return (a - b + HALF) % WRAP - HALF
end

-- A number from a player or a row, or nil (text, NaN).
local function num(value)
    value = tonumber(value)
    if value ~= value then return nil end
    return value
end

-- A length: 1 s .. 3 h, or nil when unknown (none, 0, below 0, text).
function timeline.length(value)
    value = num(value)
    if not value or value <= 0 then return nil end
    return math.min(math.max(value, 1), timeline.MAX)
end

-- The length that ends the item, or nil: live and unknown ones run on, a still picture ends only in a playlist.
local function span(state)
    local item = state.item
    if not item or item.live or (item.still and state.after ~= 'next') then return nil end
    local dur = item.dur
    if type(dur) ~= 'number' or dur <= 0 then return nil end
    return dur
end

-- Seconds into the item at server time now: held until the anchor, never past the end (live is not clamped).
function timeline.position(state, now)
    local item = state and state.item
    if not item then return 0 end
    local pos = state.pos or 0
    if state.play == 'playing' then pos = pos + math.max(0, timeline.diff(now, state.anchor)) / 1000 end
    if pos < 0 then return 0 end
    if item.live then return pos end
    local cap = type(item.dur) == 'number' and item.dur > 0 and item.dur or timeline.MAX
    return math.min(pos, cap)
end

-- Server ms when a playing item reaches its end, or nil.
function timeline.endsAt(state)
    if not state or state.play ~= 'playing' then return nil end
    local dur = span(state)
    if not dur then return nil end
    return state.anchor + math.floor((dur - (state.pos or 0)) * 1000 + 0.5)
end

-- ms left until the end (0 or less once it is due), or nil when nothing ends.
function timeline.left(state, now)
    local at = timeline.endsAt(state)
    if not at then return nil end
    return timeline.diff(at, now)
end

function timeline.due(state, now)
    local left = timeline.left(state, now)
    return left ~= nil and left <= 0
end

-- Where a seek may go: 0 .. the last second (3 h while the length is unknown); nil for live or a bad value.
function timeline.seekable(state, value)
    local item = state and state.item
    value = num(value)
    if not item or item.live or not value then return nil end
    local last = type(item.dur) == 'number' and item.dur > 0 and math.max(0, item.dur - 1) or timeline.MAX
    return math.max(0, math.min(last, value))
end

local function bump(state)
    state.rev = (state.rev or 0) + 1
    return state
end

-- Shows an item from its start second, LEAD ms from now.
function timeline.show(state, item, now)
    state.item, state.play, state.error = item, 'playing', nil
    state.pos = timeline.seekable(state, item.start or 0) or 0
    state.anchor = now + timeline.LEAD
    return bump(state)
end

-- Nothing on the screen.
function timeline.stop(state)
    state.item, state.play, state.pos, state.anchor, state.error = nil, 'idle', 0, 0, nil
    return bump(state)
end

-- Holds a playing item at the second it reached.
function timeline.pause(state, now)
    if not state.item or state.play ~= 'playing' then return nil end
    state.pos, state.play, state.anchor = timeline.position(state, now), 'paused', now
    return bump(state)
end

-- Goes on from the held second; an ended item plays again from 0.
function timeline.resume(state, now)
    if not state.item or (state.play ~= 'paused' and state.play ~= 'ended') then return nil end
    if state.play == 'ended' then state.pos = 0 end
    state.play, state.anchor, state.error = 'playing', now + timeline.RESUME, nil
    return bump(state)
end

-- Moves to a second: a playing item goes on from there RESUME ms ahead, anything else waits there paused.
function timeline.seek(state, seconds, now)
    local to = timeline.seekable(state, seconds)
    if not to then return nil end
    state.pos, state.error = to, nil
    if state.play == 'playing' then
        state.anchor = now + timeline.RESUME
    else
        state.play, state.anchor = 'paused', now
    end
    return bump(state)
end

-- seconds back (below 0) or ahead of where the item is now.
function timeline.skip(state, seconds, now)
    seconds = num(seconds)
    if not seconds or not state.item then return nil end
    return timeline.seek(state, timeline.position(state, now) + seconds, now)
end

-- The end of a playing item, once it is due: loop starts again at 0 from the exact end, next shows the following
-- item (nil when the list is over), stop holds the last second as ended.
function timeline.finish(state, now, nextItem)
    local at = timeline.endsAt(state)
    if not at then return nil end
    local dur = span(state)
    if state.after == 'loop' then
        local ms = math.max(1, math.floor(dur * 1000 + 0.5))
        local late = math.max(0, timeline.diff(now, at))
        state.pos, state.anchor = 0, at + (late // ms) * ms
        return bump(state)
    end
    if state.after == 'next' and nextItem then return timeline.show(state, nextItem, now) end
    state.play, state.pos, state.anchor = 'ended', dur, at
    return bump(state)
end

-- A broken item: held at the second it reached, ended with the reason.
function timeline.fail(state, code, now)
    if not state.item then return nil end
    state.pos, state.play, state.anchor, state.error = timeline.position(state, now), 'ended', now, code
    return bump(state)
end

-- After a restart: the saved item paused at its saved second (an ended one stays ended).
function timeline.restore(state, item, pos, play, now)
    state.item, state.error, state.anchor = item, nil, now
    if play == 'ended' and type(item.dur) == 'number' and item.dur > 0 and not item.live then
        state.play, state.pos = 'ended', item.dur
    else
        state.play, state.pos = 'paused', timeline.seekable(state, pos) or 0
    end
    return bump(state)
end

-- The list index after the current item: the next one, the first when the current one is not in the list, nil after
-- the last (wrap: the first again, for a manual next).
function timeline.nextIndex(ids, current, wrap)
    local n = #ids
    if n == 0 then return nil end
    for i = 1, n do
        if ids[i] == current then
            if i < n then return i + 1 end
            return wrap and 1 or nil
        end
    end
    return 1
end

-- The list index before the current item, the last one when it is the first or not in the list.
function timeline.prevIndex(ids, current)
    local n = #ids
    if n == 0 then return nil end
    for i = 1, n do
        if ids[i] == current then return i > 1 and i - 1 or n end
    end
    return n
end

return timeline
