Config = {}

-- =============================================================================
-- FRAMEWORK SETTINGS
-- =============================================================================
-- 'auto' = Automatic detection (Recommended)
-- 'qbx' = Force QBX-Core
-- 'qb' = Force QBCore
-- 'esx' = Force ESX
Config.Framework = 'auto'

-- =============================================================================
-- GENERAL SETTINGS
-- =============================================================================
-- Debug Levels: 0 = Off, 1 = Errors only, 2 = Warnings, 3 = All (verbose)
Config.Debug = false            -- Enable/disable debug mode (backward compatible)
Config.DebugLevel = 3           -- Debug verbosity level (0-3)
Config.Language = 'tr'          -- Language option: 'en' or 'tr' (from Locales folder)
Config.DistanceToInteract = 2.5 -- NPC interaction distance
Config.TargetSystem = 'auto'    -- 'auto', 'qb-target', 'ox_target', 'qtarget', 'sleepless_interact'

-- =============================================================================
-- HARVEST INTERACTION MODE
-- =============================================================================
-- 'target'   = Use target system (qb-target, ox_target, etc.)
-- 'custom'   = Custom UI prompt (modern, minimal design)
Config.HarvestInteraction = 'custom' -- Harvest interaction mode
Config.HarvestKey = 38               -- E key (for custom mode)

-- =============================================================================
-- UI & INTERACTION SETTINGS
-- =============================================================================
-- 'custom' (Built-in NUI), 'ox_lib', 'framework'
Config.NotifySystem = 'framework'

-- 'framework' (QBCore/QBX/ESX defaults), 'ox_lib'
Config.ProgressBar = 'custom'

-- 'custom' (Built-in Web NUI), 'ox_lib'
Config.TextUI = 'custom'

-- Path to inventory item images (no trailing slash).
-- Common values:
--   'nui://qb-inventory/html/images'   (qb-inventory)
--   'nui://ox_inventory/web/images'    (ox_inventory)
Config.InventoryImagePath = 'nui://ox_inventory/web/images'

-- Note: NPC blip settings are in Config.NPC.blip below

-- =============================================================================
-- NPC SETTINGS
-- Her NPC kendi araç spawn noktasını içerir. Birden fazla NPC ekleyebilirsiniz.
-- =============================================================================
Config.NPC = {
    {
        model    = 'a_m_m_farmer_01',
        coords   = vector4(2554.02, 4668.85, 33.98, 34.32),
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        blip     = {
            enabled = true,
            sprite  = 846,
            color   = 2,
            scale   = 0.8,
            label   = 'Çiftçilik İşleri',
        },
        vehicle  = {
            model          = 'bodhi2',
            spawnPoint     = vector4(2552.66, 4677.09, 33.92, 20.7),
            vehicleDeposit = 100, -- Araç alırken kesilen depozit (0 = ücretsiz, iade edilir)
        },
        -- Tarlalar bu NPC'ye maksimum kaç metre mesafede olabilir (Ana kara tarlaları ~500-1500m mesafede, ada ~6700m uzakta)
        maxFarmDistance = 4000.0,
        -- allowedFarmIds = {}, -- İsteğe bağlı: Belirli tarla ID'leri girilirse sadece onlar görünür (örn: {5, 6, 7, 9, 11, 12})
    },
    -- Eski okul adasındaki çiftçi NPC'si kaldırıldı (2026-11-11): ada sunucudan kalktı, Ada Tarlası (13) kapatıldı.
}


