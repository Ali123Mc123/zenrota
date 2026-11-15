-- qb-clothing: dresses any ped through its loader event; its first-character menu saves by itself.
local RESOURCE = 'qb-clothing'

return function()
    local adapter = {}

    -- qb-clothing reads every key it knows, so a skin without them falls back to the native dresser.
    function adapter.apply(ped, skin)
        if type(skin.face) ~= 'table' or type(skin.pants) ~= 'table' then return false end
        TriggerEvent('qb-clothing:client:loadPlayerClothing', skin, ped)
        return true
    end

    -- Its loader swaps the model in a thread of its own; wait for the swap.
    function adapter.applyPlayer(data)
        local model = math.tointeger(tonumber(data.model))
        if not model then return false end
        TriggerEvent('qb-clothes:loadSkin', nil, model, json.encode(data.skin))
        local deadline = GetGameTimer() + 5000
        while (GetEntityModel(PlayerPedId()) & 0xFFFFFFFF) ~= (model & 0xFFFFFFFF) do
            if GetGameTimer() > deadline then return false end
            Wait(50)
        end
        Wait(100)
        return true
    end

    -- The menu is open while IsCreatingCharacter is true; polled only for that time.
    function adapter.creator(_, session)
        TriggerEvent('qb-clothes:client:CreateFirstCharacter')
        CreateThread(function()
            local opened, deadline = false, GetGameTimer() + 10000
            while session.open do
                local ok, creating = pcall(function() return exports[RESOURCE]:IsCreatingCharacter() end)
                if not ok then return session.finish(false) end
                if creating then opened = true
                elseif opened then return session.finish(true)
                elseif GetGameTimer() > deadline then return session.finish(false) end
                Wait(250)
            end
        end)
        return true
    end

    return adapter
end
