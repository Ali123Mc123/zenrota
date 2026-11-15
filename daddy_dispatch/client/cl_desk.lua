-- The desk: open calls, units, the staff list and the history on a full screen. Its map box shows GTA's own radar,
-- moved under the box and held on the chosen call (north up); units get small blips while it is open, the heat map
-- draws the last hours' calls as coloured circles on it.
Desk = { open = false }
local unitBlips = {}

-- The radar in the box ----------------------------------------------------------------------------------------------------
local Radar = { shown = false, box = nil, wasHidden = false }
do
    local R = Config.Desk.Radar
    local GFX = 'platform:/textures/graphics'

    -- Component positions only take effect after the radar is rebuilt: a bigmap toggle does that.
    local function rebuild()
        SetBigmapActive(true, false)
        Wait(0)
        SetBigmapActive(false, false)
    end

    -- The radar fills the box: visible map (minimap_mask) matches box, minimap and blur keep GTA Scaleform matrix.
    function Radar.place(r)
        local margin = (1.0 - GetSafeZoneSize()) * 0.5
        local x, y = r.x - margin, r.y - margin
        local sw, sh = r.w / 0.111, r.h / 0.159
        for _, t in ipairs(R.Restore.textures or {}) do RemoveReplaceTexture(GFX, t[1]) end
        SetMinimapClipType(0)
        SetMinimapComponentPosition('minimap', 'L', 'T', x - 0.0245 * sw, y - 0.010 * sh, 0.150 * sw, 0.188 * sh)
        SetMinimapComponentPosition('minimap_mask', 'L', 'T', x, y, r.w, r.h)
        SetMinimapComponentPosition('minimap_blur', 'L', 'T', x - 0.050 * sw, y - 0.050 * sh, 0.266 * sw, 0.237 * sh)
        SetRadarZoom(R.Zoom)
        LockMinimapAngle(0)
        Radar.box = r
        rebuild()
        SetRadarZoom(R.Zoom)
    end

    function Radar.show(r)
        if not R.Enabled then return end
        if not Radar.shown then
            Radar.wasHidden = IsRadarHidden()
            Radar.shown = true
            CreateThread(function()
                while Radar.shown do
                    DisplayRadar(true)
                    if Radar.box then
                        local b = Radar.box
                        SetScriptGfxDrawOrder(0)
                        DrawRect(b.x + b.w * 0.5, b.y + b.h * 0.5, b.w, b.h, 22, 26, 31, 255)
                        SetScriptGfxDrawOrder(4)
                    end
                    Wait(0)
                end
            end)
        end
        Radar.place(r)
    end

    function Radar.hide()
        if not Radar.shown then return end
        Radar.shown, Radar.box = false, nil
        CreateThread(function()
            local P = R.Restore
            for _, t in ipairs(P.textures or {}) do AddReplaceTexture(GFX, t[1], t[2], t[3]) end
            UnlockMinimapPosition()
            UnlockMinimapAngle()
            if P.clip then SetMinimapClipType(P.clip) end
            for name, key in pairs({ minimap = 'minimap', minimap_mask = 'mask', minimap_blur = 'blur' }) do
                local p = P[key]
                if type(p) == 'table' and #p == 6 then SetMinimapComponentPosition(name, p[1], p[2], p[3], p[4], p[5], p[6]) end
            end
            SetRadarZoom(P.zoom or 0)
            rebuild()
            DisplayRadar(not Radar.wasHidden)
        end)
    end

    -- Holds the radar on a point.
    function Radar.focus(x, y)
        if Radar.shown then LockMinimapPosition(x + 0.0, y + 0.0) end
    end

    function Radar.zoom(level)
        if Radar.shown then SetRadarZoom(level) end
    end
end

-- The heat map ----------------------------------------------------------------------------------------------------------
local heatBlips = {}

local function clearHeat()
    for _, b in ipairs(heatBlips) do
        if DoesBlipExist(b) then RemoveBlip(b) end
    end
    heatBlips = {}
end

