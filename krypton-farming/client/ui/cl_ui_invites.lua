-- Cached player data for use in debug invites (set by openUI in cl_ui_nui.lua)
CachedPlayerData = nil

RegisterNetEvent('krypton-farming:client:requestOpen', function()
    RefreshNearbyPlayerNames(function()
        -- UI can be opened even with active job (for quit/continue options)
        TriggerServerEvent('krypton-farming:server:requestData', ClientState.activeNpcIndex or 1)
    end)
end)

local NearbyPlayerNames = {} -- [serverId] = characterName
local NearbyPlayersReady = false
local _lastNearbyRequest = 0  -- getNearbyPlayerNames debounce (3 sn)

function RefreshNearbyPlayerNames(callback)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearbyServerIds = {}
    
    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            
            if distance < 5.0 then
                local serverId = GetPlayerServerId(playerId)
                table.insert(nearbyServerIds, serverId)
            end
        end
    end
    
    if #nearbyServerIds > 0 then
        local now = GetGameTimer()
        if (now - _lastNearbyRequest) > 3000 then
            _lastNearbyRequest = now
            TriggerServerEvent('krypton-farming:server:getNearbyPlayerNames', nearbyServerIds)
        end
        -- Give server time to respond (100ms should be enough)
        SetTimeout(150, function()
            NearbyPlayersReady = true
            if callback then callback() end
        end)
    else
        NearbyPlayersReady = true
        if callback then callback() end
    end
end

function GetNearbyPlayers()
    local players = {}
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearbyServerIds = {}
    
    if Config.Debug then
        table.insert(players, {
            id = -1,
            name = 'Debug Player 1',
            distance = 5,
            isDebug = true
        })
        table.insert(players, {
            id = -2,
            name = 'Debug Player 2',
            distance = 8,
            isDebug = true
        })
        table.insert(players, {
            id = -3,
            name = 'Debug Player 3',
            distance = 12,
            isDebug = true
        })
    end
    
    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            
            if distance < 5.0 then
                local serverId = GetPlayerServerId(playerId)
                table.insert(nearbyServerIds, serverId)
                table.insert(players, {
                    id = serverId,
                    name = NearbyPlayerNames[serverId] or GetPlayerName(playerId), -- Fallback to steam name until server responds
                    distance = math.floor(distance),
                    isDebug = false
                })
            end
        end
    end
    
    if #nearbyServerIds > 0 then
        local now = GetGameTimer()
        if (now - _lastNearbyRequest) > 3000 then
            _lastNearbyRequest = now
            TriggerServerEvent('krypton-farming:server:getNearbyPlayerNames', nearbyServerIds)
        end
    end
    
    return players
end

RegisterNetEvent('krypton-farming:client:receivePlayerNames', function(playerNames)
    for serverId, charName in pairs(playerNames) do
        NearbyPlayerNames[serverId] = charName
    end
    
    if ClientState.isUiOpen then
        local updatedPlayers = GetNearbyPlayers()
        SendNUIMessage({
            action = 'updateNearbyPlayers',
            data = updatedPlayers
        })
    end
end)

RegisterNUICallback('refreshNearbyPlayers', function(_, cb)
    RefreshNearbyPlayerNames(function()
        local players = GetNearbyPlayers()
        SendNUIMessage({
            action = 'updateNearbyPlayers',
            data = players
        })
    end)
    cb('ok')
end)

RegisterNUICallback('invitePlayer', function(data, cb)
    if data.targetId then
        if data.targetId < 0 then
            local debugPlayerName = 'Debug Player ' .. math.abs(data.targetId)
            
            local myName = CachedPlayerData and CachedPlayerData.name or 'Leader'
            local myLevel = CachedPlayerData and CachedPlayerData.level or 1
            
            SendNUIMessage({
                action = 'updateGroupMembers',
                data = {
                    {
                        id = GetPlayerServerId(PlayerId()),
                        name = myName,
                        level = myLevel,
                        share = 70,
                        status = 'Working',
                        leader = true
                    },
                    {
                        id = data.targetId,
                        name = debugPlayerName,
                        level = 1,
                        share = 30,
                        status = 'Working',
                        leader = false
                    }
                }
            })
            
            if Config.Debug then
            end
            
            Krypton.Notify('Added ' .. debugPlayerName .. ' to group (Debug Mode)', 'success')
        else
            TriggerServerEvent('krypton-farming:server:invitePlayer', data.targetId)
        end
    end
    cb('ok')
end)

RegisterNUICallback('acceptInvite', function(_, cb)
    -- If NPC dialog/menu is open, close it cleanly before joining the group
    if ClientState.isUiOpen then
        ClientState.isUiOpen = false
        DestroyDialogueCam()
        SendNUIMessage({ action = 'close' })
    end
    SetNuiFocus(false, false) -- Release focus after response
    TriggerServerEvent('krypton-farming:server:acceptInvite')
    cb('ok')
end)

RegisterNUICallback('declineInvite', function(_, cb)
    -- If NPC dialog was open before invite, restore focus to it
    if ClientState.isUiOpen then
        SetNuiFocus(true, true)
    else
        SetNuiFocus(false, false)
    end
    TriggerServerEvent('krypton-farming:server:declineInvite')
    cb('ok')
end)
