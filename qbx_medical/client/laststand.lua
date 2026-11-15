local config = require 'config.client'
local sharedConfig = require 'config.shared'

function WaitForPlayerToStopMoving()
    local timeOut = 10000
    while GetEntitySpeed(cache.ped) > 0.1 and IsPedRagdoll(cache.ped) and timeOut > 1 do
        timeOut -= 10
        Wait(10)
    end
end

function ResurrectPlayer()
    local pos = GetEntityCoords(cache.ped)
    local heading = GetEntityHeading(cache.ped)
    pcall(function() exports['FeloxAC']:playerRevived() end) --[[FeloxAC:auto]]
    NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z + 0.5, heading, true, false)
    if cache.vehicle then
        SetPedIntoVehicle(cache.ped, cache.vehicle, cache.seat)
    end
end

function EndLastStand()
    LaststandTime = 0
end

function StartLastStand(attacker, weapon)
    if (GetResourceState('BakiTelli_paintballv2') == 'started' and exports['BakiTelli_paintballv2']:inGameStatus()) then return end
    DeathTime = config.deathTime
    OnDeath(attacker, weapon)
end

exports('StartLastStand', StartLastStand)