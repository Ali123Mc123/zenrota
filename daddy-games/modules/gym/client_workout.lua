-- =========================================================================
-- daddy-games :: gym :: client_workout.lua
-- Set motoru — uc mekanik + kurulum seridi.
--
-- MEKANIKLER
--   tap    tek basis (SPACE)                      sinav, mekik, dambil
--   hold   bas-TUT-birak (iki pencere)            bench, barfiks
--   combo  tus dizisi (sol tik / sag tik)         boks torbasi
--   grip   halat cekme (duello, client_duels.lua) bilek guresi
--
-- TASARIM NOTLARI
--  * HUD ODAK ALMAZ (SetNuiFocus cagrilmaz). Tuslar Lua tarafinda
--    IsDisabledControlJustPressed ile okunur; NUI yalnizca gorsel katmandir.
--  * Setin TUM sayilari sunucudan gelir (GymShared.BuildSetParams). Client
--    hicbir zorluk degeri uretmez; yalnizca uygular ve ham sayaci bildirir.
--  * Hakemlik (PERFECT/IYI/BOZUK) DAIMA Lua'dadir; JS sadece cizer.
--  * Guvenlik: olum, arac, kelepce, uzaklasma veya resource stop -> set
--    aninda iptal edilir ve ped HER durumda cozulur.
-- =========================================================================

GymWorkout = {}
if not Config.Gym or Config.Gym.Enabled == false then return end

local busy          = false
local activeSession = nil
local attachedProps = {}
local restUntil     = 0
local lastReason    = nil

-- Kontroller
local C_HIT   = 22    -- SPACE
local C_LEFT  = 24    -- sol tik
local C_RIGHT = 25    -- sag tik
local C_OK    = 38    -- E
local C_PREV  = 34    -- A
local C_NEXT  = 35    -- D
local C_STOP  = 73    -- X
local C_STOP2 = 202   -- ESC

local ABORT = { reason = nil }

function GymWorkout.IsBusy() return busy end
function GymWorkout.Abort(reason) ABORT.reason = reason or 'interrupted' end
function GymWorkout.IsAborted() return ABORT.reason ~= nil end
function GymWorkout.ClearAbort() ABORT.reason = nil end

local function hud(action, data)
    SendNUIMessage({ action = 'gym:hud:' .. action, data = data })
end

GymWorkout.Hud = hud

-- =========================================================================
-- PROP & ANIMASYON
-- =========================================================================
local function cleanupProps()
    for i = 1, #attachedProps do
        if DoesEntityExist(attachedProps[i]) then DeleteEntity(attachedProps[i]) end
    end
    attachedProps = {}
end

