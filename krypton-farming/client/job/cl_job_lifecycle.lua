RegisterNetEvent('krypton-farming:client:startJob', function(jobData)
    local region = jobData.region
    if not region then return end

    -- Force-close NPC dialog/menu if it's open (handles case where leader starts while member is in dialog)
    if ClientState.isUiOpen then
        ClientState.isUiOpen = false
        SetNuiFocus(false, false)
        if DestroyDialogueCam then DestroyDialogueCam() end
        SendNUIMessage({ action = 'hideAllUI' })
        DebugPrint('[Job] Force-closed NPC dialog because job is starting')
    end

    local seenCrops = {}
    local regionCrops = {}
    for _, spot in ipairs(region.harvestSpots or {}) do
        if spot.type and not seenCrops[spot.type] then
            seenCrops[spot.type] = true
            table.insert(regionCrops, spot.type)
        end
    end
    
    ClientState.isJobActive = true
    local totalSpots = #(region.harvestSpots or {})
    ClientState.currentJob = {
        regionId = jobData.regionId,
        groupId = jobData.groupId,
        progress = 0,
        totalSpots = totalSpots,
        currentSpot = nil,
        arrivedAtField = false,
        isComplete = false,
        region = region
    }
    
    if region.type ~= 'livestock' then
        for _, sp in ipairs(region.harvestSpots or {}) do
            local itemCfg = Config.Items and Config.Items[sp.type]
            if itemCfg and itemCfg.animal then
                region.type = 'livestock'
                break
            end
        end
    end

    local progressText = GetProgressText(region)
    local isLivestock = region.type == 'livestock'
    local useCycleSystem = isLivestock or (Config.Jobs and (region.useCycleSystem or region.useCycle))
    
    local progressData = { current = 0, max = totalSpots, text = progressText }
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
        action = 'setActiveJobPhase',
        data = {
            regionName = region.name,
            regionImage = region.image or '',
            regionType = region.type or 'agriculture',
            regionCrops = regionCrops,
            step = 'travel',
            progress = progressData
        }
    })

    SendNUIMessage({
        action = 'updatePlayerStatus',
        data = T('status_idle')
    })
    
    -- Close UI focus but keep NUI visible
    ClientState.isUiOpen = false
    SetNuiFocus(false, false)
    
    if region.center then
        local blip = AddBlipForCoord(region.center.x, region.center.y, region.center.z)
        SetBlipSprite(blip, 1) -- Circle
        SetBlipColour(blip, 2) -- Green
        SetBlipScale(blip, 1.0)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(T('field_blip'):format(region.name))
        EndTextCommandSetBlipName(blip)
        ClientState.centerBlip = blip
    end
    
    SetNewWaypoint(region.center.x, region.center.y)
    
    Krypton.Notify(T('job_started'), 'success')
    
    if jobData.vehicleJobType and Config.NPC[1] and Config.NPC[1].vehicle then
        SetupJobVehicle(jobData.vehicleJobType, jobData.vehicleEquipment)
    end
    
    StartFieldArrivalCheck(region)
    
    DebugPrint('Job started:', json.encode(ClientState.currentJob))
end)

RegisterNetEvent('krypton-farming:client:jobComplete', function()
    DebugPrint('=== JOB COMPLETE EVENT RECEIVED ===')
    if ClientState.currentJob then
        DebugPrint('Current job exists. RegionId:', ClientState.currentJob.regionId, 'Progress:', ClientState.currentJob.progress)
        ClientState.currentJob.isComplete = true
        SendNUIMessage({
            action = 'updateJobStep',
            data = 'finish'
        })
        SendNUIMessage({
            action = 'updateJobComplete',
            data = true
        })
        
        local region = ClientState.currentJob.region
        SetNewWaypoint(Config.NPC[ClientState.activeNpcIndex or 1].coords.x, Config.NPC[ClientState.activeNpcIndex or 1].coords.y)
        
        Krypton.Notify(T('harvest_complete'), 'success')
        DebugPrint('Job marked as complete, waypoint set to NPC')
    else
        DebugPrint('ERROR: jobComplete received but no current job!')
    end
end)

