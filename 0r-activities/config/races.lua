RacesConfig = {
    entry = vector4(-1841.1715, -1309.6899, 3.0674, 57.9088), -- Shared Formula 1 / Skart Race NPC position and heading.
    blip = { -- Shared Formula 1 / Skart Race NPC blip.
        enabled = false, -- false hides the map blip.
        sprite = 38,
        colour = 1,
        scale = 0.8,
    },
    formula1 = {
        debug = false, -- true: logs for this activity only.
        enabled = false, -- DaddyRP: iskeledeki sorun cozulene kadar kapali (cok ticket)
        joinRadius = 4.0,
        model = 'openwheel1',
        ghostMode = true, -- true: race cars drive through each other; false: they collide
        removeSpoiler = false,
        disabledVehicleExtras = {},
        laps = 3, -- Laps needed to finish.
        capacity = 8,
        countdownSeconds = 5,
        raceTimeout = 900000,
        trackExitDistance = 120.0,
        resetPenalty = 5000,
        vehicleColours = {
            27,
            111,
            64,
            89,
        },
        maxSpeed = 70.5556, -- Vehicle speed limit in m/s.
        grid = { -- Race starting positions and headings.
            vector4(2266.7490, 7821.9824, 423.5197, 327.1388),
            vector4(2262.6760, 7824.3618, 423.5198, 330.7168),

            vector4(2262.6630, 7813.9634, 423.5197, 327.1388),
            vector4(2258.5900, 7816.3428, 423.5198, 330.7168),

            vector4(2258.5770, 7805.9444, 423.5197, 327.1388),
            vector4(2254.5040, 7808.3238, 423.5198, 330.7168),

            vector4(2254.4910, 7797.9254, 423.5197, 327.1388),
            vector4(2250.4180, 7800.3048, 423.5198, 330.7168),
        },
        paddockPositions = { -- Positions used in the race lobby.
            vector4(2236.000, 7835.000, 423.520, 27.0),
            vector4(2231.900, 7837.400, 423.520, 27.0),
            vector4(2233.503, 7830.099, 423.520, 27.0),
            vector4(2229.403, 7832.499, 423.520, 27.0),
            vector4(2231.006, 7825.199, 423.520, 27.0),
            vector4(2226.906, 7827.599, 423.520, 27.0),
            vector4(2228.509, 7820.298, 423.520, 27.0),
            vector4(2224.409, 7822.698, 423.520, 27.0),
        },
        checkpointStep = 5,
    },
    skart_race = {
        debug = false, -- true: logs for this activity only.
        enabled = false, -- DaddyRP: iskeledeki sorun cozulene kadar kapali (cok ticket)
        mapResource = '0r-activities-assets',
        joinRadius = 4.0,
        model = 'skart',
        ghostMode = true, -- true: race cars drive through each other; false: they collide
        removeSpoiler = true,
        disabledVehicleExtras = {
            2,
        },
        laps = 3, -- Laps needed to finish.
        capacity = 6,
        countdownSeconds = 5,
        raceTimeout = 900000,
        trackExitDistance = 18.0,
        resetPenalty = 5000,
        vehicleColours = {
            27,
            111,
            64,
            89,
        },
        maxSpeed = 49.5556, -- Vehicle speed limit in m/s.
        grid = { -- Race starting positions and headings.
            vector4(3755.874354, -2372.163312, 970.395508, 220.0),
            vector4(3753.308105, -2374.316650, 970.459229, 220.0),
            vector4(3750.741856, -2376.469988, 970.467224, 220.0),
            vector4(3753.142507, -2368.907623, 970.627197, 220.0),
            vector4(3750.576258, -2371.060961, 970.645081, 220.0),
            vector4(3748.010009, -2373.214300, 970.703186, 220.0),
        },
        paddockPositions = { -- Positions used in the race lobby.
            vector4(3696.257, -2372.971, 968.588, 180.0),
            vector4(3699.757, -2372.971, 968.588, 180.0),
            vector4(3703.257, -2372.971, 968.588, 180.0),
            vector4(3706.757, -2372.971, 968.588, 180.0),
            vector4(3710.257, -2372.971, 968.588, 180.0),
            vector4(3713.757, -2372.971, 968.588, 180.0),
        },
        startCheckpoint = 25,
    },
}
