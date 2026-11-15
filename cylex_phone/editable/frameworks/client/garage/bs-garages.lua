if Config.Garage ~= 'bs-garages' then
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
        ["stored"] = "Garajda",
        ["locked"] = "Kilitli",
        ["impounded"] = "Çekilmiş",
        ["seized"] = "El Konulmuş",
        ["out"] = "Dışarıda",
        ["retrieved"] = "Geri Alınmış"
    }

    return labels[state] or state
end

local function findGarage(garage)
    for k,v in pairs(garageLocations) do 
        if v.garage_id == garage then 
            return v
        end
    end
    return false
end


function getVehicles()
    local tbl = RPC.execute("bs-vehicles:getPlayerVehicles")
    if not tbl then
        tbl = {}
    end

    local new_tbl = {}
    for k,v in pairs(tbl) do 
        local mods = {}
        if v.mods then
            mods = json.decode(v.mods)
        elseif v.allmods then 
            mods = json.decode(v.allmods) 
        elseif v.vehicle then 
            mods = json.decode(v.vehicle) 
        end
        v.fuel = math.floor(v.metadata.fuel or 100)
        v.engine = (math.floor(v.damage.engine or 1000) / 10)
        v.body = (math.floor(v.damage.body or 1000) / 10)
        v.name = GetVehicleLabel(tonumber(v.model))
        v.label = GetVehicleLabel(tonumber(v.model))
        v.garageName = findGarage(v.garage).name
        v.stateLabel = GetStateLabel(v.state)

        v.can_vale = false
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
    while Cylex == nil or Cylex.GetPlayerData == nil do Wait(1000) end
    local PlayerData = Cylex.GetPlayerData()
    garageLocations = RPC.execute("bs-vehicles:getGarageLocations")
end)

function setWaypoint(data)
    local coords = RPC.execute("bs-vehicles:garage:markVehicle", data.vehicle.vin)
    if coords then
        return SetNewWaypoint(coords.x, coords.y)
    end

    setGarageWaypoint(data)
end

function setGarageWaypoint(data)
    local garageLoc = garageLocations[data.vehicle.garage]
    if not garageLoc or not garageLoc.location then 
        return print('garage not found', data.vehicle.garage)
    end
    local targetCoords = garageLoc.location.vectors 
    SetNewWaypoint(targetCoords.x, targetCoords.y)
end

-- RegisterNetEvent("bs-garages:client:onVehicleSpawned", function()
--     getVehicles()
-- end)

-- RegisterNetEvent("bs-garages:client:onVehicleStored", function()
--     getVehicles()
-- end)

RegisterNetEvent("bs:vehicles:reloadGarage", function()
    getVehicles()
end)