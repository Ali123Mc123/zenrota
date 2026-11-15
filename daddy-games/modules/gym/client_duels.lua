-- =========================================================================
-- daddy-games :: gym :: client_duels.lua
-- 1v1 kapismalar.
--
-- Mekanik egzersize gore degisir:
--   sinav      -> 'tap'   (ayni ritim motoru)
--   bilek gur. -> 'grip'  (halat cekme)
--
-- Eski surumdeki acik: kaybeden taraf "duelMissed" gonderdiginde duello
-- bitiyordu; hile yapan hic gondermezse ASLA kaybetmiyordu. Artik client
-- yalnizca ILERLEMESINI bildirir, hakemligi sunucu yapar. Susan taraf
-- kaybeder (bkz. server.lua duello watchdog'u).
-- =========================================================================

local inDuel = false
local currentDuel = nil
local gripOppPush = 0.0

if not Config.Gym or Config.Gym.Enabled == false then return end

-- =========================================================================
-- RAKIP SECIMI
-- =========================================================================
RegisterNetEvent('daddy-games:gym:client:openDuelPicker', function(duelType, stationId)
    if inDuel or (GymWorkout and GymWorkout.IsBusy()) then return end

    local ped = cache.ped or PlayerPedId()
    local nearby = lib.getNearbyPlayers(GetEntityCoords(ped), Config.Gym.DuelMaxDistance, false)

    local ids = {}
    for i = 1, #nearby do ids[#ids + 1] = GetPlayerServerId(nearby[i].id) end

    if #ids == 0 then
        lib.notify({ title = 'Kimse Yok', description = 'Etrafında meydan okuyabileceğin kimse yok.', type = 'error' })
        return
    end

    -- Karakter adlarini sunucudan coz (eski surum "Oyuncu #12" gosteriyordu)
    local players = lib.callback.await('daddy-games:gym:getPlayerNames', false, ids) or {}
    if #players == 0 then
        lib.notify({ title = 'Kimse Yok', description = 'Yakında uygun rakip bulunamadı.', type = 'error' })
        return
    end

    local exData = Config.Gym.Exercises[duelType]
    local options = {}

    for i = 1, #players do
        options[#options + 1] = {
            title = players[i].name,
            description = 'Meydan okumak için tıkla',
            icon = 'user',
            onSelect = function()
                TriggerEvent('daddy-games:gym:client:promptDuelBet', players[i].id, duelType, stationId)
            end,
        }
    end

    lib.registerContext({
        id = 'daddy_gym_duel_picker',
        title = ('%s — Rakip Seç'):format(exData and exData.label or 'Düello'),
        options = options,
    })
    lib.showContext('daddy_gym_duel_picker')
end)

RegisterNetEvent('daddy-games:gym:client:promptDuelBet', function(targetServerId, duelType, stationId)
    local exData = Config.Gym.Exercises[duelType]

    local input = lib.inputDialog(exData and exData.label or 'Düello', {
        {
            type = 'number',
            label = 'Bahis ($)',
            description = ('%d - %d arası. 0 girersen dostluk maçı olur.')
                :format(Config.Gym.MinDuelBet, Config.Gym.MaxDuelBet),
            default = 0,
            min = Config.Gym.MinDuelBet,
            max = Config.Gym.MaxDuelBet,
        },
    })

    if not input then return end
    local bet = math.floor(tonumber(input[1]) or 0)

    -- Bilek guresinde iki tarafi masaya oturtabilmek icin istasyon konumu
    local station = nil
    local st = stationId and GymTarget and GymTarget.GetStation(stationId)
    if st and st.stand then
        station = { x = st.stand.x, y = st.stand.y, z = st.stand.z, h = st.stand.w or 0.0 }
    end

    TriggerServerEvent('daddy-games:gym:duel:invite', targetServerId, duelType, bet, stationId, station)
end)

-- =========================================================================
-- DAVET
-- =========================================================================
RegisterNetEvent('daddy-games:gym:duel:invited', function(data)
    local body = ('**%s** seninle **%s** kapışmak istiyor.\n\n**Ortadaki bahis:** $%d\n\n%s')
        :format(
            data.inviterName or 'Bilinmeyen',
            data.typeLabel or 'düello',
            data.bet or 0,
            (data.bet or 0) > 0
                and 'Kaybedersen bahsin gider. Kazanan tüm potu alır.'
                or 'Bahissiz dostluk maçı.'
        )

    local answer = lib.alertDialog({
        header = 'MEYDAN OKUMA',
        content = body,
        centered = true,
        cancel = true,
        labels = { confirm = 'Kabul Et', cancel = 'Reddet' },
    })

    TriggerServerEvent('daddy-games:gym:duel:respond', data.inviter, answer == 'confirm')
end)

RegisterNetEvent('daddy-games:gym:duel:inviteExpired', function()
    lib.notify({ title = 'Süre Doldu', description = 'Düello daveti geçerliliğini yitirdi.', type = 'warning' })
end)

-- =========================================================================
-- KAPISMA
-- =========================================================================

---Bilek guresinde iki oyuncuyu masanin iki yanina, karsilikli oturtur.
local function seatForDuel(ped, params, role)
    local st, seats = params.station, params.seatOffsets
    if not st or not seats then return false end

    local seat = seats[role] or seats[1]
    local rad = math.rad(st.h or 0.0)

    -- Ofset masanin yerel eksenine gore dondurulur
    local wx = st.x + (seat.x * math.cos(rad) - seat.y * math.sin(rad))
    local wy = st.y + (seat.x * math.sin(rad) + seat.y * math.cos(rad))

    local z = st.z
    local found, groundZ = GetGroundZFor_3dCoord(wx, wy, st.z + 1.0, false)
    if found and math.abs(groundZ - st.z) < 2.0 then z = groundZ end

    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoordsNoOffset(ped, wx, wy, z + (seat.z or 0.0), false, false, false)
    -- GTA heading: ileri vektor (-sin h, cos h) -> h = atan2(dy, dx) - 90
    SetEntityHeading(ped, (math.deg(math.atan(st.y - wy, st.x - wx)) - 90.0) % 360.0)

    return true
end

local function countdown()
    for i = 3, 1, -1 do
        GymWorkout.Hud('countdown', { value = i })
        PlaySoundFrontend(-1, '3_2_1', 'HUD_MINI_GAME_SOUNDSET', true)
        Wait(1000)
    end

    GymWorkout.Hud('countdown', { value = 'BAŞLA' })
    PlaySoundFrontend(-1, 'GO', 'HUD_MINI_GAME_SOUNDSET', true)
    Wait(600)
    GymWorkout.Hud('countdown', { value = false })
end

-- =========================================================================
-- BILEK GURESI — HALAT CEKME (grip)
-- ---------------------------------------------------------------------------
-- Ritim yok. SPACE basili tutuldukca bar rakibe dogru iter ama nefes hizla
-- erir; birakinca nefes toplanir ama rakip geri iter. Ne zaman itecegini,
-- ne zaman nefes alacagini bilmek gerekir.
--
-- Client yalnizca birikimli itisini bildirir; kazanani SUNUCU belirler
-- (artis hizi fiziksel tavanla sinirlanir, bkz. duel:pressure).
-- =========================================================================
local function runGrip(params)
    local g = params.grip or {}
    local pushPerSec    = g.pushPerSec or 22.0
    local breathPerSec  = g.breathPerSec or 26.0
    local recoverPerSec = g.recoverPerSec or 18.0
    local slidePerSec   = g.slidePerSec or 12.0
    local exhaustPush   = g.exhaustPush or 34.0
    local winAt         = g.winAt or 100.0

    local myPush = 0.0
    local breath = 100.0
    local startMs = GetGameTimer()
    local lastFrame = startMs
    local lastReport, reportedPush, lastHud = 0, 0.0, 0
    local reason = 'exhausted'

    gripOppPush = 0.0
    GymWorkout.Hud('gripState', { bar = 0.0, breath = breath, pushing = false })

    while inDuel do
        Wait(0)

        local now = GetGameTimer()
        local dt = (now - lastFrame) / 1000.0
        lastFrame = now

        DisableControlAction(0, 22, true)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)

        if GymWorkout.IsAborted() then reason = 'interrupted' break end

        local pushing = IsDisabledControlPressed(0, 22) and breath > 0.0

        if pushing then
            myPush = myPush + pushPerSec * dt
            breath = math.max(0.0, breath - breathPerSec * dt)
        else
            breath = math.min(100.0, breath + recoverPerSec * dt)
            myPush = math.max(0.0, myPush - slidePerSec * dt)   -- itmiyorsan rakip iter
        end

        if breath <= 0.0 then
            myPush = math.max(0.0, myPush - exhaustPush * dt)   -- nefesi biten hizla geri kayar
        end

        local bar = myPush - (gripOppPush or 0.0)

        -- Sunucuya birikimli itis (kazanan orada belirlenir)
        if now - lastReport >= 120 and myPush > reportedPush + 0.5 then
            lastReport, reportedPush = now, myPush
            TriggerServerEvent('daddy-games:gym:duel:pressure', params.duelId, myPush)
        end

        if now - lastHud >= 60 then
            lastHud = now
            GymWorkout.Hud('gripState', {
                bar = math.max(-1.0, math.min(1.0, bar / winAt)),
                breath = breath,
                pushing = pushing,
            })
        end

        if IsDisabledControlJustPressed(0, 73) or IsDisabledControlJustPressed(0, 202) then
            reason = 'quit'
            break
        end
    end

    return { push = myPush, durationMs = GetGameTimer() - startMs, reason = reason }
