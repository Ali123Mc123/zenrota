-- ═══════════════════════════════════════════════════════════════════════════════
-- Daddy Marketplace - Configuration
--
-- Most servers only need to change: Config.Locale, Config.Locations and Config.BlacklistedItems.
-- Everything else has sensible defaults.
-- ═══════════════════════════════════════════════════════════════════════════════

Config = Config or {}

-- ─────────────────────────────────────────────────────────────────────────────
-- General
-- ─────────────────────────────────────────────────────────────────────────────
Config.Debug = false                    -- Extra console output for troubleshooting
Config.Locale = 'tr'                    -- Language file from /locales: 'en', 'tr', 'de', 'es', 'fr'
Config.Framework = 'auto'               -- 'auto', 'qbx', 'qb', 'esx'
Config.TargetSystem = 'auto'            -- 'auto', 'ox_target', 'qb-target', 'custom', 'none' (falls back to a marker + E key)

-- Used when TargetSystem = 'custom' (runs on the CLIENT). Hook up any interaction resource
-- (sleepless_interact, interact, ...). Call open() when the player interacts with the NPC.
Config.CustomTarget = function(ped, locationId, location, open)
    -- exports.your_interact:AddLocalEntityInteraction({ entity = ped, label = 'Open Marketplace', onSelect = open })
end

Config.Inventory = {
    system = 'auto',                    -- 'auto', 'ox', 'qb', 'ps', 'lj', 'qs', 'codem'
    imageExtension = '.png',
    -- Where item images are loaded from. Change the path if your inventory stores images elsewhere.
    imagePaths = {
        ['ox']      = 'nui://ox_inventory/web/images/',
        ['qb']      = 'nui://qb-inventory/html/images/',
        ['ps']      = 'nui://ps-inventory/html/images/',
        ['lj']      = 'nui://lj-inventory/html/images/',
        ['qs']      = 'nui://qs-inventory/html/images/',
        ['codem']   = 'nui://codem-inventory/html/images/',
        ['default'] = 'nui://qb-inventory/html/images/',
    },
}

Config.Notify = {
    type = 'auto',                      -- 'auto' (ox_lib if running, else framework), 'ox_lib', 'qb', 'esx', 'custom'
    title = 'Pazar Yeri',
    position = 'top-right',             -- ox_lib only
    duration = 5000,                    -- milliseconds

    -- Used when type = 'custom'. Runs on the SERVER.
    custom = function(source, message, notifyType, duration)
        -- TriggerClientEvent('your_notify:show', source, message, notifyType, duration)
    end,
}

