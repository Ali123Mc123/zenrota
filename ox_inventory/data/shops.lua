return {
	PoliceArmoury = {
		name = 'Teçhizat Deposu',
		groups = shared.police,
		inventory = {
			{ name = 'pd_kit',            price = 0 },
			{ name = 'WEAPON_FLASHLIGHT', price = 0, metadata = { registered = true } },
			{ name = 'WEAPON_NIGHTSTICK', price = 0, metadata = { registered = true } },
			{ name = 'WEAPON_TASERGUN',   price = 0, metadata = { registered = true } },
			{ name = 'WEAPON_BEANBAG',    price = 0, metadata = { registered = true } },
			-- { name = 'WEAPON_NIGHTGALE9', price = 0, metadata = { registered = true } },
			{ name = 'WEAPON_SW357', price = 0, metadata = { registered = true } },
			{ name = 'WEAPON_JNP_COMBAT_PISTOL', price = 0, metadata = { registered = true } },
			{ name = 'WEAPON_GRD6_BLACKSPIRE_PD', price = 0, metadata = { registered = true } },
			{ name = 'spikesbox', price = 0, metadata = { registered = true } },
			{ name = 'spikebox_pilot', price = 0, metadata = { registered = true } },
			{ name = 'placeable_gps', price = 0, metadata = { registered = true } },
			{ name = 'shootable_gps', price = 0, metadata = { registered = true } },
			{ name = 'WEAPON_GPSLAUNCHER', price = 0, metadata = { registered = true } },
			{ name = 'WEAPON_SMOK2GRENADE', price = 0, metadata = { registered = true } },
			{ name = 'WEAPON_FLASHBANG', price = 0, metadata = { registered = true } },
			{ name = "camo1",             price = 0 },
			{ name = "camo2",             price = 0 },
			{ name = "at_clip_extended_pistol",  price = 0 },
			{ name = "at_grip",  price = 0 },
			{ name = "at_scope",          price = 0 },
			{ name = "at_flashlight",     price = 0 },
			{ name = "at_suppressor",     price = 0 },
			{ name = 'pdmermisi',         price = 0 },
			{ name = 'ammo-beanbag',      price = 0 },
			{ name = 'handcuffs',         price = 0 },
			{ name = 'pd_radio',          price = 0 },
			{ name = 'bodycam',           price = 0 },
			{ name = 'megaphone',         price = 0 },
			{ name = 'drone_lspd',        price = 0 },
			{ name = 'tablet',            price = 0 },
			{ name = 'gps',               price = 0 },
			{ name = 'dashcam',           price = 0 },
			-- { name = 'grappler',          price = 0 },
			{ name = 'parachute',         price = 0 },
			{ name = 'pd_armour',         price = 0 },
			{ name = 'ifaks',             price = 0 },
			{ name = 'pd_redbull',        price = 0 },
			{ name = 'bandage',           price = 0 },
			{ name = 'pd_medikit',        price = 0 },
			{ name = 'water_bottle',      price = 10 },
			{ name = 'sandwich',          price = 10 },
		},
		locations = {
			-- vec3(126.0283, -351.7602, 38.9802), -- Alta PD (eski)
			vec3(481.2061, -995.2966, 30.6898), -- MRPD
			vec3(-3160.56, 1374.84, 20.85), -- SASP
			vec3(1834.92, 3695.9, 34.71), -- BCSO
			vec3(126.0283, -351.7602, 38.9802), -- SAPR, Alta PD (prev Park Ranger: vec3(385.4680, 799.8852, 190.4902); old: vec3(-821.48, 5399.39, 35.87))
			vec3(2808.0815, 4729.9355, 46.8922), -- PBSD
			vec3(-449.3957, 6015.1519, 36.9957),
			vec3(4378.5586, -4283.2319, 3.6494), -- CPPD
		},
		targets = {
			-- { -- Alta PD (eski)
			-- 	loc = vec3(126.0283, -351.7602, 38.9802),
			-- 	length = 1.5,
			-- 	width = 3.5,
			-- 	heading = 359.61,
			-- 	minZ = 38.0,
			-- 	maxZ = 41.0,
			-- 	distance = 4
			-- },
			{ -- MRPD
				loc = vec3(481.2061, -995.2966, 30.6898),
				length = 1.5,
				width = 3.5,
				heading = 359.73,
				minZ = 29.7,
				maxZ = 32.7,
				distance = 4
			},
			{
				loc = vec3(-3160.56, 1374.84, 20.85),
				length = 1.5,
				width = 3.5,
				heading = 359.61,
				minZ = 19.0,
				maxZ = 22.0,
				distance = 4
			},
			{
				loc = vec3(1834.92, 3695.9, 34.71),
				length = 1.5,
				width = 3.5,
				heading = 359.61,
				minZ = 33.0,
				maxZ = 36.0,
				distance = 4
			},
			{
				loc = vec3(126.0283, -351.7602, 38.9802), -- SAPR, Alta PD (prev: vec3(385.4680, 799.8852, 190.4902), heading 4.7847)
				length = 1.5,
				width = 3.5,
				heading = 359.61,
				minZ = 38.0,
				maxZ = 41.0,
				distance = 4
			},
			{
				loc = vec3(2808.0815, 4729.9355, 46.8922),
				length = 1.5,
				width = 3.5,
				heading = 0.98,
				minZ = 45.0,
				maxZ = 48.0,
				distance = 4
			},
			{
				loc = vec3(-449.3957, 6015.1519, 36.9957),
				length = 1.5,
				width = 3.5,
				heading = 47.6661,
				minZ = 35.0,
				maxZ = 37.0,
				distance = 4
			},
			{ -- CPPD
				loc = vec3(4378.5586, -4283.2319, 3.6494),
				length = 1.5,
				width = 2.0,
				heading = 79.55,
				minZ = 2.2,
				maxZ = 5.0,
				distance = 4
			},
		}
	},

	EMSArmoury = {
		name = 'Teçhizat Deposu',
		groups = {
			['ambulance'] = 0
		},
		inventory = {
			{ name = 'firstaid',         price = 0 },
			{ name = 'bandage',          price = 0 },
			{ name = 'painkillers',      price = 0 },
			{ name = 'pd_radio',         price = 0 },
			{ name = 'tsandalye',        price = 0 },
			{ name = 'sedye',            price = 0 },
			{ name = 'gps',              price = 0 },
			{ name = 'redbull',          price = 0 },
			{ name = 'megaphone',        price = 0 },
			{ name = 'tablet',           price = 0 },
			{ name = 'yanik_kremi',      price = 0 },
			{ name = 'agri_kesici',      price = 0 },
			{ name = 'kanama_durdurucu', price = 0 },
			{ name = 'adrenalin',        price = 0 },
			{ name = 'antiseptik',       price = 0 },
			{ name = 'pd_medikit',       price = 0 },
			{ name = 'water_bottle',     price = 10 },
			{ name = 'sandwich',         price = 10 },
		},
		locations = {
			vector3(1135.89, -1542.83, 34.03), -- 
			vector3(600.9829, 2766.6533, 43.5551) -- orta kasaba
		},
		targets = {
			{
				loc = vector3(1135.89, -1542.83, 34.03),
				length = 0.5,
				width = 7.0,
				heading = 268.95,
				minZ = 33.03,
				maxZ = 35.5,
				distance = 5
			},
			{ 	-- orta kasaba vector4(600.9055, 2766.6001, 43.5550, 288.7740)
				loc = vector3(600.9055, 2766.6001, 43.5550),
				length = 0.5,
				width = 7.0,
				heading = 288.7740,
				minZ = 42.5,
				maxZ = 43.5,
				distance = 5
			},
		}
	},

	DojArmoury = {
		name = 'Teçhizat Deposu',
		groups = {
			['doj'] = 0
		},
		inventory = {
			{ name = 'WEAPON_FLASHLIGHT', price = 0, metadata = { registered = true } },
			{ name = 'WEAPON_TASERGUN',   price = 0, metadata = { registered = true } },
			{ name = 'handcuffs',         price = 0 },
			{ name = 'pd_radio',          price = 0 },
			{ name = 'bodycam',           price = 0 },
			{ name = 'megaphone',         price = 0 },
			{ name = 'tablet',            price = 0 },
			{ name = 'gps',               price = 0 },
			{ name = 'dashcam',           price = 0 },
			{ name = 'parachute',         price = 0 },
			{ name = 'bandage',           price = 0 },
			{ name = 'pd_medikit',        price = 0 },
			{ name = 'water_bottle',      price = 10 },
			{ name = 'sandwich',          price = 10 },
		},
		locations = {
			vector3(-538.5514, -196.8854, 42.3659),
		},
		targets = {
			{
				loc = vec3(-538.5514, -196.8854, 42.3659),
				length = 1.5,
				width = 3.5,
				heading = 118.0171,
				minZ = 41.0,
				maxZ = 43.0,
				distance = 4
			},
		}
	},

	blackmarket1 = {
		name = 'Karaborsa',
		groups = {
			['blackmarket1'] = 0
		},
		inventory = {
			{ name = 'lockpick',             price = 50 },
			{ name = 'drill',                price = 50 },
			{ name = 'medikit',              price = 25 },
			{ name = 'redbull',              price = 25 },
			{ name = 'oiltank',              price = 750 },
			{ name = 'nail_bag',             price = 125 },
			{ name = 'handcuffs',            price = 125 },
			{ name = 'illegal_tablet',       price = 250 },
			{ name = 'headbag',              price = 250 },
			{ name = 'ropehook',             price = 50 },
			{ name = 'weapon_crowbar',       price = 50 },
			{ name = 'weapon_digiscanner',   price = 50 },
			-- { name = 'powdered_milk',        price = 10 },
			{ name = 'atm_hack_device',      price = 25 },
			{ name = 'blank_card',           price = 5 },
			{ name = 'fakeplate',            price = 2500 },
			-- { name = 'moonshine_still',      price = 50 },
			-- { name = 'moonshine_pack',       price = 50 },
			{ name = 'wirecutters',          price = 125 },
			{ name = 'racingtablet',         price = 1250 },
			{ name = 'acetone',              price = 25 },
			{ name = 'neonkit',              price = 250 },
			{ name = 'neonremote',           price = 250 },
			{ name = 'nitrous_install_kit',  price = 750 },
			{ name = 'empty_nitrous_bottle', price = 125 },
			{ name = 'nitrous_bottle',       price = 250 },
			{ name = 'spraycan',             price = 25 },
			{ name = 'thermite',             price = 750 },
			{ name = 'gasmask',              price = 1000 },
			{ name = 'c4',                   price = 2500 },
			{ name = 'WEAPON_WELD',          price = 125 },
			{ name = "screwdriverset",       price = 25 },
			{ name = "awd_drivetrain",       price = 1800 },
			{ name = "rwd_drivetrain",       price = 1300 },
			{ name = "fwd_drivetrain",       price = 1050 },
			{ name = "slick_tyres",          price = 550 },
			{ name = "semi_slick_tyres",     price = 300 },
			{ name = "offroad_tyres",        price = 50 },
			{ name = "ceramic_brakes",       price = 4800 },
			{ name = "drift_tuning_kit",     price = 1300 },
			{ name = "lighting_controller",  price = 275 },
			{ name = "stancing_kit",         price = 800 },
			{ name = "v12_engine",           price = 10000 },
			{ name = "tyre_smoke_kit",       price = 1000 },
		},
	},

	blackmarket2 = {
		name = 'Karaborsa',
		groups = {
			['blackmarket2'] = 0
		},
		inventory = {
			{ name = 'lockpick',             price = 50 },
			{ name = 'drill',                price = 50 },
			{ name = 'medikit',              price = 25 },
			{ name = 'redbull',              price = 25 },
			{ name = 'oiltank',              price = 750 },
			{ name = 'nail_bag',             price = 125 },
			{ name = 'handcuffs',            price = 125 },
			{ name = 'illegal_tablet',       price = 250 },
			{ name = 'headbag',              price = 250 },
			{ name = 'ropehook',             price = 50 },
			{ name = 'weapon_crowbar',       price = 50 },
			{ name = 'weapon_digiscanner',   price = 50 },
			-- { name = 'powdered_milk',        price = 10 },
			{ name = 'atm_hack_device',      price = 25 },
			{ name = 'blank_card',           price = 5 },
			{ name = 'fakeplate',            price = 2500 },
			-- { name = 'moonshine_still',      price = 50 },
			-- { name = 'moonshine_pack',       price = 50 },
			{ name = 'wirecutters',          price = 125 },
			{ name = 'racingtablet',         price = 1250 },
			{ name = 'acetone',              price = 25 },
			{ name = 'neonkit',              price = 250 },
			{ name = 'neonremote',           price = 250 },
			{ name = 'nitrous_install_kit',  price = 750 },
			{ name = 'empty_nitrous_bottle', price = 125 },
			{ name = 'nitrous_bottle',       price = 250 },
			{ name = 'spraycan',             price = 25 },
			{ name = 'thermite',             price = 750 },
			{ name = 'gasmask',              price = 1000 },
			{ name = 'c4',                   price = 2500 },
			{ name = 'WEAPON_WELD',          price = 125 },
			{ name = "screwdriverset",       price = 25 },
			{ name = "awd_drivetrain",       price = 1800 },
			{ name = "rwd_drivetrain",       price = 1300 },
			{ name = "fwd_drivetrain",       price = 1050 },
			{ name = "slick_tyres",          price = 550 },
			{ name = "semi_slick_tyres",     price = 300 },
			{ name = "offroad_tyres",        price = 50 },
			{ name = "ceramic_brakes",       price = 4800 },
			{ name = "drift_tuning_kit",     price = 1300 },
			{ name = "lighting_controller",  price = 275 },
			{ name = "stancing_kit",         price = 800 },
			{ name = "v12_engine",           price = 10000 },
			{ name = "tyre_smoke_kit",       price = 1000 },
		},
	},

	lojistik1 = {
		name = 'Lojistik 1',
		groups = {
			['lojistik1'] = 0,
		},
		inventory = {
			{ name = 'WEAPON_BASEBALL_SLAYER',    price = 5000 },
			-- { name = 'weapon_poolcue',         price = 4250 },
			-- { name = 'weapon_oppslugger',      price = 5000 },
			-- { name = 'WEAPON_SCREWD',          price = 9250 },
			-- { name = 'WEAPON_BLACKKNIFE',      price = 8000 },
			-- { name = 'WEAPON_BLUEKNIFE',       price = 8000 },
			-- { name = 'WEAPON_GRAYKNIFE',       price = 8000 },
			-- { name = 'WEAPON_GREENKNIFE',      price = 8000 },
			-- { name = 'WEAPON_ORANGEKNIFE',     price = 8000 },
			-- { name = 'WEAPON_PINKKNIFE',       price = 8000 },
			-- { name = 'WEAPON_PURPLEKNIFE',     price = 8000 },
			-- { name = 'WEAPON_REDKNIFE',        price = 8000 },
			-- { name = 'WEAPON_YELLOWKNIFE',     price = 8000 },
			-- { name = 'WEAPON_WHITEKNIFE',      price = 8000 },
			-- { name = 'WEAPON_SWITCHBLADE',     price = 15000 },
			-- { name = "WEAPON_MX18_CLASSYBLUE", price = 20000 },
			-- { name = "WEAPON_REVOLVER_WHITY",  price = 25000 },
			-- { name = "WEAPON_DN22_FUSION",     price = 30000 },
		 	-- { name = "WEAPON_ST84_SKULLNSWORD",     price = 50000 },
			-- { name = "WEAPON_TACTICAL_BUTTERFLY",     price = 10000 },
			-- { name = "WEAPON_CAMOLAND_KNIFE",     price = 10000 },
			-- { name = "WEAPON_PY_GP",            price = 33000 },
			-- { name = "WEAPON_GHOSTG30",         price = 60000 },
			-- { name = "WEAPON_DN22_FUSION",         price = 60000 },
			-- { name = "WEAPON_DRACO_YELLOW_DRIP",   price = 75000 },
			-- { name = "at_suppressor",     	price = 2500 },
			-- { name = "at_clip_extended",     	price = 5000 },
			-- { name = "at_scope",     			price = 500 },
			-- { name = "ammo-9",                 	price = 25 },
			-- { name = "armour",                 	price = 100 },
			-- { name = "camo1",                 	price = 500 },
			-- { name = "camo2",                 	price = 500 },
		},
	},

	lojistik2 = {
		name = 'Lojistik 2',
		groups = {
			['lojistik2'] = 0,
		},
		inventory = {
			{ name = 'WEAPON_BASEBALL_SLAYER',    price = 5000 },
			-- { name = 'weapon_poolcue',         price = 4250 },
			-- { name = 'weapon_oppslugger',      price = 5000 },
			-- { name = 'WEAPON_SCREWD',          price = 9250 },
			-- { name = 'WEAPON_BLACKKNIFE',      price = 8000 },
			-- { name = 'WEAPON_BLUEKNIFE',       price = 8000 },
			-- { name = 'WEAPON_GRAYKNIFE',       price = 8000 },
			-- { name = 'WEAPON_GREENKNIFE',      price = 8000 },
			-- { name = 'WEAPON_ORANGEKNIFE',     price = 8000 },
			-- { name = 'WEAPON_PINKKNIFE',       price = 8000 },
			-- { name = 'WEAPON_PURPLEKNIFE',     price = 8000 },
			-- { name = 'WEAPON_REDKNIFE',        price = 8000 },
			-- { name = 'WEAPON_YELLOWKNIFE',     price = 8000 },
			-- { name = 'WEAPON_WHITEKNIFE',      price = 8000 },
			-- { name = 'WEAPON_SWITCHBLADE',     price = 15000 },
			-- { name = "WEAPON_MX18_CLASSYBLUE", price = 20000 },
			-- { name = "WEAPON_REVOLVER_WHITY",  price = 25000 },
			-- { name = "WEAPON_DN22_FUSION",     price = 30000 },
			-- { name = "WEAPON_ST84_SKULLNSWORD",     price = 50000 },
			-- { name = "WEAPON_TACTICAL_BUTTERFLY",     price = 10000 },
			-- { name = "WEAPON_CAMOLAND_KNIFE",     price = 10000 },
			-- { name = "WEAPON_PY_GP",           price = 33000 },
			-- { name = "WEAPON_GHOSTG30",         price = 60000 },
			-- { name = "WEAPON_DN22_FUSION",         price = 60000 },
			-- { name = "WEAPON_DRACO_YELLOW_DRIP",   price = 75000 },
			-- { name = "at_suppressor",     	price = 2500 },
			-- { name = "at_clip_extended",     	price = 5000 },
			-- { name = "at_scope",     			price = 500 },
			-- { name = "ammo-9",                 	price = 25 },
			-- { name = "armour",                 	price = 100 },
			-- { name = "camo1",                 	price = 500 },
			-- { name = "camo2",                 	price = 500 },
		},
	},

	belediye = {
		name = 'Belediye', -- DaddyRP: haritada blip yok
		inventory = {
			{ name = 'id_card',        price = 10 },
			{ name = 'driver_license', price = 10 },
		},
		locations = {
			vector3(-548.0204, -209.3649, 36.6498)
		},
		targets = {
			{
				ped = 'a_m_m_business_01',
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vector3(-548.0204, -209.3649, 36.6498),
				heading = 207.6364,
				distance = 3.5
			},
		}
	},

	torbaci1 = {
		name = 'Torbacı',
		groups = {
			['torbaci1'] = 0,
		},
		inventory = {
			{ name = 'tacir1_key',      price = 1 },
			{ name = 'tacir2_key',      price = 1 },
			{ name = 'tacir3_key',      price = 1 },
			{ name = 'moonshine_still', price = 50 },
			{ name = 'moonshine_pack',  price = 50 },
			{ name = 'plant_spray',     price = 1 },
			{ name = 'powdered_milk',   price = 1 },
			{ name = 'ammonia',         price = 1 },
			{ name = 'sacid',           price = 1 },
		},
	},

	torbaci2 = {
		name = 'Torbacı', 
		groups = {
			['torbaci2'] = 0,
		},
		inventory = {
			{ name = 'tacir1_key',      price = 1 },
			{ name = 'tacir2_key',      price = 1 },
			{ name = 'tacir3_key',      price = 1 },
			{ name = 'moonshine_still', price = 50 },
			{ name = 'moonshine_pack',  price = 50 },
			{ name = 'plant_spray',     price = 1 },
			{ name = 'powdered_milk',   price = 1 },
			{ name = 'ammonia',         price = 1 },
			{ name = 'sacid',           price = 1 },
		},
	},

	torbaci3 = {
		name = 'Torbacı',
		groups = {
			['torbaci3'] = 0,
		},
		inventory = {
			{ name = 'tacir1_key',      price = 1 },
			{ name = 'tacir2_key',      price = 1 },
			{ name = 'tacir3_key',      price = 1 },
			{ name = 'moonshine_still', price = 50 },
			{ name = 'moonshine_pack',  price = 50 },
			{ name = 'plant_spray',     price = 1 },
			{ name = 'powdered_milk',   price = 1 },
			{ name = 'ammonia',         price = 1 },
			{ name = 'sacid',           price = 1 },
		},
	},

	weedshop1 = {
		name = 'Ot Dükkanı',
		groups = {
			['weedshop1'] = 0,
		},
		inventory = {
			{ name = 'nane',              price = 250 },
			{ name = 'meth',              price = 500 },
			{ name = 'koko',              price = 500 },
			{ name = 'antidote_koko',     price = 2000 },
			{ name = 'antidote_weed',     price = 2000 },
			{ name = 'antidote_meth',     price = 2000 },
			{ name = 'antidote_nostress', price = 2000 },
			{ name = 'antidote_cigar', 	  price = 10000 },
		},
		locations = {
			vec3(-76.9077, 369.9113, 112.4583),
		},
		targets = {
			{
				ped = 'a_m_m_soucent_04',
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-76.9077, 369.9113, 112.4583),
				heading = 115.1704,
				distance = 2.5
			},
		}
	},

	weedshop2 = {
		name = 'Ot Dükkanı',
		groups = {
			['weedshop2'] = 0,
		},
		inventory = {
			{ name = 'nane',              price = 250 },
			{ name = 'meth',              price = 500 },
			{ name = 'koko',              price = 500 },
			{ name = 'antidote_koko',     price = 2000 },
			{ name = 'antidote_weed',     price = 2000 },
			{ name = 'antidote_meth',     price = 2000 },
			{ name = 'antidote_nostress', price = 2000 },
			{ name = 'antidote_cigar', 	  price = 10000 },
		},
		locations = {
			vec3(755.8140, -1864.3645, 28.2938),
		},
		targets = {
			{
				ped = 'a_m_m_soucent_04',
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(755.8140, -1864.3645, 28.2938),
				heading = 261.6802,
				distance = 2.5
			},
		}
	},

	hush = {
		name = 'Hush Deposu',
		inventory = {
			{ name = 'cigar',              price = 1000 },
		},
		locations = {
			vec3(1319.0748, -3158.6387, -20.0182),
		},
		targets = {
			{
				prop = 'prop_mil_crate_01',
				loc = vector3(1319.0748, -3158.6387, -20.0182),
				heading = 244.1928,
				distance = 2.5
			},
		}
	},

	kolej_kantin = {
		name = 'Kolej Kantini', -- sadece Kantin ve Temizlik (kantin) mesleği alabilir
		groups = {
			['kantin'] = 0,
		},
		inventory = {
			{ name = 'kantin_tost',          price = 25 },
			{ name = 'kantin_sandvic',       price = 35 },
			{ name = 'kantin_sosisli',       price = 30 },
			{ name = 'kantin_pizza_dilimi',  price = 35 },
			{ name = 'kantin_hamburger',     price = 45 },
			{ name = 'kantin_nugget',        price = 35 },
			{ name = 'kantin_patates',       price = 20 },
			{ name = 'kantin_kruvasan',      price = 20 },
			{ name = 'kantin_pretzel',       price = 15 },
			{ name = 'kantin_cikolata',      price = 15 },
			{ name = 'kantin_donut',         price = 20 },
			{ name = 'kantin_portakal_suyu', price = 15 },
			{ name = 'kantin_seftali_suyu',  price = 15 },
			{ name = 'kantin_kola',          price = 15 },
			{ name = 'kantin_cay',           price = 10 },
			-- daddy_campuslife kantininin yemek dışı ürünleri (kantin orada kapatıldı)
			{ name = 'school_notebook',      price = 30 },
			{ name = 'student_tablet',       price = 100 },
			{ name = 'student_phone',        price = 150 },
			{ name = 'skateboard',           price = 1000 },
			{ name = 'bmx',                  price = 1000 },
		},
		locations = {
			vec3(5364.5967, -5232.3359, 31.0375),
		},
		targets = {
			{
				ped = 's_m_m_linecook',
				scenario = 'WORLD_HUMAN_CLIPBOARD',
				loc = vec3(5364.5967, -5232.3359, 31.0375),
				heading = 324.3078,
				distance = 2.5
			},
		}
	},
}
