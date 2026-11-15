-- Stored clothing on the server: playerskins on qb/qbx, users.skin on esx. Read for previews, saved for fivem-appearance.
local shared = DL.require('appearance/shared')
local has = DL.require('fw/schema')

local appearance = { id = shared.detect() }
local MAX_BYTES, BATCH = 65536, 50
local allowed = { [joaat(shared.FREEMODE.m)] = true, [joaat(shared.FREEMODE.f)] = true }
local hook, served

-- The clothing script id now; the script may start after the product, so it is looked up again on use.
function appearance.current()
    if not hook then appearance.id = shared.detect() end
    return appearance.id
end

local function qbLike()
    return DL.fw.id == 'qb' or DL.fw.id == 'qbx'
end

-- One batch of rows as { citizenid, model, skin }.
local function rows(ids)
    local marks = ('?,'):rep(#ids):sub(1, -2)
    if qbLike() and has('playerskins') then
        return MySQL.query.await(('SELECT citizenid, model, skin FROM playerskins WHERE active = 1 AND citizenid IN (%s)'):format(marks), ids) or {}
    end
    if DL.fw.id == 'esx' and has('users', 'skin') then
        return MySQL.query.await(('SELECT identifier AS citizenid, skin FROM users WHERE identifier IN (%s)'):format(marks), ids) or {}
    end
    return {}
end

-- The format is read per row: illenium on ESX keeps its own format in users.skin.
local function decode(row)
    if type(row.skin) ~= 'string' or #row.skin > MAX_BYTES then return nil end
    local ok, skin = pcall(json.decode, row.skin)
    return ok and shared.data(skin, row.model) or nil
end

-- A community script: { resource, apply, applyPlayer, creator, fetch } export names; its fetch replaces the tables.
function appearance.useHook(def)
    hook = shared.hookOf(def)
    if hook then appearance.id = hook.resource end
    return hook ~= nil
end

-- Clothing of many characters: { [citizenid] = data }. Skins over 64 KB are skipped.
function appearance.fetch(citizenids)
    local ids, seen, out = {}, {}, {}
    for _, cid in ipairs(type(citizenids) == 'table' and citizenids or {}) do
        if type(cid) == 'string' and cid ~= '' and not seen[cid] then
            seen[cid] = true
            ids[#ids + 1] = cid
        end
    end
    if #ids == 0 then return out end
    local ok, result = shared.callHook(hook, 'fetch', ids)
    if ok and type(result) == 'table' then return result end
    for first = 1, #ids, BATCH do
        for _, row in ipairs(rows(table.move(ids, first, math.min(first + BATCH - 1, #ids), 1, {}))) do
            out[row.citizenid] = decode(row)
        end
    end
    return out
end

function appearance.get(citizenid)
    return appearance.fetch({ citizenid })[citizenid]
end

function appearance.has(citizenid)
    return appearance.get(citizenid) ~= nil
end

-- For fivem-appearance, which has no save of its own. Freemode models (or serve's extra models) only.
function appearance.save(citizenid, data)
    local skin = type(data) == 'table' and data.skin
    if type(citizenid) ~= 'string' or citizenid == '' or shared.format(skin) ~= 'illenium' then return false end
    if not allowed[shared.modelOf({ skin = skin })] then return false end
    local encoded = json.encode(skin)
    if #encoded > MAX_BYTES then return false end
    if qbLike() and has('playerskins') then
        return MySQL.transaction.await({
            { query = 'UPDATE playerskins SET active = 0 WHERE citizenid = ?', values = { citizenid } },
            { query = 'INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, 1)', values = { citizenid, tostring(skin.model), encoded } },
        }) == true
    end
    if DL.fw.id == 'esx' and has('users', 'skin') then
        return (MySQL.update.await('UPDATE users SET skin = ? WHERE identifier = ?', { encoded, citizenid }) or 0) > 0
    end
    return false
end

-- Registers '<resource>:appearance:saved' and ':save' once. opts = { models = { names }, canSave = fn(source) }.
function appearance.serve(opts)
    if served then return end
    served, opts = true, type(opts) == 'table' and opts or {}
    for _, model in ipairs(opts.models or {}) do allowed[type(model) == 'number' and model or joaat(model)] = true end
    local limiter = DL.ratelimit.new({ saved = { capacity = 6, refill = 0.5 }, save = { capacity = 3, refill = 0.2 } })

    -- The character always comes from the session, never from the client.
    lib.callback.register(DL.resource .. ':appearance:saved', function(source)
        if not limiter.take(source, 'saved') then return false end
        local cid = DL.fw.citizenId(source)
        return cid ~= nil and appearance.has(cid)
    end)

    lib.callback.register(DL.resource .. ':appearance:save', function(source, skin)
        if appearance.current() ~= 'fivem' or not limiter.take(source, 'save') then return false end
        if opts.canSave and not opts.canSave(source) then return false end
        local cid = DL.fw.citizenId(source)
        return cid ~= nil and appearance.save(cid, { skin = skin })
    end)

    AddEventHandler('playerDropped', function() limiter.forget(source) end)
end

return appearance
