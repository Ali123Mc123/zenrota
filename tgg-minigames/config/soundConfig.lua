Config = Config or {}

-- Sound Configuration
-- Controls whether sounds are enabled for minigames
Config.SoundEnabled = true -- Set to false to disable all minigame sounds

-- Sound Volume (0.0 to 1.0)
Config.SoundVolume = 0.5

-- Individual sound settings
Config.Sounds = {
    success = true, -- Play sound on stage completion
    fail = true,    -- Play sound on failed game completion
    click = true,   -- Play sound on meaningful interactions (clicks, key presses)
    penalty = true, -- Play sound on wrong action when not instant fail (border flash)
}
