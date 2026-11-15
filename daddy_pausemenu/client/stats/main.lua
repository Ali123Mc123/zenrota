-- Stats client: reads GTA's own counters (MP0_*, FiveM keeps them for one session), sends what grew every minute,
-- and serves the stats screen: the server's totals plus what this session has not sent yet.
local cfg = Config.Stats or {}
local PUSH = math.max(15, tonumber(cfg.PushInterval) or 60) * 1000
local GAP = 12000 -- opening the screen sends pending stats first, at most this often (the server allows one per 10 s)
local now = GetGameTimer

-- Shared by the stats files: cid (character being counted), skills (server values), ready (server has them).
PM.Stats = { cid = nil, skills = {}, ready = false }

-- MP0_<name> hashes of every stat read or written (skills.lua uses them too), made once.
local HASH, last = {}, {}
for _, d in ipairs(PMStats.TRACK) do HASH[d[1]] = GetHashKey('MP0_' .. d[1]) end
for _, name in ipairs(PMStats.SKILLS) do HASH[name] = GetHashKey('MP0_' .. name) end
PM.Stats.hash = HASH
local lastPush, cache, fetchedAt, liveToken = 0, nil, 0, nil
local loggedOut = false -- between a logout and the next character load nothing starts counting

local function read(d)
    if d[2] == 'f' then
        local ok, v = StatGetFloat(HASH[d[1]], -1)
        return ok and v or 0.0
    end
    local ok, v = StatGetInt(HASH[d[1]], -1)
    return ok and v or 0
end

-- What grew since the last push (sums), the session's best values (records) and the engine values now.
local function pending()
    local delta, records, cur = {}, {}, {}
    for _, d in ipairs(PMStats.TRACK) do
        local name, v = d[1], read(d)
        cur[name] = v
        if d[3] == 'sum' then
            local grew = v - (last[name] or v)
            if grew > 0 then delta[name] = grew end
        elseif v > 0 then
            records[name] = v
        end
    end
    for name, v in pairs(PM.Stats.own) do
        if v > 0 then records[name] = v end
    end
    return delta, records, cur
end

-- Sends the minute's growth. A counter another script reset (it shrank) simply restarts from its new value.
local function flush()
    if not PM.Stats.cid then return end
    if not PM.Stats.ready then TriggerServerEvent('daddy_pausemenu:stats:ready') end
    local delta, records, cur = pending()
    for _, d in ipairs(PMStats.TRACK) do
        if d[3] == 'sum' then last[d[1]] = cur[d[1]] end
    end
    if cache then
        for name, v in pairs(delta) do cache[name] = (cache[name] or 0) + v end
    end
    lastPush = now()
    TriggerServerEvent('daddy_pausemenu:stats:push', delta, records, PM.Stats.TakeEvents())
    PM.Stats.Enforce()
end

-- A character came in (or the resource restarted under one): counting starts from the engine's values now.
local function begin()
    local cid = DL.fw.citizenId()
    if not cid or cid == PM.Stats.cid then return end
    PM.Stats.cid, PM.Stats.ready, cache = cid, false, nil
    for _, d in ipairs(PMStats.TRACK) do last[d[1]] = read(d) end
    PM.Stats.ResetOwn()
    -- The first push comes 15 s to PUSH from now: after a restart the clients do not all push in the same second.
    lastPush = now() - math.random(0, math.floor(PUSH - 15000))
    TriggerServerEvent('daddy_pausemenu:stats:ready')
end

DL.fw.onLoaded(function()
    loggedOut = false
    -- The id can land a moment after the event, and the loop below may be asleep until the old push: retry here.
    CreateThread(function()
        for _ = 1, 10 do
            begin()
            if PM.Stats.cid or loggedOut or DL.fw.id == 'standalone' then return end
            Wait(1000)
        end
    end)
end)

DL.fw.onUnloaded(function()
    flush()
    loggedOut = true
    PM.Stats.cid, PM.Stats.ready, PM.Stats.skills, cache = nil, false, {}, nil
end)

CreateThread(function()
    DL.fw.awaitLogin()
    begin()
    -- Standalone has no character id: nothing is counted, so there is no login to wait for either.
    if not PM.Stats.cid and DL.fw.id == 'standalone' then return end
    while true do
        -- Counting: sleep until the push is due (an earlier push moves it; the check below then sleeps on).
        Wait(PM.Stats.cid and math.max(1000, lastPush + PUSH - now()) or 1000)
        if not PM.Stats.cid and not loggedOut and DL.fw.isLoggedIn() then begin() end
        if PM.Stats.cid and now() - lastPush >= PUSH then flush() end
    end
end)

-- The page's data: cached totals + this session's growth; the clocks run on from the last fetch.
local function snapshot()
    local values = {}
    for k, v in pairs(cache or {}) do values[k] = v end
    local delta, records = pending()
    for k, v in pairs(delta) do values[k] = (tonumber(values[k]) or 0) + v end
    for k, v in pairs(records) do values[k] = math.max(tonumber(values[k]) or 0, v) end
    local since = now() - fetchedAt
    values.SESSION = (tonumber(values.SESSION) or 0) + since
    values.PLAY_TIME = (tonumber(values.PLAY_TIME) or 0) + since
    if (cfg.Skills or {}).Enabled == false then
        -- Another resource owns the skills: show what the engine has.
        for _, name in ipairs(PMStats.SKILLS) do
            local ok, v = StatGetInt(HASH[name], -1)
            values[name] = ok and v or 0
        end
    end
    local data = PMStats.build(values, cfg)
    data.metric = ShouldUseMetricMeasurements()
    return data
end

local function fetch()
    if not PM.Stats.cid then return nil, 'not_loaded' end
    if now() - lastPush >= GAP then flush() end
    local result = lib.callback.await('daddy_pausemenu:stats:get', false)
    if type(result) == 'table' and result.ok and type(result.data) == 'table' then
        cache, fetchedAt = result.data, now()
    elseif not cache then
        return nil, type(result) == 'table' and result.error or 'generic'
    end
    return snapshot()
end

PM.Callback('pm:stats:load', function()
    local data, err = fetch()
    if not data then return { ok = false, error = err } end
    return { ok = true, data = data }
end)

-- While the screen shows, rows follow play every few seconds (only the tabs that changed travel).
PM.RegisterScreen('stats', {
    enter = function()
        local token, session = {}, PM.Session()
        liveToken = token
        CreateThread(function()
            local sent = {}
            while liveToken == token and PM.IsOpen() and PM.Screen() == 'stats' and PM.Session() == session do
                Wait(5000)
                if cache and liveToken == token and PM.Screen() == 'stats' then
                    local data, tabs = snapshot(), {}
                    for _, tab in ipairs(data.tabs) do
                        local encoded = json.encode(tab.rows)
                        if sent[tab.id] ~= encoded then sent[tab.id], tabs[#tabs + 1] = encoded, tab end
                    end
                    PM.Send('pm:stats:update', { tabs = tabs, records = data.records, career = data.career, metric = data.metric })
                end
            end
        end)
    end,
    leave = function() liveToken = nil end,
})
