Config = {}

-- Settings =========================================================================================================

Config.Locale = 'en' -- en | tr
Config.Debug = false -- prints placement and fire changes in the server console

Config.Reach = 6.0          -- how far from the player a piece may be placed (m)
Config.LogoutMinutes = 15   -- a camp is packed up this long after its owner leaves; the pieces wait for them as items
Config.StaleDays = 7        -- backup: pieces nobody touched for this many days are packed up the same way (0: never)
Config.Limits = { Total = 10, PerKind = { tent = 2, fire = 2, stove = 1 } } -- per character

-- One camp per character: the first tent or fire is its middle, everything else stays close. Distances in m.
Config.Camp = {
    Radius = 20.0,   -- pieces stay this close to the camp's middle
    Gap = 15.0,      -- from anyone else's camp
    Area = 50.0,     -- within this distance ...
    AreaMax = 30,    -- ... at most this many pieces, all players together
    RoadGap = 8.0,   -- from any road
    MaxSlope = 20.0, -- steepest ground, degrees
}

-- Ground a camp may stand on, by collision material (hashes from ScriptHookVDotNet's MaterialHash list).
-- Everything else (tarmac, concrete, paving, roof, metal, wooden floors) is refused, and so is any interior.
Config.Ground = {
    Grass = 0x4F747B87, GrassShort = 0xB34E900D, GrassLong = 0xE47A3E41, Hay = 0x92B69883,
    Bushes = 0x22AD7B72, Twigs = 0xC98F5B61, Leaves = 0x8653C6CD, Woodchips = 0xED932E53,
    Soil = 0xD63CCDDB, DirtTrack = 0x8F9CD58F, MudHard = 0x8C31B7EA, MudSoft = 0x61826E7A, ClayHard = 0x4434DFE7, ClaySoft = 0x216FF3F0,
    SandLoose = 0xA0EBF7E4, SandCompact = 0x1E6D775E, SandWet = 0x363CBCD5, SandTrack = 0x8E4D8AFF, SandDryDeep = 0x1E5E7A48, SandWetDeep = 0x4CCC2AFF,
    GravelSmall = 0x38BBD00C, GravelLarge = 0x7EDC5571, GravelDeep = 0xEABD174E,
    SnowLoose = 0x8C8308CA, SnowCompact = 0xCBA23987, SnowDeep = 0x608ABC80,
}

-- Extra places where nobody may camp, even on grass: { coords = vec3(x, y, z), radius = 80.0 }
Config.Areas = {}

-- Drawing: big pieces (big = true below) and small ones load within these distances; only the nearest lights shine.
-- Cell: the server sends each player the pieces of the 3 x 3 cells of this size around them.
Config.Stream = { Big = 80.0, Small = 35.0, Lights = 6, Flames = 60.0, Cell = 200.0 }

-- /campadmin (ACE daddy.admin.camp, daddy.admin or the framework's admin): camps within Range, removed pieces go back
-- to their owners. Logs go to the webhook in the convar daddy:webhook:camp:log.
Config.Admin = { Command = 'campadmin', Range = 150.0 }

-- Items the camp uses that are not its own pieces. Igniters: any one lights a fire or a torch; Consume: used up.
Config.Items = {
    Igniters = { 'lighter', 'camp_matches' },
    Consume = { camp_matches = true },
    Wood = 'camp_firewood',
    Water = 'water',        -- douses a fire and fills the pot
    Log = 'camp_log',       -- goes on the chopping block
}

Config.Keys = { Toggle = 'H', Drop = 'G' } -- held lights: switch on/off, set down (players can rebind in the game)

Config.Fire = {
    WoodMinutes = 3,    -- one bundle burns this long
    MaxWood = 3,        -- bundles the pit holds
    EmbersMinutes = 1,  -- the last minutes of wood glow as embers
    OutMinutes = 3,     -- a dead fire stays as ash this long, then the pit is empty
    RainFactor = 1.6,   -- wood burns this much faster in rain
    Light = { color = { 255, 120, 40 }, range = 9.0, intensity = 6.0 },
    FlameHeight = 0.0,  -- flames start this high above the pit (m)
    Effects = { burning = { 'core', 'ent_amb_beach_campfire', 0.9 }, embers = { 'core', 'ent_amb_torch_fire', 0.5 } },
}

Config.Stove = { Minutes = 8, Light = { color = { 255, 150, 60 }, range = 3.0, intensity = 2.0 }, Effect = { 'core', 'ent_amb_torch_fire', 0.25 } }
Config.Stack = { Capacity = 8, Start = 4 } -- firewood stack: bundles it holds, bundles it comes with
Config.PitchSeconds = 8                     -- a tent shows half raised this long

-- Shop: rangers who sell the camp items. Accounts: what the player may pay with (cash | bank), the first is picked.
-- cat: the shelf it is on (sleep | fire | seat | light | tool | food | sport).
-- More: items of other scripts sold here too, same fields; image: a picture URL if the inventory has none.
Config.Shop = {
    Enabled = true,
    Accounts = { 'cash', 'bank' },
    MaxCount = 20, -- of one item per purchase
    Ped = 's_m_y_ranger_01',
    Blip = { sprite = 557, colour = 25, scale = 0.8 },
    Points = { vec4(-679.4, 5838.9, 17.33, 225.0) },
    Items = {
        { item = 'camp_tent_dome', price = 450, cat = 'sleep' }, { item = 'camp_tent_canvas', price = 650, cat = 'sleep' },
        { item = 'camp_tent_cabin', price = 900, cat = 'sleep' }, { item = 'camp_sleeping_bag', price = 120, cat = 'sleep' },
        { item = 'camp_tarp', price = 180, cat = 'sleep' }, { item = 'camp_hammock', price = 350, cat = 'sleep' },
        { item = 'camp_backpack', price = 200, cat = 'sleep' }, { item = 'camp_tent_bag', price = 60, cat = 'sleep' },

        { item = 'camp_fire_pit', price = 60, cat = 'fire' }, { item = 'camp_grill', price = 90, cat = 'fire' },
        { item = 'camp_tripod', price = 140, cat = 'fire' }, { item = 'camp_stove', price = 140, cat = 'fire' },
        { item = 'camp_firewood', price = 15, cat = 'fire' }, { item = 'camp_firewood_stack', price = 90, cat = 'fire' },
        { item = 'camp_matches', price = 5, cat = 'fire' }, { item = 'camp_coffee_pot', price = 45, cat = 'fire' },
        { item = 'camp_skillet', price = 55, cat = 'fire' }, { item = 'camp_mug', price = 12, cat = 'fire' },
        { item = 'camp_canteen', price = 30, cat = 'fire' }, { item = 'camp_water_jug', price = 35, cat = 'fire' },
        { item = 'camp_cooler', price = 150, cat = 'fire' },

        { item = 'camp_log_bench', price = 160, cat = 'seat' }, { item = 'camp_stump', price = 40, cat = 'seat' },
        { item = 'camp_chair', price = 95, cat = 'seat' }, { item = 'camp_table', price = 130, cat = 'seat' },

        { item = 'camp_lantern', price = 110, cat = 'light' }, { item = 'camp_lantern_hook', price = 45, cat = 'light' },
        { item = 'camp_flashlight', price = 60, cat = 'light' }, { item = 'camp_torch', price = 20, cat = 'light' },

        { item = 'camp_axe', price = 120, cat = 'tool' }, { item = 'camp_chopping_block', price = 70, cat = 'tool' },
        { item = 'camp_log', price = 5, cat = 'tool' }, { item = 'camp_roast_stick', price = 10, cat = 'tool' },

        { item = 'camp_marshmallow', price = 4, cat = 'food' }, { item = 'camp_sausage', price = 8, cat = 'food' },
        { item = 'camp_coffee_grounds', price = 12, cat = 'food' }, { item = 'camp_breakfast_pack', price = 18, cat = 'food' },
        { item = 'camp_stew_pack', price = 22, cat = 'food' },
    },
    More = {
        -- { item = 'skateboard', price = 1000, cat = 'sport' },
    },
}

-- Cooking: the roasting stick game and timed recipes at a station. Inputs: { items = { any of }, count }.
Config.Cook = {
    Roast = {
        Seconds = 14,         -- from raw to burnt
        Golden = { 0.5, 0.8 }, -- the share of the time when pulling it gives the good one
        Jitter = 0.06,        -- the window moves a little every time
        Foods = {
            camp_marshmallow = { golden = 'camp_marshmallow_toasted', burnt = 'camp_marshmallow_burnt', states = { 'marshmallow', 'marshmallow_golden', 'marshmallow_burnt' } },
            camp_sausage = { golden = 'camp_sausage_cooked', burnt = 'camp_sausage_burnt', states = { 'sausage', 'sausage_cooked', 'sausage_cooked' } },
        },
        Anim = { dict = 'amb@prop_human_bbq@male@idle_a', clip = 'idle_b' },
    },
    Recipes = {
        { id = 'fish', station = 'fire', seconds = 90, output = 'camp_grilled_fish', prop = 'fish',
            inputs = { { items = { 'camp_fish', 'rainbow_trout', 'smallmouth_bass', 'largemouth_bass', 'fish' }, count = 1 } } },
        { id = 'meat', station = 'grill', seconds = 75, output = 'camp_grilled_meat',
            inputs = { { items = { 'deer_meat', 'boar_meat', 'rabbit_meat', 'meat' }, count = 1 } } },
        { id = 'breakfast', station = 'grill', seconds = 60, output = 'camp_breakfast', prop = 'skillet', inputs = { { items = { 'camp_breakfast_pack' }, count = 1 } } },
        { id = 'breakfast_stove', station = 'stove', seconds = 60, output = 'camp_breakfast', prop = 'skillet', inputs = { { items = { 'camp_breakfast_pack' }, count = 1 } } },
        { id = 'coffee', station = 'stove', seconds = 45, output = 'camp_coffee', count = 2, prop = 'coffee', inputs = { { items = { 'camp_coffee_grounds' }, count = 1 } } },
        { id = 'stew', station = 'tripod', seconds = 120, output = 'camp_stew', count = 3,
            inputs = { { items = { 'camp_stew_pack', 'deer_meat', 'boar_meat', 'rabbit_meat' }, count = 1 } } },
    },
}

-- Chopping: a log on the block, the axe in hand, a skill check per swing.
Config.Chop = { Swings = { 'easy', 'easy', 'medium' }, Yield = 1,
    Anim = { dict = 'melee@large_wpn@streamed_variations', clip = 'plyr_front_takedown_bat_r_waisthit', ms = 1800 }, -- one swing per passed check
    Stand = 0.9 } -- metres from the block's centre

-- Fine tuning ======================================================================================================
-- Pieces: item, kind, the pack model per state (first state = how it is placed) and GTA models used without the pack.
-- big: seen from further away; radius: the room it takes; over: kinds it may stand on (snaps to their middle); stash/seats/lie/door: what it offers.
-- surface: small pieces may stand on it.

local m = function(name) return 'daddy_camp_' .. name end

Config.Pieces = {
    tent_dome = { item = 'camp_tent_dome', kind = 'tent', big = true, radius = 1.4, states = { 'pitching', 'closed', 'open' },
        models = { closed = m'tent_dome_closed', open = m'tent_dome_open', pitching = m'tent_dome_pitching' }, fallback = 'prop_skid_tent_01',
        stash = { slots = 20, weight = 60000 }, door = true, lie = { vec4(0.0, 0.1, 0.1, 0.0) } },
    tent_cabin = { item = 'camp_tent_cabin', kind = 'tent', big = true, radius = 1.8, states = { 'closed', 'open' },
        models = { closed = m'tent_cabin_closed', open = m'tent_cabin_open' }, fallback = 'prop_skid_tent_03',
        stash = { slots = 30, weight = 100000 }, door = true, lie = { vec4(-0.5, 0.2, 0.1, 0.0), vec4(0.5, 0.2, 0.1, 0.0) } },
    tent_canvas = { item = 'camp_tent_canvas', kind = 'tent', big = true, radius = 1.4, states = { 'closed', 'open' },
        models = { closed = m'tent_canvas_closed', open = m'tent_canvas_open' }, fallback = 'prop_skid_tent_01b',
        stash = { slots = 20, weight = 60000 }, door = true, lie = { vec4(0.0, 0.1, 0.1, 0.0) } },
    sleeping_bag = { item = 'camp_sleeping_bag', kind = 'bag', radius = 0.6, states = { 'open', 'used', 'rolled' },
        models = { open = m'sleeping_bag_open', used = m'sleeping_bag_used', rolled = m'sleeping_bag_rolled' }, fallback = 'prop_skid_sleepbag_1',
        lie = { vec4(0.0, 0.0, 0.05, 0.0) } },
    tarp = { item = 'camp_tarp', kind = 'tarp', big = true, radius = 1.6, models = { default = m'tarp_shelter' }, fallback = 'prop_gazebo_02' },
    hammock = { item = 'camp_hammock', kind = 'hammock', big = true, radius = 1.5, models = { default = m'hammock_stand' }, lie = { vec4(0.0, 0.0, 0.5, 90.0) } },
    fire_pit = { item = 'camp_fire_pit', kind = 'fire', big = true, radius = 0.7, states = { 'empty', 'laid', 'burning', 'embers', 'out' },
        models = { empty = m'fire_pit_empty', laid = m'fire_pit_laid', burning = m'fire_pit_burning', embers = m'fire_pit_embers', out = m'fire_pit_out' },
        fallback = 'h4_prop_h4_firepit_rocks_01a', socket = vec3(0.0, 0.0, 0.15) },
    grill = { item = 'camp_grill', kind = 'grill', radius = 0.4, over = { fire = true }, models = { default = m'fire_grill' },
        sockets = { vec3(-0.13, -0.085, 0.413), vec3(0.13, -0.085, 0.413), vec3(-0.13, 0.085, 0.413), vec3(0.13, 0.085, 0.413) } },
    tripod = { item = 'camp_tripod', kind = 'tripod', big = true, radius = 0.6, over = { fire = true }, states = { 'empty', 'water', 'stew' },
        models = { empty = m'tripod_pot_empty', water = m'tripod_pot_water', stew = m'tripod_pot_stew' } },
    firewood_stack = { item = 'camp_firewood_stack', kind = 'stack', big = true, radius = 0.7, states = { 'full', 'low' },
        models = { full = m'firewood_stack_full', low = m'firewood_stack_low' }, fallback = 'prop_woodpile_01a' },
    chopping_block = { item = 'camp_chopping_block', kind = 'block', radius = 0.45, states = { 'empty', 'log' },
        models = { empty = m'chopping_block_empty', log = m'chopping_block_log' }, fallback = 'prop_log_03', socket = vec3(0.0, 0.0, 0.415) },
    log_bench = { item = 'camp_log_bench', kind = 'seat', big = true, radius = 1.0, models = { default = m'log_bench' }, fallback = 'prop_log_02',
        seats = { vec4(-0.55, 0.05, 0.45, 180.0), vec4(0.0, 0.05, 0.45, 180.0), vec4(0.55, 0.05, 0.45, 180.0) } },
    stump = { item = 'camp_stump', kind = 'seat', radius = 0.35, models = { default = m'stump_seat' }, fallback = 'prop_log_03', seats = { vec4(0.0, 0.0, 0.45, 180.0) } },
    camp_chair = { item = 'camp_chair', kind = 'seat', radius = 0.45, states = { 'open', 'folded' },
        models = { open = m'camp_chair_open', folded = m'camp_chair_folded' }, fallback = 'prop_skid_chair_01', seats = { vec4(0.0, 0.0, 0.45, 180.0) } },
    lantern_hook = { item = 'camp_lantern_hook', kind = 'hook', radius = 0.3, models = { default = m'lantern_hook' }, socket = vec3(0.242, 0.0, 1.577) },
    camp_table = { item = 'camp_table', kind = 'table', big = true, radius = 0.8, surface = true, models = { default = m'camp_table' }, fallback = 'prop_table_03' },
    cooler = { item = 'camp_cooler', kind = 'cooler', radius = 0.5, states = { 'closed', 'open' },
        models = { closed = m'cooler_closed', open = m'cooler_open' }, fallback = 'prop_coolbox_01', surface = true, stash = { slots = 15, weight = 40000 }, door = true },
    stove = { item = 'camp_stove', kind = 'stove', radius = 0.35, states = { 'off', 'on' },
        models = { off = m'camp_stove_off', on = m'camp_stove_on' }, fallback = 'prop_hobo_stove_01', socket = vec3(-0.061, 0.007, 0.12) },
    water_jug = { item = 'camp_water_jug', kind = 'jug', radius = 0.3, models = { default = m'water_jug' } },
    backpack = { item = 'camp_backpack', kind = 'pack', radius = 0.35, models = { default = m'backpack' }, fallback = 'prop_michael_backpack', stash = { slots = 25, weight = 50000 } },
    -- Decor: small = may stand on a surface (table, cooler) without being crowded out
    tent_bag = { item = 'camp_tent_bag', kind = 'decor', radius = 0.3, models = { default = m'tent_bag' } },
    firewood_bundle = { item = 'camp_firewood', kind = 'decor', radius = 0.3, models = { default = m'firewood_bundle' } },
    coffee_pot = { item = 'camp_coffee_pot', kind = 'decor', radius = 0.15, small = true, models = { default = m'coffee_pot' }, fallback = 'prop_kettle_01' },
    skillet = { item = 'camp_skillet', kind = 'decor', radius = 0.2, small = true, models = { default = m'skillet_empty' } },
    mug = { item = 'camp_mug', kind = 'decor', radius = 0.08, small = true, models = { default = m'mug' } },
    canteen = { item = 'camp_canteen', kind = 'decor', radius = 0.12, small = true, models = { default = m'canteen' } },
    -- Held items that can also be set down (hand = held: bone, offset, arm pose while held; light = what it gives when on)
    flashlight = { item = 'camp_flashlight', kind = 'light', radius = 0.2, states = { 'off', 'on' }, hand = { bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, -100.0), anim = { dict = 'amb@world_human_security_shine_torch@male@base', clip = 'base' } },
        models = { off = m'flashlight_off', on = m'flashlight_on' }, fallback = 'prop_cs_police_torch', socket = vec3(0.0, 0.165, 0.0),
        light = { spot = true, color = { 235, 240, 255 }, range = 25.0, intensity = 10.0, radius = 18.0 } },
    torch = { item = 'camp_torch', kind = 'light', radius = 0.2, states = { 'unlit', 'lit', 'burnt' }, burnMinutes = 5, hand = { bone = 28422, pos = vec3(0.0, 0.0, -0.1), rot = vec3(0.0, 0.0, 0.0), anim = { dict = 'amb@world_human_drinking@coffee@male@base', clip = 'base' } },
        models = { unlit = m'torch_unlit', lit = m'torch_lit', burnt = m'torch_burnt' }, socket = vec3(0.0, 0.0, 0.45), rest = vec3(0.0, 0.0, 0.15),
        light = { color = { 255, 130, 50 }, range = 8.0, intensity = 4.0 }, effect = { 'core', 'ent_amb_torch_fire', 0.6 } },
    lantern = { item = 'camp_lantern', kind = 'light', radius = 0.2, states = { 'off', 'on' }, hand = { bone = 28422, pos = vec3(0.11, 0.04, 0.0), rot = vec3(-90.0, 0.0, 90.0), anim = { dict = 'move_weapon@jerrycan@generic', clip = 'idle' } },
        models = { off = m'lantern_off', on = m'lantern_on' }, socket = vec3(0.0, 0.0, -0.176), rest = vec3(0.0, 0.0, 0.29),
        light = { color = { 255, 190, 110 }, range = 7.0, intensity = 3.0 } },
    -- Held only
    axe = { item = 'camp_axe', kind = 'tool', hand = { bone = 28422, pos = vec3(0.0, 0.0, -0.072), rot = vec3(0.0, 0.0, 0.0) }, models = { default = m'camp_axe' }, fallback = 'prop_w_me_hatchet' },
    roast_stick = { item = 'camp_roast_stick', kind = 'tool', states = { 'marshmallow', 'marshmallow_golden', 'marshmallow_burnt', 'sausage', 'sausage_cooked' },
        hand = { bone = 28422, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 180.0) },
        models = { marshmallow = m'roast_stick_marshmallow', marshmallow_golden = m'roast_stick_marshmallow_golden', marshmallow_burnt = m'roast_stick_marshmallow_burnt',
            sausage = m'roast_stick_sausage', sausage_cooked = m'roast_stick_sausage_cooked' } },
}

