-- Ink surfaces (6-tahta-video-sanat.md 3.2, surfaces and the DUI pool): a few DUI pages per product, each showing one
-- board at a time (another board is a load message, never a new page). A page gets its texture name once, when it is
-- made (<res>_ink<n>_g<gen>, unique for the session), and keeps it: waking it from park or binding it to another
-- board never renames it. A page with no board parks on about:blank after 3 min; it is destroyed only when the budget
-- wants it for another product or after 10 min without a board (blank first, destroyed a frame later); a slot makes
-- at most 4 pages a session, then it only parks. The page says when it listens (ink:ready with its nonce) and when a
-- board is drawn (ink:loaded): until then its messages wait; 3 s without loaded sends the load again, 5 s without
-- ready loads the page once more. A board's baked tiles (P3) are fetched by hash before its load and go to the page
-- just ahead of it; a bake while a page shows the board is folded there (nothing is fetched). Each frame a board in
-- front of the camera is 2 DrawSpritePoly (front face only, vertex colour 230), with the media page's texture 3 mm
-- behind it drawn first; a board no page shows (yet) is its colour and its last thumbnail (statics.lua).
--   local pool = Ink.surfaces({ page = 'web/dist/dui/ink.html', slots = 2, model = function(pageId) end, blobs = ..., statics = ... })
Ink = Ink or {}

local RESOURCE = GetCurrentResourceName()
local START = ('%x'):format(GetGameTimer())
local CHUNK_OPS, CHUNK_BYTES = 300, 49152 -- ops a load message carries at most
local SEND_BYTES = 98304                  -- bytes a page gets in one frame at most

