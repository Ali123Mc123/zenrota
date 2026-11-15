-- LiveBoard media on the client (6-tahta-video-sanat.md 3.3): the screens this player watches, the one media DUI page
-- (it holds the video decoder lease and is drawn behind every board of its screen group), the sound (screen volume x
-- own volume x ducking x distance to the nearest board x room, a soft fade past the floor area), the page's reports
-- (at most one a second to the server), each board page's layer, and the media panel bridge.
BoardMedia = {}

local RESOURCE = GetCurrentResourceName()
local cfg = Config.Media
local VOL, SND, PAGE, DEC = cfg.Volume, cfg.Sound, cfg.Page, cfg.Decoder
local S = BoardSound
local t = DL.locale.t
local PAGE_FILE, PAGE_ID, LEASE = 'web/dist/dui/media.html', 'media', 'screen:'
local STATE_MS, CLOCK_MS = 3000, 5000 -- the full state and the clock go to the page this often, besides every change
local DUCK = S.db(SND.DuckDb or 0)
local FORWARD = { ready = true, playing = true, stalled = true, error = true, duration = true, live = true, ended = true }
local ORDER = { 'error', 'ended', 'live', 'duration', 'stalled', 'playing', 'ready' }
local PANEL = {
    library = true, probe = true, add = true, update = true, delete = true, show = true, hide = true,
    control = true, settings = true, playlist = true, takeover = true,
}
local KVP_VOLUME, KVP_STREAMER = 'media:volume', 'media:streamer'

local screens = {} -- screen -> the latest packet
local tracked = {} -- screen -> { boards = { [uid] = item }, mounted = { [uid] = true }, leftAt, stillAt, held }
local layers = {}  -- uid -> the layer last sent (encoded)
local spots = {}   -- uid -> { interior, room } learnt where the board stands
local shapes = setmetatable({}, { __mode = 'k' }) -- item -> its floor area as a polygon
local phases = {}  -- screen -> { ev, rev, code }: what the page last said
local stalls = {}  -- screen -> rev the page found stalled
local reports, sending, looping = {}, false, false
local page, panel
local comfort = { volume = SND.Personal, streamer = false }
local duckUntil = 0
local START, made = ('%x'):format(GetGameTimer()), 0

local function call(action, data)
    local result = lib.callback.await(RESOURCE .. ':media', false, action, data)
    return type(result) == 'table' and result or { ok = false, error = 'integration_unavailable' }
end

local function timed(item)
    return item ~= nil and (item.kind == 'video' or item.kind == 'audio')
end

-- Own volume and streamer mode, kept on this PC.
local function loadComfort()
    local volume = tonumber(GetResourceKvpString(KVP_VOLUME) or '')
    comfort.volume = volume and math.max(0.0, math.min(1.0, volume)) or SND.Personal
    comfort.streamer = GetResourceKvpInt(KVP_STREAMER) == 1
end

-- Page -----------------------------------------------------------------------

local refreshScreen

-- Messages carry the page's nonce: an embedded YouTube frame cannot read it, so it cannot fake one.
local function post(message)
    if not page or not page.ready then return end
    message.nonce = page.nonce
    SendDuiMessage(page.dui, json.encode(message))
end

-- A board of the screen (mounted first) for the page's aspect and colour.
local function anyBoard(screen)
    local rec = tracked[screen]
    local uid = rec and (next(rec.mounted) or next(rec.boards))
    return uid and rec.boards[uid]
end

local function sendState()
    if not page or not page.ready then return end
    page.stateAt = GetGameTimer()
    local p = page.screen and screens[page.screen]
    if not p then return post({ type = 'idle' }) end
    local board = anyBoard(page.screen)
    post({
        type = 'state', screen = page.screen, rev = p.rev, play = p.play, anchor = p.anchor, pos = p.pos, after = p.after,
        error = p.error, item = p.item, fit = p.fit, opacity = p.opacity, now = DL.clock.now(), origin = cfg.YouTubeOrigin,
        bg = board and board.background or '#000000', aspect = board and board.width / board.height or nil,
    })
end

