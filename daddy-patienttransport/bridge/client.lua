local QBCore, ESX

local function qbCore()
    QBCore = QBCore or exports['qb-core']:GetCoreObject()
    return QBCore
end

local function esx()
    ESX = ESX or exports.es_extended:getSharedObject()
    return ESX
end

local function playerData()
    local framework = Bridge.Framework()
    if framework == 'qbx' then return exports.qbx_core:GetPlayerData() end
    if framework == 'qb' then return qbCore().Functions.GetPlayerData() end
    if framework == 'esx' then return esx().GetPlayerData() end
end

-- { name = 'ambulance', onDuty = true } or nil
-- Target options ask for the job every tick; the framework export is only read once a second.
local jobCache, jobCacheAt = nil, -1
function Bridge.GetJob()
    local current = GetGameTimer()
    if jobCacheAt >= 0 and current - jobCacheAt < 1000 then return jobCache end
    jobCache, jobCacheAt = Bridge.ReadJob(), current
    return jobCache
end

function Bridge.ReadJob()
    local data = playerData()
    local job = data and data.job
    if not job then return nil end
    if Bridge.Framework() == 'esx' then return { name = job.name, onDuty = true } end
    return { name = job.name, onDuty = job.onduty == true }
end

function Bridge.IsSelfDowned()
    if Config.IsDowned then return Config.IsDowned() == true end

    local framework = Bridge.Framework()
    if framework == 'qbx' and Bridge.Started('qbx_medical') then
        local ok, downed = pcall(function()
            return exports.qbx_medical:IsDead() or exports.qbx_medical:IsLaststand()
        end)
        return ok and downed == true
    elseif framework == 'qb' then
        local data = playerData()
        local meta = data and data.metadata
        return meta ~= nil and (meta.isdead == true or meta.inlaststand == true)
    end
    return IsEntityDead(cache.ped)
end

-- Qbox keeps downed players in a death animation; hand them back to it after moving them.
function Bridge.PlayDownedAnim()
    if not Bridge.IsSelfDowned() then return false end
    if Bridge.Framework() == 'qbx' and Bridge.Started('qbx_medical') then
        pcall(function() exports.qbx_medical:PlayDeadAnimation() end)
    end
    return true
end

local fuelResources = { 'ox_fuel', 'LegacyFuel', 'cdn-fuel', 'ps-fuel', 'lj-fuel', 'savana-fuel' }

function Bridge.SetFuel(vehicle, amount)
    SetVehicleFuelLevel(vehicle, amount)
    if Bridge.Started('ox_fuel') and NetworkGetEntityOwner(vehicle) == PlayerId() then
        Entity(vehicle).state:set('fuel', amount, true)
    end
    for i = 1, #fuelResources do
        local resource = fuelResources[i]
        if resource ~= 'ox_fuel' and Bridge.Started(resource) then
            pcall(function() exports[resource]:SetFuel(vehicle, amount) end)
        end
    end
end

-- Keeps a replicated flag of our own downed state so the server can read it on every framework.
CreateThread(function()
    local last
    while true do
        local downed = Bridge.IsSelfDowned()
        if downed ~= last then
            last = downed
            LocalPlayer.state:set(Bridge.DownedStateKey, downed, true)
        end
        Wait(1000)
    end
end)

-- Target: ox_target when started, otherwise qb-target. Options use the ox_target shape.
local function useOx()
    return Bridge.Started('ox_target')
end

local function toQb(options)
    local converted, maxDistance = {}, 0
    for i = 1, #options do
        local option = options[i]
        local distance = option.distance or 2.0
        if distance > maxDistance then maxDistance = distance end
        converted[i] = {
            icon = option.icon,
            label = option.label,
            action = function(entity) option.onSelect({ entity = entity }) end,
            canInteract = function(entity)
                if not entity or entity == 0 or not DoesEntityExist(entity) then return false end
                if #(GetEntityCoords(cache.ped) - GetEntityCoords(entity)) > distance then return false end
                return not option.canInteract or option.canInteract(entity)
            end,
        }
    end
    return { options = converted, distance = maxDistance }
end

function Bridge.AddModelTarget(models, options)
    if useOx() then return exports.ox_target:addModel(models, options) end
    exports['qb-target']:AddTargetModel(type(models) == 'table' and models or { models }, toQb(options))
end

function Bridge.AddGlobalPedTarget(options)
    if useOx() then return exports.ox_target:addGlobalPed(options) end
    exports['qb-target']:AddGlobalPed(toQb(options))
end

function Bridge.AddGlobalPlayerTarget(options)
    if useOx() then return exports.ox_target:addGlobalPlayer(options) end
    exports['qb-target']:AddGlobalPlayer(toQb(options))
end

function Bridge.AddGlobalVehicleTarget(options)
    if useOx() then return exports.ox_target:addGlobalVehicle(options) end
    exports['qb-target']:AddGlobalVehicle(toQb(options))
end
