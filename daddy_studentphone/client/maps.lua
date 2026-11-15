local RESOURCE = GetCurrentResourceName()

-- Maps: the player's place and heading for the blue dot, and the game's GPS waypoint for directions (whether one is
-- still set: a route ends when the player takes it off the pause map). names: the street, the one crossing it and the
-- area too (a voice memo's title, a shared location). nav (a route's place): the game's own turn-by-turn, the next
-- move (GENERATE_DIRECTIONS_TO_COORD: 0 "say it now" (unclear), 1 working the route out or going the wrong way, 2
-- follow the route, 3 turn left, 4 turn right, 5 straight on, 6 sharp left, 7 sharp right, 8 working it out again)
-- and how far it is, the GPS route's length, and whether the player drives and how fast, for the arrival time.
--
-- That distance is metres or tenths of one, depending on whom one asks: which, is learned from how fast it falls as
-- the player drives toward a junction (and kept for next time); until then it is taken as metres, unless it is longer
-- than the whole route.
local navScale = tonumber(GetResourceKvpString('nav_scale') or '')
local navLast, navVotes = nil, { metres = 0, tenths = 0 }

local function navMetres(raw, at, length)
    if not navScale and raw > 0 then
        if not navLast or raw > navLast.raw then
            navLast = { raw = raw, at = at } -- a new junction ahead
        elseif #(at - navLast.at) > 8.0 then
            local ratio = (navLast.raw - raw) / #(at - navLast.at)
            if ratio > 0.6 and ratio < 1.8 then navVotes.metres = navVotes.metres + 1 elseif ratio > 6.0 and ratio < 18.0 then navVotes.tenths = navVotes.tenths + 1 end
            if navVotes.metres >= 3 or navVotes.tenths >= 3 then
                navScale = navVotes.tenths >= 3 and 0.1 or 1
                SetResourceKvp('nav_scale', tostring(navScale))
            end
            navLast = { raw = raw, at = at }
        end
    end
    return raw * (navScale or ((length > 0 and raw > length * 1.2) and 0.1 or 1))
end

RegisterNUICallback('phone:where', function(data, cb)
    local ped = PlayerPedId()
    local c = GetEntityCoords(ped)
    local out = { ok = true, x = c.x, y = c.y, z = c.z, heading = GetEntityHeading(ped), waypoint = IsWaypointActive() }
    if type(data) == 'table' and (data.names or data.nav) then
        local s1, s2 = GetStreetNameAtCoord(c.x, c.y, c.z)
        local zone = GetLabelText(GetNameOfZone(c.x, c.y, c.z))
        out.street, out.cross, out.zone = GetStreetNameFromHashKey(s1), s2 ~= 0 and GetStreetNameFromHashKey(s2) or '', zone ~= 'NULL' and zone or ''
    end
    local nav = type(data) == 'table' and type(data.nav) == 'table' and data.nav or nil
    if nav and tonumber(nav.x) and tonumber(nav.y) then
        local car = IsPedInAnyVehicle(ped, false)
        local _, dir, _, dist = GenerateDirectionsToCoord(nav.x + 0.0, nav.y + 0.0, (tonumber(nav.z) or c.z) + 0.0, car)
        local length = GetGpsBlipRouteFound() and GetGpsBlipRouteLength() or 0
        out.nav = { dir = dir, dist = car and navMetres(dist or 0.0, c, length) or 0, length = length, car = car, speed = GetEntitySpeed(ped) }
    end
    cb(out)
end)

-- The weather and the hour, for the chip in Maps: what the weather script shares (Renewed-Weathersync's GlobalState,
-- its time too), or else the game's own (its weather comes as a hash, matched to a name).
local WEATHERS = { 'EXTRASUNNY', 'CLEAR', 'CLOUDS', 'OVERCAST', 'RAIN', 'CLEARING', 'THUNDER', 'SMOG', 'FOGGY', 'XMAS', 'SNOW', 'SNOWLIGHT', 'BLIZZARD', 'HALLOWEEN', 'NEUTRAL' }
RegisterNUICallback('phone:weather', function(_, cb)
    local w, clock = GlobalState.weather, GlobalState.currentTime
    local kind = type(w) == 'table' and type(w.weather) == 'string' and w.weather:upper() or nil
    if not kind then
        local hash = GetPrevWeatherTypeHashName()
        kind = 'CLEAR'
        for _, name in ipairs(WEATHERS) do
            if GetHashKey(name) == hash then kind = name end
        end
    end
    local timed = type(clock) == 'table' and tonumber(clock.hour)
    cb({ ok = true, kind = kind, hour = timed and tonumber(clock.hour) or GetClockHours(), minute = timed and (tonumber(clock.minute) or 0) or GetClockMinutes(),
        wind = GetWindSpeed(), rain = GetRainLevel() })
end)

-- The parked car: getting out of a car the player drove keeps where it stands, with its name and plate (not bicycles,
-- not boats, not aircraft). Looked at once a second.
CreateThread(function()
    local driving, label, plate
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
            local model = GetEntityModel(veh)
            if IsThisModelACar(model) or IsThisModelABike(model) or IsThisModelAQuadbike(model) then
                driving = veh
                local name = GetLabelText(GetDisplayNameFromVehicleModel(model))
                label = name ~= 'NULL' and name or GetDisplayNameFromVehicleModel(model)
                plate = (GetVehicleNumberPlateText(veh) or ''):match('^%s*(.-)%s*$')
            else
                driving = nil
            end
        elseif driving and veh == 0 then
            local at = DoesEntityExist(driving) and GetEntityCoords(driving) or GetEntityCoords(ped)
            driving = nil
            TriggerServerEvent(RESOURCE .. ':parked', at.x, at.y, at.z, label, plate)
        end
    end
end)

RegisterNUICallback('phone:goto', function(data, cb)
    if data.clear then
        SetWaypointOff()
        return cb({ ok = true })
    end
    local x, y = tonumber(data.x), tonumber(data.y)
    if x and y then SetNewWaypoint(x + 0.0, y + 0.0) end
    cb({ ok = x ~= nil and y ~= nil })
end)

RegisterNUICallback('phone:floors', function(data, cb)
    local res = DL.product.resource('campuslife')
    cb({ ok = res ~= nil })
    if not res then return end
    PhoneUI.close()
    SetTimeout(300, function() pcall(function() exports[res]:OpenFloorPlans(data.floor ~= '' and data.floor or nil) end) end)
end)
