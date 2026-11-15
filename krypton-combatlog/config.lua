Config = {}

-- ┌─────────────────────────────────────┐
-- │           GENERAL SETTINGS          │
-- └─────────────────────────────────────┘

Config.Locale = 'tr' -- Language: 'en', 'tr'
Config.Debug = false -- Debug prints in console

-- How long (seconds) the combatlog marker stays visible after a player disconnects
-- Min: 30, Max: 180
Config.DisplayDuration = 180

-- Which identifier to display on the panel
-- Options: 'license', 'steam', 'discord', 'fivem'
Config.Identifier = 'discord'

-- ┌─────────────────────────────────────┐
-- │         FRAMEWORK SETTINGS          │
-- └─────────────────────────────────────┘

-- Framework auto-detection. Override if needed.
-- Options: 'auto', 'esx', 'qb', 'qbx', 'standalone'
Config.Framework = 'auto'


-- ┌─────────────────────────────────────┐
-- │          DISPLAY MODE               │
-- └─────────────────────────────────────┘

-- How combat logs are displayed in the world
-- 'marker'   = GTA native marker (?) + NUI info panel (floating UI, press E to copy)
-- 'ped'      = Ghost ped clone (player's appearance) + ox_lib context menu to view/copy info
-- 'drawtext' = GTA native 3D text overlay (lightweight, no NUI)
Config.DisplayMode = 'marker'

-- ┌─────────────────────────────────────┐
-- │     MARKER MODE SETTINGS (marker)   │
-- └─────────────────────────────────────┘

-- Distance at which the native marker + NUI panel becomes visible
-- [E] Copy Info is always available when visible
Config.RenderDistance = 15.0

-- Distance at which the NUI panel becomes visible (very close only)
Config.NuiRenderDistance = 1


Config.NuiWorldOffset = 0.30    -- World-space panel offset above the marker
Config.NuiScreenOffsetY = 0.035 -- Additional screen-space downward offset for the panel

-- GTA Marker type (see: https://docs.fivem.net/docs/game-references/markers/)
-- 32 = Question Mark
Config.MarkerType = 32

-- Marker color (RGBA 0-255)
-- When ReasonMarkerColors is true, the marker color changes based on disconnect reason.
-- This default is used as fallback.
Config.MarkerColor = { r = 59, g = 130, b = 246, a = 200 }

-- Use disconnect-reason themed colors for marker instead of the fixed color above
Config.ReasonMarkerColors = true

-- Reason key (Config.ReasonLabels) → marker color
Config.ReasonColors = {
    game_crashed = { r = 239, g = 68, b = 68, a = 220 },   -- red
    timed_out    = { r = 249, g = 115, b = 22, a = 220 },  -- orange
    exiting      = { r = 168, g = 85, b = 247, a = 220 },  -- purple
    quit         = { r = 107, g = 114, b = 128, a = 200 }, -- gray
    kicked_afk   = { r = 168, g = 85, b = 247, a = 220 },  -- purple
    disconnected = { r = 234, g = 179, b = 8, a = 220 },   -- yellow
    default      = { r = 59, g = 130, b = 246, a = 200 },  -- blue (fallback)
}

-- Marker size (x, y, z scale)
Config.MarkerSize = { x = 0.68, y = 0.68, z = 0.68 }

-- Marker vertical offset from player feet (negative = lower)
Config.MarkerZOffset = 0.50

-- Marker bob up and down
Config.MarkerBobUpAndDown = true

-- Marker face camera
Config.MarkerFaceCamera = true

-- Marker rotation speed (degrees per frame, 0 = no rotation)
Config.MarkerRotate = false

-- ┌─────────────────────────────────────┐
-- │      PED MODE SETTINGS (ped)        │
-- └─────────────────────────────────────┘

-- Ped transparency (0-255, lower = more transparent)
Config.PedAlpha = 180

-- Ped interaction distance (for ox_target / qb-target)
Config.PedInteractDistance = 2.0

-- Ghost ped pose / animation (ped display mode)
-- You can find animation dicts/names from databases like Pleb Masters: Forge.
-- Default makes the ped lie "dead" on the ground.
Config.PedAnim = {
    dict = 'dead',
    name = 'dead_a',
    flag = 2, -- 2 = AF_HOLD_LAST_FRAME (keeps final pose)
}

-- If true, disables physics collision on the ghost ped (ped won't block player movement)
-- Note: ox_target raycast still works even with this enabled
Config.PedNoCollision = true

-- Use ox_target if available, otherwise falls back to E key interaction
Config.UseTarget = true

-- ┌─────────────────────────────────────┐
-- │    PANEL DISPLAY OPTIONS (both)     │
-- └─────────────────────────────────────┘

-- Toggle which information is shown on the panel / context menu
Config.ShowName = true       -- Player name
Config.ShowTime = true       -- Disconnect time
Config.ShowReason = true     -- Disconnect reason
Config.ShowIdentifier = true -- Player identifier

-- ┌─────────────────────────────────────┐
-- │          DISCORD SETTINGS           │
-- └─────────────────────────────────────┘

-- Discord webhook URL for logging combat logs
Config.DiscordWebhook = ''

-- Discord bot token for fetching player avatars (optional)
-- If empty, DefaultAvatar will be used
Config.DiscordBotToken = ''

-- Default avatar when Discord avatar can't be fetched
Config.DefaultAvatar = 'https://i.imgur.com/wSTFkRM.png'

-- ┌─────────────────────────────────────┐
-- │           ADMIN SETTINGS            │
-- └─────────────────────────────────────┘

-- Ace permission required for admin commands
Config.AdminAce = 'group.admin'

-- Send in-game notification to admins when someone combat logs
Config.AdminNotify = true

-- ┌─────────────────────────────────────┐
-- │         DATABASE SETTINGS           │
-- └─────────────────────────────────────┘

-- Save combat log history to database (requires oxmysql)
-- If false, logs are only kept in memory and sent to Discord
Config.UseDatabase = false

-- ┌─────────────────────────────────────┐
-- │        DISCONNECT REASONS           │
-- └─────────────────────────────────────┘

-- These disconnect reasons will NOT be counted as combat log
-- Players disconnecting with these reasons won't show a marker
Config.IgnoredReasons = {
    -- Kicks and bans are now logged with their actual reason shown
}

-- Disconnect reason → locale key; first Lua pattern found in the lowercased reason wins
-- FiveM: closing the game (Alt+F4, X, exit menu) = "Exiting", F8 quit = "Quit: <text>"
Config.ReasonLabels = {
    { '^quit:',                        'quit' },             -- on top: quit text can fake "ban"/"kicked"
    { 'exiting',                       'exiting' },
    { '^disconnected',                 'disconnected' },
    { 'game crashed',                  'game_crashed' },
    { 'timed out',                     'timed_out' },
    { 'connecting to another server',  'connecting_other' },
    { 'you were kicked for being afk', 'kicked_afk' },
    { 'kicked',                        'kicked_admin' },
    { 'ban',                           'banned_admin' },
}
