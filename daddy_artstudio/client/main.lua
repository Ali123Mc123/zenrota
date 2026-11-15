-- Art Studio client (6-tahta-video-sanat.md 3.5, 4.4): every canvas in the room is a page of the ink pool (a few DUI
-- pages, the rest their last picture, paper behind each), and the studio opens full screen on a canvas (Studio mode:
-- zoom, bucket, eyedropper; "Paint in the world" turns the camera to it). The canvas list comes once and then one row
-- per change; what a canvas allows is asked when the studio opens.
local RESOURCE = GetCurrentResourceName()
local PAGE = 'web/dist/dui/ink.html'
local KVP = RESOURCE .. ':colors'
local t = DL.locale.t
local canvases = {} -- uid -> canvas as the ink client takes it
local opening = nil -- the info the studio opens with

Studio = {}

function Studio.notify(code, kind)
    local key = 'errors.' .. tostring(code)
    local text = t(key)
    lib.notify({ description = text == key and t('errors.generic') or text, type = kind or 'error' })
end
local notify = Studio.notify

local built = LoadResourceFile(RESOURCE, PAGE) ~= nil
if not built then print(('[%s] %s is not built yet: canvases show until the UI is built'):format(RESOURCE, PAGE)) end

local client = Ink.client({
    event = RESOURCE .. ':ink',
    inside = function(b, coords, slack) return Room.inside(b, coords, slack) end,
    statics = (Config.Surface.Statics or 24) > 0 and Config.Surface.Statics or false, -- canvases shown from their last picture
    surfaces = {
        page = PAGE, slots = Config.Surface.Pages, width = Config.Surface.Size, height = Config.Surface.Size,
        stream = Config.Surface.Stream, tint = Config.Surface.Tint, twoSided = Config.Surface.TwoSided == true,
    },
})

-- Recent colours, kept on this PC.
local function recent()
    local ok, list = pcall(json.decode, GetResourceKvpString(KVP) or '[]')
    return ok and type(list) == 'table' and list or {}
end

local editor = Ink.editor(client, {
    raster = Config.Resolution.Default,
    -- The studio closes before the server's reach refuses the ops.
    reach = function(b) return math.max(1.0, Room.reach(b) - 1.0) end,
    show = function(payload, b)
        payload.raster = b.resolution or Config.Resolution.Default
        payload.paper = b.background
        payload.info = opening
        payload.tools = { colors = Config.Studio.Colors, widths = Config.Studio.Widths }
        payload.recent = recent()
        DL.focus.acquire(function() Studio.close('focus') end)
        SendNUIMessage({ action = 'open', view = 'studio', payload = payload, locale = DL.locale.table().ui, theme = Config.Theme })
    end,
    hide = function()
        SendNUIMessage({ action = 'close' })
        DL.focus.release()
    end,
})

-- The studio on a canvas (look: only to look and read its credits).
function Studio.open(uid, look)
    if editor.active() or DL.focus.owner() == RESOURCE then return end
    if not built then return notify('not_built') end
    local res = lib.callback.await(RESOURCE .. ':info', false, uid)
    if type(res) ~= 'table' or not res.ok then return notify(type(res) == 'table' and res.error or 'generic') end
    opening = res.data
    local ok, why = editor.open(uid, look == true or not res.data.role, true)
    opening = nil
    if not ok and why ~= 'busy' then notify(why == 'not_found' and 'not_found' or 'not_ready') end
end

function Studio.close(reason) editor.close(reason) end
Studio.surfaces = client.surfaces
function Studio.active() return editor.active() end

-- The list ----------------------------------------------------------------------------------------------------

local function idle() return not IsPedInAnyVehicle(PlayerPedId(), false) end

local function target(c)
    DL.target.addBox(RESOURCE .. ':' .. c.uid, {
        coords = c.coords, heading = c.heading + 90.0, size = vector3(c.width + 0.2, 0.6, c.height + 0.2),
        distance = Config.Interact.Distance,
        options = {
            { label = t('target.paint'), icon = 'fa-solid fa-palette', canInteract = idle, onSelect = function() CreateThread(function() Studio.open(c.uid) end) end },
            { label = t('target.look'), icon = 'fa-solid fa-eye', canInteract = idle, onSelect = function() CreateThread(function() Studio.open(c.uid, true) end) end },
        },
    })
end

