-- Krypton Farming - QBX-Core Bridge
-- QBX-Core için özel fonksiyonlar

if Krypton.FrameworkType ~= 'qbx' then return end

local QBX = exports.qbx_core

-- Player Fonksiyonları
Krypton.Framework.GetPlayer = function(source)
    return QBX:GetPlayer(source)
end

Krypton.Framework.GetPlayerFromId = function(source)
    local Player = Krypton.Framework.GetPlayer(source)
    if Player then
        local playerData = Player.PlayerData
        return {
            source = source,
            identifier = playerData.citizenid,
            name = playerData.charinfo.firstname .. ' ' .. playerData.charinfo.lastname,
            money = playerData.money['cash'],
            bank = playerData.money['bank'],
            job = playerData.job.name,
            jobLabel = playerData.job.label,
            gang = playerData.gang.name,
            gangLabel = playerData.gang.label
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
        -- Server-side: Her zaman kendi client handler'ımıza gönder
        TriggerClientEvent('krypton-farming:client:notify', source, message, notifyType, duration)
    else
        -- Client-side: Config'e göre yönlendir
        if Krypton and Krypton.Notify then
            Krypton.Notify(message, notifyType, duration)
        else
            -- Fallback: ox_lib
            exports.ox_lib:notify({
                title = 'Çiftçilik',
                description = message,
                type = notifyType or 'inform',
                duration = duration or 5000
            })
        end
    end
end

-- Tüm Oyuncular
Krypton.Framework.GetPlayers = function()
    local players = QBX:GetQBPlayers()
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
    -- 1. Ace permission kontrolü
    if Config.AdminPanel and Config.AdminPanel.acePermission then
        if IsPlayerAceAllowed(src, Config.AdminPanel.acePermission) then
            return true
        end
    end
    -- 2. QBX permission kontrolü
    if QBX.HasPermission then
        if QBX:HasPermission(source, 'admin') or QBX:HasPermission(source, 'god') then
            return true
        end
    end
    -- 3. Fallback: QBCore uyumlu kontrol
    local Player = Krypton.Framework.GetPlayer(source)
    if Player and Player.Functions and Player.Functions.HasPermission then
        if Player.Functions.HasPermission('admin') or Player.Functions.HasPermission('god') then
            return true
        end
    end
    -- 4. txAdmin / built-in admin fallback
    if IsPlayerAceAllowed(src, 'command') then
        return true
    end
    return false
end
