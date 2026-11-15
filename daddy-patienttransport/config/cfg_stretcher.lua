Config = Config or {}

Config.Stretcher = {
    serverVehicleType = 'automobile',           -- server spawn type, keep 'automobile'
    model = 'dd_stretcher',                     -- color spawned from the item, one of the models below
    models = { 'dd_stretcher', 'dd_stretcher_black', 'dd_stretcher_burgundy', 'dd_stretcher_green', 'dd_stretcher_grey' },
    pickupDistance = 2.5,                       -- distance to take the stretcher (m)
    interactDistance = 3.0,                     -- target distance on the stretcher (m)
    patientDetachDistance = 2.4,                -- how far from the stretcher a patient is put down (m)
    dropKeybind = 'G',                          -- key to drop the stretcher while carrying
    maxExtraId = 12,                            -- highest model extra turned off on spawn
    mechanism = {
        model = 'dd_stretcher_legs',
        dictionary = 'dd_stretcher_mech',
        clip = 'deploy',                        -- phase 0 = folded, phase 1 = open
        durationMs = 1200,
        loadTimeoutMs = 5000,
    },
    seatExtra = { folded = 11, flat = 12 },     -- seat extras (folded / flat)
    headExtra = 11,                             -- head rest extra; sitting poses use extra 12

    enableVehiclePickup = false,                -- target to take a stretcher out of any listed ambulance
    enableDeliverTarget = false,                -- "Deliver Patient" target; off = load the stretcher with [E] at the rear doors
    enableItem = true,                          -- use the item to unfold a stretcher
    item = 'sedye',                         -- item name
    itemSpawnDistance = 1.5,                    -- how far in front the stretcher unfolds (m)
}

-- Ambulances the stretcher can be loaded into.
Config.Ambulance = {
    interactDistance = 7.0,                     -- target distance on the ambulance (m)
    rearInteractDistance = 2.0,                 -- distance from the rear doors for the [E] hint (m)
    patientSeat = 2,                            -- seat the patient is put in (2 = rear right)
    -- detection = distance to the rear doors | depth / height = stretcher position inside the vehicle
    vehicles = {
        { model = 'onx_ambkee',  detection = 5.0, depth = -1.8, height = -0.15 },
        { model = 'onx_ambjog3', detection = 5.0, depth = -1.3, height = -0.15 },
        { model = 'onx_ambjog',  detection = 5.0, depth = -1.3, height = -0.15 },
        { model = 'ambulance', detection = 5.0, depth = -1.3, height = -0.15 },
        -- { model = 'my_addon_ambulance', detection = 5.0, depth = -1.8, height = -0.15 },
    },
}

-- Where a downed patient lies. Medical scripts keep their own death animation running, so only
-- the attach offset is changed to fit that pose on a flat stretcher.
Config.DownedPosition = {
    x = 0.0, y = 0.3, z = 1.5, r = 180.0,
}

-- Patient poses on the stretcher. localeKey = label in locales/ | x, y, z = offset | r = rotation
Config.Positions = {
    {
        localeKey = 'pos_lay_back',
        anim = 'savecouch@',
        lib = 't_sleep_loop_couch',
        x = 0.0, y = 0.2, z = 1.1, r = 180.0,
    },
    {
        localeKey = 'pos_sit_right',
        anim = 'amb@prop_human_seat_chair_food@male@base',
        lib = 'base',
        x = 0.0, y = -0.2, z = 0.55, r = -90.0,
    },
    {
        localeKey = 'pos_sit_left',
        anim = 'amb@prop_human_seat_chair_food@male@base',
        lib = 'base',
        x = 0.0, y = -0.2, z = 0.55, r = 90.0,
    },
    {
        localeKey = 'pos_sit_up',
        anim = 'amb@world_human_stupor@male_looking_left@base',
        lib = 'base',
        x = 0.0, y = 0.3, z = 1.5, r = 180.0,
        openDoor = true,                        -- raises the back rest in this pose
    },
}
