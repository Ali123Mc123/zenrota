-- Chores on the client: the pieces of jobs near the player as local props on the ground, the tools in hand
-- and the steps sent back. The product gives its anchors, its calls, its looks and the options it offers.
--   local chores = Chores.client({
--       anchors = Core.World.anchors,
--       call = function(name, data) return lib.callback.await('daddy_college:chores:' .. name, false, data) end,
--       looks = { litter = { models = { 'ng_proc_sodacan_01a' } }, puddle = { models = { 'daddy_school_puddle', 'm23_2_prop_m32_puddle_01a' }, states = { 'large', 'medium', 'small' } } },
--       options = function(job, piece) return { { name = 'pick', label = '...', onSelect = ... } } end,
--   })
local RESOURCE = GetCurrentResourceName()

function Chores.client(opts)
    local api, jobs = { opts = opts }, {}
    local anchors = opts.anchors
    local me = GetPlayerServerId(PlayerId())

    local function exists(name) return IsModelInCdimage(joaat(name)) end

    local function uid(job, piece) return ('chores:%s:%d'):format(job.id, piece.id) end

    function api.mine(job) return job ~= nil and job.mine == true end
    function api.job(id) return jobs[id] end
    function api.piece(id, pieceId)
        local job = jobs[id]
        return job and job.byId[pieceId]
    end

    -- The model a piece shows now; nil when its look has no model left for that stage. A done piece that stays shows
    -- its look's last state (the cut grass).
    function api.modelOf(piece)
        if piece.model then return piece.model end
        local look = opts.looks[piece.look]
        if not look then return nil end
        -- A look without states keeps one model until the piece is done.
        local last = look.states and #look.states or 0
        return Chores.model(look, piece.done and last > 0 and last or piece.stage + 1, exists)
    end

    -- The ground under a piece, looked for from the top of the job's area down (once per piece).
    local function settle(job, piece, entity)
        if not piece.gz then
            if piece.z and piece.placed then
                piece.gz = piece.z
            else
                local top = piece.z and piece.z + 1.0 or job.top or GetEntityCoords(entity).z + 2.0
                local found, z = GetGroundZFor_3dCoord(piece.x, piece.y, top, false)
                piece.gz = found and (not job.bottom or z >= job.bottom - 0.5) and z or (piece.z or job.bottom or top)
            end
        end
        SetEntityCoordsNoOffset(entity, piece.x, piece.y, piece.gz, false, false, false)
        if not piece.placed then PlaceObjectOnGroundProperly(entity) end
        SetEntityCollision(entity, false, false)
        if opts.onSpawn then opts.onSpawn(job, piece, entity) end
    end

    local function show(job, piece)
        local model, staged = api.modelOf(piece)
        local look = opts.looks[piece.look or '']
        -- A look marked point is worked without a prop of its own (a shelf, a desk the map already has); a done piece
        -- stays only as a model made for its last state (a fallback would still look undone).
        if (not model and not (look and look.point)) or (piece.done and not staged) then return anchors.remove(uid(job, piece)) end
        local z = piece.gz or piece.z or job.top or 0.0
        anchors.set(uid(job, piece), {
            presentation = model and 'prop' or 'point', model = model, coords = { x = piece.x, y = piece.y, z = z, w = piece.h or (piece.id * 47.0) % 360.0 },
            revision = staged and piece.stage or 0, distance = 2.0, streamDistance = 85.0,
            -- Aimed at a small sphere on the piece, not its model: flat pieces (spills, grass) have next to no collision.
            targetSphere = look and look.target or { radius = 0.6, height = 0.25 },
            options = job.mine and not piece.done and opts.options and opts.options(job, piece) or nil,
            onSpawn = function(_, entity) if entity then settle(job, piece, entity) end end,
        })
    end

    local function hide(job, piece) anchors.remove(uid(job, piece)) end

    local function drawJob(job)
        for _, piece in ipairs(job.pieces) do show(job, piece) end
    end

    local function forget(id)
        local job = jobs[id]
        if not job then return end
        jobs[id] = nil
        for _, piece in ipairs(job.pieces) do hide(job, piece) end
        if opts.onClose then opts.onClose(job) end
    end

    -- A view applied as a change: pieces no longer there go, the others keep their props (only their options change).
    RegisterNetEvent(RESOURCE .. ':chores:view', function(view)
        local old = jobs[view.id]
        view.byId, view.mine = {}, false
        for _, source in ipairs(view.workers or {}) do view.mine = view.mine or source == me end
        for _, piece in ipairs(view.pieces) do
            local before = old and old.byId[piece.id]
            piece.gz = before and before.gz
            view.byId[piece.id] = piece
        end
        for _, piece in ipairs(old and old.pieces or {}) do
            if not view.byId[piece.id] then hide(old, piece) end
        end
        jobs[view.id] = view
        drawJob(view)
        if opts.onView then opts.onView(view, old) end
    end)

    -- A piece changed: a stage, a new look (a trap with its rat in) or done (gone, unless the job keeps its done pieces).
    RegisterNetEvent(RESOURCE .. ':chores:piece', function(change)
        local job = jobs[change.id]
        local piece = job and job.byId[change.piece]
        if not piece then return end
        if change.look then piece.look, piece.model = change.look, nil end
        if change.stage then piece.stage = change.stage end
        if change.done then piece.done = true end
        if piece.done and not job.keepDone then hide(job, piece) else show(job, piece) end
        if opts.onPiece then opts.onPiece(job, piece) end
    end)

    -- Only who works the job changed: the props stay, the options follow.
    RegisterNetEvent(RESOURCE .. ':chores:workers', function(change)
        local job = jobs[change.id]
        if not job then return end
        job.workers, job.mine = change.workers or {}, false
        for _, source in ipairs(job.workers) do job.mine = job.mine or source == me end
        drawJob(job)
    end)

    RegisterNetEvent(RESOURCE .. ':chores:placed', function(change)
        local job = jobs[change.id]
        if not job then return end
        local piece = change.piece
        job.pieces[#job.pieces + 1], job.byId[piece.id] = piece, piece
        show(job, piece)
    end)

    RegisterNetEvent(RESOURCE .. ':chores:close', function(change) forget(change.id) end)

    -- Tools in hand -------------------------------------------------------------------------------------
    -- spec: { model, bone, pos = vec3, rot = vec3 }; seen by everyone (a networked prop on the ped).
    local held = {}

    function api.hold(spec)
        local hash = joaat(spec.model)
        if not IsModelInCdimage(hash) or not pcall(lib.requestModel, hash, 2500) then return nil end
        local ped = cache.ped
        local at = GetEntityCoords(ped)
        pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
        local entity = CreateObject(hash, at.x, at.y, at.z + 0.2, true, true, false)
        SetModelAsNoLongerNeeded(hash)
        SetEntityCollision(entity, false, false)
        local pos, rot = spec.pos or vec3(0, 0, 0), spec.rot or vec3(0, 0, 0)
        AttachEntityToEntity(entity, ped, GetPedBoneIndex(ped, spec.bone or 57005), pos.x, pos.y, pos.z, rot.x, rot.y, rot.z,
            true, true, false, true, 1, true)
        held[#held + 1] = entity
        return entity
    end

    function api.unhold(entity)
        for i = #held, 1, -1 do
            if not entity or held[i] == entity then
                if DoesEntityExist(held[i]) then DeleteEntity(held[i]) end
                table.remove(held, i)
            end
        end
    end

    -- Swaps a held prop for another model in the same grip (the bag filling up).
    function api.swap(entity, spec)
        if spec.model and DoesEntityExist(entity) and GetEntityModel(entity) == joaat(spec.model) then return entity end
        api.unhold(entity)
        return api.hold(spec)
    end

    -- One clip, waited out. -> false when the dictionary is missing
    function api.play(dict, clip, ms, flag)
        if not pcall(lib.requestAnimDict, dict, 2500) then return false end
        TaskPlayAnim(cache.ped, dict, clip, 4.0, 4.0, ms or -1, flag or 0, 0.0, false, false, false)
        if ms and ms > 0 then Wait(ms) end
        RemoveAnimDict(dict)
        return true
    end

    -- Picking up --------------------------------------------------------------------------------------

    local PICK = { dict = 'pickup_object', clip = 'pickup_low', ms = 900 }

    -- Bends down, takes the piece and tells the server. -> the server's answer
    function api.pick(id, pieceId, anim)
        anim = anim or PICK
        local piece = api.piece(id, pieceId)
        if not piece then return { ok = false, error = 'gone' } end
        TaskTurnPedToFaceCoord(cache.ped, piece.x, piece.y, piece.gz or GetEntityCoords(cache.ped).z, 400)
        Wait(400)
        api.play(anim.dict, anim.clip, anim.ms, 48)
        return opts.call('pick', { job = id, piece = pieceId }) or { ok = false, error = 'unavailable' }
    end

    -- Taking back a thing that was put down (a sign, a trap).
    function api.collect(id, pieceId)
        api.play(PICK.dict, PICK.clip, PICK.ms, 48)
        return opts.call('collect', { job = id, piece = pieceId }) or { ok = false, error = 'unavailable' }
    end

    AddEventHandler('onResourceStop', function(resource)
        if resource ~= RESOURCE then return end
        api.unhold()
        for id in pairs(jobs) do forget(id) end
    end)

    Chores.attachTools(api)
    return api
end

-- Minigame screens send their steps (a timing press) as they happen; the server times them on arrival.
RegisterNUICallback('minigame:step', function(data, cb)
    cb({ ok = true })
    lib.callback(RESOURCE .. ':minigame:step', false, function() end, data)
end)
