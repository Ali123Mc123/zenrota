Config = {}

Config.Locale = 'en' -- en | tr
Config.Debug = false

-- The phone opens only with this item: using it, or the phone key while it is in the inventory.
Config.Item = 'student_phone'
Config.Key = 'M' -- the phone's own key: opens and puts it away (players can rebind it in the game's key settings)

Config.Session = { TimeoutMs = 90000, HeartbeatMs = 30000 }

-- Where the phone sits on screen and how tall it is (share of the screen height). Banners: where notifications show while
-- the phone is away, 'corner' (beside the phone) or 'center' (the bottom middle of the screen).
Config.Screen = { Side = 'right', Height = 0.74, Margin = 0.03, Banners = 'corner' }

-- The phone goes away (and stays in the pocket) while the player is down, cuffed or swimming; dead always.
Config.PutAway = { Downed = true, Cuffed = true, Water = true }

-- The phone in hand and the game controls off while it is out (attack, aim, weapon wheel, melee, pause menu).
-- ByFrame: the prop named this plus the case colour (stream/daddy_phone_<colour>), false for Model always. 28422: right hand
Config.Prop = { Model = 'prop_npc_phone_02', ByFrame = 'daddy_phone_', Bone = 28422 }
Config.Controls = { Blocked = { 24, 25, 37, 44, 45, 140, 141, 142, 199, 200, 257, 263 } }
Config.Fix = { Command = 'phonefix' } -- frees a phone stuck in the hand or a frozen pose ('' none)
Config.Look = { Key = 'LMENU' } -- held, frees the mouse to look around with the phone out

-- Clock on the status bar: 'real' (server time) or 'game' (in-game time).
Config.Clock = 'real'

-- Without daddy_college the phone keeps its own timetable; these schools are offered in setup.
Config.Schools = { 'City University', 'Coastal Technical University', 'Bay University' }

-- Class lock: during a lesson the chosen app groups lock until it ends.
Config.ClassLock = {
    Enabled = true,
    StudentCanDisable = false, -- may a student switch it off in Settings
    Default = { social = true, games = true, video = true, sounds = false },
}

-- Settings the school fixes for every phone; players see them greyed out. Any setting key with a value it accepts,
-- e.g. { side = 'right', size = '100', teacher_always = 'on', school_focus = 'on', bell = 'on', action = 'card' }
Config.LockedPrefs = {}

-- Wallet: jobs that may check a player's school ID (College security always may). CheckTarget: the option on players
-- in the target menu; CheckCommand: the same as a command ('' none): /name [id], without an id the closest player.
Config.Wallet = { InspectJobs = { 'police', 'sheriff' }, CheckTarget = true, CheckCommand = '' }

-- Who may write to the school inbox (students, a class or everyone). Any rule grants.
Config.InboxWriters = {
    { type = 'role', product = 'college', name = 'teacher' },
    { type = 'role', product = 'college', name = 'principal' },
    { type = 'ace', name = 'daddy.admin' },
}

-- Turns the phone sideways in apps that allow it (Camera). Empty: players bind it in the game's key settings.
Config.Rotate = { Key = '' }
Config.Bell = { Minutes = 5 } -- lesson reminder this many minutes before it starts
-- Camera Control: opens the camera, takes the shot inside it (empty: players bind it). Filters are the game's own looks
-- (a timecycle modifier with its strength, or a screen effect), in the order Z and X go through them; the picture kept
-- has the look, as the game draws it. Most are the ones the game's own phone camera (Snapmatic) uses, phone_cam1-12.
-- Each needs a name in the locales (apps.scanner.filter_<id>).
-- pma-voice turns its "listen to everyone" spectator mode on whenever a script camera renders, so while the phone's
-- camera is up its player hears every player around, past their voice range. `setr voice_disableAutomaticListenerOnCamera 1`
-- in server.cfg stops that (admin spectating keeps working); the server says so on start while it is not set.
Config.Camera = {
    Key = '',
    Filters = {
        { id = 'natural' },
        { id = 'vivid', timecycle = 'phone_cam9', strength = 0.8 },
        { id = 'warm', timecycle = 'phone_cam4', strength = 0.85 },
        { id = 'cool', timecycle = 'phone_cam3', strength = 0.8 },
        { id = 'film', timecycle = 'phone_cam11', strength = 0.9 },
        { id = 'fade', timecycle = 'phone_cam10', strength = 0.85 },
        { id = 'retro', timecycle = 'phone_cam1', strength = 0.9 },
        { id = 'mono', timecycle = 'phone_cam2', strength = 1.0 },
        { id = 'noir', timecycle = 'phone_cam12', strength = 1.0 },
        { id = 'sepia', timecycle = 'phone_cam7', strength = 0.9 },
        { id = 'neon', effect = 'DeadlineNeon' },
    },
}