-- Calls of the last hours counted in square cells; each cell a circle, from yellow to red as it fills. The page gets the
-- busiest areas.
local function drawHeat()
    clearHeat()
    local rows = lib.callback.await('daddy_dispatch:heat', false) or {}
    local size = Config.Heat.Cell
    local cells, top = {}, 0
    for _, r in ipairs(rows) do
        local key = math.floor(r[1] / size) .. ':' .. math.floor(r[2] / size)
        local c = cells[key] or { x = (math.floor(r[1] / size) + 0.5) * size, y = (math.floor(r[2] / size) + 0.5) * size, n = 0 }
        c.n = c.n + 1
        cells[key] = c
        top = math.max(top, c.n)
    end
    local areas, byName = {}, {}
    for _, c in pairs(cells) do
        local share = c.n / math.max(1, top)
        local b = AddBlipForRadius(c.x, c.y, 0.0, size * 0.62)
        SetBlipColour(b, share > 0.66 and 1 or share > 0.33 and 47 or 5)
        SetBlipAlpha(b, math.floor(70 + share * 110))
        heatBlips[#heatBlips + 1] = b
        local zone = GetLabelText(GetNameOfZone(c.x, c.y, 30.0))
        local name = zone ~= 'NULL' and zone or '?'
        local a = byName[name]
        if not a then
            a = { area = name, n = 0, x = c.x, y = c.y, best = 0 }
            byName[name] = a
            areas[#areas + 1] = a
        end
        a.n = a.n + c.n
        if c.n > a.best then a.best, a.x, a.y = c.n, c.x, c.y end
    end
    table.sort(areas, function(a, b) return a.n > b.n end)
    Radar.zoom(Config.Heat.Zoom)
    if areas[1] then Radar.focus(areas[1].x, areas[1].y) end
    local out = {}
    for i = 1, math.min(6, #areas) do out[i] = { area = areas[i].area, n = areas[i].n, x = areas[i].x, y = areas[i].y } end
    return { ok = true, total = #rows, areas = out }
end

Page.on('desk:heat', function(data)
    if data.on == true then return drawHeat() end
    clearHeat()
    Radar.zoom(Config.Desk.Radar.Zoom)
end)

-- Unit blips --------------------------------------------------------------------------------------------------------------
local STATUS_COLOURS = { available = 2, busy = 1, enroute = 3, onscene = 38, ['break'] = 4 }

local function clearUnitBlips()
    for _, b in pairs(unitBlips) do
        if DoesBlipExist(b.blip) then RemoveBlip(b.blip) end
    end
    unitBlips = {}
end

local function dropUnit(id)
    local b = unitBlips[id]
    if b and DoesBlipExist(b.blip) then RemoveBlip(b.blip) end
    unitBlips[id] = nil
end

-- A unit's blip: made once, then only what changed (place, sprite, colour, name; a new sprite takes colour and name again).
local function drawUnit(u)
    if u.gone or not u.x then return dropUnit(u.id) end
    if u.id == cache.serverId then return end
    local b = unitBlips[u.id]
    if not b or not DoesBlipExist(b.blip) then
        b = { blip = AddBlipForCoord(u.x + 0.0, u.y + 0.0, 0.0) }
        SetBlipAsShortRange(b.blip, false)
        unitBlips[u.id] = b
    elseif b.x ~= u.x or b.y ~= u.y then
        SetBlipCoords(b.blip, u.x + 0.0, u.y + 0.0, 0.0)
    end
    b.x, b.y = u.x, u.y
    if b.kind ~= u.kind or not b.drawn then
        b.kind, b.status, b.cs, b.drawn = u.kind, nil, nil, true
        SetBlipSprite(b.blip, u.kind == 'air' and 43 or u.kind == 'sea' and 427 or 1)
        SetBlipScale(b.blip, 0.7)
    end
    if b.status ~= u.status then
        b.status = u.status
        SetBlipColour(b.blip, STATUS_COLOURS[u.status] or 0)
    end
    if b.cs ~= u.cs then
        b.cs = u.cs
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(u.cs or '')
        EndTextCommandSetBlipName(b.blip)
    end
end

-- The whole list (the desk opened): every unit drawn, the others gone.
local function drawUnits(list)
    local seen = {}
    for _, u in ipairs(list) do
        seen[u.id] = true
        drawUnit(u)
    end
    for id in pairs(unitBlips) do
        if not seen[id] then dropUnit(id) end
    end
end

-- Opening and closing -------------------------------------------------------------------------------------------------------
-- Single dispatch command: /dp alone opens the desk; /dp <word> runs the actions.
local function ask(_, args)
    local sub = type(args) == 'table' and args[1] and tostring(args[1]):lower() or nil

    if not sub or sub == 'masa' or sub == 'desk' then
        if not Me.unit then return end -- silent: players who are not dispatch units never get a message
        return TriggerServerEvent('daddy_dispatch:desk:open')
    end

    if sub == 'ayar' or sub == 'settings' or sub == 'ayarlar' then
        return Page.open('settings')
    end

    if sub == 'durum' or sub == 'status' then
        if not Me.unit then return end -- silent: players who are not dispatch units never get a message
        local val = args[2] and tostring(args[2]):lower()
        if val and Core.contains(Core.PICKABLE, val) then
            return TriggerServerEvent('daddy_dispatch:status', val)
        end
        if Config.StatusToggles ~= false and not val then
            return TriggerServerEvent('daddy_dispatch:status', Me.status == 'busy' and 'available' or 'busy')
        end
        return Status.pick()
    end

    if sub == '7' or sub == 'kod7' or sub == 'code7' or sub == 'mesgul' or sub == 'busy' then
        if not Me.unit then return end -- silent: players who are not dispatch units never get a message
        return TriggerServerEvent('daddy_dispatch:status', Me.status == 'busy' and 'available' or 'busy')
    end

    if sub == 'kod' or sub == 'code' then
        if not Me.unit then return end -- silent: players who are not dispatch units never get a message
        local code = args[2]
        if not code then
            local c = type(Config.CodeCommand) == 'string' and Config.CodeCommand ~= '' and Config.CodeCommand or 'dpkod'
            return Bridge.notify(('/%s <kod> (Örn: /%s 10-13)'):format(c, c), 'error')
        end
        -- /dp kod 99: through the server command, like /kod
        return ExecuteCommand(((Config.Command or 'dp') .. 'kod %s'):format(tostring(code)))
    end

    if sub == 'kapat' or sub == 'pause' or sub == 'sustur' then
        local mins = tonumber(args[2]) or Prefs.pause
        return Pause.set(mins)
    end

    if sub == 'ac' or sub == 'resume' then
        return Pause.set(nil)
    end

    if sub == 'op' or sub == 'operator' then
        return Operator.toggle()
    end

    if sub == 'r' or sub == 'cevap' or sub == 'reply' then
        local id = tonumber(args[2])
        if not id or #args < 3 then
            return Bridge.notify('Kullanım: /dpr <çağrı no> <cevap>', 'error')
        end
        return TriggerServerEvent('daddy_dispatch:reply', id, table.concat(args, ' ', 3))
    end

    Bridge.notify('Kullanım: /dpayar | /dpdurum | /dp7 | /dpkod <no> | /dpkapat | /dpac | /dpop | /dpr <no> <cevap>', 'info')
end

-- The radio code on its own short command (Config.CodeCommand, /kod 10-13): the same as /dpkod. Both are server
-- commands (server/sv_calls.lua); a client command of the same name would catch them first, so only the suggestion here.
local codeCmd = Config.CodeCommand
if type(codeCmd) == 'string' and codeCmd ~= '' then
    TriggerEvent('chat:addSuggestion', '/' .. codeCmd, 'Tüm birimlere telsiz kodu (99 panik, 0 acil destek)', { { name = 'kod', help = 'Örn: 10-13' } })
end

local cmd = Config.Command or 'dp'
if cmd ~= '' then
    Command(cmd, ask)
    TriggerEvent('chat:addSuggestion', '/' .. cmd, 'Dispatch masası')
    -- Every action is also its own command with no space: /dpkod 99, /dpdurum, /dpkapat 15 ...
    local SUBS = {
        { 'ayar', 'Dispatch ayarları' },
        { 'durum', 'Durum seç / meşgul-müsait', { { name = 'durum', help = 'isteğe bağlı' } } },
        { '7', 'Meşgul / müsait' },
        { 'kod', 'Tüm birimlere kod', { { name = 'kod', help = 'Örn: 99' } } },
        { 'kapat', 'Bildirimleri duraklat', { { name = 'dk', help = 'isteğe bağlı, 0: açılana kadar' } } },
        { 'ac', 'Bildirimleri aç' },
        { 'op', 'Operatör paneli' },
        { 'r', 'Vatandaş çağrısına cevap', { { name = 'no', help = 'çağrı no' }, { name = 'cevap', help = 'mesaj' } } },
    }
    for _, sub in ipairs(SUBS) do
        local word = sub[1]
        if word ~= 'kod' then -- /dpkod is a server command (server/sv_calls.lua)
            Command(cmd .. word, function(src, args)
                local list = { word }
                for _, a in ipairs(args or {}) do list[#list + 1] = a end
                ask(src, list)
            end, false)
        end
        TriggerEvent('chat:addSuggestion', '/' .. cmd .. word, sub[2], sub[3] or {})
    end
end

Keys.map('desk', function() ask() end)

RegisterNetEvent('daddy_dispatch:desk:open', function(data)
    if type(data) ~= 'table' then return end
    for _, call in ipairs(data.calls or {}) do
        local known = Calls.list[call.id]
        call.place = known and known.place or nil
        if not call.place then
            local street, area = Context.street(call.coords)
            call.place = { street = street or call.street, area = area }
        end
    end
    Desk.open = true
    drawUnits(data.units or {})
    Page.open('desk', data)
end)

Page.closers.desk = function()
    Desk.open = false
    TriggerServerEvent('daddy_dispatch:desk:close')
    Radar.hide()
    clearUnitBlips()
    clearHeat()
end

-- The units while the desk or the operator panel shows: the whole list once, then one unit that changed (a status) or
-- the few that changed in a tick (places).
RegisterNetEvent('daddy_dispatch:desk:units', function(list)
    if not Desk.open and not Operator.shown then return end
    if Desk.open then drawUnits(list) end
    Page.send('desk:units', { list = list })
end)

RegisterNetEvent('daddy_dispatch:desk:unit', function(u)
    if not Desk.open and not Operator.shown or type(u) ~= 'table' then return end
    if Desk.open then drawUnit(u) end
    Page.send('desk:unit', { unit = u })
end)

RegisterNetEvent('daddy_dispatch:desk:delta', function(list)
    if not Desk.open and not Operator.shown or type(list) ~= 'table' then return end
    if Desk.open then
        for _, u in ipairs(list) do drawUnit(u) end
    end
    Page.send('desk:delta', { list = list })
end)

-- The page's map box (window fractions) and the call it shows.
Page.on('desk:radar', function(data)
    if data.on ~= true then return Radar.hide() end
    local r = {}
    for _, k in ipairs({ 'x', 'y', 'w', 'h' }) do
        r[k] = tonumber(data[k])
        if not r[k] or r[k] < 0 or r[k] > 1 then return { ok = false } end
    end
    Radar.show(r)
    if tonumber(data.cx) then Radar.focus(tonumber(data.cx), tonumber(data.cy)) end
end)

Page.on('desk:focus', function(data)
    if tonumber(data.x) and tonumber(data.y) then Radar.focus(tonumber(data.x), tonumber(data.y)) end
end)

Page.on('desk:note', function(data)
    TriggerServerEvent('daddy_dispatch:desk:note', tonumber(data.id), tostring(data.text or ''))
end)

Page.on('desk:close', function(data)
    TriggerServerEvent('daddy_dispatch:desk:closecall', tonumber(data.id), tostring(data.result or ''))
end)

Page.on('desk:assign', function(data)
    TriggerServerEvent('daddy_dispatch:desk:assign', tonumber(data.id), tonumber(data.unit))
end)

Page.on('desk:radio', function(data)
    TriggerServerEvent('daddy_dispatch:desk:radio', tonumber(data.id), tostring(data.channel or ''))
end)

-- The staff list: read from the server; a manager's change (warn, operator, code, hours, badge) comes back with it.
Page.on('desk:staff', function()
    return lib.callback.await('daddy_dispatch:staff', false) or { rows = {} }
end)

Page.on('desk:staffact', function(data)
    TriggerServerEvent('daddy_dispatch:staff:act', tostring(data.identifier or ''), tostring(data.action or ''), data.value)
end)

RegisterNetEvent('daddy_dispatch:staff', function(data)
    if Desk.open then Page.send('desk:staff', data) end
end)

-- A page of closed calls, with their street names read here.
Page.on('desk:history', function(data)
    local rows = lib.callback.await('daddy_dispatch:history', false, tonumber(data.page) or 0, data.query) or {}
    for _, row in ipairs(rows) do
        local street, area = Context.street(row.coords)
        row.place = { street = street or row.street, area = area }
    end
    return { ok = true, rows = rows }
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    clearUnitBlips()
    clearHeat()
    if Radar.shown then
        Radar.shown = false
        UnlockMinimapPosition()
        UnlockMinimapAngle()
    end
end)
