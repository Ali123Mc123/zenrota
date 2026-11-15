Config = {}

Config.Locale = 'tr' -- en | tr

-- Debug: F8 prints which modules loaded, every menu step and NUI call (with its answer and time) and page errors,
-- and the menu shows a log panel. Also switchable in game with the F8 command 'pausemenu_debug'.
Config.Debug = false

-- The menu strip, in order. Remove an id to hide it: resume, map, settings, stats, photo, rules, leave.
Config.Menu = { 'resume', 'map', 'settings', 'stats', 'photo', 'rules', 'leave' }

-- Footer links, opened in the player's browser. An empty one is hidden.
Config.Links = {
    Discord = '',
    Website = '',
}

-- The commands screen (menu id 'rules'): handy commands and keys shown to players. Each key has a command, a title and
-- a text in locales/<language>.lua under rules.items.<key>.
Config.Commands = {
    'inventory',
    'interact',
    'emotes',
    'walk',
    'handsup',
    'crouch',
    'voicerange',
    'voicevolume',
    'hud',
    'togglehud',
    'cinematic',
    'crosshair',
    'fps',
    'idlecam',
    'belt',
    'carcontrol',
    'seat',
    'postal',
    'luck',
    'cards',
}

-- The look of the menu on first use; players change it in Settings > Interface (kept on their PC).
Config.Theme = {
    langChoice = true, -- players may pick the menu's language in Settings > Display (Config.Locale is the default)
    motion = 'full', -- menu animations for new players: full | reduced | off
    accent = '#c8102e', -- DaddyRP dark red; any #rrggbb; ten preset swatches are offered in the menu
    scale = 100, -- 85 | 90 | 95 | 100 | 105 (percent)
    charCam = false, -- frame the character on the home screen; false leaves the game camera alone (players press C on home)
    blur = false, -- blur the scene behind the sub screens
}

-- Esc, P and pad Start open this menu instead of GTA's.
Config.Esc = {
    PauseKey = 'pause', -- what P and pad Start open: 'pause' (home) or 'map'
    OpenKey = '', -- an extra key players can bind in FiveM's key bindings; '' leaves it unbound
    SuppressMs = 400, -- the pause keys are ignored this long after the menu closes
    -- How Esc, P and pad Start are taken over while the menu is closed:
    --   'block'   every frame GTA's pause menu is stopped before it opens (about 0.01 ms in resmon; GTA's menu never shows)
    --   'replace' nothing runs per frame (0.00 ms): GTA's pause menu is closed the moment it opens and this one opens in
    --             its place, so GTA's menu can show for a split second and play its sound
    Mode = 'replace',
    LeanBlock = true, -- 'block': the fewest natives per frame; set false if GTA's pause slips through
    ReplaceForeignPause = true, -- GTA's own pause menu (alt-tab, other scripts) is closed and this one opens
    BlockOnScriptCam = true, -- do not open while another resource's scripted camera is showing
    FreeCamStates = { 'noclip', 'freecam' }, -- player statebags of a noclip/freecam; its camera does not block
    Failsafe = 8000, -- the menu closes again if its page never reports it rendered (ms)
    ZIndex = 9999, -- keeps the menu above HUD pages
}

-- Other HUDs hidden while the menu is open: a resource and its client export that takes a boolean.
Config.Huds = {
    { resource = 'daddy-hud', export = 'SetVisible' },
}

