-- Locale table is large; send it once then skip on subsequent opens
local localesSentToNUI = false

RegisterNetEvent('krypton-farming:client:openUI', function(playerData, uiConfig, adminRegions)
    ClientState.isUiOpen = true
    SetNuiFocus(true, true)
    
    CachedPlayerData = playerData
    ClientState.skills      = playerData.skills      or {}
    ClientState.skillPoints = playerData.skillPoints or 0

    if ClientState.npcPed then
        CreateDialogueCam(ClientState.npcPed, 'dialogue')
    end
    
    local regionsForUI = {}
    
    if adminRegions and type(adminRegions) == 'table' then
        for _, adminRegion in ipairs(adminRegions) do
            -- Server already sends crops array; only build locally if missing
            if not adminRegion.crops or #adminRegion.crops == 0 then
                local crops = {}
                local seenTypes = {}
                if adminRegion.harvestSpots then
                    for _, spot in ipairs(adminRegion.harvestSpots) do
                        if spot.type and not seenTypes[spot.type] then
                            seenTypes[spot.type] = true
                            local itemCfg = Config.Items and Config.Items[spot.type]
                            table.insert(crops, {
                                key   = spot.type,
                                label = GetItemLabel(spot.type)
                            })
                        end
                    end
                end
                adminRegion.crops = crops
            end
            table.insert(regionsForUI, adminRegion)
        end
    end
    
    local nearbyPlayers = GetNearbyPlayers()
    local isJobComplete = false
    if ClientState.currentJob then
        local region = ClientState.currentJob.region
        local totalSpots = region and #(region.harvestSpots or {}) or 0
        -- Combine both signals so the "finish job" dialogue option always
        -- appears once the job is done. The explicit flag covers cases where
        -- the server only signalled completion via jobComplete event; the
        -- progress check covers cases where syncProgress arrived but the flag
        -- somehow wasn't set. Avoid the (0 >= 0) trap when totalSpots is 0.
        local progressDone = totalSpots > 0 and (ClientState.currentJob.progress or 0) >= totalSpots
        isJobComplete = ClientState.currentJob.isComplete or progressDone
    end
    
    SendNUIMessage({
        action = 'open',
        data = {
            player = playerData,
            playerId = GetPlayerServerId(PlayerId()),
            regions = regionsForUI,
            nearbyPlayers = nearbyPlayers,
            isJobActive = ClientState.isJobActive,
            isJobComplete = isJobComplete,
            groupBonusMultipliers = Config.Group and Config.Group.rewardMultiplier or {},
            uiConfig = uiConfig or {},
            locales = localesSentToNUI and nil or GetLang(),
            npcName = GetLang()['npc_name']
        }
    })
    localesSentToNUI = true
    
    DebugPrint('UI opened with player data:', json.encode(playerData))
end)

RegisterNUICallback('hideFrame', function(data, cb)
    ClientState.isUiOpen = false
    SetNuiFocus(false, false)
    TriggerServerEvent('krypton-farming:server:closeFarmUI')
    
    DestroyDialogueCam()
    
    -- When job is active, only close dialog, HUD stays visible
    if ClientState.isJobActive then
        SendNUIMessage({ action = 'close' })
        DebugPrint('Dialog closed but HUD stays (job active)')
    else
        SendNUIMessage({ action = 'close' })
    end
    
    cb('ok')
end)

RegisterNUICallback('startJob', function(data, cb)
    local regionId = data.regionId or 1
    local difficulty = data.difficulty or 'easy'
    
    ClientState.isUiOpen = false
    SetNuiFocus(false, false)
    TriggerServerEvent('krypton-farming:server:closeFarmUI')
    
    DestroyDialogueCam()
    
    TriggerServerEvent('krypton-farming:server:startJob', regionId, difficulty)
    
    cb('ok')
end)

RegisterNUICallback('minigameResult', function(data, cb)
    DebugPrint('[UI] Minigame result callback received, success:', data.success, 'perfect:', data.perfect)
    SetNuiFocus(false, false)
    
    -- Forward result to client logic for multi-stage handling (always send, even without active job)
    TriggerEvent('krypton-farming:client:minigameResult', data.success, data.token, data.perfect)
    cb('ok')
end)

RegisterNUICallback('quitJob', function(_, cb)
    if ClientState.isJobActive then
        -- Clean up world entities and blips BEFORE clearing state
        if DespawnHarvestSpots then DespawnHarvestSpots() end
        if CleanupJobVehicle then CleanupJobVehicle() end
        -- harvestSpots already cleared by DespawnHarvestSpots above

        TriggerServerEvent('krypton-farming:server:quitJob')
        SendNUIMessage({ action = 'close' })
        DebugPrint('Job quit by player')
    end
    cb('ok')
end)

RegisterNUICallback('finishJob', function(_, cb)
    if ClientState.isJobActive then
        TriggerServerEvent('krypton-farming:server:finishJob', false)
    end
    cb('ok')
end)

