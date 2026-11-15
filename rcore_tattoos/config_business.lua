-- Businesses
ConfigBusiness = {}

ConfigBusiness.DefaultMargin = 0 -- price margin in percent (0 = ekranda saf liste fiyatı gözükür)
ConfigBusiness.MinMargin = 0      -- minimal price margin that business owner can set in percents
ConfigBusiness.MaxMargin = 0      -- maximal price margin that business owner can set in percents

-- Tattooing Minigame
ConfigBusiness.MinigameDifficulty = 6.0       -- Multiplier of tattooing minigame difficulty, default = 1.0
ConfigBusiness.MinigameConfirmTimeout = 10000 -- Time in ms for employee to confirm start of tattooing, default = 10000 (10sec)
ConfigBusiness.TutorialReadTimeFirst = 4000   -- Time in ms for employee to read minigame tutorial before it starts for first time since logging in to server, default = 4000 (4s)
ConfigBusiness.TutorialReadTime = 500         -- Same as `TutorialReadTimeFirst`, but for all but first minigame plays, default = 500 (0.5s)

-- If true, grades defined for the specific business here in config will be added to ESX `job_grades` table.
-- For settings of the grades, check the documentation.
ConfigBusiness.AutoInsertJobGrades = false

-- Settings for ESX bossmenu
ConfigBusiness.DefaultESXMenuOptions = {
    withdraw = true,
    deposit = true,
    wash = false,
    employees = true,
    grades = true,
}

