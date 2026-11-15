ActivitiesTarget = { backend = nil }

local zones, entities, zoneDefinitions, globals = {}, {}, {}, {}

local function detect()
    if ActivitiesConfig.interaction ~= 'target' then return nil end
    local wanted = ActivitiesConfig.target.system
    local ox, qb = GetResourceState('ox_target'), GetResourceState('qb-target')
    if wanted == 'ox' then return ox == 'started' and 'ox' or nil end
    if wanted == 'qb' then return qb == 'started' and 'qb' or nil end
    if ActivitiesTarget.backend == 'ox' and ox == 'started' then return 'ox' end
    if ActivitiesTarget.backend == 'qb' and qb == 'started' then return 'qb' end
    if ox == 'started' then return 'ox' end
    if qb == 'started' then return 'qb' end
    return nil
end

local function oxOptions(options)
    local result = {}
    for _, option in ipairs(options) do
        result[#result + 1] = {
            name = option.name,
            icon = option.icon or 'fa-solid fa-person-running',
            label = option.label,
            distance = option.distance or ActivitiesConfig.target.distance,
            canInteract = option.canInteract,
            onSelect = function(data) option.onSelect(data and data.entity) end
        }
    end
    return result
end

local function qbOptions(options)
    local result, labels, distance = {}, {}, ActivitiesConfig.target.distance
    for _, option in ipairs(options) do
        distance = math.max(distance, option.distance or ActivitiesConfig.target.distance)
        labels[#labels + 1] = option.label
        result[#result + 1] = {
            icon = option.icon or 'fas fa-person-running',
            label = option.label,
            distance = option.distance or ActivitiesConfig.target.distance,
            canInteract = option.canInteract,
            action = option.onSelect
        }
    end
    return result, distance, labels
end

CreateThread(function()
    if ActivitiesConfig.interaction ~= 'target' then return end
    while true do
        local backend = detect()
        if backend ~= ActivitiesTarget.backend then
            ActivitiesTarget.backend = backend
            if backend then
                local saved = entities
                entities = {}
                for entity, record in pairs(saved) do
                    if DoesEntityExist(entity) and not ActivitiesTarget.AddEntity(entity, record.options, record.netId) then
                        record.registered = false; entities[entity] = record
                    end
                end
                zones = {}
                for name, record in pairs(zoneDefinitions) do
                    ActivitiesTarget.AddSphere(name, record.coords, record.radius, record.options)
                end
                for name, record in pairs(globals) do
                    record.registered = false
                    ActivitiesTarget.AddGlobal(name, record.options)
                end
                TriggerEvent('0r-activities:client:targetReady')
            end
        end
        if ActivitiesTarget.Available() then
            for entity, record in pairs(entities) do
                if not DoesEntityExist(entity) then
                    entities[entity] = nil
                elseif not record.registered then
                    ActivitiesTarget.AddEntity(entity, record.options, record.netId)
                end
            end
            for name, record in pairs(zoneDefinitions) do
                if not zones[name] then ActivitiesTarget.AddSphere(name, record.coords, record.radius, record.options) end
            end
        end
        Wait(ActivitiesConfig.target.detectionIntervalMilliseconds)
    end
end)

function ActivitiesTarget.Available()
    return ActivitiesTarget.backend ~= nil
end

function ActivitiesTarget.WaitUntilReady()
    if ActivitiesConfig.interaction ~= 'target' then return false end
    while not ActivitiesTarget.backend do
        Wait(ActivitiesConfig.target.registrationIntervalMilliseconds)
    end
    return true
end

function ActivitiesTarget.AddEntity(entity, options, netId)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return false end
    if entities[entity] and entities[entity].registered then return ActivitiesTarget.Available() end
    local record = { options = options, netId = netId, registered = false }
    entities[entity] = record
    if ActivitiesTarget.backend == 'ox' then
        local player = GetEntityType(entity) == 1 and IsPedAPlayer(entity)
        record.player = player
        if netId and not NetworkDoesNetworkIdExist(netId) then return false end
        local ok = pcall(function()
            if player then
                local filtered = oxOptions(options)
                for _, option in ipairs(filtered) do
                    local canInteract = option.canInteract
                    option.canInteract = function(hit, ...)
                        return hit == entity and DoesEntityExist(entity)
                            and (not canInteract or canInteract(hit, ...))
                    end
                end
                exports.ox_target:addGlobalPlayer(filtered)
            elseif netId then exports.ox_target:addEntity(netId, oxOptions(options))
            else exports.ox_target:addLocalEntity(entity, oxOptions(options)) end
        end)
        if ok then record.registered = true return true end
    elseif ActivitiesTarget.backend == 'qb' then
        local qb, distance = qbOptions(options)
        local ok = pcall(function() exports['qb-target']:AddTargetEntity(entity, { options = qb, distance = distance }) end)
        if ok then record.registered = true return true end
    end
    return false
end

function ActivitiesTarget.RemoveEntity(entity)
    local record = entities[entity]
    if not record then return end
    entities[entity] = nil
    if ActivitiesTarget.backend == 'ox' then
        local names = {}
        for _, option in ipairs(record.options) do names[#names + 1] = option.name end
        pcall(function()
            if record.player then exports.ox_target:removeGlobalPlayer(names)
            elseif record.netId then exports.ox_target:removeEntity(record.netId, names)
            else exports.ox_target:removeLocalEntity(entity, names) end
        end)
    elseif ActivitiesTarget.backend == 'qb' then
        local _, _, labels = qbOptions(record.options)
        pcall(function() exports['qb-target']:RemoveTargetEntity(entity, labels) end)
    end
end

function ActivitiesTarget.AddSphere(name, coords, radius, options)
    if zones[name] then return ActivitiesTarget.Available() end
    zoneDefinitions[name] = { coords = coords, radius = radius, options = options }
    if ActivitiesTarget.backend == 'ox' then
        local ok, id = pcall(function()
            return exports.ox_target:addSphereZone({ coords = coords, radius = radius, options = oxOptions(options) })
        end)
        if ok and id then zones[name] = id return true end
    elseif ActivitiesTarget.backend == 'qb' then
        local qb, distance = qbOptions(options)
        local ok = pcall(function()
            exports['qb-target']:AddCircleZone(name, coords, radius, { name = name, useZ = true },
                { options = qb, distance = distance })
        end)
        if ok then zones[name] = name return true end
    end
    return false
end

function ActivitiesTarget.AddGlobal(name, options)
    local record = globals[name] or { options = options, registered = false }
    globals[name] = record
    record.options = options
    if record.registered or ActivitiesTarget.backend ~= 'ox' then return record.registered end
    record.registered = pcall(function() exports.ox_target:addGlobalOption(oxOptions(options)) end)
    return record.registered
end

function ActivitiesTarget.RemoveGlobal(name)
    local record = globals[name]
    if not record then return end
    globals[name] = nil
    if not record.registered or ActivitiesTarget.backend ~= 'ox' then return end
    local names = {}
    for _, option in ipairs(record.options) do names[#names + 1] = option.name end
    pcall(function() exports.ox_target:removeGlobalOption(names) end)
end

function ActivitiesTarget.RemoveSphere(name)
    local id = zones[name]
    zoneDefinitions[name] = nil
    if not id then return end
    zones[name] = nil
    if ActivitiesTarget.backend == 'ox' then
        pcall(function() exports.ox_target:removeZone(id) end)
    elseif ActivitiesTarget.backend == 'qb' then
        pcall(function() exports['qb-target']:RemoveZone(id) end)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == 'ox_target' or resource == 'qb-target' then
        if (resource == 'ox_target' and ActivitiesTarget.backend == 'ox')
            or (resource == 'qb-target' and ActivitiesTarget.backend == 'qb') then
            ActivitiesTarget.backend = nil
            for _, record in pairs(globals) do record.registered = false end
            for _, record in pairs(entities) do record.registered = false end
            zones = {}
        end
        return
    end
    if resource ~= GetCurrentResourceName() then return end
    for entity in pairs(entities) do ActivitiesTarget.RemoveEntity(entity) end
    for name in pairs(zones) do ActivitiesTarget.RemoveSphere(name) end
    for name in pairs(globals) do ActivitiesTarget.RemoveGlobal(name) end
end)
