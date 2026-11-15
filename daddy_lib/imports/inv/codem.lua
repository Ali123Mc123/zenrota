-- Community supported: verify against your codem-inventory version.
local ci = exports['codem-inventory']

local function inventory(source)
    local items = ci:GetInventory(nil, source)
    return type(items) == 'table' and items or {}
end

return {
    caps = { metadata = true, stash = true, slots = true },

    count = function(source, item)
        local found = ci:GetItemByName(source, item)
        return found and (found.amount or found.count) or 0
    end,

    registerUsable = function(item, cb) return DL.fw.registerUsable(item, cb) end,

    add = function(source, item, count, metadata) return ci:AddItem(source, item, count, nil, metadata) end,
    remove = function(source, item, count, _, slot) return ci:RemoveItem(source, item, count, slot) end,
    canCarry = function() return true end,
    items = function(source) return inventory(source) end,
    slot = function(source, slot) return ci:GetItemBySlot(source, slot) end,
    setMetadata = function(source, slot, metadata) ci:SetItemMetadata(source, slot, metadata) end,
    definition = function(item) return (ci:GetItemList() or {})[item] end,
    all = function(source) return inventory(source) end,
    image = 'nui://codem-inventory/html/itemimages/%s.png',
}
