------------------------------------------------------------------------
-- Nametags Module - Client
-- Admin-only player nametags using native GamerTag API.
--
-- Keybind toggle (default PageUp) -> permission check -> polling thread.
-- Display config stored in FiveM KVP (persists across restarts).
-- Character/job data fetched from server and cached.
-- Health/armor displayed via native GamerTag component 2.
------------------------------------------------------------------------

local RESOURCE_NAME <const> = GetCurrentResourceName()
local EVENT_PREFIX <const> = RESOURCE_NAME .. ':'

-- ── KVP persistence ─────────────────────────────────────────

local KVP_KEY <const> = 'eadmin:nametag_config'

local FIELD_KEYS <const> = {
    'showId', 'showName', 'showCharName', 'showJob', 'showJobGrade',
    'showHealth', 'showSelf',
}

local DEFAULT_CONFIG <const> = {
    showId       = true,
    showName     = true,
    showCharName = false,
    showJob      = false,
    showJobGrade = false,
    showHealth   = false,
    showSelf     = false,
}

local function loadConfig()
    local raw = GetResourceKvpString(KVP_KEY)
    if raw and raw ~= '' then
        local ok, parsed = pcall(json.decode, raw)
        if ok and type(parsed) == 'table' then
            local cfg = {}
            for _, k in ipairs(FIELD_KEYS) do
                if type(parsed[k]) == 'boolean' then
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

local nametagAllowed = false
local permExpiry = 0
local PERM_TTL <const> = 5 * 60 * 1000 -- 5 minutes

local function checkPermission()
    local now = GetGameTimer()
    if nametagAllowed and now < permExpiry then
        return true
    end
    local allowed = lib.callback.await(EVENT_PREFIX .. 'canUseNametags', false)
    nametagAllowed = allowed or false
    permExpiry = allowed and (now + PERM_TTL) or 0
    return nametagAllowed
end

local function clearPermission()
    nametagAllowed = false
    permExpiry = 0
end

-- ── State ───────────────────────────────────────────────────

local nametagsEnabled = false
local activeTags = {}    -- serverId -> { handle: number, text: string, health: boolean }
local nametagData = {}   -- serverId -> { charName: string, job: string }
local lastDataFetch = 0
local DATA_REFRESH_INTERVAL <const> = 30000 -- 30s

local NAME_COLOUR <const> = 0     -- HUD_COLOUR_PURE_WHITE
local HEALTH_COLOUR <const> = 129 -- Green health bar

-- ── Helpers ─────────────────────────────────────────────────

local function needsServerData()
    return config.showCharName or config.showJob or config.showJobGrade
end

local function hasAnyField()
    for _, k in ipairs(FIELD_KEYS) do
        if k ~= 'showSelf' and config[k] then return true end
    end
    return false
end

-- ── Server data fetch ───────────────────────────────────────

local function fetchNametagData()
    local now = GetGameTimer()
    if now - lastDataFetch < DATA_REFRESH_INTERVAL then return end
    lastDataFetch = now

    local data = lib.callback.await(EVENT_PREFIX .. 'getNametagData', false)
    if type(data) == 'table' then
        nametagData = data
    end
end

-- ── Label text builder ──────────────────────────────────────

