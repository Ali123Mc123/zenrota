ConfigSv = {}
ConfigSv.Webhook =
"REDACTED_BEFORE_GITHUB_UPLOAD"                    -- Your webhook link here
ConfigSv.Inventorys = {
    -- [[ 🟢 Inventory detections, to work automatically compatible with some inventories. 🟢 ]]
    ["qb_inventory"] = GetResourceState("qb-inventory"):find("start") and true or false,
    ["qs_inventory"] = GetResourceState("qs-inventory"):find("start") and true or false,
    ["ox_inventory"] = GetResourceState("ox_inventory"):find("start") and true or false,
    ["export"] = nil
}
ConfigSv.MoneySettings = {
    -- [[ 🟢 Money Settings 🟢 ]]
    ["hasMoneyItem"] = false,
    ["moneyItemName"] = "money",
}

function sendWebhook(source, name, logtype, amount)
    local ts = os.time()
    local time = os.date('%Y-%m-%d %H:%M:%S', ts)
    local embed = {
        {
            ["title"] = ('Player Earned %s'):format(logtype),
            ["description"] = ('The player made %s'):format(logtype),
            ["color"] = 16705372,
            ["fields"] = {
                { ["name"] = "📃 Player", ["value"] = ('**%s - [%s]**'):format(name, source) },
                { ["name"] = ("✅ Earned %s Value"):format(logtype), ["value"] = ('**$%s**'):format(amount) },
            },
            ["author"] = {
                ["name"] = "Ayazwai",
                ["url"] = "https://github.com/ayazwai",
                ["icon_url"] =
                "https://cdn.discordapp.com/avatars/225154669817626626/12042ba04def3b74fdb3f6492853ee37.png?size=1024"
            },
            ["timestamp"] = time,
            ["thumbnail"] = {
                ["url"] =
                "https://img.gta5-mods.com/q95/images/sauer-101-hunting-rifle-animated-4k/e80833-Sauer101_2.PNG"
            }
        }
    }
    PerformHttpRequest(ConfigSv.Webhook, function(err, text, headers) end, 'POST',
        json.encode({ username = "Daddy Hunting", embeds = embed }), { ['Content-Type'] = 'application/json' })
end

