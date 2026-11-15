local currentHarvestPromptSpot = nil
local currentGrowthPromptSpot = nil
local currentOutlinedEntity = nil
local currentOutlineR, currentOutlineG, currentOutlineB = 0, 0, 0
local lastGrowthPercent = -1

-- Separate thread: growth timer checks (runs every 500ms, no per-frame cost)
local function StartGrowthTimerThread()
    CreateThread(function()
        while ClientState.isJobActive and ClientState.currentJob do
            local now = GetGameTimer()
            for _, spot in pairs(ClientState.harvestSpots) do
                if not spot.collected then
                    if spot.phase == 'growing1' and spot.growEndTime and now >= spot.growEndTime then
                        spot.phase = 'fertilize'
                        spot.growEndTime = nil
                        spot.growStartTime = nil
                        DebugPrint('[Cycle] Spot', spot.index, 'first growth complete - ready for fertilize')
                        TriggerServerEvent('krypton-farming:server:spotPhaseChanged', spot.index, 'fertilize')
                        if SwapCropProp then SwapCropProp(spot) end
                        -- Deferred orphan sweep: check a second time after streaming catches up
                        local spotRef = spot
                        SetTimeout(1000, function()
                            if spotRef and spotRef.entityModel and spotRef.coords then
                                local itemCfg = Config.Items and Config.Items[spotRef.type]
                                if itemCfg and itemCfg.grow1prop then
                                    local oldModel = GetHashKey(itemCfg.grow1prop)
                                    if oldModel ~= spotRef.entityModel then
                                        local orphan = GetClosestObjectOfType(spotRef.coords.x, spotRef.coords.y, spotRef.coords.z, 2.0, oldModel, false, false, false)
                                        if orphan and orphan ~= 0 and DoesEntityExist(orphan) then
                                            SetEntityAsMissionEntity(orphan, false, true)
                                            DeleteEntity(orphan)
                                            DebugPrint('[Cycle] Deferred cleanup: removed orphan grow1 prop at spot', spotRef.index)
                                        end
                                    end
                                end
                            end
                        end)
                        TriggerEvent('krypton-farming:client:notify', T('first_growth_complete'), 'success')
                        UpdateJobPanelProgress()
                        if UpdateSpotBlip then UpdateSpotBlip(spot) end
                    elseif spot.phase == 'growing2' and spot.growEndTime and now >= spot.growEndTime then
                        spot.phase = 'ready'
                        spot.growEndTime = nil
                        spot.growStartTime = nil
                        DebugPrint('[Cycle] Spot', spot.index, 'second growth complete - ready for harvest')
                        TriggerServerEvent('krypton-farming:server:spotPhaseChanged', spot.index, 'ready')
                        if SwapCropProp then SwapCropProp(spot) end
                        local spotRef = spot
                        SetTimeout(1000, function()
                            if spotRef and spotRef.entityModel and spotRef.coords then
                                local itemCfg = Config.Items and Config.Items[spotRef.type]
                                if itemCfg and itemCfg.grow2prop then
                                    local oldModel = GetHashKey(itemCfg.grow2prop)
                                    if oldModel ~= spotRef.entityModel then
                                        local orphan = GetClosestObjectOfType(spotRef.coords.x, spotRef.coords.y, spotRef.coords.z, 2.0, oldModel, false, false, false)
                                        if orphan and orphan ~= 0 and DoesEntityExist(orphan) then
                                            SetEntityAsMissionEntity(orphan, false, true)
                                            DeleteEntity(orphan)
                                            DebugPrint('[Cycle] Deferred cleanup: removed orphan grow2 prop at spot', spotRef.index)
                                        end
                                    end
                                end
                            end
                        end)
                        TriggerEvent('krypton-farming:client:notify', T('growth_complete'), 'success')
                        UpdateJobPanelProgress()
                        if UpdateSpotBlip then UpdateSpotBlip(spot) end
                    end
                end
            end
            Wait(500)
        end
    end)
end

local function GetPhaseColor(spot)
    if spot.failed then return 255, 0, 0 end
    local phase = spot.phase
    if phase == 'water' then return 66, 165, 245
    elseif phase == 'growing1' then return 255, 193, 7
    elseif phase == 'fertilize' then return 156, 39, 176
    elseif phase == 'growing2' then return 255, 152, 0
    elseif phase == 'unfed' then return 0, 188, 212
    elseif phase == 'growing_livestock' then return 255, 193, 7
    elseif phase == 'ready' then return 76, 175, 80
    end
    return 255, 255, 255
