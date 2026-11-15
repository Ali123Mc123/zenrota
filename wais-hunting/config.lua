Config = {}
Config.Framework = {
    ["Framework"] = "auto",    -- auto, esx, qbcore or qbox
    ["ResourceName"] = "auto", -- auto, es_extended or qb-core or your resource name. If you using qbx you should write qb-core
    ["SharedEvent"] = ""       -- Event name for old cores.
}

Config.Language = "tr"            -- ar, cz, ro, it, fr, de, tr
Config.ShowDebug = false          -- If you set this to `true`, the debug messages will be printed in the console. If you set it to `false`, no debug messages will be printed.
Config.InviteTimeout = 10 * 1000  -- Time in milliseconds before an invite times out.
Config.InviteDistance = 5.0       -- The distance between the person being invited and the person doing the inviting. To prevent certain things from being abused and to prevent things like cheating.
Config.GroupPlayerLimit = 4       -- Maximum number of players allowed in a hunting group.
Config.GroupMemberBlips = true    -- If you set it to `true`, group members' blips will be visible on the map. If you set it to `false`, group members' blips will not be shown.
Config.SplitMissionRewards = true -- If you set it to `true`, the total reward from the task is divided by the number of people in the group, and the reward per person is delivered. If you set it to `false`, the reward is given directly to everyone in the group in the specified amount.
Config.SellAnimalParts = true     -- If you set it to `true`, players can sell the animal parts they obtain from hunting. If you set it to `false`, players will not be able to sell animal parts.
Config.RealisticBehavior = true   -- If you set it to `true`, they will behave just like real animals; they will be afraid of gunshots and people approaching them. If you set it to `false`, they won’t be afraid of people and will continue to eat grass and walk around.

Config.StartingItems = {
    --[[
        The names and amount of hunting items players will receive from the vehicle.
        ⚠️⚠️⚠️
        These items will be automatically deleted
        if you leave the area after taking them, or if you log out of the server.
        ⚠️⚠️⚠️
    ]]
    {
        -- Hunting weapon given to players when they start the job.
        ["name"] = "weapon_musket",
        ["amount"] = 1,
    },
    {
        -- Ammunition for the hunting weapon given to players when they start the job.
        -- detect_auto: If you are using the Ox inventory, it will automatically provide musket ammunition. If you are using another inventory, it will automatically provide shotgun ammunition.
        -- If your musket ammunition is neither of these, please enter your musket ammunition.
        ["name"] = "detect_auto",
        ["amount"] = 100,
    }
}

Config.Skinning = {
    --[[
        ⚠️⚠️⚠️
        Settings related to skinning animals.
        The 'knife' table contains settings for the knife item used in skinning.
        The 'duration' value indicates how long the skinning animation will last in milliseconds.
    ]]

    ["knife"] = {
        ["must"] = false,                                       -- If you set it to `true`, players must have a knife in their inventory to skin the animal. If you set it to `false`, no knife is required.
        ["name"] = "WEAPON_KNIFE",                              -- Name of the knife item.
        ["label"] = "Bıçak",                                    -- Label of the knife item.
    },
    ["duration"] = 5 * 1000,                                    -- Time in milliseconds the animation will last.
    ["anim"] = {
        ["dict"] = "anim@gangops@facility@servers@bodysearch@", -- Animation dictionary to be played.
        ["clip"] = "player_search",                             -- Animation dictionary and clip to be played.
        ["flag"] = 1,                                           -- Animation flag to control how the animation behaves.
    },
}

Config.JobCenter = {
    ["job"] = {
        ["required"] = false, -- If you set it to `true`, only people with the specified job can access the menu. If it is `false`, anyone can perform the job without requiring a specific job title.
        ["name"] = "hunter",  -- The name of the hunting job in Jobs.lua or the jobs table.
        ["grade"] = 0,        -- The grade value of the hunting profession in the Jobs.lua or job_grades table.
    },
    ["ped"] = {
        ["model"] = "mp_m_exarmy_01",                          -- Ped model for the job center.
        ["coords"] = vector4(-679.26, 5834.38, 17.33, 133.20), -- Coordinates for the job center ped.
        ["distance"] = 3.0,                                    -- Interaction distance for the job center ped.
        ["created"] = function(entity)                         -- This function is called when the job center ped is created. You can use it for debugging or other purposes.
            Config.Debug(('Avcılık merkezi oluşturuldu. Entity ID: %s'):format(entity))
        end
    },
    ["blips"] = {
        ["label"] = "Avcılık",                         -- Blip label for the job center.
        ["coords"] = vector3(-679.26, 5834.38, 17.33), -- Blip coordinates for the job center.
        ["sprite"] = 141,                              -- Blip sprite for the job center.
        ["color"] = 5,                                 -- Blip color for the job center.
        ["scale"] = 0.83,                              -- Blip scale for the job center.
        ["show"] = true,                               -- If you set it to `true`, the blip will be shown on the map. If you set it to `false`, the blip will not be displayed.
    }
}

