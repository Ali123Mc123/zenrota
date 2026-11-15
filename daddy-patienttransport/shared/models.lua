EmsModels = {}

function EmsModels.Hashes(defaultModel, models)
    local hashes = { [joaat(defaultModel)] = true }
    for _, name in ipairs(models or {}) do hashes[joaat(name)] = true end
    return hashes
end

-- Scan all supported colors; a nearby unrelated vehicle must not hide them.
function EmsModels.Closest(hashes, distance)
    local origin = GetEntityCoords(cache.ped)
    local closest
    for _, entity in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(entity) and hashes[GetEntityModel(entity)] then
            local delta = #(GetEntityCoords(entity) - origin)
            if delta <= distance then closest, distance = entity, delta end
        end
    end
    return closest
end