local function attachProp(ped, modelName, bone, offset, rotation)
    local hash = joaat(modelName)
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then return nil end

    lib.requestModel(hash, 5000)
    if not HasModelLoaded(hash) then return nil end

    local c = GetEntityCoords(ped)
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local prop = CreateObject(hash, c.x, c.y, c.z, true, true, false)

    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, bone),
        offset.x, offset.y, offset.z, rotation.x, rotation.y, rotation.z,
        true, true, false, true, 1, true)

    SetModelAsNoLongerNeeded(hash)
    attachedProps[#attachedProps + 1] = prop
    return prop
end

---Ped'i istasyona oturtur. exData.snapToGround == false ise zemin hizalamasi
---ATLANIR (bench gibi alet uzerinde yapilan egzersizlerde ped yere duserdi).
local function placePed(ped, stand, exData)
    local z = stand.z

    if not exData or exData.snapToGround ~= false then
        local found, groundZ = GetGroundZFor_3dCoord(stand.x, stand.y, stand.z + 1.0, false)
        if found and math.abs(groundZ - stand.z) < 2.0 then z = groundZ end
    end

    SetEntityCoordsNoOffset(ped, stand.x, stand.y, z, false, false, false)
    SetEntityHeading(ped, stand.w or 0.0)
end

local function startExerciseAnim(ped, exData)
    local anim, scenario = GymShared.ResolveAnim(exData, IsPedMale(ped))

    if anim then
        lib.requestAnimDict(anim.dict, 3000)
        if HasAnimDictLoaded(anim.dict) then
            TaskPlayAnim(ped, anim.dict, anim.clip, 4.0, -4.0, -1, 1, 0, false, false, false)
            return
        end
    end

    if scenario then TaskStartScenarioInPlace(ped, scenario, 0, true) end
end

---Cikis animasyonu ClearPedTasks'tan ONCE oynatilir ki ped firlamasin.
local function playExitAnim(ped, exData)
    local exit = GymShared.ResolveExitAnim(exData)
    if not exit then ClearPedTasks(ped) return end

    lib.requestAnimDict(exit.dict, 2000)
    if not HasAnimDictLoaded(exit.dict) then ClearPedTasks(ped) return end

    TaskPlayAnim(ped, exit.dict, exit.clip, 4.0, -4.0, 1600, 0, 0, false, false, false)
    Wait(1500)
    ClearPedTasks(ped)
end

---Ped'i her kosulda serbest birakir.
---Not: SetEntityInvincible'a DOKUNULMAZ; baska scriptin ayarini ezmemek icin.
local function releasePed(ped)
    FreezeEntityPosition(ped, false)
    cleanupProps()
end

local function blockControls()
    DisableControlAction(0, C_HIT, true)
    DisableControlAction(0, C_LEFT, true)
    DisableControlAction(0, C_RIGHT, true)
    DisableControlAction(0, C_OK, true)
    DisableControlAction(0, 140, true)
    DisableControlAction(0, 141, true)
    DisableControlAction(0, 142, true)
end

-- =========================================================================
-- MEKANIK STRATEJILERI
-- ---------------------------------------------------------------------------
-- Her strateji iki fonksiyon saglar:
--   begin(ctx)  yeni dongu basladiginda (or. combo yeni dizi uretir)
--   poll(ctx)   her karede cagrilir; bir tekrar tamamlandiysa not dondurur
--               ('perfect' | 'good' | 'miss'), aksi halde nil
--
-- Ortak dongu (runSet) nefes, tempo, jitter, rampa ve iptali yonetir.
-- =========================================================================

---Faz mesafesini nota cevirir.
local function gradeAt(dist, halfPerfect, halfGood)
    if dist <= halfPerfect then return 'perfect' end
    if dist <= halfGood then return 'good' end
    return 'miss'
end

---Iki notun birlesimi (hold mekanigi icin): en kotusu belirleyicidir,
---ama ikisi de PERFECT ise PERFECT kalir.
local RANK = { perfect = 3, good = 2, miss = 1 }
local function combineGrades(a, b)
    if a == 'miss' or b == 'miss' then return 'miss' end
    if a == 'perfect' and b == 'perfect' then return 'perfect' end
    return 'good'
end

-- ---- TAP ----------------------------------------------------------------
local TapMech = {}

function TapMech.begin(ctx)
    ctx.pressed = false
end

function TapMech.poll(ctx)
    if ctx.pressed then return nil end
    if not IsDisabledControlJustPressed(0, C_HIT) then return nil end

    ctx.pressed = true
    return gradeAt(math.abs(ctx.phase - 0.5), ctx.halfPerfect, ctx.halfGood)
end

-- ---- HOLD ---------------------------------------------------------------
-- Gercek bir tekrarin iki fazi: indirirken BAS ve TUT, kaldirirken BIRAK.
local HoldMech = {}

function HoldMech.begin(ctx)
    ctx.holdStart = nil
    ctx.downGrade = nil
    ctx.done = false
    ctx.dropped = false
end

function HoldMech.poll(ctx)
    if ctx.done then return nil end

    local cfg = ctx.params.hold or { downPhase = 0.30, upPhase = 0.72, minHoldMs = 120 }
    local tol = ctx.params.holdTolerance or 1.0
    local hp, hg = ctx.halfPerfect * tol, ctx.halfGood * tol

    -- Birakmak basmaktan kolaydir: konsantrik pencere biraz genis tutulur.
    -- Aksi halde iki pencerenin carpimi seti dikkatli oyuncu icin bile
    -- imkansiz hale getiriyordu (simulasyon: %2.7 tamamlama).
    local UP = 1.35

    -- 1) Basma (eksantrik)
    if not ctx.downGrade then
        if IsDisabledControlJustPressed(0, C_HIT) then
            ctx.downGrade = gradeAt(math.abs(ctx.phase - cfg.downPhase), hp, hg)
            ctx.holdStart = ctx.now
            ctx.hudHold = true
        elseif ctx.phase > cfg.upPhase + hg * UP then
            -- Hic basmadi: dongu bosa gitti
            ctx.done = true
            return 'miss'
        end
        return nil
    end

    -- 2) Birakma (konsantrik)
    if not IsDisabledControlPressed(0, C_HIT) then
        ctx.done = true
        ctx.hudHold = false

        -- Cok erken biraktiysa halter duser
        if ctx.now - ctx.holdStart < (cfg.minHoldMs or 120) then
            ctx.dropped = true
            return 'miss'
        end

        local upGrade = gradeAt(math.abs(ctx.phase - cfg.upPhase), hp * UP, hg * UP)
        return combineGrades(ctx.downGrade, upGrade)
    end

    -- Cok uzun tuttuysa kas kilitlenir
    if ctx.phase > cfg.upPhase + hg * UP * 2.0 then
        ctx.done = true
        ctx.hudHold = false
        return 'miss'
    end

    return nil
