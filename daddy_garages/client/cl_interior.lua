-- Walking among the cars: the garage's parked cars stand in GTA's ten-car garage and the player walks between them, in a
-- routing bucket of their own. E in a car's driver seat drives it out through the garage; E by the door walks out.
Interior = { active = false, entering = false, cars = {} }
local I = Interior
local KVP = 'daddy_garages:inside'

local function fadeOut(ms)
    DoScreenFadeOut(ms)
    local stop = GetGameTimer() + ms + 1000
    while not IsScreenFadedOut() and GetGameTimer() < stop do Wait(0) end
end

-- The cars that stand inside: parked here, favourites first, then the latest driven.
local function pick()
    local list = {}
    for plate, car in pairs(Garage.cars or {}) do
        if car.state == 'in' and not plate:find('^SPAWN%-') then list[#list + 1] = car end
    end
    table.sort(list, function(a, b)
        if (a.favourite == true) ~= (b.favourite == true) then return a.favourite == true end
        return (a.lastUsed or 0) < (b.lastUsed or 0)
    end)
    return list
end

-- Local copies on the slots, dressed and locked in place (nobody else is in this bucket).
local function spawnCars(list)
    for i, slot in ipairs(Config.Interior.Slots) do
        local car = list[i]
        if not car then break end
        local hash = type(car.model) == 'string' and GetHashKey(car.model) or car.model
        if IsModelInCdimage(hash) and pcall(lib.requestModel, hash, 5000) then
            pcall(function() exports['FeloxAC']:CreateVehicle(hash) end) --[[FeloxAC:auto]]
            local veh = CreateVehicle(hash, slot.x, slot.y, slot.z, slot.w, false, false)
            SetVehicleOnGroundProperly(veh)
            if car.props then Car.setProps(veh, car.props, true) end
            if not (car.props and car.props.plate) then pcall(function() exports['FeloxAC']:ChangeVehiclePlate(veh, car.plate) end) --[[FeloxAC:auto]] SetVehicleNumberPlateText(veh, car.plate) end
            SetVehicleDoorsLocked(veh, 1)
            SetVehicleEngineOn(veh, false, true, true)
            FreezeEntityPosition(veh, true)
            SetModelAsNoLongerNeeded(hash)
            I.cars[veh] = car.plate
        end
    end
end

local function clear()
    for veh in pairs(I.cars) do
        if DoesEntityExist(veh) then DeleteEntity(veh) end
    end
    I.cars = {}
end

-- The walk-in shot: a glide from the back of the room to behind the player, then the game camera.
local function glide()
    local cams = Config.Interior.Camera or {}
    local from, to = cams[1], cams[2]
    if not from or not to then return DoScreenFadeIn(500) end
    local a = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', from.x, from.y, from.z, -4.0, 0.0, from.w or 0.0, 50.0, false, 0)
    pcall(function() exports['FeloxAC']:createCam(a) end) --[[FeloxAC:auto]]
    local b = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', to.x, to.y, to.z, -4.0, 0.0, to.w or 0.0, 50.0, false, 0)
    pcall(function() exports['FeloxAC']:createCam(b) end) --[[FeloxAC:auto]]
    SetCamActive(a, true)
    RenderScriptCams(true, false, 0, true, true)
    if GetResourceState('wais-primehud') == 'started' then exports['wais-primehud']:showHud() end
    SetCamActiveWithInterp(b, a, 2600, 1, 1)
    DoScreenFadeIn(500)
    Wait(2600)
    RenderScriptCams(false, true, 700, true, true)
    if GetResourceState('wais-primehud') == 'started' then exports['wais-primehud']:hideHud() end
    Wait(700)
    pcall(function() exports['FeloxAC']:destroyCam(a) end) --[[FeloxAC:auto]]
    DestroyCam(a, false)
    pcall(function() exports['FeloxAC']:destroyCam(b) end) --[[FeloxAC:auto]]
    DestroyCam(b, false)
end

-- Back to the garage point: the bucket, the spot, the saved mark.
local function goBack()
    I.active = false
    Bridge.hint(nil)
    clear()
    lib.callback.await('daddy_garages:interior', false, false)
    Core.land(I.back, I.heading)
    DeleteResourceKvp(KVP)
end

function I.leave()
    if not I.active then return end
    fadeOut(500)
    goBack()
    lib.callback('daddy_garages:close', false, function() end)
    Garage.current = nil
    DoScreenFadeIn(500)
end

-- The real car comes out at the garage's exit with the player in it, as from the column.
function I.driveOut(plate)
    if not I.active then return end
    fadeOut(500)
    ClearPedTasksImmediately(cache.ped)
    goBack()
    Garage.takeOut(plate, 'drive')
    DoScreenFadeIn(700)
end

-- While inside: what E does where the player stands.
local function loop()
    CreateThread(function()
        local shown
        local door = Config.Interior.Entrance
        while I.active do
            local ped = cache.ped
            local veh = GetVehiclePedIsIn(ped, false)
            local kind
            if veh ~= 0 and I.cars[veh] and GetPedInVehicleSeat(veh, -1) == ped then
                kind = 'drive'
            elseif #(GetEntityCoords(ped) - vector3(door.x, door.y, door.z)) < 2.0 then
                kind = 'leave'
            end
            if kind ~= shown then
                shown = kind
                Bridge.hint(kind, I.garage)
            end
            if kind and IsControlJustPressed(0, Config.Interact.Key) then
                if kind == 'drive' then I.driveOut(I.cars[veh]) else I.leave() end
            end
            Wait(0)
        end
    end)
end

-- From the column's walk-in button: the page goes, the player walks into the room with the cars.
function I.enter()
    local garage = Garage.current
    if I.active or Garage.busy or not garage or not garage.interior then return end
    local list = pick()
    if #list == 0 then return Page.notice('msg.interior_empty', 'info') end
    I.entering = true
    Page.open = false
    Page.focus(false)
    Page.send('garage:close')
    fadeOut(500)
    Showroom.stop(0)
    if not lib.callback.await('daddy_garages:interior', false, true) then
        lib.callback('daddy_garages:close', false, function() end)
        Garage.current = nil
        I.entering = false
        DoScreenFadeIn(300)
        return Page.notice('msg.failed', 'error')
    end
    local ped = cache.ped
    I.back, I.heading = GetEntityCoords(ped), GetEntityHeading(ped)
    I.garage = { label = garage.label }
    SetResourceKvp(KVP, garage.id)
    local door = Config.Interior.Entrance
    Core.land(door, door.w)
    spawnCars(list)
    I.active, I.entering = true, false
    loop()
    glide()
    local more = #list - #Config.Interior.Slots
    if more > 0 then Page.notice('msg.interior_more', 'info', more) end
end

Page.on('garage:walkIn', function()
    CreateThread(I.enter)
end)

-- A crash or a restart inside: back at the garage the player walked in from (only in the first minutes after joining).
CreateThread(function()
    if not GetResourceKvpString(KVP) then return end
    local stop = GetGameTimer() + 600000
    while GetGameTimer() < stop do
        Wait(3000)
        local id = not I.active and not I.entering and GetResourceKvpString(KVP)
        if not id then return end
        local door = Config.Interior.Entrance
        if Zones.list and #(GetEntityCoords(cache.ped) - vector3(door.x, door.y, door.z)) < 40.0 then
            local garage = Zones.list[id] or Zones.list[Config.DefaultGarages.car or '']
            if garage then
                Core.land(garage.coords, 0.0)
                DeleteResourceKvp(KVP)
                return
            end
        end
    end
    if not I.active then DeleteResourceKvp(KVP) end
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() or not I.active then return end
    clear()
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(cache.ped, I.back.x, I.back.y, I.back.z, false, false, false, false)
    DeleteResourceKvp(KVP)
    DoScreenFadeIn(0)
end)
