tgiCoreExports = exports["tgiann-core"]
config = tgiCoreExports:getConfig()


config.playerMaxBuyStroge = {
    active = true,
    amount = 5
}

config.moneyType = "bank"

config.blip = { -- https://docs.fivem.net/docs/game-references/blips/
    sprite = 474,
    scale = 0.7,
    colour = 0,
}
config.coords = { -- U can edit extra coords
    {
        coords = vector3(-1311.01, -1265.27, 4.57),
        blip = true
    },
}

config.policeRaid = {
    active = false,                     -- when true the cops can raid
    jobs = {
        police = {                     -- Job Name
            [2] = {                    -- Grade Lavel
                ownerNeedOnline = true -- when true, the self storage owner must be online
            },
            [3] = {
                ownerNeedOnline = false
            },
        },
        bcso = {
            [2] = {
                ownerNeedOnline = true -- when true, the self storage owner must be online
            },
            [3] = {
                ownerNeedOnline = false
            },
        }
    }
}

config.rentDayActive = true  -- false olduğunda depolar sınırsız olur, true olduğunda oyuncu her ay ödeme yapması gerekir.
config.rentDay = 7           -- Rental period day
config.reBuyDay = 5          -- After how many days can player pay the rent again?
config.money = 5000          -- Rent Price
config.reSellMoney = 2000    -- Sell Price

config.weightDivision = 1000 -- Divide the maxweight value in config.stash by this value and calculate the value to display in UI

-- Customize the items according to your server. The items written are for example purposes only.
-- EN: you can add extra levels or delete all levels. if you will delete all levels, don't delete default stash, it should always remain. you can edit other levels as you wish.
config.stash = {
    { -- Default Stash (Lvl 1)
        maxweight = 500000,
        slots = 50,
    },
    { -- Lvl 2
        maxweight = 1000000,
        slots = 100,
        money = 10000,
        items = {}
    },
    { -- Lvl 3
        maxweight = 2000000,
        slots = 120,
        money = 20000,
        items = {}
    },
    { -- Lvl 4
        maxweight = 3000000,
        slots = 140,
        money = 30000,
        items = {}
    },
    { -- Lvl 5
        maxweight = 4000000,
        slots = 160,
        money = 40000,
        items = {}
    },
    { -- Lvl 6
        maxweight = 5000000,
        slots = 180,
        money = 50000,
        items = {}
    },
    { -- Lvl 7
        maxweight = 6000000,
        slots = 200,
        money = 60000,
        items = {}
    },
}

config.langs = {} -- Don't change
