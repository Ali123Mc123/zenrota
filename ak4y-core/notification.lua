function Notify(message, type)
    if Config.Notification == 'framework' and NotifyViaFramework ~= nil then
        NotifyViaFramework(message, type)
        return
    elseif Config.Notification == 'codem-notification' then
        TriggerEvent('codem-notification:Create', message, type, nil, 4000)
        return
    elseif Config.Notification == 'okokNotify' then
        exports['okokNotify']:Alert(message, '', 4000, type, false)
        return
    elseif Config.Notification == 'mythic' then
        exports['mythic_notify']:DoHudText(type, message)
        return
    elseif Config.Notification == '17mov' then
        exports["17mov_Hud"]:ShowNotification(message, type)
        return
    elseif Config.Notification == 'ox' then
        lib.notify({
            title = message,
            type = type,
            duration = 4000,
        })
        return
    end
    
    
    if type == 'error' then
        message = '~r~' .. message
    elseif type == 'warning' then
        message = '~y~' .. message
    elseif type == 'success' then
        message = '~g~' .. message
    end
    
    SetTextComponentFormat("STRING")
    AddTextComponentString(message)
    EndTextCommandDisplayHelp(0, 0, 0, -1)
end


RegisterNetEvent('ak4y-core:client:notify')
AddEventHandler('ak4y-core:client:notify', function(message, type)
    Notify(message, type or 'info')
end)