VehicleState = {
    active = false,
    entity = nil,           -- local entity handle
    netId = nil,            -- network id
    jobType = nil,          -- 'crop' | 'livestock'
    fixedProps = {},         -- [i] = entity handle
    interactiveProps = {},   -- [equipKey] = entity handle
    equipment = {},          -- [equipKey] = { count, maxCount }
    blip = nil,
    interactionLoop = false,
    barrelProp = nil,        -- livestock: varil entity (dump target için)
}

function ResolveJobType(region)
    if not region or not region.harvestSpots then return 'crop' end

    -- Hayvancılık bölgesi tüm ekipmanı tek bir 'livestock' tipi olarak yönetir
    if region.type == 'livestock' then return 'livestock' end

    return 'crop'
end

local function SafeLoadModel(modelName, timeout)
    local model = GetHashKey(modelName)
    if not IsModelValid(model) then
        DebugWarn('[Vehicle] Invalid model:', modelName)
        return nil
    end
    RequestModel(model)
    timeout = timeout or 5000
    local start = GetGameTimer()
    while not HasModelLoaded(model) do
        Wait(10)
        if GetGameTimer() - start > timeout then
            DebugWarn('[Vehicle] Model load timeout:', modelName)
            return nil
        end
    end
    return model
end

function AttachPropToVehicle(vehicle, propConfig)
    if not vehicle or not DoesEntityExist(vehicle) then 
        DebugWarn('[Vehicle] AttachProp failed - vehicle does not exist')
        return nil 
    end

    local model = SafeLoadModel(propConfig.model)
    if not model then 
        DebugWarn('[Vehicle] AttachProp failed - could not load model:', propConfig.model)
        return nil 
    end

    local boneName = propConfig.bone or 'bodyshell'
    local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
    
    if boneIndex == -1 then
        DebugWarn('[Vehicle] AttachProp failed - bone not found:', boneName)
        return nil
    end

    local vehCoords = GetEntityCoords(vehicle)
    pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
    local obj = CreateObject(model, vehCoords.x, vehCoords.y, vehCoords.z + 5.0, false, false, false)

    if not obj or obj == 0 then
        DebugWarn('[Vehicle] Failed to create object:', propConfig.model)
        return nil
    end

    SetEntityCollision(obj, false, false)
    SetEntityInvincible(obj, true)
    FreezeEntityPosition(obj, true)

    local off = propConfig.offset or vector3(0.0, 0.0, 0.0)
    local rot = propConfig.rotation or vector3(0.0, 0.0, 0.0)

    AttachEntityToEntity(obj, vehicle, boneIndex,
        off.x, off.y, off.z,
        rot.x, rot.y, rot.z,
        false, true, false, false, 2, true)

    return obj
end

PROP_CONFIGS = {
    crop = {
        fixed = {
            { model = 'prop_barrel_02a', bone = 'bodyshell', offset = vector3(0.54, -1.8, 0.31), rotation = vector3(0.0, 0.0, 0.0) },
            { model = 'prop_cs_fertilizer', bone = 'bodyshell', offset = vector3(-0.53, -1.8, 0.27), rotation = vector3(0.0, 0.0, 0.0) },
        },
        interactive = {
            water      = { model = 'prop_wateringcan', bone = 'bodyshell', offset = vector3(0.59, -2.3, -0.1), rotation = vector3(0.0, 0.0, -140.0) },
            fertilizer = { model = 'dd_feed2_sack_full', bone = 'bodyshell', offset = vector3(-0.52, -2.2, 0.06), rotation = vector3(-10.0, 0.0, 0.0) },
            harvest    = { model = 'prop_tool_shovel006', bone = 'bodyshell', offset = vector3(0.0, -0.8, -0.17), rotation = vector3(-17.0, 0.0, 0.0) },
        },
    },
    -- Hayvancılık: inek + tavuk birleşik ekipman seti
    livestock = {
        fixed = {
            { model = 'prop_barrel_02a', bone = 'bodyshell', offset = vector3(0.54, -1.8, 0.31), rotation = vector3(0.0, 0.0, 0.0) },
        },
        interactive = {
            feed_sack   = { model = 'dd_feed_sack_full',    bone = 'bodyshell', offset = vector3(-0.6600, -1.2300, -0.0300), rotation = vector3(-1.0000, 0.0000, 0.0000) },
            milk_bucket = { model = 'dd_milk_bucket_empty', bone = 'bodyshell', offset = vector3(0.5300, -2.3100, -0.0500), rotation = vector3(0.0000, 0.0000, 0.0000) },
            egg_crate   = { model = 'v_res_fa_basket',      bone = 'bodyshell', offset = vector3(-0.0400, -2.5700, -0.1000), rotation = vector3(0.0000, 0.0000, 0.0000) },
        },
    },
}

local function StartVehicleInteractionLoop()
end

