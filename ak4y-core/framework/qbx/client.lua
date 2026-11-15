local function loadFramework()
    print("Found Framework: QBX")
    QBCore = exports['qb-core']:GetCoreObject()
    
    function IsPlayerBoss()
        return QBCore.Functions.GetPlayerData().job.isboss
    end

    function GetPlayerJob()
        return QBCore.Functions.GetPlayerData().job.name
    end

    function NotifyViaFramework(message, type)
        QBCore.Functions.Notify(message, type, 4000)
    end

    function HasItem(itemName)
        local hasItem = QBCore.Functions.HasItem(itemName)
        return hasItem
    end

    exports("IsPlayerBoss", IsPlayerBoss)
    exports("GetPlayerJob", GetPlayerJob)
    exports("NotifyViaFramework", NotifyViaFramework)
    exports("HasItem", HasItem)
end

-- CreateThread(function()
    if Config.Framework == "auto" then
        if GetResourceState("qbx_core") == "started" then
            loadFramework()

            RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
                playerLoaded()
            end)
        end
    elseif Config.Framework == "qbx" then
        loadFramework()

        RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
            playerLoaded()
        end)
    else
        return
    end
-- end)
