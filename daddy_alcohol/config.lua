Config = {}

Config.Debug = false
Config.DebugAudio = false

-- Maximum alcohol points
Config.MaxAlcohol = 100

-- Thresholds and stage hysteresis
Config.Thresholds = {
    Level1 = 20, -- Tipsy (20 - 39)
    Level2 = 40, -- Moderate (40 - 69)
    Level3 = 70, -- Heavy (70 - 89)
    Level4 = 90, -- Blackout (90 - 100)
    Margin = 4   -- Points buffer before downgrading stage
}

-- Passive metabolic decay (Tiered / dynamic metabolism)
Config.Metabolism = {
    tickMs = 15000,         -- Checked every 15 seconds (reduced from 30s)
    dynamic = true,         -- Faster decay at high alcohol levels
    defaultReduce = 1,
    tiers = {
        { minPoints = 70, reduce = 3 }, -- Stage 3 & 4 (Heavy drunk: burns ~12 pts/min, shortens severe lockup)
        { minPoints = 40, reduce = 2 }, -- Stage 2 (Moderate: burns ~8 pts/min)
        { minPoints = 1,  reduce = 1 }, -- Stage 1 (Tipsy: burns ~4 pts/min)
    }
}

-- Visual profiles per alcohol type
Config.VisualProfiles = {
    ['beer'] = {
        label = 'Bira',
        timecycle = 'spectator5',      -- Warm, soft amber ambient haze
        postfx = nil,
        shake = { [1] = 0.2, [2] = 0.5, [3] = 0.9 },
        strength = { [1] = 0.35, [2] = 0.65, [3] = 0.85 },
        clipset = { [1] = nil, [2] = 'move_m@drunk@slightlydrunk', [3] = 'move_m@drunk@moderatedrunk' }
    },
    ['wine'] = {
        label = 'Şarap',
        timecycle = 'cinema',          -- Dreamy, rich velvety cinematic tone
        postfx = nil,
        shake = { [1] = 0.25, [2] = 0.6, [3] = 1.1 },
        strength = { [1] = 0.4, [2] = 0.7, [3] = 1.0 },
        clipset = { [1] = nil, [2] = 'move_m@drunk@slightlydrunk', [3] = 'move_m@drunk@moderatedrunk' }
    },
    ['cocktail'] = {
        label = 'Kokteyl',
        timecycle = 'drug_wobbly',     -- Wavy ripple, vivid saturated party colors
        postfx = nil,
        shake = { [1] = 0.3, [2] = 0.7, [3] = 1.3 },
        strength = { [1] = 0.35, [2] = 0.65, [3] = 1.0 },
        clipset = { [1] = nil, [2] = 'move_m@drunk@slightlydrunk', [3] = 'move_m@drunk@moderatedrunk' }
    },
    ['shot'] = {
        label = 'Shot',
        timecycle = 'Drunk',           -- Classic heavy drunk lens & tunnel blur
        postfx = { [3] = 'DrugsTrevorClownsFightIn' },
        shake = { [1] = 0.4, [2] = 0.9, [3] = 2.0 },
        strength = { [1] = 0.45, [2] = 0.75, [3] = 1.0 },
        clipset = { [1] = nil, [2] = 'move_m@drunk@slightlydrunk', [3] = 'move_m@drunk@verydrunk' }
    },
    ['heavy'] = {
        label = 'Kaçak İçki',
        timecycle = 'Drunk',
        postfx = { [2] = 'DrugsTrevorClownsFightIn', [3] = 'DrugsMichaelAliensFightIn' },
        shake = { [1] = 0.5, [2] = 1.2, [3] = 2.5 },
        strength = { [1] = 0.5, [2] = 0.9, [3] = 1.0 },
        clipset = { [1] = nil, [2] = 'move_m@drunk@moderatedrunk', [3] = 'move_m@drunk@verydrunk' }
    },
}

