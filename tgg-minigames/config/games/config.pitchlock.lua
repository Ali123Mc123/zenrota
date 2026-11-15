Config = Config or {}

Config.PitchLock = {
    description = "İşitsel hafıza eşleştirme - bir tonu dinle, sonra kulağınla yeniden oluştur",
    numberOfStages = 3,                -- Total stages to complete

    minFrequency = 100,                 -- Minimum frequency in Hz
    maxFrequency = 2000,               -- Maximum frequency in Hz
    listenDuration = 1500,             -- Target tone play time in ms
    timePerStage = 10000,              -- Total time per stage in ms
    maxScorePerStage = 10,             -- Maximum score per stage
    passingMarginPercent = 20,         -- Percentage off maximum possible score allowed to still pass (e.g. 20 means you can lose up to 20% points)
    maxCentsOff = 200,                 -- Room for error in musical pitch (Cents). E.g. 200 = 2 semitones. A guess further than this scores 0 points. Increase to make the game more forgiving.
}
