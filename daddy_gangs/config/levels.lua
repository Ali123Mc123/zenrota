-- A level is reached with enough xp and paid from the vault. A level only raises limits: every feature is open
-- from the moment the gang is active. Unlocks is left for rewards of a level decided later (empty for now).
-- members: most members, vault: most money in the vault, slots / weight (kg): the stash, ranks: most ranks
Config.Levels = {
    { xp = 0,     price = 0,       members = 20, vault = 50000,    slots = 50,  weight = 100,  ranks = 5,  unlocks = {} },
    { xp = 1000,  price = 25000,   members = 22, vault = 150000,   slots = 75,  weight = 150,  ranks = 5,  unlocks = {} },
    { xp = 3000,  price = 50000,   members = 25, vault = 300000,   slots = 100, weight = 250,  ranks = 6,  unlocks = {} },
    { xp = 6000,  price = 100000,  members = 28, vault = 600000,   slots = 125, weight = 350,  ranks = 6,  unlocks = {} },
    { xp = 10000, price = 175000,  members = 30, vault = 1000000,  slots = 150, weight = 500,  ranks = 7,  unlocks = {} },
    { xp = 16000, price = 275000,  members = 32, vault = 2000000,  slots = 175, weight = 650,  ranks = 7,  unlocks = {} },
    { xp = 24000, price = 400000,  members = 35, vault = 3500000,  slots = 200, weight = 800,  ranks = 8,  unlocks = {} },
    { xp = 35000, price = 600000,  members = 38, vault = 5000000,  slots = 250, weight = 1000, ranks = 8,  unlocks = {} },
    { xp = 50000, price = 850000,  members = 40, vault = 7500000,  slots = 300, weight = 1250, ranks = 9,  unlocks = {} },
    { xp = 70000, price = 1200000, members = 45, vault = 10000000, slots = 400, weight = 1500, ranks = 10, unlocks = {} },
}
