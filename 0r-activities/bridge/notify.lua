NotificationBridge = {}

local automaticOrder = { 'ox', 'qb', 'esx' }
local resourceNames = { qb = 'qb-core', esx = 'es_extended', ox = 'ox_lib' }
local aliases = { ['qb-core'] = 'qb', ['es_extended'] = 'esx', ['ox_lib'] = 'ox' }
local notificationTypes = {
    info = 'info', inform = 'info', primary = 'info',
    success = 'success', error = 'error', warning = 'warning'
}
local cores, warnings = {}, {}

local function warnOnce(key, message)
    if warnings[key] then return end
    warnings[key] = true
    print(('[0r-activities] Notify: %s'):format(message))
end

local function boundedText(value, maximumBytes)
    if #value <= maximumBytes then return value end
    local limit = maximumBytes
    while limit > 0 do
        local nextByte = value:byte(limit + 1)
        if not nextByte or nextByte < 128 or nextByte > 191 then break end
        limit = limit - 1
    end
    return value:sub(1, limit)
end

local function validDuration(value)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge or value == -math.huge then return nil end
    return math.floor(math.max(1, math.min(60000, value)))
end

local providers = {
    qb = function(data)
        local core = cores.qb or exports['qb-core']:GetCoreObject()
        if not core or not core.Functions or type(core.Functions.Notify) ~= 'function' then return false end
        cores.qb = core
        local kind = (data.type == 'info' or data.type == 'warning') and 'primary' or data.type
        return core.Functions.Notify({ text = data.message, caption = data.title }, kind, data.duration)
    end,
    esx = function(data)
        local core = cores.esx or exports.es_extended:getSharedObject()
        if not core or type(core.ShowNotification) ~= 'function' then return false end
        cores.esx = core
        local kind = data.type == 'warning' and 'info' or data.type
        return core.ShowNotification(data.message, kind, data.duration, data.title, data.position)
    end,
    ox = function(data)
        if not lib or type(lib.notify) ~= 'function' then return false end
        return lib.notify({
            title = data.title,
            description = data.message,
            type = data.type == 'info' and 'inform' or data.type,
            duration = data.duration,
            position = data.position
        })
    end
}

local function tryProvider(system, data)
    if GetResourceState(resourceNames[system]) ~= 'started' then return false end
    local ok, result = pcall(providers[system], data)
    if ok and result ~= false then return true end
    cores[system] = nil
    warnOnce(system, ('%s could not show the notification; using another available system.'):format(system))
    return false
end

function NotificationBridge.Show(message, notificationType, durationMilliseconds)
    if type(message) ~= 'string' or not message:find('%S') then return false end
    local settings = ActivitiesConfig.notification or {}
    local title = type(settings.title) == 'string' and settings.title or ActivityLocale.activity()
    local data = {
        message = boundedText(message, 512),
        title = boundedText(title, 128),
        type = notificationTypes[notificationType] or notificationTypes[settings.defaultType] or 'info',
        duration = validDuration(durationMilliseconds) or validDuration(settings.durationMilliseconds) or 4500,
        position = type(settings.position) == 'string' and settings.position or nil
    }
    local wanted = settings.system or 'auto'
    wanted = aliases[wanted] or wanted
    if wanted ~= 'auto' then
        if providers[wanted] then
            if tryProvider(wanted, data) then return true, wanted end
            warnOnce('unavailable:' .. wanted, ('%s is unavailable; automatic fallback is active.'):format(wanted))
        else
            warnOnce('configuration', 'Unknown notification system; using auto.')
        end
    end
    for _, system in ipairs(automaticOrder) do
        if system ~= wanted and tryProvider(system, data) then return true, system end
    end

    warnOnce('native', 'No notification integration is available; using the GTA notification feed.')
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(data.message)
    EndTextCommandThefeedPostTicker(false, false)
    return true, 'native'
end

local function invalidate(resource)
    for system, name in pairs(resourceNames) do
        if resource == name then
            cores[system] = nil
            warnings[system], warnings['unavailable:' .. system], warnings.native = nil, nil, nil
        end
    end
    if resource == 'esx_notify' then cores.esx, warnings.esx = nil, nil end
end

AddEventHandler('onClientResourceStart', invalidate)
AddEventHandler('onClientResourceStop', invalidate)
