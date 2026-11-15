-- Stations in the world (lab benches, first aid stations): the body and one dressing prop while nobody plays; while
-- someone plays, the work props and effects every player near sees, built from the server's scene. Everything stands
-- on the station's own model (its top and front edge) and sits there by its own box, so it rests right on any bench or
-- mat. The player plays with the mouse on a page that owns it (views/practicals) while a camera looks at the station;
-- every step is decided on the server.
if Config.Modules.practicals == false or not Config.Practicals then return end

local cfg = Config.Practicals
local Frame = PracticalFrame
local t = DL.locale.t
local PC = { cfg = cfg, games = {}, views = {} }
Core.PracticalClient = PC

local KINDS = { lab_bench = 'lab_mix', first_aid_station = 'cpr' }

function PC.call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:practicals:' .. name, false, data or {}))
end

function PC.hasProps() return GetResourceState(cfg.PropsResource or '') == 'started' end

-- The first model of these the game has (custom first, then the fallback).
function PC.model(...)
    for _, name in ipairs({ ... }) do
        if name and name ~= '' and IsModelInCdimage(joaat(name)) then return name end
    end
end

-- Frames ----------------------------------------------------------------------------------------------------------
-- A frame is an origin and a heading; points are given in it (x right, y forward, z up) and turned with it
-- (shared/practicals_frame.lua).

function PC.point(frame, v) return vector3(Frame.point(frame, v)) end

-- The station's frame: from the surface the editor saved with it (section 3), else from its body's model (its box, or
-- the config's record for the model). top: the middle of the work surface, floor: under it, rect: the usable top
-- from the middle, front: the student's edge. dz moves it all up or down (the floor the runtime check found).
function PC.measure(view, dz)
    local surface = view.surface
    if not surface then
        local body = view.body
        local min, max = GetModelDimensions(GetEntityModel(body))
        surface = Frame.bodySurface(GetEntityCoords(body), GetEntityHeading(body), min, max, (cfg.Models or {})[view.model])
    end
    local frame = Frame.fromSurface(surface)
    frame.top.z, frame.floor.z = frame.top.z + (dz or 0.0), frame.floor.z + (dz or 0.0)
    frame.size = vector3(frame.rect.x1 - frame.rect.x0, frame.rect.y1 - frame.rect.y0, frame.top.z - frame.floor.z)
    view.frame = frame
end

-- On the station's top: x right, y forward from the middle, z above the surface.
function PC.on(view, v) return PC.point(view.frame.top, v) end

-- On the floor in front of it: x from the middle, y further out than the front edge.
function PC.stand(view, v)
    return PC.point(view.frame.floor, vector3(v.x, view.frame.front - v.y, 0.0))
end

function PC.heading(view, extra) return (view.frame.h + (extra or 0.0)) % 360.0 end

-- Objects -----------------------------------------------------------------------------------------------------------

-- A model's box (GetModelDimensions), kept once known; the model is loaded for it when it is not.
local boxes = {}
function PC.box(model)
    local hash = type(model) == 'number' and model or joaat(model)
    local box = boxes[hash]
    if box then return box[1], box[2] end
    local loaded = HasModelLoaded(hash)
    if not loaded and not pcall(lib.requestModel, hash, 3000) then return vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0) end
    local min, max = GetModelDimensions(hash)
    if not loaded then SetModelAsNoLongerNeeded(hash) end
    if max.z > min.z then boxes[hash] = { min, max } end
    return min, max
end

-- Where a model's origin goes so it sits on a spot (pivot = true: its own pivot goes on the spot).
function PC.seat(model, at, heading, pivot)
    if pivot then return at end
    local min, max = PC.box(model)
    return vector3(Frame.seat(at, heading, min, max))
end

