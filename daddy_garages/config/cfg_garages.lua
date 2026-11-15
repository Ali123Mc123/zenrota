-- The garages, in jg-advancedgarages' own format: a jg config block can be pasted here as it is.
-- The key is the garage id (it is stored with every car, so never rename one in use).
--   coords   where the player opens it            spawn    vector4, or a list of them (the first free one is used)
--   distance how near the player must stand       type     car | sea | air
--   hideBlip / blip = { id, color, scale }        hideMarkers
-- Extra fields: label (shown name, else the key), show (vector4 where the car stands in the showroom, else spawn).
-- Job and gang garages add job / gang = { 'name' } and vehiclesType = 'personal' | 'owned' | 'spawner'.
-- Garages made in the admin panel live in the database and are added to these.
-- The spots below are Qbox's default parkings.

Config.GarageLocations = {
    ['Motel Parking'] = { coords = vector3(275.58, -344.74, 45.17), spawn = vector4(271.26, -342.32, 44.7, 159.97), distance = 12.0, type = 'car' },
    ['San Andreas Parking'] = { coords = vector3(-330.67, -781.12, 33.96), spawn = vector4(-337.11, -775.34, 33.56, 132.09), distance = 12.0, type = 'car' },
    ['Spanish Ave Parking'] = { coords = vector3(-1160.46, -741.04, 19.95), spawn = vector4(-1165.38, -747.65, 18.94, 40.45), distance = 12.0, type = 'car' },
    ['Caesars 24 Parking'] = { coords = vector3(68.08, 13.15, 69.21), spawn = vector4(72.61, 11.72, 68.47, 157.59), distance = 12.0, type = 'car' },
    ['Little Seoul Parking'] = { coords = vector3(-463.51, -808.2, 30.54), spawn = vector4(-472.24, -813.61, 30.3, 179.88), distance = 12.0, type = 'car' },
    ['Laguna Parking'] = { coords = vector3(363.85, 297.97, 103.5), spawn = vector4(367.41, 297.02, 103.2, 341.08), distance = 12.0, type = 'car' },
    ['Airport Parking'] = { coords = vector3(-796.07, -2023.26, 9.17), spawn = vector4(-793.35, -2020.62, 8.51, 58.42), distance = 12.0, type = 'car' },
    ['Beach Parking'] = { coords = vector3(-1184.21, -1509.65, 4.65), spawn = vector4(-1184.4, -1501.88, 4.39, 214.7), distance = 12.0, type = 'car' },
    ['Motor Hotel Parking'] = { coords = vector3(1137.77, 2663.54, 37.9), spawn = vector4(1137.56, 2674.19, 38.17, 359.95), distance = 12.0, type = 'car' },
    ['Shore Parking'] = { coords = vector3(1726.9, 3710.38, 34.26), spawn = vector4(1728.65, 3714.85, 34.18, 21.26), distance = 12.0, type = 'car' },
    ['Bell Farms Parking'] = { coords = vector3(78.34, 6418.74, 31.28), spawn = vector4(70.71, 6425.16, 30.92, 68.5), distance = 12.0, type = 'car' },
    ['Pillbox Garage Parking'] = { coords = vector3(218.66, -804.08, 30.75), spawn = vector4(229.33, -805.01, 30.54, 156.79), distance = 12.0, type = 'car' },
    ['Airport Hangar'] = { coords = vector3(-1025.34, -3017.0, 13.95), spawn = vector4(-979.2, -2995.51, 13.95, 52.19), distance = 20.0, type = 'air' },
    ['Sandy Shores Hangar'] = { coords = vector3(1757.74, 3296.13, 41.15), spawn = vector4(1740.88, 3278.99, 41.09, 189.46), distance = 20.0, type = 'air' },
    ['LSYMC Boathouse'] = { coords = vector3(-794.64, -1510.89, 1.6), spawn = vector4(-793.58, -1501.4, 0.12, 111.5), distance = 20.0, type = 'sea' },
    ['Paleto Boathouse'] = { coords = vector3(-277.4, 6637.01, 7.5), spawn = vector4(-289.2, 6637.96, 1.01, 45.5), distance = 20.0, type = 'sea' },
}

Config.JobGarageLocations = {
    ['Police'] = { coords = vector3(454.6, -1017.4, 28.4), spawn = vector4(438.4, -1018.3, 27.7, 90.0), distance = 12.0, type = 'car', job = { 'police' }, vehiclesType = 'personal' },
}

