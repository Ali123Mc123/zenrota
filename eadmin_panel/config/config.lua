Config = Config or {}

-- Server mode: controls framework detection behavior.
--   'auto'       - Auto-detect framework (QBCore/ESX/Qbox). Falls back to standalone if none found. (default)
--   'standalone'  - Force standalone mode regardless of detected frameworks. Uses EAdmin's own
--                   player table (EAdmin_users) with no character/job/gang/inventory features.
Config.mode = 'auto'

-- Default locale: 'en'. Change to another language code and restart the resource.
Config.locale = 'tr'

-- Global debug switch (client + server modules that opt in)
Config.debug = false

-- Keybinding configuration
-- Key values: '' = no default binding (players bind via Settings > Key Bindings)
-- Common keys: F1-F24, HOME, END, PAGEUP, PAGEDOWN, INSERT, DELETE, PAUSE
-- Full reference: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/

-- Admin panel
Config.toggleCommand  = 'eadmin'              -- Command name registered in FiveM
Config.toggleKeyLabel = 'Toggle Admin Panel'  -- Description shown in Settings > Key Bindings
Config.toggleKey      = ''                    -- Default key
Config.toggleKeybind  = false                 -- Register key mapping (show in Settings > Key Bindings)

-- Support panel
Config.supportCommand  = 'support'             -- Command name registered in FiveM
Config.supportKeyLabel = 'Open Support Panel'  -- Description shown in Settings > Key Bindings
Config.supportKey      = ''                    -- Default key
Config.supportKeybind  = false                 -- Register key mapping (show in Settings > Key Bindings)

-- NoClip
Config.noClipCommand   = 'noclip'              -- Command name registered in FiveM
Config.noClipKeyLabel  = 'Toggle NoClip'       -- Description shown in Settings > Key Bindings
Config.noClipKey       = 'PAGEDOWN'            -- Default key (empty = player binds via settings)
Config.noClipKeybind   = true                  -- Register key mapping (show in Settings > Key Bindings)

-- Nametags
Config.nametagCommand  = 'nametags'            -- Command name registered in FiveM
Config.nametagKeyLabel = 'Toggle Nametags'     -- Description shown in Settings > Key Bindings
Config.nametagKey      = ''                    -- Varsayilan tus yok: PAGEUP wais-primehud editor moduyla cakisiyordu (Ayarlar > Tus Atamalari'ndan atanir)
Config.nametagKeybind  = true                  -- Register key mapping (show in Settings > Key Bindings)

-- Player Blips (map markers)
Config.blipCommand  = 'blips'                  -- Command name registered in FiveM
Config.blipKeyLabel = 'Toggle Player Blips'    -- Description shown in Settings > Key Bindings
Config.blipKey      = 'INSERT'                 -- Default key
Config.blipKeybind  = true                     -- Register key mapping (show in Settings > Key Bindings)

-- Map tile base URL for external hosting.
-- Leave empty ('') to use bundled local tiles (default).
-- Set to a URL to load tiles from an external server/CDN, e.g.:
--   'https://cdn.example.com/eadmin-map'
-- The URL should point to a directory containing:
--   tiles/{z}/{x}/{y}.png           (atlas layer)
--   satellite-tiles/{z}/{x}/{y}.png (satellite layer)
Config.mapTileBaseUrl = ''
