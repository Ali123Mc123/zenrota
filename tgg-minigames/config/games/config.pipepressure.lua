Config = Config or {}

Config.PipePressure = {
    description = "Geri sayım sırasında boru parçalarını döndür, sonra akışın baştan sona ilerleyişini izle",
    numberOfStages = 3,  -- Total stages to complete

    gridSize = 6,        -- Grid size
    flowSpeed = 80,      -- Flow animation speed
    delayTime = 20,      -- Time before flow starts in seconds
    fluidType = 'water', -- Fluid type (water or gas - changes the color)
}