Config.UI = {
    enableCommand = false,              -- Allow opening the nearest marketplace with a chat command
    openCommand = 'marketplace',        -- /marketplace (player must still be within Config.Security.maxDistance)
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Locations (each location is its own market with its own listings)
--
--   id (the key)   : unique name, stored with every listing. Don't rename it once players use it.
--   coords/heading : where the NPC or marker is
--   useTarget      : true = interact with the NPC through ox_target / qb-target
--   usePed         : spawn an NPC
--   enabledJobs    : { 'all' } or a list of jobs that may use this market
--   disabledJobs   : jobs that may never use this market (checked first)
--   categories     : { 'all' } or a list of category keys that may be traded here
--   allowedItems   : optional whitelist; when filled, ONLY these items can be traded here
--   props          : optional decoration objects spawned around the market
-- ─────────────────────────────────────────────────────────────────────────────
Config.Locations = {
    ['legion_square'] = {
        label = 'Çiftçi Pazarı',
        coords = vector3(2564.3804, 4673.5332, 34.0768),
        heading = 134.0680,
        radius = 2.0,                   -- target interaction distance (meters)
        useTarget = true,
        usePed = true,
        pedModel = 'mp_m_shopkeep_01',
        pedScenario = 'WORLD_HUMAN_CLIPBOARD',

        blip = {
            enabled = false,
            sprite = 59,
            color = 2,
            scale = 0.8,
            display = 4,
        },

        enabledJobs = { 'all' },
        disabledJobs = {},
        categories = { 'farming' },
        allowedItems = {
            'lettuce', 'tomato', 'potato', 'onion', 'pumpkin',
            'wheat', 'sunflower', 'carrot', 'bottle_milk', 'egg',
        },
        props = {},
    },
}

-- Marker used when no target system is available (or useTarget = false)
Config.Marker = {
    type = 27,
    scale = vector3(1.0, 1.0, 1.0),
    color = { r = 220, g = 38, b = 38, a = 200 },
    bobUpAndDown = false,
    faceCamera = false,
    rotate = true,
    drawDistance = 15.0,
    interactDistance = 2.0,
    interactKey = 38,                   -- E (INPUT_CONTEXT)
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Listings (fixed-price sales)
-- ─────────────────────────────────────────────────────────────────────────────
Config.Marketplace = {
    maxActiveListings = 10,             -- per player
    listingDurationHours = 48,          -- unsold items return to the seller after this; 0 = never expire
    minPrice = 1,                       -- price per unit ($)
    maxPrice = 1000000,                 -- price per unit ($)
    minQuantity = 1,
    maxQuantity = 1000,
    taxPercentage = 0,                  -- % fee taken from the SELLER's payout (buyers pay the listed price)
    listingFeePercent = 0,              -- non-refundable fee when creating a listing, % of price × quantity (0 = free)
    listingFeeMethod = 'bank',          -- account the listing fee is paid from
    canBuyOwnListing = false,
    paymentMethods = { 'cash', 'bank' },-- how buyers can pay
    sellerReceiveMethod = 'bank',       -- 'cash' or 'bank'
    confirmAboveAmount = 5000,          -- ask for an extra confirmation above this total ($); 0 = off
}

-- Restrict how specific items can be paid for (items not listed use paymentMethods above)
Config.ItemPaymentOverrides = {
    -- ['goldbar'] = { 'bank' },
}

-- Allowed price range PER UNIT for specific items (listings, buy orders and auctions).
-- Useful to stop money laundering through fake trades. Leave min or max out for no limit.
Config.ItemPriceLimits = {
    -- ['goldbar'] = { min = 1000, max = 25000 },
    -- ['water_bottle'] = { max = 500 },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Offers (buyers propose a price on a listing)
-- ─────────────────────────────────────────────────────────────────────────────
Config.Offers = {
    enabled = true,
    maxActiveOffers = 5,                -- per player
    expiryHours = 24,
    minOfferPercentage = 50,            -- lowest allowed offer, as % of the asking price
    escrow = true,                      -- hold the offer money until it is accepted/rejected (recommended)
    allowPartialQuantity = true,        -- allow offers for only part of a listing
    checkIntervalSeconds = 60,          -- how often expired offers are refunded
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Auctions
-- ─────────────────────────────────────────────────────────────────────────────
Config.Auction = {
    enabled = true,
    maxActiveAuctions = 3,              -- per player
    minDurationMinutes = 30,
    maxDurationMinutes = 1440,          -- 24 hours
    defaultDurationMinutes = 60,
    minBidIncrement = 100,              -- next bid must be at least current + this ($) ...
    minBidIncrementPercent = 5,         -- ... or current + this %, whichever is higher
    maxBuyoutPrice = 1000000,
    paymentMethod = 'bank',             -- account used for bids and buyouts
    bidPaymentHold = true,              -- true (recommended): bid money is held and refunded when outbid.
                                        -- false: winner pays at the end; if they can't, the item returns to the seller.
    allowCancelWithBids = false,        -- may sellers cancel an auction that already has bids?
    antiSnipeEnabled = true,            -- a bid in the last minutes extends the auction
    antiSnipeMinutes = 2,
    antiSnipeExtendMinutes = 2,
    checkIntervalSeconds = 30,          -- how often ended auctions are settled
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Buy Orders (buyers post "I want to buy X at $Y", sellers fill them)
-- ─────────────────────────────────────────────────────────────────────────────
Config.BuyOrders = {
    enabled = true,
    maxActiveBuyOrders = 5,             -- per player
    durationHours = 48,                 -- unfilled money is refunded after this
    minPricePerUnit = 1,
    maxPricePerUnit = 100000,
    minQuantity = 1,
    maxQuantity = 500,
    taxPercentage = 5,                  -- non-refundable creation fee, % of the order total
    buyerPaymentMethod = 'bank',        -- where the order money is taken from / refunded to
    sellerReceiveMethod = 'bank',       -- where sellers receive their payment
    allowPartialFulfillment = true,     -- sellers may fill only part of an order
    requireItemInInventory = true,      -- buyer must own at least 1 of the item to create an order
    checkIntervalSeconds = 60,          -- how often expired orders are refunded
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Featured (paid highlight at the top of the list)
-- ─────────────────────────────────────────────────────────────────────────────
Config.Featured = {
    enabled = true,
    durations = {
        { hours = 6,  price = 500  },
        { hours = 12, price = 900  },
        { hours = 24, price = 1500 },
        { hours = 48, price = 2500 },
    },
    paymentMethod = 'bank',
    maxFeaturedPerPlayer = 2,
    maxFeaturedPerLocation = 10,
    allowAuctions = true,
    allowRenewal = true,                -- extend while still featured
    bgColor = '#221113',                -- card background of featured items
    bgHoverColor = '#2C1518',
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Items
-- ─────────────────────────────────────────────────────────────────────────────

-- Block every weapon (any item whose name starts with "weapon_", any capitalisation)
Config.BlockWeapons = true

-- Items that can never be traded (not case-sensitive). Add your server's restricted items here.
Config.BlacklistedItems = {
    -- Silahlar
    'weapon_pistol', 'weapon_combatpistol', 'weapon_knife', 'weapon_bat', 'weapon_pistol50',
    'weapon_pumpshotgun', 'weapon_carbinerifle', 'weapon_smg', 'weapon_stungun',
    'weapon_flashlight', 'weapon_nightstick',

    -- Kişisel eşyalar
    'phone', 'id_card', 'driver_license', 'weaponlicense',

    -- Kara para
    'dirty_money', 'markedbills', 'black_money',

    -- Anahtarlar
    'vehiclekeys', 'housekeys',

    -- PD (Polis) Envanteri
    'handcuffs', 'police_badge', 'police_stinger', 'police_baton', 'police_cuff_key',
    'police_cuffs', 'police_tape', 'police_vest', 'police_helmet', 'armor', 'radio',
    'evidence_bag', 'empty_evidence_bag', 'fingerprint_scanner', 'breathalyzer',
    'gsr_kit', 'drugtest_kit', 'bodycam', 'dashcam', 'spike_strip', 'road_flare',
    'traffic_cone', 'barrier', 'ifaks', 'firstaid', 'bandage', 'painkillers',

    -- İllegal / Uyuşturucu & Araçlar
    'oxy', 'meth', 'weed', 'weed_brick', 'coke', 'coke_brick', 'crack', 'crack_brick',
    'joint', 'meth_bag', 'cokebaggy', 'weed_white-widow', 'weed_skunk', 'weed_purple-haze',
    'weed_og-kush', 'weed_amnesia', 'weed_ak47', 'lockpick', 'advancedlockpick',
    'trojan_usb', 'cryptostick', 'laptop', 'tablet', 'electronickit', 'screwdriverset',
    'repairkit', 'casinochips',
}

-- Labels are shown as written here on English servers; other languages use their translation
-- from /locales when one exists (key 'category.<name>').
Config.Categories = {
    ['food']        = { label = 'Food & Drinks', icon = 'fa-utensils'    },
    ['materials']   = { label = 'Materials',     icon = 'fa-cube'        },
    ['tools']       = { label = 'Tools',         icon = 'fa-wrench'      },
    ['electronics'] = { label = 'Electronics',   icon = 'fa-microchip'   },
    ['clothing']    = { label = 'Clothing',      icon = 'fa-shirt'       },
    ['medical']     = { label = 'Medical',       icon = 'fa-kit-medical' },
    ['farming']     = { label = 'Farming',       icon = 'fa-seedling'    },
    ['misc']        = { label = 'Other',         icon = 'fa-box-open'    },
}

-- Item → category. Items not listed here are in 'misc'.
Config.ItemCategories = {
    -- Farming
    ['lettuce']      = 'farming',
    ['tomato']       = 'farming',
    ['potato']       = 'farming',
    ['onion']        = 'farming',
    ['pumpkin']      = 'farming',
    ['wheat']        = 'farming',
    ['sunflower']    = 'farming',
    ['carrot']       = 'farming',
    ['bottle_milk']  = 'farming',
    ['egg']          = 'farming',

    -- Food & drinks
    ['bread']        = 'food',
    ['water_bottle'] = 'food',
    ['sandwich']     = 'food',
    ['coffee']       = 'food',

    -- Materials
    ['wood']         = 'materials',
    ['iron']         = 'materials',
    ['steel']        = 'materials',
    ['plastic']      = 'materials',
    ['copper']       = 'materials',
    ['rubber']       = 'materials',
    ['glass']        = 'materials',
    ['metalscrap']   = 'materials',
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Discord logs
-- ─────────────────────────────────────────────────────────────────────────────
Config.Webhooks = {
    enabled = true,                       -- false turns every Discord log off
    botName = 'Daddy Marketplace',
    default = 'REDACTED_BEFORE_GITHUB_UPLOAD', -- every channel below left empty
    purchase = 'REDACTED_BEFORE_GITHUB_UPLOAD',
    offlinePayment = 'REDACTED_BEFORE_GITHUB_UPLOAD',
    -- listing, bid, auctionEnd, offer, buyOrder, admin = 'url' for their own channels
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Security (advanced — defaults are fine for most servers)
-- ─────────────────────────────────────────────────────────────────────────────
Config.Security = {
    distanceCheck = true,               -- every action requires the player to be near the market they opened
    maxDistance = 10.0,                 -- meters
    rateLimitMs = 1000,                 -- minimum time between two actions of the same player
    maxRateLimitViolations = 5,         -- spam attempts before a temporary block
    rateLimitBlockMinutes = 5,
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Maintenance & integrations (advanced)
-- ─────────────────────────────────────────────────────────────────────────────

-- Finished trades, history, resolved offers and delivered items older than this are
-- removed automatically. Open listings/auctions/orders and owed items are never removed.
-- 0 = keep everything forever.
Config.HistoryRetentionDays = 90

-- Runs on the SERVER whenever the marketplace keeps money as a fee.
--   feeType = 'sale' (seller fee), 'buy_order' (creation fee) or 'featured'
-- Leave empty and the fee simply leaves the economy. Example for a society account:
Config.OnFeeCollected = function(amount, feeType)
    -- exports['qb-banking']:AddMoney('government', amount, 'marketplace-' .. feeType)
end
