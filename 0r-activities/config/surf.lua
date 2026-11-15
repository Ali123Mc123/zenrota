SurfConfig = ActivitySettings.resolve('surf', {
    debug = false, -- true: surf and boat rental logs only.
    maximumSpawnDistance = 6.0,
    visualSynchronization = {
        motionSource = 'network', -- 'snapshots' uses the custom transform fallback.
    },
    items = {
        surfboard_sunset_ray = {
            item = 'surfboard_sunset_ray', -- Inventory item name. If you change it, rename the item in your inventory too.
            label = ActivityLocale.sunset_ray_surfboard(),
            kind = 'surf',
            model = 'prop_surf_board_ldn_03',
        },
        surfboard_sea_drifter = {
            item = 'surfboard_sea_drifter', -- Inventory item name. If you change it, rename the item in your inventory too.
            label = ActivityLocale.sea_drifter_surfboard(),
            kind = 'surf',
            model = 'prop_surf_board_ldn_04',
        },
        surfboard_lifeguard = {
            item = 'surfboard_lifeguard', -- Inventory item name. If you change it, rename the item in your inventory too.
            label = ActivityLocale.lifeguard_surfboard(),
            kind = 'surf',
            model = 'prop_beach_lg_surf',
        },
        surfboard_venice_02 = {
            item = 'surfboard_venice_02', -- Inventory item name. If you change it, rename the item in your inventory too.
            label = ActivityLocale.venice_classic_ii(),
            kind = 'surf',
            model = 'prop_venice_board_03',
        },
        paddleboard = {
            item = 'paddleboard', -- Inventory item name. If you change it, rename the item in your inventory too.
            label = ActivityLocale.paddleboard(),
            kind = 'paddle',
            model = 'prop_beach_lg_surf',
        },
    },
    surf = {
        maxSpeed = 14.0, -- Normal board speed in m/s.
        boostSpeed = 20.0, -- Board speed while boosting, in m/s.
        jumpForce = 8.0, -- Jump strength; higher values give a higher jump.
    },
    paddle = {
        maxSpeed = 8.5, -- Normal board speed in m/s.
        jumpForce = 2.5, -- Jump strength; higher values give a higher jump.
    },
    rental = {
        enabled = true,
        price = 750,
        durationMilliseconds = 600000,
        maximumDistance = 1500.0,
        npc = {
            model = 'a_m_y_jetski_01',
        },
        boatModel = 'dinghy2',
        target = {
            label = ActivityLocale.boat_activities(),
            icon = 'fa-solid fa-water',
        },
        interactRadius = 3.0,
        autoSpeed = 11.0,
        capacity = 4,
    },
})
