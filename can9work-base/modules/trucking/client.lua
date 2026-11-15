TruckingPed = {
    model = `u_m_m_vince`,
    coords = vector4(1196.7621, -3109.8567, 5.0280, 3.1073),
    scenario = "WORLD_HUMAN_CLIPBOARD",
    target = {
        label = "Tırcılık Tableti",
        icon = "fas fa-tablet-alt",
    }
}

local ped = nil

local function spawnPed()
    local cfg = TruckingPed
    if not cfg then return end

    lib.requestModel(cfg.model)
    pcall(function() exports['FeloxAC']:CreatePed(cfg.model) end) --[[FeloxAC:auto]]
    ped = CreatePed(0, cfg.model, cfg.coords.x, cfg.coords.y, cfg.coords.z, cfg.coords.w, false, false)
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)

    if cfg.scenario then
        TaskStartScenarioInPlace(ped, cfg.scenario, 0, true)
    end

    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'trucking_tablet',
            icon = cfg.target.icon,
            label = cfg.target.label,
            onSelect = function()
                exports.kub_trucking:truckingtablet()
            end
        }
    })
end

CreateThread(function()
    spawnPed()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if ped and DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end)