end

-- ---- COMBO --------------------------------------------------------------
-- Dongu N esit yuvaya bolunur; her yuvada dogru tusa, yuva merkezine yakin
-- basmak gerekir. Tekrarin notu yuvalarin EN KOTUSUDUR.
local ComboMech = {}

function ComboMech.begin(ctx)
    local len = ctx.params.comboLen or 1
    ctx.seq = {}
    for i = 1, len do
        ctx.seq[i] = (math.random() < 0.5) and 'left' or 'right'
    end

    ctx.slot = 1
    ctx.worst = 'perfect'
    ctx.done = false

    hud('combo', { seq = ctx.seq, slot = 1 })
end

function ComboMech.poll(ctx)
    if ctx.done then return nil end

    local len = #ctx.seq
    local slotSpan = 1.0 / len
    local slotIndex = math.min(len, math.floor(ctx.phase / slotSpan) + 1)

    -- Yuva atlandiysa kacirilmis sayilir
    if slotIndex > ctx.slot then
        ctx.worst = 'miss'
        ctx.slot = slotIndex
    end

    local left  = IsDisabledControlJustPressed(0, C_LEFT)
    local right = IsDisabledControlJustPressed(0, C_RIGHT)
    if not left and not right then
        if ctx.phase >= 1.0 - 0.02 and ctx.slot <= len then
            ctx.done = true
            return 'miss'
        end
        return nil
    end

    local pressed = left and 'left' or 'right'
    local center = (ctx.slot - 0.5) * slotSpan
    local g

    if pressed ~= ctx.seq[ctx.slot] then
        g = 'miss'   -- yanlis yumruk
    else
        g = gradeAt(math.abs(ctx.phase - center), ctx.halfPerfect, ctx.halfGood)
    end

    if RANK[g] < RANK[ctx.worst] then ctx.worst = g end
    ctx.slot = ctx.slot + 1
    hud('combo', { seq = ctx.seq, slot = math.min(ctx.slot, len) })

    if ctx.slot > len then
        ctx.done = true
        return ctx.worst
    end

    return nil
end

local MECHANICS = { tap = TapMech, hold = HoldMech, combo = ComboMech }

