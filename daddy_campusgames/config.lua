Config = {}

-- Settings =========================================================================================================
-- What a server owner changes. The fine tuning at the end of the file is how the games look and feel.

Config.Locale = 'en'      -- en | tr (a server layer at the very end of this file may set its own)
Config.Command = 'games'  -- opens the games page when no phone runs; '' disables it
Config.TimezoneOffset = 0 -- hours from UTC for weekly boards (match Daddy College's when both run)
Config.AnyTime = true     -- games open at any hour, even places set to school hours

-- Who may place games, run tournaments and host bingo nights besides ACE daddy.admin.campusgames (or daddy.admin) and
-- framework admins. BingoManage edits the bingo host groups and may take over any night.
-- Rules: everyone, job:name:grade, ace:name, cid:id, item:name, role:college:principal ... (role:college:* needs College)
Config.Access = {
    Admin = 'role:college:principal', Tournament = 'role:college:principal',
    Bingo = 'role:college:teacher, role:college:principal, role:college:council, role:college:president',
    BingoManage = 'role:college:principal',
}

Config.StreamDistance = 60.0         -- game places load within this distance (m)
Config.SyncRadius = 40.0             -- spectators within this distance see the game
Config.JoinRange = 25.0              -- how close to a place you must be to open or join its game
Config.Lobby = { IdleMinutes = 10 }  -- a sign-up sheet nobody touches closes after this
Config.Leave = { GraceSeconds = 30 } -- a player who walks away from a running game is out after this

-- Entry fees: each place sets its amount and account. 'card' is the Daddy College campus card
-- and falls back to bank without College. Pot: none (fees leave the game) | winner (shared by the winners).
Config.Fees = { Accounts = { 'cash', 'bank', 'card' }, Pot = 'none' }

-- Rewards: College activity XP when Daddy College runs; nothing else needs it.
Config.Rewards = {
    Lesson = 'pe',               -- default lesson key for XP (your server's PE lesson); a place can set its own
    Score = { 100, 70, 50, 35 }, -- 0-100 score by place; later places get 25
    MinDistinctPlayers = 2,      -- fewer different players: no XP and nothing on the leaderboard
    MinMatchSeconds = { darts = 120, golf = 180, ctf = 240, potato = 60, light = 45, seek = 120, chairs = 60, taboo = 180, whoami = 120, balloon = 120 }, -- shorter: no XP
    DailyXpMatches = 3,          -- XP matches per game per day
    SameOpponentDaily = 2,       -- XP matches against the same player per day
    Points = { win = 3, second = 1, played = 0 },
}

Config.OnMatchEnd = function(match, results) end -- your own code after every match (server); results: id, name, place, score, xp
Config.Retention = { MatchesDays = 60, Weeks = 12 }

-- The leaderboard board: the first model the game has (the whiteboard needs game build 2060).
Config.Board = { Models = { 'ch_prop_whiteboard', 'prop_cork_board' }, Distance = 2.0 }

-- The places panel (/gamesadmin) and the props it offers.
Config.Admin = {
    Command = 'gamesadmin', PlacementReach = 150.0, MaxBatch = 32,
    Props = { 'prop_dart_bd_01', 'prop_dart_bd_cab_01', 'prop_golf_bag_01b', 'prop_beachflag_01', 'ch_prop_whiteboard', 'prop_cork_board',
        'prop_table_03', 'prop_picnictable_01', 'prop_mp_cone_02', 'prop_mp_barrier_02' },
}

Config.Theme = {
    accent = '#2F6B4F', accentHover = '#295E45', accentActive = '#22513B',
    accentSubtle = '#14201A', accentMuted = '#24402F', accentRing = '#3F8A66', accentText = '#7FC4A2',
    teamA = '#2F4B7C', teamB = '#B5452F',
}

-- Games ------------------------------------------------------------------------------------------------------------
-- Players = { fewest, most }. Sizes and times marked "default" are what a new place starts with; the place's own
-- setting in /gamesadmin wins.

-- Locale keys bottle.<kind>_1 .. _n for a deck.
local function cards(kind, n)
    local out = {}
    for i = 1, n do out[i] = ('bottle.%s_%d'):format(kind, i) end
    return out
end

-- Truth or dare: players sit round a rug on the floor or round a table. The bottle points at someone, they pick truth
-- or dare, the spinner draws a card or asks in their own words, and they spin next.
Config.Bottle = {
    Seats = { floor = 10, table = 6 },         -- most players on a rug and at a table (a place may set fewer)
    Passes = 2,                                -- passes per player per game (0 = no passing)
    UpRange = 30.0,                            -- up for a dare (G), a player keeps the seat within this far (m)
    OwnWords = true, MaxText = 140,            -- the spinner may ask in their own words
    TurnSeconds = 40, AskSeconds = 45, AnswerSeconds = 90, -- to spin or pick; to ask; to answer, then spin
    Next = 'target',                           -- target (the pointed player spins next) | round (in seat order)
    SkipSelf = true,                           -- the bottle never points at the one who spun it
    -- Cards: locale keys (bottle.*) or your own text. Keep them fit for your server.
    Decks = { truth_dare = { truth = cards('truth', 25), dare = cards('dare', 25) } },
}

-- Darts: 1-4 players throw from the line in front of the board; Rounds is the number of visits in high score.
Config.Darts = { Modes = { '501', '301', 'around_clock', 'high_score' }, DoubleOut = false, Rounds = 5, TurnSeconds = 45 }

-- Mini golf: holes drawn on flat ground belong to the nearest course entrance; the ball is picked up at par + MaxOver.
Config.Golf = { TurnSeconds = 60, MaxOver = 3 }

-- Capture the flag: two teams on a field with a base each; no weapons, a touch tags.
Config.Ctf = {
    Minutes = 10, Target = 3, MaxPlayers = 16, -- defaults: game time, flags to win, most players
    PrepSeconds = 20, Overtime = 2,            -- time to reach the bases; overtime minutes on a tie (0 = a draw)
    TagOwnHalfOnly = true,                     -- players are tagged only in the tagger's half; a flag carrier anywhere
    CarrierNoSprint = true,
}

-- Hot potato: pass it (E, to the nearest player in reach) before its hidden fuse runs out; the holder then is out.
Config.Potato = {
    Players = { 3, 12 }, Radius = 6.0, -- default ring round the spot (m)
    Fuse = { 12, 30 },                 -- seconds until it goes off (random each round)
    NoPassBack = true,                 -- never straight back to who gave it, while three or more are in
}

-- Red light, green light: run to the light while it is green; whoever still moves on red is out.
-- The place is the light, facing the players; the start line is Length metres in front of it.
Config.Light = { Players = { 2, 24 }, Length = 40.0, Width = 14.0, Minutes = 3 } -- defaults: the track (m), game time

-- Hide and seek: the seeker counts at the base with a dark screen, then finds hiders (E next to them); a hider back
-- at the base (E) is safe. Time up: the unfound are safe.
Config.Seek = {
    Players = { 3, 16 }, Radius = 50.0, Hide = 45, Minutes = 6, -- defaults: the area (m), hiding (s), seeking (min)
    Camp = 10.0,                       -- hiders still this close to the base when the seeking starts are found (m)
}

-- Musical chairs: a ring of chairs, one fewer than players; the game walks everyone round while the music plays,
-- sit (E) when it stops.
Config.Chairs = {
    Players = { 3, 10 }, Music = { 8, 18 }, SitSeconds = 8, -- how long the music plays (s, random); time to sit
    Volume = 0.35,                     -- the music's loudest (0-1), quieter away from the speaker
    VolumeCommand = 'gamesmusic',      -- each player sets their own music level: /gamesmusic 0-100 ('' turns it off)
    -- Your own music: files you put in web/public/sounds (then build the page), e.g. { 'sounds/chairs1.ogg' }; a
    -- round plays one of them from a random point, the same for everyone. Empty plays the built-in tune.
    Tracks = {},
}

-- Taboo: two teams round a table or a rug. The describer talks the card's word through without the word itself or
-- its five taboo words; the team guesses out loud (the describer presses Correct, the other team's watcher may object)
-- or types it. The watcher buzzes when a taboo word slips out.
Config.Taboo = {
    Players = { 4, 12 }, Seats = { floor = 12, table = 6, long = 8 }, -- most players on a rug, a round and a long table
    RoundSeconds = 60, Passes = 3,             -- a round's time; passes in a round
    Target = 10, Rounds = 6,                   -- defaults: points to win; rounds each team describes (then the leader wins)
    TabooPenalty = 1, PassPenalty = 0,         -- points a taboo word and a pass cost
    ObjectionSeconds = 3,                      -- how long the watcher may object to a spoken Correct
}

-- Who Am I: everyone wears a name the others see. Classic: on your turn ask yes or no questions out loud, the others
-- answer with keys, one typed guess a turn; the category comes on your 3rd turn, the first letter on your 5th.
-- Race ("Who is it?"): five clues about one person, the first to type the name scores (more the earlier).
-- A place's deck: mixed, one category, or campus (the characters online now).
Config.WhoAmI = {
    Players = { 3, 10 }, Seats = { floor = 10, table = 6, long = 8 },
    TurnSeconds = 60, MaxMinutes = 15,         -- one turn; the whole game (who is left shares the last place)
    Hints = { 3, 5 },                          -- the turn the category comes, the turn the first letter comes
    Race = { Rounds = 8, ClueSeconds = 8, Tries = 3, BreakSeconds = 5 }, -- people a race; between clues; wrong guesses each; after one
}

-- Balloon date: whoever opens it is the dater and stands on the spot; the others stand on a half moon in front, a
-- balloon each. Over the rounds the dater talks about themself and answers questions; a red flag: hold E to pop your
-- balloon (you are out). At the end the dater picks one of the balloons left (or nobody) and the two go on a date.
Config.Balloon = {
    Players = { 3, 11 }, Radius = 4.0, Arc = 150.0, -- dater included; default half moon size (m) and width (degrees)
    Rounds = {                                 -- in order: locale key balloon.round_<key>, seconds (the dater may cut one short)
        { key = 'intro', seconds = 90 },
        { key = 'questions', seconds = 150 },
        { key = 'last', seconds = 60 },
    },
    ChoiceSeconds = 45, DateSeconds = 12,      -- the dater's pick (nobody when it runs out); the date scene
    TestCommand = 'balloontest',               -- admins: a stage where you stand, you as the dater, test bots ('' off)
}

-- Bingo: a night of 75-ball games in a hall. A host (Access.Bingo) runs a programme of games, one pattern each;
-- players in the hall take free cards, mark the numbers called by clicking them and call BINGO. The server checks
-- every call against the numbers drawn and the marked squares. Prizes come from the night's fund.
Config.Bingo = {
    Command = 'bingo',                         -- the host panel ('' turns it off)
    TestCommand = 'bingotest',                 -- admins: a hall, a screen and a night with bots around you, you play too ('' turns it off)
    TestBots = 10,                             -- bots the test night starts with
    AutoDaub = false,                          -- true: cards mark themselves (no clicking)
    LockSeconds = 10,                          -- a wrong BINGO locks the player's button this long
    Hall = {
        Players = { 4, 150 },                  -- fewest card holders to start a game; most a night takes
        Countdown = 10, AnnounceSeconds = 12,  -- before a game's first number; winners on screen (s)
        MinGap = 3,                            -- the fastest a host may draw by hand (s)
        HostAwayMinutes = 5,                   -- a host gone this long ends the night (after a pause and a chance to take over)
        Invites = 2, InviteRadius = 150.0,     -- phone invites a night; how far a near invite reaches (m)
        Margin = 3.0,                          -- a player this far outside the hall area still counts as inside (m)
    },
    -- The most a host may set: games a night, cards a player may hold, one prize ($); the automatic draw's gap (s).
    Limits = { MaxGames = 10, MaxCards = 4, MaxPrize = 25000, Speed = { Min = 3, Max = 15, Default = 7 } },
    -- The prize fund: school money (by the Budget rules, at most Daily a day) and the host's own money from an Own
    -- account (at most MaxOwn, held while the night runs; what is not paid out goes back).
    Fund = { School = true, Own = { 'bank', 'cash' }, MaxOwn = 50000, Daily = 30000 },
    -- School money a night by role, highest first: the first rule a host passes is theirs. Host groups add their own.
    Budget = {
        { rule = 'role:college:principal', amount = 10000 }, { rule = 'role:college:teacher', amount = 3000 },
        { rule = 'role:college:president', amount = 2000 }, { rule = 'role:college:council', amount = 1000 },
    },
    InviteAll = 'role:college:principal',      -- who may send a night's invite to every phone (others reach the hall's surroundings)
    Xp = { Played = 40, Won = 20, MinGames = 2, MaxWins = 2 }, -- College XP once a night (0-100): played MinGames games; each win adds Won (MaxWins at most)
    -- The programme a new night starts with. pattern: line, double, corners, stamp, small_frame, x, plus, arrow, tee, diamond,
    -- kite, ladder, frame, full, heart, tree, letter_b/i/n/g/o/h/l/u/z (line, double, stamp, kite, ladder: any of their shapes);
    -- cards: the most a player may take that game (they start with one).
    Program = {
        { pattern = 'line', cards = 3, prizes = { line = 300 }, speed = 7, auto = true },
        { pattern = 'corners', cards = 3, prizes = { corners = 300 }, speed = 7, auto = true },
        { pattern = 'kite', cards = 3, prizes = { kite = 400 }, speed = 7, auto = true },
        { pattern = 'double', cards = 3, prizes = { double = 500 }, speed = 7, auto = true },
        { pattern = 'full', cards = 3, prizes = { full = 1500 }, speed = 7, auto = true },
    },
    -- The show around a night (all of it from base-game animations, props and particles).
    Show = {
        -- Cards up: the character holds a notepad and a pencil and writes a little on each mark.
        Pad = {
            Anim = { dict = 'missheistdockssetup1clipboard@base', clip = 'base' },
            Write = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', ms = 1800 },
            Props = {
                { model = 'prop_notepad_01', bone = 18905, pos = vec3(0.1, 0.02, 0.05), rot = vec3(10.0, 0.0, 0.0) },
                { model = 'prop_pencil_01', bone = 58866, pos = vec3(0.11, -0.02, 0.001), rot = vec3(-120.0, 0.0, 0.0) },
            },
            Range = 40.0,                      -- others' notepads are drawn within this distance (m)
        },
        Near = true,                           -- a card one number away pulses and a soft note plays
        -- A winner's celebration (the server picks one) and the confetti over them.
        Cheers = {
            { dict = 'anim@arena@celeb@podium@no_prop@', clip = 'cheer_a_1st' },
            { dict = 'anim@arena@celeb@podium@no_prop@', clip = 'fist_pump_a_1st' },
            { dict = 'anim@arena@celeb@podium@no_prop@', clip = 'hands_air_b_1st' },
            { dict = 'anim@arena@celeb@podium@no_prop@', clip = 'hands_air_c_1st' },
        },
        CheerMs = 4500,
        Confetti = { asset = 'scr_xs_celebration', name = 'scr_xs_confetti_burst', scale = 1.0, bursts = 2 },
        -- The camera on the winners for the night's players and host: a slow push in, film bars and a name strip.
        Cinema = {
            Enabled = true,
            ShotSeconds = 3.2, MaxShots = 3,   -- each winner's shot; more winners are named on the last strip
            From = 3.4, To = 2.3, Fov = 38.0,  -- metres from the face at the start and the end of the push in
            Skip = { control = 202, label = 'BACKSPACE' }, -- the key that skips it
        },
        IntroSeconds = 8,                      -- the night's title card during the first game's countdown
        Outro = true, OutroSeconds = 12,       -- the night's winners list when it ends
    },
}

-- Test bots: an admin adds NPC players to the game they are in with /gamesbot [count] (/gamesbot clear sends them
-- away) and plays it alone. Bots play by themselves and never pay, earn XP or reach the leaderboard.
Config.Bots = { Enabled = true, Command = 'gamesbot' }

-- Games from items: using one sets its game up where the player stands, no /gamesadmin place needed; using it again
-- (or the pick-up option on it) takes it back. The item stays in the inventory. '' turns one off.
Config.Items = {
    Names = { bottle = 'party_bottle', potato = 'party_potato', light = 'party_signal', chairs = 'party_speaker', seek = 'party_flag',
        taboo = 'party_taboo', whoami = 'party_whoami' },
    Idle = 10,                         -- a set-up game nobody plays goes after this (min)
}

-- Fine tuning ======================================================================================================
-- Models, animations, offsets and the numbers behind how each game feels. Change these while testing in game;
-- "set in game" marks the ones that depend on the models.
local function tune(game, values)
    for key, value in pairs(values) do Config[game][key] = value end
end

tune('Bottle', {
    Radius = { floor = 1.25, table = 1.05 },   -- from the bottle to the players (m); at a table, to the chairs
    SitReach = 2.0,                            -- how close to the seat a player must be to sit back down (m)
    PropPack = 'daddy_schoolprops',            -- the resource with the daddy_school_* models
    Scale = 2.2,                               -- the bottle is drawn this many times its size (1.0 = a real 26 cm bottle)
    -- The first model the game has: pitch lays it down, yaw turns its neck along the heading, z lifts it (m).
    Bottles = {
        { model = 'daddy_school_spin_bottle', pitch = 0.0, yaw = 0.0, z = 0.0 },
        { model = 'prop_cs_beer_bot_01', pitch = 90.0, yaw = 180.0, z = 0.035 },
    },
    Rugs = { 'daddy_school_spin_rug' },        -- under a floor ring (none when missing)
    Tables = { { model = 'daddy_school_round_table', top = 0.76 }, { model = 'prop_table_03b', top = 0.8 } },
    -- Chairs (truth or dare tables and musical chairs): seat height and how far back the player sits (m); heading
    -- turns the model. Set in game.
    Chairs = {
        { model = 'daddy_school_round_chair', seat = 0.5, back = 0.0, heading = 0.0 },
        { model = 'prop_table_03b_chr', seat = 0.5, back = 0.0, heading = 180.0 },
    },
    SitScenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER',
    Sit = { male = { dict = 'amb@world_human_picnic@male@base', anim = 'base' }, female = { dict = 'amb@world_human_picnic@female@base', anim = 'base' } },
    Anim = { spin = { dict = 'mp_common', clip = 'givetake1_a' }, pointed = { dict = 'gestures@m@standing@casual', clip = 'gesture_me_hard' } },
    Turns = { 3, 5 }, Seconds = { 3.5, 5.0 },  -- whole turns and seconds of a spin (random)
})

tune('Darts', {
    -- The board's spot is the bull (BoardOffset moves it if the model's origin is elsewhere); the line is Oche metres
    -- in front of it along the board's facing (Facing turns that if the model faces another way). Set in game.
    Oche = 2.37, Facing = 0.0, LineReach = 1.0, BoardOffset = vec3(0.0, 0.0, 0.0),
    AimRadius = 0.2,                           -- the aim stays this close to the bull (m)
    Sway = { A = 0.05, F = { 0.9, 1.4 } },     -- how far (m) and how fast the aim drifts
    HoldSeconds = 1.5, HoldFactor = 0.35, ShakeFactor = 1.4, -- holding the breath calms it, too long shakes it
    Scatter = 0.012,                           -- a small spread the player never sees (m)
    EndDelayMs = 1800,                         -- after the third dart, before the darts are taken out
    ReleaseMs = 900,                           -- when the throw animation lets go of the dart (set in game)
    Models = { 'prop_dart_1', 'prop_dart_2' }, DartPitch = -90.0, -- the pitch turns the tip into the board
    HitSound = { 'Hit', 'DLC_HEIST_HACKING_SNAKE_SOUNDS' }, -- name, set
    Anim = { dict = 'mini@darts', idle = 'throw_idle_a', throw = 'throw_overlay', retrieve = 'retrieve_neutral', win = 'retrieve_win_a' },
})

tune('Golf', {
    -- The ball is simulated on the server: friction and bounce set how the green plays.
    Friction = 0.09, Restitution = 0.7, StopSpeed = 0.03,
    MaxSpeed = 4.5,                            -- the ball's speed at full power (m/s)
    NeedleSpeed = 0.8, MinPower = 0.04,        -- the power needle's sweeps a second; the softest putt
    CupRadius = 0.06, CaptureSpeed = 1.3,      -- a ball slower than this over the cup drops in
    CourseRange = 300.0, PostRadius = 0.18, BallReach = 2.0, HoleDelayMs = 2500,
    Balls = { 'prop_golf_ball', 'prop_golf_ball_p2', 'prop_golf_ball_p3', 'prop_golf_ball_p4' },
    Putter = 'prop_golf_putter_01', Flag = 'prop_golfflag',
    -- The course kit when its resource runs; else the walls are lines and the corners cones.
    Kit = { Resource = 'daddy_campusgames_props', Rail = 'daddy_mg_rail_1m', Corner = 'daddy_mg_rail_corner', Cup = 'daddy_mg_cup', Tee = 'daddy_mg_tee' },
    Fallback = { Corner = 'prop_mp_cone_02', Cup = 'prop_golf_marker_01' },
    Anim = { dict = 'mini@golfai', idle = 'putt_idle_a', action = 'putt_action' },
    Stance = 0.55,                             -- how far the player stands beside the ball (m, set in game)
})

tune('Ctf', {
    TagRange = 1.6, TagSlack = 0.4, TagCooldown = 2, TagStun = 3, -- reach (m), lag allowance (m), seconds
    PickupRange = 1.6, PickupHold = 1.0, ReturnSeconds = 20, BaseReach = 2.5, OutOfBoundsSeconds = 5,
    Flags = { 'ind_prop_dlc_flag_01', 'ind_prop_dlc_flag_02' },
    FlagOnBack = { bone = 24818, offset = vec3(-0.05, -0.18, 0.0), rotation = vec3(0.0, 90.0, 0.0) }, -- set in game
})

tune('Potato', {
    HotSeconds = 5,                            -- it ticks faster this long before it goes off
    PassRange = 2.2, CatchMs = 700,            -- how close to pass (m); how soon the catcher may pass it on
    StartSeconds = 5, BreakSeconds = 4, OutSeconds = 5, -- before the first round; between rounds; out of the ring
    Models = { 'daddy_school_hot_potato', 'prop_tennis_ball' },
    Hold = { bone = 28422, offset = vec3(0.04, 0.02, -0.02), rotation = vec3(0.0, 0.0, 0.0) }, -- set in game
})

tune('Light', {
    PrepSeconds = 8,                           -- on the start line before the first green
    Green = { 2.0, 5.0 }, Red = { 2.5, 4.5 },  -- how long each light lasts (s, random)
    GraceMs = 1200, Tolerance = 0.5,           -- time to stop after red (reaction, network, slowing down); drift allowed (m)
    Finish = 3.0,                              -- the finish line, this far in front of the light (m)
    Models = { off = 'daddy_school_light_post_off', red = 'daddy_school_light_post_red', green = 'daddy_school_light_post_green' },
})

tune('Seek', { FindRange = 2.0, SafeRange = 2.5, OutSeconds = 6 }) -- reach to find, reach of the base (m); out of the area

tune('Chairs', {
    StartSeconds = 4, BreakSeconds = 4,        -- before the first round; between rounds
    Spacing = 0.8, Reach = 1.5, Hear = 30.0,   -- between chair centres; to sit; how far the music is heard (m)
    WalkGap = 0.9, WalkSpeed = 1.0,            -- how far outside the chairs everyone walks (m); how fast (1 walks, 2 runs)
    Leave = 6.0, OutSeconds = 5,               -- this far past the walking path for this long is out (m, s)
    PathSlack = 2.5,                           -- off the walking path by more than this when the music stops: no chair (m)
    EarlyLimit = 2,                            -- tries to sit while the music plays before a player is out
    TrackSkip = 30,                            -- a round's track starts up to this many seconds in
})

tune('Items', {
    -- What each one sets up: the place kind, how far in front of the player (m), the prop that marks it, its settings.
    Setup = {
        bottle = { kind = 'bottle_ring', ahead = 1.6, settings = { surface = 'floor', deck = 'truth_dare', rug = false } },
        potato = { kind = 'potato_ring', ahead = 0.0, models = { 'daddy_school_hot_potato', 'prop_tennis_ball' } },
        light = { kind = 'light_track', ahead = 0.0, turn = 180.0, models = { 'daddy_school_light_post_off', 'prop_mp_cone_02' } },
        chairs = { kind = 'chairs_ring', ahead = 2.5, models = { 'daddy_school_party_speaker', 'prop_boombox_01' } },
        seek = { kind = 'seek_base', ahead = 0.0, models = { 'daddy_school_base_flag', 'prop_beachflag_01' } },
        taboo = { kind = 'taboo_table', ahead = 1.8, settings = { surface = 'floor', rug = false }, models = { 'daddy_school_card_box' } },
        balloon = { kind = 'balloon_stage', ahead = 0.0 },
        whoami = { kind = 'whoami_ring', ahead = 1.8, settings = { surface = 'floor', rug = false, deck = 'mixed' }, models = { 'daddy_school_headband_card' } },
    },
    Reach = 4.0, Gap = 4.0, Far = 100.0,       -- the spot may be this far from the player; from other places; owner gone (m)
})

tune('Bots', {
    Models = { 'a_m_y_hipster_01', 'a_f_y_hipster_02', 'a_m_y_stbla_02', 'a_f_y_bevhills_02', 'a_m_y_vinewood_01', 'a_f_y_vinewood_01' },
    Think = { 1500, 3500 },                    -- how long a bot waits before its move (ms, random)
    Darts = 0.04,                              -- how far a bot's dart lands from where it aims (m)
    Late = 0.2,                                -- red light: the share of reds a bot stops too late on (and is out)
    Taboo = { Right = 0.25, Claim = { 8, 16 }, Buzz = 0.02 }, -- a typed guess is the word; seconds to a Correct; a buzz each second
    WhoAmI = { Turn = 20, Right = 0.3, Race = 0.08 }, -- seconds into its turn it guesses, right this often; race odds per clue
    Balloon = { Pop = 0.01 },                   -- the odds a bot pops its balloon at each think
    Bingo = { Claim = { 1, 3 } },              -- seconds before a bot calls BINGO on a complete card (random); bingo bots are cards only
})

-- Seated games (Taboo, Who Am I): a ring on a rug or round a table, two rows at a long table.
Config.Seating = {
    Radius = { floor = 1.25, table = 1.05 }, Spacing = 0.8, -- the ring (m); a big group widens it to this much per seat
    Long = { Spacing = 0.6, Half = 0.8 },      -- a long table: between chairs along it; from its middle line to a chair (m)
    Tables = {                                 -- the first model the game has; top = the table top's height (m)
        table = { { model = 'daddy_school_round_table', top = 0.76 }, { model = 'prop_table_03b', top = 0.8 } },
        long = { { model = 'daddy_school_long_table', top = 0.76 } },
    },
    Rugs = { 'daddy_school_spin_rug' },        -- under a floor ring (none when missing)
    UpRange = 30.0, SitReach = 2.0,            -- up (G), a player keeps the seat this far; how close to sit back down (m)
}

tune('Taboo', {
    StartSeconds = 4, BreakSeconds = 5,        -- before the first round; between rounds
    GuessMs = 700, ClaimMs = 1500,             -- a typed guess, a Correct at most this often (ms)
    WatchRange = 12.0, Feed = 6,               -- spectators this close see the score (m); guesses on screen
    -- On the table or the rug, along the place's heading: the first model the game has, `along` metres from the middle.
    Props = {
        box = { models = { 'daddy_school_card_box' }, along = 0.0 },
        timer = { models = { 'daddy_school_sand_timer' }, along = 0.3 },
        buzzer = { models = { 'daddy_school_buzzer_up' }, down = 'daddy_school_buzzer_down', along = -0.3 },
    },
    Card = { model = 'daddy_school_word_card', bone = 28422, offset = vec3(0.05, 0.02, -0.02), rotation = vec3(-70.0, 0.0, 0.0) }, -- in the describer's hand (set in game)
    Anim = {
        talk = { dict = 'gestures@m@standing@casual', clip = { 'gesture_hand_right', 'gesture_why', 'gesture_easy_now', 'gesture_you_soft' }, ms = 1800 },
        buzz = { dict = 'anim@apt_trans@buzzer', clip = 'buzz_reg', ms = 1200 },
        clap = { dict = 'anim@mp_player_intupperslow_clap', clip = 'idle_a', ms = 1600 },
    },
})

tune('WhoAmI', {
    StartSeconds = 4,                          -- before the names go out
    AnswerMs = 500, GuessMs = 700,             -- an answer, a guess at most this often (ms)
    BubbleSeconds = 4,                         -- an answer stays over the head
    DrawRange = 12.0, WatchRange = 12.0,       -- names over the heads; spectators this close see the screen (m)
    Band = { models = { 'daddy_school_headband_card' }, bone = 31086, offset = vec3(0.08, 0.02, 0.0), rotation = vec3(0.0, 90.0, 180.0) }, -- set in game
})

tune('Balloon', {
    StartSeconds = 6, BreakSeconds = 4,        -- walking to the spots; between rounds and after the end
    PopHoldMs = 600, AimMs = 150,              -- hold E this long to pop; the dater's pick moves at most this often
    DrawRange = 20.0, WatchRange = 20.0,       -- marks over the heads; spectators this close see the strip (m)
    FlagSeconds = 4,                           -- RED FLAG stays over a popped player
    Models = { 'daddy_school_balloon_heart', 'daddy_school_balloon_round' }, -- players get them in turn (daddy_schoolprops)
    Hold = { bone = 60309, offset = vec3(-0.106, 0.137, -0.07), rotation = vec3(112.8, -101.17, 28.02) }, -- the hand on the string
    Anim = {
        hold = { dict = 'anim@heists@humane_labs@finale@keycards', clip = 'ped_a_enter_loop' },
        pop = { dict = 'gestures@m@standing@casual', clip = { 'gesture_damn', 'gesture_no_way', 'gesture_shrug_hard' }, ms = 2200 },
        point = { dict = 'gestures@m@standing@casual', clip = 'gesture_you_soft', ms = 1600 },
        dater = { dict = 'mp_ped_interaction', clip = 'hugs_guy_a', full = true },
        chosen = { dict = 'mp_ped_interaction', clip = 'hugs_guy_b', full = true },
    },
    Pop = {                                    -- layers played together: the torn skin (in the balloon's colour), a light puff
        { asset = 'core', name = 'ent_dst_inflate_ball_clr', scale = 0.55, color = { 0.85, 0.05, 0.08 } },
        { asset = 'core', name = 'bul_rubber_dust', scale = 0.6 },
    },
    Confetti = { asset = 'scr_xs_celebration', name = 'scr_xs_confetti_burst', scale = 1.0, color = { 1.0, 0.45, 0.65 }, bursts = 2 },
    -- The date: the chosen one walks to the dater, a hug, their balloon flies off; the match's players watch a slow
    -- two-shot that ends back at the game camera.
    Cinema = { Enabled = true, From = 4.2, To = 2.6, Swing = 25.0, Fov = 40.0, WalkMs = 3500, Skip = 202 },
})

tune('Bingo', {
    TieMs = 2000,                              -- BINGOs this soon after the first share the prize (ms)
    Strikes = 3,                               -- wrong BINGOs before a player may not call in that game
    -- The hall screen (bingo_board place): the page size (px) and how close it is drawn (m).
    Board = { Width = 1280, Height = 720, Range = 60.0 },
})

-- Fine input games (aim, power) run on the shared minigame engine.
Config.Minigames = { TimingSkewMs = 120 }

-- Server settings (overrides/daddy_campusgames/config.lua)
-- The server's language.
Config.Locale = 'tr'
-- Bingo: the host panel is on; the admin test night (bingotest) is off.
Config.Bingo.Command = 'bingo'
-- Balloon date: the admin test stage.
Config.Balloon.TestCommand = 'balontest'
Config.Bingo.TestCommand = ''
-- One card a player.
Config.Bingo.Limits.MaxCards = 1
for _, game in ipairs(Config.Bingo.Program) do game.cards = 1 end
-- Öğrenci telefonundaki Oyunlar uygulaması kapalı.
Config.PhoneApp = false
