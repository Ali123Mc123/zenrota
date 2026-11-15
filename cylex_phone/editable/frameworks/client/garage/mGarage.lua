if Config.Garage ~= 'mGarage' then return end

local garageLocations = {}

function getVehicles()
    isFrameworkReady()
    local tbl = Cylex.TriggerCallback('mGarage:server:getOwnedVehicles', 'car', 1)
    if not tbl then
        tbl = {}
    end
    print('getVehicles triggered', json.encode(tbl))
    for k, v in pairs(tbl) do
        local vehicleProps = json.decode(v.vehicle)
        local damages = vehicleProps.damage

        v.fuel = math.floor(vehicleProps.fuelLevel or 100)
        v.engine = (math.floor(damages.engine or 1000) / 10)
        v.body = (math.floor(damages.body or 1000) / 10)
        v.name = vehicleProps.modelLabel
        v.label = vehicleProps.modelLabel
        v.model = vehicleProps.modelLabel

        v.can_vale = false
    end
    return tbl
end

CreateThread(function()
    while GetResourceState('mGarage') ~= 'started' do Wait(500) end
    garageLocations = exports['mGarage']:getConfig()
end)

function setWaypoint(data)
    TriggerServerEvent('cylex_phone:vehicles:markVehicle', data.vehicle)
end

function setGarageWaypoint(data)
    local coords = GetEntityCoords(PlayerPedId())
    local closest = nil
    local closestDist = nil
    if not garageLocations or not garageLocations.coords then return false end

    for k, v in pairs(garageLocations.coords) do
        local dist = #(coords - v.garage)
        if not closestDist or dist < closestDist then
            closestDist = dist
            closest = v
        end
    end

    -- Report the failure instead of returning nil: the caller treats anything
    -- that is not false as a waypoint it can announce
    if not closest then return false end

    local targetCoords = closest.garage
    SetNewWaypoint(targetCoords.x, targetCoords.y)
    return true
end


RegisterNUICallback('vehicle:markVehicle', function(data, cb)
    setWaypoint(data)
    cb(true)
end)

RegisterNetEvent('bs-garages:client:onVehicleSpawned', function()
    getVehicles()
end)

RegisterNetEvent('bs-garages:client:onVehicleStored', function()
    getVehicles()
end)
