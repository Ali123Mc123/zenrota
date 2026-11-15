Config = Config or {}

Config.Untangle = {
    description = "Karışık okları doğru sırayla tıklayarak tahtayı temizle",
    numberOfStages = 2,   -- Total boards to clear
    instantFail = false,  -- Fail on the first blocked click

    gridSize = 12,        -- Board size in cells (5-12)
    difficulty = 10,      -- Tangle difficulty (1-10) - raises the arrow count, how long and bendy they are and how many start out blocked
    timeLimit = 45,       -- Time per board in seconds (0 disables the timer)
    penaltySeconds = 4,   -- Time penalty for clicking an arrow with a blocked path
}
