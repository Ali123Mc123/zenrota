DivingConfig = ActivitySettings.resolve('diving', {
    debug = false, -- true: logs for this activity only.
    enabled = true,
    blip = {
        enabled = false, -- false hides the map blip.
        name = ActivityLocale.trophy_hunt(),
        sprite = 455,
        colour = 3,
        scale = 0.78,
    },
    capacity = 4,
    durationMilliseconds = 600000, -- Trip time limit in milliseconds.
    delivery = {
        radius = 5.0,
        verticalTolerance = 4.0,
        drawDistance = 80.0,
        markerHeight = 3.5,
        colour = {
            45,
            145,
            245,
            135,
        },
    },
    boatModel = 'dinghy',
    controls = {
        cancel = 47, -- G. Ends the search and finishes the dive at the NPC.
    },
    detectorModel = false,
    rewards = {
        account = 'cash',
        customResource = '',
        customExport = '',
    },
    npc = {
        model = 'a_m_y_jetski_01',
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        interactionRadius = 2.5,
    },
    gameplay = {
        findsPerTrip = 12, -- Base number of finds per trip.
        extraFindsPerPlayer = 2,
        recoverMilliseconds = 3000,
        searchRadius = 85.0,
        boatAnchorMargin = 20.0,
        boatBoardingRadius = 7.0,
        recoverRadius = 2.2,
        maximumUnderwaterSeconds = 600.0,
    },
    equipment = {
        -- DaddyRP: 0r-fishingv2 dalış kıyafeti (0r-fishingv2/config/diving.lua Cloths). Maske ve çanta
        -- burada kalıyor: fishing maskeyi ayrı obje olarak takıyor, 0r-activities'te o obje yok.
        outfits = {
            male = {
                [1] = { -- Mask
                    drawable = 36,
                    texture = 0,
                },
                [3] = { -- Arms / gloves
                    drawable = 1,
                    texture = 0,
                },
                [4] = { -- Pants
                    drawable = 916,
                    texture = 0,
                },
                [5] = { -- Bag / parachute
                    drawable = 0,
                    texture = 0,
                },
                [6] = { -- Shoes
                    drawable = 306,
                    texture = 0,
                },
                [7] = { -- Accessories (neck, chains)
                    drawable = 0,
                    texture = 0,
                },
                [8] = { -- Undershirt
                    drawable = 299,
                    texture = 0,
                },
                [9] = { -- Body armor
                    drawable = 0,
                    texture = 0,
                },
                [10] = { -- Decals
                    drawable = 0,
                    texture = 0,
                },
                [11] = { -- Top / jacket
                    drawable = 1977,
                    texture = 0,
                },
            },
            female = {
                [1] = { -- Mask
                    drawable = 36,
                    texture = 0,
                },
                [3] = { -- Arms / gloves
                    drawable = 30,
                    texture = 0,
                },
                [4] = { -- Pants
                    drawable = 313,
                    texture = 0,
                },
                [5] = { -- Bag / parachute
                    drawable = 0,
                    texture = 0,
                },
                [6] = { -- Shoes
                    drawable = 442,
                    texture = 20,
                },
                [7] = { -- Accessories (neck, chains)
                    drawable = 0,
                    texture = 0,
                },
                [8] = { -- Undershirt
                    drawable = 1245,
                    texture = 0,
                },
                [9] = { -- Body armor
                    drawable = 0,
                    texture = 0,
                },
                [10] = { -- Decals
                    drawable = 0,
                    texture = 0,
                },
                [11] = { -- Top / jacket
                    drawable = 2306,
                    texture = 0,
                },
            },
        },
    },
    sonar = {
        lampEnabled = true,
        range = 80.0,
    },
    loot = {
        {
            key = 'old_coins',
            label = ActivityLocale.old_coins(),
            minimum = 2,
            maximum = 5,
            unitPrice = 25, -- Cash reward per item; adjust to your economy.
            weight = 35,
        },
        {
            key = 'silver_relic',
            label = ActivityLocale.silver_residue(),
            minimum = 1,
            maximum = 2,
            unitPrice = 30, -- Cash reward per item; adjust to your economy.
            weight = 28,
        },
        {
            key = 'antique_watch',
            label = ActivityLocale.antique_watch(),
            minimum = 1,
            maximum = 1,
            unitPrice = 35, -- Cash reward per item; adjust to your economy.
            weight = 20,
        },
        {
            key = 'golden_idol',
            label = ActivityLocale.golden_idol(),
            minimum = 1,
            maximum = 1,
            unitPrice = 40, -- Cash reward per item; adjust to your economy.
            weight = 12,
        },
        {
            key = 'rare_gem',
            label = ActivityLocale.rare_jewelry(),
            minimum = 1,
            maximum = 1,
            unitPrice = 50, -- Cash reward per item; adjust to your economy.
            weight = 5,
        },
    },
    locations = { -- NPC, return point, boat spawns and underwater search areas.
        {
            npc = vector4(-3428.3162, 967.7448, 8.3467, 267.7343),
            delivery = vector4(-3441.9207, 968.2846, 0.4097, 359.8482),
            boatSpawns = { -- Available boat spawn positions and headings.
                vector4(-3438.4490, 953.5596, 2.0841, 85.0832),
                vector4(-3439.2971, 964.8042, 2.2748, 85.2406),
                vector4(-3438.8862, 975.6693, 2.1439, 72.7603),
            },
            boatSpawnClearance = 7.0,
            searchSites = { -- Underwater search areas and loot positions.
                {
                    name = ActivityLocale.pacific_reefs(),
                    center = vector3(-2840, -380, -40),
                    searchRadius = 195.0,
                    points = {
                        vector4(-2849.250000, -377.579987, -41.979973, 67.000000),
                        vector4(-2841.250000, -375.579987, -41.679977, 134.000000),
                        vector4(-2852.076416, -384.318817, -41.729977, 201.000000),
                        vector4(-2838.429932, -363.630005, -40.549984, 268.000000),
                        vector4(-2831.881348, -362.929688, -40.349987, 335.000000),
                        vector4(-2844.802490, -367.849640, -41.499969, 42.000000),
                        vector4(-2888.941895, -392.920471, -42.259979, 109.000000),
                        vector4(-2879.840820, -393.319885, -42.259979, 176.000000),
                        vector4(-2894.470947, -403.158447, -40.910000, 243.000000),
                        vector4(-2807.688721, -387.159607, -40.419983, 310.000000),
                        vector4(-2804.993896, -384.359802, -38.920006, 17.000000),
                        vector4(-2810.164795, -391.299072, -40.669979, 84.000000),
                        vector4(-2884.189941, -372.437256, -42.375576, 58.803501),
                        vector4(-2891.703369, -315.283173, -42.132591, 353.449310),
                        vector4(-2835.100830, -293.817261, -34.402977, 305.614594),
                        vector4(-2776.115234, -301.057037, -18.179972, 261.598785),
                        vector4(-2771.264404, -345.489746, -21.239088, 315.247314),
                        vector4(-2661.758301, -324.469086, -7.276803, 270.680389),
                        vector4(-2696.515869, -386.783905, -5.821705, 50.483700),
                        vector4(-2844.299072, -266.876587, -23.955276, 59.420700),
                        vector4(-2843.380615, -224.321533, -17.786278, 55.680500),
                    },
                },
                {
                    name = ActivityLocale.chumash_underwater_treads(),
                    center = vector3(-3300, -52, -27),
                    searchRadius = 355.0,
                    points = {
                        vector4(-3275.030029, -38.580002, -22.459949, 67.000000),
                        vector4(-3267.030029, -36.580002, -22.059956, 134.000000),
                        vector4(-3279.558105, -44.368938, -23.459934, 201.000000),
                        vector4(-3281.371094, -31.318451, -21.659962, 268.000000),
                        vector4(-3274.030273, -76.000000, -29.009966, 335.000000),
                        vector4(-3265.379639, -74.300018, -28.109980, 42.000000),
                        vector4(-3278.808594, -82.388924, -30.609941, 109.000000),
                        vector4(-3279.120117, -70.038429, -27.909983, 176.000000),
                        vector4(-3346.630127, -50.799995, -37.239979, 243.000000),
                        vector4(-3338.279785, -47.200020, -35.939999, 310.000000),
                        vector4(-3349.356445, -54.988956, -38.839954, 17.000000),
                        vector4(-3352.220459, -44.588428, -35.190010, 84.000000),
                        vector4(-3363.265869, -42.143200, -33.685886, 61.575001),
                        vector4(-3395.040039, -2.909901, -38.388573, 59.212700),
                        vector4(-3412.777100, 37.464390, -39.673477, 11.811200),
                        vector4(-3226.377686, -65.218697, -21.367579, 277.702087),
                        vector4(-3181.666992, -131.265701, -23.494757, 189.906799),
                        vector4(-3240.424072, -171.396103, -45.418655, 88.135101),
                        vector4(-3349.094238, -80.776253, -45.921669, 43.095699),
                        vector4(-3418.554199, -14.722300, -42.125271, 5.969800),
                        vector4(-3463.334961, 256.036804, -49.309082, 15.536600),
                    },
                },
                {
                    name = ActivityLocale.banham_deep_reef(),
                    center = vector3(-3355, 1600, -40),
                    searchRadius = 110.0,
                    points = {
                        vector4(-3387.109131, 1634.528687, -44.459923, 67.000000),
                        vector4(-3380.010010, 1637.880005, -44.659920, 134.000000),
                        vector4(-3395.641113, 1626.988647, -43.909931, 201.000000),
                        vector4(-3393.600342, 1641.741455, -44.659920, 268.000000),
                        vector4(-3355.040771, 1550.250977, -41.759945, 335.000000),
                        vector4(-3345.239014, 1552.551270, -37.410011, 42.000000),
                        vector4(-3360.369629, 1542.060303, -43.559917, 109.000000),
                        vector4(-3359.530029, 1554.911255, -40.959957, 176.000000),
                        vector4(-3327.841797, 1636.780396, -41.779987, 243.000000),
                        vector4(-3312.334473, 1641.633179, -38.080044, 310.000000),
                        vector4(-3330.518066, 1630.241333, -41.529991, 17.000000),
                        vector4(-3331.730469, 1641.090332, -43.179966, 84.000000),
                        vector4(-3395.715332, 1577.462769, -43.759487, 112.256897),
                        vector4(-3409.420654, 1606.052490, -42.049301, 60.839500),
                        vector4(-3385.378662, 1659.848145, -46.473877, 298.792389),
                        vector4(-3327.122314, 1614.688477, -40.017780, 236.626999),
                        vector4(-3296.935303, 1552.704590, -27.481386, 294.776794),
                        vector4(-3313.139893, 1508.839478, -35.202579, 191.194107),
                        vector4(-3411.048340, 1516.503540, -66.294235, 103.674400),
                        vector4(-3322.110596, 1544.901489, -36.149677, 224.651001),
                        vector4(-3391.375977, 1583.249756, -43.926975, 94.966103),
                    },
                },
            },
        },
    },
})
