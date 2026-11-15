HydroflyConfig = ActivitySettings.resolve('hydrofly', {
    debug = false, -- true: logs for this activity only.
    enabled = true,
    price = 500,
    durationMilliseconds = 300000,
    npc = {
        model = 'a_m_y_jetski_01',
        coords = vector4(-1805.1593, -1369.2826, 0.9021, 228.7726), -- NPC position and heading.
    },
    interactRadius = 3.0,
    spawn = vector4(-1990.0, -1430.0, 2.2381, 331.8256), -- Equipment spawn position and heading. DaddyRP: eski nokta (-1942.37, -1398.37) uzerinde harita zemini (z 2.3) var, su bulunamiyor ve hazirlik iptal oluyordu.
    spawnPlayerClearance = 1.5,
    exit = vector4(-1436.6716, -1512.5635, 1.1468, 106.8949), -- Return position after the activity.
    blip = {
        enabled = false, -- false hides the map blip.
        sprite = 68,
        colour = 3,
        scale = 0.75,
    },
    equipment = {
        enabled = true, -- false: the player keeps their own clothes while flying.
        barefoot = { -- Barefoot drawable (shoes, component 6). Match it to your clothing pack.
            male = 34,
            female = 35,
        },
        outfits = { -- Flying outfit: [component id] = drawable and texture.
            male = {
                [1] = { -- Mask (not applied while flying)
                    drawable = 36,
                    texture = 0,
                },
                [3] = { -- Arms / gloves
                    drawable = 8,
                    texture = 0,
                },
                [4] = { -- Pants
                    drawable = 94,
                    texture = 0,
                },
                [5] = { -- Bag / parachute
                    drawable = 0,
                    texture = 0,
                },
                [6] = { -- Shoes (barefoot above is used while flying)
                    drawable = 67,
                    texture = 0,
                },
                [7] = { -- Accessories (neck, chains)
                    drawable = 0,
                    texture = 0,
                },
                [8] = { -- Undershirt
                    drawable = 15,
                    texture = 0,
                },
                [9] = { -- Body armor
                    drawable = 0,
                    texture = 0,
                },
                [10] = { -- Decals
                    drawable = 0,
                    texture = 0,
                },
                [11] = { -- Top / jacket
                    drawable = 243,
                    texture = 5,
                },
            },
            female = {
                [1] = { -- Mask (not applied while flying)
                    drawable = 36,
                    texture = 0,
                },
                [3] = { -- Arms / gloves
                    drawable = 6,
                    texture = 0,
                },
                [4] = { -- Pants
                    drawable = 97,
                    texture = 5,
                },
                [5] = { -- Bag / parachute
                    drawable = 0,
                    texture = 0,
                },
                [6] = { -- Shoes (barefoot above is used while flying)
                    drawable = 70,
                    texture = 0,
                },
                [7] = { -- Accessories (neck, chains)
                    drawable = 0,
                    texture = 0,
                },
                [8] = { -- Undershirt
                    drawable = 1,
                    texture = 0,
                },
                [9] = { -- Body armor
                    drawable = 0,
                    texture = 0,
                },
                [10] = { -- Decals
                    drawable = 0,
                    texture = 0,
                },
                [11] = { -- Top / jacket
                    drawable = 251,
                    texture = 5,
                },
            },
        },
    },
    maximumDistance = 50.0,
    maxSessions = 10, -- Players flying at the same time. 0 = unlimited.
    synchronization = {
        poseIntervalMilliseconds = 50,
        activePoseIntervalMilliseconds = 33, -- Observers simulate the E lean locally; 60 Hz is not needed.
        poseRelayMilliseconds = 33, -- Server forwards only the newest pose at most this often.
        networkDistance = 180.0,
        visualCleanupDistance = 180.0,
    },
    flight = {
        hoverHeight = 1.0,
        maxHeight = 19.0, -- Maximum flying height above the water.
        horizontalSpeed = 5.5, -- Horizontal flight speed in m/s.
        maxDiveDepth = 2.5,
        diveSpeed = 4.0,
    },
})
