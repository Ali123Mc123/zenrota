-- ============================================================================
--  Phone-app bridge (Phase 3)
--  Registers the NN Bank mobile UI (web/build/phone.html) as an app inside any
--  supported phone resource that's running. Each phone ships a different custom-app
--  API, so we keep one small adapter per phone and call whichever match the phones
--  actually started on the server. Every adapter is pcall-guarded, so a phone whose
--  API differs by version simply logs and is skipped — it never breaks the others.
--
--  Adding a new phone: add its resource name to Config.Phone.Phones and a matching
--  entry in `Adapters` below (register = function(app) ... end). `app` gives you the
--  name, description and the cfx-nui:// URLs to the page + icon.
-- ============================================================================

if not (Config.Phone and Config.Phone.Enabled) then return end

local resourceName = GetCurrentResourceName()

--- Absolute cfx-nui URL for a file inside this resource (what phones load in their iframe).
---@param path string
local function nui(path)
  return ('https://cfx-nui-%s/%s'):format(resourceName, path)
end

-- Shared descriptor handed to every adapter.
local APP = {
  id          = 'nnbank',
  name        = Config.Phone.AppName or 'NN Bank',
  description = Config.Phone.AppDescription or 'Banking',
  page        = nui(Config.Phone.Page or 'web/build/phone.html'),
  icon        = nui(Config.Phone.Icon or 'web/icon.png'),
  iconNui     = ('nui://%s/%s'):format(resourceName, Config.Phone.Icon or 'web/icon.png'),
  color       = (Config.Brand and Config.Brand.Color) or '#ABE23E',
}

--- Run an adapter safely; one phone's broken/changed API can't take down the rest.
local function safe(label, fn)
  local ok, err = pcall(fn, APP)
  if ok then
    debugPrint(('phone: registered with ^2%s^0'):format(label))
  else
    print(('[%s] phone: ^3%s^0 not registered — %s'):format(resourceName, label, err))
  end
end

-- ============================================================================
--  Per-phone adapters. Key = resource name (must match Config.Phone.Phones).
-- ============================================================================
local Adapters = {}

-- 17 Movement Phone ---------------------------------------------------------
Adapters['17mov_Phone'] = function(app)
  exports['17mov_Phone']:AddApplication({
    name           = app.id,
    label          = app.name,
    ui             = app.page,
    icon           = app.icon,
    iconBackground = app.color,
    default        = false,
    preInstalled   = false,
    resourceName   = resourceName,
    rating         = 5.0,
  })
end

-- LB Phone — the best-documented custom-app API. Loads `ui` in an iframe. ------
Adapters['lb-phone'] = function(app)
  exports['lb-phone']:AddCustomApp({
    identifier  = app.id,
    name        = app.name,
    description = app.description,
    defaultApp  = false,      -- appears in the app drawer, not pre-installed on home
    size        = 60000,
    ui          = app.page,
    icon        = app.icon,
    -- price = 0, -- uncomment if you want it to cost in-app currency to install
  })
end

-- Quasar smartphone (qs-smartphone) ------------------------------------------
Adapters['qs-smartphone'] = function(app)
  local added = exports['qs-smartphone']:addCustomApp({
    id     = app.id,
    label  = app.name,
    icon   = app.icon,
    iframe = {
      url = app.page,
    },
  })
  if added == false then error('qs-smartphone rejected the custom app') end
end

Adapters['qs-smartphone-pro'] = function(app)
  local added = exports['qs-smartphone-pro']:addCustomApp({
    app              = app.id,
    image            = app.icon,
    ui               = app.page,
    label            = app.name,
    job              = false,
    blockedJobs      = {},
    timeout          = 5000,
    creator          = 'NANO Scripts',
    category         = 'finance',
    isGame           = false,
    description      = app.description,
    age              = '4+',
    extraDescription = {},
  })
  if added == false then error('qs-smartphone-pro rejected the custom app') end
end

-- gksphone -------------------------------------------------------------------
Adapters['gksphone'] = function(app)
  exports['gksphone']:AddApps({
    {
      app    = app.id,
      label  = app.name,
      icon   = app.icon,
      url    = app.page,
      custom = true,
    },
  })
end