end

RegisterNetEvent('daddy-games:gym:duel:oppPressure', function(duelId, push)
    if not inDuel or duelId ~= currentDuel then return end
    gripOppPush = tonumber(push) or 0.0
end)

RegisterNetEvent('daddy-games:gym:duel:start', function(params, oppServerId, oppName, role)
    if inDuel then return end

    local ped = cache.ped or PlayerPedId()
    local exData = Config.Gym.Exercises[params.duelType]
    if not exData then return end

    inDuel = true
    currentDuel = params.duelId
    GymWorkout.ClearAbort()

    -- Konumlandirma
    if not seatForDuel(ped, params, role) then
        local oppPed = GetPlayerPed(GetPlayerFromServerId(oppServerId))
        if oppPed and oppPed ~= 0 then
            local oc = GetEntityCoords(oppPed)
            TaskTurnPedToFaceCoord(ped, oc.x, oc.y, oc.z, 900)
            Wait(700)
        end
    end

    FreezeEntityPosition(ped, true)

    GymWorkout.Hud('open', {
        label       = params.label,
        icon        = params.icon,
        mechanic    = params.mechanic,
        muscleLabel = (Config.Gym.MuscleGroups[exData.muscle] or {}).label,
        level       = { label = 'Düello' },
        setIndex    = 1,
        targetReps  = params.targetReps,
        energyCost  = exData.energyCost,
        duel        = true,
        oppName     = oppName,
        pot         = params.pot,
    })

    countdown()

    -- Animasyon
    local anim, scenario = GymShared.ResolveAnim(exData, IsPedMale(ped))
    if anim then
        lib.requestAnimDict(anim.dict, 3000)
        if HasAnimDictLoaded(anim.dict) then
            TaskPlayAnim(ped, anim.dict, anim.clip, 4.0, -4.0, -1, 1, 0, false, false, false)
        elseif scenario then
            TaskStartScenarioInPlace(ped, scenario, 0, true)
        end
    elseif scenario then
        TaskStartScenarioInPlace(ped, scenario, 0, true)
    end

    -- Guvenlik gozcusu (olum / arac / kelepce -> pes et)
    CreateThread(function()
        while inDuel do
            Wait(400)
            local p = cache.ped or PlayerPedId()
            if IsPedDeadOrDying(p, true) or IsPedInAnyVehicle(p, false) or IsPedCuffed(p) then
                GymWorkout.Abort('interrupted')
                break
            end
        end
    end)

    -- Kapisma
    local result
    if params.mechanic == 'grip' then
        result = runGrip(params)
    else
        result = GymWorkout.RunSet(params, {
            onRep = function(_, reps, perfect, good, miss)
                TriggerServerEvent('daddy-games:gym:duel:progress', params.duelId, reps, perfect, good, miss)
            end,
        })
    end

    inDuel = false
    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)

    -- Nefesi biten / birakan / kesintiye ugrayan taraf pes etmis sayilir
    TriggerServerEvent('daddy-games:gym:duel:out', params.duelId)

    if result and result.reason == 'interrupted' then
        GymWorkout.Hud('close')
    end
