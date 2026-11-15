Settings = {
    Locale = 'tr',
    TableName = "can9work_addiction",
    GlobalMaxAddiction = 100,

    Thresholds = {
        Low = 25,
        Medium = 50,
        High = 75,
        Critical = 100
    },

    Withdrawal = {
        Enabled = true,
        MinLevel = 40,
        Interval = 600000,
        Shake = true,
        Blur = true,
        SlowWalk = true
    },

    Overdose = {
        Enabled = true,
        MaxUses = 5,
        Window = 60000,
        DeathChance = 10
    },

    Drugs = {
        ["nane"] = {
            label = "Esrar",
            item = "nane",
            increase = 1,
            cooldown = 120000,
            duration = 60000,
            effect = "SmokeWeed",
            -- armor = 80
        },
        ["koko"] = {
            label = "Şeker",
            item = "koko",
            addictionEnabled = true,
            increase = 1,
            cooldown = 120000,
            duration = 60000,
            effect = "CokeBaggyEffect",
            stamina = 100
        },
        ["meth"] = {
            label = "Kristal",
            item = "meth",
            increase = 1,
            cooldown = 120000,
            duration = 60000,
            effect = "MethBagEffect",
            speed = 1.1
        },
        ["nostress"] = {
            label = "NoStress",
            item = "nostress",
            increase = 2,
            cooldown = 180000,
            duration = 120000,
            effect = "EcstasyEffect",
            need = { drug = "koko", level = 25 }
        },
        ["cigar"] = {
            label = "Hush",
            item = "cigar",
            increase = 1,
            cooldown = 30000,
            duration = 30000,
            effect = "CigarEffect"
        }
    },

    Antidotes = {
        ["antidote_weed"] = { drug = "nane", cooldown = 60000 },
        ["antidote_koko"] = { drug = "koko", cooldown = 60000 },
        ["antidote_meth"] = { drug = "meth", cooldown = 60000 },
        ["antidote_nostress"] = { drug = "nostress", cooldown = 60000 },
        ["antidote_cigar"] = { drug = "cigar", cooldown = 60000 }
    },

    DynamicCooldown = {
        Enabled = true,
        BaseDrug = "nane",        -- Cooldown süresini dinamik etkileyen ana madde
        SweetSpot = 50,           -- Zirve tolerans noktası (%50 nane)
        MaxReduction = 0.50,      -- Zirve toleransta sağlanacak maksimum indirim (%50)
        PenaltyPerPoint = 0.03    -- 50'nin üzerindeki her +1 puan için eklenecek ceza süresi (+%3)
    },

    CigarCK = {
        Enabled = false, -- Huş bağımlılığından 7 gün sonra CK / karakter silme mekaniği (false: tamamen kapalı)
        Days = 7,
    }
}
