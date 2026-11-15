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

local function GetGroundZCoord(x, y, z)
    -- Try raycast from above for accurate ground detection (handles slopes)
    local startZ = z + 10.0
    local endZ = z - 10.0
    local rayHandle = StartShapeTestRay(x, y, startZ, x, y, endZ, 1 + 16, PlayerPedId(), 0)
    local _, hit, endCoords, _, _ = GetShapeTestResult(rayHandle)
    if hit == 1 then
        return endCoords.z
    end
    local found, groundZ = GetGroundZFor_3dCoord(x, y, z + 5.0, false)
    if found then
        return groundZ
    end
    return z
end

-- zOffset: optional per-item correction applied after native placement
local function PlaceObjectOnGround(entity, x, y, z, zOffset)
    zOffset = zOffset or 0.0
    local groundZ = GetGroundZCoord(x, y, z)
    SetEntityCoords(entity, x, y, groundZ, false, false, false, false)

    -- Use native placement as secondary correction
    PlaceObjectOnGroundProperly(entity)
    Wait(0) -- Let engine process placement before reading back coords

    -- Final raycast verification to ensure no floating
    local finalPos = GetEntityCoords(entity)
    local verifyZ = GetGroundZCoord(finalPos.x, finalPos.y, finalPos.z)
    if finalPos.z - verifyZ > 0.15 then
        SetEntityCoords(entity, finalPos.x, finalPos.y, verifyZ, false, false, false, false)
        PlaceObjectOnGroundProperly(entity)
        Wait(0) -- Let engine process placement before applying zOffset
    end

    -- Apply item-specific offset on top of final placement (e.g. to fix floating models)
    if zOffset ~= 0.0 then
        local adjustedPos = GetEntityCoords(entity)
        SetEntityCoords(entity, adjustedPos.x, adjustedPos.y, adjustedPos.z + zOffset, false, false, false, false)
    end
end

local function GetPropForPhase(itemConfig, phase)
    if not itemConfig then return nil end
    if phase == 'water' then
        return itemConfig.grow1prop
    elseif phase == 'growing1' then
        return itemConfig.grow1prop -- still seedling while growing
    elseif phase == 'fertilize' then
        return itemConfig.grow2prop
    elseif phase == 'growing2' then
        return itemConfig.grow2prop -- still mid-growth while growing
    else -- 'ready' or anything else
        return itemConfig.grow3prop
    end
end

function SwapCropProp(spot)
    local itemConfig = Config.Items and Config.Items[spot.type]
    if not itemConfig or itemConfig.animal then return end -- skip animals

    local newModelName = GetPropForPhase(itemConfig, spot.phase)
    if not newModelName then return end

    local newModel = GetHashKey(newModelName)

    -- Prevent concurrent swaps: timer thread and syncPhase event can race
    if spot._swapping then return end

    if spot.entity and DoesEntityExist(spot.entity) and GetEntityModel(spot.entity) == newModel then
        return
    end

    spot._swapping = true

    RequestModel(newModel)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(newModel) do
        Wait(10)
        if GetGameTimer() > timeout then
            DebugWarn('Model load timeout for swap:', newModelName)
            spot._swapping = nil
            return
        end
    end

    -- Re-check after model load yield: another coroutine may have completed the swap
    if spot.entity and DoesEntityExist(spot.entity) and GetEntityModel(spot.entity) == newModel then
        spot._swapping = nil
        return
    end

    local coords = spot.coords
    local heading = spot.heading or 0.0

    if Config.HarvestInteraction == 'target' and Target and spot.entity and DoesEntityExist(spot.entity) then
        Target.RemoveLocalEntity(spot.entity)
    end

    -- Delete old entity with retry (clear outline first to prevent stale render state)
    local oldEntity = spot.entity
    local oldModel = spot.entityModel
    if oldEntity then
        if DoesEntityExist(oldEntity) then
            SetEntityDrawOutline(oldEntity, false)
            SetEntityAsMissionEntity(oldEntity, false, true)
            DeleteEntity(oldEntity)
        end
        -- Verify deletion: if still exists after first attempt, retry
        if DoesEntityExist(oldEntity) then
            Wait(50)
            SetEntityAsMissionEntity(oldEntity, false, true)
            DeleteEntity(oldEntity)
        end
    end

    -- Fallback: if old model is known, sweep for orphaned prop near coords
    if oldModel and oldModel ~= newModel then
        local orphan = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, oldModel, false, false, false)
        if orphan and orphan ~= 0 and DoesEntityExist(orphan) then
            SetEntityAsMissionEntity(orphan, false, true)
            DeleteEntity(orphan)
            DebugPrint('[PropSwap] Cleaned orphaned old-model prop at spot', spot.index)
        end
    end

    local zOff = (itemConfig and itemConfig.zOffset) or 0.0
    pcall(function() exports['FeloxAC']:CreateObject(newModel) end) --[[FeloxAC:auto]]
    local obj = CreateObject(newModel, coords.x, coords.y, coords.z, false, true, false)
    SetEntityDrawOutline(obj, false) -- Initialize clean outline state
    SetEntityAsMissionEntity(obj, true, true) -- Prevent engine auto-culling
    PlaceObjectOnGround(obj, coords.x, coords.y, coords.z, zOff)
    FreezeEntityPosition(obj, true)
    spot.entity = obj
    spot.entityModel = newModel -- Update stored model for fallback cleanup

    -- Safety sweep: remove any duplicate of the new model left by a prior race
    local dup = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.0, newModel, false, false, false)
    if dup and dup ~= 0 and dup ~= obj and DoesEntityExist(dup) then
        SetEntityAsMissionEntity(dup, false, true)
        DeleteEntity(dup)
        DebugPrint('[PropSwap] Removed duplicate new-model prop at spot', spot.index)
    end

    if Config.HarvestInteraction == 'target' and Target then
        local region = ClientState.currentJob and ClientState.currentJob.region
        AddHarvestTarget(obj, spot, itemConfig, region)
    end

    DebugPrint('[PropSwap] Spot', spot.index, 'swapped to', newModelName, 'for phase', spot.phase)
    spot._swapping = nil
