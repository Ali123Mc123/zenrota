if Config.Garage ~= 'tgiann-realparking' then
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

        if not blacklisted_class[class] then 
            table.insert(new_tbl, v)
        end
    end
    return new_tbl
end

function setWaypoint(data)
    TriggerServerEvent('cylex_phone:vehicles:markVehicle', data.vehicle)
end

-- Marks the garage this specific vehicle is parked in, resolved server side
-- through tgiann's GetVehicleParkedGarage export.
function setGarageWaypoint(data)
    if type(data) ~= 'table' then return false end

    local plate = data.plate
    if type(plate) ~= 'string' or plate == '' then return false end

    local garage = RPC.execute('cylex_phone:server:getParkedGarage', plate)

    if Config.Debug then
        print(('[cylex_phone] garage waypoint: plate=%s found=%s'):format(
            plate, tostring(type(garage) == 'table' and garage.x ~= nil)
        ))
    end

    if type(garage) ~= 'table' or type(garage.x) ~= 'number' then return false end

    SetNewWaypoint(garage.x, garage.y)
    return true
end