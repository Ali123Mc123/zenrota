Config = {}

Config.Framework = "auto"                  -- qb, qbold, esx, esxold, custom, auto

Config.DefaultStationPrice = 10000         -- Benzin istasyonları için varsayılan fiyat
Config.MaxGasPrice = 15                    -- Benzin istasyonlarının belirleyebileceği maksimum fiyat
Config.DefaultGasPrice = 8.0               -- Benzin istasyonları için varsayılan fiyat (sahipsiz istasyonlar)
Config.DefaultFuelInventoryCapacity = 1000 -- Benzin istasyonları için varsayılan yakıt kapasitesi
Config.ShowNearestGasStationOnly = false
Config.TruckModel = "phantom"              -- Truck model for gas stations
Config.TrailerModel = "tanker"             -- Trailer model for gas stations
Config.FuelTickTime = 750                  -- Time in milliseconds to add fuel 1 by 1
Config.FuelDecor = "_FUEL_LEVEL"
Config.UseTarget = true                    -- Only for ox-target and qb-target
Config.ManagementPed = false               -- false: istasyon yonetimi can9work-auction'in istasyon NPC'sinden acilir, yonetim pedi dogmaz

Config.ReFuelPrices = {
    ["small"] = {
        import = 100,
        export = 1000,
        fuel = 100,
    },
    ["medium"] = {
        import = 500,
        export = 5000,
        fuel = 500,
    },
    ["large"] = {
        import = 1000,
        export = 10000,
        fuel = 1000,
    }
}

Config.UpgradePrice = {
    ["Inventory"] = {
        ["1"] = {
            value = "250",
            price = 2000,
        },
        ["2"] = {
            value = "500",
            price = 2500,
        },
        ["3"] = {
            value = "1000",
            price = 3000,
        },
        ["4"] = {
            value = "1500",
            price = 3500,
        },
        ["5"] = {
            value = "2000",
            price = 4000,
        }
    },
    ["TruckCapacity"] = {
        ["1"] = {
            value = "10",
            price = 4000,
        },
        ["2"] = {
            value = "20",
            price = 4500,
        },
        ["3"] = {
            value = "30",
            price = 5000,
        },
        ["4"] = {
            value = "40",
            price = 5500,
        },
        ["5"] = {
            value = "50",
            price = 6000,
        }
    },
    ["Relationship"] = {
        ["1"] = {
            value = "5",
            price = 6000,
        },
        ["2"] = {
            value = "10",
            price = 6500,
        },
        ["3"] = {
            value = "20",
            price = 7000,
        },
        ["4"] = {
            value = "30",
            price = 7500,
        },
        ["5"] = {
            value = "40",
            price = 8000,
        }
    }
}

Config.BlipConfig = {
    size = 0.7,
    color = 4,
    sprite = 361,
    text = "Benzin İstasyonu",
    enabled = false
}

Config.PumpModels = {
    [-2007231801] = true,
    [1339433404] = true,
    [1694452750] = true,
    [1933174915] = true,
    [-462817101] = true,
    [-469694731] = true,
    [-164877493] = true
}

Config.PumpModelsName = {
    "prop_gas_pump_1d",
    "prop_gas_pump_1a",
    "prop_gas_pump_1b",
    "prop_gas_pump_1c",
    "prop_vintage_pump",
    "prop_gas_pump_old2",
    "prop_gas_pump_old3"
}

-- Haritaya eklenecek özel benzin istasyonu propları
Config.CustomPumps = {
    -- Eski okul adasındaki iki pompa kaldırıldı (2026-11-11): ada sunucudan kalktı.
    {
        model = "prop_gas_pump_1d",
        coords = vector4(4726.7104, -4231.0752, 3.3717, 358.0818), -- Cayo Porto
        blip = {
            enabled = true,
            sprite = 361,
            color = 4,
            scale = 0.7,
            text = "Benzin İstasyonu"
        }
    }
}

