-- The map screen over GTA's own map: while it shows, GTA's pause map (straight into the map, no tab bar) runs under the
-- open page, its blip list column is hidden every frame and the page draws its places panel there instead. The page
-- keeps the keyboard (arrows, Enter, Q / E, Esc); the mouse belongs to the page while it is over the strip or the panel
-- (the page reports it, pm:map:hover) and to GTA's map everywhere else, so dragging and the wheel move GTA's map.
-- Two hidden helper blips (focus.lua) let a pick in the list pan GTA's map; the pad reaches the page through
-- client/main.lua (mapPad).
PM.Map = PM.Map or {}

local MENU = GetHashKey('FE_MENU_VERSION_MP_PAUSE')
-- Frontend controls the page owns while the map is up: up, down, left, right, accept, X (Space), Y (Tab), LB / RB
-- (Q / E), back, pause, LS / RS (Left Shift, Left Ctrl: RS toggles GTA's blip visibility on its map).
local KEYS = { 172, 173, 174, 175, 187, 188, 189, 190, 201, 203, 204, 205, 206, 199, 200, 202, 209, 210 }
local SETTLE_MS = 300 -- GTA swaps its page after PauseMenuceptionGoDeeper: method calls wait this long

-- front: GTA's map page is in and settled (method calls on GTA's menu movie reach it).
local on, over, token, front = false, false, 0, false

-- A method on GTA's pause menu movie (no return value).
local function fe(method, ...)
    if not BeginScaleformMovieMethodOnFrontend(method) then return false end
    for i = 1, select('#', ...) do
        local v = select(i, ...)
        if type(v) == 'boolean' then ScaleformMovieMethodAddParamBool(v) else ScaleformMovieMethodAddParamInt(v) end
    end
    EndScaleformMovieMethod()
    return true
end

function PM.Map.FullOn() return on end

-- The focus hooks (focus.lua) never break opening or closing the map.
local function focus(name, ...)
    local ok, err = pcall(PM.Map[name], ...)
    if not ok then print(('^1[%s] map focus %s: %s^7'):format(GetCurrentResourceName(), name, tostring(err))) end
end

-- GTA's map page is in and settled: method calls on GTA's menu movie reach the map page (names.lua, focus.lua).
function PM.Map.FrontReady() return on and front end

local function close()
    if not on then return end
    on, over, front = false, false, false
    token = token + 1
    focus('FocusDrop')
    if IsPauseMenuActive() then SetFrontendActive(false) end
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SetMouseCursorVisible(true)
    PM.SetBypass(false, 'fullmap')
    if PM.IsOpen() then PM.SetInput('ui') end
    PM.Send('pm:map:fullmap', { on = false })
end

local function frame()
    AllowPauseMenuWhenDeadThisFrame()
    fe('SHOW_COLUMN', 0, false)
    for i = 1, #KEYS do
        DisableControlAction(0, KEYS[i], true)
        DisableControlAction(2, KEYS[i], true)
    end
end