-- Game settings engines. PrivilegedWrite: values are written through a key binding the moment Apply is clicked.
-- FrontendDriver: graphics are changed by driving GTA's own settings screen behind the menu.
Config.Settings = {
    PrivilegedWrite = true,
    FrontendDriver = true,
    -- Slider ranges measured in game, by convar: { profile_mouseOnFootScale = { 0, 100 } }.
    -- Sliders without a known range (mouse sensitivities, auto-center, brightness) can only be changed in GTA's menu until set here.
    Ranges = {},
    -- Values "Restore defaults" sets, by convar or row id, over the built-in ones: { profile_sfxVolume = 10 }.
    Defaults = {},
    -- Row ids left out of the menu, e.g. { 'voice_enable', 'voice_talk_enabled' } to keep players from turning voice chat off.
    Hide = {},
    -- Rows hidden by default as useless on RP servers (shared/settings_layout.lua HIDE_DEFAULT) that this server wants
    -- back: row ids, or whole GTA key sections ('veh_online', 'sub'), e.g. { 'radio_station', 'sub' }.
    Show = {},
    -- pma-voice rows (voice range, radio and phone volume): the resource name and how many range modes it has.
    Voice = {
        Resource = 'pma-voice',
        Modes = 3, -- labels: locales settings.opts.proximity.v0, v1, v2 (add v3... for more modes)
    },
    -- How graphics are changed through GTA's own settings screen behind the cover.
    -- auto: keep the page focused first, then without focus, then scaleform arrow steps; what works is remembered.
    DriverFocusMode = 'auto', -- auto | focus | nofocus | scaleform
    Driver = {
        PressGapMs = 100, -- minimum time between two presses sent to GTA's menu
        TurnGapMs = 260, -- after a change of direction (GTA's menu drops a turn inside its input throttle)
        FastTurn = true, -- clear GTA's input throttle before a change of direction instead of waiting TurnGapMs
        VerifySets = true, -- read each changed row back from GTA's menu and press again when a press was dropped
        DirectWrite = true, -- settings outside Graphics are written in one go, without walking GTA's menu (no console rights)
        EventTimeoutMs = 450, -- how long a press waits for GTA to report the highlight moved
        OpenTimeoutMs = 4000, -- GTA's settings must be ready within this
        SettleMs = 150, -- pause once it is ready (the settings page streams in)
        EnterSettleMs = 150, -- after entering a list, before the highlight jumps to the first row to change
        ApplyTimeoutMs = 10000, -- Apply must finish within this (a display mode change resets the screen)
        WarnShowMs = 250, -- how long Apply waits for a question from GTA (it shows 30-50 ms after Apply)
        KeepPromptMs = 12000, -- time the player has to keep new display settings before GTA puts the old ones back
        AutoKeep = true, -- answer GTA's "keep new settings?" at once when no display mode row changed
        ConfirmMs = 30000, -- time the "change the display mode?" question waits
        RunTimeoutMs = 150000, -- hard limit for one run (every graphics row at once on a first run takes about a minute)
        DirectLanding = false, -- try to open GTA's settings straight on the right screen (none works on game build 3258)
        SuppressRender = false, -- also stop GTA drawing its menu; the cover hides it anyway, enable only after testing
        UseSeed = true, -- one-press absolute value sets (self-tested once per game build before use)
        Jump = true, -- put the highlight straight on a category or row (GTA's own mouse path); walks when it fails
        Debug = false, -- print every step in F8
    },
}

-- How often the server recounts the players online (ms); joins and drops update it at once.
Config.OnlineRefresh = 30000

-- Stats screen: GTA's own counters (kept per character in the database), skills and the money tracker.
-- Row ids are listed in shared/stats_def.lua (PMStats.ROWS); texts are under stats.rows.<id> in locales/<language>.lua.
Config.Stats = {
    PushInterval = 60, -- seconds between the client's stat updates to the server
    SaveInterval = 180, -- seconds between database saves of changed characters
    HideEmpty = true, -- rows fed by other resources (missions, robberies, tax...) stay hidden until they have a value
    TrackDuty = true, -- time on duty feeds the Shifts row
    -- The rows of each tab, in order (at most 8 show at once; more scroll with the selection).
    Tabs = {
        skills = { 'stamina', 'shooting', 'strength', 'stealth', 'flying', 'driving', 'lung' },
        career = { 'missions', 'reputation', 'rank', 'shift', 'playtime', 'on_foot', 'swimming' },
        crimes = { 'robberies', 'arrests', 'wanted', 'laundering', 'stolen', 'cop_kills' },
        vehicles = { 'owned', 'races', 'crashes', 'driven', 'top_speed', 'near_misses' },
        cash = { 'income', 'spending', 'savings', 'tax', 'best_income', 'worst_expense' },
        combat = { 'kills', 'headshots', 'survival', 'deaths', 'accuracy', 'shots' },
    },
    Records = { 'playtime', 'longest_session', 'travelled', 'deaths' }, -- the records strip
    Career = { 'session', 'playtime', 'deaths', 'on_foot' }, -- the list at the bottom of the detail panel
    -- A row's bar: a cap (full at that raw value) or ten ascending steps, e.g. kills = { 10, 25, 50, ... }.
    -- Raw units: time in ms, distance in metres, speed in m/s, money in dollars.
    Caps = {},
    Skills = {
        Enabled = true, -- false: another resource owns GTA's skills; the menu only shows them
        -- GTA stats this menu shows but does not write (the engine gets this value instead). MP0_STAMINA from running
        -- distance reached 70-100 for most players = sprint stamina barely drains. 0 = normal GTA stamina; the gym
        -- (daddy-games) may still raise it while a player keeps their condition up.
        EngineFixed = { STAMINA = 0 },
        Base = 0, -- every new character's skills start here: a number, or { STAMINA = 20, STRENGTH = 10, ... }
        Rates = {}, -- override the GTA Online progression, e.g. { stamRun = 175, shoHits = 80 } (shared/stats_def.lua)
        ShootingStat = 'HITS', -- 'HITS_PEDS_VEHICLES' if the stat probe shows that one moving on your server
        DrivingBonus = true, -- clean landings, top-speed runs and wheelies raise Driving, as in GTA
        Feed = false, -- GTA's skill card in the feed every 20 points (DaddyRP: kapalı, 'Sürüş Yeni seviye' kartı çıkmaz)
        ApplyModifiers = false, -- Rockstar's intended melee (Strength) and noise (Stealth) effects; 0.8x melee at Strength 0
    },
}

-- The map screen (GTA's own map under a places panel) and the home mini map. Blip icons are read from the game's own
-- textures on each player's PC; no Rockstar image ships with this resource.
Config.Map = {
    -- Home screen: web-based vector/atlas mini map in NUI. Set Enabled = false to keep GTA's native radar untouched.
    Radar = {
        Enabled = false,
        Zoom = 1100, -- radar zoom inside the box (1100 stays on high-res streamed tiles)
        ZoomScale = 1.4, -- radar zoom scale (broadens postal pack's tight 2.75 for a comfortable overview)
        MapScale = { w = 1.55, h = 1.55 }, -- canvas scale relative to box (fills mask completely)
        MapOffset = { x = 0.0, y = 0.0 }, -- canvas offset relative to box width/height
        MaskScale = { w = 1.0, h = 1.0 }, -- mask clipping window scale
        MaskOffset = { x = 0.0, y = 0.0 }, -- mask clipping window offset
        Backdrop = true, -- the design's sea under the see-through radar
        BackdropColor = { 20, 33, 61, 255 }, -- r, g, b, a
        -- How your HUD had the radar, put back afterwards. These are GTA's own (rectangle, bottom left); a HUD that moves
        -- or rounds the radar needs its own values here (daddy-hud's are in the docs).
        Restore = {
            clip = 0, zoom = 0, bars = 0, -- clip: 0 rectangle, 1 round; zoom: 0 is GTA's own; bars: 0 shown, 3 hidden
            zoomScale = 2.75, -- postal map pack's default level 0 scale restored on close
            zoomScaleVehicle = 2.8, -- postal map pack's default level 1 scale restored on close
            minimap = { 'L', 'B', -0.0045, 0.002, 0.150, 0.188888 },
            mask = { 'L', 'B', 0.020, 0.032, 0.111, 0.159 },
            blur = { 'L', 'B', -0.03, 0.022, 0.266, 0.237 },
            -- Radar mask textures your HUD replaces (texture, txd, new texture): taken off while in the box, put back after.
            textures = {},
        },
    },
    -- The places list over GTA's map, nearest first; its filter line names these categories first, the rest after.
    Order = { 'police', 'medical', 'garage', 'bank', 'jobs', 'shop', 'fuel', 'clothing' },
    Folded = { 'other' }, -- categories the All filter leaves out (their own filter word and a search still list them)
    GameNames = true, -- blip names as GTA has them (read from the game while the map shows); false: export, shim and category names only
    GameIcons = true, -- blip icons from the game's own art (read on each PC through nui-img); false: category letters
    -- GTA's map follows the place picked in the list (two hidden helper blips). Sprite: the helpers' blip sprite.
    -- Alpha: 1 keeps them all but invisible (0 drops them from GTA's legend: no pan); 255 shows the picked place.
    Focus = { Enabled = true, Sprite = 162, Alpha = 1 },
    -- Per category look: police = { color = '#4aa8ff', glyph = 'P' }. color: '#rrggbb', 'accent' (menu colour) or
    -- 'blip' (the blip's own colour). Names and default glyphs are in locales (map.categories.*, map.glyphs.*).
    -- Categories: police medical garage bank jobs shop clothing barber tattoo weapons fuel mechanic carwash dealer
    -- impound airport transport housing leisure players alerts other
    Categories = {},
    Sprites = {}, -- extra blip sprites per category: [357] = 'garage'
    Resources = {}, -- blips named through the shim, by the resource that made them: my_garages = 'garage'
    HideDisplay = { 0 }, -- blip display ids never drawn (GET_BLIP_INFO_ID_DISPLAY)
    Debug = false, -- print each new blip display id seen (to tune HideDisplay)
}

-- Character camera: frames your character on the home screen when a player turns it on (C on home, or Settings > Pause Menu).
Config.CharCam = {
    Fov = 40.0, -- vertical field of view (degrees)
    Margin = 1.1, -- room around the character inside its box (1.0 = head to toe)
    Height = 0.0, -- camera height over the middle of the body (m)
    MinDistance = 1.4, -- a wall closer than this: no camera, the scene is blurred instead (m)
    SwitchMs = 400, -- camera move from photo mode back to home
    EaseInMs = 650, -- from the game camera when the menu opens
    EaseOutMs = 450, -- back to the game camera when it closes (a cut in first person)
    BlurMs = 400, -- fade of the blur behind the sub screens (settings, stats, rules)
    HideOthers = false, -- hide other players within 6 m while the camera shows your character (only on your screen)
}

-- Photo mode: limits and feel.
Config.Photo = {
    MaxDistance = 8.0, -- how far the camera may go from your head (m); walls and the ground also stop it
    MaxSeconds = 300, -- photo mode ends after this long (s)
    DamageCooldown = 30, -- no photo mode this long after taking damage (s)
    MaxVehicleSpeed = 1.0, -- in a vehicle moving faster than this (m/s) photo mode is refused or ends
    Speed = 1.5, -- camera speed at 1.00x (m/s); Shift x3, Ctrl x0.25
    LookSpeed = 8.0, -- mouse look
    ShakeScale = 1.0, -- hand shake at 100% = 0.15 x this
    Dof = true, -- portrait depth of field while the camera looks at you (follow on, or orbit)
    Aperture = 2.8, -- f-number of that depth of field (lower = blurrier background)
    HideAll = false, -- true: H also hides the numbers and the key hints for a clean frame (false: only the panel, as in the design)
    -- true: the camera moves while the panel shows, but other resources' key bindings (inventory, emotes, phone) also fire
    -- in photo mode. false: the panel keeps the keyboard and the camera moves after H hides it.
    KeepInput = true,
    HideOthers = false, -- hide other players near the camera (only on your screen)
    -- Poses: [id] = { anim dictionary, clip, flag }. Leave one out to use the built-in one.
    Poses = {
        hips = { 'random@shop_tattoo', '_idle_a', 1 },
        crossed = { 'amb@world_human_hang_out_street@female_arms_crossed@idle_a', 'idle_a', 1 },
        lean = { 'amb@world_human_leaning@male@wall@back@foot_up@idle_a', 'idle_a', 1 },
        victory = { 'rcmfanatic1celebrate', 'celebrate', 1 },
    },
    -- Filters: [id] = { timecycle modifier, strength 0-1 }.
    Filters = {
        cinematic = { 'cinema', 1.0 },
        faded = { 'hud_def_desat_Neutral', 1.0 },
        warm = { 'glasses_orange', 0.6 },
        bw = { 'CAMERA_BW', 1.0 },
        night = { 'glasses_Darkblue', 0.8 },
    },
}

-- Server settings (servers/daddyrp/daddy_pausemenu/config.lua)
-- DaddyRP: web-based vector/atlas mini map in pause menu home screen.
-- Native radar is kept on player HUD outside pause menu and cleanly hidden inside pause menu.
Config.Map.Radar.Enabled = false
Config.Map.Radar.Zoom = 1100
Config.Map.Radar.ZoomScale = 1.4
Config.Map.Radar.MapScale = { w = 1.55, h = 1.55 }
Config.Map.Radar.MapOffset = { x = 0.0, y = 0.0 }
Config.Map.Radar.MaskScale = { w = 1.0, h = 1.0 }
Config.Map.Radar.MaskOffset = { x = 0.0, y = 0.0 }
Config.Map.Radar.Restore.zoom = 1200
Config.Map.Radar.Restore.zoomScale = 2.75
Config.Map.Radar.Restore.zoomScaleVehicle = 2.8
