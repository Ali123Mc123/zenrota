-- Bank world access: map blips plus the configured target provider or proximity prompt.

local function openBank()
  if SetBankingOpen then SetBankingOpen(true) end
end

-- DaddyRP: "Şifremi unuttum" — a code is mailed to cylex_phone, then code + new PIN are entered.
local resetBusy = false
local function pinNotify(text, kind)
  lib.notify({ title = 'Şifre sıfırlama', description = text, type = kind or 'inform', duration = 10000 })
end

function NN.PinResetFlow()
  if resetBusy then return end
  resetBusy = true
  local req = lib.callback.await('nn_banking:server:requestPinReset', false)
  if not req or not req.ok then
    pinNotify(req and req.error or 'İstek gönderilemedi', 'error')
    resetBusy = false
    return
  end
  -- Step 1: code just sent. Close here so the player can open the phone and read the mail;
  -- picking "Şifremi unuttum" again while the code is live opens the entry dialog (step 2).
  if not req.pending then
    pinNotify('Doğrulama kodu telefonuna e-posta olarak gönderildi. Telefonundan kodu öğren, sonra tekrar "Şifremi unuttum"u seçip kodu gir (5 dk geçerli).', 'success')
    resetBusy = false
    return
  end

  while true do
    local input = lib.inputDialog('Şifre sıfırlama', {
      { type = 'input', label = 'Telefona gelen kod', description = '6 haneli kod (e-posta)', required = true, min = 6, max = 6 },
      { type = 'input', label = 'Yeni şifre', description = '4 haneli', password = true, required = true, min = 4, max = 4 },
      { type = 'input', label = 'Yeni şifre (tekrar)', password = true, required = true, min = 4, max = 4 },
    })
    if not input then break end
    local code, pin, pin2 = tostring(input[1] or ''), tostring(input[2] or ''), tostring(input[3] or '')
    if pin ~= pin2 then
      pinNotify('Şifreler eşleşmiyor', 'error')
    else
      local res = lib.callback.await('nn_banking:server:confirmPinReset', false, { code = code, pin = pin })
      if res and res.ok then
        pinNotify('Şifren değiştirildi', 'success')
        break
      end
      pinNotify(res and res.error or 'Şifre değiştirilemedi', 'error')
      if not (res and res.retry) then break end
    end
  end
  resetBusy = false
end

local pinResetLabel = 'Şifremi unuttum'
local pinResetIcon = 'fa-solid fa-key'

local function createBlips()
  for _, loc in ipairs(Config.Locations or {}) do
    local blip = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
    SetBlipSprite(blip, 108)   -- Bank
    SetBlipColour(blip, 2)     -- green
    SetBlipScale(blip, 0.85)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(loc.label or NN.Translate('world.bank'))
    EndTextCommandSetBlipName(blip)
  end
end

-- Nearest bank location to the player, with its distance.
local function closestBank()
  local pc = GetEntityCoords(PlayerPedId())
  local best, bestDist = nil, math.huge
  for _, loc in ipairs(Config.Locations or {}) do
    local d = #(pc - loc.coords)
    if d < bestDist then best, bestDist = loc, d end
  end
  return best, bestDist
end

AddTextEntry('nnBankHelp', NN.Translate('world.bank_help'))

local qbZones = {}

CreateThread(function()
  createBlips()

  local provider = NN.TargetProvider()
  if provider == 'ox_target' then
    -- ox_target: a sphere zone at each bank with an "Access banking" option.
    for i, loc in ipairs(Config.Locations or {}) do
      exports.ox_target:addSphereZone({
        coords = loc.coords,
        radius = 1.6,
        debug = false,
        options = {
          {
            name = 'nn_bank_' .. i,
            label = NN.Translate('world.bank_target'),
            icon = 'fa-solid fa-building-columns',
            distance = 2.0,
            onSelect = function() openBank() end,
          },
          {
            name = 'nn_bank_pinreset_' .. i,
            label = pinResetLabel,
            icon = pinResetIcon,
            distance = 2.0,
            onSelect = function() NN.PinResetFlow() end,
          },
        },
      })
    end
    debugPrint('world access ready (' .. #(Config.Locations or {}) .. ' banks, ox_target)')
    return
  elseif provider == 'qb-target' then
    for i, loc in ipairs(Config.Locations or {}) do
      local name = 'nn_bank_' .. i
      exports['qb-target']:AddCircleZone(name, loc.coords, 1.6, {
        name = name,
        useZ = true,
        debugPoly = false,
      }, {
        options = {
          {
            icon = 'fa-solid fa-building-columns',
            label = NN.Translate('world.bank_target'),
            action = function() openBank() end,
          },
          {
            icon = pinResetIcon,
            label = pinResetLabel,
            action = function() NN.PinResetFlow() end,
          },
        },
        distance = 2.0,
      })
      qbZones[#qbZones + 1] = name
    end
    debugPrint('world access ready (' .. #(Config.Locations or {}) .. ' banks, qb-target)')
    return
  end

  -- Fallback: "Press E" proximity prompt (no target dependency).
  local prompt = (Config.BankPromptDistance) or 2.0
  while true do
    local wait = 600
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
      local _, dist = closestBank()
      if dist <= prompt then
        wait = 0
        BeginTextCommandDisplayHelp('nnBankHelp')
        EndTextCommandDisplayHelp(0, false, false, -1)
        if IsControlJustReleased(0, 38) then -- E (INPUT_CONTEXT)
          openBank()
        end
      end
    end
    Wait(wait)
  end
end)

AddEventHandler('onResourceStop', function(resource)
  if resource ~= GetCurrentResourceName() or GetResourceState('qb-target') ~= 'started' then return end
  for _, name in ipairs(qbZones) do
    pcall(function() exports['qb-target']:RemoveZone(name) end)
  end
end)

debugPrint('world access ready (' .. #(Config.Locations or {}) .. ' banks)')
