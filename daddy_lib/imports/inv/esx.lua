-- ESX default inventory: no metadata, no slots.
local function esx() return exports.es_extended:getSharedObject() end
local function player(source) return esx().GetPlayerFromId(source) end

local function held(source, item)
    local p = player(source)
    local found = p and p.getInventoryItem(item)
    return p, found and found.count or 0
end

return {
    caps = { metadata = false, stash = false, slots = false },

    count = function(source, item)
        local _, count = held(source, item)
        return count
    end,

    registerUsable = function(item, cb) return DL.fw.registerUsable(item, cb) end,

    add = function(source, item, count)
        local p = player(source)
        if not p then return false end
        p.addInventoryItem(item, count)
        return true
    end,

    remove = function(source, item, count)
        local p, have = held(source, item)
        if not p or have < count then return false end
        p.removeInventoryItem(item, count)
        return true
    end,

    canCarry = function(source, item, count)
        local p = player(source)
        return p ~= nil and p.canCarryItem(item, count)
    end,

    items = function(source, item)
        local _, count = held(source, item)
        return count > 0 and { { name = item, count = count } } or {}
    end,

    slot = function() return nil end,
    setMetadata = function() end,
    definition = function(item)
        local label = esx().GetItemLabel(item)
        return label and { label = label } or nil
    end,

    all = function(source)
        local p = player(source)
        local out = {}
        for _, item in ipairs(p and p.getInventory() or {}) do
            if (item.count or 0) > 0 then out[#out + 1] = { name = item.name, count = item.count } end
        end
        return out
    end,
}
