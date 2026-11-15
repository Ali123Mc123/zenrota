-- The Dorm app's "Arrange the Room": the phone goes away and Dorms' own editor opens (Dorms checks the player is in
-- their room).
RegisterNUICallback('phone:dormEditor', function(_, cb)
    local res = DL.product.resource('dorms')
    cb({ ok = res ~= nil })
    if not res then return end
    PhoneUI.close()
    SetTimeout(300, function()
        local ok = pcall(function() return exports[res]:OpenRoomEditor() end)
        if not ok then lib.notify({ description = DL.locale.t('errors.module_off'), type = 'error' }) end
    end)
end)
