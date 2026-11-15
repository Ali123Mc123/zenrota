tgiCoreExports = exports["tgiann-core"]
config = tgiCoreExports:getConfig()

config.langs = {}

-- Settings live in a few topic files next to this one:
--   config.lua            stores, phone items, payment, saved designs
--   configCatalog.lua     cases, accessories and the letter set with their prices
--   configPlacement.lua   where each kind of accessory sits on the phone, editor camera, phone models in the hand
-- Language and money format come from the tgiann-core config

config.debug = false -- Debug logs in the console (F8/server) + editor lines: where every kind of piece can go and each piece's size

-- Accessory stores: talking to the clerk opens the phone editor
---@type PhoneAccStoresConfig
config.accStores = {
    interaction = "rightMenu", -- "rightMenu" = press E prompt next to the clerk, "target" = target eye on the clerk
    maxDistance = 6.0,         -- Meters: the prompt shows from here (rightMenu)
    pressDistance = 2.0,       -- Meters: the clerk can be used from here
    locations = {
        {
            coords = vector4(-1868.2385, -1320.0457, 3.0673, 336.8376), -- Where the clerk stands (w = heading)
            ped = "a_f_y_hipster_02",                                 -- Clerk model
            scenario = "WORLD_HUMAN_STAND_IMPATIENT",                 -- Idle scenario of the clerk, false = none
            blip = { active = false, sprite = 459, color = 8, scale = 0.7 },
            -- Where the phone floats in the editor (w = heading of the phone), false = inside the player (safest, never in a wall)
            preview = false,
        },
    },
}

-- Phones that can be customized
---@type PhoneAccPhonesConfig
config.accPhones = {
    -- Phone item = case it comes with. That case is free on this phone, every other case is bought
    items = {
        phone = "black",
        black_phone = "black",
        white_phone = "white",
        cream_phone = "peach",
        mint_phone = "mint",
        fuchsia_phone = "hotpink",
        lightgreen_phone = "green",
        orange_phone = "orange",
        rose_phone = "rosegold",
    },
    metadataKey = "phoneDesign", -- Item metadata field that keeps the design id of the phone
    maxPieces = 25,              -- Most accessories on one phone (a word of letters counts as one)
    frameColor = true,           -- The screen frame of the phone script takes the color of the case (tgiann-phone, see client/editable.lua)
}

-- Checkout
---@type PhoneAccPaymentConfig
config.accPayment = {
    accounts = { "cash", "bank" }, -- Money accounts the player can pay with
}

-- Pieces a player owns but does not use (the collection)
---@type PhoneAccCollectionConfig
config.accCollection = {
    sellRate = 0.5,       -- Part of the price paid back when a piece is sold to the store
    sellAccount = "bank", -- Money account the refund goes to
    giftDistance = 5.0,   -- Meters: pieces can be given to players this close
}

config.accSavedDesigns = 12     -- How many designs one character can save
config.accDesignPhotos = true   -- Saved designs get a picture of the phone (stored by tgiann-media-lib: configs/configStorageServer.lua there)
config.accRenderDistance = 50.0 -- Meters: accessories on other players' phones are drawn within this distance
