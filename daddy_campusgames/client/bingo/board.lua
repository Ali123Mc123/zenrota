-- The stage screen of a hall night (bingo_board spots): one web page (web/dist/bingo.html) drawn on a flat quad at the
-- spot, facing the spot's heading. Only the nearest board of the hall the player stands in runs, only while a night is
-- on there, and it holds a slot of the shared DUI budget only then. The page asks for its data once it listens.
local cfg = Config.Bingo
local t = DL.locale.t
BingoBoard = {}

local LEASE, TEX = 'bingo-board', 'tex'
local LIFT = 0.03 -- the quad stands this far in front of the spot, off the wall it was placed on (m)
local PAGE = ('https://cfx-nui-%s/web/dist/bingo.html'):format(cache.resource) -- nui:// pages cannot call back

local active        -- the board shown: { uid, key, hall, tl, tr, bl, br, centre, radius }
local dui, txd, held = nil, nil, false
local nonce, ready, told = 0, false, false -- the page's number; it listens; it has the texts
local drawing = 0   -- the draw thread's generation (a new one ends the old)

local function sizeOf(record)
    local s = record.settings or {}
    return tonumber(s.screenWidth) or 4.0, tonumber(s.screenHeight) or 2.25
end

-- The quad's corners: centred on the spot, the page's left on the left of those it faces (forward = the heading).
local function quad(record)
    local c = record.coords
    local width, height = sizeOf(record)
    local h = math.rad(c.w or 0.0)
    local rx, ry = math.cos(h), math.sin(h)
    local x, y, hw, hh = c.x - math.sin(h) * LIFT, c.y + math.cos(h) * LIFT, width * 0.5, height * 0.5
    return {
        tl = vector3(x + rx * hw, y + ry * hw, c.z + hh), tr = vector3(x - rx * hw, y - ry * hw, c.z + hh),
        bl = vector3(x + rx * hw, y + ry * hw, c.z - hh), br = vector3(x - rx * hw, y - ry * hw, c.z - hh),
        centre = vector3(x, y, c.z), radius = math.sqrt(hw * hw + hh * hh),
    }
end

-- The page out and the lease back (also when another surface took the slot).
local function stop()
    drawing = drawing + 1
    if dui then DL.dui.retire(dui) end
    if held then DL.dui.release(LEASE) end
    dui, txd, active, held, ready, told = nil, nil, nil, false, false, false
end

-- What the page shows; the texts go with the first message the page gets.
local function send()
    if not dui or not ready or not active then return end
    local message = { action = 'bingoBoard', data = BingoHall.board(active.hall) }
    if not told then message.locale, told = DL.locale.table(), true end
    SendDuiMessage(dui, json.encode(message))
end

-- Both windings, so the screen shows from behind too; nothing while it is out of view.
local function draw()
    drawing = drawing + 1
    local me = drawing
    CreateThread(function()
        while drawing == me do
            local q = active
            if q and ready and IsSphereVisible(q.centre.x, q.centre.y, q.centre.z, q.radius) then
                local tl, tr, bl, br = q.tl, q.tr, q.bl, q.br
                for _ = 1, 2 do
                    DrawSpritePoly(tl.x, tl.y, tl.z, bl.x, bl.y, bl.z, br.x, br.y, br.z, 255, 255, 255, 255, txd, TEX, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0)
                    DrawSpritePoly(tl.x, tl.y, tl.z, br.x, br.y, br.z, tr.x, tr.y, tr.z, 255, 255, 255, 255, txd, TEX, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0)
                    tl, tr, bl, br = tr, tl, br, bl
                end
            end
            Wait(0)
        end
    end)
end

-- The lease first (renewed with the distance every pass), then the page and its texture.
local function start(record, hall, distance)
    if active and active.uid ~= record.uid then stop() end
    local width, height = cfg.Board.Width, cfg.Board.Height
    if not DL.dui.acquire(LEASE, distance, stop, { width = width, height = height, priority = 1 }) then return stop() end
    held = true
    local key = ('%s:%s'):format(record.uid, record.revision or 0)
    if not active or active.key ~= key then
        active = quad(record)
        active.uid, active.key = record.uid, key
    end
    active.hall = hall
    if dui then return end
    nonce, ready, told = nonce + 1, false, false
    dui = CreateDui(('%s#%d'):format(PAGE, nonce), width, height)
    txd = DL.dui.name('bingoboard')
    CreateRuntimeTextureFromDuiHandle(CreateRuntimeTxd(txd), TEX, GetDuiHandle(dui))
    draw()
end

-- The nearest board within range that belongs to the hall I am in with a night on.
CreateThread(function()
    while true do
        local hall = BingoHall and BingoHall.inside()
        local best, near
        if hall then
            local me = GetEntityCoords(cache.ped)
            for _, record in ipairs(Games.places('bingo_board')) do
                local c = record.coords
                local d = #(me - vector3(c.x, c.y, c.z))
                if record.active ~= false and d <= cfg.Board.Range and (not near or d < near) and BingoHall.hallAt(c.x, c.y, c.z) == hall then
                    best, near = record, d
                end
            end
        end
        if best then start(best, hall, near) elseif active or dui or held then stop() end
        Wait(500)
    end
end)

-- The hall's night changed: the page gets it while it shows that hall.
function BingoBoard.push(hall)
    if active and active.hall == hall then send() end
end

-- The page listens (it asks every second until it hears); an older page (another number) is ignored.
RegisterNUICallback('bingo:boardReady', function(data, cb)
    cb({ ok = true })
    if not dui or tostring(type(data) == 'table' and data.nonce or '') ~= tostring(nonce) then return end
    ready, told = true, false
    send()
end)

-- Anyone may ask for the host panel here; the server decides what it shows.
Games.kind('bingo_board', function(record)
    local model = (record.model or '') ~= '' and record.model or nil
    local c = record.coords
    local width, height = sizeOf(record)
    return {
        presentation = model and 'prop' or 'point', model = model, exact = true, distance = 6.0,
        targetSphere = { radius = math.max(0.5, math.min(width, height) * 0.5), height = 0.0 },
        options = { {
            name = 'bingo_panel', label = t('bingo.panel_open'), icon = 'fa-solid fa-sliders', distance = 6.0,
            canInteract = function() return Games.free() end,
            onSelect = function() CreateThread(function() BingoHost.open(BingoHall.hallAt(c.x, c.y, c.z)) end) end,
        } },
    }
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    drawing = drawing + 1
    if dui then DL.dui.retire(dui, true) end
    dui = nil
end)
