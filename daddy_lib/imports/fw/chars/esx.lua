-- ESX characters: es_extended's multichar join and logout events; ids look like <prefix><slot>:<license hash>.
local shared = DL.require('chars/shared')
local phone = DL.require('fw/chars/phone')
local has = DL.require('fw/schema')

local IDENTITY = { 'firstname', 'lastname', 'dateofbirth', 'sex', 'height' }
local OPTIONAL = { 'firstname', 'lastname', 'dateofbirth', 'sex', 'height', 'phone_number', 'disabled', 'is_dead', 'metadata' }
local SCAN = "SELECT c.TABLE_NAME AS tbl, c.COLUMN_NAME AS col, c.CHARACTER_MAXIMUM_LENGTH AS size FROM information_schema.COLUMNS c"
    .. " JOIN information_schema.TABLES t ON t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME AND t.TABLE_TYPE = 'BASE TABLE'"
    .. " WHERE c.TABLE_SCHEMA = DATABASE() AND c.DATA_TYPE = 'varchar' AND c.COLUMN_NAME IN ('identifier', 'owner')"
    .. " AND c.TABLE_NAME NOT LIKE 'daddy\\_%'"

local LATE_MS = 1000

local core, scanned, watching
local late = {}

local function esx()
    core = core or exports.es_extended:getSharedObject()
    return core
end

local function query(sql, params)
    local ok, rows = pcall(MySQL.query.await, sql, params)
    return ok and rows or nil
end

-- Must match the Config.Prefix an earlier esx_multicharacter used.
local function prefix()
    local value = GetConvar('daddy:esx_char_prefix', 'char')
    return shared.safeName(value) and value or 'char'
end

local function dateOrder()
    return GetConvar('daddy:esx_dateformat', 'DMY')
end

local function multichar()
    local ok, on = pcall(function() return esx().GetConfig('Multichar') end)
    return ok and on == true
end

-- The license hash es_extended keys characters by (honours esx:identifier).
local function hash(source)
    local ok, id = pcall(esx().GetIdentifier, source)
    return ok and id or nil
end

local function citizenOf(source)
    local p = esx().GetPlayerFromId(source)
    return p and p.identifier
end

-- Runs start(done) and waits up to ms for done(value); false on timeout.
local function within(ms, start)
    local p, settled = promise.new(), false
    local function done(value)
        if settled then return end
        settled = true
        p:resolve(value)
    end
    SetTimeout(ms, function() done(false) end)
    start(done)
    return Citizen.Await(p)
end

-- es_extended saves the player, then calls back; a player who is already gone counts as unloaded.
local function unload(source)
    local ok = within(15000, function(done)
        TriggerEvent('esx:playerLogout', source, function() done(true) end)
    end)
    return ok or not citizenOf(source)
end

-- A load that lands after join gave up is undone once es_extended has told the client, so nobody stays half-loaded.
local function watchLate()
    if watching then return end
    watching = true
    AddEventHandler('esx:playerLoaded', function(id)
        id = tonumber(id)
        if not id or not late[id] then return end
        late[id] = nil
        local identifier = citizenOf(id)
        print(('^3[%s] chars: es_extended loaded player %d after the wait; logging them out^7'):format(DL.resource, id))
        SetTimeout(LATE_MS, function()
            if citizenOf(id) == identifier then unload(id) end
        end)
    end)
    AddEventHandler('playerDropped', function() late[source] = nil end)
end

-- es_extended creates (with data) or loads the character; true once exactly this character is loaded.
local function join(source, char, data)
    local handler
    late[source] = nil
    within(15000, function(done)
        handler = AddEventHandler('esx:playerLoaded', function(id)
            if tonumber(id) == source then done(true) end
        end)
        TriggerEvent('esx:onPlayerJoined', source, char, data)
    end)
    RemoveEventHandler(handler)
    local loaded = citizenOf(source)
    if loaded == char .. ':' .. tostring(hash(source)) then return true end
    if loaded then
        Wait(LATE_MS)
        unload(source)
    else
        watchLate()
        late[source] = true
    end
    return false
end

