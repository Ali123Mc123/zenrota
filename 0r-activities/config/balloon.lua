BalloonConfig = ActivitySettings.resolve('balloon', {
    debug = false, -- true: logs for this activity only.
    enabled = true,
    npc = {
        model = 's_m_y_airworker',
        coords = vector4(-1849.6373, -1318.4617, 3.0674, 26.9693), -- NPC position and heading.
    },
    balloon = {
        model = '0r_balloon',
        -- Static balloon beside the NPC, not used for flights.
        parked = {
            enabled = true,
            coords = vector4(-1561.8306, -1033.2313, 13.0175, 48.2864),
        },
        -- Each rental uses the first available launch location.
        spawnLocations = {
            vector4(-1583.5657, -1049.2731, 13.0179, 136.6906),
        },
        spawnClearance = {
            players = 3.0,
            vehicles = 5.0,
        },
    },
    entryFee = {
        enabled = true,
        price = 1000,
    },
    lobby = {
        capacity = 4,
        joinRadius = 4.0,
        startRadius = 6.0,
    },
    flight = {
        center = vector3(-1560.8169, -1027.8436, 13.0177), -- Center of the allowed flight area.
        radius = 450.0, -- Flight area radius in metres.
        boundaryMargin = 8.0,
        maxAltitude = 240.0, -- Maximum flight altitude.
        durationMilliseconds = 900000, -- Flight time limit in milliseconds.
        forwardSpeed = 5.0, -- Forward flight speed in m/s.
        reverseSpeed = 4.0,
        strafeSpeed = 4.5,
    },
    target = {
        label = ActivityLocale.balloon_lobby(),
        icon = 'fa-solid fa-cloud',
    },
    blip = {
        enabled = false, -- false hides the map blip.
        name = ActivityLocale.hot_air_balloon_ride(),
        sprite = 94,
        colour = 3,
        scale = 0.8,
        radiusColour = 3,
        radiusAlpha = 70,
    },
})
