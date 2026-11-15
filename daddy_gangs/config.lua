Config = {}

Config.Framework = 'auto'      -- auto | esx | qb | qbox | standalone
Config.Stash = 'auto'          -- auto | ox | qb | qs | custom (bridge/stash/custom.lua) | none
Config.Bank = 'custom'         -- DaddyRP: can9work-funds (bridge/bank/custom.lua). internal (the vault lives in our own table) | custom
Config.Locale = 'tr'           -- en | tr
Config.Currency = '$'
Config.VersionCheck = true     -- tells in the console when a newer version is out

Config.AdminAce = 'daddy_gangs.admin'
Config.AdminGroups = { 'admin', 'superadmin', 'god' }

-- How the gang menu opens. Each one on its own; the vault and the stash only work next to a point (Config.Points).
Config.Access = {
    Npc = true,                -- a ped at every Config.Points entry, opened with a target system (or E when none runs)
    Command = 'gangmenu',     -- 'gang' or false
    Item = false,              -- a usable item name (install/items.txt) or false
    AdminCommand = 'gangadmin',
}
Config.Points = {
    { coords = vec4(539.41, -1946.55, 24.98, 304.13), model = 'a_m_m_business_01', blip = false },
}
Config.Interaction = { Distance = 2.0, Key = 'E' }

-- Who may never be in a gang: job names, or job types where the framework has them (leo, ems on Qbox)
Config.Blacklist = {
    Jobs = {},
    JobTypes = { 'leo', 'ems' },
}

Config.Gang = {
    CreatePrice = 5000,        -- paid by the founder, from cash then bank
    CreateFrom = { 'cash', 'bank' },
    NameLength = { 3, 24 },
    TagLength = { 2, 5 },
    InviteRange = 4.0,
    InviteMinutes = 10,        -- an invite nobody answers goes away
    ActiveMembers = 10,        -- every feature opens at this many members
    KeepMembers = 15,          -- this many members within KeepDays of founding, or the gang is closed
    KeepDays = 3,
    -- a closed gang: the vault goes back to the leader, the stash is emptied
    RefundVault = true,
}

Config.Xp = {
    EveryMinutes = 60,         -- an active gang earns PerOnline xp for each member in the city this often
    PerOnline = 10,
}

Config.Diplomacy = {
    MeetingHours = 24,         -- a meeting request nobody answers expires
    OutcomeDays = 7,           -- after an accepted meeting the gangs have this long to choose peace or war
    PeaceNoWarHours = 24,      -- after peace neither side may ask for war for this long
}

Config.War = {
    -- what the gangs get when an admin ends a war
    Rewards = {
        winner = { xp = 2000, score = 100 },
        loser = { xp = 250, score = -50 },
        draw = { xp = 500, score = 0 },
    },
    KillRange = 500.0,         -- a death only counts when the killer stood this close (checked on the server)
}

Config.Chat = { Keep = 200, MaxLength = 300 }
Config.Announcements = { Keep = 30, MaxLength = 600 }
Config.LogKeepDays = 60

-- Discord: url gets every gang event, admin only the ones admins should see (closed gangs, war requests)
Config.Webhooks = {
    url = '',
    admin = '',
}

Config.RateLimit = { read = 10, write = 3 }

-- Logos come from https addresses on these hosts
Config.LogoHosts = { 'i.imgur.com', 'cdn.discordapp.com', 'media.discordapp.net', 'r2.fivemanage.com' }

-- The map screen: GTA V map tiles (256 px, <Cdn>/<style>/<z>/<x>/<y>.jpg) from a CDN, laid in game coordinates.
-- Cdn: a public GitHub repository through jsDelivr (cdn.jsdelivr.net/gh/<owner>/<repo>@<tag>) or any https host.
-- Styles: the ones a player picks from; tiles = the folder on the CDN, maxZoom = its deepest zoom folder,
-- filter = a CSS filter laid over the tiles (a dark look from the same atlas, no extra files), label = the button's
-- text for a style of your own (the built-in ones are named in the locales: map.styles.<id>).
Config.Map = {
    Cdn = 'https://cdn.jsdelivr.net/gh/can9work/daddy_gang_maps@main',
    Default = 'atlas',
    Styles = {
        { id = 'atlas', tiles = 'atlas', maxZoom = 5 },
        { id = 'satellite', tiles = 'satellite', maxZoom = 4 },
        { id = 'dark', tiles = 'atlas', maxZoom = 5, filter = 'invert(1) hue-rotate(180deg) brightness(.85) contrast(.9)' },
    },
}
