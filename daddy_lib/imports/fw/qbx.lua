local players = DL.require('fw/players')
local qbjobs = DL.require('fw/qbjobs')

local function player(source)
    return exports.qbx_core:GetPlayer(source)
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
            return exports.qbx_core:GetMoney(source, account)
        end,

        removeMoney = function(source, account, amount, reason)
            return exports.qbx_core:RemoveMoney(source, account, amount, reason)
        end,

        searchCharacters = players.search,
        character = players.find,
        ownedVehicle = players.ownedVehicle,
        vehiclesOf = players.vehiclesOf,
        searchVehicles = players.searchVehicles,

        -- Source or citizen id; qbx handles offline characters itself.
        setJob = function(target, name, grade)
            local job = exports.qbx_core:GetJob(name)
            if not job then return false end
            local grades = job.grades or {}
            if not (grades[grade] or grades[tostring(grade)]) then
                grade = nil
                for level in pairs(grades) do
                    level = tonumber(level)
                    if level and (not grade or level < grade) then grade = level end
                end
                if not grade then return false end
            end
            pcall(function() exports.qbx_core:SetJob(target, name, grade) end)
            local cid = target
            if type(target) == 'number' then
                local p = player(target)
                cid = p and p.PlayerData.citizenid
            end
            if not cid then return false end
            local current = type(target) == 'number' and player(target) or exports.qbx_core:GetPlayerByCitizenId(cid) or exports.qbx_core:GetOfflinePlayer(cid)
            if current and current.PlayerData.job.name == name then return true end
            -- Some qbx versions add the job but keep the old primary one.
            pcall(function()
                exports.qbx_core:AddPlayerToJob(cid, name, grade)
                exports.qbx_core:SetPlayerPrimaryJob(cid, name)
            end)
            current = type(target) == 'number' and player(target) or exports.qbx_core:GetOfflinePlayer(cid)
            return current ~= nil and current.PlayerData.job.name == name
        end,

        jobs = function() return players.normalizeJobs(exports.qbx_core:GetJobs()) end,
        dutyCount = function(job) return exports.qbx_core:GetDutyCountJob(job) end,

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
            return exports.qbx_core:AddMoney(source, account, amount, reason)
        end,

        isAdmin = function(source)
            return exports.qbx_core:HasPermission(source, 'admin')
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

        registerUsable = function() return false end,
    },

    client = {
        isLoggedIn = function() return LocalPlayer.state.isLoggedIn == true end,

        citizenId = function()
            local data = exports.qbx_core:GetPlayerData()
            return data and data.citizenid
        end,

        onLoaded = function(cb) RegisterNetEvent('QBCore:Client:OnPlayerLoaded', cb) end,
        onUnloaded = function(cb) RegisterNetEvent('qbx_core:client:playerLoggedOut', cb) end,
    },
}
