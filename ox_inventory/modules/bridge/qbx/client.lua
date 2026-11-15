AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(cache.serverId), function(_, _, value)
    if not value then client.onLogout() end
end)

RegisterNetEvent('qbx_core:client:onGroupUpdate', function(groupName, groupGrade)
    local groups = PlayerData.groups
    if not groupGrade then
        groups[groupName] = nil
    else
        groups[groupName] = groupGrade
    end

    local QBX = exports.qbx_core
    local jobs = QBX:GetJobs()
    if jobs and jobs[groupName] then
        local jobType = jobs[groupName].type
        if jobType then
            if groupGrade then
                groups[jobType] = 0
            else
                groups[jobType] = nil
            end
        end
    end

    local gangs = QBX:GetGangs()
    if gangs and gangs[groupName] then
        local gangType = gangs[groupName].type
        if gangType then
            if groupGrade then
                groups[gangType] = 0
            else
                groups[gangType] = nil
            end
        end
    end

    client.setPlayerData('groups', groups)
end)

RegisterNetEvent('qbx_core:client:setGroups', function(groups)
    local QBX = exports.qbx_core
    local jobs = QBX:GetJobs()
    local gangs = QBX:GetGangs()

    for groupName, groupGrade in pairs(groups) do
        if jobs and jobs[groupName] then
            local jobType = jobs[groupName].type
            if jobType then groups[jobType] = 0 end
        end
        if gangs and gangs[groupName] then
            local gangType = gangs[groupName].type
            if gangType then groups[gangType] = 0 end
        end
    end

    client.setPlayerData('groups', groups)
end)

---@diagnostic disable-next-line: duplicate-set-field
function client.getPlayerInfo()
    local player = exports.qbx_core:GetPlayerData()
    return {
        name = player and player.charinfo and ('%s %s'):format(player.charinfo.firstname, player.charinfo.lastname) or GetPlayerName(PlayerId()),
        id = cache.serverId,
        cash = player and player.money and player.money.cash or 0,
        bank = player and player.money and player.money.bank or 0,
        avatar = PlayerData.avatar
    }
end

---@diagnostic disable-next-line: duplicate-set-field
function client.setPlayerStatus(values)
    local playerState = LocalPlayer.state
    for name, value in pairs(values) do
        -- compatibility for ESX style values
        if value > 100 or value < -100 then
            value = value * 0.0001
        end

        playerState:set(name, lib.math.clamp(playerState[name] + value, 0, 100), true)
    end
end
