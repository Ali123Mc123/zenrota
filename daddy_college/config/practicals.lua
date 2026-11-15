-- Lessons played at a station in the world: a lab bench and a first aid station placed from /collegeadmin. Props come
-- out only while someone plays and everyone near sees the work; the score comes from the minigame engine
-- (recipes and rhythms in config/minigames.lua). Used by lesson activity rounds and free practice.
-- The player plays with the mouse (pick, hold) while a camera looks at the station; Esc leaves.
local SHOTS = 'anim@amb@nightclub@mini@drinking@drinking_shots@ped_a@normal@'
local SHOTS_F = 'anim@amb@nightclub@mini@drinking@drinking_shots@ped_a@normal@heeled@'

Config.Practicals = {
    Reach = 2.5,            -- metres from the station to play
    SyncRadius = 40.0,      -- players this close see the station's props and effects
    LockSeconds = 600,      -- a station frees itself after this even if something hangs
    TimingSkewMs = 120,     -- a press's own time counts only this close to when the server got it

    -- Without a lesson round a student may practise at a station (no score anywhere).
    Practice = { Enabled = true, Level = 'easy', Banks = { lab_bench = 'chemistry', first_aid_station = 'first_aid' } },

    -- Lesson rounds: stations are fewer than students, so each station takes them in turn.
    Rounds = { PerTurnSeconds = 120, TurnWaitSeconds = 45, MaxRoundMinutes = 20, StationReach = 30.0 },

    StepsPerSecond = 10,    -- a player's steps the server takes in a second
    -- The shot solver (section 6): EaseMs in from the game camera, MoveMs between shots; a capsule of Radius from the
    -- target to the camera, a hit pulls it Margin before the wall, never nearer than Nearest (else it turns); Edge: the
    -- screen margin the points stay inside; Widen: degrees the view may open; NearClip and depth of field (Dof, close
    -- shots only) for shots nearer than Close. Panels: where the page covers the screen (0-1) until it says.
    Camera = { Enabled = true, EaseMs = 600, MoveMs = 450, Radius = 0.18, Margin = 0.12, Nearest = 0.45, Edge = 0.08, Widen = 10.0,
        NearClip = 0.05, Close = 0.9, Dof = false, ResultMs = 1500,
        Panels = { lab_bench = { { x0 = 0.8, y0 = 0.0, x1 = 1.0, y1 = 1.0 } },
            first_aid_station = { { x0 = 0.0, y0 = 0.2, x1 = 0.2, y1 = 0.8 }, { x0 = 0.82, y0 = 0.55, x1 = 1.0, y1 = 1.0 } } } },
    Limits = { ActiveStationsPerClient = 4 },
    -- /practicaldebug (with Config.Debug): each near station's frame, layout points, stand point and state.
    -- tune: an admin kneels at a first aid station and sets where the student's hands and face land (saved for everyone)
    Commands = { debug = 'practicaldebug', tune = 'cprayar' },

    -- Custom models (lab glassware, the manikin) come from this resource; without it the fallbacks are used.
    PropsResource = 'daddy_college_props',

    -- The editor measures each station once (/collegeadmin, world editor) and saves its surface with it: 'body' puts our
    -- bench or mat on the floor, 'map' uses a table the map already has. Normals are the hit normal's z (1 = level);
    -- steps and flatness in metres; Clear: free height over the top; Stand: the capsule where the student stands or
    -- kneels; the camera needs a free capsule, never pulled nearer its target than CameraNearest.
    Survey = {
        TableNormal = 0.995, FloorNormal = 0.985, FloorStep = 0.015, MapFlat = 0.005, StandFloor = 0.03, Corner = 0.02,
        EdgeStep = 0.02, EdgeMax = 1.5, EdgeRise = 0.015,
        Clear = { lab_bench = 0.45, first_aid_station = 1.0 },
        Stand = { lab_bench = { low = 0.3, high = 1.7, radius = 0.30 }, first_aid_station = { low = 0.25, high = 1.1, radius = 0.35 } },
        CameraRadius = 0.18, CameraNearest = 0.6,
        Standin = 'a_m_y_business_01', Kneel = 'CODE_HUMAN_MEDIC_KNEEL', -- the ghost person while placing
    },
    -- Every client checks the saved surface once when it comes near (collision loaded): a body whose floor moved sits
    -- on the floor it finds; a map table that moved marks the station broken until an admin measures it again.
    Validate = { Distance = 12.0, Tolerance = 0.02 },
    StandShift = 0.3, -- a stand point someone else takes slides along the edge at most this far

    -- Bodies the editor knows: top = the work surface over the model's origin, rect = the usable part of it in the
    -- model's own metres (x0..x1 across, y0..y1 deep, y0 the student's side); what is missing comes from its box.
    Models = {
        xm_prop_lab_desk_02 = { top = 0.90, rect = { y1 = 0.16 } }, -- the front 70 cm: the back is out of reach
        xm_prop_lab_desk_01 = { top = 0.95, rect = { y0 = -0.628, y1 = 0.18 } },
        daddy_cl_lab_bench = { top = 0.90, rect = { x0 = -0.85, x1 = 0.74, y0 = -0.325, y1 = 0.325 } }, -- clear of the gas tap
        prop_yoga_mat_01 = { top = 0.024 },
    },

    -- A prop in a hand (section 5.1): bone ID, offset and rotation per model (default for the rest); tuned in QA.
    Hold = {
        default = { bone = 28422, offset = vec3(0.0, 0.0, -0.03), rotation = vec3(0.0, 0.0, 0.0) },
        xm3_prop_xm3_lsd_bottle_02b = { bone = 28422, offset = vec3(0.0, 0.0, -0.06), rotation = vec3(0.0, 0.0, 0.0) },
        -- our hand props have their origin where the hand holds them
        daddy_cl_stir_rod = { bone = 28422, offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
        daddy_cl_reagent_bottle_red = { bone = 28422, offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
        daddy_cl_reagent_bottle_blue = { bone = 28422, offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
        daddy_cl_reagent_bottle_green = { bone = 28422, offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
        daddy_cl_reagent_bottle_yellow = { bone = 28422, offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
        daddy_cl_reagent_bottle_white = { bone = 28422, offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
        prop_safety_glasses = { bone = 31086, offset = vec3(0.05, 0.08, 0.0), rotation = vec3(0.0, 90.0, 180.0) },
    },

    -- Clip numbers (section 5.9): phases (0-1) where the hand touches what it takes (contact), where the pour holds,
    -- where a compression starts and ends; the CPR pair's own frame from their mover tracks: char_b's chest at the
    -- bottom of a compression and char_a's start (x right, y forward of the clips' origin, yaw in degrees), the clips
    -- turned from the manikin by turn; hands: how high the hand bones are over what they press. pour.mouth (where the
    -- beaker's mouth is in the pour clip's own frame, vec3) comes from /pqa calib; until then the pour plays where the
    -- student stands, upper body only.
    Calibration = {
        pickup = { contact = 0.45 },
        button = { contact = 0.4 },
        pour = { hold = 0.42, mouth = nil },
        cpr = { chest = vec3(0.031, 0.895, 0.0), rescuer = vec3(-0.553, 0.509, 0.0), yaw = -56.6, turn = 180.0, hands = 0.05,
            press = { from = 0.30, cut = 0.85 } },
    },
    -- G3 (A6 picks): the held pour as a networked scene of the ped only, so watchers see it stop too.
    Sync = { PourScene = false },
    -- The game's own sounds (no downloads): a compression deep enough, the burner lighting, the rod on glass.
    Sounds = {
        press = { name = 'CLICK_BACK', set = 'WEB_NAVIGATION_SOUNDS_PHONE' },
        ignite = { name = 'NAV_UP_DOWN', set = 'HUD_FRONTEND_DEFAULT_SOUNDSET' },
        stir = { name = 'NAV_LEFT_RIGHT', set = 'HUD_FRONTEND_DEFAULT_SOUNDSET' },
        -- a step or a game that went right or wrong, and the CPR trainer's beep (good rhythm, too fast or slow)
        good = { name = 'Beep_Green', set = 'DLC_HEIST_HACKING_SNAKE_SOUNDS' },
        bad = { name = 'Beep_Red', set = 'DLC_HEIST_HACKING_SNAKE_SOUNDS' },
        button = { name = 'Press', set = 'DLC_SECURITY_BUTTON_PRESS_SOUNDS' },
    },
    Goggles = 'prop_safety_glasses', -- on the student's head while they play (everyone near sees them)

    -- Liquid colours: a model per colour (scaled for the level) and a tint for the pour stream (r, g, b 0-1).
    Liquids = {
        clear = { model = 'daddy_cl_liquid_clear', tint = { 0.85, 0.9, 0.95 } },
        pale_blue = { model = 'daddy_cl_liquid_pale_blue', tint = { 0.55, 0.75, 1.0 } },
        deep_blue = { model = 'daddy_cl_liquid_deep_blue', tint = { 0.1, 0.25, 0.95 } },
        green = { model = 'daddy_cl_liquid_green', tint = { 0.25, 0.8, 0.35 } },
        pink = { model = 'daddy_cl_liquid_pink', tint = { 1.0, 0.45, 0.7 } },
        amber = { model = 'daddy_cl_liquid_amber', tint = { 0.95, 0.6, 0.15 } },
        milky = { model = 'daddy_cl_liquid_milky', tint = { 0.95, 0.95, 0.9 } },
        murky = { model = 'daddy_cl_liquid_murky', tint = { 0.35, 0.3, 0.2 } },
    },
    Caps = { 'red', 'blue', 'green', 'yellow', 'white' }, -- reagent bottles by slot: daddy_cl_reagent_bottle_<cap>

    -- Where things stand comes from the station's saved surface (its usable top, settings.surface), so any bench, mat
    -- or map table fits. Spots by the top's edges, front being the student's side (shared/practicals_frame.lua):
    --   x = 'left' | 'right' (dx in from that edge) or the middle (dx to the right); y = 'front' | 'back' (dy in) or the
    --   middle (dy forward); on = another prop it stands on. on = vec3(x, y, z): from the top's middle (dressing).
    --   stand = vec3(x, y, 0): on the floor, x from the middle, y out in front of the front edge.
    -- Every prop sits on its spot by its own box (the middle of its bottom on the point, wherever its pivot is).
    Kinds = {
        lab_bench = {
            game = 'lab_mix',
            Model = 'daddy_cl_lab_bench',         -- the school's own bench (daddy_college_props)
            Idle = { model = 'daddy_cl_test_tube_rack', on = vec3(-0.67, 0.0, 0.0) }, -- the one dressing prop while nobody plays
            -- Placed in this order: the burner, the tripod over it and the beaker on top in the middle, the glass rod
            -- beside them, the bottles in a row at the back (two rows when one does not fit), the tube rack (dropped
            -- when there is no room).
            Layout = {
                stand = vec3(0.0, 0.45, 0.0),
                -- flame: the burner's mouth over its base (flameModel lit there while it heats), knob: its gas valve
                heater = { model = 'daddy_cl_bunsen', fallback = 'xm3_prop_xm3_lsd_hplate_01a', x = 'mid', y = 'front', dy = 0.30, flame = 0.14,
                    flameModel = 'daddy_cl_burner_flame', knob = vec3(0.0, -0.04, 0.022) },
                tripod = { model = 'daddy_cl_tripod', on = 'heater' },
                beaker = { model = 'daddy_cl_beaker', fallback = 'xm3_prop_xm3_lsd_beaker_01a', on = 'tripod' },
                liquid = { lift = 0.0015, full = 200 },  -- over the beaker's bottom; the ml that fill it
                rod = { model = 'daddy_cl_stir_rod', fallback = 'prop_pencil_01', x = 'mid', dx = -0.24, y = 'front', dy = 0.12, radius = 0.018,
                    tip = vec3(0.0, 0.0, -0.15) },    -- the rod's lower end from its grip (its origin)
                bottles = { model = 'daddy_cl_reagent_bottle_%s', fallback = 'xm3_prop_xm3_lsd_bottle_02b', y = 'back', dy = 0.10, gap = 0.12,
                    mouth = vec3(0.0, 0.0, 0.115) },  -- the cap's top from the bottle's grip (its origin)
                rack = { model = 'daddy_cl_test_tube_rack', fallback = 'xm3_prop_xm3_rack_vial_01a', x = 'left', dx = 0.18, decor = true },
                step = 0.35,                      -- the student steps at most this far along the bench to reach a bottle
                tilt = 70.0,                      -- a bottle pours only when tipped more than this from upright
            },
            -- The camera: on = where it is (from the top's middle), look = what it looks at. Behind the student's right
            -- shoulder, their head out of the frame; pulled in front of a wall behind it.
            Camera = { on = vec3(0.45, -1.55, 1.10), look = vec3(0.0, 0.0, 0.0), Fov = 46.0 },
            -- The shots (section 6.2): target = a layout point (up: metres over it), yaw from the way the student faces
            -- (0 behind them, 180 facing them), pitch (negative looks down), dist, fov; keys: the points that stay in the
            -- free part of the screen. The solver turns a shot off walls and heads; Camera above is the last resort.
            Shots = {
                overview = { target = 'centre', yaw = 20.0, pitch = -38.0, dist = 1.55, fov = 46.0, keys = { 'beaker', 'heater', 'bottle 1', 'bottle 5' } },
                pour = { target = 'beaker', up = 0.12, yaw = 145.0, pitch = -18.0, dist = 0.60, fov = 34.0, keys = { 'beaker' } },
                heat = { target = 'heater', up = 0.10, yaw = 180.0, pitch = -10.0, dist = 0.55, fov = 36.0, keys = { 'heater', 'beaker' } },
                stir = { target = 'beaker', up = 0.06, yaw = 0.0, pitch = -55.0, dist = 0.50, fov = 36.0, keys = { 'beaker' } },
                result = { target = 'beaker', up = 0.06, yaw = 180.0, pitch = -12.0, dist = 0.65, fov = 30.0, keys = { 'beaker' } },
            },
            -- The bar clips made for pouring at a counter (section 5.3): idle the whole time under the rest, which play on
            -- the upper body (flag 48, 49 looped), so the student never turns or slides. The button clip has no female dict.
            Anims = {
                idle = { dict = SHOTS, female = SHOTS_F, clip = 'idle', loop = true },
                pickup = { dict = SHOTS, female = SHOTS_F, clip = 'pickup', flag = 48 },
                hold = { dict = SHOTS, female = SHOTS_F, clip = 'glass_hold', flag = 49 },
                pour = { dict = SHOTS, female = SHOTS_F, clip = 'pour_one', flag = 48 },
                button = { dict = 'anim@scripted@heist@ig3_button_press@male@', clip = 'button_press', flag = 48 },
            },
            -- Effects by their names in the game's particle dictionaries; ms: how long one plays (none: until stopped),
            -- fallback: tried when the first does not start. /daddyfx practicals plays them all.
            Fx = {
                pour = { asset = 'core', name = 'ent_amb_water_roof_pour', scale = 0.08 },
                fizz = { asset = 'core', name = 'ent_amb_bubble_stream', scale = 0.3, ms = 2000 },
                steam = { asset = 'core', name = 'ent_sht_steam', scale = 0.3, ms = 1500 },
                wrong = { asset = 'core', name = 'ent_brk_steam_burst', scale = 0.35, ms = 1500 },
                ruined = { asset = 'core', name = 'exp_grd_bzgas_smoke', fallback = 'ent_amb_smoke_general', scale = 0.12, ms = 3000 },
                heat = { asset = 'core', name = 'ent_amb_steam', scale = 0.15 },
                spark = { asset = 'core', name = 'ent_amb_sparking_wires', scale = 0.35, ms = 400 },
                flame = { asset = 'core', name = 'ent_amb_candle_flame', scale = 1.4 },
                stir = { asset = 'core', name = 'ent_amb_bubble_stream', scale = 0.08 },
                splash = { asset = 'core', name = 'liquid_splash_water', scale = 0.05, ms = 300 },  -- on the liquid while it pours
                passed = { asset = 'scr_fbi5a', name = 'scr_fbi5_dry_ice', scale = 0.25, ms = 2000 }, -- round the beaker at a pass
            },
            -- A right reaction: the fizz with this foam over the liquid, growing and going (none without the model);
            -- a new colour fades in over FadeMs under it. At most Loops looping effects at once per station.
            Foam = { model = 'daddy_cl_foam', ms = 2000 }, FadeMs = 300, Loops = 2,
            MinPourMs = 400, PourMlPerSecond = 40, HeatFullMs = 4000,
            -- The stir step (section 5.4): held this long (ms) with at least this many turns; the client's turns count
            -- at most this many a second.
            Stir = { MinMs = 1500, MaxMs = 7000, MinTurns = 3, TurnsPerSecond = 3 },
        },

        first_aid_station = {
            game = 'cpr',
            Model = 'prop_yoga_mat_01',
            Idle = { model = 'prop_med_bag_01b', on = vec3(0.75, 0.3, 0.0) },
            Layout = {
                -- The manikin lies on the mat along its length (heading added to the mat's, 180 more when the editor found
                -- room to kneel only on the other side); its parts are given from the manikin's own origin, turned with
                -- it. The chest pad and the head hang on their own pivots (at), the rest sits on its spot. The student
                -- kneels where the CPR clips start (Calibration.cpr); kneel is the stand-in without it.
                -- idle: the one-piece manikin lying there while nobody trains, same origin as model (no jump on the swap).
                manikin = { model = 'daddy_cl_cpr_manikin', idle = 'daddy_cl_cpr_manikin_idle', on = vec3(0.0, 0.0, 0.0), heading = 90.0 },
                chest = { model = 'daddy_cl_cpr_manikin_chest', at = vec3(0.0, -0.1, 0.19), travel = 0.045, rise = 0.007 },
                -- tilted: the body with its neck collar following the head, swapped in while the head is tilted back by
                -- tilt degrees and lifted by lift metres (the collar covers the seam only at exactly that pose).
                head = { model = 'daddy_cl_cpr_manikin_head', at = vec3(0.0, 0.24, 0.099), tilt = 22.0, lift = 0.01,
                    tilted = 'daddy_cl_cpr_manikin_tilted' },
                arm = { model = 'daddy_cl_training_arm', done = 'daddy_cl_training_arm_wrapped', at = vec3(-0.55, 0.25, 0.0) },
                roll = { model = 'daddy_cl_bandage_roll' },
                kneel = vec3(0.59, 0.26, 0.0), kneelHeading = 123.0,
                reach = 0.70, -- how far in front of the student the CPR clip's hands come down (measured on their ped once it plays)
                -- Without the props resource: a ped lying on the mat plays the partner clips (its clip lies 0.9 m
                -- below its origin, so the origin is that high over the mat).
                fallbackPed = { model = 's_m_m_scientist_01', at = vec3(0.0, 0.0, 0.9), heading = 0.0 },
            },
            Hand = { bone = 28422, offset = vec3(0.05, 0.0, 0.0), rotation = vec3(0.0, 90.0, 0.0) },
            -- From the manikin's origin: on = where the camera is, look = what it looks at. Across the manikin from the
            -- student (their face in view), on the chest pad; pulled in front of a wall behind it.
            Camera = { on = vec3(-1.20, 0.20, 1.10), look = vec3(0.0, -0.1, 0.19), Fov = 46.0 },
            -- The shots (section 6.3), the same way as the lab's; 180 is across the manikin, the student's face in view.
            Shots = {
                overview = { target = 'chest', yaw = 180.0, pitch = -32.0, dist = 1.50, fov = 46.0, keys = { 'chest', 'head pivot' } },
                -- from the side, low: the pad going down under the hands shows
                press = { target = 'chest', yaw = 180.0, pitch = -24.0, dist = 1.35, fov = 44.0, keys = { 'chest' } },
                breath = { target = 'head pivot', up = 0.06, yaw = 180.0, pitch = -15.0, dist = 0.75, fov = 38.0, keys = { 'head pivot' } },
                result = { target = 'manikin', yaw = 180.0, pitch = -25.0, dist = 1.60, fov = 44.0, keys = { 'chest', 'head pivot' } },
            },
            -- The CPR trainer beside the manikin (on: from the mat's middle): its light shows everyone near how the
            -- rhythm goes (every fifth compression), the same colours as the trainer on the student's screen.
            -- states: the same device with one lamp lit in that colour (good the big one, fast the one marked down, slow
            -- the one marked up), so watchers tell fast from slow; lamp: the big lamp from the device's origin.
            Trainer = { model = 'daddy_cl_cpr_monitor', fallback = 'prop_cs_tablet', on = vec3(0.70, 0.30, 0.0), led = vec3(0.0, 0.0, 0.03),
                lamp = vec3(0.0, -0.024, 0.038),
                states = { good = 'daddy_cl_cpr_monitor_good', fast = 'daddy_cl_cpr_monitor_fast', slow = 'daddy_cl_cpr_monitor_slow' },
                colours = { good = { 79, 174, 100 }, fast = { 224, 161, 74 }, slow = { 224, 161, 74 } }, seen = 25.0 },
            -- Every move is one sequence: a transition, then the pose's loop, so the student never stands up between
            -- steps; exit stands them up at the end. scene = true: played at the CPR clips' own origin (from the
            -- manikin, section 5.6); a compression starts on its way down (Calibration.cpr.press).
            Anims = {
                kneel = { dict = 'amb@medic@standing@tendtodead@enter', clip = 'enter' },
                exit = { dict = 'amb@medic@standing@kneel@exit', clip = 'exit' },
                ready = { dict = 'mini@cpr@char_a@cpr_def', clip = 'cpr_pumpchest_idle', loop = true, scene = true },
                press = { dict = 'mini@cpr@char_a@cpr_str', clip = 'cpr_pumpchest', scene = true },
                toBreath = { dict = 'mini@cpr@char_a@cpr_str', clip = 'cpr_cpr_to_kol', scene = true },
                breath = { dict = 'mini@cpr@char_a@cpr_str', clip = 'cpr_kol_idle', loop = true, scene = true },
                toPress = { dict = 'mini@cpr@char_a@cpr_str', clip = 'cpr_kol_to_cpr', scene = true },
                bandage = { dict = 'mini@repair', clip = 'fixing_a_ped', loop = true },
                -- The lying ped's partner clips (fallback only), at the same origin.
                partnerReady = { dict = 'mini@cpr@char_b@cpr_def', clip = 'cpr_pumpchest_idle', loop = true, scene = true },
                partnerPress = { dict = 'mini@cpr@char_b@cpr_str', clip = 'cpr_pumpchest', scene = true },
                partnerBreath = { dict = 'mini@cpr@char_b@cpr_str', clip = 'cpr_kol_idle', loop = true, scene = true },
            },
            Bandage = false, -- the bandage step needs the training arm props (not in daddy_college_props yet)
            MinPressGapMs = 250, KneelReach = 1.2,
            Weights = { rhythm = 0.6, breaths = 0.2, steps = 0.2 },
        },
    },
}
