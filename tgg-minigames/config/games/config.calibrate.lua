Config = Config or {}

Config.Calibrate = {
    description = "Aynı uzunluktaki çizgiler üst üste gelene kadar kadranları kaydır",
    numberOfStages = 2,   -- Total sets of dials to calibrate

    difficulty = 3,       -- 1 = one line per dial, 2 = three lines (one decoy), 3 = five lines (two decoys)
    timeLimit = 30,       -- Time per stage in seconds (0 disables the timer)
}
