-- Krypton Farming - Framework Bridge
-- Otomatik framework tespiti ve birleşik API

Krypton = Krypton or {}
Krypton.Framework = {}
Krypton.Inventory = {}

-- Framework Tespiti
local function DetectFramework()
    if Config.Framework ~= 'auto' then
        return Config.Framework
    end
    
    if GetResourceState('qbx_core') == 'started' then
        return 'qbx'
    elseif GetResourceState('qb-core') == 'started' then
        return 'qb'
    elseif GetResourceState('es_extended') == 'started' then
        return 'esx'
    end
    return nil
end

Krypton.FrameworkType = DetectFramework()

-- Framework Objesi
if Krypton.FrameworkType == 'qbx' then
    Krypton.Framework.Object = exports['qbx_core']
elseif Krypton.FrameworkType == 'qb' then
    Krypton.Framework.Object = exports['qb-core']:GetCoreObject()
elseif Krypton.FrameworkType == 'esx' then
    Krypton.Framework.Object = exports['es_extended']:getSharedObject()
end

-- Inventory Sistemi Tespiti
local function DetectInventory()
    if GetResourceState('ox_inventory') == 'started' then
        return 'ox'
    elseif GetResourceState('qb-inventory') == 'started' then
        return 'qb'
    elseif GetResourceState('qs-inventory') == 'started' then
        return 'qs'
    end
    return 'default'
end

Krypton.InventoryType = DetectInventory()
