-- Client main: dual display mode, damage tracking, NUI, ped clone, marker render

lib.locale()

-- Load config-based locale and override locale() function
local localeStrings = {}
local originalLocale = locale

local function loadLocaleFile()
    local cfgLocale = Config.Locale or 'en'
    local filePath = ('locales/%s.json'):format(cfgLocale)
    local fileContent = LoadResourceFile(GetCurrentResourceName(), filePath)
    if fileContent then
        localeStrings = json.decode(fileContent) or {}
    end
end

-- Override global locale function
function locale(key)
    if localeStrings[key] then
        return localeStrings[key]
    end
    return originalLocale(key)
end

loadLocaleFile()

local activeLogs = {}     -- Active combat log entries (keyed by log ID)
local spawnedPeds = {}    -- Spawned ped entities for ped mode (keyed by log ID)
local spawnedTargets = {} -- Target option names (ox_target) keyed by log ID
local isNuiReady = false
local oxtarget = GetResourceState('ox_target') == 'started'
local qbtarget = GetResourceState('qb-target') == 'started'

local function debugPrint(msg)
    if Config.Debug then
        print(('[krypton-combatlog] [DEBUG] %s'):format(msg))
    end
end

-- ┌─────────────────────────────────────┐
-- │          NUI COMMUNICATION          │
-- └─────────────────────────────────────┘

local function sendNUI(action, data)
    SendNUIMessage({
        action = action,
        data = data,
    })
end

RegisterNUICallback('nuiReady', function(_, cb)
    isNuiReady = true
    debugPrint('NUI is ready')
    cb('ok')
end)

RegisterNUICallback('copyToClipboard', function(_, cb)
    lib.notify({
        title = 'Combat Log',
        description = locale('info_copied'),
        type = 'success',
        duration = 3000,
    })
    cb('ok')
end)

-- ┌─────────────────────────────────────┐
-- │     PLAYER LOADED → SERVER SYNC     │
-- └─────────────────────────────────────┘

-- Coords/heading are read with server-side natives at disconnect time.
-- Only the ped model needs to be sent from the client, and only once on load.
local function sendAppearance()
    local ped = PlayerPedId()
    if DoesEntityExist(ped) then
        TriggerServerEvent('krypton-combatlog:server:updateAppearance', GetEntityModel(ped))
    end
end

Framework.OnPlayerLoaded(function()
    sendAppearance()
    TriggerServerEvent('krypton-combatlog:server:playerLoaded')
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(2000)
    sendAppearance()
    TriggerServerEvent('krypton-combatlog:server:playerLoaded')
end)

-- ┌─────────────────────────────────────┐
-- │     COMBAT LOG EVENT HANDLERS       │
-- └─────────────────────────────────────┘

RegisterNetEvent('krypton-combatlog:client:addLog', function(logData)
    activeLogs[logData.id] = logData
    debugPrint(('Added combat log #%s for %s (mode: %s)'):format(logData.id, logData.name, Config.DisplayMode))

    if Config.DisplayMode == 'ped' then
        spawnGhostPed(logData)
    end

    -- Client-side fallback cleanup timer
    local now = GetCloudTimeAsInt()
    local maxDuration = Config.DisplayDuration or 180
    local remaining = logData.expireAt and (logData.expireAt - now) or maxDuration
    if remaining > maxDuration then remaining = maxDuration end

    if remaining > 0 then
        SetTimeout(remaining * 1000, function()
            if activeLogs[logData.id] then
                TriggerEvent('krypton-combatlog:client:removeLog', logData.id)
            end
        end)
    else
        TriggerEvent('krypton-combatlog:client:removeLog', logData.id)
    end
end)


RegisterNetEvent('krypton-combatlog:client:removeLog', function(logId)
    if activeLogs[logId] then
        debugPrint(('Removed combat log #%s'):format(logId))
        activeLogs[logId] = nil
    end

    if spawnedPeds[logId] then
        cleanupPed(logId)
    end

    if Config.DisplayMode == 'marker' then
        sendNUI('removeLog', { id = logId })
    end
end)

-- ┌─────────────────────────────────────┐
-- │     PED MODE: GHOST PED SPAWN       │
-- └─────────────────────────────────────┘

