-- When this player dies at the hands of another player the server hears who, with what, and whether it was the
-- head. The server keeps it only when both are in gangs at war (server/modules/wars.lua).
local HEAD = 31086

AddEventHandler('gameEventTriggered', function(name, args)
    if name ~= 'CEventNetworkEntityDamage' then return end
    local victim, attacker, fatal, weapon = args[1], args[2], args[6] == 1, args[7]
    local ped = PlayerPedId()
    if victim ~= ped or not fatal or not attacker or attacker == ped or not IsPedAPlayer(attacker) then return end
    local player = NetworkGetPlayerIndexFromPed(attacker)
    if player == -1 then return end
    local hit, bone = GetPedLastDamageBone(ped)
    TriggerServerEvent('daddy_gangs:died', {
        killer = GetPlayerServerId(player),
        weapon = weapon,
        headshot = hit and bone == HEAD or false,
    })
end)
