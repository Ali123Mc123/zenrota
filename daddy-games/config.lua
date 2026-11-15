Config = {}

-- =========================================================================
-- 🔒 ADMIN & YETKİLENDİRME AYARLARI
-- =========================================================================
Config.AdminGroups = { 'admin', 'god', 'mod', 'superadmin' }

-- =========================================================================
-- 🎲 ZAR & ŞANS OYUNLARI AYARLARI (DICE MODULE)
-- =========================================================================
Config.Dice = {
    DisplayDistance = 12.0,       -- Kartın görülebileceği ve sesin duyulacağı mesafe (metre)
    DisplayDuration = 6500,       -- Kartın baş üstünde kalma süresi (ms)
    RollingDuration = 1100,       -- Zar/Para/Kart dönme & heyecan süresi (ms)
    
    EnableSound = true,           -- Gerçekçi ses efektleri
    SoundVolume = 0.5,            -- Ses seviyesi (0.1 - 1.0)
    
    EnableChatNotification = false, -- Chat ekranına sonuç düşsün mü? (Kapalı: Sadece oyun içi 3D gösterim)
    ShowPlayerNameInChat = true,  -- Chat mesajında oyuncu adı görünsün mü?
    UseCharacterName = true,      -- IC Karakter adı kullanılsın
    
    DefaultDiceCount = 2,         -- /zarat varsayılan zar adedi
    DefaultDiceSides = 6,         -- Varsayılan zar yüzü (D6)
    MaxDiceCount = 6,             -- Maksimum zar adedi
    MaxDiceSides = 100,           -- Maksimum zar yüzü (D100)
    
    Commands = {
        dice = { 'zarat', 'zar', 'roll', 'dice' },
        coin = { 'yazitura', 'coin', 'yazi-tura', 'coinflip' },
        rps = { 'tkm', 'rps', 'taskagitmakas' },
        card = { 'kartcek', 'kart', 'drawcard' },
        number = { 'sayitut', 'rastgele' },
        menu = { 'zarmenu', 'sans' }
    },
    
    CardSuits = {
        { symbol = '♠', name = 'Maça', color = '#93c5fd' },
        { symbol = '♥', name = 'Kupa', color = '#f87171' },
        { symbol = '♦', name = 'Karo', color = '#fb923c' },
        { symbol = '♣', name = 'Sinek', color = '#4ade80' }
    },
    
    CardValues = {
        { code = 'A', name = 'As', val = 1 },
        { code = '2', name = '2', val = 2 },
        { code = '3', name = '3', val = 3 },
        { code = '4', name = '4', val = 4 },
        { code = '5', name = '5', val = 5 },
        { code = '6', name = '6', val = 6 },
        { code = '7', name = '7', val = 7 },
        { code = '8', name = '8', val = 8 },
        { code = '9', name = '9', val = 9 },
        { code = '10', name = '10', val = 10 },
        { code = 'J', name = 'Vale', val = 11 },
        { code = 'Q', name = 'Kız', val = 12 },
        { code = 'K', name = 'Papaz', val = 13 },
    },
    
    Animations = {
        dice = {
            dict = 'mp_player_int_upperwank',
            clip = 'mp_player_int_wank_01',
            duration = 2000,
            revealDelay = 1200,
            prop = 'prop_dice_01',
            bone = 28422,
            offset = vector3(0.06, 0.02, -0.02),
            rotation = vector3(0.0, 0.0, 0.0)
        },
        coin = {
            dict = 'anim@mp_player_intcelebrationmale@coin_roll_and_toss',
            clip = 'coin_roll_and_toss',
            femaleDict = 'anim@mp_player_intcelebrationfemale@coin_roll_and_toss',
            femaleClip = 'coin_roll_and_toss',
            fallbackDict = 'anim@mp_player_intuppercoin_roll_and_toss',
            fallbackClip = 'idle_a',
            duration = 3400,
            revealDelay = 2400,
            prop = 'prop_anim_cash_coin_01',
            bone = 28422,
            offset = vector3(0.05, 0.01, -0.01),
            rotation = vector3(0.0, 90.0, 0.0)
        },
        rps = {
            dict = 'gestures@m@standing@casual',
            clip = 'gesture_hand_down',
            femaleDict = 'gestures@f@standing@casual',
            femaleClip = 'gesture_hand_down',
            duration = 1800,
            revealDelay = 1200,
        },
        card = {
            dict = 'anim_casino_b@ambient@casino@games@blackjack@dealer',
            clip = 'deal_card_player_01',
            fallbackDict = 'gestures@m@standing@casual',
            fallbackClip = 'gesture_me_hard',
            duration = 1800,
            revealDelay = 1100,
            prop = 'prop_playing_cards_01',
            bone = 28422,
            offset = vector3(0.08, 0.02, -0.02),
            rotation = vector3(0.0, 0.0, 90.0)
        },
        number = {
            dict = 'gestures@m@standing@casual',
            clip = 'gesture_pleased',
            femaleDict = 'gestures@f@standing@casual',
            femaleClip = 'gesture_pleased',
            duration = 1600,
            revealDelay = 1000,
        }
    }
}

-- =========================================================================
-- 🏓 RCORE OYUN MASALARI AYARLARI (TABLES MODULE)
-- =========================================================================
Config.Tables = {
    SpawnDistance = 65.0, -- Objelerin oyunculara görünme mesafesi (metre)

    -- Desteklenen Oyun Masaları
    Types = {
        airhockey = {
            label = 'Hava Hokeyi (Air Hockey)',
            icon = 'hockey-puck',
            model = 'prop_airhockey_01',
            description = 'rcore_airhockey uyumlu standart hava hokeyi masası',
            category = 'Air Hockey',
        },
        pingpong = {
            label = 'Masa Tenisi (Pinpon)',
            icon = 'table-tennis-paddle-ball',
            model = 'prop_table_tennis',
            description = 'rcore_pingpong uyumlu standart masa tenisi',
            category = 'Ping Pong',
        },
        pool = {
            label = 'Bilardo Masası (Standart Yeşil)',
            icon = 'circle-dot',
            model = 'prop_pooltable_02',
            description = 'rcore_pool uyumlu standart bilardo masası',
            category = 'Pool',
        },
        pool3b = {
            label = 'Bilardo Masası (Klasik Ahşap 3B)',
            icon = 'circle-dot',
            model = 'prop_pooltable_3b',
            description = 'rcore_pool uyumlu klasik ahşap bilardo masası',
            category = 'Pool',
        },
        poolcue = {
            label = 'Bilardo Istaka Standı',
            icon = 'bars',
            model = 'prop_pool_rack_02',
            description = 'rcore_pool ıstaka alma standı',
            category = 'Pool',
        },
    },

    -- Varsayılan Başlangıç Masaları
    Defaults = {},
}

