local SYSTEM = Config.Interaction.targetScript

CreateThread(function()
    if SYSTEM == "auto" then
        if GetResourceState("ox-target") == "started" or GetResourceState("ox_target") == "started" then
            Config.Interaction.targetScript = "ox_target"
            SYSTEM = "ox_target"
            loadTarget()
        else
            Config.Interaction.targetScript = "qb-target"
            SYSTEM = "qb-target"
            loadTarget()
        end
    else
        loadTarget()
    end
end)

function loadTarget()
    function AddEntityToTargeting(entity, message, event, canInteract, meta, maxDist, icon)
        if not SYSTEM then
            return
        end
    
        local options = {
            type = 'client',
            event = event,
            icon = icon or 'fas fa-hand',
            label = message,
            meta = meta,
            distance = maxDist,
            canInteract = canInteract or function()
                return true
            end
        }
    
        if SYSTEM == 'ox-target' or SYSTEM == 'ox_target' then
            return exports[SYSTEM]:addLocalEntity(entity, {options})
        else
            exports[SYSTEM]:AddTargetEntity(entity, {
                options = {options},
                distance = maxDist
            })
            return entity
        end
    end
    
    
    function AddZoneToTargeting(coords, rotation, scale, message, event, canInteract, meta, maxDist, icon)
        if not SYSTEM then
            return
        end
        
        local identifier = math.random(0, 999999) .. '-' .. GetGameTimer()
        
        local option = {
            type = 'client',
            event = event,
            icon = icon or 'fas fa-hand',
            label = message,
            distance = maxDist,
            canInteract = canInteract or function()
                return true
            end
        }
        if meta and type(meta) == "table" then
            for k, v in pairs(meta) do
                if not (k == 'action' and type(v) ~= 'function') then
                    option[k] = v
                end
            end
        end
        
        local options = { option }
        
        if SYSTEM == 'ox-target' or SYSTEM == 'ox_target' then
            return exports[SYSTEM]:addBoxZone({
                coords = coords,
                size = scale.yxz,
                rotation = rotation or vector3(0, 0, 0),
                debug = Config.debugMode or false,
                drawSprite = true,
                options = options,
            })
        else
            exports[SYSTEM]:AddBoxZone(identifier, coords, scale.x, scale.y, {
                name = identifier,
                debugPoly = Config.debugMode or false,
                useZ = true,
                minZ = coords - (scale.z / 2),
                maxZ = coords + (scale.z / 2),
            }, {
                options = options,
                distance = maxDist or 2.5
            })
            
            return identifier
        end
    end
    
    function RemoveTargetZone(identifier)
        if not SYSTEM then
            return
        end
        
        if SYSTEM == 'ox-target' or SYSTEM == 'ox_target' then
            exports[SYSTEM]:removeZone(identifier)
        else
            -- Solution for qb-target and qtarget
            exports[SYSTEM]:RemoveZone(identifier)
        end
    end
    
    function RemoveTargetEntity(identifier)
        if not SYSTEM then
            return
        end
        
        if SYSTEM == 'ox-target' or SYSTEM == 'ox_target' then
            exports[SYSTEM]:removeLocalEntity(identifier)
        else
            -- Solution for qb-target and qtarget
            exports[SYSTEM]:RemoveTargetEntity(identifier)
        end
    end
    
    function AddModelToTargeting(model, message, eventOrFunc, canInteract, meta, maxDist, icon)
        if not SYSTEM then return end
    
        local modelHash = type(model) == "string" and joaat(model) or model
        local isFunction = type(eventOrFunc) == "function"
    
        if SYSTEM == 'ox-target' or SYSTEM == 'ox_target' then
            local options = {
                label = message,
                icon = icon or 'fas fa-hand',
                onSelect = eventOrFunc,
                distance = maxDist,
                canInteract = canInteract or function() return true end,
                metadata = meta
            }
            return exports[SYSTEM]:addModel(modelHash, { options })
        else
            local option = {
                label = message,
                icon = icon or 'fas fa-hand',
                distance = maxDist,
                action = eventOrFunc,
                canInteract = canInteract or function() return true end,
                meta = meta
            }
    
            if isFunction then
                option.action = eventOrFunc
            else
                option.type = 'client'
                option.event = eventOrFunc
            end
            local models = {}
            models[1] = modelHash
            return exports[SYSTEM]:AddTargetModel(models, {
                options = { option },
                distance = maxDist or 2.5
            })
        end
    end
    
    function RemoveModelFromTargeting(model)
        if not SYSTEM then return end
    
        local modelHash = type(model) == "string" and joaat(model) or model
    
        if SYSTEM == 'ox-target' or SYSTEM == 'ox_target' then
            return exports[SYSTEM]:removeModel(modelHash)
        else
            return exports[SYSTEM]:RemoveTargetModel(modelHash)
        end
    end
    
    function RemoveFromTargeting(model)
        if not SYSTEM then return false end
    
        local modelHash = type(model) == "string" and joaat(model) or model
    
        if SYSTEM == 'ox-target' or SYSTEM == 'ox_target' then
            return exports[SYSTEM]:removeModel(modelHash)
        else
            return exports[SYSTEM]:RemoveTargetModel(modelHash)
        end
    end
    
    exports('AddEntityToTargeting', AddEntityToTargeting)
    exports('AddZoneToTargeting', AddZoneToTargeting)
    exports('AddModelToTargeting', AddModelToTargeting)
    exports('RemoveModelFromTargeting', RemoveModelFromTargeting)
    exports('RemoveTargetEntity', RemoveTargetEntity)
    exports('RemoveFromTargeting', RemoveFromTargeting)
    exports('RemoveTargetZone', RemoveTargetZone)
end