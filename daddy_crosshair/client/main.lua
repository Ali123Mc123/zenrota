CrosshairSettings = lib.table.deepclone(Settings.Defaults)
Profiles = Settings.SanitizeProfiles(nil)

local colorById = {}
for _, color in ipairs(Settings.Colors) do colorById[color.id] = color.hex end

local groupSetting = {}
for key, groups in pairs(Settings.WeaponGroups) do
    for _, group in ipairs(groups) do groupSetting[group] = key end
end

local unarmed = `WEAPON_UNARMED`
local meleeGroup = `GROUP_MELEE`
local sniperGroup = `GROUP_SNIPER`
local menuOpen = false
local shown = nil
local lookIndex = nil
local loaded = not Settings.ServerSync

function Send(action, data)
    SendNUIMessage({ action = action, data = data })
end

function ColorRGB(id)
    local hex = type(id) == 'string' and id:match('^#%x%x%x%x%x%x$') and id or colorById[id] or '#ffffff'
    return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
end

function IsArmed(ped)
    local weapon = GetSelectedPedWeapon(ped)
    return weapon ~= unarmed and GetWeapontypeGroup(weapon) ~= meleeGroup, weapon
end

-- Profile that applies right now: the one picked in the menu, unless the weapon in hand has its own slot.
local function EffectiveProfile(weapon)
    local s = CrosshairSettings
    if not s.autoSwitch then return s.activeProfile end
    local key = groupSetting[GetWeapontypeGroup(weapon)]
    local slot = key and s[key] or 0
    return slot > 0 and slot or s.activeProfile
end

function CurrentLook()
    return Profiles[lookIndex or CrosshairSettings.activeProfile]
end

local function PushLook(force)
    local index = EffectiveProfile(GetSelectedPedWeapon(cache.ped))
    if not force and index == lookIndex then return end
    lookIndex = index
    Send('look', Profiles[index])
end

-- The profile list is the source of truth for the look; mirror the active one back into the flat settings.
local function SyncActiveLook()
    local look = Profiles[CrosshairSettings.activeProfile]
    for _, key in ipairs(Settings.LookKeys) do CrosshairSettings[key] = look[key] end
end

local function Apply(blob)
    if type(blob) ~= 'table' then return end
    local legacy = blob.settings == nil
    for key, value in pairs(Settings.Sanitize(legacy and blob or blob.settings)) do CrosshairSettings[key] = value end
    if legacy then
        Profiles = Settings.SanitizeProfiles(nil)
        Profiles[CrosshairSettings.activeProfile] = Settings.SanitizeLook(CrosshairSettings)
    else
        Profiles = Settings.SanitizeProfiles(blob.profiles)
    end
    SyncActiveLook()
end

local function State()
    return { settings = CrosshairSettings, profiles = Profiles }
end

local function Load()
    local saved = GetResourceKvpString(Settings.SaveKey) or GetResourceKvpString(Settings.LegacySaveKey)
    Apply(saved and json.decode(saved))
end

Load()

CreateThread(function()
    if not Settings.ServerSync then return end
    while not NetworkIsSessionStarted() do Wait(250) end
    local ok, remote = pcall(lib.callback.await, 'daddy_crosshair:load', false)
    if ok and type(remote) == 'string' then
        Apply(json.decode(remote))
        SetResourceKvp(Settings.SaveKey, json.encode(State()))
        lookIndex = nil
        Send('sync', State())
    end
    loaded = true
end)

local function Visible(ped)
    local s = CrosshairSettings
    if not s.enabled or menuOpen or IsPauseMenuActive() or IsEntityDead(ped) then return false end
    if s.hideInVehicle and IsPedInAnyVehicle(ped, false) then return false end
    local armed, weapon = IsArmed(ped)
    local aiming = IsPlayerFreeAiming(PlayerId())
    if s.hideOnSniper and aiming and GetWeapontypeGroup(weapon) == sniperGroup then return false end
    if s.show == 'armed' then return armed end
    if s.show == 'aim' then return armed and aiming end
    return true
end


CreateThread(function()
    -- The game reticle (HUD 14) is already hidden every frame by qbx_hudcomponents,
    -- so this loop only needs to check visibility now and then.
    while true do
        local visible = Visible(cache.ped)
        if shown ~= visible then
            shown = visible
            Send('visible', visible)
        end
        if not menuOpen then PushLook(false) end
        Wait(50)
    end
end)

local function OpenMenu()
    if menuOpen then return end
    menuOpen = true
    SetNuiFocus(true, true)
    Send('open', State())
end

RegisterNUICallback('uiReady', function(_, cb)
    local waited = 0
    while not loaded and waited < 3000 do
        Wait(50)
        waited = waited + 50
    end
    local ui
    if Settings.Locale == 'auto' then
        ui = Daddy.Locale.UI()
    else
        local file = LoadResourceFile(GetCurrentResourceName(), ('locales/%s.json'):format(Settings.Locale)) or LoadResourceFile(GetCurrentResourceName(), 'locales/en.json')
        local locale = file and json.decode(file) or {}
        ui = locale.ui or {}
    end
    cb({
        locale = ui,
        settings = CrosshairSettings,
        profiles = Profiles,
        defaults = Settings.Defaults,
        options = Settings.Options,
        colors = Settings.Colors,
        colorKeys = Settings.ColorKeys,
        lookKeys = Settings.LookKeys,
        metaKeys = Settings.MetaKeys,
        menu = Settings.Menu,
        presets = Settings.Presets,
    })
    shown = nil
    lookIndex = nil
end)

RegisterNUICallback('save', function(data, cb)
    cb(true)
    if type(data) ~= 'table' then return end
    Apply(data)
    local state = State()
    SetResourceKvp(Settings.SaveKey, json.encode(state))
    if Settings.ServerSync then TriggerServerEvent('daddy_crosshair:save', json.encode(state)) end
end)

RegisterNUICallback('close', function(_, cb)
    cb(true)
    menuOpen = false
    shown = nil
    SetNuiFocus(false, false)
    PushLook(true)
end)

RegisterCommand(Settings.OpenCommand, OpenMenu, false)
RegisterKeyMapping(Settings.OpenCommand, locale('keybind'), 'keyboard', Settings.OpenKey)

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() and menuOpen then SetNuiFocus(false, false) end
end)
