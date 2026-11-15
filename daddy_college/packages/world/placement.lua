-- The place editor, like a level editor: a free camera and the mouse as the pointer. A spot is clicked where it
-- stands, a sphere and a box are drawn on the floor, an area corner by corner; places saved nearby show faintly.
--   World.placement.start({ shape = 'polygon', reach = 150, maxPoints = 32 }, { hud = fn, done = fn })
-- done(result) gets { shape, coords {x,y,z,w}, center, size, radius, rotation, points, minZ, maxZ, items? } or nil.
World = World or {}
World.placement = {}

-- Controls bound to one key only: 177 would also fire on Escape and the right mouse button.
local KEY = {
    click = 24, look = 25, finish = 191, accept = 201, cancel = 200, undo = 194, delete = 214,
    forward = 32, back = 33, left = 34, right = 35, up = 38, down = 44, fast = 21, fine = 19, snap = 36, raise = 10, lower = 11,
}
local MOVE, FAST, FINE, LOOK = 8.0, 4.0, 0.2, 4.0 -- camera metres a second, Shift and Alt multipliers, look speed
local GRID, ANGLE, HOVER = 0.25, 15.0, 0.02       -- Ctrl snapping; how near the cursor grabs a corner (screen heights)
local GHOST_PED = 'a_m_y_business_01'

local shapes = World.shapes
local state

local function pressed(control) return IsDisabledControlJustPressed(0, control) end
local function held(control) return IsDisabledControlPressed(0, control) end

-- One wheel notch this frame: 1 up, -1 down (with the cursor shown the game reports it on other controls).
local function wheel()
    if pressed(15) or pressed(241) then return 1 end
    if pressed(14) or pressed(242) then return -1 end
    return 0
end

-- A step made coarse with Shift and fine with Alt.
local function scaled(step)
    if held(KEY.fast) then return step * 5.0 end
    if held(KEY.fine) then return step * 0.2 end
    return step
end

local function plain(p, w) return { x = p.x, y = p.y, z = p.z, w = w } end
local function flat(a, b) return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2) end

-- A problem shown for a moment, e.g. why ENTER did nothing.
local function flash(problem)
    if problem then state.flash, state.flashUntil = problem, GetGameTimer() + 2500 end
end

-- The ghost: a see-through copy of the ped or prop being placed --------------------------------------

local function spawnGhost(request)
    if request.presentation ~= 'ped' and request.presentation ~= 'prop' then return nil end
    local isPed = request.presentation == 'ped'
    local hash = joaat((request.model or '') ~= '' and request.model or GHOST_PED)
    if not IsModelInCdimage(hash) or not pcall(lib.requestModel, hash, 5000) then return nil end
    local at = GetEntityCoords(cache.ped) - vector3(0.0, 0.0, 10.0)
    pcall(function() exports['FeloxAC']:CreatePed(hash) end) --[[FeloxAC:auto]]
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local entity = isPed and CreatePed(4, hash, at.x, at.y, at.z, 0.0, false, false) or CreateObjectNoOffset(hash, at.x, at.y, at.z, false, false, false)
    SetModelAsNoLongerNeeded(hash)
    if not entity or entity == 0 then return nil end
    SetEntityAlpha(entity, 170, false)
    SetEntityCollision(entity, false, false)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    if isPed then SetBlockingOfNonTemporaryEvents(entity, true) end
    return entity
end

-- Peds stand on the point (their origin is a metre up); a scenario plays as it will in game.
local function moveGhost(at, heading)
    local ghost = state.ghost
    if not ghost or not DoesEntityExist(ghost) then return end
    SetEntityVisible(ghost, at ~= nil, false)
    if not at then return end
    local isPed = IsEntityAPed(ghost)
    SetEntityCoordsNoOffset(ghost, at.x, at.y, isPed and at.z + 1.0 or at.z, false, false, false)
    SetEntityHeading(ghost, heading)
    local scenario = state.request.scenario or ''
    if isPed and scenario ~= '' and not IsPedUsingAnyScenario(ghost) then
        TaskStartScenarioAtPosition(ghost, scenario, at.x, at.y, at.z + 1.0, heading, 0, true, true)
    end
