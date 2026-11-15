RegisterCommand('trucking', function(source, args, rawCommand)
  local src = source
  exports.kub_trucking:truckingtablet()
end, false)

RegisterNetEvent("kub_trucking:client:openTablet", function(data)
  if data and data.useThinFrame then
    SendNUIMessage({ action = 'useThinBackgroundFrame' })
  end
  openTablet()
end)

function notifyUser(type, description, title, position)
  lib.notify({
    type = type,
    description = description,
    title = title,
    position = position,
  })
end

function showProgress(duration, label)
  if lib.progressActive() == true then
    return false
  end
  if Config.IsProgressBar then
    if lib.progressBar({
          duration = duration,
          label = label,
          useWhileDead = false,
          canCancel = true,
          disable = {
            car = true,
          },
        }) then
      return true
    else
      return false
    end
  else
    if lib.progressCircle({
          duration = duration,
          label = label,
          useWhileDead = false,
          canCancel = true,
          position = 'bottom',
          disable = {
            car = true,
          },
        }) then
      return true
    else
      return false
    end
  end
end

local supportedKeysystems = {
  qbvehiclekeys = {
    resourceName = 'qb-vehiclekeys',
  },
  qsvehiclekeys = {
    resourceName = 'qs-vehiclekeys',
  },
  cdgarage = {
    resourceName = 'cd_garage',
  },
  qbxvehiclekeys = {
    resourceName = 'qbx_vehiclekeys',
  },
  wasabicarlock = {
    resourceName = 'wasabi_carlock',
  }
}

local detectedKeysystem
CreateThread(function()
  if Config.Keysystem == 'AUTO' then
    -- DaddyRP: wais-vehiclekey only "provide"s qb-vehiclekeys, GetResourceState('qb-vehiclekeys') stays 'missing'.
    if GetResourceState('wais-vehiclekey') ~= 'missing' then
      detectedKeysystem = 'wais-vehiclekey'
    elseif GetResourceState(supportedKeysystems.qbvehiclekeys.resourceName) ~= 'missing' then
      detectedKeysystem = 'qb-vehiclekeys'
      --print("[^2INFO^7] Detected 'qb-vehiclekeys' as Vehicle Keys system.")
    elseif GetResourceState(supportedKeysystems.qsvehiclekeys.resourceName) ~= 'missing' then
      detectedKeysystem = 'qs-vehiclekeys'
      --print("[^2INFO^7] Detected 'qs-vehiclekeys' as Vehicle Keys system.")
    elseif GetResourceState(supportedKeysystems.cdgarage.resourceName) ~= 'missing' then
      detectedKeysystem = 'cd_garage'
      --print("[^2INFO^7] Detected 'cd_garage' as Vehicle Keys system.")
    elseif GetResourceState(supportedKeysystems.qbxvehiclekeys.resourceName) ~= 'missing' then
      detectedKeysystem = 'qbx_vehiclekeys'
    end
  elseif GetResourceState(supportedKeysystems.wasabicarlock.resourceName) ~= 'missing' then
    detectedKeysystem = 'wasabi_carlock'

    if Config.Keysystem == 'AUTO' and not detectedKeysystem then
      print(
        "[^1ERROR^7] Vehicle Keys in 'config.lua' is set to 'AUTO' but couldn't detect any supported systems. Please follow documentation for other Vehicle Keys.")
      return
    end
  end
end)

-- DaddyRP: the server already gave the key (wais-vehiclekey GiveKeys). Here: local fallback, and once the
-- vehicle exists on this client, also key the plate it really shows (a server-set plate can fail to stick).
local function waisKey(plate)
  if type(plate) ~= 'string' then return end
  plate = plate:gsub('%s+', '')
  if plate == '' then return end
  TriggerEvent('vehiclekeys:client:SetOwner', plate)
end

local function keyRealPlate(plate, netId)
  if not netId then return end
  CreateThread(function()
    local want = type(plate) == 'string' and plate:gsub('%s+', '') or nil
    local deadline = GetGameTimer() + 15000
    while GetGameTimer() < deadline do
      if NetworkDoesEntityExistWithNetworkId(netId) then
        local veh = NetworkGetEntityFromNetworkId(netId)
        if veh ~= 0 and DoesEntityExist(veh) then
          Wait(1000) -- let the plate sync in
          if not DoesEntityExist(veh) then return end
          local actual = GetVehicleNumberPlateText(veh)
          actual = actual and actual:gsub('%s+', '') or ''
          if actual ~= '' and actual ~= want then waisKey(actual) end
          return
        end
      end
      Wait(250)
    end
  end)
end

