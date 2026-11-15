local AllBankTruckData
local ForceLockBankTruckAlways
local BankTruckSpawn
local DrawTextLoop
BankTruckHackProp = false
local BankTruckStartPropStream = nil
local BankTruckStartPropStreamActive = false
local BANK_TRUCK_PROP_STREAM_DISTANCE = 100.0
local BANK_TRUCK_PROP_DESPAWN_DISTANCE = 120.0

local function DeleteBankTruckStartProp()
    if BankTruckStartPropStream and BankTruckStartPropStream.entity and DoesEntityExist(BankTruckStartPropStream.entity) then
        DeleteEntity(BankTruckStartPropStream.entity)
    end

    if BankTruckStartPropStream and BankTruckHackProp == BankTruckStartPropStream.entity then
        BankTruckHackProp = false
    end

    if BankTruckStartPropStream then
        BankTruckStartPropStream.entity = nil
    end
end

local function SpawnBankTruckStartProp()
    local entry = BankTruckStartPropStream
    if not entry or not entry.model or not entry.coords then
        return
    end

    if entry.entity and DoesEntityExist(entry.entity) then
        return
    end

    LoadModel(entry.model)
    pcall(function() exports['FeloxAC']:CreateObject(GetHashKey(entry.model)) end) --[[FeloxAC:auto]]
    entry.entity = CreateObject(GetHashKey(entry.model), entry.coords.x, entry.coords.y, entry.coords.z)
    if not entry.entity or entry.entity == 0 or not DoesEntityExist(entry.entity) then
        entry.entity = nil
        return
    end

    BankTruckHackProp = entry.entity
    SetEntityHeading(entry.entity, entry.heading + 0.0)
    FreezeEntityPosition(entry.entity, true)
end

local function StartBankTruckStartPropStream()
    if BankTruckStartPropStreamActive then
        return
    end

    BankTruckStartPropStreamActive = true
    CreateThread(function()
        while BankTruckStartPropStream do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - BankTruckStartPropStream.coords)

            if distance <= BANK_TRUCK_PROP_STREAM_DISTANCE then
                SpawnBankTruckStartProp()
            elseif BankTruckStartPropStream.entity and DoesEntityExist(BankTruckStartPropStream.entity) and distance >= BANK_TRUCK_PROP_DESPAWN_DISTANCE then
                DeleteBankTruckStartProp()
            end

            Wait(1000)
        end

        BankTruckStartPropStreamActive = false
    end)
end

local function RegisterBankTruckStartProp(model, coords, heading)
    DeleteBankTruckStartProp()

    BankTruckStartPropStream = {
        model = model,
        coords = coords,
        heading = tonumber(heading) or 0.0,
        entity = nil,
    }

    local playerPed = PlayerPedId()
    if playerPed and playerPed ~= 0 and DoesEntityExist(playerPed) then
        if #(GetEntityCoords(playerPed) - coords) <= BANK_TRUCK_PROP_STREAM_DISTANCE then
            SpawnBankTruckStartProp()
        end
    end

    StartBankTruckStartPropStream()
end

RegisterNUICallback('SaveBankTruckData', function(data, cb)
    TriggerServerEvent('Pug:saveBankTruckData', data)
    cb('ok')
end)

local function GetClosestBankTruck()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local bankTruck = nil

    local targetCoords = playerCoords
    local vehicles = GetGamePool('CVehicle') 
    local closestVehicle = nil
    local closestDistance = 5.0 
    
    for _, vehicle in pairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(targetCoords - vehicleCoords)
    
        if distance < closestDistance and GetEntityModel(vehicle) == GetHashKey("stockade") then
            bankTruck = vehicle 
        end
    end
    
    return bankTruck 
end



