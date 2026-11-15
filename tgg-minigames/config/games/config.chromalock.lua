Config = Config or {}

Config.ChromaLock = {
    name = 'Chroma Lock',
    description = "Renk hafızası eşleştirme - bir renge bak, sonra onu yeniden oluştur",
    numberOfStages = 3,                -- Total stages to complete
    
    listenDuration = 1500,             -- Target color show time in ms (keeping same name as PitchLock for consistency or similar functionality, wait let's use 'viewDuration' or stick to general duration concept, let's use viewDuration but config will fall back)
    viewDuration = 1500,               -- Target color show time in ms
    timePerStage = 10000,              -- Total time per stage in ms
    maxScorePerStage = 10,             -- Maximum score per stage
    passingMarginPercent = 20,         -- Percentage off maximum possible score allowed to still pass (e.g. 20 means you can lose up to 20% points)
}
