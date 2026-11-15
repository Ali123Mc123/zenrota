Config = {}

Config.Debug = false

Config.ClothingCost = 100
Config.BarberCost = 100
Config.TattooCost = 100
Config.SurgeonCost = 100

Config.ChargePerTattoo = false -- Charge players per tattoo. Config.TattooCost will become the cost of 1 tattoo. The cost can be overridden by adding `cost` key in shared/tattoos.lua for specific tattoos

-- Only set this to true if you're using rcore_tattoos
Config.RCoreTattoosCompatibility = true

Config.AsynchronousLoading = false -- Change this to false if you want the NUI data to load before displaying the appearance UI

Config.UseTarget = false

Config.TextUIOptions = {
    position = "left-center"
}

Config.NotifyOptions = {
    position = "top-center"
}

Config.OutfitCodeLength = 10

Config.UseRadialMenu = false
Config.UseOxRadial = false -- Set to true to use ox_lib radial menu, both this and UseRadialMenu must be true

Config.EnablePedsForShops = true
Config.EnablePedsForClothingRooms = true
Config.EnablePedsForPlayerOutfitRooms = true

Config.EnablePedMenu = true
Config.PedMenuGroup = "group.admin"
-- GEÇİCİ: true iken /skin herkese açık (oyuncu sadece kendine açar; başkasına /skin <id> yine sadece admin). Kapatmak için false.
Config.PedMenuPublic = true

Config.EnableJobOutfitsCommand = false -- Enables /joboutfits and /gangoutfits commands

Config.ShowNearestShopOnly = false
Config.HideRadar = false -- Hides the minimap while the appearance menu is open

Config.Locale = "tr" -- language of menus and the editor; nil = the illenium-appearance:locale convar

Config.Editor = {
    Accent = "#c8102e", -- main colour; players can pick their own in the editor settings
    -- item pictures: the photo studio's (see Config.PhotoStudio) on GitHub Pages, put there by publish-pictures.mjs;
    -- {gender} {folder} {slot} {idx} {tex} are filled in; false = numbers only
    Pictures = "https://lkrypton.github.io/daddyrp-clothing-pictures/{gender}/{folder}/{slot}_{idx}_t{tex}_a000.webp",
}

-- Photo studio (admins): a tight, transparent picture of every clothing item and colourway for the editor, stored in
-- pictures/ (server/pictures.js, see PHOTOSTUDIO.md). The ped wears an empty head this resource streams (stream/, data/).
Config.PhotoStudio = {
    Command = "photostudio", -- /photostudio run | stop | status | list | redo
    Group = "group.admin", -- who may use it
    Size = 256, -- picture width and height in pixels
    Format = "webp", -- "webp" or "png"
    Quality = 0.92, -- webp quality, 0-1
    Fill = 0.86, -- how much of the camera view the item fills before the picture is trimmed to it
    Pad = 0.06, -- empty margin around the item, part of the picture size
    Light = 1.2, -- soft front light, 0 = off
    Place = vec3(-1025.34, -3031.0, 13.94), -- a quiet spot (LSIA); the set floats Lift metres above it
    Lift = 15.0,
}
Config.NearestShopBlipUpdateDelay = 10000

Config.InvincibleDuringCustomization = true

Config.PreventTrackerRemoval = true -- Disables "Scarf and Chains" section if the player has tracker
Config.TrackerClothingOptions = {
    drawable = 13,
    texture = 0
}

Config.NewCharacterSections = {
    Ped = true,
    HeadBlend = true,
    FaceFeatures = true,
    HeadOverlays = true,
    Components = true,
    Props = true,
    Tattoos = false
}

Config.GenderBasedOnPed = true

Config.AlwaysKeepProps = false

Config.PersistUniforms = false         -- Keeps Job / Gang Outfits on player reconnects / logout
Config.OnDutyOnlyClothingRooms = false -- Set to `true` to make the clothing rooms accessible only to players who are On Duty

Config.BossManagedOutfits = false      -- Allows Job / Gang bosses to manage their own job / gang outfits

Config.ReloadSkinCooldown = 5000

Config.AutomaticFade = false -- Enables automatic fading and hides the Fade section from Hair

-- Kıyafet çıkarma butonları için sentinel değerleri
-- Sentinel = o kıyafet çıkarılmış sayılan drawable ID
-- Oyunda kıyafeti elle çıkardığında gelen numarayı buraya yaz
Config.ClothingToggles = {
    male = {
        jacketSentinel     = 0,  -- Erkek, ceket yok (component_id 11)
        undershirtSentinel = 0,  -- Erkek, gömlek/undershirt yok (component_id 8)
        torsoSentinel      = 0,  -- Erkek, eller/torso yok (component_id 3)
        lowerSentinel      = 0,  -- Erkek, pantolon yok (component_id 4)
        shoesSentinel      = 0,  -- Erkek, ayakkabı yok (component_id 6)
        hatSentinel        = -1, -- Şapka yok (prop_id 0, -1 = çıkarılmış)
        maskSentinel       = 0,  -- Erkek, maske yok (component_id 1)
        glassesSentinel    = 0,  -- Maske çıkartıldığında gözlük de çıkar (prop_id 1); kaldırmak için nil yap
    },
    female = {
        jacketSentinel     = 0,  -- Kadın, ceket yok (component_id 11)
        undershirtSentinel = 0,  -- Kadın, gömlek/undershirt yok (component_id 8)
        torsoSentinel      = 0,  -- Kadın, eller/torso yok (component_id 3)
        lowerSentinel      = 0,  -- Kadın, pantolon yok (component_id 4)
        shoesSentinel      = 0,  -- Kadın, ayakkabı yok (component_id 6)
        hatSentinel        = -1, -- Şapka yok (prop_id 0, -1 = çıkarılmış)
        maskSentinel       = 0,  -- Kadın, maske yok (component_id 1)
        glassesSentinel    = 0,  -- Maske çıkartıldığında gözlük de çıkar (prop_id 1); kaldırmak için nil yap
    },
}

