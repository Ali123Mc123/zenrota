Config = {}

Config.Locale = 'en' -- en | tr (locales/)
Config.Debug = false -- prints and the /garagestats command

Config.Theme = {
    Accent = '#ff1f6d', -- the chosen card, the tab line and the main button
}

-- Which scripts the bridge talks to; 'auto' finds the one that runs (bridge/*.lua lists them).
Config.Bridge = {
    Framework = 'auto', -- qbx | qb | esx
    Fuel = 'auto', -- LegacyFuel, ps-fuel, lj-fuel, cdn-fuel, savana-fuel, okokGasStation, ox_fuel ... | none
    Keys = 'auto', -- qb-vehiclekeys style, qbx_vehiclekeys, MrNewbVehicleKeys, wasabi_carlock, qs-vehiclekeys ... | none
    Notify = 'page', -- page (the garage's own notices) | ox_lib | qb | esx
    Interact = 'prompt', -- prompt (E with the garage's own hint) | ox_target | qb-target | textui (ox_lib)
    Mileage = 'auto', -- jg-vehiclemileage | column (the framework's own) | none
    Society = 'auto', -- can9work-funds, Renewed-Banking, okokBanking, fd_banking, qb-banking, qb-management, esx_addonaccount
    Business = 'auto', -- own | can9work-auction
    Phone = 'auto', -- cylex_phone (photos to its gallery); others get the event daddy_garages:photo
}

Config.Interact = {
    Key = 38, -- E; https://docs.fivem.net/docs/game-references/controls/
    Ped = 's_m_y_valet_01', -- the valet the target options sit on (target only)
}

Config.Blips = {
    Show = true,
    ShortRange = true,
    public = { sprite = 357, colour = 0, scale = 0.6 },
    private = { sprite = 357, colour = 0, scale = 0.55 },
    job = { sprite = 357, colour = 3, scale = 0.55 },
    gang = { sprite = 357, colour = 1, scale = 0.55 },
    impound = { sprite = 68, colour = 1, scale = 0.6 },
}

Config.Markers = {
    Show = true, -- a soft ring where the garage is
    Distance = 25.0,
    Height = 5.0, -- not drawn for a garage this far above or below (an underground one seen from the street)
}

-- A garage's reach: a box 'distance' wide (cfg_garages) and this tall.
Config.Zone = {
    Height = 4.0,
    Scale = 0.6, -- DaddyRP: every garage's 'distance' is multiplied by this (10 m -> 6 m box); 1.0 = as in cfg_garages
}

-- Taking a car out and putting it back.
Config.Vehicles = {
    WarpIn = true, -- the player sits in the car as it comes out
    SaveDamage = true, -- engine, body, dents, doors, windows and tyres are kept while parked
    CheckModel = true, -- the stored model must match the car being parked (stops swaps)
    LabelOverrides = {}, -- ['model'] = 'Pretty name' for add-on cars without a label
    Foreign = {}, -- garage names other scripts keep their own cars under (jim-jobgarage's 'jobgarage'): never listed or parked here
}

Config.Fees = {
    Return = 250, -- bringing back a car left outside or lost after a restart (0 = free)
    ReturnSociety = false, -- a job name whose society gets the return fees
    Transfer = { Base = 100, PerKm = 10, Max = 1000 }, -- moving a car to another garage, by distance
    Account = 'bank', -- bank | cash
}

-- The impound: officers impound a car next to them, owners pay at a lot once the hold time is over.
Config.Impound = {
    -- DaddyRP: off. No /iv and no impound lot; a car impounded by any script (daddy-admin, qbx) counts as left out and
    -- comes back from any garage for Config.Fees.Return, as under jg-advancedgarages. Its impound marks go as it does.
    Enabled = false,
    Command = 'iv', -- /iv next to a car
    Jobs = { 'police' }, -- who may impound, and release cars at a lot
    Hours = { 0, 1, 4, 12, 24, 72, 168 }, -- the hold times an officer picks from
    Fee = 1500, -- the fee the slip starts with
    MaxFee = 50000,
    Society = 'police', -- whose account the fees go to (false = nobody)
}

-- Cars changing hands between players.
Config.Transfer = {
    Offers = true, -- an offer with a price both accept (false = an instant, free hand-over like jg)
    HideNames = false, -- nearby players show as Stranger #id
    MaxPrice = 10000000,
    Seconds = 60, -- how long an offer waits for an answer
    Blacklist = {}, -- models that never change hands
}

-- Garages as businesses: an owner sets the take-out fee, the fees fill a till (bridge/business.lua: own or can9work).
Config.Business = {
    Enabled = true,
    DefaultFee = 100, -- the fee until the owner sets one
    MinFee = 0,
    MaxFee = 1000,
}

-- Private garages: /privategarages <player id> <name> where you stand.
Config.Private = {
    Command = 'privategarages',
    Jobs = { 'realestate' }, -- who may make them (staff always can)
}

-- Shared keys: another player may take the car out without owning it.
Config.Keys = {
    Enabled = false, -- DaddyRP: off. false hides the tab, refuses new keys and ignores the keys already given
    MaxDays = 30, -- the longest a timed key lasts (permanent keys are always allowed)
    MaxHolders = 5,
}

-- Cars that were taken out may be taken out again while the first copy still exists only with these on.
Config.Infinite = {
    Public = false,
    Job = false,
    Gang = false,
}

-- The cinematic showroom. spot: the car stands at the garage's show point (or its exit); studio: one room for all.
Config.Showroom = {
    Mode = 'spot',
    Studio = nil, -- vector4 of the room's stand when Mode = 'studio'
    Idle = 'calm', -- left alone: 'calm' (a slow, barely seen sway), 'orbit' (a slow walk round) or 'off' (still); each player can change it
    DepthOfField = true,
}

-- Walking among your cars (the column's door button): GTA's ten-car garage, a copy of its own for each player.
Config.Interior = {
    Enabled = true,
    Kinds = { public = true, private = true, job = true, gang = true }, -- which car garages have it
    Entrance = vector4(227.96, -1003.06, -99.0, 0.0), -- where you stand inside, by the door (E there walks out)
    Camera = { vector4(227.96, -977.81, -98.99, 0.0), vector4(227.96, -1006.96, -98.99, 0.0) }, -- the glide as you walk in
    Slots = { -- where the cars stand: favourites and the latest driven first
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
    Bucket = 50000, -- private routing buckets are this plus the player's id
}

-- Mileage: a service is due every EveryKm.
Config.Service = {
    EveryKm = 5000,
}

-- Card pictures: images/<model>.webp in this resource, else this address (%s = model), else a drawn outline.
Config.Images = {
    Fallback = 'https://docs.fivem.net/vehicles/%s.webp',
}

-- Performance bars (0-10) from the game's own numbers; a car at Caps fills a bar. See /garagestats with Debug on.
Config.Class = {
    Caps = { speed = 50.0, accel = 0.42, braking = 1.6, handling = 3.2 },
}

Config.Commands = {
    ChangePlate = 'vplate', -- admin: /vplate <new plate> in a car
    DeleteVehicle = 'dvdb', -- admin: removes the car you sit in from the database
    ReturnVehicle = 'vreturn', -- admin: /vreturn <plate> sends a car back to its garage
    SetJobVehicle = 'setjobvehicle', -- admin: /setjobvehicle <job> <grade> makes the car you sit in the job's
    RemoveJobVehicle = 'removejobvehicle', -- admin: /removejobvehicle <player id> gives it to a player
    SetGangVehicle = 'setgangvehicle',
    RemoveGangVehicle = 'removegangvehicle',
}

-- Server settings (servers/daddyrp/daddy_garages/config/cfg_main.lua)
-- DaddyRP: Turkish, returning a car left out is free (as under jg). A car parked in a garage comes out free unless the
-- garage's auction owner set a price themselves (no default fee; Business.Enabled = false makes every take-out free).
Config.Locale = 'tr'
Config.Fees.Return = 0
-- jim-jobgarage writes every job car as the player's own under 'jobgarage': those stay out of these garages.
Config.Vehicles.Foreign = { 'jobgarage' }
-- Job types (qbx_core jobs.lua 'type') whose jim-jobgarage cars may also be parked in public garages.
Config.Vehicles.ForeignJobTypes = { 'leo', 'ems' }
Config.Business.Enabled = true
Config.Business.DefaultFee = 0
Config.Business.MinFee = 0
Config.Business.MaxFee = 250
