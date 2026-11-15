Config = {}

Config.Locale = 'en' -- en | tr

-- Using this item opens the pad.
Config.Item = 'game_pad'
Config.RequireItem = true

-- Opens the pad without an item check when no inventory is running. '' disables it.
Config.Command = 'arcade'

Config.Session = {
    TimeoutMs = 90000,
    HeartbeatMs = 30000,
}

Config.Theme = {
    accent = '#D43D45',
    accentHover = '#C2353D',
    accentActive = '#A92D35',
    accentSubtle = 'rgba(212, 61, 69, 0.15)',
    accentMuted = 'rgba(212, 61, 69, 0.08)',
    accentRing = 'rgba(212, 61, 69, 0.35)',
    accentText = '#F08A8F',
}

-- Home screen apps, in order. dock = pinned to the bottom bar.
Config.Apps = {
    { id = 'categories', icon = 'font', tint = 'teal', dock = true },
    { id = 'agents', icon = 'user-secret', tint = 'indigo', dock = true },
    { id = 'colorclash', icon = 'cards', tint = 'red', dock = true },
    { id = 'wordguess', icon = 'spell-check', tint = 'green', dock = true },
    { id = 'sketch', icon = 'pencil', tint = 'pink', dock = false },
    { id = 'blockpuzzle', icon = 'puzzle', tint = 'orange', dock = false },
    { id = 'game2048', icon = 'grid', tint = 'yellow', dock = false },
    { id = 'minesweeper', icon = 'bomb', tint = 'red', dock = false },
    { id = 'settings', icon = 'gear', tint = 'gray', dock = false },
}

-- Categories rules and timings live in data/categories_rules.json.

Config.ColorClash = {
    MaxPlayers = 6,
    TurnMs = 15000,
    LastCardGraceMs = 3000, -- the player may still call "last card" alone
    CatchWindowMs = 3000,   -- then others may catch them
}

Config.Agents = {
    MaxPlayers = 8,
    ClueMs = 90000,
    GuessMs = 60000,
}

Config.Sketch = {
    MinPlayers = 2,
    MaxPlayers = 8,
    RoundPrepareMs = 10000,
    RoundMs = 75000,
    RoundResultMs = 8000,
    RoundsPerMatch = 0, -- 0 = everyone draws once
    MaxGuessLength = 40,
    GuessCooldownMs = 400,
    MaxStrokeBatchPoints = 240,
    MaxStrokesPerRound = 600,
    MinBrushWidth = 1,
    MaxBrushWidth = 28,
    DrawerPointsMax = 100,
    GuesserBasePoints = 100,
    GuesserPointsStep = 20,
    GuesserPointsFloor = 20,
    AllowedColors = {
        '#1f2933', '#e03131', '#f08c00', '#2f9e44', '#1971c2', '#7048e8', '#e64980', '#ffffff',
    },
}

-- Server settings (overrides/daddy_arcadepad/config.lua)
-- The server's language.
Config.Locale = 'tr'
