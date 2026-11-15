-- The framework: players (identifier, name, job, money) and where it keeps owned vehicles. Each adapter is a
-- do ... end block that adds itself to FRAMEWORKS; the detection at the end picks one.
local FRAMEWORKS = {}

-- qb-core and qbx_core share the player object (PlayerData, Functions) and the player_vehicles table.
local function qbLike(id, resource, core)
    local fw = { id = id, resource = resource, vehicles = 'player_vehicles', owner = 'citizenid', props = 'mods' }

    if Bridge.side == 'server' then
        local function player(source) return core().GetPlayer(source) end

        function fw.identifier(source)
            local p = player(source)
            return p and p.PlayerData.citizenid or nil
        end

        function fw.name(source)
            local p = player(source)
            local info = p and p.PlayerData.charinfo
            return info and ('%s %s'):format(info.firstname or '', info.lastname or ''):gsub('^%s+', ''):gsub('%s+$', '') or GetPlayerName(source)
        end

        function fw.job(source)
            local p = player(source)
            local j = p and p.PlayerData.job
            if not j or not j.name then return nil end
            local grade = type(j.grade) == 'table' and (j.grade.level or j.grade.grade) or j.grade
            return { name = j.name, grade = tonumber(grade) or 0, boss = j.isboss == true }
        end

        -- { bank, cash } the player holds.
        -- The player's gang (qb / qbx): { name, grade }.
        function fw.gang(source)
            local p = player(source)
            local g = p and p.PlayerData.gang
            if not g or not g.name or g.name == 'none' then return nil end
            local grade = type(g.grade) == 'table' and (g.grade.level or g.grade.grade) or g.grade
            return { name = g.name, grade = tonumber(grade) or 0 }
        end

        function fw.money(source)
            local p = player(source)
            local m = p and p.PlayerData.money or {}
            return { bank = tonumber(m.bank) or 0, cash = tonumber(m.cash) or 0 }
        end

        -- Takes money from an account (bank | cash); false when it is not there.
        function fw.pay(source, account, amount, reason)
            amount = Core.num(amount)
            if not amount then return false end
            local p = player(source)
            if not p then return false end
            if amount <= 0 then return true end
            if (tonumber(p.PlayerData.money[account]) or 0) < amount then return false end
            return p.Functions.RemoveMoney(account, amount, reason) == true
        end

        function fw.give(source, account, amount, reason)
            amount = Core.num(amount)
            local p = amount and amount > 0 and player(source)
            if p then p.Functions.AddMoney(account, amount, reason) end
        end

        -- Names of players by identifier (online or not): { [identifier] = name }.
        function fw.people(ids)
            local out = {}
            if #ids == 0 then return out end
            for _, r in ipairs(MySQL.query.await('SELECT citizenid, charinfo FROM players WHERE citizenid IN (?)', { ids }) or {}) do
                local c = Core.decode(r.charinfo)
                out[r.citizenid] = ('%s %s'):format(c.firstname or '', c.lastname or ''):gsub('^%s+', ''):gsub('%s+$', '')
            end
            return out
        end

        -- The server id of an online player; nil when they are offline.
        function fw.source(identifier)
            local p = core().GetPlayerByCitizenId(identifier)
            return p and p.PlayerData.source or nil
        end

        -- A job's ranks, lowest first: { grade, label, boss }.
        function fw.grades(job)
            local def = core().GetJob(job)
            local out = {}
            for g, r in pairs(def and def.grades or {}) do
                out[#out + 1] = { grade = tonumber(g) or 0, label = r.name or tostring(g), boss = r.isboss == true }
            end
            table.sort(out, function(a, b) return a.grade < b.grade end)
            return out
        end

        -- Everyone in a job, online or not: { id, name, grade }.
        local memberCache = {}
        function fw.members(job)
            local now = GetGameTimer()
            local cached = memberCache[job]
            if cached and now < cached.untilMs then
                local copy = {}
                for i, m in ipairs(cached.list) do copy[i] = { id = m.id, name = m.name, grade = m.grade } end
                return copy
            end
            local out = {}
            for _, r in ipairs(MySQL.query.await("SELECT citizenid, charinfo, job FROM players WHERE JSON_VALUE(job, '$.name') = ?", { job }) or {}) do
                local c, j = Core.decode(r.charinfo), Core.decode(r.job)
                local g = j.grade
                out[#out + 1] = {
                    id = r.citizenid, name = ('%s %s'):format(c.firstname or '', c.lastname or ''):gsub('^%s+', ''):gsub('%s+$', ''),
                    grade = type(g) == 'table' and (tonumber(g.level) or tonumber(g.grade) or 0) or tonumber(g) or 0,
                }
            end
            local copy = {}
            for i, m in ipairs(out) do copy[i] = { id = m.id, name = m.name, grade = m.grade } end
            memberCache[job] = { list = copy, untilMs = now + 30000 }
            return out
        end

        -- Sets a player's job (by identifier, online or not where the framework can); false when it could not.
        function fw.setJob(identifier, job, grade)
            memberCache = {}
            return core().SetJob(identifier, job, grade) ~= false
        end

        -- Takes bank money from an offline player in one conditional update; false when it is not there.
        function fw.payOffline(identifier, amount)
            return MySQL.update.await("UPDATE players SET money = JSON_SET(money, '$.bank', JSON_EXTRACT(money, '$.bank') - ?) WHERE citizenid = ? AND JSON_EXTRACT(money, '$.bank') + 0 >= ?",
                { amount, identifier, amount }) == 1
        end

        -- Writes a bought car: stored (in a garage) or out at the dealership; finance is jg's finance_data; society
        -- ({ name, kind = 'job' | 'gang' }) writes it to a job's or gang's name, as jg did.
        function fw.addVehicle(source, model, plate, props, stored, finance, society)
            local p = player(source)
            if society then
                local args = { p.PlayerData.license, society.name, model, tostring(joaat(model)), json.encode(props), plate, 0 }
                if not Bridge.column('player_vehicles', 'job_vehicle') then
                    return MySQL.insert.await('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', args) ~= nil
                end
                args[8], args[9] = society.kind == 'job' and 1 or 0, society.kind == 'gang' and 1 or 0
                return MySQL.insert.await('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, job_vehicle, gang_vehicle) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', args) ~= nil
            end
            return MySQL.insert.await(
                'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, financed, finance_data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                { p.PlayerData.license, p.PlayerData.citizenid, model, tostring(joaat(model)), json.encode(props), plate, stored and 1 or 0,
                  finance and 1 or 0, finance and json.encode(finance) or nil }
            ) ~= nil
        end
    end

    if Bridge.side == 'client' then
        -- The player's job name (for the desk prompt; the server checks again).
        function fw.job()
            local data = core().GetPlayerData and core().GetPlayerData() or {}
            return data.job and data.job.name or nil
        end
    end

    return fw
