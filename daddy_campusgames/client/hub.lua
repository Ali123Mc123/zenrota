-- The games page without the phone: the same page as the phone app, in this product's own screen (/games).
local function open()
    if Nui.isOpen() then return end
    Nui.open('games.hub', { standalone = true })
end

if Config.Command ~= '' then
    RegisterCommand(Config.Command, open, false)
    TriggerEvent('chat:addSuggestion', '/' .. Config.Command, DL.locale.t('games.command_hub'))
end

for _, name in ipairs({ 'nearby', 'stats', 'mine', 'tournaments', 'tourJoin', 'join', 'bingo' }) do
    RegisterNUICallback('hub:' .. name, function(data, cb)
        local result = Games.call('hub:' .. name, data)
        cb(result)
        if name == 'join' and result.ok and result.lobby and result.lobby.state == 'lobby' then
            CreateThread(function() Nui.open('games.lobby', result.lobby) end)
        end
    end)
end
