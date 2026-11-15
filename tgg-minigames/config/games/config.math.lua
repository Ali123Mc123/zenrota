Config = Config or {}

Config.Math = {
    description = "Matematiksel ifadeleri karşılaştır - hesapla ve ikincinin birinciden büyük, küçük ya da eşit olduğunu seç",
    numberOfStages = 3,                        -- Total stages to complete
    instantFail = false,                       -- Fail on wrong answer

    timeLimit = 20,                            -- Time per stage in seconds
    expressionsPerRound = 5,                   -- Expressions per round
    allowedOperators = { '+', '-', '*', '/' }, -- Allowed operators for the expressions
    minResult = 2,                             -- Minimum expression result
    maxResult = 25,                            -- Maximum expression result
    maxDifference = 5,                         -- Max difference between expressions
    penaltySeconds = 3,                        -- Time penalty for wrong answer
}