---------------------------------------------------------------------------------------------------------------
---This function is used to access player source with a given static ID.
---@enum [parent=#ConfigSv] GetPlayerSourceByStaticId
---@param staticId
---@return #number
ConfigSv.GetPlayerSourceByStaticId = function(staticId)
    -- Get the user source from the Framework or Static ID script. Export or Event.
    return staticId
end
---------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
---This function is used to access player names.
---@enum [parent=#ConfigSv] GetPlayerName
---@param source
---@return #string
ConfigSv.GetPlayerName = function(source)
    if Config.Framework.Framework == "esx" then
        local Player = wFramework.Framework.GetPlayerFromId(source)
        return Player ~= nil and ('%s - %s'):format(Player.get('firstName'), Player.get('lastName')) or "Unknown Player"
    elseif Config.Framework.Framework == "qbcore" or Config.Framework.Framework == "qbx" then
        local Player = wFramework.Framework.Functions.GetPlayer(source)
        return Player ~= nil and
        ('%s - %s'):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname) or "Unknown Player"
    end
end
---------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
---This function is used to access player names.
---@enum [parent=#ConfigSv] SetJob
---@param source
---@param job
---@return nil
ConfigSv.SetJob = function(source, job, grade)
    local src = source
    local Player = Config.Framework.Framework == "esx" and wFramework.Framework.GetPlayerFromId(src) or
    ((Config.Framework.Framework == "qbcore" or Config.Framework.Framework == "qbx") and wFramework.Framework.Functions.GetPlayer(src) or nil)
    if not Player then return Config.Debug(("[^1ERROR - SETJOB^0] Could not find player with source %s - ConfigSv.SetJob")
        :format(src)) end

    if Config.Framework.Framework == "esx" then
        Player.setJob(job, grade)
    elseif Config.Framework.Framework == "qbcore" or Config.Framework.Framework == "qbx" then
        Player.Functions.SetJob(job, grade)
    end
end
---------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
---Function that takes care of player money giving
---@enum [parent=#ConfigSv] AddMoney
---@param source
---@param amount
---@return #boolean
-- DaddyRP: CollegeAllowsHunting (bridge/editable/server.lua, Config.CollegeGate) stops rifle, parts and pay
-- for anyone who is not a College student with the hunting certificate.
ConfigSv.AddMoney = function(src, amount)
    if amount <= 0 then return false end
    if not CollegeAllowsHunting(src) then return false end
    local p = promise:new()

    if Config.Framework.Framework == "esx" then
        local xPlayer = wFramework.Framework.GetPlayerFromId(src)
        if xPlayer ~= nil then
            if ConfigSv.MoneySettings.hasMoneyItem then
                xPlayer.addInventoryItem(ConfigSv.MoneySettings.moneyItemName, amount)
            else
                xPlayer.addMoney(amount)
            end

            p:resolve(true)
        else
            Config.Debug(("[^1ERROR - ADDMONEY^0] Could not find player with source %s - ConfigSv.AddMoney"):format(src))
            p:resolve(false)
        end
    elseif Config.Framework.Framework == "qbcore" or Config.Framework.Framework == "qbx" then
        local Player = wFramework.Framework.Functions.GetPlayer(src)
        if Player ~= nil then
            if ConfigSv.MoneySettings.hasMoneyItem then
                if ConfigSv.Inventorys.export:AddItem(src, ConfigSv.MoneySettings.moneyItemName, amount) == nil then
                    Player.Functions.AddItem(ConfigSv.MoneySettings.moneyItemName, amount)
                end
            else
                Player.Functions.AddMoney("cash", amount)
            end

            p:resolve(true)
        else
            Config.Debug(("[^1ERROR - ADDMONEY^0] Could not find player with source %s - ConfigSv.AddMoney"):format(src))
            p:resolve(false)
        end
    end

    sendWebhook(src, ConfigSv.GetPlayerName(src), "Money", amount)
    return Citizen.Await(p)
end
---------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
---Function that takes care of player items giving
---@enum [parent=#ConfigSv] AddItem
---@param source
---@param item
---@param amount
---@return #boolean
ConfigSv.AddItem = function(src, item, amount)
    if not CollegeAllowsHunting(src) then return false end
    local p = promise:new()

    local itemName = tostring(item):lower()
    if itemName:find("meat") or itemName:find("hide") or itemName:find("fur") or itemName:find("leather") or itemName:find("carcass") or itemName:find("horn") or itemName:find("tusk") then
        TriggerClientEvent('rcore_stats:api:increaseStatValue', src, 'animals_hunted', 1)
    end

    if Config.Framework.Framework == "esx" then
        local xPlayer = wFramework.Framework.GetPlayerFromId(src)
        if xPlayer ~= nil then
            xPlayer.addInventoryItem(item, amount)
            p:resolve(true)
        else
            Config.Debug(("[^1ERROR - ADDITEM^0] Could not find player with source %s - ConfigSv.AddItem"):format(src))
            p:resolve(false)
        end
    elseif Config.Framework.Framework == "qbcore" or Config.Framework.Framework == "qbx" then
        local Player = wFramework.Framework.Functions.GetPlayer(src)
        if Player ~= nil then
            if ConfigSv.Inventorys.export:AddItem(src, item, amount) == nil then
                Player.Functions.AddItem(item, amount)
            end

            p:resolve(true)
        else
            Config.Debug(("[^1ERROR - ADDITEM^0] Could not find player with source %s - ConfigSv.AddItem"):format(src))
            p:resolve(false)
        end
    end

    return Citizen.Await(p)
end
---------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
---Function getting the item count of the player
---@enum [parent=#ConfigSv] GetItem
---@param source
---@param item
---@param amount
---@return #boolean
ConfigSv.GetItemAmount = function(src, item)
    local p = promise:new()
    local count = nil

    if ConfigSv.Inventorys.qs_inventory then
        count = ConfigSv.Inventorys.export:GetItemTotalAmount(src, item)
    elseif ConfigSv.Inventorys.ox_inventory or ConfigSv.Inventorys.qb_inventory then
        count = ConfigSv.Inventorys.export:GetItemCount(src, item) or 0
    else
        local Player = Config.Framework.Framework == "esx" and wFramework.Framework.GetPlayerFromId(src) or
        ((Config.Framework.Framework == "qbcore" or Config.Framework.Framework == "qbx") and wFramework.Framework.Functions.GetPlayer(src) or nil)
        if not Player then
            p:resolve(0)
            Config.Debug(("[^1ERROR - GETITEM^0] Could not find player with source %s - ConfigSv.GetItemAmount"):format(
            src))
            return Citizen.Await(p)
        end
        count = Config.Framework.Framework == "esx" and
        (Player.getInventoryItem(item) ~= nil and Player.getInventoryItem(item).count or 0) or
        (Player.Functions.GetItemByName(item) ~= nil and Player.Functions.GetItemByName(item).amount or 0)
    end

    p:resolve(count)
    return Citizen.Await(p)
end
---------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
---Function that takes care of player items removing
---@enum [parent=#ConfigSv] RemoveItem
---@param source
---@param item
---@param amount
---@return #boolean
ConfigSv.RemoveItem = function(src, item, amount)
    local p = promise:new()
    local Player = Config.Framework.Framework == "esx" and wFramework.Framework.GetPlayerFromId(src) or
    ((Config.Framework.Framework == "qbcore" or Config.Framework.Framework == "qbx") and wFramework.Framework.Functions.GetPlayer(src) or nil)
    if not Player then
        p:resolve(false)
        Config.Debug(("[^1ERROR - REMOVEITEM^0] Could not find player with source %s - ConfigSv.RemoveItem"):format(src))
        return Citizen.Await(p)
    end

    if Config.Framework.Framework == "qbcore" or Config.Framework.Framework == "qbx" then
        p:resolve(Player.Functions.RemoveItem(item, amount))
    else
        if ConfigSv.Inventorys.qs_inventory or ConfigSv.Inventorys.ox_inventory or ConfigSv.Inventorys.qb_inventory then
            p:resolve(ConfigSv.Inventorys.export:RemoveItem(src, item, amount))
        else
            if Player.getInventoryItem(item).count >= amount then
                Player.removeInventoryItem(item, amount)
                p:resolve(true)
            else
                p:resolve(false)
            end
        end
    end

    return Citizen.Await(p)
end
---------------------------------------------------------------------------------------------------------------

--- This function will be called when an animal is created, you can use it to add custom behavior to the animals, such as adding blips, setting attributes, etc.
--- @param netId number The network ID of the animal
--- @param zoneId number The ID of the zone the animal is in
--- @param model string The model of the animal
--- @param canAttack boolean Whether the animal can attack
ConfigSv.AnimalCreated = function(netId, zoneId, model, canAttack)
    Config.Debug(("[^2ANIMAL CREATED^0] NetID: %s | ZoneID: %s | Model: %s | CanAttack: %s"):format(netId, zoneId, model,
        tostring(canAttack)))
end

CreateThread(function()
    ConfigSv.Inventorys.export = ConfigSv.Inventorys.qs_inventory and exports['qs-inventory'] or
    ConfigSv.Inventorys.ox_inventory and exports.ox_inventory or nil or
    ConfigSv.Inventorys.qb_inventory and exports['qb-inventory'] or nil
    if not ConfigSv.Inventorys.export then
        Config.Debug(
        "[wais-hunting] No compatible inventory found, please set the export method manually in config_sv.lua")
    end
end)