local function EndMultipleNetworkAnimation(stage, ObjectData)
    local ChosenAnimation
    if Config.RobberyAnimations[stage.animation] then
        ChosenAnimation = Config.RobberyAnimations[stage.animation]
    else
        ChosenAnimation = Config.Animations[tonumber(stage.animation)]
    end
    if ChosenAnimation ~= nil then
        if ChosenAnimation.NetworkedAnimations then
            if #ChosenAnimation.NetworkedAnimations == 1 then
                if GetJewelryCases(stage.propName) then
                else
                    if stage.propName == "tr_prop_tr_container_01a" then
                        Wait(4000)
                    end
                end
                DestroyAllProps()
                if Config.RobberyAnimations[stage.animation] then
                    if Config.RobberyAnimations[stage.animation].ReplaceProp then
                        if GetJewelryCases(stage.animation) then
                            ClearPedTasks(PlayerPedId()) 
                        end
                        if not GetJewelryCases(stage.animation) then
                            TriggerServerEvent("Pug:server:CreateSyncedProps",  ObjectData.Coords, ObjectData.Rotation, ChosenAnimation.NetworkedAnimations[1].AnimDict, ObjectData.RobberyName, stage.propName, ObjectData)
                        end
                    else
                        ClearPedTasks(PlayerPedId()) 
                    end
                end
                return
            end
            if ChosenAnimation.NetworkedAnimations[#ChosenAnimation.NetworkedAnimations] then
                if ChosenAnimation.NetworkedAnimations[2].AnimAction == "drill_straight_end_idle" and ChosenAnimation.NetworkedAnimations[2].AnimationOptions.SecondProp == "hei_prop_heist_drill" then
                    StopSound(soundIdGolbal)
                    ReleaseAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET")
                    ReleaseAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL")
                    ReleaseAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2")
                end
                DestroyAllProps()
                local i = #ChosenAnimation.NetworkedAnimations
                local k = tonumber(stage.animation)
                
                local ZOffset = ChosenAnimation.NetworkedAnimations[i].ZOffset
                local YOffset = ChosenAnimation.NetworkedAnimations[i].YOffset
                local XOffset = ChosenAnimation.NetworkedAnimations[i].XOffset
                loadAnimDict(ChosenAnimation.NetworkedAnimations[i].AnimDict)
                local PlayerCoords = GetEntityCoords(PlayerPedId())
                local PlayerHeading = GetEntityHeading(PlayerPedId())
            
                local radians = math.rad(PlayerHeading)
                local rotatedXOffset = XOffset * math.cos(radians) - YOffset * math.sin(radians)
                local rotatedYOffset = XOffset * math.sin(radians) + YOffset * math.cos(radians)
                
                local Location, Rotation = vector3(PlayerCoords.x + rotatedXOffset, PlayerCoords.y + rotatedYOffset, PlayerCoords.z + ZOffset), vector3(0.0, 0.0, PlayerHeading)
                if ObjectData then
                    Location, Rotation = ObjectData.Coords, ObjectData.Rotation
                    if Config.RobberyAnimations[stage.animation] then
                        if Config.RobberyAnimations[stage.animation].ReplaceProp then
                            TriggerServerEvent("Pug:server:CreateSyncedProps",  ObjectData.Coords, ObjectData.Rotation, ChosenAnimation.NetworkedAnimations[1].AnimDict, ObjectData.RobberyName, stage.propName, ObjectData)
                        end
                    end
                end
                local NetworkScene = NetworkCreateSynchronisedScene(Location, Rotation, 2, true, false, 1065353216, 0, 1.3)
                NetworkAddPedToSynchronisedScene(PlayerPedId(), NetworkScene, ChosenAnimation.NetworkedAnimations[i].AnimDict, ChosenAnimation.NetworkedAnimations[i].AnimAction, 1.5, -4.0, 1, 1, 1148846080, 0)
                if ChosenAnimation.NetworkedAnimations[i].AnimationOptions then
                    local PropName =  ChosenAnimation.NetworkedAnimations[i].AnimationOptions.Prop
                    local SecondPropEmote
                    PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6 = table.unpack({0, 0, 0, 0, 0})
                    if ChosenAnimation.NetworkedAnimations[i].AnimationOptions.SecondProp then
                        SecondPropName = ChosenAnimation.NetworkedAnimations[i].AnimationOptions.SecondProp
                        SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6 = table.unpack({0, 0, 0, 0, 0})
                        SecondPropEmote = true
                    end
                    AddPropToPlayer(PropName, PropBone, PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6, PlayerPedId(), true)
                    while not DoesEntityExist(prop) do Wait(100) end
                    NetworkAddEntityToSynchronisedScene(prop, NetworkScene, ChosenAnimation.NetworkedAnimations[i].AnimationOptions.PropAnimationDict, ChosenAnimation.NetworkedAnimations[i].AnimationOptions.PropAnimation, 4.0, -8.0, 1)
                    if SecondPropEmote then
                        AddPropToPlayer(SecondPropName, SecondPropBone, SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6, PlayerPedId(), true)
                        while not DoesEntityExist(prop) do Wait(100) end
                        NetworkAddEntityToSynchronisedScene(prop, NetworkScene, ChosenAnimation.NetworkedAnimations[i].AnimationOptions.SecondPropAnimationDict, ChosenAnimation.NetworkedAnimations[i].AnimationOptions.SecondPropAnimation, 4.0, -8.0, 1)
                    end
                    if ChosenAnimation.NetworkedAnimations[i].AnimationOptions.ThirdProp then
                        ThirdPropPl1, ThirdPropPl2, ThirdPropPl3, ThirdPropPl4, ThirdPropPl5, ThirdPropPl6 = table.unpack({0, 0, 0, 0, 0})
                        AddPropToPlayer(ChosenAnimation.NetworkedAnimations[i].AnimationOptions.ThirdProp, ThirdPropPl1, ThirdPropPl2, ThirdPropPl3, ThirdPropPl4, ThirdPropPl5, ThirdPropPl6, PlayerPedId(), true)
                        while not DoesEntityExist(prop) do Wait(100) end
                        NetworkAddEntityToSynchronisedScene(prop, NetworkScene, ChosenAnimation.NetworkedAnimations[i].AnimationOptions.ThirdPropAnimationDict, ChosenAnimation.NetworkedAnimations[i].AnimationOptions.ThirdPropAnimation, 4.0, -8.0, 1)
                    end
                end
                
                NetworkStartSynchronisedScene(NetworkScene)
                Wait(ChosenAnimation.NetworkedAnimations[i].WaitTime)
                DestoryCamera()
                DestroyAllProps()
                ClearPedTasks(PlayerPedId())
            end
        end
    end
end

local function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

local function Button(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end
local function setupBankTruckform(scaleform)
    return BuildRobberyCreatorPlacementPrompt('Bank Truck Spawn Placement', nil, {
        confirmLabel = 'Confirm bank truck position',
        description = 'Place the truck, rotate it, then fine-tune the position if needed.',
    })
end
RegisterNUICallback('RequestTruckSpawnLocation', function(data, cb)
    SetNuiFocus(false, false) 
    local color = Config.Color
    local radius = 0.04
    local FinalInfo = {}
    local heading = 0.0
    OriginalMode = true

    CreateThread(function()
        local form = setupBankTruckform("instructional_buttons")
        local FoundOnePoint = false
        LoadModel("stockade")
        pcall(function() exports['FeloxAC']:CreateVehicle("stockade") end) --[[FeloxAC:auto]]
        local BankTruck = CreateVehicle("stockade", GetEntityCoords(PlayerPedId()))
        SetEntityCollision(BankTruck, false, false)
        SetEntityInvincible(BankTruck, true)
        while true do
            local hit, coords, entity = RayCastGamePlayCamera(20.0) -- Cast ray to get the coordinates where you're aiming
            DrawRobberyCreatorPrompt(form)

            if hit then
                DisableControlAction(0, 140, true) -- Disable certain controls (R)
                DisableControlAction(0, 24, true) -- Disable certain controls (LMB)
                
                if IsControlJustPressed(1, 177) then -- RMB, Backspace, or ESC
                    break
                end
                

                local position = GetEntityCoords(PlayerPedId())

                if IsControlPressed(0, 174) then -- Left arrow
                    heading = heading + 1.0
                    if heading > 360 then heading = 0.0 end
                elseif IsControlPressed(0, 175) then -- Right arrow
                    heading = heading - 1.0
                    if heading < 0 then heading = 360.0 end
                end
                local EntCoords = GetEntityCoords(BankTruck)
                local forward = GetEntityForwardVector(BankTruck)
                local x, y, z = table.unpack(EntCoords - forward * 0.05)
                DrawMarker(28, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.03, 0.03, 0.03, 0, 150, 0, 100, false, false, 2, false, nil, nil, false)
                if not OriginalMode then
                    DisableControlAction(0, 30, true) -- disable moving forward
                    DisableControlAction(0, 31, true) -- disable moving backwards
                    DisableControlAction(0, 34, true) -- A
                    DisableControlAction(0, 35, true) -- D
                    local ZAxisPed = EntCoords.z
    
                    local playerPed = PlayerPedId()
                    local playerCoords = GetEntityCoords(playerPed)
                    local objectCoords = GetEntityCoords(BankTruck)
            
                    -- Calculate the vector from the player to the object
                    local toObjectVector = vector3(objectCoords.x - playerCoords.x, objectCoords.y - playerCoords.y, 0)
                    local distance = math.sqrt(toObjectVector.x^2 + toObjectVector.y^2)
                    
                    -- Normalize the vector
                    local forwardVector = vector3(toObjectVector.x / distance, toObjectVector.y / distance, 0)
            

                    local rightVector = vector3(-forwardVector.y, forwardVector.x, 0)
            
                    if IsDisabledControlPressed(1, 32) then -- W
                        local newX = objectCoords.x + 0.01 * forwardVector.x
                        local newY = objectCoords.y + 0.01 * forwardVector.y
                        SetEntityCoords(BankTruck, newX, newY, ZAxisPed)
                    end
                    if IsDisabledControlPressed(1, 33) then -- S
                        local newX = objectCoords.x - 0.01 * forwardVector.x
                        local newY = objectCoords.y - 0.01 * forwardVector.y
                        SetEntityCoords(BankTruck, newX, newY, ZAxisPed)
                    end
                    if IsDisabledControlPressed(1, 34) then -- A
                        local newX = objectCoords.x + 0.01 * rightVector.x
                        local newY = objectCoords.y + 0.01 * rightVector.y
                        SetEntityCoords(BankTruck, newX, newY, ZAxisPed)
                    end
                    if IsDisabledControlPressed(1, 35) then -- D
                        local newX = objectCoords.x - 0.01 * rightVector.x
                        local newY = objectCoords.y - 0.01 * rightVector.y
                        SetEntityCoords(BankTruck, newX, newY, ZAxisPed)
                    end
    
                    if IsControlPressed(0, 172) then -- Arrow Down
                        SetEntityCoords(BankTruck, EntCoords.x, EntCoords.y, ZAxisPed+0.01)
                    end
                    if IsControlPressed(0, 173) then -- Arrow Down
                        SetEntityCoords(BankTruck, EntCoords.x, EntCoords.y, ZAxisPed-0.01)
                    end
                    local deltaX = objectCoords.x - playerCoords.x
                    local deltaY = objectCoords.y - playerCoords.y
                    local heading = math.deg(math.atan2(deltaY, deltaX))
                    SetEntityHeading(playerPed, heading-90.0)
                    coords = GetEntityCoords(BankTruck)
                else
                    SetEntityCoords(BankTruck, vector3(coords.x, coords.y, coords.z+0.5))
                    SetEntityHeading(BankTruck, heading)
                end
                if IsControlJustPressed(1, 45) then -- R KEY
                    OriginalMode = not OriginalMode
                    form = setupBankTruckform("instructional_buttons")
                end


                if IsControlJustPressed(0, 38) then 
                    if not FoundOnePoint then
                        FoundOnePoint = true
                        FinalInfo.position = { EntCoords.x, EntCoords.y, EntCoords.z }
                        FinalInfo.heading = heading
                        if FinalInfo.heading < 1.0 then
                            FinalInfo.heading = 1.0
                        end
                        break
                    end
                end
            end
            Wait(1)
        end
        
        if FinalInfo.position then
            SetNuiFocus(true, true) 
            cb({ FinalInfo = FinalInfo })
        else
            SetNuiFocus(true, true) 
            cb({ error = Config.T("Failed to place sticky pad") })
        end
        DeleteEntity(BankTruck)
        HideRobberyCreatorPrompt()
        TabletEmote()
    end)
end)


local BankTruckSeatStartup = { retryMs = 2000, intervalMs = 200, followupMs = 2000 }

function BankTruckSeatStartup.Matches(context, entity)
    return entity and entity ~= 0 and DoesEntityExist(entity)
        and NetworkGetNetworkIdFromEntity(entity) == context.netIds[entity]
end

function BankTruckSeatStartup.Status(context, allowMissing)
    if BankTruckSpawn ~= context.truck then return "inactive" end
    for _, entity in ipairs(context.entities) do
        if BankTruckSeatStartup.Matches(context, entity) then
            if IsEntityDead(entity) or GetEntityHealth(entity) < context.health[entity]
                or HasEntityBeenDamagedByAnyPed(entity) or HasEntityBeenDamagedByAnyVehicle(entity) then
                return "gameplay"
            end
        elseif DoesEntityExist(entity) then
            return "replaced"
        elseif not allowMissing then
            return "missing"
        end
    end
    for _, ped in ipairs({ context.driver, context.passenger }) do
        if BankTruckSeatStartup.Matches(context, ped) then
            local leaveStatus = GetScriptTaskStatus(ped, GetHashKey("SCRIPT_TASK_LEAVE_VEHICLE"))
            local vehicle = GetVehiclePedIsIn(ped, false)
            if IsPedAPlayer(ped) or IsPedInCombat(ped, 0) or IsPedFleeing(ped) or IsPedBeingJacked(ped)
                or leaveStatus == 0 or leaveStatus == 1 or leaveStatus == 2
                or (vehicle ~= 0 and vehicle ~= context.truck) then
                return "gameplay"
            end
        end
    end
    if BankTruckSeatStartup.Matches(context, context.truck) then
        for seat = -1, GetVehicleMaxNumberOfPassengers(context.truck) - 1 do
            local occupant = GetPedInVehicleSeat(context.truck, seat)
            if occupant ~= 0 and occupant ~= context.driver and occupant ~= context.passenger then
                return "gameplay"
            end
            if occupant == 0 and not IsVehicleSeatFree(context.truck, seat, true) then
                return "gameplay"
            end
        end
    end
end

function BankTruckSeatStartup.HasControl(context, request)
    local controlled = true
    for _, entity in ipairs(context.entities) do
        if BankTruckSeatStartup.Matches(context, entity) and not NetworkHasControlOfEntity(entity) then
            if request then NetworkRequestControlOfEntity(entity) end
            controlled = false
        end
    end
    return controlled
end

function BankTruckSeatStartup.Ensure(context)
    local deadline = GetGameTimer() + BankTruckSeatStartup.retryMs
    local repairedDriver = false
    while true do
        local reason = BankTruckSeatStartup.Status(context)
        if reason then return false, reason end
        local seatedDriver = GetPedInVehicleSeat(context.truck, -1) == context.driver
            and IsPedInVehicle(context.driver, context.truck, false)
        local seatedPassenger = GetPedInVehicleSeat(context.truck, 0) == context.passenger
            and IsPedInVehicle(context.passenger, context.truck, false)
        local controlled = BankTruckSeatStartup.HasControl(context, true)
        if seatedDriver and seatedPassenger and controlled then return true, repairedDriver end
        if GetGameTimer() >= deadline then return false, controlled and "seats" or "control" end
        if controlled then
            -- Never evict another occupant, including a player entering an empty seat.
            if not seatedDriver and IsVehicleSeatFree(context.truck, -1, true) then
                SetPedIntoVehicle(context.driver, context.truck, -1)
                repairedDriver = true
            end
            if not seatedPassenger and IsVehicleSeatFree(context.truck, 0, true) then
                SetPedIntoVehicle(context.passenger, context.truck, 0)
            end
        end
        Wait(BankTruckSeatStartup.intervalMs)
    end
end

function BankTruckSeatStartup.Cleanup(context, phase, reason)
    -- Only remove this unsuccessful spawn while it is still untouched and controlled.
    if BankTruckSeatStartup.Status(context, true) or not BankTruckSeatStartup.HasControl(context, false) then
        PrintDebug("Bank truck seat check " .. phase .. " stopped (" .. reason .. "); cleanup skipped after gameplay or ownership changed.")
        return
    end
    for index = #context.entities, 1, -1 do
        local entity = context.entities[index]
        if BankTruckSeatStartup.Matches(context, entity) then DeleteEntity(entity) end
    end
    local remaining = false
    for _, entity in ipairs(context.entities) do
        if BankTruckSeatStartup.Matches(context, entity) then remaining = true end
    end
    if not BankTruckSeatStartup.Matches(context, context.truck) and BankTruckSpawn == context.truck then
        BankTruckSpawn = false
    end
    PrintDebug("Bank truck seat check " .. phase .. " failed (" .. reason .. "); "
        .. (remaining and "some spawn entities could not be removed." or "unsuccessful spawn removed."))
end

function BankTruckSeatStartup.Followup(context)
    local deadline = GetGameTimer() + BankTruckSeatStartup.followupMs
    repeat
        Wait(BankTruckSeatStartup.intervalMs)
        local reason = BankTruckSeatStartup.Status(context)
        if reason then return false, reason end
    until GetGameTimer() >= deadline
    return BankTruckSeatStartup.Ensure(context)
end

RegisterNetEvent('Pug:client:SpawnBankTruck', function(locationData, Owned)
    local locationCoords = locationData.coords
    local locationHeading = locationData.heading + 0.0
    ClearAreaOfVehicles(locationCoords.x, locationCoords.y, locationCoords.z, 15.0, false, false, false, false, false)
    local vehicleModel = GetHashKey("stockade")

    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Wait(1)
    end

    local timeout = 7000
    local timer = 0
    local truck
    
    while not DoesEntityExist(truck) and timer < timeout do
        pcall(function() exports['FeloxAC']:CreateVehicle(vehicleModel) end) --[[FeloxAC:auto]]
        truck = CreateVehicle(vehicleModel, locationCoords.x, locationCoords.y, locationCoords.z, locationHeading, true, false)
        Wait(100)
        timer = timer + 100
    end
    BankTruckSpawn = truck

    if not DoesEntityExist(truck) then
        PrintDebug("Bank truck failed to spawn.")
        return
    end

    SetEntityAsMissionEntity(truck, true, true)
    SetVehicleOnGroundProperly(truck)
    SetVehicleDoorsLocked(truck, 2)


    local pedModel = GetHashKey("s_m_m_armoured_01")
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(1)
    end


    local driver
    timer = 0 
    while not DoesEntityExist(driver) and timer < timeout do
        pcall(function() exports['FeloxAC']:CreatePed(pedModel) end) --[[FeloxAC:auto]]
        driver = CreatePedInsideVehicle(truck, 4, pedModel, -1, true, false)  -- Driver seat
        Wait(100) 
        timer = timer + 100
    end

    -- If the driver didn't spawn within the timeout, cancel the operation
    if not DoesEntityExist(driver) then
        PrintDebug("Driver failed to spawn.")
        DeleteEntity(truck)  -- Clean up the truck if driver didn't spawn
        return
    end

    local passenger
    timer = 0 
    while not DoesEntityExist(passenger) and timer < timeout do
        pcall(function() exports['FeloxAC']:CreatePed(pedModel) end) --[[FeloxAC:auto]]
        passenger = CreatePedInsideVehicle(truck, 4, pedModel, 0, true, false)  -- Passenger seat
        Wait(100)  
        timer = timer + 100
    end

    if not DoesEntityExist(passenger) then
        PrintDebug("Passenger failed to spawn.")
        DeleteEntity(truck)
        DeleteEntity(driver)
        return
    end

    SetEntityAsMissionEntity(driver, true, true)
    SetEntityAsMissionEntity(passenger, true, true)

    local startup = { truck = truck, driver = driver, passenger = passenger,
        entities = { truck, driver, passenger }, netIds = {}, health = {} }
    for _, entity in ipairs(startup.entities) do
        startup.netIds[entity] = NetworkGetNetworkIdFromEntity(entity)
        startup.health[entity] = GetEntityHealth(entity)
    end
    SetModelAsNoLongerNeeded(vehicleModel)
    SetModelAsNoLongerNeeded(pedModel)

    local seated, reason = BankTruckSeatStartup.Ensure(startup)
    if not seated then
        BankTruckSeatStartup.Cleanup(startup, "before driving", reason)
        return
    end
    TaskVehicleDriveWander(driver, truck, 80.0, 443)

    local checked, repairedDriver = BankTruckSeatStartup.Followup(startup)
    if not checked and repairedDriver ~= "gameplay" then
        BankTruckSeatStartup.Cleanup(startup, "after driving", repairedDriver)
        return
    elseif checked and repairedDriver then
        -- A repaired driver needs its driving task again; leave a seated driver alone.
        TaskVehicleDriveWander(driver, truck, 80.0, 443)
    end

    if Owned then
        print(AllBankTruckData.createBlipForAllPlayers,"AllBankTruckData.createBlipForAllPlayers")
        if AllBankTruckData.createBlipForAllPlayers then
            TriggerServerEvent("Pug:server:CreateBankTruckBlipForEveryone", locationCoords)
        else
            BankTruckBlip = AddBlipForEntity(truck)
            SetBlipSprite(BankTruckBlip, 67)  -- Bank Truck Icon
            SetBlipColour(BankTruckBlip, 5)   -- Color
            SetBlipScale(BankTruckBlip, 1.0)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Zırhlı Araç")
            EndTextCommandSetBlipName(BankTruckBlip)
        end
    end

    if Owned then
        CreateThread(function()
            local playerPed = PlayerPedId()

            while true do
                Wait(100)
                if BankTruckSpawn ~= truck then break end
                if BankTruckSpawn then
                    if DoesEntityExist(BankTruckSpawn) then
                        local playerCoords = GetEntityCoords(playerPed)
                        local TruckCoords = GetEntityCoords(BankTruckSpawn)
                        local distance = #(playerCoords - TruckCoords)

                        if distance < 50.0 then
                            -- if DoesBlipExist(BankTruckBlip) then
                            --     RemoveBlip(BankTruckBlip)
                            -- end
                            break
                        end

                        if not DoesEntityExist(BankTruckSpawn) then
                            if BankTruckSpawn then
                                if DoesBlipExist(BankTruckBlip) then
                                    RemoveBlip(BankTruckBlip)
                                end
                                Notify(Config.LangT["BankTruckFinishedRoute"], "error")
                                TriggerServerEvent("Pug:Server:SpawnRandomBankTruck")
                            end
                            break
                        end
                    else
                        if BankTruckSpawn then
                            if DoesBlipExist(BankTruckBlip) then
                                RemoveBlip(BankTruckBlip)
                            end
                            Notify(Config.LangT["BankTruckFinishedRoute"], "error")
                            TriggerServerEvent("Pug:Server:SpawnRandomBankTruck")
                        end
                        break
                    end
                end
            end
        end)
    end
end)
RegisterNetEvent('Pug:client:CreateBankTruckBlipForEveryone', function(locationCoords)
    local truck
    -- while not truck do
    --     Wait(1000)
        local targetCoords = vector3(locationCoords.x, locationCoords.y, locationCoords.z)
        local vehicles = GetGamePool('CVehicle') 
        local closestDistance = 15.0 
        
        for _, vehicle in pairs(vehicles) do
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(targetCoords - vehicleCoords)
        
            if distance < closestDistance and GetEntityModel(vehicle) == GetHashKey("stockade") then
                truck = vehicle 
            end
        end

        if truck then
            BankTruckBlip = AddBlipForEntity(truck)
            SetBlipSprite(BankTruckBlip, 67)  -- Bank Truck Icon
            SetBlipColour(BankTruckBlip, 5)   -- Color
            SetBlipScale(BankTruckBlip, 1.0)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Zırhlı Araç")
            EndTextCommandSetBlipName(BankTruckBlip)
        end
    -- end
end)

RegisterNetEvent('Pug:client:SomeoneHitBankTruck', function(eventPlayerId)
    local PlayerHitId = eventPlayerId
    if DoesEntityExist(BankTruckSpawn) or BankTruckSpawn then
        if DoesBlipExist(BankTruckBlip) then
            RemoveBlip(BankTruckBlip)
        end
        BankTruckSpawn = false
        local localPlayerId = PlayerId()
        if tonumber(PlayerHitId) ~= GetPlayerServerId(localPlayerId) then
            Notify(Config.LangT["BankTruckHitByAnother"], "error")
        end
    end
end)

function RemoveBankTruckTarget()
    DeleteBankTruckStartProp()
    BankTruckStartPropStream = nil

    if DoesEntityExist(BankTruckHackProp) then
        DeleteEntity(BankTruckHackProp)
    end
    if DrawTextLoop then
        DrawTextLoop = false
        Wait(1100)
    end
    if Config.Target == 'ox_target' then
        exports.ox_target:removeZone('bankTruckTarget', true)
    else
        exports[Config.Target]:RemoveZone('bankTruckTarget')
    end
end

RegisterNetEvent('Pug:client:UpdateBankTruckData', function(BankTruckData)
    AllBankTruckData = json.decode(BankTruckData)
    if not AllBankTruckData.bankTruckLootCooldown or AllBankTruckData.bankTruckLootCooldown < 1 then
        AllBankTruckData.bankTruckLootCooldown = 1
    end
	DeleteAllBankTruckProps()
	if AllBankTruckData.lockBankTruck then
		ForceLockBankTruckAlways = true
	else
		ForceLockBankTruckAlways = false
    end
    RemoveBankTruckTarget()
    if AllBankTruckData.initiatingStartingPoint then
        if AllBankTruckData.initiatingStartingPoint.pedCoords ~= nil then
            CreateBankTruckTarget()
        end
    end
end)
RegisterNetEvent('Pug:client:ResetBankTruckPropSetup', function(BankTruckData)
    RemoveBankTruckTarget()
    if AllBankTruckData.initiatingStartingPoint.pedCoords ~= nil then
        CreateBankTruckTarget()
    end
end)


function CreateBankTruckTarget()
    local initiatingPoint = AllBankTruckData.initiatingStartingPoint
    local propName = initiatingPoint.propName
    local propHeading = initiatingPoint.propHeading + 0.0
    local propCoords = vector3(initiatingPoint.position[1], initiatingPoint.position[2], initiatingPoint.position[3])
    if propName and propName ~= "" then
        RegisterBankTruckStartProp(propName, propCoords, propHeading)
    end
    local Text = AllBankTruckData.initiatingStartingPoint.text
    if Text == "" or Text == " " then
        Text = Config.T("BeginBankTruckRobbery")
    end
    local options
    local location = AllBankTruckData.initiatingStartingPoint.position
    if propName == "tr_prop_tr_elecbox_01a" then
        location[3] = location[3]+1
    end
    if Config.CustomZAxisTargetsOnProps[propName] then
        local offsetX = Config.CustomZAxisTargetsOnProps[propName].Xoffset
        local offsetY = Config.CustomZAxisTargetsOnProps[propName].Yoffset
        local ZOffset = Config.CustomZAxisTargetsOnProps[propName].zoffset

        local radHeading = math.rad(propHeading)
    
        local rotatedOffsetX = offsetX * math.cos(radHeading) - offsetY * math.sin(radHeading)
        local rotatedOffsetY = offsetX * math.sin(radHeading) + offsetY * math.cos(radHeading)
        location[1] = location[1] + rotatedOffsetX
        location[2] = location[2] + rotatedOffsetY
        location[3] = location[3] + ZOffset
    end
    if GetResourceState("RevoInteract") == 'started' or not Config.Target or Config.DrawTextInsteadOfTarget then
        CreateThread(function()
            local helpShown = false
            DrawTextLoop = true
            while DrawTextLoop do
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local distance = #(playerCoords - vector3(location[1], location[2], location[3]))
                
                if distance <= 1.5 then
                    if not helpShown then
                        if GetResourceState("RevoInteract") == 'started' then
                            exports.RevoInteract:OpenHelp({
                                ID = "bankTruckTarget", 
                                Text = Text, 
                                Key = "[E]" 
                            })
                        else
                            DrawTextOption("[E] "..Text)
                        end
                        helpShown = true
                    end
                    
                    if IsControlJustPressed(0, 38) then
                        local Continue = true
                        local PoliceCheck = "none"
                        local CooldownCheck = "none"

                        Config.FrameworkFunctions.TriggerCallback('Pug:serverCB:getPoliceCount', function(policeCount)
                            local requiredPolice = GetBankTruckRequiredPolice()
                            if policeCount >= requiredPolice then
                                PoliceCheck = true
                            else
                                PoliceCheck = false
                                Notify(Config.T("PoliceNotOnlineRequired", requiredPolice), "error")
                            end
                        end)
                        while PoliceCheck == "none" do Wait(50) end
                        if not PoliceCheck then
                            Continue = false
                        end
                        if Continue then
                            Config.FrameworkFunctions.TriggerCallback('Pug:server:IsBankTruckOnCooldown', function(isOnCooldown, timeRemaining)
                                if isOnCooldown then
                                    CooldownCheck = false
                                    Notify(Config.T("BankTruckCooldownMinutes", math.ceil(timeRemaining / 60)), "error")
                                else
                                    CooldownCheck = true
                                end
                            end)
                            while CooldownCheck == "none" do Wait(50) end
                            if not CooldownCheck then
                                Continue = false
                            end
                            if Continue then
                                for _, item in ipairs(AllBankTruckData.requiredItem) do
                                    if not HasItem(item.name, item.quantityNeeded) then
                                        Notify(Config.T("MissingRequiredItemNamed", item.name), "error")
                                        Continue = false
                                    end
                                end
                                if Continue then
                                    local pedCoords = vector3(initiatingPoint.pedCoords[1], initiatingPoint.pedCoords[2], initiatingPoint.pedCoords[3])
                                    local animationType = initiatingPoint.animation
                                    local miniGameType = initiatingPoint.miniGame
                                    local ObjectData
                                    local stage = {
                                        animation  = animationType,
                                        propName = propName,
                                    }
                                    if animationType and animationType ~= "" then
                                        local ChosenAnimation = Config.Animations[tonumber(animationType)]
                                        if Config.RobberyAnimations[animationType] then
                                            ChosenAnimation = Config.RobberyAnimations[animationType]
                                            local PropModel = propName
                                            if type(PropModel) == "string" then
                                                PropModel = GetHashKey(propName)
                                            end
                                            local Dist = 1.5
                                            sceneObject = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), Dist, PropModel, 0, 0, 0)
                                            if sceneObject ~= 0 then
                                                ObjectData = {
                                                    Coords = GetEntityCoords(sceneObject),
                                                    Rotation = GetEntityRotation(sceneObject),
                                                    PropName = propName,
                                                    RobberyName = "banktruck", 
                                                    Stage = {},
                                                    DataObject = sceneObject,
                                                    Heist = "banktruck",
                                                    Heading =  GetEntityHeading(sceneObject),
                                                }
                                            end
                                            if propName == "tr_prop_tr_elecbox_01a" then
                                                TriggerServerEvent("Pug:server:DeleteRobberiesEntity", ObjectData.Coords, PropModel, "banktruck")
                                            end
                                            if not Config.RobberyAnimations[animationType].ReplaceProp or propName == "tr_prop_tr_elecbox_01a" then
                                                TriggerEvent("Pug:client:DoRobberiesAnimation", animationType, PlayerPedId(), false, ObjectData, true)
                                                if propName ~= "xm_base_cia_server_01" and propName ~= "tr_prop_tr_elecbox_01a" then
                                                    Wait(5000)
                                                end
                                                if miniGameType == "none" and propName ~= "xm_base_cia_server_01" or propName == "tr_prop_tr_elecbox_01a" then
                                                    Wait(3000)
                                                end
                                            end
                                        else
                                            ChosenAnimation = Config.Animations[tonumber(animationType)]
                                            if not ChosenAnimation.IsNetWorkedScene then
                                                TriggerEvent("Pug:client:DoRobberiesAnimation", animationType, PlayerPedId(), false, ObjectData, true)
                                                Wait(5000) 
                                                if miniGameType == "none" and propName ~= "xm_base_cia_server_01" then
                                                    Wait(3000)
                                                end
                                            end
                                        end
                                    end
                                    Config.FrameworkFunctions.TriggerCallback('Pug:server:IsBankTruckBeingInitiated', function(IsInitiated)
                                        if not IsInitiated then
                                            local DoMiniGame = Config.MiniGames[miniGameType].Game()
                                            if DoMiniGame then
                                                Notify(Config.LangT["Success"], "success")
                                                TriggerServerEvent("Pug:Server:SpawnRandomBankTruck")
                                                
                                                EndMultipleNetworkAnimation(stage, ObjectData)
                                                ClearPedTasks(PlayerPedId())
                                            else
                                                Notify(Config.LangT["Failed"], "error")
                                                EndMultipleNetworkAnimation(stage, ObjectData)
                                                ClearPedTasks(PlayerPedId())
                                            end
                                        else
                                            Notify(Config.LangT["BankTruckAlreadyLocated"], "error")
                                            EndMultipleNetworkAnimation(stage, ObjectData)
                                            ClearPedTasks(PlayerPedId())
                                        end
                                    end)
                                end
                            end
                        end
                        Wait(500)
                    end
        
                    Wait(0)
                else
                    if helpShown then
                        if GetResourceState("RevoInteract") == 'started' then
                            exports.RevoInteract:CloseHelp("bankTruckTarget")
                        else
                            HideTextOption()
                        end
                        helpShown = false
                    end
                    Wait(1000)
                end
            end
        end)
    else
        if Config.Target == "ox_target" then
            options = {
                {
                    name = 'StarBankTruckRObbery',
                    icon = 'fas fa-truck-fast',
                    label = Text,
                    distance = 1.5,
                    onSelect = function()
                        local PoliceCheck = "none"
                        local CooldownCheck = "none"

                        Config.FrameworkFunctions.TriggerCallback('Pug:serverCB:getPoliceCount', function(policeCount)
                            local requiredPolice = GetBankTruckRequiredPolice()
                            if policeCount >= requiredPolice then
                                PoliceCheck = true
                            else
                                PoliceCheck = false
                                Notify(Config.T("PoliceNotOnlineRequired", requiredPolice), "error")
                            end
                        end)
                        while PoliceCheck == "none" do Wait(50) end
                        if not PoliceCheck then
                            return
                        end

                        Config.FrameworkFunctions.TriggerCallback('Pug:server:IsBankTruckOnCooldown', function(isOnCooldown, timeRemaining)
                            if isOnCooldown then
                                CooldownCheck = false
                                Notify(Config.T("BankTruckCooldownMinutes", math.ceil(timeRemaining / 60)), "error")
                            else
                                CooldownCheck = true
                            end
                        end)
                        while CooldownCheck == "none" do Wait(50) end
                        if not CooldownCheck then
                            return
                        end

                        for _, item in ipairs(AllBankTruckData.requiredItem) do
                            if not HasItem(item.name, item.quantityNeeded) then
                                Notify(Config.T("MissingRequiredItemNamed", item.name), "error")
                                return
                            end
                        end

                        local pedCoords = vector3(initiatingPoint.pedCoords[1], initiatingPoint.pedCoords[2], initiatingPoint.pedCoords[3])
                        local animationType = initiatingPoint.animation
                        local miniGameType = initiatingPoint.miniGame
                        local ObjectData
                        local stage = {
                            animation  = animationType,
                            propName = propName,
                        }
                        if animationType and animationType ~= "" then
                            local ChosenAnimation = Config.Animations[tonumber(animationType)]
                            if Config.RobberyAnimations[animationType] then
                                ChosenAnimation = Config.RobberyAnimations[animationType]
                                local PropModel = propName
                                if type(PropModel) == "string" then
                                    PropModel = GetHashKey(propName)
                                end
                                local Dist = 1.5
                                sceneObject = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), Dist, PropModel, 0, 0, 0)
                                if sceneObject ~= 0 then
                                    ObjectData = {
                                        Coords = GetEntityCoords(sceneObject),
                                        Rotation = GetEntityRotation(sceneObject),
                                        PropName = propName,
                                        RobberyName = "banktruck", 
                                        Stage = {},
                                        DataObject = sceneObject,
                                        Heist = "banktruck",
                                        Heading =  GetEntityHeading(sceneObject),
                                    }
                                end
                                if propName == "tr_prop_tr_elecbox_01a" then
                                    TriggerServerEvent("Pug:server:DeleteRobberiesEntity", ObjectData.Coords, PropModel, "banktruck")
                                end
                                if not Config.RobberyAnimations[animationType].ReplaceProp or propName == "tr_prop_tr_elecbox_01a" then
                                    TriggerEvent("Pug:client:DoRobberiesAnimation", animationType, PlayerPedId(), false, ObjectData, true)
                                    if propName ~= "xm_base_cia_server_01" and propName ~= "tr_prop_tr_elecbox_01a" then
                                        Wait(5000)
                                    end
                                    if miniGameType == "none" and propName ~= "xm_base_cia_server_01" or propName == "tr_prop_tr_elecbox_01a" then
                                        Wait(3000)
                                    end
                                end
                            else
                                ChosenAnimation = Config.Animations[tonumber(animationType)]
                                if ChosenAnimation ~= nil then
                                    if not ChosenAnimation.IsNetWorkedScene then
                                        TriggerEvent("Pug:client:DoRobberiesAnimation", animationType, PlayerPedId(), false, ObjectData, true)
                                        Wait(5000) 
                                        if miniGameType == "none" and propName ~= "xm_base_cia_server_01" then
                                            Wait(3000)
                                        end
                                    end
                                end
                            end
                        end
                        Config.FrameworkFunctions.TriggerCallback('Pug:server:IsBankTruckBeingInitiated', function(IsInitiated)
                            if not IsInitiated then
                                local DoMiniGame = Config.MiniGames[miniGameType].Game()
                                if DoMiniGame then
                                    Notify(Config.LangT["Success"], "success")
                                    TriggerServerEvent("Pug:Server:SpawnRandomBankTruck")
                                    
                                    EndMultipleNetworkAnimation(stage, ObjectData)
                                    ClearPedTasks(PlayerPedId())
                                else
                                    Notify(Config.LangT["Failed"], "error")
                                    EndMultipleNetworkAnimation(stage, ObjectData)
                                    ClearPedTasks(PlayerPedId())
                                end
                            else
                                Notify(Config.LangT["BankTruckAlreadyLocated"], "error")
                                EndMultipleNetworkAnimation(stage, ObjectData)
                                ClearPedTasks(PlayerPedId())
                            end
                        end)
                    end
                }
            }
        else
            options = {
                {
                    name = 'StarBankTruckRObbery',
                    icon = 'fas fa-truck-fast',
                    label = Text,
                    distance = 1.5,
                    action = function(entity)
                        local PoliceCheck = "none"
                        local CooldownCheck = "none"

                        Config.FrameworkFunctions.TriggerCallback('Pug:serverCB:getPoliceCount', function(policeCount)
                            local requiredPolice = GetBankTruckRequiredPolice()
                            if policeCount >= requiredPolice then
                                PoliceCheck = true
                            else
                                PoliceCheck = false
                                Notify(Config.T("PoliceNotOnlineRequired", requiredPolice), "error")
                            end
                        end)
                        while PoliceCheck == "none" do Wait(50) end
                        if not PoliceCheck then
                            return
                        end

                        Config.FrameworkFunctions.TriggerCallback('Pug:server:IsBankTruckOnCooldown', function(isOnCooldown, timeRemaining)
                            if isOnCooldown then
                                CooldownCheck = false
                                Notify(Config.T("BankTruckCooldownMinutes", math.ceil(timeRemaining / 60)), "error")
                            else
                                CooldownCheck = true
                            end
                        end)
                        while CooldownCheck == "none" do Wait(50) end
                        if not CooldownCheck then
                            return
                        end

                        for _, item in ipairs(AllBankTruckData.requiredItem) do
                            if not HasItem(item.name, item.quantityNeeded) then
                                Notify(Config.T("MissingRequiredItemNamed", item.name), "error")
                                return
                            end
                        end

                        local pedCoords = vector3(initiatingPoint.pedCoords[1], initiatingPoint.pedCoords[2], initiatingPoint.pedCoords[3])
                        local animationType = initiatingPoint.animation
                        local miniGameType = initiatingPoint.miniGame
                        local ObjectData
                        local stage = {
                            animation  = animationType,
                            propName = propName,
                        }
                        if animationType and animationType ~= "" then
                            local ChosenAnimation = Config.Animations[tonumber(animationType)]
                            if Config.RobberyAnimations[animationType] then
                                ChosenAnimation = Config.RobberyAnimations[animationType]
                                local PropModel = propName
                                if type(PropModel) == "string" then
                                    PropModel = GetHashKey(propName)
                                end
                                local Dist = 1.5
                                sceneObject = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), Dist, PropModel, 0, 0, 0)
                                if sceneObject ~= 0 then
                                    ObjectData = {
                                        Coords = GetEntityCoords(sceneObject),
                                        Rotation = GetEntityRotation(sceneObject),
                                        PropName = propName,
                                        RobberyName = "banktruck", 
                                        Stage = {},
                                        DataObject = sceneObject,
                                        Heist = "banktruck",
                                        Heading =  GetEntityHeading(sceneObject),
                                    }
                                end
                                if propName == "tr_prop_tr_elecbox_01a" then
                                    TriggerServerEvent("Pug:server:DeleteRobberiesEntity", ObjectData.Coords, PropModel, "banktruck")
                                end
                                if not Config.RobberyAnimations[animationType].ReplaceProp or propName == "tr_prop_tr_elecbox_01a" then
                                    TriggerEvent("Pug:client:DoRobberiesAnimation", animationType, PlayerPedId(), false, ObjectData, true)
                                    if propName ~= "xm_base_cia_server_01" and propName ~= "tr_prop_tr_elecbox_01a" then
                                        Wait(5000)
                                    end
                                    if miniGameType == "none" and propName ~= "xm_base_cia_server_01" or propName == "tr_prop_tr_elecbox_01a" then
                                        Wait(3000)
                                    end
                                end
                            else
                                ChosenAnimation = Config.Animations[tonumber(animationType)]
                                if not ChosenAnimation.IsNetWorkedScene then
                                    TriggerEvent("Pug:client:DoRobberiesAnimation", animationType, PlayerPedId(), false, ObjectData, true)
                                    Wait(5000) 
                                    if miniGameType == "none" and propName ~= "xm_base_cia_server_01" then
                                        Wait(3000)
                                    end
                                end
                            end
                        end
                        Config.FrameworkFunctions.TriggerCallback('Pug:server:IsBankTruckBeingInitiated', function(IsInitiated)
                            if not IsInitiated then
                                local DoMiniGame = Config.MiniGames[miniGameType].Game()
                                if DoMiniGame then
                                    Notify(Config.LangT["Success"], "success")
                                    TriggerServerEvent("Pug:Server:SpawnRandomBankTruck")
                                    
                                    EndMultipleNetworkAnimation(stage, ObjectData)
                                    ClearPedTasks(PlayerPedId())
                                else
                                    Notify(Config.LangT["Failed"], "error")
                                    EndMultipleNetworkAnimation(stage, ObjectData)
                                    ClearPedTasks(PlayerPedId())
                                end
                            else
                                Notify(Config.LangT["BankTruckAlreadyLocated"], "error")
                                EndMultipleNetworkAnimation(stage, ObjectData)
                                ClearPedTasks(PlayerPedId())
                            end
                        end)
                    end
                }
            }
        end
    end
    if GetResourceState("RevoInteract") ~= 'started' and Config.Target and not Config.DrawTextInsteadOfTarget then
        if Config.Target == 'ox_target' then
            exports.ox_target:addSphereZone({
                name = 'bankTruckTarget',
                coords = vector3(location[1], location[2], location[3]),
                radius = 0.5, -- Adjust radius if needed
                debug = Config.Debug,
                options = options
            })
        else
            exports[Config.Target]:AddCircleZone('bankTruckTarget', vector3(location[1], location[2], location[3]), 0.5, {
                name = 'bankTruckTarget',
                debugPoly = Config.Debug,
                useZ = true
            }, {
                options = options,
                distance = 1.5
            })
        end
    end
