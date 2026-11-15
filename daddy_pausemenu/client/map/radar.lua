-- Home mini map: GTA's own radar moved under the page's mini map box while it shows, then put back the way the HUD
-- had it (Config.Map.Radar.Restore). The page sends the box as window fractions (pm:map:radar).
local Cfg = (Config.Map or {}).Radar or {}
local GFX = 'platform:/textures/graphics'
local shown, wasHidden, busy = false, false, false

-- Component positions only take effect after the radar is rebuilt: a bigmap toggle with a brief wait does that.
local function rebuild()
    DisplayRadar(false)
    SetRadarBigmapEnabled(true, false)
    Wait(50)
    SetRadarBigmapEnabled(false, false)
    DisplayRadar(true)
end

-- Converts top-left screen fraction box (r) into GTA's native 'L', 'B' (Bottom-Left) coordinate frame.
-- In GTA V, scissor stencils and masks are natively computed from the bottom edge.
local function getBottomCoords(r)
    local margin = (1.0 - GetSafeZoneSize()) * 0.5
    local x = r.x - margin
    local y = (1.0 - (r.y + r.h)) - margin
    return x, y
end

-- The radar fills the box: minimap_mask defines the clipping window exactly on the box,
-- while minimap canvas is scaled and centered to cover the mask completely.
-- Blur is moved off-screen (-1.0, -1.0) so it never darkens or obscures any part of the box.
-- Zoom scale is broadened so postal map tiles provide a comfortable overview without hitting empty LOD files.
local box
local function place(r)
    local x, y = getBottomCoords(r)
    local scaleW = (Cfg.MapScale and Cfg.MapScale.w) or 1.55
    local scaleH = (Cfg.MapScale and Cfg.MapScale.h) or 1.55
    local offX = (Cfg.MapOffset and Cfg.MapOffset.x) or 0.0
    local offY = (Cfg.MapOffset and Cfg.MapOffset.y) or 0.0

    local maskScaleW = (Cfg.MaskScale and Cfg.MaskScale.w) or 1.0
    local maskScaleH = (Cfg.MaskScale and Cfg.MaskScale.h) or 1.0
    local maskOffX = (Cfg.MaskOffset and Cfg.MaskOffset.x) or 0.0
    local maskOffY = (Cfg.MaskOffset and Cfg.MaskOffset.y) or 0.0

    local maskW = r.w * maskScaleW
    local maskH = r.h * maskScaleH
    local maskX = x + maskOffX * r.w
    local maskY = y + maskOffY * r.h

    local mapW = r.w * scaleW
    local mapH = r.h * scaleH
    local mapX = x - (mapW - r.w) * 0.5 + offX * r.w
    local mapY = y - (mapH - r.h) * 0.5 + offY * r.h

    for _, t in ipairs((Cfg.Restore or {}).textures or {}) do RemoveReplaceTexture(GFX, t[1]) end
    SetMinimapClipType(0)
    -- Hide blur off-screen to prevent dark overlay/shading over the box
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -1.0, -1.0, 0.01, 0.01)
    SetMinimapComponentPosition('minimap_mask', 'L', 'B', maskX, maskY, maskW, maskH)
    SetMinimapComponentPosition('minimap', 'L', 'B', mapX, mapY, mapW, mapH)
    if Cfg.ZoomScale then
        SetMapZoomDataLevel(0, Cfg.ZoomScale, 0.9, 0.08, 0.0, 0.0)
        SetMapZoomDataLevel(1, Cfg.ZoomScale, 0.9, 0.08, 0.0, 0.0)
    end
    if Cfg.Zoom then SetRadarZoom(Cfg.Zoom) end
    LockMinimapAngle(0)
    box = r
    rebuild()
    if Cfg.Zoom then SetRadarZoom(Cfg.Zoom) end
end

-- Every frame while shown: keep radar displayed, force exterior tiles so roofs/bridges do not blank it,
-- keep North locked to top (0), enforce radar zoom so tiles stream properly on foot and in vehicle,
-- and draw backdrop under the transparent radar.
local function frame()
    while shown do
        DisplayRadar(true)
        SetRadarAsExteriorThisFrame()
        LockMinimapAngle(0)
        if Cfg.Zoom then SetRadarZoom(Cfg.Zoom) end
        if box and Cfg.Backdrop ~= false then
            local c = Cfg.BackdropColor or { 20, 33, 61, 255 }
            SetScriptGfxDrawOrder(0)
            DrawRect(box.x + box.w * 0.5, box.y + box.h * 0.5, box.w, box.h, c[1], c[2], c[3], c[4])
            SetScriptGfxDrawOrder(4)
        end
        Wait(0)
    end
