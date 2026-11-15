Config = {}

-- General -------------------------------------------------------------------
Config.Debug = false
Config.Currency = '$' -- forwarded to the UI; all money strings localize through this
Config.CurrencyPosition = 'before' -- 'before' ($100) or 'after' (100$)
Config.CurrencySpacing = false     -- add a space between the amount and symbol

-- Branding: change these and the whole UI + every account number follow. Prefix is
-- the short mark on account numbers (e.g. DD-0042-8810); keep it 2-4 characters.
Config.Brand = {
  Name   = 'Daddy Bank',
  Prefix = 'DD',
  Color  = '#ABE23E', -- one-hex reskin for desktop, phone, registration, charts, and default ATM skins
}

-- UI language. 'auto' follows the player's game language. To add any custom language,
-- copy locales/en.json to locales/<code>.json, translate every value, then set that code here.
Config.Locale = 'tr'

-- Economy -------------------------------------------------------------------
Config.CardCreationFee = 180
-- Bank money granted to a brand-new account at first registration (0 = keep current bank money).
Config.StartingBalance = 0

Config.Loan = {
  Enabled = false, -- false hides Loans everywhere and rejects loan operations server-side
  MaxActive = 1,  -- maximum unpaid loans per player; 0 allows unlimited active loans
  minAmount = 1000,
  maxAmount = 100000,
  baseRate = 8.5,            -- annual %, fallback when a plan has no rate
  terms = { 7, 14, 30, 60 }, -- days
}

-- Borrowable loan products (server-validated and displayed directly in the desktop + phone UI).
Config.LoanPlans = {
  quick    = { name = 'Hızlı Nakit', rate = 12.0, minAmount = 500,   maxAmount = 10000,  terms = { 3, 7, 14 } },
  standard = { name = 'Standart',   rate = 8.5,  minAmount = 1000,  maxAmount = 50000,  terms = { 7, 14, 30 } },
  business = { name = 'İşletme',    rate = 6.5,  minAmount = 10000, maxAmount = 150000, terms = { 30, 60, 90 } },
  asset    = { name = 'Konut / Varlık', rate = 4.5, minAmount = 25000, maxAmount = 500000, terms = { 60, 90, 180 } },
}

Config.Savings = {
  defaultRate = 3.0, -- annual %
}

-- PIN (set at first-time setup; gates the ATM) ------------------------------
Config.Pin = {
  length = 4,
  maxAttempts = 5,   -- wrong tries before lockout
  lockMinutes = 5,   -- lockout duration
}

