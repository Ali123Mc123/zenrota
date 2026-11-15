-- =========================================================================
-- daddy-games :: gym :: client_perks.lua
-- Kondisyonun GERCEK oyun ici karsiligi.
--
-- Sunucu kondisyondan turetilmis degerleri gonderir; burada oyuncu
-- istatistiklerine yazilir. Kondisyon dustugunde bu degerler de duser —
-- "forma girmek gun alir, birakinca kolayca kaybolur" davranisi buradan gelir.
--
-- Baska scriptler bu statlari ezebildigi icin belirli araliklarla ve her
-- dogusta yeniden uygulanir.
-- =========================================================================

local current = nil
local lastTierIndex = nil

if not Config.Gym or Config.Gym.Enabled == false then return end

local function applyPerks()
    if not current or not Config.Gym.Perks.Enabled then return end

    local playerId = PlayerId()

    StatSetInt('MP0_STAMINA', current.stamina or 0, true)
    StatSetInt('MP0_STRENGTH', current.strength or 0, true)
    StatSetInt('MP0_LUNG_CAPACITY', current.lung or 0, true)

    if Config.Gym.Perks.MaxHealthEnabled then
        local ped = cache.ped or PlayerPedId()
        local target = current.maxHealth or 200

        if GetEntityMaxHealth(ped) ~= target then
            local hp = GetEntityHealth(ped)
            SetEntityMaxHealth(ped, target)
            pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
            SetEntityHealth(ped, math.min(hp, target))
        end
    end
end

RegisterNetEvent('daddy-games:gym:perks', function(perks)
    if type(perks) ~= 'table' then return end

    local previous = current
    current = perks
    applyPerks()

    -- Rutbe degisimini oyuncuya bildir (yukselme VE dusme)
    if lastTierIndex and perks.tierIndex and perks.tierIndex ~= lastTierIndex then
        local up = perks.tierIndex > lastTierIndex
        lib.notify({
            title = up and 'Rütbe Atladın!' or 'Rütben Düştü',
            description = ('%s %s%s'):format(
                perks.tierBadge or '',
                perks.tierLabel or '',
                up and '' or ' — kondisyonun eridi, kazanımların da azaldı.'
            ),
            type = up and 'success' or 'warning',
            duration = 8000,
        })
        PlaySoundFrontend(-1, up and 'RANK_UP' or 'CHECKPOINT_MISSED', 'HUD_MINI_GAME_SOUNDSET', true)
    end

    lastTierIndex = perks.tierIndex

    -- Kondisyon gozle gorulur dustuyse sessizce uyar
    if previous and perks.condition and previous.condition
       and previous.condition - perks.condition >= 3.0 then
        lib.notify({
            title = 'Kondisyon Düşüyor',
            description = ('Formun %.0f seviyesine indi. Antrenmana ara verdin.'):format(perks.condition),
            type = 'warning',
            duration = 7000,
        })
    end
end)

-- Baska scriptler statlari ezebilir; periyodik olarak geri yaz
CreateThread(function()
    local interval = Config.Gym.Perks.ReapplyIntervalMs or 60000
    while true do
        Wait(interval)
        applyPerks()
    end
end)

AddEventHandler('playerSpawned', function()
    Wait(1500)
    applyPerks()
end)

---Perk'leri disari acar (HUD / baska moduller okuyabilsin).
exports('GetGymPerks', function()
    return current
end)
