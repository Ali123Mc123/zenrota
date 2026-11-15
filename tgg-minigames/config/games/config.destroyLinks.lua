Config = Config or {}

Config.DestroyLinks = {
    description = "İşaret yönlerini eşleştirerek kulenin altındaki blokları yok et!",
    numberOfStages = 3,  -- Total stages to complete
    instantFail = false, -- Fail on wrong selection

    timeLimit = 8,       -- Time per stage in seconds
    targetBlocks = 30,   -- Blocks to destroy per stage
    penaltySeconds = 1,  -- Time penalty for wrong selection
}
