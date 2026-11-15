Config = Config or {}

Config.Numbers = {
    description = "Sayılara artan sırayla (1, 2, 3 vb.) olabildiğince hızlı tıkla!",
    numberOfStages = 3, -- Total stages to complete
    instantFail = true, -- Fail on wrong number

    gridSize = 4,       -- Grid size
    timePerStage = 30,  -- Time per stage in seconds
    scrambleCount = 3,  -- Grid scrambles during stage
    penaltySeconds = 3, -- Time penalty for wrong clicks
}
