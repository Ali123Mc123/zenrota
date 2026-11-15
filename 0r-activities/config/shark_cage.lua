SharkCageConfig = ActivitySettings.resolve('shark_cage', {
    debug = false, -- true: logs for this activity only.
    enabled = true,
    capacity = 2,
    durationMilliseconds = 180000, -- Activity duration in milliseconds.
    locations = {
        {
            cage = vector4(-3401.7454, 1644.9709, -25.0287, 270.1218), -- Underwater cage position and heading.
            tug = vector4(-3401.7454, 1644.9709, 0.15, 270.1218), -- Boat position and heading at the surface.
        },
        {
            cage = vector4(-2852.0342, -369.8189, -28.7283, 79.4233),
            tug = vector4(-2852.0342, -369.8189, 0.15, 79.4233),
        },
        {
            cage = vector4(540.9365, 7306.4248, -25.1577, 189.3342),
            tug = vector4(540.9365, 7306.4248, 0.15, 189.3342),
        },
    },
    equipment = {
        enabled = true,
        maximumUnderwaterSeconds = 600.0,
        outfits = {
            male = {
                [1] = { -- Mask
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
                [6] = { -- Shoes
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
                [1] = { -- Mask
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
                [6] = { -- Shoes
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
    npc = {
        model = 's_m_y_baywatch_01',
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        entry = vector4(-1861.8052, -1321.4000, 3.0674, 352.9536), -- NPC position and heading.
        exit = vector4(-1861.8052, -1321.4000, 3.0674, 352.9536), -- Return position after the activity.
        interactionRadius = 2.5,
        blip = {
            enabled = false, -- false hides the map blip.
            name = ActivityLocale.shark_cage(),
            sprite = 427,
            colour = 3,
            scale = 0.82,
        },
    },
    feeding = {
        maximumUsesPerPlayer = 3,
        cooldownMilliseconds = 650,
        lifetimeMilliseconds = 45000,
    },
})
