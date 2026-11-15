-- DaddyRP: our 'daddy_venue:' server events go over lib.callback instead of a plain net event, see server/core/net.lua
local trigger = TriggerServerEvent

function TriggerServerEvent(name, ...)
    if type(name) == 'string' and name:sub(1, 12) == 'daddy_venue:' then
        return lib.callback('daddy_venue:net', false, function() end, name, ...)
    end
    return trigger(name, ...)
end
