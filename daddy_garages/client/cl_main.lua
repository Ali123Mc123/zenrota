-- Client core: the page (messages, callbacks, focus), the pad buttons CEF cannot read, the player's own settings and the
-- menu sounds.
Page = { ready = false, open = false }

-- Messages and callbacks -----------------------------------------------------------------------------------------------
do
    function Page.send(action, data)
        data = data or {}
        data.action = action
        SendNUIMessage(data)
    end

    -- A page callback; fn(data) returns the answer (nil means { ok = true }). Errors answer { ok = false }.
    function Page.on(name, fn)
        RegisterNUICallback(name, function(data, cb)
            local ok, result = pcall(fn, type(data) == 'table' and data or {})
            if not ok then
                Bridge.warn('%s: %s', name, result)
                return cb({ ok = false })
            end
            cb(result == nil and { ok = true } or result)
        end)
    end

    -- A notice in the player's language; key is a locale key (msg.x) or a plain text.
    function Page.notice(key, tone, ...)
        Bridge.notify(Core.t(key, ...), tone)
    end

    RegisterNetEvent('daddy_garages:notice', function(key, tone, ...)
        Page.notice(key, tone, ...)
    end)
end

-- The player's settings (sound, the idle camera, cinematic length), kept in this client. Left alone the camera breathes
-- (a slow sway), walks round the car or stays still (Config.Showroom.Idle).
local IDLE = { calm = true, orbit = true, off = true }
local CINEMA = { full = true, short = true, off = true }
Prefs = { sound = true, camera = IDLE[Config.Showroom.Idle] and Config.Showroom.Idle or 'calm', cinema = 'full' }
do
    local KVP = 'daddy_garages:prefs'
    local saved = Core.decode(GetResourceKvpString(KVP))
    if type(saved.sound) == 'boolean' then Prefs.sound = saved.sound end
    if IDLE[saved.camera] then Prefs.camera = saved.camera end
    if CINEMA[saved.cinema] then Prefs.cinema = saved.cinema end

    Page.on('garage:prefs', function(data)
        if type(data.sound) == 'boolean' then Prefs.sound = data.sound end
        if IDLE[data.camera] then Prefs.camera = data.camera end
        if CINEMA[data.cinema] then Prefs.cinema = data.cinema end
        SetResourceKvp(KVP, json.encode(Prefs))
    end)

    -- How long a cinematic move runs: full, half, or a cut. Not on Prefs: Prefs goes to the page and the KVP as JSON,
    -- which cannot carry a function.
    function Page.ms(full)
        if Prefs.cinema == 'off' then return 0 end
        return Prefs.cinema == 'short' and math.floor(full / 2) or full
    end
end

-- Menu sounds from the game's own front end, off with the setting.
do
    local NAMES = { move = 'NAV_UP_DOWN', select = 'SELECT', back = 'BACK', error = 'ERROR' }

    function Page.sound(kind)
        if not Prefs.sound then return end
        PlaySoundFrontend(-1, NAMES[kind] or kind, 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    end
end

-- The page boots once: it gets its texts, the accent and the settings.
Page.on('garage:boot', function()
    Page.ready = true
    return { locale = Core.locale(), lang = Core.language(), theme = { accent = Config.Theme.Accent }, prefs = Prefs }
end)

-- Focus and the pad -------------------------------------------------------------------------------------------------------
do
    local PAD = {
        { 188, 'UP' }, { 187, 'DOWN' }, { 189, 'LEFT' }, { 190, 'RIGHT' }, { 201, 'ACCEPT' }, { 202, 'BACK' },
        { 205, 'LB' }, { 206, 'RB' }, { 203, 'X' }, { 204, 'Y' }, { 207, 'LT' }, { 208, 'RT' }, { 209, 'LS' },
        { 210, 'RS' }, { 217, 'SELECT' }, { 199, 'START' },
    }
    local focused, lastPad = false, nil

    -- While the page has the input: the game's controls rest, pad buttons go to the page as keys, and the hints switch
    -- between keyboard and pad.
    local function loop()
        while focused do
            DisableAllControlActions(0)
            DisableAllControlActions(2)
            local pad = not IsUsingKeyboard(2)
            if pad ~= lastPad then
                lastPad = pad
                Page.send('garage:device', { pad = pad })
            end
            if pad then
                for i = 1, #PAD do
                    if IsDisabledControlJustPressed(2, PAD[i][1]) then Page.send('garage:pad', { key = PAD[i][2] }) end
                end
            end
            Wait(0)
        end
    end

    function Page.focus(on)
        if on == focused then return end
        focused = on
        SetNuiFocus(on, on)
        SetNuiFocusKeepInput(false)
        if on then
            lastPad = nil
            CreateThread(loop)
        end
    end

    function Page.isPad()
        return not IsUsingKeyboard(2)
    end
end

-- Waits for the page to boot (at most ms); false when it never did.
function Page.await(ms)
    local stop = GetGameTimer() + (ms or 10000)
    while not Page.ready do
        if GetGameTimer() > stop then return false end
        Wait(50)
    end
    return true
end

-- Puts the player at a point (or leaves them where they stand) and holds them there, frozen, until the ground and the
-- streets round it have streamed in, at most 10 s. After the focus or the player was far off, a player let go at once
-- falls through the half-loaded map.
function Core.land(at, heading)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    if at then
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoords(ped, at.x, at.y, at.z, false, false, false, false)
        if heading then SetEntityHeading(ped, heading) end
    end
    local p = GetEntityCoords(ped)
    local scene = NewLoadSceneStartSphere(p.x, p.y, p.z, 80.0, 0)
    local stop = GetGameTimer() + 10000
    repeat
        RequestCollisionAtCoord(p.x, p.y, p.z)
        Wait(0)
    until GetGameTimer() > stop or HasCollisionLoadedAroundEntity(ped) and (not scene or IsNewLoadSceneLoaded())
    if scene then NewLoadSceneStop() end
    FreezeEntityPosition(ped, false)
end
