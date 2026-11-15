function AddHarvestTarget(entity, spotData, itemConfig, region)
    local isAnimal = itemConfig and itemConfig.animal ~= nil
    local action = isAnimal and (itemConfig.animal == 'cow' and 'milk' or 'collect') or 'harvest'
    local icon = itemConfig and itemConfig.icon or 'fas fa-wheat-awn'
    local isLivestock = region and region.type == 'livestock'
    local useCycleSystem = isLivestock or (Config.Jobs and region and (region.useCycleSystem or region.useCycle))
    
    local targetIcon
    if useCycleSystem then
        targetIcon = GetPhaseIcon(spotData.phase)
    else
        targetIcon = GetActionIcon(action, itemConfig)
    end
    
    Target.AddLocalEntity(entity, {
        {
            label = GetPhaseLabel(spotData, icon, action, useCycleSystem),
            icon = targetIcon,
            distance = 2.0,
            canInteract = function()
                local spot = ClientState.harvestSpots[spotData.index]
                if not spot or spot.collected or not ClientState.isJobActive then
                    return false
                end
                if spot.phase == 'growing1' or spot.phase == 'growing2' or spot.phase == 'growing_livestock' then
                    return false
                end
                -- Stale beingHarvested guard: if flag stuck >15s, auto-clear (group sync race)
                if spot.beingHarvested then
                    if spot._harvestLockTime and (GetGameTimer() - spot._harvestLockTime) > 15000 then
                        DebugPrint('[Target] Auto-clearing stale beingHarvested for spot', spotData.index)
                        spot.beingHarvested = false
                        spot.harvesterId = nil
                        spot._harvestLockTime = nil
                    else
                        return false
                    end
                end
                return true
            end,
            onSelect = function()
                local spot = ClientState.harvestSpots[spotData.index]
                if spot and not spot.collected and not spot.beingHarvested then
                    spot.failed = false
                    spot.beingHarvested = true  -- lock immediately to block re-entry
                    spot._harvestLockTime = GetGameTimer()  -- timestamp for stale lock detection
                    -- Direct call (pcall breaks Citizen.Await coroutine yields)
                    HandlePhaseAction(spot)
                    -- Safety: always ensure isHarvesting is reset after action
                    if ClientState.currentJob then
                        ClientState.currentJob.isHarvesting = false
                    end
                    spot.beingHarvested = false
                end
            end
        }
    })
end

function GetPhaseLabel(spot, icon, action, useCycleSystem)
    if not useCycleSystem or spot.phase == 'ready' then
        -- Old system or ready phase - use item action
        if action == 'milk' then
            return T('milk_cow')
        elseif action == 'collect' then
            return T('collect_item')
        else
            return T('harvest_prompt')
        end
    end
    
    -- Cycle system phases (NUI handles icons via phase)
    if spot.phase == 'unfed' then
        return T('action_feed')
    elseif spot.phase == 'growing_livestock' then
        local remaining = 0
        if spot.growEndTime then
            remaining = math.max(0, math.ceil((spot.growEndTime - GetGameTimer()) / 1000))
        end
        return (T('growing_livestock') or T('growing')) .. ' (' .. remaining .. 's)'
    elseif spot.phase == 'water' then
        return T('water_plant')
    elseif spot.phase == 'growing1' then
        local remaining = 0
        if spot.growEndTime then
            remaining = math.max(0, math.ceil((spot.growEndTime - GetGameTimer()) / 1000))
        end
        return T('growing1') .. ' (' .. remaining .. 's)'
    elseif spot.phase == 'fertilize' then
        return T('fertilize_plant')
    elseif spot.phase == 'growing2' then
        local remaining = 0
        if spot.growEndTime then
            remaining = math.max(0, math.ceil((spot.growEndTime - GetGameTimer()) / 1000))
        end
        return T('growing2') .. ' (' .. remaining .. 's)'
    end
    
    return T('harvest_prompt')
end

