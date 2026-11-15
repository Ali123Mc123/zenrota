if Config.Garage ~= 'qb-garages' then
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

local function GetStateLabel(state)
    local labels = {
        [0] = "Outside",
        [1] = "Inside",
    }

    return labels[state] or state
end

local function findGarage(garageId)
    for k,v in pairs(garageLocations) do
        if v.garage_id == garageId then
            return v
        end
    end
    return {name = "Bilinmiyor"}
end

function getVehicles()
    local tbl = RPC.execute("cylex_phone:server:getGarageVehicles")
    if not tbl then
        tbl = {}
    end

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
        v.fuel = math.floor(v.fuel or 100)
        v.engine = (math.floor(mods.engineHealth or 1000) / 10)
        v.body = (math.floor(mods.bodyHealth or 1000) / 10)
        local hash = tonumber(v.hash)
        v.name = GetVehicleLabel(hash)
        v.label = GetVehicleLabel(hash)
        v.garageName = v.garage
        v.stateLabel = GetStateLabel(v.state)
        v.model = GetDisplayNameFromVehicleModel(hash)
        v.can_vale = true
        local class = GetVehicleClassFromName(v.model)
        v.class = class
        v.mods = mods

        v.stored = v.state == 1

        if not blacklisted_class[class] then 
            table.insert(new_tbl, v)
        end
    end
    return new_tbl
end

CreateThread(function()
    while RPC == nil do Wait(1000) end
    while Cylex == nil or Cylex.GetPlayerData == nil do Wait(1000) end
    while Cylex.GetPlayerData().job == nil do Wait(300) end
    local PlayerData = Cylex.GetPlayerData()

    local success, err = pcall(function()
        garageLocations = exports['qb-garages']:getGarages() 
    end)
end)


function setWaypoint(data)
    TriggerServerEvent('cylex_phone:vehicles:markVehicle', data.vehicle)
end

function setGarageWaypoint(data)
    local coords = GetEntityCoords(PlayerPedId())
    local closest = nil
    local closestDist = nil
    if garageLocations and garageLocations.coords then 
        for k, v in pairs(garageLocations.coords) do
            local dist = #(coords - v.garage)
            if not closestDist or dist < closestDist then
                closestDist = dist
                closest = v
            end
        end
    end

    -- Report the failure instead of returning nil: the caller treats anything
    -- that is not false as a waypoint it can announce
    if not closest then return false end

    local targetCoords = closest.garage
    SetNewWaypoint(targetCoords.x, targetCoords.y)
    return true
end