end

local _scan = {}
local function ScanNearbySpots(playerCoords, harvestSpots, itemConfigs, isAnimalSpot, interactionMode)
    _scan.nearestSpot = nil
    _scan.nearestDist = 999
    _scan.outlineEntity = nil
    _scan.outlineR, _scan.outlineG, _scan.outlineB = 255, 255, 255
    _scan.animalMarkerCoords = nil
    _scan.animalMarkerR, _scan.animalMarkerG, _scan.animalMarkerB = 255, 255, 255
    local outlineDist = 999
    local animalMarkerDist = 999

    for _, spot in pairs(harvestSpots) do
        if not spot.collected and not spot.beingHarvested then
            local isAnimal = isAnimalSpot[spot.index]
            local hasEntity = spot.entity and DoesEntityExist(spot.entity)

            -- Animals: skip if entity not resolved yet (no marker, no prompt — avoids ghost selection)
            if isAnimal and not hasEntity then
                goto nextSpot
            end

            local targetCoords = (isAnimal and hasEntity) and GetEntityCoords(spot.entity) or spot.coords

            local dx = playerCoords.x - targetCoords.x
            local dy = playerCoords.y - targetCoords.y
            local flatDistSq = dx * dx + dy * dy

            if flatDistSq > 400.0 then
                if flatDistSq < _scan.nearestDist * _scan.nearestDist then
                    _scan.nearestDist = math.sqrt(flatDistSq)
                    _scan.nearestSpot = spot
                end
                goto nextSpot
            end

            local dist = #(playerCoords - targetCoords)
            if dist < _scan.nearestDist then
                _scan.nearestDist = dist
                _scan.nearestSpot = spot
            end

            if hasEntity then
                local r, g, b = GetPhaseColor(spot)

                if not isAnimal and interactionMode ~= 'target' then
                    if dist < 8.0 and dist < outlineDist then
                        _scan.outlineEntity = spot.entity
                        outlineDist = dist
                        _scan.outlineR, _scan.outlineG, _scan.outlineB = r, g, b
                    end
                elseif isAnimal then
                    if dist < 18.0 and dist < animalMarkerDist then
                        animalMarkerDist = dist
                        _scan.animalMarkerCoords = targetCoords
                        _scan.animalMarkerR, _scan.animalMarkerG, _scan.animalMarkerB = r, g, b
                    end
                end
            end
        end
        ::nextSpot::
    end
    return _scan
end

local function UpdateOutlineState(wantOutline, outlineR, outlineG, outlineB)
    if wantOutline ~= currentOutlinedEntity then
        if currentOutlinedEntity and DoesEntityExist(currentOutlinedEntity) then
            SetEntityDrawOutline(currentOutlinedEntity, false)
        end
        if wantOutline and DoesEntityExist(wantOutline) then
            SetEntityDrawOutlineShader(0)
            SetEntityDrawOutlineColor(outlineR, outlineG, outlineB, 200)
            SetEntityDrawOutline(wantOutline, true)
            currentOutlineR, currentOutlineG, currentOutlineB = outlineR, outlineG, outlineB
        end
        currentOutlinedEntity = wantOutline
    elseif wantOutline and DoesEntityExist(wantOutline) then
        if outlineR ~= currentOutlineR or outlineG ~= currentOutlineG or outlineB ~= currentOutlineB then
            SetEntityDrawOutlineColor(outlineR, outlineG, outlineB, 200)
            currentOutlineR, currentOutlineG, currentOutlineB = outlineR, outlineG, outlineB
        end
    end
end

