----              _  _     _  _     _  _     _  _     _  _     _  _     _  _     _  _
----            _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_
----            _  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|
----           |_      _|_      _|_      _|_      _|_      _|_      _|_      _|_      _|
----             |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|
----
----
----                  ___       _               ____         __ _
----                 / _ \__  _| |_   _ _ __   / ___|  ___  / _| |___      ____ _ _ __ ___
----                | | | \ \/ / | | | | '_ \  \___ \ / _ \| |_| __\ \ /\ / / _` | '__/ _ \
----                | |_| |>  <| | |_| | | | |  ___) | (_) |  _| |_ \ V  V / (_| | | |  __/
----                 \___//_/\_\_|\__, |_| |_| |____/ \___/|_|  \__| \_/\_/ \__,_|_|  \___|
----                              |___/
----
----                                   OXLYN SOFTWARE | BACKPACK ESX/QBCORE/QBOX
----
----               Thank you for purchasing our script; we greatly appreciate your preference.
----        If you have any questions or any modifications in mind, please contact us via Discord.
----
----                           Support and More: https://discord.gg/Jskkg4h54r
----
----              _  _     _  _     _  _     _  _     _  _     _  _     _  _     _  _
----            _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_ _| || |_
----            _  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|_  ..  _|
----           |_      _|_      _|_      _|_      _|_      _|_      _|_      _|_      _|
----             |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|   |_||_|
----

-- =============================================================================
--  ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗
-- ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝
-- ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
-- ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
-- ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
--  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝
-- =============================================================================
--
--  CONFIGURATION FILE — config/config.lua
--  Edit this file to configure Oxlyn Backpack for your server.
--
--  ┌─────────────────────────────────────────────────────────────┐
--  │  OPEN-SOURCE FILES YOU CAN EDIT FREELY                     │
--  │  ─────────────────────────────────────────────────────────  │
--  │  config/config.lua      ← YOU ARE HERE (main config)       │
--  │  open/bridge_client.lua ← custom inventory bridge (client) │
--  │  open/bridge_server.lua ← custom inventory bridge (server) │
--  │  open/zones.lua         ← targeting / drawtext zones       │
--  │  open/logging.lua       ← Discord / custom logging         │
--  └─────────────────────────────────────────────────────────────┘
--
-- =============================================================================

Config = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. FRAMEWORK  (auto-detected — override only if detection is wrong)
-- ─────────────────────────────────────────────────────────────────────────────
if GetResourceState('qbx_core') == 'started' then
    Config.Framework = 'qbox'
elseif GetResourceState('qb-core') == 'started' then
    Config.Framework = 'qbcore'
elseif GetResourceState('es_extended') == 'started' then
    local _ver   = GetResourceMetadata('es_extended', 'version', 0) or '0.0.0'
    local _major, _minor = _ver:match('(%d+)%.(%d+)')
    if tonumber(_major) == 1 and tonumber(_minor or 99) < 7 then
        Config.Framework = 'oldesx'
    else
        Config.Framework = 'esx'
    end
else
    Config.Framework = 'esx'  -- fallback
end
-- To override: uncomment and set below (detection runs first, this wins if placed after)
-- Config.Framework = 'qbcore'


-- Debug mode — when true, prints verbose info logs to the server/client console.
-- Warnings, errors and security alerts always print regardless of this setting.
Config.Debug = true


-- ─────────────────────────────────────────────────────────────────────────────
-- 2. INVENTORY BRIDGE
--    If you use community_bridge keep true.
--    If false → fill in open/bridge_client.lua and open/bridge_server.lua
-- ─────────────────────────────────────────────────────────────────────────────
Config.UseCommunityBridge = false

-- Inventory update event is auto-detected in editable/bridge_client.lua.
-- Override only if wrong event is picked — set it there directly.


-- ─────────────────────────────────────────────────────────────────────────────
-- 3. INTERACTION ZONES
--    How shop and locker zones are created.
-- ─────────────────────────────────────────────────────────────────────────────
Config.TargetSystem = 'ox_target'
-- Options:
--   'ox_target'  → ox_target sphere zones  (requires ox_target)
--   'qtarget'    → qtarget circle zones    (requires qtarget)
--   'qb-target'  → qb-target circle zones  (requires qb-target)
--   'drawtext'   → proximity + draw-text hint (no extra resource needed)

-- DrawText system — only used when TargetSystem = 'drawtext'
Config.DrawTextSystem = 'ox_lib'
-- Options:
--   'ox_lib'    → lib.showTextUI / lib.hideTextUI
--   'qb-core'   → exports['qb-core']:DrawText / HideText
--   'custom'    → define _G.OxlynShowText(label) and _G.OxlynHideText() yourself

Config.DrawTextOptions = {
    position      = 'right-center', -- 'right-center'|'left-center'|'top-center'|'bottom-center'
    icon          = 'hand',
    iconColor     = nil,             -- e.g. '#ffffff'
    iconAnimation = nil,             -- 'spin'|'pulse'|'beat'|'bounce'|'shake'|etc.
    alignIcon     = 'center',        -- 'top'|'center'
}


-- ─────────────────────────────────────────────────────────────────────────────
-- 4. GENERAL FEATURES
-- ─────────────────────────────────────────────────────────────────────────────

-- Enable the PIN / padlock security system.
-- When false: backpacks open freely (no PIN prompts, no padlock support).
Config.UsePINSystem = true

-- Limit each player to one backpack at a time.
-- Requires ox_inventory OR origen_inventory to be running.
Config.OneBagOnly = false

-- Enable/disable the backpack shop.
Config.EnableShop = true

-- Enable/disable the police search feature.
Config.EnablePoliceSearch = true

-- Enable/disable the storage locker feature.
Config.EnableStorageLockers = true

-- Enable/disable the passcode-reset NPC feature.
-- Player visits an NPC to reset their backpack PIN. Requires the backpack in
-- inventory, and only the player who set the original PIN can reset it.
Config.EnablePasscodeReset = false

-- ─────────────────────────────────────────────────────────────────────────────
--  BACKPACK VISUAL ON BACK
--    Controls whether the backpack is shown on the player's back (clothing
--    component / prop). Turning the visual OFF does NOT affect storage — the
--    item keeps working as a fully functional backpack from the inventory
--    (open, store, locker, police-search via command, etc. all unaffected).
-- ─────────────────────────────────────────────────────────────────────────────