-- ATM -----------------------------------------------------------------------
-- NOTE: RequireCard + GiveCardItem default to FALSE so ATMs work out of the box. To use the
-- physical-card flow you chose: (1) add a `bank_card` item to your inventory's items list
-- (ox_inventory data/items.lua), (2) set RequireCard = true and Config.GiveCardItem = true.
Config.Atm = {
  RequireCard = false,        -- require the card item to use an ATM (see note above)
  CardItem = 'bank_card',     -- inventory item name
  RequirePin = true,          -- prompt for the account PIN at the ATM (DUI stage)
  Models = { 'prop_atm_01', 'prop_atm_02', 'prop_atm_03', 'prop_fleeca_atm' },
  PromptDistance = 1.6,       -- show the "Press E to use the ATM" prompt within this many metres
  DailyWithdraw = 50000,      -- per in-game day, per player
  DailyDeposit = 100000,

  -- Which texture slot on each ATM prop the screen UI replaces, plus the DUI render resolution.
  -- These are the REAL in-game screen textures (taken from a reference ATM), so the UI actually shows
  -- on the prop. The DUI renders at w×h and is mapped 1:1 onto the slot — raise both for a sharper
  -- screen (more VRAM). If a prop still doesn't show, tune live with: /atm_tex <txd> <texture>.
  Textures = {
    ['prop_atm_01']     = { txd = 'prop_atm_01',     tex = 'prop_cashpoint_screen', w = 512,  h = 512  },
    ['prop_atm_02']     = { txd = 'prop_atm_02',     tex = 'prop_cashpoint_screen', w = 512,  h = 512  },
    ['prop_atm_03']     = { txd = 'prop_atm_03',     tex = 'prop_cashpoint_screen', w = 512,  h = 512  },
    -- fleeca slot is the whole-front emissive, so the UI is clipped to just the display sub-rect
    -- (tuned with /atm_adjust screen). The other props are screen-only textures → no `screen` needed.
    -- 1024 so the small screen sub-rect still renders with plenty of pixels (sharper, less cramped).
    ['prop_fleeca_atm'] = { txd = 'prop_fleeca_atm', tex = 'prop_fleece_emis',      w = 1024, h = 1024, screen = { x = 0.005, y = 0.500, w = 0.500, h = 0.465 } },
  },
  -- Fallback DUI resolution when a model has no Textures entry above.
  DuiSize = { w = 512, h = 512 },

  -- Camera framing the ATM screen. Set EnableCamera = false to skip the camera entirely
  -- (the screen still renders on the prop; the player just isn't zoomed in).
  -- Values copied from a reference ATM (proven). `offset` = camera position relative to the prop
  -- (GetOffsetFromEntityInWorldCoords); `rot` = the point-at offset (PointCamAtEntity). Per-model
  -- position overrides live in `offsets`. Tune per server if a specific prop frames slightly off.
  EnableCamera = true,
  Camera = {
    fov = 70.0,
    transition = 1000,
    rot    = vec3(-0.1, 3.739997, -0.7399989),        -- point-at offset (same for every model)
    offset = vec3(-0.09994507, -0.4500122, 1.379971), -- default camera position offset
    offsets = {
      ['prop_atm_01']     = vec3(-0.07, -0.4500122, 1.379971),       -- slightly right
      ['prop_atm_02']     = vec3(-0.09994507, -0.4500122, 1.129971), -- a touch lower
      ['prop_atm_03']     = vec3(-0.09994507, -0.4500122, 1.379971),
      ['prop_fleeca_atm'] = vec3(-0.09994507, -0.4500122, 1.379971),
    },
  },

  -- Mouse interaction: the on-screen cursor moves over the prop UI and clicks buttons (target-free).
  -- This maps the 0..1 screen cursor onto the UI. Defaults to the full screen; only change it if
  -- clicks feel offset (tune live with /atm_cal <x> <y> <w> <h>, then copy the values here).
  Cursor = { x = 0.0, y = 0.0, w = 1.0, h = 1.0 },

  -- ====================================================================================
  --  CUSTOMIZE THE DUI PER ATM. This is the one place to change how the on-prop screen
  --  looks for each ATM model. When an ATM opens, the row matching its prop model (or
  --  `default` if none) is sent to the UI. Add/duplicate rows for any prop you support.
  --    label    = bank name shown in the ATM header
  --    accent   = theme colour (hex) — highlights, the cursor, active buttons recolour to this
  --    subtitle = small line under the title
  -- ====================================================================================
  Skins = {
    default             = { label = 'Daddy Bank',   accent = Config.Brand.Color, subtitle = 'Güvenli ATM' },
    ['prop_fleeca_atm'] = { label = 'Fleeca',       accent = Config.Brand.Color, subtitle = 'Bireysel bankacılık' },
    ['prop_atm_01']     = { label = 'Bank of LS',   accent = Config.Brand.Color, subtitle = 'Güvenli ATM' },
    ['prop_atm_02']     = { label = 'Maze Bank',    accent = Config.Brand.Color, subtitle = 'Nakit işlemleri' },
    ['prop_atm_03']     = { label = 'Pacific Std.', accent = Config.Brand.Color, subtitle = 'Üye hizmetleri' },
  },

  -- Hit-box half-size (in normalized screen units) for the physical buttons below — how close the
  -- cursor must be to a button's projected point to count as hovering it. Bump if buttons feel
  -- hard to hit. (the reference uses ~0.012–0.02.)
  ButtonHitW = 0.013,
  ButtonHitH = 0.018,
  ButtonHitByModel = {
    ['prop_atm_01'] = { w = 0.022, h = 0.024 },
  },

  -- ====================================================================================
  --  PHYSICAL BUTTONS. The on-screen UI is a DISPLAY ONLY — you interact by aiming the cursor
  --  at the prop's real buttons (numpad + side buttons) and clicking, like a real ATM. Each entry
  --  is an invisible clickable zone at an (x,y,z) OFFSET from the prop, with an action:
  --    key:0..9  key:enter  key:back        (the numpad)
  --    menu:withdraw  menu:deposit  menu:balance  menu:history  menu:exit   (the side buttons)
  --  Offsets are seeded from a reference ATM (measured per prop). They won't be pixel-perfect on every
  --  build — fine-tune them live with  /atm_adjust buttons  (markers appear on the prop; drag, then
  --  copy the printed block back here). Models with no entry fall back to `default`.
  -- ====================================================================================
  -- Tuned in-game with /atm_adjust buttons. The fleeca / atm_02 / atm_03 props share the same
  -- counter layout; prop_atm_01 has its own compact-store layout below.
  Buttons = {
    -- prop_fleeca_atm / prop_atm_02 / prop_atm_03 share this counter layout (tuned with /atm_adjust buttons).
    ['prop_fleeca_atm'] = {
      { action = 'key:1', x = -0.155, y = -0.143, z = 1.040 },
      { action = 'key:2', x = -0.130, y = -0.143, z = 1.040 },
      { action = 'key:3', x = -0.105, y = -0.143, z = 1.040 },
      { action = 'key:4', x = -0.168, y = -0.112, z = 0.960 },
      { action = 'key:5', x = -0.137, y = -0.112, z = 0.960 },
      { action = 'key:6', x = -0.107, y = -0.112, z = 0.960 },
      { action = 'key:7', x = -0.167, y = -0.147, z = 0.960 },
      { action = 'key:8', x = -0.137, y = -0.147, z = 0.960 },
      { action = 'key:9', x = -0.107, y = -0.147, z = 0.960 },
      { action = 'key:back',  x = -0.162, y = -0.182, z = 0.960 },
      { action = 'key:0',     x = -0.141, y = -0.155, z = 0.920 },
      { action = 'key:enter', x = -0.107, y = -0.182, z = 0.960 },
      { action = 'menu:withdraw', x = -0.246, y = -0.065, z = 1.230 },
      { action = 'menu:deposit',  x = -0.261, y = -0.030, z = 1.170 },
      { action = 'menu:history',  x =  0.070, y =  0.090, z = 1.110 },
      { action = 'menu:balance',  x =  0.149, y =  0.370, z = 1.060 },
      { action = 'menu:exit',     x = -0.325, y =  0.105, z = 1.040 },
    },
    ['prop_atm_01'] = {
      { action = 'key:1', x = -0.089, y = -0.180, z = 0.890 },
      { action = 'key:2', x = -0.058, y = -0.180, z = 0.890 },
      { action = 'key:3', x = -0.027, y = -0.180, z = 0.890 },
      { action = 'key:4', x = -0.089, y = -0.200, z = 0.870 },
      { action = 'key:5', x = -0.058, y = -0.200, z = 0.870 },
      { action = 'key:6', x = -0.027, y = -0.200, z = 0.870 },
      { action = 'key:7', x = -0.089, y = -0.220, z = 0.855 },
      { action = 'key:8', x = -0.058, y = -0.220, z = 0.855 },
      { action = 'key:9', x = -0.027, y = -0.220, z = 0.855 },
      { action = 'key:back',  x = -0.089, y = -0.243, z = 0.838 },
      { action = 'key:0',     x = -0.058, y = -0.243, z = 0.838 },
      { action = 'key:enter', x = -0.027, y = -0.243, z = 0.838 },
      { action = 'menu:withdraw', x = -0.190, y = -0.110, z = 1.140 },
      { action = 'menu:deposit',  x = -0.190, y = -0.115, z = 1.100 },
      { action = 'menu:history',  x = -0.190, y = -0.122, z = 1.060 },
      { action = 'menu:balance',  x =  0.084, y = -0.110, z = 1.140 },
      { action = 'menu:exit',     x =  0.084, y = -0.115, z = 1.100 },
    },
    ['prop_atm_02'] = {
      { action = 'key:1', x = -0.155, y = -0.143, z = 1.040 },
      { action = 'key:2', x = -0.130, y = -0.143, z = 1.040 },
      { action = 'key:3', x = -0.105, y = -0.143, z = 1.040 },
      { action = 'key:4', x = -0.168, y = -0.112, z = 0.960 },
      { action = 'key:5', x = -0.137, y = -0.112, z = 0.960 },
      { action = 'key:6', x = -0.107, y = -0.112, z = 0.960 },
      { action = 'key:7', x = -0.167, y = -0.147, z = 0.960 },
      { action = 'key:8', x = -0.137, y = -0.147, z = 0.960 },
      { action = 'key:9', x = -0.107, y = -0.147, z = 0.960 },
      { action = 'key:back',  x = -0.162, y = -0.182, z = 0.960 },
      { action = 'key:0',     x = -0.141, y = -0.155, z = 0.920 },
      { action = 'key:enter', x = -0.107, y = -0.182, z = 0.960 },
      { action = 'menu:withdraw', x = -0.246, y = -0.065, z = 1.230 },
      { action = 'menu:deposit',  x = -0.261, y = -0.030, z = 1.170 },
      { action = 'menu:history',  x =  0.070, y =  0.090, z = 1.110 },
      { action = 'menu:balance',  x =  0.149, y =  0.370, z = 1.060 },
      { action = 'menu:exit',     x = -0.325, y =  0.105, z = 1.040 },
    },
    ['prop_atm_03'] = {
      { action = 'key:1', x = -0.155, y = -0.153, z = 1.040 },
      { action = 'key:2', x = -0.130, y = -0.153, z = 1.040 },
      { action = 'key:3', x = -0.105, y = -0.153, z = 1.040 },
      { action = 'key:4', x = -0.168, y = -0.122, z = 0.960 },
      { action = 'key:5', x = -0.137, y = -0.122, z = 0.960 },
      { action = 'key:6', x = -0.107, y = -0.122, z = 0.960 },
      { action = 'key:7', x = -0.167, y = -0.162, z = 0.960 },
      { action = 'key:8', x = -0.137, y = -0.162, z = 0.960 },
      { action = 'key:9', x = -0.107, y = -0.162, z = 0.960 },
      { action = 'key:back',  x = -0.162, y = -0.202, z = 0.960 },
      { action = 'key:0',     x = -0.141, y = -0.175, z = 0.920 },
      { action = 'key:enter', x = -0.107, y = -0.197, z = 0.960 },
      { action = 'menu:withdraw', x = -0.261, y = -0.055, z = 1.230 },
      { action = 'menu:deposit',  x = -0.271, y = -0.045, z = 1.170 },
      { action = 'menu:history',  x =  0.070, y =  0.070, z = 1.110 },
      { action = 'menu:balance',  x =  0.174, y =  0.390, z = 1.060 },
      { action = 'menu:exit',     x = -0.325, y =  0.070, z = 1.040 },
    },
  },
}

-- On-screen position (0..1 of the display) of each menu option's label, per prop. Leave a prop out
-- to use the defaults (options hug the left/right edge, spread by order). Tune live with
-- /atm_adjust options, then paste the printed block here.
Config.Atm.OptionLayout = {
  ['prop_fleeca_atm'] = {
    withdraw = { x = 0.000, y = 0.380 },
    deposit  = { x = 0.000, y = 0.710 },
    exit     = { x = 0.000, y = 1.000 },
    balance  = { x = 1.000, y = 0.410 },
    history  = { x = 1.000, y = 0.720 },
  },
}

-- All button actions the /atm_adjust buttons editor can assign (also the on-screen menu options).
Config.AtmButtonActions = {
  'key:1', 'key:2', 'key:3', 'key:4', 'key:5', 'key:6', 'key:7', 'key:8', 'key:9', 'key:0',
  'key:enter', 'key:back',
  'menu:withdraw', 'menu:deposit', 'menu:balance', 'menu:history', 'menu:exit',
}

-- How close (metres) the player must be to a bank location to get the "access banking" prompt.
Config.BankPromptDistance = 2.0

-- Whether buying a card in the UI also issues its physical inventory item (per-tier item from
-- Config.Cards.Tiers[design].item — card_black / card_gold / card_silver, registered in
-- ox_inventory/data/items.lua and shipped with this resource's generated icons).
Config.GiveCardItem = false -- DaddyRP: bankada kart çıkarınca envantere item verilmez

-- Bank locations — blips + "Open Banking" targets are created at each (client/cl_world.lua).
-- Covers every in-world bank: Pacific Standard + all Fleeca branches across the map.
Config.Locations = {
  { label = 'Pacific Standard Bank',    coords = vec3(246.8448, 224.3718, 107.3325), heading = 340.0 },
  { label = 'Fleeca - Legion Square',   coords = vec3(151.1486, -1043.8873, 30.7191), heading = 339.0 },
  { label = 'Fleeca - Burton',          coords = vec3(-1209.4463, -332.0887, 39.0427), heading = 297.0 },
  { label = 'Fleeca - Hawick',          coords = vec3(315.4570, -282.1697, 55.3652), heading = 339.0 },
  { label = 'Fleeca - Del Perro',       coords = vec3(-349.9258, -52.8778, 50.2376), heading = 339.0 },
  { label = 'Fleeca - Great Ocean Hwy', coords = vec3(-2960.0557, 484.9632, 16.9252), heading = 88.0 },
  { label = 'Fleeca - Route 68',        coords = vec3(1172.8721, 2709.3967, 39.3646), heading = 178.0 },
  { label = 'Fleeca - Paleto Bay',      coords = vec3(-112.9292, 6470.2612, 32.5751), heading = 134.0 },
  { label = 'Fleeca - Kolej',           coords = vec3(5322.2250, -5251.1570, 32.2310), heading = 324.57 }, -- Cayo campus school, at the College ATM
}

-- Phone app (Phase 3) -------------------------------------------------------
Config.Phone = {
  Enabled = false,
  AppName = 'Daddy Bank',
  AppDescription = 'Bankacılık: hesaplar, kartlar, transferler ve dahası',
  Page = 'web/build/phone.html',
  Icon = 'web/icon.png',

  -- Standalone phone: a floating Daddy Bank phone (bottom-right, no backdrop) you can open
  -- WITHOUT any host phone resource. Toggle with the command below and/or a keybind.
  --   Command : chat command that toggles it (e.g. /bankphone).
  --   Key     : default key for the bind (rebindable in Settings → Key Bindings → FiveM).
  --             Leave '' (empty) to make it COMMAND-ONLY — no keybind is registered.
  Command = 'bankphone',
  Key = '', -- e.g. 'F6' or 'HOME'; '' = command only


  Phones = {
    ['17mov_Phone']   = true,
    ['lb-phone']      = true,
    ['qs-smartphone'] = true,
    ['qs-smartphone-pro'] = true,
    ['gksphone']      = true,
    ['qb-phone']      = true,
    ['high-phone']    = true,
    ['roadphone']     = true,
    ['sixphone']      = true,
    ['kazer-phone']   = true,
    ['inferno-os']    = true,
    ['yflip-phone']   = true,
    ['codem-phone']   = true, -- CodeM mPhone 2.0
  },
}

-- ===========================================================================
--  CARD TIERS (Phase 4). Creating a card of a given tier charges its `price`
--  from the bank balance and (if Config.GiveCardItem) issues its inventory item.
--  The BLACK tier unlocks the Stock Market phone app. Perks below are shown in
--  the UI. Add the item names to your inventory (ox_inventory data/items.lua)
--  and drop the generated PNGs into ox_inventory/web/images/.
-- ===========================================================================
Config.Cards = {
  Order = { 'black', 'gold', 'silver' }, -- premium first (display order)
  Tiers = {
    black = {
      label  = 'Black',
      price  = 25000,
      item   = 'card_black',
      color  = '#0B0B0D',
      accent = '#ABE23E',
      stocks = true, -- unlocks the Stock Market app
      perks  = {
        'Borsa erişimi',
        "ATM'den ücretsiz para çekme",
        '+%2,0 birikim faizi',
        'Öncelikli müşteri hizmeti',
      },
    },
    gold = {
      label  = 'Altın',
      price  = 8000,
      item   = 'card_gold',
      color  = '#7A5A12',
      accent = '#F2C14E',
      stocks = false,
      perks  = {
        'Daha yüksek transfer limitleri',
        '+%1,0 birikim faizi',
        'İndirimli ATM ücretleri',
      },
    },
    silver = {
      label  = 'Gümüş',
      price  = 2500,
      item   = 'card_silver',
      color  = '#6B7077',
      accent = '#C9D2DA',
      stocks = false,
      perks  = {
        'Günlük bankacılık',
        'Temassız ödeme',
      },
    },
  },
}

-- ===========================================================================
--  STOCK MARKET (Phase 4) — simulated prices (base + bounded random walk each
--  tick). Trading is gated to BLACK card holders. Prices live in server memory.
-- ===========================================================================
Config.Stocks = {
  Enabled     = false,
  TickSeconds = 30,  -- price-update interval
  TradeFeePct = 0.5, -- % fee charged on every buy and sell
  Symbols = {
    { symbol = 'MAZE',  name = 'Maze Bank',        price = 248.50, volatility = 0.020 },
    { symbol = 'FLCA',  name = 'Fleeca Financial',  price = 120.00, volatility = 0.015 },
    { symbol = 'BILK',  name = 'Bilkington',        price = 410.75, volatility = 0.030 },
    { symbol = 'LIFE',  name = 'Lifeinvader',       price = 32.10,  volatility = 0.045 },
    { symbol = 'VAPID', name = 'Vapid Motors',      price = 76.20,  volatility = 0.025 },
    { symbol = 'TINK',  name = 'Tinkle',            price = 18.40,  volatility = 0.050 },
    { symbol = 'AUGY',  name = 'Augury Insurance',  price = 205.30, volatility = 0.020 },
    { symbol = 'PISW',  name = 'Pisswasser',        price =  9.85,  volatility = 0.060 },
  },
}

-- ===========================================================================
--  INVOICES (Phase 4) — bill another nearby player; they receive the invoice in
--  the phone app and pay it (money moves payer -> issuer's bank).
-- ===========================================================================
Config.Invoices = {
  Enabled   = false,
  MaxAmount = 1000000,

  -- Server-created invoices may route payment to one of these immutable,
  -- allowlisted recipients. Never accept raw account names from a client.
  SocietyRecipients = {
    -- mechanic = {
    --   label = 'Mechanic Society',
    --   provider = 'esx_addonaccount',
    --   account = 'society_mechanic',
    -- },
  },
}

Config.Bills = {
  Enabled = true,
  -- DaddyRP: 'daddy_bills' lists and pays the bills of daddy_bills (server/sv_daddy_bills.lua), nil uses nn_bills
  Source = 'daddy_bills',
}

-- How close (metres) another player must be to appear in the "nearby" picker for
-- sending money / billing an invoice (the server re-validates this distance).
Config.NearbyMaxDistance = 6.0

-- Bank and ATM interaction provider: 'auto', 'ox_target', 'qb-target', or 'prompt'.
-- Auto prefers ox_target, then qb-target, and finally the built-in Press E prompt.
Config.TargetSystem = 'auto'

-- Legacy setting for configurations copied from releases before TargetSystem was added.
-- It is used only when Config.TargetSystem is absent.
Config.UseOxTarget = true

-- Profile avatars: use each player's in-game ped headshot (mugshot) as their avatar in the bank
-- profile + the nearby-player transfer list. Falls back to first-letter initials when disabled or
-- when MugShotBase64 / screenshot-basic aren't running. (Both are required for ped shots.)
Config.Avatar = {
  UsePedShot  = true,
  Transparent = true, -- transparent-background cutout headshot
}

-- ===========================================================================
--  MULTIPLE ACCOUNTS (Phase 5). A player can open extra accounts beyond their
--  primary, each with its own account number + balance (personal or business).
--  The primary account mirrors framework bank money; every other account's
--  balance is stored and managed by nn_banking.
-- ===========================================================================
Config.Accounts = {
  Max          = 4,                          -- max accounts a player can OWN (incl. primary)
  CreationFee  = 0,                          -- charged from the primary on opening a new account
  AllowedTypes = { 'personal', 'business' }, -- types a player can open
}

-- Server-only account access for trusted integrations such as a DOJ MDT.
-- Every privileged export checks GetInvokingResource(); client calls and resources
-- not explicitly listed here are rejected.
Config.PrivilegedIntegrations = {
  Resources = {
    ['p_dojmdt'] = true,
  },
}

-- ===========================================================================
--  BUSINESS ACCOUNTS — members + permissions, and the ability to place ATMs in
--  the world for a price (gizmo placement). Manage it all in the Settings tab.
-- ===========================================================================
Config.Business = {
  Enabled            = true,    -- false disables new business accounts and player-placed ATMs
  CreationFee        = 0,       -- charged from the primary to open a business account
  AtmPrice           = 75000,   -- charged from the business account to place one ATM
  MaxAtmsPerBusiness = 3,
  AllowedModels      = { 'prop_atm_01', 'prop_atm_02', 'prop_atm_03', 'prop_fleeca_atm' }, -- MUST be a subset of Config.Atm.Models
  PlaceCommand       = 'placeatm',
  RemoveCommand      = 'removeatm',
  SpawnRadius        = 150.0,   -- spawn placed ATM props within this distance
  DespawnRadius      = 175.0,   -- and despawn past this (hysteresis)
  MinSpacing         = 5.0,     -- min distance between two placed ATMs
  MinFromBank        = 8.0,     -- min distance from a Config.Locations bank
  Refundable         = false,
  RefundPct          = 0.5,
  -- Placement gizmo feel.
  Place = { Distance = 2.0, MinDistance = 0.8, MaxDistance = 6.0, DistanceStep = 0.10, RotateStep = 2.0, SnapToGround = true },
}


Config.Cheques = {
  Enabled = false,
  Item = 'bank_cheque',
  BookItem = 'bank_chequebook',
  BookLeaves = 20,
  MaxAmount = 100000,
  ExpiryDays = 14,
  AllowAtm = false,
  AtmLocations = {},
  Forgery = {
    Enabled = false,
    EquipmentItem = 'cheque_printer',
    BudgetAccount = '',
    DailyBudget = 25000,
    VerificationMinutes = 30,
    Workbenches = {},
    QualityNames = { 'basic', 'advanced' },
    Qualities = {
      basic = { MaxAmount = 2500, DetectionChance = 0.75, FinalDetectionChance = 0.85, Materials = { cheque_paper = 1, cheque_ink = 1 } },
      advanced = { MaxAmount = 5000, DetectionChance = 0.35, FinalDetectionChance = 0.65, Materials = { cheque_paper = 2, cheque_ink = 3 } },
    },
  },
}

Config.Investigations = {
  Enabled = false,
  Jobs = { police = 14, sasp = 14, pbsd = 14, cppd = 14, dp = 14, bcso = 14, sapr = 16 },         -- leo: Commander ve üstü soruşturma açar
  Supervisors = { police = 15, sasp = 15, pbsd = 15, cppd = 15, dp = 15, bcso = 15, sapr = 17, judge = 0 }, -- Assistant Chief/Sheriff ve üstü onaylar
  RequireDuty = true,
  OfficerAce = 'nn_banking.investigate',
  SupervisorAce = 'nn_banking.supervise',
  RequireWarrants = true,
  MaxWarrantHours = 168,
  MaxHoldHours = 168,
  EvidenceAccount = '',
  Patterns = { WindowMinutes = 10, LargeAmount = 50000, Count = 4 },
}
