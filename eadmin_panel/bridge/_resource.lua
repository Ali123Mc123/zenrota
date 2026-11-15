--[[
    Framework & Resource Auto-Detection

    This file runs first (shared_scripts) and sets global variables used by
    all bridge, client, and server scripts. Users adapting to a different
    framework should update the detection logic here.

    All detection happens once at startup. Bridge functions use the cached
    globals instead of calling GetResourceState() on every invocation.

    Provides:
      Bridge.RESOURCE_NAME  - resource name string
      Bridge.EVENT_PREFIX   - resource name + ':'
      Bridge.getQBCore()    - lazy singleton for QBCore shared object
      Bridge.getESX()       - lazy singleton for ESX shared object
      Bridge.getPlayerData()- framework-agnostic local player data (client)
]]

Bridge = Bridge or {}

--- @type string  Resource name, cached once
Bridge.RESOURCE_NAME = GetCurrentResourceName()

--- @type string  Event prefix for all net events
Bridge.EVENT_PREFIX = Bridge.RESOURCE_NAME .. ':'

--- @type 'qbx'|'qb'|'esx'|'ox'|nil
Framework = nil

--- @type string|nil  Detected fuel resource name
FuelResource = nil

--- @type string|nil  Detected clothing resource name
ClothingResource = nil

--- @type string|nil  Detected weather sync resource
WeatherResource = nil

--- @type string|nil  Detected ambulance / medical resource
AmbulanceResource = nil

--- @type string|nil  Detected police job resource
PoliceResource = nil

--- @type string|nil  Detected inventory resource name
InventoryResource = nil

--- @type string|nil  Detected vehicle keys resource name
VehicleKeysResource = nil

--- @type string|nil  Detected garage resource name
GarageResource = nil

--- @type string|nil  Detected advanced parking resource name
ParkingResource = nil

if GetResourceState('qbx_core') == 'started' then
    Framework = 'qbx'
elseif GetResourceState('qb-core') == 'started' then
    Framework = 'qb'
elseif GetResourceState('es_extended') == 'started' then
    Framework = 'esx'
elseif GetResourceState('ox_core') == 'started' then
    Framework = 'ox'
end

-- Config.mode override: 'standalone' forces standalone regardless of detected framework
if type(Config) == 'table' and Config.mode == 'standalone' then
    Framework = nil
end

--- @type boolean  true when no supported framework is detected or mode forced to standalone
Bridge.isStandalone = (Framework == nil)

-- =========================================================================
-- Framework Shared Objects (lazy-loaded singletons)
--
-- Resolved once on first call, cached for all subsequent uses.
-- Safe to call from both client and server - pcall guards export failures.
-- =========================================================================

--- @type table|nil
local QBCoreObject = nil

--- Get the QBCore shared object (QB only). Lazy singleton.
---@return table|nil
function Bridge.getQBCore()
    if QBCoreObject == nil and Framework == 'qb' then
        local ok, obj = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if ok then QBCoreObject = obj end
    end
    return QBCoreObject
end

--- @type table|nil
local ESXSharedObject = nil

--- Get the ESX shared object (ESX only). Lazy singleton.
---@return table|nil
function Bridge.getESX()
    if ESXSharedObject == nil and Framework == 'esx' then
        local ok, obj = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok then ESXSharedObject = obj end
    end
    return ESXSharedObject
end

--- Get framework player data (client-side).
--- QBX: exports.qbx_core:GetPlayerData()
--- QB:  QBCore.Functions.GetPlayerData()
--- ESX: ESX.GetPlayerData()
---@return table|nil
function Bridge.getPlayerData()
    if Framework == 'qbx' then
        local ok, pd = pcall(function() return exports.qbx_core:GetPlayerData() end)
        return ok and pd or nil
    elseif Framework == 'qb' then
        local QBCore = Bridge.getQBCore()
        return QBCore and QBCore.Functions.GetPlayerData() or nil
    elseif Framework == 'esx' then
        local ESX = Bridge.getESX()
        return ESX and ESX.GetPlayerData() or nil
    end
    return nil
end

