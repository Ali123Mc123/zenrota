config.howtoplay = config.howtoplay or {}
config.howtoplay.en = config.howtoplay.en or {}
config.howtoplay.en["101"] = {
    title = "101 Okey",
    summary = "The point-based version of Turkish Okey. To open your hand, you must lay down melds totaling at least 101 points.",
    sections = {
        {
            heading = "Opening Rule",
            body = "To open, you must lay down at least 101 points worth of runs/groups in a single move. Alternatively, you can open with at least 5 distinct pairs.",
        },
        {
            heading = "Meld Values",
            body = "A meld's value equals the sum of the face values of its tiles. The Okey and the fake joker take the value of the tile they replace. Example: red 11-12-13 = 36 points.",
        },
        {
            heading = "Drawing from Left",
            body = "You can take the left player's discarded tile. If you haven't opened yet you must open that same turn; if you try to discard without opening, the tile goes back and you get +101.",
        },
        {
            heading = "Lay-off",
            body = "Once opened, you can attach tiles from your hand onto melds already on the table. You may add at most 2 tiles to the same meld in a single turn. You can't empty your hand by laying off, you finish by discarding your last tile.",
        },
        {
            heading = "Penalty (İşlek)",
            body = "If you discard a tile that could have been laid off, you get +101. Discarding the Okey is also +101, unless it's your last tile and you finish with it.",
        },
        {
            heading = "Scoring",
            body = "The finisher writes -101. Opened losers write the total of the tiles left in hand, players who never opened write 202. A loser who opened with pairs writes double. Finishing by discarding the Okey, finishing with pairs or finishing from hand (opening and finishing in one go) doubles every score, two of these together quadruple it. If the deck runs out there is no winner: opened players write their hand, the rest write 202. Low score is better.",
        },
    },
}
