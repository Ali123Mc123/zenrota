Config = {}

Config.Locale = 'en' -- en | tr | de | fr | es | pl | pt | cs (locales/)
Config.Debug = false -- prints, and /dispatchtest sends sample calls to you

Config.Theme = {
    Accent = '#ff1f6d', -- what is chosen in the settings and the desk, the desk's main button
}

-- Which scripts the bridge talks to; 'auto' finds the one that runs (bridge/*.lua lists them).
Config.Bridge = {
    Framework = 'auto', -- qbx | qb | esx
    Notify = 'page', -- page (the dispatch's own plate) | ox_lib | qb | esx
    Inventory = 'auto', -- ox_inventory | qb-inventory | esx (the phone a citizen call may need)
}

-- Who works the dispatch: job name -> group. Alert types and numbers send to groups (leo, ems, news) or job names.
Config.Jobs = {
    police = 'leo',
    sheriff = 'leo',
    ambulance = 'ems',
}
Config.OnDutyOnly = true -- only players on duty get calls and show as units

-- The dispatch command; '' turns it off. Each action is its own command with no space (/dp + word):
--   /dp                 -> the desk: calls, units, map, history
--   /dpayar             -> each player's own alert settings
--   /dpdurum [status]   -> status picker or toggles busy / available
--   /dp7                -> busy / available toggle (code 7)
--   /dpkod <number>     -> code to every unit (e.g. /dpkod 99)
--   /dpkapat [minutes]  -> pause alert notifications (0: until opened again)
--   /dpac               -> resume alert notifications
--   /dpop               -> operator panel
--   /dpr <no> <reply>   -> answer a citizen call
Config.Command = 'dp'
Config.StatusToggles = true -- true: /dpdurum with no word switches busy / available (as tgiann-policealert did)

-- Default keys; each player changes them in Settings -> Key Bindings -> FiveM. '' leaves the action without a key.
Config.Keys = {
    Join = 'Z', -- join the newest call (on it: leave)
    Mark = 'J', -- its place on the map
    Reply = 'Y', -- answer the newest citizen call
    List = 'O', -- every open call, with the mouse
    Hide = '', -- hide / show the alerts (no key by default: G is taken by many scripts; the settings have a switch)
    Status = 'K', -- my status
    Pause = 'F9', -- pause / open the dispatch
    Panic = '', -- panic (code 99)
    Desk = '', -- the desk
}

-- Units: every player of a dispatch job on duty.
Config.Units = {
    Default = 'busy', -- the status a unit starts with: available | busy
    BusyOnDeath = true, -- dead or down: busy
    OnScene = 40.0, -- metres from a joined call that make a unit "on scene"
    Tick = 3000, -- ms between position, crew and on-scene checks
    Kinds = { 'patrol', 'air', 'sea', 'k9', 'swat', 'motor', 'ems' }, -- what a unit may say it is (air / sea follow the vehicle)
    Callsign = true, -- the framework's callsign (qbx: /callsign); without one the server id
    Display = 'callsign', -- how units are named on the alerts: callsign | name | both
}

-- Badges on the staff list. grade: the job grade a player needs to hand that badge out; max: holders per job.
Config.Badges = {
    { id = 'hc', label = 'HC', grade = 10, max = 2 },
    { id = 'swat', label = 'SWAT', grade = 7, max = 6 },
    { id = 'air', label = 'AIR', grade = 6, max = 4 },
    { id = 'k9', label = 'K9', grade = 4, max = 4 },
}

-- The staff list (the desk's Staff tab and the operator panel): everyone of a job who has been on duty since.
Config.Staff = {
    ManageGrade = 10, -- the grade that may warn, mark the operator, set codes and reset hours (bosses always may)
    MaxWarnings = 3,
    Phone = true, -- the phone number column
    Iban = true, -- the bank account column
    Forget = 30, -- days a member who never came back stays on the list
    -- Hours counted as prime time, per job or default (24 h; the range may pass midnight).
    PrimeTime = { default = { start = 18, finish = 3 } },
}

Config.Calls = {
    Lifetime = 30, -- minutes an open call stays before it closes itself
    KeepDays = 2, -- days closed calls stay in the history
    Max = 60, -- open calls kept at once; past it the oldest closes
    Group = { Radius = 60.0, Seconds = 60, Active = 10 }, -- the same type this close and this soon counts on the first call; Active: the "active" tag from this many
    ExactChance = 20, -- percent of alerts whose place is exact (no fuzz)
    Suggest = 80.0, -- metres: a call this close makes the join key pulse
    Spam = { Count = 6, Seconds = 5, Kick = false }, -- alerts one player may raise in that time; more are dropped (and logged)
    Results = { 'arrest', 'report', 'false', 'handed', 'resolved' }, -- how a call can be closed (locales: results.*)
}

Config.Panic = {
    Track = 60, -- seconds the panic point follows the officer
    Cooldown = 20, -- seconds before the same officer can panic again
    Sound = true, -- everyone hears it at once (their panic sound; players cannot mute it unless unlocked below)
    Near = 12.0, -- metres: players this close hear the officer's radio go off
}

Config.Blips = {
    Show = true,
    Minutes = 3, -- how long a call's blip stays (joined calls keep theirs until left or closed)
    Radius = true, -- a circle where the place is not exact
    Flash = true, -- priority 1 blips flash
}

-- What the caller's client adds to an alert.
Config.Context = {
    Gender = true, -- male / female
    Mask = true, -- "masked"
    Plate = 3, -- characters of a plate shown (8 = all)
    PlateFullChance = 25, -- percent of alerts with the whole plate
    Colour = true, -- the vehicle's colour
    Class = true, -- the vehicle's class (sedan, SUV ...) and doors
    Heading = true, -- which way the vehicle goes (north, south-east ...)
    Weapon = true, -- the weapon's kind (pistol, rifle ...)
}

-- Citizen calls: /911 etc. open a small card (message, anonymous). to: groups or jobs that get it.
Config.Numbers = {
    { number = '911', type = 'call_911', to = { 'leo' } },
    { number = '311', type = 'call_311', to = { 'ems' } },
}
Config.Citizen = {
    Cooldown = 30, -- seconds between two calls of one player
    MaxLength = 200, -- characters of a message
    Anonymous = true, -- callers may hide their name and number
    ReplyLength = 120, -- characters of a unit's answer
    Phone = false, -- item names a caller needs ({ 'phone' }); false: none
    Chat = true, -- the call and the answers also land in the chat, with the call's number (for /r)
}

-- The game's own police scanner reads some calls out (PLAY_POLICE_REPORT). Players can turn it off.
Config.Scanner = {
    Enabled = true,
    -- Alert type -> the game's report. Which reports say what has to be heard in game: /dispatchscanner <name> (Debug).
    Reports = {
        shooting = 'SCRIPTED_SCANNER_REPORT_AR_02_01',
        vehicle_shooting = 'SCRIPTED_SCANNER_REPORT_AR_02_01',
        officer_down = 'SCRIPTED_SCANNER_REPORT_PS_2A_01',
        panic = 'SCRIPTED_SCANNER_REPORT_PS_2A_01',
        bank_robbery = 'SCRIPTED_SCANNER_REPORT_BS_2A_01',
        store_robbery = 'SCRIPTED_SCANNER_REPORT_AH_MUGGING_01',
        reckless_driving = 'SCRIPTED_SCANNER_REPORT_GETAWAY_01',
    },
}

-- The players' own settings: the defaults new players start with, and the ones they cannot change.
Config.Prefs = {
    Defaults = {
        type = 'plate', -- plate | thin | row
        motion = 'slide', -- how an alert comes in: slide | fade | none
        accent = '', -- one of Config.Prefs.Accents; empty: the server's
        place = 'tr', -- tr | tc | tl | r | br | bl, or { x, y } after a drag
        size = 100, -- percent, 80 - 130
        dark = 84, -- percent, the plate's darkness
        life = 3, -- seconds an alert stays (1 - 5)
        max = 3, -- alerts at once; older ones fold into rows
        stay1 = false, -- unused: every alert leaves on its own
        rows = { dir = true, dist = true, suspect = true, weapon = true, vehicle = true, units = true, time = true, map = false },
        volume = 70, -- percent
        mute = false,
        sounds = { p1 = 'siren', p2 = 'chirp', p3 = 'bell', panic = 'alarm' },
        levels = { p1 = 100, p2 = 100, p3 = 100, panic = 100 }, -- percent of the volume per priority
        types = {}, -- per alert type: { off = true } and / or { volume = 0 - 100 }
        gap = 10, -- seconds before the same sound plays again (0: no wait)
        scanner = true, -- the game's police scanner
        duck = true, -- quieter while shooting
        single = true, -- a new sound stops the one playing
        pause = 15, -- minutes the pause key pauses for (0: until opened again)
        panicThrough = true, -- panic still comes while paused
        joinedThrough = true, -- news of a joined call still comes while paused
        prio = 3, -- 1: only priority 1, 2: 1 and 2, 3: all
        kinds = {}, -- kinds turned off: weapons, vehicle, robbery, fight, citizen, ems, officer, other
        km = 0, -- farthest call shown, km (0: any)
        own = false, -- only my department's calls
        autoMark = false, -- a call that close marks itself
        operator = { x = 0.02, y = 0.3, w = 300, h = 360, scale = 100 }, -- where the operator panel sits
    },
    Locks = { 'sounds.panic', 'panicThrough' }, -- dotted names of Defaults players cannot change
    Accents = { '#ff1f6d', '#ff4b4b', '#f0a63a', '#3ecf7a', '#5ea8ff', '#a78bfa', '#f4f4f2' }, -- colours a player can pick
}

-- Sounds a player can pick. synth: drawn by the page (no file); file: a sound in this resource's sounds/ folder.
Config.Sounds = {
    { id = 'siren', synth = 'siren' },
    { id = 'chirp', synth = 'chirp' },
    { id = 'bell', synth = 'bell' },
    { id = 'tone', synth = 'tone' },
    { id = 'pulse', synth = 'pulse' },
    { id = 'alarm', synth = 'alarm' },
    -- { id = 'my_alert', file = 'sounds/my_alert.ogg', label = 'My alert' },
}

-- The desk's heat map: calls of the last hours, counted in square cells.
Config.Heat = {
    Hours = 24,
    Cell = 300.0, -- metres
    Zoom = 1400, -- the radar's zoom while it shows
}

-- A call can carry a radio channel (set on the desk); with Switch, joining it moves pma-voice there.
Config.Radio = {
    Switch = false,
}

-- The desk.
Config.Desk = {
    Groups = { 'leo', 'ems' }, -- who may open it
    PageSize = 20, -- history rows per page
    -- GTA's own radar shown in the desk's map box, the same way as daddy_pausemenu.
    Radar = {
        Enabled = true,
        Zoom = 1100,
        -- How your HUD had the radar, put back afterwards. These are GTA's own (rectangle, bottom left).
        Restore = {
            clip = 0, zoom = 0, bars = 0,
            minimap = { 'L', 'B', -0.0045, 0.002, 0.150, 0.188888 },
            mask = { 'L', 'B', 0.020, 0.032, 0.111, 0.159 },
            blur = { 'L', 'B', -0.03, 0.022, 0.266, 0.237 },
            textures = {},
        },
    },
}

-- Guards for a big server. Every net event has a per-player limit: { actions, per seconds }. Players over their limits
-- this many times in a minute are flooding: logged once a minute (and kicked with Kick).
Config.Security = {
    CallsPerSecond = 15, -- new calls server-wide; past it new alerts are dropped
    Strikes = 40,
    Kick = false,
    Limits = {
        hello = { 4, 10 }, join = { 6, 10 }, status = { 6, 10 }, pause = { 6, 10 }, down = { 3, 10 }, desk = { 4, 10 },
        deskAct = { 15, 10 }, panel = { 4, 10 }, radio = { 4, 10 }, callback = { 10, 10 }, compat = { 6, 5 }, citizen = { 3, 10 },
        reply = { 3, 10 },
    },
}

Config.Compat = {
    QbxPolice = true, -- qbx_police's own alert (police:server:policeAlert) becomes a call
    Radio = true, -- radios that report the officer's channel to cd_dispatch (tgiann-radio-v2) show it on the desk
}

-- Server settings (servers/daddyrp/daddy_dispatch/config/cfg_main.lua)
-- DaddyRP: Turkish; /dp opens the desk; /dpayar, /dp7, /dpdurum, /dpkod, /dpkapat, /dpac, /dpop, /dpr
Config.Locale = 'tr'
Config.Jobs = {
    police = 'leo', sasp = 'leo', sapr = 'leo', bcso = 'leo', pbsd = 'leo', cppd = 'leo', dp = 'leo',
    ambulance = 'ems',
    news = 'news',
}
Config.Command = 'dp'
-- DaddyRP: units send a radio code with /kod <code> (10-13, 99 panic, 0 urgent backup); /dpkod still works. '' turns it off.
Config.CodeCommand = 'kod'
Config.StatusToggles = true
Config.Calls.Spam.Kick = true
Config.Numbers = {
    { number = '911', type = 'call_911', to = { 'leo' } },
    { number = '311', type = 'call_311', to = { 'ems' } },
    { number = '211', type = 'call_211', to = { 'news' } },
}
Config.Units.Default = 'busy'
Config.Badges = {
    { id = 'hc', label = 'HC', grade = 12 },
    { id = 'swat', label = 'SWAT', grade = 7 },
    { id = 'air', label = 'AIR', grade = 6 },
    { id = 'k9', label = 'K9', grade = 4 },
}
-- DaddyRP's radar is GTA's rectangle; its postal map pack sets the zoom to 1200 on start.
Config.Desk.Radar.Restore.zoom = 1200
-- DaddyRP: an alert stays 5 seconds on screen.
Config.Prefs.Defaults.life = 5
