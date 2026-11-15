-- qb-inventory keeps metadata in 'info'; the lib reads both.
local qb = exports['qb-inventory']

return {
    caps = { metadata = true, stash = true, slots = true },

    count = function(source, item) return qb:GetItemCount(source, item) end,

    registerUsable = function(item, cb) return DL.fw.registerUsable(item, cb) end,

    add = function(source, item, count, metadata) return qb:AddItem(source, item, count, false, metadata, DL.resource) end,
    remove = function(source, item, count, _, slot) return qb:RemoveItem(source, item, count, slot, DL.resource) end,
    canCarry = function(source, item, count) return qb:CanAddItem(source, item, count) end,
    items = function(source, item) return qb:GetItemsByName(source, item) end,
    slot = function(source, slot) return qb:GetItemBySlot(source, slot) end,

    setMetadata = function(source, slot, metadata)
        local item = qb:GetItemBySlot(source, slot)
        if item then qb:SetItemData(source, item.name, 'info', metadata, slot) end
    end,

    definition = function(item)
        local core = exports['qb-core']:GetCoreObject()
        return core and core.Shared.Items[item]
    end,

    -- qb-inventory (2.x) opens a stash by name; the citizen id makes it the player's own.
    openStash = function(source, id, opts)
        local cid = DL.fw.citizenId(source)
        if not cid then return false end
        qb:OpenInventory(source, opts.shared and id or id .. '_' .. cid, { label = opts.label, slots = opts.slots, maxweight = opts.weight })
        return true
    end,

    limits = function()
        local player = exports['qb-core']:GetCoreObject().Config.Player
        return player and { slots = player.MaxInvSlots, weight = player.MaxWeight }
    end,

    all = function(source)
        local player = exports['qb-core']:GetCoreObject().Functions.GetPlayer(source)
        return player and player.PlayerData.items or {}
    end,
    image = 'nui://qb-inventory/html/images/%s.png',
}
