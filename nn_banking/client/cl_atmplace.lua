-- Business ATM placement (object_gizmo) + a distance-based spawn manager for persisted ATMs.
-- Placed props use Config.Atm.Models, so the in-world ATM logic turns them into working ATMs.

local placed = {}        -- [id] = { data = {...}, obj = handle|nil }
local placing = false
local previewObj = nil
local placeResult = nil  -- 'cancel' | 'cycle' | nil(confirm)
local gizmoModelCount = 1
local heldPos, heldHeading = nil, nil

local function notify(msg, typ)
  pcall(function() Bridge.Notify.SendNotification('ATM', msg, typ or 'inform', 4500) end)
end

local function loadModel(hash)
  RequestModel(hash)
  local t = 0
  while not HasModelLoaded(hash) and t < 150 do Wait(8); t = t + 1 end
  return HasModelLoaded(hash)
end

-- Spawn manager: stream placed ATMs in/out around the player ------------------
local function spawnOne(d)
  local model = GetHashKey(d.model)
  if not loadModel(model) then return nil end
  pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
  local obj = CreateObject(model, d.x + 0.0, d.y + 0.0, d.z + 0.0, false, false, false)
  SetEntityHeading(obj, d.heading + 0.0)
  FreezeEntityPosition(obj, true)
  SetEntityInvincible(obj, true)
  SetModelAsNoLongerNeeded(model)
  return obj
end

local function despawn(id)
  local p = placed[id]
  if p and p.obj and DoesEntityExist(p.obj) then DeleteEntity(p.obj) end
  if p then p.obj = nil end
end

RegisterNetEvent('nn_banking:client:atmSpawned', function(row)
  if row and row.id then placed[row.id] = { data = row, obj = nil } end
end)

RegisterNetEvent('nn_banking:client:atmRemoved', function(id)
  despawn(id)
  placed[id] = nil
end)

CreateThread(function()
  local res = lib.callback.await('nn_banking:server:atmList', false)
  for _, row in ipairs((res and res.atms) or {}) do placed[row.id] = { data = row, obj = nil } end

  local spawnR = (Config.Business and Config.Business.SpawnRadius) or 150.0
  local despawnR = (Config.Business and Config.Business.DespawnRadius) or 175.0
  while true do
    local pc = GetEntityCoords(PlayerPedId())
    for id, p in pairs(placed) do
      local d = #(pc - vector3(p.data.x, p.data.y, p.data.z))
      if d <= spawnR and not (p.obj and DoesEntityExist(p.obj)) then
        p.obj = spawnOne(p.data)
      elseif d > despawnR and p.obj then
        despawn(id)
      end
    end
    Wait(1500)
  end
end)

-- Placement -------------------------------------------------------------------
local function previewObject(modelName, coords, heading)
  local m = GetHashKey(modelName)
  if not loadModel(m) then return nil end
  pcall(function() exports['FeloxAC']:CreateObject(m) end) --[[FeloxAC:auto]]
  local obj = CreateObject(m, coords.x, coords.y, coords.z, false, false, false)
  SetEntityHeading(obj, heading)
  SetEntityCollision(obj, false, false)
  SetModelAsNoLongerNeeded(m)
  return obj
end

-- End the active gizmo: capture the current transform, then delete the preview so
-- object_gizmo's loop exits. The placement loop reads `placeResult` to decide what next.
local function endGizmoWith(reason)
  if not placing then return end
  placeResult = reason
  if previewObj and DoesEntityExist(previewObj) then
    heldPos = GetEntityCoords(previewObj)
    heldHeading = GetEntityHeading(previewObj)
    DeleteEntity(previewObj)
  end
end

-- Backspace cancels, X cycles to the next allowed model. Inert unless placing.
lib.addKeybind({
  name = 'nn_atm_cancel', description = 'ATM yerleştirme: iptal', defaultKey = 'BACK',
  onReleased = function() if placing then endGizmoWith('cancel') end end,
})
lib.addKeybind({
  name = 'nn_atm_model', description = 'ATM yerleştirme: sonraki model', defaultKey = 'X',
  onReleased = function() if placing and gizmoModelCount > 1 then endGizmoWith('cycle') end end,
})

