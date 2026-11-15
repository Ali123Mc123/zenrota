local shared
local has = DL.require('fw/schema')

local function esx()
    shared = shared or exports.es_extended:getSharedObject()
    return shared
end

local ADMIN_GROUPS = { admin = true, superadmin = true }
local VEHICLE = 'SELECT UPPER(TRIM(plate)) AS plate, vehicle AS model, owner FROM owned_vehicles'

-- Names live in esx_identity's columns; without it the identifier stands in.
local function name()
    return has('users', 'firstname') and "CONCAT(firstname, ' ', lastname)" or 'identifier'
end

-- Players of a job who are on duty (ESX before 1.11 has no duty: everyone is).
local function working(p) return p.job.onDuty ~= false end

-- ESX calls cash 'money'.
local function accountOf(source, account)
    local p = esx().GetPlayerFromId(source)
    local name = account == 'cash' and 'money' or account
    return p, name, p and p.getAccount(name)
end

return {
    server = {
        citizenId = function(source)
            local p = esx().GetPlayerFromId(source)
            return p and p.identifier
        end,

        playerName = function(source)
            local p = esx().GetPlayerFromId(source)
            return p and p.getName()
        end,

        job = function(source)
            local p = esx().GetPlayerFromId(source)
            return p and { name = p.job.name, grade = p.job.grade, label = p.job.label }
        end,

        gang = function() return nil end,

        money = function(source, account)
            local _, _, data = accountOf(source, account)
            return data and data.money
        end,

        removeMoney = function(source, account, amount, reason)
            local p, name, data = accountOf(source, account)
            if not data or data.money < amount then return false end
            p.removeAccountMoney(name, amount, reason)
            return true
        end,

        searchCharacters = function(query, limit)
            local like = '%' .. query .. '%'
            return MySQL.query.await(('SELECT identifier AS citizenid, %s AS name FROM users WHERE identifier LIKE ? OR %s LIKE ? LIMIT ?'):format(name(), name()), { like, like, limit }) or {}
        end,

        character = function(citizenid)
            return MySQL.single.await(('SELECT identifier AS citizenid, %s AS name, job, job_grade AS grade FROM users WHERE identifier = ?'):format(name()), { citizenid })
        end,

        -- owned_vehicles comes with esx_vehicleshop.
        ownedVehicle = function(plate)
            if not has('owned_vehicles') then return nil end
            return MySQL.single.await(VEHICLE .. ' WHERE UPPER(TRIM(plate)) = ? LIMIT 1', { plate })
        end,

        vehiclesOf = function(citizenid)
            if not has('owned_vehicles') then return {} end
            return MySQL.query.await(VEHICLE .. ' WHERE owner = ? ORDER BY plate LIMIT 100', { citizenid }) or {}
        end,

        searchVehicles = function(text, limit, offset)
            if not has('owned_vehicles') then return {}, 0 end
            local like = '%' .. text .. '%'
            local total = MySQL.scalar.await('SELECT COUNT(*) FROM owned_vehicles WHERE plate LIKE ?', { like }) or 0
            return MySQL.query.await(VEHICLE .. ' WHERE plate LIKE ? ORDER BY plate LIMIT ? OFFSET ?', { like, limit, offset }) or {}, total
        end,

        setJob = function(target, name, grade)
            if not esx().DoesJobExist(name, grade) then grade = 0 end
            local p = type(target) == 'number' and esx().GetPlayerFromId(target) or esx().GetPlayerFromIdentifier(target)
            if p then
                p.setJob(name, grade)
                return true
            end
            return MySQL.update.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', { name, grade, target }) == 1
        end,

        jobs = function()
            local players = DL.require('fw/players')
            return players.normalizeJobs(esx().GetJobs())
        end,

        dutyCount = function(job)
            local count = 0
            for _, p in pairs(esx().GetExtendedPlayers('job', job)) do
                if working(p) then count = count + 1 end
            end
            return count
        end,

        onDuty = function(source)
            local p = esx().GetPlayerFromId(source)
            return p ~= nil and working(p)
        end,

        addMoney = function(source, account, amount, reason)
            local p, name = accountOf(source, account)
            if not p then return false end
            p.addAccountMoney(name, amount, reason)
            return true
        end,

        isAdmin = function(source)
            local p = esx().GetPlayerFromId(source)
            return p ~= nil and ADMIN_GROUPS[p.getGroup()] == true
        end,

        onLoaded = function(cb)
            AddEventHandler('esx:playerLoaded', function(playerId) cb(playerId) end)
        end,

        onUnloaded = function(cb)
            AddEventHandler('esx:playerDropped', function(playerId) cb(playerId) end)
        end,

        onJobChange = function(cb)
            AddEventHandler('esx:setJob', function(src) cb(src) end)
        end,
        onMoneyChange = function(cb)
            for _, name in ipairs({ 'esx:setAccountMoney', 'esx:addAccountMoney', 'esx:removeAccountMoney' }) do
                AddEventHandler(name, function(src) cb(src) end)
            end
        end,

        registerUsable = function(item, cb)
            esx().RegisterUsableItem(item, function(source) cb(source) end)
            return true
        end,
    },

    client = {
        isLoggedIn = function() return esx().IsPlayerLoaded() end,

        citizenId = function()
            local data = esx().GetPlayerData()
            return data and data.identifier
        end,

        onLoaded = function(cb) RegisterNetEvent('esx:playerLoaded', cb) end,
        onUnloaded = function(cb) RegisterNetEvent('esx:onPlayerLogout', cb) end,
    },
}
