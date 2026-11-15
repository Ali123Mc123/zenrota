-- Everything a rank may be allowed to do. The leader rank has all of them and cannot be removed.
Config.Permissions = {
    'invite',      -- invite players
    'kick',        -- remove members below one's own rank
    'promote',     -- change the rank of members below one's own rank
    'ranks',       -- add, rename, reorder and remove ranks below one's own
    'deposit',     -- put money in the vault
    'withdraw',    -- take money out, up to the daily limit of the rank
    'stash',       -- open the stash
    'diplomacy',   -- ask for and answer meetings, propose and accept peace
    'war',         -- ask for war and accept a war request
    'announce',    -- write and pin announcements
    'logs',        -- read the logs and the vault ledger
    'settings',    -- name colour, description and logo
    'upgrade',     -- pay a level from the vault
}

-- The ranks a new gang starts with, highest first. withdraw: most money per day out of the vault (-1 no limit).
Config.DefaultRanks = {
    { label = 'Lider', leader = true, withdraw = -1 },
    { label = 'Sağ Kol', withdraw = 100000, permissions = { 'invite', 'kick', 'promote', 'ranks', 'deposit', 'withdraw', 'stash', 'diplomacy', 'war', 'announce', 'logs', 'settings', 'upgrade' } },
    { label = 'Kaptan', withdraw = 0, permissions = { 'invite', 'kick', 'promote', 'deposit', 'stash', 'diplomacy', 'announce', 'logs' } },
    { label = 'Asker', withdraw = 0, permissions = { 'deposit', 'stash' } },
    { label = 'Çaylak', withdraw = 0, permissions = { 'deposit' } },
}
