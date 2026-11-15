config.howtoplay = config.howtoplay or {}
config.howtoplay.en = config.howtoplay.en or {}
config.howtoplay.en.doubled_101 = {
    title = "Doubled 101",
    summary = "A 101 Okey variant with a rising opening threshold. Each player who opens raises the bar for those who haven't opened yet.",
    sections = {
        {
            heading = "Base Rules",
            body = "All standard 101 Okey rules apply: opening, lay-off, drawing from the left, the işlek penalty. Only the opening threshold is dynamic.",
        },
        {
            heading = "Dynamic Opening Threshold",
            body = "The series/group threshold starts at 101. When someone opens, the new threshold becomes their score plus 1, so the next player must beat it.",
        },
        {
            heading = "Pair Opening Threshold",
            body = "The pair threshold starts at 5 pairs. When someone opens with pairs, the next pair opener needs at least one more pair.",
        },
        {
            heading = "Strategy",
            body = "Opening early is an advantage because later opponents face a higher bar. But if your hand can't reach the higher score, switch to the pair opening route.",
        },
        {
            heading = "Scoring",
            body = "Same as 101. The finisher writes -101. Opened losers write the total of the tiles left in hand, players who never opened write 202. A loser who opened with pairs writes double. Finishing by discarding the Okey, finishing with pairs or finishing from hand (opening and finishing in one go) doubles every score, two of these together quadruple it. If the deck runs out there is no winner: opened players write their hand, the rest write 202. Low score is better.",
        },
    },
}
