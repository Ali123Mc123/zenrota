-- Portrait or landscape: the page decides (only some apps turn), the hand follows; a key asks the page to turn.
RegisterNUICallback('phone:orientation', function(data, cb)
    cb({ ok = true })
    if PhoneUI.open then Pose.set('landscape', data.landscape == true) end
end)

RegisterCommand('studentphone_rotate', function()
    if PhoneUI.open then SendNUIMessage({ action = 'rotate' }) end
end, false)

RegisterKeyMapping('studentphone_rotate', DL.locale.t('command.rotate'), 'keyboard', Config.Rotate.Key)
