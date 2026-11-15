local PendingPhaseSpot = nil
local PhaseApproved = false

RegisterNetEvent('krypton-farming:client:phaseApproved', function(spotIndex, phase)
    DebugPrint('[Cycle] Server approved', phase, 'for spot', spotIndex)
    if PendingPhaseSpot and PendingPhaseSpot.index == spotIndex then
        PhaseApproved = true
    end
end)

RegisterNetEvent('krypton-farming:client:phaseDenied', function(spotIndex, reason)
    DebugPrint('[Cycle] Server denied phase for spot', spotIndex, 'reason:', reason)
    PendingPhaseSpot = nil
    PhaseApproved = false
    
    if ClientState.harvestSpots[spotIndex] then
        ClientState.harvestSpots[spotIndex].beingHarvested = false
    end
    
    if reason == 'already_done' then
        Krypton.Notify(T('phase_already_done'), 'error')
    elseif reason == 'locked' then
        Krypton.Notify(T('spot_locked'), 'error')
    end
end)

-- Also sent to ALL members (including action performer) for consistency
RegisterNetEvent('krypton-farming:client:syncPhase', function(spotIndex, newPhase, growDuration)
    DebugPrint('[Cycle] Syncing phase for spot', spotIndex, '- New phase:', newPhase, 'Duration:', growDuration)
    if ClientState.harvestSpots[spotIndex] then
        local spot = ClientState.harvestSpots[spotIndex]
        local oldModel = spot.entityModel -- Capture model BEFORE swap
        spot.phase = newPhase
        spot.beingHarvested = false
        spot.harvesterId = nil
        spot.failed = false
        
        if UpdateSpotBlip then UpdateSpotBlip(spot) end
        
        if SwapCropProp then SwapCropProp(spot) end
        
        -- Deferred orphan sweep: ensures old-model props are removed even if streaming raced
        if oldModel and oldModel ~= spot.entityModel and spot.coords then
            SetTimeout(1000, function()
                local s = ClientState.harvestSpots[spotIndex]
                if s and s.coords then
                    local orphan = GetClosestObjectOfType(s.coords.x, s.coords.y, s.coords.z, 2.0, oldModel, false, false, false)
                    if orphan and orphan ~= 0 and DoesEntityExist(orphan) then
                        SetEntityAsMissionEntity(orphan, false, true)
                        DeleteEntity(orphan)
                        DebugPrint('[Cycle] syncPhase deferred cleanup: removed orphan at spot', spotIndex)
                    end
                end
            end)
        end
        
        if (newPhase == 'growing1' or newPhase == 'growing2' or newPhase == 'growing_livestock') and growDuration then
            local clientNow = GetGameTimer()
            spot.growStartTime = clientNow
            spot.growEndTime = clientNow + growDuration
            DebugPrint('[Cycle] Set local growth timer - Duration:', growDuration, 'ms, EndTime:', spot.growEndTime)
        else
            spot.growEndTime = nil
            spot.growStartTime = nil
        end
        
        UpdateJobPanelProgress()
    end
end)

