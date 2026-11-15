--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
    Customized: Antigravity CodeWalker & Blender 3D Freecam Zone Editor (V4 Depth & Anti-Penetration)
]]

local creatorActive = false
local zoneType = nil
local points = {}
local history = {}
local selectedPoint = 0
local grabMode = false
local gridSnap = false
local snapSize = 0.5
local topDownMode = false

-- Z-Plane Lock & Cursor Distance Control (Anti-penetration)
local zLockMode = false
local lockedZ = 0.0
local cursorOffset = 0.0
local baseCursorDistance = 25.0

-- Camera & Spatial variables
local cam = nil
local camCoords = vec3(0, 0, 0)
local camRot = vec3(0, 0, 0)
local camSpeed = 0.6
local baseSpeed = 0.6
local aimCoords = vec3(0, 0, 0)
local aimHit = false
local aimNormal = vec3(0, 0, 1)

-- Zone Dimensions
local xCoord, yCoord, zCoord = 0.0, 0.0, 0.0
local heading = 0.0
local height = 15.0
local width = 8.0
local length = 8.0
local format = 'array'
local lastZone = {}
local useLastZoneFalsyInputs = { ['0'] = true, [''] = true, ['false'] = true, ['nil'] = true }

-----------------------------------------------------------------------------------------
-- MATH & HELPER FUNCTIONS
-----------------------------------------------------------------------------------------

local function rotationToDirection(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)
    local num = math.abs(math.cos(x))
    return vec3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

local function camMoveVectors(yaw)
    local rad = math.rad(yaw)
    return vec3(-math.sin(rad), math.cos(rad), 0.0), vec3(math.cos(rad), math.sin(rad), 0.0)
end

local function round(val, decimals)
    local mult = 10 ^ (decimals or 2)
    return math.floor(val * mult + 0.5) / mult
end

local function saveHistory()
    local snap = {}
    for i = 1, #points do
        snap[i] = vec3(points[i].x, points[i].y, points[i].z)
    end
    history[#history + 1] = {
        points = snap,
        zCoord = zCoord,
        height = height,
        selectedPoint = selectedPoint
    }
    if #history > 30 then
        table.remove(history, 1)
    end
end

