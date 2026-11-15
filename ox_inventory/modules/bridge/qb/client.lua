local QBCore = exports['qb-core']:GetCoreObject()
local Inventory = require 'modules.inventory.client'
local Weapon = require 'modules.weapon.client'

local Config = {
	rarities = {},
	defaultRarity = 'common'
}

RegisterNetEvent('QBCore:Client:OnPlayerUnload', client.onLogout)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    if source == '' or not PlayerData.loaded then return end

    if (data.metadata.isdead or data.metadata.inlaststand) ~= PlayerData.dead then
        PlayerData.dead = data.metadata.isdead or data.metadata.inlaststand
        OnPlayerData('dead', PlayerData.dead)
    end

    local groups = PlayerData.groups

    if not groups[data.job.name] or not groups[data.gang.name] or groups[data.job.name] ~= data.job.grade.level or groups[data.gang.name] ~= data.gang.grade.level then
        PlayerData.groups = {
            [data.job.name] = data.job.grade.level,
            [data.gang.name] = data.gang.grade.level,
        }

        OnPlayerData('groups', PlayerData.groups)
    end

    if data.metadata.ishandcuffed then
        PlayerData.cuffed = true
        LocalPlayer.state:set('invBusy', true, false)
        Weapon.Disarm()
    elseif PlayerData.cuffed then
        PlayerData.cuffed = false
        LocalPlayer.state:set('invBusy', false, false)
    end
end)

---@diagnostic disable-next-line: duplicate-set-field
function client.setPlayerStatus(values)
    for name, value in pairs(values) do
        -- compatibility for ESX style values
        if value > 100 or value < -100 then
            value = value * 0.0001
        end

        if name == "hunger" then
            TriggerServerEvent('consumables:server:addHunger', QBCore.Functions.GetPlayerData().metadata.hunger + value)
        elseif name == "thirst" then
            TriggerServerEvent('consumables:server:addThirst', QBCore.Functions.GetPlayerData().metadata.thirst + value)
        elseif name == "stress" then
            if value > 0 then
                TriggerServerEvent('hud:server:GainStress', value)
            else
                value = math.abs(value)
                TriggerServerEvent('hud:server:RelieveStress', value)
            end
        end
    end
end

AddStateBagChangeHandler('inv_busy', ('player:%s'):format(cache.serverId), function(_, _, value)
    LocalPlayer.state:set('invBusy', value, false)
end)

---@diagnostic disable-next-line: duplicate-set-field
function client.getPlayerInfo()
    local player = QBCore.Functions.GetPlayerData()
    return {
        name = ('%s %s'):format(player.charinfo.firstname, player.charinfo.lastname),
        id = cache.serverId,
        cash = player.money and player.money.cash or 0,
        bank = player.money and player.money.bank or 0,
        avatar = PlayerData.avatar
    }
end

-- Rarity system integration
local function getRarityColor(itemName)
    local rarity = Inventory.GetItemRarity(itemName) or Config.DefaultRarity
    local rarityConfig = Config.Rarities and Config.Rarities[rarity]
    if rarityConfig then
        return rarityConfig.color
    end
    return Config.Rarities and Config.Rarities[Config.DefaultRarity] and Config.Rarities[Config.DefaultRarity].color
end

local function export(exportName, func)
    AddEventHandler(('__cfx_export_%s_%s'):format(string.strsplit('.', exportName, 2)), function(setCB)
        setCB(func or function()
            error(("export '%s' is not supported when using ox_inventory"):format(exportName))
        end)
    end)
end

export('qb-inventory.HasItem', function(items, amount)
    amount = amount or 1

    if type(items) == 'table' then
        for _, v in pairs(items) do
            if Inventory.GetItemCount(v) < amount then
                return false
            end
        end

        return true
    else
        return Inventory.GetItemCount(items) >= amount
    end
end)

export('qb-inventory.GetItemBySlot', function(slot)
    return Inventory.GetSlot(cache.playerId, slot)
end)

export('qb-inventory.GetItemByName', function(itemName)
    return Inventory.GetSlotWithItem(cache.playerId, itemName)
end)

export('qb-inventory.GetItemsByName', function(itemName)
    return Inventory.GetSlotsWithItem(cache.playerId, itemName)
end)