local function buildTagText(serverId, playerId)
    local parts = {}

    if config.showCharName then
        local d = nametagData[serverId]
        local charName = d and d.charName
        if charName and charName ~= '' then
            parts[#parts + 1] = charName
        end
    end

    if config.showName then
        parts[#parts + 1] = GetPlayerName(playerId)
    end

    local meta = {}

    if config.showId then
        meta[#meta + 1] = tostring(serverId)
    end

    if config.showJob then
        local d = nametagData[serverId]
        local job = d and d.job
        if job and job ~= '' then
            if config.showJobGrade then
                local grade = d.jobGrade
                if grade and grade ~= '' then
                    meta[#meta + 1] = job .. ' (' .. grade .. ')'
                else
                    meta[#meta + 1] = job
                end
            else
                meta[#meta + 1] = job
            end
        end
    end

    if #parts > 0 then
        local text = table.concat(parts, ' - ')
        if #meta > 0 then
            text = text .. ' [' .. table.concat(meta, ' | ') .. ']'
        end
        return text
    elseif #meta > 0 then
        return table.concat(meta, ' | ')
    end

    return 'ID: ' .. serverId
end

-- ── GamerTag lifecycle ──────────────────────────────────────

local function createTag(serverId, ped, text)
    local tag = CreateFakeMpGamerTag(ped, text, false, false, '', 0)
    SetMpGamerTagVisibility(tag, 0, true)
    SetMpGamerTagColour(tag, 0, NAME_COLOUR)
    SetMpGamerTagAlpha(tag, 0, 255)

    if config.showHealth then
        SetMpGamerTagVisibility(tag, 2, true)
        SetMpGamerTagHealthBarColour(tag, HEALTH_COLOUR)
        SetMpGamerTagAlpha(tag, 2, 255)
    end

    activeTags[serverId] = { handle = tag, text = text, health = config.showHealth }
end

local function removeTag(serverId)
    local entry = activeTags[serverId]
    if entry then
        RemoveMpGamerTag(entry.handle)
        activeTags[serverId] = nil
    end
end

-- ── Refresh / clear ─────────────────────────────────────────

local function refreshNametags()
    local myId = PlayerId()
    local seen = {}

    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= myId or config.showSelf then
            local serverId = GetPlayerServerId(playerId)
            local ped = GetPlayerPed(playerId)
            seen[serverId] = true

            if DoesEntityExist(ped) then
                local text = buildTagText(serverId, playerId)
                local entry = activeTags[serverId]

                if entry then
                    local tagActive = IsMpGamerTagActive(entry.handle)
                    if not tagActive or entry.text ~= text or entry.health ~= config.showHealth then
                        if tagActive then
                            RemoveMpGamerTag(entry.handle)
                        end
                        createTag(serverId, ped, text)
                    end
                else
                    createTag(serverId, ped, text)
                end
            end
        end
    end

    for serverId in pairs(activeTags) do
        if not seen[serverId] then
            removeTag(serverId)
        end
    end
end

local function clearNametags()
    for serverId in pairs(activeTags) do
        RemoveMpGamerTag(activeTags[serverId].handle)
    end
    activeTags = {}
    nametagData = {}
    lastDataFetch = 0
end

-- ── Toggle ──────────────────────────────────────────────────

local function enableNametags()
    nametagsEnabled = true
    lastDataFetch = 0

    CreateThread(function()
        if needsServerData() then
            fetchNametagData()
        end
        if hasAnyField() then
            refreshNametags()
        end
    end)
end

local function disableNametags()
    nametagsEnabled = false
    clearNametags()
end

-- ── Polling thread ──────────────────────────────────────────

CreateThread(function()
    while true do
        if nametagsEnabled then
            if needsServerData() then
                fetchNametagData()
            end

            if hasAnyField() then
                refreshNametags()
            end

            Wait(3500)
        else
            Wait(5000)
        end
    end
end)

-- ── NUI callbacks (settings UI read/write) ──────────────────

RegisterNuiCallback('getNametagConfig', function(_, cb)
    cb(config)
end)

RegisterNuiCallback('updateNametagConfig', function(data, cb)
    if type(data) ~= 'table' then cb({}) return end

    for _, k in ipairs(FIELD_KEYS) do
        if type(data[k]) == 'boolean' then
            config[k] = data[k]
        end
    end

    saveConfig(config)
    lastDataFetch = 0

    -- Force immediate rebuild if nametags are active
    if nametagsEnabled then
        for serverId in pairs(activeTags) do
            RemoveMpGamerTag(activeTags[serverId].handle)
        end
        activeTags = {}

        CreateThread(function()
            if needsServerData() then
                fetchNametagData()
            end
            if hasAnyField() then
                refreshNametags()
            end
        end)
    end

    cb(config)
end)

-- ── Server-push revocation ──────────────────────────────────

RegisterNetEvent(EVENT_PREFIX .. 'nametagsRevoked', function()
    clearPermission()
    if nametagsEnabled then
        disableNametags()
    end
end)

-- ── Keybind command ─────────────────────────────────────────

local toggleInProgress = false

lib.addKeybind({
    name = Config.nametagCommand,
    description = Config.nametagKeyLabel,
    defaultKey = Config.nametagKeybind and Config.nametagKey or nil,
    defaultMapper = 'keyboard',
    onPressed = function(self)
        if toggleInProgress then return end
        toggleInProgress = true

        if nametagsEnabled then
            disableNametags()
            toggleInProgress = false
            return
        end

        local allowed = checkPermission()
        toggleInProgress = false
        if not allowed then return end

        enableNametags()
    end
})

-- ── Cleanup on resource stop ────────────────────────────────

AddEventHandler('onClientResourceStop', function(resName)
    if resName ~= RESOURCE_NAME then return end
    if nametagsEnabled then
        clearNametags()
    end
end)