-- A local object (nobody else's), kept in the view under a name, sitting on its spot (or hung on its pivot).
function PC.object(view, name, model, at, heading, pivot)
    PC.remove(view, name)
    if not model or not pcall(lib.requestModel, model, 3000) then return nil end
    local hash = joaat(model)
    heading = heading or PC.heading(view)
    local origin = PC.seat(hash, at, heading, pivot)
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local entity = CreateObjectNoOffset(hash, origin.x, origin.y, origin.z, false, false, false)
    SetModelAsNoLongerNeeded(hash)
    if not DoesEntityExist(entity) then return nil end
    SetEntityRotation(entity, 0.0, 0.0, heading, 2, true)
    SetEntityCollision(entity, false, false)
    FreezeEntityPosition(entity, true)
    view.objects[name] = entity
    return entity
end

-- Sets an object down on a spot again, by the same rule it was made with.
function PC.put(entity, at, heading)
    local origin = PC.seat(GetEntityModel(entity), at, heading)
    SetEntityCoordsNoOffset(entity, origin.x, origin.y, origin.z, false, false, false)
    SetEntityRotation(entity, 0.0, 0.0, heading, 2, true)
end

function PC.remove(view, name)
    local entity = view.objects[name]
    if entity and DoesEntityExist(entity) then DeleteEntity(entity) end
    view.objects[name] = nil
end

-- A particle at a point, kept for def.ms (none: until stopped by its name; one-time ones go by their effect's name).
-- Every effect starts through the looped call, so one that loops and one that plays once both play and hand back a
-- handle; def.fallback is tried when the first does not start. tint: { r, g, b }.
function PC.fx(view, def, at, name, tint)
    if not def then return end
    if not HasNamedPtfxAssetLoaded(def.asset) then
        RequestNamedPtfxAsset(def.asset)
        local untilMs = GetGameTimer() + 2000
        while not HasNamedPtfxAssetLoaded(def.asset) and GetGameTimer() < untilMs do Wait(0) end
    end
    name = name or def.name
    PC.stopFx(view, name)
    local handle = 0
    for _, effect in ipairs({ def.name, def.fallback }) do
        if handle == 0 then
            UseParticleFxAsset(def.asset)
            handle = StartParticleFxLoopedAtCoord(effect, at.x, at.y, at.z, 0.0, 0.0, 0.0, def.scale or 1.0, false, false, false, false)
        end
    end
    if handle == 0 then
        -- a one-time effect the looped call would not take still plays once
        UseParticleFxAsset(def.asset)
        StartParticleFxNonLoopedAtCoord(def.name, at.x, at.y, at.z, 0.0, 0.0, 0.0, def.scale or 1.0, false, false, false)
        return
    end
    if tint then SetParticleFxLoopedColour(handle, tint[1], tint[2], tint[3], false) end
    view.fx[name] = handle
    PC.keepFx(view, name, def)
    if def.ms then
        SetTimeout(def.ms, function()
            if view.fx[name] == handle then PC.stopFx(view, name) end
        end)
    end
end

function PC.stopFx(view, name)
    local handle = view.fx[name]
    if handle then StopParticleFxLooped(handle, false) end
    view.fx[name] = nil
end

-- At most Loops looping effects per station at once (the oldest other one stops; a timed burst does not count); the
-- asset is noted to let it go.
function PC.keepFx(view, name, def)
    view.fxAt, view.fxLoop = view.fxAt or {}, view.fxLoop or {}
    view.fxAt[name], view.fxLoop[name] = GetGameTimer(), not def.ms
    if def.asset and def.asset ~= 'core' then
        view.assets = view.assets or {}
        view.assets[def.asset] = true
    end
    if def.ms then return end
    local live, oldest = 0, nil
    for other in pairs(view.fx) do
        if view.fxLoop[other] then
            live = live + 1
            if other ~= name and (not oldest or view.fxAt[other] < view.fxAt[oldest]) then oldest = other end
        end
    end
    if live > ((cfg.Kinds[view.kind] or {}).Loops or 2) and oldest then PC.stopFx(view, oldest) end
end

-- The effect assets a station asked for besides core, let go once no built station uses them (section 7.1).
function PC.releaseFx(view)
    for asset in pairs(view.assets or {}) do
        local used = false
        for _, other in pairs(PC.views) do
            if other ~= view and other.built and other.assets and other.assets[asset] then used = true end
        end
        if not used then RemoveNamedPtfxAsset(asset) end
    end
    view.assets = nil
end

-- The ped of the player at the station (nil when out of reach).
function PC.userPed(scene)
    local player = scene and scene.user and GetPlayerFromServerId(scene.user)
    if not player or player == -1 then return nil end
    local ped = GetPlayerPed(player)
    return ped ~= 0 and ped or nil
end

-- Is this view the one the local player plays at.
function PC.mine(view) return PC.playing ~= nil and PC.playing.uid == view.uid end

-- The local player's station by its scene too (the scene can come before the start's answer).
function PC.own(view) return PC.mine(view) or (view.scene ~= nil and view.scene.user == cache.serverId) end

-- How a model is held (Config.Practicals.Hold by model name, default for the rest).
local holds
function PC.holdOf(model)
    if not holds then
        holds = {}
        for name, hold in pairs(cfg.Hold or {}) do holds[joaat(name)] = hold end
    end
    return holds[type(model) == 'string' and joaat(model) or model] or (cfg.Hold or {}).default
end

-- A prop in a ped's hand by its model's hold (or the hold given), pinned the way Core.Hold pins (section 5.1).
function PC.attach(entity, ped, hand)
    hand = hand or PC.holdOf(GetEntityModel(entity))
    FreezeEntityPosition(entity, false)
    AttachEntityToEntity(entity, ped, GetPedBoneIndex(ped, hand.bone), hand.offset.x, hand.offset.y, hand.offset.z,
        hand.rotation.x, hand.rotation.y, hand.rotation.z, true, true, false, true, 1, true)
end

-- A particle on an entity (a bottle's mouth), kept under a name until stopped; tint: { r, g, b }.
function PC.fxOn(view, def, entity, offset, name, tint)
    if not def or not entity or not DoesEntityExist(entity) then return end
    if not HasNamedPtfxAssetLoaded(def.asset) then
        RequestNamedPtfxAsset(def.asset)
        local untilMs = GetGameTimer() + 2000
        while not HasNamedPtfxAssetLoaded(def.asset) and GetGameTimer() < untilMs do Wait(0) end
    end
    PC.stopFx(view, name)
    UseParticleFxAsset(def.asset)
    local handle = StartParticleFxLoopedOnEntity(def.name, entity, offset.x, offset.y, offset.z, 0.0, 0.0, 0.0, def.scale or 1.0, false, false, false)
    if handle == 0 then return end
    if tint then SetParticleFxLoopedColour(handle, tint[1], tint[2], tint[3], false) end
    view.fx[name] = handle
    PC.keepFx(view, name, def)
end

-- One of the game's own sounds at a point (Config.Practicals.Sounds).
function PC.sound(name, at)
    local s = (cfg.Sounds or {})[name]
    if s and at then PlaySoundFromCoord(-1, s.name, at.x, at.y, at.z, s.set, false, 0, false) end
end

-- Runs fn after ms unless the view was taken down meanwhile (a clip's contact phase on every client).
function PC.later(view, ms, fn)
    local built = view.builtAt
    SetTimeout(math.max(0, math.floor(ms)), function()
        if not view.gone and view.built and view.builtAt == built then fn() end
    end)
end

-- Clips -------------------------------------------------------------------------------------------------------------
-- def: { dict, female?, clip, loop?, flag?, ms?, scene? }; flag 48 plays on the upper body only, over whatever the ped
-- plays (49 looped); scene = true plays at the ped's clip origin (PC.origins[ped]) with TaskPlayAnimAdvanced.

PC.origins = {}

local function dictOf(def, ped) return (not IsPedMale(ped) and def.female) or def.dict end

-- The phase (0-1) a ped plays a clip at, nil when it does not play it.
function PC.phase(ped, def)
    local dict = dictOf(def, ped)
    if not IsEntityPlayingAnim(ped, dict, def.clip, 3) then return nil end
    return GetEntityAnimCurrentTime(ped, dict, def.clip)
end

-- Holds a clip where it is (speed 0) or lets it go on (1); on this client only (G2: others see it play through).
function PC.animSpeed(ped, def, speed) SetEntityAnimSpeed(ped, dictOf(def, ped), def.clip, speed) end

-- How long a clip lasts (ms), 1 s when the game does not say.
function PC.clipMs(def, ped)
    local dict = dictOf(def, ped or cache.ped)
    if not HasAnimDictLoaded(dict) then pcall(lib.requestAnimDict, dict, 2000) end
    local seconds = GetAnimDuration(dict, def.clip)
    return (seconds and seconds > 0 and seconds or 1.0) * 1000
end

-- A clip on the player's own ped (the female dict for female peds when there is one).
function PC.anim(def, loop)
    if not def then return end
    local dict = dictOf(def, cache.ped)
    if not pcall(lib.requestAnimDict, dict, 2000) then return end
    TaskPlayAnim(cache.ped, dict, def.clip, 6.0, -6.0, def.ms or -1, def.flag or ((loop or def.loop) and 1 or 0), 0.0, false, false, false)
end

function PC.stopAnim(def)
    if def then StopAnimTask(cache.ped, dictOf(def, cache.ped), def.clip, 2.0) end
end

-- Clips one after another as one task, so a transition never ends standing (a looped one stays to the end). An entry
-- is a clip def or { def = def, from = phase } (where it starts: a compression on its way down).
function PC.sequence(ped, ...)
    local clips = { ... }
    for i, entry in ipairs(clips) do
        if not entry.def then clips[i] = { def = entry } end
        if not pcall(lib.requestAnimDict, dictOf(clips[i].def, ped), 2000) then return end
    end
    local origin = PC.origins[ped]
    local sequence = OpenSequenceTask()
    for _, entry in ipairs(clips) do
        local def, flag = entry.def, entry.def.loop and 1 or 0
        if def.scene and origin then
            TaskPlayAnimAdvanced(0, dictOf(def, ped), def.clip, origin.x, origin.y, origin.z, 0.0, 0.0, origin.h, 8.0, -8.0, -1, flag, entry.from or 0.0, 0, 0)
        else
            TaskPlayAnim(0, dictOf(def, ped), def.clip, 8.0, -8.0, -1, flag, entry.from or 0.0, false, false, false)
        end
    end
    CloseSequenceTask(sequence)
    TaskPerformSequence(ped, sequence)
    ClearSequenceTask(sequence)
end

-- Views ---------------------------------------------------------------------------------------------------------

local function viewOf(uid)
    local view = PC.views[uid]
    if not view then
        view = { uid = uid, objects = {}, fx = {}, rev = -1, built = false, queue = {} }
        PC.views[uid] = view
    end
    return view
end

-- Takes the work props away (the body stays with its anchor).
local function unbuild(view)
    local game = PC.games[view.game]
    if game and game.clear then pcall(game.clear, view) end
    for name in pairs(view.fx) do PC.stopFx(view, name) end
    for name in pairs(view.objects) do
        if name ~= 'idle' then PC.remove(view, name) end
    end
    view.built, view.game = false, nil
    PC.releaseFx(view)
    if view.ped then PC.origins[view.ped] = nil end
    view.ped = nil
end

-- The safety goggles on the student's head while their game runs, on every client that builds the station.
local function goggles(view, scene)
    local ped = scene.state == 'active' and PC.userPed(scene) or nil
    local entity = view.objects.goggles
    if entity and (not ped or not IsEntityAttachedToEntity(entity, ped)) then
        PC.remove(view, 'goggles')
        entity = nil
    end
    local model = ped and not entity and cfg.Goggles and PC.model(cfg.Goggles)
    if not model then return end
    entity = PC.object(view, 'goggles', model, GetEntityCoords(ped), 0.0, true)
    if entity then PC.attach(entity, ped) end
end

-- The one dressing prop a station shows while it is not built here.
local function dress(view)
    local idle = cfg.Kinds[view.kind].Idle
    if idle and not view.objects.idle then PC.object(view, 'idle', PC.model(idle.model), PC.on(view, idle.on)) end
end

local function activeCount()
    local n = 0
    for _, view in pairs(PC.views) do if view.built then n = n + 1 end end
    return n
end

-- A scene from the server: build the work props once (the player's own station always, another while there is room),
-- then follow it.
local function show(view, scene, event)
    if view.gone then return end
    view.scene = scene
    if not view.frame then return end
    if scene.state == 'idle' then
        unbuild(view)
        dress(view)
        return
    end
    local game = PC.games[scene.game]
    if not game then return end
    if not view.built then
        if not PC.own(view) and activeCount() >= cfg.Limits.ActiveStationsPerClient then
            dress(view)
            return
        end
        view.built, view.game, view.builtAt = true, scene.game, GetGameTimer()
        PC.remove(view, 'idle')
        game.build(view, scene)
    end
    view.ped = PC.userPed(scene)
    game.apply(view, scene, event or {})
    goggles(view, scene)
    -- what everyone near sees and hears of it: the liquid, reactions, the trainer's light (client/practicals/look.lua)
    local look = PC.looks and PC.looks[scene.game]
    if look then look(view, scene, event or {}) end
end

-- The props again from the frame (the runtime check moved it).
local function rebuild(view)
    if view.built and view.scene then
        unbuild(view)
        show(view, view.scene)
    elseif view.objects.idle then
        PC.remove(view, 'idle')
        dress(view)
    end
end

-- A station's scene changes run one after another on one thread (a build waits for its models before the next).
local function enqueue(view, job)
    view.queue[#view.queue + 1] = job
    if view.busy then return end
    view.busy = true
    CreateThread(function()
        while #view.queue > 0 do
            local ok, err = pcall(table.remove(view.queue, 1))
            if not ok then print(('^1[daddy_college] practical scene: %s^7'):format(err)) end
        end
        view.busy = false
    end)
end

-- Scene events this client got and the largest one in bytes (debug only: /pqa net reads them).
PC.net = { events = 0, bytes = 0 }
local function counted(...)
    if Config.Debug ~= true then return end
    PC.net.events, PC.net.bytes = PC.net.events + 1, math.max(PC.net.bytes, #msgpack.pack({ ... }))
end

-- A whole scene: a start, an idle, or the answer to asking for it.
RegisterNetEvent('daddy_college:practicals:scene', function(uid, rev, scene, event)
    counted(uid, rev, scene, event)
    local view = viewOf(uid)
    if type(rev) ~= 'number' or type(scene) ~= 'table' or rev <= view.rev then return end
    view.rev, view.latest = rev, scene
    enqueue(view, function() show(view, scene, event) end)
end)

-- The whole scene again from the server (the station came into view, or a change was missed).
local function resync(view)
    if view.asking then return end
    view.asking = true
    CreateThread(function()
        local result = PC.call('scene', { uid = view.uid })
        view.asking = false
        if result.ok and result.data.rev >= view.rev then
            view.rev, view.latest = result.data.rev, result.data.scene
            enqueue(view, function() show(view, result.data.scene) end)
        end
    end)
end

-- Only what changed since the last change (section 8.2), laid over the scene this client has; a gap in the numbers
-- asks for the whole scene (a station not in view yet asks when its body comes).
RegisterNetEvent('daddy_college:practicals:diff', function(uid, rev, diff, event)
    counted(uid, rev, diff, event)
    local view = viewOf(uid)
    if type(rev) ~= 'number' or type(diff) ~= 'table' or rev <= view.rev then return end
    if rev ~= view.rev + 1 or not view.latest then
        if view.body or view.frame then resync(view) end -- a map table's station has no body
        return
    end
    local scene = {}
    for k, v in pairs(view.latest) do scene[k] = v end
    for k, v in pairs(diff) do scene[k] = v end
    view.rev, view.latest = rev, scene
    enqueue(view, function() show(view, scene, event) end)
end)

-- One async ray straight down (a frame or two): where it meets the map or an object, nil when it does not.
local function rayDown(x, y, z0, z1, ignore)
    local probe = StartShapeTestLosProbe(x, y, z0, x, y, z1, 1 | 16, ignore or 0, 4)
    local status, hit, at = 1, 0, nil
    local untilMs = GetGameTimer() + 1000
    repeat
        Wait(0)
        status, hit, at = GetShapeTestResult(probe)
    until status ~= 1 or GetGameTimer() > untilMs
    return hit == 1 and at or nil
end

-- The saved surface checked once per spawn, when the player is near with collision loaded (section 3.3.4): a body's
-- floor under its corners, a map table at its middle and corners, one ray a frame. A body whose floor moved sits on
-- the floor found (every client measures the same map); a map table that moved marks the station broken here.
local function validate(view)
    local surface, v = view.surface, cfg.Validate or {}
    if not surface or view.checking then return end
    view.checking = true
    CreateThread(function()
        while not view.gone and view.frame do
            local top = view.frame.top
            if #(GetEntityCoords(cache.ped) - vector3(top.x, top.y, top.z)) <= (v.Distance or 12.0) and HasCollisionLoadedAroundEntity(cache.ped) then break end
            Wait(1000)
        end
        if view.gone or not view.frame then return end
        local tolerance, h = v.Tolerance or 0.02, surface.heading
        if surface.mode == 'map' then
            local r = surface.rect
            for _, p in ipairs({ { 0.0, 0.0 }, { r.x0 + 0.02, r.y0 + 0.02 }, { r.x1 - 0.02, r.y0 + 0.02 }, { r.x1 - 0.02, r.y1 - 0.02 }, { r.x0 + 0.02, r.y1 - 0.02 } }) do
                local x, y = Frame.turn(h, p[1], p[2])
                local at = rayDown(surface.at.x + x, surface.at.y + y, surface.top + 0.1, surface.top - 0.3)
                if not at or math.abs(at.z - surface.top) > tolerance then
                    view.bad = true
                    return
                end
            end
            return
        end
        local body = view.body
        if not body or not DoesEntityExist(body) then return end
        local c = GetEntityCoords(body)
        local min, max = GetModelDimensions(GetEntityModel(body))
        local highest
        for _, p in ipairs({ { min.x, min.y }, { max.x, min.y }, { max.x, max.y }, { min.x, max.y } }) do
            local x, y = Frame.turn(GetEntityHeading(body), p[1], p[2])
            local at = rayDown(c.x + x, c.y + y, c.z + min.z + 0.3, c.z + min.z - 0.5, body)
            if at and (not highest or at.z > highest) then highest = at.z end
        end
        local dz = highest and highest - (c.z + min.z) or 0.0
        if math.abs(dz) <= tolerance then return end
        SetEntityCoordsNoOffset(body, c.x, c.y, c.z + dz, false, false, false)
        view.dz = (view.dz or 0.0) + dz
        PC.measure(view, view.dz)
        enqueue(view, function() rebuild(view) end)
    end)
end

-- Anchors: a station's body near the player (where the editor saved it; none on a map table, whose target is a box
-- over the table), its dressing prop, and the start option.
local function sync()
    local defs = {}
    for kind in pairs(KINDS) do
        local def = cfg.Kinds[kind]
        for _, spot in ipairs(Core.World.entities({ kind = kind })) do
            local uid = spot.uid
            local model = (spot.model or '') ~= '' and spot.model or def.Model
            local surface = type(spot.settings) == 'table' and type(spot.settings.surface) == 'table' and spot.settings.surface or nil
            local onMap = surface ~= nil and surface.mode == 'map'
            local shape, sphere
            if onMap then
                local r = surface.rect
                local cx, cy = Frame.turn(surface.heading, (r.x0 + r.x1) / 2, (r.y0 + r.y1) / 2)
                shape = { shape = 'box', center = { x = surface.at.x + cx, y = surface.at.y + cy, z = surface.top + 0.2 },
                    size = { x = r.x1 - r.x0, y = r.y1 - r.y0, z = 0.4 }, rotation = surface.heading }
            elseif kind == 'first_aid_station' then
                sphere = { radius = 0.4, height = 0.25 } -- on the manikin's chest: the mat is too thin to aim at
            end
            defs[#defs + 1] = {
                uid = 'practical:' .. uid, label = spot.label, coords = spot.coords, revision = spot.revision, presentation = onMap and 'point' or 'prop',
                model = not onMap and model or nil, distance = cfg.Reach, exact = true, shape = shape, targetSphere = sphere,
                onSpawn = function(_, entity)
                    if not entity and not onMap then return end
                    local view = viewOf(uid)
                    view.kind, view.label, view.body, view.model, view.surface = kind, spot.label, entity, model, surface
                    view.dz, view.bad, view.checking = 0.0, false, false
                    PC.measure(view)
                    validate(view)
                    resync(view)
                end,
                options = { {
                    name = 'practical_start', label = t('practicals.start_' .. kind), icon = kind == 'lab_bench' and 'fa-solid fa-flask' or 'fa-solid fa-heart-pulse',
                    distance = cfg.Reach,
                    canInteract = function() return not PC.playing and not Core.Nui.IsOpen() and not IsPedInAnyVehicle(cache.ped, false) end,
                    onSelect = function()
                        local view = PC.views[uid]
                        if view and view.bad then return Core.NotifyL('practicals.bad_surface', 'error') end
                        CreateThread(function() PC.begin(uid) end)
                    end,
                } },
            }
        end
    end
    Core.World.anchors.sync('practicals', defs)
end

Core.World.subscribe(sync)

-- Built here: the player's own station, then the nearest others, the limit in all; the rest wait dressed.
local function balance()
    local here, rows = GetEntityCoords(cache.ped), {}
    for _, view in pairs(PC.views) do
        local scene = view.scene
        if view.frame and scene and scene.state ~= 'idle' and PC.games[scene.game] then
            local top = view.frame.top
            rows[#rows + 1] = { key = view, own = PC.own(view), d = #(here - vector3(top.x, top.y, top.z)) }
        end
    end
    local keep = Frame.keep(rows, cfg.Limits.ActiveStationsPerClient)
    for _, row in ipairs(rows) do
        local view = row.key
        if view.built and not keep[view] then
            enqueue(view, function() if view.built and not view.gone then unbuild(view) dress(view) end end)
        elseif not view.built and keep[view] then
            enqueue(view, function() if not view.built and view.scene then show(view, view.scene) end end)
        end
    end
end

-- Every second: views whose body went (out of range, removed) lose their props, then the built set is kept right.
CreateThread(function()
    while true do
        Wait(1000)
        local here = GetEntityCoords(cache.ped)
        for uid, view in pairs(PC.views) do
            -- a map table has no body: it is up while the player is within the anchors' stream range
            local top = view.frame and view.frame.top
            local up = view.body and DoesEntityExist(view.body)
                or (not view.body and view.surface and view.surface.mode == 'map' and top and #(here - vector3(top.x, top.y, top.z)) < 100.0)
            if not up and not PC.mine(view) then
                PC.views[uid], view.gone = nil, true
                enqueue(view, function()
                    unbuild(view)
                    PC.remove(view, 'idle')
                end)
            end
        end
        balance()
    end
end)

-- Playing ---------------------------------------------------------------------------------------------------------

-- The camera and its shots are client/practicals/camera.lua (PC.shot, PC.cameraOff).

-- Where a world point is on screen (0-1 across and down), nil when off screen.
function PC.screen(at)
    local ok, x, y = GetScreenCoordFromWorldCoord(at.x, at.y, at.z)
    if not ok then return nil end
    return { x = x, y = y }
end

-- What the page draws over the world: { id, at (world point), label?, cap?, kind } -> screen marks. The list is kept
-- so a moving camera can draw them again (PC.reproject).
function PC.marks(list)
    local out = {}
    for _, m in ipairs(list) do
        local p = PC.screen(m.at)
        if p then out[#out + 1] = { id = m.id, x = p.x, y = p.y, r = m.r or 0.045, label = m.label, cap = m.cap, kind = m.kind, state = m.state } end
    end
    Core.Nui.Send('practicals:marks', { marks = out })
    PC.markList, PC.shown = list, out
    return out
end

function PC.reproject() if PC.playing and PC.markList then PC.marks(PC.markList) end end

-- The nearest mark to a screen point within its radius (screen heights), among the marks on the page now.
function PC.markAt(marks, x, y)
    local best, bestD
    local aspect = GetAspectRatio(false)
    for _, m in ipairs(PC.shown or marks or {}) do
        local dx, dy = (m.x - x) * aspect, m.y - y
        local d = math.sqrt(dx * dx + dy * dy)
        if d <= m.r and (not bestD or d < bestD) then best, bestD = m, d end
    end
    return best
end

-- Where the pointer's ray meets a level plane at height z (world), or nil.
function PC.onPlane(z)
    local from, dir = World.cursor.ray()
    if math.abs(dir.z) < 0.0001 then return nil end
    local k = (z - from.z) / dir.z
    if k <= 0 then return nil end
    return from + dir * k
end

-- The page's events: pointer moves and presses (x, y from 0 to 1), keys, picks and leaving.
local inbox = {}
RegisterNUICallback('practicals:input', function(e, cb)
    cb({ ok = PC.playing ~= nil })
    if not PC.playing or type(e) ~= 'table' then return end
    if e.x and e.y then World.cursor.use(tonumber(e.x) or 0, tonumber(e.y) or 0) end
    e.at = GetGameTimer()
    inbox[#inbox + 1] = e
end)

-- The events since the last frame, oldest first.
function PC.events()
    local list = inbox
    inbox = {}
    return list
end

-- What the page shows besides the marks (progress, gauges, the last step's result); the camera follows it too.
function PC.state(data)
    Core.Nui.Send('practicals:state', data)
    if PC.direct then PC.direct(data) end
end

-- Errors a step may get that the player need not read (a copy that came twice, the game already over).
local QUIET = { practical_done = true, practical_stale = true }

-- A step goes at once (in order, numbered so the server drops a copy); cb gets what the server decided, or nil and why.
function PC.send(op, data, cb)
    local mine = PC.playing
    if not mine then return end
    data = data or {}
    mine.seq = (mine.seq or 0) + 1
    data.uid, data.op, data.seq = mine.uid, op, mine.seq
    lib.callback('daddy_college:practicals:step', false, function(result)
        result = Core.NormalizeResult(result)
        if not result.ok then
            if not QUIET[result.error] then Core.HandleResult(result, 'practicals') end
            if cb then cb(nil, result.error) end
            return
        end
        if cb then cb(result.data.out) end
    end, data)
end

-- Walks to a floor point and faces the given heading.
function PC.walkTo(at, heading)
    TaskGoStraightToCoord(cache.ped, at.x, at.y, at.z, 1.0, 4000, heading, 0.2)
    local untilMs = GetGameTimer() + 4500
    while GetGameTimer() < untilMs and #(GetEntityCoords(cache.ped).xy - at.xy) > 0.3 do Wait(100) end
    ClearPedTasks(cache.ped)
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoordsNoOffset(cache.ped, at.x, at.y, GetEntityCoords(cache.ped).z, false, false, false)
    SetEntityHeading(cache.ped, heading)
end

-- The stand or kneel point free of other players and pulled chairs (section 3.3.5): else the nearest free one along
-- the edge (along: a unit vector), at most StandShift away. -> point | nil (taken)
function PC.freeSpot(view, at, along)
    local stand = ((cfg.Survey or {}).Stand or {})[view.kind] or { low = 0.3, high = 1.7, radius = 0.3 }
    local most = cfg.StandShift or 0.3
    for _, shift in ipairs({ 0.0, 0.1, -0.1, 0.2, -0.2, 0.3, -0.3 }) do
        if math.abs(shift) <= most + 1e-6 then
            local p = at + along * shift
            local probe = StartShapeTestCapsule(p.x, p.y, p.z + stand.low, p.x, p.y, p.z + stand.high, stand.radius * 0.8, 4 | 16, view.body or 0, 4)
            local status, hit, _, _, entity = 1, 0, nil, nil, 0
            local untilMs = GetGameTimer() + 500
            repeat
                Wait(0)
                status, hit, _, _, entity = GetShapeTestResult(probe)
            until status ~= 1 or GetGameTimer() > untilMs
            if hit ~= 1 or entity == cache.ped then return p end
        end
    end
end

-- The player leaves the station's pose: the kind's exit clip (up from kneeling), else its clips blend out.
local function rise(def)
    if IsEntityDead(cache.ped) or IsPedInAnyVehicle(cache.ped, false) then return end
    ClearPedSecondaryTask(cache.ped)
    local exit = def and def.Anims and def.Anims.exit
    if exit then return PC.anim(exit) end
    ClearPedTasks(cache.ped)
end

function PC.begin(uid)
    if PC.playing then return end
    local view = PC.views[uid]
    if not view or not view.frame then return end
    local result = PC.call('begin', { uid = uid })
    if not result.ok then return Core.HandleResult(result, 'practicals') end
    local game = PC.games[result.data.game.game]
    if not game then
        PC.call('quit', { uid = uid })
        return
    end
    local def = cfg.Kinds[result.data.kind]
    local mine = { uid = uid, game = result.data.game, purpose = result.data.purpose, def = def, view = view, startedAt = GetGameTimer() }
    PC.playing = mine
    inbox, PC.markList, PC.shown = {}, nil, nil
    Core.Waypoint.clear()
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    local ok, err = pcall(game.play, view, mine)
    if not ok then print(('^1[daddy_college] practical: %s^7'):format(err)) end
    if not mine.over then PC.call('quit', { uid = uid }) end
    if Core.Nui.IsOpen(mine.screen) then Core.Nui.Close() end
    World.cursor.use(nil)
    PC.cameraOff()
    rise(def)
    PC.origins[cache.ped] = nil
    PC.playing = nil
end

-- Opens the station's page (it owns the mouse; Esc leaves).
function PC.open(mine, screen, payload)
    mine.screen = screen
    payload.purpose, payload.label = mine.purpose, mine.view.label
    -- the time left counts from the server's start, not from the page (the walk and the camera came first)
    if payload.seconds then payload.seconds = math.max(0, payload.seconds - (GetGameTimer() - mine.startedAt) / 1000) end
    Core.Nui.Open(screen, payload, { failsafe = false })
    if PC.direct then PC.direct(payload) end
end

-- Leaves the game: the page closed, dying, a vehicle.
function PC.leave(mine)
    if mine.over then return end
    mine.over = true
    PC.call('quit', { uid = mine.uid })
end

Core.Nui.OnClose('practicals.lab', function() if PC.playing then PC.leave(PC.playing) end end)
Core.Nui.OnClose('practicals.cpr', function() if PC.playing then PC.leave(PC.playing) end end)

-- Should the play loop stop now (the server ended it, or the player can no longer play).
function PC.stopped(mine)
    if mine.over then return true end
    if IsEntityDead(cache.ped) or IsPedInAnyVehicle(cache.ped, false) then
        PC.leave(mine)
        return true
    end
    return false
end

RegisterNetEvent('daddy_college:practicals:result', function(data)
    local mine = PC.playing
    if mine and mine.uid == data.uid then
        mine.result = data
        PC.state({ result = data })
        SetTimeout(3500, function() mine.over = true end)
    end
    if data.why == 'timeout' then Core.NotifyL('practicals.time_up', 'error') end
    if data.purpose == 'practice' then
        Core.NotifyL('practicals.done_practice', 'inform', data.score)
    else
        Core.NotifyL('practicals.done_lesson', 'inform', data.score)
    end
end)

RegisterNetEvent('daddy_college:practicals:stop', function(data)
    local mine = PC.playing
    if mine and mine.uid == data.uid then mine.over = true end
    if data.why and data.why ~= 'quit' then Core.NotifyL('practicals.stopped_' .. data.why, 'error') end
end)

-- Someone came near the station while the player plays: the pose's loop starts again so their game sees it (5.8).
RegisterNetEvent('daddy_college:practicals:resync', function(uid)
    local mine = PC.playing
    local game = mine and mine.uid == uid and PC.games[mine.game.game]
    if game and game.resync then game.resync(mine.view, mine) end
end)

-- The station kept for this player (their lesson turn).
RegisterNetEvent('daddy_college:practicals:waypoint', function(data)
    local c = data.coords
    Core.Waypoint.mark(data.label ~= '' and data.label or t('practicals.ui.station'), vector3(c.x, c.y, c.z), 'practical:' .. data.uid, false)
end)

-- Debug ------------------------------------------------------------------------------------------------------------
-- /practicaldebug (Config.Debug): every near station's middle of top, front edge, stand point, layout points and
-- state, drawn in the world and printed to F8 once.

local debugOn = false

local function dot(at, r, g, b, text)
    DrawMarker(28, at.x, at.y, at.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.025, 0.025, 0.025, r, g, b, 220, false, false, 2, false, nil, nil, false)
    if not text then return end
    SetDrawOrigin(at.x, at.y, at.z + 0.04, 0)
    SetTextScale(0.0, 0.22)
    SetTextFont(0)
    SetTextCentre(true)
    SetTextOutline()
    SetTextColour(r, g, b, 255)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

-- The layout's own points for a station (each game knows its layout).
local function debugPoints(view)
    local game = PC.games[KINDS[view.kind]]
    return game and game.points and game.points(view) or {}
end

if Config.Debug == true and cfg.Commands and cfg.Commands.debug then
    RegisterCommand(cfg.Commands.debug, function()
        debugOn = not debugOn
        if not debugOn then return end
        for uid, view in pairs(PC.views) do
            local f = view.frame
            print(('[practicals] %s %s model=%s size=%.2fx%.2fx%.2f top=%.2f state=%s built=%s'):format(uid, view.kind, view.model or '?',
                f and f.size.x or 0, f and f.size.y or 0, f and f.size.z or 0, f and (f.top.z - f.floor.z) or 0, view.scene and view.scene.state or '?',
                tostring(view.built)))
        end
        CreateThread(function()
            while debugOn do
                for _, view in pairs(PC.views) do
                    if view.frame then
                        dot(PC.on(view, vector3(0, 0, 0)), 255, 255, 255, ('%s · %s'):format(view.kind, view.scene and view.scene.state or '?'))
                        dot(PC.point(view.frame.floor, vector3(0, view.frame.front, 0)), 255, 160, 0, 'front')
                        for _, p in ipairs(debugPoints(view)) do dot(p.at, p.r or 80, p.g or 200, p.b or 255, p.name) end
                    end
                end
                Wait(0)
            end
        end)
    end, false)
end

-- A restart mid-game leaves nothing behind: the camera, the station's props and the player's own clip.
AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    PC.cameraOff()
    if PC.playing then
        ClearPedSecondaryTask(cache.ped)
        ClearPedTasks(cache.ped)
    end
    for _, view in pairs(PC.views) do
        unbuild(view)
        PC.remove(view, 'idle')
    end
    Core.World.anchors.clear('practicals')
end)