function StartWatering(spot)
    if ClientState.currentJob.isHarvesting then
        return
    end
    
    PendingPhaseSpot = spot
    PhaseApproved = false
    TriggerServerEvent('krypton-farming:server:requestPhaseAction', spot.index, 'water')
    
    local waitStart = GetGameTimer()
    while not PhaseApproved and (GetGameTimer() - waitStart) < 2000 do
        Wait(50)
        if PendingPhaseSpot == nil then return end
    end
    
    if not PhaseApproved then
        DebugPrint('[Cycle] Server approval timeout for watering')
        PendingPhaseSpot = nil
        TriggerServerEvent('krypton-farming:server:releasePhaselock', spot.index)
        return
    end
    
    PendingPhaseSpot = nil
    PhaseApproved = false
    
    ClientState.currentJob.isHarvesting = true
    
    local playerPed = PlayerPedId()
    local frozenHeading = GetEntityHeading(playerPed)
    local frozenPos = GetEntityCoords(playerPed)
    CreateThread(function()
        while ClientState.currentJob and ClientState.currentJob.isHarvesting do
            DisableAllControlActions(0)
            -- Re-enable mouse look and essential controls
            EnableControlAction(0, 1, true)   -- LookLeftRight
            EnableControlAction(0, 2, true)   -- LookUpDown
            EnableControlAction(0, 245, true) -- Chat
            EnableControlAction(0, 249, true) -- Push to talk
            -- Enforce heading to prevent drift
            SetEntityHeading(playerPed, frozenHeading)
            Wait(0)
        end
    end)
    
    local region = ClientState.currentJob.region
    local difficulty = region and region.difficulty or 'medium'
    local diffConfig = Config.Jobs.difficulties[difficulty] or Config.Jobs.difficulties['medium']
    
    local duration = math.floor(Config.Jobs.farm.phases.water.duration * (diffConfig.actionMultiplier or 1.0))
    -- T1: Su verme süresi -15%
    if ClientState.skills and ClientState.skills['T1'] then
        duration = math.floor(duration * 0.85)
    end

    -- Hide carry prop (it will be restored after action or on return)
    if CleanupCarryProp then CleanupCarryProp() end

    local waterCanProp  = nil
    local waterFxHandle = nil
    local waterCanHash  = GetHashKey('prop_wateringcan')
    RequestModel(waterCanHash)
    local modelTimer = GetGameTimer()
    while not HasModelLoaded(waterCanHash) do
        Wait(10)
        if GetGameTimer() - modelTimer > 3000 then break end
    end
    if HasModelLoaded(waterCanHash) then
        local pos = GetEntityCoords(playerPed)
        pcall(function() exports['FeloxAC']:CreateObject(waterCanHash) end) --[[FeloxAC:auto]]
        waterCanProp = CreateObject(waterCanHash, pos.x, pos.y, pos.z, false, false, false)
        SetEntityCollision(waterCanProp, false, false)
        SetEntityInvincible(waterCanProp, true)
        SetModelAsNoLongerNeeded(waterCanHash)
        -- Bone 28422 | offset/rotation calibrated via /farmwater2 debug
        AttachEntityToEntity(waterCanProp, playerPed, GetPedBoneIndex(playerPed, 28422),
            0.4, 0.1, 0.0,
            90.0, 180.0, 0.0,
            true, true, false, true, 1, true)

        RequestNamedPtfxAsset('core')
        local ptfxTimer = GetGameTimer()
        while not HasNamedPtfxAssetLoaded('core') do
            Wait(10)
            if GetGameTimer() - ptfxTimer > 3000 then break end
        end
        if HasNamedPtfxAssetLoaded('core') then
            UseParticleFxAssetNextCall('core')
            waterFxHandle = StartParticleFxLoopedOnEntity('ent_sht_water',
                waterCanProp, 0.35, 0.0, 0.25,
                0.0, 0.0, 0.0, 2.0, false, false, false)
        end
    end

    local animDict = 'weapon@w_sp_jerrycan'
    local animName = 'fire'

    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        local start = GetGameTimer()
        while not HasAnimDictLoaded(animDict) do
            Wait(10)
            if GetGameTimer() - start > 3000 then break end
        end
    end

    -- Freeze player in place during watering (mirrors harvest2 behaviour)
    FreezeEntityPosition(playerPed, true)

    -- TaskPlayAnim flags: 49 = LOOP (1) + UPPER_BODY (16) + SECONDARY (32) for looping animation
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 49, 0, false, false, false)

    -- Progress bar (no minigame)
    local actionStart = GetGameTimer()
    StartActionAsync(T('action_water_progress'), duration)
    local elapsed = GetGameTimer() - actionStart

    -- Abort guard: if action resolved too fast, something went wrong (animation cancelled, etc.)
    if elapsed < (duration * 0.7) then
        DebugPrint('[Cycle] Watering aborted early (elapsed:', elapsed, 'ms, expected:', duration, 'ms) - aborting')
        FreezeEntityPosition(playerPed, false)
        if waterFxHandle and waterFxHandle ~= 0 then StopParticleFxLooped(waterFxHandle, false) end
        if waterCanProp and DoesEntityExist(waterCanProp) then
            DetachEntity(waterCanProp, false, false)
            DeleteEntity(waterCanProp)
        end
        ClearPedTasks(playerPed)
        if ClientState.heldEquipment and SpawnCarryProp then SpawnCarryProp(ClientState.heldEquipment) end
        ClientState.currentJob.isHarvesting = false
        spot.beingHarvested = false
        return
    end

    FreezeEntityPosition(playerPed, false)

    -- Stop particle and remove prop before clearing animation
    if waterFxHandle and waterFxHandle ~= 0 then
        StopParticleFxLooped(waterFxHandle, false)
    end
    if waterCanProp and DoesEntityExist(waterCanProp) then
        DetachEntity(waterCanProp, false, false)
        DeleteEntity(waterCanProp)
    end

    ClearPedTasks(playerPed)

    if ClientState.heldEquipment and SpawnCarryProp then
        SpawnCarryProp(ClientState.heldEquipment)
    end
    
    ClientState.currentJob.isHarvesting = false
    spot.beingHarvested = false -- Safety: ensure flag is cleared locally
    
    -- Immediately update local spot to growing1 phase for instant UI feedback
    -- Server will sync the actual growEndTime
    local regionData = ClientState.currentJob.region
    local diff = regionData and regionData.difficulty or 'medium'
    local diffCfg = Config.Jobs.difficulties[diff] or Config.Jobs.difficulties['medium']
    local baseGrowTime = Config.Jobs.farm.phases.grow1.duration
    local growTime = baseGrowTime * (diffCfg.waitMultiplier or 1.0)
    -- T4: Büyme gösterge -10%
    if ClientState.skills and ClientState.skills['T4'] then
        growTime = growTime * 0.90
    end
    
    spot.phase = 'growing1'
    spot.growStartTime = GetGameTimer()
    spot.growEndTime = spot.growStartTime + growTime
    
    if UpdateSpotBlip then UpdateSpotBlip(spot) end
    
    DebugPrint('[Cycle] Local phase set to growing1, duration:', growTime, 'ms')
    
    UpdateJobPanelProgress()
    
    TriggerServerEvent('krypton-farming:server:phaseComplete', spot.index, 'water', GetEntityCoords(playerPed))
    
