WaterActivitiesConfig = ActivitySettings.resolve('water_activities', {
    debug = false, -- true: shared water activity logs only.
    npc = vector4(-1801.6776, -857.9256, 6.4380, 111.1934), -- Shared water activity NPC position and heading.
    blip = { -- Map blip for the shared water activity NPC.
        enabled = false, -- false hides the map blip; the activities stay available.
        name = ActivityLocale.boat_activities(),
        sprite = 427,
        colour = 3,
        scale = 0.75,
    },
    itemUse = {
        requirePedInWater = true,
        minimumDepth = 0.30, -- Minimum water depth for using equipment, in metres.
    },
    landCleanup = {
        enabled = true,
        graceMilliseconds = 5000, -- Time allowed on land before collecting equipment, in milliseconds.
    },
    spawnLocations = { -- Available rental boat spawn positions and headings.
        vector4(-1868.3466, -961.7498, -1.0996, 123.9158),
        vector4(-1903.5050, -909.6629, -0.9795, 123.9158),
        vector4(-1913.1931, -902.2169, -1.1331, 123.9158),
        vector4(-1927.8552, -894.2950, -1.5651, 123.9158),
    },
    playerClearance = 3.0,
    -- Boat activities preview, shown while the boat lobby is open: the boat and its riders go straight ahead
    -- from origin for length metres at speed m/s, then the screen blinks and they start again.
    -- Empty seats are filled by npcModels; players who join the group take their places.
    -- side picks which side the wide camera stands on (1 = left of the boat, -1 = right).
    preview = {
        enabled = true,
        debug = false, -- true: preview camera key logs only.
        origin = vector4(-2065.6155, -732.3685, 0.4618, 131.3608),
        length = 600.0,
        speed = 10.0,
        side = 1,
    },
    vehicleClearance = 7.0,
})