RegisterNetEvent('krypton-farming:client:finishJob', function(rewards)
    -- Force-close NPC dialog/menu if member is talking to NPC when job finishes
    if ClientState.isUiOpen then
        ClientState.isUiOpen = false
        SetNuiFocus(false, false)
        if DestroyDialogueCam then DestroyDialogueCam() end
        DebugPrint('[Job] Force-closed NPC dialog because job is finishing')
    end

    -- Unfreeze player if they were mid-harvest when job finished
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, false)
    ClearPedTasks(playerPed)
    if ClientState.currentJob then
        ClientState.currentJob.isHarvesting = false
    end

    -- First, signal UI that job is finished (resets isJobActiveRef)
    SendNUIMessage({
        action = 'jobFinished',
        data = rewards
    })
    
    ClientState.isJobActive = false
    
    -- Wait for threads to notice the flag change and stop
    Wait(200)
    
    -- Now safe to nil the job reference
    ClientState.currentJob = nil
    
    if DespawnHarvestSpots then DespawnHarvestSpots() end
    ClientState.harvestSpots = {}
    
    if CleanupJobVehicle then CleanupJobVehicle() end
    
    if ClientState.centerBlip then
        RemoveBlip(ClientState.centerBlip)
        ClientState.centerBlip = nil
    end

    Krypton.Notify(T('money_earned', rewards.money), 'success')
    Krypton.Notify(T('xp_gained', rewards.xp), 'success')
    
    if rewards.newLevel then
        Krypton.Notify(T('level_up', rewards.newLevel), 'success')
    end
    
    DebugPrint('Job finished with rewards:', json.encode(rewards))
end)

RegisterNetEvent('krypton-farming:client:cancelJob', function()
    -- Force-close NPC dialog/menu if member is talking to NPC when job is cancelled
    if ClientState.isUiOpen then
        ClientState.isUiOpen = false
        SetNuiFocus(false, false)
        if DestroyDialogueCam then DestroyDialogueCam() end
        DebugPrint('[Job] Force-closed NPC dialog because job is being cancelled')
    end

    -- Unfreeze player if they were mid-harvest when job was cancelled
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, false)
    ClearPedTasks(playerPed)
    if ClientState.currentJob then
        ClientState.currentJob.isHarvesting = false
    end

    -- Guard: if the NUI callback already cleaned up (quitJob / confirmQuitWithoutPayment),
    -- isJobActive is already false and world cleanup has already been done.
    -- Only run the full cleanup path for server-initiated cancels (kick, leader quit, etc.)
    local wasActive = ClientState.isJobActive

    ClientState.isJobActive = false
    ClientState.currentJob = nil

    -- Clean up harvest entities and blips (no-op if NUI already cleared harvestSpots)
    if DespawnHarvestSpots then DespawnHarvestSpots() end
    ClientState.harvestSpots = {}

    if CleanupJobVehicle then CleanupJobVehicle() end

    if ClientState.centerBlip then
        RemoveBlip(ClientState.centerBlip)
        ClientState.centerBlip = nil
    end

    -- Signal UI (idempotent — safe to call even if NUI already closed)
    SendNUIMessage({
        action = 'jobFinished',
        data = { cancelled = true }
    })

    -- Show notification only when server initiated the cancel (not double-notify on self-quit)
    if wasActive then
        Krypton.Notify(T('job_cancelled'), 'error')
    end
end)

RegisterNetEvent('krypton-farming:client:showInvite', function(inviterName)
    DebugPrint('[INVITE] Received invite from:', inviterName)
    -- Send locales along with invite so modal text is always available
    SendNUIMessage({
        action = 'updateLocales',
        data = GetLang()
    })
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'showInvite',
        data = { name = inviterName }
    })
    DebugPrint('[INVITE] NUI message sent, focus enabled')
end)

RegisterNetEvent('krypton-farming:client:updateGroupMembers', function(members)
    SendNUIMessage({
        action = 'updateGroupMembers',
        data = members
    })
    DebugPrint('Group members updated:', json.encode(members))
end)

RegisterNetEvent('krypton-farming:client:confirmQuitAsNonLeader', function()
    SendNUIMessage({
        action = 'showQuitConfirmation'
    })
    SetNuiFocus(true, true)
end)

RegisterNetEvent('krypton-farming:client:updateGroupStatus', function(groupData)
    if ClientState.currentJob then
        SendNUIMessage({
            action = 'updateGroupStatus',
            data = groupData
        })
    end
end)

DebugPrint('Job module loaded')
