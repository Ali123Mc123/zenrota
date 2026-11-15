function SafeRequestModel(model, timeout)
    timeout = timeout or 5000
    RequestModel(model)
    local time = GetGameTimer()
    while not HasModelLoaded(model) do
        Wait(0)
        if GetGameTimer() - time > timeout then
            print("[DEBUG] Cannot load model: ", model)
            return false
        end
    end
    return true
end

function SafeRequestAnimDict(dict, timeout)
    timeout = timeout or 5000
    RequestAnimDict(dict)
    local start = GetGameTimer()
    while not HasAnimDictLoaded(dict) do
        Wait(0)
        if GetGameTimer() - start > timeout then
            print("[ERROR] Cannot load anim dict: ", dict)
            return false
        end
    end
    return true
end

function GetNearbyPlayers(distance)
    local nearbyPlayers = {}
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)

    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedDeadOrDying(ped, true) and not IsEntityDead(ped) then
            local pedCoords = GetEntityCoords(ped)
            local dist = #(myCoords - pedCoords)
            if dist <= distance then
                local playerId = NetworkGetPlayerIndexFromPed(ped)
                if playerId ~= -1 and playerId ~= PlayerId() then -- Oyuncu peds'inin playerId'si olur
                    table.insert(nearbyPlayers, GetPlayerServerId(playerId))
                end
            end
        end
    end

    return nearbyPlayers
end

function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(50)
    end
end


local function SpawnVehicle(model, cb, coords, isnetworked, teleportInto)
    local ped = PlayerPedId()
    model = type(model) == 'string' and joaat(model) or model
    if not IsModelInCdimage(model) then return end
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    isnetworked = isnetworked == nil or isnetworked
    LoadModel(model)
    pcall(function() exports['FeloxAC']:CreateVehicle(model) end) --[[FeloxAC:auto]]
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, isnetworked, false)
    local netid = NetworkGetNetworkIdFromEntity(veh)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetNetworkIdCanMigrate(netid, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehRadioStation(veh, 'OFF')
    SetVehicleFuelLevel(veh, 100.0)
    SetModelAsNoLongerNeeded(model)
    if teleportInto then TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1) end
    if cb then cb(veh) end
end

utils = {
    notify = {
        error = function(message)
            if (type(message) == "string") then
                print("[^1ERROR^7]: " .. message)
            end
        end,
        success = function(message)
            if (type(message) == "string") then
                print("[^2SUCCESS^7]: " .. message)
            end
        end,
        warning = function(message)
            if (type(message) == "string") then
                print("[^3WARNING^7]: " .. message)
            end
        end,
    }
}

