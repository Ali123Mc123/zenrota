------------------------------------------------------------------------
-- For any information about config, please check
-- https://documentation.rcore.cz/paid-resources/rcore_tattoos/config
------------------------------------------------------------------------

-- GENERAL --
Config = Config or {}
Config.Debug = false
Config.DebugLevel = {
    'INFO',
    'CRITICAL',
    'WARNING',
    'SUCCESS',
    'ERROR',
    'DEBUG',
    'SECURITY',
}

-- ENVIRONMENT --
Config.Locale = 'tr' -- Shop language - en, es, de, cs, fr, it, kr, pl
-- Tattoo names are automatically translated to the language of players GTA client,
-- if the tattoo name is available in the language

--Checkout server/lib/frameworkBridge.lua if you need make any changes
--Options:
--    Frameworks.ESX
--    Frameworks.QBCORE
--    Frameworks.STANDALONE - check documentation for this type of framework!
Config.Framework = Frameworks.QBCORE
Config.EnableGuidebookIntegration = false --enable rcore_guidebook integration https://store.rcore.cz/package/5041989
Config.LicenseType = 'license'            --license, steam, discord
Config.LicenseWithoutPrefix = true        --remove license:, steam: prefix from license

Config.TattooListsPath = "assets/tattooLists/"
Config.TattooLists = {
    -- Different tattoo DLCs are loaded separately, we recommend you to delete the ones that are newer,
    -- than your server's version (build number), otherwise the tattoos will still be in the menu, but will not show up
    -- more info in the documentation (link above)
    "BaseTattoos.json",
    "DLC_mpvinewood.json",   -- build 1737 (The Diamond Casino & Resort)
    "DLC_mpheist3.json",     -- build 1868 (The Diamond Casino Heist)
    "DLC_mpheist4.json",     -- build 2189 (The Cayo Perico Heist)
    "DLC_mpsecurity.json",   -- build 2545 (The Contract)
    "DLC_enterprise.json",   -- build 2699 (The Criminal Enterprises)
    "DLC_mpchristmas3.json", -- build 2802 (Los Santos Drug Wars)
    "HairFades.json",
    "DLC_mp2023_02.json",    -- build 3095 (The Chop Shop)
    -- "HairFades2.json", -- 126 more hair fades

    --Optional - have to be bought at link below to be able to use
    --RCore Addon tattoos - https://store.addon-tattoos.com/
    --"rcoreAbstractTattoos.json",
    --"rcoreAddonTattoos_animals.json",
    --"rcoreAddonTattoos_army-tattoo.json",
    --"rcoreAddonTattoos_faith.json",
    --"rcoreAddonTattoos_gangster.json",
    --"rcoreAddonTattoos_halloween.json",
    --"rcoreAddonTattoos_japanese-tattoos-pack.json",
    --"rcoreAddonTattoos_mafia-kings.json",
    --"rcoreAddonTattoos_rm.json",
    --"rcoreAddonTattoos_sons-of-anarchy.json",
    --"rcoreAddonTattoos_viking-tattoo.json",

    -- Following DLCs did not add any new tattoos: 3258 3407 3570 3751
}

-- KEYS | docs here - https://docs.fivem.net/docs/game-references/controls/
-- ❗❗ if changed, don't forget to also change in your language file to show correct keys in-game!
Config.Keys = {
    [Keys.INTERACT] = 51,        --51 INPUT_CONTEXT, Key to use to open tattoo menu
    [Keys.SESSION_LEAVE] = 194,  --194 BACKSPACE, Key to leave tattoo session as employee
    [Keys.START_TATTOOING] = 51, --51 E, Key to start tattooing as employer
}

-- BLIPS --
Config.DefaultBlipSettings = {
    name = 'Dövmeci',
    icon = 75
}
Config.DefaultBlipOptions = {
    type = 2,
    scale = 1.0,
    color = 1,
    shortRange = true
}

-- MARKERS --
Config.NearObjectDistance = 5 -- Marker render distance from player
Config.DefaultMarkerSettings = {
    text = '👺',
    size = 0.5,
    color = { r = 255, g = 255, b = 255, a = 255 }, -- Values 0-255 of RGB {red, green, blue, opacity},
    distance = Config.NearObjectDistance
}
Config.CheckPlayerPosition = 300 -- value in 'ms' to check for markers near player, 300 default, lower values can display wrong

-- SPECIAL FUNCTIONS --
Config.HennaTattooDuration = 2         -- Duration of temporary tattoos in real life days (default is 2 days)
Config.HennaAdditionalPrice = 500      -- Additional price for henna tattoo

Config.EnableShopEnterAnimation = true -- If true, taking off clothes will have animation, if ForcePlayerShopPosition is also true, player will walk to the marker automatically
Config.ForcePlayerShopPosition = false --Forcing teleport player into exact spot

Config.DisableTattooRemoval = false    -- If true, player will not be able to remove tattoos in shop

