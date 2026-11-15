-- Automatic alerts: the game tells a player's own client what they did, the client raises the alert.
Config.Detect = {
    Witnesses = true, -- an alert needs a ped that saw it (false: every shot, fight ... is reported)
    Jobs = { 'leo', 'ems' }, -- groups or jobs that never raise automatic alerts (on duty or not)

    Shooting = { Enabled = true, Cooldown = 30 }, -- on foot; seconds before the same player raises it again
    VehicleShooting = { Enabled = true, Cooldown = 30 },
    Speeding = { Enabled = true, Kmh = 180, Cooldown = 60 }, -- the driver above this speed, seen by someone
    VehicleTheft = { Enabled = true, Cooldown = 60 }, -- car alarms and jacking
    Fight = { Enabled = false, Cooldown = 60 },
    Explosion = { Enabled = false, Cooldown = 60 },
    Reckless = { Enabled = true, Cooldown = 60 }, -- the game's own mad-driver and pavement-driving events
    -- Drivers (not of the jobs above) of these classes or models: a call that follows them for Seconds.
    VehicleClass = { Enabled = false, Classes = { 18 }, Models = {}, Seconds = 60, Cooldown = 120 },
    Delay = 5, -- seconds before an automatic alert reaches the units
    Minigames = true, -- nothing while in a paintball match (bridge/minigames.lua)

    -- Weapons that never raise a shooting alert (silenced weapons never do).
    IgnoreWeapons = {
        'WEAPON_STUNGUN', 'WEAPON_STUNGUN_MP', 'WEAPON_PETROLCAN', 'WEAPON_FIREEXTINGUISHER', 'WEAPON_SNOWBALL',
        'WEAPON_BALL', 'WEAPON_FLARE', 'WEAPON_FLAREGUN', 'WEAPON_HAZARDCAN', 'WEAPON_RAYPISTOL', 'WEAPON_RAYCARBINE',
        'WEAPON_GRENADE', 'WEAPON_BZGAS', 'WEAPON_SMOKEGRENADE', 'WEAPON_MOLOTOV', 'WEAPON_STICKYBOMB', 'WEAPON_PIPEBOMB',
        'WEAPON_PROXMINE',
    },

    -- Places where shots are not reported (ranges, hunting).
    QuietZones = {
        { coords = vector3(13.9, -1097.1, 29.8), radius = 25.0 }, -- Ammu-Nation range, Adam's Apple Blvd
        { coords = vector3(821.6, -2163.6, 29.6), radius = 25.0 }, -- Ammu-Nation range, Cypress Flats
        { coords = vector3(-774.0, 5595.0, 33.6), radius = 300.0 }, -- hunting grounds
    },

    -- Vehicle classes that never raise speeding (15 helicopters, 16 planes, 18 emergency).
    SpeedExempt = { 15, 16, 18 },
}

-- Server settings (servers/daddyrp/daddy_dispatch/config/cfg_detect.lua)
-- DaddyRP, as its tgiann-policealert had it: no shot alerts from these jobs, these weapons, or more often than every 90 s.
Config.Detect.Jobs = { 'leo', 'ems', 'doj' }
Config.Detect.Shooting.Cooldown = 90
Config.Detect.VehicleShooting.Cooldown = 90
for _, w in ipairs({ 'WEAPON_UNARMED', 'WEAPON_TASERGUN', 'WEAPON_SNIPERRIFLE', 'WEAPON_WATERGUN', 'WEAPON_PAINTBALL', 'WEAPON_MUSKET', 'WEAPON_TOMATO', 'WEAPON_MX18_CLASSYBLUE' }) do
    Config.Detect.IgnoreWeapons[#Config.Detect.IgnoreWeapons + 1] = w
end
-- DaddyRP: no reckless driving alerts (the game's mad-driver and pavement-driving events).
Config.Detect.Reckless.Enabled = false
-- DaddyRP: no speeding alerts either.
Config.Detect.Speeding.Enabled = false
