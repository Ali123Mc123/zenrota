-- Nitro boost and exhaust flames.

local boosting, held = false, false

RegisterCommand('+mech_nitro', function()
    held = true
    local vehicle = cache.vehicle
    if boosting or not vehicle or cache.seat ~= -1 then return end
    local data = Entity(vehicle).state.dmech
    if not data or not (data.tuning and data.tuning.nitro) or (tonumber(data.nitro) or 0) <= 0 then return end
    local ok, ms = lib.callback.await('daddy_mechanic:nitroStart', false)
    if not ok then return end
    if not held then return TriggerServerEvent('daddy_mechanic:nitroStop') end
    boosting = true
    local stop = GetGameTimer() + ms
    AnimpostfxPlay('RaceTurbo', 0, true)
    CreateThread(function()
        while boosting and GetGameTimer() < stop and cache.vehicle == vehicle do
            SetVehicleCheatPowerIncrease(vehicle, Config.Nitro.Power)
            Wait(0)
        end
        if boosting then ExecuteCommand('-mech_nitro') end
    end)
end, false)

RegisterCommand('-mech_nitro', function()
    held = false
    if not boosting then return end
    boosting = false
    AnimpostfxStop('RaceTurbo')
    TriggerServerEvent('daddy_mechanic:nitroStop')
end, false)

RegisterKeyMapping('+mech_nitro', Core.t('ui.nitro_key'), 'keyboard', Config.Nitro.Key)

RegisterNetEvent('daddy_mechanic:nitroLeft', function(left)
    Bridge.notify(nil, Core.t('msg.nitro_left', math.floor(left)), 'info')
end)

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() and boosting then AnimpostfxStop('RaceTurbo') end
end)

local EXHAUSTS = { 'exhaust', 'exhaust_2', 'exhaust_3', 'exhaust_4' }
local flaming = {}

AddStateBagChangeHandler('dmech:boost', nil, function(bagName, _, on)
    if not on or flaming[bagName] then return end
    flaming[bagName] = true
    CreateThread(function()
        local vehicle = GetEntityFromStateBagName(bagName)
        for _ = 1, 20 do
            if vehicle ~= 0 then break end
            Wait(100)
            vehicle = GetEntityFromStateBagName(bagName)
        end
        if vehicle ~= 0 then
            lib.requestNamedPtfxAsset('core')
            while DoesEntityExist(vehicle) and Entity(vehicle).state['dmech:boost'] do
                for _, bone in ipairs(EXHAUSTS) do
                    local index = GetEntityBoneIndexByName(vehicle, bone)
                    if index ~= -1 then
                        UseParticleFxAssetNextCall('core')
                        StartParticleFxNonLoopedOnEntityBone('veh_backfire', vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, index, 1.2, false, false, false)
                    end
                end
                Wait(120)
            end
        end
        flaming[bagName] = nil
    end)
end)
