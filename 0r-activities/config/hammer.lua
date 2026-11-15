HammerConfig = ActivitySettings.resolve('hammer', {
    debug = false, -- true: logs for this activity only.
    enabled = true,
    base = vector4(-1651.139, -1108.702, 22.719, 0.0), -- Ride position and heading.
    maximumHeight = 16.02, -- Maximum platform lift height.
    npc = {
        model = 's_m_y_valet_01',
        coords = vector4(-1647.6190, -1111.9110, 12.0174, 232.3370), -- NPC position and heading.
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        interactionRadius = 2.5,
    },
    blip = {
        enabled = false,
        sprite = 266,
        colour = 1,
        scale = 0.72,
        name = ActivityLocale.drop_tower(),
    },
    queueSeconds = 15,
    capacity = 16,
    durationMilliseconds = 54000, -- Ride duration in milliseconds.
    exit = vector4(-1654.45, -1111.5, 12.15, 320.0), -- Return position after the ride.
})
