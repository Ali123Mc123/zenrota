-- The framework: players (identifier, name, job with its duty, callsign), weapon labels and whether the player is down.
-- Each adapter is a do ... end block that adds itself to FRAMEWORKS; the detection at the end picks one.
local FRAMEWORKS = {}

-- qb-core and qbx_core share the player object (PlayerData, Functions).
local function qbLike(id, resource, core)
    local fw = { id = id, resource = resource }

    -- { name, label, grade, gradeLabel, onDuty } of a PlayerData.job.
    local function jobOf(j)
        if not j or not j.name then return nil end
        local grade = type(j.grade) == 'table' and (j.grade.level or j.grade.grade) or j.grade
        local gradeLabel = type(j.grade) == 'table' and j.grade.name or nil
        return { name = j.name, label = j.label or j.name, grade = tonumber(grade) or 0, gradeLabel = gradeLabel, onDuty = j.onduty ~= false, boss = j.isboss == true }
    end

    if Bridge.side == 'server' then
        local function player(source) return core().GetPlayer(source) end

        function fw.identifier(source)
            local p = player(source)
            return p and p.PlayerData.citizenid or nil
        end

        function fw.name(source)
            local p = player(source)
            local info = p and p.PlayerData.charinfo
            if not info then return GetPlayerName(source) end
            return ('%s %s'):format(info.firstname or '', info.lastname or ''):gsub('^%s+', ''):gsub('%s+$', '')
        end

        function fw.job(source)
            local p = player(source)
            return p and jobOf(p.PlayerData.job) or nil
        end

        -- The callsign qbx_police / qb-policejob keep in the metadata (/callsign).
        function fw.callsign(source)
            local p = player(source)
            local value = p and p.PlayerData.metadata and p.PlayerData.metadata.callsign
            return type(value) == 'string' and value ~= '' and value ~= 'NO CALLSIGN' and value or nil
        end

        -- The phone number on the character, for citizen calls and the staff list.
        function fw.phone(source)
            local p = player(source)
            local info = p and p.PlayerData.charinfo
            return info and info.phone and tostring(info.phone) or nil
        end

        -- The character's bank account number (the staff list).
        function fw.account(source)
            local p = player(source)
            local info = p and p.PlayerData.charinfo
            return info and info.account and tostring(info.account) or nil
        end

        function fw.isAdmin(source)
            return IsPlayerAceAllowed(source, 'command') or core().HasPermission(source, 'admin') == true
        end

        -- cb(source) when a player's job, duty or character changes.
        function fw.onChange(cb)
            AddEventHandler('QBCore:Server:OnJobUpdate', function(source) cb(source) end)
            AddEventHandler('QBCore:Server:SetDuty', function(source) cb(source) end)
            AddEventHandler('QBCore:Server:PlayerLoaded', function(p) cb(p and p.PlayerData and p.PlayerData.source) end)
            AddEventHandler('QBCore:Server:OnPlayerUnload', function(source) cb(source) end)
            -- qbx: a new callsign (/callsign) at once.
            AddEventHandler('qbx_core:server:onSetMetaData', function(key, _, _, source)
                if key == 'callsign' then cb(source) end
            end)
        end

        -- cb(source, job) when a player is taken out of a job (qbx: a group update without a grade).
        function fw.onLeaveJob(cb)
            AddEventHandler('qbx_core:server:onGroupUpdate', function(source, name, grade)
                if grade == nil then cb(source, name) end
            end)
        end
    else
        function fw.job()
            local data = core().GetPlayerData()
            return data and jobOf(data.job) or nil
        end

        function fw.onChange(cb)
            RegisterNetEvent('QBCore:Client:OnPlayerLoaded', cb)
            RegisterNetEvent('QBCore:Client:OnPlayerUnload', cb)
            RegisterNetEvent('QBCore:Client:OnJobUpdate', cb)
            RegisterNetEvent('QBCore:Client:SetDuty', cb)
        end

        -- The framework's name for a weapon hash ('Pistol .50'), or nil.
        function fw.weaponLabel(hash)
            local list = core().Weapons()
            local item = list and list[hash]
            return item and item.label or nil
        end

        -- Down: dead or in last stand.
        function fw.isDown()
            if Bridge.started('qbx_medical') then
                return exports.qbx_medical:IsDead() == true or exports.qbx_medical:IsLaststand() == true
            end
            local data = core().GetPlayerData()
            local meta = data and data.metadata
            if meta and (meta.isdead or meta.inlaststand) then return true end
            return IsEntityDead(PlayerPedId())
        end
    end

    return fw
end

-- qbx_core: its exports.
do
    local core = {
        GetPlayer = function(source) return exports.qbx_core:GetPlayer(source) end,
        HasPermission = function(source, perm) return exports.qbx_core:HasPermission(source, perm) end,
        GetPlayerData = function() return exports.qbx_core:GetPlayerData() end,
        Weapons = function() return exports.qbx_core:GetWeapons() end,
    }
    FRAMEWORKS[#FRAMEWORKS + 1] = qbLike('qbx', 'qbx_core', function() return core end)
end

-- qb-core: the core object's Functions and Shared.
do
    local object
    local function core()
        object = object or exports['qb-core']:GetCoreObject()
        return {
            GetPlayer = function(source) return object.Functions.GetPlayer(source) end,
            HasPermission = function(source, perm) return object.Functions.HasPermission(source, perm) end,
            GetPlayerData = function() return object.Functions.GetPlayerData() end,
            Weapons = function() return object.Shared and object.Shared.Weapons end,
        }
    end
    FRAMEWORKS[#FRAMEWORKS + 1] = qbLike('qb', 'qb-core', core)
end

-- es_extended: jobs have no duty flag of their own (onDuty unless the job name starts with off).
do
    local fw = { id = 'esx', resource = 'es_extended' }
    local object
    local function esx()
        object = object or exports.es_extended:getSharedObject()
        return object
    end

    local function jobOf(j)
        if not j or not j.name then return nil end
        local off = j.name:sub(1, 3) == 'off'
        return { name = off and j.name:sub(4) or j.name, label = j.label or j.name, grade = tonumber(j.grade) or 0, gradeLabel = j.grade_label, onDuty = not off and j.onDuty ~= false, boss = j.grade_name == 'boss' }
    end

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
            return p and jobOf(p.job) or nil
        end

        function fw.callsign() return nil end

        function fw.phone() return nil end

        function fw.account() return nil end

        function fw.isAdmin(source)
            local p = player(source)
            local group = p and p.getGroup and p.getGroup()
            return IsPlayerAceAllowed(source, 'command') or group == 'admin' or group == 'superadmin'
        end

        function fw.onChange(cb)
            AddEventHandler('esx:setJob', function(source) cb(source) end)
            AddEventHandler('esx:playerLoaded', function(source) cb(source) end)
        end
    else
        function fw.job()
            local data = esx().GetPlayerData()
            return data and jobOf(data.job) or nil
        end

        function fw.onChange(cb)
            RegisterNetEvent('esx:playerLoaded', cb)
            RegisterNetEvent('esx:setJob', cb)
        end

        function fw.weaponLabel(hash)
            for _, w in ipairs(esx().GetWeaponList and esx().GetWeaponList() or {}) do
                if joaat(w.name) == hash then return w.label end
            end
            return nil
        end

        function fw.isDown()
            return IsEntityDead(PlayerPedId())
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

-- Waits until a framework runs, at most ms.
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
