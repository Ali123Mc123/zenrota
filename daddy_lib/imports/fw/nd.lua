-- ND_Core 2.x. The character id (not the license) keeps characters apart.
local function player(source)
    return exports.ND_Core:getPlayer(source)
end

return {
    server = {
        citizenId = function(source)
            local p = player(source)
            return p and tostring(p.id)
        end,

        playerName = function(source)
            local p = player(source)
            return p and (p.fullname or ('%s %s'):format(p.firstname, p.lastname))
        end,

        job = function(source)
            local p = player(source)
            local info = p and p.jobInfo or {}
            return p and p.job and { name = p.job, grade = info.rank or 0, label = info.label }
        end,

        gang = function() return nil end,

        money = function(source, account)
            local p = player(source)
            return p and (account == 'cash' and p.cash or p.bank)
        end,

        removeMoney = function(source, account, amount, reason)
            local p = player(source)
            return p ~= nil and p.deductMoney(account, amount, reason) == true
        end,

        searchCharacters = function(query, limit)
            return MySQL.query.await([[SELECT CAST(charid AS CHAR) AS citizenid, CONCAT(firstname, ' ', lastname) AS name
                FROM nd_characters WHERE CAST(charid AS CHAR) = ? OR CONCAT(firstname, ' ', lastname) LIKE ? LIMIT ?]], { query, '%' .. query .. '%', limit }) or {}
        end,

        character = function(citizenid)
            return MySQL.single.await([[SELECT CAST(charid AS CHAR) AS citizenid, CONCAT(firstname, ' ', lastname) AS name
                FROM nd_characters WHERE charid = ?]], { tonumber(citizenid) })
        end,

        ownedVehicle = function() return nil end,
        vehiclesOf = function() return {} end,
        searchVehicles = function() return {}, 0 end,

        setJob = function(target, name, grade)
            local p = type(target) == 'number' and player(target)
            if not p then return false end
            p.setJob(name, grade)
            return true
        end,

        jobs = function() return {} end,

        dutyCount = function(job)
            local count = 0
            for _, id in ipairs(GetPlayers()) do
                local p = player(tonumber(id))
                if p and p.job == job then count = count + 1 end
            end
            return count
        end,

        onDuty = function() return true end,

        addMoney = function(source, account, amount, reason)
            local p = player(source)
            return p ~= nil and p.addMoney(account, amount, reason) ~= false
        end,

        isAdmin = function() return false end,

        onLoaded = function(cb)
            AddEventHandler('ND:characterLoaded', function(character) cb(character.source) end)
        end,

        onUnloaded = function(cb)
            AddEventHandler('ND:characterUnloaded', function(source) cb(source) end)
        end,

        onJobChange = function(cb)
            AddEventHandler('ND:characterUpdated', function(character) cb(character.source) end)
        end,
        onMoneyChange = function(cb)
            AddEventHandler('ND:moneyChange', function(src) cb(src) end)
        end,

        registerUsable = function() return false end,
    },

    client = {
        isLoggedIn = function() return exports.ND_Core:getPlayer() ~= nil end,

        citizenId = function()
            local p = exports.ND_Core:getPlayer()
            return p and tostring(p.id)
        end,

        onLoaded = function(cb) RegisterNetEvent('ND:characterLoaded', cb) end,
        onUnloaded = function(cb) RegisterNetEvent('ND:characterUnloaded', cb) end,
    },
}