-- Audio configuration (PMA-Voice voice chat muffling, no GTA world audio distortion)
Config.Audio = {
    Debug = false,

    -- PMA-Voice voice chat muffling settings
    PmaVoice = {
        Enabled = true,
        Stage2FreqHi = 950.0,   -- Cutoff for Stage 2 (moderate voice muffle)
        Stage3FreqHi = 480.0,   -- Cutoff for Stage 3 (heavy underwater voice muffle)
    },

    -- Tinnitus (Ear ringing accent on heavy intake)
    Tinnitus = {
        Enabled = true,
        SoundSet = 'WastedSounds',
        SoundName = 'Bed',
        MinAlcohol = 75,
        CooldownMs = 45000,
    },

    -- Heartbeat (Pulsing loop accent in heavy stage)
    Heartbeat = {
        Enabled = true,
        SoundSet = 'Special_Abilities_Sounds',
        SoundName = 'Heartbeat_Loop',
        MinAlcohol = 80,
    },

    -- Vocal accents
    Hiccups = {
        Enabled = true,
        IntervalMin = 35000,
        IntervalMax = 65000,
    },
    BurpOnBeer = true,
    VomitOnBlackout = true,
}

-- Drunk driving with inverted steering & severe control disruption
Config.DrunkDriving = {
    Enabled = true,
    MinLevel = 40,
    InvertSteering = true,             -- Invert steering controls on heavy alcohol (Stage 3+)
    ModerateInvertChance = 0.0,        -- No inverted controls in Stage 2 (drift/wobble only; full inversion is Stage 3+)
    WobbleStrength = 0.75,             -- Strength of steering drift/wobble
    SteerWobbleChance = 0.40,          -- Chance of drifting left/right when going straight
    RandomHornChance = 0.10,           -- Chance of involuntary horn
}

-- Ragdoll and stumble (heavy stage only)
Config.Ragdoll = {
    Enabled = true,
    MinLevel = 70,
    CooldownMs = 8000,
    StumbleChanceWalking = 0.08,
    StumbleChanceRunning = 0.28,
}

-- Blackout settings
Config.Blackout = {
    Enabled = true,
    Threshold = 90,
    DurationMs = 8000,          -- 8 seconds blackout
    AlcoholReduction = 10,       -- Points reduced after waking up (prevents free instant detox)
    CooldownMs = 180000,        -- 3 minutes cooldown between blackouts
    WakeupDamage = 10,           -- Hangover damage applied to player
}

-- Nausea and Vomit Minigame (Stage 3+ / 75+ points)
Config.Nausea = {
    Enabled = true,
    MinAlcohol = 75,
    IntervalMin = 60000,        -- Min interval between nausea waves (ms)
    IntervalMax = 120000,       -- Max interval between nausea waves (ms)
    SuccessCooldown = 150000,   -- Cooldown after passing skill check (ms)
    FailedAlcoholReduction = 5, -- Points reduced after vomiting
    FailedDamage = 5,           -- Health damage from retching/vomiting
    SkillCheck = {
        difficulty = { { areaSize = 38, speedMultiplier = 1.6 } },
        inputs = { 'e' }
    }
}

