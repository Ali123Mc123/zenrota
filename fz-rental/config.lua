Config = {}
Config.useBlips = true           -- Show blips on the map.
Config.useTarget = true          -- Use ox_target for interaction.
Config.useDisplayMetadata = true -- Register metadata labels for rental papers in ox_inventory.
Config.fuelSystem =
'savana-fuel'                    -- Fuel system to use. Options: 'ox_fuel' or 'LegacyFuel' make sure to start the resource before this one.
Config.keybind = 38              -- Control index for the TextUI. Default is 'E' (38) Change locals file for UI text. https://docs.fivem.net/docs/game-references/controls/#controls
Config.returnDistance = 20.0     -- Max distance in meters between player and rented vehicle for return.

Config.minRentTime = 1           -- Minimum rental time in hours.
Config.maxRentTime = 24          -- Maximum rental time in hours.

Config.moneytype = 'bank'        -- Type of money used for transactions. Options: 'cash' or 'bank'.

Config.peds = {
    -- rental_1 = {                                              -- Unique identifier.
    --     model = 'a_m_m_hasjew_01',                            -- Model for the ped.
    --     coords = vec4(-1877.75, -353.66, 48.33, 57.54),       -- Coordinates for the rental service ped.
    --     scenario = 'WORLD_HUMAN_CLIPBOARD',                   -- Animation scenario for the ped.
    --     spawncoords = vec4(-1883.31, -349.71, 48.88, 137.63), -- Coords for spawning vehicles.
    --     blip = {
    --         sprite = 811,                                     -- Icon for the blip. https://docs.fivem.net/docs/game-references/blips/
    --         scale = 0.75,                                     -- Size of the blip.
    --         colour = 0,                                       -- Color of the blip. https://docs.fivem.net/docs/game-references/blips/#blip-colors
    --         label = 'Araç Kiralama',
    --     },
    --     zoneOptions = { -- Used when UseTarget is false.
    --         length = 3.0,
    --         width = 3.0,
    --         debugPoly = false, -- Only used for debugging.
    --     },
    -- },
    rental_2 = {
        model = 'a_m_m_hasjew_01',
        coords = vector4(1695.0205, 3290.2527, 40.5368, 103.9767), -- DaddyRP: Sandy Shores havaalanı
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        spawncoords = vector4(1688.71, 3288.68, 41.54, 103.98), -- kiralanan araç: görevlinin 6.5 m önü (oyunda gerekirse ayarlanır)
        blip = {
            sprite = 811,
            scale = 0.75,
            colour = 0,
            label = 'Araç Kiralama',
        },
        zoneOptions = {
            length = 3.0,
            width = 3.0,
            debugPoly = false,
        },
    },
    rental_3 = {
        model = 'a_m_m_hasjew_01',
        coords = vector4(-1672.9203, -534.3848, 34.9395, 139.6842), -- Del Perro; ped z = given z - 1
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        spawncoords = vector4(-1677.1258, -539.3410, 35.9395, 139.6842), -- 6.5 m in front of the clerk, check in game
        blip = {
            sprite = 811,
            scale = 0.75,
            colour = 0,
            label = 'Araç Kiralama',
        },
        zoneOptions = {
            length = 3.0,
            width = 3.0,
            debugPoly = false,
        },
    },
    rental_4 = {
        model = 'a_m_m_hasjew_01',
        coords = vector4(5284.5405, -5281.6245, 31.0107, 243.3745), -- Cayo scooter kiralama (2026-11-14); ped z = verilen z - 1
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        spawncoords = vector4(5286.2017, -5282.8511, 32.0061, 133.9032), -- scooter spawn noktası
        blip = { sprite = 226, scale = 0.75, colour = 0, label = 'Scooter Kiralama' },
        zoneOptions = { length = 3.0, width = 3.0, debugPoly = false },
    },
}

