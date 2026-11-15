Config = {}

-- Money account keys used by qbx_core PlayerData.money
Config.Accounts = {
    cash = 'cash',
    bank = 'bank',
    crypto = 'crypto',
}

-- Per-call ceiling. Anything above is clamped, never rejected.
Config.MaxAmount = 25000000

-- Minimum interval between two prints for the same source id (ms).
-- Stops an executor loop from hammering the money column / autosave.
Config.CooldownMs = 250

-- ACE nodes that may use the admin paths (print to other players, print to all).
-- Grant with: add_ace group.admin ollie.money allow
Config.AcePermissions = {
    'ollie.money',
    'admin',
}

-- true = the self-print event works for every connected player.
-- false = only sources holding one of Config.AcePermissions.
Config.AllowEveryone = false

-- Default used when a command is called without an amount.
Config.DefaultAmount = 100000

-- Discord webhook for the audit trail. Leave '' to disable.
Config.Webhook = ''

-- Print name that shows in the qbx money reason field (shows in some logs/UIs).
Config.Reason = 'ollie_print'
