-- Targets through ox_target, qb-target or a key prompt; removed when the resource stops.
-- Every kind takes distance and options = { { label, icon, onSelect(entity), canInteract(entity) } }.
local function detect()
    local forced = GetConvar('daddy:target', 'auto')
    if forced ~= 'auto' then return forced end
    if GetResourceState('ox_target') == 'started' then return 'ox' end
    if GetResourceState('qb-target') == 'started' then return 'qb' end
    return 'fallback'
end

local id = detect()
local adapter = DL.require('target/' .. id)
local active = {}

local target = { id = id }

local function add(key, kind, data)
    if active[key] then adapter.remove(key) end
    data.distance = data.distance or 2.5
    adapter.add(key, kind, data)
    active[key] = true
end

-- { coords, size = vec3, heading }
function target.addBox(key, data)
    data.heading = data.heading or 0.0
    add(key, 'box', data)
end

-- { coords, radius }
function target.addSphere(key, data)
    add(key, 'sphere', data)
end

-- { points = { {x, y} }, minZ, maxZ }
function target.addPoly(key, data)
    add(key, 'poly', data)
end

-- A local (client-created) ped or prop.
function target.addEntity(key, entity, data)
    data.entity = entity
    add(key, 'entity', data)
end

-- Every world object of these models (map props too): the options get the object.
function target.addModels(key, data)
    local hashes = {}
    for i, model in ipairs(data.models) do hashes[i] = type(model) == 'number' and model or joaat(model) end
    data.models = hashes
    add(key, 'models', data)
end

-- Every other player: the options get the player's ped.
function target.addPlayers(key, data)
    add(key, 'players', data)
end

function target.remove(key)
    if not active[key] then return end
    adapter.remove(key)
    active[key] = nil
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= DL.resource then return end
    for key in pairs(active) do pcall(adapter.remove, key) end
end)

return target
