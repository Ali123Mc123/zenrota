-- Entrance scanning: the scanner gates find what the list says (here every category: the island gate). Nothing is
-- scanned anywhere else. The gates come from the world (/collegeadmin): 'scan_gate'.
-- Needs the security module (alerts go out through its dispatch).
Config.Scan = {
    Code = '10-32',                      -- dispatch code on the alert card
    Cooldown = 20,                       -- seconds before the same gate scans the same player again
    ExemptJobs = { 'police', 'bcso', 'sasp', 'pbsd', 'sapr', 'cppd', 'ambulance' },
    ExemptOnDuty = true,                 -- those jobs pass only while on duty
    ExemptStaff = true,                  -- teachers, the principal and security walk through without a scan
    LogClear = false,                    -- also keep clear scans (removed after Retention.ClearDays)

    Gate = {
        Models = { 'ch_prop_ch_metal_detector_01a' }, -- the first your game has is used (game build 2060+)
        Box = { width = 1.0, depth = 1.2, height = 2.2 },
        -- 'walk': scanned while walking through. 'stand': stepping into the frame holds the player for a body scan
        -- (a ring of light from the feet to the head) that everyone near sees; the result shows when it ends.
        Style = 'stand',
        Stand = {
            SweepMs = 650, Cycles = 2,                                   -- one feet-to-head run, how many runs
            Pose = { dict = 'mp_sleep', clip = 'bind_pose_180' },       -- arms out while scanned (nil = no pose)
            Ring = { radius = 1.15, thickness = 0.05, color = { 60, 255, 140, 210 }, lightRange = 2.8, lightIntensity = 9.0 },
            HitLight = { pulseMs = 280, range = 3.2, intensity = 16.0, offsetZ = 0.85 }, -- red blink on a person caught
            Sound = { 'SCAN_START', 'DLC_HEIST_FLEECA_SOUNDSET' },      -- game sound as the scan starts (nil = none)
        },
        ListenDistance = 25.0,           -- the client watches a gate only this close
        Alarm = { Seconds = 3, Radius = 30.0 },
        LaneReport = false,              -- report players who come past a 'scan_lane' zone without the gate
        Lamp = { Model = 'prop_warninglight_01', Height = 2.6 }, -- the small lamp on top ('' = none)
        Sounds = {                       -- game sounds: name, sound set
            clear = { 'Beep_Green', 'DLC_HEIST_HACKING_SNAKE_SOUNDS' },
            alarm = { 'Beep_Red', 'DLC_HEIST_HACKING_SNAKE_SOUNDS' },
        },
    },
    -- What is banned, by this server's item names (ox_inventory, any case). An item named in Items wins over Allow and
    -- Patterns; Allow keeps a pattern's item off the list; Patterns are tried in order (Lua patterns on the
    -- lower-case name). gate: the gate finds it (a security search always finds everything on the list).
    -- returnable: given back after Confiscate.ReturnAfterDays.
    Contraband = {
        Categories = {
            weapon = { gate = true, priority = 'critical', returnable = false },
            blade = { gate = true, priority = 'critical', returnable = false },
            drug = { gate = true, priority = 'warning', returnable = false },     -- the island gate finds everything
            alcohol = { gate = true, priority = 'info', returnable = true },
            tool = { gate = true, priority = 'info', returnable = true },
        },
        Items = {
            -- blades among the weapons
            weapon_dagger = 'blade', weapon_machete = 'blade', weapon_hatchet = 'blade', weapon_stone_hatchet = 'blade',
            weapon_battleaxe = 'blade', weapon_woodaxe = 'blade', weapon_bottle = 'blade', weapon_switchblade = 'blade',
            weapon_tactical_butterfly = 'blade', weapon_st84_skullnsword = 'blade',
            -- tools: taken in, given back
            lockpick = 'tool', advancedlockpick = 'tool',
            weapon_crowbar = 'tool', weapon_hammer = 'tool', weapon_wrench = 'tool', weapon_screwd = 'tool', weapon_drill = 'tool',
            weapon_sledgeh = 'tool', weapon_weld = 'tool', weapon_golfclub = 'tool', weapon_poolcue = 'tool',
            -- drugs without weed, coke or meth in the name
            pills = 'drug', drug_mixer = 'drug', drug_cauldron = 'drug', drug_oven = 'drug',
        },
        Patterns = {
            { match = '^weapon_.*knife', category = 'blade' },   -- knife, blackknife ... camoland_knife
            { match = '^weapon_.*switch$', category = 'blade' }, -- the coloured switchblades
            { match = '^weapon_', category = 'weapon' },         -- every other weapon
            { match = 'rumcoke', category = 'alcohol' }, { match = 'rum_coke', category = 'alcohol' }, -- before 'coke'
            { match = 'weed', category = 'drug' }, { match = 'coke', category = 'drug' }, { match = 'meth', category = 'drug' },
            { match = 'beer', category = 'alcohol' }, { match = 'wine', category = 'alcohol' }, { match = 'whisk', category = 'alcohol' },
            { match = 'vodka', category = 'alcohol' }, { match = 'tequila_', category = 'alcohol' }, { match = 'tequila$', category = 'alcohol' }, { match = 'mezcal', category = 'alcohol' },
            { match = '_rum', category = 'alcohol' }, { match = 'rum_', category = 'alcohol' },
            { match = 'gintonic', category = 'alcohol' }, { match = 'gin_tonic', category = 'alcohol' }, { match = '_gin$', category = 'alcohol' },
            { match = 'margarita', category = 'alcohol' }, { match = 'negroni', category = 'alcohol' }, { match = 'mojito', category = 'alcohol' },
            { match = 'martini', category = 'alcohol' }, { match = 'champagne', category = 'alcohol' }, { match = 'sangria', category = 'alcohol' },
            { match = 'raki', category = 'alcohol' }, { match = 'bourbon', category = 'alcohol' }, { match = 'sake', category = 'alcohol' },
            { match = 'kamikaze', category = 'alcohol' }, { match = 'b52', category = 'alcohol' }, { match = 'lagoon', category = 'alcohol' },
            { match = 'mule', category = 'alcohol' }, { match = 'longisland', category = 'alcohol' }, { match = 'bahamamama', category = 'alcohol' },
            { match = 'onthebeach', category = 'alcohol' }, { match = 'on_the_beach', category = 'alcohol' }, { match = 'oldfashioned', category = 'alcohol' },
            { match = 'cocktail', category = 'alcohol' }, { match = '_shot_', category = 'alcohol' }, { match = '_shot$', category = 'alcohol' },
            { match = 'punch_tiki', category = 'alcohol' },
        },
        Allow = {
            -- harmless "weapons"
            'weapon_flashlight', 'weapon_petrolcan', 'weapon_hazardcan', 'weapon_fertilizercan', 'weapon_fireextinguisher',
            'weapon_ball', 'weapon_snowball', 'weapon_snowlauncher', 'weapon_flare', 'weapon_digiscanner', 'weapon_metaldetector',
            'weapon_candycane', 'weapon_tomato', 'weapon_paintball',
            -- names that look like drugs or drinks but are not
            'casino_coke', 'antidote_weed', 'antidote_meth', 'k9weed', 'sho_seaweed_salad', 'hd_root_beer', 'sc_shrimp_cocktail', 'sc_champagne_sorbet',
        },
    },

    -- The island checkpoint: the gate is the only way onto the island. A clean scan lets that one player through;
    -- anyone crossing from outside into the strip past the gate (Strip, or 'scan_lane' zones) without it is sent back
    -- (so nobody slips in behind someone clean). Leaving the island is never stopped or scanned.
    -- A hit puts the player back too: they leave the banned things in their own locker by the gate ('scan_locker')
    -- and walk through again; the locker keeps them until they take them out on the way out.
    Checkpoint = {
        Enabled = true,
        ClearSeconds = 15,               -- how long a clean scan lets the player cross into the strip
        Strip = { Width = 8.0, Depth = 3.0 }, -- the strip past the gate (m) when no 'scan_lane' zone is drawn
        PushBack = 2.5,                  -- with no send-back point ('scan_return'): metres in front of the gate
        CarrierGap = 2.5,                -- a skateboard, bike or car comes back this far beside the player
        Watch = 40.0,                    -- players this close to a gate are watched
        FindMs = 500,                    -- how often the players near a gate are found
        CheckMs = 150,                   -- how often those few are looked at (a crossing between two looks is caught too)
        ResendMs = 1200,                 -- a send-back that did not happen is sent again after this
        Teleport = 25.0,                 -- moved farther than this in one look: a teleport, not a crossing
        Alert = false,                   -- also send security the school alert and allow a search (false: red light only)
        Locker = { Id = 'college_island_locker', Slots = 40, Weight = 120000, Models = { 'p_cs_locker_01', 'v_ind_rc_locker' } },
    },

    SheetShowAll = false,                -- a search names every item, not only the banned ones

    -- Who hears about a hit besides security: 'self' = teachers who marked themselves on duty today,
    -- 'onduty' = teachers on duty in the framework, 'principal' = only the principal, 'none'.
    DutyTeachers = 'self',
    ShowItemToStudent = false,           -- the student is told the item's name, not only that something was found

    -- SearchMinutes: how long after a hit or a refusal security may search the player.
    Confiscate = { Enabled = true, ReturnAfterDays = 3, SlipItem = 'confiscation_slip', SearchMinutes = 30 },
    Discipline = { Auto = false, Jobs = 5, Seconds = 1800, Fine = 0 }, -- a proposed sanction waits for the principal
    Retention = { ScanDays = 60, ClearDays = 3, ConfiscationDays = 180 }, -- 0 keeps them
}
