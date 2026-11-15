local PlayerData = {}
local isTreating = false

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = exports.qbx_core:GetPlayerData()
end)

AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
    PlayerData.job = job
end)

lib.requestModel(Settings.Doctor.model)

local doctor = CreatePed(
    0,
    Settings.Doctor.model,
    Settings.Doctor.coords.xyz,
    Settings.Doctor.coords.w,
    false,
    true
)

FreezeEntityPosition(doctor, true)
SetEntityInvincible(doctor, true)
SetBlockingOfNonTemporaryEvents(doctor, true)

exports.ox_target:addLocalEntity(doctor, {
    {
        label = 'Tedavi Ol',
        icon = 'fa-solid fa-syringe',
        distance = 2.0,
        onSelect = function()
            if PlayerData.job and PlayerData.job.type == 'leo' then
                lib.notify({ type = 'error', description = 'Polisler burayı kullanamaz' })
                return
            end

            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            TriggerServerEvent('illegaldoctor:request')
        end
    }
})

RegisterNetEvent('illegaldoctor:start', function(index)
    if isTreating then return end
    isTreating = true

    local ped = PlayerPedId()
    local bed = Settings.Beds[index].coords

    lib.requestAnimDict('anim@gangops@morgue@table@')

    DoScreenFadeOut(500)
    Wait(600)

    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoordsNoOffset(ped, bed.x, bed.y, bed.z, false, false, false)
    SetEntityHeading(ped, bed.w)

    FreezeEntityPosition(ped, true)
    pcall(function() exports['FeloxAC']:isInvincible(true) end) --[[FeloxAC:auto]]
    SetEntityInvincible(ped, true)
    pcall(function() exports['FeloxAC']:canRagdoll(false) end) --[[FeloxAC:auto]]
    SetPedCanRagdoll(ped, false)

    TaskPlayAnim(
        ped,
        'anim@gangops@morgue@table@',
        'body_search',
        8.0,
        -8.0,
        -1,
        1,
        0,
        false,
        false,
        false
    )

    DoScreenFadeIn(500)

    local success = lib.progressBar({
        duration = Settings.HealTime,
        label = 'Tedavi ediliyorsun',
        useWhileDead = true,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = true
        }
    })

    if not success then
        lib.notify({ type = 'error', description = 'Tedavi iptal edildi' })
        cleanupTreatment(ped)
        TriggerServerEvent('illegaldoctor:finish', index, true)
        return
    end

    TriggerEvent('qbx_medical:client:playerRevived')

    lib.notify({ type = 'success', description = 'Tedavi oldun' })

    lib.requestAnimDict('get_up@directional@movement@from_knees@standard')

    TaskPlayAnim(
        ped,
        'get_up@directional@movement@from_knees@standard',
        'getup_r_0',
        8.0,
        -8.0,
        1600,
        0,
        0,
        false,
        false,
        false
    )

    Wait(1600)
    cleanupTreatment(ped)
    TriggerServerEvent('illegaldoctor:finish', index, false)
end)

function cleanupTreatment(ped)
    ClearPedTasksImmediately(ped)
    FreezeEntityPosition(ped, false)
    pcall(function() exports['FeloxAC']:isInvincible(false) end) --[[FeloxAC:auto]]
    SetEntityInvincible(ped, false)
    pcall(function() exports['FeloxAC']:canRagdoll(true) end) --[[FeloxAC:auto]]
    SetPedCanRagdoll(ped, true)
    isTreating = false
end