function spawnGhostPed(logData)
    CreateThread(function()
        local pedModel = logData.pedModel
        if not pedModel then
            pedModel = `mp_m_freemode_01`
        end

        if not lib.requestModel(pedModel, 5000) then
            debugPrint(('Failed to request ped model %s'):format(pedModel))
            return
        end

        local coords = type(logData.coords) == 'vector3' and logData.coords
            or vector3(logData.coords.x, logData.coords.y, logData.coords.z)
        local heading = logData.heading or 0.0

        -- Try to snap spawn z to ground so the lying animation looks correct.
        local spawnZ = coords.z
        local ok, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 1.0, false)
        if ok and groundZ then
            spawnZ = groundZ
        end

        pcall(function() exports['FeloxAC']:CreatePed(pedModel) end) --[[FeloxAC:auto]]
        local ped = CreatePed(0, pedModel, coords.x, coords.y, spawnZ, heading, false, false)

        if not DoesEntityExist(ped) then
            debugPrint(('Failed to create ghost ped for log #%s'):format(logData.id))
            SetModelAsNoLongerNeeded(pedModel)
            return
        end

        SetEntityAsMissionEntity(ped, true, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedFleeAttributes(ped, 0, 0)
        SetEntityInvincible(ped, true)
        SetEntityCanBeDamaged(ped, false)
        SetPedCanRagdoll(ped, false)

        -- Ensure a clean baseline so component variations apply correctly
        SetPedDefaultComponentVariation(ped)

        if Config.PedNoCollision then
            SetEntityNoCollisionEntity(ped, PlayerPedId(), false)
            SetEntityNoCollisionEntity(PlayerPedId(), ped, false)
        end

        SetEntityAlpha(ped, Config.PedAlpha, false)
        SetModelAsNoLongerNeeded(pedModel)

        -- Set default appearance
        SetPedDefaultComponentVariation(ped)

        -- Lying / dead pose animation
        local anim = Config.PedAnim or { dict = 'dead', name = 'dead_a', flag = 2 }
        if anim and anim.dict and anim.name then
            lib.requestAnimDict(anim.dict)
            TaskPlayAnim(ped, anim.dict, anim.name, 8.0, 0.0, -1, anim.flag or 2, 0.0, false, false, false)
            RemoveAnimDict(anim.dict)
        end

        FreezeEntityPosition(ped, true)

        spawnedPeds[logData.id] = ped

        setupPedInteraction(logData, ped)

        debugPrint(('Ghost ped spawned for log #%s'):format(logData.id))
    end)
end

function setupPedInteraction(logData, ped)
    if Config.UseTarget and oxtarget then
        local optionName = ('krypton_combatlog_info_%s'):format(logData.id)
        spawnedTargets[logData.id] = optionName
        exports.ox_target:addLocalEntity(ped, {
            {
                name = optionName,
                icon = 'fa-solid fa-circle-info',
                label = locale('view_info'),
                distance = Config.PedInteractDistance,
                onSelect = function()
                    showPedContextMenu(logData)
                end,
            },
        })
    elseif Config.UseTarget and qbtarget then
        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    icon = 'fa-solid fa-circle-info',
                    label = locale('view_info'),
                    action = function()
                        showPedContextMenu(logData)
                    end,
                },
            },
            distance = Config.PedInteractDistance,
        })
    end
end

function showPedContextMenu(logData)
    local options = {}

    local title = logData.name or 'Unknown'
    local desc = ''

    if Config.ShowReason then
        desc = desc .. locale('discord_reason') .. ': ' .. (logData.reasonDisplay or '?') .. '\n'
    end
    if Config.ShowIdentifier then
        desc = desc .. locale('discord_identifier') .. ': ' .. (logData.identifier or '?') .. '\n'
    end
    if Config.ShowTime and logData.timestamp then
        local t = logData.timeDisplay or logData.dateTimeDisplay or tostring(logData.timestamp)
        desc = desc .. locale('discord_time') .. ': ' .. t .. '\n'
    end

    options[#options + 1] = {
        title = title,
        description = desc,
        icon = 'circle-info',
        onSelect = function()
            local info = ('Name: %s | Reason: %s | Identifier: %s'):format(
                logData.name or '?',
                logData.reasonDisplay or '?',
                logData.identifier or '?'
            )
            lib.setClipboard(info)
            lib.notify({
                title = 'Combat Log',
                description = locale('info_copied'),
                type = 'success',
                duration = 3000,
            })
        end,
    }

    lib.registerContext({
        id = 'krypton_combatlog_' .. logData.id,
        title = locale('combat_log_detected'),
        options = options,
    })
    lib.showContext('krypton_combatlog_' .. logData.id)
