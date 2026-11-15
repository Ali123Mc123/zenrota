-- Weekly awards: the principal sets the categories, players nominate, one vote per category a week, winners on the
-- Student of the Week board and the phone. Needs the academics module (its board, rewards and titles).
Config.Awards = {
    -- Days 1 = Monday ... 7 = Sunday, in the school's time zone (Config.TimezoneOffset).
    Schedule = { nominate = { 1, 3 }, vote = { 4, 6 }, results = { day = 7, hour = 20 } },
    TickSeconds = 60,
    NominationsPerCategory = 1,  -- nominations a voter gives in each category a week
    MinNominations = 2,          -- a nominee needs this many to be on the ballot
    BallotSize = 8,              -- the most nominees on a ballot (most nominated first)
    SelfNominate = false, PairSelf = false, SelfVote = false,
    Approve = 'auto',            -- auto (MinNominations puts a nominee on the ballot) | staff (the principal approves each nominee)
    Tie = 'shared',              -- shared (all tied win) | nominations (the most nominated of the tied wins)
    MinVotes = 5,                -- a category with fewer votes has no winner
    VoterRequirement = nil,      -- a requirement rule (as in config/academics.lua) a voter must meet; nil = none
    Retention = { VoteWeeks = 12 },
    -- First start only; after that the principal edits them on the tablet. Labels: awards.cat_<key> in locales.
    -- nominee: student | pair (two students) | teacher | staff (other school jobs). voters: students | members (students and staff).
    Categories = {
        { key = 'funniest', nominee = 'student', voters = 'students', rewards = { { kind = 'title', days = 7 } } },
        { key = 'best_dressed', nominee = 'student', voters = 'students', rewards = { { kind = 'title', days = 7 } } },
        { key = 'best_duo', nominee = 'pair', voters = 'students', rewards = { { kind = 'title', days = 7 } } },
        { key = 'teacher', nominee = 'teacher', voters = 'students', rewards = { { kind = 'title', days = 7 } } },
        { key = 'staff', nominee = 'staff', voters = 'students', rewards = { { kind = 'title', days = 7 } } },
    },
    OnWinner = function(category, citizenid, votes) end, -- your own code for each winner (server)
}
