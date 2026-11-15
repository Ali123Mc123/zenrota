-- Student Tablet client: open/close, the tablet prop and the NUI bridge.
local RESOURCE = GetCurrentResourceName()
local ANIM_DICT, ANIM_NAME = 'amb@world_human_seat_wall_tablet@female@base', 'base'
local PROP_MODEL = `prop_cs_tablet`
local CLOSE_GRACE_MS = 1000

local isOpen = false
local prop

local function notify(key)
    lib.notify({ description = DL.locale.t(key), type = 'error' })
end

local function holdTablet()
    local ped = PlayerPedId()
    if pcall(lib.requestAnimDict, ANIM_DICT, 2000) then
        TaskPlayAnim(ped, ANIM_DICT, ANIM_NAME, 8.0, -8.0, -1, 49, 0, false, false, false)
    end
    if not pcall(lib.requestModel, PROP_MODEL, 2000) then return end
    local coords = GetEntityCoords(ped)
    pcall(function() exports['FeloxAC']:CreateObject(PROP_MODEL) end) --[[FeloxAC:auto]]
    prop = CreateObject(PROP_MODEL, coords.x, coords.y, coords.z, true, true, false)
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 28422), -0.03, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(PROP_MODEL)
end

local function putAway()
    if prop and DoesEntityExist(prop) then DeleteEntity(prop) end
    prop = nil
    StopAnimTask(PlayerPedId(), ANIM_DICT, ANIM_NAME, 2.0)
end

local function close()
    if not isOpen then return end
    isOpen = false
    SendNUIMessage({ action = 'close' })
    DL.focus.release()
    putAway()
    -- Give in-flight requests a moment before the server drops the session.
    SetTimeout(CLOSE_GRACE_MS, function()
        if not isOpen then TriggerServerEvent(RESOURCE .. ':close') end
    end)
end

local function open()
    if isOpen then return end
    if IsPedInAnyVehicle(PlayerPedId(), false) then return notify('notify.in_vehicle') end

    isOpen = true
    DL.focus.acquire(close)
    holdTablet()
    SendNUIMessage({ action = 'open', locale = DL.locale.table(), language = DL.locale.language(), theme = Config.Theme, hour = GetClockHours() })
end

local function guarded(cb)
    if isOpen then return true end
    cb({ ok = false, error = 'session_expired' })
end

RegisterNUICallback('pad:bootstrap', function(_, cb)
    if not guarded(cb) then return end
    local result = lib.callback.await(RESOURCE .. ':open', false)
    -- Without the item, a school role or College there is nothing to show: the tablet closes with why.
    local why = type(result) == 'table' and ({ no_item = true, no_permission = true, college_missing = true })[result.error]
    if why then
        close()
        lib.notify({ description = result.text or DL.locale.t('notify.' .. result.error), type = 'error' })
    end
    cb(result or { ok = false, error = 'integration_unavailable' })
end)

-- Every endpoint goes through one callback; the server validates the name.
RegisterNUICallback('pad:call', function(data, cb)
    if not guarded(cb) then return end
    local result = lib.callback.await(RESOURCE .. ':call', false, data.name, data.data)
    cb(result or { ok = false, error = 'integration_unavailable' })
end)

-- A club's logo from College's client, which downloads each revision once for every screen: { ok, data = { src } }.
RegisterNUICallback('pad:clubLogo', function(data, cb)
    local res = DL.product.resource('college')
    local asked = res and pcall(function()
        exports[res]:ClubLogo(tonumber(data.clubId) or 0, tonumber(data.rev) or 0, function(src)
            cb(type(src) == 'string' and { ok = true, data = { src = src } } or { ok = false, error = 'logo_gone' })
        end)
    end)
    if not asked then cb({ ok = false, error = 'college_missing' }) end
end)

RegisterNUICallback('pad:heartbeat', function(_, cb)
    cb({ ok = true })
    if isOpen then TriggerServerEvent(RESOURCE .. ':heartbeat') end
end)

RegisterNUICallback('pad:close', function(_, cb)
    cb({ ok = true })
    close()
end)

RegisterNetEvent(RESOURCE .. ':sync', function(data)
    SendNUIMessage({ action = 'sync', data = data })
end)

RegisterNetEvent(RESOURCE .. ':open', open)
RegisterNetEvent(RESOURCE .. ':close', close)
RegisterNetEvent(RESOURCE .. ':notify', notify)

exports('Open', open)
exports('Close', close)
exports('IsOpen', function() return isOpen end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE then return end
    putAway()
    if isOpen then SetNuiFocus(false, false) end
end)

-- A message from an added app's resource to its page (SendAppMessage).
RegisterNetEvent(RESOURCE .. ':appMessage', function(app, data)
    SendNUIMessage({ action = 'appMessage', app = app, data = data })
end)

-- College's lesson quiz while the tablet is open: the quiz band shows who was asked and the result (answers stay on
-- the phone and the paper card). An opened tablet reads the open question itself.
RegisterNetEvent('daddy_college:lessonquiz:round', function(p)
    if isOpen and type(p) == 'table' and p.state ~= 'world' then SendNUIMessage({ action = 'appMessage', app = 'quiz', data = p }) end
end)

-- A notice from an added app's resource (Notify): a banner, or a lock screen notice for later.
RegisterNetEvent(RESOURCE .. ':appNotice', function(app, title, text)
    SendNUIMessage({ action = 'appNotice', app = app, title = title, text = text })
end)
