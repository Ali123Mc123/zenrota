if Config.Garage ~= 'jg-advancedgarages' then
    return
end

local garageLocations = {}
local blacklisted_class = {
    [14] = true, -- Boats
    [15] = true, -- Helicopters
    [16] = true, -- Planes
    [20] = true, -- Commercial
    [21] = true, -- Trains
    [22] = true, -- Trains
}

local function GetVehicleLabel(model)
    local label = GetLabelText(GetDisplayNameFromVehicleModel(model))

    if label == 'NULL' then 
        label = GetDisplayNameFromVehicleModel(model)
    end

    return label
end

local function GetStateLabel(data)
    -- state is computed server side (1 = İçeride, 0 = Dışarıda, 2 = Çekilmiş)
    if data.state == 2 or (tonumber(data.impound) or 0) ~= 0 then
        return "Çekilmiş"
    elseif data.state == 1 then
        return "İçeride"
    else
        return "Dışarıda"
    end
end

-- Garage id -> { label, x, y, z }, fetched once and then reused, so refreshing
-- the vehicle list costs no extra round trip.
local garagesLoaded = false
local garageAttempts = 0
local MAX_GARAGE_ATTEMPTS = 3

local function LoadGarageLocations()
    -- Capped: an unanswered RPC costs a 20s await, and without a limit every
    -- list refresh would pay it again.
    if garagesLoaded or garageAttempts >= MAX_GARAGE_ATTEMPTS then return end
    garageAttempts = garageAttempts + 1

    local list = RPC.execute("cylex_phone:server:getGarageLocations")
    if type(list) ~= 'table' then return end

    local located = {}
    local count = 0
    for _, garage in pairs(list) do
        if garage.name then
            located[tostring(garage.name)] = garage
            count = count + 1
        end
    end

    if Config.Debug then
        print(('[cylex_phone] garage locations loaded: %s (attempt %s)'):format(count, garageAttempts))
    end

    if count == 0 then return end

    garageLocations = located
    garagesLoaded = true
end

-- jg stores the garage on either column depending on the framework
local function GarageIdOf(vehicle)
    if type(vehicle) ~= 'table' then return nil end
    return vehicle.garage or vehicle.garage_id
end

local function findGarage(garageId)
    if garageId == nil then return nil end

    local key = tostring(garageId)
    local garage = garageLocations[key]
    if garage then return garage end

    -- The vehicle row and jg's config can differ in casing/whitespace
    local needle = key:lower():match('^%s*(.-)%s*$')
    for name, entry in pairs(garageLocations) do
        if name:lower():match('^%s*(.-)%s*$') == needle then
            return entry
        end
    end

    return nil
end

-- Used when the vehicle's own garage id cannot be matched: better to point at
-- a real garage than to fail outright.
local function findNearestGarage()
    local coords = GetEntityCoords(PlayerPedId())
    local closest, closestDist

    for _, garage in pairs(garageLocations) do
        local dist = #(coords - vector3(garage.x, garage.y, garage.z))
        if not closestDist or dist < closestDist then
            closestDist = dist
            closest = garage
        end
    end

    return closest
end

function getVehicles()
    local tbl = RPC.execute("cylex_phone:server:getGarageVehicles")
    if not tbl then
        tbl = {}
    end

    -- Cached after the first successful call, so a list refresh costs no
    -- extra round trip
    LoadGarageLocations()

    local new_tbl = {}
    for k, v in pairs(tbl) do 
        local mods = {}
        if v.mods then
            mods = json.decode(v.mods)
        elseif v.allmods then 
            mods = json.decode(v.allmods) 
        elseif v.vehicle then 
            mods = json.decode(v.vehicle) 
        end

        if type(mods) ~= "table" then
            mods = {}
        end

        if not v.hash and mods.model then
            v.hash = mods.model
        end

        v.fuel = math.floor(v.fuel or 100)
        v.engine = (math.floor(mods.engineHealth or 1000) / 10)
        v.body = (math.floor(mods.bodyHealth or 1000) / 10)
        local hash = tonumber(v.hash)

        local name = GetVehicleLabel(hash)
        if v.nickname and v.nickname ~= '' then 
            name = v.nickname
        end
        v.name = name
        v.label = name

        -- Show the garage's label instead of its raw id when we have one
        local garageId = GarageIdOf(v)
        local garage = findGarage(garageId)
        v.garageName = (garage and garage.label) or garageId

        v.stateLabel = GetStateLabel(v)
        v.model = GetDisplayNameFromVehicleModel(hash)

        v.can_vale = true

        local class = GetVehicleClassFromName(v.model)
        v.class = class
        v.mods = mods
        if not blacklisted_class[class] then 
            table.insert(new_tbl, v)
        end
    end
    return new_tbl
end

CreateThread(function()
    while RPC == nil do Wait(1000) end

    -- Wait for jg itself, otherwise the first attempt comes back empty and
    -- burns one of the three tries
    local deadline = GetGameTimer() + 30000
    while GetResourceState('jg-advancedgarages') ~= 'started' and GetGameTimer() < deadline do
        Wait(500)
    end

    LoadGarageLocations()
end)


function setWaypoint(data)
    TriggerServerEvent('cylex_phone:vehicles:markVehicle', data.vehicle)
end

-- Returns false when the garage cannot be located, so the caller knows not to
-- report a waypoint that was never set.
function setGarageWaypoint(data)
    if type(data) ~= 'table' then return false end

    -- Deliberately does not fetch here: this runs inside an event handler and
    -- getVehicles() has already warmed the cache by the time a vehicle is on
    -- screen to tap.
    local garageId = GarageIdOf(data)
    local garage = findGarage(garageId) or findNearestGarage()

    if Config.Debug then
        print(('[cylex_phone] garage waypoint: id=%s known=%s matched=%s'):format(
            tostring(garageId), tostring(garagesLoaded), tostring(garage and garage.name)
        ))
    end

    if not garage then return false end

    SetNewWaypoint(garage.x, garage.y)
    return true
end