PoolFloatsConfig = ActivitySettings.resolve('pool_floats', {
    debug = false, -- true: logs for this activity only.
    enabled = true,
    maxOwnerDistance = 18.0,
    maxPassengerDistance = 18.0,
    rental = {
        enabled = true,
        npc = {
            model = 'a_m_y_jetski_01',
        },
        exit = vector4(-1597.5, -1160.5, 1.1, 140.0), -- Return position after the rental.
        boatModel = 'dinghy2',
        price = { -- Rental price for each float.
            inflatable_duck = 500,
            inflatable_sausage = 800,
            inflatable_flamingo = 500,
            inflatable_unicorn = 500,
        },
        interactRadius = 3.0,
        maximumDistance = 1200.0,
        durationMilliseconds = 600000, -- Rental time limit in milliseconds.
    },
    items = {
        inflatable_duck = {
            label = ActivityLocale.inflatable_duck(),
            model = 'prop_pool_duck',
            capacity = 3,
            towLaneSpacing = 3.0,
        },
        inflatable_sausage = {
            label = ActivityLocale.inflatable_sausage(),
            model = 'prop_pool_sausage',
            capacity = 3,
        },
        inflatable_flamingo = {
            label = ActivityLocale.inflatable_flamingo(),
            model = 'prop_pool_flamingo',
            capacity = 3,
            towLaneSpacing = 3.0,
            waterlineOffset = 0.20, -- Height relative to the water surface.
        },
        inflatable_unicorn = {
            label = ActivityLocale.inflatable_unicorn(),
            model = 'prop_pool_unicorn',
            capacity = 3,
            towLaneSpacing = 3.0,
            waterlineOffset = 0.20, -- Height relative to the water surface.
        },
    },
})
