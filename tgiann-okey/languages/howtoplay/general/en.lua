config.howtoplay = config.howtoplay or {}
config.howtoplay.en = config.howtoplay.en or {}
config.howtoplay.en.general = {
    title = "General",
    summary = "Core controls and tile management for the okey script. Switch to a mode tab on the right for game rules.",
    sections = {
        {
            heading = "Keys",
            body =
            "• E: Sit down at a free chair you're standing next to.\n• X: Stand up (leaving mid-round forfeits the round).\n• V: Toggle camera mode: game camera ↔ seated camera.\n• Caps Lock: Open/close the scoreboard.\n• I: Open/close this help panel.\n• B: In 101 modes, open/close the panel listing all melds laid down on the table.\n• Space: In 101 modes, hold to auto-open your hand with the best valid combination.\n• R (admin only): Hold to force-restart the round.",
        },
        {
            heading = "Tile Management",
            body =
            "• Left Click + Drag: Pick up a single tile and drop it on another slot/zone.\n• Right Click: Flip the hovered hand tile face up/down (e.g. mark the okey tile).\n• Ctrl + Left Click: Multi-select tiles (blue outline). Ctrl-click again to deselect.\n• Multi-select drag: With 2+ tiles selected, drag onto the green marker in your own meld zone to lay a new meld.",
        },
        {
            heading = "Discard & Draw",
            body =
            "• When it's your turn, either take the last tile from the player on your left's discard pile or draw from the pool (the closed deck in the middle).\n• To draw, left-click the relevant tile.\n• To discard, drag a tile from your hand to your right corner (green circle marker).",
        },
        {
            heading = "Lay-off in 101",
            body =
            "• After opening your hand (Space), drag a single tile over a meld already on the table. The meld glows green if your tile fits, red if it doesn't.\n• Drop on a green-outlined meld to lay your tile off onto it.\n• You can lay off onto your own melds or your opponents' (as long as the rules allow).",
        },
        {
            heading = "Okey Swap (Take Okey from Table)",
            body =
            "• If a meld on the table has the okey tile and you hold the actual tile it's substituting for, you can give your tile and take the okey.\n• A cyan-outlined meld means a valid swap.\n• On drop, your tile goes into the meld and the okey comes into your hand.\n• IMPORTANT: You must lay off the taken okey in the same turn. While holding the okey, you CAN'T discard ANY tile (not the okey, not any other tile). Your only way out is to lay it off.",
        },
        {
            heading = "Top-down Camera",
            body =
            "When you hold a tile and bring it close to the table center, the camera automatically switches to a top-down view. The view stays until you drop the tile, handy for clearly seeing all the melds and stacks.",
        },
    },
}
