local isOpen = false

local function release()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    TriggerServerEvent('daddy_venue:closed')
end

local function show(data)
    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', data = data })
end

local function openBusiness(id)
    local data = lib.callback.await('daddy_venue:open', false, id)
    if not data then return lib.notify({ type = 'error', description = L('not_allowed') }) end
    show(data)
end

-- /business: the window of the business opens anywhere; withdrawing, paying and the like still need the office
local function open()
    if isOpen then return release() end
    local list = lib.callback.await('daddy_venue:list', false)
    if not list or #list == 0 then return lib.notify({ type = 'error', description = L('no_business') }) end
    if #list == 1 then return openBusiness(list[1].id) end
    local options = {}
    for i, entry in ipairs(list) do
        options[i] = { title = entry.label, onSelect = function() openBusiness(entry.id) end }
    end
    lib.registerContext({ id = 'daddy_pick', title = L('business'), options = options })
    lib.showContext('daddy_pick')
end

RegisterCommand(Config.OpenCommand, open, false)

local function openKiosk()
    if isOpen then return release() end
    local data = lib.callback.await('daddy_venue:kiosk', false)
    if not data or data.error then
        return lib.notify({ type = 'error', description = Venue.closedText(data or {}) })
    end
    show(data)
end

AddEventHandler('daddy_venue:openKiosk', openKiosk)

-- DaddyRP: the cooking minigame at a station (UI-KIT box in the middle of the screen). Keys only, no cursor;
-- answers true when it was won, false when the cook gave up with ESC.
local game
Venue.Local = Venue.Local or {}

function Venue.Local.minigame(data)
    if isOpen or game then return false end
    game = promise.new()
    SetNuiFocus(true, false)
    SendNUIMessage({ action = 'game', data = { kind = data.kind, title = data.title, path = data.path, lang = Config.Locale } })
    local won = Citizen.Await(game)
    game = nil
    SetNuiFocus(false, false)
    return won == true
end

RegisterNuiCallback('gameDone', function(body, cb)
    cb({})
    if game then game:resolve(body and body.won == true) end
end)

-- DaddyRP: the admin window. Work on the map (drawing, the delivery spot) closes it, it comes back on the same page after.
local function openAdmin(screen, focus)
    if isOpen then return release() end
    local res = lib.callback.await('daddy_venue:admin', false, 'check')
    if not res or not res.ok then return lib.notify({ type = 'error', description = L('not_allowed') }) end
    show({
        mode = 'admin', lang = Config.Locale, screen = screen, focus = focus, notices = {},
        business = { id = 0, name = '', kind = '', accent = '219 31 20', role = '', onDuty = false, permissions = {}, currency = Config.Currency, balance = 0, staffOnDuty = 0, openOrders = 0 },
    })
end

RegisterCommand(Config.AdminCommand, function() openAdmin() end, false)
AddEventHandler('daddy_venue:adminBack', openAdmin)

-- every NUI callback answers, also when the server call throws (timeout): an unanswered fetch hangs the window
RegisterNuiCallback('admin', function(body, cb)
    local ok, result = pcall(lib.callback.await, 'daddy_venue:admin', false, body.action, body.body)
    cb(ok and type(result) == 'table' and result or { ok = false, error = 'busy' })
end)

RegisterNuiCallback('adminMap', function(body, cb)
    release()
    cb({})
    TriggerEvent('daddy_venue:adminMap', body)
end)

RegisterNetEvent('daddy_venue:show', function(data)
    if type(data) == 'table' then show(data) end
end)

RegisterNetEvent('daddy_venue:message', function(message)
    if type(message) ~= 'table' then return end
    if message.action == 'close' then return release() end
    SendNUIMessage(message)
end)

RegisterNuiCallback('close', function(_, cb)
    release()
    cb({})
end)

RegisterNuiCallback('build', function(_, cb)
    release()
    cb({})
    CreateThread(Venue.Local.build)
end)

local function forward(name, isWrite)
    RegisterNuiCallback(name, function(body, cb)
        local ok, result = pcall(lib.callback.await, 'daddy_venue:call', false, name, body)
        if not ok or type(result) ~= 'table' then
            if isWrite then return cb({ ok = false, error = 'busy' }) end
            return cb()
        end
        if not isWrite and result.ok == false then return cb() end
        cb(result)
    end)
end

-- the server may not answer yet (still starting): ask again until it does, without the names no window page loads
CreateThread(function()
    local names
    for attempt = 1, 30 do
        local ok, result = pcall(lib.callback.await, 'daddy_venue:names', false)
        if ok and type(result) == 'table' and type(result.read) == 'table' and type(result.write) == 'table' then
            names = result
            break
        end
        Wait(math.min(attempt, 10) * 1000)
    end
    if not names then return print('^1[daddy_venue] the server did not send the window calls^0') end
    for _, name in ipairs(names.read) do forward(name, false) end
    for _, name in ipairs(names.write) do forward(name, true) end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and (isOpen or game) then SetNuiFocus(false, false) end
end)

-- DaddyRP: logging out to the multichar screen closes the window of the old character
RegisterNetEvent('QBCore:Client:OnPlayerUnload', release)
RegisterNetEvent('esx:onPlayerLogout', release)
