Config = {}

Config.Locale = 'en'  -- en | tr | de | fr | es | pt-br | ar
Config.Debug = false  -- F8 traces, F9 page log, debug commands; keep off on a live server

Config.Bridge = {     -- 'auto' finds the running script
    Framework = 'auto',  -- qbx | qb | esx | standalone
    Appearance = 'auto', -- illenium | fivem | qbclothing | skinchanger | native
    Housing = 'auto',    -- comma list (qbx_properties,qb_apartments,qb_houses,ps_housing,esx_property) | none
    Inventory = 'auto',  -- ox | qb | qs | codem | core | tgiann | framework | none
}

Config.Commands = {
    Relog = 'relog',   -- back to the character selection
    Admin = 'mcadmin', -- admin panel (ACE daddy.admin.multichar)
    Editor = 'mcedit', -- scene editor (ACE daddy.admin.multichar)
}

Config.Intro = {
    Enabled = true,
    OnRelog = false,      -- play it again after /relog
    Logo = '',            -- a file in media/ (e.g. 'logo.png'); '' shows Title
    Title = 'LOS SANTOS',
    Awaits = true,        -- 'AWAITS' under Title in the player's language
    Kicker = 'Daddy Roleplay', -- small line over the title
    Season = '',          -- top left label; '' hides it
    Version = 'v3.0',     -- next to it; '' hides it
    Music = '',           -- extra first track: media/ file or '@resource/path.ogg'
    ShowOnline = true,    -- '142 / 256 ONLINE'
    ShowDiscord = true,   -- greet with the Discord name and avatar
}

Config.Theme = {
    Accent = '#c8102e', -- main colour: DaddyRP dark red, the same as daddy_pausemenu (Config.Theme.accent)
    Motion = 'full',    -- full | reduced | off
    Jobs = {            -- job icon and colour; icons: badge, cross, cap, board, wrench, car, briefcase, star, user
        default = { icon = 'user', color = '#e9e9ee' },
        police = { icon = 'badge', color = '#3a6bff' },
        sheriff = { icon = 'badge', color = '#c58b2a' },
        ambulance = { icon = 'cross', color = '#ff4d6d' },
        mechanic = { icon = 'wrench', color = '#ff7a1a' },
        taxi = { icon = 'car', color = '#ffc21a' },
        student = { icon = 'cap', color = '#ffc21a' },
        teacher = { icon = 'board', color = '#18c8f0' },
    },
}

Config.Selection = {
    AllowQuit = true,    -- 'leave server' button
    PlayerScene = true,  -- players may change scene, camera, time and weather
    SkipSingle = false,  -- one playable character goes straight in
    Roles = {            -- scene role by job, else by gang ('*' = any); civilian otherwise
        pd = { jobs = { 'police', 'sheriff', 'bcso', 'sasp', 'lspd', 'state' } },
        ems = { jobs = { 'ambulance', 'ems', 'doctor', 'fire' } },
        mechanic = { jobs = { 'mechanic', 'tow', 'bennys', 'lscustoms' } },
        business = { jobs = { 'realestate', 'cardealer', 'lawyer', 'judge', 'banker' } },
        campus = { jobs = { 'student', 'teacher', 'principal' } },
        racing = { jobs = { 'racer' } },
        gang = { gangs = { '*' } },
    },
}

Config.Cards = {
    Portraits = true, -- card picture from the selection camera
    Fields = { job = true, cash = true, bank = true, phone = true, playtime = true, lastLogin = true, birthdate = true, nationality = true },
}

Config.Identity = {
    MinAge = 18,
    MaxAge = 90,
    DateFormat = 'DMY', -- DMY | MDY | YMD
    BlockedWords = {},  -- names containing these are refused
}

Config.Slots = {
    Base = 2,      -- every account
    Max = 4,       -- locked cards fill up to this
    StoreUrl = '', -- your store page, on locked cards
}

Config.Discord = {
    Invite = 'https://discord.gg/ddroleplay', -- public invite, on locked cards and the whitelist screen
    StaffRoles = {},                          -- role ids for staff slash commands and delete buttons
}

Config.Delete = {
    Mode = 'player',             -- player: a confirm box deletes | request: staff decide | off
    Confirm = 'name',            -- name: type the character's name | click: one press
    MinAgeHours = 24,            -- a character this new cannot be deleted
    CooldownHours = 24,          -- one delete per account in this window
    RetentionDays = 14,          -- restorable this long
    PlayableWhilePending = true, -- request mode: playable while staff decide
}

Config.Deceased = { KeepsSlot = false } -- a deceased character still uses a slot

-- Server settings (overrides/daddy_multichar/config/cfg_main.lua)
Config.Locale = 'tr'
Config.Debug = false

-- Server settings (servers/daddyrp/daddy_multichar/config/cfg_main.lua)
-- DaddyRP has no business or racing scenes.
Config.Selection.Roles.business = nil
Config.Selection.Roles.racing = nil
-- Live: one character slot per account; the others (up to Config.Slots.Max) open by permission: a grant from /mcadmin,
-- a gift code, or a Discord role tier (Config.Slots.Discord.Tiers in sv_config.lua).
Config.Slots.Base = 1
-- DaddyRP's jobs: the selection's role scenes and the card icons by this server's job names.
Config.Selection.Roles.pd = { jobs = { 'police', 'sasp', 'pbsd', 'cppd', 'dp', 'sapr', 'bcso' } }
Config.Selection.Roles.ems = { jobs = { 'ambulance' } }
Config.Selection.Roles.mechanic = { jobs = { 'mekanik1', 'mekanik2', 'mekanik3', 'mekanik4', 'mekanik5', 'mekanik6', 'mekanik7', 'mekanik8', 'illegalmekanik1', 'illegalmekanik2' } }
Config.Selection.Roles.campus = { jobs = { 'ogrenci', 'ogretmen', 'okulmuduru', 'guvenlik', 'kantin', 'servis' } } -- kantin = Kantin ve Temizlik (canteen and janitor)
-- DaddyRP: switching to a character the open scene already suits keeps the scene (only another role changes it).
Config.Selection.KeepScene = true
for _, job in ipairs({ 'police', 'sasp', 'pbsd', 'cppd', 'dp', 'sapr', 'bcso' }) do Config.Theme.Jobs[job] = Config.Theme.Jobs.police end
for i = 1, 8 do Config.Theme.Jobs['mekanik' .. i] = Config.Theme.Jobs.mechanic end
Config.Theme.Jobs.ogrenci = Config.Theme.Jobs.student
Config.Theme.Jobs.ogretmen = Config.Theme.Jobs.teacher
Config.Theme.Jobs.okulmuduru = { icon = 'briefcase', color = '#18c8f0' }
Config.Theme.Jobs.guvenlik = { icon = 'badge', color = '#ffc21a' }
Config.Theme.Jobs.servis = { icon = 'car', color = '#ffc21a' }
Config.Theme.Jobs.kantin = { icon = 'wrench', color = '#3ddc84' }
-- DaddyRP: the first join streams a lot behind the loading screen, so the page gets longer to draw its first screen
-- before the plain ox_lib menus (safemode) take over. A missed first screen is sent once more, so the page has up to
-- twice ReadyMs.
Config.Boot = { NuiMs = 20000, ReadyMs = 20000 }
-- DaddyRP: the plain ox_lib menus never show; a page that does not draw is reloaded until it does.
Config.Safemode = 'reload'
