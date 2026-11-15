Config = {}

Config.Locale = 'en' -- en | tr
Config.Framework = 'auto' -- auto | qbx | qb | esx
Config.Inventory = 'auto' -- auto | ox_inventory | qs-inventory | qb-inventory | es_extended
Config.Society = 'auto' -- auto | can9work-funds | Renewed-Banking | okokBanking | qb-banking | qb-management | none
Config.Notify = 'ox_lib' -- ox_lib | qb | esx
Config.Key = 38 -- E
Config.Interact = 'prompt' -- prompt (the page's own key hint) | textui (ox_lib)
Config.Accent = '#ff1f6d' -- the menu's colour for what is chosen
Config.Sounds = true -- the game's own menu sounds on the mod page
Config.Currency = '$%s'

-- Prices: percent of the car's value, or the fixed price when PriceByValue is false.
Config.PriceByValue = true
Config.DefaultCarValue = 50000 -- a car no dealership or vehicle list knows
Config.MinPrice = 10
Config.RepairByDamage = true -- false: a repair costs its whole price whatever the damage
Config.HiddenMods = {} -- properties no shop offers, e.g. { 'modArmor' }

-- Staff at their own shop.
Config.StaffSelfService = true -- staff fit mods themselves at their shop; false: they place an order like a customer
Config.StaffPayFromSociety = true -- what staff fit is paid from the shop's till
Config.StaffFreeOwnCar = { 'repair', 'respray', 'cosmetics', 'wheels', 'extras' } -- what costs nothing on a free order (and for staff on a car they own); {} for none
Config.FreeOrderOwnCar = false -- true: the 'free' payment only on a car the staff member owns; false: on any car
Config.TuningGiveBack = false -- taking a tuning part off gives its item back

-- Orders and invoices at owned shops.
Config.Commission = 0.15 -- the mechanic's share of an order or invoice, paid from the till; a boss can set their shop's own
Config.StaffCommand = 'mechanic' -- staff menu: orders and invoices
Config.FitKey = 'G' -- order card: fits the next part of a claimed order at its car (players can rebind it); false for none
Config.JobCard = { Distance = 80.0 } -- the order card shows within this many metres of its shop
Config.MaxClaims = 3 -- orders one mechanic may hold at once
Config.InvoiceCommand = 'invoices' -- a player's unpaid invoices
Config.Billing = 'own' -- own (this tablet's invoices) | daddy_bills (bills go to daddy_bills, paid from its bill list)
Config.CommissionMax = 0.4 -- the highest share a boss can set on the tablet
-- Rights per grade until the boss changes them on the tablet: this grade and up, false = boss only.
Config.Permissions = { staff = false, till = false, cancel = false, parts = 0, invoice = 0, stats = false, self = false }

-- Fitting by hand: the part is carried to the car, then a skill check.
Config.Install = {
    SkillCheck = true, -- false: a progress bar of Seconds instead
    Attempts = 3, -- tries before the part breaks
    BreakOnFail = true, -- every try missed: the part's item is used up
    Difficulty = { 'easy', 'easy', 'medium' }, -- ox_lib skill check
    Keys = { 'w', 'a', 's', 'd' },
    Seconds = 8,
    Spray = { 'scr_playerlamgraff', 'scr_lamgraff_paint_spray' }, -- the respray mist (particle asset, effect): the game's spray paint, tinted with the new colour
}

-- The part used up per order category, one per bought line.
Config.OrderItems = {
    repair = 'repair_kit',
    performance = 'performance_part',
    cosmetics = 'cosmetic_part',
    respray = 'respray_kit',
    wheels = 'vehicle_wheels',
    headlights = 'xenon_kit',
    neonLights = 'neon_kit', -- only an illegal shop's counter sells it
    tyreSmoke = 'tyre_smoke_kit',
    bulletproofTyres = 'bulletproof_tyres',
    extras = 'extras_kit',
}

-- mult: extra per level.
Config.Prices = {
    repair = { price = 250, percent = 0.01 },
    performance = { price = 2000, percent = 0.07, mult = 0.02 },
    cosmetics = { price = 750, percent = 0.015, mult = 0.02 },
    respray = { price = 1000, percent = 0.03 },
    wheels = { price = 1000, percent = 0.04, mult = 0.02 },
    headlights = { price = 500, percent = 0.03 },
    neonLights = { price = 500, percent = 0.05 },
    tyreSmoke = { price = 500, percent = 0.05 },
    bulletproofTyres = { price = 5000, percent = 0.03 },
    extras = { price = 500, percent = 0.03 },
    stance = { price = 250, percent = 0.05 }, -- the stance in the menu (an illegal shop's); the stance kit is the item
}

-- Parts counter and stash at owned shops.
Config.PartsFromSociety = true -- parts staff buy are paid from the till

-- Kits anyone can use on the car next to them.
Config.Kits = {
    repair_kit = { time = 10, engine = 1000.0, body = 1000.0, skill = true },
    duct_tape = { time = 6, add = 150.0, cap = 600.0 },
    cleaning_kit = { time = 5, clean = true },
}
Config.TabletItem = 'mechanic_tablet' -- opens the staff menu; false for none

-- Wear: km a part lasts; warn: the driver is told under this %.
Config.Servicing = {
    Enabled = true,
    Warn = 20,
    Skip = { 'police', 'police2', 'police3', 'police4', 'ambulance', 'firetruk' }, -- models that never wear
    Parts = {
        engine = { life = 1500, item = 'engine_oil' },
        tyres = { life = 800, item = 'tyre_replacement' },
        brakes = { life = 1000, item = 'brakepad_replacement' },
        clutch = { life = 1500, item = 'clutch_replacement' },
    },
}

-- Nitro: staff fit the kit, a bottle fills it.
Config.Nitro = {
    Bottle = 'nitrous_bottle',
    Seconds = 10, -- a full tank lasts this long
    Power = 2.0, -- engine power while boosting
    Key = 'LSHIFT', -- default key; players change it in the game's key settings
}

-- Items drivers use on their own car.
Config.Lights = { Item = 'lighting_controller', Effects = { 'static', 'flash', 'rainbow' } }
Config.Stance = {
    Item = 'stancing_kit',
    Height = { -0.3, 0.3 }, -- suspension, metres (minus is lower)
    Camber = { 0.0, 0.5 }, -- wheel tilt
    Track = { 0.5, 1.25 }, -- wheel distance from the body, 1 = stock
}

-- Tuning parts (shops list the groups in shop.tuning). item: used up, false: paid from the till; off = true: no longer fitted.
Config.Tuning = {
    engine = {
        i4 = { item = 'i4_engine', price = 4000, add = { fInitialDriveForce = 0.02 }, sound = 'sultan', combustion = true },
        v6 = { item = 'v6_engine', price = 8000, add = { fInitialDriveForce = 0.05, fInitialDriveMaxFlatVel = 5.0 }, sound = 'feltzer2', combustion = true },
        v8 = { item = 'v8_engine', price = 14000, add = { fInitialDriveForce = 0.09, fInitialDriveMaxFlatVel = 10.0 }, sound = 'dominator', combustion = true },
        v12 = { item = 'v12_engine', price = 25000, add = { fInitialDriveForce = 0.14, fInitialDriveMaxFlatVel = 16.0 }, sound = 'adder', combustion = true, deny = { 'panto' } },
    },
    drivetrain = {
        fwd = { item = 'fwd_drivetrain', price = 3000, set = { fDriveBiasFront = 1.0 } },
        rwd = { item = 'rwd_drivetrain', price = 3000, set = { fDriveBiasFront = 0.0 } },
        awd = { item = 'awd_drivetrain', price = 6000, set = { fDriveBiasFront = 0.5 } },
    },
    tyres = {
        semi = { item = 'semi_slick_tyres', price = 1500, add = { fTractionCurveMax = 0.1, fTractionCurveMin = 0.1 } },
        slick = { item = 'slick_tyres', price = 4000, add = { fTractionCurveMax = 0.25, fTractionCurveMin = 0.2 } },
        offroad = { item = 'offroad_tyres', price = 3000, add = { fLowSpeedTractionLossMult = -0.3 }, mult = { fTractionLossMult = 0.6 } },
    },
    brakes = {
        ceramic = { item = 'ceramic_brakes', price = 6000, add = { fBrakeForce = 0.35, fTractionCurveMax = 0.15, fTractionCurveMin = 0.15 } },
    },
    drift = {
        kit = { item = 'drift_tuning_kit', price = 7000, add = { fTractionCurveMax = -0.5, fSteeringLock = 15.0 }, mult = { fTractionLossMult = 1.6 } },
    },
    gearbox = {
        quick = { item = 'gearbox_kit', price = 5000, mult = { fClutchChangeRateScaleUpShift = 2.0, fClutchChangeRateScaleDownShift = 2.0 }, combustion = true },
        manual = { item = 'manual_gearbox', price = 10000, manual = true, combustion = true },
    },
    nitro = {
        nitrous = { item = 'nitrous_install_kit', price = 8000 },
    },
}

-- Electric cars: no combustion parts.
Config.ElectricCars = {
    'voltic', 'voltic2', 'cyclone', 'cyclone2', 'tezeract', 'raiden', 'neon', 'imorgon', 'khamelion', 'surge', 'dilettante',
    'iwagen', 'omnisegt', 'virtue', 'powersurge', 'buffalo5', 'envisage', 'inductor', 'inductor2', 'caddy', 'caddy2', 'caddy3', 'airtug',
}

-- Shops. type: 'self' or 'owned' (a job runs it); sells: categories of Config.Prices; prices: overrides.
Config.Shops = {
    lscustoms = {
        label = 'Los Santos Customs',
        type = 'self',
        points = { vec3(-337.4, -136.9, 38.6), vec3(-1155.0, -2007.2, 12.7) },
        radius = 8.0,
        blip = { sprite = 72, colour = 0 },
        sells = { 'repair', 'performance', 'cosmetics', 'respray', 'wheels', 'headlights', 'extras' },
    },
    bennys = {
        label = "Benny's Motorworks",
        type = 'owned',
        job = 'mechanic',
        open = true,
        points = { vec3(-211.6, -1324.4, 30.4), vec3(-222.6, -1329.9, 30.4) },
        radius = 6.0,
        blip = { sprite = 446, colour = 5 },
        parts = {
            coords = vec3(-196.4, -1318.5, 31.1),
            items = {
                { name = 'repair_kit', price = 50 }, { name = 'performance_part', price = 100 }, { name = 'cosmetic_part', price = 75 },
                { name = 'respray_kit', price = 20 }, { name = 'vehicle_wheels', price = 100 }, { name = 'xenon_kit', price = 120 },
                { name = 'lighting_controller', price = 120 }, { name = 'extras_kit', price = 250 }, { name = 'gearbox_kit', price = 1500 },
            },
        },
        stash = { coords = vec3(-199.2, -1314.6, 31.1), slots = 100, weight = 500000 },
        sells = { 'repair', 'performance', 'cosmetics', 'respray', 'wheels', 'headlights', 'extras' },
        tuning = { 'gearbox' },
    },
    underground = {
        label = 'Underground Garage',
        type = 'owned',
        job = 'illegalmechanic',
        open = false,
        points = { vec3(894.1, -2516.0, 27.8) },
        radius = 8.0,
        parts = {
            coords = vec3(890.9, -2510.6, 28.3),
            items = {
                { name = 'neon_kit', price = 120 }, { name = 'tyre_smoke_kit', price = 100 }, { name = 'extras_kit', price = 250 },
                { name = 'respray_kit', price = 20 }, { name = 'repair_kit', price = 50 },
            },
        },
        stash = { coords = vec3(892.4, -2510.6, 28.3), slots = 100, weight = 500000 },
        sells = { 'repair', 'respray', 'neonLights', 'tyreSmoke', 'extras', 'stance' },
        tuning = { 'engine', 'drivetrain', 'tyres', 'brakes', 'drift', 'nitro' },
    },
}

-- Server settings (servers/daddyrp/daddy_mechanic/config/config.lua)
Config = {}

Config.Locale = 'tr' -- en | tr
Config.Framework = 'auto' -- auto | qbx | qb | esx
Config.Inventory = 'auto' -- auto | ox_inventory | qs-inventory | qb-inventory | es_extended
Config.Society = 'auto' -- auto | can9work-funds | Renewed-Banking | okokBanking | qb-banking | qb-management | none
Config.Notify = 'ox_lib' -- ox_lib | qb | esx
Config.Key = 38 -- E
Config.Interact = 'prompt' -- prompt (the page's own key hint) | textui (ox_lib)
Config.Accent = '#ff1f6d' -- the menu's colour for what is chosen
Config.Sounds = true -- the game's own menu sounds on the mod page
Config.Currency = '$%s'

-- Prices: percent of the car's value, or the fixed price when PriceByValue is false.
Config.PriceByValue = true
Config.DefaultCarValue = 50000 -- a car no dealership or vehicle list knows
Config.MinPrice = 0
Config.RepairByDamage = false -- a repair is the whole price
Config.HiddenMods = { 'modArmor' }

-- Staff at their own shop.
Config.StaffSelfService = false -- staff fit mods themselves at their shop; false: they place an order like a customer
Config.StaffPayFromSociety = true -- what staff fit is paid from the shop's till
Config.StaffFreeOwnCar = { 'repair', 'performance', 'cosmetics', 'respray', 'wheels', 'headlights', 'neonLights', 'tyreSmoke', 'extras', 'stance' } -- what costs nothing on a free order (grades the boss gives 'self'); they still fit the parts; {} for none
Config.FreeOrderOwnCar = false -- true: the 'free' payment only on a car the staff member owns; false: on any car
Config.TuningGiveBack = true -- taking a tuning part off (or fitting another over it) gives its item back

-- Orders and invoices at owned shops.
Config.Commission = 0.15 -- the mechanic's share of an order or invoice, paid from the till; a boss can set their shop's own
Config.StaffCommand = 'mtablet' -- staff menu: orders and invoices
Config.FitKey = 'G' -- order card: fits the next part of a claimed order at its car (players can rebind it); false for none
Config.JobCard = { Distance = 80.0 } -- the order card shows within this many metres of its shop
Config.MaxClaims = 3 -- orders one mechanic may hold at once
Config.InvoiceCommand = 'invoices' -- a player's unpaid invoices
Config.Billing = 'daddy_bills' -- tablet bills land in /faturalarım (daddy_bills)
Config.CommissionMax = 0.4 -- the highest share a boss can set on the tablet
-- Rights per grade until the boss changes them on the tablet: this grade and up, false = boss only.
Config.Permissions = { staff = false, till = false, cancel = false, parts = 0, invoice = 0, stats = false, self = false }

-- Fitting by hand: the part is carried to the car, then a skill check.
Config.Install = {
    SkillCheck = true, -- false: a progress bar of Seconds instead
    Attempts = 3, -- tries before the part breaks
    BreakOnFail = true, -- every try missed: the part's item is used up
    Difficulty = { 'easy', 'easy', 'easy', 'easy', 'easy' }, -- ox_lib skill check
    Keys = { 'w', 'a', 's', 'd' },
    Seconds = 10,
    Spray = { 'scr_playerlamgraff', 'scr_lamgraff_paint_spray' }, -- the respray mist (particle asset, effect): the game's spray paint, tinted with the new colour
}

-- The part used up per order category, one per bought line.
Config.OrderItems = {
    repair = 'repair_kit',
    performance = 'performance_part',
    cosmetics = 'cosmetic_part',
    respray = 'respray_kit',
    wheels = 'vehicle_wheels',
    headlights = 'xenon_kit',
    neonLights = 'neon_kit', -- only the illegal shops' counters sell it
    tyreSmoke = 'tyre_smoke_kit',
    bulletproofTyres = 'bulletproof_tyres',
    extras = 'extras_kit',
}

-- mult: extra per level.
Config.Prices = {
    repair = { price = 250, percent = 0.01 },
    performance = { price = 2000, percent = 0.07, mult = 0.02 },
    cosmetics = { price = 750, percent = 0.015, mult = 0.02 },
    respray = { price = 1000, percent = 0.03 },
    wheels = { price = 1000, percent = 0.04, mult = 0.02 },
    headlights = { price = 500, percent = 0.03 },
    neonLights = { price = 500, percent = 0.05 },
    tyreSmoke = { price = 500, percent = 0.05 },
    bulletproofTyres = { price = 5000, percent = 0.03 },
    extras = { price = 500, percent = 0.03 },
    stance = { price = 250, percent = 0.05 }, -- the stance in the menu (an illegal shop's); the stance kit is the item
}

-- Parts counter and stash at owned shops.
Config.PartsFromSociety = true -- parts staff buy are paid from the till

-- Kits anyone can use on the car next to them.
Config.Kits = {
    repair_kit = { time = 10, engine = 1000.0, body = 1000.0, skill = true },
    duct_tape = { time = 6, add = 150.0, cap = 600.0 },
    cleaning_kit = { time = 5, clean = true },
}
Config.TabletItem = 'mechanic_tablet' -- opens the staff menu; false for none

-- Wear: km a part lasts; warn: the driver is told under this %.
Config.Servicing = {
    Enabled = false,
    Warn = 20,
    Skip = { 'police', 'police2' }, -- models that never wear
    Parts = {
        engine = { life = 1500, item = 'engine_oil' },
        tyres = { life = 800, item = 'tyre_replacement' },
        brakes = { life = 1000, item = 'brakepad_replacement' },
        clutch = { life = 1500, item = 'clutch_replacement' },
    },
}

-- Nitro: staff fit the kit, a bottle fills it.
Config.Nitro = {
    Bottle = 'nitrous_bottle',
    Seconds = 10, -- a full tank lasts this long
    Power = 2.0, -- engine power while boosting
    Key = 'LSHIFT', -- default key; players change it in the game's key settings
}

-- Items drivers use on their own car.
Config.Lights = { Item = 'lighting_controller', Effects = { 'static', 'flash', 'rainbow' } }
Config.Stance = {
    Item = 'stancing_kit',
    Height = { -0.3, 0.3 }, -- suspension, metres (minus is lower)
    Camber = { 0.0, 0.5 }, -- wheel tilt
    Track = { 0.5, 1.25 }, -- wheel distance from the body, 1 = stock
}

-- Tuning parts (shops list the groups in shop.tuning). item: used up, false: paid from the till; off = true: no longer fitted.
Config.Tuning = {
    engine = {
        i4 = { item = 'i4_engine', price = 4000, add = { fInitialDriveForce = 0.02 }, sound = 'sultan', combustion = true, off = true },
        v6 = { item = 'v6_engine', price = 8000, add = { fInitialDriveForce = 0.05, fInitialDriveMaxFlatVel = 5.0 }, sound = 'feltzer2', combustion = true, off = true },
        v8 = { item = 'v8_engine', price = 14000, add = { fInitialDriveForce = 0.09, fInitialDriveMaxFlatVel = 10.0 }, sound = 'dominator', combustion = true, off = true },
        v12 = { item = 'v12_engine', price = 25000, add = { fInitialDriveForce = 0.14, fInitialDriveMaxFlatVel = 16.0 }, sound = 'adder', combustion = true, deny = { 'panto' } },
    },
    drivetrain = {
        fwd = { item = 'fwd_drivetrain', price = 3000, set = { fDriveBiasFront = 1.0 } },
        rwd = { item = 'rwd_drivetrain', price = 3000, set = { fDriveBiasFront = 0.0 } },
        awd = { item = 'awd_drivetrain', price = 6000, set = { fDriveBiasFront = 0.5 } },
    },
    tyres = {
        semi = { item = 'semi_slick_tyres', price = 1500, add = { fTractionCurveMax = 0.1, fTractionCurveMin = 0.1 } },
        slick = { item = 'slick_tyres', price = 4000, add = { fTractionCurveMax = 0.25, fTractionCurveMin = 0.2 } },
        offroad = { item = 'offroad_tyres', price = 3000, add = { fLowSpeedTractionLossMult = -0.3 }, mult = { fTractionLossMult = 0.6 } },
    },
    brakes = {
        ceramic = { item = 'ceramic_brakes', price = 6000, add = { fBrakeForce = 0.35, fTractionCurveMax = 0.15, fTractionCurveMin = 0.15 } },
    },
    drift = {
        kit = { item = 'drift_tuning_kit', price = 7000, add = { fTractionCurveMax = -0.5, fSteeringLock = 15.0 }, mult = { fTractionLossMult = 1.6 } },
    },
    gearbox = {
        quick = { item = 'gearbox_kit', price = 5000, mult = { fClutchChangeRateScaleUpShift = 2.0, fClutchChangeRateScaleDownShift = 2.0 }, combustion = true },
        manual = { item = 'manual_gearbox', price = 10000, manual = true, combustion = true },
    },
    nitro = {
        nitrous = { item = 'nitrous_install_kit', price = 8000 },
    },
}

-- Electric cars: no combustion parts.
Config.ElectricCars = {
    'voltic', 'voltic2', 'cyclone', 'cyclone2', 'tezeract', 'raiden', 'neon', 'imorgon', 'khamelion', 'surge', 'dilettante',
    'iwagen', 'omnisegt', 'virtue', 'powersurge', 'buffalo5', 'envisage', 'inductor', 'inductor2', 'caddy', 'caddy2', 'caddy3', 'airtug',
}

-- Shops. type: 'self' or 'owned' (a job runs it); sells: categories of Config.Prices; prices: overrides.
Config.Shops = {
    ['Mekanik 1'] = {
        label = 'BBS Garage',
        type = 'owned',
        job = 'mekanik1',
        open = false,
        points = { vec3(-321.05, -156.32, 38.91), vec3(-339.72, -160.61, 38.59), vec3(-347.75, -157.96, 38.59), vec3(-333.04, -132.33, 38.91), vec3(-317.46, -145.19, 38.91), vec3(-313.34, -134.58, 38.91), vec3(-336.24, -105.04, 39.03), vec3(-344.8, -102.18, 39.03), vec3(-353.44, -100.25, 39.03), vec3(-312.6, -125.11, 39.17) },
        radius = 7.5,
        blip = { sprite = 446, colour = 0, scale = 0.7 },
        parts = {
            coords = vec3(-337.16, -134.59, 39.01),
            items = { { name = 'xenon_kit', price = 120 }, { name = 'lighting_controller', price = 120 }, { name = 'cosmetic_part', price = 75 }, { name = 'respray_kit', price = 20 }, { name = 'vehicle_wheels', price = 100 }, { name = 'extras_kit', price = 250 }, { name = 'manual_gearbox', price = 2000 }, { name = 'performance_part', price = 100 }, { name = 'repair_kit', price = 50 }, { name = 'cleaning_kit', price = 25 }, { name = 'car_play', price = 500 } },
        },
        stashes = {
            { id = 'Mekanik 1_depo_1', label = 'Depo', coords = vec3(-314.33, -154.79, 39.01), slots = 500, weight = 999999 },
        },
        sells = { 'repair', 'performance', 'cosmetics', 'respray', 'wheels', 'headlights', 'extras' },
        tuning = { 'gearbox' },
        prices = {
            repair = { price = 50, percent = 0.01 },
            performance = { price = 200, percent = 0.07, mult = 0.02 },
            cosmetics = { price = 150, percent = 0.015, mult = 0.02 },
            respray = { price = 150, percent = 0.03 },
            wheels = { price = 200, percent = 0.04, mult = 0.02 },
            headlights = { price = 100, percent = 0.03 },
            extras = { price = 200, percent = 0.03 },
        },
    },
    ['Mekanik 3'] = {
        label = 'Bennys Mekanik',
        type = 'owned',
        job = 'mekanik3',
        open = false,
        points = { vec3(-208.47, -1335.9, 31.3), vec3(-222.25, -1335.38, 31.3), vec3(-214.64, -1335.5, 31.32), vec3(-194, -1326.83, 31.3) },
        radius = 6,
        blip = { sprite = 446, colour = 0, scale = 0.7 },
        parts = {
            coords = vec3(-211.16, -1339.07, 31.3),
            items = { { name = 'xenon_kit', price = 120 }, { name = 'lighting_controller', price = 120 }, { name = 'cosmetic_part', price = 75 }, { name = 'respray_kit', price = 20 }, { name = 'vehicle_wheels', price = 100 }, { name = 'extras_kit', price = 250 }, { name = 'manual_gearbox', price = 2000 }, { name = 'performance_part', price = 100 }, { name = 'repair_kit', price = 50 }, { name = 'cleaning_kit', price = 25 }, { name = 'car_play', price = 500 } },
        },
        stashes = {
            { id = 'Mekanik 3_depo_1', label = 'Depo', coords = vec3(-216.92, -1333.25, 31.3), slots = 500, weight = 999999 },
        },
        sells = { 'repair', 'performance', 'cosmetics', 'respray', 'wheels', 'headlights', 'extras' },
        tuning = { 'gearbox' },
        prices = {
            repair = { price = 50, percent = 0.01 },
            performance = { price = 200, percent = 0.07, mult = 0.02 },
            cosmetics = { price = 150, percent = 0.015, mult = 0.02 },
            respray = { price = 150, percent = 0.03 },
            wheels = { price = 200, percent = 0.04, mult = 0.02 },
            headlights = { price = 100, percent = 0.03 },
            extras = { price = 200, percent = 0.03 },
        },
    },
    ['Mekanik 4'] = {
        label = 'Equez Mekanik',
        type = 'owned',
        job = 'mekanik4',
        open = false,
        points = { vec3(-2077.72, -301.27, 12.93), vec3(-2088.28, -300.05, 12.78), vec3(-2098.57, -298.75, 12.93) },
        radius = 6,
        blip = { sprite = 446, colour = 0, scale = 0.7 },
        parts = {
            coords = vec3(-2089.65, -294.27, 13.27),
            items = { { name = 'xenon_kit', price = 120 }, { name = 'lighting_controller', price = 120 }, { name = 'cosmetic_part', price = 75 }, { name = 'respray_kit', price = 20 }, { name = 'vehicle_wheels', price = 100 }, { name = 'extras_kit', price = 250 }, { name = 'manual_gearbox', price = 2000 }, { name = 'performance_part', price = 100 }, { name = 'repair_kit', price = 50 }, { name = 'cleaning_kit', price = 25 }, { name = 'car_play', price = 500 } },
        },
        stashes = {
            { id = 'Mekanik 4_depo_1', label = 'Depo', coords = vec3(-2082.7, -294.96, 13.27), slots = 500, weight = 999999 },
        },
        sells = { 'repair', 'performance', 'cosmetics', 'respray', 'wheels', 'headlights', 'extras' },
        tuning = { 'gearbox' },
        prices = {
            repair = { price = 50, percent = 0.01 },
            performance = { price = 200, percent = 0.07, mult = 0.02 },
            cosmetics = { price = 150, percent = 0.015, mult = 0.02 },
            respray = { price = 150, percent = 0.03 },
            wheels = { price = 200, percent = 0.04, mult = 0.02 },
            headlights = { price = 100, percent = 0.03 },
            extras = { price = 200, percent = 0.03 },
        },
    },
    ['Mekanik 5'] = {
        label = 'Hayes Auto',
        type = 'owned',
        job = 'mekanik5',
        open = false,
        points = { vec3(-1417.09, -446.54, 35.53), vec3(-1411.58, -442.05, 35.55), vec3(-1423.78, -449.96, 35.54), vec3(1069.75, -900.57, 50.35) },
        radius = 6,
        blip = { sprite = 446, colour = 0, scale = 0.7 },
        parts = {
            coords = vec3(-1420.97, -455.11, 35.91),
            items = { { name = 'xenon_kit', price = 120 }, { name = 'lighting_controller', price = 120 }, { name = 'cosmetic_part', price = 75 }, { name = 'respray_kit', price = 20 }, { name = 'vehicle_wheels', price = 100 }, { name = 'extras_kit', price = 250 }, { name = 'manual_gearbox', price = 2000 }, { name = 'performance_part', price = 100 }, { name = 'repair_kit', price = 50 }, { name = 'cleaning_kit', price = 25 }, { name = 'car_play', price = 500 } },
        },
        stashes = {
            { id = 'Mekanik 5_depo_1', label = 'Depo', coords = vec3(-1414.38, -450.99, 35.91), slots = 500, weight = 999999 },
        },
        sells = { 'repair', 'performance', 'cosmetics', 'respray', 'wheels', 'headlights', 'extras' },
        tuning = { 'gearbox' },
        prices = {
            repair = { price = 50, percent = 0.01 },
            performance = { price = 200, percent = 0.07, mult = 0.02 },
            cosmetics = { price = 150, percent = 0.015, mult = 0.02 },
            respray = { price = 150, percent = 0.03 },
            wheels = { price = 200, percent = 0.04, mult = 0.02 },
            headlights = { price = 100, percent = 0.03 },
            extras = { price = 200, percent = 0.03 },
        },
    },
    ['Mekanik 6'] = {
        label = 'Mekanik 6',
        type = 'owned',
        job = 'mekanik6',
        open = false,
        points = { vec3(732.63, -1088.81, 21.46), vec3(734.08, -1082.15, 21.46) },
        radius = 6,
        blip = { sprite = 446, colour = 0, scale = 0.7 },
        parts = {
            coords = vec3(737.76, -1078.16, 22.17),
            items = { { name = 'xenon_kit', price = 120 }, { name = 'lighting_controller', price = 120 }, { name = 'cosmetic_part', price = 75 }, { name = 'respray_kit', price = 20 }, { name = 'vehicle_wheels', price = 100 }, { name = 'extras_kit', price = 250 }, { name = 'manual_gearbox', price = 2000 }, { name = 'performance_part', price = 100 }, { name = 'repair_kit', price = 50 }, { name = 'cleaning_kit', price = 25 }, { name = 'car_play', price = 500 } },
        },
        stashes = {
            { id = 'Mekanik 6_depo_1', label = 'Depo', coords = vec3(725.53, -1067.32, 28.31), slots = 500, weight = 999999 },
        },
        sells = { 'repair', 'performance', 'cosmetics', 'respray', 'wheels', 'headlights', 'extras' },
        tuning = { 'gearbox' },
        prices = {
            repair = { price = 50, percent = 0.01 },
            performance = { price = 200, percent = 0.07, mult = 0.02 },
            cosmetics = { price = 150, percent = 0.015, mult = 0.02 },
            respray = { price = 150, percent = 0.03 },
            wheels = { price = 200, percent = 0.04, mult = 0.02 },
            headlights = { price = 100, percent = 0.03 },
            extras = { price = 200, percent = 0.03 },
        },
    },
    ['Mekanik 7'] = {
        label = 'OVD Garage',
        type = 'owned',
        job = 'mekanik7',
        open = false,
        points = { vec3(938.3, -969.88, 39.54), vec3(925.38, -962.96, 39.5), vec3(926.39, -979.51, 39.5) },
        radius = 6,
        blip = { sprite = 446, colour = 0, scale = 0.7 },
        parts = {
            coords = vec3(947.42, -970.84, 39.5),
            items = { { name = 'xenon_kit', price = 120 }, { name = 'lighting_controller', price = 120 }, { name = 'cosmetic_part', price = 75 }, { name = 'respray_kit', price = 20 }, { name = 'vehicle_wheels', price = 100 }, { name = 'extras_kit', price = 250 }, { name = 'manual_gearbox', price = 2000 }, { name = 'performance_part', price = 100 }, { name = 'repair_kit', price = 50 }, { name = 'cleaning_kit', price = 25 }, { name = 'car_play', price = 500 } },
        },
        stashes = {
            { id = 'Mekanik 7_depo_1', label = 'Depo', coords = vec3(947.95, -973.21, 39.5), slots = 500, weight = 999999 },
        },
        sells = { 'repair', 'performance', 'cosmetics', 'respray', 'wheels', 'headlights', 'extras' },
        tuning = { 'gearbox' },
        prices = {
            repair = { price = 50, percent = 0.01 },
            performance = { price = 200, percent = 0.07, mult = 0.02 },
            cosmetics = { price = 150, percent = 0.015, mult = 0.02 },
            respray = { price = 150, percent = 0.03 },
            wheels = { price = 200, percent = 0.04, mult = 0.02 },
            headlights = { price = 100, percent = 0.03 },
            extras = { price = 200, percent = 0.03 },
        },
    },
    ['Mekanik 8'] = {
        label = 'Nethras Garage',
        type = 'owned',
        job = 'mekanik8',
        open = false,
        points = { vec3(-2221.57, -376.43, 12.97), vec3(-2217.24, -370.99, 12.97), vec3(-2210.75, -375.87, 12.97), vec3(-2215.96, -383.05, 12.97) },
        radius = 6,
        blip = { sprite = 446, colour = 0, scale = 0.7 },
        parts = {
            coords = vec3(-2216.37, -376.37, 13.34),
            items = { { name = 'xenon_kit', price = 120 }, { name = 'lighting_controller', price = 120 }, { name = 'cosmetic_part', price = 75 }, { name = 'respray_kit', price = 20 }, { name = 'vehicle_wheels', price = 100 }, { name = 'extras_kit', price = 250 }, { name = 'manual_gearbox', price = 2000 }, { name = 'performance_part', price = 100 }, { name = 'repair_kit', price = 50 }, { name = 'cleaning_kit', price = 25 }, { name = 'car_play', price = 500 } },
        },
        stashes = {
            { id = 'Mekanik 8_depo_1', label = 'Depo', coords = vec3(-2212.35, -371.69, 13.34), slots = 500, weight = 999999 },
        },
        sells = { 'repair', 'performance', 'cosmetics', 'respray', 'wheels', 'headlights', 'extras' },
        tuning = { 'gearbox' },
        prices = {
            repair = { price = 50, percent = 0.01 },
            performance = { price = 200, percent = 0.07, mult = 0.02 },
            cosmetics = { price = 150, percent = 0.015, mult = 0.02 },
            respray = { price = 150, percent = 0.03 },
            wheels = { price = 200, percent = 0.04, mult = 0.02 },
            headlights = { price = 100, percent = 0.03 },
            extras = { price = 200, percent = 0.03 },
        },
    },
    ['AfterLife Mekanik'] = {
        label = 'AfterLife Mekanik',
        type = 'owned',
        job = 'illegalmekanik1',
        open = false,
        points = { vec3(894.06, -2515.96, 27.78), vec3(915.28, -2509.24, 27.77), vec3(922.65, -2509.69, 27.77), vec3(930.53, -2510.26, 27.77), vec3(937.94, -2520.39, 27.7), vec3(890.32, -2525.61, 27.67), vec3(879.84, -2505.9, 28.6), vec3(878.95, -2514.34, 28.6), vec3(879.59, -2495.54, 28.56), vec3(876.95, -2526.5, 25.24) },
        radius = 6,
        parts = {
            coords = vec3(892.45, -2510.58, 28.32),
            items = { { name = 'neon_kit', price = 120 }, { name = 'tyre_smoke_kit', price = 100 }, { name = 'extras_kit', price = 250 }, { name = 'respray_kit', price = 20 }, { name = 'repair_kit', price = 50 }, { name = 'cleaning_kit', price = 25 } },
        },
        stashes = {
            { id = 'AfterLife Mekanik_depo_1', label = 'Depo', coords = vec3(892.45, -2510.58, 28.32), slots = 500, weight = 999999 },
            { id = 'AfterLife Mekanik_depo 2_2', label = 'Depo 2', coords = vec3(857.9, -2511.21, 25.16), slots = 500, weight = 999999 },
        },
        sells = { 'repair', 'respray', 'neonLights', 'tyreSmoke', 'extras', 'stance' },
        tuning = { 'engine', 'drivetrain', 'tyres', 'brakes', 'drift' },
        prices = {
            repair = { price = 100, percent = 0.01 },
            respray = { price = 100, percent = 0.01 },
            neonLights = { price = 250, percent = 0.05 },
            tyreSmoke = { price = 200, percent = 0.05 },
            extras = { price = 300, percent = 0.03 },
        },
    },
    ['Bunker Mekanik'] = {
        label = 'Bunker Mekanik',
        type = 'owned',
        job = 'illegalmekanik2',
        open = false,
        points = { vec3(731.28, -1036.8, 0.59), vec3(747.76, -1051.76, 0.59), vec3(742.93, -1056.47, 0.59), vec3(742.65, -1046.39, 0.59) },
        radius = 9,
        parts = {
            coords = vec3(722.35, -1041.25, 0.97),
            items = { { name = 'neon_kit', price = 120 }, { name = 'tyre_smoke_kit', price = 100 }, { name = 'extras_kit', price = 250 }, { name = 'respray_kit', price = 20 }, { name = 'repair_kit', price = 50 }, { name = 'cleaning_kit', price = 25 } },
        },
        stashes = {
            { id = 'Bunker Mekanik_depo_1', label = 'Depo', coords = vec3(722.35, -1041.25, 0.97), slots = 500, weight = 999999 },
        },
        sells = { 'repair', 'respray', 'neonLights', 'tyreSmoke', 'extras', 'stance' },
        tuning = { 'engine', 'drivetrain', 'tyres', 'brakes', 'drift' },
        prices = {
            repair = { price = 100, percent = 0.01 },
            respray = { price = 100, percent = 0.01 },
            neonLights = { price = 250, percent = 0.05 },
            tyreSmoke = { price = 200, percent = 0.05 },
            extras = { price = 300, percent = 0.03 },
        },
    },
    ['Kolej Mekanik'] = {
        label = 'Kolej Mekanik Atölyesi',
        type = 'owned',
        job = 'ogretmen',
        open = false,
        points = { vec3(5382.14, -5228.01, 26.35) },
        radius = 6,
        blip = { sprite = 446, colour = 46, scale = 0.7 },
        parts = {
            coords = vec3(5387.33, -5223.32, 26.35),
            items = { { name = 'xenon_kit', price = 120 }, { name = 'lighting_controller', price = 120 }, { name = 'cosmetic_part', price = 75 }, { name = 'respray_kit', price = 20 }, { name = 'vehicle_wheels', price = 100 }, { name = 'extras_kit', price = 250 }, { name = 'manual_gearbox', price = 2000 }, { name = 'performance_part', price = 100 }, { name = 'repair_kit', price = 50 }, { name = 'cleaning_kit', price = 25 }, { name = 'car_play', price = 500 } },
        },
        stashes = {
            { id = 'Kolej Mekanik_kolej mekanik deposu_1', label = 'Kolej Mekanik Deposu', coords = vec3(5386.19, -5219.44, 26.35), slots = 500, weight = 999999 },
        },
        sells = { 'repair', 'performance', 'cosmetics', 'respray', 'wheels', 'headlights', 'extras' },
        tuning = { 'engine', 'drivetrain', 'tyres', 'brakes', 'gearbox' },
        prices = {
            repair = { price = 50, percent = 0.01 },
            performance = { price = 200, percent = 0.07, mult = 0.02 },
            cosmetics = { price = 150, percent = 0.015, mult = 0.02 },
            respray = { price = 150, percent = 0.03 },
            wheels = { price = 200, percent = 0.04, mult = 0.02 },
            headlights = { price = 100, percent = 0.03 },
            extras = { price = 200, percent = 0.03 },
        },
    },
}
