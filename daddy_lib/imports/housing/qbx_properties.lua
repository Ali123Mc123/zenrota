-- qbx_properties: owned properties and apartments; entering uses its spawn event, the same call qbx_spawn makes.
local has = DL.require('fw/schema')

-- ps-housing also has a properties table; property_name is qbx_properties' own column.
local function ready()
    return has('properties', 'property_name') and has('properties', 'owner')
end

local function home(row, inside)
    return { id = row.id, kind = 'property', label = row.property_name, coords = row.coords, inside = inside }
end

return {
    resource = 'qbx_properties',

    server = {
        homes = function(citizenid)
            if not ready() then return {} end
            local out = {}
            for _, row in ipairs(MySQL.query.await('SELECT id, property_name, coords FROM properties WHERE owner = ?', { citizenid }) or {}) do
                out[#out + 1] = home(row, true)
            end
            return out
        end,

        -- currentPropertyId stays set when a character logs out inside; keyholders get back in too.
        resume = function(citizenid, raw)
            local id = tonumber((raw.metadata or {}).currentPropertyId)
            if not id or not ready() then return nil end
            local row = MySQL.single.await('SELECT id, property_name, coords, owner, keyholders FROM properties WHERE id = ?', { id })
            if not row then return nil end
            return home(row, row.owner == citizenid or DL.util.contains(DL.util.decodeJson(row.keyholders), citizenid))
        end,
    },

    client = {
        enter = function(entry)
            TriggerServerEvent('qbx_properties:server:enterProperty', { id = entry.id, isSpawn = true })
            return true
        end,
    },
}
