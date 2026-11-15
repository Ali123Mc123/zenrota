Config = Config or {}

Config.Locations = {
    ['SASP'] = {
        settings = {
            label = 'SASP',
            welcomeLabel = "Mekanik",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = " SASP Mekanik",
        },
        restrictions = {
            job = { 'police', 'sasp', 'bcso', 'sapr', 'pbsd', 'cppd' },
            allowedClasses = { 18 },
        },
        zones = {
            { coords = vector3(-3083.0781, 1445.0739, 20.4930), length = 8.0, width = 4.0, heading = 232.8930, minZ = 18.0, maxZ = 22.0 },
            { coords = vector3(-3078.4294, 1452.1393, 20.4454), length = 8.0, width = 4.0, heading = 230.5106, minZ = 18.0, maxZ = 22.0 },
        }
    },

    ['CPPD'] = {
        settings = {
            label = 'CPPD',
            welcomeLabel = "Mekanik",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = " CPPD Mekanik",
        },
        restrictions = {
            job = { 'police', 'sasp', 'bcso', 'sapr', 'pbsd', 'cppd' },
            allowedClasses = { 18 },
        },
        zones = {
            { coords = vector3(4366.7905, -4275.6255, 3.1782), length = 8.0, width = 4.0, heading = 183.2644, minZ = 1.5, maxZ = 6.0 },
        }
    },

    ['SASPAIR'] = {
        settings = {
            label = 'SASP',
            welcomeLabel = "AIR Mekanik",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = " SASP AIR Mekanik",
        },
        restrictions = {
            job = { 'police', 'sasp', 'bcso', 'sapr', 'pbsd', 'cppd' },
            allowedClasses = { 15 },
        },
        zones = {
            { coords = vector3(-3078.5149, 1445.7504, 24.6764), length = 10.0, width = 8.0, heading = 138.8621, minZ = 24.0, maxZ = 26.0 },
        }
    },

    ['SAPR'] = {
        settings = {
            label = 'Park Ranger',
            welcomeLabel = "Mekanik Menü!",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = "SAPR Mekanik",
        },
        restrictions = {
            job = { 'police', 'sasp', 'bcso', 'sapr', 'pbsd', 'cppd' },
            allowedClasses = { 18 },
        },
        zones = {
            -- old: vector3(-804.95, 5407.62, 33.66), vector3(-800.67, 5407.46, 33.54)
            -- prev Park Ranger: vector3(374.2018, 796.4182, 187.2872), vector3(374.7686, 797.0882, 187.3078)
            { coords = vector3(61.1869, -353.9290, 38.7455), length = 8.0, width = 4.0, heading = 90.0,  minZ = 37.0,  maxZ = 40.0 }, -- Alta PD garajı
            { coords = vector3(64.3029, -345.4052, 38.7449), length = 8.0, width = 4.0, heading = 90.0,  minZ = 37.0,  maxZ = 40.0 }, -- Alta PD garajı
            { coords = vector3(90.5537, -360.2357, 52.6779), length = 8.0, width = 4.0, heading = 180.0, minZ = 51.20, maxZ = 53.0 }, -- Alta PD üst kat
        }
    },

    ['SAPRAIR'] = {
        settings = {
            label = 'SAPR',
            welcomeLabel = "AIR Mekanik",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = " SAPR AIR Mekanik",
        },
        restrictions = {
            job = { 'police', 'sasp', 'bcso', 'sapr', 'pbsd', 'cppd' },
            allowedClasses = { 15 },
        },
        zones = {
            -- old: vector3(-790.4694, 5412.1162, 34.1659), heading 78.4603; prev: vector3(396.4262, 819.5206, 193.1280), heading 148.6640
            -- prev Park Ranger: vector3(408.3664, 762.7616, 188.4680), heading 52.2330
            { coords = vector3(66.1191, -331.8166, 56.8637), length = 10.0, width = 8.0, heading = 260.7349, minZ = 55.0, maxZ = 58.0 }, -- Alta PD çatı
        }
    },

    ['MRPD'] = {
        settings = {
            label = 'MRPD',
            welcomeLabel = "Mekanik Menü!",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = "MRPD Mekanik",
        },
        restrictions = {
            job = { 'police', 'sasp', 'bcso', 'sapr', 'pbsd', 'cppd' },
            allowedClasses = { 18 },
        },
        zones = {
            -- Alta PD (eski):
            -- { coords = vector3(61.1869, -353.9290, 38.7455), length = 8.0, width = 4.0, heading = 90.0,  minZ = 37.0,  maxZ = 40.0 },
            -- { coords = vector3(64.3029, -345.4052, 38.7449), length = 8.0, width = 4.0, heading = 90.0,  minZ = 37.0,  maxZ = 40.0 },
            -- { coords = vector3(90.5537, -360.2357, 52.6779), length = 8.0, width = 4.0, heading = 180.0, minZ = 51.20, maxZ = 53.0 },
            { coords = vector3(451.0494, -974.9964, 25.7000), length = 8.0, width = 4.0, heading = 84.19, minZ = 24.7, maxZ = 27.7 }, -- MRPD bodrum, mekanik 1
            { coords = vector3(433.1203, -976.0322, 25.7000), length = 8.0, width = 4.0, heading = 89.33, minZ = 24.7, maxZ = 27.7 }, -- MRPD bodrum, mekanik 2
        }
    },

    ['MRPDAIR'] = {
        settings = {
            label = 'MRPD',
            welcomeLabel = "AIR Mekanik",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = " MRPD AIR Mekanik",
        },
        restrictions = {
            job = { 'police', 'sasp', 'bcso', 'sapr', 'pbsd', 'cppd' },
            allowedClasses = { 15 },
        },
        zones = {
            -- { coords = vector3(66.1191, -331.8166, 56.8637), length = 10.0, width = 8.0, heading = 260.7349, minZ = 55.0, maxZ = 58.0 }, -- Alta PD (eski)
            { coords = vector3(481.6388, -982.5445, 41.0061), length = 10.0, width = 8.0, heading = 352.0159, minZ = 39.5, maxZ = 44.0 }, -- MRPD helipedi
        }
    },

    ['BCSO'] = {
        settings = {
            label = 'BCSO',
            welcomeLabel = "Mekanik",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = "bcso Mekanik",
        },
        restrictions = {
            job = { 'police', 'sasp', 'bcso', 'sapr', 'pbsd', 'cppd' },
            allowedClasses = { 18 },
        },
        zones = {
            { coords = vector3(1855.94, 3708.95, 33.36), length = 8.0,  width = 4.0, heading = 28.84, minZ = 28.84, maxZ = 34.0 },
            { coords = vector3(1830.16, 3677.96, 42.98), length = 10.0, width = 8.0, heading = 41.67, minZ = 43.84, maxZ = 45.0 },
        }
    },

    ['BCSOAIR'] = {
        settings = {
            label = 'BCSO',
            welcomeLabel = "AIR Mekanik",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = " BCSO AIR Mekanik",
        },
        restrictions = {
            job = { 'police', 'sasp', 'bcso', 'sapr', 'pbsd', 'cppd' },
            allowedClasses = { 15 },
        },
        zones = {
            { coords = vector3(1831.2015, 3674.0073, 42.9036), length = 10.0, width = 8.0, heading = 27.5886, minZ = 42.0, maxZ = 45.0 },
        }
    },
    
    ['PBSD'] = {
        settings = {
            label = 'PBSD',
            welcomeLabel = "Mekanik",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = "PBSD Mekanik",
        },
        restrictions = {
            job = { 'police', 'sasp', 'bcso', 'sapr', 'pbsd', 'cppd' },
            allowedClasses = { 18 },
        },
        zones = {
            { coords = vector3(2805.0664, 4789.6699, 46.3684), length = 8.0, width = 4.0, heading = 12.4339, minZ = 45.0, maxZ = 47.0 },
            { coords = vector3(2797.0547, 4787.6157, 46.3681), length = 8.0, width = 4.0, heading = 9.9876, minZ = 45.0, maxZ = 47.0 },
        }
    },

    ['DP'] = {
        settings = {
            label = 'DP',
            welcomeLabel = "Mekanik",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = "DP Mekanik",
        },
        restrictions = {
            job = { 'police', 'sasp', 'bcso', 'sapr', 'pbsd', 'cppd' },
            allowedClasses = { 18 },
        },
        zones = {
            { coords = vector3(-482.0946, 6024.0161, 31.3404), length = 8.0, width = 4.0, heading = 42.2505, minZ = 30.0, maxZ = 32.0 },
            { coords = vector3(-475.4540, 6031.3110, 31.3404), length = 8.0, width = 4.0, heading = 46.8297, minZ = 30.0, maxZ = 32.0 },
        }
    },

    ['PBSDAIR'] = {
        settings = {
            label = 'PBSD',
            welcomeLabel = "Mekanik",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = "PBSD Heli Mekanik",
        },
        restrictions = {
            job = { 'police', 'sasp', 'bcso', 'sapr', 'pbsd', 'cppd' },
            allowedClasses = { 15 },
        },
        zones = {
            { coords = vector3(2800.1240, 4789.8047, 51.3697), length = 10.0, width = 8.0, heading = 281.1480, minZ = 50.0, maxZ = 52.0 },
        }
    },

    ['DPAIR'] = {
        settings = {
            label = 'DP',
            welcomeLabel = "Mekanik",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = "DP Heli Mekanik",
        },
        restrictions = {
            job = { 'police', 'sasp', 'bcso', 'sapr', 'pbsd', 'cppd' },
            allowedClasses = { 15 },
        },
        zones = {
            { coords = vector3(-483.0426, 5994.5186, 31.3365), length = 10.0, width = 8.0, heading = 315.8887, minZ = 30.3365, maxZ = 31.3365 },
        }
    },

    ['DOJ'] = {
        settings = {
            label = 'DOJ',
            welcomeLabel = "Mekanik",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = "DOJ Mekanik",
        },
        restrictions = {
            job = { 'doj' },
            allowedClasses = { 18 },
        },
        zones = {
            { coords = vector3(-533.1240, -270.8853, 34.6716), length = 12.0, width = 12.0, heading = 291.3300, minZ = 33.0, maxZ = 36.0 },
        }
    },

    ['EMSAIR'] = {
        settings = {
            label = 'EMS Air Mekanik',
            welcomeLabel = "Mekanik",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = "EMS Mekanik",
        },
        restrictions = {
            job = { 'ambulance' },
            allowedClasses = { 15 },
        },
        zones = {
            -- { coords = vector3(633.4525, 2773.8135, 56.6302), length = 10.0, width = 8.0, heading = 268.3310, minZ = 55.84, maxZ = 57.0 }, -- old (town hospital)
            { coords = vector3(1205.4556, -1547.5566, 39.4018), length = 10.0, width = 8.0, heading = 337.4887, minZ = 38.4, maxZ = 42.4 },
        }
    },

    ['EMS'] = {
        settings = {
            label = 'EMS',
            welcomeLabel = "Mekanik",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = "EMS Mekanik",
        },
        restrictions = {
            job = { 'ambulance' },
            allowedClasses = { 18 },
        },
        zones = {
            { coords = vector3(1122.09, -1612.46, 34.69), length = 10.0, width = 10.0, heading = 34.84, minZ = 34.0, maxZ = 36.0 },
        }
    },

    ['EMS KASABA'] = {
        settings = {
            label = 'EMS KASABA',
            welcomeLabel = "Mekanik",
            enabled = true,
        },
        categories = {
            mods = true,
            repair = true,
            armor = false,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            turbo = true,
            cosmetics = true,
        },
        drawtextui = {
            text = "EMS Mekanik",
        },
        restrictions = {
            job = { 'ambulance' },
            allowedClasses = { 18 },
        },
        zones = {
            { coords = vector3(652.7194, 2730.3557, 41.5595), length = 10.0, width = 10.0, heading = 4.3146, minZ = 40.5, maxZ = 42.5 },
        }
    },

    ['BOAT'] = {
        settings = {
            label = 'Tekne Mekanik',
            welcomeLabel = "Tekne Mekanik Menü!",
            enabled = true,
        },
        categories = {
            repair = true,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            cosmetics = true,
        },
        drawtextui = {
            text = "Tekne Mekanik",
        },
        restrictions = {
            job = false,
            allowedClasses = { 14 },
        },
        zones = {
            { coords = vector3(-738.49, -1340.43, 0.11), length = 8.0, width = 6.0, heading = 48.62, minZ = -2.0, maxZ = 4.0 },
        }
    },
    ['BIGBOAT'] = {
        settings = {
            label = 'Buyuk Tekne Mekanik',
            welcomeLabel = "Buyuk Tekne Mekanik Menü!",
            enabled = true,
        },
        categories = {
            repair = true,
            respray = true,
            liveries = true,
            wheels = true,
            extras = true,
            cosmetics = true,
        },
        drawtextui = {
            text = "Tekne Mekanik 2",
        },
        restrictions = {
            job = false,
            allowedClasses = { 14 },
        },
        zones = {
            { coords = vector3(-3441.17, 965.91, -0.71), length = 10.0, width = 10.0, heading = 359.99, minZ = -2.0, maxZ = 4.0 },
        }
    },
}
