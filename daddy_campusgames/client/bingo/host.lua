-- The host panel of a bingo night: the command (Config.Bingo.Command) or a board's option opens it, and the server
-- decides what it shows. Each button is bingoHost:<action> here and bingo:<action> on the server, which checks the
-- host and the hall. During a game the host keeps the keys (E, H) and the panel stays shut, so the mic is never cut.
local t = DL.locale.t
BingoHost = { hall = nil } -- the hall the open panel is about

local ACTIONS = { 'open', 'start', 'draw', 'auto', 'autoCall', 'pause', 'next', 'cancel', 'finish', 'takeover', 'say', 'kick',
    'invite', 'bots', 'groups', 'groupSave', 'groupDelete', 'memberAdd', 'memberRemove' }

-- hall: the hall to host in (the one I stand in when not given).
function BingoHost.open(hall)
    if Nui.isOpen() then return end
    local result = Games.call('bingo:panel', { hall = hall or BingoHall.here() })
    if not result.ok then return Games.fail(result) end
    BingoHost.hall = type(result.hall) == 'table' and result.hall.uid or hall or BingoHall.here()
    Nui.open('games.bingoHost', result)
end

-- The night as it changes, while the panel is open.
function BingoHost.changed(hall)
    if not hall or hall ~= BingoHost.hall or not Nui.isOpen('games.bingoHost') then return end
    Nui.send('bingoHost', { op = 'state', data = BingoHall.night(hall) })
end

-- Shut: the card or the host's strip comes back.
Nui.onClose('games.bingoHost', function()
    BingoHost.hall = nil
    BingoHall.show(true)
end)

for _, action in ipairs(ACTIONS) do
    RegisterNUICallback('bingoHost:' .. action, function(data, cb)
        data = type(data) == 'table' and data or {}
        data.hall = data.hall or BingoHost.hall or BingoHall.here()
        local result = Games.call('bingo:' .. action, data)
        if not result.ok then Games.fail(result) end
        cb(result)
    end)
end

-- The whole panel again (after a change made in it).
RegisterNUICallback('bingoHost:refresh', function(_, cb)
    local result = Games.call('bingo:panel', { hall = BingoHost.hall or BingoHall.here() })
    if result.ok and type(result.hall) == 'table' then BingoHost.hall = result.hall.uid end
    cb(result)
end)

local command = Config.Bingo.Command
if command and command ~= '' then
    RegisterCommand(command, function() CreateThread(function() BingoHost.open() end) end, false)
    TriggerEvent('chat:addSuggestion', '/' .. command, t('games.command_bingo'))
end
