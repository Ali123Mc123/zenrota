Config = Config or {}

Config.Flappy = {
    description = "Kanat çırpmak için boşluğa basarak kuşunu yatay borular arasından geçir ve havada kal!",
    numberOfStages = 3, -- Total stages to complete
    jumpPower = 0.8,    -- Jump power multiplier
    fallSpeed = 0.025,  -- Fall speed per frame
    scrollSpeed = 0.5,  -- Pipe scroll speed
    openingSize = 120,  -- Opening size between pipes
    pipeSpacing = 350,  -- Distance between pipes
    pipesRequired = 8,  -- Pipes to pass through per stage
}
