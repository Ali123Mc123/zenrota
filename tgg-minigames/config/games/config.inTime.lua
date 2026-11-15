Config = Config or {}

Config.InTime = {
    description = "Doğru tuşlara basarak düşen blokları yok et - ilerlemek için tüm blokları tamamla!",
    numberOfStages = 3,  -- Total stages to complete
    blocksPerStage = 25, -- Blocks to destroy per stage
    spawnFrequency = 3,  -- Spawn frequency (1=slow, 5=fast)
    fallSpeed = 1.75,    -- Block fall speed
    useLetters = true,   -- Enable letter keys
    useNumbers = true,   -- Enable number keys
}
