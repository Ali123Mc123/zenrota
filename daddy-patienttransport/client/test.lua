if not Config.EnableTestCommands then return end

local testPed = nil
local INJURED_ANIM_DICT = 'combat@damage@writhe'
local INJURED_ANIM_NAME = 'writhe_loop'

local function notify(messageKey, nType)
    Utils.Notify('title_test', messageKey, nType)
end

local function playInjuredAnim(ped)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end

    Utils.LoadAnim(INJURED_ANIM_DICT)
    ClearPedTasksImmediately(ped)
    TaskPlayAnim(ped, INJURED_ANIM_DICT, INJURED_ANIM_NAME, 8.0, 8.0, -1, 1, 0, false, false, false)
end

local function deleteTestPed()
    if testPed and DoesEntityExist(testPed) then
        DeleteEntity(testPed)
    end

    testPed = nil
    Utils.SetTestMode(false)
end

local function spawnTestPed()
    deleteTestPed()

    local model = joaat('a_m_m_business_01')
    lib.requestModel(model)

    local spawnCoords = GetEntityCoords(cache.ped) + GetEntityForwardVector(cache.ped) * 2.0
    local ped = CreatePed(4, model, spawnCoords.x, spawnCoords.y, spawnCoords.z - 1.0,
        GetEntityHeading(cache.ped) + 180.0, false, false)

    if ped == 0 then
        notify('test_ped_failed', 'error')
        return
    end

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetEntityInvincible(ped, true)
    SetPedCanBeTargetted(ped, true)
    SetEntityHealth(ped, 120)

    -- Marks the ped so the stretcher and wheelchair targets can recognise it
    Entity(ped).state:set('stretcherTestNpc', true, false)

    playInjuredAnim(ped)

    testPed = ped
    Utils.SetTestMode(true)
    notify('test_ped_spawned', 'success')
end

AddEventHandler('daddy-patienttransport:stretcher:client:playInjuredAnim', function(ped)
    if ped == testPed or Utils.IsTestNpc(ped) then
        playInjuredAnim(ped)
    end
end)

RegisterCommand('testped', spawnTestPed, false)

RegisterCommand('deltestped', function()
    deleteTestPed()
    notify('test_ped_deleted', 'success')
end, false)

TriggerEvent('chat:addSuggestion', '/testped', L('cmd_testped'))
TriggerEvent('chat:addSuggestion', '/deltestped', L('cmd_deltestped'))

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    deleteTestPed()
end)