-- Master switch (server-wide).
--   true  → backpacks are worn on the back (default behaviour).
--   false → backpacks are NEVER shown on anyone's back. The item still works
--           normally as inventory storage.
Config.ShowBackpackOnBack = true

-- Let each player toggle the visual on THEIR OWN character with a command.
-- The choice is saved locally (KVP) and persists across reconnects / restarts.
-- Has no effect while Config.ShowBackpackOnBack = false (nothing to show).
Config.AllowPlayerToggleVisual = true

-- Chat command a player uses to toggle their own backpack visual (no leading /).
Config.ToggleVisualCommand = 'backpackvisual'

-- Padlock item — drag into backpack to activate PIN protection.
-- Set to false to disable the padlock item mechanic entirely.
-- NOTE: add 'backpack_padlock' to your inventory system's items list.
-- PIN padlock — drag into backpack stash to lock with a PIN.
-- Stays physically inside the stash; removing it clears the lock.
-- NOTE: add 'backpack_padlock' to your inventory system's items list.
Config.PadlockItem  = 'backpack_padlock'
Config.PadlockPrice = 500

-- Fingerprint padlock — drag into backpack stash to lock by identity.
-- Only the player who set it up can open the backpack (no PIN, no override).
-- Cannot change owner — only removing the padlock from the stash clears the lock.
-- NOTE: add 'backpack_fingerprint_padlock' to your inventory system's items list.
Config.FingerprintPadlockItem  = 'backpack_fingerprint_padlock'
Config.FingerprintPadlockPrice = 750

-- Block specific items from being placed inside any backpack.
-- REQUIRES ox_inventory OR origen_inventory (uses registerHook).
-- Other inventory systems are NOT supported — a console warning will appear.
Config.EnableItemBlacklist = false
Config.BlacklistedItems = {
    -- 'weapon_pistol',
    -- 'weapon_knife',
    -- 'goldbar',
}


-- ─────────────────────────────────────────────────────────────────────────────
-- 5. POLICE SEARCH
-- ─────────────────────────────────────────────────────────────────────────────
Config.PoliceSearchJobs          = { 'police', 'sheriff', 'fbi' }  -- jobs allowed to search
Config.PoliceSearchRequiresCuffs = true   -- target must be handcuffed
Config.PoliceSearchDistance      = 3.0    -- max distance in metres
Config.PoliceSearchCommand       = 'searchbackpack'  -- chat command name (no leading /)