end

-- Camera and pointer ---------------------------------------------------------------------------------

-- WASD moves over the floor plane, Q/E down and up, right mouse held looks around; it stays within reach.
local function moveCamera()
    local pose = DL.freecam.pose()
    if not pose then return end
    local coords, rotation = pose.coords, pose.rotation
    if held(KEY.look) then
        local pitch = math.max(-89.0, math.min(89.0, rotation.x - GetDisabledControlNormal(0, 2) * LOOK))
        rotation = vector3(pitch, 0.0, rotation.z - GetDisabledControlNormal(0, 1) * LOOK)
    end
    local z = math.rad(rotation.z)
    local forward, right = vector3(-math.sin(z), math.cos(z), 0.0), vector3(math.cos(z), math.sin(z), 0.0)
    local move = forward * ((held(KEY.forward) and 1 or 0) - (held(KEY.back) and 1 or 0))
        + right * ((held(KEY.right) and 1 or 0) - (held(KEY.left) and 1 or 0))
        + vector3(0.0, 0.0, (held(KEY.up) and 1 or 0) - (held(KEY.down) and 1 or 0))
    coords = coords + move * (MOVE * GetFrameTime() * (held(KEY.fast) and FAST or held(KEY.fine) and FINE or 1.0))
    local away = coords - state.origin
    if #away > state.reach then coords = state.origin + away * (state.reach / #away) end
    DL.freecam.place(coords, rotation)
end

-- Opens the camera looking down at a place being edited, or from where the player looks.
local function openCamera(target)
    local coords, rotation = GetGameplayCamCoord(), GetGameplayCamRot(2)
    if target and #(vector3(target.x, target.y, target.z) - state.origin) < state.reach then
        local z = math.rad(rotation.z)
        coords = vector3(target.x + math.sin(z) * 7.0, target.y - math.cos(z) * 7.0, target.z + 6.0)
        rotation = vector3(-38.0, 0.0, rotation.z)
    end
    DL.freecam.start({ coords = coords, rotation = rotation, fov = GetGameplayCamFov() })
end

-- The point under the cursor (snapped to the grid with Ctrl) and why it cannot be used, if it cannot.
local function aim()
    local hit = World.cursor.hit(state.reach * 2.0, state.ghost)
    if not hit then return nil, 'no_surface' end
    if held(KEY.snap) then hit = vector3(shapes.snap(hit.x, GRID), shapes.snap(hit.y, GRID), hit.z) end
    if #(hit - state.origin) > state.reach then return hit, 'too_far' end
    return hit
end

local function usable() return state.aim ~= nil and state.aimProblem == nil end

-- Tools: one per shape --------------------------------------------------------------------------------
-- Each has: step() for the HUD, click(), wheel(notch), undo(), piece() (the finished shape or nil and why),
-- draw(color) and values() for the HUD. reset() starts the next shape of a batch.

local finish, complete

local TOOLS = {}

TOOLS.point = {
    step = function() return state.batch and 'point_batch' or 'point' end,
    at = function() return state.aim and state.aim + vector3(0.0, 0.0, state.lift) end,
    piece = function()
        if not usable() then return nil, state.aimProblem end
        local at = TOOLS.point.at()
        return { shape = 'point', coords = plain(at, state.heading), center = plain(at), rotation = 0.0 }
    end,
    click = function()
        local piece, problem = TOOLS.point.piece()
        if piece then complete(piece) else flash(problem) end
    end,
    -- The wheel turns it (Ctrl: by 15 degrees); PgUp and PgDn lift it off the surface.
    wheel = function(notch)
        if held(KEY.snap) then
            state.heading = (shapes.snap(state.heading, ANGLE) + notch * ANGLE) % 360
        else
            state.heading = (state.heading + notch * scaled(5.0)) % 360
        end
    end,
    hold = function()
        local d = (held(KEY.raise) and 1 or 0) - (held(KEY.lower) and 1 or 0)
        if d ~= 0 then state.lift = state.lift + d * scaled(0.5) * GetFrameTime() end
    end,
    undo = function() return false end,
    reset = function() end,
    ghost = function() return TOOLS.point.at(), state.heading end,
    draw = function(color)
        local at = TOOLS.point.at()
        if not at then return end
        World.draw.dot(at.x, at.y, at.z + 0.03, color, 0.18)
        local h = math.rad(state.heading)
        World.draw.line(at, { x = at.x - math.sin(h) * 0.8, y = at.y + math.cos(h) * 0.8, z = at.z + 0.03 }, color, 255)
        if state.lift ~= 0.0 then World.draw.line(state.aim, at, color, 160) end
    end,
    values = function() return { heading = math.floor(state.heading + 0.5), lift = state.lift } end,
}

