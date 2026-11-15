-- Mini golf on the client: the course in the world (flags, walls, cups), the balls every nearby client rolls along
-- the server's path, and the putt: walk to your ball, E to line up, A/D or the mouse to aim, Space to start the
-- power needle and Space again to putt. Right button steps back.
local cfg = Config.Golf
local Putting = GameRules.putting
local t = DL.locale.t
local here = { id = nil, balls = {}, rolling = nil, aiming = false, looping = false, z = nil }
local DRAW_RANGE = 35.0

local function kit() return GetResourceState(cfg.Kit.Resource) == 'started' end

-- The course in the world ---------------------------------------------------------------------------------------

-- Flags on the cups, the cup and tee marks, and on each walled edge kit rails or (without the kit) corner cones.
local function furnish()
    local defs, hasKit = {}, kit()
    for _, zone in ipairs(Games.world.zones({ kind = 'golf_hole' })) do
        local s, points = zone.settings or {}, zone.points or {}
        if s.cup then
            defs[#defs + 1] = { uid = 'golf:flag:' .. zone.uid, coords = { x = s.cup.x, y = s.cup.y, z = s.cup.z, w = 0.0 }, presentation = 'prop', model = cfg.Flag, revision = zone.revision }
            defs[#defs + 1] = { uid = 'golf:cup:' .. zone.uid, coords = { x = s.cup.x, y = s.cup.y, z = s.cup.z, w = 0.0 }, presentation = 'prop',
                model = hasKit and cfg.Kit.Cup or cfg.Fallback.Cup, revision = zone.revision }
        end
        if s.tee and hasKit then
            defs[#defs + 1] = { uid = 'golf:tee:' .. zone.uid, coords = { x = s.tee.x, y = s.tee.y, z = s.tee.z, w = s.tee.w or 0.0 }, presentation = 'prop', model = cfg.Kit.Tee, revision = zone.revision }
        end
        local open = {}
        for _, i in ipairs(s.open or {}) do open[tonumber(i)] = true end
        local z = s.tee and s.tee.z or zone.minZ or 0.0
        for i, a in ipairs(points) do
            local b = points[i % #points + 1]
            defs[#defs + 1] = { uid = ('golf:corner:%s:%d'):format(zone.uid, i), coords = { x = a.x, y = a.y, z = z, w = 0.0 }, presentation = 'prop',
                model = hasKit and cfg.Kit.Corner or cfg.Fallback.Corner, revision = zone.revision }
            if hasKit and not open[i] then
                local dx, dy = b.x - a.x, b.y - a.y
                local length = math.sqrt(dx * dx + dy * dy)
                local heading = math.deg(math.atan(-dx, dy))
                for k = 0, math.floor(length) - 1 do
                    local f = (k + 0.5) / length
                    defs[#defs + 1] = { uid = ('golf:rail:%s:%d:%d'):format(zone.uid, i, k), coords = { x = a.x + dx * f, y = a.y + dy * f, z = z, w = heading },
                        presentation = 'prop', model = cfg.Kit.Rail, revision = zone.revision }
                end
            end
        end
    end
    for _, def in ipairs(defs) do def.streamDistance = Config.StreamDistance end
    Games.world.anchors.sync('golf', defs)
end
Games.world.subscribe(furnish)

-- Without the kit the walls are white lines on the ground, drawn only near the holes.
CreateThread(function()
    while true do
        local wait = 1500
        if not kit() then
            local me = GetEntityCoords(cache.ped)
            for _, zone in ipairs(Games.world.zones({ kind = 'golf_hole' })) do
                local s, points = zone.settings or {}, zone.points or {}
                local z = (s.tee and s.tee.z or me.z) + 0.03
                if #points > 2 and #(vector2(me.x, me.y) - vector2(points[1].x, points[1].y)) < DRAW_RANGE then
                    wait = 0
                    local open = {}
                    for _, i in ipairs(s.open or {}) do open[tonumber(i)] = true end
                    for i, a in ipairs(points) do
                        local b = points[i % #points + 1]
                        if not open[i] then DrawLine(a.x, a.y, z, b.x, b.y, z, 245, 245, 240, 200) end
                    end
                end
            end
        end
        Wait(wait)
    end
end)

-- The course entrance: open, join, or the sign-up sheet.
Games.kind('golf_course', function(record)
    return { options = Games.venueOptions(record, 'fa-solid fa-golf-ball-tee'), distance = 2.5 }
end)

-- Balls --------------------------------------------------------------------------------------------------------

local function ground(x, y, z)
    local found, gz = GetGroundZFor_3dCoord(x, y, z + 1.0, false)
    return found and gz or z
end

local function ballModel(scene, id)
    for i, p in ipairs(scene.public and scene.public.players or {}) do
        if p.id == id then return joaat(cfg.Balls[(i - 1) % #cfg.Balls + 1]) end
    end
    return joaat(cfg.Balls[1])
end

local function setBall(scene, id, x, y, hidden)
    local entity = here.balls[id]
    if hidden then
        if entity and DoesEntityExist(entity) then DeleteEntity(entity) end
        here.balls[id] = nil
        return
    end
    local z = ground(x, y, here.z or GetEntityCoords(cache.ped).z) + 0.021
    if not entity or not DoesEntityExist(entity) then
        local model = ballModel(scene, id)
        if not lib.requestModel(model, 3000) then return end
        pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
        entity = CreateObject(model, x, y, z, false, false, false)
        SetEntityCollision(entity, false, false)
        FreezeEntityPosition(entity, true)
        SetModelAsNoLongerNeeded(model)
        here.balls[id] = entity
    end
    SetEntityCoordsNoOffset(entity, x, y, z, false, false, false)
end

local function clearBalls()
    for id in pairs(here.balls) do setBall(nil, id, 0, 0, true) end
    here.balls = {}
end

local function placeAll(scene, balls)
    for key, ball in pairs(balls or {}) do
        local id = tonumber(key)
        setBall(scene, id, ball.x, ball.y, ball.done and ball.holed)
    end
end

-- Plays a putt's path: a point every 50 ms from the server's start time (on this client's clock).
local function roll(scene, putt)
    here.rolling = putt
    local entity = here.balls[putt.id]
    local path, start = putt.path, Games.localTime(putt.at)
    while here.rolling == putt do
        local i = (GetGameTimer() - start) / 50 + 1
        if i >= #path then break end
        if i >= 1 and entity and DoesEntityExist(entity) then
            local a, b = path[math.floor(i)], path[math.floor(i) + 1]
            local f = i - math.floor(i)
            local x, y = a[1] + (b[1] - a[1]) * f, a[2] + (b[2] - a[2]) * f
            SetEntityCoordsNoOffset(entity, x, y, (here.z or 0) + 0.021, false, false, false)
        end
        Wait(0)
    end
    local last = path[#path]
    if here.rolling == putt then
        here.rolling = nil
        if putt.holed then
            setBall(scene, putt.id, last[1], last[2], true)
            PlaySoundFrontend(-1, 'CHECKPOINT_PERFECT', 'HUD_MINI_GAME_SOUNDSET', true)
        elseif not putt.out then
            setBall(scene, putt.id, last[1], last[2])
        end
    end
end

-- Putting --------------------------------------------------------------------------------------------------------

local function play(dict, name, flag)
    if lib.requestAnimDict(dict, 3000) then TaskPlayAnim(cache.ped, dict, name, 4.0, 4.0, -1, flag or 0, 0.0, false, false, false) end
end

local putter
local function holdPutter(on)
    if putter and DoesEntityExist(putter) then DeleteEntity(putter) end
    putter = nil
    if not on then return end
    local model = joaat(cfg.Putter)
    if not lib.requestModel(model, 3000) then return end
    pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
    putter = CreateObject(model, 0.0, 0.0, 0.0, false, false, false)
    AttachEntityToEntity(putter, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.1, 0.0, -0.02, -60.0, 0.0, 0.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(model)
end

local function step(session, input)
    input.id = session
    local result = lib.callback.await('daddy_campusgames:minigame:step', false, input)
    return result and result.ok
end

local function myBall(scene)
    local s = scene.public and scene.public.scene or {}
    return (s.balls or {})[tostring(cache.serverId)] or (s.balls or {})[cache.serverId]
end

local function aim(scene)
    local s = scene.public.scene
    local ball = myBall(scene)
    if not ball then return end
    here.aiming = true
    lib.showTextUI(t('golf.aim_help'))
    local cup = s.hole.cup
    local heading = math.deg(math.atan(-(cup.x - ball.x), cup.y - ball.y))
    local z = ground(ball.x, ball.y, here.z or GetEntityCoords(cache.ped).z)
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
    SetCamFov(cam, 50.0)
    RenderScriptCams(true, true, 400, true, false)
    holdPutter(true)
    play(cfg.Anim.dict, cfg.Anim.idle, 1)

    local session, needle, began, pressed = nil, nil, nil, false
    while here.aiming do
        DisableAllControlActions(0)
        local turn = (IsDisabledControlPressed(0, 34) and 1 or 0) - (IsDisabledControlPressed(0, 35) and 1 or 0)
        if not session then heading = (heading + turn * 40.0 * GetFrameTime() - GetDisabledControlNormal(0, 1) * 8.0) % 360 end
        local dx, dy = Putting.direction(heading)
        -- Stand beside the ball, the target on your left; the camera behind the line.
        local fx, fy = Putting.direction(heading - 90.0)
        SetEntityCoordsNoOffset(cache.ped, ball.x - fx * cfg.Stance, ball.y - fy * cfg.Stance, z + 1.0, false, false, false)
        SetEntityHeading(cache.ped, heading - 90.0)
        SetCamCoord(cam, ball.x - dx * 2.4, ball.y - dy * 2.4, z + 1.25)
        PointCamAtCoord(cam, ball.x + dx * 1.5, ball.y + dy * 1.5, z)
        for k = 0, 5 do
            local a, b = 0.15 + k * 0.25, 0.27 + k * 0.25
            DrawLine(ball.x + dx * a, ball.y + dy * a, z + 0.02, ball.x + dx * b, ball.y + dy * b, z + 0.02, 255, 255, 255, 220)
        end
        if session then
            local power = Putting.power(GetGameTimer() - began, needle.speed, needle.phase)
            DrawRect(0.9, 0.55, 0.012, 0.32, 20, 24, 22, 200)
            DrawRect(0.9, 0.55 + 0.16 - power * 0.16, 0.012, power * 0.32, 245, 240, 225, 230)
            DrawRect(0.9, 0.55 + 0.16 - power * 0.32, 0.022, 0.004, 231, 195, 90, 255)
        end
        if IsDisabledControlJustPressed(0, 22) then
            if not session then
                local result = Games.call('golf:aim')
                if not result.ok then Games.fail(result) here.aiming = false break end
                session, needle = result.session, result.needle
                began = GetGameTimer()
                CreateThread(function() step(session, { kind = 'begin' }) end)
            elseif not pressed then
                pressed = true
                local ms = GetGameTimer() - began
                here.aiming = false
                play(cfg.Anim.dict, cfg.Anim.action, 0)
                CreateThread(function()
                    if step(session, { kind = 'press', ms = ms }) then
                        local result = Games.call('golf:putt', { session = session, heading = heading })
                        if not result.ok then Games.fail(result) end
                    end
                end)
            end
        end
        if not session and (IsDisabledControlJustPressed(0, 25) or IsDisabledControlJustPressed(0, 177)) then here.aiming = false end
        Wait(0)
    end
    lib.hideTextUI()
    SetTimeout(pressed and 1600 or 0, function()
        RenderScriptCams(false, true, 500, true, false)
        pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]]
        DestroyCam(cam, false)
        holdPutter(false)
        if not pressed then ClearPedTasks(cache.ped) end
    end)
end

local function turnLoop()
    if here.looping then return end
    here.looping = true
    local shown
    while here.id and Games.myTurn(Games.scenes[here.id]) do
        local scene = Games.scenes[here.id]
        local ball = myBall(scene)
        if ball and not here.aiming and not here.rolling then
            local z = here.z or GetEntityCoords(cache.ped).z
            DrawMarker(2, ball.x, ball.y, z + 0.5, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.12, 0.12, 0.12, 245, 240, 225, 200, true, true, 2, false, nil, nil, false)
            local at = #(vector2(GetEntityCoords(cache.ped).xy) - vector2(ball.x, ball.y)) <= cfg.BallReach
            local text = at and t('golf.putt_key') or t('golf.go_ball')
            if shown ~= text then lib.showTextUI(text) shown = text end
            if at and IsControlJustPressed(0, 38) and not Nui.isOpen() then aim(scene) shown = nil end
        end
        Wait(0)
    end
    here.looping = false
    lib.hideTextUI()
end

-- The score strip: the hole, its par and each player's strokes.
local function scorebar(scene)
    local s = scene.public and scene.public.scene or {}
    if not s.hole then return end
    local players = {}
    for _, p in ipairs(scene.public.players or {}) do
        local total = 0
        for _, n in pairs((s.card or {})[tostring(p.id)] or (s.card or {})[p.id] or {}) do total = total + n end
        local ball = (s.balls or {})[tostring(p.id)] or (s.balls or {})[p.id] or {}
        players[#players + 1] = { id = p.id, name = p.name, strokes = ball.strokes or 0, total = total }
    end
    local me = GetEntityCoords(cache.ped)
    if #(vector2(me.x, me.y) - vector2(s.hole.cup.x, s.hole.cup.y)) > DRAW_RANGE then return Games.hideOverlay('games.scorebar') end
    Games.overlay('games.scorebar', { game = 'golf', hole = s.hole.number, holes = #(s.holes or {}), par = s.hole.par, players = players, turn = scene.turn })
end

-- A test bot is set beside its ball on its turn, the cup on its left (where a player stands to putt).
local function botToBall(scene)
    local ped, s = Games.myBot(scene.turn), scene.public and scene.public.scene or {}
    local ball = ped and s.balls and (s.balls[tostring(scene.turn)] or s.balls[scene.turn])
    if not ball or not s.hole then return end
    local cup = s.hole.cup
    local heading = math.deg(math.atan(-(cup.x - ball.x), cup.y - ball.y))
    local fx, fy = Putting.direction(heading - 90.0)
    local z = ground(ball.x, ball.y, here.z or s.hole.z or 0.0)
    SetEntityCoordsNoOffset(ped, ball.x - fx * cfg.Stance, ball.y - fy * cfg.Stance, z + 1.0, false, false, false)
    SetEntityHeading(ped, heading - 90.0)
    if lib.requestAnimDict(cfg.Anim.dict, 2000) then TaskPlayAnim(ped, cfg.Anim.dict, cfg.Anim.idle, 4.0, 4.0, -1, 1, 0.0, false, false, false) end
end

Games.onScene('golf', function(op, args, _, scene)
    scene.public = scene.public or {}
    local s = scene.public.scene or {}
    if op == 'start' or op == 'full' then
        scene.public = args
        s = args.scene or {}
        here.id = scene.id
        here.z = s.hole and s.hole.z
        clearBalls()
        placeAll(scene, s.balls)
        if s.rolling then CreateThread(function() roll(scene, s.rolling) end) end
    elseif op == 'hole' then
        s.hole, s.balls, s.index = args.hole, args.balls, args.index
        here.z = args.hole.z
        clearBalls()
        placeAll(scene, s.balls)
    elseif op == 'putt' then
        CreateThread(function() roll(scene, args) end)
    elseif op == 'ball' then
        if args.id and args.ball then
            s.balls = s.balls or {}
            s.balls[tostring(args.id)] = args.ball
            if args.ball.done then
                local card = s.card or {}
                local row = card[tostring(args.id)] or {}
                row[s.index or 1] = args.ball.strokes
                card[tostring(args.id)] = row
                s.card = card
            end
            if args.out then lib.notify({ description = t('golf.out') }) end
            setBall(scene, args.id, args.ball.x, args.ball.y, args.ball.holed)
        end
    elseif op == 'end' then
        here.aiming, here.rolling, here.id = false, nil, nil
        clearBalls()
        Games.hideOverlay('games.scorebar')
        return
    end
    scene.public.scene = s
    if (op == 'turn' or op == 'start' or op == 'full') and Games.myTurn(scene) then CreateThread(turnLoop) end
    if op == 'turn' or op == 'start' then botToBall(scene) end
    scorebar(scene)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    clearBalls()
    holdPutter(false)
    Games.world.anchors.clear('golf')
end)
