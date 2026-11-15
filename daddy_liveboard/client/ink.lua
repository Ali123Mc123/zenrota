-- LiveBoard on the ink engine, client side (Config.Engine = 'ink', 6-tahta-video-sanat.md P1): every board in the
-- room is a page of the ink pool (packages/ink: a few DUI pages, each showing one board), the editor writes on the
-- board itself, and client/media.lua's layer, underlay and hidden flag reach the pool. The board list, targets, rights
-- and media stay with client/main.lua (Canvas.client reads only the rights then). The server decides the same way
-- (server/ink.lua); without the built ink page both sides run the canvas engine.
BoardInk = { enabled = false }

local RESOURCE = GetCurrentResourceName()
local PAGE = 'web/dist/dui/ink.html'

if Config.Engine ~= 'ink' then return end
if not (Ink and Ink.client and Ink.surfaces and Ink.editor and Ink.codec) or not LoadResourceFile(RESOURCE, PAGE) then return end

local t = DL.locale.t
local ink, interact = Config.Ink or {}, Config.Interact
local RADIUS, HEIGHT = Config.Radius or 12.0, Config.Canvas.NearbyHeight or 4.0
local KVP = RESOURCE .. ':ink_quality'
local shapes = setmetatable({}, { __mode = 'k' }) -- board -> its floor area as a polygon
local rx, since = 0, GetGameTimer()               -- push bytes for /inkstats

local function levels() return ink.Pages or { low = 1, normal = 2, high = 3 } end

-- The player's quality (kept on this PC), else the server's default.
local function quality()
    local q = GetResourceKvpString(KVP)
    if q and levels()[q] then return q end
    return levels()[ink.Quality] and ink.Quality or 'normal'
end

local function pagesOf(q) return math.max(1, math.floor(levels()[q] or 2)) end

-- Boards no ink page shows, drawn from their last thumbnail at once (low 12, normal and high 24); 0 = off.
local function staticsOf(q)
    local n = math.floor(tonumber((ink.Statics or { low = 12, normal = 24, high = 24 })[q]) or 24)
    return n > 0 and math.min(24, n) or false
end

