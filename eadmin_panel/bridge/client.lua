--[[
    Framework Bridge - Client

    Client-side Bridge functions used by Quick Actions.
    Resource handler functions are resolved once at load time from the
    globals set by bridge/_resource.lua - zero per-call string matching.
]]

Bridge = Bridge or {}

local RESOURCE_NAME = Bridge.RESOURCE_NAME

-- =========================================================================
-- Pre-resolved Resource Handlers (resolved once at load time)
-- =========================================================================

--- @type fun(vehicle: number)|nil
local fuelImpl = FuelResource and ({
    ['savana-fuel']    = function(v) exports['savana-fuel']:SetFuel(v, 100.0) end,
    ['cdn-fuel']       = function(v) exports['cdn-fuel']:SetFuel(v, 100.0) end,
    ['LegacyFuel']     = function(v) exports['LegacyFuel']:SetFuel(v, 100.0) end,
    ['lj-fuel']        = function(v) exports['lj-fuel']:SetFuel(v, 100.0) end,
    ['ox_fuel']        = function(v) Entity(v).state.fuel = 100.0 end,
    ['ps-fuel']        = function(v) exports['ps-fuel']:SetFuel(v, 100.0) end,
    ['okokGasStation'] = function(v) exports['okokGasStation']:SetFuel(v, 100.0) end,
    ['x-fuel']         = function(v) exports['x-fuel']:SetFuel(v, 100.0) end,
    ['nd_fuel']        = function(v) exports['nd_fuel']:SetFuel(v, 100.0) end,
    ['lc_fuel']        = function(v) exports['lc_fuel']:SetFuel(v, 100.0) end,
    ['gacha_fuel']     = function(v) exports['gacha_fuel']:SetFuel(v, 100.0) end,
})[FuelResource]

--- @type fun()|nil
local clothingImpl = ClothingResource and ({
    ['illenium-appearance'] = function() TriggerEvent('illenium-appearance:client:openClothingShopMenu', true) end,
    ['qb-clothing']         = function() TriggerEvent('qb-clothing:client:openMenu') end,
    ['fivem-appearance']    = function() TriggerEvent('fivem-appearance:skinCommand') end,
    ['bl_appearance']       = function() exports['bl_appearance']:OpenMenu() end,
    ['ox_appearance']       = function() exports['ox_appearance']:OpenMenu() end,
    ['esx_skin']            = function() TriggerEvent('esx_skin:openMenu') end,
})[ClothingResource]

--- @type fun(): string|nil
local weatherZoneImpl = WeatherResource and ({
    ['av_weather'] = function()
        local ok, zone = pcall(exports.av_weather.getZone, exports.av_weather)
        return ok and type(zone) == 'table' and zone.zone or nil
    end,
})[WeatherResource]

-- =========================================================================
-- Bridge Functions
-- =========================================================================

--- Revive self (client-side animation / health restore).
--- The server handles framework metadata (isdead, inlaststand).
---@return boolean
function Bridge.reviveSelf()
    local ped = PlayerPedId()
    if not ped or ped == 0 then return false end

    local animDict = 'get_up@directional@transition@from_knees@action'
    RequestAnimDict(animDict)
    local timeout = GetGameTimer() + 2000
    while not HasAnimDictLoaded(animDict) and GetGameTimer() < timeout do
        Wait(10)
    end

    if HasAnimDictLoaded(animDict) then
        TaskPlayAnim(ped, animDict, 'getup_r_0', 8.0, -8.0, 1500, 0, 0, false, false, false)
        Wait(1500)
        RemoveAnimDict(animDict)
    end

    pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
    SetEntityHealth(ped, 200)
    ClearPedBloodDamage(ped)
    return true
end

