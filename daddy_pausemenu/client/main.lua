-- Pause menu core: Esc, P and pad Start open our menu instead of GTA's; the open/close lifecycle modules hook into.
local RESOURCE = GetCurrentResourceName()
local now = GetGameTimer
-- Natives the per-frame loops call, looked up once.
local Wait, IsPauseMenuActive, GetCurrentFrontendMenuVersion = Wait, IsPauseMenuActive, GetCurrentFrontendMenuVersion
local DisableFrontendThisFrame, DisableControlAction, DisableAllControlActions, EnableControlAction =
    DisableFrontendThisFrame, DisableControlAction, DisableAllControlActions, EnableControlAction
local IsDisabledControlJustReleased, IsDisabledControlJustPressed, IsDisabledControlPressed =
    IsDisabledControlJustReleased, IsDisabledControlJustPressed, IsDisabledControlPressed
local DisablePlayerFiring, HideHudAndRadarThisFrame, HideHudComponentThisFrame, DisplayRadar, ThefeedHideThisFrame, IsUsingKeyboard =
    DisablePlayerFiring, HideHudAndRadarThisFrame, HideHudComponentThisFrame, DisplayRadar, ThefeedHideThisFrame, IsUsingKeyboard

-- Module API (see CONTRACT): PM.Open/Close/Show/IsOpen/Screen, hooks, bypass, input mode, NUI messages and callbacks.
PM = { prefs = {}, bypass = false }

local state = { open = false, screen = nil, session = 0, input = 'ui' }
local hooks = { open = {}, close = {}, screen = {}, prefs = {} }
local screens = {}
local bypass, suppressors, ownCams = {}, {}, {}
local suppressUntil, failsafe, replacing = 0, nil, false
local loggedIn, profile = false, nil
-- Until then the login poll asks every 500 ms even with a character in (set by a logout: the framework may lag it).
local fastPollUntil = 0
local PREFS_KVP = RESOURCE .. ':prefs'
-- Stored prefs carry this mark. Prefs stored without it are from before the character camera became opt-in (it was on
-- for everyone then): their camera choice is dropped once.
local PREFS_VERSION = 2
-- The language whose texts the page holds (sent with an open); nil until the first open.
local pageLanguage

-- Screens the server left in Config.Menu (home always); the rest cannot be opened at all, not even from the page.
local allowed = { pause = true }
for _, id in ipairs(PMShared.menu(Config.Menu)) do
    if PMShared.SCREENS[id] then allowed[id] = true end
end

-- GTA's settings screens: only ever open under our bypass (settings driver, hand-off). One left open without it is a
-- leftover of an interrupted driver run and is closed.
local SETTINGS_VERSIONS = {
    [GetHashKey('FE_MENU_VERSION_LANDING_MENU')] = true,
    [GetHashKey('FE_MENU_VERSION_LANDING_KEYMAPPING_MENU')] = true,
}
local leftoverAt, leftoverTries = 0, 0
local frame = 0

-- Closes GTA's frontend even when it ignores SetFrontendActive(false) (left half built by an error): restart it on
-- its own version first, then close, and as a last resort the old pause toggle.
function PM.ForceCloseFrontend()
    local version = GetCurrentFrontendMenuVersion()
    pcall(RestartFrontendMenu, version, -1)
    SetFrontendActive(false)
    pcall(SetPauseMenuActive, false)
end

local PAUSE_VERSIONS = {
    [GetHashKey('FE_MENU_VERSION_MP_PAUSE')] = true,
    [GetHashKey('FE_MENU_VERSION_SP_PAUSE')] = true,
}
-- Pad buttons forwarded to the page (CEF does not read pads).
local PAD = { [188] = 'UP', [187] = 'DOWN', [189] = 'LEFT', [190] = 'RIGHT', [201] = 'ACCEPT', [205] = 'LB', [206] = 'RB' }
-- Over GTA's map (the map screen) the bypass is on and the pad block in openLoop is skipped, but the page still owns
-- these buttons: fullmap.lua disables them for GTA every frame. X folds a group, Y jumps to the next one, the D-pad
-- repeats while held. A table of its own: the other screens keep PAD as it is.
local MAP_PAD = {
    [188] = 'UP', [187] = 'DOWN', [189] = 'LEFT', [190] = 'RIGHT', [201] = 'ACCEPT', [205] = 'LB', [206] = 'RB',
    [203] = 'X', [204] = 'Y',
}
local REPEAT_FIRST, REPEAT_EVERY = 400, 90

