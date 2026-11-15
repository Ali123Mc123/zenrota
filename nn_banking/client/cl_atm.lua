-- ATM DUI controller. Paints the atm.html surface onto the ATM prop's screen, frames a camera,
-- captures keypad input (the DUI has no focus), and drives the screens via SendDuiMessage.
-- The screen-texture slot + camera offsets vary by GTA build — tune with /atm_tex (see below).

local MENU = { 'withdraw', 'deposit', 'balance', 'history', 'exit' }
-- DUI must use the cfx-nui scheme. The nui:// scheme can make
-- CreateDui return a handle that GetDuiHandle/CreateRuntimeTextureFromDuiHandle reject.
local DUI_URL = 'https://cfx-nui-' .. GetCurrentResourceName() .. '/web/build/atm.html'

local atm = nil          -- active session state, or nil
local texOverride = nil  -- { txd, tex } set by /atm_tex for tuning
local fitOverride = nil  -- { x, y, w, h } screen-rect (UV 0..1) set by /atm_fit for tuning

-- Push the current state to the DUI display.
local function render()
  if not atm or not atm.dui then return end
  SendDuiMessage(atm.dui, json.encode({
    action = 'atm',
    data = {
      screen = atm.screen,
      holderName = atm.holderName,
      balance = atm.balance,
      cash = atm.cash,
      pinLength = #(atm.pin or ''),
      pinError = atm.pinError,
      menuIndex = atm.menuIndex or 0,
      amountMode = atm.amountMode,
      amount = atm.amount or '',
      statement = atm.statement, -- recent transactions for the mini-statement screen
      result = atm.result,
      skin = atm.skin, -- per-ATM look (label/accent/subtitle from Config.Atm.Skins)
      sideLayout = atm.sideLayout, -- { left = {menu keys}, right = {…} } for the soft-key UI
      optionPos = atm.optionPos,   -- per-option label positions (0..1) for the menu
      currency = Config.Currency,
      currencyPosition = Config.CurrencyPosition == 'after' and 'after' or 'before',
      currencySpacing = Config.CurrencySpacing == true,
      locale = Config.Locale or 'auto',
      localeCatalog = NN.ConfiguredLocaleCatalog(),
    },
  }))
end

-- Texture target for a given model (with /atm_tex override).
local function textureFor(model)
  if texOverride then return texOverride end
  for name, t in pairs(Config.Atm.Textures) do
    if GetHashKey(name) == model then return t end
  end
  return nil
end

-- Per-ATM DUI skin for a given model (Config.Atm.Skins keyed by prop name, with `default`).
local function skinFor(model)
  local skins = Config.Atm.Skins or {}
  for name, sk in pairs(skins) do
    if name ~= 'default' and GetHashKey(name) == model then return sk end
  end
  return skins.default
end

