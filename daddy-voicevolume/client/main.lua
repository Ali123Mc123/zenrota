-- UI ve yakındaki oyuncu taraması. Ses override mantığı client/voice.lua'da.

local uiOpen = false
local nameCache = {} -- [serverId] = { name = string|nil, gender = 0|1 }

local function isWearingMask(ped)
    return GetPedDrawableVariation(ped, 1) > 0
end

local function cacheKey(serverId)
    return tonumber(serverId)
end

local function rememberProfiles(profiles)
    if type(profiles) ~= 'table' then
        return
    end

    for rawId, profile in pairs(profiles) do
        local serverId = cacheKey(rawId)

        if serverId and type(profile) == 'table' then
            local gender = tonumber(profile.gender) or 0

            if gender ~= 1 then
                gender = 0
            end

            nameCache[serverId] = {
                name = profile.name,
                gender = gender,
            }
        end
    end
end

local function fetchMissingProfiles(serverIds)
    local missing = {}

    for i = 1, #serverIds do
        local serverId = serverIds[i]

        if nameCache[serverId] == nil then
            missing[#missing + 1] = serverId
        end
    end

    if #missing == 0 then
        return
    end

    local ok, profiles = pcall(function()
        return lib.callback.await('daddy-voicevolume:getPlayerProfiles', false, missing)
    end)

    if ok then
        rememberProfiles(profiles)
    end
end

local function resolveDisplayName(serverId, ped, masked)
    if masked then
        local gender = nameCache[serverId] and nameCache[serverId].gender

        if gender == nil then
            gender = IsPedMale(ped) and 0 or 1
        end

        if gender == 1 then
            return Config.MaskedFemaleLabel
        end

        return Config.MaskedMaleLabel
    end

    local profile = nameCache[serverId]
    local name = profile and profile.name

    if type(name) == 'string' and name ~= '' then
        return name
    end

    return ('Oyuncu %s'):format(serverId)
end

local function buildNearbyList()
    local nearby = {}
    local ids = {}
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local myServerId = GetPlayerServerId(PlayerId())

    for _, playerId in ipairs(GetActivePlayers()) do
        local serverId = GetPlayerServerId(playerId)

        if serverId ~= myServerId then
            local targetPed = GetPlayerPed(playerId)

            if targetPed ~= 0 and DoesEntityExist(targetPed) and IsEntityVisible(targetPed) and GetEntityAlpha(targetPed) > 50 then
                local distance = #(myCoords - GetEntityCoords(targetPed))

                if distance <= Config.ListRange then
                    nearby[#nearby + 1] = {
                        serverId = serverId,
                        ped = targetPed,
                        distance = math.floor(distance * 10 + 0.5) / 10,
                        volume = math.floor(GetCustomVolume(serverId) * 100 + 0.5),
                    }
                    ids[#ids + 1] = serverId
                end
            end
        end
    end

    fetchMissingProfiles(ids)

    local players = {}

    for i = 1, #nearby do
        local row = nearby[i]
        local masked = isWearingMask(row.ped)

        players[i] = {
            serverId = row.serverId,
            name = resolveDisplayName(row.serverId, row.ped, masked),
            masked = masked,
            distance = row.distance,
            volume = row.volume,
        }
    end

    table.sort(players, function(a, b)
        return a.distance < b.distance
    end)

    return players
end

local function openUi()
    if uiOpen then
        return
    end

    uiOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        minVolume = math.floor(Config.MinVolume * 100),
        defaultVolume = math.floor(Config.DefaultVolume * 100),
        maxVolume = math.floor(Config.MaxVolume * 100),
        listRange = Config.ListRange,
        openKey = Config.OpenKey,
    })

    -- Panel açıkken liste canlı kalmalı: oyuncular hareket ediyor, yaklaşan/uzaklaşan
    -- kişiler listeye girip çıkıyor. Tek seferlik snapshot donuk mesafeler gösterirdi.
    CreateThread(function()
        while uiOpen do
            local players = buildNearbyList()

            if uiOpen then
                SendNUIMessage({ action = 'updatePlayers', players = players })
            end

            Wait(Config.RefreshInterval)
        end
    end)
