Config = Config or {}

Config.Fingerprint = {
    description = "5 parçanın hepsini doğru hizalayarak parmak izini birleştir!",
    numberOfStages = 3, -- Total stages to complete

    timePerStage = 60,  -- Time per stage in seconds
    ringCount = 8,      -- Ridge rings per print (5-12) - more rings means thinner lines
    minArcSpan = 25,    -- Shortest ridge kept, in degrees
    maxArcSpan = 90,    -- Longest ridge before it is broken up, in degrees
    optionsPerRow = 3,  -- Pieces to pick from per strip (2-8) - the bottom two strips get 2 more
}
