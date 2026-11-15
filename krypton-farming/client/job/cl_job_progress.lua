function GetProgressText(region)
    if not region then return T('action_harvest') end

    local typeCounts = {}
    if region.harvestSpots then
        for _, spot in ipairs(region.harvestSpots) do
            if spot.type then
                typeCounts[spot.type] = (typeCounts[spot.type] or 0) + 1
            end
        end
    end

    local parts = {}
    
    for spotType, count in pairs(typeCounts) do
        local itemConfig = Config.Items and Config.Items[spotType] or {}
        local isAnimal = itemConfig.animal ~= nil

        local cropName = T('crop_' .. spotType)
        if cropName == ('crop_' .. spotType) then
            cropName = spotType
        end

        local actionKey = isAnimal and (itemConfig.animal == 'cow' and 'milk' or 'collect') or 'harvest'
        local action = T('action_' .. actionKey)
        if action == ('action_' .. actionKey) then
            action = actionKey
        end

        local cropLower = string.lower(cropName)
        local actionLower = string.lower(action)
        table.insert(parts, T('progress_task', count, cropLower, actionLower))
    end

    if #parts == 0 then
        return T('progress_task', region.totalHarvestCount or 0, string.lower(T('crop_default')), string.lower(T('action_harvest')))
    end

    return table.concat(parts, T('progress_task_separator'))
end

function BuildTypeProgressList(region)
    local list = {}
    if not region or not region.harvestSpots then return list end

    -- OLD SYSTEM: Show per-type harvest progress
    local seen = {}
    for _, spot in ipairs(region.harvestSpots) do
        local spotType = spot.type
        if spotType and not seen[spotType] then
            seen[spotType] = true

            local total = 0
            for _, s in ipairs(region.harvestSpots) do
                if s.type == spotType then total = total + 1 end
            end

            local current = 0
            for _, s in pairs(ClientState.harvestSpots or {}) do
                if s.type == spotType and s.collected then current = current + 1 end
            end

            local itemConfig = Config.Items and Config.Items[spotType] or {}
            local isAnimal = itemConfig.animal ~= nil
            local icon = itemConfig.icon or 'fas fa-leaf'

            local cropName = T('crop_' .. spotType)
            if cropName == ('crop_' .. spotType) then
                cropName = spotType
            end

            local actionKey = isAnimal and (itemConfig.animal == 'cow' and 'milk' or 'collect') or 'harvest'
            local action = T('action_' .. actionKey)
            if action == ('action_' .. actionKey) then
                action = actionKey
            end

            local text = T('progress_task', total, string.lower(cropName), string.lower(action))
            table.insert(list, { 
                text = text, 
                current = current, 
                max = total,
                icon = icon,
                cropType = spotType
            })
        end
    end

    return list
end

-- Returns: { crops = [ { name, icon, total, water, fertilize, harvest } ] }
function BuildCycleProgressList(region)
    local crops = {}
    if not region or not region.harvestSpots then return { crops = crops } end
    
    local typeGroups = {} -- [type] = { spots = {}, total = 0 }
    for i, spotConfig in ipairs(region.harvestSpots) do
        local spotType = spotConfig.type
        if spotType then
            if not typeGroups[spotType] then
                typeGroups[spotType] = { spots = {}, total = 0 }
            end
            typeGroups[spotType].total = typeGroups[spotType].total + 1
            table.insert(typeGroups[spotType].spots, i)
        end
    end
    
    for spotType, groupData in pairs(typeGroups) do
        local total = groupData.total
        
        local waterDone = 0
        local fertilizeDone = 0
        local harvestDone = 0
        
        for _, spotIndex in ipairs(groupData.spots) do
            local spot = ClientState.harvestSpots[spotIndex]
            if spot then
                if spot.collected then
                    waterDone = waterDone + 1
                    fertilizeDone = fertilizeDone + 1
                    harvestDone = harvestDone + 1
                elseif spot.phase == 'ready' then
                    waterDone = waterDone + 1
                    fertilizeDone = fertilizeDone + 1
                elseif spot.phase == 'growing2' then
                    waterDone = waterDone + 1
                    fertilizeDone = fertilizeDone + 1
                elseif spot.phase == 'fertilize' then
                    waterDone = waterDone + 1
                elseif spot.phase == 'growing1' then
                    waterDone = waterDone + 1
                end
            end
        end
        
        local itemConfig = Config.Items and Config.Items[spotType] or {}
        local cropIcon = itemConfig.icon or 'fas fa-leaf'
        local cropName = T('crop_default')
        if spotType then
            local localeKey = 'crop_' .. spotType
            local localizedCrop = T(localeKey)
            if localizedCrop ~= localeKey then
                cropName = localizedCrop
            else
                cropName = spotType
            end
        end
        
        table.insert(crops, {
            name = cropName,
            label = GetItemLabel(spotType),
            icon = cropIcon,
            type = spotType,
            total = total,
            water = { current = waterDone, max = total },
            fertilize = { current = fertilizeDone, max = total },
            harvest = { current = harvestDone, max = total }
        })
    end
    
    return { crops = crops }
end

