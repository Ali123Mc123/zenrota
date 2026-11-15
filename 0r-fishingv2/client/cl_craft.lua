CraftModel = nil
CraftCamera = nil

RegisterNetEvent(Scriptname .. ':client:craftRod', function(rod)
   local ped = cache.ped

   if not CraftModel then
      local propCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 3.0, -0.4)
      local propRot = GetEntityRotation(ped)
      pcall(function() exports['FeloxAC']:CreateObject(rod.model) end) --[[FeloxAC:auto]]
      CraftModel = CreateObject(rod.model, propCoords.x, propCoords.y, propCoords.z, false, true, false)
      SetEntityRotation(CraftModel, propRot.x, propRot.y, propRot.z - 90.0, 2, false)

      local camCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.5, 1.0)
      local camRot = GetEntityRotation(ped)

      CraftCamera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
      pcall(function() exports['FeloxAC']:createCam(CraftCamera) end) --[[FeloxAC:auto]]
      SetCamCoord(CraftCamera, camCoords.x, camCoords.y, camCoords.z)
      SetCamRot(CraftCamera, camRot.x, camRot.y, camRot.z, 2)
      SetCamActive(CraftCamera, true)
      RenderScriptCams(true, true, 1000, true, true)

      SetNuiFocus(true, true)
      NuiMessage('SHOW_CRAFT_ROD', { rod = rod })
   end
end)

RegisterNUICallback('CRAFT_ROD_PART_ITEM', function(data, cb)
   local item = data.item

   local result = lib.callback.await(Scriptname .. ':server:craftRodPartItem', false, item)

   cb(result)
end)

RegisterNUICallback('CLOSE_CRAFT_ROD', function(data, cb)
   if not CraftModel or not CraftCamera then return end

   DeleteEntity(CraftModel)
   RenderScriptCams(false, true, 1000, true, true)
   pcall(function() exports['FeloxAC']:destroyCam(CraftCamera) end) --[[FeloxAC:auto]]
   DestroyCam(CraftCamera, false)
   CraftModel = nil
   CraftCamera = nil
   ClearPedTasks(cache.ped)
   NuiMessage('CLOSE_ALL_UI', {})
   CleanupAndStopFishing()
   SetNuiFocus(false, false)
   cb(true)
end)