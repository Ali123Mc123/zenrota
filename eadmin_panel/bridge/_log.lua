--[[
    Log - Console logging utility

    Provides leveled logging with FiveM color codes.
    Loaded first in shared_scripts so every other script can use it.

    Usage:
        Log.info('Server started')
        Log.warn('Player %s has no vehicle', name)
        Log.error('Failed to load resource: %s', err)
        Log.debug('Cache hit for key %s', key)

    Configuration:
        Log.setLevel('debug')   -- show all messages
        Log.setLevel('warn')    -- show warn + error only
]]

Log = {}

local LEVELS = { debug = 1, info = 2, warn = 3, error = 4 }
local minLevel = LEVELS.info

-- Auto-configure from Config.debug (config.lua loads before _log.lua)
if type(Config) == 'table' and Config.debug == true then
    minLevel = LEVELS.debug
end

--- Change the minimum log level at runtime.
---@param level 'debug'|'info'|'warn'|'error'
function Log.setLevel(level)
    local n = LEVELS[level]
    if n then
        minLevel = n
    else
        print(('[^1LOG^7] Unknown log level: %s'):format(tostring(level)))
    end
end

local RESOURCE = GetCurrentResourceName()

local TAGS = {
    [1] = '^4[DEBUG]^7',
    [2] = '^2[INFO]^7',
    [3] = '^3[WARN]^7',
    [4] = '^1[ERROR]^7',
}

--- Core log function - not exposed directly.
---@param level number
---@param fmt string|any
local function write(level, fmt, ...)
    if level < minLevel then return end

    local msg
    if select('#', ...) > 0 then
        local ok, formatted = pcall(string.format, tostring(fmt), ...)
        msg = ok and formatted or tostring(fmt)
    else
        msg = tostring(fmt)
    end

    print(('%s [%s] %s'):format(TAGS[level], RESOURCE, msg))
end

--- Log a debug message (level 1). Typically hidden in production.
---@param fmt string  Format string (or plain message)
---@param ... any     Format arguments
function Log.debug(fmt, ...) write(1, fmt, ...) end

--- Log an informational message (level 2).
---@param fmt string
---@param ... any
function Log.info(fmt, ...) write(2, fmt, ...) end

--- Log a warning (level 3).
---@param fmt string
---@param ... any
function Log.warn(fmt, ...) write(3, fmt, ...) end

--- Log an error (level 4). Always shown unless level is raised above error.
---@param fmt string
---@param ... any
function Log.error(fmt, ...) write(4, fmt, ...) end
