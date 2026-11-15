config.howtoplay = config.howtoplay or {}
config.howtoplay.en = config.howtoplay.en or {}
config.howtoplay.en.normal = {
    title = "Normal Okey",
    summary = "Classic Turkish Okey. Every player starts with 20 points; the first player to finish wins the round and the others lose points.",
    sections = {
        {
            heading = "Goal",
            body = "Be the first to arrange your 14 tiles into valid melds (groups or runs) and discard your 15th tile to finish.",
        },
        {
            heading = "Meld Types",
            body = "Run: 3+ consecutive tiles of the same color (e.g. red 5-6-7). Group: 3 or 4 tiles of the same number in different colors. The Okey tile acts as a wildcard joker.",
        },
        {
            heading = "Turn Flow",
            body = "On your turn: either draw the last tile discarded by the player on your left or draw from the deck. Then discard one tile to your right. Turn passes to the player on your right.",
        },
        {
            heading = "Finish Types",
            body = "• Normal finish: opponents -2\n• Finish by discarding the Okey: opponents -4\n• Pair finish (7 pairs): opponents -4\n• Pair finish with the Okey: opponents -8",
        },
        {
            heading = "Scoring",
            body = "Everyone starts at 20. The round winner keeps their score, losers lose points based on the finish type. A player at 0 or below is out. If you were dealt the same tile as the indicator, press the show indicator key before your first discard to show it and your opponents lose 1 point. If the deck runs out the round is a draw and no points change.",
        },
    },
}