-- Target integration (optional). When true, an officer can aim their target
-- (ox_target / qb-target / qtarget) at a player wearing a backpack on their back
-- and pick "Search Backpack" — no command needed. Uses Config.TargetSystem.
-- NOTE: 'drawtext' does NOT support player targeting; in that mode use the command.
-- The server still enforces job + distance + handcuff rules above, no matter how
-- the search is started.
Config.PoliceSearchUseTarget      = false
Config.PoliceSearchTargetLabel    = 'Çantayı Ara'
Config.PoliceSearchTargetIcon     = 'fa-solid fa-magnifying-glass'
Config.PoliceSearchTargetDistance = 2.5     -- how close the officer must aim (metres)


-- ─────────────────────────────────────────────────────────────────────────────
-- 5b. PIN BRUTE-FORCE LOCKOUT
--     Too many wrong PIN attempts temporarily locks the backpack so a thief who
--     stole the bag item cannot hammer PINs. Owner is notified (if online) and
--     the lockout is logged.
-- ─────────────────────────────────────────────────────────────────────────────
Config.PinLockout = {
    enabled        = true,
    maxAttempts    = 5,     -- wrong attempts before lockout
    lockoutSeconds = 300,   -- how long the backpack stays locked (5 min)
}

-- ─────────────────────────────────────────────────────────────────────────────
-- 5c. ADMIN INSPECT
--     Admins can open any player's backpack for support / anti-cheat. Permission
--     is checked server-side against the framework admin group.
-- ─────────────────────────────────────────────────────────────────────────────
Config.AdminInspect = {
    enabled = true,
    command = 'inspectbag',   -- usage: /inspectbag [serverId]
}


-- ─────────────────────────────────────────────────────────────────────────────
-- 6. BACKPACKS
--    Add as many backpacks as you need. Each is identified by its unique `name`
--    (the inventory item name). `slots` / `weight` define its storage capacity.
--
--    Visual options per backpack:
--      COMPONENT (clothing drawable):
--        component = { drawable = 111, texture = 0 }
--
--      PROP (3-D object attached to ped — `prop` takes priority over component):
--        prop = {
--            model    = 'hei_prop_heist_bag_01',
--            bone     = 'SKEL_Spine2',
--            offset   = vector3(0.12, 0.0, -0.15),
--            rotation = vector3(0.0, 0.0, 0.0),
--        }
-- ─────────────────────────────────────────────────────────────────────────────

-- Fallback component when no specific one is defined for a backpack.
Config.DefaultBackpackComponent = {
    male   = { drawable = 111, texture = 3 },
    female = { drawable = 111, texture = 3 },
}

-- Fallback prop when a backpack has `prop = {}` but is missing fields.
-- Bone reference: https://wiki.rage.mp/index.php?title=Bones
Config.DefaultBackpackProp = {
    model    = 'hei_prop_heist_bag_01',
    bone     = 'SKEL_Spine2',
    offset   = vector3(0.12, 0.0, -0.15),
    rotation = vector3(0.0, 0.0, 0.0),
}

Config.Backpacks = {
    {
        name   = 'backpack_level_1',
        label  = 'Küçük Sırt Çantası',
        slots  = 16,
        weight = 10000,
        price  = 10,
        component = {
            male   = { drawable = 16, texture = 0 },
            female = { drawable = 16, texture = 0 },
        },
    },
    {
        name   = 'backpack_level_2',
        label  = 'Orta Sırt Çantası',
        slots  = 24,
        weight = 15000,
        price  = 20,
        component = {
            male   = { drawable = 18, texture = 2 },
            female = { drawable = 18, texture = 2 },
        },
    },
    {
        name   = 'backpack_level_3',
        label  = 'Büyük Sırt Çantası',
        slots  = 32,
        weight = 20000,
        price  = 30,
        component = {
            male   = { drawable = 9, texture = 0 },
            female = { drawable = 9, texture = 0 },
        },
    },
    {
        name   = 'backpack_level_4',
        label  = 'Kamp Sırt Çantası',
        slots  = 46,
        weight = 25000,
        price  = 40,
        component = {
            male   = { drawable = 109, texture = 0 },
            female = { drawable = 109, texture = 0 },
        },
    },
}