local function markReady(p)
    if page ~= p or p.ready then return end
    p.ready, p.clockAt = true, GetGameTimer()
    sendState()
    post({ type = 'clock', now = DL.clock.now() })
    if p.screen then refreshScreen(p.screen) end
end

-- Version + content hash of the built page: a new build gets a new URL, so CEF never runs an old copy.
local function pageUrl(nonce)
    local html = LoadResourceFile(RESOURCE, PAGE_FILE)
    if not html then return nil end
    local stamp = ('%s.%08x'):format(GetResourceMetadata(RESOURCE, 'version', 0) or '0', GetHashKey(html) & 0xffffffff)
    return ('https://cfx-nui-%s/%s?v=%s#%s'):format(RESOURCE, PAGE_FILE, stamp, nonce)
end

-- Only when the DUI budget takes it back (or on a stop): blank first, destroyed a frame later (now: both at once).
local function retirePage(now)
    local p = page
    if not p then return end
    page = nil
    DL.dui.release(PAGE_ID)
    SetDuiUrl(p.dui, 'about:blank')
    if p.screen then refreshScreen(p.screen) end
    if now then return DestroyDui(p.dui) end
    CreateThread(function()
        Wait(0)
        DestroyDui(p.dui)
    end)
end

-- Ready on its hello; without one the page counts as loaded 0.5 s after the DUI is up, and loads once more after 5 s
-- of silence (the 3 s state heals whatever was missed).
local function awaitReady(p)
    local load = p.loads
    CreateThread(function()
        local waited = 0
        while page == p and p.loads == load and not p.ready and not IsDuiAvailable(p.dui) and waited < 10000 do
            Wait(100)
            waited = waited + 100
        end
        Wait(500)
        if p.loads ~= load then return end
        markReady(p)
        Wait(4500)
        if page == p and p.loads == load and not p.hello and not p.parked then SetDuiUrl(p.dui, p.url) end
    end)
end

-- One page and one texture name for the session: parked on about:blank when idle, woken with its URL again.
local function createPage(distance)
    local nonce = lib.string.random('aaaaaaaa1111')
    local url = pageUrl(nonce)
    if not url then return nil end
    if not DL.dui.acquire(PAGE_ID, distance, function() retirePage(false) end) then return nil end
    made = made + 1
    local p = { nonce = nonce, url = url, loads = 1, txd = ('%s_media_%s_%d'):format(RESOURCE, START, made) }
    p.dui = CreateDui(url, PAGE.Width, PAGE.Height)
    CreateRuntimeTextureFromDuiHandle(CreateRuntimeTxd(p.txd), 'tex', GetDuiHandle(p.dui))
    page = p
    awaitReady(p)
    return p
end

-- A parked page frees its memory; its lease stays (with no distance, so it is the first to go when the budget fills).
local function parkPage(p)
    p.parked, p.ready, p.hello, p.loads = true, false, false, p.loads + 1
    SetDuiUrl(p.dui, 'about:blank')
    DL.dui.acquire(PAGE_ID, 1e9)
end

local function wakePage(p)
    p.parked, p.ready, p.hello, p.loads, p.idleAt = false, false, false, p.loads + 1, nil
    SetDuiUrl(p.dui, p.url)
    awaitReady(p)
end

-- Board layers ---------------------------------------------------------------

local function coverOf(item)
    if item.lane == 'youtube' and item.ref and item.ref ~= '' then return ('https://i.ytimg.com/vi/%s/mqdefault.jpg'):format(item.ref) end
    return item.thumbnail ~= '' and item.thumbnail or nil
end

local function cardOf(p, item, screen)
    if p.error then return { key = p.error, title = item.title } end
    if p.play == 'ended' then return { key = 'ended', title = item.title } end
    if stalls[screen] == p.rev then return { key = 'slow', title = item.title } end
end

-- none: the board's colour; image: a picture (or a video's cover) under the drawing; clear: the media page behind it.
local function layerOf(p, screen, decoding)
    local item = p and p.item
    if not item then return { mode = 'none' } end
    if item.kind == 'image' then return { mode = 'image', url = item.url, fit = p.fit, opacity = p.opacity } end
    local card = cardOf(p, item, screen)
    if decoding then return { mode = 'clear', card = card } end
    local cover = coverOf(item)
    return { mode = cover and 'image' or 'none', url = cover, fit = p.fit, opacity = p.opacity, card = card or (not cover and { key = item.kind, title = item.title } or nil) }
