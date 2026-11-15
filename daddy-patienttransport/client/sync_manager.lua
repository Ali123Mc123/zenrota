EmsSyncClient = EmsSyncClient or {}

local syncCfg = Config.Sync
local adapters = {}
local appliedOwnerRevision = {}
local trackedEntities = {}
local activeCarrier = nil
local activePatient = nil
local carrierPendingInstance = nil
local patientWorkToken = 0
local reconcileLocalPatient = nil
local reconcileEquipment = nil
local patientModeAckSent = {}

local function syncDebug(message, ...)
    if not syncCfg.debug then return end
    print(('[daddy-patienttransport][sync][client] ' .. message):format(...))
end

local function notify(messageKey, nType, ...)
    if not messageKey then return end
    Utils.Notify('title_ems_sync', messageKey, nType or 'inform', ...)
end

local function isFinite(value)
    return type(value) == 'number' and value == value and value ~= math.huge and value ~= -math.huge
end

local function getSnapshot(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return nil end
    local snapshot = Entity(entity).state[syncCfg.equipmentStateKey]
    return type(snapshot) == 'table' and snapshot or nil
end

local function resolveNetId(netId, timeoutMs)
    netId = tonumber(netId)
    if not netId or netId == 0 then return nil end

    local deadline = GetGameTimer() + (timeoutMs or syncCfg.entityResolveTimeoutMs)
    repeat
        if NetworkDoesEntityExistWithNetworkId(netId) then
            local entity = NetworkGetEntityFromNetworkId(netId)
            if entity and entity ~= 0 and DoesEntityExist(entity) then return entity end
        end
        Wait(100)
    until GetGameTimer() >= deadline

    return nil
end

local function adapterForEntity(entity, snapshot)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return nil end

    local model = GetEntityModel(entity)
    if snapshot and adapters[snapshot.kind] and adapters[snapshot.kind].hashes[model] then
        return adapters[snapshot.kind]
    end
    for _, adapter in pairs(adapters) do
        if adapter.hashes[model] then return adapter end
    end
    return nil
end

local function validGround(ground)
    return type(ground) == 'table'
        and isFinite(ground.x)
        and isFinite(ground.y)
        and isFinite(ground.z)
end

local function ownerAck(snapshot, op, ground)
    TriggerServerEvent('daddy-patienttransport:server:ownerAck', snapshot.instanceId, snapshot.revision, op, ground)
end

local function reconcileOwner(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return false end
    if NetworkGetEntityOwner(entity) ~= cache.playerId then return false end

    local snapshot = getSnapshot(entity)
    local adapter = adapterForEntity(entity, snapshot)
    if not snapshot or not adapter or not snapshot.instanceId or not snapshot.revision then
        syncDebug('owner reconcile blocked entity=%s snapshot=%s adapter=%s',
            entity, tostring(snapshot ~= nil), tostring(adapter ~= nil))
        return false
    end
    if snapshot.kind == 'wheelchair'
        and snapshot.mode == 'carried'
        and snapshot.patient
        and tonumber(snapshot.patientReadyRevision) ~= snapshot.revision then
        syncDebug('owner reconcile waiting for patient instance=%s rev=%s patient=%s ready=%s',
            tostring(snapshot.instanceId), tostring(snapshot.revision),
            tostring(snapshot.patient), tostring(snapshot.patientReadyRevision))
        return false
    end
    if tonumber(snapshot.netId) ~= NetworkGetNetworkIdFromEntity(entity) then
        syncDebug('owner reconcile blocked: net mismatch snapshot=%s local=%s instance=%s',
            tostring(snapshot.netId), NetworkGetNetworkIdFromEntity(entity), snapshot.instanceId)
        return false
    end

    -- A grounded wheelchair is a real drivable vehicle. Once a drop revision
    -- has been physically acknowledged, its network owner may move it freely;
    -- migration must not snap it back to the old drop coordinate.
    if snapshot.kind == 'wheelchair'
        and snapshot.mode == 'grounded'
        and tonumber(snapshot.appliedRevision) == snapshot.revision
        and not IsEntityAttached(entity) then
        appliedOwnerRevision[snapshot.instanceId] = snapshot.revision
        return true
    end

    if appliedOwnerRevision[snapshot.instanceId] == snapshot.revision then
        local physicallyApplied = false
        if snapshot.mode == 'carried' then
            local playerIndex = snapshot.carrier and GetPlayerFromServerId(snapshot.carrier) or -1
            if playerIndex ~= -1 then
                local ped = GetPlayerPed(playerIndex)
                physicallyApplied = ped ~= 0 and GetEntityAttachedTo(entity) == ped
            end
        elseif snapshot.mode == 'stored' then
            local parent = snapshot.storedIn and NetworkDoesEntityExistWithNetworkId(snapshot.storedIn)
                and NetworkGetEntityFromNetworkId(snapshot.storedIn) or 0
            physicallyApplied = parent ~= 0 and GetEntityAttachedTo(entity) == parent
        elseif snapshot.mode == 'grounded' and not IsEntityAttached(entity) and validGround(snapshot.ground) then
            if snapshot.kind == 'wheelchair' then
                physicallyApplied = true
            else
                local coords = GetEntityCoords(entity)
                local dx, dy, dz = coords.x - snapshot.ground.x, coords.y - snapshot.ground.y, coords.z - snapshot.ground.z
                physicallyApplied = dx * dx + dy * dy + dz * dz < 1.0
            end
        end

        if physicallyApplied and tonumber(snapshot.appliedRevision) == snapshot.revision then return true end
        if physicallyApplied then
            local op = snapshot.mode == 'carried' and 'carry'
                or snapshot.mode == 'stored' and 'store'
                or 'drop'
            ownerAck(snapshot, op, snapshot.mode == 'grounded' and snapshot.ground or nil)
            return true
        end

        appliedOwnerRevision[snapshot.instanceId] = nil
    end

    local success, op, ground = false, nil, nil

    if snapshot.mode == 'carried' then
        local playerIndex = snapshot.carrier and GetPlayerFromServerId(snapshot.carrier) or -1
        if playerIndex == -1 then
            syncDebug('carry apply blocked: carrier %s not in scope instance=%s',
                tostring(snapshot.carrier), snapshot.instanceId)
            return false
        end

        -- Player state bags are keyed by the server ID (player:<source>), not
        -- by the local player index returned from GetPlayerFromServerId.
        local carrierToken = Player(snapshot.carrier).state[syncCfg.sessionStateKey]
        if not carrierToken or carrierToken ~= snapshot.carrierToken then
            syncDebug('carry apply blocked: token mismatch instance=%s local=%s desired=%s',
                snapshot.instanceId, tostring(carrierToken), tostring(snapshot.carrierToken))
            return false
        end

        local ped = GetPlayerPed(playerIndex)
        if not ped or ped == 0 or not DoesEntityExist(ped) then
            syncDebug('carry apply blocked: carrier ped missing instance=%s playerIndex=%s',
                snapshot.instanceId, playerIndex)
            return false
        end

        local adapterSuccess = adapter.attachCarrier and adapter.attachCarrier(entity, ped, snapshot) == true
        -- The adapter waits, so the chair/stretcher may be gone by now.
        success = adapterSuccess and DoesEntityExist(entity) and GetEntityAttachedTo(entity) == ped
        if syncCfg.debug and DoesEntityExist(entity) then
            syncDebug('carry apply instance=%s rev=%s entity=%s ped=%s adapter=%s attachedTo=%s success=%s',
                snapshot.instanceId, snapshot.revision, entity, ped, tostring(adapterSuccess),
                tostring(GetEntityAttachedTo(entity)), tostring(success))
        end
        op = 'carry'
    elseif snapshot.mode == 'stored' then
        local parent = snapshot.storedIn and resolveNetId(snapshot.storedIn, 500) or nil
        if not parent then return false end

        success = adapter.applyStored and adapter.applyStored(entity, parent, snapshot) == true
        success = success and DoesEntityExist(entity) and GetEntityAttachedTo(entity) == parent
        op = 'store'
    elseif snapshot.mode == 'grounded' then
        if not validGround(snapshot.ground) then return false end

        ground = adapter.applyGround and adapter.applyGround(entity, snapshot.ground, snapshot) or nil
        success = type(ground) == 'table'
        op = 'drop'
    end

    if not success then return false end

    appliedOwnerRevision[snapshot.instanceId] = snapshot.revision
    if syncCfg.debug and DoesEntityExist(entity) then
        syncDebug('sending ACK op=%s instance=%s rev=%s owner=%s',
            op, snapshot.instanceId, snapshot.revision, NetworkGetEntityOwner(entity))
    end
    ownerAck(snapshot, op, ground)
    return true
end

local function resolveBagEntity(bagName)
    local deadline = GetGameTimer() + syncCfg.entityResolveTimeoutMs
    repeat
        local entity = GetEntityFromStateBagName(bagName)
        if entity and entity ~= 0 and DoesEntityExist(entity) then return entity end
        Wait(100)
    until GetGameTimer() >= deadline
    return nil
end

AddStateBagChangeHandler(syncCfg.equipmentStateKey, '', function(bagName, _, value)
    if type(value) ~= 'table' then
        local entity = GetEntityFromStateBagName(bagName)
        if entity and entity ~= 0 then
            local adapter = adapterForEntity(entity)
            if adapter and adapter.clearObserver then adapter.clearObserver(entity) end
            trackedEntities[entity] = nil
        end
        return
    end

    CreateThread(function()
        local entity = resolveBagEntity(bagName)
        if not entity then return end
        trackedEntities[entity] = true

        local current = getSnapshot(entity)
        if not current or current.instanceId ~= value.instanceId or current.revision ~= value.revision then return end
        if reconcileEquipment then
            reconcileEquipment(entity, current)
        else
            reconcileOwner(entity)
        end
        local adapter = adapterForEntity(entity, current)
        if adapter and adapter.reconcileObserver then
            adapter.reconcileObserver(entity, current, true)
        end
    end)
end)

local function releaseCarrierPresentation()
    carrierPendingInstance = nil
    if not activeCarrier then return end

    local adapter = adapters[activeCarrier.kind]
    if adapter and adapter.onCarrierReleased then
        adapter.onCarrierReleased(activeCarrier)
    end
    activeCarrier = nil
end

local function activateCarrierState(value, serverConfirmed)
    CreateThread(function()
        local function isCurrent()
            local current = LocalPlayer.state[syncCfg.carrierStateKey]
            if serverConfirmed then
                if type(current) ~= 'table' then return true end
                return current.instanceId == value.instanceId
                    and current.revision == value.revision
                    and current.token == value.token
                    and (current.status == 'pending' or current.status == 'active')
            end

            return type(current) == 'table'
                and current.instanceId == value.instanceId
                and current.revision == value.revision
                and current.status == value.status
                and current.token == value.token
        end

        if not isCurrent() then return end
        local entity = resolveNetId(value.netId)
        if not isCurrent() then return end
        if not entity then
            TriggerServerEvent('daddy-patienttransport:server:requestRelease', value.instanceId, value.revision)
            return
        end

        local snapshot = getSnapshot(entity)
        if not snapshot or snapshot.instanceId ~= value.instanceId
            or snapshot.revision ~= value.revision
            or snapshot.mode ~= 'carried'
            or snapshot.carrier ~= cache.serverId then
            TriggerServerEvent('daddy-patienttransport:server:requestRelease', value.instanceId, value.revision)
            return
        end

        local adapter = adapters[value.kind]
        if not adapter then return end

        if activeCarrier and activeCarrier.instanceId ~= value.instanceId then
            releaseCarrierPresentation()
        end

        carrierPendingInstance = nil
        activeCarrier = value
        activeCarrier.entity = entity
        syncDebug('carrier presentation active instance=%s rev=%s confirmed=%s',
            value.instanceId, value.revision, tostring(serverConfirmed))
        if adapter.onCarrierActive then adapter.onCarrierActive(entity, value) end
    end)
end

local function processCarrierState(value)
    if type(value) ~= 'table' then
        releaseCarrierPresentation()
        return
    end

    if value.token ~= LocalPlayer.state[syncCfg.sessionStateKey] then return end
    local latest = LocalPlayer.state[syncCfg.carrierStateKey]
    if type(latest) == 'table' and latest.token == value.token
        and (latest.instanceId ~= value.instanceId
            or latest.revision ~= value.revision
            or latest.status ~= value.status) then
        return
    end

    if value.status == 'pending' then
        if activeCarrier then releaseCarrierPresentation() end
        if carrierPendingInstance ~= value.instanceId then
            carrierPendingInstance = value.instanceId
            notify('sync_carry_pending', 'inform')
        end

        -- Server-setter entities can briefly be orphaned (owner -1), or their
        -- current owner may not have the carrier ped in scope. Let the carrier
        -- acquire control first; physical mutation still happens exclusively
        -- after this client is confirmed as the network owner.
        CreateThread(function()
            local deadline = GetGameTimer() + syncCfg.ackTimeoutMs
            local lastOwner = nil

            repeat
                local current = LocalPlayer.state[syncCfg.carrierStateKey]
                if type(current) ~= 'table'
                    or current.status ~= 'pending'
                    or current.instanceId ~= value.instanceId
                    or current.revision ~= value.revision
                    or current.token ~= value.token then
                    return
                end

                local entity = resolveNetId(value.netId, 500)
                if entity then
                    local owner = NetworkGetEntityOwner(entity)
                    if owner ~= lastOwner then
                        lastOwner = owner
                        syncDebug('pending control instance=%s rev=%s entity=%s owner=%s self=%s',
                            value.instanceId, value.revision, entity, owner, cache.playerId)
                    end
                    NetworkRequestControlOfEntity(entity)
                    if NetworkGetEntityOwner(entity) == cache.playerId then
                        local reconciled
                        if reconcileEquipment then
                            reconciled = reconcileEquipment(entity)
                        else
                            reconciled = reconcileOwner(entity)
                        end
                        syncDebug('pending owner acquired instance=%s rev=%s reconciled=%s',
                            value.instanceId, value.revision, tostring(reconciled))
                        if reconciled then return end
                    end
                end

                Wait(100)
            until GetGameTimer() >= deadline

            syncDebug('pending control timeout instance=%s rev=%s net=%s',
                value.instanceId, value.revision, tostring(value.netId))
        end)
        return
    end

    if value.status ~= 'active' then
        releaseCarrierPresentation()
        return
    end

    activateCarrierState(value, false)
end

RegisterNetEvent('daddy-patienttransport:client:carrierConfirmed', function(value)
    if type(value) ~= 'table' or value.status ~= 'active' then return end
    if value.token ~= LocalPlayer.state[syncCfg.sessionStateKey] then return end
    activateCarrierState(value, true)
end)

AddStateBagChangeHandler(syncCfg.carrierStateKey, '', function(bagName, _, value)
    if bagName ~= ('player:%s'):format(cache.serverId) then return end
    processCarrierState(value)
end)

local function patientApplied(adapter, ped, entity, state)
    local applied
    if adapter.isPatientApplied then
        applied = adapter.isPatientApplied(ped, entity, state)
    elseif state.kind == 'wheelchair' then
        applied = IsPedInVehicle(ped, entity, false)
    else
        applied = IsEntityAttachedToEntity(ped, entity)
    end

    -- Some FiveM natives return 1/0 instead of Lua true/false.
    return applied == true or applied == 1
end

reconcileLocalPatient = function(entity, snapshot)
    if not entity or entity == 0 or not DoesEntityExist(entity) or type(snapshot) ~= 'table' then
        return false
    end

    local state = LocalPlayer.state[syncCfg.patientStateKey]
    if type(state) ~= 'table'
        or state.status ~= 'attach'
        or state.token ~= LocalPlayer.state[syncCfg.sessionStateKey]
        or state.instanceId ~= snapshot.instanceId
        or tonumber(snapshot.patient) ~= cache.serverId then
        return false
    end

    local adapter = adapters[state.kind]
    if not adapter then return false end

    local success
    if adapter.reconcilePatient then
        success = adapter.reconcilePatient(cache.ped, entity, state, snapshot) == true
    elseif patientApplied(adapter, cache.ped, entity, state) then
        success = true
    elseif adapter.applyPatient then
        success = adapter.applyPatient(cache.ped, entity, state) == true
    else
        success = false
    end

    syncDebug('patient mode reconcile instance=%s rev=%s kind=%s mode=%s entity=%s success=%s vehicle=%s attachedTo=%s',
        tostring(snapshot.instanceId), tostring(snapshot.revision), tostring(state.kind),
        tostring(snapshot.mode), tostring(entity), tostring(success),
        tostring(GetVehiclePedIsIn(cache.ped, false)), tostring(GetEntityAttachedTo(cache.ped)))
    return success
end

reconcileEquipment = function(entity, snapshot)
    snapshot = snapshot or getSnapshot(entity)
    if type(snapshot) ~= 'table' then return reconcileOwner(entity) end
    if snapshot.mode ~= 'carried' and snapshot.instanceId then
        patientModeAckSent[snapshot.instanceId] = nil
    end

    local localPatientFirst = snapshot.kind == 'wheelchair'
        and snapshot.mode == 'carried'
        and tonumber(snapshot.patient) == cache.serverId

    if localPatientFirst then
        if not reconcileLocalPatient(entity, snapshot) then return false end

        if tonumber(snapshot.patientReadyRevision) ~= snapshot.revision then
            local sent = patientModeAckSent[snapshot.instanceId]
            local current = GetGameTimer()
            if not sent or sent.revision ~= snapshot.revision or current - sent.at >= 500 then
                patientModeAckSent[snapshot.instanceId] = {
                    revision = snapshot.revision,
                    at = current,
                }
                syncDebug('sending patient mode ACK instance=%s rev=%s mode=%s',
                    tostring(snapshot.instanceId), tostring(snapshot.revision), tostring(snapshot.mode))
                TriggerServerEvent('daddy-patienttransport:server:patientModeAck',
                    snapshot.instanceId, snapshot.revision, snapshot.mode)
            end
            return false
        end
    end

    local ownerApplied = reconcileOwner(entity)
    if not localPatientFirst then reconcileLocalPatient(entity, snapshot) end
    return ownerApplied
end

local function clearPatientPresentation()
    if not activePatient then return end

    local previous = activePatient
    activePatient = nil
    local entity = previous.netId and NetworkDoesEntityExistWithNetworkId(previous.netId)
        and NetworkGetEntityFromNetworkId(previous.netId) or 0
    local adapter = adapters[previous.kind]
    if adapter and adapter.removePatient then
        adapter.removePatient(cache.ped, entity ~= 0 and entity or nil, previous)
    end
end

local function processPatientState(value)
    patientWorkToken += 1
    local token = patientWorkToken

    if type(value) ~= 'table' then
        syncDebug('patient state cleared workToken=%s active=%s',
            token, activePatient and tostring(activePatient.instanceId) or 'nil')
        CreateThread(function()
            if token == patientWorkToken then clearPatientPresentation() end
        end)
        return
    end

    local localSessionToken = LocalPlayer.state[syncCfg.sessionStateKey]
    if value.token ~= localSessionToken then
        syncDebug('patient apply blocked: token mismatch instance=%s rev=%s local=%s desired=%s',
            tostring(value.instanceId), tostring(value.revision),
            tostring(localSessionToken), tostring(value.token))
        return
    end

    CreateThread(function()
        local success = false
        local deadline = GetGameTimer() + syncCfg.entityResolveTimeoutMs
        local attempt = 0

        syncDebug('patient work started instance=%s rev=%s kind=%s status=%s net=%s pose=%s',
            tostring(value.instanceId), tostring(value.revision), tostring(value.kind),
            tostring(value.status), tostring(value.netId), tostring(value.pose))

        repeat
            if token ~= patientWorkToken then return end
            attempt += 1

            local current = LocalPlayer.state[syncCfg.patientStateKey]
            if type(current) ~= 'table' or current.instanceId ~= value.instanceId or current.revision ~= value.revision then
                syncDebug('patient work cancelled instance=%s rev=%s attempt=%s current=%s/%s',
                    tostring(value.instanceId), tostring(value.revision), attempt,
                    type(current) == 'table' and tostring(current.instanceId) or 'nil',
                    type(current) == 'table' and tostring(current.revision) or 'nil')
                return
            end

            if value.status == 'vehicle' then
                local vehicle = resolveNetId(value.vehicleNetId, 500)
                if vehicle then
                    DetachEntity(cache.ped, true, true)
                    SetPedKeepTask(cache.ped, false)
                    ClearPedTasks(cache.ped)

                    local seat = tonumber(value.seat) or Config.Ambulance.patientSeat
                    if IsVehicleSeatFree(vehicle, seat) then
                        TaskWarpPedIntoVehicle(cache.ped, vehicle, seat)
                    elseif IsVehicleSeatFree(vehicle, seat - 1) then
                        TaskWarpPedIntoVehicle(cache.ped, vehicle, seat - 1)
                    end

                    Wait(150)
                    success = IsPedInVehicle(cache.ped, vehicle, false)
                    syncDebug('patient vehicle apply instance=%s rev=%s attempt=%s vehicle=%s seat=%s success=%s',
                        tostring(value.instanceId), tostring(value.revision), attempt,
                        tostring(vehicle), tostring(value.seat), tostring(success))
                else
                    syncDebug('patient vehicle unresolved instance=%s rev=%s attempt=%s vehicleNet=%s',
                        tostring(value.instanceId), tostring(value.revision), attempt,
                        tostring(value.vehicleNetId))
                end
            else
                local entity = resolveNetId(value.netId, 500)
                local adapter = entity and adapters[value.kind] or nil

                if entity and adapter then
                    if value.status == 'attach' then
                        local adapterApplied = adapter.applyPatient
                            and adapter.applyPatient(cache.ped, entity, value) == true
                        local physicallyApplied = patientApplied(adapter, cache.ped, entity, value)
                        success = adapterApplied and physicallyApplied
                        syncDebug('patient attach apply instance=%s rev=%s attempt=%s entity=%s owner=%s adapter=%s physical=%s attachedTo=%s success=%s',
                            tostring(value.instanceId), tostring(value.revision), attempt,
                            tostring(entity), tostring(NetworkGetEntityOwner(entity)),
                            tostring(adapterApplied), tostring(physicallyApplied),
                            tostring(GetEntityAttachedTo(cache.ped)), tostring(success))
                    elseif value.status == 'leave' then
                        success = adapter.removePatient and adapter.removePatient(cache.ped, entity, value) == true
                        syncDebug('patient leave apply instance=%s rev=%s attempt=%s entity=%s attached=%s success=%s',
                            tostring(value.instanceId), tostring(value.revision), attempt,
                            tostring(entity), tostring(IsEntityAttached(cache.ped)), tostring(success))
                    end
                elseif value.status == 'leave' then
                    DetachEntity(cache.ped, true, true)
                    SetPedKeepTask(cache.ped, false)
                    ClearPedTasks(cache.ped)
                    success = true
                    syncDebug('patient leave fallback instance=%s rev=%s attempt=%s entity=%s adapter=%s',
                        tostring(value.instanceId), tostring(value.revision), attempt,
                        tostring(entity), tostring(adapter ~= nil))
                else
                    syncDebug('patient apply unresolved instance=%s rev=%s attempt=%s net=%s entity=%s adapter=%s',
                        tostring(value.instanceId), tostring(value.revision), attempt,
                        tostring(value.netId), tostring(entity), tostring(adapter ~= nil))
                end
            end

            if success then
                if value.status == 'attach' then
                    activePatient = value
                else
                    activePatient = nil
                end
                syncDebug('sending patient ACK op=%s instance=%s rev=%s attempts=%s',
                    tostring(value.status), tostring(value.instanceId), tostring(value.revision), attempt)
                TriggerServerEvent('daddy-patienttransport:server:patientAck', value.instanceId, value.revision, value.status)
                return
            end

            Wait(250)
        until GetGameTimer() >= deadline

        syncDebug('patient apply timeout instance=%s rev=%s kind=%s status=%s attempts=%s attachedTo=%s vehicle=%s',
            tostring(value.instanceId), tostring(value.revision), tostring(value.kind),
            tostring(value.status), attempt, tostring(GetEntityAttachedTo(cache.ped)),
            tostring(GetVehiclePedIsIn(cache.ped, false)))
    end)
end

AddStateBagChangeHandler(syncCfg.patientStateKey, '', function(bagName, _, value)
    if bagName ~= ('player:%s'):format(cache.serverId) then return end
    processPatientState(value)
end)

RegisterNetEvent('daddy-patienttransport:client:refreshPatientAnimation', function(instanceId, revision)
    CreateThread(function()
        revision = tonumber(revision)
        local deadline = GetGameTimer() + syncCfg.entityResolveTimeoutMs

        repeat
            local state = LocalPlayer.state[syncCfg.patientStateKey]
            if type(state) ~= 'table'
                or state.status ~= 'attach'
                or state.kind ~= 'wheelchair'
                or state.instanceId ~= instanceId
                or state.token ~= LocalPlayer.state[syncCfg.sessionStateKey] then
                return
            end

            local entity = resolveNetId(state.netId, 500)
            local snapshot = entity and getSnapshot(entity) or nil
            local adapter = entity and adapters.wheelchair or nil
            local carrierIndex = snapshot and snapshot.carrier
                and GetPlayerFromServerId(tonumber(snapshot.carrier)) or -1
            local carrierPed = carrierIndex ~= -1 and GetPlayerPed(carrierIndex) or 0
            if snapshot
                and adapter
                and adapter.refreshPatientAnimation
                and snapshot.instanceId == instanceId
                and snapshot.revision == revision
                and snapshot.appliedRevision == revision
                and snapshot.mode == 'carried'
                and tonumber(snapshot.patient) == cache.serverId
                and carrierPed ~= 0
                and GetEntityAttachedTo(entity) == carrierPed then
                local success = adapter.refreshPatientAnimation(cache.ped, entity, state, snapshot) == true
                syncDebug('patient owner animation refresh instance=%s rev=%s entity=%s success=%s',
                    tostring(instanceId), tostring(revision), tostring(entity), tostring(success))
                return
            end

            Wait(100)
        until GetGameTimer() >= deadline

        syncDebug('patient owner animation refresh timeout instance=%s rev=%s',
            tostring(instanceId), tostring(revision))
    end)
end)

AddStateBagChangeHandler(syncCfg.sessionStateKey, '', function(bagName)
    if bagName ~= ('player:%s'):format(cache.serverId) then return end
    processCarrierState(LocalPlayer.state[syncCfg.carrierStateKey])
    processPatientState(LocalPlayer.state[syncCfg.patientStateKey])
end)

function EmsSyncClient.RegisterAdapter(kind, adapter)
    adapter.kind = kind
    adapter.hash = joaat(adapter.model)
    adapter.hashes = EmsModels.Hashes(adapter.model, adapter.models)
    adapters[kind] = adapter

    local carrier = LocalPlayer.state[syncCfg.carrierStateKey]
    if type(carrier) == 'table' and carrier.kind == kind then processCarrierState(carrier) end

    local patient = LocalPlayer.state[syncCfg.patientStateKey]
    if type(patient) == 'table' and patient.kind == kind then processPatientState(patient) end
end

function EmsSyncClient.GetSnapshot(entity)
    return getSnapshot(entity)
end

function EmsSyncClient.IsGrounded(entity)
    local snapshot = getSnapshot(entity)
    if snapshot then return snapshot.mode == 'grounded' and not snapshot.carrier end
    return entity and entity ~= 0 and DoesEntityExist(entity) and not IsEntityAttached(entity)
end

function EmsSyncClient.RequestCarry(entity, kind)
    if not entity or entity == 0 or not DoesEntityExist(entity) then
        notify('sync_entity_missing', 'error')
        return false
    end

    local snapshot = getSnapshot(entity)
    TriggerServerEvent('daddy-patienttransport:server:requestCarry',
        NetworkGetNetworkIdFromEntity(entity),
        snapshot and snapshot.instanceId or nil,
        kind)
    return true
end

function EmsSyncClient.RequestRelease()
    local state = LocalPlayer.state[syncCfg.carrierStateKey] or activeCarrier
    TriggerServerEvent('daddy-patienttransport:server:requestRelease',
        state and state.instanceId or nil,
        state and state.revision or nil)
end

function EmsSyncClient.GetStoredStretcher(ambulance)
    if not ambulance or ambulance == 0 or not DoesEntityExist(ambulance) then return nil end
    local netId = Entity(ambulance).state[syncCfg.storedStateKey]
    if not netId then return nil end

    if not NetworkDoesEntityExistWithNetworkId(netId) then return nil end
    local stretcher = NetworkGetEntityFromNetworkId(netId)
    if stretcher == 0 or not DoesEntityExist(stretcher) then return nil end
    local snapshot = getSnapshot(stretcher)
    if snapshot and snapshot.mode == 'stored' and snapshot.storedIn == NetworkGetNetworkIdFromEntity(ambulance) then
        return stretcher
    end
    return nil
end

RegisterNetEvent('daddy-patienttransport:client:result', function(ok, messageKey, nType, args)
    notify(messageKey, nType or (ok and 'success' or 'error'), table.unpack(args or {}))
end)

local function recoveryCandidates()
    local candidates = {}
    local coords = GetEntityCoords(cache.ped)

    for _, entity in ipairs(GetGamePool('CVehicle')) do
        local adapter = adapterForEntity(entity)
        if adapter and #(GetEntityCoords(entity) - coords) <= syncCfg.recoveryDistance then
            local snapshot = getSnapshot(entity)
            local related = (snapshot and (snapshot.carrier == cache.serverId
                    or snapshot.patient == cache.serverId
                    or IsEntityAttachedToEntity(entity, cache.ped)
                    or IsEntityAttachedToEntity(cache.ped, entity)
                    or GetVehiclePedIsIn(cache.ped, false) == entity))
                or (not snapshot and (IsEntityAttachedToEntity(entity, cache.ped)
                    or IsEntityAttachedToEntity(cache.ped, entity)
                    or GetVehiclePedIsIn(cache.ped, false) == entity))

            if related then
                candidates[#candidates + 1] = {
                    netId = NetworkGetNetworkIdFromEntity(entity),
                    instanceId = snapshot and snapshot.instanceId or nil,
                    kind = snapshot and snapshot.kind or adapter.kind,
                }

                local ownsRelationship = snapshot and (snapshot.carrier == cache.serverId
                    or (snapshot.mode == 'grounded' and snapshot.patient == cache.serverId))
                local locallyAttached = IsEntityAttachedToEntity(entity, cache.ped)
                if NetworkGetEntityOwner(entity) == cache.playerId
                    and (ownsRelationship or locallyAttached) then
                    adapter.applyGround(entity, snapshot and snapshot.ground or {
                        x = coords.x,
                        y = coords.y,
                        z = coords.z,
                        h = GetEntityHeading(cache.ped),
                    }, snapshot)
                end
            end
        end
    end

    return candidates
end

local function recoverSelf()
    releaseCarrierPresentation()
    patientWorkToken += 1

    local currentVehicle = GetVehiclePedIsIn(cache.ped, false)
    if currentVehicle and currentVehicle ~= 0 then
        local vehicleAdapter = adapterForEntity(currentVehicle)
        if vehicleAdapter and vehicleAdapter.removePatient then
            vehicleAdapter.removePatient(cache.ped, currentVehicle, {
                kind = vehicleAdapter.kind,
                status = 'leave',
            })
        end
    end

    local attachedTo = GetEntityAttachedTo(cache.ped)
    if attachedTo and attachedTo ~= 0 then
        local adapter = adapterForEntity(attachedTo)
        if adapter and adapter.removePatient then
            adapter.removePatient(cache.ped, attachedTo, { kind = adapter.kind, status = 'leave' })
        else
            DetachEntity(cache.ped, true, true)
            ClearPedTasks(cache.ped)
        end
    end

    activePatient = nil
    TriggerServerEvent('daddy-patienttransport:server:recoverSelf', recoveryCandidates())
end

RegisterCommand('emsfix', recoverSelf, false)
RegisterCommand('stretcherfix', recoverSelf, false)
RegisterCommand('wheelchairfix', recoverSelf, false)
RegisterCommand('sedyefix', recoverSelf, false)        -- DaddyRP Turkish aliases
RegisterCommand('sandalyefix', recoverSelf, false)

TriggerEvent('chat:addSuggestion', '/emsfix', L('cmd_emsfix'))
TriggerEvent('chat:addSuggestion', '/stretcherfix', L('cmd_stretcherfix'))
TriggerEvent('chat:addSuggestion', '/wheelchairfix', L('cmd_wheelchairfix'))

CreateThread(function()
    Wait(1000)
    for _, entity in ipairs(GetGamePool('CVehicle')) do
        if getSnapshot(entity) and adapterForEntity(entity) then
            trackedEntities[entity] = true
        end
    end

    processCarrierState(LocalPlayer.state[syncCfg.carrierStateKey])
    processPatientState(LocalPlayer.state[syncCfg.patientStateKey])

    -- One-time bridge for equipment created by the previous implementation.
    if IsPedInAnyVehicle(cache.ped, false) then
        local vehicle = GetVehiclePedIsIn(cache.ped, false)
        local adapter = adapterForEntity(vehicle)
        if adapter and adapter.kind == 'wheelchair' then
            TriggerServerEvent('daddy-patienttransport:server:adoptPatient', NetworkGetNetworkIdFromEntity(vehicle), 'wheelchair')
        end
    else
        local parent = GetEntityAttachedTo(cache.ped)
        local adapter = adapterForEntity(parent)
        if adapter and adapter.kind == 'stretcher' then
            TriggerServerEvent('daddy-patienttransport:server:adoptPatient', NetworkGetNetworkIdFromEntity(parent), 'stretcher')
        end
    end
end)

CreateThread(function()
    while true do
        Wait(syncCfg.ownerReconcileMs)

        local ownedInstances = {}
        for entity in pairs(trackedEntities) do
            local snapshot = getSnapshot(entity)
            local adapter = adapterForEntity(entity, snapshot)
            if not snapshot or not adapter then
                if adapter and adapter.clearObserver then adapter.clearObserver(entity, snapshot) end
                trackedEntities[entity] = nil
            else
                if adapter.reconcileObserver then adapter.reconcileObserver(entity, snapshot) end
                if NetworkGetEntityOwner(entity) == cache.playerId then
                    if snapshot.instanceId then ownedInstances[snapshot.instanceId] = true end
                    reconcileEquipment(entity, snapshot)
                end
            end
        end

        for instanceId in pairs(appliedOwnerRevision) do
            if not ownedInstances[instanceId] then appliedOwnerRevision[instanceId] = nil end
        end

        -- Patients own their own ped placement. Rebuild a broken attachment
        -- after stream/owner changes and let mode-aware adapters switch between
        -- vehicle seating and direct attachment without another client writing
        -- this player's ped.
        if activePatient then
            local state = LocalPlayer.state[syncCfg.patientStateKey]
            if type(state) == 'table'
                and state.status == 'attach'
                and state.token == LocalPlayer.state[syncCfg.sessionStateKey]
                and state.instanceId == activePatient.instanceId
                and NetworkDoesEntityExistWithNetworkId(state.netId or 0) then
                local entity = NetworkGetEntityFromNetworkId(state.netId)
                if entity ~= 0 and DoesEntityExist(entity) then
                    local snapshot = getSnapshot(entity)
                    if snapshot then reconcileEquipment(entity, snapshot) end
                end
            end
        end
    end
end)

-- Nothing here may yield: an onResourceStop handler that waits never resumes.
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    releaseCarrierPresentation()

    for entity in pairs(trackedEntities) do
        local snapshot = getSnapshot(entity)
        local adapter = adapterForEntity(entity, snapshot)
        if adapter and adapter.clearObserver then adapter.clearObserver(entity, snapshot) end
    end

    -- Put carried equipment down on the spot (the adapters' animated drop waits, so it is not used here).
    for _, entity in ipairs(GetGamePool('CVehicle')) do
        if NetworkGetEntityOwner(entity) == cache.playerId and IsEntityAttached(entity) then
            local snapshot = getSnapshot(entity)
            if snapshot and adapterForEntity(entity, snapshot) then
                DetachEntity(entity, true, true)
                FreezeEntityPosition(entity, false)
                SetEntityCollision(entity, true, true)
                SetVehicleOnGroundProperly(entity)
            end
        end
    end

    -- Last: the wheelchair adapter waits while standing the patient up.
    clearPatientPresentation()
end)