end

local function restore()
    local R = Cfg.Restore or {}
    for _, t in ipairs(R.textures or {}) do AddReplaceTexture(GFX, t[1], t[2], t[3]) end
    UnlockMinimapPosition()
    UnlockMinimapAngle()
    if R.clip then SetMinimapClipType(R.clip) end
    for name, key in pairs({ minimap = 'minimap', minimap_mask = 'mask', minimap_blur = 'blur' }) do
        local p = R[key]
        if type(p) == 'table' and #p == 6 then SetMinimapComponentPosition(name, p[1], p[2], p[3], p[4], p[5], p[6]) end
    end
    if R.zoomScale then
        SetMapZoomDataLevel(0, R.zoomScale, 0.9, 0.08, 0.0, 0.0)
        SetMapZoomDataLevel(1, R.zoomScaleVehicle or 2.8, 0.9, 0.08, 0.0, 0.0)
    end
    if R.zoom then SetRadarZoom(R.zoom) end
    rebuild()
    if R.zoom then SetRadarZoom(R.zoom) end
    DisplayRadar(not wasHidden)
end

-- True while the radar should show through the box (the core then hides the HUD but not the radar).
function PM.RadarShown() return shown end

local function hide()
    if not shown then return end
    shown = false
    CreateThread(restore)
end

PM.Callback('pm:map:radar', function(data)
    if Cfg.Enabled == false then return { ok = false, error = 'disabled' } end
    if data.on ~= true then
        hide()
        return { ok = true }
    end
    local r = {}
    for _, k in ipairs({ 'x', 'y', 'w', 'h' }) do
        r[k] = tonumber(data[k])
        if not r[k] or r[k] < 0 or r[k] > 1 then return { ok = false, error = 'validation' } end
    end
    if not PM.IsOpen() or busy then return { ok = false, error = 'busy' } end
    busy = true
    local first = not shown
    if first then wasHidden = IsRadarHidden() end
    shown = true
    place(r)
    if first then CreateThread(frame) end
    busy = false
    PM.Debug('radar in box %.3f %.3f %.3f %.3f', r.x, r.y, r.w, r.h)
    return { ok = true }
end)

PM.OnClose(hide)
PM.OnScreen(function(screen) if screen ~= 'pause' then hide() end end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if shown then
        shown = false
        UnlockMinimapAngle()
        UnlockMinimapPosition()
        restore()
    end
end)

-- In-Game Radar Live Editor (/radaredit) -------------------------------------------------------------
-- Allows server admins/developers to live-tune minimap stretch, offsets and zoom in real-time.
local editing = false

