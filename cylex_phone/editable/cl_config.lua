Config = {
    -- Set false if you don't want to see debug messages on console and F8
    Debug = false,                               -- Set to false if you don't want to see debug messages on f8
    ServerDebug = false,                       -- Set to false if you don't want to see debug messages on console

    Language = 'tr',
    dateLanguage = 'tr-TR',

    OpenKey = 'F1',
    OpenCommand = 'open_phone',
    WalkWhileOpen = true,

     -- 'auto' = detect the running resource automatically. Set a specific name to force it.
    Garage = 'jg-advancedgarages',                            -- auto, qb-garages, nation-garages, jg-advancedgarages, tgiann-realparking, op-garages, mGarage
    Housing = 'origen_housing',                           -- auto, cylex_housing, loaf_housing, origen_housing
    Inventory = 'ox_inventory',                         -- auto, qb-inventory, ox_inventory, mInventory, origen_inventory, tgiann-inventory, standalone (no item required)
    BossMenu = 'qb-management',                          -- auto, qb-management, nation-management, renewed-banking, esx_society
    Voice = {
        Script = 'auto',                        -- auto, pma, mumble, salty, toko, bs-voice
        CallEffects = true,                     -- Enable call effects
        HearNearbyVoice = true,                 -- If true, you can hear nearby players while on video record
    },


    Time = {
        Format = 24,                            -- 12, 24
        RealTime = true,                        -- If true, time will be synced with real time otherwise it will be synced with game time
    },

    Sounds = {
        -- If you turn this on, sounds such as ringtone and notification will be heard by the players around you in 3D.
        Enable3DSounds = true,                  
    },

    RacingItemRequired = true,                  -- If true, you need to have the item in your inventory to see racing app

    PhoneProp = `cylex_phoneprop`,
    NameChange = true,                           -- If true, player can change her name on settings app.
    HideNameAirdrop = true,                     -- If true, player names will be player id
    HideNameBilling = false,                     -- If true, player names will be player id in send invoice
    Animation = {
        -- Animation when turning the phone on and off 
        -- Realistic: makes it more realistic
        -- Default: makes it more basic
        Style = 'realistic', -- realistic, default
    },

    -- If you set true, it will delete bugged phone (floating phones) props around the player every 10 seconds.
    DeleteBuggedProps = true, 

    -- Widgets placed on the home screen by default on a brand-new (first setup) phone.
    -- Valid names: 'health', 'weather', 'gallery', 'bank'. Empty {} = none.
    DefaultWidgets = { 'weather', 'health' },

    GarageData = {
        -- 0 = free, 
        -- for example: 100 = if the player has 100$ or more unpaid invoice, player cannot take the vehicle out of the garage
        UnpaidInvoiceLimit = 0,
        
        -- 0 = free
        -- If you set any number, player cannot take the vehicle with vale without paying the price first.
        ValePrice = 100, -- Price to use vale service

        -- Vale service on/off
        ValeEnabled = true,

        -- true = vehicle spawns next to you, valet just steps out (no driving)
        ValeInstantDelivery = false,

        -- Vehicle photo host. Files must be named <spawnname>.png
        -- Empty = built-in source (base-game models only)
        VehicleImageUrl = '',
    }
}

