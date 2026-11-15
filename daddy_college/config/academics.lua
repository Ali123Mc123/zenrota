-- Academic progress: every lesson has its own XP and level. Effort (quizzes, full lessons, exams, study) earns XP;
-- sitting in a lesson only counts as far as effort goes, so attendance alone never levels anyone up.
Config.Academics = {
    Commands = { card = '' }, -- disabled per design: levels & skill tree are viewed on Student Tablet, Staff Tablet, and Student Phone

    Levels = { 0, 100, 250, 450, 700, 1000, 1400, 1900, 2500, 3200 }, -- counted XP for level 1, 2, 3 ... 10
    LevelsCanDrop = false,      -- a teacher's minus XP lowers the bar, never the level reached
    MilestoneLevels = { 3, 6, 10 }, -- Yörünge (3), Parlayan Yıldız (6), Süpernova (10)

    Xp = {
        Present = 10, Late = 5,  -- attendance XP for a lesson
        LessonEffort = 5,        -- a lesson of ClassPoints.FullLessonMinutes or more: this much effort XP to everyone present or late
        MinigamePerScore = 0.3,  -- a lesson activity's 0-100 score (a quiz activity round, another product) -> XP
        StudyPerUnit = 10,       -- a passed Student Tablet unit quiz
        StaffMax = 50,           -- a teacher's manual change, either way
        AttendanceMatch = 1.0,   -- attendance XP counts up to effort XP times this
        -- A passed exam: Xp at 100% (less for a lower score) plus Pass; only the first pass of an exam pays.
        Exam = {
            quiz = { Xp = 20, Pass = 5 },
            midterm = { Xp = 40, Pass = 10 },
            final = { Xp = 60, Pass = 15 },
            project = { Xp = 40, Pass = 10 },
            scholarship = { Xp = 0, Pass = 0 },
        },
    },

    -- XP a student can get in one school day (Config.TimezoneOffset); 0 = no limit.
    Daily = {
        PerLesson = 80,
        Total = 200,
        Sources = { attendance = 30, study = 40 }, -- per lesson
        SourceTotals = { quiz = 60 },              -- over every lesson of the day (quiz rewards)
        ExamCountsToTotal = false,                  -- false: exams are outside the daily limits
    },

    -- Terms are opened, moved and closed by the principal on the tablet; this is a new term's length.
    Term = { DefaultDays = 28 },

    -- Class years in order; the last one is graduation. mastered: the lessons at Promotion.Level a student needs for
    -- that year (none: 0, everyone starts there). label: nil uses the locale academics.year_<key>; short goes into
    -- section names.
    Years = {
        { key = 'prep' },
        { key = 'year1', mastered = 3 },
        { key = 'year2', mastered = 6 },
        { key = 'year3', mastered = 9 },
        { key = 'graduate', mastered = 12 },
    },
    -- A student moves up the moment a lesson reaches Level and the lessons at Level reach the next year's mastered;
    -- levels never reset, the year never goes down by itself. Letter: the Mail letter (the paper one without a phone).
    Promotion = { Level = 10, Letter = true },
    Graduation = { SetJob = false, Job = 'unemployed' }, -- SetJob: a graduate gets this job

    -- Departments: their lessons by year (required too), and how many students they take over all years (0 = no limit).
    -- Leave empty to run without departments. label: nil uses the locale academics.department_<key>.
    Departments = {
        -- police = { short = 'POL', capacity = 45, lessons = { year1 = { 'justice', 'first_aid' }, year2 = { 'justice' } } },
        -- medicine = { short = 'MED', capacity = 45, lessons = { year1 = { 'biology', 'first_aid' } } },
    },
    DepartmentFrom = 'year1', -- the year that needs a department; students choose in the year before
    PreferenceCount = 3,

    -- Major (Ana Dal / Uzmanlık): College electives. Up to Max of the Skill Tree lessons, +BonusMultiplier XP in them; kept into the next term;
    -- a first pick any time in an open term, changes only in its first ChooseDays days.
    Electives = {
        Max = 2,
        ChooseDays = 14,
        BonusMultiplier = 1.25,
        Lessons = {
            'beden_egitimi', 'mekanik', 'biyoloji', 'almanca', 'gazetecilik', 'muzik',
            'resim', 'dans', 'saglik', 'polislik', 'ascilik', 'hukuk',
        },
    },

    -- Sections are classes. Auto: a student entering a department goes into its least full section; a full one opens
    -- the next, named from Name ({year}, {dept}, {letter}). Moving up a year never changes the section (the house).
    Sections = { Auto = false, Size = 15, Name = '{year}-{dept}{letter}' },

    -- Certificates come by themselves once a student meets their earn rule (same leaves as Unlocks below).
    -- label: nil uses the locale academics.certificate_<key>.
    Certificates = {
        -- first_aid = { earn = { lesson = 'first_aid', level = 3 } },
    },
    CertificateItem = 'school_certificate', -- the paper handed out; '' for none
    Mail = { Enabled = true, EveryLevel = true }, -- Skill Tree letters in the Student Phone's Mail; EveryLevel false: only levels that open a star or give a certificate

    -- What levels and certificates open: 'club:<club name>', 'activity:<id>', 'production:<id>', 'skill:<id>'. Leaves:
    -- { lesson = key, level = n }, { certificate = key }, { exam = 'final', lesson = key }, { totalXp = n }, { club = name },
    -- grouped with { all = { ... } } or { any = { ... } }.
    Unlocks = {},

    -- Constellation / Star Skill Tree (Yıldız Ağacı): 12 lessons with Level 3 (Yörünge), 6 (Parlayan Yıldız) and 10
    -- (Süpernova) milestones. req: the other lessons it also needs, one { lesson, level } or a list of them. What each
    -- one opens in other scripts: config/integrations.lua (Skills), config/workbenches.lua and the earned certificates
    -- below; the rest is a role-play qualification. Status: [daddy]/docs/skilltree-baglanti.md.
    SkillTree = {
        {
            key = 'muzik',
            name = 'Müzik',
            category = 'Yaratıcı',
            icon = 'music',
            desc = 'Eğlence mekânlarında çalışır, sonunda mekân işletirsin.',
            skills = {
                { level = 3, tier = 'Yörünge', unlockKey = 'skill:music_badge', title = 'Müzik Rozeti', desc = 'Müzik yolunun ilk rozeti.' },
                { level = 6, tier = 'Parlayan Yıldız', unlockKey = 'skill:venue_work', title = 'Mekân Çalışanı', desc = 'Eğlence Mekânı Çalışma Sertifikası alırsın.', req = { lesson = 'dans', level = 6 } },
                { level = 10, tier = 'Süpernova', unlockKey = 'skill:venue_owner', title = 'Mekân İşletmecisi', desc = 'Eğlence Mekânı İşletme Sertifikası alırsın.', req = { { lesson = 'resim', level = 10 }, { lesson = 'dans', level = 10 } } },
            },
        },
        {
            key = 'resim',
            name = 'Resim',
            category = 'Yaratıcı',
            icon = 'palette',
            desc = 'Sprey ve oto boyası yapar, sonunda dövmeci olursun.',
            skills = {
                { level = 3, tier = 'Yörünge', unlockKey = 'skill:spray_production', title = 'Sprey Boya', desc = 'Atölyede sprey boya yaparsın.' },
                { level = 6, tier = 'Parlayan Yıldız', unlockKey = 'skill:car_paint_kit', title = 'Oto Boya Kiti', desc = 'Atölyede oto boyama kiti yaparsın. Mekanik 6 ile gizli tezgâhta NOS ve egzoz parçası.' },
                { level = 10, tier = 'Süpernova', unlockKey = 'skill:tattoo_artist', title = 'Dövmeci', desc = 'Dövmecilik Sertifikası alırsın.' },
            },
        },
        {
            key = 'dans',
            name = 'Dans',
            category = 'Yaratıcı',
            icon = 'sparkles',
            desc = 'Dans kulübü, ekip liderliği ve mekân sahnesi.',
            skills = {
                { level = 3, tier = 'Yörünge', unlockKey = 'skill:dance_club', title = 'Dans Kulübü', desc = 'Dans kulübüne katılırsın.' },
                { level = 6, tier = 'Parlayan Yıldız', unlockKey = 'skill:dance_team_leader', title = 'Ekip Lideri', desc = 'Ponpon ya da dans ekibinde lider olabilirsin.' },
                { level = 10, tier = 'Süpernova', unlockKey = 'skill:venue_dancer', title = 'Mekân Dansçısı', desc = 'Dansçılık Çalışma Sertifikası alırsın. Müzik 10 ve Resim 10 ile mekân kontrolü.' },
            },
        },
        {
            key = 'beden_egitimi',
            name = 'Beden Eğitimi',
            category = 'Hareket',
            icon = 'dumbbell',
            desc = 'Kaykay, BMX ve dövüş stilleri.',
            skills = {
                { level = 3, tier = 'Yörünge', unlockKey = 'skill:skate_bike', title = 'Kaykay & BMX', desc = "Kaykaya ve BMX'e binersin." },
                { level = 6, tier = 'Parlayan Yıldız', unlockKey = 'skill:karate', title = 'Karate', desc = 'Dojoda Karate öğrenirsin.', req = { lesson = 'dans', level = 6 } },
                { level = 10, tier = 'Süpernova', unlockKey = 'skill:advanced_combat', title = 'Boks & MMA', desc = 'Boks ve MMA öğrenir, Dövüş Sertifikası alırsın.' },
            },
        },
        {
            key = 'ascilik',
            name = 'Aşçılık',
            category = 'Üretim',
            icon = 'utensils',
            desc = 'Çiftlik işi, hızlı mutfak ve işletme aşçılığı.',
            skills = {
                { level = 3, tier = 'Yörünge', unlockKey = 'skill:farm_work', title = 'Çiftlik İşçisi', desc = 'Çiftçilik Çalışma Sertifikası alırsın.', req = { lesson = 'biyoloji', level = 3 } },
                { level = 6, tier = 'Parlayan Yıldız', unlockKey = 'skill:fast_cooking', title = 'Hızlı Mutfak', desc = 'Okul mutfağında yarı sürede pişirirsin. Gazetecilik 6 ile tariflerin hepsi açılır.' },
                { level = 10, tier = 'Süpernova', unlockKey = 'skill:chef_business', title = 'İşletme Aşçısı', desc = 'İşletme Aşçılık Belgesi alırsın.' },
            },
        },
        {
            key = 'mekanik',
            name = 'Mekanik',
            category = 'Üretim',
            icon = 'wrench',
            desc = 'Tamir kiti, neon ve usta mekanik belgesi.',
            skills = {
                { level = 3, tier = 'Yörünge', unlockKey = 'skill:repair_kit', title = 'Tamir Kiti', desc = 'Atölyede tamir kiti yaparsın.' },
                { level = 6, tier = 'Parlayan Yıldız', unlockKey = 'skill:stance_neon', title = 'Stance & Neon', desc = 'Araç stance işinden anlarsın. Resim 6 ile atölyede neon kontrol ünitesi yaparsın.' },
                { level = 10, tier = 'Süpernova', unlockKey = 'skill:mechanic_work', title = 'Usta Mekanik', desc = 'Mekanik Çalışma Sertifikası alırsın.' },
            },
        },
        {
            key = 'gazetecilik',
            name = 'Gazetecilik',
            category = 'Medya',
            icon = 'newspaper',
            desc = 'Okul gazetesi, basın kartı ve başeditörlük.',
            skills = {
                { level = 3, tier = 'Yörünge', unlockKey = 'skill:newspaper_editor', title = 'Gazete Editörü', desc = 'Okul gazetesinde editör olur, sertifikanı alırsın.' },
                { level = 6, tier = 'Parlayan Yıldız', unlockKey = 'skill:police_press', title = 'Polis Muhabiri', desc = 'Polis departmanı basın kartı ve stajyerlik sertifikası alırsın.', req = { { lesson = 'hukuk', level = 6 }, { lesson = 'polislik', level = 6 } } },
                { level = 10, tier = 'Süpernova', unlockKey = 'skill:press_chief', title = 'Başeditör', desc = 'Basın kartı ve okul gazetesi başeditörlük sertifikası alırsın.' },
            },
        },
        {
            key = 'biyoloji',
            name = 'Biyoloji',
            category = 'Bilim',
            icon = 'leaf',
            desc = 'Çiftçilik, medkit ve EMS stajı.',
            skills = {
                { level = 3, tier = 'Yörünge', unlockKey = 'skill:farmer', title = 'Çiftçi', desc = 'Çiftçilik Sertifikası alırsın.' },
                { level = 6, tier = 'Parlayan Yıldız', unlockKey = 'skill:medkit_bio', title = 'Medkit', desc = 'Revirde medkit yaparsın.', req = { lesson = 'saglik', level = 6 } },
                { level = 10, tier = 'Süpernova', unlockKey = 'skill:ems_intern_bio', title = 'EMS Stajyeri', desc = 'EMS Staj Sertifikası alırsın.', req = { lesson = 'saglik', level = 10 } },
            },
        },
        {
            key = 'almanca',
            name = 'Almanca',
            category = 'Dil',
            icon = 'languages',
            desc = 'Değişim öğrenciliği, tur rehberliği ve tercümanlık.',
            skills = {
                { level = 3, tier = 'Yörünge', unlockKey = 'skill:exchange_student', title = 'Değişim Öğrencisi', desc = 'Öğrenci kartında Almanca yazar, Değişim Öğrencisi Belgesi alırsın.' },
                { level = 6, tier = 'Parlayan Yıldız', unlockKey = 'skill:tour_guide', title = 'Tur Rehberi', desc = 'Okul gezilerinde ve misafir günlerinde rehberlik eder, Tur Rehberliği Sertifikası alırsın.' },
                { level = 10, tier = 'Süpernova', unlockKey = 'skill:translator', title = 'Tercüman', desc = 'Tercümanlık Sertifikası alır, LSDOJ duruşmalarında tercümanlık yapabilirsin.', req = { lesson = 'hukuk', level = 6 } },
            },
        },
        {
            key = 'hukuk',
            name = 'Hukuk',
            category = 'Akademik',
            icon = 'scale',
            desc = 'Sınıf temsilciliği, disiplin kurulu ve LSDOJ stajı.',
            skills = {
                { level = 3, tier = 'Yörünge', unlockKey = 'skill:class_rep', title = 'Sınıf Temsilcisi', desc = 'Sınıf temsilcisi olmaya hak kazanırsın.' },
                { level = 6, tier = 'Parlayan Yıldız', unlockKey = 'skill:discipline_board', title = 'Disiplin Kurulu', desc = 'Disiplin kuruluna başvurabilirsin.' },
                { level = 10, tier = 'Süpernova', unlockKey = 'skill:doj_intern', title = 'LSDOJ Stajyeri', desc = 'LSDOJ Stajyerlik Sertifikası alırsın.', req = { lesson = 'polislik', level = 10 } },
            },
        },
        {
            key = 'saglik',
            name = 'Sağlık',
            category = 'Sağlık',
            icon = 'heart-pulse',
            desc = 'Bandaj, medkit, yara tedavisi ve EMS stajı.',
            skills = {
                { level = 3, tier = 'Yörünge', unlockKey = 'skill:craft_bandage', title = 'Bandaj', desc = 'Revirde bandaj yaparsın.' },
                { level = 6, tier = 'Parlayan Yıldız', unlockKey = 'skill:craft_medkit', title = 'Medkit', desc = 'Revirde medkit yaparsın.', req = { lesson = 'biyoloji', level = 6 } },
                { level = 10, tier = 'Süpernova', unlockKey = 'skill:ems_intern', title = 'EMS Stajyeri', desc = 'EMS Staj Sertifikası alır, bandajla yara tedavi edersin.', req = { lesson = 'biyoloji', level = 10 } },
            },
        },
        {
            key = 'polislik',
            name = 'Polislik',
            category = 'Güvenlik',
            icon = 'shield',
            desc = 'Avcılık, siber güvenlik ve polis stajı.',
            skills = {
                { level = 3, tier = 'Yörünge', unlockKey = 'skill:hunting_license', title = 'Avcı', desc = 'Avcılık Sertifikası alır, avlanırsın.', req = { lesson = 'biyoloji', level = 3 } },
                { level = 6, tier = 'Parlayan Yıldız', unlockKey = 'skill:cyber_security', title = 'Siber Güvenlik', desc = 'Siber Güvenlik Sertifikası alırsın.' },
                { level = 10, tier = 'Süpernova', unlockKey = 'skill:police_intern', title = 'Polis Stajyeri', desc = 'Polis Departmanı Staj Sertifikası alırsın.', req = { lesson = 'hukuk', level = 10 } },
            },
        },
    },

    -- Clubs found by a word in their name ('club:<name>' rules when Unlocks names none): join = to join,
    -- lead = to be given the club's top or officer rank.
    ClubRules = {
        { match = { 'dans', 'dance', 'ponpon', 'cheer' }, join = { lesson = 'dans', level = 3 }, lead = { lesson = 'dans', level = 6 } },
    },

    -- Activity: the week's XP (attendance only as far as effort goes) plus a bonus per lesson attended. The best of
    -- the week becomes student of the week (Approve: the principal confirms first).
    Activity = { AttendanceBonus = 2, StudentOfWeek = { Enabled = true, Approve = false, MinLessons = 3 } },
    -- What the student of the week gets, all together; with Approve the principal may change each amount up to max.
    -- card: school card balance; money: account and amount; item: name and count; xp: lesson XP (lesson = nil: their
    -- best lesson of the week); title: 'Student of the Week' on their profile for days. Money and items wait for the
    -- student's next login when they are offline.
    StudentOfWeekRewards = {
        { kind = 'title', days = 7 },
        { kind = 'card', amount = 250, max = 1000 },
        -- { kind = 'money', account = 'bank', amount = 500, max = 2000 },
        -- { kind = 'item', name = 'school_trophy', count = 1, max = 3 },
        -- { kind = 'xp', amount = 25, max = 100 },
    },
    -- The board (world prop 'week_board'): this week's student with their photo, and the weeks before.
    StudentOfWeekBoard = { Model = 'prop_cork_board', Past = 6, PhotoMaxBytes = 150000, Distance = 2.0 },
    StudentOfWeekReward = function(citizenid, score, source) end, -- your own code after the list; source is nil while offline

    -- Lesson names used before a lesson was renamed or added to the catalog -> its key.
    LessonAliases = {
        ['Görsel Sanatlar'] = 'resim',
        ['gorsel_sanatlar'] = 'resim',
        ['İlk Yardım'] = 'saglik',
        ['ilk_yardim'] = 'saglik',
        ['Gastronomi'] = 'ascilik',
        ['gastronomi'] = 'ascilik',
        ['Adalet'] = 'hukuk',
        ['adalet'] = 'hukuk',
        ['Physical Education'] = 'beden_egitimi',
        ['Mechanics'] = 'mekanik',
        ['Biology'] = 'biyoloji',
        ['Journalism'] = 'gazetecilik',
        ['Music'] = 'muzik',
        ['Visual Arts'] = 'resim',
        ['Dance'] = 'dans',
        ['First Aid'] = 'saglik',
        ['Policing'] = 'polislik',
        ['Culinary Arts'] = 'ascilik',
        ['Law'] = 'hukuk',
    },
}

