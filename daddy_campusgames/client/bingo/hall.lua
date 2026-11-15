-- Bingo nights in the halls (bingo_hall zones): which hall the player stands in, the night the server sends there,
-- the card overlay, the marks and the sounds. E takes a card or shows the cards with the mouse (the host draws with E
-- when holding none); H pauses. The page and the keys only ask: the server checks the hall, the cards and the marks.
local cfg = Config.Bingo
local t = DL.locale.t
local Rules = GameRules.bingo
BingoHall = { state = {} } -- state[hall] = the night as the server last sent it (NightPublic), draws added here

local LEFT = { 'countdown', 'nextIn', 'windowLeft', 'announceLeft' } -- a game's counters (seconds left)
local REFUSED = { bingo_not_done = 'wrong', bingo_unmarked = 'unmarked', bingo_locked = 'locked', bingo_late = 'late', bingo_blocked = 'wrong' }
local NEXT_AFTER = 2000 -- the host's E goes on from the winners only once they have been up this long (ms)
local FREE = { 1, 2, 24, 25, 37, 44, 140, 141, 142, 199, 200, 257, 263 } -- kept from the game while the cards have the mouse

local halls, byUid = {}, {}                                -- bingo_hall zones: { uid, label, shape }
local lives = GlobalState['daddy_campusgames:bingo'] or {} -- halls with a night on (the server's summary)
local nights, entered, entering, retry = {}, {}, {}, {}    -- per hall: kept here; counted in; asking; next try (ms)
local here, shown, busy, flashes, mouse = nil, false, false, 0, false

Games.world.subscribe(function()
    halls, byUid = {}, {}
    for _, zone in ipairs(Games.world.zones({ kind = 'bingo_hall' })) do
        local hall = { uid = zone.uid, label = zone.label, shape = DL.geo.fromRecord(zone) }
        halls[#halls + 1], byUid[zone.uid] = hall, hall
    end
end)

AddStateBagChangeHandler('daddy_campusgames:bingo', 'global', function(_, _, value) lives = value or {} end)

-- The hall a point stands in, with the margin the server allows.
local function hallOf(x, y, z)
    for _, hall in ipairs(halls) do
        if DL.geo.distance(hall.shape, x, y, z) <= cfg.Hall.Margin then return hall.uid end
    end
end

function BingoHall.here()
    local c = GetEntityCoords(cache.ped)
    return hallOf(c.x, c.y, c.z)
end

-- A board's hall: the one it stands in, else the nearest within 40 m.
function BingoHall.hallAt(x, y, z)
    local best, near = nil, 40.0
    for _, hall in ipairs(halls) do
        local d = DL.geo.distance(hall.shape, x, y, z)
        if d < near then best, near = hall.uid, d end
    end
    return best
end

local function live(hall)
    local night = BingoHall.state[hall]
    return night ~= nil and night.state ~= 'ended'
end

-- The hall the player is in, counted in by the server, with a night on.
function BingoHall.inside()
    if here and entered[here] and live(here) then return here end
end

-- What this client keeps of a hall's night: my cards and marks, the numbers drawn, when the counters run out, effects.
local function keep(hall)
    nights[hall] = nights[hall] or { set = {}, marks = {}, ends = {} }
    return nights[hall]
end

local function forget(hall)
    nights[hall], BingoHall.state[hall] = nil, nil
end

-- A card holder plays (a host on a test night too); a host with no cards draws; the rest watch.
local function roleOf(h, night)
    if h.mine and h.mine.cards and #h.mine.cards > 0 then return 'player' end
    if night.host and night.host.id == cache.serverId then return 'host' end
    return 'watcher'
end

local function hosting(night) return night.host and night.host.id == cache.serverId end

local function rebuild(h, night)
    h.set = {}
    for _, n in ipairs(night and night.game and night.game.drawn or {}) do h.set[n] = true end
end

-- Sounds from the page, only in the hall itself.
local function sfx(hall, name)
    if hall == here and entered[hall] then SendNUIMessage({ action = 'sfx', name = name, volume = 1.0 }) end
end

-- A one-shot effect on the card (the page plays each n once); it leaves the payload after a few seconds.
local function flash(h, kind, fields)
    flashes = flashes + 1
    fields = fields or {}
    fields.kind, fields.n = kind, flashes
    h.flash, h.flashTill = fields, GetGameTimer() + 6000
end

-- The counters as seconds left now (the server sent seconds left at the moment it sent them).
local function timed(h, night)
    local game, now = night.game, GetGameTimer()
    if not game then return end
    for _, key in ipairs(LEFT) do
        local ends = h.ends[key]
        game[key] = ends and math.max(0, math.ceil((ends - now) / 1000)) or nil
    end
end

-- The numbers I marked on a card, as a list (with AutoDaub: every number drawn on it).
local function marksOf(h, card)
    local out, mine = {}, h.marks[card.id] or {}
    for _, row in ipairs(card.rows) do
        for _, n in ipairs(row) do
            if n ~= 0 and h.set[n] and (cfg.AutoDaub or mine[n]) then out[#out + 1] = n end
        end
    end
    return out
end

-- The overlay's payload (BingoView): the host's strip, a player's cards or a watcher's take prompt.
local function overlay(h, night)
    local role, game, mine, now = roleOf(h, night), night.game, h.mine or {}, GetGameTimer()
    timed(h, night)
    local cards, goal, near, ready = {}, game and game.goal, {}, false
    for k, card in ipairs(role == 'player' and mine.cards or {}) do
        cards[k] = { id = card.id, kind = 'bingo', rows = card.rows, marks = marksOf(h, card) }
        local need = goal and night.state ~= 'selling' and Rules.need(card.rows, h.set, goal)
        if need == 1 and BingoShow.near() then near[#near + 1] = card.id elseif need == 0 then ready = true end
    end
    local selling = night.state == 'selling'
    local intro
    if night.state == 'countdown' and night.gameNo == 1 and h.countdownAt and now - h.countdownAt < BingoShow.introMs() then
        local pool, first = 0, night.program and night.program[1]
        for _, g in ipairs(night.program or {}) do
            for _, amount in pairs(g.prizes or {}) do pool = pool + amount end
        end
        intro = { games = night.total, pool = pool, host = night.host and night.host.name, goal = first and first.goals and first.goals[1] }
    end
    return {
        mode = 'hall', role = role, label = night.label, state = night.state, gameNo = night.gameNo, total = night.total,
        game = game, cards = cards, max = mine.max or 1, open = mouse, autoDaub = cfg.AutoDaub == true,
        canTake = role == 'watcher' and selling, canMore = role == 'player' and selling and #cards < (mine.max or 1),
        claimed = mine.claimed == true, blocked = mine.blocked == true, locked = h.lockEnds and math.max(0, math.ceil((h.lockEnds - now) / 1000)) or 0,
        host = night.host and night.host.name, say = night.say, hosting = hosting(night),
        keys = { main = 'E', pause = hosting(night) and 'H' or nil },
        flash = now < (h.flashTill or 0) and h.flash or nil,
        near = near, ready = ready, intro = intro, scene = BingoShow.view(),
    }
end

-- The cards with the mouse ----------------------------------------------------------------------------------------

local function mouseOff()
    if not mouse then return end
    mouse = false
    BingoShow.cards(false)
    SetNuiFocusKeepInput(false)
    if not Nui.isOpen() then DL.focus.release() end
end

-- The mouse goes to the cards; the game keeps the keys (push-to-talk, walking), not the camera or the weapons.
local function mouseOn()
    if mouse or Nui.isOpen() or BingoShow.watching() then return end
    mouse = true
    BingoShow.cards(true, here)
    DL.focus.acquire(function() mouse = false SetNuiFocusKeepInput(false) BingoHall.show(true) end)
    SetNuiFocusKeepInput(true)
    CreateThread(function()
        while mouse do
            for _, control in ipairs(FREE) do DisableControlAction(0, control, true) end
            if IsDisabledControlJustPressed(0, 200) or Nui.isOpen() or not BingoHall.inside() or IsEntityDead(cache.ped) then
                mouseOff()
                BingoHall.show(true)
            end
            Wait(0)
        end
    end)
end

-- The overlay of the hall I stand in: the host's strip and a player's cards all night, a watcher's take prompt while
-- cards are handed out. force: send it even when nothing changed here (a new state, a draw).
function BingoHall.show(force)
    local hall = here
    local outro = BingoShow.outroView()
    if outro and not (hall and live(hall)) then
        mouseOff()
        shown = true
        return Games.overlay('games.bingo', { mode = 'outro', role = 'watcher', outro = outro, cards = {}, keys = { main = 'E' } })
    end
    local h, night = hall and nights[hall], hall and BingoHall.state[hall]
    local visible = h and night and entered[hall] and live(hall) and not Games.lobby
        and (roleOf(h, night) ~= 'watcher' or night.state == 'selling')
    if not visible or roleOf(h, night) ~= 'player' then mouseOff() end
    if not visible then
        if shown then Games.hideOverlay('games.bingo') end
        shown = false
        return
    end
    if shown and not force then return end
    shown = true
    Games.overlay('games.bingo', overlay(h, night))
end

-- The cards down (a scene starts, a winner celebrates).
function BingoHall.away()
    mouseOff()
    BingoHall.show(true)
end

-- A whole night from the server. complete: the answer to enter, whose mine is the whole truth (a state message may
-- leave mine out; it drops with a new game).
local function setState(hall, night, sent, complete)
    local h, old = keep(hall), BingoHall.state[hall]
    local game = night.game
    if game then game.drawn = game.drawn or {} end
    if complete or night.mine then
        h.mine = night.mine
    elseif h.mineGame and h.mineGame ~= night.gameNo then
        h.mine = nil
    end
    if h.mineGame ~= night.gameNo then h.marks, h.lockEnds = {}, nil end
    h.mineGame = h.mine and night.gameNo or nil
    if h.mine and h.mine.locked then h.lockEnds = sent + h.mine.locked * 1000 end
    if old and old.gameNo ~= night.gameNo then flash(h, 'game') end
    if night.state == 'announce' and not (old and old.state == 'announce') then h.announceAt = GetGameTimer() end
    if night.state == 'countdown' and not (old and old.state == 'countdown' and old.gameNo == night.gameNo) then h.countdownAt = GetGameTimer() end
    for _, key in ipairs(LEFT) do h.ends[key] = game and game[key] and sent + game[key] * 1000 or nil end
    h.rev, night.mine = night.rev or h.rev, nil
    BingoHall.state[hall] = night
    rebuild(h, night)
end

-- After every change: my overlay, the board and the host's panel.
local function changed(hall)
    if hall == here then BingoHall.show(true) end
    if BingoBoard then BingoBoard.push(hall, BingoHall.state[hall]) end
    if BingoHost then BingoHost.changed(hall) end
end

-- In the hall: the server counts me in and answers the whole night (none when it is over).
local function enter(hall)
    local result = Games.call('bingo:enter', { hall = hall })
    local state = result.ok and result.state or nil
    if not state then
        if result.ok then forget(hall) end
        retry[hall] = GetGameTimer() + 3000
        return changed(hall)
    end
    local h = keep(hall)
    h.seen = GetGameTimer()
    if not (h.rev and (state.rev or 0) < h.rev) then
        state.mine = result.mine
        setState(hall, state, GetGameTimer(), true)
    end
    entered[hall] = true
    changed(hall)
end

-- A step missed: the whole night again, a moment later so a full hall does not ask at once.
local function refetch(hall)
    if entering[hall] or not entered[hall] then return end
    entering[hall] = true
    CreateThread(function()
        Wait(math.random(100, 1200))
        if entered[hall] then enter(hall) end
        entering[hall] = nil
    end)
end

local function leave(hall)
    entered[hall] = nil
    local h, night = nights[hall], BingoHall.state[hall]
    -- a host or a card holder keeps hearing the night; a watcher lets go of it
    if not (h and night and (roleOf(h, night) ~= 'watcher' or hosting(night))) then forget(hall) end
    CreateThread(function() Games.call('bingo:leave', { hall = hall }) end)
end

-- The moment a message left the server, on this client's clock (at most a second back).
local function sentAt(at)
    local now = GetGameTimer()
    if type(at) ~= 'number' then return now end
    return math.max(now - 1000, math.min(Games.localTime(at), now))
end

-- A number drawn: on the list and the ball. A missed draw: the whole night again.
local function drew(hall, h, night, args, sent)
    local game = night.game
    if not game or type(args.n) ~= 'number' then return end
    local i = #game.drawn + 1
    if args.i and args.i > i then return refetch(hall) end
    if args.i and args.i < i then return end
    game.drawn[i], game.last, game.count, game.close = args.n, args.n, i, args.close or game.close
    h.set[args.n] = true
    h.ends.nextIn = args.nextIn and sent + args.nextIn * 1000 or nil
    sfx(hall, 'ball')
    if not (game.goal and h.mine and BingoShow.near()) then return end
    h.nearSeen = h.nearSeen or {}
    for _, card in ipairs(h.mine.cards or {}) do
        local key = card.id .. game.goal
        if not h.nearSeen[key] and Rules.need(card.rows, h.set, game.goal) == 1 then
            h.nearSeen[key] = true
            SetTimeout(450, function() sfx(hall, 'near') end)
            return
        end
    end
end

-- A prize won: the names on the card and the board, the cheer, and a word to a winner.
local function won(hall, h, night, args)
    local names, list, amount = {}, {}, 0
    for k, w in ipairs(args.winners or {}) do
        names[k], list[k], amount = w.name, { name = w.name, amount = w.amount or 0 }, w.amount or amount
        if w.id == cache.serverId then Nui.notify('bingo.won_you', 'success', w.amount or 0) end
    end
    if night.game and args.goal then
        night.game.winners = night.game.winners or {}
        night.game.winners[args.goal] = list
    end
    flash(h, 'won', { goal = args.goal, names = names, amount = amount })
    h.banner, h.bannerTill = { goal = args.goal, names = names, amount = amount, n = flashes, gameNo = args.gameNo }, GetGameTimer() + 8000
    sfx(hall, 'bingo')
    BingoShow.won(args.winners, hall == here)
end

-- The night is over for me (it ended, or the host took me out). Still in the hall: the next enter tells what is left.
local function gone(hall, args)
    local key = 'bingo.gone_' .. tostring(args.reason or '')
    if t(key) == key then key = 'bingo.gone' end
    Nui.notify(key, 'inform')
    if args.summary then BingoShow.outro(args.summary) end
    forget(hall)
    entered[hall], retry[hall] = nil, nil
    changed(hall)
end

-- { hall, op, rev, args, at }: state is the whole night; draw and won are steps (a rev gap asks again); missed and
-- gone are mine alone.
RegisterNetEvent('daddy_campusgames:bingo', function(message)
    if type(message) ~= 'table' or type(message.hall) ~= 'string' then return end
    local hall, op, args = message.hall, message.op, type(message.args) == 'table' and message.args or {}
    if op == 'gone' then return gone(hall, args) end
    if op == 'scene' then return BingoShow.scene(args) end
    local h, night, sent = keep(hall), BingoHall.state[hall], sentAt(message.at)
    h.seen = GetGameTimer()
    if op == 'state' then
        if h.rev and (message.rev or 0) < h.rev then return end
        setState(hall, args, sent)
        h.rev = message.rev or h.rev
    elseif op == 'missed' then
        flash(h, 'missed', { goal = args.goal })
    elseif not night then
        return refetch(hall)
    else
        if h.rev and (message.rev or 0) > h.rev + 1 then refetch(hall) end
        h.rev = math.max(h.rev or 0, message.rev or 0)
        if op == 'draw' then drew(hall, h, night, args, sent) elseif op == 'won' then won(hall, h, night, args) end
    end
    changed(hall)
end)

-- Keys and the page ---------------------------------------------------------------------------------------------------

-- The server's answer: a BINGO stands or is turned down (wrong, not marked, locked), or a card taken.
local function answer(hall, name, result)
    local refused = name == 'claim' and REFUSED[result.error]
    if not result.ok and not refused then return Games.fail(result) end
    local h, night = nights[hall], BingoHall.state[hall]
    if not h or not night then return end
    if refused then
        if h.mine then h.mine.blocked = result.blocked == true or h.mine.blocked end
        if tonumber(result.locked) then h.lockEnds = GetGameTimer() + result.locked * 1000 end
        flash(h, refused)
        sfx(hall, 'wrong')
    elseif name == 'claim' then
        if h.mine then h.mine.claimed = true end
        flash(h, 'claimed', { goal = result.goal })
    elseif name == 'take' and type(result.mine) == 'table' then
        h.mine, h.mineGame = result.mine, night.gameNo
        mouseOn()
    end
    changed(hall)
end

local function act(hall, name, data)
    if busy then return end
    busy = true
    data = data or {}
    data.hall = hall
    CreateThread(function()
        local result = Games.call('bingo:' .. name, data)
        busy = false
        answer(hall, name, result)
    end)
end

-- E: a watcher takes a card while they are handed out; a player shows or hides the cards; a host with no cards draws
-- (or, once the winners have been up a moment, goes on).
local function press(hall)
    local h, night = nights[hall], BingoHall.state[hall]
    if busy or not h or not night then return end
    local role, state = roleOf(h, night), night.state
    if role == 'player' then
        if mouse then mouseOff() else mouseOn() end
        BingoHall.show(true)
    elseif role == 'host' then
        if state == 'running' then
            act(hall, 'draw')
        elseif state == 'announce' and GetGameTimer() - (h.announceAt or 0) >= NEXT_AFTER then
            act(hall, 'next')
        end
    elseif state == 'selling' then
        act(hall, 'take')
    end
end

-- H: the host pauses the night or goes on with it.
local function pause(hall)
    local night = BingoHall.state[hall]
    if busy or not night or not hosting(night) then return end
    local state = night.state
    if state == 'paused' then
        act(hall, 'pause', { on = false })
    elseif state == 'running' or state == 'countdown' or state == 'window' or state == 'announce' then
        act(hall, 'pause', { on = true })
    end
end

-- The page: a number marked (only one drawn), one more card, BINGO, the cards put away.
RegisterNUICallback('bingo:daub', function(data, cb)
    cb({ ok = true })
    local hall = BingoHall.inside()
    local h = hall and nights[hall]
    local n, id = tonumber(data.n), tostring(data.card or '')
    if not h or not h.mine or not n or not h.set[n] then return end
    for _, card in ipairs(h.mine.cards or {}) do
        if card.id == id then
            h.marks[id] = h.marks[id] or {}
            h.marks[id][n] = not h.marks[id][n] or nil
            if h.marks[id][n] then BingoShow.write() end
            return BingoHall.show(true)
        end
    end
end)

RegisterNUICallback('bingo:more', function(_, cb)
    cb({ ok = true })
    local hall = BingoHall.inside()
    if hall then act(hall, 'take') end
end)

RegisterNUICallback('bingo:call', function(_, cb)
    cb({ ok = true })
    local hall = BingoHall.inside()
    local h = hall and nights[hall]
    if not h or not h.mine or h.mine.claimed then return end
    local marks = {}
    for _, card in ipairs(h.mine.cards or {}) do marks[card.id] = marksOf(h, card) end
    act(hall, 'claim', { marks = marks })
end)

RegisterNUICallback('bingo:hide', function(_, cb)
    cb({ ok = true })
    mouseOff()
    BingoHall.show(true)
end)

-- The keys run every frame only in a hall with a night on and no view open (with the cards up as well).
CreateThread(function()
    while true do
        local hall = BingoHall.inside()
        if hall and not Nui.isOpen() and not Games.lobby then
            if IsControlJustPressed(0, 38) or (mouse and IsDisabledControlJustPressed(0, 38)) then
                press(hall)
            elseif IsControlJustPressed(0, 74) then
                pause(hall)
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- Which hall I am in: in and out with the server, the overlay kept up (counters each second); slower with no night.
CreateThread(function()
    local open = false
    while true do
        local c, now = GetEntityCoords(cache.ped), GetGameTimer()
        here = hallOf(c.x, c.y, c.z)
        for hall in pairs(entered) do
            if hall ~= here then leave(hall) end
        end
        for hall, h in pairs(nights) do
            if not lives[hall] and now - (h.seen or 0) > 3000 then
                forget(hall)
                entered[hall] = nil
                changed(hall)
            end
        end
        local hall = here
        if hall and lives[hall] and not entered[hall] and not entering[hall] and now >= (retry[hall] or 0) then
            entering[hall] = true
            CreateThread(function()
                enter(hall)
                entering[hall] = nil
            end)
        end
        local near = false
        for _, zone in ipairs(halls) do
            if lives[zone.uid] and DL.geo.distance(zone.shape, c.x, c.y, c.z) < Config.StreamDistance then near = true break end
        end
        local was = open
        open = Nui.isOpen()
        BingoHall.show(was and not open or (hall ~= nil and entered[hall] ~= nil))
        Wait(near and 500 or 2000)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource and mouse then SetNuiFocusKeepInput(false) end
end)

-- For the board and the panel ---------------------------------------------------------------------------------------

-- The board's data (BoardData): the night without the host's part, counters as now, a fresh win as a banner.
function BingoHall.board(hall)
    local h, night = nights[hall], BingoHall.state[hall]
    local on = h ~= nil and night ~= nil and night.state ~= 'ended'
    local public
    if on then
        timed(h, night)
        public = {}
        for key, value in pairs(night) do
            if key ~= 'hostView' then public[key] = value end
        end
    end
    return {
        idle = not on, label = night and night.label or (byUid[hall] and byUid[hall].label) or '', night = public,
        banner = on and GetGameTimer() < (h.bannerTill or 0) and h.banner or nil, accent = Config.Theme.accent,
    }
end

-- The night for the host's panel (with the host's part), counters as now; nil when none is on.
function BingoHall.night(hall)
    local h, night = nights[hall], BingoHall.state[hall]
    if not h or not night then return nil end
    timed(h, night)
    return night
end