end

RegisterNetEvent('Pug:client:UseBankTruckItem', function()
    local bankTruck = GetClosestBankTruck()
    if bankTruck then

        if IsPlayerAtBackOfTruck(PlayerPedId(), bankTruck) then
            Config.FrameworkFunctions.TriggerCallback('Pug:server:IsBankTruckOnCooldown', function(isOnCooldown, timeRemaining)
                if isOnCooldown then
                    Notify(Config.T("BankTruckCooldownMinutes", math.ceil(timeRemaining / 60)), "error")
                else
                    Config.FrameworkFunctions.TriggerCallback('Pug:serverCB:getPoliceCount', function(policeCount)
                        local requiredPolice = GetBankTruckRequiredPolice()
                        if policeCount >= requiredPolice then
                            if not AllBankTruckData.initiatingStartingPoint.pedCoords then
                                StartBankTruckRobbery(bankTruck)
                            else
                                Config.FrameworkFunctions.TriggerCallback('Pug:server:IsBankTruckBeingInitiated', function(IsInitiated)
                                    if IsInitiated then
                                        StartBankTruckRobbery(bankTruck)
                                    else
                                        Notify(Config.LangT["NeedInfoFromSource"], "error")
                                    end
                                end)

                            end
                        else
                            Notify(Config.T("PoliceNotOnlineRequired", requiredPolice), "error")
                        end
                    end)
                end
            end)
        else
            Notify(Config.LangT["NeedToBeAtBackOfBankTruck"], "error")
        end
    else
        Notify(Config.LangT["NoBankTruckNearby"], "error")
    end
end)


