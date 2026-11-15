tgiCoreExports = exports["tgiann-core"]
config = tgiCoreExports:getConfig()

-- Sit pose used when a player sits on a chair around a table.
-- The ped is attached to the chair entity
config.sitPose = {
    animDict = "anim@veh@train@front@ps@base",
    animName = "sit",
    offset = vector3(0.0, 0.045, 0.05),
    rotation = vector3(0.0, 0.0, 180.0),
}

-- Tables, chairs and stones are drawn when a player gets this close (meters).
config.drawDistance = 50.0

-- A started game with nobody seated goes back to the lobby after this many minutes (0 turns it off).
config.autoResetEmptyMinutes = 5

-- Seat interaction keys + prompt range.
config.sit = {
    useTarget = false,    -- true: sit through ox_target / qb-target instead of the "E to sit" prompt
    promptDistance = 2.0, -- how close the player must be to see the "Sit" prompt (or reach the target)
    sitKey = 38,          -- key the player presses to sit down (default: E)
    standKey = 73,        -- key the player presses to stand up (default: X)
    cameraKey = 0,        -- key that turns the table camera on/off (default: V)
}

-- Camera settings while a player is seated at a table.
config.camera = {
    -- Seated camera (first-person-ish view looking down at the istaka).
    seated = {
        -- Forward offset along the chair's local Y axis (negative = towards the istaka, positive = behind the ped).
        forwardOffset = -0.12,
        -- Vertical offset above the chair's Z (≈ ped head height).
        upOffset = 0.15,
        -- Vertical offset of the camera's look-at point relative to the istaka Z (negative = below the istaka).
        lookZOffset = 0.165,
        -- Camera field-of-view.
        fov = 70.0,
        -- Smooth transition duration when entering / leaving the seated camera (ms).
        transitionMs = 500,
    },
    -- Overhead camera activated while dragging a stone towards the center of the table.
    overhead = {
        -- Height above the table center.
        height = 1.3,
        -- Camera field-of-view while overhead.
        fov = 60.0,
        -- Smooth transition duration when interpolating to / from the overhead camera (ms).
        transitionMs = 350,
    },
}

config.tables = {
    -- Kampüs
    { coords = vector3(5384.2227, -5262.8110, 32.0668), heading = 321.9364 },
    { coords = vector3(5299.6128, -5200.5713, 31.7201), heading = 11.7386 },
    { coords = vector3(5364.5991, -5177.3091, 32.0000), heading = 301.3382 },
}

-- key = FiveM key name (used as defaultKey) (https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/)
-- uiText = label shown on the UI keycap
config.keys = {
    -- Hold to force-reset the game as admin
    adminRestart = { key = "R", uiText = "R" },
    -- Toggle the scoreboard
    scoreboard = { key = "CAPITAL", uiText = "Caps" },
    -- 101: open hand (hold; automatically lays down the best combination)
    openHand = { key = "SPACE", uiText = "Boşluk" },
    -- 101: toggle the panel showing tiles laid down on the table (open by default)
    tableMelds = { key = "B", uiText = "B" },
    -- Normal okey: show the indicator tile on your first turn (opponents lose 1 point)
    showIndicator = { key = "G", uiText = "G" },
    -- Toggle the "How to Play" help panel
    howToPlay = { key = "I", uiText = "i" },
}

config.langs = {}
config.debug = false
