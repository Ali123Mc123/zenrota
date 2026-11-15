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
    if GetResourceState("ox_target"):find("start") then
        target = "ox"
    elseif GetResourceState("qb-target"):find("start") then
        target = "qb"
    else
        target = "none"
    end
end

function AddTargetEntity(entity, options, localEntity, distance)
    while target == nil do Wait(0) end
    if target == "none" then return Config.Debug("No target resource detected, skipping adding target to entity") end
    local ref = nil
    Config.Debug(("Adding target to entity using %s target - Entity: %s, isLocal?: %s"):format(target, entity, localEntity))

    if target == "ox" then
        local newOptions = {}
        for i = 1, #options, 1 do
            newOptions[i] = {
                name = options[i].name,
                icon = options[i].icon,
                label = options[i].label,
                onSelect = options[i].action,
                distance = distance or 3.0
            }
        end

        ref = not localEntity and exports.ox_target:addEntity(entity, newOptions) or exports.ox_target:addLocalEntity(entity, newOptions)
    elseif target == "qb" then
        ref = exports['qb-target']:AddTargetEntity(entity, {
            options = options,
            distance = distance or 3.0,
        })
    end

    if ref ~= nil then Targets[#Targets + 1] = ref end
    return ref
end

-----------------------------------------------------------------------------------------
-- COMMAND'S --
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- THREAD'S --
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- EXPORT'S --
-----------------------------------------------------------------------------------------