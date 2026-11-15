-- Test drives: the server makes the car in a bucket of the driver's own. Here the hall closes, the driver sits in, the
-- page shows the time left and the speed (it keeps no focus), and F, death or the time ends it; then the driver is back
-- where they stood and the showroom opens again on the car just driven. A drive a seller gave (testDrive = 'staff')
-- starts from their offer and ends where the driver stood; the seller sees the car on the map until it is over.
local active

local function finish()
    if active and not active.ending then
        active.ending = true
        TriggerServerEvent('daddy_dealerships:drive:end')
    end
end

local function begin(dealerId, model, res)
    local dealer = Dealers.get(dealerId)
    local ped = PlayerPedId()
    local from = GetEntityCoords(ped)
    active = { dealer = dealerId, model = model, staff = res.staff, back = vector4(from.x, from.y, from.z, GetEntityHeading(ped)) }
    if Hall.active then
        Hall.close(true, true)
    else
        DoScreenFadeOut(300)
        Wait(320)
    end
    -- the car streams in once the driver is near it, after the ground there
    local at = dealer.drive
    Core.land(vector3(at.x, at.y, at.z + 1.0))
    local found, veh = pcall(lib.waitFor, function()
        local entity = NetworkDoesNetworkIdExist(res.netId) and NetToVeh(res.netId) or 0
        if entity ~= 0 and DoesEntityExist(entity) then return entity end
    end, nil, 8000)
    if not found or not veh then
        finish()
        return DoScreenFadeIn(300)
    end
    TaskWarpPedIntoVehicle(ped, veh, -1)
    SetEntityInvincible(veh, true)
    pcall(function() exports['FeloxAC']:ChangeVehiclePlate(veh, res.plate) end) --[[FeloxAC:auto]]
    SetVehicleNumberPlateText(veh, res.plate)
    Bridge.keys.give(veh, res.plate)
    Bridge.fuel.set(veh, 100)
    Page.send('dealer:drive', { seconds = res.seconds, name = res.name or model, unit = Config.Row.Speed })
    DoScreenFadeIn(400)

    local kmh = Config.Row.Speed ~= 'mph'
    local tick = 0
    while active and not active.ending do
        DisableControlAction(0, 75, true) -- F leaves the car: here it ends the drive
        if IsDisabledControlJustPressed(0, 75) or IsEntityDead(PlayerPedId()) or not DoesEntityExist(veh) then finish() end
        if GetGameTimer() > tick then
            tick = GetGameTimer() + 250
            Page.send('dealer:drive:speed', { speed = math.floor(GetEntitySpeed(veh) * (kmh and 3.6 or 2.23694)) })
        end
        Wait(0)
    end
end

RegisterNetEvent('daddy_dealerships:drive:over', function()
    if not active then return end
    local a = active
    active = nil
    Page.send('dealer:drive:end')
    DoScreenFadeOut(300)
    Wait(320)
    local ped = PlayerPedId()
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(ped, a.back.x, a.back.y, a.back.z - 1.0, false, false, false, false)
    SetEntityHeading(ped, a.back.w)
    FreezeEntityPosition(ped, true)
    Page.notice('msg.drive_over', 'info')
    -- the showroom again, on the car just driven (it keeps the player frozen); dead, after a seller's drive or without
    -- it, the ground here first
    if IsEntityDead(ped) or a.staff or not Showroom.open(a.dealer, a.model) then
        Core.land()
        DoScreenFadeIn(300)
    end
end)

-- A seller's drive the player accepted.
RegisterNetEvent('daddy_dealerships:drive:start', function(dealerId, model, res)
    if active or type(res) ~= 'table' then return end
    CreateThread(function() begin(dealerId, model, res) end)
end)

RegisterNetEvent('daddy_dealerships:drive:offer', function(card)
    Ask.hold(card, function(yes)
        TriggerServerEvent('daddy_dealerships:drive:answer', yes, Core.vtype(joaat(card.model)))
    end)
end)

-- The seller: a drive they gave on the map, moved as the server says where the car is; gone when it ends.
local watched = {}
RegisterNetEvent('daddy_dealerships:drive:where', function(w)
    local blip = watched[w.id]
    if not w.x then
        if blip then RemoveBlip(blip) end
        watched[w.id] = nil
        return
    end
    if not blip then
        blip = AddBlipForCoord(w.x, w.y, w.z)
        SetBlipSprite(blip, 225)
        SetBlipColour(blip, 27)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(Core.t('ui.drive_blip', w.name or ''))
        EndTextCommandSetBlipName(blip)
        watched[w.id] = blip
    end
    SetBlipCoords(blip, w.x, w.y, w.z)
end)

RegisterCommand(Config.Commands.EndDrive, function()
    TriggerServerEvent('daddy_dealerships:drive:stop')
end, false)

TriggerEvent('chat:addSuggestion', '/' .. Config.Commands.EndDrive, Core.t('ui.end_drives'))

-- The seller in /araçsat: the drive offered to the chosen customer.
Page.on('dealer:drive:offer', function(data)
    return lib.callback.await('daddy_dealerships:drive:offer', false, Hall.dealer(), tonumber(data.target), tostring(data.model or ''))
        or { ok = false, error = 'failed' }
end)

Page.on('dealer:drive', function(data)
    local dealer, model = Hall.dealer(), tostring(data.model or '')
    if not dealer or active then return { ok = false, error = 'busy' } end
    local res = lib.callback.await('daddy_dealerships:drive', false, dealer, model, Core.vtype(joaat(model)))
    if not res or not res.ok then return { ok = false, error = res and res.error or 'failed' } end
    res.name = data.name
    CreateThread(function() begin(dealer, model, res) end)
    return { ok = true }
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    for _, blip in pairs(watched) do RemoveBlip(blip) end
    watched = {}
end)
