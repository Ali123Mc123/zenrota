-- Bridge: everything Garages asks of your framework, fuel, keys, notifications and interaction scripts.
-- Every file in bridge/ is open: change it to fit your server. The product only calls the names below.
--
--   Bridge.fw        framework: identifier, name, job, gang, money, admin, the vehicle table and its columns
--   Bridge.fuel      get / set a car's fuel (client)
--   Bridge.keys      give the keys of a car to its driver (client)
--   Bridge.notify    a short notice (client)
--   Bridge.interact  how a garage is opened: the built-in prompt, a target or a text UI (client)
--
-- Which script is used comes from Config.Bridge in config/cfg_main.lua ('auto' finds the one that runs).
-- Adding one: copy an entry in its file, rename it, change the calls, and add its resource to the AUTO list there.
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

-- Server: whether a table (or one of its columns) exists, asked once.
if Bridge.side == 'server' then
    local cache = {}

    function Bridge.has(tableName, column)
        local key = tableName .. '.' .. (column or '')
        if cache[key] == nil then
            local sql = column
                and 'SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ? LIMIT 1'
                or 'SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? LIMIT 1'
            cache[key] = MySQL.scalar.await(sql, column and { tableName, column } or { tableName }) ~= nil
        end
        return cache[key]
    end

    function Bridge.forget(tableName, column)
        cache[tableName .. '.' .. (column or '')] = nil
    end
end
