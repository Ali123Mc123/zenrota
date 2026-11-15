Config = Config or {}

Config.Dash = {
    description = "Renkli boşluklardan geçerek okunu düşen çizgilerin arasından geçir!",
    numberOfStages = 3,   -- Total stages to complete
    lineSpeed = 0.5,      -- Speed of falling lines
    openingSize = 30,     -- Size of opening to pass through
    movementSpeed = 0.5,  -- Player movement speed
    linesRequired = 25,   -- Lines to pass through per stage
    lineSpawnDelay = 500, -- Delay between line spawns in ms (Also space between lines)
}
