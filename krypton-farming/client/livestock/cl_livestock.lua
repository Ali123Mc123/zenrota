-- Hayvancılık döngüsü: Besleme → Büyüme → Toplama
-- Flow: unfed → growing (server timer) → ready → collected
--
-- Bu sistem mevcut StartHarvest / StartHarvestLoop üzerine inşa edilmiştir.
-- Hayvancılık bölgeleri (region.type == 'livestock') için SpawnHarvestSpots
-- zaten hayvan pedlerini oluşturur (cl_harvest_entities.lua). Bu dosya
-- yalnızca besleme ve toplama eylemlerini yönetir.

RegisterNetEvent('krypton-farming:client:livestockReady', function(spotIndex)
    local spot = ClientState.harvestSpots[spotIndex]
    if not spot then return end

    spot.phase = 'ready'
    spot.growEndTime = nil
    spot.growStartTime = nil

    Krypton.Notify(T('livestock_ready'), 'success')
    if UpdateJobPanelProgress then UpdateJobPanelProgress() end
    if UpdateSpotBlip then UpdateSpotBlip(spot) end
    DebugPrint('[Livestock] Spot', spotIndex, 'is now ready for collection')
end)

local function SetupFeedPropAndFx(playerPed)
    local feedProp = nil
    local feedFxHandle = nil
    local feedHash = GetHashKey('dd_feed_sack_full')
    RequestModel(feedHash)
    local modelTimer = GetGameTimer()
    while not HasModelLoaded(feedHash) do
        Wait(10)
        if GetGameTimer() - modelTimer > 3000 then break end
    end
    if HasModelLoaded(feedHash) then
        local pos = GetEntityCoords(playerPed)
        pcall(function() exports['FeloxAC']:CreateObject(feedHash) end) --[[FeloxAC:auto]]
        feedProp = CreateObject(feedHash, pos.x, pos.y, pos.z, false, false, false)
        SetEntityCollision(feedProp, false, false)
        SetEntityInvincible(feedProp, true)
        SetModelAsNoLongerNeeded(feedHash)
        AttachEntityToEntity(feedProp, playerPed, GetPedBoneIndex(playerPed, 57005),
            0.0700, 0.1000, -0.2000,
            -169.8694, -21.2123, -33.9453,
            true, true, false, true, 1, true)

        RequestNamedPtfxAsset('scr_bike_business')
        local ptfxTimer = GetGameTimer()
        while not HasNamedPtfxAssetLoaded('scr_bike_business') do
            Wait(10)
            if GetGameTimer() - ptfxTimer > 3000 then break end
        end
        if HasNamedPtfxAssetLoaded('scr_bike_business') then
            UseParticleFxAssetNextCall('scr_bike_business')
            feedFxHandle = StartParticleFxLoopedOnEntity('scr_bike_coc_cocaine_scoop_pour',
                feedProp, 0.10, 0.0, 0.25,
                0.0, 0.0, 0.0, 1.5, false, false, false)
        end
    end
    return feedProp, feedFxHandle
end

