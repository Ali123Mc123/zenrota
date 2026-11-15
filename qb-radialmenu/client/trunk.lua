local lib = lib

local inTrunk = false
local isKidnapped = false
local isKidnapping = false
local cam = nil
local disabledTrunk = {
    [`penetrator`] = "penetrator",
    [`vacca`] = "vacca",
    [`monroe`] = "monroe",
    [`turismor`] = "turismor",
    [`osiris`] = "osiris",
    [`comet`] = "comet",
    [`ardent`] = "ardent",
    [`jester`] = "jester",
    [`nero`] = "nero",
    [`nero2`] = "nero2",
    [`vagner`] = "vagner",
    [`infernus`] = "infernus",
    [`zentorno`] = "zentorno",
    [`comet2`] = "comet2",
    [`comet3`] = "comet3",
    [`comet4`] = "comet4",
    [`bullet`] = "bullet",
}

-- Functions

local function DrawText3Ds(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function getNearestVeh()
    local pos = GetEntityCoords(PlayerPedId())
    local entityWorld = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 20.0, 0.0)

    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10,
        PlayerPedId(), 0)
    local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
    return vehicleHandle
end

local function GetVehicleByPlate(plate)
    if not plate then return nil end
    local cleanPlate = string.gsub(tostring(plate), '^%s*(.-)%s*$', '%1')

    -- 1. Yakındaki araçları hızlı kontrol et (25m)
    local pCoords = GetEntityCoords(PlayerPedId())
    if lib and lib.getNearbyVehicles then
        local nearbyVehs = lib.getNearbyVehicles(pCoords, 25.0, true)
        for i = 1, #nearbyVehs do
            local veh = nearbyVehs[i].vehicle
            if DoesEntityExist(veh) then
                local vPlate = string.gsub(GetVehicleNumberPlateText(veh) or '', '^%s*(.-)%s*$', '%1')
                if vPlate == cleanPlate then
                    return veh
                end
            end
        end
    end

    -- 2. Fallback
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicles) do
        local vPlate = string.gsub(GetVehicleNumberPlateText(vehicle) or '', '^%s*(.-)%s*$', '%1')
        if vPlate == cleanPlate then
            return vehicle
        end
    end
    return nil
end

local function TrunkCam(bool)
    local vehicle = GetEntityAttachedTo(PlayerPedId())
    local drawPos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -5.5, 0.0)
    local vehHeading = GetEntityHeading(vehicle)
    if bool then
        RenderScriptCams(false, false, 0, true, false)
        if DoesCamExist(cam) then
            pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]]
            DestroyCam(cam, false)
        end
        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
        SetCamActive(cam, true)
        SetCamCoord(cam, drawPos.x, drawPos.y, drawPos.z + 2.0)
        SetCamRot(cam, -2.5, 0.0, vehHeading, 2)
        RenderScriptCams(true, false, 0, true, true)
    else
        RenderScriptCams(false, false, 0, true, false)
        if DoesCamExist(cam) then
            pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]]
            DestroyCam(cam, false)
        end
        cam = nil
    end
end

-- Events

RegisterNetEvent('qb-radialmenu:trunk:client:Door', function(plate, door, open)
    local vehicle = GetVehicleByPlate(plate)
    if not vehicle or vehicle == 0 then return end
    if open then
        SetVehicleDoorOpen(vehicle, door, false, false)
    else
        SetVehicleDoorShut(vehicle, door, false)
    end
end)

RegisterNetEvent('qb-kidnapping:client:SetKidnapping', function(bool)
    isKidnapping = bool
end)

RegisterNetEvent('qb-trunk:client:KidnapTrunk', function()
    local player, distance = lib.getClosestPlayer(GetEntityCoords(PlayerPedId()), 2.5) or -1
    if player ~= -1 then
        if isKidnapping then
            local closestVehicle = getNearestVeh()
            if closestVehicle ~= 0 then
                TriggerEvent('police:client:KidnapPlayer')
                TriggerServerEvent("police:server:CuffPlayer", GetPlayerServerId(player), false)
                Wait(50)
                TriggerServerEvent("qb-trunk:server:KidnapTrunk", GetPlayerServerId(player), closestVehicle)
            end
        else
            lib.notify({ description = locale("error.not_kidnapped"), type = 'error' })
        end
    end
end)

