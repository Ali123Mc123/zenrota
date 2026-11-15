local config = {
    pawnShops = {
        -- Kalpazan

        {
            name = "Kalpazan Dükkanı",
            blipName = "Kalpazan Dükkanı",
            coords = vector3(2519.8638, 4106.0918, 35.5851),
            size = vector3(1.5, 1.8, 2.0),
            heading = 152.9843,
            debugPoly = false,
            distance = 3.0,
            type = "money",
            blip = {
                enabled = false,
                sprite = 431,
                color = 1,
                scale = 0.7
            },
            jobRestriction = {
                enabled = true,
                allowedJobs = { "kalpazan1" },
                allowedGangs = {},
                type = "job"
            },
            -- NPC Ayarları
            npc = {
                enabled = true,
                model = 'a_m_m_business_01',
                coords = vector4(2519.8638, 4106.0918, 35.5851, 152.9843),
                scenario = 'WORLD_HUMAN_CLIPBOARD'
            },
            -- Bu shop'a özel itemler
            pawnItems = {
                {
                    item = 'black_money',
                    price = 1
                },
            },
            meltingItems = {}
        },

        {
            name = "Kalpazan Dükkanı",
            blipName = "Kalpazan Dükkanı",
            coords = vector3(427.8322, -1887.4358, 28.9520),
            size = vector3(1.5, 1.8, 2.0),
            heading = 356.0229,
            debugPoly = false,
            distance = 3.0,
            type = "money",
            blip = {
                enabled = false,
                sprite = 431,
                color = 1,
                scale = 0.7
            },
            jobRestriction = {
                enabled = true,
                allowedJobs = { "kalpazan2" },
                allowedGangs = {},
                type = "job"
            },
            -- NPC Ayarları
            npc = {
                enabled = true,
                model = 'a_m_m_business_01',
                coords = vector4(427.8322, -1887.4358, 28.9520, 179.0517),
                scenario = 'WORLD_HUMAN_CLIPBOARD'
            },
            -- Bu shop'a özel itemler
            pawnItems = {
                {
                    item = 'black_money',
                    price = 1
                },
            },
            meltingItems = {}
        },

        {
            id = 3,
            name = "Kalpazan Dükkanı",
            blipName = "Kalpazan Dükkanı",
            coords = vector3(-442.9414, -2184.3533, 9.5236),
            size = vector3(1.5, 1.8, 2.0),
            heading = 2.7865,
            debugPoly = false,
            distance = 3.0,
            type = "money",
            blip = {
                enabled = false,
                sprite = 431,
                color = 1,
                scale = 0.7
            },
            jobRestriction = {
                enabled = true,
                allowedJobs = { "kalpazan3" },
                allowedGangs = {},
                type = "job"
            },
            -- NPC Ayarları
            npc = {
                enabled = true,
                model = 'a_m_m_business_01',
                coords = vector4(-442.9414, -2184.3533, 9.5236, 2.7865),
                scenario = 'WORLD_HUMAN_CLIPBOARD'
            },
            -- Bu shop'a özel itemler
            pawnItems = {
                {
                    item = 'black_money',
                    price = 1
                },
            },
            meltingItems = {}
        },

        -- {
        --     name = "Kalpazan Dükkanı",
        --     blipName = "Kalpazan Dükkanı",
        --     coords = vector3(-551.9147, -199.0817, 83.7331),
        --     size = vector3(1.5, 1.8, 2.0),
        --     heading = 99.9334,
        --     debugPoly = false,
        --     distance = 3.0,
        --     type = "money",
        --     blip = {
        --         enabled = false,
        --         sprite = 431,
        --         color = 1,
        --         scale = 0.7
        --     },
        --     jobRestriction = {
        --         enabled = true,
        --         allowedJobs = { "kalpazan4" },
        --         allowedGangs = {},
        --         type = "job"
        --     },
        --     -- NPC Ayarları
        --     npc = {
        --         enabled = true,
        --         model = 'a_m_m_business_01',
        --         coords = vector4(-551.9147, -199.0817, 83.7331, 99.9334),
        --         scenario = 'WORLD_HUMAN_CLIPBOARD'
        --     },
        --     -- Bu shop'a özel itemler
        --     pawnItems = {
        --         {
        --             item = 'black_money',
        --             price = 1
        --         },
        --     },
        --     meltingItems = {}
        -- },

        {
            name = "Tacir Dükkanı",
            blipName = "Tacir Dükkanı",
            coords = vector3(1700.6436, 3294.2026, 48.9221),
            size = vector3(1.5, 1.8, 2.0),
            heading = 25.5127,
            debugPoly = false,
            distance = 3.0,
            type = "black",
            blip = {
                enabled = false,
                sprite = 431,
                color = 1,
                scale = 0.7
            },
            jobRestriction = {
                enabled = true,
                allowedJobs = { "tacir3" },
                allowedGangs = {},
                type = "job"
            },
            -- NPC Ayarları
            npc = {
                enabled = true,
                model = 'a_m_m_business_01',
                coords = vector4(1700.6436, 3294.2026, 48.9221, 25.5127),
                scenario = 'WORLD_HUMAN_CLIPBOARD'
            },
            -- Bu shop'a özel itemler
            pawnItems = {
                {
                    item = 'packed_coke',
                    price = 700
                },
                {
                    item = 'rolled_weed',
                    price = 570
                },
                {
                    item = 'packed_meth',
                    price = 920
                }
            },
            meltingItems = {}
        },

        {
            name = "Tacir Dükkanı",
            blipName = "Tacir Dükkanı",
            coords = vector3(10.6923, -672.8823, 33.4495),
            size = vector3(1.5, 1.8, 2.0),
            heading = 3.6092,
            debugPoly = false,
            distance = 3.0,
            type = "black",
            blip = {
                enabled = false,
                sprite = 431,
                color = 1,
                scale = 0.7
            },
            jobRestriction = {
                enabled = true,
                allowedJobs = { "tacir2" },
                allowedGangs = {},
                type = "job"
            },
            -- NPC Ayarları
            npc = {
                enabled = true,
                model = 'a_m_m_business_01',
                coords = vector4(10.6923, -672.8823, 33.4495, 3.6092),
                scenario = 'WORLD_HUMAN_CLIPBOARD'
            },
            -- Bu shop'a özel itemler
            pawnItems = {
                {
                    item = 'packed_coke',
                    price = 700
                },
                {
                    item = 'rolled_weed',
                    price = 570
                },
                {
                    item = 'packed_meth',
                    price = 920
                }
            },
            meltingItems = {}
        },

        {
            name = "Tacir Dükkanı",
            blipName = "Tacir Dükkanı",
            coords = vector3(943.7349, -1699.7452, 30.0850),
            size = vector3(1.5, 1.8, 2.0),
            heading = 138.1777,
            debugPoly = false,
            distance = 3.0,
            type = "black",
            blip = {
                enabled = false,
                sprite = 431,
                color = 1,
                scale = 0.7
            },
            jobRestriction = {
                enabled = true,
                allowedJobs = { "tacir1" },
                allowedGangs = {},
                type = "job"
            },
            -- NPC Ayarları
            npc = {
                enabled = true,
                model = 'a_m_m_business_01',
                coords = vector4(943.7349, -1699.7452, 30.0850, 138.1777),
                scenario = 'WORLD_HUMAN_CLIPBOARD'
            },
            -- Bu shop'a özel itemler
            pawnItems = {
                {
                    item = 'packed_coke',
                    price = 700
                },
                {
                    item = 'rolled_weed',
                    price = 570
                },
                {
                    item = 'packed_meth',
                    price = 920
                }
            },
            meltingItems = {}
        },

        -- {
        --     name = "Tacir Dükkanı",
        --     blipName = "Tacir Dükkanı",
        --     coords = vector3(3123.4949, 1161.8134, 19.3008),
        --     size = vector3(1.5, 1.8, 2.0),
        --     heading = 129.2007,
        --     debugPoly = false,
        --     distance = 3.0,
        --     type = "money",
        --     blip = {
        --         enabled = false,
        --         sprite = 431,
        --         color = 1,
        --         scale = 0.7
        --     },
        --     jobRestriction = {
        --         enabled = false,
        --         allowedJobs = {},
        --         allowedGangs = {},
        --         type = "job"
        --     },
        --     -- NPC Ayarları
        --     npc = {
        --         enabled = true,
        --         model = 'a_m_m_business_01',
        --         coords = vector4(3123.4949, 1161.8134, 19.3008, 129.2007),
        --         scenario = 'WORLD_HUMAN_CLIPBOARD'
        --     },
        --     -- Bu shop'a özel itemler
        --     pawnItems = {
        --         {
        --             item = 'weed_seed',
        --             price = 25
        --         },
        --         {
        --             item = 'coke_seed',
        --             price = 25
        --         },
        --         {
        --             item = 'fertilizer',
        --             price = 25
        --         },
        --         {
        --             item = 'baggy',
        --             price = 25
        --         },
        --         {
        --             item = 'plant_pot',
        --             price = 25
        --         },
        --         {
        --             item = 'default_soil',
        --             price = 25
        --         },
        --         {
        --             item = 'watering_can',
        --             price = 10
        --         },
        --         {
        --             item = 'plant_trimmers',
        --             price = 100
        --         },
        --         {
        --             item = 'phosphorus',
        --             price = 25
        --         },
        --         {
        --             item = 'pills',
        --             price = 25
        --         },
        --         {
        --             item = 'acetone',
        --             price = 25
        --         },
        --         {
        --             item = 'hammer',
        --             price = 100
        --         },
        --         {
        --             item = 'gasoline',
        --             price = 50
        --         },
        --     },
        --     meltingItems = {}
        -- },

        -- {
        --     name = "Tacir Dükkanı",
        --     blipName = "Tacir Dükkanı",
        --     coords = vector3(3124.4629, 1159.9199, 19.1931),
        --     size = vector3(1.5, 1.8, 2.0),
        --     heading = 104.0332,
        --     debugPoly = false,
        --     distance = 3.0,
        --     type = "black",
        --     blip = {
        --         enabled = false,
        --         sprite = 431,
        --         color = 1,
        --         scale = 0.7
        --     },
        --     jobRestriction = {
        --         enabled = false,
        --         allowedJobs = {},
        --         allowedGangs = {},
        --         type = "job"
        --     },
        --     -- NPC Ayarları
        --     npc = {
        --         enabled = true,
        --         model = 'a_m_m_business_01',
        --         coords = vector4(3124.4629, 1159.9199, 19.1931, 104.0332),
        --         scenario = 'WORLD_HUMAN_CLIPBOARD'
        --     },
        --     -- Bu shop'a özel itemler
        --     pawnItems = {
        --         {
        --             item = 'packaged_cooked_high_quality_coke',
        --             price = 540
        --         },
        --         {
        --             item = 'packaged_dried_high_quality_weed',
        --             price = 400
        --         },
        --         {
        --             item = 'packaged_default_meth',
        --             price = 200
        --         },
        --     },
        --     meltingItems = {}
        -- },

         {
             name = "weedshop1",
             blipName = "weedshop1",
             coords = vector3(-88.1011, 374.9435, 112.4583),
             size = vector3(1.5, 1.8, 2.0),
             heading = 353.3256,
             debugPoly = false,
             distance = 3.0,
             type = "item",       -- Yeni tip: item (eşya takası)
             blip = {
                 enabled = false, -- Blip gösterilsin mi?
                 sprite = 431,
                 color = 1,       -- Kırmızı renk tacir için
                 scale = 0.7
             },
             -- Meslek kısıtlaması
             jobRestriction = {
                 enabled = true,        -- Bu shop için meslek/gang kısıtlaması açık
                 allowedJobs = { "weedshop1" },
                 allowedGangs = { "" }, -- Gerekirse buraya gang ekle
                 type = "job"           -- "job", "gang" veya "both" (her ikisi de kontrol edilsin)
             },
             -- NPC Ayarları
             npc = {
                 enabled = true,
                 model = 'a_m_m_business_01',
                 coords = vector4(-88.1011, 374.9435, 112.4583, 353.3256),
                 scenario = 'WORLD_HUMAN_CLIPBOARD'
             },
             pawnItems = {
                 {
                    item = 'ifaks',         -- Rehin dükkanında satılmayacak, sadece takas edilecek eşya
                    requiredItem = 'ifaks', -- Oyuncudan alınacak item
                    requiredCount = 2,      -- Kaç tane alınacak
                    givenItem = 'nostress', -- Verilecek item
                    givenCount = 1          -- Kaç tane verilecek
                 },
             },
             meltingItems = {}
         },

        {
            name = "Normal Rehin Dükkanı",
            blipName = "Rehin Dükkanı",
            coords = vector3(706.9120, -960.9119, 28.3953),
            size = vector3(1.5, 1.8, 2.0),
            heading = 77.5298,
            debugPoly = false,
            distance = 3.0,
            type = "black",
            blip = {
                enabled = false,
                sprite = 431,
                color = 5,
                scale = 0.7
            },
            jobRestriction = {
                enabled = true,
                allowedJobs = { "pawnshop1" },
                allowedGangs = {},
                type = "job"
            },
            npc = {
                enabled = true,
                model = 'a_m_m_business_01',
                coords = vector4(706.9120, -960.9119, 28.3953, 77.5298),
                scenario = 'WORLD_HUMAN_CLIPBOARD'
            },
            pawnItems = {
                {
                    item = 'stolen_micro_01',
                    price = 244
                },
                {
                    item = 'stolen_micro_02',
                    price = 263
                },
                {
                    item = 'stolen_vcr_01',
                    price = 181
                },
                {
                    item = 'stolen_tv_03',
                    price = 206
                },
                {
                    item = 'stolen_tv_flat_03',
                    price = 313
                },
                {
                    item = 'stolen_console_01',
                    price = 369
                },
                {
                    item = 'stolen_mp3_dock',
                    price = 313
                },
                {
                    item = 'stolen_kettle_01',
                    price = 306
                },
                {
                    item = 'stolen_toaster_01',
                    price = 213
                },
                {
                    item = 'stolen_toaster_02',
                    price = 231
                },
                {
                    item = 'stolen_boombox_01',
                    price = 356
                },
                {
                    item = 'stolen_laptop_01a',
                    price = 500
                },
                {
                    item = 'stolen_tv_flat_01',
                    price = 425
                },
                {
                    item = 'stolen_telescope_01',
                    price = 413
                },
                {
                    item = 'stolen_mixer_01',
                    price = 213
                },
                {
                    item = 'stolen_kscales_01',
                    price = 175
                },
                {
                    item = 'stolen_printer_01',
                    price = 338
                },
                {
                    item = 'stolen_monitor_01',
                    price = 388
                },
                {
                    item = 'stolen_mmaudio_01',
                    price = 294
                },
                {
                    item = 'stolen_tapeplayer_01',
                    price = 181
                },
                {
                    item = 'stolen_hairdryer_01',
                    price = 181
                },
                {
                    item = 'stolen_coffemac_02',
                    price = 181
                },
                {
                    item = 'goldbracelet',
                    price = 1725
                },
                {
                    item = 'goldbar',
                    price = 1725
                },
                {
                    item = 'rubynecklace',
                    price = 9750
                },
                {
                    item = 'silverbar',
                    price = 863
                },
                {
                    item = 'harddrive',
                    price = 863
                },
                {
                    item = 'goldbarstack',
                    price = 8125
                },
                {
                    item = 'goldwatch',
                    price = 863
                },
                {
                    item = 'goldchain',
                    price = 1725
                },
                {
                    item = 'diamondring',
                    price = 1219
                },
                {
                    item = 'diamondnecklace',
                    price = 3250
                },
                {
                    item = 'paintingcity',
                    price = 1725
                },
                {
                    item = 'paintingfamily',
                    price = 1725
                },
                {
                    item = 'paintingguys',
                    price = 1725
                },
                {
                    item = 'paintinglady',
                    price = 1725
                },
                {
                    item = 'paintingnative',
                    price = 1725
                },
                {
                    item = 'paintingpaddle',
                    price = 1725
                },
                {
                    item = 'paintingart',
                    price = 1725
                },
                {
                    item = 'paintingclown',
                    price = 1725
                },
                {
                    item = 'paintingpig',
                    price = 1725
                },
                {
                    item = 'diamond_ring',
                    price = 1219
                },
                {
                    item = 'paintingrocket',
                    price = 1725
                },
                {
                    item = 'silverring',
                    price = 813
                },
                {
                    item = 'bitcoin',
                    price = 113750
                },
                {
                    item = 'ethereum',
                    price = 32500
                },
                {
                    item = 'ripple',
                    price = 8125
                },
                {
                    item = 'dogecoin',
                    price = 1625
                }
            },
            meltingItems = {}
        },

        {
            id = "pawnshop2",
            name = "Normal Rehin Dükkanı 2",
            blipName = "Rehin Dükkanı 2",
            coords = vector3(-1576.0033, -453.4363, 37.2072),
            size = vector3(1.5, 1.8, 2.0),
            heading = 89.1729,
            debugPoly = false,
            distance = 3.0,
            type = "black",
            blip = {
                enabled = false,
                sprite = 431,
                color = 5,
                scale = 0.7
            },
            jobRestriction = {
                enabled = true,
                allowedJobs = { "pawnshop2" },
                allowedGangs = {},
                type = "job"
            },
            npc = {
                enabled = true,
                model = 'a_m_m_business_01',
                coords = vector4(-1576.0033, -453.4363, 37.2072, 89.1729),
                scenario = 'WORLD_HUMAN_CLIPBOARD'
            },
            pawnItems = {
                {
                    item = 'stolen_micro_01',
                    price = 244
                },
                {
                    item = 'stolen_micro_02',
                    price = 263
                },
                {
                    item = 'stolen_vcr_01',
                    price = 181
                },
                {
                    item = 'stolen_tv_03',
                    price = 206
                },
                {
                    item = 'stolen_tv_flat_03',
                    price = 313
                },
                {
                    item = 'stolen_console_01',
                    price = 369
                },
                {
                    item = 'stolen_mp3_dock',
                    price = 313
                },
                {
                    item = 'stolen_kettle_01',
                    price = 306
                },
                {
                    item = 'stolen_toaster_01',
                    price = 213
                },
                {
                    item = 'stolen_toaster_02',
                    price = 231
                },
                {
                    item = 'stolen_boombox_01',
                    price = 356
                },
                {
                    item = 'stolen_laptop_01a',
                    price = 500
                },
                {
                    item = 'stolen_tv_flat_01',
                    price = 425
                },
                {
                    item = 'stolen_telescope_01',
                    price = 413
                },
                {
                    item = 'stolen_mixer_01',
                    price = 213
                },
                {
                    item = 'stolen_kscales_01',
                    price = 175
                },
                {
                    item = 'stolen_printer_01',
                    price = 338
                },
                {
                    item = 'stolen_monitor_01',
                    price = 388
                },
                {
                    item = 'stolen_mmaudio_01',
                    price = 294
                },
                {
                    item = 'stolen_tapeplayer_01',
                    price = 181
                },
                {
                    item = 'stolen_hairdryer_01',
                    price = 181
                },
                {
                    item = 'stolen_coffemac_02',
                    price = 181
                },
                {
                    item = 'goldbracelet',
                    price = 1725
                },
                {
                    item = 'goldbar',
                    price = 1725
                },
                {
                    item = 'rubynecklace',
                    price = 9750
                },
                {
                    item = 'silverbar',
                    price = 863
                },
                {
                    item = 'harddrive',
                    price = 863
                },
                {
                    item = 'goldbarstack',
                    price = 8125
                },
                {
                    item = 'goldwatch',
                    price = 863
                },
                {
                    item = 'goldchain',
                    price = 1725
                },
                {
                    item = 'diamondring',
                    price = 1219
                },
                {
                    item = 'diamondnecklace',
                    price = 3250
                },
                {
                    item = 'paintingcity',
                    price = 1725
                },
                {
                    item = 'paintingfamily',
                    price = 1725
                },
                {
                    item = 'paintingguys',
                    price = 1725
                },
                {
                    item = 'paintinglady',
                    price = 1725
                },
                {
                    item = 'paintingnative',
                    price = 1725
                },
                {
                    item = 'paintingpaddle',
                    price = 1725
                },
                {
                    item = 'paintingart',
                    price = 1725
                },
                {
                    item = 'paintingclown',
                    price = 1725
                },
                {
                    item = 'paintingpig',
                    price = 1725
                },
                {
                    item = 'diamond_ring',
                    price = 1219
                },
                {
                    item = 'paintingrocket',
                    price = 1725
                },
                {
                    item = 'silverring',
                    price = 813
                },
                {
                    item = 'bitcoin',
                    price = 113750
                },
                {
                    item = 'ethereum',
                    price = 32500
                },
                {
                    item = 'ripple',
                    price = 8125
                },
                {
                    item = 'dogecoin',
                    price = 1625
                }
            },
            meltingItems = {}
        },

        {
            id = 13,
            name = "weedshop2",
            blipName = "weedshop2",
            coords = vec3(755.8326, -1866.5144, 28.2936),
            size = vector3(1.5, 1.8, 2.0),
            heading = 322.8303,
            debugPoly = false,
            distance = 3.0,
            type = "item",       -- Yeni tip: item (eşya takası)
            blip = {
                enabled = false, -- Blip gösterilsin mi?
                sprite = 431,
                color = 1,       -- Kırmızı renk tacir için
                scale = 0.7
            },
            -- Meslek kısıtlaması
            jobRestriction = {
                enabled = true,        -- Bu shop için meslek/gang kısıtlaması açık
                allowedJobs = { "weedshop2" },
                allowedGangs = { "" }, -- Gerekirse buraya gang ekle
                type = "job"           -- "job", "gang" veya "both" (her ikisi de kontrol edilsin)
            },
            -- NPC Ayarları
            npc = {
                enabled = true,
                model = 'a_m_m_business_01',
                coords = vec4(755.8326, -1866.5144, 28.2936, 264.4846),
                scenario = 'WORLD_HUMAN_CLIPBOARD'
            },
            pawnItems = {
                {
                    item = 'ifaks',         -- Rehin dükkanında satılmayacak, sadece takas edilecek eşya
                    requiredItem = 'ifaks', -- Oyuncudan alınacak item
                    requiredCount = 2,      -- Kaç tane alınacak
                    givenItem = 'nostress', -- Verilecek item
                    givenCount = 1          -- Kaç tane verilecek
                },
            },
            meltingItems = {}
        },

        -- Black Market 1
        {
            name = "Karaborsa 1",
            blipName = "Karaborsa 1",
            coords = vec3(-32.5465, -613.9294, 35.0810),
            size = vector3(1.5, 1.8, 2.0),
            heading = 103.4274,
            debugPoly = false,
            distance = 3.0,
            type = "ox_shop",
            oxShop = "blackmarket1",
            blip = {
                enabled = false,
                sprite = 431,
                color = 1,
                scale = 0.7
            },
            jobRestriction = {
                enabled = true,
                allowedJobs = { "blackmarket1" },
                allowedGangs = {},
                type = "job"
            },
            npc = {
                enabled = true,
                model = 'a_m_m_soucent_04',
                coords = vec4(-32.5465, -613.9294, 35.0810, 103.4274),
                scenario = 'WORLD_HUMAN_AA_COFFEE'
            },
            pawnItems = {},
            meltingItems = {}
        },

        -- Black Market 2
        {
            name = "Karaborsa 2",
            blipName = "Karaborsa 2",
            coords = vec3(1299.6692, 318.3142, 80.9909),
            size = vector3(1.5, 1.8, 2.0),
            heading = 286.9387,
            debugPoly = false,
            distance = 3.0,
            type = "ox_shop",
            oxShop = "blackmarket2",
            blip = {
                enabled = false,
                sprite = 431,
                color = 1,
                scale = 0.7
            },
            jobRestriction = {
                enabled = true,
                allowedJobs = { "blackmarket2" },
                allowedGangs = {},
                type = "job"
            },
            npc = {
                enabled = true,
                model = 'a_m_m_soucent_04',
                coords = vec4(1299.6692, 318.3142, 80.9909, 286.9387),
                scenario = 'WORLD_HUMAN_AA_COFFEE'
            },
            pawnItems = {},
            meltingItems = {}
        },

        -- Lojistik 1
        {
            name = "Lojistik 1",
            blipName = "Lojistik 1",
            coords = vec3(1987.7142, 3016.7178, 47.0563),
            size = vector3(1.5, 1.8, 2.0),
            heading = 154.2245,
            debugPoly = false,
            distance = 3.0,
            type = "ox_shop",
            oxShop = "lojistik1",
            blip = {
                enabled = false,
                sprite = 431,
                color = 1,
                scale = 0.7
            },
            jobRestriction = {
                enabled = true,
                allowedJobs = { "lojistik1" },
                allowedGangs = {},
                type = "job"
            },
            npc = {
                enabled = true,
                model = 'a_m_m_soucent_04',
                coords = vec4(1987.7142, 3016.7178, 47.0563, 154.2245),
                scenario = 'WORLD_HUMAN_AA_COFFEE'
            },
            pawnItems = {},
            meltingItems = {}
        },

        -- Lojistik 2
        {
            name = "Lojistik 2",
            blipName = "Lojistik 2",
            coords = vec3(-841.7422, -397.5161, 30.4717),
            size = vector3(1.5, 1.8, 2.0),
            heading = 297.6470,
            debugPoly = false,
            distance = 3.0,
            type = "ox_shop",
            oxShop = "lojistik2",
            blip = {
                enabled = false,
                sprite = 431,
                color = 1,
                scale = 0.7
            },
            jobRestriction = {
                enabled = true,
                allowedJobs = { "lojistik2" },
                allowedGangs = {},
                type = "job"
            },
            npc = {
                enabled = true,
                model = 'a_m_m_soucent_04',
                coords = vec4(-841.7422, -397.5161, 30.4717, 297.6470),
                scenario = 'WORLD_HUMAN_AA_COFFEE'
            },
            pawnItems = {},
            meltingItems = {}
        },

        -- Torbacı 1
        {
            name = "Torbacı 1",
            blipName = "Torbacı 1",
            coords = vec3(1250.1848, -1966.2211, 43.3162),
            size = vector3(1.5, 1.8, 2.0),
            heading = 9.0880,
            debugPoly = false,
            distance = 3.0,
            type = "ox_shop",
            oxShop = "torbaci1",
            blip = {
                enabled = false,
                sprite = 431,
                color = 1,
                scale = 0.7
            },
            jobRestriction = {
                enabled = true,
                allowedJobs = { "torbaci1" },
                allowedGangs = {},
                type = "job"
            },
            npc = {
                enabled = true,
                model = 'a_m_m_business_01',
                coords = vec4(1250.1848, -1966.2211, 43.3162, 9.0880),
                scenario = 'WORLD_HUMAN_AA_COFFEE'
            },
            pawnItems = {},
            meltingItems = {}
        },

        -- Torbacı 2
        {
            name = "Torbacı 2",
            blipName = "Torbacı 2",
            coords = vec3(159.1886, -2203.4324, 4.6880),
            size = vector3(1.5, 1.8, 2.0),
            heading = 89.7177,
            debugPoly = false,
            distance = 3.0,
            type = "ox_shop",
            oxShop = "torbaci2",
            blip = {
                enabled = false,
                sprite = 431,
                color = 1,
                scale = 0.7
            },
            jobRestriction = {
                enabled = true,
                allowedJobs = { "torbaci2" },
                allowedGangs = {},
                type = "job"
            },
            npc = {
                enabled = true,
                model = 'a_m_m_business_01',
                coords = vec4(159.1886, -2203.4324, 4.6880, 89.7177),
                scenario = 'WORLD_HUMAN_AA_COFFEE'
            },
            pawnItems = {},
            meltingItems = {}
        },

        -- Torbacı 3
        {
            name = "Torbacı 3",
            blipName = "Torbacı 3",
            coords = vec3(-36.2083, -2687.9907, 6.0002),
            size = vector3(1.5, 1.8, 2.0),
            heading = 67.8668,
            debugPoly = false,
            distance = 3.0,
            type = "ox_shop",
            oxShop = "torbaci3",
            blip = {
                enabled = false,
                sprite = 431,
                color = 1,
                scale = 0.7
            },
            jobRestriction = {
                enabled = true,
                allowedJobs = { "torbaci3" },
                allowedGangs = {},
                type = "job"
            },
            npc = {
                enabled = true,
                model = 'a_m_m_business_01',
                coords = vec4(-36.2083, -2687.9907, 6.0002, 67.8668),
                scenario = 'WORLD_HUMAN_AA_COFFEE'
            },
            pawnItems = {},
            meltingItems = {}
        },
    }
}

for i, shop in ipairs(config.pawnShops) do
    shop.id = i
    local job = shop.jobRestriction and shop.jobRestriction.allowedJobs and shop.jobRestriction.allowedJobs[1]
    shop.key = job or ('shop_' .. i)
    shop.defaultCoords = shop.npc and vector4(shop.npc.coords.x, shop.npc.coords.y, shop.npc.coords.z, shop.npc.coords.w) or vector4(shop.coords.x, shop.coords.y, shop.coords.z, shop.heading or 0.0)
    shop.defaultPrices = {}
    if shop.pawnItems then
        for _, pItem in ipairs(shop.pawnItems) do
            if pItem.item and pItem.price then
                shop.defaultPrices[pItem.item] = pItem.price
            end
        end
    end
end

return config
