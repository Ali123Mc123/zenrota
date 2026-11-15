Config = Config or {}

Config.Resonance = {
    description = "Dalgan hedef dalgayla örtüşene kadar onu üç kaydırıcıyla şekillendir",
    numberOfStages = 1,   -- Total waves that must be matched

    tolerance = 10,       -- Percent of a slider's travel that still counts as matched (higher is easier)
    timeLimit = 30,       -- Time per stage in seconds (0 disables the timer)
}
