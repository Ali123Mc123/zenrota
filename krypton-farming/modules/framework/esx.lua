-- Krypton Farming - ESX Bridge
-- ESX için özel fonksiyonlar

if Krypton.FrameworkType ~= 'esx' then return end

local ESX = Krypton.Framework.Object

-- Player Fonksiyonları
Krypton.Framework.GetPlayer = function(source)
    return ESX.GetPlayerFromId(source)
end

Krypton.Framework.GetPlayerFromId = function(source)
    local Player = Krypton.Framework.GetPlayer(source)
    if Player then
        return {
            source = source,
            identifier = Player.identifier,
            name = Player.getName(),
            money = Player.getMoney(),
            bank = Player.getAccount('bank').money,
            job = Player.job.name,
            jobLabel = Player.job.label,
            gang = nil,
            gangLabel = nil
        }
    end
    return nil
end

-- Para İşlemleri
Krypton.Framework.AddMoney = function(source, amount, moneyType)
    local Player = Krypton.Framework.GetPlayer(source)
    if Player then
        if moneyType == 'bank' then
            Player.addAccountMoney('bank', amount, 'krypton-farming')
        else
            Player.addMoney(amount, 'krypton-farming')
        end
        return true
    end
    return false
end

Krypton.Framework.RemoveMoney = function(source, amount, moneyType)
    local Player = Krypton.Framework.GetPlayer(source)
    if Player then
        if moneyType == 'bank' then
            if Player.getAccount('bank').money >= amount then
                Player.removeAccountMoney('bank', amount, 'krypton-farming')
                return true
            end
        else
            if Player.getMoney() >= amount then
                Player.removeMoney(amount, 'krypton-farming')
                return true
            end
        end
    end
    return false
end

Krypton.Framework.GetMoney = function(source, moneyType)
    local Player = Krypton.Framework.GetPlayer(source)
    if Player then
        if moneyType == 'bank' then
            return Player.getAccount('bank').money or 0
        else
            return Player.getMoney() or 0
        end
    end
    return 0
end

-- Bildirim Sistemi
Krypton.Framework.Notify = function(source, message, notifyType, duration)
    if IsDuplicityVersion() then
        -- Server-side: Her zaman kendi client handler'ımıza gönder
        TriggerClientEvent('krypton-farming:client:notify', source, message, notifyType, duration)
    else
        -- Client-side: Config'e göre yönlendir
        if Krypton and Krypton.Notify then
            Krypton.Notify(message, notifyType, duration)
        else
            -- Fallback: ESX
            ESX.ShowNotification(message)
        end
    end
end

-- Tüm Oyuncular
Krypton.Framework.GetPlayers = function()
    return ESX.GetPlayers()
end

-- Oyuncu identifier
Krypton.Framework.GetIdentifier = function(source)
    local Player = Krypton.Framework.GetPlayer(source)
    if Player then
        return Player.identifier
    end
    return nil
end

-- Oyuncu yaşıyor mu?
Krypton.Framework.IsPlayerDead = function(source)
    local Player = Krypton.Framework.GetPlayer(source)
    if Player then
        -- ESX doesn't have native dead check on server, return false
        return false
    end
    return false
end

-- Admin Kontrolü
Krypton.Framework.IsAdmin = function(source)
    local src = tostring(source)
    -- 1. Ace permission kontrolü
    if Config.AdminPanel and Config.AdminPanel.acePermission then
        if IsPlayerAceAllowed(src, Config.AdminPanel.acePermission) then
            return true
        end
    end
    -- 2. ESX admin group kontrolü
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local group = xPlayer.getGroup()
        if group == 'admin' or group == 'superadmin' then return true end
    end
    -- 3. txAdmin / built-in admin fallback
    if IsPlayerAceAllowed(src, 'command') then
        return true
    end
    return false
end