RegisterNetEvent('qb-trunk:client:KidnapGetIn', function(veh)
    local ped = PlayerPedId()
    local closestVehicle = veh
    local vehClass = GetVehicleClass(closestVehicle)
    local plate = GetVehicleNumberPlateText(closestVehicle)
    if Config.TrunkClasses[vehClass].allowed then
        local isBusy = lib.callback.await('qb-trunk:server:getTrunkBusy', false, plate)
        if not disabledTrunk[GetEntityModel(closestVehicle)] then
            if not inTrunk then
                if not isBusy then
                    if not isKidnapped then
                        if GetVehicleDoorAngleRatio(closestVehicle, 5) > 0 then
                            local offset = {
                                x = Config.TrunkClasses[vehClass].x,
                                y = Config.TrunkClasses[vehClass].y,
                                z = Config.TrunkClasses[vehClass].z,
                            }
                            lib.requestAnimDict("fin_ext_p1-7")
                            TaskPlayAnim(ped, "fin_ext_p1-7", "cs_devin_dual-7", 8.0, 8.0, -1, 1, 1.0, false, false,
                                false)
                            AttachEntityToEntity(ped, closestVehicle, 0, offset.x, offset.y, offset.z, 0.0, 0.0, 40.0,
                                true, true, true, true, 2, true)
                            TriggerServerEvent('qb-trunk:server:setTrunkBusy', plate, true)
                            inTrunk = true
                            Wait(500)
                            SetVehicleDoorShut(closestVehicle, 5, false)
                            lib.notify({ description = locale("success.entered_trunk"), type = 'success' })
                            TrunkCam(true)
                            isKidnapped = true
                        else
                            lib.notify({ description = locale("error.trunk_closed"), type = 'error' })
                        end
                    else
                        local vehicle = GetEntityAttachedTo(ped)
                        plate = GetVehicleNumberPlateText(vehicle)
                        if GetVehicleDoorAngleRatio(vehicle, 5) > 0 then
                            local vehCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0, -5.0, 0)
                            DetachEntity(ped, true, true)
                            ClearPedTasks(ped)
                            inTrunk = false
                            TriggerServerEvent('qb-trunk:server:setTrunkBusy', plate, false)
                            pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
                            SetEntityCoords(ped, vehCoords.x, vehCoords.y, vehCoords.z, false, false, false, true)
                            SetEntityCollision(PlayerPedId(), true, true)
                            TrunkCam(false)
                        else
                            lib.notify({ description = locale("error.trunk_closed"), type = 'error' })
                        end
                    end
                else
                    lib.notify({ description = locale("error.someone_in_trunk"), type = 'error' })
                end
            else
                lib.notify({ description = locale("error.already_in_trunk"), type = 'error' })
            end
        else
            lib.notify({ description = locale("error.cant_enter_trunk"), type = 'error' })
        end
    else
        lib.notify({ description = locale("error.cant_enter_trunk"), type = 'error' })
    end
end)