local function UpdateCustomPrompt(showPrompt, nearestSpot, nearestDist, itemConfigs, isAnimalSpot, useCycleSystem)
    if showPrompt and currentHarvestPromptSpot ~= nearestSpot.index then
        local itemConfig = itemConfigs[nearestSpot.index]
        local isAnimal = isAnimalSpot[nearestSpot.index]
        local action = isAnimal and (itemConfig.animal == 'cow' and 'milk' or 'collect') or 'harvest'
        local icon = itemConfig and itemConfig.icon or 'fas fa-wheat-awn'
        local promptText = GetPhaseLabel(nearestSpot, icon, action, useCycleSystem)
        local promptIcon = useCycleSystem and GetPhaseIcon(nearestSpot.phase) or GetActionIcon(action, itemConfig)

        if currentGrowthPromptSpot then
            SendNUIMessage({ action = 'hideGrowthProgress' })
            currentGrowthPromptSpot = nil
        end

        SendNUIMessage({
            action = 'showHarvestPrompt',
            icon = promptIcon,
            harvestAction = action,
            itemName = nearestSpot.type,
            promptText = promptText,
            phase = nearestSpot.phase
        })
        currentHarvestPromptSpot = nearestSpot.index
    elseif not showPrompt and currentHarvestPromptSpot then
        SendNUIMessage({ action = 'hideHarvestPrompt' })
        currentHarvestPromptSpot = nil
    end

    if not showPrompt and nearestSpot and (nearestSpot.phase == 'growing1' or nearestSpot.phase == 'growing2' or nearestSpot.phase == 'growing_livestock') and nearestDist < 4.0 then
        if currentGrowthPromptSpot ~= nearestSpot.index then
            local remaining = 0
            local percentage = 0
            if nearestSpot.growEndTime and nearestSpot.growStartTime then
                local now = GetGameTimer()
                local totalTime = nearestSpot.growEndTime - nearestSpot.growStartTime
                local elapsed = now - nearestSpot.growStartTime
                remaining = math.max(0, nearestSpot.growEndTime - now)
                if totalTime > 0 then
                    percentage = math.floor(math.min(100, (elapsed / totalTime) * 100))
                end
            elseif nearestSpot.growEndTime then
                remaining = math.max(0, nearestSpot.growEndTime - GetGameTimer())
            end
            SendNUIMessage({
                action = 'showGrowthProgress',
                phase = nearestSpot.phase,
                percentage = percentage,
                remainingSeconds = math.ceil(remaining / 1000),
                phaseLabel = nearestSpot.phase == 'growing1' and T('growing1') or (nearestSpot.phase == 'growing_livestock' and (T('growing_livestock') or T('growing')) or T('growing2'))
            })
            currentGrowthPromptSpot = nearestSpot.index
            lastGrowthPercent = percentage
        end
    elseif currentGrowthPromptSpot and (not nearestSpot or nearestDist >= 4.0 or (nearestSpot.phase ~= 'growing1' and nearestSpot.phase ~= 'growing2' and nearestSpot.phase ~= 'growing_livestock')) then
        SendNUIMessage({ action = 'hideGrowthProgress' })
        currentGrowthPromptSpot = nil
        lastGrowthPercent = -1
    end
end

