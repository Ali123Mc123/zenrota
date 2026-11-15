-- Notebooks: pages with text and pen drawings; a written page can be torn out and left in the world.
Config.Notes = {
    Commands = { notebook = 'notebook', author = 'noteauthor', delete = 'notedelete' },

    NotebookItem = 'school_notebook', -- the item only carries the notebook's id; pages live in the database
    PageItem = 'notebook_page',       -- a torn page picked up from the world
    PagesPerNotebook = 20,

    -- Limits of one page.
    MaxChars = 1500,
    MaxContentKB = 96,
    MaxStrokes = 400,
    MaxPoints = 12000,

    InkColors = { '#20242a', '#2459a9', '#b83b3b', '#327153', '#795548', '#704f91' }, -- lower case
    PenWidths = { 1.5, 3.0, 6.0, 10.0 },
    HighlightColors = { '#f4e04d', '#7ed38f', '#f29ac1' }, -- highlighters, see-through (lower case)
    MarkerWidth = 14,
    LineTool = true, -- a ruler for straight lines

    -- Writing at a desk: seated on a Campus Life chair marked as a desk, [N] opens the notebook on the desk.
    Desk = {
        Enabled = true,
        Key = 306,           -- N
        Prop = 'prop_notepad_01',
        PropOffset = vec3(0.0, 0.5, -0.05), -- from the seated player: right, forward, up
        Camera = { Enabled = true, Fov = 50.0, Offset = vec3(0.0, -0.2, 0.75), Pitch = -50.0, EaseMs = 450 },
        Scratch = true,      -- no notebook: a loose sheet to write on, kept as a page if wanted
        LessonHeader = true, -- offer the running lesson's name and date at the top of an empty page
    },

    -- Pictures on a page: a copy of the holder's Student Phone photo or scan (the phone's rules apply: exams, detention,
    -- Screen Time), moved, tilted and captioned by whoever holds the page.
    Images = {
        Enabled = true,
        Sources = { photo = true, scan = true, link = false }, -- the phone's gallery, its scans, a link (see Links)
        Links = { 'https://r2.fivemanage.com/Ys6cM9PLWjYdYxw6wrjzC/' }, -- the only starts a link may have
        RequirePhone = true,  -- links need the phone in the pocket too (gallery and scans always do)
        PerPage = 2,
        PerNotebook = 8,
        PerDay = 10,          -- pictures one player adds a day (taken off ones count too)
        PerAuthor = 30,       -- pictures of one player in all notebooks at once
        MaxKB = 240,          -- data URL size of one picture (the phone keeps photos up to 240)
        MaxSide = 4096,       -- pixels on either side, from the picture's own header (a small file of a huge picture is refused)
        CaptionChars = 60,
        Styles = { 'tape', 'polaroid', 'clip' },
        MinWidth = 0.18, MaxWidth = 0.9, -- share of the page's width
        MaxTilt = 8,          -- degrees either way
        KeepDays = 90,        -- a picture nobody opened for this long goes (pages in the world stay); 0 = never
        SendBps = 400000,     -- bytes a second a picture travels to its reader
        Report = { Reasons = { 'sexual', 'harassment', 'real_info', 'hate', 'other' }, InstantHide = { 'sexual' }, HideAt = 3 }, -- on pages in the world
        Moderators = 'role:college:principal, role:college:counselor', -- see hidden pictures, hide, show, remove (admins always)
        Commands = { list = 'noteimages', remove = 'noteimagedel' },
    },

    World = {
        PageModel = 'prop_amanda_note_01',
        Lifetime = 72,        -- hours a page stays in the world (0 = forever)
        MaxPages = 100,       -- the oldest page goes when the world is full
        StreamDistance = 50.0,
        TargetDistance = 1.5,
        PlaceDistance = 3.0,
        PlaceSeconds = 60,    -- a page waits this long to be put down after tearing
    },

    -- Timings of the notebook view and the notebook in hand while writing.
    Presentation = {
        AutosaveMs = 1500,
        CoverOpenMs = 650,
        PageTurnMs = 520,
        TearMs = 850,

        Enabled = true,
        FreezePlayer = true,
        Animation = { Dict = 'missheistdockssetup1clipboard@base', Name = 'base', Flag = 49 },
        Props = {
            { Model = 'prop_notepad_01', Bone = 18905, Offset = vec3(0.10, 0.02, 0.05), Rotation = vec3(10.0, 0.0, 0.0) },
            { Model = 'prop_pencil_01', Bone = 58866, Offset = vec3(0.11, -0.02, 0.001), Rotation = vec3(-120.0, 0.0, 0.0) },
        },
    },
}
