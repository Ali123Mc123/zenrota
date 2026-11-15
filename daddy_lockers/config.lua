Config = {}

Config.Locale = 'en' -- en | tr

-- Who may rent a locker, and who may open any locker to search it (every search is logged). Access rules:
-- everyone, job:name:grade, ace:name, cid:id, item:name, role:college:student ...
Config.Renters = 'role:college:student, role:college:staff'
Config.SearchAccess = 'job:police, role:college:security'

Config.Accounts = { 'cash', 'bank' } -- payments are taken from the first account that holds them
Config.ScholarshipDiscount = true    -- the College scholarship lowers the rent

-- A new locker group starts with these; the panel (/lockeradmin) changes them per group.
Config.GroupDefaults = { SlotCount = 20, MaxWeight = 50000, RentPrice = 250, RentDays = 7, GraceDays = 0.5, PinLength = 4, MaxPerPlayer = 1, Paint = '#3d5a73' }

-- After a rental ends there are GraceDays to take things out (nothing can be put in); then the items wait at
-- Student Affairs for UnclaimedDays.
Config.UnclaimedDays = 30

Config.Pin = { MaxAttempts = 3, LockoutSeconds = 300 } -- per player and locker
Config.Interact = { Distance = 2.0, ServerDistance = 4.0, SessionMinutes = 5, StayDistance = 6.0 }

Config.Upgrades = { AlarmPrice = 600, ShelfPrice = 500, BonusSlots = 10, BonusWeight = 25000 }
Config.Notes = { Enabled = true, MaxPerLocker = 20, MaxLength = 300 }

-- Breaking a locker open: the item is checked on the server and every attempt gets one ticket.
Config.Lockpick = {
    Enabled = true,
    Item = 'lockpick',
    Stages = { 'easy', 'medium', 'medium', 'hard' }, -- one spot to find on the dial per stage: easy, medium or hard
    Keys = { 'e', 'r', '1', '2' }, -- unused since the dial game; kept so old configs load
    BreakChance = 0.5, -- the pick breaks on a failed attempt
    AlarmChance = 0.5, -- a failed attempt sets off a locker without an alarm upgrade
    CooldownSeconds = 20,
}

-- The alarm heard around a locker when it is broken into or its PIN is guessed too often.
Config.Alarm = { Radius = 30.0, Volume = 0.7, Seconds = 8 }

-- Name plate styles; the classic one is free. Labels are in locales (plates.<id>).
Config.Plates = {
    classic = { price = 0, icon = 'scroll' },
    gothic = { price = 750, icon = 'skull' },
    racing = { price = 1200, icon = 'flag-checkered' },
    anime = { price = 900, icon = 'wand-magic-sparkles' },
    luxury = { price = 1500, icon = 'crown' },
    street = { price = 600, icon = 'spray-can' },
    cyberpunk = { price = 1400, icon = 'microchip' },
    tactical = { price = 850, icon = 'shield-halved' },
    leather = { price = 1100, icon = 'stamp' },
    vaporwave = { price = 950, icon = 'gamepad' },
    hazard = { price = 700, icon = 'biohazard' },
}

-- Outfits a renter can put on at the locker. Use the components of your own server's clothes.
Config.Wardrobe = {
    Enabled = true,
    OutfitMenu = true, -- also opens the appearance resource's outfit menu (illenium-appearance, fivem-appearance, qb-clothing)
    Uniforms = {
        -- { label = 'School uniform', model = 'mp_m_freemode_01',
        --   components = { { component_id = 11, drawable = 0, texture = 0 } }, props = { { prop_id = 0, drawable = -1, texture = -1 } } },
    },
}

-- The name plate on each rented locker (a small page drawn in the world).
Config.Nameplate = {
    Enabled = true,
    MaxDistance = 3.0,
    Width = 0.60, Height = 0.15, -- metres; keep 4:1
    HeightOffset = 0.1,
    FaceOffset = 0.025,  -- pushed toward the door so it does not flicker
    HeadingOffset = 90.0, -- turn of the plate against the locker's heading
    FadeMs = 220,
    DuiPriority = 1,     -- the shared page budget: plates keep their page over screens of a lower priority
}

-- Locker groups and spots (/lockeradmin). Lockers are points on the lockers of the map; nothing is spawned.
Config.Admin = { Command = 'lockeradmin', PlacementReach = 150.0, MaxBatch = 64 }

Config.Theme = {
    accent = '#D43D45', accentHover = '#C2353D', accentActive = '#A92D35',
    accentSubtle = '#25171B', accentMuted = '#52252B', accentRing = '#E05B62', accentText = '#F08A8F',
}

-- Server settings (overrides/daddy_lockers/config.lua)
-- The server's language.
Config.Locale = 'tr'
-- DaddyRP's police jobs and school security may search a locker.
Config.SearchAccess = 'job:police, job:sasp, job:pbsd, job:cppd, job:dp, job:sapr, job:bcso, role:college:security'