-- =========================================================================
-- ORTAK SET DONGUSU
-- ---------------------------------------------------------------------------
-- Nefes, tempo, jitter, zorluk rampasi ve iptal burada; hakemlik strategy'de.
--
-- Zorluk rampasi CARPIMSAL: windowMs = taban * max(floor, 1 - oran * tekrar)
-- Boylece uzun setlerde (yuksek kondisyon) son tekrarlar gercekten zorlasir.
--
-- Tempo her donguda +-jitter kadar oynar; salt kas hafizasi yetmez.
-- =========================================================================
function GymWorkout.RunSet(params, opts)
    opts = opts or {}

    local mech = MECHANICS[params.mechanic] or MECHANICS.tap
    local dif  = Config.Gym.Difficulty

    local baseTempo  = params.tempoMs
    local baseWindow = params.perfectWindowMs
    local goodMult   = params.goodMult or 1.7
    local drain      = params.breathDrainPerSec
    local missMult   = params.missMult or 1.0
    local target     = params.targetReps
    local jitter     = params.jitter or 0.06
    local allowQuit  = opts.allowQuit ~= false

    local reps, perfect, good, miss = 0, 0, 0, 0
    local combo, bestCombo = 0, 0
    local breath = params.startBreath or 100.0
    local track = {}

    local startMs = GetGameTimer()
    local reason = 'complete'

    -- Dongu durumu
    local tempoMs, windowMs = baseTempo, baseWindow
    local cycleMs = tempoMs
    local cycleStart = startMs

    local ctx = {
        params = params,
        phase = 0, now = startMs,
        halfPerfect = 0, halfGood = 0,
    }

    ABORT.reason = nil

    local function applyRamp()
        windowMs = math.max(params.windowMinMs or 70,
            baseWindow * math.max(params.windowRampFloor or 0.45,
                                  1.0 - (params.windowRampPerRep or 0.022) * reps))
        tempoMs = baseTempo * math.max(params.tempoRampFloor or 0.62,
                                       1.0 - (params.tempoRampPerRep or 0.012) * reps)
        cycleMs = tempoMs * (1.0 + (math.random() * 2.0 - 1.0) * jitter)
    end

    local function pushCycle()
        hud('cycle', {
            tempoMs    = cycleMs,
            perfectPct = (windowMs / cycleMs) * 100.0,
            goodPct    = (windowMs * goodMult / cycleMs) * 100.0,
            mechanic   = params.mechanic,
            holdDown   = params.hold and params.hold.downPhase or nil,
            holdUp     = params.hold and params.hold.upPhase or nil,
            comboLen   = params.comboLen,
        })
    end

    local function pushState(lastHit)
        hud('state', {
            reps = reps, target = target, breath = breath, combo = combo,
            perfect = perfect, good = good, miss = miss,
            lastHit = lastHit, track = track, holding = ctx.hudHold or false,
        })
    end

    applyRamp()
    mech.begin(ctx)
    pushCycle()
    pushState(nil)

    local lastFrame = GetGameTimer()
    local lastPush = 0

    while true do
        Wait(0)

        local now = GetGameTimer()
        local dt = (now - lastFrame) / 1000.0
        lastFrame = now

        blockControls()

        if ABORT.reason then reason = ABORT.reason break end

        -- Nefes surekli erir
        breath = breath - drain * dt
        if breath <= 0.0 then
            breath = 0.0
            reason = 'exhausted'
            break
        end

        -- Cikis
        if allowQuit and (IsDisabledControlJustPressed(0, C_STOP)
                       or IsDisabledControlJustPressed(0, C_STOP2)) then
            reason = 'quit'
            break
        end

        -- Faz ve kabul bantlari
        ctx.now = now
        ctx.phase = (now - cycleStart) / cycleMs
        ctx.halfPerfect = (windowMs / cycleMs) / 2.0
        ctx.halfGood = ctx.halfPerfect * goodMult

        local grade = mech.poll(ctx)

        -- Dongu sarmasi
        if not grade and ctx.phase >= 1.0 then
            -- Bos gecen dongu: form kaybi (eski surumde BEDAVAYDI)
            if params.missedCycleCounts and reps > 0 then
                breath = breath - drain * (cycleMs / 1000.0) * (dif.BreathSkip or 0.55)
                combo = 0
                hud('skip', {})
            end

            cycleStart = now
            applyRamp()
            mech.begin(ctx)
            pushCycle()
        end

        if grade then
            local tempoSec = cycleMs / 1000.0

            if grade == 'perfect' then
                perfect = perfect + 1
                combo = combo + 1
                breath = breath + drain * tempoSec * (dif.BreathPerfect or 0.62)
                if combo >= 5 then breath = breath + drain * tempoSec * (dif.ComboBreathBonus or 0.10) end
                PlaySoundFrontend(-1, 'CHECKPOINT_PERFECT', 'HUD_MINI_GAME_SOUNDSET', true)
            elseif grade == 'good' then
                good = good + 1
                combo = 0
                breath = breath + drain * tempoSec * (dif.BreathGood or 0.30)
                PlaySoundFrontend(-1, 'CHECKPOINT_NORMAL', 'HUD_MINI_GAME_SOUNDSET', true)
            else
                miss = miss + 1
                combo = 0
                breath = breath - drain * tempoSec * (dif.BreathMiss or 0.45) * missMult
                PlaySoundFrontend(-1, 'CHECKPOINT_MISSED', 'HUD_MINI_GAME_SOUNDSET', true)
            end

            reps = reps + 1
            if combo > bestCombo then bestCombo = combo end
            breath = math.min(100.0, math.max(0.0, breath))
            track[#track + 1] = grade

            if opts.onRep then opts.onRep(grade, reps, perfect, good, miss, ctx) end
            pushState(grade)

            if reps >= target then reason = 'complete' break end

            -- Sonraki dongu
            cycleStart = now
            applyRamp()
            mech.begin(ctx)
            pushCycle()
        end

        -- Nefes cubugu icin ~12 Hz guncelleme yeter
        if now - lastPush >= 80 then
            lastPush = now
            pushState(nil)
        end
    end

    return {
        reps = reps, perfect = perfect, good = good, miss = miss,
        bestCombo = bestCombo, breath = breath, track = track,
        durationMs = GetGameTimer() - startMs,
        reason = reason,
    }
end

-- =========================================================================
-- KURULUM SERIDI — agirlik kademesi secimi
-- ---------------------------------------------------------------------------
-- Menu ACILMAZ; HUD icinde odak almayan bir serit belirir. A/D ile kademe,
-- E ile baslat, X ile vazgec. Plaka takmak gibi ~2 saniye.
-- Tum tahminler SUNUCUDA hesaplanir (gym:getSetPreview), client sadece gosterir.
-- =========================================================================
local SETUP_TIMEOUT_MS = 20000

---@return number? levelIndex  (nil = vazgecildi)
local function runSetupStrip(preview)
    local pick = preview.default or 3
    local maxIndex = #preview.levels

    -- Kilitli/karsilanamaz kademeye kilitlenme
    local function firstUsable(from, dir)
        local i = from
        for _ = 1, maxIndex do
            local lv = preview.levels[i]
            if lv and lv.unlocked then return i end
            i = i + dir
            if i < 1 or i > maxIndex then break end
        end
        return nil
    end

    pick = firstUsable(pick, -1) or firstUsable(1, 1) or 1

    hud('setup', {
        label     = preview.label,
        icon      = preview.icon,
        mechanic  = preview.mechanic,
        muscle    = preview.muscle,
        levels    = preview.levels,
        pick      = pick,
        energy    = preview.energy,
        energyMax = preview.energyMax,
        fatigue   = preview.fatigue,
        isSore    = preview.isSore,
        setIndex  = preview.setIndex,
        inProgram = preview.inProgram,
        gainMult  = preview.gainMult,
        condition = preview.condition,
    })

    local deadline = GetGameTimer() + SETUP_TIMEOUT_MS
    local result = nil

    while true do
        Wait(0)
        blockControls()
        DisableControlAction(0, C_PREV, true)
        DisableControlAction(0, C_NEXT, true)

        if GetGameTimer() > deadline then break end
        if ABORT.reason then break end

        if IsDisabledControlJustPressed(0, C_STOP) or IsDisabledControlJustPressed(0, C_STOP2) then
            break
        end

        local moved = false
        if IsDisabledControlJustPressed(0, C_PREV) and pick > 1 then
            pick = pick - 1; moved = true
        elseif IsDisabledControlJustPressed(0, C_NEXT) and pick < maxIndex then
            pick = pick + 1; moved = true
        end

        if moved then
            hud('setupPick', { pick = pick })
            PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
        end

        if IsDisabledControlJustPressed(0, C_OK) then
            local lv = preview.levels[pick]
            if lv and lv.unlocked and lv.affordable then
                result = pick
                PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
                break
            end
            PlaySoundFrontend(-1, 'ERROR', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
            hud('setupDeny', { pick = pick })
        end
    end

    hud('setupClose', {})
    return result
end

-- =========================================================================
-- GUVENLIK GOZCUSU
-- Olum / arac / kelepce / uzaklasma -> aninda iptal. Bu olmadan
-- FreezeEntityPosition kalici "donuk ped" bugu uretir.
-- =========================================================================
local function startGuard(stand)
    CreateThread(function()
        while busy do
            Wait(250)
            local p = cache.ped or PlayerPedId()

            if IsPedDeadOrDying(p, true) or IsPedInAnyVehicle(p, false)
               or IsPedCuffed(p) or IsPedRagdoll(p) then
                GymWorkout.Abort('interrupted')
                break
            end

            if stand and #(GetEntityCoords(p) - vec3(stand.x, stand.y, stand.z)) > 3.0 then
                GymWorkout.Abort('interrupted')
                break
            end
        end
    end)
end

-- =========================================================================
-- SET AKISI
-- =========================================================================
RegisterNetEvent('daddy-games:gym:client:startSet', function(station)
    if busy or not station then return end

    local ped = cache.ped or PlayerPedId()

    if IsPedDeadOrDying(ped, true) then
        lib.notify({ title = 'Antrenman', description = 'Bu durumda spor yapamazsın.', type = 'error' })
        return
    end
    if IsPedInAnyVehicle(ped, false) then
        lib.notify({ title = 'Antrenman', description = 'Önce araçtan in.', type = 'error' })
        return
    end
    if GetGameTimer() < restUntil then
        lib.notify({
            title = 'Toparlan',
            description = ('Setler arası dinlenme: %.1f sn'):format((restUntil - GetGameTimer()) / 1000),
            type = 'warning',
        })
        return
    end

    local exData = Config.Gym.Exercises[station.exercise]
    if not exData then return end

    -- 1) Kademe onizlemesi (sunucudan)
    local preview = lib.callback.await('daddy-games:gym:getSetPreview', false, station.exercise)
    if not preview then
        lib.notify({ title = 'Antrenman', description = 'Bilgiler alınamadı.', type = 'error' })
        return
    end

    busy = true
    ABORT.reason = nil

    -- 2) Kurulum seridi
    local levelIndex = runSetupStrip(preview)
    if not levelIndex then
        busy = false
        hud('close')
        return
    end

    -- 3) Sunucudan oturum iste (enerji / doluluk / bolge / kademe dogrulamasi)
    local response = lib.callback.await('daddy-games:gym:startSet', false, {
        exercise  = station.exercise,
        stationId = station.id,
        level     = levelIndex,
        coords    = { x = station.coords.x, y = station.coords.y, z = station.coords.z },
    })

    if not response or not response.ok then
        busy = false
        hud('close')
        lib.notify({
            title = 'Antrenman Başlatılamadı',
            description = (response and response.reason) or 'Sunucu yanıt vermedi.',
            type = 'error',
            duration = 6000,
        })
        return
    end

    local session = response.session
    activeSession = session
    cleanupProps()

    -- 4) Konumlandirma ve animasyon
    if station.stand then
        placePed(ped, station.stand, exData)
        Wait(80)
    end
    FreezeEntityPosition(ped, true)

    if exData.attachProp then
        attachProp(ped, exData.attachProp, exData.attachBone or 28422,
            exData.attachOffset or vector3(0, 0, 0), exData.attachRot or vector3(0, 0, 0))
    end

    startExerciseAnim(ped, exData)
    startGuard(station.stand)

    hud('open', session)

    -- 5) Set
    local result = GymWorkout.RunSet(session, {
        onRep = function(grade)
            -- Boks torbasi: PERFECT vuruslarda torbayi sallandir
            if station.exercise == 'punchbag' and grade == 'perfect'
               and station.entity and DoesEntityExist(station.entity) then
                ApplyForceToEntity(station.entity, 1, 0.0, 3.5, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end,
    })

    -- 6) Cikis
    busy = false
    activeSession = nil
    lastReason = result.reason

    if result.reason ~= 'interrupted' then
        playExitAnim(ped, exData)
    else
        ClearPedTasks(ped)
    end

    releasePed(ped)
    restUntil = GetGameTimer() + (session.restMs or Config.Gym.Lifecycle.RestBetweenSetsMs or 4000)

    TriggerServerEvent('daddy-games:gym:finishSet', session.token, {
        reps       = result.reps,
        perfect    = result.perfect,
        good       = result.good,
        miss       = result.miss,
        bestCombo  = result.bestCombo,
        durationMs = result.durationMs,
        reason     = result.reason,
    })

    if result.reason == 'interrupted' then hud('close') end
