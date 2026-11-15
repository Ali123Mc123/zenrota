Config = {}

Config.Locale = 'tr' -- en | tr

-- Role cards. DiscordRole empty: anyone may pick it; set: the daddy:discord_token and daddy:discord_guild convars are needed.
Config.Roles = {
    civil = { Enabled = true },
    student = { Enabled = true, DiscordRole = '', Job = 'student', Grade = 0 },
    teacher = { Enabled = true, DiscordRole = '', Job = 'teacher', Grade = 0 },
}

-- Where each role spawns when the forms are done; nil keeps the player where they are.
-- Example: student = vec4(-1636.2, 180.4, 61.8, 300.0)
Config.Spawns = {
    student = nil,
    teacher = nil,
}

-- Items given once when a role is picked (testing). Empty or nil: none.
Config.RoleItems = {
    student = { 'student_phone', 'student_tablet', 'school_notebook' },
    teacher = { 'school_tablet', 'school_notebook' },
}

-- A one-time "take my starting items" option at Student Affairs (College), for characters who picked their role before
-- RoleItems was on. Off: the option is not shown. A character who got RoleItems at the pick is not offered it.
Config.StarterKit = {
    Enabled = false,
    Items = {
        student = { 'student_phone', 'student_tablet', 'school_notebook' },
        teacher = { 'school_tablet', 'school_notebook' },
    },
}

-- Campus shots behind the forms: the camera glides from `from` to `to` while looking at `look`, then cuts to the
-- next shot. Empty: the forms lie on a dark desk instead.
-- Example: { from = vec3(-1700.0, 120.0, 90.0), to = vec3(-1640.0, 150.0, 85.0), look = vec3(-1630.0, 200.0, 62.0), fov = 50.0, seconds = 14 }
Config.Cameras = {}

Config.Quiz = {
    Questions = 14,       -- drawn from the pool for each student, plus one final question
    PerCategory = 2,      -- at most this many questions from one category
    QuestionSeconds = 0,  -- DaddyRP: süre yok (0 = zamanlayıcı kapalı); 20 = cevap baloncukları 20 sn'de solar
    Tolerance = 3,        -- a class this many students fuller than the emptiest open class is skipped
    Preferences = 3,      -- how many of the student's best classes are tried before the emptiest one
}

-- A 'class ceremony' point at school for students whose ceremony did not open; only they see it. nil: none.
-- Example: Config.QuizPoint = { Coords = vec3(-1636.2, 180.4, 61.8), Radius = 1.2 }
Config.QuizPoint = nil

Config.ClassmateNotice = true -- online classmates are told when a new student joins their class
Config.RoleLossAlert = false  -- true: students and teachers who lost their Discord role are reported to admins, never removed

Config.Commands = {
    ResetRole = 'rolsifirla',    -- /rolsifirla [id]: forget the role, class and job; the role screen opens again
    ResetClass = 'sinifsifirla', -- /sinifsifirla [id]: send a student through the ceremony again
    MakeStudent = 'ogrenci',     -- /ogrenci [id] (admins): the character becomes a student and takes the class ceremony
    MakeStudentDiscord = {},     -- Discord user ids that may use it too (school staff who are not admins)
    Test = 'torentest',          -- /torentest [rol]: open the ceremony (or the role screen first) without saving anything
    ResetJob = 'unemployed',     -- the job /rolsifirla gives back
}

-- Server settings (servers/daddyrp/daddy_onboarding/config.lua)
-- DaddyRP's Discord roles for the student and teacher picks.
-- Live: student and teacher need their Discord role (the daddy:discord_token and daddy:discord_guild convars).
Config.Roles.student.DiscordRole = '1563951522717638776'
Config.Roles.teacher.DiscordRole = '1526700244568510515'
-- DaddyRP's school jobs: the student and teacher picks give ogrenci and ogretmen.
Config.Roles.student.Job = 'ogrenci'
Config.Roles.teacher.Job = 'ogretmen'
-- DaddyRP: sınıf sınavı noktası Cayo kampüsünde, zemin kat holündeki Öğrenci İşleri masasının önünde.
Config.QuizPoint = { Coords = vec3(5337.34, -5236.23, 32.0), Radius = 1.2 }
-- DaddyRP (K1, on since 2026-11-10): a role pick gives its starting items (students: phone, tablet, notebook; teachers:
-- school tablet, notebook), and characters made before that take them once at Student Affairs. The tablet stays in
-- the student shop for those who lose it.
Config.RoleItems = Config.StarterKit.Items
Config.StarterKit.Enabled = true

-- DaddyRP: college staff who are not admins may use /ogrenci.
Config.Commands.MakeStudentDiscord = { '650216665132302338', '1360030365237903491', '853978161528307723', '645472700889956383' }
