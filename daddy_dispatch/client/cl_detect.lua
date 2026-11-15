-- Automatic alerts, raised on the client of the player who did it: shots (on foot, from a car), speeding, car theft,
-- fights, explosions. Players of Config.Detect.Jobs never raise them; each kind waits its cooldown; with
-- Config.Detect.Witnesses someone has to have seen it.
local D = Config.Detect
local last = {}

local IGNORED = {}
for _, w in ipairs(D.IgnoreWeapons) do IGNORED[joaat(w)] = true end

local SPEED_EXEMPT = {}
for _, class in ipairs(D.SpeedExempt) do SPEED_EXEMPT[class] = true end

-- The cooldown of a kind has passed (and starts again).
local function ready(kind)
    local cfg = D[kind]
    if not cfg or not cfg.Enabled then return false end
    local now = GetGameTimer()
    if last[kind] and now - last[kind] < cfg.Cooldown * 1000 then return false end
    last[kind] = now
    return true
end

-- Nobody saw it: try again in 3 s, not at once (a burst of shots would look round every frame).
local function retry(kind)
    last[kind] = GetGameTimer() - math.max(0, D[kind].Cooldown - 3) * 1000
end

-- A dispatch job or a minigame: read at most once a second (a burst of shots never asks the framework each time).
local exemptAt, exemptWas = -1000, false

local function exempt()
    local now = GetGameTimer()
    if now - exemptAt < 1000 then return exemptWas end
    local job = Bridge.fw.job()
    exemptAt = now
    exemptWas = (job ~= nil and Core.inList(job.name, D.Jobs)) or (D.Minigames and Bridge.inMinigame()) or false
    return exemptWas
end

-- An automatic alert: reaches the units after Config.Detect.Delay seconds.
local function raise(typeName, extra)
    extra = extra or {}
    extra.auto = true
    Context.raise(typeName, extra)
end

local function quietZone(p)
    for _, z in ipairs(D.QuietZones) do
        if #(p - z.coords) < z.radius then return true end
    end
    return false
end

-- Someone (not a player) saw it: a ped the game lists as a witness, or one close by with a clear line to the player.
local function seen(witnesses, me, range)
    if not D.Witnesses then return true end
    for _, w in ipairs(type(witnesses) == 'table' and witnesses or {}) do
        if w ~= me and DoesEntityExist(w) and IsEntityAPed(w) and not IsPedAPlayer(w) and not IsPedDeadOrDying(w, true) then return true end
    end
    local p = GetEntityCoords(me)
    local rays = 0
    for _, ped in ipairs(GetGamePool('CPed')) do
        if ped ~= me and #(GetEntityCoords(ped) - p) < range and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped, true) then
            if HasEntityClearLosToEntity(ped, me, 17) then return true end
            rays = rays + 1
            if rays >= 8 then break end
        end
    end
    return false
end

-- The game's CEvent events (CEventGunShot, CEventExplosionHeard, the shocking events) fire once for every ped that
-- perceives them, and each one is handed to Lua with its witness list: in a firefight that is dozens of peds times every
-- shot, all but one of them returning at once, and it showed in resmon whenever a player was hit. The player's own
-- actions are read here instead: a firearm in hand is watched each frame for a shot (two natives), everything else every
-- half second; kinds that are off cost nothing. Only reckless driving, which has no native, still listens to the game,
-- and only while this player drives (see the vehicle thread below).
local function on(kind) return D[kind] and D[kind].Enabled end

-- A shot by this player: not silenced, not an ignored weapon, not in a quiet zone.
local function shot(me)
    Sound.shot()
    if not (on('Shooting') or on('VehicleShooting')) then return end
    if exempt() or IsPedCurrentWeaponSilenced(me) or IGNORED[GetSelectedPedWeapon(me)] or quietZone(GetEntityCoords(me)) then return end
    local fromCar = IsPedInAnyVehicle(me, false)
    local kind = fromCar and 'VehicleShooting' or 'Shooting'
    if not ready(kind) then return end
    if not seen(nil, me, 60.0) then return retry(kind) end
    raise(fromCar and 'vehicle_shooting' or 'shooting')
end