-- Identifier and owner columns of every table, ours excluded; scanned once unless fresh.
local function targets(fresh)
    if scanned and not fresh then return scanned end
    local rows = query(SCAN)
    if not rows then return nil end
    scanned = { { tbl = 'users', col = 'identifier', size = 60 } }
    for _, row in ipairs(rows) do
        local known = row.tbl == 'users' and row.col == 'identifier'
        if known then scanned[1].size = row.size end
        if not known and shared.safeName(row.tbl) and shared.safeName(row.col) then scanned[#scanned + 1] = row end
    end
    return scanned
end

local function columns()
    local list = { '`identifier`', '`accounts`', '`job`', '`job_grade`', '`position`' }
    for _, name in ipairs(OPTIONAL) do
        if has('users', name) then list[#list + 1] = ('`%s`'):format(name) end
    end
    if has('users', 'last_seen') then list[#list + 1] = 'UNIX_TIMESTAMP(`last_seen`) AS seen' end
    return table.concat(list, ', ')
end

local function jobOf(jobs, name, grade)
    local def = jobs[name] or {}
    local level = (def.grades or {})[tostring(grade)] or {}
    return { name = name or 'unemployed', label = def.label or name, grade = tonumber(grade) or 0, gradeLabel = level.label }
end

local function row(raw, jobs, numbers)
    local id, accounts = raw.identifier, DL.util.decodeJson(raw.accounts)
    return {
        citizenid = id, slot = shared.slotOf(id, prefix()), owner = id:match(':(.+)$'),
        firstname = raw.firstname, lastname = raw.lastname, birthdate = shared.isoDate(raw.dateofbirth, dateOrder()),
        gender = shared.gender(raw.sex), height = tonumber(raw.height),
        phone = phone.pick(numbers, id, raw.phone_number),
        cash = tonumber(accounts.money) or 0, bank = tonumber(accounts.bank) or 0,
        job = jobOf(jobs, raw.job, raw.job_grade),
        position = shared.vec4(DL.util.decodeJson(raw.position)), lastSeen = tonumber(raw.seen),
        flags = { dead = DL.util.flag(raw.is_dead), jailed = false, disabled = DL.util.flag(raw.disabled) },
        raw = { metadata = DL.util.decodeJson(raw.metadata) },
    }
end

-- Rows of this prefix only, ordered by slot.
local function rowsOf(list)
    local ok, jobs = pcall(esx().GetJobs)
    local ids, out = {}, {}
    for i, raw in ipairs(list) do ids[i] = raw.identifier end
    local numbers = phone.lookup(ids)
    for _, raw in ipairs(list) do
        local character = row(raw, ok and jobs or {}, numbers)
        if character.slot then out[#out + 1] = character end
    end
    table.sort(out, function(a, b) return a.slot < b.slot end)
    return out
end

-- The shortest identifier/owner column; a longer character id would be cut there.
local function narrowest()
    local size = math.huge
    for _, target in ipairs(targets() or {}) do size = math.min(size, tonumber(target.size) or size) end
    return size
end

-- A started resource with this exact name. The name resolves to a provider when the real one is stopped, so its folder must match.
local function realStarted(name)
    for i = 0, GetNumResources() - 1 do
        if GetResourceByFindIndex(i) == name then
            local folder = tostring(GetResourcePath(name) or ''):match('([^/\\]+)[/\\]*$')
            return GetResourceState(name) == 'started' and folder == name
        end
    end
    return false
end

return {
    server = {
        caps = { nationality = false, height = true, bio = false, phone = true, gang = false },

        owners = function(source)
            local owner = hash(source)
            return owner and { owner } or {}
        end,

        list = function(owners)
            local where, params = {}, {}
            for _, owner in ipairs(owners) do
                where[#where + 1] = 'identifier LIKE ?'
                params[#params + 1] = shared.likeEscape(prefix()) .. '%:' .. shared.likeEscape(owner)
            end
            local rows = query(('SELECT %s FROM users WHERE %s'):format(columns(), table.concat(where, ' OR ')), params)
            if not rows then return nil, 'failed' end
            return rowsOf(rows)
        end,

        get = function(citizenid)
            local rows = query(('SELECT %s FROM users WHERE identifier = ?'):format(columns()), { citizenid })
            return rows and rows[1] and rowsOf({ rows[1] })[1] or nil
        end,

        owner = function(citizenid)
            if not shared.slotOf(citizenid, prefix()) then return nil end
            local rows = query('SELECT 1 AS found FROM users WHERE identifier = ?', { citizenid })
            return rows and rows[1] and citizenid:match(':(.+)$') or nil
        end,

        loaded = citizenOf,

        -- es_extended inserts the esx_identity columns and gives its own starting money and items.
        create = function(source, slot, identity)
            if not multichar() then return nil, 'mode' end
            if citizenOf(source) then return nil, 'loaded' end
            local owner = hash(source)
            if not owner then return nil, 'failed' end
            local char = prefix() .. slot
            if #char + 1 + #owner > narrowest() then return nil, 'too_long' end
            local taken = query('SELECT 1 AS found FROM users WHERE identifier = ?', { char .. ':' .. owner })
            if not taken then return nil, 'failed' end
            if taken[1] then return nil, 'slot_taken' end
            local data = {
                firstname = shared.cut(identity.firstname, 16), lastname = shared.cut(identity.lastname, 16),
                dateofbirth = shared.formatDate(identity.birthdate, dateOrder()), sex = identity.gender, height = identity.height,
            }
            if not join(source, char, data) then return nil, 'timeout' end
            return char .. ':' .. owner
        end,

        login = function(source, citizenid)
            if not multichar() then return nil, 'mode' end
            if citizenOf(source) then return nil, 'loaded' end
            local slot = shared.slotOf(citizenid, prefix())
            if not slot then return nil, 'failed' end
            if not join(source, prefix() .. slot) then return nil, 'timeout' end
            return true
        end,

        logout = function(source)
            if unload(source) then return true end
            return nil, 'timeout'
        end,

        -- Every identifier/owner column, as esx_multicharacter does, plus the caller's tables in one transaction.
        delete = function(citizenid, extra)
            local list = targets()
            if not list then return nil, 'failed' end
            local queries = {}
            for _, target in ipairs(list) do
                queries[#queries + 1] = { query = ('DELETE FROM `%s` WHERE `%s` = ?'):format(target.tbl, target.col), values = { citizenid } }
            end
            for _, extraQuery in ipairs(extra) do queries[#queries + 1] = extraQuery end
            local ok, done = pcall(MySQL.transaction.await, queries)
            if ok and done then return true end
            return nil, 'failed'
        end,

        -- esx_policejob keeps cuffs in a client local; a state bag set by another script is only a hint.
        status = function(source)
            local state = Player(source).state
            return { cuffed = (state.handcuffed or state.isHandcuffed) and true or nil }
        end,

        vehicle = function(citizenid, pick)
            if not has('owned_vehicles') then return nil end
            local filter = has('owned_vehicles', 'type') and " AND `type` = 'car'" or ''
            local rows = query('SELECT plate, vehicle FROM owned_vehicles WHERE owner = ?' .. filter .. ' LIMIT 50', { citizenid }) or {}
            local found = rows[pick == 'first' and 1 or #rows]
            local props = found and DL.util.decodeJson(found.vehicle) or {}
            if not props.model then return nil end
            return { model = props.model, props = props, plate = found.plate }
        end,

        conflicts = function(opts)
            local out = {}
            local function add(level, code, text) out[#out + 1] = { level = level, code = code, text = text } end
            if not multichar() then
                add('error', 'esx_multichar_off', "es_extended runs without Config.Multichar: keep provide 'esx_multicharacter' in the product manifest, or set Config.Multichar = true in es_extended/shared/config/main.lua")
            end
            if realStarted('esx_multicharacter') then
                add('error', 'esx_multicharacter', 'esx_multicharacter is running and opens its own selection: stop it and remove it from server.cfg')
            end
            local missing = {}
            for _, column in ipairs(IDENTITY) do
                if not has('users', column) then missing[#missing + 1] = column end
            end
            if #missing > 0 then
                add('error', 'esx_identity_columns', ('users has no %s column: import esx_identity.sql'):format(table.concat(missing, ', ')))
            end
            local size = 41 + #prefix() + #tostring(math.max(9, math.floor(tonumber(opts and opts.slots) or 9)))
            for _, target in ipairs(targets(true) or {}) do
                if (tonumber(target.size) or size) < size then
                    add('warn', 'esx_short_column', ('%s.%s is too short for character ids: ALTER TABLE `%s` MODIFY COLUMN `%s` VARCHAR(%d);'):format(target.tbl, target.col, target.tbl, target.col, size))
                end
            end
            return out
        end,
    },

    client = {
        boot = function()
            pcall(function() esx().DisableSpawnManager() end)
        end,

        -- esx_identity and others wait for this event before they show anything.
        closeLoadingScreen = function()
            TriggerEvent('esx:loadingScreenOff')
        end,

        -- es_extended saves a player only after esx:onPlayerSpawn reached the server.
        spawned = function()
            TriggerServerEvent('esx:onPlayerSpawn')
            TriggerEvent('esx:onPlayerSpawn')
            TriggerEvent('esx:restoreLoadout')
        end,

        handoff = function() return false end,

        conflicts = function()
            if multichar() then return {} end
            return { { level = 'error', code = 'esx_multichar_off', text = 'es_extended on this client runs without Config.Multichar, so it spawns players by itself' } }
        end,
    },
}
