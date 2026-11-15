-- The garage flow: opening a garage (the server's cars dressed for the page), the page's callbacks, taking a car out
-- (the exit move) and parking one (the park scene).
Garage = { current = nil, cars = {}, busy = false, shown = false, session = 0 }
local G = Garage

-- The card picture: images/<model>.webp in this resource, then Config.Images.Fallback; the page tries them in turn.
local function pictures(model)
    local name = (type(model) == 'string' and model or GetDisplayNameFromVehicleModel(model)):lower()
    local fallback = Config.Images.Fallback
    return ('nui://%s/images/%s.webp'):format(GetCurrentResourceName(), name), fallback and fallback:format(name) or nil
end

-- One server car as the page draws it: names, class, picture and service added; the props stay in Lua.
function G.dress(car)
    local make, name = Car.names(car.model)
    local perf = Car.performance(car.model, car.props)
    local image, fallback = pictures(car.model)
    local every = Config.Service.EveryKm
    return {
        plate = car.plate, model = type(car.model) == 'string' and car.model or name, make = make, name = name,
        nickname = car.nickname, type = Car.garageType(car.model), state = car.state, garage = car.garage,
        sharedBy = car.sharedBy, favourite = car.favourite, fuel = car.fuel, engine = car.engine, body = car.body,
        km = car.km, service = every > 0 and (every - car.km % every) or 99999, lastUsed = car.lastUsed,
        stats = perf.stats, stock = perf.stock, topSpeed = perf.topSpeed, drive = '', seats = perf.seats, mass = 0,
        parts = perf.parts, turbo = perf.turbo, xenon = perf.xenon, returnFee = car.returnFee,
        history = {}, keys = {}, image = car.image or image, fallback = fallback, impound = car.impound, ownerName = car.ownerName,
    }
end

local function fail(res)
    Page.notice('msg.' .. (type(res) == 'table' and res.err or 'failed'), 'error')
    Page.sound('error')
end

-- Opening and closing ----------------------------------------------------------------------------------------------------

-- temp: { type, spawn } when another script opens a garage of its own (a house garage).
function G.open(garageId, temp)
    if G.busy or Page.open or Showroom.active() then return end
    if not Page.await(5000) then return Page.notice('msg.page_missing', 'error') end
    G.busy = true
    local res = lib.callback.await('daddy_garages:open', false, garageId, temp)
    G.busy = false
    if not res or not res.ok then return fail(res) end

    G.current, G.cars = res.garage, {}
    local list = {}
    for _, car in ipairs(res.cars or {}) do
        if car.model and (Car.garageType(car.model) == res.garage.type or car.state == 'impound') then
            G.cars[car.plate] = car
            list[#list + 1] = G.dress(car)
        end
    end
    res.garage.used = #list
    if not Showroom.start(res.spot) then return end
    Bridge.hint(nil)
    Page.open, G.shown = true, false
    G.session = G.session + 1
    -- The fleet log names its cars here (the server knows only models).
    local fleet = {}
    for i, trip in ipairs(res.fleet or {}) do
        local name = trip.model ~= '' and select(2, Car.names(trip.model)) or trip.plate
        fleet[i] = { plate = trip.plate, car = name, driver = trip.driver, out = trip.out, back = trip.back, km = trip.km, fuel = trip.fuel, body = trip.body }
    end
    Page.send('garage:open', {
        garage = res.garage, cars = list, places = res.places, people = res.people, fleet = fleet, business = res.business,
        pad = Page.isPad(), prefs = Prefs,
        -- the texts ride along every open: the page's one boot ask can be lost, which left every label empty
        locale = Core.locale(), lang = Core.language(), theme = { accent = Config.Theme.Accent },
        rules = { offers = Config.Transfer.Offers ~= false, keys = Config.Keys.Enabled ~= false, keyDays = Config.Keys.MaxDays, feeMin = Config.Business.MinFee, feeMax = Config.Business.MaxFee, phone = res.phone == true },
    })
    TriggerServerEvent('daddy_garages:pictures')
    -- The page waits hidden for the camera; a first car slow to load lets it in anyway, with its loading line.
    local session = G.session
    SetTimeout(1500, function()
        if G.session == session and Showroom.waiting() then G.reveal() end
    end)
end

-- The page comes in (and takes the input) as the camera nears its place, or at once without a car to show.
function G.reveal()
    if not Page.open or G.shown then return end
    G.shown = true
    -- The studio's dip to black ends here when no car came to open it.
    if IsScreenFadedOut() or IsScreenFadingOut() then DoScreenFadeIn(Page.ms(400)) end
    Page.send('garage:reveal')
    Page.focus(true)
    Page.sound('select')
end

-- The page goes; the copy fades out as the camera glides back to the game camera.
function G.close()
    Page.open = false
    Page.focus(false)
    Page.send('garage:close')
    Showroom.leave()
    lib.callback('daddy_garages:close', false, function() end)
    G.current = nil
    Page.sound('back')
end

-- Taking a car out -------------------------------------------------------------------------------------------------------
do
    -- One short blip of the throttle as the picture comes back (off with the sound setting).
    local function rev(veh)
        CreateThread(function()
            Wait(Page.ms(700))
            for i = 1, 14 do
                SetVehicleCurrentRpm(veh, 0.35 + 0.55 * math.sin(i / 14 * math.pi))
                Wait(35)
            end
        end)
    end

    -- The page goes and the camera eases in on the copy while the server makes the real car, hidden here until its
    -- look is on. Then the real car takes the copy's place with the player in it, keys given and engine running, and the
    -- camera rises behind it into the game camera.
    local function takeOut(plate, act, look)
        local car = G.cars[plate]
        if not car or G.busy then return end
        G.busy = true
        Page.open = false
        Page.focus(false)
        Page.send('garage:close')
        Showroom.wait()
        look = look or {}
        local res = lib.callback.await('daddy_garages:takeOut', false, plate, act, { vtype = Car.spawnType(car.model), livery = look.livery, extras = look.extras })
        if not res or not res.ok then
            G.busy = false
            Showroom.leave()
            return fail(res)
        end
        -- An impounded boat or aircraft paid for at a lot it cannot leave from went to a garage of its type.
        if res.sent then
            G.current, G.busy = nil, false
            Showroom.leave()
            return Page.notice('msg.sent_home', 'success', res.sent)
        end

        local veh, stop = 0, GetGameTimer() + 8000
        while veh == 0 and GetGameTimer() < stop do
            if NetworkDoesEntityExistWithNetworkId(res.netId) then veh = NetToVeh(res.netId) end
            Wait(0)
        end
        local dressed = false
        if veh ~= 0 then
            Showroom.incoming(veh)
            if type(res.dress) == 'table' then
                NetworkRequestControlOfEntity(veh)
                local waitCtrl = GetGameTimer() + 150
                while DoesEntityExist(veh) and not NetworkHasControlOfEntity(veh) and GetGameTimer() < waitCtrl do
                    NetworkRequestControlOfEntity(veh)
                    Wait(0)
                end
                if DoesEntityExist(veh) and NetworkHasControlOfEntity(veh) then
                    Car.dress(veh, res.dress)
                    dressed = true
                    TriggerServerEvent('daddy_garages:applied', res.netId)
                end
            else
                local settled = GetGameTimer() + 400
                while Entity(veh).state['daddy_garages:props'] and GetGameTimer() < settled do Wait(0) end
            end
        end
        if res.fee and res.fee > 0 then Page.notice('msg.paid', 'info', res.fee) end
        local function seat()
            if not DoesEntityExist(veh) then return end
            -- A spot saved where someone stood is a metre up; the car is set down on its wheels instead of dropping.
            if NetworkHasControlOfEntity(veh) and GetVehicleClass(veh) ~= 14 then SetVehicleOnGroundProperly(veh) end
            if Config.Vehicles.WarpIn then TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1) end
            if type(res.dress) == 'table' and not dressed then
                local waitCtrl = GetGameTimer() + 250
                while DoesEntityExist(veh) and not NetworkHasControlOfEntity(veh) and GetGameTimer() < waitCtrl do
                    NetworkRequestControlOfEntity(veh)
                    Wait(0)
                end
                if DoesEntityExist(veh) then
                    Car.dress(veh, res.dress)
                    TriggerServerEvent('daddy_garages:applied', res.netId)
                end
            end
            if IsVehicleModLoadDone then
                local waitMods = GetGameTimer() + 200
                while DoesEntityExist(veh) and not IsVehicleModLoadDone(veh) and GetGameTimer() < waitMods do Wait(0) end
            end
            -- Keys for the plate it wears and, under a fake one, its own too (key scripts check either).
            local shown = Core.trim(GetVehicleNumberPlateText(veh), 16) or res.shown or car.plate
            Bridge.keys.give(veh, shown)
            if res.plate and Core.plate(shown) ~= res.plate then Bridge.keys.give(veh, res.plate) end
            SetVehicleEngineOn(veh, true, true, false)
            if Prefs.sound then rev(veh) end
        end
        if veh ~= 0 then
            Showroom.driveOff(veh, seat)
        else
            -- The car never reached this client: it counts as out and comes back from any garage.
            Showroom.leave()
            Page.notice('msg.failed', 'error')
        end
        G.current, G.busy = nil, false
    end

    -- An error mid take-out must not leave the screen black or the camera stuck: it is printed and the view comes back.
    function G.takeOut(plate, act, look)
        local ok, err = pcall(takeOut, plate, act, look)
        if ok then return end
        print(('^1[daddy_garages] take-out failed: %s^7'):format(err))
        G.current, G.busy = nil, false
        pcall(Showroom.stop, 0)
        DoScreenFadeIn(300)
    end
end

-- Parking ----------------------------------------------------------------------------------------------------------------

-- No seat taken (the game has no IsVehicleEmpty native).
local function vehicleEmpty(veh)
    for seat = -1, GetVehicleMaxNumberOfPassengers(veh) - 1 do
        if not IsVehicleSeatFree(veh, seat) then return false end
    end
    return true
end

-- Another player sits in the car (the parking driver may still be in it: no fade then, the car goes from under them).
local function othersIn(veh, ped)
    for seat = -1, GetVehicleMaxNumberOfPassengers(veh) - 1 do
        local who = GetPedInVehicleSeat(veh, seat)
        if who ~= 0 and who ~= ped then return true end
    end
    return false
end

-- The server is asked first, so a refusal leaves the player in the car. Then the car halts, the picture cuts to a low
-- shot at the driver's door and slides along the car as the lights and engine go off and the driver steps out; the car
-- fades out for everyone, is stored, and the camera glides back behind the player as the parked card rises.
function G.park(garageId)
    if G.busy or Showroom.active() then return end
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 or GetPedInVehicleSeat(veh, -1) ~= ped then return Page.notice('msg.not_driver', 'error') end
    G.busy = true
    local netId = NetworkGetNetworkIdFromEntity(veh)
    local check = lib.callback.await('daddy_garages:canPark', false, garageId, netId)
    if not check or not check.ok then
        G.busy = false
        return fail(check)
    end

    local stop = GetGameTimer() + 1500
    if GetEntitySpeed(veh) > 0.5 then BringVehicleToHalt(veh, 2.0, 1, false) end
    while GetEntitySpeed(veh) > 0.5 and GetGameTimer() < stop do Wait(0) end
    local data = Car.read(veh)
    local model = GetEntityModel(veh)
    local plate = Core.plate(GetVehicleNumberPlateText(veh))
    local ms = Page.ms(2200)
    if ms > 0 then
        local door, along = Showroom.parkShots(veh)
        Director.start(door)
        Director.around(veh, { along }, ms, 'smooth')
    end
    SetVehicleLights(veh, 1)
    SetVehicleEngineOn(veh, false, false, false)
    TaskLeaveVehicle(ped, veh, 0)
    stop = GetGameTimer() + 3000
    while IsPedInVehicle(ped, veh, false) and GetGameTimer() < stop do Wait(50) end
    -- The fade takes whoever still sits inside with it (they would stay invisible): wait for the passengers to be out.
    stop = GetGameTimer() + 3000
    while not vehicleEmpty(veh) and GetGameTimer() < stop do Wait(50) end
    if ms > 0 and vehicleEmpty(veh) then
        NetworkFadeOutEntity(veh, true, false)
        stop = GetGameTimer() + 1500
        while NetworkIsEntityFading(veh) and GetGameTimer() < stop do Wait(0) end
        while Director.moving() do Wait(0) end
    end
    -- Someone got in while the car faded: it stays out and fades back with them (the store would delete them with it).
    local res = { ok = false, err = 'occupied' }
    if not othersIn(veh, ped) then res = lib.callback.await('daddy_garages:store', false, garageId, netId, data) end
    if (not res or not res.ok) and ms > 0 and DoesEntityExist(veh) then NetworkFadeInEntity(veh, true) end
    if Director.active() then
        -- The game camera looks the way ours does, so the way back is short.
        Director.aimGame(Director.pose())
        Director.toGame(Page.ms(900), 'inOutSine', function() Director.stop(150) end, 0.4)
    end
    G.busy = false
    if not res or not res.ok then return fail(res) end
    local make, name = Car.names(model)
    local image = pictures(model)
    Page.send('garage:parked', { car = { plate = plate, make = make, name = name, stats = Car.performance(model, data.props).stats, image = image } })
    Page.sound('select')
end

-- The page's callbacks -----------------------------------------------------------------------------------------------------
do
    local function carOf(data)
        return G.current and G.cars[data.plate] or nil
    end

    -- The chosen car goes on the stand; its neighbours in the list load ahead. No car (an empty list): the page comes in.
    Page.on('garage:focus', function(data)
        local car = carOf(data)
        local models = {}
        if car then models[1] = car.model end
        for _, plate in ipairs(type(data.near) == 'table' and data.near or {}) do
            local other = G.current and G.cars[plate]
            if other then models[#models + 1] = other.model end
        end
        Showroom.preload(models)
        if car then Showroom.show({ model = car.model, props = car.props, plate = car.plate }) else G.reveal() end
    end)

    Page.on('garage:shot', function(data) Showroom.shot(data.shot) end)
    Page.on('garage:doors', function(data) Showroom.doors(data.open == true) end)
    Page.on('garage:orbit', function(data) Showroom.orbit(data.dx, data.dy, data.wheel) end)
    Page.on('garage:wake', function() Showroom.wake() end)

    Page.on('garage:close', function()
        if Page.open then G.close() else Page.focus(false) end
    end)

    Page.on('garage:drive', function(data)
        if not carOf(data) then return end
        if data.act == 'release' then
            local res = lib.callback.await('daddy_garages:release', false, data.plate)
            if not res or not res.ok then return fail(res) end
            Page.send('garage:remove', { plate = data.plate })
            return Page.notice('msg.released', 'success', data.plate)
        end
        CreateThread(function() G.takeOut(data.plate, data.act, { livery = data.livery, extras = data.extras }) end)
    end)

    -- An offer to a nearby player (or the instant hand-over when offers are off).
    Page.on('garage:offer', function(data)
        local res = carOf(data) and lib.callback.await('daddy_garages:offer', false, data.plate, data.to, data.price)
        if not res or not res.ok then return fail(res) end
        if res.done then Page.send('garage:remove', { plate = data.plate }) end
        Page.notice(res.done and 'msg.given' or 'msg.offer_sent', 'success')
    end)

    Page.on('garage:giveKey', function(data)
        local res = carOf(data) and lib.callback.await('daddy_garages:giveKey', false, data.plate, data.to, data.days)
        if not res or not res.ok then
            fail(res)
            return { ok = false }
        end
        return res
    end)

    -- The owner's page: the fee, and taking the till.
    Page.on('garage:businessFee', function(data)
        local res = lib.callback.await('daddy_garages:businessFee', false, data.fee)
        if not res or not res.ok then return fail(res) end
        Page.notice('msg.fee_saved', 'success')
    end)

    Page.on('garage:withdraw', function(data)
        local res = lib.callback.await('daddy_garages:withdraw', false, data.amount)
        if not res or not res.ok then
            fail(res)
            return { ok = false }
        end
        Page.notice('msg.paid_out', 'success', data.amount)
        return res
    end)

    Page.on('garage:takeKey', function(data)
        if carOf(data) then lib.callback('daddy_garages:takeKey', false, function() end, data.plate, data.name) end
    end)

    Page.on('garage:favourite', function(data)
        lib.callback('daddy_garages:favourite', false, function() end, data.plate, data.on == true)
    end)

    Page.on('garage:rename', function(data)
        lib.callback('daddy_garages:rename', false, function() end, data.plate, data.name)
    end)

    -- History and keys when the details open.
    Page.on('garage:detail', function(data)
        if not carOf(data) then return end
        lib.callback('daddy_garages:detail', false, function(detail)
            if detail then Page.send('garage:car', { plate = data.plate, patch = detail }) end
        end, data.plate)
    end)

    -- Nerede: the outside car's spot from the server; the camera flies there and the page gets street, zone, km, time.
    Page.on('garage:locate', function(data)
        if not data.on then return Showroom.locate(nil) end
        local p = carOf(data) and lib.callback.await('daddy_garages:locate', false, data.plate)
        if not p then return {} end
        local point = vector3(p.x, p.y, p.z)
        Showroom.locate(point)
        local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(p.x, p.y, p.z))
        local zone = GetLabelText(GetNameOfZone(p.x, p.y, p.z))
        local km = #(GetEntityCoords(PlayerPedId()) - point) / 1000.0
        return { street = street, zone = zone ~= 'NULL' and zone or '', km = math.floor(km * 10 + 0.5) / 10, at = p.at or 0 }
    end)

    -- A waypoint on the outside car, or on the nearest impound lot.
    Page.on('garage:waypoint', function(data)
        if data.impound then
            local here, best, bestDist = GetEntityCoords(PlayerPedId()), nil, math.huge
            for _, g in pairs(Zones.all()) do
                if g.kind == 'impound' and #(g.coords - here) < bestDist then best, bestDist = g, #(g.coords - here) end
            end
            if best then SetNewWaypoint(best.coords.x, best.coords.y) end
            return
        end
        local p = carOf(data) and lib.callback.await('daddy_garages:locate', false, data.plate)
        if p then SetNewWaypoint(p.x, p.y) end
    end)

    -- Moving a parked car to another garage.
    Page.on('garage:transfer', function(data)
        local res = carOf(data) and lib.callback.await('daddy_garages:move', false, data.plate, data.to)
        if not res or not res.ok then return fail(res) end
        local place = Zones.all()[data.to]
        Page.send('garage:car', { plate = data.plate, patch = { state = 'elsewhere', garage = place and place.label or data.to } })
        Page.notice('msg.moved', 'success', place and place.label or data.to)
    end)

    -- The taken frame: a small card picture (sent latent, it is too big for a normal event), or the link of a photo the
    -- page uploaded for the phone gallery.
    local saving = {}
    RegisterNetEvent('daddy_garages:pictureSaved', function(plate, ok)
        if not plate or not saving[plate] then return end
        saving[plate]:resolve(ok == true)
        saving[plate] = nil
    end)

    Page.on('garage:frame', function(data)
        if data.kind == 'phone' then
            return { ok = lib.callback.await('daddy_garages:frame', false, data.url) == true }
        end
        local car = G.cars[data.plate]
        if not car or type(data.url) ~= 'string' or data.url == '' then return { ok = false } end
        local p = promise.new()
        saving[data.plate] = p
        TriggerLatentServerEvent('daddy_garages:picture', 100000, data.plate, data.url)
        SetTimeout(20000, function()
            if saving[data.plate] == p then saving[data.plate] = nil p:resolve(false) end
        end)
        local ok = Citizen.Await(p)
        if ok then car.image = data.url end
        return { ok = ok }
    end)

    -- Where the page uploads a phone photo (the server's setting), or nothing when it is off.
    Page.on('garage:uploadTarget', function()
        return lib.callback.await('daddy_garages:uploadTarget', false) or {}
    end)

    -- Card pictures come after the list, as a latent event.
    RegisterNetEvent('daddy_garages:pictures', function(pictures)
        if not Page.open or type(pictures) ~= 'table' then return end
        for plate, image in pairs(pictures) do
            if G.cars[plate] then
                G.cars[plate].image = image
                Page.send('garage:car', { plate = plate, patch = { image = image } })
            end
        end
    end)

    Page.on('garage:photo', function(data) Showroom.photo(data.on == true, data.look) end)
    Page.on('garage:look', function(data) Showroom.look(data.id) end)

    -- A frame of the game for photo mode (screenshot-basic); the page shows it until it is used or dropped.
    Page.on('garage:snap', function()
        if not Bridge.started('screenshot-basic') then return {} end
        local p = promise.new()
        exports['screenshot-basic']:requestScreenshot({ encoding = 'jpg', quality = 0.9 }, function(dataUri) p:resolve(dataUri) end)
        local url = Citizen.Await(p)
        return { url = url }
    end)
end