function GetPhaseIcon(phase)
    local icons = {
        water = 'fas fa-tint',
        growing1 = 'fas fa-seedling',
        fertilize = 'fas fa-flask',
        growing2 = 'fas fa-seedling',
        unfed = 'fas fa-wheat-awn',
        growing_livestock = 'fas fa-clock',
        ready = 'fas fa-hand'
    }
    return icons[phase] or 'fas fa-hand'
end

function GetActionIcon(action, itemConfig)
    if action == 'milk' then
        return 'fas fa-droplet'
    elseif action == 'collect' then
        return 'fas fa-egg'
    elseif itemConfig and itemConfig.icon then
        return itemConfig.icon
    end
    return 'fas fa-hand'
end

function UpdateSpotBlip(spot)
    if not spot or not spot.blip or not DoesBlipExist(spot.blip) then return end
    
    local label = nil
    local color = 2
    
    if spot.phase == 'water' then
        label = T('water_plant') or 'Sula'
        color = 3 -- Blue
    elseif spot.phase == 'unfed' then
        label = T('action_feed') or 'Besle'
        color = 3 -- Blue
    elseif spot.phase == 'growing1' or spot.phase == 'growing2' or spot.phase == 'growing_livestock' then
        label = T('growing') or 'Büyüyor'
        color = 5 -- Yellow
    elseif spot.phase == 'fertilize' then
        label = T('fertilize_plant') or 'Gübrele'
        color = 47 -- Orange
    elseif spot.phase == 'ready' then
        label = T('action_harvest') or 'Hasat Et'
        color = 2 -- Green
    else
        label = T('harvest_spot_blip') or 'Hasat Noktası'
    end
    
    SetBlipColour(spot.blip, color)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(label)
    EndTextCommandSetBlipName(spot.blip)
end

function HandlePhaseAction(spot)
    -- Phase 1: Equipment gating
    if Config.NPC[1] and Config.NPC[1].vehicle and GetRequiredEquipment then
        local requiredEquip = GetRequiredEquipment(spot)
        if requiredEquip and ClientState.heldEquipment ~= requiredEquip then
            Krypton.Notify(T('need_equipment_' .. requiredEquip), 'error')
            return
        end
    end

    local region = ClientState.currentJob.region
    
    -- Auto-detect livestock per-spot if region type wasn't set
    local isLivestock = region and region.type == 'livestock'
    if not isLivestock and region then
        local itemCfg = Config.Items and Config.Items[spot.type]
        if itemCfg and itemCfg.animal then
            isLivestock = true
            region.type = 'livestock'
        end
    end
    
    local useCycleSystem = isLivestock or (Config.Jobs and region and (region.useCycleSystem or region.useCycle))

    -- Livestock dispatch: feed → grow → collect cycle
    if isLivestock then
        if spot.phase == 'unfed' then
            StartLivestockFeed(spot)
        elseif spot.phase == 'ready' then
            StartLivestockCollect(spot)
        elseif spot.phase == 'growing_livestock' then
            local remaining = 0
            if spot.growEndTime then
                remaining = math.max(0, math.ceil((spot.growEndTime - GetGameTimer()) / 1000))
            end
            Krypton.Notify(string.format(T('livestock_growing'), remaining), 'info')
        end
        return
    end
    
    if not useCycleSystem or spot.phase == 'ready' then
        StartHarvest(spot)
        return
    end
    
    if spot.phase == 'water' then
        StartWatering(spot)
    elseif spot.phase == 'fertilize' then
        StartFertilizing(spot)
    end
end

function RemoveHarvestTargets()
    if Config.HarvestInteraction == 'target' and Target then
        for _, spot in pairs(ClientState.harvestSpots) do
            if spot.entity and DoesEntityExist(spot.entity) then
                Target.RemoveLocalEntity(spot.entity)
            end
        end
    end
end