-- The room rule (Canvas.client's): the floor area, else the radius on the board's floor; slack m past it to stay.
local function inside(b, coords, slack)
    if b.zone then
        if slack <= 0 then return DL.geo.inZone(b.zone, coords) end
        local shape = shapes[b]
        if not shape then
            shape = { shape = 'polygon', points = b.zone.points, minZ = b.zone.minZ, maxZ = b.zone.maxZ }
            shapes[b] = shape
        end
        return DL.geo.distance(shape, coords) <= slack
    end
    return math.abs(coords.z - b.coords.z) <= HEIGHT + slack and #(coords - b.coords) <= RADIUS + slack
end

local function bytesOf(list, at)
    local n = 0
    for _, w in ipairs(type(list) == 'table' and list or {}) do
        n = n + 24 + (type(w) == 'table' and type(w[at]) == 'string' and #w[at] or 0)
    end
    return n
end

local client = Ink.client({
    event = RESOURCE .. ':ink',
    inside = inside,
    statics = staticsOf(quality()),
    onPush = function(_, p) rx = rx + bytesOf(p.ops, 4) + bytesOf(p.live, 3) end,
    surfaces = {
        page = PAGE, slots = pagesOf(quality()), tint = ink.Tint or 230, twoSided = ink.TwoSided == true,
        text = function() return DL.locale.table().dui end,
    },
})

local fill = ink.ScreenFill or {}
local editor = Ink.editor(client, {
    raster = ink.Raster or 2048,
    fillWidth = tonumber(fill.Width), fillHeight = tonumber(fill.Height),
    -- The editor closes before the server's reach (ServerTolerance + half the board) refuses the ops.
    reach = function(b) return math.max(1.0, (interact.ServerTolerance or 5.0) + math.max(b.width, b.height) * 0.5 - 2.5) end,
    tools = function(b) return { colors = b.colors, widths = ink.Widths } end,
    show = function(payload, b)
        payload.media = BoardInk.panel and BoardInk.panel(b.uid) or nil
        payload.content = BoardInk.contentInfo()
        DL.focus.acquire(function() BoardInk.close('focus') end)
        payload.voiceKey = BoardInk.voice(true)
        SendNUIMessage({ action = 'open', view = 'ink', payload = payload, locale = DL.locale.table().ui, theme = Config.Theme })
    end,
    hide = function()
        BoardInk.voice(false)
        BoardMedia.endPanel()
        SendNUIMessage({ action = 'close' })
        DL.focus.release()
    end,
})

-- Board content (P4) ---------------------------------------------------------------------------------------------

local PTT = 249 -- INPUT_PUSH_TO_TALK
local talking, typingText, held, voiceKey = false, false, false, nil

-- The letter or digit push-to-talk is bound to ('N'), or nil.
local function pttKey()
    local name = GetControlInstructionalButton(0, PTT, true)
    local key = type(name) == 'string' and name:match('^t_(%w)$')
    return key and key:upper() or nil
end

-- While drawing push-to-talk still works (KeepVoiceWhileDrawing); typing text takes it. The editor tells us when its
-- key is held and we press the game's control, so no other key reaches the game (the board's M, O, X shortcuts opened
-- the phone, College's announcements and emotes). A key we cannot name keeps the game's input as before.
-- Returns the key the editor watches.
function BoardInk.voice(on)
    on = on == true and ink.KeepVoiceWhileDrawing == true
    if talking == on then return voiceKey end
    talking, typingText, held = on, false, false
    voiceKey = on and pttKey() or nil
    SetNuiFocusKeepInput(on and voiceKey == nil)
    if not on then return nil end
    CreateThread(function()
        while talking do
            if voiceKey then
                if held then
                    for group = 0, 2 do SetControlNormal(group, PTT, 1.0) end
                end
            else
                DisableAllControlActions(0)
                DisableAllControlActions(1)
                DisableAllControlActions(2)
                if not typingText then EnableControlAction(0, PTT, true) end
            end
            Wait(0)
        end
    end)
    return voiceKey
end

-- The first accepted link start is the example in the picture box (PictureFolder: the old single setting).
local pictureLink = (ink.PictureLinks or { ink.PictureFolder })[1] or ''

function BoardInk.contentInfo()
    return {
        textSizes = ink.TextSizes or { 18, 28, 40, 64 }, maxPages = ink.MaxPages or 12, slides = ink.Slides or 8,
        textHint = ink.TextHint or 64, textMax = ink.TextMax or 128, imageHint = ink.ImageHint or 12, imageMax = ink.ImageMax or 24,
        link = pictureLink ~= '', folder = pictureLink, phone = DL.product.resource('studentphone') ~= nil,
        upload = math.min(ink.UploadKB or 0, ink.MaxImageKB or 400),
    }
end

-- NUI calls of the editor carry its token; content calls go to server/content.lua for the board being edited.
local function mine(data)
    return type(data) == 'table' and editor.token() ~= nil and data.token == editor.token()
end

RegisterNUICallback('ink:typing', function(data, cb)
    cb({})
    if not mine(data) or not talking then return end
    typingText = data.on == true
    if voiceKey then held = held and not typingText else SetNuiFocusKeepInput(not typingText) end
end)

RegisterNUICallback('ink:voice', function(data, cb)
    cb({})
    if mine(data) and talking and voiceKey then held = data.on == true and not typingText end
end)

-- A linked picture made smaller by the editor: its bytes go latent first, then the content call names them.
local uploadReq = 0
RegisterNUICallback('ink:upload', function(data, cb)
    local uid = editor.active()
    local limit = math.ceil(math.min(ink.UploadKB or 0, ink.MaxImageKB or 400) * 1024 / 3) * 4
    if not mine(data) or not uid or type(data.data) ~= 'string' or #data.data > limit then return cb({ ok = false, error = 'image_big' }) end
    uploadReq = uploadReq + 1
    local req = uploadReq
    TriggerLatentServerEvent(RESOURCE .. ':ink:upload', 250000, req, data.data)
    CreateThread(function()
        local result = lib.callback.await(RESOURCE .. ':content', false, 'upload', { uid = uid, url = data.url, req = req })
        cb(type(result) == 'table' and result or { ok = false, error = 'generic' })
    end)
end)

RegisterNUICallback('ink:content', function(data, cb)
    local uid = editor.active()
    if not mine(data) or not uid or type(data.action) ~= 'string' then return cb({ ok = false, error = 'validation' }) end
    local body = type(data.data) == 'table' and data.data or {}
    body.uid = uid
    CreateThread(function()
        local result = lib.callback.await(RESOURCE .. ':content', false, data.action, body)
        cb(type(result) == 'table' and result or { ok = false, error = 'generic' })
    end)
end)

RegisterNUICallback('ink:textgone', function(data, cb)
    cb({})
    if mine(data) and tonumber(data.page) and type(data.ck) == 'string' then
        TriggerServerEvent(RESOURCE .. ':ink:textgone', tonumber(data.page), data.ck)
    end
end)

local laserAt = 0
RegisterNUICallback('ink:laser', function(data, cb)
    cb({})
    if not mine(data) or tonumber(data.page) ~= editor.page() then return end
    local t, x, y = GetGameTimer(), math.floor(tonumber(data.x) or -1), math.floor(tonumber(data.y) or -1)
    if x >= 0 and t - laserAt < 70 then return end
    laserAt = t
    TriggerServerEvent(RESOURCE .. ':ink:laser', editor.page(), x, y)
end)

-- client/media.lua draws through Surface: with ink, a board's layer, underlay and hidden flag go to the pool.
for _, name in ipairs({ 'setLayer', 'setUnderlay', 'setInkHidden' }) do
    local pooled = client.surfaces[name]
    Surface[name] = function(uid, value) return pooled(uid, value) end
end

BoardInk.enabled = true

-- Every board of the list (Canvas.client's items): boards that draw get an ink page, screens their colour and media.
function BoardInk.set(items, streamOf)
    local list = {}
    for uid, item in pairs(items) do
        local preset = Config.Presets[item.preset] or Config.Presets.classroom
        list[uid] = {
            uid = uid, label = item.label, coords = item.coords, heading = item.heading, width = item.width, height = item.height,
            background = item.background, zone = item.zone, ink = preset.drawing == true,
            streamDistance = streamOf and streamOf(item) or nil, colors = preset.colors or Config.Tools.Colors,
        }
    end
    client.set(list)
end

-- What a board lets this player do (Canvas.client's mount asks this instead of reading the strokes).
function BoardInk.rights(uid)
    return lib.callback.await(RESOURCE .. ':ink:flags', false, uid)
end

-- The player left the board's room: its media goes from the board.
function BoardInk.detach(uid)
    client.surfaces.dropMedia(uid)
end

-- The editor on a board (viewOnly: to look); waits for the board's page.
function BoardInk.open(uid, viewOnly)
    if editor.active() or DL.focus.owner() == RESOURCE then return end
    local ok, why = editor.open(uid, viewOnly == true)
    if not ok and why ~= 'busy' and BoardInk.notify then BoardInk.notify(why == 'not_found' and 'not_found' or 'not_ready') end
end

function BoardInk.close(reason) editor.close(reason) end
function BoardInk.active() return editor.active() end

-- A character change closes the editor.
DL.fw.onUnloaded(function() editor.close('unloaded') end)

-- The player's own quality: ink pages drawn at once (low 1, normal 2, high 3).
if (ink.QualityCommand or '') ~= '' then
    RegisterCommand(ink.QualityCommand, function(_, args)
        local q = tostring(args[1] or ''):lower()
        if not levels()[q] then
            return lib.notify({ description = t('ink.quality', t('ink.levels.' .. quality())), type = 'inform' })
        end
        SetResourceKvp(KVP, q)
        client.surfaces.setSlots(pagesOf(q))
        lib.notify({ description = t('ink.quality_set', t('ink.levels.' .. q)), type = 'success' })
    end, false)
end

-- /inkstats: the pool, the DUI budget, the cache, the outbox and what pushes bring in; the server's pages for admins.
RegisterCommand('inkstats', function()
    CreateThread(function()
        local s = client.surfaces.stats()
        local free, max, freePx, maxPx = 0, 0, 0, 0
        pcall(function() free, max, freePx, maxPx = exports.daddy_lib:duiBudget() end)
        local secs = math.max(1, (GetGameTimer() - since) / 1000)
        local pages, waiting = 0, 0
        for id in pairs(client.models) do
            pages = pages + 1
            waiting = waiting + client.outbox.count(id)
        end
        local lines = {
            ('pool: %d live, %d parked, %d drawn of %d boards, generations %s, ready channel %s, quality %s'):format(
                s.live, s.parked, s.loaded, s.surfaces, table.concat(s.gens, '/'), tostring(s.channel), quality()),
            ('dui budget: %s of %s pages and %.1f of %.1f MPx free'):format(free or '?', max or '?', (freePx or 0) / 1e6, (maxPx or 0) / 1e6),
            ('pages cached %d, ops waiting %d, pushes in %.2f KB/s over %ds, editor %s'):format(
                pages, waiting, rx / 1024 / secs, math.floor(secs), tostring(editor.active() or '-')),
        }
        rx, since = 0, GetGameTimer()
        local server = lib.callback.await(RESOURCE .. ':ink:stats', false)
        if type(server) == 'table' then
            lines[#lines + 1] = ('server: engine %s, %d pages in memory, %d ops, %.1f KB, %d subscribers'):format(
                tostring(server.version), server.pages or 0, server.ops or 0, (server.bytes or 0) / 1024, server.subs or 0)
        end
        for _, line in ipairs(lines) do print('[inkstats] ' .. line) end
        lib.notify({ description = t('ink.stats'), type = 'inform' })
    end)
end, false)
