-- Characters without the framework's own menu. Everything yields (call from a thread); never drops a player.
local shared = DL.require('chars/shared')
local has = DL.require('fw/schema')
local adapter = (DL.require('fw/chars/' .. DL.fw.id) or DL.require('fw/chars/standalone')).server

local chars = { id = DL.fw.id, caps = adapter.caps }
local busy, held = {}, {}

local function validId(value)
    return type(value) == 'string' and #value > 0 and #value <= 64
end

local function unsupported()
    return adapter.supported == false
end

-- Trimmed text of at most n characters, not bytes, so names in any alphabet stay whole.
local function text(value, n)
    return shared.cut(DL.util.trim(value), n)
end

-- A clean identity, or nil when a required field is missing or impossible.
local function identityOf(input)
    if type(input) ~= 'table' then return nil end
    local out = {
        firstname = text(input.firstname, 50), lastname = text(input.lastname, 50),
        birthdate = shared.isoDate(input.birthdate), gender = shared.gender(input.gender),
        nationality = text(input.nationality, 50), bio = text(input.bio, 500),
        height = tonumber(input.height) and math.floor(tonumber(input.height)) or nil,
    }
    if not (out.firstname and out.lastname and out.birthdate and out.gender) then return nil end
    return out
end

-- One job per key at a time (a player in busy, a character in held); a second one gets 'busy'.
local function exclusive(locks, key, fn)
    if locks[key] then return nil, 'busy' end
    locks[key] = true
    local ok, result, err = pcall(fn)
    locks[key] = nil
    if ok then return result, err end
    print(('^1[%s] chars: %s^7'):format(DL.resource, result))
    return nil, 'failed'
end

-- DELETE statements for the caller's own tables; nil when a name is unsafe, missing tables are skipped.
local function extraTables(citizenid, list)
    local out = {}
    for _, entry in ipairs(list or {}) do
        local name, column = entry.table or entry[1], entry.column or entry[2]
        if not (shared.safeName(name) and shared.safeName(column)) then return nil end
        if has(name, column) then
            out[#out + 1] = { query = ('DELETE FROM `%s` WHERE `%s` = ?'):format(name, column), values = { citizenid } }
        end
    end
    return out
end

-- Owner keys of an online player; products keep them per license so offline and bot listing works.
function chars.owners(source)
    return adapter.owners(source) or {}
end

-- Rows ordered by slot; nil and 'failed' on a database error, so callers can tell it from none.
function chars.list(owners)
    local clean = {}
    for _, owner in ipairs(type(owners) == 'table' and owners or {}) do
        if validId(owner) then clean[#clean + 1] = owner end
    end
    if #clean == 0 then return {} end
    local ok, rows, err = pcall(adapter.list, clean)
    if not ok then return nil, 'failed' end
    return rows, err
end

-- Any character by id, with its owner (admin and bot use).
function chars.get(citizenid)
    if not validId(citizenid) then return nil end
    return adapter.get(citizenid)
end

function chars.owns(owners, citizenid)
    if type(owners) ~= 'table' or not validId(citizenid) then return false end
    return DL.util.contains(owners, adapter.owner(citizenid))
end

-- The loaded character's id, or nil.
function chars.loaded(source)
    return adapter.loaded(source)
end

-- identity: { firstname, lastname, birthdate 'YYYY-MM-DD', gender 'm'|'f', nationality, height, bio }; opts: { starterItems = true }.
function chars.create(source, identity, opts)
    if unsupported() then return nil, 'unsupported' end
    identity = identityOf(identity)
    if not identity then return nil, 'invalid' end
    return exclusive(busy, source, function()
        if adapter.loaded(source) then return nil, 'loaded' end
        local rows = chars.list(chars.owners(source))
        if not rows then return nil, 'failed' end
        return adapter.create(source, shared.freeSlot(rows), identity, opts or {})
    end)
end

-- Ownership is checked here first: frameworks drop a player who logs into someone else's character or a deleted one.
function chars.login(source, citizenid)
    if unsupported() then return nil, 'unsupported' end
    if not validId(citizenid) then return nil, 'not_owner' end
    return exclusive(busy, source, function()
        if adapter.loaded(source) then return nil, 'loaded' end
        return exclusive(held, citizenid, function()
            if not chars.owns(chars.owners(source), citizenid) then return nil, 'not_owner' end
            return adapter.login(source, citizenid)
        end)
    end)
end

-- Returns once the framework has unloaded the player.
function chars.logout(source)
    if unsupported() then return nil, 'unsupported' end
    return exclusive(busy, source, function()
        if not adapter.loaded(source) then return true end
        return adapter.logout(source)
    end)
end

-- opts.tables: { { table = 'x', column = 'citizenid' } } cleared with the framework's own data; 'busy' while it logs in.
function chars.delete(citizenid, opts)
    if unsupported() then return nil, 'unsupported' end
    if not validId(citizenid) then return nil, 'missing' end
    local extra = extraTables(citizenid, opts and opts.tables)
    if not extra then return nil, 'invalid' end
    return exclusive(held, citizenid, function()
        if not adapter.owner(citizenid) then return nil, 'missing' end
        if DL.fw.sourceOf(citizenid) then return nil, 'online' end
        return adapter.delete(citizenid, extra)
    end)
end

-- cuffed is nil when the server cannot know.
function chars.status(source)
    local found = adapter.status(source) or {}
    return { dead = found.dead == true or DL.medical.down(source), cuffed = found.cuffed, jailed = found.jailed == true }
end

-- { model, props, plate } of the character's last (or first) vehicle, for a preview.
function chars.vehicle(citizenid, pick)
    if unsupported() or not validId(citizenid) then return nil end
    return adapter.vehicle(citizenid, pick == 'first' and 'first' or 'last')
end

-- { { level = 'error'|'warn', code, text } }; an error means the selection must not open. opts.slots: the most slots.
function chars.conflicts(opts)
    local ok, out = pcall(adapter.conflicts, type(opts) == 'table' and opts or {})
    if not ok then out = { { level = 'warn', code = 'check_failed', text = 'The framework check failed: ' .. tostring(out) } } end
    if GetConvar('onesync', 'off') == 'off' then
        out[#out + 1] = { level = 'error', code = 'onesync', text = 'OneSync is off: set onesync on in server.cfg (routing buckets and server-side checks need it)' }
    end
    return out
end

return chars
