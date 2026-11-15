AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        local attacker = args[2]
        local playerPed = PlayerPedId()

        if IsEntityAVehicle(attacker) then
            attacker = GetPedInVehicleSeat(attacker, -1)
        end

        if victim == playerPed and attacker ~= playerPed and IsPedAPlayer(attacker) then
            TriggerServerEvent('can9work:checkDamage:server:PlayerDamaged')
        end
    end
end)