-- ─────────────────────────────────────────────────────────────────────────────
-- 7. SHOPS
--    Each shop entry creates: a blip, an optional NPC ped, and an interaction zone.
--    You can add as many shops as you want.
-- ─────────────────────────────────────────────────────────────────────────────
Config.Shops = {
    {
        enableBlip = false,
        enablePed  = true,

        ped = {
            model      = 'u_m_m_streetart_01',
            position   = vector3(-1189.239502, -1188.329712, 6.762695),
            heading    = 107.716537,
            invincible = true,
            frozen     = true,
            canRagdoll = false,
        },

        targetZone = {
            coords = vec3(-1189.239502, -1188.329712, 6.762695),
            radius = 1.0,
            debug  = false,
            icon   = 'fa-solid fa-bag-shopping',
            label  = 'Sırt Çantası Mağazası',
        },

        blip = {
            coords     = vector3(-1189.239502, -1188.329712, 7.762695),
            sprite     = 850,
            color      = 18,
            scale      = 0.8,
            name       = 'Sırt Çantası Mağazası',
            display    = 4,
            shortRange = true,
        },
    },
    -- Add more shops by copying the block above:
    -- {
    --     enableBlip = true,
    --     enablePed  = true,
    --     ped        = { model = '...', position = vector3(x,y,z), heading = 0.0, invincible = true, frozen = true, canRagdoll = false },
    --     targetZone = { coords = vec3(x,y,z), radius = 1.0, debug = false, icon = '...', label = '...' },
    --     blip       = { coords = vector3(x,y,z), sprite = 850, color = 18, scale = 0.8, name = '...', display = 4, shortRange = true },
    -- },
}


-- ─────────────────────────────────────────────────────────────────────────────
-- 8. STORAGE LOCKERS
--    Same structure as shops.
-- ─────────────────────────────────────────────────────────────────────────────
Config.LockerLocations = {
    {
        enableBlip = false,
        enablePed  = false,

        locker = {
            id    = 'locker_downtown',
            label = 'Downtown Sırt Çantası Deposu',
        },

        ped = {
            model      = 's_m_m_warehouse',
            position   = vector3(215.52, -809.12, 30.73),
            heading    = 250.0,
            invincible = true,
            frozen     = true,
            canRagdoll = false,
        },

        targetZone = {
            coords = vec3(215.52, -809.12, 30.73),
            radius = 1.5,
            debug  = false,
            icon   = 'fas fa-box-archive',
            label  = 'Sırt Çantası Deposu',
        },

        blip = {
            coords     = vector3(215.52, -809.12, 30.73),
            sprite     = 473,
            color      = 3,
            scale      = 0.7,
            name       = 'Sırt Çantası Deposu',
            display    = 4,
            shortRange = true,
        },
    },
    -- Add more lockers the same way:
    -- { locker = { id = 'locker_2', label = '...' }, ... }
}


-- ─────────────────────────────────────────────────────────────────────────────
-- 8b. PASSCODE RESET NPCs
--    Player visits one of these NPCs to reset the PIN on their backpack.
--    Same structure as shops/lockers. Only used when EnablePasscodeReset = true.
-- ─────────────────────────────────────────────────────────────────────────────
Config.PasscodeResetLocations = {
    -- Add more reset NPCs by copying the block above.
}


