-- Whether an optional framework table (or one of its columns) exists, looked up once: vehicles and identity
-- come from add-ons a server may not run.
local known = {}

local TABLE = 'SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?'
local COLUMN = 'SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?'

return function(name, column)
    local key = column and ('%s.%s'):format(name, column) or name
    if known[key] == nil then
        known[key] = (tonumber(MySQL.scalar.await(column and COLUMN or TABLE, { name, column })) or 0) > 0
    end
    return known[key]
end
