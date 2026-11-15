-- Taboo on the client: the card box, sand timer and buzzer on the table, the word card in the describer's hand, the
-- round's keys and the screen. Keys: the describer E Correct, Q Pass; the watcher E Taboo, Q Object (while a Correct
-- may still be objected to); the describing team E to type a guess. Everyone close sees the score; only the
-- describer and the watcher get the card.
local cfg = Config.Taboo
local t = DL.locale.t
local here = { id = nil, uid = nil, venue = nil, s = nil, card = nil, players = {}, feed = {}, flash = nil, input = false, round = 0 }
local held, flipped = nil, {} -- the word card in the describer's hand; sand timers turned over (by entity)
local busy = false

local function first(list)
    for _, name in ipairs(list or {}) do
        if IsModelInCdimage(joaat(name)) then return name end
    end
end

local function nameOf(id) return here.players[id] and here.players[id].name or '' end
local function teamOf(id) return here.players[id] and here.players[id].team or 0 end
local function playing() return here.id ~= nil and Games.lobby ~= nil and Games.lobby.id == here.id end

-- My part in this round: describer | watcher | guesser | rival | watching (not in the game).
local function role()
    local s, me = here.s, cache.serverId
    if not s or not playing() then return 'watching' end
    if me == s.describer then return 'describer' end
    if me == s.watcher then return 'watcher' end
    return teamOf(me) == s.team and 'guesser' or 'rival'
end

local function objectable()
    local c = here.s and here.s.claim
    return c ~= nil and Games.serverNow() < c.untilMs
end