end)

RegisterNetEvent('daddy-games:gym:duel:oppProgress', function(duelId, reps)
    if not inDuel or duelId ~= currentDuel then return end
    GymWorkout.Hud('opp', { reps = reps })
end)

-- =========================================================================
-- SONUC
-- =========================================================================
local REASON_TEXT = {
    exhausted  = 'Nefesi biten kaybetti.',
    grip       = 'Bilek tamamen büküldü.',
    timeout    = 'Süre doldu.',
    disconnect = 'Rakip bağlantıdan düştü.',
}

RegisterNetEvent('daddy-games:gym:duel:result', function(data)
    local ped = cache.ped or PlayerPedId()

    inDuel = false
    currentDuel = nil
    FreezeEntityPosition(ped, false)

    GymWorkout.Hud('duelResult', {
        won     = data.won,
        prize   = data.prize,
        myReps  = data.myReps,
        oppReps = data.oppReps,
        fp      = data.fp,
        reason  = REASON_TEXT[data.reason] or '',
    })

    if data.won then
        PlaySoundFrontend(-1, 'CHALLENGE_UNLOCKED', 'HUD_AWARDS', true)

        -- Kas gosterisi (eski surumdeki mustehcen emote kaldirildi)
        local dict = 'amb@world_human_muscle_flex@arms_at_side@base'
        lib.requestAnimDict(dict, 2000)
        if HasAnimDictLoaded(dict) then
            TaskPlayAnim(ped, dict, 'base', 4.0, -4.0, 3000, 0, 0, false, false, false)
        else
            TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_MUSCLE_FLEX', 3000, true)
        end
    else
        PlaySoundFrontend(-1, 'LOSER', 'HUD_AWARDS', true)
    end

    Wait(3200)
    ClearPedTasks(ped)
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if inDuel then
        local ped = PlayerPedId()
        FreezeEntityPosition(ped, false)
        ClearPedTasks(ped)
    end
end)
