return {
    DebugPoly           = false,
    Freedom             = vec4(1850.68, 2585.69, 45.67, 268.47), -- Freedom spawn coords
    RemoveJob           = true,                                  -- Remove player jobs when send to jail

    -- Create Target Zone to Check Time (if XTPrisonJobs is false) --
    CheckOut            = {
        coords = vec4(1752.01, 2480.46, 45.74, 302.2),
        size = vec3(0.9, 7.8, 1.45),
        rotation = 0.5,
        -- Optional ped config for the checkout interaction
        model = 's_m_m_security_01',
        scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
    },

    -- Alert When Entering Prison --
    EnterPrisonAlert    = {
        enable = true,
        header = 'Cezaevine Hoş Geldin, Suçlu!',
        content =
        'Cezaevindeki sürenizi azaltmak için avludaki elektrik panolarını onarabilir, bahçe temizliği yapabilir veya mutfakta çalışabilirsiniz. Süreniz bittiğinde gardiyandan tahliye olabilirsiniz.',
    },

    -- Enter Prison Spawn Location & Emotes --
    Spawns              = {
        { coords = vec4(1770.7249755859, 2479.9802246094, 45.74076461792, 31.66007232666),   emote = 'pushup' },
        { coords = vec4(1761.0710449219, 2474.9235839844, 49.693054199219, 33.123195648193), emote = 'pushup' },
        { coords = vec4(1745.0281982422, 2479.2116699219, 45.740684509277, 323.06579589844), emote = 'weights' },
        { coords = vec4(1768.1342773438, 2481.6772460938, 45.740734100342, 33.281074523926), emote = 'lean' },
    },

    -- Canteen Ped --
    -- CanteenPed = {
    --     model = 's_m_m_linecook',
    --     coords = vector4(1778.31, 2560.56, 45.62, 181.13),
    --     scenario = 'PROP_HUMAN_BBQ',
    --     mealLength = 2
    -- },

    -- Prison Doctor --
    PrisonDoctor        = {
        model = 's_m_m_doctor_01',
        coords = vec4(1753.76, 2477.42, 45.74, 300.76),
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        healLength = 5
    },

    -- Roster Location --
    RosterLocation      = {
        coords = vec3(1837.45, 2592.95, 45.85),
        radius = 0.3,
    },

    -- Set Prison Outfits --
    EnablePrisonOutfits = true,
    PrisonOufits        = {
        male = {
            accessories = {
                item = 0,
                texture = 0
            },
            mask = {
                item = 0,
                texture = 0
            },
            pants = {
                item = 57,
                texture = 0
            },
            jacket = {
                item = 909,
                texture = 0
            },
            shirt = {
                item = 0,
                texture = 0
            },
            arms = {
                item = 15,
                texture = 0
            },
            shoes = {
                item = 97,
                texture = 0
            },
            bodyArmor = {
                item = 0,
                texture = 0
            },
            bag = {
                item = 0,
                texture = 0
            },
            decals = {
                item = 0,
                texture = 0
            },
        },
        female = {
            accessories = {
                item = 0,
                texture = 0
            },
            mask = {
                item = 0,
                texture = 0
            },
            pants = {
                item = 423,
                texture = 0
            },
            jacket = {
                item = 510,
                texture = 0
            },
            shirt = {
                item = 0,
                texture = 0
            },
            arms = {
                item = 0,
                texture = 0
            },
            shoes = {
                item = 465,
                texture = 0
            },
            bodyArmor = {
                item = 0,
                texture = 0
            },
            bag = {
                item = 0,
                texture = 0
            },
            decals = {
                item = 0,
                texture = 0
            },
        }
    },

    -- Reloads Player's Last Skin When Freed --
    ResetClothing       = function()
        TriggerEvent('illenium-appearance:client:reloadSkin', true)
    end,

    -- Triggered on Player Heal --
    PlayerHealed        = function()
        TriggerEvent('qbx_medical:client:playerRevived')
    end,

    -- Trigger Emote --
    Emote               = function(emote)
        -- exports.scully_emotemenu:playEmoteByCommand(emote)
        -- exports["rpemotes"]:EmoteCommandStart(emote)
    end,

    Dispatch            = function(coords)
        exports.daddy_dispatch:Raise("prison_break", {
            title = "Hapishane İhlali",
            coords = coords, -- vec3 gönderilirse onu kullanır, nil ise oyuncu konumu
            to = { "police", "bcso", "sasp", "pbsd", "cppd", "sapr" },
            fields = {
                { icon = "lock", text = "Konum: Boilingbroke Cezaevi" },
                { icon = "info", text = "Tehdit: Yüksek" },
            }
        })
    end
}
