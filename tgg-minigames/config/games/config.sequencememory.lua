Config = Config or {}

Config.SequenceMemory = {
    description = "Vurgulanan kutuların sırasını izle, sonra aynı sırayla onlara tıkla. Her turda hatırlanacak kutu sayısı artar.",
    numberOfStages = 3,   -- Total stages to complete
    maxBoxesPerStage = 6, -- Max boxes to remember
    revealTime = 400,     -- Reveal time per box in ms
    gridSize = 4,         -- Grid size
    timePerStage = 60,    -- Time per stage in seconds
}
