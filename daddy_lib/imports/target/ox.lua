local handles = {}

local function options(key, box)
    local out = {}
    for i, option in ipairs(box.options) do
        out[i] = {
            name = ('%s:%s:%d'):format(DL.resource, key, i),
            label = option.label,
            icon = option.icon,
            distance = box.distance,
            canInteract = option.canInteract and function(entity) return option.canInteract(entity) end,
            onSelect = function(data) option.onSelect(data and data.entity) end,
        }
    end
    return out
end

local ADD = {
    box = function(key, d)
        return exports.ox_target:addBoxZone({ coords = d.coords, size = d.size, rotation = d.heading, options = options(key, d) })
    end,
    sphere = function(key, d)
        return exports.ox_target:addSphereZone({ coords = d.coords, radius = d.radius, options = options(key, d) })
    end,
    poly = function(key, d)
        local z = (d.minZ + d.maxZ) * 0.5
        local points = {}
        for i, p in ipairs(d.points) do points[i] = vector3(p.x, p.y, z) end
        return exports.ox_target:addPolyZone({ points = points, thickness = d.maxZ - d.minZ, options = options(key, d) })
    end,
    entity = function(key, d)
        local opts, names = options(key, d), {}
        for i, option in ipairs(opts) do names[i] = option.name end
        exports.ox_target:addLocalEntity(d.entity, opts)
        return { entity = d.entity, names = names }
    end,
    players = function(key, d)
        local opts, names = options(key, d), {}
        for i, option in ipairs(opts) do names[i] = option.name end
        exports.ox_target:addGlobalPlayer(opts)
        return { names = names }
    end,
    models = function(key, d)
        local opts, names = options(key, d), {}
        for i, option in ipairs(opts) do names[i] = option.name end
        exports.ox_target:addModel(d.models, opts)
        return { models = d.models, names = names }
    end,
}

return {
    add = function(key, kind, data)
        handles[key] = { kind = kind, id = ADD[kind](key, data) }
    end,

    remove = function(key)
        local handle = handles[key]
        handles[key] = nil
        if not handle then return end
        if handle.kind == 'entity' then
            if DoesEntityExist(handle.id.entity) then exports.ox_target:removeLocalEntity(handle.id.entity, handle.id.names) end
        elseif handle.kind == 'players' then
            exports.ox_target:removeGlobalPlayer(handle.id.names)
        elseif handle.kind == 'models' then
            exports.ox_target:removeModel(handle.id.models, handle.id.names)
        else
            exports.ox_target:removeZone(handle.id)
        end
    end,
}
