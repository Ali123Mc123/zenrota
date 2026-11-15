return {
    disable = {
        -- Disables the Idle Cinematic Camera
        idleCamera = true,

        -- Disabled distance sirens, distance car alarms, etc
        ambience = true,

    },

    blacklisted = {
        scenarioTypes = {
            -- WORLD_VEHICLE_POLICE_BIKE, _CAR, _NEXT_TO_CAR, _MILITARY_PLANES_BIG/_SMALL
            -- can9_base/client.lua tarafından startup'ta bir kez set edildiğinden burada tekrarlanmıyor
            'WORLD_VEHICLE_AMBULANCE',
            'WORLD_VEHICLE_FIRE_TRUCK',
            'WORLD_VEHICLE_POLICE',
            'WORLD_VEHICLE_SECURITY_CAR',
            'WORLD_VEHICLE_HELI_LIFEGUARD',
        },

        suppressedModels = {
            'SHAMAL',
            'LUXOR',
            'LUXOR2',
            'JET',
            'LAZER',
            'TITAN',
            'CRUSADER',
            'RHINO',
            'AIRTUG',
            'RIPLEY',
            'BLIMP',
        },

        scenarioGroups = {
            'LSA_Planes',
            'SANDY_PLANES',
            'GRAPESEED_PLANES',
            `ng_planes`,
        },
    },
}