-- =========================================================================
-- Resource Auto-Detection (table-driven)
--
-- Single definition table drives detection, debug logging, and warnings.
-- To add a new resource type: add a global declaration above, then append
-- an entry here. No other code changes needed.
-- =========================================================================

---@class ResourceDef
---@field var string       Global variable name to set
---@field key string       Short key for log summary
---@field scripts string[] Candidate resource names (first match wins)

---@type ResourceDef[]
local resourceDefs = {
    { var = 'FuelResource',        key = 'fuel',      scripts = { 'savana-fuel', 'cdn-fuel', 'LegacyFuel', 'lj-fuel', 'ox_fuel', 'ps-fuel', 'okokGasStation', 'x-fuel', 'nd_fuel', 'lc_fuel', 'gacha_fuel' } },
    { var = 'ClothingResource',    key = 'clothing',  scripts = { 'illenium-appearance', 'qb-clothing', 'fivem-appearance', 'esx_skin', 'ox_appearance', 'bl_appearance' } },
    { var = 'WeatherResource',     key = 'weather',   scripts = { 'qb-weathersync', 'Renewed-Weathersync', 'weathersync', 'cd_easytime', 'av_weather' } },
    { var = 'AmbulanceResource',   key = 'ambulance', scripts = { 'wasabi_ambulance_v2', 'wasabi_ambulance', 'randol_medical', 'qbx_medical', 'qb-ambulancejob', 'esx_ambulancejob', 'osp_ambulance', 'ak47_qb_ambulancejob', 'ak47_ambulancejob', 'p_ambulancejob', 'tk_ambulancejob' } },
    { var = 'PoliceResource',      key = 'police',    scripts = { 'qbx_police', 'qb-policejob', 'qbx_policejob', 'p_policejob', 'tk_policejob', 'rcore_police' } },
    { var = 'InventoryResource',   key = 'inventory', scripts = { 'ox_inventory', 'qb-inventory', 'qs-inventory', 'ps-inventory', 'origen_inventory', 'codem-inventory', 'core_inventory', 'tgiann-inventory', 'jaksam_inventory', 'ak47_inventory' } },
    { var = 'GarageResource',      key = 'garage',    scripts = { 'cd_garage', 'jg-advancedgarages', 'qs-advancedgarages', 'loaf_garage' } },
    { var = 'VehicleKeysResource', key = 'keys',      scripts = { 'wais-vehiclekey', 'qbx_vehiclekeys', 'qb-vehiclekeys', 'Renewed-Vehiclekeys', 'MrNewbVehicleKeys', 'qs-vehiclekeys', 'cd_garage', 'vehicles_keys' } },
    -- 'parking' tespiti cikarildi: ParkingResource bu resource'un hicbir
    -- yerinde tuketilmiyor (impl haritasi yok) ve sunucuda park scripti de
    -- kurulu degil. Tespit edilse bile bir ise yaramadigi icin yalniz kalici
    -- bir uyari uretiyordu. Park destegi eklenirse buraya geri konmali.
}

-- Detect first matching started resource for each category
for _, def in ipairs(resourceDefs) do
    for _, name in ipairs(def.scripts) do
        if GetResourceState(name) == 'started' then
            _G[def.var] = name
            break
        end
    end
end

-- Build debug summary + collect missing categories
local detected, missing = {}, {}
for _, def in ipairs(resourceDefs) do
    local name = _G[def.var]
    if name then
        detected[#detected + 1] = def.key .. '=' .. name
    else
        missing[#missing + 1] = def.key
    end
end

local modeLabel = Framework or 'standalone'
if type(Config) == 'table' and Config.mode == 'standalone' then
    modeLabel = 'standalone (forced via Config.mode)'
end

Log.debug('Framework: %s | %s', modeLabel,
    #detected > 0 and table.concat(detected, ', ') or 'no resources detected')

-- Warnings for missing dependencies
if not Framework and not (type(Config) == 'table' and Config.mode == 'standalone') then
    Log.warn('No supported framework detected')
end
if #missing > 0 then
    Log.warn('Not detected: %s', table.concat(missing, ', '))
end

Log.debug('Initialized')
