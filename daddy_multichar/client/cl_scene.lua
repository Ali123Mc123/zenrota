-- Preview actors: local peds dressed like the characters, ghosts and props for unused places, and their idle poses.
-- spot = { pos (ped root), heading, anim }; async steps ask valid(). The scene deletes these itself, so no Track.
do
    Actors = {}

    local FREEMODE = { m = 'mp_m_freemode_01', f = 'mp_f_freemode_01' }
    local dicts, models, warned = {}, {}, {}

    local function warn(key, text)
        if warned[key] then return end
        warned[key] = true
        print(('^3[%s] %s^7'):format(GetCurrentResourceName(), text))
    end

    function Actors.remove(ent)
        if ent and DoesEntityExist(ent) then DeleteEntity(ent) end
        return nil
    end

    local function request(model, valid)
        Stream.model(model, valid, 5000)
        if not valid() or not HasModelLoaded(model) then return false end
        models[model] = true
        return true
    end

    -- A hidden, inert local ped at the spot.
    local function spawnPed(model, spot, valid)
        if not request(model, valid) then return nil end
        local p = spot.pos
        pcall(function() exports['FeloxAC']:CreatePed(model) end) --[[FeloxAC:auto]]
        local ped = CreatePed(4, model, p.x, p.y, p.z, spot.heading + 0.0, false, false)
        if not ped or ped == 0 then return nil end
        SetEntityVisible(ped, false, false)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedCanRagdoll(ped, false)
        SetPedLodMultiplier(ped, 2.0)
        FreezeEntityPosition(ped, true)
        SetEntityCollision(ped, false, false)
        SetEntityCoordsNoOffset(ped, p.x, p.y, p.z, false, false, false)
        return ped
    end

    local function freemode(gender)
        return joaat(FREEMODE[gender == 'f' and 'f' or 'm'])
    end

    -- The character's model when the game has it, else the freemode ped of its gender.
    local function modelFor(preview, gender)
        local ok, model = pcall(Bridge.appearance.modelOf, preview, gender)
        if ok and model and IsModelInCdimage(model) and IsModelAPed(model) then return model end
        return freemode(gender)
    end

    -- Dresses a ped, then waits for the head blend and the clothing streams so nothing pops in on screen.
    local function dress(ped, data, valid, blend)
        local ok, err = pcall(Bridge.appearance.apply, ped, data)
        if not ok then warn('apply', 'dressing a preview actor failed: ' .. tostring(err)) end
        local scale = MC.lowSpec() and 0.5 or 1.0 -- low-spec: shorter streaming waits
        local deadline = GetGameTimer() + 1500 * scale
        while blend and valid() and DoesEntityExist(ped) and not HasPedHeadBlendFinished(ped) and GetGameTimer() < deadline do Wait(0) end
        deadline = GetGameTimer() + 3000 * scale
        while valid() and DoesEntityExist(ped) and not HaveAllStreamingRequestsCompleted(ped) and GetGameTimer() < deadline do Wait(0) end
        return valid() and DoesEntityExist(ped)
    end

    -- entry = { index, gender, preview = { model, skin, format } | nil }; nil when it cannot be made.
    function Actors.character(spot, entry, valid)
        local gender = entry.gender == 'f' and 'f' or 'm'
        local preview = type(entry.preview) == 'table' and type(entry.preview.skin) == 'table' and entry.preview or nil
        local model = modelFor(preview, gender)
        local ped = spawnPed(model, spot, valid)
        if not ped then return nil end
        local data = preview or Bridge.appearance.defaultPed(gender)
        local blend = model == freemode('m') or model == freemode('f')
        if not dress(ped, data, valid, blend) then return Actors.remove(ped) end
        if blend then Actors.measureHeel(ped, gender) end
        if spot.seat then SetEntityCoordsNoOffset(ped, spot.pos.x, spot.pos.y, spot.pos.z - Actors.heel(ped), false, false, false) end
        return ped
    end

    -- How far heels lift a ped's body: its pelvis in its shoes against barefoot (freemode peds only).
    local heels = setmetatable({}, { __mode = 'k' })
    local BAREFOOT = { m = 34, f = 35 }
    local function pelvis(ped)
        Wait(0)
        Wait(0)
        return GetPedBoneCoords(ped, 11816, 0.0, 0.0, 0.0).z - GetEntityCoords(ped).z
    end

    function Actors.measureHeel(ped, gender)
        local drawable, texture = GetPedDrawableVariation(ped, 6), GetPedTextureVariation(ped, 6)
        local shod = pelvis(ped)
        SetPedComponentVariation(ped, 6, BAREFOOT[gender] or 34, 0, 0)
        local bare = pelvis(ped)
        SetPedComponentVariation(ped, 6, drawable, texture, 0)
        local lift = shod - bare
        heels[ped] = (lift > 0.01 and lift < 0.3) and lift or 0.0
    end

    -- The measured heel lift (0 for flat shoes or an unmeasured ped).
    function Actors.heel(ped)
        return heels[ped] or 0.0
    end

    -- A model as a frozen local object on a ground point { pos, heading }.
    function Actors.prop(name, at, valid, collision)
        local model = type(name) == 'number' and name or joaat(tostring(name or ''))
        if not IsModelInCdimage(model) then
            warn('prop:' .. tostring(name), ('prop %s is not in the game files, skipped'):format(tostring(name)))
            return nil
        end
        if not request(model, valid) then return nil end
        local p = at.pos
        pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
        local obj = CreateObjectNoOffset(model, p.x, p.y, p.z, false, false, false)
        if not obj or obj == 0 then return nil end
        SetEntityHeading(obj, at.heading + 0.0)
        if at.ground and at.floor then Ground.stand(obj, p.z) -- a role scene: on the map's ground, as the editor shows it
        elseif at.ground then PlaceObjectOnGroundProperly(obj) end -- a model whose origin is not at its feet (tables, chairs)
        FreezeEntityPosition(obj, true)
        SetEntityCollision(obj, collision == true, collision == true)
        return obj
    end

    -- The stand-in for an unused place (Config.SlotVisuals entry): ent, alpha, gender, isPed; nil for 'none'.
    function Actors.visual(cfg, spot, ground, valid, index)
        cfg = type(cfg) == 'table' and cfg or {}
        if cfg.kind == 'prop' then return Actors.prop(cfg.model, ground, valid, false), 255, nil, false end
        if cfg.kind ~= 'ghost' then return nil end
        local gender = (index or 1) % 2 == 0 and 'f' or 'm'
        local ped = spawnPed(freemode(gender), spot, valid)
        if not ped then return nil end
        if not dress(ped, Bridge.appearance.defaultPed(gender), valid, true) then return Actors.remove(ped) end
        return ped, math.floor(CamMath.clamp(tonumber(cfg.alpha) or 90, 0, 255)), gender, true
    end

    local function pool(gender)
        local out = {}
        for _, anim in ipairs(Config.Animations or {}) do
            if anim.gender == nil or anim.gender == 'any' or anim.gender == gender then out[#out + 1] = anim end
        end
        return out
    end

    -- The spot's animation, or for 'random' one from the gender's pool, the same for a character index every time.
    function Actors.pick(id, gender, index)
        if type(id) == 'string' and id ~= 'random' then
            for _, anim in ipairs(Config.Animations or {}) do
                if anim.id == id then return anim end
            end
        end
        local list = pool(gender)
        if #list == 0 then return nil end
        return list[((tonumber(index) or 1) - 1) % #list + 1]
    end

    local seats = {} -- ped -> { chair, scenes }
    local chairs = {}
    local watchingChairs = false

    local function watchChairs()
        if watchingChairs then return end
        watchingChairs = true
        CreateThread(function()
            while next(chairs) ~= nil do
                Wait(1000)
                for ped, chair in pairs(chairs) do
                    if not DoesEntityExist(ped) then
                        if DoesEntityExist(chair) then DeleteEntity(chair) end
                        chairs[ped], seats[ped], heels[ped] = nil, nil, nil
                    end
                end
            end
            watchingChairs = false
        end)
    end

    -- Clears any active task, scenario, synced seat, chair prop, attachment, weapon or movement clipset on a ped
    -- before a new idle/act/pose starts or when the ped is released.
    function Actors.resetPose(ped)
        if not ped or not DoesEntityExist(ped) then return end
        local oldChair = chairs[ped]
        if oldChair and DoesEntityExist(oldChair) then DeleteEntity(oldChair) end
        chairs[ped], seats[ped] = nil, nil
        if IsEntityAttached(ped) then DetachEntity(ped, true, false) end
        ClearPedTasksImmediately(ped)
        RemoveAllPedWeapons(ped, true)
        ResetPedMovementClipset(ped, 0.0)
        SetEnableHandcuffs(ped, false)
    end

    -- Starts an idle pose: dictionary anims stay frozen without collision, scenarios stand on the ground.
    function Actors.idle(ped, anim, spot, valid)
        if type(anim) ~= 'table' or not DoesEntityExist(ped) then return false end
        Actors.resetPose(ped)
        if type(anim.scenario) == 'string' then
            FreezeEntityPosition(ped, false)
            SetEntityCollision(ped, true, true)
            local deadline = GetGameTimer() + 750
            while valid() and DoesEntityExist(ped) and not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < deadline do Wait(0) end
            if not valid() or not DoesEntityExist(ped) then return false end
            local p = spot.pos
            local sits = anim.scenario:find('SEAT', 1, true) ~= nil -- benches, loungers: the ped sits on the point
            TaskStartScenarioAtPosition(ped, anim.scenario, p.x, p.y, p.z, spot.heading + 0.0, 0, sits, true)
            return true
        end
        if type(anim.dict) ~= 'string' or not DoesAnimDictExist(anim.dict) then
            MC.debug('pose: dictionary %s does not exist', tostring(anim.dict))
            warn('anim:' .. tostring(anim.id), ('animation %s is missing from the game files, skipped'):format(tostring(anim.id)))
            return false
        end
        Stream.dict(anim.dict, valid, 10000) -- a new place streams the world at the same time
        if not valid() or not HasAnimDictLoaded(anim.dict) or not DoesEntityExist(ped) then
            MC.debug('pose: %s not played (scene still valid: %s, loaded: %s)', anim.dict, tostring(valid()), tostring(HasAnimDictLoaded(anim.dict)))
            return false
        end
        dicts[anim.dict] = true
        FreezeEntityPosition(ped, true)
        SetEntityCollision(ped, false, false)
        if anim.origin and spot.fixed and Actors.seat(ped, anim, spot.fixed, spot.heading, valid, true) then return true end
        local floor = spot.seat or (spot.ground and spot.ground.pos)
        if anim.chair and floor and Actors.seat(ped, anim, floor, spot.heading, valid, true) then return true end
        if anim.enter and spot.pos and Actors.enter(ped, anim, spot, valid) then return true end
        TaskPlayAnim(ped, anim.dict, anim.clip, 8.0, -8.0, -1, tonumber(anim.flag) or 1, 0.0, false, false, false)
        return true
    end

    -- A ped walks in and sits (anim.enter, then anim.clip looped) in a synced scene. With a chair (anim.chair) the scene
    -- stands on the chair and the chair plays its own part (clip .. '_chair'), as the game's seats do; without one the
    -- scene is placed so the loop lands where the plain loop stands on the spot (found by trying it and measuring).
    local function wrap(h)
        return (h + 180.0) % 360.0 - 180.0
    end

    local function scene(o, r, ped, dict, clip, loop, blend)
        local s = CreateSynchronizedScene(o.x, o.y, o.z, r.x, r.y, r.z, 2)
        SetSynchronizedSceneLooped(s, loop)
        SetSynchronizedSceneHoldLastFrame(s, not loop)
        TaskSynchronizedScene(ped, s, dict, clip, blend, -4.0, 0, 0, 1000.0, 0)
        return s
    end

    local function chairScene(o, r, chair, dict, clip, loop, blend, suffix)
        clip = clip .. (suffix or '_chair')
        if not chair or GetAnimDuration(dict, clip) <= 0.0 then return nil end
        local s = CreateSynchronizedScene(o.x, o.y, o.z, r.x, r.y, r.z, 2)
        SetSynchronizedSceneLooped(s, loop)
        SetSynchronizedSceneHoldLastFrame(s, not loop)
        PlaySynchronizedEntityAnim(chair, s, clip, dict, blend, -4.0, 0, 1000.0)
        return s
    end

    -- Enter (when asked and the clip is there), then the loop, ped and chair together.
    local function sit(ped, chair, o, r, anim, enter, valid)
        local lift = vector3(0.0, 0.0, Actors.heel(ped))
        local function play(clip, loop, blend)
            local c = chairScene(o, r, chair, anim.dict, clip, loop, blend, anim.chairClip)
            local s = scene(o - lift, r, ped, anim.dict, clip, loop, blend)
            seats[ped] = { chair = chair, ped = s, seat = c, lift = lift, fixed = anim.origin == true }
            return s
        end
        if not (enter and anim.enter and GetAnimDuration(anim.dict, anim.enter) > 0.0) then
            play(anim.clip, true, 1000.0)
            return
        end
        local s = play(anim.enter, false, 1000.0)
        CreateThread(function()
            while valid() and DoesEntityExist(ped) and IsSynchronizedSceneRunning(s) and GetSynchronizedScenePhase(s) < 0.97 do Wait(0) end
            if valid() and DoesEntityExist(ped) then play(anim.clip, true, 2.0) end
        end)
    end

    -- A seat on the floor point: the act's chair stood there, the ped sat on it (enter: walking in first). The game's
    -- seat sets face the chair's -y, so the set turns round to face the place's heading. anim.origin: the point is the
    -- scene's own origin (a set made for a place of the map, like a sofa), its prop (anim.chair) only held or moved.
    function Actors.seat(ped, anim, floor, heading, valid, enter)
        if GetAnimDuration(anim.dict, anim.clip) <= 0.0 then return false end
        local old = chairs[ped]
        if old and DoesEntityExist(old) then DeleteEntity(old) end
        chairs[ped] = nil
        local fixed = anim.origin == true
        local chair
        if anim.chair then
            chair = Actors.prop(anim.chair, { pos = floor, heading = heading + (fixed and 0.0 or 180.0), ground = not fixed, floor = true }, valid, false)
            if not chair and not fixed then return false end
        end
        if chair then
            chairs[ped] = Track.add('seat', chair) -- tracked too, so a resource stop takes it
            FreezeEntityPosition(chair, false)
            watchChairs()
        end
        FreezeEntityPosition(ped, false)
        local o = (fixed or not chair) and floor or GetEntityCoords(chair)
        sit(ped, chair, o, vector3(0.0, 0.0, heading + (fixed and 0.0 or 180.0)), anim, enter, valid)
        return true
    end

    -- Moves a seated ped and its chair at once (the editor's drag): the scenes' origin follows the floor point.
    function Actors.moveSeat(ped, floor, heading)
        local s = seats[ped]
        if not s or not IsSynchronizedSceneRunning(s.ped) then return false end
        local z, turn = floor.z, s.fixed and 0.0 or 180.0
        if s.chair and DoesEntityExist(s.chair) and not s.fixed then
            local mn = GetModelDimensions(GetEntityModel(s.chair))
            z = floor.z - mn.z
        end
        if s.seat then SetSynchronizedSceneOrigin(s.seat, floor.x, floor.y, z, 0.0, 0.0, heading + turn, true) end
        SetSynchronizedSceneOrigin(s.ped, floor.x, floor.y, z - s.lift.z, 0.0, 0.0, heading + turn, true)
        return true
    end

    function Actors.enter(ped, anim, spot, valid)
        if GetAnimDuration(anim.dict, anim.enter) <= 0.0 or GetAnimDuration(anim.dict, anim.clip) <= 0.0 then return false end
        FreezeEntityPosition(ped, false)
        local target = GetEntityCoords(ped) -- the spot, lowered for heels
        local o, rot = target, spot.heading + 0.0
        for _ = 1, 3 do
            scene(o, vector3(0.0, 0.0, rot), ped, anim.dict, anim.clip, true, 1000.0)
            Wait(0)
            Wait(0)
            if not valid() or not DoesEntityExist(ped) then return true end
            rot = rot + wrap(spot.heading - GetEntityHeading(ped))
            o = o + (target - GetEntityCoords(ped))
        end
        sit(ped, nil, o + vector3(0.0, 0.0, Actors.heel(ped)), vector3(0.0, 0.0, rot), anim, true, valid)
        return true
    end

    -- A short gesture over the idle pose (upper body, as a secondary task) when the player picks the character.
    local gestureAt = 0
    function Actors.gesture(ped, gender, valid)
        if not DoesEntityExist(ped) or GetGameTimer() - gestureAt < 1500 then return end
        local list = {}
        for _, g in ipairs(((Config.Selection or {}).Gestures) or {}) do
            if type(g.dict) == 'string' and (g.gender == nil or g.gender == 'any' or g.gender == gender) then list[#list + 1] = g end
        end
        if #list == 0 then return end
        local g = list[math.random(#list)]
        if not DoesAnimDictExist(g.dict) then return end
        Stream.dict(g.dict, valid, 2000)
        if not valid() or not HasAnimDictLoaded(g.dict) or not DoesEntityExist(ped) then return end
        dicts[g.dict] = true
        gestureAt = GetGameTimer()
        TaskPlayAnim(ped, g.dict, g.clip, 4.0, -4.0, -1, 48, 0.0, false, false, false)
    end

    -- The picked pose, or the next ones of the pool when it is missing.
    function Actors.pose(ped, spot, gender, index, valid)
        local first = Actors.pick(spot.anim, gender, index)
        if Actors.idle(ped, first, spot, valid) then return true end
        for _, anim in ipairs(pool(gender)) do
            if not valid() then return false end
            if anim ~= first and Actors.idle(ped, anim, spot, valid) then return true end
        end
        return false
    end

    function Actors.show(ent, alpha)
        if not ent or not DoesEntityExist(ent) then return end
        SetEntityVisible(ent, true, false)
        -- A weapon given while the ped was hidden stays hidden with it.
        if IsEntityAPed(ent) then
            local gun = GetCurrentPedWeaponEntityIndex(ent)
            if gun and gun ~= 0 then SetEntityVisible(gun, true, false) end
            SetPedCurrentWeaponVisible(ent, true, false, false, false)
        end
        if alpha and alpha < 255 then SetEntityAlpha(ent, alpha, false) else ResetEntityAlpha(ent) end
    end

    -- Hidden actors stay put without collision, so a stack of them on one spot never pushes the shown one.
    function Actors.hide(ent)
        if not ent or not DoesEntityExist(ent) then return end
        if IsEntityAPed(ent) then
            local gun = GetCurrentPedWeaponEntityIndex(ent)
            if gun and gun ~= 0 then SetEntityVisible(gun, false, false) end
            SetPedCurrentWeaponVisible(ent, false, false, false, false)
        end
        SetEntityVisible(ent, false, false)
        FreezeEntityPosition(ent, true)
        SetEntityCollision(ent, false, false)
    end

    -- Lets the game unload what the scene asked for.
    function Actors.release()
        for dict in pairs(dicts) do RemoveAnimDict(dict) end
        for model in pairs(models) do SetModelAsNoLongerNeeded(model) end
        dicts, models = {}, {}
    end

    -- A scene's own ped: a local ped of the model in one of its random outfits, visible at once.
    function Actors.npc(model, spot, valid)
        local hash = type(model) == 'number' and model or joaat(tostring(model or ''))
        if not IsModelInCdimage(hash) or not IsModelAPed(hash) then
            warn('ped:' .. tostring(model), ('ped %s is not in the game files, skipped'):format(tostring(model)))
            return nil
        end
        local ped = spawnPed(hash, spot, valid)
        if not ped then return nil end
        SetPedRandomComponentVariation(ped, 0)
        SetPedRandomProps(ped)
        SetEntityVisible(ped, true, false)
        return ped
    end

    -- A prop in a ped's hand ({ model, bone, pos, rot }); the caller deletes it with the scene.
    function Actors.hold(ped, prop, valid)
        if type(prop) ~= 'table' or not DoesEntityExist(ped) then return nil end
        local model = type(prop.model) == 'number' and prop.model or joaat(tostring(prop.model or ''))
        if not IsModelInCdimage(model) or not request(model, valid) then return nil end
        local at = GetEntityCoords(ped)
        pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
        local obj = CreateObject(model, at.x, at.y, at.z, false, false, false)
        if not obj or obj == 0 then return nil end
        local p, r = prop.pos or {}, prop.rot or {}
        AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, prop.bone or 28422), (p.x or 0) + 0.0, (p.y or 0) + 0.0, (p.z or 0) + 0.0,
            (r.x or 0) + 0.0, (r.y or 0) + 0.0, (r.z or 0) + 0.0, true, true, false, false, 1, true)
        return obj
    end

    -- A loaded dictionary for a synced animation (kept until Actors.release).
    function Actors.dict(dict, valid)
        if type(dict) ~= 'string' or not DoesAnimDictExist(dict) then
            warn('anim:' .. tostring(dict), ('animation %s is missing from the game files, skipped'):format(tostring(dict)))
            return false
        end
        Stream.dict(dict, valid, 3000)
        if not valid() or not HasAnimDictLoaded(dict) then return false end
        dicts[dict] = true
        return true
    end

    -- Screen anchors for the page's hit boxes and name tags: the visible actors projected at most 30 times a second,
    -- sent as mc:scene:anchors only when something moved. Values are fractions of the viewport.
    Anchors = {}

    local HEAD, PELVIS = 31086, 11816
    local INTERVAL, EPSILON = 33, 0.003
    local tracked, last, lastAt = {}, nil, 0

    -- list = { { index, ent, ped = bool } }
    function Anchors.set(list)
        tracked = type(list) == 'table' and list or {}
        last = nil
    end

    local function project(p)
        local ok, x, y = GetScreenCoordFromWorldCoord(p.x, p.y, p.z)
        if not ok or x ~= x or y ~= y then return nil end
        return x, y
    end

    -- Head and pelvis widened sideways and in depth (the hit box), and the point between them.
    local function pedPoints(ped)
        local head = GetPedBoneCoords(ped, HEAD, 0.0, 0.0, 0.0)
        local pelvis = GetPedBoneCoords(ped, PELVIS, 0.0, 0.0, 0.0)
        local points = {}
        for _, p in ipairs({ vector3(head.x, head.y, head.z + 0.14), pelvis }) do
            for _, dx in ipairs({ -0.26, 0.26 }) do
                for _, dy in ipairs({ -0.16, 0.16 }) do points[#points + 1] = vector3(p.x + dx, p.y + dy, p.z) end
            end
        end
        return points, (head + pelvis) / 2
    end

    -- The corners of an object's model box, and its centre.
    local function objectPoints(ent)
        local min, max = GetModelDimensions(GetEntityModel(ent))
        local points = {}
        for _, x in ipairs({ min.x, max.x }) do
            for _, y in ipairs({ min.y, max.y }) do
                for _, z in ipairs({ min.z, max.z }) do points[#points + 1] = GetOffsetFromEntityInWorldCoords(ent, x, y, z) end
            end
        end
        return points, GetOffsetFromEntityInWorldCoords(ent, (min.x + max.x) / 2, (min.y + max.y) / 2, (min.z + max.z) / 2)
    end

    -- { l, t, r, b } clipped to the screen; nil when a corner is behind the camera or the box is off screen.
    local function box(points)
        local l, t, r, b = 1, 1, 0, 0
        for _, p in ipairs(points) do
            local x, y = project(p)
            if not x then return nil end
            l, t, r, b = math.min(l, x), math.min(t, y), math.max(r, x), math.max(b, y)
        end
        if r <= 0 or l >= 1 or b <= 0 or t >= 1 then return nil end
        return { math.max(0, l), math.max(0, t), math.min(1, r), math.min(1, b) }
    end

    local function anchorOf(item)
        local ent = item.ent
        if not ent or not DoesEntityExist(ent) or not IsEntityVisible(ent) then return nil end
        local points, centre = (item.ped and pedPoints or objectPoints)(ent)
        local x, y = project(centre)
        if not x then return nil end
        return { index = item.index, x = x, y = y, box = box(points) }
    end

    local function near(a, b)
        return math.abs(a - b) <= EPSILON
    end

    local function sameBox(a, b)
        if a == nil or b == nil then return a == b end
        for i = 1, 4 do
            if not near(a[i], b[i]) then return false end
        end
        return true
    end

    local function changed(list, old)
        if not old or #list ~= #old then return true end
        for i, item in ipairs(list) do
            local o = old[i]
            if o.index ~= item.index or not near(o.x, item.x) or not near(o.y, item.y) or not sameBox(o.box, item.box) then return true end
        end
        return false
    end

    -- Frame 'anchors'.
    function Anchors.tick(now)
        now = type(now) == 'number' and now or GetGameTimer()
        if now - lastAt < INTERVAL then return end
        lastAt = now
        local list = {}
        for _, item in ipairs(tracked) do list[#list + 1] = anchorOf(item) end
        table.sort(list, function(a, b) return a.index < b.index end)
        if not changed(list, last) then return end
        last = list
        MC.Send('mc:scene:anchors', { list = list })
    end

    function Anchors.clear()
        tracked, last, lastAt = {}, nil, 0
        MC.Send('mc:scene:anchors', { list = {} })
    end

    -- The focused character's own car as a local vehicle on the scene's vehicle spot; it dissolves in over 300 ms.
    ShowCar = {}

    local DISSOLVE_MS = 300
    local car, owner, fadeAt, awake = nil, nil, 0, false

    local function sleep()
        if not awake then return end
        awake = false
        Frame.off('dissolve')
    end

    -- Frame 'dissolve': alpha 0 -> 255, then the normal alpha back; it stops itself.
    local function dissolve()
        if not car or not DoesEntityExist(car) then return sleep() end
        local t = (GetGameTimer() - fadeAt) / DISSOLVE_MS
        if t >= 1 then
            ResetEntityAlpha(car)
            return sleep()
        end
        SetEntityAlpha(car, math.floor(255 * t), false)
    end

    -- The car drives in from behind its spot under its own wheels, slowing to a stop on the spot (it is put there
    -- exactly at the end, or when anything gets in the way for too long).
    local ROLL_DECEL, ROLL_TOP, ROLL_MS = 3.2, 9.0, 6000
    local function rollIn(veh, spot, metres, night)
        local h = math.rad(spot.h)
        local fx, fy = -math.sin(h), math.cos(h)
        SetEntityCoordsNoOffset(veh, spot.x - fx * metres, spot.y - fy * metres, spot.z + 0.5, false, false, false)
        SetEntityHeading(veh, spot.h + 0.0)
        SetVehicleOnGroundProperly(veh)
        FreezeEntityPosition(veh, false)
        SetVehicleEngineOn(veh, true, true, false)
        SetVehicleLights(veh, 2)
        local stop = GetGameTimer() + ROLL_MS
        while car == veh and DoesEntityExist(veh) and GetGameTimer() < stop do
            local p = GetEntityCoords(veh)
            local left = (spot.x - p.x) * fx + (spot.y - p.y) * fy
            if left <= 0.08 then break end
            SetVehicleForwardSpeed(veh, math.min(ROLL_TOP, math.sqrt(2 * ROLL_DECEL * left)) + 0.2)
            Wait(0)
        end
        if car ~= veh or not DoesEntityExist(veh) then return end
        SetVehicleForwardSpeed(veh, 0.0)
        SetEntityCoordsNoOffset(veh, spot.x + 0.0, spot.y + 0.0, spot.z + 0.5, false, false, false)
        SetEntityHeading(veh, spot.h + 0.0)
        SetVehicleOnGroundProperly(veh)
        FreezeEntityPosition(veh, true)
        SetVehicleEngineOn(veh, false, true, false)
        if not night then SetVehicleLights(veh, 0) end
    end

    local function modelOf(entry)
        local model = tonumber(entry.model) or (type(entry.model) == 'string' and entry.model ~= '' and joaat(entry.model))
        if not model or not IsModelInCdimage(model) or not IsModelAVehicle(model) then return nil end
        return model
    end

    -- entry = { model, props } from the preview; spot = { x, y, z, h }; key names whose car it is.
    function ShowCar.show(entry, spot, valid, key, night)
        if type(entry) ~= 'table' or type(spot) ~= 'table' then return false end
        local model = modelOf(entry)
        if not model then return false end
        Stream.model(model, valid, 6000)
        if not valid() or not HasModelLoaded(model) then return false end
        ShowCar.clear()
        pcall(function() exports['FeloxAC']:CreateVehicle(model) end) --[[FeloxAC:auto]]
        local veh = CreateVehicle(model, spot.x + 0.0, spot.y + 0.0, spot.z + 0.5, spot.h + 0.0, false, false)
        SetModelAsNoLongerNeeded(model)
        if not veh or veh == 0 then return false end
        SetEntityAlpha(veh, 0, false)
        SetVehicleOnGroundProperly(veh)
        if type(entry.props) == 'table' then
            local ok, err = pcall(lib.setVehicleProperties, veh, entry.props)
            if not ok then print(('^3[%s] preview car props failed: %s^7'):format(GetCurrentResourceName(), err)) end
        end
        SetVehicleDirtLevel(veh, 0.0)
        SetVehicleDoorsLocked(veh, 2)
        FreezeEntityPosition(veh, true)
        SetEntityInvincible(veh, true)
        if night then SetVehicleLights(veh, 2) end
        car, owner, fadeAt = veh, key, GetGameTimer()
        local roll = tonumber((Config.Preview or {}).RollIn) or 0
        if roll > 0 and not MC.lowSpec() then CreateThread(function() rollIn(veh, spot, roll, night) end) end
        if not awake then
            awake = true
            Frame.on('dissolve', dissolve)
        end
        return true
    end

    -- Whose car stands there now (the key given to show), or nil.
    function ShowCar.owner()
        return car and DoesEntityExist(car) and owner or nil
    end

    function ShowCar.clear()
        sleep()
        if car and DoesEntityExist(car) then DeleteEntity(car) end
        car, owner = nil, nil
    end
end

-- A role scene's own cast: its peds (extras), its vehicles, the props in hands, and the synced animations between
-- the focused actor and an extra (a pair now and then, a sync that never stops). All of it is local, made after the
-- scene's props and deleted with the scene ('scene' track group).
do
    Cast = {}

    local state = nil -- { scene, peds = { [id] = { ent, spot, act, sex } }, token, held = { [ped] = obj } }

    local function lift()
        return tonumber((Config.Selection or {}).PedOffset) or 1.0
    end

    -- A local point of the scene as a ped spot (root above the ground) and its ground point.
    local function spotOf(scene, at)
        local x, y, z = CamMath.toWorld(scene.anchor, at.x or 0, at.y or 0, 0)
        z = Scene.settle(scene, x, y, z) + (at.z or 0)
        local heading = ((scene.anchor.h or 0) + (at.h or 0)) % 360
        return { pos = vector3(x, y, z + lift()), heading = heading, ground = { pos = vector3(x, y, z), heading = heading } }
    end

    local function modelHash(model)
        return type(model) == 'number' and model or joaat(tostring(model or ''))
    end

    -- A broken-down car: the front caved in, a window out, the engine smoking.
    local function wreck(veh)
        for _, hit in ipairs({ { 0.0, 2.0, 0.2 }, { 0.6, 1.8, 0.3 }, { -0.6, 1.9, 0.1 }, { 0.8, 0.4, 0.4 } }) do
            SetVehicleDamage(veh, hit[1], hit[2], hit[3], 400.0, 120.0, true)
        end
        SmashVehicleWindow(veh, 0)
        SetVehicleBodyHealth(veh, 250.0)
        SetVehicleEngineHealth(veh, 150.0)
    end

    -- A car tilted nose up (or down) on its back wheels: turned round the rear axle, so those wheels stay on the ground;
    -- its own height (at.z) then moves it up or down.
    function Cast.tiltCar(veh, c)
        local deg = tonumber(c.tilt)
        if not deg or deg == 0 then return end
        local wheel = GetEntityBoneIndexByName(veh, deg > 0 and 'wheel_lr' or 'wheel_lf')
        local axle = wheel ~= -1 and math.abs(GetOffsetFromEntityGivenWorldCoords(veh, GetWorldPositionOfEntityBone(veh, wheel)).y) or 1.3
        local p, h = GetEntityCoords(veh), GetEntityHeading(veh)
        local lift = axle * math.sin(math.rad(math.abs(deg))) + (tonumber(c.at and c.at.z) or 0.0)
        SetEntityCoordsNoOffset(veh, p.x, p.y, p.z + lift, false, false, false)
        SetEntityRotation(veh, deg + 0.0, 0.0, h, 2, true)
    end

    -- A street build (tuned): body kit, wheels, lowered, tinted, xenons and neon, in street colours. Each model always
    -- gets the same build, so a scene looks the same every time.
    local STREET = { 12, 0, 147, 29, 70, 88, 138, 64, 55, 145 } -- matte black, black, carbon, red, blue, yellow, orange...
    local NEON = { { 255, 0, 255 }, { 0, 150, 255 }, { 255, 50, 50 }, { 0, 255, 140 }, { 255, 255, 255 } }
    local function tune(veh)
        local seed = math.abs(GetEntityModel(veh)) % 997
        SetVehicleModKit(veh, 0)
        SetVehicleWheelType(veh, 5)
        for _, m in ipairs({ 0, 1, 2, 3, 4, 6, 7, 10, 15, 23 }) do
            local n = GetNumVehicleMods(veh, m)
            if n > 0 then SetVehicleMod(veh, m, (seed + m * 7) % n, false) end
        end
        ToggleVehicleMod(veh, 22, true)
        SetVehicleXenonLightsColor(veh, seed % 13)
        SetVehicleWindowTint(veh, 1)
        local main = STREET[seed % #STREET + 1]
        SetVehicleColours(veh, main, STREET[(seed + 3) % #STREET + 1])
        SetVehicleExtraColours(veh, main, 0)
        local neon = NEON[seed % #NEON + 1]
        for side = 0, 3 do SetVehicleNeonLightEnabled(veh, side, true) end
        SetVehicleNeonLightsColour(veh, neon[1], neon[2], neon[3])
    end

    -- A scene car's look and life (the editor's too): dirt, damage, engine, lights, sirens, open doors.
    function Cast.styleCar(veh, c)
        if c.tuned then tune(veh) end
        SetVehicleDirtLevel(veh, c.wrecked and 12.0 or 0.0)
        if c.wrecked then wreck(veh) end
        if c.smoke then SetVehicleEngineHealth(veh, 150.0) end -- a smoking engine, the body untouched
        if c.engine or c.siren or c.wrecked or c.smoke then SetVehicleEngineOn(veh, true, true, false) end
        if c.lights then SetVehicleLights(veh, 2) end
        if c.siren then
            SetVehicleHasMutedSirens(veh, true)
            SetVehicleSiren(veh, true)
        end
        -- Doors open a moment after the car is made (at once they can stay shut).
        if c.doors then
            SetTimeout(300, function()
                if not DoesEntityExist(veh) then return end
                for _, door in ipairs(c.doors) do SetVehicleDoorOpen(veh, door, false, true) end
            end)
        end
    end

    local function buildCar(scene, c, valid)
        local hash = modelHash(c.model)
        local mine = state
        if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) or not Stream.model(hash, valid, 6000) then return end
        -- The scene can close or change while the model streams; then the car is not built for it.
        if not state or state ~= mine then return SetModelAsNoLongerNeeded(hash) end
        local at = spotOf(scene, c.at).ground
        pcall(function() exports['FeloxAC']:CreateVehicle(hash) end) --[[FeloxAC:auto]]
        local veh = CreateVehicle(hash, at.pos.x, at.pos.y, at.pos.z + 0.5, at.heading + 0.0, false, false)
        SetModelAsNoLongerNeeded(hash)
        if not veh or veh == 0 then return end
        Track.add('scene', veh)
        state.cars[#state.cars + 1] = veh
        SetVehicleOnGroundProperly(veh)
        SetVehicleDoorsLocked(veh, 2)
        Cast.tiltCar(veh, c)
        Cast.styleCar(veh, c)
        SetEntityInvincible(veh, true)
        FreezeEntityPosition(veh, true)
    end

    -- A weapon held on one of the scene's peds (act.aim): turned to it, in a steady police aim (no AI sway).
    local AIM_DICT, AIM_CLIP = 'combat@aim_variations@arrest', 'cop_med_arrest_01'
    local PISTOLS = 416676503 -- the pistol weapon group

    -- The weapon's own stance towards a point (or a ped): a pistol in the steady police aim; a long gun aimed by the
    -- game, or held low at the ground before the target (ready).
    local function stance(ped, act, point, target, valid)
        Film.arm(ped, act.weapon, valid)
        FreezeEntityPosition(ped, true)
        if GetWeapontypeGroup(joaat(act.weapon or 'WEAPON_PISTOL')) == PISTOLS then
            if Actors.dict(AIM_DICT, valid) then TaskPlayAnim(ped, AIM_DICT, AIM_CLIP, 8.0, -8.0, -1, 1, 0.0, false, false, false) end
        elseif act.ready then
            local a = GetEntityCoords(ped)
            local low = a + (point - a) * 0.35
            TaskAimGunAtCoord(ped, low.x, low.y, a.z - 0.9, -1, false, false)
        elseif target then
            TaskAimGunAtEntity(ped, target, -1, false)
        else
            TaskAimGunAtCoord(ped, point.x, point.y, point.z, -1, false, false)
        end
    end

    -- The editor's stand-ins: the same stance towards a point ahead.
    function Cast.aimPose(ped, act, valid)
        local ahead = GetOffsetFromEntityInWorldCoords(ped, 0.0, 6.0, 0.4)
        stance(ped, act, ahead, nil, valid)
    end

    local function aimAt(ped, act)
        local target = state and state.peds[act.aim]
        if not target or not DoesEntityExist(target.ent) then return false end
        local valid = function() return DoesEntityExist(ped) end
        local a, b = GetEntityCoords(ped), GetEntityCoords(target.ent)
        SetEntityHeading(ped, math.deg(math.atan(-(b.x - a.x), b.y - a.y)))
        stance(ped, act, b, target.ent, valid)
        return true
    end

    -- The act for a sex: the spot's own female act, else the act's female variant, else the act.
    local function actOf(spot, gender)
        local act = spot.act
        if gender == 'f' then return spot.female or (type(act) == 'table' and act.female) or act end
        return act
    end

    -- An act on a ped with its held prop (a ped keeps one prop: the old one goes when a new act starts).
    local function play(ped, act, spot, valid)
        if state and state.held[ped] then
            local old = state.held[ped]
            state.held[ped] = nil
            if DoesEntityExist(old) then DeleteEntity(old) end
        end
        if act and act.aim and not act.dict and not act.scenario then
            Actors.resetPose(ped)
            return aimAt(ped, act)
        end
        if not act or not Actors.idle(ped, act, spot, valid) then return false end
        if act.prop then
            local obj = Actors.hold(ped, act.prop, valid)
            if obj and state then state.held[ped] = Track.add('scene', obj) end
        end
        return true
    end

    -- A scene ped that walks its points and back, pausing a moment at each end (a busy street, a campus).
    local function walker(scene, ped, e, valid)
        local points = { spotOf(scene, e.at).ground.pos }
        for _, p in ipairs(e.walk) do points[#points + 1] = spotOf(scene, p).ground.pos end
        CreateThread(function()
            FreezeEntityPosition(ped, false)
            SetEntityCollision(ped, true, true)
            ClearPedTasks(ped)
            local i, step = 2, 1
            while valid() and DoesEntityExist(ped) do
                local p = points[i]
                -- Straight to the point (the points are placed by hand); held up by something, round it on the path finder,
                -- and still stuck, on to the next point.
                TaskGoStraightToCoord(ped, p.x, p.y, p.z, e.speed or 1.0, 30000, 0.0, 0.5)
                local stop, last, still, routed = GetGameTimer() + 30000, GetEntityCoords(ped), 0, false
                repeat
                    Wait(500)
                    local now = DoesEntityExist(ped) and GetEntityCoords(ped) or last
                    still = #(now.xy - last.xy) < 0.15 and still + 1 or 0
                    last = now
                    if still >= 4 and not routed then
                        TaskFollowNavMeshToCoord(ped, p.x, p.y, p.z, e.speed or 1.0, 30000, 0.6, false, 0.0)
                        routed, still = true, 0
                    end
                until not valid() or not DoesEntityExist(ped) or GetGameTimer() > stop or (routed and still >= 4)
                    or #(last.xy - p.xy) < 1.0
                if i == 1 or i == #points then Wait(math.random(600, 2500)) end
                if i + step > #points or i + step < 1 then step = -step end
                i = i + step
            end
        end)
    end

    local function buildExtra(scene, e, valid)
        local spot = spotOf(scene, e.at)
        local mine = state
        local ped = Actors.npc(e.model, spot, valid)
        -- The scene can close or change while the model streams (Cast.clear, a new Cast.build); then the ped is not ours.
        if not state or state ~= mine then
            if ped and DoesEntityExist(ped) then DeleteEntity(ped) end
            return
        end
        if ped then
            Track.add('scene', ped)
            if e.alpha and e.alpha < 255 then SetEntityAlpha(ped, e.alpha, false) end
            if e.walk then walker(scene, ped, e, valid) elseif e.act then play(ped, e.act, spot, valid) end
            -- play waits while its animation streams: the scene may have closed or changed meanwhile, as above.
            if state ~= mine then
                if DoesEntityExist(ped) then DeleteEntity(ped) end
                return
            end
            mine.peds[e.id or ('extra' .. tostring(#mine.order + 1))] = { ent = ped, spot = spot, act = e.act, sex = e.sex }
        end
        mine.order[#mine.order + 1] = ped or false -- by the extra's index, for Cast.taken
    end

    -- The scene's vehicles and peds (none under low spec); blocks while they stream.
    function Cast.build(scene, valid)
        state = { scene = scene, peds = {}, order = {}, token = 0, held = {}, cars = {} }
        if MC.lowSpec() then return end
        for _, c in ipairs(scene.cars or {}) do
            if not valid() then return end
            buildCar(scene, c, valid)
        end
        for _, e in ipairs(scene.extras or {}) do
            if not valid() then return end
            buildExtra(scene, e, valid)
        end
    end

    -- The scene's own peds by id and its cars in order (films).
    function Cast.peds() return state and state.peds or {} end
    function Cast.cars() return state and state.cars or {} end

    function Cast.clear()
        state = nil
    end

    -- The dictionary of a pair for two sexes: {pair} becomes m_m, f_m or f_f.
    local function pairDict(dict, a, b)
        local key = (a == 'm' and b == 'm') and 'm_m' or ((a == 'f' and b == 'f') and 'f_f' or 'f_m')
        return (dict:gsub('{pair}', key))
    end
    Cast.pairDict = pairDict

    -- One synced animation of the actor and an extra from the actor's ground point (plus the pair's offset).
    local function synced(actor, spot, p, partner, loop, valid)
        local dict = pairDict(p.dict, actor.gender == 'f' and 'f' or 'm', partner.sex)
        local dictB = p.dictB and pairDict(p.dictB, actor.gender == 'f' and 'f' or 'm', partner.sex) or dict
        if not Actors.dict(dict, valid) or not Actors.dict(dictB, valid) then return nil end
        local o = p.offset or {}
        local x, y, z = CamMath.toWorld({ x = spot.ground.pos.x, y = spot.ground.pos.y, z = spot.ground.pos.z, h = spot.heading },
            o.x or 0, o.y or 0, o.z or 0)
        local rot = spot.heading + 0.0
        if not loop then
            -- A pair is turned and moved so the actor's part starts where it stands, the way it faces (the other one comes to it).
            local start = GetAnimInitialOffsetRotation(dict, p.a, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2)
            local at = GetAnimInitialOffsetPosition(dict, p.a, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2)
            rot = rot - start.z
            local r = math.rad(rot)
            x, y = x - (at.x * math.cos(r) - at.y * math.sin(r)), y - (at.x * math.sin(r) + at.y * math.cos(r))
        end
        local scene = CreateSynchronizedScene(x, y, z, 0.0, 0.0, rot, 2)
        SetSynchronizedSceneLooped(scene, loop == true)
        for _, ped in ipairs({ actor.ent, partner.ent }) do
            FreezeEntityPosition(ped, false)
            SetEntityCollision(ped, false, false)
        end
        TaskSynchronizedScene(actor.ent, scene, dict, p.a, 8.0, -8.0, 0, 0, 1000.0, 0)
        TaskSynchronizedScene(partner.ent, scene, dictB, p.b, 8.0, -8.0, 0, 0, 1000.0, 0)
        return scene, GetAnimDuration(dict, p.a) * 1000
    end

    -- The focused actor's part in a role scene, after it shows: its act (or the never-ending sync), and with a pair the
    -- loop that plays it every so often. false when the spot asks for nothing (the pose library takes over).
    function Cast.perform(actor, spot, valid)
        if not state or not actor or not DoesEntityExist(actor.ent) then
            MC.debug('pose: perform skipped (cast state: %s, ped: %s)', tostring(state ~= nil), tostring(actor and DoesEntityExist(actor.ent)))
            return false
        end
        state.token = state.token + 1
        local token, mine = state.token, state
        local function live() return valid() and state == mine and mine.token == token and DoesEntityExist(actor.ent) end
        local act = actOf(spot, actor.gender)
        local sync = spot.sync and state.peds[spot.sync.with]
        -- The first play only needs the scene: a later perform or release (another card, a swap) must not cut a dictionary
        -- still streaming and leave the actor standing; the token stops the pair loop below.
        local function scene() return valid() and state == mine and DoesEntityExist(actor.ent) end
        if sync and synced(actor, spot, spot.sync, sync, true, live) then return true end
        if not act or not play(actor.ent, act, spot, scene) then return false end
        local p = spot.pair
        local partner = p and state.peds[p.with]
        if not partner then return true end
        CreateThread(function()
            while live() do
                Wait(p.every)
                if not live() or MC.lowSpec() or not IsEntityVisible(actor.ent) or not DoesEntityExist(partner.ent) then return end
                -- With a partner or crew round the actor, their moments (moments.lua) play instead.
                if p.walk and not Moments.busy() then
                    -- The actor walks to the other one and back (an arrest).
                    if not Moments.walkPair(actor.ent, partner.ent, pairDict(p.dict, actor.gender == 'f' and 'f' or 'm', partner.sex), p.a, p.b, spot, live) then return end
                    if not live() then return end
                    play(actor.ent, act, spot, live)
                    if partner.act then play(partner.ent, partner.act, partner.spot, live) end
                elseif not Moments.company() and not Moments.busy() then
                    local _, ms = synced(actor, spot, p, partner, false, live)
                    if not ms then return end
                    Wait(math.floor(ms) + 100)
                    if not live() then return end
                    play(actor.ent, act, spot, live)
                    if partner.act then play(partner.ent, partner.act, partner.spot, live) end
                end
            end
        end)
        return true
    end

    -- A companion's act (a crew member, another character): its spot's act with the held prop, no pair loop.
    function Cast.act(ped, spot, gender, valid)
        if not state or type(spot) ~= 'table' then return false end
        local act = actOf(spot, gender)
        return act ~= nil and play(ped, act, spot, valid)
    end

    -- Extras standing in for a companion (fill = n) hide while n companions are there.
    function Cast.taken(count)
        if not state then return end
        for i, e in ipairs(state.scene.extras or {}) do
            local ped = state.order[i]
            if e.fill and ped and DoesEntityExist(ped) then SetEntityVisible(ped, e.fill > count, false) end
        end
    end

    -- The actor goes off screen (single mode swaps it): its pair loop stops, its held prop goes, and its tasks/chairs reset.
    function Cast.release(ped)
        Actors.resetPose(ped)
        if not state then return end
        state.token = state.token + 1
        local obj = state.held[ped]
        state.held[ped] = nil
        if obj and DoesEntityExist(obj) then DeleteEntity(obj) end
    end
end

-- Films: a role scene's opening (client/films/*.lua), played once a session per character, the menu hidden; any
-- key skips to its end. A film is a script over the scene's own people and cars; final(f) sets the end state at
-- once (after the film, a skip, or when it was already seen). The scene's still begins where it ends.
do
    Film = {}
    Films = Films or {}

    local STOP = setmetatable({}, { __tostring = function() return 'film stopped' end })
    local seen, cur = {}, nil

    local function v3(t) return vector3((t.x or t[1] or 0) + 0.0, (t.y or t[2] or 0) + 0.0, (t.z or t[3] or 0) + 0.0) end

    -- The camera: follow (mounted on a ped, offset in its frame) or from (a fixed point, or one in an entity's frame),
    -- looking at an entity (with an offset) or a point; eased towards its aim each frame.
    local function camTick()
        local c = cur and cur.cam
        if not c then return end
        local now = GetGameTimer()
        local dt = math.min(0.1, (now - (cur.camAt or now)) / 1000.0)
        cur.camAt = now
        local pos = c.follow and DoesEntityExist(c.follow) and GetOffsetFromEntityInWorldCoords(c.follow, c.offset.x, c.offset.y, c.offset.z)
            or c.fromEnt and DoesEntityExist(c.fromEnt) and GetOffsetFromEntityInWorldCoords(c.fromEnt, c.fromOffset.x, c.fromOffset.y, c.fromOffset.z)
            or c.from
        local aim = c.lookEnt and DoesEntityExist(c.lookEnt) and GetOffsetFromEntityInWorldCoords(c.lookEnt, c.lookOffset.x, c.lookOffset.y, c.lookOffset.z) or c.look
        if not pos or not aim then return end
        local k = cur.camPos and (1.0 - math.exp(-dt * (c.damp or 3.0))) or 1.0
        cur.camPos = cur.camPos and (cur.camPos + (pos - cur.camPos) * k) or pos
        cur.camAim = cur.camAim and (cur.camAim + (aim - cur.camAim) * k) or aim
        cur.fov = cur.fov and (cur.fov + ((c.fov or 40.0) - cur.fov) * k) or (c.fov or 40.0)
        local p, a = cur.camPos, cur.camAim
        local pitch, yaw = CamMath.lookRot(p.x, p.y, p.z, a.x, a.y, a.z)
        Rig.set(p.x, p.y, p.z, pitch, 0.0, yaw, cur.fov)
    end

    local function api(ctx, live)
        local f = {}
        local function check() if not live() then error(STOP, 0) end end

        function f.ped(name) return ctx.peds[name] and ctx.peds[name].ent or nil end
        function f.car(i) return ctx.cars[i] end
        function f.has(name) local p = f.ped(name) return p ~= nil and DoesEntityExist(p) end
        function f.crew() return ctx.crew end
        function f.gender(name) return ctx.peds[name] and ctx.peds[name].sex or 'm' end
        local function ent(x) return type(x) == 'string' and f.ped(x) or x end

        -- Where a ped belongs in the still: its spot.
        function f.spot(name) local p = ctx.peds[name] return p and p.spot end
        -- A point beside a car door (outside it), out metres from the car's side.
        function f.beside(car, door, out)
            local veh = ent(car)
            local p = GetEntryPositionOfDoor(veh, door)
            local c = GetEntityCoords(veh)
            local d = vector3(p.x - c.x, p.y - c.y, 0.0)
            local n = #d > 0.01 and d / #d or vector3(0.0, 0.0, 0.0)
            local at = p + n * (out or 0.0)
            return { pos = vector3(at.x, at.y, p.z + 1.0), heading = (math.deg(math.atan(n.x, -n.y)) + 360.0) % 360.0 }
        end

        function f.wait(ms)
            local stop = GetGameTimer() + ms
            while GetGameTimer() < stop do check() Wait(0) end
        end

        function f.cam(s)
            local c = { fov = s.fov, damp = s.damp }
            if s.follow then c.follow, c.offset = ent(s.follow), v3(s.offset or { 0.0, -3.0, 1.0 }) end
            if s.from then
                if type(s.from) == 'table' and s.from.ent then c.fromEnt, c.fromOffset = ent(s.from.ent), v3(s.from.offset or {})
                else c.from = v3(s.from) end
            end
            local look = s.look or { ent = s.follow }
            if type(look) == 'string' then look = { ent = look } end
            if s.follow and not look.ent then look = { ent = s.follow, offset = look } end -- an offset on the followed ped
            if look.ent then c.lookEnt, c.lookOffset = ent(look.ent), v3(look.offset or { 0.0, 0.0, 0.3 }) else c.look = v3(look) end
            if s.cut then cur.camPos, cur.camAim, cur.fov = nil, nil, nil end
            cur.cam = c
        end

        -- Moves a ped at once (a spot or { pos, heading }), hidden of nothing.
        function f.place(name, at)
            local p = ent(name)
            if not p or not at then return end
            ClearPedTasksImmediately(p)
            FreezeEntityPosition(p, false)
            SetEntityCollision(p, true, true)
            SetEntityCoordsNoOffset(p, at.pos.x, at.pos.y, at.pos.z, false, false, false)
            SetEntityHeading(p, (at.heading or 0.0) + 0.0)
        end

        function f.go(name, at, speed)
            local p = ent(name)
            FreezeEntityPosition(p, false)
            SetEntityCollision(p, true, true)
            TaskGoStraightToCoord(p, at.pos.x, at.pos.y, at.pos.z, speed or 1.0, 12000, (at.heading or GetEntityHeading(p)) + 0.0, 0.1)
        end

        function f.walk(name, at, speed)
            f.go(name, at, speed)
            local p, stop = ent(name), GetGameTimer() + 12000
            while GetGameTimer() < stop do
                check()
                local c = GetEntityCoords(p)
                if math.sqrt((c.x - at.pos.x) ^ 2 + (c.y - at.pos.y) ^ 2) < 0.25 then break end
                Wait(0)
            end
        end

        function f.arm(name, weapon)
            Film.arm(ent(name), weapon, live)
        end

        function f.holster(name) SetCurrentPedWeapon(ent(name), joaat('WEAPON_UNARMED'), true) end

        function f.aim(name, target)
            local p = ent(name)
            FreezeEntityPosition(p, false)
            TaskAimGunAtEntity(p, ent(target), -1, false)
        end

        -- Closes in on target with the gun up, stopping stop metres short.
        function f.aimWalk(name, target, stop)
            local p, t = ent(name), ent(target)
            FreezeEntityPosition(p, false)
            SetEntityCollision(p, true, true)
            TaskGoToEntityWhileAimingAtEntity(p, t, t, 1.0, false, stop + 0.0, 4.0, true, false, joaat('FIRING_PATTERN_FULL_AUTO'))
            local deadline = GetGameTimer() + 12000
            while GetGameTimer() < deadline and #(GetEntityCoords(p) - GetEntityCoords(t)) > stop + 0.35 do check() Wait(0) end
        end

        function f.anim(name, dict, clip, flag, ms)
            local p = ent(name)
            if not Actors.dict(dict, live) then return end
            TaskPlayAnim(p, dict, clip, 4.0, -4.0, ms or -1, flag or 0, 0.0, false, false, false)
        end

        function f.length(dict, clip) return math.floor(GetAnimDuration(dict, clip) * 1000) end

        -- A two-person clip lined up on the still one: the mover walks to its mark first; blocks until it ends.
        function f.pair(mover, still, dict, a, b)
            local m, s = ent(mover), ent(still)
            if not Actors.dict(dict, live) then return end
            local origin, h = Moments.align(dict, b, GetEntityCoords(s), GetEntityHeading(s))
            local p, ph = Moments.startOf(dict, a, origin, h)
            f.walk(mover, { pos = p, heading = ph })
            Moments.sync(origin, h, { { ped = m, dict = dict, clip = a }, { ped = s, dict = dict, clip = b } })
            f.wait(f.length(dict, a))
        end

        -- Cuffs from behind: the cop walks to the suspect's back, the suspect is held to him for the paired clips (as GTA
        -- Online does it), then let go.
        function f.cuffFrom(cop, suspect)
            local c, s = ent(cop), ent(suspect)
            if not Actors.dict('mp_arrest_paired', live) then return end
            local h = GetEntityHeading(s)
            local behind = GetOffsetFromEntityInWorldCoords(s, 0.1, -0.5, 0.0)
            f.walk(cop, { pos = behind, heading = h })
            ClearPedTasksImmediately(c)
            ClearPedTasksImmediately(s)
            SetEntityHeading(c, h)
            FreezeEntityPosition(s, false)
            SetEntityCollision(s, true, true)
            AttachEntityToEntity(s, c, GetPedBoneIndex(c, 11816), -0.1, 0.45, 0.0, 0.0, 0.0, 20.0, false, false, false, false, 2, false)
            TaskPlayAnim(c, 'mp_arrest_paired', 'cop_p2_back_left', 8.0, -8.0, 3750, 0, 0.0, false, false, false)
            TaskPlayAnim(s, 'mp_arrest_paired', 'crook_p2_back_left', 8.0, -8.0, 3750, 0, 0.0, false, false, false)
            f.wait(3000)
            DetachEntity(s, true, false)
            f.ground(suspect)
            f.wait(500)
        end

        -- Feet on the ground (after a ped was let go).
        function f.ground(name)
            local p = ent(name)
            local c = GetEntityCoords(p)
            local ok, gz = GetGroundZFor_3dCoord(c.x, c.y, c.z + 1.0, false)
            if ok then SetEntityCoordsNoOffset(p, c.x, c.y, gz + 1.0, false, false, false) end
        end

        function f.black(ms)
            DoScreenFadeOut(ms or 250)
            local deadline = GetGameTimer() + (ms or 250) + 400
            while not IsScreenFadedOut() and GetGameTimer() < deadline do Wait(0) end
        end

        function f.open(ms) DoScreenFadeIn(ms or 500) end

        -- Out of a car through its door; blocks until out.
        function f.leave(name, car)
            local p, veh = ent(name), ent(car)
            SetVehicleDoorsLocked(veh, 1)
            TaskLeaveVehicle(p, veh, 256)
            local deadline = GetGameTimer() + 5000
            while GetGameTimer() < deadline and IsPedInVehicle(p, veh, false) do check() Wait(0) end
        end

        function f.cuff(name)
            local p = ent(name)
            if Actors.dict('mp_arresting', live) then TaskPlayAnim(p, 'mp_arresting', 'idle', 8.0, -8.0, -1, 49, 0.0, false, false, false) end
            RequestAnimSet('move_m@prisoner_cuffed')
            SetPedMovementClipset(p, 'move_m@prisoner_cuffed', 0.5)
            SetEnableHandcuffs(p, true)
        end

        function f.board(name, car, seat)
            local p, veh = ent(name), ent(car)
            FreezeEntityPosition(p, false)
            SetEntityCollision(p, true, true)
            SetVehicleDoorsLocked(veh, 1)
            FreezeEntityPosition(veh, false)
            TaskEnterVehicle(p, veh, 10000, seat, 1.0, 1, 0)
            local deadline = GetGameTimer() + 10000
            while GetGameTimer() < deadline and not IsPedInVehicle(p, veh, false) do check() Wait(0) end
            FreezeEntityPosition(veh, true)
        end

        -- Seated at once (final states).
        function f.seat(name, car, seat)
            local p, veh = ent(name), ent(car)
            if not IsPedInVehicle(p, veh, false) then
                ClearPedTasksImmediately(p)
                FreezeEntityPosition(p, false)
                SetPedIntoVehicle(p, veh, seat)
            end
        end

        function f.door(car, index, open)
            local veh = ent(car)
            if open == false then SetVehicleDoorShut(veh, index, false) else SetVehicleDoorOpen(veh, index, false, false) end
        end

        -- Out of a car, cuffs off, back on its spot as the film begins.
        function f.reset(name)
            local p, d = f.ped(name), ctx.peds[name]
            if not p or not d or not d.spot then return end
            ResetPedMovementClipset(p, 0.0)
            SetEnableHandcuffs(p, false)
            f.place(name, d.spot)
        end

        -- A ped back on its spot (unless it is there) in its own act.
        function f.home(name)
            local d, p = ctx.peds[name], f.ped(name)
            if not d or not p or not d.spot then return end
            SetCurrentPedWeapon(p, joaat('WEAPON_UNARMED'), true)
            if #(GetEntityCoords(p) - d.spot.pos) > 0.3 then f.place(name, d.spot) end
            SetEntityHeading(p, d.spot.heading + 0.0)
            if d.restore then d.restore(live) end
        end

        return f
    end

    -- Plays a scene's film (blocks) or, when it was seen this session or replay is off, sets its end at once.
    -- ctx = { peds = { me = { ent, sex, spot, restore }, partner, crew1.., <extra id> = { ent } }, cars = { veh.. }, crew = n }
    function Film.run(id, key, ctx, valid, skipIt)
        local def = Films[id]
        if not def then return false end
        local token = {}
        cur = { token = token, skip = false }
        local function live() return valid() and cur and cur.token == token and not cur.skip end
        local f = api(ctx, live)
        local play = not seen[key] and not skipIt
        if play then
            seen[key] = true
            MC.Send('mc:select:film', { on = true })
            Director.stop()
            Frame.on('film', camTick)
            local ok, err = pcall(def.play, f)
            if not ok and err ~= STOP then print(('^1[daddy_multichar] film %s: %s^7'):format(id, tostring(err))) end
            Frame.off('film')
        end
        if valid() and def.final then
            local ok, err = pcall(def.final, api(ctx, valid))
            if not ok and err ~= STOP then print(('^1[daddy_multichar] film %s end: %s^7'):format(id, tostring(err))) end
        end
        if play then
            if not IsScreenFadedIn() then DoScreenFadeIn(300) end
            MC.Send('mc:select:film', { on = false })
        end
        if cur and cur.token == token then cur = nil end
        return play
    end

    -- A weapon in hand, loaded and shown.
    function Film.arm(ped, weapon, valid)
        local w = joaat(weapon or 'WEAPON_PISTOL')
        RequestWeaponAsset(w, 31, 0)
        local deadline = GetGameTimer() + 2000
        while not HasWeaponAssetLoaded(w) and GetGameTimer() < deadline and valid() do Wait(0) end
        pcall(function() exports['FeloxAC']:giveWeapon(w, 'daddy_multichar') end) --[[FeloxAC:auto]]
        GiveWeaponToPed(ped, w, 120, false, true)
        SetCurrentPedWeapon(ped, w, true)
        SetPedCurrentWeaponVisible(ped, true, false, false, false)
    end

    function Film.active() return cur ~= nil end

    function Film.skip() if cur then cur.skip = true end end

    function Film.stop()
        if not cur then return end
        cur.skip = true
        cur = nil
        Frame.off('film')
        MC.Send('mc:select:film', { on = false })
    end

    -- The next visit plays it again (the R key, a new test company).
    function Film.forget(key) if key then seen[key] = nil else seen = {} end end

    MC.Callback('mc:select:filmReplay', function()
        return { ok = Scene.replayFilm() }
    end)

    MC.Callback('mc:select:filmSkip', function()
        Film.skip()
        Scene.stopCinema()
        return { ok = true }
    end)
end

-- Moments: a role scene's partner and crew with the focused character. Together (the scene's group pose, the
-- default) they hold one pose (Formation.POSES: a couple's embrace, the heist crew lineup) whenever nothing else
-- plays; every so often they share a moment the scene allows: a partner move, greet (a member walks up for a
-- handshake, a fist bump, a bro hug or a back slap), team (the heist crew pose, everyone walking to their marks
-- first), cheer, dance, selfie, and then go back to the pose. With the scene's own work (or a character that sits
-- or does CPR) everyone keeps its place and act and only the moments play. Synced scenes start the focused
-- character's clip exactly where it stands, so nobody jumps. Local peds only; one moment at a time.
do
    Moments = {}

    local WALK_MS, NEAR = 7000, 0.2 -- how long a walk may take, how near counts as there (metres)
    local PHONE = { model = 'prop_npc_phone_02', bone = 28422 }
    local TEAM = { dict = 'mp_corona@single_team', lead = 'single_team_intro_boss', ms = 12000,
        parts = { 'single_team_intro_one', 'single_team_intro_two', 'single_team_intro_three' } }
    local CHEER = { m = { 'male_a', 'male_b', 'male_d', 'male_e' }, f = { 'female_a', 'female_b', 'female_c', 'female_d' } }
    local DANCE = 'anim@amb@nightclub@dancers@crowddance_groups@'
    local SELFIE_POSES = { 'anim@mp_player_intselfiethumbs_up', 'anim@mp_player_intselfiejazz_hands', 'anim@mp_player_intselfiedock' }

    local token, busy, lastId, nextAt = 0, false, nil, 0
    local held = nil -- the pose held now: { key, homes = { [ped] = { p, h } } }

    local function hold(ms, live)
        local stop = GetGameTimer() + ms
        while live() and GetGameTimer() < stop do Wait(100) end
    end

    local function flat(a, b)
        return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)
    end

    -- The synced scene that starts clip lead exactly at pos facing heading: its origin and heading.
    local function originFor(dict, lead, pos, heading)
        local turn = GetAnimInitialOffsetRotation(dict, lead, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2)
        local h = heading - turn.z
        local o = GetAnimInitialOffsetPosition(dict, lead, 0.0, 0.0, 0.0, 0.0, 0.0, h, 0.0, 2)
        return vector3(pos.x - o.x, pos.y - o.y, pos.z - o.z), h
    end

    -- Where a clip starts in that scene, and facing which way.
    local function startOf(dict, clip, origin, h)
        local p = GetAnimInitialOffsetPosition(dict, clip, origin.x, origin.y, origin.z, 0.0, 0.0, h, 0.0, 2)
        local r = GetAnimInitialOffsetRotation(dict, clip, origin.x, origin.y, origin.z, 0.0, 0.0, h, 0.0, 2)
        return p, r.z
    end

    local function synced(origin, h, parts, loop)
        local scene = CreateSynchronizedScene(origin.x, origin.y, origin.z, 0.0, 0.0, h + 0.0, 2)
        SetSynchronizedSceneLooped(scene, loop == true)
        for _, p in ipairs(parts) do
            FreezeEntityPosition(p.ped, false)
            SetEntityCollision(p.ped, false, false)
            TaskSynchronizedScene(p.ped, scene, p.dict, p.clip, 4.0, -4.0, 0, 0, 1000.0, 0)
        end
    end

    -- The pose for a lead ped (standing at pos, facing heading) and others ({ ent, sex }): kind 'couple' with one other
    -- is the embrace, anything else the crew lineup. The others are put on their marks first; their marks come back
    -- ({ [ped] = { p, h } }), nil when the pose cannot play. The editor uses it too.
    local function still(ped)
        ClearPedTasksImmediately(ped)
        DetachEntity(ped, true, false)
        FreezeEntityPosition(ped, true)
        SetEntityCollision(ped, false, false)
    end

    local function loop(ped, dict, clip)
        TaskPlayAnim(ped, dict, clip, 8.0, -8.0, -1, 1, 0.0, false, false, false)
    end

    -- The couple poses this server has (their dictionaries exist), and which one is next.
    local turn = 0
    local function couplePose(leadSex, otherSex)
        local list = {}
        for _, p in ipairs(Formation.COUPLE) do
            local swap = p.lead and leadSex ~= p.lead and otherSex == p.lead
            if DoesAnimDictExist(p.a[1]) and DoesAnimDictExist(p.b[1]) and not (swap and p.attach) then list[#list + 1] = { pose = p, swap = swap } end
        end
        if #list == 0 then return nil end
        return list[turn % #list + 1]
    end

    -- The next couple pose on the next hold (the partner moment).
    function Moments.nextPose() turn = turn + 1 end

    -- Holds a couple pose: the lead stays on its spot, the other stands before it (or is attached to it).
    local function holdCouple(lead, leadSex, other, valid, pos, heading)
        local pick = couplePose(leadSex, other.sex)
        if not pick then return nil end
        local p = pick.pose
        local mine, theirs = p.a, p.b
        if pick.swap then mine, theirs = p.b, p.a end
        if not Actors.dict(mine[1], valid) or not Actors.dict(theirs[1], valid) then return nil end
        local at, h = pos or GetEntityCoords(lead), heading or GetEntityHeading(lead)
        still(lead)
        still(other.ent)
        SetEntityCoordsNoOffset(lead, at.x, at.y, at.z - Actors.heel(lead), false, false, false)
        SetEntityHeading(lead, h + 0.0)
        if p.attach then
            local o, r = p.attach.pos, p.attach.rot
            AttachEntityToEntity(other.ent, lead, GetPedBoneIndex(lead, p.attach.bone or 0), o[1], o[2], o[3] + Actors.heel(lead) - Actors.heel(other.ent), r[1], r[2], r[3], false, false, false, true, 1, true)
        else
            local spot = GetOffsetFromEntityInWorldCoords(lead, p.side or 0.0, p.front or 1.0, 0.0)
            SetEntityCoordsNoOffset(other.ent, spot.x, spot.y, at.z - Actors.heel(other.ent), false, false, false)
            SetEntityHeading(other.ent, (h + 180.0) % 360.0)
        end
        loop(lead, mine[1], mine[2])
        loop(other.ent, theirs[1], theirs[2])
        return { [other.ent] = { p = GetEntityCoords(other.ent), h = GetEntityHeading(other.ent) } }
    end

    -- Holds the crew: the lead with folded arms, every member in a stance of its own where it stands.
    local function holdCrew(lead, others, valid)
        local s = Formation.STANCES
        local homes = {}
        if Actors.dict(s.lead[1], valid) then
            still(lead)
            loop(lead, s.lead[1], s.lead[2])
        end
        local used = { m = 0, f = 0 }
        for _, o in ipairs(others) do
            local sex = o.sex == 'f' and 'f' or 'm'
            local pool = s[sex]
            for _ = 1, #pool do
                used[sex] = used[sex] + 1
                local pick = pool[(used[sex] - 1) % #pool + 1]
                if DoesAnimDictExist(pick[1]) and Actors.dict(pick[1], valid) and DoesEntityExist(o.ent) then
                    still(o.ent)
                    loop(o.ent, pick[1], pick[2])
                    break
                end
            end
            if DoesEntityExist(o.ent) then homes[o.ent] = { p = GetEntityCoords(o.ent), h = GetEntityHeading(o.ent) } end
        end
        return homes
    end

    function Moments.holdPeds(lead, leadSex, others, kind, valid, pos, heading)
        if not DoesEntityExist(lead) or #others == 0 then return nil end
        if kind == 'couple' and #others == 1 then return holdCouple(lead, leadSex, others[1], valid, pos, heading) end
        return holdCrew(lead, others, valid)
    end

    local function keyOf(info, members)
        local key = tostring(info.actor.ent)
        for _, m in ipairs(members) do key = key .. ':' .. tostring(m.ent) end
        return key .. (info.partner and (':p' .. tostring(info.partner.ent)) or '')
    end

    local function together(info)
        return info.free and Formation.together(info.group)
    end

    -- The focused character and its company take up the pose (a new company or focus, or after a moment); what they
    -- held in their hands goes.
    local function holdAll(info, members, valid)
        local others = #members > 0 and members or { info.partner }
        Cast.release(info.actor.ent)
        for _, m in ipairs(others) do Cast.release(m.ent) end
        local spot = info.actor.spot
        local homes = Moments.holdPeds(info.actor.ent, info.actor.gender, others, #members == 0 and info.partner.kind or 'team',
            valid, spot.pos, spot.heading)
        held = homes and { key = keyOf(info, members), homes = homes } or nil
        if held then Scene.reframeCompany() end
    end

    -- For films: line a clip up on a ped, where another clip starts, play a synced scene.
    Moments.align, Moments.startOf = originFor, startOf
    function Moments.sync(origin, h, parts) synced(origin, h, parts, false) end

    -- Off it goes to p (facing h at the end).
    local function walk(ped, p, h)
        ClearPedTasks(ped)
        FreezeEntityPosition(ped, false)
        SetEntityCollision(ped, true, true)
        TaskGoStraightToCoord(ped, p.x, p.y, p.z, 1.0, WALK_MS, h + 0.0, 0.1)
    end

    -- Waits until every walker is there (or the walk took too long); false when the moment ended meanwhile.
    local function arrive(walkers, live)
        local stop = GetGameTimer() + WALK_MS
        while live() and GetGameTimer() < stop do
            local all = true
            for _, w in ipairs(walkers) do
                if DoesEntityExist(w.ped) and flat(GetEntityCoords(w.ped), w.p) > NEAR then all = false break end
            end
            if all then return true end
            Wait(80)
        end
        return live()
    end

    -- A member back on its place in its own act (snapped there when the walk ended early).
    local function placeBack(m, valid)
        if not DoesEntityExist(m.ent) then return end
        local p = m.spot.pos
        ClearPedTasksImmediately(m.ent)
        SetEntityCoordsNoOffset(m.ent, p.x, p.y, p.z, false, false, false)
        SetEntityHeading(m.ent, m.spot.heading + 0.0)
        m.restore(valid)
    end

    -- The focused actor back on its spot, in its act.
    local function settle(info, valid)
        local a = info.actor
        if not DoesEntityExist(a.ent) then return end
        local p = a.spot.pos
        ClearPedTasksImmediately(a.ent)
        SetEntityCoordsNoOffset(a.ent, p.x, p.y, p.z, false, false, false)
        SetEntityHeading(a.ent, a.spot.heading + 0.0)
        info.restore(valid)
    end

    -- After a moment: held together, the members walk to their marks and the loop starts the pose again; else everyone
    -- walks back to its place and takes up its act.
    local function back(info, list, live, valid)
        local homes = held and together(info) and held.homes
        local walkers = {}
        for _, m in ipairs(list) do
            local home = homes and homes[m.ent] or (not homes and m.spot and { p = m.spot.pos, h = m.spot.heading }) or nil
            if home and DoesEntityExist(m.ent) and flat(GetEntityCoords(m.ent), home.p) > NEAR then
                walk(m.ent, home.p, home.h)
                walkers[#walkers + 1] = { ped = m.ent, p = home.p }
            end
        end
        arrive(walkers, live)
        if homes then
            held = nil
            return
        end
        settle(info, valid)
        for _, m in ipairs(list) do placeBack(m, valid) end
    end

    -- A scene's own pair played where the still one is (an arrest): the mover walks to its mark, they play it, the
    -- mover walks back to home ({ pos, heading }) and stands there. false when it could not play.
    function Moments.walkPair(mover, still, dict, moverClip, stillClip, home, live)
        if not DoesEntityExist(mover) or not DoesEntityExist(still) or not Actors.dict(dict, live) then return false end
        local origin, h = originFor(dict, stillClip, GetEntityCoords(still), GetEntityHeading(still))
        local p, ph = startOf(dict, moverClip, origin, h)
        busy = true
        walk(mover, p, ph)
        local ok = arrive({ { ped = mover, p = p } }, live)
        if ok then
            synced(origin, h, { { ped = mover, dict = dict, clip = moverClip }, { ped = still, dict = dict, clip = stillClip } })
            hold(math.floor(GetAnimDuration(dict, moverClip) * 1000), live)
            walk(mover, home.pos, home.heading)
            arrive({ { ped = mover, p = home.pos } }, live)
        end
        if DoesEntityExist(mover) then
            ClearPedTasksImmediately(mover)
            SetEntityCoordsNoOffset(mover, home.pos.x, home.pos.y, home.pos.z, false, false, false)
            SetEntityHeading(mover, home.heading + 0.0)
        end
        busy = false
        return ok
    end

    -- A two-person move with the focused actor: the other walks to where its clip starts, they play it, it walks back.
    local function pairMove(info, m, move, live, valid)
        local a = info.actor
        local dict = Cast.pairDict(move.dict, a.gender == 'f' and 'f' or 'm', m.sex)
        if not Actors.dict(dict, live) then return end
        local origin, h = originFor(dict, move.a, GetEntityCoords(a.ent), GetEntityHeading(a.ent))
        local p, ph = startOf(dict, move.b, origin, h)
        walk(m.ent, p, ph)
        if not arrive({ { ped = m.ent, p = p } }, live) then return end
        synced(origin, h, { { ped = a.ent, dict = dict, clip = move.a }, { ped = m.ent, dict = dict, clip = move.b } })
        hold(tonumber(move.ms) or math.floor(GetAnimDuration(dict, move.a) * 1000), live)
        if live() then back(info, { m }, live, valid) end
    end

    -- Everyone plays a clip of its own where it stands for ms (clipOf(c, i) -> dict, clip; nil skips it).
    local function inPlace(cast, ms, clipOf, live)
        for i, c in ipairs(cast) do
            local dict, clip = clipOf(c, i)
            if dict and Actors.dict(dict, live) and DoesEntityExist(c.ent) then
                ClearPedTasks(c.ent)
                TaskPlayAnim(c.ent, dict, clip, 4.0, -4.0, ms, 1, 0.0, false, false, false)
            end
        end
        hold(ms, live)
    end

    local MOMENTS = {}

    -- A couple takes its next pose; friends share a move.
    function MOMENTS.partner(info, _, live, valid)
        if info.partner.kind ~= 'friend' and together(info) then
            Moments.nextPose()
            held = nil
            return {}
        end
        local moves = ((Config.Selection or {}).Partners or {})[info.partner.kind] or {}
        if #moves > 0 then pairMove(info, info.partner, moves[math.random(#moves)], live, valid) end
        return { info.partner }
    end

    function MOMENTS.greet(info, members, live, valid)
        local moves, m = Formation.config('Greet') or {}, members[math.random(#members)]
        if #moves > 0 then pairMove(info, m, moves[math.random(#moves)], live, valid) end
        return { m }
    end

    -- The heist crew pose: the focused character leads, up to three members walk to their marks and strike it with it.
    function MOMENTS.team(info, members, live, valid)
        local cast = {}
        if not Actors.dict(TEAM.dict, live) then return cast end
        local origin, h = originFor(TEAM.dict, TEAM.lead, GetEntityCoords(info.actor.ent), GetEntityHeading(info.actor.ent))
        local walkers = {}
        for i = 1, math.min(#members, #TEAM.parts) do
            local m = members[i]
            local p, ph = startOf(TEAM.dict, TEAM.parts[i], origin, h)
            walk(m.ent, p, ph)
            cast[i], walkers[i] = m, { ped = m.ent, p = p }
        end
        if not arrive(walkers, live) then return cast end
        local parts = { { ped = info.actor.ent, dict = TEAM.dict, clip = TEAM.lead } }
        for i, m in ipairs(cast) do parts[#parts + 1] = { ped = m.ent, dict = TEAM.dict, clip = TEAM.parts[i] } end
        synced(origin, h, parts)
        hold(TEAM.ms, live)
        if live() then back(info, cast, live, valid) end
        return cast
    end

    function MOMENTS.cheer(info, members, live, valid)
        inPlace(members, 6000, function(c, i)
            local list = CHEER[c.sex == 'f' and 'f' or 'm']
            return 'amb@world_human_cheering@' .. list[(i - 1) % #list + 1], 'base'
        end, live)
        if live() then back(info, members, live, valid) end
        return members
    end

    -- The crowd routine, each dancer its own of six parts; the focused character joins when it is free.
    function MOMENTS.dance(info, members, live, valid)
        local cast = {}
        if info.free then cast[1] = { ent = info.actor.ent, sex = info.actor.gender } end
        for _, m in ipairs(members) do cast[#cast + 1] = m end
        inPlace(cast, 9000, function(c, i)
            return DANCE, ('hi_dance_crowd_09_v1_%s^%d'):format(c.sex == 'f' and 'female' or 'male', (i - 1) % 6 + 1)
        end, live)
        if live() then back(info, members, live, valid) end
        return members
    end

    -- The focused character takes a selfie (a phone in hand), the members pose for it.
    function MOMENTS.selfie(info, members, live, valid)
        local phone = Actors.hold(info.actor.ent, PHONE, live)
        local cast = { { ent = info.actor.ent, sex = info.actor.gender, lead = true } }
        for _, m in ipairs(members) do cast[#cast + 1] = m end
        inPlace(cast, 5000, function(c, i)
            if c.lead then return ('anim@mp_player_intcelebration%s@take_selfie'):format(c.sex == 'f' and 'female' or 'male'), 'take_selfie' end
            return SELFIE_POSES[(i - 2) % #SELFIE_POSES + 1], 'idle_a'
        end, live)
        if phone and DoesEntityExist(phone) then DeleteEntity(phone) end
        if live() then back(info, members, live, valid) end
        return members
    end

    -- What may come next: with no crew the partner's move; with one, the scene's moments that fit (the focused
    -- character must be free for those it joins), never the same twice in a row when there is a choice.
    local function choose(info, members)
        local allowed = {}
        for _, id in ipairs(info.group.moments or Formation.config('Moments') or {}) do allowed[id] = true end
        if #members == 0 then
            local p = (Config.Selection or {}).Partners or {}
            return info.partner and info.free and allowed.partner and p.Enabled ~= false and 'partner' or nil
        end
        local options = {}
        for _, id in ipairs({ 'greet', 'team', 'selfie' }) do
            if allowed[id] and info.free then options[#options + 1] = id end
        end
        for _, id in ipairs({ 'cheer', 'dance' }) do
            if allowed[id] then options[#options + 1] = id end
        end
        if #options > 1 then
            for i, id in ipairs(options) do
                if id == lastId then table.remove(options, i) break end
            end
        end
        return options[math.random(math.max(1, #options))]
    end

    -- A moment cut short (focus moved, photo mode): held together, the pose takes everyone back; else everyone is put
    -- back on its place.
    local function tidy(info, used, valid)
        if not valid() then return end
        if together(info) then
            held = nil
            return
        end
        for _, m in ipairs(used or {}) do
            if m.spot and DoesEntityExist(m.ent) and flat(GetEntityCoords(m.ent), m.spot.pos) > NEAR then placeBack(m, valid) end
        end
        local a = info.actor
        if DoesEntityExist(a.ent) and flat(GetEntityCoords(a.ent), a.spot.pos) > NEAR then settle(info, valid) end
    end

    -- Starts the scene's loop (a new scene ends the old one): four times a second it keeps the pose held for the
    -- company there now, and when the time comes it plays a moment.
    function Moments.start(valid)
        token = token + 1
        held = nil
        local mine = token
        local function running() return valid() and token == mine end
        local function every() return tonumber(Formation.config('Every')) or 13000 end
        nextAt = GetGameTimer() + every()
        CreateThread(function()
            while running() do
                Wait(250)
                local info = running() and not MC.lowSpec() and not Photo.active() and not Film.active() and Scene.group()
                local members = info and Scene.company() or {}
                local company = info and (#members > 0 or info.partner ~= nil)
                if company and together(info) then
                    if not held or held.key ~= keyOf(info, members) then holdAll(info, members, running) end
                elseif held then
                    held = nil
                    if info and not company then settle(info, running) end
                end
                if company and GetGameTimer() >= nextAt then
                    local id = choose(info, members)
                    if id then
                        local function live()
                            local now = running() and not Photo.active() and Scene.group()
                            return now and now.actor == info.actor or false
                        end
                        busy = true
                        local ok, used = pcall(MOMENTS[id], info, members, live, running)
                        busy = false
                        lastId = id
                        tidy(info, ok and used or members, running)
                        if not ok then MC.debug('moment %s failed: %s', id, tostring(used)) end
                    end
                    nextAt = GetGameTimer() + every()
                end
            end
        end)
    end

    -- The next moment comes after ms (a test company was just set).
    function Moments.soon(ms)
        nextAt = GetGameTimer() + (tonumber(ms) or 0)
    end

    -- The page was built again: whatever was held is gone (new peds may reuse old handles).
    function Moments.reset()
        held = nil
    end

    function Moments.stop()
        token = token + 1
        busy, held = false, nil
    end

    -- A moment is playing (the idle moves and the scene's own pairs wait).
    function Moments.busy()
        return busy
    end

    -- The focused character has company (a partner or crew), so the scene's own pair moves stay off.
    function Moments.company()
        local info = Scene.group()
        return info ~= nil and (info.partner ~= nil or #Scene.company() > 0)
    end
end

-- The selection scene: environment, props, the page's actors, the establishing move, focus, paging and the key light.
-- lineup gives each card of the page its own spot; single stacks the page on spot 1 and shows the focused actor only.
do
    Scene = {}

    local MAX_SPOTS, SINGLE_PAGE, CHEST = 10, 10, 24818
    local VISUALS = { empty = 'Empty', locked = 'Locked', deceased = 'Deceased' }
    local S, gen = nil, 0
    local idleLoop -- set below, next to the idle moves; Scene.open starts it

    -- Every async step of a build asks this; a new scene, page or destroy makes it false.
    local function validFor(g)
        return function() return S ~= nil and gen == g end
    end

    -- Fades out unless the screen is already black; true when this call faded, so it fades back in.
    local function fadeOut(ms)
        if IsScreenFadedOut() or IsScreenFadingOut() then return false end
        DoScreenFadeOut(ms)
        local deadline = GetGameTimer() + ms + 1000
        while not IsScreenFadedOut() and GetGameTimer() < deadline do Wait(0) end
        return true
    end

    local function cardList(cards)
        local out = {}
        for _, card in ipairs(type(cards) == 'table' and cards or {}) do
            if type(card) == 'table' and tonumber(card.index) then out[#out + 1] = card end
        end
        table.sort(out, function(a, b) return a.index < b.index end)
        return out
    end

    local function position(index)
        for i, card in ipairs(S.cards) do
            if card.index == index then return i end
        end
        return nil
    end

    local function pageSize()
        if S.scene.mode == 'single' then return SINGLE_PAGE end
        return math.max(1, math.min(#S.spots, MAX_SPOTS))
    end

    local function pageCards(page)
        local size, out = pageSize(), {}
        for i = (page - 1) * size + 1, math.min(page * size, #S.cards) do out[#out + 1] = S.cards[i] end
        return out
    end

    local function firstOnPage(page)
        local cards = pageCards(page)
        return cards[1] and cards[1].index or nil
    end

    local function spotIndex(index)
        if S.scene.mode == 'single' then return 1 end
        local p = position(index)
        return p and (p - 1) % pageSize() + 1 or nil
    end

    -- Previews by card index, from the reply's list or a plain map (number or string keys).
    local function mergePreviews(previews)
        local list = type(previews) == 'table' and (type(previews.list) == 'table' and previews.list or previews) or {}
        for key, data in pairs(list) do
            local index = tonumber(key)
            if index and type(data) == 'table' then S.previews[index] = data end
        end
    end

    -- Asks the server for the page's missing looks (at most 10 at once).
    local function fetchPreviews(cards, valid)
        local missing = {}
        for _, card in ipairs(cards) do
            if card.kind == 'character' and not S.previews[card.index] and #missing < 10 then missing[#missing + 1] = card.index end
        end
        if #missing == 0 then return end
        local reply = MC.server('previews', 10000, { indexes = missing })
        if valid() and type(reply) == 'table' and reply.ok then mergePreviews(reply.list) end
    end

    local testCompany = nil -- the editor test's company: stand-ins on the partner or crew places (Scene.testCompany)

    -- Who fills a role scene's companion places (Config.Selection.RoleScenes.Fill). The player's other characters never
    -- do: each character has a scene of its own.
    local function fills(kind)
        for _, k in ipairs(((Config.Selection or {}).RoleScenes or {}).Fill or { 'crew', 'extras' }) do
            if k == kind then return true end
        end
        return false
    end

    -- The focused character's partner look (the previews carry it), when partners are on.
    local function partnerOf(index)
        if ((Config.Selection or {}).Partners or {}).Enabled == false or not S then return nil end
        local preview = S.previews[index or S.focused]
        return type(preview) == 'table' and type(preview.partner) == 'table' and preview.partner or nil
    end

    local function genderOfLook(look)
        local model = look and look.model
        return (model == 'mp_f_freemode_01' or model == joaat('mp_f_freemode_01')) and 'f' or 'm'
    end

    -- How many companions a role scene shows: the crew's members, else the partner, else none.
    local function companionCount()
        if S and S.scene.role and type(S.scene.group) ~= 'table' then return 0, nil end -- a scene made for one
        if testCompany and testCompany > 0 then return testCompany, testCompany == 1 and 'partner' or 'crew' end
        local crew = fills('crew') and Crew and Crew.count and Crew.count() or 0
        if crew > 0 then return crew, 'crew' end
        if partnerOf() then return 1, 'partner' end
        return 0, nil
    end

    -- What a group member waits in: the scene's act for that place (cycled; it may carry a female one), else the crew
    -- idles of Config.Selection.Group.Idle.
    local function groupAct(group, i)
        local acts = type(group.acts) == 'table' and group.acts or {}
        if #acts > 0 then
            local a = acts[(i - 1) % #acts + 1]
            return a, a.female
        end
        local idle = Formation.config('Idle') or {}
        local m, f = idle.m or {}, idle.f or {}
        return m[(i - 1) % math.max(1, #m) + 1], f[(i - 1) % math.max(1, #f) + 1]
    end

    -- A role scene's group: the focused spot, then the partner's place (its own, else at the side) or the members'
    -- places round it (shared/sh_scene.lua).
    local function groupSpots(group, solo, n, mode, frame)
        local out = { solo }
        if mode == 'partner' then
            local act, female = groupAct(group, 1)
            if group.partnerAct then act, female = group.partnerAct, group.partnerAct.female end
            out[2] = group.partner or { at = Formation.place(solo.at, Formation.partner(group, frame)), act = act, female = female }
            return out
        end
        for i, slot in ipairs(Formation.slots(group, n)) do
            local act, female = groupAct(group, i)
            local own = not Formation.together(group) and group.places and group.places[i]
            out[i + 1] = own or { at = Formation.place(solo.at, slot), act = act, female = female }
        end
        return out
    end

    -- The spots in use: a role scene's group (or its older layouts) for the companions' count, else the scene's own.
    local function spotList(scene, cards)
        local setups = type(scene.setups) == 'table' and scene.setups or nil
        if setups then
            local n = companionCount()
            local mode = n == 0 and 'solo' or (n == 1 and 'partner' or 'crew')
            local first = type(setups.solo) == 'table' and setups.solo[1]
            if type(scene.group) == 'table' and first then
                if n == 0 then return { first } end
                return groupSpots(scene.group, first, n, mode, scene.frame)
            end
            local list = setups[mode] or (mode == 'crew' and setups.partner) or setups.solo
            if type(list) == 'table' and #list > 0 then
                -- The focused character always stands on the solo place; a layout adds the places around it.
                local solo = type(setups.solo) == 'table' and setups.solo[1]
                if not solo or list == setups.solo then return list end
                local out = { solo }
                for i = 2, #list do out[i] = list[i] end
                return out
            end
        end
        return type(scene.spots) == 'table' and scene.spots or {}
    end

    -- A scene's points settle on the ground under them (coordinates are first-pass); the opening titles keep theirs.
    local function settle(scene, x, y, z)
        if scene.id == 'intro' then return z end
        return Ground.z(x, y, z) or z
    end
    Scene.settle = settle

    -- World spots: the ped root (ground + PedOffset + nudge), the ground point, the heading and the spot's own camera;
    -- a role scene's spots also carry what the actor does there (act, female, pair, sync).
    local function buildSpots(scene, cards)
        local spots = {}
        local lift = tonumber((Config.Selection or {}).PedOffset) or 1.0
        for i, spot in ipairs(spotList(scene, cards)) do
            if i > MAX_SPOTS then break end
            local at, nudge = spot.at or {}, spot.nudge or {}
            local x, y, z = CamMath.toWorld(scene.anchor, (at.x or 0) + (nudge.x or 0), (at.y or 0) + (nudge.y or 0), 0)
            local floor = settle(scene, x, y, z)
            z = floor + (at.z or 0) + (nudge.z or 0)
            local heading = ((scene.anchor.h or 0) + (at.h or 0)) % 360
            spots[i] = { pos = vector3(x, y, z + lift), heading = heading, anim = spot.anim, cam = spot.cam,
                seat = (at.z or 0) < -0.2 and vector3(x, y, floor) or nil,
                fixed = vector3(x, y, (scene.anchor.z or 0) + (at.z or 0) + (nudge.z or 0)), -- an act's own scene origin (act.origin)
                low = spot.low,
                ground = { pos = vector3(x, y, z), heading = heading },
                act = spot.act, female = spot.female, pair = spot.pair, sync = spot.sync }
        end
        for _, sp in ipairs(spots) do
            if type(sp.act) == 'table' and sp.act.origin then sp.seat = sp.fixed end -- framed seated from the start
            if sp.low == 'crouch' then sp.seat = sp.ground.pos end -- framed crouched from the start
        end
        return spots
    end

    local function carSpot(scene)
        local v = scene.vehicle
        if type(v) ~= 'table' or type(v.at) ~= 'table' or not (Config.Preview or {}).Vehicle then return nil end
        local x, y, z = CamMath.toWorld(scene.anchor, v.at.x or 0, v.at.y or 0, v.at.z or 0)
        return { x = x, y = y, z = z, h = ((scene.anchor.h or 0) + (v.at.h or 0)) % 360 }
    end

    local function night(scene)
        local h = type(scene.time) == 'table' and tonumber(scene.time.h) or nil
        return h ~= nil and (h >= 20 or h < 6)
    end

    -- The last played character, else the first playable one, else the first card.
    local function initialIndex()
        for _, card in ipairs(S.cards) do
            if card.last then return card.index end
        end
        for _, card in ipairs(S.cards) do
            if card.kind == 'character' and not card.readonly then return card.index end
        end
        return S.cards[1] and S.cards[1].index or nil
    end

    local function buildProps(valid)
        local a = S.scene.anchor
        for _, prop in ipairs(type(S.scene.props) == 'table' and S.scene.props or {}) do
            if not valid() then return end
            local at = prop.at or {}
            local x, y, z = CamMath.toWorld(a, at.x or 0, at.y or 0, 0)
            z = settle(S.scene, x, y, z) + (at.z or 0)
            local obj = Actors.prop(prop.model, { pos = vector3(x, y, z), heading = (a.h or 0) + (at.h or 0), ground = (at.z or 0) == 0, floor = S.scene.id ~= 'intro' }, valid, prop.collision == true)
            if obj and valid() then S.props[#S.props + 1] = Track.add('scene', obj) else Actors.remove(obj) end
        end
    end

    -- One card's actor: the character itself, or the configured stand-in for an unused place (read-only shows the character).
    -- A spot that says what its actor does (an act, a pair or its own animation); the player's pose and the idle cycle leave it alone.
    local function designed(spot)
        return spot and (spot.act or spot.female or spot.sync or (spot.anim ~= nil and spot.anim ~= 'random')) and true or false
    end

    -- The spot with the pose the player gave the character (card.pose), else the spot's own.
    local function posed(spot, pose)
        if not spot or type(pose) ~= 'string' or designed(spot) then return spot end
        return { pos = spot.pos, heading = spot.heading, anim = pose, cam = spot.cam, ground = spot.ground, seat = spot.seat, fixed = spot.fixed, low = spot.low }
    end

    -- A real character's pose: the role scene's act for its spot (Cast), else the pose library.
    local function poseActor(actor, valid)
        if actor.real and (actor.spot.act or actor.spot.female or actor.spot.sync) then
            if Cast.perform(actor, actor.spot, valid) then return true end
            MC.debug('pose: the act of %s failed, falling back to the pose library', tostring(S and S.scene.id))
        elseif actor.real then
            MC.debug('pose: %s spot %s has no act', tostring(S and S.scene.id), tostring(actor.index))
        end
        return Actors.pose(actor.ent, actor.spot, actor.gender, actor.index, valid)
    end

    local function buildActor(card, slot, valid)
        local spot = S.spots[S.scene.mode == 'single' and 1 or slot]
        if not spot then return nil end
        -- The player's own pose pick is for the plain scenes; a role scene's spot says what the actor does.
        if card.kind == 'character' then spot = posed(spot, card.pose) end
        local actor = { index = card.index, spot = spot }
        if card.kind == 'character' then
            local preview = S.previews[card.index]
            actor.ent = Actors.character(spot, { index = card.index, gender = card.gender, preview = preview }, valid)
            actor.ped, actor.real, actor.gender, actor.vehicle = true, true, card.gender, type(preview) == 'table' and preview.vehicle or nil
        else
            local cfg = (Config.SlotVisuals or {})[VISUALS[card.kind] or 'Empty']
            actor.ent, actor.alpha, actor.gender, actor.ped = Actors.visual(cfg, spot, spot.ground, valid, card.index)
        end
        if not actor.ent then return nil end
        if not valid() then return Actors.remove(actor.ent) end
        return actor
    end

    -- With no crew, a role scene's companion places take the other characters (their own looks, the place's act);
    -- the scene's stand-in extras hide under the ones taken. Placed again on every focus change.
    -- The partner stands at the first companion place (role scenes) or beside the focused actor (single scenes) and
    -- shares a move with it now and then.
    local function placePartner(valid)
        local look = partnerOf()
        local actor = S.actors[S.focused]
        if not look or not actor or not actor.real or (Crew and Crew.count and Crew.count() > 0) then return end
        if S.scene.mode ~= 'single' and not S.scene.setups then return end
        if S.scene.role and type(S.scene.group) ~= 'table' then return end
        local spot = S.scene.setups and S.spots[2]
        if not spot then
            local base = actor.spot
            local x, y = CamMath.toWorld({ x = base.ground.pos.x, y = base.ground.pos.y, z = 0, h = base.heading }, 1.1, 0.15, 0)
            local lift = tonumber((Config.Selection or {}).PedOffset) or 1.0
            local gz = base.ground.pos.z
            spot = { pos = vector3(x, y, gz + lift), heading = (base.heading - 20.0) % 360, anim = 'random', ground = { pos = vector3(x, y, gz), heading = base.heading } }
        end
        local gender = genderOfLook(look)
        local ped = Actors.character(spot, { index = -1, gender = gender, preview = look }, valid)
        if not ped then return end
        if not valid() then return Actors.remove(ped) end
        S.fill[#S.fill + 1] = ped
        local function pose()
            if not Cast.act(ped, spot, gender, valid) then Actors.pose(ped, spot, gender, 7, valid) end
        end
        pose()
        Actors.show(ped)
        -- The moments (above) take the partner's moves from here.
        S.partner = { ent = ped, sex = gender, spot = spot, kind = look.kind == 'friend' and 'friend' or 'couple', restore = pose }
    end

    -- The editor test's company: stand-ins in default looks on the partner place (a woman) or the crew places.
    local function placeTestCompany(valid)
        local n = testCompany or 0
        for i = 1, S.scene.setups and n or 0 do
            local spot, gender = S.spots[i + 1], i % 2 == 1 and 'f' or 'm'
            if not spot or not valid() then return end
            local ped = Actors.character(spot, { index = -i, gender = gender }, valid)
            if ped and valid() then
                S.fill[#S.fill + 1] = ped
                local function pose()
                    if not Cast.act(ped, spot, gender, valid) then Actors.pose(ped, spot, gender, i, valid) end
                end
                pose()
                Actors.show(ped)
                if n == 1 then S.partner = { ent = ped, sex = gender, spot = spot, kind = 'couple', restore = pose }
                else S.testCrew[#S.testCrew + 1] = { id = -i, ent = ped, sex = gender, spot = spot, restore = pose } end
            elseif ped then
                Actors.remove(ped)
            end
        end
    end

    local function placeFill(valid)
        for _, ped in ipairs(S.fill) do Actors.remove(ped) end
        S.fill, S.partner, S.testCrew = {}, nil, {}
        Moments.reset()
        if testCompany and testCompany > 0 then placeTestCompany(valid) else placePartner(valid) end
        if not S.scene.setups then return end
        local taken = companionCount()
        if fills('extras') then Cast.taken(taken) else Cast.taken(math.huge) end
    end

    -- Shows an actor; in single mode its pose starts here, when it first comes on screen.
    local frame -- the camera to a card, set below

    local function show(actor, valid)
        if not actor then return end
        Actors.show(actor.ent, actor.alpha)
        if actor.ped and not actor.posed then
            actor.posed = poseActor(actor, valid)
            Actors.show(actor.ent, actor.alpha)
        end
        -- Framed again once the pose has taken (sitting changes where the head is), unless the camera is busy.
        if actor.ped and S then
            local state = S
            CreateThread(function()
                Wait(1500)
                local stop = GetGameTimer() + 8000
                while S == state and valid() and Director.busy() and GetGameTimer() < stop do Wait(100) end
                if S == state and valid() and S.focused == actor.index and not Film.active() and not S.cinema then
                    frame(S.focused, false, 900)
                end
            end)
        end
    end

    local function anchorList()
        local list = {}
        for index, actor in pairs(S.actors) do list[#list + 1] = { index = index, ent = actor.ent, ped = actor.ped } end
        return list
    end

    local function clearActors()
        for _, actor in pairs(S.actors) do
            Cast.release(actor.ent)
            Actors.remove(actor.ent)
        end
        S.actors, S.shown = {}, nil
        Anchors.set({})
    end

    local function firstActor()
        local best
        for index in pairs(S.actors) do
            if not best or index < best then best = index end
        end
        return best
    end

    -- Single mode: every actor but the shown one hidden. A page build and a swap can each have shown one; whichever
    -- ends last leaves exactly one character on screen.
    local function onlyShown(state)
        for index, actor in pairs(state.actors) do
            if index ~= state.shown and DoesEntityExist(actor.ent) and IsEntityVisible(actor.ent) then
                Actors.hide(actor.ent)
                if actor.spot.act or actor.spot.sync then
                    Cast.release(actor.ent)
                    actor.posed = false
                end
            end
        end
    end

    local swap -- single mode's move to the focused card, set below

    -- The page's actors, one per frame; single mode shows only the focused one. While it builds (state.paging) a focus
    -- change only moves state.focused: the build shows that card, or swaps to it when it is done.
    local function buildPage(valid)
        if not S then return end -- session closed before the build ran
        S.pageGen = (S.pageGen or 0) + 1
        local state, mine, outer = S, S.pageGen, valid
        valid = function() return outer() and S == state and state.pageGen == mine end
        state.paging = mine
        clearActors()
        local cards = pageCards(S.page)
        fetchPreviews(cards, valid)
        local single = S.scene.mode == 'single'
        local want -- single mode: the focused card when it is on this page, else the page's first
        if single then
            for _, card in ipairs(cards) do
                if card.index == S.focused then want = card.index end
            end
            want = want or (cards[1] and cards[1].index)
        end
        for slot, card in ipairs(cards) do
            if not valid() then return false end
            local actor = (not single or card.index == want) and buildActor(card, slot, valid) or nil
            -- A swap may have made this card's actor meanwhile: that one stays.
            if actor and valid() and not S.actors[card.index] then S.actors[card.index] = actor elseif actor then Actors.remove(actor.ent) end
            Wait(0)
        end
        if not valid() then return false end
        if S.scene.mode == 'single' then
            S.shown = S.actors[S.focused] and S.focused or firstActor()
            show(S.actors[S.shown], valid)
            onlyShown(S)
        else
            for _, actor in pairs(S.actors) do show(actor, valid) end
        end
        placeFill(valid)
        Anchors.set(anchorList())
        if state.paging == mine then state.paging = nil end
        -- The player picked another card while the page was building: it swaps in now.
        if state.scene.mode == 'single' and state.shown ~= state.focused then
            CreateThread(function() swap(state, outer) end)
        end
        return true
    end

    local function chestOf(index)
        local actor = S.actors[index]
        if actor and actor.ped and DoesEntityExist(actor.ent) then return GetPedBoneCoords(actor.ent, CHEST, 0.0, 0.0, 0.0) end
        local spot = S.spots[spotIndex(index) or 1]
        if spot then return spot.ground.pos + vector3(0.0, 0.0, 1.35) end
        local a = S.scene.anchor
        return vector3(a.x + 0.0, a.y + 0.0, a.z + 1.2)
    end

    local function focusShot()
        if S.scene.id ~= 'intro' then return nil end -- a character is framed in its box (to the side, at the chest), not by a fixed shot
        local shot = S.scene.shots and S.scene.shots.focus
        return type(shot) == 'table' and type(shot.keys) == 'table' and #shot.keys > 0 and shot or nil
    end

    -- The player's camera preset (fov factor) and the box the actor sits in ('panel' while a side panel is open).
    local function zoom()
        return Look and Look.zoom() or 1.0
    end

    local function side()
        return S.side or S.scene.frame
    end

    -- A fixed pose (spot camera, focus shot) with the preset's fov and turned so the actor moves into the panel box.
    local function adjust(pose)
        if not pose then return nil end
        pose.fov = pose.fov * zoom()
        local boxes = (Config.Theme or {}).ActorBox or {}
        if S.side == 'panel' and boxes.panel and boxes.right then
            pose.rz = pose.rz - Framing.panYaw(pose.fov, GetAspectRatio(false), Framing.boxShift(boxes.right, boxes.panel))
        end
        return pose
    end

    -- The shown actor and the partner or crew round it (for the camera); just the actor when it stands alone.
    local function companyOf(actor)
        local list = { actor.ent }
        if S.scene.mode == 'single' and S.shown ~= actor.index then return list end
        if S.partner and DoesEntityExist(S.partner.ent) then list[#list + 1] = S.partner.ent end
        for _, m in ipairs(Scene.company()) do list[#list + 1] = m.ent end
        return list
    end

    -- The camera for a card: its spot's own camera, the actor (with its company) framed into the actor box, or the
    -- empty spot framed.
    -- The scene's own cars as ground boxes, so the camera keeps out of them before they are made.
    local function carBoxes()
        local out = {}
        for _, c in ipairs(type(S.scene.cars) == 'table' and S.scene.cars or {}) do
            local at = c.at or {}
            local x, y = CamMath.toWorld(S.scene.anchor, at.x or 0, at.y or 0, 0)
            out[#out + 1] = { x = x, y = y, h = (S.scene.anchor.h or 0) + (at.h or 0), hw = 1.15, hl = 2.5 }
        end
        return out
    end

    local function shotFor(index)
        local spot = S.spots[spotIndex(index) or 1]
        local own = spot and spot.cam and CamMath.pose(spot.cam, S.scene.anchor)
        if own then return adjust(own) end
        local actor = S.actors[index]
        if actor and actor.ped and DoesEntityExist(actor.ent) then
            local group = S.scene.group and Formation.together(S.scene.group) and companyOf(actor) or { actor.ent }
            if #group == 2 then
                -- A pair (an embrace faces each other): the camera on the side of the line between them nearer the scene's own.
                local a, b = GetEntityCoords(group[1]), GetEntityCoords(group[2])
                local h1 = math.deg(math.atan(b.y - a.y, b.x - a.x))
                local want = actor.spot.heading
                local d1 = math.abs((h1 - want + 540.0) % 360.0 - 180.0)
                return PedFrame.group(group, d1 <= 90.0 and h1 or h1 + 180.0, side(), S.fov, zoom())
            end
            if #group > 2 then return PedFrame.group(group, actor.spot.heading, side(), S.fov, zoom()) end
            -- Seated: framed from the seat, not the bones, so the shot is right before the pose has taken.
            -- The side the camera first takes stays (later reframes only fit the pose).
            local pose
            if actor.spot.seat then pose = PedFrame.seat(actor.spot.seat, actor.spot.heading, side(), S.fov, zoom(), actor.spot.low, carBoxes(), actor.ent, actor.view)
            else pose = PedFrame.shot(actor.ent, side(), S.fov, zoom(), carBoxes(), actor.view) end
            if pose and not actor.view then actor.view = pose.view end
            return pose
        end
        if spot then return PedFrame.at(spot.ground.pos, spot.heading, side(), S.fov, zoom()) end
        return nil
    end

    -- Where the camera rests on a card: single scenes end their focus push-in there.
    local function heroPose(index)
        local shot = S.scene.mode == 'single' and focusShot()
        if shot then return adjust(CamMath.pose(shot.keys[#shot.keys], S.scene.anchor)) end
        return shotFor(index)
    end

    -- True when the player's view differs from the scene's own (another preset or an open panel).
    local function custom()
        return S.side ~= nil or zoom() ~= 1.0
    end

    -- Lineup: glides to the card (time scaled by distance, clamped x0.7..x1.6), the focus racks with it.
    -- fixedMs: a straight pan of that length (panel open or close, camera preset).
    frame = function(index, instant, fixedMs)
        if Film.active() or (S and S.cinema) then return end
        local pose = index and heroPose(index)
        if not pose then return end
        local move = S.scene.shots and S.scene.shots.move or {}
        local ms, arc = 0, fixedMs and 0 or tonumber(move.arc) or 0
        if fixedMs and not instant then
            ms = fixedMs
        elseif not instant then
            ms = (tonumber(move.ms) or 1400) * CamMath.clamp(CamMath.dist(Rig.pose(), pose) / 3.0, 0.7, 1.6)
        end
        Director.retarget(pose, ms, { arc = arc, anchor = S.scene.anchor, subject = CamMath.dist(pose, chestOf(index)), instant = instant })
    end

    -- Single mode: the push-in plays again on every swap ("cut on action").
    -- The opener's first pose before the hero pose: down from above, out of the face, or a quarter round.
    local OPENERS = {
        drop = function(hero, chest)
            local x, y = hero.x + (hero.x - chest.x) * 0.4, hero.y + (hero.y - chest.y) * 0.4
            local z = chest.z + 5.5
            local p, r = CamMath.lookRot(x, y, z, chest.x, chest.y, chest.z)
            return { x = x, y = y, z = z, rx = p, ry = 0, rz = r, fov = hero.fov + 6.0 }, 2800
        end,
        reveal = function(hero, chest, ent)
            local head = ent and DoesEntityExist(ent) and GetPedBoneCoords(ent, 31086, 0.0, 0.0, 0.0) or (chest + vector3(0.0, 0.0, 0.5))
            local t = 0.85 / math.max(CamMath.dist(hero, head), 0.1)
            local x, y, z = head.x + (hero.x - head.x) * t, head.y + (hero.y - head.y) * t, head.z + (hero.z - head.z) * t
            local p, r = CamMath.lookRot(x, y, z, head.x, head.y, head.z)
            return { x = x, y = y, z = z, rx = p, ry = 0, rz = r, fov = 28.0 }, 3000
        end,
        orbit = function(hero, chest)
            local x, y, z = CamMath.orbit(hero, chest, math.random(2) == 1 and 55.0 or -55.0)
            local p, r = CamMath.lookRot(x, y, z, chest.x, chest.y, chest.z)
            return { x = x, y = y, z = z, rx = p, ry = 0, rz = r, fov = hero.fov }, 2600
        end,
    }
    local lastOpener

    local function opener()
        local list = {}
        for _, name in ipairs((Config.Selection or {}).Openers or { 'push' }) do
            if name ~= lastOpener and (name == 'push' or OPENERS[name]) then list[#list + 1] = name end
        end
        lastOpener = list[1] and list[math.random(#list)] or 'push'
        return lastOpener
    end

    -- A role scene's film for the shown actor (the film section above): played once a session, else its end is set at
    -- once; the scene's camera takes over after. false when the scene has none.
    local function startFilm(actor, valid)
        local id = S.scene.film
        if not id or not Films[id] or not actor or not actor.real then return false end
        local key, state = S.scene.id .. ':' .. tostring(actor.index), S
        CreateThread(function()
            Wait(600) -- the company stands by then
            if not valid() or S ~= state or not DoesEntityExist(actor.ent) then return end
            local peds = { me = { ent = actor.ent, sex = actor.gender, spot = actor.spot, restore = function(v) poseActor(actor, v) end } }
            if S.partner then peds.partner = { ent = S.partner.ent, sex = S.partner.sex, spot = S.partner.spot, restore = S.partner.restore } end
            local crew = Scene.company()
            for i, m in ipairs(crew) do peds['crew' .. i] = { ent = m.ent, sex = m.sex, spot = m.spot, restore = m.restore } end
            for id2, p in pairs(Cast.peds()) do peds[id2] = peds[id2] or { ent = p.ent, sex = p.sex, spot = p.spot } end
            local played = Film.run(id, key, { peds = peds, cars = Cast.cars(), crew = #crew }, valid)
            if valid() and S == state and S.focused then frame(S.focused, not played, played and 1600 or nil) end
        end)
        return true
    end

    local function pushIn(index)
        local shot = focusShot()
        local kind = MC.lowSpec() and 'push' or opener()
        if custom() or (kind == 'push' and not shot) then return frame(index, true) end
        if kind == 'push' then
            local last = CamMath.pose(shot.keys[#shot.keys], S.scene.anchor)
            return Director.play(shot, { from = 'first', anchor = S.scene.anchor, subject = last and CamMath.dist(last, chestOf(index)) })
        end
        local hero, chest = heroPose(index), chestOf(index)
        if not hero then return frame(index, true) end
        local actor = S.actors[index]
        local first, ms = OPENERS[kind](hero, chest, actor and actor.ent)
        Director.play({ keys = { first, hero }, ms = ms, ease = 'outCubic' }, { from = 'first', subject = CamMath.dist(hero, chest) })
    end

    -- A page card's actor, built now when single mode has not made it yet.
    local function actorFor(index, valid)
        if S.actors[index] then return S.actors[index] end
        for slot, card in ipairs(pageCards(S.page)) do
            if card.index == index then
                local actor = buildActor(card, slot, valid)
                if actor and valid() then
                    -- A page build may have made this card's actor meanwhile: keep that one.
                    if S.actors[index] then
                        Actors.remove(actor.ent)
                        return S.actors[index]
                    end
                    S.actors[index] = actor
                    Anchors.set(anchorList())
                    return actor
                end
                if actor then Actors.remove(actor.ent) end
            end
        end
        return nil
    end

    -- Single mode: the focused actor appears under a short dip; later focus calls are picked up by the same loop. A page
    -- build that starts meanwhile takes over (it shows the focused card itself).
    swap = function(state, valid)
        if state.swapping then return end
        state.swapping = true
        while valid() and not state.paging and state.shown ~= state.focused do
            local target = state.focused
            local faded = fadeOut(140)
            if not valid() or state.paging then
                if faded then DoScreenFadeIn(160) end
                break
            end
            local old = state.actors[state.shown]
            if old then
                Actors.hide(old.ent)
                -- Release any active act, pair loop, held prop, chair or scenario so the next character or next show starts clean.
                Cast.release(old.ent)
                if old.spot and DoesEntityExist(old.ent) then
                    SetEntityCoordsNoOffset(old.ent, old.spot.pos.x, old.spot.pos.y, old.spot.pos.z, false, false, false)
                    SetEntityHeading(old.ent, old.spot.heading + 0.0)
                end
                old.posed = false
            end
            ShowCar.clear()
            show(actorFor(target, valid), valid)
            state.shown = target
            onlyShown(state)
            -- The camera is set once the pose has taken (crouched, seated, leaning), while the screen is still dark.
            local wait = GetGameTimer() + 300
            while valid() and GetGameTimer() < wait do Wait(0) end
            -- The scene may have gone meanwhile (a scene change, Play): its own build lifts the black then.
            if not valid() or S ~= state then break end
            if not startFilm(state.actors[target], valid) then pushIn(target) end
            CreateThread(function() placeFill(valid) end)
            if faded then DoScreenFadeIn(160) end
        end
        state.swapping = false
    end

    -- The focused character's own car swaps in about 400 ms after the camera settles.
    local function scheduleCar(index)
        if not S.carSpot then return end
        S.carToken = (S.carToken or 0) + 1
        local state, token = S, S.carToken
        local function valid() return S == state and state.carToken == token end
        CreateThread(function()
            repeat Wait(100) until not valid() or not Director.busy()
            Wait(400)
            if not valid() or ShowCar.owner() == index then return end
            local actor = state.actors[index]
            ShowCar.clear()
            if actor and actor.vehicle then ShowCar.show(actor.vehicle, state.carSpot, valid, index, state.night) end
        end)
    end

    -- Frame 'light': a spot light from the front and above on the chest of the hovered (else focused) actor.
    local function light()
        local l = S and S.scene.light
        if type(l) ~= 'table' then return end
        local actor = S.actors[S.hovered or S.focused or -1]
        if not actor or not actor.ped or not DoesEntityExist(actor.ent) or not IsEntityVisible(actor.ent) then return end
        local chest = GetPedBoneCoords(actor.ent, CHEST, 0.0, 0.0, 0.0)
        S.aim = S.aim and S.aim + (chest - S.aim) * 0.12 or chest
        local src = S.aim + GetEntityForwardVector(actor.ent) * 2.4 + vector3(0.0, 0.0, 1.8)
        local dir = S.aim - src
        dir = dir / #dir
        local c = type(l.color) == 'table' and l.color or {}
        DrawSpotLightWithShadow(src.x, src.y, src.z, dir.x, dir.y, dir.z, math.floor(c.r or 255), math.floor(c.g or 255), math.floor(c.b or 255),
            (tonumber(l.range) or 16.0) + 0.0, (tonumber(l.intensity) or 5.0) + 0.0, 4.0, 24.0, 8.0, 74)
    end

    -- The camera starts on the establishing move (or a plain wide shot) with the scene's depth of field and sway.
    local function establish(scene)
        local shot = scene.shots and scene.shots.establish
        local a = scene.anchor
        local centre = { x = a.x, y = a.y, z = a.z + 1.1 }
        local path = CamMath.path(type(shot) == 'table' and shot.keys or nil, a)
        -- From above and behind the camera's own resting place down onto the focused character (the opening titles keep
        -- their own move).
        local hero = scene.id ~= 'intro' and S.focused and heroPose(S.focused)
        if hero then
            local chest = chestOf(S.focused)
            local x, y = hero.x + (hero.x - chest.x) * 1.6, hero.y + (hero.y - chest.y) * 1.6
            local z = hero.z + 2.4
            local pitch, yaw = CamMath.lookRot(x, y, z, chest.x, chest.y, chest.z)
            path = { { x = x, y = y, z = z, rx = pitch, ry = 0, rz = yaw, fov = hero.fov + 6.0 }, hero }
            centre = { x = chest.x, y = chest.y, z = chest.z }
        end
        if #path == 0 then
            local x, y, z = CamMath.toWorld(a, 0, 9.0, 1.8)
            local pitch, yaw = CamMath.lookRot(x, y, z, centre.x, centre.y, centre.z)
            path = { { x = x, y = y, z = z, rx = pitch, ry = 0, rz = yaw, fov = 38.0 } }
        end
        S.fov = path[#path].fov
        Rig.start(path[1])
        Rig.dof(not MC.lowSpec() and scene.dof)
        Rig.subject(CamMath.dist(path[1], centre), 0)
        Director.idle(Scene.sway())
        Director.play({ keys = path, ms = type(shot) == 'table' and shot.ms or 0, ease = type(shot) == 'table' and shot.ease or nil },
            { from = 'first', subject = CamMath.dist(path[#path], centre) })
    end

    function Scene.active()
        return S ~= nil
    end

    -- A drag on the page turns the focused character (degrees, plain or role scene alike).
    function Scene.turn(deg)
        local actor = S and S.actors[S.focused]
        if not actor or not actor.ped or not DoesEntityExist(actor.ent) then return false end
        SetEntityHeading(actor.ent, (GetEntityHeading(actor.ent) + deg) % 360)
        Scene.touch()
        return true
    end

    -- A role scene's companion place n (n = 1 stands next to the focused actor), for a crew member; nil elsewhere.
    function Scene.companion(n)
        if not S or not S.scene.setups then return nil end
        return S.spots[(tonumber(n) or 0) + 1]
    end

    -- The crew grew or shrank: a role scene takes its layout for the new size (the page is built again).
    function Scene.relayout()
        if not S or not S.scene.setups then return false end
        local spots = buildSpots(S.scene, S.cards)
        if #spots == #S.spots then return false end
        S.spots = spots
        return Scene.page(S.page, S.focused, true)
    end

    -- For the moments: the shown actor (with how to pose it again), its spot, the scene's group, the partner when there
    -- is no crew, and whether the actor can join in (not sitting, not in a never-ending sync like CPR).
    function Scene.group()
        if not S or type(S.scene.group) ~= 'table' then return nil end
        local actor = S.actors[S.scene.mode == 'single' and S.shown or S.focused]
        if not actor or not actor.real or not DoesEntityExist(actor.ent) or not IsEntityVisible(actor.ent) then return nil end
        local scenario = type(actor.spot.act) == 'table' and actor.spot.act.scenario or ''
        local seated = scenario:find('SEAT', 1, true) ~= nil or scenario:find('LOUNGER', 1, true) ~= nil
        return {
            actor = actor, spot = actor.spot, group = S.scene.group, free = not seated and not actor.spot.sync,
            partner = S.partner and DoesEntityExist(S.partner.ent) and S.partner or nil,
            restore = function(valid) poseActor(actor, valid) end,
        }
    end

    -- Who stands round the shown actor for the moments: the crew's members and the editor test's stand-ins.
    function Scene.company()
        local out = Crew and Crew.peds and Crew.peds() or {}
        for _, m in ipairs(S and S.testCrew or {}) do
            if DoesEntityExist(m.ent) then out[#out + 1] = m end
        end
        return out
    end

    -- The camera takes in the company once it stands in its pose (moments.lua calls it), in a slow move.
    function Scene.reframeCompany()
        if not S then return end
        local state = S
        SetTimeout(350, function()
            if S == state and S.focused and not Photo.active() then frame(S.focused, false, 1400) end
        end)
    end

    -- The shown actor's film again (R on the selection).
    function Scene.replayFilm()
        if not S or not S.scene.film or Film.active() then return false end
        local actor = S.actors[S.scene.mode == 'single' and S.shown or S.focused]
        if not actor then return false end
        Film.forget(S.scene.id .. ':' .. tostring(actor.index))
        return startFilm(actor, validFor(gen))
    end

    -- The editor test's company (0 alone, 1 a partner, 2-3 a crew): set before Scene.open, or on an open scene whose
    -- page is built again with the stand-ins; a moment follows soon. Scene.endTest clears it.
    function Scene.testCompany(n)
        testCompany = n
        if not S or not S.scene.setups then return end
        S.spots = buildSpots(S.scene, S.cards)
        Film.forget()
        Scene.page(S.page, S.focused, true)
        startFilm(S.actors[S.scene.mode == 'single' and S.shown or S.focused], validFor(gen))
        Moments.soon(3000)
    end

    function Scene.endTest()
        testCompany = nil
    end

    -- Whether the scene on screen shows a partner or crew (a scene made for them, or a plain one).
    function Scene.takesCompany()
        return S ~= nil and (type(S.scene.group) == 'table' or not S.scene.role)
    end

    function Scene.hasPartner(index)
        return partnerOf(tonumber(index)) ~= nil
    end

    -- The role of the scene on screen ('pd', 'ems'...), nil for a plain one.
    function Scene.role()
        return S and S.scene.role or nil
    end

    function Scene.pages()
        if not S then return 1 end
        return math.max(1, math.ceil(#S.cards / pageSize()))
    end

    function Scene.pageOf(index)
        local p = S and tonumber(index) and position(tonumber(index))
        return p and math.ceil(p / pageSize()) or nil
    end

    function Scene.current()
        return S and S.focused or nil
    end

    function Scene.actor(index)
        local actor = S and S.actors[tonumber(index) or -1]
        return actor and actor.ent or nil
    end

    -- The scene's idle sway, or nil while the player turned drift off.
    function Scene.sway()
        local sway = S and S.scene.shots and S.scene.shots.sway
        if type(sway) ~= 'table' or MC.lowSpec() or (Look and not Look.drift()) then return nil end
        return sway
    end

    -- Builds the scene behind black (missing previews fetched) and starts the establishing move; blocks, true when ready.
    -- opts { focus, side }: a scene change cuts straight to that card (no establishing move) and keeps the panel framing.
    function Scene.open(scene, cards, previews, page, opts)
        Scene.destroy()
        if type(scene) ~= 'table' or type(scene.anchor) ~= 'table' then return false end
        opts = type(opts) == 'table' and opts or {}
        gen = gen + 1
        local valid = validFor(gen)
        -- paging: the first page is not built yet (a focus change waits for it, see buildPage).
        S = { scene = scene, cards = cardList(cards), previews = {}, actors = {}, props = {}, fill = {}, fov = 38.0, side = opts.side, paging = 0 }
        S.spots = buildSpots(scene, S.cards)
        mergePreviews(previews)
        S.focused = opts.focus and position(opts.focus) and opts.focus or initialIndex()
        S.page = tonumber(page) and math.floor(CamMath.clamp(tonumber(page), 1, Scene.pages())) or Scene.pageOf(S.focused) or 1
        if Scene.pageOf(S.focused) ~= S.page then S.focused = firstOnPage(S.page) end
        S.carSpot, S.night = carSpot(scene), night(scene)
        local a = scene.anchor
        Env.apply(scene)
        if Look then Look.world() end
        Stream.ipls(type(scene.ipls) == 'table' and scene.ipls or {}, scene.sets)
        Player.place(vector4(a.x + 0.0, a.y + 0.0, a.z + 0.0, (a.h or 0.0) + 0.0))
        Stream.at(vector3(a.x + 0.0, a.y + 0.0, a.z + 0.0), (tonumber(scene.stream) or 80.0) + 0.0, 6000)
        if not valid() then return false end
        if scene.id ~= 'intro' then S.spots = buildSpots(scene, S.cards) end -- again, now that the ground is there
        if not MC.lowSpec() then buildProps(valid) end
        Cast.build(scene, valid)
        if not buildPage(valid) then return false end
        if not startFilm(S.actors[S.scene.mode == 'single' and S.shown or S.focused], valid) then establish(scene) end
        if opts.focus then
            frame(S.focused, true)
            scheduleCar(S.focused)
        end
        Frame.on('anchors', Anchors.tick)
        if type(scene.light) == 'table' and not MC.lowSpec() then Frame.on('light', light) end
        Scene.touch()
        idleLoop(S, validFor(gen))
        if type(scene.group) == 'table' then Moments.start(validFor(gen)) end -- crew and partner moments only
        -- The resting camera keeps the shown character's head where it framed it.
        local state = S
        Director.track(function()
            local a = S == state and S.actors[S.scene.mode == 'single' and S.shown or S.focused]
            return a and a.ped and DoesEntityExist(a.ent) and GetPedBoneCoords(a.ent, 31086, 0.0, 0.0, 0.0) or nil
        end)
        return true
    end

    -- The frame for the focused card again over ms: side = 'panel' while a side panel is open, nil for the scene's own.
    function Scene.reframe(sidebox, ms)
        if not S then return false end
        Scene.touch()
        S.side = sidebox
        if S.focused then frame(S.focused, (tonumber(ms) or 0) <= 0, ms) end
        return true
    end

    -- A new pose for a card's actor: it is put back on its spot and posed again (single mode: when it next shows).
    function Scene.repose(index, pose)
        local actor = S and S.actors[tonumber(index) or -1]
        if not actor or not actor.ped or designed(S.spots[spotIndex(actor.index) or 1]) then return false end
        actor.spot = posed(S.spots[spotIndex(actor.index) or 1], pose)
        local ent, spot, valid = actor.ent, actor.spot, validFor(gen)
        if not DoesEntityExist(ent) then return false end
        ClearPedTasksImmediately(ent)
        FreezeEntityPosition(ent, true)
        SetEntityCollision(ent, false, false)
        SetEntityCoordsNoOffset(ent, spot.pos.x, spot.pos.y, spot.pos.z, false, false, false)
        SetEntityHeading(ent, spot.heading + 0.0)
        actor.posed = false
        if S.scene.mode == 'single' and S.shown ~= actor.index then return true end
        CreateThread(function() actor.posed = Actors.pose(ent, spot, actor.gender, actor.index, valid) end)
        return true
    end

    -- Low-spec mode switched while the scene shows: depth of field, key light, sway and the crew follow.
    function Scene.lowSpec()
        if not S then return end
        local low = MC.lowSpec()
        Rig.dof(not low and S.scene.dof)
        if low or type(S.scene.light) ~= 'table' then Frame.off('light') else Frame.on('light', light) end
        Director.idle(Scene.sway())
        if Crew then Crew.place() end
    end

    -- Drift on or off: the sway follows at once.
    function Scene.drift()
        if not S then return end
        Director.idle(Scene.sway())
    end

    -- Where the focused card stands: { pos (ground), heading }, for the crew formation.
    function Scene.spot(index)
        if not S then return nil end
        local spot = S.spots[spotIndex(tonumber(index) or S.focused or -1) or 1]
        return spot and spot.ground or nil
    end

    -- With a crew around, a lineup shows only the focused actor (the crew stands where the others did).
    function Scene.solo(on)
        if not S then return end
        S.solo = on == true
        if S.scene.mode == 'single' then return end
        for index, actor in pairs(S.actors) do
            if S.solo and index ~= S.focused then Actors.hide(actor.ent) else Actors.show(actor.ent, actor.alpha) end
        end
    end

    -- Reel change under a fade: the page's actors are rebuilt and the focused card framed; force rebuilds the same page.
    function Scene.page(n, focusIndex, force)
        if not S then return false end
        n = math.floor(CamMath.clamp(tonumber(n) or 1, 1, Scene.pages()))
        if n == S.page and not focusIndex and not force then return true end
        local state = S
        state.reel = (state.reel or 0) + 1
        local mine = state.reel
        local faded = fadeOut(300) or state.reelFaded == true
        state.reelFaded = faded
        if S ~= state then return false end
        local valid = validFor(gen)
        state.page = n
        state.focused = focusIndex and Scene.pageOf(focusIndex) == n and tonumber(focusIndex) or firstOnPage(n)
        ShowCar.clear()
        local ok = buildPage(valid)
        if ok then
            frame(state.focused, true)
            scheduleCar(state.focused)
            if state.solo then Scene.solo(true) end
            if Crew then Crew.place() end
        end
        if state.reel == mine then
            state.reelFaded = nil
            if faded then DoScreenFadeIn(300) end
        end
        return ok
    end

    -- The focused character greets the player once the camera has come close (not under low spec).
    local function greet(index)
        local state, valid = S, validFor(gen)
        CreateThread(function()
            Wait(650)
            if not valid() or state.focused ~= index or MC.lowSpec() then return end
            local actor = state.actors[index]
            if actor and actor.real and actor.ent and not actor.spot.act and not actor.spot.female and not actor.spot.sync then Actors.gesture(actor.ent, actor.gender, valid) end
        end)
    end

    -- Idle (Config.Selection.Idle): left alone, the focused character does something to the camera now and then.
    local idleAt = GetGameTimer()

    -- Any move of the player's (focus, hover, a panel) restarts the wait.
    -- Whether the focused character takes the player's pose (the page hides the poses when its spot has its own).
    function Scene.posable()
        local actor = S and S.actors[S.focused]
        return actor ~= nil and not designed(S.spots[spotIndex(actor.index) or 1])
    end

    function Scene.touch()
        idleAt = GetGameTimer()
        if S and S.cinema then Scene.stopCinema() end
    end

    local function idleMove(actor, valid)
        local moves = ((Config.Selection or {}).Idle or {}).Moves or {}
        if #moves == 0 then return end
        local m = moves[math.random(#moves)]
        local dict = tostring(m.dict or ''):gsub('{sex}', actor.gender == 'f' and 'female' or 'male')
        if not Actors.dict(dict, valid) or not DoesEntityExist(actor.ent) then return end
        Cast.release(actor.ent)
        TaskPlayAnim(actor.ent, dict, m.clip, 4.0, -4.0, -1, 0, 0.0, false, false, false)
        local stop = GetGameTimer() + math.floor(GetAnimDuration(dict, m.clip) * 1000) + 200
        while valid() and GetGameTimer() < stop and idleAt + 100 < stop do Wait(100) end
        if valid() and DoesEntityExist(actor.ent) then poseActor(actor, valid) end
    end

    -- The focused actor's idle pose changes every PoseCycle seconds (plain scenes, no pose picked by the player).
    local function cycle(state, actor, valid)
        local card = nil
        for _, c in ipairs(state.cards) do
            if c.index == actor.index then card = c end
        end
        if designed(actor.spot) or (card and type(card.pose) == 'string' and card.pose ~= 'random') then return end
        actor.cycle = (actor.cycle or 0) + 1
        local spot = { pos = actor.spot.pos, heading = actor.spot.heading, anim = 'random', ground = actor.spot.ground }
        Actors.pose(actor.ent, spot, actor.gender, actor.index + actor.cycle, valid)
    end

    -- Left alone, the camera turns into a film: slow shots of the scene from all round, cut one after another (GTA's
    -- idle camera), the menu staying where it is; anything the player does ends it. Config.Selection.IdleCinema seconds (0: off).
    local SHOT_MS = 7000

    local function cinemaPose(target, ent, yaw, dist, lift)
        local r = math.rad(yaw)
        local p = vector3(target.x + math.sin(r) * dist, target.y - math.cos(r) * dist, target.z + lift)
        local probe = StartExpensiveSynchronousShapeTestLosProbe(target.x, target.y, target.z, p.x, p.y, p.z, 1 | 2 | 16, ent, 7)
        local _, hit, at = GetShapeTestResult(probe)
        if hit == 1 then p = target + (at - target) * 0.85 end
        local pitch, heading = CamMath.lookRot(p.x, p.y, p.z, target.x, target.y, target.z)
        return { x = p.x, y = p.y, z = p.z, rx = pitch, ry = 0.0, rz = heading, fov = 38.0 + math.random() * 10.0 }
    end

    local function cinema(state, valid)
        state.cinema = true
        local mine = {}
        state.cinemaToken = mine
        CreateThread(function()
            while valid() and state.cinemaToken == mine do
                local actor = state.actors[state.scene.mode == 'single' and state.shown or state.focused]
                if not actor or not DoesEntityExist(actor.ent) then break end
                local head = GetPedBoneCoords(actor.ent, 31086, 0.0, 0.0, 0.0)
                local target = head - vector3(0.0, 0.0, 0.3)
                local yaw, dist, lift = math.random() * 360.0, 2.4 + math.random() * 3.4, -0.6 + math.random() * 2.2
                local turn = (math.random() < 0.5 and -1 or 1) * (12.0 + math.random() * 22.0)
                local from = cinemaPose(target, actor.ent, yaw, dist, lift)
                local to = cinemaPose(target, actor.ent, yaw + turn, dist * (0.8 + math.random() * 0.25), lift + (math.random() - 0.5) * 0.5)
                Director.stop()
                Rig.set(from)
                Director.retarget(to, SHOT_MS, { arc = 0, instant = false })
                local stop = GetGameTimer() + SHOT_MS
                while valid() and state.cinemaToken == mine and GetGameTimer() < stop do Wait(100) end
            end
        end)
    end

    -- Back from the idle film: the menu returns and the camera to the character.
    function Scene.stopCinema()
        if not S or not S.cinema then return false end
        S.cinema, S.cinemaToken = false, nil
        idleAt = GetGameTimer()
        Director.stop()
        if S.focused then frame(S.focused, false, 1400) end
        return true
    end

    idleLoop = function(state, valid)
        CreateThread(function()
            local cycledAt = GetGameTimer()
            while valid() do
                Wait(1000)
                local every = tonumber((Config.Selection or {}).PoseCycle) or 0
                local focused = state.actors[state.focused]
                if every > 0 and focused and focused.real and not state.swapping and not Photo.active()
                    and GetGameTimer() - cycledAt > every * 1000 and IsEntityVisible(focused.ent) then
                    cycle(state, focused, valid)
                    cycledAt = GetGameTimer()
                end
                local wait = tonumber((Config.Selection or {}).IdleCinema) or 30
                if wait > 0 and not state.cinema and not state.swapping and not Director.busy() and not Photo.active() and not Film.active()
                    and GetGameTimer() - idleAt > wait * 1000 and (State.is('select') or State.is('editor')) then
                    cinema(state, valid)
                end
                local seconds = tonumber(((Config.Selection or {}).Idle or {}).Seconds) or 0
                local actor = seconds > 0 and state.actors[state.focused]
                if actor and actor.real and not state.swapping and not MC.lowSpec() and not Director.busy() and not Photo.active() and not Moments.busy() and not Film.active()
                    and GetGameTimer() - idleAt > seconds * 1000 and IsEntityVisible(actor.ent) then
                    idleMove(actor, valid)
                    idleAt = GetGameTimer()
                end
            end
        end)
    end

    -- Moves the camera to a card; another page changes reels first. Returns the card's page, or nil for an unknown index.
    function Scene.focus(index)
        index = tonumber(index)
        if not S or not index then return nil end
        Scene.touch()
        local page = Scene.pageOf(index)
        if not page then return nil end
        if page ~= S.page then
            Scene.page(page, index)
            return page
        end
        S.focused = index
        if S.scene.mode == 'single' and S.shown ~= index then
            -- A page still building shows this card itself, or swaps to it when it is done.
            if not S.paging then
                local state, valid = S, validFor(gen)
                CreateThread(function() swap(state, valid) end)
            end
        else
            frame(index, false)
        end
        if S.solo then Scene.solo(true) end
        if Crew then Crew.place() end
        scheduleCar(index)
        greet(index)
        return page
    end

    -- The key light follows the hovered actor; nil goes back to the focused one.
    function Scene.hover(index)
        if not S then return false end
        Scene.touch()
        index = tonumber(index)
        S.hovered = index and S.actors[index] and index or nil
        return true
    end

    -- New cards (delete, redeem, grant): the current page is rebuilt under a short dip.
    function Scene.refresh(cards, previews)
        if not S then return false end
        S.cards, S.previews = cardList(cards), {}
        mergePreviews(previews)
        if not position(S.focused) then S.focused = S.cards[1] and S.cards[1].index or nil end
        return Scene.page(Scene.pageOf(S.focused) or 1, S.focused, true)
    end

    -- Removes everything the scene made and gives the world back; safe to call at any time.
    function Scene.destroy()
        gen = gen + 1
        if not S then return end
        if Photo.active() then Photo.stop() end
        Film.stop()
        local state = S
        S = nil
        if Crew then MC.try(Crew.clear) end
        Moments.stop()
        Director.track(nil)
        Director.stop()
        Cast.clear()
        ClearExtraTimecycleModifier()
        Rig.dof(false)
        Frame.off('anchors')
        Frame.off('light')
        Anchors.clear()
        ShowCar.clear()
        for _, actor in pairs(state.actors) do Actors.remove(actor.ent) end
        for _, ped in ipairs(state.fill or {}) do Actors.remove(ped) end
        for _, prop in ipairs(state.props) do Actors.remove(prop) end
        Track.clear('scene')
        Track.clear('seat')
        Track.clear('car')
        Actors.release()
        Stream.dropIpls()
        Env.restore()
        ClearFocus()
    end
end

-- The arrest: a still that lives (the suspect on his knees, hands on his head; the officer aiming; the partner and
-- crew covering; sirens) and a camera move into it: low past the car, over the shoulder at the suspect, then the
-- scene's own frame.
do
    Films = Films or {}
    Films.arrest = {}

    function Films.arrest.play(f)
        f.cam({ from = { ent = 'me', offset = { -1.4, -3.6, 0.35 } }, look = { ent = 'suspect', offset = { 0, 0, 0.3 } }, fov = 44, cut = true })
        f.wait(400)
        f.cam({ from = { ent = 'me', offset = { -0.9, -2.6, 0.5 } }, look = { ent = 'suspect', offset = { 0, 0, 0.3 } }, fov = 42, damp = 0.6 })
        f.wait(2600)
        f.cam({ from = { ent = 'me', offset = { 0.45, -1.3, 0.72 } }, look = { ent = 'suspect', offset = { 0, 0, 0.35 } }, fov = 38, damp = 0.9 })
        f.wait(2800)
    end

    function Films.arrest.final() end
end
