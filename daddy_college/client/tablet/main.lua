-- Staff tablet: opening, the prop in hand, the heartbeat and the bridge to the server.
if not Core.ModuleEnabled('tablet') then return end

local VIEW = 'tablet.shell'
local cfg = Config.Tablet
local prop, session = nil, 0

local function holdTablet(token)
    local ped = cache.ped
    if cfg.Prop and lib.requestModel(cfg.Prop.model, 5000) and token == session then
        local coords = GetEntityCoords(ped)
        pcall(function() exports['FeloxAC']:CreateObject(joaat(cfg.Prop.model)) end) --[[FeloxAC:auto]]
        prop = CreateObject(joaat(cfg.Prop.model), coords.x, coords.y, coords.z, true, true, false)
        AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, cfg.Prop.bone), cfg.Prop.pos.x, cfg.Prop.pos.y, cfg.Prop.pos.z,
            cfg.Prop.rot.x, cfg.Prop.rot.y, cfg.Prop.rot.z, true, true, false, true, 1, true)
        SetModelAsNoLongerNeeded(joaat(cfg.Prop.model))
    end
    if cfg.Anim and lib.requestAnimDict(cfg.Anim.dict, 5000) and token == session then
        TaskPlayAnim(ped, cfg.Anim.dict, cfg.Anim.clip, 3.0, 3.0, -1, 49, 0, false, false, false)
    end
    if cfg.FreezePlayer then FreezeEntityPosition(ped, true) end
end

local function putAway()
    if prop and DoesEntityExist(prop) then DeleteEntity(prop) end
    prop = nil
    ClearPedTasks(cache.ped)
    if cfg.FreezePlayer then FreezeEntityPosition(cache.ped, false) end
end

local function stop()
    session = session + 1
    TriggerServerEvent('daddy_college:tablet:close')
    putAway()
end

local function heartbeat(token, interval)
    CreateThread(function()
        while token == session do
            Wait(interval)
            if token == session and Core.Nui.IsOpen(VIEW) then TriggerServerEvent('daddy_college:tablet:heartbeat') end
        end
    end)
end

-- app: the application to show first (the player's own start page otherwise).
local function open(app)
    if Core.Nui.IsOpen() then return end
    local response = lib.callback.await('daddy_college:tablet:open', false)
    if not response or not response.ok then return Core.HandleResult(response, 'tablet') end
    session = session + 1
    local token = session
    response.data.start = type(app) == 'string' and app or nil
    Core.Nui.Open(VIEW, response.data)
    CreateThread(function() holdTablet(token) end)
    heartbeat(token, response.data.heartbeatMs)
end

Core.Nui.OnClose(VIEW, stop)
RegisterNetEvent('daddy_college:tablet:openRequest', function(app) CreateThread(function() open(app) end) end)

-- Teacher commands of other modules open the tablet at their application.
function Core.OpenTablet(app) CreateThread(function() open(app) end) end

if cfg.Command ~= '' then
    Core.Command(cfg.Command, function() open() end)
end

-- The server dropped us (lost the job): close the open tablet too.
RegisterNetEvent('daddy_college:tablet:forceClose', function()
    if Core.Nui.IsOpen(VIEW) then Core.Nui.Close() end
end)

RegisterNetEvent('daddy_college:tablet:sync', function(data)
    if Core.Nui.IsOpen(VIEW) then Core.Nui.Send('tablet:sync', data) end
end)

-- Bridge ------------------------------------------------------------------------------------

-- A timed-out session is renewed quietly while the tablet is open, then the call runs again.
local function call(name, data)
    local response = lib.callback.await(name, false, data)
    if type(response) == 'table' and response.error == 'session_expired' and Core.Nui.IsOpen(VIEW) then
        local renewed = lib.callback.await('daddy_college:tablet:open', false)
        if renewed and renewed.ok then response = lib.callback.await(name, false, data) end
    end
    response = response or { ok = false, error = 'db_unavailable' }
    -- A code the tablet has no text for is stored; a page may word it itself, so the raw code shows in test mode only.
    local code = response.ok == false and not response.fault and response.error
    if type(code) == 'string' and code ~= 'session_expired' then
        local key = ('errors.%s.title'):format(code)
        if DL.locale.t(key) == key then Core.Untexted('errors.' .. code, code, Core.Roles().test ~= true) end
    end
    return response
end

-- { name, data } -> daddy_college:tablet:<name>; the server checks every call.
Core.Nui.SafeCallback('tablet:call', function(input)
    local name = tostring(input.name or '')
    if not name:match('^%a+$') then return { ok = false, error = 'validation' } end
    return call('daddy_college:tablet:' .. name, type(input.data) == 'table' and input.data or {})
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    session = session + 1
    putAway()
end)