-- Sounds from the page, quieter for those watching from further away.
local function sfx(name)
    local v, volume = here.venue, 1.0
    if v and not playing() then volume = math.max(0.0, 1.0 - #(GetEntityCoords(cache.ped) - vector3(v.x, v.y, v.z)) / cfg.WatchRange) end
    if volume > 0.05 then SendNUIMessage({ action = 'sfx', name = name, volume = volume }) end
end

-- The screen --------------------------------------------------------------------------------------------------------

local function payload()
    local s, r = here.s, role()
    local inRound = s.phase == 'round'
    return {
        role = r, team = s.team, mine = teamOf(cache.serverId), score = s.score, turns = s.turns, rounds = s.rounds, target = s.target,
        phase = s.phase, left = inRound and s.endsAt and math.max(0, math.ceil((s.endsAt - Games.serverNow()) / 1000)) or nil,
        passes = s.passes, describer = nameOf(s.describer), watcher = nameOf(s.watcher),
        card = inRound and (r == 'describer' or r == 'watcher') and here.card or nil,
        claim = objectable() and math.ceil((s.claim.untilMs - Games.serverNow()) / 1000) or nil,
        feed = here.feed, flash = here.flash, input = here.input,
    }
end

local function show()
    if not here.s then return end
    local v = here.venue
    if not playing() and v and #(GetEntityCoords(cache.ped) - vector3(v.x, v.y, v.z)) > cfg.WatchRange then return Games.hideOverlay('games.taboo') end
    if Nui.isOpen('games.taboo') then return SendNUIMessage({ action = 'overlay', data = payload() }) end
    Games.overlay('games.taboo', payload())
end

local function flash(kind)
    here.flash = { kind = kind, n = (here.flash and here.flash.n or 0) + 1 }
end

local function feed(entry)
    here.lines = (here.lines or 0) + 1
    entry.n = here.lines
    table.insert(here.feed, 1, entry)
    if #here.feed > cfg.Feed then here.feed[#here.feed] = nil end
end

-- The guess box: the same view with the keys taken; Enter sends and closes it, Esc only closes it.
local function openInput()
    if Nui.isOpen() then return end
    here.input = true
    Games.hideOverlay('games.taboo')
    Nui.open('games.taboo', payload(), false)
end

Nui.onClose('games.taboo', function()
    here.input = false
    show()
end)

RegisterNUICallback('taboo:guess', function(data, cb)
    local result = Games.call('taboo:guess', { text = type(data) == 'table' and data.text or nil })
    if not result.ok then Games.fail(result) end
    cb(result)
    if Nui.isOpen('games.taboo') then Nui.close() end
end)

local function act(name)
    if busy then return end
    busy = true
    CreateThread(function()
        local result = Games.call('taboo:' .. name)
        busy = false
        if not result.ok then Games.fail(result) end
    end)
end

-- Props and moves ---------------------------------------------------------------------------------------------------

-- A move over the sit, for my own ped and my test bots (others see theirs through the network).
local function anim(id, which)
    local ped = id == cache.serverId and cache.ped or Games.myBot(id)
    local a = cfg.Anim[which]
    if not ped or not a then return end
    local clip = type(a.clip) == 'table' and a.clip[math.random(#a.clip)] or a.clip
    if lib.requestAnimDict(a.dict, 2000) then TaskPlayAnim(ped, a.dict, clip, 4.0, 4.0, a.ms or 2000, 48, 0.0, false, false, false) end
end

-- The describer talks with their hands now and then all round.
local function talk(id)
    local round = here.round
    CreateThread(function()
        while here.round == round and here.s and here.s.phase == 'round' and here.s.describer == id do
            anim(id, 'talk')
            Wait(math.random(4000, 7000))
        end
    end)
end

local function drop()
    if held and DoesEntityExist(held) then DeleteEntity(held) end
    held = nil
end

-- The word card goes into the describer's hand (every client near attaches its own).
local function hold(id)
    drop()
    local c = cfg.Card
    local ped, model = id and Games.pedOf(id), first({ c.model })
    if not ped or not model or not pcall(lib.requestModel, joaat(model), 2000) then return end
    pcall(function() exports['FeloxAC']:CreateObject(joaat(model)) end) --[[FeloxAC:auto]]
    held = CreateObject(joaat(model), 0.0, 0.0, 0.0, false, false, false)
    SetEntityCollision(held, false, false)
    AttachEntityToEntity(held, ped, GetPedBoneIndex(ped, c.bone), c.offset.x, c.offset.y, c.offset.z, c.rotation.x, c.rotation.y, c.rotation.z,
        true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(joaat(model))
end

-- The sand timer turns over at every round: lifted as it turns so it lands on its other end.
local function turnTimer()
    local timer = here.uid and Seated.prop(here.uid, 'timer')
    if not timer or not DoesEntityExist(timer) then return end
    local min, max = GetModelDimensions(GetEntityModel(timer))
    local height, base, heading = max.z - min.z, GetEntityCoords(timer), GetEntityHeading(timer)
    local up = flipped[timer]
    flipped[timer] = not up
    local floor = up and base.z - height or base.z
    CreateThread(function()
        local start = GetGameTimer()
        while true do
            local k = math.min((GetGameTimer() - start) / 600, 1.0)
            local turn = up and 1.0 - k or k
            SetEntityCoordsNoOffset(timer, base.x, base.y, floor + height * turn, false, false, false)
            SetEntityRotation(timer, 180.0 * turn, 0.0, heading, 2, false)
            if k >= 1.0 or not DoesEntityExist(timer) then break end
            Wait(0)
        end
    end)
end

-- The buzzer is pressed: its down model for a moment.
local function press()
    local buzzer, down = here.uid and Seated.prop(here.uid, 'buzzer'), first({ cfg.Props.buzzer.down })
    if not buzzer or not DoesEntityExist(buzzer) or not down or not pcall(lib.requestModel, joaat(down), 1000) then return end
    local p = GetEntityCoords(buzzer)
    pcall(function() exports['FeloxAC']:CreateObject(joaat(down)) end) --[[FeloxAC:auto]]
    local pressed = CreateObjectNoOffset(joaat(down), p.x, p.y, p.z, false, false, false)
    SetEntityHeading(pressed, GetEntityHeading(buzzer))
    FreezeEntityPosition(pressed, true)
    SetModelAsNoLongerNeeded(joaat(down))
    SetEntityVisible(buzzer, false, false)
    SetTimeout(600, function()
        if DoesEntityExist(pressed) then DeleteEntity(pressed) end
        if DoesEntityExist(buzzer) then SetEntityVisible(buzzer, true, false) end
    end)
end

-- The describing team claps a word they got (me and my test bots in it).
local function clap()
    local s = here.s
    for id, p in pairs(here.players) do
        if p.team == s.team and id ~= s.describer and (id == cache.serverId or Games.myBot(id)) then anim(id, 'clap') end
    end
end

-- The game ------------------------------------------------------------------------------------------------------------

Seated.game('taboo_table', {
    label = 'games.game_taboo', icon = 'fa-solid fa-comment-slash', view = 'games.taboo', seats = cfg.Seats,
    line = function()
        local s, r = here.s, role()
        if not s or s.phase ~= 'round' then return t('taboo.wait') end
        if r == 'describer' then return t('taboo.keys_describer', s.passes or 0) end
        if r == 'watcher' then return t(objectable() and 'taboo.keys_watcher_claim' or 'taboo.keys_watcher') end
        return t(r == 'guesser' and 'taboo.keys_guesser' or 'taboo.keys_rival')
    end,
    frame = function()
        local s = here.s
        if not s or s.phase ~= 'round' then return end
        local r = role()
        if IsControlJustPressed(0, 38) then
            if r == 'describer' then act('claim') elseif r == 'watcher' then act('buzz') elseif r == 'guesser' then openInput() end
        elseif IsControlJustPressed(0, 44) then
            if r == 'describer' then act('pass') elseif r == 'watcher' and objectable() then act('object') end
        end
    end,
    -- The card box in the middle, the sand timer and the buzzer either side (an item's box already marks the spot).
    props = function(record, top)
        local c, out = record.coords, {}
        local w = math.rad(c.w or 0.0)
        for key, p in pairs(cfg.Props) do
            local model = first(p.models)
            if model and not (key == 'box' and record.portable) then
                out[#out + 1] = { model = model, x = c.x + math.cos(w) * p.along, y = c.y + math.sin(w) * p.along, z = c.z + top, h = (c.w or 0.0) + (p.turn or 0.0), key = key }
            end
        end
        return out
    end,
})

Games.onScene('taboo', function(op, args, _, scene)
    local s = here.s
    if op == 'start' or op == 'full' then
        local again = here.id == scene.id
        here.id, here.uid, here.venue, here.s = scene.id, args.venue.uid, args.venue, args.scene or {}
        if not again then here.feed, here.card = {}, nil end
        here.players = {}
        for _, p in ipairs(args.players or {}) do here.players[p.id] = p end
        if args.mine and args.mine.card then here.card = args.mine.card end
        if here.s.phase == 'round' then hold(here.s.describer) end
    elseif not s then
        return
    elseif op == 'round' then
        s.team, s.describer, s.watcher, s.endsAt, s.passes, s.turns = args.team, args.describer, args.watcher, args.endsAt, args.passes, args.turns
        s.phase, s.claim, here.card, here.round = 'round', nil, nil, here.round + 1
        hold(args.describer)
        turnTimer()
        sfx('bell')
        if playing() then
            lib.notify({ description = t('taboo.round_start', t('taboo.team_' .. args.team), nameOf(args.describer), nameOf(args.watcher)) })
        end
        if args.describer == cache.serverId or Games.myBot(args.describer) then talk(args.describer) end
    elseif op == 'card' then
        here.card = args
    elseif op == 'point' then
        s.score = args.score
        if args.why == 'taboo' then
            flash('taboo')
            sfx('buzz')
            press()
            anim(args.by, 'buzz')
            feed({ text = args.word, kind = 'taboo' })
        elseif args.why ~= 'pass' then
            flash('right')
            sfx('ding')
            clap()
            feed({ text = args.word, by = args.why == 'guess' and nameOf(args.by) or nil, kind = 'right' })
        end
    elseif op == 'claim' then
        s.claim = { id = args.id, untilMs = args.untilMs }
        SetTimeout(math.max(0, args.untilMs - Games.serverNow()) + 100, function() if here.s == s then show() end end)
    elseif op == 'objected' then
        s.score, s.claim = args.score, nil
        flash('objected')
        sfx('wrong')
        feed({ text = args.word, kind = 'objected' })
        if playing() then lib.notify({ description = t('taboo.objected', nameOf(args.by)), type = 'error' }) end
    elseif op == 'pass' then
        s.passes = args.passes
        flash('pass')
        sfx('pass')
        feed({ text = args.word, kind = 'pass' })
    elseif op == 'guess' then
        feed({ text = args.text, by = nameOf(args.by), kind = 'guess' })
    elseif op == 'watcher' then
        s.watcher = args.id
    elseif op == 'roundEnd' then
        s.phase, s.score, s.claim, here.card = 'break', args.score, nil, nil
        drop()
        sfx('bell')
    elseif op == 'end' then
        drop()
        here.id, here.uid, here.venue, here.s, here.card, here.feed, flipped = nil, nil, nil, nil, nil, {}, {}
        Games.hideOverlay('games.taboo')
        if Nui.isOpen('games.taboo') then Nui.close() end
        return
    end
    show()
end)

-- The clock on screen counts by itself; this only catches a spectator walking up or away.
CreateThread(function()
    while true do
        Wait(here.s and 2000 or 5000)
        if here.s and not playing() then show() end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then drop() end
end)
