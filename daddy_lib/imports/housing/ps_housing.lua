-- ps-housing [unverified: not on this machine]. Columns and events follow its README; every step is guarded.
local has = DL.require('fw/schema')

-- qbx_properties also has a properties table; owner_citizenid is ps-housing's own column.
local function ready()
    return has('properties', 'owner_citizenid') and has('properties', 'property_id') and has('properties', 'door_data')
end

local function home(row, inside)
    local label = row.street or row.apartment or tostring(row.property_id)
    return { id = row.property_id, kind = row.apartment and 'apartment' or 'house', label = label, coords = DL.util.decodeJson(row.door_data), inside = inside }
end

return {
    resource = 'ps-housing',

    server = {
        homes = function(citizenid)
            if not ready() then return {} end
            local out = {}
            local sql = 'SELECT property_id, street, apartment, door_data FROM properties WHERE owner_citizenid = ?'
            for _, row in ipairs(MySQL.query.await(sql, { citizenid }) or {}) do out[#out + 1] = home(row, true) end
            return out
        end,

        -- metadata.inside.property_id, as its qb-spawn edit reads it.
        resume = function(citizenid, raw)
            local id = ((raw.metadata or {}).inside or {}).property_id
            if not id or not ready() then return nil end
            local row = MySQL.single.await('SELECT property_id, street, apartment, door_data, owner_citizenid FROM properties WHERE property_id = ?', { tostring(id) })
            return row and home(row, row.owner_citizenid == citizenid) or nil
        end,
    },

    client = {
        enter = function(entry)
            TriggerServerEvent('ps-housing:server:enterProperty', tostring(entry.id))
            return true
        end,
    },
}