Config.DisableComponents = {
    Masks = false,
    UpperBody = false,
    LowerBody = false,
    Bags = false,
    Shoes = false,
    ScarfAndChains = false,
    BodyArmor = false,
    Shirts = false,
    Decals = false,
    Jackets = false
}

Config.DisableProps = {
    Hats = false,
    Glasses = false,
    Ear = false,
    Watches = false,
    Bracelets = false
}

Config.DisableHeadOverlays = {
    blemishes = false,
    beard = false,
    eyebrows = false,
    ageing = false,
    makeUp = false,
    blush = false,
    complexion = false,
    sunDamage = false,
    lipstick = false,
    moleAndFreckles = false,
    chestHair = true,
    bodyBlemishes = false
}

Config.SpecificPropsToClear = {
    'v_res_fa_bread01',
    'prop_fishing_rod_01',
    'prop_fishing_rod_02',
    'prop_fishing_net_01',
    'prop_coral_01',
    'prop_coral_02',
    'prop_coral_03',
    'p_michael_backpack_s',
    'p_michael_backpack_s',
    'bv_bumper_closed',
    'bv_bumper_a',
    'bv_bumper_b',
    'bv_frame_a',
    'bv_frame_b',
    'bv_wheelblock',
}

---@type string[]
Config.Aces = {} -- list of ace permissions used for blacklisting

Config.Blips = {
    ["clothing"] = {
        Show = true,
        Sprite = 366,
        Color = 47,
        Scale = 0.7,
        Name = "Kıyafet Mağazası",
    },
    ["barber"] = {
        Show = true,
        Sprite = 71,
        Color = 0,
        Scale = 0.7,
        Name = "Berber",
    },
    ["tattoo"] = {
        Show = true,
        Sprite = 75,
        Color = 4,
        Scale = 0.7,
        Name = "Dövme Stüdyosu",
    },
    ["surgeon"] = {
        Show = true,
        Sprite = 102,
        Color = 4,
        Scale = 0.7,
        Name = "Plastik Cerrah",
    }
}

Config.TargetConfig = {
    ["clothing"] = {
        model = "s_f_m_shop_high",
        scenario = "WORLD_HUMAN_STAND_MOBILE",
        icon = "fas fa-tshirt",
        label = "Kıyafet Mağazasını Aç",
        distance = 3
    },
    ["barber"] = {
        model = "s_m_m_hairdress_01",
        scenario = "WORLD_HUMAN_STAND_MOBILE",
        icon = "fas fa-scissors",
        label = "Berberi Aç",
        distance = 3
    },
    -- ["tattoo"] = {
    --     model = "u_m_y_tattoo_01",
    --     scenario = "WORLD_HUMAN_STAND_MOBILE",
    --     icon = "fas fa-pen",
    --     label = "Open Tattoo Shop",
    --     distance = 3
    -- },
    ["surgeon"] = {
        model = "s_m_m_doctor_01",
        scenario = "WORLD_HUMAN_STAND_MOBILE",
        icon = "fas fa-scalpel",
        label = "Cerrahı Aç",
        distance = 3
    },
    ["clothingroom"] = {
        model = "mp_g_m_pros_01",
        scenario = "WORLD_HUMAN_STAND_MOBILE",
        icon = "fas fa-sign-in-alt",
        label = "İş / Çete Kıyafet Menüsünü Aç",
        distance = 3
    },
    ["playeroutfitroom"] = {
        model = "mp_g_m_pros_01",
        scenario = "WORLD_HUMAN_STAND_MOBILE",
        icon = "fas fa-sign-in-alt",
        label = "Kıyafet Menüsünü Aç",
        distance = 3
    },
}

