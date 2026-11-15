-- Client vehicle helpers: names, the spawn type a model needs, the performance class, applying a car's saved state when
-- it comes out (through its state bag) and reading it when it is parked.
Car = {}

-- Names and types -------------------------------------------------------------------------------------------------------
do
    -- A model as a hash (rows keep a name or a hash).
    function Car.hash(model)
        return type(model) == 'number' and model or joaat(tostring(model))
    end

    local function label(key)
        if not key or key == '' or key == 'CARNOTFOUND' then return nil end
        local text = GetLabelText(key)
        return text ~= 'NULL' and text or nil
    end

    -- { make, name } of a model: the config override, the game's labels, else the model name.
    function Car.names(model)
        local hash = Car.hash(model)
        local override = Config.Vehicles.LabelOverrides[type(model) == 'string' and model or '']
        local display = GetDisplayNameFromVehicleModel(hash)
        local name = override or label(display) or (type(model) == 'string' and model) or display
        local make = label(GetMakeNameFromVehicleModel(hash)) or ''
        return make, name
    end

    -- The type CreateVehicleServerSetter needs for a model, from its class.
    local BY_CLASS = { [8] = 'bike', [13] = 'bike', [14] = 'boat', [15] = 'heli', [16] = 'plane', [21] = 'train' }

    function Car.spawnType(model)
        local hash = Car.hash(model)
        local kind = BY_CLASS[GetVehicleClassFromName(hash)] or 'automobile'
        -- The boats' class holds the submarines too.
        if kind == 'boat' and not IsThisModelABoat(hash) and not IsThisModelAJetski(hash) then return 'submarine' end
        return kind
    end

    -- The garage type a model belongs in: car | sea | air.
    function Car.garageType(model)
        return Core.typeOf(Car.spawnType(model))
    end
end

-- Performance: four bars from the game's model numbers (stock) and what the fitted parts add (Forza's class letters
-- are drawn by the page) -------------------------------------------------------------------------------------------------
do
    local function bar(value, cap)
        return math.floor(math.max(0.0, math.min(10.0, (value / cap) * 10.0)) * 10 + 0.5) / 10
    end

    -- Rough share each fitted level adds, from the game's upgrade tables.
    local function boosts(props)
        local engine = (tonumber(props.modEngine) or -1) + 1
        local gearbox = (tonumber(props.modTransmission) or -1) + 1
        local brakes = (tonumber(props.modBrakes) or -1) + 1
        local suspension = (tonumber(props.modSuspension) or -1) + 1
        local turbo = props.modTurbo == true or props.modTurbo == 1
        return {
            speed = 1.0 + engine * 0.012 + (turbo and 0.01 or 0.0),
            accel = 1.0 + engine * 0.035 + gearbox * 0.025 + (turbo and 0.05 or 0.0),
            braking = 1.0 + brakes * 0.06,
            handling = 1.0 + suspension * 0.02,
        }
    end

    -- { stats, stock, topSpeed (km/h), seats, parts, turbo, xenon } of a model with its props.
    function Car.performance(model, props)
        local hash = Car.hash(model)
        local caps = Config.Class.Caps
        local raw = {
            speed = GetVehicleModelEstimatedMaxSpeed(hash),
            accel = GetVehicleModelAcceleration(hash),
            braking = GetVehicleModelMaxBraking(hash),
            handling = GetVehicleModelMaxTraction(hash),
        }
        local up = boosts(props or {})
        local stock, stats = {}, {}
        for key, value in pairs(raw) do
            stock[key] = bar(value, caps[key])
            stats[key] = bar(value * up[key], caps[key])
        end
        local p = props or {}
        local level = function(v) return math.max(0, (tonumber(v) or -1) + 1) end
        return {
            stats = stats,
            stock = stock,
            topSpeed = math.floor(raw.speed * up.speed * 3.6),
            seats = GetVehicleModelNumberOfSeats(hash),
            parts = {
                engine = { level(p.modEngine), 4 },
                brakes = { level(p.modBrakes), 3 },
                gearbox = { level(p.modTransmission), 3 },
                suspension = { level(p.modSuspension), 4 },
                armour = { level(p.modArmor), 5 },
            },
            turbo = p.modTurbo == true or p.modTurbo == 1,
            xenon = p.modXenon == true or p.modXenon == 1,
            raw = raw,
        }
    end

    -- With Config.Debug: /garagestats prints the raw numbers of the car you sit in, to set Config.Class.Caps.
    if Config.Debug then
        RegisterCommand('garagestats', function()
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            if veh == 0 then return end
            local perf = Car.performance(GetEntityModel(veh), lib.getVehicleProperties(veh))
            print(json.encode({ raw = perf.raw, bars = perf.stats }))
        end, false)
    end