end)

---Sunucu setin sonucunu bildirir -> ozet karti.
RegisterNetEvent('daddy-games:gym:setResult', function(data)
    data.reason = lastReason or 'complete'
    hud('result', data)

    if data.newRecord then
        PlaySoundFrontend(-1, 'MEDAL_UP', 'HUD_MINI_GAME_SOUNDSET', true)
    end
    if data.programDone then
        PlaySoundFrontend(-1, 'CHALLENGE_UNLOCKED', 'HUD_AWARDS', true)
    end
end)

RegisterNetEvent('daddy-games:gym:forceStop', function()
    if busy then GymWorkout.Abort('interrupted') end
end)

RegisterNetEvent('daddy-games:gym:achievements', function(list)
    for _, ach in ipairs(list or {}) do
        lib.notify({
            title = 'Yeni Başarım',
            description = ('%s  (+%d FP)'):format(ach.label, ach.points or 0),
            icon = 'award',
            type = 'success',
            duration = 7000,
        })
        PlaySoundFrontend(-1, 'MEDAL_UP', 'HUD_MINI_GAME_SOUNDSET', true)
        Wait(400)
    end
end)

-- =========================================================================
-- ACIL TEMIZLIK
-- =========================================================================
AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)
    cleanupProps()
    SendNUIMessage({ action = 'gym:hud:close' })
    SetNuiFocus(false, false)
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if name ~= 'CEventNetworkEntityDamage' or not busy then return end

    local victim = args[1]
    if victim == (cache.ped or PlayerPedId()) and IsPedDeadOrDying(victim, true) then
        GymWorkout.Abort('interrupted')
    end
end)
