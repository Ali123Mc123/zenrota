GroundGearConfig = ActivitySettings.resolve('ground_gear', {
    debug = false, -- true: logs for this activity only.
    maximumSpawnDistance = 5.0,
    items = {
        roller_skates = {
            item = 'roller_skates', -- Inventory item name. If you change it, rename the item in your inventory too.
            label = ActivityLocale.roller_skates(),
            kind = 'roller',
            barefoot = { -- Barefoot drawable (shoes, component 6) while skating. Match it to your clothing pack.
                male = 34,
                female = 35,
            },
            maxSpeed = 16.0, -- Normal riding speed in m/s.
            sprintMaxSpeed = 20.0, -- Riding speed while holding sprint, in m/s.
            jumpForce = 6.5, -- Jump strength; higher values give a higher jump.
        },
        skateboard = {
            item = '0r_skateboard', -- Inventory item name. If you change it, rename the item in your inventory too.
            label = ActivityLocale.skateboard(),
            kind = 'skateboard',
            maxSpeed = 16.0, -- Normal riding speed in m/s.
            sprintMaxSpeed = 20.0, -- Riding speed while holding sprint, in m/s.
            jumpForce = 6.5, -- Jump strength; higher values give a higher jump.
        },
        hoverboard = {
            item = '0r_hoverboard', -- Inventory item name. If you change it, rename the item in your inventory too.
            label = ActivityLocale.hoverboard(),
            kind = 'hoverboard',
            maxSpeed = 16.0, -- Normal riding speed in m/s.
            sprintMaxSpeed = 20.0, -- Riding speed while holding sprint, in m/s.
            jumpForce = 6.5, -- Jump strength; higher values give a higher jump.
        },
    },
})
