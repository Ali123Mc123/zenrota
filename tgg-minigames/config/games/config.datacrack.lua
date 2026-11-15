Config = Config or {}

Config.DataCrack = {
    description = "Her hareketli sütunun boşluğu orta çizgiye geldiğinde onu kilitle",
    numberOfStages = 3,      -- Total boards to complete

    numberOfSegments = 8,    -- Columns that must be locked left to right
    segmentSpeed = 70,       -- Peak travel as percent of play-area height per second
    lineWidth = 35,          -- Thickness of the center line in pixels
    timeLimit = 20,          -- Time per stage in seconds (0 disables the timer)
    instantFail = false,     -- Fail the run on the first mistimed press
    penaltySeconds = 3,      -- Time penalty per miss when instantFail is off
}
