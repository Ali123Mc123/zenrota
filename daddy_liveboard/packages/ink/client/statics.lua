-- Ink statics (6-tahta-video-sanat.md 3.2, remote view and gallery; P3): boards and canvases without an ink page show
-- their last thumbnail on a runtime texture: 24 slots (the low profile 12), each made once a session when first needed
-- and refilled with SetRuntimeTextureImage from a data URL, no DUI. At first use a 4 x 4 PNG checks that data URLs load;
-- if not, one atlas DUI of 16 cells (packages/ink/dui/atlas.html) does the job. Blobs (tiles, thumbnails) come by hash
-- through Ink.blobClient, which merges requests and keeps the last 24 MB.
--   local statics = Ink.statics({ event = 'res:ink', slots = 24 })
--   statics.want(uid) / statics.drop(uid)   boards to show from their thumbnail (asked for every minute while wanted)
--   statics.set(uid, hash)                   a board's thumbnail as its page told it (an open, a bake)
--   statics.draw(uid, q, tint) -> bool       q: tl, bl, br, tr as 12 numbers (as Ink.surfaces draws); false: not ready
--   statics.texture(uid) -> txd, 'tex', u0, v0, u1, v1 | nil
--   Ink.colorTexture('#rrggbb') -> txd | nil a plain colour ('tex'), drawn under a thumbnail
Ink = Ink or {}

local blobClients, staticsOf = {}, {}

local function unique(base)
    local ok, name = pcall(function() return DL.dui.name(base) end)
    return ok and type(name) == 'string' and name or ('%s_%d'):format(base, GetGameTimer())
end

-- A 4 x 4 texture of one colour per '#rrggbb', made once; nil for anything else.
local colours = {}
function Ink.colorTexture(color)
    color = type(color) == 'string' and color:lower() or ''
    if colours[color] ~= nil then return colours[color] or nil end
    local r, g, b = color:match('^#(%x%x)(%x%x)(%x%x)$')
    colours[color] = false
    if not r then return nil end
    local name = unique(GetCurrentResourceName() .. '_inkcolor')
    local ok = pcall(function()
        local tex = CreateRuntimeTexture(CreateRuntimeTxd(name), 'tex', 4, 4)
        for x = 0, 3 do
            for y = 0, 3 do SetRuntimeTexturePixel(tex, x, y, tonumber(r, 16), tonumber(g, 16), tonumber(b, 16), 255) end
        end
        CommitRuntimeTexture(tex)
    end)
    colours[color] = ok and name or false
    return colours[color] or nil
end

