if Config.Garage ~= 'op-garages' then
    return
end

local garageLocations = {}


local function GetVehicleLabel(model)
    local label = GetLabelText(GetDisplayNameFromVehicleModel(model))

    if label == 'NULL' then 
        label = GetDisplayNameFromVehicleModel(model)
    end

    return label
end

local function GetStateLabel(state)
    local labels = {
        [1] = "Outside",
        [0] = "Inside",
    }

    return labels[state] or state
end

local function findGarage(garageId)
    for k,v in pairs(garageLocations) do
        if v.Index == garageId then
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

    for k, v in pairs(tbl) do 
        local mods = json.decode(v.mods)
        v.fuel = math.floor(v.fuel or 100)
        v.engine = (math.floor(mods.engineHealth or 1000) / 10)
        v.body = (math.floor(mods.bodyHealth or 1000) / 10)
        local hash = tonumber(v.hash)
        v.name = GetVehicleLabel(hash)
        v.label = GetVehicleLabel(hash)
        v.garageName = v.garage
        v.stateLabel = GetStateLabel(v.state)
        v.model = GetDisplayNameFromVehicleModel(hash)

        v.garage_id = v.Index
        v.can_vale = true
    end
    return tbl
end

CreateThread(function()
    while RPC == nil do Wait(1000) end
    while Cylex == nil or Cylex.GetPlayerData == nil do Wait(1000) end
    while Cylex.GetPlayerData().job == nil do Wait(300) end
    local PlayerData = Cylex.GetPlayerData()
    garageLocations = RPC.execute("cylex_phone:server:getGarageLocations")
end)


function setWaypoint(data)
    TriggerServerEvent('cylex_phone:vehicles:markVehicle', data.vehicle)
end

function setGarageWaypoint(data)
    local coords = GetEntityCoords(PlayerPedId())
    local closest = nil
    local closestDist = nil
    
    for k, v in pairs(garageLocations) do
        local encoded_coords = json.decode(v.Coords)
        local coord = encoded_coords["CenterOfZone"]
        local dist = #(coords - vector3(coord.x, coord.y, coord.z))
        if not closestDist or dist < closestDist then
            closestDist = dist
            closest = coord
        end
    end

    -- Report the failure instead of returning nil: the caller treats anything
    -- that is not false as a waypoint it can announce
    if not closest then return false end

    SetNewWaypoint(closest.x, closest.y)
    return true
end