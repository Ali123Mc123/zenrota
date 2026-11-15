-- Session kernel for pad-style NUI apps. One callback, '<prefix>:call', serves every endpoint.
--   local app = DL.pad.new({ canUse = function(source, scope, endpoint) return true end })
--   app.register('scores.get', 'read', function(source, data) return app.ok({}) end)
local pad = {}

local RATES = {
    read = { capacity = 40, refill = 4 },
    mutation = { capacity = 12, refill = 1 },
}

function pad.ok(data, revision)
    return { ok = true, data = data or {}, revision = revision }
end

function pad.fail(code)
    return { ok = false, error = code }
end

-- A refusal whose code the product's UI has no text for (errors.<code>) is stored once. The player is told the text
-- the refusal brought along (result.text), or the raw code in test mode; one notice per code every 20 s.
local toldAt = {}

local function refused(source, name, result, texts)
    local code = result.error
    if result.fault or type(code) ~= 'string' or type(DL.locale.table()[texts]) ~= 'table' then return end
    local key = ('%s.%s'):format(texts, code)
    if DL.locale.t(key) ~= key then return end
    DL.fault.missing(source, key, { endpoint = name })
    local text = type(result.text) == 'string' and result.text or (DL.fault.testing() and DL.locale.lib('fault.refused', code))
    local mark, now = ('%s:%s'):format(source, code), GetGameTimer()
    if not text or (toldAt[mark] and now - toldAt[mark] < 20000) then return end
    toldAt[mark] = now
    DL.fault.tell(source, text)
end

-- A callback that throws is stored and answers server_error with the fault's code (result.fault); the player is told the code, once
-- every 20 s per callback. For the kernel's endpoints and a product's own callbacks: pad.guarded('open', function(source) end).
function pad.guarded(place, handler)
    return function(source, ...)
        local ok, result = DL.fault.call(place, source, select('#', ...) > 0 and { ... } or nil, handler, source, ...)
        if ok then return result end
        local mark, now = ('%s:%s'):format(source, place), GetGameTimer()
        if not toldAt[mark] or now - toldAt[mark] > 20000 then
            toldAt[mark] = now
            DL.fault.tell(source, DL.fault.text(result))
        end
        return { ok = false, error = 'server_error', fault = result }
    end
end

function pad.new(options)
    local prefix = options.prefix or DL.resource
    local texts = options.texts or 'errors'
    local timeoutMs = options.timeoutMs or 90000
    local limiter = DL.ratelimit.new(options.rates or RATES)
    local sessions, count, revisions, endpoints = {}, 0, {}, {}
    local app = { ok = pad.ok, fail = pad.fail }

    -- The rate bucket outlives the session: closing and reopening must not refill it.
    local function close(source)
        if sessions[source] then
            sessions[source] = nil
            count = count - 1
        end
    end

    local function keepAlive(source)
        local session = sessions[source]
        if session then session.expires = GetGameTimer() + timeoutMs end
    end

    function app.open(source, scope)
        if not sessions[source] then count = count + 1 end
        sessions[source] = { scope = scope or 'default' }
        keepAlive(source)
    end

    app.close = close

    function app.scope(source)
        local session = sessions[source]
        return session and session.scope
    end

    -- Session, permission and rate limit; returns a failure or nil.
    function app.guard(source, endpoint, rate)
        local session = sessions[source]
        if not session then return pad.fail('session_expired') end
        if options.canUse and not options.canUse(source, session.scope, endpoint) then return pad.fail('no_permission') end
        if not limiter.take(source, rate or 'read') then return pad.fail('rate_limited') end
        keepAlive(source)
    end

    function app.register(name, rate, handler)
        endpoints[name] = { rate = rate, handler = pad.guarded(name, handler) }
    end

    lib.callback.register(prefix .. ':call', function(source, name, data)
        local endpoint = endpoints[name]
        if not endpoint then return pad.fail('not_found') end
        local denied = app.guard(source, name, endpoint.rate)
        if denied then return denied end
        local result = endpoint.handler(source, type(data) == 'table' and data or {})
        if type(result) == 'table' and result.ok == false then refused(source, name, result, texts) end
        return result
    end)

    local function nextRevision(topic)
        revisions[topic] = (revisions[topic] or 0) + 1
        return revisions[topic]
    end

    local function send(source, topic, revision, payload)
        TriggerClientEvent(prefix .. ':sync', source, { topic = topic, revision = revision, payload = payload })
    end

    function app.publish(topic, payload)
        local revision = nextRevision(topic)
        for source in pairs(sessions) do send(source, topic, revision, payload) end
        return revision
    end

    function app.publishTo(sources, topic, payload)
        local revision = nextRevision(topic)
        for _, source in ipairs(sources or {}) do send(source, topic, revision, payload) end
        return revision
    end

    -- Builds the payload per player, so secrets stay with their owner.
    function app.publishEach(sources, topic, build)
        local revision = nextRevision(topic)
        for _, source in ipairs(sources or {}) do
            local ok, payload = pcall(build, source)
            if ok and payload ~= nil then send(source, topic, revision, payload) end
        end
        return revision
    end

    RegisterNetEvent(prefix .. ':heartbeat', function() keepAlive(source) end)
    RegisterNetEvent(prefix .. ':close', function() close(source) end)
    AddEventHandler('playerDropped', function()
        close(source)
        limiter.forget(source)
        local own = ('%s:'):format(source)
        for mark in pairs(toldAt) do
            if mark:sub(1, #own) == own then toldAt[mark] = nil end
        end
    end)

    CreateThread(function()
        while true do
            Wait(15000)
            local now = GetGameTimer()
            for source, session in pairs(sessions) do
                if count > 0 and now > session.expires then close(source) end
            end
        end
    end)

    return app
end

-- Per-character preferences shared by every pad: wallpaper, sound...
function pad.getPrefs(owner)
    local out = {}
    for _, row in ipairs(MySQL.query.await('SELECT pref_key, value FROM daddy_lib_prefs WHERE owner = ?', { owner }) or {}) do
        out[row.pref_key] = row.value
    end
    return out
end

function pad.setPref(owner, key, value)
    MySQL.insert.await([[
        INSERT INTO daddy_lib_prefs (owner, pref_key, value) VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE value = VALUES(value)
    ]], { owner, key, value })
end

function pad.clearPref(owner, key)
    MySQL.update.await('DELETE FROM daddy_lib_prefs WHERE owner = ? AND pref_key = ?', { owner, key })
end

return pad