local function shape(row)
    local c = row.coords
    return {
        uid = row.uid, label = row.label, coords = vector3(c.x, c.y, c.z), heading = row.heading + 0.0, width = row.width + 0.0,
        height = row.height + 0.0, background = row.background, resolution = row.resolution, zone = row.zone,
        mode = row.mode, hidden = row.hidden == true, ink = row.hidden ~= true,
    }
end

local function apply()
    client.set(canvases)
    for uid, c in pairs(canvases) do client.surfaces.setUnderlay(uid, Paper.of(c.background)) end
end

local function put(uid, row)
    local old = canvases[uid]
    if old then DL.target.remove(RESOURCE .. ':' .. uid) end
    if not row then
        canvases[uid] = nil
        return
    end
    local c = shape(row)
    canvases[uid] = c
    target(c)
    -- Hidden or shown again: the page goes, or is opened again, when the canvas mounts again.
    if old and old.hidden ~= c.hidden and client.mounted[uid] then client.unmount(uid) end
end

RegisterNetEvent(RESOURCE .. ':canvas', function(uid, row)
    if type(uid) ~= 'string' then return end
    if editor.active() == uid and (not row or row.hidden) then editor.close('gone') end
    put(uid, type(row) == 'table' and row or nil)
    apply()
end)

CreateThread(function()
    DL.fw.awaitLogin()
    local list
    for _ = 1, 12 do
        list = lib.callback.await(RESOURCE .. ':list', false)
        if type(list) == 'table' then break end
        Wait(5000)
    end
    for _, row in ipairs(list or {}) do put(row.uid, row) end
    apply()
end)

-- The studio's own calls ---------------------------------------------------------------------------------------

local function mine(data)
    return type(data) == 'table' and editor.active() ~= nil and data.uid == editor.active()
end

RegisterNUICallback('art:info', function(data, cb)
    if not mine(data) then return cb({ ok = false }) end
    cb(lib.callback.await(RESOURCE .. ':info', false, data.uid) or { ok = false })
end)

RegisterNUICallback('art:act', function(data, cb)
    if not mine(data) or type(data.action) ~= 'string' then return cb({ ok = false }) end
    cb(lib.callback.await(RESOURCE .. ':act', false, data.uid, data.action, type(data.data) == 'table' and data.data or nil) or { ok = false })
end)

RegisterNUICallback('art:colors', function(data, cb)
    cb({})
    local out = {}
    for _, c in ipairs(type(data) == 'table' and type(data.colors) == 'table' and data.colors or {}) do
        if type(c) == 'string' and c:match('^#%x%x%x%x%x%x$') and #out < 12 then out[#out + 1] = c:lower() end
    end
    SetResourceKvp(KVP, json.encode(out))
end)

-- The painting at 1024 px goes up in pieces; the canvas goes on display.
RegisterNUICallback('art:exhibit', function(data, cb)
    if not mine(data) or type(data.image) ~= 'string' then return cb({ ok = false }) end
    local ok, why = DL.net.upload('art_exhibit', data.image, { uid = data.uid }, 30000)
    cb({ ok = ok == true, error = not ok and tostring(why) or nil })
end)

-- History pictures (P3 snapshots' thumbnails) as data URLs.
local MIME = { ['/9j/'] = 'jpeg', iVBO = 'png', UklG = 'webp' }
RegisterNUICallback('art:thumbs', function(data, cb)
    local hashes = {}
    for _, h in ipairs(type(data) == 'table' and type(data.hashes) == 'table' and data.hashes or {}) do
        if type(h) == 'string' and h:match('^%x+$') and #hashes < 24 then hashes[#hashes + 1] = h end
    end
    if #hashes == 0 or not Ink.blobClient then return cb({}) end
    local map = Ink.blobClient(RESOURCE .. ':ink').await(hashes, 15000) or {}
    local out = {}
    for h, b64 in pairs(map) do
        if type(b64) == 'string' and MIME[b64:sub(1, 4)] then out[h] = ('data:image/%s;base64,%s'):format(MIME[b64:sub(1, 4)], b64) end
    end
    cb(out)
end)

DL.fw.onUnloaded(function() editor.close('unloaded') end)

AddEventHandler('onResourceStop', function(resource)
    if resource == RESOURCE and DL.focus.owner() == RESOURCE then SetNuiFocus(false, false) end
end)
