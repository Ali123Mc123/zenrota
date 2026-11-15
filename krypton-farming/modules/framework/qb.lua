-- Krypton Farming - QBCore Bridge
-- QBCore için özel fonksiyonlar

if Krypton.FrameworkType ~= 'qb' then return end

local QBCore = Krypton.Framework.Object

-- Player Fonksiyonları
Krypton.Framework.GetPlayer = function(source)
    return QBCore.Functions.GetPlayer(source)
end

Krypton.Framework.GetPlayerFromId = function(source)
    local Player = Krypton.Framework.GetPlayer(source)
    if Player then
        return {
            source = source,
            identifier = Player.PlayerData.citizenid,
            name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            money = Player.PlayerData.money['cash'],
            bank = Player.PlayerData.money['bank'],
            job = Player.PlayerData.job.name,
            jobLabel = Player.PlayerData.job.label,
            gang = Player.PlayerData.gang.name,
            gangLabel = Player.PlayerData.gang.label
        }
    end
    return nil
end

-- Para İşlemleri
Krypton.Framework.AddMoney = function(source, amount, moneyType)
    local Player = Krypton.Framework.GetPlayer(source)
    if Player then
        return Player.Functions.AddMoney(moneyType or 'cash', amount, 'krypton-farming')
    end
    return false
end

Krypton.Framework.RemoveMoney = function(source, amount, moneyType)
    local Player = Krypton.Framework.GetPlayer(source)
    if Player then
        return Player.Functions.RemoveMoney(moneyType or 'cash', amount, 'krypton-farming')
    end
    return false
end

Krypton.Framework.GetMoney = function(source, moneyType)
    local Player = Krypton.Framework.GetPlayer(source)
    if Player then
        return Player.PlayerData.money[moneyType or 'cash'] or 0
    end
    return 0
end

-- Bildirim Sistemi
Krypton.Framework.Notify = function(source, message, notifyType, duration)
    if IsDuplicityVersion() then
        -- Server-side: Always send to our client handler
        TriggerClientEvent('krypton-farming:client:notify', source, message, notifyType or 'success', duration or 5000)
    else
        -- Client-side: Use our Krypton.Notify which respects Config.NotifySystem
        if Krypton and Krypton.Notify then
            Krypton.Notify(message, notifyType or 'info', duration or 5000)
        else
            -- Fallback only if Krypton.Notify doesn't exist
            QBCore.Functions.Notify(message, notifyType or 'success', duration or 5000)
        end
    end
end

-- Tüm Oyuncular
Krypton.Framework.GetPlayers = function()
    local players = QBCore.Functions.GetQBPlayers()
    local playerList = {}
    for src, _ in pairs(players) do
        table.insert(playerList, src)
    end
    return playerList
end

-- Oyuncu identifier
Krypton.Framework.GetIdentifier = function(source)
    local Player = Krypton.Framework.GetPlayer(source)
    if Player then
        return Player.PlayerData.citizenid
    end
    return nil
end

-- Oyuncu yaşıyor mu?
Krypton.Framework.IsPlayerDead = function(source)
    local Player = Krypton.Framework.GetPlayer(source)
    if Player then
        return Player.PlayerData.metadata.isdead or Player.PlayerData.metadata.inlaststand or false
    end
    return false
end

-- Admin Kontrolü
Krypton.Framework.IsAdmin = function(source)
    local src = tostring(source)
    -- 1. Ace permission kontrolü (cfg_admin.lua'dan)
    if Config.AdminPanel and Config.AdminPanel.acePermission then
        if IsPlayerAceAllowed(src, Config.AdminPanel.acePermission) then
            return true
        end
    end
    -- 2. QBCore permission kontrolü
    if QBCore.Functions.HasPermission then
        if QBCore.Functions.HasPermission(source, 'admin') or QBCore.Functions.HasPermission(source, 'god') then
            return true
        end
    end
    -- 3. txAdmin / built-in admin fallback
    if IsPlayerAceAllowed(src, 'command') then
        return true
    end
    return false
end
