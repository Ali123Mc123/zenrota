local identifier = GetCurrentResourceName()
local timeout = 3000
local pending = {}
local bound = {}
local lastId = 0

local function bindResponse(interface)
    if bound[interface] then return end
    bound[interface] = true

    AddEventHandler(('%s:%s:proxy_res'):format(interface, identifier), function(requestId, returns)
        local reply = pending[requestId]
        if reply then
            pending[requestId] = nil
            reply:resolve(returns)
        end
    end)
end

function vrpProxyCall(interface, member, ...)
    bindResponse(interface)

    lastId = lastId + 1
    local requestId = lastId
    local reply = promise.new()
    pending[requestId] = reply

    TriggerEvent(interface .. ':proxy', member, table.pack(...), identifier, requestId)

    if pending[requestId] then
        SetTimeout(timeout, function()
            if pending[requestId] then
                pending[requestId] = nil
                reply:resolve(false)
            end
        end)
    end

    local returns = Citizen.Await(reply)
    if returns then
        return true, returns[1]
    end

    return false
end
