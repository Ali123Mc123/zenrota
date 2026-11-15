NuiLoaded = false
Fisherman = {}
Upgrade = {}
RentBoat = {}
FishingGameResult = false
RodEntity = nil
RopeEntity = nil
FishPed = nil
CaughtFish = nil
UsingRod = false
UsingBait = false
PlayerData = {}
LuckyHat = false
FishingSessionToken = 0
IsFishingMinigameActive = false

local oldHatCache = {}

local Items <const> = require 'config.items'
local Config <const> = require 'config.main'

-- Oyuncu ölü / yerde mi? (qbx_medical ped'i gerçekten öldürmüyor, IsEntityDead yetmez)
function IsPlayerDowned()
   if IsEntityDead(cache.ped) then return true end
   if GetResourceState('qbx_medical') == 'started' then
      local ok, downed = pcall(function()
         return exports.qbx_medical:IsDead() or exports.qbx_medical:IsLaststand()
      end)
      if ok and downed then return true end
   end
   local meta = QBX and QBX.PlayerData and QBX.PlayerData.metadata
   return meta and (meta.isdead or meta.inlaststand) or false
end

--------------------------------
--- EVENTS
--------------------------------

AddEventHandler('onResourceStop', function(resource)
   if resource == GetCurrentResourceName() then
      if RodEntity then
         if DoesEntityExist(RodEntity) then
            DetachEntity(RodEntity, true, true)
            DeleteEntity(RodEntity)
         end
         RodEntity = nil
      end

      if RopeEntity and RopeEntity ~= 0 then
         local retval, ropeId = DoesRopeExist(RopeEntity)
         StopRopeWinding(RopeEntity)
         StopRopeUnwindingFront(RopeEntity)

         if retval and ropeId ~= 0 then
            DeleteRope(ropeId)
         end

         RopeEntity = nil
      end

      if FishPed then
         if DoesEntityExist(FishPed) then
            DetachEntity(FishPed, true, true)
            DeleteEntity(FishPed)
         end
         FishPed = nil
      end

      ClearPedTasks(cache.ped)
      FreezeEntityPosition(cache.ped, false)
   end
end)

RegisterNetEvent(Scriptname .. ':client:useRod', function(itemName)
   local ped = cache.ped
   local pedCoords = GetEntityCoords(ped)

   if IsPlayerDowned() then return end

   if IsPedInAnyVehicle(ped, false) or IsPedSwimming(ped) then
      Notify.SendNotify(_T('LUA.notifications.error.you_cant_fish_in_vehicle_or_swimming'), 'error', 5000)
      return
   end

   if StartingFishing or IsFishing then
      Notify.SendNotify(_T('LUA.notifications.error.you_are_already_fishing'), 'error', 5000)
      return
   end

   if IsFishing or StartingFishing then
      Notify.SendNotify(_T('LUA.notifications.error.you_are_already_using_a_rod'), 'error', 5000)
      return
   end

   for _, item in pairs(Items.Baits) do
      local success = lib.callback.await(Scriptname .. ':server:removeItem', false, item.name, 1)
      if not success then goto continue end

      if success then
         UsingBait = true
         break
      end

      ::continue::
   end

   UsingRod = nil

   for _, item in pairs(Items.FishingRods) do
      if item.name == itemName then
         UsingRod = item
         break
      end
   end

   SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
   Wait(500)

   if UsingRod then
      if Config.CraftMode then
         local rodModel = UsingRod.model
         lib.requestModel(rodModel)
         pcall(function() exports['FeloxAC']:CreateObject(rodModel) end) --[[FeloxAC:auto]]
         RodEntity = CreateObject(rodModel, pedCoords.x, pedCoords.y, pedCoords.z, true, true, false)
         AttachEntityToEntity(RodEntity, ped, GetPedBoneIndex(ped, 58867), 0.010919095944246, 0.023779414615156,
            0.023921898615188, 17.051279175968, -18.888730493859, -5.6703984305567, true, true, false, true, 1, true)
         -- Sunucuya olta netId'sini kaydet
         TriggerServerEvent(Scriptname .. ':server:registerRod', NetworkGetNetworkIdFromEntity(RodEntity))
         SetModelAsNoLongerNeeded(rodModel)
         SetNuiFocus(false, false)
         NuiMessage('SHOW_KEY_MAPPING', {})

         while true do
            Wait(0)

            if IsPlayerDowned() or not RodEntity then
               NuiMessage('CLOSE_KEY_MAPPING', {})
               ClearAllObject()
               CleanupAndStopFishing()
               return
            end

            if IsControlJustPressed(0, Config.Keys['start_fishing'].index) then
               local fullParts = lib.callback.await(Scriptname .. ':server:checkRodParts', false)
               if not fullParts then
                  Notify.SendNotify(_T('LUA.notifications.error.attach_rod_parts_to_catch_fish'), 'error', 5000)
                  ClearAllObject()
                  CleanupAndStopFishing()
                  return
               end

               local hasWater = HasWaterInFront()

               if not hasWater then
                  Notify.SendNotify(_T('LUA.notifications.error.you_cant_fish_in_this_location'), 'error', 5000)
                  ClearAllObject()
                  CleanupAndStopFishing()
                  return
               end

               if not UsingBait then
                  Notify.SendNotify(_T('LUA.notifications.error.you_need_to_use_a_bait'), 'error', 5000)
                  ClearAllObject()
                  CleanupAndStopFishing()
                  return
               end

               ClearPedTasks(ped)
               FreezeEntityPosition(ped, true)
               NuiMessage('CLOSE_KEY_MAPPING', {})
               SetNuiFocus(true, false)
               IsFishingMinigameActive = true
               if StartFishingMinigameCancelListener then
                  StartFishingMinigameCancelListener()
               end
               NuiMessage('SHOW_DISTANCE_MINIGAME', {})
               break
            end

            if IsControlJustPressed(0, Config.Keys['craft_mode'].index) then
               local partItems = lib.callback.await(Scriptname .. ':server:getPartItems', false)
               local partDatas = lib.callback.await(Scriptname .. ':server:getPartDatas', false)

               NuiMessage('UPDATE_PART_ITEMS', {
                  partItems = partItems,
                  partDatas = partDatas,
               })
               NuiMessage('CLOSE_KEY_MAPPING', {})
               TriggerEvent(Scriptname .. ':client:craftRod', UsingRod)

               ClearAllObject()
               break
            end
         end
      else
         local hasWater = HasWaterInFront()

         if not hasWater then
            Notify.SendNotify(_T('LUA.notifications.error.you_cant_fish_in_this_location'), 'error', 5000)
            return
         end

         if not UsingBait then
            Notify.SendNotify(_T('LUA.notifications.error.you_need_to_use_a_bait'), 'error', 5000)
            return
         end

         local rodModel = UsingRod.model
         lib.requestModel(rodModel)
         pcall(function() exports['FeloxAC']:CreateObject(rodModel) end) --[[FeloxAC:auto]]
         RodEntity = CreateObject(rodModel, pedCoords.x, pedCoords.y, pedCoords.z, true, true, false)
         AttachEntityToEntity(RodEntity, ped, GetPedBoneIndex(ped, 58867), 0.010919095944246, 0.023779414615156,
            0.023921898615188, 17.051279175968, -18.888730493859, -5.6703984305567, true, true, false, true, 1, true)
         -- Sunucuya olta netId'sini kaydet
         TriggerServerEvent(Scriptname .. ':server:registerRod', NetworkGetNetworkIdFromEntity(RodEntity))
         SetModelAsNoLongerNeeded(rodModel)

         ClearPedTasks(ped)
         FreezeEntityPosition(ped, true)
         addDisableControls({ 32, 33, 34, 35, 22 })
         SetNuiFocus(true, false)
         IsFishingMinigameActive = true
         if StartFishingMinigameCancelListener then
            StartFishingMinigameCancelListener()
         end
         NuiMessage('SHOW_DISTANCE_MINIGAME', {})
      end
   end
end)

RegisterNetEvent(Scriptname .. ':client:updateXp', function(xp)
   PlayerData.xp = xp
   NuiMessage('UPDATE_XP', {
      xp = xp,
   })
end)

RegisterNetEvent('baseevents:onPlayerDied', function()
   CleanupAndStopFishing()
   ClearPedTasks(cache.ped)
   NuiMessage('CLOSE_ALL_UI', {})
end)

RegisterNetEvent('baseevents:onPlayerKilled', function()
   CleanupAndStopFishing()
   ClearPedTasks(cache.ped)
   NuiMessage('CLOSE_ALL_UI', {})
end)

-- Oyuncu ellerini kaldırınca (handsup) balık tutmayı iptal et
-- NOT: NUI focus açıkken RegisterCommand tetiklenmeyebilir, bu yüzden
-- cylex_animmenuv2'nin handsUp global değişkenini doğrudan izliyoruz.
AddEventHandler('cylex:handsUp', function(active)
   if active and (IsFishingMinigameActive or RodEntity) then
      NuiMessage('CLOSE_ALL_UI', {})
      CleanupAndStopFishing()
      ClearPedTasks(cache.ped)
   end
end)

CreateThread(function()
   while true do
      local sleep = 500
      if IsFishingMinigameActive or RodEntity then
         sleep = 200
         -- handsUp global değişkenini doğrudan izle (NUI focus varken event gelmeyebilir)
         if handsUp then
            NuiMessage('CLOSE_ALL_UI', {})
            CleanupAndStopFishing()
            ClearPedTasks(cache.ped)
         end
      end
      if IsFishing or StartingFishing or IsFishingMinigameActive or RodEntity then
         sleep = 100
         if IsPlayerDowned() then
            CleanupAndStopFishing()
            ClearPedTasks(cache.ped)
            NuiMessage('CLOSE_ALL_UI', {})
         end
      end
      Wait(sleep)
   end
end)

RegisterNetEvent(Scriptname .. ':client:useLuckyHat', function(itemName)
   local ped = cache.ped
   local pedModel = GetEntityModel(ped)

   if not Config.LuckyHat.status then return end
   if not Config.LuckyHat.clothing[pedModel] or not next(Config.LuckyHat.clothing[pedModel]) then return end

   local clothing = Config.LuckyHat.clothing[pedModel]

   lib.requestAnimDict('mp_masks@truck@ds@')
   TaskPlayAnim(ped, 'mp_masks@truck@ds@', 'put_on_mask', 8.0, 8.0, -1, 49, 0, false, false, false)
   RemoveAnimDict('mp_masks@truck@ds@')

   local success = lib.progressCircle({
      duration = 1000,
      position = 'bottom',
      useWhileDead = false,
      canCancel = true,
      disable = {
         car = true,
         move = true,
         combat = true,
      },
      anim = {},
      prop = {},
   })

   if success then
      if LuckyHat then
         if oldHatCache.item == -1 then
            ClearPedProp(ped, oldHatCache.componentId)
         else
            SetPedPropIndex(ped, oldHatCache.componentId, oldHatCache.item, oldHatCache.texture, true)
         end
         oldHatCache = {}
         LuckyHat = false
      else
         oldHatCache = {
            componentId = clothing.componentId,
            item = GetPedPropIndex(ped, clothing.componentId),
            texture = GetPedPropTextureIndex(ped, clothing.componentId),
         }

         SetPedPropIndex(ped, clothing.componentId, clothing.item, clothing.texture, true)
         LuckyHat = true
      end
      ClearPedTasks(ped)
   end
end)

local freezingBoat = false

RegisterNetEvent(Scriptname .. ':client:useAnchor', function()
   local boat = GetVehiclePedIsIn(PlayerPedId(), false)
   if not boat or not IsThisModelABoat(GetEntityModel(boat)) then return end

   FreezeEntityPosition(boat, not freezingBoat)
   freezingBoat = not freezingBoat

   Notify.SendNotify(_T('LUA.notifications.success.you_used_anchor'), 'success', 5000)
end)

lib.addKeybind({
    name = Config.Commands.stop_fishing.command,
    description = Config.Commands.stop_fishing.description,
    defaultKey = Config.Commands.stop_fishing.key,
    defaultMapper = 'keyboard',
    onPressed = function(self)
        NuiMessage('CLOSE_ALL_UI', {})
        CleanupAndStopFishing()
        ClearPedTasks(cache.ped)
    end
})

exports("IsFishing", function()
   return IsFishing or StartingFishing
end)
