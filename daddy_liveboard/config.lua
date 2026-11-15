Config = {}

Config.Locale = 'tr' -- en | tr

Config.Command = 'liveboard'      -- admin menu: add, edit and remove boards (ACE daddy.admin.liveboard or daddy.admin)
Config.StopCommand = 'stopboards' -- admin: stops media on every board ('' = off)

-- Who may draw, show media and manage new boards. Rules: everyone, job:name:grade, ace:name, cid:id, item:name,
-- role:college:teacher (comma separated, '' = admins only).
Config.DefaultAccess = { draw = 'role:college:teacher, role:college:student', media = 'role:college:teacher', manage = 'role:college:principal' }
Config.CollegeAccess = { draw = 'role:college:teacher, role:college:student', media = 'role:college:teacher', manage = 'role:college:principal' } -- with Daddy College

-- Daddy College classrooms: a board placed in a classroom links to it by itself.
Config.College = {
    Enabled = true,
    LessonTeacherOnly = true,   -- during a lesson only its teacher (and managers) draw and show media
    CallUpMinutes = 5,          -- "Call to the board": the student writes this long
    MaxCallUps = 8,             -- students called up to one board at once
    StudentClaimSeconds = 20,   -- a student's turn (ink: an open class's pen) ends this long after their last stroke
    ClearOnLessonEnd = true,    -- the board is wiped when the lesson ends
    StopMediaOnLessonEnd = true,
    RestoreMinutes = 30,        -- the last clear can be brought back once within this time
    MaxCandidates = 40,         -- players listed for "Call to the board"
}

-- Board types. drawing = players can draw; media = the media panel is available; fullDist/maxDist = sound (m).
Config.Presets = {
    classroom = { background = '#ffffff', drawing = true, media = true, resolution = 1280, fullDist = 4.0, maxDist = 10.0 },
    meeting = { background = '#f4f6f8', drawing = true, media = true, resolution = 1280 },
    briefing = {
        background = '#1d232b', drawing = true, media = true, resolution = 1280,
        colors = { '#f7f4ec', '#f5d547', '#f2a03d', '#e03b3b', '#3fa34d', '#5aa9e6' },
    },
    cinema = { background = '#000000', drawing = false, media = true, resolution = 1600, fullDist = 8.0, maxDist = 30.0 },
    tv = { background = '#000000', drawing = false, media = true, resolution = 1280, fullDist = 3.0, maxDist = 10.0 },
}

Config.Radius = 12.0 -- boards without a floor area (or a classroom) show within this distance (m)

Config.Surface = {
    MaxLive = 3, -- boards drawn at once by this resource
}

Config.Interact = {
    Distance = 3.0,        -- target range (m)
    ServerTolerance = 5.0, -- server check, added to half the board size (m)
}

-- Live updates go to the players in a board's floor area; boards without one use the radius on their own floor.
Config.Canvas = { NearbyRadius = 25.0, NearbyHeight = 4.0, ZoneMargin = 1.5 }

-- The drawing engine: 'ink' (pages that never fill, everyone with the right writes at once, own undo, a clear that
-- can be undone) or 'canvas' (the old one: one drawer at a time, a board fills up). Both use the boards, rights and
-- media above. 'ink' needs the built UI (web/dist/dui/ink.html); without it 'canvas' runs.
Config.Engine = 'ink'

Config.Ink = {
    Pages = { low = 1, normal = 2, high = 3 }, -- boards drawn at once with ink, by the player's quality
    Statics = { low = 12, normal = 24, high = 24 }, -- boards shown from their last picture (no ink page, or seen from afar)
    Bake = true,                     -- old strokes bake into picture tiles, so a board never fills (false: no tiles)
    Quality = 'normal',              -- until a player picks one
    QualityCommand = 'tahtakalite',  -- a player's own quality (low / normal / high), kept on their PC ('' = off)
    Raster = 2048,                   -- the editor draws a board this many px on its long edge
    Tint = 230,                      -- board brightness in the world (255 = full; lower keeps it from glowing in the dark)
    TwoSided = false,                -- true only if boards stay invisible in game (draws both faces)
    OpenClassPens = 8,               -- students of an open class writing at once (1 = in turns)
    Widths = { 2, 4, 8, 16 },        -- pen sizes (px at the 680 px reference)
    -- Board content (P4): text boxes, pictures, pages, the laser.
    KeepVoiceWhileDrawing = true,    -- push-to-talk works while drawing (no other key reaches the game; off while typing)
    TextSizes = { 18, 28, 40, 64 },  -- text sizes (px at the 680 px reference)
    MaxPages = 12,                   -- pages per board; one more archives the oldest
    LessonArchiveDays = 7,           -- an ended lesson's pages: "Previous lesson" for its board's teacher this long
    ArchivedPageDays = 30,           -- archived pages (and their history) are deleted this long after they left the board
    TextLogPerMinute = 6,            -- text box lines a player writes to the board log a minute (more are counted, not kept)
    TextHint = 64, TextMax = 128,    -- text boxes on a page: a new page is suggested, then made by itself
    ImageHint = 12, ImageMax = 24,   -- pictures on a page: the same
    MaxImageKB = 400,                -- a picture's file
    UploadKB = 180,                  -- a linked picture past MaxImageKB is made smaller by the editor to this (0 = off)
    ScreenFill = { Width = 0.8, Height = 0.8 }, -- the board's share of the screen while writing on it (was 0.8 / 0.72)
    -- "Link" takes a png, jpg or webp whose address starts with one of these ({} = off). The first one is shown in
    -- the box as the example. A whole host takes any picture uploaded there; a folder only that folder's.
    PictureLinks = { 'https://r2.fivemanage.com/', 'https://files.fivemanage.com/' },
    Slides = 8,                      -- photos turned into pages at once
    BannedWords = {},                -- text boxes holding one of these (lower case) are refused
}

