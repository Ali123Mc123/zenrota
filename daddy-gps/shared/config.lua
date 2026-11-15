Config = {}

Config.Debug = false      -- Enable debug mode for console logging
Config.ItemName = 'gps'   -- Item name required to open GPS (must exist in your framework)
Config.RequireItem = true -- Set to true to require the player to have the item to use the command -- Set to false to allow the command to work without the item
Config.Locale = 'tr'      -- Available: 'en', 'tr', 'de', 'fr', 'es', 'it', 'nl', 'pt'

Config.WaterDamage = {    -- Water damage system - GPS breaks if player enters water while on foot
    Enabled = true,
}

Config.Callsign = { -- Callsign is a numeric value (e.g. 401, 1234)
    Min = 1,
    Max = 99999,
}

Config.RequireRealJob = true -- Require players to have an allowed job to use GPS

-- ============================================================================
-- ALLOWED JOBS (WHITELIST)
-- ============================================================================
-- If a job is NOT in this list, they cannot open the GPS (if RequireRealJob is true).
-- The value MUST match a key in Config.Departments.

Config.AllowedJobs = {
    ['police']    = 'police',
    ['sasp']      = 'sasp',
    ['pbsd']      = 'pbsd',
    ['sapr']      = 'sapr',
    ['dp']        = 'dp',
    ['bcso']      = 'bcso',
    ['ambulance'] = 'lsms',
    ['ems']       = 'lsms',
    ['doj']       = 'doj',
}
-- ============================================================================
-- DEPARTMENTS
-- ============================================================================
-- Define all available departments here.
-- key: Unique identifier (used in code)
-- label: Short name (UI Button)
-- text: Full name (UI Header/Status)
-- color: GTA Blip Color ID (Map)
-- hex: CSS Hex Color (UI Accent)
-- enabled: Show in UI?

Config.Departments = {
    police = {
        label = 'PD',
        text = 'Polis Departmanı',
        color = 3, -- Blue
        hex = '#3b82f6',
        enabled = true
    },
    pbsd = {
        label = 'PBSD',
        text = 'Paleto Bay Şerif Departmanı',
        color = 47, -- Orange
        hex = '#ff7300',
        enabled = true
    },
    bcso = {
        label = 'SD',
        text = 'Şerif Departmanı',
        color = 46, -- Gold/Yellow
        hex = '#eab308',
        enabled = true
    },
    dp = {
        label = 'DP',
        text = 'DP',
        color = 27, -- Purple
        hex = '#8b5cf6',
        enabled = true
    },
    sasp = {
        label = 'SASP',
        text = 'SASP',
        color = 22, -- Grey
        hex = '#9ca3af',
        enabled = true
    },
    sapr = {
        label = 'PR',
        text = 'SAPR',
        color = 52, -- Dark Green
        hex = '#15803d',
        enabled = true
    },
    lsms = {
        label = 'EMS',
        text = 'Sağlık Hizmetleri',
        color = 1, -- Red
        hex = '#ef4444',
        enabled = true
    },
    fire = {
        label = 'LSFD',
        text = 'İtfaiye',
        color = 47, -- Orange
        hex = '#f97316',
        enabled = false
    },
    doc = {
        label = 'DOC',
        text = 'Cezaevi',
        color = 26, -- Dark Blue
        hex = '#1e3a8a',
        enabled = false
    },
    fib = {
        label = 'FIB',
        text = 'Federal Büro',
        color = 2,      -- Green
        hex = '#22c55e',
        enabled = false -- Disabled by default
    },
    doj = {
        label = 'DOJ',
        text = 'Adalet Bakanlığı',
        color = 17,    -- Light Grey
        hex = '#b07f66',
        enabled = true -- Disabled by default
    }
}

-- ============================================================================
-- CHANNEL SYSTEM MODE
-- ============================================================================

-- 'department' = each department has its own channel (current behavior)
-- 'global'     = only one global channel, no department-specific channels
Config.ChannelMode = 'department'

-- ============================================================================
-- SELF BLIP
-- ============================================================================

-- Show the player's own GPS blip on the map
Config.SelfBlip = {
    Default = false -- Default state (user can toggle in GPS settings)
}

-- How often (in milliseconds) the client updates blip positions with smooth movement
-- Lower = smoother but more client CPU usage
Config.LerpTickMs = 400

-- Interpolation speed (0.0 to 1.0)
-- 1.0 = instant (no interpolation), 0.25 = smooth/slow
Config.LerpAlpha = 1.0

-- Distance threshold (in world units) to consider a blip "arrived" at target
-- Used to prevent micro-adjustments
Config.CoordEpsilon = 0.5

-- ============================================================================
-- BLIP APPEARANCE
-- ============================================================================

-- Blip Sizes (Scale) — per movement/vehicle state
Config.BlipSizes = {
    OnFoot     = 0.70, -- Walking / on foot
    Vehicle    = 0.70, -- Car / default vehicle
    Bike       = 0.70, -- Motorcycle
    Helicopter = 0.70, -- Helicopter
    Plane      = 0.70, -- Plane
    Boat       = 0.70, -- Boat
    Overlay    = 0.70, -- Dot overlay blip
    Chase      = 0.50  -- Chase blip (siren active)
}

-- Blip category in the map legend. 2 = plain blips with distance; 6/7 are GTA player groups, which the pause map pins to its edge
Config.BlipCategory = 2

-- Default sprite IDs for different vehicle types
Config.DefaultSprites = {
    heli  = 422, -- Helicopter sprite
    plane = 16,  -- Plane sprite
    boat  = 427, -- Boat sprite
    walk  = 1,   -- Walking/on foot sprite
    car   = 225, -- Car/vehicle sprite
    bike  = 226  -- Motorcycle sprite
}

-- Sprites that cannot be color-tinted (require DOT overlay for color)
Config.NonTintableSprites = {
    [15] = true, -- Special sprite
    [41] = true, -- Special vehicle
    [42] = true  -- Chase vehicle (siren active)
}

-- Sprites that should NOT get an overlay dot (keep natural appearance)
Config.NoOverlaySprites = {
    [42] = true -- Chase blip: no overlay, no colour tint
}



-- ============================================================================
-- PED/COORD BLIP SWITCHING (Hysteresis)
-- ============================================================================

-- Time (ms) to wait before switching between ped and coord blips
-- This prevents rapid flickering when player goes in/out of network range
Config.HysteresisMs = 2000 --

-- ============================================================================
-- ADVANCED SETTINGS
-- ============================================================================

-- Legacy compatibility flag
Config.AmbulanceUsesName = true

-- ============================================================================
-- KEYBIND
-- ============================================================================

-- Keybind to open/close the GPS UI.
-- Uses FiveM RegisterKeyMapping defaults — players can rebind in Settings > Key Bindings.
-- Set to '' (empty string) to disable the keybind entirely.
-- Common values: 'F5', 'F6', 'HOME', 'NUMPAD0', 'G', etc.
Config.Keybind = {
    Enabled     = true,
    DefaultKey  = 'F9',   -- Default key (can be rebound by player in GTA key settings)
    Description = 'GPS Aç / Kapat', -- Label shown in the key bindings menu
}
