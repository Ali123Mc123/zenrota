ParasailingConfig = ActivitySettings.resolve('parasailing', {
    debug = false, -- true: logs for this activity only.
    enabled = true,
    price = 1000,
    durationMilliseconds = 300000,
    maximumDistance = 1200.0,
    npc = {
        model = 'a_m_y_jetski_01',
    },
    interactRadius = 3.0,
    boatModel = 'dinghy2',
    exit = vector4(-1591.8, -1156.8, 1.1, 140.0), -- Return position after the activity.
    flight = {
        maximumHeight = 32.0, -- Maximum parasailing height.
        sideLimit = 3.20,
        slots = { -9.5, 9.5 },
        autoSpeed = 12.0, -- Automatic boat speed in m/s.
    },
    equipment = {
        showBackpack = true, -- false: no parachute backpack on the player.
        backpackComponent = 5, -- Clothing slot for the backpack (5 = bag / parachute).
        backpackDrawable = 1, -- Backpack model number in that slot.
        backpackTexture = 0, -- Backpack colour / texture variant.
    },
    capacity = 4,
})
