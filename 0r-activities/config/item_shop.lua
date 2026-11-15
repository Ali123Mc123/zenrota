ActivityItemShopConfig = ActivitySettings.resolve('item_shop', {
    debug = false, -- true: logs for this activity only.
    enabled = true,
    maximumQuantity = 5,
    -- Watching an item before buying: the player stays at the shop, a copy of them rides the item on these routes.
    -- origin is where the ride starts and the direction it faces. The ride goes straight ahead for length metres,
    -- then the screen blinks and it starts again from origin. side picks which side the wide camera stands on
    -- (1 = left of the ride, -1 = right).
    preview = {
        enabled = true,
        debug = false, -- true: preview camera key logs only.
        routes = {
            sea = { origin = vector4(-1603.9380, -1902.1033, 0.2096, 68.2426), water = true, length = 300.0, side = 1 },
            surf = { origin = vector4(-2603.4041, -1612.5765, 0.2232, 121.3317), water = true, length = 350.0, side = 1 },
            land = { origin = vector4(-1064.0638, -1712.1425, 4.5580, 315.8595), length = 120.0, side = 1 },
        },
    },
    npc = {
        model = 'a_m_y_surfer_01',
        coords = vector4(-1855.3621, -1320.7769, 3.0674, 12.2266), -- Shop NPC position and heading.
        interactionRadius = 2.5,
        icon = 'fa-solid fa-basket-shopping',
        blip = {
            enabled = false,
            sprite = 52,
            colour = 3,
            scale = 0.8,
        },
    },
    products = { -- Shop prices. Keep the default item keys here; renamed items are matched automatically.
        {
            item = 'canoe',
            price = 2500,
            preview = { adapter = 'canoe', route = 'sea', speed = 2.6, companion = true, cameraScale = 1.3 },
        },
        {
            item = 'paddleboard',
            price = 2200,
            preview = { adapter = 'surf', route = 'sea', speed = 2.0 },
        },
        {
            item = 'rub_trolley',
            price = 2600,
            -- skipViews: the close camera (view 2) does not suit the walking trolley.
            preview = { adapter = 'utility', route = 'land', speed = 1.4, companion = true, skipViews = { 2 } },
        },
        -- DaddyRP: marketteki hobi esyalari (BDX; onizlemesi yok). Kaykay ve BMX Cayo Porto kamp dukkaninda (daddy_camp).
        {
            item = 'rollers',
            price = 1000,
        },
        {
            item = 'iceskates',
            price = 1000,
        },
        {
            item = 'surfboard',
            price = 5000,
        },
        {
            item = 'slopstyle',
            price = 2000,
        },
        {
            item = 'surfboard_sunset_ray',
            price = 1800,
            preview = { adapter = 'surf', route = 'surf', speed = 4.0, cameraScale = 1.2 },
        },
        {
            item = 'surfboard_sea_drifter',
            price = 1800,
            preview = { adapter = 'surf', route = 'surf', speed = 4.0, cameraScale = 1.2 },
        },
        {
            item = 'surfboard_venice_02',
            price = 1800,
            preview = { adapter = 'surf', route = 'surf', speed = 4.0, cameraScale = 1.2 },
        },
        {
            item = 'surfboard_lifeguard',
            price = 1800,
            preview = { adapter = 'surf', route = 'surf', speed = 4.0, cameraScale = 1.2 },
        },
    },
})
