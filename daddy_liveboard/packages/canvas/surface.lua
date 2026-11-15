-- World surfaces drawn from DUI pages. The nearest mounted surfaces get a page, within the shared budget. A surface may
-- also draw an underlay texture (LiveBoard's media page) 3 mm behind its own page.
--   Surface.setup({ page = 'packages/canvas/dui/canvas.html', files = { ...page files }, maxLive = 6 })
Surface = {}

local RESOURCE = GetCurrentResourceName()
local cfg = { maxLive = 6, faceOffset = 0.005, underlayGap = 0.003, streamDistance = 20.0, files = {} }
local surfaces, slots, retiring = {}, {}, {}
local drawing, scanning, dirty, underlays = false, false, true, 0
local lastScan, stamp

-- A dictionary binds only to the first DUI made under its name: every DUI gets a new one (the start time covers restarts).
local START, made = ('%x'):format(GetGameTimer()), 0
local function newTxd(index)
    made = made + 1
    return ('%s_s%d_%s_%d'):format(RESOURCE, index, START, made)
end

-- The page is emptied first and destroyed a frame later, so CEF lets go of it cleanly; now = both at once.
local function retire(dui, now)
    SetDuiUrl(dui, 'about:blank')
    if now then return DestroyDui(dui) end
    retiring[dui] = true
    CreateThread(function()
        Wait(0)
        if not retiring[dui] then return end
        retiring[dui] = nil
        DestroyDui(dui)
    end)
end

-- Strokes are copied in, so the caller's list and the page's list never grow twice from one append.
local function copy(list) return table.move(list, 1, #list, 1, {}) end

function Surface.setup(options)
    for key, value in pairs(options) do cfg[key] = value end
    stamp = nil
end

-- Version + content hash of the page files: a changed file gets a new URL, so CEF never runs an old copy.
local function pageStamp()
    if stamp then return stamp end
    local parts = { cfg.page }
    for _, path in ipairs(cfg.files) do parts[#parts + 1] = LoadResourceFile(RESOURCE, path) or path end
    stamp = ('%s.%08x'):format(GetResourceMetadata(RESOURCE, 'version', 0) or '0', GetHashKey(table.concat(parts, '\n')) & 0xffffffff)
    return stamp
end

-- Texture size: the long edge is the resolution, the short edge follows the surface ratio.
local function textureSize(data)
    local base = math.floor(math.max(256, math.min(2048, data.resolution or 1024)))
    local aspect = data.width / data.height
    local function snap(value) return math.max(128, math.floor(value / 4 + 0.5) * 4) end
    if aspect >= 1.0 then return base, snap(base / aspect) end
    return snap(base * aspect), base
end

-- Messages carry the slot nonce; embedded media frames cannot read it, so they cannot fake one.
local function send(slot, message)
    message.nonce = slot.nonce
    local encoded = json.encode(message)
    if slot.ready then return SendDuiMessage(slot.dui, encoded) end
    slot.queue[#slot.queue + 1] = encoded
end

local function waitReady(slot)
    CreateThread(function()
        for _ = 1, 200 do
            if slot.destroyed then return end
            if IsDuiAvailable(slot.dui) then break end
            Wait(50)
        end
        Wait(150)
        if slot.destroyed then return end
        slot.ready = true
        for _, encoded in ipairs(slot.queue) do SendDuiMessage(slot.dui, encoded) end
        slot.queue = {}
    end)
end

local function initMessage(data, slot)
    return {
        type = 'init', width = slot.width, height = slot.height, background = data.background,
        strokes = data.strokes, text = data.text, layer = data.layer, debug = data.debug,
    }
end

local function destroy(index, now)
    local slot = slots[index]
    if not slot then return end
    slot.destroyed = true
    retire(slot.dui, now)
    local data = surfaces[slot.uid]
    if data then data.slot = nil end
    slots[index] = nil
    DL.dui.release(slot.uid)
end

local function create(index, uid, distance)
    local data = surfaces[uid]
    local granted = DL.dui.acquire(uid, distance, function()
        local current = surfaces[uid]
        if current and current.slot then destroy(current.slot) end
        dirty = true
    end)
    if not granted then
        dirty = true
        return false
    end

    local width, height = textureSize(data)
    local nonce = lib.string.random('aaaaaaaa1111')
    local url = ('https://cfx-nui-%s/%s?v=%s#%s'):format(RESOURCE, cfg.page, pageStamp(), nonce)
    local slot = { uid = uid, width = width, height = height, nonce = nonce, queue = {}, txd = newTxd(index) }
    slot.dui = CreateDui(url, width, height)
    CreateRuntimeTextureFromDuiHandle(CreateRuntimeTxd(slot.txd), 'tex', GetDuiHandle(slot.dui))
    slots[index] = slot
    data.slot = index
    waitReady(slot)
    send(slot, initMessage(data, slot))
    return true
end

local function slotOf(uid)
    local data = surfaces[uid]
    return data and data.slot and slots[data.slot]
end

-- Two triangles per side; the back side reverses the corners so it reads unmirrored from behind.
local function drawQuad(data, viewer, txd, offset)
    local rad = math.rad(data.heading)
    local nx, ny = math.cos(rad), math.sin(rad)
    local rx, ry = math.cos(rad + math.pi / 2), math.sin(rad + math.pi / 2)
    if nx * (viewer.x - data.coords.x) + ny * (viewer.y - data.coords.y) < 0 then nx, ny = -nx, -ny end
    local cx, cy, cz = data.coords.x + nx * offset, data.coords.y + ny * offset, data.coords.z
    local hw, hh = data.width * 0.5, data.height * 0.5
    local lx, ly, rgx, rgy = cx - rx * hw, cy - ry * hw, cx + rx * hw, cy + ry * hw
    DrawSpritePoly(lx, ly, cz + hh, lx, ly, cz - hh, rgx, rgy, cz - hh, 255, 255, 255, 255, txd, 'tex', 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0)
    DrawSpritePoly(lx, ly, cz + hh, rgx, rgy, cz - hh, rgx, rgy, cz + hh, 255, 255, 255, 255, txd, 'tex', 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0)
    DrawSpritePoly(rgx, rgy, cz + hh, rgx, rgy, cz - hh, lx, ly, cz - hh, 255, 255, 255, 255, txd, 'tex', 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0)
    DrawSpritePoly(rgx, rgy, cz + hh, lx, ly, cz - hh, lx, ly, cz + hh, 255, 255, 255, 255, txd, 'tex', 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0)
end

-- The underlay goes first, 3 mm behind: the page in front is transparent where it has nothing to show.
local function startDraw()
    if drawing then return end
    drawing = true
    CreateThread(function()
        while next(slots) or underlays > 0 do
            local viewer = GetFinalRenderedCamCoord()
            for _, data in pairs(surfaces) do
                if data.underlay and not data.hidden then drawQuad(data, viewer, data.underlay, cfg.faceOffset - cfg.underlayGap) end
                local slot = data.slot and slots[data.slot]
                if slot and slot.ready and not data.hidden and not data.inkHidden then drawQuad(data, viewer, slot.txd, cfg.faceOffset) end
            end
            Wait(0)
        end
        drawing = false
    end)
end

-- Nearest surfaces get pages.
local function scan()
    local pcoords = GetEntityCoords(PlayerPedId())
    if not dirty and lastScan and #(pcoords - lastScan) < 1.5 then return end
    dirty, lastScan = false, pcoords

    local list = {}
    for uid, data in pairs(surfaces) do
        local distance = #(pcoords - data.coords)
        if distance <= (data.streamDistance or cfg.streamDistance) then list[#list + 1] = { uid = uid, data = data, distance = distance } end
    end
    table.sort(list, function(a, b) return a.distance < b.distance end)

    local keep = {}
    for i = 1, math.min(#list, cfg.maxLive) do keep[list[i].uid] = list[i] end
    for index, slot in pairs(slots) do
        if not keep[slot.uid] then destroy(index) end
    end
    for uid, entry in pairs(keep) do
        if entry.data.slot then
            DL.dui.acquire(uid, entry.distance)
        else
            for index = 1, cfg.maxLive do
                if not slots[index] then
                    create(index, uid, entry.distance)
                    break
                end
            end
        end
    end
    if next(slots) then startDraw() end
end

local function startScan()
    if scanning then return end
    scanning = true
    CreateThread(function()
        while next(surfaces) do
            scan()
            Wait(next(slots) and 500 or 1000)
        end
        for index in pairs(slots) do destroy(index) end
        scanning, lastScan = false, nil
    end)
end

-- API ----------------------------------------------------------------------

-- data: coords, heading, width, height, background, strokes, resolution, streamDistance, text.
function Surface.set(uid, data)
    local existing = surfaces[uid]
    data.strokes = data.strokes and copy(data.strokes) or (existing and existing.strokes) or {}
    if existing then
        data.slot, data.hidden = existing.slot, existing.hidden
        data.layer, data.underlay, data.inkHidden = existing.layer, existing.underlay, existing.inkHidden
    end
    surfaces[uid] = data
    local slot = slotOf(uid)
    if slot then send(slot, initMessage(data, slot)) end
    dirty = true
    startScan()
end

function Surface.remove(uid)
    local data = surfaces[uid]
    if data and data.slot then destroy(data.slot) end
    if data and data.underlay then underlays = underlays - 1 end
    surfaces[uid] = nil
    dirty = true
end

function Surface.has(uid)
    return surfaces[uid] ~= nil
end

local function post(uid, message)
    local slot = slotOf(uid)
    if slot then send(slot, message) end
end
Surface.post = post

function Surface.append(uid, stroke)
    local data = surfaces[uid]
    if not data then return end
    data.strokes[#data.strokes + 1] = stroke
    post(uid, { type = 'append', stroke = stroke })
end

-- The painter's own stroke: same as append, and clears the live preview.
function Surface.commit(uid, stroke)
    local data = surfaces[uid]
    if not data then return end
    if data.strokes[#data.strokes] ~= stroke then data.strokes[#data.strokes + 1] = stroke end
    post(uid, { type = 'commit', stroke = stroke })
end

function Surface.replace(uid, strokes)
    local data = surfaces[uid]
    if not data then return end
    data.strokes = copy(strokes)
    post(uid, { type = 'replace', strokes = data.strokes })
end

function Surface.clear(uid)
    Surface.replace(uid, {})
end

-- Live preview while dragging: kind is start, append, set or clear.
function Surface.preview(uid, kind, stroke)
    post(uid, { type = 'preview', kind = kind, stroke = stroke })
end

function Surface.setVisible(uid, visible)
    local data = surfaces[uid]
    if data then data.hidden = not visible end
end

-- Media (LiveBoard) ---------------------------------------------------------

-- What the page shows under its drawing: { mode = 'none'|'image'|'clear', url, fit, opacity, card }; kept for a new page.
function Surface.setLayer(uid, layer)
    local data = surfaces[uid]
    if not data then return end
    data.layer = layer
    post(uid, { type = 'media:layer', layer = layer })
end

-- A texture drawn 3 mm behind the page (txd with a 'tex' texture), or nil.
function Surface.setUnderlay(uid, txd)
    local data = surfaces[uid]
    if not data or data.underlay == txd then return end
    underlays = underlays + (txd and 1 or 0) - (data.underlay and 1 or 0)
    data.underlay = txd
    if txd then startDraw() end
end

-- The page itself is left out (YouTube forbids layers over its player); its underlay still draws.
function Surface.setInkHidden(uid, hidden)
    local data = surfaces[uid]
    if data then data.inkHidden = hidden == true end
end

function Surface.stats()
    local live, total = 0, 0
    for _ in pairs(slots) do live = live + 1 end
    for _ in pairs(surfaces) do total = total + 1 end
    return live, total
end

-- No frame comes after a stop: pages still waiting for theirs go now too.
AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE then return end
    for index in pairs(slots) do destroy(index, true) end
    for dui in pairs(retiring) do
        retiring[dui] = nil
        DestroyDui(dui)
    end
end)