Config.DeliveryLocations = {
    vector3(-758.14, 5540.96, 33.49),
    vector3(-3046.19, 143.27, 11.6),
    vector3(-1153.01, 2672.99, 18.1),
    vector3(622.67, 110.27, 92.59),
    vector3(-574.62, -1147.27, 22.18),
    vector3(376.31, 2638.97, 44.5),
    vector3(1738.32, 3283.89, 41.13),
    vector3(1419.98, 3618.63, 34.91),
    vector3(1452.67, 6552.02, 14.89),
    vector3(3472.4, 3681.97, 33.79),
    vector3(2485.73, 4116.13, 38.07),
    vector3(65.02, 6345.89, 31.22),
    vector3(-303.28, 6118.17, 31.5),
    vector3(-63.41, -2015.25, 18.02),
    vector3(-46.35, -2112.38, 16.71),
    vector3(-746.6, -1496.67, 5.01),
    vector3(369.54, 272.07, 103.11),
    vector3(907.61, -44.12, 78.77),
    vector3(-1517.31, -428.29, 35.45),
    vector3(235.04, -1520.18, 29.15),
    vector3(34.8, -1730.13, 29.31),
    vector3(350.4, -2466.9, 6.4),
    vector3(1213.97, -1229.01, 35.35),
    vector3(1395.7, -2061.38, 52.0),
    vector3(729.09, -2023.63, 29.31),
    vector3(840.72, -1952.59, 28.85),
    vector3(551.76, -1840.26, 25.34),
    vector3(723.78, -1372.08, 26.29),
    vector3(-339.92, -1284.25, 31.32),
    vector3(1137.23, -1285.05, 34.6),
    vector3(466.93, -1231.55, 29.95),
    vector3(442.28, -584.28, 28.5),
    vector3(1560.52, 888.69, 77.46),
    vector3(2561.78, 426.67, 108.46),
    vector3(2665.4, 1700.63, 24.49),
    vector3(1120.1, 2652.5, 38.0),
    vector3(2004.23, 3071.87, 47.06),
    vector3(2038.78, 3175.7, 45.09),
    vector3(1635.54, 3562.84, 35.23),
    vector3(2744.55, 3412.43, 56.57),
    vector3(1972.17, 3839.16, 32.0),
    vector3(1980.59, 3754.65, 32.18),
    vector3(1716.0, 4706.41, 42.69),
    vector3(1691.36, 4918.42, 42.08),
    vector3(1971.07, 5165.12, 47.64)
}

Config.NoFuelClasses = { -- Bu class'taki araçlar yakıt tüketmez (HUD gösterir ama harcamaz)
    [14] = true, -- Boats / Deniz araçları
}

Config.NoFuel = { -- Yakıt kullanmasını istemediğiniz araçları buraya ekleyin.
    "bmx",
    "iak_wheelchair"
}

Config.Classes = { -- Class multipliers. If you want SUVs to use less fuel, you can change it to anything under 1.0, and vise versa.
    [0] = 0.6,     -- Compacts
    [1] = 0.6,     -- Sedans
    [2] = 0.6,     -- SUVs
    [3] = 0.6,     -- Coupes
    [4] = 0.6,     -- Muscle
    [5] = 0.6,     -- Sports Classics
    [6] = 0.6,     -- Sports
    [7] = 0.6,     -- Super
    [8] = 0.6,     -- Motorcycles
    [9] = 0.6,     -- Off-road
    [10] = 0.6,    -- Industrial
    [11] = 0.6,    -- Utility
    [12] = 0.6,    -- Vans
    [13] = 0.0,    -- Cycles
    [14] = 0.0,    -- Boats (Unlimited fuel)
    [15] = 0.6,    -- Helicopters
    [16] = 0.6,    -- Planes
    [17] = 0.6,    -- Service
    [18] = 0.6,    -- Emergency
    [19] = 0.6,    -- Military
    [20] = 0.6,    -- Commercial
    [21] = 0.6,    -- Trains
}

Config.FuelUsage = { -- Sol kısım yüzde RPM'i gösterir; sağ kısım ise her saniye tanktan çıkarılacak yakıt miktarıdır (10'a bölünmüş).
    [1.0] = 0.65,
    [0.9] = 0.55,
    [0.8] = 0.45,
    [0.7] = 0.40,
    [0.6] = 0.35,
    [0.5] = 0.25,
    [0.4] = 0.15,
    [0.3] = 0.10,
    [0.2] = 0.05,
    [0.1] = 0.05,
    [0.0] = 0.0,
}

