-- Musical chairs on the client: the ring of chairs, the music (from the speaker, fading with distance), the walk
-- round the ring while it plays (the game walks you, the keys rest) and sitting down: E sits on the nearest free
-- chair once the music stops. Everyone stands up before chairs go, so nobody is left sitting on air.
local cfg = Config.Chairs
local t = DL.locale.t
local here = { id = nil, chairs = {}, entities = {}, taken = {}, phase = nil, out = {}, venue = nil, sitting = false, walk = 1.8, round = 0 }
local HELD = { 21, 22, 23, 24, 25, 30, 31, 32, 33, 34, 35, 44, 140, 141, 142 } -- walking, sprint, jump, car, attack, cover

-- The chair model: the first of the bottle game's chairs the game has.
local function chairModel()
    for _, chair in ipairs(Config.Bottle.Chairs) do
        if IsModelInCdimage(joaat(chair.model)) then return chair end
    end
end

local function clearChairs()
    for _, entity in ipairs(here.entities) do
        if DoesEntityExist(entity) then DeleteEntity(entity) end
    end
    here.entities = {}
end

local function spawnChairs()
    clearChairs()
    local chair = chairModel()
    if not chair or not pcall(lib.requestModel, joaat(chair.model), 3000) then return end
    for i, c in ipairs(here.chairs) do
        pcall(function() exports['FeloxAC']:CreateObject(joaat(chair.model)) end) --[[FeloxAC:auto]]
        local entity = CreateObjectNoOffset(joaat(chair.model), c.x, c.y, c.z, false, false, false)
        SetEntityHeading(entity, (c.h + 180.0 + chair.heading) % 360)
        FreezeEntityPosition(entity, true)
        here.entities[i] = entity
    end
    SetModelAsNoLongerNeeded(joaat(chair.model))
end

-- Music ------------------------------------------------------------------------------------------------------------

-- Each player's own level for game music (0-1), kept on their PC: /gamesmusic 0-100.
local function myLevel()
    local level = GetResourceKvpFloat('daddy_campusgames:music')
    return GetResourceKvpString('daddy_campusgames:music_set') and level or 1.0
end

-- How loud the music is here: the speaker's level, my own level, and quieter with distance.
local function loudness()
    local v = here.venue
    if not v then return 0.0 end
    local d = #(GetEntityCoords(cache.ped) - vector3(v.x, v.y, v.z))
    local near = math.max(0.0, 1.0 - d / cfg.Hear)
    return cfg.Volume * myLevel() * near * near
end

-- The music for a round (the same track and start for everyone); stopping winds it down like a record.
local function music(on, round)
    if not on then
        here.playingMusic = false
        return SendNUIMessage({ action = 'music', play = false, scratch = true })
    end
    here.playingMusic = true
    local track = round and round.track and cfg.Tracks[round.track] or nil
    SendNUIMessage({ action = 'music', play = true, track = track, offset = round and round.offset or 0, volume = loudness() })
    CreateThread(function()
        local last = -1
        while here.playingMusic and here.id do
            local level = loudness()
            if math.abs(level - last) > 0.02 then
                SendNUIMessage({ action = 'music', volume = level })
                last = level
            end
            Wait(250)
        end
    end)
end

if cfg.VolumeCommand ~= '' then
    RegisterCommand(cfg.VolumeCommand, function(_, args)
        local level = math.max(0, math.min(100, tonumber(args[1]) or 100))
        SetResourceKvpFloat('daddy_campusgames:music', level / 100)
        SetResourceKvp('daddy_campusgames:music_set', '1')
        lib.notify({ description = t('games.music_volume', level) })
    end, false)
    TriggerEvent('chat:addSuggestion', '/' .. cfg.VolumeCommand, t('games.command_music'), { { name = '0-100', help = t('games.command_music') } })
end

-- Walking and sitting ---------------------------------------------------------------------------------------------------

local function groundZ(x, y, z)
    local found, g = GetGroundZFor_3dCoord(x, y, z + 1.0, false)
    return found and g or z
end

local function onPath(angle)
    local v, a = here.venue, math.rad(angle)
    return v.x - math.sin(a) * here.walk, v.y + math.cos(a) * here.walk
end

