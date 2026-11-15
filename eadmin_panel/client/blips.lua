------------------------------------------------------------------------
-- Blips Module - Client
-- Admin-only player blips on the game map (minimap + pause map).
--
-- Two modes:
--   'nearby' - Entity-attached blips for streamed-in players (real-time)
--   'global' - Coord-based blips for all server players (~2s position delay)
--
-- Blip style changes dynamically based on player state:
--   default (walking), vehicle, dead, jail (global only).
--
-- Keybind toggle (configurable) -> permission check -> polling thread.
-- Display config stored in FiveM KVP (persists across restarts).
-- Position data (global mode) fetched from LivePlayers server cache.
------------------------------------------------------------------------

local RESOURCE_NAME <const> = GetCurrentResourceName()
local EVENT_PREFIX <const> = RESOURCE_NAME .. ':'

-- ── KVP persistence ─────────────────────────────────────────

local KVP_KEY <const> = 'eadmin:blip_config'

local BOOLEAN_FIELDS <const> = {
    'showId', 'showName', 'showSelf',
    'shortRange', 'showHeading', 'mainMap',
}
local COLOUR_FIELDS <const> = { 'colourDefault', 'colourVehicle', 'colourDead', 'colourJail' }

local DEFAULT_CONFIG <const> = {
    mode           = 'nearby', -- 'nearby' | 'global'
    showId         = true,
    showName       = true,
    showSelf       = false,
    shortRange     = false,  -- only visible on minimap when nearby
    showHeading    = false,  -- directional heading indicator on blip
    mainMap        = true,   -- show on pause menu main map
    colourDefault  = 0,   -- white
    colourVehicle  = 0,   -- white
    colourDead     = 1,   -- red
    colourJail     = 17,  -- orange
}

local function loadConfig()
    local raw = GetResourceKvpString(KVP_KEY)
    if raw and raw ~= '' then
        local ok, parsed = pcall(json.decode, raw)
        if ok and type(parsed) == 'table' then
            local cfg = {}
            cfg.mode = (parsed.mode == 'nearby' or parsed.mode == 'global')
                and parsed.mode or DEFAULT_CONFIG.mode
            for _, k in ipairs(BOOLEAN_FIELDS) do
                if type(parsed[k]) == 'boolean' then
                    cfg[k] = parsed[k]
                else
                    cfg[k] = DEFAULT_CONFIG[k]
                end
            end
            for _, k in ipairs(COLOUR_FIELDS) do
                if type(parsed[k]) == 'number' then
                    cfg[k] = parsed[k]
                else
                    cfg[k] = DEFAULT_CONFIG[k]
                end
            end
            return cfg
        end
    end
    local cfg = {}
    for k, v in pairs(DEFAULT_CONFIG) do cfg[k] = v end
    return cfg
end

local function saveConfig(cfg)
    SetResourceKvp(KVP_KEY, json.encode(cfg))
end

local config = loadConfig()

-- ── Permission cache ────────────────────────────────────────

local blipAllowed = false
local permExpiry = 0
local PERM_TTL <const> = 5 * 60 * 1000 -- 5 minutes

local function checkPermission()
    local now = GetGameTimer()
    if blipAllowed and now < permExpiry then
        return true
    end
    local allowed = lib.callback.await(EVENT_PREFIX .. 'canUseBlips', false)
    blipAllowed = allowed or false
    permExpiry = allowed and (now + PERM_TTL) or 0
    return blipAllowed
end

local function clearPermission()
    blipAllowed = false
    permExpiry = 0
end

-- ── State ───────────────────────────────────────────────────

local blipsEnabled = false
local activeBlips = {}   -- serverId -> { handle, text, state }
local blipData = {}      -- serverId -> { x, y, z, name, state } (global mode)
local lastDataFetch = 0
local DATA_REFRESH_INTERVAL <const> = 2000 -- 2s

-- ── Blip appearance ─────────────────────────────────────────

local BLIP_SCALE    <const> = 0.85
local BLIP_CATEGORY <const> = 7    -- "Other Players" on pause map legend

-- Sprite per state (fixed). Sprite 1 = standard circle, 225 = car icon.
local BLIP_SPRITES <const> = {
    default = 1,
    vehicle = 225,
    dead    = 1,
    jail    = 1,
}

