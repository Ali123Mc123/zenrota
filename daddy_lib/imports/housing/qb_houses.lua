-- qb-houses: owned houses; its client needs the house list pushed at login, as qb-multicharacter does.
local has = DL.require('fw/schema')

local function ready()
    return has('player_houses', 'citizenid') and has('houselocations', 'coords')
end

local function home(row, inside)
    return { id = row.house, kind = 'house', label = row.label, coords = DL.util.decodeJson(row.coords).enter, inside = inside }
end

return {
    resource = 'qb-houses',

    server = {
        homes = function(citizenid)
            if not ready() then return {} end
            local out = {}
            local sql = 'SELECT ph.house, hl.label, hl.coords FROM player_houses ph JOIN houselocations hl ON hl.name = ph.house WHERE ph.citizenid = ?'
            for _, row in ipairs(MySQL.query.await(sql, { citizenid }) or {}) do out[#out + 1] = home(row, true) end
            return out
        end,

        -- metadata.inside.house; owners and keyholders go back in, anyone else is left at the door.
        resume = function(citizenid, raw)
            local house = ((raw.metadata or {}).inside or {}).house
            if type(house) ~= 'string' or not ready() then return nil end
            local sql = 'SELECT hl.name AS house, hl.label, hl.coords, ph.citizenid, ph.keyholders FROM houselocations hl LEFT JOIN player_houses ph ON ph.house = hl.name WHERE hl.name = ? LIMIT 1'
            local row = MySQL.single.await(sql, { house })
            if not row then return nil end
            return home(row, row.citizenid == citizenid or DL.util.contains(DL.util.decodeJson(row.keyholders), citizenid))
        end,

        -- qb-multicharacter's loadHouseData: house and garage config for the qb-houses and qb-garages clients.
        onLogin = function(source)
            if not has('houselocations', 'coords') then return end
            local houses, garages = {}, {}
            for _, row in ipairs(MySQL.query.await('SELECT * FROM houselocations') or {}) do
                local garage = DL.util.decodeJson(row.garage)
                houses[row.name] = { coords = DL.util.decodeJson(row.coords), owned = tonumber(row.owned) == 1 or row.owned == true, price = row.price,
                    locked = true, adress = row.label, tier = row.tier, garage = garage, decorations = {} }
                garages[row.name] = { label = row.label, takeVehicle = garage }
            end
            TriggerClientEvent('qb-garages:client:houseGarageConfig', source, garages)
            TriggerClientEvent('qb-houses:client:setHouseConfig', source, houses)
        end,
    },

    client = {
        enter = function(entry)
            TriggerEvent('qb-houses:client:enterOwnedHouse', entry.id)
            return true
        end,
    },
}
