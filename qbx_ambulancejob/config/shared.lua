return {
    checkInCost = 100,
    checkInSocietyDeposit = 50, -- EMS kasasına yatan pay (Fiyatın %50'si)
    minForCheckIn = 8,

    locations = {
        duty = {},
        vehicle = {},
        helicopter = {},
        armory = {},
        roof = {},
        main = {},
        stash = {},

        hospitals = {
            stfiacre = { -- St. Fiacre (artex_hospital)
                coords = vec3(1143.57, -1540.85, 35.03),
                checkIn = vec4(1133.3019, -1557.6188, 35.0329, 0.0560),
                beds = {
                    { coords = vec4(1124.87, -1563.31, 35.96, 0.3),    model = 2117668672 },
                    { coords = vec4(1121.43, -1563.23, 35.96, 8.24),   model = 2117668672 },
                    { coords = vec4(1117.99, -1563.07, 35.96, 14.55),  model = 2117668672 },
                    { coords = vec4(1117.82, -1554.44, 35.96, 180.89), model = 2117668672 },
                    { coords = vec4(1121.19, -1554.42, 35.96, 177.31), model = 2117668672 },
                    { coords = vec4(1124.8, -1554.26, 35.96, 173.99),  model = 2117668672 },
                },
            },
            -- Orta kasaba hastanesi kapatıldı, yerine St. Fiacre (artex_hospital) kullanılıyor
            -- ortakasaba = {
            --     coords = vec3(609.1779, 2778.8967, 43.5550),
            --     checkIn = {
            --         {
            --             coords = vec4(625.8079, 2776.3555, 43.5551, 359.7969),
            --             allowedBeds = { 1, 2, 3, 4, 5 }
            --         },
            --         {
            --             coords = vec4(632.6657, 2776.5952, 52.2715, 4.4516),
            --             allowedBeds = { 6, 7, 8, 9 }
            --         }
            --     },
            --     beds = {
            --         { coords = vector4(631.1890, 2769.0591, 43.5550, 4.0900), model = -7035577 },
            --         { coords = vector4(627.7253, 2768.8049, 43.5550, 4.0900), model = -7035577 },
            --         { coords = vector4(624.2957, 2768.5581, 43.5550, 4.0900), model = -7035577 },
            --         { coords = vector4(620.8105, 2768.3069, 43.5509, 4.0900), model = -7035577 },
            --         { coords = vector4(617.3769, 2768.0610, 43.5509, 4.0900), model = -7035577 },
            --         { coords = vector4(632.2802, 2772.8479, 53.1637, 182.2387), model = -7035577 },
            --         { coords = vector4(628.0366, 2772.9199, 53.1637, 188.4130), model = -7035577 },
            --         { coords = vector4(623.7485, 2772.7415, 53.1638, 182.6061), model = -7035577 },
            --         { coords = vector4(619.9117, 2772.3696, 53.1638, 185.7030), model = -7035577 },
            --     },
            -- },
            ada = {
                coords = vec3(5342.3380, -5251.5500, 32.9630),
                maxDistance = 450.0, -- Kolej kampüsü kapsama alanı, Cayo (dışındakiler St. Fiacre'ye gider)
                beds = {
                    { coords = vector4(5342.3380, -5251.5500, 32.9630, 58.2353), model = -7035577 },
                },
            }
            -- jail = {
            --     coords = vec3(1761, 2600, 46),
            --     beds = {
            --         { coords = vec4(1761.96, 2597.74, 45.66, 270.14), model = 2117668672 },
            --         { coords = vec4(1761.96, 2591.51, 45.66, 269.8),  model = 2117668672 },
            --         { coords = vec4(1771.8, 2598.02, 45.66, 89.05),   model = 2117668672 },
            --         { coords = vec4(1771.85, 2591.85, 45.66, 91.51),  model = 2117668672 },
            --     },
            -- },
        },

        stations = {
            { label = 'St. Fiacre Hastanesi', coords = vec4(1143.57, -1540.85, 35.03, 272.249) },
            -- { label = 'Sandy Shores Sağlık Merkezi', coords = vec4(610.6539, 2760.9639, 43.5547, 184.0413) },
        }
    },

    -- health: İyileştirme miktarı
    -- bleedChance: Kanama durma şansı (%)
    -- injuryChance: Küçük yaraların iyileşme şansı (%)
    -- duration: Kullanım süresi (ms)
    medicalItems = {
        bandage = {
            label = 'Bandaj',
            event = 'hospital:client:UseBandage',
            health = 25,
            bleedChance = 40,
            injuryChance = 10,
            duration = 4000
        },
        yanik_kremi = {
            label = 'Yanık Kremi',
            event = 'hospital:client:UseBandage',
            health = 10,
            bleedChance = 10,
            injuryChance = 50,
            duration = 3000
        },
        agri_kesici = {
            label = 'Ağrı Kesici',
            event = 'hospital:client:UseBandage',
            health = 5,
            bleedChance = 0,
            injuryChance = 0,
            duration = 2000
        },
        kanama_durdurucu = {
            label = 'Kanama Durdurucu',
            event = 'hospital:client:UseBandage',
            health = 5,
            bleedChance = 90,
            injuryChance = 5,
            duration = 5000
        },
        adrenalin = {
            label = 'Adrenalin',
            event = 'hospital:client:UseBandage',
            health = 40,
            bleedChance = 20,
            injuryChance = 5,
            duration = 6000
        },
        antiseptik = {
            label = 'Antiseptik',
            event = 'hospital:client:UseBandage',
            health = 5,
            bleedChance = 15,
            injuryChance = 25,
            duration = 3000
        },
        medikit = {
            label = 'Medikit',
            event = 'hospital:client:UseBandage',
            health = 100,
            bleedChance = 0,
            injuryChance = 0,
            duration = 6000
        },
        pd_medikit = {
            label = 'Medikit',
            event = 'hospital:client:UseBandage',
            health = 100,
            bleedChance = 0,
            injuryChance = 0,
            duration = 6000
        },
    }
}
