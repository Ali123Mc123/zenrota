-- =========================================================================
-- daddy-games :: gym :: client_npc.lua
-- Antrenor NPC'si, harita blip'i ve koc merkezinin acilisi.
--
-- Kapsam: yalnizca Ada Spor Alani (Vespucci / Alta PD kaldirildi).
-- =========================================================================

local trainerPeds = {}
local blips = {}

if not Config.Gym or Config.Gym.Enabled == false then return end

-- =========================================================================
-- BLIP'LER
-- =========================================================================
CreateThread(function()
    for _, area in pairs(Config.Gym.Areas) do
        local cfg = area.blip
        if cfg and cfg.enabled and area.center then
            local blip = AddBlipForCoord(area.center.x, area.center.y, area.center.z)

            SetBlipSprite(blip, cfg.sprite or 311)
            SetBlipColour(blip, cfg.color or 2)
            SetBlipScale(blip, cfg.scale or 0.75)
            SetBlipAsShortRange(blip, true)
            SetBlipDisplay(blip, 4)

            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(cfg.label or area.label or 'Spor Salonu')
            EndTextCommandSetBlipName(blip)

            blips[#blips + 1] = blip
        end
    end
end)

-- =========================================================================
-- ANTRENOR NPC'LERI
-- Not: Eski surumde ped `coords.z - 1.0` ile olusturuluyordu ve yere
-- gomuluyordu. Artik zemin GetGroundZFor_3dCoord ile bulunur.
-- =========================================================================
local function spawnTrainer(trainer)
    local hash = joaat(trainer.model)
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then
        print(('^3[daddy-games:gym] Antrenor modeli gecersiz: %s^7'):format(trainer.model))
        return nil
    end

    lib.requestModel(hash, 8000)
    if not HasModelLoaded(hash) then return nil end

    local c = trainer.coords
    local z = c.z
    local found, groundZ = GetGroundZFor_3dCoord(c.x, c.y, c.z + 1.0, false)
    if found and math.abs(groundZ - c.z) < 3.0 then z = groundZ end

    pcall(function() exports['FeloxAC']:CreatePed(hash) end) --[[FeloxAC:auto]]
    local ped = CreatePed(4, hash, c.x, c.y, z, c.w or 0.0, false, true)
    SetModelAsNoLongerNeeded(hash)

    if not ped or ped == 0 then return nil end

    SetEntityHeading(ped, c.w or 0.0)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanBeTargetted(ped, false)
    SetEntityCanBeDamaged(ped, false)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 17, true)

    if trainer.scenario then
        TaskStartScenarioInPlace(ped, trainer.scenario, 0, true)
    end

    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'daddy_gym_trainer_' .. trainer.id,
            icon = 'fa-solid fa-clipboard-list',
            label = ('%s — Koç Merkezi'):format(trainer.name),
            distance = 2.6,
            onSelect = function()
                GymNui.OpenHub(trainer)
            end,
        },
    })

    return ped
end

CreateThread(function()
    -- ox_target hazir olmadan addLocalEntity cagirilamaz
    local waited = 0
    while GetResourceState('ox_target') ~= 'started' and waited < 20000 do
        Wait(250)
        waited = waited + 250
    end

    for _, trainer in ipairs(Config.Gym.Trainers) do
        local ped = spawnTrainer(trainer)
        if ped then trainerPeds[#trainerPeds + 1] = ped end
    end
end)

-- =========================================================================
-- TEMIZLIK
-- =========================================================================
AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end

    for i = 1, #trainerPeds do
        if DoesEntityExist(trainerPeds[i]) then DeleteEntity(trainerPeds[i]) end
    end
    for i = 1, #blips do
        if DoesBlipExist(blips[i]) then RemoveBlip(blips[i]) end
    end
end)

-- =========================================================================
-- KOMUT: Koc merkezini elle ac (yalnizca salon icinde)
-- =========================================================================
RegisterCommand('gym', function()
    local coords = GetEntityCoords(cache.ped or PlayerPedId())
    local areaKey = GymTarget and GymTarget.AreaAt and GymTarget.AreaAt(coords)

    if not areaKey then
        lib.notify({
            title = 'Salon',
            description = 'Koç merkezini yalnızca spor salonunda açabilirsin.',
            type = 'error',
        })
        return
    end

    local trainer
    for _, t in ipairs(Config.Gym.Trainers) do
        if t.area == areaKey then trainer = t break end
    end

    GymNui.OpenHub(trainer)
end, false)