-- ─────────────────────────────────────────────────────────────────────────────
-- 9. NOTIFICATIONS
-- ─────────────────────────────────────────────────────────────────────────────
Config.Notifications = {
    -- hook-based (server)
    BackpackInBackpack      = 'Bir çantayı başka bir çantanın içine koyamazsın!',
    OnlyOneBackpack         = 'Aynı anda yalnızca bir çanta taşıyabilirsin!',
    AlreadyHaveBackpack     = 'Zaten bir çantan var! Önce mevcut çantanı bırak.',
    ItemBlacklisted         = 'Bu eşya çantaya konulamaz!',

    -- PIN
    PinIncorrect            = 'Hatalı PIN.',
    PinInvalid              = 'Geçersiz PIN — 4–8 haneli olmalı.',
    PinChangedSuccess       = 'PIN başarıyla değiştirildi.',
    PinChangeFailed         = 'PIN değiştirilemedi.',
    PinChangeWrongCurrent   = 'Mevcut PIN hatalı.',

    -- padlock item
    BackpackAlreadyLocked       = 'Bu çantada zaten bir kilit var.',
    PadlockActivated            = 'Asma kilit takıldı. Çanta artık PIN korumalı.',
    PadlockCancelled            = 'Asma kilit kurulumu iptal edildi.',
    PadlockRemoved              = 'Asma kilit çıkarıldı. Çanta artık kilitsiz.',

    -- fingerprint padlock
    FingerprintActivated        = 'Parmak izi kilidi ayarlandı. Bu çantayı yalnızca sen açabilirsin.',
    FingerprintCancelled        = 'Parmak izi kurulumu iptal edildi.',
    FingerprintDenied           = 'Erişim reddedildi. Parmak izi tanınmadı.',
    FingerprintRemoved          = 'Parmak izi kilidi çıkarıldı. Çanta artık kilitsiz.',
    FingerprintOwnerOnly        = 'Bu kilidi yalnızca parmak izi sahibi çıkarabilir.',

    -- lock removal / identifier
    LockRemoved                 = 'Kilit başarıyla çıkarıldı.',
    LockRemoveInventoryFull     = 'Envanterin dolu — kilidi çıkarmak için yer aç.',
    BackpackNoIdentifier        = 'ID oluşturmak için önce çantayı bir kez aç.',

    -- passcode reset NPC
    ResetNoBackpack             = 'Şifreyi sıfırlamak için çanta envanterinde olmalı.',
    ResetNoLock                 = 'Bu çantada ayarlı bir şifre yok.',
    ResetNotOwner               = 'Şifreyi yalnızca onu ayarlayan kişi sıfırlayabilir.',
    ResetFingerprintLock        = 'Parmak izi kilitli çantalar burada sıfırlanamaz.',
    ResetSuccess                = 'Çanta şifresi sıfırlandı.',
    ResetFailed                 = 'Çanta şifresi sıfırlanamadı.',
    ResetCancelled              = 'Şifre sıfırlama iptal edildi.',

    -- backpack general
    InvalidBackpackItem     = 'Geçersiz çanta eşyası.',

    -- backpack visual toggle (per-player command)
    BackpackVisualShown     = 'Çanta artık sırtında görünüyor.',
    BackpackVisualHidden    = 'Çanta gizlendi — envanterinden kullanmaya devam edebilirsin.',
    BackpackVisualDisabled  = 'Bu sunucuda çanta görünürlüğü kapalı.',

    -- police search
    FeatureDisabled         = 'Bu özellik devre dışı.',
    NoSearchPermission      = 'Çanta arama yetkin yok.',
    TargetTooFar            = 'Hedef çok uzakta.',
    TargetNotHandcuffed     = 'Hedefin kelepçeli olması gerekiyor.',
    TargetInventoryError    = 'Hedefin envanterine erişilemedi.',
    TargetNoBackpack        = 'Hedefin çantası yok.',
    SearchingBackpack       = 'Çanta aranıyor...',
    NoPlayerNearby          = 'Yakında oyuncu yok.',

    -- locker
    LockerAlreadyFull       = 'Dolabında zaten bir çanta saklı.',
    InventoryAccessError    = 'Envantere erişilemedi.',
    NoBackpackToStore       = 'Saklayacak bir çantan yok.',
    BackpackRemoveFailed    = 'Çanta envanterden çıkarılamadı.',
    BackpackStored          = 'Çanta dolaba kondu.',
    NoBackpackInLocker      = 'Bu dolapta saklı çanta yok.',
    InventoryFull           = 'Bu çantayı taşıyamazsın (envanter dolu).',
    BackpackAddFailed       = 'Çanta envantere eklenemedi.',
    BackpackRetrieved       = 'Çanta dolaptan alındı.',
    WithdrawHasBackpack     = 'Zaten bir çantan var! Önce onu bırak.',

    -- PIN lockout
    PinLockedOut            = 'Çok fazla hatalı deneme — bu çanta geçici olarak kilitlendi.',
    PinLockoutOwnerAlert    = 'Biri çantanı açmaya çalışıyor! Çanta kilitlendi.',

    -- admin
    AdminNoPermission       = 'Bu komutu kullanma yetkin yok.',
    AdminTargetInvalid      = 'Geçersiz hedef oyuncu.',
    AdminTargetNoBackpack   = 'Bu oyuncunun çantası yok.',
}

