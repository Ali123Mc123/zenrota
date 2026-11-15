FerrisConfig = {
    debug = false, -- true: logs for this activity only.
    enabled = true, -- false disables the activity and prevents props and NPCs from spawning.
    entry = vector3(-1660.5935, -1122.0820, 13.0185), -- NPC and boarding position.
    wheelBase = vector3(-1663.97, -1126.7, 30.7), -- Ferris wheel position.
    speed = 2.5, -- Wheel rotation speed.
    capacity = 4, -- Players per cabin.
    groupCapacity = 4,
    joinRadius = 3.0,
    npc = {
        model = 's_m_y_valet_01',
        heading = 299.4489,
        interactionRadius = 2.0,
    },
    blip = {
        enabled = false,
        name = ActivityLocale.ferris_wheel(),
        sprite = 266,
        colour = 8,
        scale = 0.75,
    },
}
