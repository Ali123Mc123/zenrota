---@diagnostic disable: deprecated

local config = require 'config.config_c'

---@class CustomEquipmentData
---@field equipmentType string
---@field coords vector3
---@field heading number
---@field locationName string?
---@field instanceName string
---@field inUse boolean
---@field timestamp number

local customEquipment = {}
local gymLocations = {}

---@type table<string, table<string, boolean>>
local resourceLocations = {}

-- Returns false if the calling resource does not have 'prompt' in its name.
-- Internal calls (GetInvokingResource() == nil) are always allowed.
local function isAuthorizedCaller()
    local invoker = GetInvokingResource()
    if invoker and not string.find(invoker, 'prompt') then
        lib.print.warn(string.format("[LIMITED] Unauthorized export call from '%s' - only 'prompt_*' resources may use this API", invoker))
        return false
    end
    return true
end

---@param coords vector3
---@return string? locationName, number distance
local function findNearestLocation(coords)
    local nearestLocation = nil
    local nearestDistance = math.huge

    for locationName, locationData in pairs(config.locations) do
        local distance = #(coords - locationData.coords)
        if distance < nearestDistance then
            nearestDistance = distance
            nearestLocation = locationName
        end
    end

    return nearestLocation, nearestDistance
end

---@param equipmentType string
---@return string
local function generateInstanceName(equipmentType)
    local timestamp = os.time()
    local random = math.random(1000, 9999)
    return string.format("custom_%s_%d_%d", equipmentType, timestamp, random)
end

---@param equipmentType string
---@return table?
local function getEquipmentConfig(equipmentType)
    return config.props[equipmentType]
end

---@deprecated Use CreateGymLocation instead
local function SpawnGymEquipment(equipmentType, coords, heading, locationName, instanceName)
    local invokingResource = GetInvokingResource()

    local equipmentConfig = getEquipmentConfig(equipmentType)
    if not equipmentConfig then
        lib.print.error(string.format("Invalid equipment type: %s", equipmentType))
        return false
    end

    instanceName = instanceName or generateInstanceName(equipmentType)

    if customEquipment[instanceName] then
        lib.print.error(string.format("Equipment instance '%s' already exists", instanceName))
        return false
    end

    if not locationName then
        local nearestLoc, distance = findNearestLocation(coords)
        if nearestLoc and distance < 200.0 then
            locationName = nearestLoc
        else
            locationName = "custom_location"
        end
    end

    customEquipment[instanceName] = {
        equipmentType = equipmentType,
        coords = coords,
        heading = heading,
        locationName = locationName,
        instanceName = instanceName,
        inUse = false,
        timestamp = os.time(),
        _createdBy = invokingResource
    }

    if invokingResource then
        if not resourceLocations[invokingResource] then
            resourceLocations[invokingResource] = {}
        end
        resourceLocations[invokingResource][instanceName] = true
    end

    TriggerClientEvent('gym:syncCustomEquipment', -1, customEquipment)
    return true
end

---@deprecated
local function DespawnGymEquipment(instanceName)
    local equipment = customEquipment[instanceName]
    if not equipment then
        return false, string.format("Equipment instance '%s' not found", instanceName)
    end

    if equipment.inUse then
        return false, string.format("Equipment '%s' is currently in use", instanceName)
    end

    customEquipment[instanceName] = nil
    TriggerClientEvent('gym:syncCustomEquipment', -1, customEquipment)
    return true
end

---@deprecated
local function GetEquipmentTypes()
    local types = {}
    for equipmentType, _ in pairs(config.props) do
        table.insert(types, equipmentType)
    end
    return types
end

---@deprecated
local function IsEquipmentBusy(instanceName)
    local equipment = customEquipment[instanceName]
    if not equipment then return false end
    return equipment.inUse or false
end

---@deprecated
local function GetSpawnedEquipment()
    local response = {}
    for k, v in pairs(customEquipment) do response[k] = v end
    for k, v in pairs(gymLocations) do response[k] = v end
    return response
end

local function SetEquipmentUse(instanceName, inUse)
    if customEquipment[instanceName] then
        customEquipment[instanceName].inUse = inUse
    end
end

local function GetEquipmentData(instanceName)
    return customEquipment[instanceName]
end

-- ──────────────────────────────────────────────────────────────────────────
-- Modern Location API
-- ──────────────────────────────────────────────────────────────────────────

