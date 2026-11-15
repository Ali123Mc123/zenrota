RegisterNetEvent('ak4y-C:codem-inventory:openStash', function(stashId, weight, slots, label)
    if GetResourceState('codem-inventory') ~= 'started' then return end

    local data = { label = label or stashId, maxweight = weight, slots = slots }
    exports['codem-inventory']:OpenInventory('stash', stashId, data)
end)
