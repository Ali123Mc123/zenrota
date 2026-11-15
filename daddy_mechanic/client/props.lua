-- Reading and writing a car's look.

Props = {}

function Props.get(vehicle)
    local props = lib.getVehicleProperties(vehicle)
    if not props then return nil end
    props.paintType1 = GetVehicleModColor_1(vehicle)
    props.paintType2 = GetVehicleModColor_2(vehicle)
    local custom, r, g, b = GetVehicleXenonLightsCustomColor(vehicle)
    props.customXenonColor = custom and { r, g, b } or nil
    props.liveryRoof = GetVehicleRoofLivery(vehicle)
    if GetNumVehicleMods(vehicle, 48) <= 0 and GetVehicleLiveryCount(vehicle) > 0 then props.modLivery = props.livery end
    return props
end

function Props.kit(vehicle)
    SetVehicleModKit(vehicle, 0)
    for _ = 1, 15 do
        if GetNumVehicleMods(vehicle, 0) > 0 or GetNumVehicleMods(vehicle, 11) > 0 or GetNumVehicleMods(vehicle, 1) > 0 then return end
        Wait(10)
        SetVehicleModKit(vehicle, 0)
    end
end

local function rgb(v)
    return type(v) == 'table' and v[1] and v[2] and v[3] and v or nil
end

function Props.set(vehicle, props)
    if type(props) ~= 'table' or not DoesEntityExist(vehicle) then return false end
    Props.kit(vehicle)
    lib.setVehicleProperties(vehicle, props)

    local primary, secondary = GetVehicleColours(vehicle)
    local pearl, wheel = GetVehicleExtraColours(vehicle)
    local c1 = type(props.color1) == 'number' and props.color1 or primary
    local c2 = type(props.color2) == 'number' and props.color2 or secondary
    if props.paintType1 then SetVehicleModColor_1(vehicle, props.paintType1, c1, props.pearlescentColor or pearl) end
    if props.paintType2 then SetVehicleModColor_2(vehicle, props.paintType2, c2) end
    local custom1, custom2 = rgb(props.customPrimaryColor) or rgb(props.color1), rgb(props.customSecondaryColor) or rgb(props.color2)
    if custom1 then SetVehicleCustomPrimaryColour(vehicle, custom1[1], custom1[2], custom1[3]) end
    if custom2 then SetVehicleCustomSecondaryColour(vehicle, custom2[1], custom2[2], custom2[3]) end
    if props.paintType1 or props.pearlescentColor or props.wheelColor then
        SetVehicleExtraColours(vehicle, props.pearlescentColor or pearl, props.wheelColor or wheel)
    end

    local xenon = rgb(props.customXenonColor)
    if xenon then SetVehicleXenonLightsCustomColor(vehicle, xenon[1], xenon[2], xenon[3])
    elseif props.xenonColor ~= nil then ClearVehicleXenonLightsCustomColor(vehicle) end

    if props.modLivery and props.modLivery >= 0 then SetVehicleMod(vehicle, 48, props.modLivery, false) end
    local livery = props.livery
    if (not livery or livery < 0) and props.modLivery and props.modLivery >= 0 and GetNumVehicleMods(vehicle, 48) <= 0 then livery = props.modLivery end
    if livery and livery >= 0 then SetVehicleLivery(vehicle, livery) end
    if props.liveryRoof and props.liveryRoof >= 0 then SetVehicleRoofLivery(vehicle, props.liveryRoof) end

    if type(props.extras) == 'table' then
        for id, on in pairs(props.extras) do
            local n = tonumber(id)
            if n and DoesExtraExist(vehicle, n) then SetVehicleExtra(vehicle, n, not (on == true or on == 0)) end
        end
    end
    return true
end

exports('getProps', Props.get)
exports('setProps', Props.set)
exports('getVehicleProperties', Props.get)
exports('setVehicleProperties', Props.set)
