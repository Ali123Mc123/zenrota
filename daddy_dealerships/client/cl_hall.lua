-- The hall: the camera goes into the showroom set (daddy_showroom) and five local cars stand in its bays, the selected
-- one in the middle and the outer two waiting out of frame. Left and right slide the camera one bay; when it arrives the
-- cars move one bay back and the camera with them (the bays are the same, so nothing shows) and the far bay ahead gets
-- the next car, out of frame: an endless row in which no car ever pops in. One loop sets the camera and the selected
-- bay's script lights every frame, from the same numbers.
-- A dealership may have its own row on the water instead (the hall in its config): there the camera holds and the boats
-- glide past it, since the shore behind repeats no bays. Each boat first floats free to find its waterline.
Hall = { active = false }

local H     -- the set: position, bays, bayLine, rail, camera, carHeading, room (exports.daddy_showroom:hall()), or a
            -- dealership's row on the water (no room; its heading, reach, long and scale)
local S     -- the open session
local PITCH -- metres between two bays
local TURN  -- the set's heading as cos and sin: the hall faces north, a row on the water its own way
local REACH = 2 -- cars each side of the selected one
local FLOATS = {} -- a boat model's height on the water, once one of it has floated

-- wais-primehud while the hall is open: hidden, and back only once the picture is (it keeps itself hidden when shown
-- on a faded-out screen). A failing export is printed, never lets it stop what called it.
local function primehud(visible)
    if GetResourceState('wais-primehud') ~= 'started' then return end
    -- DaddyRP: this primehud build works the other way round (hideHud left the HUD on in the hall, showHud took it off
    -- on the way out), so each export is called for the opposite of its name.
    local ok, err = pcall(function()
        if visible then exports['wais-primehud']:hideHud() else exports['wais-primehud']:showHud() end
    end)
    if not ok then print(('^3[daddy_dealerships] wais-primehud %s failed: %s^7'):format(visible and 'showHud' or 'hideHud', tostring(err))) end
end

local function at(x, y, z)
    return H.position + vector3(x * TURN[1] - y * TURN[2], x * TURN[2] + y * TURN[1], z)
end

-- A row entry is a catalogue model, or 'used:<id>' for a used car (its model and state came with the open).
local function modelOf(key)
    local used = key and S.used[key]
    return used and used.model or key
end

local function ease(t)
    return t * t * (3 - 2 * t)
end

-- Metres the camera stands back from its rail for a car: longer cars further, bikes nearer, inside the hall. A set may
-- bring its own reach: the length that stands at the rail, metres back per metre longer, the nearest, the furthest.
local function reachFor(model)
    if not model then return 0.0 end
    local r = H.reach or { 4.8, 1.1, -2.4, 2.6 }
    local min, max = GetModelDimensions(joaat(model))
    return math.max(r[3], math.min(r[4], (max.y - min.y - r[1]) * r[2]))
end

-- The camera's place and aim at row position x; buy (0-1) steps it in for the purchase.
local STEP_IN, STEP_UP = 1.4, 0.1

local function shot(x, back, buy)
    local c = H.camera
    local y = H.rail - back + STEP_IN * buy
    local z = c.height + STEP_UP * buy
    return at(x, y, z), at(x, H.bayLine, z + (H.bayLine - y) * math.tan(math.rad(c.pitch)))
end

-- The camera along the row: in the hall it slides with a move, on the water it holds and the boats glide.
local function camX()
    return S.sea and 0.0 or S.x
end

local function place()
    local from, look = shot(camX(), S.back, S.buy)
    SetCamCoord(S.cam, from.x, from.y, from.z)
    PointCamAtCoord(S.cam, look.x, look.y, look.z)
    SetFocusPosAndVel(from.x, from.y, from.z, 0.0, 0.0, 0.0)
end

-- Cars ----------------------------------------------------------------------------------------------------------------

