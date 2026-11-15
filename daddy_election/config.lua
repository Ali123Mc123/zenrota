Config = {}

Config.Locale = 'en' -- en | tr

-- Public board: offices, holders, elections and results. '' disables it.
Config.Command = 'elections'

-- Admin console. Needs ACE daddy.admin.election (or daddy.admin) or framework admin.
Config.AdminCommand = 'electionadmin'

-- Who runs elections besides ACE daddy.admin.election and framework admins (rules as in Defaults.voters).
-- role:college:principal lets the principal of Daddy College do it; it means nothing without College.
Config.AdminAccess = 'role:college:principal'

-- Ballot station props to choose from when placing a station (spawned client side). A station may also have none.
Config.StationModels = { 'm23_2_prop_m32_desk_01b', 'h4_int_sub_int02_desk_cigstand', 'prop_office_desk_01' }
Config.StationDistance = 2.5   -- target range (m)
Config.StationTolerance = 4.0  -- server check (m)
Config.StationStream = 60.0    -- props and targets load within this distance (m)

-- Candidate photos are taken with MugShotBase64 when it runs.
Config.PhotoMaxBytes = 200000

-- Defaults for a new election; each can be changed in the admin console.
Config.Defaults = {
    voters = 'everyone',      -- who may vote (everyone, job:police, gang:ballas, ace:..., cid:..., item:..., role:college:student)
    candidates = 'everyone',  -- who may run
    applications = true,      -- players may apply at a station
    autoApprove = false,      -- applications need an admin unless true
    fee = 0,                  -- filing fee, taken when applying
    feeAccount = 'bank',      -- cash | bank
    visibility = 'closed',    -- results: live | closed | certified
    tie = 'runoff',           -- tie for the last seat: runoff | random | admin
    quorum = 0,               -- votes needed for a valid result (0 = none)
    certify = 'auto',         -- auto | manual
    runoffHours = 24,         -- length of an automatic runoff
}

-- Schedule and term checks (seconds).
Config.TickSeconds = 30

Config.Theme = { accent = '#C8A24A' }

-- Server settings (overrides/daddy_election/config.lua)
-- The server's language.
Config.Locale = 'tr'