RegisterNUICallback('confirmQuitWithoutPayment', function(data, cb)
    if data.confirmed and ClientState.isJobActive then
        -- Clean up world entities and blips BEFORE clearing state
        if DespawnHarvestSpots then DespawnHarvestSpots() end
        if CleanupJobVehicle then CleanupJobVehicle() end
        if ClientState.centerBlip then
            RemoveBlip(ClientState.centerBlip)
            ClientState.centerBlip = nil
        end

        ClientState.isJobActive = false
        ClientState.currentJob = nil
        -- harvestSpots already cleared by DespawnHarvestSpots above

        TriggerServerEvent('krypton-farming:server:finishJob', true)
        SendNUIMessage({ action = 'close' })
        DebugPrint('Player quit without payment (confirmed)')
    end
    cb('ok')
end)
RegisterNUICallback('kickPlayer', function(data, cb)
    TriggerServerEvent('krypton-farming:server:kickPlayer', data.playerId)
    cb('ok')
end)

RegisterNUICallback('updateShares', function(data, cb)
    TriggerServerEvent('krypton-farming:server:updateShares', data.shares)
    cb('ok')
end)

RegisterNUICallback('changeClothes', function(data, cb)
    TriggerServerEvent('krypton-farming:server:changeClothes', data.type)
    cb('ok')
end)

RegisterNUICallback('changeLanguage', function(data, cb)
    if data.language then
        Lang = Locales[data.language] or Lang
        DebugPrint('[UI] Language changed to:', data.language)
    end
    cb('ok')
end)

-- Escape key failsafe (only for non-admin NUI screens like dialogue, job HUD etc.)
CreateThread(function()
    while true do
        Wait(0)
        if IsNuiFocused() and not ClientState.adminOpen then
            if IsControlJustPressed(0, 322) then -- ESC
                SetNuiFocus(false, false)
                -- During active jobs, only close dialogs — keep HUD visible
                if ClientState.isJobActive then
                    SendNUIMessage({ action = 'close' })
                    ClientState.isUiOpen = false
                    if DestroyDialogueCam then DestroyDialogueCam() end
                else
                    SendNUIMessage({ action = 'hideAllUI' })
                    ClientState.isUiOpen = false
                end
                if Config.Debug then
                end
            end
        else
            Wait(500)
        end
    end
end)

DebugPrint('UI module loaded')

-- ── Skill Tree ──────────────────────────────────────────────────────────────

RegisterNUICallback('buySkill', function(data, cb)
    local skillKey = type(data.skillKey) == 'string' and data.skillKey or nil
    if skillKey then
        TriggerServerEvent('krypton-farming:server:buySkill', skillKey)
    end
    cb('ok')
end)

RegisterNetEvent('krypton-farming:client:skillsUpdated', function(skills, skillPoints)
    ClientState.skills = skills or {}
    ClientState.skillPoints = skillPoints or 0
    SendNUIMessage({
        action = 'skillsUpdated',
        data   = { skills = ClientState.skills, skillPoints = ClientState.skillPoints }
    })
end)

RegisterNetEvent('krypton-farming:client:skillPointsEarned', function(earned, total)
    ClientState.skillPoints = total
    SendNUIMessage({
        action = 'skillPointsEarned',
        data   = { earned = earned, total = total }
    })
end)

-- ── Farm slot live updates ─────────────────────────────────────────────────
RegisterNetEvent('krypton-farming:client:farmSlotsUpdated', function(regionId, used, max)
    if not ClientState.isUiOpen or type(regionId) ~= 'string' then return end
    SendNUIMessage({
        action = 'farmSlotsUpdated',
        data = { regionId = regionId, used = used or 0, max = max or 0 }
    })
end)

-- ── Active workers payload (admin panel) ───────────────────────────────────
RegisterNetEvent('krypton-farming:client:activeWorkers', function(workers)
    SendNUIMessage({
        action = 'activeWorkers',
        data = workers or {},
    })
end)

-- ── Admin teleport to worker coordinates ───────────────────────────────────
RegisterNetEvent('krypton-farming:client:adminTeleportTo', function(coords)
    if not coords or not coords.x then return end
    local ped = PlayerPedId()
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(ped, coords.x + 1.5, coords.y, coords.z + 0.5, false, false, false, true)
end)

-- NUI callback used by the admin panel's "Active Workers" tab (request + refresh).
RegisterNUICallback('adminRequestActiveWorkers', function(_, cb)
    TriggerServerEvent('krypton-farming:server:requestActiveWorkers')
    cb('ok')
end)

RegisterNUICallback('adminTeleportToWorker', function(data, cb)
    if data and data.serverId then
        TriggerServerEvent('krypton-farming:server:adminTeleportToWorker', tonumber(data.serverId))
    end
    cb('ok')
end)
