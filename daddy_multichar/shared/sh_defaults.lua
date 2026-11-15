-- Settings the config files leave out: technical values with sensible defaults. A key set in config/ always wins;
-- copy one into a config file to change it.
local DEFAULTS = {
    Bucket = { Base = 50000 }, -- while selecting, each player is alone in bucket Base + server id
    Boot = { NuiMs = 10000, ReadyMs = 8000 },
    Safemode = true, -- a plain ox_lib menu when the page fails
    Stats = { FlushMinutes = 5 },
    Combat = { Seconds = 60 },
    Gate = { DuplicateLicense = true },
    PauseMenu = { Resource = 'daddy_pausemenu' },
    -- DaddyRP: primehud's show/hide pair works the other way round, so the names are swapped here
    Huds = { { resource = 'daddy-hud', export = 'SetVisible' }, { resource = 'wais-primehud', show = 'hideHud', hide = 'showHud' } },
    Codes = { MaxPerBatch = 50, Attempts = 5, BlockMinutes = 30 },
    Party = { Enabled = false },
    EditorProps = { 'prop_tv_cam_02', 'prop_studio_light_02', 'prop_direct_chair_01', 'prop_table_03', 'prop_beach_lounge_chair' },

    Intro = {
        Skippable = true,
        MinMs = 2500,
        Tracks = { 'builtin:noir', 'builtin:drive', 'builtin:dawn' },
        Volume = 0.25,
    },

    Theme = {
        Italic = true,
        Panel = 'light',
        Presets = {
            { id = 'crimson', accent = '#c8102e' },
            { id = 'pink', accent = '#ff1f6d' },
            { id = 'red', accent = '#ec3013' },
            { id = 'amber', accent = '#f5a524' },
            { id = 'cyan', accent = '#2ec4d6' },
            { id = 'violet', accent = '#8b5cf6' },
            { id = 'green', accent = '#22c55e' },
            { id = 'mono', accent = '#f3f2f2' },
        },
        ActorBox = {
            right = { x = 980, y = 100, w = 760, h = 900 },
            panel = { x = 520, y = 100, w = 700, h = 900 },
        },
    },

    Selection = {
        Drift = true,
        Cams = { near = 0.82, mid = 1.0, wide = 1.18 },
        Openers = { 'push', 'drop', 'reveal', 'orbit' },
        IdleCinema = 30,
        PoseCycle = 15,
        PedOffset = 1.0,
        LowSpec = false,
        StreamerDefault = false,
        RoleScenes = { Enabled = true, Fill = { 'extras' } },
        Partners = { Enabled = false },
        JobLooks = {
            taxi = { hour = 23.0, weather = 'CLEAR' },
            ambulance = { hour = 6.5, weather = 'FOGGY' },
            police = { hour = 21.0, weather = 'CLEAR' },
            mechanic = { hour = 17.5, weather = 'CLOUDS' },
            tow = { hour = 1.5, weather = 'RAIN' },
            lawyer = { hour = 9.5, weather = 'CLEAR' },
            judge = { hour = 10.0, weather = 'EXTRASUNNY' },
            realestate = { hour = 19.25, weather = 'EXTRASUNNY' },
            cardealer = { hour = 13.0, weather = 'EXTRASUNNY' },
            burgershot = { hour = 12.5, weather = 'EXTRASUNNY' },
            trucker = { hour = 6.5, weather = 'FOGGY' },
            bus = { hour = 8.0, weather = 'OVERCAST' },
        },
        DefaultLook = { hour = 19.0, weather = 'EXTRASUNNY' },
        Weathers = {
            'EXTRASUNNY', 'CLEAR', 'NEUTRAL', 'SMOG', 'FOGGY', 'OVERCAST', 'CLOUDS', 'CLEARING',
            'RAIN', 'THUNDER', 'SNOW', 'BLIZZARD', 'SNOWLIGHT', 'XMAS', 'HALLOWEEN',
        },
        Filters = {
            { id = 'cinema', modifier = 'cinema', strength = 0.7 },
            { id = 'film', modifier = 'NG_filmic01', strength = 0.8 },
            { id = 'soft', modifier = 'BloomLight', strength = 0.8 },
            { id = 'cold', modifier = 'hud_def_desat_cold', strength = 0.6 },
            { id = 'warm', modifier = 'sunglasses', strength = 0.5 },
            { id = 'noir', modifier = 'NG_filmnoir_BW01', strength = 1.0 },
        },
        Gestures = {
            { dict = 'gestures@m@standing@casual', clip = 'gesture_hello', gender = 'm' },
            { dict = 'gestures@m@standing@casual', clip = 'gesture_nod_yes_soft', gender = 'm' },
            { dict = 'gestures@m@standing@casual', clip = 'gesture_easy_now', gender = 'm' },
            { dict = 'gestures@f@standing@casual', clip = 'gesture_hello', gender = 'f' },
            { dict = 'gestures@f@standing@casual', clip = 'gesture_nod_yes_soft', gender = 'f' },
            { dict = 'gestures@f@standing@casual', clip = 'gesture_point', gender = 'f' },
        },
        Idle = {
            Seconds = 0,
            Moves = {
                { dict = 'anim@mp_player_intcelebration{sex}@take_selfie', clip = 'take_selfie' },
                { dict = 'anim@amb@waving@{sex}', clip = 'air_wave' },
                { dict = 'anim@mp_player_intcelebration{sex}@air_guitar', clip = 'air_guitar' },
                { dict = 'anim@mp_player_intcelebration{sex}@thumbs_up', clip = 'thumbs_up' },
                { dict = 'anim@mp_player_intcelebration{sex}@peace', clip = 'peace' },
                { dict = 'anim@mp_player_intcelebration{sex}@slow_clap', clip = 'slow_clap' },
            },
        },
    },

    Animations = { -- poses players may give a character (labels: locales anim.<id>)
        { id = 'stand', dict = 'anim@heists@heist_corona@team_idles@male_a', clip = 'idle', gender = 'm' },
        { id = 'stand_f', dict = 'anim@heists@heist_corona@team_idles@female_a', clip = 'idle', gender = 'f' },
        { id = 'boss', dict = 'anim@heists@heist_corona@single_team', clip = 'single_team_loop_boss', gender = 'any' },
        { id = 'arms', dict = 'amb@world_human_hang_out_street@female_arms_crossed@idle_a', clip = 'idle_a', gender = 'any' },
        { id = 'lean', scenario = 'WORLD_HUMAN_LEANING', gender = 'any' },
        { id = 'smoke', scenario = 'WORLD_HUMAN_SMOKING', gender = 'any' },
        { id = 'phone', scenario = 'WORLD_HUMAN_STAND_MOBILE', gender = 'any' },
        { id = 'coffee', scenario = 'WORLD_HUMAN_AA_COFFEE', gender = 'any' },
        { id = 'guard', scenario = 'WORLD_HUMAN_GUARD_STAND', gender = 'any' },
        { id = 'clipboard', scenario = 'WORLD_HUMAN_CLIPBOARD', gender = 'any' },
    },

    SlotVisuals = {
        Empty = { kind = 'ghost', alpha = 90 },
        Locked = { kind = 'none' },
        Deceased = { kind = 'none' },
    },

    Preview = { Vehicle = true, VehiclePick = 'last', RollIn = 12.0 },

    Identity = {
        NameMin = 2,
        NameMax = 16,
        HeightMin = 150,
        HeightMax = 210,
        HeightDefault = 175,
        BioMax = 300,
        Nationalities = { 'US', 'CA', 'MX', 'BR', 'AR', 'CO', 'GB', 'IE', 'FR', 'DE', 'NL', 'IT', 'ES', 'PT', 'PL', 'SE', 'RU', 'UA', 'TR', 'GR', 'EG', 'MA', 'NG', 'ZA', 'SA', 'AE', 'IR', 'IN', 'PK', 'CN', 'JP', 'KR', 'PH', 'AU' },
    },

    Discord = {
        Commands = {
            characters = 'characters',
            slots = 'slots',
            character = 'character',
            relog = 'relog',
            mycharacters = 'mycharacters',
            myslots = 'myslots',
        },
    },

    Spawn = {
        AerialHeight = 110.0,
        AerialDistance = 140.0,
        Arrivals = { -- what the character does as the live spawn lands (shared/sh_arrivals.lua)
            Weights = { job = 3, kind = 2, default = 1 },
            default = {
                'phone', 'phone_walk', 'call_walk', 'walk_then_phone', 'coffee', 'smoke', 'walk_then_smoke',
                'map', 'impatient', 'hang_out', 'walk', 'walk_by', 'film', 'beer', 'umbrella', 'umbrella_walk', 'taxi',
            },
            kinds = {
                last = { 'walk', 'walk_then_phone', 'impatient', 'coffee' },
                other = { 'map', 'walk_then_map', 'tourist_photo', 'binoculars', 'taxi' },
            },
            jobs = {
                police = { 'cop_idle', 'radio', 'radio_walk', 'investigate', 'guard', 'torch' },
                sheriff = { 'cop_idle', 'radio', 'radio_walk', 'investigate', 'guard', 'torch' },
                ambulance = { 'clipboard', 'clipboard_walk', 'medic_notes', 'radio_walk' },
                mechanic = { 'clipboard', 'clipboard_walk', 'call_walk' },
                tow = { 'valet', 'clipboard_walk', 'radio_walk' },
                taxi = { 'valet', 'impatient', 'phone_upright' },
                garbage = { 'janitor', 'walk' },
                reporter = { 'paparazzi', 'film', 'call_walk' },
                realestate = { 'clipboard_walk', 'call_walk', 'phone_upright' },
                cardealer = { 'clipboard', 'call_walk', 'phone_upright' },
                lawyer = { 'call_walk', 'phone_upright', 'book_walk' },
                judge = { 'book', 'phone_upright' },
                security = { 'guard', 'torch', 'radio' },
                builder = { 'drill', 'clipboard' },
                gardener = { 'leaf_blower', 'walk' },
                student = { 'book_walk', 'phone_walk', 'walk_then_phone', 'map', 'book' },
                teacher = { 'book', 'book_walk', 'clipboard', 'clipboard_walk' },
                principal = { 'clipboard_walk', 'call_walk', 'phone_upright' },
            },
        },
    },

    Onboarding = {
        Resource = 'daddy_onboarding',
        College = { Label = 'Los Santos College' },
    },

    Scenes = { -- presets are copied to the database once; points are local to the anchor (x right, y forward, z up)
        MaxSpots = 10,
        OnlyRoles = true,
        Active = {},
        Season = 'none', -- weather for jobs without a look: auto (by month) | none | winter | halloween | xmas
        Presets = {
            intro = { -- the opening titles' camera tour
                label = 'Opening titles', mode = 'single', anchor = { x = 0.0, y = 0.0, z = 0.0, h = 0.0 },
                time = { h = 19, m = 10 }, weather = 'EXTRASUNNY', population = true,
                spots = {},
                shots = {
                    establish = { ms = 96000, ease = 'smooth', keys = {
                        { pos = { x = 560.0, y = 940.0, z = 420.0 }, look = { x = 711.0, y = 1198.0, z = 350.0 }, fov = 42.0, cut = true },
                        { pos = { x = 640.0, y = 1030.0, z = 400.0 }, look = { x = 711.0, y = 1198.0, z = 350.0 }, fov = 38.0 },
                        { pos = { x = -380.0, y = -1250.0, z = 140.0 }, look = { x = -75.0, y = -818.0, z = 250.0 }, fov = 40.0, cut = true },
                        { pos = { x = -260.0, y = -1100.0, z = 160.0 }, look = { x = -75.0, y = -818.0, z = 260.0 }, fov = 36.0 },
                        { pos = { x = -1760.0, y = -1320.0, z = 40.0 }, look = { x = -1664.0, y = -1126.0, z = 32.0 }, fov = 40.0, cut = true },
                        { pos = { x = -1720.0, y = -1240.0, z = 30.0 }, look = { x = -1664.0, y = -1126.0, z = 32.0 }, fov = 34.0 },
                        -- Galileo Observatory over the city
                        { pos = { x = -560.0, y = 1210.0, z = 390.0 }, look = { x = -438.0, y = 1076.0, z = 352.0 }, fov = 42.0, cut = true },
                        { pos = { x = -520.0, y = 1150.0, z = 375.0 }, look = { x = -438.0, y = 1076.0, z = 352.0 }, fov = 36.0 },
                        -- Legion Square, low over the streets
                        { pos = { x = 195.0, y = -1080.0, z = 160.0 }, look = { x = 195.0, y = -935.0, z = 30.0 }, fov = 44.0, cut = true },
                        { pos = { x = 195.0, y = -1030.0, z = 140.0 }, look = { x = 195.0, y = -935.0, z = 30.0 }, fov = 38.0 },
                        -- Port of Los Santos cranes
                        { pos = { x = 700.0, y = -2700.0, z = 90.0 }, look = { x = 1000.0, y = -3000.0, z = 20.0 }, fov = 44.0, cut = true },
                        { pos = { x = 780.0, y = -2800.0, z = 75.0 }, look = { x = 1000.0, y = -3000.0, z = 20.0 }, fov = 38.0 },
                        -- LSIA runways
                        { pos = { x = -1000.0, y = -2500.0, z = 110.0 }, look = { x = -1300.0, y = -2800.0, z = 14.0 }, fov = 44.0, cut = true },
                        { pos = { x = -1080.0, y = -2580.0, z = 90.0 }, look = { x = -1300.0, y = -2800.0, z = 14.0 }, fov = 38.0 },
                        -- Vespucci Beach along the shore
                        { pos = { x = -1350.0, y = -1650.0, z = 45.0 }, look = { x = -1500.0, y = -1100.0, z = 10.0 }, fov = 44.0, cut = true },
                        { pos = { x = -1420.0, y = -1520.0, z = 38.0 }, look = { x = -1500.0, y = -1100.0, z = 10.0 }, fov = 38.0 },
                    } },
                    sway = false,
                },
            },
        },
    },
}

-- A list (or an empty table) is one value; named tables are filled key by key.
local function isList(t)
    return next(t) == nil or t[1] ~= nil
end

local function fill(target, source)
    for key, value in pairs(source) do
        if target[key] == nil then
            target[key] = value
        elseif type(value) == 'table' and type(target[key]) == 'table' and not isList(value) and not isList(target[key]) then
            fill(target[key], value)
        end
    end
end

-- Fills Config from the defaults; the server calls it again once config/sv_config.lua has loaded.
function ConfigDefaults()
    Config = Config or {}
    fill(Config, DEFAULTS)
end

ConfigDefaults()
