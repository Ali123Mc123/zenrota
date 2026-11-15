local stats = nil

local function ResetRechargeMultipliers()
    SetPlayerHealthRechargeMultiplier(cache.playerId, 0.0)
    SetPlayerHealthRechargeLimit(cache.playerId, 0.0)
end

function BackupPlayerStats()
    stats = {
        health = GetEntityHealth(cache.ped),
        armour = GetPedArmour(cache.ped)
    }
end

function RestorePlayerStats()
    if not stats then
        Framework.RestorePlayerArmour()
        return
    end

    local s = stats
    stats = nil

    SetEntityMaxHealth(cache.ped, 200)
    Wait(1000)

    if s.health ~= nil then
        pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
        SetEntityHealth(cache.ped, s.health)
    end
    if s.armour ~= nil then
        pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
        SetPedArmour(cache.ped, s.armour)
    end

    ResetRechargeMultipliers()
end