ConfigBusiness.Businesses = {
    dovmeci1 = {
        enabled = true,
        businessName = "dovmeci1",
        owner = "0cba7977a17d6a08c31db9d5db0cf6554cf1e8cd",
        bossMenu = {
            pos         = vector3(-112.37, -10.26, 70.51),
            size        = vector3(1, 1, 1),
            color       = { r = 255, g = 255, b = 255, a = 255 },
            markerLabel = '💼'
        },
        job = {
            enabled = true,
            label = "Dövme Dükkanı",
            employeeMarkerLabel = "🖌",
            customerAnim = {
                sitting = {
                    pos = vector4(-112.37, -10.26, 70.51, 162.26),
                    animName = 'ig_5_p3_base',
                    animDict = 'timetable@ron@ig_5_p3',
                },
            },
            employeeAnim = {
                idle = {
                    pos = vector3(-113.14, -9.98, 70.52),
                    animName = '_idle_a',
                    animDict = 'random@shop_tattoo',
                },
                tattoo = {
                    animName = 'machinic_loop_mechandplayer',
                    animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                },
            },
            grades = {
                {
                    name = 'novice',
                },
                {
                    name = 'artist',
                },
                {
                    name = 'boss',
                    isBoss = true,
                },
            },
        },
    },
    dovmeci1_chair2 = {
        enabled = true,
        businessName = "dovmeci1",
        owner = "0cba7977a17d6a08c31db9d5db0cf6554cf1e8cd",
        bossMenu = {
            pos         = vector3(-112.37, -10.26, 70.51),
            size        = vector3(1, 1, 1),
            color       = { r = 255, g = 255, b = 255, a = 255 },
            markerLabel = '💼'
        },
        job = {
            enabled = true,
            label = "Dövme Dükkanı",
            employeeMarkerLabel = "🖌",
            customerAnim = {
                sitting = {
                    pos = vector4(-112.2402, -12.2316, 70.5195, 23.5599),
                    animName = 'ig_5_p3_base',
                    animDict = 'timetable@ron@ig_5_p3',
                },
            },
            employeeAnim = {
                idle = {
                    pos = vector3(-111.6185, -11.3709, 70.5195),
                    heading = 156.2426,
                    animName = '_idle_a',
                    animDict = 'random@shop_tattoo',
                },
                tattoo = {
                    animName = 'machinic_loop_mechandplayer',
                    animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                },
            },
            grades = {
                {
                    name = 'novice',
                },
                {
                    name = 'artist',
                },
                {
                    name = 'boss',
                    isBoss = true,
                },
            },
        },
    },
    dovmeci2 = {
        enabled = true,
        businessName = "dovmeci2",
        owner = "0cba7977a17d6a08c31db9d5db0cf6554cf1e8cd",
        bossMenu = {
            pos         = vector3(-1154.17, -1426.53, 4.95),
            size        = vector3(1, 1, 1),
            color       = { r = 255, g = 255, b = 255, a = 255 },
            markerLabel = '💼'
        },
        job = {
            enabled = true,
            label = "Dövme Dükkanı",
            employeeMarkerLabel = "🖌",
            customerAnim = {
                sitting = {
                    pos = vector4(-1154.17, -1426.53, 4.95, 357.79),
                    animName = 'ig_5_p3_base',
                    animDict = 'timetable@ron@ig_5_p3',
                },
            },
            employeeAnim = {
                idle = {
                    pos = vector3(-1154.17, -1426.53, 4.95),
                    animName = '_idle_a',
                    animDict = 'random@shop_tattoo',
                },
                tattoo = {
                    animName = 'machinic_loop_mechandplayer',
                    animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                },
            },
            grades = {
                {
                    name = 'novice',
                },
                {
                    name = 'artist',
                },
                {
                    name = 'boss',
                    isBoss = true,
                },
            },
        },
    },
    dovmeci3 = {
        enabled = true,
        businessName = "dovmeci3",
        owner = "0cba7977a17d6a08c31db9d5db0cf6554cf1e8cd",
        bossMenu = {
            pos         = vector3(323.01, 181.60, 103.59),
            size        = vector3(1, 1, 1),
            color       = { r = 255, g = 255, b = 255, a = 255 },
            markerLabel = '💼'
        },
        job = {
            enabled = true,
            label = "Dövme Dükkanı",
            employeeMarkerLabel = "🖌",
            customerAnim = {
                sitting = {
                    pos = vector4(323.20, 180.82, 103.59, 110.89),
                    animName = 'ig_5_p3_base',
                    animDict = 'timetable@ron@ig_5_p3',
                },
            },
            employeeAnim = {
                idle = {
                    pos = vector3(323.01, 181.60, 103.59),
                    animName = '_idle_a',
                    animDict = 'random@shop_tattoo',
                },
                tattoo = {
                    animName = 'machinic_loop_mechandplayer',
                    animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                },
            },
            grades = {
                {
                    name = 'novice',
                },
                {
                    name = 'artist',
                },
                {
                    name = 'boss',
                    isBoss = true,
                },
            },
        },
    },
    dovmeci3_chair2 = {
        enabled = true,
        businessName = "dovmeci3",
        owner = "0cba7977a17d6a08c31db9d5db0cf6554cf1e8cd",
        bossMenu = {
            pos         = vector3(323.01, 181.60, 103.59),
            size        = vector3(1, 1, 1),
            color       = { r = 255, g = 255, b = 255, a = 255 },
            markerLabel = '💼'
        },
        job = {
            enabled = true,
            label = "Dövme Dükkanı",
            employeeMarkerLabel = "🖌",
            customerAnim = {
                sitting = {
                    pos = vector4(324.8154, 179.7087, 103.5865, 126.2803),
                    animName = 'ig_5_p3_base',
                    animDict = 'timetable@ron@ig_5_p3',
                },
            },
            employeeAnim = {
                idle = {
                    pos = vector3(323.5870, 179.4868, 103.5865),
                    heading = 276.2199,
                    animName = '_idle_a',
                    animDict = 'random@shop_tattoo',
                },
                tattoo = {
                    animName = 'machinic_loop_mechandplayer',
                    animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                },
            },
            grades = {
                {
                    name = 'novice',
                },
                {
                    name = 'artist',
                },
                {
                    name = 'boss',
                    isBoss = true,
                },
            },
        },
    },
    dovmeci4 = {
        enabled = true,
        businessName = "dovmeci4",
        owner = "0cba7977a17d6a08c31db9d5db0cf6554cf1e8cd",
        bossMenu = {
            pos         = vector3(1865.1566, 3747.1926, 33.0318),
            size        = vector3(1, 1, 1),
            color       = { r = 255, g = 255, b = 255, a = 255 },
            markerLabel = '💼'
        },
        job = {
            enabled = true,
            label = "Dövme Dükkanı",
            employeeMarkerLabel = "🖌",
            customerAnim = {
                sitting = {
                    pos = vector4(1864.0122, 3746.7573, 33.0326, 4.5507),
                    animName = 'ig_5_p3_base',
                    animDict = 'timetable@ron@ig_5_p3',
                },
            },
            employeeAnim = {
                idle = {
                    pos = vector3(1865.1566, 3747.1926, 33.0318),
                    animName = '_idle_a',
                    animDict = 'random@shop_tattoo',
                },
                tattoo = {
                    animName = 'machinic_loop_mechandplayer',
                    animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                },
            },
            grades = {
                {
                    name = 'novice',
                },
                {
                    name = 'artist',
                },
                {
                    name = 'boss',
                    isBoss = true,
                },
            },
        },
    },
    dovmeci5 = {
        enabled = true,
        businessName = "dovmeci5",
        owner = "0cba7977a17d6a08c31db9d5db0cf6554cf1e8cd",
        bossMenu = {
            pos         = vector3(-3171.3726, 1076.0308, 20.8292),
            size        = vector3(1, 1, 1),
            color       = { r = 255, g = 255, b = 255, a = 255 },
            markerLabel = '💼'
        },
        job = {
            enabled = true,
            label = "Dövme Dükkanı",
            employeeMarkerLabel = "🖌",
            customerAnim = {
                sitting = {
                    pos = vec4(-3170.2290, 1076.3744, 20.8292, 197.2347),
                    animName = 'ig_5_p3_base',
                    animDict = 'timetable@ron@ig_5_p3',
                },
            },
            employeeAnim = {
                idle = {
                    pos = vector3(-3171.3726, 1076.0308, 20.8292),
                    animName = '_idle_a',
                    animDict = 'random@shop_tattoo',
                },
                tattoo = {
                    animName = 'machinic_loop_mechandplayer',
                    animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                },
            },
            grades = {
                {
                    name = 'novice',
                },
                {
                    name = 'artist',
                },
                {
                    name = 'boss',
                    isBoss = true,
                },
            },
        },
    },
    dovmeci6 = {
        enabled = true,
        businessName = "dovmeci6",
        owner = "0cba7977a17d6a08c31db9d5db0cf6554cf1e8cd",
        bossMenu = {
            pos         = vector3(1324.0079, -1653.1140, 52.2756),
            size        = vector3(1, 1, 1),
            color       = { r = 255, g = 255, b = 255, a = 255 },
            markerLabel = '💼'
        },
        job = {
            enabled = true,
            label = "Dövme Dükkanı",
            employeeMarkerLabel = "🖌",
            customerAnim = {
                sitting = {
                    pos = vec4(1322.6858, -1653.0496, 52.2753, 349.3860),
                    animName = 'ig_5_p3_base',
                    animDict = 'timetable@ron@ig_5_p3',
                },
            },
            employeeAnim = {
                idle = {
                    pos = vector3(1324.0079, -1653.1140, 52.2756),
                    animName = '_idle_a',
                    animDict = 'random@shop_tattoo',
                },
                tattoo = {
                    animName = 'machinic_loop_mechandplayer',
                    animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                },
            },
            grades = {
                {
                    name = 'novice',
                },
                {
                    name = 'artist',
                },
                {
                    name = 'boss',
                    isBoss = true,
                },
            },
        },
    },
    dovmeci6_chair2 = {
        enabled = true,
        businessName = "dovmeci6",
        owner = "0cba7977a17d6a08c31db9d5db0cf6554cf1e8cd",
        bossMenu = {
            pos         = vector3(1324.0079, -1653.1140, 52.2756),
            size        = vector3(1, 1, 1),
            color       = { r = 255, g = 255, b = 255, a = 255 },
            markerLabel = '💼'
        },
        job = {
            enabled = true,
            label = "Dövme Dükkanı",
            employeeMarkerLabel = "🖌",
            customerAnim = {
                sitting = {
                    pos = vector4(1320.7954, -1653.8610, 52.2752, 353.0390),
                    animName = 'ig_5_p3_base',
                    animDict = 'timetable@ron@ig_5_p3',
                },
            },
            employeeAnim = {
                idle = {
                    pos = vector3(1321.0717, -1652.9398, 52.2750),
                    heading = 179.3190,
                    animName = '_idle_a',
                    animDict = 'random@shop_tattoo',
                },
                tattoo = {
                    animName = 'machinic_loop_mechandplayer',
                    animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                },
            },
            grades = {
                {
                    name = 'novice',
                },
                {
                    name = 'artist',
                },
                {
                    name = 'boss',
                    isBoss = true,
                },
            },
        },
    },
    dovmeci7 = {
        enabled = true,
        businessName = "dovmeci7",
        owner = "0cba7977a17d6a08c31db9d5db0cf6554cf1e8cd",
        bossMenu = {
            pos         = vector3(2511.9624, 4091.0938, 35.5852),
            size        = vector3(1, 1, 1),
            color       = { r = 255, g = 255, b = 255, a = 255 },
            markerLabel = '💼'
        },
        job = {
            enabled = true,
            label = "Dövme Dükkanı",
            employeeMarkerLabel = "🖌",
            customerAnim = {
                sitting = {
                    pos = vec4(2512.2559, 4090.0332, 35.5857, 54.1360),
                    animName = 'ig_5_p3_base',
                    animDict = 'timetable@ron@ig_5_p3',
                },
            },
            employeeAnim = {
                idle = {
                    pos = vector3(2511.9624, 4091.0938, 35.5852),
                    animName = '_idle_a',
                    animDict = 'random@shop_tattoo',
                },
                tattoo = {
                    animName = 'machinic_loop_mechandplayer',
                    animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                },
            },
            grades = {
                {
                    name = 'novice',
                },
                {
                    name = 'artist',
                },
                {
                    name = 'boss',
                    isBoss = true,
                },
            },
        },
    },    
}
