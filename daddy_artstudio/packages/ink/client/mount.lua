-- Ink on the client (6-tahta-video-sanat.md 3.2, reading and sync): the boards this player stands with. Entering a
-- board's room opens its live page (<event>:open with the rev the cache holds, so a return costs nothing or the few
-- events missed); leaving it closes the page 3 s later (2 m slack), and the page stays in the cache (the last 3
-- boards). Pushes are applied in order: another epoch opens the page again from nothing, a gap opens it again from
-- our rev; never the whole page for a gap. A page keeps its baked base (P3): a bake takes its old ops out of the cache
-- and the pages showing it fold them into their ground. A board out of its room but in sight is drawn from its last
-- thumbnail (statics.lua), no page opened. The DUI pool, the outbox and the editor hear every change. One loop for
-- every board, 500 ms near one and 2 s otherwise; nothing runs per frame here.
--   local ink = Ink.client({ event = 'res:ink', inside = function(board, coords, slack) end, surfaces = { ... }, statics = 24 })
--   ink.set(boards)  -- { [uid] = { coords, heading, width, height, background, ... } }, from the product's list
Ink = Ink or {}

function Ink.client(opts)
    local codec = Ink.codec
    local E = opts.event or (GetCurrentResourceName() .. ':ink')
    local KEEP, LEAVE_MS, SLACK, NEAR, FAR = 3, 3000, 2.0, 60.0, 30.0
    local client = { boards = {}, models = {}, mounted = {}, byBoard = {}, event = E }
    local models, mounted, byBoard = client.models, client.mounted, client.byBoard
    local leaving, asked, retries = {}, {}, {} -- uid -> ms it left; req -> uid; uid -> tries after too_far
    local far = {}                             -- uid -> true: in sight out of its room, drawn from its thumbnail
    local req = 0
    local looping = false

    local function now() return GetGameTimer() end

    local function hook(name, ...)
        local fn = opts[name]
        if not fn then return nil end
        local ok, value = pcall(fn, ...)
        if not ok then print(('[ink] %s failed: %s'):format(name, tostring(value))) end
        return ok and value or nil
    end

    -- Models -----------------------------------------------------------------------------------------------

    -- A page's baked base (P3): its tiles ('col_row' -> sha256), the seq they reach, the thumbnail and the raster.
    local function baseOf(raw)
        raw = type(raw) == 'table' and raw or {}
        local tiles = {}
        for key, hash in pairs(type(raw.tiles) == 'table' and raw.tiles or {}) do
            if type(key) == 'string' and type(hash) == 'string' then tiles[key] = hash end
        end
        return {
            tiles = tiles, upTo = math.tointeger(tonumber(raw.upTo)) or 0, thumb = type(raw.thumb) == 'string' and raw.thumb or '',
            w = tonumber(raw.w), h = tonumber(raw.h), size = tonumber(raw.size),
        }
    end

    local function sameTiles(a, b)
        if a.upTo ~= b.upTo then return false end
        for key, hash in pairs(a.tiles) do
            if b.tiles[key] ~= hash then return false end
        end
        for key in pairs(b.tiles) do
            if not a.tiles[key] then return false end
        end
        return true
    end

    -- The newest live clear of the cached ops (0: none).
    local function reclear(m)
        m.clear = 0
        for i = #m.ops, 1, -1 do
            local op = m.ops[i]
            if op[5] == 0 and Ink.kindOf(op[4]) == codec.CODE.clear then
                m.clear = op[1]
                return
            end
        end
    end

    -- The ops a bake took (up to upTo) leave the cache.
    local function trimTo(m, upTo)
        if m.seq < upTo then m.seq = upTo end
        if upTo <= 0 or not m.ops[1] or m.ops[1][1] > upTo then return end
        local keep = {}
        for _, op in ipairs(m.ops) do
            if op[1] > upTo then keep[#keep + 1] = op else m.bySeq[op[1]] = nil end
        end
        m.ops = keep
        reclear(m)
    end

    -- A page as the cache keeps it: ops as { seq, a, ck, d, s } (sent to the DUI and the editor as they are) above its
    -- baked base.
    local function fresh(s)
        local m = { id = s.page, board = s.board, e = s.e, rev = s.rev or 0, seq = 0, clear = s.clear or 0, role = s.role, me = s.me, ops = {}, bySeq = {} }
        m.base = baseOf(s.base)
        m.seq = m.base.upTo
        for _, w in ipairs(s.ops or {}) do
            if type(w) == 'table' and tonumber(w[1]) and w[1] > m.base.upTo then
                local op = { w[1], w[2], w[3], w[4], tonumber(w[5]) or 0 }
                m.ops[#m.ops + 1] = op
                m.bySeq[op[1]] = op
                if op[1] > m.seq then m.seq = op[1] end
            end
        end
        return m
    end

    -- New ops (seq above ours) and their effects; the newest live clear is looked for again when a clear moved.
    local function applyOps(m, list)
        local clears = false
        for _, w in ipairs(list or {}) do
            if type(w) == 'table' and tonumber(w[1]) and w[1] > m.seq then
                local op = { w[1], w[2], w[3], w[4], 0 }
                m.ops[#m.ops + 1] = op
                m.bySeq[op[1]] = op
                m.seq = op[1]
                if Ink.kindOf(op[4]) == codec.CODE.clear then clears = true end
                local fx = w[5]
                if type(fx) == 'table' then
                    for i = 1, #fx - 1, 2 do
                        local target = m.bySeq[fx[i]]
                        if target then
                            target[5] = fx[i + 1]
                            if Ink.kindOf(target[4]) == codec.CODE.clear then clears = true end
                        end
                    end
                end
            end
        end
        if clears then reclear(m) end
    end

    -- The cache keeps the pages of mounted boards and of the last few left.
    local function trim()
        local idle = {}
        for id, m in pairs(models) do
            if not mounted[m.board] then idle[#idle + 1] = m end
        end
        table.sort(idle, function(a, b) return (a.at or 0) > (b.at or 0) end)
        for i = KEEP + 1, #idle do
            local m = idle[i]
            models[m.id] = nil
            if byBoard[m.board] == m.id then byBoard[m.board] = nil end
        end
    end

    -- Opening ----------------------------------------------------------------------------------------------

    -- Opens the board's live page; keep = send the rev we hold (a return, a gap) so only what we miss comes.
    local function open(uid, keep)
        local m = byBoard[uid] and models[byBoard[uid]]
        req = req + 1
        asked[req] = uid
        local have = keep ~= false and m and { e = m.e, r = m.rev } or nil
        TriggerServerEvent(E .. ':open', uid, have, req)
    end
    client.open = open

    local function mount(uid)
        local b = client.boards[uid]
        if not b or mounted[uid] then return end
        mounted[uid], leaving[uid], retries[uid] = true, nil, 0
        hook('onMount', b)
        client.surfaces.set(uid, b)
        local id = byBoard[uid]
        if id and models[id] then client.surfaces.page(uid, id) end
        if b.ink ~= false then open(uid, true) end
    end

    -- The editor (client.editor, set by Ink.editor) hears what the product hears.
    local function tell(name, ...)
        local ed = client.editor
        if ed and ed[name] then ed[name](...) end
    end

    local function unmount(uid)
        if not mounted[uid] then return end
        mounted[uid], leaving[uid] = nil, nil
        local m = byBoard[uid] and models[byBoard[uid]]
        if m and m.open then
            m.open = false
            TriggerServerEvent(E .. ':close', m.id)
        end
        if m then m.at = now() end
        client.surfaces.remove(uid)
        hook('onUnmount', uid)
        trim()
    end
    client.mount, client.unmount = mount, unmount

    RegisterNetEvent(E .. ':state', function(s)
        if type(s) ~= 'table' then return end
        local uid = asked[s.req]
        asked[s.req] = nil
        if s.error then
            uid = uid or s.key
            if type(uid) ~= 'string' or not mounted[uid] then return end
            local tries = (retries[uid] or 0) + 1
            retries[uid] = tries
            if (s.error == 'slow' or s.error == 'too_far') and tries <= 6 then
                local wait = s.error == 'slow' and math.min(10000, math.max(250, tonumber(s.retry) or 1000)) or 2000
                SetTimeout(wait, function() if mounted[uid] then open(uid, true) end end)
            end
            return
        end
        local uidOf = type(s.board) == 'string' and s.board or uid
        local m = models[s.page]
        local replaced = false
        if s.mode == 'same' and m and m.e == s.e then
            -- nothing new
        elseif s.mode == 'events' and m and m.e == s.e then
            applyOps(m, s.events)
        else
            if s.mode == 'same' and s.retry then -- the whole page is on its way to us (or just came): ask again later
                local wait = math.min(20000, math.max(250, tonumber(s.retry) or 1000))
                return SetTimeout(wait, function()
                    local held = byBoard[uidOf] and models[byBoard[uidOf]]
                    if mounted[uidOf] then open(uidOf, held ~= nil and held.e == s.e) end
                end)
            end
            if s.mode ~= 'full' then return open(uidOf, false) end -- our copy is gone: the whole page
            m = fresh(s)
            models[s.page] = m
            replaced = true
        end
        local base = baseOf(s.base)
        if not sameTiles(m.base, base) then
            -- Baked while we were away: those ops leave our copy, the pages showing it load the tiles.
            trimTo(m, base.upTo)
            replaced = true
        end
        m.base = base
        m.rev, m.role, m.me, m.board, m.open, m.at = math.max(m.rev, s.rev or 0), s.role, s.me or m.me, uidOf, true, now()
        m.clear = tonumber(s.clear) or m.clear or 0
        local before = byBoard[uidOf]
        if before and before ~= s.page then
            -- The board shows another page now (P4): the old one closes once its last ops are out.
            SetTimeout(3000, function()
                local old = models[before]
                if old and old.open and byBoard[uidOf] ~= before then
                    old.open = false
                    TriggerServerEvent(E .. ':close', before)
                end
            end)
            tell('moved', uidOf, m)
        end
        byBoard[uidOf] = s.page
        retries[uidOf] = 0
        if client.statics then client.statics.set(uidOf, base.thumb) end
        if not mounted[uidOf] then
            m.open = false
            TriggerServerEvent(E .. ':close', s.page)
            return trim()
        end
        if replaced then client.surfaces.reload(s.page) end
        client.surfaces.page(uidOf, s.page)
        if s.mode == 'events' and s.events and #s.events > 0 then
            local packet = { page = s.page, rev = m.rev, ops = s.events }
            client.surfaces.push(s.page, packet)
            client.outbox.ack(s.page, s.events, m.me)
            hook('onPush', m, packet)
            tell('push', m, packet)
        end
        hook('onState', m, replaced)
        tell('state', m, replaced)
        client.outbox.opened(s.page)
    end)

    RegisterNetEvent(E .. ':push', function(p)
        local m = type(p) == 'table' and models[p.page]
        if not m or not m.open then return end
        if p.e ~= m.e then return open(m.board, false) end
        if (tonumber(p.from) or 0) > m.rev then return open(m.board, true) end
        applyOps(m, p.ops)
        if tonumber(p.rev) and p.rev > m.rev then m.rev = p.rev end
        local me = client.outbox.ack(p.page, p.ops, m.me)
        if me and not m.me then m.me = me end
        client.surfaces.push(p.page, p)
        hook('onPush', m, p)
        tell('push', m, p)
    end)

    -- A bake (P3): the ops up to upTo are in the page's tiles now. They leave the cache; the pages and the editor
    -- showing the page fold their own pixels into its ground (nothing is fetched); a page loaded later gets the tiles.
    -- A thumbnail-only bake moves nothing but the thumbnail.
    RegisterNetEvent(E .. ':baked', function(b)
        local m = type(b) == 'table' and models[b.page]
        if not m or b.e ~= m.e then return end
        local base = baseOf(b.base)
        if base.upTo < m.base.upTo then return end
        local moved = not sameTiles(m.base, base)
        m.base = base
        if client.statics and byBoard[m.board] == m.id then client.statics.set(m.board, base.thumb) end
        if not moved then return end
        trimTo(m, base.upTo)
        client.surfaces.baked(m.id, base.upTo)
        hook('onBaked', m, base.upTo)
        tell('baked', m, base.upTo)
    end)

    RegisterNetEvent(E .. ':nack', function(page, list)
        client.outbox.nack(page, list)
    end)

    RegisterNetEvent(E .. ':role', function(page, role)
        local m = models[page]
        if not m then return end
        m.role = role
        hook('onRole', m, role)
        tell('role', m, role)
    end)

    -- The server let the page go: too far for it (positions differ for a moment: open again if we are still in the
    -- room), too many pages followed, or the board is gone.
    RegisterNetEvent(E .. ':closed', function(page, reason)
        local m = models[page]
        if not m then return end
        m.open = false
        if reason == 'gone' then
            models[page] = nil
            if byBoard[m.board] == page then byBoard[m.board] = nil end
            return
        end
        if reason == 'away' and mounted[m.board] then
            SetTimeout(2000, function() if mounted[m.board] and not m.open then open(m.board, true) end end)
        end
        if reason == 'moved' and mounted[m.board] then open(m.board, true) end
    end)

    -- The board shows another page (P4 page strip): open the board again, its new page comes.
    RegisterNetEvent(E .. ':moved', function(uid)
        if type(uid) == 'string' and mounted[uid] then open(uid, true) end
    end)

    -- The outbox and the pool ------------------------------------------------------------------------------

    client.outbox = Ink.outbox({
        event = E,
        open = function(page) return models[page] ~= nil and models[page].open == true end,
        reopen = function(page)
            local m = models[page]
            if m and mounted[m.board] then open(m.board, true) end
        end,
        onDrop = function(page, cks, code, extra)
            hook('onDrop', page, cks, code, extra)
            tell('dropped', page, cks, code, extra)
        end,
        onCount = function(page, n, state) tell('count', page, n, state) end,
    })

    -- Boards no page of the pool shows, drawn from their last thumbnail (P3; opts.statics: its slots, false: none).
    client.statics = opts.statics ~= false and Ink.statics and Ink.statics({ event = E, slots = tonumber(opts.statics) or 24 }) or nil

    local pool = opts.surfaces or {}
    pool.model = function(id) return models[id] end
    pool.blobs = Ink.blobClient and Ink.blobClient(E) or nil -- baked tiles by hash
    pool.statics = client.statics
    client.surfaces = Ink.surfaces(pool)

    -- The boards ---------------------------------------------------------------------------------------------

    -- Inside a board's room; leaving needs 2 m more, and 3 s outside (the editor's board stays). A board with ink out
    -- of its room but within its stream distance is a surface without a page: its thumbnail shows.
    local function scan()
        local here = GetEntityCoords(PlayerPedId())
        local t, nearest = now(), math.huge
        for uid, b in pairs(client.boards) do
            local d = #(here - b.coords)
            if d < nearest then nearest = d end
            if d <= (b.reach or 80.0) and hook('inside', b, here, 0.0) then
                leaving[uid] = nil
                if not mounted[uid] then mount(uid) end
            elseif mounted[uid] then
                if d <= (b.reach or 80.0) and hook('inside', b, here, SLACK) then
                    leaving[uid] = nil
                elseif not (client.editor and client.editor.holds(uid)) then
                    leaving[uid] = leaving[uid] or t
                    if t - leaving[uid] >= LEAVE_MS then unmount(uid) end
                end
            end
            local seen = client.statics ~= nil and b.ink ~= false and not mounted[uid] and d <= (tonumber(b.streamDistance) or FAR)
            if seen and not far[uid] then
                far[uid] = true
                client.surfaces.set(uid, b)
            elseif not seen and far[uid] then
                far[uid] = nil
                if not mounted[uid] then client.surfaces.remove(uid) end
            end
        end
        return nearest
    end

    local function loop()
        if looping then return end
        looping = true
        CreateThread(function()
            while next(client.boards) or next(mounted) do
                local nearest = scan()
                Wait((nearest < NEAR or next(mounted)) and 500 or 2000)
            end
            looping = false
        end)
    end

    -- The product's boards ({ [uid] = board }); a board that went is let go, a changed one is set again.
    function client.set(list)
        for uid in pairs(client.boards) do
            if not list[uid] then
                unmount(uid)
                if far[uid] then
                    far[uid] = nil
                    client.surfaces.remove(uid)
                end
                client.boards[uid] = nil
            end
        end
        for uid, b in pairs(list) do
            client.boards[uid] = b
            if mounted[uid] or far[uid] then client.surfaces.set(uid, b) end
        end
        loop()
    end

    -- The board's page as the cache holds it, or nil.
    function client.model(uid)
        local id = byBoard[uid]
        return id and models[id] or nil
    end

    function client.wake() loop() end

    -- Pictures by sha256 (P4): asked once, kept up to 24 MB, shared by the DUI pages and the editor (ink:blob).
    local images, order, held, waiting, imgReq = {}, {}, 0, {}, 0
    local IMAGE_CACHE = 24 * 1048576

    local function settle(hash, data)
        local list = waiting[hash]
        waiting[hash] = nil
        if data and not images[hash] then
            images[hash], held = data, held + #data
            order[#order + 1] = hash
            while held > IMAGE_CACHE and #order > 1 do
                local old = table.remove(order, 1)
                held, images[old] = held - #(images[old] or ''), nil
            end
        end
        for _, p in ipairs(list or {}) do p:resolve(data) end
    end

    -- The picture's base64 (await-able), or nil when it is not there (yet).
    function client.image(hash)
        if type(hash) ~= 'string' or #hash ~= 64 then return nil end
        if images[hash] then return images[hash] end
        local p = promise.new()
        if waiting[hash] then
            waiting[hash][#waiting[hash] + 1] = p
        else
            waiting[hash] = { p }
            imgReq = imgReq + 1
            TriggerServerEvent(E .. ':img', imgReq, hash)
            SetTimeout(20000, function() if waiting[hash] then settle(hash, nil) end end)
        end
        return Citizen.Await(p)
    end

    RegisterNetEvent(E .. ':img', function(r)
        if type(r) ~= 'table' or type(r.hash) ~= 'string' or not waiting[r.hash] then return end
        if r.wait then
            return SetTimeout(math.min(5000, math.max(200, tonumber(r.wait) or 1000)), function()
                if waiting[r.hash] then TriggerServerEvent(E .. ':img', r.req, r.hash) end
            end)
        end
        settle(r.hash, type(r.data) == 'string' and r.data or nil)
    end)

    RegisterNUICallback('ink:blob', function(data, cb)
        local hash = type(data) == 'table' and data.hash
        CreateThread(function()
            local b64 = client.image(hash)
            cb(b64 and { data = b64 } or { missing = true })
        end)
    end)

    AddEventHandler('onResourceStop', function(resource)
        if resource ~= GetCurrentResourceName() then return end
        for uid in pairs(mounted) do
            local m = byBoard[uid] and models[byBoard[uid]]
            if m and m.open then TriggerServerEvent(E .. ':close', m.id) end
        end
    end)

    return client
end

-- An op's kind code from its base64 without decoding it (the server checked the op): the first byte.
local B64 = {}
do
    local alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    for i = 1, 64 do B64[alphabet:byte(i)] = i - 1 end
end

function Ink.kindOf(d)
    if type(d) ~= 'string' or #d < 4 then return 0 end
    local a, b = B64[d:byte(1)], B64[d:byte(2)]
    return a and b and ((a << 2) | (b >> 4)) or 0
end

return Ink.client