-- 'canvas' engine only:
Config.ClaimSeconds = 60 -- one drawer at a time; renewed on every stroke

Config.Limits = {
    MaxStrokes = 1500,
    MaxPoints = 60000,
    MaxContentKB = 256,
}

Config.Tools = {
    Kinds = { 'pen', 'brush', 'marker', 'eraser', 'fill', 'line', 'rect', 'circle' },
    Colors = { '#1f2229', '#e03b3b', '#f2a03d', '#f5d547', '#3fa34d', '#2f6fb5', '#7d4fa8', '#f7f4ec' },
    Widths = { 2.0, 5.0, 10.0, 20.0 },
    DefaultOpacity = 1.0,
}

Config.Theme = { accent = '#3E7BFA' }

-- Media plays on a server timeline: it ends, loops or goes to the next item by itself, and comes back paused at its
-- second after a restart. Two kinds of link: YouTube, and files from the school's own upload folder.
Config.Media = {
    Enabled = true,
    -- One video decodes per client for every product (daddy_lib, convar daddy:dui_video): screens without it show their cover.
    Lanes = { youtube = true, file = true }, -- file = .mp4 .webm, .mp3 .m4a .ogg .opus and pictures from DirectPrefixes
    AllowLive = false,    -- YouTube live streams (refused while false)
    FetchMetadata = true, -- asks YouTube's oEmbed for the title and cover image
    PerOwner = 60,        -- library items per teacher; the one unused longest gives way to a new one
    UnusedDays = 60,      -- items unused this long are deleted (playlists and the school archive keep theirs)
    MaxPlaylist = 50,     -- items in one screen's playlist
    SlideSeconds = 10,    -- a picture in a playlist shows this long before the next item
    MaxFileMB = 1024,     -- a file's HEAD check: at most this big

    -- Sound follows distance: full up to FullDist, silent past MaxDist (per screen, set in the panel).
    Volume = { Default = 0.5, Max = 1.0, FullDist = 3.0, MaxDist = 12.0, HardMaxMeters = 40.0, Curve = 1.6 },
    Distances = { class = { 4.0, 10.0 }, hall = { 8.0, 30.0 }, open = { 3.0, 40.0 } }, -- panel presets: full, heard up to (m)

    -- Heard = screen volume x own volume x ducking x distance (nearest point of the board) x room.
    Sound = {
        Personal = 0.8,           -- a player's own media volume until they set one (/medyases)
        OtherRoom = 0.35,         -- heard from another room of the screen's building (boards without a floor area)
        Outside = 0.15,           -- heard from outside that building
        EdgeFade = 3.0,           -- m past a board's floor area over which the sound fades out
        DuckDb = -6.0,            -- quieter while another player this close talks ...
        DuckRadius = 8.0,         -- ... (m)
        DuckHoldMs = 1500,        -- ducking stays this long after the last word
        TickMs = 200, Step = 0.015, ResendMs = 1000, -- worked out every TickMs, sent when it moves by Step or every ResendMs
    },
    ComfortCommand = 'medyases',  -- own media volume and streamer mode (YouTube muted for you), kept on this PC

    -- The media page: one DUI per client, drawn 3 mm behind the boards of the screen it plays.
    Page = { Width = 1280, Height = 720, WarmSeconds = 15, IdleMinutes = 3 }, -- kept loaded WarmSeconds after you leave
    Decoder = { InZone = 100, Playing = 50, PerMeter = 1, PausedRelease = 10 }, -- score per screen; paused gives it up after 10 s
    InkOverYouTube = false,       -- YouTube's embed rules forbid layers over its player: the drawing hides while it plays
    YouTubeOrigin = '',           -- '' = the page's own origin; try 'https://www.youtube.com' if every video fails in game

    DirectPrefixes = { 'https://r2.fivemanage.com/Ys6cM9PLWjYdYxw6wrjzC/' }, -- host + folder; the only place for files
    ThumbnailHosts = { 'i.ytimg.com' }, -- cover images must come from these hosts (or the folder)

    Blacklist = {}, -- substrings that reject a URL

    Limits = { MaxUrlLength = 512 },
}