end

function cleanupPed(logId)
    local ped = spawnedPeds[logId]
    if ped and DoesEntityExist(ped) then
        if Config.UseTarget and oxtarget then
            local optionName = spawnedTargets[logId]
            if optionName then
                exports.ox_target:removeLocalEntity(ped, optionName)
            end
        elseif Config.UseTarget and qbtarget then
            exports['qb-target']:RemoveTargetEntity(ped, locale('view_info'))
        end
        DeleteEntity(ped)
    end
    spawnedPeds[logId] = nil
    spawnedTargets[logId] = nil
end

-- ┌─────────────────────────────────────┐
-- │    REASON-BASED MARKER COLOR        │
-- └─────────────────────────────────────┘

local function getMarkerColorForReason(reasonKey)
    if not Config.ReasonMarkerColors then
        return Config.MarkerColor
    end

    local colors = Config.ReasonColors or {}
    return (reasonKey and colors[reasonKey]) or colors['default'] or Config.MarkerColor
end

-- ┌─────────────────────────────────────┐
-- │        MAIN RENDER LOOP             │
-- └─────────────────────────────────────┘

local lastNuiUpdate = 0
local lastSentCount = 0

CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local playerCoords = GetEntityCoords(ped)
        local nuiLogs = {}
        local closestInteractable = nil
        local closestInteractDist = math.huge

        local now = GetCloudTimeAsInt()
        for logId, logData in pairs(activeLogs) do
            if logData.expireAt and now >= logData.expireAt then
                TriggerEvent('krypton-combatlog:client:removeLog', logId)
            else
                local logCoords = type(logData.coords) == 'vector3' and logData.coords
                    or vector3(logData.coords.x, logData.coords.y, logData.coords.z)
                local dist = #(playerCoords - logCoords)

                if Config.DisplayMode == 'marker' then
                    -- ── MARKER MODE ──
                    if dist <= Config.RenderDistance then
                        sleep = 0

                        local markerZ = logCoords.z + Config.MarkerZOffset
                        local nuiDistance = Config.NuiRenderDistance or 2.35
                        local mc = getMarkerColorForReason(logData.reasonKey)

                        -- Draw GTA native marker only if the NUI is NOT fully visible yet
                        if dist > nuiDistance then
                            DrawMarker(
                                Config.MarkerType,
                                logCoords.x, logCoords.y, markerZ,
                                0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0,
                                Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z,
                                mc.r, mc.g, mc.b, mc.a,
                                Config.MarkerBobUpAndDown,
                                Config.MarkerFaceCamera,
                                2,
                                Config.MarkerRotate,
                                nil, nil, false
                            )
                        end

                        if dist <= nuiDistance then
                            local panelAnchorZ = markerZ + (Config.NuiWorldOffset or 0.46)
                            local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(
                                logCoords.x, logCoords.y, panelAnchorZ)

                            if onScreen then
                                screenY = math.min(0.995, screenY + (Config.NuiScreenOffsetY or 0.014))
                                local opacity = 1.0

                                nuiLogs[#nuiLogs + 1] = {
                                    id = logId,
                                    screenX = screenX,
                                    screenY = screenY,
                                    distance = dist,
                                    opacity = opacity,
                                    name = logData.name,
                                    identifier = logData.identifier,
                                    reasonDisplay = logData.reasonDisplay,
                                    timeDisplay = logData.timeDisplay,
                                    dateTimeDisplay = logData.dateTimeDisplay,
                                    showName = logData.showName,
                                    showTime = logData.showTime,
                                    showReason = logData.showReason,
                                    showIdentifier = logData.showIdentifier,
                                    copyLabel = locale('copy_info'),
                                    showHint = true,
                                }

                                if dist < closestInteractDist then
                                    closestInteractDist = dist
                                    closestInteractable = logId
                                end
                            end
                        end
                    end
                elseif Config.DisplayMode == 'ped' then
                    -- ── PED MODE (fallback if no target system) ──
                    if not Config.UseTarget or (not oxtarget and not qbtarget) then
                        if dist <= Config.PedInteractDistance then
                            sleep = 0
                            if dist < closestInteractDist then
                                closestInteractDist = dist
                                closestInteractable = logId
                            end
                        end
                    end
                elseif Config.DisplayMode == 'drawtext' then
                    -- ── DRAWTEXT MODE ──
                    if dist <= Config.RenderDistance then
                        sleep = 0

                        local markerZ = logCoords.z + Config.MarkerZOffset
                        local nuiDistance = Config.NuiRenderDistance or 2.35
                        local mc = getMarkerColorForReason(logData.reasonKey)

                        if dist > nuiDistance then
                            DrawMarker(
                                Config.MarkerType,
                                logCoords.x, logCoords.y, markerZ,
                                0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0,
                                Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z,
                                mc.r, mc.g, mc.b, mc.a,
                                Config.MarkerBobUpAndDown,
                                Config.MarkerFaceCamera,
                                2,
                                Config.MarkerRotate,
                                nil, nil, false
                            )
                        else
                            local textZ = markerZ + Config.MarkerSize.z * 0.5 + 0.15
                            local parts = {}
                            if Config.ShowName then
                                parts[#parts + 1] = logData.name or 'Unknown'
                            end
                            if Config.ShowReason then
                                parts[#parts + 1] = logData.reasonDisplay or '?'
                            end
                            if Config.ShowTime and logData.timeDisplay then
                                parts[#parts + 1] = logData.timeDisplay
                            end
                            if Config.ShowIdentifier then
                                local id = logData.identifier or ''
                                if #id > 30 then id = id:sub(1, 28) .. '..' end
                                parts[#parts + 1] = id
                            end

                            local line = table.concat(parts, ' | ')
                            DrawText3D(logCoords.x, logCoords.y, textZ, line)

                            if dist < closestInteractDist then
                                closestInteractDist = dist
                                closestInteractable = logId
                            end
                        end
                    end
                end
            end
        end


        -- Send NUI updates (marker mode only)
        if Config.DisplayMode == 'marker' and isNuiReady then
            local now = GetGameTimer()
            if now - lastNuiUpdate >= 33 or #nuiLogs ~= lastSentCount then
                if #nuiLogs > 0 or lastSentCount > 0 then
                    sendNUI('updateLogs', nuiLogs)
                    lastNuiUpdate = now
                    lastSentCount = #nuiLogs
                end
            end
        end

        -- Handle [E] key interaction
        if closestInteractable then
            if Config.DisplayMode == 'marker' then
                if IsControlJustPressed(0, 38) then
                    local logData = activeLogs[closestInteractable]
                    if logData then
                        local copyText = ('Name: %s | Reason: %s | Identifier: %s | Timestamp: %s'):format(
                            logData.name,
                            logData.reasonDisplay,
                            logData.identifier,
                            logData.timeDisplay or tostring(logData.timestamp)
                        )
                        sendNUI('copyText', { text = copyText })
                    end
                end
            elseif Config.DisplayMode == 'ped' then
                DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z + 0.3, locale('copy_info'))
                if IsControlJustPressed(0, 38) then
                    local logData = activeLogs[closestInteractable]
                    if logData then
                        showPedContextMenu(logData)
                    end
                end
            elseif Config.DisplayMode == 'drawtext' then
                if IsControlJustPressed(0, 38) then
                    local logData = activeLogs[closestInteractable]
                    if logData then
                        local info = ('Name: %s | Reason: %s | Identifier: %s | Time: %s'):format(
                            logData.name or '?',
                            logData.reasonDisplay or '?',
                            logData.identifier or '?',
                            logData.timeDisplay or tostring(logData.timestamp)
                        )
                        lib.setClipboard(info)
                        lib.notify({
                            title = 'Combat Log',
                            description = locale('info_copied'),
                            type = 'success',
                            duration = 3000,
                        })
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-- ┌─────────────────────────────────────┐
-- │      HELPER: 3D TEXT DRAWING        │
-- └─────────────────────────────────────┘

function DrawText3D(x, y, z, text)
    SetTextScale(0.30, 0.30)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x, y, z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    local factor = #text / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 100)
    ClearDrawOrigin()
end

-- ┌─────────────────────────────────────┐
-- │         RESOURCE CLEANUP            │
-- └─────────────────────────────────────┘

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    for logId, _ in pairs(spawnedPeds) do
        cleanupPed(logId)
    end

    if isNuiReady then
        sendNUI('updateLogs', {})
    end
end)
