-- Wish trees: a tree or a board placed in /collegeadmin; anyone allowed hangs a short card, everyone nearby sees it.
-- Students never see who wrote a card; moderators do. Needs the notes module (the card is written in its editor).
Config.Wishes = {
    Access = 'role:college:student, role:college:member', -- who may hang a wish (reading is open to all)
    Moderators = 'role:college:principal, role:college:counselor', -- who may hide and delete and see authors (admins always)

    PerPlayer = 999,          -- live wishes one player may have on all trees (TEMP testing; 2 when the school opens)
    CooldownMinutes = 0,      -- between two wishes of one player (TEMP testing; 30 when the school opens)
    LifetimeDays = 7,         -- a card falls off after this
    AnyTime = true,           -- trees take wishes at any hour, even those set to school hours
    WhenFull = 'oldest',      -- a full tree: 'oldest' drops its oldest card, 'closed' takes no more
    RequireItem = false,      -- an item name (e.g. 'wish_card') used up per wish, or false
    RequireApproval = false,  -- true: cards wait for a moderator before they show

    -- The card: one short page in the notebook's editor.
    MaxChars = 140,
    AllowDrawing = true,
    MaxStrokes = 60,
    MaxPoints = 2500,
    Colors = { 'cream', 'pink', 'blue', 'yellow', 'green' }, -- colours a writer may pick (each its own card model, see Cards)

    -- Your word list (lower case); case and accents do not matter, a word matches the start of a written word.
    Filter = {
        Words = {},
        Action = 'reject',    -- 'reject' tells the writer, 'review' sends the card to the moderators
    },
    Reports = { AutoHide = 3 }, -- reports that hide a card until a moderator looks

    MeToo = true,                       -- readers may add a "me too" to a card; the count shows on the card
    Fulfilled = { Color = 'gold', ExtraDays = 7 }, -- the writer marks a wish come true: it turns this colour and stays longer
    Featured = { Min = 3, Days = 7 },   -- the wish of the week: most "me too"s (at least Min) among the cards of the last Days

    StreamDistance = 40.0,
    TargetDistance = 2.5,
    TargetSphere = { radius = 3.2, height = 1.9 }, -- a tree is targeted on a sphere under its crown, out to its branch tips

    -- Hanging a card: a reach up for a high place (more than HighAbove metres above the feet), a hand forward for a low one;
    -- the card shows on the tree ShowAfterMs into the reach.
    Hang = {
        HighAbove = 1.5,
        ShowAfterMs = 1200,
        High = { Dict = 'missheistfbisetup1', Name = 'unlock_loop_janitor', Ms = 1800 },
        Low = { Dict = 'amb@prop_human_parking_meter@male@base', Name = 'base', Ms = 1800 },
    },
    Retention = { Days = 30 }, -- removed and fallen cards are deleted after this
    Commands = { places = 'wishplaces' }, -- admins: where each tree takes its card places from

    -- Wish night: a moderator lets every card of a tree go from the staff tablet; the cards rise and fade with this effect.
    Release = { Asset = 'scr_indep_fireworks', Effect = 'scr_indep_firework_trailburst', Scale = 0.25, RiseSeconds = 6 },

    -- Board slots: a grid on the board's face; Lift is the height of the face's center above the model's origin.
    Board = { Cols = 6, Rows = 4, Width = 2.2, Height = 1.5, Depth = 0.03, Lift = 0.0 },

    -- Models, the default first (the first the game has). A tree may list its card places (offsets from the model's
    -- origin, { x, y, z }); places set on a tree in /collegeadmin win; a tree with neither gets a ring of places under its
    -- crown (Ring, or the model's own ring).
    Ring = { Count = 16, Radius = 1.0, Low = 1.45, High = 2.05 },
    Trees = {
        { model = 'daddy_school_wish_tree', lift = 0.06, slots = { -- 96 places under its branches (tools/props/hang_slots.py); lift raises every card (m)
            { x = -1.829, y = -0.151, z = 2.414 },
            { x = -1.599, y = -1.135, z = 2.055 },
            { x = -1.678, y = -1.307, z = 2.288 },
            { x = -1.246, y = -1.005, z = 2.437 },
            { x = -1.12, y = -0.909, z = 2.082 },
            { x = -2.095, y = -1.87, z = 2.103 },
            { x = -2.284, y = -2.042, z = 2.268 },
            { x = -1.748, y = -1.646, z = 1.972 },
            { x = -1.201, y = -1.174, z = 1.962 },
            { x = -1.384, y = -1.415, z = 1.936 },
            { x = -1.493, y = -1.595, z = 2.156 },
            { x = -1.499, y = -1.771, z = 2.438 },
            { x = -0.959, y = -1.707, z = 2.439 },
            { x = -0.745, y = -1.681, z = 2.228 },
            { x = -0.585, y = -2.036, z = 1.901 },
            { x = -0.626, y = -2.456, z = 1.955 },
            { x = -0.664, y = -2.831, z = 2.142 },
            { x = -0.402, y = -1.796, z = 1.922 },
            { x = -0.308, y = -1.472, z = 1.949 },
            { x = -0.437, y = -2.284, z = 2.114 },
            { x = -0.319, y = -2.442, z = 2.394 },
            { x = 0.48, y = -1.816, z = 2.35 },
            { x = 0.797, y = -2.938, z = 1.879 },
            { x = 0.787, y = -2.628, z = 1.778 },
            { x = 0.952, y = -2.841, z = 2.142 },
            { x = 0.778, y = -2.315, z = 1.771 },
            { x = 0.75, y = -1.936, z = 1.84 },
            { x = 0.971, y = -2.313, z = 2.127 },
            { x = 0.73, y = -1.636, z = 1.905 },
            { x = 1.121, y = -2.407, z = 2.37 },
            { x = 0.746, y = -1.336, z = 1.993 },
            { x = 1.351, y = -2.166, z = 2.129 },
            { x = 1.014, y = -1.624, z = 2.045 },
            { x = 1.211, y = -1.873, z = 2.071 },
            { x = 2.074, y = -1.536, z = 2.343 },
            { x = 2.108, y = -1.296, z = 2.104 },
            { x = 2.108, y = -1.042, z = 1.875 },
            { x = 3.04, y = -1.389, z = 2.215 },
            { x = 2.796, y = -1.236, z = 1.768 },
            { x = 2.531, y = -1.076, z = 1.666 },
            { x = 2.277, y = -0.906, z = 1.666 },
            { x = 1.976, y = -0.688, z = 1.735 },
            { x = 1.748, y = -0.497, z = 1.78 },
            { x = 1.436, y = -0.28, z = 1.785 },
            { x = 1.945, y = -0.353, z = 2.315 },
            { x = 1.738, y = 0.311, z = 2.408 },
            { x = 3.002, y = 0.682, z = 2.009 },
            { x = 2.73, y = 0.68, z = 1.876 },
            { x = 1.58, y = 0.438, z = 2.107 },
            { x = 2.303, y = 0.651, z = 1.853 },
            { x = 1.884, y = 0.62, z = 1.909 },
            { x = 2.287, y = 0.806, z = 2.243 },
            { x = 2.065, y = 1.144, z = 2.334 },
            { x = 1.733, y = 1.035, z = 1.951 },
            { x = 2.026, y = 1.325, z = 1.868 },
            { x = 1.388, y = 0.988, z = 1.978 },
            { x = 2.225, y = 1.594, z = 1.866 },
            { x = 2.371, y = 1.899, z = 1.947 },
            { x = 1.465, y = 1.28, z = 2.367 },
            { x = 0.552, y = 1.678, z = 2.274 },
            { x = 0.797, y = 3.2, z = 2.374 },
            { x = 0.501, y = 2.019, z = 1.984 },
            { x = 0.362, y = 1.712, z = 2.035 },
            { x = 0.507, y = 2.422, z = 1.886 },
            { x = 0.516, y = 2.756, z = 1.902 },
            { x = 0.493, y = 3.087, z = 2.003 },
            { x = 0.294, y = 2.289, z = 2.429 },
            { x = 0.152, y = 2.657, z = 2.38 },
            { x = 0.104, y = 2.06, z = 2.137 },
            { x = 0.061, y = 2.433, z = 2.16 },
            { x = -1.358, y = 2.131, z = 2.402 },
            { x = -0.99, y = 1.36, z = 1.85 },
            { x = -1.443, y = 1.941, z = 2.091 },
            { x = -1.241, y = 1.562, z = 1.828 },
            { x = -1.547, y = 1.812, z = 1.743 },
            { x = -1.792, y = 2.031, z = 1.713 },
            { x = -2.033, y = 2.265, z = 1.797 },
            { x = -1.502, y = 1.308, z = 1.977 },
            { x = -1.21, y = 0.95, z = 1.841 },
            { x = -2.458, y = 1.914, z = 2.012 },
            { x = -1.142, y = 0.877, z = 2.342 },
            { x = -2.282, y = 1.634, z = 1.863 },
            { x = -2.075, y = 1.369, z = 1.775 },
            { x = -1.471, y = 0.867, z = 2.049 },
            { x = -1.817, y = 1.043, z = 1.739 },
            { x = -2.035, y = 1.076, z = 2.201 },
            { x = -1.542, y = 0.727, z = 1.748 },
            { x = -2.324, y = 0.592, z = 2.438 },
            { x = -2.265, y = 0.382, z = 2.202 },
            { x = -1.803, y = 0.205, z = 1.862 },
            { x = -1.513, y = 0.124, z = 1.863 },
            { x = -2.45, y = 0.14, z = 1.872 },
            { x = -2.86, y = 0.131, z = 2.005 },
            { x = -3.132, y = 0.124, z = 2.132 },
            { x = -2.157, y = 0.074, z = 1.847 },
            { x = -1.732, y = 0.023, z = 2.114 },
        } },
        { model = 'prop_tree_birch_05', ring = { Count = 16, Radius = 1.1, Low = 1.5, High = 2.1 } },
        { model = 'h4_prop_tree_umbrella_sml_01', ring = { Count = 14, Radius = 0.9, Low = 1.4, High = 1.9 } },
        { model = 'prop_plant_int_03a', ring = { Count = 8, Radius = 0.45, Low = 0.9, High = 1.2 } },
    },
    Boards = { 'prop_cork_board' },
    -- Card models, the first the game has; %s is the card's colour (one model per colour).
    Cards = {
        tree = { 'daddy_school_wish_tag_%s', 'prop_amanda_note_01' },
        board = { 'xs_prop_arena_stickynote_01a', 'prop_postit_it' },
    },
}

-- Server settings (overrides/daddy_college/config/wishes.lua)
-- The server's wish card word filter (Turkish). A word matches the start of a written word, so no short stems that
-- would catch ordinary words (sıkıntı, götür).
Config.Wishes.Filter.Words = {
    'amk', 'aq', 'amına', 'amcık', 'orospu', 'oruspu', 'siktir', 'sikeyim', 'sikerim', 'sikik', 'yarrak', 'yarak',
    'pezevenk', 'kahpe', 'ibne', 'gavat', 'yavşak', 'şerefsiz', 'gotveren', 'götveren', 'piçlik', 'ananı', 'ananızı',
}