Config.Stores = {
    {
        type = "clothing",
        coords = vector4(1693.2, 4828.11, 42.07, 188.66),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false, -- false => uses the size + rotation to create the zone | true => uses points to create the zone
        showBlip = true, -- overrides the blip visibilty configured above for the group
        --targetModel = "s_m_m_doctor_01", -- overrides the target ped configured for the group
        --targetScenario = "" -- overrides the target scenario configure for the group
        points = {
            vector3(1686.9018554688, 4829.8330078125, 42.07),
            vector3(1698.8566894531, 4831.4604492188, 42.07),
            vector3(1700.2448730469, 4817.7734375, 42.07),
            vector3(1688.3682861328, 4816.2954101562, 42.07)
        }
    },
    {
        type = "clothing",
        coords = vector4(-705.5, -149.22, 37.42, 122),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-719.86212158203, -147.83151245117, 37.42),
            vector3(-709.10491943359, -141.53076171875, 37.42),
            vector3(-699.94342041016, -157.44494628906, 37.42),
            vector3(-710.68774414062, -163.64665222168, 37.42)
        }
    },
    {
        type = "clothing",
        coords = vector4(-1192.61, -768.4, 17.32, 216.6),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-1206.9552001953, -775.06304931641, 17.32),
            vector3(-1190.6080322266, -764.03198242188, 17.32),
            vector3(-1184.5672607422, -772.16949462891, 17.32),
            vector3(-1199.24609375, -783.07928466797, 17.32)
        }
    },
    {
        type = "clothing",
        coords = vector4(425.91, -801.03, 29.49, 177.79),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(419.55020141602, -798.36547851562, 29.49),
            vector3(431.61773681641, -798.31909179688, 29.49),
            vector3(431.19784545898, -812.07122802734, 29.49),
            vector3(419.140625, -812.03594970703, 29.49)
        }
    },
    {
        type = "clothing",
        coords = vector4(-168.73, -301.41, 39.73, 238.67),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-160.82145690918, -313.85919189453, 39.73),
            vector3(-172.56513977051, -309.82858276367, 39.73),
            vector3(-166.5775604248, -292.48077392578, 39.73),
            vector3(-154.84906005859, -296.51647949219, 39.73)
        }
    },
    {
        type = "clothing",
        coords = vector4(75.39, -1398.28, 29.38, 6.73),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(81.406135559082, -1400.7791748047, 29.38),
            vector3(69.335029602051, -1400.8251953125, 29.38),
            vector3(69.754981994629, -1387.078125, 29.38),
            vector3(81.500122070312, -1387.3002929688, 29.38)
        }
    },
    {
        type = "clothing",
        coords = vector4(-827.39, -1075.93, 11.33, 294.31),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-826.26251220703, -1082.6293945312, 11.33),
            vector3(-832.27856445312, -1072.2819824219, 11.33),
            vector3(-820.16442871094, -1065.7727050781, 11.33),
            vector3(-814.08953857422, -1076.1878662109, 11.33)
        }
    },
    {
        type = "clothing",
        coords = vector4(-1445.86, -240.78, 49.82, 36.17),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-1448.4829101562, -226.39401245117, 49.82),
            vector3(-1439.2475585938, -234.70428466797, 49.82),
            vector3(-1451.5389404297, -248.33193969727, 49.82),
            vector3(-1460.7554931641, -240.02815246582, 49.82)
        }
    },
    {
        type = "clothing",
        coords = vector4(9.22, 6515.74, 31.88, 131.27),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(6.4955291748047, 6522.205078125, 31.88),
            vector3(14.737417221069, 6513.3872070312, 31.88),
            vector3(4.3691010475159, 6504.3452148438, 31.88),
            vector3(-3.5187695026398, 6513.1538085938, 31.88)
        }
    },
    -- {
    --     type = "clothing",
    --     coords = vector4(615.35, 2762.72, 42.09, 170.51),
    --     size = vector3(4, 4, 4),
    --     rotation = 45,
    --     usePoly = false,
    --     points = {
    --         vector3(612.58312988281, 2747.2814941406, 42.09),
    --         vector3(612.26214599609, 2767.0520019531, 42.09),
    --         vector3(622.37548828125, 2767.7614746094, 42.09),
    --         vector3(623.66833496094, 2749.5180664062, 42.09)
    --     }
    -- },
    {
        type = "clothing",
        coords = vector4(1191.61, 2710.91, 38.22, 269.96),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(1188.7923583984, 2704.2021484375, 38.22),
            vector3(1188.7498779297, 2716.2661132812, 38.22),
            vector3(1202.4979248047, 2715.8479003906, 38.22),
            vector3(1202.3558349609, 2703.9294433594, 38.22)
        }
    },
    {
        type = "clothing",
        coords = vector4(-3171.32, 1043.56, 20.86, 334.3),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-3162.0075683594, 1056.7303466797, 20.86),
            vector3(-3170.8247070312, 1039.0412597656, 20.86),
            vector3(-3180.0979003906, 1043.1201171875, 20.86),
            vector3(-3172.7292480469, 1059.8623046875, 20.86)
        }
    },
    {
        type = "clothing",
        coords = vector4(-1105.52, 2707.79, 19.11, 317.19),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-1103.3004150391, 2700.8195800781, 19.11),
            vector3(-1111.3771972656, 2709.884765625, 19.11),
            vector3(-1100.8548583984, 2718.638671875, 19.11),
            vector3(-1093.1976318359, 2709.7365722656, 19.11)
        }
    },
    {
        type = "clothing",
        coords = vector4(124.82, -224.36, 54.56, 335.41),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(133.60948181152, -210.31390380859, 54.56),
            vector3(125.8349609375, -228.48097229004, 54.56),
            vector3(116.3140335083, -225.02020263672, 54.56),
            vector3(122.56930541992, -207.83396911621, 54.56)
        }
    },
    -- Berber #1 (barber_14, Rockford Hills -814.22, -183.7) kaldırıldı: ihale ve hizmet yok. Sonraki mağazalar eski id'lerini businessId ile korur.
    {
        type = "barber",
        businessId = "barber_15", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vector4(136.78, -1708.4, 29.29, 144.19),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(132.57008361816, -1710.5053710938, 29.29),
            vector3(138.77899169922, -1702.6778564453, 29.29),
            vector3(142.73052978516, -1705.6853027344, 29.29),
            vector3(135.49719238281, -1712.9750976562, 29.29)
        }
    },
    {
        type = "barber",
        businessId = "barber_16", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vector4(-1282.57, -1116.84, 6.99, 89.25),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-1287.4735107422, -1115.4364013672, 6.99),
            vector3(-1277.5638427734, -1115.1229248047, 6.99),
            vector3(-1277.2469482422, -1120.1147460938, 6.99),
            vector3(-1287.4561767578, -1119.2506103516, 6.99)
        }
    },
    {
        type = "barber",
        businessId = "barber_17", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vector4(1931.41, 3729.73, 32.84, 212.08),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(1932.4931640625, 3725.3374023438, 32.84),
            vector3(1927.2720947266, 3733.7663574219, 32.84),
            vector3(1931.4379882812, 3736.5327148438, 32.84),
            vector3(1936.0697021484, 3727.2839355469, 32.84)
        }
    },
    {
        type = "barber",
        businessId = "barber_18", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vector4(1212.8, -472.9, 65.2, 60.94),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(1208.3327636719, -469.84338378906, 65.2),
            vector3(1217.9066162109, -472.40216064453, 65.2),
            vector3(1216.9870605469, -477.00939941406, 65.2),
            vector3(1206.1077880859, -473.83499145508, 65.2)
        }
    },
    {
        type = "barber",
        businessId = "barber_19", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vector4(-32.9, -152.3, 56.1, 335.22),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-29.730783462524, -148.67495727539, 56.1),
            vector3(-32.919719696045, -158.04254150391, 56.1),
            vector3(-37.612594604492, -156.62759399414, 56.1),
            vector3(-33.30192565918, -147.31649780273, 56.1)
        }
    },
    {
        type = "barber",
        businessId = "barber_20", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vector4(-278.1, 6228.5, 30.7, 49.32),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-280.29818725586, 6232.7265625, 30.7),
            vector3(-273.06427001953, 6225.9692382812, 30.7),
            vector3(-276.25280761719, 6222.4013671875, 30.7),
            vector3(-282.98211669922, 6230.015625, 30.7)
        }
    },
    -- { -- Alta PD (eski)
    --     type = "clothing",
    --     coords = vector4(103.1598, -335.2025, 45.0704, 156.8063),
    --     size = vector3(4, 4, 4),
    --     rotation = 45,
    --     usePoly = false,
    --     showBlip = false,
    --     auction = false,
    --     points = {
    --         vec3(103.1598, -335.2025, 45.0704),
    --         vec3(98.6943, -333.5850, 45.0631),
    --     }
    -- },
    { -- MRPD kıyafet
        type = "clothing",
        businessId = "clothing_21", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vector4(461.2511, -997.3065, 31.1337, 176.2444),
        size = vector3(4, 4, 4),
        rotation = 176.2444,
        usePoly = false,
        showBlip = false,
        auction = false,
        points = {
            vec3(463.2511, -995.3065, 31.1337),
            vec3(459.2511, -995.3065, 31.1337),
            vec3(459.2511, -999.3065, 31.1337),
            vec3(463.2511, -999.3065, 31.1337),
        }
    },
    { -- SASP
        type = "clothing",
        businessId = "clothing_22", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vec4(-3157.05, 1370.29, 20.85, 45.34),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        showBlip = false,
        auction = false,
        points = {
            vec3(-3156.26, 1369.59, 20.85),
            vec3(-3158.29, 1371.62, 20.85)
        }
    },
    { -- BCSO
        type = "clothing",
        businessId = "clothing_23", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vec4(1829.28, 3675.85, 34.71, 332.64),
        size = vector3(5, 5, 5),
        rotation = 45,
        usePoly = false,
        showBlip = false,
        auction = false,
        points = {
            vec3(1829.28, 3675.85, 34.71),
            vec3(1827.47, 3680.34, 34.71),
        }
    },
    { -- SAPR, Alta PD soyunma odası (prev Park Ranger: vec4(386.4240, 793.5951, 190.4835, 359.2847); old: vec4(-829.32, 5388.54, 35.87, 13.35))
        type = "clothing",
        businessId = "clothing_24", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vec4(103.1598, -335.2025, 45.0704, 156.8063),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        showBlip = false,
        auction = false,
        points = {
            vec3(103.1598, -335.2025, 45.0704),
            vec3(98.6943, -333.5850, 45.0631),
        }
    },
    { -- PBSD
        type = "clothing",
        businessId = "clothing_25", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vector4(2813.1992, 4730.1602, 47.8923, 286.0446),
        size = vector3(5, 5, 5),
        rotation = 45,
        usePoly = false,
        showBlip = false,
        auction = false,
        points = {
            vec3(2813.1992, 4730.1602, 47.8923),
        }
    },
    { -- EMS
        type = "clothing",
        businessId = "clothing_26", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vec4(1138.46, -1540.67, 35.03, 272.98),
        size = vector3(5, 5, 5),
        rotation = 45,
        usePoly = false,
        showBlip = false,
        auction = false,
        points = {
            vec3(1138.46, -1540.67, 35.03),
            vec3(1138.2, -1538.55, 35.03),
        }
    },
    { -- EMS orta kasaba
        type = "clothing",
        businessId = "clothing_27", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vector4(640.2562, 2770.1780, 43.5551, 93.1598),
        size = vector3(5, 5, 5),
        rotation = 45,
        usePoly = false,
        showBlip = false,
        auction = false,
        points = {
            vector3(640.2562, 2770.1780, 43.5551),
            vector3(636.0869, 2769.7793, 43.5551),
        }
    },
    { -- DP
        type = "clothing",
        businessId = "clothing_28", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vector4(-439.0855, 6011.1401, 36.9957, 137.7547),
        size = vector3(6, 6, 6),
        rotation = 45,
        usePoly = false,
        showBlip = false,
        auction = false,
        points = {
            vector3(-439.0855, 6011.1401, 36.9957),
        }
    },
    { -- Yeni Okul Kıyafet 1
        type = "clothing",
        businessId = "clothing_29", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vector4(5316.5460, -5290.3290, 16.6160, 55.2521),
        size = vector3(4, 4, 4),
        rotation = 0,
        usePoly = false,
        showBlip = false,
    },
    { -- Yeni Okul Kıyafet 2
        type = "clothing",
        businessId = "clothing_30", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vector4(5318.9310, -5286.5170, 16.6160, 58.3588),
        size = vector3(4, 4, 4),
        rotation = 0,
        usePoly = false,
        showBlip = false,
    },
    { -- Yeni Okul Berber 1
        type = "barber",
        businessId = "barber_31", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vector4(5315.4430, -5283.5630, 16.6160, 46.7477),
        size = vector3(4, 4, 4),
        rotation = 0,
        usePoly = false,
        showBlip = false,
    },
    { -- Yeni Okul Berber 2
        type = "barber",
        businessId = "barber_32", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vector4(5312.6450, -5288.5440, 16.6160, 243.5369),
        size = vector3(4, 4, 4),
        rotation = 0,
        usePoly = false,
        showBlip = false,
    },
    { -- Yeni Okul Kıyafet 3
        type = "clothing",
        businessId = "clothing_33", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vector4(5319.2090, -5233.1270, 43.8200, 194.9546),
        size = vector3(4, 4, 4),
        rotation = 0,
        usePoly = false,
        showBlip = false,
    },
    { -- Yeni Okul Berber 3
        type = "barber",
        businessId = "barber_34", -- sabit id (Berber #1 kaldırılınca sıra kaydı)
        coords = vector4(5315.9090, -5234.2800, 43.8180, 242.1720),
        size = vector3(4, 4, 4),
        rotation = 0,
        usePoly = false,
        showBlip = false,
    },
    { -- CPPD
        type = "clothing",
        businessId = "clothing_35",
        coords = vector4(4374.8599, -4284.6724, 3.6494, 6.8360),
        size = vector3(4, 4, 4),
        rotation = 0,
        usePoly = false,
        showBlip = false,
        auction = false,
        points = {
            vec3(4374.8599, -4284.6724, 3.6494),
        }
    }
}


