-- Versioned migrations. Each step is one SQL statement.
--   DL.migrate.define(1, { 'CREATE TABLE ...', 'CREATE INDEX ...' })
--   DL.migrate.run()  -- after DL.product.register
local migrate = { list = {}, done = false }

local LOCK_SECONDS = 60

function migrate.define(version, steps)
    migrate.list[#migrate.list + 1] = { version = version, steps = steps }
end

local function checksum(steps)
    return ('%08x'):format(GetHashKey(table.concat(steps, '\n')) & 0xffffffff)
end

-- A row lease, so two servers on one database never migrate at once.
local function lock(product, holder)
    MySQL.query.await([[
        INSERT INTO daddy_lib_migration_locks (product, holder, expires_at)
        VALUES (?, ?, NOW() + INTERVAL ? SECOND)
        ON DUPLICATE KEY UPDATE
            holder = IF(expires_at < NOW(), VALUES(holder), holder),
            expires_at = IF(expires_at < NOW(), VALUES(expires_at), expires_at)
    ]], { product, holder, LOCK_SECONDS })
    local owner = MySQL.scalar.await('SELECT holder FROM daddy_lib_migration_locks WHERE product = ?', { product })
    return owner == holder
end

local function unlock(product, holder)
    MySQL.update.await('DELETE FROM daddy_lib_migration_locks WHERE product = ? AND holder = ?', { product, holder })
end

local function applied(product)
    local out = {}
    for _, row in ipairs(MySQL.query.await('SELECT version FROM daddy_lib_migrations WHERE product = ?', { product }) or {}) do
        out[row.version] = true
    end
    return out
end

function migrate.run()
    local product = DL.product.id
    assert(product, 'call DL.product.register before DL.migrate.run')
    DL.product.awaitLib()

    local holder = ('%s:%d'):format(DL.resource, math.random(1, 0x7fffffff))
    while not lock(product, holder) do Wait(1000) end

    local ok, err = pcall(function()
        local done = applied(product)
        table.sort(migrate.list, function(a, b) return a.version < b.version end)
        for _, migration in ipairs(migrate.list) do
            if not done[migration.version] then
                for _, sql in ipairs(migration.steps) do MySQL.query.await(sql) end
                MySQL.insert.await('INSERT INTO daddy_lib_migrations (product, version, checksum) VALUES (?, ?, ?)',
                    { product, migration.version, checksum(migration.steps) })
            end
        end
    end)

    unlock(product, holder)
    if not ok then error(('%s migration failed: %s'):format(product, err)) end
    migrate.done = true
end

function migrate.await()
    while not migrate.done do Wait(100) end
end

return migrate
