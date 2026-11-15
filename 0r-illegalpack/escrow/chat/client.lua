RegisterNUICallback('nui:chat:getGlobalMessages', function(_, resultCallback)
    resultCallback(lib.callback.await(_e('server:chat:getGlobalMessages'), false))
end)

RegisterNUICallback('nui:chat:sendMessage', function(message, resultCallback)
    resultCallback(lib.callback.await(_e('server:chat:addMessage'), false, message))
end)