end

local hoveredServerId = nil
local markerThreadActive = false

local function startMarkerThread()
    if markerThreadActive then return end
    markerThreadActive = true

    CreateThread(function()
        while uiOpen and hoveredServerId ~= nil do
            local targetPlayer = GetPlayerFromServerId(hoveredServerId)

            if targetPlayer ~= -1 then
                local targetPed = GetPlayerPed(targetPlayer)

                if targetPed ~= 0 and DoesEntityExist(targetPed) and IsEntityVisible(targetPed) and GetEntityAlpha(targetPed) > 50 then
                    local targetCoords = GetEntityCoords(targetPed)

                    -- Oyuncunun başının üstünde ters çevrilmiş Chevron oku (MarkerTypeChevronUpx1 - Type 2)
                    DrawMarker(
                        2, -- MarkerTypeChevronUpx1 (Single Chevron)
                        targetCoords.x, targetCoords.y, targetCoords.z + 1.15,
                        0.0, 0.0, 0.0,
                        180.0, 0.0, 0.0, -- Inverted pointing down
                        0.32, 0.32, 0.32,
                        244, 63, 94, 230, -- Soft Red Theme (#f43f5e)
                        true, -- Bob
                        true, -- Face Camera
                        2,
                        false,
                        nil, nil, false
                    )
                end
            end
            Wait(0)

        end
        markerThreadActive = false
    end)
end

local function closeUi()
    if not uiOpen then
        return
    end

    uiOpen = false
    hoveredServerId = nil

    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function toggleUi()
    if uiOpen then
        closeUi()
    else
        openUi()
    end
end

RegisterCommand(Config.OpenCommand, toggleUi, false)
RegisterKeyMapping(Config.OpenCommand, 'Ses Seviyesi Panelini Aç/Kapat', 'keyboard', Config.OpenKey)

RegisterNUICallback('close', function(_, cb)
    closeUi()
    cb('ok')
end)

RegisterNUICallback('hoverPlayer', function(data, cb)
    local serverId = tonumber(data and data.serverId)
    if serverId and serverId > 0 then
        hoveredServerId = serverId
        startMarkerThread()
    else
        hoveredServerId = nil
    end
    cb('ok')
end)

local lastVoiceRestart = 0
local VOICE_RESTART_COOLDOWN = 10000 -- 10 saniye cooldown

local function handleVoiceRestart()
    local now = GetGameTimer()
    local elapsed = now - lastVoiceRestart

    if elapsed < VOICE_RESTART_COOLDOWN then
        local remainingSec = math.ceil((VOICE_RESTART_COOLDOWN - elapsed) / 1000)
        lib.notify({
            title = 'Ses Sistemi',
            description = ('Ses sistemi yeni sıfırlandı. Lütfen %d saniye bekleyin.'):format(remainingSec),
            type = 'inform',
            duration = 3000,
        })
        return
    end

    lastVoiceRestart = now
    RestartVoiceEngine()

    lib.notify({
        title = 'Ses Sistemi',
        description = 'Ses bağlantısı ve Mumble kanalları başarıyla sıfırlandı.',
        type = 'success',
        duration = 4000,
    })
end

RegisterNUICallback('restartVoice', function(_, cb)
    handleVoiceRestart()
    cb('ok')
end)

RegisterCommand('fixvoice', function()
    handleVoiceRestart()
end, false)

RegisterNUICallback('setVolume', function(data, cb)
    local serverId = tonumber(data and data.serverId)
    local percent = tonumber(data and data.volume)

    if serverId and percent and GetPlayerFromServerId(serverId) ~= -1 then
        percent = math.max(0, math.min(100, percent))
        SetCustomVolume(serverId, percent / 100)
    end

    cb('ok')
end)

RegisterNetEvent('onPlayerDropped', function(serverId)
    serverId = tonumber(serverId)

    if serverId then
        nameCache[serverId] = nil
    end
end)

-- UI açık kalmışken kaynak restart edilirse imleç/focus takılı kalmasın.
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    nameCache = {}

    if uiOpen then
        uiOpen = false
        hoveredServerId = nil
        SetNuiFocus(false, false)
    end
end)
