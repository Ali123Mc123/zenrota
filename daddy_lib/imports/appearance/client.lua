-- Clothing on the client: dresses preview peds and the player, and runs the clothing script's creator.
local shared = DL.require('appearance/shared')
local native = DL.require('appearance/native')(shared)

local appearance = { id = shared.detect() }
local script = appearance.id
local FILES = { illenium = true, fivem = true, qbclothing = true, skinchanger = true }
local BY_FORMAT = { illenium = { 'illenium', 'fivem' }, qb = { 'qbclothing' } }
local FORMAT_OF = { illenium = 'illenium', fivem = 'illenium', qbclothing = 'qb', skinchanger = 'skinchanger' }
local adapters, hook, current = {}, nil, nil

-- One adapter per script id, built on first use; unknown ids use the native dresser.
local function adapterOf(id)
    if adapters[id] == nil then
        adapters[id] = FILES[id] and DL.require('appearance/' .. id)({ resource = shared.resourceOf(id), shared = shared, native = native }) or native
    end
    return adapters[id]
end

local function running(id)
    local resource = shared.resourceOf(id)
    return resource ~= nil and GetResourceState(resource) == 'started'
end

-- A community script, asked before the built-in adapters: { resource, apply, applyPlayer, creator, fetch } export names.
function appearance.useHook(def)
    hook = shared.hookOf(def)
    if hook then appearance.id = hook.resource end
    return hook ~= nil
end

-- Dresses any ped, local preview peds included, by the format the skin was stored in.
function appearance.apply(ped, data)
    if type(data) ~= 'table' or not DoesEntityExist(ped) then return false end
    local ok, done = shared.callHook(hook, 'apply', ped, data)
    if ok and done then return true end
    if type(data.skin) ~= 'table' then return false end
    for _, id in ipairs(BY_FORMAT[data.format or shared.format(data.skin)] or {}) do
        if running(id) and adapterOf(id).apply(ped, data.skin) then return true end
    end
    return native.apply(ped, data)
end

-- Dresses the player through the running script when it stored this format, otherwise with natives.
function appearance.applyPlayer(data)
    if type(data) ~= 'table' then return false end
    local ok, done = shared.callHook(hook, 'applyPlayer', data)
    if ok and done then return true end
    if type(data.skin) ~= 'table' then return false end
    local adapter = adapterOf(script)
    local format = data.format or shared.format(data.skin)
    if FORMAT_OF[script] == format and running(script) and adapter.applyPlayer(data) then return true end
    return native.applyPlayer(data)
end

function appearance.defaultPed(gender)
    gender = gender == 'f' and 'f' or 'm'
    return { model = joaat(shared.FREEMODE[gender]), skin = shared.defaults(gender), format = 'illenium' }
end

-- Asks the server up to three times, five seconds apart, whether the clothing reached the database.
local function confirmSaved(session)
    for try = 1, 3 do
        Wait(try == 1 and 500 or 5000)
        if session.cancelled then return false end
        if lib.callback.await(DL.resource .. ':appearance:saved', false) == true then return true end
    end
    return false
end

-- finish(result) ends the creator once: an appearance to save, true when the script saved, false when cancelled.
local function newSession(opts)
    local session = { open = true, opts = type(opts) == 'table' and opts or {}, done = promise.new() }
    function session.finish(result)
        if not session.open then return end
        session.open = false
        session.done:resolve(result)
    end
    return session
end

-- Blocks until the new character's clothing is saved: true, or false with 'unsaved' | 'cancelled' | 'unsupported'.
function appearance.openCreator(gender, opts)
    appearance.cancel()
    gender = gender == 'f' and 'f' or 'm'
    local session = newSession(opts)
    local adapter = adapterOf(script)
    current = session
    if hook and hook.creator and GetResourceState(hook.resource) == 'started' then
        CreateThread(function()
            local ok, saved = shared.callHook(hook, 'creator', gender, session.opts)
            session.finish(ok and saved ~= false)
        end)
    elseif not (running(script) and adapter.creator and adapter.creator(gender, session)) then
        current = nil
        return false, 'unsupported'
    end
    local result = Citizen.Await(session.done)
    if type(result) == 'table' and adapter.save and not session.cancelled then adapter.save(result) end
    local saved = result ~= false and not session.cancelled and confirmSaved(session)
    if current == session then current = nil end
    if saved then return true end
    return false, (session.cancelled or result == false) and 'cancelled' or 'unsaved'
end

-- Releases a waiting openCreator; none of the supported scripts can close its menu from outside.
function appearance.cancel()
    local session = current
    current = nil
    if not session then return end
    session.cancelled = true
    session.finish(false)
end

-- Relog hygiene: the clothing script forgets the last character's tattoos and outfit cache.
function appearance.reset()
    local fw = DL.fw.id
    if fw == 'qb' or fw == 'qbx' then TriggerEvent('qb-multicharacter:client:chooseChar')
    elseif fw == 'esx' then TriggerEvent('esx_skin:resetFirstSpawn') end
end

-- A clothing script that stops mid-creator never answers; release the wait.
AddEventHandler('onResourceStop', function(resource)
    if current and (resource == shared.resourceOf(script) or (hook and resource == hook.resource)) then appearance.cancel() end
end)

return appearance
