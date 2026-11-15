-- While the menu is open: other HUDs hide, and the page gets the game clock, our server id and the players online.
local ONLINE = 'daddy_pausemenu:online'

local function setHuds(visible)
    for _, hud in ipairs(Config.Huds or {}) do
        if GetResourceState(hud.resource) == 'started' then
            local ok = pcall(function()
                local api = exports[hud.resource]
                api[hud.export](api, visible)
            end)
            if not ok then print(('^3[daddy_pausemenu] %s:%s failed^7'):format(hud.resource, hud.export)) end
        end
    end
end

PM.OnOpen(function()
    setHuds(false)
    local session = PM.Session()
    CreateThread(function()
        -- The server id is fixed; the clock and the count are sampled every second and sent only when one changed
        -- (the first pass of each open always sends).
        local id, clock, online = GetPlayerServerId(PlayerId()), nil, nil
        while PM.IsOpen() and PM.Session() == session do
            local hours, minutes = GetClockHours(), GetClockMinutes()
            local count = GlobalState[ONLINE] or #GetActivePlayers()
            if hours * 60 + minutes ~= clock or count ~= online then
                clock, online = hours * 60 + minutes, count
                PM.Send('pm:core:hud', { time = ('%02d:%02d'):format(hours, minutes), id = id, online = count })
            end
            Wait(1000)
        end
    end)
end)

PM.OnClose(function()
    setHuds(true)
end)