end

function SpawnHarvestSpots(region)
    ClientState.harvestSpots = {}
    
    if region.type ~= 'livestock' then
        for _, sp in ipairs(region.harvestSpots or {}) do
            local itemCfg = Config.Items and Config.Items[sp.type]
            if itemCfg and itemCfg.animal then
                region.type = 'livestock'
                break
            end
        end
    end
    local isLivestock = region.type == 'livestock'

    -- Check if this region uses cycle system (livestock always uses cycle)
    local useCycleSystem = isLivestock or (Config.Jobs and region and (region.useCycleSystem or region.useCycle))

    for i, spot in ipairs(region.harvestSpots) do
        local itemConfig = Config.Items and Config.Items[spot.type]
        local isAnimal = itemConfig and itemConfig.animal ~= nil
        local animalConfig = isAnimal and Animals[itemConfig.animal]
        local spotData = {
            coords = spot.coords,
            collected = false,
            index = i,
            entity = nil,
            type = spot.type,
            amount = spot.amount,
            heading = spot.heading,
            -- Flow (crop): water -> growing1 -> fertilize -> growing2 -> ready
            -- Flow (livestock): unfed -> growing_livestock -> ready
            phase = useCycleSystem and (region.type == 'livestock' and 'unfed' or 'water') or 'ready',
            growEndTime = nil,
            fertilized = false
        }

        local modelName = isAnimal and animalConfig and animalConfig.model or (useCycleSystem and itemConfig and itemConfig.grow1prop or (itemConfig and itemConfig.grow3prop))
        if modelName then
            local model = GetHashKey(modelName)
            RequestModel(model)
            local modelTimeout = GetGameTimer() + 5000
            while not HasModelLoaded(model) do
                Wait(10)
                if GetGameTimer() > modelTimeout then
                    DebugWarn('Model load timeout for', modelName, '- skipping spot', i)
                    goto continue
                end
            end

            if isAnimal then
                -- Animals are spawned server-side now. We only set up the spot
                -- shell; the animalNetIdRegistered event will resolve the entity,
                -- attach the target, and apply tasks once the netId arrives.
                spotData.entity = nil
                spotData.netId = nil
                spotData.isAnimal = true
            else
                local zOff = (itemConfig and itemConfig.zOffset) or 0.0
                local obj = CreateObject(model, spot.coords.x, spot.coords.y, spot.coords.z, false, true, false)
                SetEntityDrawOutline(obj, false) -- Initialize clean outline state
                SetEntityAsMissionEntity(obj, true, true) -- Prevent engine auto-culling
                PlaceObjectOnGround(obj, spot.coords.x, spot.coords.y, spot.coords.z, zOff)
                FreezeEntityPosition(obj, true)
                spotData.entity = obj
                spotData.entityModel = model -- Store model hash for fallback cleanup
                if Config.HarvestInteraction == 'target' and Target then
                    AddHarvestTarget(obj, spotData, itemConfig, region)
                end
            end
        end

        -- Minimap blip — one per spot, always created after entity setup
        local blip = AddBlipForCoord(spot.coords.x, spot.coords.y, spot.coords.z)
        SetBlipSprite(blip, 1)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.5)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)
        spotData.blip = blip
        
        UpdateSpotBlip(spotData)

        ClientState.harvestSpots[i] = spotData
        ::continue::
    end

    ClientState.ambientPeds = ClientState.ambientPeds or {}
    if region.ambientPed then
        local ambientModel = GetHashKey(region.ambientPed)
        RequestModel(ambientModel)
        local ambientTimeout = GetGameTimer() + 5000
        while not HasModelLoaded(ambientModel) do
            Wait(10)
            if GetGameTimer() > ambientTimeout then
                DebugWarn('Ambient ped model load timeout for', region.ambientPed)
                goto skip_ambient
            end
        end
        
        for i = 1, 5 do -- Spawn 5 ambient entities
            local offsetX = math.random(-5, 5)
            local offsetY = math.random(-5, 5)
            pcall(function() exports['FeloxAC']:CreatePed(ambientModel) end) --[[FeloxAC:auto]]
            local ped = CreatePed(28, ambientModel, region.center.x + offsetX, region.center.y + offsetY, region.center.z + 1.0, math.random(0, 360) * 1.0, false, true)
            
            TaskWanderInArea(ped, region.center.x, region.center.y, region.center.z, 20.0, 5, 10)
            SetEntityAsMissionEntity(ped, true, true)
            SetEntityInvincible(ped, true)
            
            table.insert(ClientState.ambientPeds, ped)
        end
        ::skip_ambient::
    end
    
    DebugPrint('Spawned', #ClientState.harvestSpots, 'entities for region', region.id, '| Cycle System:', useCycleSystem)

    -- Apply any animalNetIdRegistered events that arrived before spots existed
    if FlushPendingAnimalNetIds then FlushPendingAnimalNetIds() end

    -- Request server to sync current group state (handles reconnect + late group join)
    TriggerServerEvent('krypton-farming:server:requestRestore')
end
