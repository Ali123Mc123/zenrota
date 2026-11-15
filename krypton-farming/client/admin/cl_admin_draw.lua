local Config = Config
local cfg = Config.AdminPanel or {}
local cfgCreator = cfg.creator or {}
local cfgNoclip = cfg.noclip or {}

function IsEventSystemEnabled()
    return cfg.events and cfg.events.enabled == true
end

TopCam = {
    active = false,
    cam = nil,
    x = 0, y = 0,              -- world position of camera center
    height = 80.0,             -- camera altitude
    minHeight = tonumber(cfgCreator.minCameraHeight) or 1.0,
    maxHeight = tonumber(cfgCreator.maxCameraHeight),
    heightStep = tonumber(cfgCreator.cameraHeightStep) or 0.8,
    speed = 0.8,               -- base movement speed (world units per frame)
    slowSpeed = 0.15,          -- slow mode speed
    isSlow = false,            -- Caps Lock toggle
    savedPos = nil,            -- player position before entering cam
    savedHeading = 0,
}

function EnableTopCam()
    if TopCam.active then return end
    TopCam.active = true
    TopCam.isSlow = false

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    TopCam.savedPos = pos
    TopCam.savedHeading = GetEntityHeading(ped)
    TopCam.x = pos.x
    TopCam.y = pos.y
    TopCam.height = 80.0

    pcall(function() exports['FeloxAC']:isVisible(false) end) --[[FeloxAC:auto]]
    SetEntityVisible(ped, false, false)
    SetEntityCollision(ped, false, false)
    FreezeEntityPosition(ped, true)
    pcall(function() exports['FeloxAC']:isInvincible(true) end) --[[FeloxAC:auto]]
    SetEntityInvincible(ped, true)
    SetEntityAlpha(ped, 0, false)

    TopCam.cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(TopCam.cam, TopCam.x, TopCam.y, TopCam.height + pos.z)
    SetCamRot(TopCam.cam, -90.0, 0.0, 0.0, 2) -- looking straight down
    SetCamFov(TopCam.cam, 60.0)
    RenderScriptCams(true, true, 500, true, false)

    CreateThread(function()
        while TopCam.active do
            local ped2 = PlayerPedId()
            local speed = TopCam.isSlow and TopCam.slowSpeed or TopCam.speed

            -- Scale speed with height (zoom out = faster panning)
            local heightScale = TopCam.height / 80.0
            speed = speed * heightScale

            if IsDisabledControlPressed(0, 21) then speed = speed * (cfgNoclip.fastMultiplier or 3.0) end

            local dx, dy = 0, 0
            if IsDisabledControlPressed(0, 32) then dy = dy + speed end   -- W
            if IsDisabledControlPressed(0, 33) then dy = dy - speed end   -- S
            if IsDisabledControlPressed(0, 34) then dx = dx - speed end   -- A
            if IsDisabledControlPressed(0, 35) then dx = dx + speed end   -- D

            TopCam.x = TopCam.x + dx
            TopCam.y = TopCam.y + dy

            local zoomStep = TopCam.heightStep or 0.8
            if IsDisabledControlPressed(0, 21) or IsControlPressed(0, 21) then
                zoomStep = zoomStep * (cfgNoclip.fastMultiplier or 3.0)
            end
            if TopCam.isSlow then
                zoomStep = zoomStep * 0.3
            end

            -- Space / PageUp = Zoom out (higher)
            local isZoomOutPressed = IsDisabledControlPressed(0, 22) or IsControlPressed(0, 22)
                or IsDisabledControlPressed(0, 10) or IsControlPressed(0, 10)

            -- Ctrl (Duck: 36, Sniper/PC L-Ctrl: 210, VehAim/PC L-Ctrl: 326, Parachute/PC L-Ctrl: 153, VehAttack: 132, C: 26, PageDown: 11) = Zoom in (closer to ground)
            local isZoomInPressed = IsDisabledControlPressed(0, 36) or IsControlPressed(0, 36)
                or IsDisabledControlPressed(0, 210) or IsControlPressed(0, 210)
                or IsDisabledControlPressed(0, 326) or IsControlPressed(0, 326)
                or IsDisabledControlPressed(0, 153) or IsControlPressed(0, 153)
                or IsDisabledControlPressed(0, 132) or IsControlPressed(0, 132)
                or IsDisabledControlPressed(0, 26) or IsControlPressed(0, 26)
                or IsDisabledControlPressed(0, 11) or IsControlPressed(0, 11)

            if isZoomOutPressed then
                TopCam.height = TopCam.height + zoomStep
                if TopCam.maxHeight and TopCam.maxHeight > 0 then
                    TopCam.height = math.min(TopCam.height, TopCam.maxHeight)
                end
            end
            if isZoomInPressed then
                TopCam.height = TopCam.height - zoomStep
                if TopCam.minHeight and TopCam.minHeight > 0 then
                    TopCam.height = math.max(TopCam.height, TopCam.minHeight)
                end
            end

            -- Mouse wheel zoom when wizard is not actively using scroll for item/radius selection
            local canUseScroll = not Creator or not Creator.active or (Creator.step ~= 3 and Creator.step ~= 4)
            if canUseScroll then
                if IsControlJustPressed(0, 241) or IsDisabledControlJustPressed(0, 241) then
                    TopCam.height = math.max(TopCam.height - (zoomStep * 3.0), TopCam.minHeight or 1.0)
                elseif IsControlJustPressed(0, 242) or IsDisabledControlJustPressed(0, 242) then
                    TopCam.height = TopCam.height + (zoomStep * 3.0)
                    if TopCam.maxHeight and TopCam.maxHeight > 0 then
                        TopCam.height = math.min(TopCam.height, TopCam.maxHeight)
                    end
                end
            end

            local found, gz = GetGroundZFor_3dCoord(TopCam.x, TopCam.y, 1000.0, false)
            local baseZ = found and gz or 0

            SetCamCoord(TopCam.cam, TopCam.x, TopCam.y, baseZ + TopCam.height)
            SetCamRot(TopCam.cam, -90.0, 0.0, 0.0, 2)

            -- Keep ped at ground level under camera
            local pedGz = baseZ + 1.0
            SetEntityCoordsNoOffset(ped2, TopCam.x, TopCam.y, pedGz, false, false, false)

            DisableControlAction(0, 22, true)   -- Jump/Space
            DisableControlAction(0, 36, true)   -- Crouch/Ctrl
            DisableControlAction(0, 210, true)  -- Sniper zoom / L-Ctrl
            DisableControlAction(0, 326, true)  -- Veh aim / L-Ctrl
            DisableControlAction(0, 153, true)  -- Parachute brake / L-Ctrl
            DisableControlAction(0, 132, true)  -- Veh attack cam / L-Ctrl
            DisableControlAction(0, 26, true)   -- C / Look behind
            DisableControlAction(0, 44, true)   -- Cover
            DisableControlAction(0, 75, true)   -- Exit vehicle
            DisableControlAction(0, 37, true)   -- Select weapon
            DisableControlAction(0, 24, true)   -- Attack
            DisableControlAction(0, 25, true)   -- Aim
            DisableControlAction(0, 47, true)   -- Detonate
            DisableControlAction(0, 58, true)   -- Throw grenade
            DisableControlAction(0, 263, true)  -- Melee
            DisableControlAction(0, 264, true)  -- Melee2
            DisableControlAction(0, 245, true)  -- T (chat)
            DisableControlAction(0, 200, true)  -- Map/ESC (handled manually)

            -- Caps Lock toggle slow mode (control 137)
            if IsDisabledControlJustPressed(0, 137) then
                TopCam.isSlow = not TopCam.isSlow
            end

            Wait(0)
        end
    end)