local function CleanupFeedState(feedProp, feedFxHandle, playerPed, spot)
    FreezeEntityPosition(playerPed, false)
    if feedFxHandle and feedFxHandle ~= 0 then
        StopParticleFxLooped(feedFxHandle, false)
    end
    if feedProp and DoesEntityExist(feedProp) then
        DetachEntity(feedProp, false, false)
        DeleteEntity(feedProp)
    end
    ClearPedTasks(playerPed)
    if spot.entity and DoesEntityExist(spot.entity) then
        FreezeEntityPosition(spot.entity, false)
        local region = ClientState.currentJob and ClientState.currentJob.region
        if not (region and region.zone and region.zone.points and #region.zone.points >= 3) then
            error('[Livestock] CleanupFeedState: region polyzone yok — hayvancılık tarlası polyzone zorunlu')
        end
        if not region.zone.bounds then PrecomputeRegionBounds(region) end
        local r = GetZoneWanderRadius(region.zone)
        TaskWanderInArea(spot.entity, region.center.x, region.center.y, region.center.z or spot.coords.z, r, 5, 10)
    end
end

function StartLivestockFeed(spot)
    if ClientState.currentJob.isHarvesting then return end

    if spot.phase ~= 'unfed' then
        if spot.phase == 'feeding' then
            Krypton.Notify(T('phase_already_done'), 'info')
        elseif spot.phase == 'ready' then
            Krypton.Notify(T('livestock_not_fed') .. ' (' .. T('phase_ready_livestock') .. ')', 'info')
        elseif spot.phase == 'growing_livestock' then
            local remaining = 0
            if spot.growEndTime then
                remaining = math.max(0, math.ceil((spot.growEndTime - GetGameTimer()) / 1000))
            end
            Krypton.Notify(string.format(T('livestock_growing'), remaining), 'info')
        end
        return
    end

    if Config.NPC[1] and Config.NPC[1].vehicle and ClientState.heldEquipment ~= 'feed_sack' then
        Krypton.Notify(T('need_equipment_feed_sack'), 'error')
        return
    end

    local PendingFeedSpot = spot
    local FeedApproved = false

    TriggerServerEvent('krypton-farming:server:requestLivestockFeed', spot.index)

    local waitStart = GetGameTimer()
    while not FeedApproved and (GetGameTimer() - waitStart) < 2000 do
        Wait(50)
        if PendingFeedSpot == nil then return end
        if ClientState._feedDenied == spot.index then
            ClientState._feedDenied = nil
            return  -- fast-fail: server already notified the player
        end
        if ClientState._feedApproved == spot.index then
            FeedApproved = true
            ClientState._feedApproved = nil
        end
    end

    if not FeedApproved then
        DebugPrint('[Livestock] Feed approval timeout for spot', spot.index)
        TriggerServerEvent('krypton-farming:server:releaseFeedLock', spot.index)
        return
    end

    ClientState.currentJob.isHarvesting = true

    local playerPed = PlayerPedId()
    local frozenHeading = GetEntityHeading(playerPed)
    CreateActionControlThread(playerPed, frozenHeading)

    if spot.entity and DoesEntityExist(spot.entity) then
        ClearPedTasks(spot.entity)
        Wait(200)
        FreezeEntityPosition(spot.entity, true)
        TaskTurnPedToFaceEntity(spot.entity, playerPed, 1500)
    end

    local region = ClientState.currentJob.region
    local difficulty = region and region.difficulty or 'medium'
    local diffConfig = Config.Jobs.difficulties[difficulty] or Config.Jobs.difficulties['medium']
    local feedDuration = math.floor(Config.Jobs.livestock.phases.feed.duration * (diffConfig.actionMultiplier or 1.0))
    -- H1: Besleme s\u00fcresi -20%, H5: +ek -10%
    if ClientState.skills and ClientState.skills['H1'] then feedDuration = math.floor(feedDuration * 0.80) end
    if ClientState.skills and ClientState.skills['H5'] then feedDuration = math.floor(feedDuration * 0.90) end

    if CleanupCarryProp then CleanupCarryProp() end

    local feedProp, feedFxHandle = SetupFeedPropAndFx(playerPed)

    local animDict = 'weapons@misc@jerrycan@'
    local animName = 'fire'
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        local t = GetGameTimer()
        while not HasAnimDictLoaded(animDict) do
            Wait(10)
            if GetGameTimer() - t > 3000 then break end
        end
    end

    FreezeEntityPosition(playerPed, true)
    -- Döngüsel animasyon (flags 49 = LOOP | UPPER_BODY | SECONDARY — fertilize ile aynı)
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 49, 0, false, false, false)

    local actionStart = GetGameTimer()
    StartActionAsync(T('action_feed_progress'), feedDuration)
    local elapsed = GetGameTimer() - actionStart

    if elapsed < (feedDuration * 0.7) then
        DebugPrint('[Livestock] Feed aborted early (elapsed:', elapsed, 'ms, expected:', feedDuration, 'ms)')
        CleanupFeedState(feedProp, feedFxHandle, playerPed, spot)
        if ClientState.heldEquipment and SpawnCarryProp then SpawnCarryProp(ClientState.heldEquipment) end
        ClientState.currentJob.isHarvesting = false
        return
    end

    CleanupFeedState(feedProp, feedFxHandle, playerPed, spot)
    ClientState.currentJob.isHarvesting = false

    if ClientState.heldEquipment and SpawnCarryProp then
        SpawnCarryProp(ClientState.heldEquipment)
    end

    TriggerServerEvent('krypton-farming:server:livestockFeedResult', spot.index, GetEntityCoords(playerPed))

    DebugPrint('[Livestock] Feed action complete for spot', spot.index)