-- Debug mode (Config.Debug or F8 'pausemenu_debug'): steps, NUI calls and page errors print in F8.
local debugOn = Config.Debug == true
-- Lua -> page messages too frequent to print.
local NOISY = {
    ['pm:core:hud'] = true, ['pm:map:player'] = true, ['pm:map:blips'] = true, ['pm:map:blipsMove'] = true,
    ['pm:map:route'] = true, ['pm:stats:update'] = true, ['pm:photo:state'] = true,
}

local function clip(value, max)
    local ok, text = pcall(json.encode, value)
    text = ok and text or tostring(value)
    return #text > (max or 200) and text:sub(1, max or 200) .. '...' or text
end

function PM.Debug(fmt, ...)
    if debugOn then print(('^3[%s:debug]^7 ' .. fmt):format(RESOURCE, ...)) end
end

function PM.IsDebug() return debugOn end

local function call(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then print(('^1[%s] %s^7'):format(RESOURCE, err)) end
end

local function run(list, ...)
    for i = 1, #list do call(list[i], ...) end
end

local function suppress(ms)
    suppressUntil = math.max(suppressUntil, now() + (ms or 0))
end

-- 'esc' when Esc was just released, 'p' for P or pad Start, on the player and frontend pads.
local function pauseReleased()
    for pad = 0, 2, 2 do
        if IsDisabledControlJustReleased(pad, 200) or IsDisabledControlJustReleased(pad, 322) then return 'esc' end
        if IsDisabledControlJustReleased(pad, 199) then return 'p' end
    end
end

local function blockPause()
    DisableFrontendThisFrame()
    for pad = 0, 2, 2 do
        DisableControlAction(pad, 199, true)
        DisableControlAction(pad, 200, true)
        DisableControlAction(pad, 322, true)
    end
end

-- The closed menu's lean frame (Config.Esc.LeanBlock): the two pause controls on the player pad and their release, 4
-- natives instead of 13. GTA's own frontend (pause on focus loss, another script) is then looked for every 8th frame.
local LEAN = Config.Esc.LeanBlock ~= false
local function leanReleased()
    if IsDisabledControlJustReleased(0, 200) then return 'esc' end
    if IsDisabledControlJustReleased(0, 199) then return 'p' end
end

-- Leave hooks of the old screen, enter hooks of the new one, then the any-screen hooks.
local function enter(screen, prev)
    for _, h in ipairs(prev and screens[prev] or {}) do
        if h.leave then call(h.leave, screen) end
    end
    for _, h in ipairs(screen and screens[screen] or {}) do
        if h.enter then call(h.enter, prev) end
    end
    run(hooks.screen, screen, prev)
end

-- The page's part of Config, built once (Config does not change at runtime); debug is set on each open.
local UI_CONFIG = {
    menu = PMShared.menu(Config.Menu),
    links = { discord = PMShared.link(Config.Links.Discord), website = PMShared.link(Config.Links.Website) },
    rules = PMShared.rules(Config.Commands or Config.Rules),
    pauseKey = Config.Esc.PauseKey == 'map' and allowed.map and 'map' or 'pause',
}

-- Asks the framework whether a character is in; an error keeps the last answer.
local function refreshLogin()
    local ok, on = pcall(DL.fw.isLoggedIn)
    if ok then loggedIn = on == true end
    return loggedIn
end

-- An admin noclip or freecam the player flies (a statebag in Config.Esc.FreeCamStates): its camera does not block.
local function freeCam()
    for _, key in ipairs(Config.Esc.FreeCamStates or {}) do
        if LocalPlayer.state[key] then return true end
    end
    return false
end

-- txAdmin's noclip tells other resources nothing but its mode event: it sets the same statebag.
RegisterNetEvent('txcl:setPlayerMode', function(mode) LocalPlayer.state:set('noclip', mode == 'noclip', false) end)

-- Why the menu cannot open right now, or nil when it can.
local function blocked(force)
    if state.open then return 'already open' end
    if PM.bypass then return 'bypass (a GTA screen is driven)' end
    if not force and now() < suppressUntil then return 'suppressed after close' end
    -- Asked again here: the poll is slow while a character is in.
    if not refreshLogin() then return 'not logged in' end
    -- Another resource holds focus (phone, inventory) or GTA shows a frontend of its own.
    if IsNuiFocused() then return 'another resource holds NUI focus' end
    if IsPauseMenuActive() then return ('a GTA frontend is open (version %d)'):format(GetCurrentFrontendMenuVersion()) end
    if GetIsLoadingScreenActive() or IsPlayerSwitchInProgress() or IsScreenFadedOut() then return 'loading, switching or faded out' end
    if Config.Esc.BlockOnScriptCam then
        local cam = GetRenderingCam()
        if cam ~= -1 and not ownCams[cam] and not freeCam() then return 'another resource camera is rendering' end
    end
end

local function canOpen(force)
    local why = blocked(force)
    if why then PM.Debug('open refused: %s', why) end
    return why == nil
end

-- The player card comes from the server's framework bridge; the last one shows until the new one lands.
local function fetchProfile(session)
    local result = lib.callback.await('daddy_pausemenu:core:profile', false)
    if type(result) ~= 'table' or not result.ok then return end
    profile = result.data
    if state.open and state.session == session then PM.Send('pm:core:profile', profile) end
end

local function pad(key)
    PM.Send('pm:core:pad', { key = key })
end

local held = {} -- [control] = when a held D-pad direction repeats next
local function mapPad()
    if IsUsingKeyboard(2) then return end -- keys reach the page through CEF
    local t = now()
    for control, key in pairs(MAP_PAD) do
        if IsDisabledControlJustPressed(2, control) then
            pad(key)
            held[control] = t + REPEAT_FIRST
        elseif held[control] and control >= 187 and control <= 190 and IsDisabledControlPressed(2, control) then
            if t >= held[control] then
                pad(key)
                held[control] = t + REPEAT_EVERY
            end
        else
            held[control] = nil
        end
    end
    if IsDisabledControlJustReleased(2, 199) or IsDisabledControlJustReleased(2, 202) then pad('BACK') end
end

local function openLoop(session)
    local pid = PlayerId()
    while state.open and state.session == session do
        DisablePlayerFiring(pid, true)
        -- The home mini map shows GTA's radar through the page: keep the radar, hide the rest of the HUD. Over GTA's own
        -- map (the map screen) GTA hides the HUD itself.
        if PM.Map and PM.Map.FullOn and PM.Map.FullOn() then
            -- nothing to hide
        elseif PM.RadarShown and PM.RadarShown() then
            DisplayRadar(true)
            for i = 1, 22 do HideHudComponentThisFrame(i) end
        else
            HideHudAndRadarThisFrame()
        end
        ThefeedHideThisFrame()
        -- In bypass a module drives a GTA frontend with injected frontend controls: leave every control to it.
        if not PM.bypass then
            -- Every player control is held off (attack, movement, vehicle, weapon wheel, phone...) in one call. The pad
            -- and pause reads here and in the modules use the IsDisabled* natives, which still see the input.
            DisableAllControlActions(0)
            -- Push to talk stays live while the page has the input, as before.
            if state.input == 'ui' then EnableControlAction(0, 249, true) end
            if state.input == 'game' then
                -- The page has no keyboard here: Esc, P and pad Back/Start go to it as BACK.
                if pauseReleased() or IsDisabledControlJustReleased(2, 202) then pad('BACK') end
            elseif not IsUsingKeyboard(2) then
                for control, key in pairs(PAD) do
                    if IsDisabledControlJustPressed(2, control) then pad(key) end
                end
                if IsDisabledControlJustReleased(2, 199) or IsDisabledControlJustReleased(2, 202) then pad('BACK') end
            end
        elseif PM.Map and PM.Map.FullOn and PM.Map.FullOn() then
            -- Over GTA's map the page keeps its pad buttons (GTA's own controls stay live for the map).
            mapPad()
        end
        Wait(0)
    end
    -- The click or trigger that closed the menu must not fire a weapon as input returns to the game.
    local stop = now() + 250
    while now() < stop and not state.open do
        DisablePlayerFiring(pid, true)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        Wait(0)
    end
