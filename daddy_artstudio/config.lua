Config = {}

Config.Locale = 'tr' -- en | tr

Config.Command = 'artstudio' -- admin menu: canvases and reports (ACE daddy.admin.artstudio or daddy.admin)

-- Item needed to paint, e.g. 'paint_brush' ('' = none); looked at when a painter opens a canvas, kept 30 s.
Config.BrushItem = ''

-- Who may paint a new canvas, and the admin menu's presets ('custom' takes rules: everyone, job:name:grade, ace:name,
-- cid:id, item:name, role:college:student, comma separated). Manage: deletes anyone's strokes, clears, goes back in
-- history and exhibits on every canvas.
Config.Access = {
    Default = 'role:college:member',
    Manage = 'role:college:teacher',
    Presets = {
        { key = 'everyone', rule = 'everyone' },
        { key = 'members', rule = 'role:college:member' },
        { key = 'students', rule = 'role:college:student' },
        { key = 'teachers', rule = 'role:college:teacher' },
    },
}

Config.DefaultMode = 'open' -- open (a shared mural) | owned (an owner and invitees) | gallery (display only)

Config.Owned = {
    Days = 7,           -- an empty canvas is held this long once claimed (the owner can renew it)
    Invitees = 4,       -- painters an owner may invite
    InviteRange = 10.0, -- invitees are picked among players this close (m)
}

Config.Resolution = { Default = 1536, Choices = { 1024, 1536, 2048 } } -- a canvas's long edge in the studio (px)

Config.Paper = '#f6f1e4' -- a new canvas starts in this colour
Config.Backgrounds = { '#f6f1e4', '#ffffff', '#e9dfc9', '#1f2229' }

Config.Radius = 12.0 -- canvases without a floor area show within this distance (m)
Config.Height = 4.0  -- ... and this far above or below them

-- The ink engine (packages/ink).
Config.Ink = {
    Bake = true,          -- old strokes bake into picture tiles at 128 KB or 300 strokes, so a canvas never fills (false: no tiles)
    ArchivedDays = 30,    -- archived paintings (a deleted canvas, a page a restore replaced) are deleted after this long
    RestoreSeconds = 60,  -- one "bring this back" per canvas in this time
    RestoreOps = 2000,    -- strokes a restore copies on top of the snapshot's tiles (the newest)
}

Config.Surface = {
    Pages = 4,        -- canvases drawn live at once; the others show their last picture
    Size = 1024,      -- texture of a live canvas (px)
    Statics = 24,     -- canvases shown from their last picture at once
    Stream = 30.0,    -- drawn within this distance (m)
    Tint = 230,       -- brightness in the world (255 = full; lower keeps it from glowing in the dark)
    TwoSided = false, -- true only if canvases stay invisible in game (draws both faces)
}

Config.Interact = {
    Distance = 2.5,        -- target range (m)
    ServerTolerance = 4.0, -- server check, added to half the canvas size (m)
}

Config.Studio = {
    Colors = { '#1f2229', '#f7f4ec', '#e03b3b', '#f2a03d', '#f5d547', '#3fa34d', '#2f6fb5', '#5aa9e6', '#7d4fa8', '#e86fa3', '#8c5a3c', '#9aa0a6' },
    Widths = { 1, 2, 4, 8, 16, 32, 64 }, -- brush sizes (px at the 680 px reference)
}

Config.Report = {
    Reasons = { 'inappropriate', 'offensive', 'spam', 'other' },
    CooldownMinutes = 10, -- one report per player and canvas in this time
    KeepDays = 90,        -- dismissed reports are deleted after this long (open ones after twice that)
}

Config.LogDays = 30 -- the moderation log (admin menu) keeps this many days

Config.Theme = { accent = '#C9873F' }
