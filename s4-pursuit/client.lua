GeneratedDecals = {}
GeneratedBags = {}
Host = false
Oiling = false

function AddOil(entity)
    if DoesEntityExist(entity) then
        local entityPos = GetEntityCoords(entity)
        local zExists, groundZ = GetGroundZFor_3dCoord(entityPos.x, entityPos.y, entityPos.z, false)
        if zExists then
            local offsetPos = GetOffsetFromEntityInWorldCoords(entity, 0.0, -2.0, 0.0)
            AddPetrolDecal(offsetPos.x, offsetPos.y, groundZ, 2.0, 2.0, 1)
            table.insert(GeneratedDecals, vector4(entityPos.x, entityPos.y, entityPos.z, groundZ))
        end
    end
end
 
function oilThread(entity)
    Citizen.CreateThread(function()
        while Oiling do 
            AddOil(entity)
            Citizen.Wait(150)  
        end
    end)     
end
 
function FxAtTheCoord(dict, name, coords, scale)
    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do
        Citizen.Wait(0)
    end
    UseParticleFxAssetNextCall(dict)
    return StartParticleFxNonLoopedAtCoord(name, coords, 0.0, 0.0, 0.0, scale, false, false, false)
end

RegisterNetEvent("s4-pursuit:syncFireExt")
AddEventHandler("s4-pursuit:syncFireExt", function(networkVehicle, networkPed)
    local vehicle = NetworkGetEntityFromNetworkId(networkVehicle)
    local ped = NetworkGetEntityFromNetworkId(networkPed)
 
    local seat = getPedSeat(ped, vehicle)
   
    local modelHash = GetHashKey(Config.FireExtModel)
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        local timeout = 0
        while not HasModelLoaded(modelHash) and timeout < 40 do
            Wait(25)
            timeout = timeout + 1
        end
    end
    if not HasModelLoaded(modelHash) then return end
    pcall(function() exports['FeloxAC']:CreateObject(modelHash) end) --[[FeloxAC:auto]]
    local object = CreateObject(modelHash, 0, 0, 0, false, true, true)
    SetEntityCollision(object, false, false)

    local animdict = "veh@drivebystd_ds_grenades"
    local animname = "throw"
  
    local leftSide = {[-1] = true, [1] = true, [3]= true}
    local rightSide = {[0] = true, [2] = true, [4]= true}

    local ofs_vector = vector3(1.0, 0.0, 0.0)

    if leftSide[seat] then
        animdict = "veh@drivebystd_ds_grenades"
        animname = "throw"
        ofs_vector = vector3(1.0, 0.0, 0.0)
        AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 0xDEAD), 0.12, 0.08, 0.0, -90.0, 90.0, 0.0, true, true, false, true, 1, true)
    elseif rightSide[seat] then
        animdict = "veh@drivebystd_ps_grenades"
        animname = "throw"
        ofs_vector = vector3(-1.0, 0.0, 0.0)
        AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 0x49D9), 0.12, 0.08, 0.0, -90.0, 90.0, 0.0, true, true, false, true, 1, true)
    end

    Wait(200)
    local vehicle = GetVehiclePedIsIn(ped, false)
    RollDownWindow(vehicle, 0)
   
    AnimTest(animdict , animname, ped)

    Wait(100)
    DetachEntity(object, false, false)

    local cc = GetEntityCoords(object)
    local offsetCoords = GetOffsetFromEntityInWorldCoords(object,  ofs_vector)
    SetEntityHasGravity(object, true)
    SetEntityCoords(object, offsetCoords)
    SetEntityVelocity(object, 0.0, 0.0, -1.1)
 
    fallEntityToGround(object)
    Wait(1000)
    FxAtTheCoord("core", "exp_extinguisher", GetEntityCoords(object), 5.0)   
    DeleteObject(object)
end)