local function undo()
    if #history > 0 then
        local prev = table.remove(history)
        points = {}
        for i = 1, #prev.points do
            points[i] = vec3(prev.points[i].x, prev.points[i].y, prev.points[i].z)
        end
        zCoord = prev.zCoord
        height = prev.height
        selectedPoint = math.min(prev.selectedPoint, #points)
        lib.notify({ title = 'Geri Alındı (Undo)', type = 'inform' })
    end
end

local function calculateCenterAndZ()
    if #points == 0 then return end
    local sumX, sumY, sumZ = 0, 0, 0
    local minZ, maxZ = 99999.0, -99999.0
    for i = 1, #points do
        sumX = sumX + points[i].x
        sumY = sumY + points[i].y
        sumZ = sumZ + points[i].z
        if points[i].z < minZ then minZ = points[i].z end
        if points[i].z > maxZ then maxZ = points[i].z end
    end
    xCoord = round(sumX / #points, 2)
    yCoord = round(sumY / #points, 2)
    zCoord = round(sumZ / #points, 2)
end

local function calculatePerimeter()
    if #points < 2 then return 0.0 end
    local dist = 0.0
    for i = 1, #points - 1 do
        dist = dist + #(vec2(points[i].x, points[i].y) - vec2(points[i + 1].x, points[i + 1].y))
    end
    return round(dist, 1)
end

-----------------------------------------------------------------------------------------
-- 2D TOP-LEFT HUD & 3D RENDERING
-----------------------------------------------------------------------------------------

local function draw2DHUD()
    -- Compact sleek background bar at top-left
    DrawRect(0.20, 0.10, 0.38, 0.18, 0, 0, 0, 195)

    -- Header Title
    SetTextFont(4)
    SetTextScale(0.35, 0.35)
    SetTextColour(0, 230, 255, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(("~b~3D ZONE EDITÖRÜ~s~ [%s] | Ofset: ~y~%+.1fm~s~ | Z-Kilit: %s"):format(
        zoneType:upper(), cursorOffset, zLockMode and ("~g~%.1fm~s~"):format(lockedZ) or "~r~KAPALI~s~"
    ))
    DrawText(0.015, 0.015)

    -- Controls Line 1 (Camera & Depth)
    SetTextFont(4)
    SetTextScale(0.25, 0.25)
    SetTextColour(255, 255, 255, 230)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString("~y~[WASD + Q/E]~s~ Uçuş | ~g~[Mouse Tekerlek]~s~ Noktayı Yakınlaştır / Uzaklaştır | ~y~[R]~s~ Sıfırla")
    DrawText(0.015, 0.038)

    -- Controls Line 2 (Roof Lock & Precision)
    SetTextFont(4)
    SetTextScale(0.25, 0.25)
    SetTextColour(255, 255, 255, 230)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString("~o~[L] Çatı Z-Kilidi (İçeri Girmeyi Engeller)~s~ | ~y~[U] Kuşbakışı 90°~s~ | ~p~[Ok Tuşları]~s~ İnce Ayar")
    DrawText(0.015, 0.060)

    -- Controls Line 3 (Vertex Editing)
    SetTextFont(4)
    SetTextScale(0.25, 0.25)
    SetTextColour(255, 255, 255, 230)
    SetTextOutline()
    SetTextEntry("STRING")
    if zoneType == 'poly' then
        AddTextComponentString("~g~[SOL TIK]~s~ Çizgi Çek & Nokta Ekle | ~y~[TAB]~s~ Seç | ~o~[G]~s~ Taşı | ~r~[Backspace]~s~ Sil | ~p~[Z]~s~ Geri Al")
    elseif zoneType == 'box' then
        AddTextComponentString("~g~[SOL TIK]~s~ Merkez Belirle | ~y~[Shift+Q/E]~s~ Açı | ~y~[Alt+Tekerlek]~s~ Uzunluk")
    else
        AddTextComponentString("~g~[SOL TIK]~s~ Merkez Belirle | ~y~[Shift+Tekerlek]~s~ Yarıçap Ayarla")
    end
    DrawText(0.015, 0.082)

    -- Controls Line 4 (Thickness & Save)
    SetTextFont(4)
    SetTextScale(0.25, 0.25)
    SetTextColour(255, 255, 255, 230)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString("~p~[Shift+Tekerlek]~s~ Yükseklik | ~p~[Ctrl+Tekerlek]~s~ Z Kotu | ~g~[ENTER]~s~ Kaydet & Kopyala | ~r~[ESC]~s~ Çık")
    DrawText(0.015, 0.104)

    -- Status Line 5
    SetTextFont(4)
    SetTextScale(0.27, 0.27)
    SetTextColour(0, 255, 180, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    local statusText = ""
    if zoneType == 'poly' then
        statusText = ("Noktalar: ~w~%d~s~ | Yükseklik: ~w~%.1fm~s~ | Çevre: ~w~%.1fm~s~ | İmleç Z: ~w~%.2fm~s~"):format(
            #points, height, calculatePerimeter(), aimCoords.z
        )
        if selectedPoint > 0 and points[selectedPoint] then
            statusText = statusText .. (" | ~y~Seçili: #%d%s~s~"):format(selectedPoint, grabMode and " (~o~TAŞINIYOR~s~)" or "")
        end
    elseif zoneType == 'box' then
        statusText = ("Genişlik: ~w~%.1fm~s~ | Uzunluk: ~w~%.1fm~s~ | Yükseklik: ~w~%.1fm~s~ | Açı: ~w~%.1f°~s~"):format(width, length, height, heading)
    else
        statusText = ("Yarıçap: ~w~%.1fm~s~"):format(height)
    end
    AddTextComponentString(statusText)
    DrawText(0.015, 0.126)
end

local function draw3DText(coords, text, size, color)
    local onScreen, screenX, screenY = World3dToScreen2d(coords.x, coords.y, coords.z)
    if onScreen then
        SetTextScale(size or 0.35, size or 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        if color then
            SetTextColour(color.r, color.g, color.b, color.a or 255)
        else
            SetTextColour(255, 255, 255, 255)
        end
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(screenX, screenY)
    end
end

local function drawWallQuad(p1, p2, zBottom, zTop, r, g, b, a)
    DrawPoly(p1.x, p1.y, zBottom, p2.x, p2.y, zBottom, p2.x, p2.y, zTop, r, g, b, a)
    DrawPoly(p2.x, p2.y, zTop, p2.x, p2.y, zBottom, p1.x, p1.y, zBottom, r, g, b, a)
    DrawPoly(p1.x, p1.y, zBottom, p2.x, p2.y, zTop, p1.x, p1.y, zTop, r, g, b, a)
    DrawPoly(p1.x, p1.y, zTop, p2.x, p2.y, zTop, p1.x, p1.y, zBottom, r, g, b, a)
end

local function renderScene()
    local thicknessHalf = height / 2.0
    local baseZ = zCoord - thicknessHalf
    local topZ = zCoord + thicknessHalf

    -- 1. Raycast Aim Marker & 3D Gizmo
    if aimHit or aimCoords then
        local markerColor = grabMode and { r = 255, g = 180, b = 0 } or (zLockMode and { r = 0, g = 255, b = 100 } or { r = 0, g = 230, b = 255 })
        DrawMarker(28, aimCoords.x, aimCoords.y, aimCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.25, 0.25, 0.25, markerColor.r, markerColor.g, markerColor.b, 200, false, false, 2, false, nil, nil, false)

        -- 3D Crosshair
        DrawLine(aimCoords.x - 0.8, aimCoords.y, aimCoords.z, aimCoords.x + 0.8, aimCoords.y, aimCoords.z, markerColor.r, markerColor.g, markerColor.b, 255)
        DrawLine(aimCoords.x, aimCoords.y - 0.8, aimCoords.z, aimCoords.x, aimCoords.y + 0.8, aimCoords.z, markerColor.r, markerColor.g, markerColor.b, 255)
        DrawLine(aimCoords.x, aimCoords.y, aimCoords.z - 1.5, aimCoords.x, aimCoords.y, aimCoords.z + 1.5, markerColor.r, markerColor.g, markerColor.b, 200)

        if zLockMode then
            DrawMarker(1, aimCoords.x, aimCoords.y, lockedZ - 0.05, 0, 0, 0, 0, 0, 0, 3.0, 3.0, 0.1, 0, 255, 100, 80, false, false, 2, false, nil, nil, false)
        end
    end

    -- 2. PolyZone CAD Chain Rendering (Continuous Outer Line)
    if zoneType == 'poly' then
        local n = #points
        for i = 1, n do
            local p = points[i]
            local isSel = (i == selectedPoint)

            local vColor = isSel and { r = 255, g = 215, b = 0, a = 255 } or { r = 0, g = 255, b = 150, a = 220 }
            DrawMarker(1, p.x, p.y, p.z - 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.3, 0.3, 0.6, vColor.r, vColor.g, vColor.b, vColor.a, false, false, 2, false, nil, nil, false)

            draw3DText(vec3(p.x, p.y, p.z + 0.5), ('#%d%s (Z:%.1f)'):format(i, isSel and ' [SEÇİLİ]' or '', p.z), 0.32, vColor)

            -- Solid chain segment to next point only
            if i < n then
                local nextP = points[i + 1]
                DrawLine(p.x, p.y, baseZ, nextP.x, nextP.y, baseZ, 0, 230, 255, 255)
                DrawLine(p.x, p.y, topZ, nextP.x, nextP.y, topZ, 0, 230, 255, 255)
                DrawLine(p.x, p.y, baseZ, p.x, p.y, topZ, 0, 180, 255, 180)
                drawWallQuad(p, nextP, baseZ, topZ, 0, 140, 255, 45)
            end
        end

        if n > 0 then
            local lastP = points[n]
            DrawLine(lastP.x, lastP.y, baseZ, lastP.x, lastP.y, topZ, 0, 180, 255, 180)
        end

        -- Active elastic line from LAST point directly to CURRENT cursor
        if n > 0 and not grabMode then
            local lastP = points[n]
            DrawLine(lastP.x, lastP.y, baseZ, aimCoords.x, aimCoords.y, baseZ, 255, 220, 0, 255)
            DrawLine(lastP.x, lastP.y, topZ, aimCoords.x, aimCoords.y, topZ, 255, 220, 0, 255)
            DrawLine(lastP.x, lastP.y, lastP.z, aimCoords.x, aimCoords.y, aimCoords.z, 255, 220, 0, 255)
            drawWallQuad(lastP, aimCoords, baseZ, topZ, 255, 220, 0, 40)

            -- Faint preview line to Point 1
            if n >= 2 then
                local firstP = points[1]
                DrawLine(aimCoords.x, aimCoords.y, aimCoords.z, firstP.x, firstP.y, firstP.z, 255, 100, 0, 100)
            end
        end

    -- 3. BoxZone Rendering
    elseif zoneType == 'box' then
        local rad = math.rad(-heading)
        local sinH = math.sin(rad)
        local cosH = math.cos(rad)
        local center = vec2(xCoord, yCoord)
        local boxPoints = {
            center + vec2((width * cosH + length * sinH), (length * cosH - width * sinH)) / 2,
            center + vec2(-(width * cosH - length * sinH), (length * cosH + width * sinH)) / 2,
            center + vec2(-(width * cosH + length * sinH), -(length * cosH - width * sinH)) / 2,
            center + vec2((width * cosH - length * sinH), -(length * cosH + width * sinH)) / 2,
        }
        for i = 1, 4 do
            local p1 = boxPoints[i]
            local p2 = boxPoints[(i % 4) + 1]
            DrawLine(p1.x, p1.y, baseZ, p2.x, p2.y, baseZ, 255, 80, 40, 255)
            DrawLine(p1.x, p1.y, topZ, p2.x, p2.y, topZ, 255, 80, 40, 255)
            DrawLine(p1.x, p1.y, baseZ, p1.x, p1.y, topZ, 255, 80, 40, 180)
            drawWallQuad(p1, p2, baseZ, topZ, 255, 80, 40, 50)
        end
        DrawMarker(28, xCoord, yCoord, zCoord, 0, 0, 0, 0, 0, 0, 0.4, 0.4, 0.4, 255, 255, 0, 220, false, false, 2, false, nil, nil, false)

    -- 4. SphereZone Rendering
    elseif zoneType == 'sphere' then
        DrawMarker(28, xCoord, yCoord, zCoord, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            height * 2.0, height * 2.0, height * 2.0, 0, 180, 255, 80, false, false, 2, false, nil, nil, false)
    end
end

-----------------------------------------------------------------------------------------
-- LIFECYCLE & INPUT HANDLER
-----------------------------------------------------------------------------------------

local function closeCreator(cancel)
    if cam then
        RenderScriptCams(false, false, 0, true, false)
        SetCamActive(cam, false)
        pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]]
        DestroyCam(cam, false)
        cam = nil
    end

    local ped = cache.ped or PlayerPedId()
    FreezeEntityPosition(ped, false)
    pcall(function() exports['FeloxAC']:isVisible(true) end) --[[FeloxAC:auto]]
    SetEntityVisible(ped, true, false)
    pcall(function() exports['FeloxAC']:isInvincible(false) end) --[[FeloxAC:auto]]
    SetEntityInvincible(ped, false)
    lib.hideTextUI()

    if not cancel then
        calculateCenterAndZ()

        ---@type string[]?
        local input = lib.inputDialog(('Zone Kaydet: %s'):format(zoneType:upper()), {
            { type = 'input', label = 'Zone İsmi / Name', placeholder = 'ornek_zone', default = 'Yeni_Zone' },
            {
                type = 'select',
                label = 'Export Formatı',
                default = format,
                options = {
                    { value = 'array', label = 'Array (Tablo / Config.Zones)' },
                    { value = 'function', label = 'Function (lib.zones)' },
                    { value = 'target', label = 'Target (ox_target)' },
                }
            }
        })

        if input and input[1] then
            format = input[2] or 'array'
            local zoneName = input[1]

            local payload = {
                zoneType = zoneType,
                name = zoneName,
                format = format,
                xCoord = xCoord,
                yCoord = yCoord,
                zCoord = zCoord,
                heading = heading,
                height = height,
                width = width,
                length = length,
                points = points
            }

            TriggerServerEvent('ox_lib:saveZone', payload)

            local luaCode = ""
            if zoneType == 'poly' then
                local ptLines = {}
                for i = 1, #points do
                    ptLines[#ptLines + 1] = ('\t\tvec3(%.2f, %.2f, %.2f),'):format(points[i].x, points[i].y, zCoord)
                end
                luaCode = ('{\n\tname = "%s",\n\tpoints = {\n%s\n\t},\n\tthickness = %.1f,\n}'):format(
                    zoneName, table.concat(ptLines, '\n'), height
                )
            elseif zoneType == 'box' then
                luaCode = ('{\n\tname = "%s",\n\tcoords = vec3(%.2f, %.2f, %.2f),\n\tsize = vec3(%.2f, %.2f, %.2f),\n\trotation = %.1f,\n}'):format(
                    zoneName, xCoord, yCoord, zCoord, width, length, height, heading
                )
            elseif zoneType == 'sphere' then
                luaCode = ('{\n\tname = "%s",\n\tcoords = vec3(%.2f, %.2f, %.2f),\n\tradius = %.1f,\n}'):format(
                    zoneName, xCoord, yCoord, zCoord, height
                )
            end

            lib.setClipboard(luaCode)
            print('^2[ox_lib Zone Creator] Zone Başarıyla Kaydedildi ve Panoya Kopyalandı!^7')
            print(luaCode)
            lib.notify({ title = 'Zone Kaydedildi & Panoya Kopyalandı!', type = 'success' })
        end
    end

    creatorActive = false
    zoneType = nil
    points = {}
    history = {}
    grabMode = false
    zLockMode = false
    cursorOffset = 0.0
end

local function startCreator(arg, useLast)
    creatorActive = true
    zoneType = arg
    points = {}
    history = {}
    selectedPoint = 0
    grabMode = false
    gridSnap = false
    topDownMode = false
    zLockMode = false
    lockedZ = 0.0
    cursorOffset = 0.0

    local ped = cache.ped or PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    xCoord, yCoord, zCoord = round(pedCoords.x, 2), round(pedCoords.y, 2), round(pedCoords.z, 2)
    lockedZ = zCoord

    heading = useLast and lastZone[zoneType] and lastZone[zoneType].heading or 0.0
    height = useLast and lastZone[zoneType] and lastZone[zoneType].height or 15.0
    width = useLast and lastZone[zoneType] and lastZone[zoneType].width or 8.0
    length = useLast and lastZone[zoneType] and lastZone[zoneType].length or 8.0

    -- Setup 3D Freecam Camera
    camCoords = pedCoords + vec3(0.0, 0.0, 10.0)
    camRot = GetGameplayCamRot(2)
    cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', camCoords.x, camCoords.y, camCoords.z,
        camRot.x, camRot.y, camRot.z, GetGameplayCamFov(), false, 0)
    pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)

    FreezeEntityPosition(ped, true)
    pcall(function() exports['FeloxAC']:isVisible(false) end) --[[FeloxAC:auto]]
    SetEntityVisible(ped, false, false)
    pcall(function() exports['FeloxAC']:isInvincible(true) end) --[[FeloxAC:auto]]
    SetEntityInvincible(ped, true)
    lib.hideTextUI()

    CreateThread(function()
        while creatorActive do
            Wait(0)
            DisableAllControlActions(0)

            -- 1. Freecam Look Rotation
            local lookX = GetDisabledControlNormal(0, 1) * -4.5
            local lookY = GetDisabledControlNormal(0, 2) * -4.5
            camRot = vec3(
                math.max(-89.9, math.min(89.9, camRot.x + lookY)),
                0.0,
                camRot.z + lookX
            )

            -- 2. Freecam Movement (WASD + Q/E)
            local forward, right = camMoveVectors(camRot.z)
            local currentSpeed = camSpeed
            if IsDisabledControlPressed(0, 21) then -- Shift (Sprint)
                currentSpeed = currentSpeed * 3.5
            elseif IsDisabledControlPressed(0, 19) then -- Alt (Precision)
                currentSpeed = currentSpeed * 0.2
            end

            local moveVec = vec3(0, 0, 0)
            if IsDisabledControlPressed(0, 32) then moveVec = moveVec + forward end -- W (32)
            if IsDisabledControlPressed(0, 33) then moveVec = moveVec - forward end -- S (33)
            if IsDisabledControlPressed(0, 34) then moveVec = moveVec - right end   -- A (34)
            if IsDisabledControlPressed(0, 35) then moveVec = moveVec + right end   -- D (35)
            if IsDisabledControlPressed(0, 38) then moveVec = moveVec + vec3(0, 0, 1) end -- E (38 - Up)
            if IsDisabledControlPressed(0, 44) then moveVec = moveVec - vec3(0, 0, 1) end -- Q (44 - Down)

            if #(moveVec) > 0.0 then
                camCoords = camCoords + (moveVec / #(moveVec)) * currentSpeed
            end

            SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
            SetCamRot(cam, camRot.x, camRot.y, camRot.z, 2)

            -- 3. Surface & Plane Raycasting (Anti-Penetration)
            local camDir = rotationToDirection(camRot)

            if zLockMode then
                -- MATHEMATICAL PLANE INTERSECTION (Guaranteed never penetrates inside house)
                if math.abs(camDir.z) > 0.001 then
                    local t = (lockedZ - camCoords.z) / camDir.z
                    if t > 0 and t < 800.0 then
                        local planePoint = camCoords + camDir * t
                        aimCoords = planePoint + (camDir * cursorOffset)
                        aimHit = true
                        aimNormal = vec3(0, 0, 1)
                    else
                        aimCoords = camCoords + camDir * (baseCursorDistance + cursorOffset)
                        aimHit = false
                    end
                else
                    aimCoords = camCoords + camDir * (baseCursorDistance + cursorOffset)
                    aimHit = false
                end
            else
                -- HIGH-PRECISION OUTER SURFACE LOS PROBE (Catches outer walls, roof geometry)
                local rayEnd = camCoords + camDir * 600.0
                local rayHandle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, rayEnd.x, rayEnd.y, rayEnd.z, 511, ped, 7)
                local _, hit, hitCoords, normal = GetShapeTestResult(rayHandle)

                if hit == 1 then
                    aimHit = true
                    -- Apply cursor offset along camera ray (scrolling down pulls it OUT of the house)
                    aimCoords = hitCoords + (camDir * cursorOffset)
                    aimNormal = normal
                else
                    aimHit = false
                    aimCoords = camCoords + camDir * (baseCursorDistance + cursorOffset)
                    aimNormal = vec3(0, 0, 1)
                end
            end

            -- 4. Manual Precision Nudging (Arrow Keys)
            local nudgeStep = IsDisabledControlPressed(0, 21) and 0.5 or (IsDisabledControlPressed(0, 19) and 0.02 or 0.1)

            if IsDisabledControlPressed(0, 172) then -- Arrow UP (172)
                aimCoords = aimCoords + vec3(0.0, nudgeStep, 0.0)
            end
            if IsDisabledControlPressed(0, 173) then -- Arrow DOWN (173)
                aimCoords = aimCoords - vec3(0.0, nudgeStep, 0.0)
            end
            if IsDisabledControlPressed(0, 174) then -- Arrow LEFT (174)
                aimCoords = aimCoords - vec3(nudgeStep, 0.0, 0.0)
            end
            if IsDisabledControlPressed(0, 175) then -- Arrow RIGHT (175)
                aimCoords = aimCoords + vec3(nudgeStep, 0.0, 0.0)
            end

            -- Apply Grid Snapping
            if gridSnap then
                aimCoords = vec3(
                    math.floor(aimCoords.x / snapSize + 0.5) * snapSize,
                    math.floor(aimCoords.y / snapSize + 0.5) * snapSize,
                    math.floor(aimCoords.z / snapSize + 0.5) * snapSize
                )
            end

            -- If in Grab Mode, update selected point position live
            if grabMode and selectedPoint > 0 and points[selectedPoint] then
                points[selectedPoint] = vec3(aimCoords.x, aimCoords.y, aimCoords.z)
                calculateCenterAndZ()
            end

            -- 5. Dedicated Key Controls

            -- Add Point / Drop Grabbed: ONLY Left Click (24) or Space (22)
            if IsDisabledControlJustPressed(0, 24) or IsDisabledControlJustPressed(0, 22) then
                if zoneType == 'poly' then
                    saveHistory()
                    if grabMode then
                        grabMode = false
                        lib.notify({ title = ('Nokta #%d Yerleştirildi'):format(selectedPoint), type = 'success' })
                    else
                        local newP = vec3(round(aimCoords.x, 2), round(aimCoords.y, 2), round(aimCoords.z, 2))
                        points[#points + 1] = newP
                        selectedPoint = #points
                        calculateCenterAndZ()
                        lib.notify({ title = ('Nokta #%d Eklendi (Z: %.1f)'):format(#points, newP.z), type = 'inform' })
                    end
                elseif zoneType == 'box' or zoneType == 'sphere' then
                    xCoord = round(aimCoords.x, 2)
                    yCoord = round(aimCoords.y, 2)
                    zCoord = round(aimCoords.z, 2)
                    lib.notify({ title = 'Merkez Konumu Güncellendi', type = 'success' })
                end
            end

            -- Select Next Point: TAB (37)
            if IsDisabledControlJustPressed(0, 37) and #points > 0 then
                if IsDisabledControlPressed(0, 21) then
                    selectedPoint = selectedPoint - 1
                    if selectedPoint < 1 then selectedPoint = #points end
                else
                    selectedPoint = (selectedPoint % #points) + 1
                end
            end

            -- Grab / Move Point: G (47)
            if IsDisabledControlJustPressed(0, 47) and #points > 0 then
                if selectedPoint == 0 then selectedPoint = #points end
                grabMode = not grabMode
                if grabMode then
                    saveHistory()
                    lib.notify({ title = ('Nokta #%d Taşınıyor... (Bırakmak için Tıklayın)'):format(selectedPoint), type = 'warning' })
                end
            end

            -- Reset Distance Offset: R (45)
            if IsDisabledControlJustPressed(0, 45) then
                cursorOffset = 0.0
                lib.notify({ title = 'Mesafe Sıfırlandı (0.0m)', type = 'inform' })
            end

            -- Toggle Z-Plane Lock: L (182 / 80)
            if IsDisabledControlJustPressed(0, 182) or IsDisabledControlJustPressed(0, 80) then
                zLockMode = not zLockMode
                if zLockMode then
                    lockedZ = round(aimCoords.z, 2)
                    lib.notify({ title = ('Çatı Z-Kilidi AÇIK: %.2fm (İçeri Girmez)'):format(lockedZ), type = 'success' })
                else
                    lib.notify({ title = 'Çatı Z-Kilidi KAPALI (Yüzey Raycast)', type = 'inform' })
                end
            end

            -- Delete Point: Backspace (194) or Delete (178)
            if IsDisabledControlJustPressed(0, 194) or IsDisabledControlJustPressed(0, 178) then
                if zoneType == 'poly' and #points > 0 then
                    saveHistory()
                    local delIdx = (selectedPoint > 0 and selectedPoint <= #points) and selectedPoint or #points
                    table.remove(points, delIdx)
                    selectedPoint = math.min(delIdx, #points)
                    calculateCenterAndZ()
                    lib.notify({ title = 'Nokta Silindi', type = 'error' })
                end
            end

            -- Undo: Z (20)
            if IsDisabledControlJustPressed(0, 20) then
                undo()
            end

            -- Toggle Top-Down View: U (303)
            if IsDisabledControlJustPressed(0, 303) then
                topDownMode = not topDownMode
                if topDownMode then
                    camRot = vec3(-89.9, 0.0, camRot.z)
                    lib.notify({ title = 'Kuşbakışı 90° Kilitlendi', type = 'inform' })
                else
                    camRot = vec3(-35.0, 0.0, camRot.z)
                    lib.notify({ title = 'Serbest Bakış Açıldı', type = 'inform' })
                end
            end

            -- Toggle Grid Snapping: C (26)
            if IsDisabledControlJustPressed(0, 26) then
                gridSnap = not gridSnap
                lib.notify({ title = gridSnap and 'Grid Snapping: AÇIK (0.5m)' or 'Grid Snapping: KAPALI', type = 'inform' })
            end

            -- Mouse Wheel Controls: Scroll Up (17) / Scroll Down (16)
            if IsDisabledControlJustReleased(0, 17) then -- Scroll Up
                if IsDisabledControlPressed(0, 21) then -- Shift + Scroll (Height)
                    height = height + 1.0
                elseif IsDisabledControlPressed(0, 36) then -- Ctrl + Scroll (Base Z / Locked Z)
                    if zLockMode then
                        lockedZ = lockedZ + 0.5
                    elseif zoneType == 'poly' then
                        zCoord = zCoord + 0.5
                    else
                        width = width + 0.5
                    end
                elseif IsDisabledControlPressed(0, 19) then -- Alt + Scroll (Length)
                    length = length + 0.5
                else -- DIRECT MOUSE WHEEL: PUSH POINT FURTHER (UZAKLAŞTIR)
                    cursorOffset = cursorOffset + 0.8
                end
            elseif IsDisabledControlJustReleased(0, 16) then -- Scroll Down
                if IsDisabledControlPressed(0, 21) then -- Shift + Scroll (Height)
                    height = math.max(1.0, height - 1.0)
                elseif IsDisabledControlPressed(0, 36) then -- Ctrl + Scroll (Base Z / Locked Z)
                    if zLockMode then
                        lockedZ = lockedZ - 0.5
                    elseif zoneType == 'poly' then
                        zCoord = zCoord - 0.5
                    else
                        width = math.max(0.5, width - 0.5)
                    end
                elseif IsDisabledControlPressed(0, 19) then -- Alt + Scroll (Length)
                    length = math.max(0.5, length - 0.5)
                else -- DIRECT MOUSE WHEEL: PULL POINT CLOSER (YAKINLAŞTIR / EVİN DIŞINA ÇEK)
                    cursorOffset = cursorOffset - 0.8
                end
            end

            -- Rotate Box: Shift + Q (44) and Shift + E (38)
            if zoneType == 'box' then
                if IsDisabledControlPressed(0, 21) and IsDisabledControlJustPressed(0, 38) then
                    heading = (heading - 5.0) % 360.0
                elseif IsDisabledControlPressed(0, 21) and IsDisabledControlJustPressed(0, 44) then
                    heading = (heading + 5.0) % 360.0
                end
            end

            -- Save Zone: ENTER (201)
            if IsDisabledControlJustReleased(0, 201) then
                if zoneType == 'poly' and #points < 3 then
                    lib.notify({ title = 'En az 3 nokta gereklidir!', type = 'error' })
                else
                    closeCreator(false)
                    return
                end
            end

            -- Cancel Zone: ESC (200)
            if IsDisabledControlJustReleased(0, 200) then
                SetPauseMenuActive(false)
                closeCreator(true)
                lib.notify({ title = 'Zone Oluşturma İptal Edildi', type = 'inform' })
                return
            end

            -- 6. Render 3D World Scene & Sleek Top-Left 2D HUD
            renderScene()
            draw2DHUD()
        end
    end)
end

-----------------------------------------------------------------------------------------
-- COMMANDS & CHAT SUGGESTIONS
-----------------------------------------------------------------------------------------

RegisterCommand('zone', function(source, args, rawCommand)
    if args[1] ~= 'poly' and args[1] ~= 'box' and args[1] ~= 'sphere' then
        lib.notify({ title = 'Geçersiz zone tipi: poly, box, sphere', type = 'error' })
        return
    end

    if creatorActive then
        lib.notify({ title = 'Zaten aktif bir zone düzenleyicisi açık', type = 'error' })
        return
    end

    local useLast = args[2] and not useLastZoneFalsyInputs[args[2]]
    startCreator(args[1], useLast)
end, true)

CreateThread(function()
    Wait(1000)
    TriggerEvent('chat:addSuggestion', '/zone', '3D CodeWalker & Blender Zone Editörünü Başlatır', {
        { name = 'zoneType', help = 'poly, box, sphere' },
        { name = 'useLast', help = 'Son ayarları kopyala (opsiyonel)' }
    })
end)
