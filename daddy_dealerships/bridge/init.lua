-- Bridge: everything Dealerships asks of your framework, fuel, keys, notifications and interaction scripts.
-- Every file in bridge/ is open: change it to fit your server. The product only calls the names below.
--
--   Bridge.fw        framework: identifier, name, job, money, paying, writing a bought car
--   Bridge.fuel      set a new car's fuel (client)
--   Bridge.keys      give the keys of a new car to its buyer (client)
--   Bridge.notify    a short notice (client)
--   Bridge.hint      the "open the showroom" hint (client)
--
-- Which script is used comes from Config.Bridge in config/cfg_main.lua ('auto' finds the one that runs).
Bridge = {
    side = IsDuplicityVersion() and 'server' or 'client',
    resource = GetCurrentResourceName(),
}

function Bridge.started(resource)
    return type(resource) == 'string' and GetResourceState(resource) == 'started'
end

function Bridge.warn(text, ...)
    print(('^3[%s] ' .. text .. '^7'):format(Bridge.resource, ...))
end

-- The first entry of a list whose resource runs, or the one Config.Bridge names.
function Bridge.pick(setting, entries)
    local wanted = (Config.Bridge or {})[setting]
    if type(wanted) == 'string' and wanted ~= 'auto' then
        for _, entry in ipairs(entries) do
            if entry.id == wanted then return entry end
        end
        return nil
    end
    for _, entry in ipairs(entries) do
        if entry.resource and Bridge.started(entry.resource) then return entry end
    end
    return nil
end

-- Server: whether a table exists, asked once.
if Bridge.side == 'server' then
    local cache = {}

    function Bridge.has(tableName)
        if cache[tableName] == nil then
            cache[tableName] = MySQL.scalar.await('SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? LIMIT 1', { tableName }) ~= nil
        end
        return cache[tableName]
    end

    -- Whether a table has a column, asked once.
    function Bridge.column(tableName, column)
        local key = tableName .. '.' .. column
        if cache[key] == nil then
            cache[key] = MySQL.scalar.await('SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ? LIMIT 1', { tableName, column }) ~= nil
        end
        return cache[key]
    end
end