end

-- Lua -> page: { action = 'pm:<module>:<name>', data = ... }.
function PM.Send(action, data)
    if debugOn and not NOISY[action] then
        -- The open message carries every text of the language: only its head is encoded and printed.
        local shown = action == 'pm:core:open' and { session = data.session, screen = data.screen, language = data.language } or data
        PM.Debug('-> page %s %s', action, clip(shown, 160))
    end
    SendNUIMessage({ action = action, data = data })
end

function PM.IsOpen() return state.open end
function PM.Screen() return state.screen end
function PM.Session() return state.session end

-- Opens on a screen (pause by default). force skips the short lock that follows a close (return from a GTA screen).
function PM.Open(screen, force)
    screen = allowed[screen] and screen or 'pause'
    if state.open then
        PM.Show(screen)
        return true
    end
    if not canOpen(force) then return false end
    state.open, state.screen, state.input = true, screen, 'ui'
    state.session = state.session + 1
    local session = state.session
    SetNuiZindex(Config.Esc.ZIndex or 9999)
    DL.focus.acquire(PM.Close)
    SetNuiFocusKeepInput(false)
    LocalPlayer.state:set('daddyPauseOpen', true, false)
    PM.Debug('open session=%d screen=%s', session, screen)
    UI_CONFIG.debug = debugOn
    -- The texts (about 50 KB) go only when the page does not hold this language yet; it asks for others itself.
    local language = DL.locale.language()
    PM.Send('pm:core:open', {
        session = session, screen = screen, locale = pageLanguage ~= language and DL.locale.table() or nil, language = language,
        config = UI_CONFIG, prefs = PM.prefs, profile = profile,
    })
    pageLanguage = language
    TriggerEvent(RESOURCE .. ':visibility', true)
    run(hooks.open, screen)
    enter(screen, nil)
    CreateThread(function() openLoop(session) end)
    CreateThread(function() fetchProfile(session) end)
    -- A page that never reports it rendered must not keep the player's input.
    failsafe = session
    SetTimeout(Config.Esc.Failsafe or 8000, function()
        if failsafe == session and state.open and state.session == session then PM.Close() end
    end)
    return true