Config.ClothingRooms = {
    -- {
    --     job = "police",
    --     coords = vector4(454.91, -990.89, 30.69, 193.4),
    --     size = vector3(4, 4, 4),
    --     rotation = 45,
    --     usePoly = false,
    --     points = {
    --         vector3(460.41918945312, -993.11444091797, 30.69),
    --         vector3(449.39508056641, -993.60614013672, 30.69),
    --         vector3(449.88696289062, -990.23779296875, 30.69),
    --         vector3(450.97882080078, -989.71411132812, 30.69),
    --         vector3(451.0325012207, -987.89904785156, 30.69),
    --         vector3(453.47863769531, -987.76928710938, 30.69),
    --         vector3(454.35513305664, -988.46459960938, 30.69),
    --         vector3(460.4231262207, -987.94573974609, 30.69)
    --     }
    -- }
}


Config.PlayerOutfitRooms = {
    -- Sample outfit room config
    --[[    {
        job = "police",
        coords = vector4(287.28, -573.41, 43.16, 79.61),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(284.83, -574.01, 43.16),
            vector3(286.33, -570.03, 43.16),
            vector3(290.33, -571.74, 43.16),
            vector3(289.0, -574.75, 43.16)
        },
        citizenIDs = {
            "BHH65156"
        }
    }]] --
    { -- Ganimet Avı kıyafet dolabı (kayıtlı kıyafetler; satın alma yok)
        coords = vector4(-2112.0349, -291.6656, 13.2653, 0.0),
        size = vector3(3, 3, 3),
        rotation = 0,
        usePoly = false,
        citizenIDs = {} -- boş = herkes kullanabilir
    },
    { -- Equez Galeri kıyafet dolabı (kayıtlı kıyafetler; satın alma yok)
        coords = vector4(-29.0002, -1093.7859, 26.4223, 0.0),
        size = vector3(3, 3, 3),
        rotation = 0,
        usePoly = false,
        citizenIDs = {}
    }
}

