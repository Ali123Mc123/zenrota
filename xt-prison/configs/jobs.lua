return {
    -- Her başarılı görevde düşürülecek ceza süresi (1 ay / 1 dakika)
    DefaultReduction = 1,

    -- Görevler arası genel kısa bekleme süresi (Saniye)
    GlobalCooldown = 15,

    -- Görev türleri ve noktaları
    Jobs = {
        -- 1. Elektrik ve Sigorta Panosu Tamiri (15 sn, -1 ay)
        electrical = {
            label = 'Elektrik Panosu Tamiri',
            icon = 'bolt',
            reduceMinutes = 1,
            duration = 15000, -- 15 saniye
            categoryCooldown = 180, -- 5 pano bittiğinde 3 dakika cooldown (diğer işlere yönlendirir)
            anim = {
                dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                clip = 'machinic_loop_mechandplayer',
                flag = 49
            },
            prop = {
                model = 'prop_tool_screwdvr01',
                bone = 28422,
                pos = vec3(0.0, 0.0, 0.0),
                rot = vec3(0.0, 0.0, 0.0)
            },
            locations = {
                { id = 'elec_1', coords = vec3(1760.6593, 2519.0835, 45.5650), heading = 256.1170 },
                { id = 'elec_2', coords = vec3(1737.5278, 2504.8440, 45.5650), heading = 164.2756 },
                { id = 'elec_3', coords = vec3(1761.4490, 2540.4746, 45.5650), heading = 354.5865 },
                { id = 'elec_4', coords = vec3(1718.5226, 2527.8196, 45.5648), heading = 117.6642 },
                { id = 'elec_5', coords = vec3(1679.6747, 2480.2598, 45.5649), heading = 140.8296 },
            }
        },

        -- 2. Avlu ve Çevre Temizliği (15 sn, -1 ay)
        cleaning = {
            label = 'Avlu Temizliği',
            icon = 'broom',
            reduceMinutes = 1,
            duration = 15000, -- 15 saniye
            categoryCooldown = 120, -- 5 nokta bittiğinde 2 dakika cooldown
            anim = {
                dict = 'amb@world_human_janitor@male@idle_a',
                clip = 'idle_a',
                flag = 49
            },
            prop = {
                model = 'prop_tool_broom',
                bone = 28422,
                pos = vec3(-0.01, 0.02, -0.03),
                rot = vec3(0.0, 0.0, 0.0)
            },
            locations = {
                { id = 'clean_1', coords = vec3(1706.9863, 2508.3086, 45.5649), heading = 281.2636 },
                { id = 'clean_2', coords = vec3(1739.7146, 2515.3967, 45.5650), heading = 320.5545 },
                { id = 'clean_3', coords = vec3(1753.2517, 2524.6584, 45.5651), heading = 139.1933 },
                { id = 'clean_4', coords = vec3(1761.1183, 2545.9338, 45.5650), heading = 334.4157 },
                { id = 'clean_5', coords = vec3(1699.1749, 2514.4712, 45.5604), heading = 289.2581 },
            }
        },

        -- 3. Mutfak ve Yemek Hazırlığı (15 sn, -1 ay)
        kitchen = {
            label = 'Mutfak İşi Yap',
            icon = 'utensils',
            reduceMinutes = 1,
            duration = 15000, -- 15 saniye
            categoryCooldown = 120, -- 5 nokta bittiğinde 2 dakika cooldown
            anim = {
                dict = 'anim@amb@business@coc@coc_unpack_cut@',
                clip = 'coke_cut_v1_coccutter',
                flag = 49
            },
            prop = {
                model = 'prop_knife',
                bone = 28422,
                pos = vec3(0.0, 0.0, 0.0),
                rot = vec3(0.0, 0.0, 0.0)
            },
            locations = {
                { id = 'kitchen_1', coords = vec3(1778.31, 2560.56, 45.62), heading = 181.13 },
                { id = 'kitchen_2', coords = vec3(1781.12, 2560.56, 45.62), heading = 181.13 },
                { id = 'kitchen_3', coords = vec3(1779.65, 2564.71, 45.62), heading = 0.0 },
                { id = 'kitchen_4', coords = vec3(1777.5304, 2563.8987, 45.6731), heading = 88.1067 },
                { id = 'kitchen_5', coords = vec3(1784.05, 2564.71, 45.62), heading = 0.0 },
            }
        }
    }
}
