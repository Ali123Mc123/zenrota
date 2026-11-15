can9work = can9work or {}
can9work.Functions = can9work.Functions or {}

can9work.Functions.SendLog = function(logType, message, data)
    TriggerServerEvent('can9work:DiscordLog:SendLog', logType, message, data)
end

-- Ölüm Tespiti
AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        local attacker = args[2]
        local isFatal = args[6] == 1 or GetEntityHealth(victim) <= 0
        local playerPed = PlayerPedId()

        if victim == playerPed and isFatal then
            local killerName = 'Bilinmiyor'
            local killerServerId = '-'
            local weaponHash = args[7] or GetSelectedPedWeapon(attacker)
            local coords = GetEntityCoords(playerPed)
            local street = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
            local streetName = GetStreetNameFromHashKey(street)

            if IsEntityAPed(attacker) then
                if IsPedAPlayer(attacker) then
                    killerServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker))
                    killerName = GetPlayerName(NetworkGetPlayerIndexFromPed(attacker))
                end
            elseif IsEntityAVehicle(attacker) then
                local driver = GetPedInVehicleSeat(attacker, -1)
                if driver ~= 0 and IsPedAPlayer(driver) then
                    killerServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(driver))
                    killerName = GetPlayerName(NetworkGetPlayerIndexFromPed(driver))
                end
            end

            TriggerServerEvent('can9work:DiscordLog:PlayerDeathDetailed', {
                playerName = GetPlayerName(PlayerId()),
                playerId = GetPlayerServerId(PlayerId()),
                killerName = killerName,
                killerServerId = killerServerId,
                weapon = weaponHash,
                coords = { x = coords.x, y = coords.y, z = coords.z },
                street = streetName
            })
        end
    end
end)

-- Export

exports('SendLog', function(logType, title, data)
    can9work.Functions.SendLog(logType, title, data)
end)
