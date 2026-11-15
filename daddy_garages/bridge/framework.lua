-- The framework: players (identifier, name, job, gang, money, admin) and where it keeps owned vehicles.
-- Each adapter is a do ... end block that adds itself to FRAMEWORKS; the detection at the end picks one.
local FRAMEWORKS = {}

-- qb-core and qbx_core share the player object (PlayerData, Functions) and the player_vehicles table.
local function qbLike(id, resource, core)
    local fw = { id = id, resource = resource }

    -- The vehicle table and the columns Garages reads and writes (missing ones are skipped). mileage is the column
    -- jg-vehiclemileage keeps (km); depotprice the impound fee other scripts read.
    fw.vehicles = {
        table = 'player_vehicles', owner = 'citizenid', model = 'vehicle', props = 'mods', fuel = 'fuel', engine = 'engine',
        body = 'body', state = 'state', stateIn = 1, stateOut = 0, stateImpound = 2, garage = 'garage', km = 'mileage',
        fakeplate = 'fakeplate', depot = 'depotprice',
    }

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

        -- { name, grade, boss } of the job or gang, or nil.
        local function group(source, key)
            local p = player(source)
            local g = p and p.PlayerData[key]
            if not g or not g.name then return nil end
            local grade = type(g.grade) == 'table' and (g.grade.level or g.grade.grade) or g.grade
            return { name = g.name, grade = tonumber(grade) or 0, boss = g.isboss == true, type = g.type }
        end

        function fw.job(source) return group(source, 'job') end

        function fw.gang(source) return group(source, 'gang') end

        -- Takes money from the account (bank | cash); false when it is not there.
        function fw.pay(source, amount, reason)
            amount = Core.num(amount)
            if not amount then return false end
            local p = player(source)
            if not p then return false end
            if amount <= 0 then return true end
            local account = Config.Fees.Account == 'cash' and 'cash' or 'bank'
            -- qbx lets the bank go below zero: without this check a buyer pays money they do not have
            if (tonumber(p.PlayerData.money[account]) or 0) < amount then return false end
            return p.Functions.RemoveMoney(account, amount, reason) == true
        end

        function fw.give(source, amount, reason)
            amount = Core.num(amount)
            local p = amount and amount > 0 and player(source)
            if p then p.Functions.AddMoney(Config.Fees.Account == 'cash' and 'cash' or 'bank', amount, reason) end
        end

        function fw.sourceOf(identifier)
            local p = core().GetPlayerByCitizenId(identifier)
            return p and p.PlayerData.source or nil
        end

        function fw.isAdmin(source)
            return IsPlayerAceAllowed(source, 'command') or core().HasPermission(source, 'admin') == true or core().HasPermission(source, 'god') == true
        end

        -- A character's name, online or not.
        local nameCache = {}
        function fw.nameOf(identifier)
            if not identifier then return '' end
            local online = fw.sourceOf(identifier)
            if online then
                local n = fw.name(online)
                nameCache[identifier] = n
                return n
            end
            if nameCache[identifier] then return nameCache[identifier] end
            local info = Core.decode(MySQL.scalar.await('SELECT charinfo FROM players WHERE citizenid = ?', { identifier }))
            local n = info.firstname and ('%s %s'):format(info.firstname, info.lastname or '') or identifier
            nameCache[identifier] = n
            return n
        end

        -- The stored model name of a row.
        function fw.modelOf(row) return row.vehicle end
    else
        function fw.identifier()
            local data = core().GetPlayerData()
            return data and data.citizenid or nil
        end

        local function group(key)
            local data = core().GetPlayerData()
            local g = data and data[key]
            if not g or not g.name then return nil end
            local grade = type(g.grade) == 'table' and (g.grade.level or g.grade.grade) or g.grade
            return { name = g.name, grade = tonumber(grade) or 0, boss = g.isboss == true }
        end

        function fw.job() return group('job') end

        function fw.gang() return group('gang') end

        -- cb() when the character loads or its job / gang changes.
        function fw.onChange(cb)
            RegisterNetEvent('QBCore:Client:OnPlayerLoaded', cb)
            RegisterNetEvent('QBCore:Client:OnJobUpdate', cb)
            RegisterNetEvent('QBCore:Client:OnGangUpdate', cb)
        end
    end

    return fw
end

