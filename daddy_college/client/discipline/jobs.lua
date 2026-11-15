-- Public detention jobs on the client: the pieces drawn through the chores package, each kind with its own marker,
-- and [E] at the nearest one. Litter: picked by hand into a bag that fills up, the full bag thrown in a bin.
-- Sweep, mop, wipe: one [E] works a piece off in one go, it shrinks stage by stage. Organize: a close panel.
if not Core.ModuleEnabled('discipline') then return end

local cfg = Config.Discipline
local t = DL.locale.t
local current -- { job, total, bag, full, busy }

local function exists(name) return IsModelInCdimage(joaat(name)) end

local function firstModel(names)
    for _, name in ipairs(names or {}) do
        if exists(name) then return name end
    end
end

-- Looks: one per litter model so the pieces are mixed, the others staged by the chores package.
local looks = {}
for i, name in ipairs(cfg.Models.litter) do looks['litter' .. i] = { models = { name, 'prop_rub_litter_05' } } end
-- The states each staged model is made in, one per stage of the work (the last stage repeats when a model has fewer).
local STATES = { pile = { 'large', 'medium', 'trace' }, puddle = { 'large', 'medium', 'small' }, stain = { 'dirty', 'faded', 'faded' } }
for kind, states in pairs(STATES) do looks[kind] = { models = cfg.Models[kind], states = states } end
looks.bucket = { models = cfg.Models.bucket }
looks.shelf = { models = cfg.Models.shelf, point = true }

local chores

local function fail(result) Core.HandleResult(result, 'discipline') end

local function chore(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:chores:' .. name, false, data))
end

-- The bag's model for how full it is: a staged bag when the game has one, the plain bag otherwise.
local BAG_STATES = { 'empty', 'half', 'full' }
local function bagModel(done, total)
    local staged = Chores.stageOf(done, total, 3)
    for _, name in ipairs(cfg.Models.bag) do
        if exists(name .. '_' .. BAG_STATES[staged]) then return name .. '_' .. BAG_STATES[staged] end
        if exists(name) then return name end
    end
end

local function bagSpec(done, total)
    local model, h = bagModel(done, total), cfg.Hands.bag
    return model and { model = model, bone = h.bone, pos = h.pos, rot = h.rot } or nil
end

-- The slip's job line: what the job is and how many of its pieces are done.
local function showJob()
    if not current then return Core.Nui.Send('discipline:job', {}) end
    local left = 0
    for _, piece in ipairs(current.job.pieces) do
        if not piece.done and not piece.placed then left = left + 1 end
    end
    Core.Nui.Send('discipline:job', { kind = current.job.kind, done = current.total - left, total = current.total })
end

local function clear()
    if not current then return end
    current = nil
    showJob()
    chores.unhold()
    ClearPedTasks(cache.ped)
end

-- The ground under a piece, looked for once from the top of the job's area (the prop's spawn sets it too).
local function ground(job, piece)
    if piece.gz then return piece.gz end
    local found, z = GetGroundZFor_3dCoord(piece.x, piece.y, (job.top or GetEntityCoords(cache.ped).z + 5.0) + 0.0, false)
    if found then piece.gz = z end
    return found and z or nil
end

-- A flat ring lies on the ground; any other marker (the cone) stands over the spot and turns.
local function marker(m, x, y, z)
    local c, flat = m.color, m.type == 25 or m.type == 23 or m.type == 27
    DrawMarker(m.type, x, y, z + m.height, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, m.size, m.size, flat and 0.5 or m.size * 1.4,
        c[1], c[2], c[3], c[4], m.bob == true, false, 2, not flat, nil, nil, false)
end

-- Litter ----------------------------------------------------------------------------------------------

-- One piece picked by hand (the bag is hidden while the hand is on the ground); the bag fills up, the last one
-- sends the student to a bin.
local function pick(job, piece)
    local mine = current
    mine.busy = true
    if mine.bag and DoesEntityExist(mine.bag) then SetEntityVisible(mine.bag, false, false) end
    local result = chores.pick(job.id, piece.id)
    if current ~= mine then return end
    if result.ok then mine.bag = chores.swap(mine.bag, bagSpec(mine.total - result.left, mine.total)) end
    if mine.bag and DoesEntityExist(mine.bag) then SetEntityVisible(mine.bag, true, false) end
    mine.busy = false
    if not result.ok then return fail(result) end
    if result.left > 0 then return end
    mine.full = true
    Core.NotifyL('discipline.litter_bin', 'inform')