Config.GasStations = {
    [1] = {
        zones = {
            vector3(288.78, -1283.96, 26.0),
            vector3(240.85, -1282.82, 26.0),
            vector3(244.86, -1239.22, 26.0),
            vector3(288.42, -1239.36, 26.0)
        },
        thickness = 10,
        price = 900000,
        management = vector4(288.4500, -1268.1497, 29.4407, 93.4944),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(288.5574, -1264.4276, 29.4407, 82.8625),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(273.3329, -1245.9517, 29.2370, 87.1950),
        trailerCoord = vector4(294.9744, -1246.5293, 29.3542, 90.9719)
    },
    [2] = {
        zones = {
            vector3(801.52, -1045.45, 26.0),
            vector3(801.52, -1018.18, 26.0),
            vector3(834.09, -1018.18, 26.0),
            vector3(834.09, -1045.45, 26.0)
        },
        thickness = 15,
        price = 750000,
        management = vector4(818.2385, -1040.6113, 26.7508, 14.2469),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(821.9138, -1040.6526, 26.7508, 2.5997),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(830.4810, -1034.1969, 26.7804, 358.5965),
        trailerCoord = vector4(826.4495, -1043.1300, 27.0581, 2.0524)
    },
    [3] = {
        zones = {
            vector3(1187.88, -1415.91, 35.0),
            vector3(1187.88, -1374.24, 35.0),
            vector3(1221.21, -1374.24, 35.0),
            vector3(1221.21, -1415.91, 35.0)
        },
        thickness = 15,
        price = 650000,
        management = vector4(1211.3257, -1389.2129, 35.3769, 178.9408),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(1207.6866, -1389.8146, 35.3769, 181.8591),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(1198.7385, -1413.8983, 34.9262, 180.2320),
        trailerCoord = vector4(1198.9894, -1394.3572, 34.9956, 176.4576)
    },
    -- [4] = {
    --     zones = {
    --         vector3(1145.83, -315.91, 69.0),
    --         vector3(1148.86, -353.03, 69.0),
    --         vector3(1203.03, -360.23, 69.0),
    --         vector3(1199.24, -304.17, 69.0)
    --     },
    --     thickness = 15,
    --     price = 750000,
    --     management = vector4(1167.1351, -322.2129, 69.2706, 285.0890),
    --     managementPed = "a_m_m_genfat_02",
    --     jobList = vector4(1167.5330, -324.9409, 69.2592, 280.7859),
    --     jobListPed = "a_m_m_prolhost_01",
    --     truckCoord = vector4(1194.7905, -312.1997, 68.7857, 279.3985),
    --     trailerCoord = vector4(1180.0952, -314.9736, 69.2478, 279.6097)
    -- },
    [4] = {
        zones = {
            vector3(622.73, 307.58, 103.0),
            vector3(672.73, 268.18, 103.0),
            vector3(650.00, 233.33, 103.0),
            vector3(598.48, 259.09, 103.0)
        },
        thickness = 15,
        price = 900000,
        management = vector4(641.6697, 260.9101, 103.2961, 60.9836),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(643.4546, 264.2095, 103.2956, 57.1015),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(639.6699, 284.9062, 103.2715, 61.2695),
        trailerCoord = vector4(652.1791, 277.9498, 103.2952, 61.4102)
    },
    [5] = {
        zones = {
            vector3(2593.45, 339.88, 108.0),
            vector3(2540.65, 339.88, 108.0),
            vector3(2545.58, 443.75, 108.0),
            vector3(2596.05, 444.98, 108.0)
        },
        thickness = 15,
        price = 550000,
        management = vector4(2559.3850, 373.7945, 108.6212, 277.0486),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(2559.5862, 369.9875, 108.6212, 274.8446),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(2559.9050, 426.2695, 108.5234, 315.7792),
        trailerCoord = vector4(2549.7957, 415.8957, 108.5270, 315.7336)
    },
    [6] = {
        zones = {
            vector3(176.89, -1538.26, 29.26),
            vector3(151.52, -1560.98, 29.26),
            vector3(168.56, -1577.65, 29.26),
            vector3(196.97, -1563.64, 29.26)
        },
        thickness = 10,
        price = 700000,
        management = vector4(167.49, -1553.88, 29.26, 229.8755),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(164.4, -1557.22, 29.26, 229.8755),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(191.9736, -1561.2590, 29.3314, 215.9296),
        trailerCoord = vector4(181.1608, -1546.5983, 29.2538, 217.2834)
    },
    [7] = {
        zones = {
            vector3(-359.47, -1496.97, 30.0),
            vector3(-359.47, -1454.17, 30.0),
            vector3(-297.73, -1454.17, 30.0),
            vector3(-297.73, -1496.97, 30.0)
        },
        thickness = 15,
        price = 800000,
        management = vector4(-342.1403, -1475.0756, 30.7496, 272.9150),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(-342.1319, -1478.2798, 30.7513, 267.1089),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(-321.4901, -1494.9099, 30.3545, 270.1808),
        trailerCoord = vector4(-334.5273, -1494.9843, 30.4035, 270.1864)
    },
    [8] = {
        zones = {
            vector3(1772.94, 3294.41, 41.0),
            vector3(1747.77, 3335.58, 41.0),
            vector3(1775.68, 3350.92, 41.0),
            vector3(1804.11, 3306.80, 41.0)
        },
        thickness = 15,
        price = 450000,
        management = vector4(1776.2926, 3327.3689, 41.4333, 296.1235),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(1777.2233, 3325.7615, 41.4333, 300.0064),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(1787.9413, 3315.4163, 41.5993, 305.1619),
        trailerCoord = vector4(1776.5878, 3306.7400, 41.3199, 308.5014)
    },
    [9] = {
        zones = {
            vector3(19.70, 2781.82, 57.0),
            vector3(48.48, 2807.58, 57.0),
            vector3(86.36, 2778.79, 57.0),
            vector3(59.09, 2754.55, 57.0)
        },
        thickness = 15,
        price = 400000,
        management = vector4(46.5614, 2789.3489, 57.8782, 148.1412),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(44.6484, 2790.1345, 57.8782, 150.8788),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(36.5279, 2790.5701, 57.9467, 149.2087),
        trailerCoord = vector4(45.6654, 2804.9194, 57.9518, 145.1168)
    },
    [10] = {
        zones = {
            vector3(240.60, 2609.96, 44.0),
            vector3(247.65, 2572.19, 44.0),
            vector3(278.57, 2581.32, 44.0),
            vector3(276.15, 2622.38, 44.0)
        },
        thickness = 15,
        price = 400000,
        management = vector4(265.8512, 2598.2112, 44.8451, 18.6395),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(267.9684, 2598.8452, 44.8121, 12.3598),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(272.6851, 2607.6941, 44.7634, 8.5719),
        trailerCoord = vector4(274.4703, 2594.2395, 44.6123, 7.0301)
    },
    [11] = {
        zones = {
            vector3(1019.72, 2681.55, 39.0),
            vector3(1018.05, 2648.79, 39.0),
            vector3(1067.89, 2648.42, 39.0),
            vector3(1067.64, 2678.24, 39.0)
        },
        thickness = 15,
        price = 500000,
        management = vector4(1039.3646, 2664.0688, 39.5513, 5.0118),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(1041.6196, 2664.1501, 39.5511, 2.1037),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(1056.8258, 2670.8257, 39.5655, 358.9032),
        trailerCoord = vector4(1056.6450, 2658.2625, 39.6244, 358.1627)
    },
    [12] = {
        zones = {
            vector3(1225.44, 2664.93, 37.0),
            vector3(1206.24, 2626.10, 37.0),
            vector3(1191.26, 2626.61, 37.0),
            vector3(1194.56, 2674.54, 37.0)
        },
        thickness = 15,
        price = 500000,
        management = vector4(1200.7109, 2655.6321, 37.8515, 313.6816),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(1202.1726, 2654.2312, 37.8515, 320.2604),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(1212.1686, 2650.6587, 37.8975, 337.1649),
        trailerCoord = vector4(1201.8685, 2636.4009, 37.8850, 320.7616)
    },
    [13] = {
        zones = {
            vector3(2515.15, 2628.79, 38.0),
            vector3(2553.79, 2636.36, 38.0),
            vector3(2567.42, 2574.24, 38.0),
            vector3(2514.39, 2565.91, 38.0)
        },
        thickness = 15,
        price = 400000,
        management = vector4(2545.3105, 2591.9802, 37.9574, 110.0982),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(2544.2473, 2593.4851, 37.9449, 114.7184),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(2534.4639, 2592.3518, 38.0144, 359.5963),
        trailerCoord = vector4(2534.7334, 2579.1575, 38.0122, 354.6547)
    },
    [14] = {
        zones = {
            vector3(2628.03, 3320.45, 55.0),
            vector3(2701.52, 3271.97, 55.0),
            vector3(2659.85, 3218.94, 55.0),
            vector3(2585.61, 3263.64, 55.0)
        },
        thickness = 15,
        price = 650000,
        management = vector4(2673.6870, 3266.9431, 55.2405, 236.5547),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(2671.8445, 3263.4666, 55.2405, 244.5151),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(2667.3455, 3255.9773, 55.3088, 238.4953),
        trailerCoord = vector4(2657.6379, 3261.8711, 55.3097, 236.6954)
    },
    [15] = {
        zones = {
            vector3(1971.97, 3773.86, 32.0),
            vector3(1992.05, 3740.15, 32.0),
            vector3(2020.83, 3757.20, 32.0),
            vector3(2000.76, 3792.05, 32.0)
        },
        thickness = 15,
        price = 550000,
        management = vector4(2002.8330, 3780.6204, 32.1808, 213.9731),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(2001.2297, 3779.7749, 32.1808, 212.7619),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(1990.3682, 3769.4272, 32.2494, 219.3473),
        trailerCoord = vector4(1982.2356, 3782.3833, 32.2480, 207.7901)
    },
    [16] = {
        zones = {
            vector3(1701.41, 4952.69, 42.0),
            vector3(1727.55, 4926.94, 42.0),
            vector3(1700.72, 4900.10, 42.0),
            vector3(1670.97, 4924.44, 42.0)
        },
        thickness = 15,
        price = 450000,
        management = vector4(1702.3004, 4934.6367, 42.0782, 57.3447),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(1703.8304, 4937.1133, 42.0782, 55.9008),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(1687.3342, 4920.9702, 42.1477, 52.8277),
        trailerCoord = vector4(1699.1719, 4912.4185, 42.1457, 55.0271)
    },
    [17] = {
        zones = {
            vector3(1685.2339, 6436.6016, 31.0),
            vector3(1721.9838, 6418.7954, 31.0),
            vector3(1702.65, 6387.12, 31.0),
            vector3(1663.64, 6405.68, 31.0)
        },
        thickness = 15,
        price = 350000,
        management = vector4(1706.0942, 6425.7666, 32.7712, 155.7259),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(1704.2395, 6426.4326, 32.7686, 153.8350),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(1686.1896, 6419.8394, 32.4002, 171.1805),
        trailerCoord = vector4(1688.2095, 6432.4185, 32.5359, 166.1833)
    },
    [18] = {
        zones = {
            vector3(119.70, 6631.82, 31.0),
            vector3(184.09, 6552.27, 31.0),
            vector3(218.94, 6568.18, 31.0),
            vector3(158.33, 6651.52, 31.0)
        },
        thickness = 15,
        price = 650000,
        management = vector4(154.5516, 6643.5791, 31.5988, 139.3038),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(153.1226, 6645.4341, 31.5774, 138.3498),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(148.7416, 6637.2651, 31.6798, 223.5210),
        trailerCoord = vector4(138.4116, 6649.3086, 31.6802, 224.2270)
    },
    [19] = {
        zones = {
            vector3(-114.03, 6409.07, 31.0),
            vector3(-79.16, 6443.52, 31.0),
            vector3(-58.15, 6422.60, 31.0),
            vector3(-92.17, 6389.50, 31.0)
        },
        thickness = 15,
        price = 350000,
        management = vector4(-93.9869, 6408.7798, 31.6404, 45.7698),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(-92.2564, 6410.6187, 31.6405, 45.7062),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(-76.3248, 6428.9482, 31.5350, 44.5913),
        trailerCoord = vector4(-81.5884, 6422.7354, 31.5577, 44.8212)
    },
    [20] = {
        zones = {
            vector3(-2570.08, 2341.67, 33.0),
            vector3(-2565.91, 2290.53, 33.0),
            vector3(-2500.00, 2294.70, 33.0),
            vector3(-2510.98, 2348.86, 33.0)
        },
        thickness = 15,
        price = 400000,
        management = vector4(-2545.9480, 2315.8252, 33.2161, 1.4953),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(-2542.3364, 2316.1748, 33.2161, 6.5344),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(-2527.6091, 2337.6489, 33.1291, 212.7283),
        trailerCoord = vector4(-2534.4954, 2341.4558, 33.1268, 213.1388)
    },
    [21] = {
        zones = {
            vector3(-1793.56, 820.08, 138.0),
            vector3(-1836.36, 787.12, 138.0),
            vector3(-1810.98, 760.98, 138.0),
            vector3(-1768.94, 795.83, 138.0)
        },
        thickness = 15,
        price = 650000,
        management = vector4(-1819.6770, 797.4009, 138.1463, 316.6339),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(-1818.4160, 796.0036, 138.1152, 318.1024),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(-1810.3538, 792.3575, 138.2115, 216.4570),
        trailerCoord = vector4(-1820.4478, 806.7779, 138.8328, 222.1127)
    },
    [22] = {
        zones = {
            vector3(-1432.58, -214.39, 46.0),
            vector3(-1380.30, -270.08, 46.0),
            vector3(-1431.06, -310.98, 46.0),
            vector3(-1473.86, -258.71, 46.0)
        },
        thickness = 15,
        price = 550000,
        management = vector4(-1427.1622, -268.9912, 46.2284, 137.0545),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(-1428.6516, -267.4286, 46.2267, 139.0371),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(-1444.7422, -260.6065, 46.3365, 132.4743),
        trailerCoord = vector4(-1433.7723, -250.4177, 46.4146, 132.1840)
    },
    [23] = {
        zones = {
            vector3(-2120.83, -293.56, 13.0),
            vector3(-2042.80, -301.52, 13.0),
            vector3(-2044.70, -363.64, 13.0),
            vector3(-2128.79, -344.70, 13.0)
        },
        thickness = 15,
        price = 700000,
        management = vector4(-2073.2432, -328.2831, 13.3160, 84.9274),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(-2073.1277, -326.3472, 13.3160, 86.2623),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(-2057.9875, -260.3458, 22.3748, 31.2978),
        trailerCoord = vector4(-2045.1826, -271.2222, 23.0127, 54.3527)
    },
    [24] = {
        zones = {
            vector3(-734.85, -849.24, 19.0),
            vector3(-646.21, -852.27, 19.0),
            vector3(-655.30, -946.21, 19.0),
            vector3(-742.42, -952.27, 19.0)
        },
        thickness = 15,
        price = 1000000,
        management = vector4(-701.7596, -916.8944, 19.2141, 187.0228),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(-704.0950, -916.8051, 19.2141, 186.2100),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(-723.2169, -916.4905, 19.0821, 181.5654),
        trailerCoord = vector4(-729.6755, -913.3036, 19.0878, 179.4848)
    },
    [25] = {
        zones = {
            vector3(-537.88, -1178.79, 18.0),
            vector3(-490.15, -1196.21, 18.0),
            vector3(-511.36, -1256.82, 18.0),
            vector3(-562.12, -1243.18, 18.0)
        },
        thickness = 15,
        price = 550000,
        management = vector4(-532.2974, -1220.8298, 18.4550, 336.0453),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(-530.4784, -1221.4441, 18.4550, 341.4840),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(-509.4522, -1203.5626, 19.3309, 340.4641),
        trailerCoord = vector4(-516.0611, -1219.3046, 18.4418, 327.8982)
    },
    [26] = {
        zones = {
            vector3(-96.21, -1748.48, 29.0),
            vector3(-42.80, -1734.47, 29.0),
            vector3(-35.23, -1757.58, 29.0),
            vector3(-65.53, -1784.85, 29.0),
            vector3(-100.38, -1763.26, 29.0)
        },
        thickness = 15,
        price = 1000000,
        management = vector4(-48.1979, -1761.2443, 29.4396, 138.7248),
        managementPed = "a_m_m_genfat_02",
        jobList = vector4(-49.9788, -1759.8141, 29.4397, 143.1028),
        jobListPed = "a_m_m_prolhost_01",
        truckCoord = vector4(-59.0327, -1741.2533, 29.3900, 48.9153),
        trailerCoord = vector4(-64.3526, -1741.5819, 29.3767, 49.9724)
    },
}