end

-- qbx_core: its exports.
do
    local core = {
        GetPlayer = function(source) return exports.qbx_core:GetPlayer(source) end,
        GetPlayerByCitizenId = function(id) return exports.qbx_core:GetPlayerByCitizenId(id) end,
        GetPlayerData = function() return exports.qbx_core:GetPlayerData() end,
        GetJob = function(name) return exports.qbx_core:GetJob(name) end,
        SetJob = function(identifier, job, grade) return exports.qbx_core:SetJob(identifier, job, grade) end,
    }
    FRAMEWORKS[#FRAMEWORKS + 1] = qbLike('qbx', 'qbx_core', function() return core end)
end

-- qb-core: the core object's Functions.
do
    local object
    local function core()
        object = object or exports['qb-core']:GetCoreObject()
        return {
            GetPlayer = function(source) return object.Functions.GetPlayer(source) end,
            GetPlayerByCitizenId = function(id) return object.Functions.GetPlayerByCitizenId(id) end,
            GetPlayerData = function() return object.Functions.GetPlayerData() end,
            GetJob = function(name) return object.Shared.Jobs[name] end,
            -- qb-core sets the job of an online player only
            SetJob = function(identifier, job, grade)
                local p = object.Functions.GetPlayerByCitizenId(identifier)
                return p and p.Functions.SetJob(job, grade) or false
            end,
        }
    end
    FRAMEWORKS[#FRAMEWORKS + 1] = qbLike('qb', 'qb-core', core)
end

-- es_extended: owned_vehicles keeps the props (with the model hash) in its vehicle column.
do
    local fw = { id = 'esx', resource = 'es_extended', vehicles = 'owned_vehicles', owner = 'owner', props = 'vehicle' }
    local object
    local function esx()
        object = object or exports.es_extended:getSharedObject()
        return object
    end
    local ACCOUNTS = { bank = 'bank', cash = 'money' }

    if Bridge.side == 'server' then
        local function player(source) return esx().GetPlayerFromId(source) end

        function fw.identifier(source)
            local p = player(source)
            return p and p.identifier or nil
        end

        function fw.name(source)
            local p = player(source)
            return p and p.getName() or GetPlayerName(source)
        end

        function fw.job(source)
            local p = player(source)
            local j = p and p.job
            return j and { name = j.name, grade = tonumber(j.grade) or 0, boss = j.grade_name == 'boss' } or nil
        end

        function fw.money(source)
            local p = player(source)
            local bank, cash = p and p.getAccount('bank'), p and p.getAccount('money')
            return { bank = bank and bank.money or 0, cash = cash and cash.money or 0 }
        end

        function fw.pay(source, account, amount, reason)
            amount = Core.num(amount)
            if not amount then return false end
            local p = player(source)
            if not p then return false end
            if amount <= 0 then return true end
            local held = p.getAccount(ACCOUNTS[account] or 'bank')
            if not held or held.money < amount then return false end
            p.removeAccountMoney(ACCOUNTS[account] or 'bank', amount, reason)
            return true
        end

        function fw.give(source, account, amount, reason)
            amount = Core.num(amount)
            local p = amount and amount > 0 and player(source)
            if p then p.addAccountMoney(ACCOUNTS[account] or 'bank', amount, reason) end
        end

        function fw.grades(job)
            local def = (esx().GetJobs() or {})[job]
            local out = {}
            for g, r in pairs(def and def.grades or {}) do
                out[#out + 1] = { grade = tonumber(g) or tonumber(r.grade) or 0, label = r.label or r.name or tostring(g), boss = r.name == 'boss' }
            end
            table.sort(out, function(a, b) return a.grade < b.grade end)
            return out
        end

        local memberCache = {}
        function fw.members(job)
            local now = GetGameTimer()
            local cached = memberCache[job]
            if cached and now < cached.untilMs then
                local copy = {}
                for i, m in ipairs(cached.list) do copy[i] = { id = m.id, name = m.name, grade = m.grade } end
                return copy
            end
            local out = {}
            for _, r in ipairs(MySQL.query.await('SELECT identifier, firstname, lastname, job_grade FROM users WHERE job = ?', { job }) or {}) do
                out[#out + 1] = { id = r.identifier, name = ('%s %s'):format(r.firstname or '', r.lastname or ''), grade = tonumber(r.job_grade) or 0 }
            end
            local copy = {}
            for i, m in ipairs(out) do copy[i] = { id = m.id, name = m.name, grade = m.grade } end
            memberCache[job] = { list = copy, untilMs = now + 30000 }
            return out
        end

        function fw.setJob(identifier, job, grade)
            memberCache = {}
            local p = esx().GetPlayerFromIdentifier(identifier)
            if p then
                p.setJob(job, grade)
                return true
            end
            return MySQL.update.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', { job, grade, identifier }) == 1
        end

        function fw.people(ids)
            local out = {}
            if #ids == 0 then return out end
            for _, r in ipairs(MySQL.query.await('SELECT identifier, firstname, lastname FROM users WHERE identifier IN (?)', { ids }) or {}) do
                out[r.identifier] = ('%s %s'):format(r.firstname or '', r.lastname or '')
            end
            return out
        end

        function fw.source(identifier)
            local p = esx().GetPlayerFromIdentifier(identifier)
            return p and p.source or nil
        end

        function fw.payOffline(identifier, amount)
            return MySQL.update.await("UPDATE users SET accounts = JSON_SET(accounts, '$.bank', JSON_EXTRACT(accounts, '$.bank') - ?) WHERE identifier = ? AND JSON_EXTRACT(accounts, '$.bank') + 0 >= ?",
                { amount, identifier, amount }) == 1
        end

        -- ESX garages tell cars, boats and aircraft apart by the type column.
        function fw.addVehicle(source, _, plate, props, stored, finance, _, garageType)
            local kind = garageType == 'sea' and 'boat' or garageType == 'air' and 'aircraft' or 'car'
            return MySQL.insert.await('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored, financed, finance_data) VALUES (?, ?, ?, ?, ?, ?, ?)',
                { fw.identifier(source), plate, json.encode(props), kind, stored and 1 or 0, finance and 1 or 0, finance and json.encode(finance) or nil }) ~= nil
        end
    end

    if Bridge.side == 'client' then
        function fw.job()
            local data = esx().GetPlayerData() or {}
            return data.job and data.job.name or nil
        end
    end

    FRAMEWORKS[#FRAMEWORKS + 1] = fw
end

-- Detection on first use (the framework may start after this resource): Config.Bridge.Framework, or the first that
-- runs.
do
    local mt = getmetatable(Bridge) or {}
    local index = mt.__index
    mt.__index = function(self, key)
        if key ~= 'fw' then return type(index) == 'function' and index(self, key) or nil end
        local chosen = Bridge.pick('Framework', FRAMEWORKS)
        if not chosen then
            Bridge.warn('no framework found (qbx_core, qb-core or es_extended); set Config.Bridge.Framework')
            chosen = FRAMEWORKS[1]
        end
        rawset(self, 'fw', chosen)
        return chosen
    end
    setmetatable(Bridge, mt)
end

-- Waits (server start) until a framework runs, at most ms.
function Bridge.awaitFramework(ms)
    local stop = GetGameTimer() + (ms or 30000)
    while GetGameTimer() < stop do
        for _, fw in ipairs(FRAMEWORKS) do
            if Bridge.started(fw.resource) then return true end
        end
        Wait(250)
    end
    return false
end
