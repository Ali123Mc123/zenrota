tgiCoreExports = exports["tgiann-core"]
config = tgiCoreExports:getConfig()
config.langs = {}

-- Settings live in topic files next to this one:
--   config.lua           general
--   configCatalog.lua    shapes, lengths, colors, layers and charms
--   configPlacement.lua  how nails sit on the fingers
-- Salons, prices, unlocks, bills, promotions, nail breaking, NPC customer pay / tips / anger, reviews, the trend of
-- the week, manicurist levels and NPC customer models are set in game: /nailsadmin (saved in data/*.json)

config.debug = false -- Prints extra debug information to the console

-- How the admin panel data (salons, prices and other settings, arms, NPC models in data/*.json) reaches a joining player
-- true:  the player gets it from the server on join. Everyone always has the latest data, but every joining
--        player downloads all of it from the server (extra network usage)
-- false: the player reads the data/*.json files that come with the resource. No extra network usage, but those files
--        only reach players on resource start: after an admin panel edit, players who join later see the old data
--        until the script is restarted (players already online always get every edit at once)
config.nailsLoadDataFromServer = false

-- Salon interaction
---@type NailsSalonConfig
config.salons = {
    interaction = "target", -- "target" (ox_target / qb-target) or "drawtext" (press E)
    maxDistance = 6.0, -- Drawtext shows from this distance
    pressDistance = 2.0, -- Drawtext can be used from this distance
    -- Control a customer waiting on a seat stands up with (73 = X), https://docs.fivem.net/docs/game-references/controls/
    standUpControl = 73,
}

-- Manicurist job
---@type NailsJobConfig
config.job = {
    enabled = true, -- Adds the manicurist job flow (do nails on other players)
    names = { "nailart1" }, -- DaddyRP: sadece Nail Art 1 (nailart1) çalışanları tırnak yapar; salon meslek modunda, satın alma yok
    onlyOnDuty = true, -- Manicurist must be on duty
    requireJob = false, -- true: players can't do their own nails at the NPC, a manicurist has to do them
    commission = 30, -- Percent of the price the manicurist gets paid in NPC salons (job / owned salons set their own)
    customerAcceptTime = 30, -- Seconds the customer has to answer a request
    command = "manicure", -- Manicurists use this next to a customer (works with target and drawtext)
    minigame = { enabled = true }, -- The worker paints the nails in a small minigame before they are applied (false = applied at once)
}

-- Payment
---@type NailsPaymentConfig
config.payment = {
    accounts = { "cash", "bank" }, -- Tried in this order
}

-- Studio camera and pose
---@type NailsStudioConfig
config.studio = {
    fov = 32.0, -- Camera field of view
    distance = 0.36, -- Start distance of the camera from one hand (both hands view is further)
    pitch = 62.0, -- Start angle of the camera above the hands (90 = straight down), looking from the manicurist's side
    zoom = { min = 0.05, max = 0.8 },
    -- Sitting pose at the salon seat and in the studio: base = whole body (female / male), upper = arms and hands on top of it.
    -- Both are frozen at phase (0-1 = point of the animation)
    pose = {
        -- the chair pose plays in place (scene poses like timetable@... move the body off the seat)
        base = { dict = "amb@prop_human_seat_chair@male@generic@base", clip = "base", phase = 0.0 },
        baseMale = { dict = "amb@prop_human_seat_chair@male@generic@base", clip = "base", phase = 0.0 },
        upper = { dict = "anim@amb@clubhouse@bar@drink@idle_a", clip = "idle_a_bartender", phase = 0.0 },
        -- Hands of female peds (false = the same as upper). Clips made for male peds (like the bartender above) twist
        -- the female pinky; tgiann_nails_pose (streamed by tgiann-nails-assets) is made on the female skeleton:
        -- palms down, straight fingers. Admins try poses live with config.admin.testCommands.pose
        upperFemale = { dict = "tgiann_nails_pose", clip = "female", phase = 0.0 },
    },
    backdropDistance = 0.35, -- Most metres behind the hands the studio background is drawn (it comes closer so only the hands show)
    orbitSpeed = 200.0, -- Mouse orbit speed
    light = { range = 1.0, intensity = 2.5, color = { 255, 244, 230 } }, -- Soft light on the hand
    photos = true, -- Shows the photo button (stored by tgiann-media-lib: configs/configStorageServer.lua there)
}

-- Drawing the nails on players
---@type NailsRenderConfig
config.render = {
    distance = 20.0, -- Nails are drawn on players closer than this (the models stop drawing at 20 m anyway)
    charmDistance = 10.0, -- 3D charms are added on players closer than this (tiny, unseen further away)
    -- Detail by distance: every nail picture takes a cell of the shared 64 cell atlas, in a crowd the nearest players get them
    fingerDistance = 10.0, -- Closer than this every finger shows its own picture (sets: a different one on each finger)
    lookDistance = 12.0, -- Closer than this every look of the design shows (sets: their first picture); further only the main look
}

-- NPC customers: a worker turns "Take NPC customers" on at the salon NPC (owned salons with a clock in point: on duty).
-- While they are in the salon's work area, NPC customers come in, sit on a free seat and ask for a design. The worker
-- does it in the painting minigame; the salon / job gets paid like a sale, a clean job earns a tip. Needs customer
-- seats in the salon and config.job.minigame enabled. Pay, tips, anger and the ped models: /nailsadmin > NPCs
---@type NailsOrdersConfig
config.orders = {
    enabled = false, -- DaddyRP: NPC müşteri kapalı, tırnak sadece oyunculara yapılır
    interval = { min = 120, max = 300 }, -- Seconds between two NPC customers in one salon
    maxWaiting = 2, -- Most NPC customers waiting in one salon at the same time
    patience = 300, -- Seconds an NPC customer waits before leaving
    minWorkSeconds = 25, -- A job finished faster than this is not paid (the minigame takes longer anyway)
    maxLayers = 2, -- Most layers in an asked design
    maxCharms = 2, -- Most charms in an asked design
}

-- Manicurist levels: every job gives experience (amounts and the tip bonus: /nailsadmin > NPCs)
---@type NailsSkillConfig
config.skill = {
    levels = { 0, 100, 250, 500, 900, 1400, 2000, 2800 }, -- Experience needed for level 1, 2, 3...
}

-- Inventory items (add them to your inventory first: INSTALL/items_tgiann.md, items_ox.md, items_qb.md). Works with every inventory tgiann-core supports;
-- press-on nails keep their design in the item metadata, so they need an inventory with metadata.
-- showOnMenu = sold in the salon shop menu. canCraft = the staff make it in the salon shop; made items go on the shelf,
-- or straight into the maker's inventory when showOnMenu is false. canCraft = false: the item is in neither, so you can
-- sell / craft it with your own shop or craft script
---@type NailsItemsConfig
config.items = {
    -- Fixes the broken nails. On while nails can break (/nailsadmin > Nails can break)
    repairKit = {
        name = "nail_repair_kit",
        seconds = 8,
        showOnMenu = true,
        canCraft = true,
        animation = { animDict = "missheistdockssetup1clipboard@base", anim = "base", flags = 49 }, -- While using it
    },
    -- Takes the nails off
    remover = {
        enabled = true,
        name = "nail_remover",
        seconds = 6,
        showOnMenu = true,
        canCraft = true,
        animation = { animDict = "missheistdockssetup1clipboard@base", anim = "base", flags = 49 },
    },
    -- Bought in the studio as a box (price x priceFactor), put on anywhere later
    pressOn = {
        enabled = true,
        name = "press_on_nails",
        seconds = 10,
        priceFactor = 1.25,
        showOnMenu = true,
        canCraft = true,
        animation = { animDict = "missheistdockssetup1clipboard@base", anim = "base", flags = 49 },
    },
}

-- Salon shop: the salon NPC sells the nail items above (enabled ones with showOnMenu and canCraft).
-- mode "craft": the staff (owned salon members / job salon workers) make the items at the NPC and put them on the shelf;
--   customers buy from the shelf even when nobody works, the maker gets makerShare percent of each sale, the rest goes
--   to the salon money (owned) or the job money. Press-on boxes are made from the salon's catalog designs.
-- mode "direct": every salon's NPC sells the items itself, no making and no stock.
-- Selling the items in your own shops instead: enabled = false, or per item showOnMenu / canCraft in config.items
---@type NailsShopConfig
config.shop = {
    enabled = true,
    mode = "craft", -- "craft" or "direct"
    makerShare = 40, -- Craft mode: percent of the sale price paid to the maker (online: bank, offline: on the next login)
    maxStock = 50, -- Craft mode: most of one item on a salon's shelf (press-on: all designs together)
    maxCraft = 5, -- Most items made in one go
    maxBuy = 10, -- Most items bought in one go
    animation = { animDict = "mini@repair", anim = "fixing_a_ped", flags = 49 }, -- While making items
    -- price = what customers pay (owned salons: the owner picks it between min and max in the management panel)
    -- seconds / cost / materials = making one in craft mode (cost is paid by the maker, materials are inventory items)
    items = {
        repairKit = { price = 200, min = 100, max = 600, seconds = 6, cost = 50, materials = {} },
        remover = { price = 120, min = 60, max = 400, seconds = 5, cost = 30, materials = {} },
        pressOn = { price = 600, min = 300, max = 2000, seconds = 12, cost = 150, materials = {} },
    },
}

-- Designs players save for themselves in the studio (reloaded with one click)
---@type NailsSavedConfig
config.saved = {
    enabled = true,
    max = 20, -- Most saved designs per character
    nameLength = 32, -- Longest design name
}

-- Nail position fix for custom arm clothes. Admins fix each arm in /nailsadmin > Arms > Fix nail position.
---@type NailsFitConfig
config.fit = {
    players = false, -- true: players can also fix their own nails in the studio (everyone sees their fix)
    maxMove = 0.02, -- Furthest a nail can be moved, in metres
    maxRotate = 45.0, -- Most a nail can be turned, in degrees
    maxPlayerArms = 8, -- How many different arms one player can keep a fix for (every player receives these, keep it low)
    -- Nails shown while fixing when the player has none
    sampleDesign = { shape = "square", length = "long", base = "#e84d8a", layers = {}, broken = 0 },
}

-- Salon catalog: owners / workers take a photo of a design in the studio and list it; customers pick from it.
-- The listing fee and the designer's share are set in /nailsadmin > Prices
---@type NailsCatalogConfig
config.catalog = {
    enabled = true,
    maxPerSalon = 60, -- Most designs one salon's catalog can hold
    maxPerAuthor = 12, -- Most designs one designer can have in one salon
    photoValid = 600, -- Seconds a studio photo can still be listed after it was taken
    titleLength = 32, -- Longest design name
}

-- Admin commands
---@type NailsAdminConfig
config.admin = {
    command = "nailsadmin", -- Opens the admin panel (salons, arms, NPCs, prices, breaking, catalog)
    -- Admin test commands (false = off)
    testCommands = {
        worker = "nailsworkertest", -- Try the worker side (painting minigame) on your own hands in the salon you stand in
        order = "nailsorder", -- An NPC customer in the salon you stand in right now ("/nailsorder clear" sends them away); pays nothing
        items = "nailsitems", -- One of each nail item (the press-on box holds the nails you wear)
        breakNails = "nailsbreak", -- Breaks some of your nails: /nailsbreak [count]
        age = "nailsage", -- Makes your set older to test wear: /nailsage [hours]
        pose = "nailspose", -- Sit and try hand poses for the studio (config.studio.pose) with the arrow keys
    },
}
