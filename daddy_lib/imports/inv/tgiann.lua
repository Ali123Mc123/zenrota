-- Community supported: verify against your tgiann-inventory version (ox-like exports).
local tg = exports['tgiann-inventory']

return {
    caps = { metadata = true, stash = true, slots = true },

    count = function(source, item) return tg:Search(source, 'count', item) end,

    registerUsable = function(item, cb)
        tg:CreateUsableItem(item, function(source, data) cb(source, data and data.slot) end)
        return true
    end,

    add = function(source, item, count, metadata) return tg:AddItem(source, item, count, nil, metadata) end,
    remove = function(source, item, count, metadata, slot) return tg:RemoveItem(source, item, count, metadata, slot) end,
    canCarry = function(source, item, count, metadata) return tg:CanCarryItem(source, item, count, metadata) end,
    items = function(source, item) return tg:Search(source, 'slots', item) end,
    slot = function(source, slot) return tg:GetSlot(source, slot) end,
    setMetadata = function(source, slot, metadata) tg:SetMetadata(source, slot, metadata) end,
    definition = function(item) return tg:Items(item) end,
    all = function(source) return tg:GetInventoryItems(source) end,
    image = 'nui://inventory_images/images/%s.webp',
}
