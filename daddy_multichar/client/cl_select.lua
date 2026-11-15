-- From the loading screen to the first picture: the server says where the player stands, the page and the first view
-- get ready behind black, and only then the loading screen goes.
do
    Boot = {}
    local running, covered = false, false
    -- Server answers worth asking again (still starting, another call in flight, rate limited).
    local RETRY = { busy = true, not_ready = true, rate = true }

    function Boot.busy()
        return running
    end

    -- The page's loading bar (0..100); it shows 'press any key' at 100. Never goes back within one load.
    local loaded = -1
    function Boot.load(progress)
        progress = math.floor(CamMath.clamp(tonumber(progress) or 0, 0, 100))
        if progress <= loaded and progress > 0 then return end
        loaded = progress < 100 and progress or -1
        MC.Send('mc:core:load', { progress = progress })
    end

    -- True when a 'boot' reply plays the intro.
    function Boot.introPlays(reply)
        return type(reply) == 'table' and reply.intro == true and type(reply.introScene) == 'table'
    end

    -- The poster's top labels: season, version, online count and the title (mc:core:intro).
    function Boot.introData()
        local cfg, info = Config.Intro or {}, type(MC.session) == 'table' and MC.session.introInfo or nil
        info = type(info) == 'table' and info or {}
        local online = cfg.ShowOnline ~= false and tonumber(info.online) or nil
        local profile = type(MC.session) == 'table' and type(MC.session.profile) == 'table' and MC.session.profile or nil
        return { season = cfg.Season or '', version = cfg.Version or '', online = online, max = online and tonumber(info.max) or nil,
            kicker = cfg.Kicker or '', title = cfg.Title or '', awaits = cfg.Awaits ~= false, profile = profile }
    end

    -- The server's 'boot' reply, asked again every 2 s while it says busy or not ready.
    function Boot.ask(totalMs)
        local stop = GetGameTimer() + (totalMs or 60000)
        local reply = MC.server('boot', 15000)
        while not reply.ok and RETRY[reply.error] and GetGameTimer() < stop do
            Wait(2000)
            reply = MC.server('boot', 15000)
        end
        return reply
    end

    -- The loading screen goes once, and only when it was up as the boot began (not after a restart mid-game).
    function Boot.closeLoading()
        if not covered then return end
        covered = false
        Bridge.chars.closeLoadingScreen()
    end

    function Boot.hide()
        MC.fadeOut(0)
        Player.hide()
    end

    -- The scene's first camera key, rendered behind black with the map streamed around it.
    function Boot.firstView(scene)
        local shots = type(scene) == 'table' and scene.shots or nil
        local key = shots and shots.establish and shots.establish.keys[1]
        if not key then return false end
        local pose = SceneSchema.pose(scene.anchor, key)
        local dx, dy, dz = SceneSchema.forward(pose.rx, pose.rz)
        Env.apply(scene)
        Player.place({ x = pose.x, y = pose.y, z = pose.z - 30.0, w = 0.0 })
        Boot.load(55)
        Stream.view(pose, { x = dx, y = dy, z = dz }, 900.0, 8000)
        Boot.load(85)
        Rig.start(pose)
        Boot.load(90)
        return true
    end

    -- The server could not answer: the error card (or a notification without the page) with a way out.
    function Boot.failed(reply)
        Boot.closeLoading()
        local key = 'errors.' .. tostring(reply.error or 'not_ready')
        local actions = Config.Selection.AllowQuit and { 'retry', 'quit' } or { 'retry' }
        if Nui.awaitAlive(2000) and Nui.error(key, {}, actions) then return Nui.input('ui') end
        lib.notify({ description = Core.locale.t(key), type = 'error', duration = 15000 })
    end

    -- The error card's Retry (mc:core:boot { retry = true }): ask the server again and follow its answer.
    function Boot.retry()
        if running then return end
        running = true
        MC.bump()
        local reply = Boot.ask(30000)
        running = false
        if not reply.ok then return Boot.failed(reply) end
        Boot.follow(reply)
    end

    -- A character already plays (a restart mid-game): give the screen and the player back, nothing else.
    function Boot.playing()
        Env.restore()
        Rig.release()
        MC.try(Spawn.reset)
        MC.try(Spawn.hud, false)
        if IsNewLoadSceneActive() then NewLoadSceneStop() end
        ClearFocus()
        State.set('playing')
        Boot.closeLoading()
        Nui.close()
        if Player.hidden() then Player.release() end
        Links.suppress(false)
        if IsScreenFadedOut() or IsScreenFadingOut() then DoScreenFadeIn(500) end
    end

    -- A misconfigured server: players get the SETUP INCOMPLETE card (admins the lines too), never a black screen.
    function Boot.setup(info)
        info = type(info) == 'table' and info or {}
        Boot.closeLoading()
        if Nui.open('setup', { admin = info.admin == true, lines = info.lines }) then return Nui.input('ui') end
        lib.alertDialog({ header = Core.locale.t('safemode.setup_title'), content = Core.locale.t('safemode.setup'), centered = true })
    end

    -- The server is still busy with this player (a login, a spawn): ask again every 5 s for half a minute.
    function Boot.wait(state)
        local gen = MC.gen
        Nui.transition('loading', { eyebrow = Core.locale.t('client.loading_eyebrow') })
        for _ = 1, 6 do
            Wait(5000)
            if gen ~= MC.gen then return end
            local reply = Boot.ask(15000)
            if not reply.ok or reply.state ~= state or reply.step then return Boot.follow(reply) end
        end
        Boot.failed({ error = 'not_ready' })
    end

    local function pedGender()
        return GetEntityModel(PlayerPedId()) == GetHashKey('mp_f_freemode_01') and 'f' or 'm'
    end

    -- Mid-flow states a reply names without a step: the cutscene ends, the wardrobe opens again, the rest waits.
    local function midway(reply)
        if reply.state == 'cutscene' then return Flow.step(MC.server('cutsceneDone', 15000), { isNew = true }) end
        if reply.state == 'appearance' then return Create.wardrobe(pedGender(), false) end
        return Boot.wait(reply.state)
    end

    -- Where a 'boot' reply leads: setup, a resumed step, the game, the intro, the selection or a flow in progress.
    function Boot.follow(reply, opts)
        if not reply.ok then return Boot.failed(reply) end
        MC.session = reply
        local step = reply.step
        if reply.setup or (type(step) == 'table' and step.step == 'setup') then return Boot.setup(type(reply.setup) == 'table' and reply.setup or step) end
        if type(step) == 'table' then return Flow.step(step, { isNew = step.isNew == true }) end
        if reply.state == 'playing' then return Boot.playing() end
        if reply.state ~= 'intro' and reply.state ~= 'select' then return midway(reply) end
        if Boot.introPlays(reply) then return Intro.run(reply, opts) end
        return Select.open(reply, { credits = true })
    end

    -- The framework's client-side checks (ESX without Config.Multichar on this client): printed, and the setup card shows.
    local function clientSetup(reply)
        local ok, found = pcall(Bridge.chars.conflicts)
        local lines = {}
        for _, item in ipairs(ok and type(found) == 'table' and found or {}) do
            local fatal = item.level == 'error'
            if fatal then lines[#lines + 1] = item.text end
            print(('%s %s: %s^7'):format(fatal and '^1CONFIG ERROR^7' or '^3CONFIG WARNING^7', tostring(item.code), tostring(item.text)))
        end
        if #lines == 0 or reply.setup then return end
        reply.setup, reply.step = true, { step = 'setup', admin = reply.isAdmin == true, lines = reply.isAdmin and lines or nil }
    end

    local function start(reply)
        if not reply.ok then return Boot.failed(reply) end
        if reply.state == 'playing' and not reply.step then return Boot.playing() end
        clientSetup(reply)
        Boot.hide()
        -- Without the page's hello the open is sent anyway: the hello can be lost while the page itself works, and only
        -- a first screen that never draws (Nui.open sends it once more) hands the player to the plain menus. The
        -- loading screen goes first then: on a first join (empty cache) it can be what holds the page back.
        if not Nui.awaitAlive(Config.Boot.NuiMs or 10000) then
            print('^3[daddy_multichar] the page did not say hello in time; closing the loading screen and opening it anyway^7')
            Boot.closeLoading()
        end
        local intro = Boot.introPlays(reply)
        Nui.open(intro and 'intro' or 'transition', {})
        Boot.load(20)
        if not Nui.awaitReady(Nui.readyBudget()) then return Nui.fail('the first screen did not render') end
        Boot.load(35)
        Wait(0)
        Wait(0)
        Boot.closeLoading()
        if not (reply.step or reply.setup) then Boot.firstView(intro and reply.introScene or reply.scene) end
        Boot.load(90)
        Boot.follow(reply, { prepared = true })
    end

    -- Runs once per resource start, from client/cl_main.lua.
    function Boot.run()
        if running then return end
        running = true
        while not NetworkIsPlayerActive(PlayerId()) do Wait(100) end
        MC.loadPrefs()
        Look.load()
        Bridge.chars.boot()
        covered = GetIsLoadingScreenActive()
        if covered then Boot.hide() end
        local reply = Boot.ask(60000)
        if reply.ok then MC.session = reply end
        start(reply)
        running = false
    end

    -- The opening titles: the 'intro' scene's shots over the city until a key, a click or a pad button, then the selection.
    -- The Director plays reduced and off motion as still holds on each shot's first key (a short dip or a hard cut).
    Intro = {}
    local promptAt, continued, finished = nil, false, false

    -- The shots as world-space moves split at the cut keys; the first one opens on the fade-in, every later one cuts.
    local function moves(scene)
        local list = SceneSchema.cuts(scene.shots.establish)
        for i, move in ipairs(list) do
            for k, key in ipairs(move.keys) do move.keys[k] = SceneSchema.worldKey(scene.anchor, key) end
            move.cut = i > 1
        end
        return list
    end

    local function play(scene, loop)
        local list = moves(scene)
        finished = #list == 0
        if finished then return end
        Director.playList(list, { loop = loop, dipMs = 600, onDone = function() finished = true end })
    end

    local function stop()
        Director.stop()
        ClearFocus()
    end

    local function show(scene)
        local cfg = Config.Intro
        local own = scene.music ~= nil and scene.music ~= ''
        MC.Send('mc:intro:show', {
            logo = cfg.Logo, title = cfg.Title, music = own and scene.music or cfg.Music, volume = own and scene.volume or cfg.Volume,
            minMs = cfg.MinMs, skippable = cfg.Skippable ~= false,
        })
    end

    -- Waits for the player after MinMs (the prompt shows then), or for the end of one pass when it cannot be skipped.
    local function await(gen)
        local skippable = Config.Intro.Skippable ~= false
        local prompted = false
        promptAt, continued = GetGameTimer() + math.max(0, tonumber(Config.Intro.MinMs) or 0), false
        while not continued and gen == MC.gen and (skippable or not finished) do
            if skippable and not prompted and GetGameTimer() >= promptAt then
                prompted = true
                Boot.load(100)
                MC.Send('mc:intro:prompt', {})
            end
            Wait(100)
        end
        promptAt = nil
        return gen == MC.gen
    end

    -- opts.prepared: the boot already streamed the first view and started the camera.
    function Intro.run(session, opts)
        local scene = session.introScene
        if Nui.failed() or type(scene) ~= 'table' then return Select.open(session, { credits = true }) end
        local gen = MC.gen
        State.set('intro')
        Links.suppress(true)
        if Nui.current() ~= 'intro' then Nui.open('intro', {}) end
        if not (opts and opts.prepared) then
            MC.fadeOut(300)
            Boot.load(0)
            Boot.firstView(scene)
        end
        play(scene, Config.Intro.Skippable ~= false)
        show(scene)
        Nui.input('ui')
        DoScreenFadeIn(1200)
        if not await(gen) then return stop() end
        MC.fadeOut(700)
        stop()
        Select.open(session, { credits = true })
    end

    MC.Callback('mc:intro:continue', function()
        if not promptAt or GetGameTimer() < promptAt or Config.Intro.Skippable == false then return { ok = false, error = 'state' } end
        continued = true
        return { ok = true }
    end)

    -- The watchdog's target: stop whatever is stuck, ask the server ('boot') where the player stands and follow it.
    -- It never fires spawned events; only the server's answer decides.
    Recover = {}
    local busy, history = false, {}

    -- More than three recoveries within a minute will not get better: the error card stays instead.
    local function tooMany()
        local now, kept = GetGameTimer(), {}
        for _, at in ipairs(history) do
            if now - at < 60000 then kept[#kept + 1] = at end
        end
        kept[#kept + 1] = now
        history = kept
        return #kept > 3
    end

    -- Stops the switch, cameras, cutscene and scene, gives the weather back and hides the player behind black.
    function Recover.teardown()
        if IsPlayerSwitchInProgress() then StopPlayerSwitch() end
        MC.fadeOut(300)
        MC.try(Bridge.appearance.cancel)
        MC.try(Cutscene and Cutscene.abort)
        MC.try(Director and Director.stop)
        MC.try(Select.close)
        MC.try(Rig and Rig.release)
        MC.try(Spawn.reset, true)
        Env.restore()
        Player.hide()
    end

    function Recover.run(state, reason)
        if busy then return end
        busy = true
        print(('^3[daddy_multichar] recovering from %s (%s)^7'):format(tostring(state), tostring(reason)))
        MC.bump()
        Recover.teardown()
        Nui.toast('client.recovering', 'info')
        local reply = tooMany() and { ok = false, error = 'not_ready' } or Boot.ask(30000)
        busy = false
        if not reply.ok then return Boot.failed(reply) end
        Boot.follow(reply)
    end

    -- When the page fails (web/dist missing or broken), characters are picked from plain ox_lib menus: play, create and
    -- the spawn point. The server calls and checks are the same; there is no cutscene and every spawn fades.
    Safemode = {}
    local MENU, SPAWN_MENU = 'daddy_multichar:safemode', 'daddy_multichar:safemode:spawn'
    local running, cards = false, {}
    local t = function(key, ...) return Core.locale.t(key, ...) end

    local function notify(code)
        lib.notify({ description = t('errors.' .. tostring(code or 'invalid')), type = 'error' })
    end

    local function today()
        -- FiveM's client Lua has no os library; the game clock of the PC is used instead.
        local y, m, d = GetLocalTime()
        return y and ('%04d-%02d-%02d'):format(y, m, d) or nil
    end

    local function nations()
        local out = {}
        for _, code in ipairs(Config.Identity.Nationalities or {}) do out[#out + 1] = { value = code, label = t('nation.' .. code) } end
        return out
    end

    -- The casting sheet as one input dialog; nil when the player backs out.
    local function ask()
        local cfg = Config.Identity
        local order = cfg.DateFormat or 'DMY'
        local rows = {
            { type = 'input', label = t('safemode.firstname'), required = true, min = cfg.NameMin, max = cfg.NameMax },
            { type = 'input', label = t('safemode.lastname'), required = true, min = cfg.NameMin, max = cfg.NameMax },
            { type = 'input', label = t('safemode.birthdate'), placeholder = t('safemode.date_' .. order:lower()), required = true },
            { type = 'select', label = t('safemode.gender'), required = true, options = { { value = 'm', label = t('safemode.male') }, { value = 'f', label = t('safemode.female') } } },
            { type = 'select', label = t('safemode.nationality'), required = true, searchable = true, options = nations() },
            { type = 'number', label = t('safemode.height'), required = true, min = cfg.HeightMin, max = cfg.HeightMax, default = cfg.HeightDefault },
        }
        if (tonumber(cfg.BioMax) or 0) > 0 then rows[#rows + 1] = { type = 'textarea', label = t('safemode.bio'), max = cfg.BioMax } end
        local v = lib.inputDialog(t('safemode.create'), rows)
        if not v then return nil end
        return { firstname = v[1], lastname = v[2], birthdate = Bridge.chars.isoDate(v[3], order) or tostring(v[3]), gender = v[4],
            nationality = v[5], height = tonumber(v[6]), bio = v[7] or '' }
    end

    local function play(index)
        local reply = MC.server('play', 30000, { index = index })
        if not reply.ok then
            notify(reply.error)
            return Safemode.menu(cards)
        end
        running = false
        Player.reset()
        Bridge.appearance.applyPlayer({ model = reply.model, skin = reply.skin, format = reply.format })
        Player.hide()
        Flow.step(reply, { isNew = false })
    end

    -- The sheet until it passes here and on the server, or the player backs out (the slot is given back).
    local function create(index)
        local reply = MC.server('startCreate', 10000, { index = index })
        if not reply.ok then
            notify(reply.error)
            return Safemode.menu(cards)
        end
        while true do
            local identity = ask()
            if not identity then
                MC.server('cancelCreate', 10000)
                return Safemode.menu(cards)
            end
            local ok, _, code = IdentityRules.check(identity, Config.Identity, today())
            reply = ok and MC.server('create', 30000, { identity = identity }) or { ok = false, error = code }
            if reply.ok then
                running = false
                return Flow.step(reply, { isNew = true })
            end
            notify(reply.error)
        end
    end

    local function option(index, card)
        local name = ('%s %s'):format(card.firstname or '', card.lastname or '')
        local function run(fn) return function() CreateThread(function() fn(index) end) end end
        if card.kind == 'empty' then return { title = t('safemode.new'), icon = 'user-plus', onSelect = run(create) } end
        if card.kind == 'locked' then return { title = t('safemode.locked'), icon = 'lock', disabled = true } end
        if card.kind == 'deceased' then return { title = name, description = t('safemode.deceased'), icon = 'cross', disabled = true } end
        if card.readonly then return { title = name, description = t('safemode.readonly'), icon = 'lock', disabled = true } end
        local job = type(card.job) == 'table' and card.job.label or nil
        return { title = name, description = card.pendingDelete and t('safemode.pending') or job, icon = 'user', onSelect = run(play) }
    end

    -- The character list; it cannot be closed, only left through a choice (or the quit line).
    function Safemode.menu(list)
        cards = type(list) == 'table' and list or {}
        local options = {}
        for index, card in ipairs(cards) do options[#options + 1] = option(index, card) end
        if Config.Selection.AllowQuit then
            options[#options + 1] = { title = t('safemode.quit'), icon = 'door-open', onSelect = function() CreateThread(function() MC.server('disconnect', 10000) end) end }
        end
        lib.registerContext({ id = MENU, title = t('safemode.title'), canClose = false, options = options })
        lib.showContext(MENU)
    end

    -- The spawn_select step without the page.
    function Safemode.spawn(points)
        if Config.Safemode == 'reload' then return Nui.reload('safemode spawn') end
        local options = {}
        for _, point in ipairs(type(points) == 'table' and points or {}) do
            local id = point.id
            options[#options + 1] = { title = tostring(point.label or id), icon = 'location-dot', onSelect = function()
                CreateThread(function()
                    local reply = MC.server('spawn', 15000, { id = id })
                    if not reply.ok then
                        notify(reply.error)
                        return Safemode.spawn(points)
                    end
                    Flow.step(reply)
                end)
            end }
        end
        lib.registerContext({ id = SPAWN_MENU, title = t('safemode.spawn_title'), canClose = false, options = options })
        lib.showContext(SPAWN_MENU)
    end

    -- Takes over the selection: black screen, hidden player, the server's cards in a menu.
    function Safemode.run(session)
        -- Config.Safemode = 'reload': the page is reloaded instead; these menus never show.
        if Config.Safemode == 'reload' then
            if type(session) == 'table' then MC.session = session end
            return Nui.reload('safemode')
        end
        if running then return end
        running = true
        if type(session) == 'table' then MC.session = session end
        print('^3[daddy_multichar] safemode: characters are picked from the plain menu^7')
        Boot.closeLoading()
        MC.try(Select.close)
        MC.try(Rig and Rig.release)
        MC.fadeOut(0)
        Player.hide()
        Frame.on('hud', Frame.hud)
        Links.suppress(true)
        State.set('select')
        local reply = MC.server('enter', 15000)
        if reply.ok then return Safemode.menu(reply.cards) end
        running = false
        Recover.run('select', reply.error)
    end
end

-- The selection: the scene with the cast, the page's callbacks and sheets, Play, and every step a server reply names
-- (Flow.step). Cards are addressed by index only; the server maps them to characters.
do
    Select = {}
    local view -- { scene, cards, slots, previews, page, focused, seq, touched, busy } while the selection is up
    -- Single mode builds a page's characters at one spot; one page is one previews call (the server sends ten at most).
    local SINGLE_PAGE = 10
    local REVEAL_MS = 300 -- after a relog the cast settles under the black this long before the red wipes it open
    local STEPS = {}

    local function isIndex(value)
        return type(value) == 'number' and value >= 1 and value == math.floor(value)
    end

    local function pageSize(v)
        if v.scene.mode == 'lineup' then return math.max(1, #v.scene.spots) end
        return SINGLE_PAGE
    end

    local function pageOf(v, index)
        return math.floor((index - 1) / pageSize(v)) + 1
    end

    local function pageCount(v)
        return math.max(1, math.ceil(#v.cards / pageSize(v)))
    end

    local function cardAt(index)
        return view and not view.opening and isIndex(index) and view.cards[index] or nil
    end

    local function fullName(card)
        return ('%s %s'):format(card.firstname or '', card.lastname or '')
    end

    -- The page's looks not cached yet, handed to Scene.open and Scene.refresh (a page turn fetches its own).
    local function fetchPreviews(v, page)
        local size, wanted = pageSize(v), {}
        for index = (page - 1) * size + 1, math.min(page * size, #v.cards) do
            if v.cards[index].kind == 'character' and v.previews[index] == nil and #wanted < 10 then wanted[#wanted + 1] = index end
        end
        if #wanted == 0 then return end
        local reply = MC.server('previews', 15000, { indexes = wanted })
        if not reply.ok or type(reply.list) ~= 'table' then return end
        for index, preview in pairs(reply.list) do v.previews[tonumber(index)] = preview end
    end

    local function sendCast(v)
        MC.Send('mc:select:cast', { cards = v.cards, slots = v.slots, page = v.page, pages = pageCount(v), focused = v.focused })
    end

    -- The credits roll with the establishing move; then the camera finds the first card unless the player moved first.
    local function rollThenFocus(v, ms)
        CreateThread(function()
            local stop = GetGameTimer() + ms
            while view == v and not v.touched and GetGameTimer() < stop do Wait(100) end
            if view == v and not v.touched then Select.focus(v.focused) end
        end)
    end

    -- A scene that streams too slowly comes in anyway: the black of one build never outlasts BUILD_MS.
    local BUILD_MS = 20000
    local function budget(v)
        v.build = (v.build or 0) + 1
        local mine = v.build
        CreateThread(function()
            local stop = GetGameTimer() + BUILD_MS
            while view == v and v.build == mine and GetGameTimer() < stop do Wait(250) end
            if view == v and v.build == mine and State.is('select') and (IsScreenFadedOut() or IsScreenFadingOut()) then DoScreenFadeIn(500) end
        end)
        return function() if v.build == mine then v.build = mine + 1 end end
    end

    -- The server's pick swapped for the focused card's own scene before the first build.
    local function ownScene(session, card)
        local id = Look.target(card)
        if not id or id == session.scene.id then return end
        local reply = MC.server('look', 10000, { scene = id })
        if reply.ok and type(reply.scene) == 'table' then session.scene = reply.scene end
    end

    local function build(session, reply, opts)
        local v = { scene = session.scene, cards = reply.cards or {}, slots = reply.slots, previews = {}, seq = 0 }
        v.focused = isIndex(reply.focus) and v.cards[reply.focus] and reply.focus or 1
        v.page = pageOf(v, v.focused)
        view = v
        Look.load()
        ownScene(session, v.cards[v.focused])
        if view ~= v then return end
        v.scene = session.scene
        v.page = pageOf(v, v.focused)
        fetchPreviews(v, v.page)
        Boot.load(100)
        Nui.open('select', { frame = Select.frame() })
        MC.Send('mc:select:busy', { on = false })
        sendCast(v)
        Crew.send()
        local built = budget(v)
        Scene.open(v.scene, v.cards, v.previews, v.page)
        built()
        if view ~= v then return end
        Look.focused(v.cards[v.focused], true)
        Look.push()
        Crew.place()
        local ms = v.scene.shots.establish.ms
        if opts.credits then MC.Send('mc:scene:credits', { ms = ms }) end
        Nui.input('ui')
        DoScreenFadeIn(900)
        MC.emit('onSelection')
        TriggerEvent('daddy_multichar:client:selection')
        rollThenFocus(v, ms)
    end

    -- Config.Selection.SkipSingle: the one playable character of an account, when it has exactly one.
    local function single(cards)
        local found
        for _, card in ipairs(type(cards) == 'table' and cards or {}) do
            if card.kind == 'character' then
                if found or card.readonly then return nil end
                found = card
            end
        end
        return found
    end

    -- Opens the selection for a 'boot' reply (session.scene); when it is already up, only the cards refresh.
    function Select.open(session, opts)
        if view then return Select.reload() end
        if Nui.failed() then return Safemode.run(session) end
        view = { opening = true }
        local gen = MC.gen
        State.set('select')
        Links.suppress(true)
        local reply = MC.server('enter', 15000)
        if gen ~= MC.gen then view = nil return end
        if not reply.ok or type(session.scene) ~= 'table' then
            view = nil
            return Recover.run('select', reply.error or 'invalid')
        end
        local only = (Config.Selection or {}).SkipSingle == true and (opts or {}).credits and single(reply.cards)
        if only then
            view = nil
            return Select.play(only.index, only)
        end
        local ok, err = pcall(build, session, reply, opts or {})
        if ok then return end
        print(('^1[daddy_multichar] selection: %s^7'):format(tostring(err)))
        view = nil
        MC.try(Scene.destroy)
        Recover.run('select', 'invalid')
    end

    function Select.active()
        return view ~= nil
    end

    -- The side the session's scene frames the actor on; the page puts its texts on the other side.
    function Select.frame()
        local scene = type(MC.session) == 'table' and MC.session.scene or nil
        return type(scene) == 'table' and scene.frame or 'right'
    end

    -- Ends the selection's scene; the page stays for whatever comes next.
    function Select.close()
        local v = view
        view = nil
        Look.reset()
        if v and not v.opening then Scene.destroy() end
    end

    -- The cards of the selection (empty when it is closed).
    function Select.cards()
        return view and view.cards or {}
    end

    -- The focused card, or nil.
    function Select.card()
        return view and not view.opening and view.cards[view.focused] or nil
    end

    function Select.touch()
        if view then view.touched = true end
    end

    -- The player picked another scene: a black cut of cutMs, the scene rebuilt there with the same card in focus.
    function Select.swapScene(scene, cutMs, side)
        local v = view
        if not v or v.opening or type(scene) ~= 'table' then return false end
        v.touched = true
        MC.fadeOut(cutMs)
        if view ~= v then return false end
        local built = budget(v)
        MC.session.scene, v.scene = scene, scene
        -- The cards did not change: the cast (with its portraits) goes to the page again only on another page.
        local page = pageOf(v, v.focused)
        fetchPreviews(v, page)
        if page ~= v.page then
            v.page = page
            sendCast(v)
        end
        Scene.open(scene, v.cards, v.previews, v.page, { focus = v.focused, side = side })
        built()
        if view ~= v then return false end
        Look.focused(v.cards[v.focused], true)
        Crew.place()
        DoScreenFadeIn(cutMs)
        return true
    end

    -- New cards from the server (a sheet, a grant, an admin): indexes may now point at other characters.
    function Select.update(cards, slots)
        local v = view
        if not v or v.opening or type(cards) ~= 'table' then return end
        v.cards, v.slots, v.previews = cards, slots or v.slots, {}
        v.page = math.min(v.page, pageCount(v))
        if not v.cards[v.focused] then v.focused = 1 end
        fetchPreviews(v, v.page)
        if view ~= v then return end
        sendCast(v)
        Scene.refresh(v.cards, v.previews)
    end

    function Select.reload()
        if not view or view.opening then return end
        local reply = MC.server('cards', 10000)
        if reply.ok then Select.update(reply.cards, reply.slots) end
    end

    -- A page change ("reel change"): the scene rebuilds it under a dip and fetches the page's looks itself.
    function Select.page(n)
        local v = view
        if not v or v.opening or not isIndex(n) or n > pageCount(v) then return false end
        if n == v.page then return true end
        v.page = n
        Scene.page(n)
        return true
    end

    -- Moves the camera to a card (the scene turns the page when needed); returns the page it is on.
    function Select.focus(index)
        if not cardAt(index) then return nil end
        local v = view
        local target = Look.target(v.cards[index])
        local scene = type(MC.session) == 'table' and MC.session.scene or nil
        local moving = target ~= nil and type(scene) == 'table' and target ~= scene.id
        local page = (not moving and Scene.focus(index)) or pageOf(v, index)
        v.focused, v.page = index, page
        MC.Send('mc:select:focused', { index = index })
        Look.focused(v.cards[index])
        Crew.focus(index)
        return page
    end

    -- Back on the selection after a failed Play, with the reason as a toast.
    local function back(code)
        if view then view.busy = false end
        State.set('select')
        Nui.screen('select', { frame = Select.frame() })
        if view then sendCast(view) end
        MC.Send('mc:select:busy', { on = false })
        Nui.toast('errors.' .. tostring(code or 'invalid'), 'error')
    end

    -- Play: the server logs the character in; the ped is reset, dressed and hidden, then the reply's step runs.
    function Select.play(index, card)
        local gen = MC.gen
        State.set('loading')
        MC.Send('mc:select:busy', { on = true })
        Nui.transition('loading', { eyebrow = Core.locale.t('client.loading_eyebrow'), title = fullName(card), sub = Core.locale.t('client.loading_sub') })
        local reply = MC.server('play', 30000, { index = index })
        if gen ~= MC.gen then return end
        if not reply.ok then return back(reply.error) end
        Look.snapshot()
        Spawn.played(card)
        Relog.cast(card.firstname, card.lastname)
        MC.fadeOut(500)
        Select.close()
        Player.reset()
        Bridge.appearance.applyPlayer({ model = reply.model, skin = reply.skin, format = reply.format })
        Player.hide()
        Flow.step(reply, { isNew = false })
    end

    -- The server's 'open' push: the only way back into the selection (relog, forced, logout, resume).
    function Select.reopen(data)
        if Boot.busy() then return end
        if view then return Select.reload() end
        if State.is('playing') then Relog.forced(data.reason) end
        Relog.settle(12000)
        MC.bump()
        Recover.teardown()
        local reply = Boot.ask(30000)
        if not reply.ok then return Boot.failed(reply) end
        MC.session = reply
        if data.intro == true and type(reply.introScene) == 'table' then
            SetTimeout(REVEAL_MS, Relog.reveal)
            return Intro.run(reply)
        end
        Select.open(reply, { credits = true })
        Wait(REVEAL_MS)
        Relog.reveal()
    end

    -- Runs the step a reply names: appearance | cutscene | spawn_select | spawning | handoff | setup.
    function Flow.step(reply, opts)
        if type(reply) ~= 'table' or reply.ok == false then return Recover.run(State.get(), type(reply) == 'table' and reply.error or 'invalid') end
        local run = STEPS[reply.step]
        if not run then return Recover.run(State.get(), 'invalid') end
        return run(reply, opts or {})
    end

    -- A step the server pushes (resume, a forced spawn): whatever ran before stops first.
    function Flow.force(step)
        if Boot.busy() or (step.step == 'spawning' and Spawn.busy()) then return end
        if step.step == 'spawn_select' and SpawnSelect.active() then return SpawnSelect.relock(step.lock) end
        MC.bump()
        -- A crew member waiting on the selector goes straight to the entry card (the leader's point fanned out).
        if step.step == 'spawning' and SpawnSelect.active() then return Flow.step(step, { isNew = step.isNew == true }) end
        Recover.teardown()
        Flow.step(step, { isNew = step.isNew == true })
    end

    function STEPS.appearance(step, opts)
        return Create.wardrobe(step.gender, opts.isNew == true)
    end

    -- The arrival cutscene (none in safemode), then the server's spawning step.
    function STEPS.cutscene(step, opts)
        local gen = MC.gen
        State.set('cutscene')
        if not Nui.failed() then
            Nui.open('cutscene', { id = step.id })
            Cutscene.play(step.id)
        end
        if gen ~= MC.gen then return end
        local reply = MC.server('cutsceneDone', 15000)
        if gen ~= MC.gen then return end
        Flow.step(reply, opts)
    end

    function STEPS.spawn_select(step)
        State.set('spawn_select')
        if Nui.failed() then return Safemode.spawn(step.points) end
        Nui.open('spawn', {})
        if not SpawnSelect.open(step.points, step.lock == true) then Recover.run('spawn_select', 'bad_spawn') end
    end

    -- Spawn.finish runs the transition, the spawned events, the server's 'spawned' and the move to playing.
    function STEPS.spawning(step)
        State.set('spawning')
        if Nui.failed() then step.transition = 'fade' end
        Spawn.finish(step)
    end

    function STEPS.handoff(step)
        State.set('spawning')
        Spawn.handoff(step.isNew == true, step.apartment == true)
    end

    function STEPS.setup(step)
        return Boot.setup(step)
    end

    MC.Callback('mc:select:focus', function(data)
        if not cardAt(data.index) then return { ok = false, error = 'invalid' } end
        view.touched = true
        local page = Select.focus(data.index)
        return { ok = page ~= nil, page = page }
    end)

    -- Hover from the page's hit boxes; an older sequence number than the last one seen is dropped.
    MC.Callback('mc:select:hover', function(data)
        local seq = tonumber(data.seq) or 0
        if not view or view.opening or seq <= view.seq then return { ok = true } end
        view.seq = seq
        if data.index ~= nil and not cardAt(data.index) then return { ok = false, error = 'invalid' } end
        Scene.hover(data.index)
        return { ok = true }
    end)

    MC.Callback('mc:select:page', function(data)
        if not Select.page(data.page) then return { ok = false, error = 'invalid' } end
        return { ok = true, page = data.page }
    end)

    -- A character's idle pose: the server stores it, then the actor takes it at once.
    MC.Callback('mc:select:setPose', function(data)
        local card = cardAt(data.index)
        if not card or card.kind ~= 'character' or not Look.knownPose(data.pose) then return { ok = false, error = 'invalid' } end
        local reply = MC.server('pose', 10000, { index = data.index, pose = data.pose })
        if not reply.ok then return { ok = false, error = reply.error } end
        card.pose = reply.pose
        Scene.repose(data.index, reply.pose)
        Nui.toast('pose.saved', 'success')
        return { ok = true, pose = reply.pose }
    end)

    -- Answers at once; the screens move on through pushes (the login can take longer than a page call may wait).
    MC.Callback('mc:select:play', function(data)
        local card = cardAt(data.index)
        if not card or card.kind ~= 'character' or card.readonly then return { ok = false, error = 'locked' } end
        if view.busy or not State.is('select') then return { ok = false, error = 'busy' } end
        view.busy = true
        CreateThread(function() Select.play(data.index, card) end)
        return { ok = true }
    end)

    local function text(value, max)
        return type(value) == 'string' and #value <= max and value or nil
    end

    -- A sheet's server call; new cards refresh the cast and the scene.
    local function sheet(name, data)
        if not view or view.opening then return { ok = false, error = 'state' } end
        local reply = MC.server(name, 10000, data)
        if reply.ok and type(reply.cards) == 'table' then CreateThread(function() Select.update(reply.cards, reply.slots) end) end
        return { ok = reply.ok == true, error = reply.error, field = reply.field }
    end

    -- The confirm box: player mode deletes, request mode asks staff (Config.Delete.Mode).
    MC.Callback('mc:delete:confirm', function(data)
        local mode = (Config.Delete or {}).Mode
        if not cardAt(data.index) then return { ok = false, error = 'invalid' } end
        if mode == 'player' then return sheet('delete', { index = data.index }) end
        if mode == 'request' then return sheet('requestDelete', { index = data.index }) end
        return { ok = false, error = 'locked' }
    end)

    -- Where the focused character stands on screen, from just over the head to the waist, as shares of the screen; the
    -- page crops its portrait there (the cards' 240x312 shape). A close camera may cut the hair or the waist off the
    -- screen: the frame's edge stands in for them; only a head off screen fails.
    local HEAD, PELVIS = 31086, 11816
    local function onScreen(pos)
        local on, x, y = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)
        return on, x, y
    end

    MC.Callback('mc:picture:frame', function(data)
        local index = tonumber(data.index)
        if not view or not index or Scene.current() ~= index then return { ok = false, error = 'invalid' } end
        local ped = Scene.actor(index)
        if not ped or not DoesEntityExist(ped) or not IsEntityAPed(ped) then return { ok = false, error = 'invalid' } end
        local head = GetPedBoneCoords(ped, HEAD, 0.0, 0.0, 0.0)
        local waist = GetPedBoneCoords(ped, PELVIS, 0.0, 0.0, 0.0)
        local headOn, x, headY = onScreen(head)
        if not headOn then return { ok = false, error = 'offscreen' } end
        local topOn, _, top = onScreen(head + vector3(0.0, 0.0, 0.28))
        local bottomOn, _, bottom = onScreen(waist)
        if not topOn then top = 0.0 end
        if not bottomOn or bottom <= headY then bottom = 1.0 end
        local sw, sh = GetActiveScreenResolution()
        local height = bottom - top
        local width = height * (240 / 312) * sh / sw
        return { ok = true, region = { x = x - width / 2, y = top, w = width, h = height } }
    end)

    -- A picture the page took (the focused character's portrait, or the scene's thumbnail for staff), sent in parts so
    -- each client event stays small; the server checks and stores it.
    local PICTURE_PART = 7000
    MC.Callback('mc:picture:save', function(data)
        local image, kind = data.image, data.kind
        if not view or type(image) ~= 'string' or #image > 120000 or (kind ~= 'portrait' and kind ~= 'thumb') then
            return { ok = false, error = 'invalid' }
        end
        local parts = math.ceil(#image / PICTURE_PART)
        for part = 1, parts do
            local chunk = image:sub((part - 1) * PICTURE_PART + 1, part * PICTURE_PART)
            local reply = MC.server('picture', 10000, { kind = kind, target = data.target, part = part, parts = parts, data = chunk })
            if not reply.ok then return { ok = false, error = reply.error } end
        end
        -- Our copy of the cards keeps it too, or the next cast (a tab, a scene change) would bring the old one back.
        if kind == 'thumb' then Look.thumb(data.target, image) end
        local card = kind == 'portrait' and view and view.cards and view.cards[tonumber(data.target) or -1]
        if card then card.portrait, card.portraitAt = image, GetCloudTimeAsInt() end
        return { ok = true }
    end)

    -- The request sheet with a reason for staff (request mode).
    MC.Callback('mc:delete:request', function(data)
        local reason = data.reason == nil and '' or text(data.reason, 600)
        if (Config.Delete or {}).Mode ~= 'request' then return { ok = false, error = 'locked' } end
        if not cardAt(data.index) or not reason then return { ok = false, error = 'invalid' } end
        return sheet('requestDelete', { index = data.index, reason = reason })
    end)

    MC.Callback('mc:delete:cancel', function(data)
        if not cardAt(data.index) then return { ok = false, error = 'invalid' } end
        return sheet('cancelRequest', { index = data.index })
    end)

    MC.Callback('mc:slots:redeem', function(data)
        local code = text(data.code, 64)
        if not code or code == '' then return { ok = false, error = 'invalid_code' } end
        return sheet('redeem', { code = code })
    end)

    RegisterNetEvent('daddy_multichar:cards', function(data)
        if type(data) ~= 'table' or not view or view.opening then return end
        CreateThread(function() Select.update(data.cards, data.slots) end)
    end)

    RegisterNetEvent('daddy_multichar:open', function(data)
        CreateThread(function() Select.reopen(type(data) == 'table' and data or {}) end)
    end)

    RegisterNetEvent('daddy_multichar:step', function(step)
        if type(step) ~= 'table' then return end
        CreateThread(function() Flow.force(step) end)
    end)

    -- A new character: the casting sheet, the server's create, then the wardrobe (the clothing script's creator) and the
    -- step the server names next. The wardrobe path also serves an old character that never saved a look.
    Create = {}
    local busy, warned = false, false
    local NOON = { h = 12, m = 0 }

    -- Today's date for the age check on the client; the server checks again with its own clock.
    local function today()
        -- FiveM's client Lua has no os library; the game clock of the PC is used instead.
        local y, m, d = GetLocalTime()
        return y and ('%04d-%02d-%02d'):format(y, m, d) or nil
    end

    -- Where the creator runs: the selection scene's anchor (private bucket, nobody around), else the new-character point.
    local function room()
        local scene = type(MC.session) == 'table' and MC.session.scene or nil
        local a = type(scene) == 'table' and scene.anchor or nil
        return a and { x = a.x, y = a.y, z = a.z, w = a.h } or Config.NewCharacter.Point
    end

    -- One round in the clothing creator; without a creator script the player is told once and goes on.
    local function dress(gender, isNew)
        local ok, err = Bridge.appearance.openCreator(gender, { isNew = isNew })
        if ok or err ~= 'unsupported' or warned then return end
        warned = true
        lib.notify({ description = Core.locale.t('client.creator_unavailable'), type = 'inform' })
    end

    -- Creator rounds until the server has the look ('invalid' means not yet; it lets the player on after three rounds).
    local function fitting(gender, isNew, gen)
        local reply
        for round = 1, 4 do
            if round > 1 and not warned then lib.notify({ description = Core.locale.t('client.creator_retry'), type = 'inform' }) end
            dress(gender, isNew)
            if gen ~= MC.gen then return nil end
            reply = MC.server('appearanceDone', 20000)
            if gen ~= MC.gen then return nil end
            if reply.ok or reply.error ~= 'invalid' then return reply end
        end
        return reply
    end

    -- A failure without a field ends the sheet: the server may already be back on select, else cancelCreate takes it there.
    local function backToSelect()
        if State.is('create') then MC.server('cancelCreate', 10000) end
        State.set('select')
        Nui.screen('select', { frame = Select.frame() })
    end

    -- Submits the sheet; the page gets mc:create:result, and on success the reply's step (the wardrobe) runs.
    function Create.run(index, identity)
        if busy then return false end
        busy = true
        local gen = MC.gen
        MC.Send('mc:select:busy', { on = true })
        local reply = MC.server('create', 30000, { identity = identity })
        busy = false
        if gen ~= MC.gen then return false end
        MC.Send('mc:create:result', { ok = reply.ok == true, field = reply.field, error = reply.error, reason = reply.reason })
        MC.Send('mc:select:busy', { on = false })
        if not reply.ok then
            if not reply.field then backToSelect() end
            return false
        end
        Relog.cast(identity.firstname, identity.lastname)
        Select.close()
        Flow.step(reply, { isNew = true })
        return true
    end

    -- Noon light and the player visible, frozen, on solid ground in an empty spot; the page closes for the creator.
    local function stage()
        Env.apply({ time = NOON, weather = 'EXTRASUNNY' })
        local at = room()
        Player.place(at)
        Stream.collision(PlayerPedId(), 5000)
        -- The scene's anchor is a ground point, so the ped's root stood on it with half the body under the floor. Like the
        -- scene's own actors, the root goes PedOffset over the ground found there (once the collision is in).
        local x, y, z = at.x or at[1], at.y or at[2], at.z or at[3]
        local ground = x and Ground.z(x, y, z)
        if ground then
            local lift = tonumber((Config.Selection or {}).PedOffset) or 1.0
            pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
            SetEntityCoordsNoOffset(PlayerPedId(), x + 0.0, y + 0.0, ground + lift, false, false, false)
        end
        Nui.close()
        Player.release()
        FreezeEntityPosition(PlayerPedId(), true)
        DoScreenFadeIn(500)
    end

    -- The wardrobe: the creator until the server has the look, then the step it names (cutscene or spawn).
    function Create.wardrobe(gender, isNew)
        local gen = MC.gen
        State.set('appearance')
        Nui.transition('wardrobe', { eyebrow = Core.locale.t('client.wardrobe_eyebrow'), title = Core.locale.t('client.wardrobe_title') })
        MC.fadeOut(500)
        Select.close()
        Rig.release()
        stage()
        local reply = fitting(gender == 'f' and 'f' or 'm', isNew, gen)
        if not reply then return end
        MC.fadeOut(400)
        Player.hide()
        if not reply.ok then return Recover.run('appearance', reply.error) end
        Nui.transition('loading', { eyebrow = Core.locale.t('client.loading_eyebrow') })
        Flow.step(reply, { isNew = isNew })
    end

    MC.Callback('mc:create:open', function(data)
        if not (Select.active() and State.is('select')) or type(data.index) ~= 'number' then return { ok = false, error = 'state' } end
        local reply = MC.server('startCreate', 10000, { index = data.index })
        if not reply.ok then return { ok = false, error = reply.error } end
        Create.index = data.index
        State.set('create')
        -- roles: the civilian / student / teacher cards (nil hides the cell).
        Nui.screen('create', { index = data.index, frame = Select.frame(), roles = reply.roles })
        return { ok = true }
    end)

    MC.Callback('mc:create:cancel', function()
        if not State.is('create') then return { ok = false, error = 'state' } end
        local reply = MC.server('cancelCreate', 10000)
        if not reply.ok then return { ok = false, error = reply.error } end
        State.set('select')
        Nui.screen('select', { frame = Select.frame() })
        return { ok = true }
    end)

    -- The page checked the sheet with rules.ts; it is checked here again, then sent (the server decides).
    MC.Callback('mc:create:submit', function(data)
        if not State.is('create') or busy then return { ok = false, error = 'busy' } end
        local ok, field, code = IdentityRules.check(data.identity, Config.Identity, today())
        if not ok then return { ok = false, field = field, error = code } end
        CreateThread(function() Create.run(Create.index, data.identity) end)
        return { ok = true }
    end)

    -- Photo mode on the selection (P): the page hides, the camera orbits the focused character (drag), comes closer or
    -- goes back (wheel) and lifts (right drag); the page's C takes the card picture from this view. Esc goes back to the
    -- scene's own framing. Dragging outside photo mode turns the character instead.
    Photo = {}

    local CHEST = 24818
    local MIN_DIST, MAX_DIST, SMOOTH = 0.7, 7.0, 0.18
    local on, want, now, ent = false, nil, nil, nil

    local function chest()
        if not ent or not DoesEntityExist(ent) then return nil end
        return GetPedBoneCoords(ent, CHEST, 0.0, 0.0, 0.0)
    end

    -- Frame 'photo': the camera eases toward the wanted orbit every frame.
    local function tick()
        local c = chest()
        if not c then return Photo.stop() end
        for _, key in ipairs({ 'yaw', 'pitch', 'dist', 'lift' }) do now[key] = now[key] + (want[key] - now[key]) * SMOOTH end
        local yaw, pitch = math.rad(now.yaw), math.rad(now.pitch)
        local x = c.x - math.sin(yaw) * math.cos(pitch) * now.dist
        local y = c.y + math.cos(yaw) * math.cos(pitch) * now.dist
        local z = c.z + math.sin(pitch) * now.dist + now.lift
        local p, r = CamMath.lookRot(x, y, z, c.x, c.y, c.z + now.lift)
        Rig.set(x, y, z, p, 0.0, r, now.fov)
    end

    function Photo.active()
        return on
    end

    function Photo.start()
        if on or not Scene.active() then return false end
        ent = Scene.actor(Scene.current())
        local c = chest()
        if not c then return false end
        Director.stop()
        local pose = Rig.pose()
        local dx, dy, dz = pose.x - c.x, pose.y - c.y, pose.z - c.z
        local flat = math.sqrt(dx * dx + dy * dy)
        now = {
            yaw = math.deg(math.atan(-dx, dy)), pitch = math.deg(math.atan(dz, math.max(flat, 0.01))),
            dist = CamMath.clamp(math.sqrt(dx * dx + dy * dy + dz * dz), MIN_DIST, MAX_DIST), lift = 0.0, fov = pose.fov or 40.0,
        }
        want = { yaw = now.yaw, pitch = now.pitch, dist = now.dist, lift = 0.0 }
        on = true
        Frame.on('photo', tick)
        return true
    end

    -- dx, dy: degrees to orbit; zoom: metres closer (+) or further (-); lift: metres up or down.
    function Photo.move(dx, dy, zoom, lift)
        if not on then return end
        want.yaw = want.yaw - (tonumber(dx) or 0)
        want.pitch = CamMath.clamp(want.pitch + (tonumber(dy) or 0), -30.0, 70.0)
        want.dist = CamMath.clamp(want.dist - (tonumber(zoom) or 0), MIN_DIST, MAX_DIST)
        want.lift = CamMath.clamp(want.lift + (tonumber(lift) or 0), -0.9, 0.6)
        Scene.touch()
    end

    function Photo.stop()
        if not on then return end
        on, ent = false, nil
        Frame.off('photo')
        Scene.reframe(nil, 700)
        Director.idle(Scene.sway())
    end

    local function ready()
        return Select.active() and State.is('select')
    end

    MC.Callback('mc:photo:start', function()
        if not ready() then return { ok = false, error = 'state' } end
        return { ok = Photo.start() }
    end)

    MC.Callback('mc:photo:move', function(data)
        Photo.move(data.dx, data.dy, data.zoom, data.lift)
        return { ok = true }
    end)

    MC.Callback('mc:photo:stop', function()
        Photo.stop()
        return { ok = true }
    end)

    -- Outside photo mode a drag turns the focused character (degrees).
    MC.Callback('mc:scene:turn', function(data)
        if not ready() or on then return { ok = false } end
        Scene.turn(tonumber(data.deg) or 0)
        return { ok = true }
    end)
end

-- The player's own view of the selection (the Scene and Preferences tabs): scene, camera preset, clock, weather, the look a job
-- brings (Auto) and drift. Clock and weather stay on this client; the server checks the scene. The tabs sit left, so the actor keeps its frame.
do
    Look = {}
    local KVP = 'daddy_multichar:look'
    local CAMS = { near = true, mid = true, wide = true }
    local PANELS = { scene = true, prefs = true, party = true }
    local BLEND_MS, PAN_MS, CUT_MS = 350, 1100, 220
    local my = { cam = 'mid', auto = false, drift = true, hour = nil, weather = nil, panel = nil, filter = 'none' }
    local busy = false
    local wish -- a scene picked while another one is being built
    local filterIds -- set with the filters below; Look.push lists them
    local chosen = {} -- card index -> the scene the player picked for it this visit

    local function cfg()
        return Config.Selection or {}
    end

    local function allowed()
        return cfg().PlayerScene ~= false
    end

    -- Camera preset, Auto and drift come back on the next visit; clock and weather picks do not.
    function Look.load()
        local ok, saved = pcall(json.decode, GetResourceKvpString(KVP) or '')
        saved = ok and type(saved) == 'table' and saved or {}
        my.cam = CAMS[saved.cam] and saved.cam or 'mid'
        my.auto = saved.auto == true
        if saved.drift == nil then my.drift = cfg().Drift ~= false else my.drift = saved.drift == true end
        my.filter = type(saved.filter) == 'string' and saved.filter or 'none'
        my.hour, my.weather, my.panel = nil, nil, nil
    end

    local function save()
        SetResourceKvp(KVP, json.encode({ cam = my.cam, auto = my.auto, drift = my.drift, filter = my.filter }))
    end

    -- The fov factor of the camera preset (1 when players may not pick).
    function Look.zoom()
        if not allowed() then return 1.0 end
        return tonumber((cfg().Cams or {})[my.cam]) or 1.0
    end

    function Look.drift()
        if not allowed() then return cfg().Drift ~= false end
        return my.drift
    end

    local function sceneId()
        local scene = type(MC.session) == 'table' and MC.session.scene or nil
        return type(scene) == 'table' and scene.id or nil
    end

    -- The scenes a player may pick: the server's list when the boot reply has one, else the configured active ones.
    function Look.scenes()
        local list = type(MC.session) == 'table' and type(MC.session.scenes) == 'table' and MC.session.scenes or nil
        if list then return list end
        local out, presets = {}, (Config.Scenes or {}).Presets or {}
        for _, id in ipairs((Config.Scenes or {}).Active or {}) do
            local preset = type(presets[id]) == 'table' and presets[id] or {}
            out[#out + 1] = { id = id, label = preset.label or id, desc = preset.desc, role = preset.role, kind = preset.kind }
        end
        return out
    end

    -- The poses a player may give a character: random first, then Config.Animations (labels: locales anim.<id>).
    function Look.poses()
        local out = { { id = 'random', label = 'pose.random' } }
        for _, anim in ipairs(Config.Animations or {}) do
            if type(anim.id) == 'string' then out[#out + 1] = { id = anim.id, label = 'anim.' .. anim.id } end
        end
        return out
    end

    -- True for a pose id the server also accepts.
    function Look.knownPose(id)
        for _, item in ipairs(Look.poses()) do
            if item.id == id then return true end
        end
        return false
    end

    -- The scene list without its thumbnails, which go to the page once per visit (mc:select:thumbs).
    local function sceneRows()
        local out = {}
        for i, scene in ipairs(Look.scenes()) do out[i] = { id = scene.id, label = scene.label, desc = scene.desc, fresh = scene.fresh, role = scene.role } end
        return out
    end

    local thumbsSent = false
    local thumbs, asked = {}, {} -- scene id -> thumbnail (kept while the resource runs); ids already asked for

    -- The settings panel's state on the page.
    function Look.push()
        local hour, weather = Env.now()
        MC.Send('mc:select:env', {
            hour = math.floor(hour * 4 + 0.5) / 4 % 24, weather = weather, auto = my.auto, scene = sceneId(), cam = my.cam,
            drift = Look.drift(), scenes = allowed() and sceneRows() or {}, allowed = allowed(), poses = Look.poses(),
            filter = my.filter, filters = filterIds(), posable = Scene.posable and Scene.posable() or false,
        })
        if thumbsSent or not allowed() then return end
        thumbsSent = true
        MC.Send('mc:select:thumbs', { thumbs = thumbs })
        local missing = {}
        for _, scene in ipairs(Look.scenes()) do
            if not thumbs[scene.id] and not asked[scene.id] and #missing < 64 then
                missing[#missing + 1] = scene.id
                asked[scene.id] = true
            end
        end
        if #missing > 0 then CreateThread(function() MC.server('thumbs', 10000, { ids = missing }) end) end
    end

    -- The season pack the server runs (boot reply), or nil.
    local function season()
        return type(MC.session) == 'table' and SeasonRules.NAMES[MC.session.seasonPack] and MC.session.seasonPack or nil
    end

    local function jobName(card)
        local job = type(card) == 'table' and type(card.job) == 'table' and card.job or {}
        return type(job.name) == 'string' and job.name or (type(job.label) == 'string' and job.label:lower() or '')
    end

    -- A job's look ({ scene?, hour, weather }) from a card: job.name when the server sends it, else the label lower-cased.
    -- Jobs without one get the default look, whose weather follows the season.
    local function jobLook(card)
        return (cfg().JobLooks or {})[jobName(card)] or SeasonRules.look(cfg().DefaultLook, season())
    end

    local function listed(list, value)
        for _, item in ipairs(type(list) == 'table' and list or {}) do
            if item == value or item == '*' then return true end
        end
        return false
    end

    -- A card's role (Config.Selection.Roles): the role listing its job, else the one listing its gang, else civilian.
    function Look.roleOf(card)
        local roles, job = cfg().Roles or {}, jobName(card)
        local gang = type(card) == 'table' and type(card.gang) == 'string' and card.gang or nil
        for role, rule in pairs(roles) do
            if type(rule) == 'table' and job ~= '' and listed(rule.jobs, job) then return role end
        end
        for role, rule in pairs(roles) do
            if type(rule) == 'table' and gang and listed(rule.gangs, gang) then return role end
        end
        return 'civilian'
    end

    -- Role scenes are drawn at random, by the focused character's job (Config.Selection.Roles), out of one shuffled
    -- bag per role that this client keeps across visits: every scene of the role shows once before any comes back, and
    -- the scene just shown never comes straight again, so each login and each character switch opens another. A job
    -- with a single scene takes turns with the civilian ones; a crew or a partner draws from the scenes made for them.
    local BAG_KVP = 'daddy_multichar:scenebag'
    local bags, lastShown -- role -> scene ids left to draw this round; the scene drawn last
    local rolled -- { index, id }: the scene drawn for the card in focus

    local function loadBags()
        if bags then return end
        local ok, saved = pcall(json.decode, GetResourceKvpString(BAG_KVP) or '')
        saved = ok and type(saved) == 'table' and saved or {}
        bags = type(saved.bags) == 'table' and saved.bags or {}
        lastShown = type(saved.last) == 'string' and saved.last or nil
    end

    local function saveBags()
        SetResourceKvp(BAG_KVP, json.encode({ bags = bags, last = lastShown }))
    end

    local function sceneIds(match)
        local out = {}
        for _, scene in ipairs(Look.scenes()) do
            if match(scene) then out[#out + 1] = scene.id end
        end
        return out
    end

    -- A scene's role as the selection reads it: one without a job in Config.Selection.Roles (a scene saved in the
    -- database before its role was dropped) counts as civilian.
    local function roleOfScene(scene)
        local role = scene.role
        if role == nil or role == 'civilian' or (cfg().Roles or {})[role] then return role end
        return 'civilian'
    end

    local function solo(role)
        return function(scene)
            return scene.role ~= nil and (scene.kind or 'solo') == 'solo' and (role == nil or roleOfScene(scene) == role)
        end
    end

    -- The next scene out of the role's bag; a used-up bag is shuffled anew (Fisher-Yates), never opening on lastShown.
    local function draw(key, list)
        if #list == 0 then return nil end
        if #list == 1 then return list[1] end
        local valid, bag = {}, {}
        for _, id in ipairs(list) do valid[id] = true end
        for _, id in ipairs(type(bags[key]) == 'table' and bags[key] or {}) do
            if valid[id] then bag[#bag + 1] = id end -- scenes removed since drop out
        end
        if #bag == 0 then
            for i, id in ipairs(list) do bag[i] = id end
            for i = #bag, 2, -1 do
                local j = math.random(i)
                bag[i], bag[j] = bag[j], bag[i]
            end
        end
        if bag[#bag] == lastShown and #bag > 1 then
            local j = math.random(#bag - 1)
            bag[#bag], bag[j] = bag[j], bag[#bag]
        end
        local id = table.remove(bag)
        bags[key] = bag
        return id
    end

    -- The scene for a card. reuse: the one already drawn for this card (the focus is still settling on it).
    local function roleScene(card, reuse)
        local index = type(card) == 'table' and tonumber(card.index) or 1
        if rolled and rolled.index == index and (reuse or rolled.id == sceneId()) then return rolled.id end
        loadBags()
        local id
        local company = (Crew and Crew.count and Crew.count() > 0) and 'crew' or (Scene.hasPartner(index) and 'partner') or nil
        if company then
            id = draw(company, sceneIds(function(scene) return scene.kind == company end))
        end
        if not id then
            local role = Look.roleOf(card)
            local list = sceneIds(solo(role))
            local civilian = role ~= 'civilian' and sceneIds(solo('civilian')) or {}
            local current = sceneId()
            -- Config.Selection.KeepScene: a scene that already suits this card stays, so switching between characters
            -- of one role only moves the camera instead of rebuilding (and streaming) another place.
            if cfg().KeepScene == true and current and (listed(list, current) or (#list <= 1 and listed(civilian, current))) then
                id = current
            elseif #list == 1 and #civilian > 0 then
                id = lastShown ~= list[1] and list[1] or draw('civilian', civilian)
            elseif #list > 0 then
                id = draw(role, list)
            else
                id = draw('civilian', civilian) or draw('*', sceneIds(solo(nil)))
            end
        end
        if not id then return nil end
        rolled, lastShown = { index = index, id = id }, id
        saveBags()
        return id
    end

    local function filterOf(id)
        for _, f in ipairs(cfg().Filters or {}) do
            if f.id == id then return f end
        end
        return nil
    end

    -- The player's filter over the scene's own look (an extra timecycle layer), or none.
    function Look.filter()
        local f = filterOf(my.filter)
        if f and type(f.modifier) == 'string' then
            SetExtraTimecycleModifier(f.modifier)
            SetExtraTimecycleModifierStrength((tonumber(f.strength) or 1.0) + 0.0)
        else
            ClearExtraTimecycleModifier()
        end
    end

    -- The filters' ids in order, 'none' first (the page labels them filter.<id>).
    filterIds = function()
        local out = { 'none' }
        for _, f in ipairs(cfg().Filters or {}) do
            if type(f.id) == 'string' then out[#out + 1] = f.id end
        end
        return out
    end

    -- The next filter (photo mode's F).
    function Look.nextFilter()
        local ids = filterIds()
        local at = 1
        for i, id in ipairs(ids) do
            if id == my.filter then at = i end
        end
        my.filter = ids[at % #ids + 1]
        save()
        Look.filter()
        Look.push()
        return my.filter
    end

    -- The player's picks over a freshly applied scene (Scene.open calls this right after Env.apply).
    function Look.world()
        if my.hour then Env.clock(my.hour, 0) end
        if my.weather then Env.weather(my.weather) end
        Look.filter()
    end

    local pick -- the scene change (below), for a role scene picked by focus

    -- A character's saved look (Scene tab): its scene, clock, weather, camera and filter, before the role scene.
    local function savedLook(card)
        local look = type(card) == 'table' and type(card.look) == 'table' and card.look or nil
        if not look or type(look.scene) ~= 'string' then return nil end
        for _, scene in ipairs(Look.scenes()) do
            if scene.id == look.scene then return look end
        end
        return nil
    end

    -- The scene a card brings: the one picked for it this visit, else its saved scene, else a role scene drawn for its job.
    function Look.target(card)
        if not allowed() or type(card) ~= 'table' then return nil end
        local saved = savedLook(card)
        return chosen[card.index] or (saved and saved.scene) or roleScene(card)
    end

    -- Focus moved to a card: the scene picked for it this visit, else its saved scene, else the role scene drawn for it
    -- (Look.target drew it); the camera and filter the player kept for the character come back. With no scene and Auto on,
    -- its job's clock and weather glide in (instant when the scene opens).
    function Look.focused(card, instant)
        if not allowed() then return end
        local saved = savedLook(card)
        if saved then
            if CAMS[saved.cam] then my.cam = saved.cam end
            if type(saved.filter) == 'string' then my.filter = saved.filter end
        end
        local scene = type(card) == 'table' and (chosen[card.index] or (saved and saved.scene) or roleScene(card, true)) or nil
        if scene then
            my.hour, my.weather = nil, nil
            if saved and saved.scene == scene then
                my.hour = tonumber(saved.hour)
                my.weather = type(saved.weather) == 'string' and saved.weather or nil
            end
            if scene ~= sceneId() then
                pick(scene)
            else
                if my.hour then Env.clock(my.hour, instant and 0 or BLEND_MS) end
                if my.weather then Env.weather(my.weather, not instant) end
            end
            return Look.push()
        end
        if not my.auto then return end
        local look = jobLook(card)
        my.hour, my.weather = tonumber(look.hour), type(look.weather) == 'string' and look.weather or nil
        if my.hour then Env.clock(my.hour, instant and 0 or BLEND_MS) end
        if my.weather then Env.weather(my.weather, not instant) end
        Look.push()
    end

    -- A thumbnail staff just took, or the server's paced answer to the 'thumbs' call.
    function Look.thumb(id, image)
        if type(id) ~= 'string' or type(image) ~= 'string' then return end
        thumbs[id] = image
    end

    RegisterNetEvent('daddy_multichar:thumbs', function(list)
        if type(list) ~= 'table' then return end
        for id, image in pairs(list) do Look.thumb(id, image) end
        if Select.active() then MC.Send('mc:select:thumbs', { thumbs = thumbs }) end
    end)

    -- The clock and weather the player last looked at, kept for the entry card after the scene is gone.
    function Look.snapshot()
        local hour, weather = Env.now()
        Look.last = { hour = hour, weather = weather }
        return Look.last
    end

    -- The selection closed: picks of this visit end, the panel is shut.
    function Look.reset()
        my.hour, my.weather, my.panel = nil, nil, nil
        thumbsSent = false
        wish = nil
        chosen = {}
        rolled = nil
    end

    local function sceneHour()
        local scene = type(MC.session) == 'table' and MC.session.scene or nil
        local t = type(scene) == 'table' and type(scene.time) == 'table' and scene.time or nil
        return t and (tonumber(t.h) or 0) + (tonumber(t.m) or 0) / 60 or nil, type(scene) == 'table' and scene.weather or nil
    end

    -- Guards every settings call: the selection is up and players may change the view.
    local function ready(needsAllowed)
        if not Select.active() or not State.is('select') then return false end
        Select.touch()
        Scene.touch()
        return not needsAllowed or allowed()
    end

    local function done()
        Look.push()
        return { ok = true }
    end

    MC.Callback('mc:select:panel', function(data)
        if not ready(false) then return { ok = false, error = 'state' } end
        local open = PANELS[data.open] and data.open or nil
        if open == 'party' and my.panel ~= 'party' then CreateThread(Crew.refresh) end
        my.panel = open
        return { ok = true }
    end)

    -- A scene the server allows: a 220 ms black cut, the scene rebuilt there (it streams for a few seconds), the same card
    -- in focus. A pick made meanwhile waits and runs next; the last one wins. Look.push tells the page when it is done.
    local function changeScene(id)
        busy = true
        local reply = MC.server('look', 10000, { scene = id })
        if reply.ok and type(reply.scene) == 'table' then Select.swapScene(reply.scene, CUT_MS, nil) end
        local queued = wish
        wish = nil
        if queued and queued ~= sceneId() and ready(true) then return changeScene(queued) end
        busy = false
        Look.push()
        return reply.ok == true
    end

    -- A scene change now, or after the one being built (the last pick wins).
    pick = function(id)
        if busy then
            wish = id
            return true
        end
        CreateThread(function()
            local ok, err = pcall(changeScene, id)
            if ok then return end
            busy, wish = false, nil
            print(('^1[daddy_multichar] scene change: %s^7'):format(tostring(err)))
            if IsScreenFadedOut() or IsScreenFadingOut() then DoScreenFadeIn(300) end
        end)
        return false
    end

    MC.Callback('mc:select:setScene', function(data)
        if not ready(true) or type(data.id) ~= 'string' or #data.id > 80 then return { ok = false, error = 'invalid' } end
        local card = Select.card()
        if type(card) == 'table' then chosen[card.index] = data.id end
        if data.id == sceneId() and not busy then return done() end
        if pick(data.id) then return { ok = true, queued = true } end
        return { ok = true }
    end)

    MC.Callback('mc:select:setCam', function(data)
        if not ready(true) or not CAMS[data.cam] then return { ok = false, error = 'invalid' } end
        my.cam = data.cam
        save()
        Scene.reframe(nil, PAN_MS)
        return done()
    end)

    MC.Callback('mc:select:setTime', function(data)
        local hour = tonumber(data.hour)
        if not ready(true) or not hour or hour < 0 or hour > 24 then return { ok = false, error = 'invalid' } end
        my.hour, my.auto = hour % 24, false
        Env.clock(my.hour, BLEND_MS)
        save()
        return done()
    end)

    local function knownWeather(kind)
        for _, w in ipairs(cfg().Weathers or {}) do
            if w == kind then return true end
        end
        return false
    end

    MC.Callback('mc:select:setWeather', function(data)
        if not ready(true) or not knownWeather(data.weather) then return { ok = false, error = 'invalid' } end
        my.weather, my.auto = data.weather, false
        Env.weather(my.weather, true)
        save()
        return done()
    end)

    MC.Callback('mc:select:setAuto', function(data)
        if not ready(true) then return { ok = false, error = 'state' } end
        my.auto = data.on == true
        save()
        if my.auto then Look.focused(Select.card()) end
        return done()
    end)

    -- Saves (or with clear, drops) the focused character's look as the player sees it now.
    MC.Callback('mc:select:saveLook', function(data)
        if not ready(true) then return { ok = false, error = 'state' } end
        local card = Select.card()
        if type(card) ~= 'table' or card.kind ~= 'character' then return { ok = false, error = 'invalid' } end
        local hour, weather = Env.now()
        local look = data.clear ~= true and { scene = sceneId(), hour = hour, weather = weather, cam = my.cam, filter = my.filter } or nil
        local reply = MC.server('look:save', 10000, { index = card.index, look = look })
        if reply.ok then card.look = reply.look end
        return { ok = reply.ok == true, error = reply.error, look = reply.look }
    end)

    MC.Callback('mc:select:setFilter', function(data)
        if not ready(false) or type(data.id) ~= 'string' then return { ok = false, error = 'invalid' } end
        my.filter = (data.id == 'none' or filterOf(data.id)) and data.id or 'none'
        save()
        Look.filter()
        return done()
    end)

    MC.Callback('mc:photo:filter', function()
        if not ready(false) then return { ok = false, error = 'state' } end
        return { ok = true, filter = Look.nextFilter() }
    end)

    MC.Callback('mc:select:setDrift', function(data)
        if not ready(true) then return { ok = false, error = 'state' } end
        my.drift = data.on == true
        save()
        Scene.drift()
        return done()
    end)

    -- Back to the scene's own clock, weather and framing.
    MC.Callback('mc:select:resetLook', function()
        if not ready(true) then return { ok = false, error = 'state' } end
        my.hour, my.weather, my.auto, my.cam, my.drift = nil, nil, false, 'mid', cfg().Drift ~= false
        save()
        local hour, weather = sceneHour()
        if hour then Env.clock(hour, BLEND_MS) end
        if weather then Env.weather(weather, true) end
        Scene.reframe(nil, PAN_MS)
        Scene.drift()
        return done()
    end)

    -- /mc_scene [id] (Config.Debug, admins): on the selection, lists the scenes or switches to one (role scenes too).
    function Look.debugScene(_, args)
        local id = args and args[1]
        if not id then
            for _, scene in ipairs(Look.scenes()) do print(('%s%s  %s'):format(scene.id, scene.role and (' [' .. scene.role .. ']') or '', scene.label or '')) end
            return
        end
        if not ready(false) then return print('mc_scene: open the character selection first') end
        local card = Select.card()
        if type(card) == 'table' then chosen[card.index] = id end
        my.auto = false
        pick(id)
    end
end

-- The crew (P): the server's party state relayed to the page, the page's crew calls relayed to the server, and the
-- members standing next to the focused actor as local clones in formation, with name tags projected for the page.
do
    Crew = {}
    local HEAD = 31086
    local MODES = { solo = true, partner = true, crew = true }
    local FADE_MS, TAG_MS, FOCUS_MS, EPSILON = 600, 33, 400, 0.003
    local party = nil  -- the last 'party' push
    local clones = {}  -- [id] = { key, ent, info, spot }
    local marks = {}   -- low-spec: [id] = { info, head } tags with no ped under them
    local tagsAt, lastTags = 0, nil
    local focusWant, focusAt, focusing = nil, 0, false

    local function enabled()
        return (Config.Party or {}).Enabled == true
    end

    local function myId()
        return GetPlayerServerId(PlayerId())
    end

    -- The page's copy of the state (previews stay here).
    function Crew.send()
        if not party or not Select.active() then return end
        MC.Send('mc:party:state', { mode = party.mode, formation = party.formation, leader = party.leader == true,
            members = party.members or {}, people = party.people or {}, max = party.max or (Config.Party or {}).Max })
    end

    -- Member looks by id, from a list of { id, model, skin, format } or a map.
    local function previews()
        local out = {}
        for key, p in pairs(type(party.previews) == 'table' and party.previews or {}) do
            if type(p) == 'table' then out[tonumber(p.id) or tonumber(key) or -1] = p end
        end
        return out
    end

    local function genderOf(preview)
        if preview.gender == 'f' or preview.gender == 'm' then return preview.gender end
        local model = preview.model
        return (model == 'mp_f_freemode_01' or model == joaat('mp_f_freemode_01')) and 'f' or 'm'
    end

    -- Ground z near a point, else the leader's.
    local function ground(x, y, z)
        local ok, gz = GetGroundZFor_3dCoord(x + 0.0, y + 0.0, z + 1.5, false)
        if ok and math.abs(gz - z) < 2.0 then return gz end
        return z
    end

    -- Who stands next to the actor: accepted members with a look, in the formation's slots from the focused spot.
    local function wanted()
        local base = party and Select.active() and Scene.takesCompany() and Scene.spot()
        if not base then return {} end
        local looks, me, list = previews(), myId(), {}
        local slots = ((Config.Party or {}).Formations or {})[party.formation or 'side'] or {}
        local frame = { x = base.pos.x, y = base.pos.y, z = 0, h = base.heading }
        local lift = tonumber((Config.Selection or {}).PedOffset) or 1.0
        for _, m in ipairs(type(party.members) == 'table' and party.members or {}) do
            local look, slot = looks[tonumber(m.id) or -1], slots[#list + 1]
            -- A role scene has its own places for companions (with what they do there); others use the formation.
            local place = Scene.companion(#list + 1)
            if tonumber(m.id) ~= me and m.state == 'in' and type(look) == 'table' and place then
                local g = place.ground.pos
                list[#list + 1] = { id = tonumber(m.id), info = m, preview = look, key = json.encode(look),
                    spot = place, head = vector3(g.x, g.y, g.z + 1.7) }
            elseif tonumber(m.id) ~= me and m.state == 'in' and type(look) == 'table' and slot then
                local x, y = CamMath.toWorld(frame, tonumber(slot.x) or 0, tonumber(slot.y) or 0, 0)
                local z = ground(x, y, base.pos.z)
                list[#list + 1] = { id = tonumber(m.id), info = m, preview = look, key = json.encode(look),
                    spot = { pos = vector3(x, y, z + lift), heading = base.heading, anim = 'random' }, head = vector3(x, y, z + 1.7) }
            end
        end
        return list
    end

    local function remove(id)
        local c = clones[id]
        clones[id] = nil
        if c then Actors.remove(c.ent) end
    end

    -- The clone fades in over FADE_MS (local peds cannot use the network fade).
    local function fadeIn(ent)
        SetEntityAlpha(ent, 0, false)
        SetEntityVisible(ent, true, false)
        local t0 = GetGameTimer()
        while DoesEntityExist(ent) and GetGameTimer() - t0 < FADE_MS do
            SetEntityAlpha(ent, math.floor(255 * (GetGameTimer() - t0) / FADE_MS), false)
            Wait(0)
        end
        if DoesEntityExist(ent) then ResetEntityAlpha(ent) end
    end

    local function spawn(m)
        local c = { key = m.key, info = m.info, spot = m.spot, preview = m.preview }
        clones[m.id] = c
        local function valid() return clones[m.id] == c and Scene.active() end
        CreateThread(function()
            local gender = genderOf(m.preview)
            local ped = Actors.character(c.spot, { index = m.id, gender = gender, preview = m.preview }, valid)
            if not ped then return end
            if not valid() then return Actors.remove(ped) end
            c.ent = Track.add('crew', ped)
            if not Cast.act(ped, c.spot, gender, valid) then Actors.pose(ped, c.spot, gender, m.id, valid) end
            if valid() then fadeIn(ped) end
        end)
    end

    -- A clone already there walks nowhere: it is put on its new spot and posed again.
    local function move(c, m)
        c.info, c.preview = m.info, m.preview
        if not c.ent or not DoesEntityExist(c.ent) or #(c.spot.pos - m.spot.pos) < 0.05 then return end
        c.spot = m.spot
        local p = m.spot.pos
        ClearPedTasksImmediately(c.ent)
        FreezeEntityPosition(c.ent, true)
        SetEntityCoordsNoOffset(c.ent, p.x, p.y, p.z, false, false, false)
        SetEntityHeading(c.ent, m.spot.heading + 0.0)
        CreateThread(function()
            local valid = function() return clones[m.id] == c end
            local gender = genderOf(m.preview)
            if not Cast.act(c.ent, c.spot, gender, valid) then Actors.pose(c.ent, c.spot, gender, m.id, valid) end
        end)
    end

    -- Projected head tags, at most 30 times a second and only when they moved.
    local function tags(now)
        if now - tagsAt < TAG_MS then return end
        tagsAt = now
        local list = {}
        local function add(id, info, head)
            local ok, x, y = GetScreenCoordFromWorldCoord(head.x, head.y, head.z + 0.35)
            if ok then list[#list + 1] = { id = id, name = info.name, character = info.character, job = info.job, state = info.state, x = x, y = y } end
        end
        for id, c in pairs(clones) do
            if c.ent and DoesEntityExist(c.ent) and IsEntityVisible(c.ent) then add(id, c.info, GetPedBoneCoords(c.ent, HEAD, 0.0, 0.0, 0.0)) end
        end
        for id, m in pairs(marks) do add(id, m.info, m.head) end
        table.sort(list, function(a, b) return a.id < b.id end)
        local same = lastTags and #lastTags == #list
        for i = 1, same and #list or 0 do
            local a, b = list[i], lastTags[i]
            if a.id ~= b.id or math.abs(a.x - b.x) > EPSILON or math.abs(a.y - b.y) > EPSILON then same = false break end
        end
        if same then return end
        lastTags = list
        MC.Send('mc:party:tags', { list = list })
    end

    local function tagging(on)
        if on then return Frame.on('crewtags', tags) end
        Frame.off('crewtags')
        if lastTags and #lastTags > 0 then MC.Send('mc:party:tags', { list = {} }) end
        lastTags = nil
    end

    -- Clones follow the party and the focused spot: new ones fade in, moved ones are put back, gone ones removed.
    function Crew.place()
        local list, keep = wanted(), {}
        marks = {}
        if MC.lowSpec() then
            for id in pairs(clones) do remove(id) end
            for _, m in ipairs(list) do marks[m.id] = { info = m.info, head = m.head } end
            Scene.solo(next(marks) ~= nil)
            return tagging(next(marks) ~= nil)
        end
        for _, m in ipairs(list) do
            keep[m.id] = true
            local c = clones[m.id]
            if c and c.key ~= m.key then
                remove(m.id)
                c = nil
            end
            if c then move(c, m) else spawn(m) end
        end
        for id in pairs(clones) do
            if not keep[id] then remove(id) end
        end
        local any = next(clones) ~= nil
        Scene.solo(any)
        tagging(any)
    end

    -- Every clone goes (the scene closes, the resource stops).
    function Crew.clear()
        for id in pairs(clones) do remove(id) end
        marks = {}
        Track.clear('crew')
        tagging(false)
    end

    -- Names for the entry card: everyone in the crew.
    function Crew.names()
        local out = {}
        for _, m in ipairs(party and type(party.members) == 'table' and party.members or {}) do
            local name = type(m.character) == 'string' and m.character or m.name
            if m.state == 'in' and type(name) == 'string' then out[#out + 1] = name end
        end
        return out
    end

    -- The focused card for the server (others see who we are about to play), at most every FOCUS_MS, the last one wins.
    -- The members standing in the scene, for the moments: ped, sex, place and how to put them back in their act.
    function Crew.peds()
        local out = {}
        for id, c in pairs(clones) do
            if c.ent and DoesEntityExist(c.ent) and IsEntityVisible(c.ent) and c.spot then
                local gender = genderOf(c.preview)
                out[#out + 1] = { id = id, ent = c.ent, sex = gender, spot = c.spot, restore = function(valid)
                    if not Cast.act(c.ent, c.spot, gender, valid) then Actors.pose(c.ent, c.spot, gender, id, valid) end
                end }
            end
        end
        table.sort(out, function(a, b) return a.id < b.id end)
        return out
    end

    -- The members in the scene besides this player (a role scene picks its layout by it).
    function Crew.count()
        local others, me = 0, myId()
        for _, m in ipairs(party and type(party.members) == 'table' and party.members or {}) do
            if tonumber(m.id) ~= me and m.state == 'in' then others = others + 1 end
        end
        return others
    end

    function Crew.focus(index)
        if not enabled() then return end
        focusWant = index
        if focusing then return end
        focusing = true
        CreateThread(function()
            while focusWant do
                local wait = focusAt + FOCUS_MS - GetGameTimer()
                if wait > 0 then Wait(wait) end
                local i = focusWant
                focusWant, focusAt = nil, GetGameTimer()
                if Select.active() then MC.server('focus', 5000, { index = i }) end
            end
            focusing = false
        end)
    end

    -- A new party state (push or party:state reply): the page and the clones follow it.
    function Crew.apply(data)
        if type(data) ~= 'table' then return end
        party = data
        Crew.send()
        -- A role scene takes another layout when the crew changes size; the rebuilt page places the crew itself.
        if Scene.active() and Scene.role() then
            CreateThread(function()
                -- A crew takes a crew scene (alone again: the character's own).
                Look.focused(Select.card())
                if not Scene.relayout() then Crew.place() end
            end)
            return
        end
        Crew.place()
    end

    -- The crew panel opened: ask the server for the current state.
    function Crew.refresh()
        if not enabled() then return end
        local reply = MC.server('party:state', 10000)
        if reply.ok then Crew.apply(reply) end
    end

    RegisterNetEvent('daddy_multichar:party', function(data)
        CreateThread(function() Crew.apply(data) end)
    end)

    RegisterNetEvent('daddy_multichar:partyInvite', function(data)
        if type(data) ~= 'table' or not tonumber(data.id) then return end
        MC.Send('mc:party:invite', { id = tonumber(data.id), name = data.name, character = data.character, job = data.job })
    end)

    -- A character plays: the party is over on this client.
    AddEventHandler('daddy_multichar:client:state', function(name)
        if name == 'playing' then
            party = nil
            Crew.clear()
        end
    end)

    -- The page's crew calls, relayed with their reply (the server checks the state).
    local function relay(name, payload)
        if not enabled() then return { ok = false, error = 'state' } end
        local reply = MC.server(name, 10000, payload)
        return { ok = reply.ok == true, error = reply.error }
    end

    -- A server id, or a test person's negative id while Config.Debug is on (/mccrew).
    local function playerId(value)
        local id = tonumber(value)
        if not id or id ~= math.floor(id) or id == 0 then return nil end
        return (id > 0 or Config.Debug == true) and id or nil
    end

    MC.Callback('mc:party:invite', function(data)
        local id = playerId(data.id)
        if not id then return { ok = false, error = 'invalid' } end
        return relay('party:invite', { id = id })
    end)

    MC.Callback('mc:party:kick', function(data)
        local id = playerId(data.id)
        if not id then return { ok = false, error = 'invalid' } end
        return relay('party:kick', { id = id })
    end)

    MC.Callback('mc:party:mode', function(data)
        if not MODES[data.mode] then return { ok = false, error = 'invalid' } end
        return relay('party:mode', { mode = data.mode })
    end)

    MC.Callback('mc:party:formation', function(data)
        if type(data.form) ~= 'string' or not ((Config.Party or {}).Formations or {})[data.form] then return { ok = false, error = 'invalid' } end
        return relay('party:formation', { form = data.form })
    end)

    MC.Callback('mc:party:partner', function(data)
        if data.kind ~= 'couple' and data.kind ~= 'friend' then return { ok = false, error = 'invalid' } end
        return relay('party:partner', { kind = data.kind })
    end)

    MC.Callback('mc:party:partnerRespond', function(data)
        return relay('party:partnerRespond', { accept = data.accept == true })
    end)

    MC.Callback('mc:partner:unlink', function(data)
        local reply = MC.server('partner:unlink', 10000, { index = tonumber(data.index) })
        return { ok = reply.ok == true, error = reply.error }
    end)

    MC.Callback('mc:party:respond', function(data)
        local id = playerId(data.id)
        if not id then return { ok = false, error = 'invalid' } end
        return relay('party:respond', { id = id, accept = data.accept == true })
    end)
end

-- /relog: client pre-checks (the server checks everything again), the server's logout, then the cut back to casting.
-- The selection itself opens only on the server's 'open' push.
do
    Relog = {}
    local lastCombat, damageHandler, busy, out = 0, nil, false, nil
    local who, shown = nil, false -- the played character's name; the leaving poster is on the page
    local POSTER_MS = 1060 -- the red sweeps in and out (420 + 220 + 420) before the sky switch starts

    local function t(key, ...)
        return Core.locale.t(key, ...)
    end

    -- Damage dealt or taken marks combat; the handler exists only while a character plays (no per-frame cost).
    local function onGameEvent(name, args)
        if name ~= 'CEventNetworkEntityDamage' then return end
        local ped = PlayerPedId()
        if args[1] == ped or args[2] == ped then lastCombat = GetGameTimer() end
    end

    local function track(on)
        if on and not damageHandler then
            damageHandler = AddEventHandler('gameEventTriggered', onGameEvent)
        elseif not on and damageHandler then
            RemoveEventHandler(damageHandler)
            damageHandler = nil
        end
    end

    local function inCombat(ped)
        local window = (tonumber(Config.Combat.Seconds) or 60) * 1000
        return (lastCombat > 0 and GetGameTimer() - lastCombat < window) or IsPedInMeleeCombat(ped) or IsPedShooting(ped)
    end

    -- The first reason a relog is refused here (an errors.<code> key), or nil.
    function Relog.check()
        local ped, cfg = PlayerPedId(), Config.Relog
        if not cfg.Enabled then return 'locked' end
        if not State.is('playing') then return 'state' end
        if cfg.BlockDead and (IsPedDeadOrDying(ped, true) or IsEntityDead(ped)) then return 'dead' end
        if cfg.BlockCuffed and Bridge.chars.cuffed() then return 'restrained' end
        if cfg.BlockVehicle and IsPedInAnyVehicle(ped, true) then return 'vehicle' end
        if inCombat(ped) then return 'combat' end
        if not MC.allow('canRelog') then return 'hook' end
        return nil
    end

    -- The command and the Relog() export; a refusal shows as a notification.
    function Relog.request()
        if busy then return false end
        local why = Relog.check()
        if why then
            Nui.toast('errors.' .. why, 'error')
            return false
        end
        busy = true
        local reply = MC.server('relog', 40000)
        busy = false
        if reply.ok then return true end
        Nui.toast('errors.' .. tostring(reply.error or 'invalid'), 'error')
        if State.is('relogging') then CreateThread(function() Recover.run('relogging', reply.error) end) end
        return false
    end

    -- The live transition leaves the same way it came: the camera rises out of the gameplay camera into the sky.
    local function liveOut()
        if Config.Spawn.Transition ~= 'live' or MC.prefs.motion ~= 'full' or MC.lowSpec() then return false end
        local ped = PlayerPedId()
        return not IsEntityDead(ped) and not IsPedInAnyVehicle(ped, true) and GetInteriorFromEntity(ped) == 0
    end

    -- GTA's switch-out to the sky (full motion, switch transition), else a plain fade.
    local function leave()
        if Config.Spawn.Transition ~= 'switch' or MC.prefs.motion ~= 'full' then return end
        SwitchOutPlayer(PlayerPedId(), 0, 1)
        local stop = GetGameTimer() + 8000
        while GetPlayerSwitchState() < 5 and GetGameTimer() < stop do Wait(0) end
    end

    -- The character being played, for the leaving poster (Play and a new character set it).
    function Relog.cast(first, last)
        local name = ('%s %s'):format(first or '', last or ''):match('^%s*(.-)%s*$')
        who = name ~= '' and name or nil
    end

    -- The leaving poster's facts: who, the kicker, the clock and where they stood.
    local function poster()
        local info = Spawn.where(GetEntityCoords(PlayerPedId()))
        local place = info.zone ~= '' and info.zone or info.street
        return {
            name = who or t('client.relog_title'), kicker = t('client.relog_kicker'),
            hour = GetClockHours() + GetClockMinutes() / 60, place = place ~= '' and place or t('client.relog_place'),
        }
    end

    -- The 'relogging' push (and a forced one): the leaving poster (red wipe in from the right, the name), the
    -- switch-out or a fade under it, then black; the player is hidden there.
    function Relog.forced(reason)
        if out then return end
        out = { reason = reason, done = false }
        if Admin.isOpen() then
            Admin.close(true)
            TriggerServerEvent('daddy_multichar:admin:close')
        end
        if State.is('appearance') then Bridge.appearance.cancel() end
        State.set('relogging')
        Links.suppress(true)
        if liveOut() then Live.leave(3200) end
        Nui.transition('relog', poster())
        shown = Nui.isOpen() and not Nui.failed()
        if shown then Wait(POSTER_MS) end
        leave()
        MC.fadeOut(400)
        if shown then MC.Send('mc:core:transition', { kind = 'relog', black = true }) end
        if IsPlayerSwitchInProgress() then StopPlayerSwitch() end
        Player.hide()
        Bridge.appearance.reset()
        out.done = true
    end

    -- The selection is built under the black: the red covers the poster and wipes out to the left over the cast.
    function Relog.reveal()
        if not shown then return end
        shown = false
        MC.Send('mc:core:transition', { kind = 'relog', out = true })
    end

    -- Waits for the cut to finish (the 'open' push may arrive during it), then forgets it.
    function Relog.settle(ms)
        local stop = GetGameTimer() + (ms or 12000)
        while out and not out.done and GetGameTimer() < stop do Wait(50) end
        out = nil
    end

    AddEventHandler('daddy_multichar:client:state', function(name)
        track(name == 'playing')
        if name == 'playing' then out = nil end
    end)

    RegisterNetEvent('daddy_multichar:relogging', function(data)
        CreateThread(function() Relog.forced(type(data) == 'table' and data.reason or nil) end)
    end)

    if Config.Relog.Enabled then
        RegisterCommand(Config.Commands.Relog, function() CreateThread(Relog.request) end, false)
        TriggerEvent('chat:addSuggestion', '/' .. Config.Commands.Relog, Core.locale.t('client.relog_help'))
    end
end
