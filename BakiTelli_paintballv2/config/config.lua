Config = {}
-- General Config
Config.Framework = "auto" -- Determines which framework to use: auto, esx, or qb or qbx
Config.Mysql = "oxmysql" -- oxmysql or ghmattimysql or mysql-async
Config.CustomInventory = "auto" -- auto or "quasar" or "ox_inventory" or false
Config.Locale = 'tr' -- "en", "es", "ru", "de", "fr", "pt", "pl", "hu", "gr", "nl", "ro", "tr", "ar", "zh", "he", "fa"

-- # Paintball General Config 
Config.Distance = 5 -- Where to access the menu
Config.OutOfBoundsDistance = 400 -- Kill player if they leave the arena. 0 = disabled. Measured from the map center (midpoint of red 1 and blue 1).
Config.MoneyType = "bank" -- bank or cash
Config.LobbyNamePrefix = "DADDY" -- LobbyName Prefix
Config.LobbyNameNumber = 6 -- How many characters
Config.QuitGame = "qpb" -- Quit Game Command
Config.ScoreboardKey = 20 -- Z key (GTA key code for Z)
Config.LobbyCreatePrice = 0

Config.PaintballAreas = {
    [1] = vector3(82.0395, 6422.4990, 31.6732), -- eski 0r-paintball girişi (Paleto)
    [2] = vector3(4432.2456, -4197.3862, 3.3269), -- Cayo Porto
} 

-- # Paintball Market Config
Config.PaintballMarket = { -- skin market config
	["default_pistol"] = { -- no change and no delete
		["localeKey"] = "market_default_pistol", -- no change
		["price"] = "default",
		["image"] = "./img/default_pistol.png",
		["description"] = "Varsayılan Paintball Tabancası",
		["type"] = "pistol", -- no change
		["weapon"] = "WEAPON_PB_PISTOL",
	},
	["default_rifle"] = { -- no change and no delete
		["localeKey"] = "market_default_rifle", -- no change
		["price"] = "default",
		["image"] = "./img/default_rifle.png",
		["description"] = "Varsayılan Paintball Tüfeği",
		["type"] = "rifle", -- no change
		["weapon"] = "WEAPON_PB_RIFLE",
	},
	["default_smg"] = { -- no change and no delete
		["localeKey"] = "market_default_smg", -- no change
		["price"] = "default",
		["image"] = "./img/default_smg.png",
		["description"] = "Varsayılan Paintball Hafif Makineli",
		["type"] = "smg", -- no change
		["weapon"] = "WEAPON_PB_SMG",
	},
	["default_pump"] = { -- no change and no delete
		["localeKey"] = "market_default_pump", -- no change
		["price"] = "default",
		["image"] = "./img/default_pump.png",
		["description"] = "Varsayılan Paintball Pompalısı",
		["type"] = "pump", -- no change
		["weapon"] = "WEAPON_PB_SHOTGUN",
	},
	["darkwave_pistol"] = { -- no change or delete
		["localeKey"] = "market_darkwave_pistol", -- no change
		["price"] = 15000,
		["image"] = "./img/darkwave_pistol.png",
		["description"] = "Darkwave Paintball Tabancası",
		["type"] = "pistol", -- no change
		["weapon"] = "WEAPON_PB_PISTOL_B",
	},
	["darkwave_rifle"] = { -- no change or delete
		["localeKey"] = "market_darkwave_rifle", -- no change
		["price"] = 15000,
		["image"] = "./img/darkwave_rifle.png",
		["description"] = "Darkwave Paintball Tüfeği",
		["type"] = "rifle", -- no change
		["weapon"] = "WEAPON_PB_RIFLE_B",
	},
	["darkwave_smg"] = { -- no change or delete
		["localeKey"] = "market_darkwave_smg", -- no change
		["price"] = 15000,
		["image"] = "./img/darkwave_smg.png",
		["description"] = "Darkwave Paintball Hafif Makineli",
		["type"] = "smg", -- no change
		["weapon"] = "WEAPON_PB_SMG_B",
	},
	["darkwave_pump"] = { -- no change or delete
		["localeKey"] = "market_darkwave_pump", -- no change
		["price"] = 15000,
		["image"] = "./img/darkwave_pump.png",
		["description"] = "Darkwave Paintball Pompalısı",
		["type"] = "pump", -- no change
		["weapon"] = "WEAPON_PB_SHOTGUN_B",
	},
	["gold_pistol"] = { -- no change or delete
		["localeKey"] = "market_gold_pistol", -- no change
		["price"] = 30000,
		["image"] = "./img/gold_pistol.png",
		["description"] = "Altın Paintball Tabancası",
		["type"] = "pistol", -- no change
		["weapon"] = "WEAPON_PB_PISTOL_G",
	},
	["gold_rifle"] = { -- no change or delete
		["localeKey"] = "market_gold_rifle", -- no change
		["price"] = 30000,
		["image"] = "./img/gold_rifle.png",
		["description"] = "Altın Paintball Tüfeği",
		["type"] = "rifle", -- no change
		["weapon"] = "WEAPON_PB_RIFLE_G",
	},
	["gold_smg"] = {
		["localeKey"] = "market_gold_smg", -- no change
		["price"] = 30000,
		["image"] = "./img/gold_smg.png",
		["description"] = "Altın Paintball Hafif Makineli",
		["type"] = "smg", -- no change
		["weapon"] = "WEAPON_PB_SMG_G",
	},
	["gold_pump"] = {
		["localeKey"] = "market_gold_pump", -- no change	
		["price"] = 30000,
		["image"] = "./img/gold_pump.png",
		["description"] = "Altın Paintball Pompalısı",
		["type"] = "pump", -- no change
		["weapon"] = "WEAPON_PB_SHOTGUN_G",
	},
}

