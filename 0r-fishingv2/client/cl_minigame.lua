local StartingFishing = false
local IsFishing = false
local isPullingRope = false
local currentFishDistance = 0
local rodDistance = 0
local MinigameStartTime = 0

local Items <const> = require 'config.items'
local Config <const> = require 'config.main'

-- Utility functions
local function getFishZ(fishCoords)
   local x, y, z = fishCoords.x, fishCoords.y, fishCoords.z + 10.0
   local hitGround, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
   local isInWater, waterZ = TestVerticalProbeAgainstAllWater(x, y, z, 0)
   return isInWater and waterZ or (hitGround and groundZ or z)
end

local function getAvailableFishItems(level, lucky)
   local fishItems = {}
   if lucky then
      for _, v in pairs(Items.LuckyItems) do
         fishItems[#fishItems + 1] = v
      end
   else
      for _, v in pairs(Items.Fishs) do
         if Config.LongDistance.status and math.random(1, 100) <= Config.LongDistance.chance and rodDistance > 36.0 then
            fishItems[#fishItems + 1] = v
         elseif v.level <= level and v.rodLevel <= UsingRod.level then
            fishItems[#fishItems + 1] = v
         end
      end
   end
   return fishItems
end

local function calculateRewards(selectedFish)
   local rewards = {}
   if Config.CaughtRewards.status then
      local xpConfig = Config.CaughtRewards.quality[selectedFish.quality]
      if xpConfig then
         rewards.xp = xpConfig.random and math.random(xpConfig.min, xpConfig.max) or xpConfig.default
      end
   end
   return rewards
end

local function StartOutline()
   if not FishPed then return end

   CreateThread(function()
      while IsFishing do
         Wait(0)
         SetEntityDrawOutline(FishPed, true)
         SetEntityDrawOutlineColor(255, 165, 0, 255)
         SetEntityDrawOutlineShader(1)
      end
   end)
end

local function StopOutline()
   if not FishPed then return end
   SetEntityDrawOutline(FishPed, false)
end


local function getPullDistance(distance)
   if distance <= 25 then
      return 25.0
   else
      return 25.0
   end
end

local function isSessionInvalid(sessionToken)
   return sessionToken ~= (FishingSessionToken or 0) or not UsingRod or not UsingBait
end

local function cancelFishingFromMinigame()
   if not IsFishingMinigameActive then return end
   IsFishingMinigameActive = false
   LocalPlayer.state.invBusy = false
   SetNuiFocus(false, false)
   NuiMessage('CLOSE_FISHING_MINIGAME', {})
   CleanupAndStopFishing()
end

local minigameCancelListenerRunning = false

function StartFishingMinigameCancelListener()
   if minigameCancelListenerRunning then return end

   minigameCancelListenerRunning = true

   CreateThread(function()
      while IsFishingMinigameActive do
         Wait(0)
         if IsControlJustPressed(0, 178) or IsDisabledControlJustPressed(0, 178)
             or IsControlJustPressed(0, 177) or IsDisabledControlJustPressed(0, 177)
             or IsControlJustPressed(0, 322) or IsDisabledControlJustPressed(0, 322) then
            cancelFishingFromMinigame()
            break
         end
      end

      minigameCancelListenerRunning = false
   end)
end

local function catchingFish()
   if not FishPed then return end
   local ped = cache.ped

   StopOutline()

   NuiMessage('CLOSE_FISHING_MINIGAME', {})
   IsFishingMinigameActive = false
   SetEntityVisible(FishPed, false, false)
   local level = GetLevel()
   local lucky = math.random(1, 100) <= Config.LongDistance.chance and Config.LongDistance.status
   local fishItems = getAvailableFishItems(level, lucky)

   local trashChance = math.random(1, 100)
   local selectedItem = nil

   if trashChance <= Config.Trash.chance and Config.Trash.status then
      local selectedTrash = Items.Trashs[math.random(1, #Items.Trashs)]
      local rewards = calculateRewards(selectedTrash)

      CaughtFish = {
         name = selectedTrash.name,
         label = selectedTrash.label,
         quality = selectedTrash.quality,
         height = 0,
         rewards = rewards
      }
      selectedItem = CaughtFish
   elseif #fishItems > 0 then
      local selectedFish = fishItems[math.random(1, #fishItems)]
      local rewards = calculateRewards(selectedFish)

      CaughtFish = {
         name = selectedFish.name,
         label = selectedFish.label,
         quality = selectedFish.quality,
         height = math.random(2, 60),
         rewards = rewards
      }
      selectedItem = CaughtFish
   end

   if selectedItem then
      -- Always auto-take the fish/trash
      local found = lib.callback.await(Scriptname .. ':server:checkBait', false)
      if not found then
         local checkLuckyHat = lib.callback.await(Scriptname .. ':server:checkLuckyHat', false)
         ClearAllObject()
         TriggerServerEvent(Scriptname .. ':server:takeFish', CaughtFish, checkLuckyHat)
         CleanupAndStopFishing()
         TriggerServerEvent(Scriptname .. ':server:stopFishing')

         if RoomData and next(RoomData) ~= nil and RoomData.game.taskStarted then
            TriggerServerEvent(Scriptname .. ':server:addFish', RoomData.settings.ownerIdentifier)
         end
         return
      else
         local checkLuckyHat = lib.callback.await(Scriptname .. ':server:checkLuckyHat', false)
         ClearAllObject()
         TriggerServerEvent(Scriptname .. ':server:takeFish', CaughtFish, checkLuckyHat)

         if RoomData and next(RoomData) ~= nil and RoomData.game.taskStarted then
            TriggerServerEvent(Scriptname .. ':server:addFish', RoomData.settings.ownerIdentifier)
         end

         -- Check if player cancelled during the callback await
         if not UsingRod or not UsingBait then
            CleanupAndStopFishing()
            return
         end

         CleanupAndRestartFishing()
      end
   end
end

-- Fishing functions
local function startFishingThread()
   if not FishPed then return end
   local ped = cache.ped
   local pedCoords = GetEntityCoords(ped)
   local currentCoords = GetEntityCoords(FishPed)
   local sessionToken = FishingSessionToken or 0

   CreateThread(function()
      while StartingFishing do
         -- Bekleme süresini küçük parçalara böl: her 200ms'de iptal kontrolü yap
         local waitTime1 = math.random(1500, 2000)
         local elapsed1 = 0
         while elapsed1 < waitTime1 do
            Wait(200)
            elapsed1 = elapsed1 + 200
            if not UsingRod or not UsingBait or isSessionInvalid(sessionToken) then return end
         end

         local waitTime2 = math.random(Config.FishingTimes.Rod.min, Config.FishingTimes.Rod.max)
         local elapsed2 = 0
         while elapsed2 < waitTime2 do
            Wait(200)
            elapsed2 = elapsed2 + 200
            if not UsingRod or not UsingBait or isSessionInvalid(sessionToken) then return end
         end

         if isSessionInvalid(sessionToken) then return end
         if StartingFishing then
            if not Config.AFKMode then
               SetNuiFocus(true, false)
               IsFishingMinigameActive = true
               LocalPlayer.state.invBusy = true
               StartFishingMinigameCancelListener()
               MinigameStartTime = GetGameTimer()
               NuiMessage('SHOW_FISHING_MINIGAME', {
                  distance = #(vector2(pedCoords.x, pedCoords.y) - vector2(currentCoords.x, currentCoords.y)),
               })
            else
               StartingFishing = false
               IsFishing = false
               isPullingRope = false
               currentFishDistance = 0

               local finalDirection = vector2(pedCoords.x, pedCoords.y) - vector2(currentCoords.x, currentCoords.y)
               finalDirection = finalDirection / #(finalDirection)

               local finalXY = vector2(pedCoords.x, pedCoords.y) - (finalDirection * 2.0)
               local finalCoords = vector3(finalXY.x, finalXY.y, currentCoords.z)
               local finalFishZ = getFishZ(finalCoords)

               SetEntityCoords(FishPed, finalCoords.x, finalCoords.y, finalFishZ, false, false, false, false)
               RopeForceLength(RopeEntity,
                  #(vector3(finalCoords.x, finalCoords.y, finalFishZ) - GetOffsetFromEntityInWorldCoords(RodEntity, 0, 0, 2.5)))
               catchingFish()
            end

            SetEntityVisible(FishPed, true, false)
            StartOutline()
            IsFishing = true
            StartingFishing = false
         end
      end
   end)
end

local function pullRope()
   SetNuiFocus(false, false)
   IsFishingMinigameActive = false
   if not IsFishing or not RodEntity or not FishPed or not RopeEntity or isPullingRope then return end

   isPullingRope = true
   StartRopeWinding(RopeEntity)
   StartRopeUnwindingFront(FishPed)

   local ped = cache.ped
   local pedCoords = GetEntityCoords(ped)
   local currentCoords = GetEntityCoords(FishPed)
   local pullDistance = getPullDistance(currentFishDistance)
   local step = 0.12
   local currentStep = 0

   while currentStep < pullDistance and isPullingRope and IsFishing do
      if IsPlayerDowned() then
         CleanupAndStopFishing()
         break
      end
      local direction = vector2(pedCoords.x, pedCoords.y) - vector2(currentCoords.x, currentCoords.y)
      direction = direction / #(direction)

      local newXY = vector2(currentCoords.x, currentCoords.y) + (direction * step)
      local newCoords = vector3(newXY.x, newXY.y, currentCoords.z)
      local fishZ = getFishZ(newCoords)

      SetEntityCoords(FishPed, newCoords.x, newCoords.y, fishZ - 3.0, false, false, false, false)

      local rodAttach = GetOffsetFromEntityInWorldCoords(RodEntity, 0, 0, 2.5)
      local newDistance = #(vector3(newCoords.x, newCoords.y, fishZ - 3.0) - rodAttach)

      RopeForceLength(RopeEntity, newDistance)
      RopeForceLength(RopeEntity,
         #(vector3(newCoords.x, newCoords.y, fishZ - 3.0) - GetOffsetFromEntityInWorldCoords(RodEntity, 0, 0, 2.5)))

      currentCoords = vector3(newCoords.x, newCoords.y, fishZ - 3.0)
      currentStep = currentStep + step

      if #(vector2(currentCoords.x, currentCoords.y) - vector2(pedCoords.x, pedCoords.y)) < 2.0 then
         break
      end

      Wait(50)
   end

   currentFishDistance = #(vector2(currentCoords.x, currentCoords.y) - vector2(pedCoords.x, pedCoords.y))
   isPullingRope = false
   StopRopeWinding(RopeEntity)
   StopRopeUnwindingFront(RopeEntity)

   Wait(500)

   if currentFishDistance <= 2.0 then
      StartingFishing = false
      IsFishing = false
      isPullingRope = false
      currentFishDistance = 0

      local finalDirection = vector2(pedCoords.x, pedCoords.y) - vector2(currentCoords.x, currentCoords.y)
      finalDirection = finalDirection / #(finalDirection)

      local finalXY = vector2(pedCoords.x, pedCoords.y) - (finalDirection * 2.0)
      local finalCoords = vector3(finalXY.x, finalXY.y, currentCoords.z)
      local finalFishZ = getFishZ(finalCoords)

      SetEntityCoords(FishPed, finalCoords.x, finalCoords.y, finalFishZ, false, false, false, false)
      RopeForceLength(RopeEntity,
         #(vector3(finalCoords.x, finalCoords.y, finalFishZ) - GetOffsetFromEntityInWorldCoords(RodEntity, 0, 0, 2.5)))
      catchingFish()
   else
      if not StartingFishing and not IsFishing then return end

      SetNuiFocus(true, false)
      IsFishingMinigameActive = true
      LocalPlayer.state.invBusy = true
      MinigameStartTime = GetGameTimer()
      NuiMessage('RESUME_FISHING_MINIGAME', { distance = currentFishDistance })
   end
end

-- NUI Callbacks
RegisterNUICallback('RESULT_DISTANCE_MINIGAME', function(data, cb)
   local sessionToken = FishingSessionToken or 0
   if not RodEntity or not IsFishingMinigameActive then
      cb('ok')
      return
   end

   local currentTime = GetGameTimer()
   local timeDiff = currentTime - MinigameStartTime

   if Config.AntiMacro and timeDiff < (Config.AntiMacroGracePeriod or 1500) then
      TriggerServerEvent(Scriptname .. ':server:banPlayer', 'Balıkçılık Makro Tespit Edildi (minigame çok hızlı)')
      CleanupAndStopFishing()
      cb('ok')
      return
   end

   SetNuiFocus(false, false)
   IsFishingMinigameActive = false
   LocalPlayer.state.invBusy = false

   if isSessionInvalid(sessionToken) then
      cb('ok')
      return
   end

   local ped = cache.ped
   local pedCoords = GetEntityCoords(ped)

   local distance = math.max((tonumber(data.distance) or 0) / 2, 10) * 1.0

   local fishCoords = GetOffsetFromEntityInWorldCoords(ped, 0, distance, 0)
   rodDistance = distance
   local fishZ = getFishZ(fishCoords)

   lib.requestAnimDict('fishing_animation')
   lib.playAnim(ped, 'fishing_animation', 'fishing_clip', 8.0, -8.0, -1, 11, false, false, 0, false)
   RemoveAnimDict('fishing_animation')

   Wait(2000)

   if isSessionInvalid(sessionToken) then
      cb('ok')
      return
   end

   lib.requestAnimDict('amb@world_human_stand_fishing@idle_a')
   lib.playAnim(ped, 'amb@world_human_stand_fishing@idle_a', 'idle_c', 8.0, -8.0, 2.0, 11, false, false, 0, false)
   RemoveAnimDict('amb@world_human_stand_fishing@idle_a')

   if RodEntity then
      safeDeleteEntity(RodEntity)
      TriggerServerEvent(Scriptname .. ':server:unregisterRod')
      RodEntity = nil
   end

   Wait(100)

   if isSessionInvalid(sessionToken) then
      ClearAllObject()
      cb('ok')
      return
   end

   local rodModel = UsingRod.model
   lib.requestModel(rodModel)
   pcall(function() exports['FeloxAC']:CreateObject(rodModel) end) --[[FeloxAC:auto]]
   RodEntity = CreateObject(rodModel, pedCoords.x, pedCoords.y, pedCoords.z, true, true, false)
   SetModelAsNoLongerNeeded(rodModel)
   -- Sunucuya yeni olta netId'sini kaydet
   TriggerServerEvent(Scriptname .. ':server:registerRod', NetworkGetNetworkIdFromEntity(RodEntity))

   AttachEntityToEntity(RodEntity, ped, GetPedBoneIndex(ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false,
      true, 1, true)
   local fishModel = `v_res_fa_bread01`

   lib.requestModel(fishModel)
   pcall(function() exports['FeloxAC']:CreateObject(fishModel) end) --[[FeloxAC:auto]]
   FishPed = CreateObject(fishModel, fishCoords.x, fishCoords.y, fishZ - 3.0, false, false, false)
   SetEntityVisible(FishPed, false, false)
   FreezeEntityPosition(FishPed, true)
   SetModelAsNoLongerNeeded(fishModel)

   local ropeStartAttachPosition = GetOffsetFromEntityInWorldCoords(RodEntity, 0, 0, 2.5)

   if not RopeAreTexturesLoaded() then
      RopeLoadTextures()
      while not RopeAreTexturesLoaded() do Wait(0) end
   end

   RopeEntity = AddRope(ropeStartAttachPosition.x, ropeStartAttachPosition.y, ropeStartAttachPosition.z, 0, 0, 0, 5.0, 5,
      5.0, 15, 0.7, false, false, false, 0, false)

   if RopeEntity and RopeEntity ~= 0 then
      AttachEntitiesToRope(RopeEntity, RodEntity, FishPed, ropeStartAttachPosition.x, ropeStartAttachPosition.y,
         ropeStartAttachPosition.z, fishCoords.x, fishCoords.y, fishZ - 3.0, distance, false, false, "", "")

      CreateThread(function()
         local currentLength = 5.0
         while currentLength < distance do
            currentLength = math.min(currentLength + 2.0, distance)
            RopeForceLength(RopeEntity, currentLength)
            Wait(50)
         end
      end)
   else
      ClearAllObject()
      return
   end

   ModifyWater(fishCoords.x, fishCoords.y, 50.0, 200.0)
   FreezeEntityPosition(FishPed, true)
   StopRopeUnwindingFront(RopeEntity)
   StopRopeWinding(RopeEntity)
   RopeForceLength(RopeEntity, distance)

   currentFishDistance = distance
   TriggerServerEvent(Scriptname .. ':server:startFishing')
   StartingFishing = true
   startFishingThread()
   cb('ok')
end)

RegisterNUICallback('FISHING_GAME_RESULT', function(data, cb)
   if not IsFishingMinigameActive then
      cb('ok')
      return
   end

   local currentTime = GetGameTimer()
   local timeDiff = currentTime - MinigameStartTime

   if data.success and Config.AntiMacro and timeDiff < (Config.AntiMacroGracePeriod or 1500) then
      TriggerServerEvent(Scriptname .. ':server:banPlayer', 'Balıkçılık Makro Tespit Edildi (minigame çok hızlı)')
      CleanupAndStopFishing()
      cb('ok')
      return
   end

   SetNuiFocus(false, false)
   IsFishingMinigameActive = false
   LocalPlayer.state.invBusy = false
   if data.success then
      pullRope()
   else
      Notify.SendNotify(_T('LUA.notifications.error.you_failed_to_catch_the_fish'), 'error', 5000)
      SetNuiFocus(false, false)
      ClearAllObject()
      if UsingBait then
         local found = lib.callback.await(Scriptname .. ':server:checkBait', false)

         if not found then
            CleanupAndStopFishing()
            TriggerServerEvent(Scriptname .. ':server:stopFishing')
            return
         end
      else
         CleanupAndStopFishing()
         TriggerServerEvent(Scriptname .. ':server:stopFishing')
         return
      end

      CreateThread(function()
         Wait(500)
         CleanupAndRestartFishing()
      end)
   end
   cb('ok')
end)

RegisterNUICallback('CLOSE_FISHING_MINIGAME', function(data, cb)
   SetNuiFocus(false, false)
   IsFishingMinigameActive = false
   LocalPlayer.state.invBusy = false
   CleanupAndStopFishing()
   cb('ok')
end)
