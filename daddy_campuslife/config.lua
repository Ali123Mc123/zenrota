Config = {}

Config.Locale = 'en' -- en | tr

-- Who may use each service. Access rules: everyone, job:name:grade, ace:name, cid:id, item:name, role:college:student ...
Config.Access = {
    Canteen = 'everyone',
    Vending = 'role:college:student, role:college:member',
    Nurse = 'everyone',
    Shop = 'everyone',
    ShopStaff = 'role:college:canteen', -- cashiers at a staffed till
}

Config.Accounts = { 'cash', 'bank' } -- the canteen lets the buyer pick; other payments take the first account that holds them
Config.CampusCard = true             -- the canteen also takes the College campus card (its balance), when College runs
Config.ScholarshipDiscount = true    -- the College scholarship lowers canteen prices

-- The canteen: each canteen keeps its own catalog, edited in the panel (/campusadmin). Stock is optional per item.
Config.Canteen = {
    -- DaddyRP: off. The college canteen is an ox_inventory shop now (data/shops.lua: kolej_kantin, the 'kantin' job only);
    -- no clerk ped, no canteen screen and no canteen in the Student Phone's Wallet. true brings it all back as it was.
    Enabled = false,
    Reach = 4.0,          -- how close the buyer must stand (server check)
    SessionSeconds = 180, -- an open shop expires after this
    MaxLines = 24, MaxQuantity = 60,
    PendingMinutes = 5,   -- an order stuck half way (a crash) is settled after this: stock back, money back
    RestockMinutes = 60,  -- items with a restock level are filled up to it this often
    Categories = { 'food', 'drink', 'snack', 'other' }, -- labels in locales (canteen.category_<id>)
    -- Items a new canteen can start with in the panel; items your inventory does not have are skipped.
    Starter = {
        { item = 'toast_a', category = 'food', price = 40 },
        { item = 'sandwich', category = 'food', price = 50 },
        { item = 'chips_c', category = 'snack', price = 30 },
        { item = 'water_bottle', category = 'drink', price = 20 },
        { item = 'coffeecup_a', category = 'drink', price = 40 },
        { item = 'bubbletea_a', category = 'drink', price = 60 },
        { item = 'redbull', category = 'drink', price = 50 },
    },
}

-- Vending machines: points on the machines of the map, each selling one catalog. Missing items are skipped.
Config.Vending = {
    Reach = 3.0, MaxCount = 10, CooldownMs = 1500, ProgressMs = 2000,
    Catalogs = {
        snack = { { item = 'toast_a', price = 40 }, { item = 'sandwich', price = 50 }, { item = 'chips_c', price = 30 } },
        drink = { { item = 'water_bottle', price = 20 }, { item = 'bubbletea_a', price = 60 }, { item = 'coffeecup_a', price = 40 } },
        coffee = { { item = 'coffeecup_a', price = 40 } },
    },
}

-- The infirmary: a nurse treats one patient at a time on a bed; each nurse spot has its own fee, bed and bedside.
Config.Nurse = {
    Reach = 3.0, DurationMs = 10000, WalkMs = 2500,
    ExitStep = 1.0, -- the patient gets up this far to the side of the nurse's spot at the bed (m)
    ClosedWhenOnDuty = { Job = 'ambulance', Count = 0 }, -- with this many on duty the nurses close; 0 keeps them open
    PatientAnim = { dict = 'anim@gangops@morgue@table@', clip = 'body_search' },
    TreatAnim = { dict = 'amb@medic@standing@timeofdeath@base', clip = 'base' },
}

