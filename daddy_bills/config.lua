Config = {}

Config.Locale = 'tr'                -- en | tr | de | fr | es | pt | pl
Config.Framework = 'auto'           -- auto | esx | qb | qbox | standalone
Config.Society = 'custom'           -- DaddyRP: can9work-funds (bridge/society/custom.lua). where job bills are paid: auto | esx | qb (Renewed-Banking, qb-banking, qb-management) | custom (bridge/society/custom.lua)
Config.Currency = '$'
Config.NumberPrefix = 'INV-'
Config.VersionCheck = true          -- tells in the console when a newer version is out

Config.Command = 'faturakes'        -- opens the tablet, false to turn it off
Config.ListCommand = 'faturalarım' -- opens the tablet on the player's own bills (inbox), false to turn it off
Config.Key = false                  -- DaddyRP: no key. default key of the tablet, players can change it, false for none (esx_billing also uses F7)

-- the tablet in the hand while it is open, false for none
Config.Tablet = {
    prop = 'prop_cs_tablet', bone = 28422, offset = vec3(0.0, -0.03, 0.0), rotation = vec3(20.0, -90.0, 0.0),
    dict = 'amb@code_human_in_bus_passenger_idles@female@tablet@idle_a', anim = 'idle_a',
}
-- admins: anyone allowed every command (add_ace group.admin command allow), this ace, or one of these framework groups
Config.AdminAce = 'daddy_bills.admin'
Config.AdminGroups = { 'admin', 'superadmin', 'god' }
Config.AdminCommand = 'billsadmin'   -- opens the menu on the admin screen, false to turn it off
Config.MaxCommission = 50            -- the highest commission a boss can give a grade

Config.Range = 5.0                  -- how close a player has to be to receive a bill in person
Config.MaxAmount = 1000000
Config.MaxLines = 20
Config.Tax = 0                      -- default tax percent of a line
Config.PayFrom = { 'bank', 'cash' } -- accounts a player may pay from, the first one is the default

-- every player can bill another player, the money goes to the sender
Config.Personal = { enabled = false, maxAmount = 5000, dailyLimit = 20000 }

-- admins bill any player in the city in the name of the state (taxes, fees); society: account the money goes to, false keeps it out of the economy
Config.State = { label = 'Los Santos Belediyesi', society = false }

-- jobs that bill in the name of the job, paid into the society account of the job
-- grade: lowest grade allowed to bill, cancel: lowest grade allowed to cancel, commission: percent for the sender
-- fine: the bills of the job are fines (shown as such, no installments)
-- boss: lowest grade that sees the boss screen; left out it is the boss grade of the framework (grade name 'boss' on ESX, isboss on QBCore)
-- the boss changes grade, commission and the highest bill per grade and the ready items on the tablet, config.lua stays the default and the ceiling
-- DaddyRP: the jobs that billed under can9work-jobsv2, all alike (every grade bills, 10% to the sender);
-- cancel = 99: only the sender, the boss or an admin cancels. The police jobs write fines.
Config.Jobs = {
    police          = { label = 'PD', grade = 0, cancel = 99, commission = 10, fine = true },
    sasp            = { label = 'SASP', grade = 0, cancel = 99, commission = 10, fine = true },
    sapr            = { label = 'PR', grade = 0, cancel = 99, commission = 10, fine = true },
    dp              = { label = 'DP', grade = 0, cancel = 99, commission = 10, fine = true },
    bcso            = { label = 'SD', grade = 0, cancel = 99, commission = 10, fine = true },
    pbsd            = { label = 'PBSD', grade = 0, cancel = 99, commission = 10, fine = true },
    cppd            = { label = 'CPPD', grade = 0, cancel = 99, commission = 10, fine = true },
    gunshop1        = { label = 'Silahçı 1', grade = 0, cancel = 99, commission = 10 },
    gunshop2        = { label = 'Silahçı 2', grade = 0, cancel = 99, commission = 10 },
    gunshop3        = { label = 'Silahçı 3', grade = 0, cancel = 99, commission = 10 },
    gunshop4        = { label = 'Silahçı 4', grade = 0, cancel = 99, commission = 10 },
    gunshop5        = { label = 'Silahçı 5', grade = 0, cancel = 99, commission = 10 },
    gunshop6        = { label = 'Silahçı 6', grade = 0, cancel = 99, commission = 10 },
    mekanik1        = { label = 'Mekanik 1', grade = 0, cancel = 99, commission = 10 },
    mekanik2        = { label = 'Mekanik 2', grade = 0, cancel = 99, commission = 10 },
    mekanik3        = { label = 'Mekanik 3', grade = 0, cancel = 99, commission = 10 },
    mekanik4        = { label = 'Mekanik 4', grade = 0, cancel = 99, commission = 10 },
    mekanik5        = { label = 'Mekanik 5', grade = 0, cancel = 99, commission = 10 },
    mekanik6        = { label = 'Mekanik 6', grade = 0, cancel = 99, commission = 10 },
    mekanik7        = { label = 'Mekanik 7', grade = 0, cancel = 99, commission = 10 },
    mekanik8        = { label = 'Mekanik 8', grade = 0, cancel = 99, commission = 10 },
    illegalmekanik1 = { label = 'AfterLife Mekanik', grade = 0, cancel = 99, commission = 10 },
    illegalmekanik2 = { label = 'Bunker Mekanik', grade = 0, cancel = 99, commission = 10 },
    ambulance       = { label = 'EMS', grade = 0, cancel = 99, commission = 10 },
    cardealer       = { label = 'PDM', grade = 0, cancel = 99, commission = 10 },
    cardealer2      = { label = 'Auto Luxury', grade = 0, cancel = 99, commission = 10 },
    lojistik1       = { label = 'Lojistik 1', grade = 0, cancel = 99, commission = 10 },
    lojistik2       = { label = 'Lojistik 2', grade = 0, cancel = 99, commission = 10 },
    pawnshop1       = { label = 'Rehinci 1', grade = 0, cancel = 99, commission = 10 },
    pawnshop2       = { label = 'Rehinci 2', grade = 0, cancel = 99, commission = 10 },
    kalpazan1       = { label = 'Kalpazan 1', grade = 0, cancel = 99, commission = 10 },
    kalpazan2       = { label = 'Kalpazan 2', grade = 0, cancel = 99, commission = 10 },
    kalpazan3       = { label = 'Kalpazan 3', grade = 0, cancel = 99, commission = 10 },
    kalpazan4       = { label = 'Kalpazan 4', grade = 0, cancel = 99, commission = 10 },
    news            = { label = 'Haber Merkezi', grade = 0, cancel = 99, commission = 10 },
    tacir1          = { label = 'Tacir 1', grade = 0, cancel = 99, commission = 10 },
    tacir2          = { label = 'Tacir 2', grade = 0, cancel = 99, commission = 10 },
    tacir3          = { label = 'Tacir 3', grade = 0, cancel = 99, commission = 10 },
    tacir4          = { label = 'Tacir 4', grade = 0, cancel = 99, commission = 10 },
    weedcamp        = { label = 'Weedcamp', grade = 0, cancel = 99, commission = 10 },
}

