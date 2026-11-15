local Config = Config
local cfg = Config.AdminPanel or {}
local cfgCreator = cfg.creator or {}

local ItemList = {}

local function BuildItemList()
    ItemList = {}
    if Config.Items then
        for key, item in pairs(Config.Items) do
            table.insert(ItemList, { name = key, label = item.label or key })
        end
    end
    table.sort(ItemList, function(a, b) return a.name < b.name end)
end

local Creator = {
    active = false,
    step = 0,           -- 0=inactive, 1=info, 2=zone, 3=spots, 4=events, 5=review
    nuiFocused = false, -- NUI mouse+keyboard focus durumu

    -- Step 1 data (farm info, NUI formdan gelir)
    farmInfo = {
        name = '', label = '',
        difficulty = 'medium', cooldown = 300, multiplier = 1.0,
        hourReq = 0, rewardMoney = 150, rewardXP = 75,
        useCycle = true, minYield = 1, maxYield = 3,
        showInNpc = true,
        jobSlots = 0,
    },

    zonePoints = {},    -- { vector3, ... }

    spots = {},         -- { { x,y,z, heading, itemName, label }, ... }
    selectedItemIdx = 1,

    eventZones = {},    -- { { x,y,z, radius, eventType, eventLabel, chance }, ... }
    selectedEventIdx = 1,
    currentRadius = 8.0,
    currentChance = 30,

    cursorPos = nil,    -- vector3 — raycast result
}

local function GetCreatorNextStep(step)
    if step == 1 then return 2 end
    if step == 2 then return 3 end
    if step == 3 then return IsEventSystemEnabled() and 4 or 5 end
    if step == 4 then return 5 end
    return step
end

local function GetCreatorPrevStep(step)
    if step == 5 then return IsEventSystemEnabled() and 4 or 3 end
    if step == 4 then return 3 end
    if step == 3 then return 2 end
    if step == 2 then return 1 end
    return nil
end

local function IsCursorInsideCurrentZone(pos)
    return pos and #Creator.zonePoints >= 3 and IsPointInPoly(pos.x, pos.y, Creator.zonePoints)
end

local function IsSpotInsideCurrentZone(spot)
    return spot and #Creator.zonePoints >= 3 and IsPointInPoly(spot.x, spot.y, Creator.zonePoints)
end

local function FindLastSpotForItem(itemName)
    if not itemName or itemName == '' then return nil end
    for idx = #Creator.spots, 1, -1 do
        local spot = Creator.spots[idx]
        if spot and spot.itemName == itemName then
            return spot, idx
        end
    end
    return nil
end

local function GetDistance2D(a, b)
    if not a or not b then return nil end
    local dx = (a.x or 0) - (b.x or 0)
    local dy = (a.y or 0) - (b.y or 0)
    return math.sqrt(dx * dx + dy * dy)
end

local function ReconcilePlacementsWithZone()
    if #Creator.zonePoints < 3 then return 0, 0 end

    local keptSpots, removedSpots = {}, 0
    for _, spot in ipairs(Creator.spots) do
        if IsSpotInsideCurrentZone(spot) then
            table.insert(keptSpots, spot)
        else
            removedSpots = removedSpots + 1
        end
    end
    Creator.spots = keptSpots

    local keptEvents, removedEvents = {}, 0
    for _, zone in ipairs(Creator.eventZones) do
        if IsSpotInsideCurrentZone(zone) then
            table.insert(keptEvents, zone)
        else
            removedEvents = removedEvents + 1
        end
    end
    Creator.eventZones = keptEvents

    if removedSpots > 0 then
        Krypton.Notify(('%s spot yeni alan disinda kaldigi icin kaldirildi.'):format(removedSpots), 'warning')
    end

    if removedEvents > 0 then
        Krypton.Notify(('%s event bolgesi yeni alan disinda kaldigi icin kaldirildi.'):format(removedEvents), 'warning')
    end

    return removedSpots, removedEvents
end

