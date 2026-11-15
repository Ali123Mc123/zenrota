Settings = {}

-- RP surumu: sade nisangah. Hit marker, hasar sayilari, kill yazilari, tracer, ses ve isabet telafisi yok.
Settings.Locale = 'tr'
Settings.OpenCommand = 'crosshair'
Settings.OpenKey = 'F9'
Settings.SaveKey = 'daddy_crosshair_rp_v1'
Settings.LegacySaveKey = 'daddy_crosshair_rp_v1'

-- Profiles and server sync
Settings.MaxProfiles = 1
Settings.ServerSync = true
Settings.ServerWriteDelay = 1500
Settings.MaxPayload = 4000

Settings.Colors = {
    { id = 'white', hex = '#ffffff' },
    { id = 'gray', hex = '#9aa0aa' },
    { id = 'red', hex = '#ff3b3b' },
    { id = 'yellow', hex = '#ffe03d' },
    { id = 'green', hex = '#2ee86b' },
    { id = 'cyan', hex = '#25e6ff' },
}

Settings.WeaponGroups = {}

-- Settings that belong to a profile (the crosshair look); everything else is shared by all profiles
Settings.LookKeys = { 'style', 'color', 'size', 'thickness', 'gap', 'opacity', 'outline', 'shadow', 'dot', 'rotation', 'anim', 'dynamic', 'dynamicAmount', 'dynamicSpeed' }

-- Settings that describe the profile system itself (not exported in share codes)
Settings.MetaKeys = { 'activeProfile' }

-- Color settings also accept any #rrggbb value
Settings.ColorKeys = { 'color' }

Settings.Options = {
    show = { 'armed', 'aim' },
    style = { 'dot', 'cross', 'plus', 'tee', 'x', 'hline', 'circle', 'ringcross', 'square', 'corners', 'diamond', 'triangle', 'chevron', 'bracket' },
    size = { 2, 4, 6, 8, 10, 12 },
    thickness = { 1, 2, 3 },
    gap = { 0, 2, 4, 6 },
    opacity = { 30, 40, 50, 60, 70, 80, 90, 100 },
    shadow = { 0, 2, 4 },
    rotation = { 0 },
    anim = { 'none' },
    dynamicAmount = { 6 },
    dynamicSpeed = { 180 },
    activeProfile = { 1 },
}

for _, key in ipairs(Settings.ColorKeys) do
    Settings.Options[key] = {}
    for i, color in ipairs(Settings.Colors) do Settings.Options[key][i] = color.id end
end

Settings.Defaults = {
    enabled = true,
    show = 'aim',
    style = 'dot',
    color = 'white',
    size = 4,
    thickness = 2,
    gap = 2,
    opacity = 80,
    outline = true,
    shadow = 2,
    dot = false,
    rotation = 0,
    anim = 'none',
    dynamic = false,
    dynamicAmount = 6,
    dynamicSpeed = 180,
    hideInVehicle = false,
    hideOnSniper = true,
    activeProfile = 1,
}

Settings.Menu = {
    { id = 'crosshair', rows = {
        { key = 'enabled', type = 'toggle' },
        { key = 'show', type = 'choice' },
        { key = 'style', type = 'shape' },
        { key = 'color', type = 'color' },
        { key = 'size', type = 'step', unit = 'px' },
        { key = 'thickness', type = 'step', unit = 'px' },
        { key = 'gap', type = 'step', unit = 'px' },
        { key = 'opacity', type = 'step', unit = '%' },
        { key = 'outline', type = 'toggle' },
        { key = 'dot', type = 'toggle' },
        { key = 'hideInVehicle', type = 'toggle' },
        { key = 'hideOnSniper', type = 'toggle' },
    } },
}

Settings.Presets = {
    { id = 'dot', values = { style = 'dot', color = 'white', size = 4, outline = true, dot = false, opacity = 80 } },
    { id = 'minimal', values = { style = 'dot', color = 'white', size = 2, thickness = 1, outline = false, dot = false, opacity = 60 } },
    { id = 'classic', values = { style = 'cross', color = 'white', size = 6, thickness = 1, gap = 2, outline = true, dot = false, opacity = 80 } },
}
