-- Janitor incidents on the client: the depot and the bins, every incident as a place to take the work order (and a
-- blip for janitors), the pager when a new one comes, and the chores pieces each kind draws. The kinds add their
-- own effects through JanitorClient.kinds; the server decides every step.
if not Config.Janitor or not Config.Janitor.Enabled then return end

local cfg = Config.Janitor
local t = DL.locale.t
local incidents, blips = {}, {}

-- capped: today's pay limit reached (no orders taken); binActions: fn(bin uid) -> a target option
JanitorClient = { kinds = {}, janitor = false, capped = false, tools = {}, binActions = {} }
local kinds = JanitorClient.kinds

local function exists(name) return IsModelInCdimage(joaat(name)) end

function JanitorClient.model(names)
    for _, name in ipairs(names or {}) do
        if exists(name) then return name end
    end
end

-- The board's answer keeps what this player may do and holds.
function JanitorClient.refresh()
    local result = Campus.call('janitor:board')
    if result.ok then JanitorClient.janitor, JanitorClient.capped, JanitorClient.tools = result.janitor, result.capped == true, result.tools or {} end
    return result
end

-- The chores pieces of the incidents (spills, rats' traps, grass patches; a trap with its rat in).
local looks = {}
for _, kind in ipairs({ 'puddle', 'grass' }) do looks[kind] = { models = cfg.Models[kind], states = kind == 'puddle' and { 'large', 'medium', 'small' } or { 'tall', 'cut' } } end
for _, kind in ipairs({ 'sign', 'trap', 'trapFull', 'bucket', 'panel' }) do looks[kind] = { models = cfg.Models[kind] } end
looks.valve = { models = {}, point = true }

Campus.chores = Chores.client({
    anchors = Campus.world.anchors,
    call = function(name, data) return Campus.call('chores:' .. name, data) end,
    looks = looks,
    options = function(job, piece)
        local kind = job.data and kinds[job.data.kind]
        return kind and kind.options and kind.options(job, piece) or nil
    end,
    onView = function(job) local kind = job.data and kinds[job.data.kind] if kind and kind.onJob then kind.onJob(job) end end,
    onPiece = function(job, piece) local kind = job.data and kinds[job.data.kind] if kind and kind.onPiece then kind.onPiece(job, piece) end end,
    onClose = function(job) local kind = job.data and kinds[job.data.kind] if kind and kind.onJobClose then kind.onJobClose(job) end end,
    -- A load fell from the hands (a fall, a car, another one taken up): the kind whose prop it was deals with it.
    onDropped = function(prop) for _, kind in pairs(kinds) do if kind.onDropped then kind.onDropped(prop) end end end,
})

-- The depot ----------------------------------------------------------------------------------------------------

local function tool(name, take)
    local result = Campus.call('janitor:tool', { tool = name, take = take })
    if not result.ok then return Campus.fail(result) end
    JanitorClient.tools = result.tools or {}
    Nui.notify(take and 'janitor.tool_taken' or 'janitor.tool_returned', 'success', t('janitor.tool_' .. name))
end

Campus.kind('janitor_depot', function(record)
    local options = { { name = 'janitor_board', label = t('janitor.open_board'), icon = 'fa-solid fa-clipboard-list',
        canInteract = function() return JanitorClient.janitor end, onSelect = function() CreateThread(JanitorClient.openBoard) end } }
    for _, name in ipairs(cfg.Tools) do
        options[#options + 1] = { name = 'janitor_take_' .. name, label = t('janitor.take', t('janitor.tool_' .. name)), icon = 'fa-solid fa-toolbox',
            canInteract = function() return JanitorClient.janitor and not JanitorClient.tools[name] end, onSelect = function() CreateThread(function() tool(name, true) end) end }
        options[#options + 1] = { name = 'janitor_return_' .. name, label = t('janitor.return', t('janitor.tool_' .. name)), icon = 'fa-solid fa-box',
            canInteract = function() return JanitorClient.tools[name] == true end, onSelect = function() CreateThread(function() tool(name, false) end) end }
    end
    if (record.model or '') == '' then record.presentation, record.model = 'prop', JanitorClient.model(cfg.Models.depot) end
    return { options = options, distance = cfg.DepotReach }
end)

Campus.kind('janitor_bin', function(record)
    if (record.model or '') == '' then record.presentation, record.model = 'prop', JanitorClient.model(cfg.Models.bin) end
    local options = {}
    for _, action in ipairs(JanitorClient.binActions) do options[#options + 1] = action(record.uid) end
    return { options = options }
end)

-- Incidents ---------------------------------------------------------------------------------------------------

local SPRITES = { flood = { 405, 3 }, power = { 354, 46 }, rat = { 141, 21 }, lawn = { 469, 2 } }
local me = GetPlayerServerId(PlayerId())

-- The server names workers by server id (never by citizen id): this game finds itself among them.
local function mark(view)
    for _, w in ipairs(view and view.workers or {}) do w.mine = w.src == me end
    return view
end

local function mine(view)
    for _, w in ipairs(view.workers or {}) do
        if w.mine then return true end
    end
    return false
end

local function claim(view)
    local result = Campus.call('janitor:claim', { id = view.id })
    if result.error == 'janitor_capped' then JanitorClient.capped = true end -- today's limit: the option goes away
    if not result.ok then return Campus.fail(result) end
    incidents[view.id] = mark(result.view)
    Nui.notify('janitor.claimed', 'success', t('janitor.kind_' .. view.kind))
end

local function draw(view)
    local uid = 'janitor:incident:' .. view.id
    if blips[view.id] then RemoveBlip(blips[view.id]) blips[view.id] = nil end
    if view.state ~= 'open' and view.state ~= 'claimed' then return Campus.world.anchors.remove(uid) end
    local c = view.coords
    if not c then return end
    if JanitorClient.janitor then
        local look = SPRITES[view.kind] or { 1, 0 }
        local blip = AddBlipForCoord(c.x, c.y, c.z)
        SetBlipSprite(blip, look[1])
        SetBlipColour(blip, look[2])
        SetBlipScale(blip, 0.85)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(t('janitor.kind_' .. view.kind))
        EndTextCommandSetBlipName(blip)
        blips[view.id] = blip
    end
    local options = {
        { name = 'janitor_claim', label = t('janitor.claim'), icon = 'fa-solid fa-clipboard-check',
            canInteract = function() local v = incidents[view.id] return JanitorClient.janitor and not JanitorClient.capped and v ~= nil and not mine(v) end,
            onSelect = function() CreateThread(function() claim(incidents[view.id]) end) end },
    }
    local kind = kinds[view.kind]
    for _, option in ipairs(kind and kind.incidentOptions and kind.incidentOptions(view.id) or {}) do options[#options + 1] = option end
    -- revision: a new step only changes the options, refreshed in place (no gap until the next scan). A spot on the
    -- floor (a flood, a rat) is aimed at on a low sphere: a look at the ground there finds it every time.
    Campus.world.anchors.set(uid, { coords = { x = c.x, y = c.y, z = c.z, w = 0.0 }, presentation = 'point', distance = 3.0, revision = 0,
        targetSphere = kind and kind.target or nil, options = options })
end

local function apply(view)
    local before = incidents[view.id]
    local live = view.state == 'open' or view.state == 'claimed'
    incidents[view.id] = live and mark(view) or nil
    draw(view)
    local kind = kinds[view.kind]
    if kind and kind.onView then kind.onView(view, before) end
    -- A step done on an order this player works: the next one is told.
    local upNext = live and before and before.step ~= view.step and mine(view) and view.steps and view.steps[view.step]
    if upNext then Nui.notify('janitor.next_step', 'inform', t(('janitor.step_%s_%s'):format(view.kind, upNext))) end
    TriggerEvent('daddy_campuslife:incidentSeen')
end

RegisterNetEvent('daddy_campuslife:incident', apply)

-- A new work order (or one still waiting, remind): the pager beeps and the place goes on the map.
RegisterNetEvent('daddy_campuslife:janitor:dispatch', function(view)
    JanitorClient.janitor = true
    PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'Phone_SoundSet_Default', true)
    Nui.notify(view.remind and 'janitor.reminder' or 'janitor.dispatch', 'inform', t('janitor.kind_' .. view.kind), view.label ~= '' and view.label or t('janitor.somewhere'))
    apply(view)
end)

-- Hired, let go, on or off duty, a tool used or given back, today's limit reached: the targets and blips follow.
RegisterNetEvent('daddy_campuslife:janitor:access', function(janitor, tools, capped)
    JanitorClient.janitor, JanitorClient.tools, JanitorClient.capped = janitor == true, type(tools) == 'table' and tools or {}, capped == true
    for _, view in pairs(incidents) do draw(view) end
end)

function JanitorClient.incident(id) return incidents[id] end

-- Is this player working the incident (taken or helping)?
function JanitorClient.working(id)
    local view = incidents[id]
    return view ~= nil and mine(view)
end

-- A close panel: the camera on the thing, the server's game on screen dressed as it (skin), scored there. The camera
-- stands in front of the thing whichever way it faces (at.w; a panel faces along its -Y, as GTA's ATMs do).
local looking, lookingAt
function JanitorClient.panel(id, at, skin)
    local result = Campus.call('janitor:panelStart', { id = id })
    if not result.ok then return Campus.fail(result) end
    lookingAt = id
    looking = Campus.chores.closeLook({ coords = vector3(at.x, at.y, at.z + 0.6), from = vector3(0.0, -1.2, 0.3), aim = vector3(0.0, -0.1, 0.0),
        heading = at.w or 0.0, reach = 4.0, onClose = function() if Nui.isOpen('campus.panel') then Nui.close() end end })
    Nui.open('campus.panel', { game = result.game, skin = skin })
end

Nui.onClose('campus.panel', function()
    if looking then looking.close() looking = nil end
end)

RegisterNUICallback('janitor:panelFinish', function(data, cb)
    local result = Campus.call('janitor:panelFinish', type(data) == 'table' and data or {})
    cb(result)
    if result.ok then Nui.notify(result.passed and 'janitor.panel_done' or 'janitor.panel_again', result.passed and 'success' or 'error') end
end)

-- A wrong move in the game (a breaker out of order): the kind shows it in the world at once.
RegisterNUICallback('janitor:panelFault', function(_, cb)
    cb({ ok = true })
    local view = lookingAt and incidents[lookingAt]
    local kind = view and kinds[view.kind]
    if kind and kind.onFault then kind.onFault(lookingAt) end
end)
function JanitorClient.mine(view) return mine(view) end

-- The work order board: a clipboard in hand, the orders on screen; the player can walk with it up.
local held
local function boardData()
    local result = JanitorClient.refresh()
    for _, view in ipairs(result.ok and result.incidents or {}) do
        incidents[view.id] = mark(view)
        draw(view)
    end
    return result
end

local function closeBoard()
    if held then Campus.chores.unhold(held) held = nil end
    ClearPedSecondaryTask(cache.ped)
    SetNuiFocusKeepInput(false)
end

function JanitorClient.openBoard()
    if Nui.isOpen('campus.board') then return Nui.close() end
    local result = boardData()
    if not result.ok then return Campus.fail(result) end
    if not result.janitor and not result.admin then return Campus.fail({ error = 'no_permission' }) end -- janitors on duty and staff
    Nui.open('campus.board', result)
    SetNuiFocusKeepInput(true)
    local model = JanitorClient.model(cfg.Models.board)
    if model then held = Campus.chores.hold({ model = model, bone = 18905, pos = vec3(0.1, 0.02, 0.08), rot = vec3(-130.0, -50.0, 0.0) }) end
    Campus.chores.play('amb@world_human_clipboard@male@base', 'base', -1, 49)
    CreateThread(function()
        while Nui.isOpen('campus.board') do
            for _, control in ipairs({ 1, 2, 24, 25, 37, 44, 140, 141, 142, 200 }) do DisableControlAction(0, control, true) end
            if IsPedInAnyVehicle(cache.ped, false) or IsEntityDead(cache.ped) then Nui.close() end
            Wait(0)
        end
    end)
end

Nui.onClose('campus.board', closeBoard)

-- What the board's buttons do: take or join an order, leave it, mark it on the map; staff cancel one.
local function answer(cb, result) cb(result.ok and { ok = true, data = boardData() } or result) end
RegisterNUICallback('janitor:boardClaim', function(data, cb)
    local result = Campus.call('janitor:claim', { id = data.id })
    if result.error == 'janitor_capped' then JanitorClient.capped = true end
    if not result.ok then Campus.fail(result) end
    answer(cb, result)
end)
RegisterNUICallback('janitor:boardLeave', function(data, cb)
    local result = Campus.call('janitor:leave', { id = data.id })
    if not result.ok then Campus.fail(result) end
    answer(cb, result)
end)
RegisterNUICallback('janitor:boardCancel', function(data, cb)
    local view = incidents[tonumber(data.id)]
    local result = Campus.call('janitor:cancel', { id = data.id })
    if result.ok then Nui.notify('janitor.cancelled', 'success', view and t('janitor.kind_' .. view.kind) or '') else Campus.fail(result) end
    answer(cb, result)
end)
-- The map shows where the work is now: a kind may name another spot than the place (a lawn's mower stand).
RegisterNUICallback('janitor:boardMap', function(data, cb)
    local view = incidents[tonumber(data.id)]
    local kind = view and kinds[view.kind]
    local at = view and (kind and kind.waypoint and kind.waypoint(view) or view.coords)
    if at then SetNewWaypoint(at.x, at.y) Nui.notify('janitor.board_marked', 'inform') end
    cb({ ok = true })
end)

-- An open board follows the orders as they change.
local pushing = false
AddEventHandler('daddy_campuslife:incidentSeen', function()
    if pushing or not Nui.isOpen('campus.board') then return end
    pushing = true
    SetTimeout(400, function()
        pushing = false
        if Nui.isOpen('campus.board') then Nui.send('janitor:board', boardData()) end
    end)
end)

RegisterCommand(cfg.Command, function() CreateThread(JanitorClient.openBoard) end, false)

-- What this player may do and holds, and the incidents there are: asked when a character comes in (or this starts),
-- again with a growing wait while the server does not answer (it may be starting too); spread so a restart is no rush.
local welcoming
local function welcome()
    local token = {}
    welcoming = token
    Wait(2000 + math.random(0, 6000))
    local delay = 5000
    for _ = 1, 8 do
        if welcoming ~= token then return end
        local me = Campus.call('janitor:me')
        if me.ok then JanitorClient.janitor, JanitorClient.capped, JanitorClient.tools = me.janitor == true, me.capped == true, me.tools or {} end
        local seen = me.ok and Campus.call('janitor:incidents') or me
        if welcoming ~= token then return end
        if seen.ok then
            for _, view in ipairs(seen.incidents or {}) do apply(view) end
            return
        end
        Wait(delay)
        delay = math.min(delay * 2, 60000)
    end
end

CreateThread(function()
    DL.fw.awaitLogin()
    welcome()
end)
DL.fw.onLoaded(function() CreateThread(welcome) end)

-- Off the character (a relog, the selection screen): the next one starts with no janitor rights, tools, pins or boards.
DL.fw.onUnloaded(function()
    welcoming = nil
    JanitorClient.janitor, JanitorClient.capped, JanitorClient.tools = false, false, {}
    if Nui.isOpen('campus.board') or Nui.isOpen('campus.panel') then Nui.close() end
    for _, view in pairs(incidents) do draw(view) end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, blip in pairs(blips) do RemoveBlip(blip) end
end)
