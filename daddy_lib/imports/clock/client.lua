-- Server time on a client: daddy_lib's one sampler (services/client/clock.lua), learnt by export once and by event
-- after every round. While it has nothing (daddy_lib down or still sampling) the time a server packet carried stands in.
local clock = {}
local info, hint, asked

local function take(data)
    if type(data) ~= 'table' or type(data.offset) ~= 'number' then return end
    if data.mode == 'network' or data.mode == 'sampled' then info = data end
end

AddEventHandler('daddy_lib:clock', take)

-- At most every 5 s while the sampler is unknown; a stopped daddy_lib only costs a failed call.
local function ask()
    local t = GetGameTimer()
    if asked and t - asked < 5000 then return end
    asked = t
    local done, data = pcall(function() return exports.daddy_lib:ClockInfo() end)
    if done then take(data) end
end

-- Server ms now.
function clock.now()
    if not info then ask() end
    if info then
        if info.mode == 'network' then return GetNetworkTimeAccurate() end
        return GetGameTimer() + info.offset
    end
    return GetGameTimer() + (hint or 0)
end

-- The server's time a packet carried: a rough clock (no round trip in it) until the sampler answers.
function clock.hint(serverMs)
    if type(serverMs) == 'number' then hint = serverMs - GetGameTimer() end
end

-- True once daddy_lib's sampler has a time.
function clock.ready()
    if not info then ask() end
    return info ~= nil
end

-- mode ('network' | 'sampled'), offset, trip, samples, at; nil before the first round.
function clock.info()
    return info
end

return clock
