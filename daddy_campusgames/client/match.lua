-- Matches on the client: the lobby sheet, the server's clock and the scene of every game near the player.
-- Each game listens with Games.onScene(game, fn(op, args, message, scene)); scene is that match's state here.
local t = DL.locale.t
Games.lobby, Games.scenes = nil, {}
local handlers, offset, synced = {}, 0, false

-- Server time in ms, for spins, putts and countdowns that run at the same moment everywhere.
function Games.serverNow() return GetGameTimer() + offset end

-- The local time (GetGameTimer) a moment of the server's clock falls on here. A start never waits more than a
-- second, and with no clock yet it is now, so a clock that is off can never hold a spin or a putt back.
function Games.localTime(at)
    if not synced then return GetGameTimer() end
    return GetGameTimer() + math.min(at - Games.serverNow(), 1000)
end

-- The clock: asked until the server answers (after a restart it may still be starting), then every few minutes.
local function measure()
    local best
    for _ = 1, 5 do
        local sent = GetGameTimer()
        local result = lib.callback.await('daddy_campusgames:clock', false, {})
        local back = GetGameTimer()
        if type(result) == 'table' and result.now then
            local trip = back - sent
            if not best or trip < best.trip then best = { trip = trip, offset = result.now + trip / 2 - back } end
        end
        Wait(150)
    end
    if best then offset, synced = math.floor(best.offset), true end
    return best ~= nil
end

CreateThread(function()
    while true do Wait(measure() and 300000 or 2000) end
end)

function Games.onScene(game, fn) handlers[game] = fn end

-- Lobby ---------------------------------------------------------------------------------------------------

function Games.openLobby()
    local result = Games.call('lobby:view')
    if not result.ok then return Games.fail(result) end
    Nui.open('games.lobby', result.lobby)
end

-- The server's sheet of my match (nil once I am out). Scenes of other matches go: a player only sees their own game,
-- and a game they left lets go of them (keys, weapons, props).
RegisterNetEvent('daddy_campusgames:lobby', function(view)
    local was = Games.lobby
    Games.lobby = view
    Games.dropScenes(view and view.id)
    if Nui.isOpen('games.lobby') then
        if view and view.state == 'lobby' then Nui.send('lobby', view) else Nui.close() end
    elseif view and not was and view.game ~= 'bottle' then
        Nui.notify('games.lobby_joined', 'success')
    end
end)

for _, action in ipairs({ 'leave', 'ready', 'team', 'balance', 'mode', 'kick', 'start' }) do
    RegisterNUICallback('lobby:' .. action, function(data, cb)
        local result = Games.call('lobby:' .. action, data)
        if not result.ok then Games.fail(result) end
        cb(result)
    end)
end

-- The options a game place offers: open a game, join one, or look at your lobby.
function Games.venueOptions(record, icon)
    local function at() return (GlobalState['daddy_campusgames:venues'] or {})[record.uid] end
    return {
        { name = 'games_open', label = t('games.open_game'), icon = icon,
            canInteract = function() return Games.free() and not Games.lobby and not at() end,
            onSelect = function() CreateThread(function()
                local result = Games.call('lobby:open', { venue = record.uid })
                if not result.ok then return Games.fail(result) end
                Nui.open('games.lobby', result.lobby)
            end) end },
        { name = 'games_join', label = t('games.join_game'), icon = 'fa-solid fa-user-plus',
            canInteract = function()
                local busy = at()
                return Games.free() and not Games.lobby and busy ~= nil and busy.count < busy.max
            end,
            onSelect = function() CreateThread(function()
                local result = Games.call('lobby:join', { venue = record.uid })
                if not result.ok then return Games.fail(result) end
                if result.lobby.state == 'lobby' then Nui.open('games.lobby', result.lobby) end
            end) end },
        { name = 'games_lobby', label = t('games.show_lobby'), icon = 'fa-solid fa-clipboard-list',
            canInteract = function() return Games.free() and Games.lobby ~= nil and Games.lobby.state == 'lobby' end,
            onSelect = function() CreateThread(Games.openLobby) end },
    }
end

-- Scenes ----------------------------------------------------------------------------------------------------

-- What every game shares: whose turn it is, and the result sheet for the players at the end.
local function common(scene, op, args)
    if op == 'start' or op == 'full' then scene.turn, scene.turnEnds = args.turn and args.turn.id, args.turn and args.turn.ends end
    if op == 'turn' then scene.turn, scene.turnEnds = args.id, args.ends end
    if op == 'end' and args.results then
        for _, row in ipairs(args.results) do
            if row.id == cache.serverId and not Nui.isOpen() then
                Nui.open('games.result', { game = scene.game, mode = scene.public and scene.public.mode, results = args.results, summary = args.summary, me = cache.serverId })
            end
        end
    end
end

local function dispatch(scene, op, args, message)
    common(scene, op, args)
    local fn = handlers[scene.game]
    if not fn then return end
    local ok, err = pcall(fn, op, args, message, scene)
    if not ok then print(('^1[daddy_campusgames] %s %s: %s^7'):format(scene.game, op, err)) end
end

-- A missed step: the whole scene from the server, given to the game as 'full' (one ask at a time per match).
local fetching = {}
local function refetch(id)
    if fetching[id] then return end
    fetching[id] = true
    local result = Games.call('sceneFull', { id = id })
    fetching[id] = nil
    if not result.ok then
        Games.scenes[id] = nil
        return
    end
    local public = result.match
    local scene = Games.scenes[id] or {}
    scene.id, scene.game, scene.rev, scene.public = id, public.game, public.rev, public
    Games.scenes[id] = scene
    dispatch(scene, 'full', public, { id = id, rev = public.rev })
end

-- Every scene but the kept one ends here (the game cleans up as at a real end).
function Games.dropScenes(keep)
    for id, scene in pairs(Games.scenes) do
        if id ~= keep then
            Games.scenes[id] = nil
            dispatch(scene, 'end', {}, { id = id })
        end
    end
end

-- In a match a client follows only its own; a spectator follows one match per game at a time.
local watching = {}
local function wanted(message)
    local mine = Games.lobby and Games.lobby.id
    if mine then return message.id == mine end
    if message.private or not message.game then return true end
    local other = watching[message.game]
    if other and other ~= message.id and Games.scenes[other] then return false end
    watching[message.game] = message.id
    return true
end

RegisterNetEvent('daddy_campusgames:scene', function(message)
    local id = message.id
    if not id or not wanted(message) then return end
    local scene = Games.scenes[id]
    if message.op == 'start' then
        scene = { id = id, game = message.args.game, rev = message.rev, public = message.args }
        Games.scenes[id] = scene
        return dispatch(scene, 'start', message.args, message)
    end
    if not scene then return CreateThread(function() refetch(id) end) end
    if message.private then return dispatch(scene, message.op, message.args, message) end
    if message.rev ~= scene.rev + 1 then return CreateThread(function() refetch(id) end) end
    scene.rev = message.rev
    dispatch(scene, message.op, message.args, message)
    if message.op == 'end' then Games.scenes[id] = nil end
end)

-- Is it my turn in my game?
function Games.myTurn(scene)
    return scene and scene.turn == cache.serverId
end
