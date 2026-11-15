-- Framework bridge: players, jobs, money and owned cars. Change it to fit your server.

Bridge = { server = IsDuplicityVersion() }

function Bridge.started(resource)
    return GetResourceState(resource) == 'started'
end

local function qbLike(resource, core)
    local fw = { resource = resource, table = 'player_vehicles', owner = 'citizenid', props = 'mods' }

    local function player(source) return core().GetPlayer(source) end

    function fw.identifier(source)
        local p = player(source)
        return p and p.PlayerData.citizenid
    end

    function fw.name(source)
        local p = player(source)
        local info = p and p.PlayerData.charinfo
        return info and ('%s %s'):format(info.firstname, info.lastname) or GetPlayerName(source)
    end

    function fw.nameOf(id)
        local info = Core.decode(MySQL.scalar.await('SELECT charinfo FROM players WHERE citizenid = ?', { id }))
        return info.firstname and ('%s %s'):format(info.firstname, info.lastname) or id
    end

    function fw.job(source)
        local j = player(source) and player(source).PlayerData.job
        if not j then return nil end
        local grade = type(j.grade) == 'table' and j.grade.level or j.grade
        return { name = j.name, grade = tonumber(grade) or 0, duty = j.onduty == true, boss = j.isboss == true }
    end

    function fw.hasJob(source, name)
        local p = player(source)
        local d = p and p.PlayerData
        if not d then return false end
        return (d.job and d.job.name == name) or (type(d.jobs) == 'table' and d.jobs[name] ~= nil)
    end

    function fw.balance(source, account)
        local p = player(source)
        return p and p.PlayerData.money[account] or 0
    end

    function fw.pay(source, amount, account)
        local p = player(source)
        return p ~= nil and p.Functions.RemoveMoney(account, amount, 'mechanic') == true
    end

    function fw.give(source, amount, account)
        local p = player(source)
        if p then p.Functions.AddMoney(account, amount, 'mechanic') end
    end

    function fw.grades(job)
        local list = resource == 'qbx_core' and (exports.qbx_core:GetJob(job) or {}).grades or (exports['qb-core']:GetCoreObject().Shared.Jobs[job] or {}).grades
        local out = {}
        for grade, g in pairs(list or {}) do out[#out + 1] = { grade = tonumber(grade), label = g.name, boss = g.isboss == true } end
        table.sort(out, function(a, b) return a.grade < b.grade end)
        return out
    end

    function fw.staff(job)
        local out = {}
        if resource == 'qbx_core' then
            for _, m in ipairs(exports.qbx_core:GetGroupMembers(job, 'job') or {}) do out[#out + 1] = { id = m.citizenid, grade = tonumber(m.grade) or 0 } end
        else
            local rows = MySQL.query.await("SELECT citizenid, job FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(job, '$.name')) = ?", { job }) or {}
            for _, r in ipairs(rows) do
                local j = json.decode(r.job) or {}
                out[#out + 1] = { id = r.citizenid, grade = tonumber(type(j.grade) == 'table' and j.grade.level or j.grade) or 0 }
            end
        end
        local kept = {}
        for _, m in ipairs(out) do
            local row = MySQL.single.await("SELECT charinfo, JSON_UNQUOTE(JSON_EXTRACT(job, '$.name')) AS job FROM players WHERE citizenid = ?", { m.id }) or {}
            local online = resource == 'qbx_core' and exports.qbx_core:GetPlayerByCitizenId(m.id)
            -- Fired elsewhere with only the main job set to unemployed: the left-over group row is not staff.
            if not (resource == 'qbx_core' and (online and online.PlayerData.job.name or row.job) == 'unemployed') then
                local info = json.decode(row.charinfo or '{}') or {}
                m.name = info.firstname and ('%s %s'):format(info.firstname, info.lastname) or m.id
                kept[#kept + 1] = m
            end
        end
        return kept
    end

    function fw.setJob(id, job, grade)
        if resource == 'qbx_core' then
            if grade then
                local added, has = pcall(exports.qbx_core.AddPlayerToJob, exports.qbx_core, id, job, grade)
                if not added or has == false then return false end
                local set, primary = pcall(exports.qbx_core.SetPlayerPrimaryJob, exports.qbx_core, id, job)
                return set and primary ~= false
            end
            local removed, gone = pcall(exports.qbx_core.RemovePlayerFromJob, exports.qbx_core, id, job)
            return removed and gone ~= false
        end
        local core = exports['qb-core']:GetCoreObject()
        local p = core.Functions.GetPlayerByCitizenId(id)
        if p then return p.Functions.SetJob(grade and job or 'unemployed', grade or 0) end
        local name = grade and job or 'unemployed'
        local def = core.Shared.Jobs[name]
        local g = def and def.grades[tostring(grade or 0)] or {}
        local data = { name = name, label = def and def.label or name, onduty = false, payment = g.payment or 0, isboss = g.isboss == true,
            grade = { name = g.name or '', level = grade or 0 } }
        return MySQL.update.await('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(data), id }) == 1
    end

    return fw
end

local ADAPTERS = {
    qbx = qbLike('qbx_core', function()
        return { GetPlayer = function(source) return exports.qbx_core:GetPlayer(source) end }
    end),
    qb = qbLike('qb-core', function()
        return exports['qb-core']:GetCoreObject().Functions
    end),
}

ADAPTERS.esx = (function()
    local fw = { resource = 'es_extended', table = 'owned_vehicles', owner = 'owner', props = 'vehicle' }
    local function player(source) return exports.es_extended:getSharedObject().GetPlayerFromId(source) end
    local ACCOUNT = { cash = 'money', bank = 'bank' }

    function fw.identifier(source)
        local p = player(source)
        return p and p.identifier
    end

    function fw.name(source)
        local p = player(source)
        return p and p.getName() or GetPlayerName(source)
    end

    function fw.nameOf(id)
        local r = MySQL.single.await('SELECT firstname, lastname FROM users WHERE identifier = ?', { id })
        return r and r.firstname and ('%s %s'):format(r.firstname, r.lastname) or id
    end

    function fw.job(source)
        local j = player(source) and player(source).job
        return j and { name = j.name, grade = tonumber(j.grade) or 0, duty = j.onDuty ~= false, boss = j.grade_name == 'boss' }
    end

    function fw.hasJob(source, name)
        local j = fw.job(source)
        return j ~= nil and j.name == name
    end

    function fw.balance(source, account)
        local p = player(source)
        local held = p and p.getAccount(ACCOUNT[account])
        return held and held.money or 0
    end

    function fw.pay(source, amount, account)
        if fw.balance(source, account) < amount then return false end
        player(source).removeAccountMoney(ACCOUNT[account], amount, 'mechanic')
        return true
    end

    function fw.give(source, amount, account)
        local p = player(source)
        if p then p.addAccountMoney(ACCOUNT[account], amount, 'mechanic') end
    end

    function fw.grades(job)
        local out = {}
        for _, g in ipairs(MySQL.query.await('SELECT grade, label, name FROM job_grades WHERE job_name = ? ORDER BY grade', { job }) or {}) do
            out[#out + 1] = { grade = g.grade, label = g.label, boss = g.name == 'boss' }
        end
        return out
    end

    function fw.staff(job)
        local out = {}
        for _, r in ipairs(MySQL.query.await('SELECT identifier, firstname, lastname, job_grade FROM users WHERE job = ?', { job }) or {}) do
            out[#out + 1] = { id = r.identifier, name = ('%s %s'):format(r.firstname or '', r.lastname or ''), grade = r.job_grade }
        end
        return out
    end

    function fw.setJob(id, job, grade)
        local p = exports.es_extended:getSharedObject().GetPlayerFromIdentifier(id)
        if p then
            p.setJob(grade and job or 'unemployed', grade or 0)
            return true
        end
        return MySQL.update.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', { grade and job or 'unemployed', grade or 0, id }) == 1
    end

    return fw
end)()

setmetatable(Bridge, {
    __index = function(self, key)
        if key ~= 'fw' then return nil end
        local fw = ADAPTERS[Config.Framework]
        for _, id in ipairs({ 'qbx', 'qb', 'esx' }) do
            if fw then break end
            if Bridge.started(ADAPTERS[id].resource) then fw = ADAPTERS[id] end
        end
        rawset(self, 'fw', fw or ADAPTERS.qbx)
        return self.fw
    end,
})

function Bridge.notify(source, text, kind)
    if Bridge.server then return TriggerClientEvent('daddy_mechanic:notify', source, text, kind) end
    if Config.Notify == 'qb' then return TriggerEvent('QBCore:Notify', text, kind == 'info' and 'primary' or kind) end
    if Config.Notify == 'esx' then return TriggerEvent('esx:showNotification', text) end
    lib.notify({ description = text, type = kind == 'info' and 'inform' or kind })
end
