Config = {}

Config.Locale = 'tr' -- en | tr
Config.Accent = '#ff1f6d' -- the main button and what is chosen

-- Keys (players can change them in FiveM's key settings)
Config.Keys = {
    Look = 'V',        -- hold: free camera without the panel; press again to close
    Photo = 'F6',      -- photo mode with the panel
    HoldMs = 400,      -- how long V is held before the free camera opens (a short tap keeps the game's own V)
    -- Tilt while the camera is open (panel shown or hidden): game control ids and the letters shown on the panel
    TiltLeft = { Control = 45, Label = 'R' },  -- 45 = R
    TiltRight = { Control = 23, Label = 'F' }, -- 23 = F
    TiltSpeed = 40.0,  -- degrees a second while held
}

-- Smooth motion: how fast the camera catches up with the mouse and keys (higher = snappier, lower = softer)
Config.Smooth = {
    Look = 35.0, -- turning (high: the mouse feels direct)
    Move = 7.0,  -- moving, speeding up and slowing down
    Zoom = 9.0,  -- zoom and tilt
}

-- Blend from and back to the game camera, in ms
Config.Blend = { Open = 550, Close = 650 }

-- Quick look (hold V): the camera circles the character
Config.Look = {
    MinDistance = 1.2,
    MaxDistance = 6.0, -- metres from the character's head
    Fov = 50.0,
}

-- Free camera and photo mode
Config.Free = {
    MaxDistance = 12.0, -- metres from the character, sideways
    MaxHeight = 6.0,    -- metres above or below the character
    Speed = 3.0,        -- metres per second (Shift x3, Ctrl x0.3)
    OpenPull = 0.6,     -- metres the camera drifts back when photo mode opens
    LookSpeed = 9.0,   -- mouse sensitivity
    MinFov = 1.0,       -- the closest zoom (1 = the game's limit, about 50x)
    MaxFov = 120.0,     -- the widest view
    MaxRoll = 45.0,     -- degrees the camera tilts sideways
    WallGap = 0.25,     -- the camera stays this far from walls
    ReturnWhenHidden = true, -- the camera comes back when the character is out of its sight (round a corner)
    HiddenSeconds = 2.0,
}

-- When the camera cannot open
Config.Block = {
    DamageSeconds = 30,  -- after taking or dealing damage
    Weapon = true,       -- a weapon in hand (free camera and photo mode)
    Driving = true,      -- driving a moving vehicle
}

-- Photos
Config.Photo = {
    Width = 1920,       -- largest width of a photo in pixels
    Quality = 0.92,     -- JPEG quality 0-1
    PerMinute = 6,      -- photos a player may take in a minute
    Keep = 60,          -- photos kept in a player's list (older ones leave the list)
    Folder = 'daddy_photocam/photo', -- Fivemanage folder
    Host = 'https://r2.fivemanage.com/Ys6cM9PLWjYdYxw6wrjzC/', -- where this server's Fivemanage files live
    MinBytes = 15000,   -- a smaller file is an empty frame and is thrown away
}

-- Filters (timecycle modifiers); names are in locales (filters.<id>)
Config.Filters = {
    { id = 'none' },
    { id = 'bw', modifier = 'spectator4' },
    { id = 'bw_soft', modifier = 'hud_def_desat_cold_kill' },
    { id = 'noir', modifier = 'NG_deathfail_BW_base' },
    { id = 'cinema', modifier = 'cinema' },
    { id = 'cinema_strong', modifier = 'cinema_001' },
    { id = 'film_warm', modifier = 'NG_filmic10' },
    { id = 'film_old', modifier = 'CHOP' },
    { id = 'vhs', modifier = 'Broken_camera_fuzz' },
    { id = 'cctv', modifier = 'CAMERA_secuirity_FUZZ' },
    { id = 'bloom', modifier = 'BloomLight' },
    { id = 'bright', modifier = 'BeastLaunch02' },
    { id = 'contrast', modifier = 'epsilion' },
    { id = 'sharp', modifier = 'AmbientPUSH' },
    { id = 'vignette', modifier = 'BikerForm01' },
    { id = 'cold', modifier = 'glasses_brown' },
    { id = 'blue', modifier = 'glasses_Darkblue' },
    { id = 'orange', modifier = 'glasses_orange' },
    { id = 'pink', modifier = 'TinyPink01' },
    { id = 'purple', modifier = 'glasses_purple' },
    { id = 'beach', modifier = 'ArenaWheelPurple01' },
    { id = 'sunset', modifier = 'MP_Arena_theme_evening' },
    { id = 'fog', modifier = 'graveyard_shootout' },
    { id = 'underwater', modifier = 'underwater_deep' },
}

-- Weather types offered in photo mode (only the player sees them)
Config.Weathers = { 'EXTRASUNNY', 'CLEAR', 'CLOUDS', 'OVERCAST', 'SMOG', 'FOGGY', 'RAIN', 'THUNDER', 'CLEARING', 'SNOWLIGHT', 'XMAS' }

-- Other HUDs to hide while a camera is open; hidden = true when it opens, false when it closes
Config.Hud = function(hidden)
    -- DaddyRP: wais-primehud's exports work the other way round (showHud hides, hideHud shows)
    if GetResourceState('wais-primehud') == 'started' then
        pcall(function() exports['wais-primehud'][hidden and 'showHud' or 'hideHud'](exports['wais-primehud']) end)
    end
end
