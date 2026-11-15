-- Hide and seek on the client: the seeker counts with a dark screen and cannot move, hiders run; then E finds a
-- hider next to the seeker, or (for a hider at the base) calls safe. The base is marked on the ground.
local cfg = Config.Seek
local t = DL.locale.t
local here = { id = nil, seeker = nil, phase = nil, found = {}, safe = {}, venue = nil, blind = false }

local function blind(on)
    if on == here.blind then return end
    here.blind = on
    FreezeEntityPosition(cache.ped, on)
    if on then DoScreenFadeOut(600) else DoScreenFadeIn(600) end
end

local function nameOf(scene, id)
    for _, p in ipairs(scene.public and scene.public.players or {}) do
        if p.id == id then return p.name end
    end
    return ''
end

local function bar(scene)
    local s = scene.public and scene.public.scene or {}
    local left = 0
    for _, p in ipairs(scene.public and scene.public.players or {}) do
        if p.id ~= here.seeker and not here.found[p.id] and not here.safe[p.id] then left = left + 1 end
    end
    local untilMs = here.phase == 'hide' and s.untilMs or s.endsAt
    Games.overlay('games.scorebar', { game = 'party', title = t('games.game_seek'), items = {
        { label = t('seek.seeker'), value = nameOf(scene, here.seeker) }, { label = t('seek.hidden'), value = tostring(left) } },
        remaining = untilMs and math.max(0, math.floor((untilMs - Games.serverNow()) / 1000)) or nil })
end

local function call(name)
    CreateThread(function()
        local result = Games.call(name)
        if not result.ok then Games.fail(result) end
    end)
end

local function playLoop()
    if here.playing then return end
    here.playing = true
    local shown
    while here.id and Games.lobby and Games.lobby.id == here.id do
        local me, v = cache.serverId, here.venue
        local seeker = here.seeker == me
        local outNow = here.found[me] or here.safe[me]
        if v then DrawMarker(1, v.x, v.y, v.z + 0.02, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, cfg.SafeRange * 2, cfg.SafeRange * 2, 0.3, 240, 200, 60, 70, false, false, 2, false, nil, nil, false) end
        local atBase = v and #(GetEntityCoords(cache.ped).xy - vector2(v.x, v.y)) <= cfg.SafeRange
        local text
        if outNow then text = here.safe[me] and t('seek.you_safe') or t('seek.you_found')
        elseif here.phase == 'hide' then text = seeker and t('seek.counting') or t('seek.hide', math.floor(cfg.Camp))
        elseif seeker then text = t('seek.find_key')
        else text = atBase and t('seek.safe_key') or t('seek.hiding') end
        if shown ~= text then lib.showTextUI(text) shown = text end
        if here.phase == 'seek' and not outNow and IsControlJustPressed(0, 38) and not Nui.isOpen() then
            if seeker then call('seek:find') elseif atBase then call('seek:safe') end
        end
        Wait(0)
    end
    here.playing = false
    blind(false)
    lib.hideTextUI()
end

Games.kind('seek_base', function(record)
    return { options = Games.venueOptions(record, 'fa-solid fa-eye-slash'), distance = 3.0 }
end)

-- Test bots at the start: hiders run to a random spot in the area (past the camp line), a seeker waits at the base.
local function botsHide(s, v)
    for id, ped in pairs(Games.myBots()) do
        if DoesEntityExist(ped) then
            if id == s.seeker then
                FreezeEntityPosition(ped, true)
            else
                local a, d = math.random() * 2 * math.pi, cfg.Camp + 3.0 + math.random() * math.max(2.0, (s.radius or cfg.Radius) - cfg.Camp - 8.0)
                TaskGoStraightToCoord(ped, v.x + math.sin(a) * d, v.y + math.cos(a) * d, v.z, 2.0, -1, 0.0, 0.5)
            end
        end
    end
end

Games.onScene('seek', function(op, args, _, scene)
    if op == 'start' or op == 'full' then
        local s = args.scene or {}
        here.id, here.seeker, here.phase, here.found, here.safe, here.venue = scene.id, s.seeker, s.phase, s.found or {}, s.safe or {}, args.venue
        local playing = Games.lobby and Games.lobby.id == scene.id
        blind(playing and s.phase == 'hide' and s.seeker == cache.serverId)
        if op == 'start' and playing then
            lib.notify({ description = s.seeker == cache.serverId and t('seek.you_seek') or t('seek.seeker_is', nameOf(scene, s.seeker)), type = 'inform' })
        end
        if op == 'start' then botsHide(s, args.venue) end
        if playing then CreateThread(playLoop) end
    elseif op == 'seek' then
        here.phase = 'seek'
        scene.public.scene.endsAt = args.endsAt
        blind(false)
        local seeker = Games.myBot(here.seeker)
        if seeker then FreezeEntityPosition(seeker, false) end
        PlaySoundFrontend(-1, 'Beep_Green', 'DLC_HEIST_HACKING_SNAKE_SOUNDS', true)
        lib.notify({ description = t('seek.go'), type = 'success' })
    elseif op == 'found' then
        here.found[args.id] = true
        if Games.myBot(args.id) then TaskHandsUp(Games.myBot(args.id), 4000, 0, -1, true) end
        local mine, camp = args.id == cache.serverId, args.why == 'camp'
        local key = mine and (camp and 'seek.you_camped' or 'seek.you_found') or (camp and 'seek.camped' or 'seek.found')
        lib.notify({ description = t(key, args.name or ''), type = mine and 'error' or 'inform' })
    elseif op == 'safe' then
        here.safe[args.id] = true
        lib.notify({ description = t('seek.safe', args.name or ''), type = 'success' })
    elseif op == 'end' then
        blind(false)
        here.id, here.phase = nil, nil
        Games.hideOverlay('games.scorebar')
        return
    end
    bar(scene)
end)

CreateThread(function()
    while true do
        local scene = here.id and Games.scenes[here.id]
        if scene then bar(scene) end
        Wait(1000)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource and here.blind then
        FreezeEntityPosition(cache.ped, false)
        DoScreenFadeIn(0)
    end
end)
