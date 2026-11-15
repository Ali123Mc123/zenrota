-- Garage's valet (server/garage.lua): the nearest road point by the player for the car to come to, and once it is
-- there its mods put back on (the owner's game takes control of it first) and a waypoint to it.
local RESOURCE = GetCurrentResourceName()

-- The game's names for vehicle models (Garage lists them by these).
RegisterNUICallback('phone:modelNames', function(data, cb)
    local out = {}
    for _, model in ipairs(type(data.models) == 'table' and data.models or {}) do
        if type(model) == 'string' then
            local label = GetLabelText(GetDisplayNameFromVehicleModel(joaat(model)))
            out[model] = label ~= 'NULL' and label or model
        end
    end
    cb({ ok = true, names = out })
end)

-- The player's waypoint (Ride's drop-off), or nothing.
RegisterNUICallback('phone:waypoint', function(_, cb)
    local blip = GetFirstBlipInfoId(8)
    if not DoesBlipExist(blip) then return cb({ ok = false }) end
    local c = GetBlipInfoIdCoord(blip)
    cb({ ok = true, x = c.x, y = c.y, z = c.z })
end)

lib.callback.register(RESOURCE .. ':valetSpot', function()
    local p = GetEntityCoords(PlayerPedId())
    local ok, node, heading = GetClosestVehicleNodeWithHeading(p.x + 6.0, p.y + 6.0, p.z, 1, 3.0, 0)
    if not ok or #(node - p) > 80.0 then return nil end
    return { x = node.x, y = node.y, z = node.z, h = heading }
end)

RegisterNetEvent(RESOURCE .. ':valetArrived', function(netId, mods, plate)
    local veh, tries = 0, 0
    while tries < 60 do
        if NetworkDoesNetworkIdExist(netId) then
            veh = NetToVeh(netId)
            if veh ~= 0 and DoesEntityExist(veh) then break end
        end
        Wait(100)
        tries = tries + 1
    end
    if veh == 0 then return end
    NetworkRequestControlOfEntity(veh)
    local waited = 0
    while not NetworkHasControlOfEntity(veh) and waited < 30 do
        Wait(100)
        waited = waited + 1
    end
    if type(mods) == 'table' then lib.setVehicleProperties(veh, mods) end
    pcall(function() exports['FeloxAC']:ChangeVehiclePlate(veh, plate) end) --[[FeloxAC:auto]]
    SetVehicleNumberPlateText(veh, plate)
    SetVehicleOnGroundProperly(veh)
    SetVehicleDoorsLocked(veh, 1)
    local c = GetEntityCoords(veh)
    SetNewWaypoint(c.x, c.y)
end)