Config.GangGarageLocations = {
    ['Lost MC'] = { coords = vector3(957.25, -129.63, 74.39), spawn = vector4(957.25, -129.63, 74.39, 199.21), distance = 12.0, type = 'car', gang = { 'lostmc' }, vehiclesType = 'personal' },
}

Config.ImpoundLocations = {
    ['Impound Lot'] = { coords = vector3(400.45, -1630.87, 29.29), spawn = vector4(407.2, -1645.58, 29.31, 228.28), distance = 12.0, type = 'car', job = { 'police' } },
}

-- Where a car goes when it has no garage yet (a dealership sale) or its garage is gone: one per type.
Config.DefaultGarages = {
    car = 'Pillbox Garage Parking',
    sea = 'LSYMC Boathouse',
    air = 'Airport Hangar',
}

-- Server settings (servers/daddyrp/daddy_garages/config/cfg_garages.lua)
-- DaddyRP: the 94 garages from its jg-advancedgarages config, as they were. A garage whose name ends in a number is
-- can9work-auction's business garage_<number>, as under jg (Bot Garaj 2 shares garage_2 with Garaj 2); bossmenu and price
-- are not read here. No job garages (jim-jobgarage has them) and no impound (Config.Impound.Enabled = false): a towed car
-- comes back from any garage for the return fee, as under jg.

