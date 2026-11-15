local DivingConfig <const> = require 'config.diving'

local CurrentGear = {
   mask = 0,
   tank = 0,
   oxygen = 0,
   enabled = false
}

local oldClothesCache = {}
local oldPropsCache = {}
local isWearingClothes = false
local isWearingSuit = false
local OxygenLevel = 0

local function playGearAnimation()
   local ped = cache.ped
   lib.requestAnimDict(DivingConfig.GearAnimation.dict)
   lib.playAnim(ped, DivingConfig.GearAnimation.dict, DivingConfig.GearAnimation.anim, 8.0, 8.0, -1, 49, 0, false, false, false)
end

local function deleteGearEntity(entityId)
   if entityId ~= 0 then
      DetachEntity(entityId, false, true)
      DeleteObject(entityId)
      return 0
   end
   return 0
end

local function deleteGearMaskAndTank()
   local ped = cache.ped
   CurrentGear.mask = deleteGearEntity(CurrentGear.mask)
   CurrentGear.tank = deleteGearEntity(CurrentGear.tank)
   CurrentGear.enabled = false

   SetEnableScuba(ped, false)
   SetPedMaxTimeUnderwater(ped, 50.00)
   ClearPedTasks(ped)
   TriggerServerEvent("InteractSound_SV:PlayOnSource", nil, 0.25)
   isWearingSuit = false
end

local function createGearEntity(model, boneId, offset, rotation)
   local ped = cache.ped
   lib.requestModel(model)

   pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
   local entity = CreateObject(model, 1.0, 1.0, 1.0, true, true, false)
   local bone = GetPedBoneIndex(ped, boneId)
   AttachEntityToEntity(entity, ped, bone, offset.x, offset.y, offset.z, rotation.x, rotation.y, rotation.z, true, true, false, false, 2, true)

   return entity
end