-- Me and my test bots: each to their start on the walking path, then walked round it until the music stops.
local function walkers(starts)
    local list = {}
    if starts[cache.serverId] and not here.out[cache.serverId] then list[#list + 1] = { ped = cache.ped, angle = starts[cache.serverId] } end
    for id, ped in pairs(Games.myBots()) do
        if starts[id] and not here.out[id] and DoesEntityExist(ped) then list[#list + 1] = { ped = ped, angle = starts[id] } end
    end
    return list
end

local function walk(starts)
    local v, round = here.venue, here.round
    if not v then return end
    local list = walkers(starts)
    for _, w in ipairs(list) do
        local x, y = onPath(w.angle)
        ClearPedTasksImmediately(w.ped)
        SetEntityCoords(w.ped, x, y, groundZ(x, y, v.z), false, false, false, false)
        SetEntityHeading(w.ped, (w.angle + 90.0) % 360)
    end
    local nextStep = 0
    while here.id and here.phase == 'music' and here.round == round do
        if GetGameTimer() >= nextStep then
            nextStep = GetGameTimer() + 400
            for _, w in ipairs(list) do
                if DoesEntityExist(w.ped) then
                    local at = GetEntityCoords(w.ped)
                    local angle = math.deg(math.atan(-(at.x - v.x), at.y - v.y))
                    local x, y = onPath(angle + 35.0)
                    TaskGoStraightToCoord(w.ped, x, y, v.z, cfg.WalkSpeed, -1, 0.0, 0.0)
                end
            end
        end
        if list[1] and list[1].ped == cache.ped then
            for _, control in ipairs(HELD) do DisableControlAction(0, control, true) end
        end
        Wait(0)
    end
    for _, w in ipairs(list) do
        if DoesEntityExist(w.ped) then ClearPedTasks(w.ped) end
    end
end

-- Everyone of mine up from the chairs (me and my bots).
local function standAll()
    if here.sitting then
        here.sitting = false
        ClearPedTasks(cache.ped)
    end
    for id, ped in pairs(Games.myBots()) do
        if DoesEntityExist(ped) and here.seatedBots and here.seatedBots[id] then ClearPedTasks(ped) end
    end
    here.seatedBots = {}
end

-- Sits me (or, ped, one of my test bots) on chair i.
local function sitOn(i, ped)
    local c, chair = here.chairs[i], chairModel() or Config.Bottle.Chairs[1]
    if not c then return end
    local h = math.rad(c.h)
    local x, y = c.x + math.sin(h) * chair.back, c.y - math.cos(h) * chair.back
    TaskStartScenarioAtPosition(ped or cache.ped, Config.Bottle.SitScenario, x, y, c.z + chair.seat, c.h, 0, true, true)
    if not ped then here.sitting = true end
end

local function nearestFree()
    local me, best, bestD = GetEntityCoords(cache.ped), nil, cfg.Reach
    for i, c in ipairs(here.chairs) do
        local d = #(vector2(me.x, me.y) - vector2(c.x, c.y))
        if not here.taken[i] and d <= bestD then best, bestD = i, d end
    end
    return best
end

local function bar(scene)
    local alive = 0
    for _, p in ipairs(scene.public and scene.public.players or {}) do
        if not here.out[p.id] then alive = alive + 1 end
    end
    local s = scene.public and scene.public.scene or {}
    Games.overlay('games.scorebar', { game = 'party', title = t('games.game_chairs'), items = {
        { label = t('chairs.round'), value = tostring(s.round or 0) }, { label = t('chairs.left'), value = tostring(alive) } } })
end

local function playLoop()
    if here.playing then return end
    here.playing = true
    local shown
    while here.id and Games.lobby and Games.lobby.id == here.id do
        local me = cache.serverId
        local text
        if here.out[me] then text = t('chairs.you_out')
        elseif here.sitting then text = t('chairs.seated')
        elseif here.phase == 'sit' then text = t('chairs.sit_key')
        elseif here.phase == 'music' then text = t('chairs.walk')
        else text = t('chairs.wait') end
        if shown ~= text then lib.showTextUI(text) shown = text end
        if here.phase == 'sit' and not here.sitting and not here.out[me] and IsControlJustPressed(0, 38) and not Nui.isOpen() then
            local chair = nearestFree()
            if not chair then lib.notify({ description = t('chairs.no_chair'), type = 'error' })
            else
                CreateThread(function()
                    local result = Games.call('chairs:sit', { chair = chair })
                    if not result.ok then Games.fail(result) end
                end)
            end
        end
        Wait(0)
    end
    here.playing = false
    standAll()
    lib.hideTextUI()
end

Games.kind('chairs_ring', function(record)
    return { options = Games.venueOptions(record, 'fa-solid fa-chair'), distance = 2.5 }
end)

local OUT_TEXT = { early = 'chairs.out_early', ring = 'chairs.out_ring', vehicle = 'chairs.out_ring', away = 'chairs.out_ring' }

Games.onScene('chairs', function(op, args, _, scene)
    if op == 'start' or op == 'full' then
        local s = args.scene or {}
        here.id, here.venue, here.chairs, here.taken, here.phase, here.out = scene.id, args.venue, s.chairs or {}, s.taken or {}, s.phase, s.out or {}
        here.walk, here.round = s.walk or here.walk, s.round or 0
        spawnChairs()
        if Games.lobby and Games.lobby.id == scene.id then CreateThread(playLoop) end
    elseif op == 'round' then
        standAll()
        here.chairs, here.taken, here.phase, here.round, here.walk = args.chairs, {}, 'music', args.round, args.walk or here.walk
        scene.public.scene.round = args.round
        spawnChairs()
        music(true, args)
        CreateThread(function() walk(args.starts or {}) end)
    elseif op == 'stop' then
        here.phase = 'sit'
        music(false)
    elseif op == 'sat' then
        here.taken[args.chair] = args.id
        if args.id == cache.serverId then sitOn(args.chair) end
        local bot = Games.myBot(args.id)
        if bot then
            sitOn(args.chair, bot)
            here.seatedBots = here.seatedBots or {}
            here.seatedBots[args.id] = true
        end
    elseif op == 'resolved' then
        here.phase = 'break'
        music(false)
        standAll() -- up before the next round's chairs come
        if args.again then lib.notify({ description = t('chairs.again') }) end
    elseif op == 'out' then
        here.out[args.id] = true
        local key = OUT_TEXT[args.why] or 'chairs.out'
        lib.notify({ description = args.id == cache.serverId and t('chairs.you_out') or t(key, args.name or ''), type = args.id == cache.serverId and 'error' or 'inform' })
    elseif op == 'end' then
        music(false)
        standAll()
        here.id, here.phase = nil, nil
        Games.hideOverlay('games.scorebar')
        -- The chairs go once everyone has stood up.
        local entities = here.entities
        here.entities = {}
        SetTimeout(2500, function()
            for _, entity in ipairs(entities) do
                if DoesEntityExist(entity) then DeleteEntity(entity) end
            end
        end)
        return
    end
    bar(scene)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    clearChairs()
    if here.sitting then ClearPedTasks(cache.ped) end
end)