-- # Paintball Maps Config
Config.Maps = {
	{
		map_img = "./img/2.png",
		red =  {
			[1] = vector4(3234.811, -125.9215, 1388.109, 186.8525),
			[2] = vector4(3231.894, -126.0005, 1388.109, 182.7994),
			[3] = vector4(3229.04, -126.0167, 1388.109, 185.5305),
			[4] = vector4(3214.663, -125.7718, 1388.109, 192.0256),
			[5] = vector4(3208.985, -125.8526, 1388.109, 195.9801),
		},
		blue = {
			[1] = vector4(3234.788, -171.9013, 1388.109, 355.6349),
			[2] = vector4(3231.819, -172.1867, 1388.109, 359.0597),
			[3] = vector4(3229.26, -172.3242, 1388.109, 5.017426),
			[4] = vector4(3214.897, -172.4576, 1388.109, 356.0765),
			[5] = vector4(3209.153, -172.3117, 1388.109, 20.60857),
		}
	},
	{
		map_img = "./img/1.png",
		red =  {
			[1] = vector4(-3732.24, -2984.88, 541.92, 184.52),
			[2] = vector4(-3735.76, -2984.48, 541.92, 185.52),
			[3] = vector4(-3740.6, -2984.48, 541.92, 180.52),
			[4] = vector4(-3745.6, -2984.72, 541.92, 186.96),
			[5] = vector4(-3750.12, -2985.24, 541.92, 184.0),
		},
		blue = {
			[1] = vector4(-3748.24, -3021.08, 541.92, 1.64),
			[2] = vector4(-3748.24, -3021.08, 541.92, 1.64),
			[3] = vector4(-3748.24, -3021.08, 541.92, 1.64),
			[4] = vector4(-3748.24, -3021.08, 541.92, 1.64),
			[5] = vector4(-3731.28, -3020.36, 541.92, 1.36),
		}
	},
	{
		map_img = "./img/3.png",
		red =  {
			[1] = vector4(-36.48768, -1140.328, -2.30642, 75.48946),
			[2] = vector4(-36.27711, -1138.796, -2.30642, 77.53115),
			[3] = vector4(-35.89815, -1137.546, -2.30642, 68.69373),
			[4] = vector4(-35.07166, -1136.23, -2.30642, 75.48691),
			[5] = vector4(-34.7529, -1135.046, -2.30642, 68.26452),
		},
		blue = {
			[1] = vector4(-65.59706, -1119.177, -2.30642, 252.2849),
			[2] = vector4(-66.2309, -1120.808, -2.30642, 252.2012),
			[3] = vector4(-66.6067, -1122.751, -2.30642, 258.0199),
			[4] = vector4(-67.78556, -1126.407, -2.30642, 251.9601),
			[5] = vector4(-68.61132, -1128.636, -2.30642, 250.364),
		}
	},
	{
		map_img = "./img/4.png",
		red =  {
			[1] = vector4(-2299.1321, 5885.3203, 1678.0912, 150.5354),
			[2] = vector4(-2297.5681, 5883.5225, 1678.0912, 150.2108),
			[3] = vector4(-2295.8845, 5881.5728, 1678.0912, 150.5985),
			[4] = vector4(-2294.2568, 5879.8018, 1678.0912, 150.6756),
			[5] = vector4(-2292.8105, 5878.0884, 1678.0912, 150.9372),
		},
		blue = {
			[1] = vector4(-2446.1543, 5746.2378, 1678.0881, 316.1814),
			[2] = vector4(-2444.6484, 5744.5913, 1678.0881, 316.4158),
			[3] = vector4(-2442.2632, 5742.7373, 1678.0884, 316.5005),
			[4] = vector4(-2440.0945, 5740.2476, 1678.0884, 316.5442),
			[5] = vector4(-2436.7297, 5737.7524, 1678.0886, 316.0243),
		}
	},
	{
		map_img = "./img/5.png",
		red =  {
			[1] = vector4(-3662.06, 2220.09, 445.65, 269.89),
			[2] = vector4(-3662.07, 2222.38, 445.65, 269.89),
			[3] = vector4(-3662.34, 2207.42, 445.65, 269.7),
			[4] = vector4(-3662.27, 2205.04, 445.65, 269.7),
			[5] = vector4(-3663.19, 2213.42, 445.65, 269.7),
		},
		blue = {
			[1] = vector4(-3614.51, 2214.21, 445.65, 88.45),
			[2] = vector4(-3614.73, 2207.31, 445.65, 88.28),
			[3] = vector4(-3614.8, 2203.75, 445.65, 88.23),
			[4] = vector4(-3614.76, 2219.4, 445.65, 88.3),
			[5] = vector4(-3614.79, 2222.39, 445.65, 88.49),
		}
	},
}

