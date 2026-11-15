Config = Config or {}

Config.LightsOut = {
    description = "Işıklara tıklayarak onları ve komşularını aç/kapat. Süre bitmeden tüm ızgarayı söndür.",
    numberOfStages = 1, -- Total stages to complete

    timeLimit = 30,     -- Time per stage in seconds (0 disables the timer)
    gridSize = 4,       -- Board size N x N (3-7)
    scrambleMoves = 5,  -- Random plus-presses used to build each board
}
