-- skinchanger with esx_skin. skinchanger only dresses the player ped, so previews use the native dresser.
return function()
    local adapter = {}

    -- Starts an event that answers through a callback; false after ms without an answer.
    local function await(start, ms)
        local p, settled = promise.new(), false
        local function settle(value)
            if settled then return end
            settled = true
            p:resolve(value)
        end
        start(function() settle(true) end)
        SetTimeout(ms, function() settle(false) end)
        return Citizen.Await(p)
    end

    function adapter.applyPlayer(data)
        return await(function(done) TriggerEvent('skinchanger:loadSkin', data.skin, done) end, 10000)
    end

    -- loadSkin records the sex esx_skin saves (the default model alone does not); a frame lets it finish before the menu reads it.
    function adapter.creator(gender, session)
        if GetResourceState('esx_skin') ~= 'started' then return false end
        local skin = { sex = gender == 'f' and 1 or 0 }
        if not await(function(done) TriggerEvent('skinchanger:loadSkin', skin, done) end, 10000) then return false end
        Wait(0)
        TriggerEvent('esx_skin:openSaveableMenu', function() session.finish(true) end, function() session.finish(false) end)
        return true
    end

    return adapter
end
