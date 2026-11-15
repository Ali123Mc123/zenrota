-- Student Affairs: a desk with a clerk students talk to for papers, cards, results, clubs and enrolment.
-- Desks are world spots of kind 'affairs_desk' (a ped); every desk works the same.
Config.Affairs = {
    Model = 'a_f_y_business_02',        -- used when the desk record has no model
    Scenario = 'WORLD_HUMAN_CLIPBOARD',
    TalkDistance = 2.5,
    DeskDistance = 5.0,                 -- desk-only actions (turning in papers, buying) need the player this close

    -- The camera looks at the clerk's face; with a panel open it moves aside.
    Camera = { Distance = 0.7, Fov = 55.0, ZOffset = 0.0, SideOffset = 0.15, TransitionMs = 800, ReleaseMs = 500 },

    -- Anyone with the Discord role may enrol as a student without the principal.
    SelfEnroll = {
        Enabled = true,
        DiscordRole = '',        -- empty: anyone may enrol; needs the daddy:discord_token and daddy:discord_guild convars otherwise
        AutoAssignClass = false, -- put the student into the least full open class
        CooldownSeconds = 30,
    },

    -- Club presidents manage members and ranks at the desk; officer ranks answer requests at the club table.
    Club = {
        MaxMembers = 0, SearchLimit = 50, MaxRanks = 20, -- MaxMembers 0: the club's own limit, or none
        ProfileEditors = 'president',   -- who edits the club's profile and logo: 'president' or 'officers'
        NoColor = '#1f3a68',            -- the colour of a club that picked none, on every screen and stand
        MaxQuestions = 3,               -- application questions in a profile
        Interview = { ExpireHours = 48, StepMinutes = 15 }, -- an unanswered interview goes back to waiting after this
        Activity = { EventWeight = 3, TaskWeight = 5, StandWeight = 2, InterestWeight = 1, JoinWeight = 4 }, -- a club's week: members' activity + events attended + tasks approved + per 30 stand minutes, interested students, members a stand brought
        Events = {
            SchoolNeedsApproval = true, -- a school-wide event waits for the principal
            AttendRadius = 20.0,        -- members this close to the officer taking attendance count as there
            XpScore = 0,                -- above 0: each attendance is an activity of this score (0-100) in the club's lesson below
            Images = { 'sand', 'sea', 'tide', 'dawn', 'grove', 'dusk', 'graphite' }, -- the same cover keys as the phone's events
        },
        Tasks = { MaxOpen = 10 },
        Lessons = {},                   -- club name -> lesson key for event XP, e.g. ['Debate Club'] = 'literature'
        Icons = { 'fa-solid fa-futbol', 'fa-solid fa-music', 'fa-solid fa-flask', 'fa-solid fa-masks-theater', 'fa-solid fa-camera',
            'fa-solid fa-chess', 'fa-solid fa-scale-balanced', 'fa-solid fa-shield-halved', 'fa-solid fa-palette', 'fa-solid fa-code',
            'fa-solid fa-book-open', 'fa-solid fa-heart-pulse' },
        -- The club's logo: a 256 x 256 picture its profile editor uploads from the phone; stands, brochures, phones and
        -- tablets show it. Students report it, moderators hide, show, remove or lock it.
        Logo = {
            Enabled = true,
            MaxChars = 131072,       -- data URL characters of the 256 x 256 picture (PNG or JPEG)
            CooldownMinutes = 10,    -- between two uploads of one club
            Approval = false,        -- true: a new logo waits for a moderator
            Background = '#e5ded0',  -- the editor's first background (the emblem circle's own colour)
            Slots = 12,              -- stands with a logo one player sees at once
            SendBps = 200000,        -- bytes a second a logo travels to a player
            LockDays = 7,            -- uploads closed after a moderator removes a logo (0 = none)
            -- InstantHide: hidden at once when InstantMin different students give that reason (one alone never does)
            Report = { Reasons = { 'sexual', 'hate', 'harassment', 'real_info', 'other' }, InstantHide = { 'sexual' }, InstantMin = 2, HideAt = 3 },
            Moderators = 'role:college:principal, role:college:counselor', -- see hidden logos, hide, show, remove (admins always)
        },
        -- Club tables in the garden (/collegeadmin): open while an officer stands at one. Prop places are from the table's
        -- origin (x right, y front, z up; set in game); the cloth's colour is the nearest of ClothColors to the club's.
        Table = {
            Reach = 3.0, LeaveSeconds = 120, LeaveDistance = 10.0,
            ReferralDays = 7,             -- a handed brochure brings its student to the one who handed it for this many days
            Blip = { Enabled = true, Sprite = 409, Colour = 27, Scale = 0.7, ShortRange = false }, -- open stands on the map (a list shows them too)
            HandReach = 2.0,
            OfferSeconds = 15,           -- how long a held-out brochure waits for [E]
            HandProp = 'prop_cs_pamphlet_01', -- the brochure in hand while handing or taking one              -- how far in front of the table the officer can hand a brochure
            FlyerItem = 'club_flyer', FlyerMax = 3, -- an item you add to your inventory; without it the server refuses brochures with a message
            Models = {                    -- the first model the game has; daddy_schoolprops brings the stand table set
                table = { 'daddy_school_club_table_bare', 'prop_table_03' },  -- the table itself (bare, closed)
                cloth = 'daddy_school_club_table_%s',  -- the table dressed in a ClothColors colour while open
                banner = 'daddy_school_club_banner_%s', -- the roll-up banner beside it while open (table setting board = banner)
                flyers = { 'daddy_school_club_flyer_stand', 'prop_cs_pamphlet_01' }, signup = { 'daddy_school_club_signup', 'prop_cs_clipboard' },
                nameplate = { 'm24_1_prop_m41_nameplate_01a', 'prop_amanda_note_01' }, closed = 'prop_amanda_note_01', chair = 'prop_table_03_chr',
                parasol = 'prop_parasol_01', gazebo = 'prop_gazebo_01', cork = 'prop_cork_board', whiteboard = 'ch_prop_whiteboard',
                -- the logo discs per slot (1..Logo.Slots): one for every banner, one per cloth colour
                logo = { banner = 'daddy_school_club_logo_banner_s%02d', cloth = 'daddy_school_club_logo_cloth_%s_s%02d' },
            },
            -- Spots in the table's own frame (x right, y toward the officer's side, z up, w turn); the front faces -y.
            Places = {
                flyers = vec4(-0.55, -0.12, 0.76, 0.0), signup = vec4(0.5, -0.15, 0.76, 0.0), nameplate = vec4(0.0, -0.3, 0.76, 0.0),
                closed = vec4(0.0, -0.15, 0.76, 0.0), chairs = { vec4(-0.45, 0.8, 0.0, 180.0), vec4(0.45, 0.8, 0.0, 180.0) },
                banner = vec4(1.35, 0.2, 0.0, 0.0), parasol = vec4(0.0, 0.0, 0.0, 0.0), gazebo = vec4(0.0, 0.0, 0.0, 0.0), board = vec4(1.6, 0.4, 0.0, 270.0),
            },
            OldPlaces = {                 -- the same spots on prop_table_03 when the stand table is missing
                nameplate = vec4(0.45, -0.35, 0.8, 0.0), flyers = vec4(-0.4, -0.3, 0.8, 0.0), signup = vec4(0.1, -0.3, 0.8, 0.0),
                closed = vec4(0.0, -0.3, 0.8, 0.0), chairs = { vec4(0.0, 0.85, 0.0, 180.0), vec4(0.0, -0.95, 0.0, 0.0) },
                banner = vec4(1.2, 0.2, 0.0, 0.0), parasol = vec4(0.0, 0.0, 0.0, 0.0), gazebo = vec4(0.0, 0.0, 0.0, 0.0), board = vec4(1.6, 0.4, 0.0, 270.0),
            },
            -- Cloth and banner colours; an open table wears the one nearest to the club's own colour.
            ClothColors = { red = '#c0392b', navy = '#1f3a68', green = '#2e7d4f', purple = '#6b3fa0', orange = '#d9822b', black = '#202124' },
        },
    },

    -- The student tablet (Daddy Student Tablet) sold at the desk; hidden when the item does not exist.
    -- DaddyRP: masada satılmıyor (Item = ''); tablet markette 100$.
    Tablet = { Item = '', Price = 100 },
}

-- Doors only members of a club may open (ox_doorlock). The key is the club name as saved in the tablet.
Config.ClubDoors = {
    -- ['Martial Arts'] = {
    --     doors = { 'school_gym' },     -- ox_doorlock door names or ids
    --     onlyPresident = false,        -- only the club's presidents
    --     allowPrincipal = true,
    --     allowSecurity = true,
    --     allowSchoolPresident = true,
    -- },
}
