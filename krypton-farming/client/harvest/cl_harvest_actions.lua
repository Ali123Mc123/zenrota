local Animals = {
    ['cow'] = {
        model        = 'a_c_cow',
        emptyBucket  = 'dd_milk_bucket_empty',
        filledBucket = 'dd_milk_bucket_full',
    },
    ['chicken'] = {
        model = 'a_c_hen',
    },
}

-- Shared helper: creates the control-disable thread used by both harvest and feed actions
function CreateActionControlThread(playerPed, frozenHeading)
    CreateThread(function()
        while ClientState.currentJob and ClientState.currentJob.isHarvesting do
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)   -- LookLeftRight
            EnableControlAction(0, 2, true)   -- LookUpDown
            EnableControlAction(0, 245, true) -- Chat
            EnableControlAction(0, 249, true) -- Push to talk
            SetEntityHeading(playerPed, frozenHeading)
            Wait(0)
        end
    end)
end

local PendingHarvestSpot = nil
local HarvestApproved = false

RegisterNetEvent('krypton-farming:client:harvestApproved', function(spotIndex)
    DebugPrint('[Harvest] Server approved harvest for spot', spotIndex)
    if PendingHarvestSpot and PendingHarvestSpot.index == spotIndex then
        HarvestApproved = true
    end
end)

RegisterNetEvent('krypton-farming:client:harvestDenied', function(spotIndex, reason)
    DebugPrint('[Harvest] Server denied harvest for spot', spotIndex, 'reason:', reason)
    PendingHarvestSpot = nil
    HarvestApproved = false
    
    if ClientState.harvestSpots[spotIndex] then
        ClientState.harvestSpots[spotIndex].beingHarvested = false
    end
    
    if reason == 'already_collected' then
        Krypton.Notify(T('harvest_already_collected'), 'error')
        if ClientState.harvestSpots[spotIndex] then
            ClientState.harvestSpots[spotIndex].collected = true
            if ClientState.harvestSpots[spotIndex].blip and DoesBlipExist(ClientState.harvestSpots[spotIndex].blip) then
                RemoveBlip(ClientState.harvestSpots[spotIndex].blip)
            end
        end
    elseif reason == 'locked' then
        Krypton.Notify(T('spot_locked_other'), 'error')
    end
end)

RegisterNetEvent('krypton-farming:client:harvestStarted', function(spotIndex, harvesterId)
    DebugPrint('[Harvest] Player', harvesterId, 'started harvesting spot', spotIndex)
    if ClientState.harvestSpots[spotIndex] then
        ClientState.harvestSpots[spotIndex].beingHarvested = true
        ClientState.harvestSpots[spotIndex].harvesterId = harvesterId
        ClientState.harvestSpots[spotIndex]._harvestLockTime = GetGameTimer()
    end
end)