-- MONEY --
Config.MoneyAccountTypes = { "bank" } -- Accounts to check if player can afford tattoo, accounts will be checked in the order you write them
Config.PriceMultiplier = 2          -- You can simply adjust price of all tattoos by changing this multiplier, deafult = 1.0 (=no price change)

-- BODY CONFIG --
Config.NakedPartsIds = {
    male = {
        tshirt_1  = 0, -- GÖMLEK
        tshirt_2  = 0,
        arms      = 0,
        torso_1   = 0,   -- CEKET
        torso_2   = 0,
        pants_1   = 198, -- BACAKLAR
        pants_2   = 0,
        decals_1  = 0,
        decals_2  = 0,
        shoes_1   = 154, -- AYAKKABI
        shoes_2   = 0,
        mask_1    = 0,
        bproof_1  = 0,
        bproof_2  = 0,
        chain_1   = 0,
        chain_2   = 0,
        bags_1    = 0,
        bags_2    = 0,
        helmet_1  = -1,
        helmet_2  = 0,
        glasses_1 = -1,
        glasses_2 = 0,
        ears_1    = -1,
        ears_2    = 0
    },
    female = {
        tshirt_1  = 0,    -- GÖMLEK
        tshirt_2  = 0,
        arms      = 0,    -- ELLER
        torso_1   = 201, -- CEKET
        torso_2   = 0,
        pants_1   = 424,    -- BACAKLAR
        pants_2   = 0,
        decals_1  = 0,
        decals_2  = 0,
        shoes_1   = 0, -- AYAKKABI
        shoes_2   = 0,
        mask_1    = 0,
        bproof_1  = 0,
        bproof_2  = 0,
        chain_1   = 0,
        chain_2   = 0,
        bags_1    = 0,
        bags_2    = 0,
        helmet_1  = -1,
        helmet_2  = 0,
        glasses_1 = -1,
        glasses_2 = 0,
        ears_1    = -1,
        ears_2    = 0
    }
}

-- SHOPS --
-- For all possible tattoo shop variants and features, please check the documentation (link above)
Config.Shops = {
    { -- Shop as a business with job and employees
        pos = vector3(-112.37, -10.26, 70.51),
        blip = Config.DefaultBlipSettings,
        marker = Config.DefaultMarkerSettings,
        businessId = 'dovmeci1',
    },
    {
        pos = vector3(-112.2402, -12.2316, 70.5195),
        blip = Config.DefaultBlipSettings,
        marker = Config.DefaultMarkerSettings,
        businessId = 'dovmeci1_chair2',
    },
    { -- Shop as a business with job and employees
        pos = vector3(-1154.99, -1427.23, 4.95),
        blip = Config.DefaultBlipSettings,
        marker = Config.DefaultMarkerSettings,
        businessId = 'dovmeci2',
    },
    {
        pos = vector3(323.20, 180.82, 103.59),
        blip = Config.DefaultBlipSettings,
        marker = Config.DefaultMarkerSettings,
        businessId = 'dovmeci3',
    },
    {
        pos = vector3(324.8154, 179.7087, 103.5865),
        blip = Config.DefaultBlipSettings,
        marker = Config.DefaultMarkerSettings,
        businessId = 'dovmeci3_chair2',
    },
    {
        pos = vector3(1864.0122, 3746.7573, 33.0326),
        blip = Config.DefaultBlipSettings,
        marker = Config.DefaultMarkerSettings,
        businessId = 'dovmeci4',
    },
    {
        pos = vector3(-3170.2290, 1076.3744, 20.8292),
        blip = Config.DefaultBlipSettings,
        marker = Config.DefaultMarkerSettings,
        businessId = 'dovmeci5',
    },
    {
        pos = vector3(1322.6858, -1653.0496, 52.2753),
        blip = Config.DefaultBlipSettings,
        marker = Config.DefaultMarkerSettings,
        businessId = 'dovmeci6',
    },
    {
        pos = vector3(1320.7954, -1653.8610, 52.2752),
        blip = Config.DefaultBlipSettings,
        marker = Config.DefaultMarkerSettings,
        businessId = 'dovmeci6_chair2',
    },
    {
        pos = vector3(2511.9624, 4091.0938, 35.5852),
        blip = Config.DefaultBlipSettings,
        marker = Config.DefaultMarkerSettings,
        businessId = 'dovmeci7',
    }    
}


-- ❗❗❗ EXPERIMENTAL ❗❗❗
-- All settings below are *experimental*
-- Bugs can occur by using these experimental settings
-- *NO* support is provided for these settings, use at your own risk

-- Opacity
Config.UseOpacity = false              -- default = false
Config.DefaultOpacity = 1              -- Default tattoo opacity (1-5)
Config.OpacityAdditionalPrice = 100    -- Additional price per opacity level
Config.DisableCollisionSetting = false -- Disable collision setting for tattooed player
