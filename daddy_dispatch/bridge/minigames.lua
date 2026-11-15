-- Client: whether the player is in a game where shots are part of the play (no automatic alerts then). Add yours as an
-- entry: its resource and a check.
local GAMES = {
    { resource = 'pug-paintball', check = function() return exports['pug-paintball']:IsInPaintball() end },
    { resource = '0r-paintball-v2', check = function() return exports['0r-paintball-v2']:inGame() end },
    { resource = 'BakiTelli_paintballv2', check = function() return exports['BakiTelli_paintballv2']:inGameStatus() end },
}

function Bridge.inMinigame()
    for _, g in ipairs(GAMES) do
        if Bridge.started(g.resource) then
            local ok, playing = pcall(g.check)
            if ok and playing then return true end
        end
    end
    return false
end