function StartHarvestLoop()
    local region = ClientState.currentJob.region
    local isLivestock = region.type == 'livestock'
    local useCycleSystem = isLivestock or (Config.Jobs and region and (region.useCycleSystem or region.useCycle))
    local interactionMode = Config.HarvestInteraction or 'custom'

    StartGrowthTimerThread()

    -- Stale beingHarvested cleanup thread (group sync race guard)
    CreateThread(function()
        while ClientState.isJobActive and ClientState.currentJob do
            local now = GetGameTimer()
            for _, spot in pairs(ClientState.harvestSpots) do
                if spot.beingHarvested and spot._harvestLockTime then
                    if (now - spot._harvestLockTime) > 15000 then
                        DebugPrint('[HarvestLoop] Auto-clearing stale beingHarvested for spot', spot.index)
                        spot.beingHarvested = false
                        spot.harvesterId = nil
                        spot._harvestLockTime = nil
                    end
                end
            end
            Wait(5000)
        end
    end)

    lastGrowthPercent = -1
    CreateThread(function()
        while ClientState.isJobActive and ClientState.currentJob do
            if interactionMode == 'custom' and currentGrowthPromptSpot then
                local spot = ClientState.harvestSpots[currentGrowthPromptSpot]
                if spot and (spot.phase == 'growing1' or spot.phase == 'growing2' or spot.phase == 'growing_livestock') and spot.growEndTime and spot.growStartTime then
                    local now = GetGameTimer()
                    local totalTime = spot.growEndTime - spot.growStartTime
                    local elapsed = now - spot.growStartTime
                    local remaining = math.max(0, spot.growEndTime - now)
                    local percentage = 0
                    if totalTime > 0 then
                        percentage = math.floor(math.min(100, (elapsed / totalTime) * 100))
                    end
                    -- Only send NUI when percentage actually changed
                    if percentage ~= lastGrowthPercent then
                        SendNUIMessage({
                            action = 'updateGrowthProgress',
                            percentage = percentage,
                            remainingSeconds = math.ceil(remaining / 1000)
                        })
                        lastGrowthPercent = percentage
                    end
                end
            else
                lastGrowthPercent = -1
            end
            Wait(500)
        end
    end)

    CreateThread(function()
        -- Cache item configs once (they don't change at runtime)
        local itemConfigs = {}
        local isAnimalSpot = {}
        for _, spot in pairs(ClientState.harvestSpots) do
            local cfg = Config.Items and Config.Items[spot.type]
            itemConfigs[spot.index] = cfg
            isAnimalSpot[spot.index] = cfg and cfg.animal ~= nil
        end

        while ClientState.isJobActive and ClientState.currentJob do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local scan = ScanNearbySpots(playerCoords, ClientState.harvestSpots, itemConfigs, isAnimalSpot, interactionMode)

            local wantOutline = (interactionMode ~= 'target') and scan.outlineEntity or nil
            UpdateOutlineState(wantOutline, scan.outlineR, scan.outlineG, scan.outlineB)

            if scan.animalMarkerCoords then
                DrawMarker(2, scan.animalMarkerCoords.x, scan.animalMarkerCoords.y, scan.animalMarkerCoords.z + 1.0,
                    0.0, 0.0, 0.0, 0.0, 180.0, 0.0,
                    0.2, 0.2, 0.2,
                    scan.animalMarkerR, scan.animalMarkerG, scan.animalMarkerB, 200,
                    true, true, 2, nil, nil, false)
            end

            local showPrompt = scan.nearestSpot and not scan.nearestSpot.collected and not scan.nearestSpot.beingHarvested and scan.nearestDist < 2.0
            if showPrompt and (scan.nearestSpot.phase == 'growing1' or scan.nearestSpot.phase == 'growing2' or scan.nearestSpot.phase == 'growing_livestock') then
                showPrompt = false
            end
            
            if interactionMode == 'custom' then
                UpdateCustomPrompt(showPrompt, scan.nearestSpot, scan.nearestDist, itemConfigs, isAnimalSpot, useCycleSystem)
            end
            
            if interactionMode ~= 'target' and showPrompt then
                if IsControlJustPressed(0, Config.HarvestKey) then
                    scan.nearestSpot.failed = false
                    scan.nearestSpot.beingHarvested = true
                    SendNUIMessage({ action = 'hideHarvestPrompt' })
                    currentHarvestPromptSpot = nil
                    HandlePhaseAction(scan.nearestSpot)
                    if ClientState.currentJob then
                        ClientState.currentJob.isHarvesting = false
                    end
                    scan.nearestSpot.beingHarvested = false
                end
            end
            
            if showPrompt or scan.animalMarkerCoords then
                Wait(0)
            elseif scan.nearestSpot and scan.nearestDist < 10.0 then
                Wait(50)
            else
                Wait(100)
            end
        end
        
        if currentOutlinedEntity and DoesEntityExist(currentOutlinedEntity) then
            SetEntityDrawOutline(currentOutlinedEntity, false)
        end
        currentOutlinedEntity = nil

        if currentHarvestPromptSpot then
            SendNUIMessage({ action = 'hideHarvestPrompt' })
            currentHarvestPromptSpot = nil
        end
        if currentGrowthPromptSpot then
            SendNUIMessage({ action = 'hideGrowthProgress' })
            currentGrowthPromptSpot = nil
        end
    end)
end

function UpdateJobPanelProgress()
    if not ClientState.currentJob then return end
    
    local region = ClientState.currentJob.region
    if not region then return end
    
    local progressText = GetProgressText(region)
    local totalSpots = #(region.harvestSpots or {})
    
    local isLivestock = region.type == 'livestock'
    local useCycleSystem = isLivestock or (Config.Jobs and region and (region.useCycleSystem or region.useCycle))
    
    local progressData = {
        current = ClientState.currentJob.progress or 0, 
        max = totalSpots, 
        text = progressText
    }
    
    if useCycleSystem then
        if region.type == 'livestock' then
            local lsData = BuildLivestockProgressList(region)
            progressData.animals = lsData.animals
            progressData.isLivestock = true
        else
            local cycleData = BuildCycleProgressList(region)
            progressData.crops = cycleData.crops
        end
    else
        local progressList = BuildTypeProgressList(region)
        progressData.list = progressList
    end
    
    SendNUIMessage({
        action = 'updateJobProgress',
        data = progressData
    })
    
    DebugPrint('[Cycle] Updated JobPanel progress')
end

DebugPrint('Harvest loop module loaded')
