Config = {}

Config.Framework = 'qbox'      -- DaddyRP. auto | esx | qb | qbox | standalone
Config.Inventory = 'ox'        -- DaddyRP. auto | none | ox | core | qs | codem | tgiann | origen | one | ps | esx | qb
Config.Bank = 'custom'         -- DaddyRP: can9work-funds (bridge/bank/custom.lua). internal | custom (edit bridge/bank/custom.lua)
-- Bills from the register: auto picks daddy_bills, then esx_billing. none hides billing, custom is bridge/billing/custom.lua
Config.Billing = 'auto'        -- auto | daddy_bills | esx_billing | custom | none

-- Modules a server can do without. false hides the screen or tab and the server refuses its actions, nothing else changes.
Config.Features = {
    delivery = true,      -- delivery orders and the courier board
    promos = true,        -- promotions and promo codes at the kiosk
    loyalty = true,       -- loyalty points and rewards
    reviews = true,       -- customers rate their order, rating on the dashboard
    equipment = false,    -- DaddyRP: off. Kitchen equipment that wears and breaks; players bought it thinking it placed a station
    waste = true,         -- waste log
    inspections = true,   -- health inspections and fines
    schedule = true,      -- shift planning
    hiring = true,        -- job postings and applications
    payroll = true,       -- salaries paid from the business account
    performance = true,   -- staff performance
    supplier = false,     -- DaddyRP: off. Supplier orders and quick restock; the ingredients come from players into the depot
    marketplace = true,   -- DaddyRP: the Market tab lists the ingredient listings of daddy-marketplace (view only)
}

-- DaddyRP: the depot of a business is an ox_inventory stash. The ingredient items in it are the stock: a recipe takes
-- whole items out of it (a crate opens into 10 portions, what is left stays as opened stock). Only ingredients go in.
Config.Depot = { slots = 80, weight = 1000000 }
Config.Currency = '$'

-- DaddyRP: ox_doorlock door groups (the names can9work-jobsv2 used) -> place id from the Places tab of /venueadmin.
-- Everyone in the business that holds the place opens those doors (exports.daddy_venue:isPlayerInBusiness).
-- Fill in the id once the place is drawn in /venueadmin; a group left at nil opens nothing.
Config.DoorGroups = {
    -- pierbar = 1,
    -- club77 = 2,
    -- hookies_diner = 3,
    -- ['21_fightclub'] = 4,
    -- yellow_jack_inn = 5,
    -- pond_cafe = 6,
    -- paddockbar = 7,
    -- sho_noodle = 8,
    -- pacificbar = 9,
    -- tequilala = 10,
    -- strip_club = 11,
    -- bahama_mamas = 12,
}
Config.Locale = 'tr'            -- en | tr, texts are in locales/
Config.Languages = { 'en', 'tr' }
Config.VersionCheck = true      -- tells in the console when a newer version is out

Config.AdminAce = 'daddy_venue.admin'
Config.OpenCommand = 'business'   -- the business window from anywhere; money work (Venue.OfficeOnly) only next to the office
Config.AdminCommand = 'venueadmin'   -- DaddyRP: the admin window (places, businesses, presets, layout packs)

