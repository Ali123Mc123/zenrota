-- Client: the time in the hall. Night while the showroom is open; after it, the weather script's own time again.
do
    local SCRIPTS = {
        -- Renewed-Weathersync: syncWeather false stops its time and weather (and holds the clock itself)
        { resource = 'Renewed-Weathersync', pause = function() LocalPlayer.state:set('syncWeather', false, true) end,
          resume = function() LocalPlayer.state:set('syncWeather', true, true) end },
        { resource = 'qb-weathersync', pause = function() TriggerEvent('qb-weathersync:client:DisableSync') end,
          resume = function() TriggerEvent('qb-weathersync:client:EnableSync') end },
    }
    -- no weather script: the game's clock, held while inside
    local GAME = {
        pause = function() NetworkOverrideClockMillisecondsPerGameMinute(99999999) end,
        resume = function()
            NetworkClearClockTimeOverride()
            NetworkOverrideClockMillisecondsPerGameMinute(2000)
        end,
    }
    local paused

    function Bridge.night(on)
        if not (Config.Room or {}).Night then return end
        if on and not paused then
            paused = GAME
            for _, s in ipairs(SCRIPTS) do
                if GetResourceState(s.resource) == 'started' then
                    paused = s
                    break
                end
            end
            paused.pause()
            Wait(0)
            NetworkOverrideClockTime(23, 0, 0)
        elseif not on and paused then
            paused.resume()
            paused = nil
        end
    end
end