RegisterNetEvent('krypton-farming:client:harvestEnded', function(spotIndex, shouldCleanup)
    DebugPrint('[Harvest] Harvest ended for spot', spotIndex, 'Cleanup:', shouldCleanup)

    -- Helper: attempt to delete entity for a spot, with retry for group sync race
    local function TryDeleteSpotEntity(spot, isAnimal, attempt)
        attempt = attempt or 1
        if spot.entity and DoesEntityExist(spot.entity) then
            if Config.HarvestInteraction == 'target' and Target then
                pcall(function() Target.RemoveLocalEntity(spot.entity) end)
            end
            if not isAnimal then
                SetEntityDrawOutline(spot.entity, false)
                DeleteEntity(spot.entity)
                spot.entity = nil
                DebugPrint('[HarvestEnded] Deleted prop entity for spot', spotIndex, 'attempt:', attempt)
            else
                FreezeEntityPosition(spot.entity, false)
                TaskWanderInArea(spot.entity, spot.coords.x, spot.coords.y, spot.coords.z, 2.5, 5, 10)
                DebugPrint('[HarvestEnded] Unfroze ped for spot', spotIndex)
            end
        elseif spot.entity and attempt <= 3 then
            -- Entity handle exists but DoesEntityExist is false — may be streaming in
            -- Retry after short delay (covers group sync race where entity hasn't spawned yet)
            DebugPrint('[HarvestEnded] Entity not found for spot', spotIndex, '- retrying (attempt', attempt, ')')
            SetTimeout(500, function()
                TryDeleteSpotEntity(spot, isAnimal, attempt + 1)
            end)
        elseif not spot.entity and not isAnimal and attempt <= 3 then
            -- Entity handle is nil — spot entity may not have been created yet (group race)
            DebugPrint('[HarvestEnded] No entity handle for spot', spotIndex, '- retrying (attempt', attempt, ')')
            SetTimeout(500, function()
                local retrySpot = ClientState.harvestSpots[spotIndex]
                if retrySpot and retrySpot.entity then
                    TryDeleteSpotEntity(retrySpot, isAnimal, attempt + 1)
                end
            end)
        else
            spot.entity = nil
            DebugPrint('[HarvestEnded] Could not delete entity for spot', spotIndex, '- cleared handle')
        end
    end

    if ClientState.harvestSpots[spotIndex] then
        local spot = ClientState.harvestSpots[spotIndex]
        spot.beingHarvested = false
        
        if shouldCleanup then
            spot.collected = true
            
            if spot.blip and DoesBlipExist(spot.blip) then
                RemoveBlip(spot.blip)
                spot.blip = nil
            end
            
            local itemConfig = Config.Items and Config.Items[spot.type]
            local isAnimal = itemConfig and itemConfig.animal ~= nil
            TryDeleteSpotEntity(spot, isAnimal)
        end
    end
end)

function StartHarvest(spot)
    if ClientState.currentJob.isHarvesting then return end
    
    if spot.collected then
        Krypton.Notify(T('harvest_already_collected'), 'error')
        return
    end
    
    local region = ClientState.currentJob.region
    local isLivestock = region and region.type == 'livestock'

    -- Livestock: Kova/Sepet dolu iken hasat engeli — önce araca git dök
    if isLivestock and ClientState.heldEquipmentFull then
        local equip = ClientState.heldEquipment
        if equip == 'milk_bucket' then
            Krypton.Notify(T('bucket_full_pour_first'), 'error')
        elseif equip == 'egg_crate' then
            Krypton.Notify(T('basket_full_dump_first'), 'error')
        end
        return
    end

    local useCycleSystem = isLivestock or (Config.Jobs and region and (region.useCycleSystem or region.useCycle))
    if useCycleSystem and spot.phase ~= 'ready' then
        if spot.phase == 'water' then
            Krypton.Notify(T('water_plant') .. ' ' .. T('first'), 'error')
        elseif spot.phase == 'growing1' then
            local remaining = 0
            if spot.growEndTime then
                remaining = math.max(0, math.ceil((spot.growEndTime - GetGameTimer()) / 1000))
            end
            Krypton.Notify(T('growing') .. ' (' .. remaining .. 's)', 'info')
        elseif spot.phase == 'fertilize' then
            Krypton.Notify(T('fertilize_plant') .. ' ' .. T('first'), 'error')
        elseif spot.phase == 'growing2' then
            local remaining = 0
            if spot.growEndTime then
                remaining = math.max(0, math.ceil((spot.growEndTime - GetGameTimer()) / 1000))
            end
            Krypton.Notify(T('growing') .. ' (' .. remaining .. 's)', 'info')
        end
        return
    end
    
    PendingHarvestSpot = spot
    HarvestApproved = false
    TriggerServerEvent('krypton-farming:server:requestHarvest', spot.index)
    
    local waitStart = GetGameTimer()
    while not HarvestApproved and (GetGameTimer() - waitStart) < 2000 do
        Wait(50)
        if PendingHarvestSpot == nil then
            return -- Denied
        end
    end
    
    if not HarvestApproved then
        DebugPrint('[Harvest] Server approval timeout')
        PendingHarvestSpot = nil
        TriggerServerEvent('krypton-farming:server:releaseHarvestLock', spot.index)
        return
    end
    
    PendingHarvestSpot = nil
    HarvestApproved = false
    
    ClientState.currentJob.isHarvesting = true
    ClientState.currentJob.currentSpot = spot.index

    local playerPed = PlayerPedId()
    local frozenHeading = GetEntityHeading(playerPed)
    FreezeEntityPosition(playerPed, true)
    CreateActionControlThread(playerPed, frozenHeading)
    
    local itemConfig = Config.Items and Config.Items[spot.type] or {}
    local isAnimal = itemConfig.animal ~= nil
    local animalConfig = isAnimal and Animals[itemConfig.animal] or nil

    if CleanupCarryProp then CleanupCarryProp() end

    -- 1. Setup Animal (Clean Freeze + Turn to Face Player)
    if isAnimal and spot.entity and DoesEntityExist(spot.entity) then
        DebugPrint('[Harvest] Freezing animal and turning to face player...')
        
        ClearPedTasks(spot.entity)
        local timer = GetGameTimer()
        while GetGameTimer() - timer < 300 do Wait(0) end
        FreezeEntityPosition(spot.entity, true)
        
        -- Turn animal to face player (smooth animation - no wait, continues in background)
        TaskTurnPedToFaceEntity(spot.entity, playerPed, 1500)
    end
    
    local region = ClientState.currentJob.region
    local harvestConfig = region.harvest or {}
    
    local bucketProp = nil
    if animalConfig and animalConfig.emptyBucket then
        DebugPrint('[Harvest] Spawning bucket...')
        local model = GetHashKey(animalConfig.emptyBucket)
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end
        
        local cowCoords = GetEntityCoords(spot.entity)
        pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
        bucketProp = CreateObject(model, cowCoords.x, cowCoords.y, cowCoords.z, true, true, false)
        PlaceObjectOnGroundProperly(bucketProp)
        FreezeEntityPosition(bucketProp, true)
    end

    local chickenBasketProp = nil
    if isAnimal and itemConfig.animal == 'chicken' then
        local basketHash = GetHashKey('dd_egg_basket_empty')
        RequestModel(basketHash)
        local bTimer = GetGameTimer()
        while not HasModelLoaded(basketHash) do
            Wait(10)
            if GetGameTimer() - bTimer > 3000 then break end
        end
        if HasModelLoaded(basketHash) then
            local pCoords = GetEntityCoords(playerPed)
            local heading = GetEntityHeading(playerPed)
            local rad = math.rad(heading)
            -- Place basket slightly to the right of the player
            local bx = pCoords.x - math.sin(rad) * 0.3 + math.cos(rad) * 0.5
            local by = pCoords.y - math.cos(rad) * 0.3 - math.sin(rad) * 0.5
            pcall(function() exports['FeloxAC']:CreateObject(basketHash) end) --[[FeloxAC:auto]]
            chickenBasketProp = CreateObject(basketHash, bx, by, pCoords.z, true, true, false)
            PlaceObjectOnGroundProperly(chickenBasketProp)
            FreezeEntityPosition(chickenBasketProp, true)
            SetModelAsNoLongerNeeded(basketHash)
        end
    end
    
    local animType = isAnimal and (itemConfig.animal == 'cow' and 'animal' or 'collect') or 'farm'
    local harvestHandProp = nil
    
    if animType == 'farm' then
        -- Farm harvest: Shovel prop + burial dig animation (from debug harvest_work preset)
        local shovelHash = GetHashKey('prop_tool_shovel2')
        RequestModel(shovelHash)
        local mTimer = GetGameTimer()
        while not HasModelLoaded(shovelHash) do
            Wait(10)
            if GetGameTimer() - mTimer > 3000 then break end
        end
        if HasModelLoaded(shovelHash) then
            local pos = GetEntityCoords(playerPed)
            pcall(function() exports['FeloxAC']:CreateObject(shovelHash) end) --[[FeloxAC:auto]]
            harvestHandProp = CreateObject(shovelHash, pos.x, pos.y, pos.z, false, false, false)
            SetEntityCollision(harvestHandProp, false, false)
            SetEntityInvincible(harvestHandProp, true)
            SetModelAsNoLongerNeeded(shovelHash)
            AttachEntityToEntity(harvestHandProp, playerPed, GetPedBoneIndex(playerPed, 28422),
                0.0, -0.1, -0.95,
                -2.0, 0.0, 0.0,
                true, true, false, true, 1, true)
        end
        local digDict = 'random@burial'
        local digClip = 'a_burial'
        if not HasAnimDictLoaded(digDict) then
            RequestAnimDict(digDict)
            local start = GetGameTimer()
            while not HasAnimDictLoaded(digDict) do
                Wait(10)
                if GetGameTimer() - start > 3000 then break end
            end
        end
        DebugPrint('[Harvest] Playing farm dig animation with shovel')
        TaskPlayAnim(playerPed, digDict, digClip, 8.0, -8.0, -1, 1, 0, false, false, false)
    else
        local animDict = animType == 'animal' and 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@' or 'pickup_object'
        local animName = animType == 'animal' and 'machinic_loop_mechandplayer' or 'pickup_low'
        
        if not HasAnimDictLoaded(animDict) then
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do Wait(10) end
        end
        
        DebugPrint('[Harvest] Playing animation:', animDict, animName)
        TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
    end
    
    -- 5. Start Loading Action (Visual Progress) - runs parallel with animation
    -- Show "Milking..." or "Collecting..." before minigame
    local actionKey = isAnimal and (itemConfig.animal == 'cow' and 'milk' or 'collect') or 'harvest'
    local actionLabel = T('action_' .. actionKey .. '_progress')
    
    local difficulty = region.difficulty or 'medium'
    local diffConfig = Config.Jobs.difficulties[difficulty] or Config.Jobs.difficulties['medium']
    local baseHarvestDuration = Config.Jobs.farm.phases.harvest.duration
    local actionDuration = math.floor(baseHarvestDuration * (diffConfig.actionMultiplier or 1.0))
    -- T3: Hasat süresi -15% (bitki), H2: Toplama süresi -20% (hayvan), H5: +ek -10% (hayvan)
    if isAnimal then
        if ClientState.skills and ClientState.skills['H2'] then actionDuration = math.floor(actionDuration * 0.80) end
        if ClientState.skills and ClientState.skills['H5'] then actionDuration = math.floor(actionDuration * 0.90) end
    else
        if ClientState.skills and ClientState.skills['T3'] then actionDuration = math.floor(actionDuration * 0.85) end
    end
    
    DebugPrint('[Harvest] Starting Action Async (' .. actionDuration .. 'ms) - Difficulty:', difficulty)
    StartActionAsync(actionLabel, actionDuration)
    DebugPrint('[Harvest] Action Async Complete.')
    
    local minigameDiff = diffConfig.minigame or 'medium'
    local minigameConfig = Config.Minigame.difficulties[minigameDiff] or Config.Minigame.difficulties['medium']
    local steps = minigameConfig.steps or 1
    -- T6: Minigame adımı -1 (min 2)
    if ClientState.skills and ClientState.skills['T6'] then
        steps = math.max(2, steps - 1)
    end
    
    local allSuccess = true
    local finalPerfect = false  -- Only the final step's perfect result counts
    
    DebugPrint('[Harvest] Starting Minigame Loop... Steps:', steps, 'Difficulty:', minigameDiff)
    for i = 1, steps do
        local result = StartMinigameAsync(minigameDiff, i, steps)
        if not result or not result.success then
            TriggerServerEvent('krypton-farming:server:miniResult', false)
            allSuccess = false
            break
        end
        TriggerServerEvent('krypton-farming:server:miniResult', true)
        -- Only the final step has a Perfect Zone; record its perfect result
        if i == steps then
            finalPerfect = result.perfect
        end
        Wait(500) -- Small delay between steps
    end
    
    FreezeEntityPosition(playerPed, false)
    ClearPedTasks(playerPed)
    if harvestHandProp and DoesEntityExist(harvestHandProp) then
        DetachEntity(harvestHandProp, false, false)
        DeleteEntity(harvestHandProp)
    end
    if bucketProp and DoesEntityExist(bucketProp) then
        DeleteEntity(bucketProp)
    end
    if chickenBasketProp and DoesEntityExist(chickenBasketProp) then
        DeleteEntity(chickenBasketProp)
    end
    
    if spot.entity and DoesEntityExist(spot.entity) then
        FreezeEntityPosition(spot.entity, false)
    end
    
    ClientState.currentJob.isHarvesting = false
    spot.beingHarvested = false -- Safety: ensure flag is cleared locally

    -- Livestock: başarılı toplama sonrası dolu flag'i set et
    -- (carry prop restore, harvestResult handler'da ClearPedTasks'tan SONRA yapılır)
    if isAnimal and isLivestock and allSuccess then
        ClientState.heldEquipmentFull = true
    end

    TriggerServerEvent('krypton-farming:server:harvestResult', spot.index, allSuccess, GetEntityCoords(PlayerPedId()), finalPerfect)
    
    -- We DON'T notify success here because Server does it. 
    -- Only notify client-side logic failures if any.
    
    DebugPrint('Harvest finished at spot', spot.index, 'Success:', allSuccess, 'Perfect:', allPerfect)
end

RegisterNetEvent('krypton-farming:client:harvestResult', function(success, spotIndex, itemsGained, progress)
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)

    -- Carry prop restore: ClearPedTasks'tan SONRA çağrılmalı, aksi halde animasyon ölür
    if ClientState.heldEquipment and SpawnCarryProp then
        local propKey = ClientState.heldEquipment
        if ClientState.heldEquipmentFull then
            propKey = propKey .. '_full'
        end
        SpawnCarryProp(propKey)
    end

    if ClientState.currentJob then
        local spot = ClientState.harvestSpots[spotIndex]
        if spot and spot.entity and DoesEntityExist(spot.entity) then
            ClearPedTasks(spot.entity)
            FreezeEntityPosition(spot.entity, false)
            local _r2 = ClientState.currentJob.region
            if not (_r2 and _r2.zone and _r2.zone.points and #_r2.zone.points >= 3 and _r2.center) then
                error('[HarvestComplete] Hayvan re-task: polyzone+center zorunlu')
            end
            if not _r2.zone.bounds then PrecomputeRegionBounds(_r2) end
            local _rad2 = GetZoneWanderRadius(_r2.zone)
            TaskWanderInArea(spot.entity, _r2.center.x, _r2.center.y, _r2.center.z or spot.coords.z, _rad2, 5, 10)
        end
    
        ClientState.currentJob.isHarvesting = false

        -- Track previous progress so we can detect whether the server actually
        -- advanced. Server's FailHarvest path (e.g. distance failure) reuses the
        -- harvestResult event with success=false but does NOT increment
        -- group.progress and does NOT send syncProgress. If we unconditionally
        -- mark the spot as collected here, the HUD shows 100% while the server
        -- still considers the job incomplete — causing the NPC to refuse to pay
        -- and the vehicle return prompt to never appear.
        local prevProgress = ClientState.currentJob.progress or 0
        ClientState.currentJob.progress = progress
        local serverAdvanced = (progress or 0) > prevProgress

        if ClientState.harvestSpots[spotIndex] then
            ClientState.harvestSpots[spotIndex].beingHarvested = false

            -- Only mark as collected if the server truly advanced. For real
            -- successes, syncProgress will arrive immediately after this event
            -- and also mark collected=true (idempotent). For real failures
            -- (e.g. minigame fail) the server still advances progress, so we
            -- still mark here. For server-side rejections (FailHarvest) we keep
            -- the spot interactable so the player can retry.
            if serverAdvanced then
                ClientState.harvestSpots[spotIndex].collected = true

                if ClientState.harvestSpots[spotIndex].blip and DoesBlipExist(ClientState.harvestSpots[spotIndex].blip) then
                    RemoveBlip(ClientState.harvestSpots[spotIndex].blip)
                end
            end
        end

        UpdateJobPanelProgress()

        local region = ClientState.currentJob.region
        local totalSpots = region and #(region.harvestSpots or {}) or 0

        if totalSpots > 0 and progress >= totalSpots then
            ClientState.currentJob.isComplete = true
            SendNUIMessage({
                action = 'updateJobStep',
                data = 'finish'
            })
            SendNUIMessage({
                action = 'updateJobComplete',
                data = true
            })
            DebugPrint('Job completed! Progress:', progress, '/', totalSpots)
        end
        
        if success and itemsGained and itemsGained > 0 then
            local spot = ClientState.harvestSpots[spotIndex]
            local spotType = spot and spot.type
            local cropInfo = spotType and Config.Items[spotType]
            if cropInfo then
                Krypton.Notify(T('harvest_success', itemsGained, GetItemLabel(spotType)), 'success')
            end
        end
    end
end)