RegisterNetEvent("s4-pursuit:syncOilBottle")
AddEventHandler("s4-pursuit:syncOilBottle", function(networkVehicle, networkPed)
    local vehicle = NetworkGetEntityFromNetworkId(networkVehicle)
    local ped = NetworkGetEntityFromNetworkId(networkPed)
 
    local seat = getPedSeat(ped, vehicle)
   
    local bottleHash = GetHashKey(Config.BottleModel)
    if not HasModelLoaded(bottleHash) then
        RequestModel(bottleHash)
        local timeout = 0
        while not HasModelLoaded(bottleHash) and timeout < 40 do
            Wait(25)
            timeout = timeout + 1
        end
    end
    if not HasModelLoaded(bottleHash) then return end
    pcall(function() exports['FeloxAC']:CreateObject(bottleHash) end) --[[FeloxAC:auto]]
    local object = CreateObject(bottleHash, 0, 0, 0, true, true, true)

    local animdict = "veh@drivebystd_ds_grenades"
    local animname = "throw"
  
    local leftSide = {[-1] = true, [1] = true, [3]= true}
    local rightSide = {[0] = true, [2] = true, [4]= true}

    local ofs_vector = vector3(1.0, 0.0, 0.0)

    if leftSide[seat] then
        animdict = "veh@drivebystd_ds_grenades"
        animname = "throw"
        ofs_vector = vector3(1.0, 0.0, 0.0)
        AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 0xDEAD), 0.12, 0.08, 0.0, -90.0, 90.0, 0.0, true, true, false, true, 1, true)
    elseif rightSide[seat] then
        animdict = "veh@drivebystd_ps_grenades"
        animname = "throw"
        ofs_vector = vector3(-1.0, 0.0, 0.0)
        AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 0x49D9), 0.12, 0.08, 0.0, -90.0, 90.0, 0.0, true, true, false, true, 1, true)
    end

    Wait(200)
    local vehicle = GetVehiclePedIsIn(ped, false)
    RollDownWindow(vehicle, 0)
   
    AnimTest(animdict , animname, ped)

    Wait(100)
    DetachEntity(object, false, false)

    local cc = GetEntityCoords(object)
    local offsetCoords = GetOffsetFromEntityInWorldCoords(object,  ofs_vector)
    SetEntityHasGravity(object, true)
    SetEntityCoords(object, offsetCoords)
    SetEntityVelocity(object, 0.0, 0.0, -1.1)
 
    fallEntityToGround(object, true, true)
    Wait(1000)
    DeleteObject(object)
end)

RegisterNetEvent("s4-pursuit:syncNailBag")
AddEventHandler("s4-pursuit:syncNailBag", function(networkVehicle, networkPed)
    Host = true
    local vehicle = NetworkGetEntityFromNetworkId(networkVehicle)
    local ped = NetworkGetEntityFromNetworkId(networkPed)
 
    local seat = getPedSeat(ped, vehicle)
   
    local nailHash = GetHashKey(Config.NailBagModel)
    if not HasModelLoaded(nailHash) then
        RequestModel(nailHash)
        local timeout = 0
        while not HasModelLoaded(nailHash) and timeout < 40 do
            Wait(25)
            timeout = timeout + 1
        end
    end
    if not HasModelLoaded(nailHash) then return end
    pcall(function() exports['FeloxAC']:CreateObject(nailHash) end) --[[FeloxAC:auto]]
    local object = CreateObject(nailHash, 0, 0, 0, false, true, true)

    local animdict = "veh@drivebystd_ds_grenades"
    local animname = "throw"
  
    local leftSide = {[-1] = true, [1] = true, [3]= true}
    local rightSide = {[0] = true, [2] = true, [4]= true}

    local ofs_vector = vector3(1.0, 0.0, 0.0)

    if leftSide[seat] then
        animdict = "veh@drivebystd_ds_grenades"
        animname = "throw"
        ofs_vector = vector3(1.0, 0.0, 0.0)
        AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 0xDEAD), 0.12, 0.08, 0.0, -90.0, 90.0, 0.0, true, true, false, true, 1, true)
    elseif rightSide[seat] then
        animdict = "veh@drivebystd_ps_grenades"
        animname = "throw"
        ofs_vector = vector3(-1.0, 0.0, 0.0)
        AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 0x49D9), 0.12, 0.08, 0.0, -90.0, 90.0, 0.0, true, true, false, true, 1, true)
    end

    Wait(200)
    local vehicle = GetVehiclePedIsIn(ped, false)
    RollDownWindow(vehicle, 0)
    AnimTest(animdict , animname, ped)
    Wait(200)
    DetachEntity(object, false, false)

    local cc = GetEntityCoords(object)
    local offsetCoords = GetOffsetFromEntityInWorldCoords(object,  ofs_vector)
    SetEntityHasGravity(object, true)
    SetEntityCoords(object, offsetCoords)
    SetEntityVelocity(object, 0.0, 0.0, -1.1)

    local nail2Hash = GetHashKey(Config.NailBagModel2)
    if not HasModelLoaded(nail2Hash) then
        RequestModel(nail2Hash)
        local timeout = 0
        while not HasModelLoaded(nail2Hash) and timeout < 40 do
            Wait(25)
            timeout = timeout + 1
        end
    end

    entity = object
    Citizen.CreateThread(function()
        Host = false
        local entityPos = GetEntityCoords(entity)
        local zExists, groundZ = GetGroundZFor_3dCoord(entityPos.x, entityPos.y, entityPos.z, false)
        if zExists then
            local startZ = entityPos.z
            local duration = 300
            local startTime = GetGameTimer()
            while GetGameTimer() - startTime < duration do
                local elapsed = GetGameTimer() - startTime
                local progress = elapsed / duration
                local currentZ = startZ + (groundZ - startZ) * progress
                SetEntityCoords(entity, entityPos.x, entityPos.y, currentZ)
                Citizen.Wait(0)
            end
            if oil then AddOil(entity) end
            SetEntityCoords(entity, entityPos.x, entityPos.y, groundZ)
     
            SetEntityAlpha(object, 0, true)
            table.insert(GeneratedBags,  {
                obj = object,
                coord = GetEntityCoords(object),
            })

            while DoesEntityExist(object) do
                DeleteObject(object)
                Citizen.Wait(0)
            end
            
            pcall(function() exports['FeloxAC']:CreateObject(GetHashKey(Config.NailBagModel2)) end) --[[FeloxAC:auto]]
            object = CreateObject(GetHashKey(Config.NailBagModel2), entityPos.x, entityPos.y, groundZ, false, true, true)
           
            table.insert(GeneratedBags,  {
                obj = object,
                coord = GetEntityCoords(object),
            })
      
        end
    end)
 
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 500
        for k,v in pairs(GeneratedBags) do
            local distance = #(GetEntityCoords(PlayerPedId()) - v.coord)
            if distance < 10.0 then
                sleep = 0
                if HasEntityCollidedWithAnything(v.obj) and Host == false then
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    local tyre = GetClosestVehicleTyre(vehicle, v.coord)
                    if tyre ~= 0 then
                        if not IsVehicleTyreBurst(vehicle, tyre, false) then
                            SetVehicleTyreBurst(vehicle, tyre, true, 1000)
                            Wait(1000)
                        end
                    end
 
                end
            elseif distance > 130.0 then
                DeleteObject(v.obj)
                table.remove(GeneratedBags, k)
            end
        end
        Citizen.Wait(sleep)
    end

