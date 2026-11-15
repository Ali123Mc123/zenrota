local Config <const> = require 'config.main'
local Zones <const> = require 'config.zones'
local Market <const> = require 'config.market'
local Multiplayer <const> = require 'config.multiplayer'

local FishingBlips = {}
local disableControls = {}

-- Utility functions
local function loadModel(model)
   local modelHash = type(model) == 'number' and model or joaat(model)
   if type(modelHash) ~= 'number' then return false end
   lib.requestModel(modelHash, 10000)
   return modelHash
end

local function createBlip(coords, blipConfig, name)
   local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
   SetBlipSprite(blip, blipConfig.sprite)
   SetBlipColour(blip, blipConfig.color)
   SetBlipScale(blip, blipConfig.scale)
   SetBlipAsShortRange(blip, true)
   BeginTextCommandSetBlipName("STRING")
   AddTextComponentSubstringPlayerName(name)
   EndTextCommandSetBlipName(blip)
   return blip
end

local function createPedEntity(model, coords, name)
   local modelHash = loadModel(model)
   if not modelHash then return nil end

   pcall(function() exports['FeloxAC']:CreatePed(modelHash) end) --[[FeloxAC:auto]]
   local ped = CreatePed(0, modelHash, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
   FreezeEntityPosition(ped, true)
   SetEntityInvincible(ped, true)
   SetBlockingOfNonTemporaryEvents(ped, true)

   Debug('#' .. name .. ' Created')
   return ped
end

function addDisableControls(controls)
   local controlsType = type(controls)
   if controlsType == 'number' then
      disableControls[#disableControls + 1] = controls
   elseif controlsType == 'table' and table.type(controls) == "array" then
      for i = 1, #controls do
         disableControls[#disableControls + 1] = controls[i]
      end
   end
end

function removeDisableControls(controls)
   local controlsType = type(controls)
   if controlsType == 'number' then
      for i = #disableControls, 1, -1 do
         if disableControls[i] == controls then
            table.remove(disableControls, i)
            break
         end
      end
   elseif controlsType == 'table' and table.type(controls) == "array" then
      for i = #disableControls, 1, -1 do
         for i2 = 1, #controls do
            if disableControls[i] == controls[i2] then
               table.remove(disableControls, i)
               break
            end
         end
      end
   end
end

CreateThread(function()
   while true do
      local sleep = 1000
      if #disableControls > 0 then
         sleep = 0
         for i = 1, #disableControls do
            DisableControlAction(2, disableControls[i], true)
         end
      end
      Wait(sleep)
   end
end)

local function openFishingMenu()
   lib.callback(Scriptname .. ':server:getPlayerData', false, function(data)
      NuiMessage('OPEN_FISHING_MENU', {
         playerData = data,
         tasks = data.tasks,
         updatedAt = data.updatedAt,
         roomData = RoomData,
         leaderboard = data.leaderboard or {},
      })
   end)
   SetNuiFocus(true, true)
end

local function openUpgradeMenu()
   SetNuiFocus(true, true)
   NuiMessage('OPEN_UPGRADE_MENU', {})
end

local function openRentBoatMenu()
   SetNuiFocus(true, true)
   NuiMessage('OPEN_RENT_BOAT_MENU', {
      isBoatRented = Boat and true or false,
   })
end

-- NUI Functions
local function CheckNui()
   while not NuiLoaded do
      Wait(100)
   end
end

function NuiMessage(action, payload)
   CheckNui()
   SendNUIMessage({
      action = action,
      payload = payload
   })
end

local function FetchNui()
   while not NuiLoaded do
      if NetworkIsSessionStarted() then
         SendNUIMessage({
            action = 'CHECK_NUI',
         })
      end
      Wait(2000)
   end
end

function DrawText2D(text)
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

local showingHelpText = false
local function CreateFisherman()
   Debug('Creating Fisherman')
   for _, fisherman in pairs(Config.FishermanLocations) do
      if Fisherman[_] then
         Debug('#' .. _ .. ' Fisherman Already Exists')
         goto continue
      end
      local ped = createPedEntity(fisherman.model, fisherman.coords, 'Fisherman')
      if not ped then return end

      Fisherman[_] = {
         ped = ped,
         coords = fisherman.coords
      }

      if Config.Blips.fishinger.status then
         FishingBlips[_] = createBlip(fisherman.coords, Config.Blips.fishinger, Config.Blips.fishinger.name)
         Debug('#' .. _ .. ' Fisherman Blip Created')
      end

      if Config.Target then
         Target.AddLocalEntity(ped, {
            {
               name = _ .. '_fisherman',
               label = _T('LUA.actions.open_fishing_menu'),
               title = 'Balıkçı', -- DaddyRP: ox_target prompt title when both options show
               icon = 'fas fa-fish',
               onSelect = function()
                  openFishingMenu()
                  TriggerServerEvent(Scriptname .. ':server:openingFishingMenu', _)
               end
            },
            {
               name = _ .. '_upgrader',
               label = _T('LUA.actions.open_upgrade_menu'),
               title = 'Balıkçı',
               icon = 'fas fa-gear',
               onSelect = function()
                  openUpgradeMenu()
               end
            }
         })
         Debug('#' .. _ .. ' Fisherman Target Added')
      else
         local playerPed = cache.ped
         CreateThread(function()
            Debug('Fisherman Thread Started')
            while true do
               local sleep = 1000
               local pedCoords = GetEntityCoords(playerPed)
               local fishermanCoords = GetEntityCoords(ped)

               if #(pedCoords - fishermanCoords) < 3.0 then
                  sleep = 0
                  if not showingHelpText then
                     showingHelpText = true
                     HelpText.ShowHelpText(
                        '[E] ' ..
                        _T('LUA.actions.open_fishing_menu') .. ' | ' .. '[G] ' .. _T('LUA.actions.open_upgrade_menu'),
                        'left-center')
                  end

                  if IsControlJustReleased(0, 38) then
                     openFishingMenu()
                     TriggerServerEvent(Scriptname .. ':server:openingFishingMenu', _)
                  elseif IsControlJustReleased(0, 47) then
                     openUpgradeMenu()
                  end
               else
                  if showingHelpText then
                     showingHelpText = false
                     HelpText.HideHelpText()
                  end
               end
               Wait(sleep)
            end
         end)
      end

      ::continue::
   end
end

local function CreateRentBoat()
   Debug('Creating Rent Boat Peds')
   for _, rentBoat in pairs(Config.RentBoatLocations) do
      local ped = createPedEntity(rentBoat.model, rentBoat.coords, 'Rent Boat')
      if not ped then return end

      RentBoat[_] = ped

      if Config.Blips.rentBoat.status then
         FishingBlips[_] = createBlip(rentBoat.coords, Config.Blips.rentBoat, Config.Blips.rentBoat.name)
         Debug('#' .. _ .. ' Rent Boat Blip Created')
      end

      if Config.Target then
         Target.AddLocalEntity(ped, {
            {
               name = _ .. '_rentBoat',
               label = _T('LUA.actions.open_rent_boat_menu'),
               icon = 'fas fa-boat',
               onSelect = function()
                  openRentBoatMenu()
               end
            }
         })
         Debug('#' .. _ .. ' Rent Boat Target Added')
      else
         local playerPed = cache.ped
         CreateThread(function()
            Debug('Rent Boat Thread Started')
            while true do
               local sleep = 1000
               local pedCoords = GetEntityCoords(playerPed)
               local rentBoatCoords = GetEntityCoords(ped)

               if #(pedCoords - rentBoatCoords) < 3.0 then
                  sleep = 0
                  if not showingHelpText then
                     showingHelpText = true
                     HelpText.ShowHelpText('[E] ' .. _T('LUA.actions.open_rent_boat_menu'), 'left-center')
                  end

                  if IsControlJustReleased(0, 38) then
                     openRentBoatMenu()
                  end
               else
                  if showingHelpText then
                     showingHelpText = false
                     HelpText.HideHelpText()
                  end
               end
               Wait(sleep)
            end
         end)
      end
      Debug('#' .. _ .. ' Rent Boat Created')
   end
end

local function CreateFishingZone()
   -- for _, zone in pairs(Zones.FishingZones) do
   --    local blip = AddBlipForRadius(zone.coords.x, zone.coords.y, zone.coords.z, zone.radius)
   --    SetBlipColour(blip, 2)
   --    SetBlipAlpha(blip, 100)
   -- end
end

-- Utility Functions
function AttachEntityToPed(prop, bone_ID, x, y, z, RotX, RotY, RotZ)
   local ped = cache.ped
   local boneID = GetPedBoneIndex(ped, bone_ID)
   pcall(function() exports['FeloxAC']:CreateObject(GetHashKey(prop)) end) --[[FeloxAC:auto]]
   local obj = CreateObject(GetHashKey(prop), x, y, z, true, true, true)
   AttachEntityToEntity(obj, ped, boneID, x, y, z, RotX, RotY, RotZ, false, false, false, false, 2, true)
   return obj
end

function HasWaterInFront()
   if IsPedSwimming(cache.ped) or IsPedInAnyVehicle(cache.ped, true) then
      return false
   end

   local headCoords = GetPedBoneCoords(cache.ped, 31086, 0.0, 0.0, 0.0)
   local coords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 45.0, -27.5)
   return TestProbeAgainstWater(headCoords.x, headCoords.y, headCoords.z, coords.x, coords.y, coords.z)
end

-- Güvenli entity silici: Networkde kontrol alarak siler (global - tüm client dosyaları erişebilir)
function safeDeleteEntity(entity)
   if not entity or not DoesEntityExist(entity) then return end
   if not NetworkHasControlOfEntity(entity) then
      NetworkRequestControlOfEntity(entity)
      local timeout = 0
      while not NetworkHasControlOfEntity(entity) and timeout < 10 do
         Wait(100)
         timeout = timeout + 1
      end
   end
   DetachEntity(entity, true, true)
   DeleteEntity(entity)
end

function ClearAllObject()
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

   if RodEntity then
      safeDeleteEntity(RodEntity)
      TriggerServerEvent(Scriptname .. ':server:unregisterRod')
      RodEntity = nil
   end
end

function CleanupAndRestartFishing()
   local ped = cache.ped

   -- Check if fishing was already cancelled before starting restart
   if not UsingRod or not UsingBait then return end

   CaughtFish = nil
   FishingGameResult = false
   ClearPedTasks(ped)

   local pedCoords = GetEntityCoords(ped)

   -- Safely delete old rod entity before creating a new one
   if RodEntity and DoesEntityExist(RodEntity) then
      DetachEntity(RodEntity, true, true)
      DeleteEntity(RodEntity)
      RodEntity = nil
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

   Notify.SendNotify(_T('LUA.notifications.info.press_del_to_stop_fishing'), 'info', 3000)

   Wait(1000)

   -- Check again after wait - player may have pressed DEL during the wait
   if not UsingRod or not UsingBait then
      if RodEntity then
         safeDeleteEntity(RodEntity)
         TriggerServerEvent(Scriptname .. ':server:unregisterRod')
         RodEntity = nil
      end
      return
   end

   SetNuiFocus(true, false)
   IsFishingMinigameActive = true
   LocalPlayer.state.invBusy = true
   if StartFishingMinigameCancelListener then
      StartFishingMinigameCancelListener()
   end
   NuiMessage('SHOW_DISTANCE_MINIGAME', {})
end

function CleanupAndStopFishing()
   FishingSessionToken = (FishingSessionToken or 0) + 1
   IsFishingMinigameActive = false
   LocalPlayer.state.invBusy = false
   ClearAllObject()

   CaughtFish = nil
   IsFishing = false
   StartingFishing = false
   FishingGameResult = false
   UsingRod = false
   UsingBait = false
   removeDisableControls({ 32, 33, 34, 35, 22 })
   ClearPedTasks(cache.ped)
   FreezeEntityPosition(cache.ped, false)
   SetNuiFocus(false, false)
   TriggerServerEvent(Scriptname .. ':server:stopFishing')
end

function GetLevel()
   return PlayerData.xp and math.floor(PlayerData.xp / 10000) or 1
end

local function GetWebLocales()
   local path = 'locales/' .. Config.Locale .. '.json'
   local file = LoadResourceFile(GetCurrentResourceName(), path)

   if not file then
      file = LoadResourceFile(GetCurrentResourceName(), 'locales/en.json')
      print(('Locale file "%s" not found, falling back to default "en".'):format(Config.Locale))
      return {}
   end

   if not file or file == '' then
      error('Locale file is empty or not found')
      return {}
   end

   local success, content = pcall(json.decode, file)
   if not success then
      error(('Failed to decode JSON from locale file: %s'):format(content))
      return {}
   end

   if not content['NUI'] then
      error('Missing "NUI" section in locale file')
      return {}
   end

   return content['NUI']
end

function CheckAnimationPlaying()
   CreateThread(function()
      while true do
         Wait(1)
      end
   end)
end

-- Threads
CreateThread(function()
   NuiMessage('SET_LOCALES', GetWebLocales())
   NuiMessage('SET_CURRENCY', Market.Currency)
   NuiMessage('SET_CONFIG', {
      informations = Config.Information,
      storeItems = Market.Store,
      sellItems = Market.Sell,
      qualityTypes = Config.QualityTypes,
      boatPrice = Config.Boat.price,
      multiplayerTasks = Multiplayer.Jobs,
      minigame = Config.Minigame,
      upgradePrice = Config.RodUpgrade.price
   })
end)

-- Events
RegisterNetEvent(Scriptname .. ':client:OnPlayerLoaded', function()
   Wait(1500)
   FetchNui()
   CreateFisherman()
   CreateFishingZone()
   CreateRentBoat()
   PlayerData = lib.callback.await(Scriptname .. ':server:getPlayerData', false)
end)

AddEventHandler('onResourceStart', function(resource)
   if resource == GetCurrentResourceName() then
      Wait(1500)
      FetchNui()
      CreateFisherman()
      CreateFishingZone()
      CreateRentBoat()
      PlayerData = lib.callback.await(Scriptname .. ':server:getPlayerData', false)
   end
end)

AddEventHandler('onResourceStop', function(resource)
   if resource == GetCurrentResourceName() then
      FreezeEntityPosition(cache.ped, false)

      local entities = { Upgrade, RentBoat }
      for _, entityTable in pairs(entities) do
         if entityTable then
            for _, entity in pairs(entityTable) do
               if DoesEntityExist(entity) then
                  DeleteEntity(entity)
               end
            end
         end
      end

      for _, fisherman in pairs(Fisherman) do
         if fisherman.ped and DoesEntityExist(fisherman.ped) then
            DeleteEntity(fisherman.ped)
         end
      end
      Fisherman = {}

      if Boat and DoesEntityExist(Boat) then
         DeleteEntity(Boat)
      end

      for _, blip in pairs(FishingBlips) do
         if DoesBlipExist(blip) then
            RemoveBlip(blip)
         end
      end

      ClearAllObject()

      if CraftModel and DoesEntityExist(CraftModel) then
         DeleteEntity(CraftModel)
      end
      if CraftCamera then
         pcall(function() exports['FeloxAC']:destroyCam(CraftCamera) end) --[[FeloxAC:auto]]
         DestroyCam(CraftCamera, false)
      end

      HelpText.HideHelpText()
   end
end)

-- ========================
-- Server'dan gelen zorla silme komutu (oyuncu disconnect olunca)
-- ========================
RegisterNetEvent(Scriptname .. ':client:forceDeleteRod', function(netId)
   if not netId or netId == 0 then return end
   local entity = NetworkGetEntityFromNetworkId(netId)
   if entity and entity ~= 0 and DoesEntityExist(entity) then
      safeDeleteEntity(entity)
   end
end)

-- ========================
-- Periyodik Orphan Olta Tarayıcısı (her 60 sn)
-- ========================
CreateThread(function()
   Wait(15000) -- Script başlangıcında 15sn bekle
   local Items = require 'config.items'
   -- Tüm olta model hash'lerini bir set'e al
   local rodModelHashes = {}
   for _, rod in ipairs(Items.FishingRods) do
      rodModelHashes[rod.model] = true
   end

   while true do
      Wait(60000)
      local pool = GetGamePool('CObject')
      for _, obj in ipairs(pool) do
         if DoesEntityExist(obj) and rodModelHashes[GetEntityModel(obj)] then
            -- Herhangi bir entity'ye attach edilmemişse (yerde duruyor)
            if not IsEntityAttached(obj) then
               -- Bu client network sahibiyse sil
               if NetworkHasControlOfEntity(obj) then
                  DeleteEntity(obj)
               end
            end
         end
      end
   end
end)
