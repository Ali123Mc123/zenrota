AddEventHandler('ox_target:debug', function(data)
    if data.entity and GetEntityType(data.entity) > 0 then
        data.archetype = GetEntityArchetypeName(data.entity)
        data.model = GetEntityModel(data.entity)
    end

    print(json.encode(data, { indent = true }))
end)

if GetConvarInt('ox_target:debug', 0) ~= 1 then return end
