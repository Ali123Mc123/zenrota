---[[
--- All accepted values are specified in `shared/types/__job.lua`.
---]]

---@type Job
return {
    -- Minimum required level to start the job
    level = 1,
    requiredMinCopCount = 0,
    enabled = false,

    -- Job title displayed in the UI
    label = locale('meth_job.label'),

    -- Short mission description
    description = locale('meth_job.description'),

    -- UI image for the mission
    image = 'meth_lab.png',

    -- Rewards for completing the mission
    reward = { exp = 5, money = 'Random' },

    -- Additional info or lore for the mission
    information = locale('meth_job.information'),

    -- Step-by-step instructions for the mission
    steps = {
        { label = locale('meth_job.steps.1') },
        { label = locale('meth_job.steps.2'), timeLimit = 60 * 30, },
    },

    -- Blips
    blips = {
        lab_location = { sprite = 270, color = 5, text = locale('meth_job.blips.lab_location') },
    },

    --[[ Game mechanics and settings ]]
    game = {
        police_alert_chance = 0.0, -- 20% chance to alert police when packaging meth

        -- Difficulty of the mini-game
        skillCheck = {
            enabled = true,
            difficulty = { 'easy', 'easy', 'easy' },
            keys = { '1', '2', '3' },
            activeActions = {
                cooking = false,
                hammering = false,
                packing = true,
            }
        },

        -- If you have an MLO map and want to use it!
        -- Set useShellInterior to false, and you must also adjust all ``coords`` values for ``scene`` scenes to match your map.
        -- We do not provide support for this. You must set it up yourself !

        useShellInterior = true, -- true = use shell interior, false = use mlo interior

        shell_interior = {
            coords = vector3(1009.5, -3196.6, -38.99682),
            entrance = vector4(997.7157, -3198.7317, -37.3937, 347.3677),
            exitPoint = vector3(996.89, -3200.64, -36.39),
        },

        shell_interior_lab_locations = {
            { entrance = vector4(2389.2461, 3341.7229, 47.9395, 0.0), exit = vector3(2389.2461, 3341.7229, 47.9395), item = 'tacir2_key' }, -- meth
            { entrance = vector4(2337.6169, 2605.4595, 47.3122, 327.6031), exit = vector3(2337.6169, 2605.4595, 47.3122), item = 'tacir1_key' }, -- meth
            { entrance = vector4(848.0728, 2864.1748, 58.4857, 298.2540),  exit = vector3(848.0728, 2864.1748, 58.4857),  item = 'tacir3_key' }, -- meth
        },

        mlo_interior_lab_locations = {
            vector3(198.9336, 2459.0754, 55.6908), -- MLO interior location 1 - [bamboozled barnlab]
        },

        cookScene = {
            requiredItems = {
                { label = 'Amonyak',       itemName = 'ammonia', count = 1 },
                { label = 'Sülfürik Asit', itemName = 'sacid',   count = 1 },
            },
            rewardItems = {
                { label = 'Pişmiş Kristal', itemName = 'cooked_meth', count = 1 },
            },
            coords = {
                mlo_interior = {},
                shell_interior = {
                    {
                        coords = vector3(1005.74, -3200.39, -38.52),
                        offset = vector3(5.0, 2.0, -0.40),
                        rotation = vector3(0.0, 0.0, 0.0),
                    },
                },
            },
        },

        hammerScene = {
            requiredItems = {
                { label = 'Pişmiş Kristal', itemName = 'cooked_meth', count = 1 },
            },
            rewardItems = {
                { label = 'İşlenmemiş Kristal', itemName = 'breaked_meth', count = 1 },
            },
            coords = {
                mlo_interior = {},
                shell_interior = {
                    {
                        coords = vector3(1016.44, -3194.87, -38.99),
                        offset = vector3(-3.16, -1.75, -1.0),
                        rotation = vector3(0.0, 0.0, 0.0),
                    }
                },
            },
        },

        packingScene = {
            requiredItems = {
                { label = 'İşlenmemiş Kristal', itemName = 'breaked_meth', count = 1 },
            },
            rewardItems = {
                { label = 'Paketlenmiş Kristal', itemName = 'packed_meth', count = 1 },
            },
            coords = {
                mlo_interior = {},
                shell_interior = {
                    {
                        coords = vector3(1012.07, -3194.95, -38.99),
                        offset = vector3(-4.71, -1.52, -1.0),
                        rotation = vector3(0.0, 0.0, 0.0),
                    },
                },
            },
        },
    },
}