--- Fill the current vehicle's fuel to 100%.
--- Uses the handler resolved once at load time from FuelResource.
---@param vehicle number  Vehicle entity handle
---@return boolean
function Bridge.fillFuel(vehicle)
    if not vehicle or vehicle == 0 then return false end

    if fuelImpl then
        pcall(fuelImpl, vehicle)
    else
        -- Fallback: use native fuel level (works without a fuel script)
        SetVehicleFuelLevel(vehicle, 100.0)
    end

    return true
end

--- Get the current weather zone name (av_weather only, nil for other resources).
---@return string|nil
function Bridge.getWeatherZone()
    return weatherZoneImpl and weatherZoneImpl() or nil
end

--- Open the clothing / appearance menu.
--- Uses the handler resolved once at load time from ClothingResource.
---@return boolean
function Bridge.openClothingMenu()
    if not clothingImpl then return false end
    pcall(clothingImpl)
    return true
end

-- =========================================================================
-- Server-Triggered Client Events
-- =========================================================================

--- Set health and/or armor on the local ped (triggered by server Bridge).
RegisterNetEvent(RESOURCE_NAME .. ':bridge:setVitals', function(health, armor)
    local ped = PlayerPedId()
    if not ped or ped == 0 then return end
    if health then pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]] SetEntityHealth(ped, health) end
    if armor then pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]] SetPedArmour(ped, armor) end
end)

--- Full revive: animation + health/armor restore (triggered by server Bridge).
RegisterNetEvent(RESOURCE_NAME .. ':bridge:revive', function()
    Bridge.reviveSelf()
end)

--- Uncuff via tk_policejob exports (triggered by server Bridge).
RegisterNetEvent(RESOURCE_NAME .. ':bridge:tkUncuff', function()
    if exports.tk_policejob:isHandcuffed() then
        exports.tk_policejob:unCuff()
    end
end)

-- =========================================================================
-- Vitals Reporter - event-driven metadata sync
--
-- Listens to framework events for metadata changes (hunger/thirst/stress/
-- death/jail) and reports them to the server. Zero polling - pure events.
--
-- Sources per framework:
--   QBX:  StateBag handlers (hunger, thirst, stress)
--         + hud:client:UpdateNeeds fallback
--         + death/jail polling (LocalPlayer.state.isDead/inLaststand)
--   QB:   hud:client:UpdateNeeds, stress StateBag, death/jail poll
--   ESX:  esx_status:onTick, IsEntityDead native (polled only for death)
-- =========================================================================

local serverId = GetPlayerServerId(PlayerId())

-- Current vitals state - updated by event handlers, reported on change
local vitals = {
    hunger = 100,
    thirst = 100,
    stress = 0,
    isdead = false,
    inlaststand = false,
    injail = 0,
}

local lastReported = {}

local function round(v)
    return math.floor((tonumber(v) or 0) + 0.5)
end

local function reportIfChanged()
    local h = round(vitals.hunger)
    local t = round(vitals.thirst)
    local s = round(vitals.stress)
    local d = vitals.isdead == true
    local ls = vitals.inlaststand == true
    local j = vitals.injail or 0

    if lastReported.isdead == d
        and lastReported.inlaststand == ls
        and lastReported.injail == j
        and lastReported.hunger and math.abs(lastReported.hunger - h) < 2
        and lastReported.thirst and math.abs(lastReported.thirst - t) < 2
        and lastReported.stress and math.abs(lastReported.stress - s) < 2
    then
        return
    end

    lastReported.hunger = h
    lastReported.thirst = t
    lastReported.stress = s
    lastReported.isdead = d
    lastReported.inlaststand = ls
    lastReported.injail = j

    TriggerServerEvent(Bridge.EVENT_PREFIX .. 'reportVitals', {
        hunger = h,
        thirst = t,
        stress = s,
        isdead = d,
        inlaststand = ls,
        injail = j,
    })
end

local function clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

