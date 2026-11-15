-- School security: lock hours, exit permits, the campus boundary, a gate guard and the incident dispatch.
-- The places come from the world: zone 'campus' (the school boundary), spot 'security_return' (where students
-- who leave without a permit are brought back), peds 'security_guard' (settings.doors = door ids they open),
-- zones 'dispatch_quiet' (fights are not reported, e.g. a boxing ring) and 'dispatch_ignore' (nothing is reported).
Config.Security = {
    Commands = { exit = 'exit', lock = 'schoollock', history = 'dispatchlog' },
    -- On another player (no target menu): /<name> [id]; without an id the nearest player within CommandReach m.
    PlayerCommands = { search = 'ustara', checkPermit = 'izinkontrol', givePermit = 'izinver' },
    CommandReach = 3.0,

    -- Doors (ox_doorlock id or name) the campus lock closes from the Security Center.
    LockDoors = {},

    -- Hours the school counts as locked, on the school clock.
    Schedule = { { start = '09:00', finish = '17:00' } },

    Permit = {
        Item = 'exit_permit',
        MaxMinutes = 720,
        GraceMinutes = 10,          -- time to come back after a permit runs out
        OverstaySeconds = 1800,     -- detention for coming back later than that
        -- Students ask at Student Affairs, the principal approves, the paper is collected at the desk.
        Request = { Enabled = true, ClaimMinutes = 60, CooldownSeconds = 60, DefaultMinutes = 15, ReasonMin = 5, ReasonMax = 300 },
        -- With class years (academics): the longest permit a student may ask for, by year (0: none). A missing year uses MaxMinutes.
        -- SuccessBonus adds the best matching extra: rank = in the top N of the week's activity. Empty YearMinutes: off (only
        -- MaxMinutes, no limit shown anywhere), e.g. { prep = 0, year1 = 60, year2 = 120, year3 = 240 }.
        YearMinutes = {},
        SuccessBonus = { { rank = 10, minutes = 60 } },
        PrincipalAboveCap = true, -- the principal may approve past a student's limit (up to MaxMinutes) with a note
        -- Using the paper shows it to the players around; it does not use it up.
        Show = {
            DurationMs = 12000, Radius = 3.0, CooldownMs = 5000,
            Animation = { Dict = 'paper_1_rcm_alt1-9', Clip = 'player_one_dual-9', Flag = 50,
                Prop = 'prop_notepad_01', Bone = 57005, Offset = vec3(0.10, 0.02, -0.03), Rotation = vec3(-90.0, 170.0, 79.0) },
        },
    },

    -- Group trips: a teacher takes students off campus; members need no paper while the trip is out. Off: no Trips app.
    Trips = { Enabled = false, MaxMinutes = 180, MaxStudents = 15, NearbyRadius = 15.0 },

    -- Jobs that are never treated as trespassers or reported to dispatch.
    ExemptJobs = { 'police', 'bcso', 'sasp', 'pbsd', 'sapr', 'cppd', 'ambulance', 'doj' },
    ExemptDead = true, -- dead or downed players are left alone

    -- A student outside the campus without a permit gets a countdown, then is brought back.
    OutOfBounds = {
        Enabled = false, -- DaddyRP: ŞİMDİLİK KAPALI (okul dışındaki öğrenci okula geri atılmıyor)
        CountdownSeconds = 30,
        CheckMs = 2000,
        FadeMs = 800,
        RepeatOffender = 3,         -- returns before a detention follows (0 = never)
        DisciplineSeconds = 1800,
    },

    -- Gate guards stand only while no security player is on duty.
    Guard = { Model = 's_m_m_security_01', Scenario = 'WORLD_HUMAN_GUARD_STAND', UnlockSeconds = 12, Distance = 2.5 },

    Dispatch = {
        Enabled = true,
        FallbackToStaff = false,    -- teachers get the alerts when no security player is online
        HudMs = 8000,
        BlipSeconds = 45,
        Cooldowns = { gunshot = 20, melee_weapon = 15, fight = 25, trespassing = 300, downed = 60, contraband = 60 }, -- seconds
        PhoneItem = 'phone',        -- a downed player needs it to call security ('' = no phone needed)
        DownedKey = 47,             -- [G]
        HistoryKey = 'J',
        ExemptWeapons = { `WEAPON_MUSKET`, `WEAPON_HUNTINGRIFLE`, `WEAPON_SNIPERRIFLE` },
    },
}
