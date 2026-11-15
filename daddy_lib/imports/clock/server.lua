-- Server time on the server: its own game timer, the clock every client samples.
local clock = {}

function clock.now()
    return GetGameTimer()
end

function clock.hint() end

function clock.ready()
    return true
end

return clock
