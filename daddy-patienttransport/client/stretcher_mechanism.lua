EmsStretcherMechanism = {}

local cfg = Config.Stretcher.mechanism
local model = joaat(cfg.model)
local stretcherModels = EmsModels.Hashes(Config.Stretcher.model, Config.Stretcher.models)
local entries = {}
local clockOffset
local stopping = false

local function renderPhase(phase)
    -- The engine can wrap normalized time 1.0 to the first frame.
    -- Keep authoritative progress exact; clamp only the sampled pose.
    return math.max(0.0, math.min(0.9999, phase))
end

local function valid(entity, entry)
    if stopping or entries[entity] ~= entry or not DoesEntityExist(entity)
        or not stretcherModels[GetEntityModel(entity)] then return false end
    local snapshot = EmsSyncClient.GetSnapshot(entity)
    return snapshot and snapshot.instanceId == entry.instanceId
end

function EmsStretcherMechanism.Clear(entity)
    local entry = entries[entity]
    if not entry then return end
    entries[entity] = nil
    if entry.object and DoesEntityExist(entry.object) then DeleteEntity(entry.object) end
end

function EmsStretcherMechanism.AwaitFold(entity, snapshot)
    if GetResourceState(GetCurrentResourceName()) ~= 'started' or not snapshot or not snapshot.mechanism
        or snapshot.mechanism.targetPhase ~= 0 or snapshot.mechanism.durationMs == 0 then return true end
    EmsStretcherMechanism.Reconcile(entity, snapshot)
    local deadline = GetGameTimer() + cfg.durationMs + 100
    repeat
        local current = DoesEntityExist(entity) and EmsSyncClient.GetSnapshot(entity)
        if not current or current.instanceId ~= snapshot.instanceId or current.revision ~= snapshot.revision
            or NetworkGetEntityOwner(entity) ~= cache.playerId then return false end
        if clockOffset and EmsMechanism.Phase(current.mechanism, GetGameTimer() + clockOffset) <= 0 then
            return true
        end
        Wait(0)
    until stopping or GetGameTimer() >= deadline
    local current = DoesEntityExist(entity) and EmsSyncClient.GetSnapshot(entity)
    return not stopping and current and current.instanceId == snapshot.instanceId
        and current.revision == snapshot.revision and NetworkGetEntityOwner(entity) == cache.playerId
end

function EmsStretcherMechanism.Reconcile(entity, snapshot)
    if stopping or not snapshot or not snapshot.mechanism then return end
    local entry = entries[entity]
    if entry and entry.instanceId ~= snapshot.instanceId then
        EmsStretcherMechanism.Clear(entity)
        entry = nil
    end
    if not entry then
        entry = { instanceId = snapshot.instanceId, state = snapshot.mechanism }
        entries[entity] = entry
    end
    -- Owner ACKs and patient pose changes must not restart the clip.
    if snapshot.mechanism.id >= entry.state.id then entry.state = snapshot.mechanism end
    if entry.object and DoesEntityExist(entry.object) then return end
    if entry.loading or clockOffset == nil then return end
    if entry.retryAt and GetGameTimer() < entry.retryAt then return end
    entry.loading = true

    CreateThread(function()
        RequestModel(model)
        RequestAnimDict(cfg.dictionary)
        local deadline = GetGameTimer() + cfg.loadTimeoutMs
        while valid(entity, entry) and (not HasModelLoaded(model) or not HasAnimDictLoaded(cfg.dictionary))
            and GetGameTimer() < deadline do Wait(0) end
        entry.loading = false
        if not valid(entity, entry) then return end
        if not HasModelLoaded(model) or not HasAnimDictLoaded(cfg.dictionary) then
            entry.retryAt = GetGameTimer() + 5000
            print('[daddy-patienttransport] DD mechanism model/animation load failed; retrying in 5s')
            return
        end

        local coords = GetEntityCoords(entity)
        pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
        local object = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, false, false, false)
        if object == 0 then entry.retryAt = GetGameTimer() + 5000; return end
        entry.object = object
        SetEntityAsMissionEntity(object, true, true)
        SetEntityCollision(object, false, false)
        SetEntityInvincible(object, true)
        SetEntityHasGravity(object, false)
        AttachEntityToEntity(object, entity, -1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            false, false, false, false, 2, true)
        local phase = renderPhase(EmsMechanism.Phase(entry.state, GetGameTimer() + clockOffset))
        PlayEntityAnim(object, cfg.clip, cfg.dictionary, 1000.0, false, true, false, phase, 0)
        SetEntityAnimSpeed(object, cfg.dictionary, cfg.clip, 0.0)
        SetEntityAnimCurrentTime(object, cfg.dictionary, cfg.clip, phase)
    end)
end

CreateThread(function()
    while not stopping do
        local sent = GetGameTimer()
        local ok, serverTime = pcall(lib.callback.await, 'daddy-patienttransport:server:mechanismClock', false)
        if ok and type(serverTime) == 'number' then
            clockOffset = serverTime - (sent + GetGameTimer()) / 2
        end
        Wait(clockOffset and 30000 or 2000)
    end
end)

CreateThread(function()
    while not stopping do
        local active = false
        for entity, entry in pairs(entries) do
            if not valid(entity, entry) then
                EmsStretcherMechanism.Clear(entity)
            elseif entry.object and DoesEntityExist(entry.object) and clockOffset then
                if GetEntityAttachedTo(entry.object) ~= entity then
                    AttachEntityToEntity(entry.object, entity, -1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        false, false, false, false, 2, true)
                end
                local phase = EmsMechanism.Phase(entry.state, GetGameTimer() + clockOffset)
                local pose = renderPhase(phase)
                if not IsEntityPlayingAnim(entry.object, cfg.dictionary, cfg.clip, 3) then
                    PlayEntityAnim(entry.object, cfg.clip, cfg.dictionary, 1000.0, false, true, false, pose, 0)
                end
                SetEntityAnimSpeed(entry.object, cfg.dictionary, cfg.clip, 0.0)
                SetEntityAnimCurrentTime(entry.object, cfg.dictionary, cfg.clip, pose)
                active = active or phase ~= entry.state.targetPhase
            end
        end
        Wait(active and 0 or (next(entries) and 50 or 500))
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    stopping = true
    for entity in pairs(entries) do EmsStretcherMechanism.Clear(entity) end
    SetModelAsNoLongerNeeded(model)
    RemoveAnimDict(cfg.dictionary)
end)