-- Chairs: points on the chairs of the map. [G] changes the pose; poses are per character model.
Config.Chairs = {
    Male = {
        { id = 'normal', scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER' },
        { id = 'forward', scenario = 'PROP_HUMAN_SEAT_STRIP_WATCH' },
        { id = 'back', scenario = 'PROP_HUMAN_SEAT_DECKCHAIR' },
    },
    -- z / fwd / side move the clip against the chair, in metres.
    Female = {
        { id = 'normal', dict = 'timetable@reunited@ig_10', anim = 'base_amanda', z = -0.5 },
        { id = 'legs_crossed', dict = 'timetable@amanda@ig_12', anim = 'base_amanda', z = -0.5 },
        { id = 'at_table', dict = 'switch@michael@restaurant', anim = '001510_02_gc_mics3_ig_1_base_amanda', z = -0.5 },
    },
}

-- Floor plans: boards that open your building's plans. Put the pictures in floors/ (they are your map's, not ours),
-- or give a full nui:// or https:// address.
Config.FloorPlans = {
    Floors = {
        -- { id = 'ground', label = 'Ground floor', image = 'floors/ground.webp' },
    },
}

-- The gym: workout spots placed in the panel, and every gym prop of the map below.
Config.Gym = {
    Exercises = {
        pushups = { scenario = 'WORLD_HUMAN_PUSH_UPS' },
        situps = { scenario = 'WORLD_HUMAN_SIT_UPS' },
        chinups = { dict = 'amb@prop_human_muscle_chin_ups@male@base', anim = 'base' },
        weights = { scenario = 'WORLD_HUMAN_MUSCLE_FREE_WEIGHTS' },
        flex = { scenario = 'WORLD_HUMAN_MUSCLE_FLEX' },
        yoga = { scenario = 'WORLD_HUMAN_YOGA' },
    },
    Props = { prop_muscle_bench_01 = 'weights', prop_muscle_bench_02 = 'weights', prop_chinup_01 = 'chinups', prop_freeweight_01 = 'weights' },
    MinSeconds = 5, -- shorter workouts are not reported
}

-- The panel (/campusadmin): canteens, vending machines, nurses, chairs, floor plans and gym spots.
Config.Admin = {
    Command = 'campusadmin', PlacementReach = 150.0, MaxBatch = 64,
    Peds = { 's_f_y_scrubs_01', 's_m_m_doctor_01', 's_f_y_shop_mid', 'a_f_y_business_02', 'a_m_y_business_01', 's_m_y_chef_01' },
    Props = { 'prop_vend_snak_01', 'prop_vend_soda_01', 'prop_vend_soda_02', 'prop_vend_coffe_01', 'prop_vend_water_01',
        'prop_cleaning_trolly', 'p_dumpster_t', 'prop_bin_01a', 'ch_prop_ch_fuse_box_01a' },
    Scenarios = { 'WORLD_HUMAN_CLIPBOARD', 'WORLD_HUMAN_STAND_IMPATIENT', 'WORLD_HUMAN_AA_COFFEE', 'PROP_HUMAN_BUM_SHOPPING_CART' },
}

Config.Theme = {
    accent = '#D43D45', accentHover = '#C2353D', accentActive = '#A92D35',
    accentSubtle = '#25171B', accentMuted = '#52252B', accentRing = '#E05B62', accentText = '#F08A8F',
}

-- Server settings (overrides/daddy_campuslife/config.lua)
-- The server's language.
Config.Locale = 'tr'
-- DaddyRP: the Cayo campus's floor plans; the map resource (daddy_school_cayo) carries the pictures.
Config.FloorPlans = {
    Floors = {
        { id = 'second', label = '2. Kat', image = 'nui://daddy_school_cayo/floors/second.webp' },
        { id = 'first', label = '1. Kat', image = 'nui://daddy_school_cayo/floors/first.webp' },
        { id = 'ground', label = 'Zemin Kat', image = 'nui://daddy_school_cayo/floors/ground.webp' },
        { id = 'lower', label = 'Alt Kat', image = 'nui://daddy_school_cayo/floors/lower.webp' },
        { id = 'sport', label = 'Spor Katı', image = 'nui://daddy_school_cayo/floors/sport.webp' },
        { id = 'cellar', label = 'Mahzen', image = 'nui://daddy_school_cayo/floors/cellar.webp' },
    },
}
