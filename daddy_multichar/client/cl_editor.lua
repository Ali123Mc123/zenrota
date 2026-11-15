-- The shape maths the placement editor needs: points, shapes from any record, and a shape's middle.
--   shape: { shape = 'point'|'sphere'|'box'|'polygon', center, size, rotation, radius, points, minZ, maxZ, heading }
do
    World = World or {}
    World.geo = {}

    local SHAPES = { point = true, sphere = true, box = true, polygon = true }
    local POINT_RADIUS = 1.0

    local function num(value, fallback)
        local n = tonumber(value)
        if n ~= n then return fallback end
        return n or fallback
    end

    -- vector2/3/4, {x,y,z,w} or {1,2,3,4} -> { x, y, z, w }.
    function World.geo.vec(value)
        local kind = type(value)
        if kind == 'vector3' or kind == 'vector4' or kind == 'vector2' then
            return { x = value.x, y = value.y, z = kind ~= 'vector2' and value.z or 0.0, w = kind == 'vector4' and value.w or nil }
        end
        if kind ~= 'table' then return nil end
        local x, y = num(value.x) or num(value[1]), num(value.y) or num(value[2])
        if not x or not y then return nil end
        return { x = x, y = y, z = num(value.z) or num(value[3]) or 0.0, w = num(value.w) or num(value[4]) }
    end
    local vec = World.geo.vec

    local function readPoints(value)
        if type(value) == 'string' then value = value ~= '' and json.decode(value) or nil end
        if type(value) ~= 'table' then return nil end
        local out = {}
        for i, point in ipairs(value) do
            local p = vec(point)
            if not p then return nil end
            out[i] = { x = p.x, y = p.y }
        end
        return #out > 0 and out or nil
    end

    -- Any record (config entry, NUI form, shape) -> a shape, or nil. Without a shape name it guesses.
    function World.geo.shape(raw)
        if type(raw) ~= 'table' then return nil end
        local kind = SHAPES[tostring(raw.shape or ''):lower()] and tostring(raw.shape):lower() or nil
        local points = readPoints(raw.points or raw.points_json)
        local center = vec(raw.center) or vec(raw.coords)
        local size = vec(raw.size)
        local radius = num(raw.radius)
        if not kind then
            kind = points and #points >= 3 and 'polygon' or radius and radius > 0 and 'sphere' or size and 'box' or center and 'point'
            if not kind then return nil end
        end
        if kind == 'polygon' and (not points or #points < 3) then return nil end
        if kind ~= 'polygon' and not center then return nil end
        return {
            shape = kind,
            center = center and { x = center.x, y = center.y, z = center.z } or nil,
            heading = (num(raw.heading) or (center and center.w) or 0.0) % 360.0,
            size = kind == 'box' and (size or { x = 1.0, y = 1.0, z = 2.0 }) or size,
            rotation = num(raw.rotation, 0.0),
            radius = (kind == 'sphere' or kind == 'point') and (radius or POINT_RADIUS) or radius,
            points = points,
            minZ = num(raw.minZ) or num(raw.min_z),
            maxZ = num(raw.maxZ) or num(raw.max_z),
        }
    end

    -- The middle of a shape; a polygon's sits halfway between its floor and ceiling.
    function World.geo.centroid(shape)
        if shape.shape ~= 'polygon' then return shape.center and { x = shape.center.x, y = shape.center.y, z = shape.center.z } end
        local sx, sy = 0.0, 0.0
        for _, p in ipairs(shape.points) do sx, sy = sx + p.x, sy + p.y end
        local low = shape.minZ or 0.0
        return { x = sx / #shape.points, y = sy / #shape.points, z = (low + (shape.maxZ or low)) * 0.5 }
    end

    -- Drawing world shapes for one frame: the editor's preview and the admin's debug view use the same lines,
    -- so what is placed looks exactly like what is saved. Call every frame.
    World = World or {}
    World.draw = {}

    -- Gold for the focused record, red for an inactive or invalid one, green for a placed point.
    World.draw.colors = {
        focused = { 250, 204, 21 }, inactive = { 239, 68, 68 }, valid = { 34, 197, 94 }, invalid = { 239, 68, 68 },
    }

    -- '#D43D45' -> { 212, 61, 69 }
    function World.draw.rgb(hex)
        hex = tostring(hex or ''):gsub('#', '')
        return { tonumber(hex:sub(1, 2), 16) or 46, tonumber(hex:sub(3, 4), 16) or 123, tonumber(hex:sub(5, 6), 16) or 255 }
    end

    -- A wall seen from both sides (one DrawPoly is invisible from behind).
    local function wall(x1, y1, x2, y2, low, high, c, alpha)
        local r, g, b = c[1], c[2], c[3]
        DrawPoly(x1, y1, low, x2, y2, low, x2, y2, high, r, g, b, alpha)
        DrawPoly(x1, y1, low, x2, y2, high, x1, y1, high, r, g, b, alpha)
        DrawPoly(x2, y2, high, x2, y2, low, x1, y1, low, r, g, b, alpha)
        DrawPoly(x1, y1, high, x2, y2, high, x1, y1, low, r, g, b, alpha)
    end

    -- Floor or ceiling as a fan; right for convex outlines.
    local function cap(points, z, c, alpha)
        local p1 = points[1]
        for i = 2, #points - 1 do
            local p2, p3 = points[i], points[i + 1]
            DrawPoly(p1.x, p1.y, z, p2.x, p2.y, z, p3.x, p3.y, z, c[1], c[2], c[3], alpha)
            DrawPoly(p3.x, p3.y, z, p2.x, p2.y, z, p1.x, p1.y, z, c[1], c[2], c[3], alpha)
        end
    end

    function World.draw.dot(x, y, z, c, size, alpha)
        size = size or 0.2
        DrawMarker(28, x, y, z, 0, 0, 0, 0, 0, 0, size, size, size, c[1], c[2], c[3], alpha or 220, false, false, 2, false, nil, nil, false)
    end

    local function line(a, b, c, alpha)
        DrawLine(a.x, a.y, a.z, b.x, b.y, b.z, c[1], c[2], c[3], alpha)
    end
    World.draw.line = line

    -- A corner the editor can grab: a ball on a post down to the floor, bigger while the cursor is on it.
    function World.draw.handle(p, floor, c, hot)
        World.draw.dot(p.x, p.y, p.z, c, hot and 0.32 or 0.2, hot and 255 or 210)
        if floor and floor < p.z then line({ x = p.x, y = p.y, z = floor }, p, c, 160) end
    end

    -- The eight corners of a turned box: bottom four, top four.
    local function boxCorners(shape)
        local c, s = shape.center, shape.size
        local rot = math.rad(shape.rotation or 0.0)
        local cos, sin = math.cos(rot), math.sin(rot)
        local low, high = {}, {}
        for i, o in ipairs({ { -1, -1 }, { 1, -1 }, { 1, 1 }, { -1, 1 } }) do
            local lx, ly = o[1] * s.x * 0.5, o[2] * s.y * 0.5
            local x, y = c.x + lx * cos - ly * sin, c.y + lx * sin + ly * cos
            low[i], high[i] = { x = x, y = y, z = c.z - s.z * 0.5 }, { x = x, y = y, z = c.z + s.z * 0.5 }
        end
        return low, high
    end

    -- Text with a dark plate, centred on a world point.
    function World.draw.label(x, y, z, text, c)
        local onScreen, sx, sy = World3dToScreen2d(x, y, z)
        if not onScreen then return end
        SetTextScale(0.30, 0.30)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextColour(c and c[1] or 255, c and c[2] or 255, c and c[3] or 255, 240)
        SetTextCentre(true)
        BeginTextCommandDisplayText('STRING')
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(sx, sy)
        DrawRect(sx, sy + 0.012, 0.015 + #text / 360, 0.024, 10, 12, 18, 210)
    end

    -- style: { color = {r,g,b}, focused, faint (other places behind the editor), label, corners = false }
    function World.draw.shape(shape, style)
        if type(shape) ~= 'table' then return end
        style = style or {}
        local c, focused, faint = style.color or { 255, 255, 255 }, style.focused == true, style.faint == true
        local edge, side, lid = focused and 255 or 210, focused and 160 or 100, focused and 85 or 45
        if faint then edge, side, lid = 120, 28, 10 end
        local top

        if shape.shape == 'polygon' and shape.points and #shape.points >= 3 then
            local points, low = shape.points, shape.minZ or 0.0
            local high = shape.maxZ or low + 3.0
            for i, a in ipairs(points) do
                local b = points[i % #points + 1]
                wall(a.x, a.y, b.x, b.y, low, high, c, side)
                line({ x = a.x, y = a.y, z = low }, { x = b.x, y = b.y, z = low }, c, edge)
                line({ x = a.x, y = a.y, z = high }, { x = b.x, y = b.y, z = high }, c, edge)
                line({ x = a.x, y = a.y, z = low }, { x = a.x, y = a.y, z = high }, c, focused and 255 or edge)
                if style.corners ~= false and not faint then
                    World.draw.dot(a.x, a.y, low, c)
                    World.draw.dot(a.x, a.y, high, c)
                end
            end
            cap(points, low, c, lid)
            cap(points, high, c, lid)
            top = high
        elseif shape.shape == 'sphere' and shape.center then
            local p, d = shape.center, (shape.radius or 1.0) * 2.0
            DrawMarker(28, p.x, p.y, p.z, 0, 0, 0, 0, 0, 0, d, d, d, c[1], c[2], c[3], faint and 30 or focused and 120 or 70, false, false, 2, false, nil, nil, false)
            top = p.z + (shape.radius or 1.0)
        elseif shape.shape == 'box' and shape.center and shape.size then
            local low, high = boxCorners(shape)
            for i = 1, 4 do
                local n = i % 4 + 1
                wall(low[i].x, low[i].y, low[n].x, low[n].y, low[i].z, high[i].z, c, side)
                line(low[i], low[n], c, edge)
                line(high[i], high[n], c, edge)
                line(low[i], high[i], c, edge)
            end
            cap(low, low[1].z, c, lid)
            cap(high, high[1].z, c, lid)
            top = high[1].z
        elseif shape.center then
            local p = shape.center
            World.draw.dot(p.x, p.y, p.z + 0.03, c, 0.15, faint and 120 or nil)
            if (shape.radius or 0) > 0.15 then
                local d = shape.radius * 2.0
                DrawMarker(1, p.x, p.y, p.z - 0.95, 0, 0, 0, 0, 0, 0, d, d, 1.0, c[1], c[2], c[3], 40, false, false, 2, false, nil, nil, false)
            end
            top = p.z + 1.0
        end

        if top and not faint and style.label and style.label ~= '' then
            local center = World.geo.centroid(shape)
            if center then World.draw.label(center.x, center.y, top + 0.3, style.label, c) end
        end
    end

    -- Geometry for the place editor, kept free of game calls so it can be tested: a box from three clicks, polygon
    -- area and crossing sides, grid snapping. Points are { x, y, z } tables.
    World = World or {}
    World.shapes = {}

    local shapes = World.shapes

    function shapes.snap(value, step)
        return math.floor(value / step + 0.5) * step
    end

    -- The box drawn by two corners of one side (a, b) and a point that sets the depth: rotation is the side's angle,
    -- size.x its length, size.y the depth; base is the floor center. Nil while a side is too short.
    function shapes.box(a, b, depthPoint, height)
        local dx, dy = b.x - a.x, b.y - a.y
        local length = math.sqrt(dx * dx + dy * dy)
        if length < 0.05 then return nil end
        local ux, uy = dx / length, dy / length
        local depth = depthPoint and ((depthPoint.x - a.x) * -uy + (depthPoint.y - a.y) * ux) or 0.0
        local floor = math.min(a.z, b.z)
        local base = { x = a.x + ux * length * 0.5 - uy * depth * 0.5, y = a.y + uy * length * 0.5 + ux * depth * 0.5, z = floor }
        return {
            base = base, rotation = math.deg(math.atan(dy, dx)) % 360,
            size = { x = length, y = math.abs(depth), z = height },
            center = { x = base.x, y = base.y, z = floor + height * 0.5 },
        }
    end

    -- Floor area of an outline in square metres.
    function shapes.area(points)
        local sum = 0.0
        for i, a in ipairs(points) do
            local b = points[i % #points + 1]
            sum = sum + a.x * b.y - b.x * a.y
        end
        return math.abs(sum) * 0.5
    end

    local function side(a, b, c)
        return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
    end

    local function cross(a, b, c, d)
        return side(a, b, c) * side(a, b, d) < 0 and side(c, d, a) * side(c, d, b) < 0
    end

    -- Whether two sides of the closed outline cross each other.
    function shapes.crossing(points)
        local n = #points
        if n < 4 then return false end
        for i = 1, n do
            local a, b = points[i], points[i % n + 1]
            for j = i + 2, n do
                if not (i == 1 and j == n) and cross(a, b, points[j], points[j % n + 1]) then return true end
            end
        end
        return false
    end

    -- The middle of the outline's corners.
    function shapes.middle(points)
        local x, y, z = 0.0, 0.0, 0.0
        for _, p in ipairs(points) do x, y, z = x + p.x, y + p.y, z + (p.z or 0.0) end
        local n = math.max(#points, 1)
        return { x = x / n, y = y / n, z = z / n }
    end

    -- Lowest and highest corner.
    function shapes.heights(points)
        local low, high
        for _, p in ipairs(points) do
            local z = p.z or 0.0
            low, high = math.min(low or z, z), math.max(high or z, z)
        end
        return low, high
    end

    -- The mouse in the world while a script camera runs: the game's own cursor, the ray under it and how close it
    -- is to a point drawn on screen.
    World = World or {}
    World.cursor = {}

    -- Forward, right and up of a camera rotation (no roll).
    local function basis(rotation)
        local z, x = math.rad(rotation.z), math.rad(rotation.x)
        local c = math.cos(x)
        local forward = vector3(-math.sin(z) * c, math.cos(z) * c, math.sin(x))
        local right = vector3(math.cos(z), math.sin(z), 0.0)
        local up = vector3(right.y * forward.z - right.z * forward.y, right.z * forward.x - right.x * forward.z, right.x * forward.y - right.y * forward.x)
        return forward, right, up
    end

    -- Shows the cursor this frame; sprite 1 is the arrow, 3 an open hand, 4 a closed one, 11 an arrow with a plus.
    function World.cursor.show(sprite)
        SetMouseCursorActiveThisFrame()
        SetMouseCursorSprite(sprite or 1)
    end

    -- Where the cursor is, from 0 to 1 across and down the screen.
    function World.cursor.position()
        return GetDisabledControlNormal(0, 239), GetDisabledControlNormal(0, 240)
    end

    -- The ray under the cursor: origin and unit direction.
    function World.cursor.ray()
        local origin, rotation = GetFinalRenderedCamCoord(), GetFinalRenderedCamRot(2)
        local forward, right, up = basis(rotation)
        local x, y = World.cursor.position()
        local v = math.tan(math.rad(GetFinalRenderedCamFov()) * 0.5)
        local dir = forward + right * ((x * 2.0 - 1.0) * v * GetAspectRatio(false)) + up * ((1.0 - y * 2.0) * v)
        return origin, dir / #dir
    end

    -- What the cursor points at (map and props), or nil over the sky.
    function World.cursor.hit(range, ignore)
        local from, dir = World.cursor.ray()
        local to = from + dir * (range or 300.0)
        local probe = StartExpensiveSynchronousShapeTestLosProbe(from.x, from.y, from.z, to.x, to.y, to.z, 1 | 16, ignore or 0, 7)
        local _, hit, coords = GetShapeTestResult(probe)
        if hit ~= 1 then return nil end
        return vector3(coords.x, coords.y, coords.z)
    end

    -- How far the cursor is from a world point on screen, in screen heights; nil when the point is off screen.
    function World.cursor.distanceTo(x, y, z)
        local onScreen, sx, sy = GetScreenCoordFromWorldCoord(x, y, z)
        if not onScreen then return nil end
        local cx, cy = World.cursor.position()
        local dx = (sx - cx) * GetAspectRatio(false)
        return math.sqrt(dx * dx + (sy - cy) * (sy - cy))
    end

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
        local pose = Core.freecam.pose()
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
        Core.freecam.place(coords, rotation)
    end

    -- Opens the camera looking down at a place being edited, or from where the player looks.
    local function openCamera(target)
        local coords, rotation = GetGameplayCamCoord(), GetGameplayCamRot(2)
        if target and #(vector3(target.x, target.y, target.z) - state.origin) < state.reach then
            local z = math.rad(rotation.z)
            coords = vector3(target.x + math.sin(z) * 7.0, target.y - math.cos(z) * 7.0, target.z + 6.0)
            rotation = vector3(-38.0, 0.0, rotation.z)
        end
        Core.freecam.start({ coords = coords, rotation = rotation, fov = GetGameplayCamFov() })
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
        Core.freecam.stop()
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
            World.draw.shape(World.geo.shape(item) or item, { color = World.draw.colors.valid, faint = true })
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
        local target = #state.points > 0 and shapes.middle(state.points) or World.geo.vec(existing.center) or World.geo.vec(existing.coords)
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
end

-- The scene editor (admins): a working copy of a scene in Lua, stand-in actors, freecam key capture, placement,
-- the world applied live, a read-only test with the admin's own look, and saving through the admin pad.
-- Editor.rule/apply/anim/blank are pure, so tests load this file.
do
    Editor = {}

    local MAX_PROPS, MAX_KEYS, SAMPLE_CAR = 24, 24, 'tailgater'
    local WEATHERS = { 'EXTRASUNNY', 'CLEAR', 'NEUTRAL', 'SMOG', 'FOGGY', 'OVERCAST', 'CLOUDS', 'CLEARING', 'RAIN', 'THUNDER', 'SNOW', 'BLIZZARD', 'SNOWLIGHT', 'XMAS', 'HALLOWEEN', 'RAIN_HALLOWEEN', 'SNOW_HALLOWEEN' }
    local EASES = { 'smooth', 'linear', 'outQuad', 'inOutQuad', 'outCubic', 'inOutCubic', 'outSine', 'inOutSine' }
    local LOOK_PROPS = { 0, 1, 2, 6, 7 }
    local dicts = {} -- animation dictionaries the stand-ins loaded, removed on teardown

    local function copy(v)
        if type(v) ~= 'table' then return v end
        local out = {}
        for k, x in pairs(v) do out[k] = copy(x) end
        return out
    end
    Editor.copy = copy

    local function t(...) return Core.locale.t(...) end

    local function maxSpots()
        return Config.Scenes and Config.Scenes.MaxSpots or 10
    end

    -- Rules: every path the panel may set and its range, SceneSchema's or narrower ('#' is a list index) ---------------

    local function set(list)
        local out = {}
        for _, v in ipairs(list) do out[v] = true end
        return out
    end
    local function num(min, max, int) return { kind = 'number', min = min, max = max, int = int } end
    local function enum(list, optional) return { kind = 'enum', set = set(list), optional = optional } end
    local function toggle(default, off) return { kind = 'toggle', default = default, off = off } end
    local BOOL = { kind = 'bool' }

    local RULES = {
        label = { kind = 'text', max = 48 },
        desc = { kind = 'text', max = 64 },
        id = { kind = 'id' },
        mode = enum({ 'single', 'lineup' }),
        frame = enum({ 'left', 'center', 'right' }),
        population = BOOL,
        stream = num(20, 250),
        music = { kind = 'music' },
        volume = num(0, 1),
        weather = enum(WEATHERS, true),
        ipls = { kind = 'names', max = 16 },
        time = toggle({ h = 12, m = 0 }),
        ['time.h'] = num(0, 23, true),
        ['time.m'] = num(0, 59, true),
        timecycle = toggle({ name = 'cinema', strength = 0.3 }),
        ['timecycle.name'] = { kind = 'name' },
        ['timecycle.strength'] = num(0, 1),
        dof = toggle({ near = 1.0, far = 2.5, strength = 0.8 }, false),
        ['dof.near'] = num(0, 10),
        ['dof.far'] = num(0, 50),
        ['dof.strength'] = num(0, 1),
        light = toggle({ color = { r = 255, g = 214, b = 170 }, range = 18.0, intensity = 6.0 }, false),
        ['light.color.r'] = num(0, 255, true),
        ['light.color.g'] = num(0, 255, true),
        ['light.color.b'] = num(0, 255, true),
        ['light.range'] = num(1, 50),
        ['light.intensity'] = num(0, 20),
        ['spots.#.anim'] = { kind = 'anim' },
        ['spots.#.at.h'] = num(-360, 360),
        ['spots.#.nudge'] = toggle({ x = 0.0, y = 0.0, z = 0.0 }),
        ['spots.#.nudge.x'] = num(-1, 1),
        ['spots.#.nudge.y'] = num(-1, 1),
        ['spots.#.nudge.z'] = num(-1, 1),
        ['spots.#.cam'] = { kind = 'clear' },
        ['spots.#.cam.fov'] = num(10, 90),
        ['props.#.collision'] = BOOL,
        ['props.#.at.h'] = num(-360, 360),
        ['shots.establish.ms'] = num(500, 120000, true),
        ['shots.establish.ease'] = enum(EASES),
        ['shots.focus'] = toggle({ ms = 2600, ease = 'outCubic', keys = {} }),
        ['shots.focus.ms'] = num(300, 20000, true),
        ['shots.focus.ease'] = enum(EASES),
        ['shots.move'] = toggle({ ms = 1400, arc = 0.25 }),
        ['shots.move.ms'] = num(300, 5000, true),
        ['shots.move.arc'] = num(0, 1),
        ['shots.sway'] = toggle({ x = 0.08, z = 0.04, yaw = 0.6, period = 9.0 }, false),
        ['shots.sway.x'] = num(0, 1),
        ['shots.sway.z'] = num(0, 1),
        ['shots.sway.yaw'] = num(0, 5),
        ['shots.sway.period'] = num(2, 60),
        -- A role scene's partner and crew round the focused character (shared/sh_scene.lua).
        group = toggle({ formation = 'arc', distance = 1.6, spread = 120.0, direction = 180.0, acts = {} }),
        ['group.pose'] = enum({ 'together', 'scene' }),
        ['group.places'] = { kind = 'clear' },
        ['group.formation'] = enum({ 'arc', 'row' }),
        ['group.distance'] = num(0.6, 6),
        ['group.spread'] = num(0, 360, true),
        ['group.direction'] = num(0, 360, true),
        ['group.moments'] = { kind = 'names', max = 8 },
    }
    for _, shot in ipairs({ 'establish', 'focus' }) do
        RULES['shots.' .. shot .. '.keys.#.fov'] = num(10, 90)
        RULES['shots.' .. shot .. '.keys.#.cut'] = BOOL
        RULES['shots.' .. shot .. '.keys.#.ms'] = num(0, 60000, true)
    end

    local MUSIC = set({ 'ogg', 'mp3', 'wav', 'webm' })

    -- Each check answers ok and the value to store.
    local CHECK = {}

    function CHECK.number(rule, v)
        v = tonumber(v)
        if not v or v ~= v or v < rule.min or v > rule.max then return false end
        return true, rule.int and math.floor(v + 0.5) or v
    end

    function CHECK.bool(_, v) return type(v) == 'boolean', v end

    function CHECK.enum(rule, v)
        if rule.optional and (v == nil or v == '' or v == false) then return true, nil end
        return rule.set[v] == true, v
    end

    function CHECK.text(rule, v)
        if type(v) ~= 'string' then return false end
        v = v:gsub('%c', ' '):match('^%s*(.-)%s*$')
        local len = utf8.len(v) or #v
        return len > 0 and len <= rule.max, v
    end

    function CHECK.id(_, v) return type(v) == 'string' and #v <= 64 and v:match('^[%w_:%-]+$') ~= nil, v end

    function CHECK.name(_, v) return type(v) == 'string' and #v <= 64 and v:match('^[%w_%-]+$') ~= nil, v end

    function CHECK.names(rule, v)
        if type(v) ~= 'table' or #v > rule.max then return false end
        local out = {}
        for i, name in ipairs(v) do
            if not CHECK.name(nil, name) then return false end
            out[i] = name
        end
        return true, out
    end

    -- '' (the soft drone), a file in media/ or '@resource/path', always an audio file (SceneSchema's rule).
    function CHECK.music(_, v)
        if v == '' then return true, '' end
        if type(v) ~= 'string' or #v > 128 or v:find('..', 1, true) then return false end
        local resource, path = v:match('^@([%w_%-]+)/(.+)$')
        local file = path or v
        if not resource and file:find('/', 1, true) then return false end
        local ext = file:match('%.(%w+)$')
        return ext ~= nil and MUSIC[ext:lower()] == true and file:match('^[%w_%-%. /]+$') ~= nil and file:sub(1, 1) ~= '/', v
    end

    function CHECK.anim(_, v)
        if v == 'random' then return true, v end
        for _, a in ipairs(Config.Animations or {}) do
            if a.id == v then return true, v end
        end
        return false
    end

    function CHECK.toggle(rule, v)
        if v == true then return true, copy(rule.default) end
        return v == false or v == nil, rule.off
    end

    function CHECK.clear(_, v) return v == false or v == nil, nil end

    -- 'spots.2.anim' -> the rule of 'spots.#.anim', the keys { 'spots', 2, 'anim' } and the shape.
    function Editor.rule(path)
        if type(path) ~= 'string' or #path > 64 then return nil end
        local keys, shape = {}, {}
        for part in path:gmatch('[^.]+') do
            local n = tonumber(part)
            if n and (n < 1 or n > 64 or n % 1 ~= 0) then return nil end
            keys[#keys + 1], shape[#shape + 1] = n and math.floor(n) or part, n and '#' or part
        end
        return RULES[table.concat(shape, '.')], keys, shape
    end

    -- The table holding the last key, making switched-off toggles on the way; nil when an index does not exist.
    local function parentOf(scene, keys, shape)
        local node = scene
        for i = 1, #keys - 1 do
            local child = node[keys[i]]
            if type(child) ~= 'table' then
                local rule = RULES[table.concat(shape, '.', 1, i)]
                if not (rule and rule.kind == 'toggle') then return nil end
                child = copy(rule.default)
                node[keys[i]] = child
            end
            node = child
        end
        return node
    end

    -- Sets one whitelisted value; false and why ('path' | 'value' | 'missing') when it is not allowed.
    function Editor.apply(scene, path, value)
        local rule, keys, shape = Editor.rule(path)
        if not rule then return false, 'path' end
        local ok, clean = CHECK[rule.kind](rule, value)
        if not ok then return false, 'value' end
        local parent = parentOf(scene, keys, shape)
        if not parent then return false, 'missing' end
        local last = keys[#keys]
        if rule.kind == 'toggle' and value == true and type(parent[last]) == 'table' then return true end
        parent[last] = clean
        return true
    end

    -- A spot's animation: its id, or for 'random' one of the gender's pool picked by the spot number.
    function Editor.anim(id, gender, index)
        local pool = {}
        for _, a in ipairs(Config.Animations or {}) do
            if a.id == id then return a end
            if a.gender == 'any' or a.gender == gender then pool[#pool + 1] = a end
        end
        if id ~= 'random' or #pool == 0 then return nil end
        return pool[(index - 1) % #pool + 1]
    end

    -- A new scene at an anchor: one spot facing the camera and an establishing push-in.
    function Editor.blank(anchor, id)
        return {
            id = id, label = id, mode = 'lineup', anchor = anchor, frame = 'right', population = false,
            spots = { { at = { x = 0.0, y = 0.0, z = 0.0, h = 0.0 }, anim = 'random' } },
            shots = {
                establish = { ms = 7000, ease = 'smooth', keys = {
                    { pos = { x = 0.0, y = 14.0, z = 4.0 }, look = { x = 0.0, y = 0.0, z = 1.2 }, fov = 40.0 },
                    { pos = { x = 0.0, y = 8.0, z = 1.8 }, look = { x = 0.0, y = 0.0, z = 1.1 }, fov = 38.0 },
                } },
                move = { ms = 1400, arc = 0.25 },
                sway = { x = 0.08, z = 0.04, yaw = 0.6, period = 9.0 },
            },
        }
    end

    -- Session --------------------------------------------------------------------------------------------------------

    local ed -- { work, revision, origId, scenes, selected, mode, dirty, back, gen, marks, testing, cast, previews, focus }

    local function waitFade(out, ms)
        local deadline = GetGameTimer() + (ms or 1500)
        while GetGameTimer() < deadline and (out and not IsScreenFadedOut() or not out and not IsScreenFadedIn()) do Wait(0) end
    end

    local function fail(key, args, code)
        Nui.toast(key, 'error', args)
        return { ok = false, error = code or 'invalid' }
    end

    -- The panel's copy of the session, at most ten times a second.
    local function push()
        if not ed then return end
        local now = GetGameTimer()
        if now - (ed.pushedAt or 0) < 100 then
            if ed.queued then return end
            ed.queued = true
            return SetTimeout(100, function()
                if not ed then return end
                ed.queued = false
                push()
            end)
        end
        ed.pushedAt = now
        MC.Send('mc:editor:state', { scene = ed.work, selected = ed.selected, mode = ed.mode, dirty = ed.dirty, revision = ed.revision,
            pick = ed.pick or false, axis = ed.axis or 'ground', status = ed.status or 'saved', undo = ed.history and #ed.history or 0,
            company = ed.company or 0 })
    end

    -- edit: the page has the mouse and the game keeps the keys (flying); panel: the cursor on the page; camera, place
    -- and test: the game owns input.
    local function setMode(mode, extra)
        ed.mode = mode
        Nui.input((mode == 'panel' or mode == 'edit') and 'ui' or 'game')
        SetNuiFocusKeepInput(mode == 'edit')
        local data = extra or {}
        data.mode = mode
        MC.Send('mc:editor:mode', data)
        push()
    end

    local function newId()
        return ('scene_%d'):format(GetCloudTimeAsInt() % 1000000)
    end

    -- Stage: the stand-ins, the sample car and the props around the anchor ------------------------------------------

    local function offset()
        return Config.Selection and Config.Selection.PedOffset or 1.0
    end

    -- Where the hidden player waits: the anchor, or under the first camera key for the intro (its anchor is the origin).
    local function home(work)
        local shot = work.id == 'intro' and work.shots and work.shots.establish
        local key = shot and shot.keys and shot.keys[1]
        if key then return { x = key.pos.x, y = key.pos.y, z = key.pos.z - 30.0, h = 0.0 } end
        return work.anchor
    end

    -- Items: every placeable part of the scene under one key ('anchor', 'spots:2', 'props:1', 'extras:3', 'cars:1',
    -- 'vehicle:1', 'partner:2', 'crew:3'), what it is, and its entry (the table holding .at; the anchor is the scene).
    local GROUPS = {
        { field = 'spots', kind = 'spot' }, { field = 'partner', kind = 'spot', layout = true }, { field = 'crew', kind = 'spot', layout = true },
        { field = 'extras', kind = 'ped' }, { field = 'cars', kind = 'car' }, { field = 'vehicle', kind = 'car', single = true },
        { field = 'props', kind = 'prop' },
    }

    local function listOf(work, group)
        if group.layout then return (work.setups or {})[group.field] or {} end
        if group.single then return work[group.field] and { work[group.field] } or {} end
        return work[group.field] or {}
    end

    -- { key, field, index, kind, entry, model, act } for every item, the anchor first (not for the intro).
    -- Independent company (pose 'scene'): each member's own place, first made from the formation.
    local function ownPlace(work, i, n)
        local g, solo, acts = work.group, work.spots[1], work.group.acts or {}
        if n == 1 then
            g.partner = g.partner or { at = Formation.place(solo.at, Formation.partner(g, work.frame)), act = g.partnerAct or acts[1] }
            return g.partner, 'partner'
        end
        g.places = g.places or {}
        g.places[i] = g.places[i] or { at = Formation.place(solo.at, Formation.slots(g, n)[i]), act = #acts > 0 and acts[(i - 1) % #acts + 1] or nil }
        return g.places[i], 'crew'
    end

    local function items(work)
        local out = {}
        if work.id ~= 'intro' then out[1] = { key = 'anchor', field = 'anchor', kind = 'anchor', entry = work } end
        for _, g in ipairs(GROUPS) do
            for i, entry in ipairs(g.layout and type(work.group) == 'table' and {} or listOf(work, g)) do
                if not (g.layout and i == 1) then
                    out[#out + 1] = { key = g.field .. ':' .. i, field = g.field, index = i, kind = g.kind, entry = entry,
                        model = g.field == 'vehicle' and SAMPLE_CAR or entry.model, act = entry.act }
                end
            end
        end
        -- Where the walking scene peds go: a mark per point, moved like any part.
        for i, e in ipairs(work.extras or {}) do
            for j, p in ipairs(type(e.walk) == 'table' and e.walk or {}) do
                out[#out + 1] = { key = 'walk:' .. i .. ':' .. j, field = 'walk', index = j, owner = i, kind = 'walk', entry = { at = p, id = e.id } }
            end
        end
        local n = ed and ed.company or 0
        if type(work.group) == 'table' and not Formation.together(work.group) and n > 0 and work.spots and work.spots[1] then
            for i = 1, n do
                local entry, field = ownPlace(work, i, n)
                out[#out + 1] = { key = 'group:' .. i, field = field, index = i, kind = 'spot', entry = entry, act = entry.act }
            end
        end
        return out
    end

    local function itemOf(key)
        if not ed or type(key) ~= 'string' then return nil end
        for _, item in ipairs(items(ed.work)) do
            if item.key == key then return item end
        end
        return nil
    end

    -- An item's place in the world: { x, y, z } of its ground point and its world heading.
    -- A role scene stands its parts on the ground under them (Scene's settle: the first ground within 3 m of the
    -- anchor's height); their z is a height over that ground. Other scenes, and the own car, measure from the anchor.
    -- Found grounds are kept per 5 cm cell until the stage is built again.
    local groundCache = {}

    local function baseZ(x, y, field)
        local a = ed.work.anchor
        if ed.work.id == 'intro' or field == 'vehicle' then return a.z end
        local key = ('%d:%d:%d'):format(math.floor(x * 20), math.floor(y * 20), math.floor(a.z * 10))
        local cached = groundCache[key]
        if cached then return cached end
        local gz = Ground.z(x, y, a.z)
        if gz then
            groundCache[key] = gz
            return gz
        end
        return a.z
    end

    local function worldOf(item)
        local a = ed.work.anchor
        if item.kind == 'anchor' then return { x = a.x, y = a.y, z = a.z }, a.h or 0.0 end
        local at, n = item.entry.at, item.entry.nudge or {}
        local p = Place.toWorld(a, { x = at.x + (n.x or 0.0), y = at.y + (n.y or 0.0), z = 0.0 })
        p.z = baseZ(p.x, p.y, item.field) + (at.z or 0.0) + (n.z or 0.0)
        return p, Place.worldHeading(a, at.h)
    end

    -- The label an item shows over the stage and in the list.
    local function labelOf(item)
        if item.kind == 'anchor' then return t('editorui.anchor') end
        if item.field == 'spots' then return t('editorui.spot', item.index) end
        if item.field == 'props' then return t('editorui.prop', item.index) end
        if item.field == 'extras' then return t('editorui.extra', item.entry.id or item.index) end
        if item.field == 'cars' then return t('editorui.car', item.index) end
        if item.field == 'vehicle' then return t('editorui.vehicle') end
        if item.kind == 'walk' then return t('editorui.walk_point', item.entry.id or item.owner) end
        return t('editorui.layout_' .. item.field, item.index)
    end

    local drawMarks -- the stage overlay, set with edit mode below

    -- What the item does or is, for its label: a scenario or clip, else its model.
    local function subOf(item)
        if item.kind == 'anchor' or item.kind == 'walk' then return nil end
        local act = item.entry.act
        return act and (act.scenario or act.clip) or item.model or item.entry.anim
    end

    -- The company the editor shows (ed.company: 0 alone, 1 a partner, 2-3 a crew) placed by the scene's group as the
    -- selection places it: where each stands (world point, heading) and what it waits in.
    local function companyAct(group, i, female)
        local acts = type(group.acts) == 'table' and group.acts or {}
        if #acts > 0 then
            local a = acts[(i - 1) % #acts + 1]
            return female and a.female or a
        end
        local idle = Formation.config('Idle') or {}
        local list = (female and idle.f or idle.m) or {}
        return list[(i - 1) % math.max(1, #list) + 1]
    end

    local function company(work)
        local g, solo, n = work.group, (work.spots or {})[1], ed and ed.company or 0
        if type(g) ~= 'table' or not solo or n == 0 or not Formation.together(g) then return {} end
        local out = {}
        if n == 1 then
            local own = g.partner
            out[1] = { at = own and own.at or Formation.place(solo.at, Formation.partner(g, work.frame)), act = own and own.act or g.partnerAct, field = 'partner' }
        else
            for i, slot in ipairs(Formation.slots(g, n)) do out[i] = { at = Formation.place(solo.at, slot), field = 'crew' } end
        end
        for i, c in ipairs(out) do
            c.key, c.index, c.female = 'group:' .. i, i, n == 1 or i % 2 == 0
            c.act = c.act or companyAct(g, i, c.female)
            c.p = Place.toWorld(work.anchor, { x = c.at.x, y = c.at.y, z = 0.0 })
            c.p.z = baseZ(c.p.x, c.p.y, 'group') + (c.at.z or 0.0)
            c.h = Place.worldHeading(work.anchor, c.at.h)
        end
        return out
    end

    local function marks(work)
        local list = {}
        for _, item in ipairs(items(work)) do
            local p, h = worldOf(item)
            list[#list + 1] = { key = item.key, field = item.field, kind = item.kind, p = p, h = h, text = labelOf(item), sub = subOf(item),
                tall = item.kind == 'spot' or item.kind == 'ped' }
        end
        for _, c in ipairs(company(work)) do
            list[#list + 1] = { key = c.key, field = c.field, kind = 'spot', p = c.p, h = c.h, tall = true,
                text = c.field == 'partner' and t('editorui.company_partner') or t('editorui.company_member', c.index),
                sub = c.act and (c.act.scenario or c.act.clip) or nil }
        end
        return list
    end

    -- Where an act's seat goes: its own scene origin (act.origin: the anchor's height, not the ground), else the floor.
    local function seatAt(anim, p)
        if anim.origin then return vector3(p.x, p.y, ed.work.anchor.z + (p.z - baseZ(p.x, p.y, 'spots'))) end
        return vector3(p.x, p.y, Ground.z(p.x, p.y, p.z + 1.0) or p.z)
    end

    -- A stand-in holds its act's prop (a notepad, a clipboard), as in the scene.
    local held = setmetatable({}, { __mode = 'k' })
    local function hold(ped, anim, valid)
        local old = held[ped]
        if old and DoesEntityExist(old) then DeleteEntity(old) end
        held[ped] = nil
        if type(anim.prop) ~= 'table' then return end
        local obj = Actors.hold(ped, anim.prop, valid)
        if obj then held[ped] = Track.add('editor', obj) end
    end

    local function idle(ped, anim, p, h, valid)
        if not anim then return end
        hold(ped, anim, valid)
        if anim.aim and not anim.dict and not anim.scenario then return Cast.aimPose(ped, anim, valid) end
        if anim.scenario then
            return TaskStartScenarioAtPosition(ped, anim.scenario, p.x, p.y, p.z + offset(), h, 0, anim.scenario:find('SEAT', 1, true) ~= nil, true)
        end
        if not Stream.dict(anim.dict, valid, 3000) then return end
        dicts[anim.dict] = true
        if not valid() then return end
        if (anim.chair or anim.origin) and Actors.seat(ped, anim, seatAt(anim, p), h, valid, false) then return end
        FreezeEntityPosition(ped, true)
        SetEntityCollision(ped, false, false)
        TaskPlayAnim(ped, anim.dict, anim.clip, 8.0, -8.0, -1, anim.flag or 1, 0.0, false, false, false)
    end

    local function pedAt(model, p, h, valid)
        local hash = type(model) == 'number' and model or joaat(model)
        if not IsModelInCdimage(hash) or not Stream.model(hash, valid, 5000) or not valid() then return nil end
        pcall(function() exports['FeloxAC']:CreatePed(hash) end) --[[FeloxAC:auto]]
        local ped = CreatePed(4, hash, p.x, p.y, p.z + offset(), h, false, false)
        SetModelAsNoLongerNeeded(hash)
        -- CreatePed takes the feet's height; like the scene, the root goes exactly PedOffset over the ground point.
        SetEntityCoordsNoOffset(ped, p.x, p.y, p.z + offset(), false, false, false)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedCanRagdoll(ped, false)
        return ped
    end

    -- One item on the stage: a stand-in on a character place, the scene's own ped, a car or a prop.
    local function spawn(item, valid)
        local p, h = worldOf(item)
        local ent
        if item.kind == 'spot' then
            local gender = (item.index or 1) % 2 == 0 and 'f' or 'm'
            local look = Bridge.appearance.defaultPed(gender)
            ent = pedAt(look.model, p, h, valid)
            if ent then
                Bridge.appearance.apply(ent, look)
                local act = gender == 'f' and (item.entry.female or (type(item.entry.act) == 'table' and item.entry.act.female) or item.entry.act) or item.entry.act
                ed.acts[item.key] = act or Editor.anim(item.entry.anim or 'random', gender, item.index or 1)
                idle(ent, ed.acts[item.key], p, h, valid)
            end
        elseif item.kind == 'ped' then
            ent = pedAt(item.model, p, h, valid)
            if ent then
                SetPedRandomComponentVariation(ent, 0)
                ed.acts[item.key] = item.entry.act
                idle(ent, item.entry.act, p, h, valid)
            end
        elseif item.kind == 'car' then
            local hash = joaat(item.model or SAMPLE_CAR)
            if IsModelInCdimage(hash) and Stream.model(hash, valid, 5000) and valid() then
                pcall(function() exports['FeloxAC']:CreateVehicle(hash) end) --[[FeloxAC:auto]]
                ent = CreateVehicle(hash, p.x, p.y, p.z, h, false, false)
                SetModelAsNoLongerNeeded(hash)
                -- On its wheels (or, before the ground has loaded, its model's bottom on the point); moves keep that height.
                if not SetVehicleOnGroundProperly(ent) then
                    local min = GetModelDimensions(hash)
                    SetEntityCoordsNoOffset(ent, p.x, p.y, p.z - min.z, false, false, false)
                end
                if item.field == 'cars' then
                    Cast.tiltCar(ent, item.entry)
                    Cast.styleCar(ent, item.entry)
                end
                ed.rise[item.key] = GetEntityCoords(ent).z - p.z
                FreezeEntityPosition(ent, true)
                SetEntityInvincible(ent, true)
                SetVehicleDoorsLocked(ent, 2)
            end
        elseif item.kind == 'prop' then
            local hash = joaat(item.model)
            if IsModelInCdimage(hash) and Stream.model(hash, valid, 5000) and valid() then
                pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
                ent = CreateObjectNoOffset(hash, p.x, p.y, p.z, false, false, false)
                SetModelAsNoLongerNeeded(hash)
                SetEntityHeading(ent, h)
                if (item.entry.at.z or 0) == 0 then
                    if ed.work.id ~= 'intro' then Ground.stand(ent, p.z) else PlaceObjectOnGroundProperly(ent) end
                    if ed.rise then ed.rise[item.key] = GetEntityCoords(ent).z - p.z end
                end
                FreezeEntityPosition(ent, true)
                local solid = item.entry.collision == true
                SetEntityCollision(ent, solid, solid)
            end
        end
        if not ent or ent == 0 then return nil end
        if not valid() then
            DeleteEntity(ent)
            return nil
        end
        Track.add('editor', ent)
        ed.ents[item.key] = ent
        return ent
    end

    -- The company's stand-ins again (after a group setting, the company or the focused place changed).
    local function placeCompany()
        for _, ent in ipairs(ed.companyEnts or {}) do
            if DoesEntityExist(ent) then DeleteEntity(ent) end
        end
        ed.companyEnts = {}
        ed.marks = marks(ed.work)
        ed.companyGen = (ed.companyGen or 0) + 1
        local gen, mine, list = ed.gen, ed.companyGen, company(ed.work)
        local function valid() return ed ~= nil and ed.gen == gen and ed.companyGen == mine and not ed.testing end
        CreateThread(function()
            for _, c in ipairs(list) do
                if not valid() then return end
                local look = Bridge.appearance.defaultPed(c.female and 'f' or 'm')
                local ped = pedAt(look.model, c.p, c.h, valid)
                if ped then
                    Bridge.appearance.apply(ped, look)
                    idle(ped, c.act, c.p, c.h, valid)
                    Track.add('editor', ped)
                    if valid() then ed.companyEnts[#ed.companyEnts + 1] = ped else DeleteEntity(ped) end
                end
                Wait(0)
            end
            -- Together: they take up the pose with the focused place's stand-in.
            local g, hero = ed.work.group, (ed.work.spots or {})[1]
            local act = hero and (hero.act or {}).scenario or ''
            if not valid() or #ed.companyEnts == 0 or not Formation.together(g) or act:find('SEAT', 1, true) or act:find('LOUNGER', 1, true) or (hero and hero.sync) then return end
            local stop = GetGameTimer() + 3000
            while valid() and not (ed.ents and ed.ents['spots:1'] and DoesEntityExist(ed.ents['spots:1'])) and GetGameTimer() < stop do Wait(100) end
            local lead = ed.ents and ed.ents['spots:1']
            if not valid() or not lead or not DoesEntityExist(lead) then return end
            local others = {}
            for i, ent in ipairs(ed.companyEnts) do others[i] = { ent = ent, sex = list[i] and list[i].female and 'f' or 'm' } end
            local p, h = worldOf(itemOf('spots:1'))
            Moments.holdPeds(lead, 'm', others, #others == 1 and 'couple' or 'team', valid, vector3(p.x, p.y, p.z + offset()), h)
        end)
    end

    -- Spot 1's never-ending two-person animation (CPR) with the scene ped it names, played as in the scene.
    local function syncPreview()
        local hero = itemOf('spots:1')
        local sync = hero and hero.entry.sync
        if not sync then return end
        local partner
        for _, it in ipairs(items(ed.work)) do
            if it.kind == 'ped' and it.entry.id == sync.with then partner = it end
        end
        local a, b = ed.ents['spots:1'], partner and ed.ents[partner.key]
        if not a or not b or not DoesEntityExist(a) or not DoesEntityExist(b) then return end
        local sexA, sexB = (hero.index or 1) % 2 == 0 and 'f' or 'm', partner.entry.sex or 'm'
        local dict = Cast.pairDict(sync.dict, sexA, sexB)
        local dictB = sync.dictB and Cast.pairDict(sync.dictB, sexA, sexB) or dict
        local alive = function() return ed ~= nil end
        if not Stream.dict(dict, alive, 3000) or not Stream.dict(dictB, alive, 3000) then return end
        dicts[dict], dicts[dictB] = true, true
        local p, h = worldOf(hero)
        local scene = CreateSynchronizedScene(p.x, p.y, p.z, 0.0, 0.0, h + 0.0, 2)
        SetSynchronizedSceneLooped(scene, true)
        for _, ped in ipairs({ a, b }) do
            FreezeEntityPosition(ped, false)
            SetEntityCollision(ped, false, false)
        end
        TaskSynchronizedScene(a, scene, dict, sync.a, 8.0, -8.0, 0, 0, 1000.0, 0)
        TaskSynchronizedScene(b, scene, dictB, sync.b, 8.0, -8.0, 0, 0, 1000.0, 0)
    end

    -- Rebuilds everything on the stage; an older build stops at its next step.
    local function build()
        ed.gen = ed.gen + 1
        local gen = ed.gen
        local function valid() return ed ~= nil and ed.gen == gen and not ed.testing end
        Track.clear('editor')
        Track.clear('seat')
        ed.ents, ed.acts, ed.rise = {}, {}, {}
        groundCache = {}
        ed.marks = marks(ed.work)
        CreateThread(function()
            for _, item in ipairs(items(ed.work)) do
                if not valid() then return end
                if item.kind ~= 'anchor' then
                    spawn(item, valid)
                    Wait(0)
                end
            end
            if valid() then syncPreview() end
        end)
        placeCompany()
    end

    -- One item made again (after a move, a new act or model): its old entity goes first.
    local function respawn(key)
        local old = ed.ents and ed.ents[key]
        if old and DoesEntityExist(old) then DeleteEntity(old) end
        if ed.ents then ed.ents[key] = nil end
        local item = itemOf(key)
        if not item or item.kind == 'anchor' then return end
        local gen = ed.gen
        CreateThread(function() spawn(item, function() return ed ~= nil and ed.gen == gen and not ed.testing end) end)
    end

    -- Slider drags send many values; the stage rebuilds once they settle.
    local function rebuildSoon()
        ed.buildToken = (ed.buildToken or 0) + 1
        local token = ed.buildToken
        ed.marks = marks(ed.work)
        SetTimeout(250, function()
            if ed and ed.buildToken == token and not ed.testing then build() end
        end)
    end

    -- The scene's world around the hidden player: clock, weather, IPLs, streaming and the stage.
    local function stage()
        local h = home(ed.work)
        Player.place(vec4(h.x, h.y, h.z, h.h or 0.0))
        Env.apply(ed.work)
        Stream.ipls(ed.work.ipls or {}, ed.work.sets)
        Stream.at(h, 80.0, 6000)
        build()
    end

    -- The camera at the first establishing key, or in front of the anchor looking at it.
    local function firstPose(work)
        local shot = work.shots and work.shots.establish
        local key = shot and shot.keys and shot.keys[1]
        return CamTool.poseOf(key or { pos = { x = 0.0, y = 8.0, z = 2.0 }, look = { x = 0.0, y = 0.0, z = 1.0 }, fov = 40.0 }, work.anchor)
    end

    -- The ground under the camera with the actors facing it: where a new or moved anchor goes.
    local function anchorHere()
        local pose = CamTool.pose()
        local ground = pose and Place.ground(pose.coords)
        if ground then ground.h = Place.round((pose.rotation.z + 180.0) % 360.0) end
        return ground
    end

    local function moveAnchor(at)
        ed.work.anchor = at
        Player.place(vec4(at.x, at.y, at.z, at.h))
    end

    -- Changes ----------------------------------------------------------------------------------------------------------

    local LIVE = { time = 'env', weather = 'env', timecycle = 'env', ipls = 'ipls', spots = 'build', props = 'build', vehicle = 'build', anchor = 'build',
        extras = 'build', cars = 'build', partner = 'build', crew = 'build', group = 'company' }

    -- After every change: dirty, the live world for what changed, the panel.
    local edited -- a change saved once the edits settle (below)

    local function changed(path)
        ed.dirty = true
        local what = LIVE[tostring(path):match('^[^.]+')]
        if what == 'env' then
            Env.apply(ed.work)
        elseif what == 'ipls' then
            Stream.dropIpls()
            Stream.ipls(ed.work.ipls or {}, ed.work.sets)
        elseif what == 'build' then
            rebuildSoon()
        elseif what == 'company' then
            ed.companyToken = (ed.companyToken or 0) + 1
            local token = ed.companyToken
            SetTimeout(250, function()
                if ed and ed.companyToken == token then
                    if Formation.together(ed.work.group) then placeCompany() else build() end
                end
            end)
        end
        push()
    end

    local function spotIndex(selected)
        local i = tonumber(tostring(selected):match('^spot:(%d+)$'))
        return i and ed.work.spots and ed.work.spots[i] and i or nil
    end

    local function selectedShot()
        return ed.selected == 'focus' and 'focus' or 'establish'
    end

    -- The establish or focus shot, made when missing.
    local function shotOf(name)
        ed.work.shots = ed.work.shots or {}
        local shot = ed.work.shots[name]
        if type(shot) ~= 'table' then
            shot = { ms = name == 'focus' and 2600 or 7000, ease = name == 'focus' and 'outCubic' or 'smooth', keys = {} }
            ed.work.shots[name] = shot
        end
        shot.keys = shot.keys or {}
        return shot
    end

    local CALLS = {}

    function CALLS.set(d)
        local ok, why = Editor.apply(ed.work, d.path, d.value)
        if not ok then return { ok = false, error = 'invalid', field = why } end
        changed(d.path)
        return { ok = true }
    end

    -- 'establish', 'focus' or 'spot:<n>': where captured keys go.
    function CALLS.select(d)
        if d.value ~= 'establish' and d.value ~= 'focus' and not spotIndex(d.value) then return { ok = false, error = 'invalid' } end
        ed.selected = d.value
        push()
        return { ok = true }
    end

    -- Enter: the camera becomes the next key of the selected shot, or the selected spot's own camera.
    function CALLS.capture()
        local key = CamTool.capture(ed.work.anchor)
        if not key then return { ok = false, error = 'invalid' } end
        local spot = spotIndex(ed.selected)
        if spot then
            ed.work.spots[spot].cam = key
        else
            local shot = shotOf(selectedShot())
            if #shot.keys >= MAX_KEYS then return fail('editorui.limit') end
            shot.keys[#shot.keys + 1] = key
        end
        changed('shots')
        edited()
        return { ok = true }
    end

    -- Backspace: the last key of the selected shot, or the selected spot's camera, goes.
    function CALLS.undo()
        local spot = spotIndex(ed.selected)
        local keys = not spot and shotOf(selectedShot()).keys
        if spot then
            ed.work.spots[spot].cam = nil
        elseif #keys > 0 then
            keys[#keys] = nil
        else
            return { ok = false, error = 'invalid' }
        end
        changed('shots')
        edited()
        return { ok = true }
    end

    function CALLS.removeKey(d)
        local keys, i = shotOf(selectedShot()).keys, tonumber(d.value)
        if not i or not keys[i] then return { ok = false, error = 'invalid' } end
        table.remove(keys, i)
        changed('shots')
        return { ok = true }
    end

    -- The camera jumps to key number value of the selected shot.
    function CALLS.view(d)
        local key = shotOf(selectedShot()).keys[tonumber(d.value) or 0]
        if not key then return { ok = false, error = 'invalid' } end
        CamTool.place(CamTool.poseOf(key, ed.work.anchor))
        return { ok = true }
    end

    -- Space: the selected shot plays; a single key just moves the camera there.
    function CALLS.preview()
        local spot = spotIndex(ed.selected)
        local shot = spot and { keys = { ed.work.spots[spot].cam }, ms = 1000 } or shotOf(selectedShot())
        if #shot.keys == 0 then return fail('editorui.no_keys') end
        if ed.mode == 'panel' then setMode('camera') end
        if #shot.keys == 1 then CamTool.place(CamTool.poseOf(shot.keys[1], ed.work.anchor)) else CamTool.preview(shot, ed.work.anchor) end
        return { ok = true }
    end

    local function setSpot(index, at)
        local spots = ed.work.spots or {}
        ed.work.spots = spots
        if index and spots[index] then spots[index].at = at else spots[#spots + 1] = { at = at, anim = 'random' } end
    end

    local function setProp(index, model, at)
        local props = ed.work.props or {}
        ed.work.props = props
        if index and props[index] then props[index].at = at else props[#props + 1] = { model = model, at = at, collision = false } end
    end

    -- A partner or crew place: index 2.. (place 1 is always the focused character's, the solo spot).
    local function layoutOf(kind)
        ed.work.setups = ed.work.setups or {}
        local list = ed.work.setups[kind]
        if type(list) ~= 'table' or #list == 0 then
            local solo = (ed.work.spots or {})[1]
            list = { solo and copy(solo) or { at = { x = 0.0, y = 0.0, z = 0.0, h = 0.0 }, anim = 'random' } }
            ed.work.setups[kind] = list
        end
        return list
    end

    local function setLayout(kind, index, at)
        local list = layoutOf(kind)
        if index and list[index] then list[index].at = at else list[#list + 1] = { at = at, anim = 'random', act = { scenario = 'WORLD_HUMAN_HANG_OUT_STREET' } } end
    end

    -- A placed point lands in the scene; freecam starts again where placement left its camera.
    local function placed(field, index, model, at, back)
        if not ed then return end
        if at and field ~= 'anchor' then
            -- The placement tool measures height from the anchor; a part keeps it over its own ground.
            local w = Place.toWorld(ed.work.anchor, at)
            at.z = Place.round(w.z - baseZ(w.x, w.y, field))
        end
        if at then
            if field == 'anchor' then moveAnchor(at)
            elseif field == 'spots' then setSpot(index, at)
            elseif field == 'vehicle' then ed.work.vehicle = { at = at }
            elseif field == 'extras' or field == 'cars' then ed.work[field][index].at = at
            elseif field == 'partner' or field == 'crew' then setLayout(field, index, at)
            else setProp(index, model, at) end
            changed(field)
        end
        CamTool.start(Place.lastPose)
        setMode(back)
    end

    local PLACE = { anchor = 'anchor', spots = 'spot', vehicle = 'vehicle', props = 'prop', extras = 'spot', cars = 'vehicle', partner = 'spot', crew = 'spot' }

    -- The world point and heading a placement starts from: the anchor, or the entry's local point.
    local function startPoint(field, entry)
        local a = ed.work.anchor
        if field == 'anchor' then return { x = a.x, y = a.y, z = a.z, w = a.h }, a.h end
        if not entry then return nil, a.h end
        local p = Place.toWorld(a, { x = entry.at.x, y = entry.at.y, z = 0.0 })
        p.z = baseZ(p.x, p.y, field) + (entry.at.z or 0.0)
        p.w = Place.worldHeading(a, entry.at.h)
        return p, p.w
    end

    local function placeLabel(field, index, list)
        if field == 'spots' then return t('editorui.spot', index or #list + 1) end
        if field == 'extras' then return t('editorui.extra', list[index] and list[index].id or index) end
        if field == 'cars' then return t('editorui.car', index) end
        if field == 'partner' or field == 'crew' then return t('editorui.layout_' .. field, index or #list + 1) end
        if field == 'props' then return t('editorui.prop', index or #list + 1) end
        return t('editorui.' .. field)
    end

    -- path: anchor | spots | vehicle | props; value: the entry number to move, or for a new prop its model.
    function CALLS.place(d)
        local field, index = d.path, tonumber(d.value)
        if not PLACE[field] or World.placement.active() or (field == 'anchor' and ed.work.id == 'intro') then return { ok = false, error = 'invalid' } end
        local list = (field == 'spots' or field == 'props') and (ed.work[field] or {})
            or ((field == 'extras' or field == 'cars') and (ed.work[field] or {}))
            or ((field == 'partner' or field == 'crew') and layoutOf(field)) or nil
        local entry = field == 'vehicle' and ed.work.vehicle or list and index and list[index]
        if list and index and not entry then return { ok = false, error = 'invalid' } end
        if (field == 'extras' or field == 'cars') and not entry then return { ok = false, error = 'invalid' } end
        if (field == 'partner' or field == 'crew') and index == 1 then return { ok = false, error = 'invalid' } end
        if list and not entry and #list >= (field == 'spots' and maxSpots() or MAX_PROPS) then return fail('editorui.limit') end
        local model = field == 'props' and (entry and entry.model or d.value)
        if field == 'props' and not Place.model(model) then return fail('editorui.bad_model') end
        local anim = field == 'spots' and entry and (entry.act or Editor.anim(entry.anim or 'random', 'm', index))
            or (field == 'extras' and entry and entry.act) or ((field == 'partner' or field == 'crew') and entry and entry.act) or nil
        local pedModel = field == 'extras' and entry and entry.model or nil
        local existing, heading = startPoint(field, entry)
        local back = ed.mode == 'panel' and 'panel' or 'camera'
        local started = Place.start(PLACE[field], {
            anchor = ed.work.anchor, existing = existing, heading = heading, label = placeLabel(field, index, list),
            model = pedModel or model, scenario = anim and anim.scenario, backdrop = drawMarks,
        }, function(at) placed(field, index, model, at, back) end)
        if not started then return { ok = false, error = 'busy' } end
        setMode('place')
        return { ok = true }
    end

    -- The anchor jumps to the ground under the camera (not for the intro, whose anchor is the origin).
    function CALLS.anchorHere()
        local ground = ed.work.id ~= 'intro' and anchorHere()
        if not ground then return fail('editorui.no_ground') end
        moveAnchor(ground)
        changed('anchor')
        return { ok = true }
    end

    -- path: spots | props | vehicle; value: the entry number.
    function CALLS.remove(d)
        local field, i = d.path, tonumber(d.value)
        if field == 'vehicle' then
            ed.work.vehicle = nil
        elseif (field == 'extras' or field == 'cars') and i and ed.work[field] and ed.work[field][i] then
            table.remove(ed.work[field], i)
        elseif (field == 'partner' or field == 'crew') and i and i > 1 and ed.work.setups and ed.work.setups[field] and ed.work.setups[field][i] then
            table.remove(ed.work.setups[field], i)
        elseif (field == 'spots' or field == 'props') and i and ed.work[field] and ed.work[field][i] then
            table.remove(ed.work[field], i)
            local selected = tonumber(tostring(ed.selected):match('^spot:(%d+)$'))
            if field == 'spots' and selected and selected >= i then ed.selected = 'establish' end
        else
            return { ok = false, error = 'invalid' }
        end
        changed(field)
        return { ok = true }
    end

    -- Edit mode: one mode for everything. The page keeps the focus and the mouse; the game keeps the keys for flying
    -- (SetNuiFocusKeepInput). Right drag looks, WASD flies (Q/E down and up, Shift fast, Alt slow), a click picks an item
    -- (on the item itself or its label), a drag moves it on the ground or along the axis picked with X, Y or Z, the wheel
    -- turns it (Alt+wheel: height). Every change can be undone and saves itself a moment later.

    local FLY, FAST, SLOW, LOOK = 7.0, 8.0, 0.25, 0.22 -- metres a second, Shift and Alt factors, degrees a pixel
    local PICK = 0.035                                  -- how near the pointer picks a label (screen heights)
    local SAVE_MS, UNDO_MAX = 1200, 60
    local AXES = { ground = true, x = true, y = true, z = true }
    local KEY = { forward = 32, back = 33, left = 34, right = 35, up = 38, down = 44, fast = 21, slow = 19 }

    local function held(control) return IsDisabledControlPressed(0, control) end

    -- The scene before a change, for Ctrl+Z.
    local function remember()
        ed.history = ed.history or {}
        ed.history[#ed.history + 1] = copy(ed.work)
        if #ed.history > UNDO_MAX then table.remove(ed.history, 1) end
    end

    -- A role scene's spots stay its solo layout after any copy.
    local function relink()
        local setups = ed.work.setups
        if type(setups) == 'table' and type(setups.solo) == 'table' and #setups.solo > 0 then ed.work.spots = setups.solo end
    end

    local saveNow -- the save without the toast (below)

    -- After a change: dirty, the labels, the panel, and a save once the edits settle.
    edited = function()
        ed.dirty = true
        ed.marks = marks(ed.work)
        ed.saveToken = (ed.saveToken or 0) + 1
        local token = ed.saveToken
        ed.status = 'waiting'
        push()
        SetTimeout(SAVE_MS, function()
            if ed and ed.saveToken == token and ed.dirty and not ed.testing then saveNow() end
        end)
    end

    -- The pointer and the handles ---------------------------------------------------------------------------------------
    -- The page owns the mouse and sends where it is (0..1 across and down); the ray, the picking and the handles are
    -- worked out here from the rendered camera, so nothing depends on the game's own cursor.

    local AXIS_COLORS = { x = { 255, 70, 70 }, y = { 70, 220, 90 }, z = { 80, 140, 255 }, ring = { 255, 200, 60 } }
    local HOT = { 255, 240, 120 }
    local ARROW, RING, GRAB = 1.25, 1.1, 0.02 -- handle length and ring radius (metres), how near grabs a handle (screen heights)
    local SNAP_M, SNAP_DEG = 0.25, 15.0

    local pointer = { x = 0.5, y = 0.5, shift = false }

    local function axesOf(h)
        local r = math.rad(h)
        return { x = vector3(math.cos(r), math.sin(r), 0.0), y = vector3(-math.sin(r), math.cos(r), 0.0), z = vector3(0.0, 0.0, 1.0) }
    end

    -- The ray from the rendered camera through the pointer: origin and unit direction.
    local function ray()
        local origin, rot = GetFinalRenderedCamCoord(), GetFinalRenderedCamRot(2)
        local z, x = math.rad(rot.z), math.rad(rot.x)
        local c = math.cos(x)
        local forward = vector3(-math.sin(z) * c, math.cos(z) * c, math.sin(x))
        local right = vector3(math.cos(z), math.sin(z), 0.0)
        local up = vector3(right.y * forward.z - right.z * forward.y, right.z * forward.x - right.x * forward.z, right.x * forward.y - right.y * forward.x)
        local v = math.tan(math.rad(GetFinalRenderedCamFov()) * 0.5)
        local dir = forward + right * ((pointer.x * 2.0 - 1.0) * v * GetAspectRatio(false)) + up * ((1.0 - pointer.y * 2.0) * v)
        return origin, dir / #dir
    end

    -- A world point on screen (0..1), or nil behind the camera.
    local function screenOf(p)
        local ok, sx, sy = GetScreenCoordFromWorldCoord(p.x, p.y, p.z)
        if not ok then return nil end
        return sx, sy
    end

    -- Distances on screen in screen heights (the width counts by the aspect ratio).
    local function screenDist(ax, ay, bx, by)
        local dx = (ax - bx) * GetAspectRatio(false)
        return math.sqrt(dx * dx + (ay - by) * (ay - by))
    end

    local function segmentDist(px, py, ax, ay, bx, by)
        local aspect = GetAspectRatio(false)
        local vx, vy, wx, wy = (bx - ax) * aspect, by - ay, (px - ax) * aspect, py - ay
        local len2 = vx * vx + vy * vy
        local t = len2 > 0 and math.max(0.0, math.min(1.0, (wx * vx + wy * vy) / len2)) or 0.0
        local dx, dy = wx - vx * t, wy - vy * t
        return math.sqrt(dx * dx + dy * dy)
    end

    -- Where the pointer meets the level plane at height z.
    local function onPlane(z)
        local from, dir = ray()
        if math.abs(dir.z) < 1e-4 then return nil end
        local t = (z - from.z) / dir.z
        if t <= 0 or t > 500.0 then return nil end
        return from + dir * t
    end

    -- The picked item's handles: they start at its ground point (a person's feet), its axes, the ring.
    local function handlesOf(item)
        local p, h = worldOf(item)
        return vector3(p.x, p.y, p.z + 0.05), axesOf(h), vector3(p.x, p.y, p.z), h
    end

    -- Which handle lies under the pointer: 'x', 'y', 'z', 'ring' or nil.
    local function handleAt(item)
        local origin, axes, ground = handlesOf(item)
        local best, bestD
        local ox, oy = screenOf(origin)
        if ox then
            for name, dir in pairs(axes) do
                local tx, ty = screenOf(origin + dir * ARROW)
                local d = tx and segmentDist(pointer.x, pointer.y, ox, oy, tx, ty)
                if d and d < GRAB and (not bestD or d < bestD) then best, bestD = name, d end
            end
        end
        local prev
        for i = 0, 32 do
            local a = i / 32 * math.pi * 2
            local sx, sy = screenOf(vector3(ground.x + math.cos(a) * RING, ground.y + math.sin(a) * RING, ground.z + 0.05))
            if sx and prev then
                local d = segmentDist(pointer.x, pointer.y, prev[1], prev[2], sx, sy)
                if d < GRAB and (not bestD or d < bestD) then best, bestD = 'ring', d end
            end
            prev = sx and { sx, sy } or nil
        end
        return best
    end

    local function line(a, b, c, alpha)
        DrawLine(a.x, a.y, a.z, b.x, b.y, b.z, c[1], c[2], c[3], alpha or 255)
    end

    -- A thick bar from a to b: a few lines side by side.
    local function bar(a, b, c)
        for _, o in ipairs({ vector3(0.0, 0.0, 0.0), vector3(0.012, 0.0, 0.0), vector3(0.0, 0.012, 0.0), vector3(0.0, 0.0, 0.012) }) do line(a + o, b + o, c) end
    end

    local function drawHandles(item)
        local origin, axes, ground = handlesOf(item)
        local active = ed.drag and ed.drag.handle or ed.hot
        for name, dir in pairs(axes) do
            local c = name == active and HOT or AXIS_COLORS[name]
            local tip = origin + dir * ARROW
            bar(origin, tip, c)
            DrawMarker(28, tip.x, tip.y, tip.z, 0, 0, 0, 0, 0, 0, 0.09, 0.09, 0.09, c[1], c[2], c[3], 230, false, false, 2, false, nil, nil, false)
            World.draw.label(tip.x, tip.y, tip.z + 0.12, name:upper(), c)
        end
        local rc = active == 'ring' and HOT or AXIS_COLORS.ring
        local prev
        for i = 0, 48 do
            local a = i / 48 * math.pi * 2
            local p = vector3(ground.x + math.cos(a) * RING, ground.y + math.sin(a) * RING, ground.z + 0.05)
            if prev then line(prev, p, rc) end
            prev = p
        end
        -- Where it faces: a short tick on the ring.
        local f = axes.y
        line(vector3(ground.x, ground.y, ground.z + 0.05) + f * (RING - 0.2), vector3(ground.x, ground.y, ground.z + 0.05) + f * (RING + 0.25), rc)
    end

    drawMarks = function()
        if not ed then return end
        for _, m in ipairs(ed.marks or {}) do
            local on, over = m.key == ed.pick, m.key == ed.hover
            local color = on and World.draw.colors.focused or (over and HOT or World.draw.colors.valid)
            World.draw.dot(m.p.x, m.p.y, m.p.z + 0.03, color, on and 0.24 or (over and 0.22 or 0.16))
            World.draw.label(m.p.x, m.p.y, m.p.z + (m.tall and 2.15 or 0.6), m.text, color)
        end
        local item = itemOf(ed.pick)
        if item then drawHandles(item) end
    end

    -- The page draws the labels, the ground rings and the handles (mc:editor:marks, MarkLayer.vue) from points worked
    -- out here every frame as fractions of the screen, sent only when something moved and at most every MARKS_MS.
    local MARKS_MS = 15
    local FOOT = { spot = 0.45, ped = 0.45, car = 2.3, prop = 0.6, anchor = 0.9 } -- ground ring radius (metres)
    local TAG = { spot = 2.25, ped = 2.25, car = 2.0, prop = 1.0, anchor = 0.3 }  -- label height over the ground
    local marksAt, marksSent = 0, nil

    local function q(v)
        return math.floor(v * 10000 + 0.5) / 10000
    end

    local function shown(p)
        local sx, sy = screenOf(p)
        if not sx then return nil end
        return q(sx), q(sy)
    end

    -- A ground ring as its centre and two radius ends (the page draws the ellipse through them); nil off screen.
    local function footOf(p, h, r)
        local axes = axesOf(h)
        local c = vector3(p.x, p.y, p.z + 0.03)
        local cx, cy = shown(c)
        local ax, ay = shown(c + axes.x * r)
        local bx, by = shown(c + axes.y * r)
        if not (cx and ax and bx) then return nil end
        return { cx, cy, ax, ay, bx, by }
    end

    local function tagOf(m, cam)
        local i = tonumber(m.key:match('^group:(%d+)$'))
        local ent = i and ed.companyEnts and ed.companyEnts[i]
        if ent and DoesEntityExist(ent) then
            local c = GetEntityCoords(ent)
            m = setmetatable({ p = vector3(c.x, c.y, c.z - offset()) }, { __index = m })
        end
        local lx, ly = shown(vector3(m.p.x, m.p.y, m.p.z + (TAG[m.kind] or 1.0)))
        if not lx then return nil end
        local gx, gy = shown(vector3(m.p.x, m.p.y, m.p.z + 0.03))
        return { k = m.key, f = m.field, x = lx, y = ly, gx = gx, gy = gy, t = m.text, s = m.sub,
            d = math.floor(#(cam - vector3(m.p.x, m.p.y, m.p.z)) + 0.5), g = footOf(m.p, m.h, FOOT[m.kind] or 0.5),
            on = m.key == ed.pick or nil, over = m.key == ed.hover or nil }
    end

    -- The picked item's handles on screen: the origin, the X, Y, Z tips, the ring (-1, -1 where it goes behind the
    -- camera), the facing tick and the handle under the pointer or in the hand.
    local function gizmoOf(item)
        local origin, axes, ground = handlesOf(item)
        local ox, oy = shown(origin)
        if not ox then return nil end
        local out = { o = { ox, oy }, hot = ed.drag and ed.drag.handle or ed.hot, ring = {} }
        for name, dir in pairs(axes) do
            local tx, ty = shown(origin + dir * ARROW)
            if tx then out[name] = { tx, ty } end
        end
        local base = vector3(ground.x, ground.y, ground.z + 0.05)
        for i = 0, 40 do
            local a = i / 40 * math.pi * 2
            local sx, sy = shown(base + vector3(math.cos(a) * RING, math.sin(a) * RING, 0.0))
            out.ring[#out.ring + 1] = sx or -1
            out.ring[#out.ring + 1] = sy or -1
        end
        local ax, ay = shown(base + axes.y * (RING - 0.18))
        local bx, by = shown(base + axes.y * (RING + 0.32))
        if ax and bx then out.face = { ax, ay, bx, by } end
        return out
    end

    local function sendMarks()
        local now = GetGameTimer()
        if now - marksAt < MARKS_MS then return end
        marksAt = now
        local cam, list = GetFinalRenderedCamCoord(), {}
        for _, m in ipairs(ed.marks or {}) do list[#list + 1] = tagOf(m, cam) end
        local item = itemOf(ed.pick)
        local body = json.encode({ action = 'mc:editor:marks', data = { list = list, gizmo = item and gizmoOf(item) or nil } })
        if body == marksSent then return end
        marksSent = body
        SendNuiMessage(body)
    end

    -- Flying: the camera moves on WASD (Q/E) unless a field takes the keys; looking comes from the page's right drag.
    local function fly()
        local pose = Core.freecam.pose()
        if not pose then return end
        local coords, rotation = pose.coords, pose.rotation
        if ed.look then
            local pitch = math.max(-89.0, math.min(89.0, rotation.x - ed.look.y * LOOK))
            rotation = vector3(pitch, 0.0, rotation.z - ed.look.x * LOOK)
            ed.look = nil
        end
        if not ed.typing then
            local z, x = math.rad(rotation.z), math.rad(rotation.x)
            local forward = vector3(-math.sin(z) * math.cos(x), math.cos(z) * math.cos(x), math.sin(x))
            local right = vector3(math.cos(z), math.sin(z), 0.0)
            local move = forward * ((held(KEY.forward) and 1 or 0) - (held(KEY.back) and 1 or 0))
                + right * ((held(KEY.right) and 1 or 0) - (held(KEY.left) and 1 or 0))
                + vector3(0.0, 0.0, (held(KEY.down) and 1 or 0) - (held(KEY.up) and 1 or 0))
            coords = coords + move * (FLY * GetFrameTime() * (held(KEY.fast) and FAST or held(KEY.slow) and SLOW or 1.0))
        end
        Core.freecam.place(coords, rotation)
    end

    local function editFrame()
        DisableAllControlActions(0)
        if CamTool.previewTick() then return end -- a camera move plays (Settings > Camera)
        fly()
        sendMarks()
    end

    -- Moving items -----------------------------------------------------------------------------------------------------

    -- Puts an item's entity where its entry now says (peds keep standing on their root height).
    local function follow(item)
        local ent = ed.ents and ed.ents[item.key]
        if not ent or not DoesEntityExist(ent) then return end
        local p, h = worldOf(item)
        local act = ed.acts and ed.acts[item.key]
        if type(act) == 'table' and (act.chair or act.origin) and Actors.moveSeat(ent, seatAt(act, p), h) then return end
        local rise = ed.rise and ed.rise[item.key] or 0.0
        if item.kind == 'prop' and (item.entry.at.z or 0) ~= 0 then rise = 0.0 end -- a raised prop: its origin, as in the scene
        local z = (item.kind == 'spot' or item.kind == 'ped') and p.z + offset() or p.z + rise
        SetEntityCoordsNoOffset(ent, p.x, p.y, z, false, false, false)
        SetEntityHeading(ent, h)
    end

    -- After a move the entity stays (no flicker): a car settles on its wheels again, a person in a scenario starts it
    -- again at the new place (a scenario keeps to where it began); an item without an entity yet is made.
    local function refresh(key)
        local item = itemOf(key)
        if not item or item.kind == 'anchor' then return end
        if key == 'spots:1' and item.entry.sync then return syncPreview() end
        if key == 'spots:1' then placeCompany() end
        local ent = ed.ents and ed.ents[key]
        if not ent or not DoesEntityExist(ent) then return respawn(key) end
        follow(item)
        local p, h = worldOf(item)
        if item.kind == 'car' then
            if SetVehicleOnGroundProperly(ent) and ed.rise then
                if item.field == 'cars' then Cast.tiltCar(ent, item.entry) end
                ed.rise[key] = GetEntityCoords(ent).z - p.z
            end
            return
        end
        local anim = ed.acts and ed.acts[key]
        if type(anim) == 'table' and (anim.chair or anim.origin) then
            if not Actors.moveSeat(ent, seatAt(anim, p), h) then idle(ent, anim, p, h, function() return DoesEntityExist(ent) end) end
            return
        end
        if (item.kind == 'spot' or item.kind == 'ped') and type(anim) == 'table' and anim.scenario then
            local z = p.z + offset()
            ClearPedTasksImmediately(ent)
            SetEntityCoordsNoOffset(ent, p.x, p.y, z, false, false, false)
            SetEntityHeading(ent, h)
            TaskStartScenarioAtPosition(ent, anim.scenario, p.x, p.y, z, h, 0, anim.scenario:find('SEAT', 1, true) ~= nil, false)
        end
    end

    -- Sets an item's world point and heading; the anchor moves the whole scene with it.
    -- A scene's centre is its character: the anchor goes where spot 1 stands and every local point shifts with it,
    -- so nothing moves in the world (the cameras keep to the character). true when it moved.
    local function centre()
        local w = ed.work
        local hero = w.id ~= 'intro' and (w.spots or {})[1]
        local at = hero and hero.at
        if not at or (math.abs(at.x or 0) < 0.005 and math.abs(at.y or 0) < 0.005) then return false end
        local dx, dy = at.x or 0.0, at.y or 0.0
        local a = w.anchor
        local x, y = CamMath.toWorld(a, dx, dy, 0)
        w.anchor = { x = Place.round(x), y = Place.round(y), z = a.z, h = a.h }
        local seen = {}
        local function shift(p)
            if type(p) ~= 'table' or seen[p] or not tonumber(p.x) or not tonumber(p.y) then return end
            seen[p] = true
            p.x, p.y = Place.round(p.x - dx), Place.round(p.y - dy)
        end
        local function each(list)
            for _, e in ipairs(type(list) == 'table' and list or {}) do
                shift(e.at)
                if type(e.cam) == 'table' then shift(e.cam.pos) shift(e.cam.look) end
            end
        end
        each(w.spots) each(w.extras) each(w.cars) each(w.props)
        for _, list in pairs(type(w.setups) == 'table' and w.setups or {}) do each(list) end
        if type(w.vehicle) == 'table' then shift(w.vehicle.at) end
        if type(w.group) == 'table' then
            if type(w.group.partner) == 'table' then shift(w.group.partner.at) end
            each(w.group.places)
        end
        for _, shot in pairs(type(w.shots) == 'table' and w.shots or {}) do
            for _, k in ipairs(type(shot) == 'table' and type(shot.keys) == 'table' and shot.keys or {}) do shift(k.pos) shift(k.look) end
        end
        return true
    end

    local function placeAt(item, p, h)
        if item.kind == 'anchor' then
            local a = ed.work.anchor
            local before = { x = a.x, y = a.y, z = a.z, h = a.h }
            ed.work.anchor = { x = Place.round(p.x), y = Place.round(p.y), z = Place.round(p.z), h = Place.round((h or a.h or 0.0) % 360.0) }
            for _, other in ipairs(items(ed.work)) do
                if other.kind ~= 'anchor' then follow(other) end
            end
            ed.anchorMoved = ed.anchorMoved or (before.h ~= ed.work.anchor.h)
            return
        end
        local at = Place.toLocal(ed.work.anchor, p)
        local n = item.entry.nudge or {}
        item.entry.at = { x = Place.round(at.x - (n.x or 0.0)), y = Place.round(at.y - (n.y or 0.0)), z = Place.round(p.z - baseZ(p.x, p.y, item.field) - (n.z or 0.0)),
            h = h and Place.localHeading(ed.work.anchor, h) or item.entry.at.h }
        if item.kind == 'walk' then
            local point = ed.work.extras[item.owner].walk[item.index]
            point.x, point.y, point.z = item.entry.at.x, item.entry.at.y, item.entry.at.z
            return
        end
        if item.key == 'spots:1' and centre() then
            for _, other in ipairs(items(ed.work)) do
                if other.kind ~= 'anchor' then follow(other) end
            end
            return
        end
        follow(item)
    end

    local function snap(v, step)
        return math.floor(v / step + 0.5) * step
    end

    -- One drag step: along a handle's axis (the pointer's travel on screen, projected on the axis), round the ring, or
    -- the whole item over the ground (optionally held to X or Y by the axis keys).
    local function dragTo()
        local d = ed.drag
        local item = d and itemOf(d.key)
        if not item then return end
        if not d.moved and screenDist(pointer.x, pointer.y, d.x0, d.y0) < 0.004 then return end
        if not d.moved then
            remember()
            d.moved = true
        end
        local p0, h0 = d.p0, d.h
        if d.handle == 'ring' then
            local hit = onPlane(p0.z)
            if not hit or not d.angle0 then return end
            local angle = math.deg(math.atan(hit.y - p0.y, hit.x - p0.x))
            local turn = angle - d.angle0
            local h = h0 + turn
            if pointer.shift then h = snap(h, SNAP_DEG) end
            placeAt(item, p0, h % 360.0)
        elseif d.handle then
            local dir = axesOf(h0)[d.handle]
            local sx0, sy0 = screenOf(d.origin)
            local sx1, sy1 = screenOf(d.origin + dir)
            if not sx0 or not sx1 then return end
            local ax, ay = (sx1 - sx0) * GetAspectRatio(false), sy1 - sy0
            local len2 = ax * ax + ay * ay
            if len2 < 1e-7 then return end
            local mx, my = (pointer.x - d.x0) * GetAspectRatio(false), pointer.y - d.y0
            local m = (mx * ax + my * ay) / len2
            if pointer.shift then m = snap(m, SNAP_M) end
            local target = p0 + dir * m
            if d.handle ~= 'z' and item.kind ~= 'anchor' then target = vector3(target.x, target.y, baseZ(target.x, target.y, item.field) + d.lift) end
            placeAt(item, target, h0)
        else
            local hit = onPlane(p0.z)
            if not hit then return end
            local target = hit + d.offset
            if ed.axis == 'x' or ed.axis == 'y' then
                local dir = axesOf(h0)[ed.axis]
                local along = (target.x - p0.x) * dir.x + (target.y - p0.y) * dir.y
                target = vector3(p0.x + dir.x * along, p0.y + dir.y * along, p0.z)
            elseif ed.axis == 'z' then
                target = p0
            end
            if pointer.shift then target = vector3(p0.x + snap(target.x - p0.x, SNAP_M), p0.y + snap(target.y - p0.y, SNAP_M), target.z) end
            -- Over a kerb or a slope it keeps its height over the ground.
            if item.kind ~= 'anchor' and ed.axis ~= 'z' then target = vector3(target.x, target.y, baseZ(target.x, target.y, item.field) + d.lift) end
            placeAt(item, target, h0)
        end
        ed.marks = marks(ed.work)
    end

    -- What lies under the pointer: an item's entity, else the nearest label or dot.
    -- What the pointer is on: a label the page reports (tag), else the entity under it, else a point near a label.
    local function pickAt(tag)
        if tag and itemOf(tag) then return tag end
        local from, dir = ray()
        local to = from + dir * 300.0
        local probe = StartExpensiveSynchronousShapeTestLosProbe(from.x, from.y, from.z, to.x, to.y, to.z, -1, PlayerPedId(), 7)
        local _, hit, _, _, ent = GetShapeTestResult(probe)
        if hit == 1 and ent and ent ~= 0 then
            for key, e in pairs(ed.ents or {}) do
                if e == ent then return key end
            end
        end
        local best, bestD
        for _, m in ipairs(ed.marks or {}) do
            for _, lift in ipairs({ 0.03, m.tall and 1.0 or 0.3, TAG[m.kind] or 1.0 }) do
                local sx, sy = screenOf(vector3(m.p.x, m.p.y, m.p.z + lift))
                local dist = sx and screenDist(pointer.x, pointer.y, sx, sy)
                if dist and dist < 0.035 and (not bestD or dist < bestD) then best, bestD = m.key, dist end
            end
        end
        return best
    end

    local function choose(key)
        ed.pick = itemOf(key) and key or nil
        ed.hot = nil
        push()
    end

    -- The page's pointer: { type = down | move | up | wheel | look, x, y, button, delta, dx, dy, alt, shift, ctrl }.
    function CALLS.pointer(d)
        local v = type(d.value) == 'table' and d.value or {}
        local x, y = tonumber(v.x), tonumber(v.y)
        if x and y then pointer.x, pointer.y = x, y end
        if v.shift ~= nil then pointer.shift = v.shift == true end
        if v.type == 'look' then
            ed.look = { x = (ed.look and ed.look.x or 0) + (tonumber(v.dx) or 0), y = (ed.look and ed.look.y or 0) + (tonumber(v.dy) or 0) }
            return { ok = true }
        end
        if v.type == 'move' then
            if ed.drag then
                dragTo()
            else
                local picked = itemOf(ed.pick)
                ed.hot = picked and handleAt(picked) or nil
                ed.hover = not ed.hot and pickAt(v.tag) or nil
            end
            return { ok = true }
        end
        if v.type == 'down' and v.button == 0 then
            -- A handle of the picked item first; else whatever is under the pointer is picked and dragged over the ground.
            local picked = itemOf(ed.pick)
            local handle = picked and handleAt(picked)
            local item = picked
            if not handle then
                choose(pickAt(v.tag))
                item = itemOf(ed.pick)
            end
            if item then
                local p, h = worldOf(item)
                local p0 = vector3(p.x, p.y, p.z)
                local origin = handlesOf(item)
                local hit = onPlane(p0.z)
                local over = item.kind ~= 'anchor' and ((item.entry.at.z or 0.0) + ((item.entry.nudge or {}).z or 0.0)) or 0.0
                ed.drag = { key = item.key, handle = handle, p0 = p0, h = h, origin = origin, x0 = pointer.x, y0 = pointer.y, lift = over,
                    offset = hit and (p0 - hit) or vector3(0.0, 0.0, 0.0), moved = false,
                    angle0 = hit and math.deg(math.atan(hit.y - p0.y, hit.x - p0.x)) or nil }
            end
            return { ok = true, pick = ed.pick }
        end
        if v.type == 'up' then
            local d = ed.drag
            ed.drag = nil
            if d and d.moved then
                -- The whole scene moved: the hidden player (who streams the area) follows, and the stage is built again.
                if d.key == 'anchor' or ed.anchorMoved then
                    local an = ed.work.anchor
                    Player.place(vec4(an.x, an.y, an.z, an.h or 0.0))
                    build()
                else
                    refresh(d.key)
                end
                ed.anchorMoved = nil
                edited()
            end
            return { ok = true }
        end
        if v.type == 'wheel' and ed.pick then
            local item = itemOf(ed.pick)
            if not item then return { ok = false } end
            local step = (tonumber(v.delta) or 0) < 0 and 1 or -1
            remember()
            local p, h = worldOf(item)
            if v.alt then
                placeAt(item, vector3(p.x, p.y, p.z + step * 0.05), h)
            else
                placeAt(item, vector3(p.x, p.y, p.z), (h + step * (v.shift and 15.0 or (v.ctrl and 1.0 or 5.0))) % 360.0)
            end
            if item.kind == 'anchor' then build() end
            -- Once the wheel rests, a car settles and a scenario starts again facing the new way.
            ed.wheelToken = (ed.wheelToken or 0) + 1
            local token, key = ed.wheelToken, item.key
            if item.kind ~= 'anchor' then
                SetTimeout(400, function()
                    if ed and ed.wheelToken == token and not ed.drag then refresh(key) end
                end)
            end
            edited()
            return { ok = true }
        end
        return { ok = true }
    end

    -- The company the stage shows round the focused place: 0 alone, 1 a partner, 2 or 3 a crew.
    function CALLS.company(d)
        local n = math.floor(tonumber(d.value) or 0)
        if n < 0 or n > 3 then return { ok = false, error = 'invalid' } end
        ed.company = n
        if Formation.together(ed.work.group) then placeCompany() else build() end
        push()
        return { ok = true }
    end

    -- The page says a text field has the keys (WASD must not fly then).
    function CALLS.typing(d)
        ed.typing = d.value == true
        return { ok = true }
    end

    function CALLS.pick(d)
        choose(d.value)
        return { ok = true }
    end

    function CALLS.axis(d)
        if not AXES[d.value] then return { ok = false, error = 'invalid' } end
        ed.axis = d.value
        push()
        return { ok = true }
    end

    -- The camera goes to look at an item from a few metres away.
    function CALLS.focus(d)
        local item = itemOf(d.value or ed.pick)
        if not item then return { ok = false, error = 'invalid' } end
        local p = worldOf(item)
        local pose = Core.freecam.pose()
        local yaw = pose and pose.rotation.z or 0.0
        local r = math.rad(yaw)
        local from = vector3(p.x + math.sin(r) * 5.0, p.y - math.cos(r) * 5.0, p.z + 2.6)
        local pitch, look = CamMath.lookRot(from.x, from.y, from.z, p.x, p.y, p.z + 0.9)
        Core.freecam.place(from, vector3(pitch, 0.0, look))
        return { ok = true }
    end

    -- The inspector: nudges in the item's own frame (metres, degrees) or exact local values.
    function CALLS.nudge(d)
        local v = type(d.value) == 'table' and d.value or {}
        local item = itemOf(v.key or ed.pick)
        if not item then return { ok = false, error = 'invalid' } end
        remember()
        local p, h = worldOf(item)
        local dir = axesOf(h)
        local by = tonumber(v.by) or 0
        local target = vector3(p.x, p.y, p.z)
        if v.axis == 'x' or v.axis == 'y' or v.axis == 'z' then target = target + dir[v.axis] * by end
        -- A step along X or Y keeps a part's height over the ground.
        if (v.axis == 'x' or v.axis == 'y') and item.kind ~= 'anchor' then
            local n = item.entry.nudge or {}
            target = vector3(target.x, target.y, baseZ(target.x, target.y, item.field) + (item.entry.at.z or 0.0) + (n.z or 0.0))
        end
        placeAt(item, target, v.axis == 'h' and (h + by) % 360.0 or h)
        if item.kind == 'anchor' then build() else refresh(item.key) end
        edited()
        return { ok = true }
    end

    -- The ground under an item: in a role scene a part's own ground (where the game stands it), else the first ground
    -- found below it; nil when there is none.
    local function groundUnder(item)
        local p, h = worldOf(item)
        if ed.work.id ~= 'intro' and item.kind ~= 'anchor' and item.field ~= 'vehicle' then return vector3(p.x, p.y, baseZ(p.x, p.y, item.field)), h end
        local found, z = GetGroundZFor_3dCoord(p.x, p.y, p.z + 2.0, false)
        if not found then return nil, h end
        return vector3(p.x, p.y, z), h
    end

    -- Puts an item on the ground under it.
    function CALLS.ground(d)
        local item = itemOf(d.value or ed.pick)
        if not item then return { ok = false, error = 'invalid' } end
        local p, h = groundUnder(item)
        if not p then return fail('editorui.no_ground') end
        remember()
        placeAt(item, p, h)
        if item.kind == 'anchor' then build() else refresh(item.key) end
        edited()
        return { ok = true }
    end

    -- Every part on its ground at once (the scene centre stays where it is).
    function CALLS.groundAll()
        remember()
        for _, item in ipairs(items(ed.work)) do
            if item.kind ~= 'anchor' then
                local p, h = groundUnder(item)
                if p then
                    placeAt(item, p, h)
                    refresh(item.key)
                end
            end
        end
        edited()
        return { ok = true }
    end

    -- What the item does: a Config.Animations pose id, an arrivals library name, or 'random' / 'none'.
    local function actOf(id)
        for _, a in ipairs(Config.Animations or {}) do
            if a.id == id then return { scenario = a.scenario, dict = a.dict, clip = a.clip, flag = a.flag }, id end
        end
        local e = Arrivals and Arrivals[id]
        if type(e) == 'table' and (e.scenario or e.dict) and not e.walk and not e.taxi then
            return { scenario = e.scenario, dict = e.dict, clip = e.clip, flag = e.flag or (e.dict and 1 or nil), prop = e.prop }, nil
        end
        return nil, nil
    end

    function CALLS.act(d)
        local v = type(d.value) == 'table' and d.value or {}
        local item = itemOf(v.key or ed.pick)
        if not item or (item.kind ~= 'spot' and item.kind ~= 'ped') or type(v.id) ~= 'string' then return { ok = false, error = 'invalid' } end
        remember()
        local act, pose = actOf(v.id)
        item.entry.female, item.entry.sync, item.entry.pair = nil, nil, nil
        if v.id == 'random' and item.kind == 'spot' then
            item.entry.act, item.entry.anim = nil, 'random'
        elseif pose and item.kind == 'spot' then
            item.entry.act, item.entry.anim = nil, pose
        elseif act then
            item.entry.act = act
        else
            item.entry.act = nil
        end
        respawn(item.key)
        edited()
        return { ok = true }
    end

    -- A pasted animation ("dict : clip" or "dict clip" as pleb.masters copies it) or a scenario name.
    function CALLS.animPaste(d)
        local v = type(d.value) == 'table' and d.value or {}
        local item = itemOf(v.key or ed.pick)
        if not item or (item.kind ~= 'spot' and item.kind ~= 'ped') or type(v.text) ~= 'string' then return { ok = false, error = 'invalid' } end
        local text = v.text:match('^%s*(.-)%s*$')
        local dict, clip = text:match('^([%w_%-@%.]+)%s*[:%s]%s*([%w_%-@%.%^]+)$')
        local act
        if dict and DoesAnimDictExist(dict) then
            act = { dict = dict, clip = clip, flag = 1 }
        elseif text:match('^[%u_%d]+$') and #text > 6 then
            act = { scenario = text }
        else
            return fail('editorui.bad_anim')
        end
        remember()
        item.entry.female, item.entry.sync, item.entry.pair = nil, nil, nil
        item.entry.act, item.entry.anim = act, nil
        respawn(item.key)
        edited()
        return { ok = true }
    end

    function CALLS.model(d)
        local v = type(d.value) == 'table' and d.value or {}
        local item = itemOf(v.key or ed.pick)
        if not item or (item.kind ~= 'prop' and item.kind ~= 'ped' and item.field ~= 'cars') or not Place.model(v.model) then return fail('editorui.bad_model') end
        remember()
        item.entry.model = v.model
        respawn(item.key)
        edited()
        return { ok = true }
    end

    -- The ground point the camera looks at (or 4 m ahead of it), facing the camera: where new items go.
    local function lookPoint()
        local pose = Core.freecam.pose()
        if not pose then return nil end
        local dir = Core.freecam.direction(pose.rotation)
        local to = pose.coords + dir * 60.0
        local probe = StartExpensiveSynchronousShapeTestLosProbe(pose.coords.x, pose.coords.y, pose.coords.z, to.x, to.y, to.z, 1 | 16, PlayerPedId(), 7)
        local _, hit, at = GetShapeTestResult(probe)
        local p = hit == 1 and at or (pose.coords + dir * 4.0)
        local found, z = GetGroundZFor_3dCoord(p.x, p.y, p.z + 1.5, false)
        return vector3(p.x, p.y, found and z or p.z), (pose.rotation.z + 180.0) % 360.0
    end

    -- A new item where the camera looks: a character place (spots, partner, crew), a person, a car or a prop.
    function CALLS.add(d)
        local v = type(d.value) == 'table' and d.value or {}
        local field = v.field
        local p, h = lookPoint()
        if not p then return fail('editorui.no_ground') end
        local at = Place.toLocal(ed.work.anchor, p)
        at.z = Place.round(p.z - baseZ(p.x, p.y, field))
        at.h = Place.localHeading(ed.work.anchor, h)
        remember()
        local entry
        if field == 'spots' then
            ed.work.spots = ed.work.spots or {}
            if #ed.work.spots >= maxSpots() then return fail('editorui.limit') end
            entry = { at = at, anim = 'random' }
            table.insert(ed.work.spots, entry)
        elseif field == 'partner' or field == 'crew' then
            entry = { at = at, anim = 'random', act = { scenario = 'WORLD_HUMAN_HANG_OUT_STREET' } }
            table.insert(layoutOf(field), entry)
        elseif field == 'extras' then
            if not Place.model(v.model or '') then return fail('editorui.bad_model') end
            ed.work.extras = ed.work.extras or {}
            entry = { id = ('npc%d'):format(#ed.work.extras + 1), model = v.model, at = at, act = actOf(v.act or 'stand') or { scenario = 'WORLD_HUMAN_STAND_IMPATIENT' }, sex = 'm' }
            table.insert(ed.work.extras, entry)
        elseif field == 'cars' then
            if not Place.model(v.model or '') then return fail('editorui.bad_model') end
            ed.work.cars = ed.work.cars or {}
            entry = { model = v.model, at = at }
            table.insert(ed.work.cars, entry)
        elseif field == 'vehicle' then
            ed.work.vehicle = { at = at }
        elseif field == 'props' then
            if not Place.model(v.model or '') then return fail('editorui.bad_model') end
            ed.work.props = ed.work.props or {}
            if #ed.work.props >= MAX_PROPS then return fail('editorui.limit') end
            entry = { model = v.model, at = at, collision = false }
            table.insert(ed.work.props, entry)
        else
            return { ok = false, error = 'invalid' }
        end
        build()
        for _, item in ipairs(items(ed.work)) do
            if item.entry == entry or (field == 'vehicle' and item.field == 'vehicle') then ed.pick = item.key end
        end
        edited()
        return { ok = true }
    end

    -- Ctrl+D: a copy of the picked item half a metre to its right.
    function CALLS.duplicate()
        local item = itemOf(ed.pick)
        if not item or item.kind == 'anchor' or item.kind == 'walk' or item.field == 'vehicle' or item.key:find('^group:') then return { ok = false, error = 'invalid' } end
        remember()
        local entry = copy(item.entry)
        local list = (item.field == 'partner' or item.field == 'crew') and layoutOf(item.field) or ed.work[item.field]
        entry.at = { x = entry.at.x + 0.6, y = entry.at.y, z = entry.at.z, h = entry.at.h }
        if entry.id then entry.id = entry.id .. 'b' end
        table.insert(list, entry)
        build()
        for _, it in ipairs(items(ed.work)) do
            if it.entry == entry then ed.pick = it.key end
        end
        edited()
        return { ok = true }
    end

    -- A scene ped starts walking (a point 4 m ahead of it, which it walks to and back) or walks one point further; speed:
    -- 1 walk, 2 jog, 3 run.
    function CALLS.walk(d)
        local item = itemOf(ed.pick)
        if not item or item.field ~= 'extras' then return { ok = false, error = 'invalid' } end
        remember()
        local e, v = item.entry, type(d.value) == 'table' and d.value or {}
        if v.speed then
            e.speed = tonumber(v.speed)
        elseif v.stop then
            e.walk, e.speed = nil, nil
        else
            e.walk = e.walk or {}
            local from = e.walk[#e.walk] or e.at
            local r = math.rad(tonumber(e.at.h) or 0.0)
            e.walk[#e.walk + 1] = { x = Place.round(from.x - math.sin(r) * 4.0), y = Place.round(from.y + math.cos(r) * 4.0), z = 0.0, h = 0.0 }
        end
        ed.marks = marks(ed.work)
        edited()
        return { ok = true }
    end

    -- Del: the picked item goes (the anchor and the last character place stay).
    function CALLS.drop(d)
        local item = itemOf(d.value or ed.pick)
        if not item or item.kind == 'anchor' or item.key:find('^group:') then return { ok = false, error = 'invalid' } end
        if item.field == 'spots' and #(ed.work.spots or {}) <= 1 then return fail('editorui.last_spot') end
        remember()
        if item.kind == 'walk' then
            local owner = ed.work.extras[item.owner]
            table.remove(owner.walk, item.index)
            if #owner.walk == 0 then owner.walk, owner.speed = nil, nil end
        elseif item.field == 'vehicle' then
            ed.work.vehicle = nil
        elseif item.field == 'partner' or item.field == 'crew' then
            table.remove(layoutOf(item.field), item.index)
        else
            table.remove(ed.work[item.field], item.index)
        end
        ed.pick = nil
        build()
        edited()
        return { ok = true }
    end

    -- The whole scene to a new place (its heading kept unless given): the hidden player streams it, the stage is built
    -- there and the camera comes along to look at it.
    local function moveScene(p, h)
        remember()
        local a = ed.work.anchor
        ed.work.anchor = { x = Place.round(p.x), y = Place.round(p.y), z = Place.round(p.z), h = Place.round(((h or a.h) or 0.0) % 360.0) }
        local an = ed.work.anchor
        Player.place(vec4(an.x, an.y, an.z, an.h))
        Stream.at(vector3(an.x, an.y, an.z), 80.0, 4000)
        build()
        CALLS.focus({ value = 'anchor' })
        edited()
    end

    -- 'Bring the scene here': where the camera looks.
    function CALLS.bring()
        local p = lookPoint()
        if not p then return fail('editorui.no_ground') end
        CreateThread(function() moveScene(p, nil) end)
        return { ok = true }
    end

    -- A pasted point (vec3, vec4 or plain numbers, as /mc_point prints them) for the picked item, or for the scene centre
    -- (the whole scene goes there). /mc_point gives a ped's root, about a metre over the ground: it lands on the ground.
    -- Without a height the ground is found; without a heading the item keeps its own.
    local function parsePoint(text)
        local nums = {}
        -- The digit of 'vector4' / 'vec3' is not a number of the point.
        local clean = tostring(text or ''):gsub('[%a_]+%d*', ' ')
        for n in clean:gmatch('-?%d+%.?%d*') do nums[#nums + 1] = tonumber(n) end
        if #nums < 2 then return nil end
        return nums[1], nums[2], nums[3], nums[4]
    end

    local function groundNear(x, y, z)
        if not z then
            RequestCollisionAtCoord(x, y, 500.0)
            Wait(500)
            local found, gz = GetGroundZFor_3dCoord(x, y, 1000.0, false)
            return found and gz or 30.0
        end
        local found, gz = GetGroundZFor_3dCoord(x, y, z + 1.0, false)
        if found and math.abs(gz - z) < 2.5 then return gz end
        return z
    end

    function CALLS.pasteAt(d)
        local v = type(d.value) == 'table' and d.value or {}
        local x, y, z, h = parsePoint(v.text)
        if not x then return fail('editorui.bad_point') end
        local item = itemOf(v.key or ed.pick)
        if not item then return { ok = false, error = 'invalid' } end
        CreateThread(function()
            local gz = groundNear(x, y, z)
            if not ed then return end
            if item.kind == 'anchor' then return moveScene(vector3(x, y, gz), h) end
            remember()
            local _, keep = worldOf(item)
            placeAt(item, vector3(x, y, gz), h and (h % 360.0) or keep)
            refresh(item.key)
            CALLS.focus({ value = item.key })
            edited()
        end)
        return { ok = true }
    end

    function CALLS.anchorTo(d)
        return CALLS.pasteAt({ value = { key = 'anchor', text = d.value } })
    end

    -- Ctrl+Z: the scene as it was before the last change.
    function CALLS.history()
        local last = ed.history and table.remove(ed.history)
        if not last then return { ok = false, error = 'invalid' } end
        ed.work = last
        relink()
        if not itemOf(ed.pick) then ed.pick = nil end
        Env.apply(ed.work)
        build()
        edited()
        return { ok = true }
    end

    -- Test: the real selection scene, read-only, the cast wearing the admin's own look -----------------------------

    local function headBlend(ped)
        local blob = string.rep('\0\0\0\0\0\0\0\0', 10)
        if not Citizen.InvokeNative(0x2746BD9D88C5C5D0, ped, blob, true) then return nil end
        local function int(at) return (string.unpack('<i4', blob, at)) end
        local function float(at) return (string.unpack('<f', blob, at)) end
        return { shapeFirst = int(1), shapeSecond = int(9), shapeThird = int(17), skinFirst = int(25), skinSecond = int(33),
            skinThird = int(41), shapeMix = float(49), skinMix = float(57), thirdMix = float(65) }
    end

    local function overlays(ped, names)
        local out = {}
        for i, name in ipairs(names) do
            local ok, style, _, color, second, opacity = GetPedHeadOverlayData(ped, i - 1)
            if ok then out[name] = { style = style == 255 and 0 or style, opacity = style == 255 and 0.0 or opacity, color = color, secondColor = second } end
        end
        return out
    end

    -- The admin's own look as an illenium-shaped skin, which every clothing bridge can put on a local ped.
    local function ownLook()
        local ped, shared = PlayerPedId(), Bridge.skin
        local skin = { components = {}, props = {}, faceFeatures = {}, tattoos = {}, headOverlays = overlays(ped, shared.HEAD_OVERLAYS) }
        for id = 0, 11 do
            skin.components[id + 1] = { component_id = id, drawable = GetPedDrawableVariation(ped, id), texture = GetPedTextureVariation(ped, id) }
        end
        for i, id in ipairs(LOOK_PROPS) do
            skin.props[i] = { prop_id = id, drawable = GetPedPropIndex(ped, id), texture = GetPedPropTextureIndex(ped, id) }
        end
        for i, name in ipairs(shared.FACE_FEATURES) do skin.faceFeatures[name] = GetPedFaceFeature(ped, i - 1) end
        skin.hair = { style = GetPedDrawableVariation(ped, 2), texture = GetPedTextureVariation(ped, 2), color = GetPedHairColor(ped), highlight = GetPedHairHighlightColor(ped) }
        skin.eyeColor = GetPedEyeColor(ped)
        local ok, blend = pcall(headBlend, ped)
        skin.headBlend = ok and blend or nil
        return { model = GetEntityModel(ped), skin = skin, format = 'illenium' }
    end

    -- Stand-in cards for every spot (three for a single-actor scene), all wearing the same look.
    local function mockCast(scene)
        local okLook, look = pcall(ownLook)
        look = okLook and look or { model = GetEntityModel(PlayerPedId()) }
        local gender = look.model == joaat('mp_f_freemode_01') and 'f' or 'm'
        local count = scene.mode == 'single' and 3 or math.max(1, #(scene.spots or {}))
        local cards, previews = {}, {}
        for i = 1, count do
            cards[i] = { index = i, kind = 'character', gender = gender, firstname = t('editorui.stand_in'), lastname = tostring(i), last = i == 1 }
            previews[i] = look
        end
        return cards, previews
    end

    local function runTest(scene)
        if not ed or ed.testing then return end
        ed.testing, ed.focus = true, 1
        ed.gen = ed.gen + 1
        CamTool.endPreview()
        DoScreenFadeOut(300)
        waitFade(true)
        CamTool.stop()
        Track.clear('editor')
        ed.cast, ed.previews = mockCast(scene)
        setMode('test')
        -- The company the editor shows plays along (up and down change it, testKeys).
        Scene.testCompany(type(scene.group) == 'table' and ed.company or 0)
        local ok, err = pcall(Scene.open, scene, ed.cast, ed.previews, 1)
        if not ok then print(('^1[daddy_multichar] editor test: %s^7'):format(err)) end
        DoScreenFadeIn(500)
    end

    function CALLS.test()
        local scene, err = SceneSchema.normalize(copy(ed.work))
        if not scene then return fail('editorui.invalid', { tostring(err) }) end
        CreateThread(function() runTest(scene) end)
        return { ok = true }
    end

    -- Back from a test: the scene goes, the editor's stage and camera come back.
    function Editor.stopTest()
        if not ed or not ed.testing or ed.stopping then return end
        ed.stopping = true
        DoScreenFadeOut(300)
        waitFade(true)
        pcall(Scene.destroy)
        Scene.endTest()
        Director.stop()
        Rig.release()
        if not ed then return end
        ed.testing, ed.stopping, ed.cast, ed.previews = false, false, nil, nil
        stage()
        CamTool.start()
        setMode('edit')
        DoScreenFadeIn(400)
    end

    -- Saving and loading through the admin pad ----------------------------------------------------------------------

    local PAD_ERRORS = { stale = 'editorui.stale', session_expired = 'editorui.expired', not_found = 'editorui.not_found' }

    local function padFail(reply)
        local code = tostring(reply and reply.error or 'server_error')
        return fail(PAD_ERRORS[code] or 'editorui.failed', { code }, code)
    end

    -- A renamed scene saves as a new one, so it carries no revision. silent: the autosave (no toast).
    function CALLS.save(d)
        local silent = type(d) == 'table' and d.silent == true
        local scene, err = SceneSchema.normalize(copy(ed.work))
        if not scene then return fail('editorui.invalid', { tostring(err) }) end
        local revision = ed.work.id == ed.origId and ed.revision or nil
        local reply = Admin.pad('world.saveScene', { scene = ed.work, revision = revision })
        if not reply.ok then return padFail(reply) end
        local data = type(reply.data) == 'table' and reply.data or {}
        ed.revision, ed.origId, ed.dirty = data.revision or reply.revision or revision, ed.work.id, false
        ed.status = 'saved'
        if not silent then Nui.toast('editorui.saved', 'success') end
        push()
        return { ok = true }
    end

    saveNow = function()
        if not ed then return end
        ed.status = 'saving'
        push()
        local reply = CALLS.save({ silent = true })
        if ed and not reply.ok then
            ed.status = 'failed'
            push()
        end
    end

    function CALLS.delete()
        if not ed.origId then return { ok = false, error = 'invalid' } end
        local reply = Admin.pad('world.deleteScene', { id = ed.origId })
        if not reply.ok then return padFail(reply) end
        ed.origId, ed.revision, ed.dirty = nil, nil, true
        Nui.toast('editorui.deleted', 'success')
        push()
        return { ok = true }
    end

    -- A scene row of world.get ({ id, revision, readonly, scene, ... }), or nil and the failed reply.
    local function sceneRow(id)
        local reply = Admin.pad('world.get', {})
        if not reply.ok then return nil, reply end
        for _, row in ipairs(type(reply.data) == 'table' and type(reply.data.scenes) == 'table' and reply.data.scenes or {}) do
            if row.id == id and type(row.scene) == 'table' then return row end
        end
        return nil, { error = 'not_found' }
    end

    -- The stored revision of a pushed scene; 0 when only a preset or a pack has it (its first save makes the row).
    local function revisionOf(id)
        local row = sceneRow(id)
        return row and tonumber(row.revision) or 0
    end

    function CALLS.load(d)
        if type(d.value) ~= 'string' then return { ok = false, error = 'invalid' } end
        local row, reply = sceneRow(d.value)
        if not row then return padFail(reply) end
        CreateThread(function() Editor.switch(row.scene, tonumber(row.revision) or 0) end)
        return { ok = true }
    end

    -- A new scene where the camera looks.
    function CALLS.new()
        local ground = anchorHere()
        if not ground then return fail('editorui.no_ground') end
        CreateThread(function() Editor.switch(Editor.blank(ground, newId()), nil) end)
        return { ok = true }
    end

    function CALLS.close()
        Editor.close()
        return { ok = true }
    end

    -- One panel or key call; nothing but close while a test or a placement runs.
    function Editor.call(d)
        if not ed then return { ok = false, error = 'state' } end
        local fn = type(d) == 'table' and CALLS[d.name]
        if not fn then return { ok = false, error = 'invalid' } end
        -- The page's own background calls (pointer, typing) are not the player's: no 'busy' for them.
        if (ed.testing or ed.mode == 'place') and (d.name == 'pointer' or d.name == 'typing') then return { ok = true } end
        if (ed.testing or ed.mode == 'place') and d.name ~= 'close' then return { ok = false, error = 'busy' } end
        return fn(d)
    end

    -- Opening and closing --------------------------------------------------------------------------------------------

    local function pressed(control)
        return IsDisabledControlJustPressed(0, control)
    end

    -- Camera mode: Tab the panel, Enter capture, Backspace undo, Space preview, Esc the exit prompt.
    local function cameraKeys()
        if pressed(37) then return setMode('panel') end
        if pressed(201) or pressed(191) then return Editor.call({ name = 'capture' }) end
        if pressed(194) then return Editor.call({ name = 'undo' }) end
        if pressed(22) then return Editor.call({ name = 'preview' }) end
        if pressed(200) or pressed(322) then return setMode('panel', { prompt = 'exit' }) end
    end

    -- Test mode: arrows (or A and D) move the focus along the cast, Esc or Backspace end the test.
    local function testKeys()
        DisableAllControlActions(0)
        if pressed(200) or pressed(322) or pressed(194) then return CreateThread(Editor.stopTest) end
        -- Any of the test keys ends the idle film first.
        for _, c in ipairs({ 172, 173, 174, 175, 32, 33, 34, 35, 201, 22 }) do
            if pressed(c) and Scene.stopCinema() then return end
        end
        -- Up and down (W, S): alone or with a partner round a role scene's character.
        local company = (pressed(172) or pressed(32)) and 1 or (pressed(173) or pressed(33)) and -1 or 0
        local partners = ((Config.Selection or {}).Partners or {}).Enabled ~= false
        if company ~= 0 and partners and not ed.stopping and type(ed.work.group) == 'table' then
            ed.company = ((ed.company or 0) + company) % 2
            local n = ed.company
            CreateThread(function() Scene.testCompany(n) end) -- the page is built again (it waits)
            push()
        end
        local step = (pressed(175) or pressed(35)) and 1 or (pressed(174) or pressed(34)) and -1 or 0
        if step == 0 or not ed.cast or ed.stopping then return end
        ed.focus = (ed.focus - 1 + step) % #ed.cast + 1
        Scene.focus(ed.focus)
    end

    local function frame()
        if not ed or ed.mode == 'place' then return end
        HideHudAndRadarThisFrame()
        DisableFrontendThisFrame()
        if ed.testing then return testKeys() end
        if ed.mode == 'edit' then return editFrame() end
        sendMarks()
        if ed.mode ~= 'camera' then return end
        DisableAllControlActions(0)
        if CamTool.previewTick() then return end
        CamTool.step()
        cameraKeys()
    end

    local function openData()
        local anims = {}
        for _, a in ipairs(Config.Animations or {}) do anims[#anims + 1] = { id = a.id, gender = a.gender } end
        -- What a place or a person can do: the idle poses, then the arrivals library's standing moves.
        local acts, peds, cars, seen = {}, {}, {}, {}
        for _, a in ipairs(Config.Animations or {}) do acts[#acts + 1] = { id = a.id, label = 'anim.' .. a.id } end
        local names = {}
        for name, e in pairs(Arrivals or {}) do
            if type(e) == 'table' and (e.scenario or e.dict) and not e.walk and not e.taxi and not e.next then names[#names + 1] = name end
        end
        table.sort(names)
        for _, name in ipairs(names) do acts[#acts + 1] = { id = name } end
        -- Models the role scenes use, as the add menus' first choices.
        for _, preset in pairs((Config.Scenes or {}).Presets or {}) do
            for _, e in ipairs(type(preset) == 'table' and preset.extras or {}) do
                if type(e.model) == 'string' and not seen[e.model] then seen[e.model], peds[#peds + 1] = true, e.model end
            end
            for _, c in ipairs(type(preset) == 'table' and preset.cars or {}) do
                if type(c.model) == 'string' and not seen[c.model] then seen[c.model], cars[#cars + 1] = true, c.model end
            end
        end
        table.sort(peds)
        table.sort(cars)
        return {
            scene = ed.work, scenes = ed.scenes, selected = ed.selected, mode = ed.mode, dirty = ed.dirty, revision = ed.revision,
            animations = anims, props = Config.EditorProps or {}, weathers = WEATHERS, eases = EASES,
            limits = { spots = maxSpots(), props = MAX_PROPS, keys = MAX_KEYS },
            acts = acts, peds = peds, cars = cars, pick = ed.pick or false, axis = ed.axis or 'ground', status = ed.status or 'saved',
        }
    end

    -- The player's ground point with the actors facing the gameplay camera, for a scene made from nothing.
    local function here()
        local ped = PlayerPedId()
        local p = GetEntityCoords(ped)
        return { x = Place.round(p.x), y = Place.round(p.y), z = Place.round(p.z - 1.0), h = Place.round((GetGameplayCamRot(2).z + 180.0) % 360.0) }
    end

    -- A scene becomes the working copy. revision nil: a new scene that was never saved.
    local function adopt(scene, revision)
        ed.work, ed.selected, ed.dirty = copy(scene), 'establish', revision == nil
        ed.pick, ed.drag, ed.history, ed.axis, ed.status = nil, nil, {}, 'ground', revision == nil and 'waiting' or 'saved'
        -- A role scene's spots are its solo layout: one list, so moving a spot moves the solo place too.
        local setups = ed.work.setups
        if type(setups) == 'table' and type(setups.solo) == 'table' and #setups.solo > 0 then ed.work.spots = setups.solo end
        ed.revision, ed.origId = revision, revision and scene.id or nil
        ed.company = ed.work.kind == 'partner' and 1 or 0
        -- An older role scene whose character stands off its centre is centred on it once, and saved.
        if centre() then
            ed.dirty, ed.status = true, 'waiting'
            SetTimeout(SAVE_MS, function()
                if ed and ed.dirty and not ed.testing then saveNow() end
            end)
        end
    end

    local function enter(scene)
        local revision = scene and revisionOf(scene.id) or nil
        DoScreenFadeOut(300)
        waitFade(true)
        if not ed then return end
        State.set('editor')
        Links.suppress(true)
        adopt(scene or Editor.blank(here(), newId()), revision)
        Player.hide()
        stage()
        CamTool.start(firstPose(ed.work))
        Frame.on('editor', frame)
        if not Nui.open('editor', openData()) then return Editor.close() end
        setMode('edit')
        DoScreenFadeIn(500)
    end

    -- Opened by the server's 'editor' push (admin checked, private bucket set, pad session open).
    function Editor.open(scene, scenes)
        if ed then return CreateThread(function() Editor.switch(scene, scene and revisionOf(scene.id) or nil) end) end
        if Cutscene.active() then return TriggerServerEvent('daddy_multichar:admin:close') end
        local ped = PlayerPedId()
        marksSent = nil
        ed = { gen = 0, mode = 'camera', scenes = scenes or {}, back = { coords = GetEntityCoords(ped), heading = GetEntityHeading(ped) } }
        Admin.close(true)
        Admin.heartbeat('editor', true)
        CamTool.debugCommands()
        CreateThread(function() enter(scene) end)
    end

    -- Another scene in the open editor, under a short fade; nil makes a new one where the camera looks.
    function Editor.switch(scene, revision)
        if not ed or ed.testing then return end
        local ground = not scene and anchorHere()
        DoScreenFadeOut(300)
        waitFade(true)
        if not ed then return end
        CamTool.endPreview()
        Stream.dropIpls()
        adopt(scene or Editor.blank(ground or ed.work.anchor, newId()), scene and revision or nil)
        stage()
        CamTool.stop()
        CamTool.start(firstPose(ed.work))
        push()
        DoScreenFadeIn(400)
    end

    -- Everything back as it was: the world, the player where they stood, the page closed, the pad session ended.
    local function teardown(s, now)
        if s.testing then pcall(Scene.destroy) end
        CamTool.endPreview()
        if not now then
            DoScreenFadeOut(300)
            waitFade(true)
        end
        Frame.off('editor')
        CamTool.stop()
        Track.clear('editor')
        Track.clear('seat')
        for dict in pairs(dicts) do RemoveAnimDict(dict) end
        dicts = {}
        Stream.dropIpls()
        Env.restore()
        Player.place(vec4(s.back.coords.x, s.back.coords.y, s.back.coords.z, s.back.heading))
        Player.release()
        Links.suppress(false)
        Nui.close()
        Admin.heartbeat('editor', false)
        TriggerServerEvent('daddy_multichar:admin:close')
        State.set('playing')
        if not now then DoScreenFadeIn(500) end
    end

    -- force: at once, without fades (resource stop).
    function Editor.close(force)
        local s = ed
        if not s then return end
        ed = nil
        if World.placement.active() then World.placement.cancel() end
        if force then return teardown(s, true) end
        CreateThread(function() teardown(s, false) end)
    end

    function Editor.active()
        return ed ~= nil
    end

    function Editor.anchor()
        return ed and ed.work and ed.work.anchor or nil
    end

    RegisterNetEvent('daddy_multichar:editor', function(payload)
        payload = type(payload) == 'table' and payload or {}
        Editor.open(type(payload.scene) == 'table' and payload.scene or nil, type(payload.scenes) == 'table' and payload.scenes or {})
    end)

    MC.Callback('mc:editor:call', function(data)
        return Editor.call(data)
    end)

    MC.Callback('mc:editor:input', function(data)
        if not ed or ed.testing or ed.mode == 'place' then return { ok = false, error = 'state' } end
        if data.mode ~= 'camera' and data.mode ~= 'panel' then return { ok = false, error = 'invalid' } end
        setMode(data.mode)
        return { ok = true }
    end)

    AddEventHandler('onResourceStop', function(resource)
        if resource == GetCurrentResourceName() then Editor.close(true) end
    end)
end

-- The editor's camera: Core.freecam with the wheel as zoom, key capture into anchor-local values, shot previews
-- through the Rig and Director, and the /mc_pose /mc_point calibration commands (Config.Debug, confirmed admins).
do
    CamTool = {}

    local LOOK_AHEAD, GRACE_MS = 10.0, 250
    local saved, previewing, previewFrom = nil, false, 0
    local registered = false

    -- Starts freecam at a pose ({ coords, rotation, fov }), the saved one, or the gameplay camera.
    function CamTool.start(pose)
        pose = pose or saved
        if Core.freecam.active() then return end
        Core.freecam.start(pose and { coords = pose.coords, rotation = pose.rotation, fov = pose.fov } or nil)
    end

    function CamTool.stop()
        saved = Core.freecam.pose() or saved
        Core.freecam.stop()
    end

    function CamTool.pose()
        return Core.freecam.pose() or saved
    end

    -- Moves the running freecam to a world pose.
    function CamTool.place(pose)
        saved = pose
        Core.freecam.place(pose.coords, pose.rotation, pose.fov)
    end

    -- Wheel up narrows the lens, wheel down widens it.
    local function notch()
        if IsDisabledControlJustPressed(0, 15) or IsDisabledControlJustPressed(0, 241) then return -1 end
        if IsDisabledControlJustPressed(0, 14) or IsDisabledControlJustPressed(0, 242) then return 1 end
        return 0
    end

    -- Every frame in camera mode, with the controls disabled.
    function CamTool.step()
        Core.freecam.step()
        local n = notch()
        if n ~= 0 then Core.freecam.zoom(n * 2.0) end
    end

    -- The camera now as a key local to the anchor: position, a point it looks at and the lens.
    function CamTool.capture(anchor)
        local pose = Core.freecam.pose()
        if not pose then return nil end
        local look = pose.coords + Core.freecam.direction(pose.rotation) * LOOK_AHEAD
        return { pos = Place.toLocal(anchor, pose.coords), look = Place.toLocal(anchor, look), fov = Place.round(pose.fov) }
    end

    -- A key local to the anchor as a freecam pose (CamMath.pose turns it into the world).
    function CamTool.poseOf(key, anchor)
        local p = CamMath.pose(key, anchor)
        return { coords = vector3(p.x, p.y, p.z), rotation = vector3(p.rx, 0.0, p.rz), fov = p.fov }
    end

    -- Plays a shot the way the game will (Director.playList splits it at cut keys); freecam comes back afterwards.
    function CamTool.preview(shot, anchor)
        CamTool.stop()
        Rig.start(CamMath.pose(shot.keys[1], anchor))
        Director.playList({ keys = shot.keys, ms = shot.ms or 4000, ease = shot.ease }, { anchor = anchor, dipMs = 400 })
        previewing, previewFrom = true, GetGameTimer()
    end

    function CamTool.endPreview()
        if not previewing then return end
        previewing = false
        Director.stop()
        Rig.release()
        if not IsScreenFadedIn() then DoScreenFadeIn(200) end
        CamTool.start(saved)
    end

    -- While a preview runs: true. It ends by itself or on Space, Backspace or Esc.
    function CamTool.previewTick()
        if not previewing then return false end
        local key = IsDisabledControlJustPressed(0, 22) or IsDisabledControlJustPressed(0, 194) or IsDisabledControlJustPressed(0, 200)
        local over = GetGameTimer() - previewFrom > GRACE_MS and not Director.busy()
        if key or over then CamTool.endPreview() end
        return true
    end

    -- Calibration ------------------------------------------------------------------------------------------------------

    local function v3(p)
        return ('vec3(%.2f, %.2f, %.2f)'):format(p.x, p.y, p.z)
    end

    local function output(text)
        print(text)
        lib.setClipboard(text)
        lib.notify({ description = Core.locale.t('editorui.copied'), type = 'inform' })
    end

    -- What the centre of the screen points at (map and props), or nil over the sky.
    local function aimPoint()
        local from, rot = GetFinalRenderedCamCoord(), GetFinalRenderedCamRot(2)
        local to = from + Core.freecam.direction(rot) * 500.0
        local probe = StartExpensiveSynchronousShapeTestLosProbe(from.x, from.y, from.z, to.x, to.y, to.z, 1 | 16, PlayerPedId(), 7)
        local _, hit, coords = GetShapeTestResult(probe)
        return (hit == 1 or hit == true) and coords or nil
    end

    -- /mc_pose: the rendered camera as a key, plus the editor's local form while it is open.
    local function printPose()
        local pos, rot, fov = GetFinalRenderedCamCoord(), GetFinalRenderedCamRot(2), GetFinalRenderedCamFov()
        local look = pos + Core.freecam.direction(rot) * LOOK_AHEAD
        local lines = { ('{ pos = %s, look = %s, fov = %.1f },'):format(v3(pos), v3(look), fov) }
        local anchor = Editor.anchor()
        if anchor then
            local p, l = Place.toLocal(anchor, pos), Place.toLocal(anchor, look)
            lines[2] = ('-- local: { pos = { x = %.2f, y = %.2f, z = %.2f }, look = { x = %.2f, y = %.2f, z = %.2f }, fov = %.1f },'):format(p.x, p.y, p.z, l.x, l.y, l.z, fov)
        end
        output(table.concat(lines, '\n'))
    end

    -- /mc_point: the player as a vec4 and the point under the centre of the screen as a vec3.
    local function printPoint()
        local ped = PlayerPedId()
        local p = GetEntityCoords(ped)
        local lines = { ('vec4(%.2f, %.2f, %.2f, %.1f)'):format(p.x, p.y, p.z, GetEntityHeading(ped)) }
        local hit = aimPoint()
        if hit then lines[2] = v3(hit) end
        output(table.concat(lines, '\n'))
    end

    -- Registers the calibration commands once, in debug builds, after the server confirmed an admin.
    function CamTool.debugCommands()
        if registered or Config.Debug ~= true then return end
        registered = true
        RegisterCommand('mc_pose', printPose, false)
        RegisterCommand('mc_point', printPoint, false)
        RegisterCommand('mc_arrival', Live.test, false)
        RegisterCommand('mc_scene', Look.debugScene, false)
    end

    -- The boot answer carries the server's isAdmin; the admin and editor pushes call debugCommands themselves.
    if Config.Debug == true then
        AddEventHandler('daddy_multichar:client:state', function()
            if MC.session and MC.session.isAdmin then CamTool.debugCommands() end
        end)
    end

    -- Placement for the scene editor: World.placement for the anchor, spots, the vehicle and props, and the conversion
    -- between the world and the scene's local frame (CamMath). Placement stops freecam when it ends; Place.lastPose
    -- keeps where its camera was, so the editor can start freecam there again.
    Place = { lastPose = nil }

    local function round(v)
        return math.floor(v * 1000.0 + 0.5) / 1000.0
    end
    Place.round = round

    -- CamMath answers with three numbers or with a table; both read the same here.
    local function triple(a, b, c)
        if type(a) ~= 'number' then return a.x, a.y, a.z end
        return a, b, c
    end

    function Place.toLocal(anchor, p)
        local x, y, z = triple(CamMath.toLocal(anchor, p.x, p.y, p.z))
        return { x = round(x), y = round(y), z = round(z) }
    end

    function Place.toWorld(anchor, p)
        local x, y, z = triple(CamMath.toWorld(anchor, p.x, p.y, p.z))
        return { x = x, y = y, z = z }
    end

    -- Headings between the frames, local ones kept within -180..180.
    function Place.localHeading(anchor, h)
        return round((h - (anchor.h or 0.0) + 180.0) % 360.0 - 180.0)
    end

    function Place.worldHeading(anchor, h)
        return ((anchor.h or 0.0) + (h or 0.0)) % 360.0
    end

    -- A placed point as the scene stores it: the anchor in the world, everything else local to the anchor.
    function Place.result(kind, anchor, coords)
        if kind == 'anchor' then
            return { x = round(coords.x), y = round(coords.y), z = round(coords.z), h = round((coords.w or 0.0) % 360.0) }
        end
        local at = Place.toLocal(anchor, coords)
        at.h = Place.localHeading(anchor, coords.w or 0.0)
        return at
    end

    -- A model name the game knows, for props typed into the editor.
    function Place.model(name)
        return type(name) == 'string' and #name <= 64 and name:match('^[%w_]+$') ~= nil and IsModelInCdimage(joaat(name))
    end

    -- The ground under a point, or nil over water and the void.
    function Place.ground(p)
        local found, z = GetGroundZFor_3dCoord(p.x, p.y, p.z + 2.0, false)
        if not found then return nil end
        return { x = round(p.x), y = round(p.y), z = round(z) }
    end

    local REQUESTS = {
        anchor = function() return { shape = 'point', reach = 150.0 } end,
        spot = function(opts) return { shape = 'point', presentation = 'ped', model = opts.model or 'mp_m_freemode_01', scenario = opts.scenario } end,
        vehicle = function() return { shape = 'point' } end,
        prop = function(opts) return { shape = 'point', presentation = 'prop', model = opts.model } end,
    }

    -- Starts placing kind ('anchor' | 'spot' | 'vehicle' | 'prop'); done(at) gets the stored form, or nil when cancelled.
    -- opts: { anchor, existing (world {x,y,z,w}), heading, label, model?, scenario?, backdrop? }.
    function Place.start(kind, opts, done)
        local request = REQUESTS[kind](opts)
        request.reach = request.reach or 60.0
        request.label, request.heading, request.backdrop = opts.label, opts.heading, opts.backdrop
        request.existing = opts.existing and { coords = opts.existing } or nil
        Place.lastPose = Core.freecam.pose()
        return World.placement.start(request, {
            hud = function(hud)
                Place.lastPose = Core.freecam.pose() or Place.lastPose
                MC.Send('mc:editor:place', hud)
            end,
            done = function(result)
                done(result and result.coords and Place.result(kind, opts.anchor, result.coords) or nil)
            end,
        })
    end
end

-- The admin panel: opened by the server's 'admin' push (the pad session is already open), every panel call relayed
-- to the pad callback by a whitelisted name, a heartbeat while the panel or the editor is open, closed from the page.
do
    Admin = {}

    local PREFIX = 'daddy_multichar:admin'
    local BEAT_MS = 30000
    local ENDPOINTS = {}
    for _, name in ipairs({
        'players.search', 'account.get', 'codes.list', 'requests.list', 'archive.list', 'audit.list', 'world.get', 'doctor.run',
        'slots.give', 'slots.revoke', 'tebex.claim', 'codes.create', 'codes.disable', 'requests.decide', 'archive.restore',
        'archive.purge', 'character.archive', 'character.deceased', 'character.revive', 'player.relog', 'world.saveScene',
        'world.deleteScene', 'world.setActive', 'world.saveSpawn', 'world.deleteSpawn', 'world.reset',
    }) do ENDPOINTS[name] = true end

    local open = false
    local beats, beatToken = {}, 0

    -- One pad endpoint; the reply is the pad's { ok, data, revision } or { ok = false, error }.
    function Admin.pad(name, data)
        local ok, reply = pcall(lib.callback.await, PREFIX .. ':call', false, name, data or {})
        if ok and type(reply) == 'table' then return reply end
        return { ok = false, error = 'server_error' }
    end

    local function beat(token)
        if token ~= beatToken or not next(beats) then return end
        TriggerServerEvent(PREFIX .. ':heartbeat')
        SetTimeout(BEAT_MS, function() beat(token) end)
    end

    -- Keeps the pad session alive while any owner ('admin', 'editor') needs it; the editor's camera mode calls nothing.
    function Admin.heartbeat(owner, on)
        local before = next(beats) ~= nil
        beats[owner] = on and true or nil
        if before or not next(beats) then return end
        beatToken = beatToken + 1
        local token = beatToken
        SetTimeout(BEAT_MS, function() beat(token) end)
    end

    function Admin.open()
        if open or Editor.active() then return end
        local free = State.is('playing') or State.is('idle')
        if not free or not Nui.open('admin', {}) then return TriggerServerEvent(PREFIX .. ':close') end
        open = true
        CamTool.debugCommands()
        Nui.input('ui')
        Admin.heartbeat('admin', true)
    end

    -- silent keeps the page and the pad session for the editor, which takes both over.
    function Admin.close(silent)
        if not open then return end
        open = false
        Admin.heartbeat('admin', false)
        if silent then return end
        Nui.close()
        TriggerServerEvent(PREFIX .. ':close')
    end

    function Admin.isOpen()
        return open
    end

    local LOCAL = {}

    function LOCAL.close()
        Admin.close()
        return { ok = true }
    end

    -- The Scenes tab opens the editor through the server's command, which checks the admin again.
    function LOCAL.editor(data)
        local id = type(data) == 'table' and data.id or nil
        if id ~= nil and (type(id) ~= 'string' or #id > 64 or not id:match('^[%w_:%-]+$')) then return { ok = false, error = 'invalid' } end
        Admin.close(true)
        ExecuteCommand(('%s %s'):format(Config.Commands.Editor, id or ''))
        SetTimeout(5000, function()
            if not open and not Editor.active() then Nui.close() end
        end)
        return { ok = true }
    end

    MC.Callback('mc:admin:call', function(req)
        if not open then return { ok = false, error = 'session_expired' } end
        if LOCAL[req.name] then return LOCAL[req.name](req.data) end
        if not ENDPOINTS[req.name] then return { ok = false, error = 'not_found' } end
        return Admin.pad(req.name, type(req.data) == 'table' and req.data or {})
    end)

    -- Pad pushes ({ topic, revision, payload }) reach the page while the panel or the editor shows.
    RegisterNetEvent(PREFIX .. ':sync', function(message)
        if type(message) ~= 'table' or not (open or Editor.active()) then return end
        MC.Send('mc:admin:data', { topic = message.topic, payload = message.payload })
    end)

    RegisterNetEvent('daddy_multichar:admin', function()
        Admin.open()
    end)

    AddEventHandler('onResourceStop', function(resource)
        if resource == GetCurrentResourceName() then Admin.close(true) end
    end)
end
