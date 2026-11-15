CreateThread(function()
    while not CodeLoaded do Wait(500) end

    local function is_dead()
        return PhoneClient and PhoneClient.isDead
    end
    
    local function OnDeath()
        -- if PhoneClient.isDead then return end
        local data = LocalPlayer.state.callData
        if data then
            TriggerServerEvent('cylex_phone:server:startConversation', data.targetNumber, "reject")
        end
    
        if PhoneClient.isOpen then
            DoPhoneAnimation("exit")
            TriggerEvent('cylex_phone:client:openPhone', false)
        end
    end
    
    
    local function set_dead()
        PhoneClient.isDead = true
    
        OnDeath()
    
        while IsPedDeadOrDying(PlayerPedId(), false) do
            Wait(500)
        end
    
        PhoneClient.isDead = false
    end
    
    AddEventHandler("CEventDeath", function(entities, entity, data)
        if entities[1] == PlayerPedId() and not is_dead() then
            set_dead()
        end
    end)
    
    AddEventHandler("CEventEntityDamaged", function()
        if IsPedDeadOrDying(PlayerPedId(), false) and not is_dead() then
            set_dead()
        end
    end)
    
    AddStateBagChangeHandler('isDead', nil, function(bagName, key, data)
        local playerSrc = tonumber(bagName:sub(8))
        if GetPlayerServerId(PlayerId()) ~= playerSrc then return end
        if data == false then return end
        while PhoneClient == nil do Wait(500) end
        if not PhoneClient.isOpen then return end
        OnDeath()
    end)
end)