TOOLS.sphere = {
    step = function() return state.center and 'sphere_radius' or 'sphere_center' end,
    piece = function()
        if not state.center then return nil, 'unfinished' end
        return { shape = 'sphere', coords = plain(state.center, state.heading), center = plain(state.center), radius = state.radius }
    end,
    click = function()
        if not usable() then return flash(state.aimProblem) end
        if not state.center then
            state.center, state.radiusSet = plain(state.aim), false
        else
            complete(TOOLS.sphere.piece())
        end
    end,
    wheel = function(notch)
        state.radius = math.max(0.25, state.radius + notch * scaled(0.1))
        state.radiusSet = true
    end,
    -- Until the wheel sets it, the radius follows the cursor.
    hold = function()
        if not state.center or state.radiusSet or not state.aim then return end
        local r = math.max(0.25, flat(state.center, state.aim))
        state.radius = held(KEY.snap) and math.max(GRID, shapes.snap(r, GRID)) or r
    end,
    undo = function()
        if not state.center then return false end
        state.center = nil
        return true
    end,
    reset = function() state.center = nil end,
    ghost = function() return state.center or state.aim, state.heading end,
    draw = function(color)
        local c = state.center or state.aim
        if not c then return end
        World.draw.shape({ shape = 'sphere', center = c, radius = state.radius }, { color = color, focused = true })
        World.draw.dot(c.x, c.y, c.z, color, 0.12)
    end,
    values = function() return { radius = state.radius } end,
}

-- A box: two clicks for one side, a third for the depth, then the wheel for the height.
local function boxNow()
    if not state.a or not state.b then return nil end
    return shapes.box(state.a, state.b, state.depthAt or state.aim, state.height)
end

-- With Ctrl the side turns by 15 degrees and grows by the grid.
local function sideEnd()
    local a, p = state.a, state.aim
    if not held(KEY.snap) then return plain(p) end
    local angle = math.rad(shapes.snap(math.deg(math.atan(p.y - a.y, p.x - a.x)), ANGLE))
    local length = shapes.snap(flat(a, p), GRID)
    return { x = a.x + math.cos(angle) * length, y = a.y + math.sin(angle) * length, z = p.z }
end

