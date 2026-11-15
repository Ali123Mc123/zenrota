-- ============================================================================
-- Daddy GPS - Shared Utility Functions
-- ============================================================================
-- Common functions used across client and server scripts
-- ============================================================================

-- Trim whitespace from string
function trim(s)
    if not s then return "" end
    s = tostring(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Normalize department key (handle ambulance/ems → lsms conversion)
function NormalizeDeptKey(key)
    if not key then return nil end
    local k = tostring(key):lower()
    if k == 'ambulance' or k == 'ems' then return 'lsms' end
    if k == 'ranger' then return 'sapr' end
    if k == 'sheriff' then return 'bcso' end
    if k == 'state' or k == 'trooper' then return 'sasp' end
    return k
end

-- Resolve department key from various input formats (string, table, etc.)
function ResolveDeptKeyFromUserInput(input)
    if type(input) == "table" then
        if input.key then return NormalizeDeptKey(input.key) end
        if input.value then
            local v = NormalizeDeptKey(input.value)
            if v and Config.Departments[v] then return v end
        end
        if input.label then 
            input = input.label 
        else 
            input = "" 
        end
    end
    
    local raw = trim(input)
    if raw == "" then return nil end
    
    local k = NormalizeDeptKey(raw)
    if Config.Departments[k] then return k end
    
    -- Try to match by label
    local upper = string.upper(raw)
    for key, def in pairs(Config.Departments) do
        local lab = string.upper(trim(def.label or ""))
        if lab == upper then return key end
    end
    
    -- Legacy fallback
    if k == 'ambulance' or k == 'ems' then return 'lsms' end
    
    return nil
end

-- Check if a job is allowed to use the GPS system
function IsJobAllowed(job)
    return job and Config.AllowedJobs[job] ~= nil
end

-- Debug print wrapper
function dprint(...)
    if Config.Debug then 
        print('[daddy-gps]', ...) 
    end
end

-- ============================================================================
-- Locale System (Lua-side)
-- ============================================================================

local _localeData = nil

function LoadLocaleData()
    if _localeData then return _localeData end
    local locale = Config.Locale or 'en'
    local jsonFile = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. locale .. '.json')
    if jsonFile then
        _localeData = json.decode(jsonFile)
    else
        local fallback = LoadResourceFile(GetCurrentResourceName(), 'locales/en.json')
        if fallback then
            _localeData = json.decode(fallback)
        else
            _localeData = {}
        end
    end
    return _localeData
end

-- Reset locale cache (used when language changes at runtime)
function ResetLocaleCache()
    _localeData = nil
end

--- Resolve a dot-path key from the locale data
--- @param key string Dot-separated path (e.g. 'notify.no_permission')
--- @param fallback string Fallback if key not found
--- @return string
function L(key, fallback, ...)
    local data = LoadLocaleData()
    local parts = {}
    for p in key:gmatch('[^%.]+') do
        parts[#parts+1] = p
    end
    local obj = data
    for _, p in ipairs(parts) do
        if type(obj) ~= 'table' then return fallback or key end
        obj = obj[p]
    end
    local result = type(obj) == 'string' and obj or (fallback or key)
    -- Simple %s replacement for dynamic values
    local args = {...}
    if #args > 0 then
        local idx = 0
        result = result:gsub('%%s', function()
            idx = idx + 1
            return tostring(args[idx] or '')
        end)
    end
    return result
end
