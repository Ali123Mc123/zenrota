-- Lessons, attendance and the house standings.
Config.ClassPoints = {
    Commands = {
        create = 'lesson',          -- announce a lesson
        start = 'startlesson',      -- start your announced lesson
        finish = 'endlesson',       -- end your lesson
        attendance = 'attendance',  -- attendance of your current or last lesson
        schedule = 'timetable',     -- weekly timetable
        closeAll = 'closelessons',  -- admin: end every running lesson
        code = 'attendcode',        -- a student without a phone types the attendance code: /attendcode 4821
    },

    AllowCustomLessonName = false, -- teachers may type a lesson that is not in the catalog
    SkillTreeOnly = true,         -- only the Skill Tree's lessons (config/academics.lua) are taught; every other one is off
    LessonNameMax = 64,
    SubjectMax = 100,
    MaxClassesPerLesson = 0,      -- 0 = no limit
    RosterPerClass = 150,
    RosterLimit = 600,
    AllowGuests = true,           -- teachers may add a student from another class

    MaxLessonMinutes = 90,        -- a forgotten lesson ends by itself
    TeacherOfflineGrace = 300,    -- seconds a lesson waits for a teacher who left
    EditWindowMinutes = 30,       -- an ended lesson's marks (and its quiz's written answers) can be fixed this long
    -- Past lessons on the tablet: the principal, master and admins always; the lesson's own teacher for OwnHours after its end.
    DeleteLesson = { OwnTeacher = true, OwnHours = 24 },   -- delete the lesson with its marks, quiz and XP
    EditAttendance = { OwnTeacher = true, OwnHours = 24 }, -- change a student's mark (the attendance XP follows)
    AutoAbsentOnEnd = true,       -- unmarked students count as absent
    MinLessonSecondsForAbsent = 120, -- shorter lessons record no absences
    FullLessonMinutes = 10,       -- a lesson this long counts for the house standings and its base XP (Xp.LessonEffort)
    WatchdogMs = 60000,

    -- House standings from lesson attendance: present and late as below, a raw count (not per member).
    Houses = {
        Enabled = true,
        Present = 1, Late = 0.5,
        Top = 5,                  -- attenders on each house's page
        CacheSeconds = 300,       -- tables are worked out again at most this often
        MinRecomputeSeconds = 60, -- after a lesson ended, not sooner than this
        List = {},                -- { name, color } in order; empty: every class in daddycl_classes
    },

    ScheduleEnabled = true,
    AnnounceDuration = 15000,     -- ms the lesson card stays on screen
    AnnounceScope = 'school',     -- who hears the bell: school, students, teachers, all

    -- Lessons with a time start and end by themselves (school clock, Config.TimezoneOffset).
    AutoLesson = { Enabled = true, StartGraceMin = 10, TickMs = 30000 },

    -- [G] marks the classroom, [H] the teacher, from the lesson card.
    Waypoint = { Enabled = true, Key = 47, SummonKey = 74 }, -- [G] marks the classroom, [H] the teacher, while the lesson card shows

    -- Bell and lesson voice. Voices: lesson slug (name in lower case, accents dropped, spaces as _) -> sounds/lessons/<file>.ogg
    -- The recordings are in Turkish, for Turkish lesson names; any other lesson gets the bell alone.
    Bell = {
        Enabled = true, Volume = 0.25, VoiceVolume = 0.45, GapMs = 250,
        OnAnnounced = true, OnStarted = false, OnEnded = true,
        EndedSeconds = 3.5, EndedVolume = 0.20,
        Voices = {
            ingilizce = 'ingilizce', matematik = 'matematik', tarih = 'tarih', ilk_yardim = 'ilkyardim',
            rehberlik_ve_psikoloji = 'rehberlik_psikoloji', muzik = 'muzik', beden_egitimi = 'beden', mekanik = 'mekanik',
            fransiz_dili_ve_edebiyati = 'fransiz_dili', gorsel_sanatlar = 'gorsel_sanatlar', gastronomi = 'gastronomi',
            felsefe = 'felsefe', gazetecilik = 'gazetecilik', sinema_ve_televizyon = 'sinema_televizyon', fizik = 'fizik',
            kimya = 'kimya', drama = 'drama', dans = 'dans', ekonomi = 'ekonomi', cografya = 'cografya', almanca = 'almanca',
            adalet = 'adalet', ascilik = 'ascilik', edebiyat = 'edebiyat', edebiyat_ve_adalet = 'edebiyat_adalet', fransizca = 'fransizca',
            izcilik = 'izcilik', moda_tasarim = 'moda_tasarim', moda_tasarimi = 'moda_tasarim', polislik = 'polislik', psikoloji = 'psikoloji',
            rehberlik = 'rehberlik', resim = 'resim', saglik = 'saglik', tiyatro = 'tiyatro', yazilim = 'yazilim',
        },
    },

    -- A notebook the teacher puts on a desk; students sign themselves in. Off for now: DaddyRP takes attendance by code.
    -- LateAfterMinutes counts for every way of signing (code, QR, notebook), on or off.
    AttendanceSheet = { Enabled = false, PropModel = 'v_med_p_notebook', SignMs = 3000, LateAfterMinutes = 10 },

    -- Attendance code: the teacher opens a fresh code, students inside the classroom type it on the phone.
    AttendanceCode = {
        Enabled = true,
        Digits = 4,              -- code length (4-8); easy ones (1111, 1234, 1212) never come up
        OpenSeconds = 180,       -- a code closes by itself after this; opening it again gives a fresh one
        TeacherRadius = 15.0,    -- a lesson held where the teacher stands: metres from the teacher
        MaxWrong = 5,            -- wrong codes that lock a student out of the lesson's code (the teacher marks them)
        TryGapMs = 1500,         -- least time between two tries
        GraceSeconds = 60,       -- late from the later of the start + LateAfterMinutes and the lesson's first code + this
        AnnounceToRoster = true, -- the lesson's online students hear that it opened (never the code)
        NoticeGap = 60,          -- seconds between two of those notices however often the code is opened
        ShowInRoom = true,       -- "Show the class": the code on the screens of the students in the classroom
        ShowSeconds = 20,        -- how long it shows there
        ShowCooldown = 30,       -- seconds between two shows
        Shortcuts = true,        -- the "all present" and "those in the room present" buttons stay
        PaperKey = 246,          -- Y: a student without a phone takes the paper card to write the code
    },

    -- The removal scan: students at the absence limit set in the Director Panel lose their enrollment.
    -- Off: no absence limit at all; the scan does not run and students see no limit (DaddyRP: off for now).
    AutoExpel = {
        Enabled = false,
        CheckIntervalMinutes = 360,
        OnStart = true,
        DiscordRoles = {},  -- Discord role ids taken from an expelled student (needs the daddy:discord_token convar)
    },
}

-- DaddyRP: the six houses in their order and colours (the same as config/discord.lua); prep and year sections are none.
Config.ClassPoints.Houses.List = {
    { name = 'Valiant', color = '#E63946' }, { name = 'Orion', color = '#F4B400' }, { name = 'Eclipse', color = '#2A9D4B' },
    { name = 'Zenith', color = '#1D7FE0' }, { name = 'Nexus', color = '#CFD8DC' }, { name = 'Apex', color = '#8E44AD' },
}