-- A local car standing on the floor of a bay (slot -2 to 2), inside the hall's room; its model is loaded. A used car
-- stands as it was sold: paint, mods, dents and health (the dents take a few frames, and it is made invincible after).
-- A boat on the water goes in at its model's height there; the first of a model floats free until float() holds it.
local function spawn(slot, hash, key)
    local min = GetModelDimensions(hash)
    local lift = S.sea and (FLOATS[hash] or 0.0) or -min.z + 0.02
    local p = at(slot * PITCH - (S.sea and S.x or 0.0), H.bayLine, lift)
    pcall(function() exports['FeloxAC']:CreateVehicle(hash) end) --[[FeloxAC:auto]]
    local veh = CreateVehicle(hash, p.x, p.y, p.z, S.heading, false, false)
    local used = S.used[key]
    local held = not S.sea or FLOATS[hash] ~= nil
    SetModelAsNoLongerNeeded(hash)
    if not used then SetEntityInvincible(veh, true) end
    FreezeEntityPosition(veh, held)
    SetVehicleDirtLevel(veh, 0.0)
    SetVehicleLights(veh, 1)
    SetVehicleDoorsLocked(veh, 2)
    if S.interior then ForceRoomForEntity(veh, S.interior, S.room) end
    -- a boat floating free must not come to rest on a neighbour's hull (a long one reaches into the next bays)
    if S.sea then
        for _, other in pairs(S.slot) do
            SetEntityNoCollisionEntity(veh, other, false)
            SetEntityNoCollisionEntity(other, veh, false)
        end
    end
    local c1, c2 = GetVehicleColours(veh)
    S.cars[veh] = { lift = lift, c1 = c1, c2 = c2, used = used ~= nil, hash = hash, held = held, free = GetGameTimer() + 800, phase = math.random() * 6.28 }
    if used then
        CreateThread(function()
            Used.apply(veh, used)
            if DoesEntityExist(veh) then SetEntityInvincible(veh, true) end
        end)
    end
    return veh
end

-- A car to its bay after the row moved on; boats on the water are placed every frame (float).
local function move(veh, slot)
    if not veh or S.sea then return end
    local p = at(slot * PITCH, H.bayLine, S.cars[veh].lift)
    SetEntityCoordsNoOffset(veh, p.x, p.y, p.z, false, false, false)
    SetEntityHeading(veh, S.heading)
    ForceRoomForEntity(veh, S.interior, S.room)
end

-- The boats, every frame: one floating free is held once it has lain still a moment (or the row moves; at most 2 s on),
-- and its model keeps that height; a held one rocks gently in its bay and glides with the row.
local function float(now)
    for slot = -REACH, REACH do
        local veh = S.slot[slot]
        local boat = veh and S.cars[veh]
        if boat and not boat.held then
            boat.still = GetEntitySpeed(veh) < 0.1 and (boat.still or now) or nil
            if S.slide or now > boat.free and (boat.still and now - boat.still > 300 or now > boat.free + 2000) then
                local lift = GetEntityCoords(veh).z - H.position.z
                local sane = lift > -4.0 and lift < 2.0
                boat.held, boat.lift = true, sane and lift or 0.0
                if sane then FLOATS[boat.hash] = lift end
                FreezeEntityPosition(veh, true)
            end
        end
        if boat and boat.held then
            local t = now / 1000.0 + boat.phase
            local p = at(slot * PITCH - S.x, H.bayLine, boat.lift + 0.04 * math.sin(t * 1.3))
            SetEntityCoordsNoOffset(veh, p.x, p.y, p.z, false, false, false)
            SetEntityRotation(veh, 0.5 * math.sin(t * 0.9), 0.8 * math.sin(t * 1.1), S.heading, 2, false)
        end
    end
end

local function remove(veh)
    if veh and DoesEntityExist(veh) then DeleteEntity(veh) end
    if veh then S.cars[veh] = nil end
end

-- The selected car always shows (it may have been a hidden neighbour a moment ago); the rest hide while buying and
-- beside a car longer than Config.Row.Long. No car's lights are on: on the polished floor their beams lay like windows.
local function neighbours()
    local centre, long = S.slot[0], false
    if centre then
        SetEntityVisible(centre, true, false)
        local min, max = GetModelDimensions(GetEntityModel(centre))
        long = (max.y - min.y) > (H.long or Config.Row.Long or 7.0)
    end
    for slot = -REACH, REACH do
        local veh = S.slot[slot]
        if veh then
            if slot ~= 0 then SetEntityVisible(veh, not long and S.buy < 0.5, false) end
        end
    end
end