-- Returns: { animals = [ { name, label, icon, type, total, feed, collect } ] }
function BuildLivestockProgressList(region)
    local animals = {}
    if not region or not region.harvestSpots then return { animals = animals } end

    local typeGroups = {}
    for i, spotConfig in ipairs(region.harvestSpots) do
        local spotType = spotConfig.type
        if spotType then
            if not typeGroups[spotType] then
                typeGroups[spotType] = { spots = {}, total = 0 }
            end
            typeGroups[spotType].total = typeGroups[spotType].total + 1
            table.insert(typeGroups[spotType].spots, i)
        end
    end

    for spotType, groupData in pairs(typeGroups) do
        local total = groupData.total
        local fedDone = 0
        local collectDone = 0

        for _, spotIndex in ipairs(groupData.spots) do
            local spot = ClientState.harvestSpots and ClientState.harvestSpots[spotIndex]
            if spot then
                if spot.collected then
                    fedDone = fedDone + 1
                    collectDone = collectDone + 1
                elseif spot.phase == 'ready' then
                    fedDone = fedDone + 1
                elseif spot.phase == 'growing_livestock' then
                    fedDone = fedDone + 1
                end
            end
        end

        local itemConfig = Config.Items and Config.Items[spotType] or {}
        local animalIcon = itemConfig.icon or 'fas fa-paw'
        local animalName = spotType
        local localeKey = 'crop_' .. spotType
        local localizedName = T(localeKey)
        if localizedName ~= localeKey then
            animalName = localizedName
        end

        table.insert(animals, {
            name = animalName,
            label = GetItemLabel(spotType),
            icon = animalIcon,
            type = spotType,
            total = total,
            feed    = { current = fedDone,     max = total },
            collect = { current = collectDone,  max = total }
        })
    end

    return { animals = animals }
end

RegisterNetEvent('krypton-farming:client:syncProgress', function(progress, collectedSpots)
    DebugPrint('=== SYNC PROGRESS EVENT RECEIVED === Progress:', progress, 'CollectedSpots:', #collectedSpots)
    DebugPrint('[Sync] Collected spot indices:', json.encode(collectedSpots))
    
    if ClientState.currentJob then
        ClientState.currentJob.progress = progress
        
        for _, spotIndex in ipairs(collectedSpots) do
            if ClientState.harvestSpots[spotIndex] then
                local spot = ClientState.harvestSpots[spotIndex]
                
                DebugPrint('[Sync] Processing spot', spotIndex, '- Already collected:', spot.collected)
                
                local wasCollected = spot.collected
                spot.collected = true
                spot.beingHarvested = false
                
                if spot.blip and DoesBlipExist(spot.blip) then
                    RemoveBlip(spot.blip)
                end
                
                -- Delete prop entities (plants, eggs, etc.) - only once
                if not wasCollected then
                    local itemConfig = Config.Items and Config.Items[spot.type]
                    local isAnimal = itemConfig and itemConfig.animal ~= nil
                    if not isAnimal then
                        if spot.entity and DoesEntityExist(spot.entity) then
                            DeleteEntity(spot.entity)
                            DebugPrint('[Sync] Deleted prop entity for spot', spotIndex)
                        end
                    end
                end
            else
                DebugPrint('[Sync] WARNING: Spot', spotIndex, 'not found in harvestSpots table!')
            end
        end
        
        UpdateJobPanelProgress()
        
        local region = ClientState.currentJob.region
        local totalSpots = region and #(region.harvestSpots or {}) or 0
        
        if progress >= totalSpots then
            DebugPrint('[Sync] Job completed! Marking as complete. Progress:', progress, '/', totalSpots)
            ClientState.currentJob.isComplete = true
            SendNUIMessage({
                action = 'updateJobStep',
                data = 'finish'
            })
            SendNUIMessage({
                action = 'updateJobComplete',
                data = true
            })
        end
    else
        DebugPrint('ERROR: syncProgress received but no current job!')
    end
end)

RegisterCommand('+farming_panel_toggle', function()
    if ClientState.isJobActive and ClientState.currentJob and ClientState.currentJob.arrivedAtField then
        SendNUIMessage({ action = 'toggleJobPanelExpand' })
    end
end, false)
RegisterCommand('-farming_panel_toggle', function() end, false)
RegisterKeyMapping('+farming_panel_toggle', 'Farming: Toggle Job Panel Detail', 'keyboard', 'b')

RegisterCommand('+farming_panel_left', function()
    if ClientState.isJobActive and ClientState.currentJob then
        SendNUIMessage({ action = 'jobPanelNavLeft' })
    end
end, false)
RegisterCommand('-farming_panel_left', function() end, false)
RegisterKeyMapping('+farming_panel_left', 'Farming: Previous Crop', 'keyboard', 'LEFT')

RegisterCommand('+farming_panel_right', function()
    if ClientState.isJobActive and ClientState.currentJob then
        SendNUIMessage({ action = 'jobPanelNavRight' })
    end
end, false)
RegisterCommand('-farming_panel_right', function() end, false)
RegisterKeyMapping('+farming_panel_right', 'Farming: Next Crop', 'keyboard', 'RIGHT')
