local QBX = nil

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    client.onPlayerLoad(true)
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    client.onPlayerLoad(false)
end)

-- Checks if the player is logged in based on local player state
---@return boolean isLoggedIn
function client.isPlayerLoaded()
    return LocalPlayer.state.isLoggedIn
end

function client.hasPlayerGotGroup(filter)
    if QBX then
        if type(filter) == 'table' then
            for k, v in pairs(filter) do
                local groupName = type(k) == 'number' and v or k
                if QBX:HasGroup(groupName) then
                    return true
                end
            end
            return false
        end
        return QBX:HasGroup(filter)
    end

    return false
end

if GetResourceState('qbx_core') == 'started' or GetResourceState('qbx_core') == 'starting' then
    QBX = exports.qbx_core
end