-- Cooking props shown at a station while a recipe runs (raw, then done).
Config.CookProps = {
    fish = { raw = m'fish_skewer_raw', done = m'fish_skewer_cooked', offset = vec4(0.0, -0.55, 0.0, 180.0) },
    skillet = { raw = m'skillet_empty', done = m'skillet_food', offset = vec4(0.0, 0.0, 0.0, 0.0) },
    coffee = { raw = m'coffee_pot', done = m'coffee_pot', offset = vec4(0.0, 0.0, 0.0, 0.0), fallback = 'prop_kettle_01' },
}

-- Server settings (overrides/daddy_camp/config.lua)
Config.Locale = 'tr'
Config.Debug = true -- dev server: /camphand to fit props in the hand

-- Server settings (servers/daddyrp/daddy_camp/config.lua)
-- DaddyRP: Turkish, no debug, the ranger shop in Cayo Porto, and the hobby gear of other scripts on a Sports shelf.
Config.Locale = 'tr'
Config.Debug = false
Config.Shop.Points = { vec4(4490.1875, -4369.3945, 3.4261, 280.8820) } -- Cayo Porto
Config.Shop.More = { -- BDX-Skate and BDX-Bmx; 0r's own shop no longer sells them
    { item = 'skateboard', price = 1000, cat = 'sport' },
    { item = 'bmx', price = 1000, cat = 'sport' },
}
-- DaddyRP: camps may sit closer to each other (5 m from anyone else's).
Config.Camp.Gap = 5.0