-- Blobs by hash for one ink event: get(hash, cb(b64 | nil)), fetch(hashes, cb(map, complete), ms), await(hashes, ms),
-- peek(hash) -> b64 | nil (cached only).
function Ink.blobClient(event)
    local E = event or (GetCurrentResourceName() .. ':ink')
    if blobClients[E] then return blobClients[E] end
    local C = {}
    local CACHE, PER_CALL, RETRY_MS = 24 * 1048576, 16, 10000
    local cache, order, head, last, held = {}, {}, 1, 0, 0
    local waiting, queued, req, sending = {}, {}, 0, false -- hash -> { at, cbs }; hashes to ask for

    local function keep(hash, b64)
        if cache[hash] then return end
        cache[hash], held, last = b64, held + #b64, last + 1
        order[last] = hash
        while held > CACHE and head <= last do
            local old = order[head]
            order[head], head = nil, head + 1
            if cache[old] then held, cache[old] = held - #cache[old], nil end
        end
    end

    local function flush()
        local list = {}
        for hash in pairs(queued) do
            list[#list + 1], queued[hash] = hash, nil
            if #list >= PER_CALL then break end
        end
        if #list > 0 then
            req = req + 1
            TriggerServerEvent(E .. ':blob', req, list)
        end
        if next(queued) then SetTimeout(250, flush) else sending = false end
    end

    local function ask(hash)
        queued[hash] = true
        if not sending then
            sending = true
            SetTimeout(0, flush)
        end
    end

    local function done(hash, b64)
        local w = waiting[hash]
        waiting[hash] = nil
        if b64 then keep(hash, b64) end
        for _, cb in ipairs(w and w.cbs or {}) do pcall(cb, b64) end
    end

    function C.peek(hash)
        return cache[hash]
    end

    function C.get(hash, cb)
        if cache[hash] then return cb(cache[hash]) end
        local w = waiting[hash]
        if w then
            w.cbs[#w.cbs + 1] = cb
            if GetGameTimer() - w.at > RETRY_MS then -- the answer never came: ask again
                w.at = GetGameTimer()
                ask(hash)
            end
            return
        end
        waiting[hash] = { at = GetGameTimer(), cbs = { cb } }
        ask(hash)
    end

    function C.fetch(hashes, cb, ms)
        local out, seen, left, missing, finished = {}, {}, 0, false, false
        local function finish(complete)
            if finished then return end
            finished = true
            cb(out, complete)
        end
        for _, h in ipairs(hashes) do
            if not seen[h] then seen[h], left = true, left + 1 end
        end
        if left == 0 then return finish(true) end
        for h in pairs(seen) do
            C.get(h, function(b64)
                if b64 then out[h] = b64 else missing = true end
                left = left - 1
                if left == 0 then finish(not missing) end
            end)
        end
        SetTimeout(ms or 15000, function() finish(false) end)
    end

    -- Inside a thread: { [hash] = b64 } once all came, or nil (one is missing or it took too long).
    function C.await(hashes, ms)
        local p = promise.new()
        C.fetch(hashes, function(map, complete) p:resolve(complete and map or false) end, ms)
        return Citizen.Await(p) or nil
    end

    RegisterNetEvent(E .. ':blob', function(r)
        if type(r) ~= 'table' then return end
        if r.wait then -- the server asked us to slow down
            SetTimeout(math.max(100, math.min(10000, tonumber(r.wait) or 1000)), function()
                for _, hash in ipairs(type(r.hashes) == 'table' and r.hashes or {}) do
                    if waiting[hash] then ask(hash) end
                end
            end)
            return
        end
        for hash, b64 in pairs(type(r.blobs) == 'table' and r.blobs or {}) do
            if type(b64) == 'string' then done(hash, b64) end
        end
        for _, hash in ipairs(type(r.missing) == 'table' and r.missing or {}) do done(hash, nil) end
    end)

    blobClients[E] = C
    return C
end

function Ink.statics(opts)
    opts = opts or {}
    local E = opts.event or (GetCurrentResourceName() .. ':ink')
    if staticsOf[E] then return staticsOf[E] end
    local RES = GetCurrentResourceName()
    local SIZE, ATLAS, COUNT = 512, 1024, math.max(1, math.min(24, math.tointeger(opts.slots) or 24))
    local PROBE = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAQAAAAECAYAAACp8Z5+AAAAD0lEQVR4nGP4jwYYSBcAAHg8P8FY7imoAAAAAElFTkSuQmCC'
    local blobs = Ink.blobClient(E)
    local S = {}
    local mode, atlas, slots, byUid, wanted, hashes = nil, nil, {}, {}, {}, {} -- 'runtime' | 'atlas'; ...; uid -> hash
    local looping, soon = false, false

    -- Runtime textures from data URLs; the atlas DUI when a 4 x 4 PNG does not load that way.
    local function setup()
        if mode then return end
        local ok, width = pcall(function()
            local probe = CreateRuntimeTextureFromImage(CreateRuntimeTxd(unique(RES .. '_inkprobe')), 'probe', PROBE)
            return probe and probe ~= 0 and GetRuntimeTextureWidth(probe) or 0
        end)
        if ok and width == 4 then
            mode = 'runtime' -- the slots come one by one as they are needed (newSlot)
            return
        end
        mode = 'atlas'
        local txd = unique(RES .. '_inkatlas')
        local dui = CreateDui(('nui://%s/packages/ink/dui/atlas.html'):format(RES), ATLAS, ATLAS)
        CreateRuntimeTextureFromDuiHandle(CreateRuntimeTxd(txd), 'tex', GetDuiHandle(dui))
        atlas = dui
        for i = 1, math.min(COUNT, 16) do
            local c, r = (i - 1) % 4, (i - 1) // 4
            slots[i] = { txd = txd, cell = i - 1, u0 = c / 4, v0 = r / 4, u1 = (c + 1) / 4, v1 = (r + 1) / 4, used = 0 }
        end
        print(('[%s] ink: data URL textures did not load, the thumbnail atlas is used'):format(RES))
    end

    local function fill(slot, b64)
        local url = ('data:image/%s;base64,%s'):format(b64:sub(1, 4) == '/9j/' and 'jpeg' or 'png', b64)
        if mode == 'runtime' then
            SetRuntimeTextureImage(slot.tex, url)
        else
            SendDuiMessage(atlas, json.encode({ cell = slot.cell, src = url }))
        end
        slot.ready = true
    end

    -- One more runtime texture while the slots are fewer than COUNT (each about 1 MB): its index, or nil.
    local function newSlot()
        local i = #slots + 1
        if mode ~= 'runtime' or i > COUNT then return nil end
        local txd = unique(('%s_inkstatic%d'):format(RES, i))
        slots[i] = { txd = txd, tex = CreateRuntimeTexture(CreateRuntimeTxd(txd), 'tex', SIZE, SIZE), u0 = 0.0, v0 = 0.0, u1 = 1.0, v1 = 1.0, used = 0 }
        return i
    end

    -- A free slot, else a new one, else one no longer wanted, else the one drawn longest ago.
    local function slotFor(uid)
        local i = byUid[uid]
        if i then return slots[i] end
        local best
        for j, slot in ipairs(slots) do
            if not slot.uid then
                best = j
                break
            end
            if not wanted[slot.uid] and (not best or slot.used < slots[best].used) then best = j end
        end
        if not best or slots[best].uid then best = newSlot() or best end
        if not best then
            for j, slot in ipairs(slots) do
                if not best or slot.used < slots[best].used then best = j end
            end
        end
        local slot = slots[best]
        if not slot then return nil end
        if slot.uid then byUid[slot.uid] = nil end
        slot.uid, slot.hash, slot.ready = uid, nil, false
        byUid[uid] = best
        return slot
    end

    local function show(uid)
        local hash = hashes[uid]
        if not wanted[uid] or type(hash) ~= 'string' or hash == '' then return end
        local slot = slotFor(uid)
        if not slot or slot.hash == hash then return end
        slot.hash = hash -- the old picture stays until the new one is in
        blobs.get(hash, function(b64)
            if b64 and slot.uid == uid and slot.hash == hash then fill(slot, b64) end
        end)
    end

    local function wantedList()
        local list = {}
        for uid in pairs(wanted) do list[#list + 1] = uid end
        return list
    end

    -- Every minute while anything is wanted: the thumbnails, and a 2 min watch for new ones.
    local function loop()
        local list = wantedList()
        if #list == 0 then
            looping = false
            return
        end
        TriggerServerEvent(E .. ':thumbs', list)
        SetTimeout(60000, loop)
    end

    function S.want(uid)
        if type(uid) ~= 'string' or wanted[uid] then return end
        wanted[uid] = true
        setup()
        if hashes[uid] then show(uid) end
        if not looping then
            looping = true
            SetTimeout(500, loop)
        elseif not soon then
            soon = true
            SetTimeout(1000, function()
                soon = false
                if next(wanted) then TriggerServerEvent(E .. ':thumbs', wantedList()) end
            end)
        end
    end

    function S.drop(uid)
        wanted[uid] = nil
    end

    -- The board's thumbnail as its page said (an open, a bake): shown at once while the board is wanted.
    function S.set(uid, hash)
        if type(uid) ~= 'string' or type(hash) ~= 'string' or hash == '' then return end
        hashes[uid] = hash
        if wanted[uid] then show(uid) end
    end

    function S.texture(uid)
        local i = byUid[uid]
        local slot = i and slots[i]
        if not slot or not slot.ready then return nil end
        slot.used = GetGameTimer()
        return slot.txd, 'tex', slot.u0, slot.v0, slot.u1, slot.v1
    end

    -- Front face only, as Ink.surfaces draws a page; tint dims it in a dark room (default 230).
    function S.draw(uid, q, tint)
        local txd, tex, u0, v0, u1, v1 = S.texture(uid)
        if not txd then return false end
        local t = tint or 230
        DrawSpritePoly(q[1], q[2], q[3], q[4], q[5], q[6], q[7], q[8], q[9], t, t, t, 255, txd, tex, u0, v0, 1.0, u0, v1, 1.0, u1, v1, 1.0)
        DrawSpritePoly(q[1], q[2], q[3], q[7], q[8], q[9], q[10], q[11], q[12], t, t, t, 255, txd, tex, u0, v0, 1.0, u1, v1, 1.0, u1, v0, 1.0)
        return true
    end

    function S.mode() return mode end

    RegisterNetEvent(E .. ':thumbs', function(map)
        if type(map) ~= 'table' then return end
        for uid, hash in pairs(map) do
            if wanted[uid] and type(hash) == 'string' then
                hashes[uid] = hash
                show(uid)
            end
        end
    end)

    RegisterNetEvent(E .. ':thumb', function(uid, hash)
        if type(uid) ~= 'string' or type(hash) ~= 'string' then return end
        hashes[uid] = hash
        show(uid)
    end)

    staticsOf[E] = S
    return S
end
