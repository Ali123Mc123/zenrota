-- One NUI owner at a time. The previous owner is told to close first.
local owner = nil

exports('acquireFocus', function()
    local resource = GetInvokingResource()
    if owner and owner ~= resource then TriggerEvent('daddy_lib:focus:revoke', owner) end
    owner = resource
    return true
end)

exports('releaseFocus', function()
    if owner == GetInvokingResource() then owner = nil end
end)

exports('focusOwner', function() return owner end)

AddEventHandler('onClientResourceStop', function(resource)
    if owner == resource then owner = nil end
end)
