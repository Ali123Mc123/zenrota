-- English (en) — prompt_arcade_games
-- To add a language: copy this file to locales/<code>.lua, translate the VALUES only
-- (never the keys), then set Arc.Config.language = '<code>' in config.lua.
-- %s / %d are placeholders — keep them, and keep them in the same order.
return {
    -- ── Cabinet names (shown in the pre-game menu + leaderboard header) ──────────────
    title_space    = 'Space Monkey',
    title_wizard   = "The Wizard's Ruin",
    title_badlands = 'Badlands Revenge',
    title_rockets  = 'Race and Chase: Crotch Rockets',
    title_truckin  = "Race and Chase: Get Truckin'",
    title_street   = 'Race and Chase: Street Legal',
    title_love     = 'Love Tester',
    title_claw     = 'Claw Machine',
    title_fortune  = 'Nazar the Fortune Teller',
    title_strength = 'Strength Tester',

    -- ── Interaction labels (ox_target / qb-target prompt, and the built-in Text UI) ──
    target_space    = 'Play Space Monkey',
    target_wizard   = "Play The Wizard's Ruin",
    target_badlands = 'Play Badlands Revenge',
    target_rockets  = 'Play Crotch Rockets',
    target_truckin  = "Play Get Truckin'",
    target_street   = 'Play Street Legal',
    target_love     = 'Test your love',
    target_claw     = 'Play the claw machine',
    target_fortune  = 'Ask Nazar your fortune',
    target_strength = 'Test your strength',

    -- ── Text UI (only used when no ox_target / qb-target is installed) ───────────────
    -- %s = the interaction label above. Keep it.
    textui_prompt = '[E]  %s',

    -- ── Pre-game menu drawn on the cabinet ──────────────────────────────────────────
    menu_arcade   = 'ARCADE',
    menu_play     = '[E] PLAY',
    menu_playSolo = '[E] PLAY SOLO',
    menu_volume   = '[Up] / [Down]  VOLUME  %d%%',
    menu_leave    = '[Backspace] LEAVE',
    menu_waitCoop = '...or just wait here — a 2nd player can join this cabinet for co-op',

    -- ── Love Tester ─────────────────────────────────────────────────────────────────
    love_result   = 'Love Tester:  %s',
    love_tookSide = 'Love Tester — you took the %s side. Waiting for a partner...',
    love_sideLeft  = 'LEFT',
    love_sideRight = 'RIGHT',
    love_walkUp   = 'Walk up to a Love Tester to play.',
    -- the cabinet's cold -> hot scale (exactly 10, coldest first)
    loveRatings = {
        'ICE COLD', 'COLD SHOULDER', 'THAW OUT', 'CLAMMY', 'WARMER',
        'FLUSHED', "GETTIN' STEAMY", 'BURNING LOINS', "HOT N' HEAVY", "SIZZLIN'",
    },

    -- ── Nazar the Fortune Teller ────────────────────────────────────────────────────
    -- (The fortune TEXTS themselves are edited in config.lua -> Arc.Cabinets.fortune.fortunes)
    fortune_stir   = 'Nazar shudders... the spirits stir.',
    fortune_speaks = 'Nazar speaks:  %s',

    -- ── Strength Tester ─────────────────────────────────────────────────────────────
    strength_result = 'Strength Tester:  %s  (%d)',
    -- exactly 4, weakest first
    strengthTiers = { 'PUNY', 'TOUGH GUY', 'HE-MAN', 'RING THE BELL!' },

    -- ── Pay-per-play (only shown when payment.enabled) ───────────────────────────────
    menu_price   = '  —  $%d',                  -- appended to the PLAY label
    textui_price = '[E]  %s  ($%d)',
    pay_denied   = "You need $%d to play.",
    pay_error    = 'Payment failed — try again.',
    play_denied  = "You can't start that from here.",
}
