local core
local players = DL.require('fw/players')
local qbjobs = DL.require('fw/qbjobs')

local function qb()
    core = core or exports['qb-core']:GetCoreObject()
    return core
end

local function player(source)
    return qb().Functions.GetPlayer(source)
end

return {
    server = {
        citizenId = function(source)
            local p = player(source)
            return p and p.PlayerData.citizenid
        end,

        playerName = function(source)
            local info = (player(source) or {}).PlayerData
            info = info and info.charinfo
            return info and ('%s %s'):format(info.firstname, info.lastname)
        end,

        job = function(source)
            local p = player(source)
            local job = p and p.PlayerData.job
            return job and { name = job.name, grade = job.grade.level, label = job.label }
        end,

        gang = function(source)
            local p = player(source)
            local gang = p and p.PlayerData.gang
            return gang and gang.name ~= 'none' and { name = gang.name, grade = gang.grade.level, label = gang.label } or nil
        end,

        money = function(source, account)
            local p = player(source)
            return p and p.PlayerData.money[account]
        end,

        removeMoney = function(source, account, amount, reason)
            local p = player(source)
            return p ~= nil and p.Functions.RemoveMoney(account, amount, reason)
        end,

        searchCharacters = players.search,
        character = players.find,
        ownedVehicle = players.ownedVehicle,
        vehiclesOf = players.vehiclesOf,
        searchVehicles = players.searchVehicles,

        setJob = function(target, name, grade)
            local job = qb().Shared.Jobs[name]
            if not job then return false end
            local level = job.grades[tostring(grade)] and grade or 0
            local p = type(target) == 'number' and player(target) or qb().Functions.GetPlayerByCitizenId(target)
            if p then return p.Functions.SetJob(name, level) == true end
            -- Offline: the job column holds the whole job object.
            local info = job.grades[tostring(level)] or {}
            local data = { name = name, label = job.label, payment = info.payment or 0, onduty = job.defaultDuty == true, isboss = info.isboss == true, type = job.type, grade = { name = info.name, level = level } }
            return MySQL.update.await('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(data), target }) == 1
        end,

        jobs = function() return players.normalizeJobs(qb().Shared.Jobs) end,

        dutyCount = function(job)
            local count = 0
            for _, p in pairs(qb().Functions.GetQBPlayers()) do
                if p.PlayerData.job.name == job and p.PlayerData.job.onduty then count = count + 1 end
            end
            return count
        end,

        onDuty = function(source)
            local p = player(source)
            return p ~= nil and p.PlayerData.job.onduty == true
        end,

        -- Job and duty with one lookup, and the events that keep them current.
        jobState = function(source)
            local p = player(source)
            return p and qbjobs.state(p.PlayerData.job) or nil
        end,
        watchJobs = qbjobs.watch,

        addMoney = function(source, account, amount, reason)
            local p = player(source)
            return p ~= nil and p.Functions.AddMoney(account, amount, reason)
        end,

        isAdmin = function(source)
            return qb().Functions.HasPermission(source, 'admin')
        end,

        onLoaded = function(cb)
            AddEventHandler('QBCore:Server:PlayerLoaded', function(p) cb(p.PlayerData.source) end)
        end,

        onUnloaded = function(cb)
            AddEventHandler('QBCore:Server:OnPlayerUnload', cb)
        end,

        -- A duty toggle changes job.onduty, so it counts as a job change too. With watchJobs (fw/server.lua) this is not
        -- used: the watcher runs the callbacks after it wrote the new job.
        onJobChange = function(cb)
            AddEventHandler('QBCore:Server:OnJobUpdate', function(src) cb(src) end)
            AddEventHandler('QBCore:Server:SetDuty', function(src) cb(src) end)
        end,
        onMoneyChange = function(cb)
            AddEventHandler('QBCore:Server:OnMoneyChange', function(src) cb(src) end)
        end,

        registerUsable = function(item, cb)
            qb().Functions.CreateUseableItem(item, function(source, data) cb(source, data and data.slot) end)
            return true
        end,
    },

    client = {
        isLoggedIn = function() return LocalPlayer.state.isLoggedIn == true end,

        citizenId = function()
            local data = qb().Functions.GetPlayerData()
            return data and data.citizenid
        end,

        onLoaded = function(cb) RegisterNetEvent('QBCore:Client:OnPlayerLoaded', cb) end,
        onUnloaded = function(cb) RegisterNetEvent('QBCore:Client:OnPlayerUnload', cb) end,
    },
}