end

local function refreshBoard(uid, screen)
    local p = screens[screen]
    local item = p and p.item
    local decoding = page ~= nil and page.ready and page.screen == screen and timed(item)
    local layer = layerOf(p, screen, decoding)
    -- YouTube allows nothing over its player: while it plays behind with no card the board page is left out. The
    -- strokes alone hide (hideInk) while it plays or the screen's ink is off; pictures, covers and cards stay.
    local tube = (decoding and item.lane == 'youtube' and p.play == 'playing' and not cfg.InkOverYouTube) == true
    Surface.setUnderlay(uid, decoding and page.txd or nil)
    Surface.setInkHidden(uid, tube and layer.card == nil)
    if item and (tube or p.ink == false) then layer.hideInk = true end
    local encoded = json.encode(layer)
    if layers[uid] == encoded then return end
    layers[uid] = encoded
    Surface.setLayer(uid, layer)
end

refreshScreen = function(screen)
    local rec = tracked[screen]
    if not rec then return end
    for uid in pairs(rec.mounted) do refreshBoard(uid, screen) end
end

-- Sound ----------------------------------------------------------------------

local function zoneShape(item)
    local shape = shapes[item]
    if not shape then
        shape = { shape = 'polygon', points = item.zone.points, minZ = item.zone.minZ, maxZ = item.zone.maxZ }
        shapes[item] = shape
    end
    return shape
end

-- Where a board without a floor area stands: learnt from the player once they stand within 3 m of it.
local function spotOf(uid, d, interior, room)
    local spot = spots[uid]
    if not spot and d <= 3.0 then
        spot = { interior = interior, room = room }
        spots[uid] = spot
    end
    return spot
end

-- How well the player hears a screen (the best of its boards), how far its nearest board is, and whether they stand in
-- its room (a floor area, or a mounted board without one).
local function viewOf(rec, p, here, interior, room)
    local near, far = p and p.near or VOL.FullDist, p and p.far or VOL.MaxDist
    local factor, nearest, inZone = 0.0, math.huge, false
    for uid, item in pairs(rec.boards) do
        local d = S.nearest(item, here)
        nearest = math.min(nearest, d)
        local edge, part = 1.0, 1.0
        if item.zone then
            local out = DL.geo.distance(zoneShape(item), here)
            inZone = inZone or out <= 0
            edge = S.edge(out, SND.EdgeFade)
        else
            inZone = inZone or rec.mounted[uid] == true
            local spot = spotOf(uid, d, interior, room)
            if spot then part = S.room(spot.interior, spot.room, interior, room, SND.OtherRoom, SND.Outside) end
        end
        factor = math.max(factor, S.board(d, near, far, VOL.Curve, edge, part))
    end
    return { factor = factor, distance = nearest, inZone = inZone }
end

-- -6 dB while another player within 8 m talks, held 1.5 s past the last word; looked for only while not ducked.
local function duck(now)
    if DUCK >= 1.0 then return 1.0 end
    if now >= duckUntil then
        local me, here = PlayerId(), GetEntityCoords(PlayerPedId())
        for _, player in ipairs(GetActivePlayers()) do
            if player ~= me and NetworkIsPlayerTalking(player) then
                local ped = GetPlayerPed(player)
                if ped ~= 0 and #(GetEntityCoords(ped) - here) <= SND.DuckRadius then
                    duckUntil = now + SND.DuckHoldMs
                    break
                end
            end
        end
    end
    return now < duckUntil and DUCK or 1.0
end

local function gainOf(now, p, view)
    if not p or not view or p.play ~= 'playing' or IsPauseMenuActive() then return 0.0 end
    local own = comfort.volume
    if comfort.streamer and p.item and p.item.lane == 'youtube' then own = 0.0 end
    if own <= 0.0 or view.factor <= 0.0 or (p.vol or 0) <= 0 then return 0.0 end
    return S.gain(p.vol, own, duck(now), view.factor)