-- # Paintball Lobby Loaction Config
Config.PaintballLobbyLoaction = {
	["red"] = {
		[1] = {
			coord = vec4(664.061523, -545.920898, 13.974365, 241.779526),
			anim = {
				["dict"] = "anim@amb@nightclub@peds@",
				["anim"] = "rcmme_amanda1_stand_loop_cop",
			},
		},
		[2] = {
			coord = vec4(663.665955, -546.830750, 13.991211, 241.614166),
			anim = {
				["dict"] = "anim@amb@nightclub@peds@",
				["anim"] = "rcmme_amanda1_stand_loop_cop",
			},
		},
		[3] = {
			coord = vec4(664.5739, -545.0358, 13.9829, 241.7045),
			anim = {
				["dict"] = "anim@amb@nightclub@peds@",
				["anim"] = "rcmme_amanda1_stand_loop_cop",
			},
		},
		[4] = {
			coord = vec4(664.8481, -545.6943, 13.9820, 241.7465),
			anim = {
				["dict"] = "amb@world_human_stupor@male@idle_a",
				["anim"] = "idle_a",
			},
		},
		[5] = {
			coord = vec4(664.4028, -546.5956, 13.9926, 241.1903),
			anim = {
				["dict"] = "amb@world_human_stupor@male@idle_a",
				["anim"] = "idle_a",
			},
		},
	},
	["blue"] = {
		[1] = {
			coord = vec4(662.1896, -549.5630, 14.0317, 241.0219),
			anim = {
				["dict"] = "anim@amb@nightclub@peds@",
				["anim"] = "rcmme_amanda1_stand_loop_cop",
			},
		},
		[2] = {
			coord = vec4(661.7096, -550.4404, 14.0425, 241.0219),
			anim = {
				["dict"] = "anim@amb@nightclub@peds@",
				["anim"] = "rcmme_amanda1_stand_loop_cop",
			},
		},
		[3] = {
			coord = vec4(662.6254, -548.7296, 14.0216, 241.0219),
			anim = {
				["dict"] = "anim@amb@nightclub@peds@",
				["anim"] = "rcmme_amanda1_stand_loop_cop",
			},
		},
		[4] = {
			coord = vec4(662.8275, -549.3780, 14.0273, 241.0219),
			anim = {
				["dict"] = "amb@world_human_stupor@male@idle_a",
				["anim"] = "idle_a",
			},
		},
		[5] = {
			coord = vec4(662.3732, -550.2469, 14.0379, 241.0219),
			anim = {
				["dict"] = "amb@world_human_stupor@male@idle_a",
				["anim"] = "idle_a",
			},
		},
	}
}