end

function DisableTopCam()
    if not TopCam.active then return end
    TopCam.active = false

    if TopCam.cam then
        RenderScriptCams(false, true, 500, true, false)
        pcall(function() exports['FeloxAC']:destroyCam(TopCam.cam) end) --[[FeloxAC:auto]]
        DestroyCam(TopCam.cam, false)
        TopCam.cam = nil
    end

    local ped = PlayerPedId()
    pcall(function() exports['FeloxAC']:isVisible(true) end) --[[FeloxAC:auto]]
    SetEntityVisible(ped, true, false)
    SetEntityCollision(ped, true, true)
    FreezeEntityPosition(ped, false)
    pcall(function() exports['FeloxAC']:isInvincible(false) end) --[[FeloxAC:auto]]
    SetEntityInvincible(ped, false)
    ResetEntityAlpha(ped)
end

function RaycastFromCamera(dist)
    dist = dist or 500.0
    -- For top-down cam: cast a ray from screen center straight down
    if TopCam.active and TopCam.cam then
        local camCoord = GetCamCoord(TopCam.cam)
        local dest = vector3(camCoord.x, camCoord.y, camCoord.z - dist)
        local ray = StartShapeTestRay(camCoord.x, camCoord.y, camCoord.z, dest.x, dest.y, dest.z, 1 + 16, PlayerPedId(), 0)
        local _, hit, endCoords = GetShapeTestResult(ray)
        if hit then return vector3(endCoords.x, endCoords.y, endCoords.z), true end
        return nil, false
    end
    local camPos = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local rX, rZ = math.rad(camRot.x), math.rad(camRot.z)
    local cosX = math.abs(math.cos(rX))
    local dir = vector3(-math.sin(rZ) * cosX, math.cos(rZ) * cosX, math.sin(rX))
    local dest = camPos + dir * dist
    local ray = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, 1 + 16, PlayerPedId(), 0)
    local _, hit, endCoords = GetShapeTestResult(ray)
    if hit then return vector3(endCoords.x, endCoords.y, endCoords.z), true end
    return nil, false
