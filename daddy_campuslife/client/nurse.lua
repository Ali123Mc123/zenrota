-- The infirmary scene. Each nurse has its own scene: one treating a patient never blocks another nurse.
-- Every client sees the nurse walk to the bed and back; the patient's client also lies down, waits and gets up.
local t = DL.locale.t
local cfg = Config.Nurse
local scenes = {}        -- nurse uid -> token of the scene running there
local treating = nil     -- the scene this player is the patient of: { uid, token }

local function nurseRecord(uid) return Campus.world.entity(uid) end
local function nursePed(uid) return Campus.entity('nurse', uid) end

-- Walking ----------------------------------------------------------------------------------------------
-- The anchor keeps its ped frozen; it is let go for the walk and frozen again where it stops.

local function walk(ped, dest)
    if not ped or not DoesEntityExist(ped) or not dest then return end
    FreezeEntityPosition(ped, false)
    ClearPedTasksImmediately(ped)
    TaskGoStraightToCoord(ped, dest.x, dest.y, dest.z, 1.0, cfg.WalkMs, dest.w or 0.0, 0.3)
    local deadline = GetGameTimer() + cfg.WalkMs + 1500
    while GetGameTimer() < deadline and DoesEntityExist(ped) do
        local c = GetEntityCoords(ped)
        if (c.x - dest.x) ^ 2 + (c.y - dest.y) ^ 2 < 0.25 then break end
        Wait(100)
    end
    if not DoesEntityExist(ped) then return end
    ClearPedTasksImmediately(ped)
    SetEntityCoords(ped, dest.x, dest.y, dest.z, false, false, false, false) -- the same height rule as the spawned ped
    SetEntityHeading(ped, dest.w or 0.0)
    FreezeEntityPosition(ped, true)
end

local function playAnim(ped, anim)
    if ped and anim.dict and pcall(lib.requestAnimDict, anim.dict, 2000) then
        TaskPlayAnim(ped, anim.dict, anim.clip, 8.0, -8.0, -1, 1, 0.0, false, false, false)
    end
end

-- The patient ------------------------------------------------------------------------------------------

local function lieDown(bed)
    DoScreenFadeOut(400)
    Wait(450)
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoordsNoOffset(cache.ped, bed.x, bed.y, bed.z, false, false, false)
    SetEntityHeading(cache.ped, bed.w or 0.0)
    FreezeEntityPosition(cache.ped, true)
    pcall(function() exports['FeloxAC']:isInvincible(true) end) --[[FeloxAC:auto]]
    SetEntityInvincible(cache.ped, true)
    playAnim(cache.ped, cfg.PatientAnim)
    DoScreenFadeIn(400)
end

local function getUp(exit)
    DoScreenFadeOut(300)
    Wait(350)
    ClearPedTasksImmediately(cache.ped)
    if exit then
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoords(cache.ped, exit.x, exit.y, exit.z, false, false, false, false)
        SetEntityHeading(cache.ped, exit.w or 0.0)
    end
    FreezeEntityPosition(cache.ped, false)
    pcall(function() exports['FeloxAC']:isInvincible(false) end) --[[FeloxAC:auto]]
    SetEntityInvincible(cache.ped, false)
    DoScreenFadeIn(300)
end

-- Where the patient gets up: on the floor beside the bed, a step to the side of where the nurse stands (her bedside
-- spot, or her own spot without one) and with a clear way to it; of two free sides, the one further from her way back.
local function exitPoint(bed, bedside, home)
    local spot = bedside or home
    local out = vector2(spot.x - bed.x, spot.y - bed.y)
    if #out < 0.05 then return spot end
    local side = vector2(-out.y, out.x) / #out * (cfg.ExitStep or 1.0)
    local best, bestFar
    for _, sign in ipairs({ 1, -1 }) do
        local x, y = spot.x + side.x * sign, spot.y + side.y * sign
        local ray = StartExpensiveSynchronousShapeTestLosProbe(spot.x, spot.y, spot.z + 0.8, x, y, spot.z + 0.8, 17, cache.ped, 4)
        local _, blocked = GetShapeTestResult(ray)
        local far = (x - home.x) ^ 2 + (y - home.y) ^ 2
        if blocked ~= 1 and blocked ~= true and (not bestFar or far > bestFar) then
            best, bestFar = vector4(x, y, spot.z, GetHeadingFromVector_2d(bed.x - x, bed.y - y)), far
        end
    end
    return best or spot