end

-- The throw first (the bag leaves the hand mid-swing), then the server counts the job and hands the next one out.
local function deliver(job, bin)
    local mine, throw = current, cfg.Throw
    mine.busy = true
    TaskTurnPedToFaceCoord(cache.ped, bin.x, bin.y, bin.z, 400)
    Wait(400)
    local played = pcall(lib.requestAnimDict, throw.dict, 2500)
    if played then TaskPlayAnim(cache.ped, throw.dict, throw.clip, 4.0, 4.0, throw.ms, 48, 0.0, false, false, false) end
    Wait(throw.release)
    if mine.bag then chores.unhold(mine.bag) end
    mine.bag = nil
    Wait(throw.ms - throw.release)
    if played then RemoveAnimDict(throw.dict) end
    if current ~= mine then return end
    local result = chore('drop', { job = job.id, target = bin.id })
    if current ~= mine then return end
    mine.busy = false
    if result.ok then return end
    mine.bag = chores.hold(bagSpec(mine.total, mine.total))
    fail(result)
end

-- Surfaces ----------------------------------------------------------------------------------------------

-- One [E]: the tool and the motion run on until the piece is gone; a stage goes to the server every stageMs.
local SLIP = { sweep = 'sweep', mop = 'wipe', wipe = 'wipe' } -- the progress slip's drawing per kind

local function work(job, piece)
    local w, mine = cfg.Work[job.kind], current
    mine.busy = true
    local begun = chore('begin', { job = job.id, piece = piece.id })
    if not begun.ok then
        mine.busy = false
        return fail(begun)
    end
    TaskTurnPedToFaceCoord(cache.ped, piece.x, piece.y, piece.gz or GetEntityCoords(cache.ped).z, 400)
    Wait(400)
    local stage, stages = begun.stage or 0, begun.stages or 1
    local state = { running = true }
    CreateThread(function()
        while state.running and stage < stages do
            Wait(w.stageMs)
            if not state.running then break end
            local result = chore('stage', { job = job.id, piece = piece.id, stage = stage + 1 })
            if not result.ok then
                state.error = result
                break
            end
            stage = stage + 1
        end
        -- The slip ends with the piece (a tick) or with the refusal, not on its spare half second.
        if state.running then Core.ProgressEnd(stage >= stages) end
        state.over = true
    end)
    local finished = Core.Progress({
        duration = (stages - stage) * w.stageMs + 600, label = t('discipline.progress_' .. job.kind), kind = SLIP[job.kind], canCancel = true,
        disable = { move = true, car = true, combat = true }, anim = { dict = w.dict, clip = w.clip, flag = 1 },
        prop = w.prop and { model = w.prop, bone = w.bone, pos = w.pos, rot = w.rot } or nil,
    })
    state.running = false
    mine.busy = false
    if state.error then return fail(state.error) end
    if not finished and stage < stages then Core.NotifyL('discipline.work_stopped', 'inform') end
end

-- The loop -----------------------------------------------------------------------------------------------

