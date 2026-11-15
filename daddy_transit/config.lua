Config = {}

Config.Locale = 'en' -- en | tr

-- Who may ride: access rules (everyone, job:name:grade, ace:name, cid:id, item:name, role:college:student ...).
Config.Riders = 'role:college:student, role:college:staff'

-- While one of these jobs is on duty, fast travel is closed and the shuttle runs instead. {} keeps it always open.
Config.DriverJobs = { 'school_driver' }

Config.Accounts = { 'cash', 'bank' } -- fares are taken from the first account that holds them
Config.ScholarshipDiscount = false     -- the College scholarship lowers the fare
Config.CooldownSeconds = 10
Config.FadeMs = 800
Config.SourceDistance = 4.0 -- the rider must stand this close to the stop's clerk

-- The ride scene (the view from a bus window); when off, the screen only fades.
Config.Cinematic = {
    Enabled = true,
    MinDurationMs = 5600,
    FailsafeMs = 12000,          -- the scene is ended after this long whatever happens
}

-- Stops (/transitadmin): a clerk stands at each; riders pick a destination from the board there.
Config.Admin = {
    Command = 'transitadmin',
    PlacementReach = 150.0,
    Models = { 'a_m_y_business_01', 'a_f_y_business_02', 'a_m_m_business_01', 's_m_m_gentransport', 's_m_y_airworker' },
    Scenarios = { 'WORLD_HUMAN_CLIPBOARD', 'WORLD_HUMAN_STAND_IMPATIENT', 'WORLD_HUMAN_STAND_MOBILE', 'WORLD_HUMAN_AA_COFFEE' },
    DefaultModel = 'a_m_y_business_01',
    DefaultScenario = 'WORLD_HUMAN_CLIPBOARD',
    -- Pictures a stop can show on the board, in web/dist/images.
    Images = { 'images/destinations/school.webp', 'images/destinations/mall.webp', 'images/destinations/dorm.webp' },
}

Config.Theme = {
    accent = '#D43D45', accentHover = '#C2353D', accentActive = '#A92D35',
    accentSubtle = '#25171B', accentMuted = '#52252B', accentRing = '#E05B62', accentText = '#F08A8F',
}

-- Stops made on first start when no stop has their routeCode: { routeCode, label, coords = vec4, departOnly, price, riders }.
-- departOnly: riders leave from it but it is never a destination. riders: who may ride from it (narrows Config.Riders).
Config.Seeds = {}

-- Server settings (overrides/daddy_transit/config.lua)
-- The server's language.
Config.Locale = 'tr'
-- DaddyRP's shuttle driver job.
Config.DriverJobs = {} -- DaddyRP: şoför yok, hızlı yolculuk her zaman açık
-- DaddyRP: one-way city stop at the Del Perro pier; only students ride from it to the school island.
Config.Seeds = {
    { routeCode = 'SEHIR', label = 'Okul Adası Servisi', coords = vec4(-1857.8973, -1273.8099, 3.0098, 134.1126), departOnly = true, price = 0, riders = 'role:college:student' },
}
