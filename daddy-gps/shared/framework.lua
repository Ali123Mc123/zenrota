-- ============================================================================
-- FRAMEWORK BRIDGE (QB / QBOX / ESX)
-- ============================================================================
-- Auto-detects framework and provides a unified API
-- ============================================================================

Framework = {}
local fwType = nil
local Obj = nil

-- Detect Framework
if GetResourceState('qbx_core') == 'started' then
    fwType = 'qbox'
    Obj = exports['qbx_core']
elseif GetResourceState('qb-core') == 'started' then
    fwType = 'qb'
    Obj = exports['qb-core']:GetCoreObject()
elseif GetResourceState('es_extended') == 'started' then
    fwType = 'esx'
    Obj = exports['es_extended']:getSharedObject()
end


-- Detect Inventory
local invType = nil
if GetResourceState('ox_inventory') == 'started' then
    invType = 'ox'
elseif GetResourceState('qs-inventory') == 'started' then
    invType = 'qs'
elseif GetResourceState('ps-inventory') == 'started' then
    invType = 'ps'
elseif GetResourceState('lj-inventory') == 'started' then
    invType = 'lj'
elseif GetResourceState('qb-inventory') == 'started' then
    invType = 'qb'
elseif GetResourceState('core_inventory') == 'started' then
    invType = 'core'
end


-- ============================================================================
-- SHARED FUNCTIONS
-- ============================================================================

function Framework.HasItem(src, item)
    -- Handle Client/Server difference for src
    local isServer = IsDuplicityVersion()
    local playerSrc = isServer and src or nil
    local itemName = item or src -- If client, first arg is item

    if not isServer then
        -- CLIENT SIDE
        if invType == 'ox' then
            return exports.ox_inventory:Search('count', itemName) > 0
        elseif fwType == 'qbox' then
            local p = exports.qbx_core:GetPlayerData()
            if not p or not p.items then return false end
            for _, v in pairs(p.items) do
                if v.name == itemName then return true end
            end
            return false
        elseif fwType == 'qb' then
            local p = Obj.Functions.GetPlayerData()
            if not p or not p.items then return false end
            for _, v in pairs(p.items) do
                if v.name == itemName then return true end
            end
            return false
        elseif fwType == 'esx' then
            local p = Obj.GetPlayerData()
            if not p or not p.inventory then return false end
            for _, v in ipairs(p.inventory) do
                if v.name == itemName and v.count > 0 then return true end
            end
            return false
        end
    else
        -- SERVER SIDE
        if invType == 'ox' then
            return exports.ox_inventory:Search(playerSrc, 'count', itemName) > 0
        elseif fwType == 'qbox' then
            local Player = exports.qbx_core:GetPlayer(playerSrc)
            if not Player then return false end
            if Player.Functions and Player.Functions.GetItemByName then
                return Player.Functions.GetItemByName(itemName) ~= nil
            end
            if Player.PlayerData and Player.PlayerData.items then
                for _, v in pairs(Player.PlayerData.items) do
                    if v and v.name == itemName then return true end
                end
            end
            return false
        elseif fwType == 'qb' then
            local Player = Obj.Functions.GetPlayer(playerSrc)
            return Player and Player.Functions.GetItemByName(itemName) ~= nil
        elseif fwType == 'esx' then
            local xPlayer = Obj.GetPlayerFromId(playerSrc)
            if not xPlayer then return false end
            local invItem = xPlayer.getInventoryItem(itemName)
            return invItem and invItem.count > 0
        end
    end
    
    return true -- Default allow if no inventory detected
end

function Framework.GetJob(src)
    if not fwType then return nil end
    
    if IsDuplicityVersion() then -- SERVER
        if fwType == 'qbox' then
            local Player = exports.qbx_core:GetPlayer(src)
            return Player and Player.PlayerData.job or nil
        elseif fwType == 'qb' then
            local Player = Obj.Functions.GetPlayer(src)
            return Player and Player.PlayerData.job or nil
        elseif fwType == 'esx' then
            local xPlayer = Obj.GetPlayerFromId(src)
            return xPlayer and xPlayer.job or nil
        end
    else -- CLIENT
        if fwType == 'qbox' then
            local p = exports.qbx_core:GetPlayerData()
            return p and p.job or nil
        elseif fwType == 'qb' then
            local p = Obj.Functions.GetPlayerData()
            return p and p.job or nil
        elseif fwType == 'esx' then
            return Obj.GetPlayerData().job or nil
        end
    end
    return nil