Config.ResalePercent = 60      -- percent of the purchase price an owner gets back when giving a bought place up
Config.TransferRange = 5.0      -- the new owner must stand this close
Config.MaxBusinessesPerPlayer = 1
Config.KioskRange = 2.5
-- How players use kiosks, stations, doors and crates:
-- auto (a target system when one runs, otherwise textui) | target (ox_target or qb-target) | textui (ox_lib box) | 3dtext (text above the point) | help (the GTA help box)
Config.Interaction = { Mode = 'auto', Key = 'E', Distance = 1.6 }
Config.Blips = true
-- DaddyRP: every business that holds a place has a map blip at the place's door, named after the business.
-- The icon and colour come from Names (the business or place name, as the old job blips of the server had them),
-- else from the first word of Words found in the name, else Default. Sprites: docs.fivem.net/docs/game-references/blips
Config.VenueBlips = {
    Show = true,
    Scale = 0.75,
    Default = { sprite = 93, color = 46 },          -- cocktail glass
    Names = {
        ['Bean Machine'] = { sprite = 924, color = 56 },
        ['Paddock'] = { sprite = 726, color = 52 },
        ['Pier Bar'] = { sprite = 836, color = 67 },
        ['Tikibar'] = { sprite = 836, color = 46 },
        ['Tiki Bar'] = { sprite = 836, color = 46 },
        ['Sahil Kafe'] = { sprite = 267, color = 47 },
        ['Noir Bar'] = { sprite = 93, color = 40 },
        ['Bowling Cafe'] = { sprite = 739, color = 5 },   -- no bowling icon in the game: the arcade joystick, yellow
        ['UwU Cafe'] = { sprite = 954, color = 19 },
        ['Pond Cafe'] = { sprite = 267, color = 47 },
        ['Hookies Diner'] = { sprite = 96, color = 1 },
        ['Sho Noodle'] = { sprite = 293, color = 59 },
        ['Taco Bomb'] = { sprite = 79, color = 70 },
        ['Yellow Jack Inn'] = { sprite = 827, color = 33 },
    },
    Words = {
        { words = { 'kafe', 'cafe', 'coffee', 'kahve' }, sprite = 267, color = 47 },
        { words = { 'pizza', 'burger', 'diner', 'lokanta', 'restoran', 'restaurant' }, sprite = 96, color = 1 },
        { words = { 'noodle', 'sushi' }, sprite = 293, color = 59 },
        { words = { 'taco', 'bakery', 'fırın', 'pastane' }, sprite = 79, color = 70 },
        { words = { 'tiki' }, sprite = 836, color = 46 },
        { words = { 'bar', 'pub', 'club', 'kulüp' }, sprite = 93, color = 46 },
    },
}
Config.NearbyRange = 5.0
Config.OfferSeconds = 120
Config.MaxStaff = 40
-- Pay limits. Someone without finance.manage (a manager) sets pay only up to ManagerSalary / ManagerCommission and
-- never raises a pay that is already above it; finance.manage (the owner) goes up to MaxSalary / MaxCommission.
Config.Pay = { MaxSalary = 100000, MaxCommission = 100, ManagerSalary = 500, ManagerCommission = 10 }
Config.PayrollDays = 7
Config.TaxDays = 7
Config.DeliveryMinutes = 30
Config.DeliveryLimit = 2
Config.DeliveryArrive = 5.0
Config.InspectionDays = 7
Config.EquipmentMaxLevel = 3
Config.Equipment = { stove = 3000, fryer = 2500, oven = 3500, bar = 2000, coffee = 1800 }
Config.KioskPay = { 'cash', 'bank' }   -- accounts a kiosk order is paid from, in this order
Config.TickMinutes = 10
Config.AuditKeepDays = 30
Config.NoticeKeepDays = 30
Config.SlowTaskMs = 50

Config.MaxTransfer = 1000000
Config.DepositFrom = { 'cash', 'bank' }   -- accounts used in this order when a player puts money in
Config.WithdrawTo = 'bank'

Config.RateLimit = { read = 10, write = 2 }

Config.DefaultHours = { from = '10:00', to = '23:00' }

Config.RentGraceDays = 3   -- days after a missed rent before the business is locked
Config.RentKeepDays = 7    -- days a locked business is kept before it is released

-- Places an admin draws in /venueadmin
Config.Places = {
    PolyMax = 40,        -- corners of one zone
    Height = 6.0,        -- default height of a zone above its highest corner
    PropLimit = 80,      -- default number of placed objects
    Draw = 150.0,        -- the zone view of /venueadmin draws only zones this close
}

-- `stock` multiplies the storage limit of every ingredient. Other upgrades are only recorded for now.
Config.PropertyUpgrades = {
    { id = 'fridge', label = 'Soğuk oda', desc = 'Tüm malzemelerde +%50 depolama', price = 12000, icon = 'fa-snowflake', stock = 1.5 },
    { id = 'kitchen', label = 'İkinci mutfak istasyonu', desc = 'İki aşçı aynı anda çalışabilir', price = 18000, icon = 'fa-fire-burner' },
    { id = 'terrace', label = 'Teras oturma alanı', desc = 'Müşteriler için daha fazla oturma yeri', price = 9500, icon = 'fa-umbrella-beach' },
}

