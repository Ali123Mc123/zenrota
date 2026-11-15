local client = {}

client.notify = function(title, message, type)
    lib.notify({
        title = title,
        description = message,
        type = type,
    })
end

client.minigame = function(machine)
    local success = lib.skillCheck({
        'easy',
        'easy',
    }, {'1', '2', '3', '4'})
    return success
end

client.onExerciseStart = function(machine, repeatCount, animSpeed)
    LocalPlayer.state:set('invBusy', true, false)
    if GetResourceState('ox_target') == 'started' then
        exports.ox_target:disableTargeting(true)
    elseif GetResourceState('qb-target') == 'started' then
        exports['qb-target']:DisableTarget(true)
    end
end

client.onExerciseEnd = function(machine)
    LocalPlayer.state:set('invBusy', false, false)
    if GetResourceState('ox_target') == 'started' then
        exports.ox_target:disableTargeting(false)
    elseif GetResourceState('qb-target') == 'started' then
        exports['qb-target']:DisableTarget(false)
    end
end

client.boxingRing = {
    onFightStart = function()
        LocalPlayer.state:set('invBusy', true, false)
    end,

    onFightEnd = function(result)
        LocalPlayer.state:set('invBusy', false, false)
    end
}

return client