end

function Framework.Notify(src, msg, notifyType)
    -- Check for ox_lib first
    if GetResourceState('ox_lib') == 'started' then
        if IsDuplicityVersion() then -- SERVER
            TriggerClientEvent('ox_lib:notify', src, { description = msg, type = notifyType or 'info' })
        else -- CLIENT
            exports.ox_lib:notify({ description = msg, type = notifyType or 'info' })
        end
        return
    end

    if IsDuplicityVersion() then -- SERVER
        if fwType == 'qbox' or fwType == 'qb' then
            TriggerClientEvent('QBCore:Notify', src, msg, notifyType)
        elseif fwType == 'esx' then
            TriggerClientEvent('esx:showNotification', src, msg)
        end
    else -- CLIENT
        if fwType == 'qbox' then
            exports.qbx_core:Notify(msg, notifyType or 'info')
        elseif fwType == 'qb' then
            Obj.Functions.Notify(msg, notifyType)
        elseif fwType == 'esx' then
            Obj.ShowNotification(msg)
        end
    end
end

-- ============================================================================
-- CLIENT FUNCTIONS
-- ============================================================================

if not IsDuplicityVersion() then
    function Framework.TriggerCallback(name, cb, ...)
        if fwType == 'qbox' then
            local args = { ... }
            CreateThread(function()
                local result = lib.callback.await(name, false, table.unpack(args))
                cb(result)
            end)
        elseif fwType == 'qb' then
            Obj.Functions.TriggerCallback(name, cb, ...)
        elseif fwType == 'esx' then
            Obj.TriggerServerCallback(name, cb, ...)
        end
    end
    
    -- ESX Job Update Listener
    if fwType == 'esx' then
        RegisterNetEvent('esx:setJob', function(job)
            -- You can trigger a local event here if needed
        end)
    end
end

-- ============================================================================
-- SERVER FUNCTIONS
-- ============================================================================

if IsDuplicityVersion() then
    function Framework.RegisterCallback(name, cb)
        if fwType == 'qbox' then
            lib.callback.register(name, function(source, ...)
                return cb(source, ...)
            end)
        elseif fwType == 'qb' then
            Obj.Functions.CreateCallback(name, function(source, cbFunc, ...)
                cbFunc(cb(source, ...))
            end)
        elseif fwType == 'esx' then
            Obj.RegisterServerCallback(name, function(source, cbFunc, ...)
                cbFunc(cb(source, ...))
            end)
        end
    end

    function Framework.RegisterUsableItem(name, cb)
        if fwType == 'qbox' then
            exports.qbx_core:CreateUseableItem(name, cb)
        elseif fwType == 'qb' then
            Obj.Functions.CreateUseableItem(name, cb)
        elseif fwType == 'esx' then
            Obj.RegisterUsableItem(name, cb)
        end
    end

    function Framework.GetIdentifier(src)
        if fwType == 'qbox' then
            local Player = exports.qbx_core:GetPlayer(src)
            return Player and Player.PlayerData.citizenid or nil
        elseif fwType == 'qb' then
            local Player = Obj.Functions.GetPlayer(src)
            return Player and Player.PlayerData.citizenid or nil
        elseif fwType == 'esx' then
            local xPlayer = Obj.GetPlayerFromId(src)
            return xPlayer and xPlayer.identifier or nil
        end
    end

    function Framework.GetPlayerName(src)
        if fwType == 'qbox' then
            local Player = exports.qbx_core:GetPlayer(src)
            if not Player then return 'Unknown', 'Unknown' end
            return Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname
        elseif fwType == 'qb' then
            local Player = Obj.Functions.GetPlayer(src)
            if not Player then return 'Unknown', 'Unknown' end
            return Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname
        elseif fwType == 'esx' then
            local xPlayer = Obj.GetPlayerFromId(src)
            return xPlayer and xPlayer.getName() or 'Unknown'
        end
    end
    
    -- Metadata/State Management (Using StateBags for cross-framework compatibility)
    function Framework.SetState(src, key, val)
        local p = Player(src)
        if p then p.state:set(key, val, true) end
    end
    
    function Framework.GetState(src, key)
        local p = Player(src)
        return p and p.state[key] or nil
    end
end