-- Focus timer (the side key starts it).
Config.Focus = { Minutes = 25, Key = 'F7' }

Config.Limits = {
    Homework = 80, Notes = 80, Exams = 40, Contacts = 60, Groups = 10, Calls = 50,
    TitleLength = 120, BodyLength = 4000, MessageLength = 500, ChatHistory = 60,
    Scans = 20, ScanBytes = 180000,
    Notifications = 200, NotificationDays = 7, -- kept per character; older ones go
    MessageDays = 30, -- chat messages older than this go; 0 keeps them
    Folders = 20, DeletedDays = 30, Lists = 20, Alarms = 20, CalendarEvents = 200, -- note folders; days a deleted note waits in Recently Deleted; homework lists; alarms; personal calendar events
    Pins = 30, -- map pins per player
    Photos = 150, PhotoBytes = 440000, ThumbBytes = 40000, -- the gallery's photos per player; the largest picture and thumbnail (JPEG data URL characters)
    Albums = 10, AlbumPhotos = 200, -- shared albums a player makes; photos in one album (each is a copy)
}

-- Words masked with * in chat messages (lowercase, plain text).
Config.BlockedWords = {}

-- Wi-Fi: the school network reaches only College's campus (false: everywhere, as without College).
Config.Wifi = { CampusOnly = true }

-- Words looked up online (dictionaryapi.dev, English only); answers are cached in the database.
Config.Dictionary = {
    Enabled = true,
    -- Word of the day: one a day in this order (the widget), looked up like any word.
    Daily = { 'resilient', 'meticulous', 'ubiquitous', 'pragmatic', 'eloquent', 'diligent', 'ambiguous', 'candid', 'coherent', 'concise',
        'empirical', 'feasible', 'inevitable', 'lucid', 'nuance', 'paradigm', 'plausible', 'prolific', 'rigorous', 'scrutiny',
        'tenacious', 'tentative', 'versatile', 'vivid', 'zealous', 'benevolent', 'cogent', 'curious', 'deduce', 'endeavor' },
}

-- College's academics: certificates also show as Wallet passes.
Config.Academy = { CertificatePasses = true }

-- Student phone numbers: every character gets their own on first opening. '#' is a random digit, the rest stays as
-- written ('7##-####' gives 712-3456). A fixed first digit keeps them apart from the main phone's numbers.
Config.Numbers = { Pattern = '7##-####' }

