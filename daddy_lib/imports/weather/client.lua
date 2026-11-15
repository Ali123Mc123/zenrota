-- Hands weather and time to a scene and back: Renewed-Weathersync, qb-weathersync or cd_easytime, else nothing.
local weather = {}
local paused, before = false, nil

local function renewed()
    return GetResourceState('Renewed-Weathersync') == 'started'
end

-- Renewed provides qb-weathersync and cd_easytime too, so it is asked first.
local function sync(on)
    if renewed() then
        LocalPlayer.state.syncWeather = on
    elseif GetResourceState('qb-weathersync') == 'started' then
        TriggerEvent(on and 'qb-weathersync:client:EnableSync' or 'qb-weathersync:client:DisableSync')
    elseif GetResourceState('cd_easytime') == 'started' then
        TriggerEvent('cd_easytime:PauseSync', not on)
    end
end

-- The scene's weather type; paused Renewed re-applies its playerWeather every 2.5 s, so it is written there too.
function weather.set(kind)
    if type(kind) ~= 'string' or kind == '' then return false end
    if paused and renewed() then
        if before == nil then before = LocalPlayer.state.playerWeather or false end
        LocalPlayer.state.playerWeather = kind
    end
    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypeNowPersist(kind)
    return true
end

-- pause(kind?) stops the sync; kind is the weather the scene holds meanwhile.
function weather.pause(kind)
    if not paused then
        paused = true
        sync(false)
    end
    if kind then weather.set(kind) end
end

function weather.resume()
    if not paused then return end
    paused = false
    if before ~= nil then LocalPlayer.state.playerWeather = before or nil end
    before = nil
    sync(true)
end

function weather.paused()
    return paused
end

-- A product that stops mid-scene gives the sync back.
AddEventHandler('onResourceStop', function(resource)
    if resource == DL.resource then weather.resume() end
end)

return weather
