--[[ state ]]

Profile = {}

local playerProfile = {
    level = 0,
    exp = 0,
    nextLevelExp = 0,
    name = nil,
    illegal_nickname = nil,
    source = -1,
    photo = 1,
}

--[[ functions ]]

Profile.get = function()
    return playerProfile
end

Profile.fetch = function()
    local response = lib.callback.await(_e('server:profile:get'), false)
    if not response then return false end
    playerProfile = response
    return playerProfile
end

Profile.updateUI = function()
    client.sendReactMessage('ui:setUserProfile', playerProfile)
end

--[[ events ]]

RegisterNetEvent(_e('client:profile:onUpdate'), function(newProfile)
    playerProfile.exp = newProfile.exp
    playerProfile.level = newProfile.level
    playerProfile.nextLevelExp = newProfile.nextLevelExp
    client.sendReactMessage('ui:setUserProfile', playerProfile)
end)

RegisterNUICallback('nui:profile:updateIllegalNickName', function(newNickName, resultCallback)
    local response = lib.callback.await(_e('server:profile:updateIllegalNickName'), false, newNickName)
    if response.error then
        client.sendReactAlert(response.error, 'error')
        return resultCallback(false)
    end

    playerProfile.illegal_nickname = newNickName
    client.sendReactMessage('ui:setUserProfile', response.profile)
    resultCallback(true)
end)

RegisterNUICallback('nui:profile:updatePhoto', function(newPhoto, resultCallback)
    local response = lib.callback.await(_e('server:profile:updatePhoto'), false, newPhoto)
    if response.error then
        client.sendReactAlert(response.error, 'error')
        return resultCallback(false)
    end

    playerProfile.photo = newPhoto
    client.sendReactMessage('ui:setUserProfile', response.profile)

    if client.lobby.id then
        TriggerServerEvent(_e('server:profile:onProfilePhotoChanged'), client.lobby.id, newPhoto)
    end

    resultCallback(true)
end)