Config.apps = {
    {
        name = 'home',
        label = 'Ana Ekran',
        hide = true,
    },
    {
        name = 'lockscreen',
        label = 'Kilit Ekranı',
        hide = true,
    },
    {
        name = 'settings',
        label = 'Ayarlar',
        icon = 'app-icon/settings.svg',
        default_installed = true,
    },
    {
        name = "appstore",
        label = 'App Store',
        icon = 'app-icon/appstore.svg',
        default_installed = true,
    },
    {
        name = 'calculator',
        label = 'Hesap Makinesi',
        icon = 'app-icon/calculator.svg',
        default_installed = true,
    },
    -- {
    --     name = 'siri',
    --     label = 'Assistant',
    --     icon = 'app-icon/siri.svg',
    --     -- hide = true,
    -- },
    {
        name = 'weather',
        label = 'Hava Durumu',
        icon = 'app-icon/weather.svg',
        default_installed = true,
    },
    {
        name = 'health',
        label = 'Sağlık',
        icon = 'app-icon/health.svg',
        default_installed = true,
    },
    {
        name = 'videoCall',
        label = 'Görüntülü Arama',
        hide = true,
    },
    {
        name = 'mail',
        label = 'Posta',
        icon = 'app-icon/mail.svg',
        default_installed = true,
    },
    {
        name = 'bank',
        label = 'Banka',
        icon = 'app-icon/bank.svg',
        default_installed = true,
    },
    {
        name = 'company',
        label = 'Şirket',
        icon = 'app-icon/company.svg',
    },
    -- {
    --     name = 'frogeats',
    --     label = 'Frogeats',
    --     icon = 'app-icon/frogeats.svg',
    --     default_installed = true,
    -- },
    -- {
    --     name = 'casino',
    --     label = 'Casino',
    --     icon = 'app-icon/casino.svg',
    -- },
    {
        name = 'news',
        label = 'Haberler',
        icon = 'app-icon/news.svg',
    },
    {
        name = "notes",
        label = 'Notlar',
        icon = 'app-icon/notes.svg',
        default_installed = true,
    },
    
    {
        name = 'twitter',
        label = 'Frogger',
        icon = 'app-icon/twitter.svg',
        VerifiedAccountPrice = 50000,
    },
     {
        name = 'swiper',
        label = 'Swiper',
        icon = 'app-icon/swiper.svg',
        VerifiedAccountPrice = 2500,
        GoldAccountPrice = 5000,
    },
    {
        name = 'instagram',
        label = 'Frogram',
        icon = 'app-icon/instagram.svg',
        VerifiedAccountPrice = 5000,
    },
     {
        name = 'foffy',
        label = 'Foffy',
        icon = 'app-icon/foffy.svg',
        VerifiedAccountPrice = 5000,
    },
    {
        name = 'frogly',
        label = 'Frogly',
        icon = 'app-icon/frogly.svg',
        VerifiedAccountPrice = 5000,
    },
    {
        name = 'house',
        label = 'Ana Ekran',
        icon = 'app-icon/house.svg',
    },
    {
        name = 'garage',
        label = 'Araçlar',
        icon = 'app-icon/garage.svg',
    },
    -- {
    --     name = 'billing',
    --     label = 'Billing',
    --     icon = 'app-icon/billing.svg',
    --     -- default_installed = true,
    -- },
    {
        name = 'yellowpage',
        label = 'Sarı Sayfalar',
        icon = 'app-icon/yellowpage.svg',
    },
    -- {
    --     name = 'racing',
    --     label = 'Yarış',
    --     icon = 'app-icon/racing.svg',
    -- },
    {
        name = 'darkchat',
        label = 'Darkchat',
        icon = 'app-icon/darkchat.svg',
    },
    -- {
    --     name = 'music',
    --     label = 'Music',
    --     icon = 'app-icon/music.svg',
    -- },
    -- {
    --     name = 'youtube',
    --     label = 'Metube',
    --     icon = 'app-icon/metube.svg',
    -- },
    {
        name = 'hacker',
        label = 'Hacker',
        icon = 'app-icon/hacker.svg',
    },
    {
        name = 'clock',
        label = 'Saat',
        icon = 'app-icon/clock.svg',
    },
    {
        name = 'streaming',
        label = 'Yayın',
        icon = 'app-icon/streaming.svg',
    },
    {
        name = 'number',
        label = '1024+1024',
        icon = 'app-icon/1024+1024.png',
        game = true,
    },
    {
        name = 'pixeltower',
        label = 'Pixel Tower',
        icon = 'app-icon/pixeltower.png',
        game = true,
    },
    {
        name = 'uno',
        label = 'Unt',
        icon = 'app-icon/uno.png',
        game = true,
    },
    {
		name = 'skatesurfers',
		label = 'Skate Surfers',
		icon = 'app-icon/skatesurfers.png',
		game = true,
	},
	{
		name = 'runtemple',
		label = 'Run Temple',
		icon = 'app-icon/runtemple.png',
		game = true,
	},
    {
		name = 'blockbusters',
		label = 'Block Busters',
		icon = 'app-icon/blockbusters.svg',
		game = true,
	},
    {
        name = 'call',
        label = 'Telefon',
        icon = 'app-icon/callapp.svg',
        bottom = true,
        default_installed = true,
    },
    {
        name = 'camera',
        label = 'Kamera',
        icon = 'app-icon/camera.svg',
        bottom = true,
        default_installed = true,
    },
    {
        name = 'gallery',
        label = 'Galeri',
        icon = 'app-icon/gallery.svg',
        bottom = true,
        default_installed = true,
    },
    {
        name = 'messages',
        label = 'Mesajlar',
        icon = 'app-icon/messages.svg',
        bottom = true,
        default_installed = true,
    },
}

