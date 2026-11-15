Config = Config or {}

Config.Stacker = {
    description = "Her hareketli sırayı platforma bırakarak dikdörtgenleri hedef çizgisine kadar üst üste diz",
    numberOfStages = 2,      -- Total stacks to complete

    timeLimit = 20,          -- Time per stage in seconds (0 disables the timer)
    rowsToGoal = 12,         -- Moving rows to place; the last sits flush with the goal
    startWidthPercent = 35,  -- Starting platform width as a percent of the play area
    segmentSpeed = 80,       -- Horizontal speed as percent of play-area width per second
    speedUpEachRow = false,  -- If true, speed increases after each successful drop
    speedIncrease = 12,      -- Extra percent-per-second added per placed row when speedUpEachRow is on
}
