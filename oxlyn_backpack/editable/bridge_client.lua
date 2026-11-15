-- =============================================================================
-- OPEN SOURCE: Custom Client Inventory Bridge
-- =============================================================================
-- Only active when Config.UseCommunityBridge = false
--
-- The resource auto-detects which inventory is running and fills in
-- GetItemCount automatically. InventoryUpdateEvent is also auto-detected;
-- override Config.InventoryUpdateEvent in config.lua only if needed.
-- =============================================================================

-- ── Auto-detect inventory update event ──────────────────────────────────────
-- Runs before UseCommunityBridge guard so it covers both paths.
-- Only fills in the value when the user left it blank.
if not Config.InventoryUpdateEvent or Config.InventoryUpdateEvent == '' then
    -- Native client events fired by each inventory after item changes.
    -- Inventories marked false fire no reliable native event; the server bridge
    -- fires 'oxlyn_backpack:inventoryUpdated' after add/remove as a fallback.
    local _eventMap = {
        ['tgiann-inventory'] = false,                                       -- no known native event; uses server fallback
        ak47_inventory       = 'qb-inventory:client:updateInventory',       -- mirrors qb-inventory's client event
        origen_inventory     = 'qb-inventory:client:updateInventory',
        ox_inventory         = 'ox_inventory:updateInventory',
        ['codem-inventory']  = false,                                       -- no known native event; uses server fallback
        ['qs-inventory']     = 'inventory:client:UpdatePlayerInventory',
        core_inventory       = false,                                       -- no known native event; uses server fallback
        ['qb-inventory']     = 'qb-inventory:client:updateInventory',
        ['ps-inventory']     = 'inventory:client:UpdatePlayerInventory',
        ['jpr-inventory']    = 'inventory:client:UpdatePlayerInventory',
    }

    -- Always detect based on running inventory resource.
    -- Native inventory events fire on ALL item changes regardless of whether
    -- community_bridge sits in the middleware layer — so we must NOT force
    -- the community_bridge event even when UseCommunityBridge = true.
    -- ak47_inventory sits BEFORE ox_inventory: its ox compat layer can claim
    -- the ox_inventory RESOURCE name while the ox_inventory EXPORT name does
    -- not exist.
    local _order = {
        'tgiann-inventory', 'origen_inventory', 'ak47_inventory', 'ox_inventory',
        'codem-inventory', 'qs-inventory', 'core_inventory',
        'qb-inventory', 'ps-inventory', 'jpr-inventory',
    }
    for _, res in ipairs(_order) do
        if GetResourceState(res) == 'started' then
            local evt = _eventMap[res]
            -- false = no known native event; use server-side fallback
            Config.InventoryUpdateEvent = evt or 'oxlyn_backpack:inventoryUpdated'
            break
        end
    end

    if Config.InventoryUpdateEvent and Config.InventoryUpdateEvent ~= '' then
        DebugPrint(('[Oxlyn Backpack] Auto-detected InventoryUpdateEvent: %s'):format(Config.InventoryUpdateEvent))
    end
end

if Config.UseCommunityBridge then return end

-- ── Auto-detect inventory ────────────────────────────────────────────────────
local detectedInventory = nil
local _candidates = {
    'tgiann-inventory', 'origen_inventory', 'ak47_inventory', 'ox_inventory',
    'codem-inventory', 'qs-inventory', 'core_inventory',
    'qb-inventory', 'ps-inventory', 'jpr-inventory',
}
for _, res in ipairs(_candidates) do
    if GetResourceState(res) == 'started' then
        detectedInventory = res
        break
    end
end

DebugPrint(('[Oxlyn Backpack] Client bridge — detected inventory: %s'):format(detectedInventory or 'NONE (configure manually)'))

-- ── Cached export references ─────────────────────────────────────────────────
local ox     = detectedInventory == 'ox_inventory'        and exports.ox_inventory          or nil
local origen = detectedInventory == 'origen_inventory'    and exports.origen_inventory       or nil
local qs     = detectedInventory == 'qs-inventory'        and exports['qs-inventory']        or nil
-- ak47_inventory answers the qb-shaped client surface, so it shares the handle.
local qb     = (detectedInventory == 'qb-inventory' or detectedInventory == 'ak47_inventory')
               and exports[detectedInventory]                                     or nil
local ps     = detectedInventory == 'ps-inventory'        and exports['ps-inventory']         or nil
local codem  = detectedInventory == 'codem-inventory'     and exports['codem-inventory']     or nil
local tgiann = detectedInventory == 'tgiann-inventory'    and exports['tgiann-inventory']    or nil
local core   = detectedInventory == 'core_inventory'      and exports.core_inventory         or nil
local jpr    = detectedInventory == 'jpr-inventory'       and exports['jpr-inventory']       or nil

-- ── Bridge implementation ─────────────────────────────────────────────────────

local CustomClientBridge = {}

--- Returns how many of `itemName` the local player carries.
function CustomClientBridge.GetItemCount(itemName)

    if ox then
        return ox:GetItemCount(itemName, nil, false) or 0

    elseif origen then
        local result = origen:Search('count', itemName)
        return (result and result.count) or 0

    elseif tgiann then
        return tgiann:GetItemCount(itemName, nil, false) or 0

    elseif codem then
        -- codem exposes GetItemsTotalAmount on client via GetClientPlayerInventory; sum manually
        local inv = codem:GetClientPlayerInventory() or {}
        local count = 0
        for _, v in pairs(inv) do
            if v.name == itemName then count = count + (v.amount or v.count or 1) end
        end
        return count

    elseif qs then
        return qs:Search(itemName) or 0

    elseif core then
        return (core:getItemCount(itemName) or 0)

    elseif qb then
        -- Try GetItemByName for actual count; fall back to HasItem bool.
        local item = qb:GetItemByName(itemName)
        if item then return item.amount or item.count or 1 end
        return 0

    elseif ps then
        local item = ps:GetItemByName(itemName)
        if item then return item.amount or item.count or 1 end
        return 0

    elseif jpr then
        local ok, item = pcall(function() return jpr:GetItemByName(itemName) end)
        if ok and item then return item.amount or item.count or 1 end
        return (jpr:HasItem(itemName, 1) and 1) or 0

    end

    return 0
end

_G.OxlynCustomClientBridge = CustomClientBridge

-- ── Early export stubs ────────────────────────────────────────────────────────
-- Register placeholder exports NOW so ox_inventory (and other resources) can
-- reference them immediately at startup, before client/client.lua loads and
-- registers the real implementations (which overwrite these stubs).
local function _stub() end
exports('openBackpack',       _stub)
exports('openBackpack1',      _stub)
exports('openBackpack2',      _stub)
exports('openBackpack3',      _stub)
exports('searchPlayerBackpack', _stub)
exports('openLockerMenu',     _stub)
exports('openPasscodeReset',  _stub)
