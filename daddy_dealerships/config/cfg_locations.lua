-- The dealerships. The places come from here. The settings start from here and may be changed in game (/dealeradmin,
-- the boss at the desk); then the last change wins: a line changed here takes over at the next start, a setting changed
-- in game at once. A server moving from jg keeps its dealership_locations: what an entry writes wins, the rest stays.
--
-- Places
--   open        where the showroom opens (E), and how near you must stand
--   manage      the management desk (E, staff only)
--   spawn       where a bought car is delivered
--   drive       where a test drive starts; leave it out for no test drives
--   sell        where a player sells their own car back (driven there, E); leave it out for none
--   hall        where the showroom shows its cars: a showroom resource's name (Config.Hall when left out), or a row of
--               its own on the water (a table, the boats below)
--   blip        map marker; false hides it
-- Settings (all may be left out)
--   label       the name
--   type        self-service (anyone buys at catalogue price) | owned (a job runs it; cars sell from its stock)
--   job         the job that works here: direct sales and the management desk
--   categories  catalogue categories shown (dealership_vehicles.category)
--   purchase    false: cars are shown, not sold
--   finance     buying on instalments (Config.Finance)
--   accounts    what a buyer pays from, { 'bank', 'cash' }; Config.Purchase.Accounts when left out
--   commission  a seller's share of a direct sale, in percent
--   colours     the paint a buyer picks: palette (Config.Colours) | free (any colour) | false (the car's own colours)
--   testDrive   self (the buyer drives alone) | staff (an employee starts it for the buyer) | false; self when left out
--   sellBack    the share of the catalogue price paid for a player's car, 0.6; Config.Prices.SellBack when left out,
--               false buys none
--   showroom    who may open the showroom: { jobs = { police = {} }, gangs = { ballas = { 3, 4 } } } (a name and its
--               grades, none for every grade); left out, everyone
--   society     the company tills a buyer may pay from, written as showroom
--   disabled    true closes the dealership for everyone
Config.Dealerships = {
    pdm = {
        label = 'Equez Galeri',
        type = 'owned',
        job = 'cardealer',
        open = { coords = vector3(-56.6051, -1096.9868, 26.4223), size = 2.0 }, -- heading 31.15
        manage = vector3(-31.1169, -1106.4866, 26.4224), -- heading 15.80
        sell = vector3(-30.25, -1110.03, 26.42),
        spawn = vector4(-16.34, -1082.33, 26.25, 238.13),
        drive = vector4(-955.79, -3363.3, 13.52, 56.72),
        finance = true,
        commission = 15,
        colours = 'free',
        categories = { 'sedans', 'compacts', 'motorcycles', 'offroad', 'coupes', 'cycles', 'muscle', 'suvs', 'sportsclassics', 'super', 'sports', 'commercial' },
        blip = { sprite = 523, colour = 0, scale = 0.8 },
    },
    luxury = {
        label = 'Lüks Galeri',
        type = 'owned',
        job = 'cardealer2',
        open = { coords = vector3(-784.21, -212.82, 37.0), size = 2.0 },
        manage = vector3(-779.19, -214.31, 37.0),
        sell = vector3(-781.56, -232.16, 37.04),
        spawn = vector4(-760.08, -232.9, 36.86, 27.74),
        drive = vector4(-955.79, -3363.3, 13.52, 56.72),
        finance = true,
        commission = 7,
        colours = 'free',
        categories = { 'sedans', 'compacts', 'motorcycles', 'offroad', 'coupes', 'cycles', 'muscle', 'suvs', 'sportsclassics', 'super', 'sports', 'commercial' },
        blip = { sprite = 523, colour = 0, scale = 0.8 },
    },
    boats = {
        label = 'Tekne Galerisi',
        type = 'self-service',
        open = { coords = vector3(-1815.1136, -1397.4283, 1.9021), size = 2.0 }, -- heading 229.44
        sell = vector3(-1808.526, -1418.2939, 0.0),
        spawn = vector4(-1808.526, -1418.2939, 0.4, 158.488),
        drive = vector4(-1808.526, -1418.2939, 0.4, 158.488),
        finance = false,
        colours = 'palette',
        categories = { 'boats' },
        blip = { sprite = 371, colour = 0, scale = 0.8 },
        -- the boats float on the marina's water, not in the hall; numbers as daddy_showroom's hall, around position
        hall = {
            position = vector3(-1798.0692, -1411.7394, 0.0), -- the middle bay; z is the water's height
            heading = 50.0,                             -- the way the camera looks (from the sea back at the jetty)
            bays = { -26, -13, 0, 13, 26 },
            bayLine = 0.0,
            rail = -17.0,                               -- metres from the boats to the camera
            carHeading = 135,                           -- a boat's turn against the camera, as a car's in the hall
            camera = { height = 3.0, pitch = -6, fov = 40 },
            reach = { 9.0, 0.8, -5.0, 17.0 },           -- back for longer boats: length at the rail, per metre, nearest, furthest
            long = 12.0,                                -- metres: a boat longer than this hides its neighbours
            scale = 2.0,                                -- the selected bay's lights, twice the hall's
        },
    },
}
