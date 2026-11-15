--------------------------------
--- NUI CALLBACKS
--------------------------------

local isTakingFish = false -- Anti-spam flag for TAKE_IT / LET_FISH_GO

RegisterNUICallback('CHECKED_NUI', function(data, cb)
   NuiLoaded = true
   cb('ok')
end)

RegisterNUICallback('CLOSE_MENU', function(data, cb)
   SetNuiFocus(false, false)
   cb('ok')
end)

RegisterNUICallback('TAKE_IT', function(data, cb)
   if isTakingFish then cb('ok') return end
   isTakingFish = true

   if CaughtFish then
      TriggerServerEvent(Scriptname .. ':server:takeFish', CaughtFish)
   end
   SetNuiFocus(false, false)

   ClearAllObject()
   if UsingBait then
      local found = lib.callback.await(Scriptname .. ':server:checkBait', false)

      if not found then
         isTakingFish = false
         CleanupAndStopFishing()
         TriggerServerEvent(Scriptname .. ':server:stopFishing')
         return
      end
   else
      isTakingFish = false
      CleanupAndStopFishing()
      TriggerServerEvent(Scriptname .. ':server:stopFishing')
      return
   end

   CreateThread(function()
      Wait(500)
      isTakingFish = false
      CleanupAndRestartFishing()
   end)

   cb('ok')
end)

RegisterNUICallback('LET_FISH_GO', function(data, cb)
   if isTakingFish then cb('ok') return end
   isTakingFish = true

   if CaughtFish then
      TriggerServerEvent(Scriptname .. ':server:letFishGo', CaughtFish)
   end
   SetNuiFocus(false, false)

   ClearAllObject()
   if UsingBait then
      local found = lib.callback.await(Scriptname .. ':server:checkBait', false)

      if not found then
         isTakingFish = false
         CleanupAndStopFishing()
         TriggerServerEvent(Scriptname .. ':server:stopFishing')
         return
      end
   else
      isTakingFish = false
      CleanupAndStopFishing()
      TriggerServerEvent(Scriptname .. ':server:stopFishing')
      return
   end

   CreateThread(function()
      Wait(500)
      isTakingFish = false
      CleanupAndRestartFishing()
   end)

   cb('ok')
end)

RegisterNUICallback('UPGRADE_ROD', function(data, cb)
   TriggerServerEvent(Scriptname .. ':server:upgradeRod', data.level)
   cb('ok')
end)

RegisterNUICallback('STOP_FISHING', function(data, cb)
   CleanupAndStopFishing()
   TriggerServerEvent(Scriptname .. ':server:stopFishing')
   cb('ok')
end)