end

function PM.Close()
    if not state.open then return end
    local screen = state.screen
    PM.Debug('close from screen=%s', tostring(screen))
    state.open, state.screen, state.input, failsafe = false, nil, 'ui', nil
    suppress(Config.Esc.SuppressMs or 400)
    PM.Send('pm:core:close')
    DL.focus.release()
    SetNuiFocusKeepInput(false)
    LocalPlayer.state:set('daddyPauseOpen', false, false)
    TriggerEvent(RESOURCE .. ':visibility', false)
    enter(nil, screen)
    run(hooks.close, screen)
end

-- Switches the open menu to another screen and tells the page.
function PM.Show(screen)
    if not state.open or not allowed[screen] or state.screen == screen then return end
    local prev = state.screen
    state.screen = screen
    PM.Send('pm:core:screen', { screen = screen })
    enter(screen, prev)
end

function PM.Toast(text)
    if state.open then PM.Send('pm:core:toast', { text = tostring(text) }) end
end

-- ui: the page has keyboard and mouse. game: the page stays visible, input goes to the game (photo mode).
-- keep: the page has focus and the game still gets input (settings Apply arming).
function PM.SetInput(mode)
    if not state.open or (mode ~= 'ui' and mode ~= 'game' and mode ~= 'keep') then return false end
    state.input = mode
    if mode == 'game' then
        SetNuiFocusKeepInput(false)
        SetNuiFocus(false, false)
    else
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(mode == 'keep')
    end
    return true
