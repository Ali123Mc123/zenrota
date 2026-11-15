-- Casely: the phone app where players share and sell their phone designs (needs tgiann-phone-lib)
-- Works on tgiann-phone, sd-phone, sky_phone, lb-phone, 17mov_Phone, codem-phone, high-phone, yseries (yphone, yflip-phone), gksphone and cylex_phone

---@type PhoneAccAppConfig
config.accApp = {
    active = true,
    phone = "auto",          -- "auto" = the first running phone of the list above; or one of those resource names
    defaultInstalled = true, -- On the home screen from the start (false = the player installs it from the phone's store)
    price = 0,               -- App store price (phones that sell apps)

    -- The "Open in studio" / "Make a new design" buttons of the app
    --   "anywhere" = the studio opens right where the player stands (the phone closes first)
    --   "store"    = only next to a store clerk; elsewhere the app sets a waypoint to the closest store
    --   false      = no studio buttons in the app, the studio only opens at the store clerk
    studio = false,

    accounts = {
        maxPerCharacter = 3, -- Accounts one character can create
        usernameMin = 3,
        usernameMax = 20,
        passwordMin = 4,
        loginAttempts = 5,     -- Wrong passwords before a short wait
        loginWaitSeconds = 60, -- The wait after too many wrong passwords
    },

    pins = {
        titleMax = 40,
        descriptionMax = 300,
        bioMax = 150,
        commentMax = 300,
        priceMax = 50000, -- Highest price a design can be sold for (0 = free)
        fee = 0.10,       -- Part of every sale the platform keeps (0.10 = 10%)
        cooldown = 20,    -- Seconds between two shared designs
    },

    reportReasons = { -- Reasons players can pick when reporting (lang keys)
        "UI_CASELY_REPORT_SPAM",
        "UI_CASELY_REPORT_STOLEN",
        "UI_CASELY_REPORT_HATE",
        "UI_CASELY_REPORT_OTHER",
    },
}