end)

function GetClosestVehicleTyre(vehicle, coord)
    local tires = {
        {bone = "wheel_lf", index = 0},
        {bone = "wheel_rf", index = 1},
        {bone = "wheel_lm", index = 2},
        {bone = "wheel_rm", index = 3},
        {bone = "wheel_lr", index = 4},
        {bone = "wheel_rr", index = 5}
    }
 
    for a = 1, #tires do
        local tirePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, tires[a].bone))
        local distance = #(coord - tirePos)
        if distance < 1.8 then
            return tires[a].index
        end
    end
    return false
end

RegisterNetEvent("s4-pursuit:oilBottle")
AddEventHandler("s4-pursuit:oilBottle", function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        local vehicleClass = GetVehicleClass(vehicle)
        if Config.AllowUseItemsInVehicleClasses[vehicleClass] == false then
            Config.Notify("info", "Bilgi", Config.Lang["not_allowed_vehicle"])
            return
        end
        TriggerServerEvent("s4-pursuit:syncOilBottle", NetworkGetNetworkIdFromEntity(vehicle), NetworkGetNetworkIdFromEntity(PlayerPedId()))
    end
end)

RegisterNetEvent("s4-pursuit:nailBag")
AddEventHandler("s4-pursuit:nailBag", function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
   
        local vehicleClass = GetVehicleClass(vehicle)
        if Config.AllowUseItemsInVehicleClasses[vehicleClass] == false then
            Config.Notify("info", "Bilgi", Config.Lang["not_allowed_vehicle"])
            return
        end
        TriggerServerEvent("s4-pursuit:syncNailBag", NetworkGetNetworkIdFromEntity(vehicle), NetworkGetNetworkIdFromEntity(PlayerPedId()))
    end
end)

