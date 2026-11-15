return {
	['black_money'] = {
		label = 'Kara Para',
	},

	['money'] = {
		label = 'Nakit Para',
	},

	['id_card'] = {
		label = 'Kimlik',
	},

	['driver_license'] = {
		label = 'Ehliyet',
	},

	['weaponlicense'] = {
		label = 'Silah Ruhsatı',
	},

	['lawyerpass'] = {
		label = 'Avukat Kimliği',
	},

	["gps"] = {
		label = "GPS",
		weight = 500,
		client = {
			export = 'daddy-gps.open',
		},
	},

	['water_bottle'] = {
		label = 'Su',
		weight = 500,
		client = {
			status = { thirst = 350000, },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle', },
			prop = { model = `bzzz_food_dino_drink_a`, pos = vec3(0.01, 0.01, 0.08), rot = vec3(0.0, 0.0, 0.0), },
			usetime = 6000,
			cancel = true,
		}
	},

	['sandwich'] = {
		label = 'Sandviç',
		weight = 200,
		client = {
			status = { hunger = 500000, },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger', },
			prop = { model = `bzzz_food_bakery_toast_a`, pos = vec3(0.02, 0.0, -0.01), rot = vec3(-80.0, 0.0, 0.0), },
			usetime = 8000,
			cancel = true,
		}
	},

	['parachute'] = {
		label = 'Paraşüt',
		weight = 1000,
		stack = true,
		close = true,
	},

	['megaphone'] = {
		label = 'Megafon',
		weight = 1000,
		stack = true,
		close = true,
	},

	['microphone'] = {
		label = 'Mikrofon',
		weight = 500,
		stack = false,
		close = true,
		description = 'Konuşurken sesinizi amfiye ve uzak mesafeye ileten el mikrofonu.',
	},

	['phone'] = {
		label = 'Telefon',
		weight = 250,
		stack = false,
		close = true,
	},

	['drone_lspd'] = {
		label = 'PD Drone',
		weight = 1000,
		stack = false,
		close = true,
		groups = {
			['leo'] = 0,
			['doj'] = 0,
		},
		degrade = 10080,
		decay = true
	},

	['drone'] = {
		label = 'Drone',
		weight = 1000,
		stack = false,
		close = true,
		degrade = 10080,
		decay = true
	},

	['armour'] = {
		label = 'Çelik Yelek',
		weight = 100,
		stack = true,
		close = true,
		allowArmed = true,
	},

	['pd_armour'] = {
		label = 'Polis Yeleği',
		weight = 100,
		stack = true,
		close = true,
		allowArmed = true,
		groups = {
			['leo'] = 0,
			['doj'] = 0,
		}
	},

	['radio'] = {
		label = 'Radyo',
		weight = 500,
		stack = true,
		allowArmed = true
	},

	['pd_radio'] = {
		label = 'L. Radyo',
		weight = 500,
		stack = true,
		allowArmed = true,
	},

	['ems_radio'] = {
		label = 'EMS Radyo',
		weight = 500,
		stack = true,
		allowArmed = true,
	},

	['tablet'] = {
		label = 'Tablet',
		weight = 1000,
		stack = true,
		close = true,
	},

	['carsale_mdt'] = {
		label = 'Araç Satış Tableti',
		weight = 1000,
		stack = false,
		close = true,
		client = {
			event = 'p_carsale/client/toggleTablet'
		}
	},

	['hackusb'] = {
		label = 'Hack USB',
		weight = 100,
		stack = false,
		close = true,
	},

	['cryptowallet'] = {
		label = 'Kripto Cüzdan',
		weight = 100,
		stack = false,
		close = true,
		client = {
			export = 'can9work-base.cryptowallet'
		}
	},

	['ethereum'] = {
		label = 'Ethereum',
		weight = 100,
		stack = true,
		close = true,
	},

	['bitcoin'] = {
		label = 'Bitcoin',
		weight = 100,
		stack = true,
		close = true,
	},

	['ripple'] = {
		label = 'Ripple',
		weight = 100,
		stack = true,
		close = true,
	},

	['dogecoin'] = {
		label = 'Dogecoin',
		weight = 100,
		stack = true,
		close = true,
	},

	['militaryusb'] = {
		label = 'Askeri USB',
		weight = 100,
		stack = false,
		close = true,
	},

	['security_card_02'] = {
		label = 'Güvenlik Kartı Seviye 2',
		weight = 50,
		stack = false,
		close = true,
	},

	['security_card_01'] = {
		label = 'Güvenlik Kartı Seviye 1',
		weight = 50,
		stack = false,
		close = true,
	},

	['vehicle_contract'] = {
		label = 'Araç Sözleşmesi',
		weight = 10,
		stack = false,
		close = true,
		consume = 0,
		client = {
			event = 'p_carsale/client_job/useDocument'
		},
	},

	['ifaks'] = {
		label = 'Ifaks',
		weight = 1000,
		stack = true,
		close = true,
		allowArmed = true,
	},

	['bandage'] = {
		label = 'Bandaj',
		weight = 1000,
		stack = true,
		close = true,
		allowArmed = true,
	},

	['painkillers'] = {
		label = 'Ağrı Kesici',
		weight = 1000,
		stack = true,
		close = true,
	},

	['firstaid'] = {
		label = 'İlk Yardım Çantası',
		weight = 1000,
		stack = true,
		close = true,
		groups = {
			['ambulance'] = 0,
		}
	},

	['medikit'] = {
		label = 'Medikit',
		weight = 500,
		stack = true,
		close = true,
		allowArmed = true,
	},

	['pd_medikit'] = {
		label = 'Polis Medikit',
		weight = 500,
		stack = true,
		close = true,
		allowArmed = true,
		groups = {
			['ambulance'] = 0,
			['leo'] = 0,
			['doj'] = 0,
		}
	},

	['lockpick'] = {
		label = 'Basit Maymuncuk',
		weight = 500,
		stack = true,
		close = true,
	},

	['advancedlockpick'] = {
		label = 'Gelişmiş Maymuncuk',
		weight = 500,
		stack = true,
		close = true,
	},

	['handcuffs'] = {
		label = 'Kelepçe',
		weight = 1000,
		stack = true,
		close = true,
		allowArmed = true,
	},

	['bodycam'] = {
		label = 'Vücut Kamerası',
		weight = 100,
		stack = false,
		close = true,
		client = {
			event = 'spy-bodycam:bodycamstatus'
		}
	},

	['dashcam'] = {
		label = 'Araç Kamerası',
		weight = 500,
		stack = false,
		close = true,
		client = {
			event = 'spy-bodycam:toggleCarCam'
		}
	},

	['vision_bodycam'] = {
		label = 'Daddy Vision Vücut Kamerası',
		description = 'Görev sırasında vücuda takılan profesyonel kamera.',
		weight = 350,
		stack = false,
		close = true,
		consume = 0,
		server = { export = 'daddy-bodycam.UseDeviceItem' },
	},

	['vision_dashcam'] = {
		label = 'Daddy Vision Araç Kamerası',
		description = 'Devriye araçları için ön ve arka görüş kamera sistemi.',
		weight = 900,
		stack = false,
		close = true,
		consume = 0,
		server = { export = 'daddy-bodycam.UseDeviceItem' },
	},

	['vision_actioncam'] = {
		label = 'Daddy Vision Aksiyon Kamerası',
		description = 'Kask, göğüs ve omuz bağlantılarını destekleyen aksiyon kamerası.',
		weight = 300,
		stack = false,
		close = true,
		consume = 0,
		server = { export = 'daddy-bodycam.UseDeviceItem' },
	},

	['vision_tripod'] = {
		label = 'Daddy Vision Tripod',
		description = 'Sabit yayın ve olay takibi için taşınabilir kamera tripodu.',
		weight = 3500,
		stack = false,
		close = true,
		consume = 0,
		server = { export = 'daddy-bodycam.UseDeviceItem' },
	},

	['vision_drone'] = {
		label = 'Daddy Vision Drone',
		description = 'Havadan görüntüleme ve operasyon desteği sağlayan kamera droneu.',
		weight = 2500,
		stack = false,
		close = true,
		consume = 0,
		server = { export = 'daddy-bodycam.UseDeviceItem' },
	},

	['grappler'] = {
		label = 'Lastik Kancası',
		weight = 220,
	},

	["auction_tablet"] = {
		label = "İhale Terminali",
		weight = 1000,
		stack = false,
		client = {
			export = 'can9work-auction.OpenAuctionTablet',
		}
	},

	["auction_certificate"] = {
		label = "Mülkiyet Belgesi",
		weight = 1000,
		stack = false,
		close = true,
		client = {
			export = 'can9work-auction.OpenCertificate',
		}
	},

	["redbull"] = {
		label = "Enerji İçeceği",
		weight = 100,
		stack = true,
		close = true,
		allowArmed = true,
	},

	["pd_redbull"] = {
		label = "Polis Enerji İçeceği",
		weight = 100,
		stack = true,
		close = true,
		allowArmed = true,
		groups = {
			['leo'] = 0,
			['doj'] = 0,
		}
	},
	
	['sigara'] = {
		label = 'Sigara',
		stack = true,
		weight = 115,
		allowArmed = true,
	},

	['lighter'] = {
		label = 'Çakmak',
		weight = 200,
	},

	['empty_evidence_bag'] = {
		label = 'Boş Delil Poşeti',
		weight = 200,
	},

	['filled_evidence_bag'] = {
		label = 'Dolu Delil Poşeti',
		weight = 200,
	},

	['camera'] = {
		label = 'Fotoğraf Makinesi',
		weight = 1000,
		stack = false,
		close = true,
	},

	["koko"] = { label = "Şeker", weight = 1000, stack = true, allowArmed = true, },
	["meth"] = { label = "Kristal", weight = 1000, stack = true, allowArmed = true, },
	["weed"] = { label = "Çürük Nane", weight = 1000, stack = true, allowArmed = true, },
	["nane"] = { label = "Nane", weight = 1000, stack = true, allowArmed = true, client = { client = { image = "weed.png" } } },
	["nostress"] = { label = "No Stress", weight = 1000, stack = true, allowArmed = true, },
	['antidote_weed'] = { label = 'Nane Panzehiri', weight = 2000, stack = true, close = true },
	['antidote_koko'] = { label = 'Şeker Panzehiri', weight = 2000, stack = true, close = true },
	['antidote_meth'] = { label = 'Kristal Panzehiri', weight = 2000, stack = true, close = true },
	['antidote_nostress'] = { label = 'No Stress Panzehiri', weight = 2000, stack = true, close = true },

	['tibbi_kit'] = {
		label = "Tıbbi Kit",
		weight = 1000,
		stack = true,
		close = true,
		allowArmed = true,
		client = { client = { image = "medkit.png" } }
	},

	['polaroid'] = { label = 'Polaroid Fotoğraf', weight = 1000, stack = true, close = true },
	['polaroid_empty'] = { label = 'Boş Polaroid', weight = 1000, stack = true, close = true },

	['racingtablet'] = {
		label = 'Yarış Tableti',
		weight = 2000,
		stack = false,
		client = {
			export = 'rahe-racing.racingtablet',
		}
	},

	['backpack'] = {
		label = 'Sırt Çantası',
		weight = 220,
		stack = false,
		consume = 0,
		client = {
			export = 'wasabi_backpack.openBackpack'
		}
	},

	['sedye'] = {
		label = 'Sedye',
		weight = 8000,
		stack = false,
		close = true,
	},

	['tsandalye'] = {
		label = 'Tekerlekli Sandalye',
		weight = 6000,
		stack = false,
		close = true,
	},

	['torture_chair'] = {
		label = 'İşkence Sandalyesi',
		weight = 10000,
		stack = false,
	},

	['torture_wrench'] = {
		label = 'İşkence Anahtarı',
		weight = 1000,
		stack = false,
	},

	['torture_pliers'] = {
		label = 'İşkence Pense',
		weight = 1000,
		stack = false,
	},

	['torture_electrocute'] = {
		label = 'Elektrik Şoku',
		weight = 500,
		stack = false,
	},

	['torture_syringe'] = {
		label = 'İşkence Şırıngası',
		weight = 3000,
		stack = false,
	},

	['torture_petrolcan'] = {
		label = 'İşkence Benzin',
		weight = 3000,
		stack = false,
	},

	["rm_car_1"] = {
		label  = "RC Araba 1",
		weight = 5000,
		stack  = true,
		close  = true,
	},

	["rm_car_2"] = {
		label  = "RC Araba 2",
		weight = 5000,
		stack  = true,
		close  = true,
	},

	["rm_car_3"] = {
		label  = "RC Araba 3",
		weight = 5000,
		stack  = true,
		close  = true,
	},

	["rm_car_dumps"] = {
		label  = "RC Araba Dumps",
		weight = 5000,
		stack  = true,
		close  = true,
	},

	["rm_car_grc86gt"] = {
		label  = "RC Araba GRC86GT",
		weight = 5000,
		stack  = true,
		close  = true,
	},

	["rm_car_599xx"] = {
		label  = "RC Araba 599XX",
		weight = 5000,
		stack  = true,
		close  = true,
	},

	["rm_car_truck"] = {
		label  = "RC Kamyon",
		weight = 5000,
		stack  = true,
		close  = true,
	},

	["rm_car_monster"] = {
		label  = "RC Araba Monster",
		weight = 5000,
		stack  = true,
		close  = true,
	},

	["rm_car_ruiner"] = {
		label  = "RC Araba Ruiner",
		weight = 5000,
		stack  = true,
		close  = true,
	},

	["rm_car_sultanrs"] = {
		label  = "RC Araba Sultan RS",
		weight = 5000,
		stack  = true,
		close  = true,
	},

	["rm_car_camera"] = {
		label  = "RC Araba Kamerası",
		weight = 5000,
		stack  = true,
		close  = true,
	},

	["rm_car_van"] = {
		label  = "RC Minibüs",
		weight = 5000,
		stack  = true,
		close  = true,
	},

	["rm_car_toystory"] = {
		label  = "RC Oyuncak Araba",
		weight = 5000,
		stack  = true,
		close  = true,
	},

	["rm_car_flame"] = {
		label  = "RC Araba Flame",
		weight = 5000,
		stack  = true,
		close  = true,
	},

	["oiltank"] = {
		label = 'Yağ Tankı',
		weight = 2000,
		useable = true,
		shouldClose = true,
		stack = false,
	},

	["oil_bottle"] = {
		label = 'Yağ Şişesi',
		weight = 100,
		useable = true,
		shouldClose = true,
	},

	["nail_bag"] = {
		label = 'Çivi Torbası',
		weight = 100,
		useable = true,
		shouldClose = true,
	},

	["fire_extinguisher"] = {
		label = 'Yangın Söndürücü (Tuzak)',
		weight = 1000,
		useable = true,
		shouldClose = true,
	},

	['boombox_a'] = {
		label = 'Büyük Hoparlör',
		weight = 8000,
		stack = false,
		close = true,
		server = {
			export = 'wais-speaker.placeBoombox'
		}
	},

	['boombox_f'] = {
		label = 'Yer Hoparlörü',
		weight = 7500,
		stack = false,
		close = true,
		server = {
			export = 'wais-speaker.placeBoombox'
		}
	},

	['boombox_b'] = {
		label = 'Taşınabilir Teyp',
		weight = 2500,
		stack = false,
		close = true,
		server = {
			export = 'wais-speaker.placeBoombox'
		}
	},

	['boombox_c'] = {
		label = 'Taşınabilir Hoparlör',
		weight = 2500,
		stack = false,
		close = true,
		server = {
			export = 'wais-speaker.placeBoombox'
		}
	},

	['event_box'] = {
		label = 'Etkinlik Kutusu',
		weight = 500,
		stack = true,
		close = true,
		client = {
			export = 'can9work-base.eventbox'
		}
	},

	['tacir1_key'] = {
		label = 'Pembe Anahtar',
		weight = 500,
		stack = true,
		close = true,
		degrade = 4320, -- 3 gün
	},

	['tacir2_key'] = {
		label = 'Mor Anahtar',
		weight = 500,
		stack = true,
		close = true,
		decay = true,
		degrade = 4320, -- 3 gün
	},

	['tacir3_key'] = {
		label = 'Turuncu Anahtar',
		weight = 500,
		stack = true,
		close = true,
		decay = true,
		degrade = 4320, -- 3 gün
	},

	['boombox_d'] = {
		label = 'El Radyosu',
		weight = 1500,
		stack = false,
		close = true,
		server = {
			export = 'wais-speaker.placeBoombox'
		}
	},

	['boombox_e'] = {
		label = 'Mini Hoparlör',
		weight = 1000,
		stack = false,
		close = true,
		server = {
			export = 'wais-speaker.placeBoombox'
		}
	},

	["car_play"] = {
		label = "Araç Müzik Sistemi",
		weight = 1000,
		stack = false,
		close = true,
		server = {
			export = 'wais-speaker.installCarSpeaker'
		}
	},

	-- [[ AVCILIK: wais-hunting ]] --

	['boar_meat'] = {
		label = 'Yaban Domuzu Eti',
		weight = 500,
		stack = true,
	},

	['boar_skin'] = {
		label = 'Yaban Domuzu Postu',
		weight = 300,
		stack = true,
	},

	['boar_tusk'] = {
		label = 'Yaban Domuzu Dişi',
		weight = 100,
		stack = true,
	},

	['pig_meat'] = {
		label = 'Domuz Eti',
		weight = 500,
		stack = true,
	},

	['pig_skin'] = {
		label = 'Domuz Postu',
		weight = 300,
		stack = true,
	},

	['pig_feet'] = {
		label = 'Domuz Paçası',
		weight = 150,
		stack = true,
	},

	['rabbit_meat'] = {
		label = 'Tavşan Eti',
		weight = 200,
		stack = true,
	},

	['rabbit_skin'] = {
		label = 'Tavşan Postu',
		weight = 100,
		stack = true,
	},

	['rabbit_feet'] = {
		label = 'Tavşan Ayağı',
		weight = 50,
		stack = true,
	},

	['mtlion_meat'] = {
		label = 'Dağ Aslanı Eti',
		weight = 800,
		stack = true,
	},

	['mtlion_skin'] = {
		label = 'Dağ Aslanı Postu',
		weight = 600,
		stack = true,
	},

	['deer_meat'] = {
		label = 'Geyik Eti',
		weight = 600,
		stack = true,
	},

	['deer_skin'] = {
		label = 'Geyik Postu',
		weight = 400,
		stack = true,
	},

	['deer_horns'] = {
		label = 'Geyik Boynuzu',
		weight = 300,
		stack = true,
	},

	-- [[ PAWNSHOP: Çalıntı Eşyalar ]] --

	['stolen_micro_01'] = { label = 'Çalıntı Mikro Dalga 1', weight = 3000, stack = false, rarity = "Rare" },
	['stolen_micro_02'] = { label = 'Çalıntı Mikro Dalga 2', weight = 3000, stack = false, rarity = "Rare" },
	['stolen_vcr_01'] = { label = 'Çalıntı VCR', weight = 2000, stack = false, rarity = "Rare" },
	['stolen_tv_03'] = { label = 'Çalıntı TV', weight = 5000, stack = false, rarity = "Rare" },
	['stolen_tv_flat_03'] = { label = 'Çalıntı Düz TV 3', weight = 4000, stack = false, rarity = "Rare" },
	['stolen_tv_flat_01'] = { label = 'Çalıntı Düz TV 1', weight = 4000, stack = false, rarity = "Rare" },
	['stolen_console_01'] = { label = 'Çalıntı Oyun Konsolu', weight = 2000, stack = false, rarity = "Rare" },
	['stolen_mp3_dock'] = { label = 'Çalıntı MP3 Dock', weight = 1000, stack = false, rarity = "Rare" },
	['stolen_kettle_01'] = { label = 'Çalıntı Su Isıtıcı', weight = 1500, stack = false, rarity = "Rare" },
	['stolen_toaster_01'] = { label = 'Çalıntı Ekmek Kızartma 1', weight = 1000, stack = false, rarity = "Rare" },
	['stolen_toaster_02'] = { label = 'Çalıntı Ekmek Kızartma 2', weight = 1000, stack = false, rarity = "Rare" },
	['stolen_boombox_01'] = { label = 'Çalıntı Teyp', weight = 2500, stack = false, rarity = "Rare" },
	['stolen_laptop_01a'] = { label = 'Çalıntı Laptop', weight = 2000, stack = false, rarity = "Rare" },
	['stolen_telescope_01'] = { label = 'Çalıntı Teleskop', weight = 3000, stack = false, rarity = "Rare" },
	['stolen_mixer_01'] = { label = 'Çalıntı Mikser', weight = 2000, stack = false, rarity = "Rare" },
	['stolen_kscales_01'] = { label = 'Çalıntı Mutfak Terazisi', weight = 1000, stack = false, rarity = "Rare" },
	['stolen_printer_01'] = { label = 'Çalıntı Yazıcı', weight = 3000, stack = false, rarity = "Rare" },
	['stolen_monitor_01'] = { label = 'Çalıntı Monitör', weight = 3500, stack = false, rarity = "Rare" },
	['stolen_mmaudio_01'] = { label = 'Çalıntı Ses Sistemi', weight = 2500, stack = false, rarity = "Rare" },
	['stolen_tapeplayer_01'] = { label = 'Çalıntı Kaset Çalar', weight = 1000, stack = false, rarity = "Rare" },
	['stolen_hairdryer_01'] = { label = 'Çalıntı Saç Kurutma', weight = 800, stack = false, rarity = "Rare" },
	['stolen_coffemac_02'] = { label = 'Çalıntı Kahve Makinesi', weight = 1500, stack = false, rarity = "Rare" },

	-- [[ PAWNSHOP: Değerliler & Mücevherler ]] --

	['goldbracelet'] = { label = 'Altın Bilezik', weight = 200, stack = true, rarity = "Epic" },
	['goldbar'] = { label = 'Altın Külçe', weight = 1000, stack = true, rarity = "Rare" },
	['rubynecklace'] = { label = 'Yakut Kolye', weight = 150, stack = true, rarity = "Legendary" },
	['silverbar'] = { label = 'Gümüş Külçe', weight = 800, stack = true, rarity = "Rare" },
	['harddrive'] = { label = 'Sabit Disk', weight = 500, stack = true, rarity = "Rare" },
	['goldbarstack'] = { label = 'Altın Külçe Yığını', weight = 5000, stack = false, rarity = "Legendary" },
	['goldwatch'] = { label = 'Altın Saat', weight = 200, stack = true, rarity = "Rare" },
	['goldchain'] = { label = 'Altın Zincir', weight = 150, stack = true, rarity = "Epic" },
	['diamondring'] = { label = 'Elmas Yüzük', weight = 100, stack = true, rarity = "Rare" },
	['diamond_ring'] = { label = 'Elmas Yüzük', weight = 100, stack = true, rarity = "Rare" },
	['diamondnecklace'] = { label = 'Elmas Kolye', weight = 150, stack = true, rarity = "Legendary" },
	['silverring'] = { label = 'Gümüş Yüzük', weight = 80, stack = true, rarity = "Rare" },

	-- [[ PAWNSHOP: Tablolar ]] --

	['paintingcity'] = { label = 'Şehir Tablosu', weight = 1000, stack = false, rarity = "Rare" },
	['paintingfamily'] = { label = 'Aile Tablosu', weight = 1000, stack = false, rarity = "Rare" },
	['paintingguys'] = { label = 'Erkekler Tablosu', weight = 1000, stack = false, rarity = "Rare" },
	['paintinglady'] = { label = 'Bayan Tablosu', weight = 1000, stack = false, rarity = "Rare" },
	['paintingnative'] = { label = 'Yerli Tablosu', weight = 1000, stack = false, rarity = "Rare" },
	['paintingpaddle'] = { label = 'Kürek Tablosu', weight = 1000, stack = false, rarity = "Rare" },
	['paintingart'] = { label = 'Sanat Tablosu', weight = 1000, stack = false, rarity = "Rare" },
	['paintingclown'] = { label = 'Palyaço Tablosu', weight = 1000, stack = false, rarity = "Rare" },
	['paintingpig'] = { label = 'Domuz Tablosu', weight = 1000, stack = false, rarity = "Rare" },
	['paintingrocket'] = { label = 'Roket Tablosu', weight = 1000, stack = false, rarity = "Rare" },

	-- [[ PAWNSHOP: Tacir Ürünleri ]] --

	['rolled_weed'] = { label = 'Sarılı Nane', weight = 500, stack = true },
	['packed_coke'] = { label = 'Paketlenmiş Şeker', weight = 500, stack = true },
	['packed_meth'] = { label = 'Paketlenmiş Kristal', weight = 500, stack = true },

	['fakeplate'] = {
		label  = 'Sahte Plaka',
		weight = 200,
		stack  = false,
		close  = true,
		client = {
			export = 'daddy-fakeplate.useFakePlate',
		},
	},

	-- ['platerestorekit'] = {
	-- 	label  = 'Plaka Onarım Kiti',
	-- 	weight = 300,
	-- 	stack  = true,
	-- 	close  = true,
	-- 	client = {
	-- 		export = 'krypton-fakeplate.usePlateRestoreKit',
	-- 	},
	-- },

	['screwdriverset'] = {
		label  = 'Tornavida Seti',
		weight = 500,
		stack  = true,
		close  = false,
		client = {
			export = 'daddy-fakeplate.usePlateRestoreKit',
		},
	},

	['rental_papers'] = {
		label = 'Kiralama Evrakları',
		weight = 50,
		stack = true,
		close = true,
		description = 'Kiraladıkça oluşan araç kiralama belgeleri.',
	},

	-- Pug Robbery Creator Items

	["gasmask"] = {
		label = "Gaz Maskesi",
		weight = 100,
		stack = true,
		close = true,
	},

	["ropehook"] = {
		label = "Halat Kancası",
		weight = 100,
		stack = true,
		close = true,
	},

	["purpleusb"] = {
		label = "Mor USB",
		weight = 10,
		stack = true,
		close = true,
		rarity = "Epic"
	},

	["salvagedlockpick"] = {
		label = "Hurda Maymuncuk",
		weight = 5,
		stack = true,
		close = true,
	},

	["unmarkedsimcard"] = {
		label = "Kayıtsız SIM Kart",
		weight = 5,
		stack = true,
		close = true,
		rarity = "Rare"
	},

	["bandsofnotes"] = {
		label = "Banknot Destesi",
		weight = 10,
		stack = true,
		close = true,
	},

	["bankcard"] = {
		label = "Banka Kartı",
		weight = 5,
		stack = true,
		close = true,
		rarity = "Epic"
	},

	["group6card"] = {
		label = "Group 6 Güvenlik Kartı",
		weight = 5,
		stack = true,
		close = true,
		rarity = "Legendary"
	},

	["humaneco2"] = {
		label = "X2 Bileşiği",
		weight = 5,
		stack = true,
		close = true,
	},

	["paletobankcard"] = {
		label = "Paleto Banka Kartı",
		weight = 5,
		stack = true,
		close = true,
		rarity = "Epic"
	},

	["stacksofcash"] = {
		label = "Para Desteleri",
		weight = 15,
		stack = true,
		close = true,
	},

	["thermite"] = {
		label = "Termit",
		weight = 5,
		stack = true,
		close = true,
	},

	["drill"] = {
		label = "Matkap",
		weight = 1000,
		stack = true,
		close = true,
	},

	["handsaw"] = {
		label = "El Testeresi",
		weight = 3,
		stack = true,
		close = true,
	},

	["wirecutters"] = {
		label = "Tel Makası",
		weight = 2,
		stack = true,
		close = true,
	},

	["pincracker"] = {
		label = "Şifre Kırıcı",
		weight = 1,
		stack = true,
		close = true,
		rarity = "Rare"
	},

	["bigbankcard"] = {
		label = "Büyük Banka Kartı",
		weight = 5,
		stack = true,
		close = true,
		rarity = "Legendary"
	},

	["c4"] = {
		label = "C4 Patlayıcı",
		weight = 10,
		stack = true,
		close = true,
		rarity = "Epic"
	},

	["humaneusb"] = {
		label = "Humane Labs USB",
		weight = 1,
		stack = true,
		close = true,
		rarity = "Legendary"
	},

	["bankidcard"] = {
		label = "Banka Kimlik Kartı",
		weight = 1,
		stack = true,
		close = true,
		rarity = "Epic"
	},

	-- # start 0r-illegalpack
	-- # jobs/bag_snatch

	['illegal_tablet']                          = {
		label = 'İllegal Tablet',
		weight = 500,
		stack = false,
		close = true,
		degrade = 10080,
		decay = true,
		rarity = "Rare"
	},

	['stolen_bag']                              = { label = 'Çalıntı Çanta', weight = 1.0, stack = true, },
	['scrapmetal']                              = { label = 'Hurda Metal', weight = 0.1, stack = true, },
	['plastic']                                 = { label = 'Plastik', weight = 0.1, stack = true, },
	['glass']                                   = { label = 'Cam', weight = 0.1, stack = true, },
	['copperwire']                              = { label = 'Bakır Tel', weight = 0.1, stack = true, },
	['medkit']                                  = { label = 'İlk Yardım Çantası', weight = 0.1, stack = true, },
	['adrenaline']                              = { label = 'Adrenalin', weight = 0.1, stack = true, },

	-- # jobs/cocaine_job

	['unpacked_coke']                           = { label = 'Paketlenmemiş Kokain', weight = 1.0, stack = true, },
	['cutted_coke']                             = { label = 'Kesilmiş Kokain', weight = 1.0, stack = true, },

	-- # jobs/counterfeit_money

	['uncutted_money']                          = { label = 'Kesilmemiş Para', weight = 0.1, stack = true, },
	['cutted_money']                            = { label = 'Kesilmiş Para', weight = 0.1, stack = true, },

	-- # jobs/fraud

	['fake_credit_card']                        = { label = 'Sahte Kredi Kartı', weight = 0.0, stack = true, },

	-- # jobs/meth_job

	['cooked_meth']                             = { label = 'Pişirilmiş Met', weight = 0.0, stack = true, },
	['breaked_meth']                            = { label = 'Parçalanmış Met', weight = 0.0, stack = true, },

	-- # jobs/moonshine

	['moonshine_still']                         = { label = 'Kaçak İçki İmbliği', weight = 1.0, stack = true, },
	['old_corn']                                = { label = 'Bayat Mısır', weight = 0.1, stack = true, },
	['old_fruit']                               = { label = 'Bayat Meyve', weight = 0.1, stack = true, },
	['tap_water']                               = { label = 'Musluk Suyu', weight = 0.1, stack = true, },
	['moonshine']                               = { label = 'Kaçak İçki (Moonshine)', weight = 0.1, stack = true, },
	['crushed_ingredients']                     = { label = 'Ezilmiş Malzemeler', weight = 0.1, stack = true, },
	['blended_ingredients']                     = { label = 'Karıştırılmış Malzemeler', weight = 0.1, stack = true, },

	-- # jobs/weed

	['unpacked_weed']                           = { label = 'Paketlenmemiş Ot', weight = 0.1, stack = true, },
	['packed_weed']                             = { label = 'Paketlenmiş Ot', weight = 1.0, stack = true, },

	--- # end 0r-illegalpack

	-- qbx_divegear Items

	['diving_fill']                             = {
		label = 'Dalış Tüpü',
		weight = 3000,
		stack = false,
		close = true,
	},

	['diving_gear']                             = {
		label = 'Dalış Ekipmanı',
		weight = 30000,
		stack = false,
		close = true,
	},

	['powdered_milk']                           = { label = 'Süt Tozu', weight = 0.1, stack = true, },
	['money_sheet']                             = { label = 'Para Kağıdı', weight = 0.1, stack = true, },
	['plant_spray']                             = { label = 'Bitki İlacı', weight = 0.0, stack = false, degrade = 2880, decay = true },
	['ammonia']                                 = { label = 'Amonyak', weight = 0.1, stack = true, },
	['sacid']                                   = { label = 'Asit', weight = 0.1, stack = true, },
	['atm_hack_device']                         = { label = 'ATM Hack Cihazı', weight = 0.1, stack = true, },
	['blank_card']                              = { label = 'Boş Kart', weight = 0.1, stack = true, },
	['moonshine_pack']                          = { label = 'Kaçak İçki Paketi', weight = 0.1, stack = true, },
	['lucky_hat']                               = { label = 'Şans Şapkası', weight = 0.1, stack = false, },

	-- 0r-fishingv2 Items

	['fishing_rod_one']                         = {
		label = 'Olta (Seviye 1)',
		weight = 1000,
		stack = false,
		close = false,
		degrade = 10080,
		decay = true
	},

	['fishing_rod_two']                         = {
		label = 'Olta (Seviye 2)',
		weight = 1000,
		stack = false,
		close = false,
		degrade = 10080,
		decay = true
	},

	['fishing_rod_three']                       = {
		label = 'Olta (Seviye 3)',
		weight = 1000,
		stack = false,
		close = false,
		degrade = 10080,
		decay = true
	},

	['fishing_rod_four']                        = {
		label = 'Olta (Seviye 4)',
		weight = 1000,
		stack = false,
		close = false,
		degrade = 10080,
		decay = true
	},

	['fishing_rod_five']                        = {
		label = 'Olta (Seviye 5)',
		weight = 1000,
		stack = false,
		close = false,
		degrade = 10080,
		decay = true
	},

	['fishing_net']                             = { label = 'Balık Ağı', weight = 2.0, stack = false, close = true },
	['anchor']                                  = { label = 'Çapa', weight = 5.0, stack = false, close = true },
	['worm_fish_bait']                          = { label = 'Solucan Yem', weight = 0.1, stack = true, close = true },
	['simple_fish_bait']                        = { label = 'Basit Yem', weight = 0.1, stack = true, close = true },
	['illegal_fish_bait']                       = { label = 'Yasa Dışı Yem', weight = 0.1, stack = true, close = true },
	['diving_cloth']                            = { label = 'Dalış Kıyafeti', weight = 1.5, stack = false, close = true },
	['bass']                                    = { label = 'Levrek', weight = 0.5, stack = true, close = true },
	['bluegill']                                = { label = 'Güneş Balığı', weight = 0.3, stack = true, close = true },
	['common_carp']                             = { label = 'Sazan', weight = 0.6, stack = true, close = true },
	['nothern_pike']                            = { label = 'Kuzey Turnası', weight = 0.8, stack = true, close = true },
	['perch']                                   = { label = 'Tatlısu Levreği', weight = 0.4, stack = true, close = true },
	['rainbow_trout']                           = { label = 'Gökkuşağı Alabalığı', weight = 0.7, stack = true, close = true },
	['redfin_pickerel']                         = { label = 'Kızıl Turna', weight = 0.5, stack = true, close = true },
	['rock_bass']                               = { label = 'Kaya Levreği', weight = 0.6, stack = true, close = true },
	['small_trout']                             = { label = 'Küçük Alabalık', weight = 0.3, stack = true, close = true },
	['smallmouth_bass']                         = { label = 'Küçük Ağızlı Levrek', weight = 0.4, stack = true, close = true },
	['sockeye_salmon']                          = { label = 'Kırmızı Somon', weight = 1.2, stack = true, close = true },
	['trout']                                   = { label = 'Alabalık', weight = 0.8, stack = true, close = true },
	['whitefish']                               = { label = 'Beyaz Balık', weight = 0.5, stack = true, close = true },
	['redpearl']                                = { label = 'Kırmızı İnci', weight = 0.1, stack = true, close = true },
	['bluepearl']                               = { label = 'Mavi İnci', weight = 0.1, stack = true, close = true },
	['yellowpearl']                             = { label = 'Sarı İnci', weight = 0.1, stack = true, close = true },
	['greenpearl']                              = { label = 'Yeşil İnci', weight = 0.1, stack = true, close = true },
	['green_crab']                              = { label = 'Yeşil Yengeç', weight = 0.2, stack = true, close = true },
	['red_crab']                                = { label = 'Kırmızı Yengeç', weight = 0.2, stack = true, close = true },
	['blue_crab']                               = { label = 'Mavi Yengeç', weight = 0.2, stack = true, close = true },
	['king_crab']                               = { label = 'Kral Yengeç', weight = 0.8, stack = true, close = true },
	['trash_can']                               = { label = 'Çöp Kutusu', weight = 0.5, stack = true, close = true },
	['trash_chips']                             = { label = 'Çöp Cips Paketi', weight = 0.1, stack = true, close = true },
	['trash_burger']                            = { label = 'Çöp Hamburger', weight = 0.1, stack = true, close = true },

	-- wais-outfitbag Item

	['outfit_bag']                              = { label = 'Kıyafet Çantası', weight = 500, stack = false, close = true },

	-- BDX Scripts Items

	['skateboard']                              = { label = 'Kaykay', weight = 1000, stack = false, close = true },
	['bmx']                                     = { label = 'BMX', weight = 2000, stack = false, close = true },
	['slopstyle']                               = { label = 'Slopstyle Bisikleti', weight = 2500, stack = false, close = true },
	['hoverboard']                              = { label = 'Hoverboard', weight = 1500, stack = false, close = true },
	['rollers']                                 = { label = 'Paten', weight = 800, stack = false, close = true },
	['scooter']                                 = { label = 'Scooter', weight = 1500, stack = false, close = true },
	['skis']                                    = { label = 'Kayak', weight = 1200, stack = false, close = true },
	['iceskates']                               = { label = 'Buz Pateni', weight = 800, stack = false, close = true },
	['snowboard']                               = { label = 'Snowboard', weight = 1500, stack = false, close = true },
	['surfboard']                               = { label = 'Sörf Tahtası', weight = 2000, stack = false, close = true },

	['spraycan']                                = {
		label = 'Sprey Kutusu',
		weight = 500,
		stack = true,
		close = true
	},

	-- plt_drugs Items

	['weed_seed']                               = { label = 'Esrar Tohumu', weight = 40, stack = true },
	['gingeritis_weed']                         = { label = 'Islak Gingeritis Esrarı', weight = 110, stack = true },
	['energizing_dried_weed']                   = { label = 'Enerji Veren Kurutulmuş Esrar', weight = 30, stack = true },
	['high_quality_weed']                       = { label = 'Islak Yüksek Kalite Esrar', weight = 100, stack = true },
	['dried_weed']                              = { label = 'Kurutulmuş Esrar', weight = 20, stack = true },
	['dried_high_quality_weed']                 = { label = 'Kurutulmuş Yuksek Kalite Esrar', weight = 20, stack = true },
	['packaged_gingeritis_weed']                = { label = 'Paketlenmiş Islak Gingeritis Esrarı', weight = 110, stack = true },
	['packaged_energizing_dried_weed']          = { label = 'Paketlenmiş Enerji Veren Kurutulmuş Esrar', weight = 40, stack = true },
	['packaged_weed']                           = { label = 'Paketlenmiş Islak Esrar', weight = 110, stack = true },
	['packaged_high_quality_weed']              = { label = 'Paketlenmiş Islak Yuksek Kalite Esrar', weight = 110, stack = true },
	['packaged_dried_weed']                     = { label = 'Paketlenmiş Kurutulmuş Esrar', weight = 30, stack = true },
	['packaged_dried_high_quality_weed']        = { label = 'Paketlenmiş Kurutulmuş Yuksek Kalite Esrar', weight = 20, stack = true },
	['coke_seed']                               = { label = 'Kokain Tohumu', weight = 40, stack = true },
	['coke_leaf']                               = { label = 'Islak Kokain Yaprağı', weight = 50, stack = true },
	['high_quality_coke_leaf']                  = { label = 'Islak Yuksek Kalite Kokain Yaprağı', weight = 50, stack = true },
	['dried_coke_leaf']                         = { label = 'Kurutulmuş Kokain Yaprağı', weight = 10, stack = true },
	['dried_high_quality_coke_leaf']            = { label = 'Kurutulmuş Yuksek Kalite Kokain Yaprağı', weight = 10, stack = true },
	['coke']                                    = { label = 'Islak Kokain Bazı', weight = 100, stack = true },
	['high_quality_coke']                       = { label = 'Islak Yuksek Kalite Kokain Bazı', weight = 100, stack = true },
	['dried_coke']                              = { label = 'Kurutulmuş Kokain Bazı', weight = 20, stack = true },
	['dried_high_quality_coke']                 = { label = 'Kurutulmuş Yuksek Kalite Kokain Bazı', weight = 20, stack = true },
	['cooked_coke']                             = { label = 'Islak Kokain', weight = 100, stack = true },
	['cooked_high_quality_coke']                = { label = 'Islak Yüksek Kalite Kokain', weight = 100, stack = true },
	['cooked_dried_coke']                       = { label = 'Kurutulmuş Kokain', weight = 20, stack = true },
	['cooked_dried_high_quality_coke']          = { label = 'Kurutulmuş Yuksek Kalite Kokain', weight = 20, stack = true },
	['packaged_coke']                           = { label = 'Paketlenmiş Islak Kokain Bazı', weight = 100, stack = true },
	['packaged_high_quality_coke']              = { label = 'Paketlenmiş Islak Yuksek Kalite Kokain Bazı', weight = 100, stack = true },
	['packaged_dried_coke']                     = { label = 'Paketlenmiş Kurutulmuş Kokain Bazı', weight = 20, stack = true },
	['packaged_dried_high_quality_coke']        = { label = 'Paketlenmiş Kurutulmuş Yuksek Kalite Kokain Bazı', weight = 20, stack = true },
	['packaged_cooked_coke']                    = { label = 'Paketlenmiş Islak Kokain', weight = 100, stack = true },
	['packaged_cooked_high_quality_coke']       = { label = 'Paketlenmiş Islak Yuksek Kalite Kokain', weight = 100, stack = true },
	['packaged_cooked_dried_coke']              = { label = 'Paketlenmiş Kurutulmuş Kokain', weight = 20, stack = true },
	['packaged_cooked_dried_high_quality_coke'] = { label = 'Paketlenmiş Kurutulmuş Yuksek Kalite Kokain', weight = 20, stack = true },
	['liquid_meth']                             = { label = 'Sıvı Met', weight = 200, stack = true },
	['default_meth']                            = { label = 'Met Tomurcuğu', weight = 10, stack = true },
	['packaged_default_meth']                   = { label = 'Paketlenmiş Met', weight = 60, stack = true },
	['weed_brick']                              = { label = 'Esrar Tuğlası', weight = 400, stack = true },
	['high_quality_weed_brick']                 = { label = 'Yuksek Kalite Esrar Tuğlası', weight = 400, stack = true },
	['coke_brick']                              = { label = 'Kokain Bazı Tuğlası', weight = 500, stack = true },
	['high_quality_coke_brick']                 = { label = 'Yuksek Kalite Kokain Bazı Tuğlası', weight = 500, stack = true },
	['cooked_coke_brick']                       = { label = 'Kokain Tuğlası', weight = 500, stack = true },
	['cooked_high_quality_coke_brick']          = { label = 'Yuksek Kalite Kokain Tuğlası', weight = 500, stack = true },
	['baggy']                                   = { label = 'Poşet', weight = 10, stack = true },
	['plant_pot']                               = { label = 'Saksı', weight = 100, stack = true },
	['fertilizer']                              = { label = 'Gübre İlacı', weight = 1000, stack = true },
	['default_lamp']                            = { label = 'Lamba', weight = 500, stack = true },
	['default_fan']                             = { label = 'Fan', weight = 500, stack = true },
	['default_soil']                            = { label = 'Toprak', weight = 500, stack = true },
	['drying_rack']                             = { label = 'Kurutma Rafı', weight = 500, stack = false },
	['watering_can']                            = { label = 'Sulama Kabı', weight = 500, stack = true },
	['default_brick_press']                     = { label = 'Pres', weight = 3500, stack = false },
	['packaging_station']                       = { label = 'Paketleme İstasyonu', weight = 5000, stack = false },
	['drug_mixer']                              = { label = 'Uyuşturucu Karıştırıcısı', weight = 2000, stack = false },
	['plant_trimmers']                          = { label = 'Bitki Makası', weight = 200, stack = true },
	['drug_cauldron']                           = { label = 'Kazan', weight = 5000, stack = false },
	['drug_oven']                               = { label = 'Lab Fırını', weight = 5000, stack = false },
	['chemistry_station']                       = { label = 'Kimya İstasyonu', weight = 5000, stack = false },

	['acetone']                                 = {
		label = 'Aseton',
		weight = 500,
		stack = true,
	},

	['pills']                                   = { label = 'Hap', weight = 100, stack = true },
	['phosphorus']                              = { label = 'Fosfor', weight = 500, stack = true },
	['gasoline']                                = { label = 'Benzin', weight = 2000, stack = true },
	['hammer']                                  = { label = 'Çekiç', weight = 1000, stack = true },

	-- JS MECHANIC

	["engine_oil"]                              = {
		label = "Motor Yağı",
		weight = 1000,
	},

	["tyre_replacement"]                        = {
		label = "Lastik Değişimi",
		weight = 1000,
	},

	["clutch_replacement"]                      = {
		label = "Debriyaj Değişimi",
		weight = 1000,
	},

	["air_filter"]                              = {
		label = "Hava Filtresi",
		weight = 100,
	},

	["spark_plug"]                              = {
		label = "Buji",
		weight = 1000,
	},

	["brakepad_replacement"]                    = {
		label = "Fren Balatası Değişimi",
		weight = 1000,
	},

	["suspension_parts"]                        = {
		label = "Süspansiyon Parçaları",
		weight = 1000,
	},
	-- Engine Items

	["i4_engine"]                               = {
		label = "I4 Motor",
		weight = 1000,
	},

	["v6_engine"]                               = {
		label = "V6 Motor",
		weight = 1000,
	},

	["v8_engine"]                               = {
		label = "V8 Motor",
		weight = 1000,
	},

	["v12_engine"]                              = {
		label = "V12 Motor",
		weight = 1000,
		rarity = "Epic",
	},

	["turbocharger"]                            = {
		label = "Turboşarj",
		weight = 1000,
	},
	-- Electric Engines

	["ev_motor"]                                = {
		label = "EV Motoru",
		weight = 1000,
	},

	["ev_battery"]                              = {
		label = "EV Bataryası",
		weight = 1000,
	},

	["ev_coolant"]                              = {
		label = "EV Soğutma Sıvısı",
		weight = 1000,
	},
	-- Drivetrain Items

	["awd_drivetrain"]                          = {
		label = "AWD Aktarma Sistemi",
		weight = 1000,
	},

	["rwd_drivetrain"]                          = {
		label = "RWD Aktarma Sistemi",
		weight = 1000,
	},

	["fwd_drivetrain"]                          = {
		label = "FWD Aktarma Sistemi",
		weight = 1000,
	},
	-- Tuning Items

	["slick_tyres"]                             = {
		label = "Slick Lastikler",
		weight = 1000,
	},

	["semi_slick_tyres"]                        = {
		label = "Semi-Slick Lastikler",
		weight = 1000,
	},

	["offroad_tyres"]                           = {
		label = "Arazi Lastikleri",
		weight = 1000,
	},

	["drift_tuning_kit"]                        = {
		label = "Drift Parçaları",
		weight = 1000,
	},

	["ceramic_brakes"]                          = {
		label = "Seramik Frenler",
		weight = 1000,
	},
	-- Cosmetic Items

	["lighting_controller"]                     = {
		label = "Işık Kontrolcüsü",
		weight = 100,
		server = {
			export = "daddy_mechanic.lighting_controller",
		}
	},

	-- daddy_mechanic: the parts a mechanic fits (the controller above is only the driver's remote)
	["xenon_kit"]                               = {
		label = "Xenon Far Kiti",
		weight = 800,
		client = { image = "lighting_controller.png" },
	},

	["neon_kit"]                                = {
		label = "Neon Kiti",
		weight = 1500,
		client = { image = "lighting_controller.png" },
	},

	["stancing_kit"]                            = {
		label = "Stance Kiti",
		weight = 100,
		server = {
			export = "daddy_mechanic.stancing_kit",
		}
	},

	["cosmetic_part"]                           = {
		label = "Kozmetik Parçalar",
		weight = 100,
	},

	["respray_kit"]                             = {
		label = "Yeniden Boyama Kiti",
		weight = 1000,
	},

	["vehicle_wheels"]                          = {
		label = "Araç Jant Seti",
		weight = 1000,
	},

	["tyre_smoke_kit"]                          = {
		label = "Lastik Dumanı Kiti",
		weight = 1000,
	},

	["bulletproof_tyres"]                       = {
		label = "Kurşun Geçirmez Lastikler",
		weight = 1000,
	},

	["extras_kit"]                              = {
		label = "Ekstra Parça Kiti",
		weight = 1000,
	},
	-- Nitrous & Cleaning Items

	["nitrous_bottle"]                          = {
		label = "Nitro Tüpü",
		weight = 1000,
		server = {
			export = "daddy_mechanic.nitrous_bottle",
		}
	},

	["empty_nitrous_bottle"]                    = {
		label = "Boş Nitro Tüpü",
		weight = 1000,
	},

	["nitrous_install_kit"]                     = {
		label = "Nitro Montaj Kiti",
		weight = 1000,
	},

	["cleaning_kit"]                            = {
		label = "Temizlik Kiti",
		weight = 1000,
		server = {
			export = "daddy_mechanic.cleaning_kit",
		}
	},

	["repair_kit"]                              = {
		label = "Tamir Kiti",
		weight = 1000,
		server = {
			export = "daddy_mechanic.repair_kit",
		}
	},

	["duct_tape"]                               = {
		label = "Koli Bandı",
		weight = 1000,
		server = {
			export = "daddy_mechanic.duct_tape",
		}
	},
	-- Performance Item

	["performance_part"]                        = {
		label = "Performans Parçaları",
		weight = 1000,
	},
	-- Mechanic Tablet Item

	["mechanic_tablet"]                         = {
		label = "Mekanik Tableti",
		weight = 1000,
		server = {
			export = "daddy_mechanic.mechanic_tablet",
		}
	},
	-- Gearbox

	["manual_gearbox"]                          = {
		label = "Manuel Şanzıman",
		weight = 1000,
	},

	["gearbox_kit"]                              = {
		label = "Şanzıman Kiti",
		weight = 15000,
		stack = false,
		client = { image = "manual_gearbox.png" },
	},

	["yanik_kremi"]                             = {
		label = "Yanık Kremi",
		weight = 200,
		description =
		"Yanık yaralarında enfeksiyonu önlemek ve iyileşmeyi desteklemek için kullanılan bir krem (Silver Sulfadiazine)."
	},

	["agri_kesici"]                             = {
		label = "Ağrı Kesici",
		weight = 150,
		description = "Şiddetli ağrıları azaltmak için kullanılan güçlü bir ağrı kesici (Morphine)."
	},

	["kanama_durdurucu"]                        = {
		label = "Bloodstopper İğne",
		weight = 150,
		description = "Aşırı kanamayı azaltmak veya durdurmak için kullanılan iğne (Tranexamic Acid)."
	},

	["adrenalin"]                               = {
		label = "Adrenalin",
		weight = 150,
		description = "Kalp durması veya ciddi alerjik reaksiyonlarda kullanılan hayat kurtarıcı iğne (Epinephrine)."
	},

	["antiseptik"]                              = {
		label = "Antiseptik",
		weight = 300,
		description = "Yaraları ve cildi temizleyerek mikropları öldürmek için kullanılan solüsyon (Povidone-Iodine)."
	},

	-- krypton-farming Items

	['lettuce']                           = { label = 'Marul', weight = 100 },
	['tomato']                            = { label = 'Domates', weight = 100 },
	['potato']                            = { label = 'Patates', weight = 200 },
	['onion']                             = { label = 'Soğan', weight = 150 },
	['pumpkin']                           = { label = 'Mısır', weight = 250 },
	['wheat']                             = { label = 'Buğday', weight = 200 },
	['sunflower']                         = { label = 'Ayçiçeği Yağı', weight = 400 },
	['carrot']                            = { label = 'Havuç', weight = 120 },
	['bottle_milk']                       = { label = 'Süt', weight = 500 },
	['egg']                               = { label = 'Yumurta', weight = 80 },

	['headbag']                           = {
		label = 'Çuval',
		weight = 150,
		stack = true,
		client = {
			export = 'wx_headbag.headbag',
		},
	},

	["tv_crt_classic"] = {
		label = "Klasik CRT Televizyon",
		weight = 800,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_crt_old"] = {
		label = "Eski CRT Televizyon",
		weight = 800,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_crt_wood"] = {
		label = "Ahşap Kasalı CRT Televizyon",
		weight = 900,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_flat_small"] = {
		label = "Küçük Düz Ekran TV",
		weight = 500,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_cinema"] = {
		label = "Sinema Televizyonu",
		weight = 1500,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_curved_xl"] = {
		label = "XL Kavisli Ekran",
		weight = 2000,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_smash"] = {
		label = "Retro Smash Televizyon",
		weight = 700,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_flat_overlay"] = {
		label = "Çerçeveli Düz Ekran TV",
		weight = 700,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_laptop"] = {
		label = "Dizüstü Bilgisayar",
		weight = 200,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_trevor"] = {
		label = "Trevor'un Televizyonu",
		weight = 800,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_vintage"] = {
		label = "Vintage Televizyon",
		weight = 800,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_crt_overlay"] = {
		label = "Çerçeveli CRT Televizyon",
		weight = 800,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_flat_classic"] = {
		label = "Klasik Düz Ekran TV",
		weight = 1000,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_flat_screen"] = {
		label = "Düz Ekran Televizyon",
		weight = 900,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_flat_medium"] = {
		label = "Orta Boy Düz Ekran TV",
		weight = 800,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_flat_modern"] = {
		label = "Modern Düz Ekran TV",
		weight = 1100,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_flat_premium"] = {
		label = "Premium Düz Ekran TV",
		weight = 1200,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	["tv_monitor_large"] = {
		label = "Büyük Monitör",
		weight = 400,
		stack = false,
		close = true,
		server = {
			export = 'wais-tv.PlaceTV'
		}
	},

	-- Dikenli şerit

	["spikesbox"] = {
		label = "Dikenli Şerit Kutusu",
		weight = 2000,
		stack = true
	},

	["spikebox_pilot"] = {
		label = "Dikenli Şerit Kumandası",
		weight = 200,
		stack = true
	},

	-- GPS takip cihazları

	["placeable_gps"] = {
		label = "GPS Takip Cihazı",
		weight = 1000,
		stack = true
	},

	["shootable_gps"] = {
		label = "GPS Takip Cihazı (Atılabilir)",
		weight = 500,
		stack = true,
	},

	-- Graffiti (isteğe bağlı)

	["spray_can"] = {
		label = "Sprey Boya",
		weight = 1,
		stack = false
	},

	["spray_remover"] = {
		label = "Graffiti Temizleyici",
		weight = 1,
		stack = false,
	},

	["notebook"] = {
		label = "Not Defteri",
		weight = 200,
		buttons = {
			{
				label = "Kopyasını Oluştur",
				action = function(slot)
					TriggerServerEvent("prp-notebook:server:duplicateNotebook", slot)
				end
			}
		},
	},

	['student_tablet'] = {
		label = 'Öğrenci Tableti', weight = 500, stack = false, close = true,
		description = 'Ders programı, duyurular, notlar ve okul işlemlerini içeren öğrenci tableti',
		server = { export = 'daddy_studentpad.useItem' },
	},

	['game_pad'] = {
		label = 'Oyun Tableti', weight = 500, stack = false, close = true,
		description = 'İsim Şehir, Codenames, Uno ve klasik oyunları içeren taşınabilir oyun tableti',
		server = { export = 'daddy_arcadepad.useItem' },
	},

	['teacher_tablet'] = {
		label = 'Öğretmen Tableti', weight = 500, stack = false, close = true,
		description = 'Okul yönetim, yoklama ve akademik işlem tableti',
		server = { export = 'daddy_college.useItem' },
	},

	['daddy_exam_paper'] = {
		label = 'Sınav Kağıdı', weight = 10, stack = false, close = true,
		description = 'Tek kullanımlık sınav kağıdı',
		server = { export = 'daddy_college.useItem' },
	},

	['daddy_notebook'] = {
		label = 'Not Defteri', weight = 100, stack = false, close = true,
		description = 'Kişisel not defteri',
		server = { export = 'daddy_college.useItem' },
	},

	['daddy_note_page'] = {
		label = 'Not Kağıdı', weight = 5, stack = true, close = true,
		description = 'Yırtılmış tek sayfa',
		server = { export = 'daddy_college.useItem' },
	},

	['daddy_exam_result'] = {
		label = 'Sınav Sonucu', weight = 5, stack = false,
		description = 'Basılı sınav sonuç belgesi',
	},

	['daddy_exit_permit'] = {
		label = 'Çıkış Kağıdı', weight = 5, stack = false, close = true,
		description = 'Okuldan çıkış izin belgesi — kullanınca yakındakilere gösterir',
		server = { export = 'daddy_college.useItem' },
	},

	['daddy_student_card'] = {
		label = 'Öğrenci Kartı', weight = 10, stack = false, close = true,
		description = 'Resmî öğrenci kimlik kartı — kullanınca yakındakilere gösterir',
		server = { export = 'daddy_college.useItem' },
	},

	['daddy_teacher_card'] = {
		label = 'Öğretmen Kartı', weight = 10, stack = false, close = true,
		description = 'Akademik personel kimlik kartı — kullanınca yakındakilere gösterir',
		server = { export = 'daddy_college.useItem' },
	},

	['daddy_principal_card'] = {
		label = 'Müdür Kartı', weight = 10, stack = false, close = true,
		description = 'Okul yönetimi kimlik kartı — kullanınca yakındakilere gösterir',
		server = { export = 'daddy_college.useItem' },
	},

	['daddy_security_card'] = {
		label = 'Güvenlik Kartı', weight = 10, stack = false, close = true,
		description = 'Okul güvenliği kimlik kartı — kullanınca yakındakilere gösterir',
		server = { export = 'daddy_college.useItem' },
	},

	['backpack_padlock'] = {
		label = 'Asma Kilit',
		weight = 200,
		stack = false,
		close = true,
	},

	['backpack_fingerprint_padlock'] = {
		label = 'Parmak İzi Kilidi',
		weight = 250,
		stack = false,
		close = true,
	},

	['backpack_level_1'] = {
		label = 'Küçük Sırt Çantası',
		weight = 1000,
		stack = false,
		close = true,
		client = { export = 'oxlyn_backpack.openBackpack' }
	},

	['backpack_level_2'] = {
		label = 'Orta Boy Sırt Çantası',
		weight = 1000,
		stack = false,
		close = true,
		client = { export = 'oxlyn_backpack.openBackpack' }
	},

	['backpack_level_3'] = {
		label = 'Büyük Sırt Çantası',
		weight = 1000,
		stack = false,
		close = true,
		client = { export = 'oxlyn_backpack.openBackpack' }
	},

	['backpack_level_4'] = {
		label = 'Kamp Sırt Çantası',
		weight = 1000,
		stack = false,
		close = true,
		client = { export = 'oxlyn_backpack.openBackpack' }
	},

	['boardgame_fourinline'] = {
		label = 'Dört Bir Sırada',
		weight = 2000,
		stack = true,
		close = true,
		client = { image = 'boardgame_fourinline.png' }
	},
	['boardgame_chess'] = {
		label = 'Satranç',
		weight = 2000,
		stack = true,
		close = true,
		client = { image = 'boardgame_chess.png' }
	},
	['boardgame_checkers'] = {
		label = 'Dama',
		weight = 2000,
		stack = true,
		close = true,
		client = { image = 'boardgame_checkers.png' }
	},
	['boardgame_towerblocks'] = {
		label = 'Kule Blokları',
		weight = 2000,
		stack = true,
		close = true,
		client = { image = 'boardgame_towerblocks.png' }
	},
	['boardgame_armwrestling'] = {
		label = 'Bilek Güreşi Masası',
		weight = 5000,
		stack = true,
		close = true,
		client = { image = 'boardgame_armwrestling.png' }
	},
	['boardgame_truthordare'] = {
		label = 'Doğruluk mu Cesaret mi?',
		weight = 1000,
		stack = true,
		close = true,
		client = { image = 'boardgame_truthordare.png' }
	},
	['boardgame_santostycoon'] = {
		label = 'Santos Tycoon',
		weight = 2000,
		stack = true,
		close = true,
		client = { image = 'boardgame_santostycoon.png' }
	},
	['lstour_board'] = {
		label = 'Monopoly Masası',
		weight = 3000,
		stack = false,
		close = true,
		client = { image = 'boardgame_santostycoon.png' }
	},
	['casino_chips'] = {
		label = 'Casino Fişi',
		weight = 1,
		stack = true,
		close = true,
		client = { image = 'casino_chips.png' }
	},
	['casino_beer'] = {
		label = 'Pisswasser Bira',
		weight = 350,
		stack = true,
		close = true,
		client = { image = 'casino_beer.png' }
	},
	['casino_burger'] = {
		label = 'Casino Burger',
		weight = 250,
		stack = true,
		close = true,
		client = { image = 'casino_burger.png' }
	},
	['casino_coke'] = {
		label = 'Casino Kola',
		weight = 330,
		stack = true,
		close = true,
		client = { image = 'casino_coke.png' }
	},
	['casino_sprite'] = {
		label = 'Casino Gazoz',
		weight = 330,
		stack = true,
		close = true,
		client = { image = 'casino_sprite.png' }
	},
	['casino_luckypotion'] = {
		label = 'Şans İksiri',
		weight = 150,
		stack = true,
		close = true,
		client = { image = 'casino_luckypotion.png' }
	},
	['casino_psqs'] = {
		label = "P's & Q's Atıştırmalık",
		weight = 100,
		stack = true,
		close = true,
		client = { image = 'casino_psqs.png' }
	},
	['casino_ego_chaser'] = {
		label = 'Ego Chaser Bar',
		weight = 100,
		stack = true,
		close = true,
		client = { image = 'casino_ego_chaser.png' }
	},
	['casino_sandwitch'] = {
		label = 'Casino Sandviç',
		weight = 200,
		stack = true,
		close = true,
		client = { image = 'casino_sandwitch.png' }
	},
	['casino_donut'] = {
		label = 'Casino Donut',
		weight = 150,
		stack = true,
		close = true,
		client = { image = 'casino_donut.png' }
	},
	['casino_coffee'] = {
		label = 'Casino Kahve',
		weight = 250,
		stack = true,
		close = true,
		client = { image = 'casino_coffee.png' }
	},
	['boardgame_colormatch'] = {
		label = 'Renk Eşleştirme',
		weight = 500,
		stack = true,
		close = true,
		client = { image = 'boardgame_colormatch.png' }
	},
	['boardgame_whoami'] = {
		label = 'Ben Kimim?',
		weight = 2000,
		stack = true,
		close = true,
		client = { image = 'boardgame_whoami.png' }
	},
	['boardgame_rodeo'] = {
		label = 'Mekanik Boğa',
		weight = 10000,
		stack = true,
		close = true,
		client = { image = 'boardgame_rodeo.png' }
	},
	['boardgame_xox'] = {
		label = 'XOX',
		weight = 2000,
		stack = true,
		close = true,
		client = { image = 'boardgame_xox.png' }
	},

	["joint"] = {
		label = "Joint",
		weight = 50,
		stack = true,
		close = true
	},

	["cigarette"] = {
		label = "Sigara",
		weight = 30,
		stack = true,
		close = true
	},

	["lighter"] = {
		label = "Çakmak",
		weight = 50,
		stack = false,
		close = true
	},

	["bong"] = {
		label = "Bong",
		weight = 250,
		stack = false,
		close = true
	},

	["vape"] = {
		label = "Elektronik Sigara",
		weight = 150,
		stack = false,
		close = true
	},

	["vape_battery"] = {
		label = "Elektronik Sigara Bataryası",
		weight = 100,
		stack = true,
		close = true
	},

	["vape_vanilla_flavour"] = {
		label = "Vanilya Aroması",
		weight = 20,
		stack = false,
		close = true
	},

	["vape_green_flavour"] = {
		label = "Yeşil Aroma",
		weight = 20,
		stack = false,
		close = true
	},

	["vape_purple_flavour"] = {
		label = "Mor Aroma",
		weight = 20,
		stack = false,
		close = true
	},

	["vape_rainbow_flavour"] = {
		label = "Gökkuşağı Aroması",
		weight = 20,
		stack = false,
		close = true
	},

	["weed_nugget"] = {
		label = "Joint Parçası",
		weight = 1,
		stack = true,
		close = true
	},

	["cigarette_pack"] = {
		label = "Sigara Paketi",
		weight = 200,
		stack = false,
		close = true
	},

	["bong_water"] = {
		label = "Bong Suyu",
		weight = 250,
		stack = true,
		close = true
	},

	['pd_kit'] = {
		label = 'Teçhizat Çantası',
		weight = 32110,
		stack = false,
		close = true,
		consume = 1,
		groups = {
			['leo'] = 0,
		},
		description = 'İçerisinde standart polis teçhizatı bulunan paket.',
		client = {
			usetime = 5000,
			label = 'Teçhizat Çantası Açılıyor...',
			cancel = true,
			anim = {
				dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
				clip = 'machinic_loop_mechandplayer',
			},
			disable = {
				move = true,
				car = true,
				combat = true,
			},
		},
	},

	['cigar'] = {
		label = 'Hush',
		weight = 50,
		stack = true,
		close = true,
		rarity = "Legendary",
		description = 'Liman tarafında el altından sarılan, katranı ağır bir puro. Tütün yaprakları kas gerilimini ve darbe direncini artıran sert bir kimyasal karışımla dinlendirilmiştir. Ciğerlere çekildiği an vücuttaki acı hissini baskılar, koldaki tendonları kilitlercesine gerginleştirir ve silaha binen vuruş gücünü katlar. Fakat bedeli ağırdır; ciğerleri çürütür, zamanla kalbi tüketir. Haddini bilmeyenler için bu puro, içtikleri son şey olur',
	},

	['antidote_cigar'] = {
		label = 'Hush Panzehiri',
		weight = 100,
		stack = true,
		close = true,
		description = 'Vücuttaki ağır katran ve tütün tortusunu temizleyen, ölümcül puro bağımlılığını tedavi eden medikal solüsyon.',
	},

	-- daddy_college install (items)
	['school_tablet'] = { label = 'Okul Tableti', weight = 600, stack = false, close = true, description = 'Öğretmen, güvenlik ve müdür için personel tableti', server = { export = 'daddy_college.useItem' } },
	['exam_paper'] = { label = 'Sınav Kağıdı', weight = 20, stack = false, close = true, description = 'Sınav oturumunda soruları cevaplamak için kullan', server = { export = 'daddy_college.useItem' } },
	['school_notebook'] = { label = 'Defter', weight = 250, stack = false, close = true, description = 'Yazı ve çizim için spiralli defter', server = { export = 'daddy_college.useItem' } },
	['notebook_page'] = { label = 'Defter Sayfası', weight = 5, stack = false, close = true, description = 'Defterden koparılmış bir sayfa', server = { export = 'daddy_college.useItem' } },
	['phone_powerbank'] = { label = 'Powerbank', weight = 200, stack = true, close = true, description = 'Telefonu 10 dakika şarj eder', server = { export = 'daddy_studentphone.useItem' } },
	['veba_ilac'] = { label = 'Veba İlacı', weight = 50, stack = true, close = true, description = 'Fare vebasını iyileştirir', server = { export = 'daddy_veba.useItem' } },
	['veba_maske'] = { label = 'Tıbbi Maske', weight = 20, stack = true, close = true, description = '30 dakika öksürükten bulaşmayı önler', server = { export = 'daddy_veba.useItem' } },
	['school_newspaper'] = { label = 'Okul Gazetesi', weight = 50, stack = true, close = true, description = 'Okul gazetesinin bir sayısı', server = { export = 'daddy_college.useItem' } },
	['exit_permit'] = { label = 'Çıkış İzni', weight = 5, stack = false, close = true, description = 'Kampüsten bununla çıkılır; kullanınca etrafındakilere gösterilir', server = { export = 'daddy_college.useItem' } },
	['student_card'] = { label = 'Öğrenci Kimlik Kartı', weight = 10, stack = false, close = true, description = 'Okul kimliğin; kullanınca etrafındakilere gösterirsin', server = { export = 'daddy_college.useItem' } },
	['teacher_card'] = { label = 'Öğretmen Kimlik Kartı', weight = 10, stack = false, close = true, description = 'Akademik personel kimliği; kullanınca gösterirsin', server = { export = 'daddy_college.useItem' } },
	['principal_card'] = { label = 'Müdür Kimlik Kartı', weight = 10, stack = false, close = true, description = 'Okul yönetimi kimliği; kullanınca gösterirsin', server = { export = 'daddy_college.useItem' } },
	['security_card'] = { label = 'Güvenlik Kimlik Kartı', weight = 10, stack = false, close = true, description = 'Okul güvenliği kimliği; kullanınca gösterirsin', server = { export = 'daddy_college.useItem' } },
	['school_certificate'] = { label = 'Sertifika', weight = 10, stack = false, close = true, description = 'Okulun verdiği sertifika; kullanınca çevrendekilere gösterirsin', server = { export = 'daddy_college.useItem' } },
	['confiscation_slip'] = { label = 'Emanet Fişi', weight = 5, stack = false, close = false, description = 'Okul bir eşyanı emanette tutuyor; üstünde yazan gün Öğrenci İşleri\'nden geri al' },
	['club_flyer'] = { label = 'Kulüp Broşürü', weight = 5, stack = true, close = true, description = 'Bir kulübün broşürü; okumak için kullan', server = { export = 'daddy_college.useItem' } },
	-- daddy_college kitchen workbench (food)
	['ds_fries'] = { label = 'Patates Kızartması', weight = 300, degrade = 2880, decay = true, client = { status = { hunger = 750000 }, anim = { dict = 'bzzz_fastfood_anim2', clip = 'anim2' }, prop = { model = `bzzz_prop_fastfood_fries_d`, pos = vec3(0.12, 0.06, 0.08), rot = vec3(30.0, 35.0, 134.0) }, usetime = 5000, } },
	['ds_energy_bar'] = { label = 'Enerji Barı', weight = 150, degrade = 2880, decay = true, client = { status = { hunger = 750000 }, anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' }, prop = { model = `bzzz_new_snacks_energy_a`, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) }, usetime = 8000, cancel = true } },
	['ds_steak_sandwich'] = { label = 'Biftekli Sandviç', weight = 400, degrade = 2880, decay = true, client = { status = { hunger = 750000 }, anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' }, prop = { model = `bzzz_food_bakery_baguette_c`, pos = vec3(0.02, 0.0, -0.01), rot = vec3(-80.0, 0.0, 0.0) }, usetime = 5000, } },
	['ds_hotdog'] = { label = 'Hotdog', weight = 350, degrade = 2880, decay = true, client = { status = { hunger = 750000 }, anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' }, prop = { model = `bzzz_food_hotdog_b`, pos = vec3(0.02, 0.01, -0.02), rot = vec3(-80.0, 0.0, 0.0) }, usetime = 5000, } },
	['ds_pizza_slice'] = { label = 'Pizza Dilimi', weight = 200, degrade = 2880, decay = true, client = { status = { hunger = 750000 }, anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' }, prop = { model = `bzzz_food_bakery_bread_d`, pos = vec3(0.02, 0.0, -0.01), rot = vec3(-80.0, 0.0, 0.0) }, usetime = 5000, } },
	['ds_brownie'] = { label = 'Brownie', weight = 200, degrade = 2880, decay = true, client = { status = { hunger = 750000 }, anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' }, prop = { model = `bzzz_sugary_brownies_a`, pos = vec3(-0.02, 0.0, -0.01), rot = vec3(70.0, -64.0, 52.0) }, usetime = 5000, } },
	['ds_apple_pie'] = { label = 'Elmalı Turta', weight = 250, degrade = 2880, decay = true, client = { status = { hunger = 750000 }, anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' }, prop = { model = `bzzz_sugary_applepie_a`, pos = vec3(-0.02, 0.01, 0.0), rot = vec3(16.0, 16.0, -18.0) }, usetime = 5000, } },
	['ds_cheesecake'] = { label = 'Cheesecake', weight = 250, degrade = 2880, decay = true, client = { status = { hunger = 750000 }, anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' }, prop = { model = `bzzz_sugary_cheesecake_a`, pos = vec3(-0.03, -0.01, 0.01), rot = vec3(-11.0, -180.0, 76.0) }, usetime = 5000, } },
	['ds_tiramisu'] = { label = 'Tiramisu', weight = 250, degrade = 2880, decay = true, client = { status = { hunger = 750000 }, anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' }, prop = { model = `bzzz_sugary_tiramisu_a`, pos = vec3(-0.03, -0.01, 0.01), rot = vec3(-11.0, -180.0, 76.0) }, usetime = 5000, } },
	-- daddy_studentphone + daddy_dorms install (items)
	['student_phone'] = { label = 'Öğrenci Telefonu', weight = 200, stack = false, close = true, description = 'Ders programı, ödevler, odak sayacı ve okul mesajları cebinde', server = { export = 'daddy_studentphone.useItem' } },
	['dorm_keycard'] = { label = 'Yurt Anahtar Kartı', weight = 10, stack = false, close = true, description = 'Yurt odanın kapısını açar; oda numarası kartın üstünde', server = { export = 'daddy_dorms.useItem' } },
	-- daddy_campusgames install (items)
	['party_bottle'] = { label = 'Çevirme Şişesi', weight = 300, stack = false, close = true, description = 'Doğruluk mu cesaret mi: kullanınca önüne kurulur, tekrar kullanınca toplanır', server = { export = 'daddy_campusgames.useItem' } },
	['party_potato'] = { label = 'Sıcak Patates', weight = 200, stack = false, close = true, description = 'Sıcak patates oyununu olduğun yere kurar; tekrar kullanınca toplanır', server = { export = 'daddy_campusgames.useItem' } },
	['party_signal'] = { label = 'Oyun Işığı', weight = 2500, stack = false, close = true, description = 'Kırmızı ışık yeşil ışık: ışık olduğun yere, pist baktığın yöne kurulur; tekrar kullanınca toplanır', server = { export = 'daddy_campusgames.useItem' } },
	['party_speaker'] = { label = 'Parti Hoparlörü', weight = 1500, stack = false, close = true, description = 'Müzikli sandalye oyununu önüne kurar; tekrar kullanınca toplanır', server = { export = 'daddy_campusgames.useItem' } },
	['party_flag'] = { label = 'Kale Bayrağı', weight = 500, stack = false, close = true, description = 'Saklambaç: bayrağı dikersin, kale burası olur; tekrar kullanınca toplanır', server = { export = 'daddy_campusgames.useItem' } },
	['party_taboo'] = { label = 'Tabu Kutusu', weight = 600, stack = false, close = true, description = 'Tabu: kartları önüne koyar, etrafına oturan iki takım oynar; tekrar kullanınca toplanır', server = { export = 'daddy_campusgames.useItem' } },
	['party_whoami'] = { label = 'Ben Kimim Kartları', weight = 300, stack = false, close = true, description = 'Ben Kimim: kartları önüne koyar, etrafına oturanlar oynar; tekrar kullanınca toplanır', server = { export = 'daddy_campusgames.useItem' } },
	['party_tombala'] = { label = 'Tombala Torbası', weight = 500, stack = false, close = true, description = 'Tombala: torbayı önüne koyar, etrafına oturanlar oynar; tekrar kullanınca toplanır', server = { export = 'daddy_campusgames.useItem' } },
	-- tgiann-nails
	['nail_repair_kit'] = { label = 'Tırnak Tamir Kiti', weight = 200, stack = true, close = true, description = 'Kırık tırnakları her yerde onarır' },
	['nail_remover'] = { label = 'Aseton', weight = 150, stack = true, close = true, description = 'Tırnaklarını çıkarır' },
	['press_on_nails'] = { label = 'Takma Tırnak', weight = 100, stack = false, close = true, description = 'Salon kataloğundan hazır tırnak kutusu' },

	-- daddy_bills
	['bill_receipt'] = { label = 'Makbuz', weight = 10, stack = false, close = true, consume = 0, description = 'Ödenmiş bir faturanın makbuzu', server = { export = 'daddy_bills.useReceipt' } },

	-- daddy_venue (install/items/general + burgershot)
	['venue_mojito'] = {
		label = 'Mojito',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_cuba_libre'] = {
		label = 'Cuba Libre',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_margarita'] = {
		label = 'Margarita',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_vodka_soda'] = {
		label = 'Vodka Soda',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_whiskey_sour'] = {
		label = 'Whiskey Sour',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_tequila_shot'] = {
		label = 'Tequila Shot',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_beer'] = {
		label = 'Bira',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_fries'] = {
		label = 'Patates Kızartması',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_cola'] = {
		label = 'Kola',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_brownie'] = {
		label = 'Brownie',
		weight = 150,
		stack = true,
		close = true,
	},

	['venue_margherita'] = {
		label = 'Margherita',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_pepperoni_pizza'] = {
		label = 'Pepperonili Pizza',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_mushroom_pizza'] = {
		label = 'Mantarlı Pizza',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_garlic_bread'] = {
		label = 'Sarımsaklı Ekmek',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_lemonade'] = {
		label = 'Limonata',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_espresso'] = {
		label = 'Espresso',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_latte'] = {
		label = 'Latte',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_cappuccino'] = {
		label = 'Cappuccino',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_tea'] = {
		label = 'Çay',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_hot_chocolate'] = {
		label = 'Sıcak Çikolata',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_orange_juice'] = {
		label = 'Portakal Suyu',
		weight = 300,
		stack = true,
		close = true,
	},

	['venue_sandwich'] = {
		label = 'Sandviç',
		weight = 300,
		stack = true,
		close = true,
	},
	['dd_bs_bleeder'] = {
		label = 'The Bleeder',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_cheeseburger'] = {
		label = 'Cheeseburger',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_money_shot'] = {
		label = 'Money Shot',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_heart_stopper'] = {
		label = 'Heart Stopper',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_bacon_burger'] = {
		label = 'Baconlı Burger',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_bacon_cheeseburger'] = {
		label = 'Baconlı Cheeseburger',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_chicken_burger'] = {
		label = 'Tavuk Burger',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_chicken_melt'] = {
		label = 'Tavuklu Melt',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_meat_free'] = {
		label = 'Etsiz Burger',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_chicken_wrap'] = {
		label = 'Tavuk Dürüm',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_veggie_wrap'] = {
		label = 'Sebzeli Dürüm',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_chicken_salad'] = {
		label = 'Tavuklu Salata',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_garden_salad'] = {
		label = 'Bahçe Salatası',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_fries'] = {
		label = 'Patates Kızartması',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_large_fries'] = {
		label = 'Büyük Patates Kızartması',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_cheese_fries'] = {
		label = 'Peynirli Patates',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_onion_rings'] = {
		label = 'Soğan Halkası',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_nuggets_6'] = {
		label = 'Nugget (6 adet)',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_nuggets_9'] = {
		label = 'Nugget (9 adet)',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_chicken_strips'] = {
		label = 'Çıtır Tavuk',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_ecola'] = {
		label = 'eCola',
		weight = 350,
		stack = true,
		close = true,
	},

	['dd_bs_sprunk'] = {
		label = 'Sprunk',
		weight = 350,
		stack = true,
		close = true,
	},

	['dd_bs_orange_juice'] = {
		label = 'Portakal Suyu',
		weight = 350,
		stack = true,
		close = true,
	},

	['dd_bs_coffee'] = {
		label = 'Kahve',
		weight = 350,
		stack = true,
		close = true,
	},

	['dd_bs_latte'] = {
		label = 'Latte',
		weight = 350,
		stack = true,
		close = true,
	},

	['dd_bs_iced_coffee'] = {
		label = 'Buzlu Kahve',
		weight = 350,
		stack = true,
		close = true,
	},

	['dd_bs_hot_chocolate'] = {
		label = 'Sıcak Çikolata',
		weight = 350,
		stack = true,
		close = true,
	},

	['dd_bs_chocolate_shake'] = {
		label = 'Çikolatalı Milkshake',
		weight = 350,
		stack = true,
		close = true,
	},

	['dd_bs_strawberry_shake'] = {
		label = 'Çilekli Milkshake',
		weight = 350,
		stack = true,
		close = true,
	},

	['dd_bs_vanilla_shake'] = {
		label = 'Vanilyalı Milkshake',
		weight = 350,
		stack = true,
		close = true,
	},

	['dd_bs_chocolate_sundae'] = {
		label = 'Çikolatalı Sundae',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_strawberry_sundae'] = {
		label = 'Çilekli Sundae',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_chocolate_donut'] = {
		label = 'Çikolatalı Donut',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_strawberry_donut'] = {
		label = 'Çilekli Donut',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_cookie'] = {
		label = 'Çikolatalı Kurabiye',
		weight = 250,
		stack = true,
		close = true,
	},

	['dd_bs_bun'] = {
		label = 'Hamburger Ekmeği',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_patty'] = {
		label = 'Dana Köfte',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_veggie_patty'] = {
		label = 'Sebze Köftesi',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_chicken'] = {
		label = 'Tavuk Fileto',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_bacon'] = {
		label = 'Bacon',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_cheddar'] = {
		label = 'Cheddar Dilimi',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_lettuce'] = {
		label = 'Marul',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_tomato'] = {
		label = 'Domates',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_onion'] = {
		label = 'Soğan',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_pickle'] = {
		label = 'Turşu',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_sauce'] = {
		label = 'Burger Sosu',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_tortilla'] = {
		label = 'Tortilla',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_frozen_fries'] = {
		label = 'Donuk Patates',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_frozen_rings'] = {
		label = 'Donuk Soğan Halkası',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_frozen_nuggets'] = {
		label = 'Donuk Nugget',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_oil'] = {
		label = 'Kızartma Yağı',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_flour'] = {
		label = 'Un',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_sugar'] = {
		label = 'Şeker',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_cola_syrup'] = {
		label = 'eCola Şurubu',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_sprunk_syrup'] = {
		label = 'Sprunk Şurubu',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_orange'] = {
		label = 'Portakal',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_coffee_beans'] = {
		label = 'Kahve Çekirdeği',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_milk'] = {
		label = 'Süt',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_icecream'] = {
		label = 'Dondurma Karışımı',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_chocolate'] = {
		label = 'Çikolata',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_strawberry'] = {
		label = 'Çilek',
		weight = 100,
		stack = true,
		close = true,
	},

	['dd_bs_cup'] = {
		label = 'Burger Shot Bardağı',
		weight = 100,
		stack = true,
		close = true,
	},

	-- 0r-activities
	['rub_trolley'] = {
		label = 'Market Arabası',
		weight = 6500,
		stack = false,
		close = true,
		consume = 0,
		description = 'Sürücü ve bir yolcu taşıyabilen market arabası.',
		client = { image = 'nui://0r-activities/items/images/rub_trolley.png' },
		server = { export = '0r-activities.useUtilityVehicles' }
	},
	['canoe'] = {
		label = 'Kano',
		weight = 9000,
		stack = false,
		close = true,
		consume = 0,
		description = 'İki kişilik kano.',
		client = { image = 'nui://0r-activities/items/images/canoe.png' },
		server = { export = '0r-activities.useCanoe' }
	},
	['roller_skates'] = {
		label = 'Paten',
		weight = 2800,
		stack = false,
		close = true,
		consume = 0,
		description = 'Bir çift tekerlekli paten.',
		client = { image = 'nui://0r-activities/items/images/roller_skates.png' },
		server = { export = '0r-activities.useGroundGear' }
	},
	['0r_skateboard'] = {
		label = 'Kaykay',
		weight = 3800,
		stack = false,
		close = true,
		consume = 0,
		description = 'Binilip taşınabilen kaykay.',
		client = { image = 'nui://0r-activities/items/images/skateboard.png' },
		server = { export = '0r-activities.useGroundGear' }
	},
	['0r_hoverboard'] = {
		label = 'Hoverboard',
		weight = 3800,
		stack = false,
		close = true,
		consume = 0,
		description = 'Binilip taşınabilen hoverboard.',
		client = { image = 'nui://0r-activities/items/images/hoverboard.png' },
		server = { export = '0r-activities.useGroundGear' }
	},
	['surfboard_sunset_ray'] = {
		label = 'Sörf Tahtası (Sunset Ray)',
		weight = 4500,
		stack = false,
		close = true,
		consume = 0,
		description = 'Sunset Ray desenli sörf tahtası.',
		client = { image = 'nui://0r-activities/items/images/surfboard_sunset_ray.png' },
		server = { export = '0r-activities.useWaterBoard' }
	},
	['surfboard_sea_drifter'] = {
		label = 'Sörf Tahtası (Sea Drifter)',
		weight = 4500,
		stack = false,
		close = true,
		consume = 0,
		description = 'Sea Drifter desenli sörf tahtası.',
		client = { image = 'nui://0r-activities/items/images/surfboard_sea_drifter.png' },
		server = { export = '0r-activities.useWaterBoard' }
	},
	['surfboard_lifeguard'] = {
		label = 'Cankurtaran Sörf Tahtası',
		weight = 4500,
		stack = false,
		close = true,
		consume = 0,
		description = 'Cankurtaran tipi sörf tahtası.',
		client = { image = 'nui://0r-activities/items/images/surfboard_lifeguard.png' },
		server = { export = '0r-activities.useWaterBoard' }
	},
	['surfboard_venice_02'] = {
		label = 'Sörf Tahtası (Venice Classic II)',
		weight = 4500,
		stack = false,
		close = true,
		consume = 0,
		description = 'Venice Classic serisinden sörf tahtası.',
		client = { image = 'nui://0r-activities/items/images/surfboard_venice_02.png' },
		server = { export = '0r-activities.useWaterBoard' }
	},
	['paddleboard'] = {
		label = 'Kürek Sörfü',
		weight = 4500,
		stack = false,
		close = true,
		consume = 0,
		description = 'Küreğiyle birlikte kürek sörfü tahtası.',
		client = { image = 'nui://0r-activities/items/images/paddleboard.png' },
		server = { export = '0r-activities.useWaterBoard' }
	},
	-- daddy_venue: market crates (cloud-shop); put in a business depot each one is 10 portions of stock
	['daddy_crate_grocery'] = { label = 'Bakkaliye Kolisi', weight = 2000, stack = true, close = true, description = 'Şeker, tuz, baharat, pirinç, makarna, kakao, soslar. İşletme deposunda 10 porsiyon.' },
	['daddy_crate_produce'] = { label = 'Manav Kasası', weight = 2000, stack = true, close = true, description = 'Meyveler ve çiftlikte olmayan sebzeler. İşletme deposunda 10 porsiyon.' },
	['daddy_crate_hotdrink'] = { label = 'Sıcak İçecek Kolisi', weight = 2000, stack = true, close = true, description = 'Kahve, çay, matcha. İşletme deposunda 10 porsiyon.' },
	['daddy_crate_soda'] = { label = 'Meşrubat ve Buz Kolisi', weight = 2000, stack = true, close = true, description = 'Kola, tonik, soda, enerji içeceği, buz. İşletme deposunda 10 porsiyon.' },
	['daddy_crate_liquor'] = { label = 'Likör ve Aroma Kasası', weight = 2000, stack = true, close = true, description = 'Likörler, vermut, bitter, kokteyl şurupları. İşletme deposunda 10 porsiyon.' },
	['daddy_crate_seafood'] = { label = 'Deniz Ürünleri Kasası', weight = 2000, stack = true, close = true, description = 'Karides, ıstakoz, ahtapot, kalamar, midye, ton balığı. İşletme deposunda 10 porsiyon.' },
	-- bzzz_food_bundles: Paddock Bar menüsü (daddy_venue install/menu-plan.md)
	['beer_original'] = {
		label = 'Fıçı Bira',
		weight = 200,
		stack = true,
		close = true,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_prop_beer_original`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			bone = 60309,
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['beer_kiwi'] = {
		label = 'Kivili Bira',
		weight = 200,
		stack = true,
		close = true,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_prop_beer_kiwi`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			bone = 60309,
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['beer_raspberry'] = {
		label = 'Ahududulu Bira',
		weight = 200,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_prop_beer_raspberry`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			bone = 60309,
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_beer_d'] = {
		label = 'Bardak Bira',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_beer_d`, pos = vec3(0.04, 0.02, -0.02), rot = vec3(5.0, -4.0, 28.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_gintonic_a'] = {
		label = 'Cin Tonik',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_gintonic_a`, pos = vec3(0.02, 0.02, -0.05), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_tomcollins_a'] = {
		label = 'Tom Collins',
		weight = 350,
		client = {
			status = { thirst = 700000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_tomcollins_a`, pos = vec3(0.02, 0.02, -0.05), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_negroni_a'] = {
		label = 'Negroni',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_negroni_a`, pos = vec3(0.03, 0.02, 0.04), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_martini_a'] = {
		label = 'Martini',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_martini_a`, pos = vec3(0.04, 0.01, 0.0), rot = vec3(12.0, -8.0, -48.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_oldfashioned_a'] = {
		label = 'Old Fashioned',
		weight = 350,
		client = {
			status = { thirst = 600000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_oldfashioned_a`, pos = vec3(0.03, 0.02, 0.04), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_bluelagoon_a'] = {
		label = 'Blue Lagoon',
		weight = 350,
		client = {
			status = { thirst = 600000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_bluelagoon_a`, pos = vec3(0.02, 0.02, -0.03), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_longislandicedtea_a'] = {
		label = 'Long Island',
		weight = 350,
		client = {
			status = { thirst = 750000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_longislandicedtea_a`, pos = vec3(0.02, 0.02, -0.03), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_moscowmule_a'] = {
		label = 'Moscow Mule Shot',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_moscowmule_a`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(12.0, -8.0, 18.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_shot_lemondrop_a'] = {
		label = 'Lemon Drop Shot',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_shot_lemondrop_a`, pos = vec3(0.0, 0.01, 0.07), rot = vec3(12.0, -8.0, 18.0) },
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['glass_orange'] = {
        label = 'Taze Portakal Suyu',
		degrade = 4320,-- 72 stunden
        weight = 100,
        stack = true,
		close = true,
        client = {
            status = { thirst = 500000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_drink_juice_glass_orange',
            pos = vec3(0.01, 0.01, -0.10), rot = vec3(0.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 8000,
        },
    },
	['glass_apple'] = {
        label = 'Elma Suyu',
		degrade = 4320,-- 72 stunden
        weight = 100,
        stack = true,
		close = true,
        client = {
            status = { thirst = 500000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_drink_juice_glass_apple',
             pos = vec3(0.01, 0.01, -0.10), rot = vec3(0.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 8000,
        },
    },
	['bzzz_pepsiloca_a'] = {
		label = 'Pepsiloca',
		weight = 500,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_new_snacks_pepsiloca_a`, pos = vec3(0.01 ,0.00, 0.07), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['bzzz_energy'] = {
		label = 'Enerji İçeceği',
		weight = 500,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_new_snacks_energy_a`, pos = vec3(0.01 ,0.00, 0.05), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['bzzz_food_grill_steak_grill_a'] = {
		label = 'Izgara Biftek',
		weight = 250,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_food_grill_steak_grill_a`, pos = vec3(0.03, -0.03, -0.02), rot = vec3(18.0, -35.0, 64.0) },
			usetime = 5000,
			notification = 'Afiyet olsun!'
		}
	},
	['bzzz_food_grill_steak_grill_c'] = {
		label = 'T-Bone Biftek',
		weight = 400,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_food_grill_steak_grill_c`, pos = vec3(0.06, -0.04, -0.02), rot = vec3(24.0, 30.0, -62.0) },
			usetime = 5000,
			notification = 'Afiyet olsun!'
		}
	},
	['bzzz_food_grill_burger_grill_d'] = {
		label = 'Izgara Burger',
		weight = 600,
		client = {
			status = { hunger = 850000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_food_grill_burger_grill_d`, pos = vec3(0.0, -0.02, -0.03), rot = vec3(0.0, 0.0, -50.0) },
			usetime = 5000,
			notification = 'Afiyet olsun!'
		}
	},
	['bzzz_prop_fastfood_bigburger_a'] = {
		label = 'Big Burger',
		weight = 500,
		client = {
			status = { hunger = 1000000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_prop_fastfood_bigburger_a`, pos = vec3(-0.01, 0.0, -0.02), rot = vec3(31.0, 15.0, 0.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['bzzz_prop_fastfood_cheeseburger_a'] = {
		label = 'Cheeseburger',
		weight = 500,
		client = {
			status = { hunger = 1000000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_prop_fastfood_cheeseburger_a`, pos = vec3(-0.01, 0.0, -0.02), rot = vec3(31.0, 15.0, 0.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['res_food_f'] = {
        label = 'Biftek ve Kızartma',
        degrade = 2880,-- 48 stunden
        weight = 200,
        stack = false,
		close = true,
        client = {
            status = { hunger = 800000 },
            anim = { dict = 'bzzz@restaurant@eat', clip = 'bzzz_restaurant_eat' },

            prop = { model = 'bzzz_restaurant_food_f',
            bone = 60309,
            pos = vec3(0.08, -0.04, 0.07),
            rot = vec3(-30.0, 10.0, 0.0) },

            propTwo = { model = 'bzzz_restaurant_fork_a',
			bone = 28422,
            pos = vec3(0.07, 0.05, -0.03),
            rot = vec3(-100.0, 24.0, -86.0) },

            usetime = 17500,
        },
    },
	['res_food_a'] = {
        label = 'Şinitzel ve Patates',
        degrade = 2880,-- 48 stunden
        weight = 200,
        stack = false,
		close = true,
        client = {
            status = { hunger = 800000 },
            anim = { dict = 'bzzz@restaurant@eat', clip = 'bzzz_restaurant_eat' },

            prop = { model = 'bzzz_restaurant_food_a',
            bone = 60309,
            pos = vec3(0.08, -0.04, 0.07),
            rot = vec3(-30.0, 10.0, 0.0) },

            propTwo = { model = 'bzzz_restaurant_fork_a',
            bone = 28422,
            pos = vec3(0.07, 0.05, -0.03),
            rot = vec3(-100.0, 24.0, -86.0) },

            usetime = 17500,
			notification = 'Afiyet olsun!'
        },
    },
	['bzzz_food_grill_skewer_grill_a'] = {
		label = 'Et Şiş',
		weight = 200,
		client = {
			status = { hunger = 900000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_food_grill_skewer_grill_a`, pos = vec3(0.04, -0.02, -0.03), rot = vec3(15.0, -30.0, 65.0) },
			usetime = 5000,
			notification = 'Afiyet olsun!'
		}
	},
	['bzzz_food_grill_chicken_grill_c'] = {
		label = 'Tavşan Kanat',
		weight = 300,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_food_grill_chicken_grill_c`, pos = vec3(-0.01, 0.0, 0.0), rot = vec3(-20.0, -16.0, -83.0) },
			usetime = 5000,
			notification = 'Afiyet olsun!'
		}
	},
	['bzzz_prop_fastfood_frenchfries_a'] = {
        label = 'Parmak Patates',
        degrade = 2880,
        weight = 200,
        stack = true,
		close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'bzzz_fastfood_anim1', clip = 'anim1' },

            prop = { model = 'bzzz_prop_fastfood_frenchfries_a',
            bone = 60309,
            pos = vec3(0.09, 0.04, 0.05),
            rot = vec3(-80.0, 50.0, 0.0) },

            propTwo = { model = 'bzzz_prop_fastfood_fries_c',
            bone = 28422,
            pos = vec3(0.07, 0.04, -0.03),
            rot = vec3(-100.0, -40.0, -30.0) },

            usetime = 4000,
			notification = 'Afiyet olsun!'
        },
    },
	['bzzz_prop_fastfood_onion_b'] = {
        label = 'Soğan Halkası',
        degrade = 2880,
        weight = 200,
        stack = true,
		close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'bzzz_fastfood_anim2', clip = 'anim2' },

            prop = { model = 'bzzz_prop_fastfood_onion_b',
            bone = 60309,
            pos = vec3(0.16, 0.02, 0.02),
            rot = vec3(30.0, 35.0, 134.0) },

            propTwo = { model = 'bzzz_prop_fastfood_onion_a',
            bone = 28422,
            pos = vec3(0.08, 0.06, -0.05),
            rot = vec3(13.0, 50.0, 124.0) },

            usetime = 4000,
			notification = 'Afiyet olsun!'
        },
    },
	['bzzz_prop_fastfood_friedcheese_a'] = {
        label = 'Peynir Kızartması',
        degrade = 2880,
        weight = 200,
        stack = true,
		close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'bzzz_fastfood_anim2', clip = 'anim2' },

            prop = { model = 'bzzz_prop_fastfood_friedcheese_a',
            bone = 60309,
            pos = vec3(0.16, 0.02, 0.02),
            rot = vec3(30.0, 35.0, 134.0) },


            usetime = 4000,
			notification = 'Afiyet olsun!'
        },
    },
	['nachos_a'] = {
        label = 'Peynirli Nachos',
		weight = 250,
		stack = true,
		close = true,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'anim@scripted@island@special_peds@pavel@hs4_pavel_ig5_caviar_p1', clip = 'base_idle' },
            prop = { model = `bzzz_food_nachos_a`, pos = vec3(-0.04, 0.07, -0.01), rot = vec3(0.00, 0.00, 0.00) },
			bone = 60309,
			usetime = 25500,
			notification = 'Afiyet olsun!'
		},
	},
	['bzzz_prop_fastfood_vegesalad_a'] = {
        label = 'Vejetaryen Salata',
        degrade = 2880,
        weight = 200,
        stack = true,
		close = true,
        client = {
            status = { hunger = 550000 },
            anim = { dict = 'bzzz_fastfood_anim2', clip = 'anim2' },

            prop = { model = 'bzzz_prop_fastfood_vegesalad_a',
            bone = 60309,
            pos = vec3(0.11, -0.01, 0.05),
            rot = vec3(-30.0, 10.0, 0.0) },

            propTwo = { model = 'bzzz_prop_fastfood_vegesalad_b',
            bone = 28422,
            pos = vec3(0.07, 0.04, -0.03),
            rot = vec3(-100.0, -40.0, -30.0) },

            usetime = 4000,
			notification = 'Afiyet olsun!'
        },
    },
	['bzzz_sugary_cheesecake_a'] = {
		label = 'Cheesecake',
		weight = 200,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_cheesecake_a`, pos = vec3(0.0, 0.02, -0.02), rot = vec3(16.0, 16.0, -18.0) },
			usetime = 4500,
			notification = 'Afiyet olsun!'
		}
	},
	['bzzz_sugary_cake_a'] = {
		label = 'Çikolatalı Pasta',
		weight = 200,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_cake_a`, pos = vec3(-0.02, 0.0, -0.02), rot = vec3(10.0, 7.0, -42.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['bzzz_sugary_tiramisu_a'] = {
		label = 'Tiramisu',
		weight = 100,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_tiramisu_a`, pos = vec3(-0.02, 0.0, -0.01), rot = vec3(20.0, -32.0, 82.0) },
			usetime = 4500,
			notification = 'Afiyet olsun!'
		}
	},
	['icecream_chc'] = { -- brain cold go brrrrr
        label = 'Çikolatalı Dondurma',
		degrade = 1440,-- 24 stunden
        weight = 250,
        stack = true,
		close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'bzzz_icecream_chocolate',
            bone = 18905,
            pos = vec3(0.10, 0.03, 0.03),
            rot = vec3(105.0, 70.0, -203.0) },
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['bzzz_sugary_brownies_a'] = {
		label = 'Brownie',
		weight = 150,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_brownies_a`, pos = vec3(-0.02, 0.0, -0.02), rot = vec3(10.0, 0.0, 0.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	-- bzzz_food_bundles: Pier Bar menüsü (daddy_venue install/menu-plan.md)
	['beer_plum'] = {
		label = 'Erikli Bira',
		weight = 200,
		stack = true,
		close = true,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_prop_beer_plum`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			bone = 60309,
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_beer_c'] = {
		label = 'Küçük Bira',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_beer_c`, pos = vec3(0.04, 0.02, -0.02), rot = vec3(5.0, -4.0, 28.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_beer_a'] = {
		label = 'Büyük Bira',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_beer_a`, pos = vec3(0.03, 0.02, -0.01), rot = vec3(5.0, -4.0, 28.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_sexonthebeach_a'] = {
		label = 'Sex on the Beach',
		weight = 350,
		client = {
			status = { thirst = 600000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_longislandicedtea_a`, pos = vec3(0.02, 0.02, -0.03), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_bahamamama_a'] = {
		label = 'Bahama Mama',
		weight = 350,
		client = {
			status = { thirst = 750000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_bahamamama_a`, pos = vec3(0.02, 0.02, -0.03), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_maitai_a'] = {
		label = 'Mai Tai',
		weight = 350,
		client = {
			status = { thirst = 750000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_maitai_a`, pos = vec3(0.03, 0.02, 0.04), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_rumcoke_a'] = {
		label = 'Rom Kola',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_rumcoke_a`, pos = vec3(0.02, 0.02, -0.05), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['bzzz_drink_coconut_a'] = {
		label = 'Hindistan Cevizi Kokteyli',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_coconut_a`, pos = vec3(0.07, 0.05, 0.04), rot = vec3(28.0, -50.0, 14.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['glass_pineapple'] = {
        label = 'Ananas Suyu',
		degrade = 4320,-- 72 stunden
        weight = 100,
        stack = true,
		close = true,
        client = {
            status = { thirst = 500000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_drink_juice_glass_pineapple',
            pos = vec3(0.01, 0.01, -0.10), rot = vec3(0.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 8000,
        },
    },
	['glass_grapefruit'] = {
        label = 'Greyfurt Suyu',
		degrade = 4320,-- 72 stunden
        weight = 100,
        stack = true,
		close = true,
        client = {
            status = { thirst = 500000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_drink_juice_glass_grapefruit',
            pos = vec3(0.01, 0.01, -0.10), rot = vec3(0.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 8000,
        },
    },
	['box_orange'] = {
        label = 'Kutu Portakal Suyu',
		degrade = 4320,-- 72 stunden
        weight = 100,
        stack = true,
		close = true,
        client = {
            status = { thirst = 500000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_drink_juice_box_orange',
            pos = vec3(0.01, 0.06, -0.18), rot = vec3(2.0, -4.0, 122.0) },
			bone = 60309,
            usetime = 16000,
        },
    },
	['bzzz_pepsiloca_b'] = {
		label = 'Pepsiloca Light',
		weight = 500,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_new_snacks_pepsiloca_b`, pos = vec3(0.01 ,0.00, 0.07), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['bzzz_englishfood_fishchips_a'] = {
        label = 'Fish & Chips',
        degrade = 2880,
        weight = 1000,
        stack = false,
		close = true,
        client = {
            status = { hunger = 600000 },
            anim = { dict = 'bzzz_englishfood_animations', clip = 'anim2' },

            prop = { model = 'bzzz_englishfood_fishchips_a',
            bone = 60309,
            pos = vec3(0.08, 0.01, 0.055),
            rot = vec3(-30.0, 0.0, 0.0) },

            propTwo = { model = 'bzzz_englishfood_fishchips_a2',
            bone = 28422,
            pos = vec3(0.07, 0.04, -0.03),
            rot = vec3(-100.0, -40.0, -30.0) },

            usetime = 17500,
			notification = 'Afiyet olsun!'
        },
    },
	['bzzz_food_grill_fish_grill_a'] = {
		label = 'Izgara Balık',
		weight = 300,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_food_grill_fish_grill_a`, pos = vec3(0.06, 0.00, -0.04), rot = vec3(-20.0, -16.0, -83.0) },
			usetime = 5000,
			notification = 'Afiyet olsun!'
		}
	},
	['bzzz_food_grill_salmon_grill_a'] = {
		label = 'Izgara Somon',
		weight = 200,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_food_grill_salmon_grill_a`, pos = vec3(0.0, -0.02, -0.02), rot = vec3(25.0, -35.0, 64.0) },
			usetime = 5000,
			notification = 'Afiyet olsun!'
		}
	},
	['bzzz_sushi_crabcakes_b'] = {
        label = 'Yengeç Köftesi',
        degrade = 2880,-- inedible after 48 hours
        weight = 200, -- edit the value as you need
        stack = false,
		close = true,
        client = {
            status = { hunger = 900000 }, -- edit the value as you need
            anim = { dict = 'bzzz_sushi_eat', clip = 'bzzz_sushi_eat' },

            prop = { model = 'bzzz_sushi_crabcakes_b',
            bone = 60309,
            pos = vec3(0.17, 0.0, 0.03),
            rot = vec3(-30.0, 15.0, 35.0) },

            propTwo = { model = 'bzzz_sushi_crabcakes_a',
			bone = 28422,
            pos = vec3(0.09, 0.05, -0.04),
            rot = vec3(-60.0, -75.0, 45.0) },

            usetime = 5000, -- edit the value as you need
			notification = 'Afiyet olsun!'
        },
    },
	['bzzz_sushi_softshellcrab_b'] = {
        label = 'Çıtır Yengeç',
        degrade = 2880,-- inedible after 48 hours
        weight = 200, -- edit the value as you need
        stack = false,
		close = true,
        client = {
            status = { hunger = 900000 }, -- edit the value as you need
            anim = { dict = 'bzzz_sushi_eat', clip = 'bzzz_sushi_eat' },

            prop = { model = 'bzzz_sushi_softshellcrab_b',
            bone = 60309,
            pos = vec3(0.17, 0.0, 0.03),
            rot = vec3(-30.0, 15.0, 35.0) },

            propTwo = { model = 'bzzz_sushi_moulesmarinieres_b',
			bone = 28422,
            pos = vec3(0.08, 0.05, -0.03),
            rot = vec3(-90.0, -27.0, -27.0) },

            usetime = 5000, -- edit the value as you need
			notification = 'Afiyet olsun!'
        },
    },
	['bzzz_sushi_friedcalamari_b'] = {
        label = 'Kalamar Tava',
        degrade = 2880,-- inedible after 48 hours
        weight = 200, -- edit the value as you need
        stack = false,
		close = true,
        client = {
            status = { hunger = 650000 }, -- edit the value as you need
            anim = { dict = 'bzzz_sushi_eat', clip = 'bzzz_sushi_eat' },

            prop = { model = 'bzzz_sushi_friedcalamari_b',
            bone = 60309,
            pos = vec3(0.17, 0.0, 0.03),
            rot = vec3(-30.0, 15.0, 35.0) },

            propTwo = { model = 'bzzz_sushi_friedcalamari_a',
			bone = 28422,
            pos = vec3(0.08, 0.05, -0.03),
            rot = vec3(-90.0, -27.0, -27.0) },

            usetime = 5000, -- edit the value as you need
			notification = 'Afiyet olsun!'
        },
    },
	['bzzz_sushi_coconutshrimp_b'] = {
        label = 'Hindistan Cevizli Karides',
        degrade = 2880,-- inedible after 48 hours
        weight = 200, -- edit the value as you need
        stack = false,
		close = true,
        client = {
            status = { hunger = 850000 }, -- edit the value as you need
            anim = { dict = 'bzzz_sushi_eat', clip = 'bzzz_sushi_eat' },

            prop = { model = 'bzzz_sushi_coconutshrimp_b',
            bone = 60309,
            pos = vec3(0.17, 0.0, 0.03),
            rot = vec3(-30.0, 15.0, 35.0) },

            propTwo = { model = 'bzzz_sushi_coconutshrimp_c',
			bone = 28422,
            pos = vec3(0.07, 0.05, -0.03),
            rot = vec3(-111.0, -84.0, -21.0) },

            usetime = 5000, -- edit the value as you need
			notification = 'Afiyet olsun!'
        },
    },
	['res_food_j'] = {
        label = 'Soslu Karides',
        degrade = 2880,-- 48 stunden
        weight = 200,
        stack = false,
		close = true,
        client = {
            status = { hunger = 850000 },
            anim = { dict = 'bzzz@restaurant@eat', clip = 'bzzz_restaurant_eat' },

            prop = { model = 'bzzz_restaurant_food_j',
            bone = 60309,
            pos = vec3(0.08, -0.04, 0.07),
            rot = vec3(-30.0, 10.0, 0.0) },

            propTwo = { model = 'bzzz_restaurant_material_shrimp_a',
			bone = 28422,
            pos = vec3(0.07, 0.05, -0.03),
            rot = vec3(-100.0, 24.0, -86.0) },
            usetime = 17500,
			notification = 'Afiyet olsun!'
        },
    },
	['fishball_a'] = {
		label = 'Balık Köftesi Şiş',
		weight = 350,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_skewerpack_fishball_a`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(-10.0, -90.0, 0.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['fish_a'] = {
		label = 'Balık Şiş',
		weight = 350,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_skewerpack_fish_a`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(-10.0, -90.0, 0.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['bzzz_prop_fastfood_fries_d'] = {
        label = 'Kova Patates',
        degrade = 2880,
        weight = 200,
        stack = true,
		close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'bzzz_fastfood_anim2', clip = 'anim2' },

            prop = { model = 'bzzz_prop_fastfood_fries_d',
            bone = 60309,
            pos = vec3(0.12, 0.06, 0.08),
            rot = vec3(30.0, 35.0, 134.0) },

            propTwo = { model = 'bzzz_prop_fastfood_fries_c',
            bone = 28422,
            pos = vec3(0.06, 0.05, -0.04),
            rot = vec3(13.0, 50.0, 124.0) },

            usetime = 4000,
			notification = 'Afiyet olsun!'
        },
    },
	['chips_c'] = {
		label = 'Sarımsaklı Cips',
		weight = 350,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'bzzz_eating_chips', clip = 'eat_chip' },
			prop = { model = `bzzz_prop_chips_c_open`, bone = 60309, pos = vec3(0.11, 0.05, 0.04), rot = vec3(97.2, -14.2, 150.6) },
			propTwo = { model = `bzzz_prop_chip_b`, bone = 28422, pos = vec3(0.1, 0.05, -0.04), rot = vec3(-14.0, 70.0, 63.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['bzzz_food_grill_corn_grill_a'] = {
		label = 'Közlenmiş Mısır',
		weight = 300,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_food_grill_corn_grill_a`, pos = vec3(0.04, -0.02, -0.03), rot = vec3(15.0, -30.0, 65.0) },
			usetime = 5000,
			notification = 'Afiyet olsun!'
		}
	},
	['bzzz_sushi_oystersonice_a'] = {
        label = 'Buzda İstiridye',
        degrade = 2880,-- inedible after 48 hours
        weight = 200, -- edit the value as you need
        stack = false,
		close = true,
        client = {
            status = { hunger = 700000 }, -- edit the value as you need
            anim = { dict = 'bzzz_sushi_eat', clip = 'bzzz_sushi_eat' },

            prop = { model = 'bzzz_sushi_oystersonice_a',
            bone = 60309,
            pos = vec3(0.07, 0.01, 0.04),
            rot = vec3(-30.0, 0.0, 0.0) },

            propTwo = { model = 'bzzz_sushi_oystersonice_b',
			bone = 28422,
            pos = vec3(0.09, 0.06, -0.03),
            rot = vec3(-30.0, 0.0, 0.0) },

            usetime = 4000, -- edit the value as you need
			notification = 'Afiyet olsun!'
        },
    },
	['icecream_lmn'] = { -- brain cold go brrrrr
        label = 'Limonlu Dondurma',
		degrade = 1440,-- 24 stunden
        weight = 250,
        stack = true,
		close = true,
        client = {
            status = { hunger = 600000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'bzzz_icecream_lemon',
            bone = 18905,
            pos = vec3(0.10, 0.03, 0.03),
            rot = vec3(105.0, 70.0, -203.0) },
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['icecream_sby'] = { -- brain cold go brrrrr
        label = 'Çilekli Dondurma',
		degrade = 1440,-- 24 stunden
        weight = 250,
        stack = true,
		close = true,
        client = {
            status = { hunger = 600000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'bzzz_icecream_strawberry',
            bone = 18905,
            pos = vec3(0.10, 0.03, 0.03),
            rot = vec3(105.0, 70.0, -203.0) },
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['bzzz_candy_cotton_pink'] = {
		label = 'Pembe Pamuk Şeker',
		weight = 500,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_candy_cotton_pink`, pos = vec3(-0.02, 0.01, -0.01), rot = vec3(0.0, -90.0, 0.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['bzzz_candy_cotton_blue'] = {
		label = 'Mavi Pamuk Şeker',
		weight = 500,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_candy_cotton_blue`, pos = vec3(-0.02, 0.01, -0.01), rot = vec3(0.0, -90.0, 0.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['orang'] = {
		label = 'Portakallı Buzlu Lolipop',
		weight = 350,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_popsicle_orang_b`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['chufty'] = {
		label = 'Çikolatalı Kaplama Dondurma',
		weight = 350,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_popsicle_chufty_b`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	-- bzzz_food_bundles: Pier Bar menüsü (daddy_venue install/menu-plan.md)
	['bzzz_prop_fastfood_friedfish_a'] = {
        label = 'Balık Kızartması',
        degrade = 2880,
        weight = 200,
        stack = true,
		close = true,
        client = {
            status = { hunger = 600000 },
            anim = { dict = 'bzzz_fastfood_anim2', clip = 'anim2' },

            prop = { model = 'bzzz_prop_fastfood_friedfish_a',
            bone = 60309,
            pos = vec3(0.16, 0.02, 0.02),
            rot = vec3(30.0, 35.0, 134.0) },


            usetime = 4000,
			notification = 'Afiyet olsun!'
        },
    },
	-- bzzz_food_bundles: Sahil Kafe menüsü (daddy_venue install/menu-plan.md)
	['coffeecup_a'] = {
        label = 'Filtre Kahve',
        weight = 200,
		stack = true,
		close = true,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = 'bzzz_food_cooffeecup01_a',
			pos = vec3(0.00, 0.02, 0.03), rot = vec3(0.00, 0.0, 0.0) },
			bone = 60309,
			usetime = 4000,
			notification = 'Şerefe!'
		},
	},
	['mug_a'] = {
        label = 'Türk Kahvesi',
        weight = 250,
		stack = true,
		close = true,
		--description = "something sweet",
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = 'bzzz_food_xmas_mug_a',
			pos = vec3(-0.01, 0.02, 0.00), rot = vec3(0.00, 0.0, 0.0) },
			bone = 60309,
			usetime = 8000,
			notification = 'Şerefe!'
		},
	},
	['mug_b'] = {
        label = 'Türk Çayı',
        weight = 250,
		stack = true,
		close = true,
		--description = "something sweet",
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = 'bzzz_food_xmas_mug_b',
			pos = vec3(0.00, 0.01, 0.00), rot = vec3(0.0, 0.0, 0.0) },
			bone = 60309,
			usetime = 8000,
			notification = 'Şerefe!'
		},
	},
	['bzzz_sushi_matcha_milk_tea_a'] = {
        label = 'Matcha Latte',
		degrade = 4320,--inedible after 72 hours
        weight = 100,
        stack = true,
		close = true,
        client = {
            status = { thirst = 500000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_sushi_matcha_milk_tea_a',
            pos = vec3(0.07, 0.02, -0.02), rot = vec3(-21.0, 0.0, 80.0) },
			bone = 60309,
            usetime = 8000,
        },
    },
	['bubbletea_a'] = {
        label = 'Bubble Tea',
        weight = 250,
		stack = true,
		close = true,
		client = {
			status = { thirst = 550000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = 'bzzz_food_bubbletea_a',
			pos = vec3(0.03, 0.01, 0.05), rot = vec3(0.00, 0.0, 0.0) },
			bone = 60309,
			usetime = 8000,
			notification = 'Şerefe!'
		},
	},
	['glass_strawberry'] = {
        label = 'Çilek Suyu',
		degrade = 4320,-- 72 stunden
        weight = 100,
        stack = true,
		close = true,
        client = {
            status = { thirst = 500000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_drink_juice_glass_strawberry',
            pos = vec3(0.01, 0.01, -0.10), rot = vec3(0.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 8000,
        },
    },
	['glass_peach'] = {
        label = 'Şeftali Suyu',
		degrade = 4320,-- 72 stunden
        weight = 100,
        stack = true,
		close = true,
        client = {
            status = { thirst = 500000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_drink_juice_glass_peach',
            pos = vec3(0.01, 0.01, -0.10), rot = vec3(0.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 8000,
        },
    },
	['glass_kiwi'] = {
        label = 'Kivi Suyu',
		degrade = 4320,-- 72 stunden
        weight = 100,
        stack = true,
		close = true,
        client = {
            status = { thirst = 500000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_drink_juice_glass_kiwi',
            pos = vec3(0.01, 0.01, -0.10), rot = vec3(0.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 8000,
        },
    },
	['glass_banana'] = {
        label = 'Muzlu Smoothie',
		degrade = 4320,-- 72 stunden
        weight = 100,
        stack = true,
		close = true,
        client = {
            status = { thirst = 500000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_drink_juice_glass_banana',
            pos = vec3(0.01, 0.01, -0.10), rot = vec3(0.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 8000,
        },
    },
	['toast_a'] = {
        label = 'Kaşarlı Tost',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
		close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_toast_a',
            pos = vec3(0.02, -0.01, -0.04),
            rot = vec3(48.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['toast_d'] = {
        label = 'Jambonlu Sandviç',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
		close = true,
        client = {
            status = { hunger = 750000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_toast_d',
            pos = vec3(-0.01, 0.01, -0.05),
            rot = vec3(54.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['bzzz_englishfood_sandwich_a'] = {
        label = "Baconlı Sandviç",
        degrade = 2880,
        weight = 500,
        stack = false,
		close = true,
        client = {
            status = { hunger = 750000 },
            anim = { dict = 'bzzz_englishfood_animations', clip = 'anim2' },

            prop = { model = 'bzzz_englishfood_plate_a',
            bone = 60309,
            pos = vec3(0.08, 0.01, 0.055),
            rot = vec3(-30.0, 0.0, 0.0) },

            propTwo = { model = 'bzzz_englishfood_sandwich_b',
            bone = 28422,
            pos = vec3(0.07, 0.01, -0.03),
            rot = vec3(12.0, 10.0, 58.0) },

            usetime = 10000,
			notification = 'Afiyet olsun!'
        },
    },
	['croissant_a'] = {
        label = 'Kruvasan',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
		close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_croissant_a',
            pos = vec3(0.03, 0.01, -0.05),
            rot = vec3(54.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['bagel'] = {
        label = 'Bagel',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
		close = true,
        client = {
			image = 'bzzz_food_bakery_bagel_a.png',
            status = { hunger = 500000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_bagel_a',
            pos = vec3(-0.01, -0.02, -0.04),
            rot = vec3(46.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['bowl_primavera'] = {
        label = 'Sebzeli Makarna',
        degrade = 2880,-- 48 stunden
        weight = 200,
        stack = false,
		close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'bzzz_bowl_eat', clip = 'bowl_eat' },

            prop = { model = 'bzzz_bowlfood_primavera_pasta_a',
            bone = 60309,
            pos = vec3(0.07, 0.03, 0.07),
            rot = vec3(-30.0, 0.0, 0.0) },

            propTwo = { model = 'bzzz_bowlfood_primavera_pasta_b',
			      bone = 28422,
            pos = vec3(0.04, 0.05, 0.0),
            rot = vec3(-90.0, -27.0, -27.0) },
            usetime = 17500,
			      notification = 'Afiyet olsun!'
        },
    },
	['coconut_b'] = {
		label = 'Hindistan Cevizi Dilimi',
		weight = 350,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_fruits_coconut_b`, bone = 60309, pos = vec3(-0.02, 0.01, 0.0), rot = vec3(30.0, -41.0, 80.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['dragon_fruit_b'] = {
		label = 'Ejder Meyvesi',
		weight = 350,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_fruits_dragon_fruit_b`, bone = 60309, pos = vec3(-0.02, 0.0, -0.01), rot = vec3(-46.0, 19.0, 170.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['bzzz_sugary_wafer_a'] = {
		label = 'Waffle',
		weight = 50,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_wafer_a`, pos = vec3(0.02, -0.04, -0.06), rot = vec3(20.0, -44.0, 72.0) },
			usetime = 4500,
			notification = 'Afiyet olsun!'
		}
	},
	['bzzz_sugary_pancakes_a'] = {
		label = 'Pankek',
		weight = 100,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_pancakes_a`, pos = vec3(-0.03, -0.01, 0.0), rot = vec3(40.0, -64.0, 52.0) },
			usetime = 4500,
			notification = 'Afiyet olsun!'
		}
	},
	['lemoncake_a'] = {
        label = 'Limonlu Kek',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
		close = true,
        client = {
            status = { hunger = 600000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_lemoncake_a',
            pos = vec3(0.03, -0.01, -0.06),
            rot = vec3(104.0, 100.0, -48.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['muffin_a'] = {
        label = 'Muffin',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
		close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_muffin_a',
            pos = vec3(0.04, -0.01, -0.03),
            rot = vec3(-12.0, -84.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['bzzz_sugary_macaron_a'] = {
		label = 'Çilekli Makaron',
		weight = 50,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_macaron_a`, pos = vec3(-0.03, -0.01, 0.0), rot = vec3(-11.0, -180.0, 76.0) },
			usetime = 4500,
			notification = 'Afiyet olsun!'
		}
	},
	['icecream_rpy'] = { -- brain cold go brrrrr
        label = 'Ahududulu Dondurma',
		degrade = 1440,-- 24 stunden
        weight = 250,
        stack = true,
		close = true,
        client = {
            status = { hunger = 600000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'bzzz_icecream_raspberry',
            bone = 18905,
            pos = vec3(0.10, 0.03, 0.03),
            rot = vec3(105.0, 70.0, -203.0) },
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['bzzz_food_grill_pineapple_grill_a'] = {
		label = 'Izgara Ananas',
		weight = 200,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_food_grill_pineapple_grill_a`, pos = vec3(-0.03, 0.0, -0.01), rot = vec3(2.0, -15.0, 106.0) },
			usetime = 5000,
			notification = 'Afiyet olsun!'
		}
	},
	['freeze'] = {
		label = 'Buzlu Şerbet',
		weight = 350,
		client = {
			status = { hunger = 650000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_popsicle_freeze_b`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	-- bzzz_food_bundles: Sahil Kafe menüsü (daddy_venue install/menu-plan.md)
	['bzzz_uwuprops_cappuccino_a'] = {
		label = 'Cappuccino',
		weight = 500,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_uwuprops_cappuccino_a`, pos = vec3(0.01, 0.01, 0.04), rot = vec3(0.0, -30.0, 30.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['bzzz_uwuprops_coffee_a'] = {
		label = 'Latte',
		weight = 500,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_uwuprops_coffee_a`, pos = vec3(0.01, 0.01, 0.04), rot = vec3(0.0, -30.0, 30.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['bzzz_uwuprops_drink_a'] = {
		label = 'Buzlu Latte',
		weight = 500,
		client = {
			status = { thirst = 550000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_uwuprops_drink_a`, pos = vec3(0.04, 0.01, 0.01), rot = vec3(0.0, -20.0, 25.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['bzzz_uwuprops_drink_b'] = {
		label = 'Buzlu Mocha',
		weight = 500,
		client = {
			status = { thirst = 750000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_uwuprops_drink_b`, pos = vec3(0.04, 0.01, 0.01), rot = vec3(0.0, -20.0, 25.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['bzzz_uwuprops_drink_c'] = {
		label = 'Buzlu Karamel Latte',
		weight = 500,
		client = {
			status = { thirst = 750000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_uwuprops_drink_c`, pos = vec3(0.04, 0.01, 0.01), rot = vec3(0.0, -20.0, 25.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['bzzz_uwuprops_drink_d'] = {
		label = 'Buzlu Vanilya Latte',
		weight = 500,
		client = {
			status = { thirst = 750000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_uwuprops_drink_d`, pos = vec3(0.04, 0.01, 0.01), rot = vec3(0.0, -20.0, 25.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['bzzz_uwuprops_icecream_a'] = {
		label = 'Kase Dondurma',
		weight = 500,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_uwuprops_icecream_a`, pos = vec3(-0.03, 0.0, -0.01), rot = vec3(-75.0, -4.0, 80.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Afiyet olsun!'
		}
	},

	-- daddy_camp
	['camp_tent_dome'] = { label = 'Kubbe Çadır', weight = 4000, stack = false, close = true, description = 'İki kişilik çadır: kullanınca kurulur', server = { export = 'daddy_camp.useItem' } },
	['camp_tent_cabin'] = { label = 'Kabin Çadır', weight = 9000, stack = false, close = true, description = 'Büyük aile çadırı: kullanınca kurulur', server = { export = 'daddy_camp.useItem' } },
	['camp_tent_canvas'] = { label = 'Kanvas Çadır', weight = 7000, stack = false, close = true, description = 'Klasik kanvas çadır: kullanınca kurulur', server = { export = 'daddy_camp.useItem' } },
	['camp_sleeping_bag'] = { label = 'Uyku Tulumu', weight = 1500, stack = false, close = true, description = 'Kullanınca serilir', server = { export = 'daddy_camp.useItem' } },
	['camp_tarp'] = { label = 'Branda', weight = 2500, stack = false, close = true, description = 'İki direkli branda: kullanınca kurulur', server = { export = 'daddy_camp.useItem' } },
	['camp_hammock'] = { label = 'Hamak', weight = 8000, stack = false, close = true, description = 'Ayaklı hamak', server = { export = 'daddy_camp.useItem' } },
	['camp_fire_pit'] = { label = 'Ateş Çukuru Taşları', weight = 6000, stack = false, close = true, description = 'Kamp ateşi için taş halka kur', server = { export = 'daddy_camp.useItem' } },
	['camp_grill'] = { label = 'Ateş Izgarası', weight = 2500, stack = false, close = true, description = 'Ateş çukurunun üstüne koy, üstünde pişir', server = { export = 'daddy_camp.useItem' } },
	['camp_tripod'] = { label = 'Üç Ayak ve Kazan', weight = 3500, stack = false, close = true, description = 'Ateşin üstüne kur, doldur, yahni pişir', server = { export = 'daddy_camp.useItem' } },
	['camp_firewood'] = { label = 'Odun Demeti', weight = 1500, stack = true, close = true, description = 'Ateşte yanar; kullanınca demet yere konur', server = { export = 'daddy_camp.useItem' } },
	['camp_firewood_stack'] = { label = 'Odun İstifi', weight = 9000, stack = false, close = true, description = 'Kampın yanına odun istifi', server = { export = 'daddy_camp.useItem' } },
	['camp_chopping_block'] = { label = 'Odun Kesme Kütüğü', weight = 6000, stack = false, close = true, description = 'Üstüne kütük koy, baltayla yar', server = { export = 'daddy_camp.useItem' } },
	['camp_log'] = { label = 'Kütük', weight = 2000, stack = true, close = true, description = 'Yarılıp odun olacak kütük' },
	['camp_axe'] = { label = 'Kamp Baltası', weight = 1200, stack = false, close = true, description = 'Kesme kütüğünde odun yarar' },
	['camp_matches'] = { label = 'Kibrit', weight = 50, stack = true, close = true, description = 'Ateş, meşale ya da ocak yakar' },
	['camp_log_bench'] = { label = 'Kütük Bank', weight = 8000, stack = false, close = true, description = 'Üç kişilik bank', server = { export = 'daddy_camp.useItem' } },
	['camp_stump'] = { label = 'Kütük Tabure', weight = 3000, stack = false, close = true, description = 'Oturmak için kütük', server = { export = 'daddy_camp.useItem' } },
	['camp_chair'] = { label = 'Kamp Sandalyesi', weight = 2500, stack = false, close = true, description = 'Katlanır kamp sandalyesi', server = { export = 'daddy_camp.useItem' } },
	['camp_flashlight'] = { label = 'El Feneri', weight = 400, stack = false, close = true, description = 'Kullanınca eline alırsın; kamp tuşlarıyla açılır ve yere konur', server = { export = 'daddy_camp.useItem' } },
	['camp_torch'] = { label = 'Meşale', weight = 700, stack = false, close = true, description = 'Kullanınca eline alırsın; çakmak ya da kibritle yanar, zamanla biter', server = { export = 'daddy_camp.useItem' } },
	['camp_lantern'] = { label = 'Gaz Lambası', weight = 1200, stack = false, close = true, description = 'Kullanınca eline alırsın; yere koy ya da fener direğine as', server = { export = 'daddy_camp.useItem' } },
	['camp_lantern_hook'] = { label = 'Fener Direği', weight = 2000, stack = false, close = true, description = 'Lamba asmak için demir direk', server = { export = 'daddy_camp.useItem' } },
	['camp_table'] = { label = 'Katlanır Kamp Masası', weight = 5000, stack = false, close = true, description = 'Kamp masası', server = { export = 'daddy_camp.useItem' } },
	['camp_cooler'] = { label = 'Soğutucu', weight = 4000, stack = false, close = true, description = 'Yiyecek ve içecek saklar; kamptaki herkes açabilir', server = { export = 'daddy_camp.useItem' } },
	['camp_stove'] = { label = 'Kamp Ocağı', weight = 2500, stack = false, close = true, description = 'Kahve ve kahvaltı için gaz ocağı', server = { export = 'daddy_camp.useItem' } },
	['camp_water_jug'] = { label = 'Su Bidonu', weight = 3000, stack = false, close = true, description = 'Kamp için su bidonu', server = { export = 'daddy_camp.useItem' } },
	['camp_backpack'] = { label = 'Sırt Çantası', weight = 2000, stack = false, close = true, description = 'Yere koy, içine eşya sakla', server = { export = 'daddy_camp.useItem' } },
	['camp_tent_bag'] = { label = 'Çadır Çantası', weight = 1500, stack = true, close = true, description = 'Kampa yakışan toplu çadır çantası: kullanınca yere konur', server = { export = 'daddy_camp.useItem' } },
	['camp_coffee_pot'] = { label = 'Kamp Kahve Demliği', weight = 800, stack = true, close = true, description = 'Emaye kahve demliği: kullanınca yere konur', server = { export = 'daddy_camp.useItem' } },
	['camp_skillet'] = { label = 'Döküm Tava', weight = 1500, stack = true, close = true, description = 'İyi yağlanmış döküm tava: kullanınca yere konur', server = { export = 'daddy_camp.useItem' } },
	['camp_mug'] = { label = 'Emaye Kupa', weight = 250, stack = true, close = true, description = 'Kenarı çentikli kamp kupası: kullanınca yere konur', server = { export = 'daddy_camp.useItem' } },
	['camp_canteen'] = { label = 'Matara', weight = 600, stack = true, close = true, description = 'Asker tipi matara: kullanınca yere konur', server = { export = 'daddy_camp.useItem' } },
	['camp_roast_stick'] = { label = 'Şiş Çubuğu', weight = 200, stack = false, close = true, description = 'Ateşte marşmelov ve sosis kızart' },
	['camp_marshmallow'] = { label = 'Marşmelov', weight = 50, stack = true, close = true, description = 'Ateşte kızarınca daha güzel' },
	['camp_marshmallow_toasted'] = { label = 'Kızarmış Marşmelov', weight = 50, stack = true, close = true, description = 'Altın sarısı, yapış yapış' },
	['camp_marshmallow_burnt'] = { label = 'Yanık Marşmelov', weight = 50, stack = true, close = true, description = 'Dışı kömür' },
	['camp_sausage'] = { label = 'Sosis', weight = 150, stack = true, close = true, description = 'Çiğ: şişte kızart' },
	['camp_sausage_cooked'] = { label = 'Kızarmış Sosis', weight = 150, stack = true, close = true, description = 'Ateşten yeni çıktı' },
	['camp_sausage_burnt'] = { label = 'Yanık Sosis', weight = 150, stack = true, close = true, description = 'Ateşte biraz fazla kaldı' },
	['camp_fish'] = { label = 'Taze Balık', weight = 400, stack = true, close = true, description = 'Ateşin yanında şişte pişir' },
	['camp_grilled_fish'] = { label = 'Ateşte Balık', weight = 350, stack = true, close = true, description = 'Çıtır derili, isli' },
	['camp_grilled_meat'] = { label = 'Izgara Et', weight = 350, stack = true, close = true, description = 'Kamp ızgarasında pişti' },
	['camp_breakfast_pack'] = { label = 'Kahvaltı Paketi', weight = 400, stack = true, close = true, description = 'Tava için yumurta ve pastırma' },
	['camp_breakfast'] = { label = 'Kamp Kahvaltısı', weight = 400, stack = true, close = true, description = 'Sahanda yumurta ve pastırma' },
	['camp_coffee_grounds'] = { label = 'Kahve', weight = 200, stack = true, close = true, description = 'Ocaktaki demlik için' },
	['camp_coffee'] = { label = 'Kamp Kahvesi', weight = 250, stack = true, close = true, description = 'Sıcak ve sert' },
	['camp_stew_pack'] = { label = 'Yahni Paketi', weight = 600, stack = true, close = true, description = 'Kazan için et ve sebze' },
	['camp_stew'] = { label = 'Kamp Yahnisi', weight = 500, stack = true, close = true, description = 'Kazandan bir kase koyu yahni' },
	-- bzzz_food_bundles: Bean Machine menüsü (daddy_venue install/menu-plan.md)
	['dd_bm_filtre_kahve'] = {
        label = 'Filtre Kahve',
        weight = 200,
		stack = true,
        close = true,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = 'bzzz_food_cooffeecup01_a',
			pos = vec3(0.00, 0.02, 0.03), rot = vec3(0.00, 0.0, 0.0) },
			bone = 60309,
			usetime = 4000,
			notification = 'Şerefe!'
		},
	},
	['dd_bm_americano'] = {
        label = 'Americano',
        weight = 200,
		stack = true,
        close = true,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = 'bzzz_food_cooffeecup01_a',
			pos = vec3(0.00, 0.02, 0.03), rot = vec3(0.00, 0.0, 0.0) },
			bone = 60309,
			usetime = 4000,
			notification = 'Şerefe!'
		},
	},
	['dd_bm_turk_kahvesi'] = {
        label = 'Türk Kahvesi',
        weight = 250,
		stack = true,
        close = true,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = 'bzzz_food_xmas_mug_a',
			pos = vec3(-0.01, 0.02, 0.00), rot = vec3(0.00, 0.0, 0.0) },
			bone = 60309,
			usetime = 8000,
			notification = 'Şerefe!'
		},
	},
	['dd_bm_latte'] = {
		label = 'Latte',
		weight = 500,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_uwuprops_coffee_a`, pos = vec3(0.01, 0.01, 0.04), rot = vec3(0.0, -30.0, 30.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['dd_bm_vanilyali_latte'] = {
		label = 'Vanilyalı Latte',
		weight = 500,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_uwuprops_coffee_a`, pos = vec3(0.01, 0.01, 0.04), rot = vec3(0.0, -30.0, 30.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['dd_bm_cappuccino'] = {
		label = 'Cappuccino',
		weight = 500,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_uwuprops_cappuccino_a`, pos = vec3(0.01, 0.01, 0.04), rot = vec3(0.0, -30.0, 30.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['dd_bm_mocha'] = {
		label = 'Mocha',
		weight = 500,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_uwuprops_cappuccino_a`, pos = vec3(0.01, 0.01, 0.04), rot = vec3(0.0, -30.0, 30.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['dd_bm_turk_cayi'] = {
        label = 'Türk Çayı',
        weight = 250,
		stack = true,
        close = true,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = 'bzzz_food_xmas_mug_b',
			pos = vec3(0.00, 0.01, 0.00), rot = vec3(0.0, 0.0, 0.0) },
			bone = 60309,
			usetime = 8000,
			notification = 'Şerefe!'
		},
	},
	['dd_bm_sutlu_ingiliz_cayi'] = {
        label = 'Sütlü İngiliz Çayı',
		degrade = 2880,
        weight = 150,
        stack = false,
        close = true,
        client = {
            status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_englishfood_tea_b',
            pos = vec3(0.02 ,0.0, 0.06),
            rot = vec3(0.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 5000,
			notification = 'Şerefe!'
        },
    },
	['dd_bm_buzlu_latte'] = {
		label = 'Buzlu Latte',
		weight = 500,
		client = {
			status = { thirst = 550000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_uwuprops_drink_a`, pos = vec3(0.04, 0.01, 0.01), rot = vec3(0.0, -20.0, 25.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['dd_bm_buzlu_mocha'] = {
		label = 'Buzlu Mocha',
		weight = 500,
		client = {
			status = { thirst = 750000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_uwuprops_drink_b`, pos = vec3(0.04, 0.01, 0.01), rot = vec3(0.0, -20.0, 25.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['dd_bm_buzlu_karamel_latte'] = {
		label = 'Buzlu Karamel Latte',
		weight = 500,
		client = {
			status = { thirst = 750000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_uwuprops_drink_c`, pos = vec3(0.04, 0.01, 0.01), rot = vec3(0.0, -20.0, 25.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['dd_bm_buzlu_vanilya_latte'] = {
		label = 'Buzlu Vanilya Latte',
		weight = 500,
		client = {
			status = { thirst = 750000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_uwuprops_drink_d`, pos = vec3(0.04, 0.01, 0.01), rot = vec3(0.0, -20.0, 25.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['dd_bm_bubble_tea'] = {
        label = 'Bubble Tea',
        weight = 250,
		stack = true,
        close = true,
		client = {
			status = { thirst = 550000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = 'bzzz_food_bubbletea_a',
			pos = vec3(0.03, 0.01, 0.05), rot = vec3(0.00, 0.0, 0.0) },
			bone = 60309,
			usetime = 8000,
			notification = 'Şerefe!'
		},
	},
	['dd_bm_esmer_sekerli_cay'] = {
        label = 'Esmer Şekerli Sütlü Çay',
		degrade = 4320,--inedible after 72 hours
        weight = 100,
        stack = true,
        close = true,
        client = {
            status = { thirst = 550000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_sushi_brown_sugar_milk_tea_a',
            pos = vec3(0.07, 0.02, -0.02), rot = vec3(-21.0, 0.0, 80.0) },
			bone = 60309,
            usetime = 8000,
        },
    },
	['dd_bm_taro_cay'] = {
        label = 'Taro Sütlü Çay',
		degrade = 4320,--inedible after 72 hours
        weight = 100,
        stack = true,
        close = true,
        client = {
            status = { thirst = 550000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_sushi_taro_milk_tea_a',
            pos = vec3(0.07, 0.02, -0.02), rot = vec3(-21.0, 0.0, 80.0) },
			bone = 60309,
            usetime = 8000,
        },
    },
	['dd_bm_cilekli_cay'] = {
        label = 'Çilekli Sütlü Çay',
		degrade = 4320,--inedible after 72 hours
        weight = 100,
        stack = true,
        close = true,
        client = {
            status = { thirst = 550000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_sushi_strawberry_milk_tea_a',
            pos = vec3(0.07, 0.02, -0.02), rot = vec3(-21.0, 0.0, 80.0) },
			bone = 60309,
            usetime = 8000,
        },
    },
	['dd_bm_tay_cayi'] = {
        label = 'Tay Sütlü Çay',
		degrade = 4320,--inedible after 72 hours
        weight = 100,
        stack = true,
        close = true,
        client = {
            status = { thirst = 550000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_sushi_thai_milk_tea_a',
            pos = vec3(0.07, 0.02, -0.02), rot = vec3(-21.0, 0.0, 80.0) },
			bone = 60309,
            usetime = 8000,
        },
    },
	['dd_bm_matcha_latte'] = {
        label = 'Matcha Latte',
		degrade = 4320,--inedible after 72 hours
        weight = 100,
        stack = true,
        close = true,
        client = {
            status = { thirst = 500000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_sushi_matcha_milk_tea_a',
            pos = vec3(0.07, 0.02, -0.02), rot = vec3(-21.0, 0.0, 80.0) },
			bone = 60309,
            usetime = 8000,
        },
    },
	['dd_bm_kruvasan'] = {
        label = 'Kruvasan',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_croissant_a',
            pos = vec3(0.03, 0.01, -0.05),
            rot = vec3(54.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bm_jambonlu_sandvic'] = {
        label = 'Jambonlu Sandviç',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 750000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_toast_d',
            pos = vec3(-0.01, 0.01, -0.05),
            rot = vec3(54.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bm_kasarli_tost'] = {
        label = 'Kaşarlı Tost',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_toast_a',
            pos = vec3(0.02, -0.01, -0.04),
            rot = vec3(48.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bm_dolgulu_baget'] = { 
        label = 'Dolgulu Baget',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 650000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_baguette_c',
            pos = vec3(0.09, 0.01, -0.03),
            rot = vec3(40.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bm_yumurtali_tost'] = { 
        label = 'Yumurtalı Tost',
        degrade = 2880,-- 48 stunden
        weight = 200,
        stack = false,
        close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'bzzz@restaurant@eat', clip = 'bzzz_restaurant_eat' },

            prop = { model = 'bzzz_restaurant_food_h',
            bone = 60309,
            pos = vec3(0.08, -0.04, 0.07),
            rot = vec3(-30.0, 10.0, 0.0) },

            propTwo = { model = 'bzzz_restaurant_fork_f',
			bone = 28422,
            pos = vec3(0.07, 0.05, -0.03),
            rot = vec3(-100.0, 24.0, -86.0) },
            usetime = 17500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bm_mantarli_omlet'] = {
        label = 'Mantarlı Omlet',
        degrade = 2880,-- 48 hours
        weight = 200,
        stack = false,
        close = true,
        client = {
            status = { hunger = 600000 },
            anim = { dict = 'bzzz_mushrooms_food', clip = 'bzzz_mushrooms_food' },

            prop = { model = 'bzzz_mushroomsfood_omelette_a',
			bone = 60309,
            pos = vec3(0.08, 0.01, 0.05),
            rot = vec3(-30.0, 0.0, 0.0) },

            propTwo = { model = 'bzzz_mushroomsfood_omelette_b',
			bone = 28422,
            pos = vec3(0.09, 0.04, -0.05),
            rot = vec3(-90.0, 0.0, -30.0) },

            usetime = 17500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bm_pretzel'] = {
        label = 'Pretzel',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_pretzel_a',
            pos = vec3(0.03, -0.05, -0.04),
            rot = vec3(26.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bm_muzlu_kek'] = { 
        label = 'Muzlu Kek Dilimi',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_bananabread_b',
            pos = vec3(0.00, 0.00, 0.00),
            rot = vec3(32.0, -32.0, 50.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bm_kurabiye'] = {
		label = 'Kurabiye',
		weight = 200,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_cookie_a`, pos = vec3(-0.01, -0.01, 0.0), rot = vec3(25.0, 2.0, -8.0) },
			usetime = 4500, 
			notification = 'Afiyet olsun!'
		}
	},
	['dd_bm_uzumlu_rulo'] = {
        label = 'Üzümlü Rulo',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_danish_a',
            pos = vec3(-0.01, -0.02, -0.04),
            rot = vec3(38.0, -8.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bm_biskuvi'] = {
        label = 'Bisküvi',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_biscuit_a',
            pos = vec3(-0.01, -0.01, -0.02),
            rot = vec3(22.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bm_cikolatali_donut'] = {
        label = 'Çikolatalı Donut',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_donut_b',
            pos = vec3(-0.01, -0.02, -0.04),
            rot = vec3(46.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bm_cilekli_donut'] = {
        label = 'Çilekli Donut',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_donut_c',
            pos = vec3(-0.01, -0.02, -0.04),
            rot = vec3(46.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bm_red_velvet'] = {
		label = 'Red Velvet',
		weight = 100,
		client = {
			status = { hunger = 550000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_redvelvet_a`, pos = vec3(0.0, 0.02, -0.02), rot = vec3(16.0, 16.0, -18.0) },
			usetime = 4500, 
			notification = 'Afiyet olsun!'
		}
	},
	['dd_bm_tiramisu'] = {
		label = 'Tiramisu',
		weight = 100,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_tiramisu_a`, pos = vec3(-0.02, 0.0, -0.01), rot = vec3(20.0, -32.0, 82.0) },
			usetime = 4500, 
			notification = 'Afiyet olsun!'
		}
	},
	['dd_bm_muffin'] = {
        label = 'Muffin',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_muffin_a',
            pos = vec3(0.04, -0.01, -0.03),
            rot = vec3(-12.0, -84.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	-- bzzz_food_bundles: Tikibar menüsü (daddy_venue install/menu-plan.md)
	['dd_tk_margarita'] = {
		label = 'Margarita',
		weight = 350,
		client = {
			status = { thirst = 600000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_margarita_a`, pos = vec3(0.04, 0.01, 0.0), rot = vec3(12.0, -8.0, -48.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_cosmopolitan'] = {
		label = 'Cosmopolitan',
		weight = 350,
		client = {
			status = { thirst = 600000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_cosmopolitan_a`, pos = vec3(0.04, 0.01, 0.0), rot = vec3(12.0, -8.0, -48.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_gimlet'] = {
		label = 'Gimlet',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_gimlet_a`, pos = vec3(0.04, 0.01, 0.0), rot = vec3(12.0, -8.0, -48.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_screwdriver'] = {
		label = 'Screwdriver',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_screwdriver_a`, pos = vec3(0.02, 0.02, -0.05), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_whiskey_sour'] = {
		label = 'Whiskey Sour',
		weight = 350,
		client = {
			status = { thirst = 600000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_whiskeysour_a`, pos = vec3(0.03, 0.02, 0.04), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_white_russian'] = {
		label = 'White Russian',
		weight = 350,
		client = {
			status = { thirst = 600000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_whiterussian_a`, pos = vec3(0.03, 0.02, 0.04), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_black_russian'] = {
		label = 'Black Russian',
		weight = 350,
		client = {
			status = { thirst = 600000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_blackrussian_a`, pos = vec3(0.03, 0.02, 0.04), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_bloody_mary'] = {
		label = 'Bloody Mary',
		weight = 350,
		client = {
			status = { thirst = 600000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_bloodymary_a`, pos = vec3(0.02, 0.02, -0.05), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_mai_tai'] = {
		label = 'Mai Tai',
		weight = 350,
		client = {
			status = { thirst = 750000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_maitai_a`, pos = vec3(0.03, 0.02, 0.04), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_hindistan_cevizi'] = {
		label = 'Hindistan Cevizi Kokteyli',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_coconut_a`, pos = vec3(0.07, 0.05, 0.04), rot = vec3(28.0, -50.0, 14.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_shot_b52'] = {
		label = 'B52',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_shot_b52_a`, pos = vec3(0.0, 0.01, 0.07), rot = vec3(12.0, -8.0, 18.0) },
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_shot_blue_kamikaze'] = {
		label = 'Blue Kamikaze',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_shot_bluekamikaze_a`, pos = vec3(0.0, 0.01, 0.07), rot = vec3(12.0, -8.0, 18.0) },
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_shot_kamikaze'] = {
		label = 'Kamikaze',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_shot_kamikaze_a`, pos = vec3(0.0, 0.01, 0.07), rot = vec3(12.0, -8.0, 18.0) },
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_shot_rom'] = {
		label = 'Rom Shot',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_shot_rum_a`, pos = vec3(0.0, 0.01, 0.07), rot = vec3(12.0, -8.0, 18.0) },
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_shot_votka'] = {
		label = 'Votka Shot',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_shot_vodka_a`, pos = vec3(0.0, 0.01, 0.07), rot = vec3(12.0, -8.0, 18.0) },
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_shot_washington'] = {
		label = 'Washington Apple',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_shot_washinapple_a`, pos = vec3(0.0, 0.01, 0.07), rot = vec3(12.0, -8.0, 18.0) },
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_elmali_bira'] = {
		label = 'Elmalı Bira',
		weight = 200,
		stack = true,
        close = true,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_prop_beer_apple`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			bone = 60309,
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_yaban_mersinli_bira'] = {
		label = 'Yaban Mersinli Bira',
		weight = 200,
		stack = true,
        close = true,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_prop_beer_blueberry`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			bone = 60309,
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_buyuk_bira'] = {
		label = 'Büyük Bira',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_beer_b`, pos = vec3(0.02, 0.01, -0.07), rot = vec3(5.0, -4.0, 28.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_ironix'] = {
        label = 'Ironix Enerji',
		degrade = 2880,
        weight = 150,
        stack = false,
        close = true,
        client = {
            status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_englishfood_ironix_a',
            pos = vec3(0.01 ,0.00, 0.07),
            rot = vec3(0.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 5000,
			notification = 'Şerefe!'
        },
    },
	['dd_tk_pop_cola'] = {
		label = 'Büyük Pop-Cola',
		weight = 500,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_prop_popcorn_drink_c`, pos = vec3(0.06, 0.09, 0.03), rot = vec3(43.0, -10.0, -25.0) },
			usetime = 5000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['dd_tk_patlamis_misir'] = {
        label = 'Büyük Patlamış Mısır',
        weight = 200,
        stack = false,
        close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'bzzz_popcorn_animation', clip = 'bzzz_popcorn_animation' },

            prop = { model = 'bzzz_prop_popcorn_box_c',
            bone = 60309,
            pos = vec3(0.13, -0.01, 0.11),
            rot = vec3(-80.0, -14.0, 3.0) },

            propTwo = { model = 'bzzz_prop_popcorn_piece',
            bone = 28422,
            pos = vec3(0.09, 0.06, -0.04),
            rot = vec3(18.0, 45.0, 60.0) },

            usetime = 17500,
	    notification = 'Afiyet olsun!'
        },
    },
	['dd_tk_tavuk_lokma'] = {
        label = 'Çıtır Tavuk Lokma',
        degrade = 2880,
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'bzzz_fastfood_anim2', clip = 'anim2' },

            prop = { model = 'bzzz_prop_fastfood_chicken_f',
            bone = 60309,
            pos = vec3(0.09, 0.02, 0.04),
            rot = vec3(30.0, 35.0, 134.0) },

            propTwo = { model = 'bzzz_prop_fastfood_chicken_c',
            bone = 28422,
            pos = vec3(0.09, 0.05, -0.04),
            rot = vec3(13.0, 37.0, 124.0) },

            usetime = 4000,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_tk_fistik'] = {
		label = 'Fıstık',
		weight = 500,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_new_snacks_peanuts_a`, pos = vec3(0.0, -0.02, -0.01), rot = vec3(0.0, -20.0, 80.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_tk_corndog'] = {
		label = 'Corndog',
		weight = 350,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_skewerpack_corndog_a`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(-10.0, -90.0, 0.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_tk_cips'] = {
		label = 'Cips',
		weight = 350,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'bzzz_eating_chips', clip = 'eat_chip' },
			prop = { model = `bzzz_prop_chips_a_open`, bone = 60309, pos = vec3(0.11, 0.05, 0.04), rot = vec3(97.2, -14.2, 150.6) },
			propTwo = { model = `bzzz_prop_chip_a`, bone = 28422, pos = vec3(0.1, 0.05, -0.04), rot = vec3(-14.0, 70.0, 63.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_tk_pizza_a'] = {
		label = 'Pizza Margherita',
		weight = 350,
		client = {
			status = { hunger = 800000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_foodpack_pizza_margherita002`, bone = 60309, pos = vec3(0.02, -0.03, -0.02), rot = vec3(0.0, 25.0, -70.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_tk_pizza_b'] = {
		label = 'Pizza Hawaii',
		weight = 350,
		client = {
			status = { hunger = 900000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_foodpack_pizza_hawaii002`, bone = 60309, pos = vec3(0.02, -0.03, -0.02), rot = vec3(0.0, 25.0, -70.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_tk_pizza_c'] = {
		label = 'Dört Peynirli Pizza',
		weight = 350,
		client = {
			status = { hunger = 900000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' }, 
			prop = { model = `bzzz_foodpack_pizza_quattro-formaggi002`, bone = 60309, pos = vec3(0.02, -0.03, -0.02), rot = vec3(0.0, 25.0, -70.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_tk_doner_durum'] = {
        label = 'Döner Dürüm',
		weight = 250,
		stack = true,
        close = true,
		client = {
			status = { hunger = 700000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = `bzzz_food_kebab_a`, pos = vec3(0.00, 0.00, 0.00), rot = vec3(138.00, 152.00, 124.00) },
			bone = 60309,
			usetime = 8500,
			notification = 'Afiyet olsun!'
		},
	},
	['dd_tk_pamuk_seker_kirmizi'] = {
		label = 'Kırmızı Pamuk Şeker',
		weight = 500,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_candy_cotton_red`, pos = vec3(-0.02, 0.01, -0.01), rot = vec3(0.0, -90.0, 0.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_tk_pamuk_seker_sari'] = {
		label = 'Sarı Pamuk Şeker',
		weight = 500,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_candy_cotton_yellow`, pos = vec3(-0.02, 0.01, -0.01), rot = vec3(0.0, -90.0, 0.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_tk_buzlu_lolipop'] = {
		label = 'Meyveli Buzlu Lolipop',
		weight = 350,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_popsicle_barfs_b`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_tk_deniz_yildizi'] = {
		label = 'Çikolatalı Deniz Yıldızı',
		weight = 350,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_popsicle_starfish_b`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_tk_fistikli_dondurma'] = { -- brain cold go brrrrr
        label = 'Antep Fıstıklı Dondurma',
		degrade = 1440,-- 24 stunden
        weight = 250,
        stack = true,
        close = true,
        client = {
            status = { hunger = 600000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
            prop = { model = 'bzzz_icecream_pistachio',
            bone = 18905,
            pos = vec3(0.10, 0.03, 0.03),
            rot = vec3(105.0, 70.0, -203.0) },
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	-- bzzz_food_bundles: Noir Bar menüsü (daddy_venue install/menu-plan.md)
	['dd_nb_manhattan'] = {
		label = 'Manhattan',
		weight = 350,
		client = {
			status = { thirst = 800000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_manhattan_a`, pos = vec3(0.04, 0.01, 0.0), rot = vec3(12.0, -8.0, -48.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_nb_old_fashioned'] = {
		label = 'Old Fashioned',
		weight = 350,
		client = {
			status = { thirst = 750000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_oldfashioned_a`, pos = vec3(0.03, 0.02, 0.04), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_nb_negroni'] = {
		label = 'Negroni',
		weight = 350,
		client = {
			status = { thirst = 700000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_negroni_a`, pos = vec3(0.03, 0.02, 0.04), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_nb_martini'] = {
		label = 'Martini',
		weight = 350,
		client = {
			status = { thirst = 700000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_martini_a`, pos = vec3(0.04, 0.01, 0.0), rot = vec3(12.0, -8.0, -48.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_nb_espresso_martini'] = {
		label = 'Espresso Martini',
		weight = 350,
		client = {
			status = { thirst = 800000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_martini_a`, pos = vec3(0.04, 0.01, 0.0), rot = vec3(12.0, -8.0, -48.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_nb_whiskey_sour'] = {
		label = 'Whiskey Sour',
		weight = 350,
		client = {
			status = { thirst = 650000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_whiskeysour_a`, pos = vec3(0.03, 0.02, 0.04), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_nb_black_russian'] = {
		label = 'Black Russian',
		weight = 350,
		client = {
			status = { thirst = 650000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_blackrussian_a`, pos = vec3(0.03, 0.02, 0.04), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_nb_white_russian'] = {
		label = 'White Russian',
		weight = 350,
		client = {
			status = { thirst = 700000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_whiterussian_a`, pos = vec3(0.03, 0.02, 0.04), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_nb_cosmopolitan'] = {
		label = 'Cosmopolitan',
		weight = 350,
		client = {
			status = { thirst = 650000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_cosmopolitan_a`, pos = vec3(0.04, 0.01, 0.0), rot = vec3(12.0, -8.0, -48.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_nb_gimlet'] = {
		label = 'Gimlet',
		weight = 350,
		client = {
			status = { thirst = 600000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_gimlet_a`, pos = vec3(0.04, 0.01, 0.0), rot = vec3(12.0, -8.0, -48.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_nb_cin_tonik'] = {
		label = 'Cin Tonik',
		weight = 350,
		client = {
			status = { thirst = 600000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_gintonic_a`, pos = vec3(0.02, 0.02, -0.05), rot = vec3(5.0, -1.0, -27.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_nb_moscow_mule'] = {
		label = 'Moscow Mule',
		weight = 350,
		client = {
			status = { thirst = 600000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_moscowmule_a`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(12.0, -8.0, 18.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_nb_shot_b52'] = {
		label = 'B52',
		weight = 350,
		client = {
			status = { thirst = 550000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_shot_b52_a`, pos = vec3(0.0, 0.01, 0.07), rot = vec3(12.0, -8.0, 18.0) },
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['dd_nb_shot_kamikaze'] = {
		label = 'Kamikaze',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_shot_kamikaze_a`, pos = vec3(0.0, 0.01, 0.07), rot = vec3(12.0, -8.0, 18.0) },
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['dd_nb_shot_bourbon'] = {
		label = 'Bourbon Shot',
		weight = 350,
		client = {
			status = { thirst = 550000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_shot_rum_a`, pos = vec3(0.0, 0.01, 0.07), rot = vec3(12.0, -8.0, 18.0) },
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['dd_nb_bardak_bira'] = {
		label = 'Bardak Bira',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_beer_d`, pos = vec3(0.04, 0.02, -0.02), rot = vec3(5.0, -4.0, 28.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_nb_bitter_bira'] = {
        label = 'Bitter Bira',
		degrade = 2880,
        weight = 300,
        stack = false,
        close = true,
        client = {
            status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_englishfood_beer_a',
            pos = vec3(0.02, 0.02, -0.07),
            rot = vec3(5.0, -4.0, 28.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Şerefe!'
        },
    },
	['dd_nb_tomahawk'] = {
		label = 'Tomahawk Biftek',
		weight = 250,
		client = {
			status = { hunger = 1000000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_food_grill_steak_grill_b`, pos = vec3(0.03, -0.03, -0.02), rot = vec3(18.0, -35.0, 64.0) },
			usetime = 5000, 
			notification = 'Afiyet olsun!'
		}
	},
	['dd_nb_ossobuco'] = {
		label = 'Ossobuco',
		weight = 500,
		client = {
			status = { hunger = 1000000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_food_grill_steak_grill_d`, pos = vec3(0.03, -0.04, -0.02), rot = vec3(30.0, 0.0, -8.0) },
			usetime = 5000, 
			notification = 'Afiyet olsun!'
		}
	},
	['dd_nb_istakoz'] = { 
        label = 'Istakoz',
        degrade = 2880,-- 48 stunden
        weight = 200,
        stack = false,
        close = true,
        client = {
            status = { hunger = 1000000 },
            anim = { dict = 'bzzz@restaurant@eat', clip = 'bzzz_restaurant_eat' },

            prop = { model = 'bzzz_restaurant_food_g',
            bone = 60309,
            pos = vec3(0.08, -0.04, 0.07),
            rot = vec3(-30.0, 10.0, 0.0) },

            propTwo = { model = 'bzzz_restaurant_fork_d',
			bone = 28422,
            pos = vec3(0.07, 0.05, -0.03),
            rot = vec3(-100.0, 24.0, -86.0) },
            usetime = 17500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_nb_istakoz_kuyrugu'] = {
        label = 'Istakoz Kuyruğu',
        degrade = 2880,-- inedible after 48 hours
        weight = 200, -- edit the value as you need 
        stack = false,
        close = true,
        client = {
            status = { hunger = 1000000 }, -- edit the value as you need
            anim = { dict = 'bzzz_sushi_eat', clip = 'bzzz_sushi_eat' },

            prop = { model = 'bzzz_sushi_lobstertail_b',
            bone = 60309,
            pos = vec3(0.17, 0.0, 0.03),
            rot = vec3(-30.0, 15.0, 35.0) },

            propTwo = { model = 'bzzz_sushi_moulesmarinieres_b',
			bone = 28422,
            pos = vec3(0.08, 0.05, -0.03),
            rot = vec3(-90.0, -27.0, -27.0) },

            usetime = 5000, -- edit the value as you need
			notification = 'Afiyet olsun!'
        },
    },
	['dd_nb_izgara_ahtapot'] = {
        label = 'Izgara Ahtapot',
        degrade = 2880,-- inedible after 48 hours
        weight = 200, -- edit the value as you need 
        stack = false,
        close = true,
        client = {
            status = { hunger = 950000 }, -- edit the value as you need
            anim = { dict = 'bzzz_sushi_eat', clip = 'bzzz_sushi_eat' },

            prop = { model = 'bzzz_sushi_grilledoctopus_b',
            bone = 60309,
            pos = vec3(0.17, 0.0, 0.03),
            rot = vec3(-30.0, 15.0, 35.0) },

            propTwo = { model = 'bzzz_sushi_grilledoctopus_a',
			bone = 28422,
            pos = vec3(0.08, 0.05, -0.03),
            rot = vec3(-90.0, -27.0, -27.0) },

            usetime = 5000, -- edit the value as you need
			notification = 'Afiyet olsun!'
        },
    },
	['dd_nb_sarapli_midye'] = {
        label = 'Beyaz Şaraplı Midye',
        degrade = 2880,-- inedible after 48 hours
        weight = 200, -- edit the value as you need 
        stack = false,
        close = true,
        client = {
            status = { hunger = 900000 }, -- edit the value as you need
            anim = { dict = 'bzzz_sushi_eat', clip = 'bzzz_sushi_eat' },

            prop = { model = 'bzzz_sushi_moulesmarinieres_a',
            bone = 60309,
            pos = vec3(0.07, 0.01, 0.04),
            rot = vec3(-30.0, 0.0, 0.0) },

            propTwo = { model = 'bzzz_sushi_moulesmarinieres_b',
			bone = 28422,
            pos = vec3(0.08, 0.05, -0.03),
            rot = vec3(-90.0, -27.0, -27.0) },

            usetime = 5000, -- edit the value as you need
			notification = 'Afiyet olsun!'
        },
    },
	['dd_nb_mantarli_risotto'] = {
        label = 'Mantarlı Risotto',
        degrade = 2880,-- 48 hours
        weight = 200,
        stack = false,
        close = true,
        client = {
            status = { hunger = 800000 },
            anim = { dict = 'bzzz_mushrooms_food', clip = 'bzzz_mushrooms_food' },

			prop = { model = 'bzzz_mushroomsfood_risotto_a',
            bone = 60309,
            pos = vec3(0.07, 0.03, 0.07),
            rot = vec3(-30.0, 0.0, 0.0) },
			
			propTwo = { model = 'bzzz_mushroomsfood_risotto_b',
			bone = 28422,
            pos = vec3(0.09, 0.03, -0.06),
            rot = vec3(-110.0, 150.0, -30.0) },

            usetime = 10500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_nb_biftek_patates'] = { 
        label = 'Biftek ve Patates',
        degrade = 2880,-- 48 stunden
        weight = 200,
        stack = false,
        close = true,
        client = {
            status = { hunger = 900000 },
            anim = { dict = 'bzzz@restaurant@eat', clip = 'bzzz_restaurant_eat' },

            prop = { model = 'bzzz_restaurant_food_e',
            bone = 60309,
            pos = vec3(0.08, -0.04, 0.07),
            rot = vec3(-30.0, 10.0, 0.0) },

            propTwo = { model = 'bzzz_restaurant_fork_e',
			bone = 28422,
            pos = vec3(0.07, 0.05, -0.03),
            rot = vec3(-100.0, 24.0, -86.0) },
            usetime = 17500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_nb_izgara_camembert'] = {
		label = 'Izgara Camembert',
		weight = 300,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_food_grill_camembert_grill_a`, pos = vec3(-0.01, 0.0, 0.0), rot = vec3(-20.0, -16.0, -83.0) },
			usetime = 5000, 
			notification = 'Afiyet olsun!'
		}
	},
	['dd_nb_hellim_izgara'] = {
		label = 'Hellim Izgara',
		weight = 300,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_food_grill_halloumi_grill_a`, pos = vec3(-0.03, 0.0, 0.0), rot = vec3(22.0, -25.0, 85.0) },
			usetime = 5000, 
			notification = 'Afiyet olsun!'
		}
	},
	['dd_nb_mantar_sis'] = {
	label = 'Mantar Şiş',
	degrade = 2880,-- 48 hours
    stack = false,
    close = true,
	weight = 350,
	client = {
		status = { hunger = 550000 },
		anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
		prop = { model = `bzzz_mushroomsfood_skewer_a`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(-90.0, -90.0, 0.0) },
		usetime = 5500,
		notification = 'Afiyet olsun!'
	}
},
	['dd_nb_pretzel'] = {
		label = 'Pretzel',
		weight = 500,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_new_snacks_pretzels_a`, pos = vec3(0.03, -0.04, -0.01), rot = vec3(-80.0, 0.0, 70.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_nb_fistik'] = {
		label = 'Fıstık',
		weight = 500,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_new_snacks_peanuts_a`, pos = vec3(0.0, -0.02, -0.01), rot = vec3(0.0, -20.0, 80.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_nb_cikolata_truf'] = {
		label = 'Çikolata Trüf',
		weight = 20,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_truffles_a`, pos = vec3(-0.02, 0.0, -0.01), rot = vec3(70.0, -64.0, 52.0) },
			usetime = 4500, 
			notification = 'Afiyet olsun!'
		}
	},
	['dd_nb_elmali_turta'] = {
		label = 'Elmalı Turta',
		weight = 50,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_applepie_b`, pos = vec3(-0.03, 0.01, 0.0), rot = vec3(-30.0, 0.0, 160.0) },
			usetime = 5000, 
			notification = 'Afiyet olsun!'
		}
	},
	['dd_nb_tres_leches'] = {
		label = 'Tres Leches',
		weight = 100,
		client = {
			status = { hunger = 650000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_treslechescake_a`, pos = vec3(-0.02, 0.0, -0.01), rot = vec3(20.0, -32.0, 82.0) },
			usetime = 4500, 
			notification = 'Afiyet olsun!'
		}
	},
	['dd_nb_cilekli_pasta'] = {
		label = 'Çilekli Pasta',
		weight = 200,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_cake_b`, pos = vec3(-0.02, 0.0, -0.02), rot = vec3(10.0, 7.0, -42.0) },
			usetime = 4000, 
			notification = 'Afiyet olsun!'
		}
	},
	['dd_nb_cikolata_kulesi'] = {
		label = 'Çikolata Kulesi',
		weight = 200,
		client = {
			status = { hunger = 700000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_chocothrone_a`, pos = vec3(0.05, -0.01, 0.0), rot = vec3(1.0, -4.0, -8.0) },
			usetime = 4500, 
			notification = 'Afiyet olsun!'
		}
	},
	-- bzzz_food_bundles: Kolej kantini (ox_inventory market: kantin)
	['kantin_tost'] = {
        label = 'Kaşarlı Tost',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 600000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_toast_a',
            pos = vec3(0.02, -0.01, -0.04),
            rot = vec3(48.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['kantin_sandvic'] = {
        label = 'Karışık Sandviç',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 650000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_toast_d',
            pos = vec3(-0.01, 0.01, -0.05),
            rot = vec3(54.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['kantin_sosisli'] = {
        label = 'Sosisli',
		weight = 250,
		stack = true,
        close = true,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = `bzzz_food_hotdog_b`, pos = vec3(0.02, 0.00, -0.01), rot = vec3(362.00, -8.00, 432.00) },
			bone = 60309,
			usetime = 5500,
			notification = 'Afiyet olsun!'
		},
	},
	['kantin_pizza_dilimi'] = {
		label = 'Pizza Dilimi',
		weight = 350,
		client = {
			status = { hunger = 650000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_foodpack_pizza_cheezy002`, bone = 60309, pos = vec3(0.02, -0.03, -0.02), rot = vec3(0.0, 25.0, -70.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['kantin_hamburger'] = {
		label = 'Kantin Burgeri',
		weight = 500,
		client = {
			status = { hunger = 700000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_prop_fastfood_cheeseburger_a`, pos = vec3(-0.01, 0.0, -0.02), rot = vec3(31.0, 15.0, 0.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Afiyet olsun!'
		}
	},
	['kantin_patates'] = {
        label = 'Patates Kızartması',
        degrade = 2880,
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 550000 },
            anim = { dict = 'bzzz_fastfood_anim1', clip = 'anim1' },

            prop = { model = 'bzzz_prop_fastfood_fries_a',
            bone = 60309,
            pos = vec3(0.09, 0.04, 0.05),
            rot = vec3(-80.0, 50.0, 0.0) },

            propTwo = { model = 'bzzz_prop_fastfood_fries_c',
            bone = 28422,
            pos = vec3(0.07, 0.04, -0.03),
            rot = vec3(-100.0, -40.0, -30.0) },

            usetime = 4000,
			notification = 'Afiyet olsun!'
        },
    },
	['kantin_nugget'] = { 
        label = 'Tavuk Nugget',
        degrade = 2880,-- 48 stunden
        weight = 200,
        stack = false,
        close = true,
        client = {
            status = { hunger = 650000 },
            anim = { dict = 'bzzz_food_dino_anim', clip = 'bzzz_food_dino_anim' },

            prop = { model = 'bzzz_food_dino_nuggets_a',
            bone = 60309,
            pos = vec3(0.12, 0.0, 0.06),
            rot = vec3(-99.0, -34.0, 0.0) },

            propTwo = { model = 'bzzz_food_dino_nuggets_b',
			bone = 28422,
            pos = vec3(0.09, 0.05, -0.03),
            rot = vec3(-50.0, 15.0, -28.0) },
            usetime = 8000,
		    notification = 'Afiyet olsun!'
        },
    },
	['kantin_kruvasan'] = {
		label = 'Kruvasan',
		weight = 500,
		client = {
			status = { hunger = 550000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_new_snacks_croissant_a`, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, -50.0, 80.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Afiyet olsun!'
		}
	},
	['kantin_pretzel'] = {
        label = 'Pretzel',
		degrade = 2880,-- 48 stunden
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 550000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_food_bakery_pretzel_a',
            pos = vec3(0.03, -0.05, -0.04),
            rot = vec3(26.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Afiyet olsun!'
        },
    },
	['kantin_cikolata'] = {
		label = 'Sütlü Çikolata',
		weight = 200,
		client = {
			status = { hunger = 550000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_chocolate_a`, pos = vec3(0.04, -0.02, -0.01), rot = vec3(0.0, -24.0, 72.0) },
			usetime = 4500, 
			notification = 'Afiyet olsun!'
		}
	},
	['kantin_donut'] = {
		label = 'Pembe Donut',
		weight = 500,
		client = {
			status = { hunger = 550000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_new_snacks_donut_a`, pos = vec3(0.0, 0.0, -0.02), rot = vec3(0.0, -20.0, 80.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Afiyet olsun!'
		}
	},
	['kantin_portakal_suyu'] = {
        label = 'Kutu Portakal Suyu',
		degrade = 4320,-- 72 stunden
        weight = 100,
        stack = true,
        close = true,
        client = {
            status = { thirst = 550000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_drink_juice_box_orange',
            pos = vec3(0.01, 0.06, -0.18), rot = vec3(2.0, -4.0, 122.0) },
			bone = 60309,
            usetime = 8000,
        },
    },
	['kantin_seftali_suyu'] = {
        label = 'Kutu Şeftali Suyu',
		degrade = 4320,-- 72 stunden
        weight = 100,
        stack = true,
        close = true,
        client = {
            status = { thirst = 550000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_drink_juice_box_peach',
           pos = vec3(0.01, 0.06, -0.18), rot = vec3(2.0, -4.0, 122.0) },
			bone = 60309,
            usetime = 8000,
        },
    },
	['kantin_kola'] = {
		label = 'Kola',
		weight = 500,
		client = {
			status = { thirst = 550000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_prop_fastfood_drink_b`, pos = vec3(0.02, 0.00, 0.01), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['kantin_cay'] = {
        label = 'Kantin Çayı',
        weight = 250,
		stack = true,
        close = true,
		--description = "something sweet",
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = 'bzzz_food_xmas_mug_b',
			pos = vec3(0.00, 0.01, 0.00), rot = vec3(0.0, 0.0, 0.0) },
			bone = 60309,
			usetime = 8000,
			notification = 'Şerefe!'
		},
	},
	-- bzzz_food_bundles: Bowling Cafe menüsü (daddy_venue install/menu-plan.md)
	['dd_bw_menu_burger'] = {
        label = 'Burger ve Patates Menüsü',
        degrade = 2880,
        weight = 600,
        stack = true,
        close = true,
        client = {
            status = { hunger = 950000 },
            anim = { dict = 'bzzz_fastfood_anim2', clip = 'anim2' },

            prop = { model = 'bzzz_prop_fastfood_menu_a',
            bone = 60309,
            pos = vec3(0.09, 0.02, 0.05),
            rot = vec3(-10.0, -40.0, -90.0) },

            propTwo = { model = 'bzzz_prop_fastfood_fries_c',
            bone = 28422,
            pos = vec3(0.09, 0.04, -0.03),
            rot = vec3(-100.0, -40.0, -30.0) },

            usetime = 5500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bw_menu_nugget'] = {
        label = 'Nugget ve Patates Menüsü',
        degrade = 2880,
        weight = 600,
        stack = true,
        close = true,
        client = {
            status = { hunger = 900000 },
            anim = { dict = 'bzzz_fastfood_anim2', clip = 'anim2' },

            prop = { model = 'bzzz_prop_fastfood_menu_b',
            bone = 60309,
            pos = vec3(0.09, 0.02, 0.05),
            rot = vec3(-10.0, -40.0, -90.0) },

            propTwo = { model = 'bzzz_prop_fastfood_fries_c',
            bone = 28422,
            pos = vec3(0.09, 0.04, -0.03),
            rot = vec3(-100.0, -40.0, -30.0) },

            usetime = 5500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bw_menu_but'] = {
        label = 'Çıtır But ve Patates Menüsü',
        degrade = 2880,
        weight = 600,
        stack = true,
        close = true,
        client = {
            status = { hunger = 900000 },
            anim = { dict = 'bzzz_fastfood_anim2', clip = 'anim2' },

            prop = { model = 'bzzz_prop_fastfood_menu_c',
            bone = 60309,
            pos = vec3(0.09, 0.02, 0.05),
            rot = vec3(-10.0, -40.0, -90.0) },

            propTwo = { model = 'bzzz_prop_fastfood_fries_c',
            bone = 28422,
            pos = vec3(0.09, 0.04, -0.03),
            rot = vec3(-100.0, -40.0, -30.0) },

            usetime = 5500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bw_menu_serit'] = {
        label = 'Çıtır Şerit ve Patates Menüsü',
        degrade = 2880,
        weight = 600,
        stack = true,
        close = true,
        client = {
            status = { hunger = 900000 },
            anim = { dict = 'bzzz_fastfood_anim2', clip = 'anim2' },

            prop = { model = 'bzzz_prop_fastfood_menu_d',
            bone = 60309,
            pos = vec3(0.09, 0.02, 0.05),
            rot = vec3(-10.0, -40.0, -90.0) },

            propTwo = { model = 'bzzz_prop_fastfood_fries_c',
            bone = 28422,
            pos = vec3(0.09, 0.04, -0.03),
            rot = vec3(-100.0, -40.0, -30.0) },

            usetime = 5500,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bw_sosisli'] = {
        label = 'Hardallı Sosisli',
		weight = 250,
		stack = true,
        close = true,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = `bzzz_food_hotdog_a`, pos = vec3(0.02, 0.00, -0.01), rot = vec3(362.00, -8.00, 432.00) },
			bone = 60309,
			usetime = 5500,
			notification = 'Afiyet olsun!'
		},
	},
	['dd_bw_pizza_a'] = {
		label = 'Jambonlu Pizza',
		weight = 350,
		client = {
			status = { hunger = 850000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' }, 
			prop = { model = `bzzz_foodpack_pizza_prosciutto002`, bone = 60309, pos = vec3(0.02, -0.03, -0.02), rot = vec3(0.0, 25.0, -70.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_bw_pizza_b'] = {
		label = 'Sebzeli Pizza',
		weight = 350,
		client = {
			status = { hunger = 800000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_foodpack_pizza_vegetariana002`, bone = 60309, pos = vec3(0.02, -0.03, -0.02), rot = vec3(0.0, 25.0, -70.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_bw_pizza_c'] = {
		label = 'Karışık Pizza',
		weight = 350,
		client = {
			status = { hunger = 900000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_foodpack_pizza_capricciosa002`, bone = 60309, pos = vec3(0.02, -0.03, -0.02), rot = vec3(0.0, 25.0, -70.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_bw_quesadilla'] = {
        label = 'Quesadilla',
		degrade = 2880,-- 48 hours
        weight = 300,
        stack = false,
        close = true,
        client = {
            status = { hunger = 650000 },
            anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = 'bzzz_mexicanfood_quesadilla_a',
            pos = vec3(-0.01, -0.03, -0.05),
            rot = vec3(-50.0, -150.0, 0.0) },
			bone = 60309,
            usetime = 5000,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bw_burrito'] = {
        label = 'Burrito',
		weight = 250,
		stack = true,
        close = true,
		client = {
			status = { hunger = 700000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
            prop = { model = `bzzz_food_burrito_a`, pos = vec3(0.03, 0.01, -0.03), rot = vec3(8.00, 96.00, 0.00) },
			bone = 60309,
			usetime = 5500,
			notification = 'Afiyet olsun!'
		},
	},
	['dd_bw_misir_kucuk'] = {
        label = 'Küçük Patlamış Mısır',
        weight = 200,
        stack = false,
        close = true,
        client = {
            status = { hunger = 500000 },
            anim = { dict = 'bzzz_popcorn_animation', clip = 'bzzz_popcorn_animation' },

            prop = { model = 'bzzz_prop_popcorn_box_a',
            bone = 60309,
            pos = vec3(0.1, 0.03, 0.09),
            rot = vec3(-80.0, -14.0, 3.0) },

            propTwo = { model = 'bzzz_prop_popcorn_piece',
            bone = 28422,
            pos = vec3(0.09, 0.06, -0.04),
            rot = vec3(18.0, 45.0, 60.0) },

            usetime = 17500,
      	    notification = 'Afiyet olsun!'
        },
    },
	['dd_bw_misir_orta'] = {
        label = 'Orta Patlamış Mısır',
        weight = 200,
        stack = false,
        close = true,
        client = {
            status = { hunger = 600000 },
            anim = { dict = 'bzzz_popcorn_animation', clip = 'bzzz_popcorn_animation' },

            prop = { model = 'bzzz_prop_popcorn_box_b',
            bone = 60309,
            pos = vec3(0.1, 0.03, 0.09),
            rot = vec3(-80.0, -14.0, 3.0) },

            propTwo = { model = 'bzzz_prop_popcorn_piece',
            bone = 28422,
            pos = vec3(0.09, 0.06, -0.04),
            rot = vec3(18.0, 45.0, 60.0) },

            usetime = 17500,
      	    notification = 'Afiyet olsun!'
        },
    },
	['dd_bw_patates'] = {
        label = 'Patates Kızartması',
        degrade = 2880,
        weight = 200,
        stack = true,
        close = true,
        client = {
            status = { hunger = 550000 },
            anim = { dict = 'bzzz_fastfood_anim1', clip = 'anim1' },

            prop = { model = 'bzzz_prop_fastfood_fries_b',
            bone = 60309,
            pos = vec3(0.09, 0.04, 0.05),
            rot = vec3(-80.0, 50.0, 0.0) },

            propTwo = { model = 'bzzz_prop_fastfood_fries_c',
            bone = 28422,
            pos = vec3(0.07, 0.04, -0.03),
            rot = vec3(-100.0, -40.0, -30.0) },

            usetime = 4000,
			notification = 'Afiyet olsun!'
        },
    },
	['dd_bw_sogan_halkasi'] = {
		label = 'Soğan Halkası',
		weight = 500,
		client = {
			status = { hunger = 550000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_prop_fastfood_onion_a`, pos = vec3(-0.04, 0.01, -0.01), rot = vec3(01.0, 45.0, -85.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_bw_cips'] = {
		label = 'Cips',
		weight = 350,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'bzzz_eating_chips', clip = 'eat_chip' },
			prop = { model = `bzzz_prop_chips_b_open`, bone = 60309, pos = vec3(0.11, 0.05, 0.04), rot = vec3(97.2, -14.2, 150.6) },
			propTwo = { model = `bzzz_prop_chip_b`, bone = 28422, pos = vec3(0.1, 0.05, -0.04), rot = vec3(-14.0, 70.0, 63.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_bw_peynir_sis'] = {
		label = 'Peynir Şiş',
		weight = 350,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_skewerpack_cheese_a`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(-10.0, -90.0, 0.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_bw_misir_sis'] = {
		label = 'Mısır Şiş',
		weight = 350,
		client = {
			status = { hunger = 550000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_skewerpack_corn_a`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(-10.0, -90.0, 0.0) },
			usetime = 4000,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_bw_buyuk_bira'] = {
		label = 'Büyük Bira',
		weight = 350,
		client = {
			status = { thirst = 600000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_beer_a`, pos = vec3(0.03, 0.02, -0.01), rot = vec3(5.0, -4.0, 28.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_bw_bardak_bira'] = {
		label = 'Bardak Bira',
		weight = 350,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_drink_beer_d`, pos = vec3(0.04, 0.02, -0.02), rot = vec3(5.0, -4.0, 28.0) },
			usetime = 5000,
			notification = 'Şerefe!'
		}
	},
	['dd_bw_elmali_bira'] = {
		label = 'Elmalı Bira',
		weight = 200,
		stack = true,
        close = true,
		client = {
			status = { thirst = 550000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_prop_beer_apple`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			bone = 60309,
			usetime = 4000,
			notification = 'Şerefe!'
		}
	},
	['dd_bw_bitter_bira'] = {
        label = 'Bitter Bira',
		degrade = 2880,
        weight = 300,
        stack = false,
        close = true,
        client = {
            status = { thirst = 550000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_englishfood_beer_a',
            pos = vec3(0.02, 0.02, -0.07),
            rot = vec3(5.0, -4.0, 28.0) },
			bone = 60309,
            usetime = 7500,
			notification = 'Şerefe!'
        },
    },
	['dd_bw_popcola_kucuk'] = {
		label = 'Küçük Pop-Cola',
		weight = 500,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_prop_popcorn_drink_a`, pos = vec3(0.04, 0.02, 0.01), rot = vec3(13.0, -10.0, -10.0) },
			usetime = 5000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['dd_bw_popcola_orta'] = {
		label = 'Orta Pop-Cola',
		weight = 500,
		client = {
			status = { thirst = 550000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_prop_popcorn_drink_b`, pos = vec3(0.06, 0.06, 0.03), rot = vec3(31.0, -16.0, -16.0) },
			usetime = 5000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['dd_bw_popcola_buyuk'] = {
		label = 'Büyük Pop-Cola',
		weight = 500,
		client = {
			status = { thirst = 600000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_prop_popcorn_drink_c`, pos = vec3(0.06, 0.09, 0.03), rot = vec3(43.0, -10.0, -25.0) },
			usetime = 5000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['dd_bw_sprunk'] = {
		label = 'Büyük Sprunk',
		weight = 500,
		client = {
			status = { thirst = 550000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `bzzz_prop_fastfood_drink_a`, pos = vec3(0.02, 0.00, -0.01), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Şerefe!'
		}
	},
	['dd_bw_ironix_zero'] = {
        label = 'Ironix Zero',
		degrade = 2880,
        weight = 150,
        stack = false,
        close = true,
        client = {
            status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_englishfood_ironix_b',
            pos = vec3(0.01 ,0.00, 0.07),
            rot = vec3(0.0, 0.0, 0.0) },
			bone = 60309,
            usetime = 5000,
			notification = 'Şerefe!'
        },
    },
	['dd_bw_visne_suyu'] = {
        label = 'Kutu Vişne Suyu',
		degrade = 4320,-- 72 stunden
        weight = 100,
        stack = true,
        close = true,
        client = {
            status = { thirst = 500000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_drink_juice_box_cherry',
            pos = vec3(0.01, 0.06, -0.18), rot = vec3(2.0, -4.0, 122.0) },
			bone = 60309,
            usetime = 16000,
        },
    },
	['dd_bw_muz_suyu'] = {
        label = 'Kutu Muz Suyu',
		degrade = 4320,-- 72 stunden
        weight = 100,
        stack = true,
        close = true,
        client = {
            status = { thirst = 500000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = 'bzzz_drink_juice_box_banana',
           pos = vec3(0.01, 0.06, -0.18), rot = vec3(2.0, -4.0, 122.0) },
			bone = 60309,
            usetime = 16000,
        },
    },
	['dd_bw_meyve_posu'] = {
        label = 'Meyve Suyu Poşeti',
        weight = 250,
		stack = true,
        close = true,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = 'bzzz_food_capisun_a',
			pos = vec3(-0.03, 0.01, -0.08), rot = vec3(4.00, 4.0, 120.0) },
			bone = 60309,
			usetime = 23500,
			notification = 'Şerefe!'
		},
	},
	['dd_bw_portakal_gazoz'] = {
	label = 'Portakallı Gazoz',
	weight = 200,
	client = {
		status = { thirst = 500000 },
		anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
		prop = { model = `bzzz_food_dino_drink_d`, pos = vec3(0.03, 0.02, 0.07), rot = vec3(32.0, 6.0, -64.0) },
		usetime = 5000, 
		notification = 'Şerefe!'
	}
},
	['dd_bw_dondurma_cikolata'] = {
		label = 'Çikolata-Vanilya Dondurma',
		weight = 500,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_prop_fastfood_icecream_a`, pos = vec3(-0.02, 0.0, -0.01), rot = vec3(1.0, -85.0, 10.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_bw_dondurma_ahududu'] = {
		label = 'Ahududu Dondurma',
		weight = 500,
		client = {
			status = { hunger = 600000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_prop_fastfood_icecream_b`, pos = vec3(-0.02, 0.0, -0.01), rot = vec3(1.0, -85.0, 10.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_bw_donut'] = {
		label = 'Çikolatalı Donut',
		weight = 500,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_new_snacks_donut_b`, pos = vec3(0.0, 0.0, -0.02), rot = vec3(0.0, -20.0, 80.0) },
			usetime = 4000,
			cancel = true,
			notification = 'Afiyet olsun!'
		}
	},
	['dd_bw_cupcake'] = {
	label = 'Cupcake',
	weight = 200,
	client = {
		status = { hunger = 550000 },
		anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
		prop = { model = `bzzz_food_dino_cupcake_a`, pos = vec3(-0.01, 0.02, -0.03), rot = vec3(33.0, -10.0, -8.0) },
		usetime = 5000, 
		notification = 'Afiyet olsun!'
	}
},
	['dd_bw_kurabiye'] = {
		label = 'Kurabiye',
		weight = 200,
		client = {
			status = { hunger = 500000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_sugary_cookie_b`, pos = vec3(-0.01, -0.01, 0.0), rot = vec3(25.0, 2.0, -8.0) },
			usetime = 4500, 
			notification = 'Afiyet olsun!'
		}
	},
}