end

function GetGroundZ(coords)
    if cfgCreator.snapToGround == false then return coords.z end
    local found, gz = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 5.0, false)
    return found and gz or coords.z
end

function IsPointInPoly(px, py, poly)
    local inside = false
    local j = #poly
    for i = 1, #poly do
        local xi, yi = poly[i].x, poly[i].y
        local xj, yj = poly[j].x, poly[j].y
        if ((yi > py) ~= (yj > py)) and (px < (xj - xi) * (py - yi) / (yj - yi) + xi) then
            inside = not inside
        end
        j = i
    end
    return inside
end

function PolyArea(poly)
    local area = 0
    local j = #poly
    for i = 1, #poly do
        area = area + (poly[j].x + poly[i].x) * (poly[j].y - poly[i].y)
        j = i
    end
    return math.abs(area / 2.0)
end

function PolyCentroid(poly)
    local cx, cy, cz = 0, 0, 0
    for _, p in ipairs(poly) do
        cx, cy, cz = cx + p.x, cy + p.y, cz + p.z
    end
    local n = #poly
    return vector3(cx / n, cy / n, cz / n)
end

function DrawLine3D(p1, p2, color)
    DrawLine(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, color.r, color.g, color.b, color.a)
end

function DrawSphere(pos, size, color)
    DrawMarker(28, pos.x, pos.y, pos.z, 0,0,0, 0,0,0, size, size, size, color.r, color.g, color.b, color.a, false, false, 2, false, nil, nil, false)
end

function DrawCylinder(pos, sizeXY, sizeZ, color)
    DrawMarker(1, pos.x, pos.y, pos.z - 0.98, 0,0,0, 0,0,0, sizeXY, sizeXY, sizeZ, color.r, color.g, color.b, color.a, false, false, 2, false, nil, nil, false)
end

-- Downward chevron marker (type 2)
function DrawDownArrow(pos, size, color)
    DrawMarker(2, pos.x, pos.y, pos.z + 1.8, 0,0,0, 180.0,0,0, size, size, size, color.r, color.g, color.b, color.a, true, true, 2, true, nil, nil, false)
end

-- Ground ring marker (type 25)
function DrawGroundRing(pos, size, color)
    DrawMarker(25, pos.x, pos.y, pos.z - 0.95, 0,0,0, 0,0,0, size, size, 0.5, color.r, color.g, color.b, color.a, false, false, 2, false, nil, nil, false)
end

function DrawSpotMarker(pos, size, color)
    DrawMarker(1, pos.x, pos.y, pos.z - 0.92, 0, 0, 0, 0, 0, 0, size * 1.15, size * 1.15, 0.18, color.r, color.g, color.b, math.min((color.a or 180) + 25, 255), false, false, 2, false, nil, nil, false)
    DrawGroundRing(pos, size * 2.0, color)
    DrawDownArrow(pos, size * 0.6, color)
end

function DrawWall(p1, p2, height, color)
    local r, g, b, a = color.r, color.g, color.b, color.a
    local b1 = vector3(p1.x, p1.y, p1.z)
    local b2 = vector3(p2.x, p2.y, p2.z)
    local t1 = vector3(p1.x, p1.y, p1.z + height)
    local t2 = vector3(p2.x, p2.y, p2.z + height)
    DrawPoly(b1.x, b1.y, b1.z, b2.x, b2.y, b2.z, t1.x, t1.y, t1.z, r, g, b, a)
    DrawPoly(b2.x, b2.y, b2.z, t2.x, t2.y, t2.z, t1.x, t1.y, t1.z, r, g, b, a)
    DrawPoly(t1.x, t1.y, t1.z, b2.x, b2.y, b2.z, b1.x, b1.y, b1.z, r, g, b, a)
    DrawPoly(t1.x, t1.y, t1.z, t2.x, t2.y, t2.z, b2.x, b2.y, b2.z, r, g, b, a)
end

function DrawText3D(pos, text)
    local onScreen, sx, sy = World3dToScreen2d(pos.x, pos.y, pos.z + 0.6)
    if not onScreen then return end
    SetTextScale(0.28, 0.28)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(1, 0, 0, 0, 200)
    SetTextEdge(1, 0, 0, 0, 200)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(sx, sy)
end

function DrawCrosshair()
    local s = cfgCreator.crosshairSize or 0.008
    DrawRect(0.5, 0.5, s, 0.001, 255, 255, 255, 180)
    DrawRect(0.5, 0.5, 0.001, s * (16/9), 255, 255, 255, 180)
end
