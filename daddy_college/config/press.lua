-- School newspaper: a club writes at a newsroom desk, the editor prints, and copies wait in stacks around campus.
-- Desks and racks are placed with /collegeadmin ('press_desk', 'press_rack'). Copies never run out; each player
-- takes one per issue. Nothing is filtered: the editor answers for what is printed, staff hide or withdraw.
Config.Press = {
    Club = 'Newspaper',           -- the club whose members write (its name in the clubs list)
    Writers = { 'teacher' },      -- extra roles that may write: 'teacher', 'principal', 'year:<key>', 'club:<name>', 'skill:<key>'
    EditorLevel = 1,              -- club ranks at this level or above edit (1 = president)
    Editors = { 'skill:newspaper_editor', 'teacher' }, -- extra roles that may edit; a teacher runs the paper while the club has no president
    Advisors = {},                -- extra roles that hide printed articles and close reports (server staff always may)
    Withdraw = {},                -- extra roles that take a whole issue back (server staff always may)
    Masthead = '',                -- the paper's name; empty = the locale's default

    -- One advisor teacher, picked by the club president, approves or turns back each issue before it prints.
    -- The advisor never edits text; with no answer the issue counts as approved after AutoHours.
    -- TeachersPrint: a teacher at the desk prints without the advisor (the advisor is a teacher too).
    Approval = { Enabled = true, AutoHours = 24, NoteMin = 10, TeachersPrint = true },
    LockClub = true,              -- the club's members and president change only inside the club (server staff always may)
    Pressure = { Enabled = true, MinChars = 20, PerDay = 3 }, -- "Report pressure": goes to server staff, never to the school

    -- 'quote' is the Quote of the Week corner, written by columnists only; 'school' is the school's own corner.
    Sections = { 'news', 'interview', 'podcast', 'photo', 'magazine', 'horoscope', 'cartoon', 'clubs', 'quote' },
    ColumnistSections = { 'quote' },
    Article = { Title = 80, Kicker = 120, MaxChars = 4000, MaxBlocks = 40 },
    MaxArticles = 12,             -- articles in one issue
    MinHoursBetweenIssues = 24,
    Pages = { Max = 8, Rows = 16, Boxes = 30 }, -- an issue's pages: a 6-column grid of Rows rows each
    Flash = { PerDay = 1, AutoHours = 1 }, -- one-page breaking news: once a day, outside the wait; the advisor has AutoHours
    Templates = 20,               -- page layouts the club may keep
    WriteZones = { 'campus' },    -- writers write anywhere in these zones (the command below); editing and printing stay at the desk
    Command = 'gazete',           -- opens the newsroom where writing is allowed ('' = off)
    Notices = { MaxChars = 1500, OpenPerAuthor = 1 }, -- "From the school": teachers write it on the tablet, it prints in the next issue

    OneCopyEach = true,           -- one copy per player per issue from the racks
    ReplaceOld = true,            -- a new issue takes the old stacks away
    StackHours = 48,              -- hours a hand-placed stack stays (0 = until the next issue); a rack's stays until the next issue
    LooseHours = 24,              -- hours a single dropped copy stays
    MaxStacks = 12, MaxLoose = 30, MaxManualStacks = 3,
    StreamDistance = 40.0, TargetDistance = 1.6, PlaceDistance = 3.0,
    PlaceZones = { 'campus' },    -- zone kinds where an editor may put extra stacks ('' or {} = anywhere)
    -- Racks start with BaseStock copies; club members carry up to CarryMax copies per issue from the desk and fill
    -- racks (up to RackMax) or hand them out. An empty rack nobody fills refills itself after RefillMinutes.
    Distribution = { BaseStock = 10, RackMax = 40, CarryMax = 20, RefillMinutes = 10, HandDistance = 3.0 },

    PhoneReading = 'copy',        -- Student Phone: 'copy' (issues the player took), 'all' or 'off'
    -- Pictures: the Student Phone's photos and scans, or a link from these hosts.
    -- Every reader gets an issue's pictures inline: keep them small (an issue with many photos is several MB per read).
    Images = { Enabled = true, Max = 4, MaxKB = 180,
        Hosts = { 'i.imgur.com', 'r2.fivemanage.com', 'files.fivemanage.com', 'cdn.discordapp.com', 'media.discordapp.net', 'i.ibb.co' } },

    Reports = { Reasons = { 'false', 'harassment', 'real_info', 'other' } },
    Retention = { WithdrawnDays = 90 }, -- bodies of withdrawn issues are cleared after this

    Item = 'school_newspaper',
    Models = {
        Stack = 'm25_1_prop_m51_paper_news_quik', -- needs game build 3407; the fallback is used when it is missing
        StackFallback = 'sum_prop_ac_papers_01a',
        Loose = 'prop_cs_newspaper',
        Desk = 'prop_cs_magazine',
        Rack = 'prop_news_disp_01a', -- the stand at every press_rack spot; its copies are taken from it
    },
    -- The paper in hand while reading.
    Reading = {
        Enabled = true,
        FreezePlayer = false,
        Animation = { Dict = 'amb@world_human_tourist_map@male@base', Name = 'base', Flag = 49 },
        Props = { { Model = 'prop_cs_newspaper', Bone = 28422, Offset = vec3(0.0, 0.0, 0.0), Rotation = vec3(0.0, 0.0, 0.0) } },
    },
    Writing = {
        Enabled = true,
        FreezePlayer = true,
        Animation = { Dict = 'missheistdockssetup1clipboard@base', Name = 'base', Flag = 49 },
        Props = { { Model = 'prop_notepad_01', Bone = 18905, Offset = vec3(0.10, 0.02, 0.05), Rotation = vec3(10.0, 0.0, 0.0) } },
    },
}
