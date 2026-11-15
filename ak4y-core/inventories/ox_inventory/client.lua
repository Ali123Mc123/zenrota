RegisterNetEvent('ak4y-C:ox_inventory:openStash', function(stashId)
    if GetResourceState('ox_inventory') ~= 'started' then return end

    exports.ox_inventory:openInventory('stash', stashId)
end)