Config.Outfits = {
    ["police"] = {
        ["Male"] = {
            {
                name = "Short Sleeve",
                outfitData = {
                    ["pants"] = { item = 24, texture = 0 },    -- Pants
                    ["arms"] = { item = 19, texture = 0 },     -- Arms
                    ["t-shirt"] = { item = 58, texture = 0 },  -- T Shirt
                    ["vest"] = { item = 0, texture = 0 },      -- Body Vest
                    ["torso2"] = { item = 55, texture = 0 },   -- Jacket
                    ["shoes"] = { item = 51, texture = 0 },    -- Shoes
                    ["accessory"] = { item = 0, texture = 0 }, -- Neck Accessory
                    ["bag"] = { item = 0, texture = 0 },       -- Bag
                    ["hat"] = { item = -1, texture = -1 },     -- Hat
                    ["glass"] = { item = 0, texture = 0 },     -- Glasses
                    ["mask"] = { item = 0, texture = 0 }       -- Mask
                },
                grades = { 0, 1, 2, 3, 4 },
            },
            {
                name = "Trooper Tan",
                outfitData = {
                    ["pants"] = { item = 24, texture = 0 },    -- Pants
                    ["arms"] = { item = 20, texture = 0 },     -- Arms
                    ["t-shirt"] = { item = 58, texture = 0 },  -- T Shirt
                    ["vest"] = { item = 0, texture = 0 },      -- Body Vest
                    ["torso2"] = { item = 317, texture = 3 },  -- Jacket
                    ["shoes"] = { item = 51, texture = 0 },    -- Shoes
                    ["accessory"] = { item = 0, texture = 0 }, -- Neck Accessory
                    ["bag"] = { item = 0, texture = 0 },       -- Bag
                    ["hat"] = { item = 58, texture = 0 },      -- Hat
                    ["glass"] = { item = 0, texture = 0 },     -- Glasses
                    ["mask"] = { item = 0, texture = 0 }       -- Mask
                },
                grades = { 0, 1, 2, 3, 4 },
            },
            {
                name = "Long Sleeve",
                outfitData = {
                    ["pants"] = { item = 24, texture = 0 },    -- Pants
                    ["arms"] = { item = 20, texture = 0 },     -- Arms
                    ["t-shirt"] = { item = 58, texture = 0 },  -- T Shirt
                    ["vest"] = { item = 0, texture = 0 },      -- Body Vest
                    ["torso2"] = { item = 317, texture = 0 },  -- Jacket
                    ["shoes"] = { item = 51, texture = 0 },    -- Shoes
                    ["accessory"] = { item = 0, texture = 0 }, -- Neck Accessory
                    ["bag"] = { item = 0, texture = 0 },       -- Bag
                    ["hat"] = { item = -1, texture = -1 },     -- Hat
                    ["glass"] = { item = 0, texture = 0 },     -- Glasses
                    ["mask"] = { item = 0, texture = 0 }       -- Mask
                },
                grades = { 1, 2, 3, 4 },
            },
            {
                name = "Trooper Black",
                outfitData = {
                    ["pants"] = { item = 24, texture = 0 },    -- Pants
                    ["arms"] = { item = 20, texture = 0 },     -- Arms
                    ["t-shirt"] = { item = 58, texture = 0 },  -- T Shirt
                    ["vest"] = { item = 0, texture = 0 },      -- Body Vest
                    ["torso2"] = { item = 317, texture = 8 },  -- Jacket
                    ["shoes"] = { item = 51, texture = 0 },    -- Shoes
                    ["accessory"] = { item = 0, texture = 0 }, -- Neck Accessory
                    ["bag"] = { item = 0, texture = 0 },       -- Bag
                    ["hat"] = { item = 58, texture = 3 },      -- Hat
                    ["glass"] = { item = 0, texture = 0 },     -- Glasses
                    ["mask"] = { item = 0, texture = 0 }       -- Mask
                },
                grades = { 2, 3, 4 },
            },
            {
                name = "SWAT",
                outfitData = {
                    ["pants"] = { item = 130, texture = 1 },     -- Pants
                    ["arms"] = { item = 172, texture = 0 },      -- Arms
                    ["t-shirt"] = { item = 15, texture = 0 },    -- T Shirt
                    ["vest"] = { item = 15, texture = 2 },       -- Body Vest
                    ["torso2"] = { item = 336, texture = 3 },    -- Jacket
                    ["shoes"] = { item = 24, texture = 0 },      -- Shoes
                    ["accessory"] = { item = 133, texture = 0 }, -- Neck Accessory
                    ["hat"] = { item = 150, texture = 0 },       -- Hat
                    ["glass"] = { item = 0, texture = 0 },       -- Glasses
                    ["mask"] = { item = 52, texture = 0 }        -- Mask
                },
                grades = { 3, 4 },
            }
        },
        ["Female"] = {
            {
                name = "Short Sleeve",
                outfitData = {
                    ["pants"] = { item = 133, texture = 0 },   -- Pants
                    ["arms"] = { item = 31, texture = 0 },     -- Arms
                    ["t-shirt"] = { item = 35, texture = 0 },  -- T Shirt
                    ["vest"] = { item = 34, texture = 0 },     -- Body Vest
                    ["torso2"] = { item = 48, texture = 0 },   -- Jacket
                    ["shoes"] = { item = 52, texture = 0 },    -- Shoes
                    ["accessory"] = { item = 0, texture = 0 }, -- Neck Accessory
                    ["bag"] = { item = 0, texture = 0 },       -- Bag
                    ["hat"] = { item = 0, texture = 0 },       -- Hat
                    ["glass"] = { item = 0, texture = 0 },     -- Glasses
                    ["mask"] = { item = 0, texture = 0 }       -- Mask
                },
                grades = { 0, 1, 2, 3, 4 },
            },
            {
                name = "Trooper Tan",
                outfitData = {
                    ["pants"] = { item = 133, texture = 0 },   -- Pants
                    ["arms"] = { item = 31, texture = 0 },     -- Arms
                    ["t-shirt"] = { item = 35, texture = 0 },  -- T Shirt
                    ["vest"] = { item = 34, texture = 0 },     -- Body Vest
                    ["torso2"] = { item = 327, texture = 3 },  -- Jacket
                    ["shoes"] = { item = 52, texture = 0 },    -- Shoes
                    ["accessory"] = { item = 0, texture = 0 }, -- Neck Accessory
                    ["bag"] = { item = 0, texture = 0 },       -- Bag
                    ["hat"] = { item = 0, texture = 0 },       -- Hat
                    ["glass"] = { item = 0, texture = 0 },     -- Glasses
                    ["mask"] = { item = 0, texture = 0 }       -- Mask
                },
                grades = { 0, 1, 2, 3, 4 },
            },
            {
                name = "Long Sleeve",
                outfitData = {
                    ["pants"] = { item = 133, texture = 0 },   -- Pants
                    ["arms"] = { item = 31, texture = 0 },     -- Arms
                    ["t-shirt"] = { item = 35, texture = 0 },  -- T Shirt
                    ["vest"] = { item = 34, texture = 0 },     -- Body Vest
                    ["torso2"] = { item = 327, texture = 0 },  -- Jacket
                    ["shoes"] = { item = 52, texture = 0 },    -- Shoes
                    ["accessory"] = { item = 0, texture = 0 }, -- Neck Accessory
                    ["bag"] = { item = 0, texture = 0 },       -- Bag
                    ["hat"] = { item = 0, texture = 0 },       -- Hat
                    ["glass"] = { item = 0, texture = 0 },     -- Glasses
                    ["mask"] = { item = 0, texture = 0 }       -- Mask
                },
                grades = { 1, 2, 3, 4 },
            },
            {
                name = "Trooper Black",
                outfitData = {
                    ["pants"] = { item = 133, texture = 0 },   -- Pants
                    ["arms"] = { item = 31, texture = 0 },     -- Arms
                    ["t-shirt"] = { item = 35, texture = 0 },  -- T Shirt
                    ["vest"] = { item = 34, texture = 0 },     -- Body Vest
                    ["torso2"] = { item = 327, texture = 8 },  -- Jacket
                    ["shoes"] = { item = 52, texture = 0 },    -- Shoes
                    ["accessory"] = { item = 0, texture = 0 }, -- Neck Accessory
                    ["bag"] = { item = 0, texture = 0 },       -- Bag
                    ["hat"] = { item = 0, texture = 0 },       -- Hat
                    ["glass"] = { item = 0, texture = 0 },     -- Glasses
                    ["mask"] = { item = 0, texture = 0 }       -- Mask
                },
                grades = { 2, 3, 4 },
            },
            {
                name = "SWAT",
                outfitData = {
                    ["pants"] = { item = 135, texture = 1 },     -- Pants
                    ["arms"] = { item = 213, texture = 0 },      -- Arms
                    ["t-shirt"] = { item = 0, texture = 0 },     -- T Shirt
                    ["vest"] = { item = 17, texture = 2 },       -- Body Vest
                    ["torso2"] = { item = 327, texture = 8 },    -- Jacket
                    ["shoes"] = { item = 52, texture = 0 },      -- Shoes
                    ["accessory"] = { item = 102, texture = 0 }, -- Neck Accessory
                    ["bag"] = { item = 0, texture = 0 },         -- Bag
                    ["hat"] = { item = 149, texture = 0 },       -- Hat
                    ["glass"] = { item = 0, texture = 0 },       -- Glasses
                    ["mask"] = { item = 35, texture = 0 }        -- Mask
                },
                grades = { 3, 4 },
            }
        }
    },
    ["realestate"] = {
        ["Male"] = {
            {
                -- Outfits
                name = "Worker",
                outfitData = {
                    ["pants"]     = { item = 28, texture = 0 },  -- Pants
                    ["arms"]      = { item = 1, texture = 0 },   -- Arms
                    ["t-shirt"]   = { item = 31, texture = 0 },  -- T Shirt
                    ["vest"]      = { item = 0, texture = 0 },   -- Body Vest
                    ["torso2"]    = { item = 294, texture = 0 }, -- Jacket
                    ["shoes"]     = { item = 10, texture = 0 },  -- Shoes
                    ["accessory"] = { item = 0, texture = 0 },   -- Neck Accessory
                    ["bag"]       = { item = 0, texture = 0 },   -- Bag
                    ["hat"]       = { item = 12, texture = -1 }, -- Hat
                    ["glass"]     = { item = 0, texture = 0 },   -- Glasses
                    ["mask"]      = { item = 0, texture = 0 },   -- Mask
                },
                grades = { 0, 1, 2, 3, 4 },
            }
        },
        ["Female"] = {
            {
                name = "Worker",
                outfitData = {
                    ["pants"]     = { item = 57, texture = 2 },  -- Pants
                    ["arms"]      = { item = 0, texture = 0 },   -- Arms
                    ["t-shirt"]   = { item = 34, texture = 0 },  -- T Shirt
                    ["vest"]      = { item = 0, texture = 0 },   -- Body Vest
                    ["torso2"]    = { item = 105, texture = 7 }, -- Jacket
                    ["shoes"]     = { item = 8, texture = 5 },   -- Shoes
                    ["accessory"] = { item = 11, texture = 3 },  -- Neck Accessory
                    ["bag"]       = { item = 0, texture = 0 },   -- Bag
                    ["hat"]       = { item = -1, texture = -1 }, -- Hat
                    ["glass"]     = { item = 0, texture = 0 },   -- Glasses
                    ["mask"]      = { item = 0, texture = 0 },   -- Mask
                },
                grades = { 0, 1, 2, 3, 4 },
            }
        }
    },
    ["ambulance"] = {
        ["Male"] = {
            {
                name = "T-Shirt",
                outfitData = {
                    ["arms"] = { item = 85, texture = 0 },       -- Arms
                    ["t-shirt"] = { item = 129, texture = 0 },   -- T-Shirt
                    ["torso2"] = { item = 250, texture = 0 },    -- Jackets
                    ["vest"] = { item = 0, texture = 0 },        -- Vest
                    ["decals"] = { item = 58, texture = 0 },     -- Decals
                    ["accessory"] = { item = 127, texture = 0 }, -- Neck
                    ["bag"] = { item = 0, texture = 0 },         -- Bag
                    ["pants"] = { item = 96, texture = 0 },      -- Pants
                    ["shoes"] = { item = 54, texture = 0 },      -- Shoes
                    ["mask"] = { item = 121, texture = 0 },      -- Mask
                    ["hat"] = { item = 122, texture = 0 },       -- Hat
                    ["glass"] = { item = 0, texture = 0 },       -- Glasses
                    ["ear"] = { item = 0, texture = 0 }          -- Ear accessories
                },
                grades = { 0, 1, 2, 3, 4 },
            },
            {
                name = "Polo",
                outfitData = {
                    ["arms"] = { item = 90, texture = 0 },       -- Arms
                    ["t-shirt"] = { item = 15, texture = 0 },    -- T-Shirt
                    ["torso2"] = { item = 249, texture = 0 },    -- Jackets
                    ["vest"] = { item = 0, texture = 0 },        -- Vest
                    ["decals"] = { item = 57, texture = 0 },     -- Decals
                    ["accessory"] = { item = 126, texture = 0 }, -- Neck
                    ["bag"] = { item = 0, texture = 0 },         -- Bag
                    ["pants"] = { item = 96, texture = 0 },      -- Pants
                    ["shoes"] = { item = 54, texture = 0 },      -- Shoes
                    ["mask"] = { item = 121, texture = 0 },      -- Mask
                    ["hat"] = { item = 122, texture = 0 },       -- Hat
                    ["glass"] = { item = 0, texture = 0 },       -- Glasses
                    ["ear"] = { item = 0, texture = 0 }          -- Ear accessories
                },
                grades = { 2, 3, 4 },
            },
            {
                name = "Doctor",
                outfitData = {
                    ["arms"] = { item = 93, texture = 0 },       -- Arms
                    ["t-shirt"] = { item = 32, texture = 3 },    -- T-Shirt
                    ["torso2"] = { item = 31, texture = 7 },     -- Jackets
                    ["vest"] = { item = 0, texture = 0 },        -- Vest
                    ["decals"] = { item = 0, texture = 0 },      -- Decals
                    ["accessory"] = { item = 126, texture = 0 }, -- Neck
                    ["bag"] = { item = 0, texture = 0 },         -- Bag
                    ["pants"] = { item = 28, texture = 0 },      -- Pants
                    ["shoes"] = { item = 10, texture = 0 },      -- Shoes
                    ["mask"] = { item = 0, texture = 0 },        -- Mask
                    ["hat"] = { item = -1, texture = 0 },        -- Hat
                    ["glass"] = { item = 0, texture = 0 },       -- Glasses
                    ["ear"] = { item = 0, texture = 0 }          -- Ear accessories
                },
                grades = { 3, 4 },
            }
        },
        ["Female"] = {
            {
                name = "T-Shirt",
                outfitData = {
                    ["arms"] = { item = 109, texture = 0 },     -- Arms
                    ["t-shirt"] = { item = 159, texture = 0 },  -- T-Shirt
                    ["torso2"] = { item = 258, texture = 0 },   -- Jackets
                    ["vest"] = { item = 0, texture = 0 },       -- Vest
                    ["decals"] = { item = 66, texture = 0 },    -- Decals
                    ["accessory"] = { item = 97, texture = 0 }, -- Neck
                    ["bag"] = { item = 0, texture = 0 },        -- Bag
                    ["pants"] = { item = 99, texture = 0 },     -- Pants
                    ["shoes"] = { item = 55, texture = 0 },     -- Shoes
                    ["mask"] = { item = 121, texture = 0 },     -- Mask
                    ["hat"] = { item = 121, texture = 0 },      -- Hat
                    ["glass"] = { item = 0, texture = 0 },      -- Glasses
                    ["ear"] = { item = 0, texture = 0 }         -- Ear accessories
                },
                grades = { 0, 1, 2, 3, 4 },
            },
            {
                name = "Polo",
                outfitData = {
                    ["arms"] = { item = 105, texture = 0 },     -- Arms
                    ["t-shirt"] = { item = 13, texture = 0 },   -- T-Shirt
                    ["torso2"] = { item = 257, texture = 0 },   -- Jackets
                    ["vest"] = { item = 0, texture = 0 },       -- Vest
                    ["decals"] = { item = 65, texture = 0 },    -- Decals
                    ["accessory"] = { item = 96, texture = 0 }, -- Neck
                    ["bag"] = { item = 0, texture = 0 },        -- Bag
                    ["pants"] = { item = 99, texture = 0 },     -- Pants
                    ["shoes"] = { item = 55, texture = 0 },     -- Shoes
                    ["mask"] = { item = 121, texture = 0 },     -- Mask
                    ["hat"] = { item = 121, texture = 0 },      -- Hat
                    ["glass"] = { item = 0, texture = 0 },      -- Glasses
                    ["ear"] = { item = 0, texture = 0 }         -- Ear accessories
                },
                grades = { 2, 3, 4 },
            },
            {
                name = "Doctor",
                outfitData = {
                    ["arms"] = { item = 105, texture = 0 },     -- Arms
                    ["t-shirt"] = { item = 39, texture = 3 },   -- T-Shirt
                    ["torso2"] = { item = 7, texture = 1 },     -- Jackets
                    ["vest"] = { item = 0, texture = 0 },       -- Vest
                    ["decals"] = { item = 0, texture = 0 },     -- Decals
                    ["accessory"] = { item = 96, texture = 0 }, -- Neck
                    ["bag"] = { item = 0, texture = 0 },        -- Bag
                    ["pants"] = { item = 34, texture = 0 },     -- Pants
                    ["shoes"] = { item = 29, texture = 0 },     -- Shoes
                    ["mask"] = { item = 0, texture = 0 },       -- Mask
                    ["hat"] = { item = -1, texture = 0 },       -- Hat
                    ["glass"] = { item = 0, texture = 0 },      -- Glasses
                    ["ear"] = { item = 0, texture = 0 }         -- Ear accessories
                },
                grades = { 3, 4 },
            }
        }
    }
}

