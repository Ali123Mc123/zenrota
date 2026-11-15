local cfg = Config.Wheelchair
local wheelchairHashes = EmsModels.Hashes(cfg.model, cfg.models)

local pushState = {
    active = false,
    wheelchair = nil,
}
local wheelchairExitGuard = {
    netId = nil,
    expiresAt = 0,
}
local wheelchairInternalExit = {
    netId = nil,
    expiresAt = 0,
}
local wheelchairPatientTransition = {
    busy = false,
    instanceId = nil,
}
local wheelchairCarryPoses = {}
local observerPatientAnimations = {}

local PUSH_ANIM_DICT = 'anim@heists@box_carry@'
local PUSH_ANIM_NAME = 'idle'
local PATIENT_ANIM_DICT = 'amb@prop_human_seat_chair_food@male@base'
local PATIENT_ANIM_NAME = 'base'

-- Controls blocked while the wheelchair is locked
local DRIVE_CONTROLS = {
    32, -- W forward
    33, -- S back
    34, -- A left
    35, -- D right
    59, -- move left/right
    63, -- turn left
    64, -- turn right
    71, -- vehicle accelerate
    72, -- vehicle brake
}

local function notify(messageKey, nType, ...)
    Utils.Notify('title_wheelchair', messageKey, nType, ...)
end