local function GetActiveNpcVehicleConfig()
    local idx = ClientState.activeNpcIndex or 1
    if Config.NPC[idx] and Config.NPC[idx].vehicle and Config.NPC[idx].vehicle.spawnPoint then
        return Config.NPC[idx].vehicle
    end

    local pCoords = GetEntityCoords(PlayerPedId())
    local closestVeh = Config.NPC[1] and Config.NPC[1].vehicle
    local closestDist = math.huge
    for _, npc in ipairs(Config.NPC) do
        if npc.vehicle and npc.vehicle.spawnPoint then
            local sp = npc.vehicle.spawnPoint
            local dist = #(pCoords - vector3(sp.x, sp.y, sp.z))
            if dist < closestDist then
                closestDist = dist
                closestVeh = npc.vehicle
            end
        end
    end
    return closestVeh
end

local function StartSpawnPointLoop()
    local spawnCooldown = false -- E key debounce

    CreateThread(function()
        local promptActive = false

        while VehicleState.active and not VehicleState.entity and ClientState.isJobActive do
            local pedCoords = GetEntityCoords(PlayerPedId())
            local vehConfig = GetActiveNpcVehicleConfig()
            local spawn = vehConfig and vehConfig.spawnPoint

            local dist = math.huge
            local markerZ = spawn and spawn.z or 0
            if spawn then
                local found, groundZ = GetGroundZFor_3dCoord(spawn.x, spawn.y, spawn.z + 5.0, false)
                markerZ = found and groundZ or spawn.z
                dist = #(pedCoords - vector3(spawn.x, spawn.y, spawn.z))
            end

            if spawn and dist < 10.0 then
                -- Draw flat ground circle marker (type 6 = flat disc)
                DrawMarker(6, spawn.x, spawn.y, markerZ,
                    0.0, 0.0, 180.0, 0.0, 0.0, 0.0,
                    5.0, 5.0, 5.0,
                    255, 255, 255, 150,
                    false, false, 2, nil, nil, false)

                if dist < 6.0 then
                    if not promptActive then
                        local deposit = vehConfig and vehConfig.vehicleDeposit or 0
                        local depositText = deposit > 0 and (" ($" .. deposit .. ")") or ""
                        SendNUIMessage({
                            action = 'showHarvestPrompt',
                            icon = 'fas fa-truck-pickup',
                            harvestAction = 'harvest',
                            promptText = T('vehicle_spawn_prompt') .. depositText,
                        })
                        promptActive = true
                    end

                    if IsControlJustPressed(0, 38) and not spawnCooldown then -- E key debounce
                        spawnCooldown = true
                        TriggerServerEvent('krypton-farming:server:requestVehicle')
                        SetTimeout(3000, function() spawnCooldown = false end)
                    end
                else
                    if promptActive then
                        SendNUIMessage({ action = 'hideHarvestPrompt' })
                        promptActive = false
                    end
                end
                Wait(0)
            else
                if promptActive then
                    SendNUIMessage({ action = 'hideHarvestPrompt' })
                    promptActive = false
                end
                Wait(300)
            end
        end
        if promptActive then
            SendNUIMessage({ action = 'hideHarvestPrompt' })
        end
    end)
end

local function StartReturnPointLoop()
    CreateThread(function()
        local promptActive = false

        while VehicleState.active and VehicleState.entity and ClientState.isJobActive do
            local pedCoords = GetEntityCoords(PlayerPedId())
            local vehConfig = GetActiveNpcVehicleConfig()
            local spawn = vehConfig and vehConfig.spawnPoint

            local dist = math.huge
            local markerZ = spawn and spawn.z or 0
            if spawn then
                local found, groundZ = GetGroundZFor_3dCoord(spawn.x, spawn.y, spawn.z + 5.0, false)
                markerZ = found and groundZ or spawn.z
                dist = #(pedCoords - vector3(spawn.x, spawn.y, spawn.z))
            end

            -- Treat the job as done if either the explicit flag is set OR the
            -- progress counter has reached the total. The dual check protects
            -- against rare desyncs where one signal arrives but not the other.
            local cj = ClientState.currentJob
            local isJobDone = false
            if cj then
                if cj.isComplete then
                    isJobDone = true
                else
                    local _region = cj.region
                    local _total = _region and #(_region.harvestSpots or {}) or 0
                    if _total > 0 and (cj.progress or 0) >= _total then
                        isJobDone = true
                    end
                end
            end

            if spawn and dist < 10.0 and isJobDone then
                DrawMarker(6, spawn.x, spawn.y, markerZ,
                    0.0, 0.0, 180.0, 0.0, 0.0, 0.0,
                    5.0, 5.0, 5.0,
                    0, 220, 100, 120,
                    false, false, 2, nil, nil, false)

                if dist < 6.0 then
                    if not promptActive then
                        local deposit = vehConfig and vehConfig.vehicleDeposit or 0
                        local depositText = deposit > 0 and (' (+$' .. deposit .. ')') or ''
                        SendNUIMessage({
                            action = 'showHarvestPrompt',
                            icon = 'fas fa-truck-pickup',
                            harvestAction = 'harvest',
                            promptText = T('vehicle_return_prompt') .. depositText,
                        })
                        promptActive = true
                    end

                    if IsControlJustPressed(0, 38) then -- E
                        TriggerServerEvent('krypton-farming:server:returnVehicle')
                    end
                else
                    if promptActive then
                        SendNUIMessage({ action = 'hideHarvestPrompt' })
                        promptActive = false
                    end
                end
                Wait(0)
            else
                if promptActive then
                    SendNUIMessage({ action = 'hideHarvestPrompt' })
                    promptActive = false
                end
                Wait(300)
            end
        end
        if promptActive then
            SendNUIMessage({ action = 'hideHarvestPrompt' })
        end
    end)