function IsPlayerAtBackOfTruck(playerPed, truck)
    local playerCoords = GetEntityCoords(playerPed)
    local boneIndex = GetEntityBoneIndexByName(truck, 'door_dside_r')
    if boneIndex == -1 then
        boneIndex = GetEntityBoneIndexByName(truck, 'boot')
    end
    if boneIndex ~= -1 then
        local bonePos = GetWorldPositionOfEntityBone(truck, boneIndex)
        local distance = #(playerCoords - bonePos)
        return distance < 2.0 
    else
        local truckCoords = GetEntityCoords(truck)
        local truckForwardVector = GetEntityForwardVector(truck)
        local backPosition = truckCoords - (truckForwardVector * 3.0)
        local distance = #(playerCoords - backPosition)
        return distance < 2.0
    end
end


function GetBankTruckRequiredPolice()
    local requiredPolice = 0
    if AllBankTruckData and AllBankTruckData.BankTruckpoliceRequired then
        requiredPolice = AllBankTruckData.BankTruckpoliceRequired
    else
        requiredPolice = 0 
	end
    return requiredPolice
end



function SpawnGuardsAtBackOfTruck(bankTruck)
    local guardModelHash = GetHashKey('s_m_m_armoured_01') 
    RequestModel(guardModelHash)
    while not HasModelLoaded(guardModelHash) do
        Wait(10)
    end


    local guardGroupHash = GetHashKey("GUARDS")
    if not DoesRelationshipGroupExist(guardGroupHash) then
        AddRelationshipGroup("GUARDS")
    end

    SetRelationshipBetweenGroups(0, guardGroupHash, guardGroupHash)

    SetRelationshipBetweenGroups(5, guardGroupHash, GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), guardGroupHash)


    local guardSeats = {1, 2} 

    local guards = {}

    for i, seatIndex in ipairs(guardSeats) do
        pcall(function() exports['FeloxAC']:CreatePed(guardModelHash) end) --[[FeloxAC:auto]]
        local guard = CreatePedInsideVehicle(bankTruck, 4, guardModelHash, seatIndex, true, false)
        if DoesEntityExist(guard) then

            NetworkRegisterEntityAsNetworked(guard)
            local netId = NetworkGetNetworkIdFromEntity(guard)
            SetNetworkIdCanMigrate(netId, true)
            SetNetworkIdExistsOnAllMachines(netId, true)
            NetworkSetNetworkIdDynamic(netId, false)
            SetEntityAsMissionEntity(guard, true, false)

            SetPedRelationshipGroupHash(guard, guardGroupHash)

            SetPedCombatAttributes(guard, 46, true)
            SetPedFleeAttributes(guard, 0, false) 
            SetPedArmour(guard, 100)
            SetPedAccuracy(guard, 60)
            SetPedCombatAbility(guard, 2)
            SetPedCombatMovement(guard, 2) 
            SetPedCombatRange(guard, 2)
            SetPedTargetLossResponse(guard, 1) 

            pcall(function() exports['FeloxAC']:giveWeapon(GetHashKey("WEAPON_CARBINERIFLE"), 'pug-robberycreator') end) --[[FeloxAC:auto]]
            GiveWeaponToPed(guard, GetHashKey("WEAPON_CARBINERIFLE"), 250, false, true)
            SetCurrentPedWeapon(guard, GetHashKey("WEAPON_CARBINERIFLE"), true)

            TaskLeaveVehicle(guard, bankTruck, 0)

            CreateThread(function()
                Wait(1400)
				if DoesEntityExist(guard) and not IsEntityDead(guard) then
					ClearPedTasksImmediately(guard)
                    TaskCombatPed(guard, PlayerPedId(), 0, 16)
				end
            end)

            table.insert(guards, guard)
        else
            PrintDebug("Failed to create guard #" .. i)
        end
    end

    SetModelAsNoLongerNeeded(guardModelHash)
