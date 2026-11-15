-- Settings for the whole resource. Texts are in locales/, the dealerships in config/cfg_locations.lua.
Config = {}

Config.Locale = 'tr'                -- en, tr
Config.Currency = '$%s'             -- money as shown; %s is the amount
Config.NumberLocale = 'tr-TR'       -- thousands separator on the page (tr-TR 1.000, en-US 1,000)
Config.PlateFormat = '1AA111AA'     -- 1 a digit, A a letter, . either; anything else stays as it is
Config.Theme = { Accent = '#ff1f6d' }
Config.AdminAces = { 'command', 'admin' } -- /dealeradmin, every desk and showroom: a player with one of these aces
Config.Debug = false                -- true: the server console says why a player was refused (admin, desk, showroom, sale)
-- Brand logos on the page: an address, %s the brand in lower case without spaces (albany, ubermacht); false for none.
Config.Logos = 'https://raw.githubusercontent.com/GalaxisStudios/vehicle-brand/main/%s.png'

-- Which script does what; 'auto' finds the one that runs (see bridge/).
Config.Bridge = {
    Framework = 'auto',             -- auto, qbx, qb, esx
    Fuel = 'auto',                  -- auto, ox_fuel, savana-fuel, LegacyFuel, ... , none
    Keys = 'auto',                  -- auto, qbx_vehiclekeys, qb-vehiclekeys, ...
    Interact = 'prompt',            -- prompt (the page's own key hint), textui (ox_lib)
    Notify = 'page',                -- page, ox_lib, qb, esx
}

-- The showroom hall the camera goes to (the daddy_showroom resource: its place, bays and camera).
Config.Hall = 'daddy_showroom'

-- The hall as a place: everyone browsing one dealership shares a routing bucket (they hear each other, the street
-- does not), and it is night in there.
Config.Room = {
    Bucket = 7700,                  -- each dealership gets this plus its number; false leaves everyone where they are
    Night = true,                   -- the weather script rests while inside and the clock stands at night
}

Config.Row = {
    Move = 800,                     -- ms the camera takes for one bay
    Sort = 'price',                 -- price, price_desc, name, newest, popular
    NewDays = 7,                    -- cars added in the last days are "new"
    Popular = 3,                    -- the week's best sellers get "best seller"
    Lights = true,                  -- the selected bay's key and rim lights
    Speed = 'kmh',                  -- top speed in kmh or mph
    -- what makes a 10 in the specs: as daddy_garages' Config.Class.Caps, so a car rates the same in both
    Caps = { speed = 50.0, accel = 0.42, braking = 1.6, handling = 3.2 },
    Long = 7.0,                     -- metres: a car longer than this (a bus, a boat) hides its neighbours
}

-- Prices, as jg-dealerships counts them: a car sells at its catalogue price (/dealeradmin); an owned dealership may sell
-- at its own, inside the car's limits. Stock and buying back are shares of the catalogue price. Finance adds its
-- interest; campaigns and coupons come off last.
Config.Prices = {
    ManagerPrices = true,           -- managers of an owned dealership set its own prices at the desk (Stock)
    Discounts = true,               -- bosses run campaigns and coupons at the desk; false: none, running ones stop counting
    DealerPrice = 0.8,              -- an owned dealership pays this share for its stock
    SellBack = 0.6,                 -- a dealership buying a player's car pays this share (its own percent wins); false: no dealership buys
}

-- Buying on instalments, as jg-dealerships counts it: a total with interest, a share of it today, the rest in equal
-- payments taken from the bank every Interval hours (also from an offline player's bank when Offline). A payment that
-- cannot be taken leaves RepoHours before the car is taken back. A dealership offers it when its finance is on.
Config.Finance = {
    Enabled = true,
    -- the plans offered: payments after the down payment, and the interest added to the price; more than one adds a
    -- card each to the purchase's plan step
    Plans = {
        { Payments = 4, Interest = 0.3 },
    },
    DownPayment = 0.5,              -- share of the total paid today
    Interval = 24,                  -- hours between two payments
    RepoHours = 1,                  -- hours after a failed payment before the car is taken back
    MaxPerPlayer = 1,               -- financed cars a player may have at once
    Offline = true,                 -- payments run for offline players too, from their bank in the database
}

-- Test drives: the car waits at the dealership's drive point, in a routing bucket of the driver's own. Where the staff
-- give them (testDrive = 'staff' in cfg_locations.lua), a seller offers one from /araçsat and ends it with /testbitir.
Config.TestDrive = {
    Seconds = 45,                   -- how long a drive lasts
    StaffSeconds = 300,             -- a drive a seller gave lasts at most this long
    Max = 5,                        -- drives at once a dealership
    Plate = 'TEST1111',             -- the test car's plate pattern (as Config.PlateFormat)
    Bucket = 9000,                  -- the driver's bucket is this plus their server id
}

-- An owned dealership's stock orders: delivered at once, paid from its till (Config.Prices.DealerPrice).
Config.Stock = {
    MaxOrder = 20,                  -- cars in one order
}

-- The management desk: its till history, the boss's settings and hiring.
Config.Desk = {
    History = 30,                   -- till movements listed under the till
    MaxCommission = 50,             -- the most a boss may give sellers of a direct sale (Settings), percent
    AskToHire = true,               -- a player offered a job accepts it first (E held); false hires at once
}

-- Display cars in the world (jg's dealership_dispveh): each client makes them itself near them.
Config.Display = {
    Distance = 100.0,               -- metres: nearer than this the cars stand there
    Reach = 6.0,                    -- metres: standing this near one, E opens the showroom on it
    Plate = 'DEALER',
}

-- Ground marker at each dealership's opening spot so players can see where to open the showroom.
Config.Markers = {
    Show = true,
    Distance = 25.0,
}

-- Direct sales (/araçsat): a seller offers the car chosen in the showroom to a player standing near.
Config.DirectSale = {
    Distance = 10.0,                -- metres between the seller and the customer
    Seconds = 30,                   -- how long an offer waits
    Hold = 1500,                    -- ms the customer holds E to sign
}

-- The used-car hall: a car a player sells back stays at that dealership as it stands (paint, mods, dents, mileage) and
-- is sold again in a hall of its own. Damage and mileage take their shares off what the seller gets and off its price.
Config.Used = {
    Enabled = true,                 -- false: a car sold back is deleted (an owned dealership gets one more in stock)
    Price = 0.85,                   -- a used car in perfect shape costs this share of its catalogue price
    Damage = 0.4,                   -- at most this share off for damage (body and engine at 0)
    PerKm = 0.02,                   -- this share off every 1000 km ...
    MaxKm = 0.3,                    -- ... up to this share
    Max = 40,                       -- newest offers a hall shows (each carries its props to the client)
}

-- Car pictures (/carphotos, admins): shot in a dealership's hall, written into images/<model>.webp.
Config.Photos = {
    Command = 'carphotos',
    Hall = 'pdm',                   -- whose hall the pictures are taken in
    Size = { 800, 450 },            -- the picture in pixels (16:9)
    Plate = 'DADDY',                -- the plate the cars carry in the pictures
}

-- Chat commands (jg-dealerships' names, so players keep their habits).
Config.Commands = {
    Finance = 'finans',             -- the player's financed cars
    DirectSale = 'araçsat',         -- staff: offer a car (or a test drive) to a player nearby
    EndDrive = 'testbitir',         -- staff: end the test drives they gave
    Admin = 'dealeradmin',          -- admins: catalogue and dealerships
}

Config.Purchase = {
    Accounts = { 'bank', 'cash' },  -- what a buyer may pay with
    Garage = true,                  -- "send to my garage" (daddy_garages, or jg-advancedgarages)
    Fuel = 100,                     -- fuel of a new car
}

-- Paints offered when buying (the game's palette index); the first chip keeps the car's own colours.
Config.Colours = {
    { key = 'black', index = 0, hex = '#0d0e10' },
    { key = 'graphite', index = 1, hex = '#26282c' },
    { key = 'silver', index = 4, hex = '#9a9ea6' },
    { key = 'white', index = 111, hex = '#eeeeea' },
    { key = 'red', index = 27, hex = '#a3161a' },
    { key = 'wine', index = 34, hex = '#5c1420' },
    { key = 'orange', index = 38, hex = '#d8641c' },
    { key = 'yellow', index = 89, hex = '#e2b822' },
    { key = 'green', index = 50, hex = '#1f4d36' },
    { key = 'blue', index = 64, hex = '#22427e' },
    { key = 'navy', index = 62, hex = '#16233f' },
    { key = 'purple', index = 145, hex = '#4b2a6b' },
}

-- Server settings (servers/daddyrp/daddy_dealerships/config/cfg_main.lua)
-- DaddyRP: debug off (true: the console explains refusals and traces the showroom closing).
Config.Debug = false

Config.Prices.SellBack = false -- DaddyRP: dealerships buy no player cars (second-hand selling closed)
Config.Prices.ManagerPrices = false -- DaddyRP: owners cannot set their own prices; every car sells at its catalogue price
Config.Prices.Discounts = false -- DaddyRP: no campaigns or coupons at the desk; ones already made stop counting