-- DaddyRP: hunting on Cayo Porto is for College students only (daddy_college state bag), checked at the menu and before
-- any pay. Only inside Area (Cayo avcılık NPC'si + bölgesi); kasabadaki (Paleto vb.) avcılık herkese açık kalır.
Config.CollegeGate = {
    Enabled = true,
    Area = { coords = vector3(4730.0, -4510.0, 10.0), radius = 500.0 }, -- nil yaparsan kapı her yerde geçerli olur
    Certificate = 'hunting_license', -- daddy_college certificate; comes by itself at the levels below
    Levels = {                       -- shown in the notice when missing (keep equal to daddy_college hunting_license)
        { lesson = 'polislik', label = 'Polislik', level = 3 },
        { lesson = 'biyoloji', label = 'Biyoloji', level = 3 },
    },
    AdminAce = 'command',            -- this ace skips the gate (testing)
}

Config.ExtraJobCenters = {
    {
        ["ped"] = {
            ["model"] = "mp_m_exarmy_01",
            ["coords"] = vector4(4621.2021, -4417.9961, 3.6176, 93.3889),
            ["distance"] = 3.0,
        },
        ["blips"] = {
            ["label"] = "Avcılık (Cayo Porto)",
            ["coords"] = vector3(4621.2021, -4417.9961, 3.6176),
            ["sprite"] = 141,
            ["color"] = 5,
            ["scale"] = 0.83,
            ["show"] = true,
        }
    }
}

Config.Vehicle = {
    --[[
        Vehicle used for the hunting job.
        - model: The model name of the vehicle.
        - type: The type of vehicle (automobile, bike, etc.).
        - outcoords: The coordinates where the vehicle will spawn when taken out for the job.
        - controlDistance: The distance within which the player must remain from the vehicle while on the job. If the player exceeds this distance, the job will be canceled and the vehicle will be removed.
    ]]

    ["type"] = "automobile",   -- Vehicle type [automobile, bike, boat, heli, plane, submarine, trailer and train]
    ["model"] = "mesa3",       -- Vehicle model name
    ["maxDistance"] = 250.0,   -- The maximum distance the player can be from the vehicle. If they exceed this distance, they will receive a warning every 5 seconds, and after 10 warnings, the vehicle will be deleted.
    ["controlDistance"] = 3.0, -- The width distance at which out coords will be monitored
    ["outcoords"] = {
        --[[
            Coordinates where the vehicle will spawn when taken out for the job.
        ]]
        vec4(-677.6839, 5826.7158, 17.1025, 135.5928),
        vec4(-680.4544, 5828.8892, 17.1015, 133.6158),
        vec4(-683.1483, 5831.2280, 17.1018, 134.0365),
        vec4(-685.2559, 5834.2231, 17.1021, 133.3776),

        -- Cayo Porto araç çıkışı
        vec4(4614.4106, -4426.7979, 3.5084, 88.9956),
    },
}

Config.Zones = {
    --[[
        ⚠️⚠️⚠️
        Hunting zones where animals will spawn.
        You can create multiple zones by copying and pasting the entire table structure below.
        Each zone includes:
        - coords: The center coordinates of the hunting zone.
        - radius: The radius of the hunting zone.
        - maxAnimals: Maximum number of animals that can be present in the zone at any given time.
        - removeAnimal: The deletion period for animals that have died but for which no action has been taken. If an animal dies and is not skinned, it will be deleted within this period.
        - spawnInterval: The interval at which new animals will spawn in the zone.
        - blips: Settings for the blip that appears on the map for the hunting zone.
        - animals: A table of animals that may appear in this area, along with their rarity and attack behavior.
        ⚠️⚠️⚠️
    ]]

    {
        ["coords"] = vector3(-576.35, 5938.56, 31.09),  -- Center coordinates of the hunting zone
        ["radius"] = 80.0,                              -- Radius of the hunting zone
        ["maxAnimals"] = 50,                            -- Maximum number of animals that can be present in the zone at any given time
        ["removeAnimal"] = 0.5 * 60 * 1000,             -- The deletion period for animals that have died but for which no action has been taken. If an animal dies and is not skinned, it will be deleted within this period.
        ["spawnInterval"] = 0.50 * 60 * 1000,           -- A new animal will spawn every 0.60 minutes.
        ["animal_task_time"] = math.random(5000, 8000), -- The duration for which an animal will perform a random task (walking, wander, looking around, grazing) before switching to a new one.
        ["blips"] = {
            ["show"] = true,
            ["label"] = "Avcılık Bölgesi",
            ["color"] = 5,
            ["scale"] = 0.7,
            ["sprite"] = 141,
            ["radius"] = {
                ["show"] = true,
                ["color"] = 5,
                ["alpha"] = 80,
            }
        },
        ["animals"] = {
            --[[
                ⚠️⚠️⚠️
                This is a table of animals that may appear in this area.
                The rarity value of all animals must total 1.0f
                The 'canAttack' value determines whether the animal can attack the player or not.
                    - Chance for the animal to attack the player. For example, if you set it to 10, there will be a 10% chance that the animal will attack the player when they are nearby.
                    - You can set it to `true` for an aggressive mode or `false` for a normal mode.
            ]]
            {
                ["model"] = "a_c_deer",
                ["rarity"] = 0.11,
            },
            {
                ["model"] = "a_c_mtlion",
                ["rarity"] = 0.20,
                ["canAttack"] = 30 -- 30% chance to attack the player
            },
            {
                ["model"] = "a_c_rabbit_01",
                ["rarity"] = 0.10,
            },
            {
                ["model"] = "a_c_pig",
                ["rarity"] = 0.20,
            },
            {
                ["model"] = "a_c_boar",
                ["rarity"] = 0.39,
                ["canAttack"] = 20 -- 20% chance to attack the player
            }
        },
    },
    {
        ["coords"] = vector3(1176.3206, 4575.3989, 116.9845), -- Center coordinates of the hunting zone
        ["radius"] = 80.0,                                    -- Radius of the hunting zone
        ["maxAnimals"] = 38,                                  -- Maximum number of animals that can be present in the zone at any given time
        ["removeAnimal"] = 0.5 * 60 * 1000,                   -- The deletion period for animals that have died but for which no action has been taken. If an animal dies and is not skinned, it will be deleted within this period.
        ["spawnInterval"] = 0.5 * 60 * 1000,                  -- A new animal will spawn every 0.75 minutes.
        ["animal_task_time"] = math.random(8000, 10000),      -- The duration for which an animal will perform a random task (walking, wander, looking around, grazing) before switching to a new one.
        ["blips"] = {
            ["show"] = true,
            ["label"] = "Avcılık Bölgesi",
            ["color"] = 5,
            ["scale"] = 0.7,
            ["sprite"] = 141,
            ["radius"] = {
                ["show"] = true,
                ["color"] = 5,
                ["alpha"] = 80,
            }
        },
        ["animals"] = {
            --[[
                ⚠️⚠️⚠️
                This is a table of animals that may appear in this area.
                The rarity value of all animals must total 1.0f
                The 'canAttack' value determines whether the animal can attack the player or not.
                    - Chance for the animal to attack the player. For example, if you set it to 10, there will be a 10% chance that the animal will attack the player when they are nearby.
                    - You can set it to `true` for an aggressive mode or `false` for a normal mode.
            ]]
            {
                ["model"] = "a_c_deer",
                ["rarity"] = 0.11,
            },
            {
                ["model"] = "a_c_mtlion",
                ["rarity"] = 0.20,
                ["canAttack"] = 30 -- 30% chance to attack the player
            },
            {
                ["model"] = "a_c_rabbit_01",
                ["rarity"] = 0.10,
            },
            {
                ["model"] = "a_c_pig",
                ["rarity"] = 0.20,
            },
            {
                ["model"] = "a_c_boar",
                ["rarity"] = 0.39,
                ["canAttack"] = 20 -- 20% chance to attack the player
            }
        },
    },
    {
        ["coords"] = vector3(-1448.56, 4640.55, 53.09),
        ["radius"] = 80.0,
        ["maxAnimals"] = 31,                            -- Maximum number of animals that can be present in the zone at any given time
        ["removeAnimal"] = 0.5 * 60 * 1000,             -- The deletion period for animals that have died but for which no action has been taken. If an animal dies and is not skinned, it will be deleted within this period.
        ["spawnInterval"] = 0.5 * 60 * 1000,            -- A new animal will spawn every 1 minutes.
        ["animal_task_time"] = math.random(5000, 8000), -- The duration for which an animal will perform a random task (walking, wander, looking around, grazing) before switching to a new one.
        ["blips"] = {
            ["show"] = true,
            ["label"] = "Avcılık Bölgesi",
            ["color"] = 5,
            ["scale"] = 0.7,
            ["sprite"] = 141,
            ["radius"] = {
                ["show"] = true,
                ["color"] = 5,
                ["alpha"] = 80,
            }
        },
        ["animals"] = {
            --[[
                ⚠️⚠️⚠️
                This is a table of animals that may appear in this area.
                The rarity value of all animals must total 1.0f
                The 'canAttack' value determines whether the animal can attack the player or not.
                    - Chance for the animal to attack the player. For example, if you set it to 10, there will be a 10% chance that the animal will attack the player when they are nearby.
                    - You can set it to `true` for an aggressive mode or `false` for a normal mode.
            ]]
            {
                ["model"] = "a_c_deer",
                ["rarity"] = 0.20,
            },
            {
                ["model"] = "a_c_mtlion",
                ["rarity"] = 0.10,
                ["canAttack"] = 30 -- 30% chance to attack the player
            },
            {
                ["model"] = "a_c_rabbit_01",
                ["rarity"] = 0.20,
            },
            {
                ["model"] = "a_c_boar",
                ["rarity"] = 0.50,
                ["canAttack"] = 20 -- 20% chance to attack the player
            }
        },
    },
    {
        ["coords"] = vector3(-1508.0404, 4431.5532, 17.0580),
        ["radius"] = 40.0,
        ["maxAnimals"] = 25,                            -- Maximum number of animals that can be present in the zone at any given time
        ["removeAnimal"] = 0.5 * 60 * 1000,             -- The deletion period for animals that have died but for which no action has been taken. If an animal dies and is not skinned, it will be deleted within this period.
        ["spawnInterval"] = 0.5 * 60 * 1000,            -- A new animal will spawn every 1 minutes.
        ["animal_task_time"] = math.random(5000, 8000), -- The duration for which an animal will perform a random task (walking, wander, looking around, grazing) before switching to a new one.
        ["blips"] = {
            ["show"] = true,
            ["label"] = "Avcılık Bölgesi",
            ["color"] = 5,
            ["scale"] = 0.7,
            ["sprite"] = 141,
            ["radius"] = {
                ["show"] = true,
                ["color"] = 5,
                ["alpha"] = 80,
            }
        },
        ["animals"] = {
            --[[
                ⚠️⚠️⚠️
                This is a table of animals that may appear in this area.
                The rarity value of all animals must total 1.0f
                The 'canAttack' value determines whether the animal can attack the player or not.
                    - Chance for the animal to attack the player. For example, if you set it to 10, there will be a 10% chance that the animal will attack the player when they are nearby.
                    - You can set it to `true` for an aggressive mode or `false` for a normal mode.

                In this area:
                - Deer are somewhat common.
                - Mountain lions are quite rare and have a chance to attack players.
                - Rabbits are somewhat more common.
                - Pigs are quite common.
                - Boars are fairly common and have a chance to attack players.
            ]]
            {
                ["model"] = "a_c_deer",
                ["rarity"] = 0.60,
            },
            {
                ["model"] = "a_c_mtlion",
                ["rarity"] = 0.05,
                ["canAttack"] = 30 -- 30% chance to attack the player
            },
            {
                ["model"] = "a_c_rabbit_01",
                ["rarity"] = 0.05,
            },
            {
                ["model"] = "a_c_boar",
                ["rarity"] = 0.35,
                ["canAttack"] = 20 -- 20% chance to attack the player
            }
        },
    },
    {
        ["coords"] = vector3(4843.5410, -4600.1406, 17.0113), -- Cayo Porto avcılık bölgesi
        ["radius"] = 60.0,                                    -- Yarıçap: 60
        ["maxAnimals"] = 20,                                  -- Hayvan sınırı: 20
        ["removeAnimal"] = 0.5 * 60 * 1000,
        ["spawnInterval"] = 0.15 * 60 * 1000,                 -- Hızlı spawn (her 9 saniyede bir yeni hayvan)
        ["animal_task_time"] = math.random(5000, 8000),
        ["blips"] = {
            ["show"] = true,
            ["label"] = "Avcılık Bölgesi (Cayo Porto)",
            ["color"] = 5,
            ["scale"] = 0.7,
            ["sprite"] = 141,
            ["radius"] = {
                ["show"] = true,
                ["color"] = 5,
                ["alpha"] = 80,
            }
        },
        ["animals"] = {
            {
                ["model"] = "a_c_deer",
                ["rarity"] = 0.35,
            },
            {
                ["model"] = "a_c_mtlion",
                ["rarity"] = 0.10,
                ["canAttack"] = 30 -- %30 saldırma şansı
            },
            {
                ["model"] = "a_c_rabbit_01",
                ["rarity"] = 0.15,
            },
            {
                ["model"] = "a_c_pig",
                ["rarity"] = 0.15,
            },
            {
                ["model"] = "a_c_boar",
                ["rarity"] = 0.25,
                ["canAttack"] = 20 -- %20 saldırma şansı
            }
        },
    },
}

Config.Missions = {
    {
        ["label"] = "Geyik Avı",
        ["image"] =
        "https://user-images.githubusercontent.com/55892717/163342386-b07ff6ee-0316-4f18-a060-727fdc35afed.png",
        ["description"] = "Ormanlık bölgede geyik avla.",
        ["rewards"] = {
            ["money"] = 400,
            ["xp"] = 150,
        },
        ["animal"] = "a_c_deer",
        ["requiredLevel"] = 1,
        ["animalsToKill"] = 5,
    },

    {
        ["label"] = "Tavşan Avı",
        ["image"] =
        "https://static.wikia.nocookie.net/gtawiki/images/8/89/Rabbit-GTAVe.png/revision/latest/scale-to-width-down/1200?cb=20240601214342",
        ["description"] = "Ormanlık bölgede tavşan avla.",
        ["rewards"] = {
            ["money"] = 400,
            ["xp"] = 250,
        },
        ["animal"] = "a_c_rabbit_01",
        ["requiredLevel"] = 1,
        ["animalsToKill"] = 5,
    },

    {
        ["label"] = "Domuz Avı",
        ["image"] = "https://staticg.sportskeeda.com/editor/2025/04/22e45-17435384894625-1920.jpg",
        ["description"] = "Ormanlık bölgede domuz avla.",
        ["rewards"] = {
            ["money"] = 400,
            ["xp"] = 350,
        },
        ["animal"] = "a_c_pig",
        ["requiredLevel"] = 1,
        ["animalsToKill"] = 3,
    },

    {
        ["label"] = "Yaban Domuzu Avı I",
        ["image"] =
        "https://www.creocommunity.com/wp-content/uploads/2024/01/Trouver-des-sangliers-dans-GTA-Online-emplacements-de-chasse-1200x720.jpg",
        ["description"] = "Belirlenmiş bölgede yaban domuzu avla.",
        ["rewards"] = {
            ["money"] = 800,
            ["xp"] = 450,
        },
        ["animal"] = "a_c_boar",
        ["requiredLevel"] = 2,
        ["animalsToKill"] = 8,
    },

    {
        ["label"] = "Dağ Aslanı Avı",
        ["image"] = "https://live.staticflickr.com/3770/19791705723_621cfe2bb0_b.jpg",
        ["description"] = "Ormanlık bölgede dağ aslanı avla.",
        ["rewards"] = {
            ["money"] = 800,
            ["xp"] = 700,
        },
        ["animal"] = "a_c_mtlion",
        ["requiredLevel"] = 2,
        ["animalsToKill"] = 5,
    },

    {
        ["label"] = "Geyik Av I",
        ["image"] =
        "https://user-images.githubusercontent.com/55892717/163342386-b07ff6ee-0316-4f18-a060-727fdc35afed.png",
        ["description"] = "Geyik ve domuz dahil çeşitli hayvanları avla.",
        ["rewards"] = {
            ["money"] = 1200,
            ["xp"] = 900,
        },
        ["animal"] = "a_c_deer",
        ["requiredLevel"] = 3,
        ["animalsToKill"] = 12,
    },

    {
        ["label"] = "Yaban Domuzu Avı II",
        ["image"] =
        "https://www.creocommunity.com/wp-content/uploads/2024/01/Trouver-des-sangliers-dans-GTA-Online-emplacements-de-chasse-1200x720.jpg",
        ["description"] = "Deneyimli avcılar için gelişmiş yaban domuzu av görevi.",
        ["rewards"] = {
            ["money"] = 1600,
            ["xp"] = 1100,
        },
        ["animal"] = "a_c_boar",
        ["requiredLevel"] = 4,
        ["animalsToKill"] = 15,
    },

    {
        ["label"] = "Yırtıcı Avı I",
        ["image"] = "https://live.staticflickr.com/3770/19791705723_621cfe2bb0_b.jpg",
        ["description"] = "Tehlikeli dağ aslanlarını avla. Dikkatli ol!",
        ["rewards"] = {
            ["money"] = 2000,
            ["xp"] = 1400,
        },
        ["animal"] = "a_c_mtlion",
        ["requiredLevel"] = 5,
        ["animalsToKill"] = 8,
    },

    {
        ["label"] = "Usta Geyik Avı",
        ["image"] =
        "https://user-images.githubusercontent.com/55892717/163342386-b07ff6ee-0316-4f18-a060-727fdc35afed.png",
        ["description"] = "Uzman seviyesinde geyik av görevi.",
        ["rewards"] = {
            ["money"] = 2400,
            ["xp"] = 1700,
        },
        ["animal"] = "a_c_deer",
        ["requiredLevel"] = 6,
        ["animalsToKill"] = 20,
    },

    {
        ["label"] = "Domuz Avı II",
        ["image"] = "https://staticg.sportskeeda.com/editor/2025/04/22e45-17435384894625-1920.jpg",
        ["description"] = "Farklı bölgelerde çeşitli hayvanları avla.",
        ["rewards"] = {
            ["money"] = 2800,
            ["xp"] = 2100,
        },
        ["animal"] = "a_c_pig",
        ["requiredLevel"] = 7,
        ["animalsToKill"] = 25,
    },

    {
        ["label"] = "Yırtıcı Avı II",
        ["image"] = "https://live.staticflickr.com/3770/19791705723_621cfe2bb0_b.jpg",
        ["description"] = "Birden fazla tehlikeli yırtıcıyı avla.",
        ["rewards"] = {
            ["money"] = 3200,
            ["xp"] = 2500,
        },
        ["animal"] = "a_c_mtlion",
        ["requiredLevel"] = 8,
        ["animalsToKill"] = 12,
    },

    {
        ["label"] = "Usta Avcı Mücadelesi",
        ["image"] =
        "https://www.creocommunity.com/wp-content/uploads/2024/01/Trouver-des-sangliers-dans-GTA-Online-emplacements-de-chasse-1200x720.jpg",
        ["description"] = "Usta avcılar için en zor av görevi.",
        ["rewards"] = {
            ["money"] = 3600,
            ["xp"] = 3000,
        },
        ["animal"] = "a_c_boar",
        ["requiredLevel"] = 9,
        ["animalsToKill"] = 30,
    },

    {
        ["label"] = "Efsanevi Av",
        ["image"] = "https://live.staticflickr.com/3770/19791705723_621cfe2bb0_b.jpg",
        ["description"] = "Sadece en yetenekli avcıların tamamlayabileceği efsanevi görev.",
        ["rewards"] = {
            ["money"] = 4000,
            ["xp"] = 4000,
        },
        ["animal"] = "a_c_mtlion",
        ["requiredLevel"] = 10,
        ["animalsToKill"] = 20,
    },
}

Config.Rewards = {
    --[[
        ⚠️⚠️⚠️
        Rewards for each animal type.
        The 'xp' value indicates the experience points awarded for hunting the animal.
        The 'items' table lists the items and their amount that players receive upon successfully hunting the animal.
        ⚠️⚠️⚠️
    ]]

    [joaat("a_c_boar")] = {
        ["xp"] = 3,
        ["items"] = {
            { name = "boar_meat", amount = 2 },
            { name = "boar_skin", amount = 1 },
            { name = "boar_tusk", amount = 2 },
        }
    },
    [joaat("a_c_pig")] = {
        ["xp"] = 2,
        ["items"] = {
            { name = "pig_meat", amount = 3 },
            { name = "pig_skin", amount = 1 },
            { name = "pig_feet", amount = 4 },
        }
    },
    [joaat("a_c_rabbit_01")] = {
        ["xp"] = 1,
        ["items"] = {
            { name = "rabbit_meat", amount = 2 },
            { name = "rabbit_skin", amount = 1 },
            { name = "rabbit_feet", amount = 4 },
        }
    },
    [joaat("a_c_mtlion")] = {
        ["xp"] = 30,
        ["items"] = {
            { name = "mtlion_meat", amount = 1 },
            { name = "mtlion_skin", amount = 2 },
        }
    },
    [joaat("a_c_deer")] = {
        ["xp"] = 5,
        ["items"] = {
            { name = "deer_meat",  amount = 1 },
            { name = "deer_skin",  amount = 2 },
            { name = "deer_horns", amount = 2 },
        }
    },
}

Config.AnimalPartsPrices = {
    --[[
        ⚠️⚠️⚠️
        Selling prices for each item obtained from hunting.
        The key represents the item name, and the value represents the selling price.
        ⚠️⚠️⚠️
    ]]

    -- ["boar_meat"] = 50,
    -- ["boar_skin"] = 80,
    -- ["boar_tusk"] = 30,
    -- ["pig_meat"] = 40,
    -- ["pig_skin"] = 70,
    -- ["pig_feet"] = 20,
    -- ["rabbit_meat"] = 20,
    -- ["rabbit_skin"] = 40,
    -- ["rabbit_feet"] = 10,
    -- ["mtlion_meat"] = 200,
    -- ["mtlion_skin"] = 300,
    -- ["deer_meat"] = 60,
    -- ["deer_skin"] = 100,
    -- ["deer_horns"] = 40,
    ["boar_meat"] = 10,
    ["boar_skin"] = 16,
    ["boar_tusk"] = 6,
    ["pig_meat"] = 8,
    ["pig_skin"] = 14,
    ["pig_feet"] = 4,
    ["rabbit_meat"] = 4,
    ["rabbit_skin"] = 8,
    ["rabbit_feet"] = 2,
    ["mtlion_meat"] = 40,
    ["mtlion_skin"] = 60,
    ["deer_meat"] = 12,
    ["deer_skin"] = 20,
    ["deer_horns"] = 8,
}

Config.Levels = {
    --[[
        ⚠️⚠️⚠️
        Experience points required for each level and the corresponding multiplier.
        The multiplier increases the rewards players receive while hunting.
        For example, at level 2 with a multiplier of 0.15, players will receive 15% more rewards.
        ⚠️⚠️⚠️
    ]]
    ["default"] = {
        --[[
            Default level and experience points for new players.
        ]]
        ["xp"] = 0,
        ["level"] = 1,
    },
    ["levels"] = {
        --[[
            Level progression table.
            You can create a new level by copying and pasting.
        ]]
        { ["xp"] = 0,     ["level"] = 1,  ["multiplier"] = 0.05, },
        { ["xp"] = 1000,  ["level"] = 2,  ["multiplier"] = 0.15, },
        { ["xp"] = 3000,  ["level"] = 3,  ["multiplier"] = 0.17, },
        { ["xp"] = 6000,  ["level"] = 4,  ["multiplier"] = 0.20, },
        { ["xp"] = 10000, ["level"] = 5,  ["multiplier"] = 0.15, },
        { ["xp"] = 15000, ["level"] = 6,  ["multiplier"] = 0.27, },
        { ["xp"] = 21000, ["level"] = 7,  ["multiplier"] = 0.30, },
        { ["xp"] = 28000, ["level"] = 8,  ["multiplier"] = 0.35, },
        { ["xp"] = 36000, ["level"] = 9,  ["multiplier"] = 0.37, },
        { ["xp"] = 45000, ["level"] = 10, ["multiplier"] = 0.40, },
    }
}

Config.Commands = {
    ["exit"] = {
        ["command"] = "exitgroup",                      -- Av grubundan ayrılma komutu.
        ["description"] = "Mevcut av grubundan ayrıl.", -- Komut açıklaması.
        ["permission"] = nil                            -- group.admin veya nil
    },
    ["givexp"] = {
        ["command"] = "givehuntxp",                                  -- Bir oyuncuya avlanma deneyim puanı verme komutu.
        ["description"] = "Bir oyuncuya avlanma deneyim puanı ver.", -- Komut açıklaması.
        ["permission"] = "group.admin"                               -- group.admin veya nil
    },
    ["setxp"] = {
        ["command"] = "sethuntxp",                                         -- Bir oyuncunun avlanma deneyim puanını ayarlama komutu.
        ["description"] = "Bir oyuncunun avlanma deneyim puanını ayarla.", -- Komut açıklaması.
        ["permission"] = "group.admin"                                     -- group.admin veya nil
    },
    ["setlevel"] = {
        ["command"] = "sethuntlevel",                                 -- Bir oyuncunun avlanma seviyesini ayarlama komutu.
        ["description"] = "Bir oyuncunun avlanma seviyesini ayarla.", -- Komut açıklaması.
        ["permission"] = "group.admin"                                -- group.admin veya nil
    },
}

Config.StepperWidget = {
    --[[
        These are the settings for the small widget that appears on the left side when the Job is started.
    ]]
    ["show"] = true,     -- If you set it to `false`, progress for the task will not be visible and the system will not display what the user needs to do.
    ["keys"] = {
        ["label"] = "B", -- Represents the button character that will appear in the widget.
        ["key"] = "B",   -- It is a key that can be enlarged or reduced by pressing it on the keyboard. https://docs.fivem.net/docs/game-references/controls/
    }
}

Config.AnimalBlips = {
    ["enable"] = true, -- If you set it to `true`, the killed animal will have a blip on the map for easier location. If you set it to `false`, no blip will be shown.
    ["blips"] = {
        --[[
            Blip settings for killed animals.
            You can find the blips and their colors at this address => https://docs.fivem.net/docs/game-references/blips
        ]]
        ["sprite"] = 141,
        ["color"] = 36,
        ["scale"] = 0.8,
        ["label"] = "Hayvan",
    }
}

Config.InviteControllers = {
    --[[
        ⌨️⌨️⌨️
        When a player is invited to a group, the controls for the invite box that appears below are as follows.
        The labels for the accept and decline buttons are visible in the invite box, i.e., NUI. The key is functionally the key type that Fivem will recognize.
        https://docs.fivem.net/docs/game-references/controls/
    ]]

    ["accept"] = {
        ["label"] = "Y", -- It will appear on the NUI side, next to the Accept button.
        ["key"] = "Y",   -- It is a functional key that will work on the Fivem side.
    },
    ["decline"] = {
        ["label"] = "ESC",  -- It will appear on the NUI side, next to the Decline button.
        ["key"] = "Escape", -- It is a functional key that will work on the Fivem side.
    }
}

Config.Debug = function(...)
    if Config.ShowDebug then
        print(...)
    end
end

Config.VehicleAction = function(vehicle, netId, plate, removed)
    --[[
        vehicle : Vehicle entity
        plate   : Vehicle plate
        netId   : Vehicle network id
        removed : If the vehicle is being removed, set to true. Otherwise, set to false.
    ]]

    if removed then
        if GetResourceState("qs-vehiclekeys"):find("start") then
            exports['qs-vehiclekeys']:RemoveKeys(plate, Config.Vehicle.model)
        elseif GetResourceState("qb-vehiclekeys"):find("start") then
            TriggerEvent('qb-vehiclekeys:client:RemoveKeys', plate)
        end

        return
    end

    if GetResourceState("qs-vehiclekeys"):find("start") then
        exports['qs-vehiclekeys']:GiveKeys(plate, GetDisplayNameFromVehicleModel(Config.Vehicle.model, true))
    else
        TriggerEvent('vehiclekeys:client:SetOwner', plate)
    end

    if GetResourceState('LegacyFuel'):find("start") then
        exports["LegacyFuel"]:SetFuel(vehicle, 100)
    elseif GetResourceState('ox_fuel'):find("start") then
        Entity(vehicle).state.fuel = 100
    elseif GetResourceState('okokGasStation'):find("start") then
        exports['okokGasStation']:SetFuel(vehicle, 100)
    elseif GetResourceState("cdn-fuel"):find("start") then
        exports["cdn-fuel"]:SetFuel(vehicle, 100)
    elseif GetResourceState("savana-fuel"):find("start") then
        exports["savana-fuel"]:SetFuel(vehicle, 100)
    end
end

Config.Notification = function(title, text, type, time)
    title = title or "Avcılık İşi"
    time = time or 5000

    if GetResourceState("okokNotify"):find("start") then
        exports['okokNotify']:Alert(title, text, time, type, true)
    elseif lib ~= nil then
        lib.notify({
            title = title,
            type = type,
            duration = time,
            description = text,
            iconAnimation = "beatFade",
            position = "center-top"
        })
    end
end