Config.vehicles = {
    -- rental_1 = {
    --     {
    --         name = 'Blista',
    --         description = 'Küçük ve güvenilir bir hatchback.',
    --         model = 'blista',
    --         price = 60,
    --         icon = 'car',
    --         image = 'nui://fz-rental/web/images/blista.png',
    --     },
    --     {
    --         name = 'Prairie',
    --         description = 'Kompakt ve ekonomik bir araba.',
    --         model = 'prairie',
    --         price = 65,
    --         icon = 'car',
    --         image = 'nui://fz-rental/web/images/prairie.png',
    --     },
    --     {
    --         name = 'Asea',
    --         description = 'Pratik, 4 kapılı bir sedan.',
    --         model = 'asea',
    --         price = 70,
    --         icon = 'car',
    --         image = 'nui://fz-rental/web/images/asea.png',
    --     },
    --     {
    --         name = 'Intruder',
    --         description = 'Konforlu, orta boy bir sedan.',
    --         model = 'intruder',
    --         price = 80,
    --         icon = 'car',
    --         image = 'nui://fz-rental/web/images/intruder.png',
    --     },
    --     {
    --         name = 'Premier',
    --         description = 'Günlük kullanım için dengeli bir sedan.',
    --         model = 'premier',
    --         price = 85,
    --         icon = 'car',
    --         image = 'nui://fz-rental/web/images/premier.png',
    --     },
    --     {
    --         name = 'Stanier',
    --         description = 'Sağlam, büyük boy bir sedan.',
    --         model = 'stanier',
    --         price = 90,
    --         icon = 'car',
    --         image = 'nui://fz-rental/web/images/stanier.png',
    --     },
    --     {
    --         name = 'Asterope',
    --         description = 'Sade ve verimli bir aile arabası.',
    --         model = 'asterope',
    --         price = 75,
    --         icon = 'car',
    --         image = 'nui://fz-rental/web/images/asterope.png',
    --     },
    --     {
    --         name = 'RancherXL',
    --         description = 'Günlük kullanım için basit bir SUV.',
    --         model = 'rancherxl',
    --         price = 95,
    --         icon = 'car',
    --         image = 'nui://fz-rental/web/images/rancherxl.png',
    --     },
    -- },
    rental_2 = {
        {
            name = 'Blista',
            description = 'Küçük ve güvenilir bir hatchback.',
            model = 'blista',
            price = 60,
            icon = 'car',
            image = 'nui://fz-rental/web/images/blista.png',
        },
        {
            name = 'Prairie',
            description = 'Kompakt ve ekonomik bir araba.',
            model = 'prairie',
            price = 65,
            icon = 'car',
            image = 'nui://fz-rental/web/images/prairie.png',
        },
        {
            name = 'Asea',
            description = 'Pratik, 4 kapılı bir sedan.',
            model = 'asea',
            price = 70,
            icon = 'car',
            image = 'nui://fz-rental/web/images/asea.png',
        },
        {
            name = 'Intruder',
            description = 'Konforlu, orta boy bir sedan.',
            model = 'intruder',
            price = 80,
            icon = 'car',
            image = 'nui://fz-rental/web/images/intruder.png',
        },
        {
            name = 'Premier',
            description = 'Günlük kullanım için dengeli bir sedan.',
            model = 'premier',
            price = 85,
            icon = 'car',
            image = 'nui://fz-rental/web/images/premier.png',
        },
        {
            name = 'Stanier',
            description = 'Sağlam, büyük boy bir sedan.',
            model = 'stanier',
            price = 90,
            icon = 'car',
            image = 'nui://fz-rental/web/images/stanier.png',
        },
        {
            name = 'Asterope',
            description = 'Sade ve verimli bir aile arabası.',
            model = 'asterope',
            price = 75,
            icon = 'car',
            image = 'nui://fz-rental/web/images/asterope.png',
        },
        {
            name = 'RancherXL',
            description = 'Günlük kullanım için basit bir SUV.',
            model = 'rancherxl',
            price = 95,
            icon = 'car',
            image = 'nui://fz-rental/web/images/rancherxl.png',
        },
    },
}

Config.vehicles.rental_3 = Config.vehicles.rental_2 -- same cars at the Del Perro point

-- DaddyRP: Cayo kampüs kapısı, motor/scooter
Config.vehicles.rental_4 = {
    { name = 'Scooter', description = 'Kampüs ile şehir arası elektrikli scooter.', model = 'gcscoot', price = 15, icon = 'car' },
}
