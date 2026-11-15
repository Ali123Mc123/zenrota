-- Red light, green light on the client: the start and finish lines on the ground, the light (its red or green model
-- stands in for the one at the place), the start spot, the sounds and what to do now on screen. Players just run;
-- the server watches them. The track runs the way the light's lenses face (the place heading turned round).
local cfg = Config.Light
local t = DL.locale.t
local here = { id = nil, phase = nil, venue = nil, light = nil, done = {}, out = {} }
local MOVE = { 21, 22, 30, 31, 32, 33, 34, 35 } -- sprint, jump, walking: held during the countdown

local function frame(v)
    local h = math.rad((v.h or 0) + 180.0)
    return vector2(-math.sin(h), math.cos(h))
end

local function ground(x, y, z)
    local found, g = GetGroundZFor_3dCoord(x, y, z + 1.0, false)
    return found and g or z
end

-- A line across the track at a distance in front of the light.
local function line(v, f, ahead, width, r, g, b)
    local cx, cy = v.x + f.x * ahead, v.y + f.y * ahead
    DrawMarker(43, cx, cy, ground(cx, cy, v.z) + 0.02, 0.0, 0.0, 0.0, 0.0, 0.0, v.h or 0.0, width, 0.25, 0.04, r, g, b, 150, false, false, 2, false, nil, nil, false)
end

-- The light's model for the phase over the place's own prop (which hides meanwhile).
local function showLight(phase)
    if here.light and DoesEntityExist(here.light) then DeleteEntity(here.light) end
    here.light = nil
    local v, anchor = here.venue, here.venue and Games.entity('light_track', here.venue.uid)
    local hash = joaat(cfg.Models[phase] or cfg.Models.off)
    local swap = v and phase ~= 'off' and IsModelInCdimage(hash)
    if anchor and DoesEntityExist(anchor) then SetEntityVisible(anchor, not swap, false) end
    if not swap or not pcall(lib.requestModel, hash, 2000) then return end
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    here.light = CreateObject(hash, v.x, v.y, v.z, false, false, false)
    SetEntityHeading(here.light, v.h or 0.0)
    FreezeEntityPosition(here.light, true)
    SetModelAsNoLongerNeeded(hash)
end

local function counts(scene)
    local total, done = 0, 0
    for _, p in ipairs(scene.public and scene.public.players or {}) do
        total = total + 1
        if here.done[p.id] then done = done + 1 end
    end
    return done, total
end

local function bar(scene)
    local done, total = counts(scene)
    local s = scene.public and scene.public.scene or {}
    Games.overlay('games.scorebar', { game = 'party', title = t('games.game_light'), light = here.phase,
        items = { { label = t('light.finished'), value = ('%d/%d'):format(done, total) } },
        remaining = s.endsAt and math.max(0, math.floor((s.endsAt - Games.serverNow()) / 1000)) or nil })
end

local function drawLoop(scene)
    if here.drawing then return end
    here.drawing = true
    while here.id == scene.id do
        local v, s = here.venue, scene.public and scene.public.scene or {}
        if v and s.length then
            local f = frame(v)
            line(v, f, s.length, s.width, 255, 255, 255)
            line(v, f, s.finish, s.width, 90, 200, 120)
        end
        Wait(0)
    end
    here.drawing = false
end

-- While I play: what to do now on screen, and no walking off before the first green.
local function playLoop()
    if here.playing then return end
    here.playing = true
    local shown
    while here.id and Games.lobby and Games.lobby.id == here.id do
        local me = cache.serverId
        local text = here.out[me] and t('light.you_out') or here.done[me] and t('light.you_finished', here.done[me])
            or t('light.do_' .. (here.phase or 'prep'))
        if shown ~= text then lib.showTextUI(text) shown = text end
        if here.phase == 'prep' then
            for _, control in ipairs(MOVE) do DisableControlAction(0, control, true) end
        end
        Wait(0)
    end
    here.playing = false
    lib.hideTextUI()
end