-- Alcoholic drinks and point values
Config.Drinks = {
    -- Beers (+5 to 6 points) - ~4 beers needed for Tipsy (Stage 1)
    ['bzzz_drink_beer_a']           = { points = 6, label = 'Büyük Bira', type = 'beer' },
    ['bzzz_drink_beer_b']           = { points = 5, label = 'Şişe Bira', type = 'beer' },
    ['bzzz_drink_beer_c']           = { points = 5, label = 'Kutu Bira', type = 'beer' },
    ['bzzz_drink_beer_d']           = { points = 6, label = 'Fıçı Bira', type = 'beer' },
    ['bzzz_drink_beer_a_paddock']   = { points = 6, label = 'Paddock Bira', type = 'beer' },
    ['bzzz_drink_beer_tiki']        = { points = 5, label = 'Tiki Bira', type = 'beer' },
    ['bzzz_drink_beer_a_pier']      = { points = 6, label = 'Pier Bira', type = 'beer' },
    ['bzzz_drink_beer_c_pier']      = { points = 5, label = 'Pier Kutu Bira', type = 'beer' },
    ['bzzz_drink_beer_d_pier']      = { points = 6, label = 'Pier Fıçı Bira', type = 'beer' },
    ['bzzz_drink_beer_a_tequilala'] = { points = 6, label = 'Tequilala Bira', type = 'beer' },
    ['bzzz_drink_beer_d_tequilala'] = { points = 6, label = 'Tequilala Fıçı Bira', type = 'beer' },
    ['club77_beer']                 = { points = 5, label = 'Club77 Bira', type = 'beer' },
    ['yj_beer_bottle']              = { points = 5, label = 'Yellow Jack Bira', type = 'beer' },
    ['yj_draft_beer']               = { points = 6, label = 'Yellow Jack Fıçı Bira', type = 'beer' },
    ['ds_beer']                     = { points = 5, label = 'Diner Bira', type = 'beer' },
    ['fc_ringside_beer']            = { points = 5, label = 'Ringside Bira', type = 'beer' },
    ['lost_beer_draft']             = { points = 6, label = 'Lost MC Fıçı Bira', type = 'beer' },
    ['lost_beer_bottle']            = { points = 5, label = 'Lost MC Şişe Bira', type = 'beer' },
    ['sho_sapporo_beer']            = { points = 5, label = 'Sapporo Bira', type = 'beer' },
    ['teq_beer_apple']              = { points = 5, label = 'Elmalı Bira', type = 'beer' },
    ['teq_beer_blueberry']          = { points = 5, label = 'Yaban Mersinli Bira', type = 'beer' },
    ['teq_beer_kiwi']               = { points = 5, label = 'Kivili Bira', type = 'beer' },
    ['teq_beer_original']           = { points = 5, label = 'Orijinal Bira', type = 'beer' },
    ['pad_beer_plum']               = { points = 5, label = 'Erikli Bira', type = 'beer' },
    ['pad_beer_raspberry']          = { points = 5, label = 'Ahududulu Bira', type = 'beer' },
    ['beer']                        = { points = 5, label = 'Bira', type = 'beer' },

    -- Wines & Champagnes (+10 to 12 points) - 2 glasses for Tipsy (Stage 1), 4 for Moderate (Stage 2)
    ['bzzz_drink_mulledwine_pacific'] = { points = 10, label = 'Sıcak Şarap', type = 'wine' },
    ['club77_red_wine']             = { points = 10, label = 'Kırmızı Şarap', type = 'wine' },
    ['hp_wine_red']                 = { points = 10, label = 'Hogs Kırmızı Şarap', type = 'wine' },
    ['hp_wine_white']               = { points = 10, label = 'Hogs Beyaz Şarap', type = 'wine' },
    ['sho_plum_wine']               = { points = 10, label = 'Erik Şarabı', type = 'wine' },
    ['club77_champagne']            = { points = 10, label = 'Şampanya', type = 'wine' },
    ['sc_expensive_champagne']      = { points = 12, label = 'Lüks Şampanya', type = 'wine' },
    ['fc_victory_champagne']        = { points = 10, label = 'Zafer Şampanyası', type = 'wine' },
    ['wine']                        = { points = 10, label = 'Şarap', type = 'wine' },
    ['champagne']                   = { points = 10, label = 'Şampanya', type = 'wine' },

    -- Cocktails (+14 to 16 points) - 2 cocktails for Tipsy, 3 for Moderate (Stage 2)
    ['bzzz_drink_rumcoke_a']         = { points = 14, label = 'Cuba Libre (Rum & Coke)', type = 'cocktail' },
    ['bzzz_drink_rumcoke_a_pier']    = { points = 14, label = 'Pier Rum & Coke', type = 'cocktail' },
    ['bzzz_drink_gintonic_a_pacific']= { points = 14, label = 'Cin Tonik', type = 'cocktail' },
    ['bzzz_drink_gintonic_a_pier']   = { points = 14, label = 'Pier Cin Tonik', type = 'cocktail' },
    ['bzzz_drink_whiskeysour_a']     = { points = 14, label = 'Viski Sour', type = 'cocktail' },
    ['bzzz_drink_whiskeysour_a_pacific'] = { points = 14, label = 'Pacific Viski Sour', type = 'cocktail' },
    ['bzzz_drink_whiskeysour_a_tequilala'] = { points = 14, label = 'Tequilala Viski Sour', type = 'cocktail' },
    ['bzzz_drink_bahamamama_a_tequilala'] = { points = 14, label = 'Bahama Mama', type = 'cocktail' },
    ['bzzz_drink_bluelagoon_a_tequilala'] = { points = 14, label = 'Blue Lagoon', type = 'cocktail' },
    ['bzzz_drink_longislandicedtea_a_tequilala'] = { points = 16, label = 'Long Island Iced Tea', type = 'cocktail' },
    ['bzzz_drink_sexonthebeach_a_tequilala'] = { points = 14, label = 'Sex on the Beach', type = 'cocktail' },
    ['bzzz_drink_negroni_a_tequilala'] = { points = 15, label = 'Negroni', type = 'cocktail' },
    ['bzzz_drink_oldfashioned_a_tequilala'] = { points = 15, label = 'Old Fashioned', type = 'cocktail' },
    ['bzzz_drink_moscowmule_a_tequilala'] = { points = 14, label = 'Moscow Mule', type = 'cocktail' },
    ['bzzz_drink_tequila_sunrise_taco'] = { points = 14, label = 'Tequila Sunrise', type = 'cocktail' },
    ['club77_whiskey_sour']         = { points = 14, label = 'Club77 Viski Sour', type = 'cocktail' },
    ['club77_gin_tonic']            = { points = 14, label = 'Club77 Cin Tonik', type = 'cocktail' },
    ['club77_rum_coke']             = { points = 14, label = 'Club77 Rum Kola', type = 'cocktail' },
    ['yj_rum_coke']                 = { points = 14, label = 'Yellow Jack Rum Kola', type = 'cocktail' },
    ['yj_gin_tonic']                = { points = 14, label = 'Yellow Jack Cin Tonik', type = 'cocktail' },
    ['yj_vodka_orange']             = { points = 14, label = 'Votka Portakal', type = 'cocktail' },
    ['hp_cocktail_hoggy']           = { points = 14, label = 'Hoggy Kokteyl', type = 'cocktail' },
    ['hp_cocktail_tusker']          = { points = 14, label = 'Tusker Kokteyl', type = 'cocktail' },
    ['hp_cocktail_bristle']         = { points = 14, label = 'Bristle Kokteyl', type = 'cocktail' },
    ['sc_midnight_cocktail']        = { points = 15, label = 'Midnight Kokteyl', type = 'cocktail' },
    ['sc_tequila_sunrise_luxury']   = { points = 14, label = 'Lüks Tequila Sunrise', type = 'cocktail' },

    -- Bahama Mamas Cocktails
    ['bm_bahama_mama']              = { points = 14, label = 'Bahama Mama', type = 'cocktail' },
    ['bm_blue_lagoon']              = { points = 14, label = 'Blue Lagoon', type = 'cocktail' },
    ['bm_long_island']              = { points = 16, label = 'Long Island', type = 'cocktail' },
    ['bm_sex_on_the_beach']         = { points = 14, label = 'Sex On The Beach', type = 'cocktail' },
    ['bm_margarita']                = { points = 14, label = 'Margarita', type = 'cocktail' },
    ['bm_martini']                  = { points = 15, label = 'Martini', type = 'cocktail' },
    ['bm_bloodymary']               = { points = 14, label = 'Bloody Mary', type = 'cocktail' },
    ['bm_black_russian']            = { points = 16, label = 'Black Russian', type = 'cocktail' },
    ['bm_white_russian']            = { points = 15, label = 'White Russian', type = 'cocktail' },
    ['bm_maitai']                   = { points = 14, label = 'Mai Tai', type = 'cocktail' },

    -- Tiki Bar Cocktails
    ['tiki_kissme_cocktail']        = { points = 15, label = 'Kiss Me Tiki Kokteyl', type = 'cocktail' },
    ['tiki_twohearts_cocktail']     = { points = 15, label = 'Two Hearts Tiki Kokteyl', type = 'cocktail' },

    -- Shots and spirits (+16 points) - 1 shot relaxes, 2 shots Tipsy (Stage 1), 3 shots Moderate (Stage 2), 5 shots Heavy (Stage 3)
    ['bzzz_drink_shot_b52_a']       = { points = 16, label = 'B-52 Shot', type = 'shot' },
    ['bzzz_drink_shot_bluekamikaze_a'] = { points = 16, label = 'Blue Kamikaze Shot', type = 'shot' },
    ['bzzz_drink_shot_kamikaze_a']  = { points = 16, label = 'Kamikaze Shot', type = 'shot' },
    ['bzzz_drink_shot_vodka_a']     = { points = 16, label = 'Votka Shot', type = 'shot' },
    ['bzzz_drink_shot_rum_a']       = { points = 16, label = 'Rom Shot', type = 'shot' },
    ['bzzz_drink_shot_lemondrop_a'] = { points = 16, label = 'Lemon Drop Shot', type = 'shot' },
    ['bzzz_drink_shot_washinapple_a']= { points = 16, label = 'Washington Apple Shot', type = 'shot' },
    ['bzzz_drink_shot_rum_a_tiki']  = { points = 16, label = 'Tiki Rom Shot', type = 'shot' },
    ['bzzz_drink_shot_aloha']       = { points = 16, label = 'Aloha Shot', type = 'shot' },
    ['bzzz_drink_shot_ocean']       = { points = 16, label = 'Ocean Shot', type = 'shot' },
    ['bzzz_drink_tequila_tiki']     = { points = 16, label = 'Tekila', type = 'shot' },
    ['bzzz_drink_shot_kamikaze_pier']= { points = 16, label = 'Pier Kamikaze Shot', type = 'shot' },
    ['bzzz_drink_shot_vodka_pier']  = { points = 16, label = 'Pier Votka Shot', type = 'shot' },
    ['bzzz_drink_tequila_shot_taco']= { points = 16, label = 'Tekila Shot', type = 'shot' },
    ['bzzz_drink_mezcal_shot_taco'] = { points = 16, label = 'Mezcal Shot', type = 'shot' },
    ['bzzz_drink_shot_b52_a_tequilala'] = { points = 16, label = 'B-52 Shot', type = 'shot' },
    ['bzzz_drink_shot_bluekamikaze_a_tequilala'] = { points = 16, label = 'Blue Kamikaze', type = 'shot' },
    ['bzzz_drink_shot_kamikaze_a_tequilala'] = { points = 16, label = 'Kamikaze', type = 'shot' },
    ['bzzz_drink_shot_vodka_a_tequilala'] = { points = 16, label = 'Votka Shot', type = 'shot' },
    ['bzzz_drink_shot_rum_a_tequilala'] = { points = 16, label = 'Rom Shot', type = 'shot' },
    ['club77_vodka_shot']           = { points = 16, label = 'Club77 Votka Shot', type = 'shot' },
    ['club77_tequila_shot']         = { points = 16, label = 'Club77 Tekila Shot', type = 'shot' },
    ['c77_shot_b52']                = { points = 16, label = 'C77 B-52 Shot', type = 'shot' },
    ['yj_whiskey_neat']             = { points = 16, label = 'Sek Viski', type = 'shot' },
    ['yj_tequila_shot']             = { points = 16, label = 'Yellow Jack Tekila Shot', type = 'shot' },
    ['yj_shot_b52']                 = { points = 16, label = 'Yellow Jack B-52', type = 'shot' },
    ['hp_whiskey']                  = { points = 16, label = 'Hogs Viski', type = 'shot' },
    ['hp_rum']                      = { points = 16, label = 'Hogs Rom', type = 'shot' },
    ['hp_gin']                      = { points = 16, label = 'Hogs Cin', type = 'shot' },
    ['hp_vodka']                    = { points = 16, label = 'Hogs Votka', type = 'shot' },
    ['hp_shot_bramble']             = { points = 16, label = 'Bramble Shot', type = 'shot' },
    ['hp_shot_muddy']               = { points = 16, label = 'Muddy Shot', type = 'shot' },
    ['ds_whiskey']                  = { points = 16, label = 'Diner Viski', type = 'shot' },
    ['ed_passion_shot']             = { points = 16, label = 'Passion Shot', type = 'shot' },
    ['sc_neon_shot']                = { points = 16, label = 'Neon Shot', type = 'shot' },
    ['sc_luxury_vodka']             = { points = 16, label = 'Lüks Votka', type = 'shot' },
    ['fc_blood_shot']               = { points = 16, label = 'Blood Shot', type = 'shot' },
    ['fc_iron_fist_vodka']          = { points = 16, label = 'Iron Fist Votka', type = 'shot' },
    ['lost_rum_shot']               = { points = 16, label = 'Lost Rom Shot', type = 'shot' },
    ['lost_vodka_shot']             = { points = 16, label = 'Lost Votka Shot', type = 'shot' },
    ['lost_whiskey']                = { points = 16, label = 'Lost MC Viski', type = 'shot' },
    ['lost_dark_rum']               = { points = 16, label = 'Lost Koyu Rom', type = 'shot' },
    ['lost_tequila_shot']           = { points = 16, label = 'Lost Tekila Shot', type = 'shot' },
    ['lost_blue_shot']              = { points = 16, label = 'Lost Mavi Shot', type = 'shot' },
    ['sho_sake_shot']               = { points = 16, label = 'Sake Shot', type = 'shot' },
    ['whiskey']                     = { points = 16, label = 'Viski', type = 'shot' },
    ['vodka']                       = { points = 16, label = 'Votka', type = 'shot' },
    ['tequila']                     = { points = 16, label = 'Tekila', type = 'shot' },
    ['gin']                         = { points = 16, label = 'Cin', type = 'shot' },
    ['rum']                         = { points = 16, label = 'Rom', type = 'shot' },
    ['raki']                        = { points = 16, label = 'Rakı', type = 'shot' },
    ['pc_raki']                     = { points = 16, label = 'Yeni Rakı', type = 'shot' },

    -- Heavy / moonshine (+30 points)
    ['moonshine']                   = { points = 30, label = 'Kaçak Moonshine', type = 'heavy' },
    ['lost_moonshine']              = { points = 30, label = 'Lost MC Moonshine', type = 'heavy' },
}