Companys = {
    {
        job = "police",
        label = "Polis Departmanı",
        icon = "https://assets.cylexdev.com/cylex_phone/icons/company/police.png",

        location = {
            name = 'Polis Departmanı',
            x = 441.2,
            y = -978.5,
            z = 30.7,
        },

        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 }
    },
    {
        job = "doj",
        label = "DOJ",
        icon = "https://assets.cylexdev.com/cylex_phone/icons/company/police.png",

        location = {
            name = 'DOJ',
            x = -539.8606,
            y = -213.4408,
            z = 37.6499,
        },

        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 }
    },
    {
        job = "sasp",
        label = "SASP",
        icon = "https://assets.cylexdev.com/cylex_phone/icons/company/police.png",

        location = {
            name = 'SASP',
            x = -3100.11,
            y = 1412.78,
            z = 20.62,
        },

        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 }
    },
    {
        job = "sapr",
        label = "SAPR",
        icon = "https://assets.cylexdev.com/cylex_phone/icons/company/police.png",

        location = {
            name = 'SAPR',
            x = 395.45,
            y = 781.06,
            z = 186.77,
        },

        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 }
    },
    {
        job = "pbsd",
        label = "Paleto Bay Şerifliği",
        icon = "https://assets.cylexdev.com/cylex_phone/icons/company/police.png",

        location = {
            name = 'Paleto Bay Şerifliği',
            x = -433.4237,
            y = 6017.9453,
            z = 31.4902,
        },

        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 }
    },
    {
        job = "cppd",
        label = "Cayo Perico Polisi",
        icon = "https://assets.cylexdev.com/cylex_phone/icons/company/police.png",

        location = {
            name = 'Cayo Perico Polisi',
            x = 4378.5586,
            y = -4283.2319,
            z = 3.6494,
        },

        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 }
    },
    {
        job = "bcso",
        label = "Şerif Departmanı",
        icon = "https://assets.cylexdev.com/cylex_phone/icons/company/police.png",

        location = {
            name = 'Şerif Departmanı',
            x = 1809.78,
            y = 3668.18,
            z = 34.25,
        },

        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 }
    },
    {
        job = "ambulance",
        label = "Sağlık Merkezi",
        icon = "https://assets.cylexdev.com/cylex_phone/icons/company/ambulance.png",

        location = {
            name = 'Sağlık Merkezi',
            x = 1154.54,
            y = -1512.25,
            z = 34.69,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }
    },
    {
        job = "dovmeci1",
        label = "Dövmeci 1",
        icon = "https://gta-assets.blueskyrp.net/phone_icons/company/police.png",
        hidden = true,
        location = {
            name = 'Dövmeci 1',
            x = -112.2402,
            y = -12.2316,
            z = 70.5195,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job = "dovmeci2",
        label = "Dövmeci 2",
        icon = "https://gta-assets.blueskyrp.net/phone_icons/company/police.png",
        hidden = true,
        location = {
            name = 'Dövmeci 2',
            x = -1154.17,
            y = -1426.53,
            z = 4.95,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job = "dovmeci3",
        label = "Dövmeci 3",
        icon = "https://gta-assets.blueskyrp.net/phone_icons/company/police.png",
        hidden = true,
        location = {
            name = 'Dövmeci 3',
            x = 323.11,
            y = 180.77,
            z = 103.59,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job = "dovmeci4",
        label = "Dövmeci 4",
        icon = "https://gta-assets.blueskyrp.net/phone_icons/company/police.png",
        hidden = true,
        location = {
            name = 'Dövmeci 4',
            x = 1148.77,
            y = -1514.36,
            z = 10.63,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job = "dovmeci5",
        label = "Dövmeci 5",
        icon = "https://gta-assets.blueskyrp.net/phone_icons/company/police.png",
        hidden = true,
        location = {
            name = 'Dövmeci 5',
            x = -3170.9092,
            y = 1075.3573,
            z = 20.8292,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job = "dovmeci6",
        label = "Dövmeci 6",
        icon = "https://gta-assets.blueskyrp.net/phone_icons/company/police.png",
        hidden = true,
        location = {
            name = 'Dövmeci 6',
            x = -3170.9092,
            y = 1075.3573,
            z = 20.8292,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job = "dovmeci7",
        label = "Dövmeci 7",
        icon = "https://gta-assets.blueskyrp.net/phone_icons/company/police.png",
        hidden = true,
        location = {
            name = 'Dövmeci 6',
            x = -3170.9092,
            y = 1075.3573,
            z = 20.8292,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },    
    {
        job             = "mekanik1",
        label           = "Mekanik 1",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Mekanik 1',
            x = -1424.85,
            y = -447.13,
            z = 35.91,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "mekanik2",
        label           = "Mekanik 2",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Mekanik 2',
            x = -1424.85,
            y = -447.13,
            z = 35.91,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "mekanik3",
        label           = "Mekanik 3",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Mekanik 3',
            x = -1424.85,
            y = -447.13,
            z = 35.91,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "mekanik4",
        label           = "Mekanik 4",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Mekanik 4',
            x = -1424.85,
            y = -447.13,
            z = 35.91,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "mekanik5",
        label           = "Mekanik 5",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Mekanik 5',
            x = 1090.4722,
            y = -888.3101,
            z = 50.3192,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "mekanik6",
        label           = "Mekanik 6",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Mekanik 6',
            x = 732.6266,
            y = -1088.8141,
            z = 21.4591,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "mekanik7",
        label           = "Mekanik 7",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Mekanik 7',
            x = 956.0053,
            y = -987.7523,
            z = 40.0933,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "mekanik8",
        label           = "Mekanik 8",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Mekanik 8',
            x = 956.0053,
            y = -987.7523,
            z = 40.0933,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "illegalmekanik1",
        label           = "AfterLife Mekanik",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'AfterLife Mekanik',
            x = 894.06,
            y = -2515.96,
            z = 27.78,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "illegalmekanik2",
        label           = "Bunker Mekanik",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Bunker Mekanik',
            x = 731.28,
            y = -1036.8,
            z = 0.59,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "gunshop1",
        label           = "Silahçı 1",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Gunshop 1',
            x = -1306.4478,
            y = -389.0718,
            z = 37.8630,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "gunshop2",
        label           = "Silahçı 2",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Gunshop 2',
            x = 252.1781,
            y = -44.9531,
            z = 71.0713,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "gunshop3",
        label           = "Silahçı 3",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Gunshop 3',
            x = -3172.2063,
            y = 1082.6619,
            z = 21.8585,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "gunshop4",
        label           = "Silahçı 4",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Gunshop 4',
            x = 22.5645,
            y = -1104.7150,
            z = 30.7706,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "gunshop5",
        label           = "Silahçı 5",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Gunshop 5',
            x = -1306.5730,
            y = -389.7198,
            z = 36.6958,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "gunshop6",
        label           = "Silahçı 6",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Gunshop 6',
            x = 812.3385,
            y = -2146.1985,
            z = 29.3739,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "lojistik1",
        label           = "Lojistik 1",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Lojistik 1',
            x = 1987.7142,
            y = 3016.7178,
            z = 47.0563,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "lojistik2",
        label           = "Lojistik 2",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Lojistik 2',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "pawnshop1",
        label           = "Rehinci 1",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Pawnshop 1',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "pawnshop2",
        label           = "Rehinci 2",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Pawnshop 2',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "kalpazan1",
        label           = "Kalpazan 1",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Kalpazan 1',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "kalpazan2",
        label           = "Kalpazan 2",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Kalpazan 2',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "kalpazan3",
        label           = "Kalpazan 3",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Kalpazan 3',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "kalpazan4",
        label           = "Kalpazan 4",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,
        location        = {
            name = 'Kalpazan 4',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "news",
        label           = "Haber Merkezi",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",

        location        = {
            name = 'Haberler',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "tacir1",
        label           = "Tacir 1",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,

        location        = {
            name = 'Tacir 1',
            x = 991.9782,
            y = -1661.9338,
            z = 29.5528,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "tacir2",
        label           = "Tacir 2",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,

        location        = {
            name = 'Tacir 2',
            x = 1394.5031,
            y = 3613.8091,
            z = 34.9809,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "tacir3",
        label           = "Tacir 3",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,

        location        = {
            name = 'Tacir 3',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "tacir4",
        label           = "Tacir 4",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,

        location        = {
            name = 'Tacir 4',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "torbaci1",
        label           = "Torbaci 1",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,

        location        = {
            name = 'Torbaci 1',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "torbaci2",
        label           = "Torbaci 2",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,

        location        = {
            name = 'Torbaci 2',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "torbaci3",
        label           = "Torbaci 3",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,

        location        = {
            name = 'Torbaci 3',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "torbaci4",
        label           = "Torbaci 4",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,

        location        = {
            name = 'Torbaci 4',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "blackmarket2",
        label           = "Kara Borsa 2",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,

        location        = {
            name = 'Black Market 2',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "blackmarket1",
        label           = "Kara Borsa 1",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,

        location        = {
            name = 'Black Market 1',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "emlakci1",
        label           = "Emlakci 1",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,

        location        = {
            name = 'Emlakci 1',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "emlakci2",
        label           = "Emlakci 2",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,

        location        = {
            name = 'Emlakci 2',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "weedshop1",
        label           = "Ot Dükkanı 1",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,

        location        = {
            name = 'Weedshop 1',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job             = "weedshop2",
        label           = "Ot Dükkanı 2",
        icon            = "https://gta-assets.blueskyrp.net/cylex_phone/company/mechanic.png",
        hidden          = true,

        location        = {
            name = 'Weedshop 2',
            x = -659.04,
            y = -938.83,
            z = 21.83,
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job = "cardealer",
        label = "Galeri",
        icon = "https://gta-assets.blueskyrp.net/cylex_phone/company/cardealer.png",
        hidden = true,
        location = {
            name = 'Galeri',
            x = -55.9281,
            y = -1116.5176,
            z = 26.4349
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
    {
        job = "cardealer2",
        label = "Galeri 2",
        icon = "https://gta-assets.blueskyrp.net/cylex_phone/company/cardealer.png",
        hidden = true,
        location = {
            name = 'Galeri 2',
            x = -55.9281,
            y = -1116.5176,
            z = 26.4349
        },
        job_call_grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
    },
}

Config.settings = {
    [0] = {
        {
            name = 'airplane',
            label = 'Uçak Modu',
            icon = '@/assets/icons/settings/airplane.png',
            type = 'slider',
        },
        {
            name = 'wifi',
            label = 'Wi-Fi',
            icon = '@/assets/icons/settings/wifi.png',
            type = 'text',
        },
        {
            name = 'bluetooth',
            label = 'Bluetooth',
            icon = '@/assets/icons/settings/bluetooth.png',
            type = 'text',
        },
        {
            name = 'faceid',
            label = 'Face ID',
            icon = '@/assets/icons/settings/faceid.png',
            type = 'text',
        },
        {
            name = 'wallpaper',
            label = 'Duvar Kağıdı',
            icon = '@/assets/icons/settings/wallpaper.png',
            type = 'arrow',
            app = true,
        },
    },
    [1] = {
         {
            name = 'about',
            label = 'Hakkında',
            icon = '../images/icons/settings/about.png',
            type = 'arrow',
            app = true,
        },
        {
            name = 'language',
            label = 'Dil',
            icon = '../images/icons/settings/language.png',
            type = 'arrow',
            app = true,
        },
        {
            name = 'pet',
            label = 'Evcil Hayvan',
            icon = '../images/icons/settings/pet.png',
            type = 'arrow',
            app = true,
        },
        {
            name = 'notification',
            label = 'Bildirimler',
            icon = '../images/icons/settings/notification.png',
            type = 'arrow',
            app = true,
        },
        {
            name = 'focus',
            label = 'Odak ve Tema',
            icon = '@/assets/icons/settings/focus.png',
            type = 'arrow',
            app = true,
        },
        {
            name = 'sound',
            label = 'Sesler',
            icon = '../images/icons/settings/sound.png',
            type = 'arrow',
            app = true,
        },
    },
}

Config.ringtone_sounds = {
	{
		name = 'default',
		label = 'Varsayılan',
	},
	{
		name = 'marimba',
		label = 'Marimba',
	},
	{
		name = 'sencha',
		label = 'Sencha',
	},
}

Config.notification_sounds = {
	{
		name = 'default',
		label = 'Varsayılan',
	},
	{
		name = 'note',
		label = 'Nota',
	},
	{
		name = 'circles',
		label = 'Circles',
	},
	{
		name = 'rebaund',
		label = 'Rebaund',
	},
	{
		name = 'popcorn',
		label = 'Popcorn',
	},
	{
		name = 'glass',
		label = 'Glass',
	},
	{
		name = 'chord',
		label = 'Chord',
	},
	{
		name = 'aurora',
		label = 'Aurora',
	},
}

Config.wallpapers = {
    'b1.png',
	'b2.png',
	'b3.png',
	'b4.png',
	'b5.png',
	'b6.png',
	'b7.png',
	'b8.png',
	'b9.png',
	'b10.png',
	'b11.png',
	'b12.png',
	'b13.png',
	'b14.png',
	'b15.png',
	'b16.png',
	'b17.png',
	'b18.png',
	'b19.png',
	'b20.png',
	'b21.png',
	'b22.png',
	'b23.png',
	'b24.png',
	'b25.png',
	'b26.png',
	'b27.png',
	'b28.png',
	'b29.png',
	'b30.png',
	'b31.png',
	'b32.png',
	'b33.png',
	'b36.png',
	'b37.png',
	'b38.png',
	'b39.jpg',
	'b40.png',
	'b41.png',
	'b42.jpg',
}

Config.casino = {
    ['management'] = {
        job_name = 'casino',
        price_cut = 0.5, -- 50% of the money lost from the app goes to the casino job money.
    },
    ["plinko"] = {
        min_bet_amount = 10,
        max_bet_amount = 5000,
    },
    ["dice"] = {
        min_bet_amount = 10,
        max_bet_amount = 5000,
        -- Higher chance means harder to win
        chance = 60,
    },
    ["mine"] = {
        min_bet_amount = 10,
        max_bet_amount = 5000,
    },
    BucketMultipliers = {
        ["high"] = {
            ["8"] = {29, 4, 1.5, 0.3, 0.2, 0.3, 1.5, 4, 29},
            ["9"] = {43, 7, 2, 0.6, 0.2, 0.2, 0.6, 2, 7, 43},
            ["10"] = {76, 10, 3, 0.9, 0.3, 0.2, 0.3, 0.9, 3, 10, 76},
            ["11"] = {120, 14, 5.2, 1.4, 0.4, 0.2, 0.2, 0.4, 1.4, 5.2, 14, 120},
            ["12"] = {170, 24, 8.1, 2, 0.7, 0.2, 0.2, 0.2, 0.7, 2, 8.1, 24, 170},
            ["13"] = {260, 37, 11, 4, 1, 0.2, 0.2, 0.2, 0.2, 1, 4, 11, 37, 260},
            ["14"] = {420, 56, 18, 5, 1.9, 0.3, 0.2, 0.2, 0.2, 0.3, 1.9, 5, 18, 56, 420},
            ["15"] = {620, 83, 27, 8, 3, 0.5, 0.2, 0.2, 0.2, 0.2, 0.5, 3, 8, 27, 83, 620},
            ["16"] = {1000, 130, 26, 9, 4, 2, 0.2, 0.2, 0.2, 0.2, 0.2, 2, 4, 9, 26, 130, 1000},
        },
        ["medium"] = {
            ["8"] = {13, 3, 1.3, 0.7, 0.4, 0.7, 1.3, 3, 13},
            ["9"] = {18, 4, 1.7, 0.9, 0.5, 0.5, 0.9, 1.7, 4, 18},
            ["10"] = {22, 5, 2, 1.4, 0.6, 0.4, 0.6, 1.4, 2, 5, 22},
            ["11"] = {24, 6, 3, 1.8, 0.7, 0.5, 0.5, 0.7, 1.8, 3, 6, 24},
            ["12"] = {33, 11, 4, 2, 1.1, 0.6, 0.3, 0.6, 1.1, 2, 4, 11, 33},
            ["13"] = {43, 13, 6, 3, 1.3, 0.7, 0.4, 0.4, 0.7, 1.3, 3, 6, 13, 43},
            ["14"] = {58, 15, 7, 4, 1.9, 1, 0.5, 0.2, 0.5, 1, 1.9, 4, 7, 15, 58},
            ["15"] = {88, 18, 11, 5, 3, 1.3, 0.5, 0.3, 0.3, 0.5, 1.3, 3, 5, 11, 18, 88},
            ["16"] = {110, 41, 10, 5, 3, 1.5, 1, 0.5, 0.3, 0.5, 1, 1.5, 3, 5, 10, 41, 110},
        },
        ["low"] = {
            ["8"] = {5.6, 2.1, 1.1, 1, 0.5, 1, 1.1, 2.1, 5.6},
            ["9"] = {5.6, 2, 1.6, 1, 0.7, 0.7, 1, 1.6, 2, 5.6},
            ["10"] = {8.9, 3, 1.4, 1.1, 1, 0.5, 1, 1.1, 1.4, 3, 8.9},
            ["11"] = {8.4, 3, 1.9, 1.3, 1, 0.7, 0.7, 1, 1.3, 1.9, 3, 8.4},
            ["12"] = {10, 3, 1.6, 1.4, 1.1, 1, 0.5, 1, 1.1, 1.4, 1.6, 3, 10},
            ["13"] = {8.1, 4, 3, 1.9, 1.2, 0.9, 0.7, 0.7, 0.9, 1.2, 1.9, 3, 4, 8.1},
            ["14"] = {7.1, 4, 1.9, 1.4, 1.3, 1.1, 1, 0.5, 1, 1.1, 1.3, 1.4, 1.9, 4, 7.1},
            ["15"] = {15, 8, 3, 2, 1.5, 1.1, 1, 0.7, 0.7, 1, 1.1, 1.5, 2, 3, 8, 15},
            ["16"] = {16, 9, 2, 1.4, 1.4, 1.2, 1.1, 1, 0.5, 1, 1.1, 1.2, 1.4, 1.4, 2, 9, 16},
        }
    },
    
    PlinkoChances = {
        ["8"] = {0.2006, 3.1250, 10.9375, 21.8750, 27.3438, 21.8750, 10.9375, 3.1250, 0.2006},
        ["9"] = {0.1053, 1.7578, 7.0313, 16.4063, 24.6094, 24.6094, 16.4063, 7.0313, 1.7578, 0.1053},
        ["10"] = {0.0477, 1.0742, 4.3945, 11.8164, 20.0195, 24.9023, 20.0195, 11.8164, 4.3945, 1.0742, 0.0477},
        ["11"] = {0.0288, 0.5371, 2.4414, 7.3242, 15.6250, 22.9492, 22.9492, 15.6250, 7.3242, 2.4414, 0.5371, 0.0288},
        ["12"] = {0.0144, 0.2686, 1.2207, 4.3945, 10.2539, 18.2617, 23.7305, 18.2617, 10.2539, 4.3945, 1.2207, 0.2686, 0.0144},
        ["13"] = {0.0062, 0.1348, 0.6104, 2.1973, 6.3477, 13.9648, 21.4844, 21.4844, 13.9648, 6.3477, 2.1973, 0.6104, 0.1348, 0.0062},
        ["14"] = {0.0031, 0.0674, 0.3052, 1.0986, 4.1504, 10.0586, 17.5781, 22.2656, 17.5781, 10.0586, 4.1504, 1.0986, 0.3052, 0.0674, 0.0031},
        ["15"] = {0.0015, 0.0337, 0.1526, 0.5493, 2.6855, 7.8125, 14.3555, 20.0195, 20.0195, 14.3555, 7.8125, 2.6855, 0.5493, 0.1526, 0.0337, 0.0015},
        ["16"] = {0.007, 0.0168, 0.0763, 0.2747, 1.3428, 4.8828, 11.7188, 17.0898, 21.4844, 17.0898, 11.7188, 4.8828, 1.3428, 0.2747, 0.0763, 0.0168, 0.007},
    }
}

-- Key is job name, value is minimum grade to access the app
Config.news_jobs = {
    ['news'] = 0,
    ['weazel'] = 0,
}


-- DaddyRP: the bank app shows and pays the bills of daddy_bills (frameworks/*/billing/daddyBills.lua)
Config.Billing = 'daddyBills'

Config.billing = {
    -- If true, everyone can send invoices to everyone. 
    -- If false, only jobs can send invoices to bottom jobs (even if false, bottom jobs can still send invoices).
    EnableEveryoneToSend = true,
    Jobs = {
        ['police'] = {
            ['label'] = 'Polis',

            ['price_cut_sender'] = {
                -- If true, the job will receive a cut from the money sent to the job.
                -- If it is false, no money goes into the job money.
                enabled = true, 
                percent = 50, -- 100% of the money goes to the job money.
            },
            ['price_cut_receiver'] = {
                enabled = true,
                percent = 50 -- 50% of the money goes to the job money.
            },

            ['send'] = { 0, 1, 2, 3, 4, 5, 6, 7 },
            ['receive'] = { 'all' },
        },
        ['ambulance'] = {
            ['label'] = 'Ambulans',
            ['price_cut_sender'] = {
                enabled = true, 
                percent = 100, 
            },
            ['price_cut_receiver'] = {
                enabled = false,
                percent = 0 
            },
            ['send'] = { 0, 1, 2, 3, 4, 5, 6, 7 },
            ['receive'] = { 0, 1, 2, 3, 4, 5, 6, 7 },
        },
        ['cardealer'] = {
            ['label'] = 'Galerici',
            ['price_cut_sender'] = {
                enabled = true, 
                percent = 50
            },
            ['price_cut_receiver'] = {
                enabled = true,
                percent = 50
            },
            ['send'] = { 'all' },
            ['receive'] = { 'all' },
        },
        ['taxi'] = {
            ['label'] = 'Taksi',
            ['price_cut_sender'] = {
                enabled = true, 
                percent = 50
            },
            ['price_cut_receiver'] = {
                enabled = true,
                percent = 50
            },
            ['send'] = { 'all' },
            ['receive'] = { 'all' },
        },
        ['mechanic'] = {
            ['label'] = 'Mekanik',
            ['price_cut_sender'] = {
                enabled = true, 
                percent = 50
            },
            ['price_cut_receiver'] = {
                enabled = true,
                percent = 50
            },
            ['send'] = { 'all' },
            ['receive'] = { 'all' },
        },
        ['bennys'] = {
            ['label'] = 'Bennys',
            ['price_cut_sender'] = {
                enabled = true, 
                percent = 50
            },
            ['price_cut_receiver'] = {
                enabled = true,
                percent = 50
            },
            ['send'] = { 'all' },
            ['receive'] = { 'all' },
        },
        ['burgershot'] = {
            ['label'] = 'Burgershot',
            ['price_cut_sender'] = {
                enabled = true, 
                percent = 50
            },
            ['price_cut_receiver'] = {
                enabled = true,
                percent = 50
            },
            ['send'] = { 'all' },
            ['receive'] = { 'all' },
        },
        ['uwu'] = {
            ['label'] = 'Uwu',
            ['price_cut_sender'] = {
                enabled = true, 
                percent = 50
            },
            ['price_cut_receiver'] = {
                enabled = true,
                percent = 50
            },
            ['send'] = { 'all' },
            ['receive'] = { 'all' },
        },
    },
}

Config.camera = {
    effects = {
        {
            name = "natural",
            type = "timecycle", -- veya "screeneffect"
            modifier = nil,
            strength = 0.0,
            description = "Natural",
            transitionTime = 400,
            color = "#FFFFFF"
        },
        {
            name = "valencia",
            type = "timecycle",
            modifier = 'MP_corona_heist',
            strength = 0.5,
            description = "Valencia",
            transitionTime = 500,
            color = "#E17055"
        },
        {
            name = "lark",
            type = "timecycle",
            modifier = 'MP_corona_selection',
            strength = 0.6,
            description = "Lark",
            transitionTime = 500,
            color = "#FDCB6E"
        },
        {
            name = "reyes",
            type = "timecycle",
            modifier = 'NG_filmic02',
            strength = 0.7,
            description = "Reyes",
            transitionTime = 600,
            color = "#A29BFE"
        },
        {
            name = "blue",
            type = "screeneffect",
            modifier = 'DeathFailMichaelIn',
            strength = 0.8,
            description = "Blue",
            transitionTime = 1000,
            color = "#74B9FF"
        },
        {
            name = "blue2",
            type = "screeneffect",
            modifier = 'DeadlineNeon',
            strength = 0.8,
            description = "Blue",
            transitionTime = 1000,
            color = "#74B9FF"
        },
        {
            name = "blue3",
            type = "screeneffect",
            modifier = 'BikerFormation',
            strength = 0.8,
            description = "",
            transitionTime = 1000,
            color = "#E17055"
        },
        {
            name = "blue4",
            type = "screeneffect",
            modifier = 'BikerFilter',
            strength = 0.8,
            description = "",
            transitionTime = 1000,
            color = "#E17055"
        },
        {
            name = "blue5",
            type = "screeneffect",
            modifier = 'CamPushInTrevor',
            strength = 0.8,
            description = "",
            transitionTime = 1000,
            color = "#E17055"
        },
        {
            name = "blue6",
            type = "screeneffect",
            modifier = 'CrossLine',
            strength = 0.8,
            description = "",
            transitionTime = 1000,
            color = "#E17055"
        },
        {
            name = "blue7",
            type = "screeneffect",
            modifier = 'DeathFailMPIn',
            strength = 0.8,
            description = "",
            transitionTime = 1000,
            color = "#E17055"
        },
        {
            name = "blue8",
            type = "screeneffect",
            modifier = 'DeathFailNeutralIn',
            strength = 0.8,
            description = "",
            transitionTime = 1000,
            color = "#E17055"
        },
        {
            name = "blue9",
            type = "screeneffect",
            modifier = 'DeathFailTrevorIn',
            strength = 0.8,
            description = "",
            transitionTime = 1000,
            color = "#E17055"
        },
        {
            name = "drunk",
            type = "screeneffect",
            modifier = 'DrugsMichaelAliensFight',
            strength = 0.3,
            description = "Drunk",
            transitionTime = 800,
            color = "#FF6B9D"
        },
        
        {
            name = "juno",
            type = "timecycle",
            modifier = 'MP_corona_heist',
            strength = 0.6,
            description = "Juno",
            transitionTime = 550,
            color = "#00B894"
        },
        {
            name = "ludwig",
            type = "timecycle",
            modifier = 'MP_NIGHT',
            strength = 0.8,
            description = "Ludwig",
            transitionTime = 650,
            color = "#2D3436"
        },
        {
            name = "nightvision",
            type = "screeneffect",
            modifier = 'nightvision',
            strength = 1.0,
            description = "Night Vision - Gece görüş",
            transitionTime = 500,
            color = "#00FF41"
        },
        {
            name = "perpetua",
            type = "timecycle",
            modifier = 'REDMIST_blend',
            strength = 0.9,
            description = "Perpetua",
            transitionTime = 600,
            color = "#6C5CE7"
        },
        {
            name = "amaro",
            type = "timecycle",
            modifier = 'MP_corona_selection',
            strength = 0.8,
            description = "Amaro",
            transitionTime = 550,
            color = "#F39C12"
        },
        {
            name = "mayfair",
            type = "timecycle",
            modifier = 'hud_def_blur',
            strength = 0.7,
            description = "Mayfair",
            transitionTime = 500,
            color = "#E84393"
        },
        {
            name = "rise",
            type = "timecycle",
            modifier = 'NG_filmic02',
            strength = 0.6,
            description = "Rise",
            transitionTime = 450,
            color = "#F1C40F"
        },
        {
            name = "hudson",
            type = "timecycle",
            modifier = 'MP_NIGHT',
            strength = 0.7,
            description = "Hudson",
            transitionTime = 600,
            color = "#3498DB"
        },
        -- You can add more effects here
    }
}