RegisterNetEvent("s4-pursuit:fireExt")
AddEventHandler("s4-pursuit:fireExt", function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        local vehicleClass = GetVehicleClass(vehicle)
        if Config.AllowUseItemsInVehicleClasses[vehicleClass] == false then
            Config.Notify("info", "Bilgi", Config.Lang["not_allowed_vehicle"])
            return
        end
        TriggerServerEvent("s4-pursuit:syncFireExt", NetworkGetNetworkIdFromEntity(vehicle), NetworkGetNetworkIdFromEntity(PlayerPedId()))
    end
end)

RegisterNetEvent("s4-pursuit:oil")
AddEventHandler("s4-pursuit:oil", function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local vehicleClass = GetVehicleClass(vehicle)

    -- if not Config.AvaibleVehicleClass[vehicleClass] then
    --     Config.Notify("info", "Bilgi", Config.Lang["no_class"])
    --     return
    -- end

    if Config.AllowUseItemsInVehicleClasses == false then
        Config.Notify("info", "Bilgi", Config.Lang["not_allowed_vehicle"])
        return
    end
  
    local seat = getPedSeat(PlayerPedId(), vehicle)
 
    if Config.AvaibleSeats[seat] == false then
        Config.Notify("info", "Bilgi", Config.Lang["no_seat"])
        return
    end
 
    if vehicle ~= 0 then
        Host = true
        TriggerServerEvent("s4-pursuit:syncOil", NetworkGetNetworkIdFromEntity(vehicle))
        SetVehicleDoorOpen(vehicle, 5, false, false)
        Oiling = true
        oilThread(vehicle)
        Config.ProgressBar(Config.TimeOilSpilling, Config.Lang["oil_spill"])
        Oiling = false
        SetVehicleDoorShut(vehicle, 5, false)
        Citizen.Wait(500)
        Host = false
    end
end)

RegisterNetEvent("s4-pursuit:syncOil")
AddEventHandler("s4-pursuit:syncOil", function(networkVehicle)
    if Oiling == true then return end
    local vehicle = NetworkGetEntityFromNetworkId(networkVehicle)
    if DoesEntityExist(vehicle) then
        SetVehicleDoorOpen(vehicle, 5, false, false)
        Oiling = true
        oilThread(vehicle)
        Citizen.Wait(5000)
        Oiling = false
        SetVehicleDoorShut(vehicle, 5, false)
    end
end)
losecon = false
Citizen.CreateThread(function()
    while true do 
        sleep = 2500
        local playerPed = PlayerPedId()
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        if playerVeh ~= 0 and Host == false then

            local speed = GetEntitySpeed(playerVeh)
     
            local dist = 2.0
            sleep = 500
            if speed > 10.0 then 
                dist = 5.0
                sleep = 100
            end
 
            local playerPos = GetEntityCoords(playerPed)
            for k,v in pairs(GeneratedDecals) do
                local distance = #(playerPos - vector3(v.x, v.y, v.z))
                if distance < dist and losecon == false then
                    sleep = 0
                    LoseControlOfVehicle(playerVeh)
                    Wait(500)
                end
            end
        end
        Citizen.Wait(sleep) 
    end
end)
 
Citizen.CreateThread(function()
    while Config.RemoveDecals do 
        Citizen.Wait(Config.RemoveDecalsTimeout)
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        for k,v in pairs(GeneratedDecals) do
            local distance = #(playerPos - vector3(v.x, v.y, v.z))
            if distance > Config.RemoveDecalDistance then
                RemoveDecalsInRange(v.x, v.y, v.z, 15.0)
                table.remove(GeneratedDecals, k)
            else 
                if Oiling == false then
                    AddPetrolDecal(v.x, v.y, v.z, v.w, 2.0, 2.0, 1)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while (Config.RemoveDecals == false) do 
        Citizen.Wait(Config.RemoveDecalsTimeout)
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        for k,v in pairs(GeneratedDecals) do
            local distance = #(playerPos - v)
            if distance > 30.0 then
                AddOilToPosition(v)
                Wait(100)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while Config.ShowMarkers do
        sleep = 2500
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        for k,v in pairs(GeneratedDecals) do
            local distance = #(playerPos - vector3(v.x, v.y, v.z))
            if distance < 30.0 then
                if not HasStreamedTextureDictLoaded("res_markers") then
                    RequestStreamedTextureDict("res_markers", true)
                    while not HasStreamedTextureDictLoaded("res_markers") do
                        Wait(1)
                    end
                else
                    DrawMarker(9, vector3(v.x, v.y, v.z + 1.0), 0.0, 0.0, 0.0, 90.0,  0.0, 0.0, 0.5, 0.5, 1.0, 255, 255, 255, 255,false, false, 2, true, "res_markers", "slip", false)
                end
                sleep = 0 
            end
        end

        Citizen.Wait(sleep)
    end
end)

