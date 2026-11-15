Config = Config or {}

Config.PinLock = {
    name = 'Pin Lock',
    description = "Yerçekimine karşı koymak için dokun ve her pimi gizli doğru noktasına yerleştir!",

    numberOfPins = 8,      -- Amount of pins that must be set (2-8)
    pushStrength = 0.6,    -- Upward impulse added per tap (channel heights per second)
    gravity = 3.0,         -- Downward pull applied constantly (channel heights per second squared)
    zoneTolerance = 7,     -- Half size of the hidden sweet spot as a percentage of the channel
    instantFail = false,   -- Fail the whole game on the first wrong set press
    maxAttempts = 3,       -- Wrong set presses allowed when instantFail is false
    gameTime = 20,         -- Time in seconds to set every pin (0 disables the timer)
    minimalMode = false,   -- Hide container background and border
}