-- Test bots: to their start spots, standing still until the first green.
local function botsToLine(spots)
    for id, ped in pairs(Games.myBots()) do
        local spot = spots[id]
        if spot and DoesEntityExist(ped) then
            ClearPedTasksImmediately(ped)
            SetEntityCoords(ped, spot.x, spot.y, ground(spot.x, spot.y, spot.z), false, false, false, false)
            SetEntityHeading(ped, spot.h)
        end
    end
end

-- On green they run for the light; on red most stop at once and a few too late (and are out).
local function botsOnLight(scene, phase)
    local v, s = here.venue, scene.public and scene.public.scene or {}
    if not v then return end
    local f = frame(v)
    local fx, fy = v.x + f.x * (s.finish or 3.0) * 0.5, v.y + f.y * (s.finish or 3.0) * 0.5
    for id, ped in pairs(Games.myBots()) do
        if DoesEntityExist(ped) and not here.done[id] and not here.out[id] then
            if phase == 'green' then
                TaskGoStraightToCoord(ped, fx, fy, v.z, 1.0 + (id % 3) * 0.5, -1, (v.h or 0.0) % 360, 0.5)
            else
                SetTimeout(math.random() < Config.Bots.Late and 1700 or math.random(100, 400), function()
                    if here.phase ~= 'green' and DoesEntityExist(ped) then ClearPedTasks(ped) end
                end)
            end
        end
    end
end

Games.kind('light_track', function(record)
    return { options = Games.venueOptions(record, 'fa-solid fa-traffic-light'), distance = 3.0,
        model = IsModelInCdimage(joaat(cfg.Models.off)) and cfg.Models.off or 'prop_mp_cone_02' }
end)

Games.onScene('light', function(op, args, _, scene)
    if op == 'start' or op == 'full' then
        local s = args.scene or {}
        here.id, here.venue, here.phase, here.done, here.out = scene.id, args.venue, s.phase, s.done or {}, s.out or {}
        showLight(s.phase == 'prep' and 'off' or s.phase)
        CreateThread(function() drawLoop(scene) end)
        -- At the start every player goes to their spot on the start line, facing the light.
        local spot = op == 'start' and s.spots and s.spots[cache.serverId]
        if spot then
            pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
            SetEntityCoords(cache.ped, spot.x, spot.y, ground(spot.x, spot.y, spot.z), false, false, false, false)
            SetEntityHeading(cache.ped, spot.h)
            lib.notify({ description = t('light.ready', math.floor((s.prepMs or 8000) / 1000)) })
        end
        if op == 'start' then botsToLine(s.spots or {}) end
        if Games.lobby and Games.lobby.id == scene.id then CreateThread(playLoop) end
    elseif op == 'light' then
        here.phase = args.phase
        scene.public.scene.endsAt = args.endsAt
        showLight(args.phase)
        botsOnLight(scene, args.phase)
        PlaySoundFrontend(-1, args.phase == 'green' and 'Beep_Green' or 'Beep_Red', 'DLC_HEIST_HACKING_SNAKE_SOUNDS', true)
    elseif op == 'finished' then
        here.done[args.id] = args.place
        if Games.myBot(args.id) then ClearPedTasks(Games.myBot(args.id)) end
        lib.notify({ description = args.id == cache.serverId and t('light.you_finished', args.place) or t('light.finished_by', args.name or '', args.place), type = 'success' })
    elseif op == 'out' then
        here.out[args.id] = true
        if Games.myBot(args.id) then SetPedToRagdoll(Games.myBot(args.id), 3000, 3000, 0, false, false, false) end
        if args.id == cache.serverId then
            SetPedToRagdoll(cache.ped, 3000, 3000, 0, false, false, false)
            lib.notify({ description = t('light.you_out'), type = 'error' })
        else
            lib.notify({ description = t('light.out', args.name or '') })
        end
    elseif op == 'end' then
        showLight('off')
        here.id, here.phase = nil, nil
        Games.hideOverlay('games.scorebar')
        return
    end
    bar(scene)
end)

-- The clock on the bar moves between the server's messages.
CreateThread(function()
    while true do
        local scene = here.id and Games.scenes[here.id]
        if scene and here.phase then bar(scene) end
        Wait(1000)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    if here.light and DoesEntityExist(here.light) then DeleteEntity(here.light) end
end)
