-- Janitor incidents: while a janitor is on duty the school now and then has a flood, a power cut, a rat or a lawn
-- to mow. Janitors take the work order from their board (/janitor), do the steps in the world and are paid.
-- Places come from /campusadmin (section Janitor): the depot, bins, flood, power, rat and lawn spots, the mower.
Config.Access.Janitor = 'role:college:janitor'          -- who works the incidents (College's Config.Roles.Janitors)
Config.Access.JanitorAdmin = 'role:college:principal'   -- who may open or cancel one by hand, besides Campus Life admins

Config.Janitor = {
    Enabled = true,
    Command = 'janitor',            -- opens the work order board
    OpenCommand = 'campusincident', -- /campusincident <kind> [place]: opens one by hand
    RequireDuty = true,             -- only janitors on duty in the framework get work orders
    MinOnDuty = 1, MaxOpen = 2,
    Interval = { 8, 15 },           -- minutes between rolls for a new incident
    RemindMinutes = 10,             -- an open order nobody took is sent again after this
    ExpireMinutes = 45,             -- an open order nobody took ends unpaid after this (0 = never)
    RejoinMinutes = 5,              -- a worker who left the game is let go after this; with nobody left the order opens again
    StaleMinutes = 20,              -- a taken order with no work done for this long goes back to the board (0 = never)
    MaxHelpers = 2,
    DepotReach = 3.0,

    Pay = {
        Account = 'bank',           -- the framework account the pay goes to
        ToCampusCard = false,       -- pay onto the College campus card instead
        DailyCap = 5000,            -- the most a janitor earns from incidents in a day (0 = no cap)
        GrowPay = 0.25,             -- each size an incident grew adds this share of its base
    },

    -- Each kind: how often it is picked (weight), when ('school' hours or 'always'), what it pays
    -- (base + per piece of work), and how it grows while nobody takes it (every seconds, up to max).
    Events = {
        flood = { weight = 3, hours = 'always', pay = { base = 250, perPiece = 40, tidy = 30 }, Grow = { every = 180, max = 6 }, SlipChance = 0.15,
            Puddles = 3, Spread = 3.0, Level = 'easy' }, -- Spread: metres the water runs from the spot (a spot's own setting wins)
        power = { weight = 2, hours = 'always', pay = { base = 300, perPiece = 0 }, game = 'sequence', level = 'normal',
            Radius = 25.0, RetrySeconds = 5 }, -- lights out this far from the panel (a panel's own radius setting wins)
        rat = { weight = 2, hours = 'always', pay = { base = 200, perPiece = 80 }, Grow = { every = 300, max = 3 }, Bait = '',
            Model = 'a_c_rat', Lure = { 20, 40 }, BaitLure = { 8, 15 }, Flee = 4.0 }, -- seconds until a rat walks into a trap; Bait: an item that shortens it
        lawn = { weight = 1, hours = 'always', pay = { base = 350, perPiece = 15 }, GrowDays = 3, MaxPatches = 30, Patches = 20 },
    },

    Tools = { 'torch', 'sign', 'trap', 'mop' }, -- what the depot hands out

    -- The close panels (a valve, a breaker panel): difficulty, and the breakers in circuit order (each name's text is
    -- janitor.breaker_<name> in the locales; a name with no text there shows as written).
    Games = {
        Levels = {
            easy = { pass = 50, rounds = 3, zone = 0.24, speed = 0.7, steps = 4 },
            normal = { pass = 70, rounds = 4, zone = 0.18, speed = 1.0, steps = 5 },
        },
        Banks = {
            power = { sequence = { { 'main', 'halls', 'classrooms', 'canteen', 'gym', 'outside' } }, showOrder = true }, -- showOrder: the diagram in the door
        },
    },

    -- Strokes for mopping: two keys in turn, steady (as College's detention).
    Strokes = { Keys = { { control = 34, name = 'A' }, { control = 35, name = 'D' } }, PerStage = 8, MinGapMs = 250, MaxGapMs = 1400 },
    Clips = { mop = { dict = 'anim@scripted@freemode@ig13_mop_floor@male@', clip = 'action', ms = 1600 }, valve = { dict = 'anim@scripted@freemode@ig11_valve_turn@male@', clip = 'action' } },
    Hands = { mop = { bone = 28422, pos = vec3(0.0, 0.0, -0.05), rot = vec3(0.0, 0.0, 0.0) }, torch = { bone = 57005, pos = vec3(0.12, 0.02, -0.02), rot = vec3(-90.0, 0.0, 0.0) },
        trap = { bone = 57005, pos = vec3(0.25, 0.0, -0.05), rot = vec3(0.0, -90.0, 0.0) } },
    Sounds = { powerDown = { 'Power_Down', 'DLC_HEIST_HACKING_SNAKE_SOUNDS' }, sparks = { 'Short_Circuit', 'DLC_BTL_Hacker_Sounds' } }, -- name, set
    Torch = { Distance = 18.0, Brightness = 6.0, Radius = 24.0, Falloff = 10.0 }, -- the torch's cone
    Effects = { water = { 'core', 'ent_sht_water' }, sparks = { 'core', 'ent_brk_sparking_wires' } }, -- particle asset and name

    Mower = { Model = 'mower', PushModel = 'prop_lawnmower_01', ReturnMinutes = 20, LateFee = 100 },

    -- Models: the first your game has is used; a staged one ('<name>_<state>') shows the work going down.
    Models = {
        depot = { 'prop_cleaning_trolly' }, bin = { 'p_dumpster_t', 'prop_bin_01a' }, board = { 'p_amb_clipboard_01' },
        puddle = { 'daddy_school_puddle', 'm23_2_prop_m32_puddle_01a' }, sign = { 'v_serv_wetfloorsn', 'prop_mp_cone_02' },
        trap = { 'daddy_school_rat_trap_open', 'prop_cs_cardbox_01' }, trapFull = { 'daddy_school_rat_trap_rat', 'prop_cs_cardbox_01' }, grass = { 'daddy_school_grass', 'prop_grass_001_a' },
        panel = { 'daddy_school_breaker_panel', 'ch_prop_ch_fuse_box_01a' }, torch = { 'prop_cs_police_torch' }, mop = { 'prop_cs_mop_s' },
        bucket = { 'm23_2_prop_m32_bucket_mop_01a', 'prop_cs_mopbucket_01' },
    },

    Retention = { IncidentDays = 30, PayDays = 90 },
}
