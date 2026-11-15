Config = Config or {}

Config.Unlocked = {
    description = "Çemberleri döndürerek renkli noktaları kendi renkteki çizgilerle eşleştir",
    numberOfStages = 3,        -- Total stages to complete
    instantFail = false,       -- Fail on wrong answer

    totalCircles = 4,          -- Number of circles
    emptySpacePercentage = 30, -- Empty space percentage
    timerPerStage = 45,        -- Time per stage in seconds
    penaltySeconds = 3,        -- Time penalty for wrong answer
}