-- The selected car's numbers for the page, rated as daddy_garages rates a car (Config.Row.Caps are its caps, so a car
-- rates the same in both): four bars 0-10 from the model, its top speed, and facts read from the car itself.
local function stats(veh, model)
    local hash, caps = GetEntityModel(veh), Config.Row.Caps
    local function bar(value, cap) return math.floor(math.max(0.0, math.min(10.0, value / cap * 10.0)) * 10 + 0.5) / 10 end
    local speed = GetVehicleModelEstimatedMaxSpeed(hash)
    local bias = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fDriveBiasFront')
    local mph = Config.Row.Speed == 'mph'
    Page.send('dealer:stats', {
        model = model,
        speed = math.floor(speed * (mph and 2.23694 or 3.6)),
        unit = mph and 'mph' or 'kmh',
        bars = {
            speed = bar(speed, caps.speed),
            accel = bar(GetVehicleModelAcceleration(hash), caps.accel),
            brake = bar(GetVehicleModelMaxBraking(hash), caps.braking),
            grip = bar(GetVehicleModelMaxTraction(hash), caps.handling),
        },
        seats = GetVehicleModelNumberOfSeats(hash),
        drive = bias >= 0.9 and 'fwd' or bias <= 0.1 and 'rwd' or 'awd',
        mass = math.floor(GetVehicleHandlingFloat(veh, 'CHandlingData', 'fMass') + 0.5),
    })
end

-- After the cars changed: who shows, and a new selected car's numbers.
local function arrange()
    neighbours()
    local centre = S.slot[0]
    if centre and S.statsFor ~= centre then
        S.statsFor = centre
        stats(centre, modelOf(S.list[S.index]))
    end
end

-- The car for a slot: placed at once when its model is in memory, otherwise as soon as it loads, if the row still
-- wants that car there by then (a slide or a new row may have moved on; the next one fills the slot again).
local function fill(slot)
    if not S or not Hall.active or Hall.closing then return end
    local key = S.list[S.index + slot]
    if not key or S.slot[slot] then return end
    local hash = joaat(modelOf(key))
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then return end
    RequestModel(hash)
    if S.requested then S.requested[hash] = true end
    if HasModelLoaded(hash) then
        if S.requested then S.requested[hash] = nil end
        S.slot[slot] = spawn(slot, hash, key)
        return
    end
    local session = S
    CreateThread(function()
        local stop = GetGameTimer() + 10000
        while not HasModelLoaded(hash) and GetGameTimer() < stop and S == session and Hall.active and not Hall.closing do Wait(50) end
        if S ~= session or not Hall.active or Hall.closing or S.slot[slot] or S.list[S.index + slot] ~= key or not HasModelLoaded(hash) then
            SetModelAsNoLongerNeeded(hash)
            if session.requested then session.requested[hash] = nil end
            return
        end
        if S.requested then S.requested[hash] = nil end
        S.slot[slot] = spawn(slot, hash, key)
        arrange()
    end)
end

-- Loads a model ahead, so the far bay's next car is ready.
local function preload(index)
    local key = S.list[index]
    if key then
        local hash = joaat(modelOf(key))
        RequestModel(hash)
        if S.requested then S.requested[hash] = true end
    end
end

-- Lights: a key from the front and two rims behind on the selected bay, a low key on each neighbour.
local function spot(from, to, distance, brightness, radius, shadow)
    local d = norm(to - from)
    if shadow then
        DrawSpotLightWithShadow(from.x, from.y, from.z, d.x, d.y, d.z, 240, 244, 255, distance, brightness, 0.0, radius, 1.0, shadow)
    else
        DrawSpotLight(from.x, from.y, from.z, d.x, d.y, d.z, 240, 244, 255, distance, brightness, 0.0, radius, 1.0)
    end
end

-- The rig is the hall's; a set with a scale (boats on the water) stands it that much bigger.
local function lights()
    local x, y, k = camX(), H.bayLine, H.scale or 1.0
    spot(at(x, y - 4.6 * k, 5.2 * k), at(x, y, 0.5 * k), 12.0 * k, 9.0 + 3.0 * S.buy, 30.0, 1)
    spot(at(x - 2.4 * k, y + 2.4 * k, 5.0 * k), at(x, y, 0.8 * k), 10.0 * k, 5.0, 24.0)
    spot(at(x + 2.4 * k, y + 2.4 * k, 5.0 * k), at(x, y, 0.8 * k), 10.0 * k, 5.0, 24.0)
    if S.buy < 0.5 then
        for _, side in ipairs({ -1, 1 }) do
            spot(at(x + side * PITCH, y - 4.6 * k, 5.2 * k), at(x + side * PITCH, y, 0.5 * k), 12.0 * k, 3.0, 30.0)
        end
    end
