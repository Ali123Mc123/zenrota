-- Fitting parts by hand at the car.

Install = {}

local KIND = {
    order = {
        repair = 'engine', performance = 'engine', cosmetics = 'body', respray = 'paint', wheels = 'wheel', headlights = 'front', neonLights = 'side',
        tyreSmoke = 'wheel', bulletproofTyres = 'wheel', extras = 'body', stance = 'stance',
    },
    tune = { engine = 'hoist', drivetrain = 'engine', tyres = 'wheel', brakes = 'wheel', drift = 'engine', gearbox = 'engine', nitro = 'engine' },
    service = { engine = 'oil', tyres = 'wheel', brakes = 'wheel', clutch = 'engine' },
}

local CARRY = {
    engine = { model = `prop_tool_box_04`, bone = 57005, at = vec3(0.4, 0.0, -0.02), rot = vec3(-90.0, 0.0, 90.0) },
    wheel = { model = `prop_wheel_tyre`, bone = 28422, at = vec3(0.0, 0.05, -0.15), rot = vec3(0.0, 90.0, 0.0), anim = { 'anim@heists@box_carry@', 'idle' } },
    paint = { model = `prop_cs_spray_can`, bone = 28422, at = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
    tools = { model = `prop_tool_box_04`, bone = 57005, at = vec3(0.4, 0.0, -0.02), rot = vec3(-90.0, 0.0, 90.0) },
    oil = { model = `prop_oilcan_01a`, bone = 57005, at = vec3(0.15, 0.0, -0.05), rot = vec3(-90.0, 0.0, 0.0) },
}

local HOIST = {
    model = `prop_engine_hoist`, engine = `prop_car_engine_01`,
    turn = 180.0,
    ahead = 1.7,
    reach = 3.05,
    hang = vec3(0.0, -1.85, 1.0),
    drop = 0.45,
    anim = { 'missfinale_c2ig_11', 'pushcar_offcliff_m' },
}

local WORK = {
    engine = { 'mini@repair', 'fixing_a_ped' },
    hoist = { 'mini@repair', 'fixing_a_ped' },
    oil = { 'mini@repair', 'fixing_a_ped' },
    wheel = { 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer' },
    stance = { 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer' },
    body = { 'mini@repair', 'fixing_a_player' },
}

local PAINT = { dict = 'switch@franklin@lamar_tagging_wall', shake = 'lamar_tagging_wall_loop_lamar', spray = 'lamar_tagging_exit_loop_lamar' }

function Install.kindOf(source, job) return KIND[source] and KIND[source][job] or 'body' end

local function spots(vehicle, kind, extra)
    local lo, hi = GetModelDimensions(GetEntityModel(vehicle))
    local z = lo.z + (hi.z - lo.z) * 0.35
    if kind == 'engine' or kind == 'oil' or kind == 'hoist' then
        local bone = GetEntityBoneIndexByName(vehicle, 'engine')
        local p = bone ~= -1 and GetEntityBonePosition_2(vehicle, bone)
        local rear = p and GetOffsetFromEntityGivenWorldCoords(vehicle, p.x, p.y, p.z).y < 0
        local gap = kind == 'hoist' and extra - 0.8 or 0.6
        return { vec3(0.0, rear and lo.y - gap or hi.y + gap, z) }, rear and 5 or 4
    elseif kind == 'wheel' or kind == 'stance' then
        local me, best, at = GetEntityCoords(cache.ped), math.huge, nil
        for _, name in ipairs({ 'wheel_lf', 'wheel_rf', 'wheel_lr', 'wheel_rr' }) do
            local bone = GetEntityBoneIndexByName(vehicle, name)
            if bone ~= -1 then
                local world = GetEntityBonePosition_2(vehicle, bone)
                local d = #(world - me)
                if d < best then best, at = d, GetOffsetFromEntityGivenWorldCoords(vehicle, world.x, world.y, world.z) end
            end
        end
        at = at or vec3(lo.x, hi.y * 0.6, z)
        return { vec3(at.x + (at.x < 0 and -0.7 or 0.7), at.y, z) }
    elseif kind == 'paint' then
        return { vec3(0.0, hi.y + 1.0, z), vec3(hi.x + 1.0, 0.0, z), vec3(0.0, lo.y - 1.0, z), vec3(lo.x - 1.0, 0.0, z) }
    elseif kind == 'front' then
        return { vec3(0.0, hi.y + 0.6, z) }, 4
    elseif kind == 'side' then
        return { vec3(lo.x - 0.7, 0.0, z) }
    end
    return { vec3(lo.x - 0.7, 0.2, z) }
end

local function load(dict)
    lib.requestAnimDict(dict)
    return dict
end

local function pushHoist()
    lib.requestModel(HOIST.model)
    lib.requestModel(HOIST.engine)
    local at = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, HOIST.ahead, -1.0)
    local hoist = CreateObject(HOIST.model, at.x, at.y, at.z, true, true, false)
    local engine = CreateObject(HOIST.engine, at.x, at.y, at.z, true, true, false)
    SetModelAsNoLongerNeeded(HOIST.model)
    SetModelAsNoLongerNeeded(HOIST.engine)
    SetEntityCollision(hoist, false, false)
    AttachEntityToEntity(engine, hoist, 0, HOIST.hang.x, HOIST.hang.y, HOIST.hang.z, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    TaskPlayAnim(cache.ped, load(HOIST.anim[1]), HOIST.anim[2], 3.0, 3.0, -1, 49, 0, false, false, false)
    CreateThread(function()
        while DoesEntityExist(hoist) and not IsEntityPositionFrozen(hoist) do
            local p = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, HOIST.ahead, 0.0)
            local found, ground = GetGroundZFor_3dCoord(p.x, p.y, p.z + 0.5, false)
            SetEntityCoordsNoOffset(hoist, p.x, p.y, found and ground or p.z - 1.0, false, false, false)
            SetEntityHeading(hoist, GetEntityHeading(cache.ped) + HOIST.turn)
            Wait(0)
        end
    end)
    return hoist, engine, HOIST.reach
end

local function carry(kind)
    local c = CARRY[kind] or CARRY.tools
    lib.requestModel(c.model)
    local prop = CreateObject(c.model, 0.0, 0.0, 0.0, true, true, false)
    SetModelAsNoLongerNeeded(c.model)
    AttachEntityToEntity(prop, cache.ped, GetPedBoneIndex(cache.ped, c.bone), c.at.x, c.at.y, c.at.z, c.rot.x, c.rot.y, c.rot.z, true, true, false, true, 1, true)
    if c.anim then TaskPlayAnim(cache.ped, load(c.anim[1]), c.anim[2], 3.0, 3.0, -1, 49, 0, false, false, false) end
    return prop, c.anim
end

local function check()
    local cfg = Config.Install
    if not cfg.SkillCheck then
        return lib.progressBar({ duration = cfg.Seconds * 1000, label = Core.t('ui.fitting_part'), canCancel = true, disable = { move = true, car = true, combat = true } }) or nil
    end
    for left = (tonumber(cfg.Attempts) or 3) - 1, 0, -1 do
        if lib.skillCheck(cfg.Difficulty, cfg.Keys) then return true end
        if left > 0 then
            Bridge.notify(nil, Core.t('msg.skill_missed', left), 'error')
            while lib.skillCheckActive() do Wait(0) end
            Wait(1500)
        end
    end
    return false
end

Install.check = check

local function atSpot(vehicle, spot, kind, label)
    local shown, nextCheck = nil, 0
    while true do
        Wait(0)
        if not DoesEntityExist(vehicle) then return nil end
        if GetGameTimer() > nextCheck then
            nextCheck = GetGameTimer() + 500
            if Bridge.down() then
                Bridge.hint(nil)
                return nil
            end
        end
        local world = GetOffsetFromEntityInWorldCoords(vehicle, spot.x, spot.y, spot.z)
        local me = GetEntityCoords(cache.ped)
        local d = #(me - world)
        DrawMarker(20, world.x, world.y, world.z + 0.6, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 160, true, true, 2, false, nil, nil, false)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 23, true)
        local here = d < 1.3
        if here ~= shown then
            shown = here
            Bridge.hint(here and { label = label, keys = { { 'E', 'ui.hint_fit' }, { 'Backspace', 'ui.hint_stop' } } }
                or { label = label, sub = Core.t('ui.install_go'), keys = { { 'Backspace', 'ui.hint_stop' } } })
        end
        if IsControlJustPressed(0, 177) or #(me - GetEntityCoords(vehicle)) > 25.0 then
            Bridge.hint(nil)
            return nil
        end
        if here and IsControlJustPressed(0, Config.Key) then
            Bridge.hint(nil)
            TaskTurnPedToFaceCoord(cache.ped, GetEntityCoords(vehicle), 800)
            Wait(800)
            return true
        end
    end
end

local live = {}

local function stopSpray()
    if live.fx then StopParticleFxLooped(live.fx, false) end
    live.fx = nil
end

local function drop()
    stopSpray()
    for _, key in ipairs({ 'engine', 'prop' }) do
        local e = live[key]
        if e and DoesEntityExist(e) then
            DetachEntity(e, true, true)
            DeleteEntity(e)
        end
        live[key] = nil
    end
    Bridge.hint(nil)
end

local function spray(prop, tint)
    local asset, effect = Config.Install.Spray[1], Config.Install.Spray[2]
    lib.requestNamedPtfxAsset(asset)
    TaskPlayAnim(cache.ped, load(PAINT.dict), PAINT.shake, 3.0, 3.0, -1, 49, 0, false, false, false)
    local spraying = true
    CreateThread(function()
        Wait(1000)
        if not spraying or not DoesEntityExist(prop) then return end
        TaskPlayAnim(cache.ped, PAINT.dict, PAINT.spray, 3.0, 3.0, -1, 49, 0, false, false, false)
        UseParticleFxAsset(asset)
        live.fx = StartParticleFxLoopedOnEntity(effect, prop, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
        if tint then SetParticleFxLoopedColour(live.fx, tint[1] / 255, tint[2] / 255, tint[3] / 255, false) end
    end)
    local done = lib.progressBar({ duration = 3500, label = Core.t('ui.spraying'), canCancel = true, disable = { move = true, car = true, combat = true } })
    spraying = false
    stopSpray()
    StopAnimTask(cache.ped, PAINT.dict, PAINT.shake, 2.0)
    StopAnimTask(cache.ped, PAINT.dict, PAINT.spray, 2.0)
    return done
end

exports('install', function(source, job, label)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 15.0, false)
    if vehicle then return Install.run(vehicle, source, job, label or job) end
end)

local function run(vehicle, source, job, label, look)
    local kind = Install.kindOf(source, job)
    local prop, walk, engine, length
    if kind == 'hoist' and not IsModelInCdimage(HOIST.model) then kind = 'engine' end
    if kind == 'hoist' then
        prop, engine, length = pushHoist()
        walk = HOIST.anim
    else
        prop, walk = carry(CARRY[kind] and kind or 'tools')
    end
    live.prop, live.engine = prop, engine
    local list, door = spots(vehicle, kind, length or 0.0)
    local result

    for i, spot in ipairs(list) do
        local name = kind == 'paint' and ('%s %d / %d'):format(label, i, #list) or label
        if not atSpot(vehicle, spot, kind, name) then break end
        if kind == 'paint' then
            if not spray(prop, look and look.tint) then break end
            if i == #list then result = true end
        else
            if door then SetVehicleDoorOpen(vehicle, door, false, false) end
            if walk then StopAnimTask(cache.ped, walk[1], walk[2], 2.0) end
            if engine then
                FreezeEntityPosition(prop, true)
            else
                DetachEntity(prop, true, true)
                DeleteEntity(prop)
                prop, live.prop = nil, nil
            end
            local work = WORK[kind] or WORK.body
            TaskPlayAnim(cache.ped, load(work[1]), work[2], 3.0, 3.0, -1, 1, 0, false, false, false)
            if engine then
                CreateThread(function()
                    for step = 0, 30 do
                        if not DoesEntityExist(engine) then return end
                        AttachEntityToEntity(engine, prop, 0, HOIST.hang.x, HOIST.hang.y, HOIST.hang.z - step * HOIST.drop / 30, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                        Wait(50)
                    end
                end)
            end
            result = check()
            ClearPedTasks(cache.ped)
            if door then SetVehicleDoorShut(vehicle, door, false) end
        end
    end

    drop()
    if walk then StopAnimTask(cache.ped, walk[1], walk[2], 2.0) end
    return result
end

Install.busy = false

function Install.run(vehicle, source, job, label, look)
    if Install.busy then return nil end
    Install.busy = true
    local ok, result = pcall(run, vehicle, source, job, label, look)
    Install.busy = false
    if ok then return result end
    print(('^1[daddy_mechanic] fit: %s^0'):format(result))
    drop()
    ClearPedTasks(cache.ped)
    return nil
end

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then drop() end
end)
