-- Core: texts, small helpers and the dealership list, the same on both sides.
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

    function Core.t(key, ...)
        local text = find(Core.locale(), key) or find(Locales and Locales.en, key)
        if not text then return key end
        return select('#', ...) > 0 and text:format(...) or text
    end
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

-- A line in the console while Config.Debug is on.
function Core.debug(text, ...)
    if Config.Debug then print(('^5[%s] ' .. text .. '^7'):format(GetCurrentResourceName(), ...)) end
end

-- A finite number clamped to [lo, hi], or fallback when nil / NaN / ±Inf.
function Core.num(value, lo, hi, fallback)
    local n = tonumber(value)
    if not n or n ~= n or n == math.huge or n == -math.huge then return fallback end
    if lo and n < lo then n = lo end
    if hi and n > hi then n = hi end
    return n
end

-- Money as the server shows it: Config.Currency around the amount with thousands dots.
function Core.money(n)
    local s = tostring(math.floor(tonumber(n) or 0)):reverse():gsub('(%d%d%d)', '%1.'):reverse():gsub('^%.', '')
    return Config.Currency:format(s)
end

-- The dealerships with their defaults filled in: Dealers.all[id], Dealers.get(id).
Dealers = { all = {} }
do
    for id, d in pairs(Config.Dealerships or {}) do
        Dealers.all[id] = {
            id = id,
            label = d.label or id,
            disabled = d.disabled == true,
            type = d.type == 'owned' and 'owned' or 'self-service',
            job = d.job,
            open = d.open and d.open.coords,
            size = d.open and d.open.size or 2.0,
            manage = d.manage,
            sell = d.sell,
            sellOn = false,
            sellPercent = math.floor((Config.Prices.SellBack or 0.6) * 100 + 0.5),
            spawn = d.spawn,
            drive = d.drive,
            testDrive = d.drive ~= nil and d.testDrive ~= false,
            finance = d.finance == true,
            commission = tonumber(d.commission) or 10,
            colours = d.colours == nil and 'palette' or d.colours,
            driveMode = d.testDrive == 'staff' and 'staff' or 'self',
            categories = d.categories or {},
            blip = d.blip,
            hall = d.hall,
            -- the server fills these from jg's dealership_locations (server/sv_main.lua)
            perms = {}, accounts = Config.Purchase.Accounts, jobs = {}, gangs = {}, showroomJobs = {}, showroomGangs = {},
        }
    end

    function Dealers.get(id)
        return type(id) == 'string' and Dealers.all[id] or nil
    end
end