function Ink.surfaces(opts)
    local cfg = {
        page = 'web/dist/dui/ink.html', slots = 2, width = 1280, height = 800, stream = 30.0, tint = 230,
        offset = 0.005, gap = 0.003, twoSided = false, park = 180000, destroy = 600000, gens = 4,
        ready = 5000, loaded = 3000, lease = 'ink', tick = 250,
    }
    for k, v in pairs(opts or {}) do cfg[k] = v end
    local blobs, statics = cfg.blobs, cfg.statics -- tiles by hash (Ink.blobClient); thumbnails of boards no page shows
    local pool = {}
    local surfaces, slots, byNonce = {}, {}, {} -- uid -> surface; index -> slot; nonce -> slot
    local media = {} -- uid -> { layer, underlay, inkHidden }: the product's media hooks may come before the surface
    local made, stamp, plain = 0, nil, 0
    local managing, drawing, sending = false, false, {}
    local channel = false -- a page answered once: the DUI -> NUI callback works on this client

    local function now() return GetGameTimer() end

    local function nonce()
        local out = {}
        for i = 1, 12 do out[i] = string.char(math.random(97, 122)) end
        return table.concat(out)
    end

    -- Version and content hash of the built page: a new build gets a new URL, so CEF never runs an old copy.
    local function pageUrl(n)
        if not stamp then
            local html = LoadResourceFile(RESOURCE, cfg.page)
            if not html then return nil end
            stamp = ('%s.%08x'):format(GetResourceMetadata(RESOURCE, 'version', 0) or '0', GetHashKey(html) & 0xffffffff)
        end
        return ('https://cfx-nui-%s/%s?v=%s#%s'):format(RESOURCE, cfg.page, stamp, n)
    end

    -- A texture dictionary binds only to the first DUI made under its name: one name per DUI, never again.
    local function txdName(index, gen)
        made = made + 1
        local base = ('%s_ink%d_g%d'):format(RESOURCE, index, gen)
        local ok, name = pcall(function() return DL.dui.name(base) end)
        return ok and type(name) == 'string' and name or ('%s_%s_%d'):format(base, START, made)
    end

    -- Budget -----------------------------------------------------------------------------------------------

    local destroy

    local function leaseId(slot) return ('%s:%d'):format(cfg.lease, slot.index) end

    local function lease(slot, distance)
        local ok, granted = pcall(DL.dui.acquire, leaseId(slot), distance, function()
            slot.revoked = now()
            destroy(slot, false)
        end, { width = cfg.width, height = cfg.height })
        return ok and granted == true
    end

    local function park(slot)
        pcall(function()
            if DL.dui.park then DL.dui.park(leaseId(slot)) else DL.dui.acquire(leaseId(slot), 1e9) end
        end)
    end

    -- Sending ----------------------------------------------------------------------------------------------

    local function sendNow(slot, message)
        message.nonce = slot.nonce
        SendDuiMessage(slot.dui, json.encode(message))
    end

    -- Messages leave in order; a page that is not listening yet keeps them, big loads go over a few frames.
    local function flush(slot)
        if sending[slot] then return end
        sending[slot] = true
        CreateThread(function()
            while slot.dui and slot.state == 'ready' and #slot.out > 0 do
                local spent = 0
                while #slot.out > 0 and spent < SEND_BYTES do
                    local message = table.remove(slot.out, 1)
                    message.nonce = slot.nonce
                    local text = json.encode(message)
                    spent = spent + #text
                    SendDuiMessage(slot.dui, text)
                end
                if #slot.out > 0 then Wait(0) end
            end
            sending[slot] = nil
        end)
    end

    local function post(slot, message)
        slot.out[#slot.out + 1] = message
        if slot.state == 'ready' then flush(slot) end
    end

    -- The sha256s of a model's baked tiles, each once.
    local function tilesOf(model)
        local list, seen = {}, {}
        for _, hash in pairs(model.base and model.base.tiles or {}) do
            if not seen[hash] then seen[hash], list[#list + 1] = true, hash end
        end
        return list
    end

    -- A page's board: unload what it showed, its baked tiles (fetched first when they are not here; anyway: the ones
    -- that did not come stay out), then the model's ops in chunks (the snapshot is taken now; later pushes follow it
    -- in the same queue and the page skips the ops it has).
    local function sendLoad(slot, anyway)
        local s = slot.uid and surfaces[slot.uid]
        local model = s and s.page and (s.page < 0 and { id = s.page, e = 0, rev = 0, clear = 0, ops = {} } or cfg.model(s.page))
        if not model then return end
        local hashes, missing = tilesOf(model), {}
        for _, hash in ipairs(blobs and hashes or {}) do
            if not blobs.peek(hash) then missing[#missing + 1] = hash end
        end
        if #missing > 0 and not anyway then
            local token = {}
            slot.fetching, slot.page, slot.loaded, slot.out = token, model.id, nil, {}
            blobs.fetch(missing, function(_, complete)
                if slot.fetching ~= token then return end
                slot.fetching = nil
                if slot.dui and slot.state == 'ready' and slot.uid then sendLoad(slot, not complete) end
            end, 20000)
            return
        end
        slot.fetching = nil
        slot.out = {}
        slot.page, slot.loaded, slot.loadAt, slot.tries = model.id, nil, now(), (slot.tries or 0) + 1
        slot.loadWait = cfg.loaded + #model.ops * 3 + #hashes * 60 -- a full page takes longer to draw: never sent again mid-draw
        local chunks, list, bytes = {}, {}, 0
        for i = 1, #model.ops do
            local op = model.ops[i]
            list[#list + 1] = op
            bytes = bytes + #op[4] + 32
            if #list >= CHUNK_OPS or bytes >= CHUNK_BYTES then
                chunks[#chunks + 1] = list
                list, bytes = {}, 0
            end
        end
        if #list > 0 or #chunks == 0 then chunks[#chunks + 1] = list end
        post(slot, { type = 'unload' })
        for _, hash in ipairs(hashes) do
            local b64 = blobs and blobs.peek(hash)
            if b64 then post(slot, { type = 'tile', hash = hash, data = b64 }) end
        end
        post(slot, {
            type = 'load', page = model.id, e = model.e, rev = model.rev, clear = model.clear, aspect = s.width / s.height,
            bg = s.background, text = cfg.text and cfg.text() or nil, ops = chunks[1], more = #chunks > 1, base = model.base,
        })
        for i = 2, #chunks do post(slot, { type = 'more', page = model.id, ops = chunks[i] }) end
        if #chunks > 1 then post(slot, { type = 'done', page = model.id, rev = model.rev }) end
        post(slot, { type = 'layer', layer = s.layer or { mode = 'none' } })
        post(slot, { type = 'edit', on = s.editing == true })
        if slot.blind then slot.loaded = slot.page end
    end

    local function ready(slot)
        if slot.state ~= 'waiting' then return end
        slot.state = 'ready'
        if slot.uid and not slot.loaded then sendLoad(slot) end
        flush(slot)
    end

    -- Pages --------------------------------------------------------------------------------------------------

    -- A new DUI for a slot (a new generation, a new name), when the budget allows it.
    local function create(slot, distance)
        if slot.gen >= cfg.gens and slot.dui == nil then return false end
        local n = nonce()
        local url = pageUrl(n)
        if not url or not lease(slot, distance) then return false end
        slot.gen = slot.gen + 1
        slot.nonce, slot.url, slot.txd = n, url, txdName(slot.index, slot.gen)
        slot.dui = CreateDui(url, cfg.width, cfg.height)
        CreateRuntimeTextureFromDuiHandle(CreateRuntimeTxd(slot.txd), 'tex', GetDuiHandle(slot.dui))
        slot.state, slot.since, slot.reloaded, slot.blind, slot.out = 'waiting', now(), false, false, {}
        byNonce[n] = slot
        return true
    end

    -- A parked page loads its URL again: same DUI, same texture name.
    local function wake(slot, distance)
        if not lease(slot, distance) then return false end
        SetDuiUrl(slot.dui, slot.url)
        slot.state, slot.since, slot.reloaded, slot.blind, slot.out, slot.parkedAt = 'waiting', now(), false, false, {}, nil
        return true
    end

    local function detach(slot)
        local s = slot.uid and surfaces[slot.uid]
        if s and s.slot == slot.index then s.slot = nil end
        slot.uid = nil
        slot.freeSince = now()
    end

    -- A slot without a board keeps its page (warm) but gives way first when the budget is full.
    local function unbindOf(slot)
        if slot.uid and slot.dui then pcall(DL.dui.acquire, leaseId(slot), 1e8) end
        detach(slot)
    end

    -- Blank first, destroyed a frame later (now: both at once, a stop has no next frame). A slot past its last
    -- generation only parks.
    destroy = function(slot, nowToo)
        if not slot.dui then return end
        detach(slot)
        slot.page, slot.loaded, slot.out, slot.fetching = nil, nil, {}, nil
        if slot.gen >= cfg.gens and not nowToo then
            SetDuiUrl(slot.dui, 'about:blank')
            slot.state, slot.parkedAt = 'parked', slot.parkedAt or now()
            pcall(DL.dui.release, leaseId(slot))
            return
        end
        local dui = slot.dui
        byNonce[slot.nonce or ''] = nil
        slot.dui, slot.state, slot.txd = nil, 'none', nil
        pcall(DL.dui.release, leaseId(slot))
        local retired = pcall(function() DL.dui.retire(dui, nowToo) end)
        if retired then return end
        SetDuiUrl(dui, 'about:blank')
        if nowToo then return DestroyDui(dui) end
        CreateThread(function()
            Wait(0)
            DestroyDui(dui)
        end)
    end

    local function bind(slot, s)
        if slot.uid and slot.uid ~= s.uid then unbindOf(slot) end
        slot.uid, slot.freeSince = s.uid, nil
        s.slot = slot.index
        if slot.state == 'parked' then
            if (slot.revoked and now() - slot.revoked < 5000) or not wake(slot, s.distance) then
                unbindOf(slot)
                return false
            end
        end
        if slot.page == s.page and slot.loaded == s.page then
            post(slot, { type = 'layer', layer = s.layer or { mode = 'none' } })
            post(slot, { type = 'edit', on = s.editing == true })
            return true
        end
        slot.loaded, slot.tries = nil, 0
        if slot.state == 'ready' then sendLoad(slot) end
        return true
    end

    -- Binding: the nearest boards with a page get the slots; a slot that shows a board's page already goes to it.
    local function assign(here)
        local want = {}
        for uid, s in pairs(surfaces) do
            s.distance = #(here - s.coords)
            if s.page and s.distance <= s.stream then want[#want + 1] = s end
        end
        table.sort(want, function(a, b) return a.distance < b.distance end)
        local keep = {}
        for i = 1, math.min(#want, cfg.slots) do keep[want[i].uid] = want[i] end
        for _, slot in ipairs(slots) do
            if slot.uid and not keep[slot.uid] then unbindOf(slot) end
        end
        for _, s in pairs(keep) do
            local slot = s.slot and slots[s.slot]
            if slot and slot.uid == s.uid then
                if slot.page ~= s.page then
                    slot.loaded, slot.tries = nil, 0
                    if slot.state == 'ready' then sendLoad(slot) end
                end
            else
                local best
                for _, other in ipairs(slots) do
                    if not other.uid and other.page == s.page and other.dui then best = other end
                end
                if not best then
                    for _, other in ipairs(slots) do
                        if not other.uid and other.dui and (not best or other.state == 'ready') then best = other end
                    end
                end
                if not best then
                    for _, other in ipairs(slots) do
                        if not other.uid and not other.dui and other.gen < cfg.gens
                            and (not other.revoked or now() - other.revoked > 5000) and create(other, s.distance) then
                            best = other
                            break
                        end
                    end
                end
                if best then bind(best, s) end
            end
        end
        -- Boards in sight that no page shows (yet) are drawn from their last thumbnail.
        if not statics then return end
        for uid, s in pairs(surfaces) do
            if s.ink ~= false then
                local slot = s.slot and slots[s.slot]
                if s.distance <= s.stream and not (slot and slot.uid == uid and slot.loaded and slot.loaded == s.page) then
                    statics.want(uid)
                else
                    statics.drop(uid)
                end
            end
        end
    end

    -- Handshake timeouts, the lease's distance, park and destroy.
    local function look(slot, t)
        if slot.state == 'waiting' then
            if not slot.reloaded and t - slot.since >= cfg.ready then
                slot.reloaded, slot.since = true, t
                SetDuiUrl(slot.dui, slot.url)
            elseif slot.reloaded and t - slot.since >= cfg.ready and IsDuiAvailable(slot.dui) then
                slot.blind = not channel -- no answer at all: messages go anyway, the state heals itself
                slot.state = 'waiting'
                ready(slot)
            end
        elseif slot.state == 'ready' and slot.uid and slot.page and slot.loaded ~= slot.page and not slot.fetching then
            if t - (slot.loadAt or t) >= (slot.loadWait or cfg.loaded) then
                if (slot.tries or 0) >= 3 or slot.blind then slot.loaded = slot.page else sendLoad(slot) end
            end
        end
        local s = slot.uid and surfaces[slot.uid]
        if s and slot.dui and t - (slot.leaseAt or 0) >= 1000 then
            slot.leaseAt = t
            lease(slot, s.distance or 0)
        end
        if not slot.uid and slot.dui then
            local idle = t - (slot.freeSince or t)
            if slot.state ~= 'parked' and idle >= cfg.park then
                SetDuiUrl(slot.dui, 'about:blank')
                slot.state, slot.page, slot.loaded, slot.out, slot.parkedAt = 'parked', nil, nil, {}, t
                park(slot)
            elseif slot.state == 'parked' and idle >= cfg.destroy and slot.gen < cfg.gens then
                destroy(slot, false)
            end
        end
    end

    local startDraw

    local function manage()
        if managing then return end
        managing = true
        CreateThread(function()
            while true do
                local live = next(surfaces) ~= nil
                for _, slot in ipairs(slots) do live = live or slot.dui ~= nil end
                if not live then break end
                local t = now()
                assign(GetEntityCoords(PlayerPedId()))
                for _, slot in ipairs(slots) do look(slot, t) end
                startDraw()
                Wait(cfg.tick)
            end
            managing = false
        end)
    end

    -- Drawing ------------------------------------------------------------------------------------------------

    -- Corners at the face offset: tl, bl, br, tr as 12 numbers; the normal; a radius for the view test.
    local function quad(s, offset)
        local rad = math.rad(s.heading)
        local nx, ny = math.cos(rad), math.sin(rad)
        local rx, ry = math.cos(rad + math.pi / 2), math.sin(rad + math.pi / 2)
        local cx, cy, cz = s.coords.x + nx * offset, s.coords.y + ny * offset, s.coords.z
        local hw, hh = s.width * 0.5, s.height * 0.5
        local lx, ly, gx, gy = cx - rx * hw, cy - ry * hw, cx + rx * hw, cy + ry * hw
        return { lx, ly, cz + hh, lx, ly, cz - hh, gx, gy, cz - hh, gx, gy, cz + hh }
    end

    local function shapeOf(s)
        local rad = math.rad(s.heading)
        s.nx, s.ny = math.cos(rad), math.sin(rad)
        s.front, s.under = quad(s, cfg.offset), quad(s, cfg.offset - cfg.gap)
        s.radius = math.sqrt(s.width * s.width + s.height * s.height) * 0.5
        s.stream = tonumber(s.streamDistance) or cfg.stream
        s.stream2 = s.stream * s.stream
    end

    local T = cfg.tint
    -- Front face only: the visible side of a triangle is where (b - a) x (c - a) points, the board's normal here.
    local function draw(q, txd)
        DrawSpritePoly(q[1], q[2], q[3], q[4], q[5], q[6], q[7], q[8], q[9], T, T, T, 255, txd, 'tex', 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0)
        DrawSpritePoly(q[1], q[2], q[3], q[7], q[8], q[9], q[10], q[11], q[12], T, T, T, 255, txd, 'tex', 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0)
        if not cfg.twoSided then return end
        DrawSpritePoly(q[1], q[2], q[3], q[7], q[8], q[9], q[4], q[5], q[6], T, T, T, 255, txd, 'tex', 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0, 1.0)
        DrawSpritePoly(q[1], q[2], q[3], q[10], q[11], q[12], q[7], q[8], q[9], T, T, T, 255, txd, 'tex', 0.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0)
    end

    local function drawable()
        for _, s in pairs(surfaces) do
            if s.underlay or (statics and s.ink ~= false) then return true end
            local slot = s.slot and slots[s.slot]
            if slot and slot.loaded and slot.loaded == s.page then return true end
        end
        return false
    end

    -- A board no page shows (yet): its colour (unless something lies behind it already), then its last thumbnail.
    local function drawStatic(s)
        if not s.underlay then
            if s.paper == nil then s.paper = Ink.colorTexture and Ink.colorTexture(s.background) or false end
            if s.paper then draw(s.under, s.paper) end
        end
        if not s.editing then statics.draw(s.uid, s.front, T) end
    end

    startDraw = function()
        if drawing or not drawable() then return end
        drawing = true
        CreateThread(function()
            while drawable() do
                local cam = GetFinalRenderedCamCoord()
                local rot = GetFinalRenderedCamRot(2)
                local rx, rz = math.rad(rot.x), math.rad(rot.z)
                local c = math.abs(math.cos(rx))
                local fx, fy, fz = -math.sin(rz) * c, math.cos(rz) * c, math.sin(rx)
                for _, s in pairs(surfaces) do
                    local dx, dy, dz = s.coords.x - cam.x, s.coords.y - cam.y, s.coords.z - cam.z
                    -- In front of the board, within reach, and not behind the camera.
                    if dx * s.nx + dy * s.ny < 0 and dx * dx + dy * dy + dz * dz <= s.stream2
                        and dx * fx + dy * fy + dz * fz > -s.radius then
                        if s.underlay then draw(s.under, s.underlay) end
                        local slot = s.slot and slots[s.slot]
                        if slot and slot.loaded and slot.loaded == s.page and slot.txd then
                            if not s.inkHidden then draw(s.front, slot.txd) end
                        elseif statics and s.ink ~= false and not s.inkHidden then
                            drawStatic(s)
                        end
                    end
                end
                Wait(0)
            end
            drawing = false
        end)
    end

    -- NUI callbacks of the pages ------------------------------------------------------------------------------

    RegisterNUICallback('ink:ready', function(data, cb)
        cb({})
        local slot = type(data) == 'table' and byNonce[data.nonce]
        if not slot or slot.state ~= 'waiting' then return end
        channel = true
        ready(slot)
    end)

    RegisterNUICallback('ink:loaded', function(data, cb)
        cb({})
        local slot = type(data) == 'table' and byNonce[data.nonce]
        if not slot or tonumber(data.page) ~= slot.page then return end
        channel = true
        slot.loaded = slot.page
        startDraw()
    end)

    -- API ------------------------------------------------------------------------------------------------------

    for i = 1, math.max(1, cfg.slots) do slots[i] = { index = i, gen = 0, state = 'none', out = {} } end

    -- A board in the room: coords, heading, width, height, background, streamDistance; page (its page id) once it is
    -- open. A board without ink (ink = false, a screen) gets a page id of its own below 0: its colour and media only.
    function pool.set(uid, data)
        local s = surfaces[uid]
        if not s then
            s = { uid = uid }
            local m = media[uid]
            if m then s.layer, s.underlay, s.inkHidden = m.layer, m.underlay, m.inkHidden end
            surfaces[uid] = s
        end
        for k, v in pairs(data) do s[k] = v end
        s.paper = nil -- its colour texture, found again when it is drawn
        if s.ink == false and not (s.page and s.page < 0) then
            plain = plain + 1
            s.page = -plain
        end
        shapeOf(s)
        manage()
    end

    -- The board's page is open (or was opened again): bound slots load it.
    function pool.page(uid, pageId)
        local s = surfaces[uid]
        if not s then return end
        if s.page ~= pageId then s.page = pageId end
        local slot = s.slot and slots[s.slot]
        if slot and slot.uid == uid and slot.page ~= pageId then
            slot.loaded, slot.tries = nil, 0
            if slot.state == 'ready' then sendLoad(slot) end
        end
        manage()
    end

    -- The board left the room: its slot keeps the page warm for the next board (or for its return).
    function pool.remove(uid)
        local s = surfaces[uid]
        if not s then return end
        local slot = s.slot and slots[s.slot]
        if slot and slot.uid == uid then unbindOf(slot) end
        surfaces[uid] = nil
        if statics then statics.drop(uid) end
    end

    -- A push for a page: every slot showing it (bound or still warm) gets it after what it has queued.
    function pool.push(pageId, packet)
        for _, slot in ipairs(slots) do
            if slot.dui and slot.page == pageId and slot.state ~= 'parked' then
                post(slot, { type = 'push', page = pageId, rev = packet.rev, ops = packet.ops, live = packet.live, laser = packet.laser })
            end
        end
    end

    -- A bake (P3): every page showing it (bound or still warm) folds the ops up to upTo into its ground, after what it
    -- has queued; one still fetching tiles loads the model as it is by then.
    function pool.baked(pageId, upTo)
        for _, slot in ipairs(slots) do
            if slot.dui and slot.page == pageId and slot.state ~= 'parked' and not slot.fetching then
                post(slot, { type = 'fold', page = pageId, upTo = upTo })
            end
        end
    end

    -- The page was replaced (a full open): slots showing it load it again.
    function pool.reload(pageId)
        for _, slot in ipairs(slots) do
            if slot.dui and slot.page == pageId then
                if slot.uid then
                    slot.loaded, slot.tries = nil, 0
                    if slot.state == 'ready' then sendLoad(slot) end
                else
                    slot.page, slot.loaded = nil, nil
                end
            end
        end
    end

    local function bound(uid)
        local s = surfaces[uid]
        local slot = s and s.slot and slots[s.slot]
        return s, slot and slot.uid == uid and slot or nil
    end

    local function mediaOf(uid)
        local m = media[uid]
        if not m then
            m = {}
            media[uid] = m
        end
        return m
    end

    -- Media (LiveBoard): what shows under the ink ({ mode = 'none'|'image'|'clear', url, fit, opacity, card, hideInk }).
    -- Kept for the board until dropMedia, so a surface made later shows it too.
    function pool.setLayer(uid, layer)
        mediaOf(uid).layer = layer
        local s, slot = bound(uid)
        if not s then return end
        s.layer = layer
        if slot then post(slot, { type = 'layer', layer = layer }) end
    end

    -- A texture drawn 3 mm behind the board (the media page), or nil.
    function pool.setUnderlay(uid, txd)
        mediaOf(uid).underlay = txd
        local s = surfaces[uid]
        if not s or s.underlay == txd then return end
        s.underlay = txd
        if txd then startDraw() end
    end

    -- The board's page is left out (YouTube allows nothing over its player); its underlay still draws.
    function pool.setInkHidden(uid, hidden)
        mediaOf(uid).inkHidden = hidden == true
        local s = surfaces[uid]
        if s then s.inkHidden = hidden == true end
    end

    -- The product stopped showing media on the board (it left the board's room).
    function pool.dropMedia(uid)
        media[uid] = nil
        local s, slot = bound(uid)
        if not s then return end
        if s.layer and slot then post(slot, { type = 'layer', layer = { mode = 'none' } }) end
        s.layer, s.underlay, s.inkHidden = nil, nil, false
    end

    -- Pages at once (the player's quality): more slots come empty, fewer let their pages go for good.
    function pool.setSlots(n)
        n = math.max(1, math.floor(tonumber(n) or 1))
        for i = #slots + 1, n do slots[i] = { index = i, gen = 0, state = 'none', out = {} } end
        for i = #slots, n + 1, -1 do
            local slot = slots[i]
            slot.gen = 0 -- a slot that goes is destroyed, never parked
            destroy(slot, false)
            slots[i] = nil
        end
        cfg.slots = n
        manage()
    end

    -- The editor draws this board's ink itself: the page hides its own.
    function pool.editing(uid, on)
        local s, slot = bound(uid)
        if not s then return end
        s.editing = on == true
        if slot then post(slot, { type = 'edit', on = s.editing }) end
    end

    function pool.has(uid) return surfaces[uid] ~= nil end

    function pool.stats()
        local out = { surfaces = 0, live = 0, parked = 0, loaded = 0, gens = {}, channel = channel }
        for _ in pairs(surfaces) do out.surfaces = out.surfaces + 1 end
        for i, slot in ipairs(slots) do
            out.gens[i] = slot.gen
            if slot.state == 'parked' then out.parked = out.parked + 1 elseif slot.dui then out.live = out.live + 1 end
            if slot.loaded then out.loaded = out.loaded + 1 end
        end
        return out
    end

    -- No frame comes after a stop: every page goes at once.
    AddEventHandler('onResourceStop', function(resource)
        if resource ~= RESOURCE then return end
        for _, slot in ipairs(slots) do
            if slot.dui then destroy(slot, true) end
        end
    end)

    return pool
end

return Ink.surfaces
