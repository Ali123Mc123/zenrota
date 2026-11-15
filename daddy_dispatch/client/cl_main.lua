-- Client core: the page (messages, callbacks, focus), the player's own settings (kept on this PC, with the server's
-- locks), the names of their keys, their unit, and notices.
Page = { ready = false, screen = nil, closers = {} }
Me = { unit = false }

-- Others that want to hear of my unit (cl_units, cl_operator) add a function here: daddy_dispatch:me has one handler
-- only (in this file). With several RegisterNetEvent handlers for the same event, an anti-cheat that wraps
-- RegisterNetEvent (FeloxAC clientEvent guard) may keep only the last one, and then Me.unit never gets set.
MeListeners = {}
function OnMe(fn) MeListeners[#MeListeners + 1] = fn end

-- Every dispatch command runs in a thread of this resource. Typed in the chat, um-chat runs it with ExecuteCommand,
-- so inside the handler the invoking resource is um-chat; a TriggerServerEvent from there never reached the server
-- (the anti-cheat's server event guard drops it as another resource triggering our events): /kod, /dp did nothing.
function Command(name, fn)
    RegisterCommand(name, function(src, args, raw)
        CreateThread(function() fn(src, args, raw) end)
    end, false)
end

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

    RegisterNetEvent('daddy_dispatch:notice', function(key, tone, ...)
        Bridge.notify(Core.t(key, ...), tone)
    end)
end

-- Screens: one at a time has the mouse (list, settings, desk, card, status). The list keeps walking and driving.
do
    local looping = false

    local function hold()
        if looping then return end
        looping = true
        CreateThread(function()
            while Page.screen == 'list' do
                DisableControlAction(0, 1, true)
                DisableControlAction(0, 2, true)
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 257, true)
                Wait(0)
            end
            looping = false
        end)
    end

    function Page.open(screen, data)
        if Page.screen and Page.screen ~= screen then Page.close(Page.screen) end
        Page.screen = screen
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(screen == 'list')
        if screen == 'list' then hold() end
        data = data or {}
        data.on = true
        Page.send(screen, data)
    end

    function Page.close(screen)
        if not screen or Page.screen ~= screen then return end
        Page.screen = nil
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        Page.send(screen, { on = false })
        if Page.closers[screen] then Page.closers[screen]() end
    end

    -- The page closed a screen itself (Esc, a button).
    Page.on('close', function(data)
        Page.close(data.screen)
    end)

    AddEventHandler('onResourceStop', function(name)
        if name == GetCurrentResourceName() and Page.screen then SetNuiFocus(false, false) end
    end)
end

-- The player's settings: Prefs is data only (it goes to the page and the KVP as JSON); Settings changes it.
Prefs = Core.copy(Config.Prefs.Defaults)
Settings = {}
do
    local KVP = 'daddy_dispatch:prefs'
    local RANGES = { size = { 80, 130 }, dark = { 40, 100 }, life = { 1, 5 }, max = { 1, 5 }, volume = { 0, 100 }, pause = { 0, 600 }, prio = { 1, 3 }, km = { 0, 20 }, gap = { 0, 120 } }
    local CHOICES = {
        type = { plate = true, thin = true, row = true }, place = { tr = true, tc = true, tl = true, r = true, br = true, bl = true },
        motion = { slide = true, fade = true, none = true },
    }
    local KINDS = { weapons = true, vehicle = true, robbery = true, fight = true, citizen = true, ems = true, officer = true, other = true }
    local SOUNDS = { none = true }
    for _, s in ipairs(Config.Sounds) do SOUNDS[s.id] = true end

    local function locked(path) return Core.contains(Config.Prefs.Locks, path) end

    -- One value checked against the defaults' kind; nil when it does not fit.
    local function check(key, value)
        local default = Config.Prefs.Defaults[key]
        if RANGES[key] then return tonumber(value) and math.floor(Core.clamp(value, RANGES[key][1], RANGES[key][2])) or nil end
        if key == 'place' and type(value) == 'table' and tonumber(value.x) and tonumber(value.y) then
            return { x = Core.clamp(value.x, 0, 1), y = Core.clamp(value.y, 0, 1) }
        end
        if CHOICES[key] then return CHOICES[key][value] and value or nil end
        if type(default) == 'boolean' then
            if type(value) == 'boolean' then return value end
            return nil
        end
        if key == 'rows' and type(value) == 'table' then
            local out = {}
            for row, on in pairs(default) do out[row] = value[row] == nil and on or value[row] == true end
            return out
        end
        if key == 'sounds' and type(value) == 'table' then
            local out = {}
            for slot, id in pairs(default) do
                out[slot] = (not locked('sounds.' .. slot) and SOUNDS[value[slot]]) and value[slot] or id
            end
            return out
        end
        if key == 'kinds' and type(value) == 'table' then
            local out = {}
            for kind, off in pairs(value) do
                if KINDS[kind] and off == true then out[kind] = true end
            end
            return out
        end
        if key == 'accent' then
            return (value == '' or Core.contains(Config.Prefs.Accents, value)) and value or nil
        end
        if key == 'levels' and type(value) == 'table' then
            local out = {}
            for slot, level in pairs(default) do out[slot] = math.floor(Core.clamp(value[slot] or level, 0, 100)) end
            return out
        end
        -- Per alert type: off, and / or its own volume.
        if key == 'types' and type(value) == 'table' then
            local out = {}
            for name, v in pairs(value) do
                if Config.Alerts[name] and type(v) == 'table' then
                    local own = { off = v.off == true or nil, volume = Core.num(v.volume) and math.floor(Core.clamp(v.volume, 0, 100)) or nil }
                    if own.off or own.volume then out[name] = own end
                end
            end
            return out
        end
        -- Where the operator panel sits: screen fractions, size in px, scale in percent.
        if key == 'operator' and type(value) == 'table' then
            return {
                x = Core.clamp(value.x, 0, 1), y = Core.clamp(value.y, 0, 1), w = math.floor(Core.clamp(value.w, 220, 700)),
                h = math.floor(Core.clamp(value.h, 160, 900)), scale = math.floor(Core.clamp(value.scale, 70, 150)),
            }
        end
        return nil
    end

    -- Takes what fits from a table of settings; locked ones stay as the server set them.
    local function merge(into, from)
        for key in pairs(Config.Prefs.Defaults) do
            if from[key] ~= nil and not locked(key) then
                local value = check(key, from[key])
                if value ~= nil then into[key] = value end
            end
        end
    end

    merge(Prefs, Core.decode(GetResourceKvpString(KVP)))
    -- Once: an alert's time saved from before it could pass 3 s goes to the server's default (DaddyRP 5 s).
    if GetResourceKvpInt(KVP .. ':life5') ~= 1 then
        Prefs.life = Config.Prefs.Defaults.life
        SetResourceKvpInt(KVP .. ':life5', 1)
        if GetResourceKvpString(KVP) then SetResourceKvp(KVP, json.encode(Prefs)) end
    end

    function Settings.save(from)
        merge(Prefs, from)
        SetResourceKvp(KVP, json.encode(Prefs))
    end

    function Settings.reset()
        for key, value in pairs(Config.Prefs.Defaults) do Prefs[key] = Core.copy(value) end
        DeleteResourceKvp(KVP)
    end

    -- The page saves a change; it gets the settings back as kept.
    Page.on('prefs', function(data)
        if data.reset then Settings.reset() else Settings.save(type(data.prefs) == 'table' and data.prefs or {}) end
        return { ok = true, prefs = Prefs }
    end)
end

-- Keys ------------------------------------------------------------------------------------------------------------------
Keys = { commands = {} }
-- A new name drops the key players saved for it (FiveM keeps a saved key over a new default): hide was G.
local RENAMED = { hide = '_v2' }
do
    -- A key mapping for an action: the command (never typed by players) and its default key.
    function Keys.map(action, fn)
        local command = 'daddy_dispatch_' .. action .. (RENAMED[action] or '')
        Keys.commands[action] = command
        Command(command, fn)
        RegisterKeyMapping(command, Core.t('keys.' .. action), 'keyboard', Config.Keys[action:sub(1, 1):upper() .. action:sub(2)] or '')
        TriggerEvent('chat:removeSuggestion', '/' .. command)
    end

    -- The key each action has now ('t_Z' -> 'Z'); empty when none.
    function Keys.labels()
        local out = {}
        for action, command in pairs(Keys.commands) do
            local label = GetControlInstructionalButton(0, joaat(command) | 0x80000000, true) or ''
            label = label:gsub('^t_', '')
            out[action] = label:sub(1, 2) == 'b_' and (Config.Keys[action:sub(1, 1):upper() .. action:sub(2)] or '') or label
        end
        return out
    end
end

-- Boot and my unit ------------------------------------------------------------------------------------------------------
do
    -- Every alert type a player can give its own sound setting, in code order.
    local alerts = {}
    for name, def in pairs(Config.Alerts) do
        if name ~= 'custom' then alerts[#alerts + 1] = { type = name, code = def.code, priority = def.priority, kind = def.kind } end
    end
    table.sort(alerts, function(a, b) return a.kind == b.kind and a.type < b.type or a.kind < b.kind end)

    -- The page shows commands under the single /dp command.
    local function primaryCommands()
        local cmd = Config.Command or 'dp'
        return {
            Desk = cmd,
            Settings = cmd .. 'ayar',
            Status = cmd .. 'durum',
            Busy = cmd .. '7',
            Code = cmd .. 'kod',
            Pause = cmd .. 'kapat',
            Resume = cmd .. 'ac',
            Operator = cmd .. 'op',
            Reply = cmd .. 'r',
        }
    end

    -- The page boots once: its texts, the accent, the settings and what can be chosen.
    Page.on('boot', function()
        Page.ready = true
        local sounds = {}
        for _, s in ipairs(Config.Sounds) do
            sounds[#sounds + 1] = { id = s.id, synth = s.synth, file = s.file, label = s.label }
        end
        SetTimeout(500, function() TriggerServerEvent('daddy_dispatch:hello') end)
        return {
            locale = Core.locale(), lang = Core.language(), theme = { accent = Config.Theme.Accent },
            prefs = Prefs, defaults = Config.Prefs.Defaults, locks = Config.Prefs.Locks, sounds = sounds, keys = Keys.labels(),
            kinds = Config.Units.Kinds, results = Config.Calls.Results, commands = primaryCommands(), me = Me,
            scanner = Config.Scanner.Enabled, anonymous = Config.Citizen.Anonymous, maxText = Config.Citizen.MaxLength,
            paused = Pause and Pause.untilAt, accents = Config.Prefs.Accents, activeAt = Config.Calls.Group.Active,
            suggest = Config.Calls.Suggest, alerts = alerts,
        }
    end)

    RegisterNetEvent('daddy_dispatch:me', function(unit)
        local was = Me.unit
        Me.unit = unit and true or false
        for k in pairs(Me) do
            if k ~= 'unit' then Me[k] = nil end
        end
        if unit then
            for k, v in pairs(unit) do Me[k] = v end
        end
        Page.send('me', { me = Me })
        if was and not Me.unit and Calls then Calls.clear() end
        for _, fn in ipairs(MeListeners) do
            local ok, err = pcall(fn, unit)
            if not ok then Bridge.warn('me: %s', err) end
        end
    end)

    -- The unit is also asked for without the page: if the page never boots (a NUI error), Me.unit would stay false
    -- and every command (/kod, /dp...) would stay silent.
    CreateThread(function()
        while not NetworkIsPlayerActive(PlayerId()) do Wait(500) end
        Wait(8000)
        if not Me.unit then TriggerServerEvent('daddy_dispatch:hello') end
    end)

    -- After a job or duty change the server reads the unit again.
    CreateThread(function()
        Bridge.fw.onChange(function()
            SetTimeout(1000, function() TriggerServerEvent('daddy_dispatch:hello') end)
        end)
    end)
end

-- The server's clock: os.time on the server and GetCloudTimeAsInt here are both Unix seconds.
function Core.now()
    return GetCloudTimeAsInt()
end
