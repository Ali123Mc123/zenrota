-- Community supported: verify against your core_inventory version.
local ci = exports.core_inventory

return {
    caps = { metadata = true, stash = true, slots = false },

    count = function(source, item) return ci:getItemCount(source, item) end,

    registerUsable = function(item, cb) return DL.fw.registerUsable(item, cb) end,

    add = function(source, item, count, metadata) return ci:addItem(source, item, count, metadata) end,
    remove = function(source, item, count, metadata) return ci:removeItem(source, item, count, metadata) end,
    canCarry = function(source, item, count) return ci:canCarry(source, item, count) end,
    items = function(source) return ci:getInventory(source) end,
    slot = function() return nil end,
    setMetadata = function(source, slot, metadata) ci:updateMetadata(source, slot, metadata) end,
    definition = function(item) return (ci:getItemsList() or {})[item] end,
    all = function(source) return ci:getInventory(source) end,
    image = 'nui://core_inventory/html/img/%s.png',
}
