function GetRequiredEquipment(spot)
    if not (Config.NPC[1] and Config.NPC[1].vehicle) then return nil end
    if not ClientState.currentJob then return nil end

    local region = ClientState.currentJob.region
    local useCycleSystem = Config.Jobs
        and region and (region.useCycleSystem or region.useCycle)

    -- Hayvancılık bölgesi için faz tabanlı ekipman
    if region and region.type == 'livestock' then
        if spot.phase == 'unfed' then return 'feed_sack' end
        if spot.phase == 'growing_livestock' then return nil end
        if spot.phase == 'ready' then
            local itemConfig = Config.Items and Config.Items[spot.type]
            if itemConfig and itemConfig.animal == 'cow' then return 'milk_bucket' end
            if itemConfig and itemConfig.animal == 'chicken' then return 'egg_crate' end
        end
        return nil
    end

    if useCycleSystem then
        if spot.phase == 'water' then return 'water' end
        if spot.phase == 'fertilize' then return 'fertilizer' end
        if spot.phase == 'ready' then return 'harvest' end
    end

    local itemConfig = Config.Items and Config.Items[spot.type]
    if itemConfig and itemConfig.animal then
        if itemConfig.animal == 'cow' then return 'milk_bucket' end
        if itemConfig.animal == 'chicken' then return 'egg_crate' end
    end

    return 'harvest'
end

