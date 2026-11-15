-- Name plates on rented lockers, fixed to the locker door (they do not turn to the camera).
-- One page (web/dist/nameplate.html) draws up to ROWS plates as rows of a texture; each plate is a quad that
-- samples its row. The page holds a slot of the shared DUI budget only while plates are near.
local cfg = Config.Nameplate
if not cfg.Enabled then return end

local t = DL.locale.t
local ROW_W, ROW_H, ROWS = 512, 128, 16
local TEX, LEASE = 'plates', 'nameplates'
local PAGE = ('nui://%s/web/dist/nameplate.html'):format(GetCurrentResourceName())
-- A dictionary binds only to the first DUI made under its name: every DUI gets a new one (the start time covers restarts).
local TXD_PREFIX = ('%s_plates_%x_'):format(GetCurrentResourceName(), GetGameTimer())

local LEASE_SIZE = { width = ROW_W, height = ROW_H * ROWS, priority = cfg.DuiPriority or 1 }

local dui, txd
local made = 0
local ready = false  -- the page said it listens (it asks for the rows itself; a message sent before that is lost)
local retiring = {}  -- pages waiting for their frame before they are destroyed
local rows = {}      -- slot -> { key, code, owner, title, theme, notes, state }
local slotOf = {}    -- plate key -> slot
local shown = {}     -- the plates being drawn: { key, slot, coords, heading, alpha, target }
local drawing = false

-- The page is emptied first and destroyed a frame later, so CEF lets go of it cleanly; a stop has no next frame.
local function release(stopping)
    if dui then
        local old = dui
        SetDuiUrl(old, 'about:blank')
        retiring[old] = true
        SetTimeout(0, function()
            if not retiring[old] then return end
            retiring[old] = nil
            DestroyDui(old)
        end)
        dui = nil
    end
    if stopping then
        for old in pairs(retiring) do
            retiring[old] = nil
            DestroyDui(old)
        end
    end
    rows, slotOf, shown, ready = {}, {}, {}, false
    DL.dui.release(LEASE)
end

-- The lease is renewed with the nearest plate's distance and the page's real size, so a farther page gives way first.
local function ensure(distance)
    if not DL.dui.acquire(LEASE, distance, release, LEASE_SIZE) then return false end
    if dui then return true end
    made = made + 1
    dui = CreateDui(('%s#%d'):format(PAGE, made), ROW_W, ROW_H * ROWS)
    txd = TXD_PREFIX .. made
    CreateRuntimeTextureFromDuiHandle(CreateRuntimeTxd(txd), TEX, GetDuiHandle(dui))
    return true
end

-- The page gets every row at once, after it has loaded (and again when it says it is ready).
local function push()
    local payload = {}
    for slot = 1, ROWS do payload[slot] = rows[slot] or false end
    local message = json.encode({ rows = payload })
    if ready then return SendDuiMessage(dui, message) end
    CreateThread(function()
        local tries = 0
        while dui and not IsDuiAvailable(dui) and tries < 200 do
            tries = tries + 1
            Wait(50)
        end
        if dui then SendDuiMessage(dui, message) end
    end)
end

-- One row per locker and look: a plate that changes gets a new row and the old one fades out.
local function plateKey(p) return table.concat({ p.uid, p.code, p.owner or '', p.theme, p.title or '', p.notes and '1' or '0', p.state or '' }, '::') end

local function freeSlot(slot)
    local row = rows[slot]
    if row then slotOf[row.key] = nil end
    rows[slot] = nil
end

local function takeSlot(plate)
    local key = plateKey(plate)
    if slotOf[key] then return slotOf[key] end
    for slot = 1, ROWS do
        if not rows[slot] then
            rows[slot] = { key = key, code = plate.code, owner = plate.owner, title = plate.title, theme = plate.theme, notes = plate.notes, state = plate.state }
            slotOf[key] = slot
            return slot
        end
    end
end

-- Drawing ------------------------------------------------------------------------------------------------