-- qb-phone -------------------------------------------------------------------
-- Stock qb-phone has no add-app export (apps live in qb-phone/config.lua). This
-- targets the common community fork export; on stock qb-phone it errors and is
-- skipped — add NN Bank to qb-phone's Config.Apps pointing at app.page instead.
Adapters['qb-phone'] = function(app)
  exports['qb-phone']:AddNewApp({
    app         = app.id,
    name        = app.name,
    description = app.description,
    icon        = app.icon,
    url         = app.page,
    color       = app.color,
  })
end

-- high-phone -----------------------------------------------------------------
Adapters['high-phone'] = function(app)
  exports['high-phone']:AddCustomApp({
    id   = app.id,
    name = app.name,
    icon = app.icon,
    url  = app.page,
  })
end

-- roadphone ------------------------------------------------------------------
Adapters['roadphone'] = function(app)
  exports['roadphone']:addCustomApp(app.id, {
    name = app.name,
    icon = app.icon,
    url  = app.page,
  })
end

-- "Six phone" (sixphone) -----------------------------------------------------
Adapters['sixphone'] = function(app)
  exports['sixphone']:AddCustomApp({
    identifier = app.id,
    name       = app.name,
    icon       = app.icon,
    ui         = app.page,
  })
end

-- "Kazer phone" (kazer-phone) ------------------------------------------------
Adapters['kazer-phone'] = function(app)
  exports['kazer-phone']:AddCustomApp({
    id   = app.id,
    name = app.name,
    icon = app.icon,
    url  = app.page,
  })
end

-- iPhone-style: inferno-os / yflip-phone (share a similar AddApp shape) -------
local function infernoStyle(app)
  local phone = exports['inferno-os'] and 'inferno-os' or 'yflip-phone'
  exports[phone]:AddCustomApp({
    identifier  = app.id,
    name        = app.name,
    description = app.description,
    icon        = app.icon,
    ui          = app.page,
  })
end
Adapters['inferno-os']  = infernoStyle
Adapters['yflip-phone'] = infernoStyle

-- CodeM mPhone 2.0 ---------------------------------------------------------
-- CodeM expects raw HTML. Keep Banking's own NUI as a nested frame so its existing
-- callbacks continue targeting nn_banking, then forward phone lifecycle messages.
Adapters['codem-phone'] = function(app)
  local wrapper = ([=[<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>html,body,#nnbank{width:100%%;height:100%%;margin:0;border:0;overflow:hidden;background:transparent}</style></head><body><iframe id="nnbank" src="%s" allow="clipboard-read; clipboard-write"></iframe><script>const frame=document.getElementById('nnbank');addEventListener('message',event=>{if(event.source===parent){frame.contentWindow.postMessage(event.data,'*')}else if(event.source===frame.contentWindow){parent.postMessage(event.data,'*')}});</script></body></html>]=]):format(app.page)
  local added, err = exports['codem-phone']:AddCustomApp({
    identifier  = app.id,
    name        = app.name,
    description = app.description,
    ui          = wrapper,
    icon        = app.iconNui,
    defaultApp  = false,
    notification = true,
    addAppStore = false,
    developer   = 'NANO Scripts',
  })
  if added ~= true then error(err or 'codem-phone rejected the custom app') end
end

-- ============================================================================
--  Detection + registration
-- ============================================================================

--- Register with every enabled phone that's currently started.
local function registerAll()
  for res, enabled in pairs(Config.Phone.Phones) do
    if enabled and Adapters[res] and GetResourceState(res) == 'started' then
      safe(res, Adapters[res])
    end
  end
end

-- Initial sweep once everything has settled (phones export after their own init).
CreateThread(function()
  Wait(1500)
  registerAll()
end)

-- If a phone starts (or restarts) after us, register with just that one.
AddEventHandler('onClientResourceStart', function(res)
  if Config.Phone.Phones[res] and Adapters[res] then
    Wait(1000) -- let the phone finish booting before we call its export
    if GetResourceState(res) == 'started' then
      safe(res, Adapters[res])
    end
  end
end)

RegisterNetEvent('codem-phone:phoneLoaded', function()
  if Config.Phone.Phones['codem-phone'] and GetResourceState('codem-phone') == 'started' then
    CreateThread(function()
      Wait(500)
      if GetResourceState('codem-phone') == 'started' then
        safe('codem-phone', Adapters['codem-phone'])
      end
    end)
  end
end)