local function open()
    if on or PM.bypass or not PM.IsOpen() then return end
    on, over, front = true, false, false
    token = token + 1
    local my = token
    -- Every blocker stands down: GTA's frontend is ours on purpose, and the map needs the game's input.
    PM.SetBypass(true, 'fullmap')
    SetNuiFocus(true, false)
    SetNuiFocusKeepInput(true)
    SetMouseCursorVisible(true)
    PM.Send('pm:map:fullmap', { on = true })
    CreateThread(function()
        if token ~= my then return end
        -- The focus helpers exist before GTA builds its legend, so its first build lists them.
        focus('FocusPrepare')
        AllowPauseMenuWhenDeadThisFrame()
        ActivateFrontendMenu(MENU, false, -1)
        local deadline = GetGameTimer() + 1500
        while not IsPauseMenuActive() and GetGameTimer() < deadline and token == my do
            AllowPauseMenuWhenDeadThisFrame()
            Wait(0)
        end
        if token ~= my then return end
        if not IsPauseMenuActive() then
            -- GTA did not open its map (another frontend, a loading screen): the places panel stays on its own.
            PM.Debug('full map: GTA frontend did not open, places panel only')
            close()
            return
        end
        -- Straight into the map, as GTA's own M key does; GTA's tab bar does not show.
        local enterAt = GetGameTimer() + 150
        while GetGameTimer() < enterAt and token == my do
            frame()
            Wait(0)
        end
        if token == my and IsPauseMenuActive() then
            PauseMenuceptionGoDeeper(0)
            CreateThread(function()
                local settle = GetGameTimer() + SETTLE_MS
                while token == my and on and GetGameTimer() < settle do Wait(0) end
                if token ~= my or not on then return end
                front = true
                focus('FocusReady', function() return token == my and on end)
            end)
        end
        -- Clicking a blip on GTA's map selects that blip in the right-hand places list.
        -- The pointer value is the CENTRE of GTA's map, not the mouse. On a click GTA waits ~580 ms (its double-click
        -- window), then glides the map centre onto the clicked blip over ~0.5 s. So a click arms a pick, and the pick is
        -- sent once that glide has come to rest: the resting centre is the clicked blip. A held press (a drag) is no pick.
        local PICK_TRACE = false -- F8: the centre's glide after each click
        local PICK_WINDOW = 3000 -- ms a click waits for GTA's glide to finish
        local SETTLE_PICK = 90 -- ms without movement = the glide has ended
        local DRAG_MS = 250 -- a press held longer than this is a drag of the map
        local readPtr = GetPauseMapPointerWorldPosition
        local last = readPtr and readPtr() or nil
        local armedAt, downAt, moved, movedAt = nil, nil, false, 0
        while token == my and on and IsPauseMenuActive() do
            frame()
            local now = GetGameTimer()

            if readPtr then
                if not over and (IsControlJustPressed(2, 237) or IsDisabledControlJustPressed(2, 237)
                    or IsControlJustPressed(0, 24) or IsDisabledControlJustPressed(0, 24)) then
                    downAt = now
                    armedAt, moved = now, false
                    if PICK_TRACE then print('^3[PM-PICK] click^7') end
                end
                if downAt and (IsControlJustReleased(2, 237) or IsDisabledControlJustReleased(2, 237)
                    or IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
                    if now - downAt > DRAG_MS then armedAt = nil end -- dragged the map: nothing picked
                    downAt = nil
                end

                local cur = readPtr()
                if cur and (not last or math.abs(cur.x - last.x) > 0.5 or math.abs(cur.y - last.y) > 0.5) then
                    last = cur
                    movedAt = now
                    if armedAt then moved = true end
                    if PICK_TRACE then print(('^2[PM-PICK] centre -> (%.1f, %.1f)^7'):format(cur.x, cur.y)) end
                end

                if armedAt and moved and not downAt and now - movedAt >= SETTLE_PICK then
                    armedAt = nil
                    local busy = PM.Map.FocusBusy and PM.Map.FocusBusy()
                    if not busy and last and (math.abs(last.x) > 0.01 or math.abs(last.y) > 0.01) then
                        if PICK_TRACE then print(('^2[PM-PICK] settled (%.1f, %.1f): pick^7'):format(last.x, last.y)) end
                        PM.Send('pm:map:pickPoint', { x = last.x, y = last.y })
                    end
                end
                if armedAt and now - armedAt > PICK_WINDOW then armedAt = nil end
            end
            Wait(0)
        end
        if token ~= my then return end
        -- GTA closed its map by itself: the page goes home.
        close()
        if PM.IsOpen() and PM.Screen() == 'map' then PM.Show('pause') end
    end)
end

PM.RegisterScreen('map', { enter = open, leave = close })
PM.OnClose(close)

-- The pointer is over the page's strip or panel: the page takes the mouse there (clicks, the list's wheel) and GTA's
-- own pointer hides; elsewhere both get input and GTA's pointer moves the map.
PM.Callback('pm:map:hover', function(data)
    local want = data.over == true
    if on and want ~= over then
        over = want
        SetNuiFocus(true, want)
        SetNuiFocusKeepInput(not want)
        SetMouseCursorVisible(not want)
    end
    return { ok = true }
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and on then
        if IsPauseMenuActive() then SetFrontendActive(false) end
        SetMouseCursorVisible(true)
    end
end)