end

-- Screens ----------------------------------------------------------------------

local function untrack(screen)
    local rec = tracked[screen]
    if not rec then return end
    tracked[screen] = nil
    if rec.held then DL.dui.videoRelease(LEASE .. screen) end
    for uid in pairs(rec.boards) do TriggerServerEvent(RESOURCE .. ':media:close', uid) end
    screens[screen], phases[screen], stalls[screen] = nil, nil, nil
end

-- The decoder: every screen with a video or sound asks while it plays (a paused or ended one keeps it 10 s); the page
-- shows the best one held.
local function decide(now, views)
    local best, top
    for screen, rec in pairs(tracked) do
        local p = screens[screen]
        local item = p and p.item
        local playing = timed(item) and p.play == 'playing'
        if playing then rec.stillAt = nil elseif timed(item) then rec.stillAt = rec.stillAt or now end
        local view = views[screen]
        local want = view ~= nil and timed(item) and (playing or (rec.held and now - rec.stillAt < DEC.PausedRelease * 1000))
        if want then
            local score = S.score(view.inZone, playing, view.distance, DEC)
            rec.held = DL.dui.video(LEASE .. screen, score)
            if rec.held and (not top or score > top) then best, top = screen, score end
        elseif rec.held then
            rec.held = false
            DL.dui.videoRelease(LEASE .. screen)
        end
    end
    return best
end

-- A page that could not be made (budget full, UI not built) is tried again 5 s later; an idle one parks after 3 min.
local retryAt = 0
local function showOnPage(now, best, views)
    if best and not page and now >= retryAt and not createPage(views[best].distance) then retryAt = now + 5000 end
    if not page then return end
    if best and page.parked then wakePage(page) end
    if page.screen ~= best then
        local before = page.screen
        page.screen, page.gainSent, page.idleAt = best, nil, nil
        sendState()
        if before then refreshScreen(before) end
        if best then refreshScreen(best) end
    end
    if not best then
        page.idleAt = page.idleAt or now
        if not page.parked and now - page.idleAt >= PAGE.IdleMinutes * 60000 then parkPage(page) end
        return
    end
    if now - (page.leaseAt or 0) >= 1000 then
        page.leaseAt = now
        DL.dui.acquire(PAGE_ID, views[best].distance)
    end
end

local function feedPage(now, views)
    if not page or not page.ready then return end
    if now - (page.stateAt or 0) >= STATE_MS then sendState() end
    if now - (page.clockAt or 0) >= CLOCK_MS then
        page.clockAt = now
        post({ type = 'clock', now = DL.clock.now() })
    end
    if not page.screen then return end
    local gain = gainOf(now, screens[page.screen], views[page.screen])
    if S.due(gain, page.gainSent, page.gainAt, now, SND.Step, SND.ResendMs) then
        page.gainSent, page.gainAt = gain, now
        post({ type = 'gain', value = gain })
    end
end

-- Every 200 ms while a watched screen has a video or sound (1 s otherwise): views, the 15 s warm keep, the decoder,
-- the page and its sound. Returns the wait.
local function tick()
    local now = GetGameTimer()
    local ped = PlayerPedId()
    local here = GetEntityCoords(ped)
    local interior, room = GetInteriorFromEntity(ped), GetRoomKeyFromEntity(ped)
    local views, hot = {}, false
    for screen, rec in pairs(tracked) do
        local p = screens[screen]
        local view = viewOf(rec, p, here, interior, room)
        if next(rec.mounted) or view.factor > 0 then
            rec.leftAt = nil
        else
            rec.leftAt = rec.leftAt or now
        end
        if rec.leftAt and now - rec.leftAt >= PAGE.WarmSeconds * 1000 then
            untrack(screen)
        else
            views[screen] = view
            hot = hot or timed(p and p.item)
        end
    end
    showOnPage(now, decide(now, views), views)
    feedPage(now, views)
    return (hot or (page and page.screen)) and SND.TickMs or 1000
end