-- State -> config colour key (colours are admin-configurable via KVP).
local COLOUR_KEYS <const> = {
    default = 'colourDefault',
    vehicle = 'colourVehicle',
    dead    = 'colourDead',
    jail    = 'colourJail',
}

-- ── Helpers ─────────────────────────────────────────────────

local function buildBlipName(serverId, playerName)
    local parts = {}
    if config.showName and playerName and playerName ~= '' then
        parts[#parts + 1] = playerName
    end
    if config.showId then
        if #parts > 0 then
            parts[#parts + 1] = '[' .. serverId .. ']'
        else
            parts[#parts + 1] = 'ID: ' .. serverId
        end
    end
    if #parts == 0 then
        return 'ID: ' .. serverId
    end
    return table.concat(parts, ' ')
end

local function setBlipDisplayName(blip, name)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(name)
    EndTextCommandSetBlipName(blip)
end

--- Resolve player state from client-side natives (nearby mode).
--- Jail state is unavailable client-side; jailed players are typically
--- in a separate routing bucket and won't be streamed anyway.
---@param ped number
---@return string
local function resolveNearbyState(ped)
    if IsEntityDead(ped) then return 'dead' end
    if GetVehiclePedIsIn(ped, false) ~= 0 then return 'vehicle' end
    return 'default'
end

-- ── Blip lifecycle ──────────────────────────────────────────

local function applyStyle(blip, state)
    SetBlipSprite(blip, BLIP_SPRITES[state] or 1)
    SetBlipColour(blip, config[COLOUR_KEYS[state]] or 0)
    SetBlipScale(blip, BLIP_SCALE)
    SetBlipCategory(blip, BLIP_CATEGORY)
    SetBlipAsShortRange(blip, config.shortRange)
    SetBlipDisplay(blip, config.mainMap and 2 or 5)
    ShowHeadingIndicatorOnBlip(blip, config.showHeading)
end

--- Update an existing blip entry in-place. Only calls natives when values change.
---@param entry table  activeBlips entry { handle, text, state }
---@param name string
---@param state string
local function updateEntry(entry, name, state)
    if entry.text ~= name then
        setBlipDisplayName(entry.handle, name)
        entry.text = name
    end
    if entry.state ~= state then
        SetBlipSprite(entry.handle, BLIP_SPRITES[state] or 1)
        SetBlipColour(entry.handle, config[COLOUR_KEYS[state]] or 0)
        entry.state = state
    end
end

local function removeBlip(serverId)
    local entry = activeBlips[serverId]
    if entry then
        if DoesBlipExist(entry.handle) then
            RemoveBlip(entry.handle)
        end
        activeBlips[serverId] = nil
    end
end

local function clearAllBlips()
    for _, entry in pairs(activeBlips) do
        if DoesBlipExist(entry.handle) then
            RemoveBlip(entry.handle)
        end
    end
    activeBlips = {}
    blipData = {}
    lastDataFetch = 0
end

-- ── Server data fetch (global mode) ─────────────────────────

local function fetchBlipData()
    local now = GetGameTimer()
    if now - lastDataFetch < DATA_REFRESH_INTERVAL then return end
    lastDataFetch = now

    local data = lib.callback.await(EVENT_PREFIX .. 'getBlipData', false)
    if type(data) == 'table' then
        blipData = data
    end
end

-- ── Refresh: nearby mode ────────────────────────────────────

local function refreshNearbyBlips()
    local myId = PlayerId()
    local seen = {}

    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= myId or config.showSelf then
            local serverId = GetPlayerServerId(playerId)
            local ped = GetPlayerPed(playerId)
            seen[serverId] = true

            if DoesEntityExist(ped) then
                local name = buildBlipName(serverId, GetPlayerName(playerId))
                local state = resolveNearbyState(ped)
                local entry = activeBlips[serverId]

                if entry and DoesBlipExist(entry.handle) then
                    -- In-place update: only call natives when values differ
                    updateEntry(entry, name, state)
                else
                    -- Create new (or replace invalidated handle)
                    local blip = AddBlipForEntity(ped)
                    applyStyle(blip, state)
                    setBlipDisplayName(blip, name)
                    activeBlips[serverId] = { handle = blip, text = name, state = state }
                end
            end
        end
    end

    for serverId in pairs(activeBlips) do
        if not seen[serverId] then
            removeBlip(serverId)
        end
    end
end

-- ── Refresh: global mode ────────────────────────────────────

local function refreshGlobalBlips()
    local myServerId = GetPlayerServerId(PlayerId())
    local seen = {}

    for srcKey, data in pairs(blipData) do
        local serverId = tonumber(srcKey) or srcKey
        if serverId ~= myServerId or config.showSelf then
            seen[serverId] = true
            local name = buildBlipName(serverId, data.name)
            local state = data.state or 'default'
            local entry = activeBlips[serverId]

            if entry and DoesBlipExist(entry.handle) then
                SetBlipCoords(entry.handle, data.x, data.y, data.z)
                updateEntry(entry, name, state)
            else
                local blip = AddBlipForCoord(data.x, data.y, data.z)
                applyStyle(blip, state)
                setBlipDisplayName(blip, name)
                entry = { handle = blip, text = name, state = state }
                activeBlips[serverId] = entry
            end

            -- Heading rotation for coord blips (entity blips auto-track)
            if config.showHeading and data.heading then
                SetBlipRotation(entry.handle, math.floor(data.heading))
            end
        end
    end

    for serverId in pairs(activeBlips) do
        if not seen[serverId] then
            removeBlip(serverId)
        end
    end
end

-- ── Main refresh dispatcher ─────────────────────────────────

local function refreshBlips()
    if config.mode == 'nearby' then
        refreshNearbyBlips()
    else
        refreshGlobalBlips()
    end
end

-- ── Toggle ──────────────────────────────────────────────────

local function enableBlips()
    blipsEnabled = true
    lastDataFetch = 0

    CreateThread(function()
        if config.mode == 'global' then
            fetchBlipData()
        end
        refreshBlips()
    end)
end

local function disableBlips()
    blipsEnabled = false
    clearAllBlips()
end

-- ── Polling thread ──────────────────────────────────────────

CreateThread(function()
    while true do
        if blipsEnabled then
            if config.mode == 'global' then
                fetchBlipData()
            end
            refreshBlips()
            Wait(3500)
        else
            Wait(5000)
        end
    end
end)

-- ── NUI callbacks (settings UI read/write) ──────────────────

RegisterNuiCallback('getBlipConfig', function(_, cb)
    cb(config)
end)

RegisterNuiCallback('updateBlipConfig', function(data, cb)
    if type(data) ~= 'table' then cb({}) return end

    if data.mode == 'nearby' or data.mode == 'global' then
        config.mode = data.mode
    end

    for _, k in ipairs(BOOLEAN_FIELDS) do
        if type(data[k]) == 'boolean' then
            config[k] = data[k]
        end
    end

    for _, k in ipairs(COLOUR_FIELDS) do
        if type(data[k]) == 'number' then
            config[k] = data[k]
        end
    end

    saveConfig(config)

    -- Force immediate rebuild if blips are active
    if blipsEnabled then
        clearAllBlips()

        CreateThread(function()
            if config.mode == 'global' then
                fetchBlipData()
            end
            refreshBlips()
        end)
    end

    cb(config)
end)

-- ── Server-push revocation ──────────────────────────────────

RegisterNetEvent(EVENT_PREFIX .. 'blipsRevoked', function()
    clearPermission()
    if blipsEnabled then
        disableBlips()
    end
end)

-- ── Keybind command ─────────────────────────────────────────

local toggleInProgress = false

lib.addKeybind({
    name = Config.blipCommand,
    description = Config.blipKeyLabel,
    defaultKey = Config.blipKeybind and Config.blipKey or nil,
    defaultMapper = 'keyboard',
    onPressed = function(self)
        if toggleInProgress then return end
        toggleInProgress = true

        if blipsEnabled then
            disableBlips()
            toggleInProgress = false
            return
        end

        local allowed = checkPermission()
        toggleInProgress = false
        if not allowed then return end

        enableBlips()
    end
})

-- ── Cleanup on resource stop ────────────────────────────────

AddEventHandler('onClientResourceStop', function(resName)
    if resName ~= RESOURCE_NAME then return end
    if blipsEnabled then
        clearAllBlips()
    end
end)
