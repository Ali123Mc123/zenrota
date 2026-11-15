-- What a camera changes on the player's own screen: filter, weather, time and the HUD. All of it goes back on close.
World = {}

local filters = {}
for _, f in ipairs(Config.Filters) do filters[f.id] = f end

local weather = DL.weather
local scene = { weather = nil, hour = nil, clock = nil }
local hudHidden = false
local filtered = false
local radarWasHidden = false

function World.filter(id, strength)
    local f = filters[id]
    if not f or not f.modifier then
        if filtered then ClearTimecycleModifier() end
        filtered = false
        return
    end
    filtered = true
    SetTimecycleModifier(f.modifier)
    SetTimecycleModifierStrength(math.max(0.0, math.min(1.0, tonumber(strength) or 1.0)))
end

-- The server's weather while the sync is paused, so pausing for the clock alone changes nothing else.
local function serverWeather()
    local w = GlobalState.weather
    return type(w) == 'table' and w.weather or 'EXTRASUNNY'
end

-- kind / hour nil = the server's own. Renewed locks the clock at 21:00 when paused, so the hour is held here.
function World.scene(kind, hour)
    scene.weather = kind
    scene.hour = tonumber(hour)
    if not kind and not scene.hour then
        scene.clock = nil
        return weather.resume()
    end
    if not weather.paused() then scene.clock = GetClockHours() + GetClockMinutes() / 60 end
    weather.pause(kind or serverWeather())
end

CreateThread(function()
    while true do
        local held = scene.hour or scene.clock
        if held and weather.paused() then
            local h = math.floor(held)
            NetworkOverrideClockTime(h, math.floor((held - h) * 60), 0)
            NetworkOverrideClockMillisecondsPerGameMinute(99999999)
            Wait(250)
        else
            Wait(1000)
        end
    end
end)

function World.hud(hidden)
    if hudHidden == hidden then return end
    hudHidden = hidden
    pcall(Config.Hud, hidden)
    if hidden then radarWasHidden = IsRadarHidden() end
    DisplayRadar(not hidden and not radarWasHidden)
    if not hidden then return end
    CreateThread(function()
        while hudHidden do
            HideHudAndRadarThisFrame()
            ThefeedHideThisFrame()
            Wait(0)
        end
    end)
end

function World.reset()
    World.filter('none')
    World.scene(nil, nil)
    World.hud(false)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then World.reset() end
end)
