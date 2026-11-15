-- Krypton Farming - Inventory Bridge
-- Tüm inventory sistemleri için birleşik API

Krypton.Inventory = Krypton.Inventory or {}

-- Item Ekleme
Krypton.Inventory.AddItem = function(source, itemName, amount, metadata)
    if not source or not itemName then return false end
    amount = amount or 1
    
    if Krypton.InventoryType == 'ox' then
        return exports.ox_inventory:AddItem(source, itemName, amount, metadata)
    elseif Krypton.InventoryType == 'qb' then
        local Player = Krypton.Framework.GetPlayer(source)
        if Player then
            return Player.Functions.AddItem(itemName, amount, nil, metadata)
        end
    elseif Krypton.InventoryType == 'qs' then
        return exports['qs-inventory']:AddItem(source, itemName, amount, nil, metadata)
    else
        -- Default fallback - QBX native
        local Player = Krypton.Framework.GetPlayer(source)
        if Player then
            return Player.Functions.AddItem(itemName, amount, nil, metadata)
        end
    end
    return false
end

-- Item Çıkarma
Krypton.Inventory.RemoveItem = function(source, itemName, amount, metadata, slot)
    if not source or not itemName then return false end
    amount = amount or 1
    
    if Krypton.InventoryType == 'ox' then
        return exports.ox_inventory:RemoveItem(source, itemName, amount, metadata, slot)
    elseif Krypton.InventoryType == 'qb' then
        local Player = Krypton.Framework.GetPlayer(source)
        if Player then
            return Player.Functions.RemoveItem(itemName, amount, slot)
        end
    elseif Krypton.InventoryType == 'qs' then
        return exports['qs-inventory']:RemoveItem(source, itemName, amount, slot)
    else
        local Player = Krypton.Framework.GetPlayer(source)
        if Player then
            return Player.Functions.RemoveItem(itemName, amount, slot)
        end
    end
    return false
end

-- Item Sayısı
Krypton.Inventory.GetItemCount = function(source, itemName, metadata)
    if not source or not itemName then return 0 end
    
    if Krypton.InventoryType == 'ox' then
        return exports.ox_inventory:GetItemCount(source, itemName, metadata) or 0
    elseif Krypton.InventoryType == 'qb' then
        local Player = Krypton.Framework.GetPlayer(source)
        if Player then
            local items = Player.PlayerData.items
            local count = 0
            for _, item in pairs(items) do
                if item.name == itemName then
                    count = count + (item.amount or item.count or 1)
                end
            end
            return count
        end
    elseif Krypton.InventoryType == 'qs' then
        return exports['qs-inventory']:GetItemTotalAmount(source, itemName) or 0
    else
        local Player = Krypton.Framework.GetPlayer(source)
        if Player then
            local items = Player.PlayerData.items
            local count = 0
            for _, item in pairs(items) do
                if item.name == itemName then
                    count = count + (item.amount or item.count or 1)
                end
            end
            return count
        end
    end
    return 0
end

-- Item Var mı?
Krypton.Inventory.HasItem = function(source, itemName, amount)
    amount = amount or 1
    return Krypton.Inventory.GetItemCount(source, itemName) >= amount
end

-- Envanter Dolu mu?
Krypton.Inventory.CanCarry = function(source, itemName, amount)
    if not source or not itemName then return false end
    amount = amount or 1
    
    if Krypton.InventoryType == 'ox' then
        return exports.ox_inventory:CanCarryItem(source, itemName, amount)
    elseif Krypton.InventoryType == 'qb' then
        local Player = Krypton.Framework.GetPlayer(source)
        if Player then
            local totalWeight = exports['qb-inventory']:GetTotalWeight(Player.PlayerData.items)
            local itemInfo = QBCore and QBCore.Shared.Items[itemName]
            local itemWeight = itemInfo and itemInfo.weight or 0
            local maxWeight = Config.MaxInventoryWeight or (QBCore and QBCore.Config and QBCore.Config.Player and QBCore.Config.Player.MaxWeight) or 120000
            return (totalWeight + (itemWeight * amount)) <= maxWeight
        end
        return false
    elseif Krypton.InventoryType == 'qs' then
        return exports['qs-inventory']:CanCarryItem(source, itemName, amount)
    else
        -- Default fallback - assume can carry (legacy support)
        return true
    end
end
