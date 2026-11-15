-- Darts on the client: the board, the line on your turn, aiming from a camera over the shoulder with the sway
-- the server sent, and the darts every nearby client sees fly and stick where the server says.
-- Aiming: move the mouse, hold the left button to hold your breath, let go to throw; right button steps back.
local cfg = Config.Darts
local Darts = GameRules.darts
local t = DL.locale.t
local here = { id = nil, board = nil, darts = {}, aiming = false }
local SCORE_RANGE = 8.0

-- Board space ----------------------------------------------------------------------------------------------------

-- The board's bull, the thrower's right and the way the board faces (out towards the line).
local function frame(board)
    local h = math.rad((board.w or 0) + cfg.Facing)
    local forward = vector3(-math.sin(h), math.cos(h), 0.0)
    local right = vector3(-math.cos(h), -math.sin(h), 0.0)
    local o = cfg.BoardOffset
    local center = vector3(board.x, board.y, board.z) + right * o.x + forward * o.y + vector3(0.0, 0.0, o.z)
    return center, right, forward
end

local function onBoard(board, x, y)
    local center, right = frame(board)
    return center + right * x + vector3(0.0, 0.0, y)
end

-- The darts in the board ----------------------------------------------------------------------------------------

local function clearDarts()
    for _, entity in ipairs(here.darts) do
        if DoesEntityExist(entity) then DeleteEntity(entity) end
    end
    here.darts = {}
end

