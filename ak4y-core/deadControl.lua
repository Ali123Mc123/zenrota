local isPlayerDead = false

RegisterNetEvent('ak4y-core:SetDeathStatus', function(value)
    isPlayerDead = value
end)

exports('isPlayerDead', function()
    return isPlayerDead
end)

RegisterNetEvent('qbx_medical:client:playerRevived', function()
    TriggerEvent('ak4y-core:SetDeathStatus', false)
end)

RegisterNetEvent('qbx_medical:client:onPlayerLaststand', function()
    TriggerEvent('ak4y-core:SetDeathStatus', true)
end)