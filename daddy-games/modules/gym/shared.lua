-- =========================================================================
-- daddy-games :: gym :: shared.lua
-- Rutbe / enerji / curume / puanlama matematigi.
-- Client ve server AYNI fonksiyonlari kullanir; boylece UI'in gosterdigi
-- degerle sunucunun hesapladigi deger asla ayrisamaz.
--
-- ONEMLI: Zamana bagli tum fonksiyonlar SUNUCUDA cagrilmalidir (sunucu saati
-- otoritedir). Client bunlari yalnizca sunucudan gelen anlik goruntuyu
-- bicimlendirmek icin kullanir.
-- =========================================================================

GymShared = {}
if not Config.Gym or Config.Gym.Enabled == false then return end

local IS_SERVER = IsDuplicityVersion()

-- =========================================================================
-- ZAMAN YARDIMCILARI
-- =========================================================================

---Gun anahtari (YYYY-MM-DD). Gunluk durum sifirlamasi bunun uzerinden yapilir.
---@param ts number? unix timestamp (varsayilan: simdi)
---@return string
function GymShared.DayKey(ts)
    return os.date('%Y-%m-%d', ts or os.time())
end

---Iki gun anahtari arasindaki tam gun farki.
---@param a string YYYY-MM-DD
---@param b string YYYY-MM-DD
---@return number
function GymShared.DayDiff(a, b)
    if not a or not b then return 0 end
    local ay, am, ad = a:match('(%d+)-(%d+)-(%d+)')
    local by, bm, bd = b:match('(%d+)-(%d+)-(%d+)')
    if not ay or not by then return 0 end

    local at = os.time({ year = tonumber(ay), month = tonumber(am), day = tonumber(ad), hour = 12 })
    local bt = os.time({ year = tonumber(by), month = tonumber(bm), day = tonumber(bd), hour = 12 })
    return math.floor((bt - at) / 86400 + 0.5)
end

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

GymShared.Clamp = clamp

---Dogrusal ara deger.
function GymShared.Lerp(a, b, t)
    return a + (b - a) * clamp(t, 0.0, 1.0)
end

-- =========================================================================
-- RUTBE
-- Efektif rutbe = min(kondisyondan gelen, form puanindan gelen).
-- Kondisyon dusunce rutbe de duser; FP omur boyu birikir ve TAVAN koyar.
-- =========================================================================

---@param condition number 0-100
---@param points number omur boyu form puani
---@return number index, table tier
function GymShared.GetTier(condition, points)
    local tiers = Config.Gym.Tiers
    condition = condition or 0
    points = points or 0

    local byCondition, byPoints = 1, 1
    for i = 1, #tiers do
        if condition >= tiers[i].minCondition then byCondition = i end
        if points >= tiers[i].minPoints then byPoints = i end
    end

    local idx = math.min(byCondition, byPoints)
    return idx, tiers[idx]
end

