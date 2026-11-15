-- Game-clock alarms (uygulamalar/saat.md): the server keeps them, but only the game knows the city's time, so it
-- watches the clock while the player has one on and tells the server when one is due (server/alarms.lua rings it).
local RESOURCE = GetCurrentResourceName()
local JUMP = 10 -- a clock that leapt further than this many game minutes was set by hand: nothing in between rings

local alarms = {} -- { id, hm, days }
local watching = false

-- Monday = 1 ... Sunday = 7, as the phone counts days.
local function weekday()
    local d = GetClockDayOfWeek()
    return d == 0 and 7 or d
end

local function minuteOf(hm)
    local h, m = hm:match('^(%d+):(%d+)$')
    return tonumber(h) * 60 + tonumber(m)
end

-- Is minute t within (from, to], the stretch of the day the clock moved through (it may pass midnight)?
local function passed(t, from, to)
    if from <= to then return t > from and t <= to end
    return t > from or t <= to
end

-- Once a second, while an alarm is on: each minute the clock moved through rings the alarms set to it on today.
local function watch()
    if watching then return end
    watching = true
    CreateThread(function()
        local last = GetClockHours() * 60 + GetClockMinutes()
        while #alarms > 0 do
            Wait(1000)
            local now = GetClockHours() * 60 + GetClockMinutes()
            if now ~= last then
                local day = tostring(weekday())
                if (now - last) % 1440 <= JUMP then
                    for _, a in ipairs(alarms) do
                        local repeats = a.days ~= ''
                        if passed(minuteOf(a.hm), last, now) and (not repeats or (',' .. a.days .. ','):find(',' .. day .. ',', 1, true)) then
                            TriggerServerEvent(RESOURCE .. ':alarmGame', a.id)
                        end
                    end
                end
                last = now
            end
        end
        watching = false
    end)
end

local function set(list)
    alarms = type(list) == 'table' and list or {}
    if #alarms > 0 then watch() end
end

RegisterNetEvent(RESOURCE .. ':gameAlarms', set)

CreateThread(function()
    DL.fw.awaitLogin()
    set(lib.callback.await(RESOURCE .. ':gameAlarms', false))
end)
