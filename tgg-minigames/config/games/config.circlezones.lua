Config = Config or {}

Config.CircleZones = {
    description = "Hızlı tepki beceri testi - parça hedef bölgelere ulaştığında tıkla!",

    rotationTime = 4,    -- Time for full rotation in seconds
    minTargetSize = 20,  -- Minimum target zone size in degrees
    maxTargetSize = 40,  -- Maximum target zone size in degrees
    numberOfTargets = 3, -- Number of target zones (max 25)
    penaltyPercent = 5,  -- Percentage to move back on wrong click (0-100)
}
