-- qbx_properties: owned properties and apartments; entering uses its spawn event, the same call qbx_spawn makes.
do
    local has = Bridge.has

    -- ps-housing also has a properties table; property_name is qbx_properties' own column.
    local function ready()
        return has('properties', 'property_name') and has('properties', 'owner')
    end

    local function home(row, inside)
        return { id = row.id, kind = 'property', label = row.property_name, coords = row.coords, inside = inside }
    end

    Bridge.homes.qbx_properties = {
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
                return home(row, row.owner == citizenid or Core.util.contains(Core.util.decodeJson(row.keyholders), citizenid))
            end,
        },

        client = {
            enter = function(entry)
                TriggerServerEvent('qbx_properties:server:enterProperty', { id = entry.id, isSpawn = true })
                return true
            end,
        },
    }
end

-- qb-apartments: one apartment per character; the door comes from the script's own config.lua.
do
    local has = Bridge.has
    local config

    local function home(row, inside)
        if config == nil then config = Bridge.readConfig('qb-apartments', 'config.lua') or false end
        local env = config or nil
        local place = env and env.Apartments and env.Apartments.Locations and env.Apartments.Locations[row.type]
        if not (place and place.coords and place.coords.enter) then return nil end
        return { id = row.name, kind = 'apartment', label = row.label or place.label, coords = place.coords.enter, inside = inside, meta = { type = row.type } }
    end

    Bridge.homes.qb_apartments = {
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
end

-- qb-houses: owned houses; its client needs the house list pushed at login, as qb-multicharacter does.
do
    local has = Bridge.has

    local function ready()
        return has('player_houses', 'citizenid') and has('houselocations', 'coords')
    end

    local function home(row, inside)
        return { id = row.house, kind = 'house', label = row.label, coords = Core.util.decodeJson(row.coords).enter, inside = inside }
    end

    Bridge.homes.qb_houses = {
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
                return home(row, row.citizenid == citizenid or Core.util.contains(Core.util.decodeJson(row.keyholders), citizenid))
            end,

            -- qb-multicharacter's loadHouseData: house and garage config for the qb-houses and qb-garages clients.
            onLogin = function(source)
                if not has('houselocations', 'coords') then return end
                local houses, garages = {}, {}
                for _, row in ipairs(MySQL.query.await('SELECT * FROM houselocations') or {}) do
                    local garage = Core.util.decodeJson(row.garage)
                    houses[row.name] = { coords = Core.util.decodeJson(row.coords), owned = tonumber(row.owned) == 1 or row.owned == true, price = row.price,
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
end

-- ps-housing [unverified: not on this machine]. Columns and events follow its README; every step is guarded.
do
    local has = Bridge.has

    -- qbx_properties also has a properties table; owner_citizenid is ps-housing's own column.
    local function ready()
        return has('properties', 'owner_citizenid') and has('properties', 'property_id') and has('properties', 'door_data')
    end

    local function home(row, inside)
        local label = row.street or row.apartment or tostring(row.property_id)
        return { id = row.property_id, kind = row.apartment and 'apartment' or 'house', label = label, coords = Core.util.decodeJson(row.door_data), inside = inside }
    end

    Bridge.homes.ps_housing = {
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
end

-- esx_property: owners live in its memory, saved to properties.json every few minutes. Its shell entry is client-local,
-- so homes spawn at the door; after login it puts a character back inside by itself (users.last_property).
do
    local function label(property)
        return (property.setName and property.setName ~= '') and property.setName or property.Name
    end

    -- The live list; the file can be minutes old, so it is only the fallback.
    local function properties()
        local ok, list = pcall(function() return exports.esx_property:GetProperties() end)
        if ok and type(list) == 'table' then return list end
        return Core.util.decodeJson(LoadResourceFile('esx_property', 'properties.json'))
    end

    Bridge.homes.esx_property = {
        resource = 'esx_property',

        server = {
            homes = function(citizenid)
                local out = {}
                for index, property in ipairs(properties()) do
                    if type(property) == 'table' and property.Owner == citizenid and property.Entrance then
                        out[#out + 1] = { id = index, kind = 'house', label = label(property), coords = property.Entrance, inside = false }
                    end
                end
                return out
            end,
        },

        client = {
            enter = function() return false end,
        },
    }
end

-- Builds Bridge.housing: homes for the spawn selector from Config.Bridge.Housing ('auto' = every script that runs,
-- a comma list such as 'qbx_properties,qb_houses', or 'none'). The multichar:housing convar overrides 'auto'.
-- Entry: { key = '<provider>:<id>', provider, id, kind, label, coords = vector4, inside, meta }; inside = enter() places the player.
do
    local PROVIDERS = { 'qbx_properties', 'qb_apartments', 'qb_houses', 'ps_housing', 'esx_property' }

    local function wanted()
        local value = Bridge.setting('Housing', 'housing')
        if value == 'auto' then return PROVIDERS end
        local list = {}
        for id in value:gmatch('[^,%s]+') do
            if Bridge.homes[id] then list[#list + 1] = id end
        end
        return list
    end

    -- JSON text, vector or { x, y, z, w|h|heading } as a vector4; nil without a position.
    local function vec(value)
        if type(value) == 'string' then value = Core.util.decodeJson(value) end
        local kind = type(value)
        if kind == 'vector3' or kind == 'vector4' then return vector4(value.x, value.y, value.z, kind == 'vector4' and value.w or 0.0) end
        if kind ~= 'table' then return nil end
        local x, y, z = tonumber(value.x or value[1]), tonumber(value.y or value[2]), tonumber(value.z or value[3])
        if not (x and y and z) then return nil end
        return vector4(x, y, z, tonumber(value.w or value.h or value.heading or value[4]) or 0.0)
    end

    local function server()
        local housing = { ids = {} }
        local loaded = {}
        for _, id in ipairs(wanted()) do
            local adapter = Bridge.homes[id]
            if adapter then
                loaded[#loaded + 1] = { id = id, adapter = adapter }
                if Bridge.started(adapter.resource) then housing.ids[#housing.ids + 1] = id end
            end
        end

        -- Adapters whose script runs right now.
        local function active()
            local list = {}
            for _, entry in ipairs(loaded) do
                if Bridge.started(entry.adapter.resource) then list[#list + 1] = entry end
            end
            return list
        end

        local function call(provider, name, ...)
            local fn = provider.adapter.server[name]
            if not fn then return nil end
            local ok, result = pcall(fn, ...)
            if not ok then Bridge.warn('housing %s.%s failed: %s', provider.id, name, result) end
            return ok and result or nil
        end

        local function entry(provider, home)
            local coords = type(home) == 'table' and home.id ~= nil and vec(home.coords)
            if not coords then return nil end
            return { key = ('%s:%s'):format(provider.id, home.id), provider = provider.id, id = home.id, kind = home.kind or 'house',
                label = tostring(home.label or home.id), coords = coords, inside = home.inside == true, meta = home.meta }
        end

        function housing.homes(citizenid)
            local out = {}
            if type(citizenid) ~= 'string' or citizenid == '' then return out end
            for _, provider in ipairs(active()) do
                for _, home in ipairs(call(provider, 'homes', citizenid) or {}) do out[#out + 1] = entry(provider, home) end
            end
            return out
        end

        -- Checks a key a client picked against the character's own homes.
        function housing.find(citizenid, key)
            if type(key) ~= 'string' then return nil end
            for _, home in ipairs(housing.homes(citizenid)) do
                if home.key == key then return home end
            end
            return nil
        end

        -- The home a character logged out inside, from its framework metadata (raw = { charinfo, metadata }).
        function housing.resume(citizenid, raw)
            if type(citizenid) ~= 'string' or type(raw) ~= 'table' then return nil end
            for _, provider in ipairs(active()) do
                local home = entry(provider, call(provider, 'resume', citizenid, raw))
                if home then return home end
            end
            return nil
        end

        -- After a character loads: scripts that need data pushed to the client (qb-houses).
        function housing.onLogin(source)
            for _, provider in ipairs(active()) do call(provider, 'onLogin', source) end
        end

        return housing
    end

    local function client()
        local housing = {}

        -- Call after chars.login and chars.spawned. True when the script placed the player; false means teleport to entry.coords.
        function housing.enter(entry)
            if type(entry) ~= 'table' or entry.inside ~= true then return false end
            local adapter = Bridge.homes[entry.provider]
            if not adapter or not Bridge.started(adapter.resource) then return false end
            local ok, placed = pcall(adapter.client.enter, entry)
            return ok and placed == true
        end

        return housing
    end

    Bridge.define('housing', function()
        if Bridge.side == 'client' then return client() end
        return server()
    end)
end
