WaterSlideConfig = ActivitySettings.resolve('water_slide', {
    debug = false, -- true: logs for this activity only.
    enabled = true,
    price = 0, -- 0 = free.
    interaction = 'target', -- 'target' or 'textui'.
    entries = {
        { offset = vector3(-4.7263, 3.8789, 9.9594), radius = 2.5 },
        { offset = vector3(-4.6209, 6.1909, 9.9843), radius = 2.5 },
        { offset = vector3(-5.5269, 6.8733, 9.9594), radius = 2.5 },
    },
    target = { height = -0.45, radius = 1.4 },
    blip = {
        enabled = false,
        sprite = 410,
        colour = 3,
        scale = 0.8,
        label = ActivityLocale.water_slide(),
    },
    coords = vector4(-1745.229858, -1051.742432, -0.224665, 229.911285), -- Set with /aquanew.
    waterLevel = 0.0,
    lanes = {
        { enabled = true },
        { enabled = true },
        { enabled = true },
    },
    ride = {
        exitSpeed = 5.0,
        finalBoost = { distance = 8.0, speed = 10.0, acceleration = 7.0 }, -- Set false to disable.
    },
    fall = {
        lift = 1.6,
    },
    lyingPose = {
        offset = vector3(0.0, 0.0, 0.15),
        rotation = vector3(0.0, 0.0, 180.0),
    },
    multiplayer = {
        startDelayMilliseconds = 2000,
        laneCooldownMilliseconds = 2500,
    },
    camera = {
        defaultView = 3, -- 1: follow, 2: front, 3: drone.
    },
})
