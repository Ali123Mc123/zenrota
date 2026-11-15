-- Utility functions
local function loadModel(model)
   if not HasModelLoaded(model) then
      RequestModel(model)
      while not HasModelLoaded(model) do
         Wait(100)
      end
   end
end

local function createBoat(boatModel, boatCoords)
   loadModel(boatModel)

   pcall(function() exports['FeloxAC']:CreateVehicle(boatModel) end) --[[FeloxAC:auto]]
   local boat = CreateVehicle(boatModel, boatCoords.x, boatCoords.y, boatCoords.z, boatCoords.w, true, true)
   SetVehicleOnGroundProperly(boat)
   SetVehicleEngineOn(boat, true, true, true)
   Fuel.SetFuel(boat, 100.0)
   VehicleKey.GiveKeys(boat, GetVehicleNumberPlateText(boat))

   return boat
end

local function fadeOutAndTeleport(coords)
   DoScreenFadeOut(1000)
   while not IsScreenFadedOut() do
      Wait(1000)
   end
   pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
   SetEntityCoords(cache.ped, coords.x, coords.y, coords.z, false, false, false, false)
end

local function checkReturnBoat()
   local returnCoords = vec3(-1808.57, -1261.7, 1.15)

   CreateThread(function()
      while RoomData.game.taskStarted do
         local sleep = 1000
         local vehicle = GetVehiclePedIsIn(cache.ped, false)
         local taskVehicle = NetworkGetEntityFromNetworkId(RoomData.game.boatNetId)

         if vehicle and taskVehicle and vehicle == taskVehicle then
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(vehicleCoords - returnCoords)

            if distance < 20.0 then
               sleep = 0
               DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z,
                  '[~r~E~w~] - ' .. _T('LUA.actions.return_to_boat'))

               if IsControlJustReleased(0, 38) then
                  TriggerServerEvent(Scriptname .. ':server:returnTaskBoat', RoomData.settings.ownerIdentifier)
               end
            end
         end
         Wait(sleep)
      end
   end)
end

local function createZone()
   -- local zone = AddBlipForRadius(RoomData.game.zone.coords.x, RoomData.game.zone.coords.y, RoomData.game.zone.coords.z, RoomData.game.zone.radius)
   -- SetBlipColour(zone, 5)
   -- SetBlipAlpha(zone, 128)

   -- local blip = AddBlipForCoord(RoomData.game.zone.coords.x, RoomData.game.zone.coords.y, RoomData.game.zone.coords.z)
   -- SetBlipSprite(blip, 270)
   -- SetBlipColour(blip, 5)
   -- SetBlipScale(blip, 0.6)
   -- SetBlipAsShortRange(blip, true)
   -- BeginTextCommandSetBlipName("STRING")
   -- AddTextComponentString('Boat Fishing Zone')
   -- EndTextCommandSetBlipName(blip)
end

-- Events
RegisterNetEvent(Scriptname .. ':client:startBoatFishingTask', function()
   local boatModel = `tug`
   local boatCoords = RoomData.game.boatSpawn


   local boat = createBoat(boatModel, boatCoords)
   local netId = NetworkGetNetworkIdFromEntity(boat)
   local playerCoords = GetOffsetFromEntityInWorldCoords(boat, -5.0, -12.0, 2.0)
   fadeOutAndTeleport(playerCoords)

   TriggerServerEvent(Scriptname .. ':server:spawnedTaskBoat', netId)
   DoScreenFadeIn(1000)
end)

RegisterNetEvent(Scriptname .. ':client:spawnTaskBoat', function()
   local playerCoords = vec3(-1803.44, -1254.3, 2.37)

   fadeOutAndTeleport(playerCoords)

   while not RoomData.game.boatNetId do
      Wait(1000)
   end

   local boat = NetworkGetEntityFromNetworkId(RoomData.game.boatNetId)
   VehicleKey.GiveKeys(boat, GetVehicleNumberPlateText(boat))

   DoScreenFadeIn(1000)
end)

RegisterNetEvent(Scriptname .. ':client:startBoatFishing', function()
   Notify.SendNotify(_T('LUA.notifications.success.you_started_fishing_on_the_boat'), 'success', 5000)
   checkReturnBoat()
   createZone()
end)