local function SendCreatorUpdate()
    local zPoints = {}
    for _, p in ipairs(Creator.zonePoints) do
        table.insert(zPoints, { x = p.x, y = p.y, z = p.z })
    end

    local sSpots = {}
    for i, s in ipairs(Creator.spots) do
        table.insert(sSpots, { index = i, x = s.x, y = s.y, z = s.z, itemName = s.itemName, label = s.label })
    end

    local sEvents = {}
    for i, e in ipairs(Creator.eventZones) do
        table.insert(sEvents, { index = i, x = e.x, y = e.y, z = e.z, radius = e.radius, eventType = e.eventType, eventLabel = e.eventLabel, chance = e.chance })
    end

    local selectedItem = ItemList[Creator.selectedItemIdx]
    local eventTypes = cfg.eventTypes or {}
    local selEvent = eventTypes[Creator.selectedEventIdx]
    local lastSameItemSpot = selectedItem and FindLastSpotForItem(selectedItem.name) or nil
    local sameItemDistance = nil
    if Creator.cursorPos and lastSameItemSpot then
        sameItemDistance = GetDistance2D(Creator.cursorPos, lastSameItemSpot)
    end

    SendNUIMessage({
        action = 'updateCreatorState',
        data = {
            step = Creator.step,
            zonePoints = zPoints,
            zoneArea = #Creator.zonePoints >= 3 and math.floor(PolyArea(Creator.zonePoints)) or 0,
            spots = sSpots,
            eventZones = sEvents,
            eventsEnabled = IsEventSystemEnabled(),
            selectedItem = selectedItem and selectedItem.label or '?',
            selectedItemName = selectedItem and selectedItem.name or '',
            selectedEventType = selEvent and selEvent.label or '?',
            currentRadius = Creator.currentRadius,
            currentChance = Creator.currentChance,
            sameItemDistance = sameItemDistance,
            minSpotSpacing = cfgCreator.minSpotSpacing or 1.5,
            farmInfo = Creator.farmInfo,
        }
    })
end

local function SetCreatorStep(step)
    if step == 4 and not IsEventSystemEnabled() then
        step = 5
    end

    Creator.step = step

    if step == 1 or step == 5 then
        -- Form steps: NUI focus ON, camera OFF
        Creator.nuiFocused = true
        SetNuiFocus(true, true)
        if TopCam.active then DisableTopCam() end
    elseif step >= 2 and step <= 4 then
        -- Placement steps: NUI focus OFF, top-down camera ON
        Creator.nuiFocused = false
        SetNuiFocus(false, false)
        if not TopCam.active then EnableTopCam() end
    end

    SendNUIMessage({
        action = 'creatorSetStep',
        data = { step = step }
    })
    SendCreatorUpdate()
end