local function isWheelchair(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return false end
    local ok, model = pcall(GetEntityModel, entity) -- throws for some map objects ox_target aims at
    return ok and wheelchairHashes[model] == true
end

local function isWheelchairOnGround(entity)
    if not isWheelchair(entity) then return false end
    return EmsSyncClient.IsGrounded(entity)
end

local function isWheelchairLocked(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return false end
    local snapshot = EmsSyncClient.GetSnapshot(entity)
    if snapshot then return snapshot.locked == true end
    return Entity(entity).state.isLocked == true
end

local function getInstanceId(entity)
    local snapshot = EmsSyncClient.GetSnapshot(entity)
    return snapshot and snapshot.instanceId or nil
end

local function wheelchairSyncDebug(message, ...)
    if not Config.Sync.debug then return end
    print(('[daddy-patienttransport][sync][wheelchair] ' .. message):format(...))
end

local function normalizeAngle(value)
    while value > 180.0 do value -= 360.0 end
    while value < -180.0 do value += 360.0 end
    return value
end

local function markInternalWheelchairExit(wheelchair)
    wheelchairInternalExit.netId = NetworkGetNetworkIdFromEntity(wheelchair)
    wheelchairInternalExit.expiresAt = GetGameTimer() + 2500
end

local function captureWheelchairCarryPose(ped, wheelchair, instanceId)
    if not IsPedInVehicle(ped, wheelchair, false) then
        return wheelchairCarryPoses[instanceId]
    end

    local pedCoords = GetEntityCoords(ped)
    local offset = GetOffsetFromEntityGivenWorldCoords(
        wheelchair, pedCoords.x, pedCoords.y, pedCoords.z)
    local pedRotation = GetEntityRotation(ped, 2)
    local wheelchairRotation = GetEntityRotation(wheelchair, 2)
    local pose = {
        x = offset.x,
        y = offset.y,
        z = offset.z,
        rx = normalizeAngle(pedRotation.x - wheelchairRotation.x),
        ry = normalizeAngle(pedRotation.y - wheelchairRotation.y),
        rz = normalizeAngle(pedRotation.z - wheelchairRotation.z),
    }
    wheelchairCarryPoses[instanceId] = pose
    return pose
end

local function playWheelchairPatientAnim(ped, forceRestart)
    Utils.LoadAnim(PATIENT_ANIM_DICT)
    if forceRestart then
        -- The first task is created before the wheelchair owner reparents the
        -- chair to the carrier. Recreate it afterwards on the patient owner so
        -- that the final task tree is cloned to observers as well.
        StopAnimTask(ped, PATIENT_ANIM_DICT, PATIENT_ANIM_NAME, 0.0)
        Wait(0)
    end
    if forceRestart or not IsEntityPlayingAnim(ped, PATIENT_ANIM_DICT, PATIENT_ANIM_NAME, 3) then
        TaskPlayAnim(ped, PATIENT_ANIM_DICT, PATIENT_ANIM_NAME,
            8.0, 8.0, -1, 1, 0, false, false, false)
    end
    SetPedKeepTask(ped, true)
    ForceEntityAiAndAnimationUpdate(ped)
end

-- Runs one patient transition at a time. The flag is always released, even when a native throws
-- on a chair that was deleted mid-transition, so later attaches are never blocked for good.
local function runTransition(instanceId, fn, ...)
    if wheelchairPatientTransition.busy then return false end
    wheelchairPatientTransition.busy = true
    wheelchairPatientTransition.instanceId = instanceId
    local ok, result = pcall(fn, ...)
    wheelchairPatientTransition.busy = false
    wheelchairPatientTransition.instanceId = nil
    if not ok then wheelchairSyncDebug('patient transition failed: %s', tostring(result)) end
    return ok and result == true
end

local function attachWhileCarried(ped, wheelchair, instanceId)
    local pose = captureWheelchairCarryPose(ped, wheelchair, instanceId)
    if not pose then
        if IsPedInAnyVehicle(ped, false) then return false end

        ClearPedTasksImmediately(ped)
        TaskWarpPedIntoVehicle(ped, wheelchair, -1)
        Wait(100)
        if not DoesEntityExist(wheelchair) then return false end
        pose = captureWheelchairCarryPose(ped, wheelchair, instanceId)
    end
    if not pose then return false end

    if IsPedInVehicle(ped, wheelchair, false) then
        markInternalWheelchairExit(wheelchair)
        TaskLeaveVehicle(ped, wheelchair, 16)

        local deadline = GetGameTimer() + 750
        while DoesEntityExist(wheelchair) and IsPedInVehicle(ped, wheelchair, false) and GetGameTimer() < deadline do
            Wait(0)
        end
        if not DoesEntityExist(wheelchair) then return false end
        if IsPedInVehicle(ped, wheelchair, false) then
            ClearPedTasksImmediately(ped)
            Wait(0)
        end
    end

    if IsPedInAnyVehicle(ped, false) or not DoesEntityExist(wheelchair) then return false end

    if IsEntityAttached(ped) then DetachEntity(ped, true, true) end
    ClearPedTasksImmediately(ped)
    AttachEntityToEntity(ped, wheelchair, 0,
        pose.x, pose.y, pose.z, pose.rx, pose.ry, pose.rz,
        false, false, false, true, 2, true)
    playWheelchairPatientAnim(ped)
    -- Let the patient-owned attachment and animation enter clone sync before
    -- the equipment owner is allowed to attach the chair to the carrier.
    Wait(150)
    if not DoesEntityExist(wheelchair) then return false end

    local success = GetEntityAttachedTo(ped) == wheelchair
        and not IsPedInAnyVehicle(ped, false)
    wheelchairSyncDebug('patient carry mode instance=%s entity=%s attached=%s vehicle=%s',
        tostring(instanceId), tostring(wheelchair), tostring(GetEntityAttachedTo(ped)),
        tostring(GetVehiclePedIsIn(ped, false)))
    return success
end

local function attachPatientWhileCarried(ped, wheelchair)
    local instanceId = getInstanceId(wheelchair)
    if not instanceId then return false end

    if GetEntityAttachedTo(ped) == wheelchair and not IsPedInAnyVehicle(ped, false) then
        playWheelchairPatientAnim(ped)
        return true
    end
    return runTransition(instanceId, attachWhileCarried, ped, wheelchair, instanceId)
end

local function seatWhenGrounded(ped, wheelchair, instanceId)
    if IsEntityAttached(ped) then DetachEntity(ped, true, true) end
    SetPedKeepTask(ped, false)
    ClearPedTasksImmediately(ped)
    TaskWarpPedIntoVehicle(ped, wheelchair, -1)
    Wait(100)
    if not DoesEntityExist(wheelchair) then return false end

    local success = IsPedInVehicle(ped, wheelchair, false)
    if success and instanceId then wheelchairCarryPoses[instanceId] = nil end
    wheelchairSyncDebug('patient grounded mode instance=%s entity=%s seated=%s vehicle=%s',
        tostring(instanceId), tostring(wheelchair), tostring(success),
        tostring(GetVehiclePedIsIn(ped, false)))
    return success
end

local function seatPatientWhenGrounded(ped, wheelchair)
    local instanceId = getInstanceId(wheelchair)
    if IsPedInVehicle(ped, wheelchair, false) then
        if instanceId then wheelchairCarryPoses[instanceId] = nil end
        return true
    end
    return runTransition(instanceId, seatWhenGrounded, ped, wheelchair, instanceId)
end

local function applyWheelchairPatientMode(ped, wheelchair)
    local netId = NetworkGetNetworkIdFromEntity(wheelchair)
    if wheelchairExitGuard.netId == netId
        and GetGameTimer() < wheelchairExitGuard.expiresAt then
        return false
    end

    local snapshot = EmsSyncClient.GetSnapshot(wheelchair)
    if snapshot and snapshot.mode == 'carried' then
        return attachPatientWhileCarried(ped, wheelchair)
    end
    if snapshot and snapshot.mode == 'grounded' and IsEntityAttached(wheelchair) then
        return false
    end
    return seatPatientWhenGrounded(ped, wheelchair)
end

local function clearWheelchairObserver(wheelchair, snapshot)
    local instanceId = type(snapshot) == 'table' and snapshot.instanceId or nil
    local clearAll = not wheelchair and not instanceId

    for key, entry in pairs(observerPatientAnimations) do
        if clearAll or key == instanceId or entry.wheelchair == wheelchair then
            observerPatientAnimations[key] = nil
        end
    end
end

local function reconcileWheelchairObserver(wheelchair, snapshot, waitForClone)
    if type(snapshot) ~= 'table' or not snapshot.instanceId then return false end

    local patientSource = tonumber(snapshot.patient)
    local observerActive = snapshot.mode == 'carried'
        and patientSource
        and patientSource ~= cache.serverId
        and tonumber(snapshot.patientReadyRevision) == snapshot.revision

    if not observerActive then
        clearWheelchairObserver(wheelchair, snapshot)
        return false
    end

    local playerIndex = GetPlayerFromServerId(patientSource)
    if playerIndex == -1 then
        clearWheelchairObserver(wheelchair, snapshot)
        return false
    end

    local ped = GetPlayerPed(playerIndex)
    if ped == 0 or not DoesEntityExist(ped) then
        clearWheelchairObserver(wheelchair, snapshot)
        return false
    end

    local previous = observerPatientAnimations[snapshot.instanceId]
    if previous and previous.ped ~= ped then
        observerPatientAnimations[snapshot.instanceId] = nil
        previous = nil
    end

    -- The task is authored by the patient owner, but every observer still
    -- needs the dictionary resident before the cloned task can render.
    Utils.LoadAnim(PATIENT_ANIM_DICT)
    if waitForClone then
        local deadline = GetGameTimer() + 250
        while DoesEntityExist(wheelchair)
            and DoesEntityExist(ped)
            and GetEntityAttachedTo(ped) ~= wheelchair
            and GetGameTimer() < deadline do
            Wait(25)
        end
    end
    local live = EmsSyncClient.GetSnapshot(wheelchair)
    if not live
        or live.instanceId ~= snapshot.instanceId
        or live.revision ~= snapshot.revision
        or live.mode ~= 'carried' then
        return false
    end

    local playing = IsEntityPlayingAnim(ped, PATIENT_ANIM_DICT, PATIENT_ANIM_NAME, 3)
    local revisionChanged = not previous or previous.revision ~= snapshot.revision
    local requestedAt = revisionChanged and 0 or previous.requestedAt or 0
    local requests = revisionChanged and 0 or previous.requests or 0
    local current = GetGameTimer()

    if not playing and requests < 3 and current - requestedAt >= 750 then
        -- A client cannot author a task on another player's ped. Ask the
        -- server to make the patient owner recreate the task instead.
        requests += 1
        requestedAt = current
        TriggerServerEvent('daddy-patienttransport:server:requestPatientAnimationRefresh',
            snapshot.instanceId, snapshot.revision)
        wheelchairSyncDebug('observer requested patient anim refresh instance=%s rev=%s patient=%s ped=%s owner=%s attached=%s attempt=%s',
            tostring(snapshot.instanceId), tostring(snapshot.revision),
            tostring(patientSource), tostring(ped), tostring(NetworkGetEntityOwner(ped)),
            tostring(GetEntityAttachedTo(ped)), tostring(requests))
    end

    observerPatientAnimations[snapshot.instanceId] = {
        wheelchair = wheelchair,
        ped = ped,
        revision = snapshot.revision,
        requestedAt = requestedAt,
        requests = requests,
    }
    return true
end

local function wheelchairDriveState(entity)
    local snapshot = EmsSyncClient.GetSnapshot(entity)
    local carried = snapshot and snapshot.mode == 'carried'
    local locked = cfg.lockable and isWheelchairLocked(entity)
    if carried then return true, 'wheelchair_being_carried' end
    if locked then return true, 'wheelchair_is_locked' end
    return false, nil
end

local function getClosestWheelchair(maxDistance)
    return EmsModels.Closest(wheelchairHashes, maxDistance or cfg.interactDistance)
end

-- Grants the driver a vehicle key once the chair is unlocked, so vehicle key scripts do not block it
local function requestKeyIfUnlocked(wheelchair)
    if not isWheelchair(wheelchair) then return end
    if isWheelchairLocked(wheelchair) then return end
    local snapshot = EmsSyncClient.GetSnapshot(wheelchair)
    if snapshot and snapshot.mode ~= 'grounded' then return end
    TriggerServerEvent('daddy-patienttransport:wheelchair:server:requestKey', NetworkGetNetworkIdFromEntity(wheelchair))
end

AddStateBagChangeHandler('isLocked', '', function(bagName, _, value)
    if value ~= false then return end
    local entity = GetEntityFromStateBagName(bagName)
    if cache.vehicle == entity and cache.seat == -1 then
        requestKeyIfUnlocked(entity)
    end
end)

lib.onCache('seat', function(newSeat)
    if newSeat ~= -1 then return end
    requestKeyIfUnlocked(cache.vehicle)
end)

-- Grounded + unlocked is the drivable mode. While an EMS carries the chair,
-- driving stays disabled even if its wheel lock is open.
lib.onCache('vehicle', function(vehicle, previousVehicle)
    if previousVehicle and previousVehicle ~= 0 and isWheelchair(previousVehicle)
        and vehicle ~= previousVehicle then
        local netId = NetworkGetNetworkIdFromEntity(previousVehicle)
        local instanceId = getInstanceId(previousVehicle)
        local internalExit = wheelchairInternalExit.netId == netId
            and GetGameTimer() < wheelchairInternalExit.expiresAt

        if internalExit then
            wheelchairInternalExit.netId = nil
            wheelchairInternalExit.expiresAt = 0
        else
            wheelchairExitGuard.netId = netId
            wheelchairExitGuard.expiresAt = GetGameTimer() + 3000

            -- Exit is voluntary. Clear the server patient relation immediately
            -- so a delayed/retried attach state cannot warp the player back.
            CreateThread(function()
                for _ = 1, 4 do
                    if cache.vehicle == previousVehicle then return end
                    TriggerServerEvent('daddy-patienttransport:wheelchair:server:selfExited', netId, instanceId)
                    Wait(250)
                end
            end)
        end
    end

    if not vehicle or vehicle == 0 or not isWheelchair(vehicle) then return end
    Bridge.SetFuel(vehicle, 100.0)
    if wheelchairExitGuard.netId == NetworkGetNetworkIdFromEntity(vehicle) then
        wheelchairExitGuard.netId = nil
        wheelchairExitGuard.expiresAt = 0
    end

    CreateThread(function()
        Wait(500)
        if cache.vehicle == vehicle then
            TriggerServerEvent('daddy-patienttransport:server:adoptPatient',
                NetworkGetNetworkIdFromEntity(vehicle), 'wheelchair')
        end
    end)

    CreateThread(function()
        local notifyCooldown = 0
        local appliedState = nil

        while cache.vehicle == vehicle do
            local blocked, blockedReason = wheelchairDriveState(vehicle)

            if blocked ~= appliedState then
                appliedState = blocked
                SetVehicleUndriveable(vehicle, blocked)
                SetVehicleEngineOn(vehicle, not blocked, true, true)
            end

            if blocked then
                for i = 1, #DRIVE_CONTROLS do
                    DisableControlAction(0, DRIVE_CONTROLS[i], true)
                end

                if IsDisabledControlJustPressed(0, 32) or IsDisabledControlJustPressed(0, 33)
                    or IsDisabledControlJustPressed(0, 71) or IsDisabledControlJustPressed(0, 72) then
                    if GetGameTimer() > notifyCooldown then
                        notify(blockedReason or 'wheelchair_is_locked', 'error')
                        notifyCooldown = GetGameTimer() + cfg.lockNotifyCooldown
                    end
                end

                Wait(0)
            else
                Wait(250)
            end
        end
    end)
end)

-- These physical helpers are called only by the network-owner adapter below.
local PUSH_OFFSET = { x = -0.06, y = 0.85, z = -0.53, rx = 180.0, ry = 180.0, rz = 180.0 }

local function waitForAttachment(entity, parent)
    local deadline = GetGameTimer() + 500
    repeat
        if GetEntityAttachedTo(entity) == parent then return true end
        Wait(0)
    until GetGameTimer() >= deadline or not DoesEntityExist(entity) or not DoesEntityExist(parent)

    if not DoesEntityExist(entity) or not DoesEntityExist(parent) then return false end
    return GetEntityAttachedTo(entity) == parent
end

local function applyPushAttach(wheelchair, ped)
    if not wheelchair or wheelchair == 0 or not DoesEntityExist(wheelchair) then return end
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end

    SetEntityVelocity(wheelchair, 0.0, 0.0, 0.0)
    SetVehicleUndriveable(wheelchair, true)
    -- Keep the chair rigid against the ped entity transform instead of
    -- following an animated skeleton bone while the carrier walks.
    AttachEntityToEntity(wheelchair, ped, -1,
        PUSH_OFFSET.x, PUSH_OFFSET.y, PUSH_OFFSET.z,
        PUSH_OFFSET.rx, PUSH_OFFSET.ry, PUSH_OFFSET.rz,
        false, false, false, false, 2, true)
    return waitForAttachment(wheelchair, ped)
end

local function applyDetach(wheelchair)
    if not wheelchair or wheelchair == 0 or not DoesEntityExist(wheelchair) then return end

    DetachEntity(wheelchair, true, true)
    FreezeEntityPosition(wheelchair, false)
    SetEntityCollision(wheelchair, true, true)
end

local function stopPushing()
    EmsSyncClient.RequestRelease()
end

local function playPushAnim()
    TaskPlayAnim(cache.ped, PUSH_ANIM_DICT, PUSH_ANIM_NAME, 8.0, 8.0, -1, 50, 0, false, false, false)
end

local function startPushing(wheelchair)
    if pushState.active then
        notify('already_pushing_wheelchair', 'error')
        return
    end

    if IsPedInAnyVehicle(cache.ped, false) then
        notify('cannot_carry_in_vehicle', 'error')
        return
    end

    EmsSyncClient.RequestCarry(wheelchair, 'wheelchair')
end

local function deactivatePushPresentation()
    pushState.active = false
    pushState.wheelchair = nil
    ClearPedTasksImmediately(cache.ped)
    lib.hideTextUI()
end

local function activatePushPresentation(wheelchair)
    if pushState.active and pushState.wheelchair == wheelchair then return end

    deactivatePushPresentation()
    Utils.LoadAnim(PUSH_ANIM_DICT)
    pushState.active = true
    pushState.wheelchair = wheelchair
    playPushAnim()
    lib.showTextUI(L('textui_drop_wheelchair', cfg.dropKeybind))

    CreateThread(function()
        local nextAnimCheck, enterNotifyCooldown = 0, 0

        while pushState.active and pushState.wheelchair == wheelchair and DoesEntityExist(wheelchair) do
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
                if not IsEntityPlayingAnim(cache.ped, PUSH_ANIM_DICT, PUSH_ANIM_NAME, 3) then
                    playPushAnim()
                end
            end

            Wait(0)
        end
    end)
end

local function removePatientFromWheelchair(wheelchair)
    if not wheelchair or wheelchair == 0 or not DoesEntityExist(wheelchair) then return end

    local wheelchairNetId = NetworkGetNetworkIdFromEntity(wheelchair)
    local driverPed = GetPedInVehicleSeat(wheelchair, -1)

    if driverPed and driverPed ~= 0 and DoesEntityExist(driverPed) then
        if IsPedAPlayer(driverPed) then
            local playerIndex = NetworkGetPlayerIndexFromPed(driverPed)
            if playerIndex ~= -1 then
                TriggerServerEvent('daddy-patienttransport:wheelchair:server:removePatient',
                    wheelchairNetId, getInstanceId(wheelchair))
                return
            end
        else
            Utils.RequestControl(driverPed)
            TaskLeaveVehicle(driverPed, wheelchair, 16)
            Wait(300)

            -- Force the ped out if the leave task did not take
            if IsPedInVehicle(driverPed, wheelchair, false) then
                ClearPedTasksImmediately(driverPed)
                local coords = GetEntityCoords(wheelchair) + GetEntityForwardVector(wheelchair) * -1.5
                SetEntityCoords(driverPed, coords.x, coords.y, coords.z, false, false, false, false)
            end

            notify('wheelchair_patient_removed', 'success')
            return
        end
    end

    TriggerServerEvent('daddy-patienttransport:wheelchair:server:removePatient', wheelchairNetId, getInstanceId(wheelchair))
end

EmsSyncClient.RegisterAdapter('wheelchair', {
    model = cfg.model,
    models = cfg.models,
    attachCarrier = function(wheelchair, ped)
        -- Stay frozen until the chair is attached, otherwise it gets a few physics frames and drops
        FreezeEntityPosition(wheelchair, true)
        local attached = applyPushAttach(wheelchair, ped)
        FreezeEntityPosition(wheelchair, false)
        SetEntityCollision(wheelchair, true, true)
        return attached
    end,
    applyGround = function(wheelchair, ground)
        applyDetach(wheelchair)
        SetEntityHasGravity(wheelchair, true)
        SetEntityDynamic(wheelchair, true)
        SetEntityCoords(wheelchair, ground.x, ground.y, ground.z, false, false, false, false)
        SetEntityHeading(wheelchair, ground.h or GetEntityHeading(wheelchair))
        SetVehicleOnGroundProperly(wheelchair)
        Wait(0)
        SetVehicleOnGroundProperly(wheelchair)
        if IsEntityAttached(wheelchair) then return nil end
        local coords = GetEntityCoords(wheelchair)
        return { x = coords.x, y = coords.y, z = coords.z, h = GetEntityHeading(wheelchair) }
    end,
    onCarrierActive = activatePushPresentation,
    onCarrierReleased = deactivatePushPresentation,
    reconcileObserver = reconcileWheelchairObserver,
    clearObserver = clearWheelchairObserver,
    applyPatient = applyWheelchairPatientMode,
    reconcilePatient = applyWheelchairPatientMode,
    refreshPatientAnimation = function(ped, wheelchair, _, snapshot)
        if not snapshot
            or snapshot.kind ~= 'wheelchair'
            or snapshot.mode ~= 'carried'
            or tonumber(snapshot.patient) ~= cache.serverId
            or GetEntityAttachedTo(ped) ~= wheelchair
            or IsPedInAnyVehicle(ped, false) then
            return false
        end

        playWheelchairPatientAnim(ped, true)
        local playing = IsEntityPlayingAnim(ped, PATIENT_ANIM_DICT, PATIENT_ANIM_NAME, 3)
        wheelchairSyncDebug('patient owner anim refreshed instance=%s rev=%s ped=%s playing=%s',
            tostring(snapshot.instanceId), tostring(snapshot.revision), tostring(ped), tostring(playing))
        return playing
    end,
    removePatient = function(ped, wheelchair, state)
        local vehicle = wheelchair
        if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
            local attachedTo = GetEntityAttachedTo(ped)
            vehicle = isWheelchair(attachedTo) and attachedTo or GetVehiclePedIsIn(ped, false)
        end

        local instanceId = type(state) == 'table' and state.instanceId
            or (vehicle and vehicle ~= 0 and getInstanceId(vehicle) or nil)
        if instanceId then wheelchairCarryPoses[instanceId] = nil end
        SetPedKeepTask(ped, false)

        if vehicle and vehicle ~= 0 and GetEntityAttachedTo(ped) == vehicle then
            DetachEntity(ped, true, true)
            ClearPedTasksImmediately(ped)
            local coords = GetEntityCoords(vehicle) + GetEntityForwardVector(vehicle) * -1.5
            SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
            return GetEntityAttachedTo(ped) ~= vehicle
        end

        if not IsPedInAnyVehicle(ped, false) then return true end

        markInternalWheelchairExit(vehicle)
        TaskLeaveVehicle(ped, vehicle, 16)
        Wait(350)
        if IsPedInAnyVehicle(ped, false) then
            ClearPedTasksImmediately(ped)
            if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
                local coords = GetEntityCoords(vehicle) + GetEntityForwardVector(vehicle) * -1.5
                SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
            end
        end
        return not IsPedInAnyVehicle(ped, false)
    end,
    isPatientApplied = function(ped, wheelchair)
        local snapshot = EmsSyncClient.GetSnapshot(wheelchair)
        if snapshot and snapshot.mode == 'carried' then
            return GetEntityAttachedTo(ped) == wheelchair
                and not IsPedInAnyVehicle(ped, false)
        end
        return IsPedInVehicle(ped, wheelchair, false)
    end,
})

lib.addKeybind({
    name = 'dpt_wheelchair_drop',
    description = L('drop_wheelchair', cfg.dropKeybind),
    defaultKey = cfg.dropKeybind,
    onPressed = function()
        if pushState.active or LocalPlayer.state[Config.Sync.carrierStateKey] then
            stopPushing()
        end
    end,
})

Bridge.AddModelTarget(cfg.models or cfg.model, {
    {
        name = 'wheelchair_sit',
        icon = 'fa-solid fa-wheelchair',
        label = L('sit_wheelchair'),
        distance = cfg.interactDistance,
        canInteract = function(entity)
            if pushState.active then return false end
            if IsPedInAnyVehicle(cache.ped, false) then return false end
            return isWheelchair(entity) and IsVehicleSeatFree(entity, -1)
        end,
        onSelect = function(data)
            TriggerServerEvent('daddy-patienttransport:wheelchair:server:seatPatient',
                cache.serverId, NetworkGetNetworkIdFromEntity(data.entity), getInstanceId(data.entity))
        end,
    },
    {
        name = 'wheelchair_push',
        icon = 'fa-solid fa-person-walking-with-cane',
        label = L('push_wheelchair'),
        distance = cfg.pickupDistance,
        canInteract = function(entity)
            return Utils.CanUseEmsInteract() and isWheelchairOnGround(entity) and not pushState.active
        end,
        onSelect = function(data)
            startPushing(data.entity)
        end,
    },
    {
        name = 'wheelchair_lock',
        icon = 'fa-solid fa-lock',
        label = L('lock_wheelchair'),
        distance = cfg.interactDistance,
        canInteract = function(entity)
            if not cfg.lockable then return false end
            return WheelchairPermissionsClient.CanUse() and not isWheelchairLocked(entity)
        end,
        onSelect = function(data)
            TriggerServerEvent('daddy-patienttransport:wheelchair:server:toggleLock',
                NetworkGetNetworkIdFromEntity(data.entity), getInstanceId(data.entity))
        end,
    },
    {
        name = 'wheelchair_unlock',
        icon = 'fa-solid fa-lock-open',
        label = L('unlock_wheelchair'),
        distance = cfg.interactDistance,
        canInteract = function(entity)
            if not cfg.lockable then return false end
            return WheelchairPermissionsClient.CanUse() and isWheelchairLocked(entity)
        end,
        onSelect = function(data)
            TriggerServerEvent('daddy-patienttransport:wheelchair:server:toggleLock',
                NetworkGetNetworkIdFromEntity(data.entity), getInstanceId(data.entity))
        end,
    },
    {
        name = 'wheelchair_force_free',
        icon = 'fa-solid fa-link-slash',
        label = L('free_wheelchair'),
        distance = cfg.interactDistance,
        canInteract = function(entity)
            if not Utils.CanUseEmsInteract() then return false end
            if pushState.active and pushState.wheelchair == entity then return false end
            local snapshot = EmsSyncClient.GetSnapshot(entity)
            return snapshot and snapshot.mode == 'carried'
        end,
        onSelect = function(data)
            local snapshot = EmsSyncClient.GetSnapshot(data.entity)
            TriggerServerEvent('daddy-patienttransport:server:forceRelease',
                NetworkGetNetworkIdFromEntity(data.entity), snapshot and snapshot.instanceId)
        end,
    },
    {
        name = 'wheelchair_remove_patient',
        icon = 'fa-solid fa-person-walking',
        label = L('remove_wheelchair_patient'),
        distance = cfg.interactDistance,
        canInteract = function(entity)
            return isWheelchair(entity) and Utils.CanUseEmsInteract() and not IsVehicleSeatFree(entity, -1)
        end,
        onSelect = function(data)
            removePatientFromWheelchair(data.entity)
        end,
    },
    {
        name = 'wheelchair_fold',
        icon = 'fa-solid fa-box',
        label = L('fold_wheelchair'),
        distance = cfg.interactDistance,
        canInteract = function(entity)
            if not cfg.enableItem then return false end
            return WheelchairPermissionsClient.CanUse()
                and isWheelchairOnGround(entity) and IsVehicleSeatFree(entity, -1)
        end,
        onSelect = function(data)
            local wheelchair = data.entity
            local ok = lib.callback.await('daddy-patienttransport:wheelchair:server:foldWheelchair', false,
                NetworkGetNetworkIdFromEntity(wheelchair), getInstanceId(wheelchair))
            if not ok then return end
            notify('wheelchair_folded', 'success')
        end,
    },
})

-- Test NPC options only exist while the test commands are enabled.
if Config.EnableTestCommands then
    Bridge.AddGlobalPedTarget({
        {
            name = 'wheelchair_seat_npc',
            icon = 'fa-solid fa-wheelchair',
            label = L('lay_wheelchair_patient'),
            distance = 2.5,
            canInteract = function(entity)
                if not Utils.CanUseEmsInteract() then return false end
                if not Utils.IsTestNpc(entity) then return false end
                if pushState.active then return false end

                local wheelchair = getClosestWheelchair(cfg.interactDistance)
                return wheelchair ~= nil and isWheelchairOnGround(wheelchair) and IsVehicleSeatFree(wheelchair, -1)
            end,
            onSelect = function(data)
                local wheelchair = getClosestWheelchair(cfg.interactDistance)
                if wheelchair then
                    Utils.RequestControl(data.entity)
                    TaskWarpPedIntoVehicle(data.entity, wheelchair, -1)
                    notify('wheelchair_patient_seated', 'success')
                end
            end,
        },
    })
end

Bridge.AddGlobalPlayerTarget({
    {
        name = 'wheelchair_seat_player',
        icon = 'fa-solid fa-wheelchair',
        label = L('lay_wheelchair_patient'),
        distance = 2.5,
        canInteract = function(entity)
            if not Utils.CanUseEmsInteract() then return false end
            if entity == cache.ped then return false end
            if pushState.active then return false end

            local wheelchair = getClosestWheelchair(cfg.interactDistance)
            return wheelchair ~= nil and isWheelchairOnGround(wheelchair) and IsVehicleSeatFree(wheelchair, -1)
        end,
        onSelect = function(data)
            local wheelchair = getClosestWheelchair(cfg.interactDistance)
            if not wheelchair then return end

            local playerIndex = NetworkGetPlayerIndexFromPed(data.entity)
            if playerIndex == -1 then return end

            TriggerServerEvent('daddy-patienttransport:wheelchair:server:seatPatient',
                GetPlayerServerId(playerIndex), NetworkGetNetworkIdFromEntity(wheelchair),
                getInstanceId(wheelchair))
        end,
    },
})

if cfg.enableCommands then
    RegisterCommand('wheelchair', function()
        if not Utils.CanUseEmsInteract() then
            Utils.JobDeniedNotify('title_wheelchair')
            return
        end

        TriggerServerEvent('daddy-patienttransport:server:spawnCommand', 'wheelchair')
    end, false)

    RegisterCommand('delwheelchair', function()
        if not Utils.CanUseEmsInteract() then
            Utils.JobDeniedNotify('title_wheelchair')
            return
        end

        local wheelchair = getClosestWheelchair(cfg.deleteDistance)
        if not wheelchair then
            notify('no_wheelchair_nearby', 'error')
            return
        end

        TriggerServerEvent('daddy-patienttransport:server:deleteEquipment',
            NetworkGetNetworkIdFromEntity(wheelchair), 'wheelchair', getInstanceId(wheelchair))
    end, false)

    TriggerEvent('chat:addSuggestion', '/wheelchair', L('cmd_wheelchair'))
    TriggerEvent('chat:addSuggestion', '/delwheelchair', L('cmd_delwheelchair'))
end

-- /emsfix and the legacy aliases are registered by client/sync_manager.lua.

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    clearWheelchairObserver()
    if pushState.active then deactivatePushPresentation() end
end)