local function initVitals()
    if Framework == 'qbx' then
        local pd = Bridge.getPlayerData()
        if pd then
            local md = pd.metadata or {}
            vitals.hunger = clamp(tonumber(md.hunger) or 100, 0, 100)
            vitals.thirst = clamp(tonumber(md.thirst) or 100, 0, 100)
            vitals.stress = clamp(tonumber(md.stress) or 0, 0, 100)
            vitals.isdead = md.isdead == true
            vitals.inlaststand = md.inlaststand == true
            vitals.injail = md.injail or 0
        end
        -- Also read StateBag values (they may be more current)
        local ps = LocalPlayer.state
        if ps.hunger ~= nil then vitals.hunger = clamp(ps.hunger, 0, 100) end
        if ps.thirst ~= nil then vitals.thirst = clamp(ps.thirst, 0, 100) end
        if ps.stress ~= nil then vitals.stress = clamp(ps.stress, 0, 100) end
        if ps.isDead ~= nil then vitals.isdead = ps.isDead == true end
        if ps.inLaststand ~= nil then vitals.inlaststand = ps.inLaststand == true end
    elseif Framework == 'qb' then
        local pd = Bridge.getPlayerData()
        if pd then
            local md = pd.metadata or {}
            vitals.hunger = clamp(tonumber(md.hunger) or 100, 0, 100)
            vitals.thirst = clamp(tonumber(md.thirst) or 100, 0, 100)
            vitals.stress = clamp(tonumber(md.stress) or 0, 0, 100)
            vitals.isdead = md.isdead == true
            vitals.inlaststand = md.inlaststand == true
            vitals.injail = md.injail or 0
        end
    elseif Framework == 'esx' then
        vitals.isdead = IsEntityDead(PlayerPedId())
    end

    reportIfChanged()
end

-- ── Common: stress StateBag (works across QBX, QB, and standalone) ──

if Framework == 'qbx' or Framework == 'qb' then
    AddStateBagChangeHandler('stress', ('player:%s'):format(serverId), function(_, _, value)
        vitals.stress = clamp(value or 0, 0, 100)
        reportIfChanged()
    end)
end

-- ── QBX (Qbox): StateBag handlers + death/jail polling ──

if Framework == 'qbx' then
    AddStateBagChangeHandler('hunger', ('player:%s'):format(serverId), function(_, _, value)
        vitals.hunger = clamp(value or 0, 0, 100)
        reportIfChanged()
    end)

    AddStateBagChangeHandler('thirst', ('player:%s'):format(serverId), function(_, _, value)
        vitals.thirst = clamp(value or 0, 0, 100)
        reportIfChanged()
    end)

    -- hud:client:UpdateNeeds as fallback (some servers still fire this)
    RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
        vitals.hunger = clamp(newHunger or 0, 0, 100)
        vitals.thirst = clamp(newThirst or 0, 0, 100)
        reportIfChanged()
    end)

    -- QBX has no StateBag for isDead/inLaststand - poll instead
    CreateThread(function()
        while not Bridge.getPlayerData() do Wait(500) end
        initVitals()
        while true do
            Wait(15000)
            local ps = LocalPlayer.state
            local pd = Bridge.getPlayerData()
            local md = pd and pd.metadata or {}
            vitals.isdead = ps.isDead == true or md.isdead == true
            vitals.inlaststand = ps.inLaststand == true or md.inlaststand == true
            vitals.injail = md.injail or 0
            reportIfChanged()
        end
    end)

-- ── QBCore: event + death/jail polling fallback ──

elseif Framework == 'qb' then
    RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
        vitals.hunger = clamp(newHunger or 0, 0, 100)
        vitals.thirst = clamp(newThirst or 0, 0, 100)
        reportIfChanged()
    end)

    CreateThread(function()
        while not Bridge.getPlayerData() do Wait(500) end
        initVitals()
        while true do
            Wait(15000)
            local pd = Bridge.getPlayerData()
            if pd and pd.metadata then
                local md = pd.metadata
                vitals.isdead = md.isdead == true
                vitals.inlaststand = md.inlaststand == true
                vitals.injail = md.injail or 0
                reportIfChanged()
            end
        end
    end)

