Config = Config or {}

Config.Typix = {
    description = "Klasik kelime tahmin oyunu - süre bitmeden 5 harfli kelimeyi en fazla 6 denemede bul!",
    numberOfStages = 3,    -- Total stages to complete
    timeLimit = 240,       -- Time per stage in seconds
    wordLists = {
        variety = false,   -- Use variety word list (too hard to guess - don't recommend using it)
        animals = false,   -- Use animals word list
        food = false,      -- Use food word list
        tech = false,      -- Use tech word list
        cities = true,     -- Use cities word list
        countries = false, -- Use countries word list
        math = false,      -- Use math word list
        tools = false,     -- Use tools word list
        nsfw = false,      -- Use NSFW word list
    },
}