end

-- The row ----------------------------------------------------------------------------------------------------------------

-- A slide's end, in the frame the camera arrives: the cars step one bay back as the camera does, so the picture stays
-- the same; the far car behind goes. The next frame fills the far bay ahead (out of frame) and tells the page.
local function shift(dir)
    remove(S.slot[-REACH * dir])
    for slot = -REACH * dir, (REACH - 1) * dir, dir do S.slot[slot] = S.slot[slot + dir] end
    S.slot[REACH * dir] = nil
    for slot = -REACH, REACH do move(S.slot[slot], slot) end
    S.x = 0.0
    S.index = S.index + dir
    S.moving = false
    neighbours()
    CreateThread(function()
        if not S then return end
        for slot = -REACH, REACH do fill(slot) end
        arrange()
        preload(S.index + (REACH + 1) * dir)
        Page.send('dealer:index', { index = S.index })
    end)
end

-- One frame of the open hall: a slide or a step in moves on, then the camera and the script lights follow from the
-- same numbers in this same frame (two loops used to take turns, and the light jumped for a frame).
local function frame()
    local now = GetGameTimer()
    local m = S.slide
    if m then
        local t = math.min(1.0, (now - m.start) / m.ms)
        local e = ease(t)
        S.x = m.dir * PITCH * e
        S.back = m.fromBack + (m.toBack - m.fromBack) * e
        if t >= 1.0 then
            S.slide = nil
            shift(m.dir)
        end
    end
    local p = S.pose
    if p then
        local t = math.min(1.0, (now - p.start) / p.ms)
        S.buy = p.from + (p.to - p.from) * ease(t)
        if t >= 1.0 then
            S.pose = nil
            neighbours()
        end
    end
    place()
    if Config.Row.Lights then lights() end
    if S.sea then float(now) end
end