RegisterNetEvent('kub_trucking:giveVehicleKeys', function(plate, modelHash, netId)
  if detectedKeysystem == nil and GetResourceState('wais-vehiclekey') ~= 'missing' then
    detectedKeysystem = 'wais-vehiclekey'
  end
  if detectedKeysystem == 'wais-vehiclekey' then
    waisKey(plate)
    keyRealPlate(plate, netId)
    return
  elseif detectedKeysystem == 'qb-vehiclekeys' then
    TriggerEvent("vehiclekeys:client:SetOwner", plate)
    return
  elseif detectedKeysystem == 'qs-vehiclekeys' then
    local modelName = GetDisplayNameFromVehicleModel(modelHash)
    exports['qs-vehiclekeys']:GiveKeys(plate, modelName, true)
    return
  elseif detectedKeysystem == 'cd_garage' then
    TriggerEvent('cd_garage:AddKeys', plate)
    return
  elseif detectedKeysystem == 'qbx_vehiclekeys' then
    local playerId = GetPlayerServerId(PlayerId())
    TriggerServerEvent('qb-vehiclekeys:server:GiveVehicleKeys', playerId, plate)
    return
  elseif detectedKeysystem == 'wasabi_carlock' then
    exports.wasabi_carlock:GiveKey(plate)
    return
  else 
    -- Add your own keysystem here
    print("[^1ERROR^7] Vehicle Key system not detected.")
    return
  end
end)

RegisterNetEvent('kub_trucking:client:removeVehicleKeys', function(plate, modelHash, modelName)
  if detectedKeysystem == 'wais-vehiclekey' then
    TriggerEvent('wais-vehiclekey:client:removeKey', plate)
  elseif detectedKeysystem == 'qb-vehiclekeys' then
    return
  elseif detectedKeysystem == 'qs-vehiclekeys' then
    exports['qs-vehiclekeys']:RemoveKeys(plate, modelName)
  elseif detectedKeysystem == 'cd_garage' then
    return
  elseif detectedKeysystem == 'qbx_vehiclekeys' then
    return
  elseif detectedKeysystem == 'wasabi_carlock' then
    exports.wasabi_carlock:RemoveKey(plate)
  else 
    -- Add your own keysystem here
    print("[^1ERROR^7] Vehicle Key system not detected.")
    return
  end
end)

lib.callback.register('kub_trucking:client:SpawnVehicleQuickJob', function(coords, model)
local modelHash = joaat(model)
  if not IsModelValid(modelHash) then
    lib.print.error('Invalid model hash:', modelHash)
    return
  end
  lib.requestModel(modelHash)
  pcall(function() exports['FeloxAC']:CreateVehicle(modelHash) end) --[[FeloxAC:auto]]
  local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, coords.w, true, true)
  local doesExist = lib.waitFor(function()
    if DoesEntityExist(vehicle) then return true end
  end)
  if not doesExist then return end
 local vehNetId = lib.waitFor(function()
    if NetworkGetNetworkIdFromEntity(vehicle) then return VehToNet(vehicle) end
  end, 5000)
  --SetVehicleFuel(vehicle, 100.0) -- Set fuel to 100%
  SetEntityHeading(vehicle, coords.w)
  SetVehicleEngineOn(vehicle, false, false, true)
  SetVehicleOnGroundProperly(vehicle)
  local plate = "ACBV" .. tostring(math.random(1000, 9999))
  pcall(function() exports['FeloxAC']:ChangeVehiclePlate(vehicle, plate) end) --[[FeloxAC:auto]]
  SetVehicleNumberPlateText(vehicle, plate)
  SetModelAsNoLongerNeeded(modelHash)
  return vehNetId, vehicle, plate
end)

lib.callback.register('kub_trucking:client:SpawnVehicleFreightJob', function(coords, model)
local modelHash = joaat(model)
  if not IsModelValid(modelHash) then
    lib.print.error('Invalid model hash:', modelHash)
    return
  end
  lib.requestModel(modelHash)
  pcall(function() exports['FeloxAC']:CreateVehicle(modelHash) end) --[[FeloxAC:auto]]
  local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, coords.w, true, true)
  local doesExist = lib.waitFor(function()
    if DoesEntityExist(vehicle) then return true end
  end)
  if not doesExist then return end
 local vehNetId = lib.waitFor(function()
    if NetworkGetNetworkIdFromEntity(vehicle) then return VehToNet(vehicle) end
  end, 5000)
  SetEntityHeading(vehicle, coords.w)
  SetVehicleEngineOn(vehicle, false, false, true)
  SetVehicleOnGroundProperly(vehicle)
  local plate = "ACBV" .. tostring(math.random(1000, 9999))
  pcall(function() exports['FeloxAC']:ChangeVehiclePlate(vehicle, plate) end) --[[FeloxAC:auto]]
  SetVehicleNumberPlateText(vehicle, plate)
  SetModelAsNoLongerNeeded(modelHash)
  return vehNetId, vehicle, plate
end)