-- Settings the config files leave out get their defaults here, so an older config keeps working after an update.
local DEFAULTS = {
    Bridge = { Framework = 'auto', Fuel = 'auto', Keys = 'auto', Notify = 'page', Interact = 'prompt', Mileage = 'auto', Society = 'auto', Business = 'auto', Phone = 'auto' },
    Interact = { Key = 38, Ped = 's_m_y_valet_01' },
    Blips = { Show = true, ShortRange = true },
    Markers = { Show = true, Distance = 25.0 },
    Vehicles = { WarpIn = true, SaveDamage = true, CheckModel = true, LabelOverrides = {} },
    Fees = { Return = 250, ReturnSociety = false, Transfer = { Base = 100, PerKm = 10, Max = 1000 }, Account = 'bank' },
    Infinite = { Public = false, Job = false, Gang = false },
    Impound = { Command = 'iv', Jobs = { 'police' }, Hours = { 0, 1, 4, 12, 24, 72, 168 }, Fee = 1500, MaxFee = 50000, Society = 'police' },
    Transfer = { Offers = true, HideNames = false, MaxPrice = 10000000, Seconds = 60, Blacklist = {} },
    Keys = { MaxDays = 30, MaxHolders = 5 },
    Business = { Enabled = true, DefaultFee = 100, MinFee = 0, MaxFee = 1000 },
    Private = { Command = 'privategarages', Jobs = { 'realestate' } },
    Showroom = { Mode = 'spot', DepthOfField = true },
    Interior = {
        Enabled = true,
        Kinds = { public = true, private = true, job = true, gang = true },
        Entrance = vector4(227.96, -1003.06, -99.0, 0.0),
        Camera = { vector4(227.96, -977.81, -98.99, 0.0), vector4(227.96, -1006.96, -98.99, 0.0) },
        Slots = {
            vector4(233.0, -984.0, -99.41, 118.0),
            vector4(233.0, -988.5, -99.41, 118.0),
            vector4(233.0, -993.0, -99.41, 118.0),
            vector4(233.0, -997.5, -99.41, 118.0),
            vector4(233.0, -1002.0, -99.41, 118.0),
            vector4(223.6, -979.0, -99.41, 235.2),
            vector4(223.6, -983.6, -99.41, 235.2),
            vector4(223.6, -988.2, -99.41, 235.2),
            vector4(223.6, -992.8, -99.41, 235.2),
            vector4(223.6, -997.4, -99.41, 235.2),
            vector4(223.6, -1002.0, -99.41, 235.2),
        },
        Bucket = 50000,
    },
    Service = { EveryKm = 5000 },
    Images = { Fallback = 'https://docs.fivem.net/vehicles/%s.webp' },
    Class = { Caps = { speed = 50.0, accel = 0.42, braking = 1.6, handling = 3.2 } },
    Commands = {
        ChangePlate = 'vplate', DeleteVehicle = 'dvdb', ReturnVehicle = 'vreturn', SetJobVehicle = 'setjobvehicle',
        RemoveJobVehicle = 'removejobvehicle', SetGangVehicle = 'setgangvehicle', RemoveGangVehicle = 'removegangvehicle',
    },
    Photo = { Looks = {
        none = false,
        cinema = { 'cinema', 0.7 },
        film = { 'NG_filmic01', 0.8 },
        soft = { 'BloomLight', 0.8 },
        cold = { 'hud_def_desat_cold', 0.6 },
        warm = { 'sunglasses', 0.5 },
        noir = { 'NG_filmnoir_BW01', 1.0 },
    } },
    Theme = { Accent = '#ff1f6d' },
    GarageLocations = {}, JobGarageLocations = {}, GangGarageLocations = {}, ImpoundLocations = {},
    DefaultGarages = {},
}

local function fill(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then
            target[key] = value
        elseif type(value) == 'table' and type(target[key]) == 'table' and #value == 0 then
            fill(target[key], value)
        end
    end
end

Config = Config or {}
fill(Config, DEFAULTS)
