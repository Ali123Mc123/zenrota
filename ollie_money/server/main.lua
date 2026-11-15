local RESOURCE = GetCurrentResourceName()
local QBox = exports.qbx_core

local lastPrint = {}

local function clampAmount(amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return nil end
    if amount > Config.MaxAmount then return Config.MaxAmount end
    return amount
end

local function normalizeAccount(account)
    account = tostring(account or 'cash'):lower()
    if not Config.Accounts[account] then return nil end
    return account
end

local function getPlayer(src)
    local ok, player = pcall(function() return QBox:GetPlayer(src) end)
    if not ok or not player then return nil end
    return player
end

local function isStaff(src)
    for i = 1, #Config.AcePermissions do
        if IsPlayerAceAllowed(src, Config.AcePermissions[i]) then return true end
    end
    return false
end

local function webhook(title, description, color)
    if not Config.Webhook or Config.Webhook == '' then return end
    PerformHttpRequest(Config.Webhook, function() end, 'POST', json.encode({
        username = 'ollie_money',
        embeds = { { title = title, description = description, color = color or 65280 } },
    }), { ['Content-Type'] = 'application/json' })
end

--- Adds money to a connected player and persists the row immediately.
---@param src number source id
---@param account string cash|bank|crypto
---@param amount number
---@param reason string|nil
---@return boolean success
---@return number|string newBalanceOrError
local function printMoney(src, account, amount, reason)
    src = tonumber(src)
    if not src then return false, 'invalid source' end
    amount = clampAmount(amount)
    if not amount then return false, 'amount must be > 0' end
    account = normalizeAccount(account)
    if not account then return false, 'unknown account' end

    local player = getPlayer(src)
    if not player then return false, 'player not loaded' end

    local now = GetGameTimer()
    if lastPrint[src] and now - lastPrint[src] < Config.CooldownMs then
        return false, 'cooldown'
    end
    lastPrint[src] = now

    local before = player.PlayerData.money[account] or 0
    player.Functions.AddMoney(account, amount, reason or Config.Reason)
    pcall(function() player.Functions.Save() end)

    local after = player.PlayerData.money[account] or (before + amount)
    return true, after
end

exports('PrintMoney', function(src, account, amount, reason)
    return printMoney(src, account, amount, reason)
end)

exports('PrintMoneyAll', function(account, amount, reason)
    local players = QBox:GetQBPlayers()
    local count = 0
    for src in pairs(players) do
        if printMoney(src, account, amount, reason) then count = count + 1 end
    end
    return count
end)

local function selfPrint(src, account, amount, silent)
    if not Config.AllowEveryone and not isStaff(src) then
        if not silent then TriggerClientEvent('ollie_money:client:notify', src, 'Bu komut icin yetkin yok.', 'error') end
        return
    end
    local ok, result = printMoney(src, account, amount, Config.Reason)
    if not silent then
        TriggerClientEvent('ollie_money:client:notify', src, ok
            and ('Hesaba islendi. Yeni bakiye: $' .. result)
            or ('Olmadi: ' .. tostring(result)), ok and 'success' or 'error')
    end
    webhook(ok and 'money printed' or 'money print failed', ('src `%s` / %s / %s / %s'):format(src, account, amount, tostring(result)), ok and 65280 or 16711680)
end

-- Self print. Needs Config.AllowEveryone or an ACE node, otherwise anyone
-- with an executor can mint on your server.
RegisterNetEvent('ollie_money:print', function(amount, account)
    selfPrint(source, account, amount)
end)

-- Admin: print to a specific source.
RegisterNetEvent('ollie_money:printTo', function(targetId, amount, account)
    local src = source
    if not isStaff(src) then
        TriggerClientEvent('ollie_money:client:notify', src, 'Bu komut icin yetkin yok.', 'error')
        return
    end
    local ok, result = printMoney(targetId, account, amount, Config.Reason)
    TriggerClientEvent('ollie_money:client:notify', src, ok
        and ('ID %d hesabina islendi. Yeni bakiye: $%s'):format(tonumber(targetId) or 0, result)
        or ('Olmadi: ' .. tostring(result)), ok and 'success' or 'error')
    webhook(ok and 'money printed (target)' or 'money print failed (target)',
        ('staff `%s` -> `%s` / %s / %s'):format(src, tostring(targetId), account, amount), ok and 65280 or 16711680)
end)

RegisterCommand('para', function(src, args)
    local amount = args[1] or Config.DefaultAmount
    local account = args[2] or 'bank'
    -- /para <amount> [cash|bank|crypto]
    selfPrint(src, account, amount)
end, false)

RegisterCommand('parahep', function(src, args)
    if not isStaff(src) then
        TriggerClientEvent('ollie_money:client:notify', src, 'Bu komut icin yetkin yok.', 'error')
        return
    end
    local amount = clampAmount(args[1] or Config.DefaultAmount)
    local account = normalizeAccount(args[2] or 'bank')
    if not amount or not account then
        TriggerClientEvent('ollie_money:client:notify', src, 'Kullanim: /parahep <miktar> [cash|bank|crypto]', 'error')
        return
    end
    local count = exports[RESOURCE]:PrintMoneyAll(account, amount, 'ollie_print_all')
    webhook('money printed to all', ('staff `%s` / %s / %s / %d players'):format(src, account, amount, count), 65280)
    TriggerClientEvent('ollie_money:client:notify', src, ('%d oyuncuya islendi.'):format(count), 'success')
end, false)

RegisterCommand('parabakiye', function(src, args)
    local target = tonumber(args[1]) or src
    local player = getPlayer(target)
    if not player then
        TriggerClientEvent('ollie_money:client:notify', src, 'Oyuncu yuklu degil.', 'error')
        return
    end
    local money = player.PlayerData.money or {}
    TriggerClientEvent('ollie_money:client:notify', src,
        ('ID %d | cash %s | bank %s | crypto %s'):format(target, money.cash or 0, money.bank or 0, money.crypto or 0), 'inform')
end, false)

-- Standalone SQL mint for offline players. Only fires when the resource export
-- is unavailable, i.e. the player is not loaded in memory.
lib.callback.register('ollie_money:server:mintOffline', function(src, citizenid, account, amount)
    if not isStaff(src) then return false, 'no permission' end
    account = normalizeAccount(account)
    amount = clampAmount(amount)
    if not account or not amount or not citizenid then return false, 'invalid input' end

    local row = MySQL.single.await('SELECT money FROM players WHERE citizenid = ?', { citizenid })
    if not row then return false, 'citizenid not found' end

    local money = json.decode(row.money) or {}
    money[account] = (money[account] or 0) + amount
    MySQL.update.await('UPDATE players SET money = ? WHERE citizenid = ?', { json.encode(money), citizenid })
    webhook('offline mint', ('citizenid `%s` / %s / %s'):format(citizenid, account, amount), 16776960)
    return true, money[account]
end)

AddEventHandler('playerDropped', function()
    lastPrint[source] = nil
end)
