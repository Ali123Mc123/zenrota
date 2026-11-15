Config = Config or {}

Config.Echo = {
    description = "Hafıza oyunu - renkli kutuları say ve gördüklerinle ilgili soruları cevapla",
    numberOfStages = 3,                -- Total stages to complete

    gridSize = 8,                      -- Grid size
    timePerStage = 12,                 -- Time per stage in seconds
    colorRanges = {
        red = { min = 2, max = 5 },    -- Minimum and maximum number of red boxes
        green = { min = 2, max = 5 },  -- Minimum and maximum number of green boxes
        blue = { min = 2, max = 5 },   -- Minimum and maximum number of blue boxes
        yellow = { min = 2, max = 5 }, -- Minimum and maximum number of yellow boxes
    },
}
