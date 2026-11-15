-- Arcade Pad client: open/close, tablet prop and the NUI bridge.
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
    SendNUIMessage({ action = 'open', locale = DL.locale.table(), language = DL.locale.language(), theme = Config.Theme })
end

local function guarded(cb)
    if isOpen then return true end
    cb({ ok = false, error = 'session_expired' })
end

RegisterNUICallback('pad:bootstrap', function(_, cb)
    if not guarded(cb) then return end
    local result = lib.callback.await(RESOURCE .. ':open', false)
    if type(result) == 'table' and result.error == 'no_item' then
        close()
        notify('notify.no_item')
    end
    cb(result or { ok = false, error = 'integration_unavailable' })
end)

-- Every game endpoint goes through one callback; the server validates the name.
RegisterNUICallback('pad:call', function(data, cb)
    if not guarded(cb) then return end
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

-- Player portrait for game lobbies, when MugShotBase64 is installed.
RegisterNUICallback('pad:photo', function(data, cb)
    if GetResourceState('MugShotBase64') ~= 'started' then return cb({ ok = false, error = 'unavailable' }) end
    local player = data.serverId and GetPlayerFromServerId(tonumber(data.serverId)) or PlayerId()
    if player == -1 then return cb({ ok = false, error = 'not_active' }) end
    local ok, photo = pcall(function() return exports.MugShotBase64:GetMugShotBase64(GetPlayerPed(player), false) end)
    if ok and type(photo) == 'string' and photo:sub(1, 22) == 'data:image/png;base64,' then
        return cb({ ok = true, data = { photo = photo } })
    end
    cb({ ok = false, error = 'failed' })
end)

RegisterNetEvent(RESOURCE .. ':sync', function(data)
    SendNUIMessage({ action = 'sync', data = data })
end)

RegisterNetEvent(RESOURCE .. ':open', open)
RegisterNetEvent(RESOURCE .. ':notify', notify)

exports('Open', open)
exports('Close', close)
exports('IsOpen', function() return isOpen end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE then return end
    putAway()
    if isOpen then SetNuiFocus(false, false) end
end)
