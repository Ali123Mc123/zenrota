-- One server clock for every product on this client (imports/clock): 5 pings 200 ms apart, the shortest round trip
-- wins; a new round every 5 min and after the game froze (its timer drifted from the wall clock). The engine's
-- GetNetworkTimeAccurate() is used instead when it agrees with that sample within 20 ms.
local RESOURCE = GetCurrentResourceName()
local C = assert(load(LoadResourceFile(RESOURCE, 'imports/clock/shared.lua'), ('@@%s/imports/clock/shared.lua'):format(RESOURCE)))()

local info = { mode = 'none', offset = 0 }
local pending, seq = {}, 0

RegisterNetEvent('daddy_lib:clock:pong', function(id, server)
    local entry = pending[id]
    if not entry or type(server) ~= 'number' then return end
    pending[id] = nil
    local sample = C.sample(entry.sent, GetGameTimer(), server)
    sample.agree = C.agrees(GetNetworkTimeAccurate(), server + sample.trip / 2, C.AGREE)
    entry.round[#entry.round + 1] = sample
end)

-- One round; false when no answer came back.
local function round()
    local samples = {}
    for _ = 1, C.SAMPLES do
        seq = seq + 1
        pending[seq] = { sent = GetGameTimer(), round = samples }
        TriggerServerEvent('daddy_lib:clock:ping', seq)
        Wait(C.GAP)
    end
    local waited = 0
    while #samples < C.SAMPLES and waited < C.TIMEOUT do
        Wait(100)
        waited = waited + 100
    end
    pending = {}
    local best = C.best(samples)
    if not best then return false end
    info = {
        mode = best.agree and 'network' or 'sampled', offset = best.offset, trip = best.trip,
        samples = #samples, at = GetGameTimer(),
    }
    TriggerEvent('daddy_lib:clock', info)
    return true
end

-- Server ms now; the own timer until the first round is back.
exports('ServerNow', function()
    if info.mode == 'network' then return GetNetworkTimeAccurate() end
    return GetGameTimer() + info.offset
end)

-- mode ('none' | 'network' | 'sampled'), offset, trip, samples, at.
exports('ClockInfo', function()
    return info
end)

-- A random wait first: after a restart every client pings at once otherwise.
CreateThread(function()
    Wait(math.random(0, 2000))
    while true do
        local wait = round() and C.EVERY or C.RETRY
        local last, game, cloud = GetGameTimer(), GetGameTimer(), GetCloudTimeAsInt()
        repeat
            Wait(C.CHECK)
        until C.diff(GetGameTimer(), last) >= wait or C.drifted(game, cloud, GetGameTimer(), GetCloudTimeAsInt(), C.FREEZE)
    end
end)