-- Calls between student phones, on their own pma-voice call channels (from ChannelBase, far from the main phone's), so
-- the two phones never share a line. A player in a main phone call is busy here; the main phone taking the voice line
-- ends a student phone call. HiddenPrefix dialled before a number hides the caller's number.
Config.Calls = {
    Enabled = true,
    Voice = 'pma-voice',  -- 'pma-voice', or 'none' (calls ring and are logged without a voice line)
    ChannelBase = 1700000,
    RingSeconds = 30,
    HiddenPrefix = '#31#',
    EndOnDeath = true,     -- dying drops the call
    EarWhenClosed = false, -- true: closing the phone in a call holds it at the ear; false: it goes to the pocket
    Keys = { Answer = '', HangUp = '' }, -- answer and hang up with the phone in the pocket (players bind them)
    Waiting = true,        -- a second call rings through one in progress: hold it, swap the two, merge them
    MaxParticipants = 5,   -- people on a merged conference call
    -- Speaker: players standing this close join the call (they hear it and can talk, as around a real speakerphone).
    Speaker = { Enabled = true, Range = 3.0 },
    -- Players this close hear the phone ring, softer with distance; on silent only a buzz within 2 m.
    NearbyRing = { Enabled = true, Range = 5.0 },
    -- A caller nobody answered can leave a voice message (Phone > Voicemail), this many seconds long at most.
    Voicemail = { Enabled = true, Seconds = 30 },
}

-- School numbers in the Phone app. ring: who answers the line (access rules); every one of them online with a phone
-- rings until the first answers. Without ring the line is closed.
Config.Contacts = {
    { name = 'Student Affairs', number = '555-2140', label = 'office', ring = 'role:college:principal, role:college:counselor' },
    { name = 'Campus Security', number = '555-7000', label = 'emergency', ring = 'role:college:security' },
    { name = 'Library', number = '555-2155', label = 'office' },
}

-- Apps from other resources. group decides the class lock; without a target the icon is hidden.
-- target: { product = 'arcade', export = 'OpenFor' } (server), { export = 'res:Fn' } (client) or { event = 'name' } (client)
Config.ExternalApps = {
    { id = 'video', group = 'video' },
    { id = 'social', group = 'social' },
    { id = 'music', group = 'sounds' },
}

-- App Store. RemoteUrls: AddApp pages may be full https addresses (false: only their own files).
-- Core: built-in apps every phone has and keeps (Settings and the App Store always). Every other built-in app is in the
-- App Store, saved per character once got. Preinstalled: App Store apps a new phone starts with (they can be removed).
-- scanner = Camera, card = Wallet (student ID, payments), classroom = staff only.
Config.AppStore = {
    RemoteUrls = false,
    Core = { 'phone', 'messages', 'scanner', 'photos', 'settings', 'store', 'school', 'card', 'classroom' },
    Preinstalled = {},
}

-- AirDrop: phones within Range metres share photos, contact cards and places; each player picks who sees them
-- (Settings > AirDrop). An offer waits ExpireSeconds for an answer.
-- Video in calls: peer to peer (WebRTC, video only; pma-voice keeps the voice). The servers below help two players find
-- each other; a few home networks also need a TURN server (your own or a provider's: { urls = 'turn:...', username,
-- credential }), without one those calls stay voice only. Fps is the camera's frames a second.
Config.Video = {
    Enabled = true,
    Fps = 24,
    IceServers = {
        { urls = 'stun:stun.l.google.com:19302' },
        { urls = 'stun:stun1.l.google.com:19302' },
    },
    -- Cloudflare's TURN (Realtime, free tier) is set in server.cfg, not here (this file reaches every player):
    -- set studentphone:turn_key "<key id>" and set studentphone:turn_token "<api token>". Unset: STUN only.
}

-- Voice clips recorded in the page (Opus, about 3 KB a second): voice messages in Messages and Shadow Chat, Voice Memos,
-- and voicemail (its length is Config.Calls.Voicemail.Seconds). Memos and voicemails kept per character. MemosApp: the
-- Voice Memos app on the home screen (voice messages and voicemail work without it).
Config.Voice = { Enabled = true, MemosApp = false, MessageSeconds = 60, MemoSeconds = 180, Memos = 50, Voicemails = 30 }

-- Pictures by address (a contact's photo, the player's own, a wallpaper): https only, from these hosts only, so a link
-- cannot log who looks at it. Discord's links run out after a while; image hosts such as Imgur or FiveManage keep
-- theirs. AnyHost takes any https picture (its site can then see who looked at it); a wallpaper also needs the site to
-- allow being drawn (CORS), as Imgur, Discord and FiveManage do.
Config.PictureLinks = {
    Enabled = true,
    AnyHost = false,
    Hosts = { 'i.imgur.com', 'r2.fivemanage.com', 'files.fivemanage.com', 'cdn.discordapp.com', 'media.discordapp.net', 'i.ibb.co' },
}

Config.AirDrop = { Enabled = true, Range = 6.0, ExpireSeconds = 60 }

-- Campus Media: the campus's social network. People sign up with a username and a password; a character opens at
-- most MaxAccounts accounts (and may sign in to any account whose password they know). Posts are up to MaxPhotos
-- gallery photos with words, or words alone (MaxChars), with replies of ReplyChars; direct messages hold MessageChars;
-- moments are photos that stay MomentHours. PostGap, ReplyGap and MomentGap are the seconds an account waits between
-- them. Reports from HideAt readers hide a post until staff (Config.Confess.Roles review) look; staff also give the
-- verified badge and reset passwords.
Config.Campus = {
    Enabled = true,
    MaxAccounts = 2,
    MaxChars = 500, ReplyChars = 300, MessageChars = 500, MaxPhotos = 5,
    MomentHours = 24,
    PostGap = 30, ReplyGap = 4, MomentGap = 20,
    MaxParts = 4, MaxReplyPhotos = 1, -- posts in one chain; photos on one reply's part
    FeedPage = 15, RepliesPage = 20, ActivityPage = 30, ActivityDays = 30, -- page sizes; days activity is kept
    LikeNoticeGap = 600, MentionCap = 10, BellCap = 200, -- seconds between like banners per post; mentions and bell banners per post
    HideAt = 3,
    Reasons = { 'harassment', 'real_info', 'sexual', 'hate', 'spam', 'other' },
}