end

function StartFertilizing(spot)
    if ClientState.currentJob.isHarvesting then
        return
    end
    
    PendingPhaseSpot = spot
    PhaseApproved = false
    TriggerServerEvent('krypton-farming:server:requestPhaseAction', spot.index, 'fertilize')
    
    local waitStart = GetGameTimer()
    while not PhaseApproved and (GetGameTimer() - waitStart) < 2000 do
        Wait(50)
        if PendingPhaseSpot == nil then return end
    end
    
    if not PhaseApproved then
        DebugPrint('[Cycle] Server approval timeout for fertilizing')
        PendingPhaseSpot = nil
        TriggerServerEvent('krypton-farming:server:releasePhaselock', spot.index)
        return
    end
    
    PendingPhaseSpot = nil
    PhaseApproved = false
    
    ClientState.currentJob.isHarvesting = true
    
    local playerPed = PlayerPedId()
    local frozenHeading = GetEntityHeading(playerPed)
    CreateThread(function()
        while ClientState.currentJob and ClientState.currentJob.isHarvesting do
            DisableAllControlActions(0)
            -- Re-enable mouse look and essential controls
            EnableControlAction(0, 1, true)   -- LookLeftRight
            EnableControlAction(0, 2, true)   -- LookUpDown
            EnableControlAction(0, 245, true) -- Chat
            EnableControlAction(0, 249, true) -- Push to talk
            -- Enforce heading to prevent drift
            SetEntityHeading(playerPed, frozenHeading)
            Wait(0)
        end
    end)
    
    local region = ClientState.currentJob.region
    local difficulty = region and region.difficulty or 'medium'
    local diffConfig = Config.Jobs.difficulties[difficulty] or Config.Jobs.difficulties['medium']
    
    local duration = math.floor(Config.Jobs.farm.phases.fertilize.duration * (diffConfig.actionMultiplier or 1.0))
    -- T2: Gübreleme süresi -15%
    if ClientState.skills and ClientState.skills['T2'] then
        duration = math.floor(duration * 0.85)
    end

    -- Hide carry prop (it will be restored after action or on return)
    if CleanupCarryProp then CleanupCarryProp() end

    local fertProp    = nil
    local fertFxHandle = nil
    local fertHash    = GetHashKey('dd_feed2_sack_open')
    RequestModel(fertHash)
    local modelTimer = GetGameTimer()
    while not HasModelLoaded(fertHash) do
        Wait(10)
        if GetGameTimer() - modelTimer > 3000 then break end
    end
    if HasModelLoaded(fertHash) then
        local pos = GetEntityCoords(playerPed)
        pcall(function() exports['FeloxAC']:CreateObject(fertHash) end) --[[FeloxAC:auto]]
        fertProp = CreateObject(fertHash, pos.x, pos.y, pos.z, false, false, false)
        SetEntityCollision(fertProp, false, false)
        SetEntityInvincible(fertProp, true)
        SetModelAsNoLongerNeeded(fertHash)
        -- Bone 57005 | offset/rotation from fert_work debug preset
        AttachEntityToEntity(fertProp, playerPed, GetPedBoneIndex(playerPed, 57005),
            0.18, 0.13, -0.24,
            -165.8694, -11.2123, -32.9453,
            true, true, false, true, 1, true)

        RequestNamedPtfxAsset('scr_bike_business')
        local ptfxTimer = GetGameTimer()
        while not HasNamedPtfxAssetLoaded('scr_bike_business') do
            Wait(10)
            if GetGameTimer() - ptfxTimer > 3000 then break end
        end
        if HasNamedPtfxAssetLoaded('scr_bike_business') then
            UseParticleFxAssetNextCall('scr_bike_business')
            fertFxHandle = StartParticleFxLoopedOnEntity('scr_bike_coc_cocaine_scoop_pour',
                fertProp, 0.10, 0.0, 0.25,
                0.0, 0.0, 0.0, 1.5, false, false, false)
        end
    end

    local animDict = 'weapons@misc@jerrycan@'
    local animName = 'fire'
    
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        local start = GetGameTimer()
        while not HasAnimDictLoaded(animDict) do
            Wait(10)
            if GetGameTimer() - start > 3000 then break end
        end
    end
    
    -- Freeze player in place during fertilizing (mirrors harvest2 behaviour)
    FreezeEntityPosition(playerPed, true)

    -- TaskPlayAnim flags: 49 = LOOP (1) + UPPER_BODY (16) + SECONDARY (32) for looping animation
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 49, 0, false, false, false)
    
    -- Progress bar (no minigame) - Await completion
    local actionStart = GetGameTimer()
    StartActionAsync(T('action_fertilize_progress'), duration)
    local elapsed = GetGameTimer() - actionStart

    -- Abort guard: if action resolved too fast, something went wrong (animation cancelled, etc.)
    if elapsed < (duration * 0.7) then
        DebugPrint('[Cycle] Fertilizing aborted early (elapsed:', elapsed, 'ms, expected:', duration, 'ms) - aborting')
        FreezeEntityPosition(playerPed, false)
        if fertFxHandle and fertFxHandle ~= 0 then StopParticleFxLooped(fertFxHandle, false) end
        if fertProp and DoesEntityExist(fertProp) then
            DetachEntity(fertProp, false, false)
            DeleteEntity(fertProp)
        end
        ClearPedTasks(playerPed)
        if ClientState.heldEquipment and SpawnCarryProp then SpawnCarryProp(ClientState.heldEquipment) end
        ClientState.currentJob.isHarvesting = false
        spot.beingHarvested = false
        return
    end

    FreezeEntityPosition(playerPed, false)

    -- Stop particle and remove prop before clearing animation
    if fertFxHandle and fertFxHandle ~= 0 then
        StopParticleFxLooped(fertFxHandle, false)
    end
    if fertProp and DoesEntityExist(fertProp) then
        DetachEntity(fertProp, false, false)
        DeleteEntity(fertProp)
    end

    ClearPedTasks(playerPed)

    if ClientState.heldEquipment and SpawnCarryProp then
        SpawnCarryProp(ClientState.heldEquipment)
    end
    
    ClientState.currentJob.isHarvesting = false
    spot.beingHarvested = false -- Safety: ensure flag is cleared locally
    
    -- Immediately update local spot to growing2 phase for instant UI feedback
    -- Server will sync the actual growEndTime
    local regionData = ClientState.currentJob.region
    local diff = regionData and regionData.difficulty or 'medium'
    local diffCfg = Config.Jobs.difficulties[diff] or Config.Jobs.difficulties['medium']
    local baseGrowTime = Config.Jobs.farm.phases.grow2.duration
    local growTime = baseGrowTime * (diffCfg.waitMultiplier or 1.0)
    -- T4: Büyme gösterge -10%
    if ClientState.skills and ClientState.skills['T4'] then
        growTime = growTime * 0.90
    end
    
    spot.phase = 'growing2'
    spot.growStartTime = GetGameTimer()
    spot.growEndTime = spot.growStartTime + growTime
    
    if UpdateSpotBlip then UpdateSpotBlip(spot) end
    
    DebugPrint('[Cycle] Local phase set to growing2, duration:', growTime, 'ms')
    
    UpdateJobPanelProgress()
    
    TriggerServerEvent('krypton-farming:server:phaseComplete', spot.index, 'fertilize', GetEntityCoords(playerPed))
end

DebugPrint('Harvest module loaded')
