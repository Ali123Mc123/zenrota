-- One-day plague event. Nothing happens until an admin starts it (/veba ac); /veba bitir cures everyone.
-- No database: the sickness lives in memory, a resource restart clears it.
Config = {}

Config.Locale = 'tr' -- en | tr

-- Who runs the event and bites: daddy.admin.veba / daddy.admin ACE or framework admin.
Config.Command = 'veba'
Config.Sub = { -- the words after /veba
    start = 'ac', stop = 'bitir', rats = 'fareler', spread = 'bulasma', give = 'ver', cure = 'iyilestir',
    exempt = 'muaf', list = 'liste', rat = 'fare', on = 'ac', off = 'kapat', all = 'herkes',
}

-- The school: decoration rats and catching it by cough only happen inside.
Config.Zone = { center = vec3(5340.0, -5235.0, 28.0), radius = 120.0 }

-- Biting: staff in a rat ped press the key next to a player.
Config.Bite = {
    Key = 'E',
    Reach = 1.6,          -- metres to the bitten player
    Cooldown = 15,        -- seconds between two bites of one biter
    Models = { 'a_c_rat' }, -- the biter must be one of these peds (empty = any ped)
    Invincible = true,    -- staff in the rat ped (/veba fare) cannot be killed
}

-- Stages by minutes since infected: 1 nothing, 2 symptoms, 3 heavy.
Config.Stages = { Symptoms = 3, Heavy = 12 }
Config.MaxSick = 35 -- the most sick players at once (bites and coughs stop above it)

-- Coughing: every Tick seconds each sick player at stage 2+ coughs with Chance; players within Reach catch it with Catch.
Config.Spread = { Enabled = true, Tick = 20, Chance = 0.25, Reach = 2.0, Catch = 0.12 }

-- What the sick player feels (only on their own screen; the cough is an animation others see).
Config.Effects = {
    -- the emote menu's own cough; the sound (web/sounds) is heard by players within Hear metres
    Cough = { dict = 'timetable@gardener@smoking_joint', clip = 'idle_cough', ms = 3000,
        Sounds = { 'cough_1.wav', 'cough_2.ogg' }, Volume = 0.35, Hear = 12.0 },
    Pale = { name = 'rply_saturation_neg', strength = 0.3 },   -- stage 2: washed-out colours
    Dizzy = { name = 'Drunk', strength = 0.35 },              -- stage 3: hazy and pale
    Walk = { m = 'move_m@injured', f = 'move_f@injured' },     -- stage 3: limping, no sprint or jump
    Spell = { name = 'DRUNK_SHAKE', amount = 1.0, every = 45, seconds = 5 }, -- stage 3: a dizzy spell this often
    Bite = { name = 'SMALL_EXPLOSION_SHAKE', amount = 0.12 },
    -- the emote menu's walk style events, so a chosen walk comes back after the limp (false: none)
    WalkStyle = { changed = 'cylex_animmenuv2:client:onWalkSet', set = 'cylex_animmenuv2:client:setWalk' },
}

-- The infirmary: lying there for Seconds cures a player who shows symptoms; cured players stay immune for the day.
Config.Infirmary = {
    coords = vec3(5338.937, -5250.331, 32.037),
    radius = 4.0,
    Seconds = 45,
    Anim = { dict = 'anim@gangops@morgue@table@', clip = 'body_search' },
}

-- Items: the medicine cures anywhere (crafted at the infirmary bench), the mask stops catching it by cough.
Config.Items = {
    Medicine = 'veba_ilac',
    Mask = 'veba_maske',
    MaskMinutes = 30,
    MaskCloth = { component = 1, m = { 68, 0 }, f = { 58, 0 } }, -- worn while it protects: drawable, texture (false: none)
}

-- Who may examine a player (target on a player: shows the stage).
Config.Examine = { Access = 'role:college:teacher, role:college:principal, job:ambulance, ace:daddy.admin', Reach = 2.5 }

-- Decoration rats: local to each player's screen, never networked; they wander and run from people.
Config.Rats = {
    Model = 'a_c_rat',
    Max = 6,          -- at most this many around one player
    PerSpot = 2,
    Near = 35.0,      -- a spot this close to the player gets its rats
    Spots = {         -- canteen, discipline store, infirmary, lockers, lower floor, sports floor
        vec3(5360.2, -5232.8, 31.1), vec3(5321.3, -5225.0, 31.0), vec3(5340.5, -5248.0, 31.0),
        vec3(5324.2, -5249.7, 31.3), vec3(5317.3, -5240.3, 25.2), vec3(5339.4, -5227.1, 20.7),
    },
}