local function DrawText2(text)
	SetTextFont(4)
	SetTextProportional(true)
	SetTextScale(0.0, 0.45)
	SetTextDropshadow(1, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName(text)
   EndTextCommandDisplayText(0.45, 0.90)
end

local function showOxygenLevel()
   local ped = cache.ped

   while CurrentGear.enabled do
      Wait(0)
      if CurrentGear.enabled == true and isWearingSuit == true and OxygenLevel > 0 then
         if IsPedSwimmingUnderWater(cache.ped) then
            local oxygenPct = math.floor((OxygenLevel / DivingConfig.OxygenLevel) * 100)
            DrawText2('Oxygen: ' .. oxygenPct .. '%')
         end
      end
   end
end

local function createGearMaskAndTank()
   local ped = cache.ped

   CurrentGear.tank = createGearEntity(DivingConfig.TankModel, 24818,
      {x = -0.25, y = -0.25, z = 0.0}, {x = 180.0, y = 90.0, z = 0.0})

   CurrentGear.mask = createGearEntity(DivingConfig.MaskModel, 12844,
      {x = 0.0, y = 0.0, z = 0.0}, {x = 180.0, y = 90.0, z = 0.0})

   SetEnableScuba(ped, true)
   -- Tüp daha önce açıldıysa ekipman tekrar giyilince 2000 sn'yi 50'ye düşürme
   SetPedMaxTimeUnderwater(ped, OxygenLevel > 0 and 2000.00 or 50.00)
   CurrentGear.enabled = true
   ClearPedTasks(ped)
   TriggerServerEvent("InteractSound_SV:PlayOnSource", "breathdivingsuit", 0.25)

   CreateThread(showOxygenLevel)

   CreateThread(function()
      while CurrentGear.enabled do
            local ped = cache.ped -- ped değişirse (respawn/model) güncel ped'e uygula
            if OxygenLevel > 0 then
               -- Tüpte oksijen varken scuba + akciğer süresini sürekli tazele (HUD oksijeni de dolu kalır)
               SetEnableScuba(ped, true)
               SetPedMaxTimeUnderwater(ped, 2000.00)
            end
            if IsPedSwimmingUnderWater(ped) then
               OxygenLevel = OxygenLevel - 1

               if OxygenLevel % 10 == 0 and OxygenLevel <= 90 and OxygenLevel > 0 then
                  TriggerServerEvent("InteractSound_SV:PlayOnSource", "breathdivingsuit", 0.25)
               elseif OxygenLevel <= 0 then
                  OxygenLevel = 0
                  if DivingConfig.RemoveDivingGear then deleteGearMaskAndTank() end
                  SetEnableScuba(ped, false)
                  -- 1.0 sn akciğer = tüp bitince/tüpsüz dalışta anında boğulma; normal nefese dön
                  SetPedMaxTimeUnderwater(ped, 50.00)
                  Notify.SendNotify('Dalış tüpünde oksijen yok.', 'error', 5000)
                  CurrentGear.enabled = false
                  isWearingSuit = false
                  TriggerServerEvent("InteractSound_SV:PlayOnSource", nil, 0.25)
                  return
               end
            end
            Wait(1000)
      end
   end)
end

local function progressCircle(callback)
   return lib.progressCircle({
      duration = 5000,
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
end

local function handleDivingCloth()
   local ped = cache.ped
   local pedModel = GetEntityModel(ped)

   if not DivingConfig.Cloths[pedModel] or not next(DivingConfig.Cloths[pedModel]) then
      Notify.SendNotify('Bu karakter modelinde dalış kıyafeti desteklenmiyor.', 'error', 5000)
      return
   end

   playGearAnimation()

   if not progressCircle() then return end

   if not isWearingClothes then
      oldClothesCache = {}
      for compId = 0, 11 do
         oldClothesCache[compId] = {
               item = GetPedDrawableVariation(ped, compId),
               texture = GetPedTextureVariation(ped, compId),
         }
         SetPedComponentVariation(ped, compId, 0, 0, 0)
      end

      oldPropsCache = {}
      for propId = 0, 7 do
         local drawable = GetPedPropIndex(ped, propId)
         if drawable ~= -1 then
               oldPropsCache[propId] = {
                  item = drawable,
                  texture = GetPedPropTextureIndex(ped, propId),
               }
         end
         ClearPedProp(ped, propId)
      end

      for _, v in pairs(DivingConfig.Cloths[pedModel]) do
         SetPedComponentVariation(ped, v.componentId, v.item, v.texture, 0)
      end

      isWearingClothes = true
   else
      for compId, data in pairs(oldClothesCache) do
         SetPedComponentVariation(ped, compId, data.item, data.texture, 0)
      end

      for propId, data in pairs(oldPropsCache) do
         SetPedPropIndex(ped, propId, data.item, data.texture, true)
      end

      oldClothesCache = {}
      oldPropsCache = {}
      isWearingClothes = false
   end
end

local function handleDivingGear()
   local ped = cache.ped

   if IsPedSwimming(ped) or IsPedSwimmingUnderWater(ped) or IsPedInAnyVehicle(ped, false) then return end

   if not isWearingSuit then
      isWearingSuit = true
      playGearAnimation()

      if not progressCircle() then return end
      createGearMaskAndTank()
   else
      playGearAnimation()

      if not progressCircle() then return end
      deleteGearMaskAndTank()
   end
end

-- Events
AddEventHandler('onResourceStop', function(resource)
   if resource == GetCurrentResourceName() then
      deleteGearMaskAndTank()
   end
end)

RegisterNetEvent(Scriptname .. ':client:useDivingCloth', handleDivingCloth)

RegisterNetEvent(Scriptname .. ':client:useDivingGear', handleDivingGear)

lib.callback.register(Scriptname .. ':client:canUseDivingTube', function()
   if not isWearingSuit then
      Notify.SendNotify(_T('LUA.notifications.error.diving_gear_required'), 'error', 5000)
      return false
   end
   if OxygenLevel >= DivingConfig.OxygenLevel then
      Notify.SendNotify(_T('LUA.notifications.error.oxygen_tank_full'), 'error', 5000)
      return false
   end
   return true
end)

RegisterNetEvent(Scriptname .. ':client:useDivingTube', function()
   OxygenLevel = DivingConfig.OxygenLevel
   SetPedMaxTimeUnderwater(cache.ped, 2000.00)
   Notify.SendNotify(_T('LUA.notifications.success.oxygen_cylinder_opened'), 'success', 5000)
end)

AddEventHandler('onResourceStop', function(resource)
   if resource == GetCurrentResourceName() then
      deleteGearMaskAndTank()
   end
end)