-- =========================================================================
-- GYM & SPOR MODULU
-- ---------------------------------------------------------------------------
-- Tasarim felsefesi: bu bir "gel-puan-kas-git" sistemi DEGILDIR.
-- Oyuncu gunluk enerjisiyle sinirlidir, kas gruplari tutulur, forma girmek
-- gunler alir ve antrenmani birakinca kondisyon (ve ona bagli perk'ler) duser.
--
-- Ikonlar: Lucide adlaridir (bkz. web/gym/icons.js). Emoji KULLANILMAZ.
-- =========================================================================
Config.Gym = {
    Enabled = false, -- Gym sistemini tamamen kapatir (true: acik, false: kapali)
    Debug = false,
    Locale = 'tr',

    -- Duello
    MaxDuelBet = 50000,
    MinDuelBet = 0,
    DuelInviteTimeout = 30,
    DuelRoundTimeoutMs = 9000,
    DuelMaxDistance = 10.0,

    -- =====================================================================
    -- KAPASITE — kondisyonun ne kazandirdigi
    -- ---------------------------------------------------------------------
    -- Kondisyon 0 -> 100 arasinda DOGRUSAL interpolasyon yapilir.
    -- Bu blok, "formumu artirirsam daha fazla set atabilir miyim?" sorusunun
    -- somut cevabidir: evet, hem enerji tavani hem set basina tekrar buyur.
    -- =====================================================================
    Capacity = {
        EnergyMaxBase   = 100,    EnergyMaxPeak   = 190,    -- gunluk yorgunluk tavani
        RegenHoursBase  = 12.0,   RegenHoursPeak  = 7.0,    -- bostan doluya
        RepMultBase     = 0.70,   RepMultPeak     = 1.45,   -- set basina tekrar carpani
        DailyCapBase    = 12.0,   DailyCapPeak    = 7.0,    -- gunluk kondisyon tavani (zirvede YAVASLAR)
        PrecisionBonus  = 0.15,   -- bant x(1 + 0.15 * kondisyonOrani)
    },

    -- =====================================================================
    -- YORGUNLUK — setin ne kadar zorlastigi
    -- ---------------------------------------------------------------------
    -- Tek bir 0..1 skaler uretilir ve set parametrelerine dort ayri eksende
    -- uygulanir. HUD'da gosterilir; oyuncu neden zorlandigini gormezse
    -- sistem adaletsiz hissettirir.
    -- =====================================================================
    Fatigue = {
        WeightEnergy     = 0.55,   -- gunluk tukenmislik (1 - enerji/tavan)
        WeightSore       = 0.25,   -- kas tutulmasi (DOMS)
        WeightRepeat     = 0.20,   -- ust uste ayni alet
        RepeatSetsForMax = 5,

        -- Bu uc deger simulasyonla kalibre edildi (tools/ yaninda sim notlari):
        -- dinc/dikkatli %96 tamamlar, yorgunluk .45'te %39'a, .60'ta %13'e
        -- duser, .85'te pratikte imkansizdir. Usta oyuncu her durumda sansini
        -- korur; yani zorluk beceriyi cezalandirmaz, ozensizligi cezalandirir.
        StartBreathPeak   = 68.0,  -- yorgunluk 1'de sete kac nefesle baslarsin
        WindowMultPeak    = 0.74,  -- kabul bandi carpani
        DrainMultPeak     = 1.30,  -- nefes tukenis carpani
        JitterBase        = 0.06,  -- tempo oynamasi (dinc)
        JitterPeak        = 0.18,  -- tempo oynamasi (bitkin)
        HoldTolerancePeak = 0.70,  -- 'hold' mekaniginde tutus toleransi
    },

    -- =====================================================================
    -- AGIRLIK KADEMELERI
    -- ---------------------------------------------------------------------
    -- Set oncesi secilir. Agir = dar bant + cok enerji + az tekrar + cok odul.
    -- Ust kademeler kondisyonla acilir; dogrulama SUNUCUDA yapilir.
    -- Egzersizler `levelLabels` ile kendi adlandirmasini verebilir.
    -- =====================================================================
    Levels = {
        { id = 'warmup', label = 'Isınma',   minCondition = 0,  window = 1.25, energy = 0.70, points = 0.60, reps = 1.20 },
        { id = 'light',  label = 'Hafif',    minCondition = 0,  window = 1.10, energy = 0.85, points = 0.85, reps = 1.10 },
        { id = 'normal', label = 'Normal',   minCondition = 15, window = 1.00, energy = 1.00, points = 1.00, reps = 1.00 },
        { id = 'heavy',  label = 'Ağır',     minCondition = 45, window = 0.85, energy = 1.25, points = 1.35, reps = 0.85 },
        { id = 'max',    label = 'Maksimal', minCondition = 75, window = 0.70, energy = 1.60, points = 1.85, reps = 0.70 },
    },

    -- =====================================================================
    -- TABAN ZORLUK
    -- ---------------------------------------------------------------------
    -- Eski surumde "en az IYI" bandi dongunun %36-74'uydu; rastgele basmak
    -- bile tutuyordu. GoodMult 2.4 -> 1.7 ve dar taban bantlarla bu oran
    -- ~%20'ye iner. Hedef: dikkatli oyuncu seti bitirir.
    -- =====================================================================
    Difficulty = {
        GoodMult         = 1.70,   -- iyi bandi = perfect bandi x bu

        -- Tekrar rampasi CARPIMSAL: uzun setlerde de anlamli kalir
        WindowRampPerRep = 0.022,  WindowRampFloor = 0.45,
        TempoRampPerRep  = 0.012,  TempoRampFloor  = 0.62,
        WindowMinMs      = 70,

        MissedCycleCounts = true,  -- dongu bos gecerse BOZUK sayilir

        -- Nefes ekonomisi (tempoya oranli)
        BreathPerfect = 0.62,      -- geri kazanim
        BreathGood    = 0.30,
        BreathMiss    = 0.45,      -- ek ceza
        BreathSkip    = 0.55,      -- kacirilan dongu cezasi
        ComboBreathBonus = 0.10,   -- 5+ combo'da ek geri kazanim

        -- Odul egrisi: kusursuz oynamak ozensiz oynamaktan BELIRGIN iyi olmali
        QualityBase   = 0.25,      -- toplam carpan = Base + Slope * kalite
        QualitySlope  = 1.05,
        ComboBonusMax = 0.25,      -- ardisik PERFECT ile +%25'e kadar
        ComboFullAt   = 8,
    },

    -- =====================================================================
    -- LIFECYCLE
    -- =====================================================================
    Lifecycle = {
        MinEnergyToStart = 4,

        ConditionMax        = 100.0,
        DecayStartHours     = 30.0,
        DecayPerDay         = 4.0,
        DecayHardAfterHours = 72.0,
        DecayPerDayHard     = 6.0,
        StreakShieldDays    = 7,

        SetDiminishing      = { 1.00, 0.80, 0.60, 0.35, 0.15, 0.05 },
        SetDiminishingFloor = 0.05,

        SameExerciseEnergyStep = 0.15,

        MuscleSoreAfterSets  = 2,
        MuscleSoreHours      = 6.0,
        MuscleSoreGainMult   = 0.30,
        MuscleSoreEnergyMult = 1.50,

        StreakHalveAfterDays = 1,
        StreakResetAfterDays = 2,

        ProgramBonusFP        = 250,
        ProgramBonusCondition = 3.0,
        ProgramGainMult       = 1.25,

        MaxSetDurationMs       = 300000,
        StationReleaseDistance = 5.0,
        WatchdogIntervalMs     = 5000,
        RestBetweenSetsMs      = 4000,
    },

    -- =====================================================================
    -- RUTBELER
    -- Efektif rutbe = min(kondisyondan gelen, form puanindan gelen).
    -- `icon` bir Lucide adidir, `metal` madalyon rengini secer.
    -- =====================================================================
    Tiers = {
        { id = 'rookie',   label = 'Çaylak',   icon = 'sprout',      metal = nil,        minCondition = 0,  minPoints = 0     },
        { id = 'amateur',  label = 'Amatör',   icon = 'chevron-up',  metal = 'bronze',   minCondition = 20, minPoints = 500   },
        { id = 'fit',      label = 'Formda',   icon = 'chevrons-up', metal = 'silver',   minCondition = 40, minPoints = 2000  },
        { id = 'athlete',  label = 'Atlet',    icon = 'medal',       metal = 'silver',   minCondition = 60, minPoints = 6000  },
        { id = 'pro',      label = 'Sporcu',   icon = 'award',       metal = 'gold',     minCondition = 75, minPoints = 15000 },
        { id = 'champion', label = 'Şampiyon', icon = 'trophy',      metal = 'gold',     minCondition = 90, minPoints = 35000 },
        { id = 'legend',   label = 'Efsane',   icon = 'crown',       metal = 'platinum', minCondition = 98, minPoints = 75000 },
    },

    -- =====================================================================
    -- PERK'LER — kondisyondan dogrusal turetilir, kondisyonla birlikte DUSER
    -- =====================================================================
    Perks = {
        Enabled          = true,
        StaminaMin       = 0,     StaminaMax   = 0,   -- DaddyRP: gym stamina vermiyor (MP0_STAMINA hep 0)
        StrengthMin      = 0,     StrengthMax  = 100,
        LungMin          = 0,     LungMax      = 100,
        MeleeMultMin     = 1.00,  MeleeMultMax = 1.45,
        MaxHealthEnabled = false, MaxHealthMin = 200, MaxHealthMax = 225,
        ReapplyIntervalMs = 60000,
    },

    -- =====================================================================
    -- KAS GRUPLARI
    -- Renk YOK: yuk haritasi tek hue yogunluk rampasi kullanir (tokens.css).
    -- =====================================================================
    MuscleGroups = {
        chest = { label = 'Göğüs',     icon = 'dumbbell'   },
        back  = { label = 'Sırt',      icon = 'move-up'    },
        arms  = { label = 'Kol',       icon = 'weight'     },
        core  = { label = 'Karın',     icon = 'fold-vertical' },
        full  = { label = 'Tüm Vücut', icon = 'hand-metal' },
    },

    -- =====================================================================
    -- SET TIPLERI — rutbeyle acilan ozel setler
    -- =====================================================================
    SetTypes = {
        {
            id = 'straight', label = 'Düz Set', icon = 'circle-dot',
            minTier = 1,
            desc = 'Standart set.',
        },
        {
            id = 'dropset', label = 'Drop Set', icon = 'trending-down',
            minTier = 5,   -- Sporcu
            desc = 'Nefesin bitince kademe düşer ve set devam eder. Toplam tekrar artar, puan x1.35.',
            pointMult = 1.35, energyMult = 1.30, dropSteps = 2,
        },
        {
            id = 'superset', label = 'Süper Set', icon = 'chevrons-right',
            minTier = 6,   -- Şampiyon
            desc = 'İki egzersiz arka arkaya, tek enerji maliyeti. Puan x1.60.',
            pointMult = 1.60, energyMult = 1.45,
        },
    },

    -- =====================================================================
    -- EGZERSIZLER
    -- ---------------------------------------------------------------------
    -- mechanic:
    --   'tap'   tek basis  (SPACE) — sinav, mekik, dambil
    --   'hold'  bas-TUT-birak    — bench, barfiks (iki pencere: indirme + kaldirma)
    --   'combo' tus dizisi       — boks (sol tik / sag tik)
    --   'grip'  halat cekme      — bilek guresi (yalniz duello)
    --
    -- perfectWindowMs degerleri tempo'nun ~%11'i (tap), ~%15'i (hold, iki
    -- pencere oldugu icin) ve ~%17'si (combo) olacak sekilde secildi.
    -- GoodMult 1.7 ile "en az IYI" bandi tap'te ~%19'a iner (eskiden %61).
    --
    -- anim.male / anim.female / anim.exit birer ADAY LISTESIDIR; calisma
    -- aninda DoesAnimDictExist gecen ilk aday kullanilir, hicbiri yoksa
    -- anim.scenario'ya dusulur.
    -- =====================================================================
    Exercises = {
        bench = {
            id = 'bench', label = 'Bench Press', short = 'Bench',
            icon = 'dumbbell', muscle = 'chest',
            targetIcon = 'fa-solid fa-dumbbell',   -- ox_target Font Awesome kullanir
            desc = 'İndirirken bas ve tut, kaldırırken bırak. Acele edersen halter üstüne gelir.',

            mechanic = 'hold',
            hold = { downPhase = 0.30, upPhase = 0.74, minHoldMs = 130 },

            anim = {
                male = {
                    { dict = 'amb@prop_human_seat_muscle_bench_press@idle_a', clip = 'idle_a' },
                    { dict = 'amb@prop_human_seat_muscle_bench_press@base',   clip = 'base'   },
                },
                female = {
                    { dict = 'amb@prop_human_seat_muscle_bench_press@idle_a', clip = 'idle_a' },
                    { dict = 'amb@prop_human_seat_muscle_bench_press@base',   clip = 'base'   },
                },
                exit = {
                    { dict = 'amb@prop_human_seat_muscle_bench_press@exit', clip = 'exit' },
                    { dict = 'amb@prop_human_seat_muscle_bench_press@base', clip = 'exit' },
                },
                scenario = 'PROP_HUMAN_MUSCLE_BENCH_PRESS',
            },

            -- 'hold' iki pencereli oldugu icin bant tek basisli egzersizlerden
            -- genistir; yine de IKISINI birden tutturmak gerekir.
            tempoMs = 2000, perfectWindowMs = 380,
            breathDrainPerSec = 7.5, targetReps = 14, minRepMs = 900, maxRepMs = 6000,

            energyCost = 12, pointsPerRep = 8, conditionPerSet = 3.2,
            recordField = 'bench_record',

            offset = vector3(0.0, 0.0, 0.25), headingOffset = 0.0, snapToGround = false,
            models = {
                'prop_muscle_bench_01', 'prop_bench_press', 'prop_barbell_02',
                'brum_bzzz_gym_pack_001', 'brum_bzzz_gym_pack_002',
            },
        },

        pullup = {
            id = 'pullup', label = 'Barfiks', short = 'Barfiks',
            icon = 'move-up', muscle = 'back',
            targetIcon = 'fa-solid fa-arrow-up-from-bracket',   -- ox_target Font Awesome kullanir
            desc = 'Çekerken tut, inerken bırak. Yerçekimi affetmez.',

            mechanic = 'hold',
            hold = { downPhase = 0.28, upPhase = 0.70, minHoldMs = 110 },

            anim = {
                male = {
                    { dict = 'amb@prop_human_muscle_chin_ups@male@idle_a', clip = 'idle_a' },
                    { dict = 'amb@prop_human_muscle_chin_ups@male@base',   clip = 'base'   },
                },
                female = {
                    { dict = 'amb@prop_human_muscle_chin_ups@female@idle_a', clip = 'idle_a' },
                    { dict = 'amb@prop_human_muscle_chin_ups@female@base',   clip = 'base'   },
                    { dict = 'amb@prop_human_muscle_chin_ups@male@idle_a',   clip = 'idle_a' },
                },
                exit = {
                    { dict = 'amb@prop_human_muscle_chin_ups@male@exit', clip = 'exit' },
                },
                scenario = 'PROP_HUMAN_MUSCLE_CHIN_UPS',
            },

            tempoMs = 1400, perfectWindowMs = 210,
            breathDrainPerSec = 9.0, targetReps = 12, minRepMs = 700, maxRepMs = 5000,

            energyCost = 10, pointsPerRep = 8, conditionPerSet = 3.0,
            recordField = 'pullup_record',

            offset = vector3(0.0, -0.15, 0.0), headingOffset = 180.0,
            models = {
                'prop_muscle_bench_04', 'prop_muscle_bench_05', 'prop_chinup_01',
                'brum_bzzz_gym_pack_003', 'brum_bzzz_gym_pack_004',
                'brum_bzzz_gym_pack_005a', 'brum_bzzz_gym_pack_005b',
                'brum_bzzz_gym_pack_005c', 'brum_bzzz_gym_pack_005d',
            },
        },

        situp = {
            id = 'situp', label = 'Mekik', short = 'Mekik',
            icon = 'fold-vertical', muscle = 'core',
            targetIcon = 'fa-solid fa-person-running',   -- ox_target Font Awesome kullanir
            desc = 'Hızlı ve düzenli tempo. Karın kasları erken yanar.',

            mechanic = 'tap',

            anim = {
                male = {
                    { dict = 'amb@world_human_sit_ups@male@idle_a', clip = 'idle_a' },
                    { dict = 'amb@world_human_sit_ups@male@base',   clip = 'base'   },
                },
                female = {
                    { dict = 'amb@world_human_sit_ups@female@idle_a', clip = 'idle_a' },
                    { dict = 'amb@world_human_sit_ups@female@base',   clip = 'base'   },
                    { dict = 'amb@world_human_sit_ups@male@idle_a',   clip = 'idle_a' },
                },
                exit = { { dict = 'amb@world_human_sit_ups@male@exit', clip = 'exit' } },
                scenario = 'WORLD_HUMAN_SIT_UPS',
            },

            tempoMs = 1100, perfectWindowMs = 120,
            breathDrainPerSec = 6.0, targetReps = 20, minRepMs = 550, maxRepMs = 4000,

            energyCost = 6, pointsPerRep = 5, conditionPerSet = 2.0,
            recordField = 'situp_record',

            offset = vector3(0.0, 0.0, 0.05), headingOffset = 180.0,
            allowOnGround = true,
            models = { 'prop_muscle_bench_03', 'prop_yoga_mat_01', 'prop_yoga_mat_02', 'prop_yoga_mat_03', 'prop_mat_01' },
        },

        dumbbell = {
            id = 'dumbbell', label = 'Serbest Ağırlık', short = 'Ağırlık',
            icon = 'biceps-flexed', muscle = 'arms',
            targetIcon = 'fa-solid fa-hand-fist',   -- ox_target Font Awesome kullanir
            desc = 'Biceps curl. Tempoyu kaçırırsan bilek gider.',

            mechanic = 'tap',

            anim = {
                male = {
                    { dict = 'amb@world_human_muscle_free_weights@male@barbell@idle_a', clip = 'idle_a' },
                    { dict = 'amb@world_human_muscle_free_weights@male@barbell@base',   clip = 'base'   },
                },
                female = {
                    { dict = 'amb@world_human_muscle_free_weights@female@barbell@idle_a', clip = 'idle_a' },
                    { dict = 'amb@world_human_muscle_free_weights@female@barbell@base',   clip = 'base'   },
                    { dict = 'amb@world_human_muscle_free_weights@male@barbell@idle_a',   clip = 'idle_a' },
                },
                exit = { { dict = 'amb@world_human_muscle_free_weights@male@barbell@exit', clip = 'exit' } },
                scenario = 'WORLD_HUMAN_MUSCLE_FREE_WEIGHTS',
            },

            -- Halter, animasyonun bekledigi model ve kemiktir
            -- (cylex AnimationList.json:24650 ile teyitli)
            attachProp = 'prop_curl_bar_01',
            attachBone = 28422,
            attachOffset = vector3(0.0, 0.0, 0.0),
            attachRot = vector3(0.0, 0.0, 0.0),

            tempoMs = 1300, perfectWindowMs = 145,
            breathDrainPerSec = 7.0, targetReps = 16, minRepMs = 650, maxRepMs = 4500,

            energyCost = 8, pointsPerRep = 6, conditionPerSet = 2.4,
            recordField = 'dumbbell_record',

            offset = vector3(0.0, -0.85, 0.0), headingOffset = 180.0,
            models = { 'prop_barbell_01', 'prop_muscle_bench_02', 'prop_muscle_bench_06', 'prop_freeweight_01', 'prop_freeweight_02' },
        },

        pushup = {
            id = 'pushup', label = 'Şınav', short = 'Şınav',
            icon = 'arrow-down-up', muscle = 'chest',
            targetIcon = 'fa-solid fa-person-running',   -- ox_target Font Awesome kullanir
            desc = 'En hızlı tempo, en çabuk tükenen nefes.',

            mechanic = 'tap',
            duelable = true,

            -- DIKKAT: @base/base STATIK bir plank pozudur, tekrar YAPMAZ.
            -- Gercek tekrar animasyonu @idle_a/idle_a'dir.
            anim = {
                male = {
                    { dict = 'amb@world_human_push_ups@male@idle_a', clip = 'idle_a' },
                    { dict = 'amb@world_human_push_ups@male@base',   clip = 'base'   },
                },
                female = {
                    { dict = 'amb@world_human_push_ups@female@idle_a', clip = 'idle_a' },
                    { dict = 'amb@world_human_push_ups@female@base',   clip = 'base'   },
                    { dict = 'amb@world_human_push_ups@male@idle_a',   clip = 'idle_a' },
                },
                exit = { { dict = 'amb@world_human_push_ups@male@exit', clip = 'exit' } },
                scenario = 'WORLD_HUMAN_PUSH_UPS',
            },

            tempoMs = 900, perfectWindowMs = 100,
            breathDrainPerSec = 8.5, targetReps = 22, minRepMs = 450, maxRepMs = 3500,

            energyCost = 8, pointsPerRep = 5, conditionPerSet = 2.2,
            recordField = 'pushup_record',

            offset = vector3(0.0, 0.0, 0.0), headingOffset = 0.0,
            allowOnGround = true,
            models = { 'prop_yoga_mat_01', 'prop_yoga_mat_02', 'prop_yoga_mat_03', 'prop_mat_01' },
        },

        -- Boks torbasi: her donguda bir tus dizisi belirir.
        -- SOL TIK = sol yumruk, SAG TIK = sag yumruk (control 24 / 25).
        -- Dizi uzunlugu kademeyle buyur: 1 - 2 - 2 - 3 - 3
        punchbag = {
            id = 'punchbag', label = 'Boks Torbası', short = 'Boks',
            icon = 'hand-metal', muscle = 'full',
            targetIcon = 'fa-solid fa-hand-back-fist',   -- ox_target Font Awesome kullanir
            desc = 'Kombinasyonu doğru sırada ve tempoda çak. Combo yaparsan vuruş gücün fırlar.',

            mechanic = 'combo',
            combo = {
                lenByLevel = { 1, 2, 2, 3, 3 },
                perKeyMs   = 260,        -- her tusa ayrilan sure
            },
            -- Kademeler burada tempo adlarini alir
            levelLabels = { 'Isınma', 'Ritim', 'Tempo', 'Sparring', 'Nakavt' },

            anim = { male = {}, female = {}, exit = {}, scenario = 'WORLD_HUMAN_PUNCH_BAG' },
            hitAnim = { dict = 'melee@unarmed@streamed_core', clip = 'short_0_attack' },

            tempoMs = 620, perfectWindowMs = 105,
            breathDrainPerSec = 11.0, targetReps = 24, minRepMs = 300, maxRepMs = 2500,

            energyCost = 15, pointsPerRep = 10, conditionPerSet = 3.6,
            recordField = 'punch_record',
            isPowerScore = true,
            powerScoreMax = 999,

            offset = vector3(0.0, -0.95, 0.0), headingOffset = 180.0,
            models = {
                'prop_punch_bag', 'prop_boxing_bag_01',
                'brum_bzzz_gym_pack_008a', 'brum_bzzz_gym_pack_008b',
                'brum_bzzz_gym_pack_009', 'brum_bzzz_gym_pack_010',
            },
        },

        -- Bilek guresi: ritim degil HALAT CEKME.
        -- SPACE basili tutuldukca bar rakibe dogru iter ama nefes hizla erir;
        -- birakinca nefes toplanir ama rakip geri iter.
        -- DIKKAT: mini@arm_wrestling clip adlari oyun icinde dogrulanmalidir.
        armwrestling = {
            id = 'armwrestling', label = 'Bilek Güreşi', short = 'Bilek',
            icon = 'handshake', muscle = 'arms',
            targetIcon = 'fa-solid fa-handshake',   -- ox_target Font Awesome kullanir
            desc = 'Ne zaman iteceğini, ne zaman nefes alacağını bilmek gerek.',

            mechanic = 'grip',
            grip = {
                pushPerSec    = 22.0,   -- basili tutunca bar ne hizla iter
                breathPerSec  = 26.0,   -- basili tutarken nefes tukenisi
                recoverPerSec = 18.0,   -- birakinca nefes toplama
                slidePerSec   = 12.0,   -- birakinca bar geri kayma
                winAt         = 100.0,  -- bar bu degere ulasinca mac biter
                exhaustPush   = 34.0,   -- nefesi biten tarafi rakip bu hizla iter
            },

            anim = {
                male = {
                    { dict = 'mini@arm_wrestling', clip = 'sweep_low_left' },
                    { dict = 'mini@arm_wrestling', clip = 'sweep_a' },
                },
                female = {
                    { dict = 'mini@arm_wrestling', clip = 'sweep_low_left' },
                    { dict = 'mini@arm_wrestling', clip = 'sweep_a' },
                },
                exit = {},
                scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER',
            },

            tempoMs = 800, perfectWindowMs = 160,
            breathDrainPerSec = 10.0, targetReps = 18, minRepMs = 400, maxRepMs = 3000,

            energyCost = 10, pointsPerRep = 6, conditionPerSet = 2.6,
            recordField = false,

            duelOnly = true,
            duelable = true,
            seatOffsets = {
                vector3(0.0,  0.62, 0.0),
                vector3(0.0, -0.62, 0.0),
            },

            offset = vector3(0.0, -0.65, 0.0), headingOffset = 180.0,
            models = { 'prop_arm_wrestle_01', 'prop_table_03', 'prop_table_04' },
        },
    },

    -- =====================================================================
    -- GUNLUK PROGRAMLAR (anti-grind cekirdegi)
    -- Program kalemlerine sayilan setler ProgramGainMult carpani alir;
    -- program tamamlaninca buyuk bonus + seri +1 gelir.
    -- minTier ile rutbeye gore acilir.
    -- =====================================================================
    Programs = {
        { id = 'prog_starter', label = 'Temel Kondisyon',      icon = 'sprout',        minTier = 1,
          items = { { ex = 'pushup', sets = 2 }, { ex = 'situp', sets = 2 } } },

        { id = 'prog_core',    label = 'Karın & Dayanıklılık', icon = 'fold-vertical', minTier = 1,
          items = { { ex = 'situp', sets = 3 }, { ex = 'pushup', sets = 2 } } },

        { id = 'prog_upper',   label = 'Üst Vücut Günü',       icon = 'dumbbell',      minTier = 2,
          items = { { ex = 'bench', sets = 2 }, { ex = 'dumbbell', sets = 2 }, { ex = 'pushup', sets = 1 } } },

        { id = 'prog_back',    label = 'Sırt & Çekiş Günü',    icon = 'move-up',       minTier = 2,
          items = { { ex = 'pullup', sets = 3 }, { ex = 'dumbbell', sets = 1 } } },

        { id = 'prog_power',   label = 'Güç Günü',             icon = 'anvil',         minTier = 3,
          items = { { ex = 'bench', sets = 3 }, { ex = 'punchbag', sets = 1 }, { ex = 'pullup', sets = 2 } } },

        { id = 'prog_fight',   label = 'Ring Hazırlığı',       icon = 'hand-metal',    minTier = 4,
          items = { { ex = 'punchbag', sets = 2 }, { ex = 'pushup', sets = 3 }, { ex = 'dumbbell', sets = 2 } } },
    },

    -- =====================================================================
    -- TAKVIYELER (Sporcu Bufesi -> salonun kendi dolabi)
    -- ACLIK/SUSUZLUK DOLDURMAZ. Yalnizca gym mekaniklerine etki eder.
    -- =====================================================================
    Supplements = {
        UseOxInventory = false,
        CrashEnergyMult = 1.20,

        Items = {
            {
                id = 'protein_shake', label = 'Whey Protein Shake', icon = 'milk',
                price = 120, dailyLimit = 2,
                desc = 'Anında +25 enerji. Toparlanmanı hızlandırır.',
                effect = { type = 'energy', amount = 25 },
            },
            {
                id = 'isotonic', label = 'İzotonik İçecek', icon = 'droplets',
                price = 90, dailyLimit = 3,
                desc = 'Sonraki 3 sette nefesin %35 daha yavaş tükenir.',
                effect = { type = 'breath', mult = 0.65, sets = 3 },
            },
            {
                id = 'preworkout', label = 'Pre-Workout', icon = 'flame',
                price = 350, dailyLimit = 1,
                desc = 'Sonraki 2 sette kabul bandı %60 geniş + puan x1.25. Bitince 10 dk enerji maliyeti +%20.',
                effect = { type = 'focus', windowMult = 1.60, pointMult = 1.25, sets = 2, crashMs = 600000 },
            },
            {
                id = 'creatine', label = 'Kreatin', icon = 'pill',
                price = 500, dailyLimit = 1,
                desc = '24 saat boyunca enerji tavanın +20. Yorgunluk sınırını yükseltir.',
                effect = { type = 'energymax', amount = 20, durationMs = 86400000 },
            },
            {
                id = 'chalk', label = 'Magnezyum Tozu', icon = 'sparkles',
                price = 60, dailyLimit = 3,
                desc = 'Sonraki sette form kaybı yarıya iner. Barfiks ve bench için ideal.',
                effect = { type = 'grip', missMult = 0.5, sets = 1 },
            },
            {
                id = 'towel', label = 'Spor Havlusu', icon = 'shirt',
                price = 800, dailyLimit = 1, permanent = true,
                desc = 'Kalıcı: setler arası toparlanma süresi %30 kısalır.',
                effect = { type = 'rest', mult = 0.70 },
            },
        },
    },

    -- =====================================================================
    -- ANTRENOR NPC'LERI — yalnizca Kampus Spor Alani (Cayo kampusu, fitness pedi)
    -- =====================================================================
    Trainers = {
        {
            id = 'resort_gym_trainer',
            name = 'Başantrenör Marcus',
            title = 'Kampüs Spor Alanı Başantrenörü',
            area = 'resort_gym',
            model = 'a_m_y_musclbeac_01',
            coords = vector4(5389.0010, -5284.6440, 31.4700, 236.0),
            scenario = 'WORLD_HUMAN_MUSCLE_FLEX',
            quotes = {
                'Acı yoksa kazanç da yok evlat. Ama abartma, kas dinlenirken büyür.',
                'Her gün gel. Bir hafta gelmezsen kondisyonunu sıfırdan toplarsın.',
                'Ağırlığı artırmak marifet değil; o ağırlıkta formu bozmamak marifet.',
                'Programını bitir, gerisi bonus. Aynı aleti altı kere yapmak seni geliştirmez.',
                'Yorgunken kaldırdığın ağırlık, dinçken kaldırdığından iki kat değerlidir.',
            },
        },
    },

    -- =====================================================================
    -- BOLGELER VE ISTASYONLAR
    -- stand : ped in isinlanacagi vector4 (z = AYAK hizasi, w = heading)
    -- target: (ops.) ox_target kutusu; verilmezse stand+ileri*0.6, z+0.7 turetilir
    -- useModelTargets: bolge yaricapindaki gym proplarina entity hedefi ekler
    -- =====================================================================
    Areas = {
        ['resort_gym'] = {
            label = 'Kampüs Spor Alanı',
            center = vector3(5393.23, -5287.5, 31.5),
            radius = 20.0,
            useModelTargets = true,

            blip = {
                enabled = true,
                sprite = 311,
                color = 2,
                scale = 0.75,
                label = 'Kampüs Spor Alanı',
            },

            -- Fitness pedinde her aletten birer tane var: istasyonlar pedin kendi proplarının yanında.
            stations = {
                bench = {
                    spawnProp = false,
                    propModel = 'prop_muscle_bench_01',
                    locations = {
                        { stand = vector4(5397.4630, -5284.7800, 32.3820, 59.90) },
                    },
                },

                dumbbell = {
                    spawnProp = false,
                    propModel = 'prop_barbell_01',
                    locations = {
                        { stand = vector4(5392.3770, -5292.2860, 31.7420, 63.07) },
                        { stand = vector4(5394.0550, -5293.2680, 31.7930, 252.14) },
                    },
                },

                situp = {
                    spawnProp = false,
                    propModel = 'prop_muscle_bench_03',
                    locations = {
                        { stand = vector4(5396.2870, -5286.5560, 32.3850, 241.84) },
                    },
                },

                pullup = {
                    spawnProp = false,
                    propModel = 'prop_muscle_bench_04',
                    -- Konum listesi boş: barfiks demirleri model-tabanlı target ile
                    -- yakalanır (useModelTargets). /gympos ile buraya konum eklenebilir.
                    locations = {},
                },

                pushup = {
                    spawnProp = false,
                    propModel = 'prop_yoga_mat_01',
                    locations = {},
                },

                punchbag = {
                    -- Pedde asılı torba için çerçeve yok: istasyon pedin kendi ayaklı torbasının
                    -- (prop_beach_punchbag) önünde, ayrıca torba yaratılmıyor.
                    spawnProp = false,
                    propModel = 'prop_punch_bag',
                    propZOffset = 1.60,
                    placeOnGround = false,
                    locations = {
                        { stand = vector4(5396.3300, -5283.3700, 30.9700, 323.10) },
                    },
                },

                armwrestling = {
                    spawnProp = true,
                    propModel = 'prop_arm_wrestle_01',
                    propZOffset = 0.0,
                    placeOnGround = true,   -- PlaceObjectOnGroundProperly ile zemine oturtulur
                    locations = {
                        { stand = vector4(5391.7620, -5289.4020, 30.9700, 322.42) },
                    },
                },
            },
        },
    },

    -- =====================================================================
    -- BASARIMLAR
    -- Emoji rozet YOK: `icon` bir Lucide adi, `metal` madalyon rengidir
    -- (bronze | silver | gold | platinum). Render web/gym/hub.js'te.
    --
    -- req.type: pushup_record | pullup_record | bench_record | situp_record |
    --           dumbbell_record | punch_record | duel_wins | total_duels |
    --           armwrestle_wins | streak_days | fitness_points |
    --           condition_score | programs_done
    -- =====================================================================
    Achievements = {
        -- Sinav
        { id = 'pushup_first', category = 'pushup', label = 'İlk Terleme',    icon = 'arrow-down-up', metal = 'bronze',   points = 20,  description = 'İlk şınav setini tamamla.',       req = { type = 'pushup_record', value = 1 } },
        { id = 'pushup_10',    category = 'pushup', label = 'Isınma Turu',    icon = 'arrow-down-up', metal = 'bronze',   points = 50,  description = 'Tek sette 10 şınav çek.',         req = { type = 'pushup_record', value = 10 } },
        { id = 'pushup_25',    category = 'pushup', label = 'Şınav Makinesi', icon = 'arrow-down-up', metal = 'silver',   points = 150, description = 'Tek sette 25 şınav çek.',         req = { type = 'pushup_record', value = 25 } },
        { id = 'pushup_50',    category = 'pushup', label = 'Ada Boğası',     icon = 'arrow-down-up', metal = 'gold',     points = 400, description = 'Tek sette 50 şınav çek.',         req = { type = 'pushup_record', value = 50 } },

        -- Barfiks
        { id = 'pullup_10',    category = 'pullup', label = 'Yerçekimine İnat', icon = 'move-up',    metal = 'bronze',   points = 60,  description = 'Tek sette 10 barfiks tamamla.',   req = { type = 'pullup_record', value = 10 } },
        { id = 'pullup_25',    category = 'pullup', label = 'Demir Pençe',      icon = 'move-up',    metal = 'silver',   points = 200, description = 'Tek sette 25 barfiks tamamla.',   req = { type = 'pullup_record', value = 25 } },

        -- Bench
        { id = 'bench_15',     category = 'bench',  label = 'Halter Ustası',    icon = 'dumbbell',   metal = 'bronze',   points = 80,  description = 'Tek sette 15 bench tekrarı yap.', req = { type = 'bench_record', value = 15 } },
        { id = 'bench_30',     category = 'bench',  label = 'Ağır Siklet Pres', icon = 'dumbbell',   metal = 'gold',     points = 250, description = 'Tek sette 30 bench tekrarı yap.', req = { type = 'bench_record', value = 30 } },

        -- Mekik & agirlik
        { id = 'situp_30',     category = 'situp',    label = 'Çelik Karın',   icon = 'fold-vertical',  metal = 'silver', points = 90, description = 'Tek sette 30 mekik çek.',        req = { type = 'situp_record', value = 30 } },
        { id = 'dumbbell_25',  category = 'dumbbell', label = 'Bilek Kuvveti', icon = 'biceps-flexed',  metal = 'silver', points = 90, description = 'Tek sette 25 curl tekrarı yap.', req = { type = 'dumbbell_record', value = 25 } },

        -- Boks
        { id = 'punch_500',    category = 'punch', label = 'Hafif Siklet',    icon = 'hand-metal', metal = 'bronze',   points = 30,  description = 'Boks torbasında 500+ güç puanı al.', req = { type = 'punch_record', value = 500 } },
        { id = 'punch_750',    category = 'punch', label = 'Orta Siklet',     icon = 'hand-metal', metal = 'silver',   points = 80,  description = 'Boks torbasında 750+ güç puanı al.', req = { type = 'punch_record', value = 750 } },
        { id = 'punch_900',    category = 'punch', label = 'Ağır Siklet',     icon = 'hand-metal', metal = 'gold',     points = 200, description = 'Boks torbasında 900+ güç puanı al.', req = { type = 'punch_record', value = 900 } },
        { id = 'punch_980',    category = 'punch', label = 'Tek Yumruk Adam', icon = 'hand-metal', metal = 'platinum', points = 500, description = 'Boks torbasında 980+ güç puanı al.', req = { type = 'punch_record', value = 980 } },

        -- Duello
        { id = 'duel_first',   category = 'duel', label = 'Meydan Okuyan',      icon = 'swords', metal = 'bronze',   points = 30,  description = 'İlk 1v1 düellona katıl.',  req = { type = 'total_duels', value = 1 } },
        { id = 'duel_win_5',   category = 'duel', label = 'Yenilmez Gladyatör', icon = 'swords', metal = 'silver',   points = 150, description = 'Toplam 5 düello kazan.',   req = { type = 'duel_wins', value = 5 } },
        { id = 'duel_win_20',  category = 'duel', label = 'Salonun Efendisi',   icon = 'swords', metal = 'platinum', points = 500, description = 'Toplam 20 düello kazan.',  req = { type = 'duel_wins', value = 20 } },

        -- Bilek guresi
        { id = 'arm_win_1',    category = 'armwrestle', label = 'İlk Tokalaşma', icon = 'handshake', metal = 'bronze', points = 40,  description = 'İlk bilek güreşi galibiyetini al.', req = { type = 'armwrestle_wins', value = 1 } },
        { id = 'arm_win_5',    category = 'armwrestle', label = 'Demir Bilek',   icon = 'handshake', metal = 'silver', points = 180, description = '5 bilek güreşi maçı kazan.',        req = { type = 'armwrestle_wins', value = 5 } },
        { id = 'arm_win_15',   category = 'armwrestle', label = 'Titan Tutuşu',  icon = 'handshake', metal = 'gold',   points = 450, description = '15 bilek güreşi maçı kazan.',       req = { type = 'armwrestle_wins', value = 15 } },

        -- Disiplin & seri
        { id = 'streak_3',  category = 'streak', label = 'Haftalık Rutin',   icon = 'flame',          metal = 'bronze',   points = 100,  description = '3 gün üst üste programını tamamla.',  req = { type = 'streak_days', value = 3 } },
        { id = 'streak_7',  category = 'streak', label = 'Disiplin Abidesi', icon = 'flame',          metal = 'silver',   points = 350,  description = '7 gün üst üste programını tamamla.',  req = { type = 'streak_days', value = 7 } },
        { id = 'streak_30', category = 'streak', label = 'Yaşam Biçimi',     icon = 'calendar-check', metal = 'platinum', points = 1200, description = '30 gün üst üste programını tamamla.', req = { type = 'streak_days', value = 30 } },

        -- Program
        { id = 'prog_1',  category = 'program', label = 'İlk Program',   icon = 'clipboard-check', metal = 'bronze', points = 60,  description = 'İlk günlük programını tamamla.', req = { type = 'programs_done', value = 1 } },
        { id = 'prog_25', category = 'program', label = 'Sadık Öğrenci', icon = 'list-checks',     metal = 'gold',   points = 400, description = '25 günlük program tamamla.',     req = { type = 'programs_done', value = 25 } },

        -- Kondisyon (dusen deger — tutmak marifet)
        { id = 'cond_40',  category = 'condition', label = 'Forma Girdin',  icon = 'trending-up', metal = 'bronze',   points = 120,  description = '40 kondisyona ulaş.',  req = { type = 'condition_score', value = 40 } },
        { id = 'cond_75',  category = 'condition', label = 'Sporcu Vücudu', icon = 'heart-pulse', metal = 'gold',     points = 450,  description = '75 kondisyona ulaş.',  req = { type = 'condition_score', value = 75 } },
        { id = 'cond_100', category = 'condition', label = 'Zirve Form',    icon = 'star',        metal = 'platinum', points = 1500, description = '100 kondisyona ulaş.', req = { type = 'condition_score', value = 100 } },

        -- Form puani (omur boyu)
        { id = 'fitness_1000', category = 'fitness', label = 'Yaşam Tarzı',  icon = 'target', metal = 'silver', points = 250,  description = 'Toplam 1.000 Form Puanına ulaş.', req = { type = 'fitness_points', value = 1000 } },
        { id = 'fitness_5000', category = 'fitness', label = 'Efsane Sporcu', icon = 'award', metal = 'gold',   points = 1000, description = 'Toplam 5.000 Form Puanına ulaş.', req = { type = 'fitness_points', value = 5000 } },
    },
}
