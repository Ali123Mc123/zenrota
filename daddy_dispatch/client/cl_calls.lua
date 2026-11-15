-- The open calls this unit can see: the server sends them, the player's filters decide which pop up, sound and get a
-- blip (the list and the desk show them all). Distance and direction go to the page; the keys act on the newest call.
Calls = { list = {}, current = nil, hidden = false }
local blips = {}
-- The calls the page shows (it says which) and the distance and direction it last got of each.
local watched, told = {}, {}

-- Paused: Pause.untilAt is -1 (until opened) or a time; panic and the joined call may still come.
Pause = { untilAt = nil }

function Pause.on()
    return Pause.untilAt == -1 or (Pause.untilAt ~= nil and Core.now() < Pause.untilAt)
end

local function distanceTo(call)
    local p = GetEntityCoords(PlayerPedId())
    return #(vector2(p.x, p.y) - vector2(call.coords.x, call.coords.y))
end

-- Whether a call pops up, sounds and gets a blip for this player.
local function alerts(call)
    if call.panic then return not Pause.on() or Prefs.panicThrough end
    if Me.call == call.id then return not Pause.on() or Prefs.joinedThrough end
    if Pause.on() then return false end
    if call.priority > Prefs.prio or Prefs.kinds[call.kind] then return false end
    if Prefs.own and call.kind == 'officer' and call.dept and call.dept ~= Me.job then return false end
    if Prefs.km > 0 and distanceTo(call) > Prefs.km * 1000 then return false end
    return true
end

-- Blips ----------------------------------------------------------------------------------------------------------------
local function removeBlip(id)
    local b = blips[id]
    if not b then return end
    if DoesBlipExist(b.main) then RemoveBlip(b.main) end
    if b.radius and DoesBlipExist(b.radius) then RemoveBlip(b.radius) end
    blips[id] = nil
end

local function addBlip(call)
    removeBlip(call.id)
    if not Config.Blips.Show or type(call.blip) ~= 'table' then return end
    local c = call.coords
    local main = AddBlipForCoord(c.x, c.y, c.z)
    SetBlipSprite(main, tonumber(call.blip.sprite) or 161)
    SetBlipColour(main, tonumber(call.blip.colour) or 1)
    SetBlipScale(main, tonumber(call.blip.scale) or 1.0)
    SetBlipAsShortRange(main, false)
    if Config.Blips.Flash and call.priority == 1 then SetBlipFlashes(main, true) end
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(('%s · %s'):format(call.code, call.title))
    EndTextCommandSetBlipName(main)
    local radius
    if Config.Blips.Radius and call.radius then
        radius = AddBlipForRadius(c.x, c.y, c.z, call.radius + 0.0)
        SetBlipColour(radius, tonumber(call.blip.colour) or 1)
        SetBlipAlpha(radius, 80)
    end
    blips[call.id] = { main = main, radius = radius, untilAt = GetGameTimer() + Config.Blips.Minutes * 60000, flashUntil = GetGameTimer() + 10000 }
end

local function moveBlip(call)
    local b = blips[call.id]
    if not b then return end
    local c = call.coords
    SetBlipCoords(b.main, c.x, c.y, c.z)
    if b.radius then SetBlipCoords(b.radius, c.x, c.y, c.z) end
end

-- Blips go after Config.Blips.Minutes, unless it is the call the player is on; flashing stops after 10 s.
CreateThread(function()
    while true do
        Wait(5000)
        local now = GetGameTimer()
        for id, b in pairs(blips) do
            if now > b.untilAt and Me.call ~= id then removeBlip(id) end
            if b.flashUntil and now > b.flashUntil and DoesBlipExist(b.main) then
                SetBlipFlashes(b.main, false)
                b.flashUntil = nil
            end
        end
    end
end)

-- The list -------------------------------------------------------------------------------------------------------------
-- The street and area here (the server cannot read street names).
local function place(call)
    local street, area = Context.street(call.coords)
    call.place = { street = street or call.street, area = area }
end

function Calls.clear()
    for id in pairs(blips) do removeBlip(id) end
    Calls.list, Calls.current, told = {}, nil, {}
    Page.send('calls', { list = {} })
end

-- A call: a new one pops, sounds and gets a blip when it passes the player's filters; one that was there is updated.
local function add(call, quiet)
    place(call)
    local loud = not quiet and alerts(call)
    call.quiet = not loud
    Calls.list[call.id] = call
    if loud then
        addBlip(call)
        Sound.forCall(call)
        if Prefs.autoMark and distanceTo(call) < 300.0 then SetNewWaypoint(call.coords.x, call.coords.y) end
    end
    return call
end

