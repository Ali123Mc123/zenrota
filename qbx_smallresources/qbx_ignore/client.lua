local config = require 'qbx_ignore.config'

local suppressedModelHashes = {}
for i, name in ipairs(config.blacklisted.suppressedModels) do
    suppressedModelHashes[i] = joaat(name)
end

-- DaddyRP: the server runs with `set onesync_population false` (server.cfg), so there are no ambient peds or
-- vehicles at all. The blacklist below is only a safety net and is set once; it used to run again every 10 s, and
-- a populationPedCreating handler (a coroutine with Wait(500) + GetClosestPed for every spawned ped) was removed:
-- with population off that event never has anything to act on.
CreateThread(function()
    for _, sctyp in next, config.blacklisted.scenarioTypes do
        SetScenarioTypeEnabled(sctyp, false)
    end
    for i = 1, #suppressedModelHashes do
        SetVehicleModelIsSuppressed(suppressedModelHashes[i], true)
    end
    for _, scgrp in next, config.blacklisted.scenarioGroups do
        SetScenarioGroupEnabled(scgrp, false)
    end
end)

CreateThread(function() -- all these should only need to be called once
    if config.disable.ambience then
        StartAudioScene('CHARACTER_CHANGE_IN_SKY_SCENE')
    end
    SetAudioFlag('PoliceScannerDisabled', true)
    SetGarbageTrucks(false)
    SetCreateRandomCops(false)
    SetCreateRandomCopsNotOnScenarios(false)
    SetCreateRandomCopsOnScenarios(false)
    DistantCopCarSirens(false)
    SetFarDrawVehicles(false)
    RemoveVehiclesFromGeneratorsInArea(335.2616 - 300.0, -1432.455 - 300.0, 46.51 - 300.0, 335.2616 + 300.0,
        -1432.455 + 300.0, 46.51 + 300.0) -- central los santos medical center
    RemoveVehiclesFromGeneratorsInArea(441.8465 - 500.0, -987.99 - 500.0, 30.68 - 500.0, 441.8465 + 500.0,
        -987.99 + 500.0, 30.68 + 500.0)   -- police station mission row
    RemoveVehiclesFromGeneratorsInArea(316.79 - 300.0, -592.36 - 300.0, 43.28 - 300.0, 316.79 + 300.0, -592.36 + 300.0,
        43.28 + 300.0)                    -- pillbox
    RemoveVehiclesFromGeneratorsInArea(-2150.44 - 500.0, 3075.99 - 500.0, 32.8 - 500.0, -2150.44 + 500.0,
        -3075.99 + 500.0, 32.8 + 500.0)   -- military
    RemoveVehiclesFromGeneratorsInArea(-1108.35 - 300.0, 4920.64 - 300.0, 217.2 - 300.0, -1108.35 + 300.0,
        4920.64 + 300.0, 217.2 + 300.0)   -- nudist
    RemoveVehiclesFromGeneratorsInArea(-458.24 - 300.0, 6019.81 - 300.0, 31.34 - 300.0, -458.24 + 300.0, 6019.81 + 300.0,
        31.34 + 300.0)                    -- police station paleto
    RemoveVehiclesFromGeneratorsInArea(1854.82 - 300.0, 3679.4 - 300.0, 33.82 - 300.0, 1854.82 + 300.0, 3679.4 + 300.0,
        33.82 + 300.0)                    -- police station sandy
    RemoveVehiclesFromGeneratorsInArea(-724.46 - 300.0, -1444.03 - 300.0, 5.0 - 300.0, -724.46 + 300.0, -1444.03 + 300.0,
        5.0 + 300.0)                      -- REMOVE CHOPPERS WOW
end)

if config.disable.idleCamera then
    DisableIdleCamera(true)
    DisableVehiclePassengerIdleCamera(true)
end

-- The pistol whip block (140-142 while holding a gun) is done in can9_base's per-frame function, which already
-- runs every frame; a second Wait(0) loop here was started again on every weapon switch and the old one kept
-- running while a weapon was still in hand, so switching weapons stacked loops.
-- Infinite ammo is a persistent ped setting: set it once when the extinguisher / jerry can is taken out.
local infinite = { [`WEAPON_FIREEXTINGUISHER`] = true, [`WEAPON_PETROLCAN`] = true }

lib.onCache('weapon', function(weapon)
    if weapon and infinite[weapon] then
        SetPedInfiniteAmmo(cache.ped, true, weapon)
    end
end)