-- qbx_core: its exports; GetPlayerData on the client.
do
    local core = {
        GetPlayer = function(source) return exports.qbx_core:GetPlayer(source) end,
        GetPlayerByCitizenId = function(id) return exports.qbx_core:GetPlayerByCitizenId(id) end,
        HasPermission = function(source, perm) return exports.qbx_core:HasPermission(source, perm) end,
        GetPlayerData = function() return exports.qbx_core:GetPlayerData() end,
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
            HasPermission = function(source, perm) return object.Functions.HasPermission(source, perm) end,
            GetPlayerData = function() return object.Functions.GetPlayerData() end,
        }
    end
    FRAMEWORKS[#FRAMEWORKS + 1] = qbLike('qb', 'qb-core', core)
end

-- es_extended: owned_vehicles keeps the props (with the model hash) in its vehicle column.
do
    local fw = { id = 'esx', resource = 'es_extended' }
    local object
    local function esx()
        object = object or exports.es_extended:getSharedObject()
        return object
    end

    fw.vehicles = {
        table = 'owned_vehicles', owner = 'owner', model = nil, props = 'vehicle', fuel = nil, engine = nil, body = nil,
        state = 'stored', stateIn = 1, stateOut = 0, stateImpound = 0, garage = 'parking', km = 'mileage', fakeplate = nil,
    }

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

        -- ESX has no gangs of its own.
        function fw.gang() return nil end

        function fw.pay(source, amount, reason)
            amount = Core.num(amount)
            if not amount then return false end
            local p = player(source)
            if not p then return false end
            if amount <= 0 then return true end
            local account = Config.Fees.Account == 'cash' and 'money' or 'bank'
            local held = p.getAccount(account)
            if not held or held.money < amount then return false end
            p.removeAccountMoney(account, amount, reason)
            return true
        end

        function fw.give(source, amount, reason)
            amount = Core.num(amount)
            local p = amount and amount > 0 and player(source)
            if p then p.addAccountMoney(Config.Fees.Account == 'cash' and 'money' or 'bank', amount, reason) end
        end

        function fw.sourceOf(identifier)
            local p = esx().GetPlayerFromIdentifier(identifier)
            return p and p.source or nil
        end

        function fw.isAdmin(source)
            local p = player(source)
            local group = p and p.getGroup and p.getGroup()
            return IsPlayerAceAllowed(source, 'command') or group == 'admin' or group == 'superadmin'
        end

        local nameCache = {}
        function fw.nameOf(identifier)
            if not identifier then return '' end
            local online = fw.sourceOf(identifier)
            if online then
                local n = fw.name(online)
                nameCache[identifier] = n
                return n
            end
            if nameCache[identifier] then return nameCache[identifier] end
            local row = MySQL.single.await('SELECT firstname, lastname FROM users WHERE identifier = ?', { identifier })
            local n = row and ('%s %s'):format(row.firstname or '', row.lastname or '') or identifier
            nameCache[identifier] = n
            return n
        end

        -- ESX stores only the props; their model is a hash.
        function fw.modelOf(row)
            local props = Core.decode(row.vehicle)
            return props.model
        end
    else
        function fw.identifier()
            local data = esx().GetPlayerData()
            return data and data.identifier or nil
        end

        function fw.job()
            local data = esx().GetPlayerData()
            local j = data and data.job
            return j and { name = j.name, grade = tonumber(j.grade) or 0, boss = j.grade_name == 'boss' } or nil
        end

        function fw.gang() return nil end

        function fw.onChange(cb)
            RegisterNetEvent('esx:playerLoaded', cb)
            RegisterNetEvent('esx:setJob', cb)
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

-- A model's entry in the framework vehicle list (Qbox, qb-core), or nil when it does not know it.
local qbVehicles
local function listEntry(model)
    if type(model) ~= 'string' then return nil end
    local ok, v = pcall(function()
        if Bridge.started('qbx_core') then return exports.qbx_core:GetVehiclesByName(model) end
        if Bridge.started('qb-core') then
            qbVehicles = qbVehicles or exports['qb-core']:GetCoreObject().Shared.Vehicles
            return qbVehicles[model]
        end
    end)
    return ok and type(v) == 'table' and v or nil
end

-- Brand and name for logs, or nil.
function Bridge.vehicleLabel(model)
    local v = listEntry(model)
    return v and v.name and (('%s %s'):format(v.brand or '', v.name):gsub('^%s+', '')) or nil
end
