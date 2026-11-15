-- Apps from other resources: the server checks the class lock, then the app opens here or there.
local RESOURCE = GetCurrentResourceName()

RegisterNUICallback('phone:external', function(data, cb)
    local result = lib.callback.await(RESOURCE .. ':external', false, data.id)
    if type(result) ~= 'table' or not result.ok then
        cb(result or { ok = false })
        return
    end
    cb({ ok = true })
    PhoneUI.close()
    local target = result.client
    if not target then return end
    if target.event then TriggerEvent(target.event) end
    local res, fn = tostring(target.export or ''):match('^([^:]+):(.+)$')
    if res then pcall(function() exports[res][fn]() end) end
end)

-- School > Affairs: the election board opens in place of the phone (voting itself stays at the campus booths).
RegisterNUICallback('phone:election', function(_, cb)
    local res = DL.product.resource('election')
    cb({ ok = res ~= nil })
    if not res then return end
    PhoneUI.close()
    SetTimeout(300, function() pcall(function() exports[res]:OpenBoard() end) end)
end)