-- Runs while a screen is watched or the page is awake; a parked page and no screen cost nothing.
local function start()
    if looping then return end
    looping = true
    CreateThread(function()
        while next(tracked) or (page and not page.parked) do Wait(tick()) end
        looping = false
    end)
end

-- Packets: older revisions never overwrite newer ones.
function BoardMedia.apply(data)
    if type(data) ~= 'table' or type(data.screen) ~= 'string' then return end
    local previous = screens[data.screen]
    if previous and (tonumber(data.rev) or 0) < (previous.rev or 0) then return end
    DL.clock.hint(data.now)
    if not tracked[data.screen] and not (panel and panel.screen == data.screen) then return end
    screens[data.screen] = data
    if previous and previous.rev == data.rev then return end
    if page and page.screen == data.screen then sendState() end
    refreshScreen(data.screen)
    if panel and panel.screen == data.screen then
        local out = {}
        for key, value in pairs(data) do out[key] = value end
        out.at = DL.clock.now()
        SendNUIMessage({ action = 'media:state', data = out })
    end
    start()
    if tracked[data.screen] and timed(data.item) then tick() end -- the decoder and the page at once, not at the next look
end

-- A board was mounted: it watches its screen from now on (open returns the state at once).
function BoardMedia.attach(item)
    local rec = tracked[item.screen]
    if not rec then
        rec = { boards = {}, mounted = {} }
        tracked[item.screen] = rec
    end
    rec.boards[item.uid], rec.mounted[item.uid], rec.leftAt = item, true, nil
    layers[item.uid] = nil
    refreshBoard(item.uid, item.screen)
    start()
    CreateThread(function()
        local result = call('open', { uid = item.uid })
        if result.ok then BoardMedia.apply(result.data) end
    end)
end

-- Unmounted: the screen stays watched while it is heard, then 15 s more (the page keeps its video loaded).
function BoardMedia.detach(uid)
    for _, rec in pairs(tracked) do rec.mounted[uid] = nil end
    layers[uid] = nil
end

RegisterNetEvent(RESOURCE .. ':media:sync', BoardMedia.apply)

-- Reports from the page: only with its nonce, only for what it plays now; on to the server at most once a second.
local function forward(screen, rev, ev, code, dur)
    local rec = tracked[screen]
    local uid = rec and (next(rec.mounted) or next(rec.boards))
    if not uid then return end
    reports[ev] = { screen = screen, uid = uid, rev = rev, ev = ev, code = code, dur = dur }
    if sending then return end
    sending = true
    CreateThread(function()
        while true do
            local entry
            for _, name in ipairs(ORDER) do
                if reports[name] then
                    entry, reports[name] = reports[name], nil
                    break
                end
            end
            if not entry then break end
            local p = screens[entry.screen]
            if p and p.rev == entry.rev then
                TriggerServerEvent(RESOURCE .. ':media:report', { uid = entry.uid, rev = entry.rev, ev = entry.ev, code = entry.code, dur = entry.dur })
                Wait(1000)
            end
        end
        sending = false
    end)
end

RegisterNUICallback('media:report', function(data, cb)
    cb({})
    if type(data) ~= 'table' or not page or data.nonce ~= page.nonce then return end
    local ev = tostring(data.ev or '')
    if ev == 'hello' then
        page.hello = true
        return markReady(page)
    end
    local screen = data.screen
    local p = type(screen) == 'string' and screens[screen]
    if not p or screen ~= page.screen or tonumber(data.rev) ~= p.rev then return end
    local code = type(data.code) == 'string' and data.code:sub(1, 32) or nil
    phases[screen] = { ev = ev, rev = p.rev, code = code }
    if ev == 'stalled' and stalls[screen] ~= p.rev then
        stalls[screen] = p.rev
        refreshScreen(screen)
    elseif ev == 'playing' and stalls[screen] then
        stalls[screen] = nil
        refreshScreen(screen)
    end
    if panel and panel.screen == screen then SendNUIMessage({ action = 'media:phase', data = phases[screen] }) end
    if FORWARD[ev] then forward(screen, p.rev, ev, code, tonumber(data.dur)) end
end)

