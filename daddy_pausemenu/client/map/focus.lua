-- Focus: GTA's map under the map screen pans onto the place picked in the list, as its own legend does. GTA moves its
-- map only for a legend row (PauseMenuMapItem.stepVal -> SET_MAP_LOCATION(6, uid, value) to C++), so two helper blips
-- of ours (one legend row of two, hidden like the rest of GTA's legend) are moved onto the picked place and that row
-- steps with GTA's own row code (tier 'step': the reader shipped today finds the row). The waypoint is never touched.
-- Research: maplegend/focus.md, plan.md section 3.
PM.Map = PM.Map or {}
local D = PMDrv
local Cfg = (Config.Map or {}).Focus or {}
local ON = Cfg.Enabled ~= false
local SPRITE = PMMap.count(Cfg.Sprite, 162, 0, 1023) -- radar_poi: one icon (no height arrows), rare on RP servers
local ALPHA = PMMap.count(Cfg.Alpha, 1, 1, 255) -- GTA leaves an alpha 0 blip out of its legend (T6, in game); 255 shows the place
local VIEW = 'currentPage.column1.model.viewList.0' -- GTA's legend list, relative to TIMELINE
local DPAD_RIGHT = 11 -- GamePadConstants.DPADRIGHT: the column steps its highlighted row
local READY_MS, GAP_MS = 4000, 90
-- BATCH: names.lua holds up to 8 of GTA's 20 return-value slots. ROWS_MAX: GTA's legend has a row per sprite and name;
-- numbered places (F3 "Garaj #1" ... "#67", every station, market and shop) make well over 160, and with the helpers'
-- row past the scan the map never panned to a picked place. The row is cached once found, so a long scan is rare.
local BATCH, ROWS_MAX = 8, 1000
local LABEL = 'Selected place'

local anchors, isAnchor = {}, {}
local label = LABEL -- the helpers' name, so their legend row's label (FocusPrepare localises it)
-- mode: 'step' | false (none this visit) | nil (not known yet). retried: a timed out start was tried again.
local mode, row, token, timedOut, retried = nil, nil, 0, false, false
local want, worker = nil, nil -- the newest place asked for; the token of the running worker

-- PM.Debug, and the temporary diagnostics' listener when one is set (client/map/diag.lua).
local function log(fmt, ...)
    PM.Debug(fmt, ...)
    if PM.Map.Trace then PM.Map.Trace(fmt, ...) end
end

local function anchor(x, y)
    local blip = AddBlipForCoord(x, y, 0.0)
    SetBlipSprite(blip, SPRITE)
    SetBlipDisplay(blip, 4) -- main map only, selectable: listed in the legend
    SetBlipAlpha(blip, ALPHA)
    SetBlipHiddenOnLegend(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(label)
    EndTextCommandSetBlipName(blip)
    return blip
end

function PM.Map.IsFocusAnchor(blip) return isAnchor[blip] == true end

local function state(m) PM.Send('pm:map:focusState', { mode = m or false }) end

function PM.Map.FocusDrop()
    token = token + 1
    for _, blip in ipairs(anchors) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
    end
    anchors, isAnchor, mode, row, want, timedOut, retried = {}, {}, nil, nil, nil, false, false
end

-- Before GTA's map opens, so its first legend build lists the helpers (a later one needs a rebuild).
function PM.Map.FocusPrepare()
    PM.Map.FocusDrop()
    state(false) -- no pan until FocusReady found the row
    if not ON then return end
    local text = DL.locale.t('map.focus_anchor')
    label = text ~= 'map.focus_anchor' and PMMap.label(text) or LABEL
    -- The row is found by this text read back from GTA's legend: a letter outside ASCII ('Seçilen yer') may come back
    -- otherwise encoded and the row is never found (F8: map focus: false, row nil). Accents are dropped.
    for from, to in pairs({ ['ç'] = 'c', ['Ç'] = 'C', ['ğ'] = 'g', ['Ğ'] = 'G', ['ı'] = 'i', ['İ'] = 'I', ['ö'] = 'o', ['Ö'] = 'O',
        ['ş'] = 's', ['Ş'] = 'S', ['ü'] = 'u', ['Ü'] = 'U' }) do label = label:gsub(from, to) end
    label = label:gsub('[\128-\255]', '')
    if label == '' then label = LABEL end
    local c = GetEntityCoords(PlayerPedId())
    for i = 1, 2 do
        anchors[i] = anchor(c.x, c.y)
        isAnchor[anchors[i]] = true
    end
end

-- One legend field as a string, through the shipped reader's DXR_E (GTA keeps 63 bytes).
local function field(i, k)
    local c = D.feQueue('DXR_E', { ('%s.dataList.%d.%d'):format(VIEW, i, k), 'toString', 10 }, 'str')
    c.i = i
    return c
end

local function ours(text) return type(text) == 'string' and text:find(label, 1, true) ~= nil end

-- The helpers' row (their label, two values): the cached one while it still holds, else a scan, BATCH rows a frame.
local function findRow()
    if row then
        local c = D.feAwait({ field(row, 6), field(row, 11) }, 300)
        if ours(c[1].str) and c[2].str == '2' then return row end
        row = nil
    end
    local n = math.tointeger(tonumber(D.feCall('DXR_E', { VIEW .. '.dataList.length', 'toString', 10 }, 300, 'str').str or ''))
    if not n then return nil end
    for first = 0, math.min(n, ROWS_MAX) - 1, BATCH do
        local batch = {}
        for i = first, math.min(first + BATCH - 1, n - 1) do batch[#batch + 1] = field(i, 6) end
        D.feAwait(batch, 700)
        for _, c in ipairs(batch) do
            if ours(c.str) and D.feCall('DXR_E', { ('%s.dataList.%d.11'):format(VIEW, c.i), 'toString', 10 }, 300, 'str').str == '2' then
                row = c.i
                return row
            end
        end
    end
end

-- GTA's own row code: highlight the helpers' row, then one D-pad right (stepVal(1) sends SET_MAP_LOCATION with the
-- next value; with two values GTA never gets the same call twice).
local function step()
    local i = findRow()
    if not i then return false end
    D.fe('SET_COLUMN_HIGHLIGHT', 0, i, false, false, false)
    return D.fe('SET_COLUMN_INPUT_EVENT', 0, DPAD_RIGHT)
end

local function pan(x, y, my)
    local z = GetHeightmapBottomZForPosition(x, y)
    for _, blip in ipairs(anchors) do SetBlipCoords(blip, x, y, z) end
    Wait(0) -- the helpers stand there before GTA looks them up
    for _ = 1, 3 do -- a legend rebuild (a blip came or went, a new waypoint) hides the row for a few frames
        if token ~= my then return false end
        if step() then return true end
        row = nil
        Wait(50)
    end
    return false
end

-- One worker per map visit; only the newest place is panned to. A worker of an older visit never blocks a new one.
local function work()
    if worker == token or not mode or not want then return end
    local my = token
    worker = my
    CreateThread(function()
        while want and token == my do
            local w = want
            want = nil
            if not pan(w.x, w.y, my) then
                log('map focus: pan to %.0f, %.0f failed (row %s)', w.x, w.y, tostring(row))
            end
            Wait(GAP_MS)
        end
        if worker == my then worker = nil end
    end)
end

-- After PauseMenuceptionGoDeeper(0) (fullmap.lua): GTA's menu takes input, the reader is in its movie and the legend
-- lists the helpers. alive(): the full map is still the one this ran for.
function PM.Map.FocusReady(alive)
    local my = token
    if not ON or #anchors == 0 then
        mode = false
        return state(false)
    end
    local stop = GetGameTimer() + READY_MS
    local function live() return token == my and alive() end
    while live() and not (GetPauseMenuState() == 15 and IsFrontendReadyForControl()) and GetGameTimer() < stop do Wait(0) end
    local ok = live() and D.inject()
    while ok and live() and mode == nil and GetGameTimer() < stop do
        if findRow() then mode = 'step' else Wait(150) end
    end
    if token ~= my then return end
    if mode == nil then
        -- Out of time with a reader that may still come: the first pick tries once more.
        timedOut = live() and not retried and D.readerState() ~= 'broken'
        mode = false
    end
    log('map focus: %s (reader %s, row %s, anchors %d)', tostring(mode), tostring((D.readerState())), tostring(row), #anchors)
    state(mode)
    work()
end

-- A pan to a world point: { ok = true } once it is queued, or { ok = false, error = 'validation' | 'unavailable' }.
function PM.Map.Focus(x, y)
    x, y = PMMap.point(x, y)
    if not x then return { ok = false, error = 'validation' } end
    if not ON or not PM.Map.FullOn() or #anchors == 0 then return { ok = false, error = 'unavailable' } end
    if mode == false then
        if not timedOut then return { ok = false, error = 'unavailable' } end
        timedOut, retried, mode = false, true, nil
        local my = token
        CreateThread(function() PM.Map.FocusReady(function() return token == my and PM.Map.FullOn() end) end)
    end
    want = { x = x, y = y }
    work() -- waits for FocusReady while it is still running
    return { ok = true }
end

-- What the pans stand on (diagnostics).
function PM.Map.FocusInfo()
    return { on = ON, mode = mode, row = row, anchors = #anchors, label = label, sprite = SPRITE, alpha = ALPHA,
        timedOut = timedOut, retried = retried, working = worker ~= nil }
end

function PM.Map.FocusBusy()
    return worker ~= nil or want ~= nil
end

PM.Callback('pm:map:focus', function(data) return PM.Map.Focus(data.x, data.y) end)

-- The reader is requested before the first pick needs it (it costs one of the 16 reader names per resource start).
PM.RegisterScreen('map', {
    enter = function()
        if ON and D.readerState() == 'unknown' then D.prewarm() end
    end,
})

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then PM.Map.FocusDrop() end
end)
