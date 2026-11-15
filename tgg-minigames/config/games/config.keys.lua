Config = Config or {}

Config.Keys = {
    description = "Tuşlara soldan sağa, satır satır doğru sırayla bas!",
    numberOfStages = 3, -- Total stages to complete
    instantFail = true, -- Fail on wrong key

    useLetters = true,  -- Enable letter keys
    useNumbers = true,  -- Enable number keys

    timePerStage = 35,  -- Time per stage in seconds
    numberOfKeys = 12,  -- Keys to press per stage
    penaltySeconds = 3, -- Time penalty for mistakes
}