end

RegisterNetEvent('krypton-farming:client:livestockFeedApproved', function(spotIndex)
    ClientState._feedApproved = spotIndex
    DebugPrint('[Livestock] Feed approved for spot', spotIndex)
end)

RegisterNetEvent('krypton-farming:client:livestockFeedDenied', function(spotIndex, reason)
    DebugPrint('[Livestock] Feed denied for spot', spotIndex, 'reason:', reason)
    ClientState._feedDenied = spotIndex  -- signal wait loop to exit immediately
    if reason == 'not_unfed' then
        Krypton.Notify(T('phase_already_done'), 'info')
    elseif reason == 'locked' then
        Krypton.Notify(T('livestock_spot_locked'), 'error')
    elseif reason == 'too_far' then
        Krypton.Notify(T('harvest_too_far'), 'error')
    end
end)

RegisterNetEvent('krypton-farming:client:livestockFeedStarted', function(spotIndex)
    if ClientState.harvestSpots[spotIndex] then
        ClientState.harvestSpots[spotIndex].beingHarvested = true
    end
end)

RegisterNetEvent('krypton-farming:client:livestockFed', function(spotIndex, growEndTime)
    local spot = ClientState.harvestSpots[spotIndex]
    if not spot then return end

    spot.phase = 'growing_livestock'
    spot.growEndTime = GetGameTimer() + (growEndTime * 1000) -- sunucudan saniye gelir, ms'e çevir
    spot.growStartTime = GetGameTimer()
    spot.beingHarvested = false

    local remaining = math.ceil(growEndTime)
    Krypton.Notify(string.format(T('livestock_feeding_done'), remaining), 'success')
    if UpdateJobPanelProgress then UpdateJobPanelProgress() end
    if UpdateSpotBlip then UpdateSpotBlip(spot) end
    DebugPrint('[Livestock] Spot', spotIndex, 'fed. Growing for', growEndTime, 's')
end)

-- Hayvanları tarla polyzonu içinde tut.
-- Polyzone ZORUNLUDUR — yoksa thread hata atar (fallback yok).
-- Wander hedefi: zone center, radius: GetZoneWanderRadius (kenarda margin var).
-- Sınır kontrolü: IsDeepInsideZone (kenardan 1.5m içeride mi?).