function DespawnHarvestSpots()
    RemoveHarvestTargets()
    
    if ClientState.harvestSpots then
        for _, spot in pairs(ClientState.harvestSpots) do
            if spot.entity and DoesEntityExist(spot.entity) then
                SetEntityDrawOutline(spot.entity, false)
                SetEntityAsMissionEntity(spot.entity, false, true)
                DeleteEntity(spot.entity)
            end
            -- Fallback: if entity handle is gone but was a crop, search nearby for orphaned prop
            if spot.entity == nil and spot.entityModel and spot.coords then
                local nearby = GetClosestObjectOfType(spot.coords.x, spot.coords.y, spot.coords.z, 2.0, spot.entityModel, false, false, false)
                if nearby and nearby ~= 0 and DoesEntityExist(nearby) then
                    SetEntityAsMissionEntity(nearby, false, true)
                    DeleteEntity(nearby)
                    DebugPrint('[DespawnHarvestSpots] Deleted orphaned prop at spot via model search')
                end
            end
            if spot.blip and DoesBlipExist(spot.blip) then
                RemoveBlip(spot.blip)
            end
        end
    end
    ClientState.harvestSpots = {}
    
    if ClientState.ambientPeds then
        for _, ped in ipairs(ClientState.ambientPeds) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
    end
    ClientState.ambientPeds = {}
end

-- Buffer for animalNetIdRegistered events that arrive before SpawnHarvestSpots
-- has populated ClientState.harvestSpots. Without this, those events are lost
-- and the affected animals never have a target / interaction attached.
local _pendingAnimalNetIds = {}

