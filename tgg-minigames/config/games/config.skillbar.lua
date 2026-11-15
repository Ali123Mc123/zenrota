Config = Config or {}

Config.SkillBar = {
    description = "Hareketli parça hedef bölgeye ulaştığında tıkla!",

    segmentSpeed = 80,   -- Speed of moving segment (percentage per second)
    targetZoneSize = 8,  -- Size of target zone (percentage of bar width)
    hitsRequired = 5,    -- Number of successful hits to complete the game
    minimalMode = false, -- Hide container background and border
}
