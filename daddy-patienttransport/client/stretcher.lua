local cfg = Config.Stretcher
local stretcherHashes = EmsModels.Hashes(cfg.model, cfg.models)

local carryState = {
    active = false,
    stretcher = nil,
}

local npcPatientsByStretcher = {}

local CARRY_ANIM_DICT = 'anim@heists@box_carry@'
local CARRY_ANIM_NAME = 'idle'

local function notify(messageKey, nType, ...)
    Utils.Notify('title_stretcher', messageKey, nType, ...)
end

local function stretcherDebug(message, ...)
    if not Config.Sync or not Config.Sync.debug then return end
    print(('[daddy-patienttransport][stretcher-debug] ' .. message):format(...))
end

local function isStretcher(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return false end
    local ok, model = pcall(GetEntityModel, entity) -- throws for some map objects ox_target aims at
    return ok and stretcherHashes[model] == true
end

local function isStretcherOnGround(entity)
    if not isStretcher(entity) then return false end
    return EmsSyncClient.IsGrounded(entity)
end

local function getInstanceId(entity)
    local snapshot = EmsSyncClient.GetSnapshot(entity)
    return snapshot and snapshot.instanceId or nil
end

-- flat = true lays the seat down, false folds it up
local function setSeatExtras(stretcher, flat)
    SetVehicleExtra(stretcher, cfg.seatExtra.folded, not flat)
    SetVehicleExtra(stretcher, cfg.seatExtra.flat, flat == true)
end

-- Spawn with every extra disabled
local function setDefaultStretcherExtras(stretcher)
    for i = 1, cfg.maxExtraId do
        SetVehicleExtra(stretcher, i, true)
    end
    SetVehicleExtra(stretcher, cfg.headExtra, false)
end

local function getClosestStretcher(maxDistance)
    return EmsModels.Closest(stretcherHashes, maxDistance or cfg.interactDistance)
end

-- The authoritative equipment and ambulance state bags cover late stream-in.
local function getStoredStretcher(ambulance)
    return EmsSyncClient.GetStoredStretcher(ambulance)
end

local function hasStoredStretcherState(ambulance)
    return ambulance and ambulance ~= 0 and DoesEntityExist(ambulance)
        and Entity(ambulance).state[Config.Sync.storedStateKey] ~= nil
end

local function getPatientServerId(stretcher)
    if not stretcher or stretcher == 0 or not DoesEntityExist(stretcher) then return nil end
    local snapshot = EmsSyncClient.GetSnapshot(stretcher)
    return snapshot and snapshot.patient or nil
end

local function getNpcPatient(stretcher)
    if not stretcher or stretcher == 0 or not DoesEntityExist(stretcher) then return nil end
    local netId = NetworkGetNetworkIdFromEntity(stretcher)
    local ped = npcPatientsByStretcher[netId]
    if ped and DoesEntityExist(ped) then return ped end
    npcPatientsByStretcher[netId] = nil
    return nil
end

local function hasPatient(stretcher)
    if not stretcher or stretcher == 0 or not DoesEntityExist(stretcher) then return false end
    local snapshot = EmsSyncClient.GetSnapshot(stretcher)
    return (snapshot and snapshot.patient ~= nil)
        or getNpcPatient(stretcher) ~= nil
end

local CARRY_OFFSET = { x = -0.05, y = 1.3, z = -0.345, rx = 180.0, ry = 180.0, rz = 180.0 }

local function waitForAttachment(entity, parent)
    local deadline = GetGameTimer() + 500
    repeat
        if GetEntityAttachedTo(entity) == parent then return true end
        Wait(0)
    until GetGameTimer() >= deadline or not DoesEntityExist(entity) or not DoesEntityExist(parent)

    if not DoesEntityExist(entity) or not DoesEntityExist(parent) then return false end
    return GetEntityAttachedTo(entity) == parent
end

local function applyCarryAttach(stretcher, ped)
    if not stretcher or stretcher == 0 or not DoesEntityExist(stretcher) then return end
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end

    -- A frozen entity does not follow its attach parent, so always thaw before attaching
    FreezeEntityPosition(stretcher, false)
    -- -1 intentionally targets the ped entity transform instead of an
    -- animated skeleton bone, keeping the stretcher rigid while walking.
    AttachEntityToEntity(stretcher, ped, -1,
        CARRY_OFFSET.x, CARRY_OFFSET.y, CARRY_OFFSET.z,
        CARRY_OFFSET.rx, CARRY_OFFSET.ry, CARRY_OFFSET.rz,
        false, false, false, false, 2, true)
    return waitForAttachment(stretcher, ped)
end

-- The sync manager invokes this only on the current network owner.
local function applyGrounded(stretcher, grounded)
    if not stretcher or stretcher == 0 or not DoesEntityExist(stretcher) then return end

    DetachEntity(stretcher, true, true)
    FreezeEntityPosition(stretcher, false)
    SetEntityCollision(stretcher, true, true)
    SetEntityHasGravity(stretcher, true)
    SetEntityDynamic(stretcher, true)
    SetEntityCoords(stretcher, grounded.x, grounded.y, grounded.z, false, false, false, false)
    SetEntityHeading(stretcher, grounded.h or 0.0)
    SetVehicleOnGroundProperly(stretcher)
    return not IsEntityAttached(stretcher)
end

local function stopCarrying(placeOnGround)
    EmsSyncClient.RequestRelease()
end

local function storeStretcherInAmbulance(stretcher, ambulance, ambConfig)
    local ambNetId = NetworkGetNetworkIdFromEntity(ambulance)
    local stored = getStoredStretcher(ambulance)

    if stored and stored ~= stretcher then
        notify('stretcher_slot_occupied', 'error')
        return
    end

    TriggerServerEvent('daddy-patienttransport:stretcher:server:storeStretcher',
        ambNetId, NetworkGetNetworkIdFromEntity(stretcher), getInstanceId(stretcher))
end

local function seatPedInVehicle(ped, vehicle, seat)
    if not ped or ped == 0 or not vehicle or vehicle == 0 then return end

    Utils.RequestControl(ped)
    if IsVehicleSeatFree(vehicle, seat) then
        TaskWarpPedIntoVehicle(ped, vehicle, seat)
    elseif IsVehicleSeatFree(vehicle, seat - 1) then
        TaskWarpPedIntoVehicle(ped, vehicle, seat - 1)
    end
end

local function deliverPatientToAmbulance(stretcher, ambulance, ambConfig)
    if not hasPatient(stretcher) then
        notify('no_patient', 'error')
        return
    end

    local stretcherNetId = NetworkGetNetworkIdFromEntity(stretcher)
    local ambNetId = NetworkGetNetworkIdFromEntity(ambulance)
    local seat = Config.Ambulance.patientSeat

    -- NPC patients are moved locally, players go through the server
    local npcPed = getNpcPatient(stretcher)
    if npcPed and DoesEntityExist(npcPed) then
        Utils.RequestControl(npcPed)
        DetachEntity(npcPed, true, true)
        ClearPedTasks(npcPed)
        seatPedInVehicle(npcPed, ambulance, seat)
        npcPatientsByStretcher[stretcherNetId] = nil
        storeStretcherInAmbulance(stretcher, ambulance, ambConfig)
        notify('patient_delivered', 'success')
        return
    end

    if getPatientServerId(stretcher) then
        TriggerServerEvent('daddy-patienttransport:stretcher:server:deliverPatient',
            stretcherNetId, ambNetId, seat, getInstanceId(stretcher))
        storeStretcherInAmbulance(stretcher, ambulance, ambConfig)
        notify('patient_delivered', 'success')
    end
end

local function playCarryAnim()
    TaskPlayAnim(cache.ped, CARRY_ANIM_DICT, CARRY_ANIM_NAME, 8.0, 8.0, -1, 50, 0, false, false, false)
end

local function startCarrying(stretcher)
    if carryState.active then
        notify('already_carrying', 'error')
        return
    end

    if IsPedInAnyVehicle(cache.ped, false) then
        notify('cannot_carry_in_vehicle', 'error')
        return
    end

    EmsSyncClient.RequestCarry(stretcher, 'stretcher')
end

local function deactivateCarryPresentation()
    carryState.active = false
    carryState.stretcher = nil
    ClearPedTasksImmediately(cache.ped)
    lib.hideTextUI()
end

local function activateCarryPresentation(stretcher)
    if carryState.active and carryState.stretcher == stretcher then return end

    deactivateCarryPresentation()
    Utils.LoadAnim(CARRY_ANIM_DICT)
    carryState.active = true
    carryState.stretcher = stretcher
    playCarryAnim()

    CreateThread(function()
        local dropText = L('textui_drop_stretcher', cfg.dropKeybind)
        local storeText = L('textui_store_stretcher', cfg.dropKeybind)
        local shownText, nextScan, nextAnimCheck = nil, 0, 0
        local ambulance, ambConfig, atRearDoor
        local enterNotifyCooldown, storeCooldown = 0, 0

        while carryState.active and carryState.stretcher == stretcher and DoesEntityExist(stretcher) do
            local current = GetGameTimer()
            DisableControlAction(0, 23, true)

            if IsDisabledControlJustPressed(0, 23) and current > enterNotifyCooldown then
                enterNotifyCooldown = current + 3000
                notify('cannot_enter_vehicle', 'error')
            end

            if IsPedInAnyVehicle(cache.ped, false) then
                EmsSyncClient.RequestRelease()
                break
            end

            if current >= nextAnimCheck then
                nextAnimCheck = current + 500
                if IsPedDeadOrDying(cache.ped, true) then
                    EmsSyncClient.RequestRelease()
                    break
                end
                if not IsEntityPlayingAnim(cache.ped, CARRY_ANIM_DICT, CARRY_ANIM_NAME, 3) then
                    playCarryAnim()
                end
            end

            if current >= nextScan then
                nextScan = current + 250
                atRearDoor = false
                ambulance, ambConfig = Utils.GetClosestAmbulance(Config.Ambulance.interactDistance)
                if ambulance and ambConfig then
                    local rearCoords = Utils.GetAmbulanceRearCoords(ambulance, ambConfig.detection)
                    atRearDoor = #(GetEntityCoords(cache.ped) - rearCoords) <= Config.Ambulance.rearInteractDistance
                end

                local text = atRearDoor and storeText or dropText
                if text ~= shownText then
                    shownText = text
                    lib.showTextUI(text)
                end
            end

            if atRearDoor and current >= storeCooldown and IsControlJustPressed(0, 38) then
                storeCooldown = current + 1500
                storeStretcherInAmbulance(stretcher, ambulance, ambConfig)
            end

            Wait(0)
        end

        lib.hideTextUI()
    end)
end

local function deployStretcherFromAmbulance(ambulance, ambConfig)
    local stretcher = getStoredStretcher(ambulance)
    if stretcher then
        startCarrying(stretcher)
        return
    end

    -- Vehicle pickup mode may create a fresh server-owned unit when the slot is empty.
    TriggerServerEvent('daddy-patienttransport:stretcher:server:deployFromAmbulance',
        NetworkGetNetworkIdFromEntity(ambulance))
end

-- Medical scripts keep re-applying a downed player's death animation, and nothing we play
-- survives it. So we stop fighting it: a downed patient keeps
-- their death animation and we only correct the attach offset to match that pose. The values
-- in Config.DownedPosition are what lines the death pose up on a flat stretcher.
local poseToken = 0

-- Remembers where we are lying, so a death state change can swap us to the matching pose
local selfPose = { stretcher = nil, index = nil }

-- Keeps our pose winning against anything that tries to re-apply a downed animation
local function holdStretcherPose(stretcher, position)
    poseToken = poseToken + 1
    local token = poseToken

    CreateThread(function()
        while token == poseToken do
            Wait(500)
            if token ~= poseToken then return end
            if not DoesEntityExist(stretcher) then return end
            if not IsEntityAttachedToEntity(cache.ped, stretcher) then return end

            if not IsEntityPlayingAnim(cache.ped, position.anim, position.lib, 3) then
                TaskPlayAnim(cache.ped, position.anim, position.lib, 8.0, 8.0, -1, 1, 0, false, false, false)
            end
        end
    end)
end

local function attachPedToStretcher(ped, stretcher, positionIndex)
    if not ped or ped == 0 or not stretcher or stretcher == 0 then return end

    local idx = positionIndex or 1
    local position = Config.Positions[idx]
    if not position then return end

    Utils.RequestControl(ped)

    local isSelf = ped == cache.ped
    local downed = isSelf and Config.DownedPosition and Utils.IsSelfDowned()

    if downed then
        local downedPos = Config.DownedPosition

        -- Death animation stays untouched; the entity owner manages vehicle extras.
        poseToken = poseToken + 1
        selfPose.stretcher, selfPose.index = stretcher, idx

        AttachEntityToEntity(ped, stretcher, 0, downedPos.x, downedPos.y, downedPos.z,
            0.0, 0.0, downedPos.r, false, false, false, true, 2, true)
        stretcherDebug('attach immediate ped=%s self=%s downed=true pose=%s stretcher=%s attached=%s attachedTo=%s extra11=%s extra12=%s door4=%.3f',
            tostring(ped), tostring(isSelf), tostring(idx), tostring(stretcher),
            tostring(IsEntityAttachedToEntity(ped, stretcher)), tostring(GetEntityAttachedTo(ped)),
            tostring(IsVehicleExtraTurnedOn(stretcher, 11)),
            tostring(IsVehicleExtraTurnedOn(stretcher, 12)),
            GetVehicleDoorAngleRatio(stretcher, 4))
        return
    end

    Utils.LoadAnim(position.anim)
    AttachEntityToEntity(ped, stretcher, 0, position.x, position.y, position.z,
        0.0, 0.0, position.r, false, false, false, true, 2, true)
    TaskPlayAnim(ped, position.anim, position.lib, 8.0, 8.0, -1, 1, 0, false, false, false)
    stretcherDebug('attach immediate ped=%s self=%s downed=false pose=%s stretcher=%s attached=%s attachedTo=%s extra11=%s extra12=%s door4=%.3f',
        tostring(ped), tostring(isSelf), tostring(idx), tostring(stretcher),
        tostring(IsEntityAttachedToEntity(ped, stretcher)), tostring(GetEntityAttachedTo(ped)),
        tostring(IsVehicleExtraTurnedOn(stretcher, 11)),
        tostring(IsVehicleExtraTurnedOn(stretcher, 12)),
        GetVehicleDoorAngleRatio(stretcher, 4))

    if isSelf then
        selfPose.stretcher, selfPose.index = stretcher, idx
        holdStretcherPose(stretcher, position)
    end
end

-- Dying or being revived while already lying on the stretcher swaps which pose is correct,
-- so re-apply it. Covers both directions: alive -> downed offset, downed -> real pose.
local function onOwnDownedChanged(bagName)
    if bagName ~= ('player:%s'):format(GetPlayerServerId(PlayerId())) then return end

    CreateThread(function()
        Wait(500)

        local stretcher = selfPose.stretcher
        if not stretcher or not DoesEntityExist(stretcher) then return end
        if not IsEntityAttachedToEntity(cache.ped, stretcher) then return end

        attachPedToStretcher(cache.ped, stretcher, selfPose.index or 1)
    end)
end

AddStateBagChangeHandler('qbx_medical:deathState', '', onOwnDownedChanged)
AddStateBagChangeHandler(Bridge.DownedStateKey, '', onOwnDownedChanged)

local function detachPedFromStretcher(ped, stretcher)
    if not ped or ped == 0 then return end

    Utils.RequestControl(ped)
    DetachEntity(ped, true, true)
    ClearPedTasks(ped)

    if stretcher and stretcher ~= 0 and DoesEntityExist(stretcher) then
        local coords = GetEntityCoords(stretcher) + GetEntityForwardVector(stretcher) * -cfg.patientDetachDistance
        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    end

    if ped == cache.ped then
        poseToken = poseToken + 1
        selfPose.stretcher, selfPose.index = nil, nil
        -- The task clear above wipes a downed player's death animation, hand it back
        Utils.PlayDownedAnim()
    end

    if Utils.IsTestNpc(ped) then
        TriggerEvent('daddy-patienttransport:stretcher:client:playInjuredAnim', ped)
    end
end

local function applyPatientExtras(stretcher, snapshot)
    if not snapshot or not snapshot.patient then
        SetVehicleDoorShut(stretcher, 4, false)
        return
    end

    local pose = tonumber(snapshot.patientPose) or 1
    local downed = snapshot.patientDowned == true

    setSeatExtras(stretcher, downed or pose == 1)
    local position = Config.Positions[pose]
    if position and position.openDoor then
        SetVehicleDoorOpen(stretcher, 4, false, false)
    else
        SetVehicleDoorShut(stretcher, 4, false)
    end
end

EmsSyncClient.RegisterAdapter('stretcher', {
    model = cfg.model,
    models = cfg.models,
    reconcileObserver = EmsStretcherMechanism.Reconcile,
    clearObserver = EmsStretcherMechanism.Clear,
    attachCarrier = function(stretcher, ped, snapshot)
        setDefaultStretcherExtras(stretcher)
        applyPatientExtras(stretcher, snapshot)
        return applyCarryAttach(stretcher, ped)
    end,
    applyGround = function(stretcher, ground, snapshot)
        if not EmsStretcherMechanism.AwaitFold(stretcher, snapshot) then return nil end
        setDefaultStretcherExtras(stretcher)
        if not applyGrounded(stretcher, ground) then return nil end
        applyPatientExtras(stretcher, snapshot)
        Wait(0)
        SetVehicleOnGroundProperly(stretcher)
        if IsEntityAttached(stretcher) then return nil end
        local coords = GetEntityCoords(stretcher)
        return { x = coords.x, y = coords.y, z = coords.z, h = GetEntityHeading(stretcher) }
    end,
    applyStored = function(stretcher, ambulance, snapshot)
        local ambConfig = Utils.GetAmbulanceConfig(ambulance)
        if not ambConfig then return false end
        if not EmsStretcherMechanism.AwaitFold(stretcher, snapshot) then return false end
        if not DoesEntityExist(ambulance) then return false end

        DetachEntity(stretcher, true, false)
        setDefaultStretcherExtras(stretcher)
        applyPatientExtras(stretcher, snapshot)
        FreezeEntityPosition(stretcher, false)
        AttachEntityToEntity(stretcher, ambulance, 0, 0.0, ambConfig.depth, ambConfig.height,
            0.0, 0.0, 0.0, false, false, false, false, 2, true)
        return waitForAttachment(stretcher, ambulance)
    end,
    onCarrierActive = activateCarryPresentation,
    onCarrierReleased = deactivateCarryPresentation,
    applyPatient = function(ped, stretcher, state)
        attachPedToStretcher(ped, stretcher, state.pose or 1)
        return true
    end,
    removePatient = function(ped, stretcher)
        detachPedFromStretcher(ped, stretcher)
        return not IsEntityAttached(ped)
    end,
    isPatientApplied = function(ped, stretcher)
        return IsEntityAttachedToEntity(ped, stretcher)
    end,
})

local function layNpcOnStretcher(targetPed, stretcher, positionIndex)
    if not isStretcherOnGround(stretcher) then
        notify('no_stretcher_nearby', 'error')
        return
    end

    if hasPatient(stretcher) then
        notify('stretcher_has_patient', 'error')
        return
    end

    attachPedToStretcher(targetPed, stretcher, positionIndex or 1)
    local stretcherNetId = NetworkGetNetworkIdFromEntity(stretcher)
    npcPatientsByStretcher[stretcherNetId] = targetPed
    notify('patient_laid', 'success')
end

local function layPlayerOnStretcher(targetPed, stretcher)
    if not Utils.CanUseEmsInteract() then
        Utils.JobDeniedNotify('title_stretcher')
        return
    end

    if Utils.IsTestNpc(targetPed) then
        layNpcOnStretcher(targetPed, stretcher, 1)
        return
    end

    if not isStretcherOnGround(stretcher) then
        notify('no_stretcher_nearby', 'error')
        return
    end

    if hasPatient(stretcher) then
        notify('stretcher_has_patient', 'error')
        return
    end

    local playerIndex = NetworkGetPlayerIndexFromPed(targetPed)
    if playerIndex == -1 then return end

    TriggerServerEvent('daddy-patienttransport:stretcher:server:layPatient', GetPlayerServerId(playerIndex),
        NetworkGetNetworkIdFromEntity(stretcher), 1, getInstanceId(stretcher))
end

local function removePatientFromStretcher(stretcher)
    if not Utils.CanUseEmsInteract() then
        Utils.JobDeniedNotify('title_stretcher')
        return
    end

    local stretcherNetId = NetworkGetNetworkIdFromEntity(stretcher)
    local npcPed = getNpcPatient(stretcher)

    if npcPed and DoesEntityExist(npcPed) then
        detachPedFromStretcher(npcPed, stretcher)
        npcPatientsByStretcher[stretcherNetId] = nil
        notify('patient_removed', 'success')
        return
    end

    TriggerServerEvent('daddy-patienttransport:stretcher:server:removePatient', stretcherNetId, getInstanceId(stretcher))
end

-- A downed patient is locked into their death animation by the medical script, so changing their pose
-- does nothing visible. The death state bag is replicated, so we can check it from here.
local function isPatientAlive(stretcher)
    local npcPed = getNpcPatient(stretcher)
    if npcPed and DoesEntityExist(npcPed) then return true end

    local patientId = getPatientServerId(stretcher)
    if not patientId then return false end

    local playerIndex = GetPlayerFromServerId(patientId)
    if playerIndex == -1 then return false end
    local state = Player(patientId).state
    local qbxState = state['qbx_medical:deathState']
    if qbxState ~= nil then return qbxState == 1 end
    return state[Bridge.DownedStateKey] ~= true
end

local function openPositionMenu(stretcher)
    if not hasPatient(stretcher) then
        notify('no_patient', 'error')
        return
    end

    local stretcherNetId = NetworkGetNetworkIdFromEntity(stretcher)
    local options = {}

    for index, position in ipairs(Config.Positions) do
        options[#options + 1] = {
            title = L(position.localeKey),
            onSelect = function()
                local npcPed = getNpcPatient(stretcher)
                if npcPed and DoesEntityExist(npcPed) then
                    stretcherDebug('npc position selected ped=%s stretcher=%s net=%s pose=%s openDoor=%s',
                        tostring(npcPed), tostring(stretcher), tostring(stretcherNetId),
                        tostring(index), tostring(position.openDoor == true))
                    attachPedToStretcher(npcPed, stretcher, index)
                else
                    TriggerServerEvent('daddy-patienttransport:stretcher:server:changePosition',
                        stretcherNetId, index, getInstanceId(stretcher))
                end
            end,
        }
    end

    lib.registerContext({
        id = 'stretcher_positions',
        title = L('change_position'),
        options = options,
    })

    lib.showContext('stretcher_positions')
end

exports('SetTestMode', Utils.SetTestMode)
exports('LayNpcOnStretcher', layNpcOnStretcher)

lib.addKeybind({
    name = 'dpt_stretcher_drop',
    description = L('drop_stretcher', cfg.dropKeybind),
    defaultKey = cfg.dropKeybind,
    onPressed = function()
        if carryState.active or LocalPlayer.state[Config.Sync.carrierStateKey] then
            stopCarrying(true)
        end
    end,
})

Bridge.AddModelTarget(cfg.models or cfg.model, {
    {
        name = 'stretcher_take',
        icon = 'fa-solid fa-hand-holding-medical',
        label = L('take_stretcher'),
        distance = cfg.pickupDistance,
        canInteract = function(entity)
            return Utils.CanUseEmsInteract() and isStretcherOnGround(entity) and not carryState.active
        end,
        onSelect = function(data)
            startCarrying(data.entity)
        end,
    },
    {
        name = 'stretcher_lay_self',
        icon = 'fa-solid fa-bed-pulse',
        label = L('lay_self_stretcher'),
        distance = cfg.pickupDistance,
        canInteract = function(entity)
            if not Utils.CanUseEmsInteract() then return false end
            if carryState.active then return false end
            if IsPedInAnyVehicle(cache.ped, false) then return false end
            return isStretcherOnGround(entity) and not hasPatient(entity)
        end,
        onSelect = function(data)
            layPlayerOnStretcher(cache.ped, data.entity)
        end,
    },
    {
        name = 'stretcher_remove_patient',
        icon = 'fa-solid fa-person-walking',
        label = L('remove_patient'),
        distance = cfg.interactDistance,
        canInteract = function(entity)
            return Utils.CanUseEmsInteract() and hasPatient(entity)
        end,
        onSelect = function(data)
            removePatientFromStretcher(data.entity)
        end,
    },
    {
        name = 'stretcher_change_position',
        icon = 'fa-solid fa-bed-pulse',
        label = L('change_position'),
        distance = cfg.interactDistance,
        -- Hidden for downed patients: their death animation cannot be overridden, so the pose
        -- would not change and the menu would just look broken
        canInteract = function(entity)
            return Utils.CanUseEmsInteract() and hasPatient(entity) and isPatientAlive(entity)
        end,
        onSelect = function(data)
            openPositionMenu(data.entity)
        end,
    },
    {
        name = 'stretcher_fold',
        icon = 'fa-solid fa-box',
        label = L('fold_stretcher'),
        distance = cfg.interactDistance,
        canInteract = function(entity)
            if not cfg.enableItem then return false end
            return Utils.CanUseEmsInteract() and isStretcherOnGround(entity) and not hasPatient(entity)
        end,
        onSelect = function(data)
            local stretcher = data.entity
            local ok = lib.callback.await('daddy-patienttransport:stretcher:server:foldStretcher', false,
                NetworkGetNetworkIdFromEntity(stretcher), getInstanceId(stretcher))
            if not ok then return end
            notify('stretcher_folded', 'success')
        end,
    },
})

-- Test NPC options only exist while the test commands are enabled.
if Config.EnableTestCommands then
    Bridge.AddGlobalPedTarget({
        {
            name = 'stretcher_lay_test_npc',
            icon = 'fa-solid fa-bed-pulse',
            label = L('lay_patient'),
            distance = 2.5,
            canInteract = function(entity)
                if not Utils.CanUseEmsInteract() then return false end
                if not Utils.IsTestNpc(entity) then return false end
                if carryState.active then return false end
                if IsEntityAttachedToEntity(entity, cache.ped) then return false end

                local stretcher = getClosestStretcher(cfg.interactDistance)
                return stretcher ~= nil and isStretcherOnGround(stretcher) and not hasPatient(stretcher)
            end,
            onSelect = function(data)
                local stretcher = getClosestStretcher(cfg.interactDistance)
                if stretcher then
                    layNpcOnStretcher(data.entity, stretcher, 1)
                end
            end,
        },
    })
end

Bridge.AddGlobalPlayerTarget({
    {
        name = 'stretcher_lay_player',
        icon = 'fa-solid fa-bed-pulse',
        label = L('lay_patient'),
        distance = 2.5,
        canInteract = function(entity)
            if not Utils.CanUseEmsInteract() then return false end
            if entity == cache.ped then return false end
            if carryState.active then return false end

            local stretcher = getClosestStretcher(cfg.interactDistance)
            return stretcher ~= nil and isStretcherOnGround(stretcher) and not hasPatient(stretcher)
        end,
        onSelect = function(data)
            local stretcher = getClosestStretcher(cfg.interactDistance)
            if stretcher then
                layPlayerOnStretcher(data.entity, stretcher)
            end
        end,
    },
})

Bridge.AddGlobalVehicleTarget({
    {
        name = 'stretcher_deploy',
        icon = 'fa-solid fa-truck-medical',
        label = L('deploy_stretcher'),
        distance = Config.Ambulance.interactDistance,
        canInteract = function(entity)
            if not cfg.enableVehiclePickup then return false end
            if not Utils.CanUseEmsInteract() then return false end
            if carryState.active then return false end
            if not Utils.IsAmbulance(entity) then return false end
            return not IsPedInAnyVehicle(cache.ped, false)
        end,
        onSelect = function(data)
            local ambConfig = Utils.GetAmbulanceConfig(data.entity)
            if ambConfig then
                deployStretcherFromAmbulance(data.entity, ambConfig)
            end
        end,
    },
    {
        name = 'stretcher_store',
        icon = 'fa-solid fa-truck-ramp-box',
        label = L('store_stretcher'),
        distance = Config.Ambulance.interactDistance,
        canInteract = function(entity)
            if not cfg.enableVehiclePickup then return false end
            if not Utils.CanUseEmsInteract() then return false end
            if not carryState.active or not carryState.stretcher then return false end
            if not Utils.IsAmbulance(entity) then return false end
            if hasStoredStretcherState(entity) then return false end
            return not hasPatient(carryState.stretcher)
        end,
        onSelect = function(data)
            if not carryState.stretcher then return end
            local ambConfig = Utils.GetAmbulanceConfig(data.entity)
            if ambConfig then
                storeStretcherInAmbulance(carryState.stretcher, data.entity, ambConfig)
            end
        end,
    },
    {
        name = 'stretcher_deliver',
        icon = 'fa-solid fa-person-walking-arrow-right',
        label = L('deliver_patient'),
        distance = Config.Ambulance.interactDistance,
        canInteract = function(entity)
            if not cfg.enableDeliverTarget then return false end
            if not Utils.CanUseEmsInteract() then return false end
            if not carryState.active or not carryState.stretcher then return false end
            if not Utils.IsAmbulance(entity) then return false end
            return hasPatient(carryState.stretcher)
        end,
        onSelect = function(data)
            if not carryState.stretcher then return end
            local ambConfig = Utils.GetAmbulanceConfig(data.entity)
            if ambConfig then
                deliverPatientToAmbulance(carryState.stretcher, data.entity, ambConfig)
            end
        end,
    },
    {
        name = 'stretcher_retrieve',
        icon = 'fa-solid fa-dolly',
        label = L('take_stretcher'),
        distance = Config.Ambulance.interactDistance,
        -- Not gated behind enableVehiclePickup: storing works with [E] regardless of that flag,
        -- so gating only the retrieval left stretchers permanently locked inside the ambulance
        canInteract = function(entity)
            if not Utils.CanUseEmsInteract() then return false end
            if not Utils.IsAmbulance(entity) then return false end
            if carryState.active then return false end
            return hasStoredStretcherState(entity)
        end,
        onSelect = function(data)
            local ambConfig = Utils.GetAmbulanceConfig(data.entity)
            if ambConfig then
                deployStretcherFromAmbulance(data.entity, ambConfig)
            end
        end,
    },
    {
        name = 'stretcher_remove_patient_vehicle',
        icon = 'fa-solid fa-person-walking',
        label = L('remove_patient'),
        distance = Config.Ambulance.interactDistance,
        canInteract = function(entity)
            if not Utils.CanUseEmsInteract() then return false end
            if not Utils.IsAmbulance(entity) then return false end

            local stretcher = getStoredStretcher(entity)
            return stretcher ~= nil and hasPatient(stretcher)
        end,
        onSelect = function(data)
            -- Take the whole unit back out, same way it went in: stretcher + patient together
            local stretcher = getStoredStretcher(data.entity)
            if stretcher then
                startCarrying(stretcher)
            end
        end,
    },
})

-- /emsfix and the legacy aliases are registered by client/sync_manager.lua.

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    -- Only touch our own ped state when we were carrying; otherwise a restart would reset everyone.
    if carryState.active then deactivateCarryPresentation() end

    for _, ped in pairs(npcPatientsByStretcher) do
        if ped and DoesEntityExist(ped) and Utils.IsTestNpc(ped) then
            DeleteEntity(ped)
        end
    end
end)
