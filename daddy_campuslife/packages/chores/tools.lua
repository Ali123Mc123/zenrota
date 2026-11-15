-- Chores on the client, the work itself: strokes on a surface, carrying a load, putting a thing down,
-- looking close at a panel and cutting in passing. Each one waits until it is over and says how it ended.

local MOVE = { 21, 22, 23, 24, 25, 30, 31, 32, 33, 34, 35, 44, 75, 140, 141, 142, 257, 263 }
local CANCEL = { 177, 200, 202 } -- Backspace, Esc, Esc (frontend)

local function dead() return IsEntityDead(cache.ped) or IsPedRagdoll(cache.ped) end

local function cancelled()
    for _, control in ipairs(CANCEL) do
        if IsControlJustPressed(0, control) or IsDisabledControlJustPressed(0, control) then return true end
    end
    return false
end

function Chores.attachTools(api)
    local opts = api.opts
    local function call(name, data) return opts.call(name, data) or { ok = false, error = 'unavailable' } end

    -- Strokes ------------------------------------------------------------------------------------------
    -- w: { keys = { { control = 34, name = 'A' }, { control = 35, name = 'D' } }, perStage = 8,
    --      rules = { minGapMs, maxGapMs }, clip = { dict, clip, ms }, reach = 2.5,
    --      onStroke = function(accepted, count, perStage, why) end, onStage = function(stage, stages) end }
    -- -> 'done' | 'cancelled' | 'gone' | 'too_far' | the server's error
    function api.strokes(id, pieceId, w)
        local piece = api.piece(id, pieceId)
        if not piece then return 'gone' end
        local begun = call('begin', { job = id, piece = pieceId })
        if not begun.ok then return begun.error end
        TaskTurnPedToFaceCoord(cache.ped, piece.x, piece.y, piece.gz or 0.0, 400)
        if w.clip then pcall(lib.requestAnimDict, w.clip.dict, 2500) end
        local chain, stage, sent = {}, begun.stage, 0
        while true do
            Wait(0)
            for _, control in ipairs(MOVE) do DisableControlAction(0, control, true) end
            if cancelled() or dead() then return 'cancelled' end
            if piece.done then return 'done' end
            if Chores.flat(GetEntityCoords(cache.ped), piece) > (w.reach or 2.5) then return 'too_far' end
            for _, key in ipairs(w.keys) do
                if IsDisabledControlJustPressed(0, key.control) then
                    local accepted, why = Chores.stroke(chain, key.name, GetGameTimer(), w.rules)
                    if accepted and w.clip then
                        TaskPlayAnim(cache.ped, w.clip.dict, w.clip.clip, 8.0, 8.0, w.clip.ms or 1000, 48, 0.0, false, false, false)
                    end
                    if w.onStroke then w.onStroke(accepted, chain.count or 0, w.perStage, why) end
                end
            end
            -- Every perStage strokes one stage goes to the server; a refusal for speed just waits for more work.
            local due = math.floor((chain.count or 0) / w.perStage)
            if due > sent then
                sent = due
                local result = call('stage', { job = id, piece = pieceId, stage = stage + 1 })
                if result.ok then
                    stage = result.stage or stage + 1
                    if w.onStage then w.onStage(stage, piece.stages) end
                    if stage >= piece.stages then
                        if w.clip then RemoveAnimDict(w.clip.dict) end
                        return 'done'
                    end
                elseif result.error ~= 'too_quick' then
                    return result.error
                end
            end
        end
    end

    -- Carrying -----------------------------------------------------------------------------------------
    -- Two hands on the load: no running, jumping, weapons or cars until it is put down or dropped.
    local carrying

    -- spec: a hold spec; clip: { dict, clip } looped while carrying. -> the held prop
    -- What falls from the hands (a fall, a car, a new load taken up) goes to the product: onDropped(prop).
    function api.carry(spec, clip)
        local before = carrying and carrying.entity
        api.drop()
        if before and opts.onDropped then opts.onDropped(before) end
        clip = clip or { dict = 'anim@heists@box_carry@', clip = 'idle' }
        local entity = api.hold(spec)
        if not entity then return nil end
        local mine = { entity = entity }
        carrying = mine
        pcall(lib.requestAnimDict, clip.dict, 2500)
        CreateThread(function()
            while carrying == mine do
                if not IsEntityPlayingAnim(cache.ped, clip.dict, clip.clip, 3) then
                    TaskPlayAnim(cache.ped, clip.dict, clip.clip, 4.0, 4.0, -1, 49, 0.0, false, false, false)
                end
                for _, control in ipairs({ 21, 22, 23, 24, 25, 37, 44, 75, 140, 141, 142 }) do DisableControlAction(0, control, true) end
                if dead() or IsPedInAnyVehicle(cache.ped, true) then
                    api.drop()
                    if opts.onDropped then opts.onDropped(entity) end
                end
                Wait(0)
            end
        end)
        return entity
    end

    function api.carried() return carrying and carrying.entity end

    -- Lets go of the load (no server step).
    function api.drop()
        if not carrying then return end
        local entity = carrying.entity
        carrying = nil
        ClearPedTasks(cache.ped)
        api.unhold(entity)
    end

    -- Puts the load down at a drop spot of the job. -> the server's answer
    function api.deliver(id, target)
        local result = call('drop', { job = id, target = target })
        if result.ok then
            api.drop()
            api.play('pickup_object', 'putdown_low', 900, 48)
        end
        return result
    end

    -- Putting down -------------------------------------------------------------------------------------

    local function aim(reach)
        local origin = GetFinalRenderedCamCoord()
        local target = origin + DL.freecam.direction(GetFinalRenderedCamRot(2)) * reach
        local probe = StartExpensiveSynchronousShapeTestLosProbe(origin.x, origin.y, origin.z, target.x, target.y, target.z, 511, cache.ped, 7)
        local _, hit, coords, normal = GetShapeTestResult(probe)
        return hit == 1, coords, normal
    end

    -- A see-through copy follows the aim; the wheel turns it, left click (or Enter, never Space) puts it on flat ground
    -- inside the job's area, Backspace or right click gives up. prompt(show) lets the product draw its key hints.
    -- -> the server's answer, or { ok = false, error = 'cancelled' | 'model' }
    function api.place(id, model, prompt, reach)
        reach = reach or 3.5
        local hash = joaat(model)
        if not IsModelInCdimage(hash) or not pcall(lib.requestModel, hash, 2500) then return { ok = false, error = 'model' } end
        local job = api.job(id)
        local zone = job and job.zone
        local function inside(c)
            return not zone or DL.geo.contains(zone, c.x, c.y, zone.shape == 'polygon' and ((job.bottom or 0.0) + (job.top or 0.0)) * 0.5 or c.z)
        end
        local here = GetEntityCoords(cache.ped)
        pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
        local ghost = CreateObject(hash, here.x, here.y, here.z, false, false, false)
        SetEntityCollision(ghost, false, false)
        FreezeEntityPosition(ghost, true)
        SetModelAsNoLongerNeeded(hash)
        local heading = GetEntityHeading(cache.ped)
        if prompt then prompt(true) end
        local function finish(result)
            if prompt then prompt(false) end
            DeleteEntity(ghost)
            return result
        end
        while true do
            Wait(0)
            for _, control in ipairs({ 24, 25, 14, 15 }) do DisableControlAction(0, control, true) end
            if IsDisabledControlJustPressed(0, 14) then heading = heading - 7.5 end
            if IsDisabledControlJustPressed(0, 15) then heading = heading + 7.5 end
            local ped = GetEntityCoords(cache.ped)
            local hit, coords, normal = aim(#(GetFinalRenderedCamCoord() - ped) + reach + 1.0)
            local valid = hit and #(coords - ped) <= reach and normal.z >= 0.9 and inside(coords)
            if hit then
                -- The copy floats a hair over the ground so it does not flicker in it; the real one stands on it.
                SetEntityCoordsNoOffset(ghost, coords.x, coords.y, coords.z + 0.015, false, false, false)
                SetEntityRotation(ghost, 0.0, 0.0, heading, 2, true)
            end
            SetEntityAlpha(ghost, valid and 200 or 70, false)
            if valid and (IsDisabledControlJustPressed(0, 24) or IsControlJustPressed(0, 201)) then
                api.play('pickup_object', 'putdown_low', 900, 48)
                return finish(call('place', { job = id, model = model, x = coords.x, y = coords.y, z = coords.z, h = heading }))
            end
            if IsControlJustPressed(0, 177) or IsDisabledControlJustPressed(0, 25) or dead() then return finish({ ok = false, error = 'cancelled' }) end
        end
    end

    -- Close look -----------------------------------------------------------------------------------------
    -- A camera on a thing (a breaker panel, a valve) while the product's panel is open.
    -- look: { coords = vector3 of the thing, from = offset of the camera, aim = offset of the point looked at, heading =
    --         the thing's (the offsets turn with it as GetOffsetFromEntityInWorldCoords does; 0 = as written), fov, reach }
    -- -> a handle with close(); closes itself when the player walks off or goes down.
    local function turned(v, heading)
        local r = math.rad(heading or 0.0)
        local c, s = math.cos(r), math.sin(r)
        return vector3(v.x * c - v.y * s, v.x * s + v.y * c, v.z)
    end

    function api.closeLook(look)
        local from = look.coords + turned(look.from or vector3(0.0, -0.8, 0.2), look.heading)
        local at = look.coords + turned(look.aim or vector3(0.0, 0.0, 0.0), look.heading)
        local cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', from.x, from.y, from.z, 0.0, 0.0, 0.0, look.fov or 45.0, false, 2)
        pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
        PointCamAtCoord(cam, at.x, at.y, at.z)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 400, true, false)
        local handle = { open = true }
        function handle.close()
            if not handle.open then return end
            handle.open = false
            RenderScriptCams(false, true, 400, true, false)
            pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]]
            DestroyCam(cam, false)
            if look.onClose then look.onClose() end
        end
        CreateThread(function()
            while handle.open do
                Wait(250)
                if dead() or #(GetEntityCoords(cache.ped) - look.coords) > (look.reach or 3.0) then handle.close() end
            end
        end)
        return handle
    end

    -- Cutting in passing ----------------------------------------------------------------------------------
    -- While the job is open and this player works it, the nearest piece within reach is cut every half second.
    -- canCut() says whether the player has the tool now (in the mower, the push mower in hand). One watch per job: a new
    -- one ends the one before. -> stop(), which ends it.
    local watching = {}
    function api.watchCuts(id, canCut, reach)
        local token = {}
        watching[id] = token
        CreateThread(function()
            while watching[id] == token do
                Wait(500)
                local job = api.job(id)
                if not job or not job.mine then break end
                if watching[id] == token and canCut() then
                    local here, best, near = GetEntityCoords(cache.ped), nil, reach or 1.8
                    for _, piece in ipairs(job.pieces) do
                        local d = not piece.done and Chores.flat(here, piece)
                        if d and d <= near then best, near = piece, d end
                    end
                    if best then call('cut', { job = id, piece = best.id }) end
                end
            end
            if watching[id] == token then watching[id] = nil end
        end)
        return function() if watching[id] == token then watching[id] = nil end end
    end
end