Config.Labels = {
    -- PIN dialog titles (shown in padlock UI)
    PinDialogUnlock             = 'Çantanın Kilidini Aç',
    PinDialogSet                = 'PIN Belirle',
    PinDialogChangeCurrent      = 'Mevcut PIN',
    PinDialogChangeNew          = 'Yeni PIN',
    PinDialogPadlock            = "Asma Kilit PIN'i Belirle",
    PinDialogReset              = 'Yeni Şifre Belirle',

    -- fingerprint UI
    FingerprintDialogRegister   = 'Parmak İzi Kaydet',
    FingerprintDialogVerify     = 'Parmak İzi Kilidi',
    FingerprintStatusScanning   = 'Taranıyor…',
    FingerprintStatusConfirmed  = 'Kimlik doğrulandı',
    FingerprintStatusDenied     = 'Erişim reddedildi',

    -- PIN input field labels (kept for fallback if NUI not used)
    PinInputCode            = 'PIN Kodu',
    PinInputNew             = 'Yeni PIN (4–8 hane)',
    PinInputCurrent         = 'Mevcut PIN',

    -- backpack context menu
    MenuTitle               = 'Sırt Çantası',
    MenuOpen                = 'Çantayı Aç',
    MenuChangePin           = 'PIN Değiştir',
    MenuChangePinDesc       = "Mevcut PIN'i yenisiyle değiştir",
    MenuRemovePadlock       = 'Asma Kilidi Çıkar',
    MenuRemovePadlockDesc   = 'Bu çantadaki asma kilidi çıkar',

    -- locker context menu
    LockerWithdrawTitle     = 'Çantayı Al',
    LockerWithdrawDesc      = 'Sakladığın çantayı geri al',
    LockerDepositTitle      = 'Çantayı Bırak',
    LockerDepositDesc       = 'Çantanı bu dolapta sakla',
}


-- =============================================================================
-- DO NOT EDIT BELOW THIS LINE
-- Internal helper functions shared between client and server.
-- =============================================================================

--- Verbose log — only prints when Config.Debug is true.
--- Use plain print() for warnings, errors and security alerts.
function DebugPrint(...)
    if Config.Debug then print(...) end
end

--- Look up a backpack config entry by item name. Returns the entry or nil.
function GetBackpackByName(itemName)
    if not itemName then return nil end
    for _, bp in ipairs(Config.Backpacks) do
        if bp.name == itemName then return bp end
    end
    return nil
end

--- Legacy fallback: map an old numeric level to a backpack entry.
--- Only used when reading pre-existing data (locker rows / item metadata)
--- created before backpacks were keyed purely by name.
function GetBackpackByLegacyLevel(level)
    if not level then return nil end
    level = tonumber(level)
    if not level then return nil end
    -- Old default naming scheme was 'backpack_level_N'.
    return GetBackpackByName('backpack_level_' .. level)
        or Config.Backpacks[level]
        or Config.Backpacks[1]
end

local _ESX
local _QBCore

local function GetESX()
    if not _ESX then _ESX = exports['es_extended']:getSharedObject() end
    return _ESX
end

local function GetQBCore()
    if not _QBCore then _QBCore = exports['qb-core']:GetCoreObject() end
    return _QBCore
end

function Notify(message, notifType, src)
    local notifyType = notifType or 'inform'
    local framework  = Config.Framework

    if IsDuplicityVersion() then
        if not src then
            print('[Oxlyn Backpack] Notify called without src on server side')
            return
        end
        if framework == 'qbcore' then
            TriggerClientEvent('QBCore:Notify', src, message, notifyType)
        elseif framework == 'qbox' then
            -- qbx_core has no server-side Notify export; use ox_lib event directly
            TriggerClientEvent('ox_lib:notify', src, { type = notifyType, description = message })
        elseif framework == 'esx' or framework == 'oldesx' then
            TriggerClientEvent('esx:showNotification', src, message)
        else
            TriggerClientEvent('ox_lib:notify', src, { type = notifyType, description = message })
        end
        return
    end

    -- Client side
    if framework == 'qbcore' then
        local core = GetQBCore()
        if core then core.Functions.Notify(message, notifyType); return end
    end
    if framework == 'qbox' then
        local ok = pcall(function() exports.qbx_core:Notify(message, notifyType) end)
        if ok then return end
    end
    if framework == 'esx' then
        local core = GetESX()
        if core then core.ShowNotification(message); return end
    end
    if framework == 'oldesx' then
        TriggerEvent('esx:showNotification', message)
        return
    end
    lib.notify({ type = notifyType, description = message })
end
