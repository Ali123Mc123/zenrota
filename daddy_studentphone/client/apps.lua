-- Apps from other resources: messages from their resource to their open page, and their Live Activities.
local RESOURCE = GetCurrentResourceName()

RegisterNetEvent(RESOURCE .. ':appMessage', function(app, data)
    SendNUIMessage({ action = 'appMessage', app = app, data = data })
end)

RegisterNetEvent(RESOURCE .. ':activity', function(activity)
    if type(activity) == 'table' then SendNUIMessage({ action = 'activity', data = activity }) end
end)
