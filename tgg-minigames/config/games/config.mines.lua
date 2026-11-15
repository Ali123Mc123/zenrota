Config = Config or {}

Config.Mines = {
    description = "Mayınların yerlerini hatırla ve kaybolduktan sonra hepsini bul!",
    numberOfStages = 3, -- Total stages to complete

    gridSize = 5,       -- Grid size
    minesCount = 5,     -- Mines to remember
    previewTime = 4,    -- Preview time in seconds
    stageTime = 12,     -- Time to find mines in seconds
    maxFails = 2,       -- Maximum wrong clicks allowed
}
