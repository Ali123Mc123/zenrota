local Items <const> = require 'config.items'

local SpawnedObjects = {}
local area = nil
local blip = nil
local outlineThreadActive = false

-- Utility functions
local function createAreaBlip()
   -- area = AddBlipForRadius(RoomData.game.zone.coords.x, RoomData.game.zone.coords.y, RoomData.game.zone.coords.z, RoomData.game.zone.radius)
   -- SetBlipColour(area, 5)
   -- SetBlipAlpha(area, 128)

   -- blip = AddBlipForCoord(RoomData.game.zone.coords.x, RoomData.game.zone.coords.y, RoomData.game.zone.coords.z)
   -- SetBlipSprite(blip, 270)
   -- SetBlipColour(blip, 5)
   -- SetBlipScale(blip, 0.6)
   -- SetBlipAsShortRange(blip, true)
   -- BeginTextCommandSetBlipName("STRING")
   -- AddTextComponentString('Underwater Area')
   -- EndTextCommandSetBlipName(blip)
end

local function deleteAreaBlip()
   if area and DoesBlipExist(area) then
      RemoveBlip(area)
   end

   if blip and DoesBlipExist(blip) then
      RemoveBlip(blip)
   end

   area = nil
   blip = nil
end

local function getRandomPropName()
   return Items.UnderwaterObjects[math.random(1, #Items.UnderwaterObjects)].objectName
end

local function createUnderwaterObject(propName, coords)
   local model = GetHashKey(propName)
   lib.requestModel(model)

   local success, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, 100.0, true)
   if not success then return nil end

   pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
   local obj = CreateObject(model, coords.x, coords.y, groundZ, false, true, false)
   SetEntityHeading(obj, math.random(0, 360))
   FreezeEntityPosition(obj, true)

   return {
      id = #SpawnedObjects + 1,
      object = obj,
      name = propName,
      coords = coords,
      collecting = false,
   }
end

local function progressCircle(label, duration)
   return lib.progressCircle({
      label = label,
      duration = duration,
      position = 'bottom',
      useWhileDead = false,
      allowSwimming = true,
      allowRagdoll = false,
      allowCuffed = false,
      canCancel = false,
      disable = {
         move = true,
         car = true,
         combat = true,
      },
      anim = {
         dict = 'weapons@first_person@aim_rng@generic@projectile@thermal_charge@',
         clip = 'plant_floor'
      },
      prop = {},
   })
end

local function collectUnderwaterObject(index, objectData)
   if objectData.collecting then return end

   objectData.collecting = true
   TriggerServerEvent(Scriptname .. ':server:updateUnderwaterObject', RoomData.settings.ownerIdentifier, objectData.id,
      'collecting')

   if not progressCircle('Obje Toplanıyor', 5000) then return end

   TriggerServerEvent(Scriptname .. ':server:collectUnderwaterObject', RoomData.settings.ownerIdentifier, objectData.id,
      objectData.name)
end

local function startEntityOutlineThread()
   if outlineThreadActive then return end

   outlineThreadActive = true
   CreateThread(function()
      while RoomData and RoomData.game.selectedTask == 3 and RoomData.game.taskStarted and outlineThreadActive do
         local playerCoords = GetEntityCoords(PlayerPedId())

         for k, v in pairs(SpawnedObjects) do
            if DoesEntityExist(v.object) then
               if #(playerCoords - GetEntityCoords(v.object)) < 100.0 then
                  if not v.collecting then
                     SetEntityDrawOutline(v.object, true)
                     SetEntityDrawOutlineColor(255, 165, 0, 255)
                     SetEntityDrawOutlineShader(1)
                  end
               else
                  SetEntityDrawOutline(v.object, false)
               end
            end
         end

         Wait(100)
      end

      for k, v in pairs(SpawnedObjects) do
         if DoesEntityExist(v.object) then
            SetEntityDrawOutline(v.object, false)
         end
      end
   end)
end

local function stopEntityOutlineThread()
   outlineThreadActive = false
end

-- Main functions
local function createUnderwaterObjects()
   local numberOfObjects = 30

   for i = 1, numberOfObjects do
      local propName = getRandomPropName()
      local coords = GetRandomCoordInCircle(RoomData.game.zone.coords, RoomData.game.zone.radius)
      local objectData = createUnderwaterObject(propName, coords)

      if objectData then
         table.insert(SpawnedObjects, objectData)
      end
   end

   local showHelpText = false
   CreateThread(function()
      while RoomData and RoomData.game.selectedTask == 3 and RoomData.game.taskStarted do
         local playerCoords = GetEntityCoords(PlayerPedId())
         local closestDist = 10.0
         local closestObj = nil

         for _, v in pairs(SpawnedObjects) do
            if DoesEntityExist(v.object) then
               local objCoords = GetEntityCoords(v.object)
               local dist = #(playerCoords - objCoords)
               if dist < closestDist then
                  closestDist = dist
                  closestObj = v
               end
            end
         end

         if closestObj and not closestObj.collecting then
            if not showHelpText then
               HelpText.ShowHelpText('[E] - ' .. _T('LUA.actions.collect_object'), 'left-center')
               showHelpText = true
            end

            if IsControlJustReleased(0, 38) then
               collectUnderwaterObject(k, closestObj)
            end

            Wait(0)
         else
            if showHelpText then
               HelpText.HideHelpText()
               showHelpText = false
            end
            Wait(100)
         end
      end
   end)

   startEntityOutlineThread()
   TriggerServerEvent(Scriptname .. ':server:createUnderwaterObjectsForOtherPlayer', RoomData.settings.ownerIdentifier,
      SpawnedObjects)
end

local function cleanupUnderwaterObjects()
   stopEntityOutlineThread()

   for _, v in pairs(SpawnedObjects) do
      if DoesEntityExist(v.object) then
         SetEntityDrawOutline(v.object, false)
         DeleteEntity(v.object)
      end
   end
   SpawnedObjects = {}
end

local function checkUnderwaterArea()
   CreateThread(function()
      local isInArea = false
      while RoomData and RoomData.game.selectedTask == 3 and not isInArea do
         local playerCoords = GetEntityCoords(PlayerPedId())
         local distance = #(vector2(playerCoords.x, playerCoords.y) - vector2(RoomData.game.zone.coords.x, RoomData.game.zone.coords.y))

         if distance < 100.0 then
            isInArea = true
            createUnderwaterObjects()
         end

         Wait(1000)
      end
   end)
end

-- Events
RegisterNetEvent(Scriptname .. ':client:startUnderwaterTask', function()
   createAreaBlip()
   checkUnderwaterArea()
end)

RegisterNetEvent(Scriptname .. ':client:stopUnderwaterTask', function()
   cleanupUnderwaterObjects()
   deleteAreaBlip()
end)

RegisterNetEvent(Scriptname .. ':client:createUnderwaterObjectsForOtherPlayer', function(table)
   createAreaBlip()

   for k, v in pairs(table) do
      local obj = createUnderwaterObject(v.name, v.coords)
      if obj then
         SpawnedObjects[#SpawnedObjects + 1] = obj
      end
   end

   local showHelpText = false
   CreateThread(function()
      while RoomData and RoomData.game.selectedTask == 3 and RoomData.game.taskStarted do
         local playerCoords = GetEntityCoords(PlayerPedId())
         local closestDist = 10.0
         local closestObj = nil

         for _, v in pairs(SpawnedObjects) do
            if DoesEntityExist(v.object) then
               local objCoords = GetEntityCoords(v.object)
               local dist = #(playerCoords - objCoords)
               if dist < closestDist then
                  closestDist = dist
                  closestObj = v
               end
            end
         end

         if closestObj then
            if not showHelpText then
               HelpText.ShowHelpText('[E] - ' .. _T('LUA.actions.collect_object'), 'left-center')
               showHelpText = true
            end

            if IsControlJustReleased(0, 38) then
               collectUnderwaterObject(k, closestObj)
            end

            Wait(0)
         else
            if showHelpText then
               HelpText.HideHelpText()
               showHelpText = false
            end
            Wait(100)
         end
      end
   end)

   startEntityOutlineThread()
end)

RegisterNetEvent(Scriptname .. ':client:deleteUnderwaterObject', function(index)
   for k, v in pairs(SpawnedObjects) do
      if v.id == index then
         SetEntityDrawOutline(v.object, false)
         DeleteEntity(v.object)
         table.remove(SpawnedObjects, k)
      end
   end
end)

RegisterNetEvent(Scriptname .. ':client:updateUnderwaterObject', function(index, action)
   for k, v in pairs(SpawnedObjects) do
      if v.id == index then
         v.collecting = action == 'collecting'
      end
   end
end)

AddEventHandler('onResourceStop', function(resource)
   if resource == GetCurrentResourceName() then
      cleanupUnderwaterObjects()
   end
end)
