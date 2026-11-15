-- The leaderboard on a wall: a whiteboard (or the first board model the game has) that opens this week's and
-- all time standings per game.
local t = DL.locale.t

local function model()
    for _, name in ipairs(Config.Board.Models) do
        if IsModelInCdimage(joaat(name)) then return name end
    end
end

local function open(game, scope)
    local result = Games.call('stats', { game = game, scope = scope })
    if not result.ok then return Games.fail(result) end
    if Nui.isOpen('games.board') then return Nui.send('board', result) end
    Nui.open('games.board', result)
end

Games.kind('games_board', function(record)
    return {
        presentation = 'prop', model = (record.model or '') ~= '' and record.model or model(), distance = Config.Board.Distance,
        options = { {
            name = 'games_board', label = t('games.board_look'), icon = 'fa-solid fa-trophy', distance = Config.Board.Distance,
            canInteract = function() return Games.free() end,
            onSelect = function() CreateThread(function() open() end) end,
        }, {
            name = 'games_tournaments', label = t('games.tour_look'), icon = 'fa-solid fa-sitemap', distance = Config.Board.Distance,
            canInteract = function() return Games.free() end,
            onSelect = function() CreateThread(Games.openTournaments) end,
        } },
    }
end)

-- Tournaments: the list with brackets, and the staff's form.
function Games.openTournaments()
    local result = Games.call('tour:list')
    if not result.ok then return Games.fail(result) end
    if Nui.isOpen('games.tournament') then return Nui.send('tournaments', result) end
    Nui.open('games.tournament', result)
end

for _, action in ipairs({ 'join', 'leave', 'create', 'draw', 'forfeit', 'cancel', 'places' }) do
    RegisterNUICallback('tour:' .. action, function(data, cb)
        local result = Games.call('tour:' .. action, data)
        if not result.ok then Games.fail(result) end
        cb(result)
        if result.ok and action ~= 'places' then CreateThread(Games.openTournaments) end
    end)
end

RegisterNUICallback('board:show', function(data, cb)
    cb({ ok = true })
    CreateThread(function() open(data.game, data.scope) end)
end)
