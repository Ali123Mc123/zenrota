-- Who Am I on the client: a headband card on every player's forehead, the names over the heads (for the players only,
-- never your own), the answers as coloured words over the heads, an arrow over the one asking, and the screen.
-- Keys: E yes, Q no, H maybe while someone else asks; on your own turn E to type your guess, Q to hand the turn on;
-- in the race E to type.
local cfg = Config.WhoAmI
local t = DL.locale.t
local here = { id = nil, venue = nil, s = nil, players = {}, names = {}, hints = {}, answers = {}, asks = {}, bands = {}, input = false }
local busy = false
local COLORS = { yes = { 90, 210, 120 }, no = { 235, 90, 70 }, maybe = { 240, 200, 70 } }

local function first(list)
    for _, name in ipairs(list or {}) do
        if IsModelInCdimage(joaat(name)) then return name end
    end
end

local function nameOf(id) return id and here.players[id] and here.players[id].name or '' end
local function playing() return here.id ~= nil and Games.lobby ~= nil and Games.lobby.id == here.id end
local function near(range)
    local v = here.venue
    return v ~= nil and #(GetEntityCoords(cache.ped) - vector3(v.x, v.y, v.z)) <= range
end

local function sfx(name)
    if playing() or near(cfg.WatchRange) then SendNUIMessage({ action = 'sfx', name = name, volume = playing() and 1.0 or 0.5 }) end
end

-- GTA's fonts have no ş, ğ, ı or İ: over the heads those are written s, g, i and I.
local GLYPHS = { ['ş'] = 's', ['Ş'] = 'S', ['ğ'] = 'g', ['Ğ'] = 'G', ['ı'] = 'i', ['İ'] = 'I' }
local function plain(text) return (text:gsub('[\196\197][\128-\191]', GLYPHS)) end

-- The screen --------------------------------------------------------------------------------------------------------

local function secondsTo(at) return at and math.max(0, math.ceil((at - Games.serverNow()) / 1000)) or nil end

