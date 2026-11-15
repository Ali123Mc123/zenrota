return {
    timeout = 10000,
    maxSpikes = 5,
    policePlatePrefix = 'LSPD',
    objects = {
        cone = { model = `prop_roadcone02a`, freeze = false },
        barrier = { model = `prop_barrier_work06a`, freeze = true },
        roadsign = { model = `prop_snow_sign_road_06g`, freeze = true },
        tent = { model = `prop_gazebo_03`, freeze = true },
        light = { model = `prop_worklight_03b`, freeze = true },
        chair = { model = `prop_chair_08`, freeze = true },
        chairs = { model = `prop_chair_pile_01`, freeze = true },
        tabe = { model = `prop_table_03`, freeze = true },
        monitor = { model = `des_tvsmash_root`, freeze = true },
    },

    locations = {
        duty = {},
        vehicle = {},
        stash = {},
        impound = {},
        helicopter = {},
        armory = {},
        trash = {},
        fingerprint = {},
        evidence = {},
        stations = {
            -- { color = 38, sprite = 60, label = 'Polis Departmanı',           coords = vec3(16.1647, -370.8582, 40.4295) }, -- Alta PD (eski)
            { color = 38, sprite = 60, label = 'Mission Row Police Department', coords = vec3(434.0, -983.0, 30.7) },
            { color = 40, sprite = 60, label = 'San Andreas State Police', coords = vec3(-3081.31, 1443.66, 20.85) },
            { color = 81, sprite = 60, label = 'Blaine County Sheriff Office', coords = vec3(1840.29, 3666.61, 33.86) },
            { color = 52, sprite = 60, label = 'San Andreas Park Rangers', coords = vec3(16.1647, -370.8582, 40.4295) },
            { color = 81, sprite = 60, label = 'Paleto Bay Sheriff Department', coords = vec3(-447.8401, 6034.3340, 31.3399) },
        },
    },

    radars = {
        -- /!\ The maxspeed(s) need to   be in an increasing order /!\
        -- If you don't want to fine people just do that: 'config.speedFines = false'
        -- fine if you're maxspeed or less over the speedlimit
        -- (i.e if you're at 41 mph and the radar's limit is 35 you're 6mph over so a 25$ fine)
        speedFines = {
            { fine = 25,  maxSpeed = 10 },
            { fine = 50,  maxSpeed = 30 },
            { fine = 250, maxSpeed = 80 },
            { fine = 500, maxSpeed = 180 },
        }
    }
}