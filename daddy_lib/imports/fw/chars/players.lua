-- qb/qbx characters: the players table read into the bridge's row shape, plus the steps both adapters share.
local shared = DL.require('chars/shared')
local phone = DL.require('fw/chars/phone')
local has = DL.require('fw/schema')

local players = {}

local function query(sql, params)
    local ok, rows = pcall(MySQL.query.await, sql, params)
    return ok and rows or nil
end

local function decode(value)
    return DL.util.decodeJson(value)
end

-- Optional columns differ between qb and qbx versions.
local function columns()
    local list = { 'citizenid', 'cid', 'license', 'charinfo', 'money', 'job', 'gang', 'position', 'metadata' }
    if has('players', 'phone_number') then list[#list + 1] = 'phone_number' end
    local seen = has('players', 'last_logged_out') and 'COALESCE(last_logged_out, last_updated)' or 'last_updated'
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

-- One players row in the bridge's shape; numbers are phone numbers found elsewhere.
function players.row(raw, numbers)
    local info, money, meta = decode(raw.charinfo), decode(raw.money), decode(raw.metadata)
    local status = players.status(meta)
    return {
        citizenid = raw.citizenid, slot = tonumber(raw.cid) or tonumber(info.cid), owner = raw.license,
        firstname = info.firstname, lastname = info.lastname,
        birthdate = shared.isoDate(info.birthdate) or shared.isoDate(info.birthdate, 'DMY'),
        gender = shared.gender(info.gender), nationality = info.nationality, height = tonumber(info.height), bio = info.backstory,
        phone = phone.pick(numbers, raw.citizenid, raw.phone_number, info.phone),
        cash = tonumber(money.cash) or 0, bank = tonumber(money.bank) or 0,
        job = job(decode(raw.job)), gang = gang(decode(raw.gang)),
        position = shared.vec4(decode(raw.position)), lastSeen = tonumber(raw.seen),
        flags = { dead = status.dead, jailed = status.jailed, disabled = false },
        raw = { charinfo = info, metadata = meta },
    }
end

local function rowsOf(list)
    local ids = {}
    for i, raw in ipairs(list) do ids[i] = raw.citizenid end
    local numbers, out = phone.lookup(ids), {}
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

-- Up to 5 s for the inventory to load; a lib without inv.ready gets a short fixed wait.
local function awaitInventory(source)
    if type(DL.inv.ready) ~= 'function' then return Wait(1000) end
    players.waitFor(function()
        local ok, ready = pcall(DL.inv.ready, source)
        return not ok or ready == true
    end, 5000)
end

-- items: { name, amount, metadata = table | function(source) }.
function players.starter(source, items)
    if #items == 0 then return end
    awaitInventory(source)
    for _, item in ipairs(items) do
        local metadata = item.metadata
        if type(metadata) == 'function' then
            local ok, out = pcall(metadata, source)
            metadata = ok and out or nil
        end
        pcall(DL.inv.add, source, item.name, item.amount or 1, metadata)
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
    if not has('player_vehicles') then return nil end
    local sql = 'SELECT vehicle, hash, mods, plate FROM player_vehicles WHERE citizenid = ? ORDER BY id %s LIMIT 1'
    local rows = query(sql:format(pick == 'first' and 'ASC' or 'DESC'), { citizenid })
    local row = rows and rows[1]
    if not row then return nil end
    local props = decode(row.mods)
    return { model = tonumber(props.model) or tonumber(row.hash) or row.vehicle, props = props, plate = row.plate }
end

-- Client: qb-houses and qb-apartments forget an old inside spot, as their spawn screens do.
function players.leaveHomes()
    if GetResourceState('qb-houses') == 'started' then TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false) end
    if GetResourceState('qb-apartments') == 'started' then TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false) end
end

return players
