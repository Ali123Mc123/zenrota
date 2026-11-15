-- NUI focus for the product's pages: acquire() takes keyboard and mouse, release() gives them back.
do
    local focus = {}
    Core.focus = focus

    -- closeUi is kept for callers written against a shared focus owner; nothing else takes focus from us here.
    function focus.acquire(closeUi)
        SetNuiFocus(true, true)
    end

    function focus.release()
        SetNuiFocus(false, false)
    end
end

-- A free camera for placing things: WASD moves, mouse looks, Shift fast, Ctrl slow, E/Q up and down.
do
    local freecam = {}
    Core.freecam = freecam
    local camera, frozenPed, wasFrozen
    local fov = 50.0

    local SETTINGS = { moveSpeed = 0.35, fast = 3.0, slow = 0.25, lookSpeed = 3.0, minFov = 20.0, maxFov = 90.0 }

    local function setting(opts, key)
        return opts and tonumber(opts[key]) or SETTINGS[key]
    end

    function freecam.direction(rotation)
        local z, x = math.rad(rotation.z), math.rad(rotation.x)
        local c = math.abs(math.cos(x))
        return vector3(-math.sin(z) * c, math.cos(z) * c, math.sin(x))
    end

    function freecam.active()
        return camera ~= nil and DoesCamExist(camera)
    end

    function freecam.start(opts)
        if freecam.active() then return false end
        opts = opts or {}
        local coords, rotation = opts.coords or GetGameplayCamCoord(), opts.rotation or GetGameplayCamRot(2)
        camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        pcall(function() exports['FeloxAC']:createCam(camera) end) --[[FeloxAC:auto]]
        if opts.freezePed ~= false then
            frozenPed = PlayerPedId()
            wasFrozen = IsEntityPositionFrozen(frozenPed)
            FreezeEntityPosition(frozenPed, true)
        end
        fov = math.max(setting(opts, 'minFov'), math.min(setting(opts, 'maxFov'), opts.fov or GetGameplayCamFov()))
        SetCamCoord(camera, coords.x, coords.y, coords.z)
        SetCamRot(camera, rotation.x, rotation.y, rotation.z, 2)
        SetCamFov(camera, fov + 0.0)
        SetCamActive(camera, true)
        RenderScriptCams(true, false, 0, true, true)
        return true
    end

    -- Call every frame with the controls disabled; returns the new coords and rotation.
    function freecam.step(opts)
        if not freecam.active() then return nil end
        local coords, rotation = GetCamCoord(camera), GetCamRot(camera, 2)
        local forward = freecam.direction(rotation)
        local right = vector3(forward.y, -forward.x, 0.0)
        local speed = setting(opts, 'moveSpeed')
        if IsDisabledControlPressed(0, 21) then speed = speed * setting(opts, 'fast')
        elseif IsDisabledControlPressed(0, 36) then speed = speed * setting(opts, 'slow') end
        if IsDisabledControlPressed(0, 32) then coords = coords + forward * speed end
        if IsDisabledControlPressed(0, 33) then coords = coords - forward * speed end
        if IsDisabledControlPressed(0, 34) then coords = coords - right * speed end
        if IsDisabledControlPressed(0, 35) then coords = coords + right * speed end
        if IsDisabledControlPressed(0, opts and opts.upControl or 38) then coords = coords + vector3(0.0, 0.0, speed) end
        if IsDisabledControlPressed(0, opts and opts.downControl or 44) then coords = coords - vector3(0.0, 0.0, speed) end
        local look = setting(opts, 'lookSpeed')
        rotation = vector3(math.max(-89.0, math.min(89.0, rotation.x - GetDisabledControlNormal(0, 2) * look)), 0.0, rotation.z - GetDisabledControlNormal(0, 1) * look)
        SetCamCoord(camera, coords.x, coords.y, coords.z)
        SetCamRot(camera, rotation.x, rotation.y, rotation.z, 2)
        SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        return coords, rotation
    end

    function freecam.zoom(delta, opts)
        fov = math.max(setting(opts, 'minFov'), math.min(setting(opts, 'maxFov'), fov + delta))
        if freecam.active() then SetCamFov(camera, fov + 0.0) end
        return fov
    end

    -- Moves the running camera to a fixed pose, as a CCTV viewer does.
    function freecam.place(coords, rotation, newFov, opts)
        if not freecam.active() then return false end
        if newFov then fov = math.max(setting(opts, 'minFov'), math.min(setting(opts, 'maxFov'), newFov)) end
        SetCamCoord(camera, coords.x, coords.y, coords.z)
        SetCamRot(camera, rotation.x, rotation.y, rotation.z, 2)
        SetCamFov(camera, fov + 0.0)
        SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        return true
    end

    function freecam.pose()
        if not freecam.active() then return nil end
        return { coords = GetCamCoord(camera), rotation = GetCamRot(camera, 2), fov = fov }
    end

    function freecam.stop()
        if not camera then return end
        RenderScriptCams(false, false, 0, true, true)
        if DoesCamExist(camera) then pcall(function() exports['FeloxAC']:destroyCam(camera) end) --[[FeloxAC:auto]] DestroyCam(camera, false) end
        camera = nil
        ClearFocus()
        if frozenPed and DoesEntityExist(frozenPed) and not wasFrozen then FreezeEntityPosition(frozenPed, false) end
        frozenPed = nil
    end

    AddEventHandler('onResourceStop', function(resource)
        if resource == GetCurrentResourceName() then freecam.stop() end
    end)
end