Config.InitialPlayerClothes = {
    Male = {
        Model = "mp_m_freemode_01",
        Components = {
            {
                component_id = 0, -- Face
                drawable = 0,
                texture = 0
            },
            {
                component_id = 1, -- Mask
                drawable = 0,
                texture = 0
            },
            {
                component_id = 2, -- Hair
                drawable = 0,
                texture = 0
            },
            {
                component_id = 3, -- Upper Body
                drawable = 0,
                texture = 0
            },
            {
                component_id = 4, -- Lower Body
                drawable = 470,
                texture = 0
            },
            {
                component_id = 5, -- Bag
                drawable = 0,
                texture = 0
            },
            {
                component_id = 6, -- Shoes
                drawable = 342,
                texture = 0
            },
            {
                component_id = 7, -- Scarf & Chains
                drawable = 0,
                texture = 0
            },
            {
                component_id = 8, -- Shirt
                drawable = 0,
                texture = 0
            },
            {
                component_id = 9, -- Body Armor
                drawable = 0,
                texture = 0
            },
            {
                component_id = 10, -- Decals
                drawable = 0,
                texture = 0
            },
            {
                component_id = 11, -- Jacket
                drawable = 0,
                texture = 0
            }
        },
        Props = {
            {
                prop_id = 0, -- Hat
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 1, -- Glasses
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 2, -- Ear
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 6, -- Watch
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 7, -- Bracelet
                drawable = -1,
                texture = -1
            }
        },
        Hair = {
            color = 0,
            highlight = 0,
            style = 0,
            texture = 0
        }
    },
    Female = {
        Model = "mp_f_freemode_01",
        Components = {
            {
                component_id = 0, -- Face
                drawable = 0,
                texture = 0
            },
            {
                component_id = 1, -- Mask
                drawable = 0,
                texture = 0
            },
            {
                component_id = 2, -- Hair
                drawable = 0,
                texture = 0
            },
            {
                component_id = 3, -- Upper Body
                drawable = 0,
                texture = 0
            },
            {
                component_id = 4, -- Lower Body
                drawable = 424,
                texture = 0
            },
            {
                component_id = 5, -- Bag
                drawable = 0,
                texture = 0
            },
            {
                component_id = 6, -- Shoes
                drawable = 0,
                texture = 0
            },
            {
                component_id = 7, -- Scarf & Chains
                drawable = 0,
                texture = 0
            },
            {
                component_id = 8, -- Shirt
                drawable = 0,
                texture = 0
            },
            {
                component_id = 9, -- Body Armor
                drawable = 0,
                texture = 0
            },
            {
                component_id = 10, -- Decals
                drawable = 0,
                texture = 0
            },
            {
                component_id = 11, -- Jacket
                drawable = 119,
                texture = 2
            }
        },
        Props = {
            {
                prop_id = 0, -- Hat
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 1, -- Glasses
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 2, -- Ear
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 6, -- Watch
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 7, -- Bracelet
                drawable = -1,
                texture = -1
            }
        },
        Hair = {
            color = 0,
            highlight = 0,
            style = 0,
            texture = 0
        }
    }
}

-- ═══════════════════════════════════════════════════════════════════════════════
--  Ped Modülü Ayarları
-- ═══════════════════════════════════════════════════════════════════════════════

Config.EnablePedModule = true        -- Ped modülünü aktif/pasif yap
Config.PedModuleCommand = "pedlerim" -- Oyuncu ped menüsü komutu
Config.PedAdminCommand = "pedver"    -- Admin ped yönetim komutu
Config.PedAdminGroup = "group.admin" -- ACE permission (server.cfg'de add_principal varsa)
Config.PedAdminPermissions = {       -- qbx_core / qb-core permission listesi
    "god",
    "admin",
    "mod",
}
Config.PedAdminGroups = Config.PedAdminPermissions -- Geriye dönük uyumluluk
Config.PedAutoLoadDefault = true                   -- Giriş yaptığında varsayılan pedi otomatik yükle
Config.PedAutoLoadDelay = 3000                     -- Varsayılan ped yükleme gecikmesi (ms)
