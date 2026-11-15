-- Core: texts, small helpers and the garage list, the same on both sides.
Core = Core or {}

-- Texts from Locales in Config.Locale; a key missing there falls back to English, then to the key itself.
do
    local function find(node, key)
        for part in key:gmatch('[^.]+') do
            node = type(node) == 'table' and node[part] or nil
        end
        return type(node) == 'string' and node or nil
    end

    function Core.language()
        return Locales and Locales[Config.Locale] and Config.Locale or 'en'
    end

    function Core.locale()
        return Locales and Locales[Core.language()] or {}
    end

    -- t('msg.not_owner', ...) -> the formatted text.
    function Core.t(key, ...)
        local text = find(Core.locale(), key) or find(Locales and Locales.en, key)
        if not text then return key end
        return select('#', ...) > 0 and text:format(...) or text
    end
end

do
    -- Trimmed text, nil when empty; max cuts it.
    function Core.trim(value, max)
        if type(value) ~= 'string' then return nil end
        local out = value:match('^%s*(.-)%s*$')
        if out == '' then return nil end
        return max and out:sub(1, max) or out
    end

    -- A plate as compared everywhere: no padding, upper case.
    function Core.plate(value)
        local plate = Core.trim(tostring(value or ''))
        return plate and plate:upper() or nil
    end

    -- A database flag as a boolean (oxmysql gives TINYINT(1) as booleans, other drivers as numbers).
    function Core.flag(value)
        return value == true or value == 1 or value == '1'
    end

    -- JSON text (or a table) as a table; {} for anything else.
    function Core.decode(value)
        if type(value) == 'table' then return value end
        if type(value) ~= 'string' or value == '' then return {} end
        local ok, decoded = pcall(json.decode, value)
        return ok and type(decoded) == 'table' and decoded or {}
    end

    function Core.contains(list, value)
        for _, item in ipairs(list or {}) do
            if item == value then return true end
        end
        return false
    end

    -- A finite number clamped to [lo, hi], or fallback when nil / NaN / ±Inf.
    function Core.num(value, lo, hi, fallback)
        local n = tonumber(value)
        if not n or n ~= n or n == math.huge or n == -math.huge then return fallback end
        if lo and n < lo then n = lo end
        if hi and n > hi then n = hi end
        return n
    end

    -- A vector4 from a vector4, a vector3 (heading 0) or a { x, y, z, w | h | heading } table; nil otherwise.
    function Core.vec4(v)
        local kind = type(v)
        if kind == 'vector4' then return v end
        if kind == 'vector3' then return vector4(v.x, v.y, v.z, 0.0) end
        if kind == 'table' then
            local x, y, z = Core.num(v.x), Core.num(v.y), Core.num(v.z)
            if x and y and z then
                return vector4(x + 0.0, y + 0.0, z + 0.0, (Core.num(v.w or v.h or v.heading, nil, nil, 0.0)) + 0.0)
            end
        end
        return nil
    end

    function Core.vec3(v)
        local p = Core.vec4(v)
        return p and vector3(p.x, p.y, p.z) or nil
    end

    -- A vector as a plain table, for state bags and the page.
    function Core.plain(v)
        return v and { x = v.x, y = v.y, z = v.z, w = v.w } or nil
    end
end

-- Garages: the config tables (jg format) and the extra ones the server shares (admin panel, other scripts) as one
-- list of the same shape: { id, label, kind, type, coords, spawns, show, distance, blip, markers, job, gang,
-- vehiclesType, vehicles, owners }.
do
    local KINDS = {
        { table = 'GarageLocations', kind = 'public' },
        { table = 'JobGarageLocations', kind = 'job' },
        { table = 'GangGarageLocations', kind = 'gang' },
        { table = 'ImpoundLocations', kind = 'impound', off = function() return Config.Impound and Config.Impound.Enabled == false end },
    }
    local TYPES = { car = true, sea = true, air = true }

    local function list(value)
        if type(value) == 'string' then return { value } end
        return type(value) == 'table' and value or nil
    end

    -- One garage from a jg-style entry; nil when it has no usable spot.
    function Core.garage(id, raw, kind)
        local coords = Core.vec3(raw.coords)
        if not coords then return nil end
        local spawns = {}
        local first = raw.spawn or raw.spawns
        if Core.vec4(first) then
            spawns[1] = Core.vec4(first)
        elseif type(first) == 'table' then
            for _, s in ipairs(first) do spawns[#spawns + 1] = Core.vec4(s) end
        end
        if #spawns == 0 then spawns[1] = vector4(coords.x, coords.y, coords.z, 0.0) end
        local blip = raw.blip
        return {
            id = tostring(id),
            label = raw.label or tostring(id),
            kind = raw.kind or kind,
            type = TYPES[raw.type] and raw.type or 'car',
            coords = coords,
            spawns = spawns,
            show = Core.vec4(raw.show),
            distance = tonumber(raw.distance) or 12.0,
            blip = raw.hideBlip ~= true and {
                sprite = type(blip) == 'table' and tonumber(blip.id) or nil,
                colour = type(blip) == 'table' and tonumber(blip.color or blip.colour) or nil,
                scale = type(blip) == 'table' and tonumber(blip.scale) or nil,
            } or false,
            markers = raw.hideMarkers ~= true,
            job = list(raw.job),
            gang = list(raw.gang),
            vehiclesType = raw.vehiclesType or 'personal',
            vehicles = type(raw.vehicles) == 'table' and raw.vehicles or nil,
            owners = type(raw.owners) == 'table' and raw.owners or nil,
            owner = type(raw.owner) == 'string' and raw.owner or nil,
            capacity = tonumber(raw.capacity),
        }
    end

    -- Every garage by id: the config ones, then the extra ones (which may replace a config one by id).
    function Core.garages(extra)
        local out = {}
        for _, group in ipairs(KINDS) do
            if not (group.off and group.off()) then
                for id, raw in pairs(Config[group.table] or {}) do
                    out[tostring(id)] = Core.garage(id, raw, group.kind)
                end
            end
        end
        -- with the impound off (Config.Impound.Enabled) no lot is a garage, the ones added in game neither
        local noLots = Config.Impound and Config.Impound.Enabled == false
        for id, raw in pairs(extra or {}) do
            if not (noLots and raw.kind == 'impound') then out[tostring(id)] = Core.garage(id, raw, raw.kind or 'public') end
        end
        return out
    end

    -- Whether a vehicle type ('automobile', 'bike', 'boat', 'heli', 'plane', 'submarine' ...) fits a garage type.
    function Core.fits(garageType, vehicleType)
        if vehicleType == 'boat' or vehicleType == 'submarine' then return garageType == 'sea' end
        if vehicleType == 'heli' or vehicleType == 'plane' or vehicleType == 'blimp' then return garageType == 'air' end
        return garageType == 'car'
    end

    -- Whether a garage has the walk-in room: car garages of the kinds Config.Interior lists.
    function Core.walkable(garage)
        local cfg = Config.Interior
        return cfg.Enabled == true and garage ~= nil and garage.type == 'car' and cfg.Kinds[garage.kind] == true
    end

    -- The garage type a vehicle type belongs to.
    function Core.typeOf(vehicleType)
        if vehicleType == 'boat' or vehicleType == 'submarine' then return 'sea' end
        if vehicleType == 'heli' or vehicleType == 'plane' or vehicleType == 'blimp' then return 'air' end
        return 'car'
    end
end