end

-- After the treatment the patient stays on the bed until [E].
local function waitToGetUp(bed)
    lib.showTextUI(t('nurse.get_up'), { position = 'right-center', icon = 'bed' })
    local tick = 0
    while true do
        DisableControlAction(0, 22, true)
        DisableControlAction(0, 24, true)
        tick = tick + 1
        if tick % 30 == 0 and not IsEntityPlayingAnim(cache.ped, cfg.PatientAnim.dict, cfg.PatientAnim.clip, 3) then playAnim(cache.ped, cfg.PatientAnim) end
        if IsControlJustPressed(0, 38) or IsDisabledControlJustPressed(0, 38) or IsEntityDead(cache.ped) then break end
        if #(GetEntityCoords(cache.ped) - vector3(bed.x, bed.y, bed.z)) > 1.0 then break end
        Wait(0)
    end
    lib.hideTextUI()
end

local function treat(uid, token, record)
    local bed, bedside = DL.geo.vec(record.settings.bed), DL.geo.vec(record.settings.bedside)
    treating = { uid = uid, token = token }
    lieDown(bed)
    local done = lib.progressBar({ duration = cfg.DurationMs, label = t('nurse.treating'), useWhileDead = true, canCancel = false,
        disable = { move = true, car = true, combat = true, mouse = true } })
    local result = done and scenes[uid] == token and Campus.call('nurse:complete', { token = token }) or { ok = false }
    if result.ok then
        Nui.notify('nurse.done', 'success')
        waitToGetUp(bed)
    else
        Campus.call('nurse:abort', { token = token })
        if result.error then Campus.fail(result) end
    end
    local found, exit = pcall(exitPoint, bed, bedside, record.coords)
    getUp(found and exit or bedside or record.coords)
    treating = nil
end

-- Scenes -----------------------------------------------------------------------------------------------

RegisterNetEvent('daddy_campuslife:nurse:start', function(scene)
    local record = nurseRecord(scene.uid)
    if not record then return end
    scenes[scene.uid] = scene.token
    CreateThread(function()
        local ped = nursePed(scene.uid)
        local bedside = DL.geo.vec(record.settings.bedside)
        if ped and bedside then
            walk(ped, bedside)
            playAnim(ped, cfg.TreatAnim)
        end
    end)
    if scene.patient == cache.serverId then CreateThread(function() treat(scene.uid, scene.token, record) end) end
end)

RegisterNetEvent('daddy_campuslife:nurse:finish', function(scene)
    scenes[scene.uid] = nil
    local record = nurseRecord(scene.uid)
    local ped = nursePed(scene.uid)
    if record and ped then CreateThread(function() walk(ped, record.coords) end) end
end)

-- The server heals through the medical resource; this covers what it could not.
RegisterNetEvent('daddy_campuslife:nurse:heal', function(heal)
    if heal.revive then
        local c = GetEntityCoords(cache.ped)
        pcall(function() exports['FeloxAC']:playerRevived() end) --[[FeloxAC:auto]]
        NetworkResurrectLocalPlayer(c.x, c.y, c.z, GetEntityHeading(cache.ped), 0, false)
    end
    if heal.full then
        pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
        SetEntityHealth(cache.ped, GetEntityMaxHealth(cache.ped))
        ClearPedBloodDamage(cache.ped)
    end
end)

local function busy(uid) return scenes[uid] ~= nil or (GlobalState['campuslife:nurses'] or {})[uid] == true end

Campus.kind('nurse', function(record)
    local cost = math.floor(tonumber(record.settings.cost) or 0)
    return { options = { {
        name = 'campus_nurse', icon = 'fa-solid fa-user-nurse',
        label = cost > 0 and t('nurse.target_fee', cost) or t('nurse.target'),
        canInteract = function() return not treating and not busy(record.uid) and not IsPedInAnyVehicle(cache.ped, false) and not Nui.isOpen() end,
        onSelect = function()
            CreateThread(function()
                local result = Campus.call('nurse:request', { uid = record.uid })
                if not result.ok then Campus.fail(result) end
            end)
        end,
    } } }
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() or not treating then return end
    lib.hideTextUI()
    FreezeEntityPosition(cache.ped, false)
    pcall(function() exports['FeloxAC']:isInvincible(false) end) --[[FeloxAC:auto]]
    SetEntityInvincible(cache.ped, false)
    ClearPedTasksImmediately(cache.ped)
end)
