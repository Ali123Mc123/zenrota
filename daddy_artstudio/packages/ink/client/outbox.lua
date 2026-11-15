-- Ink outbox (6-tahta-video-sanat.md 3.2, write path): every op this client writes (strokes, shapes, undo, redo,
-- erase, clear) goes through one queue per page, in order, as plain <event>:ops calls. One call at a time: the next
-- leaves when the server answered every op of the last (the push brings its seq back, or a nack), so a slowed op is
-- never overtaken by a later one. The client keeps to 8 KB/s with a 64 KB burst on its own; past the server's rate
-- ('slow') or with no free pen ('wait') ops wait the time the server names and go again with the same key. An op
-- without an answer goes again after 5 s (the server applies a key once). Nothing is dropped for being fast; only a
-- real refusal (no right, a broken op, too far, an expired clear) drops an op, with its reason.
--   local box = Ink.outbox({ event = 'res:ink', open = function(page) end, reopen = function(page) end, onDrop = ..., onCount = ... })
Ink = Ink or {}

function Ink.outbox(opts)
    local codec, R = Ink.codec, Ink.rules.CLIENT
    local E = opts.event
    local box = {}
    local queues = {} -- page id -> { list = { { ck, d } }, sent = { [ck] = true } | nil, sentAt, pause, state }
    local bytes = Ink.rules.bucket(R.BURST, R.RATE)
    local running = false
    local KEEP = { slow = true, wait = true, closed = true }

    local function now() return GetGameTimer() end

    local function queueOf(page)
        local q = queues[page]
        if not q then
            q = { list = {}, pause = 0, state = 'ok' }
            queues[page] = q
        end
        return q
    end

    local function count(page, q)
        if opts.onCount then opts.onCount(page, #q.list, q.state) end
    end

    local function indexOf(q, ck)
        for i, entry in ipairs(q.list) do
            if entry[1] == ck then return i end
        end
    end

    -- The call in flight is answered once none of its ops waits for an answer.
    local function settle(q)
        if not q.sent then return end
        for ck in pairs(q.sent) do
            if indexOf(q, ck) then return end
        end
        q.sent = nil
    end

    local function send(page, q, t)
        if #q.list == 0 or q.sent or t < q.pause or not opts.open(page) then return end
        local batch, size, keys = {}, 0, {}
        for i = 1, math.min(#q.list, R.BATCH_OPS) do
            local entry = q.list[i]
            if i > 1 and size + #entry[2] > R.BATCH_BYTES then break end
            batch[i], size, keys[entry[1]] = { entry[1], entry[2] }, size + #entry[2], true
        end
        local fine, wait = bytes.take('up', size, t)
        if not fine then
            q.pause, q.state = t + wait, 'slow'
            return count(page, q)
        end
        q.sent, q.sentAt = keys, t
        if q.state == 'slow' or q.state == 'wait' then q.state = 'ok' end
        TriggerServerEvent(E .. ':ops', page, batch)
    end

    local function loop()
        if running then return end
        running = true
        CreateThread(function()
            while next(queues) do
                local t = now()
                for page, q in pairs(queues) do
                    if q.sent and t - q.sentAt >= R.RESEND_MS then q.sent = nil end -- no answer: the same keys go again
                    send(page, q, t)
                    if #q.list == 0 and not q.sent then queues[page] = nil end
                end
                Wait(50)
            end
            running = false
        end)
    end

    -- Ops from the editor, in its order: { { ck, d }, ... }. A malformed one is dropped at once with its reason.
    function box.add(page, list)
        if type(page) ~= 'number' or type(list) ~= 'table' then return end
        local q = queueOf(page)
        local bad = {}
        for _, entry in ipairs(list) do
            local ck, d = type(entry) == 'table' and entry[1], type(entry) == 'table' and entry[2]
            if codec.isKey(ck) and ck:byte(1) ~= 95 and type(d) == 'string' and #d > 0 and #d <= codec.MAX_B64 then
                if not indexOf(q, ck) then q.list[#q.list + 1] = { ck, d } end
            elseif codec.isKey(ck) then
                bad[#bad + 1] = ck
            end
        end
        if #bad > 0 and opts.onDrop then opts.onDrop(page, bad, 'bad') end
        count(page, q)
        loop()
    end

    -- A push: own ops that came back are done. me: this client's author number on the page (nil: match keys alone).
    -- Returns the author number seen on an own op (the caller learns it).
    function box.ack(page, ops, me)
        local q = queues[page]
        if not q or type(ops) ~= 'table' then return nil end
        local seen, changed = nil, false
        for _, op in ipairs(ops) do
            local ck, a = type(op) == 'table' and op[3], type(op) == 'table' and op[2]
            local at = ck and indexOf(q, ck)
            if at and (me == nil or a == me) then
                table.remove(q.list, at)
                seen, changed = a, true
            end
        end
        if changed then
            settle(q)
            if q.state ~= 'slow' and q.state ~= 'wait' then q.state = 'ok' end
            count(page, q)
        end
        return seen
    end

    -- Refusals of the last call: { { ck, code, extra } }.
    function box.nack(page, list)
        local q = queues[page]
        if not q or type(list) ~= 'table' then return end
        local t = now()
        local dropped = {}
        for _, n in ipairs(list) do
            local ck, code, extra = n[1], n[2], n[3]
            local at = indexOf(q, ck)
            if at then
                if KEEP[code] then
                    if code ~= 'closed' then q.pause = math.max(q.pause, t + math.max(50, math.min(30000, tonumber(extra) or 1000))) end
                    q.state = code
                else
                    table.remove(q.list, at)
                    if code ~= 'dup' then
                        dropped[code] = dropped[code] or { keys = {}, extra = extra }
                        local keys = dropped[code].keys
                        keys[#keys + 1] = ck
                    end
                end
                if q.sent then q.sent[ck] = nil end
            end
        end
        settle(q)
        if q.sent and next(q.sent) == nil then q.sent = nil end
        if q.state == 'closed' and opts.reopen then opts.reopen(page) end
        for code, drop in pairs(dropped) do
            if opts.onDrop then opts.onDrop(page, drop.keys, code, drop.extra) end
        end
        count(page, q)
        loop()
    end

    -- The page is open again (after 'closed' or a reconnect): what waits goes now.
    function box.opened(page)
        local q = queues[page]
        if not q then return end
        if q.state == 'closed' then q.state = 'ok' end
        q.sent = nil
        count(page, q)
        loop()
    end

    function box.count(page)
        local q = queues[page]
        return q and #q.list or 0, q and q.state or 'ok'
    end

    -- Everything waiting for a page goes (the board was removed); returns the keys dropped.
    function box.forget(page)
        local q = queues[page]
        queues[page] = nil
        local out = {}
        for i, entry in ipairs(q and q.list or {}) do out[i] = entry[1] end
        return out
    end

    return box
end

return Ink.outbox
