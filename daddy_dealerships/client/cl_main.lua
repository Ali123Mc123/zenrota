-- Client core: the page (messages, callbacks, focus), the pad buttons CEF cannot read and the menu sounds.
Page = { ready = false }

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

    RegisterNetEvent('daddy_dealerships:notice', function(key, tone, ...)
        Page.notice(key, tone, ...)
    end)
end

-- Menu sounds from the game's own front end.
do
    local NAMES = { move = 'NAV_LEFT_RIGHT', select = 'SELECT', back = 'BACK', error = 'ERROR' }

    function Page.sound(kind)
        PlaySoundFrontend(-1, NAMES[kind] or kind, 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    end

    Page.on('dealer:sound', function(data) Page.sound(data.kind) end)
end

-- The finance plans as the page counts them; the first is the one the row shows under prices.
function Page.finance()
    local f, plans = Config.Finance, {}
    for i, plan in ipairs(f.Plans) do plans[i] = { payments = plan.Payments, interest = plan.Interest } end
    return { payments = plans[1].payments, interest = plans[1].interest, down = f.DownPayment, interval = f.Interval, plans = plans }
end

-- The page boots once: its texts, the accent, the money format and the paints on offer.
Page.on('dealer:boot', function()
    Page.ready = true
    local colours = {}
    for i, c in ipairs(Config.Colours) do colours[i] = { key = c.key, hex = c.hex } end
    return {
        locale = Core.locale(), lang = Core.language(), theme = { accent = Config.Theme.Accent },
        currency = Config.Currency, numberLocale = Config.NumberLocale, colours = colours,
        accounts = Config.Purchase.Accounts, garage = Config.Purchase.Garage == true,
        finance = Config.Finance.Enabled and Page.finance() or false,
        sort = Config.Row.Sort, logos = Config.Logos or false,
    }
end)

-- Focus and the pad: while the page has the input the game's controls rest and pad buttons reach the page as keys.
do
    local PAD = {
        { 188, 'UP' }, { 187, 'DOWN' }, { 189, 'LEFT' }, { 190, 'RIGHT' }, { 201, 'ACCEPT' }, { 202, 'BACK' },
        { 205, 'LB' }, { 206, 'RB' }, { 203, 'X' }, { 204, 'Y' }, { 207, 'LT' }, { 208, 'RT' }, { 217, 'SELECT' },
    }
    local focused, lastPad = false, nil

    local function loop()
        while focused do
            DisableAllControlActions(0)
            DisableAllControlActions(2)
            local pad = not IsUsingKeyboard(2)
            if pad ~= lastPad then
                lastPad = pad
                Page.send('dealer:device', { pad = pad })
            end
            if pad then
                for i = 1, #PAD do
                    if IsDisabledControlJustPressed(2, PAD[i][1]) then Page.send('dealer:pad', { key = PAD[i][2] }) end
                end
            end
            Wait(0)
        end
    end

    -- The page closes on Esc's keydown, so the key is still held when the game gets the input back: its release would
    -- open GTA's pause menu (black, a spinner while it builds), which a pause menu script in 'replace' mode then shuts
    -- half built, leaving the screen black. Esc, P and pad Start stay off until they are up and a moment has passed.
    local PAUSE = { 199, 200, 322 }

    local function paused()
        for pad = 0, 2, 2 do
            for i = 1, #PAUSE do
                if IsDisabledControlPressed(pad, PAUSE[i]) or IsDisabledControlJustReleased(pad, PAUSE[i]) then return true end
            end
        end
        return false
    end

    local function hold()
        local quiet, stop = GetGameTimer() + 500, GetGameTimer() + 5000
        while not focused and GetGameTimer() < stop do
            DisableFrontendThisFrame()
            for pad = 0, 2, 2 do
                for i = 1, #PAUSE do DisableControlAction(pad, PAUSE[i], true) end
            end
            if paused() then quiet = GetGameTimer() + 500 end
            if GetGameTimer() > quiet then break end
            Wait(0)
        end
    end

    function Page.focus(on)
        -- asked again: the focus is set once more, whatever took it meanwhile
        if on == focused then
            if on then SetNuiFocus(true, true) end
            return
        end
        focused = on
        SetNuiFocus(on, on)
        SetNuiFocusKeepInput(false)
        if on then
            lastPad = nil
            CreateThread(loop)
        else
            CreateThread(hold)
        end
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

-- Puts the player at a point (or leaves them where they stand) and holds them there briefly until collision around
-- them is ready. Avoids NewLoadSceneStartSphere which can hang GTA V's streamer across routing bucket transitions.
function Core.land(at, heading)
    local ped = PlayerPedId()
    if IsNewLoadSceneActive() then NewLoadSceneStop() end
    if at then
        FreezeEntityPosition(ped, true)
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoords(ped, at.x, at.y, at.z, false, false, false, false)
        if heading then SetEntityHeading(ped, heading) end
    end
    local p = GetEntityCoords(ped)
    RequestCollisionAtCoord(p.x, p.y, p.z)
    local stop = GetGameTimer() + (at and 1500 or 1500)
    while GetGameTimer() < stop and not HasCollisionLoadedAroundEntity(ped) do
        RequestCollisionAtCoord(p.x, p.y, p.z)
        Wait(0)
    end
    FreezeEntityPosition(ped, false)
end