-- Shots: a firearm in hand is watched every frame (IsPedShooting is true on the frame a round leaves); otherwise a look
-- twice a second. Sound.shot (quieter alerts while one shoots) needs it even for the dispatch jobs.
CreateThread(function()
    while true do
        local me = PlayerPedId()
        if IsPedArmed(me, 4) then
            if IsPedShooting(me) then shot(me) end
            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- Fights, car theft and explosions, twice a second and only for the kinds that are on.
CreateThread(function()
    local wasJacking, alarmed = false, 0
    while true do
        Wait(500)
        local me = PlayerPedId()
        -- a punch or a swing this player throws, someone close by seeing it
        if on('Fight') and IsPedPerformingMeleeAction(me) and not exempt() and ready('Fight') then
            if not seen(nil, me, 30.0) then retry('Fight') else raise('fight') end
        end
        if on('VehicleTheft') then
            -- jacking a driver out, or an alarm going off on the car this player is getting into (once per car)
            local jacking = IsPedJacking(me)
            local veh = GetVehiclePedIsTryingToEnter(me)
            if veh == 0 then veh = GetVehiclePedIsIn(me, false) end
            local alarm = veh ~= 0 and IsVehicleAlarmActivated(veh) and veh ~= alarmed
            if ((jacking and not wasJacking) or alarm) and not exempt() and ready('VehicleTheft') then raise('vehicle_theft') end
            if alarm then alarmed = veh end
            wasJacking = jacking
        end
        -- an explosion within earshot
        if on('Explosion') then
            local p = GetEntityCoords(me)
            if IsExplosionInSphere(-1, p.x, p.y, p.z, 60.0) and not exempt() and ready('Explosion') then raise('explosion') end
        end
    end
end)

-- Reckless driving the game itself notices: driving on the pavement, a mad driver, a chase. These listeners are added
-- while this player drives and removed when they stop (setReckless from the vehicle thread).
local RECKLESS_EVENTS = { 'CEventShockingMadDriverExtreme', 'CEventShockingDrivingOnPavement', 'CEventShockingCarChase', 'CEventShockingMadDriver' }
local recklessHandlers

local function reckless(witnesses, ped)
    local me = PlayerPedId()
    if ped ~= me then return end
    local veh = GetVehiclePedIsIn(me, false)
    if veh == 0 or GetPedInVehicleSeat(veh, -1) ~= me or SPEED_EXEMPT[GetVehicleClass(veh)] then return end
    if exempt() or not ready('Reckless') then return end
    if not seen(witnesses, me, 60.0) then return retry('Reckless') end
    raise('reckless_driving')
end

local function setReckless(driving)
    if driving and not recklessHandlers and on('Reckless') then
        recklessHandlers = {}
        for i, name in ipairs(RECKLESS_EVENTS) do recklessHandlers[i] = AddEventHandler(name, reckless) end
    elseif not driving and recklessHandlers then
        for _, h in ipairs(recklessHandlers) do RemoveEventHandler(h) end
        recklessHandlers = nil
    end
end

CreateThread(function()
    while true do
        Wait(1000)
        local me = PlayerPedId()
        local veh = GetVehiclePedIsIn(me, false)
        setReckless(veh ~= 0 and GetPedInVehicleSeat(veh, -1) == me)
    end
end)

-- A driver of an emergency class or model who is not of the dispatch jobs: one call that follows them.
CreateThread(function()
    local VC = D.VehicleClass
    if not VC.Enabled then return end
    local CLASSES, MODELS = {}, {}
    for _, c in ipairs(VC.Classes) do CLASSES[c] = true end
    for _, m in ipairs(VC.Models) do MODELS[joaat(m)] = true end
    local last = 0
    while true do
        Wait(1000)
        local me = PlayerPedId()
        local veh = GetVehiclePedIsIn(me, false)
        if veh ~= 0 and veh ~= last and GetPedInVehicleSeat(veh, -1) == me then
            last = veh
            if (CLASSES[GetVehicleClass(veh)] or MODELS[GetEntityModel(veh)]) and not exempt() and ready('VehicleClass') then
                Context.raise('emergency_vehicle_theft')
            end
        elseif veh == 0 then
            last = 0
        end
    end
end)

-- Speeding: the driver above Config.Detect.Speeding.Kmh, seen from the road.
CreateThread(function()
    while true do
        Wait(2000)
        local me = PlayerPedId()
        local veh = GetVehiclePedIsIn(me, false)
        if D.Speeding.Enabled and veh ~= 0 and GetPedInVehicleSeat(veh, -1) == me and not SPEED_EXEMPT[GetVehicleClass(veh)] then
            local kmh = GetEntitySpeed(veh) * 3.6
            if kmh >= D.Speeding.Kmh and not exempt() and ready('Speeding') then
                if seen(nil, me, 80.0) then
                    raise('reckless_driving', { fields = { { icon = 'gauge', text = Core.t('context.speed', math.floor(kmh)) } } })
                else
                    retry('Speeding')
                end
            end
        end
    end
end)