local function drawEditorText(str, tx, ty, sc, r, g, b)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(sc, sc)
    SetTextColour(r or 255, g or 255, b or 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry('STRING')
    AddTextComponentSubstringPlayerName(str)
    DrawText(tx, ty)
end

RegisterCommand('radaredit', function()
    if editing then
        editing = false
        return
    end

    if not PM.IsOpen() then
        PM.Open('pause')
        local timeout = GetGameTimer() + 3000
        while not shown and GetGameTimer() < timeout do Wait(50) end
    end

    if not box or not shown then
        print('^1[radaredit] Mini map box is not active. Please open pause menu home screen first.^7')
        return
    end

    editing = true
    SetNuiFocus(false, false)

    CreateThread(function()
        local targetMode = 'MAP' -- 'MAP' or 'MASK'
        local scaleW = (Cfg.MapScale and Cfg.MapScale.w) or 1.55
        local scaleH = (Cfg.MapScale and Cfg.MapScale.h) or 1.55
        local offX = (Cfg.MapOffset and Cfg.MapOffset.x) or 0.0
        local offY = (Cfg.MapOffset and Cfg.MapOffset.y) or 0.0

        local maskScaleW = (Cfg.MaskScale and Cfg.MaskScale.w) or 1.0
        local maskScaleH = (Cfg.MaskScale and Cfg.MaskScale.h) or 1.0
        local maskOffX = (Cfg.MaskOffset and Cfg.MaskOffset.x) or 0.0
        local maskOffY = (Cfg.MaskOffset and Cfg.MaskOffset.y) or 0.0

        local zoom = Cfg.Zoom or 1100
        local zoomScale = Cfg.ZoomScale or 1.4

        local function apply()
            local x, y = getBottomCoords(box)
            local maskW = box.w * maskScaleW
            local maskH = box.h * maskScaleH
            local maskX = x + maskOffX * box.w
            local maskY = y + maskOffY * box.h

            local mapW = box.w * scaleW
            local mapH = box.h * scaleH
            local mapX = x - (mapW - box.w) * 0.5 + offX * box.w
            local mapY = y - (mapH - box.h) * 0.5 + offY * box.h

            SetMinimapClipType(0)
            SetMinimapComponentPosition('minimap_blur', 'L', 'B', -1.0, -1.0, 0.01, 0.01)
            SetMinimapComponentPosition('minimap_mask', 'L', 'B', maskX, maskY, maskW, maskH)
            SetMinimapComponentPosition('minimap', 'L', 'B', mapX, mapY, mapW, mapH)
            SetMapZoomDataLevel(0, zoomScale, 0.9, 0.08, 0.0, 0.0)
            SetMapZoomDataLevel(1, zoomScale, 0.9, 0.08, 0.0, 0.0)
            SetRadarZoom(zoom)
            rebuild()
            SetRadarZoom(zoom)
        end

        apply()
        print('^2[radaredit] Live Radar Editor started! Adjust with Arrow keys / Shift / Ctrl.^7')

        while editing and shown and PM.IsOpen() do
            DisableAllControlActions(0)
            EnableControlAction(0, 245, true) -- T (Chat)

            -- Editor HUD Panel
            DrawRect(0.84, 0.30, 0.30, 0.44, 15, 23, 42, 235)
            DrawRect(0.84, 0.075, 0.30, 0.003, 230, 50, 75, 255)

            drawEditorText('~r~RADAR LIVE EDITOR~s~', 0.70, 0.09, 0.38)
            drawEditorText(string.format('EDIT TARGET: ~y~[ %s ]~s~ (Press TAB to switch)', targetMode), 0.70, 0.13, 0.32)

            if targetMode == 'MAP' then
                drawEditorText(string.format('MapOffset:  X = ~g~%.3f~s~  |  Y = ~g~%.3f~s~', offX, offY), 0.70, 0.17, 0.30)
                drawEditorText('  Arrows: Move Map Canvas', 0.70, 0.20, 0.24, 180, 180, 180)
                drawEditorText(string.format('MapScale:   W = ~g~%.2f~s~   |  H = ~g~%.2f~s~', scaleW, scaleH), 0.70, 0.23, 0.30)
                drawEditorText('  Num 4/6 or [ / ]: Width | Num 8/2: Height', 0.70, 0.26, 0.24, 180, 180, 180)
            else
                drawEditorText(string.format('MaskOffset: X = ~b~%.3f~s~  |  Y = ~b~%.3f~s~', maskOffX, maskOffY), 0.70, 0.17, 0.30)
                drawEditorText('  Arrows: Move Clipping Window', 0.70, 0.20, 0.24, 180, 180, 180)
                drawEditorText(string.format('MaskScale:  W = ~b~%.2f~s~   |  H = ~b~%.2f~s~', maskScaleW, maskScaleH), 0.70, 0.23, 0.30)
                drawEditorText('  Num 4/6 or [ / ]: Width | Num 8/2: Height', 0.70, 0.26, 0.24, 180, 180, 180)
            end

            drawEditorText(string.format('Zoom: ~y~%d~s~   |  ZoomScale: ~y~%.2f~s~', zoom, zoomScale), 0.70, 0.30, 0.30)
            drawEditorText('  PgUp / PgDn: ZoomScale | Num +/-: Zoom', 0.70, 0.33, 0.24, 180, 180, 180)

            drawEditorText('Blur: ~g~Disabled (Off-screen)~s~', 0.70, 0.37, 0.26)
            drawEditorText('~g~[ENTER]~s~: Save & Print Config to F8', 0.70, 0.42, 0.30)
            drawEditorText('~r~[BACKSPACE] / [ESC]~s~: Exit Editor', 0.70, 0.45, 0.30)

            local changed = false
            local step = IsDisabledControlPressed(0, 21) and 0.002 or 0.01

            -- TAB: Toggle between MAP and MASK
            if IsDisabledControlJustPressed(0, 37) then
                targetMode = targetMode == 'MAP' and 'MASK' or 'MAP'
                PlaySoundFrontend(-1, 'NAV_LEFT_RIGHT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                Wait(150)
            end

            -- Adjustments based on targetMode
            if targetMode == 'MAP' then
                if IsDisabledControlPressed(0, 172) then offY = offY + step; changed = true; Wait(80) end -- Up (in LB, up is +Y)
                if IsDisabledControlPressed(0, 173) then offY = offY - step; changed = true; Wait(80) end -- Down
                if IsDisabledControlPressed(0, 174) then offX = offX - step; changed = true; Wait(80) end -- Left
                if IsDisabledControlPressed(0, 175) then offX = offX + step; changed = true; Wait(80) end -- Right

                if IsDisabledControlPressed(0, 108) or IsDisabledControlPressed(0, 39) then scaleW = math.max(0.5, scaleW - 0.02); changed = true; Wait(80) end
                if IsDisabledControlPressed(0, 109) or IsDisabledControlPressed(0, 40) then scaleW = scaleW + 0.02; changed = true; Wait(80) end
                if IsDisabledControlPressed(0, 110) then scaleH = math.max(0.5, scaleH - 0.02); changed = true; Wait(80) end
                if IsDisabledControlPressed(0, 111) then scaleH = scaleH + 0.02; changed = true; Wait(80) end
            else
                if IsDisabledControlPressed(0, 172) then maskOffY = maskOffY + step; changed = true; Wait(80) end
                if IsDisabledControlPressed(0, 173) then maskOffY = maskOffY - step; changed = true; Wait(80) end
                if IsDisabledControlPressed(0, 174) then maskOffX = maskOffX - step; changed = true; Wait(80) end
                if IsDisabledControlPressed(0, 175) then maskOffX = maskOffX + step; changed = true; Wait(80) end

                if IsDisabledControlPressed(0, 108) or IsDisabledControlPressed(0, 39) then maskScaleW = math.max(0.3, maskScaleW - 0.02); changed = true; Wait(80) end
                if IsDisabledControlPressed(0, 109) or IsDisabledControlPressed(0, 40) then maskScaleW = maskScaleW + 0.02; changed = true; Wait(80) end
                if IsDisabledControlPressed(0, 110) then maskScaleH = math.max(0.3, maskScaleH - 0.02); changed = true; Wait(80) end
                if IsDisabledControlPressed(0, 111) then maskScaleH = maskScaleH + 0.02; changed = true; Wait(80) end
            end

            -- ZoomScale (PageUp / PageDown)
            if IsDisabledControlPressed(0, 10) then zoomScale = zoomScale + 0.05; changed = true; Wait(100) end
            if IsDisabledControlPressed(0, 11) then zoomScale = math.max(0.4, zoomScale - 0.05); changed = true; Wait(100) end

            -- Zoom (Numpad + / -)
            if IsDisabledControlPressed(0, 96) then zoom = math.min(1250, zoom + 25); changed = true; Wait(100) end
            if IsDisabledControlPressed(0, 97) then zoom = math.max(800, zoom - 25); changed = true; Wait(100) end

            if changed then
                apply()
            end

            -- ENTER: Print config to F8
            if IsDisabledControlJustPressed(0, 201) or IsDisabledControlJustPressed(0, 18) then
                print('^2--------------------------------------------------^7')
                print('^2[radaredit] PERFECT CONFIG GENERATED:^7')
                print(string.format('^3Config.Map.Radar.MapScale = { w = %.2f, h = %.2f }^7', scaleW, scaleH))
                print(string.format('^3Config.Map.Radar.MapOffset = { x = %.3f, y = %.3f }^7', offX, offY))
                print(string.format('^3Config.Map.Radar.MaskScale = { w = %.2f, h = %.2f }^7', maskScaleW, maskScaleH))
                print(string.format('^3Config.Map.Radar.MaskOffset = { x = %.3f, y = %.3f }^7', maskOffX, maskOffY))
                print(string.format('^3Config.Map.Radar.Zoom = %d^7', zoom))
                print(string.format('^3Config.Map.Radar.ZoomScale = %.2f^7', zoomScale))
                print('^2--------------------------------------------------^7')
                PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
            end

            -- Exit: Backspace / ESC
            if IsDisabledControlJustPressed(0, 177) then
                editing = false
            end

            Wait(0)
        end

        editing = false
        if PM.IsOpen() then
            SetNuiFocus(true, true)
        end
        print('^2[radaredit] Editor exited.^7')
    end)
end, false)