-- Mail: the school's domain for every character's address, the longest mail and how many addresses one may go to.
Config.Mail = { Enabled = true, Domain = 'kampus.edu', MaxBody = 4000, MaxTo = 5 }

-- The campus Market: how many days a listing stays, how many open ones a player keeps and the wait between new ones.
Config.Market = { Enabled = true, Days = 7, MaxOpen = 8, PostGap = 60 }

-- Music: the server's songs (https audio files: { id, title, artist, url, cover }), the hosts players may add songs from
-- by link (empty: no adding) and how many each player keeps.
Config.Music = {
    Enabled = false, -- off while the app is redone
    Library = {},
    Hosts = { 'cdn.discordapp.com', 'files.catbox.moe' },
    MaxTracks = 100,
}

-- Spark, the dating app: on or off and the youngest age a profile may give.
Config.Dating = { Enabled = false, MinAge = 18 } -- off while the app is redone

-- Services: who players can ask for help (a label when there is no apps.services.svc_<id> text, symbol, colour and
-- the framework jobs that answer), whether only those
-- on duty get requests, the wait between requests and when an untaken one closes (minutes). A number that rings its
-- staff in turn is Config.Contacts with ring.
Config.Services = {
    Enabled = false, -- off while the app is redone
    DutyOnly = true,
    Gap = 30,
    CloseAfter = 60,
    List = {
        { id = 'police', label = 'Police', symbol = 'shield.fill', color = '#2f5fd0', jobs = { 'police', 'sheriff' } },
        { id = 'medic', label = 'Medic', symbol = 'cross.case.fill', color = '#e0453a', jobs = { 'ambulance' } },
        { id = 'mechanic', label = 'Mechanic', symbol = 'wrench.and.screwdriver.fill', color = '#e08a1e', jobs = { 'mechanic' } },
        { id = 'taxi', label = 'Taxi', symbol = 'car.fill', color = '#d6a400', jobs = { 'taxi' } },
    },
}