RegisterNetEvent('qb-trunk:client:GetIn', function()
    local ped = PlayerPedId()
    local closestVehicle = getNearestVeh()
    if closestVehicle ~= 0 then
        local vehClass = GetVehicleClass(closestVehicle)
        local plate = GetVehicleNumberPlateText(closestVehicle)
        if Config.TrunkClasses[vehClass].allowed then
            local isBusy = lib.callback.await('qb-trunk:server:getTrunkBusy', false, plate)
            if not disabledTrunk[GetEntityModel(closestVehicle)] then
                if not inTrunk then
                    if not isBusy then
                        if GetVehicleDoorAngleRatio(closestVehicle, 5) > 0 then
                            local offset = {
                                x = Config.TrunkClasses[vehClass].x,
                                y = Config.TrunkClasses[vehClass].y,
                                z = Config.TrunkClasses[vehClass].z,
                            }
                            lib.requestAnimDict("fin_ext_p1-7")
                            TaskPlayAnim(ped, "fin_ext_p1-7", "cs_devin_dual-7", 8.0, 8.0, -1, 1, 1.0, false, false,
                                false)
                            AttachEntityToEntity(ped, closestVehicle, 0, offset.x, offset.y, offset.z, 0.0, 0.0, 40.0,
                                true, true, true, true, 2, true)
                            TriggerServerEvent('qb-trunk:server:setTrunkBusy', plate, true)
                            inTrunk = true
                            Wait(500)
                            SetVehicleDoorShut(closestVehicle, 5, false)
                            lib.notify({ description = locale("success.entered_trunk"), type = 'success' })
                            TrunkCam(true)
                        else
                            lib.notify({ description = locale("error.trunk_closed"), type = 'error' })
                        end
                    else
                        lib.notify({ description = locale("error.someone_in_trunk"), type = 'error' })
                    end
                else
                    lib.notify({ description = locale("error.already_in_trunk"), type = 'error' })
                end
            else
                lib.notify({ description = locale("error.cant_enter_trunk"), type = 'error' })
            end
        else
            lib.notify({ description = locale("error.cant_enter_trunk"), type = 'error' })
        end
    else
        lib.notify({ description = locale("error.no_vehicle_found"), type = 'error' })
    end
end)

-- Threads

CreateThread(function()
    while true do
        local sleep = 1000
        if cam then
            local vehicle = GetEntityAttachedTo(PlayerPedId())
            if vehicle ~= 0 then
                sleep = 0
                local drawPos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -5.5, 0)
                local vehHeading = GetEntityHeading(vehicle)
                SetCamRot(cam, -2.5, 0.0, vehHeading, 0.0)
                SetCamCoord(cam, drawPos.x, drawPos.y, drawPos.z + 2)
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if inTrunk then
            if not isKidnapped then
                local ped = PlayerPedId()
                local vehicle = GetEntityAttachedTo(ped)
                if DoesEntityExist(vehicle) and vehicle ~= 0 then
                    local drawPos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.5, 0)
                    local plate = GetVehicleNumberPlateText(vehicle)
                    sleep = 0
                    DrawText3Ds(drawPos.x, drawPos.y, drawPos.z + 0.75, locale("general.get_out_trunk_button"))
                    if IsControlJustPressed(0, 38) then
                        if GetVehicleDoorAngleRatio(vehicle, 5) > 0 then
                            local vehCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0, -5.0, 0)
                            DetachEntity(ped, true, true)
                            ClearPedTasks(ped)
                            inTrunk = false
                            TriggerServerEvent('qb-trunk:server:setTrunkBusy', plate, false)
                            pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
                            SetEntityCoords(ped, vehCoords.x, vehCoords.y, vehCoords.z, false, false, false, true)
                            SetEntityCollision(ped, true, true)
                            TrunkCam(false)
                        else
                            lib.notify({ description = locale("error.trunk_closed"), type = 'error' })
                        end
                        Wait(100)
                    end
                    if GetVehicleDoorAngleRatio(vehicle, 5) > 0 then
                        DrawText3Ds(drawPos.x, drawPos.y, drawPos.z + 0.5, locale("general.close_trunk_button"))
                        if IsControlJustPressed(0, 47) then
                            if not IsVehicleSeatFree(vehicle, -1) then
                                TriggerServerEvent('qb-radialmenu:trunk:server:Door', false, plate, 5)
                            else
                                SetVehicleDoorShut(vehicle, 5, false)
                            end
                            Wait(100)
                        end
                    else
                        DrawText3Ds(drawPos.x, drawPos.y, drawPos.z + 0.5, locale("general.open_trunk_button"))
                        if IsControlJustPressed(0, 47) then
                            if not IsVehicleSeatFree(vehicle, -1) then
                                TriggerServerEvent('qb-radialmenu:trunk:server:Door', true, plate, 5)
                            else
                                SetVehicleDoorOpen(vehicle, 5, false, false)
                            end
                            Wait(100)
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)
