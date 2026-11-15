-- Sitting on chairs and working out. A chair is claimed on the server first, so two players never share one.
local t = DL.locale.t
local seated, working = nil, false

-- Chairs -----------------------------------------------------------------------------------------------

local function poses() return IsPedMale(cache.ped) and Config.Chairs.Male or Config.Chairs.Female end

-- A scenario lines itself up with the chair; a clip is moved by the pose's z / fwd / side and frozen there.
-- skipEnter fast-forwards the scenario's sitting down, so a pose change does not replay it.
local function applyPose(chair, pose, skipEnter)
    local c, heading = chair.coords, chair.coords.w or 0.0
    ClearPedTasksImmediately(cache.ped)
    if pose.scenario then
        FreezeEntityPosition(cache.ped, false)
        TaskStartScenarioAtPosition(cache.ped, pose.scenario, c.x, c.y, c.z, heading, 0, true, true)
        if skipEnter then
            for _ = 1, 24 do ForcePedAiAndAnimationUpdate(cache.ped) end
        end
        return
    end
    if not pcall(lib.requestAnimDict, pose.dict, 2000) then return end
    local rad = math.rad(heading)
    local fwd, side = pose.fwd or 0.0, pose.side or 0.0
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoordsNoOffset(cache.ped, c.x - math.sin(rad) * fwd + math.cos(rad) * side, c.y + math.cos(rad) * fwd + math.sin(rad) * side, c.z + (pose.z or 0.0), false, false, false)
    SetEntityHeading(cache.ped, heading)
    FreezeEntityPosition(cache.ped, true)
    TaskPlayAnim(cache.ped, pose.dict, pose.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
end

local function standUp(exit)
    if not seated then return end
    seated = nil
    lib.hideTextUI()
    FreezeEntityPosition(cache.ped, false)
    ClearPedTasks(cache.ped)
    TriggerServerEvent('daddy_campuslife:chair:stand')
    if exit then
        Wait(200)
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoords(cache.ped, exit.x, exit.y, exit.z, false, false, false, false)
    end
end

local function sit(chair)
    local result = Campus.call('chair:sit', { uid = chair.uid })
    if not result.ok then return Campus.fail(result) end
    local c, heading = chair.coords, chair.coords.w or 0.0
    local rad = math.rad(heading)
    local exit = vector3(c.x + 0.65 * math.sin(rad), c.y - 0.65 * math.cos(rad), c.z)
    local list, index = poses(), 1
    seated = chair.uid
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(cache.ped, c.x, c.y, c.z, false, false, false, false)
    SetEntityHeading(cache.ped, heading)
    applyPose(chair, list[index], false)
    lib.showTextUI(t('chairs.stand_up'))
    while seated == chair.uid do
        DisableControlAction(0, 22, true)
        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
        if IsControlJustPressed(0, 38) or IsDisabledControlJustPressed(0, 38) then return standUp(exit) end
        if IsControlJustPressed(0, 47) or IsDisabledControlJustPressed(0, 47) then
            index = index % #list + 1
            applyPose(chair, list[index], true)
            lib.notify({ description = ('%s (%d/%d)'):format(t('chairs.pose_' .. list[index].id), index, #list), type = 'inform', duration = 1200 })
        end
        if IsEntityDead(cache.ped) or #(GetEntityCoords(cache.ped) - vector3(c.x, c.y, c.z)) > 3.0 then return standUp() end
        Wait(0)
    end
end

local function taken(uid) return (GlobalState['campuslife:seats'] or {})[uid] == true end

Campus.kind('chair', function(record)
    return { distance = 1.8, options = { {
        name = 'campus_chair', label = t('chairs.target'), icon = 'fa-solid fa-chair',
        canInteract = function() return not seated and not working and not taken(record.uid) and Campus.free() end,
        onSelect = function() CreateThread(function() sit(record) end) end,
    } } }
end)

exports('IsSeated', function() return seated ~= nil end)

-- The gym ----------------------------------------------------------------------------------------------

local function workout(exercise, uid, at)
    local move = Config.Gym.Exercises[exercise]
    if not move or working then return end
    local result = Campus.call('gym:start', { exercise = exercise, uid = uid })
    if not result.ok then return Campus.fail(result) end
    working = true
    if at then
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoords(cache.ped, at.x, at.y, at.z, false, false, false, false)
        SetEntityHeading(cache.ped, at.w or GetEntityHeading(cache.ped))
    end
    if move.scenario then TaskStartScenarioInPlace(cache.ped, move.scenario, 0, true)
    elseif pcall(lib.requestAnimDict, move.dict, 2000) then TaskPlayAnim(cache.ped, move.dict, move.anim, 8.0, -8.0, -1, 1, 0, false, false, false) end
    lib.showTextUI(t('gym.stop'), { position = 'right-center', icon = 'dumbbell' })
    local start = GetEntityCoords(cache.ped)
    while true do
        DisableControlAction(0, 22, true)
        DisableControlAction(0, 24, true)
        RestorePlayerStamina(cache.playerId, 0.05)
        if IsControlJustPressed(0, 73) or IsDisabledControlJustPressed(0, 73) or IsEntityDead(cache.ped) or #(GetEntityCoords(cache.ped) - start) > 3.0 then break end
        Wait(0)
    end
    lib.hideTextUI()
    ClearPedTasks(cache.ped)
    local done = Campus.call('gym:finish')
    working = false
    if done.ok and done.seconds >= Config.Gym.MinSeconds then Nui.notify('gym.done', 'success', done.seconds) end
end

local function option(exercise, uid, at)
    return {
        name = 'campus_gym_' .. exercise, label = t('gym.target', t('gym.exercise_' .. exercise)), icon = 'fa-solid fa-dumbbell',
        canInteract = function() return not working and not seated and Campus.free() end,
        onSelect = function() CreateThread(function() workout(exercise, uid, at) end) end,
    }
end

Campus.kind('gym_spot', function(record)
    if not Config.Gym.Exercises[record.settings.exercise] then return nil end
    return { options = { option(record.settings.exercise, record.uid, record.coords) } }
end)

-- Every gym prop of the map, by model.
CreateThread(function()
    local byExercise = {}
    for model, exercise in pairs(Config.Gym.Props) do
        byExercise[exercise] = byExercise[exercise] or {}
        table.insert(byExercise[exercise], model)
    end
    for exercise, models in pairs(byExercise) do DL.target.addModels('campus_gym_' .. exercise, { models = models, distance = 2.0, options = { option(exercise) } }) end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if seated or working then
        lib.hideTextUI()
        FreezeEntityPosition(cache.ped, false)
        ClearPedTasks(cache.ped)
    end
end)