local function AddEquipmentToLocation(locationName, equipmentType, coords)
    local invokingResource = GetInvokingResource()

    if not gymLocations[locationName] then
        lib.print.error(string.format("Location '%s' does not exist", locationName))
        return false, 0
    end

    if not config.props[equipmentType] then
        lib.print.error(string.format("Equipment type '%s' is not defined in config", equipmentType))
        return false, 0
    end

    if not gymLocations[locationName].props then
        gymLocations[locationName].props = {}
    end
    if not gymLocations[locationName].props[equipmentType] then
        gymLocations[locationName].props[equipmentType] = {}
    end

    local coordsList = {}
    if type(coords) == 'table' and coords.x then
        coordsList = {coords}
    elseif type(coords) == 'table' then
        coordsList = coords
    else
        lib.print.error("Invalid coords parameter - must be vector4 or array of vector4")
        return false, 0
    end

    local addedCount = 0
    for _, coord in ipairs(coordsList) do
        local isValid = false
        if type(coord) == 'vector4' then
            table.insert(gymLocations[locationName].props[equipmentType], coord)
            isValid = true
        elseif equipmentType == 'bench' and type(coord) == 'table' and coord.coords and type(coord.coords) == 'vector4' then
            if coord.bar and type(coord.bar) ~= 'vector4' then
                table.insert(gymLocations[locationName].props[equipmentType], coord.coords)
            else
                table.insert(gymLocations[locationName].props[equipmentType], coord)
            end
            isValid = true
        end
        if isValid then addedCount = addedCount + 1 end
    end

    if invokingResource then
        if not resourceLocations[invokingResource] then resourceLocations[invokingResource] = {} end
        resourceLocations[invokingResource][locationName] = true
    end

    TriggerClientEvent('gym:refreshLocation', -1, locationName, gymLocations[locationName])
    return true, addedCount
end

local function RemoveEquipmentFromLocation(locationName, equipmentType, coords, tolerance)
    tolerance = tolerance or 0.1

    if not gymLocations[locationName] then
        lib.print.error(string.format("Location '%s' does not exist", locationName))
        return false, 0
    end

    if not gymLocations[locationName].props or not gymLocations[locationName].props[equipmentType] then
        return false, 0
    end

    local equipmentList = gymLocations[locationName].props[equipmentType]
    local removedCount = 0

    if coords == nil then
        removedCount = #equipmentList
        gymLocations[locationName].props[equipmentType] = {}
    else
        local coordsList = {}
        if type(coords) == 'vector4' or (type(coords) == 'table' and coords.x) then
            coordsList = {coords}
        elseif type(coords) == 'table' then
            coordsList = coords
        else
            return false, 0
        end

        for _, targetCoord in ipairs(coordsList) do
            for i = #equipmentList, 1, -1 do
                local equipment = equipmentList[i]
                local equipCoords = equipment
                if type(equipment) == 'table' and equipment.coords then equipCoords = equipment.coords end
                local targetCoords = targetCoord
                if type(targetCoord) == 'table' and targetCoord.coords then targetCoords = targetCoord.coords end
                local distance = #(vec3(equipCoords.x, equipCoords.y, equipCoords.z) - vec3(targetCoords.x, targetCoords.y, targetCoords.z))
                if distance <= tolerance then
                    table.remove(equipmentList, i)
                    removedCount = removedCount + 1
                    break
                end
            end
        end
    end

    if removedCount > 0 then
        TriggerClientEvent('gym:refreshLocation', -1, locationName, gymLocations[locationName])
        return true, removedCount
    end
    return false, 0
end

local function GetLocationEquipment(locationName)
    if not gymLocations[locationName] then return nil end
    return gymLocations[locationName].props or {}
end

local function GetAllLocations()
    return config.locations
end

local function CreateGymLocation(locationName, data)
    local invokingResource = GetInvokingResource()

    if gymLocations[locationName] then
        return false, "Location already exists"
    end

    if type(data) ~= 'table' or not data.coords then
        return false, "Invalid data: coords required"
    end

    if type(data.coords) ~= 'vector3' then
        return false, "coords must be a vector3"
    end

    if data.props then
        for equipmentType, coordsList in pairs(data.props) do
            if not config.props[equipmentType] then
                return false, string.format("Unknown equipment type: %s", equipmentType)
            end
        end
    end

    gymLocations[locationName] = {
        coords = data.coords,
        renderDistance = data.renderDistance,
        props = data.props or {},
        _createdBy = invokingResource
    }

    if invokingResource then
        if not resourceLocations[invokingResource] then resourceLocations[invokingResource] = {} end
        resourceLocations[invokingResource][locationName] = true
    end

    lib.print.info(string.format("Created gym location '%s' (by %s)", locationName, invokingResource or "internal"))
    TriggerClientEvent('gym:locationCreated', -1, locationName, gymLocations[locationName])
    return true
end

