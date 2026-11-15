-- The map loaded around an arrival before the picture comes up: wide enough that the street and the buildings the
-- player sees first are there, not only the ground under it. The selector starts it while the player looks at a point.
local ARRIVAL_M = 200.0

-- The spawn selector: an aerial establishing shot over each point (our camera, no map), the screenplay title card,
-- and the NUI list. The client only echoes a server id back; the server decides where the player goes.
do
    SpawnSelect = {}

    local DRIFT_DEG, DRIFT_MS, FOV = 8.0, 10000, 40.0
    local sel, chosen = nil, nil
    -- Menu labels, not place names: their title cards use the zone instead.
    local UNNAMED = { last = true, forced = true, ['cfg:default'] = true }

    local function placeName(point)
        if UNNAMED[point.id] or UNNAMED[point.kind] or point.label == '' then return nil end
        return point.label
    end

    -- Camera over a point: its own cam when the server sent one, else behind and above it (Config.Spawn.Aerial*).
    local function aerial(point, angle)
        local c = point.coords
        if type(point.cam) == 'table' then
            local pose = CamMath.pose(point.cam)
            local lx, ly, lz = CamMath.point(point.cam.look)
            if pose and lx then
                pose.x, pose.y = CamMath.orbit(pose, { x = lx, y = ly }, angle)
                pose.rx, pose.rz = CamMath.lookRot(pose.x, pose.y, pose.z, lx, ly, lz)
            end
            if pose then return pose end
        end
        local cfg = Config.Spawn or {}
        local x, y, z = CamMath.toWorld({ x = c.x, y = c.y, z = c.z, h = c.w + angle }, 0, -(tonumber(cfg.AerialDistance) or 140.0), tonumber(cfg.AerialHeight) or 110.0)
        local pitch, yaw = CamMath.lookRot(x, y, z, c.x, c.y, c.z + 5.0)
        return { x = x, y = y, z = z, rx = pitch, ry = 0, rz = yaw, fov = FOV }
    end

    -- A slow ping-pong orbit while the point stays chosen (full motion only).
    local function drift(point, token, dir, ms)
        if not sel or sel.token ~= token or Director.motion() ~= 'full' then return end
        Director.play({ keys = { aerial(point, DRIFT_DEG * dir) }, ms = ms, ease = 'inOutSine' }, {
            from = 'current',
            onDone = function() drift(point, token, -dir, DRIFT_MS) end,
        })
    end

    -- The camera flies to a point (over a raised arc when it is far) and the title card follows it; ms overrides the time.
    function SpawnSelect.focus(id, ms)
        local point = sel and sel.byId[id]
        if not point then return false end
        sel.focused, sel.token = point.id, sel.token + 1
        local token, c = sel.token, point.coords
        local target, from = aerial(point, 0), Rig.pose()
        local distance = CamMath.dist(from, target)
        local info = Spawn.where(c, placeName(point))
        MC.Send('mc:spawn:focused', { id = point.id, zone = info.zone, street = info.street, time = info.time, slug = info.slug })
        SetFocusPosAndVel(c.x, c.y, c.z, 0.0, 0.0, 0.0)
        -- The arrival loads while the player looks at the point, so the spawn does not hold the camera up for it.
        Stream.prefetch(c.xyz, ARRIVAL_M)
        if distance < 1.0 then
            drift(point, token, 1, DRIFT_MS / 2)
            return true
        end
        local flat = math.sqrt((target.x - from.x) ^ 2 + (target.y - from.y) ^ 2)
        local mid = { x = (from.x + target.x) / 2, y = (from.y + target.y) / 2, z = math.max(from.z, target.z) + CamMath.clamp(distance * 0.25, 60.0, 400.0) }
        Rig.blur(distance > 400.0 and 0.4 or 0.0)
        Director.retarget(target, ms or CamMath.clamp(distance * 2.2, 1400, 4000), {
            mid = flat > 200.0 and mid or nil,
            ease = 'inOutCubic',
            onDone = function()
                Rig.blur(0.0)
                drift(point, token, 1, DRIFT_MS / 2)
            end,
        })
        return true
    end

    -- The first point: the last location when there is one.
    local function initial(list)
        for _, point in ipairs(list) do
            if point.group == 'last' or point.kind == 'last' then return point end
        end
        return list[1]
    end

    -- Opens the selector over black: points from the spawn_select step. false when no point is usable.
    function SpawnSelect.open(points, lock)
        SpawnSelect.close()
        local list, byId, public = {}, {}, {}
        for _, p in ipairs(type(points) == 'table' and points or {}) do
            local coords = type(p) == 'table' and type(p.id) == 'string' and Spawn.coords(p.coords)
            if coords and not byId[p.id] then
                local point = { id = p.id, kind = p.kind, group = p.group or 'other', label = tostring(p.label or ''), coords = coords, cam = p.cam }
                list[#list + 1], byId[p.id] = point, point
                public[#public + 1] = { id = point.id, kind = point.kind, group = point.group, label = point.label, zone = Spawn.where(coords).zone }
            end
        end
        if #list == 0 then return false end
        sel, chosen = { list = list, byId = byId, lock = lock == true, token = 0, busy = false, raw = points, public = public }, nil
        -- The world's own clock and weather from here on: the aerial shots show the real time, so the live spawn does not jump.
        Env.restore()
        State.set('spawn_select')
        Spawn.hud(true)
        MC.Send('mc:spawn:points', { points = public, lock = sel.lock })
        Nui.screen('spawn', { points = public, lock = sel.lock })
        Nui.input('ui')
        local first = initial(list)
        local start = aerial(first, 0)
        local high = { x = start.x, y = start.y, z = start.z + 90.0, rx = start.rx - 12.0, ry = 0, rz = start.rz, fov = start.fov + 6.0 }
        Rig.start(high)
        local fx, fy, fz = CamMath.forward(start.rx, start.rz)
        -- 800 m covers the aerial shot; a deeper load only fills the memory the arrival needs next.
        Stream.view(vector3(start.x, start.y, start.z), vector3(fx, fy, fz), 800.0, 5000)
        SpawnSelect.focus(first.id, 2600)
        if IsScreenFadedOut() or IsScreenFadingOut() then DoScreenFadeIn(800) end
        return true
    end

    function SpawnSelect.active()
        return sel ~= nil
    end

    -- A crew member waits for the leader (lock) or may pick again: the page updates, the camera stays.
    function SpawnSelect.relock(lock)
        if not sel then return false end
        sel.lock, sel.busy = lock == true, false
        MC.Send('mc:spawn:points', { points = sel.public, lock = sel.lock })
        return true
    end

    -- The step's points as the server sent them (Safemode takes over with them when the page fails).
    function SpawnSelect.points()
        return sel and sel.raw or nil
    end

    -- The label of the point the player just confirmed, once, for the arrival title card.
    function SpawnSelect.chosen()
        local label = chosen
        chosen = nil
        return label
    end

    -- Stops the drift; the camera stays for the transition (a crane starts from it).
    function SpawnSelect.close()
        if not sel then return end
        sel = nil
        Director.stop()
        Rig.blur(0.0)
    end

    MC.Callback('mc:spawn:focus', function(data)
        data = type(data) == 'table' and data or {}
        if not sel then return { ok = false, error = 'state' } end
        if type(data.id) ~= 'string' or not sel.byId[data.id] then return { ok = false, error = 'invalid' } end
        SpawnSelect.focus(data.id)
        return { ok = true }
    end)

    -- The server checks the id and answers with the spawning step; the transition runs after the page has its answer.
    MC.Callback('mc:spawn:confirm', function(data)
        data = type(data) == 'table' and data or {}
        local point = sel and type(data.id) == 'string' and sel.byId[data.id]
        if not point then return { ok = false, error = sel and 'invalid' or 'state' } end
        if sel.busy then return { ok = false, error = 'busy' } end
        sel.busy = true
        local reply = MC.server('spawn', 20000, { id = point.id })
        if type(reply) ~= 'table' or not reply.ok then
            if sel then sel.busy = false end
            return { ok = false, error = type(reply) == 'table' and reply.error or 'timeout' }
        end
        chosen = placeName(point)
        CreateThread(function() Spawn.run(reply) end)
        return { ok = true }
    end)

    -- The entry card ('go'): the page wipes red then black and shows the giant clock, the place and the crew; the
    -- player is placed under that black and the page lets go only once the player stands there.
    Entry = {}
    local BLACK_MS, HOLD_MS, OUT_MS = 840, 2340, 620
    local WEATHER_KEY = '^[%u]+$'
    local started = nil

    local function t(key, ...)
        return Core.locale.t(key, ...)
    end

    -- 'Tuesday · Clear': the day the clock card shows and the weather the player looked at.
    local function kicker(weather)
        local day = t('clientv2.day_' .. GetClockDayOfWeek())
        if type(weather) ~= 'string' or not weather:match(WEATHER_KEY) then return day end
        return t('clientv2.kicker', day, t('clientv2.weather_' .. weather))
    end

    -- Starts the card and blocks until the page is black; false when there is no page to show it.
    function Entry.begin(coords, label)
        if Nui.failed() or not Nui.isOpen() then return false end
        local look = Look.last or Look.snapshot()
        local info = Spawn.where(coords, label)
        started = GetGameTimer()
        Nui.transition('entry', {
            eyebrow = info.zone, title = label or (info.zone ~= '' and info.zone) or info.street, sub = info.street,
            hour = look.hour, weather = look.weather, kicker = kicker(look.weather), crew = Crew.names(),
        })
        Wait(BLACK_MS)
        return true
    end

    function Entry.active()
        return started ~= nil
    end

    -- The player stands there: the card holds its time, then the page wipes out over the opening game and closes.
    function Entry.release()
        if not started then return end
        local left = started + HOLD_MS - GetGameTimer()
        if left > 0 then Wait(left) end
        started, Look.last = nil, nil
        MC.Send('mc:core:transition', { kind = 'entry', out = true })
        DoScreenFadeIn(400)
        Wait(OUT_MS)
        if not Select.active() then Nui.close() end
    end

    -- Gets the player to the spawn point: the live glide from the aerial shot to the character (live.lua), GTA's sky
    -- switch (the ascent from the destination hidden by black), a crane down from the aerial shot, a plain fade, or
    -- nothing when the player already stands there.
    Transition = {}

    local SWITCH_OUT_MS, SWITCH_IN_MS, STREAM_MS, COLLISION_MS = 8000, 15000, 10000, 5000
    local landed = nil

    local function t(key, ...)
        return Core.locale.t(key, ...)
    end

    local function waitFor(check, ms)
        local deadline = GetGameTimer() + ms
        while not check() do
            if GetGameTimer() > deadline then return false end
            Wait(0)
        end
        return true
    end

    local function fadeOut(ms)
        if IsScreenFadedOut() then return end
        if not IsScreenFadingOut() then DoScreenFadeOut(ms) end
        waitFor(IsScreenFadedOut, ms + 1000)
    end

    -- The hidden player at the destination with the area and its collision streamed.
    local function place(coords)
        Player.place(coords)
        Stream.at(coords.xyz, ARRIVAL_M, STREAM_MS)
        Stream.collision(PlayerPedId(), COLLISION_MS)
    end

    local function reveal()
        local ped = PlayerPedId()
        pcall(function() exports['FeloxAC']:isVisible(true) end) --[[FeloxAC:auto]]
        SetEntityVisible(ped, true, false)
        SetEntityCollision(ped, true, true)
    end

    -- Fade out, place, stream; the screen stays black for Spawn.finish.
    local function fade(coords)
        fadeOut(500)
        Director.stop()
        Rig.release()
        place(coords)
        return 'fade'
    end

    -- A switch that does not reach its next state in time ends as a fade (the player is already placed).
    local function abort()
        StopPlayerSwitch()
        fadeOut(300)
        return 'fade'
    end

    local function switch(coords)
        fadeOut(500)
        Director.stop()
        Rig.release()
        Env.restore()
        place(coords)
        local ped = PlayerPedId()
        SwitchOutPlayer(ped, 0, 1)
        if not waitFor(function() return GetPlayerSwitchState() >= 5 end, SWITCH_OUT_MS) then return abort() end
        reveal()
        Nui.close()
        DoScreenFadeIn(600)
        SwitchInPlayer(ped)
        if not waitFor(function() return not IsPlayerSwitchInProgress() end, SWITCH_IN_MS) then return abort() end
        return 'switch'
    end

    -- The aerial shot holds over the destination while it streams, then sinks into the gameplay camera.
    local function crane(coords)
        Director.stop()
        place(coords)
        reveal()
        SetGameplayCamRelativeHeading(0.0)
        SetGameplayCamRelativePitch(-8.0, 1.0)
        Nui.close()
        Rig.toGameplay(2500)
        Wait(2600)
        return 'crane'
    end

    -- Already there (a cutscene ended on the spot): only the camera goes back; far away it is a fade.
    local function none(coords)
        if #(GetEntityCoords(PlayerPedId()) - coords.xyz) > 3.0 then return fade(coords) end
        if Rig.active() then Rig.toGameplay(800) end
        return 'none'
    end

    -- The live glide; when a step hangs it ends as a fade (the player is placed by then or placed now).
    local function live(coords, hooks)
        if Live.run(coords, { job = hooks.job, kind = hooks.kind, down = hooks.down, loaded = hooks.loaded }) then return 'live' end
        return fade(coords)
    end

    local RUN = { switch = switch, crane = crane, fade = fade, none = none }

    local ROOF_M = 25.0 -- how high a roof over the point is looked for

    -- A roof over a point: a ray straight up from head height hits the map or a building within ROOF_M.
    local function roofed(c)
        RequestCollisionAtCoord(c.x, c.y, c.z)
        local ray = StartExpensiveSynchronousShapeTestLosProbe(c.x, c.y, c.z + 1.0, c.x, c.y, c.z + ROOF_M, 1 | 16, PlayerPedId(), 7)
        local _, hit = GetShapeTestResult(ray)
        return hit == 1
    end

    -- Indoors: inside an interior's box and under a roof. An MLO's box reaches well past its walls (the street, the
    -- forecourt), so the box alone sent open ground to the fade; a roof check keeps those outdoors.
    function Transition.indoors(coords)
        coords = Spawn.coords(coords)
        if not coords or GetInteriorAtCoords(coords.x, coords.y, coords.z) == 0 then return false end
        return roofed(coords)
    end

    -- True when the live glide can run here: full motion, not low spec, outdoors and no home to enter.
    function Transition.liveOk(coords, hooks)
        coords = Spawn.coords(coords)
        hooks = type(hooks) == 'table' and hooks or {}
        if not coords or Director.motion() ~= 'full' or MC.lowSpec() or hooks.enter ~= nil then return false end
        return not Transition.indoors(coords)
    end

    -- Reduced motion, interiors and home entries take the fade; a crane needs the aerial camera.
    local function choose(coords, kind, hooks)
        if kind == 'none' then return 'none' end
        if kind == 'live' then return Transition.liveOk(coords, hooks) and 'live' or 'fade' end
        if kind ~= 'switch' and kind ~= 'crane' then return 'fade' end
        if Director.motion() ~= 'full' or hooks.enter ~= nil then return 'fade' end
        if Transition.indoors(coords) then return 'fade' end
        if kind == 'crane' and not Rig.active() then return 'fade' end
        return kind
    end

    -- True when the last transition put the player on these coords in the last minute.
    function Transition.landed(coords)
        coords = Spawn.coords(coords)
        if not landed or not coords or GetGameTimer() - landed.at > 60000 then return false end
        return #(landed.pos - coords.xyz) < 2.0
    end

    -- Blocks until the player is at coords (hooks { enter, label, entry, job, kind }); returns what ran, 'fade' leaves the
    -- screen black. hooks.entry: the page's entry card already covers the screen, so no spawn card. 'live' shows only the
    -- small caption over the game.
    function Transition.run(coords, kind, hooks)
        coords = Spawn.coords(coords)
        if not coords then return nil end
        hooks = type(hooks) == 'table' and hooks or {}
        local chosen = choose(coords, kind, hooks)
        Spawn.hud(true)
        if chosen ~= 'none' and not hooks.entry then
            local info = Spawn.where(coords, hooks.label)
            local title = hooks.label or (info.zone ~= '' and info.zone) or info.street
            if chosen == 'live' then
                Nui.input('game')
                Nui.transition('live', { eyebrow = info.zone ~= title and info.zone or '', title = title, sub = ('%s · %s'):format(info.street, info.time) })
            else
                Nui.transition('spawn', { eyebrow = t('spawnui.arriving'), title = title, sub = info.slug })
            end
        end
        local ran = chosen == 'live' and live(coords, hooks) or RUN[chosen](coords)
        landed = { pos = coords.xyz, at = GetGameTimer() }
        return ran
    end

    -- The end of every spawn: the transition, the framework's spawn events (fired here, on the client), the home entry,
    -- the server's ack and the game handed back. Also the framework handoff and the combat-lock title card.
    Spawn = {}

    local EXPORT = '^[%a_][%w_]*$'
    local running, hudOn, continuityAt = false, false, -60000
    local pendingLoad = nil -- { isNew } while the framework's spawn screen still has the player (handoff)
    local playedJob = nil -- the played character's job name: it picks the live arrival

    -- The character about to spawn (Select.play): only its job is kept.
    function Spawn.played(card)
        local job = type(card) == 'table' and type(card.job) == 'table' and card.job or nil
        playedJob = job and (type(job.name) == 'string' and job.name or (type(job.label) == 'string' and job.label:lower())) or nil
    end

    local function t(key, ...)
        return Core.locale.t(key, ...)
    end

    -- True while a spawn runs (the server's repeated spawning push is then ignored).
    function Spawn.busy()
        return running
    end

    -- A vector4 from the server's { x, y, z, w } (or a vector); nil without three numbers.
    function Spawn.coords(c)
        local kind = type(c)
        if kind == 'vector4' then return c end
        if kind == 'vector3' then return vector4(c.x, c.y, c.z, 0.0) end
        if kind ~= 'table' then return nil end
        local x, y, z = tonumber(c.x), tonumber(c.y), tonumber(c.z)
        if not (x and y and z) or x ~= x or y ~= y or z ~= z then return nil end
        return vector4(x + 0.0, y + 0.0, z + 0.0, (tonumber(c.w or c.h) or 0.0) + 0.0)
    end

    local function daypart(hour)
        if hour >= 5 and hour < 8 then return 'dawn' end
        if hour >= 8 and hour < 18 then return 'day' end
        if hour >= 18 and hour < 21 then return 'dusk' end
        return 'night'
    end

    -- Title card facts for a place: zone, street, clock and a screenplay slug line ("EXT. LEGION SQUARE - NIGHT").
    function Spawn.where(coords, label)
        local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
        if zone == 'NULL' then zone = '' end
        local street = GetStreetNameFromHashKey((GetStreetNameAtCoord(coords.x, coords.y, coords.z))) or ''
        local hour, minute = GetClockHours(), GetClockMinutes()
        local side = GetInteriorAtCoords(coords.x, coords.y, coords.z) ~= 0 and t('spawnui.int') or t('spawnui.ext')
        local place = label or (zone ~= '' and zone) or street
        return { zone = zone, street = street, time = ('%02d:%02d'):format(hour, minute),
            slug = t('spawnui.slug', side, place, t('spawnui.' .. daypart(hour))) }
    end

    local function hideHud()
        HideHudAndRadarThisFrame()
        ThefeedHideThisFrame()
    end

    -- Frame 'switch': no HUD while the selector and the transition run.
    function Spawn.hud(on)
        on = on == true
        if on == hudOn then return end
        hudOn = on
        if on then Frame.on('switch', hideHud) else Frame.off('switch') end
    end

    -- The combat-lock title card: the character carries on where it left; held 2.5 s.
    function Spawn.continuity(point)
        local coords = Spawn.coords(type(point) == 'table' and point.coords or point)
        local label = type(point) == 'table' and type(point.label) == 'string' and point.label or nil
        local info = coords and Spawn.where(coords, label)
        Nui.transition('continuity', { eyebrow = t('spawnui.continuity_eyebrow'), title = info and info.slug or t('spawnui.continuity_title'),
            sub = t('spawnui.continuity_sub') })
        continuityAt = GetGameTimer()
        Wait(2500)
    end

    -- The player stands on the spot, visible and free; the cameras and the selector's leftovers go (the entry card stays).
    local function land(coords, keepPage)
        local ped = PlayerPedId()
        if #(GetEntityCoords(ped) - coords.xyz) > 5.0 then
            Player.place(coords)
            Stream.collision(ped, 5000)
        end
        Scene.destroy()
        Director.stop()
        Rig.release()
        Env.restore()
        Player.release()
        Stream.holdGround(15000)
        if not keepPage then Nui.close() end
        Spawn.hud(false)
        -- The selector's or the arrival's load scene ends here: from now on the map streams around the player.
        if IsNewLoadSceneActive() then NewLoadSceneStop() end
        ClearFocus()
    end

    -- A home (Bridge.housing) or another script's client export by name; waits until it moves the player, 10 s at most.
    local function enter(entry)
        if type(entry) ~= 'table' then return end
        local from = GetEntityCoords(PlayerPedId())
        local placed = false
        if type(entry.resource) == 'string' and type(entry.export) == 'string' and entry.export:match(EXPORT) then
            if GetResourceState(entry.resource) ~= 'started' then return end
            placed = pcall(function() return exports[entry.resource][entry.export](exports[entry.resource], entry.id) end)
        else
            local ok, result = pcall(Bridge.housing.enter, entry)
            placed = ok and result == true
        end
        if not placed then return end
        local deadline = GetGameTimer() + 10000
        while GetGameTimer() < deadline and #(GetEntityCoords(PlayerPedId()) - from) < 2.0 do Wait(100) end
    end

    -- The server moves the session to playing; one more try when the first ask gets no answer.
    local function ack(handoff)
        local reply = MC.server('spawned', 15000, { handoff = handoff })
        if reply.error == 'not_ready' then reply = MC.server('spawned', 15000, { handoff = handoff }) end
        return reply.ok == true
    end

    -- Playing: the pause menu and HUDs come back; the event runs the onSpawned hooks and a new character's onboarding.
    local function playing(isNew, deferred)
        Links.suppress(false)
        State.set('playing')
        if deferred then pendingLoad = { isNew = isNew } return end
        TriggerEvent('daddy_multichar:client:spawned', { isNew = isNew })
    end

    -- Handoff: the hooks and onboarding wait until the framework's own spawn screen has loaded the player.
    local function frameworkLoaded()
        local p = pendingLoad
        pendingLoad = nil
        if p and State.is('playing') then TriggerEvent('daddy_multichar:client:spawned', { isNew = p.isNew }) end
    end

    if (Config.Spawn or {}).Mode == 'framework' then pcall(Bridge.fw.onLoaded, frameworkLoaded) end

    AddEventHandler('daddy_multichar:client:state', function(name)
        if name ~= 'playing' then pendingLoad = nil end
    end)

    -- A spawning step from the server: transition, framework events, home entry, ack. Blocks; true when acked.
    local function finish(step)
        local coords = Spawn.coords(type(step) == 'table' and step.coords)
        if running or not coords then return false end
        running = true
        local gen, isNew = MC.gen, step.isNew == true
        SpawnSelect.close()
        State.set('spawning')
        if step.kind == 'forced' and GetGameTimer() - continuityAt > 10000 then Spawn.continuity({ coords = coords }) end
        local label = SpawnSelect.chosen()
        local kind = step.transition or (Config.Spawn or {}).Transition or 'fade'
        if Config.Debug then
            print(('^3[daddy_multichar] spawn transition=%s motion=%s lowSpec=%s enter=%s interior=%s landed=%s liveOk=%s coords=%s^7'):format(
                tostring(kind), tostring(Director.motion()), tostring(MC.lowSpec()), tostring(step.enter ~= nil),
                tostring(GetInteriorAtCoords(coords.x, coords.y, coords.z)), tostring(Transition.landed(coords)),
                tostring(Transition.liveOk(coords, { enter = step.enter })), tostring(coords)))
        end
        -- Live needs full motion and an outdoor point; else the entry card and a fade, as before.
        if kind == 'live' and not Transition.liveOk(coords, { enter = step.enter }) then kind = 'fade' end
        local entry, ran, loaded = false, nil, false
        -- Live runs the framework's load events itself, before the arrival starts (they may dress the ped again).
        local function load()
            loaded = true
            pcall(Bridge.chars.spawned, coords, isNew)
        end
        if not Transition.landed(coords) then
            entry = kind ~= 'none' and kind ~= 'live' and Entry.begin(coords, label)
            ran = Transition.run(coords, entry and 'fade' or kind, { enter = step.enter, label = label, entry = entry, job = playedJob, kind = step.kind, down = step.down == true, loaded = load })
        end
        if gen ~= MC.gen then
            Live.cancel()
            running = false
            return false
        end
        -- Live: the caption fades out over the game; the page closes after it.
        if ran == 'live' then MC.Send('mc:core:transition', { kind = 'live', out = true }) end
        land(coords, entry or ran == 'live')
        if ran == 'live' then
            SetTimeout(700, function()
                if not Select.active() then Nui.close() end
            end)
        end
        if not loaded then pcall(Bridge.chars.spawned, coords, isNew) end
        enter(step.enter)
        if gen ~= MC.gen then running = false return false end
        if entry then Entry.release() end
        if IsScreenFadedOut() or IsScreenFadingOut() then DoScreenFadeIn(800) end
        local acked = ack(false)
        running = false
        if gen ~= MC.gen then return false end
        playing(isNew)
        return acked
    end

    function Spawn.finish(step)
        local ok, result = xpcall(finish, debug.traceback, step)
        if ok then return result end
        print(('^1[daddy_multichar] spawn: %s^7'):format(tostring(result)))
        Spawn.reset()
        return false
    end

    -- Recovery and errors: no spawn in progress, no arrival running, the screen back (dark: left black for recovery).
    function Spawn.reset(dark)
        running = false
        MC.try(Live.cancel)
        if not dark and (IsScreenFadedOut() or IsScreenFadingOut()) then DoScreenFadeIn(500) end
    end

    -- Spawn.Mode 'framework': all closes and its spawn screen takes over with our own character id; else Spawn.Default.
    function Spawn.handoff(isNew, apartment)
        if running then return false end
        isNew = isNew == true
        SpawnSelect.close()
        Scene.destroy()
        Director.stop()
        Rig.release()
        Env.restore()
        Nui.close()
        Spawn.hud(false)
        ClearFocus()
        Player.release()
        local cidOk, cid = pcall(Bridge.fw.citizenId)
        local ok, took
        if apartment then
            -- The apartment script's own starting pick, the event qb and qbx multichars send a new character to.
            ok, took = pcall(TriggerEvent, 'apartments:client:setupSpawnUI', { citizenid = cidOk and cid or nil, new = true })
            took = ok
        else
            ok, took = pcall(Bridge.chars.handoff, cidOk and cid or nil, isNew)
        end
        if not (ok and took) then
            return Spawn.finish({ step = 'spawning', coords = (Config.Spawn or {}).Default, transition = 'fade', isNew = isNew, kind = 'first' })
        end
        if IsScreenFadedOut() or IsScreenFadingOut() then DoScreenFadeIn(500) end
        local gen = MC.gen
        local acked = ack(true)
        if gen ~= MC.gen then return false end
        playing(isNew, true)
        return acked
    end

    -- Routes a step from a reply or the 'step' push: spawning, handoff or spawn_select. Blocks for spawning.
    function Spawn.run(step)
        if type(step) ~= 'table' then return false end
        if step.step == 'spawning' then return Spawn.finish(step) end
        if step.step == 'handoff' then return Spawn.handoff(step.isNew, step.apartment == true) end
        if step.step == 'spawn_select' then return SpawnSelect.open(step.points, step.lock) end
        return false
    end
end

-- The live spawn ('live'): no black and no card. The aerial shot holds over the point while it streams, the character
-- is placed there in view, the framework loads it (its clothes too), and it starts doing something (Config.Spawn.Arrivals).
-- The camera comes down on one unbroken path, always looking at the character: it slows on a shot framed for what the
-- character does, then settles into the gameplay camera's own pose just as the arrival ends, so the handover cannot
-- be seen. Any step that hangs ends in false (the caller fades).
do
    Live = {}

    -- The aerial shot holds at most STREAM_MS for the area (ARRIVAL_M around the point): the selector has loaded most
    -- of it already, and what is left keeps loading while the camera comes down (the focus stays on the point).
    local STREAM_MS, COLLISION_MS, LOADED_MS, DEADLINE_MS = 3000, 8000, 900, 25000
    local DOWN_MS, HANDOVER_MS = 4500, 200
    -- The arrival length (the player's pref, else Config.Spawn.ArrivalLength): the cinematic's shortest and longest ms.
    -- walk only walks in; short and walk drop an entry's next part.
    -- off: the character only stands at the point (no walk, no animation) while the camera comes down.
    local LENGTHS = { off = { 2500, 2500 }, walk = { 3500, 6500 }, short = { 3500, 5000 }, full = { 5000, 12000 } }
    local FRAMED_AT = 0.42 -- timeline share where the camera is on the framed shot
    local WALK_SPEED = 1.25 -- metres a second at walking pace
    local KEEP_MS, KEEP_TRIES = 300, 12
    local CHECK_MS, CHOICES = 450, 4 -- an arrival must be playing this soon, or the next choice is tried
    local LAST_KVP = 'live_arrival'
    local GO_STRAIGHT = 0x7D8F4411 -- TASK_GO_STRAIGHT_TO_COORD
    local TAXI_NEAR, TAXI_RUN, TAXI_MAX_MS, HOLD_MS = 9.0, 35.0, 18000, 6000 -- a cab: the road this close, its run-up

    -- Framed shots: camera and look point in the ped's frame (x right, y forward, z up from its root, about the pelvis).
    -- All of them sit beside or behind the character, so the way down to the gameplay camera never turns back on itself.
    local SHOTS = {
        shoulder = { cam = { 0.55, -1.25, 0.6 }, look = { 0.1, 0.7, 0.35 }, fov = 40.0 }, -- a phone, a map, a clipboard
        side = { cam = { 1.7, 0.35, 0.5 }, look = { 0.0, 0.15, 0.55 }, fov = 38.0 },      -- a profile: smoking, coffee
        follow = { cam = { -0.8, -2.8, 0.85 }, look = { 0.0, 1.6, 0.45 }, fov = 45.0 },   -- walking into the shot
        wide = { cam = { 2.3, -2.1, 1.0 }, look = { 0.0, 0.0, 0.6 }, fov = 44.0 },
        down = { cam = { 1.5, -0.9, 0.3 }, look = { 0.0, 0.2, -0.6 }, fov = 42.0 },       -- lying on the ground
    }

    local current -- { ped, arrival, target, prop, ended } while an arrival plays

    local function disableControls()
        DisableAllControlActions(0)
        HideHudAndRadarThisFrame()
    end

    local function with(base, extra)
        local out = {}
        for k, v in pairs(base) do out[k] = v end
        for k, v in pairs(extra) do out[k] = v end
        return out
    end

    -- A list item: a name in the library (shared/arrivals) or an entry of its own.
    local function resolve(item)
        if type(item) == 'string' then
            local found = Arrivals[item]
            return type(found) == 'table' and found or nil, item
        end
        return type(item) == 'table' and item or nil, nil
    end

    local function raining()
        return IsPrevWeatherType('RAIN') or IsPrevWeatherType('THUNDER') or IsPrevWeatherType('CLEARING')
    end

    local function fits(e, ctx)
        if e.sex and (e.sex == 'male') ~= ctx.male then return false end
        if e.time and (e.time == 'night') ~= ctx.night then return false end
        if e.weather and (e.weather == 'rain') ~= ctx.rain then return false end
        local after = resolve(e.next)
        return not after or fits(after, ctx)
    end

    -- Up to CHOICES arrivals in the order to try: the job's, the spawn kind's and the default list mixed by their weights,
    -- the ones the moment rules out left out, the last one played kept back when there is another.
    function Live.pick(job, kind, ped, length)
        local cfg = (Config.Spawn or {}).Arrivals or {}
        local weights = cfg.Weights or {}
        local hour = GetClockHours()
        local ctx = { male = IsPedMale(ped), night = hour >= 20 or hour < 6, rain = raining() }
        local pool, seen = {}, {}
        local function add(list, weight)
            if type(list) ~= 'table' then return end
            for _, item in ipairs(list) do
                local e, name = resolve(item)
                local key = name or tostring(e)
                if e and not seen[key] and fits(e, ctx) and (length ~= 'walk' or tonumber(e.walk)) and (not e.taxi or length == 'full') then
                    seen[key] = true
                    pool[#pool + 1] = { e = e, key = key, w = (tonumber(e.weight) or 1) * weight }
                end
            end
        end
        add((cfg.jobs or {})[job or ''], tonumber(weights.job) or 3)
        add((cfg.kinds or {})[kind or ''], tonumber(weights.kind) or 2)
        add(cfg.default, tonumber(weights.default) or 1)
        local last = GetResourceKvpString(LAST_KVP)
        if #pool > 1 then
            for i, p in ipairs(pool) do
                if p.key == last then table.remove(pool, i) break end
            end
        end
        local out = {}
        while #pool > 0 and #out < CHOICES do
            local total = 0
            for _, p in ipairs(pool) do total = total + p.w end
            local r = math.random() * total
            for i, p in ipairs(pool) do
                r = r - p.w
                if r <= 0 or i == #pool then
                    out[#out + 1] = table.remove(pool, i)
                    break
                end
            end
        end
        return out
    end

    local function attachProp(ped, prop)
        if type(prop) ~= 'table' or not Stream.model(prop.model, function() return true end, 2000) then return nil end
        local hash = GetHashKey(prop.model)
        local at = GetEntityCoords(ped)
        pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
        local obj = CreateObject(hash, at.x, at.y, at.z, false, false, false)
        SetModelAsNoLongerNeeded(hash)
        local p, r = prop.pos or {}, prop.rot or {}
        AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, tonumber(prop.bone) or 28422), p[1] or 0.0, p[2] or 0.0, p[3] or 0.0,
            r[1] or 0.0, r[2] or 0.0, r[3] or 0.0, true, true, false, true, 1, true)
        return obj
    end

    local function dropProp(c)
        if c and c.prop and DoesEntityExist(c.prop) then DeleteEntity(c.prop) end
        if c then c.prop = nil end
    end

    -- Starts (or starts again) the arrival on ped; c.target is where a walk ends. soft: no snap out of what it was doing.
    local function start(ped, c, soft)
        local arrival = c.arrival
        if not soft then ClearPedTasksImmediately(ped) end
        MC.debug('live arrival %s', tostring(arrival.scenario or arrival.clip or (arrival.walk and 'walk')))
        if type(arrival.scenario) == 'string' then
            TaskStartScenarioInPlace(ped, arrival.scenario, 0, true)
            return true
        end
        if type(arrival.dict) == 'string' and type(arrival.clip) == 'string' then
            if not Stream.dict(arrival.dict, function() return true end, 2000) then return false end
            local flag = tonumber(arrival.flag) or (arrival.walk and 49 or 1) -- 49: upper body only, the legs keep walking
            TaskPlayAnim(ped, arrival.dict, arrival.clip, 4.0, -4.0, -1, flag, 0.0, false, false, false)
            if not c.prop or not DoesEntityExist(c.prop) or not IsEntityAttachedToEntity(c.prop, ped) then
                dropProp(c)
                c.prop = attachProp(ped, arrival.prop)
            end
        end
        if c.target then
            local t = c.target
            TaskGoStraightToCoord(ped, t.x, t.y, t.z, 1.0, -1, t.w, 0.1)
        end
        return true
    end

    local function playing(ped, c)
        if c.taxi then return true end
        local arrival = c.arrival
        if arrival.scenario then return IsPedUsingScenario(ped, arrival.scenario) or IsPedActiveInScenario(ped) end
        if arrival.clip and not IsEntityPlayingAnim(ped, arrival.dict, arrival.clip, 3) then return false end
        if c.target and #(GetEntityCoords(ped).xy - vector2(c.target.x, c.target.y)) > 1.0 then
            return GetScriptTaskStatus(ped, GO_STRAIGHT) ~= 7
        end
        return true
    end

    -- A walk that has reached the point goes on with its next part (stopping to check the phone, lighting up).
    local function arrived(c)
        if not c.target then return false end
        return #(GetEntityCoords(c.ped).xy - vector2(c.target.x, c.target.y)) < 0.6 or GetScriptTaskStatus(c.ped, GO_STRAIGHT) == 7
    end

    local function advance(c)
        local after = resolve(c.arrival.next)
        c.target = nil
        if not after then return end
        if c.arrival.clip then StopAnimTask(c.ped, c.arrival.dict, c.arrival.clip, 2.0) end
        dropProp(c)
        c.arrival = after
        start(c.ped, c, true)
    end

    -- While the camera comes down the arrival is kept on: the framework's load may dress the ped again (or make a new one)
    -- some time after its events, which drops the task; it starts again on the current ped.
    local function keep(alive)
        CreateThread(function()
            local tries = 0
            while current and not current.ended and alive() and tries < KEEP_TRIES do
                Wait(KEEP_MS)
                local c = current
                if not c or c.ended then return end
                local ped = PlayerPedId()
                if ped ~= c.ped or not playing(ped, c) then
                    tries = tries + 1
                    MC.debug('live arrival dropped (new ped: %s), starting it again', tostring(ped ~= c.ped))
                    if ped ~= c.ped then dropProp(c) end
                    c.ped = ped
                    start(ped, c)
                end
            end
        end)
    end

    -- The arrival ends softly before the camera is back: a scenario plays its exit, an animation blends out.
    local function finish(c)
        if not c or c.ended then return end
        c.ended = true
        if not DoesEntityExist(c.ped) then return dropProp(c) end
        if c.arrival.scenario then
            ClearPedTasks(c.ped)
        elseif c.arrival.clip then
            StopAnimTask(c.ped, c.arrival.dict, c.arrival.clip, 2.0)
        end
        SetTimeout(700, function() dropProp(c) end)
    end

    -- A walk begins behind the point, turned by angle degrees (it comes in from a side and turns into the heading), on
    -- open ground: nil when a wall or a drop is in the way.
    local function walkStart(coords, metres, angle)
        local h = math.rad(coords.w + angle)
        local x, y = coords.x + math.sin(h) * metres, coords.y - math.cos(h) * metres
        local ray = StartExpensiveSynchronousShapeTestLosProbe(coords.x, coords.y, coords.z + 0.3, x, y, coords.z + 0.3, 1 | 16, PlayerPedId(), 7)
        local _, hit = GetShapeTestResult(ray)
        if hit == 1 then return nil end
        local found, ground = GetGroundZFor_3dCoord(x, y, coords.z + 1.5, false)
        if not found or math.abs(ground + 1.0 - coords.z) > 0.8 then return nil end
        local _, faceTo = CamMath.lookRot(x, y, 0, coords.x, coords.y, 0)
        return vector4(x, y, ground + 1.0, faceTo)
    end

    -- A cab brings the character: it drives in along the nearest road, stops, the character gets out of the back and
    -- The cab is networked (others see the player ride in): taken back before it goes, as its control may have moved
    -- to a nearby player; failing that the game may take it once it is no longer needed.
    local function dispose(ent)
        if not DoesEntityExist(ent) then return end
        SetEntityAsMissionEntity(ent, true, true)
        DeleteEntity(ent)
        if not DoesEntityExist(ent) then return end
        NetworkRequestControlOfEntity(ent)
        CreateThread(function()
            local stop = GetGameTimer() + 1000
            while DoesEntityExist(ent) and GetGameTimer() < stop do
                Wait(50)
                SetEntityAsMissionEntity(ent, true, true)
                DeleteEntity(ent)
            end
            if DoesEntityExist(ent) then SetEntityAsNoLongerNeeded(ent) end
        end)
    end

    -- walks to the point; the cab drives off and goes. busy() holds the camera's last stretch until the walk is done.
    local function taxiBegin(ped, coords, e)
        local found, node, nodeH = GetClosestVehicleNodeWithHeading(coords.x, coords.y, coords.z, 1, 3.0, 0)
        if not found or #(node - coords.xyz) > TAXI_NEAR then return nil end
        local car, driver = joaat(e.taxi.model or 'taxi'), joaat(e.taxi.driver or 'a_m_y_stlat_01')
        local ok = Stream.model(car, function() return true end, 4000) and Stream.model(driver, function() return true end, 4000)
        if not ok then return nil end
        local h = math.rad(nodeH)
        local fx, fy = -math.sin(h), math.cos(h)
        pcall(function() exports['FeloxAC']:CreateVehicle(car) end) --[[FeloxAC:auto]]
        local veh = CreateVehicle(car, node.x - fx * TAXI_RUN, node.y - fy * TAXI_RUN, node.z + 0.5, nodeH, true, false)
        if not veh or veh == 0 then return nil end
        SetVehicleOnGroundProperly(veh)
        SetEntityAsMissionEntity(veh, true, true)
        pcall(function() exports['FeloxAC']:CreatePed(driver) end) --[[FeloxAC:auto]]
        local cabbie = CreatePedInsideVehicle(veh, 26, driver, -1, true, false)
        SetModelAsNoLongerNeeded(car)
        SetModelAsNoLongerNeeded(driver)
        SetBlockingOfNonTemporaryEvents(cabbie, true)
        SetPedIntoVehicle(ped, veh, 2)
        TaskVehicleDriveToCoord(cabbie, veh, node.x, node.y, node.z, 9.0, 0, car, 786603, 1.5, true)
        local c = { ped = ped, arrival = e, taxi = { car = veh, driver = cabbie }, stage = 'drive' }
        c.busy = function() return c.stage ~= 'done' end
        CreateThread(function()
            local t0 = GetGameTimer()
            while c.stage == 'drive' and GetGameTimer() - t0 < 10000 do
                if #(GetEntityCoords(veh) - node) < 3.0 and GetEntitySpeed(veh) < 1.0 then break end
                Wait(100)
            end
            if not DoesEntityExist(veh) then c.stage = 'done' return end
            c.stage = 'exit'
            TaskLeaveVehicle(ped, veh, 0)
            t0 = GetGameTimer()
            while IsPedInAnyVehicle(ped, false) and GetGameTimer() - t0 < 4000 do Wait(100) end
            if IsPedInAnyVehicle(ped, false) then TaskLeaveVehicle(ped, veh, 16) end
            TaskVehicleDriveWander(cabbie, veh, 12.0, 786603)
            c.stage = 'walk'
            TaskGoStraightToCoord(ped, coords.x, coords.y, coords.z, 1.0, -1, coords.w, 0.1)
            t0 = GetGameTimer()
            while #(GetEntityCoords(ped).xy - coords.xy) > 0.6 and GetGameTimer() - t0 < 9000 do Wait(100) end
            c.stage = 'done'
            Wait(15000)
            dispose(cabbie)
            dispose(veh)
        end)
        return c
    end

    -- Places and starts one arrival; nil (the ped back on the point) when it has no room to walk or does not play.
    local function begin(ped, coords, e)
        if type(e.taxi) == 'table' then return taxiBegin(ped, coords, e) end
        local c = { ped = ped, arrival = e }
        local metres = tonumber(e.walk)
        if metres and metres > 0 then
            local angle = tonumber(e.angle) or (math.random(20, 40) * (math.random(2) == 1 and -1 or 1))
            local from = walkStart(coords, metres, angle) or walkStart(coords, metres, -angle) or walkStart(coords, metres, 0)
            if not from then return nil end
            pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]] 
            SetEntityCoordsNoOffset(ped, from.x, from.y, from.z, false, false, false)
            SetEntityHeading(ped, from.w)
            c.target = coords
        end
        if start(ped, c) then
            Wait(CHECK_MS)
            if playing(ped, c) then return c end
        end
        ClearPedTasksImmediately(ped)
        dropProp(c)
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]] 
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
        SetEntityHeading(ped, coords.w)
        return nil
    end

    -- A camera high behind the point, for spawns that come without the selector's aerial shot.
    local function aerialOver(c)
        local x, y, z = CamMath.toWorld({ x = c.x, y = c.y, z = c.z, h = c.w }, 0, -70.0, 50.0)
        local pitch, yaw = CamMath.lookRot(x, y, z, c.x, c.y, c.z + 1.0)
        return { x = x, y = y, z = z, rx = pitch, ry = 0, rz = yaw, fov = 45.0 }
    end

    -- Where the gameplay camera stands behind the ped (it keeps following it while ours renders); a sane fallback.
    local function gameplayPose(ped)
        local at = GetEntityCoords(ped)
        local pos, rot, fov = GetGameplayCamCoord(), GetGameplayCamRot(2), GetGameplayCamFov()
        if #(pos - at) < 12.0 and fov > 10.0 then
            return { x = pos.x, y = pos.y, z = pos.z, rx = rot.x, ry = 0, rz = rot.z, fov = fov }
        end
        local x, y, z = CamMath.toWorld({ x = at.x, y = at.y, z = at.z, h = GetEntityHeading(ped) }, 0.0, -4.0, 0.8)
        local pitch, yaw = CamMath.lookRot(x, y, z, at.x, at.y, at.z + 0.4)
        return { x = x, y = y, z = z, rx = pitch, ry = 0, rz = yaw, fov = 50.0 }
    end

    -- The camera in the ped's frame as an orbit: distance, elevation and azimuth (0 in front, 90 right, 180 behind)
    -- around a pivot at its chest. Interpolating these instead of points gives a crane that spirals in without overshoot.
    local PIVOT = 0.4

    local function toOrbit(x, y, z)
        local flat = math.sqrt(x * x + y * y)
        local dz = z - PIVOT
        return {
            r = math.max(math.sqrt(flat * flat + dz * dz), 0.5),
            e = math.deg(math.atan(dz, math.max(flat, 1e-3))),
            a = math.deg(math.atan(x, y)),
        }
    end

    local function fromOrbit(o)
        local e, a = math.rad(o.e), math.rad(o.a)
        local flat = o.r * math.cos(e)
        return flat * math.sin(a), flat * math.cos(a), PIVOT + o.r * math.sin(e)
    end

    local function localOf(anchor, p)
        return CamMath.toLocal(anchor, p.x, p.y, p.z)
    end

    -- Three knots (0, FRAMED_AT, 1), still at both ends; on the middle one slow when the value runs on, still when it
    -- turns back. Never leaves the knots' range, so nothing overshoots.
    local function knots(v0, v1, v2, u)
        local a = FRAMED_AT
        local d0, d1 = (v1 - v0) / a, (v2 - v1) / (1 - a)
        local m = (d0 * d1 > 0) and 0.3 * (d0 > 0 and 1 or -1) * math.min(math.abs(d0), math.abs(d1)) or 0
        local function h(p0, p1, m0, m1, t, span)
            local t2, t3 = t * t, t * t * t
            return (2 * t3 - 3 * t2 + 1) * p0 + (t3 - 2 * t2 + t) * span * m0 + (-2 * t3 + 3 * t2) * p1 + (t3 - t2) * span * m1
        end
        if u <= a then return h(v0, v1, 0, m, u / a, a) end
        return h(v1, v2, m, 0, (u - a) / (1 - a), 1 - a)
    end

    local function smooth(a, b, x)
        local t = CamMath.clamp((x - a) / (b - a), 0, 1)
        return t * t * (3 - 2 * t)
    end

    -- The framed shot on the side the camera passes anyway (mirrored left or right), so the way round never turns back.
    local function sideOf(shot, right)
        if (shot.cam[1] >= 0) == right then return shot end
        return { cam = { -shot.cam[1], shot.cam[2], shot.cam[3] }, look = { -shot.look[1], shot.look[2], shot.look[3] }, fov = shot.fov }
    end

    -- Where the gameplay camera looks, in the ped's frame: a point along its view as far ahead as the ped is from it.
    local function gameplayLook(an, gp)
        local fx, fy, fz = CamMath.forward(gp.rx, gp.rz)
        local d = math.max(CamMath.dist(gp, an), 1.0)
        return { CamMath.toLocal(an, gp.x + fx * d, gp.y + fy * d, gp.z + fz * d) }
    end

    -- One timeline for the camera and the arrival: ms long, the arrival ending (exit included) just before the camera is
    -- home. Blocks; false when the session changed or the deadline passed.
    local function fly(ped, finalAt, shotName, ms, exitMs, alive, deadline)
        local from = Rig.pose()
        local h = finalAt.w
        local function anchor()
            local at = GetEntityCoords(ped)
            return { x = at.x, y = at.y, z = at.z, h = h }
        end
        local o0 = toOrbit(localOf(anchor(), from))
        local gp0 = gameplayPose(ped)
        local o2 = toOrbit(localOf(anchor(), gp0))
        o2.a = CamMath.unwrap(o0.a, o2.a)
        -- The framed shot on the gameplay camera's side (it sits over the right shoulder), so the end never swings across.
        local gpX = CamMath.toLocal(anchor(), gp0.x, gp0.y, gp0.z)
        local shot = sideOf(SHOTS[shotName] or SHOTS.wide, gpX >= 0)
        local o1 = toOrbit(shot.cam[1], shot.cam[2], shot.cam[3])
        o1.a = CamMath.unwrap(o2.a, o1.a) -- the framed shot is a short way from the gameplay camera, never round the back
        -- Look points in the ped's frame: its chest from far away, then the framed one on the shot.
        local look0 = { 0.0, 0.0, PIVOT }
        local t0, yaw = GetGameTimer(), from.rz
        local last, held = t0, 0
        while true do
            if not alive() or GetGameTimer() > deadline then return false end
            -- A cab still on its way holds the last stretch (up to HOLD_MS) so the camera lands with the character.
            local tick = GetGameTimer()
            if current and current.busy and current.busy() and (tick - t0) / ms > 0.8 and held < HOLD_MS then
                t0, held = t0 + (tick - last), held + (tick - last)
            end
            last = tick
            local u = CamMath.clamp((GetGameTimer() - t0) / ms, 0, 1)
            local c = current
            if c and not c.ended and c.target and c.arrival.next and arrived(c) then advance(c) end
            if c and not c.ended and GetGameTimer() - t0 >= ms - exitMs then finish(c) end
            local an = anchor()
            -- The end knot follows the gameplay camera as it is now (the ped may still be moving or turning).
            local gp = gameplayPose(ped)
            local live = toOrbit(localOf(an, gp))
            local o = {
                r = math.exp(knots(math.log(o0.r), math.log(o1.r), math.log(live.r), u)),
                e = knots(o0.e, o1.e, live.e, u),
                a = knots(o0.a, o1.a, CamMath.unwrap(o2.a, live.a), u),
            }
            local px, py, pz = CamMath.toWorld(an, fromOrbit(o))
            -- The end look point is the gameplay camera's own, so the view turns into it on the way, not at the last moment.
            local look2 = gameplayLook(an, gp)
            local lx = knots(look0[1], shot.look[1], look2[1], u)
            local ly = knots(look0[2], shot.look[2], look2[2], u)
            local lz = knots(look0[3], shot.look[3], look2[3], u)
            local tx, ty, tz = CamMath.toWorld(an, lx, ly, lz)
            local pitch, look = CamMath.lookRot(px, py, pz, tx, ty, tz)
            -- Eases out of wherever the aerial shot was looking, and into the gameplay camera's own angles.
            local w0, w2 = smooth(0.0, 0.15, u), smooth(0.85, 1.0, u)
            pitch = CamMath.lerp(from.rx, pitch, w0)
            look = CamMath.unwrap(yaw, CamMath.lerp(from.rz, CamMath.unwrap(from.rz, look), w0))
            pitch = CamMath.lerp(pitch, gp.rx, w2)
            look = CamMath.lerp(look, CamMath.unwrap(look, gp.rz), w2)
            if w2 > 0 then px, py, pz = CamMath.lerp(px, gp.x, w2), CamMath.lerp(py, gp.y, w2), CamMath.lerp(pz, gp.z, w2) end
            local fov = knots(from.fov or 45.0, shot.fov, gp.fov, u)
            yaw = look
            Rig.set(px, py, pz, pitch, 0.0, look, fov)
            if u >= 1 then return true end
            Wait(0)
        end
    end

    -- Blocks until the player stands on coords, the arrival done and the gameplay camera back; false when it could not.
    -- opts { job, kind, down, loaded }: the job and the point kind pick the arrival; down: the character left the game dead
    -- (the medical script lays it down again, no arrival); loaded() runs the framework's load events (they may dress the
    -- ped again, which would cancel an arrival started before them).
    function Live.run(coords, opts)
        opts = type(opts) == 'table' and opts or {}
        local gen, deadline = MC.gen, GetGameTimer() + DEADLINE_MS
        local alive = function() return gen == MC.gen end
        local function fail()
            Frame.off('live')
            Live.cancel()
            return false
        end
        Frame.on('live', disableControls)
        if not Rig.active() then
            Rig.start(aerialOver(coords))
            if IsScreenFadedOut() or IsScreenFadingOut() then DoScreenFadeIn(600) end
        end
        Director.stop()
        SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)

        -- Placed while the camera still looks from above, hidden until the ground is there. No ground in time: the
        -- arrival would walk the character through the map, so the caller's fade takes over (it waits for the ground).
        Player.place(coords)
        Stream.at(coords.xyz, ARRIVAL_M, STREAM_MS)
        if not Stream.collision(PlayerPedId(), COLLISION_MS) then
            print('^3[daddy_multichar] live spawn: no ground in time, using the fade^7')
            return fail()
        end
        if not alive() or GetGameTimer() > deadline then return fail() end
        -- Whatever is not loaded yet keeps loading while the camera comes down (land stops it).
        Stream.prefetch(coords.xyz, ARRIVAL_M)
        Player.release()
        SetEntityHeading(PlayerPedId(), coords.w)
        if opts.loaded then
            opts.loaded()
            Wait(LOADED_MS)
            if not alive() then return fail() end
        end

        -- The ped may be a new one after the load (a model set again): read it now.
        local ped = PlayerPedId()
        local ms, exitMs, shotName = DOWN_MS, 0, 'down'
        if not opts.down then
            local length = opts.length or MC.arrivalLength()
            local limits = LENGTHS[length] or LENGTHS.short
            shotName, ms = 'wide', limits[1]
            local choices = opts.only and { opts.only } or ((length == 'off' or IsEntityInWater(ped)) and {} or Live.pick(opts.job, opts.kind, ped, length))
            if #choices == 0 then MC.debug('live arrival: none for job %s, kind %s', tostring(opts.job), tostring(opts.kind)) end
            for _, choice in ipairs(choices) do
                local c = begin(ped, coords, choice.e)
                if not alive() then return fail() end
                if c then
                    if not opts.only then pcall(SetResourceKvp, LAST_KVP, choice.key) end
                    current = c
                    keep(alive)
                    local e, after = choice.e, length == 'full' and resolve(choice.e.next) or nil
                    if not after then c.arrival = with(e, { next = false }) end
                    local walkMs = c.target and tonumber(e.walk) / WALK_SPEED * 1000 + 800 or 0
                    ms = length == 'walk' and walkMs or math.max(tonumber(e.ms) or 6000, walkMs)
                    if after then ms = ms + (tonumber(after.ms) or 6000) end
                    exitMs = tonumber((after or e).exit) or ((after or e).scenario and 1800 or 600)
                    shotName = e.cam or (after and after.cam) or (c.target and 'follow' or 'wide')
                    break
                end
                MC.debug('live arrival %s did not play, trying the next', choice.key)
            end
            ms = CamMath.clamp(ms, limits[1], current and current.taxi and TAXI_MAX_MS or limits[2])
        end

        -- The gameplay camera looks straight ahead from behind; ours comes down into exactly that pose.
        SetGameplayCamRelativeHeading(0.0)
        SetGameplayCamRelativePitch(-5.0, 1.0)
        if not fly(ped, coords, shotName, ms, exitMs, alive, deadline + ms + HOLD_MS) then return fail() end

        -- Our camera stands where the gameplay one is: the controls come back at once (a scenario's last exit frames
        -- may still play, the first step ends them) while a short blend hands the camera over.
        current = nil
        Frame.off('live')
        Nui.letGo()
        Rig.toGameplay(HANDOVER_MS)
        ClearFocus()
        return true
    end

    -- /mc_arrival (Config.Debug, admins): the library played on the spot with the live camera, its name on screen.
    -- No argument or 'all': every entry in turn (Backspace stops after the one playing); a name plays that one;
    -- 'down' the dead-on-logout landing; 'short' or 'walk' after any of them plays it at that length.
    local testing = nil

    local function label()
        local t = testing
        if not t then return end
        if IsDisabledControlJustPressed(0, 177) then t.stop = true end
        SetTextFont(4)
        SetTextScale(0.0, 0.5)
        SetTextColour(255, 255, 255, 230)
        SetTextOutline()
        BeginTextCommandDisplayText('STRING')
        AddTextComponentSubstringPlayerName(t.text .. (t.stop and '  ~r~(stopping)' or '  ~c~Backspace: stop'))
        EndTextCommandDisplayText(0.02, 0.9)
    end

    local function tags(e)
        local out = {}
        for _, key in ipairs({ 'cam', 'sex', 'time', 'weather' }) do
            if e[key] then out[#out + 1] = key .. '=' .. tostring(e[key]) end
        end
        if e.walk then out[#out + 1] = 'walk=' .. e.walk end
        if e.next then out[#out + 1] = 'next=' .. tostring(e.next) end
        return table.concat(out, ' ')
    end

    function Live.test(_, args)
        if testing then testing.stop = true return end
        local which, length = args[1] or 'all', 'full'
        for _, a in ipairs(args) do
            if a == 'short' or a == 'walk' or a == 'full' then length = a end
        end
        if which == 'short' or which == 'walk' or which == 'full' then which = 'all' end
        local list = {}
        if which == 'all' then
            for name, e in pairs(Arrivals) do
                if type(e) == 'table' then list[#list + 1] = name end
            end
            table.sort(list)
        elseif which == 'down' or type(Arrivals[which]) == 'table' then
            list[1] = which
        else
            return print(('mc_arrival: no arrival named %s'):format(which))
        end
        CreateThread(function()
            local ped = PlayerPedId()
            local at = GetEntityCoords(ped)
            local coords = vector4(at.x, at.y, at.z, GetEntityHeading(ped))
            testing = { text = '' }
            Frame.on('live_test', label)
            for i, name in ipairs(list) do
                if testing.stop then break end
                local e = Arrivals[name]
                testing.text = ('%d/%d  %s  ~c~%s %s'):format(i, #list, name, e and tags(e) or 'down', length)
                print(('mc_arrival %d/%d %s'):format(i, #list, name))
                Live.run(coords, { only = e and { e = e, key = name } or nil, down = name == 'down', length = length })
                Wait(1500)
            end
            Frame.off('live_test')
            testing = nil
        end)
    end

    -- The way out (relog with the live transition): our camera takes over from the gameplay camera where it stands and
    -- rises behind the character into the sky; the leaving poster and the black come after it. Blocks for about ms.
    function Live.leave(ms)
        ms = tonumber(ms) or 3200
        local ped = PlayerPedId()
        local at, h = GetEntityCoords(ped), GetEntityHeading(ped)
        Frame.on('live', disableControls)
        Rig.start(gameplayPose(ped))
        local x, y, z = CamMath.toWorld({ x = at.x, y = at.y, z = at.z, h = h }, 0.0, -45.0, 38.0)
        local pitch, yaw = CamMath.lookRot(x, y, z, at.x, at.y, at.z + 1.0)
        local done = false
        Director.retarget({ x = x, y = y, z = z, rx = pitch, ry = 0, rz = yaw, fov = 45.0 }, ms, { ease = 'inOutCubic', onDone = function() done = true end })
        local stop = GetGameTimer() + ms + 600
        while not done and GetGameTimer() < stop do Wait(0) end
        Frame.off('live')
    end

    -- Something took the player away mid-arrival (a relog, a restart): the arrival is dropped and the controls freed.
    function Live.cancel()
        Frame.off('live')
        local c = current
        current = nil
        if not c then return end
        dropProp(c)
        if c.taxi then
            dispose(c.taxi.driver)
            dispose(c.taxi.car)
        end
        if DoesEntityExist(c.ped) and not c.ended then ClearPedTasks(c.ped) end
    end
end

-- Plays a cutscene from shared/cutscenes: actors, a timeline of steps, hold-to-skip, and one way out for every
-- ending (done, skipped, failed or timed out). Timeline, checks and needs are pure, so tests load this file.
do
    Cutscene = {}

    local SKIP_MS, GRACE_MS = 900, 10000
    local ACTOR_TYPES = { vehicle = 1, prop = 2, ped = 3, player = 4 }
    local REFS = { 'actor', 'ped', 'vehicle' }
    local current, generation = nil, 0

    -- The steps in play order: by time, then as written.
    function Cutscene.timeline(def)
        local list = {}
        for i, step in ipairs(def.steps or {}) do
            for kind, params in pairs(step) do
                if kind ~= 't' then list[#list + 1] = { t = tonumber(step.t) or 0, kind = kind, p = params, i = i } end
            end
        end
        table.sort(list, function(a, b)
            if a.t ~= b.t then return a.t < b.t end
            return a.i < b.i
        end)
        return list
    end

    -- Models and animation dictionaries to load before the first frame, sorted.
    function Cutscene.needs(def)
        local models, dicts, seen = {}, {}, {}
        local function add(list, name)
            if type(name) == 'string' and not seen[name] then
                seen[name] = true
                list[#list + 1] = name
            end
        end
        for _, a in pairs(def.actors or {}) do
            add(models, a.model)
            add(models, a.driver and a.driver.model)
        end
        for _, s in ipairs(Cutscene.timeline(def)) do
            if s.kind == 'prop' then add(models, s.p.model) end
            if s.kind == 'anim' then add(dicts, s.p.dict) end
        end
        table.sort(models)
        table.sort(dicts)
        return models, dicts
    end

    local function checkParams(def, kind, p)
        if type(p) ~= 'table' then return 'params' end
        for _, ref in ipairs(REFS) do
            if p[ref] ~= nil and not def.actors[p[ref]] then return ref .. ' ' .. tostring(p[ref]) end
        end
        if kind == 'path' and #(p.points or {}) < 2 then return 'points' end
        if kind == 'camera' and #(p.keys or {}) < 1 then return 'keys' end
        if kind == 'drive' and not (p.to or p.ahead) then return 'to' end
        if kind == 'wait' and not p['until'] then return 'until' end
    end

    -- Why a step cannot play, or nil: one known kind, known actors, a time inside the cutscene.
    local function checkStep(def, step)
        local kinds = 0
        for kind, p in pairs(step) do
            if kind ~= 't' then
                kinds = kinds + 1
                if not Steps.KINDS[kind] then return 'kind ' .. tostring(kind) end
                local problem = checkParams(def, kind, p)
                if problem then return kind .. ': ' .. problem end
            end
        end
        local t = tonumber(step.t)
        if kinds ~= 1 then return 'one kind per step' end
        if not t or t < 0 or t > def.ms then return 't' end
    end

    local function checkActors(def)
        for name, a in pairs(def.actors) do
            if not ACTOR_TYPES[a.type] then return 'actor ' .. name end
            if a.type ~= 'player' and type(a.model) ~= 'string' then return 'model ' .. name end
            local seat = a.seat and def.actors[a.seat.actor]
            if a.seat and not (seat and seat.type == 'vehicle') then return 'seat ' .. name end
        end
    end

    -- Why a definition cannot play, or nil.
    function Cutscene.check(def)
        if type(def) ~= 'table' or type(def.steps) ~= 'table' or type(def.actors) ~= 'table' then return 'shape' end
        if not tonumber(def.ms) or not (def.arrive and def.arrive.x and def.arrive.w) then return 'arrive' end
        local problem = checkActors(def)
        if problem then return problem end
        local done = 0
        for i, step in ipairs(def.steps) do
            problem = checkStep(def, step)
            if problem then return ('step %d: %s'):format(i, problem) end
            if step.done then done = done + 1 end
        end
        if done ~= 1 then return 'one done step' end
        return nil
    end

    -- Runtime ----------------------------------------------------------------------------------------------------------

    local function waitFade(out, ms)
        local deadline = GetGameTimer() + (ms or 1500)
        while GetGameTimer() < deadline and (out and not IsScreenFadedOut() or not out and not IsScreenFadedIn()) do Wait(0) end
    end

    local function setCam(c, x, y, z, pitch, yaw, fov)
        if c.rig then return Rig.set(x, y, z, pitch, 0.0, yaw, fov) end
        c.rig = true
        Rig.start({ x = x, y = y, z = z, rx = pitch, ry = 0.0, rz = yaw, fov = fov })
    end

    local function finish(c, result, blend)
        if c.over then return end
        c.over, c.result, c.blend = true, result, blend
        Frame.off('cut')
        c.done:resolve(result)
    end

    local function newContext(id, def)
        generation = generation + 1
        local c = { id = id, def = def, gen = generation, actors = {}, arrived = {}, updaters = {}, props = {},
            list = Cutscene.timeline(def), next = 1, clock = 0, sent = 0.0, done = promise.new() }
        c.valid = function() return current == c and not c.over end
        c.setCam = function(...) setCam(c, ...) end
        c.wait = function(cond, timeout) c.waiting = { cond = cond, deadline = GetGameTimer() + timeout } end
        c.finish = function(result, blend) finish(c, result, blend) end
        return c
    end

    -- Space, or A on a pad (Enter is not a skip).
    local function holding()
        return IsDisabledControlPressed(0, 22) or (not IsUsingKeyboard(2) and IsDisabledControlPressed(2, 201))
    end

    -- Hold for SKIP_MS; the page draws its ring from the progress.
    local function skipProgress(c, now)
        c.holdFrom = holding() and (c.holdFrom or now) or nil
        local progress = c.holdFrom and math.min(1.0, (now - c.holdFrom) / SKIP_MS) or 0.0
        if math.abs(progress - c.sent) >= 0.04 or (progress ~= c.sent and (progress == 0.0 or progress == 1.0)) then
            c.sent = progress
            MC.Send('mc:cut:skip', { progress = progress })
        end
        return progress >= 1.0
    end

    -- Timeline time stands still while a wait holds it.
    local function advance(c, now, dt)
        local w = c.waiting
        if w and now < w.deadline and not Steps.holds(c, w.cond) then return end
        c.waiting = nil
        c.clock = c.clock + dt
    end

    local function fire(c)
        while not c.over and not c.waiting and c.list[c.next] and c.list[c.next].t <= c.clock do
            local s = c.list[c.next]
            c.next = c.next + 1
            Steps[s.kind](s.p, c)
        end
    end

    -- Movers first, the camera last, so it frames where they are this frame.
    local function update(c, now, dt)
        for name, fn in pairs(c.updaters) do
            if name ~= 'cam' and fn(now, dt) then c.updaters[name] = nil end
        end
        local cam = c.updaters.cam
        if cam and cam(now, dt) then c.updaters.cam = nil end
    end

    local function frame()
        local c = current
        if not c or c.over then return end
        local now = GetGameTimer()
        local dt = now - c.last
        c.last = now
        DisableAllControlActions(0)
        DisableFrontendThisFrame()
        HideHudAndRadarThisFrame()
        if skipProgress(c, now) then return finish(c, 'skipped') end
        advance(c, now, dt)
        fire(c)
        if not c.over then update(c, now, dt / 1000.0) end
    end

    -- A broken step ends the cutscene instead of the Frame host dropping the handler.
    local function guarded()
        local ok, err = pcall(frame)
        if ok or not current then return end
        print(('^1[daddy_multichar] cutscene %s: %s^7'):format(current.id, err))
        finish(current, 'failed')
    end

    local function load(c)
        local models, dicts = Cutscene.needs(c.def)
        c.models, c.dicts = models, dicts
        for _, name in ipairs(models) do
            if not Stream.model(joaat(name), c.valid, 8000) then error('model ' .. name) end
        end
        for _, dict in ipairs(dicts) do Stream.dict(dict, c.valid, 4000) end
    end

    -- Vehicles first, so seats and drivers have somewhere to go.
    local function spawn(c)
        local actors, names = c.def.actors, {}
        for name in pairs(actors) do names[#names + 1] = name end
        table.sort(names, function(a, b)
            local x, y = ACTOR_TYPES[actors[a].type], ACTOR_TYPES[actors[b].type]
            if x ~= y then return x < y end
            return a < b
        end)
        for _, name in ipairs(names) do
            c.actors[name] = Steps.spawn[actors[name].type](actors[name], c)
            if not c.actors[name] then error('actor ' .. name) end
        end
    end

    -- Under black: the player hidden at the arrival, the area streamed and emptied, models in, actors placed.
    local function prepare(c)
        local at = c.def.stream or c.def.arrive
        if not IsScreenFadedOut() then
            DoScreenFadeOut(300)
            waitFade(true)
        end
        Player.hide()
        Player.place(c.def.arrive)
        Stream.at(at, 150.0, 8000)
        ClearAreaOfVehicles(at.x, at.y, at.z, 150.0, false, false, false, false, false)
        ClearAreaOfPeds(at.x, at.y, at.z, 150.0, 1)
        load(c)
        spawn(c)
    end

    -- The t = 0 steps place the camera before the picture comes up.
    local function start(c)
        Nui.screen('cutscene', { id = c.id, title = c.def.title })
        Nui.input('game')
        Env.crowd(true)
        c.last = GetGameTimer()
        fire(c)
        update(c, c.last, 0.0)
        Frame.on('cut', guarded)
        SetTimeout(c.def.ms + GRACE_MS, function()
            if current == c then finish(c, 'failed') end
        end)
        DoScreenFadeIn(800)
    end

    -- The cutscene's models and dictionaries go back to the streamer (spawned entities keep theirs).
    local function unload(c)
        for _, name in ipairs(c.models or {}) do SetModelAsNoLongerNeeded(joaat(name)) end
        for _, dict in ipairs(c.dicts or {}) do RemoveAnimDict(dict) end
        c.models, c.dicts = nil, nil
    end

    -- Per-frame work stops at once; with a delay the actors live on a moment (a cab driving off) before they go.
    local function cleanup(c, delay)
        Frame.off('cut')
        Director.stop()
        Env.crowd(false)
        ClearFocus()
        MC.Send('mc:cut:skip', { progress = 0.0 })
        if current == c then current = nil end
        if not delay then
            Track.clear('cutscene')
            return unload(c)
        end
        SetTimeout(delay, function()
            if generation == c.gen and not current then Track.clear('cutscene') end
            if not current then unload(c) end
        end)
    end

    local function behindPlayer()
        SetGameplayCamRelativeHeading(0.0)
        SetGameplayCamRelativePitch(-5.0, 1.0)
    end

    -- Skip, failure or timeout: under black the player stands at the arrival with the gameplay camera behind.
    local function recover(c)
        local me = PlayerPedId()
        DoScreenFadeOut(300)
        waitFade(true, 1000)
        ClearPedTasksImmediately(me)
        cleanup(c)
        Player.place(c.def.arrive)
        Steps.show(me)
        Stream.collision(me, 3000)
        behindPlayer()
        Rig.toGameplay(0)
        DoScreenFadeIn(500)
    end

    -- The end as written: the camera blends down behind the player (snapped to the arrival when far from it).
    local function land(c)
        local me, a, blend = PlayerPedId(), c.def.arrive, c.blend or 1500
        local pos = GetEntityCoords(me)
        if math.sqrt((pos.x - a.x) ^ 2 + (pos.y - a.y) ^ 2) > 3.0 then
            DoScreenFadeOut(250)
            waitFade(true, 800)
            ClearPedTasksImmediately(me)
            Player.place(a)
            Steps.show(me)
            DoScreenFadeIn(400)
        end
        behindPlayer()
        Rig.toGameplay(blend)
        cleanup(c, blend + 4000)
        Wait(blend)
        for _, obj in ipairs(c.props) do
            if DoesEntityExist(obj) then DeleteEntity(obj) end
        end
        ClearPedTasks(me)
    end

    -- Blocks until the cutscene ends: 'done', 'skipped' or 'failed'. The player ends at def.arrive either way.
    function Cutscene.play(id)
        local def = Cutscenes and Cutscenes[id]
        local problem = current and 'busy' or not def and 'unknown' or Cutscene.check(def)
        if problem then
            print(('^1[daddy_multichar] cutscene %s: %s^7'):format(tostring(id), problem))
            return 'failed'
        end
        local c = newContext(id, def)
        current = c
        local ok, err = pcall(prepare, c)
        if ok and c.valid() then ok, err = pcall(start, c) end
        if not ok then
            print(('^1[daddy_multichar] cutscene %s: %s^7'):format(id, err))
            finish(c, 'failed')
        end
        local result = Citizen.Await(c.done)
        if c.aborted then return result end
        if result == 'done' then land(c) else recover(c) end
        MC.debug('cutscene %s: %s', id, result)
        return result
    end

    -- Stops at once without moving the player (resource stop, watchdog); the caller recovers.
    function Cutscene.abort()
        local c = current
        if not c then return end
        c.aborted = true
        finish(c, 'failed')
        cleanup(c)
    end

    function Cutscene.active()
        return current ~= nil
    end

    AddEventHandler('onResourceStop', function(resource)
        if resource == GetCurrentResourceName() then Cutscene.abort() end
    end)

    -- Cutscene actors and step handlers. A handler starts one action; work that lasts goes into c.updaters and returns
    -- true when it is over. The spline and easing maths are pure, so tests load this file too.
    Steps = { spawn = {} }

    Steps.KINDS = {
        camera = true, follow = true, path = true, drive = true, walk = true, enter = true, leave = true, anim = true,
        scenario = true, prop = true, gear = true, doors = true, lights = true, sound = true, title = true,
        subtitle = true, fade = true, focus = true, place = true, wait = true, done = true,
    }

    local EASE = {
        linear = function(t) return t end,
        outQuad = function(t) return 1.0 - (1.0 - t) * (1.0 - t) end,
        outCubic = function(t) return 1.0 - (1.0 - t) ^ 3 end,
        smooth = function(t) return t * t * (3.0 - 2.0 * t) end,
    }

    function Steps.ease(name, t)
        t = math.max(0.0, math.min(1.0, t))
        return (EASE[name] or EASE.smooth)(t)
    end

    -- A vector or table as a plain table, for modules that copy their input (a vector3 has no w to read).
    function Steps.plain(v)
        local kind = type(v)
        if kind ~= 'table' and kind ~= 'vector3' and kind ~= 'vector4' then return nil end
        return { x = v.x + 0.0, y = v.y + 0.0, z = v.z + 0.0, w = kind ~= 'vector3' and v.w or nil }
    end
    local plain = Steps.plain

    local function catmull(p0, p1, p2, p3, t)
        local t2 = t * t
        return 0.5 * (2.0 * p1 + (p2 - p0) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 + (3.0 * p1 - p0 - 3.0 * p2 + p3) * t2 * t)
    end

    -- Cumulative chord lengths, so the spline is crossed at an even speed.
    function Steps.chords(points)
        local cum, total = { 0.0 }, 0.0
        for i = 2, #points do
            local a, b = points[i - 1], points[i]
            total = total + math.sqrt((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2 + (b.z - a.z) ^ 2)
            cum[i] = total
        end
        return cum, total
    end

    -- 2b - a: the phantom point past an end of the spline.
    local function mirror(a, b)
        return { x = 2.0 * b.x - a.x, y = 2.0 * b.y - a.y, z = 2.0 * b.z - a.z }
    end

    -- The point at progress u (0..1) of a Catmull-Rom spline through every point.
    function Steps.sample(points, cum, total, u)
        local n = #points
        if n < 2 or total <= 0.0 then return points[1].x, points[1].y, points[1].z end
        local s = math.max(0.0, math.min(1.0, u)) * total
        local i = 1
        while i < n - 1 and cum[i + 1] < s do i = i + 1 end
        local len = cum[i + 1] - cum[i]
        local t = len > 0.0 and (s - cum[i]) / len or 0.0
        local p1, p2 = points[i], points[i + 1]
        local p0, p3 = points[i - 1] or mirror(p2, p1), points[i + 2] or mirror(p1, p2)
        return catmull(p0.x, p1.x, p2.x, p3.x, t), catmull(p0.y, p1.y, p2.y, p3.y, t), catmull(p0.z, p1.z, p2.z, p3.z, t)
    end

    -- The direction of travel at u, from a short chord around it.
    function Steps.tangent(points, cum, total, u)
        local x1, y1, z1 = Steps.sample(points, cum, total, math.max(0.0, u - 0.002))
        local x2, y2, z2 = Steps.sample(points, cum, total, math.min(1.0, u + 0.002))
        return x2 - x1, y2 - y1, z2 - z1
    end

    -- Pitch and heading of a direction, GTA style: heading 0 is north and forward is (-sin h, cos h).
    function Steps.lookRot(dx, dy, dz)
        return math.deg(math.atan(dz, math.sqrt(dx * dx + dy * dy))), math.deg(math.atan(-dx, dy))
    end

    -- to moved by whole turns so it lies within 180 degrees of from.
    function Steps.unwrap(from, to)
        return from + ((to - from + 180.0) % 360.0 - 180.0)
    end

    -- Roll that leans into a turn (rate in degrees a second), eased so it never snaps; limit 0 keeps it level.
    function Steps.bank(current, rate, dt, limit)
        limit = limit or 20.0
        local target = math.max(-limit, math.min(limit, -rate * 1.5))
        return current + (target - current) * (1.0 - math.exp(-dt * 3.0))
    end

    -- a moved towards b by k (0..1); no a yet means b itself.
    function Steps.mix(a, b, k)
        if not a then return plain(b) end
        return { x = a.x + (b.x - a.x) * k, y = a.y + (b.y - a.y) * k, z = a.z + (b.z - a.z) * k }
    end

    -- Game side ------------------------------------------------------------------------------------------------------

    local function entity(c, name)
        local e = name and c.actors[name]
        return e and DoesEntityExist(e) and e or nil
    end

    local function reached(c, name)
        c.arrived[name] = true
        return true
    end

    -- Brings the player into the picture; Player.hide left them frozen, invisible and without collision.
    function Steps.show(ped)
        SetEntityVisible(ped, true, false)
        ResetEntityAlpha(ped)
        SetEntityCollision(ped, true, true)
        FreezeEntityPosition(ped, false)
    end

    -- How far the model's origin sits above its lowest point (the wheels of a plane).
    function Steps.lift(ent)
        local low = GetModelDimensions(GetEntityModel(ent))
        return -low.z
    end

    -- A road node near p, facing p.w's way along the road, moved side metres to the kerb; nil when there is no road.
    local function road(p, side)
        local found, node, heading = GetClosestVehicleNodeWithHeading(p.x, p.y, p.z, 1, 3.0, 0)
        if not found then return nil end
        if p.w and math.abs(Steps.unwrap(p.w, heading) - p.w) > 90.0 then heading = (heading + 180.0) % 360.0 end
        local r, s = math.rad(heading), side or 0.0
        return { x = node.x + math.cos(r) * s, y = node.y + math.sin(r) * s, z = node.z, w = heading }
    end

    -- Where an actor or a drive goes: a point, or metres ahead of the vehicle, snapped to the road when asked.
    function Steps.target(p, ent)
        local to = plain(p.to or p.at)
        if p.ahead and ent then to = plain(GetOffsetFromEntityInWorldCoords(ent, 0.0, p.ahead + 0.0, 0.0)) end
        if to and ent and not to.w then to.w = GetEntityHeading(ent) end
        if to and p.road then to = road(to, p.side) or to end
        return to
    end

    local function driver(veh, def)
        pcall(function() exports['FeloxAC']:CreatePed(joaat(def.model)) end) --[[FeloxAC:auto]]
        local ped = CreatePedInsideVehicle(veh, 26, joaat(def.model), -1, false, false)
        if ped == 0 then return end
        Track.add('cutscene', ped)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedKeepTask(ped, true)
        SetEntityInvincible(ped, true)
        SetDriverAbility(ped, 1.0)
        SetDriverAggressiveness(ped, 0.0)
    end

    function Steps.spawn.vehicle(a)
        local at = Steps.target(a)
        RequestCollisionAtCoord(at.x, at.y, at.z)
        pcall(function() exports['FeloxAC']:CreateVehicle(joaat(a.model)) end) --[[FeloxAC:auto]]
        local veh = CreateVehicle(joaat(a.model), at.x, at.y, at.z, at.w or 0.0, false, false)
        if veh == 0 then return nil end
        Track.add('cutscene', veh)
        SetEntityInvincible(veh, true)
        SetVehicleDirtLevel(veh, 0.0)
        SetVehicleDoorsLocked(veh, 1)
        SetVehRadioStation(veh, 'OFF')
        SetVehicleEngineOn(veh, true, true, false)
        if a.lod then SetEntityLodDist(veh, a.lod) end
        if a.gear then ControlLandingGear(veh, a.gear) end
        if a.frozen then FreezeEntityPosition(veh, true) else SetVehicleOnGroundProperly(veh) end
        if a.driver then driver(veh, a.driver) end
        return veh
    end

    function Steps.spawn.ped(a)
        local at = plain(a.at)
        pcall(function() exports['FeloxAC']:CreatePed(joaat(a.model)) end) --[[FeloxAC:auto]]
        local ped = CreatePed(4, joaat(a.model), at.x, at.y, at.z - 1.0, at.w or 0.0, false, false)
        if ped == 0 then return nil end
        Track.add('cutscene', ped)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetEntityInvincible(ped, true)
        return ped
    end

    function Steps.spawn.prop(a)
        local at = plain(a.at)
        pcall(function() exports['FeloxAC']:CreateObject(joaat(a.model)) end) --[[FeloxAC:auto]]
        local obj = CreateObjectNoOffset(joaat(a.model), at.x, at.y, at.z, false, false, false)
        if obj == 0 then return nil end
        Track.add('cutscene', obj)
        SetEntityHeading(obj, at.w or 0.0)
        FreezeEntityPosition(obj, true)
        return obj
    end

    -- The player: seated in a vehicle actor, or left hidden until a place step shows them.
    function Steps.spawn.player(a, c)
        local me = PlayerPedId()
        if a.seat then
            Steps.show(me)
            SetPedIntoVehicle(me, c.actors[a.seat.actor], a.seat.index or 0)
        end
        return me
    end

    -- Steps ----------------------------------------------------------------------------------------------------------

    -- A keyed move through the Director; the first key cuts in and the area around it streams.
    function Steps.camera(p, c)
        c.updaters.cam = nil
        local keys = {}
        for i, k in ipairs(p.keys) do
            keys[i] = { pos = plain(k.pos), look = plain(k.look), rot = plain(k.rot), fov = k.fov or 40.0, ms = k.ms }
        end
        local first = keys[1]
        SetFocusPosAndVel(first.pos.x, first.pos.y, first.pos.z, 0.0, 0.0, 0.0)
        local pitch, yaw = first.rot and first.rot.x or 0.0, first.rot and first.rot.z or 0.0
        if first.look then pitch, yaw = Steps.lookRot(first.look.x - first.pos.x, first.look.y - first.pos.y, first.look.z - first.pos.z) end
        c.setCam(first.pos.x, first.pos.y, first.pos.z, pitch, yaw, first.fov)
        if #keys > 1 then Director.play({ keys = keys, ms = p.ms or 4000, ease = p.ease or 'smooth' }, { from = 'first' }) end
    end

    -- The camera tracks an actor: mounted on it (offset) or from a fixed place (from; 'camera' keeps where it is now).
    function Steps.follow(p, c)
        local ent = entity(c, p.actor)
        if not ent then return end
        Director.stop()
        local from = p.from == 'camera' and (Rig.pose() or plain(GetFinalRenderedCamCoord())) or plain(p.from)
        local offset, look = plain(p.offset) or { x = 0.0, y = -6.0, z = 2.0 }, plain(p.look) or { x = 0.0, y = 0.0, z = 0.0 }
        local damp = p.damp or (from and 10.0 or 25.0)
        local pos, aim
        SetFocusEntity(ent)
        c.updaters.cam = function(_, dt)
            if not DoesEntityExist(ent) then return true end
            local wantPos = from or GetOffsetFromEntityInWorldCoords(ent, offset.x, offset.y, offset.z)
            local k = pos and (1.0 - math.exp(-dt * damp)) or 1.0
            pos = Steps.mix(pos, wantPos, k)
            aim = Steps.mix(aim, GetOffsetFromEntityInWorldCoords(ent, look.x, look.y, look.z), k)
            local pitch, yaw = Steps.lookRot(aim.x - pos.x, aim.y - pos.y, aim.z - pos.z)
            c.setCam(pos.x, pos.y, pos.z, pitch, yaw, p.fov or 40.0)
        end
    end

    -- Flies or rolls an actor along a spline: heading and pitch from the tangent, bank from the turn rate.
    function Steps.path(p, c)
        local ent = entity(c, p.actor)
        if not ent then return end
        local points = {}
        for i, v in ipairs(p.points) do points[i] = plain(v) end
        local cum, total = Steps.chords(points)
        local lift, start, ms = Steps.lift(ent), GetGameTimer(), math.max(1, p.ms or 5000)
        local nose, noseTo = p.pitch or 0.0, p.pitchTo or p.pitch or 0.0
        local yaw, bank = nil, 0.0
        c.arrived[p.actor] = false
        c.updaters['path:' .. p.actor] = function(now, dt)
            if not DoesEntityExist(ent) then return true end
            local u = Steps.ease(p.ease or 'linear', (now - start) / ms)
            local x, y, z = Steps.sample(points, cum, total, u)
            local pitch, heading = Steps.lookRot(Steps.tangent(points, cum, total, u))
            heading = yaw and Steps.unwrap(yaw, heading) or heading
            bank = Steps.bank(bank, yaw and (heading - yaw) / math.max(dt, 0.001) or 0.0, dt, p.bank)
            yaw = heading
            SetEntityCoordsNoOffset(ent, x, y, z + lift, false, false, false)
            SetEntityRotation(ent, pitch + nose + (noseTo - nose) * u, bank, heading, 2, true)
            return u >= 1.0 and reached(c, p.actor)
        end
    end

    -- Snaps a vehicle onto its target, stopped.
    local function snap(veh, to)
        SetEntityCoords(veh, to.x, to.y, to.z, false, false, false, false)
        if to.w then SetEntityHeading(veh, to.w) end
        SetVehicleOnGroundProperly(veh)
        SetVehicleForwardSpeed(veh, 0.0)
    end

    -- AI drive-to; past the timeout the vehicle snaps onto the target (snap = false lets it drive on).
    function Steps.drive(p, c)
        local veh = entity(c, p.actor)
        local ped = veh and GetPedInVehicleSeat(veh, -1)
        if not ped or ped == 0 then return end
        local to = Steps.target(p, veh)
        local stop, deadline = p.stop or 2.0, GetGameTimer() + (p.timeout or 10000)
        c.arrived[p.actor] = false
        TaskVehicleDriveToCoord(ped, veh, to.x, to.y, to.z, p.speed or 10.0, 0, GetEntityModel(veh), p.style or 2883621, stop, true)
        c.updaters['drive:' .. p.actor] = function(now)
            if not DoesEntityExist(veh) then return true end
            local pos = GetEntityCoords(veh)
            local near = math.sqrt((pos.x - to.x) ^ 2 + (pos.y - to.y) ^ 2) <= stop + 1.5
            if near and GetEntitySpeed(veh) < 1.0 then return reached(c, p.actor) end
            if now < deadline then return false end
            if p.snap ~= false then snap(veh, to) end
            return reached(c, p.actor)
        end
    end

    function Steps.walk(p, c)
        local ped = entity(c, p.ped)
        if not ped then return end
        local to, timeout = plain(p.to), p.timeout or 10000
        local deadline = GetGameTimer() + timeout
        c.arrived[p.ped] = false
        TaskGoStraightToCoord(ped, to.x, to.y, to.z, p.speed or 1.0, timeout, to.w or GetEntityHeading(ped), 0.25)
        c.updaters['walk:' .. p.ped] = function(now)
            local pos = GetEntityCoords(ped)
            local away = math.sqrt((pos.x - to.x) ^ 2 + (pos.y - to.y) ^ 2)
            return (away <= 0.7 or now >= deadline) and reached(c, p.ped)
        end
    end

    function Steps.enter(p, c)
        local ped, veh = entity(c, p.ped), entity(c, p.vehicle)
        if ped and veh then SetPedIntoVehicle(ped, veh, p.seat or 0) end
    end

    function Steps.leave(p, c)
        local ped, veh = entity(c, p.ped), entity(c, p.vehicle)
        if ped and veh then TaskLeaveVehicle(ped, veh, p.flags or 0) end
    end

    -- The dictionary was loaded before the first frame (Cutscene.needs).
    function Steps.anim(p, c)
        local ped = entity(c, p.ped)
        if ped then TaskPlayAnim(ped, p.dict, p.clip, 4.0, -4.0, p.ms or -1, p.flag or 49, 0.0, false, false, false) end
    end

    function Steps.scenario(p, c)
        local ped = entity(c, p.ped)
        if ped then TaskStartScenarioInPlace(ped, p.name, 0, true) end
    end

    -- A prop in a ped's hand, e.g. a suitcase at bone 57005.
    function Steps.prop(p, c)
        local ped = entity(c, p.ped)
        if not ped then return end
        local o, r, at = plain(p.offset) or { x = 0.0, y = 0.0, z = 0.0 }, plain(p.rot) or { x = 0.0, y = 0.0, z = 0.0 }, GetEntityCoords(ped)
        pcall(function() exports['FeloxAC']:CreateObject(joaat(p.model)) end) --[[FeloxAC:auto]]
        local obj = CreateObject(joaat(p.model), at.x, at.y, at.z, false, false, false)
        if obj == 0 then return end
        Track.add('cutscene', obj)
        c.props[#c.props + 1] = obj
        SetEntityCollision(obj, false, false)
        AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, p.bone or 57005), o.x, o.y, o.z, r.x, r.y, r.z, true, true, false, true, 1, true)
    end

    function Steps.gear(p, c)
        local veh = entity(c, p.actor)
        if veh then ControlLandingGear(veh, p.state or 0) end
    end

    function Steps.doors(p, c)
        local veh = entity(c, p.actor)
        if not veh then return end
        for _, i in ipairs(type(p.index) == 'table' and p.index or { p.index or 0 }) do
            if p.open == false then SetVehicleDoorShut(veh, i, false) else SetVehicleDoorOpen(veh, i, false, false) end
        end
    end

    function Steps.lights(p, c)
        local veh = entity(c, p.actor)
        if veh then SetVehicleLights(veh, p.on == false and 1 or 2) end
    end

    -- sfx plays the page's synth sound; name a GTA frontend sound.
    function Steps.sound(p)
        if p.sfx then
            MC.Send('mc:cut:sfx', { name = p.sfx })
        elseif p.name then
            PlaySoundFrontend(-1, p.name, p.set or 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
        end
    end

    function Steps.title(p) MC.Send('mc:cut:title', { key = p.key }) end

    function Steps.subtitle(p) MC.Send('mc:cut:subtitle', { key = p.key, ms = p.ms or 3000 }) end

    function Steps.fade(p)
        if p.out then DoScreenFadeOut(p.out) elseif p['in'] then DoScreenFadeIn(p['in']) end
    end

    -- Streams a place ahead of a cut to it.
    function Steps.focus(p)
        local at = plain(p.at)
        SetFocusPosAndVel(at.x, at.y, at.z, 0.0, 0.0, 0.0)
        RequestCollisionAtCoord(at.x, at.y, at.z)
    end

    -- Moves an actor at once; visible = true brings a hidden player into the scene. A ped waits frozen (3 s at most)
    -- until the ground under it has collision, so it never drops through the map after a cut.
    function Steps.place(p, c)
        local ent = entity(c, p.actor)
        if not ent then return end
        local at, deadline = plain(p.at), GetGameTimer() + 3000
        if p.visible then Steps.show(ent) end
        if ent == PlayerPedId() then pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]] end
        SetEntityCoords(ent, at.x, at.y, at.z, false, false, false, false)
        SetEntityHeading(ent, at.w or 0.0)
        if not IsEntityAPed(ent) then return end
        FreezeEntityPosition(ent, true)
        c.updaters['ground:' .. p.actor] = function(now)
            RequestCollisionAtCoord(at.x, at.y, at.z)
            if now < deadline and not HasCollisionLoadedAroundEntity(ent) then return false end
            FreezeEntityPosition(ent, false)
            return true
        end
    end

    function Steps.wait(p, c) c.wait(p['until'], p.timeout or 5000) end

    function Steps.done(p, c) c.finish('done', p.blend) end

    -- A wait condition: arrived:<actor> (drive, walk or path over), exited:<ped>, entered:<ped>.
    function Steps.holds(c, cond)
        local kind, name = tostring(cond):match('^(%a+):([%w_]+)$')
        if kind == 'arrived' then return c.arrived[name] == true end
        local ped = name and entity(c, name)
        if kind == 'exited' then return not ped or not IsPedInAnyVehicle(ped, false) end
        if kind == 'entered' then return ped ~= nil and IsPedInAnyVehicle(ped, false) end
        return true
    end
end
