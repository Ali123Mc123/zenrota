-- The student council: a role of its own (role:college:council), apart from the school president. The principal or a
-- server admin adds and removes members with the command; each member has a rank. Members write sanctions on the
-- Student Tablet (they wait for a teacher or the principal), wear the rank on their ID and read the phone's council box.
Config.Council = {
    Enabled = true,
    -- Ranks, highest first; their names are in locales (council.rank_<key>).
    Ranks = { 'president', 'vice', 'secretary', 'member' },
    Command = 'council', -- the principal or an admin: members and ranks
    -- What a member may ask for in one sanction (detention jobs, or minutes in the room mode).
    -- MaxWaiting: sanctions one writer may have waiting at once.
    Sanction = { MaxJobs = 3, MaxMinutes = 30, MaxWaiting = 5 },
}

-- Server settings (servers/daddyrp/daddy_college/config/council.lua)
-- DaddyRP: komut /konsey.
Config.Council.Command = 'konsey'