-- Puts the row's cars (models, and used:<id> for used cars) around index into the five bays (the page sends the row
-- after a hall, a sort or a search).
function Hall.show(models, index)
    if not S or not Hall.active or Hall.closing then return end
    -- a newer row (fast typing in the search or rapid category switching) wins
    S.token = (S.token or 0) + 1
    local token = S.token
    local first = not S.shown
    S.shown = true
    S.list, S.index = models, math.max(1, math.min(math.max(1, #models), index or 1))
    S.slide = nil
    S.statsFor, S.moving = nil, false
    Page.send('dealer:index', { index = S.index })
    for slot = -REACH, REACH do
        remove(S.slot[slot])
        S.slot[slot] = nil
    end
    S.x, S.back = 0.0, reachFor(modelOf(S.list[S.index]))
    for _, slot in ipairs({ 0, -1, 1, -2, 2 }) do fill(slot) end
    if first then
        local stop = GetGameTimer() + (S.sea and 1800 or 1000)
        while S and Hall.active and not Hall.closing and token == S.token and S.list[S.index] and not (S.slot[0] and S.cars[S.slot[0]].held) and GetGameTimer() < stop do Wait(0) end
    end
    if not S or not Hall.active or Hall.closing or token ~= S.token then return end
    arrange()
    preload(S.index - REACH - 1)
    preload(S.index + REACH + 1)
    if IsScreenFadedOut() or IsScreenFadingOut() then DoScreenFadeIn(250) end
    -- the first row that lands ends the loading screen, even when a newer row cut the first one short
    if not S.ready then
        S.ready = true
        Page.send('dealer:loading', { done = true })
    end
end

-- The selected car: its doors (all open or shut), its lights or its horn.
function Hall.action(kind)
    local veh = S and S.slot[0]
    if not veh or not DoesEntityExist(veh) then return end
    local car = S.cars[veh]
    if kind == 'doors' then
        car.doors = not car.doors
        for door = 0, 5 do
            if car.doors then SetVehicleDoorOpen(veh, door, false, false) else SetVehicleDoorShut(veh, door, false) end
        end
    elseif kind == 'lights' then
        car.lights = not car.lights
        SetVehicleLights(veh, car.lights and 2 or 1)
    elseif kind == 'horn' then
        StartVehicleHorn(veh, 700, joaat('HELDDOWN'), false)
    end
end

-- One bay left (-1) or right (1); false at the end of the row. The frame loop moves the camera.
function Hall.slide(dir)
    if not S or S.slide or S.buy > 0 or not S.list[S.index + dir] then return false end
    local veh = S.slot[0]
    if veh and S.cars[veh] and (S.cars[veh].doors or S.cars[veh].lights) then
        SetVehicleDoorsShut(veh, true)
        SetVehicleLights(veh, 1)
        S.cars[veh].doors, S.cars[veh].lights = false, false
    end
    S.slide = { dir = dir, start = GetGameTimer(), ms = Config.Row.Move, fromBack = S.back, toBack = reachFor(modelOf(S.list[S.index + dir])) }
    S.moving = true
    Page.send('dealer:moving', { dir = dir })
    return true
end

-- The camera steps in for the purchase (and back out); the neighbours go dark once it is in.
function Hall.pose(buy)
    if not S then return end
    S.pose = { from = S.buy, to = buy and 1.0 or 0.0, start = GetGameTimer(), ms = 700 }
end

-- Paints the selected car: a colour {r, g, b} (free colours), one of Config.Colours, or nil for its own colours; a used
-- car keeps its paint.
function Hall.paint(i, rgb)
    local veh = S and S.slot[0]
    if not veh or S.cars[veh].used then return end
    if type(rgb) == 'table' and #rgb == 3 then
        SetVehicleCustomPrimaryColour(veh, rgb[1], rgb[2], rgb[3])
        SetVehicleCustomSecondaryColour(veh, rgb[1], rgb[2], rgb[3])
        return
    end
    ClearVehicleCustomPrimaryColour(veh)
    ClearVehicleCustomSecondaryColour(veh)
    local colour, own = Config.Colours[i], S.cars[veh]
    if colour then SetVehicleColours(veh, colour.index, colour.index)
    else SetVehicleColours(veh, own.c1, own.c2) end
end

function Hall.dealer()
    return S and S.dealer
end

-- Opening and closing -----------------------------------------------------------------------------------------------

-- The dealership's set: its own row on the water (a table in its config), or the hall of a showroom resource (named
-- there, or Config.Hall) whose hall() gives the place, the bays and the camera.
local function setOf(id)
    local own = (Dealers.get(id) or {}).hall
    if type(own) == 'table' then return own end
    local ok, hall = pcall(function() return exports[own or Config.Hall]:hall() end)
    return ok and type(hall) == 'table' and hall or nil
end

-- Whether this session is still the open one (Hall.close drops Hall.active at once, S only after its fade).
local function live(session)
    return Hall.active and not Hall.closing and S == session
end

-- The frame loop of a session; an error in it closes the hall instead of freezing it.
local function frames(session)
    CreateThread(function()
        while Hall.active and S == session do
            HideHudAndRadarThisFrame()
            local ok, err = pcall(frame)
            if not ok then
                print(('^1[daddy_dealerships] hall frame failed: %s^7'):format(tostring(err)))
                return Hall.close()
            end
            Wait(0)
        end
    end)
end

-- Until the first row is on screen: the picture comes back after 3 s whatever faded it, and at 15 s the hall closes.
local function watchdog(session)
    CreateThread(function()
        local start, freed = GetGameTimer(), false
        while Hall.active and S == session and not session.ready do
            local t = GetGameTimer() - start
            if t > 15000 then
                print('^3[daddy_dealerships] hall open: no row after 15 s, closing^7')
                Page.notice('msg.open_failed', 'error')
                return Hall.close()
            end
            if t > 3000 and session.opened then
                if (IsScreenFadedOut() or IsScreenFadingOut()) and not IsScreenFadingIn() then DoScreenFadeIn(250) end
                if not freed then
                    freed = true
                    Page.send('dealer:loading', { done = true })
                    Page.focus(true)
                end
            end
            Wait(250)
        end
    end)
end

local function enter(dealer, vehicles, money, focus)
    local hall = setOf(dealer.id)
    if not hall then return Page.notice('msg.no_hall', 'error') end
    H, PITCH = hall, hall.bays[2] - hall.bays[1]
    TURN = { math.cos(math.rad(H.heading or 0.0)), math.sin(math.rad(H.heading or 0.0)) }
    -- A hall is an interior: the game knows it (its proxy) before it streams in. Without one the focus never goes there:
    -- an MLO streaming in with no proxy crashes the game. A row on the water has no room.
    local interior
    if H.room then
        interior = GetInteriorAtCoords(H.position.x, H.position.y, H.position.z + 1.0)
        if interior == 0 or not IsValidInterior(interior) then return Page.notice('msg.no_hall', 'error') end
    end
    S = {
        dealer = dealer.id, interior = interior, room = interior and joaat(H.room), sea = not interior,
        heading = (H.carHeading + (H.heading or 0.0)) % 360.0,
        list = {}, index = 1, slot = {}, cars = {}, used = {}, requested = {}, x = 0.0, back = 0.0, buy = 0.0,
    }
    -- a used car's props and dents stay here for its bay; the page gets the rest
    for _, v in ipairs(vehicles) do
        if v.used then
            S.used['used:' .. v.used.id] = { model = v.model, props = v.used.props, dents = v.used.dents, body = v.used.body, engine = v.used.engine }
            v.used.props, v.used.dents = nil, nil
        end
    end
    local session = S
    Hall.active = true
    -- the page's loading screen covers the way in; the first row (Hall.show) or the watchdog takes it away
    Page.send('dealer:loading', { label = dealer.label })
    watchdog(session)
    DoScreenFadeOut(300)
    Wait(320)
    -- closed meanwhile (Esc, a test drive, another script): Hall.close already undid it all
    if not live(session) then return false end
    FreezeEntityPosition(PlayerPedId(), true)
    -- the dealership's own bucket (everyone browsing it hears each other); night in the hall, the water keeps its hour
    TriggerServerEvent('daddy_dealerships:room', dealer.id, true)
    if S.interior then Bridge.night(true) end
    local from, look = shot(0.0, 0.0, 0.0)
    SetFocusPosAndVel(from.x, from.y, from.z, 0.0, 0.0, 0.0)
    if S.interior then
        PinInteriorInMemory(S.interior)
        local stop = GetGameTimer() + 8000
        while live(session) and not IsInteriorReady(session.interior) and GetGameTimer() < stop do Wait(0) end
        if not live(session) then return false end
    end
    S.cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', from.x, from.y, from.z, 0.0, 0.0, 0.0, H.camera.fov + 0.0, false, 2)
    pcall(function() exports['FeloxAC']:createCam(S.cam) end) --[[FeloxAC:auto]]
    PointCamAtCoord(S.cam, look.x, look.y, look.z)
    SetCamActive(S.cam, true)
    RenderScriptCams(true, false, 0, true, false)
    primehud(false)
    if S.interior then ForceRoomForGameViewport(S.interior, S.room) end
    frames(session)
    session.opened = true
    Page.send('dealer:open', { dealer = dealer, vehicles = vehicles, money = money, focus = focus })
    Page.focus(true)
    return true
end

-- Opens the hall; any error on the way in undoes it all (camera, focus, frozen ped, black screen), so the next E works.
function Hall.open(...)
    local ok, res = pcall(enter, ...)
    if ok then return res == true end
    print(('^1[daddy_dealerships] hall open failed: %s^7'):format(tostring(res)))
    Page.notice('msg.open_failed', 'error')
    if Hall.active or S then Hall.close() end
    return false
end

-- The car on screen: the corners of its model's box seen by the camera, 0-1 across and down.
local function screenBox(veh)
    local min, max = GetModelDimensions(GetEntityModel(veh))
    local x0, y0, x1, y1 = 1.0, 1.0, 0.0, 0.0
    for _, cx in ipairs({ min.x, max.x }) do
        for _, cy in ipairs({ min.y, max.y }) do
            for _, cz in ipairs({ min.z, max.z }) do
                local p = GetOffsetFromEntityInWorldCoords(veh, cx, cy, cz)
                local seen, sx, sy = GetScreenCoordFromWorldCoord(p.x, p.y, p.z)
                if seen then x0, y0, x1, y1 = math.min(x0, sx), math.min(y0, sy), math.max(x1, sx), math.max(y1, sy) end
            end
        end
    end
    return { x0 = x0, y0 = y0, x1 = x1, y1 = y1 }
end

-- Pictures (/carphotos): a dealership's hall with one car at a time in the middle bay, in its first colours, the camera
-- and the lights as the row has them. shoot(model, box) takes each picture (box: the car on screen); stop() ends the
-- run after the car being shot. Only a hall set (an interior) is a studio.
local function studio(id, models, shoot, stop)
    local hall = setOf(id)
    if Hall.active or not hall or not hall.room then return false end
    H, PITCH = hall, hall.bays[2] - hall.bays[1]
    TURN = { math.cos(math.rad(H.heading or 0.0)), math.sin(math.rad(H.heading or 0.0)) }
    local interior = GetInteriorAtCoords(H.position.x, H.position.y, H.position.z + 1.0)
    if interior == 0 or not IsValidInterior(interior) then return false end
    S = {
        dealer = id, interior = interior, room = joaat(H.room), sea = false, heading = (H.carHeading + (H.heading or 0.0)) % 360.0,
        list = {}, index = 1, slot = {}, cars = {}, used = {}, x = 0.0, back = 0.0, buy = 0.0,
    }
    local session = S
    Hall.active = true
    DoScreenFadeOut(300)
    Wait(320)
    if not live(session) then return false end
    FreezeEntityPosition(PlayerPedId(), true)
    Bridge.night(true)
    local from, look = shot(0.0, 0.0, 0.0)
    SetFocusPosAndVel(from.x, from.y, from.z, 0.0, 0.0, 0.0)
    PinInteriorInMemory(S.interior)
    local ready = GetGameTimer() + 8000
    while live(session) and not IsInteriorReady(session.interior) and GetGameTimer() < ready do Wait(0) end
    if not live(session) then return false end
    S.cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', from.x, from.y, from.z, 0.0, 0.0, 0.0, H.camera.fov + 0.0, false, 2)
    pcall(function() exports['FeloxAC']:createCam(S.cam) end) --[[FeloxAC:auto]]
    SetCamActive(S.cam, true)
    RenderScriptCams(true, false, 0, true, false)
    primehud(false)
    ForceRoomForGameViewport(S.interior, S.room)
    frames(session)
    DoScreenFadeIn(300)
    for _, model in ipairs(models) do
        if stop() or not S then break end
        S.list, S.index, S.back = { model }, 1, reachFor(model)
        fill(0)
        local until_ = GetGameTimer() + 10000
        while S and not S.slot[0] and GetGameTimer() < until_ do Wait(50) end
        local veh = S and S.slot[0]
        if veh then
            SetVehicleColourCombination(veh, 0)
            SetVehicleNumberPlateText(veh, Config.Photos.Plate)
            -- the camera's distance follows the car, its textures stream in, the frame lags the game by a few
            Wait(1200)
            shoot(model, screenBox(veh))
            remove(veh)
            S.slot[0] = nil
        end
        SetModelAsNoLongerNeeded(joaat(model))
    end
    Hall.close()
    return true
end

-- The picture run; an error in it gives the game back like the row does.
function Hall.studio(...)
    local ok, res = pcall(studio, ...)
    if ok then return res end
    print(('^1[daddy_dealerships] hall studio failed: %s^7'):format(tostring(res)))
    if Hall.active or S then Hall.close() end
    return false
end

-- One step of the way out: an error in it is printed and the next step still runs (one bad entity or a missing
-- export must never leave the scripted camera on, the focus in the hall or the screen black).
local function step(what, fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then print(('^1[daddy_dealerships] hall close: %s failed: %s^7'):format(what, tostring(err))) end
end

-- dark: the screen stays black (what comes next fades it in); away: the player is moved elsewhere next and stays frozen
-- for it (Core.land there lets them go). Only true counts: CreateThread(Hall.close) once handed the scheduler's own
-- argument in as dark, and the Esc way out stayed black.
function Hall.close(dark, away)
    dark, away = dark == true, away == true
    Core.debug('hall close: dark=%s away=%s active=%s closing=%s', tostring(dark), tostring(away), tostring(Hall.active), tostring(Hall.closing))
    if (not Hall.active and not S) or Hall.closing then return end
    Hall.active, Hall.closing = false, true
    local session = S
    if session then
        session.token = (session.token or 0) + 1
        session.slide = nil
        session.moving = false
    end
    step('page', Page.focus, false)
    step('page', Page.send, 'dealer:close')
    DoScreenFadeOut(200)
    Wait(210)
    -- the camera and the focus first: they are what keeps the picture away from the player
    RenderScriptCams(false, false, 0, true, false)
    step('focus', ClearFocus)
    step('room', ClearRoomForGameViewport)
    if session then
        if session.cam then pcall(function() exports['FeloxAC']:destroyCam(session.cam) end) --[[FeloxAC:auto]] step('camera', DestroyCam, session.cam, false) end
        for slot = -REACH, REACH do step('car', remove, session.slot[slot]) end
        for hash in pairs(session.requested or {}) do step('model', SetModelAsNoLongerNeeded, hash) end
        if session.interior then step('interior', UnpinInterior, session.interior) end
    end
    step('bucket', TriggerServerEvent, 'daddy_dealerships:room', nil, false)
    step('night', Bridge.night, false)
    S = nil
    -- the streets round the player streamed out while the focus was in the hall; they come back before the picture does
    if not away then
        step('land', Core.land)
        FreezeEntityPosition(PlayerPedId(), false)
    end
    Hall.closing = false
    Core.debug('hall close: done, faded out=%s fading out=%s cam=%d', tostring(IsScreenFadedOut()), tostring(IsScreenFadingOut()), GetRenderingCam())
    -- whatever got out of step, the game has the input back (the pause menu will not open while any focus is held)
    SetNuiFocus(false, false)
    if not dark then
        DoScreenFadeIn(300)
        -- the bucket change re-streams the world: should anything fade the screen out again meanwhile, it comes back
        CreateThread(function()
            local stop = GetGameTimer() + 4000
            while GetGameTimer() < stop and not Hall.active do
                if (IsScreenFadedOut() or IsScreenFadingOut()) and not IsScreenFadingIn() then
                    Core.debug('hall close: screen went dark again, fading in')
                    DoScreenFadeIn(250)
                end
                Wait(100)
            end
        end)
    end
    -- the HUD comes back with the picture: shown while the screen is still black it stays hidden
    CreateThread(function()
        local stop = GetGameTimer() + 3000
        while GetGameTimer() < stop and not Hall.active and (IsScreenFadedOut() or IsScreenFadingOut()) do Wait(50) end
        if not Hall.active then primehud(true) end
    end)
end

Page.on('dealer:list', function(data)
    if type(data.models) ~= 'table' then return { ok = false } end
    CreateThread(function() Hall.show(data.models, tonumber(data.index)) end)
end)
Page.on('dealer:slide', function(data) return { ok = Hall.slide(tonumber(data.dir) == -1 and -1 or 1) } end)
Page.on('dealer:pose', function(data) Hall.pose(data.buy == true) end)
Page.on('dealer:paint', function(data) Hall.paint(tonumber(data.colour), data.rgb) end)
Page.on('dealer:action', function(data) Hall.action(tostring(data.kind or '')) end)
Page.on('dealer:close', function()
    Core.debug('page close: panel=%s hall=%s', tostring(Panel.active), tostring(Hall.active))
    if Panel.active then return Panel.close() end
    if Hall.active then return CreateThread(function() Hall.close() end) end
    -- neither is open here, yet the page asked: whatever got out of step, the player gets the game back
    if not Hall.closing then
        Page.focus(false)
        SetNuiFocus(false, false)
        Page.send('dealer:close')
    end
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    if Hall.active then
        for slot = -REACH, REACH do remove(S.slot[slot]) end
        for hash in pairs(S and S.requested or {}) do SetModelAsNoLongerNeeded(hash) end
        RenderScriptCams(false, false, 0, true, false)
        primehud(true)
        if S and S.cam then pcall(function() exports['FeloxAC']:destroyCam(S.cam) end) --[[FeloxAC:auto]] DestroyCam(S.cam, false) end
        ClearFocus()
        ClearRoomForGameViewport()
        if S and S.interior then UnpinInterior(S.interior) end
        FreezeEntityPosition(PlayerPedId(), false)
        Bridge.night(false)
        Page.focus(false)
        DoScreenFadeIn(0)
    end
end)