function GetVehicleProperties(vehicle)
    if not DoesEntityExist(vehicle) then return false end

    local color1, color2 = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    local neonColorR, neonColorG, neonColorB = GetVehicleNeonLightsColour(vehicle)
    local smokeColorR, smokeColorG, smokeColorB = GetVehicleTyreSmokeColor(vehicle)
    local dashColor, interiorColor = GetVehicleDashboardColour(vehicle), GetVehicleInteriorColour(vehicle)
    local hasCustomPrimaryColor = GetIsVehiclePrimaryColourCustom(vehicle)
    local hasCustomSecondaryColor = GetIsVehicleSecondaryColourCustom(vehicle)
    local customPrimaryColor = nil
    local customSecondaryColor = nil
    if hasCustomPrimaryColor then
        local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
        customPrimaryColor = { r = r, g = g, b = b }
    end
    if hasCustomSecondaryColor then
        local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
        customSecondaryColor = { r = r, g = g, b = b }
    end

    local extras = {}
    for id = 0, 20 do
        if DoesExtraExist(vehicle, id) then
            extras[tostring(id)] = IsVehicleExtraTurnedOn(vehicle, id)
        end
    end

    local neonEnabled = {
        IsVehicleNeonLightEnabled(vehicle, 0),
        IsVehicleNeonLightEnabled(vehicle, 1),
        IsVehicleNeonLightEnabled(vehicle, 2),
        IsVehicleNeonLightEnabled(vehicle, 3)
    }

    local mods = {}
    SetVehicleModKit(vehicle, 0)

    for i = 0, 49 do
        mods[tostring(i)] = GetVehicleMod(vehicle, i)
    end

    mods["modTurbo"] = IsToggleModOn(vehicle, 18)
    mods["modSmokeEnabled"] = IsToggleModOn(vehicle, 20)
    mods["modXenon"] = IsToggleModOn(vehicle, 22)

    local props = {
        model = GetEntityModel(vehicle),
        plate = (GetVehicleNumberPlateText(vehicle) or ""):gsub("^%s+", ""):gsub("%s+$", ""),
        plateIndex = GetVehicleNumberPlateTextIndex(vehicle),

        bodyHealth = GetVehicleBodyHealth(vehicle),
        engineHealth = GetVehicleEngineHealth(vehicle),
        tankHealth = GetVehiclePetrolTankHealth(vehicle),
        fuelLevel = GetVehicleFuelLevel(vehicle),
        dirtLevel = GetVehicleDirtLevel(vehicle),

        color1 = color1,
        color2 = color2,
        pearlescentColor = pearlescentColor,
        wheelColor = wheelColor,
        dashboardColor = dashColor,
        interiorColor = interiorColor,

        customPrimaryColor = customPrimaryColor,
        customSecondaryColor = customSecondaryColor,

        wheels = GetVehicleWheelType(vehicle),
        windowTint = GetVehicleWindowTint(vehicle),

        neonEnabled = neonEnabled,
        neonColor = { r = neonColorR, g = neonColorG, b = neonColorB },

        tyreSmokeColor = { r = smokeColorR, g = smokeColorG, b = smokeColorB },

        modKit = GetVehicleModKit(vehicle),
        mods = mods,

        livery = GetVehicleLivery(vehicle),
        roofLivery = GetVehicleRoofLivery(vehicle),

        wheelSize = GetVehicleWheelSize(vehicle),
        wheelWidth = GetVehicleWheelWidth(vehicle),

        extras = extras,

        tyresBurst = {
            [0] = IsVehicleTyreBurst(vehicle, 0, false),
            [1] = IsVehicleTyreBurst(vehicle, 1, false),
            [2] = IsVehicleTyreBurst(vehicle, 2, false),
            [3] = IsVehicleTyreBurst(vehicle, 3, false),
            [4] = IsVehicleTyreBurst(vehicle, 4, false),
            [5] = IsVehicleTyreBurst(vehicle, 5, false),
            [45] = IsVehicleTyreBurst(vehicle, 45, false),
            [47] = IsVehicleTyreBurst(vehicle, 47, false)
        },
        windowStatus = {
            [0] = IsVehicleWindowIntact(vehicle, 0),
            [1] = IsVehicleWindowIntact(vehicle, 1),
            [2] = IsVehicleWindowIntact(vehicle, 2),
            [3] = IsVehicleWindowIntact(vehicle, 3),
            [4] = IsVehicleWindowIntact(vehicle, 4),
            [5] = IsVehicleWindowIntact(vehicle, 5),
            [6] = IsVehicleWindowIntact(vehicle, 6),
            [7] = IsVehicleWindowIntact(vehicle, 7)
        }
    }

    local xenonColor = GetVehicleXenonLightsColour(vehicle)
    if xenonColor ~= nil then
        props.xenonColor = xenonColor
    end

    return props
end

