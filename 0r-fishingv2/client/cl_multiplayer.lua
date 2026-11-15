RoomData = {}

-- Utility functions
local function deleteTaskBoat()
   if RoomData.game and RoomData.game.boatNetId and RoomData.game.boatNetId ~= 0 then
      local boat = NetworkGetEntityFromNetworkId(RoomData.game.boatNetId)
      if DoesEntityExist(boat) then
         DeleteEntity(boat)
      end

      VehicleKey.RemoveKeys(boat, GetVehicleNumberPlateText(boat))
   end
end

local function updateTeamData()
   NuiMessage('UPDATE_TEAM_DATA', {
      team = RoomData,
   })
end

local function fadeOutAndTeleport()
   DoScreenFadeOut(1000)
   while not IsScreenFadedOut() do
      Wait(1000)
   end

   local newCoords = vec4(-1818.98, -1214.87, 13.02, 46.75)
   pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
   SetEntityCoords(cache.ped, newCoords.x, newCoords.y, newCoords.z, false, false, false, false)
end

-- Events
AddEventHandler('onResourceStop', function(resource)
   if resource == GetCurrentResourceName() then
      deleteTaskBoat()
   end
end)

RegisterNetEvent(Scriptname .. ':client:updateRoomData', function(data)
   RoomData = data
   updateTeamData()
end)

RegisterNetEvent(Scriptname .. ':client:kickedRoom', function()
   local data = lib.callback.await(Scriptname .. ':server:createRoom', false)
   RoomData = data
   updateTeamData()
end)

RegisterNetEvent(Scriptname .. ':client:invitePlayer', function(data)
   SetNuiFocus(true, true)
   NuiMessage('INVITE_PLAYER', data)
end)

RegisterNetEvent(Scriptname .. ':client:showStatus', function()
   NuiMessage('SHOW_STATUS', {})
end)

RegisterNetEvent(Scriptname .. ':client:hideStatus', function()
   NuiMessage('HIDE_STATUS', {})
end)

RegisterNetEvent(Scriptname .. ':client:fadeOut', function()
   fadeOutAndTeleport()
end)

RegisterNetEvent(Scriptname .. ':client:fadeIn', function()
   DoScreenFadeIn(1000)
end)

RegisterNetEvent(Scriptname .. ':client:deleteTaskBoat', function()
   while not IsScreenFadedOut() do
      Wait(1000)
   end

   deleteTaskBoat()
   TriggerServerEvent(Scriptname .. ':server:fadeIn', RoomData.settings.ownerIdentifier)
   TriggerServerEvent(Scriptname .. ':server:resetTask', RoomData.settings.ownerIdentifier)
end)

RegisterNetEvent(Scriptname .. ':client:forceDeleteTaskBoat', function()
   deleteTaskBoat()
end)

-- NUI Callbacks
RegisterNUICallback('GET_TEAM_DATA', function(data, cb)
   if not RoomData or next(RoomData) == nil then
      RoomData = lib.callback.await(Scriptname .. ':server:createRoom', false)
      updateTeamData()
   end

   cb({
      status = true,
      team = RoomData,
   })
end)

RegisterNUICallback('STOP_MULTIPLAYER_TASK', function(data, cb)
   TriggerServerEvent(Scriptname .. ':server:stopMultiplayerTask')
   cb('ok')
end)

RegisterNUICallback('SELECT_MULTIPLAYER_TASK', function(data, cb)
   local taskId = data.taskId
   local result = lib.callback.await(Scriptname .. ':server:selectMultiplayerTask', false, taskId)


   Notify.SendNotify(result.message, result.success and 'success' or 'error', 5000)
   cb({
      status = result.success,
      message = result.message
   })
end)

RegisterNUICallback('CREATE_ROOM', function(data, cb)
   local result = lib.callback.await(Scriptname .. ':server:createRoom', false)
   RoomData = result
   updateTeamData()
   cb('ok')
end)

RegisterNUICallback('INVITE_PLAYER', function(data, cb)
   local targetId = data.targetId
   TriggerServerEvent(Scriptname .. ':server:invitePlayer', targetId)
   cb('ok')
end)

RegisterNUICallback('KICK_PLAYER', function(data, cb)
   local targetId = data.targetId
   TriggerServerEvent(Scriptname .. ':server:kickPlayer', targetId)
   cb('ok')
end)

RegisterNUICallback('LEAVE_TEAM', function(data, cb)
   TriggerServerEvent(Scriptname .. ':server:leaveTeam', RoomData.settings.ownerIdentifier)
   cb('ok')
end)

RegisterNUICallback('ACCEPT_INVITE', function(data, cb)
   SetNuiFocus(false, false)
   TriggerServerEvent(Scriptname .. ':server:acceptInvite', data)
   cb('ok')
end)

RegisterNUICallback('DECLINE_INVITE', function(data, cb)
   SetNuiFocus(false, false)
   TriggerServerEvent(Scriptname .. ':server:declineInvite', data)
   cb('ok')
end)

RegisterNUICallback('START_MULTIPLAYER_TASK', function(data, cb)
   TriggerServerEvent(Scriptname .. ':server:startMultiplayerTask')
   cb('ok')
end)

RegisterNUICallback('CHANGE_SETTINGS', function(data, cb)
   TriggerServerEvent(Scriptname .. ':server:changeSettings', data.settings)
   cb('ok')
end)