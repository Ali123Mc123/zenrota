-- Camp pieces near the player as local props with their targets; the list and every change come from the server.
local defs = Config.Pieces
Client = { pieces = {}, objects = {}, me = nil }

function Client.t(key, ...) return DL.locale.t(key, ...) end

function Client.notify(key, kind, ...)
    lib.notify({ description = DL.locale.t(key, ...), type = kind or 'inform' })
end

-- The model to draw for a state: the pack's, or its GTA stand-in when the pack is not installed.
function Client.model(def, state)
    local pack, fallback = Camp.modelOf(def, state)
    for _, name in ipairs({ pack or '', fallback or '' }) do
        if name ~= '' and IsModelInCdimage(joaat(name)) then return joaat(name) end
    end
end

function Client.load(hash)
    return hash and pcall(lib.requestModel, hash, 5000) and HasModelLoaded(hash)
end

function Client.act(id, action, extra)
    local data = extra or {}
    data.id, data.action = id, action
    return lib.callback.await('daddy_camp:act', false, data)
end

-- A short kneeling animation with a bar; false when the player cancelled it.
function Client.work(label, ms, anim)
    return lib.progressBar({
        duration = ms, label = DL.locale.t(label), useWhileDead = false, canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = anim or { dict = 'amb@medic@standing@kneel@base', clip = 'base' },
    })
end

local function despawn(id)
    local o = Client.objects[id]
    if not o then return end
    DL.target.remove('camp_' .. id)
    Effects.stop(id)
    if DoesEntityExist(o.entity) then DeleteEntity(o.entity) end
    Client.objects[id] = nil
end

local function spawn(p)
    local def = defs[p.key]
    local hash = def and Client.model(def, p.state)
    if not Client.load(hash) then return end
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local entity = CreateObjectNoOffset(hash, p.x, p.y, p.z, false, false, false)
    SetEntityHeading(entity, p.h + 0.0)
    FreezeEntityPosition(entity, true)
    SetModelAsNoLongerNeeded(hash)
    Client.objects[p.id] = { entity = entity, state = p.state, hash = hash }
    DL.target.addEntity('camp_' .. p.id, entity, { distance = 2.5, options = Options.of(p.id) })
    Effects.start(p, entity)
end

-- A state or data change: a new model redraws the prop, the same one only its effects.
local function refresh(p)
    local o = Client.objects[p.id]
    if not o then return end
    local hash = Client.model(defs[p.key], p.state)
    if hash ~= o.hash then return despawn(p.id), spawn(p) end
    o.state = p.state
    Effects.stop(p.id)
    Effects.start(p, o.entity)
end

RegisterNetEvent('daddy_camp:set', function(p)
    Client.pieces[p.id] = p
    refresh(p)
end)

RegisterNetEvent('daddy_camp:remove', function(id)
    Client.pieces[id] = nil
    despawn(id)
end)

-- The server sends the pieces of the cells around the player; what is not in the list any more goes.
local function area(all)
    if not all then return end
    local fresh = {}
    for _, p in ipairs(all.pieces or {}) do fresh[p.id] = p end
    local old = Client.pieces
    for id in pairs(old) do
        if not fresh[id] then despawn(id) end
    end
    Client.pieces, Client.me = fresh, all.me
    for id, p in pairs(fresh) do
        local was = old[id]
        if was and (was.state ~= p.state or json.encode(was.data) ~= json.encode(p.data)) then refresh(p) end
    end
end

local function reload()
    for id in pairs(Client.objects) do despawn(id) end
    Client.pieces = {}
    area(lib.callback.await('daddy_camp:all', false))
end

RegisterNetEvent('daddy_camp:reload', reload)
RegisterNetEvent('daddy_camp:area', area)

-- Streams the pieces in and out by distance: big ones from further away.
CreateThread(function()
    Wait(1500)
    reload()
    local big, small = Config.Stream.Big ^ 2, Config.Stream.Small ^ 2
    while true do
        local me = GetEntityCoords(PlayerPedId())
        for id, p in pairs(Client.pieces) do
            local def = defs[p.key]
            local near = (p.x - me.x) ^ 2 + (p.y - me.y) ^ 2 < (def and def.big and big or small)
            local o = Client.objects[id]
            -- deleted by something other than this script (another resource or an anticheat): say so and put it back
            if o and near and not DoesEntityExist(o.entity) then
                print(('^1[daddy_camp] piece #%d (%s) was deleted by another resource, putting it back^0'):format(id, p.key))
                despawn(id)
                o = nil
            end
            if near and not o then spawn(p) elseif not near and o then despawn(id) end
        end
        Wait(1000)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= DL.resource then return end
    for id in pairs(Client.objects) do despawn(id) end
end)
