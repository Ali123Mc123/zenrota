ZiplineConfig = ActivitySettings.resolve('zipline', {
    debug = false, -- true: logs for this activity only.
    enabled = true,
    blip = {
        enabled = false, -- false hides the map blip.
        sprite = 727, -- Blip names come from each line's name below.
        colour = 15,
        scale = 0.8,
    },
    interactionRadius = 3.0,
    targetZoneRadius = 2.0,
    boardingIntervalMilliseconds = 2000,
    speedMultiplier = 2.00, -- Travel speed multiplier; higher values make the ride faster.
    locations = { -- Zipline routes; add entries exported by /ziplinenew.
        {
            name = 'Zipline',
            start = vector3(-1136.496216, 4658.705078, 245.664978), -- Upper boarding position.
            finish = vector3(-1131.325317, 4313.092773, 88.231361), -- Lower landing position.
            channelOffset = vector3(-1.039921, -0.170065, 0.0), -- Offset of the second lane from the first.
            seconds = 47.5, -- Base travel time before the speed multiplier is applied.
            speedMultiplier = 2.00,
            sag = 0.0,
        },
        {
            name = 'Zipline',
            start = vector3(-766.034607, 4337.898926, 149.483353),
            finish = vector3(-771.129700, 4503.135742, 89.887924),
            channelOffset = vector3(1.052759, -0.045352, 0.0),
            seconds = 22.0,
            speedMultiplier = 2.00,
            sag = 0.0,
        },
        {
            name = 'Zipline',
            start = vector3(495.341766, 5500.211426, 775.914429),
            finish = vector3(-1180.745972, 3862.249023, 490.393738),
            channelOffset = vector3(1.051979, -0.060807, 0.0),
            seconds = 120.0,
            sag = 0.0,
        },
        {
            name = 'Zipline',
            start = vector3(-488.193756, -980.842163, 54.529354),
            finish = vector3(-478.908630, -791.739990, 48.499279),
            channelOffset = vector3(-1.052606, -0.048771, 0.0),
            seconds = 23.7,
            sag = 0.0,
        },
    },
})
