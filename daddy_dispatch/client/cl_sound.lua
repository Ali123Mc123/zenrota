-- Sounds: which one an alert plays (the player's pick per priority, panic its own), how loud (their volume, half while
-- they shoot), and the game's police scanner. The page draws or plays the sound itself.
Sound = { shotAt = 0, played = {} }

local PANIC_LOCKED = Core.contains(Config.Prefs.Locks, 'sounds.panic')

-- Called when this player fires (cl_detect hears the game's gunshot event).
function Sound.shot()
    Sound.shotAt = GetGameTimer()
end

function Sound.forCall(call)
    local panic = call.panic and Config.Panic.Sound
    if Prefs.mute and not (panic and PANIC_LOCKED) then return end
    local own = Prefs.types[call.type]
    if own and own.off and not panic then return end
    local slot = panic and 'panic' or ('p' .. call.priority)
    local id = Prefs.sounds[slot]
    if not id or id == 'none' then return end
    -- The same sound waits Prefs.gap seconds (never a panic).
    local now = GetGameTimer()
    if not panic and Prefs.gap > 0 and Sound.played[id] and now - Sound.played[id] < Prefs.gap * 1000 then return end
    Sound.played[id] = now
    local volume = Prefs.volume / 100 * (Prefs.levels[slot] or 100) / 100 * (own and own.volume or 100) / 100
    if panic and PANIC_LOCKED then volume = math.max(volume, 0.6) end
    if Prefs.duck and now - Sound.shotAt < 10000 then volume = volume * 0.5 end
    Page.send('play', { sound = id, volume = volume, single = Prefs.single })
    if call.scanner and Prefs.scanner and Config.Scanner.Enabled then PlayPoliceReport(call.scanner, 0.0) end
end

-- An officer next to this player pressed panic: their radio goes off, softer with the distance (0 close, 1 far).
RegisterNetEvent('daddy_dispatch:near', function(far)
    if Prefs.mute then return end
    local volume = math.max(0.15, 1 - (tonumber(far) or 1)) * 0.8 * Prefs.volume / 100
    Page.send('play', { sound = 'radio', volume = volume, single = false })
end)

-- Debug: hear one of the game's police reports.
if Config.Debug then
    RegisterCommand('dispatchscanner', function(_, args)
        if args[1] then PlayPoliceReport(args[1], 0.0) end
    end, false)
end