local function quad(p)
    local rad = math.rad(p.heading + 90.0)
    local rx, ry = math.cos(rad), math.sin(rad)
    local hw, hh = cfg.Width * 0.5, cfg.Height * 0.5
    local c = p.coords
    local tl = { c.x - rx * hw, c.y - ry * hw, c.z + hh }
    local tr = { c.x + rx * hw, c.y + ry * hw, c.z + hh }
    local bl = { c.x - rx * hw, c.y - ry * hw, c.z - hh }
    local br = { c.x + rx * hw, c.y + ry * hw, c.z - hh }
    local v0, v1 = (p.slot - 1) / ROWS, p.slot / ROWS
    local a = math.floor(p.alpha)
    if a <= 0 then return end
    -- Both windings, so the plate shows from behind too.
    for _ = 1, 2 do
        DrawSpritePoly(tl[1], tl[2], tl[3], bl[1], bl[2], bl[3], br[1], br[2], br[3], 255, 255, 255, a, txd, TEX, 0.0, v0, 1.0, 0.0, v1, 1.0, 1.0, v1, 1.0)
        DrawSpritePoly(tl[1], tl[2], tl[3], br[1], br[2], br[3], tr[1], tr[2], tr[3], 255, 255, 255, a, txd, TEX, 0.0, v0, 1.0, 1.0, v1, 1.0, 1.0, v0, 1.0)
        tl, tr, bl, br = tr, tl, br, bl
    end
end

local function draw()
    if drawing then return end
    drawing = true
    CreateThread(function()
        local last = GetGameTimer()
        while drawing do
            local now = GetGameTimer()
            local step = 255.0 * math.min(50, now - last) / math.max(1, cfg.FadeMs)
            last = now
            local kept, freed = {}, false
            for _, p in ipairs(shown) do
                p.alpha = p.alpha < p.target and math.min(p.target, p.alpha + step) or math.max(p.target, p.alpha - step)
                if p.target == 0 and p.alpha <= 0 then
                    freeSlot(p.slot)
                    freed = true
                else
                    kept[#kept + 1] = p
                    quad(p)
                end
            end
            shown = kept
            if freed then push() end
            if #shown == 0 then
                drawing = false
                release()
            end
            Wait(0)
        end
    end)
end

-- Which plates are near ------------------------------------------------------------------------------------

local function wanted()
    local here = GetEntityCoords(cache.ped)
    local out, nearest = {}, cfg.MaxDistance
    for uid, rental in pairs(Lockers.rentals) do
        local spot = Lockers.spots[uid]
        local distance = spot and #(here - vector3(spot.coords.x, spot.coords.y, spot.coords.z))
        if distance and distance <= cfg.MaxDistance then
            nearest = math.min(nearest, distance)
            local base = spot.coords.w or 0.0
            local rad = math.rad(base)
            out[#out + 1] = {
                uid = uid, code = spot.code, owner = rental.owner, title = rental.title, notes = (rental.unread or 0) > 0,
                theme = Config.Plates[rental.plate] and rental.plate or 'classic', state = rental.state == 'grace' and t('lockers.plate_grace') or nil,
                heading = base + cfg.HeadingOffset,
                coords = vector3(spot.coords.x - math.sin(rad) * cfg.FaceOffset, spot.coords.y + math.cos(rad) * cfg.FaceOffset, spot.coords.z + cfg.HeightOffset),
            }
        end
    end
    return out, nearest
end

-- New plates fade in, gone ones fade out; a row is reused only once its plate has faded.
local function refresh()
    local list, nearest = wanted()
    if #list > 0 and not ensure(nearest) then return end
    local byKey, changed = {}, false
    for _, p in ipairs(shown) do byKey[plateKey(p)] = p end
    local next = {}
    for _, plate in ipairs(list) do
        local id = plateKey(plate)
        local existing = byKey[id]
        if existing then
            existing.target, byKey[id] = 255, nil
            next[#next + 1] = existing
        else
            local before = slotOf[plateKey(plate)]
            local slot = takeSlot(plate)
            if slot then
                changed = changed or before == nil
                plate.slot, plate.alpha, plate.target = slot, 0, 255
                next[#next + 1] = plate
            end
        end
    end
    for _, gone in pairs(byKey) do
        gone.target = 0
        next[#next + 1] = gone
    end
    shown = next
    if changed then push() end
    if #shown > 0 then draw() end
end

CreateThread(function()
    while true do
        if next(Lockers.rentals) then refresh() end
        Wait(500)
    end
end)

AddEventHandler('daddy_lockers:changed', refresh)

-- The page asks for its rows once its listener is up; an older page (another number) is ignored.
RegisterNUICallback('nameplate:ready', function(data, cb)
    cb(1)
    if not dui or tonumber(type(data) == 'table' and data.page) ~= made then return end
    ready = true
    push()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then release(true) end
end)