Config.Strings = {
    ExitVehicle = "Araçtan çık",
    EToRefuel = "Aracı yakıtla doldurmak için ~y~E ~w~ tuşuna basın",
    FullTank = "Depo dolu",
    Management = "E - Yönetim Menüsü",
    Buystation = "E - İstasyon Satın Al",
    Joblist = "E - İş Listesi",
    TargetManagement = "Yönetim Menüsünü Aç",
    TargetBuystation = "İstasyon Satın Alma Menüsünü Aç",
    TargetJoblist = "İş Listesini Aç",
    TargetGaspump = "Benzin Pompası",
    newJob = 'Yeni bir işiniz var! Yakıtı işaretli noktaya teslim edin.',
    getBackTruck = 'Kamyonun yanına dön!',
    attachTrailer = 'Römorku bağla!',
    goBackStation = 'Yakıtı yüklediniz! İstasyona geri dönün.',
    delivered = 'Yakıtı teslim ettiniz',
    importMarker = '[E] - Yakıt İçe Aktar',
    unloadFuel = '[E] - Yakıtı Boşalt',
    exportFuel = "[E] - Yakıtı Dışarı Aktar",
    loadFuel = '[E] - Yakıt Yükle',
    parkMarker = '[E] - Kamyonu Park Et',
    completed = 'Aldığınız tutar: $',
    paid = 'Ödediğiniz tutar: $',
    paidFor = 'için',
    lFuel = ' L yakıt.',
    noVehicle = 'Araç bulunamadı',
    onlyStationPump = 'Benzin pompası sadece benzinlik alanında kullanılabilir.',
}


