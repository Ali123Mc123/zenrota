-- A rat on the client: the rats run about their area and flee from people (whoever's game owns a rat moves it),
-- one walks into a trap when the server says so; the janitor sets traps, picks up a full one and throws it into a
-- big bin, or takes an empty one back.
if not Config.Janitor or not Config.Janitor.Enabled then return end

local cfg = Config.Janitor
local rule = cfg.Events.rat
local t = DL.locale.t
local chores = Campus.chores
local nests, moving = {}, {} -- incident id -> view; rat net id -> what it was last told to do
local busy, carried, trap = false, nil, nil -- carried: the job id of the full trap in hand; trap: its prop

local function step(id)
    local view = nests[id]
    return view and view.steps and view.steps[view.step]
end
local function full(view, pieceId)
    for _, id in ipairs(view and view.data and view.data.full or {}) do if id == pieceId then return true end end
    return false
end

-- Traps --------------------------------------------------------------------------------------------------------

-- A trap from the depot, put down inside the rat area (the preview keeps to the server's reach).
local function setTrap(id)
    local view = nests[id]
    if not view or busy then return end
    if JanitorClient.tools.trap ~= true then return Campus.fail({ error = 'janitor_no_trap' }) end -- before the preview: the depot first
    busy = true
    local model = JanitorClient.model(cfg.Models.trap)
    local result = model and chores.place(view.data.job, model, function(show)
        if show then lib.showTextUI(t('janitor.place_trap_hint')) else lib.hideTextUI() end
    end, 2.8) or { ok = false, error = 'no_tool' }
    busy = false
    if not result.ok and result.error ~= 'cancelled' then Campus.fail({ error = result.error == 'no_tool' and 'janitor_no_trap' or result.error }) end
end

-- Picking a trap up: a full one into the hands for the bin, an empty one back to the tools (the server tells the tools).
local function pickUp(job, piece, isFull)
    local result = chores.collect(job.id, piece.id)
    if not result.ok then return Campus.fail(result) end
    if not isFull then return end
    local hand = cfg.Hands.trap
    trap = chores.carry({ model = JanitorClient.model(cfg.Models.trapFull), bone = hand.bone, pos = hand.pos, rot = hand.rot })
    carried = job.id
    Nui.notify('janitor.rat_carry', 'inform')
end

-- Lets go of the full trap here (its order ended, or the server put it back).
local function letGo()
    if not carried then return end
    if trap and chores.carried() == trap then chores.drop() end
    carried, trap = nil, nil
end

-- A full trap goes into any big bin near, while its order is still on.
JanitorClient.binActions[#JanitorClient.binActions + 1] = function(binUid)
    return { name = 'janitor_rat_throw', label = t('janitor.rat_throw'), icon = 'fa-solid fa-dumpster',
        canInteract = function() return carried ~= nil and chores.carried() ~= nil and chores.job(carried) ~= nil end,
        onSelect = function()
            CreateThread(function()
                local result = chores.deliver(carried, binUid)
                if not result.ok then return Campus.fail(result) end
                carried, trap = nil, nil
            end)
        end }
end

JanitorClient.kinds.rat = {
    target = { radius = 1.0, height = 0.3 }, -- the spot is on the floor: a low sphere over it

    -- Always while catching, so one without a trap hears to fetch one from the depot.
    incidentOptions = function(id)
        return {
            { name = 'janitor_rat_trap', label = t('janitor.rat_trap'), icon = 'fa-solid fa-box',
                canInteract = function() return JanitorClient.working(id) and step(id) == 'catch' end,
                onSelect = function() CreateThread(function() setTrap(id) end) end },
        }
    end,

    options = function(job, piece)
        if not piece.placed or piece.done then return nil end
        local id = job.data.incident
        return {
            { name = 'janitor_rat_full', label = t('janitor.rat_full'), icon = 'fa-solid fa-hand',
                canInteract = function() return full(nests[id], piece.id) and chores.carried() == nil end,
                onSelect = function() CreateThread(function() pickUp(job, piece, true) end) end },
            { name = 'janitor_rat_back', label = t('janitor.rat_back'), icon = 'fa-solid fa-rotate-left',
                canInteract = function() return JanitorClient.working(id) and not full(nests[id], piece.id) end,
                onSelect = function() CreateThread(function() pickUp(job, piece, false) end) end },
        }
    end,

    onView = function(view)
        nests[view.id] = (view.state == 'open' or view.state == 'claimed') and view or nil
    end,

    -- The full trap fell (a fall, a car, another load taken up): the server puts it back where the rat was caught.
    onDropped = function(prop)
        if not carried or prop ~= trap then return end
        carried, trap = nil, nil
        CreateThread(function()
            if Campus.call('janitor:ratLost', {}).ok then Nui.notify('janitor.rat_dropped', 'inform') end
        end)
    end,

    onJobClose = function(job) if carried == job.id then letGo() end end,
}

-- The server put the trap back (this player left the order or the character).
RegisterNetEvent('daddy_campuslife:janitor:trapGone', function(id)
    local view = nests[id]
    if not view or not view.data or view.data.job == carried then letGo() end
end)

DL.fw.onUnloaded(letGo)

-- The rats: a rat this game owns wanders its area, runs from a person close by, walks to its trap when lured.
local function drive(view, rat)
    if not NetworkDoesNetworkIdExist(rat.net) then return end
    local ped = NetToPed(rat.net)
    if ped == 0 or not DoesEntityExist(ped) or NetworkGetEntityOwner(ped) ~= PlayerId() then return end
    local m = moving[rat.net]
    if not m then
        m = { at = 0 }
        moving[rat.net] = m
        SetBlockingOfNonTemporaryEvents(ped, true)
        local c = GetEntityCoords(ped)
        local found, z = GetGroundZFor_3dCoord(c.x, c.y, c.z + 2.0, false)
        if found then SetEntityCoordsNoOffset(ped, c.x, c.y, z, false, false, false) end
    end
    local now = GetGameTimer()
    if rat.trap then
        local piece = chores.piece(view.data.job, rat.trap)
        if piece and m.doing ~= 'trap' then
            m.doing = 'trap'
            TaskGoToCoordAnyMeans(ped, piece.x, piece.y, piece.z, 1.0, 0, false, 786603, 0xbf800000)
        end
        return
    end
    local near = #(GetEntityCoords(cache.ped) - GetEntityCoords(ped)) < (rule.Flee or 4.0)
    if near and (m.doing ~= 'flee' or now > m.at) then
        m.doing, m.at = 'flee', now + 3000
        TaskSmartFleePed(ped, cache.ped, 12.0, 3000, false, false)
    elseif not near and (m.doing ~= 'wander' or now > m.at) then
        local c = view.data.center
        m.doing, m.at = 'wander', now + 20000
        TaskWanderInArea(ped, c.x, c.y, c.z, view.data.radius, 1.0, 1.0)
    end
end

CreateThread(function()
    while true do
        local wait = 2000
        local here = GetEntityCoords(cache.ped)
        for _, view in pairs(nests) do
            local c = view.data and view.data.center
            if c and #(here - vector3(c.x, c.y, c.z)) < 120.0 then
                wait = 500
                for _, rat in ipairs(view.data.rats or {}) do drive(view, rat) end
            end
        end
        Wait(wait)
    end
end)