-- Recovery items directly reduce alcohol points (server-authoritative)
Config.RecoveryItems = {
    -- Water
    ['water_bottle']                = { reduce = 10, label = 'Su', message = 'Soğuk su içtin, biraz ferahladın.' },
    ['lost_water']                  = { reduce = 10, label = 'Lost Kaynak Suyu', message = 'Soğuk su içtin, biraz ferahladın.' },
    ['tap_water']                   = { reduce = 10, label = 'Musluk Suyu', message = 'Su içtin, biraz ferahladın.' },
    ['wc_mountain_water']           = { reduce = 12, label = 'Kaynak Suyu', message = 'Buz gibi kaynak suyu seni ferahlattı.' },
    ['bzzz_drink_mexican_water_taco']= { reduce = 10, label = 'Meksika Suyu', message = 'Su içtin, ferahladın.' },

    -- Dairy & ayran
    ['pad_ayran']                   = { reduce = 20, label = 'Köy Ayranı', message = 'Bol köpüklü ayran mideni ve başını rahatlattı!' },
    ['bottle_milk']                 = { reduce = 18, label = 'Şişe Süt', message = 'Süt mideni yatıştırdı, alkolün etkisi azaldı.' },

    -- Coffee
    ['pad_turkish_coffee']          = { reduce = 25, label = 'Türk Kahvesi', message = 'Okkalı Türk kahvesi zihnini açtı, kendine geldin!' },
    ['bzzz_uwuprops_coffee_a']      = { reduce = 25, label = 'Sıcak Kahve', message = 'Sıcak kahve sersemliğini aldı.' },
    ['trey_iced_coffee']            = { reduce = 22, label = 'Soğuk Kahve', message = 'Soğuk kahve başındaki ağırlığı hafifletti.' },
    ['uwu_iced_coffee']             = { reduce = 22, label = 'Uwu Soğuk Kahve', message = 'Kahve zihnini toparladı.' },
    ['ds_iced_coffee']              = { reduce = 22, label = 'Diner Soğuk Kahve', message = 'Kahve zihnini toparladı.' },
    ['hd_diner_coffee']             = { reduce = 25, label = 'Filtre Kahve', message = 'Sert kahve seni kendine getirdi.' },
    ['wc_camp_coffee']              = { reduce = 25, label = 'Kamp Kahvesi', message = 'Sıcak kahve zihnini açtı.' },
    ['fc_black_eye_coffee']         = { reduce = 25, label = 'Black Eye Kahve', message = 'Sert kahve sersemliğini dağıttı!' },
    ['lost_black_coffee']           = { reduce = 25, label = 'Sade Kahve', message = 'Sade kahve başındaki uğultuyu kesti.' },
    ['sho_asian_coffee']            = { reduce = 25, label = 'Asya Kahvesi', message = 'Kahve zihnini açtı.' },
    ['coffee']                      = { reduce = 25, label = 'Kahve', message = 'Kahve seni kendine getirdi.' },

    -- Energy drinks
    ['redbull']                     = { reduce = 15, label = 'Redbull', message = 'Enerji içeceği alkolün ağırlığını hafifletti.' },
    ['pd_redbull']                  = { reduce = 18, label = 'Polis Enerji İçeceği', message = 'Yüksek kafein alkol sersemliğini dağıttı.' },

    -- Medical
    ['painkillers']                 = { reduce = 20, label = 'Ağrı Kesici', message = 'Ağrı kesici zonklayan baş ağrını kesti.' },
    ['medikit']                     = { reduce = 15, label = 'İlk Yardım Çantası', message = 'Tedavi alkolün sersemliğini hafifletti.' },
    ['pd_medikit']                  = { reduce = 15, label = 'Polis İlk Yardım Çantası', message = 'Tedavi alkolün sersemliğini hafifletti.' },
}

-- Backward compatibility alias
Config.SoberItems = Config.RecoveryItems
