local handles = {}

local function zoneName(key) return ('%s:%s'):format(DL.resource, key) end

local function options(d)
    local out = {}
    for i, option in ipairs(d.options) do
        out[i] = {
            label = option.label,
            icon = option.icon,
            canInteract = option.canInteract and function(entity) return option.canInteract(entity) end,
            action = function(entity) option.onSelect(entity) end,
        }
    end
    return { options = out, distance = d.distance }
end

local ADD = {
    box = function(key, d)
        local half = d.size.z / 2
        exports['qb-target']:AddBoxZone(zoneName(key), d.coords, d.size.y, d.size.x, {
            name = zoneName(key), heading = d.heading, minZ = d.coords.z - half, maxZ = d.coords.z + half,
        }, options(d))
    end,
    sphere = function(key, d)
        exports['qb-target']:AddCircleZone(zoneName(key), d.coords, d.radius, { name = zoneName(key), useZ = true }, options(d))
    end,
    poly = function(key, d)
        local points = {}
        for i, p in ipairs(d.points) do points[i] = vector2(p.x, p.y) end
        exports['qb-target']:AddPolyZone(zoneName(key), points, { name = zoneName(key), minZ = d.minZ, maxZ = d.maxZ }, options(d))
    end,
    entity = function(_, d)
        local opts = options(d)
        exports['qb-target']:AddTargetEntity(d.entity, opts)
        local labels = {}
        for i, o in ipairs(opts.options) do labels[i] = o.label end
        return { entity = d.entity, labels = labels }
    end,
    players = function(_, d)
        local opts = options(d)
        exports['qb-target']:AddGlobalPlayer(opts)
        local labels = {}
        for i, o in ipairs(opts.options) do labels[i] = o.label end
        return { labels = labels }
    end,
    models = function(_, d)
        local opts = options(d)
        exports['qb-target']:AddTargetModel(d.models, opts)
        local labels = {}
        for i, o in ipairs(opts.options) do labels[i] = o.label end
        return { models = d.models, labels = labels }
    end,
}

return {
    add = function(key, kind, data)
        handles[key] = { kind = kind, data = ADD[kind](key, data) }
    end,

    remove = function(key)
        local handle = handles[key]
        handles[key] = nil
        if not handle then return end
        if handle.kind == 'entity' then
            exports['qb-target']:RemoveTargetEntity(handle.data.entity, handle.data.labels)
        elseif handle.kind == 'players' then
            exports['qb-target']:RemoveGlobalPlayer(handle.data.labels)
        elseif handle.kind == 'models' then
            exports['qb-target']:RemoveTargetModel(handle.data.models, handle.data.labels)
        else
            exports['qb-target']:RemoveZone(zoneName(key))
        end
    end,
}
