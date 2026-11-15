-- qb-apartments: one apartment per character; the door comes from the script's own config.lua.
local has = DL.require('fw/schema')
local readConfig = DL.require('housing/config')

local function home(row, inside)
    local env = readConfig('qb-apartments', 'config.lua')
    local place = env and env.Apartments and env.Apartments.Locations and env.Apartments.Locations[row.type]
    if not (place and place.coords and place.coords.enter) then return nil end
    return { id = row.name, kind = 'apartment', label = row.label or place.label, coords = place.coords.enter, inside = inside, meta = { type = row.type } }
end

return {
    resource = 'qb-apartments',

    server = {
        homes = function(citizenid)
            if not has('apartments', 'citizenid') then return {} end
            local out = {}
            for _, row in ipairs(MySQL.query.await('SELECT name, type, label FROM apartments WHERE citizenid = ?', { citizenid }) or {}) do
                out[#out + 1] = home(row, true)
            end
            return out
        end,

        -- metadata.inside.apartment is written while a character is inside its own apartment.
        resume = function(citizenid, raw)
            local inside = (((raw.metadata or {}).inside or {}).apartment) or {}
            if not inside.apartmentId or not has('apartments', 'citizenid') then return nil end
            local row = MySQL.single.await('SELECT name, type, label, citizenid FROM apartments WHERE name = ?', { tostring(inside.apartmentId) })
            return row and home(row, row.citizenid == citizenid) or nil
        end,
    },

    client = {
        enter = function(entry)
            if not entry.meta or not entry.meta.type then return false end
            TriggerEvent('qb-apartments:client:LastLocationHouse', entry.meta.type, entry.id)
            return true
        end,
    },
}