-- The runner hears how many viewers have a problem.
RegisterNetEvent(RESOURCE .. ':media:issues', function(screen, n)
    if panel and panel.screen == screen then SendNUIMessage({ action = 'media:issues', data = { screen = screen, n = tonumber(n) or 0 } }) end
end)

-- Panel ------------------------------------------------------------------------

local function stamped(packet)
    if type(packet) ~= 'table' then return nil end
    local out = {}
    for key, value in pairs(packet) do out[key] = value end
    out.at = DL.clock.now()
    return out
end

-- A panel session for a board (the paint view's mini player or the Media option): its token goes with every call.
function BoardMedia.panelFor(item, standalone)
    panel = { uid = item.uid, screen = item.screen, token = lib.string.random('aaaaaaaa1111aaaa'), standalone = standalone == true }
    return {
        uid = item.uid, token = panel.token, label = item.label, screen = stamped(screens[item.screen]),
        phase = phases[item.screen], origin = cfg.YouTubeOrigin,
    }
end

function BoardMedia.endPanel()
    panel = nil
end

function BoardMedia.open(item)
    if DL.focus.owner() == RESOURCE then return end
    local payload = BoardMedia.panelFor(item, true)
    DL.focus.acquire(BoardMedia.close)
    SendNUIMessage({ action = 'open', view = 'media', locale = DL.locale.table().ui, theme = Config.Theme, payload = payload })
end

function BoardMedia.close()
    if not panel or not panel.standalone then return end
    panel = nil
    SendNUIMessage({ action = 'close' })
    DL.focus.release()
end

-- Every panel action goes to the server with the board's uid; answers that carry a screen update it at once.
RegisterNUICallback('media:call', function(data, cb)
    if type(data) ~= 'table' or not panel or data.token ~= panel.token then return cb({ ok = false, error = 'no_permission' }) end
    local action = tostring(data.action)
    if not PANEL[action] then return cb({ ok = false, error = 'validation' }) end
    local body = type(data.data) == 'table' and data.data or {}
    body.uid = panel.uid
    local result = call(action, body)
    local out = result.data
    if result.ok and type(out) == 'table' then
        if type(out.screen) == 'table' then
            BoardMedia.apply(out.screen)
            out.screen = stamped(out.screen)
        elseif type(out.screen) == 'string' and out.rev then
            BoardMedia.apply(out)
            result.data = stamped(out)
        end
    end
    cb(result)
end)

RegisterNUICallback('media:close', function(_, cb)
    cb({ ok = true })
    BoardMedia.close()
end)

-- Own volume and streamer mode ---------------------------------------------------

if cfg.ComfortCommand and cfg.ComfortCommand ~= '' then
    RegisterCommand(cfg.ComfortCommand, function()
        local input = lib.inputDialog(t('comfort.title'), {
            { type = 'slider', label = t('comfort.volume'), min = 0, max = 100, step = 5, default = math.floor(comfort.volume * 100 + 0.5) },
            { type = 'checkbox', label = t('comfort.streamer'), checked = comfort.streamer },
        })
        if not input then return end
        comfort.volume = math.max(0, math.min(100, tonumber(input[1]) or 80)) / 100
        comfort.streamer = input[2] == true
        SetResourceKvp(KVP_VOLUME, tostring(comfort.volume))
        SetResourceKvpInt(KVP_STREAMER, comfort.streamer and 1 or 0)
        lib.notify({ description = t(comfort.streamer and 'comfort.saved_streamer' or 'comfort.saved', math.floor(comfort.volume * 100 + 0.5)), type = 'success' })
    end, false)
    TriggerEvent('chat:addSuggestion', '/' .. cfg.ComfortCommand, t('comfort.help'))
end

-- Lifecycle --------------------------------------------------------------------

-- A character change closes the panel; what the boards show goes on (the next character may stand in the same room).
DL.fw.onUnloaded(function()
    if panel and panel.standalone then BoardMedia.close() end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE then return end
    if page then
        local p = page
        page = nil
        SetDuiUrl(p.dui, 'about:blank')
        DestroyDui(p.dui)
    end
end)

loadComfort()
