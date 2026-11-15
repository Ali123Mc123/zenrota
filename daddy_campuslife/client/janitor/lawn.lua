-- A lawn on the client: the mower stand (take the ride-on mower or a push mower, bring it back), cutting the grass
-- patches by driving or pushing over them (the server checks the vehicle and the speed), and the stand on the map
-- for the one who took the order.
if not Config.Janitor or not Config.Janitor.Enabled then return end

local cfg = Config.Janitor
local t = DL.locale.t
local chores = Campus.chores
local lawns = {} -- incident id -> view
local using -- { id, job, vehicle = net | nil, push = entity | nil, stop = fn }
local stand -- { id, blip, route }: the stand of the lawn order this player took
local me = GetPlayerServerId(PlayerId())

local function step(view) return view and view.steps and view.steps[view.step] end

-- The lawn order this janitor is on.
local function mine()
    for id, view in pairs(lawns) do
        if JanitorClient.working(id) then return id, view end
    end
end

-- The lawn order this janitor took (its stand is on their map only).
local function claimed()
    for id, view in pairs(lawns) do
        if view.claimer == me then return id, view end
    end
end

local function canCut()
    if not using then return false end
    if using.push then return chores.carried() == using.push and not IsPedInAnyVehicle(cache.ped, false) end
    local vehicle = GetVehiclePedIsIn(cache.ped, false)
    return vehicle ~= 0 and GetEntityModel(vehicle) == joaat(cfg.Mower.Model)
end

-- Whether the player needs the stand now: to take a mower for the mowing, or to bring theirs back.
local function needsStand(id, view)
    local s = step(view)
    return (s == 'mow' and using == nil) or (s == 'return' and using ~= nil and using.id == id)
end

-- The stand's blip for the order this player took, with the route to it while they need it.
local function mark()
    local id, view = claimed()
    local spot = id and view.data and view.data.stand
    if stand and (not spot or stand.id ~= id) then
        RemoveBlip(stand.blip)
        stand = nil
    end
    if not spot then return end
    if not stand then
        local blip = AddBlipForCoord(spot.x, spot.y, spot.z)
        SetBlipSprite(blip, 357)
        SetBlipColour(blip, 2)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, false)
        SetBlipRouteColour(blip, 2)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(t('janitor.mower_stand'))
        EndTextCommandSetBlipName(blip)
        stand = { id = id, blip = blip, route = false }
    end
    SetBlipCoords(stand.blip, spot.x, spot.y, spot.z)
    local route = needsStand(id, view)
    if route ~= stand.route then
        stand.route = route
        SetBlipRoute(stand.blip, route)
    end
end

-- Lets go of the mower of an order (or of any): the push mower out of the hands, the cutting stopped.
local function release(id)
    local u = using
    if not u or (id and u.id ~= id) then return end
    using = nil
    if u.stop then u.stop() end
    if u.push and chores.carried() == u.push then chores.drop() end
    mark()
end

local function pushMower()
    return chores.carry({ model = cfg.Mower.PushModel, bone = 57005, pos = vec3(0.45, 0.0, -0.9), rot = vec3(0.0, 0.0, 90.0) },
        { dict = 'missfinale_c2ig_11', clip = 'pushcar_offcliff_m' })
end

local function take(push)
    local id, view = mine()
    if not id or step(view) ~= 'mow' then return Campus.fail({ error = 'janitor_not_now' }) end
    local result = Campus.call('janitor:mowerTake', { id = id, push = push })
    if not result.ok then return Campus.fail(result) end
    local u = { id = id, job = view.data.job }
    using = u
    if push then
        u.push = pushMower()
    else
        local limit = GetGameTimer() + 3000
        while not NetworkDoesNetworkIdExist(result.net) and GetGameTimer() < limit do Wait(50) end
        local vehicle = NetworkDoesNetworkIdExist(result.net) and NetToVeh(result.net) or 0
        if vehicle ~= 0 then
            TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
            -- The keys once more from this side, should the server's not reach the keys script (it starts the engine then).
            TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(vehicle))
        end
        u.vehicle = result.net
    end
    if using ~= u then -- the order ended while the mower came
        if u.push and chores.carried() == u.push then chores.drop() end
        return
    end
    u.stop = chores.watchCuts(u.job, canCut, push and 1.4 or 2.2)
    mark()
    Nui.notify('janitor.mower_taken', 'inform', cfg.Mower.ReturnMinutes)
end

local function bring()
    local u = using
    if not u then return end
    if u.vehicle and IsPedInAnyVehicle(cache.ped, false) then TaskLeaveVehicle(cache.ped, GetVehiclePedIsIn(cache.ped, false), 0) Wait(1500) end
    local result = Campus.call('janitor:mowerReturn', {})
    if not result.ok then
        if result.error == 'not_found' then release(u.id) end
        return Campus.fail(result)
    end
    release(u.id)
    Nui.notify('janitor.mower_back', 'success')
end

Campus.kind('janitor_mower', function()
    return { options = {
        { name = 'janitor_mower_take', label = t('janitor.mower_take'), icon = 'fa-solid fa-tractor',
            canInteract = function() local _, view = mine() return using == nil and step(view) == 'mow' and chores.carried() == nil end,
            onSelect = function() CreateThread(function() take(false) end) end },
        { name = 'janitor_mower_push', label = t('janitor.mower_push'), icon = 'fa-solid fa-person-walking',
            canInteract = function() local _, view = mine() return using == nil and step(view) == 'mow' and chores.carried() == nil and IsModelInCdimage(joaat(cfg.Mower.PushModel)) end,
            onSelect = function() CreateThread(function() take(true) end) end },
        { name = 'janitor_mower_return', label = t('janitor.mower_return'), icon = 'fa-solid fa-square-parking',
            canInteract = function() return using ~= nil end,
            onSelect = function() CreateThread(bring) end },
    }, distance = 4.0 }
end)

JanitorClient.kinds.lawn = {
    onView = function(view)
        local live = view.state == 'open' or view.state == 'claimed'
        lawns[view.id] = live and view or nil
        if not live then release(view.id) end
        mark()
    end,

    -- The board's map button: for the one who took it, the stand while the mower is to be taken or brought back, else the lawn.
    waypoint = function(view)
        local spot = view.data and view.data.stand
        if spot and view.claimer == me and needsStand(view.id, view) then return spot end
    end,

    -- The push mower fell from the hands (a fall, a car): taken up again once the player is back on foot.
    onDropped = function(prop)
        local u = using
        if not u or not u.push or prop ~= u.push then return end
        CreateThread(function()
            while using == u and (IsPedRagdoll(cache.ped) or IsEntityDead(cache.ped) or IsPedInAnyVehicle(cache.ped, true)) do Wait(500) end
            if using == u and chores.carried() == nil then u.push = pushMower() end
        end)
    end,
}

-- The server took the mower back (late, or the player was let go from the order or left it).
RegisterNetEvent('daddy_campuslife:janitor:mowerGone', function(id) release(id) end)

-- Off the character: no mower in hand, no stand on the map.
DL.fw.onUnloaded(function()
    release()
    if stand then RemoveBlip(stand.blip) stand = nil end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if stand then RemoveBlip(stand.blip) end
end)
