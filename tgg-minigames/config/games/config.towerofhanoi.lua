Config = Config or {}

Config.TowerOfHanoi = {
    description = "Tüm diskleri en sağdaki kuleye taşı. Aynı anda yalnızca bir disk taşı. Büyük disk küçük diskin üzerine konamaz.",
    numberOfStages = 3, -- Total stages to complete
    numberOfDisks = 3,  -- Disks to move
    timePerStage = 120, -- Time per stage in seconds
}
