Target, TargetRefs = {["name"] = nil,["export"] = nil}, {}

-----------------------------------------------------------------------------------------
-- EVENT'S --
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- CALLBACK'S --
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- FUNCTION'S --
-----------------------------------------------------------------------------------------

function DetectTarget()
    Config.Debug(('[^2INFO - TARGET^0] Detecting target resource...'))
    if GetResourceState("ox_target"):find("start") then
        Target.name = "ox"
        Target.export = exports.ox_target
        return Config.Debug(('[^2INFO - TARGET^0] Detected ox_target resource, using ox_target as target system'))
    end
    
    if GetResourceState("qb-target"):find("start") then
        Target.name = "qb"
        Target.export = exports['qb-target']
        return Config.Debug(('[^2INFO - TARGET^0] Detected qb-target resource, using qb-target as target system'))
    end

    Target.name = "none"
    return Config.Debug(('[^3WARNING - TARGET^0] No target resource detected, please install ox_target or qb-target for the best experience, or integrate your own target system using the function.'))
end

-- DaddyRP: daddy_venue's signs and screens are prop_tv_flat_01 too, but they are its own display and not TVs of this
-- script, so the model targets skip them (exports.daddy_venue:IsVenueObject).
local function venueObject(entity)
    if not entity or GetResourceState('daddy_venue') ~= 'started' then return false end
    local ok, owned = pcall(function() return exports.daddy_venue:IsVenueObject(entity) end)
    return ok and owned == true
end

local function skipVenue(check)
    return function(entity, ...)
        if venueObject(entity) then return false end
        if check then return check(entity, ...) end
        return true
    end
end

function AddTargetEntity(entity, options, localEntity, distance)
    while Target.name == nil do Wait(0) end
    if Target.name == "none" then return Config.Debug("[^2INFO - TARGET^0] No target resource detected, skipping adding target to entity") end
    Config.Debug(("[^2INFO - TARGET^0] Adding target to entity using %s target - Entity: %s, isLocal?: %s"):format(Target.name, entity, localEntity))
    
    if Target.name == "ox" then
        local newOptions = {}
        for i = 1, #options, 1 do
            newOptions[i] = {
                name = options[i].name,
                icon = options[i].icon,
                label = options[i].label,
                onSelect = options[i].action,
                canInteract = skipVenue(options[i].canInteract),
                distance = distance or 3.0
            }
        end

        if not localEntity then Target.export:addEntity(entity, newOptions) else Target.export:addLocalEntity(entity, newOptions) end
    elseif Target.name == "qb" then
        local newOptions = {}
        for i = 1, #options, 1 do
            local option = {}
            for key, value in pairs(options[i]) do option[key] = value end
            option.canInteract = skipVenue(options[i].canInteract)
            newOptions[i] = option
        end
        Target.export:AddTargetEntity(entity, {
            options = newOptions,
            distance = distance or 3.0,
        })
    end
end

function AddTargetModel(model, options, distance)
    while Target.name == nil do Wait(0) end
    if Target.name == "none" then return Config.Debug("[^2INFO - TARGET^0] No target resource detected, skipping adding target to entity") end
    Config.Debug(("[^2INFO - TARGET^0] Adding global target to model using %s target - Model: %s"):format(Target.name, model))

    if Target.name == "ox" then
        local newOptions = {}
        for i = 1, #options, 1 do
            newOptions[i] = {
                name = options[i].name,
                icon = options[i].icon,
                label = options[i].label,
                onSelect = options[i].action,
                canInteract = skipVenue(options[i].canInteract),
                distance = distance
            }
        end

        Target.export:addModel(model, newOptions)
    elseif Target.name == "qb" then
        local newOptions = {}
        for i = 1, #options, 1 do
            local option = {}
            for key, value in pairs(options[i]) do option[key] = value end
            option.canInteract = skipVenue(options[i].canInteract)
            newOptions[i] = option
        end
        Target.export:AddTargetModel(model, {
            options = newOptions,
            distance = distance,
        })
    end
end

function RemoveTargetEntity(entity, strNetId, localEntity)
    while Target.name == nil do Wait(0) end
    if Target.name == "none" then return Config.Debug("[^2INFO - TARGET^0] No target resource detected, skipping removing target from entity") end
    Config.Debug(("[^2INFO - TARGET^0] Removing target from entity using %s target - Entity: %s, isLocal?: %s"):format(Target.name, entity, localEntity))
    local options = {
        ('pause_resume_%s'):format(strNetId),
        ('destroy_video_%s'):format(strNetId),
        ('tv_take_back_%s'):format(strNetId),
    }

    if Target.name == "ox" then
        if not localEntity then Target.export:removeEntity(entity, options) else Target.export:removeLocalEntity(entity, options) end
    elseif Target.name == "qb" then
        Target.export:RemoveTargetEntity(entity, options)
    end
end

function ProgressBar(duration, label, anim)
    return lib.progressBar({
        duration = duration,
        label = label,
        useWhileDead = false,
        canCancel = true,
        anim = anim or nil,
        disable = {
            car = true,
            move = true,
            combat = true,
        }
    })
end

-----------------------------------------------------------------------------------------
-- COMMAND'S --
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- THREAD'S --
-----------------------------------------------------------------------------------------

CreateThread(DetectTarget)

-----------------------------------------------------------------------------------------
-- EXPORT'S --
-----------------------------------------------------------------------------------------