end

function PM.Input() return state.input end

-- Bypass: a module has a GTA frontend open on purpose (settings driver, hand-off, map fallback); every blocker stops.
function PM.SetBypass(on, owner)
    bypass[owner or 'core'] = on and true or nil
    PM.bypass = next(bypass) ~= nil
end

-- Cameras our modules create do not count as "another resource's camera" when opening.
function PM.ClaimCam(cam) if cam then ownCams[cam] = true end end
function PM.ReleaseCam(cam) if cam then ownCams[cam] = nil end end

function PM.OnOpen(fn) hooks.open[#hooks.open + 1] = fn end
function PM.OnClose(fn) hooks.close[#hooks.close + 1] = fn end
function PM.OnScreen(fn) hooks.screen[#hooks.screen + 1] = fn end
function PM.OnPrefs(fn) hooks.prefs[#hooks.prefs + 1] = fn end

-- handlers = { enter = function(prev) end, leave = function(next) end }, run as the screen shows and hides
-- (opening the menu enters its first screen, closing leaves the last one). Several modules may watch one screen.
function PM.RegisterScreen(name, handlers)
    screens[name] = screens[name] or {}
    table.insert(screens[name], handlers)
end

-- An NUI callback that always answers: errors and slow handlers come back as { ok = false }.
function PM.Callback(name, handler, timeoutMs)
    RegisterNUICallback(name, function(data, cb)
        local done, started = false, now()
        local function finish(result, why)
            if done then return end
            done = true
            if result == nil then why = why or 'handler returned nothing' end
            result = result or { ok = false, error = 'integration_unavailable' }
            if debugOn and name ~= 'pm:core:log' then
                local failed = type(result) ~= 'table' or result.ok == false
                PM.Debug('%s %s %dms %s -> %s', failed and '^1FAIL^7' or 'ok', name, now() - started, clip(data, 120),
                    failed and (tostring(result.error) .. (why and (' (' .. why .. ')') or '')) or clip(result, 120))
            end
            cb(result)
        end
        SetTimeout(timeoutMs or 12000, function() finish({ ok = false, error = 'timeout' }, 'no answer in time') end)
        CreateThread(function()
            local ok, result = xpcall(handler, debug.traceback, type(data) == 'table' and data or {})
            if not ok then print(('^1[%s] %s: %s^7'):format(RESOURCE, name, result)) end
            finish(ok and result or { ok = false, error = 'integration_unavailable' }, not ok and 'Lua error, see above' or nil)
        end)
    end)
end

-- Opens a GTA frontend (map, settings, key bindings) with every blocker off; ours comes back when it closes.
local frontendBusy = false
function PM.OpenFrontend(menuName, goDeeper, returnScreen)
    -- Never while a module drives a frontend of its own (settings driver): its cleanup would close this one.
    if frontendBusy or PM.bypass or type(menuName) ~= 'string' then return false end
    frontendBusy = true
    PM.Close()
    PM.SetBypass(true, 'frontend')
    CreateThread(function()
        Wait(50)
        AllowPauseMenuWhenDeadThisFrame()
        ActivateFrontendMenu(GetHashKey(menuName), false, -1)
        local deadline = now() + 1500
        while not IsPauseMenuActive() and now() < deadline do
            AllowPauseMenuWhenDeadThisFrame()
            Wait(0)
        end
        if goDeeper and IsPauseMenuActive() then
            Wait(150)
            PauseMenuceptionGoDeeper(0)
        end
        while IsPauseMenuActive() do
            AllowPauseMenuWhenDeadThisFrame()
            -- Esc in a map opened straight from ours closes it instead of showing GTA's tab bar.
            if goDeeper and (IsControlJustPressed(2, 200) or IsControlJustPressed(2, 199)) then SetFrontendActive(false) end
            Wait(0)
        end
        PM.SetBypass(false, 'frontend')
        frontendBusy = false
        suppress(Config.Esc.SuppressMs or 400)
        if returnScreen then
            Wait(150)
            PM.Open(returnScreen, true)
        end
    end)
    return true
end

-- The menu's language: the player's pick (Settings > Display) or the server's. This resource's client texts follow it.
local SERVER_LOCALE = Locales[Config.Locale] and Config.Locale or 'en'

local function languageOf(lang)
    local code = PMShared.LANGS[tonumber(lang) or 0]
    return code and Locales[code] and code or SERVER_LOCALE
end

local function applyLanguage()
    Config.Locale = languageOf((PM.prefs or {}).lang)
end

local function loadPrefs()
    local raw = GetResourceKvpString(PREFS_KVP)
    local ok, saved = pcall(json.decode, raw or '')
    if ok and type(saved) == 'table' and saved.v ~= PREFS_VERSION then saved.charcam = nil end
    -- Once: a colour a player picked before goes back to the server's (Config.Theme.accent), the same as the
    -- character select and the clothing editor; picks made after this stay
    if GetResourceKvpInt('daddy_pausemenu:accent_reset_red') ~= 1 then
        if ok and type(saved) == 'table' then
            saved.accent, saved.accentC = nil, nil
            SetResourceKvp(PREFS_KVP, json.encode(saved))
        end
        SetResourceKvpInt('daddy_pausemenu:accent_reset_red', 1)
    end
    -- Once: the blur behind the sub screens goes back to the server's default (Config.Theme.blur, now off); a player
    -- who turns it on after this keeps it
    if GetResourceKvpInt('daddy_pausemenu:blur_reset_off') ~= 1 then
        if ok and type(saved) == 'table' then
            saved.blur = nil
            SetResourceKvp(PREFS_KVP, json.encode(saved))
        end
        SetResourceKvpInt('daddy_pausemenu:blur_reset_off', 1)
    end
    PM.prefs = PMShared.normalizePrefs(ok and saved or nil, Config.Theme)
    applyLanguage()
end

PM.Callback('pm:core:ready', function(data)
    if tonumber(data.session) == state.session then failsafe = nil end
    return { ok = true }
end)

PM.Callback('pm:core:close', function()
    PM.Close()
    return { ok = true }
end)

PM.Callback('pm:core:screen', function(data)
    local screen = data.screen
    if not state.open or not allowed[screen] then return { ok = false, error = 'validation' } end
    if state.screen ~= screen then
        local prev = state.screen
        state.screen = screen
        enter(screen, prev)
    end
    return { ok = true }
end)

PM.Callback('pm:core:prefs', function(data)
    PM.prefs = PMShared.normalizePrefs(data.prefs, Config.Theme)
    local stored = { v = PREFS_VERSION }
    for k, v in pairs(PM.prefs) do stored[k] = v end
    SetResourceKvp(PREFS_KVP, json.encode(stored))
    applyLanguage()
    run(hooks.prefs, PM.prefs)
    return { ok = true, data = PM.prefs }
end)

-- The texts of a language the player is trying (Settings > Display > Language), before Apply keeps it.
PM.Callback('pm:core:locale', function(data)
    pageLanguage = nil -- the page tries another language; the next open sends the texts again
    if (Config.Theme or {}).langChoice == false then return { ok = false, error = 'validation' } end
    local code = languageOf(data.lang)
    return { ok = true, data = { locale = Locales[code] or DL.locale.table(), language = code } }
end)

PM.Callback('pm:core:profile', function()
    fetchProfile(state.session)
    return { ok = profile ~= nil, data = profile }
end)

PM.Callback('pm:core:leave', function()
    if not state.open then return { ok = false, error = 'validation' } end
    TriggerServerEvent('daddy_pausemenu:core:leave')
    return { ok = true }
end)

-- Debug mode only: failed calls and errors the page saw, printed here so they land in F8 and the client log.
PM.Callback('pm:core:log', function(data)
    if debugOn then print(('^1[%s:page]^7 %s %s'):format(RESOURCE, tostring(data.kind), tostring(data.text):sub(1, 600))) end
    return { ok = true }
end)

-- Which modules loaded: a missing one means a script failed to load (its F8 error is above) or was not listed.
local function moduleReport()
    local found = {
        settings = type(PM.Settings) == 'table' and type(PM.Settings.Env) == 'function',
        driver = type(PM.Driver) == 'table' and type(PM.Driver.Run) == 'function',
        stats = type(PM.Stats) == 'table' and type(PM.Stats.ResetOwn) == 'function',
        map = type(PM.Map) == 'table',
        charcam = type(CharCam) == 'table' and type(CharCam.SetScreen) == 'function',
    }
    local missing, line = {}, {}
    for _, name in ipairs({ 'settings', 'driver', 'stats', 'map', 'charcam' }) do
        line[#line + 1] = name .. '=' .. (found[name] and 'ok' or 'MISSING')
        if not found[name] then missing[#missing + 1] = name end
    end
    return missing, table.concat(line, ' ')
end

CreateThread(function()
    Wait(1000)
    local missing, line = moduleReport()
    -- A missing module always warns: its screen would answer every click with "the game did not answer".
    if #missing > 0 then print(('^1[%s] modules missing: %s^7'):format(RESOURCE, table.concat(missing, ', '))) end
    PM.Debug('modules: %s | build %d | logged in %s', line, GetGameBuildNumber(), tostring(DL.fw.isLoggedIn()))
end)

RegisterCommand('pausemenu_debug', function()
    debugOn = not debugOn
    print(('[%s] debug %s'):format(RESOURCE, debugOn and 'on' or 'off'))
    if debugOn then PM.Debug('modules: %s | open %s screen %s', select(2, moduleReport()), tostring(state.open), tostring(state.screen)) end
    SendNUIMessage({ action = 'pm:core:debug', data = { on = debugOn } })
end, false)

-- Character selection and loading keep GTA's own pause menu; the takeover starts once a character is in. A logout
-- arrives at once through DL.fw.onUnloaded (below), so with a character in the framework is asked only every 5 s, as
-- a safety net; without one every 500 ms, and for 10 s after a logout (a framework that still says "in" for a moment
-- must not keep GTA's pause menu blocked in character selection for 5 s).
CreateThread(function()
    local askAt = 0
    while true do
        local t = now()
        if not loggedIn or t >= askAt or t < fastPollUntil then
            refreshLogin()
            t = now()
            askAt = t + 5000
        end
        Wait((not loggedIn or t < fastPollUntil) and 500 or math.max(500, math.min(5000, askAt - t)))
    end
end)

-- 'replace' mode (Config.Esc.Mode): GTA's pause menu opens on Esc / P and is replaced; see the takeover below.
local REPLACE = Config.Esc.Mode == 'replace'

-- GTA's own frontend showed up: a settings screen a driver run left open is closed (three tries, then forced); a pause
-- menu (pause on focus loss, another script, or Esc / P in 'replace' mode) is closed and ours opens in its place.
local function watchFrontend(active, version)
    if active and SETTINGS_VERSIONS[version] then
        if now() >= leftoverAt then
            leftoverAt = now() + 500
            leftoverTries = leftoverTries + 1
            PM.Debug('closing a GTA settings screen left open without a driver run (try %d)', leftoverTries)
            if leftoverTries >= 3 then PM.ForceCloseFrontend() else SetFrontendActive(false) end
        end
        return true
    end
    if leftoverTries > 0 and not active then leftoverTries = 0 end
    if not (active and PAUSE_VERSIONS[version]) then return false end
    -- P still held when GTA's menu came up: P opens the map when the server wants it.
    local map = Config.Esc.PauseKey == 'map' and (IsControlPressed(0, 199) or IsDisabledControlPressed(0, 199))
    SetFrontendActive(false)
    if (REPLACE or Config.Esc.ReplaceForeignPause) and not state.open and not replacing and not next(suppressors) and now() >= suppressUntil then
        replacing = true
        CreateThread(function()
            -- GTA's frontend takes a few frames to shut; ours opens as soon as it is gone.
            local stop = now() + 600
            while IsPauseMenuActive() and now() < stop do Wait(0) end
            replacing = false
            if not state.open then PM.Open(map and 'map' or 'pause', true) end
        end)
    end
    suppress(250)
    return true
end

-- The takeover. 'block' (Config.Esc.Mode): every frame GTA's pause menu is blocked and ours opens when the key comes
-- back up. 'replace': nothing runs per frame while the menu is closed; GTA's pause menu is looked for 20 times a second
-- and replaced (watchFrontend). While our menu is open both modes block every frame.

CreateThread(function()
    loadPrefs()
    while true do
        if not loggedIn then
            -- Nothing to block before a character is in: no per-frame wake-ups.
            Wait(100)
        elseif REPLACE and not state.open then
            if not PM.bypass then
                local active = IsPauseMenuActive()
                watchFrontend(active, active and GetCurrentFrontendMenuVersion())
            end
            Wait(50)
        else
            if not PM.bypass then
                local look = true
                if LEAN and not state.open then
                    DisableControlAction(0, 199, true)
                    DisableControlAction(0, 200, true)
                    frame = (frame + 1) % 8
                    look = frame == 0
                else
                    blockPause()
                end
                -- Read once per looked-at frame; only watchFrontend changes the frontend.
                local active = look and IsPauseMenuActive()
                if not watchFrontend(active, active and GetCurrentFrontendMenuVersion()) and not state.open then
                    local key = LEAN and leanReleased() or (not LEAN and pauseReleased())
                    if key and now() >= suppressUntil and not next(suppressors) then
                        PM.Open(key == 'p' and Config.Esc.PauseKey == 'map' and 'map' or 'pause')
                    end
                end
            end
            -- Every frame while a character is in, bypass too: blocking starts again the frame a GTA screen closes.
            Wait(0)
        end
    end
end)

-- An extra open key players can bind; it opens on release, like Esc.
RegisterCommand('+pausemenu_open', function() end, false)
RegisterCommand('-pausemenu_open', function()
    if not state.open and not next(suppressors) then PM.Open('pause') end
end, false)
RegisterKeyMapping('+pausemenu_open', DL.locale.t('keys.open'), 'keyboard', Config.Esc.OpenKey or '')

DL.fw.onUnloaded(function()
    loggedIn, profile = false, nil
    fastPollUntil = now() + 10000
    PM.Close()
end)

exports('IsOpen', function() return state.open end)
exports('GetScreen', function() return state.screen end)
exports('Open', function(screen) return PM.Open(screen) end)
exports('Close', function() PM.Close() end)

-- Resources that use Esc as "cancel" outside NUI (placement modes, minigames) hold the menu off while active.
exports('Suppress', function(on)
    local resource = GetInvokingResource() or RESOURCE
    local count = (suppressors[resource] or 0) + (on and 1 or -1)
    suppressors[resource] = count > 0 and count or nil
    return next(suppressors) ~= nil
end)

AddEventHandler('onClientResourceStop', function(resource)
    suppressors[resource] = nil
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE or not state.open then return end
    local screen = state.screen
    state.open = false
    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false)
    LocalPlayer.state:set('daddyPauseOpen', false, false)
    TriggerEvent(RESOURCE .. ':visibility', false)
    enter(nil, screen)
    run(hooks.close, screen)
end)