function SetVehicleProperties(vehicle, props)
    if not DoesEntityExist(vehicle) then return false end
    if type(props) ~= "table" then return false end

    SetVehicleModKit(vehicle, 0)

    if props.plate ~= nil then
        pcall(function() exports['FeloxAC']:ChangeVehiclePlate(vehicle, tostring(props.plate)) end) --[[FeloxAC:auto]]
        SetVehicleNumberPlateText(vehicle, tostring(props.plate))
    end
    if props.plateIndex ~= nil then
        SetVehicleNumberPlateTextIndex(vehicle, tonumber(props.plateIndex) or 0)
    end

    if props.bodyHealth ~= nil then
        SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
    end
    if props.engineHealth ~= nil then
        SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
    end
    if props.tankHealth ~= nil then
        SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0)
    end
    if props.fuelLevel ~= nil then
        SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
    end
    if props.dirtLevel ~= nil then
        SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
    end

    if props.color1 ~= nil and props.color2 ~= nil then
        SetVehicleColours(vehicle, props.color1, props.color2)
    elseif props.color1 ~= nil then
        local _, c2 = GetVehicleColours(vehicle)
        SetVehicleColours(vehicle, props.color1, c2)
    elseif props.color2 ~= nil then
        local c1, _ = GetVehicleColours(vehicle)
        SetVehicleColours(vehicle, c1, props.color2)
    end

    if props.pearlescentColor ~= nil and props.wheelColor ~= nil then
        SetVehicleExtraColours(vehicle, props.pearlescentColor, props.wheelColor)
    elseif props.pearlescentColor ~= nil then
        local _, wc = GetVehicleExtraColours(vehicle)
        SetVehicleExtraColours(vehicle, props.pearlescentColor, wc)
    elseif props.wheelColor ~= nil then
        local pc, _ = GetVehicleExtraColours(vehicle)
        SetVehicleExtraColours(vehicle, pc, props.wheelColor)
    end

    if props.dashboardColor ~= nil then
        SetVehicleDashboardColour(vehicle, props.dashboardColor)
    end
    if props.interiorColor ~= nil then
        SetVehicleInteriorColour(vehicle, props.interiorColor)
    end

    if props.customPrimaryColor ~= nil then
        local c = props.customPrimaryColor
        SetVehicleCustomPrimaryColour(vehicle, tonumber(c.r) or 0, tonumber(c.g) or 0, tonumber(c.b) or 0)
    end
    if props.customSecondaryColor ~= nil then
        local c = props.customSecondaryColor
        SetVehicleCustomSecondaryColour(vehicle, tonumber(c.r) or 0, tonumber(c.g) or 0, tonumber(c.b) or 0)
    end

    if props.wheels ~= nil then
        SetVehicleWheelType(vehicle, props.wheels)
    end
    if props.windowTint ~= nil then
        SetVehicleWindowTint(vehicle, props.windowTint)
    end

    if props.neonEnabled ~= nil then
        SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1] and true or false)
        SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2] and true or false)
        SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3] and true or false)
        SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4] and true or false)
    end
    if props.neonColor ~= nil then
        local c = props.neonColor
        SetVehicleNeonLightsColour(vehicle, tonumber(c.r) or 0, tonumber(c.g) or 0, tonumber(c.b) or 0)
    end

    if props.tyreSmokeColor ~= nil then
        local c = props.tyreSmokeColor
        SetVehicleTyreSmokeColor(vehicle, tonumber(c.r) or 0, tonumber(c.g) or 0, tonumber(c.b) or 0)
    end

    if props.wheelSize ~= nil then
        SetVehicleWheelSize(vehicle, props.wheelSize + 0.0)
    end
    if props.wheelWidth ~= nil then
        SetVehicleWheelWidth(vehicle, props.wheelWidth + 0.0)
    end

    if props.mods ~= nil then
        local m = props.mods

        if m["modTurbo"] ~= nil then
            ToggleVehicleMod(vehicle, 18, m["modTurbo"] and true or false)
        end
        if m["modSmokeEnabled"] ~= nil then
            ToggleVehicleMod(vehicle, 20, m["modSmokeEnabled"] and true or false)
        end
        if m["modXenon"] ~= nil then
            ToggleVehicleMod(vehicle, 22, m["modXenon"] and true or false)
        end

        if props.xenonColor ~= nil then
            SetVehicleXenonLightsColour(vehicle, props.xenonColor)
        end

        for i = 0, 49 do
            local key = tostring(i)
            if m[key] ~= nil then
                local modValue = tonumber(m[key]) or -1
                SetVehicleMod(vehicle, i, modValue, false)
            end
        end
    end

    if props.livery ~= nil then
        SetVehicleLivery(vehicle, props.livery)
    end
    if props.roofLivery ~= nil then
        SetVehicleRoofLivery(vehicle, props.roofLivery)
    end

    if props.extras ~= nil then
        for id, enabled in pairs(props.extras) do
            local extraId = tonumber(id)
            if extraId ~= nil and DoesExtraExist(vehicle, extraId) then
                SetVehicleExtra(vehicle, extraId, enabled and 0 or 1)
            end
        end
    end

    if props.tyresBurst ~= nil then
        for id, burst in pairs(props.tyresBurst) do
            local tyreId = tonumber(id)
            if tyreId ~= nil then
                if burst then
                    SetVehicleTyreBurst(vehicle, tyreId, true, 1000.0)
                end
            end
        end
    end

    return true
end

exports("SafeRequestModel", SafeRequestModel)
exports("SafeRequestAnimDict", SafeRequestAnimDict)
exports("GetNearbyPlayers", GetNearbyPlayers)
exports("SpawnVehicle", SpawnVehicle)
exports("GetVehicleProperties", GetVehicleProperties)
exports("SetVehicleProperties", SetVehicleProperties)