local function ResolveAnimalNetId(spotIndex, netId)
    local spot = ClientState.harvestSpots and ClientState.harvestSpots[spotIndex]
    if not spot then
        _pendingAnimalNetIds[spotIndex] = netId
        return
    end

    if spot.entity and DoesEntityExist(spot.entity) then
        -- Don't replace if we own this network entity (we are the spawner)
        if spot.netId and spot.netId == netId then return end

        if Config.HarvestInteraction == 'target' and Target then
            Target.RemoveLocalEntity(spot.entity)
        end
        SetEntityAsMissionEntity(spot.entity, false, true)
        DeleteEntity(spot.entity)
        spot.entity = nil
    end

    CreateThread(function()
        local entity = nil
        -- Retry indefinitely while job is active. Streaming may take longer than 5s
        -- if the player is far from the animal at spawn time. Without retries,
        -- such animals would forever lack a target / interaction.
        while ClientState.isJobActive and ClientState.currentJob do
            if NetworkDoesNetworkIdExist(netId) then
                entity = NetworkGetEntityFromNetworkId(netId)
                if entity and entity ~= 0 and DoesEntityExist(entity) then
                    break
                end
            end
            Wait(250)
        end

        if entity and entity ~= 0 and DoesEntityExist(entity) then
            spot.entity = entity
            spot.netId = netId
            if Config.HarvestInteraction == 'target' and Target then
                local itemConfig = Config.Items and Config.Items[spot.type]
                local region = ClientState.currentJob and ClientState.currentJob.region
                AddHarvestTarget(entity, spot, itemConfig, region)
            end

            -- Swap static coord blip for an entity blip so the icon follows the
            -- animal natively (zero per-frame cost — handled by the engine).
            if spot.blip and DoesBlipExist(spot.blip) then
                RemoveBlip(spot.blip)
            end
            local newBlip = AddBlipForEntity(entity)
            SetBlipSprite(newBlip, 1)
            SetBlipDisplay(newBlip, 4)
            SetBlipScale(newBlip, 0.5)
            SetBlipColour(newBlip, 2)
            SetBlipAsShortRange(newBlip, true)
            spot.blip = newBlip
            UpdateSpotBlip(spot)

            -- Apply behaviour when (and if) we get network control of the ped.
            -- Server spawned it, but only the controlling client can task it.
            -- No attempt cap: server-side entity ownership migrates asynchronously
            -- and can take longer than 6s under load. Loop until job ends.
            CreateThread(function()
                while ClientState.isJobActive and ClientState.currentJob do
                    if NetworkHasControlOfEntity(entity) then
                        SetEntityInvincible(entity, true)
                        SetBlockingOfNonTemporaryEvents(entity, true)
                        SetPedFleeAttributes(entity, 0, 0)
                        local region = ClientState.currentJob and ClientState.currentJob.region
                        if not (region and region.zone and region.zone.points and #region.zone.points >= 3 and region.center) then
                            error('[AnimalSpawn] İlk wander: polyzone+center zorunlu')
                        end
                        if not region.zone.bounds then PrecomputeRegionBounds(region) end
                        local r = GetZoneWanderRadius(region.zone)
                        TaskWanderInArea(entity, region.center.x, region.center.y, region.center.z or spot.coords.z, r, 5, 10)
                        break
                    end
                    NetworkRequestControlOfEntity(entity)
                    Wait(300)
                end
            end)

            DebugPrint('[Livestock] Resolved networked animal for spot', spotIndex, 'netId:', netId)
        end
    end)
end

-- Called from SpawnHarvestSpots after spots are created, to apply any netId
-- events that arrived before the spots existed.
function FlushPendingAnimalNetIds()
    if not next(_pendingAnimalNetIds) then return end
    local pending = _pendingAnimalNetIds
    _pendingAnimalNetIds = {}
    for spotIndex, netId in pairs(pending) do
        ResolveAnimalNetId(spotIndex, netId)
    end
end

RegisterNetEvent('krypton-farming:client:animalNetIdRegistered', function(spotIndex, netId)
    ResolveAnimalNetId(spotIndex, netId)
end)

-- Server tells us a livestock entity has been despawned (group teardown).
-- Drop any local references and targets; entity itself is removed by server.
RegisterNetEvent('krypton-farming:client:animalDespawned', function(spotIndex)
    if not ClientState.harvestSpots then return end
    local spot = ClientState.harvestSpots[spotIndex]
    if not spot then return end

    if spot.entity and DoesEntityExist(spot.entity) then
        if Config.HarvestInteraction == 'target' and Target then
            pcall(function() Target.RemoveLocalEntity(spot.entity) end)
        end
        -- Also try local delete in case server delete didn't reach us yet.
        if NetworkHasControlOfEntity(spot.entity) then
            DeleteEntity(spot.entity)
        end
    end
    spot.entity = nil
    spot.netId = nil
end)

-- Admin-triggered sweep: delete orphan cow/hen peds inside known farm zones
-- that aren't part of any active group's animal netIds.
RegisterNetEvent('krypton-farming:client:sweepStrayAnimals', function(zones, allowNetIds)
    if type(zones) ~= 'table' then return end

    local allow = {}
    if type(allowNetIds) == 'table' then
        for _, netId in ipairs(allowNetIds) do allow[netId] = true end
    end

    local cowHash, henHash = GetHashKey('a_c_cow'), GetHashKey('a_c_hen')
    local myCoords = GetEntityCoords(PlayerPedId())
    local deleted = 0

    for _, ped in ipairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) then
            local model = GetEntityModel(ped)
            if model == cowHash or model == henHash then
                local pedCoords = GetEntityCoords(ped)
                local netId = NetworkGetEntityIsNetworked(ped) and NetworkGetNetworkIdFromEntity(ped) or 0
                if not allow[netId] then
                    for _, zone in ipairs(zones) do
                        if zone.center then
                            local d = #(vector3(zone.center.x, zone.center.y, zone.center.z) - pedCoords)
                            if d <= (zone.radius or 120.0) then
                                if NetworkHasControlOfEntity(ped) then
                                    SetEntityAsMissionEntity(ped, true, true)
                                    DeleteEntity(ped)
                                else
                                    NetworkRequestControlOfEntity(ped)
                                    Wait(50)
                                    if NetworkHasControlOfEntity(ped) then
                                        SetEntityAsMissionEntity(ped, true, true)
                                        DeleteEntity(ped)
                                    end
                                end
                                if not DoesEntityExist(ped) then deleted = deleted + 1 end
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    if deleted > 0 then
        DebugPrint('[StraySweep] Deleted', deleted, 'orphan animals near you')
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DespawnHarvestSpots()
        DebugPrint('Harvest spots cleaned up on resource stop')
    end
end)