function StartCreator()
    if Creator.active then return end

    BuildItemList()
    if #ItemList == 0 then
        TriggerEvent('chat:addMessage', { args = { '^1[Krypton]', 'Config.Items is empty!' } })
        return
    end

    Creator.active = true
    Creator.zonePoints = {}
    Creator.spots = {}
    Creator.eventZones = {}
    Creator.selectedItemIdx = 1
    Creator.selectedEventIdx = 1
    Creator.currentRadius = cfgCreator.defaultEventRadius or 8.0
    Creator.currentChance = cfgCreator.defaultEventChance or 30
    Creator.cursorPos = nil

    local defaults = cfg.defaults or {}
    Creator.farmInfo = {
        name = '', label = '',
        description = '',
        imageUrl = '',
        cooldown = defaults.cooldown or 300,
        multiplier = defaults.multiplier or 1.0,
        rewardMoney = defaults.rewardMoney or 150,
        useCycle = defaults.useCycleSystem ~= false,
        minYield = defaults.minYield or 1,
        maxYield = defaults.maxYield or 3,
        showInNpc = true,
        jobSlots = defaults.jobSlots or 0,
    }

    local nuiItems = {}
    for _, item in ipairs(ItemList) do
        table.insert(nuiItems, { name = item.name, label = item.label })
    end

    local nuiEventTypes = {}
    if IsEventSystemEnabled() then
        for _, et in ipairs(cfg.eventTypes or {}) do
            table.insert(nuiEventTypes, { id = et.id, label = et.label, icon = et.icon })
        end
    end

    local creatorDefaults = cfg.defaults or {}
    creatorDefaults = table.clone and table.clone(creatorDefaults) or json.decode(json.encode(creatorDefaults)) or {}
    creatorDefaults.eventsEnabled = IsEventSystemEnabled()

    SendNUIMessage({
        action = 'openCreator',
        data = {
            items = nuiItems,
            eventTypes = nuiEventTypes,
            farmInfo = Creator.farmInfo,
            defaults = creatorDefaults,
        }
    })

    SetCreatorStep(1) -- Start at info form

    CreateThread(function()
        while Creator.active do
            if Creator.step >= 2 and Creator.step <= 4 then
                local hitPos, didHit = RaycastFromCamera(200.0)
                if didHit and hitPos then
                    Creator.cursorPos = vector3(hitPos.x, hitPos.y, GetGroundZ(hitPos))
                end
                DrawCrosshair()
            end

            if Creator.step == 2 then
                local pts = Creator.zonePoints
                local lineC = cfgCreator.zoneLineColor or { r = 0, g = 200, b = 255, a = 200 }
                local ptC = cfgCreator.zonePointColor or { r = 0, g = 255, b = 100, a = 220 }
                local ptSize = cfgCreator.zonePointSize or 0.4
                local wallColor = { r = 200, g = 30, b = 30, a = 40 }
                local wallH = 3.0

                for i, p in ipairs(pts) do
                    DrawSphere(p, ptSize, ptC)
                    DrawText3D(p, '#' .. i)
                    if i > 1 then
                        DrawLine3D(pts[i - 1], p, lineC)
                        DrawWall(pts[i - 1], p, wallH, wallColor)
                    end
                end
                if #pts >= 3 then
                    DrawLine3D(pts[#pts], pts[1], { r = lineC.r, g = lineC.g, b = lineC.b, a = math.floor(lineC.a * 0.5) })
                    DrawWall(pts[#pts], pts[1], wallH, { r = wallColor.r, g = wallColor.g, b = wallColor.b, a = math.floor(wallColor.a * 0.5) })
                end
                if #pts > 0 and Creator.cursorPos then
                    DrawLine3D(pts[#pts], Creator.cursorPos, { r = 255, g = 255, b = 255, a = 80 })
                    DrawSphere(Creator.cursorPos, ptSize * 0.7, { r = 255, g = 255, b = 255, a = 100 })
                elseif Creator.cursorPos then
                    DrawSphere(Creator.cursorPos, ptSize * 0.7, { r = 255, g = 255, b = 255, a = 100 })
                end

            elseif Creator.step == 3 then
                local pts = Creator.zonePoints
                local lineC = cfgCreator.zoneLineColor or { r = 0, g = 200, b = 255, a = 200 }
                local spotC = cfgCreator.spotMarkerColor or { r = 0, g = 150, b = 255, a = 180 }
                local ghostC = cfgCreator.spotGhostColor or { r = 255, g = 255, b = 255, a = 100 }
                local spotSize = cfgCreator.spotMarkerSize or 0.5
                local minSpotSpacing = cfgCreator.minSpotSpacing or 1.5
                local wallColor = { r = 200, g = 30, b = 30, a = 25 }
                local wallH = 3.0
                local selItem = ItemList[Creator.selectedItemIdx]
                local lastSameItemSpot = selItem and FindLastSpotForItem(selItem.name) or nil

                for i = 1, #pts do
                    local ni = (i % #pts) + 1
                    DrawLine3D(pts[i], pts[ni], { r = lineC.r, g = lineC.g, b = lineC.b, a = math.floor(lineC.a * 0.3) })
                    DrawWall(pts[i], pts[ni], wallH, wallColor)
                end

                for idx, s in ipairs(Creator.spots) do
                    local sp = vector3(s.x, s.y, s.z)
                    local markerColor = IsSpotInsideCurrentZone(s) and spotC or { r = 255, g = 80, b = 80, a = 200 }
                    DrawSpotMarker(sp, spotSize, markerColor)
                    DrawText3D(sp, '#' .. idx .. ' ~b~' .. (s.label or s.itemName))
                end

                if Creator.cursorPos then
                    local inZone = IsCursorInsideCurrentZone(Creator.cursorPos)
                    local gc = inZone and ghostC or { r = 255, g = 50, b = 50, a = 120 }
                    DrawSpotMarker(Creator.cursorPos, spotSize, gc)

                    if selItem then
                        local label = '[ ' .. selItem.label .. ' ]'
                        if lastSameItemSpot then
                            local dist = GetDistance2D(Creator.cursorPos, lastSameItemSpot)
                            if dist then
                                local spacingStatus = dist < minSpotSpacing and '~r~' or '~g~'
                                DrawLine3D(vector3(lastSameItemSpot.x, lastSameItemSpot.y, lastSameItemSpot.z), Creator.cursorPos, { r = 255, g = 255, b = 255, a = 70 })
                                label = ('%s\n%s%.2fm~s~ prev'):format(label, spacingStatus, dist)
                            end
                        end
                        DrawText3D(Creator.cursorPos, label)
                    end
                end

            elseif Creator.step == 4 then
                local pts = Creator.zonePoints
                local lineC = cfgCreator.zoneLineColor or { r = 0, g = 200, b = 255, a = 200 }
                local evColor = cfgCreator.eventZoneColor or { r = 255, g = 100, b = 0, a = 60 }
                local evOutline = cfgCreator.eventZoneOutline or { r = 255, g = 150, b = 0, a = 200 }

                for i = 1, #pts do
                    local ni = (i % #pts) + 1
                    DrawLine3D(pts[i], pts[ni], { r = lineC.r, g = lineC.g, b = lineC.b, a = math.floor(lineC.a * 0.3) })
                end

                for _, s in ipairs(Creator.spots) do
                    DrawCylinder(vector3(s.x, s.y, s.z), 0.3, 0.3, { r = 0, g = 150, b = 255, a = 60 })
                end

                for idx, e in ipairs(Creator.eventZones) do
                    local ep = vector3(e.x, e.y, e.z)
                    DrawCylinder(ep, e.radius * 2, 0.3, evColor)
                    local segments = 32
                    for s = 1, segments do
                        local a1 = (s - 1) / segments * math.pi * 2
                        local a2 = s / segments * math.pi * 2
                        local p1 = vector3(ep.x + math.cos(a1) * e.radius, ep.y + math.sin(a1) * e.radius, ep.z)
                        local p2 = vector3(ep.x + math.cos(a2) * e.radius, ep.y + math.sin(a2) * e.radius, ep.z)
                        DrawLine3D(p1, p2, evOutline)
                    end
                    DrawText3D(ep, 'EZ#' .. idx .. ' ' .. e.eventLabel .. ' (' .. e.chance .. '%)')
                end

                if Creator.cursorPos then
                    DrawCylinder(Creator.cursorPos, Creator.currentRadius * 2, 0.2, { r = 255, g = 200, b = 0, a = 40 })
                    local segments = 32
                    for s = 1, segments do
                        local a1 = (s - 1) / segments * math.pi * 2
                        local a2 = s / segments * math.pi * 2
                        local r = Creator.currentRadius
                        local p1 = vector3(Creator.cursorPos.x + math.cos(a1) * r, Creator.cursorPos.y + math.sin(a1) * r, Creator.cursorPos.z)
                        local p2 = vector3(Creator.cursorPos.x + math.cos(a2) * r, Creator.cursorPos.y + math.sin(a2) * r, Creator.cursorPos.z)
                        DrawLine3D(p1, p2, { r = 255, g = 255, b = 255, a = 80 })
                    end
                    local eventTypes = cfg.eventTypes or {}
                    local selEvent = eventTypes[Creator.selectedEventIdx]
                    if selEvent then
                        DrawText3D(Creator.cursorPos, '[ ' .. selEvent.label .. ' R=' .. string.format('%.0f', Creator.currentRadius) .. ' ' .. Creator.currentChance .. '% ]')
                    end
                end
            end

            Wait(0)
        end
    end)

    CreateThread(function()
        while Creator.active do
            if Creator.step >= 2 and Creator.step <= 4 and not Creator.nuiFocused then

                DisableControlAction(0, 24, true)
                if IsDisabledControlJustPressed(0, 24) then
                    if Creator.step == 2 then
                        if Creator.cursorPos then
                            local maxPts = cfgCreator.maxZonePoints or 50
                            if #Creator.zonePoints >= maxPts then
                                PlaySoundFrontend(-1, 'ERROR', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                            else
                                table.insert(Creator.zonePoints, Creator.cursorPos)
                                PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                                SendCreatorUpdate()
                            end
                        end

                    elseif Creator.step == 3 then
                        if Creator.cursorPos then
                            local inZone = IsCursorInsideCurrentZone(Creator.cursorPos)
                            if not inZone then
                                PlaySoundFrontend(-1, 'ERROR', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                            else
                                local tooClose = false
                                local minDist = cfgCreator.minSpotSpacing or 1.5
                                for _, s in ipairs(Creator.spots) do
                                    local dx = s.x - Creator.cursorPos.x
                                    local dy = s.y - Creator.cursorPos.y
                                    if math.sqrt(dx * dx + dy * dy) < minDist then
                                        tooClose = true
                                        break
                                    end
                                end
                                if tooClose then
                                    PlaySoundFrontend(-1, 'ERROR', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                                else
                                    local maxSpots = cfgCreator.maxSpotsPerFarm or 50
                                    if #Creator.spots >= maxSpots then
                                        PlaySoundFrontend(-1, 'ERROR', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                                    else
                                        local selItem = ItemList[Creator.selectedItemIdx]
                                        table.insert(Creator.spots, {
                                            x = Creator.cursorPos.x,
                                            y = Creator.cursorPos.y,
                                            z = Creator.cursorPos.z,
                                            heading = GetEntityHeading(PlayerPedId()),
                                            itemName = selItem and selItem.name or 'tomato',
                                            label = selItem and selItem.label or 'Tomato',
                                        })
                                        PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                                        SendCreatorUpdate()
                                    end
                                end
                            end
                        end

                    elseif Creator.step == 4 and IsEventSystemEnabled() then
                        if Creator.cursorPos then
                            local eventTypes = cfg.eventTypes or {}
                            local selEvent = eventTypes[Creator.selectedEventIdx]
                            table.insert(Creator.eventZones, {
                                x = Creator.cursorPos.x,
                                y = Creator.cursorPos.y,
                                z = Creator.cursorPos.z,
                                radius = Creator.currentRadius,
                                eventType = selEvent and selEvent.id or 'thief',
                                eventLabel = selEvent and selEvent.label or 'Thief',
                                chance = Creator.currentChance,
                            })
                            PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                            SendCreatorUpdate()
                        end
                    end
                end

                DisableControlAction(0, 25, true)
                if IsDisabledControlJustPressed(0, 25) then
                    if Creator.step == 2 and #Creator.zonePoints > 0 then
                        table.remove(Creator.zonePoints)
                        PlaySoundFrontend(-1, 'CANCEL', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                        SendCreatorUpdate()
                    elseif Creator.step == 3 and #Creator.spots > 0 then
                        table.remove(Creator.spots)
                        PlaySoundFrontend(-1, 'CANCEL', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                        SendCreatorUpdate()
                    elseif Creator.step == 4 and #Creator.eventZones > 0 then
                        table.remove(Creator.eventZones)
                        PlaySoundFrontend(-1, 'CANCEL', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                        SendCreatorUpdate()
                    end
                end

                DisableControlAction(0, 45, true) -- R
                if IsDisabledControlJustPressed(0, 45) then -- R
                    if Creator.step == 3 then
                        Creator.selectedItemIdx = Creator.selectedItemIdx % #ItemList + 1
                        PlaySoundFrontend(-1, 'NAV_LEFT_RIGHT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                        SendCreatorUpdate()
                    elseif Creator.step == 4 then
                        local evtCount = #(cfg.eventTypes or {})
                        if evtCount > 0 then
                            Creator.selectedEventIdx = Creator.selectedEventIdx % evtCount + 1
                            PlaySoundFrontend(-1, 'NAV_LEFT_RIGHT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                            SendCreatorUpdate()
                        end
                    end
                end

                if Creator.step == 3 then
                    if IsControlJustPressed(0, 241) then -- scroll up
                        Creator.selectedItemIdx = Creator.selectedItemIdx % #ItemList + 1
                        PlaySoundFrontend(-1, 'NAV_LEFT_RIGHT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                        SendCreatorUpdate()
                    end
                    if IsControlJustPressed(0, 242) then -- scroll down
                        Creator.selectedItemIdx = Creator.selectedItemIdx - 1
                        if Creator.selectedItemIdx < 1 then Creator.selectedItemIdx = #ItemList end
                        PlaySoundFrontend(-1, 'NAV_LEFT_RIGHT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                        SendCreatorUpdate()
                    end
                end

                if Creator.step == 4 then
                    if IsControlJustPressed(0, 241) then -- scroll up
                        Creator.currentRadius = math.min(Creator.currentRadius + 1.0, cfgCreator.maxEventRadius or 50.0)
                        SendCreatorUpdate()
                    end
                    if IsControlJustPressed(0, 242) then -- scroll down
                        Creator.currentRadius = math.max(Creator.currentRadius - 1.0, cfgCreator.minEventRadius or 2.0)
                        SendCreatorUpdate()
                    end
                    -- G / H = chance +/- 5%
                    if IsControlJustPressed(0, 47) then -- G
                        Creator.currentChance = math.min(Creator.currentChance + 5, 100)
                        SendCreatorUpdate()
                    end
                    if IsControlJustPressed(0, 74) then -- H
                        Creator.currentChance = math.max(Creator.currentChance - 5, 5)
                        SendCreatorUpdate()
                    end
                end

                if IsControlJustPressed(0, 191) then -- ENTER
                    if Creator.step == 2 then
                        local minPts = cfgCreator.minZonePoints or 3
                        if #Creator.zonePoints < minPts then
                            PlaySoundFrontend(-1, 'ERROR', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                        else
                            ReconcilePlacementsWithZone()
                            SetCreatorStep(GetCreatorNextStep(Creator.step))
                        end
                    elseif Creator.step == 3 then
                        if #Creator.spots == 0 then
                            PlaySoundFrontend(-1, 'ERROR', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                        else
                            ReconcilePlacementsWithZone()
                            SetCreatorStep(GetCreatorNextStep(Creator.step))
                        end
                    elseif Creator.step == 4 then
                        -- Events optional — can skip
                        ReconcilePlacementsWithZone()
                        SetCreatorStep(GetCreatorNextStep(Creator.step))
                    end
                end

                if IsControlJustPressed(0, 202) then -- BACKSPACE
                    local prevStep = GetCreatorPrevStep(Creator.step)
                    if prevStep then
                        SetCreatorStep(prevStep)
                    end
                end

                DisableControlAction(0, 200, true) -- MAP
                if IsDisabledControlJustPressed(0, 200) then
                    CancelCreator()
                end
            end

            Wait(0)
        end
    end)
end

local function LandPlayerOnGround()
    local ped = PlayerPedId()
    if TopCam.savedPos then
        local found, gz = GetGroundZFor_3dCoord(TopCam.savedPos.x, TopCam.savedPos.y, TopCam.savedPos.z + 10.0, false)
        if found then
            pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
            SetEntityCoordsNoOffset(ped, TopCam.savedPos.x, TopCam.savedPos.y, gz + 0.5, false, false, false)
        else
            pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
            SetEntityCoordsNoOffset(ped, TopCam.savedPos.x, TopCam.savedPos.y, TopCam.savedPos.z + 0.5, false, false, false)
        end
        SetEntityHeading(ped, TopCam.savedHeading)
        return
    end
    local pos = GetEntityCoords(ped)
    local found, gz = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z + 5.0, false)
    if found then
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoordsNoOffset(ped, pos.x, pos.y, gz + 0.5, false, false, false)
    else
        for testZ = pos.z, 0, -25.0 do
            local f2, gz2 = GetGroundZFor_3dCoord(pos.x, pos.y, testZ, false)
            if f2 then
                pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
                SetEntityCoordsNoOffset(ped, pos.x, pos.y, gz2 + 0.5, false, false, false)
                return
            end
        end
    end
end

function CancelCreator()
    if not Creator.active then return end
    Creator.active = false
    Creator.step = 0
    Creator.nuiFocused = false
    local wasTopCam = TopCam.active
    DisableTopCam()
    if wasTopCam then LandPlayerOnGround() end
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeCreator' })
    TriggerEvent('chat:addMessage', { args = { '^3[Krypton Admin]', 'Farm creation cancelled.' } })
end

function SaveCreator()
    if not Creator.active then return end

    ReconcilePlacementsWithZone()
    SendCreatorUpdate()

    if #Creator.zonePoints < 3 then
        TriggerEvent('chat:addMessage', { args = { '^1[Krypton Admin]', 'Cannot save: Need at least 3 zone points!' } })
        return
    end
    if #Creator.spots == 0 then
        TriggerEvent('chat:addMessage', { args = { '^1[Krypton Admin]', 'Cannot save: Need at least 1 spot!' } })
        return
    end
    if Creator.farmInfo.name == '' then
        TriggerEvent('chat:addMessage', { args = { '^1[Krypton Admin]', 'Cannot save: Farm name is required!' } })
        return
    end

    local zPoints = {}
    for _, p in ipairs(Creator.zonePoints) do
        table.insert(zPoints, { x = p.x, y = p.y, z = p.z })
    end

    local center = PolyCentroid(Creator.zonePoints)

    local minZ, maxZ = 9999, -9999
    for _, p in ipairs(Creator.zonePoints) do
        if p.z < minZ then minZ = p.z end
        if p.z > maxZ then maxZ = p.z end
    end

    local serSpots = {}
    for _, s in ipairs(Creator.spots) do
        table.insert(serSpots, {
            x = s.x, y = s.y, z = s.z,
            heading = s.heading or 0,
            itemName = s.itemName or 'tomato',
            label = s.label or s.itemName or 'Tomato',
        })
    end

    local serEvents = {}
    for _, e in ipairs(Creator.eventZones) do
        table.insert(serEvents, {
            x = e.x, y = e.y, z = e.z,
            radius = e.radius or 8.0,
            eventType = e.eventType or 'thief',
            eventLabel = e.eventLabel or 'Thief',
            chance = e.chance or 30,
        })
    end

    local payload = {
        name = Creator.farmInfo.name,
        label = Creator.farmInfo.label ~= '' and Creator.farmInfo.label or Creator.farmInfo.name,
        description = Creator.farmInfo.description or '',
        imageUrl = Creator.farmInfo.imageUrl or '',
        cooldown = Creator.farmInfo.cooldown or 300,
        multiplier = Creator.farmInfo.multiplier or 1.0,
        rewardMoney = Creator.farmInfo.rewardMoney or 150,
        useCycle = Creator.farmInfo.useCycle ~= false,
        minYield = Creator.farmInfo.minYield or 1,
        maxYield = Creator.farmInfo.maxYield or 3,
        showInNpc = Creator.farmInfo.showInNpc ~= false,
        jobSlots = math.max(0, math.floor(tonumber(Creator.farmInfo.jobSlots) or 0)),
        centerX = center.x,
        centerY = center.y,
        centerZ = center.z,
        zonePoints = zPoints,
        minZ = minZ - 5,
        maxZ = maxZ + 10,
        spots = serSpots,
        eventZones = serEvents,
    }

    TriggerServerEvent('krypton-farming:admin:createFarm', payload)

    Creator.active = false
    Creator.step = 0
    Creator.nuiFocused = false
    local wasTopCam = TopCam.active
    DisableTopCam()
    if wasTopCam then LandPlayerOnGround() end
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeCreator' })
    local saveSummary = 'Farm saving... ' .. #serSpots .. ' spots'
    if IsEventSystemEnabled() then
        saveSummary = saveSummary .. ', ' .. #serEvents .. ' event zones'
    end
    TriggerEvent('chat:addMessage', { args = { '^2[Krypton Admin]', saveSummary } })
end

RegisterNUICallback('creatorSetFarmInfo', function(data, cb)
    if data then
        Creator.farmInfo = {
            name = data.name or '',
            label = data.label or data.name or '',
            description = data.description or '',
            imageUrl = data.imageUrl or '',
            cooldown = tonumber(data.cooldown) or 300,
            multiplier = tonumber(data.multiplier) or 1.0,
            rewardMoney = tonumber(data.rewardMoney) or 150,
            useCycle = data.useCycle ~= false,
            minYield = tonumber(data.minYield) or 1,
            maxYield = tonumber(data.maxYield) or 3,
            showInNpc = data.showInNpc ~= false,
            jobSlots = math.max(0, math.floor(tonumber(data.jobSlots) or 0)),
        }
    end
    SetCreatorStep(2)
    cb('ok')
end)

RegisterNUICallback('creatorNextStep', function(_, cb)
    local nextStep = GetCreatorNextStep(Creator.step)
    if nextStep and nextStep ~= Creator.step then
        if Creator.step == 2 or Creator.step == 3 or Creator.step == 4 then
            ReconcilePlacementsWithZone()
        end
        SetCreatorStep(nextStep)
    end
    cb('ok')
end)

RegisterNUICallback('creatorPrevStep', function(_, cb)
    if Creator.step == 1 then
        CancelCreator()
    else
        local prevStep = GetCreatorPrevStep(Creator.step)
        if prevStep then
            SetCreatorStep(prevStep)
        end
    end
    cb('ok')
end)

RegisterNUICallback('creatorSave', function(_, cb)
    SaveCreator()
    cb('ok')
end)

RegisterNUICallback('creatorCancel', function(_, cb)
    CancelCreator()
    cb('ok')
end)

RegisterNUICallback('creatorGoToStep', function(data, cb)
    local step = data and tonumber(data.step)
    if step and step >= 1 and step <= 5 then
        if Creator.step == 2 or Creator.step == 3 or Creator.step == 4 then
            ReconcilePlacementsWithZone()
        end
        SetCreatorStep(step)
    end
    cb('ok')
end)
