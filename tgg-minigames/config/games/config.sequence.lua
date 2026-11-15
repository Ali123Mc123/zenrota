Config = Config or {}

Config.Sequence = {
    description = "Ok tuşlarıyla gezinerek ızgaradaki belirli sembol dizilerini bul",
    numberOfStages = 3,  -- Total stages to complete
    instantFail = false, -- Fail on wrong answer

    timeLimit = 30,      -- Time per stage in seconds
    penaltySeconds = 2,  -- Time penalty for wrong answer
    sequenceLength = 4,  -- Symbols in sequence
    scrambleCount = 2,   -- Grid scrambles during stage

    enabledSymbolSets = {
        shapeSide = true, -- Shape side symbols
        dot2x3 = true,    -- Dot 2x3 symbols
        dot2x4 = true,    -- Dot 2x4 symbols
        dominoV = true,   -- Domino vertical symbols
        dominoH = true,   -- Domino horizontal symbols
        arrows = true,    -- Arrows symbols
        letters = true,   -- Letters symbols
        numbers = true,   -- Numbers symbols
    },

    symbolSets = {
        shapeSide = { "◧", "◨", "⬒", "⬓", "◩", "◪", "■", "🞕", "◐", "◑", "◓", "◒", "◔", "◕", "●", "◉" },
        dot2x3 = { "⠞", "⠮", "⠫", "⠝", "⠳", "⠞", "⠧", "⠼", "⠾", "⠯", "⠽", "⠷", "⠾", "⠟", "⠻", "⠿", "⠗", "⠕" },
        dot2x4 = { "⡻", "⡾", "⢗", "⢯", "⢿", "⣇", "⣏", "⣟", "⣧", "⣯", "⣷", "⣿", "⡾", "⣹", "⣻", "⣼", "⣽", "⡮" },
        dominoV = { "🁪", "🁱", "🁸", "🁿", "🂆", "🂍", "🁤", "🁥", "🁦", "🁧", "🁨", "🁩", "🁫", "🁳", "🁻", "🂃", "🂋", "🂓" },
        dominoH = { "🀲", "🀳", "🀴", "🀵", "🀶", "🀷", "🀸", "🀿", "🁆", "🁍", "🁔", "🁛", "🀹", "🁁", "🁉", "🁑", "🁙", "🁡" },
        arrows = { "⇐", "⇒", "⇑", "⇓", "⇖", "⇘", "⇗", "⇙", "⇔", "⇕" },
        letters = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" },
        numbers = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" },
    },
}
