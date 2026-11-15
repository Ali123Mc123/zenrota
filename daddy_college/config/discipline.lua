-- Discipline: detention, an optional fine and a leaderboard. Two ways to serve it (Mode):
--   'public': chores in the garden and halls in front of everyone, given as a number of jobs; it ends when they are done.
--     Places: zones 'discipline_public' (one per floor), spot 'discipline_start' (where jobs are taken), props 'discipline_bin'.
--   'room': the closed room with a timer that cleaning tasks shorten. Places: zone 'discipline_area', spots
--     'discipline_room' (where students are sent), 'discipline_exit' and 'discipline_task' (settings.task picks the kind).
Config.Discipline = {
    Commands = { panel = 'discipline', history = 'disciplinelog' },

    Mode = 'public',          -- 'public' or 'room'; public falls back to room while no 'discipline_public' zone is drawn
    StartMode = 'walk',       -- 'walk' to the start point with a waypoint, or 'teleport'

    -- Public detention is a number of jobs; timed sanctions (campus, permits, scanners) become jobs too.
    Quota = { Min = 1, Max = 20, Presets = { 3, 5, 8, 10, 15 }, SecondsPerJob = 300 },

    Public = {
        StartReach = 4.0,                     -- how close to the start point a job is taken
        StartRadius = 20.0,                   -- the start point counts as inside the areas this far around
        LeaveSeconds = 20, LeavePenalty = 1,  -- leaving the areas: countdown, then back with a job added
        Label = true,                         -- a small 'Detention 4/8' over the student's head
        LabelDistance = 15.0,
        HelpJanitor = true,                   -- may take mopping or litter jobs of a Campus Life incident nearby
    },

    -- Public places kept here: each kind is used only while none is drawn in the admin editor.
    -- DaddyRP: the south-east lawn of the Cayo campus, past the pool, outside the building (community service).
    Places = {
        Zones = { { minZ = 26.0, maxZ = 42.0, points = {
            vec2(5374.0, -5309.0), vec2(5390.0, -5284.0), vec2(5404.0, -5284.0),
            vec2(5408.0, -5300.0), vec2(5396.0, -5326.0), vec2(5372.0, -5322.0),
        } } },
        Start = vec4(5380.88, -5316.23, 31.52, 75.3),                                   -- the cleaning cart
        Bins = { vec3(5391.49, -5295.97, 30.95), vec3(5375.82, -5301.51, 30.96) },     -- the map's own bins
        BinProps = false,                                                                -- true: a bin prop on each
    },

    -- The jobs of public detention: weight picks how often (0 = never), minSeconds is the least a job may take.
    -- A finished job hands the next one out on the spot; the trolley is only for the first one.
    -- DaddyRP: outdoors only, so no mopping, wiping or shelf tidying.
    Jobs = {
        litter = { weight = 4, count = 6, spacing = 3.5, edge = 1.5, minSeconds = 20 },
        sweep = { weight = 3, piles = 4, stages = 3, minSeconds = 20 },
        mop = { weight = 0, puddles = 2, stages = 3, minSeconds = 8 },
        wipe = { weight = 0, count = 3, stages = 2, minSeconds = 8 },
        organize = { weight = 0, game = 'sequence', bank = 'discipline', level = 'easy', minSeconds = 20 },
    },

    -- Models: the first your game has is used; a staged one ('<name>_<state>') shows the work going down.
    Models = {
        start = { 'prop_cleaning_trolly' }, bin = { 'prop_bin_01a' },
        litter = { 'ng_proc_food_bag01a', 'prop_cs_paper_cup', 'ng_proc_litter_plasbot1', 'ng_proc_sodacan_01a', 'ng_proc_paper_02a', 'prop_rub_litter_05' },
        bag = { 'daddy_school_trashbag_hand', 'prop_cs_rub_binbag_01' },
        pile = { 'daddy_school_dust_pile', 'prop_rub_litter_01' }, puddle = { 'daddy_school_puddle', 'm23_2_prop_m32_puddle_01a' },
        stain = { 'daddy_school_stain', 'prop_rub_litter_04' }, shelf = {}, broom = { 'prop_tool_broom' }, mop = { 'prop_cs_mop_s' }, rag = {},
        bucket = { 'm23_2_prop_m32_bucket_mop_01a', 'prop_cs_mopbucket_01' },
    },

    -- The litter bag in the right hand (PH_R_Hand, +X to the ground in the carry clip): hung by its neck, 0.66 m tall.
    Hands = {
        bag = { bone = 28422, pos = vec3(0.64, 0.03, 0.0), rot = vec3(-90.0, 0.0, 90.0) },
    },
    BagClip = { dict = 'move_weapon@jerrycan@generic', clip = 'idle' }, -- upper body only, walking and running stay free
    -- Sweep, mop, wipe: one [E] at a piece works it off in one go; it shrinks every stageMs (the server checks the pace).
    Work = {
        sweep = { stageMs = 2000, dict = 'anim@amb@drug_field_workers@rake@male_a@base', clip = 'base', prop = 'prop_tool_broom', bone = 28422, pos = vec3(-0.01, 0.04, -0.03), rot = vec3(0.0, 0.0, 0.0) },
        mop = { stageMs = 2000, dict = 'move_mop', clip = 'idle_scrub_small_player', prop = 'prop_cs_mop_s', bone = 28422, pos = vec3(0.0, 0.0, 0.12), rot = vec3(0.0, 0.0, 0.0) },
        wipe = { stageMs = 2000, dict = 'timetable@floyd@clean_kitchen@base', clip = 'base', prop = 'prop_sponge_01', bone = 28422, pos = vec3(0.0, 0.0, -0.01), rot = vec3(90.0, 0.0, 0.0) },
    },
    -- World markers per kind (DrawMarker type, size, height over the ground, colour); reach is how close [E] works.
    Marker = {
        reach = 1.6, binReach = 2.6, draw = 35.0,
        litter = { type = 0, size = 0.22, height = 0.6, color = { 245, 205, 70, 210 }, bob = true },  -- small cone over each piece
        sweep = { type = 25, size = 1.2, height = 0.04, color = { 160, 130, 95, 140 } },              -- soft dust ring
        mop = { type = 25, size = 1.4, height = 0.04, color = { 90, 150, 220, 140 } },
        wipe = { type = 25, size = 1.0, height = 0.04, color = { 200, 200, 200, 140 } },
        bin = { type = 0, size = 0.35, height = 1.7, color = { 90, 200, 120, 220 }, bob = true },     -- over the bins once the bag is full
    },
    Throw = { dict = 'missfbi4prepp1', clip = '_bag_throw_garbage_man', ms = 1300, release = 700 },
    BinBagSeconds = 30, -- a thrown bag lies beside the bin this long

    -- Room detention: the time it lasts.
    MinSeconds = 1800,
    MaxSeconds = 7200,
    DurationStep = 300,
    DurationPresets = { 1800, 2700, 3600, 5400, 7200 },
    ReasonMin = 3,
    ReasonMax = 200,

    Fine = { Enabled = true, Min = 0, Max = 100000, Presets = { 0, 1000, 2500, 5000, 10000, 25000 } },

    -- Discipline XP: an approved sanction takes counted XP from the student (the lesson of the offence, then the major,
    -- then the best lesson); a pardon gives it back, a served one keeps it. Levels may drop, and stars, level
    -- certificates and the scholarship drop with them (they come back with the level).
    Xp = {
        Enabled = true,
        PerJob = 6, Min = 10, Max = 120, -- per job of the sanction (a timed one counted as jobs), within Min and Max
        System = 15,                     -- what the school issues itself (campus, permits, a scanner hit) takes this much
        OverrideMax = 200,               -- the principal or a master may type 0..this on the form; teachers cannot
        DailyMax = 150,                  -- the most a student loses in a school day, the rest is not taken (0 = no limit)
        LevelsCanDrop = true,            -- false: the bar drops, the level reached stays
        BlockWeekAward = true,           -- a valid sanction approved in the week keeps a student from student of the week
    },

    ReturnMode = 'saved', -- 'saved': back where the student was taken from; 'fixed': the discipline_exit spot

    -- NoPhoneApps: during detention the Student Phone opens only School, Messages, Phone and Settings.
    Restrictions = { NoVehicle = true, NoWeapons = true, NoPhoneApps = false },

    Tasks = {
        Reduction = 60,   -- seconds taken off per task
        Duration = 8000,  -- ms of work per task
        Cooldown = 15,    -- seconds before the next spot opens
        Distance = 2.0,
        Blip = { sprite = 280, color = 5, scale = 0.8 },
        Marker = { type = 21, size = { x = 0.4, y = 0.4, z = 0.3 }, color = { r = 235, g = 45, b = 45, a = 180 }, offset = 0.0, drawDistance = 15.0, bob = true, rotate = true },
        Kinds = {
            sweep = { icon = 'fa-solid fa-broom', anim = { dict = 'amb@world_human_janitor@male@idle_a', clip = 'idle_a', flag = 49 },
                prop = { model = 'prop_tool_broom', bone = 28422, pos = vec3(-0.01, 0.02, -0.03), rot = vec3(0.0, 0.0, 0.0) } },
            organize = { icon = 'fa-solid fa-boxes-packing', anim = { dict = 'mini@repair', clip = 'fixing_a_ped', flag = 49 } },
            trash = { icon = 'fa-solid fa-trash', anim = { dict = 'amb@world_human_gardener@male@idle_a', clip = 'idle_a', flag = 49 } },
            wipe = { icon = 'fa-solid fa-soap', anim = { dict = 'amb@world_human_bum_wash@male@high@idle_a', clip = 'idle_a', flag = 49 } },
        },
    },

    CandidateBlockCount = 3, -- valid sanctions that keep a student out of school elections
    Announcement = { Scope = 'school', Duration = 12000 },
    LeaderboardLimit = 20,
}
