-- Core: texts, small helpers, jobs and alert types, the same on both sides.
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

    -- t('msg.joined', ...) -> the formatted text.
    function Core.t(key, ...)
        local text = find(Core.locale(), key) or find(Locales and Locales.en, key)
        if not text then return key end
        return select('#', ...) > 0 and text:format(...) or text
    end
end

do
    -- Trimmed text, nil when empty; max cuts it (bytes, 1024 when not given). It ends before the first half letter or
    -- broken byte: the database refuses them, and one bad value would fail a whole batched write.
    function Core.trim(value, max)
        if type(value) ~= 'string' then return nil end
        max = max or 1024
        if #value > max * 4 then value = value:sub(1, max * 4) end
        local out = value:gsub('[%c]', ' '):match('^%s*(.-)%s*$')
        if #out > max then out = out:sub(1, max) end
        local ok, bad = utf8.len(out)
        if not ok then out = out:sub(1, bad - 1):match('^(.-)%s*$') end
        return out ~= '' and out or nil
    end

    -- A finite number, or nil: NaN and infinity sent by a client never get through.
    function Core.num(v)
        v = tonumber(v)
        if not v or v ~= v or v == math.huge or v == -math.huge then return nil end
        return v
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

    -- A vector3 from a vector, a { x, y, z } table or x, y, z; nil otherwise.
    function Core.vec3(v)
        local kind = type(v)
        if kind ~= 'vector3' and kind ~= 'vector4' and kind ~= 'table' then return nil end
        local x, y, z = Core.num(v.x), Core.num(v.y), Core.num(v.z) or 0.0
        if not x or not y then return nil end
        return vector3(x + 0.0, y + 0.0, z + 0.0)
    end

    -- A vector as a plain table, for events and the page.
    function Core.plain(v)
        return v and { x = math.floor(v.x * 10 + 0.5) / 10, y = math.floor(v.y * 10 + 0.5) / 10, z = math.floor(v.z * 10 + 0.5) / 10 } or nil
    end

    function Core.clamp(v, lo, hi)
        v = Core.num(v) or lo
        return v < lo and lo or v > hi and hi or v
    end

    -- A deep copy of plain data.
    function Core.copy(v)
        if type(v) ~= 'table' then return v end
        local out = {}
        for k, item in pairs(v) do out[k] = Core.copy(item) end
        return out
    end
end

-- Jobs: the group a job belongs to (Config.Jobs), and the job names a list of groups and jobs stands for.
do
    function Core.group(job)
        return job and Config.Jobs[job] or nil
    end

    -- Whether a job works the dispatch at all.
    function Core.isDispatchJob(job)
        return Core.group(job) ~= nil
    end

    -- Whether job is in a list of groups or job names.
    function Core.inList(job, list)
        if not job then return false end
        local group = Core.group(job)
        for _, entry in ipairs(list or {}) do
            if entry == job or (group and entry == group) then return true end
        end
        return false
    end
end

-- Alert types: the config entry with its title filled in; unknown types fall back to custom.
do
    function Core.alertType(name)
        local def = Config.Alerts[name]
        if not def then return nil end
        return def
    end

    function Core.title(name, ...)
        local def = Config.Alerts[name]
        if def and def.title then return def.title end
        return Core.t('alerts.' .. name, ...)
    end

    -- Statuses a unit can be in; available, busy and break are the ones a player picks.
    Core.STATUSES = { available = true, busy = true, enroute = true, onscene = true, ['break'] = true }
    Core.PICKABLE = { 'available', 'busy', 'break' }

    -- The type whose code another script's alert carries ('10-52' -> player_down), or nil.
    function Core.typeOfCode(code)
        if type(code) ~= 'string' or code == '' then return nil end
        for name, def in pairs(Config.Alerts) do
            if def.code == code and name ~= 'custom' then return name end
        end
        return nil
    end

    -- Our icon for another script's icon name (Font Awesome words), or nil.
    local WORDS = {
        { 'gun', 'gun' }, { 'pistol', 'gun' }, { 'crosshair', 'gun' }, { 'car', 'car' }, { 'truck', 'car' },
        { 'motorcycle', 'car' }, { 'injured', 'med' }, { 'heart', 'med' }, { 'ambulance', 'med' }, { 'medkit', 'med' },
        { 'skull', 'med' }, { 'fire', 'fire' }, { 'explosion', 'fire' }, { 'bomb', 'fire' }, { 'house', 'house' },
        { 'home', 'house' }, { 'store', 'store' }, { 'shop', 'store' }, { 'bank', 'bank' }, { 'columns', 'bank' },
        { 'vault', 'bank' }, { 'gem', 'case' }, { 'sack', 'case' }, { 'phone', 'phone' }, { 'secret', 'eye' },
        { 'eye', 'eye' }, { 'mask', 'eye' }, { 'running', 'lock' }, { 'lock', 'lock' }, { 'jail', 'lock' },
        { 'pills', 'pill' }, { 'cannabis', 'pill' }, { 'fist', 'fist' }, { 'hand', 'fist' }, { 'shield', 'badge' },
        { 'badge', 'badge' }, { 'siren', 'siren' }, { 'bell', 'siren' }, { 'radio', 'radio' }, { 'news', 'news' },
    }

    function Core.iconOf(name)
        if type(name) ~= 'string' then return nil end
        name = name:lower()
        for _, w in ipairs(WORDS) do
            if name:find(w[1], 1, true) then return w[2] end
        end
        return nil
    end
end
