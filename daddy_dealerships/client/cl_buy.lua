-- Buying from the page: the server takes the money and writes the car; here the hall closes and the car is handed over,
-- outside the door with its keys or into the buyer's garage. A direct sale hands it over the same way.
Purchase = {}

-- The vehicle type the server spawns with, from the model (the server prefers the framework's list when it has one).
function Core.vtype(hash)
    if IsThisModelABoat(hash) or IsThisModelAJetski(hash) then return 'boat' end
    -- the boats' class holds the submarines too
    if GetVehicleClassFromName(hash) == 14 then return 'submarine' end
    if IsThisModelAHeli(hash) then return 'heli' end
    if IsThisModelAPlane(hash) then return 'plane' end
    if IsThisModelABike(hash) or IsThisModelABicycle(hash) then return 'bike' end
    return 'automobile'
end

-- The garage type a new car is filed under (jg-advancedgarages' car / sea / air).
local function garageType(hash)
    local kind = Core.vtype(hash)
    return (kind == 'boat' or kind == 'submarine') and 'sea' or (kind == 'heli' or kind == 'plane') and 'air' or 'car'
end

-- After a purchase: the hall closes and the car is the buyer's (at the door with its keys, or in the garage).
function Purchase.handOver(res, hash)
    Hall.close()
    if res.stored then
        TriggerServerEvent('jg-advancedgarages:server:dealerships-send-to-default-garage', garageType(hash), res.plate)
        return Page.notice('msg.bought_garage', 'success', res.plate)
    end
    -- lib.waitFor throws when the time is up: a car that never arrives just means no warp
    local found, veh = pcall(lib.waitFor, function()
        local entity = res.netId and NetworkDoesNetworkIdExist(res.netId) and NetToVeh(res.netId) or 0
        if entity ~= 0 and DoesEntityExist(entity) then return entity end
    end, nil, 5000)
    -- The fuel goes on with the look, by the client that owns the car (the bag below).
    if found and veh then
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        Bridge.keys.give(veh, res.plate)
    end
    Page.notice('msg.bought', 'success', res.plate)
end

Page.on('dealer:buy', function(data)
    local hash = joaat(tostring(data.model or ''))
    local res = lib.callback.await('daddy_dealerships:buy', false, {
        dealer = Hall.dealer(), model = data.model, colour = tonumber(data.colour), rgb = data.rgb, account = data.account, coupon = data.coupon, plan = data.plan, terms = tonumber(data.terms),
        delivery = data.delivery, vtype = Core.vtype(hash), used = tonumber(data.used),
    })
    if not res or not res.ok then return { ok = false, error = res and res.error or 'failed' } end
    CreateThread(function() Purchase.handOver(res, hash) end)
    return { ok = true, plate = res.plate }
end)

Page.on('dealer:coupon', function(data)
    return lib.callback.await('daddy_dealerships:coupon', false, Hall.dealer(), tostring(data.model or ''), tostring(data.code or ''), data.plan, tonumber(data.used),
        tonumber(data.target))
        or { ok = false, error = 'failed' }
end)

-- The look of a bought car (its props: colours and plate; a used car's whole state) and its fuel, put on by the client
-- the game made its owner. Every client waits a while to become it; the server sets the bag again when nobody did.
AddStateBagChangeHandler('daddy_dealerships:props', nil, function(bag, _, value)
    if type(value) ~= 'table' then return end
    CreateThread(function()
        local found, veh = pcall(lib.waitFor, function()
            local entity = GetEntityFromStateBagName(bag)
            if entity ~= 0 and DoesEntityExist(entity) then return entity end
        end, nil, 5000)
        if not found or not veh then return end
        local stop = GetGameTimer() + 10000
        while DoesEntityExist(veh) and NetworkGetEntityOwner(veh) ~= PlayerId() and GetGameTimer() < stop do Wait(100) end
        if not DoesEntityExist(veh) or NetworkGetEntityOwner(veh) ~= PlayerId() or not Entity(veh).state['daddy_dealerships:props'] then return end
        if value.used then
            Used.apply(veh, value.used)
        elseif type(value.props) == 'table' then
            lib.setVehicleProperties(veh, value.props)
        end
        Bridge.fuel.set(veh, tonumber(value.fuel) or Config.Purchase.Fuel)
        TriggerServerEvent('daddy_dealerships:applied', NetworkGetNetworkIdFromEntity(veh))
    end)
end)