-- Bunu değiştirmeyin. Ne yaptığınızı bilmiyorsanız scripti bozabilirsiniz.

-- Auto Framework Detection
if Config.Framework == "auto" then
    if GetResourceState("qb-core") == "started" then
        Config.Framework = "qb"
    elseif GetResourceState("es_extended") == "started" then
        Config.Framework = "esx"
    else
        print("Couldn't find a framework. Using custom framework.")
        Config.Framework = "custom"
    end
end

-- Framework Object
if Config.Framework == "qb" or Config.Framework == "QB" or Config.Framework == "qb-core" then
    Config.Framework = "qb"
    FrameworkObject = exports['qb-core']:GetCoreObject()
elseif Config.Framework == "qbold" then
    FrameworkObject = nil
    Config.Framework = "qb"

    Citizen.CreateThread(function()
        while FrameworkObject == nil do
            TriggerEvent('QBCore:GetObject', function(obj) FrameworkObject = obj end)
            Citizen.Wait(50)
        end
    end)
elseif Config.Framework == "esx" or Config.Framework == "ESX" or Config.Framework == "es_extended" then
    Config.Framework = "esx"
    FrameworkObject = exports['es_extended']:getSharedObject()
elseif Config.Framework == "esxold" then
    FrameworkObject = nil
    Config.Framework = "esx"

    Citizen.CreateThread(function()
        while FrameworkObject == nil do
            TriggerEvent('esx:getSharedObject', function(obj) FrameworkObject = obj end)
            Citizen.Wait(50)
        end
    end)
else
    Config.Framework = "custom"
    -- Write your own code shared object code.
    FrameworkObject = nil
end