TOOLS.box = {
    step = function()
        if not state.a then return 'box_a' end
        if not state.b then return 'box_b' end
        if not state.depthAt then return 'box_depth' end
        return 'box_height'
    end,
    piece = function()
        local box = state.depthAt and boxNow()
        if not box then return nil, 'unfinished' end
        if box.size.x < 0.3 or box.size.y < 0.3 then return nil, 'too_small' end
        return { shape = 'box', coords = plain(box.base, box.rotation), center = box.center, size = box.size, rotation = box.rotation }
    end,
    click = function()
        if state.depthAt then
            local piece, problem = TOOLS.box.piece()
            return piece and complete(piece) or flash(problem)
        end
        if not usable() then return flash(state.aimProblem) end
        if not state.a then
            state.a = plain(state.aim)
        elseif not state.b then
            local b = sideEnd()
            if flat(state.a, b) < 0.3 then return flash('too_small') end
            state.b = b
        else
            local box = boxNow()
            if not box or box.size.y < 0.3 then return flash('too_small') end
            state.depthAt = plain(state.aim)
        end
    end,
    wheel = function(notch) state.height = math.max(0.3, state.height + notch * scaled(0.25)) end,
    hold = function() end,
    undo = function()
        if state.depthAt then state.depthAt = nil
        elseif state.b then state.b = nil
        elseif state.a then state.a = nil
        else return false end
        return true
    end,
    reset = function() state.a, state.b, state.depthAt = nil, nil, nil end,
    ghost = function()
        local box = boxNow()
        if box then return box.base, box.rotation end
        return state.a or state.aim, 0.0
    end,
    draw = function(color)
        local box = boxNow()
        if box then
            World.draw.shape({ shape = 'box', center = box.center, size = box.size, rotation = box.rotation }, { color = color, focused = true })
        elseif state.a and state.aim then
            local b = sideEnd()
            World.draw.line(state.a, b, color, 255)
            World.draw.dot(b.x, b.y, b.z, color, 0.14)
        end
        if state.a then World.draw.dot(state.a.x, state.a.y, state.a.z, color, 0.16) end
        if not state.a and state.aim then World.draw.dot(state.aim.x, state.aim.y, state.aim.z, color, 0.14) end
    end,
    values = function()
        local box = boxNow()
        if box then return { size = box.size, rotation = math.floor(box.rotation + 0.5) } end
        if state.a and state.aim then return { length = flat(state.a, sideEnd()) } end
        return {}
    end,
}

-- An area: corners are clicked, dragged, added on a side's middle and deleted. Floor and ceiling follow the
-- corners (a metre under the lowest, four over the highest) until the wheel sets them.
local function settleHeights()
    if #state.points == 0 then return end
    local low, high = shapes.heights(state.points)
    if not state.floorSet then state.minZ = low - 1.0 end
    if not state.ceilingSet then state.maxZ = high + 4.0 end
    if state.maxZ < state.minZ + 0.5 then state.maxZ = state.minZ + 0.5 end
end