Config.GarageLocations = {
  ["Garaj 1"]               = {
    coords = vector3(-1697.26, -1138.34, 13.15),
    spawn = vector4(-1687.45, -1130.29, 12.73, 321.08),
    bossmenu = vector4(-1699.25, -1128.51, 13.15, 234.99),
    price = 8000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 2"]               = {
    coords = vector3(-15.46, -1097.21, 26.67),
    spawn = vector4(-20.82, -1112.51, 26.25, 163.37),
    bossmenu = vector4(-3.43, -1086.34, 26.67, 73.64),
    price = 6000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 3"]               = {
    coords = vector3(-759.28, -233.30, 37.28),
    spawn = vector4(-765.29, -223.98, 36.86, 27.27),
    bossmenu = vector4(-763.29, -235.24, 37.27, 301.56),
    price = 4000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 4"]               = {
    coords = vector3(-1151.82, -1743.56, 4.07),
    spawn = vector4(-1159.52, -1730.30, 3.74, 214.40),
    bossmenu = vector4(-1183.85, -1774.30, 4.34, 305.99),
    price = 3000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 5"]               = {
    coords = vector3(-582.48, -1104.64, 22.18),
    spawn = vector4(-581.15, -1123.08, 21.76, 90.55),
    bossmenu = vector4(-602.19, -1140.03, 22.32, 273.28),
    price = 4000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 6"]               = {
    coords = vector3(-3021.48, 93.83, 11.61),
    spawn = vector4(-3034.40, 102.33, 11.19, 318.19),
    bossmenu = vector4(-3060.11, 106.71, 11.61, 273.93),
    price = 3000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 7"]               = {
    coords = vector3(904.20, -1543.30, 30.52),
    spawn = vector4(890.42, -1550.33, 30.19, 221.73),
    bossmenu = vector4(884.67, -1549.65, 30.53, 303.78),
    price = 4500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 8"]               = {
    coords = vector3(1116.98, -1505.58, 34.69),
    spawn = vector4(1126.54, -1498.74, 34.27, 89.05),
    bossmenu = vector4(1123.69, -1471.72, 34.84, 88.24),
    price = 8000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 9"]               = {
    coords = vector3(51.48, -1582.74, 29.46),
    spawn = vector4(39.07, -1570.55, 28.87, 230.17),
    bossmenu = vector4(61.51, -1579.07, 29.60, 50.50),
    price = 5000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 10"]              = {
    coords = vector3(-47.25, -1839.16, 26.31),
    spawn = vector4(-62.94, -1840.88, 26.26, 319.49),
    bossmenu = vector4(-81.46, -1832.20, 27.10, 231.92),
    price = 4000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 11"]              = {
    coords = vector3(97.17, -1396.25, 29.26),
    spawn = vector4(108.91, -1402.11, 28.86, 142.97),
    bossmenu = vector4(89.81, -1411.72, 29.42, 321.58),
    price = 5000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 12"]              = {
    coords = vector3(1082.2677, -878.3480, 50.1056),
    spawn = vector4(1080.2627, -873.3015, 50.2060, 201.2251),
    bossmenu = vector4(1080.2627, -873.3015, 50.2060, 201.2251),
    price = 3500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 13"]              = {
    coords = vector3(809.91, -735.84, 27.60),
    spawn = vector4(801.12, -722.24, 27.54, 132.22),
    bossmenu = vector4(815.03, -749.23, 26.73, 271.75),
    price = 3000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 14"]              = {
    coords = vector3(324.82, -213.43, 54.09),
    spawn = vector4(335.42, -213.75, 53.66, 67.81),
    bossmenu = vector4(329.34, -200.28, 54.23, 159.63),
    price = 3500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 15"]              = {
    coords = vector3(99.12, -203.40, 54.49),
    spawn = vector4(76.22, -201.32, 54.07, 249.10),
    bossmenu = vector4(84.55, -220.71, 54.64, 342.93),
    price = 3500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 16"]              = {
    coords = vector3(-364.65, -126.98, 38.70),
    spawn = vector4(-371.85, -107.24, 38.26, 160.20),
    bossmenu = vector4(-383.70, -97.99, 38.68, 171.21),
    price = 3500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 17"]              = {
    coords = vector3(-903.17, -152.31, 41.88),
    spawn = vector4(-921.24, -170.29, 41.45, 27.85),
    bossmenu = vector4(-906.62, -143.92, 41.88, 208.73),
    price = 3000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 18"]              = {
    coords = vector3(-1520.42, -419.69, 35.44),
    spawn = vector4(-1535.84, -434.38, 35.02, 230.63),
    bossmenu = vector4(-1534.88, -421.92, 35.59, 233.24),
    price = 4500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 19"]              = {
    coords = vector3(-1425.34, -652.64, 28.67),
    spawn = vector4(-1402.32, -641.45, 28.25, 120.76),
    bossmenu = vector4(-1422.48, -640.75, 28.67, 214.75),
    price = 4000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 20"]              = {
    coords = vector3(-2150.78, -378.30, 13.15),
    spawn = vector4(-2139.35, -402.67, 12.84, 47.75),
    bossmenu = vector4(-2135.07, -392.44, 13.19, 150.40),
    price = 4500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 21"]              = {
    coords = vector3(-3050.21, 451.48, 6.58),
    spawn = vector4(-3051.12, 460.87, 6.40, 155.69),
    bossmenu = vector4(-3043.71, 475.83, 6.78, 253.95),
    price = 3000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 22"]              = {
    coords = vector3(-3145.99, 1058.76, 20.52),
    spawn = vector4(-3138.76, 1078.88, 20.20, 82.71),
    bossmenu = vector4(-3153.77, 1053.38, 20.89, 334.84),
    price = 4000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 23"]              = {
    coords = vector3(-2524.06, 2341.15, 33.06),
    spawn = vector4(-2538.20, 2347.27, 32.64, 211.27),
    bossmenu = vector4(-2524.17, 2317.69, 33.22, 7.06),
    price = 3000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 24"]              = {
    coords = vector3(-1136.76, 2671.70, 18.09),
    spawn = vector4(-1160.91, 2671.78, 17.67, 221.17),
    bossmenu = vector4(-1134.66, 2683.04, 18.51, 132.31),
    price = 3000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 25"]              = {
    coords = vector3(333.37, 2622.70, 44.49),
    spawn = vector4(351.89, 2630.76, 44.07, 30.46),
    bossmenu = vector4(317.07, 2622.72, 44.46, 313.55),
    price = 3500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 26"]              = {
    coords = vector3(1128.20, 2666.22, 38.02),
    spawn = vector4(1105.61, 2663.33, 37.55, 358.18),
    bossmenu = vector4(1121.54, 2641.73, 38.14, 4.62),
    price = 3000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 27"]              = {
    coords = vector3(1859.93, 2576.58, 45.67),
    spawn = vector4(1876.12, 2595.04, 45.25, 270.73),
    bossmenu = vector4(1852.16, 2590.03, 45.67, 270.64),
    price = 6000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 28"]              = {
    coords = vector3(2542.83, 2620.46, 37.94),
    spawn = vector4(2550.04, 2614.96, 37.52, 20.12),
    bossmenu = vector4(2527.63, 2617.20, 37.96, 269.32),
    price = 3000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 29"]              = {
    coords = vector3(2760.88, 3467.53, 55.69),
    spawn = vector4(2767.40, 3456.61, 55.28, 246.38),
    bossmenu = vector4(2747.25, 3472.96, 55.67, 246.39),
    price = 3500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 30"]              = {
    coords = vector3(2486.46, 4116.58, 38.06),
    spawn = vector4(2491.95, 4122.66, 37.78, 336.58),
    bossmenu = vector4(2483.90, 4108.90, 38.04, 337.27),
    price = 3500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 31"]              = {
    coords = vector3(67.20, 6407.70, 31.23),
    spawn = vector4(81.44, 6396.34, 30.80, 133.15),
    bossmenu = vector4(52.76, 6400.91, 31.44, 227.59),
    price = 3500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 32"]              = {
    coords = vector3(-683.89, 5822.38, 17.33),
    spawn = vector4(-696.66, 5810.83, 16.91, 65.37),
    bossmenu = vector4(-690.41, 5815.30, 17.33, 62.54),
    price = 3500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 33"]              = {
    coords = vector3(336.59, 3426.44, 36.28),
    spawn = vector4(323.93, 3423.48, 36.12, 255.35),
    bossmenu = vector4(346.86, 3405.49, 36.85, 23.10),
    price = 3500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 34"]              = {
    coords = vector3(1850.30, 3687.90, 34.01),
    spawn = vector4(1850.30, 3687.90, 34.01, 210.22),
    bossmenu = vector4(1859.42, 3712.21, 33.75, 124.27),
    price = 1000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 35"]              = {
    coords = vector3(395.09, 807.04, 189.38),
    spawn = vector4(400.64, 797.21, 188.56, 162.22),
    bossmenu = vector4(377.56, 800.99, 187.67, 2.84),
    price = 1000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 36"]              = {
    coords = vector3(446.27, -989.72, 25.70),
    spawn = vector4(437.22, -988.76, 25.28, 90.17),
    bossmenu = vector4(423.87, -1000.29, 25.70, 359.51),
    price = 1000000,
    distance = 10.0, -- MRPD bodrumunda; alan artık 4 m yüksek kutu, üstteki giriş katından açılmaz
    type = "car",
    hideBlip = true
  },
  ["Garaj 37"]              = {
    coords = vector3(-3161.9280, 1408.6387, 20.6252),
    spawn = vector4(-3160.7546, 1414.6602, 20.6252, 221.0387),
    bossmenu = vector4(-3177.10, 1411.23, 20.85, 230.12),
    price = 1000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 38"]              = {
    coords = vector3(-459.24, 6042.30, 31.34),
    spawn = vector4(-472.39, 6035.39, 30.92, 225.58),
    bossmenu = vector4(-461.88, 6027.19, 31.49, 315.04),
    price = 1000000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 39"]              = {
    coords = vector3(-567.13, 330.69, 84.45),
    spawn = vector4(-572.71, 323.83, 84.12, 354.94),
    bossmenu = vector4(-570.55, 310.78, 84.50, 358.52),
    price = 1500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 40"]              = {
    coords = vector3(1261.12, -370.99, 69.04),
    spawn = vector4(1274.65, -368.12, 68.63, 53.10),
    bossmenu = vector4(1254.62, -350.16, 69.08, 345.42),
    price = 1500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 41"]              = {
    coords = vector3(-242.53, -1319.37, 31.30),
    spawn = vector4(-244.97, -1338.77, 30.87, 358.71),
    bossmenu = vector4(-231.49, -1340.43, 31.30, 95.08),
    price = 2500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 42"]              = {
    coords = vector3(851.78, -2119.03, 30.54),
    spawn = vector4(865.8911, -2125.3040, 29.9384, 173.8749),
    bossmenu = vector4(843.97, -2132.01, 30.54, 266.77),
    price = 2500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 43"]              = {
    coords = vector3(-537.16, -257.47, 35.78),
    spawn = vector4(-542.84, -272.89, 34.84, 111.75),
    bossmenu = vector4(-529.41, -256.75, 35.68, 122.57),
    price = 2500000,
    distance = 10.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 44"]              = {
    coords = vector3(-830.15, 5408.65, 34.44),
    spawn = vector4(-825.99, 5407.01, 34.04, 357.72),
    bossmenu = vector4(-836.90, 5393.52, 34.63, 85.87),
    price = 2500000,
    distance = 12.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 45"]              = {
    coords = vector3(169.06, -3193.11, 5.82),
    spawn = vector4(162.06, -3197.41, 5.96, 270.59),
    bossmenu = vector4(161.52, -3191.68, 5.97, 266.28),
    price = 2500000,
    distance = 12.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 46"]              = {
    coords = vector3(-1670.2245, -543.9589, 34.6059),
    spawn = vector4(-1664.3770, -548.5848, 33.9713, 233.0126),
    bossmenu = vector3(-1670.2245, -543.9589, 34.6059),
    price = 2500000,
    distance = 12.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 47"]              = {
    coords = vector3(85.3182, -346.5528, 38.7444),
    spawn = vector4(75.5985, -346.3999, 38.2309, 249.7117),
    bossmenu = vector3(85.3182, -346.5528, 38.7444),
    price = 2500000,
    distance = 12.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 48"]              = {
    coords = vector3(86.1420, -385.1443, 40.6656),
    spawn = vector4(78.8047, -399.7604, 40.2160, 9.4924),
    bossmenu = vector3(86.1420, -385.1443, 40.6656),
    price = 2500000,
    distance = 12.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 49"]              = {
    coords = vector3(711.0923, -1075.3312, 21.9523),
    spawn = vector4(718.1803, -1078.6527, 21.8732, 88.6471),
    bossmenu = vector3(711.0923, -1075.3312, 21.9523),
    price = 2500000,
    distance = 12.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 50"]              = {
    coords = vector3(2485.8433, 1503.7053, 38.9329),
    spawn = vector4(2492.5764, 1515.3718, 38.3262, 90.4301),
    bossmenu = vector3(2485.8433, 1503.7053, 38.9329),
    price = 2500000,
    distance = 12.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 51"]              = {
    coords = vector3(-1431.9774, 4235.6855, 48.1556),
    spawn = vector4(-1437.8674, 4232.9844, 48.4270, 92.1622),
    bossmenu = vector3(-1431.9774, 4235.6855, 48.1556),
    price = 2500000,
    distance = 12.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 52"]              = {
    coords = vector3(-337.5192, 271.6604, 85.7979),
    spawn = vector4(-328.2797, 277.6797, 85.8948, 92.6809),
    bossmenu = vector3(-337.5192, 271.6604, 85.7979),
    price = 2500000,
    distance = 12.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 53"]              = {
    coords = vector3(1173.4037, -642.2302, 62.4426),
    spawn = vector4(1173.5089, -650.0810, 62.0619, 188.3894),
    bossmenu = vector3(1173.4037, -642.2302, 62.4426),
    price = 2500000,
    distance = 12.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 54"]              = {
    coords = vector3(2542.2268, 4666.4663, 34.0768),
    spawn = vector4(2536.3374, 4668.2456, 33.9313, 309.4969),
    bossmenu = vector3(2542.2268, 4666.4663, 34.0768),
    price = 2500000,
    distance = 5.0, -- DaddyRP: 12 m reached the farm NPC next to it
    type = "car",
    hideBlip = true
  },
  ["Garaj 55"]              = {
    coords = vector3(2211.8069, 5594.6758, 53.4802),
    spawn = vector4(2213.4172, 5603.5317, 53.5585, 354.4334),
    bossmenu = vector3(2211.8069, 5594.6758, 53.4802),
    price = 2500000,
    distance = 12.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 56"]              = {
    coords = vector3(2788.9126, 4772.3379, 46.3577),
    spawn = vector4(2781.4172, 4770.5117, 46.1306, 283.7061),
    bossmenu = vector3(2788.9126, 4772.3379, 46.3577),
    price = 2500000,
    distance = 14.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 57"]              = {
    coords = vector3(-844.0440, -706.3336, 27.1067),
    spawn = vector4(-842.0859, -689.6727, 26.9379, 358.9880),
    bossmenu = vector3(-844.0440, -706.3336, 27.1067),
    price = 2500000,
    distance = 14.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 58"]              = {
    coords = vector3(1985.8610, 3068.8118, 46.9779),
    spawn = vector4(1993.2579, 3080.0000, 46.6182, 238.1259),
    bossmenu = vector3(1985.8610, 3068.8118, 46.9779),
    price = 2500000,
    distance = 14.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 59"]              = {
    coords = vector3(917.6243, -41.7212, 78.7641),
    spawn = vector4(917.6243, -41.7212, 78.7641, 56.1841),
    bossmenu = vector3(917.6243, -41.7212, 78.7641),
    price = 2500000,
    distance = 14.0,
    type = "car",
    hideBlip = true
  },  
  ["Garaj 60"]              = {
    coords = vector3(1150.6174, -308.4689, 68.0808),
    spawn = vector4(1150.6174, -308.4689, 68.0808, 238.1259),
    bossmenu = vector3(1150.6174, -308.4689, 68.0808),
    price = 2500000,
    distance = 14.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 61"]              = {
    coords = vector3(-701.7527, -864.2643, 23.4858),
    spawn = vector4(-701.7527, -864.2643, 23.4858, 132.4627),
    bossmenu = vector3(-701.7527, -864.2643, 23.4858),
    price = 2500000,
    distance = 14.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 62"]              = {
    coords = vector3(224.48, -38.28, 68.7),
    spawn = vector4(224.48, -38.28, 68.7, 341.11),
    bossmenu = vector3(224.48, -38.28, 68.7),
    price = 2500000,
    distance = 14.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 63"]              = {
    coords = vector3(854.5159, -2348.4775, 30.3313),
    spawn = vector4(853.3109, -2334.3281, 29.7369, 174.9677),
    bossmenu = vector3(854.5159, -2348.4775, 30.3313),
    price = 2500000,
    distance = 14.0,
    type = "car",
    hideBlip = true
  },
  ["Garaj 64"]              = {
    coords = vector3(-1337.1755, -1480.5767, 4.3137),
    spawn = vector4(-1347.9252, -1458.5022, 3.7064, 293.3615),
    bossmenu = vector3(-1337.1755, -1480.5767, 4.3137),
    price = 2500000,
    distance = 14.0,
    type = "car",
    hideBlip = true
  },     
  ["Garaj 65"]              = {
    coords = vector3(616.5451, 2725.5652, 41.9367),
    spawn = vector4(615.9636, 2716.6257, 41.9369, 0.2826),
    bossmenu = vector3(616.5451, 2725.5652, 41.9367),
    price = 2500000,
    distance = 14.0,
    type = "car",
    hideBlip = true
  },     
  ["Garaj 66"]              = {
    coords = vector3(5346.4830, -5316.5730, 32.0500),
    spawn = vector4(5346.4830, -5316.5730, 32.0500, 218.3800),
    bossmenu = vector3(5346.4830, -5316.5730, 32.0500),
    price = 2500000,
    distance = 14.0,
    type = "car",
    hideBlip = true
  },     
  ["Garaj 67"]              = {
    coords = vector3(3932.4473, -4696.5703, 4.1903),
    spawn = vector4(3932.4473, -4696.5703, 4.1903, 288.8215),
    bossmenu = vector3(3932.4473, -4696.5703, 4.1903),
    price = 2500000,
    distance = 14.0,
    type = "car",
    hideBlip = true
  },    
  ["Bot Garaj 1"]           = {
    coords = vector3(-1796.71, -1228.43, 1.77),
    spawn = vector4(-1798.97, -1236.14, 0.36, 142.06),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },
  ["Bot Garaj 2"]           = {
    coords = vector3(-798.13, -1423.01, 1.62),
    spawn = vector4(-806.24, -1430.76, 0.32, 162.08),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },
  ["Bot Garaj 3"]           = {
    coords = vector3(6.20, -2801.49, 2.90),
    spawn = vector4(-1.49, -2808.66, 0.62, 129.65),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },
  -- ["Bot Garaj 4"] -- Bot Garaj 1 ile aynı koordinatlar, duplicate kaldırıldı

  ["Bot Garaj 5"]           = {
    coords = vector3(-798.13, -1423.01, 1.62),
    spawn = vector4(-806.24, -1430.76, 0.32, 162.08),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },

  ["Bot Garaj 6"]           = {
    coords = vector3(2839.73, -668.89, 0.23),
    spawn = vector4(2862.99, -672.20, 0.34, 263.58),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },

  ["Bot Garaj 7"]           = {
    coords = vector3(3766.13, 3819.17, 0.50),
    spawn = vector4(3784.03, 3821.68, 0.68, 278.74),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },

  ["Bot Garaj 8"]           = {
    coords = vector3(3844.47, 4445.14, 0.11),
    spawn = vector4(3867.96, 4447.84, 0.40, 275.53),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },

  ["Bot Garaj 9"]           = {
    coords = vector3(182.69, 7104.58, 0.31),
    spawn = vector4(180.77, 7126.13, 0.86, 2.45),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },

  ["Bot Garaj 10"]          = {
    coords = vector3(-1603.49, 5260.27, 2.00),
    spawn = vector4(-1595.77, 5273.16, 0.82, 340.34),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },

  ["Bot Garaj 11"]          = {
    coords = vector3(-2593.49, 3726.94, 0.38),
    spawn = vector4(-2612.88, 3726.71, 0.72, 88.14),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },

  ["Bot Garaj 12"]          = {
    coords = vector3(-3307.52, 1008.24, 0.21),
    spawn = vector4(-3340.16, 1017.88, 0.24, 72.77),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },

  ["Bot Garaj 13"]          = {
    coords = vector3(-3091.18, 33.80, 0.17),
    spawn = vector4(-3108.94, 15.18, 0.41, 135.74),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },

  ["Bot Garaj 14"]          = {
    coords = vector3(1473.45, 3920.44, 30.12),
    spawn = vector4(1465.61, 3896.62, 30.13, 161.65),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },

  ["Bot Garaj 15"]          = {
    coords = vector3(683.88, 4149.76, 30.13),
    spawn = vector4(667.42, 4129.34, 30.47, 142.95),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },

  ["Bot Garaj 16"]          = {
    coords = vector3(1693.66, 37.76, 161.81),
    spawn = vector4(1699.20, 29.51, 160.80, 247.32),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },

  ["Bot Garaj 17"]          = {
    coords = vector3(34.95, 853.63, 197.70),
    spawn = vector4(49.86, 844.82, 196.86, 236.02),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },
  ["Bot Garaj 18"]          = {
    coords = vector3(-3437.00, 970.01, 8.35), -- DaddyRP: 9 m west, off the Ganimet Avı (0r-activities diving) NPC
    spawn = vector4(-3528.04, 928.95, -0.88, 130.53),
    distance = 12.0,
    type = "sea",
    hideBlip = true,
    blip = { id = 357, color = 0, scale = 0.5 },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },
  ["Bot Garaj 19"]          = {
    coords = vector3(-3329.5020, 6961.9199, 2.4842),
    spawn = vector4(-3329.5020, 6961.9199, 2.4842, 224.6467),
    distance = 12.0,
    type = "sea",
    hideBlip = false,
    blip = { id = 427, color = 3, scale = 0.6 },
    hideMarkers = false,
    markers = {
      id = 35,
      size = { x = 0.8, y = 0.8, z = 0.8 },
      color = { r = 0, g = 180, b = 255, a = 150 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },
  ["Bot Garaj Cayo"]        = {
    coords = vector3(4475.4692, -4189.6660, 1.4757),
    spawn = vector4(4488.7925, -4187.4287, -0.2690, 324.9888),
    distance = 12.0,
    type = "sea",
    hideBlip = false,
    blip = { id = 427, color = 3, scale = 0.6 },
    hideMarkers = false,
    markers = {
      id = 35,
      size = { x = 0.8, y = 0.8, z = 0.8 },
      color = { r = 0, g = 180, b = 255, a = 150 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },
  ["Garaj Air PD"]          = {
    label = "PD Hava Garajı",
    -- Alta PD (eski): coords = vector3(134.7569, -354.9612, 57.5743), spawn = vector3(134.7569, -354.9612, 57.5743)
    coords = vector3(449.168, -981.325, 43.691),         -- MRPD çatı helipedi (AIR mekanik yan pedde)
    spawn = vector4(449.168, -981.325, 43.691, 87.234),
    distance = 10.0,
    type = "air",
    hideBlip = true,
    blip = {
      id = 357,
      color = 0,
      scale = 0.5
    },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },
  ["Garaj Air DP"]          = {
    label = "DP Hava Garajı",
    coords = vector3(-474.8987, 5989.4492, 31.3365),
    spawn = vector3(-474.8987, 5989.4492, 31.3365),
    distance = 10.0,
    type = "air",
    hideBlip = true,
    blip = {
      id = 357,
      color = 0,
      scale = 0.5
    },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },
  ["Garaj Air Sasp"]        = {
    label = "SASP Hava Garajı",
    coords = vector3(-3114.10, 1471.65, 20.63),
    spawn = vector4(-3114.25, 1471.54, 20.63, 238.23),
    distance = 10.0,
    type = "air",
    hideBlip = true,
    blip = {
      id = 357,
      color = 0,
      scale = 0.5
    },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },
  ["Garaj Air Park Ranger"] = {
    label = "Park Ranger Hava Garajı",
    -- old: coords = vector3(-808.13, 5426.45, 34.19), spawn = vector4(-826.86, 5426.18, 33.80, 255.13)
    -- prev: coords = vector3(354.5047, 795.1805, 187.7197), spawn = vector4(354.5047, 795.1805, 187.7197, 245.0353)
    -- prev Park Ranger: coords = vector3(408.3664, 762.7616, 188.4680), spawn = vector4(408.3664, 762.7616, 188.4680, 52.2330)
    coords = vector3(134.7569, -354.9612, 57.5743),       -- Alta PD çatı helipedi
    spawn = vector4(134.7569, -354.9612, 57.5743, 340.0),
    distance = 10.0,
    type = "air",
    hideBlip = true,
    blip = {
      id = 357,
      color = 0,
      scale = 0.5
    },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },
  ["Garaj Air BCSO"]        = {
    label = "BCSO Hava Garajı",
    coords = vector3(1824.44, 3685.75, 42.58),
    spawn = vec4(1824.44, 3685.77, 42.86, 8.53),
    distance = 10.0,
    type = "air",
    hideBlip = true,
    blip = {
      id = 357,
      color = 0,
      scale = 0.5
    },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },
  ["Garaj Air PBSD"]        = {
    label = "PBSD Hava Garajı",
    coords = vector3(2782.3552, 4794.6489, 46.7042),
    spawn = vector4(2782.3552, 4794.6489, 46.7042, 101.4833),
    distance = 10.0,
    type = "air",
    hideBlip = true,
    blip = {
      id = 357,
      color = 0,
      scale = 0.5
    },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },
  ["Garaj Air EMS"]         = {
    label = "EMS Hava Garajı",
    coords = vector3(1186.13, -1552.94, 39.4),
    spawn = vector4(1186.13, -1552.94, 39.4, 3.91),
    distance = 10.0,
    type = "air",
    job = { "ambulance" },
    hideBlip = true,
    blip = {
      id = 357,
      color = 0,
      scale = 0.5
    },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },
  ["Garaj Air EMS Kasaba"]         = {
    label = "EMS Kasaba Hava Garajı",
    coords = vector3(606.7991, 2772.8010, 61.6175),
    spawn = vector4(606.7991, 2772.8010, 61.6175, 192.8081),
    distance = 10.0,
    type = "air",
    job = { "ambulance" },
    hideBlip = true,
    blip = {
      id = 357,
      color = 0,
      scale = 0.5
    },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },
  ["Garaj Kolej"] = {
    coords = vector3(5393.3600, -5235.9990, 26.3530),
    spawn = vector4(5393.3600, -5235.9990, 26.3530, 58.5100),
    bossmenu = vector4(5393.3600, -5235.9990, 26.3530, 58.5100),
    distance = 10.0,
    type = "car",
    hideBlip = true,
    blip = {
      id = 357,
      color = 3,
      scale = 0.6,
      label = "Kolej Garajı"
    },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  },
  ["Garaj Iskele"] = { -- public, Del Perro pier entrance
    label = "İskele Garajı",
    coords = vector3(-1844.9333, -1302.8784, 3.0098),
    spawn = vector4(-1841.7409, -1304.3131, 3.0098, 245.7997), -- 3.5 m ahead of the spot, check in game
    distance = 10.0,
    type = "car",
    hideBlip = false,
    blip = {
      id = 357,
      color = 0,
      scale = 0.6
    },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
  }
}

Config.JobGarageLocations = {}

Config.GangGarageLocations = {
  ["The Lost MC"] = {
    coords = vector3(439.18, -1518.48, 29.28),
    spawn = vector4(439.18, -1518.48, 29.28, 139.06),
    distance = 15,
    gang = { "lostmc" },
    type = "car",
    hideBlip = false,
    blip = {
      id = 357,
      color = 82,
      scale = 0.55
    },
    hideMarkers = true,
    markers = {
      id = 21,
      size = { x = 0.3, y = 0.3, z = 0.3 },
      color = { r = 255, g = 255, b = 255, a = 120 },
      bobUpAndDown = 0,
      faceCamera = 0,
      rotate = 1,
      drawOnEnts = 0
    },
    vehiclesType = "personal", -- Use personal vehicles
  }
}

-- The police impound on the game's own lot at Davis (jg's example, never switched on under jg): officers impound with
-- /iv, owners pay here once the time is up. Boats and aircraft paid for here go to a garage of their type.
Config.ImpoundLocations = {
  ["Impound A"] = {
    label = "Çekme Otoparkı",
    coords = vector3(410.8, -1626.26, 29.29),
    spawn = vector4(408.44, -1630.88, 29.29, 136.88),
    distance = 15,
    type = "car",
    job = { "police" },
    blip = { id = 68, color = 82, scale = 0.55 },
  },
}

-- A dealership sale waits in the garage nearest the dealership.
Config.DefaultGarages = { car = 'Garaj 2', sea = 'Bot Garaj 2', air = 'Garaj Air PD' }