local function dartModel(id)
    local scene = Games.scenes[here.id]
    local seat = 1
    for i, p in ipairs(scene and scene.public and scene.public.players or {}) do
        if p.id == id then seat = i end
    end
    return joaat(cfg.Models[(seat - 1) % #cfg.Models + 1])
end

-- A dart from the thrower's hand to its spot in 0.25 s, then it stays.
local function fly(dart)
    local board = here.board
    if not board then return end
    local _, _, forward = frame(board)
    local target = onBoard(board, dart.x, dart.y) + forward * 0.03
    local model = dartModel(dart.id)
    if not lib.requestModel(model, 3000) then return end
    local thrower = Games.pedOf(dart.id)
    local from = thrower and GetPedBoneCoords(thrower, 57005, 0.0, 0.0, 0.0) or target + forward * 2.0
    pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
    local entity = CreateObject(model, from.x, from.y, from.z, false, false, false)
    SetEntityCollision(entity, false, false)
    FreezeEntityPosition(entity, true)
    SetModelAsNoLongerNeeded(model)
    local yaw = (board.w or 0) + cfg.Facing + 180.0
    here.darts[#here.darts + 1] = entity
    local start = GetGameTimer()
    while GetGameTimer() - start < 250 and DoesEntityExist(entity) do
        local k = (GetGameTimer() - start) / 250
        local p = from + (target - from) * k + vector3(0.0, 0.0, math.sin(k * math.pi) * 0.12)
        SetEntityCoordsNoOffset(entity, p.x, p.y, p.z, false, false, false)
        SetEntityRotation(entity, cfg.DartPitch, 0.0, yaw, 2, false)
        Wait(0)
    end
    if DoesEntityExist(entity) then
        SetEntityCoordsNoOffset(entity, target.x, target.y, target.z, false, false, false)
        SetEntityRotation(entity, cfg.DartPitch + math.random(-6, 6), math.random(-6, 6), yaw + math.random(-5, 5), 2, false)
        PlaySoundFromCoord(-1, cfg.HitSound[1], target.x, target.y, target.z, cfg.HitSound[2], false, 8, false)
    end
end

-- Aiming ------------------------------------------------------------------------------------------------------------

local function play(dict, name, flag)
    if lib.requestAnimDict(dict, 3000) then TaskPlayAnim(cache.ped, dict, name, 4.0, 4.0, -1, flag or 0, 0.0, false, false, false) end
end

local function step(session, input)
    input.id = session
    local result = lib.callback.await('daddy_campusgames:minigame:step', false, input)
    return result and result.ok
end

-- A cross on the screen where the dart would land now.
local function reticle(board, x, y, calm)
    local p = onBoard(board, x, y)
    local ok, sx, sy = GetScreenCoordFromWorldCoord(p.x, p.y, p.z)
    if not ok then return end
    local a = calm and 220 or 255
    local g = calm and 255 or 210
    DrawRect(sx, sy, 0.018, 0.0022, 255, g, g, a)
    DrawRect(sx, sy, 0.0012, 0.032, 255, g, g, a)
    DrawRect(sx, sy, 0.003, 0.0053, 255, 255, 255, 255)
end

local function aim()
    local board = here.board
    local result = Games.call('darts:aim')
    if not result.ok then return Games.fail(result) end
    here.aiming = true
    lib.hideTextUI()
    local center, right, forward = frame(board)
    local line = center + forward * cfg.Oche
    local eye = line + vector3(0.0, 0.0, 1.62 - (center.z - line.z)) + right * 0.18
    local cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', eye.x, eye.y, center.z + 0.05, 0.0, 0.0, 0.0, 32.0, false, 2)
    pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
    PointCamAtCoord(cam, center.x, center.y, center.z)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 400, true, false)
    SetEntityHeading(cache.ped, (board.w or 0) + cfg.Facing + 180.0)
    play(cfg.Anim.dict, cfg.Anim.idle, 1)

    local p, x, y, holdAt, held = result.sway, 0.0, 0.0, nil, false
    local sens, radius = 0.05, result.aimRadius
    -- The clock starts as 'begin' leaves: the server times every later step from its arrival, so the gaps agree.
    local began = GetGameTimer()
    CreateThread(function() step(result.session, { kind = 'begin' }) end)
    local thrown = false
    while here.aiming do
        DisableAllControlActions(0)
        local now = (GetGameTimer() - began) / 1000
        x = x + GetDisabledControlNormal(0, 1) * sens
        y = y - GetDisabledControlNormal(0, 2) * sens
        local r = math.sqrt(x * x + y * y)
        if r > radius then x, y = x / r * radius, y / r * radius end
        if IsDisabledControlJustPressed(0, 24) and not holdAt then
            holdAt = now
            CreateThread(function()
                step(result.session, { kind = 'hold', ms = math.floor(holdAt * 1000) })
                held = true
            end)
        end
        local dx, dy = Darts.sway(p, now, holdAt)
        reticle(board, x + dx, y + dy, holdAt and now - holdAt <= p.hold)
        if holdAt and IsDisabledControlJustReleased(0, 24) then
            thrown = true
            here.aiming = false
            play(cfg.Anim.dict, cfg.Anim.throw, 0)
            local rx, ry, ms = x, y, math.floor(now * 1000)
            CreateThread(function()
                while not held do Wait(0) end
                if step(result.session, { kind = 'release', x = rx, y = ry, ms = ms }) then
                    local thrownResult = Games.call('darts:throw', { session = result.session })
                    if not thrownResult.ok then Games.fail(thrownResult) end
                end
            end)
        end
        if IsDisabledControlJustPressed(0, 25) or IsDisabledControlJustPressed(0, 177) then here.aiming = false end
        Wait(0)
    end
    if not thrown then ClearPedTasks(cache.ped) end
    SetTimeout(thrown and 900 or 0, function()
        RenderScriptCams(false, true, 500, true, false)
        pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]]
        DestroyCam(cam, false)
    end)
end

-- Your turn: the line glows on the floor; at the line, E takes aim.
local function turnLoop()
    if here.looping then return end
    here.looping = true
    local shown
    while here.id and Games.myTurn(Games.scenes[here.id]) do
        local board = here.board
        if board and not here.aiming then
            local center, _, forward = frame(board)
            local line = center + forward * cfg.Oche
            local ground = GetEntityCoords(cache.ped).z - 0.98
            DrawMarker(43, line.x, line.y, ground, 0.0, 0.0, 0.0, 0.0, 0.0, (board.w or 0) + cfg.Facing, 1.2, 0.06, 0.02, 255, 255, 255, 140, false, false, 2, false, nil, nil, false)
            local at = #(vector2(GetEntityCoords(cache.ped).xy) - vector2(line.x, line.y)) <= cfg.LineReach
            local text = at and t('darts.aim_key') or t('darts.go_line')
            if shown ~= text then lib.showTextUI(text) shown = text end
            if at and IsControlJustPressed(0, 38) and not Nui.isOpen() then aim() shown = nil end
        end
        Wait(0)
    end
    here.looping = false
    lib.hideTextUI()
