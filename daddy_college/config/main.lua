Config = {}

Config.Locale = 'en' -- en | tr

Config.Debug = true -- admin test commands (/daddyfx); keep off on a live server

-- Test kit for admins (/collegetest): every school system tried in a few clicks (role, items, wish trees, club tables,
-- janitor, detention, lessons, newspaper, certificates). It changes real data: keep it off once the school is live.
Config.TestKit = false
Config.TestKitCommand = 'collegetest'
Config.TestKitItems = { 'school_tablet', 'student_tablet', 'student_phone', 'school_notebook', 'student_card', 'teacher_card', 'exit_permit', 'dorm_keycard', 'game_pad' }

-- The school clock (lesson times, timetable, weekly reset) in hours from UTC; Istanbul is 3.
Config.TimezoneOffset = 3

-- Jobs that make a role. Teachers: job = lowest grade that counts.
Config.Roles = {
    Students = { 'student' },
    Teachers = { teacher = 0, principal = 0 },
    Principals = { 'principal' },
    Security = { 'school_security' },
    Canteen = { 'canteen' },
    Drivers = { 'school_driver' },
    Janitors = { 'janitor' },
    -- The guidance counselor prints certificate papers (staff tablet); jobs with their lowest grade, like Teachers, and
    -- also in Teachers to open the tablet. Empty: the principal prints them.
    Counselors = {}, -- e.g. { teacher = 3 }
    Unemployed = 'unemployed',
    -- Jobs the principal can hire into from the tablet.
    Hire = { student = 'student', teacher = 'teacher', principal = 'principal', security = 'school_security', canteen = 'canteen', driver = 'school_driver', janitor = 'janitor' },
}

-- Masters: citizen ids with every school right and no limits - XP and lesson points they give (any amount, any number
-- of times, past the students' daily limits), rate limits, cooldowns, quiz and permit caps - and the access roles
-- other products ask College for (role:college:principal, teacher, staff, security, counselor, student, member, canteen).
-- What a player is stays as the game says: being a student, a janitor on the incident count, a scholarship already
-- spun, a sheet already signed. The convar daddy_college:master (comma separated) adds more.
Config.Masters = {}

-- New students get the next free number from here.
Config.StudentNumberStart = 1001

-- Discord role id that marks a student excused; needs the daddy:discord_token and daddy:discord_guild convars.
Config.ExcuseDiscordRole = ''

-- Lessons teachers can pick. Leave it out to use the list in locales/<language>.lua.
-- Config.Lessons = { 'Mathematics', 'History' }

-- Payments try these accounts in order.
Config.Money = {
    Accounts = { 'cash', 'bank' },
    ScholarshipDiscount = true,
}

-- Modules can be turned off one by one.
Config.Modules = {
    tablet = true,
    classpoints = true,
    exam = true,
    notes = true,
    wishes = true, -- wish trees and boards anyone may hang a card on (config/wishes.lua); needs notes
    discipline = true,
    affairs = true,
    security = true,
    studentcard = true,
    scholarship = true,
    cardpay = true,
    academics = true, -- lesson XP and levels (config/academics.lua); needs classpoints
    lessonquiz = true, -- quizzes in a running lesson (config/lessonquiz.lua); needs classpoints
    scan = true, -- entrance scanning gates (config/scan.lua); needs security
    awards = true, -- weekly awards voting (config/awards.lua); needs academics
    practicals = false, -- lessons played at a lab bench or first aid station in the world (config/practicals.lua)
    press = true, -- the school newspaper: newsroom desk, racks of copies, the paper item (config/press.lua)
    admin = true,
}

-- The marker on a spot (a classroom, a teacher, an incident): a label seen through walls.
Config.Waypoint = { ArriveDistance = 8.0, DrawDistance = 0.0, Height = 1.35, ScreenWidth = 0.135, Minutes = 5 }

-- Notifications and progress bars: 'college' draws the school's own, 'ox' uses ox_lib's to match your other scripts.
Config.Ui = { Notifications = 'college', Progress = 'college' }

Config.Theme = {
    accent = '#D43D45', accentHover = '#C2353D', accentActive = '#A92D35',
    accentSubtle = '#25171B', accentMuted = '#52252B', accentRing = '#E05B62', accentText = '#F08A8F',
}

Config.Tech = {
    NuiFailsafe = 30000,     -- NUI focus is released after this long without a heartbeat (ms)
    LogPageSize = 25,
    LogRetentionDays = 60,   -- audit rows older than this are removed (0 keeps them)
}

-- Server settings (overrides/daddy_college/config/main.lua)
-- The test server: Turkish, stations on.
Config.Locale = 'tr'
Config.Modules.practicals = true

-- Server settings (servers/daddyrp/daddy_college/config/main.lua)
-- DaddyRP: debug commands off.
Config.Debug = false
-- DaddyRP's school jobs (qbx_core shared/jobs.lua): ogrenci, ogretmen (each grade is a branch), okulmuduru (Okul İdaresi;
-- every grade runs the school, as on this server before), guvenlik, kantin (Kantin ve Temizlik: canteen and janitor in one
-- job, so it is in both lists and hired once), servis.
Config.Roles.Students = { 'ogrenci' }
Config.Roles.Teachers = { ogretmen = 0, okulmuduru = 0 }
Config.Roles.Principals = { 'okulmuduru' }
Config.Roles.Security = { 'guvenlik' }
Config.Roles.Canteen = { 'kantin' }
Config.Roles.Drivers = { 'servis' }
Config.Roles.Janitors = { 'kantin' }
-- DaddyRP: 12 aktif ders (Yazılım kaldırıldı); qbx_core ogretmen rütbeleri (1-13) aynı sırada, 5 boş.
Config.Lessons = { 'Müzik', 'Resim', 'Dans', 'Beden Eğitimi', 'Aşçılık', 'Mekanik', 'Gazetecilik', 'Hukuk', 'Sağlık', 'Polislik', 'Almanca', 'Biyoloji' }
Config.Roles.Hire = { student = 'ogrenci', teacher = 'ogretmen', principal = 'okulmuduru', security = 'guvenlik', canteen = 'kantin', driver = 'servis' }
-- DaddyRP: the admin test kit is on while the school is being tested.
Config.TestKit = true
-- DaddyRP's master.
Config.Masters = { 'T15388EJ' }
