-- Inventory from the daddy:inventory convar, or whichever is running.
local ORDER = {
    { id = 'ox', resource = 'ox_inventory' },
    { id = 'qb', resource = 'qb-inventory' },
    { id = 'qs', resource = 'qs-inventory' },
    { id = 'codem', resource = 'codem-inventory' },
    { id = 'core', resource = 'core_inventory' },
    { id = 'tgiann', resource = 'tgiann-inventory' },
}

local function detect()
    local forced = GetConvar('daddy:inventory', 'auto')
    if forced ~= 'auto' then return forced end
    for _, inv in ipairs(ORDER) do
        if GetResourceState(inv.resource) == 'started' then return inv.id end
    end
    return DL.fw.id == 'esx' and 'esx' or 'none'
end

local id = detect()
local adapter = DL.require('inv/' .. id)

local inv = { id = id, caps = adapter.caps }

-- One stack in a common shape: { slot, name, count, metadata }.
local function stack(item, slot)
    if type(item) ~= 'table' or not item.name then return nil end
    local metadata = item.metadata or item.info
    return { slot = item.slot or slot, name = item.name, count = tonumber(item.count or item.amount) or 1, metadata = type(metadata) == 'table' and metadata or {} }
end

-- Whether the player's inventory has loaded and can take items (true for inventories that cannot tell).
function inv.ready(source)
    return not adapter.ready or adapter.ready(source) == true
end

function inv.count(source, item)
    return tonumber(adapter.count(source, item)) or 0
end

function inv.has(source, item, amount)
    return inv.count(source, item) >= (amount or 1)
end

-- Usable items this resource registered, for `daddy check`.
inv.usable = {}

-- cb(source, slot) runs when a player uses the item; a cb that throws is stored and the player is told its code.
function inv.registerUsable(item, cb)
    inv.usable[#inv.usable + 1] = item
    exports.daddy_lib:usable(item)
    local function guarded(source, slot)
        local ok, code = DL.fault.call('item.' .. item, source, { slot = slot }, cb, source, slot)
        if not ok then DL.fault.tell(source, DL.fault.text(code)) end
    end
    if not adapter.registerUsable(item, guarded) then
        print(('^3[%s] %s cannot register usable item %s^7'):format(DL.resource, id, item))
    end
end

function inv.add(source, item, count, metadata)
    return adapter.add(source, item, count or 1, metadata) and true or false
end

-- metadata and slot pick one stack where the inventory supports it.
function inv.remove(source, item, count, metadata, slot)
    return adapter.remove(source, item, count or 1, metadata, slot) and true or false
end

function inv.canCarry(source, item, count, metadata)
    return adapter.canCarry(source, item, count or 1, metadata) ~= false
end

-- Every stack of an item the player holds.
function inv.items(source, item)
    local out = {}
    for key, raw in pairs(adapter.items(source, item) or {}) do
        local found = stack(raw, key)
        if found and found.name == item then out[#out + 1] = found end
    end
    return out
end

function inv.slot(source, slot)
    return stack(adapter.slot(source, slot), slot)
end

function inv.setMetadata(source, slot, metadata)
    adapter.setMetadata(source, slot, metadata)
end

-- The item's registered definition ({ label, weight, ... }), or nil.
function inv.definition(item)
    return adapter.definition(item)
end

-- Every stack the player holds, by slot.
function inv.all(source)
    local out = {}
    for key, raw in pairs(adapter.all(source) or {}) do
        local found = stack(raw, tonumber(key))
        if found then out[#out + 1] = found end
    end
    table.sort(out, function(a, b) return (a.slot or 0) < (b.slot or 0) end)
    return out
end

-- Items that point at a resource's export, for health checks: { { name, label, resource, export, image } }, or nil
-- when the inventory cannot tell.
function inv.exported()
    return adapter.exported and adapter.exported() or nil
end

-- How many slots and grams the player's inventory holds, or nil when the inventory cannot tell.
function inv.limits(source)
    local found = adapter.limits and adapter.limits(source)
    if type(found) ~= 'table' then return nil end
    return { slots = tonumber(found.slots), weight = tonumber(found.weight) }
end

-- The item's picture for a UI, or nil. The convar daddy:item_images ('nui://.../%s.png') overrides the inventory's.
function inv.image(item)
    local pattern = GetConvar('daddy:item_images', '')
    if pattern == '' then pattern = adapter.image or '' end
    return pattern ~= '' and pattern:format(item) or nil
end


-- Opens the player's own stash (one per character) from the server; false where the inventory has none.
-- opts = { label, slots, weight, shared }; shared: one stash for everyone instead of one per character.
function inv.openStash(source, id, opts)
    if not adapter.openStash then return false end
    return adapter.openStash(source, id, opts or {}) ~= false
end

return inv