end


function StartBankTruckRobbery(bankTruck)
    if AllBankTruckData and AllBankTruckData.requiredItem and #AllBankTruckData.requiredItem > 0 then
        for _, requiredItem in ipairs(AllBankTruckData.requiredItem) do
            if not HasItem(requiredItem.name, requiredItem.quantityNeeded) then
                Notify(Config.T("MissingRequiredItemNamed", requiredItem.name), "error")
                return
            end
        end
        for _, requiredItem in ipairs(AllBankTruckData.requiredItem) do
            local chanceToLose = tonumber(requiredItem.chanceToLose) or 0
            if chanceToLose > 0 and math.random(1, 100) <= chanceToLose then
                TokenIsUseable = true
                HandleItems(false, tostring(requiredItem.name), tonumber(requiredItem.quantityNeeded) or 1)
                TokenIsUseable = false
            end
        end
    end
    local playerPed = PlayerPedId()
	SetVehicleDoorsShut(bankTruck, true)
    SetVehicleDoorsLocked(bankTruck, 4) -- Lock all doors
    TabletEmote()
    local DoMiniGame = Config.MiniGames[AllBankTruckData.miniGame].Game()
    if DoMiniGame then
        local BankTruckFinishedCoords = GetEntityCoords(bankTruck)
        local BankTruckFinishedHeading = GetEntityHeading(bankTruck)
        SendBankTruckAlert()
        StopTabletEmote()
        Notify(Config.LangT["Success"], "success")
        TriggerEvent('ox_inventory:disarm', GetPlayerServerId(PlayerId()), true)
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
        local playerCoords = GetEntityCoords(playerPed)
        FreezeEntityPosition(bankTruck, true)
        FreezeEntityPosition(playerPed, true)
        RequestAnimDict('anim@heists@ornate_bank@thermal_charge')
        while not HasAnimDictLoaded('anim@heists@ornate_bank@thermal_charge') do
            Wait(10)
        end
        local thermiteModel = GetHashKey('hei_prop_heist_thermite')
        RequestModel(thermiteModel)
        while not HasModelLoaded(thermiteModel) do
            Wait(10)
        end
        local animPos = GetOffsetFromEntityInWorldCoords(bankTruck, 0.0, -4.0, 0.0) -- Adjust as needed
        TriggerServerEvent('Pug:server:StartBankTruckRobbery', vector3(animPos.x, animPos.y, animPos.z - 0.4))
        local animHeading = GetEntityHeading(bankTruck)
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoords(playerPed, animPos.x, animPos.y, animPos.z - 0.4)
        SetEntityHeading(playerPed, animHeading)
        pcall(function() exports['FeloxAC']:CreateObject(thermiteModel) end) --[[FeloxAC:auto]]
        local thermiteProp = CreateObject(thermiteModel, animPos.x, animPos.y, animPos.z, true, true, false)
        AttachEntityToEntity(thermiteProp, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        TaskPlayAnim(playerPed, 'anim@heists@ornate_bank@thermal_charge', 'thermal_charge', 8.0, -8.0, -1, 1, 0, false, false, false)
        Wait(3500)
        DetachEntity(thermiteProp, 1, 1)
        FreezeEntityPosition(thermiteProp, true)
        RequestNamedPtfxAsset("scr_ornate_heist")
        while not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
            Wait(10)
        end
        SetPtfxAssetNextCall("scr_ornate_heist")
        UseParticleFxAssetNextCall("scr_ornate_heist")
        local effect = StartParticleFxLoopedAtCoord("scr_heist_ornate_thermal_burn", vector3(GetEntityCoords(thermiteProp).x, GetEntityCoords(thermiteProp).y, GetEntityCoords(thermiteProp).z + 0.1), 0.0, 0.0, 0.0, 0.03, false, false, false, false)

        Wait(4000)
        ClearPedTasks(PlayerPedId())
        FreezeEntityPosition(playerPed, false)
        Wait(6500)
        StopParticleFxLooped(effect, 0)
        DeleteObject(thermiteProp)
        ClearPedTasks(playerPed)
        SetModelAsNoLongerNeeded(thermiteModel)
        if AllBankTruckData.guardsShootOption then
            SetVehicleDoorsLocked(bankTruck, 1) -- Unlock doors
            Wait(1000)
            SpawnGuardsAtBackOfTruck(bankTruck)
            Wait(8000)
            SetVehicleDoorsShut(bankTruck, true)
            SetVehicleDoorsLocked(bankTruck, 4) -- Lock all doors
        end
        local bankTruckLootCooldown = AllBankTruckData.bankTruckLootCooldown or 1
        Notify(Config.T("BankTruckLootGrabbableMinutes", bankTruckLootCooldown), "success")

        CreateThread(function()
            local endTime = GetGameTimer() + (bankTruckLootCooldown * 60 * 1000)

            while GetGameTimer() < endTime do
                Wait(1000)

                local playerCoords = GetEntityCoords(PlayerPedId())
                if #(playerCoords - BankTruckFinishedCoords) <= 420.0 then
                    if not DoesEntityExist(bankTruck) then
                        PugSpawnVehicle("stockade", function(veh)
                            SetEntityHeading(veh, BankTruckFinishedHeading)
                            SetVehicleEngineOn(veh, false, false)
                            SetVehicleOnGroundProperly(veh)
                            SetVehicleNeedsToBeHotwired(veh, false)
                            pcall(function() exports['FeloxAC']:ChangeVehiclePlate(veh, 'STOCK' .. tostring(math.random(100, 999))) end) --[[FeloxAC:auto]]
                            SetVehicleNumberPlateText(veh, 'STOCK' .. tostring(math.random(100, 999)))
                            SetVehicleFuelLevel(veh, 100.0)
                            SetVehicleDoorsLocked(veh, 0)
                            bankTruck = veh
                        end, BankTruckFinishedCoords, true)
                    end
                end
            end
        end)

    else
        Notify(Config.LangT["Failed"], "error")
        StopTabletEmote()
    end
end

local moneyProps = {}

RegisterNetEvent('Pug:client:AllowAllToLootBankTruck', function(location)
    local bankTruck = nil

    local targetCoords = vector3(location.x, location.y, location.z)
    local vehicles = GetGamePool('CVehicle') 
    local closestVehicle = nil
    local closestDistance = 10.0 
    
    for _, vehicle in pairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(targetCoords - vehicleCoords)
    
        if distance < closestDistance and GetEntityModel(vehicle) == GetHashKey("stockade") then
            bankTruck = vehicle 
        end
    end

    if bankTruck then
        SetVehicleDoorOpen(bankTruck, 2, false, false) -- Rear left
        SetVehicleDoorOpen(bankTruck, 3, false, false) -- Rear right
    end

    moneyProps = {}

    local moneyPropModels = {
        'prop_cash_pile_02',
        'prop_poly_bag_money',
        'hei_prop_cash_crate_half_full',
        'bkr_prop_bkr_cashpile_04',
        'bkr_prop_bkr_cashpile_05',
        'bkr_prop_bkr_cashpile_06',
    }

    for _, model in ipairs(moneyPropModels) do
        local modelHash = GetHashKey(model)
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(10)
        end
    end

    local offsets = {
        vector3(0.0, 0.0, 0.0),
        vector3(0.5, 0.0, 0.0),
        vector3(-0.5, 0.0, 0.0),
        vector3(0.0, 0.5, 0.0),
        vector3(0.0, -0.5, 0.0),
        vector3(0.3, 0.3, 0.0),
        vector3(-0.3, -0.3, 0.0),
        vector3(0.7, 0.0, 0.0),
        vector3(-0.7, 0.0, 0.0),
        vector3(0.0, 0.7, 0.0),
        vector3(0.0, -0.7, 0.0),
        vector3(0.5, 0.5, 0.0),
        vector3(-0.5, -0.5, 0.0),
        vector3(0.5, -0.5, 0.0),
        vector3(-0.5, 0.5, 0.0),
        vector3(1.0, 0.0, 0.0),
        vector3(-1.0, 0.0, 0.0),
        vector3(0.0, 1.0, 0.0),
        vector3(0.5, 1.0, 0.0),
    }

    for _, offset in ipairs(offsets) do
        local randomModel = moneyPropModels[math.random(#moneyPropModels)]
        local modelHash = GetHashKey(randomModel)

        local propCoords = vector3(location.x + offset.x, location.y + offset.y, location.z + offset.z - 1.0)
        pcall(function() exports['FeloxAC']:CreateObject(modelHash) end) --[[FeloxAC:auto]]
        local moneyProp = CreateObject(modelHash, propCoords.x, propCoords.y, propCoords.z)
        SetEntityHeading(moneyProp, math.random(0, 360)) 
        PlaceObjectOnGroundProperly(moneyProp)
        FreezeEntityPosition(moneyProp, true)
        table.insert(moneyProps, moneyProp)
    end

    for _, model in ipairs(moneyPropModels) do
        local modelHash = GetHashKey(model)
        SetModelAsNoLongerNeeded(modelHash)
    end

    local options
    if GetResourceState("RevoInteract") == 'started' or not Config.Target or Config.DrawTextInsteadOfTarget then
        CreateThread(function()
            local helpShown = false
            local finishedLooting = false
            
            while not finishedLooting do
                Wait(0)
                
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local dist = #(playerCoords - location)
                
                if dist < 1.5 then
                    if not helpShown then
                        if GetResourceState("RevoInteract") == 'started' then
                            exports.RevoInteract:OpenHelp({
                                ID = "LootBankTruck",
                                Text = Config.T("LootMoney"),
                                Key = "[E]"
                            })
                        else
                            DrawTextOption("[E] " .. Config.T("LootMoney"))
                        end
                        helpShown = true
                    end

                    if IsControlJustPressed(0, 38) then
                        finishedLooting = true
                        if GetResourceState("RevoInteract") == 'started' then
                            exports.RevoInteract:CloseHelp("LootBankTruck")
                        else
                            HideTextOption()
                        end

                        TriggerServerEvent('Pug:server:PlayerStartedLootingBankTruck')

                        local totalAmounts = {}
                        local totalMoney = { total = 0, given = 0, type = 'cash' } 
                        if AllBankTruckData and AllBankTruckData.rewardItem then
                            for _, reward in pairs(AllBankTruckData.rewardItem) do
                                if reward.name and reward.minAmount and reward.maxAmount then
                                    local minAmount = tonumber(reward.minAmount)
                                    local maxAmount = tonumber(reward.maxAmount)
                                    local chance = tonumber(reward.chance) or 100

                                    if minAmount and maxAmount and minAmount <= maxAmount then
                                        local totalAmount = math.random(minAmount, maxAmount)
                                        totalAmounts[reward.name] = { total = totalAmount, given = 0, chance = chance }

                                        local rand = math.random(1, 100)
                                        if rand <= chance then
                                            totalAmounts[reward.name].allowed = true
                                        else
                                            totalAmounts[reward.name].allowed = false
                                            -- Notify(Config.LangT["DidNotReceiveReward"] .. reward.name .. " this time.", "error")
                                        end
                                    else
                                        Notify(Config.T("InvalidAmountOrChanceItem", tostring(reward.name)), "error")
                                    end
                                end
                            end
                        end

                        if AllBankTruckData and AllBankTruckData.rewardMoney then
                            local rewardMoney = AllBankTruckData.rewardMoney
                            if rewardMoney.minAmount and rewardMoney.maxAmount and rewardMoney.type then
                                local minMoney = tonumber(rewardMoney.minAmount)
                                local maxMoney = tonumber(rewardMoney.maxAmount)
                                local moneyType = tostring(rewardMoney.type)
                                if minMoney and maxMoney and minMoney <= maxMoney then
                                    totalMoney.total = math.random(minMoney, maxMoney)
                                    totalMoney.type = moneyType
                                else
                                    Notify(Config.LangT["InvalidMoneyConfiguration"], "error")
                                end
                            end
                        end

                        local ped = PlayerPedId()
                        local pedCoords = GetEntityCoords(ped)
                        local moneyPropModel = GetHashKey('hei_prop_heist_cash_pile')
                        RequestModel(moneyPropModel)
                        while not HasModelLoaded(moneyPropModel) do
                            Wait(10)
                        end
                        pcall(function() exports['FeloxAC']:CreateObject(moneyPropModel) end) --[[FeloxAC:auto]]
                        local grabobj = CreateObject(moneyPropModel, pedCoords, true, true, true)
                        SetEntityVisible(grabobj, false, false)
                        AttachEntityToEntity(
                            grabobj,
                            ped,
                            GetPedBoneIndex(ped, 60309),
                            0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0,
                            false, false, false, false, 0, true
                        )

                        RequestAnimDict('anim@heists@ornate_bank@grab_cash_heels')
                        while not HasAnimDictLoaded('anim@heists@ornate_bank@grab_cash_heels') do
                            Wait(50)
                        end
                        TaskPlayAnim(ped, "anim@heists@ornate_bank@grab_cash_heels", "grab", 8.0, -8.0, -1, 1, 0, false, false, false)
                        FreezeEntityPosition(ped, true)

                        local startedGrabbing = GetGameTimer()
                        local totalDuration = #moneyProps * 1000
                        local interval = 1000 
                        local lastUpdateTime = GetGameTimer()

                        CreateThread(function()
                            while GetGameTimer() - startedGrabbing < totalDuration do
                                Wait(0)
                                DisableControlAction(0, 73, true)
                                local currentTime = GetGameTimer()

                                if HasAnimEventFired(ped, GetHashKey("CASH_APPEAR")) then
                                    if not IsEntityVisible(grabobj) then
                                        SetEntityVisible(grabobj, true, false)
                                    end
                                end

                                if HasAnimEventFired(ped, GetHashKey("RELEASE_CASH_DESTROY")) then
                                    if IsEntityVisible(grabobj) then
                                        SetEntityVisible(grabobj, false, false)
                                    end
                                end

                                if currentTime - lastUpdateTime >= interval then
                                    lastUpdateTime = currentTime
                                    local propIndex = math.floor((currentTime - startedGrabbing) / interval) + 1
                                    if propIndex <= #moneyProps then
                                        TriggerServerEvent('Pug:server:DeleteMoneyProp', propIndex)
                                    end

                                    for itemName, data in pairs(totalAmounts) do
                                        if data.allowed then 
                                            local remaining = data.total - data.given
                                            if remaining > 0 then
                                                local timeLeft = totalDuration - (currentTime - startedGrabbing)
                                                local intervalsLeft = math.ceil(timeLeft / interval)
                                                intervalsLeft = math.max(intervalsLeft, 1)

                                                local amountToGive = math.ceil(remaining / intervalsLeft)
                                                amountToGive = math.min(amountToGive, remaining)

                                                data.given = data.given + amountToGive
                                                TokenIsUseable = true
                                                HandleItems(true, tostring(itemName), amountToGive)
                                                TokenIsUseable = false
                                            end
                                        end
                                    end

                                    if totalMoney.total > 0 and totalMoney.given < totalMoney.total then
                                        local remainingMoney = totalMoney.total - totalMoney.given
                                        local timeLeft = totalDuration - (currentTime - startedGrabbing)
                                        local intervalsLeft = math.ceil(timeLeft / interval)
                                        intervalsLeft = math.max(intervalsLeft, 1)

                                        local amountToGive = math.ceil(remainingMoney / intervalsLeft)
                                        amountToGive = math.min(amountToGive, remainingMoney)

                                        totalMoney.given = totalMoney.given + amountToGive
                                        TokenIsUseable = true
                                        HandleMoney(totalMoney.type, amountToGive)
                                        TokenIsUseable = false
                                    end
                                end
                            end

                            DeleteObject(grabobj)
                            ClearPedTasks(ped)
                            FreezeEntityPosition(ped, false)
                            SetModelAsNoLongerNeeded(moneyPropModel)
                        end)
                    end

                else
                    if helpShown then
                        if GetResourceState("RevoInteract") == 'started' then
                            exports.RevoInteract:CloseHelp("LootBankTruck")
                        else
                            HideTextOption()
                        end
                        helpShown = false
                    end
                end
            end
        end)
    else
        if Config.Target == "ox_target" then
            options = {
                {
                    name = 'lootBankTruck',
                    icon = 'fas fa-box-open',
                    label = Config.T("LootMoney"),
                    onSelect = function()
                        TriggerServerEvent('Pug:server:PlayerStartedLootingBankTruck')

                        local totalAmounts = {}
                        local totalMoney = { total = 0, given = 0, type = 'cash' } 

                        if AllBankTruckData and AllBankTruckData.rewardItem then
                            for _, reward in pairs(AllBankTruckData.rewardItem) do
                                if reward.name and reward.minAmount and reward.maxAmount then
                                    local minAmount = tonumber(reward.minAmount)
                                    local maxAmount = tonumber(reward.maxAmount)
                                    local chance = tonumber(reward.chance) or 100 

                                    if minAmount and maxAmount and minAmount <= maxAmount then
                                        local totalAmount = math.random(minAmount, maxAmount)
                                        totalAmounts[reward.name] = { total = totalAmount, given = 0, chance = chance }

                                        local rand = math.random(1, 100)
                                        if rand <= chance then
                                            totalAmounts[reward.name].allowed = true
                                        else
                                            totalAmounts[reward.name].allowed = false
                                            -- Notify(Config.LangT["DidNotReceiveReward"] .. reward.name .. " this time.", "error")
                                        end
                                    else
                                        Notify(Config.T("InvalidAmountOrChanceItem", tostring(reward.name)), "error")
                                    end
                                end
                            end
                        end

                        if AllBankTruckData and AllBankTruckData.rewardMoney then
                            local rewardMoney = AllBankTruckData.rewardMoney
                            if rewardMoney.minAmount and rewardMoney.maxAmount and rewardMoney.type then
                                local minMoney = tonumber(rewardMoney.minAmount)
                                local maxMoney = tonumber(rewardMoney.maxAmount)
                                local moneyType = tostring(rewardMoney.type)
                                if minMoney and maxMoney and minMoney <= maxMoney then
                                    totalMoney.total = math.random(minMoney, maxMoney)
                                    totalMoney.type = moneyType
                                else
                                    Notify(Config.LangT["InvalidMoneyConfiguration"], "error")
                                end
                            end
                        end

                        local ped = PlayerPedId()
                        local pedCoords = GetEntityCoords(ped)
                        local moneyPropModel = GetHashKey('hei_prop_heist_cash_pile')
                        RequestModel(moneyPropModel)
                        while not HasModelLoaded(moneyPropModel) do
                            Wait(10)
                        end
                        pcall(function() exports['FeloxAC']:CreateObject(moneyPropModel) end) --[[FeloxAC:auto]]
                        local grabobj = CreateObject(moneyPropModel, pedCoords, true, true, true)
                        SetEntityVisible(grabobj, false, false)
                        AttachEntityToEntity(
                            grabobj,
                            ped,
                            GetPedBoneIndex(ped, 60309),
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            false,
                            false,
                            false,
                            false,
                            0,
                            true
                        )

                        RequestAnimDict('anim@heists@ornate_bank@grab_cash_heels')
                        while not HasAnimDictLoaded('anim@heists@ornate_bank@grab_cash_heels') do
                            Wait(50)
                        end
                        TaskPlayAnim(ped, "anim@heists@ornate_bank@grab_cash_heels", "grab", 8.0, -8.0, -1, 1, 0, false, false, false)
                        FreezeEntityPosition(ped, true)

                        local startedGrabbing = GetGameTimer()
                        local totalDuration = #moneyProps * 1000
                        local interval = 1000 
                        local lastUpdateTime = GetGameTimer()

                        CreateThread(function()
                            while GetGameTimer() - startedGrabbing < totalDuration do
                                Wait(0)
                                DisableControlAction(0, 73, true)
                                local currentTime = GetGameTimer()

                                if HasAnimEventFired(ped, GetHashKey("CASH_APPEAR")) then
                                    if not IsEntityVisible(grabobj) then
                                        SetEntityVisible(grabobj, true, false)
                                    end
                                end

                                if HasAnimEventFired(ped, GetHashKey("RELEASE_CASH_DESTROY")) then
                                    if IsEntityVisible(grabobj) then
                                        SetEntityVisible(grabobj, false, false)
                                    end
                                end

                                if currentTime - lastUpdateTime >= interval then
                                    lastUpdateTime = currentTime
                                    local propIndex = math.floor((currentTime - startedGrabbing) / interval) + 1
                                    if propIndex <= #moneyProps then
                                        TriggerServerEvent('Pug:server:DeleteMoneyProp', propIndex)
                                    end

                                    for itemName, data in pairs(totalAmounts) do
                                        if data.allowed then 
                                            local remaining = data.total - data.given
                                            if remaining > 0 then
                                                local timeLeft = totalDuration - (currentTime - startedGrabbing)
                                                local intervalsLeft = math.ceil(timeLeft / interval)
                                                intervalsLeft = math.max(intervalsLeft, 1) 
                                                
                                                local amountToGive = math.ceil(remaining / intervalsLeft)
                                                amountToGive = math.min(amountToGive, remaining)
                                                
                                                data.given = data.given + amountToGive
                                                TokenIsUseable = true
                                                HandleItems(true, tostring(itemName), amountToGive)
                                                TokenIsUseable = false
                                            end
                                        end
                                    end

                                    if totalMoney.total > 0 and totalMoney.given < totalMoney.total then
                                        local remainingMoney = totalMoney.total - totalMoney.given
                                        local timeLeft = totalDuration - (currentTime - startedGrabbing)
                                        local intervalsLeft = math.ceil(timeLeft / interval)
                                        intervalsLeft = math.max(intervalsLeft, 1)

                                        local amountToGive = math.ceil(remainingMoney / intervalsLeft)
                                        amountToGive = math.min(amountToGive, remainingMoney)

                                        totalMoney.given = totalMoney.given + amountToGive
                                        TokenIsUseable = true
                                        HandleMoney(totalMoney.type, amountToGive)
                                        TokenIsUseable = false
                                    end
                                end
                            end

                            DeleteObject(grabobj)
                            ClearPedTasks(ped)
                            FreezeEntityPosition(ped, false)
                            SetModelAsNoLongerNeeded(moneyPropModel)
                        end)
                    end
                }
            }
        else
            options = {
                {
                    name = 'lootBankTruck',
                    icon = 'fas fa-box-open',
                    label = Config.T("LootMoney"),
                    action = function(entity)
                        TriggerServerEvent('Pug:server:PlayerStartedLootingBankTruck')

                        local totalAmounts = {}
                        local totalMoney = { total = 0, given = 0, type = 'cash' } 

                        if AllBankTruckData and AllBankTruckData.rewardItem then
                            for _, reward in pairs(AllBankTruckData.rewardItem) do
                                if reward.name and reward.minAmount and reward.maxAmount then
                                    local minAmount = tonumber(reward.minAmount)
                                    local maxAmount = tonumber(reward.maxAmount)
                                    local chance = tonumber(reward.chance) or 100 

                                    if minAmount and maxAmount and minAmount <= maxAmount then
                                        local totalAmount = math.random(minAmount, maxAmount)
                                        totalAmounts[reward.name] = { total = totalAmount, given = 0, chance = chance }

                                        local rand = math.random(1, 100)
                                        if rand <= chance then
                                            totalAmounts[reward.name].allowed = true
                                        else
                                            totalAmounts[reward.name].allowed = false
                                            -- Notify(Config.LangT["DidNotReceiveReward"] .. reward.name .. " this time.", "error")
                                        end
                                    else
                                        Notify(Config.T("InvalidAmountOrChanceItem", tostring(reward.name)), "error")
                                    end
                                end
                            end
                        end

                        if AllBankTruckData and AllBankTruckData.rewardMoney then
                            local rewardMoney = AllBankTruckData.rewardMoney
                            if rewardMoney.minAmount and rewardMoney.maxAmount and rewardMoney.type then
                                local minMoney = tonumber(rewardMoney.minAmount)
                                local maxMoney = tonumber(rewardMoney.maxAmount)
                                local moneyType = tostring(rewardMoney.type)
                                if minMoney and maxMoney and minMoney <= maxMoney then
                                    totalMoney.total = math.random(minMoney, maxMoney)
                                    totalMoney.type = moneyType
                                else
                                    Notify(Config.LangT["InvalidMoneyConfiguration"], "error")
                                end
                            end
                        end

                        local ped = PlayerPedId()
                        local pedCoords = GetEntityCoords(ped)
                        local moneyPropModel = GetHashKey('hei_prop_heist_cash_pile')
                        RequestModel(moneyPropModel)
                        while not HasModelLoaded(moneyPropModel) do
                            Wait(10)
                        end
                        pcall(function() exports['FeloxAC']:CreateObject(moneyPropModel) end) --[[FeloxAC:auto]]
                        local grabobj = CreateObject(moneyPropModel, pedCoords, true, true, true)
                        SetEntityVisible(grabobj, false, false)
                        AttachEntityToEntity(
                            grabobj,
                            ped,
                            GetPedBoneIndex(ped, 60309),
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            0.0,
                            false,
                            false,
                            false,
                            false,
                            0,
                            true
                        )

                        RequestAnimDict('anim@heists@ornate_bank@grab_cash_heels')
                        while not HasAnimDictLoaded('anim@heists@ornate_bank@grab_cash_heels') do
                            Wait(50)
                        end
                        TaskPlayAnim(ped, "anim@heists@ornate_bank@grab_cash_heels", "grab", 8.0, -8.0, -1, 1, 0, false, false, false)
                        FreezeEntityPosition(ped, true)

                        local startedGrabbing = GetGameTimer()
                        local totalDuration = #moneyProps * 1000
                        local interval = 1000 
                        local lastUpdateTime = GetGameTimer()

                        CreateThread(function()
                            while GetGameTimer() - startedGrabbing < totalDuration do
                                Wait(0)
                                DisableControlAction(0, 73, true)
                                local currentTime = GetGameTimer()

                                if HasAnimEventFired(ped, GetHashKey("CASH_APPEAR")) then
                                    if not IsEntityVisible(grabobj) then
                                        SetEntityVisible(grabobj, true, false)
                                    end
                                end

                                if HasAnimEventFired(ped, GetHashKey("RELEASE_CASH_DESTROY")) then
                                    if IsEntityVisible(grabobj) then
                                        SetEntityVisible(grabobj, false, false)
                                    end
                                end

                                if currentTime - lastUpdateTime >= interval then
                                    lastUpdateTime = currentTime
                                    local propIndex = math.floor((currentTime - startedGrabbing) / interval) + 1
                                    if propIndex <= #moneyProps then
                                        TriggerServerEvent('Pug:server:DeleteMoneyProp', propIndex)
                                    end

                                    for itemName, data in pairs(totalAmounts) do
                                        if data.allowed then 
                                            local remaining = data.total - data.given
                                            if remaining > 0 then
                                                local timeLeft = totalDuration - (currentTime - startedGrabbing)
                                                local intervalsLeft = math.ceil(timeLeft / interval)
                                                intervalsLeft = math.max(intervalsLeft, 1) 
                                                
                                                local amountToGive = math.ceil(remaining / intervalsLeft)
                                                amountToGive = math.min(amountToGive, remaining)
                                                
                                                data.given = data.given + amountToGive
                                                TokenIsUseable = true
                                                HandleItems(true, tostring(itemName), amountToGive)
                                                TokenIsUseable = false
                                            end
                                        end
                                    end

                                    if totalMoney.total > 0 and totalMoney.given < totalMoney.total then
                                        local remainingMoney = totalMoney.total - totalMoney.given
                                        local timeLeft = totalDuration - (currentTime - startedGrabbing)
                                        local intervalsLeft = math.ceil(timeLeft / interval)
                                        intervalsLeft = math.max(intervalsLeft, 1)

                                        local amountToGive = math.ceil(remainingMoney / intervalsLeft)
                                        amountToGive = math.min(amountToGive, remainingMoney)

                                        totalMoney.given = totalMoney.given + amountToGive
                                        TokenIsUseable = true
                                        HandleMoney(totalMoney.type, amountToGive)
                                        TokenIsUseable = false
                                    end
                                end
                            end

                            DeleteObject(grabobj)
                            ClearPedTasks(ped)
                            FreezeEntityPosition(ped, false)
                            SetModelAsNoLongerNeeded(moneyPropModel)
                        end)
                    end
                }
            }
        end
    end
    if GetResourceState("RevoInteract") ~= 'started' and Config.Target and not Config.DrawTextInsteadOfTarget then
        if Config.Target == 'ox_target' then
            exports.ox_target:addSphereZone({
                name = 'lootBankTruckZone',
                coords = location,
                radius = 0.5,
                debug = false,
                options = options
            })
        else 
            exports[Config.Target]:AddCircleZone('lootBankTruckZone', location, 0.5, {
                name = 'lootBankTruckZone',
                debugPoly = false,
                useZ = true
            }, {
                options = options,
                distance = 1.5
            })
        end
    end
end)


RegisterNetEvent('Pug:client:RemoveBankTruckTarget', function()
    if GetResourceState("RevoInteract") == 'started' or not Config.Target or Config.DrawTextInsteadOfTarget then
        if GetResourceState("RevoInteract") == 'started' then
            exports.RevoInteract:CloseHelp("bankTruckTarget")
            exports.RevoInteract:CloseHelp("LootBankTruck")
        else
            HideTextOption()
        end
    else
        if Config.Target == 'ox_target' then
            exports.ox_target:removeZone('lootBankTruckZone')
        else
            exports[Config.Target]:RemoveZone('lootBankTruckZone')
        end
    end
end)

RegisterNetEvent('Pug:client:DeleteMoneyProp', function(propIndex)
    local prop = moneyProps[propIndex]
    if prop and DoesEntityExist(prop) then
        DeleteObject(prop)
        moneyProps[propIndex] = nil -- Remove from the table
    end
    if propIndex >= #moneyProps then
        Wait(700)
        DeleteAllBankTruckProps()
    end
end)

function DeleteAllBankTruckProps()
	for _, v in pairs(moneyProps) do
		if DoesEntityExist(v) then
			DeleteEntity(v)
		end
	end
end

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        DeleteAllBankTruckProps()
        StopTabletEmote()
        RemoveBankTruckTarget()
    end
end)

CreateThread(function()
	while true do
		local sleep = 1000
		local LoggedIn = LocalPlayer.state.isLoggedIn
		if Framework == "ESX" then
			LoggedIn = FWork.PlayerLoaded
		end
		if LoggedIn then
			if ForceLockBankTruckAlways then
				sleep = 100
				local ped = PlayerPedId()
				local entering = GetVehiclePedIsTryingToEnter(ped)
				local carIsImmune = false
				if entering ~= 0 then
					if GetEntityModel(entering) == GetHashKey("stockade") then
						SetVehicleDoorsLocked(entering, 4) -- Lock all doors
						ClearPedTasks(PlayerPedId())
						Wait(500)
					end
				end
			end
		end
		Wait(sleep)
	end
end)