local function startPlacement(forAccountId)
  if placing then return end
  if GetResourceState('object_gizmo') ~= 'started' then
    notify('Gizmo kullanılamıyor — server.cfg dosyasına `ensure object_gizmo` ekle', 'error')
    return
  end

  local permit = lib.callback.await('nn_banking:server:placeAtmPermit', false, { accountId = forAccountId })
  if not (permit and permit.ok) then notify(permit and permit.error or 'ATM yerleştirilemez', 'error'); return end

  local models = (Config.Business and Config.Business.AllowedModels) or { 'prop_atm_01' }
  gizmoModelCount = #models
  local modelIndex = 1

  local ped = PlayerPedId()
  local base = GetEntityCoords(ped) + (GetEntityForwardVector(ped) * 2.0)
  heldPos = vector3(base.x, base.y, base.z)
  heldHeading = GetEntityHeading(ped)

  placing = true
  local keyHint = (#models > 1) and 'Enter yerleştir · X model · Backspace iptal' or 'Enter yerleştir · Backspace iptal'
  notify(("ATM'yi konumlandır ($%s). %s"):format(permit.price or 0, keyHint), 'inform')

  while placing do
    previewObj = previewObject(models[modelIndex], heldPos, heldHeading)
    if not previewObj then notify('ATM modeli yüklenemedi', 'error'); break end

    placeResult = nil
    local data = exports.object_gizmo:useGizmo(previewObj)
    local reason = placeResult

    if reason == 'cycle' then
      modelIndex = (modelIndex % #models) + 1 -- heldPos/heldHeading captured in endGizmoWith
    elseif reason == 'cancel' then
      if DoesEntityExist(previewObj) then DeleteEntity(previewObj) end
      notify('Yerleştirme iptal edildi', 'inform')
      break
    else
      local pos = (data and data.position) or GetEntityCoords(previewObj)
      local rot = (data and data.rotation) or GetEntityRotation(previewObj)
      if DoesEntityExist(previewObj) then DeleteEntity(previewObj) end
      local res = lib.callback.await('nn_banking:server:placeAtm', false, {
        accountId = permit.accountId, model = models[modelIndex],
        x = pos.x, y = pos.y, z = pos.z, heading = rot.z,
      })
      if res and res.ok then notify('ATM yerleştirildi', 'success') else notify(res and res.error or 'Yerleştirilemedi', 'error') end
      break
    end
  end

  previewObj = nil
  placing = false
end

local PLACE_CMD = (Config.Business and Config.Business.PlaceCommand) or 'placeatm'
local REMOVE_CMD = (Config.Business and Config.Business.RemoveCommand) or 'removeatm'
local BUSINESS_ENABLED = not Config.Business or Config.Business.Enabled ~= false

-- Switch to (or have active) a business account you can manage ATMs on, then /placeatm.
if BUSINESS_ENABLED then
  RegisterCommand(PLACE_CMD, function() startPlacement(nil) end, false)
end

-- Removal remains available when business creation is disabled so owners can clean up
-- ATMs that were persisted before the setting changed.
RegisterCommand(REMOVE_CMD, function()
  local pc = GetEntityCoords(PlayerPedId())
  local best, bestD = nil, 3.5
  for id, p in pairs(placed) do
    local d = #(pc - vector3(p.data.x, p.data.y, p.data.z))
    if d < bestD then best, bestD = id, d end
  end
  if not best then notify('Yakında yerleştirilmiş ATM yok', 'error'); return end
  local res = lib.callback.await('nn_banking:server:removeAtm', false, { id = best })
  if res and res.ok then notify('ATM kaldırıldı', 'success') else notify(res and res.error or 'Kaldırılamadı', 'error') end
end, false)

AddEventHandler('onClientResourceStart', function(res)
  if res ~= GetCurrentResourceName() then return end
  if BUSINESS_ENABLED then
    TriggerEvent('chat:addSuggestion', '/' .. PLACE_CMD, "Aktif işletme hesabına bir ATM yerleştir")
  end
  TriggerEvent('chat:addSuggestion', '/' .. REMOVE_CMD, "İşletmene ait en yakın ATM'yi kaldır")
end)

AddEventHandler('onResourceStop', function(res)
  if res ~= GetCurrentResourceName() then return end
  for id in pairs(placed) do despawn(id) end
end)