-- Clips: the longest clip in seconds, the largest upload (bytes of its data), how many clips a player keeps, and live
-- streams (on or off, how many may watch one; each viewer is a connection from the broadcaster's game).
Config.Clips = { Enabled = false, Seconds = 15, MaxBytes = 1600000, PerPlayer = 30, Live = true, MaxViewers = 6 } -- off while the app is redone

-- Crypto: made-up coins (id, name, symbol, colour, starting price and how far one step may swing it), how often prices
-- move (minutes), the framework account trades use, the fee each way and the largest single buy.
Config.Crypto = {
    Enabled = false, -- off while the app is redone
    StepMinutes = 5,
    Account = 'bank',
    Fee = 0.01,
    MaxTrade = 50000,
    Coins = {
        { id = 'lsc', name = 'Los Santos Coin', symbol = 'LSC', color = '#f2a20c', price = 1250, swing = 0.03 },
        { id = 'camp', name = 'Campus Token', symbol = 'CMP', color = '#3d8fd9', price = 3.4, swing = 0.06 },
        { id = 'vine', name = 'Vinewood', symbol = 'VWD', color = '#bf5af2', price = 42, swing = 0.08 },
    },
}

-- Browser: the hosts its pages may come from (https only, subdomains too), the start page's tiles and the address
-- words are searched at (empty: no search). A site must allow being framed: DuckDuckGo, Google, Brave and
-- OpenStreetMap refuse and show an empty page, Wikipedia's sites open.
Config.Browser = {
    Enabled = true,
    Hosts = { 'wikipedia.org', 'wiktionary.org' },
    Home = {
        { title = 'Vikipedi', url = 'https://tr.wikipedia.org/wiki/Anasayfa?useformat=mobile' },
        { title = 'Vikisözlük', url = 'https://tr.wiktionary.org/wiki/Ana_Sayfa?useformat=mobile' },
        { title = 'Wikipedia', url = 'https://en.wikipedia.org/wiki/Main_Page?useformat=mobile' },
    },
    Search = 'https://tr.wikipedia.org/w/index.php?useformat=mobile&fulltext=1&search=',
}

-- Garage: the valet (a garaged vehicle brought to the nearest road), its fee from Account and the wait between two.
-- A server whose garage script should do the bringing sets ValetEvent: that server event gets (source, plate).
Config.Garage = { Enabled = false, Valet = true, ValetFee = 250, ValetGap = 120, Account = 'bank', ValetEvent = nil } -- off while the app is redone

-- Ride: the fare (Base, plus PerKm along the straight line to the drop-off), the account it moves between and how long
-- a request nobody takes waits (minutes).
Config.Ride = { Enabled = false, Base = 40, PerKm = 25, Account = 'bank', ExpireMinutes = 10 } -- off while the app is redone

-- Payphones: the street phone boxes (with ox_target) call a number with the caller's number hidden for Price in cash.
Config.Payphone = {
    Enabled = true,
    Price = 5,
    Models = { 'prop_phonebox_01a', 'prop_phonebox_01b', 'prop_phonebox_01c', 'prop_phonebox_02', 'prop_phonebox_03', 'prop_phonebox_04' },
}

-- Wallet's Cash: the framework account it uses, the smallest and largest single payment and the most sent in a day.
Config.Wallet = { Enabled = true, Account = 'bank', MinSend = 1, MaxSend = 5000, DayLimit = 20000 }

-- The battery, in percent a minute: OpenDrain while the phone is out, IdleDrain in the pocket (LowPower times that in
-- Low Power Mode), Charge in a vehicle (VehicleCharges) or while the ChargePhone export keeps it plugged in.
Config.Battery = {
    Enabled = true,
    OpenDrain = 0.5, IdleDrain = 0.05, LowPower = 0.5,
    Charge = 3, VehicleCharges = true,
    Powerbank = { Item = 'phone_powerbank', Seconds = 600, -- one use charges this long (Item = false: none)
        Hold = { Model = 'daddy_school_powerbank', Dict = 'cellphone@', Clip = 'cellphone_text_read_base', Ms = 3000 } }, -- shown in the hand (false: none)
    -- Plug the phone in at these (ox_target): any of the Models or a Points spot; it charges while you stay within Reach.
    Chargers = {
        Models = { 'prop_vend_snak_01', 'prop_vend_soda_01', 'prop_vend_soda_02', 'prop_vend_coffe_01', 'prop_vend_water_01',
            'daddy_school_charger_wall', 'daddy_school_charger_stand' },
        Points = {}, -- vec3 spots (dorm desks, canteen walls...)
        -- Charger props placed on the map (local objects). Coords are where you stood facing it: a 'wall' one goes
        -- WallAhead m in front of you at WallHeight above your feet, a 'stand' one StandAhead m ahead on the ground.
        Spawn = {
            { Kind = 'stand', Coords = vector4(5328.7998, -5255.7197, 31.9806, 156.0964) },
            { Kind = 'stand', Coords = vector4(5344.1050, -5286.8120, 31.0418, 350.5793) },
            { Kind = 'stand', Coords = vector4(5400.2500, -5265.9243, 32.0001, 112.2916) },
            { Kind = 'stand', Coords = vector4(5373.4448, -5184.6323, 32.0038, 308.3147) },
            { Kind = 'stand', Coords = vector4(5344.7456, -5167.1567, 32.0189, 17.3128) },
        },
        SpawnModels = { wall = 'daddy_school_charger_wall', stand = 'daddy_school_charger_stand' },
        WallAhead = 0.45, WallHeight = 1.3, StandAhead = 0.6,
        Reach = 2.5,
    },
}

-- The phone's passcode: Tries wrong codes in a row lock it for the next of Waits (seconds); staff take a forgotten one
-- off with ResetCommand <server id>. Face ID fails while the mask slot (component 1) holds anything but NoMask.
Config.Passcode = {
    Tries = 5,
    Waits = { 60, 300, 900, 3600 },
    ResetCommand = 'phonepasscode',
    NoMask = { 0 },
}

-- Shadow Chat: anonymous rooms and strangers. Rooms (freq is only an order kept from older configs; from/to: the hours
-- a room is open, school clock, e.g. 22 to 4) and a match with a stranger by shared interests, who may then talk on a
-- hidden line. Everyone writes under a name made up per room and day (a colour and a shape). Staff (Config.Confess.Roles
-- review) take messages away and mute writers; HideAt reports hide a message. Messages live KeepHours; in a match they
-- can go sooner (Timers: the choices in seconds, Timer: a new match's own, 0 for none). IceBreakSeconds of silence
-- in a new match bring a topic from the host. Each room needs a name in the locales (apps.whisper.room_<id>).
Config.Whisper = {
    Enabled = true,
    Rooms = {
        { id = 'campus', freq = 88.0 },
        { id = 'dorm', freq = 91.3 },
        { id = 'lessons', freq = 96.6 },
        { id = 'night', freq = 103.0, from = 22, to = 4 },
    },
    MaxChars = 300, KeepHours = 48, HideAt = 3,
    Rate = { gap = 2, minute = 15 }, -- seconds between messages, messages a minute
    Timers = { 300, 3600, 86400 }, Timer = 3600,
    IceBreakSeconds = 30,
}

-- Confessions: short anonymous posts. Players never see who wrote one; the server keeps the author for staff.
-- Nothing is filtered: readers report, staff hide, mute or ban. Roles use access rules ('role:college:principal',
-- 'ace:group.admin', 'job:police'...); server admins (daddy.admin) always have every right.
Config.Confess = {
    Enabled = true,
    Audience = 'school',          -- 'school': with College, students write and the school reads; 'everyone'
    StaffWrite = false,           -- staff may post too (school audience)
    MinChars = 8, MaxChars = 280, MaxLines = 6,
    Tags = { 'crush', 'campus', 'lesson', 'dorm', 'other' },
    Replies = true, MaxReplies = 50,
    Jitter = { 30, 120 },         -- seconds before a post goes live (replies wait half)
    LifetimeHours = 72,
    KeepDays = 30, EvidenceDays = 90, AuditDays = 180,
    Rate = {
        Post = { gap = 120, hour = 2, day = 6 },
        Reply = { gap = 20, hour = 20 },
        Like = 30,                -- per minute
        Report = { hour = 10, day = 20 },
        DuplicateHours = 24,
    },
    Reports = {
        Reasons = { 'harassment', 'real_info', 'sexual', 'hate', 'threat', 'selfharm', 'spam', 'other' },
        HideAt = 3, HideAtNoStaff = 2, -- different readers before a post hides until review
        InstantHide = { 'real_info', 'sexual', 'threat', 'selfharm' }, -- one report hides
        Urgent = { 'threat', 'selfharm' }, -- staff online get an urgent notice
        TrustFloor = 0.3,         -- readers whose reports are mostly dismissed stop counting
    },
    Roles = {
        review = 'role:college:principal, role:college:counselor', -- see reports, hide, put back
        sanction = 'role:college:principal',                        -- delete, warn, mute, ban
        -- reveal: see who wrote a post (with a reason, logged); left out = server admins only
        freeze = 'role:college:principal',                          -- make the app read-only
    },
    RevealPerDay = 5,
    Ladder = { { kind = 'warn' }, { kind = 'mute', hours = 24 }, { kind = 'ban', days = 7 }, { kind = 'ban' } },
    SanctionScope = 'account',    -- 'account' (the player's licence) or 'character'
    RulesVersion = 1,             -- raise it to show the rules page to everyone again
    LogHook = nil,                -- a server event name that gets every moderation row
    -- "To the council": complaints and ideas without a name; only the student council (College) and the principal read
    -- them, only the principal sees who wrote one. One note per CooldownSeconds a student; kept KeepDays.
    CouncilBox = { Enabled = true, MaxChars = 600, CooldownSeconds = 300, KeepDays = 30 },
}

-- Server settings (overrides/daddy_studentphone/config.lua)
-- The server's language.
Config.Locale = 'tr'
-- The main phone is cylex_phone (F1). The student phone sits at the bottom right with its notifications and calls beside
-- it. It has its own numbers and calls (Config.Calls); it stays in the pocket while cylex is up, and a cylex call makes
-- its line busy.
Config.Screen.Side = 'right'
Config.Screen.Banners = 'corner'
-- Players may use a picture from any https address (contacts, profile, wallpaper).
Config.PictureLinks.AnyHost = true
-- Kimlik sorgulama target yerine komutla: /kimliksor [id] (id yoksa en yakın oyuncu). Yetki ve mesafe server/card.lua'da.
Config.Wallet.CheckTarget = false
Config.Wallet.CheckCommand = 'kimliksor'
-- Ele yapışan telefon / donan animasyon: /telefonduzelt
Config.Fix.Command = 'telefonduzelt'
-- Okul numaralarının ve servislerin Türkçe adları.
local contactNames = { ['555-2140'] = 'Öğrenci İşleri', ['555-7000'] = 'Kampüs Güvenliği', ['555-2155'] = 'Kütüphane' }
for _, contact in ipairs(Config.Contacts) do contact.name = contactNames[contact.number] or contact.name end
local serviceNames = { police = 'Polis', medic = 'Sağlık', mechanic = 'Mekanik', taxi = 'Taksi' }
for _, service in ipairs(Config.Services.List) do service.label = serviceNames[service.id] or service.label end
