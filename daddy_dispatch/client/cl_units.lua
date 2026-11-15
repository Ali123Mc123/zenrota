-- My unit: the status picker and commands (/status, code7, /code), panic, pausing the dispatch for a while, and busy
-- when down.

-- Pause -----------------------------------------------------------------------------------------------------------------
do
    local KVP = 'daddy_dispatch:pause'

    -- Seconds left (-1: until opened, nil: open): the server counts with its own clock.
    local function left()
        if Pause.untilAt == -1 then return -1 end
        return Pause.untilAt and Pause.untilAt - Core.now() or nil
    end

    local function tell()
        Page.send('paused', { untilAt = Pause.untilAt })
        TriggerServerEvent('daddy_dispatch:pause', left())
    end

    -- minutes: 0 until opened again; nil opens it.
    function Pause.set(minutes)
        if minutes == nil then
            Pause.untilAt = nil
            DeleteResourceKvp(KVP)
            Bridge.notify(Core.t('msg.resumed'), 'success')
        else
            minutes = math.floor(Core.clamp(minutes, 0, 600))
            Pause.untilAt = minutes == 0 and -1 or Core.now() + minutes * 60
            SetResourceKvpInt(KVP, Pause.untilAt)
            Bridge.notify(minutes == 0 and Core.t('msg.paused_forever') or Core.t('msg.paused', minutes), 'info')
        end
        tell()
    end

    -- A pause from before a restart or relog still holds.
    local saved = GetResourceKvpInt(KVP)
    if saved == -1 or saved > Core.now() then Pause.untilAt = saved end

    -- A timed pause ends by itself.
    CreateThread(function()
        while true do
            Wait(5000)
            if Pause.untilAt and Pause.untilAt ~= -1 and Core.now() >= Pause.untilAt then Pause.set(nil) end
        end
    end)

    Page.on('pause', function(data)
        local minutes = tonumber(data.minutes)
        Pause.set(minutes and minutes >= 0 and minutes or nil)
        return { ok = true, untilAt = Pause.untilAt }
    end)

    Keys.map('pause', function()
        if not Me.unit then return end
        if Pause.on() then Pause.set(nil) else Pause.set(Prefs.pause) end
    end)

    -- The server learns of a pause from before (a relog, a restart) once the unit exists.
    OnMe(function(unit)
        if unit and Pause.on() and not unit.paused then TriggerServerEvent('daddy_dispatch:pause', left()) end
    end)
end

-- Status ----------------------------------------------------------------------------------------------------------------
Status = {}
do
    function Status.pick()
        if not Me.unit then return end -- silent: players who are not dispatch units never get a message
        Page.open('status', { statuses = Core.PICKABLE, kinds = Config.Units.Kinds })
    end

    Page.on('status', function(data)
        if Core.contains(Core.PICKABLE, data.status) then TriggerServerEvent('daddy_dispatch:status', data.status) end
        if data.kind then TriggerServerEvent('daddy_dispatch:kind', tostring(data.kind)) end
    end)

    Keys.map('status', Status.pick)
end

-- Codes and panic -------------------------------------------------------------------------------------------------------
do
    Keys.map('panic', function()
        if Me.unit then TriggerServerEvent('daddy_dispatch:code', '99') end
    end)
end

-- Down: the server makes the unit busy (Config.Units.BusyOnDeath). Looked at every two seconds, only while a unit.
CreateThread(function()
    local wasDown = false
    while true do
        Wait(2000)
        if Me.unit and Config.Units.BusyOnDeath then
            local down = Bridge.fw.isDown()
            if down and not wasDown then TriggerServerEvent('daddy_dispatch:down') end
            wasDown = down
        end
    end
end)