-- ready items a job picks from when it writes a bill, labels as they appear on the bill
Config.Presets = {
    police = {
        { label = 'Hız sınırı aşımı', unit = 1000 },
        { label = 'Kırmızı ışık ihlali', unit = 500 },
        { label = 'Ehliyetsiz araç kullanma', unit = 2500 },
        { label = 'Tehlikeli araç kullanma', unit = 1500 },
        { label = 'Kamu düzenini bozma', unit = 750 },
        { label = 'Polise mukavemet', unit = 5000 },
        { label = 'Ruhsatsız silah taşıma', unit = 10000 },
    },
    ambulance = {
        { label = 'Muayene', unit = 300 },
        { label = 'Acil müdahale', unit = 1000 },
        { label = 'Olay yeri müdahale', unit = 500 },
        { label = 'Ameliyat', unit = 2500 },
        { label = 'İlaç', unit = 200 },
    },
    mekanik1 = {
        { label = 'Tamir kiti', unit = 500 },
        { label = 'Lastik değişimi', unit = 400 },
        { label = 'Motor tamiri', unit = 3000 },
        { label = 'Kaporta tamiri', unit = 1500 },
        { label = 'Çekici hizmeti', unit = 750 },
    },
}
-- DaddyRP: the other police jobs and every mechanic share these lists
for _, job in ipairs({ 'sasp', 'sapr', 'dp', 'bcso', 'pbsd', 'cppd' }) do Config.Presets[job] = Config.Presets.police end
for _, job in ipairs({ 'mekanik2', 'mekanik3', 'mekanik4', 'mekanik5', 'mekanik6', 'mekanik7', 'mekanik8', 'illegalmekanik1', 'illegalmekanik2' }) do
    Config.Presets[job] = Config.Presets.mekanik1
end

-- a bill that comes back by itself (rent, insurance, a subscription), every one of these days
Config.Recurring = { choices = { 7, 14, 30 }, maxPerPlayer = 10 }
Config.Autopay = true               -- a player can let a bill pay itself from the bank on its due date
-- a paid bill leaves a receipt item (install/items explains the item for each inventory); jobOnly: only for bills of a job
Config.Receipt = { enabled = true, item = 'bill_receipt', jobOnly = false }
Config.Templates = { personal = 20, job = 40 }   -- saved bills a player keeps, and a job keeps (saved by its boss)

-- esx_billing is replaced: remove it from server.cfg and the bills of other scripts come here (F7 opens this menu)
Config.EsxBilling = true
-- okokBilling is replaced the same way: its exports and events bill here (remove okokBilling from server.cfg)
Config.OkokBilling = true
-- unpaid bills of the old script are copied here once, at the first start: esx_billing (table billing), qb (table phone_invoices)
Config.Import = { esx_billing = false, qb = false }

Config.Disputes = true              -- the customer can object to a bill, the sender or a manager of the job decides
Config.RemindEveryMinutes = 60      -- how often a sender may remind the customer of an unpaid bill

-- defaults a sender can change on each bill
Config.Due = { days = 3, choices = { 0, 1, 3, 7, 14 } }       -- 0 = no due date
Config.LateFee = { percent = 5, everyHours = 24, cap = 50 }   -- added after the due date, cap is percent of the total
Config.Installments = { max = 6 }                             -- 1 = no installments

Config.RateLimit = { read = 10, write = 4 }

-- a weekly summary of the job in its Discord channel: issued, collected, open debt, the best staff
Config.Reports = {
    -- police = 'https://discord.com/api/webhooks/...',
}

-- every event of a bill in Discord: url gets all of them, jobs get their own bills too; events set to false are not sent
Config.Logs = {
    url = '',
    jobs = {
        -- police = 'https://discord.com/api/webhooks/...',
    },
    identifiers = true,             -- show the license of the players under their names
    events = {
        created = true, paid = true, partial = false, cancelled = true, forgiven = true, fee_waived = true, extended = true,
        disputed = true, dispute_ok = true, dispute_no = true, autopay_failed = true, settings = true,
    },
}