function StartLivestockTetherThread()
    CreateThread(function()
        while ClientState.isJobActive and ClientState.currentJob do
            local region = ClientState.currentJob.region

            -- Polyzone zorunlu — yoksa hata at, fallback yok.
            if not (region and region.zone and region.zone.points and #region.zone.points >= 3 and region.center) then
                error('[Livestock] Tether thread: polyzone+center zorunlu, region eksik tanımlanmış')
            end
            if not region.zone.bounds then PrecomputeRegionBounds(region) end

            local zone        = region.zone
            local center      = region.center
            local zoneWanderR = GetZoneWanderRadius(zone)
            local cx, cy, cz  = center.x, center.y, (center.z or 0.0)

            for _, spot in pairs(ClientState.harvestSpots) do
                if not spot.collected and not spot.beingHarvested
                    and spot.entity and DoesEntityExist(spot.entity)
                    and not IsEntityPositionFrozen(spot.entity)
                    and NetworkHasControlOfEntity(spot.entity)
                then
                    local pos = GetEntityCoords(spot.entity)

                    -- Hayvan zone'un içinde + kenardan en az 5m içeride mi? (polygon-aware)
                    if not IsDeepInsideZone(pos, zone, 5.0) then
                        ClearPedTasks(spot.entity)
                        TaskWanderInArea(spot.entity, cx, cy, cz, zoneWanderR, 5, 10)

                        -- Hard reset: zone merkezinden çok uzaktaysa teleport et
                        local ddx = pos.x - cx
                        local ddy = pos.y - cy
                        if (ddx * ddx + ddy * ddy) > (zoneWanderR * 1.5) * (zoneWanderR * 1.5) then
                            ClearPedTasksImmediately(spot.entity)
                            SetEntityCoordsNoOffset(spot.entity, cx, cy, cz + 0.5, false, false, false)
                            TaskWanderInArea(spot.entity, cx, cy, cz, zoneWanderR, 5, 10)
                            DebugPrint('[Tether] Spot', spot.index, 'hard-reset → zone center')
                        end
                    end
                end
            end
            Wait(2000)
        end
    end)
end

-- Kendi büyüme döngüsü — cl_harvest.lua'daki cycle timer'ından ayrı çalışır.
function StartLivestockGrowthThread()
    CreateThread(function()
        while ClientState.isJobActive and ClientState.currentJob do
            local now = GetGameTimer()
            for _, spot in pairs(ClientState.harvestSpots) do
                if not spot.collected and spot.phase == 'growing_livestock' then
                    if spot.growEndTime and now >= spot.growEndTime then
                        -- Lokal güncelleme; sunucu kendi timer'ıyla zaten 'ready' event'ini gönderir.
                        -- Ama sunucu gecikmesi durumunda oynayan deneyimi bozmamak için lokal da güncelleriz.
                        spot.phase = 'ready'
                        spot.growEndTime = nil
                        spot.growStartTime = nil
                        if UpdateJobPanelProgress then UpdateJobPanelProgress() end
                        if UpdateSpotBlip then UpdateSpotBlip(spot) end
                        DebugPrint('[Livestock] Spot', spot.index, 'growth complete (client-side timer)')
                    end
                end
            end
            Wait(500)
        end
    end)
end

-- Mevcut StartHarvest fonksiyonunu yeniden kullanır çünkü
-- toplama akışı (sunucu onayı → animasyon → minigame → sonuç) aynı.
-- Fazı kontrol eden ek bir guard ekliyoruz.
function StartLivestockCollect(spot)
    if ClientState.heldEquipmentFull then
        local equip = ClientState.heldEquipment
        if equip == 'milk_bucket' then
            Krypton.Notify(T('bucket_full_pour_first'), 'error')
        elseif equip == 'egg_crate' then
            Krypton.Notify(T('basket_full_dump_first'), 'error')
        end
        return
    end

    if spot.phase == 'unfed' then
        Krypton.Notify(T('livestock_not_fed'), 'error')
        return
    end
    if spot.phase == 'growing_livestock' then
        local remaining = 0
        if spot.growEndTime then
            remaining = math.max(0, math.ceil((spot.growEndTime - GetGameTimer()) / 1000))
        end
        Krypton.Notify(string.format(T('livestock_growing'), remaining), 'info')
        return
    end
    if spot.phase ~= 'ready' then
        Krypton.Notify(T('livestock_not_ready'), 'info')
        return
    end

    StartHarvest(spot)
end

-- cl_vehicle.lua'daki GetRequiredEquipment fonksiyonu livestock fazlarını
-- de desteklemesi gerekiyor. Bu sayede ekipman gereksinimleri doğru çalışır.
-- Not: Asıl override cl_vehicle.lua'da yapılır; bu sadece referans.

-- cl_job.lua'daki StartHarvestLoop yerine bunu çağırır (livestock region için)
function StartLivestockLoop()
    StartLivestockGrowthThread()
    StartLivestockTetherThread()

    -- Ana döngüyü başlat (StartHarvestLoop ile aynı mekanizma çalışır;
    -- livestock spotları zaten SpawnHarvestSpots tarafından oluşturulmuştur,
    -- hedef sistemi ve özel UI prompt sistemi de cl_harvest.lua tarafından
    -- yönetilir — StartHarvestLoop bu spotları da işler)
    StartHarvestLoop()

    DebugPrint('[Livestock] Livestock loop started')
end