-- =============================================================================
-- JOB ACCESS RESTRICTION
-- =============================================================================
-- mode:
--   'everyone'  → Herkes çiftçilik yapabilir (varsayılan)
--   'whitelist' → Sadece listede yazanlar yapabilir (job VEYA identifier eşleşirse izin verilir)
--   'blacklist' → Listede yazanlar YAPAMAZ (job VEYA identifier eşleşirse engellenir)
--
-- jobs:   Meslek isim listesi (framework job.name değeri)
-- gangs:  Gang isim listesi (QBCore/QBX gang.name değeri, ESX'te boş bırakılabilir)
-- identifiers: Spesifik oyuncu identifier'ları (citizenid / license)
-- =============================================================================
Config.AccessRestriction = {
    mode = 'everyone', -- 'everyone' | 'whitelist' | 'blacklist'
    jobs = {           -- Meslek listesi
        -- 'police',
        -- 'ambulance',
        'beanmachine',
        'pacificbar',
        'paddockbar',
        'pierbar',
        'taco',
        'tacobomb',
        'tequilala',
        'burgershot',
        'tikibar',
        'uwucafe',
    },
    gangs = { -- Gang listesi (QBCore/QBX)
        -- 'ballas',
    },
    identifiers = { -- Spesifik oyuncu identifier'ları
        -- 'ABC12345',
    },
}


-- =============================================================================
-- WORK CLOTHING
-- =============================================================================
Config.WorkClothes = {
    bonus = {
        enabled = true,
        cash    = 0.10, -- +10% para bonusu
        xp      = 0.10, -- +10% XP bonusu
    },
    male = {
        ['tshirt_1'] = 0,  -- gömlek
        ['tshirt_2'] = 0,
        ['torso_1'] = 1360,   -- ceket
        ['torso_2'] = 2,
        ['arms'] = 238,    -- eller
        ['arms_2'] = 0,
        ['pants_1'] = 569, -- bacaklar
        ['pants_2'] = 0,
        ['shoes_1'] = 331, -- ayakkabı
        ['shoes_2'] = 0,
        ['hat_1'] = 264,    -- şapka
        ['hat_2'] = 3,
        ['decals_1'] = 1,  -- arma
        ['decals_2'] = 0,
        ['mask_1'] = 0,    -- maske
        ['mask_2'] = 0,
        ['bproof_1'] = 0,  -- vücut zırhı
        ['bproof_2'] = 0,
        ['bags_1'] = 0,    -- çanta ve paraşüt
        ['bags_2'] = 0,
        ['chain_1'] = 0,   -- atkı ve zincir
        ['chain_2'] = 0,
    },
    female = {
        ['tshirt_1'] = 0,   -- gömlek
        ['tshirt_2'] = 0,
        ['torso_1'] = 2651, -- ceket
        ['torso_2'] = 0,
        ['arms'] = 0,       -- eller
        ['arms_2'] = 0,
        ['pants_1'] = 49,    -- bacaklar
        ['pants_2'] = 0,
        ['shoes_1'] = 580,  -- ayakkabı
        ['shoes_2'] = 0,
        ['mask_1'] = 0,     -- maske
        ['mask_2'] = 0,
        ['hat_1'] = -1,     -- şapka
        ['hat_2'] = 0,
    }
}

-- =============================================================================
-- GROUP SYSTEM
-- =============================================================================
Config.Group = {
    maxMembers = 4,     -- Maximum group members
    inviteTimeout = 30, -- Invite timeout (seconds)
    -- Group Reward Multiplier (Hybrid System)
    -- Solo players get base reward, groups get bonus based on size
    -- Example: 2 players = 1.25x total reward (each gets 62.5% of base)
    -- This incentivizes group play while keeping economy balanced
    rewardMultiplier = {
        [1] = 1.0,  -- Solo: 100% (no bonus)
        [2] = 1.25, -- 2 players: 125% total (+25% bonus)
        [3] = 1.40, -- 3 players: 140% total (+40% bonus)
        [4] = 1.50, -- 4 players: 150% total (+50% bonus)
    },
}

-- =============================================================================
-- MINIGAME SETTINGS
-- =============================================================================
-- duration/perfectZone are controlled by the NUI minigame component itself
-- Only 'steps' (consecutive hits) is configurable from Lua
Config.Minigame = {
    difficulties = {
        easy = {
            steps = 3, -- Consecutive successful hits required
        },
        medium = {
            steps = 5,
        },
        hard = {
            steps = 7,
        }
    },
    -- Perfect Zone: a highlighted zone on the timer bar.
    -- If the player presses the correct key while the timer is within this zone,
    -- the harvest counts as "perfect" → max yield reward.
    perfectZone = {
        enabled = false,  -- false = no perfect zone (all successes are normal)
        size = 15,        -- Zone width as % of the timer bar (5-30 recommended)
        -- Position range: the zone center is randomized between these % values each round
        minPosition = 25, -- Minimum center position (%)
        maxPosition = 75, -- Maximum center position (%)
        -- Reward: perfect harvests use the bonus multiplier from FarmingCycle difficulty
        -- Normal success = base reward, Perfect = base reward * bonusMultiplier (guaranteed)
    }
}

-- =============================================================================
-- JOB CYCLE SYSTEM
-- =============================================================================

Config.Jobs = {

    -- -------------------------------------------------------------------------
    -- Shared difficulty settings (farm + livestock both use this)
    -- -------------------------------------------------------------------------
    difficulties = {
        easy = {
            actionMultiplier = 1.0, -- Aksiyon base: 5s × 1.0 = 5s
            waitMultiplier   = 1.0, -- Bekleme orijinal sürede 30sn
            minigame         = 'easy',
            reward           = 1.0,
            yieldMultiplier  = 1.0,
        },
        medium = {
            actionMultiplier = 1.6, -- Aksiyon: 5s × 1.6 = 8s
            waitMultiplier   = 1.5, -- Bekleme %50 daha uzun 45sn
            minigame         = 'medium',
            reward           = 1.5,
            yieldMultiplier  = 1.5,
        },
        hard = {
            actionMultiplier = 2.2, -- Aksiyon: 5s × 2.2 = 11s
            waitMultiplier   = 2.5, -- Bekleme %150 daha uzun 75sn
            minigame         = 'hard',
            reward           = 2.0,
            yieldMultiplier  = 2.0,
        },
    },

    -- -------------------------------------------------------------------------
    -- Farm: WATER → GROW1 → FERTILIZE → GROW2 → HARVEST
    -- Aksiyon süreleri: Easy=5s | Medium=8s | Hard=11s
    -- -------------------------------------------------------------------------
    farm = {
        phases = {
            water     = { duration = 5000, type = 'action' },
            grow1     = { duration = 30000, type = 'wait' },
            fertilize = { duration = 5000, type = 'action' },
            grow2     = { duration = 30000, type = 'wait' },
            harvest   = { duration = 5000, type = 'action' },
        },
    },

    -- -------------------------------------------------------------------------
    -- Livestock: FEED → GROW → COLLECT → DELIVER
    -- Aksiyon süreleri: Easy=5s | Medium=8s | Hard=11s
    -- -------------------------------------------------------------------------
    livestock = {
        phases = {
            feed    = { duration = 5000, type = 'action' },
            grow    = { duration = 45000, type = 'wait' },
            collect = { duration = 5000, type = 'action' },
            deliver = { duration = 3000, type = 'action' },
        },
    },
}

-- =============================================================================
-- ANTI-CHEAT & SECURITY
-- =============================================================================
Config.Security = {
    distanceCheck = true,     -- Distance check enabled
    maxHarvestDistance = 3.0, -- Maximum harvest distance
    rateLimiting = true,      -- Rate limiting enabled
    maxActionsPerMinute = 30, -- Maximum actions per minute
}

-- =============================================================================
-- MASTERY SYSTEM (per-farm difficulty progression)
-- =============================================================================
-- Difficulty multipliers (reward, bonusChance, etc.) are in Config.Jobs.difficulties
Config.MasterySystem = {
    enabled = true,
    unlockRequirements = {
        medium = 5, -- Easy'yi 5 kez tamamlayınca Medium açılır
        hard = 5,   -- Medium'u 5 kez tamamlayınca Hard açılır
    },
}

-- =============================================================================
-- RANK SYSTEM (work hours based progression)
-- =============================================================================
Config.LevelSystem = {
    maxLevel = 50,
    -- XP formula: how much XP is needed to go from level N to N+1
    -- Formula: baseXp * (level ^ exponent)
    -- Level 1→2: 100, Level 2→3: ~122, Level 10→11: ~412, Level 20→21: ~930
    baseXp = 100,
    exponent = 1.15,
    -- Bonus multiplier applied to job rewards per level
    bonusPerLevel = 0.015, -- Each level adds +1.5% reward bonus (was 1%)
    maxBonus = 1.75,       -- Cap at +75% (Level 50) (was +50%)
    -- XP reward given at end of job (before difficulty/group multipliers)
    baseXpReward = 50,
}

-- =============================================================================
-- COOLDOWN SETTINGS
-- =============================================================================
Config.Cooldown = {
    globalCooldown = 60, -- Global cooldown after any job (seconds)
    -- Region-specific cooldowns are defined per farm in the database
}

-- =============================================================================
-- SKILL TREE (SP earned per level, permanently spent on skills)
-- =============================================================================
Config.SkillTree = {
    pointsPerLevel = 1, -- Her levelda 1 SP
    milestoneBonus = {
        [10] = 1, [20] = 1, [30] = 2, [40] = 2, [50] = 3,
    },
    -- Dal 1: Tarımcı (19 SP) | Dal 2: Hayvancı (16 SP) | Dal 3: Girişimci (17 SP)
    skills = {
        T1 = { label = 'Çevik Eller', branch = 'farmer', cost = 2, requires = {}, levelReq = 0 },
        T2 = { label = 'İkinci Nefes', branch = 'farmer', cost = 2, requires = {}, levelReq = 0 },
        T3 = { label = 'Pratik Bıçak', branch = 'farmer', cost = 3, requires = {}, levelReq = 0 },
        T4 = { label = 'Yeşil Parmak', branch = 'farmer', cost = 4, requires = { 'T1', 'T2' }, levelReq = 0 },
        T5 = { label = 'Bereketli Toprak', branch = 'farmer', cost = 3, requires = { 'T3' }, levelReq = 0 },
        T6 = { label = 'Üçüncü Göz', branch = 'farmer', cost = 5, requires = { 'T4', 'T5' }, levelReq = 20 },

        H1 = { label = 'Hızlı Besleyici', branch = 'livestock', cost = 2, requires = {}, levelReq = 0 },
        H2 = { label = 'Usta Sağıcı', branch = 'livestock', cost = 3, requires = {}, levelReq = 0 },
        H3 = { label = 'Sabırlı Bakıcı', branch = 'livestock', cost = 3, requires = { 'H1' }, levelReq = 0 },
        H4 = { label = 'Verimli Bakım', branch = 'livestock', cost = 3, requires = { 'H2' }, levelReq = 0 },
        H5 = { label = 'Zen Ahırı', branch = 'livestock', cost = 5, requires = { 'H3', 'H4' }, levelReq = 25 },

        O1 = { label = 'Hızlı Dinlenme', branch = 'entrepreneur', cost = 2, requires = {}, levelReq = 0 },
        O2 = { label = 'Deneyim Avcısı', branch = 'entrepreneur', cost = 2, requires = {}, levelReq = 0 },
        O3 = { label = 'Pazarlıkçı', branch = 'entrepreneur', cost = 4, requires = { 'O1' }, levelReq = 0 },
        O4 = { label = 'Takım Ruhu', branch = 'entrepreneur', cost = 4, requires = { 'O2' }, levelReq = 0 },
        O5 = { label = 'Çırak Ustası', branch = 'entrepreneur', cost = 5, requires = { 'O3', 'O4' }, levelReq = 20 },
    },
}
