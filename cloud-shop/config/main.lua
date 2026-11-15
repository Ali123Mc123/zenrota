--? For support, join our Discord server: https://discord.gg/jAnEnyGBef

return {
	Framework = "qbox",                        -- Options: "esx", "qbox", "qbcore", "custom", or "auto" (auto-detects avaible options)
	Locale = "tr",                             -- Options: "en", "de", "tr"
	DebugMode = "prod",                        -- Options: "prod" (minimal logs), "dev" (detailed logs), false (disable logs)

	EnableSounds = true,                       -- Plays sounds when interacting with the shop interface
	ImagePath = "nui://ox_inventory/web/images/", -- Path to the item images --? Local folder: "item_images/"
	WeaponAsItem = true,                       -- Treat weapons as items
	UnownedStorePriceMultiplier = 1.0,         -- Multiplier applied to prices when a store has no owner (set 1.0 to disable)

	Shops = {
		["shop"] = {
			PointRadius = 25.0, -- The radius within which markers, peds, and other game elements related to the shop are displayed

			Locations = {
				vector4(372.8008, 328.1116, 103.5665, 262.1354), -- Clinton Ave
				vector4(2555.5110, 380.7313, 108.6229, 0.9597), -- Palomino Ave
				vector4(-3040.5376, 583.9359, 7.9089, 17.7445), -- Inseno Road
				vector4(-3243.9229, 1000.0519, 12.8307, 0.7583), -- Barbareno Rd
				vector4(-2193.4412, 4290.1064, 49.1743, 63.6331), -- Great Ocean Hwy
				vector4(1959.1536, 3741.4165, 32.3437, 298.7749), -- Niland Ave
				vector4(2676.5083, 3280.1863, 55.2411, 335.5104), -- Senora Fwy
				vector4(1728.5699, 6416.7671, 35.0372, 243.3380), -- Senora Fwy 2
				vector4(1134.2589, -983.0569, 46.4158, 278.9547), -- El Rancho Blvd
				vector4(-1221.4543, -908.0496, 12.3263, 36.5340), -- San Andreas Ave
				vector4(-1486.7350, -377.5593, 40.1634, 132.9464), -- Prosperity St
				-- vector4(-2966.3162, 391.5883, 15.0433, 86.4455), -- Great Ocean Hwy
				vector4(24.5062, -1345.5989, 29.4970, 263.3659), -- Inoccence Blvd
				-- vector4(-561.7218, 286.8480, 82.1765, 266.4413), -- Milton Rd
				vector4(-47.2886, -1758.5280, 29.4210, 45.3676), -- Davis Ave
				-- vector4(1165.0068, -323.6485, 69.2051, 101.2836), -- West Mirrow Drive
				vector4(-706.0665, -914.6005, 19.2156, 82.3892), -- Palomino Ave
				vector4(-1819.4907, 793.5951, 138.0846, 132.5959), -- Banham Canyon Dr
				-- vector4(549.2471, 2669.6699, 42.1565, 96.9846), -- Route 68
				vector4(1392.0671, 3606.1155, 34.9809, 203.5101), -- Algonquin Blvd
				-- vector4(1984.2482, 3054.3589, 47.2151, 240.0611), -- Panorama Dr
			},

			--? For icons, use Iconify: https://icon-sets.iconify.design
			Categories = {
				{ name = "Tüm Ürünler", type = "all",         icon = "ic:round-clear-all" }, --! Tüm marketler için zorunlu
				{ name = "Yiyecekler",  type = "food",        icon = "mdi:food-drumstick" },
				{ name = "İçecekler",   type = "drinks",      icon = "ion:water-sharp" },
				{ name = "Elektronik",  type = "electronics", icon = "ic:round-phone-iphone" },
				{ name = "Aletler",     type = "tools",       icon = "ion:hammer" },
				{ name = "Tütün",       type = "tobacco",     icon = "mdi:smoking" },
				{ name = "Sağlık",      type = "healing",     icon = "material-symbols:healing" },
				{ name = "Spor",        type = "sports",      icon = "mdi:skateboard" },
			},

			Items = {
				-- Food & Essentials
				{ name = "phone",          label = "Telefon",              category = "electronics", price = 30 },
				-- DaddyRP: işletme malzemeleri, gerisi oyuncu üretiminden (daddy_venue menu-plan)
				{ name = "daddy_crate_grocery", label = "Bakkaliye Kolisi", category = "food", price = 100 },
				{ name = "daddy_crate_produce", label = "Manav Kasası", category = "food", price = 100 },
				{ name = "daddy_crate_hotdrink", label = "Sıcak İçecek Kolisi", category = "food", price = 100 },
				{ name = "daddy_crate_soda", label = "Meşrubat ve Buz Kolisi", category = "food", price = 100 },
				{ name = "daddy_crate_liquor", label = "Likör ve Aroma Kasası", category = "food", price = 150 },
				{ name = "daddy_crate_seafood", label = "Deniz Ürünleri Kasası", category = "food", price = 200 },
				{ name = "sandwich",       label = "Sandviç",              category = "food",        price = 30 },
				{ name = "water_bottle",   label = "Su",                   category = "drinks",      price = 30 },
				{ name = "radio",          label = "Telsiz",               category = "electronics", price = 30 },
				{ name = "bandage",        label = "Bandaj",               category = "healing",     price = 30 },
				{ name = "polaroid_empty", label = "Boş Polaroid",         category = "electronics", price = 10 },
				{ name = "game_pad",       label = "Oyun Tableti",         category = "electronics", price = 1000 },

				-- Backpacks & Security (oxlyn_backpack)
				{ name = "backpack_level_1",            label = "Küçük Sırt Çantası",      category = "tools", price = 500 },
				{ name = "backpack_level_2",            label = "Orta Boy Sırt Çantası",   category = "tools", price = 1000 },
				{ name = "backpack_level_3",            label = "Büyük Sırt Çantası",      category = "tools", price = 2000 },
				{ name = "backpack_level_4",            label = "Kamp Sırt Çantası",       category = "tools", price = 3500 },
				{ name = "backpack_padlock",            label = "Asma Kilit",              category = "tools", price = 250 },
				{ name = "backpack_fingerprint_padlock", label = "Parmak İzi Kilidi",       category = "tools", price = 500 },

				-- Tobacco & Vaping (zyke_smoking)
				{ name = "cigarette_pack",       label = "Sigara Paketi",          category = "tobacco", price = 50 },
				{ name = "lighter",              label = "Çakmak",                 category = "tobacco", price = 50 },
				-- { name = "cigar",                label = "Puro",                   category = "tobacco", price = 100 },
				{ name = "vape",                 label = "Elektronik Sigara",      category = "tobacco", price = 500 },
				{ name = "vape_battery",         label = "Vape Bataryası",         category = "tobacco", price = 100 },
				{ name = "vape_vanilla_flavour", label = "Vanilya Aroması",        category = "tobacco", price = 150 },
				{ name = "vape_green_flavour",   label = "Yeşil Aroma",            category = "tobacco", price = 150 },
				{ name = "vape_purple_flavour",  label = "Mor Aroma",              category = "tobacco", price = 150 },
				{ name = "vape_rainbow_flavour", label = "Gökkuşağı Aroması",      category = "tobacco", price = 200 },
				{ name = "bong",                 label = "Bong",                   category = "tobacco", price = 400 },
				{ name = "bong_water",           label = "Bong Suyu",              category = "tobacco", price = 50 },
				{ name = "outfit_bag",     label = "Kıyafet Çantası",      category = "tools",       price = 500 },
				{ name = "parachute",      label = "Paraşüt",              category = "tools",       price = 500 },
				{ name = "spray_can",      label = "Sprey Boya",           category = "tools",       price = 1000 },
				{ name = "spray_remover",  label = "Graffiti Temizleyici", category = "tools",       price = 100 },
				{ name = "notebook",  	   label = "Not Defteri",          category = "tools",       price = 50 },
				{ name = "boombox_a",      label = "Büyük Hoparlör",       category = "electronics", price = 500 },
				{ name = "boombox_f",      label = "Yer Hoparlörü",        category = "electronics", price = 500 },
				{ name = "boombox_b",      label = "Taşınabilir Teyp",     category = "electronics", price = 500 },
				{ name = "boombox_c",      label = "Taşınabilir Hoparlör", category = "electronics", price = 500 },
				{ name = "boombox_d",      label = "El Radyosu",           category = "electronics", price = 500 },
				{ name = "boombox_e",      label = "Mini Hoparlör",        category = "electronics", price = 500 },
				
				-- TVs & Monitors
				{ name = "tv_laptop",      label = "Dizüstü Bilgisayar",   category = "electronics", price = 2500 },
				{ name = "tv_monitor_large", label = "Büyük Monitör",       category = "electronics", price = 2800 },
				{ name = "tv_crt_old",     label = "Eski CRT Televizyon",   category = "electronics", price = 3000 },
				{ name = "tv_trevor",      label = "Trevor'un Televizyonu", category = "electronics", price = 3100 },
				{ name = "tv_flat_small",  label = "Küçük Düz Ekran TV",   category = "electronics", price = 3200 },
				{ name = "tv_crt_classic", label = "Klasik CRT Televizyon", category = "electronics", price = 3300 },
				{ name = "tv_vintage",     label = "Vintage Televizyon",    category = "electronics", price = 3500 },
				{ name = "tv_crt_wood",    label = "Ahşap Kasalı CRT Televizyon", category = "electronics", price = 3800 },
				{ name = "tv_crt_overlay", label = "Çerçeveli CRT Televizyon", category = "electronics", price = 4000 },
				{ name = "tv_smash",       label = "Retro Smash Televizyon", category = "electronics", price = 4200 },
				{ name = "tv_flat_medium", label = "Orta Boy Düz Ekran TV", category = "electronics", price = 5000 },
				{ name = "tv_flat_screen", label = "Düz Ekran Televizyon", category = "electronics", price = 5500 },
				{ name = "tv_flat_classic", label = "Klasik Düz Ekran TV",  category = "electronics", price = 6000 },
				{ name = "tv_flat_overlay", label = "Çerçeveli Düz Ekran TV", category = "electronics", price = 6500 },
				{ name = "tv_flat_modern", label = "Modern Düz Ekran TV",   category = "electronics", price = 8000 },
				{ name = "tv_flat_premium", label = "Premium Düz Ekran TV", category = "electronics", price = 10000 },
				-- { name = "tv_curved_xl",   label = "XL Kavisli Ekran",     category = "electronics", price = 12500 },
				-- { name = "tv_cinema",      label = "Sinema Televizyonu",   category = "electronics", price = 15000 },

				-- Spor ekipmanı (BDX: yalnızca sunucuda kurulu ve çalışan sporlar)
				{ name = "skateboard",     label = "Kaykay",               category = "sports",      price = 2500 },
				{ name = "bmx",            label = "BMX",                  category = "sports",      price = 3500 },
				-- { name = "slopstyle",      label = "Slopestyle Bisikleti", category = "sports",      price = 4500 },
			},


			Requirement = {
				Job = {
					required = false, -- Whether a job is required to access the shop
					jobs = {
						{
							label = "Polis", -- The display name of the required job
							name = "police", -- The name of the required job
							grade = 0, -- Minimum job grade required to access the shop
						},
					},
				},
				License = {
					required = false, -- Whether a license is required to access the shop
					buyDialog = true, -- Displays a dialog prompting the player to purchase the required license
					label = "Silah Ruhsatı", -- The display name of the required license
					type = "weapon", -- The type of the required license (e.g., "weapon")
					price = 1000, -- The cost of the license
				},
			},

			Locales = { --? Para birimi simgesi, buton yazıları ve daha fazlası "locales/" klasöründe bulunabilir
				MainHeader = {
					title = "Market",
					tag = "7/24",
					description =
					"Mahallenizdeki markete hoş geldiniz, gece gündüz her zaman hizmetinizdeyiz!\nİhtiyaçlarınıza özel seçilmiş kaliteli ürünleri keşfedin.",
				},
				CartHeader = {
					title = "Alışveriş",
					tag = "Sepet",
					description =
					"Seçtiğiniz ürünleri gözden geçirin ve\nbirden fazla ödeme seçeneğiyle güvenli ve kolay bir şekilde ödeme yapın.",
				},
			},

			Blip = {
				enabled = false, -- If true, displays a map blip for the shop locations
				name = "Market [7/24]", -- Name displayed on the map
				sprite = 59, -- Blip icon type --? Reference: https://docs.fivem.net/docs/game-references/blips
				color = 0, -- Blip color --? Reference: https://docs.fivem.net/docs/game-references/blips/#blip-colors
				scale = 0.7, -- Size of the blip
			},

			Indicator = {
				Ped = {
					enabled = true,     -- If true, spawns a ped (NPC) at the locations
					model = `mp_m_shopkeep_01`, -- Ped model type --? Reference: https://docs.fivem.net/docs/game-references/ped-models
					scenario = "WORLD_HUMAN_AA_SMOKE", -- Animation scenario for the ped --? Reference: https://github.com/DioneB/gtav-scenarios
				},
				Marker = {
					enabled = false, -- If true, displays a marker at the shop locations
					type = 20,      -- Marker type --? Reference: https://docs.fivem.net/docs/game-references/markers
					size = vec3(0.7, 0.7, 0.7), -- Size of the marker
					color = { 65, 133, 235, 120 }, -- RGBA color of the marker
					bobUpAndDown = false, -- If true, marker moves up and down
					faceCamera = false, -- If true, marker faces the player's camera
					rotate = true,  -- If true, marker rotates
				},
			},

			Interaction = {
				OpenKey = 38, -- Default: 38 (E key) --? Reference: https://docs.fivem.net/docs/game-references/controls

				HelpText = {
					enabled = false, -- If true, displays floating help text near the interaction point
					distance = 2.5, -- Distance within which help text appears and is interactable
				},
				FloatingText = {
					enabled = false, -- If true, displays floating text above the shop NPC
					distance = 2.5, -- Distance within which floating text is visible and interactable
				},
				Target = {        -- Uses ox_target by default --? (modifiable in config/functions.lua)
					enabled = true, -- If true, enables targeting system
					boxZoneSize = vec3(4, 4, 4), -- Size of the target zone
					drawSprite = false, -- If true, displays a sprite for the target zone
					distance = 2.5, -- Interaction distance
				},
			},
		},
	},
}
