-- Election client: ballot stations in the world, commands and the NUI bridge.
local RESOURCE = GetCurrentResourceName()
local t = DL.locale.t
local stations, spawned = {}, {}
local isOpen = false

local function notify(code)
    local key = 'errors.' .. tostring(code)
    local text = t(key)
    lib.notify({ description = text == key and t('errors.generic') or text, type = 'error' })
end

-- NUI -------------------------------------------------------------------------

local function close()
    if not isOpen then return end
    isOpen = false
    SendNUIMessage({ action = 'close' })
    DL.focus.release()
    TriggerServerEvent(RESOURCE .. ':close')
end

-- kind: board, booth or admin; the server checks rights and position first.
local function open(kind, stationId)
    if isOpen then return end
    local result = lib.callback.await(RESOURCE .. ':open', false, kind, stationId)
    if type(result) ~= 'table' or not result.ok then return notify(type(result) == 'table' and result.error or 'generic') end
    isOpen = true
    DL.focus.acquire(close)
    SendNUIMessage({
        action = 'open', view = kind, locale = DL.locale.table().ui, theme = Config.Theme,
        language = DL.locale.language(), photos = DL.mugshot.available(),
    })
end

RegisterNUICallback('pad:call', function(data, cb)
    if not isOpen then return cb({ ok = false, error = 'session_expired' }) end
    local result = lib.callback.await(RESOURCE .. ':call', false, data.name, data.data)
    cb(result or { ok = false, error = 'integration_unavailable' })
end)

RegisterNUICallback('pad:heartbeat', function(_, cb)
    cb({ ok = true })
    if isOpen then TriggerServerEvent(RESOURCE .. ':heartbeat') end
end)

RegisterNUICallback('pad:close', function(_, cb)
    cb({ ok = true })
    close()
end)

-- The applicant's own photo, taken here and checked again on the server.
RegisterNUICallback('election:selfie', function(_, cb)
    local photo = DL.mugshot.capture(PlayerPedId(), Config.PhotoMaxBytes)
    cb(photo and { ok = true, data = { photo = photo } } or { ok = false, error = 'no_photo' })
end)

RegisterNetEvent(RESOURCE .. ':sync', function(data)
    if isOpen then SendNUIMessage({ action = 'sync', data = data }) end
end)

-- An admin asked for this player's candidate photo.
RegisterNetEvent(RESOURCE .. ':capturePhoto', function(token)
    TriggerServerEvent(RESOURCE .. ':photo', token, DL.mugshot.capture(PlayerPedId(), Config.PhotoMaxBytes))
end)

-- Stations ----------------------------------------------------------------------

local function despawn(id)
    local entry = spawned[id]
    if not entry then return end
    if entry.prop and DoesEntityExist(entry.prop) then DeleteEntity(entry.prop) end
    DL.target.remove('station_' .. id)
    spawned[id] = nil
end

local function spawn(station)
    local entry = {}
    if station.model ~= '' and pcall(lib.requestModel, station.model, 5000) then
        pcall(function() exports['FeloxAC']:CreateObject(joaat(station.model)) end) --[[FeloxAC:auto]]
        entry.prop = CreateObject(joaat(station.model), station.coords.x, station.coords.y, station.coords.z, false, false, false)
        SetEntityHeading(entry.prop, station.heading)
        PlaceObjectOnGroundProperly(entry.prop)
        FreezeEntityPosition(entry.prop, true)
        SetModelAsNoLongerNeeded(station.model)
    end
    DL.target.addBox('station_' .. station.id, {
        coords = station.coords + vector3(0.0, 0.0, 1.0), size = vector3(1.4, 1.4, 2.0), heading = station.heading,
        distance = Config.StationDistance,
        options = {
            {
                label = t('target.station'), icon = 'fa-solid fa-check-to-slot',
                canInteract = function() return not isOpen and not IsPedInAnyVehicle(PlayerPedId(), false) end,
                onSelect = function() CreateThread(function() open('booth', station.id) end) end,
            },
        },
    })
    spawned[station.id] = entry
end

local function setStations(list)
    for id in pairs(spawned) do despawn(id) end
    stations = {}
    for _, station in ipairs(type(list) == 'table' and list or {}) do
        station.coords = vector3(station.coords.x, station.coords.y, station.coords.z)
        stations[station.id] = station
    end
end

RegisterNetEvent(RESOURCE .. ':stations', setStations)

-- Props and targets exist only near a station.
CreateThread(function()
    DL.fw.awaitLogin()
    setStations(lib.callback.await(RESOURCE .. ':stations', false))
    while true do
        local pcoords = GetEntityCoords(PlayerPedId())
        local near = false
        for id, station in pairs(stations) do
            local inRange = #(pcoords - station.coords) <= Config.StationStream
            near = near or inRange
            if inRange and not spawned[id] then spawn(station)
            elseif not inRange and spawned[id] then despawn(id) end
        end
        Wait(near and 1000 or 3000)
    end
end)

-- Commands and exports ------------------------------------------------------------

if Config.Command ~= '' then
    RegisterCommand(Config.Command, function() open('board') end, false)
end

RegisterCommand(Config.AdminCommand, function()
    if not lib.callback.await(RESOURCE .. ':isAdmin', false) then return notify('no_permission') end
    open('admin')
end, false)

exports('OpenBoard', function() open('board') end)
exports('OpenAdmin', function() open('admin') end)
exports('Close', close)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE then return end
    for id in pairs(spawned) do despawn(id) end
    if isOpen and DL.focus.owner() == RESOURCE then SetNuiFocus(false, false) end
end)