-- ── ESX: esx_status:onTick + death polling ──

elseif Framework == 'esx' then
    RegisterNetEvent('esx_status:onTick', function(data)
        for i = 1, #data do
            if data[i].name == 'hunger' then
                vitals.hunger = clamp(math.floor(data[i].percent), 0, 100)
            elseif data[i].name == 'thirst' then
                vitals.thirst = clamp(math.floor(data[i].percent), 0, 100)
            end
        end
        reportIfChanged()
    end)

    CreateThread(function()
        while not PlayerPedId() or PlayerPedId() == 0 do Wait(500) end
        initVitals()
        while true do
            Wait(3500)
            local dead = IsEntityDead(PlayerPedId())
            if vitals.isdead ~= dead then
                vitals.isdead = dead
                reportIfChanged()
            end
        end
    end)

-- ── Standalone: death polling via FiveM natives ──

else
    CreateThread(function()
        while not PlayerPedId() or PlayerPedId() == 0 do Wait(500) end
        while true do
            Wait(3500)
            local ped = PlayerPedId()
            local dead = IsEntityDead(ped)
            if vitals.isdead ~= dead then
                vitals.isdead = dead
                reportIfChanged()
            end
        end
    end)
end

-- =========================================================================
-- Vehicle Reporter - event-driven vehicle state sync
--
-- Uses lib.onCache('vehicle') to detect enter/exit vehicle events.
-- Reports vehicle model, class, category, and plate to the server.
-- When value is nil (exited), reports nil so server clears vehicle state.
-- =========================================================================

local VEHICLE_CLASS_CATEGORY = {
    [0]  = 'car',        -- Compacts
    [1]  = 'car',        -- Sedans
    [2]  = 'car',        -- SUVs
    [3]  = 'car',        -- Coupes
    [4]  = 'car',        -- Muscle
    [5]  = 'car',        -- Sports Classics
    [6]  = 'car',        -- Sports
    [7]  = 'car',        -- Super
    [8]  = 'motorcycle', -- Motorcycles
    [9]  = 'car',        -- Off-road
    [10] = 'car',        -- Industrial
    [11] = 'car',        -- Utility
    [12] = 'car',        -- Vans
    [13] = 'bicycle',    -- Cycles
    [14] = 'boat',       -- Boats
    [15] = 'aircraft',   -- Helicopters
    [16] = 'aircraft',   -- Planes
    [17] = 'car',        -- Service
    [18] = 'car',        -- Emergency
    [19] = 'car',        -- Military
    [20] = 'car',        -- Commercial
    [21] = 'car',        -- Trains
    [22] = 'car',        -- Open Wheel
}

---@param vehicle number Vehicle entity handle
---@return table|nil
local function buildVehicleInfo(vehicle)
    if not vehicle or vehicle == 0 then return nil end

    local model = GetEntityModel(vehicle)
    local displayName = GetDisplayNameFromVehicleModel(model)
    local label = GetLabelText(displayName)
    if not label or label == 'NULL' then label = displayName end

    local class = GetVehicleClass(vehicle)

    return {
        model = label,
        class = class,
        category = VEHICLE_CLASS_CATEGORY[class] or 'car',
        plate = GetVehicleNumberPlateText(vehicle),
    }
end

local function reportVehicle(vehicleData)
    TriggerServerEvent(Bridge.EVENT_PREFIX .. 'reportVehicle', vehicleData)
end

lib.onCache('vehicle', function(vehicle)
    if vehicle and vehicle ~= 0 then
        reportVehicle(buildVehicleInfo(vehicle))
    else
        reportVehicle(nil)
    end
end)

-- Report initial vehicle state on resource start (covers hot-reload while in vehicle)
CreateThread(function()
    Wait(1000)
    local currentVehicle = cache.vehicle
    if currentVehicle and currentVehicle ~= 0 then
        reportVehicle(buildVehicleInfo(currentVehicle))
    end
end)

