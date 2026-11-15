-- Lights in the hand: each player's statebag says what they hold, every client draws it near them with its light.
local defs = Config.Pieces
Hand = { props = {}, fx = {}, tune = {} } -- tune: hand offsets being tried out (client/tune.lua)

-- What each player holds, kept from statebag changes: no player's statebag is read in a loop (with hundreds of players
-- in scope that polling was the resource's idle cost).
local holds = {}
AddStateBagChangeHandler('camp:hold', nil, function(bagName, _, value)
    local id = tonumber(bagName:match('^player:(%d+)$'))
    if id then holds[id] = value end
end)

local function holdOf(serverId)
    return holds[serverId]
end

-- A local prop in a ped's hand; also used for the axe and the roasting stick.
function Hand.attach(ped, key, state)
    local def = defs[key]
    local hash = Client.model(def, state)
    if not Client.load(hash) then return nil end
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local prop = CreateObject(hash, GetEntityCoords(ped), false, false, false)
    local h = Hand.tune[key] or def.hand
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, h.bone), h.pos.x, h.pos.y, h.pos.z, h.rot.x, h.rot.y, h.rot.z, true, true, false, true, 1, true)
    SetEntityCollision(prop, false, false)
    SetModelAsNoLongerNeeded(hash)
    return prop
end

local function drop(serverId)
    local held = Hand.props[serverId]
    if not held then return end
    if Hand.fx[serverId] then StopParticleFxLooped(Hand.fx[serverId], false) end
    if DoesEntityExist(held.prop) then DeleteEntity(held.prop) end
    Hand.props[serverId], Hand.fx[serverId] = nil, nil
end

-- Keeps every near player's held prop in step with their statebag.
CreateThread(function()
    while true do
        local me, seen = GetEntityCoords(PlayerPedId()), {}
        -- only the players who hold something (almost always nobody)
        for id, hold in pairs(holds) do
            local player = GetPlayerFromServerId(id)
            local ped = player ~= -1 and GetPlayerPed(player) or 0
            if ped ~= 0 and defs[hold.key] and #(GetEntityCoords(ped) - me) < 80.0 and not IsPedInAnyVehicle(ped, false) then
                seen[id] = true
                local held = Hand.props[id]
                if not held or held.key ~= hold.key or held.state ~= hold.state or held.ped ~= ped then
                    drop(id)
                    local prop = Hand.attach(ped, hold.key, hold.state)
                    if prop then
                        Hand.props[id] = { prop = prop, key = hold.key, state = hold.state, ped = ped }
                        local look, light, socket = Effects.lookOf({ key = hold.key, state = hold.state })
                        if look then Hand.fx[id] = Effects.particle(look, prop, socket) end
                        Hand.props[id].light, Hand.props[id].socket = light, socket
                    end
                end
            end
        end
        for id in pairs(Hand.props) do if not seen[id] then drop(id) end end
        Wait((next(holds) or next(Hand.props)) and 400 or 1000)
    end
end)

CreateThread(function()
    while true do
        local any = false
        for _, held in pairs(Hand.props) do
            if held.light and DoesEntityExist(held.prop) then
                any = true
                Effects.draw(held.light, held.prop, held.socket, GetEntityForwardVector(held.ped))
            end
        end
        Wait(any and 0 or 300)
    end
end)

local function mine()
    return holdOf(GetPlayerServerId(PlayerId()))
end

-- The arm pose of what I hold (upper body, walking stays free); the game sends it to the others.
-- Paused while a progress bar, the roasting stick or the axe plays its own animation.
CreateThread(function()
    local posed
    while true do
        local ped, hold = PlayerPedId(), mine()
        local def = hold and defs[hold.key]
        local anim = def and def.hand and def.hand.anim
        if posed and posed ~= anim then StopAnimTask(ped, posed.dict, posed.clip, 1.0) posed = nil end
        if anim and not (Cook and Cook.busy) and not lib.progressActive() and not IsPedInAnyVehicle(ped, false) and not IsEntityPlayingAnim(ped, anim.dict, anim.clip, 3) then
            if lib.requestAnimDict(anim.dict, 1000) then
                TaskPlayAnim(ped, anim.dict, anim.clip, 3.0, -3.0, -1, 49, 0, false, false, false)
                RemoveAnimDict(anim.dict)
            end
        end
        posed = anim
        Wait(anim and 500 or 1000)
    end
end)

RegisterCommand('daddy_camp_toggle', function()
    local hold = mine()
    if not hold then return end
    if hold.key == 'torch' and hold.state == 'unlit' and not Client.work('camp.work_light', 2000, { dict = 'anim@mp_player_intmenu@key_fob@', clip = 'fob_click' }) then return end
    lib.callback.await('daddy_camp:toggle', false)
end, false)

-- Sets the held light down in front, or hangs a lantern on a hook close by.
RegisterCommand('daddy_camp_drop', function()
    local hold, ped = mine(), PlayerPedId()
    if not hold or IsPedInAnyVehicle(ped, false) then return end
    local def = defs[hold.key]
    local at, heading = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.6, 0.0), GetEntityHeading(ped)
    local found, ground = GetGroundZFor_3dCoord(at.x, at.y, at.z + 1.0, false)
    if not found then return end
    local pos = vec3(at.x, at.y, ground + (def.rest and def.rest.z or 0.03))
    if hold.key == 'lantern' then
        for id, p in pairs(Client.pieces) do
            local o = Client.objects[id]
            if p.key == 'lantern_hook' and o and #(vec3(p.x, p.y, p.z) - at) < 1.5 then
                pos, heading = GetOffsetFromEntityInWorldCoords(o.entity, defs.lantern_hook.socket.x, defs.lantern_hook.socket.y, defs.lantern_hook.socket.z), p.h
                break
            end
        end
    end
    local problem = Place.ground(pos)
    if problem then return Client.notify('camp.' .. problem, 'error') end
    lib.requestAnimDict('pickup_object')
    TaskPlayAnim(ped, 'pickup_object', 'putdown_low', 8.0, -8.0, 900, 48, 0, false, false, false)
    Wait(700)
    lib.callback.await('daddy_camp:drop', false, { x = pos.x, y = pos.y, z = pos.z, h = heading })
end, false)

RegisterKeyMapping('daddy_camp_toggle', DL.locale.t('camp.key_toggle'), 'keyboard', Config.Keys.Toggle)
RegisterKeyMapping('daddy_camp_drop', DL.locale.t('camp.key_drop'), 'keyboard', Config.Keys.Drop)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= DL.resource then return end
    for id in pairs(Hand.props) do drop(id) end
end)