function SpawnVehicleProps()
    if not VehicleState.entity or not DoesEntityExist(VehicleState.entity) then 
        DebugWarn('[Vehicle] Cannot spawn props - vehicle entity does not exist')
        return 
    end

    local jobType = VehicleState.jobType
    local propConfig = PROP_CONFIGS[jobType]
    if not propConfig then 
        DebugWarn('[Vehicle] No prop config for job type:', jobType)
        return 
    end

    local vehicle = VehicleState.entity
    DebugPrint('[Vehicle] Starting prop spawn for job type:', jobType)

    if propConfig.fixed then
        DebugPrint('[Vehicle] Spawning', #propConfig.fixed, 'fixed props')
        for i, cfg in ipairs(propConfig.fixed) do
            local obj = AttachPropToVehicle(vehicle, cfg)
            if obj then
                table.insert(VehicleState.fixedProps, obj)
                -- Livestock: ilk fixed prop varilin yani barrelProp'un kendisi
                if jobType == 'livestock' and i == 1 then
                    VehicleState.barrelProp = obj
                end
                DebugPrint('[Vehicle] Fixed prop', i, 'spawned:', cfg.model)
            else
                DebugWarn('[Vehicle] Failed to spawn fixed prop:', cfg.model)
            end
        end
    end

    if propConfig.interactive then
        local interactiveCount = 0
        for key, _ in pairs(propConfig.interactive) do
            interactiveCount = interactiveCount + 1
        end
        DebugPrint('[Vehicle] Attempting to spawn', interactiveCount, 'interactive props')
        
        for key, cfg in pairs(propConfig.interactive) do
            local equipState = VehicleState.equipment[key]
            if equipState and equipState.count > 0 then
                local obj = AttachPropToVehicle(vehicle, cfg)
                if obj then
                    VehicleState.interactiveProps[key] = obj
                    DebugPrint('[Vehicle] Interactive prop spawned:', cfg.model, 'for', key)
                else
                    DebugWarn('[Vehicle] Failed to spawn interactive prop:', cfg.model, 'for', key)
                end
            else
                DebugPrint('[Vehicle] Skipping', key, '- count:', equipState and equipState.count or 'nil')
            end
        end
    end
    
    DebugPrint('[Vehicle] Prop spawn complete. Fixed:', #VehicleState.fixedProps)
end

local function UpdateInteractiveProp(equipKey)
    local equipState = VehicleState.equipment[equipKey]
    if not equipState then return end

    local propEntity = VehicleState.interactiveProps[equipKey]

    if equipState.count > 0 and not propEntity then
        -- Need to show prop (was hidden, now available again)
        local jobType = VehicleState.jobType
        local propConfig = PROP_CONFIGS[jobType]
        if propConfig and propConfig.interactive and propConfig.interactive[equipKey] then
            local obj = AttachPropToVehicle(VehicleState.entity, propConfig.interactive[equipKey])
            if obj then
                VehicleState.interactiveProps[equipKey] = obj
            end
        end
    elseif equipState.count <= 0 and propEntity then
        -- Need to hide prop (all equipment taken)
        if DoesEntityExist(propEntity) then
            DeleteEntity(propEntity)
        end
        VehicleState.interactiveProps[equipKey] = nil
    end
end

function DespawnVehicleProps()
    for _, obj in ipairs(VehicleState.fixedProps) do
        if DoesEntityExist(obj) then
            DeleteEntity(obj)
        end
    end
    VehicleState.fixedProps = {}
    VehicleState.barrelProp = nil

    for key, obj in pairs(VehicleState.interactiveProps) do
        if DoesEntityExist(obj) then
            DeleteEntity(obj)
        end
    end
    VehicleState.interactiveProps = {}
end

local function GetEquipmentLabel(equipKey)
    local labels = {
        water = T('equip_water'),
        fertilizer = T('equip_fertilizer'),
        harvest = T('equip_harvest'),
        milk_bucket = T('equip_milk_bucket'),
        egg_crate = T('equip_egg_crate'),
        feed_sack = T('equip_feed_sack'),
    }
    return labels[equipKey] or equipKey
end

local function GetEquipmentIcon(equipKey)
    local icons = {
        water = 'fas fa-droplet',
        fertilizer = 'fas fa-flask',
        harvest = 'fas fa-wheat-awn',
        milk_bucket = 'fas fa-bucket',
        egg_crate = 'fas fa-box',
        feed_sack = 'fas fa-bag-shopping',
    }
    return icons[equipKey] or 'fas fa-toolbox'
end

local function GetSortedAvailableKeys()
    local keys = {}
    for key, state in pairs(VehicleState.equipment) do
        if state.count > 0 then
            keys[#keys + 1] = key
        end
    end
    table.sort(keys)
    return keys
end

function AddVehicleTargets()
    if not Target then return end
    if not VehicleState.entity or not DoesEntityExist(VehicleState.entity) then return end

    local options = {}

    -- One option per equipment type; selecting while holding another auto-swaps (server handles it)
    for key, _ in pairs(VehicleState.equipment) do
        options[#options + 1] = {
            name = 'farming_equip_' .. key,
            label = GetEquipmentLabel(key),
            icon = GetEquipmentIcon(key),
            distance = 5.0,
            canInteract = function()
                local equip = VehicleState.equipment[key]
                return equip and equip.count > 0 and ClientState.isJobActive
                    and not ClientState.heldEquipmentFull
            end,
            onSelect = function()
                TriggerServerEvent('krypton-farming:server:takeEquipment', key)
            end
        }
    end

    DebugPrint('[Vehicle] Adding target to entity:', VehicleState.entity, 'options:', #options)
    Target.AddLocalEntity(VehicleState.entity, options)

    local returnOptions = {
        {
            name = 'farming_equip_return',
            label = T('return_equipment'),
            icon = 'fas fa-hand',
            distance = 5.0,
            canInteract = function()
                return ClientState.heldEquipment ~= nil and not ClientState.heldEquipmentFull and ClientState.isJobActive
            end,
            onSelect = function()
                TriggerServerEvent('krypton-farming:server:returnEquipment')
            end
        }
    }
    Target.AddLocalEntity(VehicleState.entity, returnOptions)

    -- Hayvancılık: Varil dump target'ları (araç arkasina, vehicle entity'sinin kendisine eklenir)
    if VehicleState.jobType == 'livestock' then
        local barrelOptions = {
            {
                name = 'livestock_pour_milk',
                label = T('pour_milk_barrel'),
                icon = 'fas fa-fill-drip',
                distance = 5.0,
                canInteract = function()
                    return ClientState.heldEquipment == 'milk_bucket'
                        and ClientState.heldEquipmentFull
                        and ClientState.isJobActive
                        and not (ClientState.currentJob and ClientState.currentJob.isHarvesting)
                end,
                onSelect = function()
                    CreateThread(function()
                        ClientState.currentJob.isHarvesting = true
                        local ped = PlayerPedId()
                        local frozenHeading = GetEntityHeading(ped)
                        FreezeEntityPosition(ped, true)
                        CreateActionControlThread(ped, frozenHeading)
                        if CarryState and CarryState.animDict then
                            StopAnimTask(ped, CarryState.animDict, 'idle', 3.0)
                        end
                        local dict = 'amb@prop_human_bum_bin@idle_a'
                        if not HasAnimDictLoaded(dict) then
                            RequestAnimDict(dict)
                            local t = GetGameTimer()
                            while not HasAnimDictLoaded(dict) do
                                Wait(10)
                                if GetGameTimer() - t > 3000 then break end
                            end
                        end
                        TaskPlayAnim(ped, dict, 'idle_a', 8.0, -8.0, 2500, 1, 0, false, false, false)
                        StartActionAsync(T('pouring_milk'), 2500)
                        ClearPedTasks(ped)
                        FreezeEntityPosition(ped, false)
                        ClientState.heldEquipmentFull = false
                        SpawnCarryProp('milk_bucket')
                        ClientState.currentJob.isHarvesting = false
                        Krypton.Notify(T('milk_poured'), 'success')
                    end)
                end
            },
            {
                name = 'livestock_dump_eggs',
                label = T('dump_eggs_basket'),
                icon = 'fas fa-box-open',
                distance = 5.0,
                canInteract = function()
                    return ClientState.heldEquipment == 'egg_crate'
                        and ClientState.heldEquipmentFull
                        and ClientState.isJobActive
                        and not (ClientState.currentJob and ClientState.currentJob.isHarvesting)
                end,
                onSelect = function()
                    CreateThread(function()
                        ClientState.currentJob.isHarvesting = true
                        local ped = PlayerPedId()
                        local frozenHeading = GetEntityHeading(ped)
                        FreezeEntityPosition(ped, true)
                        CreateActionControlThread(ped, frozenHeading)
                        if CarryState and CarryState.animDict then
                            StopAnimTask(ped, CarryState.animDict, 'idle', 3.0)
                        end
                        local dict = 'amb@prop_human_bum_bin@idle_a'
                        if not HasAnimDictLoaded(dict) then
                            RequestAnimDict(dict)
                            local t = GetGameTimer()
                            while not HasAnimDictLoaded(dict) do
                                Wait(10)
                                if GetGameTimer() - t > 3000 then break end
                            end
                        end
                        TaskPlayAnim(ped, dict, 'idle_a', 8.0, -8.0, 2000, 1, 0, false, false, false)
                        StartActionAsync(T('dumping_eggs'), 2000)
                        ClearPedTasks(ped)
                        FreezeEntityPosition(ped, false)
                        ClientState.heldEquipmentFull = false
                        SpawnCarryProp('egg_crate')
                        ClientState.currentJob.isHarvesting = false
                        Krypton.Notify(T('eggs_dumped'), 'success')
                    end)
                end
            },
        }
        Target.AddLocalEntity(VehicleState.entity, barrelOptions)
        DebugPrint('[Vehicle] Livestock barrel dump targets added to vehicle')
    end
end

function RemoveVehicleTargets()
    if not Target then return end
    if VehicleState.entity then
        Target.RemoveLocalEntity(VehicleState.entity)
    end
end

local CarryState = {
    propEntity = nil,
    animDict   = nil,
}

local CARRY_CONFIGS = {
    water = {
        prop = 'prop_wateringcan', bone = 57005,
        offset = vector3(0.43, -0.03, -0.05), rotation = vector3(470.0, 170.0, 100.0),
        movementClipset = 'move_weapon@jerrycan@generic',
    },
    fertilizer = {
        prop = 'dd_feed2_sack_full', bone = 57005,
        offset = vector3(0.3000, -0.0200, 0.0100), rotation = vector3(456.0000, 170.0000, 100.0000),
        movementClipset = 'move_weapon@jerrycan@generic',
    },
    harvest = {
        prop = 'prop_tool_shovel2', bone = 28422,
        offset = vector3(0.70, 0.95, -0.001), rotation = vector3(-53.0, -88.0, -181.0),
        movementClipset = 'move_weapon@jerrycan@generic',
    },
    milk_bucket = {
        prop = 'dd_milk_bucket_empty', bone = 57005,
        offset   = vector3(0.3500, -0.0300, -0.0200),  rotation = vector3(-11.0000, -90.0000, -11.0000),
        movementClipset = 'move_weapon@jerrycan@generic',
    },
    milk_bucket_full = {
        prop = 'dd_milk_bucket_full', bone = 57005,
        offset   = vector3(0.3500, -0.0300, -0.0200),  rotation = vector3(-11.0000, -90.0000, -11.0000),
        movementClipset = 'move_weapon@jerrycan@generic',
    },
    egg_crate = {
        prop = 'dd_egg_basket_empty', bone = 57005,
        offset = vector3(0.2000, -0.0000, -0.2000), rotation = vector3(-116.0000, 70.0000, -20.0000),
        movementClipset = 'anim@heists@box_carry@',
    },
    egg_crate_full = {
        prop = 'dd_egg_basket_full', bone = 57005,
        offset = vector3(0.2000, -0.0000, -0.2000), rotation = vector3(-116.0000, 70.0000, -20.0000),
        movementClipset = 'anim@heists@box_carry@',
    },
    feed_sack = {
        prop = 'dd_feed_sack_full', bone = 57005,
        offset = vector3(0.3600, 0.0200, -0.0500), rotation = vector3(5.0000, -83.0000, -3.0000),
        movementClipset = 'move_weapon@jerrycan@generic',
    },
}

function CleanupCarryProp()
    local ped = PlayerPedId()
    if CarryState.propEntity and DoesEntityExist(CarryState.propEntity) then
        -- Request network control for networked carry props before deletion
        if NetworkGetEntityIsNetworked(CarryState.propEntity) then
            NetworkRequestControlOfEntity(CarryState.propEntity)
            local timeout = GetGameTimer() + 1000
            while not NetworkHasControlOfEntity(CarryState.propEntity) and GetGameTimer() < timeout do
                Wait(10)
            end
        end
        DetachEntity(CarryState.propEntity, false, false)
        DeleteEntity(CarryState.propEntity)
    end
    CarryState.propEntity = nil
    ClearPedTasks(ped)
    ResetPedMovementClipset(ped, 0)
    CarryState.animDict = nil
end

function SpawnCarryProp(equipKey)
    CleanupCarryProp()
    Wait(50) -- let ped settle after ClearPedTasks, mirrors StartCalibration

    local cfg = CARRY_CONFIGS[equipKey]
    if not cfg then return end

    local ped = PlayerPedId()

    -- Match debug command sequence: Reset → ClearTasks → Wait → Spawn → SetClipset
    -- ClearPedTasks is required to clear residual vehicle-exit tasks that override SetPedMovementClipset
    ResetPedMovementClipset(ped, 0)
    ClearPedTasks(ped)
    Wait(100)

    local hash = GetHashKey(cfg.prop)
    RequestModel(hash)
    local t = GetGameTimer()
    while not HasModelLoaded(hash) do
        Wait(10)
        if GetGameTimer() - t > 3000 then return end
    end

    local pos = GetEntityCoords(ped)
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local obj = CreateObject(hash, pos.x, pos.y, pos.z, true, true, false)
    if not obj or obj == 0 then return end

    SetEntityCollision(obj, false, false)
    SetEntityInvincible(obj, true)
    SetModelAsNoLongerNeeded(hash)

    AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, cfg.bone),
        cfg.offset.x, cfg.offset.y, cfg.offset.z,
        cfg.rotation.x, cfg.rotation.y, cfg.rotation.z,
        true, true, false, true, 1, true)

    CarryState.propEntity = obj

    -- Use TaskPlayAnim on movement clipset dict's idle clip (flags 49)
    -- This is what StartCalibration does and it's proven to work.
    -- SetPedMovementClipset is unreliable in FiveM contexts.
    if cfg.movementClipset then
        local animDict = cfg.movementClipset
        if not HasAnimDictLoaded(animDict) then
            RequestAnimDict(animDict)
            local dt = GetGameTimer()
            while not HasAnimDictLoaded(animDict) do
                Wait(10)
                if GetGameTimer() - dt > 3000 then break end
            end
        end
        if HasAnimDictLoaded(animDict) then
            TaskPlayAnim(ped, animDict, 'idle', 8.0, -8.0, -1, 49, 0, false, false, false)
            CarryState.animDict = animDict
        end
    end
end

RegisterNetEvent('krypton-farming:client:equipmentUpdate', function(equipKey, newCount)
    if not VehicleState.active then return end

    if VehicleState.equipment[equipKey] then
        VehicleState.equipment[equipKey].count = newCount
        UpdateInteractiveProp(equipKey)
    end

    DebugPrint('[Vehicle] Equipment updated:', equipKey, '=', newCount)
end)

RegisterNetEvent('krypton-farming:client:equipmentTaken', function(equipKey)
    ClientState.heldEquipment = equipKey
    SpawnCarryProp(equipKey)
    Krypton.Notify(T('equipment_taken', GetEquipmentLabel(equipKey)), 'success')
    DebugPrint('[Vehicle] Equipment taken:', equipKey)

    -- Auto-return equipment if player enters a vehicle
    CreateThread(function()
        while ClientState.heldEquipment == equipKey do
            Wait(250)
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                TriggerServerEvent('krypton-farming:server:returnEquipment')
                Krypton.Notify(T('equipment_returned_vehicle'), 'error')
                break
            end
        end
    end)
end)

RegisterNetEvent('krypton-farming:client:equipmentReturned', function()
    local wasHolding = ClientState.heldEquipment
    ClientState.heldEquipment = nil
    ClientState.heldEquipmentFull = false
    CleanupCarryProp()

    if wasHolding then
        Krypton.Notify(T('equipment_returned'), 'success')
    end
    DebugPrint('[Vehicle] Equipment returned')
end)

RegisterNetEvent('krypton-farming:client:vehicleReturned', function()
    DespawnVehicleProps()
    RemoveVehicleTargets()
    CleanupCarryProp()
    ClientState.heldEquipment = nil
    ClientState.heldEquipmentFull = false
    VehicleState.entity = nil
    VehicleState.netId  = nil
    DebugPrint('[Vehicle] Vehicle returned to spawn point')
end)