end

-- Saved state -----------------------------------------------------------------------------------------------------------
do
    local deformation = 'VehicleDeformation'

    -- Dents without that resource: the deformation sampled on a grid over the model's box (the deepest 80 spots kept),
    -- put back by denting the same spots a little at a time until each is about as deep again.
    local function readDents(veh)
        local min, max = GetModelDimensions(GetEntityModel(veh))
        local span = math.max(max.x - min.x, max.y - min.y, max.z - min.z)
        local step = math.max(0.4, span / 10.0)
        local cut = function(n, k) return math.floor(n * k + 0.5) / k end
        local points = {}
        for x = min.x, max.x, step do
            for y = min.y, max.y, step do
                for z = min.z, max.z, step do
                    local depth = #GetVehicleDeformationAtPos(veh, x, y, z)
                    if depth > 0.03 then points[#points + 1] = { cut(x, 100), cut(y, 100), cut(z, 100), cut(depth, 1000) } end
                end
            end
        end
        table.sort(points, function(a, b) return a[4] > b[4] end)
        for i = #points, 81, -1 do points[i] = nil end
        return points
    end

    -- By hash: this native has no Lua name on older game builds, and calling the missing name stopped the take-out.
    local function doorBreak(veh, door, on)
        pcall(Citizen.InvokeNative, 0x2FA133A4A9D37ED8, veh, door, on)
    end

    local function putDents(veh, points)
        for _ = 1, 4 do
            local short = false
            for _, p in ipairs(points) do
                local now = #GetVehicleDeformationAtPos(veh, p[1], p[2], p[3])
                if now < p[4] * 0.8 then
                    short = true
                    SetVehicleDamage(veh, p[1], p[2], p[3], math.min(800.0, (p[4] - now) * 1200.0 + 40.0), 0.45, true)
                end
            end
            if not short then return end
            Wait(0)
        end
    end

    -- Applies vehicle properties compatibly across ox_lib, qb-core and jg-mechanic (fixing ox_lib's RGB color1 + numeric
    -- color2 reset, missing paintType1/paintType2 on numeric colours, pearlescent reset after SetVehicleModColor_1,
    -- inverted boolean extras, modLivery and custom xenon RGB).
    function Car.setProps(veh, props, isLocal)
        if type(props) ~= 'table' or not DoesEntityExist(veh) then return end
        -- Daddy Mechanic owns how a car looks when it runs.
        if Bridge.started('daddy_mechanic') then
            exports.daddy_mechanic:setProps(veh, props)
            return
        end
        SetVehicleModKit(veh, 0)
        if props.modSpoilers or props.modFrontBumper or props.modRearBumper or props.modSideSkirt or props.modExhaust
            or props.modHood or props.modRoof or props.modEngine or props.modFrontWheels then
            local tries = 0
            while DoesEntityExist(veh) and GetNumVehicleMods(veh, 0) == 0 and GetNumVehicleMods(veh, 1) == 0
                and GetNumVehicleMods(veh, 11) == 0 and tries < 15 do
                Wait(10)
                SetVehicleModKit(veh, 0)
                tries = tries + 1
            end
            if not DoesEntityExist(veh) then return end
        end

        lib.setVehicleProperties(veh, props)

        local curPrimary, curSecondary = GetVehicleColours(veh)
        local curPearl, curWheel = GetVehicleExtraColours(veh)
        local c1 = props.color1 or props.customPrimaryColor
        local c2 = props.color2 or props.customSecondaryColor
        local p1 = type(c1) == 'number' and c1 or curPrimary
        local p2 = type(c2) == 'number' and c2 or curSecondary

        if type(c1) == 'number' or type(c2) == 'number' then
            if type(c1) == 'number' then ClearVehicleCustomPrimaryColour(veh) end
            if type(c2) == 'number' then ClearVehicleCustomSecondaryColour(veh) end
            SetVehicleColours(veh, p1, p2)
        end
        -- The paint type call also sets the colour index: it gets the saved one, or a plain colour turns black.
        if props.paintType1 ~= nil then
            SetVehicleModColor_1(veh, props.paintType1, p1, props.disablePearl and 0 or (props.pearlescentColor or 0))
        end
        if props.paintType2 ~= nil then
            SetVehicleModColor_2(veh, props.paintType2, p2)
        end
        if type(c1) == 'table' and c1[1] and c1[2] and c1[3] then
            SetVehicleCustomPrimaryColour(veh, c1[1], c1[2], c1[3])
        end
        if type(c2) == 'table' and c2[1] and c2[2] and c2[3] then
            SetVehicleCustomSecondaryColour(veh, c2[1], c2[2], c2[3])
        end
        if props.pearlescentColor ~= nil or props.wheelColor ~= nil or props.disablePearl ~= nil then
            local pearl = props.disablePearl and 0 or (props.pearlescentColor or curPearl)
            SetVehicleExtraColours(veh, pearl, props.wheelColor or curWheel)
        end

        if props.modFrontWheels then
            SetVehicleMod(veh, 23, props.modFrontWheels, (props.modCustomTiresF or props.modCustomFrontWheels) == true)
        end
        if props.modBackWheels then
            SetVehicleMod(veh, 24, props.modBackWheels, (props.modCustomTiresR or props.modCustomBackWheels) == true)
        end
        if props.modKit17 and not props.modNitrous then SetVehicleMod(veh, 17, props.modKit17, false) end
        if props.modKit19 and not props.modSubwoofer then SetVehicleMod(veh, 19, props.modKit19, false) end
        if props.modKit21 ~= nil and props.modHydraulics == nil then ToggleVehicleMod(veh, 21, props.modKit21 == true or props.modKit21 == 1) end
        if props.modKit47 and not props.modDoorR then SetVehicleMod(veh, 47, props.modKit47, false) end
        if props.modKit49 and not props.modLightbar then SetVehicleMod(veh, 49, props.modKit49, false) end
        if props.modLivery and props.modLivery >= 0 then
            SetVehicleMod(veh, 48, props.modLivery, false)
            SetVehicleLivery(veh, props.modLivery)
        end
        if props.livery and props.livery >= 0 then
            SetVehicleLivery(veh, props.livery)
        end
        if props.liveryRoof and not props.modRoofLivery then
            SetVehicleRoofLivery(veh, props.liveryRoof)
        end

        local xc = (props.xenonCustomColorEnabled and type(props.xenonCustomColor) == 'table' and props.xenonCustomColor)
            or (type(props.xenonColor) == 'table' and props.xenonColor)
            or (type(props.customXenonColor) == 'table' and props.customXenonColor)
        if xc and xc[1] and xc[2] and xc[3] then
            SetVehicleXenonLightsCustomColor(veh, xc[1], xc[2], xc[3])
        end

        if type(props.extras) == 'table' then
            for id, val in pairs(props.extras) do
                local numId = tonumber(id)
                if numId and DoesExtraExist(veh, numId) then
                    local disable = (type(val) == 'boolean') and (not val) or (val == 1)
                    SetVehicleExtra(veh, numId, disable)
                end
            end
        end

        if not isLocal and Bridge.started('jg-mechanic') then
            if props.enableStance ~= nil or props.tuningConfig ~= nil or props.lcInstalled ~= nil or props.servicingData ~= nil then
                pcall(function() exports['jg-mechanic']:setVehicleStatebagProperties(veh, props) end)
            end
        end
    end

    -- Applies the saved props, fuel, health, damage, livery and extras; the server's bag carries them. A car parked
    -- burning would catch fire again as it comes out: its engine and tank come back at no less than 0 (dead, not lit).
    function Car.apply(veh, data)
        if type(data) ~= 'table' or not DoesEntityExist(veh) then return end
        local props = data.props
        if props then
            if props.engineHealth then props.engineHealth = math.max(0.0, props.engineHealth + 0.0) end
            if props.tankHealth then props.tankHealth = math.max(0.0, props.tankHealth + 0.0) end
            Car.setProps(veh, props, false)
        end
        if data.engine then data.engine = math.max(0.0, data.engine + 0.0) end
        if data.plate then pcall(function() exports['FeloxAC']:ChangeVehiclePlate(veh, data.plate) end) --[[FeloxAC:auto]] SetVehicleNumberPlateText(veh, data.plate) end
        if data.engine then SetVehicleEngineHealth(veh, data.engine + 0.0) end
        if data.body then SetVehicleBodyHealth(veh, data.body + 0.0) end
        if data.livery then SetVehicleLivery(veh, data.livery) end
        if type(data.extras) == 'table' then
            for id = 0, 20 do
                if DoesExtraExist(veh, id) then SetVehicleExtra(veh, id, not Core.contains(data.extras, id)) end
            end
        end
        local damage = data.damage or {}
        if Config.Vehicles.SaveDamage and damage.deformation and Bridge.started(deformation) then
            pcall(function() exports[deformation]:SetVehicleDeformation(veh, damage.deformation) end)
        elseif Config.Vehicles.SaveDamage and type(damage.dents) == 'table' and #damage.dents > 0 then
            -- Denting must not knock off a door the car still had: those doors cannot break while the dents go on.
            local props = data.props or {}
            local kept = {}
            for i = 0, 5 do
                if not Core.contains(props.doors or {}, i) then
                    kept[#kept + 1] = i
                    doorBreak(veh, i, false)
                end
            end
            putDents(veh, damage.dents)
            -- A door may still drop a moment later: then the car loses the dents and keeps only its own breaks.
            CreateThread(function()
                local stop = GetGameTimer() + 1500
                while DoesEntityExist(veh) and GetGameTimer() < stop do
                    for _, i in ipairs(kept) do
                        if IsVehicleDoorDamaged(veh, i) then
                            SetVehicleFixed(veh)
                            SetVehicleDeformationFixed(veh)
                            lib.setVehicleProperties(veh, { windows = props.windows, doors = props.doors, tyres = props.tyres })
                            if data.engine then SetVehicleEngineHealth(veh, data.engine + 0.0) end
                            if data.body then SetVehicleBodyHealth(veh, data.body + 0.0) end
                            stop = 0
                            break
                        end
                    end
                    Wait(100)
                end
                if not DoesEntityExist(veh) then return end
                for _, i in ipairs(kept) do doorBreak(veh, i, true) end
            end)
            -- Denting costs health and may crack glass: the saved health and the whole windows come back.
            if data.engine then SetVehicleEngineHealth(veh, data.engine + 0.0) end
            if data.body then SetVehicleBodyHealth(veh, data.body + 0.0) end
            local broken = data.props and data.props.windows or {}
            for i = 0, 7 do
                if not Core.contains(broken, i) then FixVehicleWindow(veh, i) end
            end
        end
        Bridge.fuel.set(veh, data.fuel or (data.props and data.props.fuelLevel) or 100.0)
    end

    local function readProps(veh)
        if Bridge.started('daddy_mechanic') then return exports.daddy_mechanic:getProps(veh) end
        return lib.getVehicleProperties(veh)
    end

    -- How many of the saved parts and paints the car does not show (a numeric value read back unlike the saved one).
    local function missing(veh, props)
        local seen, n = readProps(veh) or {}, 0
        for key, want in pairs(props) do
            if type(key) == 'string' and type(want) == 'number' and (key:sub(1, 3) == 'mod' or key:find('olor') or key:find('paintType'))
                and seen[key] ~= nil and seen[key] ~= want then
                n = n + 1
            end
        end
        return n
    end

    -- Car.apply once, then (in the background) read back and put the look on again while parts or paint are missing
    -- (the mod kit or a part's model may load a moment late). Up to three tries; what never takes (a part this model
    -- lacks) stops counting once nothing changes. false when this car is already being dressed here.
    local dressing = {}
    function Car.dress(veh, data)
        if dressing[veh] then return false end
        dressing[veh] = true
        Car.apply(veh, data)
        local props = type(data) == 'table' and data.props
        if type(props) ~= 'table' then
            dressing[veh] = nil
            return true
        end
        CreateThread(function()
            local last
            for _ = 1, 3 do
                Wait(300)
                if not DoesEntityExist(veh) then break end
                local n = missing(veh, props)
                if n == 0 or n == last then break end
                last = n
                Car.setProps(veh, props, false)
                -- the livery and extras picked at take-out go back over the saved ones
                if data.livery then SetVehicleLivery(veh, data.livery) end
                if type(data.extras) == 'table' then
                    for id = 0, 20 do
                        if DoesExtraExist(veh, id) then SetVehicleExtra(veh, id, not Core.contains(data.extras, id)) end
                    end
                end
            end
            dressing[veh] = nil
        end)
        return true
    end

    -- The owner of a car that came out applies its state, then tells the server the bag can go. Every client waits a
    -- while to become the owner; the server sets the bag again when nobody applied it.
    AddStateBagChangeHandler('daddy_garages:props', nil, function(bagName, _, value)
        if not value then return end
        local veh = GetEntityFromStateBagName(bagName)
        local stop = GetGameTimer() + 5000
        while (veh == 0 or not DoesEntityExist(veh)) and GetGameTimer() < stop do
            Wait(0)
            veh = GetEntityFromStateBagName(bagName)
        end
        if veh == 0 then return end
        local mine = GetGameTimer() + 2000
        while DoesEntityExist(veh) and NetworkGetEntityOwner(veh) ~= PlayerId() and GetGameTimer() < mine do Wait(0) end
        if not DoesEntityExist(veh) or NetworkGetEntityOwner(veh) ~= PlayerId() or not Entity(veh).state['daddy_garages:props'] then return end
        if Car.dress(veh, value) then TriggerServerEvent('daddy_garages:applied', NetworkGetNetworkIdFromEntity(veh)) end
    end)

    -- A fuel script may give a car it has not seen a random tank: the saved fuel goes on again when the driver
    -- sits in (over the fuel script's first ticks), then the server drops the note.
    lib.onCache('seat', function(seat)
        if seat ~= -1 then return end
        CreateThread(function()
            Wait(0)
            local veh = cache.vehicle
            local fuel = veh and Entity(veh).state['daddy_garages:fuel']
            if not fuel then return end
            for _ = 1, 4 do
                if not DoesEntityExist(veh) or GetPedInVehicleSeat(veh, -1) ~= cache.ped then return end
                Bridge.fuel.set(veh, fuel)
                Wait(750)
            end
            TriggerServerEvent('daddy_garages:fuelSet', NetworkGetNetworkIdFromEntity(veh))
        end)
    end)

    -- What parking saves: { props, fuel, engine, body, damage }.
    function Car.read(veh)
        local damage = {}
        if Config.Vehicles.SaveDamage and Bridge.started(deformation) then
            local ok, value = pcall(function() return exports[deformation]:GetVehicleDeformation(veh) end)
            if ok then damage.deformation = value end
        elseif Config.Vehicles.SaveDamage then
            damage.dents = readDents(veh)
        end
        local props
        if Bridge.started('daddy_mechanic') then
            props = exports.daddy_mechanic:getProps(veh)
        elseif Bridge.started('jg-mechanic') then
            local ok, jgProps = pcall(function() return exports['jg-mechanic']:getVehicleProperties(veh, true) end)
            if ok and type(jgProps) == 'table' then props = jgProps end
        end
        return {
            props = props or lib.getVehicleProperties(veh),
            fuel = Bridge.fuel.get(veh),
            engine = GetVehicleEngineHealth(veh),
            body = GetVehicleBodyHealth(veh),
            damage = damage,
        }
    end
end