-- # Paintball Key Infos 
Config.KeyInfos = {
	{
		Key = "Z",
		Label = "Skor Tablosu",
	},
	{
		Key = "/qpb",
		Label = "Oyundan Çık",
	}
}

-- # Paintball Finish effect
Config.FinishEffects = {
	EffectUse = true,
    name = 'proj_indep_firework_v2', 
	child = 'scr_firework_indep_repeat_burst_rwb'
}

-- # Paintball Weapons Config
Config.PaintballWeapons = {
	["pistol"] = { -- no change or delete
		["localeKey"] = "weapon_pistol", -- no change
	},
	["rifle"] = { -- no change or delete
		["localeKey"] = "weapon_rifle", -- no change
	},
	["smg"] = { -- no change or delete
		["localeKey"] = "weapon_smg", -- no change
	},
	["pump"] = { -- no change or delete
		["localeKey"] = "weapon_pump", -- no change
	},
}

-- # Paintball Mods Config
Config.PaintballMods = {
	["TeamWipe"] = { -- delete or no change
		["localeKey"] = "gamemode_teamwipe", -- no change
	},
	["KillHunt"] = { -- delete or no change
		["localeKey"] = "gamemode_killhunt", -- no change
	},
	["RandomArsenal"] = { -- delete or no change
		["localeKey"] = "gamemode_randomarsenal", -- no change
	},
}

-- # Paintball Markers Config
Config.Markers = {
	PaintBall = {
		Type = 21,
		Size = {
			x = 1.0,
			y = 1.0,
			z = 0.5,
		},
		Color = {
			r = 39,
			g = 207,
			b = 120,
		},
	},
}

-- # Paintball Blips Config
Config.Blips = {
    Blips = true,
    PaintBall = {
		Sprite = 160,
		Scale = 0.7,
		Colour = 1,
    }
}

-- # Paintball Lobby Camera Config
Config.PaintballCam = {
    -- The target position where the camera will move to
    Target = vector3(666.461548, -549.454956, 15.024902),

    -- The direction the camera will face (heading/yaw)
    Heading = 61.36, -- 0 = north, 90 = east, 180 = south, 270 = west

    -- The up/down angle of the camera (pitch)
    Pitch = 0.0,    -- 0 = straight, positive = up, negative = down

    -- The tilt of the camera (roll)
    Roll = 0.0,     -- usually 0

    -- The height offset from the ground where the camera starts (for animation)
    StartZOffset = 5.0,

    -- The duration for the camera to move to the target (in ms)
    Duration = 2000
}