---Bir sonraki rutbe icin ne eksik? (UI'da "neden yukselmiyorum" sorusunu cevaplar)
---@return table? nextTier, string? blocker 'condition' | 'points'
function GymShared.GetNextTierGap(condition, points)
    local tiers = Config.Gym.Tiers
    local idx = GymShared.GetTier(condition, points)
    local nxt = tiers[idx + 1]
    if not nxt then return nil, nil end

    local needCondition = math.max(0, nxt.minCondition - (condition or 0))
    local needPoints = math.max(0, nxt.minPoints - (points or 0))

    return {
        tier = nxt,
        needCondition = needCondition,
        needPoints = needPoints,
    }, (needCondition > 0 and 'condition' or 'points')
end

-- =========================================================================
-- KAPASITE — kondisyonun somut karsiligi
-- ---------------------------------------------------------------------------
-- "Formumu artirirsam daha fazla set atabilir miyim?" sorusunun cevabi burasi.
-- Kondisyon 0 -> 100 arasinda dogrusal interpolasyon yapilir:
--     enerji tavani, rejenerasyon hizi, set basina tekrar, gunluk kondisyon
--     tavani ve acilan en yuksek agirlik kademesi.
-- =========================================================================

---@param condition number 0-100
---@return table { ratio, energyMax, regenHours, repMult, dailyCap, precision }
function GymShared.GetCapacity(condition)
    local c = Config.Gym.Capacity
    local r = clamp((condition or 0) / Config.Gym.Lifecycle.ConditionMax, 0.0, 1.0)

    return {
        ratio      = r,
        energyMax  = GymShared.Lerp(c.EnergyMaxBase,  c.EnergyMaxPeak,  r),
        regenHours = GymShared.Lerp(c.RegenHoursBase, c.RegenHoursPeak, r),
        repMult    = GymShared.Lerp(c.RepMultBase,    c.RepMultPeak,    r),
        dailyCap   = GymShared.Lerp(c.DailyCapBase,   c.DailyCapPeak,   r),
        precision  = 1.0 + c.PrecisionBonus * r,
    }
end

-- =========================================================================
-- ENERJI (gunluk yorgunluk siniri)
-- Rejenerasyon GERCEK saate baglidir, oyunda gecirilen sureye degil.
-- Boylece "sunucuda bekleyip enerji doldurma" diye bir sey olmaz.
-- =========================================================================

---Aktif buff'lari ve KONDISYONU hesaba katan enerji tavani.
function GymShared.GetEnergyMax(stats, now)
    now = now or os.time()
    local base = GymShared.GetCapacity(stats.condition_score).energyMax

    local buffs = stats.active_buffs
    if type(buffs) == 'table' then
        local bonus = buffs.energymax
        if type(bonus) == 'table' and (bonus.until_ts or 0) > now then
            base = base + (bonus.amount or 0)
        end
    end

    return base
end

---Kondisyona gore rejenerasyon suresi (saat).
function GymShared.GetRegenHours(stats)
    return GymShared.GetCapacity(stats.condition_score).regenHours
end

---Gecen sureye gore enerjiyi tazeler. stats'i YERINDE gunceller.
function GymShared.RegenEnergy(stats, now)
    now = now or os.time()

    local last = stats.energy_ts or now
    local elapsed = now - last
    if elapsed <= 0 then
        stats.energy_ts = now
        return
    end

    local maxEnergy = GymShared.GetEnergyMax(stats, now)
    local perSecond = maxEnergy / (GymShared.GetRegenHours(stats) * 3600.0)

    stats.energy = clamp((stats.energy or maxEnergy) + elapsed * perSecond, 0.0, maxEnergy)
    stats.energy_ts = now
end

---Enerjinin tam dolmasina kalan saniye (0 = dolu).
function GymShared.SecondsUntilFullEnergy(stats, now)
    now = now or os.time()
    local maxEnergy = GymShared.GetEnergyMax(stats, now)
    local missing = maxEnergy - (stats.energy or 0)
    if missing <= 0 then return 0 end

    local perSecond = maxEnergy / (GymShared.GetRegenHours(stats) * 3600.0)
    return math.ceil(missing / perSecond)
end

-- =========================================================================
-- KONDISYON CURUMESI
-- Antrenman birakilirsa kondisyon (ve ona bagli TUM perk'ler) duser.
-- Yuksek seri "kas hafizasi" saglar ve curumeyi yariya indirir.
-- =========================================================================

---Son antrenmandan bu yana gecen sureye gore kondisyonu dusurur.
---stats'i YERINDE gunceller. Dusen puan miktarini dondurur.
---@return number lostAmount
function GymShared.ApplyDecay(stats, now)
    now = now or os.time()
    local lc = Config.Gym.Lifecycle

    local lastTrain = stats.last_train_ts
    if not lastTrain or lastTrain <= 0 then
        stats.decay_ts = now
        return 0
    end

    -- Curume, en son uygulandigi andan itibaren hesaplanir (cift sayim olmasin)
    local from = math.max(stats.decay_ts or lastTrain, lastTrain)
    if now <= from then return 0 end

    local hoursIdle = (now - lastTrain) / 3600.0
    if hoursIdle < lc.DecayStartHours then
        stats.decay_ts = now
        return 0
    end

    -- Curumenin gercekten basladigi an
    local decayBegin = lastTrain + lc.DecayStartHours * 3600.0
    local effectiveFrom = math.max(from, decayBegin)
    if now <= effectiveFrom then
        stats.decay_ts = now
        return 0
    end

    local hardBegin = lastTrain + lc.DecayHardAfterHours * 3600.0
    local normalSeconds = math.max(0, math.min(now, hardBegin) - effectiveFrom)
    local hardSeconds = math.max(0, now - math.max(effectiveFrom, hardBegin))

    local lost = (normalSeconds / 86400.0) * lc.DecayPerDay
                 + (hardSeconds / 86400.0) * lc.DecayPerDayHard

    if (stats.streak_days or 0) >= lc.StreakShieldDays then
        lost = lost * 0.5
    end

    local before = stats.condition_score or 0.0
    stats.condition_score = clamp(before - lost, 0.0, lc.ConditionMax)
    stats.decay_ts = now

    return before - stats.condition_score
end

-- =========================================================================
-- PERK'LER (kondisyonun gercek oyun ici karsiligi)
-- =========================================================================

---@param condition number 0-100
---@return table { stamina, strength, lung, meleeMult, maxHealth, ratio }
function GymShared.GetPerks(condition)
    local p = Config.Gym.Perks
    local ratio = clamp((condition or 0) / Config.Gym.Lifecycle.ConditionMax, 0.0, 1.0)

    return {
        ratio     = ratio,
        stamina   = math.floor(GymShared.Lerp(p.StaminaMin, p.StaminaMax, ratio) + 0.5),
        strength  = math.floor(GymShared.Lerp(p.StrengthMin, p.StrengthMax, ratio) + 0.5),
        lung      = math.floor(GymShared.Lerp(p.LungMin, p.LungMax, ratio) + 0.5),
        meleeMult = GymShared.Lerp(p.MeleeMultMin, p.MeleeMultMax, ratio),
        maxHealth = math.floor(GymShared.Lerp(p.MaxHealthMin, p.MaxHealthMax, ratio) + 0.5),
    }
end

-- =========================================================================
-- GUNLUK DURUM (daily_state)
-- Gun degistiginde sifirlanir. Set sayaclari, kas grubu yuku ve program
-- ilerlemesi burada tutulur.
-- =========================================================================

function GymShared.NewDailyState(dayKey)
    return {
        day = dayKey or GymShared.DayKey(),
        sets = {},            -- [exerciseId] = setSayisi
        groups = {},          -- [muscleGroup] = { sets = n, soreUntil = ts }
        conditionGained = 0.0,
        energySpent = 0.0,
        programId = false,
        programProgress = {}, -- [exerciseId] = tamamlanan set sayisi
        programDone = false,
        totalSets = 0,
    }
end

---Gun degistiyse durumu sifirlar. Degisiklik olduysa true doner.
---@return boolean rolled, string? previousDay
function GymShared.RollDailyState(stats, now)
    now = now or os.time()
    local today = GymShared.DayKey(now)
    local daily = stats.daily_state

    if type(daily) ~= 'table' or not daily.day then
        stats.daily_state = GymShared.NewDailyState(today)
        return true, nil
    end

    if daily.day == today then
        -- Eski/bozuk kayitlarda eksik alt tablolari tamamla
        daily.sets = daily.sets or {}
        daily.groups = daily.groups or {}
        daily.programProgress = daily.programProgress or {}
        daily.conditionGained = daily.conditionGained or 0.0
        daily.energySpent = daily.energySpent or 0.0
        daily.totalSets = daily.totalSets or 0
        return false, nil
    end

    local previous = daily.day
    stats.daily_state = GymShared.NewDailyState(today)
    return true, previous
end

---Kas grubu tutulu mu? (DOMS)
function GymShared.IsMuscleSore(stats, group, now)
    now = now or os.time()
    local daily = stats.daily_state
    if type(daily) ~= 'table' then return false end

    local g = daily.groups and daily.groups[group]
    if type(g) ~= 'table' then return false end

    return (g.soreUntil or 0) > now
end

---O gun bir egzersizden kac set yapilmis?
function GymShared.SetsToday(stats, exerciseId)
    local daily = stats.daily_state
    if type(daily) ~= 'table' or type(daily.sets) ~= 'table' then return 0 end
    return daily.sets[exerciseId] or 0
end

-- =========================================================================
-- GUNLUK PROGRAM
-- Program, (citizenid + gun) uzerinden DETERMINISTIK secilir; sunucu yeniden
-- baslasa da o gunun programi degismez.
-- =========================================================================

local function stableHash(str)
    local h = 5381
    for i = 1, #str do
        h = (h * 33 + str:byte(i)) % 2147483647
    end
    return h
end

---O gun icin uygun programi secer (rutbeye gore filtreli).
---@return table? program
function GymShared.PickProgram(citizenid, condition, points, dayKey)
    local tierIdx = GymShared.GetTier(condition, points)
    local pool = {}

    for i = 1, #Config.Gym.Programs do
        local prog = Config.Gym.Programs[i]
        if tierIdx >= (prog.minTier or 1) then
            pool[#pool + 1] = prog
        end
    end

    if #pool == 0 then return Config.Gym.Programs[1] end

    local seed = stableHash(tostring(citizenid) .. '|' .. tostring(dayKey or GymShared.DayKey()))
    return pool[(seed % #pool) + 1]
end

---Programin kalan kalemlerini dondurur.
---@return table items { ex, label, done, need, complete }, boolean allDone
function GymShared.ProgramStatus(stats)
    local daily = stats.daily_state
    if type(daily) ~= 'table' or not daily.programId then return {}, false end

    local program
    for i = 1, #Config.Gym.Programs do
        if Config.Gym.Programs[i].id == daily.programId then
            program = Config.Gym.Programs[i]
            break
        end
    end
    if not program then return {}, false end

    local items, allDone = {}, true
    for i = 1, #program.items do
        local item = program.items[i]
        local exData = Config.Gym.Exercises[item.ex]
        local done = (daily.programProgress and daily.programProgress[item.ex]) or 0
        local complete = done >= item.sets

        if not complete then allDone = false end

        items[#items + 1] = {
            ex = item.ex,
            label = exData and exData.label or item.ex,
            short = exData and exData.short or item.ex,
            icon = exData and exData.icon or 'dumbbell',
            muscle = exData and exData.muscle or 'full',
            done = done,
            need = item.sets,
            complete = complete,
        }
    end

    return items, allDone
end

---Bu set programin bir kalemine sayiyor mu?
function GymShared.CountsForProgram(stats, exerciseId)
    local daily = stats.daily_state
    if type(daily) ~= 'table' or not daily.programId or daily.programDone then return false end

    for i = 1, #Config.Gym.Programs do
        local prog = Config.Gym.Programs[i]
        if prog.id == daily.programId then
            for j = 1, #prog.items do
                local item = prog.items[j]
                if item.ex == exerciseId then
                    local done = (daily.programProgress and daily.programProgress[exerciseId]) or 0
                    return done < item.sets
                end
            end
            return false
        end
    end

    return false
end

-- =========================================================================
-- SET PARAMETRELERI — TEK KAYNAK
-- ---------------------------------------------------------------------------
-- Bir setin butun sayilari (tekrar, tempo, bant, nefes, enerji, odul) burada
-- uretilir. Sunucu bunu otorite olarak, client de onizleme icin cagirir;
-- boylece UI'in gosterdigi ile sunucunun uyguladigi asla ayrisamaz.
-- =========================================================================

---Azalan getiri: ayni egzersizin o gunku (setIndex+1). seti
function GymShared.DiminishFor(setIndex)
    local lc = Config.Gym.Lifecycle
    local tbl = lc.SetDiminishing
    local i = setIndex + 1
    if i <= #tbl then return tbl[i] end
    return lc.SetDiminishingFloor
end

---Aktif buff kaydini dondurur (suresi/adedi dolduysa nil).
local function activeBuff(stats, key, now)
    local buffs = stats.active_buffs
    if type(buffs) ~= 'table' then return nil end

    local b = buffs[key]
    if type(b) ~= 'table' then return nil end
    if b.until_ts and b.until_ts <= now then return nil end
    if b.sets and b.sets <= 0 then return nil end

    return b
end

GymShared.ActiveBuff = activeBuff

-- =========================================================================
-- YORGUNLUK
-- ---------------------------------------------------------------------------
-- Uc kaynaktan tek bir 0..1 skaler: gunluk tukenmislik, kas tutulmasi ve
-- ust uste ayni aleti calisma. Set parametrelerine dort eksende uygulanir.
-- =========================================================================

---@return number fatigue 0..1, table parcalar
function GymShared.GetFatigue(stats, exerciseId, now)
    now = now or os.time()
    local f = Config.Gym.Fatigue
    local ex = Config.Gym.Exercises[exerciseId]

    local energyMax = GymShared.GetEnergyMax(stats, now)
    local drained = 1.0 - clamp((stats.energy or 0) / math.max(1, energyMax), 0.0, 1.0)
    local sore = (ex and GymShared.IsMuscleSore(stats, ex.muscle, now)) and 1.0 or 0.0
    local repeats = clamp(GymShared.SetsToday(stats, exerciseId) / f.RepeatSetsForMax, 0.0, 1.0)

    local total = clamp(
        f.WeightEnergy * drained + f.WeightSore * sore + f.WeightRepeat * repeats,
        0.0, 1.0
    )

    return total, { drained = drained, sore = sore > 0, repeats = repeats }
end

-- =========================================================================
-- AGIRLIK KADEMELERI
-- =========================================================================

---Bir egzersiz icin kademe listesi; kilitli olanlar isaretlenir.
---@return table[] levels, number maxUnlockedIndex
function GymShared.GetLevels(exerciseId, condition)
    local ex = Config.Gym.Exercises[exerciseId]
    local out, maxUnlocked = {}, 1

    for i, lv in ipairs(Config.Gym.Levels) do
        local unlocked = (condition or 0) >= lv.minCondition
        if unlocked then maxUnlocked = i end

        out[i] = {
            index = i,
            id = lv.id,
            label = (ex and ex.levelLabels and ex.levelLabels[i]) or lv.label,
            minCondition = lv.minCondition,
            unlocked = unlocked,
        }
    end

    return out, maxUnlocked
end

---Kademe secimini dogrular; gecersizse en yuksek acik kademeye duser.
---@return number levelIndex, boolean wasValid
function GymShared.ClampLevel(exerciseId, condition, levelIndex)
    local _, maxUnlocked = GymShared.GetLevels(exerciseId, condition)
    local i = math.floor(tonumber(levelIndex) or 0)

    if i < 1 then return math.min(3, maxUnlocked), true end   -- varsayilan: Normal
    if i > maxUnlocked then return maxUnlocked, false end

    return i, true
end

-- =========================================================================
-- BUILD SET PARAMS — bir setin TUM sayilari
-- =========================================================================

---@param stats table
---@param exerciseId string
---@param levelIndex number secilen agirlik kademesi
---@param now number?
---@return table? params
function GymShared.BuildSetParams(stats, exerciseId, levelIndex, now)
    now = now or os.time()

    local ex = Config.Gym.Exercises[exerciseId]
    if not ex then return nil end

    local lc  = Config.Gym.Lifecycle
    local dif = Config.Gym.Difficulty
    local fcf = Config.Gym.Fatigue

    local cap = GymShared.GetCapacity(stats.condition_score)
    local lvlIndex = GymShared.ClampLevel(exerciseId, stats.condition_score, levelIndex)
    local lvl = Config.Gym.Levels[lvlIndex]
    local lvlLabel = (ex.levelLabels and ex.levelLabels[lvlIndex]) or lvl.label

    local fatigue, parts = GymShared.GetFatigue(stats, exerciseId, now)
    local setIndex = GymShared.SetsToday(stats, exerciseId)
    local inProgram = GymShared.CountsForProgram(stats, exerciseId)

    -- ---- Enerji maliyeti -------------------------------------------------
    local energyCost = ex.energyCost * lvl.energy * (1.0 + lc.SameExerciseEnergyStep * setIndex)
    if parts.sore then energyCost = energyCost * lc.MuscleSoreEnergyMult end

    local crashUntil = (type(stats.active_buffs) == 'table' and stats.active_buffs.focus_crash) or 0
    if crashUntil > now then
        energyCost = energyCost * (Config.Gym.Supplements.CrashEnergyMult or 1.20)
    end

    -- ---- Takviye buff'lari -----------------------------------------------
    local focus  = activeBuff(stats, 'focus', now)
    local breath = activeBuff(stats, 'breath', now)
    local grip   = activeBuff(stats, 'grip', now)

    -- ---- Kabul bandi: kademe x kondisyon x yorgunluk x takviye ------------
    local windowMs = ex.perfectWindowMs
        * lvl.window
        * cap.precision
        * GymShared.Lerp(1.0, fcf.WindowMultPeak, fatigue)
        * (focus and (focus.windowMult or 1.0) or 1.0)

    -- ---- Nefes ------------------------------------------------------------
    local drain = ex.breathDrainPerSec
        * GymShared.Lerp(1.0, fcf.DrainMultPeak, fatigue)
        * (breath and (breath.mult or 1.0) or 1.0)

    -- ---- Tekrar hedefi: KONDISYON x KADEME --------------------------------
    local targetReps = math.max(4, math.floor(ex.targetReps * cap.repMult * lvl.reps + 0.5))

    -- ---- Kazanc / odul ----------------------------------------------------
    local gainMult = GymShared.DiminishFor(setIndex)
    if parts.sore then gainMult = gainMult * lc.MuscleSoreGainMult end
    if inProgram then gainMult = gainMult * lc.ProgramGainMult end

    local restMult = (type(stats.active_buffs) == 'table'
        and type(stats.active_buffs.rest) == 'table'
        and stats.active_buffs.rest.mult) or 1.0

    return {
        exercise    = exerciseId,
        mechanic    = ex.mechanic or 'tap',
        label       = ex.label,
        short       = ex.short,
        icon        = ex.icon,
        muscle      = ex.muscle,
        muscleLabel = (Config.Gym.MuscleGroups[ex.muscle] or {}).label,

        level     = { index = lvlIndex, id = lvl.id, label = lvlLabel },
        setIndex  = setIndex + 1,
        inProgram = inProgram,

        -- Zorluk
        targetReps       = targetReps,
        tempoMs          = ex.tempoMs,
        perfectWindowMs  = math.max(dif.WindowMinMs, math.floor(windowMs + 0.5)),
        goodMult         = dif.GoodMult,
        windowRampPerRep = dif.WindowRampPerRep,
        windowRampFloor  = dif.WindowRampFloor,
        tempoRampPerRep  = dif.TempoRampPerRep,
        tempoRampFloor   = dif.TempoRampFloor,
        windowMinMs      = dif.WindowMinMs,
        jitter           = GymShared.Lerp(fcf.JitterBase, fcf.JitterPeak, fatigue),
        missedCycleCounts = dif.MissedCycleCounts,

        -- Nefes
        breathDrainPerSec = drain,
        startBreath       = GymShared.Lerp(100.0, fcf.StartBreathPeak, fatigue),
        missMult          = grip and (grip.missMult or 1.0) or 1.0,
        breathPerfect     = dif.BreathPerfect,
        breathGood        = dif.BreathGood,
        breathMiss        = dif.BreathMiss,
        breathSkip        = dif.BreathSkip,
        comboBreathBonus  = dif.ComboBreathBonus,

        -- Mekanige ozel
        hold          = ex.hold,
        holdTolerance = GymShared.Lerp(1.0, fcf.HoldTolerancePeak, fatigue),
        comboLen      = (ex.mechanic == 'combo' and ex.combo) and (ex.combo.lenByLevel[lvlIndex] or 1) or nil,
        comboPerKeyMs = ex.combo and ex.combo.perKeyMs or nil,
        grip          = ex.grip,

        -- Ekonomi
        energyCost = math.floor(energyCost * 10 + 0.5) / 10,
        gainMult   = gainMult,
        pointMult  = lvl.points * (focus and (focus.pointMult or 1.0) or 1.0),
        restMs     = math.floor(lc.RestBetweenSetsMs * restMult),

        -- HUD gostergeleri
        fatigue  = fatigue,
        isSore   = parts.sore,
        dailyCap = cap.dailyCap,
        capacity = { repMult = cap.repMult, energyMax = cap.energyMax, ratio = cap.ratio },

        minRepMs = ex.minRepMs,
        maxRepMs = ex.maxRepMs,
    }
end

---Set BITTIKTEN sonra set-bazli buff sayaclarini dusurur.
function GymShared.ConsumeSetBuffs(stats)
    local buffs = stats.active_buffs
    if type(buffs) ~= 'table' then return end

    for _, key in ipairs({ 'breath', 'focus', 'grip' }) do
        local b = buffs[key]
        if type(b) == 'table' and b.sets then
            b.sets = b.sets - 1
            if b.sets <= 0 then
                if key == 'focus' and b.crashMs then
                    buffs.focus_crash = os.time() + math.floor(b.crashMs / 1000)
                end
                buffs[key] = nil
            end
        end
    end
end

-- =========================================================================
-- SET PUANLAMASI (otorite: SUNUCU)
-- ---------------------------------------------------------------------------
-- Client yalnizca ham sayaclari bildirir; puana cevirme isi burada yapilir.
-- Odul egrisi eskisinden BELIRGIN daha dik: kusursuz oynamak ozensiz
-- oynamaktan %33 degil, ~%140 daha iyi (ustune combo carpani).
-- =========================================================================

---Form kalitesi 0..1
function GymShared.FormQuality(reps, perfect, good)
    if (reps or 0) <= 0 then return 0.0 end
    return clamp(((perfect or 0) * 1.0 + (good or 0) * 0.6) / reps, 0.0, 1.0)
end

---@param result table { reps, perfect, good, miss, bestCombo }
---@param params table GymShared.BuildSetParams ciktisi
function GymShared.ScoreSet(stats, exerciseId, result, params)
    local ex = Config.Gym.Exercises[exerciseId]
    local dif = Config.Gym.Difficulty
    if not ex then return { fp = 0, condition = 0.0, quality = 0.0, qualityMult = 0.0 } end

    local reps = math.max(0, math.floor(result.reps or 0))
    local quality = GymShared.FormQuality(reps, result.perfect, result.good)

    -- 0.25 (berbat form) .. 1.30 (kusursuz form)
    local qualityMult = dif.QualityBase + dif.QualitySlope * quality

    -- Ardisik PERFECT serisi ek carpan verir
    local comboRatio = clamp((result.bestCombo or 0) / dif.ComboFullAt, 0.0, 1.0)
    local comboMult = 1.0 + dif.ComboBonusMax * comboRatio

    local fp = reps * (ex.pointsPerRep or 5)
        * qualityMult * comboMult * params.gainMult * params.pointMult
    fp = math.floor(fp + 0.5)

    -- Kondisyon: gunluk tavana kadar (tavan kondisyonla DUSER)
    local daily = stats.daily_state or {}
    local remainingCap = math.max(0.0, (params.dailyCap or 12.0) - (daily.conditionGained or 0.0))

    local condition = (ex.conditionPerSet or 2.0) * qualityMult * params.gainMult
    condition = condition * clamp(reps / math.max(1, params.targetReps), 0.0, 1.0)
    condition = math.min(condition, remainingCap)

    local out = {
        fp = fp,
        condition = condition,
        quality = quality,
        qualityMult = qualityMult,
        comboMult = comboMult,
        cappedByDaily = (remainingCap <= 0.001),
    }

    -- Boks torbasi "guc skoru" olarak kaydedilir, tekrar sayisi olarak degil.
    if ex.isPowerScore then
        local tierIdx = GymShared.GetTier(stats.condition_score, stats.fitness_points)
        local tierFactor = 0.70 + 0.30 * ((tierIdx - 1) / math.max(1, #Config.Gym.Tiers - 1))
        local volume = clamp(reps / math.max(1, params.targetReps), 0.0, 1.0)
        local levelFactor = 0.80 + 0.20 * ((params.level.index - 1) / 4)

        local power = (0.35 + 0.65 * quality) * (0.60 + 0.40 * volume)
            * (ex.powerScoreMax or 999) * tierFactor * levelFactor
        out.powerScore = math.floor(clamp(power, 0, ex.powerScoreMax or 999) + 0.5)
    end

    return out
end

-- =========================================================================
-- ANIMASYON COZUCU (yalnizca client)
-- Config'deki aday listesini gezer, DoesAnimDictExist gecen ILK adayi doner.
-- Hicbiri yoksa scenario'ya duser. Yanlis bir dict adi sistemi KIRMAZ.
-- =========================================================================

if not IS_SERVER then
    ---@param exData table Config.Gym.Exercises[...]
    ---@param isMale boolean
    ---@return table? { dict, clip } , string? scenario
    function GymShared.ResolveAnim(exData, isMale)
        local animCfg = exData and exData.anim
        if not animCfg then return nil, nil end

        -- Once kendi cinsiyetinin listesi, sonra digerininki denenir.
        -- (Bir egzersizde yalnizca tek cinsiyet tanimliysa yine de calisir.)
        local primary = (isMale and animCfg.male or animCfg.female) or {}
        local fallback = (isMale and animCfg.female or animCfg.male) or {}

        for _, list in ipairs({ primary, fallback }) do
            for i = 1, #list do
                local c = list[i]
                if c.dict and DoesAnimDictExist(c.dict) then
                    return c, animCfg.scenario
                end
            end
        end

        return nil, animCfg.scenario
    end

    ---Cikis animasyonu icin ayni cozumleme.
    function GymShared.ResolveExitAnim(exData)
        local animCfg = exData and exData.anim
        if not animCfg or type(animCfg.exit) ~= 'table' then return nil end

        for i = 1, #animCfg.exit do
            local c = animCfg.exit[i]
            if c.dict and DoesAnimDictExist(c.dict) then return c end
        end

        return nil
    end
end
