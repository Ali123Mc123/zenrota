local starttingNetting = false
local netEntity = nil
local fishs = {}

local Items <const> = require 'config.items'
local Config <const> = require 'config.main'

local function getAvailableFishItems(level)
   local fishItems = {}
   for _, v in pairs(Items.Fishs) do
      if v.level <= level then
         fishItems[#fishItems + 1] = v
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

local function startNetting()
   CreateThread(function()
      while starttingNetting do
         Wait(math.random(Config.FishingTimes.Net.min, Config.FishingTimes.Net.max))

         if not starttingNetting then return end

         local fishsList = getAvailableFishItems(GetLevel())
         if #fishsList > 0 then
            local selectedFish = fishsList[math.random(1, #fishsList)]
            local rewards = calculateRewards(selectedFish)
            Notify.SendNotify(_T('LUA.notifications.success.you_caught_a_fish', selectedFish.name), 'success', 5000)

            fishs[#fishs + 1] = {
               name = selectedFish.name,
               label = selectedFish.label,
               quality = selectedFish.quality,
               height = math.random(2, 60),
               rewards = rewards
            }
         end
      end
   end)
end

local function startNettingCheck()
   CreateThread(function()
      while starttingNetting do
         Wait(1000)

         local playerCoords = GetEntityCoords(cache.ped)
         local netCoords = GetEntityCoords(netEntity)

         if #(playerCoords - netCoords) > 50.0 then
            Notify.SendNotify(_T('LUA.notifications.error.too_far_from_net'), 'error', 5000)
            if netEntity and DoesEntityExist(netEntity) then
               DeleteEntity(netEntity)
            end

            netEntity = nil
            starttingNetting = false

            fishs = {}
            TriggerServerEvent(Scriptname .. ':server:stopNetting', fishs)
            return
         end
      end
   end)
end

RegisterNetEvent(Scriptname .. ':client:startNetting', function()
   local ped = cache.ped

   if IsPlayerDowned() then return end

   if IsPedInAnyVehicle(ped, false) then
      Notify.SendNotify(_T('LUA.notifications.error.you_cant_while_in_vehicle'), 'error', 5000)
      return
   end


   if IsPedSwimming(ped) or IsPedSwimmingUnderWater(ped) or IsPedInAnyVehicle(ped, false) then
      Notify.SendNotify(_T('LUA.notifications.error.you_cant_while_swimming'), 'error', 5000)
      return
   end

   local hasWater = HasWaterInFront()

   if not hasWater then
      Notify.SendNotify(_T('LUA.notifications.error.you_cant_fish_in_this_location'), 'error', 5000)
      return
   end

   if not starttingNetting then
      local model = `qua_fishing_net`
      lib.requestModel(model)
      local netPos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 7.0, 0.0)
      local _, floorZ = GetGroundZExcludingObjectsFor_3dCoord(netPos.x, netPos.y, netPos.z, true)
      pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
      netEntity = CreateObject(model, netPos.x, netPos.y, floorZ-0.6, true, true, false)
      SetEntityRotation(netEntity, 0.0, 0.0, 180.0, 2, true)
      FreezeEntityPosition(netEntity, true)

      Notify.SendNotify('Ağ atılıyor...', 'success', 5000)

      startNetting()
      starttingNetting = true
   else
      if netEntity and DoesEntityExist(netEntity) then
         DeleteEntity(netEntity)
         Notify.SendNotify('Ağ toplandı...', 'success', 5000)
         starttingNetting = false

         TriggerServerEvent(Scriptname .. ':server:stopNetting', fishs)
         fishs = {}
      end

      netEntity = nil
      starttingNetting = false
   end

   startNettingCheck()
end)

RegisterNetEvent('onResourceStop', function(resource)
   if resource == GetCurrentResourceName() then
      if netEntity and DoesEntityExist(netEntity) then
         DeleteEntity(netEntity)
      end
   end
end)

local function stopNettingOnDeath()
   if netEntity and DoesEntityExist(netEntity) then
      DeleteEntity(netEntity)
   end

   netEntity = nil
   starttingNetting = false

   fishs = {}
   TriggerServerEvent(Scriptname .. ':server:stopNetting', fishs)
end

RegisterNetEvent('baseevents:onPlayerDied', stopNettingOnDeath)
-- qbx_medical ölüm olayı (baseevents bu sunucuda tetiklenmeyebilir)
AddEventHandler('qbx_medical:client:onPlayerDied', stopNettingOnDeath)