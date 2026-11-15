-- Student shops: a shop placed in /campusadmin with its shelves, tills and stock room nearby. The shop's catalog is
-- edited like a canteen's menu. Self-service: take from the shelves, pay at a self till. Staffed: a cashier rings the
-- basket up at the till and the buyer confirms. Auto: staffed while a cashier is at the till, else self-service.
Config.Shop = {
    Enabled = true,
    AnyTime = true,            -- canteens and shops ignore their open/close hours
    Reach = 3.0,              -- shelf and till distance (server check)
    Area = 15.0,               -- shelves, tills and the stock room belong to the nearest shop within this many metres
    Basket = {
        Model = 'prop_cs_shopping_bag', IdleSeconds = 300, MaxLines = 20,
        Hand = { Bone = 57005, Offset = vec3(0.40, 0.0, -0.02), Rotation = vec3(0.0, -90.0, 75.0) }, -- the bag in hand (set in game)
    },
    Anims = {
        Pick = { Dict = 'mp_common', Name = 'givetake1_a', Ms = 1200 },       -- taking from a shelf
        Pay = { Dict = 'amb@prop_human_atm@male@idle_a', Name = 'idle_b', Ms = 1800 }, -- at a self till
        Scan = { Dict = 'oddjobs@shop_robbery@rob_till', Name = 'loop', Ms = 1500 },   -- a cashier ringing up
    },
    Staff = { RequireDuty = true, CommissionPercent = 10, DailyCap = 2000, PayAccount = 'bank' },
    Restock = { PerCrate = 10, Pay = 25, CrateModel = 'prop_cs_cardbox_01' },
    -- Sale money leaves the economy; to send it to a society, listen to the server event
    -- 'daddy_campuslife:canteenOrder' (source, { id, canteen, total, discount, lines, channel }).
    Models = {                 -- what the panel offers; a spot may also use a model of the map ('point')
        shelves = { 'prop_shelves_01', 'prop_ff_shelves_01', 'prop_vend_fridge01', 'prop_bread_rack_01', 'prop_postcard_rack' },
        tills = { 'prop_till_01', 'prop_till_02' },
        stock = { 'prop_cs_cardbox_01' },
    },
    -- Items a new shop can start with; items your inventory does not have are skipped.
    Starter = {
        { item = 'student_phone', category = 'other', price = 150 },
        { item = 'phone_powerbank', category = 'other', price = 40 },
        { item = 'veba_maske', category = 'other', price = 25 },
        { item = 'student_tablet', category = 'other', price = 100 },
        { item = 'school_notebook', category = 'other', price = 30 },
        { item = 'skateboard', category = 'other', price = 1000 },
        { item = 'party_bottle', category = 'other', price = 50 },
    },
}