-- Every 250 ms: the markers in sight (the bins once the bag is full) and the nearest thing within reach.
local function scan(mine)
    local m, job, here = cfg.Marker, mine.job, GetEntityCoords(cache.ped)
    local list, near, best = {}, nil, math.huge
    if mine.full then
        for _, bin in ipairs(job.drops or {}) do
            local d = #(here - vector3(bin.x, bin.y, bin.z))
            if d < m.draw then list[#list + 1] = { m = m.bin, x = bin.x, y = bin.y, z = bin.z } end
            if d < m.binReach and d < best then near, best = bin, d end
        end
        return list, near
    end
    local style = m[job.kind]
    if not style then return list end
    for _, piece in ipairs(job.pieces) do
        if not piece.done and not piece.placed then
            local d = Chores.flat(here, piece)
            local z = d < m.draw and ground(job, piece)
            if z then list[#list + 1] = { m = style, x = piece.x, y = piece.y, z = z } end
            if z and d < m.reach and d < best then near, best = piece, d end
        end
    end
    return list, near
end

-- What [E] does at the thing near: pick up, throw the bag, or the surface's work.
local function action(mine)
    if mine.full then return t('discipline.litter_throw') end
    return mine.job.kind == 'litter' and t('discipline.litter_pick') or t('discipline.work_' .. mine.job.kind)
end

-- The job's loop: markers drawn every frame only while some are in sight, the school's own key prompt at the
-- bottom, and the bag clip kept on.
local function loop(mine)
    local list, near, scanAt, shown = {}, nil, 0, nil
    local key = Core.KeyName(38)
    while current == mine do
        local now = GetGameTimer()
        if now >= scanAt then
            scanAt = now + 250
            list, near = scan(mine)
            if mine.bag and not mine.busy and not IsEntityPlayingAnim(cache.ped, cfg.BagClip.dict, cfg.BagClip.clip, 3)
                and pcall(lib.requestAnimDict, cfg.BagClip.dict, 1000) then
                TaskPlayAnim(cache.ped, cfg.BagClip.dict, cfg.BagClip.clip, 4.0, 4.0, -1, 49, 0.0, false, false, false)
            end
        end
        for _, spot in ipairs(list) do marker(spot.m, spot.x, spot.y, spot.z) end
        local ready = near ~= nil and not mine.busy and not Core.ProgressActive() and not IsPedInAnyVehicle(cache.ped, false)
        local label = ready and action(mine) or nil
        if label ~= shown then
            shown = label
            Core.Prompt('discipline_job', label and { keys = { { keys = { key }, label = label } } } or nil)
        end
        if ready and IsControlJustPressed(0, 38) then
            mine.busy = true
            local target, job = near, mine.job
            CreateThread(function()
                if current ~= mine then return end
                if mine.full then deliver(job, target) elseif job.kind == 'litter' then pick(job, target) else work(job, target) end
            end)
        end
        Wait(#list > 0 and 0 or 250)
    end
    Core.Prompt('discipline_job', nil)
end

-- Organize ------------------------------------------------------------------------------------------------

-- The shelf panel: the server's game on paper, scored there.
local function organize(job, piece)
    if not current or current.busy then return end
    current.busy = true
    local result = Core.NormalizeResult(lib.callback.await('daddy_college:discipline:organizeStart', false, { job = job.id, piece = piece.id }))
    if current then current.busy = false end
    if not result.ok then return fail(result) end
    Core.Nui.Open('discipline.organize', { game = result.game })
end

Core.Nui.SafeCallback('discipline:organizeFinish', function(data)
    local result = Core.NormalizeResult(lib.callback.await('daddy_college:discipline:organizeFinish', false, data))
    if not result.ok then fail(result) end
    return result
end)

chores = Chores.client({
    anchors = Core.World.anchors,
    call = chore,
    looks = looks,
    options = function(job, piece)
        if job.kind ~= 'organize' or piece.placed then return nil end
        return { { name = 'discipline_organize', label = t('discipline.work_organize'), icon = 'fa-solid fa-book', distance = 2.5,
            canInteract = function() return current ~= nil and current.job.id == job.id and not current.busy end,
            onSelect = function() CreateThread(function() organize(job, piece) end) end } }
    end,
    onView = function(job)
        if not job.mine then return end
        if current and current.job.id == job.id then
            current.job = job
            return showJob()
        end
        clear()
        local total = 0
        for _, piece in ipairs(job.pieces) do
            if not piece.placed then total = total + 1 end
        end
        current = { job = job, total = total }
        showJob()
        if job.kind == 'litter' then current.bag = chores.hold(bagSpec(0, total)) end
        CreateThread(function() loop(current) end)
    end,
    onPiece = function(job)
        if current and current.job.id == job.id then showJob() end
    end,
    onClose = function(job)
        if current and current.job.id == job.id then clear() end
    end,
})
Core.ChoresClient = chores

-- The bag a student threw lies beside the bin for a while.
RegisterNetEvent('daddy_college:discipline:binbag', function(spot)
    local model = firstModel({ 'prop_rub_binbag_01', 'prop_cs_rub_binbag_01' })
    if not model or not pcall(lib.requestModel, joaat(model), 2500) then return end
    pcall(function() exports['FeloxAC']:CreateObject(joaat(model)) end) --[[FeloxAC:auto]]
    local entity = CreateObject(joaat(model), spot.x + 0.7, spot.y + 0.4, spot.z, false, false, false)
    SetModelAsNoLongerNeeded(joaat(model))
    PlaceObjectOnGroundProperly(entity)
    FreezeEntityPosition(entity, true)
    SetEntityCollision(entity, false, false)
    SetTimeout(cfg.BinBagSeconds * 1000, function() if DoesEntityExist(entity) then DeleteEntity(entity) end end)
end)

RegisterNetEvent('daddy_college:discipline:release', clear)