end

-- The score strip for players and anyone watching close by.
local function scorebar(scene)
    local public = scene.public or {}
    local s = public.scene or {}
    local me = GetEntityCoords(cache.ped)
    local board = here.board
    if not board or #(me - vector3(board.x, board.y, board.z)) > SCORE_RANGE then return Games.hideOverlay('games.scorebar') end
    Games.overlay('games.scorebar', { game = 'darts', mode = public.mode, players = s.lines or {}, turn = scene.turn, darts = #(s.darts or {}), last = scene.last })
end

-- The board's target: open, join, or look at the sign-up sheet.
Games.kind('dart_board', function(record)
    return { options = Games.venueOptions(record, 'fa-solid fa-bullseye'), distance = 2.5 }
end)

-- A test bot steps up to the line on its turn, facing the board, and throws with the arm.
local function botToLine(ped)
    local center, _, forward = frame(here.board)
    local line = center + forward * cfg.Oche
    local _, z = GetGroundZFor_3dCoord(line.x, line.y, line.z + 1.0, false)
    SetEntityCoords(ped, line.x, line.y, z ~= 0 and z or line.z - 1.7, false, false, false, false)
    SetEntityHeading(ped, (here.board.w or 0) + cfg.Facing + 180.0)
end

local function botAnim(ped, name)
    if lib.requestAnimDict(cfg.Anim.dict, 2000) then TaskPlayAnim(ped, cfg.Anim.dict, name, 4.0, 4.0, -1, name == cfg.Anim.idle and 1 or 0, 0.0, false, false, false) end
end

Games.onScene('darts', function(op, args, _, scene)
    scene.public = scene.public or {}
    local s = scene.public.scene or {}
    if op == 'start' or op == 'full' then
        scene.public = args
        s = args.scene or {}
        here.id, here.board = scene.id, s.board
        clearDarts()
        for _, dart in ipairs(s.darts or {}) do CreateThread(function() fly(dart) end) end
    elseif op == 'throw' then
        s.darts = s.darts or {}
        s.darts[#s.darts + 1] = args.dart
        for _, line in ipairs(s.lines or {}) do
            if line.id == args.dart.id then line.line = args.line end
        end
        scene.last = { value = args.value, mult = args.mult, bust = args.bust }
        SetTimeout(args.dart.id == cache.serverId and 350 or cfg.ReleaseMs - 300, function() fly(args.dart) end)
        if Games.myBot(args.dart.id) then botAnim(Games.myBot(args.dart.id), cfg.Anim.throw) end
        if args.bust then lib.notify({ description = t('darts.bust'), type = 'error' }) end
    elseif op == 'retrieve' then
        if args.id == cache.serverId then
            play(cfg.Anim.dict, (args.total or 0) >= 60 and cfg.Anim.win or cfg.Anim.retrieve, 0)
        end
        SetTimeout(1500, clearDarts)
        s.darts = {}
        scene.last = nil
    elseif op == 'end' then
        clearDarts()
        here.aiming = false
        Games.hideOverlay('games.scorebar')
        here.id = nil
        return
    end
    scene.public.scene = s
    if op == 'turn' or op == 'start' or op == 'full' then
        if Games.myTurn(scene) then CreateThread(turnLoop) end
        local bot = Games.myBot(scene.turn)
        if bot and here.board then
            botToLine(bot)
            botAnim(bot, cfg.Anim.idle)
        end
    end
    scorebar(scene)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then clearDarts() end
end)
