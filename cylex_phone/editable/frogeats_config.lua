if not Config then Config = {} end
-- =====================================================
-- FROGEATS (food delivery app)
-- Every restaurant is tied to a `job`: its staff, boss and funds come from there.
-- =====================================================
Config.FrogEats = {
    Restaurants = {
        {
            job = "burgershot",
            label = "Burgershot Vespucci",
            logo = "https://assets.cylexdev.com/cylex_phone/icons/company/burgershot.png",
            cover = "",
            category = "burger",
            tags = { "Burger", "Fast Food" },
            location = { 
                name = "Vespucci Blvd", 
                x = 312.9, 
                y = -594.0, 
                z = 43.3 
            },
            min_order = 100,
            delivery_fee = 100,
            -- Which foods the boss may put on this menu (keys from `Foods` below).
            foods = { "cheeseburger", "double_burger", "chicken_burger", "veggie_burger", "fries", "onion_rings", "cola", "milkshake" },
        },
        {
            job = "bennys",
            label = "Benny's Diner",
            logo = "https://assets.cylexdev.com/cylex_phone/icons/company/mechanic.png",
            cover = "",
            category = "diner",
            tags = { "Diner", "Breakfast" },
            location = { 
                name = "Strawberry Ave", 
                x = 265.0, 
                y = -1235.0, 
                z = 29.0 
            },
            min_order = 50,
            delivery_fee = 80,
            foods = { "margherita", "pepperoni", "salad", "sushi_set", "cola", "milkshake", "hotdog", "water" },
        },
    },

    -- "How busy is it right now", from the players standing in the venue.
    Busy = {
        radius = 60.0,      -- metres around `location` that count as being inside
        -- Player count >= value → that level. Below `light` shows as empty.
        thresholds = {
            light  = 2,
            medium = 5,
            high   = 9,
        },
    },

    -- Where item images come from. `%s` = the name written in a food's `image`.
    -- Point this at your inventory resource:
    ItemImage = "https://cfx-nui-cylex_inventory/html/images/%s.png",
    -- ox_inventory: "https://cfx-nui-ox_inventory/web/images/%s.png"
    -- qb-inventory: "https://cfx-nui-qb-inventory/html/images/%s.png"
    -- qs-inventory: "https://cfx-nui-qs-inventory/html/images/%s.png"
    -- codem-inventory: "https://cfx-nui-codem-inventory/html/itemimages/%s.png"

    -- Every food in the game. The key is the id used in a restaurant's `foods` list.
    -- The boss can only pick a category and set the price between min_price and
    -- max_price — name, picture and those bounds are yours alone.
    -- `image`: a full URL is used as-is, a bare name goes through ItemImage above.
    Foods = {
        ["cheeseburger"]   = { label = "Cheeseburger",    image = "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=70", min_price = 50,  max_price = 500, default_price = 100 },
        ["double_burger"]  = { label = "Double Burger",    image = "https://images.unsplash.com/photo-1553979459-d2229ba7433a?w=400&q=70",   min_price = 80,  max_price = 600, default_price = 150 },
        ["chicken_burger"] = { label = "Chicken Burger",   image = "https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=400&q=70", min_price = 50,  max_price = 450, default_price = 120 },
        ["veggie_burger"]  = { label = "Veggie Burger",    image = "https://images.unsplash.com/photo-1520072959219-c595dc870360?w=400&q=70", min_price = 40,  max_price = 400, default_price = 90  },
        ["margherita"]     = { label = "Margherita Pizza", image = "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400&q=70", min_price = 60,  max_price = 500, default_price = 140 },
        ["pepperoni"]      = { label = "Pepperoni Pizza",  image = "https://images.unsplash.com/photo-1628840042765-356cda07504e?w=400&q=70", min_price = 70,  max_price = 550, default_price = 160 },
        ["fries"]          = { label = "Fries",            image = "https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=400&q=70", min_price = 15,  max_price = 120, default_price = 40  },
        ["onion_rings"]    = { label = "Onion Rings",      image = "https://images.unsplash.com/photo-1639024471283-03518883512d?w=400&q=70", min_price = 20,  max_price = 130, default_price = 45  },
        ["cola"]           = { label = "Cola",             image = "https://images.unsplash.com/photo-1554866585-cd94860890b7?w=400&q=70",   min_price = 10,  max_price = 80,  default_price = 25  },
        ["milkshake"]      = { label = "Milkshake",        image = "https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=400&q=70", min_price = 25,  max_price = 150, default_price = 60  },
        ["salad"]          = { label = "Salad",            image = "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=70", min_price = 25,  max_price = 200, default_price = 70  },
        ["sushi_set"]      = { label = "Sushi Platter",    image = "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400&q=70", min_price = 100, max_price = 800, default_price = 250 },

        -- Pictures taken from the inventory instead of a URL
        ["hotdog"]         = { label = "Hotdog",           image = "hotdog",        min_price = 20, max_price = 150, default_price = 45 },
        ["water"]          = { label = "Water",            image = "water_bottle",  min_price = 5,  max_price = 40,  default_price = 12 },
    },

    -- Ordering rules for every restaurant. A restaurant's own `ordering` block wins.
    Ordering = {
        methods = {
            courier = true,   -- an on-duty player delivers it
            npc     = false,  -- NPC courier — not built yet, leave it off
            pickup  = true,   -- the buyer collects it from the restaurant
        },

        -- Falls back to an NPC courier when fewer than `min_on_duty` staff are working
        -- (or always, if you want every delivery handled by an NPC).
        npc_fallback = {
            always      = false,
            min_on_duty = 1,
        },

        npc_eta_seconds = 300,          -- delivery time shown for an NPC courier
        delivery_timeout_seconds = 600, -- undelivered by then → cancelled, money refunded

        -- If the restaurant has had nobody on duty for this long, its waiting orders are
        -- cancelled and refunded instead of holding the buyer's money. 0 turns this off.
        orphan_grace_seconds = 120,

        -- The buyer can move the delivery address to where they are standing, this often:
        location_update_cooldown = 60,
        -- How far from the restaurant the address may be moved, in metres. Orders placed
        -- further out than this may still be moved, but never further away than they
        -- already were. 0 = no limit.
        location_update_radius = 2000.0,

        -- PICKUP: longer deadline, and staff can only hand it over while the buyer is
        -- standing at the restaurant.
        pickup_timeout_seconds = 1200,
        pickup_radius = 20.0,           -- metres from the restaurant's `location`

        -- How the money is split when an order is delivered. NPC and pickup orders have
        -- no human courier, so their share goes to the company.
        payout = {
            courier_percent = 20,
            company_percent = 80,
        },
    },
}

-- Builds a food's picture URL. Keep it outside Config.FrogEats — that table is sent to
-- the phone as JSON and a function inside it would break.
function FrogeatsFoodImage(food)
    local img = food and food.image
    if type(img) ~= "string" or img == "" then return "" end
    if img:find("://", 1, true) then return img end -- http(s):// or nui://
    return (Config.FrogEats.ItemImage or "nui://ox_inventory/web/images/%s.png"):format(img)
end