RegisterNetEvent('daddy_dispatch:calls', function(list)
    for id in pairs(blips) do removeBlip(id) end
    Calls.list, told = {}, {}
    local out = {}
    for _, call in ipairs(list or {}) do out[#out + 1] = add(call, true) end
    Page.send('calls', { list = out })
end)

RegisterNetEvent('daddy_dispatch:call', function(call)
    if not Me.unit or type(call) ~= 'table' then return end
    Page.send('call', { call = add(call) })
end)

RegisterNetEvent('daddy_dispatch:change', function(id, changes)
    local call = Calls.list[id]
    if not call or type(changes) ~= 'table' then return end
    for k, v in pairs(changes) do call[k] = v end
    if changes.coords then
        place(call)
        moveBlip(call)
        changes.place = call.place
    end
    Page.send('change', { id = id, changes = changes })
    -- A note on the call I am on brings it back up (while paused only if the player wants it).
    if changes.notes and Me.call == id and (not Pause.on() or Prefs.joinedThrough) then Page.send('show', { id = id }) end
end)

RegisterNetEvent('daddy_dispatch:drop', function(id, result)
    local call = Calls.list[id]
    Calls.list[id], told[id], watched[id] = nil, nil, nil
    removeBlip(id)
    if call and Me.call == id then Bridge.notify(Core.t('msg.closed', call.code, Core.t('results.' .. tostring(result))), 'info') end
    Page.send('drop', { id = id, result = result })
end)

-- Joining and leaving (the server sets the status), marking.
function Calls.join(id)
    if not Me.unit then return end -- silent: players who are not dispatch units never get a message
    if Me.call == id then
        TriggerServerEvent('daddy_dispatch:leave', id)
        local call = Calls.list[id]
        if call then Bridge.notify(Core.t('msg.left', call.code), 'info') end
        return
    end
    TriggerServerEvent('daddy_dispatch:join', id)
end

-- The call's place as the waypoint, with its blip.
local function waypoint(call)
    SetNewWaypoint(call.coords.x, call.coords.y)
    if not blips[call.id] then addBlip(call) end
end

function Calls.mark(id)
    local call = Calls.list[id]
    if not call then return end
    waypoint(call)
    Bridge.notify(Core.t('msg.marked'), 'success')
end

RegisterNetEvent('daddy_dispatch:joined', function(id, ok)
    local call = Calls.list[id]
    if not ok or not call then return end
    waypoint(call)
    Bridge.notify(Core.t('msg.joined', call.code), 'success')
    if Config.Radio.Switch and call.radio and Bridge.setRadio(call.radio) then Bridge.notify(Core.t('msg.radio_switched', call.radio), 'info') end
end)

-- The desk put me on a call: its waypoint; it pops up and sounds unless I paused without joinedThrough.
RegisterNetEvent('daddy_dispatch:assigned', function(id)
    local call = Calls.list[id]
    if not call then return end
    waypoint(call)
    if not Pause.on() or Prefs.joinedThrough then
        Sound.forCall(call)
        Page.send('assigned', { id = id })
    end
end)

-- Distance and direction of the calls on screen, for the arrows (degrees clockwise from where the camera looks). Only
-- what moved: the shown distance (10 m steps, 100 m past a kilometre) or 3 degrees; nothing while none shows.
Page.on('watch', function(data)
    watched = {}
    for i, id in ipairs(type(data.ids) == 'table' and data.ids or {}) do
        if i > 60 then break end
        id = tonumber(id)
        if id and Calls.list[id] then watched[id] = true end
    end
end)

CreateThread(function()
    while true do
        local busy = next(watched) and not Calls.hidden
        Wait(busy and 300 or 1000)
        if busy then
            local p = GetEntityCoords(PlayerPedId())
            local cam = GetGameplayCamRot(2).z
            local out = {}
            for id in pairs(watched) do
                local call = Calls.list[id]
                if call then
                    local dx, dy = call.coords.x - p.x, call.coords.y - p.y
                    local d = math.floor(math.sqrt(dx * dx + dy * dy))
                    local a = math.floor((cam - math.deg(math.atan(dy, dx)) + 90.0) % 360)
                    local step = d < 1000 and 10 or 100
                    local last = told[id]
                    if not last or last.d // step ~= d // step or math.abs((last.a - a + 180) % 360 - 180) >= 3 then
                        told[id] = { d = d, a = a }
                        out[#out + 1] = { id = id, d = d, a = a }
                    end
                end
            end
            if #out > 0 then Page.send('where', { list = out }) end
        end
    end
end)

-- The page --------------------------------------------------------------------------------------------------------------
Page.on('current', function(data)
    Calls.current = tonumber(data.id)
end)

Page.on('join', function(data) Calls.join(tonumber(data.id)) end)
Page.on('mark', function(data) Calls.mark(tonumber(data.id)) end)

-- A sample call for the settings' test button: only on this screen, never sent.
Page.on('test', function(data)
    local p = GetEntityCoords(PlayerPedId())
    local priority = math.floor(Core.clamp(data.priority or 1, 1, 3))
    local call = {
        id = -GetGameTimer(), type = 'test', code = priority == 1 and '10-32' or priority == 2 and '10-55' or '10-10',
        title = Core.t('alerts.test'), priority = priority, icon = 'radio', kind = 'other',
        coords = { x = p.x + 180.0, y = p.y + 240.0, z = p.z }, fields = {}, units = {}, count = 1, at = Core.now(), test = true,
    }
    place(call)
    Sound.forCall(call)
    Page.send('call', { call = call, test = true })
end)

-- The keys ---------------------------------------------------------------------------------------------------------------
Keys.map('join', function()
    if Calls.current then Calls.join(Calls.current) end
end)

Keys.map('mark', function()
    if Calls.current then Calls.mark(Calls.current) end
end)

Keys.map('list', function()
    if not Me.unit then return end
    if Page.screen == 'list' then Page.close('list') else Page.open('list') end
end)

-- Hiding the alerts says so (a notice now, a chip on screen while hidden); the key and the settings both come here.
function Calls.setHidden(on)
    Calls.hidden = on == true
    Page.send('hide', { on = Calls.hidden })
    Bridge.notify(Core.t(Calls.hidden and 'msg.hidden_on' or 'msg.hidden_off'), 'info')
end

Keys.map('hide', function()
    if not Me.unit then return end
    Calls.setHidden(not Calls.hidden)
end)

Page.on('hide', function(data)
    Calls.setHidden(data.on == true)
end)
