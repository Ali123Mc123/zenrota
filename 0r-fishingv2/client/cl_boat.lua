local Config <const> = require 'config.main'

Boat = nil

-- NUI CALLBACKS
RegisterNUICallback('RENT_BOAT', function(data, cb)
   lib.callback(Scriptname .. ':server:rentBoat', false, function(res)
      if res then
         Notify.SendNotify(_T("LUA.notifications.success.boat_rented"), 'success', 5000)

         local ped = cache.ped
         if not HasModelLoaded(`dinghy3`) then
            lib.requestModel(`dinghy3`, 10000)
         end

         local spawnCoords = nil
         local playerCoords = GetEntityCoords(ped)
         for k, v in pairs(Config.RentBoatLocations) do
            if #(playerCoords - vector3(v.coords.x, v.coords.y, v.coords.z)) < 50.0 then
               spawnCoords = v.spawnCoords
               break
            end
         end

         if not spawnCoords then
            Notify.SendNotify(_T("LUA.notifications.error.boat_not_found"), 'error', 5000)
            cb('error')
            return
         end

         pcall(function() exports['FeloxAC']:CreateVehicle(`dinghy3`) end) --[[FeloxAC:auto]]
         Boat = CreateVehicle(`dinghy3`, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w, true, true)
         SetPedIntoVehicle(ped, Boat, -1)
         SetVehicleEngineOn(Boat, true, true, true)
         Fuel.SetFuel(Boat, 100.0)
         VehicleKey.GiveKeys(Boat, GetVehicleNumberPlateText(Boat))
      else
         Notify.SendNotify(_T("LUA.notifications.error.not_enough_money"), 'error', 5000)
      end
      cb('ok')
   end)
end)

RegisterNUICallback('RETURN_BOAT', function(data, cb)
   if Boat then
      Notify.SendNotify(_T("LUA.notifications.success.boat_returned"), 'success', 5000)

      if DoesEntityExist(Boat) then
         DeleteEntity(Boat)
      end

      VehicleKey.RemoveKeys(Boat, GetVehicleNumberPlateText(Boat))

      Boat = nil
   end
   cb('ok')
end)