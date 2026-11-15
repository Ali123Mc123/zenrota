-- Flooding on the client: the water spraying until the valve is shut, the spills (chores pieces) everyone sees,
-- the steps of the janitor (valve panel, sign, mop, sign back), a slip for whoever runs through a spill with no
-- sign by it, and the mop for a student serving detention who helps.
if not Config.Janitor or not Config.Janitor.Enabled then return end

local cfg = Config.Janitor
local rule = cfg.Events.flood
local t = DL.locale.t
local chores = Campus.chores
local sprays, floods = {}, {} -- incident id -> particle handle; incident id -> view
local busy = false

-- Water ----------------------------------------------------------------------------------------------------------

local function spray(view)
    local on = (view.state == 'open' or view.state == 'claimed') and view.data and view.data.spraying
    if on and not sprays[view.id] then
        local fx, c = cfg.Effects.water, view.coords
        if not pcall(function()
            RequestNamedPtfxAsset(fx[1])
            local limit = GetGameTimer() + 3000
            while not HasNamedPtfxAssetLoaded(fx[1]) and GetGameTimer() < limit do Wait(0) end
        end) then return end
        UseParticleFxAsset(fx[1])
        sprays[view.id] = StartParticleFxLoopedAtCoord(fx[2], c.x, c.y, c.z + 0.3, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    elseif not on and sprays[view.id] then
        StopParticleFxLooped(sprays[view.id], false)
        sprays[view.id] = nil
    end
end

-- Steps --------------------------------------------------------------------------------------------------------

local function step(id)
    local view = floods[id]
    return view and view.steps and view.steps[view.step]
end

-- The valve: its own spot to aim at while the water runs (the flood's spot when it has none), marked for its workers.
local function valve(view)
    local uid, v = 'janitor:valve:' .. view.id, view.data and view.data.valve
    if not v or not floods[view.id] or step(view.id) ~= 'valve' then return Campus.world.anchors.remove(uid) end
    local working = JanitorClient.working(view.id)
    Campus.world.anchors.set(uid, { coords = { x = v.x, y = v.y, z = v.z, w = v.w or 0.0 }, presentation = 'point', distance = 2.0,
        targetSphere = { radius = 0.6, height = 0.4 }, revision = working and 1 or 0,
        marker = working and { type = 0, size = { x = 0.25, y = 0.25, z = 0.25 }, color = { r = 80, g = 170, b = 255, a = 180 }, offset = 1.0, bob = true, drawDistance = 12.0 } or nil,
        options = { { name = 'janitor_flood_valve', label = t('janitor.flood_valve'), icon = 'fa-solid fa-faucet',
            canInteract = function() return JanitorClient.working(view.id) and step(view.id) == 'valve' end,
            onSelect = function() CreateThread(function() local f = floods[view.id] if f then JanitorClient.panel(view.id, f.data.valve, 'valve') end end) end } } })
end

local function placeSign(id)
    local view = floods[id]
    if not view or busy then return end
    if JanitorClient.tools.sign ~= true then return Campus.fail({ error = 'janitor_no_sign' }) end -- before the preview: the depot first
    busy = true
    local model = JanitorClient.model(cfg.Models.sign)
    local result = model and chores.place(view.data.job, model, function(show)
        if show then lib.showTextUI(t('janitor.place_hint')) else lib.hideTextUI() end
    end) or { ok = false, error = 'no_tool' }
    busy = false
    if not result.ok and result.error ~= 'cancelled' then Campus.fail({ error = result.error == 'no_tool' and 'janitor_no_sign' or result.error }) end
end

-- Mopping one spill: two keys in turn. The help line shows them, the strokes towards the next stage ("3/8") and
-- "slower" after a press that came too quick (it does not count).
local function mop(job, piece)
    if busy then return end
    busy = true
    local k = cfg.Strokes
    local held = chores.hold({ model = JanitorClient.model(cfg.Models.mop), bone = cfg.Hands.mop.bone, pos = cfg.Hands.mop.pos, rot = cfg.Hands.mop.rot })
    local working, strokes, slowUntil = true, 0, 0
    CreateThread(function()
        local shown
        while working do
            local slow = GetGameTimer() < slowUntil
            local key = strokes .. (slow and '!' or '')
            if key ~= shown then -- the line changes only with the count
                shown = key
                local line = t('janitor.stroke_hint', k.Keys[1].name, k.Keys[2].name) .. '  ' .. t('janitor.stroke_count', strokes, k.PerStage)
                AddTextEntry('campus_janitor_strokes', slow and line .. '  ' .. t('janitor.stroke_slow') or line)
            end
            BeginTextCommandDisplayHelp('campus_janitor_strokes')
            EndTextCommandDisplayHelp(0, false, false, -1)
            Wait(0)
        end
    end)
    local ended = chores.strokes(job.id, piece.id, { keys = k.Keys, perStage = k.PerStage, rules = { minGapMs = k.MinGapMs, maxGapMs = k.MaxGapMs },
        clip = cfg.Clips.mop, reach = 2.5,
        onStroke = function(accepted, count, perStage, why)
            if accepted then strokes = count % perStage elseif why == 'quick' then slowUntil = GetGameTimer() + 1200 end
        end })
    working = false
    if held then chores.unhold(held) end
    busy = false
    if ended ~= 'done' and ended ~= 'cancelled' then Campus.fail({ error = ended == 'no_tool' and 'janitor_no_mop' or ended }) end
end

local function collect(job, piece)
    local result = chores.collect(job.id, piece.id)
    if not result.ok then Campus.fail(result) end
end

local function help(id)
    local result = Campus.call('janitor:help', { id = id })
    if not result.ok then return Campus.fail(result) end
    Nui.notify('janitor.help_joined', 'success')
end

JanitorClient.kinds.flood = {
    target = { radius = 1.0, height = 0.3 }, -- the spot is on the floor: a low sphere over it

    -- On the incident's own spot: the sign (in its step always, so one without a sign hears to fetch it; while mopping
    -- only with one in hand) and help from detention. The valve has its own spot.
    incidentOptions = function(id)
        return {
            { name = 'janitor_flood_sign', label = t('janitor.flood_sign'), icon = 'fa-solid fa-triangle-exclamation',
                canInteract = function() return JanitorClient.working(id) and (step(id) == 'sign' or step(id) == 'mop' and JanitorClient.tools.sign == true) end,
                onSelect = function() CreateThread(function() placeSign(id) end) end },
            { name = 'janitor_flood_help', label = t('janitor.flood_help'), icon = 'fa-solid fa-hands-helping',
                canInteract = function() return LocalPlayer.state.collegeDetention ~= nil and not JanitorClient.working(id) and step(id) == 'mop' end,
                onSelect = function() CreateThread(function() help(id) end) end },
        }
    end,

    options = function(job, piece)
        local id = job.data.incident
        if piece.placed and piece.look ~= 'bucket' then
            return { { name = 'janitor_flood_collect', label = t('janitor.flood_collect'), icon = 'fa-solid fa-hand',
                canInteract = function() return step(id) == 'tidy' end, onSelect = function() CreateThread(function() collect(job, piece) end) end } }
        end
        if piece.placed then return nil end
        -- With the mop from the depot (a student helping from detention brings their own).
        return { { name = 'janitor_flood_mop', label = t('janitor.flood_mop'), icon = 'fa-solid fa-broom',
            canInteract = function() return not busy and step(id) == 'mop' and (JanitorClient.tools.mop == true or LocalPlayer.state.collegeDetention ~= nil) end,
            onSelect = function() CreateThread(function() mop(job, piece) end) end } }
    end,

    onView = function(view)
        if view.state == 'open' or view.state == 'claimed' then floods[view.id] = view else floods[view.id] = nil end
        spray(view)
        valve(view)
    end,

    -- The board's map button: the valve while it is the step (it may stand away from the spot).
    waypoint = function(view)
        local v = view.data and view.data.valve
        if v and view.steps and view.steps[view.step] == 'valve' then return v end
    end,
}

-- Slipping: running through a spill with no sign within three metres puts the player down for a moment.
local slipped = {}
CreateThread(function()
    while true do
        local wait, here = 1000, GetEntityCoords(cache.ped)
        for id, view in pairs(floods) do
            local c = view.coords
            if c and #(here - vector3(c.x, c.y, c.z)) < 30.0 then
                wait = 200
                local job = chores.job(view.data.job)
                if job and (IsPedRunning(cache.ped) or IsPedSprinting(cache.ped)) and not IsPedInAnyVehicle(cache.ped, false) then
                    for _, piece in ipairs(job.pieces) do
                        if not piece.placed and not piece.done and Chores.flat(here, piece) < 1.1 and (slipped[piece.id] or 0) < GetGameTimer() then
                            local signed = false
                            for _, other in ipairs(job.pieces) do
                                if other.placed and not other.done and other.look ~= 'bucket' and Chores.flat(other, piece) < 3.0 then signed = true end
                            end
                            slipped[piece.id] = GetGameTimer() + 10000
                            if not signed and math.random() < (rule.SlipChance or 0) then SetPedToRagdoll(cache.ped, 1500, 1800, 0, false, false, false) end
                        end
                    end
                end
            end
        end
        Wait(wait)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, handle in pairs(sprays) do StopParticleFxLooped(handle, false) end
end)
