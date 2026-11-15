if GetResourceState('qbx_core') == 'started' then
    QBCore = exports.qbx_core
elseif Config.Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
else
    QBCore = exports['qb-core']:GetCoreObject()
end

Framework = {}

function Framework:Notify(msg, type)
    if Config.Framework == "qb" then
        FrameworkObject.Functions.Notify(msg, type, 2500)
    elseif Config.Framework == "esx" then
        TriggerEvent('esx:showNotification', source, msg)
    end
end

function Framework:OpenStash(roomId, motelId)
    if currentRoom == nil then
        return Framework:Notify("Odada olman gerekiyor!", "error")
    end
    
    local name = "MOTEL-" .. motelId .. "-STASH-" .. roomId
    if GetResourceState('ox_inventory') == 'started' then
        if exports.ox_inventory:openInventory('stash', name) == false then
            TriggerServerEvent('izzy-motels:createStash', name)
            exports.ox_inventory:openInventory('stash', name)
        end
    else
        TriggerServerEvent('inventory:server:OpenInventory', 'stash', name, {
            maxweight = 1000000,
            slots = 75,
        })
    end 
end

function Framework:OpenClothing()
    if GetResourceState('qb-clothing') == 'started' then
        TriggerEvent('qb-clothing:client:openOutfitMenu')
    elseif GetResourceState('esx_skin') == 'started' then
        TriggerEvent("esx_skin:openSaveableMenu")
    elseif GetResourceState('fivem-appearance') == 'started' then
        exports["fivem-appearance"]:startPlayerCustomization(function(appearance)
            if appearance then
                TriggerServerEvent('fivem-appearance:server:saveAppearance', appearance)
            end
        end)
    elseif GetResourceState('illenium-appearance') == 'started' then
        TriggerEvent('illenium-appearance:client:openOutfitMenu')
    else
        -- You need to integrate your own clothing system here
    end
end