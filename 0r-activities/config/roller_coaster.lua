CoasterConfig = {
    debug = false, -- true: logs for this activity only.
    enabled = true, -- false disables the activity and prevents props and NPCs from spawning.
    entry = vector3(-1643.4801, -1121.3492, 17.3386), -- NPC and boarding position.
    queueSeconds = 15, -- Wait before the ride starts, in seconds.
    laps = 2, -- Laps per ride.
    capacity = 16,
    groupCapacity = 4,
    joinRadius = 6.0,
    queueRadius = 8.0,
    npc = {
        model = 's_m_y_valet_01',
        heading = 138.3591,
        interactionRadius = 4.5,
    },
    blip = {
        enabled = false,
        name = ActivityLocale.roller_coaster(),
        sprite = 266,
        colour = 27,
        scale = 0.75,
    },
    exitPoints = { -- Player return positions after the ride.
        vector3(-1641.914, -1125.268, 17.3424),
        vector3(-1642.606, -1126.240, 17.3424),
        vector3(-1643.573, -1127.390, 17.3424),
        vector3(-1644.271, -1128.200, 17.3424),
        vector3(-1645.343, -1129.313, 17.3424),
        vector3(-1645.966, -1130.067, 17.3424),
        vector3(-1647.022, -1131.291, 17.3424),
        vector3(-1647.645, -1132.016, 17.3424),
        vector3(-1648.713, -1133.282, 17.3424),
        vector3(-1649.336, -1134.007, 17.3424),
        vector3(-1650.404, -1135.273, 17.3424),
        vector3(-1651.027, -1135.998, 17.3424),
        vector3(-1652.095, -1137.264, 17.3424),
        vector3(-1652.718, -1137.989, 17.3424),
        vector3(-1653.786, -1139.255, 17.3424),
        vector3(-1654.409, -1139.980, 17.3424),
    },
}
