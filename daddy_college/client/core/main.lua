-- College client core: roles the server sent, notices, results and login hooks.
Core = { Util = { L = DL.locale.t, Lf = DL.locale.t } }

local roles = {}

function Core.ModuleEnabled(name) return Config.Modules[name] ~= false end
function Core.GetCitizenId() return DL.fw.citizenId() end

-- Role flags come from the server; they only decide what the UI shows.
function Core.IsStudent() return roles.student == true end
function Core.IsTeacher() return roles.teacher == true end
function Core.IsAdmin() return roles.admin == true end
function Core.IsSecurity() return roles.security == true end
function Core.IsPrincipal() return roles.principal == true end
Core.IsPrincipalOrMaster = Core.IsPrincipal
function Core.IsSchoolMember() return roles.member == true end
function Core.Roles() return roles end

RegisterNetEvent('daddy_college:roles', function(flags)
    roles = type(flags) == 'table' and flags or {}
    TriggerEvent('daddy_college:rolesChanged', roles)
end)

-- Login hooks run once the character is in, and again after a character switch.
local loggedIn, waiters = false, {}

local function run(fn)
    CreateThread(function()
        local ok, err = pcall(fn)
        if not ok then print(('^1[daddy_college] login hook: %s^7'):format(err)) end
    end)
end

function Core.OnLogin(fn)
    waiters[#waiters + 1] = fn
    if loggedIn then run(fn) end
end

CreateThread(function()
    DL.fw.awaitLogin()
    loggedIn = true
    lib.callback.await('daddy_college:roles', false)
    for _, fn in ipairs(waiters) do run(fn) end
end)

DL.fw.onLoaded(function()
    lib.callback.await('daddy_college:roles', false)
    for _, fn in ipairs(waiters) do run(fn) end
end)

-- Notices and results ----------------------------------------------------------------------

-- kind: 'success' | 'error' | 'warning' | 'inform'. The school's paper tickets, or ox_lib's notifications.
function Core.Notify(message, kind)
    if not message or message == '' then return end
    if Config.Ui and Config.Ui.Notifications == 'ox' then return lib.notify({ description = message, type = kind or 'inform' }) end
    SendNUIMessage({ action = 'notify', data = { message = message, kind = kind or 'inform' } })
end

RegisterNetEvent('daddy_college:notify', function(message, kind) Core.Notify(message, kind) end)

function Core.NotifyL(key, kind, ...)
    Core.Notify(DL.locale.t(key, ...), kind)
end

-- Any server answer -> { ok, data } or { ok = false, error }. The fields also stay on top, where views read them.
function Core.NormalizeResult(result)
    if type(result) ~= 'table' then return { ok = false, error = 'db_unavailable' } end
    if result.ok == false or result.error or result.reason then
        result.ok, result.error = false, result.error or result.reason
        return result
    end
    if result.data == nil then
        local data = {}
        for key, value in pairs(result) do
            if key ~= 'ok' then data[key] = value end
        end
        result.data = data
    end
    result.ok = true
    return result
end

-- An error code no text covers: the player sees the raw code (not when quiet) and the gap is stored once (DL.fault).
local untexted = {}

function Core.Untexted(key, code, quiet)
    if not quiet then Core.NotifyL('common.refused', 'error', code) end
    if untexted[key] then return end
    untexted[key] = true
    lib.callback('daddy_college:fault:text', false, function() end, key)
end

-- Shows the module's text for an error, then the common one, then the raw code; result.args fill the text.
-- A failure with a fault code was already told by the server.
function Core.HandleResult(result, module)
    if result and result.ok then return true end
    if result and result.fault then return false end
    local code = result and (result.error or result.reason) or 'generic_error'
    local args = result and type(result.args) == 'table' and result.args or {}
    for _, key in ipairs({ ('%s.%s'):format(module or 'common', code), 'common.' .. code }) do
        local text = DL.locale.t(key, table.unpack(args))
        if text ~= key then
            Core.Notify(text, 'error')
            return false
        end
    end
    Core.Untexted(('%s.%s'):format(module or 'common', code), tostring(code))
    return false
end

function Core.Command(name, fn, module)
    if module and not Core.ModuleEnabled(module) then return end
    RegisterCommand(name, function(_, args) CreateThread(function() fn(args) end) end, false)
end

-- A command's player: the id typed first, or the nearest player within reach (the server checks both again).
function Core.CommandTarget(args, reach)
    local id = tonumber(args and args[1])
    if id then return id end
    local player = lib.getClosestPlayer(GetEntityCoords(cache.ped), reach or 3.0, false)
    if player then return GetPlayerServerId(player) end
    Core.NotifyL('common.player_offline', 'error')
end

Core.World = World.client()

function Core.HasCampus() return #Core.World.zones({ kind = 'campus' }) > 0 end

-- Inside a campus zone, or anywhere when no campus is drawn.
-- The campus shapes are built once until the world changes; loops ask every few seconds.
local campusShapes, watching

function Core.OnCampus(coords)
    coords = coords or GetEntityCoords(cache.ped)
    if not watching then
        watching = true
        Core.World.subscribe(function() campusShapes = nil end) -- runs once now, then after every world change
    end
    if not campusShapes then
        campusShapes = {}
        for _, zone in ipairs(Core.World.zones({ kind = 'campus' })) do campusShapes[#campusShapes + 1] = DL.geo.fromRecord(zone) end
    end
    if #campusShapes == 0 then return true end
    for _, shape in ipairs(campusShapes) do
        if DL.geo.contains(shape, coords) then return true end
    end
    return false
end