-- What an owner can place inside a place. `use` objects get a marker and open something with E.
-- The models are ordinary GTA props, change them if one looks wrong on your server.
Config.Build = {
    Refund = 50,       -- percent of the price that comes back when an object is removed
    Stream = 80.0,     -- objects appear when you are this close
    CrateMinutes = 60, -- a supplier crate nobody carries in goes into the stock by itself after this long
    FreeDecor = 6,     -- decoration pieces every place gets for free, `free` below is the same per object
    PickExisting = true, -- owners may turn a prop of the map (a counter of the MLO) into the prep counter instead of placing a new one
    Order = { 'office', 'kiosk', 'pickup', 'depot', 'counter', 'sign', 'tv', 'screen' },
    Objects = {
        office = { label = 'Office', icon = 'fa-laptop', group = 'point', model = 'prop_laptop_01a', price = 0, max = 1, use = true },
        kiosk = { label = 'Order kiosk', icon = 'fa-display', group = 'point', model = 'prop_till_01', price = 500, max = 3, free = 1, use = true, public = true }, -- public: customers see its E too, the rest only staff
        depot = { label = 'Storage', icon = 'fa-box', group = 'point', model = 'prop_cs_cardbox_01', price = 0, max = 1, use = true },
        -- DaddyRP: the staff puts the made products in, the customer takes theirs out. Emptied at every resource start.
        -- prop = false: no prop is spawned, only the marker and the E (the model is only the ghost while placing it)
        pickup = { label = 'Pickup counter', icon = 'fa-bell-concierge', group = 'point', model = 'prop_ff_counter_01', price = 0, max = 2, use = true, public = true, prop = false },
        -- DaddyRP: one prep counter makes every product of the menu (food, drinks, desserts); it replaced the stove, fryer,
        -- oven, bar and coffee machine (migration 020 turned those into counters). More counters = more cooks at once.
        counter = { label = 'Prep counter', icon = 'fa-kitchen-set', group = 'station', model = 'prop_ff_counter_01', price = 2500, max = 4, free = 1 },
        sign = { label = 'Sign', icon = 'fa-signature', group = 'display', model = 'prop_tv_flat_01', price = 300, max = 2, free = 1, display = 'sign' },
        tv = { label = 'Promo screen', icon = 'fa-tv', group = 'display', model = 'prop_tv_flat_01', price = 450, max = 3, free = 1, display = 'tv' },
        screen = { label = 'Order screen', icon = 'fa-list-ol', group = 'display', model = 'prop_tv_flat_01', price = 450, max = 2, free = 1, display = 'screen' },
        decor = { label = 'Decoration', icon = 'fa-couch', group = 'decor', model = 'prop_table_03', price = 0, max = 0 },
    },
}

-- Decoration an owner can buy for the place. The price is paid from the business account, Config.Build.Refund comes back on removal.
-- Models are ordinary GTA props, a model that does not exist on your build is reported in the client console.
Config.Decor = {
    { key = 'table_round', label = 'Round table', model = 'prop_table_03', price = 120 },
    { key = 'table_long', label = 'Long table', model = 'prop_table_01', price = 180 },
    { key = 'picnic', label = 'Picnic table', model = 'prop_picnictable_02', price = 220 },
    { key = 'chair', label = 'Chair', model = 'prop_chair_01a', price = 40 },
    { key = 'chair_alt', label = 'Chair (plain)', model = 'prop_chair_01b', price = 40 },
    { key = 'stool', label = 'Bar stool', model = 'prop_bar_stool_01', price = 55 },
    { key = 'bench', label = 'Bench', model = 'prop_bench_01a', price = 90 },
    { key = 'plant', label = 'Indoor plant', model = 'prop_plant_int_03a', price = 70 },
    { key = 'plant_tall', label = 'Tall plant', model = 'prop_plant_int_02a', price = 95 },
    { key = 'parasol', label = 'Parasol', model = 'prop_parasol_01', price = 150 },
    { key = 'bin', label = 'Waste bin', model = 'prop_bin_07a', price = 30 },
    { key = 'fridge', label = 'Fridge', model = 'prop_fridge_03', price = 260 },
}

Config.DecorByKey = {}
for _, item in ipairs(Config.Decor) do Config.DecorByKey[item.key] = item end

-- Signs and screens show a web page on a flat surface in front of the prop. Images come from https addresses
-- whose host is on this list, the owner types them in the build menu. Size and position are in meters from the prop.
Config.Display = {
    Domains = { 'i.imgur.com', 'cdn.discordapp.com', 'media.discordapp.net', 'r2.fivemanage.com' },
    MaxUrls = 3,
    Distance = 15.0,
    Quad = { w = 1.0, h = 0.58, up = 0.55, out = 0.04 },
}
