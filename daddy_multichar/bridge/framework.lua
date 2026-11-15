-- Pure helpers the framework adapters share: gender, dates, slots, positions and safe SQL names. No natives.
do
    local helpers = {}

    local GENDER = { [0] = 'm', [1] = 'f', ['0'] = 'm', ['1'] = 'f', m = 'm', f = 'f', M = 'm', F = 'f' }
    -- Where year, month and day sit in a date written in each order.
    local ORDERS = { YMD = { 1, 2, 3 }, DMY = { 3, 2, 1 }, MDY = { 3, 1, 2 } }
    local DAYS = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

    -- 'm' or 'f' from 0/1, '0'/'1' or 'm'/'f'; nil for anything else.
    function helpers.gender(value)
        return GENDER[value]
    end

    local function daysIn(year, month)
        if month == 2 and year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0) then return 29 end
        return DAYS[month]
    end

    -- 'YYYY-MM-DD' from a date in the given order (a four-digit year first is always YMD), or nil when it cannot exist.
    function helpers.isoDate(text, order)
        if type(text) ~= 'string' then return nil end
        local a, b, c = text:match('^%s*(%d+)[-/.](%d+)[-/.](%d+)%s*$')
        if not a then return nil end
        local parts = { tonumber(a), tonumber(b), tonumber(c) }
        local at = #a == 4 and ORDERS.YMD or ORDERS[order or 'YMD'] or ORDERS.YMD
        local year, month, day = parts[at[1]], parts[at[2]], parts[at[3]]
        if year < 1000 or year > 9999 or month < 1 or month > 12 or day < 1 or day > daysIn(year, month) then return nil end
        return ('%04d-%02d-%02d'):format(year, month, day)
    end

    -- An ISO date written in another order with slashes, as esx_identity stores it.
    function helpers.formatDate(iso, order)
        local year, month, day = tostring(iso or ''):match('^(%d%d%d%d)-(%d%d)-(%d%d)$')
        if not year then return nil end
        if order == 'DMY' then return ('%s/%s/%s'):format(day, month, year) end
        if order == 'MDY' then return ('%s/%s/%s'):format(month, day, year) end
        return ('%s/%s/%s'):format(year, month, day)
    end

    -- Slot of a prefixed identifier: slotOf('char3:abc', 'char') is 3.
    function helpers.slotOf(identifier, prefix)
        if type(identifier) ~= 'string' or type(prefix) ~= 'string' then return nil end
        if identifier:sub(1, #prefix) ~= prefix then return nil end
        return tonumber(identifier:sub(#prefix + 1):match('^(%d+):'))
    end

    -- The lowest slot none of the rows uses.
    function helpers.freeSlot(rows)
        local used = {}
        for _, row in ipairs(rows or {}) do
            if row.slot then used[row.slot] = true end
        end
        local slot = 1
        while used[slot] do slot = slot + 1 end
        return slot
    end

    local function point(x, y, z, w)
        if vector4 then return vector4(x, y, z, w) end
        return { x = x, y = y, z = z, w = w }
    end

    -- A vector4 from a vector or a { x, y, z } table with w, a or heading; nil without coordinates.
    function helpers.vec4(pos)
        local kind = type(pos)
        if kind == 'vector4' then return pos end
        if kind == 'vector3' then return point(pos.x, pos.y, pos.z, 0.0) end
        if kind ~= 'table' then return nil end
        local x, y, z = tonumber(pos.x or pos[1]), tonumber(pos.y or pos[2]), tonumber(pos.z or pos[3])
        if not (x and y and z) then return nil end
        return point(x, y, z, tonumber(pos.w or pos.a or pos.heading or pos[4]) or 0.0)
    end

    -- The first n characters of a UTF-8 text; a cut never splits a character.
    function helpers.cut(text, n)
        if type(text) ~= 'string' then return nil end
        local stop = utf8.offset(text, n + 1)
        return stop and text:sub(1, stop - 1) or text
    end

    -- A table or column name that is safe to put in backticks.
    function helpers.safeName(name)
        return type(name) == 'string' and #name <= 64 and name:match('^[%w_]+$') ~= nil
    end

    -- Escapes %, _ and backslash so text matches itself inside SQL LIKE.
    function helpers.likeEscape(text)
        return (tostring(text):gsub('[\\%%_]', '\\%0'))
    end

    Bridge.helpers = helpers
end

-- Whether a table (or one of its columns) exists, asked once: vehicles, identity and housing come from add-ons.
do
    local known = {}

    local TABLE = 'SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?'
    local COLUMN = 'SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?'

    -- Bridge.has('players', 'phone_number') -> true | false. Server only.
    function Bridge.has(name, column)
        local key = column and ('%s.%s'):format(name, column) or name
        if known[key] == nil then
            known[key] = (tonumber(MySQL.scalar.await(column and COLUMN or TABLE, { name, column })) or 0) > 0
        end
        return known[key]
    end

    -- The table another resource's config file returns (or the globals it sets), run in a sandbox; nil when it fails.
    function Bridge.readConfig(resource, path)
        local source = LoadResourceFile(resource, path)
        if not source then return nil end
        local env = setmetatable({}, { __index = _G })
        local chunk = load(source, ('@@%s/%s'):format(resource, path), 't', env)
        if not chunk then return nil end
        local ok, out = pcall(chunk)
        if not ok then return nil end
        return type(out) == 'table' and out or env
    end
end

-- qb and qbx share one database layout: the players table, player_vehicles and lb-phone numbers. Both adapters use this.
do
    local players = {}
    local helpers = Bridge.helpers

    local NAME = "CONCAT(JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')), ' ', JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname')))"
    local VEHICLE = 'SELECT UPPER(TRIM(plate)) AS plate, vehicle AS model, citizenid AS owner FROM player_vehicles'

    local function query(sql, params)
        local ok, rows = pcall(MySQL.query.await, sql, params)
        return ok and rows or nil
    end

    local function decode(value)
        return Core.util.decodeJson(value)
    end

    -- Phone numbers ------------------------------------------------------------------------------------------

    local function lbPhone()
        return Bridge.started('lb-phone') and Bridge.has('phone_phones', 'owner_id') and Bridge.has('phone_phones', 'phone_number')
    end

    local function text(value)
        value = value ~= nil and tostring(value) or ''
        return value ~= '' and value or nil
    end

    -- { [character id] = number } from lb-phone for a batch of characters.
    function players.phones(ids)
        local out = {}
        if #ids == 0 or not lbPhone() then return out end
        local ok, rows = pcall(MySQL.query.await, 'SELECT owner_id, phone_number FROM phone_phones WHERE owner_id IN (?)', { ids })
        for _, row in ipairs(ok and rows or {}) do out[row.owner_id] = row.phone_number end
        return out
    end

    -- The first number in the chain: lb-phone, the phone_number column, then charinfo.phone.
    function players.phone(numbers, id, column, fallback)
        return text(numbers[id]) or text(column) or text(fallback)
    end

    -- Staff edit of a character that is not being played: only the given fields change (names, birth date, nationality,
    -- cash, bank, job and grade). jobOf(name) is the framework's job definition. true, or false and a reason.
    function players.edit(citizenid, ch, jobOf)
        local row = MySQL.single.await('SELECT charinfo, money, job FROM players WHERE citizenid = ?', { citizenid })
        if not row then return false, 'invalid' end
        local info, money, job = decode(row.charinfo), decode(row.money), decode(row.job)
        for _, key in ipairs({ 'firstname', 'lastname', 'nationality', 'birthdate' }) do
            if ch[key] then info[key] = ch[key] end
        end
        if ch.cash then money.cash = ch.cash end
        if ch.bank then money.bank = ch.bank end
        if ch.job then
            local ok, def = pcall(jobOf, ch.job)
            local grades = ok and type(def) == 'table' and def.grades or {}
            local g = grades[tostring(ch.grade)] or grades[ch.grade]
            if not g then return false, 'job' end
            job = { name = ch.job, label = def.label, payment = g.payment, type = def.type, onduty = def.defaultDuty ~= false,
                isboss = g.isboss == true, grade = { name = g.name, level = ch.grade } }
        end
        MySQL.update.await('UPDATE players SET charinfo = ?, money = ?, job = ? WHERE citizenid = ?',
            { json.encode(info), json.encode(money), json.encode(job), citizenid })
        return true
    end

    -- Search and vehicles ------------------------------------------------------------------------------------

    -- Online and offline characters by name or id: { { citizenid, name } }.
    function players.search(needle, limit)
        local like = '%' .. needle .. '%'
        return MySQL.query.await(('SELECT citizenid, %s AS name FROM players WHERE citizenid LIKE ? OR %s LIKE ? LIMIT ?'):format(NAME, NAME), { like, like, limit }) or {}
    end

    -- Owned vehicles of a character: { { plate, model, owner } }.
    function players.vehiclesOf(citizenid)
        if not Bridge.has('player_vehicles') then return {} end
        return MySQL.query.await(VEHICLE .. ' WHERE citizenid = ? ORDER BY plate LIMIT 100', { citizenid }) or {}
    end

    -- Character rows -----------------------------------------------------------------------------------------

    -- Optional columns differ between qb and qbx versions.
    local function columns()
        local list = { 'citizenid', 'cid', 'license', 'charinfo', 'money', 'job', 'gang', 'position', 'metadata' }
        if Bridge.has('players', 'phone_number') then list[#list + 1] = 'phone_number' end
        local seen = Bridge.has('players', 'last_logged_out') and 'COALESCE(last_logged_out, last_updated)' or 'last_updated'
        list[#list + 1] = ('UNIX_TIMESTAMP(%s) AS seen'):format(seen)
        return table.concat(list, ', ')
    end

    local function job(raw)
        local grade = type(raw.grade) == 'table' and raw.grade or {}
        return { name = raw.name or 'unemployed', label = raw.label or raw.name, grade = tonumber(grade.level) or 0, gradeLabel = grade.name }
    end

    local function gang(raw)
        if not raw.name or raw.name == 'none' then return nil end
        local grade = type(raw.grade) == 'table' and raw.grade or {}
        return { name = raw.name, label = raw.label or raw.name, grade = tonumber(grade.level) or 0 }
    end

    -- Dead, cuffed and jailed from qb/qbx metadata (qbx_police and qb-policejob share the keys).
    function players.status(meta)
        meta = meta or {}
        return { dead = meta.isdead == true or meta.inlaststand == true, cuffed = meta.ishandcuffed == true, jailed = (tonumber(meta.injail) or 0) > 0 }
    end

    -- One players row in the bridge's character shape; numbers are phone numbers found elsewhere.
    function players.row(raw, numbers)
        local info, money, meta = decode(raw.charinfo), decode(raw.money), decode(raw.metadata)
        local status = players.status(meta)
        return {
            citizenid = raw.citizenid, slot = tonumber(raw.cid) or tonumber(info.cid), owner = raw.license,
            firstname = info.firstname, lastname = info.lastname,
            birthdate = helpers.isoDate(info.birthdate) or helpers.isoDate(info.birthdate, 'DMY'),
            gender = helpers.gender(info.gender), nationality = info.nationality, height = tonumber(info.height), bio = info.backstory,
            phone = players.phone(numbers, raw.citizenid, raw.phone_number, info.phone),
            cash = tonumber(money.cash) or 0, bank = tonumber(money.bank) or 0,
            job = job(decode(raw.job)), gang = gang(decode(raw.gang)),
            position = helpers.vec4(decode(raw.position)), lastSeen = tonumber(raw.seen),
            flags = { dead = status.dead, jailed = status.jailed, disabled = false },
            raw = { charinfo = info, metadata = meta },
        }
    end

    local function rowsOf(list)
        local ids = {}
        for i, raw in ipairs(list) do ids[i] = raw.citizenid end
        local numbers, out = players.phones(ids), {}
        for i, raw in ipairs(list) do out[i] = players.row(raw, numbers) end
        return out
    end

    -- The player's identifiers of the given kinds, in order.
    function players.owners(source, kinds)
        local out = {}
        for _, kind in ipairs(kinds) do
            local id = GetPlayerIdentifierByType(tostring(source), kind)
            if id then out[#out + 1] = id end
        end
        return out
    end

    function players.list(owners)
        local rows = query(('SELECT %s FROM players WHERE license IN (?) ORDER BY cid'):format(columns()), { owners })
        if not rows then return nil, 'failed' end
        return rowsOf(rows)
    end

    function players.get(citizenid)
        local rows = query(('SELECT %s FROM players WHERE citizenid = ?'):format(columns()), { citizenid })
        return rows and rows[1] and rowsOf({ rows[1] })[1] or nil
    end

    function players.owner(citizenid)
        local rows = query('SELECT license FROM players WHERE citizenid = ?', { citizenid })
        return rows and rows[1] and rows[1].license or nil
    end

    -- A database error counts as still there.
    local function exists(citizenid)
        local rows = query('SELECT 1 AS found FROM players WHERE citizenid = ?', { citizenid })
        return rows == nil or rows[1] ~= nil
    end

    -- charinfo for a new character; qb and qbx keep the extra keys (height).
    function players.charinfo(slot, identity)
        return {
            firstname = identity.firstname, lastname = identity.lastname, birthdate = identity.birthdate,
            gender = identity.gender == 'f' and 1 or 0, nationality = identity.nationality,
            cid = slot, height = identity.height, backstory = identity.bio,
        }
    end

    -- Polls test every 100 ms until it passes or ms run out.
    function players.waitFor(test, ms)
        local stop = GetGameTimer() + ms
        while not test() do
            if GetGameTimer() >= stop then return false end
            Wait(100)
        end
        return true
    end

    -- items: { name, amount, metadata = table | function(source) }, given once the inventory has loaded (5 s at most).
    -- missingOnly: only the ones the player does not have yet (the second try at the spawn). A failed one is printed.
    function players.starter(source, items, missingOnly)
        if #items == 0 then return end
        players.waitFor(function()
            local ok, ready = pcall(Bridge.inv.ready, source)
            return not ok or ready == true
        end, 5000)
        for _, item in ipairs(items) do
            local amount = item.amount or 1
            if not (missingOnly and Bridge.inv.has(source, item.name, amount)) then
                local metadata = item.metadata
                if type(metadata) == 'function' then
                    local ok, out = pcall(metadata, source)
                    metadata = ok and out or nil
                end
                local ok, added = pcall(Bridge.inv.add, source, item.name, amount, metadata)
                if not ok or not added then
                    print(('^3[daddy_multichar] starter item %s not given to %s: %s^7'):format(item.name, source, ok and 'refused' or tostring(added)))
                end
            end
        end
    end

    -- Waits for the framework's own delete (10 s), then clears the caller's tables in one transaction.
    function players.finishDelete(citizenid, extra)
        if not players.waitFor(function() return not exists(citizenid) end, 10000) then return nil, 'failed' end
        if #extra == 0 then return true end
        local ok, done = pcall(MySQL.transaction.await, extra)
        if ok and done then return true end
        return nil, 'failed'
    end

    -- The character's first or last vehicle with its saved mods.
    function players.vehicle(citizenid, pick)
        if not Bridge.has('player_vehicles') then return nil end
        local sql = 'SELECT vehicle, hash, mods, plate FROM player_vehicles WHERE citizenid = ? ORDER BY id %s LIMIT 1'
        local rows = query(sql:format(pick == 'first' and 'ASC' or 'DESC'), { citizenid })
        local row = rows and rows[1]
        if not row then return nil end
        local props = decode(row.mods)
        return { model = tonumber(props.model) or tonumber(row.hash) or row.vehicle, props = props, plate = row.plate }
    end

    -- Client: qb-houses and qb-apartments forget an old inside spot, as their spawn screens do.
    function players.leaveHomes()
        if Bridge.started('qb-houses') then TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false) end
        if Bridge.started('qb-apartments') then TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false) end
    end

    Bridge.players = players
end

-- qbx_core: players through its exports, characters through Login, Logout and DeleteCharacter (never its menu).
do
    local players = Bridge.players

    local function player(source)
        return exports.qbx_core:GetPlayer(source)
    end

    local function citizenOf(source)
        local p = player(source)
        return p and p.PlayerData.citizenid
    end

    -- qbx_core's own starterItems. Given after the first spawn (Spawn.done), never at the creation: ox_inventory had not
    -- built the inventory yet then and refused every item. Only the missing ones; true once the player holds them all.
    local function starterItems(source)
        local shared = Bridge.readConfig('qbx_core', 'config/shared.lua')
        local items = shared and shared.starterItems or {}
        players.starter(source, items, true)
        for _, item in ipairs(items) do
            if not Bridge.inv.has(source, item.name, item.amount or 1) then return false end
        end
        return true
    end

    local server = {
        -- What the character form may ask for.
        caps = { nationality = true, height = true, bio = true, phone = true, gang = true },

        -- The loaded character's id, or nil.
        citizenId = citizenOf,

        playerName = function(source)
            local info = (player(source) or {}).PlayerData
            info = info and info.charinfo
            return info and ('%s %s'):format(info.firstname, info.lastname)
        end,

        -- { name, grade, label } or nil.
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

        onDuty = function(source)
            local p = player(source)
            return p ~= nil and p.PlayerData.job.onduty == true
        end,

        isAdmin = function(source) return exports.qbx_core:HasPermission(source, 'admin') end,
        searchCharacters = players.search,
        vehiclesOf = players.vehiclesOf,

        -- cb(source) when a character finished loading / unloads.
        onLoaded = function(cb) AddEventHandler('QBCore:Server:PlayerLoaded', function(p) cb(p.PlayerData.source) end) end,
        onUnloaded = function(cb) AddEventHandler('QBCore:Server:OnPlayerUnload', cb) end,

        -- Owner keys of an online player.
        owners = function(source) return players.owners(source, { 'license2', 'license' }) end,
        list = players.list,
        get = players.get,
        edit = function(citizenid, ch) return players.edit(citizenid, ch, function(name) return exports.qbx_core:GetJob(name) end) end,
        owner = players.owner,
        loaded = citizenOf,

        -- Login with new data skips qbx's slot limit; the bridge already picked the slot.
        create = function(source, slot, identity, opts)
            if player(source) then return nil, 'loaded' end
            local data = { cid = slot, charinfo = players.charinfo(slot, identity) }
            pcall(function() exports.qbx_core:Login(source, false, data) end)
            local citizenid = citizenOf(source)
            if not citizenid then return nil, 'failed' end
            return citizenid
        end,

        -- Starter items, given by the core after the spawn (see starterItems above).
        starter = starterItems,

        -- Login drops a player who is already loaded or not the owner; Bridge.chars checked both.
        login = function(source, citizenid)
            if player(source) then return nil, 'loaded' end
            pcall(function() exports.qbx_core:Login(source, citizenid) end)
            if citizenOf(source) == citizenid then return true end
            return nil, 'failed'
        end,

        -- Logout saves, waits 200 ms and only then clears the player.
        logout = function(source)
            pcall(function() exports.qbx_core:Logout(source) end)
            if players.waitFor(function() return player(source) == nil end, 3000) then return true end
            return nil, 'timeout'
        end,

        -- The DeleteCharacter export is ForceDelete: a thread over qbx's characterDataTables.
        delete = function(citizenid, extra)
            if not pcall(function() exports.qbx_core:DeleteCharacter(citizenid) end) then return nil, 'failed' end
            return players.finishDelete(citizenid, extra)
        end,

        status = function(source)
            local p = player(source)
            return players.status(p and p.PlayerData.metadata)
        end,

        vehicle = players.vehicle,

        -- Setup that would fight the selection.
        conflicts = function()
            local out = {}
            local client = Bridge.readConfig('qbx_core', 'config/client.lua') or {}
            local characters = client.characters or {}
            if characters.useExternalCharacters ~= true then
                out[#out + 1] = { level = 'error', code = 'qbx_external_characters', text = 'qbx_core still runs its own character menu: set characters.useExternalCharacters = true in qbx_core/config/client.lua' }
            end
            if characters.startingApartment == true and Bridge.started('qbx_properties') then
                out[#out + 1] = { level = 'error', code = 'qbx_starting_apartment', text = 'qbx_properties opens its apartment picker on every login: set characters.startingApartment = false in qbx_core/config/client.lua' }
            end
            return out
        end,
    }

    local client = {
        isLoggedIn = function() return LocalPlayer.state.isLoggedIn == true end,

        citizenId = function()
            local data = exports.qbx_core:GetPlayerData()
            return data and data.citizenid
        end,

        onLoaded = function(cb) RegisterNetEvent('QBCore:Client:OnPlayerLoaded', cb) end,
        onUnloaded = function(cb) RegisterNetEvent('qbx_core:client:playerLoggedOut', cb) end,

        -- qbx's server event only sets isLoggedIn, so the client event is fired here too.
        spawned = function()
            TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
            TriggerEvent('QBCore:Client:OnPlayerLoaded')
            players.leaveHomes()
        end,

        -- qbx_spawn needs the player logged in and fires both load events itself.
        handoff = function()
            if not Bridge.started('qbx_spawn') then return false end
            TriggerEvent('qb-spawn:client:setupSpawns')
            return true
        end,
    }

    Bridge.frameworks.qbx = { server = server, client = client }
end

-- qb-core: players through the core object, characters through QBCore.Player Login, Logout and ForceDeleteCharacter.
do
    local players = Bridge.players

    local core
    local function qb()
        core = core or exports['qb-core']:GetCoreObject()
        return core
    end

    local function player(source)
        return qb().Functions.GetPlayer(source)
    end

    local function citizenOf(source)
        local p = player(source)
        return p and p.PlayerData.citizenid
    end

    -- The item info qb-multicharacter writes on the id card and the driver licence.
    local function infoFor(item, citizenid, charinfo)
        if item == 'id_card' then
            return { citizenid = citizenid, firstname = charinfo.firstname, lastname = charinfo.lastname, birthdate = charinfo.birthdate, gender = charinfo.gender, nationality = charinfo.nationality }
        end
        if item == 'driver_license' then
            return { firstname = charinfo.firstname, lastname = charinfo.lastname, birthdate = charinfo.birthdate, type = 'Class C Driver License' }
        end
    end

    local function starterItems(source, citizenid, charinfo)
        local list = {}
        for _, entry in pairs(qb().Shared.StarterItems or {}) do
            list[#list + 1] = { name = entry.item, amount = entry.amount, metadata = infoFor(entry.item, citizenid, charinfo) }
        end
        players.starter(source, list)
    end

    local server = {
        -- What the character form may ask for.
        caps = { nationality = true, height = true, bio = true, phone = true, gang = true },

        -- The loaded character's id, or nil.
        citizenId = citizenOf,

        playerName = function(source)
            local info = (player(source) or {}).PlayerData
            info = info and info.charinfo
            return info and ('%s %s'):format(info.firstname, info.lastname)
        end,

        -- { name, grade, label } or nil.
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

        onDuty = function(source)
            local p = player(source)
            return p ~= nil and p.PlayerData.job.onduty == true
        end,

        isAdmin = function(source) return qb().Functions.HasPermission(source, 'admin') end,
        searchCharacters = players.search,
        vehiclesOf = players.vehiclesOf,

        -- cb(source) when a character finished loading / unloads.
        onLoaded = function(cb) AddEventHandler('QBCore:Server:PlayerLoaded', function(p) cb(p.PlayerData.source) end) end,
        onUnloaded = function(cb) AddEventHandler('QBCore:Server:OnPlayerUnload', cb) end,

        -- Owner keys of an online player.
        owners = function(source) return players.owners(source, { 'license' }) end,
        list = players.list,
        get = players.get,
        edit = function(citizenid, ch) return players.edit(citizenid, ch, function(name) return qb().Shared.Jobs[name] end) end,
        owner = players.owner,
        loaded = citizenOf,

        -- qb has no double-login guard of its own, so the loaded check matters here.
        create = function(source, slot, identity, opts)
            if player(source) then return nil, 'loaded' end
            local charinfo = players.charinfo(slot, identity)
            pcall(function() qb().Player.Login(source, false, { cid = slot, charinfo = charinfo }) end)
            local citizenid = citizenOf(source)
            if not citizenid then return nil, 'failed' end
            pcall(qb().Commands.Refresh, source)
            if opts.starterItems ~= false then starterItems(source, citizenid, charinfo) end
            return citizenid
        end,

        login = function(source, citizenid)
            if player(source) then return nil, 'loaded' end
            pcall(function() qb().Player.Login(source, citizenid) end)
            if citizenOf(source) ~= citizenid then return nil, 'failed' end
            pcall(qb().Commands.Refresh, source)
            return true
        end,

        logout = function(source)
            pcall(function() qb().Player.Logout(source) end)
            if players.waitFor(function() return player(source) == nil end, 3000) then return true end
            return nil, 'timeout'
        end,

        -- ForceDeleteCharacter runs an async transaction over qb's own player tables.
        delete = function(citizenid, extra)
            if not pcall(function() qb().Player.ForceDeleteCharacter(citizenid) end) then return nil, 'failed' end
            return players.finishDelete(citizenid, extra)
        end,

        status = function(source)
            local p = player(source)
            return players.status(p and p.PlayerData.metadata)
        end,

        vehicle = players.vehicle,

        -- Setup that would fight the selection.
        conflicts = function()
            if not Bridge.started('qb-multicharacter') then return {} end
            return { { level = 'error', code = 'qb_multicharacter', text = 'qb-multicharacter is running and opens its own selection: stop it and remove it from server.cfg' } }
        end,
    }

    local client = {
        isLoggedIn = function() return LocalPlayer.state.isLoggedIn == true end,

        citizenId = function()
            local data = qb().Functions.GetPlayerData()
            return data and data.citizenid
        end,

        onLoaded = function(cb) RegisterNetEvent('QBCore:Client:OnPlayerLoaded', cb) end,
        onUnloaded = function(cb) RegisterNetEvent('QBCore:Client:OnPlayerUnload', cb) end,

        -- qb-core answers the server event with the client one.
        spawned = function()
            TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
            players.leaveHomes()
        end,

        -- qb-apartments opens qb-spawn itself; without it, qb-spawn is opened directly.
        handoff = function(citizenid)
            local data = { citizenid = citizenid }
            if Bridge.started('qb-apartments') then
                TriggerEvent('apartments:client:setupSpawnUI', data)
                return true
            end
            if not Bridge.started('qb-spawn') then return false end
            TriggerEvent('qb-spawn:client:setupSpawns', data, false, nil)
            TriggerEvent('qb-spawn:client:openUI', true)
            return true
        end,
    }

    Bridge.frameworks.qb = { server = server, client = client }
end

-- es_extended: characters through its multichar join and logout events; ids look like <prefix><slot>:<license hash>.
-- Convars: multichar:esx_char_prefix (the Config.Prefix an earlier esx_multicharacter used, default char) and
-- multichar:esx_dateformat (esx_identity's date order: DMY | MDY | YMD).
do
    local helpers = Bridge.helpers

    local IDENTITY = { 'firstname', 'lastname', 'dateofbirth', 'sex', 'height' }
    local OPTIONAL = { 'firstname', 'lastname', 'dateofbirth', 'sex', 'height', 'phone_number', 'disabled', 'is_dead', 'metadata' }
    local ADMIN_GROUPS = { admin = true, superadmin = true }
    local VEHICLE = 'SELECT UPPER(TRIM(plate)) AS plate, vehicle AS model, owner FROM owned_vehicles'
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

    local function prefix()
        local value = Bridge.convar('esx_char_prefix', 'char')
        return helpers.safeName(value) and value or 'char'
    end

    local function dateOrder()
        return Bridge.convar('esx_dateformat', 'DMY')
    end

    -- Names live in esx_identity's columns; without it the identifier stands in.
    local function nameSql()
        return Bridge.has('users', 'firstname') and "CONCAT(firstname, ' ', lastname)" or 'identifier'
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
            Bridge.warn('es_extended loaded player %d after the wait; logging them out', id)
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
            if not known and helpers.safeName(row.tbl) and helpers.safeName(row.col) then scanned[#scanned + 1] = row end
        end
        return scanned
    end

    local function columns()
        local list = { '`identifier`', '`accounts`', '`job`', '`job_grade`', '`position`' }
        for _, name in ipairs(OPTIONAL) do
            if Bridge.has('users', name) then list[#list + 1] = ('`%s`'):format(name) end
        end
        if Bridge.has('users', 'last_seen') then list[#list + 1] = 'UNIX_TIMESTAMP(`last_seen`) AS seen' end
        return table.concat(list, ', ')
    end

    local function jobOf(jobs, name, grade)
        local def = jobs[name] or {}
        local level = (def.grades or {})[tostring(grade)] or {}
        return { name = name or 'unemployed', label = def.label or name, grade = tonumber(grade) or 0, gradeLabel = level.label }
    end

    -- One users row in the bridge's character shape.
    local function row(raw, jobs, numbers)
        local decode, flag = Core.util.decodeJson, Core.util.flag
        local id, accounts = raw.identifier, decode(raw.accounts)
        return {
            citizenid = id, slot = helpers.slotOf(id, prefix()), owner = id:match(':(.+)$'),
            firstname = raw.firstname, lastname = raw.lastname, birthdate = helpers.isoDate(raw.dateofbirth, dateOrder()),
            gender = helpers.gender(raw.sex), height = tonumber(raw.height),
            phone = Bridge.players.phone(numbers, id, raw.phone_number),
            cash = tonumber(accounts.money) or 0, bank = tonumber(accounts.bank) or 0,
            job = jobOf(jobs, raw.job, raw.job_grade),
            position = helpers.vec4(decode(raw.position)), lastSeen = tonumber(raw.seen),
            flags = { dead = flag(raw.is_dead), jailed = false, disabled = flag(raw.disabled) },
            raw = { metadata = decode(raw.metadata) },
        }
    end

    -- Rows of this prefix only, ordered by slot.
    local function rowsOf(list)
        local ok, jobs = pcall(esx().GetJobs)
        local ids, out = {}, {}
        for i, raw in ipairs(list) do ids[i] = raw.identifier end
        local numbers = Bridge.players.phones(ids)
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

    local server = {
        -- What the character form may ask for.
        caps = { nationality = false, height = true, bio = false, phone = true, gang = false },

        -- The loaded character's id, or nil.
        citizenId = citizenOf,

        playerName = function(source)
            local p = esx().GetPlayerFromId(source)
            return p and p.getName()
        end,

        -- { name, grade, label } or nil.
        job = function(source)
            local p = esx().GetPlayerFromId(source)
            return p and { name = p.job.name, grade = p.job.grade, label = p.job.label }
        end,

        gang = function() return nil end,

        -- ESX before 1.11 has no duty: everyone in the job is on duty.
        onDuty = function(source)
            local p = esx().GetPlayerFromId(source)
            return p ~= nil and p.job.onDuty ~= false
        end,

        isAdmin = function(source)
            local p = esx().GetPlayerFromId(source)
            return p ~= nil and ADMIN_GROUPS[p.getGroup()] == true
        end,

        searchCharacters = function(needle, limit)
            local like = '%' .. needle .. '%'
            return MySQL.query.await(('SELECT identifier AS citizenid, %s AS name FROM users WHERE identifier LIKE ? OR %s LIKE ? LIMIT ?'):format(nameSql(), nameSql()), { like, like, limit }) or {}
        end,

        -- owned_vehicles comes with esx_vehicleshop.
        vehiclesOf = function(citizenid)
            if not Bridge.has('owned_vehicles') then return {} end
            return MySQL.query.await(VEHICLE .. ' WHERE owner = ? ORDER BY plate LIMIT 100', { citizenid }) or {}
        end,

        -- cb(source) when a character finished loading / unloads.
        onLoaded = function(cb) AddEventHandler('esx:playerLoaded', function(playerId) cb(playerId) end) end,
        onUnloaded = function(cb) AddEventHandler('esx:playerDropped', function(playerId) cb(playerId) end) end,

        -- Owner keys of an online player.
        owners = function(source)
            local owner = hash(source)
            return owner and { owner } or {}
        end,

        list = function(owners)
            local where, params = {}, {}
            for _, owner in ipairs(owners) do
                where[#where + 1] = 'identifier LIKE ?'
                params[#params + 1] = helpers.likeEscape(prefix()) .. '%:' .. helpers.likeEscape(owner)
            end
            local rows = query(('SELECT %s FROM users WHERE %s'):format(columns(), table.concat(where, ' OR ')), params)
            if not rows then return nil, 'failed' end
            return rowsOf(rows)
        end,

        get = function(citizenid)
            local rows = query(('SELECT %s FROM users WHERE identifier = ?'):format(columns()), { citizenid })
            return rows and rows[1] and rowsOf({ rows[1] })[1] or nil
        end,

        -- Staff edit of a character that is not being played (esx_identity has no nationality).
        edit = function(citizenid, ch)
            local rows = query('SELECT accounts FROM users WHERE identifier = ?', { citizenid })
            if not rows or not rows[1] then return false, 'invalid' end
            local sets, params = {}, {}
            local function set(column, value)
                sets[#sets + 1] = ('`%s` = ?'):format(column)
                params[#params + 1] = value
            end
            if ch.firstname then set('firstname', ch.firstname) end
            if ch.lastname then set('lastname', ch.lastname) end
            if ch.birthdate then set('dateofbirth', helpers.formatDate(ch.birthdate, dateOrder())) end
            if ch.cash or ch.bank then
                local accounts = Core.util.decodeJson(rows[1].accounts)
                accounts.money, accounts.bank = ch.cash or accounts.money, ch.bank or accounts.bank
                set('accounts', json.encode(accounts))
            end
            if ch.job then
                local ok, jobs = pcall(esx().GetJobs)
                local def = ok and jobs and jobs[ch.job]
                if not def or not (def.grades or {})[tostring(ch.grade)] then return false, 'job' end
                set('job', ch.job)
                set('job_grade', ch.grade)
            end
            if #sets == 0 then return true end
            params[#params + 1] = citizenid
            MySQL.update.await(('UPDATE users SET %s WHERE identifier = ?'):format(table.concat(sets, ', ')), params)
            return true
        end,

        owner = function(citizenid)
            if not helpers.slotOf(citizenid, prefix()) then return nil end
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
                firstname = helpers.cut(identity.firstname, 16), lastname = helpers.cut(identity.lastname, 16),
                dateofbirth = helpers.formatDate(identity.birthdate, dateOrder()), sex = identity.gender, height = identity.height,
            }
            if not join(source, char, data) then return nil, 'timeout' end
            return char .. ':' .. owner
        end,

        login = function(source, citizenid)
            if not multichar() then return nil, 'mode' end
            if citizenOf(source) then return nil, 'loaded' end
            local slot = helpers.slotOf(citizenid, prefix())
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
            if not Bridge.has('owned_vehicles') then return nil end
            local filter = Bridge.has('owned_vehicles', 'type') and " AND `type` = 'car'" or ''
            local rows = query('SELECT plate, vehicle FROM owned_vehicles WHERE owner = ?' .. filter .. ' LIMIT 50', { citizenid }) or {}
            local found = rows[pick == 'first' and 1 or #rows]
            local props = found and Core.util.decodeJson(found.vehicle) or {}
            if not props.model then return nil end
            return { model = props.model, props = props, plate = found.plate }
        end,

        -- Setup that would fight the selection.
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
                if not Bridge.has('users', column) then missing[#missing + 1] = column end
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
    }

    local client = {
        isLoggedIn = function() return esx().IsPlayerLoaded() end,

        citizenId = function()
            local data = esx().GetPlayerData()
            return data and data.identifier
        end,

        onLoaded = function(cb) RegisterNetEvent('esx:playerLoaded', cb) end,
        onUnloaded = function(cb) RegisterNetEvent('esx:onPlayerLogout', cb) end,

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
    }

    Bridge.frameworks.esx = { server = server, client = client }
end

-- No supported framework: the license is the player's id, there are no characters to list or create.
do
    local function license(source)
        return GetPlayerIdentifierByType(tostring(source), 'license')
    end

    local server = {
        supported = false,
        caps = { nationality = false, height = false, bio = false, phone = false, gang = false },
        citizenId = license,
        playerName = function(source) return GetPlayerName(tostring(source)) end,
        job = function() return nil end,
        gang = function() return nil end,
        onDuty = function() return true end,
        isAdmin = function() return false end,
        vehiclesOf = function() return {} end,

        -- Without a character table only the players online right now are found.
        searchCharacters = function(needle, limit)
            local out, lower = {}, needle:lower()
            for _, id in ipairs(GetPlayers()) do
                local name, cid = GetPlayerName(id), license(id)
                if #out < limit and (name:lower():find(lower, 1, true) or cid == needle) then out[#out + 1] = { citizenid = cid, name = name } end
            end
            return out
        end,

        onLoaded = function(cb) AddEventHandler('playerJoining', function() cb(source) end) end,
        onUnloaded = function() end,

        owners = function(source)
            local id = license(source)
            return id and { id } or {}
        end,
        list = function() return {} end,
        get = function() return nil end,
        owner = function() return nil end,
        loaded = function() return nil end,
        status = function() return {} end,
        vehicle = function() return nil end,

        conflicts = function()
            return { { level = 'warn', code = 'unsupported', text = 'No supported framework runs, so there are no characters to list or create' } }
        end,
    }

    local client = {
        isLoggedIn = function() return NetworkIsPlayerActive(PlayerId()) end,
        citizenId = function() return nil end,
        onLoaded = function(cb) AddEventHandler('playerSpawned', function() cb() end) end,
        onUnloaded = function() end,
        spawned = function() end,
        handoff = function() return false end,
    }

    Bridge.frameworks.standalone = { server = server, client = client }
end

-- Picks the framework (Config.Bridge.Framework, the multichar:framework convar, or the first one running) and builds
-- Bridge.fw (players) and Bridge.chars (characters) from its adapter. Everything here yields: call from a thread.
do
    local helpers = Bridge.helpers

    local AUTO = {
        { id = 'qbx', resource = 'qbx_core' },
        { id = 'qb', resource = 'qb-core' },
        { id = 'esx', resource = 'es_extended' },
        { id = 'nd', resource = 'ND_Core' },
    }

    local function detect()
        local forced = Bridge.setting('Framework', 'framework')
        if forced ~= 'auto' then return forced end
        for _, entry in ipairs(AUTO) do
            if Bridge.started(entry.resource) then return entry.id end
        end
        return 'standalone'
    end

    local id = detect()

    -- The adapter of this side; a framework without a file runs as standalone.
    local function adapter()
        local found = Bridge.frameworks[id] or Bridge.frameworks.standalone
        return found[Bridge.side]
    end

    -- Players ------------------------------------------------------------------------------------------------

    Bridge.define('fw', function()
        local a = adapter()
        local fw = { id = id }
        fw.citizenId = a.citizenId
        fw.onLoaded = a.onLoaded
        if Bridge.side == 'client' then
            fw.isLoggedIn = a.isLoggedIn
            fw.onUnloaded = a.onUnloaded
            return fw
        end
        fw.playerName, fw.job, fw.gang, fw.onDuty, fw.vehiclesOf = a.playerName, a.job, a.gang, a.onDuty, a.vehiclesOf

        -- Online and offline characters by name or id: { { citizenid, name } }.
        function fw.searchCharacters(text, limit)
            text = Core.util.trim(text, 64)
            if not text or #text < 2 then return {} end
            return a.searchCharacters(text, math.min(limit or 20, 50))
        end

        -- ACE daddy.admin, or the framework's own admin.
        function fw.isAdmin(source)
            return IsPlayerAceAllowed(tostring(source), 'daddy.admin') or a.isAdmin(source) == true
        end

        -- The online player playing a character, or nil.
        function fw.sourceOf(citizenid)
            if not citizenid then return nil end
            for _, player in ipairs(GetPlayers()) do
                local source = tonumber(player)
                if a.citizenId(source) == citizenid then return source end
            end
        end

        -- cb(source) on logout and on disconnect.
        function fw.onUnloaded(cb)
            a.onUnloaded(cb)
            AddEventHandler('playerDropped', function() cb(source) end)
        end

        return fw
    end)

    -- Characters on the client: loading screen, the framework's spawn events and its own spawn screen -------

    local function clientChars(a)
        local chars = { id = id, isoDate = helpers.isoDate }

        -- Stops spawnmanager (and the framework) from spawning the player on their own.
        function chars.boot()
            pcall(function() exports.spawnmanager:setAutoSpawn(false) end)
            if a.boot then a.boot() end
        end

        -- Call it only once the product's own screen is ready behind a fade.
        function chars.closeLoadingScreen()
            ShutdownLoadingScreen()
            ShutdownLoadingScreenNui()
            if a.closeLoadingScreen then a.closeLoadingScreen() end
        end

        -- The framework's post-spawn events; call once, after the ped is placed and dressed.
        function chars.spawned(coords, isNew)
            a.spawned(coords, isNew == true)
            local at = helpers.vec4(coords)
            TriggerEvent('playerSpawned', at and { x = at.x, y = at.y, z = at.z, heading = at.w } or {})
        end

        -- true: the framework's spawn screen took over and fires the load events, so do not call spawned.
        function chars.handoff(citizenid, isNew)
            return a.handoff(citizenid, isNew == true) == true
        end

        -- Advisory only (ESX keeps cuffs on the client).
        function chars.cuffed()
            local v = IsPedCuffed(PlayerPedId())
            return v == true or v == 1
        end

        function chars.conflicts()
            return a.conflicts and a.conflicts() or {}
        end

        return chars
    end

    -- Characters on the server, without the framework's own menu; never drops a player ---------------------

    local function validId(value)
        return type(value) == 'string' and #value > 0 and #value <= 64
    end

    -- Trimmed text of at most n characters, not bytes, so names in any alphabet stay whole.
    local function text(value, n)
        return helpers.cut(Core.util.trim(value), n)
    end

    -- A clean identity, or nil when a required field is missing or impossible.
    local function identityOf(input)
        if type(input) ~= 'table' then return nil end
        local out = {
            firstname = text(input.firstname, 50), lastname = text(input.lastname, 50),
            birthdate = helpers.isoDate(input.birthdate), gender = helpers.gender(input.gender),
            nationality = text(input.nationality, 50), bio = text(input.bio, 500),
            height = tonumber(input.height) and math.floor(tonumber(input.height)) or nil,
        }
        if not (out.firstname and out.lastname and out.birthdate and out.gender) then return nil end
        return out
    end

    -- One job per key at a time (a player, or a character); a second one gets 'busy'.
    local function exclusive(locks, key, fn)
        if locks[key] then return nil, 'busy' end
        locks[key] = true
        local ok, result, err = pcall(fn)
        locks[key] = nil
        if ok then return result, err end
        Bridge.warn('chars: %s', result)
        return nil, 'failed'
    end

    -- DELETE statements for the caller's own tables; nil when a name is unsafe, missing tables are skipped.
    local function extraTables(citizenid, list)
        local out = {}
        for _, entry in ipairs(list or {}) do
            local name, column = entry.table or entry[1], entry.column or entry[2]
            if not (helpers.safeName(name) and helpers.safeName(column)) then return nil end
            if Bridge.has(name, column) then
                out[#out + 1] = { query = ('DELETE FROM `%s` WHERE `%s` = ?'):format(name, column), values = { citizenid } }
            end
        end
        return out
    end

    local function serverChars(a)
        local chars = { id = id, caps = a.caps, isoDate = helpers.isoDate }
        local busy, held = {}, {}
        local unsupported = function() return a.supported == false end

        -- Owner keys of an online player; stored per license so offline and bot listing works.
        function chars.owners(source)
            return a.owners(source) or {}
        end

        -- Rows ordered by slot; nil and 'failed' on a database error, so callers can tell it from none.
        function chars.list(owners)
            local clean = {}
            for _, owner in ipairs(type(owners) == 'table' and owners or {}) do
                if validId(owner) then clean[#clean + 1] = owner end
            end
            if #clean == 0 then return {} end
            local ok, rows, err = pcall(a.list, clean)
            if not ok then return nil, 'failed' end
            return rows, err
        end

        -- Any character by id, with its owner (admin and bot use).
        function chars.get(citizenid)
            if not validId(citizenid) then return nil end
            return a.get(citizenid)
        end

        -- Staff edit of a character that is not being played; false and a reason when the framework cannot.
        function chars.edit(citizenid, changes)
            if not validId(citizenid) or not a.edit then return false, 'unsupported' end
            return a.edit(citizenid, changes)
        end

        function chars.owns(owners, citizenid)
            if type(owners) ~= 'table' or not validId(citizenid) then return false end
            return Core.util.contains(owners, a.owner(citizenid))
        end

        -- The loaded character's id, or nil.
        function chars.loaded(source)
            return a.loaded(source)
        end

        -- Starter items for frameworks that give them after the spawn: true when the player holds them all, false
        -- when some are still missing. nil: this framework gave them at the creation already.
        function chars.starter(source)
            if not a.starter then return nil end
            return a.starter(source) == true
        end

        -- identity: { firstname, lastname, birthdate 'YYYY-MM-DD', gender 'm'|'f', nationality, height, bio }; opts: { starterItems = true }.
        function chars.create(source, identity, opts)
            if unsupported() then return nil, 'unsupported' end
            identity = identityOf(identity)
            if not identity then return nil, 'invalid' end
            return exclusive(busy, source, function()
                if a.loaded(source) then return nil, 'loaded' end
                local rows = chars.list(chars.owners(source))
                if not rows then return nil, 'failed' end
                return a.create(source, helpers.freeSlot(rows), identity, opts or {})
            end)
        end

        -- Ownership is checked here first: frameworks drop a player who logs into someone else's character or a deleted one.
        function chars.login(source, citizenid)
            if unsupported() then return nil, 'unsupported' end
            if not validId(citizenid) then return nil, 'not_owner' end
            return exclusive(busy, source, function()
                if a.loaded(source) then return nil, 'loaded' end
                return exclusive(held, citizenid, function()
                    if not chars.owns(chars.owners(source), citizenid) then return nil, 'not_owner' end
                    return a.login(source, citizenid)
                end)
            end)
        end

        -- Returns once the framework has unloaded the player.
        function chars.logout(source)
            if unsupported() then return nil, 'unsupported' end
            return exclusive(busy, source, function()
                if not a.loaded(source) then return true end
                return a.logout(source)
            end)
        end

        -- opts.tables: { { table = 'x', column = 'citizenid' } } cleared with the framework's own data; 'busy' while it logs in.
        function chars.delete(citizenid, opts)
            if unsupported() then return nil, 'unsupported' end
            if not validId(citizenid) then return nil, 'missing' end
            local extra = extraTables(citizenid, opts and opts.tables)
            if not extra then return nil, 'invalid' end
            return exclusive(held, citizenid, function()
                if not a.owner(citizenid) then return nil, 'missing' end
                if Bridge.fw.sourceOf(citizenid) then return nil, 'online' end
                return a.delete(citizenid, extra)
            end)
        end

        -- { dead, cuffed, jailed }; cuffed is nil when the server cannot know.
        function chars.status(source)
            local found = a.status(source) or {}
            return { dead = found.dead == true or Bridge.medical.down(source), cuffed = found.cuffed, jailed = found.jailed == true }
        end

        -- { model, props, plate } of the character's last (or first) vehicle, for a preview.
        function chars.vehicle(citizenid, pick)
            if unsupported() or not validId(citizenid) then return nil end
            return a.vehicle(citizenid, pick == 'first' and 'first' or 'last')
        end

        -- { { level = 'error'|'warn', code, text } }; an error means the selection must not open. opts.slots: the most slots.
        function chars.conflicts(opts)
            local ok, out = pcall(a.conflicts, type(opts) == 'table' and opts or {})
            if not ok then out = { { level = 'warn', code = 'check_failed', text = 'The framework check failed: ' .. tostring(out) } } end
            if not Bridge.frameworks[id] then
                out = { { level = 'warn', code = 'unsupported', text = ('%s characters are not supported yet, so there are no characters to list or create'):format(id) } }
            end
            if GetConvar('onesync', 'off') == 'off' then
                out[#out + 1] = { level = 'error', code = 'onesync', text = 'OneSync is off: set onesync on in server.cfg (routing buckets and server-side checks need it)' }
            end
            return out
        end

        return chars
    end

    Bridge.define('chars', function()
        if Bridge.side == 'client' then return clientChars(adapter()) end
        return serverChars(adapter())
    end)
end
