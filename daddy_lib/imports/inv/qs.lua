-- Community supported: verify against your qs-inventory version.
local qs = exports['qs-inventory']

local function inventory(source)
    local items = qs:GetInventory(source)
    return type(items) == 'table' and (items.items or items) or {}
end

return {
    caps = { metadata = true, stash = true, slots = true },

    count = function(source, item) return qs:GetItemTotalAmount(source, item) end,

    registerUsable = function(item, cb)
        qs:CreateUsableItem(item, function(source, data) cb(source, data and data.slot) end)
        return true
    end,

    add = function(source, item, count, metadata) return qs:AddItem(source, item, count, nil, metadata) end,
    remove = function(source, item, count, _, slot) return qs:RemoveItem(source, item, count, slot) end,
    canCarry = function(source, item, count) return qs:CanCarryItem(source, item, count) end,
    items = function(source) return inventory(source) end,
    slot = function(source, slot) return inventory(source)[slot] end,
    setMetadata = function(source, slot, metadata) qs:SetItemMetadata(source, slot, metadata) end,
    definition = function(item) return (qs:GetItemList() or {})[item] end,
    all = function(source) return inventory(source) end,
    image = 'nui://qs-inventory/html/images/%s.png',
}
