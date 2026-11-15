Config.Spawn = {
    Mode = 'daddy',          -- daddy: this selector | framework: qbx_spawn, qb-spawn or qb-apartments
    Transition = 'live',     -- live | switch | crane | fade
    ArrivalLength = 'short', -- live spawn: off | walk | short | full
    LastLocation = true,
    OnlyLast = false,        -- true: the selector shows only the last location
    Homes = true,            -- owned properties and apartments
    Default = vec4(195.17, -933.77, 30.69, 144.0), -- when nothing else is allowed
    Points = {               -- rules: everyone, job:<name>[:<grade>], gang:<name>, ace:<perm>, discord:<roleId>
        { id = 'legion', label = 'Legion Square', coords = vec4(195.17, -933.77, 30.69, 144.0), rules = 'everyone' },
        { id = 'airport', label = 'Los Santos Havalimanı', coords = vec4(-1037.5, -2737.6, 20.17, 330.0), rules = 'everyone' },
        { id = 'sandy', label = 'Sandy Shores', coords = vec4(1850.9, 3690.2, 34.27, 210.0), rules = 'everyone' },
        { id = 'paleto', label = 'Paleto Bay', coords = vec4(-160.6, 6436.9, 31.92, 45.0), rules = 'everyone' },
        { id = 'lspd', label = 'Mission Row Karakolu', coords = vec4(428.2, -984.3, 30.71, 90.0), rules = 'job:police' },
        { id = 'pillbox', label = 'Pillbox Hastanesi', coords = vec4(298.2, -584.6, 43.26, 70.0), rules = 'job:ambulance' },
    },
}

Config.NewCharacter = {
    Cutscene = 'plane',  -- plane | bus | taxi | random | none
    ChooseSpawn = false, -- with 'none': the spawn selector instead of Point
    Point = vec4(-1037.5, -2737.6, 20.17, 330.0),
    StarterItems = true,
    StartingApartment = true, -- with qb-apartments or qbx_apartments running, a new character picks its first apartment
}

Config.Onboarding = { -- daddy_onboarding; sleeps while it does not run
    Enabled = true,
    Roles = true,     -- pick civilian / student / teacher on the casting form
    College = {
        Enabled = true, -- College spawn point for students and teachers
        Coords = vec4(-1636.2, 180.4, 61.8, 300.0),
        Jobs = { 'student', 'teacher' },
        NewArrive = true, -- new students and teachers arrive here
    },
}

Config.Relog = {
    Enabled = true,
    AdminOnly = false, -- true: only admins (ACE daddy.admin) may /relog
    Cooldown = 300, -- seconds
    BlockDead = true,
    BlockCuffed = true,
    BlockVehicle = true,
}

-- Server settings (servers/daddyrp/daddy_multichar/config/cfg_spawn.lua)
-- DaddyRP: the selector shows only the last location; only admins may /relog.
Config.Spawn.OnlyLast = true
Config.Relog.AdminOnly = true
-- DaddyRP's College spawn (the Cayo campus, before the school's main steps), and its school jobs arrive there.
Config.Onboarding.College.Coords = vec4(5318.6100, -5263.8940, 30.8680, 326.0)
Config.Onboarding.College.Jobs = { 'ogrenci', 'ogretmen' }
-- DaddyRP: no arrival animation on joining (smoking, a phone, photos cost the player time): a player who turns the
-- arrival on under the settings only walks the few steps into the point, whatever the job. Lists set here are not
-- filled from the defaults, so the empty ones stay empty.
Config.Spawn.Arrivals = { default = { 'walk' }, kinds = {}, jobs = {} }
-- DaddyRP: no arrival at all by default (no walk, no animation); players may still pick one under the settings.
Config.Spawn.ArrivalLength = 'off'
-- DaddyRP: new characters arrive at the Sandy Shores airfield instead of LSIA, with their own light-aircraft arrival
-- (Cutscenes.sandy in shared/sh_cutscenes.lua; 'none' plays the plain live spawn at Point instead).
Config.NewCharacter.Cutscene = 'sandy'
Config.NewCharacter.Point = vec4(1693.0242, 3300.9121, 41.5671, 105.7606)
