-- ox items point at '<resource>.useItem'; one export serves every item. ox consumes an item whose export answers nil,
-- so an item with no handler answers false: the player keeps it and is told (DL.fault.item).
local handlers = {}
local ox = exports.ox_inventory

exports('useItem', function(event, item, inventory, slot)
    if event ~= 'usingItem' then return end
    local handler = handlers[item.name]
    if handler then handler(inventory.id, slot) else DL.fault.item(inventory.id, item.name) end
    return false
end)

return {
    caps = { metadata = true, stash = true, slots = true },

    ready = function(source) return type(source) == 'number' and ox:GetInventory(source) and true or false end,
    count = function(source, item) return ox:Search(source, 'count', item) end,

    registerUsable = function(item, cb)
        handlers[item] = cb
        return true
    end,

    add = function(source, item, count, metadata) return ox:AddItem(source, item, count, metadata) end,
    remove = function(source, item, count, metadata, slot) return ox:RemoveItem(source, item, count, metadata, slot) end,
    canCarry = function(source, item, count, metadata) return ox:CanCarryItem(source, item, count, metadata) end,
    items = function(source, item) return ox:Search(source, 'slots', item) end,
    slot = function(source, slot) return ox:GetSlot(source, slot) end,
    setMetadata = function(source, slot, metadata) ox:SetMetadata(source, slot, metadata) end,
    definition = function(item) return ox:Items(item) end,
    all = function(source) return ox:GetInventoryItems(source) end,

    limits = function(source)
        local inventory = ox:GetInventory(source)
        return inventory and { slots = inventory.slots, weight = inventory.maxWeight }
    end,
    -- ox keeps one stash per player when it is registered with owner = true.
    openStash = function(source, id, opts)
        ox:RegisterStash(id, opts.label or id, opts.slots or 50, opts.weight or 100000, not opts.shared)
        return ox:forceOpenInventory(source, 'stash', id) ~= nil
    end,
    image = 'nui://ox_inventory/web/images/%s.png',

    -- Items that point at an export: { { name, label, resource, export, image } } (image: its picture file exists).
    exported = function()
        local out = {}
        for name, item in pairs(ox:Items() or {}) do
            local export = type(item.server) == 'table' and item.server.export
            local resource, fn = tostring(export or ''):match('^([^.]+)%.(.+)$')
            if resource then
                out[#out + 1] = { name = name, label = item.label, resource = resource, export = fn,
                    image = LoadResourceFile('ox_inventory', ('web/images/%s.png'):format(name)) ~= nil }
            end
        end
        return out
    end,
}