-- Populate Config.Academics.Unlocks automatically from SkillTree milestones so external scripts can query
-- exports['daddy_college']:MeetsRequirement(citizenid, 'skill:karate') or 'skill:repair_kit', etc.
for _, course in ipairs(Config.Academics.SkillTree or {}) do
    for _, node in ipairs(course.skills or {}) do
        if node.unlockKey then
            local all = { { lesson = course.key, level = node.level } }
            local req = node.req
            for _, other in ipairs(type(req) == 'table' and (req.lesson and { req } or req) or {}) do
                all[#all + 1] = { lesson = other.lesson, level = other.level }
            end
            Config.Academics.Unlocks[node.unlockKey] = #all == 1 and all[1] or { all = all }
        end
    end
end

-- DaddyRP: the certificates of the first test term, open to everyone for now (add needs = { lesson = ..., level = ... } later).
Config.Academics.Certificates = {
    -- earn: given by itself once the student meets the levels. Role-play papers; only
    -- hunting_license is asked for by a script (wais-hunting, config/integrations.lua).
    venue_work = { earn = { all = { { lesson = 'muzik', level = 6 }, { lesson = 'dans', level = 6 } } } },
    venue_owner = { earn = { all = { { lesson = 'muzik', level = 10 }, { lesson = 'resim', level = 10 }, { lesson = 'dans', level = 10 } } } },
    venue_dancer = { earn = { lesson = 'dans', level = 10 } },
    tattoo_artist = { earn = { lesson = 'resim', level = 10 } },
    fighter = { earn = { lesson = 'beden_egitimi', level = 10 } },
    farm_work = { earn = { all = { { lesson = 'ascilik', level = 3 }, { lesson = 'biyoloji', level = 3 } } } },
    farmer = { earn = { lesson = 'biyoloji', level = 3 } },
    chef_business = { earn = { lesson = 'ascilik', level = 10 } },
    mechanic_work = { earn = { lesson = 'mekanik', level = 10 } },
    press_editor = { earn = { lesson = 'gazetecilik', level = 3 } },
    police_press = { earn = { all = { { lesson = 'gazetecilik', level = 6 }, { lesson = 'hukuk', level = 6 }, { lesson = 'polislik', level = 6 } } } },
    press_chief = { earn = { lesson = 'gazetecilik', level = 10 } },
    ems_intern = { earn = { all = { { lesson = 'saglik', level = 10 }, { lesson = 'biyoloji', level = 10 } } } },
    doj_intern = { earn = { all = { { lesson = 'hukuk', level = 10 }, { lesson = 'polislik', level = 10 } } } },
    police_intern = { earn = { all = { { lesson = 'polislik', level = 10 }, { lesson = 'hukuk', level = 10 } } } },
    hunting_license = { earn = { all = { { lesson = 'polislik', level = 3 }, { lesson = 'biyoloji', level = 3 } } } },
    exchange_student = { earn = { lesson = 'almanca', level = 3 } },
    tour_guide = { earn = { lesson = 'almanca', level = 6 } },
    translator = { earn = { all = { { lesson = 'almanca', level = 10 }, { lesson = 'hukuk', level = 6 } } } },
    cyber_security = { earn = { lesson = 'polislik', level = 6 } },
    -- DaddyRP: elle verilir (öğretmen/müdür /bbizin), seviyeyle gelmez. wais-speaker boombox kilidi bunu sorar.
    boombox_permit = {},
}