-- Fully tear down a session. Robust against partial setup (called from OpenAtm's fail path too):
-- clears `atm` FIRST so the input loop stops disabling controls, then unwinds cam/tex/DUI and
-- ALWAYS unfreezes the ped. Every native is guarded so one bad handle can't leave the player stuck.
-- DaddyRP: the PIN is typed with the game's 1-9 keys, which are also ox_inventory's hotbar; the hotbar and the
-- inventory are shut while the ATM is open and given back as they were.
local invLock
local function lockInventory(on)
  local st = LocalPlayer.state
  if on and not invLock then
    invLock = { hotkeys = st.invHotkeys, busy = st.invBusy }
    st:set('invHotkeys', false, false)
    st:set('invBusy', true, false)
  elseif not on and invLock then
    st:set('invHotkeys', invLock.hotkeys ~= false, false)
    st:set('invBusy', invLock.busy == true, false)
    invLock = nil
  end
end

local function teardown()
  if not atm then return end
  local a = atm
  atm = nil
  lockInventory(false)
  if a.mode then
    SetNuiFocus(false, false)
    local msg = a.mode == 'buttons' and 'atmButtonConfig'
      or a.mode == 'optpos' and 'atmOptionConfig'
      or 'atmConfig'
    SendNUIMessage({ action = msg, data = { open = false } })
  end
  if a.cam then
    RenderScriptCams(false, true, 400, true, true)
    if DoesCamExist(a.cam) then pcall(function() pcall(function() exports['FeloxAC']:destroyCam(a.cam) end) --[[FeloxAC:auto]] DestroyCam(a.cam, false) end) end
  end
  if a.tex then pcall(function() RemoveReplaceTexture(a.tex.txd, a.tex.tex) end) end
  if a.dui then pcall(function() DestroyDui(a.dui) end) end
  FreezeEntityPosition(PlayerPedId(), false)
end

function CloseAtm()
  teardown()
end

-- Blocking server call helper (run from a thread).
local function srv(name, payload)
  return lib.callback.await('nn_banking:server:' .. name, false, payload)
end

-- Apply a money-op result ({ok, account, cash}) to the local display.
local function applyMoneyResult(res, okTitleKey)
  if res and res.ok then
    atm.balance = res.account and res.account.balance or atm.balance
    atm.cash = res.cash ~= nil and res.cash or atm.cash
    atm.result = {
      ok = true,
      titleKey = okTitleKey,
      messageKey = 'atm.new_balance',
      messageVars = { amount = formatMoney(atm.balance) },
    }
  else
    atm.result = {
      ok = false,
      titleKey = 'atm.declined',
      message = res and res.error or nil,
      messageKey = not (res and res.error) and 'atm.try_again' or nil,
    }
  end
  atm.screen = 'result'
  render()
  -- auto-return to menu
  local token = {}
  atm.resultToken = token
  CreateThread(function()
    Wait(4500)
    if atm and atm.resultToken == token and atm.screen == 'result' then
      atm.screen = 'menu'
      render()
    end
  end)
end

-- minimal money formatter for the DUI result line (UI does its own full formatting)
function formatMoney(n)
  return NN.FormatCurrency(n)
end

-- Run a menu choice (shared by keypad Enter and a mouse click on the item).
local function selectMenu(choice)
  if not atm or atm.screen ~= 'menu' then return end
  if choice == 'exit' then
    CloseAtm()
  elseif choice == 'balance' then
    atm.screen = 'loading'; render()
    CreateThread(function()
      local res = srv('atmBalance')
      if not atm then return end
      if res and res.ok then atm.balance = res.balance; atm.cash = res.cash end
      atm.screen = 'balance'; render()
    end)
  elseif choice == 'history' then
    atm.screen = 'loading'; render()
    CreateThread(function()
      local res = srv('atmHistory')
      if not atm then return end
      if res and res.ok then
        atm.statement = res.transactions or {}
        if res.balance ~= nil then atm.balance = res.balance end
        if res.cash ~= nil then atm.cash = res.cash end
      else
        atm.statement = {}
      end
      atm.screen = 'statement'; render()
    end)
  elseif choice == 'withdraw' or choice == 'deposit' then
    atm.amountMode = choice; atm.amount = ''; atm.screen = 'amount'; render()
  end
end

-- Input from the physical keypad (digits/enter/back/up/down). `key` is '0'..'9' | 'enter' | 'back' | 'up' | 'down'.
local function input(key)
  if not atm then return end
  local screen = atm.screen

  if screen == 'pin' then
    if key:match('%d') then
      if #atm.pin < 4 then atm.pin = atm.pin .. key end
      atm.pinError = nil
      render()
      if #atm.pin == 4 then
        local pin = atm.pin
        atm.screen = 'loading'; render()
        CreateThread(function()
          local res = srv('atmVerify', { pin = pin })
          if not atm then return end
          if res and res.verified then
            atm.pin = ''; atm.menuIndex = 0; atm.screen = 'menu'
          else
            atm.pin = ''
            atm.pinError = res and res.locked and 'atm.locked' or 'atm.wrong_pin'
            atm.screen = 'pin'
          end
          render()
        end)
      end
    elseif key == 'back' then
      atm.pin = atm.pin:sub(1, -2); render()
    end

  elseif screen == 'menu' then
    if key == 'up' then
      atm.menuIndex = (atm.menuIndex - 1) % #MENU; render()
    elseif key == 'down' then
      atm.menuIndex = (atm.menuIndex + 1) % #MENU; render()
    elseif key == 'enter' then
      selectMenu(MENU[atm.menuIndex + 1])
    end

  elseif screen == 'amount' then
    if key:match('%d') then
      if #atm.amount < 9 then atm.amount = (atm.amount == '0' and '' or atm.amount) .. key end
      render()
    elseif key == 'back' then
      if atm.amount == '' then atm.screen = 'menu' else atm.amount = atm.amount:sub(1, -2) end
      render()
    elseif key == 'enter' then
      local amt = tonumber(atm.amount) or 0
      if amt < 1 then return end
      local mode = atm.amountMode
      atm.screen = 'loading'; render()
      CreateThread(function()
        local res = srv(mode == 'deposit' and 'atmDeposit' or 'atmWithdraw', { amount = amt })
        if not atm then return end
        applyMoneyResult(res, mode == 'deposit' and 'atm.deposit_complete' or 'atm.cash_dispensed')
      end)
    end

  elseif screen == 'balance' or screen == 'result' or screen == 'statement' then
    if key == 'enter' or key == 'back' then
      atm.screen = 'menu'; render()
    end
  end
end

-- A button the player clicked in the DUI (the UI hit-tests the cursor and reports the action
-- string). 'menu:<choice>' picks a menu item; 'key:<k>' maps to the keypad input above.
local function handleAction(a)
  if not atm or type(a) ~= 'string' then return end
  local key = a:match('^key:(.+)$')
  if key then input(key); return end -- numpad is always digit/enter/back

  local choice = a:match('^menu:(.+)$')
  if not choice then return end
  local screen = atm.screen
  if screen == 'menu' then
    for i, k in ipairs(MENU) do if k == choice then atm.menuIndex = i - 1 end end
    selectMenu(choice)
  elseif screen == 'amount' then
    -- soft-key: side buttons become Confirm (right) / Cancel (left) on the amount screen.
    if (atm.sideOf and atm.sideOf[a]) == 'right' then
      input('enter') -- Confirm (submit the amount)
    else
      atm.amount = ''; atm.screen = 'menu'; render() -- Cancel
    end
  elseif screen == 'balance' or screen == 'result' or screen == 'statement' then
    atm.screen = 'menu'; render() -- any side button returns to the menu
  end
end

-- Open the ATM on a given prop entity (from proximity E or /atm). `mode` opens a TUNING session
-- with sample data + a focused NUI panel instead of the normal input: 'screen' adjusts
-- the screen rect, while 'buttons' positions the physical buttons.
-- Which Config.Atm.Models prop this entity is, found without GET_ENTITY_MODEL: on a map ATM whose
-- archetype is streaming that native throws inside gta-streaming-five (0x9F47B058362C84B5) even
-- while DoesEntityExist says yes. The closest object of each ATM model at the entity's spot is
-- compared with the entity instead.
local function atmModelName(entity)
  local ok, name = pcall(function()
    local c = GetEntityCoords(entity)
    for _, n in ipairs(Config.Atm.Models or {}) do
      if GetClosestObjectOfType(c.x, c.y, c.z, 0.5, GetHashKey(n), false, false, false) == entity then return n end
    end
  end)
  return ok and name or nil
end

function OpenAtm(entity, mode, filter)
  if atm then return end
  local modelName = entity and entity ~= 0 and DoesEntityExist(entity) and atmModelName(entity)
  if not modelName then
    Bridge.Notify.SendNotification('ATM', 'Yakında ATM yok', 'error', 4000)
    return
  end
  -- CLAIM the session SYNCHRONOUSLY (before the async server calls below). Otherwise `atm`
  -- stays nil while the callbacks are in flight and the proximity loop / a re-press keeps
  -- calling OpenAtm every frame, spawning multiple DUIs + cameras -> "invalid handle" spam.
  atm = { opening = true, entity = entity, screen = 'loading', pin = '', menuIndex = 0, amount = '', mode = mode, buttonFilter = filter }
  lockInventory(true)

  CreateThread(function()
    -- Any failure goes through teardown() (clears `atm`, unwinds cam/tex/DUI, unfreezes the ped)
    -- so the player is NEVER left frozen or with controls disabled.
    local function fail(msg)
      teardown()
      Bridge.Notify.SendNotification('ATM', msg or 'Kullanılamıyor', 'error', 4000)
    end

    -- 1) access + account data (server-authoritative). Tuning modes use sample data (no server).
    local requirePin = false
    if mode then
      atm.holderName, atm.balance, atm.cash = 'Config Preview', 124580, 3420
    else
      local access = srv('atmAccess')
      if not (access and access.ok) then return fail(access and access.error) end
      if not atm then return end
      local data = srv('atmData')
      if not (data and data.ok) then return fail(data and data.error) end
      if not atm then return end
      atm.holderName, atm.balance, atm.cash = data.holderName, data.balance, data.cash
      requirePin = data.requirePin
    end

    -- 2) Create the DUI, then WAIT for it to be available BEFORE building the runtime texture.
    --    Calling CreateRuntimeTextureFromDuiHandle on a not-yet-ready handle is exactly the
    --    `native 0xB135472B: invalid handle` crash. Store the DUI on `atm` immediately so a
    --    later failure tears it down too. (a reference ATM waits the same way.)
    -- Resolve the screen texture slot + the DUI resolution for THIS prop (per-model; from the reference).
    -- The DUI is created at the slot's native resolution so the UI maps onto it 1:1.
    -- The prop can stream out / be deleted while we awaited the server above; a native on a
    -- dead handle throws (the model was already resolved in OpenAtm, see atmModelName).
    if not atm then return end
    if not DoesEntityExist(entity) then return fail('ATM bulunamadı') end
    atm.modelName = modelName
    local model = GetHashKey(modelName)

    -- Physical-button hit zones. buttonDefs holds the editable offsets (used by /atm_adjust buttons);
    -- buttons holds the precomputed world positions used for the live aim/click in normal mode.
    atm.buttonDefs, atm.buttons = {}, {}
    local modelHit = (Config.Atm.ButtonHitByModel or {})[modelName] or {}
    local bhw = tonumber(modelHit.w) or Config.Atm.ButtonHitW or 0.013
    local bhh = tonumber(modelHit.h) or Config.Atm.ButtonHitH or 0.018
    local modelButtons = (Config.Atm.Buttons or {})[modelName] or (Config.Atm.Buttons or {}).default or {}
    for _, b in ipairs(modelButtons) do
      atm.buttonDefs[#atm.buttonDefs + 1] = { action = b.action, x = b.x, y = b.y, z = b.z, hw = b.hw, hh = b.hh }
      atm.buttons[#atm.buttons + 1] = {
        action = b.action,
        world = GetOffsetFromEntityInWorldCoords(entity, b.x, b.y, b.z),
        hw = b.hw or bhw, hh = b.hh or bhh,
      }
    end

    -- Side-button layout for the UI: each menu:* button is a soft-key on the left (x<0) or right
    -- (x>0) edge, ordered top→bottom by height (z). The UI shows each option's label beside its
    -- physical button; `sideOf` lets handleAction tell left/right apart on the amount screen.
    local lefts, rights = {}, {}
    for _, b in ipairs(atm.buttonDefs) do
      local mk = b.action:match('^menu:(.+)$')
      if mk then
        local side = (b.x < 0) and lefts or rights
        side[#side + 1] = { k = mk, z = b.z }
      end
    end
    table.sort(lefts, function(p, q) return p.z > q.z end)
    table.sort(rights, function(p, q) return p.z > q.z end)
    atm.sideOf = {}
    local function sideKeys(list, side)
      local out = {}
      for _, e in ipairs(list) do out[#out + 1] = e.k; atm.sideOf['menu:' .. e.k] = side end
      return out
    end
    atm.sideLayout = { left = sideKeys(lefts, 'left'), right = sideKeys(rights, 'right') }

    -- On-screen position (0..1) of each option label. Defaults hug the left/right edge, spread by
    -- order; Config.Atm.OptionLayout[model] overrides per option. /atm_adjust options tunes them live.
    atm.optionPos = {}
    local optCfg = (Config.Atm.OptionLayout or {})[modelName] or {}
    local function fillPos(list, side)
      local n = #list
      for i, k in ipairs(list) do
        local c = optCfg[k]
        atm.optionPos[k] = c and { x = c.x, y = c.y }
          or { x = (side == 'left') and 0.04 or 0.96, y = (n <= 1) and 0.5 or (0.2 + ((i - 1) / (n - 1)) * 0.6) }
      end
    end
    fillPos(atm.sideLayout.left, 'left')
    fillPos(atm.sideLayout.right, 'right')

    local tex = textureFor(model)
    local duiW = (tex and tex.w) or Config.Atm.DuiSize.w
    local duiH = (tex and tex.h) or Config.Atm.DuiSize.h
    atm.skin = skinFor(model) -- per-ATM DUI look, sent to the UI on the first render

    -- The screen rectangle (UV 0..1) the UI is clipped to. Most props are the full texture; the
    -- fleeca slot is a whole-front emissive, so only a sub-rect is the display (else the UI bleeds
    -- across the whole ATM). /atm_fit overrides it live for tuning.
    local sc = fitOverride or (tex and tex.screen) or { x = 0.0, y = 0.0, w = 1.0, h = 1.0 }
    atm.fit = sc

    -- Pass the surface size + screen rect to the page (DUI viewport units resolve against the game
    -- window, not the texture, so the page lays out in a fixed-pixel box and clips to the rect).
    local url = ('%s?w=%d&h=%d&sx=%s&sy=%s&sw=%s&sh=%s'):format(DUI_URL, duiW, duiH, sc.x, sc.y, sc.w, sc.h)
    local dui = CreateDui(url, duiW, duiH)
    if not dui then return fail('Could not create the ATM display') end
    atm.dui = dui

    local tries = 0
    while atm and not IsDuiAvailable(dui) and tries < 200 do Wait(10); tries = tries + 1 end
    if not atm then return end
    if not IsDuiAvailable(dui) then return fail('ATM display did not load') end
    Wait(150) -- brief settle so the DUI handle is fully valid (mirrors the reference's post-create wait)
    if not atm then return end -- player may have ESC-cancelled during the wait (DUI already gone)

    local handle = GetDuiHandle(dui)
    if not handle or handle == '' then return fail('ATM display handle unavailable') end

    -- 3) Runtime txd + texture from the DUI handle — pcall-guarded so a native error can never
    --    abort this thread and strand the player with controls disabled.
    --    NOTE: CreateRuntimeTextureFromDuiHandle's FIRST arg is the TextureDict HANDLE returned
    --    by CreateRuntimeTxd (a number) — NOT the txd name string. Passing the name is exactly
    --    the `0xB135472B: invalid handle` crash. AddReplaceTexture (step 4) does take the names.
    local txd = CreateRuntimeTxd('nn_atm_txd')
    if not txd then return fail('Could not create the ATM texture dictionary') end
    local okTex = pcall(function()
      CreateRuntimeTextureFromDuiHandle(txd, 'nn_atm_tex', handle)
    end)
    if not okTex or not atm then return fail('Could not build the ATM display texture') end

    -- 4) Replace the prop's screen texture slot (best-effort: a wrong slot just shows nothing).
    if tex then
      pcall(function() AddReplaceTexture(tex.txd, tex.tex, 'nn_atm_txd', 'nn_atm_tex') end)
      atm.tex = tex
    end

    -- 5) Camera (optional) + freeze — only now that the display is live. Mirrors a reference ATM's
    --    createAtmCamera: position via a per-model offset, aim with the point-at offset, FOV 70.
    if Config.Atm.EnableCamera ~= false then
      local c = Config.Atm.Camera
      local off = c.offset
      for name, o in pairs(c.offsets or {}) do
        if GetHashKey(name) == model then off = o; break end
      end
      local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
      pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
      SetCamFov(cam, c.fov)
      local pos = GetOffsetFromEntityInWorldCoords(entity, off.x, off.y, off.z)
      SetCamCoord(cam, pos.x, pos.y, pos.z)
      PointCamAtEntity(cam, entity, c.rot.x, c.rot.y, c.rot.z, true)
      SetCamActive(cam, true)
      RenderScriptCams(true, true, c.transition or 1000, true, true)
      atm.cam = cam
    end
    FreezeEntityPosition(PlayerPedId(), true)

    atm.opening = nil
    if mode == 'screen' then
      -- Screen-rect tuner: show the menu + a focused panel that drives the rect live.
      atm.screen = 'menu'
      render()
      SetNuiFocus(true, true)
      SendNUIMessage({
        action = 'atmConfig',
        data = {
          open = true,
          model = modelName or 'unknown',
          tex = { txd = (tex and tex.txd) or '', tex = (tex and tex.tex) or '', w = duiW, h = duiH },
          screen = { x = sc.x, y = sc.y, w = sc.w, h = sc.h },
        },
      })
    elseif mode == 'buttons' then
      -- Button editor: show the menu + a focused panel that positions the physical buttons; the
      -- client draws a marker per button on the prop (see the loop's 'buttons' branch).
      atm.screen = 'menu'
      atm.buttonSel = 1
      render()
      SetNuiFocus(true, true)
      SendNUIMessage({
        action = 'atmButtonConfig',
        data = {
          open = true,
          model = modelName or 'unknown',
          actions = Config.AtmButtonActions or {},
          buttons = atm.buttonDefs,
          filter = atm.buttonFilter or 'all', -- 'options' = only edit the side buttons (/atm_adjust options)
        },
      })
    elseif mode == 'optpos' then
      -- Option-label positioner: show the menu + a focused panel that drags each on-screen option
      -- label onto its physical button. The option button markers also draw (for reference).
      atm.buttonFilter = 'options'
      atm.screen = 'menu'
      render()
      SetNuiFocus(true, true)
      SendNUIMessage({
        action = 'atmOptionConfig',
        data = {
          open = true,
          model = modelName or 'unknown',
          options = atm.sideLayout, -- { left = keys, right = keys }
          pos = atm.optionPos,
        },
      })
    else
      atm.screen = (requirePin and 'pin') or 'menu'
      render()
      -- Re-send shortly after: the DUI page may attach its 'atm' message listener a tick AFTER it
      -- finishes loading, so the very first state can be dropped — leaving it stuck on "Connecting…".
      -- Re-pushing a few times guarantees the menu/pin screen actually shows.
      CreateThread(function()
        for _ = 1, 5 do
          Wait(150)
          if atm and atm.dui then render() else return end
        end
      end)
    end
  end)
end

local closestAtm

local function openAtmTuner(mode, filter)
  local entity, dist = closestAtm()
  local maxDist = (Config.Atm and Config.Atm.ConfigDistance) or 4.0
  if entity == 0 or dist > maxDist then
    Bridge.Notify.SendNotification('ATM', "Bir ATM'ye yaklaş", 'error', 4000)
    return
  end
  OpenAtm(entity, mode, filter)
end

local function showAtmAdjustMenu()
  lib.registerContext({
    id = 'nn_banking_atm_adjust',
    title = 'ATM ayarı',
    options = {
      {
        title = 'DUI ekranı',
        description = "En yakın ATM'nin ekran alanını ayarla.",
        icon = 'display',
        onSelect = function() openAtmTuner('screen') end,
      },
      {
        title = 'Fiziksel tuşlar',
        description = "En yakın ATM'nin tuş takımı ve yan tuş alanlarını ayarla.",
        icon = 'keyboard',
        onSelect = function() openAtmTuner('buttons') end,
      },
      {
        title = 'Seçenek etiketleri',
        description = 'DUI menü etiketlerini fiziksel yan tuşlarla hizala.',
        icon = 'list',
        onSelect = function() openAtmTuner('optpos') end,
      },
    },
  })
  lib.showContext('nn_banking_atm_adjust')
end

RegisterNetEvent('nn_banking:client:atmAdjust', function(mode, filter)
  if atm then
    Bridge.Notify.SendNotification('ATM', 'Önce mevcut ATM oturumunu kapat', 'error', 4000)
    return
  end
  if mode == 'screen' then
    openAtmTuner('screen')
  elseif mode == 'buttons' then
    openAtmTuner('buttons', filter)
  elseif mode == 'options' then
    openAtmTuner('optpos')
  else
    showAtmAdjustMenu()
  end
end)

TriggerEvent('chat:addSuggestion', '/atm_adjust', 'Admin: adjust the nearest ATM DUI and physical buttons', {
  { name = 'mode', help = 'Optional: screen, buttons, or options' },
  { name = 'filter', help = 'Optional physical-button action filter' },
})

-- Controls disabled while using the ATM (movement, weapons, pause) — the reference's set. NOT cursor
-- (239/240) or attack (24), which we read for the mouse interaction below.
local ATM_DISABLE = {
  21, 22, 23, 24, 25, 36, 37, 44, 47, 69, 70, 75, 92, 114, 140, 141, 142, 143, 157, 158,
  160, 164, 165, 172, 173, 174, 175, 199, 200, 202, 245, 257, 263, 264, 322, 331,
}

-- Project a button offset to screen. Returns onScreen, screenX, screenY (0..1).
local function projectButton(def)
  local w = GetOffsetFromEntityInWorldCoords(atm.entity, def.x, def.y, def.z)
  return GetScreenCoordFromWorldCoord(w.x, w.y, w.z)
end

local function suppressPause()
  DisableControlAction(0, 199, true)
  DisableControlAction(0, 200, true)
  DisableControlAction(0, 322, true)
end

-- Button-editor overlay: draw a marker + label at every button (the selected one highlighted).
local function drawButtonMarkers()
  if not atm or not atm.buttonDefs then return end
  local optionsOnly = atm.buttonFilter == 'options'
  for i, b in ipairs(atm.buttonDefs) do
    -- /atm_adjust options only draws/edits the menu side buttons; skip the numpad.
    if not (optionsOnly and not b.action:find('^menu:')) then
      local on, sx, sy = projectButton(b)
      if on then
        local sel = (i == atm.buttonSel)
        DrawRect(sx, sy, 0.013, 0.019, sel and 240 or 40, sel and 220 or 200, sel and 60 or 240, sel and 235 or 140)
        SetTextFont(4); SetTextScale(0.27, 0.27); SetTextColour(255, 255, 255, 255)
        SetTextEntry('STRING'); AddTextComponentString((b.action:gsub('key:', ''):gsub('menu:', '')))
        DrawText(sx - 0.012, sy - 0.013)
      end
    end
  end
end

-- Main loop. Normal mode = aim the cursor at the prop's physical buttons and click (the on-screen
-- UI is display-only). Tuning modes suspend that and let the focused NUI panel drive instead.
CreateThread(function()
  while true do
    if not atm or atm.opening then
      Wait(atm and 0 or 200)
    elseif atm.mode == 'buttons' or atm.mode == 'optpos' then
      suppressPause()
      drawButtonMarkers() -- show the option/button markers for reference while positioning
      Wait(0)
    elseif atm.mode then
      suppressPause() -- 'screen' tuner: the panel owns focus + its own Esc
      Wait(0)
    else
      for i = 1, #ATM_DISABLE do DisableControlAction(0, ATM_DISABLE[i], true) end
      SetMouseCursorActiveThisFrame()

      -- Which physical button is the cursor over? (projected point within the button's hit box)
      local cx, cy = GetControlNormal(0, 239), GetControlNormal(0, 240)
      local hovered, hoverScore
      for _, b in ipairs(atm.buttons or {}) do
        local on, sx, sy = GetScreenCoordFromWorldCoord(b.world.x, b.world.y, b.world.z)
        if on then
          local dx, dy = math.abs(cx - sx), math.abs(cy - sy)
          if dx <= b.hw and dy <= b.hh then
            local score = (dx / b.hw) ^ 2 + (dy / b.hh) ^ 2
            if not hoverScore or score < hoverScore then hovered, hoverScore = b, score end
          end
        end
      end
      SetMouseCursorSprite(hovered and 5 or 1) -- hand over a button, arrow otherwise

      -- Tell the display which option is hovered so it can highlight it.
      local hoverAction = hovered and hovered.action or nil
      if hoverAction ~= atm.lastHover then
        atm.lastHover = hoverAction
        if atm.dui then
          SendDuiMessage(atm.dui, json.encode({ action = 'atmHover', data = { action = hoverAction } }))
        end
      end

      if IsDisabledControlJustPressed(0, 200) or IsDisabledControlJustPressed(0, 202) then
        CloseAtm() -- ESC / Cancel
      elseif hovered and (IsDisabledControlJustPressed(0, 24) or IsControlJustPressed(0, 24)
          or IsDisabledControlJustPressed(0, 237) or IsControlJustPressed(0, 237)) then
        handleAction(hovered.action)
      end
      Wait(0)
    end
  end
end)

-- Closest ATM prop to the player (target-free — scan by model, NO target system involved).
-- Returns (entity, distance).
closestAtm = function()
  local pc = GetEntityCoords(PlayerPedId())
  local best, bestDist = 0, math.huge
  for _, name in ipairs(Config.Atm.Models) do
    local obj = GetClosestObjectOfType(pc.x, pc.y, pc.z, 3.5, GetHashKey(name), false, false, false)
    if obj ~= 0 and DoesEntityExist(obj) then
      local d = #(pc - GetEntityCoords(obj))
      if d < bestDist then best, bestDist = obj, d end
    end
  end
  return best, bestDist
end

-- The DUI reports a clicked button here (its own hit-test resolves which one). We route it
-- through the same logic as the keypad. Works from the DUI via fetch to this resource.
RegisterNUICallback('atm:action', function(data, cb)
  handleAction(data and data.action)
  cb('ok')
end)

-- The option-label editor streams positions here → push to the DUI so labels move live + keep state.
RegisterNUICallback('atmOptionSet', function(data, cb)
  if atm and atm.dui and data and type(data.pos) == 'table' then
    local pos = {}
    for k, p in pairs(data.pos) do pos[k] = { x = tonumber(p.x) or 0.5, y = tonumber(p.y) or 0.5 } end
    atm.optionPos = pos
    SendDuiMessage(atm.dui, json.encode({ action = 'atmOption', data = pos }))
  end
  cb('ok')
end)

-- Print the option-label layout to the F8 console for Config.Atm.OptionLayout.
RegisterNUICallback('atmOptionPrint', function(data, cb)
  if data and type(data.pos) == 'table' then
    print('^2[nn_banking]^0 ===== ATM option labels — paste into Config.Atm.OptionLayout =====')
    print(("    ['%s'] = {"):format((atm and atm.modelName) or 'prop_xxx'))
    for k, p in pairs(data.pos) do
      print(("      %s = { x = %.3f, y = %.3f },"):format(k, tonumber(p.x) or 0.5, tonumber(p.y) or 0.5))
    end
    print('    },')
    print('^2[nn_banking]^0 ============================================================')
  end
  cb('ok')
end)

RegisterNUICallback('atmOptionClose', function(_, cb)
  if atm and atm.mode == 'optpos' then CloseAtm() end
  cb('ok')
end)

-- The button editor owns the full list; it syncs the whole thing here on every change so the
-- on-prop markers stay current (`sel` is the 1-based selected index, highlighted brighter).
RegisterNUICallback('atmButtonSync', function(data, cb)
  if atm and data and type(data.buttons) == 'table' then
    local defs = {}
    for _, b in ipairs(data.buttons) do
      defs[#defs + 1] = { action = b.action, x = tonumber(b.x) or 0.0, y = tonumber(b.y) or 0.0, z = tonumber(b.z) or 1.0 }
    end
    atm.buttonDefs = defs
    atm.buttonSel = tonumber(data.sel) or atm.buttonSel
  end
  cb('ok')
end)

-- Print the finished button block to the F8 console so it can be pasted into Config.Atm.Buttons.
RegisterNUICallback('atmButtonPrint', function(_, cb)
  if atm and atm.buttonDefs then
    print('^2[nn_banking]^0 ===== ATM buttons — paste into Config.Atm.Buttons =====')
    print(("    ['%s'] = {"):format(atm.modelName or 'prop_xxx'))
    for _, b in ipairs(atm.buttonDefs) do
      print(("      { action = '%s', x = %.3f, y = %.3f, z = %.3f },"):format(b.action, b.x, b.y, b.z))
    end
    print('    },')
    print('^2[nn_banking]^0 ========================================================')
  end
  cb('ok')
end)

-- Editor asked to close.
RegisterNUICallback('atmButtonClose', function(_, cb)
  if atm and atm.mode == 'buttons' then CloseAtm() end
  cb('ok')
end)

-- The config panel streams the live screen rect here → push it to the DUI so the on-prop UI
-- repositions in real time, and keep atm.fit in sync.
RegisterNUICallback('atmConfigSet', function(data, cb)
  if atm and atm.dui and data then
    local sx, sy = tonumber(data.sx) or 0.0, tonumber(data.sy) or 0.0
    local sw, sh = tonumber(data.sw) or 1.0, tonumber(data.sh) or 1.0
    atm.fit = { x = sx, y = sy, w = sw, h = sh }
    SendDuiMessage(atm.dui, json.encode({ action = 'atmFit', data = { sx = sx, sy = sy, sw = sw, sh = sh } }))
  end
  cb('ok')
end)

-- Print the finished config line to the F8 console so it can be copied into Config.Atm.Textures.
RegisterNUICallback('atmConfigPrint', function(data, cb)
  if data then
    local t = (atm and atm.tex) or {}
    local name = (atm and atm.modelName) or 'prop_xxx'
    print('^2[nn_banking]^0 ===== ATM screen config — paste into Config.Atm.Textures =====')
    print(("    ['%s'] = { txd = '%s', tex = '%s', w = %d, h = %d, screen = { x = %.3f, y = %.3f, w = %.3f, h = %.3f } },"):format(
      name, t.txd or name, t.tex or '?', t.w or 512, t.h or 512,
      tonumber(data.sx) or 0.0, tonumber(data.sy) or 0.0, tonumber(data.sw) or 1.0, tonumber(data.sh) or 1.0))
    print('^2[nn_banking]^0 ===========================================================')
  end
  cb('ok')
end)

-- Panel asked to close — tear the tuning session down (releases focus via teardown).
RegisterNUICallback('atmConfigClose', function(_, cb)
  if atm and atm.mode == 'screen' then CloseAtm() end
  cb('ok')
end)

-- Proximity interaction (target-free, no target dependency — works regardless of ox_target).
-- When on foot near an ATM, show the prompt and open the DUI on E. Cheap when away from ATMs.
AddTextEntry('nnAtmHelp', NN.Translate('world.atm_help'))

local qbTargetModels
local qbTargetLabel

CreateThread(function()
  local provider = NN.TargetProvider()
  if provider == 'ox_target' then
    local models = {}
    for _, name in ipairs(Config.Atm.Models or {}) do models[#models + 1] = name end
    exports.ox_target:addModel(models, {
      {
        name = 'nn_atm_use',
        label = NN.Translate('world.atm_target'),
        icon = 'fa-solid fa-money-bill-transfer',
        distance = 1.8,
        onSelect = function(data) OpenAtm(data.entity) end,
      },
      {
        name = 'nn_atm_pinreset',
        label = 'Şifremi unuttum',
        icon = 'fa-solid fa-key',
        distance = 1.8,
        onSelect = function() NN.PinResetFlow() end,
      },
    })
    return
  elseif provider == 'qb-target' then
    qbTargetModels = {}
    qbTargetLabel = NN.Translate('world.atm_target')
    for _, name in ipairs(Config.Atm.Models or {}) do qbTargetModels[#qbTargetModels + 1] = name end
    exports['qb-target']:AddTargetModel(qbTargetModels, {
      options = {
        {
          icon = 'fa-solid fa-money-bill-transfer',
          label = qbTargetLabel,
          action = function(entity) OpenAtm(entity) end,
        },
        {
          icon = 'fa-solid fa-key',
          label = 'Şifremi unuttum',
          action = function() NN.PinResetFlow() end,
        },
      },
      distance = 1.8,
    })
    return
  end

  -- Fallback: proximity prompt (no target dependency).
  local promptDist = (Config.Atm and Config.Atm.PromptDistance) or 1.6
  while true do
    local wait = 500
    if not atm and not IsPedInAnyVehicle(PlayerPedId(), false) then
      local entity, dist = closestAtm()
      if entity ~= 0 and dist <= promptDist then
        wait = 0
        BeginTextCommandDisplayHelp('nnAtmHelp')
        EndTextCommandDisplayHelp(0, false, false, -1)
        if IsControlJustReleased(0, 38) then -- E (INPUT_CONTEXT)
          OpenAtm(entity)
        end
      end
    end
    Wait(wait)
  end
end)

AddEventHandler('onResourceStop', function(res)
  if res ~= GetCurrentResourceName() then return end
  teardown()
  if qbTargetModels and GetResourceState('qb-target') == 'started' then
    pcall(function() exports['qb-target']:RemoveTargetModel(qbTargetModels, { qbTargetLabel, 'Şifremi unuttum' }) end)
  end
end)

-- Keypad bindings LAST + pcall-guarded: RegisterKeyMapping can error on some builds, and that
-- must NOT abort the proximity/open logic registered above. (Called synchronously at load —
-- RegisterKeyMapping requires the first tick, so no Wait before this.)
local function bind(name, label, key, fn)
  pcall(function() RegisterKeyMapping(name, label, 'keyboard', key) end)
  RegisterCommand(name, function() if atm then fn() end end, false)
end
for i = 0, 9 do
  local digit = tostring(i)
  local label = NN.Translate('world.atm_key', { key = i })
  local handler = function() input(digit) end
  bind('nnatm_' .. digit, label, 'NUMPAD' .. digit, handler)
  bind('nnatm_top_' .. digit, label .. ' (top row)', digit, handler)
end
bind('nnatm_enter', NN.Translate('world.atm_confirm'), 'RETURN', function() input('enter') end)
bind('nnatm_back', NN.Translate('world.atm_back'), 'BACK', function() input('back') end)
bind('nnatm_up', NN.Translate('world.atm_up'), 'UP', function() input('up') end)
bind('nnatm_down', NN.Translate('world.atm_down'), 'DOWN', function() input('down') end)