-- The client namespace: the page bridge (pausemenu style), server calls, player prefs, client hooks, exports and the
-- cleanup when the resource stops. The other client files add to these globals; only the boot thread starts anything.
do
    local RESOURCE = GetCurrentResourceName()
    local PREFS_KVP = 'daddy_multichar:prefs'
    local MOTION = { full = true, reduced = true, off = true }
    local ARRIVAL = { off = true, walk = true, short = true, full = true }
    -- Lua -> page messages and page -> Lua calls too frequent to print in debug mode.
    local NOISY = {
        ['mc:scene:anchors'] = true, ['mc:cut:skip'] = true, ['mc:core:pad'] = true, ['mc:editor:state'] = true,
        ['mc:editor:place'] = true, ['mc:select:hover'] = true, ['mc:core:log'] = true, ['mc:party:tags'] = true,
    }
    local hooks = { canRelog = {}, onSpawned = {}, onSelection = {} }
    local debugOn = Config.Debug == true

    MC = { state = 'idle', prefs = {}, session = nil, gen = 0 }
    -- What happens after a server reply names a step (client/cl_select.lua).
    Flow = {}

    local function clip(value, max)
        local ok, text = pcall(json.encode, value)
        text = ok and text or tostring(value)
        return #text > max and text:sub(1, max) .. '...' or text
    end

    -- F8 trace while Config.Debug is on.
    function MC.debug(fmt, ...)
        if debugOn then print(('^3[%s:debug]^7 ' .. fmt):format(RESOURCE, ...)) end
    end

    -- Calls fn when it exists; an error is printed and swallowed (cleanup paths must finish).
    function MC.try(fn, ...)
        if type(fn) ~= 'function' then return end
        local ok, err = pcall(fn, ...)
        if not ok then print(('^1[%s] %s^7'):format(RESOURCE, err)) end
    end

    -- A new flow generation: anything still waiting on an older one gives up when it wakes.
    function MC.bump()
        MC.gen = MC.gen + 1
        return MC.gen
    end

    -- Fades to black and waits until it is (at most the fade plus two seconds).
    function MC.fadeOut(ms)
        if IsScreenFadedOut() then return end
        DoScreenFadeOut(ms or 0)
        local stop = GetGameTimer() + (ms or 0) + 2000
        while not IsScreenFadedOut() and GetGameTimer() < stop do Wait(0) end
    end

    -- Lua -> page: { action = 'mc:<module>:<name>', data }.
    function MC.Send(action, data)
        if debugOn and not NOISY[action] then
            local shown = action == 'mc:core:open' and { session = data.session, screen = data.screen, language = data.language } or data
            MC.debug('-> page %s %s', action, clip(shown, 160))
        end
        SendNUIMessage({ action = action, data = data })
    end

    -- A page callback that always answers within timeoutMs (12 s): errors and slow handlers come back as { ok = false }.
    function MC.Callback(name, handler, timeoutMs)
        RegisterNUICallback(name, function(data, cb)
            local done, started = false, GetGameTimer()
            local function finish(result, why)
                if done then return end
                done = true
                result = type(result) == 'table' and result or { ok = false, error = 'invalid' }
                if debugOn and not NOISY[name] then
                    MC.debug('%s %s %dms %s -> %s', result.ok == false and '^1FAIL^7' or 'ok', name, GetGameTimer() - started,
                        clip(data, 120), result.ok == false and (tostring(result.error) .. (why and (' (' .. why .. ')') or '')) or clip(result, 120))
                end
                cb(result)
            end
            SetTimeout(timeoutMs or 12000, function() finish({ ok = false, error = 'not_ready' }, 'no answer in time') end)
            CreateThread(function()
                local ok, result = xpcall(handler, debug.traceback, type(data) == 'table' and data or {})
                if not ok then print(('^1[%s] %s: %s^7'):format(RESOURCE, name, result)) end
                finish(ok and result or { ok = false, error = 'invalid' }, not ok and 'Lua error, see above' or nil)
            end)
        end)
    end

    -- A server callback with its own timeout; always a table, { ok = false, error = 'not_ready' } when no answer came.
    function MC.server(name, timeoutMs, data)
        local p, done = promise.new(), false
        local function finish(reply)
            if done then return end
            done = true
            p:resolve(reply)
        end
        lib.callback('daddy_multichar:' .. name, false, finish, data or {})
        SetTimeout(timeoutMs or 15000, function() finish(nil) end)
        local reply = Citizen.Await(p)
        if type(reply) ~= 'table' then reply = { ok = false, error = reply == nil and 'not_ready' or 'invalid' } end
        MC.debug('server %s -> %s', name, reply.ok and 'ok' or tostring(reply.error))
        return reply
    end

    local function unit(value, default)
        local n = tonumber(value)
        if not n or n ~= n then return default end
        return math.max(0.0, math.min(1.0, n))
    end

    -- The page's own prefs (theme, track, streamer...) kept as plain values: short keys, short strings, at most 24.
    local function extras(raw, out)
        local n = 0
        for key, value in pairs(raw) do
            local kind = type(value)
            local plain = kind == 'boolean' or kind == 'number' or (kind == 'string' and #value <= 64)
            if n < 24 and out[key] == nil and type(key) == 'string' and #key <= 32 and plain then
                out[key], n = value, n + 1
            end
        end
        return out
    end

    -- Player prefs in one known shape; Config.Theme gives the defaults. lowSpec nil follows Config.Selection.LowSpec.
    function MC.normalizePrefs(raw)
        raw = type(raw) == 'table' and raw or {}
        local theme = Config.Theme or {}
        local lowSpec = nil
        if raw.lowSpec ~= nil then lowSpec = raw.lowSpec == true end
        return extras(raw, {
            motion = MOTION[raw.motion] and raw.motion or (MOTION[theme.Motion] and theme.Motion or 'full'),
            music = raw.music ~= false, volume = unit(raw.volume, 0.25), mute = raw.mute == true, sfx = unit(raw.sfx, 0.8),
            grain = raw.grain == true,
            subtitles = raw.subtitles ~= false,
            lowSpec = lowSpec,
            arrival = ARRIVAL[raw.arrival] and raw.arrival or nil,
        })
    end

    -- How long the live spawn's arrival is: the player's pref, else Config.Spawn.ArrivalLength.
    function MC.arrivalLength()
        local pref = MC.prefs and MC.prefs.arrival
        if ARRIVAL[pref] then return pref end
        local cfg = (Config.Spawn or {}).ArrivalLength
        return ARRIVAL[cfg] and cfg or 'off'
    end

    -- Low-spec mode: the player's pref, else the server's Config.Selection.LowSpec.
    function MC.lowSpec()
        local pref = MC.prefs and MC.prefs.lowSpec
        if pref ~= nil then return pref == true end
        return (Config.Selection or {}).LowSpec == true
    end

    -- The camera reads motion before the page exists, so prefs load from KVP at boot.
    function MC.loadPrefs()
        local ok, saved = pcall(json.decode, GetResourceKvpString(PREFS_KVP) or '')
        MC.prefs = MC.normalizePrefs(ok and saved or nil)
        -- Once: the arrival a player saved before 'off' existed (mostly the old default sent along with any other pref)
        -- goes back to the server's default, so the new default reaches everyone; picks made after this stay.
        if GetResourceKvpInt('daddy_multichar:arrival_reset') ~= 1 then
            MC.prefs.arrival = nil
            SetResourceKvp(PREFS_KVP, json.encode(MC.prefs))
            SetResourceKvpInt('daddy_multichar:arrival_reset', 1)
        end
        return MC.prefs
    end

    MC.Callback('mc:core:prefs', function(data)
        local wasLow = MC.lowSpec()
        MC.prefs = MC.normalizePrefs(data.prefs)
        SetResourceKvp(PREFS_KVP, json.encode(MC.prefs))
        if MC.lowSpec() ~= wasLow then CreateThread(Scene.lowSpec) end
        return { ok = true, prefs = MC.prefs }
    end)

    local function callHook(resource, exportName, ...)
        if GetResourceState(resource) ~= 'started' then return false end
        local args = table.pack(...)
        local ok, a, b = pcall(function() return exports[resource][exportName](exports[resource], table.unpack(args, 1, args.n)) end)
        if not ok then print(('^1[%s] client hook %s:%s failed: %s^7'):format(RESOURCE, resource, exportName, a)) end
        return ok, a, b
    end

    -- Every hook must allow; the first refusal and its reason win.
    function MC.allow(name, ...)
        for resource, exportName in pairs(hooks[name] or {}) do
            local ok, allowed, reason = callHook(resource, exportName, ...)
            if ok and allowed == false then return false, reason end
        end
        return true
    end

    function MC.emit(name, ...)
        for resource, exportName in pairs(hooks[name] or {}) do callHook(resource, exportName, ...) end
    end

    -- Hooks are export names of the caller (no function refs across resources): canRelog, onSpawned, onSelection.
    exports('registerClientHook', function(name, exportName)
        local resource = GetInvokingResource()
        if not hooks[name] or type(exportName) ~= 'string' or not resource then return false end
        hooks[name][resource] = exportName
        return true
    end)

    AddEventHandler('onClientResourceStop', function(resource)
        for _, list in pairs(hooks) do list[resource] = nil end
    end)

    exports('IsActive', function()
        local state = State.get()
        return state ~= 'idle' and state ~= 'playing'
    end)

    exports('GetState', function() return State.get() end)

    exports('Relog', function()
        CreateThread(Relog.request)
        return true
    end)

    exports('IsEditing', function()
        return type(Editor) == 'table' and Editor.active() == true
    end)

    -- Spawn.finish fires this once per spawn: the onSpawned hooks, then onboarding for a new character.
    AddEventHandler('daddy_multichar:client:spawned', function(data)
        local isNew = type(data) == 'table' and data.isNew == true
        MC.emit('onSpawned', isNew)
        if isNew then CreateThread(Links.onboarding) end
    end)

    -- Everything client.md lists for a stop; a playing player is left as is, a selecting one stays hidden.
    local function cleanup()
        local appearance = rawget(Bridge, 'appearance')
        MC.try(appearance and appearance.cancel)
        MC.try(Cutscene and Cutscene.abort)
        MC.try(Editor and Editor.close, true)
        MC.try(Admin and Admin.close)
        MC.try(Scene and Scene.destroy)
        MC.try(Crew and Crew.clear)
        MC.try(Track.clearAll)
        MC.try(Live and Live.cancel)
        if IsPlayerSwitchInProgress() then StopPlayerSwitch() end
        MC.try(Rig and Rig.release)
        RenderScriptCams(false, false, 0, true, true)
        ClearFocus()
        NewLoadSceneStop()
        MC.try(Env.restore)
        MC.try(Stream.dropIpls)
        SetNuiFocus(false, false)
        ShutdownLoadingScreenNui()
        DoScreenFadeIn(0)
        MC.try(Links.suppress, false)
    end

    AddEventHandler('onResourceStop', function(resource)
        if resource == RESOURCE then cleanup() end
    end)

    CreateThread(function()
        Wait(0)
        Boot.run()
    end)
end

-- A scene's world: clock, weather and timecycle held while it shows (weather and time sync paused through
-- Bridge.weather), the player's own clock and weather picks blended in, and an empty city for cutscenes.
-- restore() gives everything back.
do
    Env = {}
    local applied, hour, weather, nextClock = false, nil, nil, 0
    local blend = nil -- { from, to, t0, ms } while the clock glides to a new hour
    local SNOWY = { SNOW = true, BLIZZARD = true, SNOWLIGHT = true, XMAS = true }
    local BLEND_S = 0.6 -- seconds a picked weather rolls in (short, so a pick shows at once)
    local snowOn, rolling = false, 0

    -- Snow on the ground with tyre and footstep trails for the snowy types; off for the rest and on restore.
    local function snow(on)
        if on == snowOn then return end
        snowOn = on
        ForceSnowPass(on)
        SetForceVehicleTrails(on)
        SetForcePedFootstepsTracks(on)
    end

    local function write(h)
        local hh, mm, ss = CamMath.clock(h)
        NetworkOverrideClockTime(hh, mm, ss)
    end

    -- The clock is written again once a second (sync scripts write it too, even while paused), every frame while blending.
    local function clock(now)
        if not hour then return end
        if blend then
            local u = (now - blend.t0) / blend.ms
            hour = CamMath.hourLerp(blend.from, blend.to, CamMath.ease('smooth', u))
            if u >= 1 then hour, blend = blend.to, nil end
            return write(hour)
        end
        if now < nextClock then return end
        nextClock = now + 1000
        write(hour)
    end

    local function timecycle(tc)
        if type(tc) ~= 'table' or type(tc.name) ~= 'string' then return ClearTimecycleModifier() end
        SetTimecycleModifier(tc.name)
        SetTimecycleModifierStrength(tonumber(tc.strength) or 1.0)
    end

    -- No traffic, peds or scenarios this frame.
    local function crowd()
        SetVehicleDensityMultiplierThisFrame(0.0)
        SetRandomVehicleDensityMultiplierThisFrame(0.0)
        SetParkedVehicleDensityMultiplierThisFrame(0.0)
        SetPedDensityMultiplierThisFrame(0.0)
        SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
    end

    local function hold(h)
        hour, blend, nextClock = h, nil, 0
        if h then Frame.on('env', clock) else Frame.off('env') end
    end

    -- scene = { time = { h, m }?, weather?, timecycle = { name, strength }? }; a second apply replaces the first.
    function Env.apply(scene)
        scene = type(scene) == 'table' and scene or {}
        applied, weather, rolling = true, scene.weather, rolling + 1
        Bridge.weather.pause(scene.weather)
        snow(SNOWY[scene.weather] == true)
        local t = type(scene.time) == 'table' and scene.time or nil
        hold(t and (tonumber(t.h) or 0) + (tonumber(t.m) or 0) / 60 or nil)
        timecycle(scene.timecycle)
    end

    -- The clock glides to a fractional hour over ms (0 jumps); only while a scene holds the world.
    function Env.clock(h, ms)
        h = tonumber(h)
        if not applied or not h then return false end
        h = h % 24
        ms = tonumber(ms) or 0
        if not hour or ms <= 0 then
            hold(h)
            return true
        end
        blend = { from = hour, to = h, t0 = GetGameTimer(), ms = ms }
        Frame.on('env', clock)
        return true
    end

    -- The weather type (client only); blend rolls it in over BLEND_S first, then the paused sync keeps it.
    function Env.weather(kind, blend)
        if not applied or type(kind) ~= 'string' then return false end
        weather, rolling = kind, rolling + 1
        snow(SNOWY[kind] == true)
        if not blend then return Bridge.weather.set(kind) end
        local mine = rolling
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypeOverTime(kind, BLEND_S)
        SetTimeout(math.floor(BLEND_S * 1000) + 100, function()
            if applied and rolling == mine then Bridge.weather.set(kind) end
        end)
        return true
    end

    -- The hour and weather on screen (the hour falls back to the game clock).
    function Env.now()
        local h = hour or (GetClockHours() + GetClockMinutes() / 60)
        return blend and blend.to or h, weather
    end

    function Env.restore()
        Frame.off('env')
        Frame.off('crowd')
        if not applied then return end
        applied, hour, weather, blend, rolling = false, nil, nil, nil, rolling + 1
        snow(false)
        NetworkClearClockTimeOverride()
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        ClearTimecycleModifier()
        ClearExtraTimecycleModifier()
        Bridge.weather.resume()
    end

    -- off = true empties the city every frame until Env.crowd(false) or Env.restore(); calling it again is free.
    function Env.crowd(off)
        if off then Frame.on('crowd', crowd) else Frame.off('crowd') end
    end

    -- The resource's only per-frame loop. It runs while at least one handler is on, so idle costs nothing.
    Frame = {}
    local handlers, order, running = {}, {}, false

    -- Lists are copied on change, so a handler may switch itself (or others) off mid-frame.
    local function without(list, id)
        local out = {}
        for i = 1, #list do
            if list[i] ~= id then out[#out + 1] = list[i] end
        end
        return out
    end

    -- One pcall per handler; one that errors is dropped and printed.
    local function tick(list, now)
        for i = 1, #list do
            local id = list[i]
            local fn = handlers[id]
            if fn then
                local ok, err = pcall(fn, now)
                if not ok then
                    print(('^1[daddy_multichar] frame handler %s dropped: %s^7'):format(id, err))
                    Frame.off(id)
                end
            end
        end
    end

    local function loop()
        while #order > 0 do
            tick(order, GetGameTimer())
            Wait(0)
        end
        running = false
    end

    -- fn(now) runs every frame under this id until Frame.off(id); the same id replaces the handler in place.
    function Frame.on(id, fn)
        if type(fn) ~= 'function' then return end
        if handlers[id] == nil then
            local list = without(order, id)
            list[#list + 1] = id
            order = list
        end
        handlers[id] = fn
        if not running then
            running = true
            CreateThread(loop)
        end
    end

    function Frame.off(id)
        if handlers[id] == nil then return end
        handlers[id] = nil
        order = without(order, id)
    end

    function Frame.running()
        return running
    end

    -- The selection's frame: no HUD, radar or feed, no game controls and no GTA pause menu.
    function Frame.hud()
        HideHudAndRadarThisFrame()
        ThefeedHideThisFrame()
        DisableAllControlActions(0)
        DisableFrontendThisFrame()
    end

    -- The map's ground under a point: scene props, peds and cars never count, so the editor and the selection agree.
    Ground = {}

    -- The ground near z (from 2 m above to 4 m below), else the game's ground; nil over water and the void.
    function Ground.z(x, y, z)
        x, y, z = x + 0.0, y + 0.0, z + 0.0
        local probe = StartExpensiveSynchronousShapeTestLosProbe(x, y, z + 2.0, x, y, z - 4.0, 1, 0, 7)
        local _, hit, at = GetShapeTestResult(probe)
        if hit == 1 then return at.z end
        local ok, gz = GetGroundZFor_3dCoord(x, y, z + 2.0, false)
        if ok and math.abs(gz - z) < 3.0 then return gz end
        return nil
    end

    -- Stands an object's bottom on a ground height (models whose origin is not at their feet: tables, chairs).
    function Ground.stand(obj, z)
        local mn = GetModelDimensions(GetEntityModel(obj))
        local p = GetEntityCoords(obj)
        SetEntityCoordsNoOffset(obj, p.x, p.y, z - mn.z, false, false, false)
    end

    -- Other resources around the selection: the pause menu and HUDs are held off, onboarding runs after a new arrival.
    Links = {}
    local suppressed, onboarding = false, false

    local function started(resource)
        return type(resource) == 'string' and GetResourceState(resource) == 'started' and resource or nil
    end

    -- The pause menu's Suppress is a counter per resource, so it is told only when our own value changes.
    local function pausemenu(on)
        local res = Core.product.resource('pausemenu')
        if not res then return end
        local ok, err = pcall(function() return exports[res]:Suppress(on) end)
        if not ok then MC.debug('pausemenu Suppress failed: %s', tostring(err)) end
    end

    -- Config.Huds: each resource's export takes visible = true | false, or a show/hide export pair.
    local function huds(visible)
        for _, hud in ipairs(Config.Huds or {}) do
            local res = type(hud) == 'table' and started(hud.resource)
            local fn = res and (type(hud.export) == 'string' and hud.export or (visible and hud.show or hud.hide))
            if type(fn) == 'string' then
                local ok, err = pcall(function()
                    if hud.export then return exports[res][fn](exports[res], visible) end
                    return exports[res][fn](exports[res])
                end)
                if not ok then MC.debug('hud %s:%s failed: %s', res, fn, tostring(err)) end
            end
        end
    end

    -- DaddyRP: the HUDs are hidden only while a character is loaded (the editor, a cutscene, a relog's selection) and
    -- shown again only when we hid them. Before the first load a HUD such as wais-primehud is not up yet: a hide sent
    -- then was kept and the show after the spawn came while it was still loading, so the HUD stayed off.
    local hudsHidden = false
    local SHOW_AGAIN = { 2000, 5000 }

    local function loggedIn()
        local ok, value = pcall(function() return Bridge.fw.isLoggedIn() end)
        return ok and value == true
    end

    -- true while the selection, a cutscene or the spawn owns the screen.
    function Links.suppress(on)
        on = on == true
        if on == suppressed then return end
        suppressed = on
        pausemenu(on)
        if on then
            if loggedIn() then
                hudsHidden = true
                huds(false)
            end
            return
        end
        if not hudsHidden then return end
        hudsHidden = false
        huds(true)
        -- a show right after the load events may still reach a HUD that is busy loading the character
        for _, ms in ipairs(SHOW_AGAIN) do
            SetTimeout(ms, function()
                if not suppressed then huds(true) end
            end)
        end
    end

    -- pcall that hands back the value; an error is printed and reads as nil.
    -- An export may pass on a native's 1 for yes.
    local function yes(v) return v == true or v == 1 end

    local function ask(fn)
        local ok, value = pcall(fn)
        if not ok then print(('^1[daddy_multichar] onboarding: %s^7'):format(value)) end
        return ok and value or nil
    end

    -- Blocks until onboarding is done with a new character (30 min cap); IsRunning also covers a run its own gate began.
    -- With the role picked on the casting form the player is already placed, so onboarding does not move them.
    function Links.onboarding()
        if not Onboard.enabled() or onboarding then return false end
        local res = Core.product.resource('onboarding')
        if not res then return false end
        onboarding = true
        ask(function() return exports[res]:Run({ noSpawn = Onboard.roles() }) end)
        local stop = GetGameTimer() + 30 * 60000
        while GetGameTimer() < stop and yes(ask(function() return exports[res]:IsRunning() end)) do Wait(500) end
        onboarding = false
        return true
    end

    -- A pause menu that restarts forgets our block; it is told again while we still hold it.
    AddEventHandler('onClientResourceStart', function(resource)
        if suppressed and resource == ((Config.PauseMenu or {}).Resource or 'daddy_pausemenu') then pausemenu(true) end
    end)

    -- The page: open and close, screens, input focus, toasts, the ready failsafe and the pad buttons CEF cannot read.
    Nui = {}
    -- everReady: the page has drawn a screen at least once (it works; a later slow frame is no reason to drop it).
    local page = { alive = false, open = false, failed = false, session = 0, ready = 0, input = 'game', revokes = 0, everReady = false }
    local Z_INDEX = 9998
    local PAD = {
        { 188, 'UP' }, { 187, 'DOWN' }, { 189, 'LEFT' }, { 190, 'RIGHT' }, { 201, 'ACCEPT' }, { 202, 'BACK' },
        { 205, 'LB' }, { 206, 'RB' }, { 203, 'X' }, { 204, 'Y' },
    }
    -- States where a broken page means the player must still pick a character (the plain menus take over).
    local PICKING = { idle = true, intro = true, select = true, create = true, relogging = true }
    local KINDS = { info = 'inform', success = 'success', error = 'error' }

    local function waitUntil(check, ms)
        local stop = GetGameTimer() + (ms or 5000)
        while not check() do
            if GetGameTimer() >= stop then return false end
            Wait(50)
        end
        return true
    end

    -- The intro playlist: Config.Intro.Music first when it is set, then Config.Intro.Tracks.
    function Nui.tracks(intro)
        local out = {}
        if type(intro.Music) == 'string' and intro.Music ~= '' then out[1] = intro.Music end
        for _, track in ipairs(type(intro.Tracks) == 'table' and intro.Tracks or {}) do
            if type(track) == 'string' and track ~= '' and track ~= out[1] then out[#out + 1] = track end
        end
        return out
    end

    -- The page's part of Config: theme, the casting sheet's public rules and links; never secrets or blocked words.
    local function uiConfig()
        local id, theme, intro, sel = Config.Identity or {}, Config.Theme or {}, Config.Intro or {}, Config.Selection or {}
        return {
            theme = { accent = theme.Accent, italic = theme.Italic ~= false, actorBox = theme.ActorBox, panel = theme.Panel == 'dark' and 'dark' or 'light', jobs = theme.Jobs },
            themes = theme.Presets or {},
            music = { tracks = Nui.tracks(intro), volume = intro.Volume },
            streamer = sel.StreamerDefault == true, lowSpec = sel.LowSpec == true, arrival = (Config.Spawn or {}).ArrivalLength,
            identity = {
                NameMin = id.NameMin, NameMax = id.NameMax, MinAge = id.MinAge, MaxAge = id.MaxAge, HeightMin = id.HeightMin,
                HeightMax = id.HeightMax, HeightDefault = id.HeightDefault, BioMax = id.BioMax, DateFormat = id.DateFormat,
                Nationalities = id.Nationalities,
            },
            deleteMode = Config.Delete.Mode, deleteConfirm = Config.Delete.Confirm == 'click' and 'click' or 'name', retentionDays = Config.Delete.RetentionDays, storeUrl = Config.Slots.StoreUrl, discordInvite = Config.Discord.Invite,
            party = { enabled = (Config.Party or {}).Enabled == true, max = (Config.Party or {}).Max },
            playerScene = Config.Selection.PlayerScene ~= false, weathers = Config.Selection.Weathers,
            intro = { minMs = Config.Intro.MinMs, skippable = Config.Intro.Skippable ~= false },
            allowQuit = Config.Selection.AllowQuit == true, isAdmin = type(MC.session) == 'table' and MC.session.isAdmin == true,
            debug = Config.Debug == true, dateFormat = id.DateFormat,
        }
    end

    -- Pad buttons reach the page as virtual keys while it has the input and the last device was a pad.
    local function pad()
        if page.input ~= 'ui' or IsUsingKeyboard(2) then return end
        for i = 1, #PAD do
            if IsDisabledControlJustPressed(2, PAD[i][1]) then MC.Send('mc:core:pad', { key = PAD[i][2] }) end
        end
    end

    local function releaseFocus()
        SetNuiFocusKeepInput(false)
        Core.focus.release()
    end

    -- Another resource took the focus: take it back after 500 ms, three times at most per open.
    local function revoked()
        SetNuiFocus(false, false)
        if page.input ~= 'ui' or page.revokes >= 3 then return end
        page.revokes = page.revokes + 1
        SetTimeout(500, function()
            if page.open and page.input == 'ui' then Core.focus.acquire(revoked) end
        end)
    end

    function Nui.awaitAlive(ms)
        return waitUntil(function() return page.alive end, ms)
    end

    -- true once the page reported the current open rendered; false on timeout or a failed page.
    function Nui.awaitReady(ms)
        local session = page.session
        waitUntil(function() return page.ready == session or page.failed end, ms)
        return page.ready == session and not page.failed
    end

    -- No first frame from an open in time. A page that never drew gets the open once more (it may have loaded after
    -- the first one was sent); a page that drew before is only failed where a character must still be picked. Either
    -- way only a second miss counts: a minimized or busy game holds the page's frames back.
    local function missed(session, payload, retried)
        if page.failed or not page.open or page.session ~= session or page.ready == session then return end
        if not retried then
            if not page.everReady then
                if page.screen ~= payload.screen then payload.screen, payload.data = page.screen, {} end
                print(('^3[daddy_multichar] the page has not drawn its first screen yet; opening it again^7'))
                MC.Send('mc:core:open', payload)
                MC.Send('mc:core:intro', Boot.introData())
            end
            return SetTimeout(Config.Boot.ReadyMs or 8000, function() missed(session, payload, true) end)
        end
        if page.everReady and not PICKING[State.get()] then return end
        Nui.fail('the first screen did not render')
    end

    -- Opens the page on a screen, or switches the screen when it is open; nil when the page has failed.
    function Nui.open(screen, data)
        if page.failed then return nil end
        if page.open then
            Nui.screen(screen, data)
            return page.session
        end
        page.open, page.session, page.revokes = true, page.session + 1, 0
        local session, language = page.session, Core.locale.language()
        SetNuiZindex(Z_INDEX)
        local payload = {
            session = session, screen = screen, data = data or {}, language = language, config = uiConfig(), prefs = MC.prefs,
            locale = page.language ~= language and Core.locale.table() or nil,
        }
        MC.Send('mc:core:open', payload)
        MC.Send('mc:core:intro', Boot.introData())
        page.language, page.screen = language, screen
        Frame.on('hud', Frame.hud)
        Frame.on('pad', pad)
        -- A resent open must carry the locale even when this one did not need it.
        payload.locale = Core.locale.table()
        SetTimeout(Config.Boot.ReadyMs or 8000, function() missed(session, payload, false) end)
        return session
    end

    -- How long a first screen may take with the one resend: the boot waits this long before it gives up.
    function Nui.readyBudget()
        return (Config.Boot.ReadyMs or 8000) * 2 + 1000
    end

    -- The screen the page shows, or nil while closed.
    function Nui.current()
        return page.open and page.screen or nil
    end

    function Nui.screen(screen, data)
        if page.failed then return nil end
        if not page.open then return Nui.open(screen, data) end
        page.screen = screen
        MC.Send('mc:core:screen', { screen = screen, data = data or {} })
        return page.session
    end

    -- Closes the page (it unmounts, so nothing animates while closed) and gives input back to the game.
    function Nui.close()
        Frame.off('hud')
        Frame.off('pad')
        page.input = 'game'
        releaseFocus()
        if not page.open then return end
        page.open, page.screen = false, nil
        MC.Send('mc:core:close', {})
    end

    -- ui: the page takes keyboard and mouse; game: the page stays on screen and the game gets the input.
    -- The page stays on screen (a caption fading out) but no longer holds the game's controls.
    function Nui.letGo()
        Frame.off('hud')
        Frame.off('pad')
        releaseFocus()
    end

    function Nui.input(mode)
        if mode ~= 'ui' and mode ~= 'game' then return false end
        page.input = mode
        if mode == 'ui' and page.open then
            Core.focus.acquire(revoked)
            SetNuiFocusKeepInput(false)
        else
            releaseFocus()
        end
        if page.open then MC.Send('mc:core:input', { mode = mode }) end
        return true
    end

    -- The black transition card: kind loading | relog | reel | wardrobe | continuity | spawn | entry; opts are its texts
    -- (eyebrow, title, sub); entry adds its facts (hour, weather, kicker, crew), relog its poster (name, kicker, hour, place).
    function Nui.transition(kind, opts)
        if not Nui.screen('transition', { kind = kind }) then return end
        local data = { kind = kind }
        for key, value in pairs(type(opts) == 'table' and opts or {}) do data[key] = value end
        MC.Send('mc:core:transition', data)
    end

    -- A toast on the page, or an ox_lib notification while the page is closed.
    function Nui.toast(key, kind, args)
        kind, args = KINDS[kind] and kind or 'info', type(args) == 'table' and args or {}
        if page.open and not page.failed then return MC.Send('mc:core:toast', { key = key, kind = kind, args = args }) end
        local ok, text = pcall(Core.locale.t, key, table.unpack(args))
        lib.notify({ description = ok and text or key, type = KINDS[kind] })
    end

    -- The error card ('SCENE INTERRUPTED'); actions the page offers, e.g. { 'quit' }.
    function Nui.error(key, args, actions)
        if not Nui.screen('error', {}) then return false end
        MC.Send('mc:core:error', { key = key, args = args or {}, actions = actions or { 'quit' } })
        return true
    end

    function Nui.isOpen()
        return page.open
    end

    function Nui.failed()
        return page.failed
    end

    -- The page is broken: it closes for good, and where a player must pick a character the plain menus take over.
    function Nui.fail(why)
        if page.failed then return end
        -- Mostly a busy or minimized game holding frames back (the reload below recovers it); web/dist only when it never draws.
        print(('^3[daddy_multichar] the menu page gave no frame in time (%s); a busy or minimized game, or web/dist missing if it never recovers^7'):format(why))
        page.failed, page.open = true, false
        Frame.off('pad')
        SendNUIMessage({ action = 'mc:core:close', data = {} })
        releaseFocus()
        if Config.Safemode == 'reload' then return Nui.reload(why) end
        if Config.Safemode == false then return print('^1[daddy_multichar] Config.Safemode is off: nothing can replace the page^7') end
        if PICKING[State.get()] then return CreateThread(function() Safemode.run(MC.session) end) end
        local points = State.is('spawn_select') and SpawnSelect.points()
        if points then
            SpawnSelect.close()
            CreateThread(function() Safemode.spawn(points) end)
        end
    end

    -- Config.Safemode = 'reload': the plain ox_lib menus never take over. The page is opened again until a screen draws
    -- (a longer pause after each miss); then the flow starts over from where the server says the player stands.
    -- Outside the character pick the page is only made ready for its next open. A page that still talks to Lua is only
    -- slow (a first join), so it keeps what it loaded; one that does not is reloaded. The loading screen goes first,
    -- since on a first join it can be what holds the page back.
    local reloading = false
    local RECOVER = { loading = true, spawn_select = true }

    function Nui.reloading()
        return reloading
    end

    function Nui.reload(why)
        if reloading then return end
        reloading = true
        CreateThread(function()
            local tries = 0
            Boot.closeLoading()
            while true do
                tries = tries + 1
                -- Every third try reloads anyway, in case the page answers but can no longer draw.
                local talking = page.alive and tries % 3 ~= 0
                print(('^3[daddy_multichar] the page did not draw (%s); %s it, try %d^7'):format(tostring(why), talking and 'opening' or 'reloading', tries))
                page.failed, page.open, page.everReady = false, false, false
                if not talking then
                    page.alive = false
                    SendNUIMessage({ action = 'mc:core:reload', data = {} })
                    waitUntil(function() return page.alive end, Config.Boot.NuiMs or 10000)
                end
                Nui.open('transition', {})
                if Nui.awaitReady(Nui.readyBudget()) then break end
                Wait(math.min(tries, 6) * 5000)
            end
            reloading = false
            print('^2[daddy_multichar] the page draws again^7')
            local state = State.get()
            if PICKING[state] or RECOVER[state] then
                Boot.closeLoading()
                return Recover.run(state, 'page reloaded')
            end
            Nui.close()
        end)
    end

    -- The page's first call; { retry = true } comes from the error card's Retry.
    MC.Callback('mc:core:boot', function(data)
        page.alive = true
        if data.retry == true and page.open then CreateThread(Boot.retry) end
        return { ok = true, debug = Config.Debug == true }
    end)

    -- A drawn screen also proves the page alive (its first hello may have been lost).
    MC.Callback('mc:core:ready', function(data)
        page.alive = true
        if tonumber(data.session) == page.session then page.ready, page.everReady = page.session, true end
        return { ok = true }
    end)

    -- Debug mode only: errors the page saw, printed in F8.
    MC.Callback('mc:core:log', function(data)
        if Config.Debug then print(('^1[daddy_multichar:page]^7 %s %s'):format(tostring(data.kind), tostring(data.text):sub(1, 600))) end
        return { ok = true }
    end)

    MC.Callback('mc:core:quit', function()
        if not Config.Selection.AllowQuit or State.is('playing') then return { ok = false, error = 'state' } end
        return MC.server('disconnect', 10000)
    end)

    RegisterNetEvent('daddy_multichar:notify', function(data)
        if type(data) ~= 'table' or type(data.key) ~= 'string' or not data.key:match('^[%w_.]+$') then return end
        Nui.toast(data.key, data.kind, data.args)
    end)

    -- The local player while no character plays: hidden, frozen and safe; placed, revived and reset between characters.
    -- Player(serverId) (state bags) keeps working: the table is callable.
    local native = Player
    Player = setmetatable({}, { __call = function(_, id) return native(id) end })
    local hidden = false

    -- x, y, z, heading of a vector or a { x, y, z, w|h|heading } table (or array).
    local function unpack4(v)
        local kind = type(v)
        if kind == 'vector4' then return v.x, v.y, v.z, v.w end
        if kind == 'vector3' then return v.x, v.y, v.z, 0.0 end
        if kind ~= 'table' then return nil end
        return tonumber(v.x or v[1]), tonumber(v.y or v[2]), tonumber(v.z or v[3]), tonumber(v.w or v.h or v.heading or v[4]) or 0.0
    end

    function Player.coords()
        local ped = PlayerPedId()
        local at = GetEntityCoords(ped)
        return vector4(at.x, at.y, at.z, GetEntityHeading(ped))
    end

    function Player.resurrect(v)
        local x, y, z, h = unpack4(v or Player.coords())
        pcall(function() exports['FeloxAC']:playerRevived() end) --[[FeloxAC:auto]]
        NetworkResurrectLocalPlayer(x, y, z, h, true, false)
        local ped = PlayerPedId()
        pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
        SetEntityHealth(ped, GetEntityMaxHealth(ped))
        ClearPedBloodDamage(ped)
        ClearPlayerWantedLevel(PlayerId())
    end

    -- Frozen, invisible, invincible and without collision (revived first when dead).
    function Player.hide()
        if IsEntityDead(PlayerPedId()) then Player.resurrect() end
        local ped = PlayerPedId()
        FreezeEntityPosition(ped, true)
        pcall(function() exports['FeloxAC']:isVisible(false) end) --[[FeloxAC:auto]]
        SetEntityVisible(ped, false, false)
        SetEntityCollision(ped, false, false)
        pcall(function() exports['FeloxAC']:isInvincible(true) end) --[[FeloxAC:auto]]
        SetEntityInvincible(ped, true)
        pcall(function() exports['FeloxAC']:isInvincible(true) end) --[[FeloxAC:auto]]
        SetPlayerInvincible(PlayerId(), true)
        hidden = true
    end

    function Player.release()
        local ped = PlayerPedId()
        FreezeEntityPosition(ped, false)
        pcall(function() exports['FeloxAC']:isVisible(true) end) --[[FeloxAC:auto]]
        SetEntityVisible(ped, true, false)
        SetEntityCollision(ped, true, true)
        pcall(function() exports['FeloxAC']:isInvincible(false) end) --[[FeloxAC:auto]]
        SetEntityInvincible(ped, false)
        pcall(function() exports['FeloxAC']:isInvincible(false) end) --[[FeloxAC:auto]]
        SetPlayerInvincible(PlayerId(), false)
        hidden = false
    end

    function Player.hidden()
        return hidden
    end

    -- Moves the ped (collision is requested there; the caller waits with Stream.collision when it needs the ground).
    function Player.place(v)
        local x, y, z, h = unpack4(v)
        if not (x and y and z) then return false end
        local ped = PlayerPedId()
        RequestCollisionAtCoord(x, y, z)
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoordsNoOffset(ped, x, y, z, false, false, false)
        SetEntityHeading(ped, h)
        return true
    end

    -- Clears what the last character carried: health, armour, weapons, props, tattoos, damage and tasks.
    function Player.reset()
        if IsEntityDead(PlayerPedId()) then Player.resurrect() end
        local ped = PlayerPedId()
        ClearPedTasksImmediately(ped)
        pcall(function() exports['FeloxAC']:removeAllWeapons() end) --[[FeloxAC:auto]]
        RemoveAllPedWeapons(ped, true)
        pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
        SetPedArmour(ped, 0)
        pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
        SetEntityHealth(ped, GetEntityMaxHealth(ped))
        ClearAllPedProps(ped)
        ClearPedDecorations(ped)
        ClearPedBloodDamage(ped)
        ResetPedVisibleDamage(ped)
        StopEntityFire(ped)
        ClearPlayerWantedLevel(PlayerId())
    end

    -- The client's copy of the server state, with a watchdog per state that hands a stuck flow to Recover.
    State = {}
    local current, token = 'idle', 0
    -- Watchdog limits (ms) before Recover asks the server again; spawning covers Spawn.finish's slowest path.
    local LIMITS = { loading = 45000, spawning = 75000, relogging = 30000, cutscene = 180000 }

    local function watch(name, mine, ms)
        if not ms then return end
        SetTimeout(ms, function()
            if token ~= mine then return end
            CreateThread(function() Recover.run(name, 'watchdog') end)
        end)
    end

    -- limitMs overrides the watchdog for this state (a cutscene that knows its length).
    function State.set(name, limitMs)
        local prev = current
        current, token = name, token + 1
        MC.state = name
        watch(name, token, limitMs or LIMITS[name])
        if prev == name then return end
        MC.debug('state %s -> %s', prev, name)
        TriggerEvent('daddy_multichar:client:state', name, prev)
    end

    function State.get()
        return current
    end

    function State.is(name)
        return current == name
    end

    -- Streaming with timeouts: the world around a view, collisions, interiors, IPLs, models and animation dictionaries.
    -- valid() (optional) lets a caller give up early when its scene is gone.
    Stream = {}
    local added = { ipls = {}, sets = {}, pinned = {} }

    -- A caller still wanting the load: true, or 1 (entity natives answer 1 for yes).
    local function alive(valid)
        if valid == nil then return true end
        local v = valid()
        return v == true or v == 1
    end

    local function waitFor(check, ms, valid)
        local stop = GetGameTimer() + (ms or 5000)
        while not check() do
            if GetGameTimer() >= stop or not alive(valid) then return false end
            Wait(0)
        end
        return true
    end

    -- The map around a camera: focus there, load scene along dir (a sphere without dir), wait, stop. The game runs one
    -- load scene at a time, so a newer call takes it over: an older one (a scene left half built for the next one, or
    -- for the spawn) stops waiting and leaves it running, instead of stopping the newer load when its own wait ends.
    local loadToken = 0
    function Stream.view(pos, dir, far, ms)
        loadToken = loadToken + 1
        local mine = loadToken
        if IsNewLoadSceneActive() then NewLoadSceneStop() end
        SetFocusPosAndVel(pos.x, pos.y, pos.z, 0.0, 0.0, 0.0)
        if dir then
            NewLoadSceneStart(pos.x, pos.y, pos.z, dir.x, dir.y, dir.z, far or 900.0, 0)
        else
            NewLoadSceneStartSphere(pos.x, pos.y, pos.z, far or 150.0, 0)
        end
        ms = ms or 8000
        if MC.lowSpec() then ms = math.floor(ms / 2) end -- low-spec: shorter streaming waits
        local done = waitFor(function() return loadToken ~= mine or IsNewLoadSceneLoaded() end, ms)
        if loadToken ~= mine then return false end
        NewLoadSceneStop()
        return done
    end

    function Stream.at(pos, r, ms)
        RequestCollisionAtCoord(pos.x, pos.y, pos.z)
        return Stream.view(pos, nil, r or 80.0, ms or 6000)
    end

    -- Starts loading the map around a point without waiting (the spawn selector warms the arrival while the player
    -- looks at it); the next Stream.view takes the load scene over, and a load that is done by then returns at once.
    function Stream.prefetch(pos, r)
        loadToken = loadToken + 1
        if IsNewLoadSceneActive() then NewLoadSceneStop() end
        RequestCollisionAtCoord(pos.x, pos.y, pos.z)
        NewLoadSceneStartSphere(pos.x, pos.y, pos.z, r or 150.0, 0)
    end

    -- The collision is asked for every frame where the ped stands now (a single ask can be dropped while the map streams).
    function Stream.collision(ped, ms)
        ped = ped or PlayerPedId()
        return waitFor(function()
            local at = GetEntityCoords(ped)
            RequestCollisionAtCoord(at.x, at.y, at.z)
            return HasCollisionLoadedAroundEntity(ped)
        end, ms or 5000)
    end

    -- A player handed over without the ground under it (a slow PC, a big map) stays frozen where it is, visible, until
    -- the collision is there (ms at most), so it never drops through the map. Runs on its own thread.
    function Stream.holdGround(ms)
        CreateThread(function()
            local ped = PlayerPedId()
            if HasCollisionLoadedAroundEntity(ped) then return end
            FreezeEntityPosition(ped, true)
            local stop = GetGameTimer() + (ms or 15000)
            while GetGameTimer() < stop and DoesEntityExist(ped) and not HasCollisionLoadedAroundEntity(ped) do
                local at = GetEntityCoords(ped)
                RequestCollisionAtCoord(at.x, at.y, at.z)
                Wait(100)
            end
            if DoesEntityExist(ped) then FreezeEntityPosition(ped, false) end
        end)
    end

    -- The interior at a point, pinned and ready; 0 outdoors.
    function Stream.interior(pos, ms)
        local id = GetInteriorAtCoords(pos.x, pos.y, pos.z)
        if id == 0 then return 0 end
        if not added.pinned[id] then
            PinInteriorInMemory(id)
            added.pinned[id] = true
        end
        waitFor(function() return IsInteriorReady(id) end, ms or 5000)
        return id
    end

    -- Switches on an interior's entity sets that were off, remembering them for dropIpls.
    local function entitySets(set)
        local id = Stream.interior(set, 5000)
        if id == 0 then return end
        for _, name in ipairs(set.names or {}) do
            if not IsInteriorEntitySetActive(id, name) then
                ActivateInteriorEntitySet(id, name)
                added.sets[#added.sets + 1] = { id = id, name = name }
            end
        end
        RefreshInterior(id)
    end

    -- Requests IPLs (and entity sets) that are not active yet; only what was added here is undone later.
    function Stream.ipls(list, sets)
        for _, name in ipairs(list or {}) do
            if not IsIplActive(name) then
                RequestIpl(name)
                added.ipls[#added.ipls + 1] = name
            end
        end
        for _, set in ipairs(sets or {}) do entitySets(set) end
    end

    function Stream.dropIpls()
        local refresh = {}
        for _, name in ipairs(added.ipls) do RemoveIpl(name) end
        for _, set in ipairs(added.sets) do
            DeactivateInteriorEntitySet(set.id, set.name)
            refresh[set.id] = true
        end
        for id in pairs(refresh) do RefreshInterior(id) end
        for id in pairs(added.pinned) do UnpinInterior(id) end
        added = { ipls = {}, sets = {}, pinned = {} }
    end

    -- true once the model is loaded (and the caller still wants it); false for unknown models.
    function Stream.model(model, valid, ms)
        local hash = type(model) == 'string' and GetHashKey(model) or model
        if type(hash) ~= 'number' or not IsModelInCdimage(hash) then return false end
        RequestModel(hash)
        return waitFor(function() return HasModelLoaded(hash) end, ms or 5000, valid) and alive(valid)
    end

    function Stream.dict(dict, valid, ms)
        if type(dict) ~= 'string' or not DoesAnimDictExist(dict) then return false end
        RequestAnimDict(dict)
        return waitFor(function() return HasAnimDictLoaded(dict) end, ms or 3000, valid) and alive(valid)
    end

    -- Local entities by group (scene, car, cutscene, editor), so a group goes in one call and nothing is left behind.
    Track = {}
    local groups = {}

    local function delete(entity)
        if not DoesEntityExist(entity) or entity == PlayerPedId() then return end
        SetEntityAsMissionEntity(entity, true, true)
        if IsEntityAPed(entity) then
            DeletePed(entity)
        elseif IsEntityAVehicle(entity) then
            DeleteVehicle(entity)
        else
            DeleteObject(entity)
        end
        if DoesEntityExist(entity) then DeleteEntity(entity) end
    end

    -- Returns the entity, so creation and tracking read as one line.
    function Track.add(group, entity)
        if not entity or entity == 0 then return entity end
        groups[group] = groups[group] or {}
        table.insert(groups[group], entity)
        return entity
    end

    function Track.clear(group)
        local list = groups[group]
        groups[group] = nil
        for _, entity in ipairs(list or {}) do delete(entity) end
    end

    function Track.clearAll()
        for group in pairs(groups) do Track.clear(group) end
    end
end