local function sideMiddle(i)
    local a, b = state.points[i], state.points[i % #state.points + 1]
    return { x = (a.x + b.x) * 0.5, y = (a.y + b.y) * 0.5, z = (a.z + b.z) * 0.5 }
end

-- The corner, or failing that the side middle, under the cursor.
local function hover()
    local best, kind, index = HOVER, nil, nil
    for i, p in ipairs(state.points) do
        local d = World.cursor.distanceTo(p.x, p.y, p.z)
        if d and d < best then best, kind, index = d, 'corner', i end
    end
    if kind then return kind, index end
    local sides = #state.points >= 3 and #state.points or #state.points - 1
    for i = 1, sides do
        local m = sideMiddle(i)
        local d = World.cursor.distanceTo(m.x, m.y, m.z)
        if d and d < best then best, kind, index = d, 'side', i end
    end
    return kind, index
end

local function polygonProblem()
    if #state.points < 3 then return 'too_few' end
    if shapes.crossing(state.points) then return 'crossing' end
end

TOOLS.polygon = {
    step = function() return #state.points < 3 and 'polygon_start' or 'polygon' end,
    piece = function()
        local problem = polygonProblem()
        if problem then return nil, problem end
        local points = {}
        for i, p in ipairs(state.points) do points[i] = { x = p.x, y = p.y } end
        local middle = shapes.middle(state.points)
        return { shape = 'polygon', points = points, minZ = state.minZ, maxZ = state.maxZ, center = middle, coords = plain(middle) }
    end,
    click = function() end,
    -- Pressing on a corner grabs it, on a side's middle adds one there and grabs it, elsewhere adds one at the end.
    hold = function()
        if state.drag then
            if not held(KEY.click) then state.drag = nil
            elseif usable() then state.points[state.drag] = plain(state.aim) end
            return settleHeights()
        end
        state.hoverKind, state.hoverIndex = hover()
        if pressed(KEY.delete) and state.hoverKind == 'corner' then
            table.remove(state.points, state.hoverIndex)
            state.hoverKind = nil
            return settleHeights()
        end
        if not pressed(KEY.click) then return end
        if state.hoverKind == 'corner' then
            state.drag = state.hoverIndex
        elseif state.hoverKind == 'side' and #state.points < state.maxPoints then
            table.insert(state.points, state.hoverIndex + 1, sideMiddle(state.hoverIndex))
            state.drag = state.hoverIndex + 1
        elseif #state.points >= state.maxPoints then
            flash('too_many')
        elseif not usable() then
            flash(state.aimProblem)
        else
            state.points[#state.points + 1] = plain(state.aim)
        end
        settleHeights()
    end,
    -- The wheel moves the ceiling, with Shift the floor (Alt: fine).
    wheel = function(notch)
        local step = notch * (held(KEY.fine) and 0.05 or 0.25)
        if held(KEY.fast) then
            state.minZ, state.floorSet = math.min(state.minZ + step, state.maxZ - 0.5), true
        else
            state.maxZ, state.ceilingSet = math.max(state.maxZ + step, state.minZ + 0.5), true
        end
    end,
    undo = function()
        if #state.points == 0 then return false end
        table.remove(state.points)
        settleHeights()
        return true
    end,
    reset = function() end,
    ghost = function() return nil end,
    draw = function(color)
        local points, n = state.points, #state.points
        if n >= 3 then
            World.draw.shape({ shape = 'polygon', points = points, minZ = state.minZ, maxZ = state.maxZ }, { color = color, corners = false })
        end
        for i, p in ipairs(points) do
            local hot = state.drag == i or (state.hoverKind == 'corner' and state.hoverIndex == i)
            World.draw.handle(p, state.minZ, hot and World.draw.colors.focused or color, hot)
            World.draw.label(p.x, p.y, p.z + 0.45, tostring(i), color)
            if i < n then World.draw.line(p, points[i + 1], color, 255) end
        end
        if state.hoverKind == 'side' then
            local m = sideMiddle(state.hoverIndex)
            World.draw.handle(m, nil, World.draw.colors.focused, true)
        end
        -- The corner a click would add: from the last corner to the cursor and on to the first.
        if not state.drag and not state.hoverKind and state.aim and n > 0 and n < state.maxPoints then
            World.draw.line(points[n], state.aim, color, 140)
            if n >= 2 then World.draw.line(state.aim, points[1], color, 90) end
        elseif n >= 3 then
            World.draw.line(points[n], points[1], color, 255)
        end
        if state.aim and not state.hoverKind then World.draw.dot(state.aim.x, state.aim.y, state.aim.z, color, 0.12) end
    end,
    values = function()
        return { corners = #state.points, maxPoints = state.maxPoints, area = #state.points >= 3 and shapes.area(state.points) or 0,
            minZ = state.minZ, maxZ = state.maxZ, hover = state.drag and 'drag' or state.hoverKind }
    end,
}

local function tool() return TOOLS[state.shape] or TOOLS.point end

-- Ending ----------------------------------------------------------------------------------------------

local function stop()
    local ended = state
    state = nil
    DL.freecam.stop()
    if ended.ghost and DoesEntityExist(ended.ghost) then DeleteEntity(ended.ghost) end
    ended.hooks.hud({ visible = false })
    return ended
end

local function cancel()
    if state then stop().hooks.done(nil) end
end

finish = function(result) stop().hooks.done(result) end

-- A finished shape: saved at once, or added to the batch while the editor goes on.
complete = function(piece)
    if not piece then return end
    if not state.batch then return finish(piece) end
    if #state.items >= state.batchLimit then return flash('too_many') end
    state.items[#state.items + 1] = piece
    tool().reset()
end

-- ENTER: the batch so far, or the shape as drawn when it is complete.
local function accept()
    if state.batch then
        if #state.items == 0 then return flash('nothing') end
        return finish({ shape = state.shape, items = state.items })
    end
    local piece, problem = tool().piece()
    if piece then finish(piece) else flash(problem) end
end

-- Every frame -----------------------------------------------------------------------------------------

local function drawFrame(problem)
    if state.request.backdrop then state.request.backdrop() end
    for _, item in ipairs(state.items) do
        World.draw.shape(DL.geo.shape(item) or item, { color = World.draw.colors.valid, faint = true })
        World.draw.dot(item.coords.x, item.coords.y, item.coords.z + 0.03, World.draw.colors.valid, 0.16)
    end
    tool().draw(problem and World.draw.colors.invalid or state.color)
    local at, heading = tool().ghost()
    moveGhost(at, heading or 0.0)
end

local function sendHud(problem)
    local now = GetGameTimer()
    if now - (state.hudAt or 0) < 100 then return end
    state.hudAt = now
    local data = tool().values()
    data.visible, data.shape, data.label, data.step, data.problem = true, state.shape, state.request.label, tool().step(), problem
    data.batch, data.count, data.looking, data.snap, data.reach = state.batch, #state.items, held(KEY.look), held(KEY.snap), state.reach
    data.distance = state.aim and math.floor(#(state.aim - state.origin) + 0.5) or nil
    state.hooks.hud(data)
end

local function frame()
    DisableAllControlActions(0)
    EnableControlAction(0, 249, true) -- push to talk
    moveCamera()
    local t = tool()
    if held(KEY.look) then
        state.aim, state.aimProblem = nil, nil
    else
        state.aim, state.aimProblem = aim()
        t.hold()
        if t ~= TOOLS.polygon and pressed(KEY.click) then t.click() end
        if not state then return end
        local notch = wheel()
        if notch ~= 0 then t.wheel(notch) end
        World.cursor.show(state.drag and 4 or state.hoverKind and 3 or 1)
    end
    if not state then return end
    if pressed(KEY.undo) then t.undo() end
    if pressed(KEY.finish) or pressed(KEY.accept) then accept() end
    if not state then return end
    if pressed(KEY.cancel) or IsEntityDead(cache.ped) then return cancel() end

    local flashing = state.flash and GetGameTimer() < state.flashUntil and state.flash
    local problem = flashing or (state.shape == 'polygon' and #state.points >= 4 and shapes.crossing(state.points) and 'crossing') or state.aimProblem
    drawFrame(problem)
    sendHud(problem)
end

-- Starting --------------------------------------------------------------------------------------------

-- request: { shape, presentation?, model?, scenario?, label?, heading?, existing?, batch?, reach?, maxPoints?,
-- batchLimit?, color?, backdrop? (draws the other places each frame) }. False when an editor is already open.
function World.placement.start(request, hooks)
    if state then return false end
    local existing = request.existing or {}
    local origin = GetEntityCoords(cache.ped)
    local size = existing.size or {}
    state = {
        request = request, hooks = hooks, shape = request.shape or 'point', color = request.color or World.draw.colors.valid,
        origin = origin, reach = tonumber(request.reach) or 150.0, batch = request.batch == true, items = {},
        maxPoints = request.maxPoints or 32, batchLimit = request.batchLimit or 64,
        heading = tonumber(request.heading) or (GetGameplayCamRot(2).z + 180.0) % 360, lift = 0.0,
        radius = tonumber(existing.radius) or 1.0, height = tonumber(size.z) or 2.5, points = {},
    }
    for _, p in ipairs(existing.points or {}) do
        if tonumber(p.x) and tonumber(p.y) then state.points[#state.points + 1] = { x = tonumber(p.x), y = tonumber(p.y), z = 0.0 } end
    end
    -- An area being edited keeps its floor and ceiling; its corners sit a metre over the floor.
    if #state.points >= 3 and tonumber(existing.minZ) and tonumber(existing.maxZ) then
        state.minZ, state.maxZ, state.floorSet, state.ceilingSet = tonumber(existing.minZ), tonumber(existing.maxZ), true, true
        for _, p in ipairs(state.points) do p.z = state.minZ + 1.0 end
    else
        state.points, state.minZ, state.maxZ = {}, origin.z - 1.0, origin.z + 4.0
    end
    state.ghost = spawnGhost(request)
    local target = #state.points > 0 and shapes.middle(state.points) or DL.geo.vec(existing.center) or DL.geo.vec(existing.coords)
    openCamera(target)
    CreateThread(function()
        while state do
            frame()
            Wait(0)
        end
    end)
    return true
end

function World.placement.active() return state ~= nil end
World.placement.cancel = cancel

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then cancel() end
end)
