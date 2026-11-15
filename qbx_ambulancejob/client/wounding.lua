local config = require 'config.client'
local painkillerAmount = 0
local consumePainKillerLoop

lib.callback.register('hospital:client:UseIfaks', function()
    if lib.progressCircle({
            duration = 3000,
            position = 'bottom',
            label = locale('progress.ifaks'),
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = false,
                car = false,
                combat = true,
                mouse = false,
            },
            anim = {
                dict = 'mp_suicide',
                clip = 'pill',
            },
        })
    then
        TriggerServerEvent('hud:server:RelieveStress', math.random(12, 24))
        pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
        SetEntityHealth(cache.ped, GetEntityHealth(cache.ped) + 10)
        local wasOnPainKillers = OnPainKillers
        OnPainKillers = true
        exports.qbx_medical:DisableDamageEffects()
        if painkillerAmount < 3 then
            painkillerAmount += 1
        end
        if not wasOnPainKillers then
            consumePainKillerLoop()
        end
        if math.random(1, 100) < 50 then
            exports.qbx_medical:RemoveBleed(1)
        end
        return true
    else
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
        return false
    end
end)

lib.callback.register('hospital:client:UseBandage', function(item)
    local config = item and item.medicalConfig
    local progressLabel = (config and config.label or (item and item.label)) and
        ((config and config.label or item.label) .. ' kullanılıyor...') or locale('progress.bandage')

    local healthAdd = config and config.health or 10
    local bleedChance = config and config.bleedChance or 50
    local injuryChance = config and config.injuryChance or 7
    local duration = config and config.duration or 4000

    if lib.progressCircle({
            duration = duration,
            position = 'bottom',
            label = progressLabel,
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = false,
                car = false,
                combat = true,
                mouse = false,
            },
            anim = {
                dict = 'clothingshirt',
                clip = 'try_shirt_positive_a',
                flag = 49
            }
        })
    then
        local ped = PlayerPedId()
        pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
        SetEntityHealth(ped, math.min(GetEntityMaxHealth(ped), GetEntityHealth(ped) + healthAdd))

        if bleedChance > 0 and math.random(1, 100) < bleedChance then
            exports.qbx_medical:RemoveBleed(1)
        end

        if injuryChance > 0 and math.random(1, 100) < injuryChance then
            exports.qbx_medical:ResetMinorInjuries()
        end

        return true
    else
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
        return false
    end
end)

lib.callback.register('hospital:client:UsePainkillers', function()
    if lib.progressCircle({
            duration = 3000,
            position = 'bottom',
            label = locale('progress.painkillers'),
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = false,
                car = false,
                combat = true,
                mouse = false,
            },
            anim = {
                dict = 'mp_suicide',
                clip = 'pill',
            },
        })
    then
        local wasOnPainKillers = OnPainKillers
        OnPainKillers = true
        exports.qbx_medical:DisableDamageEffects()
        if painkillerAmount < 3 then
            painkillerAmount += 1
        end
        if not wasOnPainKillers then
            consumePainKillerLoop()
        end
        return true
    else
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
        return false
    end
end)

consumePainKillerLoop = function()
    CreateThread(function()
        while painkillerAmount > 0 do
            painkillerAmount -= 1
            Wait(config.painkillerInterval * 1000)
        end
        painkillerAmount = 0
        OnPainKillers = false
        exports.qbx_medical:EnableDamageEffects()
    end)
end

RegisterNetEvent('hospital:client:ApplyMedicineEffect', function(itemConfig)
    local healthAdd = itemConfig.health or 10
    local bleedChance = itemConfig.bleedChance or 50
    local injuryChance = itemConfig.injuryChance or 7

    local curHealth = GetEntityHealth(cache.ped)
    local maxHealth = GetEntityMaxHealth(cache.ped)
    local newHealth = curHealth + healthAdd

    if newHealth > maxHealth then newHealth = maxHealth end

    pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
    SetEntityHealth(cache.ped, math.floor(newHealth))

    if bleedChance > 0 and math.random(1, 100) < bleedChance then
        exports.qbx_medical:RemoveBleed(1)
    end

    if injuryChance > 0 and math.random(1, 100) < injuryChance then
        exports.qbx_medical:ResetMinorInjuries()
    end

    ClearPedBloodDamage(cache.ped)
    exports.qbx_core:Notify("EMS tarafından tedavi edildiniz.", 'success')
end)