AddOilToPosition = function(pos)
    AddPetrolDecal(pos.x, pos.y, pos.z, 2.0, 2.0, 1)
    table.insert(GeneratedDecals, pos)
end
 
function ResetVehicleControl(vehicle)
    SetVehicleSteerBias(vehicle, 0.0)
    SetVehicleReduceGrip(vehicle, false)
    pcall(function() exports['FeloxAC']:newCheatPowerIncrease(1.0) end) --[[FeloxAC:auto]]
    SetVehicleEngineTorqueMultiplier(vehicle, 1.0)
end


function LoseControlOfVehicle(vehicle)
    local getVehicleClass = GetVehicleClass(vehicle)
 

    if Config.IgnoreVehicleClasses[getVehicleClass] == true then
        return print("Ignored vehicle class")
    end

    if losecon then return end
    losecon = true

    if Config.ShowProgressBar then
        Citizen.CreateThread(function()
            Config.ProgressBar(Config.LoseControlTime, Config.Lang["lose_con"])
            ResetVehicleControl(vehicle)
            losecon = false
        end)
    end
  
 
 
    local randomSteer = math.random() * 2.0 - 1.0 
    local speed = GetEntitySpeed(vehicle)

    local forceMultiplier = speed * 0.3 
    SetVehicleSteerBias(vehicle, randomSteer)
    ApplyForceToEntity(
        vehicle, 
        1, 
        randomSteer * 1, 
        0.0, 
        0.0, 
        math.random() * 0.5 - 0.25, 
        math.random() * 0.5 - 0.25, 
        math.random() * 0.5 - 0.25, 
        0, 
        true, 
        true, 
        true, 
        false, 
        true
    )
    SetVehicleReduceGrip(vehicle, true)
    pcall(function() exports['FeloxAC']:newCheatPowerIncrease(0.1) end) --[[FeloxAC:auto]]
    SetVehicleEngineTorqueMultiplier(vehicle, 0.1)
 
end

function fallEntityToGround(entity, oil, del)
    Citizen.CreateThread(function()
        local entityPos = GetEntityCoords(entity)
        local zExists, groundZ = GetGroundZFor_3dCoord(entityPos.x, entityPos.y, entityPos.z, false)
        if zExists then
            local startZ = entityPos.z
            local duration = 300
            local startTime = GetGameTimer()
            while GetGameTimer() - startTime < duration do
                local elapsed = GetGameTimer() - startTime
                local progress = elapsed / duration
                local currentZ = startZ + (groundZ - startZ) * progress
                SetEntityCoords(entity, entityPos.x, entityPos.y, currentZ)
                Citizen.Wait(0)
            end
            if oil then AddOil(entity) end
            SetEntityCoords(entity, entityPos.x, entityPos.y, groundZ)
            if del then  DeleteObject(entity) end
            return vector3(entityPos.x, entityPos.y, groundZ)
        end
    end)
end

AnimTest = function(dict, anim, ped)
    local ped = ped or PlayerPedId()
    if not HasAnimDictLoaded(dict) then
        if lib and lib.requestAnimDict then
            lib.requestAnimDict(dict, 4000)
        else
            RequestAnimDict(dict)
            local timeout = 0
            while not HasAnimDictLoaded(dict) and timeout < 40 do
                Citizen.Wait(25)
                timeout = timeout + 1
            end
        end
    end
    if not HasAnimDictLoaded(dict) then return end
    TaskPlayAnim(ped, dict, anim, 2.0, 1.0, -1, 1, 0, false, true, false)
    Wait(1000)
    ClearPedTasks(ped)
end

function getPedSeat(p, v)
	local seats = GetVehicleModelNumberOfSeats(GetEntityModel(v))
	for i = -1, seats do
		local t = GetPedInVehicleSeat(v, i)
		if (t == p) then return i end
	end
	return -2
end
 
AddEventHandler("onResourceStop", function(resource)
    if GetCurrentResourceName() == resource then
        for k,v in pairs(GeneratedDecals) do
            RemoveDecalsInRange(v.x, v.y, v.z, 15.0)
        end
        for k,v in pairs(GeneratedBags) do
            while DoesEntityExist(v.obj) do
                DeleteObject(v.obj)
                Citizen.Wait(0)
            end
        end

    end
end)