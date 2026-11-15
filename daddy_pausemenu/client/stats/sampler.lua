-- Records the engine does not keep for us (top speed, longest life, longest wanted spell) and the driving events
-- GTA's stats_controller rewarded: clean landings and top-speed runs. Once a second; at the wheel ten times a second
-- while moving or in the air, twice a second when stopped or crawling.
local AIR_OR_WATER = { [14] = true, [15] = true, [16] = true, [21] = true } -- boats, helicopters, planes, trains
-- Below CRAWL m/s no record moves; only a roll off a ledge is seen up to 0.4 s late.
local FAST_MS, SLOW_MS, CRAWL = 100, 500, 5.0
local PID = PlayerId() -- the local player's index does not change in a session

PM.Stats.own = { TOP_SPEED = 0, LONGEST_LIFE = 0, LONGEST_WANTED = 0 }
local own, events, st = PM.Stats.own, { land = 0, speed = 0 }, {}

-- A new character: its own records start over.
function PM.Stats.ResetOwn()
    for name in pairs(own) do own[name] = 0 end
    events.land, events.speed = 0, 0
    st = { armed = true }
end

-- The events since the last push (the server checks them against the time between pushes).
function PM.Stats.TakeEvents()
    local out = { land = events.land, speed = events.speed }
    events.land, events.speed = 0, 0
    return out
end

-- A landing counts after 1.5 s in the air on all four wheels; 53 m/s on the ground counts once per 10 s below 20 m/s.
-- Returns the wait before the next look.
local function drive(veh, t)
    local speed = GetEntitySpeed(veh)
    own.TOP_SPEED = math.max(own.TOP_SPEED, speed)
    if IsEntityInAir(veh) then
        st.air = st.air or t
        return FAST_MS
    end
    if st.air then
        if t - st.air > 1500 and IsVehicleOnAllWheels(veh) then events.land = events.land + 1 end
        st.air = nil
    end
    if speed < 20.0 then
        st.slow = st.slow or t
        if t - st.slow >= 10000 then st.armed = true end
    else
        st.slow = nil
        if st.armed and speed >= 53.0 then
            events.speed, st.armed = events.speed + 1, false
        end
    end
    return speed >= CRAWL and FAST_MS or SLOW_MS
end

CreateThread(function()
    PM.Stats.ResetOwn()
    local clockAt, car, carClass = 0, 0, nil
    while true do
        local wait = 1000
        if PM.Stats.cid then
            local ped, t = PlayerPedId(), GetGameTimer()
            -- The life and wanted clocks keep 1 s steps at the wheel too. 950: a 1 s wait that wakes a few ms short
            -- on the game timer still runs them, so on foot they never skip to 2 s.
            if t >= clockAt then
                clockAt = t + 950
                if IsEntityDead(ped) then
                    st.alive = nil
                else
                    st.alive = st.alive or t
                    own.LONGEST_LIFE = math.max(own.LONGEST_LIFE, t - st.alive)
                end
                if GetPlayerWantedLevel(PID) > 0 then
                    st.wanted = st.wanted or t
                    own.LONGEST_WANTED = math.max(own.LONGEST_WANTED, t - st.wanted)
                else
                    st.wanted = nil
                end
            end
            local veh = GetVehiclePedIsIn(ped, false)
            if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
                -- A vehicle's class never changes: read once per vehicle driven.
                if veh ~= car then car, carClass = veh, GetVehicleClass(veh) end
            else
                car = 0
            end
            if car ~= 0 and not AIR_OR_WATER[carClass] then
                wait = drive(veh, t)
            else
                st.air = nil
            end
        end
        Wait(wait)
    end
end)
