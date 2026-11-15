Settings.EventBox = {
    ProgressBar = {
        duration = 3000,
        label = 'Etkinlik Kutusu Açılıyor...',
        anim = {
            dict = 'anim@amb@business@weed@weed_inspecting_lo_med_hi@',
            clip = 'weed_stand_check_low_alb',
        },
    },

    Zone = {
        -- coords = vec3(4754.0, -5138.0, 34.0), -- PUBG / CAYO
        coords = vec3(2647.6, 5046.15, 68.0), -- MADDE X
        -- coords = vec3(985.5, -3111.0, 20.0), -- LIMAN
        -- radius = 1500.0, -- PUBG / CAYO
        radius = 1911.95, -- MADDE X
        -- radius = 700.0, -- LIMAN
        debug = false                        -- Set to false to hide the sphere
    },

    Rewards = {
        { name = 'sandwich',                label = 'Sandviç',         min = 5,  max = 5,  chance = 100 },
        { name = 'water_bottle',            label = 'Su',              min = 5,  max = 5,  chance = 100 },
        { name = 'redbull',                 label = 'Enerji İçeceği',  min = 20, max = 20, chance = 100 },
        { name = 'armour',                  label = 'Zırh',            min = 20, max = 20, chance = 100 },
        { name = 'medikit',                 label = 'Medikit',         min = 20, max = 20, chance = 100 },
        { name = 'ammo-9',                  label = '9mm Şarjör',      min = 50, max = 50, chance = 100 },
        { name = 'WEAPON_MX18_CLASSYBLUE',  label = 'MX18 Classyblue', min = 1,  max = 1,  chance = 100 },
        { name = 'radio',                   label = 'Radyo',           min = 1,  max = 1,  chance = 100 },
    }
}