local function payload()
    local s, me = here.s, cache.serverId
    local base = { mode = s.mode, watching = not playing(), input = here.input, last = here.last }
    if s.mode == 'race' then
        local scores = {}
        for id, points in pairs(s.points or {}) do scores[#scores + 1] = { name = nameOf(id), points = points, me = id == me } end
        table.sort(scores, function(a, b) return a.points > b.points end)
        base.round, base.rounds, base.phase, base.clues, base.scores = s.round, s.rounds, s.phase, s.clues or {}, scores
        base.clueLeft, base.revealed, base.misses = s.phase == 'clues' and secondsTo(s.clueEndsAt) or nil, s.revealed, here.misses
        return base
    end
    local solved = {}
    for _, row in ipairs(s.solved or {}) do solved[#solved + 1] = { who = nameOf(row.id), name = row.name, place = row.place, me = row.id == me } end
    local total = 0
    for _ in pairs(here.players) do total = total + 1 end
    base.asker, base.mine, base.left, base.solved, base.total = nameOf(s.asker), s.asker == me, secondsTo(s.endsAt), solved, total
    base.gameLeft, base.hints, base.asks = s.deadline and math.max(0, s.deadline - math.floor((GetGameTimer() - (s.deadlineAt or 0)) / 1000)) or nil, here.hints, here.asks
    return base
end

local function show()
    if not here.s then return end
    if not playing() and not near(cfg.WatchRange) then return Games.hideOverlay('games.whoami') end
    if Nui.isOpen('games.whoami') then return SendNUIMessage({ action = 'overlay', data = payload() }) end
    Games.overlay('games.whoami', payload())
end

local function openInput()
    if Nui.isOpen() then return end
    here.input = true
    Games.hideOverlay('games.whoami')
    Nui.open('games.whoami', payload(), false)
end

Nui.onClose('games.whoami', function()
    here.input = false
    show()
end)

RegisterNUICallback('whoami:guess', function(data, cb)
    local result = Games.call('whoami:guess', { text = type(data) == 'table' and data.text or nil })
    if not result.ok then Games.fail(result) elseif here.s and here.s.mode == 'classic' then here.guessed = true end
    cb(result)
    if Nui.isOpen('games.whoami') then Nui.close() end
end)

local function act(name, data)
    if busy then return end
    busy = true
    CreateThread(function()
        local result = Games.call('whoami:' .. name, data)
        busy = false
        if not result.ok then Games.fail(result) end
    end)
end

-- Headbands ----------------------------------------------------------------------------------------------------------

local function unband(id)
    local entity = here.bands[id]
    here.bands[id] = nil
    if entity and DoesEntityExist(entity) then DeleteEntity(entity) end
end

-- A headband on the player's head; again when the ped changed (a bot's ped may come late).
local function band(id)
    local ped, entity = Games.pedOf(id), here.bands[id]
    if entity and DoesEntityExist(entity) and ped and IsEntityAttachedToEntity(entity, ped) then return end
    unband(id)
    local b = cfg.Band
    local model = first(b.models)
    if not ped or not model or not pcall(lib.requestModel, joaat(model), 2000) then return end
    pcall(function() exports['FeloxAC']:CreateObject(joaat(model)) end) --[[FeloxAC:auto]]
    entity = CreateObject(joaat(model), 0.0, 0.0, 0.0, false, false, false)
    SetEntityCollision(entity, false, false)
    AttachEntityToEntity(entity, ped, GetPedBoneIndex(ped, b.bone), b.offset.x, b.offset.y, b.offset.z, b.rotation.x, b.rotation.y, b.rotation.z,
        true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(joaat(model))
    here.bands[id] = entity
end

local function unbandAll()
    for id in pairs(here.bands) do unband(id) end
end

-- Over the heads -----------------------------------------------------------------------------------------------------

local function text3d(at, text, color, scale)
    SetDrawOrigin(at.x, at.y, at.z, 0)
    SetTextScale(0.0, scale)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(color[1], color[2], color[3], 240)
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(plain(text))
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

local function drawLoop()
    if here.drawing then return end
    here.drawing = true
    local white, green, gold = { 255, 255, 255 }, { 120, 220, 140 }, { 240, 200, 70 }
    while here.s do
        local me, now, s = cache.serverId, GetGameTimer(), here.s
        if near(cfg.DrawRange) then
            local found = {}
            for _, row in ipairs(s.solved or {}) do found[row.id] = row.name end
            for id in pairs(here.players) do
                local ped = Games.pedOf(id)
                if ped then
                    local head = GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.0)
                    local name = found[id] or (id ~= me and here.names[id]) or nil
                    if name then text3d(head + vector3(0.0, 0.0, 0.34), name, found[id] and green or white, 0.42)
                    elseif id == me and playing() and s.mode == 'classic' then text3d(head + vector3(0.0, 0.0, 0.34), '?', gold, 0.5) end
                    local said = here.answers[id]
                    if said and now < said.untilMs then text3d(head + vector3(0.0, 0.0, 0.5), t('whoami.' .. said.value), COLORS[said.value], 0.5) end
                    if id == s.asker then
                        DrawMarker(2, head.x, head.y, head.z + 0.72, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.18, 0.18, 0.18, 240, 200, 70, 220, true, true, 2, false, nil, nil, false)
                    end
                end
            end
            Wait(0)
        else
            Wait(500)
        end
    end
    here.drawing = false
end

-- The game ------------------------------------------------------------------------------------------------------------

Seated.game('whoami_ring', {
    label = 'games.game_whoami', icon = 'fa-solid fa-user-secret', view = 'games.whoami', seats = cfg.Seats,
    line = function()
        local s = here.s
        if not s then return nil end
        if s.mode == 'race' then return t(s.phase == 'clues' and 'whoami.keys_race' or 'whoami.wait') end
        if not s.asker then return t('whoami.wait') end
        if s.asker == cache.serverId then return t(here.guessed and 'whoami.keys_turn_guessed' or 'whoami.keys_turn') end
        return t('whoami.keys_answer', nameOf(s.asker))
    end,
    frame = function()
        local s = here.s
        if not s then return end
        if s.mode == 'race' then
            if s.phase == 'clues' and IsControlJustPressed(0, 38) then openInput() end
            return
        end
        if not s.asker then return end
        if s.asker == cache.serverId then
            if IsControlJustPressed(0, 38) and not here.guessed then openInput()
            elseif IsControlJustPressed(0, 44) then act('done') end
        elseif IsControlJustPressed(0, 38) then act('answer', { value = 'yes' })
        elseif IsControlJustPressed(0, 44) then act('answer', { value = 'no' })
        elseif IsControlJustPressed(0, 74) then act('answer', { value = 'maybe' }) end
    end,
    props = function() return {} end,
})

Games.onScene('whoami', function(op, args, _, scene)
    local s, me = here.s, cache.serverId
    if op == 'start' or op == 'full' then
        local again = here.id == scene.id
        here.id, here.venue, here.s = scene.id, args.venue, args.scene or {}
        here.s.deadlineAt = GetGameTimer()
        if not again then here.names, here.hints, here.answers, here.asks, here.last, here.misses = {}, {}, {}, {}, nil, nil end
        here.players = {}
        for _, p in ipairs(args.players or {}) do
            here.players[p.id] = p
            band(p.id)
        end
        if args.mine then here.names, here.hints = args.mine.names or here.names, args.mine.hints or here.hints end
        CreateThread(drawLoop)
    elseif not s then
        return
    elseif op == 'names' then
        here.names = args
    elseif op == 'hint' then
        here.hints = args
        lib.notify({ description = args.letter and t('whoami.hint_letter', args.letter) or t('whoami.hint_category', t('whoami.cat_' .. args.category)) })
    elseif op == 'asker' then
        s.asker, s.endsAt, here.asks, here.guessed, here.answers = args.id, args.endsAt, {}, false, {}
        if args.id == me then
            sfx('bell')
            lib.notify({ description = t('whoami.your_turn') })
        end
    elseif op == 'answer' then
        here.answers[args.by] = { value = args.value, untilMs = GetGameTimer() + cfg.BubbleSeconds * 1000 }
        for i, row in ipairs(here.asks) do
            if row.id == args.by then table.remove(here.asks, i) break end
        end
        table.insert(here.asks, 1, { id = args.by, who = nameOf(args.by), value = args.value })
    elseif op == 'solved' then
        s.solved = s.solved or {}
        s.solved[#s.solved + 1] = { id = args.id, name = args.name, place = args.place }
        here.last = { who = nameOf(args.id), text = args.name, ok = true, me = args.id == me }
        sfx('ding')
        lib.notify({ description = args.id == me and t('whoami.you_found', args.name) or t('whoami.found', nameOf(args.id), args.name), type = 'success' })
    elseif op == 'wrong' then
        here.last = { who = nameOf(args.id), text = args.text, ok = false, me = args.id == me }
        sfx('wrong')
    elseif op == 'raceRound' then
        s.round, s.rounds, s.clues, s.phase, s.revealed, here.misses, here.last = args.round, args.rounds, {}, 'clues', nil, nil, nil
    elseif op == 'clue' then
        s.clues = s.clues or {}
        s.clues[args.n], s.clueEndsAt = args.text, args.endsAt
        sfx('clue')
    elseif op == 'miss' then
        here.misses = args.left
        sfx('wrong')
    elseif op == 'reveal' then
        s.phase, s.revealed, s.points = 'reveal', args.name, args.points or s.points
        here.last = args.by and { who = nameOf(args.by), text = args.name, ok = true, gained = args.gained, me = args.by == me } or { text = args.name, ok = false }
        sfx(args.by and 'ding' or 'wrong')
    elseif op == 'left' then
        here.players[args.id] = nil
        unband(args.id)
    elseif op == 'end' then
        local mine = args.summary and args.summary.reveal and args.summary.reveal[me]
        if mine and playing() then lib.notify({ description = t('whoami.you_were', mine) }) end
        unbandAll()
        here.id, here.venue, here.s, here.players, here.names = nil, nil, nil, {}, {}
        Games.hideOverlay('games.whoami')
        if Nui.isOpen('games.whoami') then Nui.close() end
        return
    end
    show()
end)

-- Headbands for peds that came late, a spectator walking up or away, and the clocks on screen between events.
CreateThread(function()
    while true do
        Wait(here.s and 2000 or 5000)
        if here.s then
            for id in pairs(here.players) do band(id) end
            show()
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then unbandAll() end
end)