end

function SetupJobVehicle(jobType, equipmentState)
    if not (Config.NPC and #Config.NPC > 0) then return end

    VehicleState.active    = true
    VehicleState.jobType   = jobType
    VehicleState.equipment = equipmentState or {}

    StartSpawnPointLoop()
    DebugPrint('[Vehicle] Setup done. Awaiting player at spawn point. Type:', jobType)
end

RegisterNetEvent('krypton-farming:client:vehicleSpawned', function(netId, isRequester, plate)
    if not VehicleState.active then return end
    VehicleState.netId = netId

    CreateThread(function()
        -- Phase 1: Wait for network ID to register
        local timeout = GetGameTimer() + 15000
        while not NetworkDoesNetworkIdExist(netId) do
            Wait(200)
            if GetGameTimer() > timeout or not VehicleState.active then
                DebugWarn('[Vehicle] Timeout waiting for vehicleSpawned netId:', netId)
                return
            end
        end

        -- Phase 2: Resolve entity handle (re-query each iteration — first call may return 0
        -- if the entity hasn't streamed to this client yet)
        local entity = 0
        local loadTimeout = GetGameTimer() + 10000
        while not DoesEntityExist(entity) do
            entity = NetworkGetEntityFromNetworkId(netId)
            Wait(100)
            if GetGameTimer() > loadTimeout then break end
        end

        if not DoesEntityExist(entity) then
            DebugWarn('[Vehicle] Entity does not exist after vehicleSpawned')
            return
        end

        VehicleState.entity = entity

        -- Phase 3: Wait for vehicle model to stream in on this client
        local vehModel = GetEntityModel(entity)
        if vehModel and not HasModelLoaded(vehModel) then
            RequestModel(vehModel)
            local modelTimeout = GetGameTimer() + 5000
            while not HasModelLoaded(vehModel) do
                Wait(50)
                if GetGameTimer() > modelTimeout then break end
            end
        end

        SetVehicleDoorsLocked(entity, 1)

        -- Phase 4: Requester — warp into driver seat + start engine
        if isRequester then
            -- Request network control for smooth warp
            NetworkRequestControlOfEntity(entity)
            local controlTimeout = GetGameTimer() + 3000
            while not NetworkHasControlOfEntity(entity) do
                Wait(100)
                NetworkRequestControlOfEntity(entity)
                if GetGameTimer() > controlTimeout then break end
            end

            local ped = PlayerPedId()
            TaskWarpPedIntoVehicle(ped, entity, -1)
            Wait(300)

            -- Verify warp succeeded; fallback to direct placement
            if not IsPedInVehicle(ped, entity, false) then
                DebugWarn('[Vehicle] TaskWarp failed, using SetPedIntoVehicle fallback')
                SetPedIntoVehicle(ped, entity, -1)
                Wait(200)
            end

            SetVehicleEngineOn(entity, true, true, false)
        end

        -- Phase 5: Ensure plate is set on client + give keys client-side (belt-and-suspenders)
        if plate then
            pcall(function() exports['FeloxAC']:ChangeVehiclePlate(entity, plate) end) --[[FeloxAC:auto]]
            SetVehicleNumberPlateText(entity, plate)
            TriggerEvent('vehiclekeys:client:SetOwner', plate)
        end

        -- Phase 6: Wait for vehicle to be fully ready, then spawn props + targets
        Wait(500)
        SpawnVehicleProps()
        AddVehicleTargets()
        StartVehicleInteractionLoop()
        StartReturnPointLoop()

        -- Watch for external vehicle deletion (dv, explosion, etc.)
        CreateThread(function()
            while VehicleState.active and VehicleState.entity do
                if not DoesEntityExist(VehicleState.entity) then
                    DebugPrint('[Vehicle] Vehicle entity lost externally - cleaning up props')
                    DespawnVehicleProps()
                    RemoveVehicleTargets()
                    VehicleState.entity = nil
                    VehicleState.netId = nil
                end
                Wait(1000)
            end
        end)

        DebugPrint('[Vehicle] Ready. Entity:', entity, 'Requester:', isRequester)
    end)
end)

function CleanupJobVehicle()
    if not VehicleState.active then return end
    DebugPrint('[Vehicle] Cleaning up job vehicle')

    RemoveVehicleTargets()
    DespawnVehicleProps()

    ClientState.heldEquipment = nil
    ClientState.heldEquipmentFull = false
    CleanupCarryProp()

    VehicleState.active = false
    VehicleState.entity = nil
    VehicleState.netId = nil
    VehicleState.jobType = nil
    VehicleState.equipment = {}
    VehicleState.blip = nil
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupJobVehicle()
    end
end)

DebugPrint('Vehicle module loaded')
