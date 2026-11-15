local function loadFramework()
    ESX = nil

    if not Config.UseExportForEsx then
        ESX = exports['es_extended']:getSharedObject()
    else
        Citizen.CreateThread(function()
            while ESX == nil do
                TriggerEvent('esx:getSharedObject', function(obj)
                    ESX = obj
                end)
                Citizen.Wait(0)
            end
        end)
    end

    Citizen.CreateThread(function()
        while ESX == nil or ESX.GetPlayerData().job == nil do
            Citizen.Wait(10)
        end

        ESX.PlayerData = ESX.GetPlayerData()

        PLAYER_DATA    = ESX.PlayerData
    end)

    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(jobData)
        PLAYER_DATA.job = jobData
    end)

    function IsPlayerBoss()
        if PLAYER_DATA and PLAYER_DATA.job and PLAYER_DATA.job.grade_name then
            return PLAYER_DATA.job.grade_name == "boss"
        else
            return false
        end
    end

    function GetPlayerJob()
        return PLAYER_DATA.job.name
    end

    function HasItem(itemName)
        local xPlayer = ESX.GetPlayerData()
        if not xPlayer or not xPlayer.inventory then return false end

        for _, item in pairs(xPlayer.inventory) do
            if item.name == itemName and item.count > 0 then
                return true
            end
        end
        return false
    end
    
    function NotifyViaFramework(message, type)
        if type == 'warning' then
            type = 'error'
        end
        
        ESX.ShowNotification(message, type, 4000)
    end

    exports("IsPlayerBoss", IsPlayerBoss)
    exports("GetPlayerJob", GetPlayerJob)
    exports("NotifyViaFramework", NotifyViaFramework)
    exports('HasItem', HasItem)
end

-- CreateThread(function()
    if Config.Framework == "auto" then
        if GetResourceState("es_extended") == "started" then
            loadFramework()

            RegisterNetEvent('esx:playerLoaded', function()
                playerLoaded()
            end)
        end
    elseif Config.Framework == "esx" then
        loadFramework()
        
        RegisterNetEvent('esx:playerLoaded', function()
            playerLoaded()
        end)
    end
-- end)