-- Display cars: each client makes them itself from the server's list (local cars near them, frozen and locked).
-- Standing at one on foot shows its name and price; E opens the showroom on it.
local list, made, madeSpec = {}, {}, {}

local function specKey(d)
    local c = d.rgb and ('%d,%d,%d'):format(d.rgb[1] or 0, d.rgb[2] or 0, d.rgb[3] or 0) or tostring(d.index or '')
    return ('%s:%.2f:%.2f:%.2f:%.2f:%s'):format(tostring(d.model or ''), d.x or 0, d.y or 0, d.z or 0, d.w or 0, c)
end

local function make(d)
    local hash = joaat(d.model)
    if not IsModelInCdimage(hash) or not pcall(lib.requestModel, hash, 5000) then return end
    pcall(function() exports['FeloxAC']:CreateVehicle(hash) end) --[[FeloxAC:auto]]
    local veh = CreateVehicle(hash, d.x, d.y, d.z, d.w, false, false)
    SetModelAsNoLongerNeeded(hash)
    SetEntityInvincible(veh, true)
    SetVehicleDoorsLocked(veh, 2)
    SetVehicleOnGroundProperly(veh)
    FreezeEntityPosition(veh, true)
    SetVehicleDirtLevel(veh, 0.0)
    pcall(function() exports['FeloxAC']:ChangeVehiclePlate(veh, Config.Display.Plate) end) --[[FeloxAC:auto]]
    SetVehicleNumberPlateText(veh, Config.Display.Plate)
    if d.rgb then
        SetVehicleCustomPrimaryColour(veh, d.rgb[1], d.rgb[2], d.rgb[3])
        SetVehicleCustomSecondaryColour(veh, d.rgb[1], d.rgb[2], d.rgb[3])
    elseif d.index then
        SetVehicleColours(veh, d.index, d.index)
    end
    made[d.id] = veh
    madeSpec[d.id] = specKey(d)
end

local function remove(id)
    if made[id] and DoesEntityExist(made[id]) then DeleteEntity(made[id]) end
    made[id] = nil
    madeSpec[id] = nil
end

RegisterNetEvent('daddy_dealerships:display', function(fresh)
    local nextList = type(fresh) == 'table' and fresh or {}
    local byId = {}
    for _, d in ipairs(nextList) do byId[d.id] = d end
    for id in pairs(made) do
        local d = byId[id]
        if not d or madeSpec[id] ~= specKey(d) then remove(id) end
    end
    list = nextList
end)

-- Near ones stand, far ones go.
CreateThread(function()
    list = lib.callback.await('daddy_dealerships:display', false) or {}
    while true do
        local here = GetEntityCoords(PlayerPedId())
        for _, d in ipairs(list) do
            local near = #(here - vector3(d.x, d.y, d.z)) <= Config.Display.Distance
            if near and not made[d.id] then make(d)
            elseif not near and made[d.id] then remove(d.id) end
        end
        Wait(1000)
    end
end)

-- The prompt at the nearest one, while the dealership's own door is not prompting.
CreateThread(function()
    local shown
    while true do
        local pick
        if not Hall.active and not Panel.active and not Showroom.at and not IsPedInAnyVehicle(PlayerPedId(), false) then
            local here, best = GetEntityCoords(PlayerPedId()), Config.Display.Reach
            for _, d in ipairs(list) do
                local dist = #(here - vector3(d.x, d.y, d.z))
                if made[d.id] and dist < best then pick, best = d, dist end
            end
        end
        if pick ~= shown then
            shown = pick
            Bridge.hint(pick and { label = pick.name, sub = Core.money(pick.price), verb = 'ui.view' } or nil)
        end
        if pick then
            if IsControlJustPressed(0, 38) then
                Bridge.hint(nil)
                shown = nil
                Showroom.open(pick.dealer, pick.model)
            end
            Wait(0)
        else
            Wait(next(made) and 250 or 1000)
        end
    end
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    for id in pairs(made) do remove(id) end
end)
