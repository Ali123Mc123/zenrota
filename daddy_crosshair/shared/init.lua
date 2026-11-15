lib.locale(Settings.Locale ~= 'auto' and Settings.Locale or nil)

local colorKey = {}
for _, key in ipairs(Settings.ColorKeys) do colorKey[key] = true end

local function Valid(key, value)
    local default = Settings.Defaults[key]
    if default == nil or type(value) ~= type(default) then return false, nil end
    if colorKey[key] and value:match('^#%x%x%x%x%x%x$') then return true, value:lower() end
    local options = Settings.Options[key]
    if options and not lib.table.contains(options, value) then return false, nil end
    return true, value
end

-- Returns only the entries of data that are known settings with an allowed value.
function Settings.Sanitize(data)
    local clean = {}
    if type(data) ~= 'table' then return clean end
    for key in pairs(Settings.Defaults) do
        local ok, value = Valid(key, data[key])
        if ok then clean[key] = value end
    end
    return clean
end

function Settings.DefaultLook()
    local look = {}
    for _, key in ipairs(Settings.LookKeys) do look[key] = Settings.Defaults[key] end
    return look
end

function Settings.SanitizeLook(data)
    local look = Settings.DefaultLook()
    if type(data) ~= 'table' then return look end
    for _, key in ipairs(Settings.LookKeys) do
        local ok, value = Valid(key, data[key])
        if ok then look[key] = value end
    end
    return look
end

-- Always returns Settings.MaxProfiles look tables; missing or broken slots fall back to defaults.
function Settings.SanitizeProfiles(list)
    local profiles = {}
    for i = 1, Settings.MaxProfiles do
        profiles[i] = Settings.SanitizeLook(type(list) == 'table' and list[i] or nil)
    end
    return profiles
end