local function RemoveGymLocation(locationName)
    if not gymLocations[locationName] then return false end
    gymLocations[locationName] = nil
    TriggerClientEvent('gym:locationRemoved', -1, locationName)
    return true
end

local function GetAvailableEquipmentTypes()
    local types = {}
    for equipmentType, _ in pairs(config.props) do
        table.insert(types, equipmentType)
    end
    return types
end

-- ──────────────────────────────────────────────────────────────────────────
-- Exports (all gated behind the 'prompt' resource name check)
-- ──────────────────────────────────────────────────────────────────────────

exports('SpawnGymEquipment', function(equipmentType, coords, heading, locationName, instanceName)
    if not isAuthorizedCaller() then return false end
    return SpawnGymEquipment(equipmentType, coords, heading, locationName, instanceName)
end)

exports('DespawnGymEquipment', function(instanceName)
    if not isAuthorizedCaller() then return false end
    return DespawnGymEquipment(instanceName)
end)

exports('GetEquipmentTypes', function()
    if not isAuthorizedCaller() then return {} end
    return GetEquipmentTypes()
end)

exports('IsEquipmentBusy', function(instanceName)
    if not isAuthorizedCaller() then return false end
    return IsEquipmentBusy(instanceName)
end)

exports('GetSpawnedEquipment', function()
    if not isAuthorizedCaller() then return {} end
    return GetSpawnedEquipment()
end)

exports('_SetEquipmentUse', SetEquipmentUse)
exports('_GetEquipmentData', GetEquipmentData)

exports('AddEquipmentToLocation', function(locationName, equipmentType, coords)
    if not isAuthorizedCaller() then return false, 0 end
    return AddEquipmentToLocation(locationName, equipmentType, coords)
end)

exports('RemoveEquipmentFromLocation', function(locationName, equipmentType, coords, tolerance)
    if not isAuthorizedCaller() then return false, 0 end
    return RemoveEquipmentFromLocation(locationName, equipmentType, coords, tolerance)
end)

exports('GetLocationEquipment', function(locationName)
    if not isAuthorizedCaller() then return nil end
    return GetLocationEquipment(locationName)
end)

exports('GetAllLocations', function()
    if not isAuthorizedCaller() then return {} end
    return GetAllLocations()
end)

exports('CreateGymLocation', function(locationName, data)
    if not isAuthorizedCaller() then return false, 'Unauthorized' end
    return CreateGymLocation(locationName, data)
end)

exports('RemoveGymLocation', function(locationName)
    if not isAuthorizedCaller() then return false end
    return RemoveGymLocation(locationName)
end)

exports('GetAvailableEquipmentTypes', function()
    if not isAuthorizedCaller() then return {} end
    return GetAvailableEquipmentTypes()
end)

-- ──────────────────────────────────────────────────────────────────────────
-- Client sync callback (no restriction — called by own clients only)
-- ──────────────────────────────────────────────────────────────────────────

lib.callback.register('gym:getSpawnedEquipment', function(source)
    return {
        deprecated = customEquipment,
        locations = gymLocations
    }
end)

-- ──────────────────────────────────────────────────────────────────────────
-- Cleanup
-- ──────────────────────────────────────────────────────────────────────────

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        customEquipment = {}
        gymLocations = {}
        return
    end

    if resourceLocations[resourceName] then
        for itemName, _ in pairs(resourceLocations[resourceName]) do
            if gymLocations[itemName] and gymLocations[itemName]._createdBy == resourceName then
                gymLocations[itemName] = nil
                TriggerClientEvent('gym:locationRemoved', -1, itemName)
            end
            if customEquipment[itemName] and customEquipment[itemName]._createdBy == resourceName then
                customEquipment[itemName] = nil
            end
        end
        resourceLocations[resourceName] = nil
    end
end)

return {
    SpawnGymEquipment = SpawnGymEquipment,
    DespawnGymEquipment = DespawnGymEquipment,
    GetEquipmentTypes = GetEquipmentTypes,
    IsEquipmentBusy = IsEquipmentBusy,
    GetSpawnedEquipment = GetSpawnedEquipment,
    SetEquipmentUse = SetEquipmentUse,
    GetEquipmentData = GetEquipmentData,
    AddEquipmentToLocation = AddEquipmentToLocation,
    RemoveEquipmentFromLocation = RemoveEquipmentFromLocation,
    GetLocationEquipment = GetLocationEquipment,
    GetAllLocations = GetAllLocations,
    CreateGymLocation = CreateGymLocation,
    RemoveGymLocation = RemoveGymLocation,
    GetAvailableEquipmentTypes = GetAvailableEquipmentTypes,
}
