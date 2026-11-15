-- The world editor: a setup panel's places edited in the world itself, like a level editor. The page keeps the
-- focus and owns the mouse (a dock on the left, the rest is the view): it sends the pointer and the shortcuts here,
-- the game keeps WASD, Space and C for flying (SetNuiFocusKeepInput). A click places the picked kind and saves it at
-- once; a place is clicked to pick it, dragged to move it, turned with the wheel, nudged with the arrows; Del, Ctrl+D
-- and Ctrl+Z. What a spot will be shows under the pointer as a see-through ghost standing on the surface: the ped
-- with its scenario, the prop, or a standing person where a player is sent. Placed spots far off show the same way.
-- An area is drawn here too, PolyZone style: fly over its edge and press E for a corner under the camera (or click
-- where the pointer is), its walls rise as it goes; floor, ceiling, size and radius are set from the dock.
--   local edit = World.worldedit({ call = fn(name, data), records = fn, refresh = fn, send = fn(action, data),
--                                  reach = 150, zoneReach = 400, color = { r, g, b }, suspend = fn, resume = fn, maxPoints = 32,
--                                  preview = fn(kind, coords, settings, final, uid, model), model = fn(row) })
-- preview: a product that measures what it places (a station's work surface) returns nil for other kinds, else
-- { ghosts = { { key, model, at, heading, scenario } }, lines = { { a, b, ok } }, dots = { { at, ok } }, problem,
-- settings, coords }: drawn while placing, moving or picked; final = true (it may wait) before every save of the spot,
-- whose settings and coords it sets, and a problem refuses the save. model(row) == false: the spot shows no model.
-- NUI: world:edit { enabled, kinds = { kind = { preview = { models }, scenario, presentation } } },
--      world:pointer { type, x, y, button, dx, dy, delta, ctrl, shift, alt }, world:command { name, ... },
--      world:pick { kind, label, record, shapes }, world:typing { on }
-- It sends: world:selected { uid, record } | nil, world:mode { mode, kind }, world:problem { code }, world:area { ... }.
World = World or {}

local MOVE, FAST, FINE, LOOK = 8.0, 4.0, 0.2, 0.25 -- fly metres a second, Shift and Alt multipliers, degrees a pixel
local HOVER, DRAW = 0.03, 120.0                     -- how near the pointer picks a place (screen heights); draw range
local STREAMED = 80.0                               -- spots this near the player are the world's own (anchors), no ghost
local KEY = { forward = 32, back = 33, left = 34, right = 35, up = 22, down = 26, fast = 21, fine = 19 } -- WASD, Space, C, Shift, Alt
local MIN_SIZE = 0.5                                -- the smallest box side and sphere radius the server keeps

local function held(control) return IsDisabledControlPressed(0, control) end
local function copy(t) return json.decode(json.encode(t)) end
local function vec(p) return p and vector3(p.x + 0.0, p.y + 0.0, (p.z or 0.0) + 0.0) end
local function plain(p, w) return { x = p.x, y = p.y, z = p.z, w = w } end
local function round(v, step) step = step or 0.01 return math.floor(v / step + 0.5) * step end

-- How far below its origin a model's bottom is (0 when the game does not have it).
local function bottomOf(model)
    local hash = model and joaat(model)
    if not hash or not IsModelInCdimage(hash) then return 0.0 end
    local min = GetModelDimensions(hash)
    return min.z
end

function World.worldedit(opts)
    local edit = {}
    local s -- the running editor, nil when off
    local typing = false
    local shapes = World.shapes

    local function send(action, data) opts.send(action, data) end
    local function problem(code) send('world:problem', { code = code }) end

    -- Places ---------------------------------------------------------------------------------------------

    local function listOf(record) local r = opts.records() or {} return record == 'zone' and (r.zones or {}) or (r.entities or {}) end
    local function find(record, uid)
        for _, row in ipairs(listOf(record)) do if row.uid == uid then return row end end
    end
    -- Keeps the panel's list in step with a save before the server's refresh comes back.
    local function store(record, row, removed)
        local list = listOf(record)
        for i, old in ipairs(list) do
            if old.uid == row.uid then
                if removed then table.remove(list, i) else list[i] = row end
                return
            end
        end
        if not removed then list[#list + 1] = row end
    end

    -- Where a place is drawn and picked: a spot's coords, an area's middle.
    local function anchor(record, row)
        if record == 'entity' then return vec(row.coords) end
        local shape = DL.geo.fromRecord(row)
        local c = shape and DL.geo.centroid(shape)
        return c and vector3(c.x, c.y, c.z or (row.minZ or 0.0) + 1.0)
    end

    -- Kinds: what each shows ------------------------------------------------------------------------------

    -- The first model of a list the game has (a custom one may not be streamed).
    local function firstModel(list)
        for _, name in ipairs(type(list) == 'table' and list or { list }) do
            if type(name) == 'string' and name ~= '' and IsModelInCdimage(joaat(name)) then return name end
        end
    end
    local function kindOf(kind)
        local k = s.kinds[kind]
        if not k then return {} end
        if k.model == nil then k.model = firstModel(k.preview) or false end
        return k
    end
    -- The model a spot shows: its own, else its kind's (none when the product says it stands without one).
    local function modelOf(row)
        if opts.model and opts.model(row) == false then return nil end
        if row.model and row.model ~= '' then return row.model end
        return kindOf(row.kind).model or nil
    end
    local function scenarioOf(row)
        if row.scenario and row.scenario ~= '' then return row.scenario end
        return kindOf(row.kind).scenario
    end

    -- Ghosts ---------------------------------------------------------------------------------------------

    -- A see-through copy of a model, one per key, moved where asked; ghosts not drawn this frame go. A ped stands
    -- with its scenario, as the world will show it.
    local function ghost(key, model, at, heading, alpha, scenario)
        local g = s.ghosts[key]
        if g and (g.model ~= model or g.scenario ~= scenario or not DoesEntityExist(g.entity)) then
            if DoesEntityExist(g.entity) then DeleteEntity(g.entity) end
            g, s.ghosts[key] = nil, nil
        end
        if not g then
            local hash = joaat(model)
            if not IsModelInCdimage(hash) then return end
            RequestModel(hash)
            if not HasModelLoaded(hash) then return end
            local ped = IsModelAPed(hash)
            pcall(function() exports['FeloxAC']:CreatePed(hash) end) --[[FeloxAC:auto]]
            pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
            local entity = ped and CreatePed(4, hash, at.x, at.y, at.z, heading, false, false) or CreateObject(hash, at.x, at.y, at.z, false, false, false)
            SetModelAsNoLongerNeeded(hash)
            if not entity or entity == 0 then return end
            SetEntityCollision(entity, false, false)
            FreezeEntityPosition(entity, true)
            SetEntityInvincible(entity, true)
            if ped then
                SetBlockingOfNonTemporaryEvents(entity, true)
                SetPedCanRagdoll(entity, false)
                if scenario then TaskStartScenarioInPlace(entity, scenario, 0, true) end
            end
            g = { entity = entity, model = model, scenario = scenario }
            s.ghosts[key] = g
        end
        SetEntityCoordsNoOffset(g.entity, at.x, at.y, at.z, false, false, false)
        SetEntityHeading(g.entity, heading)
        SetEntityAlpha(g.entity, alpha, false)
        g.seen = true
    end

    local function clearGhosts(all)
        for key, g in pairs(s.ghosts) do
            if all or not g.seen then
                if DoesEntityExist(g.entity) then DeleteEntity(g.entity) end
                s.ghosts[key] = nil
            else
                g.seen = false
            end
        end
    end

    local function ghostEntity(key) local g = s and s.ghosts[key] return g and g.entity or 0 end

    -- What the product measures for a spot (opts.preview); nil for kinds it does not know.
    local function previewOf(kind, coords, settings, final, uid, model)
        if not opts.preview then return nil end
        local ok, p = pcall(opts.preview, kind, coords, settings or {}, final, uid, model)
        return ok and p or nil
    end

    -- Its whole layout as ghosts, its lines and a green or red dot for each check.
    local function drawPreview(p)
        for i, g in ipairs(p.ghosts or {}) do
            ghost('pv:' .. (g.key or i), g.model, vec(g.at), g.heading or 0.0, p.problem and 110 or 170, g.scenario)
        end
        for _, l in ipairs(p.lines or {}) do World.draw.line(l[1], l[2], l.ok == false and World.draw.colors.invalid or World.draw.colors.valid, 200) end
        for _, d in ipairs(p.dots or {}) do World.draw.dot(d.at.x, d.at.y, d.at.z + 0.01, d.ok and World.draw.colors.valid or World.draw.colors.invalid, 0.06) end
    end

    -- Picking ---------------------------------------------------------------------------------------------

    local function mode(name, extra)
        local data = extra or {}
        data.mode = name
        send('world:mode', data)
    end

    local function select(record, uid)
        if s.slots and s.slots.uid ~= uid then s.slots = nil mode('select') end
        if s.spot and s.spot.uid ~= uid then s.spot = nil mode('select') end
        s.selected = uid and { record = record, uid = uid } or nil
        send('world:selected', s.selected)
    end
    local function selectedRow() return s.selected and find(s.selected.record, s.selected.uid) end

    -- Saving ------------------------------------------------------------------------------------------------

    -- Saves a place; on success the list has the server's copy (with its new revision).
    local function save(record, row)
        local result = opts.call(record == 'zone' and 'saveZone' or 'saveEntity', row)
        if not result.ok then
            problem(result.field and ('%s:%s'):format(result.field, result.detail or 'invalid') or result.error or 'failed')
            return nil
        end
        local saved = result.record or (result.data and result.data.record)
        if saved then store(record, saved) end
        return saved
    end

    -- A spot about to be saved, measured again where it now is (its settings and coords from the product); nil when
    -- a check fails (the problem is shown and nothing is saved).
    local function measured(row)
        local p = previewOf(row.kind, row.coords, row.settings, true, row.uid, row.model)
        if not p then return row end
        if p.problem then
            problem(p.problem)
            return nil
        end
        local out = copy(row)
        out.settings = type(out.settings) == 'table' and out.settings or {}
        for key, value in pairs(p.settings or {}) do out.settings[key] = value end
        if p.coords then out.coords = p.coords end
        return out
    end

    local function remember(step)
        s.undo[#s.undo + 1] = step
        if #s.undo > 50 then table.remove(s.undo, 1) end
    end

    -- An edited place waits a moment for more nudges before it is saved; the undo step keeps where it was.
    local function changed(record, row, before)
        s.dirty = { record = record, row = row, before = s.dirty and s.dirty.row.uid == row.uid and s.dirty.before or before, at = GetGameTimer() + 500 }
        store(record, row)
    end
    local function flush()
        local d = s.dirty
        if not d then return end
        s.dirty = nil
        local row = d.row
        if d.record == 'entity' then row = measured(row) end
        local saved = row and save(d.record, row)
        if saved then remember({ kind = 'update', record = d.record, before = d.before })
        else store(d.record, d.before) end
    end

    -- Moving --------------------------------------------------------------------------------------------------

    -- Moves a place by an offset; an area moves every corner and its floor and ceiling.
    local function moved(record, row, d, turn)
        local out = copy(row)
        if record == 'entity' then
            local c = out.coords
            out.coords = { x = c.x + d.x, y = c.y + d.y, z = c.z + d.z, w = ((c.w or 0.0) + (turn or 0.0)) % 360 }
            return out
        end
        for _, p in ipairs(out.points or {}) do p.x, p.y = p.x + d.x, p.y + d.y end
        if out.center then out.center = { x = out.center.x + d.x, y = out.center.y + d.y, z = (out.center.z or 0.0) + d.z } end
        if out.minZ then out.minZ, out.maxZ = out.minZ + d.z, out.maxZ + d.z end
        if turn and out.rotation then out.rotation = (out.rotation + turn) % 360 end
        return out
    end

    local function nudge(d, turn)
        local row = selectedRow()
        if not row then return end
        changed(s.selected.record, moved(s.selected.record, row, d, turn), copy(row))
    end

    -- Down onto whatever is under a spot.
    local function ground()
        local row = selectedRow()
        if not row or s.selected.record ~= 'entity' then return end
        local c = row.coords
        local found, z = GetGroundZFor_3dCoord(c.x, c.y, c.z + 1.0, false)
        if found then nudge(vector3(0.0, 0.0, z - bottomOf(modelOf(row)) - c.z)) end
    end

    -- An area's numbers set from the dock (floor, ceiling, size, turn, radius), with the same limits as drawing it.
    -- A box keeps its floor when its height changes.
    local function zoneField(row, field, value)
        value = tonumber(value)
        if not value then return nil end
        local out = copy(row)
        if field == 'minZ' and out.maxZ then out.minZ = math.min(value, out.maxZ - MIN_SIZE)
        elseif field == 'maxZ' and out.minZ then out.maxZ = math.max(value, out.minZ + MIN_SIZE)
        elseif field == 'radius' then out.radius = math.max(MIN_SIZE, value)
        elseif field == 'rotation' then out.rotation = value % 360
        elseif (field == 'sizeX' or field == 'sizeY' or field == 'sizeZ') and out.size then
            local axis = field:sub(5):lower()
            local size = math.max(MIN_SIZE, value)
            if axis == 'z' and out.center then out.center.z = out.center.z - out.size.z * 0.5 + size * 0.5 end
            out.size[axis] = size
        else
            return nil
        end
        return out
    end

    -- Camera ---------------------------------------------------------------------------------------------------

    local function fly()
        local pose = DL.freecam.pose()
        if not pose then return end
        local coords, rotation = pose.coords, pose.rotation
        if s.look.x ~= 0 or s.look.y ~= 0 then
            local pitch = math.max(-89.0, math.min(89.0, rotation.x - s.look.y * LOOK))
            rotation = vector3(pitch, 0.0, rotation.z - s.look.x * LOOK)
            s.look = { x = 0, y = 0 }
        end
        if not typing then
            local z = math.rad(rotation.z)
            local forward, right = vector3(-math.sin(z), math.cos(z), 0.0), vector3(math.cos(z), math.sin(z), 0.0)
            local move = forward * ((held(KEY.forward) and 1 or 0) - (held(KEY.back) and 1 or 0))
                + right * ((held(KEY.right) and 1 or 0) - (held(KEY.left) and 1 or 0))
                + vector3(0.0, 0.0, (held(KEY.up) and 1 or 0) - (held(KEY.down) and 1 or 0))
            coords = coords + move * (MOVE * GetFrameTime() * (held(KEY.fast) and FAST or held(KEY.fine) and FINE or 1.0))
        end
        local away = coords - s.origin
        if #away > s.fly then coords = s.origin + away * (s.fly / #away) end
        DL.freecam.place(coords, rotation)
    end

    -- Flies to look down at a place.
    local function goTo(record, uid)
        local row = find(record, uid)
        local at = row and anchor(record, row)
        if not at then return end
        if #(at - s.origin) > s.fly then return problem('too_far') end
        local pose = DL.freecam.pose()
        local z = math.rad(pose and pose.rotation.z or 0.0)
        DL.freecam.place(vector3(at.x + math.sin(z) * 7.0, at.y - math.cos(z) * 7.0, at.z + 5.0), vector3(-35.0, 0.0, pose and pose.rotation.z or 0.0))
        select(record, uid)
    end

    -- Pointer ------------------------------------------------------------------------------------------------

    -- The reach of what is being placed: an area's corners may go further than a spot.
    local function reachNow() return s.area and s.zoneReach or s.reach end

    local function aim()
        local hit = World.cursor.hit(s.fly * 2.0, ghostEntity('pick'))
        if hit and #(hit - s.origin) > reachNow() then return hit, 'too_far' end
        return hit
    end

    -- The ground under the camera: where E puts a corner or a spot, PolyZone style (fly over the line, press E).
    local function below()
        local pose = DL.freecam.pose()
        if not pose then return nil end
        local from = pose.coords
        local probe = StartExpensiveSynchronousShapeTestLosProbe(from.x, from.y, from.z, from.x, from.y, from.z - 400.0, 1 | 16, ghostEntity('pick'), 7)
        local _, hit, coords = GetShapeTestResult(probe)
        if hit ~= 1 then return nil, 'no_surface' end
        local at = vector3(coords.x, coords.y, coords.z)
        if #(at - s.origin) > reachNow() then return at, 'too_far' end
        return at
    end

    -- The place under the pointer: the nearest anchor on screen within reach.
    local function hover()
        local camera, best, found = GetFinalRenderedCamCoord(), HOVER, nil
        for _, record in ipairs({ 'entity', 'zone' }) do
            for _, row in ipairs(listOf(record)) do
                local at = anchor(record, row)
                if at and #(at - camera) < DRAW then
                    local d = World.cursor.distanceTo(at.x, at.y, at.z)
                    if d and d < best then best, found = d, { record = record, uid = row.uid } end
                end
            end
        end
        return found
    end

    -- A spot of the picked kind at a point (the pointer's or the camera's); saved at once.
    local function placeSpot(at, why)
        if not at or why then return problem(why or 'no_surface') end
        local pick = s.pick
        -- a prop or ped stands on the surface: its origin goes up by how far its bottom is below it
        local model = kindOf(pick.kind).model or nil
        local z = at.z - bottomOf(model)
        local row = { kind = pick.kind, label = pick.label, active = true, settings = copy(pick.settings or {}), shape = 'point',
            coords = { x = at.x, y = at.y, z = z, w = s.heading } }
        -- a product that measures it (opts.preview) gets the point the pointer is on and sets where it really goes
        local p = previewOf(pick.kind, { x = at.x, y = at.y, z = at.z, w = s.heading }, row.settings, true)
        if p and p.problem then return problem(p.problem) end
        if p then
            for key, value in pairs(p.settings or {}) do row.settings[key] = value end
            row.coords = p.coords or row.coords
        end
        local saved = save('entity', row)
        if not saved then return end
        remember({ kind = 'create', record = 'entity', uid = saved.uid })
        select('entity', saved.uid)
    end

    -- Areas -------------------------------------------------------------------------------------------------
    -- s.area: { kind, label, shapes, shape, row (the area being redrawn), points, minZ, maxZ, floorSet, ceilingSet,
    --           center, radius, radiusSet, a, b, depthAt, height, box = { center, size, rotation }, drag, hoverKind, hoverIndex }

    local function areaSettle()
        local a = s.area
        if a.shape ~= 'polygon' or #a.points == 0 then return end
        local low, high = shapes.heights(a.points)
        if not a.floorSet then a.minZ = low - 1.0 end
        if not a.ceilingSet then a.maxZ = high + 4.0 end
        if a.maxZ < a.minZ + MIN_SIZE then a.maxZ = a.minZ + MIN_SIZE end
    end

    -- The box while it is drawn from two corners of a side and its depth, or as set.
    local function areaBox()
        local a = s.area
        if a.box then return a.box end
        if not a.a or not a.b then return nil end
        local box = shapes.box(a.a, a.b, a.depthAt or s.aimAt or s.belowAt or a.b, a.height)
        return box and { center = box.center, size = box.size, rotation = box.rotation, drawing = not a.depthAt }
    end

    local function sideMiddle(i)
        local p = s.area.points
        local a, b = p[i], p[i % #p + 1]
        return { x = (a.x + b.x) * 0.5, y = (a.y + b.y) * 0.5, z = (a.z + b.z) * 0.5 }
    end

    -- What is wrong with the area as drawn, if anything.
    local function areaProblem()
        local a = s.area
        if a.shape == 'polygon' then
            if #a.points < 3 then return 'too_few' end
            if shapes.crossing(a.points) then return 'crossing' end
            for _, p in ipairs(a.points) do
                if #(vector3(p.x, p.y, p.z) - s.origin) > s.zoneReach then return 'too_far' end
            end
        elseif a.shape == 'sphere' then
            if not a.center then return 'unfinished' end
            if a.radius < MIN_SIZE then return 'too_small' end
        else
            if not a.box then return 'unfinished' end
            local size = a.box.size
            if size.x < MIN_SIZE or size.y < MIN_SIZE or size.z < MIN_SIZE then return 'too_small' end
        end
    end

    -- The step the dock explains, and every number it shows.
    local function areaState()
        local a = s.area
        if not a then return { active = false } end
        local out = { active = true, kind = a.kind, label = a.label, shape = a.shape, shapes = a.shapes, editing = a.row ~= nil, problem = areaProblem(),
            maxPoints = s.maxPoints, reach = s.zoneReach }
        if a.shape == 'polygon' then
            out.step = #a.points < 3 and 'polygon_start' or 'polygon'
            out.corners, out.minZ, out.maxZ = #a.points, a.minZ, a.maxZ
            out.area = #a.points >= 3 and round(shapes.area(a.points), 0.1) or 0
        elseif a.shape == 'sphere' then
            out.step = not a.center and 'sphere_center' or not a.radiusSet and 'sphere_radius' or 'sphere_done'
            out.radius = a.radius
        else
            local box = areaBox()
            out.step = a.box and 'box_done' or not a.a and 'box_a' or not a.b and 'box_b' or 'box_depth'
            if box then out.size, out.rotation = { x = box.size.x, y = box.size.y, z = box.size.z }, box.rotation end
            out.height = a.height
        end
        -- Not finished yet is the step the dock shows, not a problem.
        if out.problem == 'unfinished' or out.problem == 'too_few' then out.problem = nil end
        return out
    end

    -- The dock follows the area: at once after a change, at most every 100 ms while dragging.
    local function areaSend(now)
        if not now and GetGameTimer() - (s.areaSent or 0) < 100 then return end
        s.areaSent = GetGameTimer()
        send('world:area', areaState())
    end

    local function areaStart(kind, label, kindShapes, row)
        flush()
        s.pick, s.slots, s.spot = nil, nil, nil
        local list = type(kindShapes) == 'table' and #kindShapes > 0 and kindShapes or { 'polygon' }
        local shape = row and row.shape or list[1]
        local pose = DL.freecam.pose()
        local floor = (pose and pose.coords.z or s.origin.z) - 1.0
        local a = { kind = kind, label = label, shapes = list, shape = shape, row = row and copy(row), points = {}, minZ = floor, maxZ = floor + 5.0,
            radius = 2.0, height = 3.0 }
        if row and shape == 'polygon' then
            a.minZ, a.maxZ, a.floorSet, a.ceilingSet = tonumber(row.minZ) or floor, tonumber(row.maxZ) or floor + 5.0, true, true
            for _, p in ipairs(row.points or {}) do a.points[#a.points + 1] = { x = p.x, y = p.y, z = a.minZ + 1.0 } end
        elseif row and shape == 'sphere' then
            a.center, a.radius, a.radiusSet = row.center and plain(row.center), tonumber(row.radius) or 2.0, true
        elseif row and shape == 'box' and row.center and row.size then
            a.box = { center = plain(row.center), size = copy(row.size), rotation = tonumber(row.rotation) or 0.0 }
            a.height = row.size.z
        end
        s.area = a
        mode('area', { kind = kind })
        areaSend(true)
    end

    local function areaStop()
        s.area = nil
        send('world:area', { active = false })
        mode('select')
    end

    -- A new corner, centre or box corner at a point (the pointer's or the camera's).
    local function areaAdd(at, why)
        local a = s.area
        if not at then return problem(why or 'no_surface') end
        if why then return problem(why) end
        if a.shape == 'polygon' then
            if #a.points >= s.maxPoints then return problem('too_many') end
            a.points[#a.points + 1] = plain(at)
            areaSettle()
        elseif a.shape == 'sphere' then
            if not a.center then a.center, a.radiusSet = plain(at), false
            elseif not a.radiusSet then
                -- the second point sets the radius: on the edge the pointer or the camera is over
                a.radius = math.max(MIN_SIZE, #(vector3(at.x - a.center.x, at.y - a.center.y, 0.0)))
                a.radiusSet = true
            end
        else
            if a.box then return end
            if not a.a then a.a = plain(at)
            elseif not a.b then
                if #(vector3(at.x - a.a.x, at.y - a.a.y, 0.0)) < MIN_SIZE then return problem('too_small') end
                a.b = plain(at)
            elseif not a.depthAt then
                a.depthAt = plain(at)
                local box = areaBox()
                if not box or box.size.y < MIN_SIZE then a.depthAt = nil return problem('too_small') end
                a.box = { center = box.center, size = box.size, rotation = box.rotation }
            end
        end
        areaSend(true)
    end

    -- Back one step: the last corner, the radius, the last box corner.
    local function areaBack()
        local a = s.area
        if a.shape == 'polygon' then
            if #a.points == 0 then return problem('nothing_to_undo') end
            table.remove(a.points)
            areaSettle()
        elseif a.shape == 'sphere' then
            if a.radiusSet then a.radiusSet = false elseif a.center then a.center = nil else return problem('nothing_to_undo') end
        else
            if a.box then a.box, a.depthAt = nil, nil
            elseif a.b then a.b = nil
            elseif a.a then a.a = nil
            else return problem('nothing_to_undo') end
        end
        areaSend(true)
    end

    -- The corner, side middle or centre under the pointer.
    local function areaHover()
        local a = s.area
        local best, kind, index = HOVER, nil, nil
        if a.shape == 'polygon' then
            for i, p in ipairs(a.points) do
                local d = World.cursor.distanceTo(p.x, p.y, p.z)
                if d and d < best then best, kind, index = d, 'corner', i end
            end
            if kind then return kind, index end
            local sides = #a.points >= 3 and #a.points or #a.points - 1
            for i = 1, sides do
                local m = sideMiddle(i)
                local d = World.cursor.distanceTo(m.x, m.y, m.z)
                if d and d < best then best, kind, index = d, 'side', i end
            end
            return kind, index
        end
        local c = a.shape == 'sphere' and a.center or (a.box and a.box.center)
        local d = c and World.cursor.distanceTo(c.x, c.y, c.z)
        if d and d < best then return 'center', 1 end
    end

    local function areaDown()
        local a = s.area
        if a.hoverKind == 'corner' then a.drag = { kind = 'corner', index = a.hoverIndex } return end
        if a.hoverKind == 'side' and #a.points < s.maxPoints then
            table.insert(a.points, a.hoverIndex + 1, sideMiddle(a.hoverIndex))
            a.drag = { kind = 'corner', index = a.hoverIndex + 1 }
            return areaSend(true)
        end
        if a.hoverKind == 'center' then a.drag = { kind = 'center' } return end
        areaAdd(aim())
    end

    local function areaDragTo()
        local a, d = s.area, s.area.drag
        local hit, why = aim()
        if not hit or why then return end
        if d.kind == 'corner' and a.points[d.index] then
            a.points[d.index] = plain(hit)
            areaSettle()
        elseif d.kind == 'center' then
            if a.shape == 'sphere' then a.center = plain(hit)
            elseif a.box then a.box.center = { x = hit.x, y = hit.y, z = hit.z + a.box.size.z * 0.5 } end
        end
        areaSend(false)
    end

    -- Floor, ceiling, size, turn and radius from the dock or the wheel.
    local function areaSet(field, value)
        local a = s.area
        value = tonumber(value)
        if not value then return end
        if field == 'minZ' then a.minZ, a.floorSet = math.min(value, a.maxZ - MIN_SIZE), true
        elseif field == 'maxZ' then a.maxZ, a.ceilingSet = math.max(value, a.minZ + MIN_SIZE), true
        elseif field == 'radius' then a.radius, a.radiusSet = math.max(MIN_SIZE, value), a.center ~= nil
        elseif field == 'height' then a.height = math.max(MIN_SIZE, value)
            if a.box then a.box.center.z, a.box.size.z = a.box.center.z - a.box.size.z * 0.5 + a.height * 0.5, a.height end
        elseif a.box and field == 'rotation' then a.box.rotation = value % 360
        elseif a.box and (field == 'sizeX' or field == 'sizeY' or field == 'sizeZ') then
            local axis = field:sub(5):lower()
            local size = math.max(MIN_SIZE, value)
            if axis == 'z' then a.box.center.z, a.height = a.box.center.z - a.box.size.z * 0.5 + size * 0.5, size end
            a.box.size[axis] = size
        end
        areaSend(true)
    end

    local function areaWheel(e)
        local a, step = s.area, (e.delta or 0) > 0 and -1 or 1
        local fine = e.alt and 0.05 or 0.25
        if a.shape == 'polygon' then
            if e.shift then areaSet('minZ', a.minZ + step * fine) else areaSet('maxZ', a.maxZ + step * fine) end
        elseif a.shape == 'sphere' then
            areaSet('radius', a.radius + step * (e.alt and 0.05 or 0.25))
        elseif a.box and e.shift then
            areaSet('rotation', a.box.rotation + step * (e.ctrl and 15.0 or 5.0))
        else
            areaSet('height', a.height + step * fine)
        end
    end

    -- The finished area in the shape the server keeps; nil and why while it cannot be saved.
    local function areaPiece()
        local a = s.area
        local why = areaProblem()
        if why then return nil, why end
        if a.shape == 'polygon' then
            local points = {}
            for i, p in ipairs(a.points) do points[i] = { x = round(p.x), y = round(p.y) } end
            local middle = shapes.middle(a.points)
            middle.z = a.minZ
            return { shape = 'polygon', points = points, minZ = round(a.minZ), maxZ = round(a.maxZ), center = middle, coords = plain(middle) }
        elseif a.shape == 'sphere' then
            return { shape = 'sphere', center = plain(a.center), coords = plain(a.center), radius = round(a.radius) }
        end
        local box = a.box
        return { shape = 'box', center = plain(box.center), coords = plain(box.center), size = { x = round(box.size.x), y = round(box.size.y), z = round(box.size.z) },
            rotation = round(box.rotation, 0.1) }
    end

    local function areaSave()
        local a = s.area
        local piece, why = areaPiece()
        if not piece then return problem(why) end
        local input = a.row and copy(a.row) or { kind = a.kind, label = a.label, active = true, settings = {} }
        for key, value in pairs(piece) do input[key] = value end
        local saved = save('zone', input)
        if not saved then return end
        remember(a.row and { kind = 'update', record = 'zone', before = a.row } or { kind = 'create', record = 'zone', uid = saved.uid })
        areaStop()
        select('zone', saved.uid)
    end

    -- Another shape the kind allows; the floor and ceiling stay.
    local function areaShape(shape)
        local a = s.area
        if not DL.util.contains(a.shapes, shape) or a.shape == shape then return end
        a.shape, a.points, a.center, a.radiusSet, a.a, a.b, a.depthAt, a.box = shape, {}, nil, false, nil, nil, nil, nil
        areaSend(true)
    end

    -- A point setting: a spot near the selected place (where a bag comes out, the officer's screen) --------------

    local function spotStart(e)
        local row = selectedRow()
        if not row or s.selected.record ~= 'entity' or type(e.key) ~= 'string' then return end
        flush()
        s.pick, s.slots = nil, nil
        s.spot = { uid = row.uid, key = e.key }
        local now = (row.settings or {})[e.key]
        if type(now) == 'table' and now.w then s.heading = now.w end
        mode('spot', { key = e.key })
    end

    local function spotEnd()
        flush()
        s.spot = nil
        mode('select')
    end

    -- later: the wheel turning it waits for more notches before it is saved.
    local function spotSet(at, why, later)
        if not at or why then return problem(why or 'no_surface') end
        local row = selectedRow()
        if not row then return spotEnd() end
        local next = copy(row)
        next.settings = next.settings or {}
        next.settings[s.spot.key] = { x = round(at.x), y = round(at.y), z = round(at.z), w = round(s.heading, 0.1) }
        changed('entity', next, copy(row))
        if not later then flush() end
    end

    local slotDown -- the slots section below fills it in

    -- Pointer events --------------------------------------------------------------------------------------------

    local function down(e)
        if e.button == 2 then s.looking = true return end
        if e.button ~= 0 then return end
        if s.area then return areaDown() end
        if s.slots then return slotDown() end
        if s.spot then return spotSet(aim()) end
        if s.pick then return placeSpot(aim()) end
        local over = hover()
        if not over then return select(nil) end
        flush()
        select(over.record, over.uid)
        local row = find(over.record, over.uid)
        local hit = aim()
        local at = anchor(over.record, row)
        if hit and at then s.drag = { from = hit, before = copy(row), moved = false, offset = at - hit } end
    end

    -- Dragging slides a place over whatever the pointer is on (an area keeps its height).
    local function dragTo()
        local d = s.drag
        local hit = aim()
        if not hit then return end
        local row = find(s.selected.record, s.selected.uid)
        if not row then s.drag = nil return end
        local at = anchor(s.selected.record, row)
        local target = hit + d.offset
        if s.selected.record == 'entity' then target = vector3(target.x, target.y, hit.z - bottomOf(modelOf(row))) end
        local delta = vector3(target.x - at.x, target.y - at.y, s.selected.record == 'entity' and target.z - at.z or 0.0)
        if #delta < 0.01 then return end
        d.moved = true
        store(s.selected.record, moved(s.selected.record, row, delta))
    end

    local function up(e)
        if e.button == 2 then s.looking = false return end
        if s.area then
            if s.area.drag then s.area.drag = nil areaSend(true) end
            return
        end
        local d = s.drag
        s.drag = nil
        if not d or not d.moved or not s.selected then return end
        local row = find(s.selected.record, s.selected.uid)
        if row and s.selected.record == 'entity' then row = measured(row) end
        local saved = row and save(s.selected.record, row)
        if saved then remember({ kind = 'update', record = s.selected.record, before = d.before })
        else store(s.selected.record, d.before) end
    end

    local function wheel(e)
        if s.area then return areaWheel(e) end
        if s.slots then return end
        local step = (e.delta or 0) > 0 and -1 or 1
        local angle = e.ctrl and 15.0 or e.shift and 45.0 or e.alt and 1.0 or 5.0
        if s.spot then
            s.heading = (s.heading + step * angle) % 360
            local row = selectedRow()
            local now = row and (row.settings or {})[s.spot.key]
            if type(now) == 'table' and now.x then spotSet(vector3(now.x, now.y, now.z), nil, true) end
            return
        end
        if s.pick then s.heading = (s.heading + step * angle) % 360 return end
        if s.selected then nudge(vector3(0.0, 0.0, 0.0), step * angle) end
    end

    -- Slots ---------------------------------------------------------------------------------------------------
    -- A setting of type 'offsets' (places for wish cards on a tree): spots round the selected place, kept as
    -- offsets from its origin and turned with it. A click adds one where the pointer meets the upright plane through
    -- the place (or what it hits close by), a click on a spot picks it, arrows move it, Del takes it away.

    local function turned(row, x, y, back)
        local r = math.rad((row.coords.w or 0.0) * (back and -1 or 1))
        local c, n = math.cos(r), math.sin(r)
        return x * c - y * n, x * n + y * c
    end
    local function slotsOf(row) return (row.settings or {})[s.slots.key] or {} end
    local function slotAt(row, o)
        local x, y = turned(row, o.x, o.y)
        return vector3(row.coords.x + x, row.coords.y + y, row.coords.z + o.z)
    end
    local function withSlots(row, list)
        local out = copy(row)
        out.settings = out.settings or {}
        out.settings[s.slots.key] = list
        return out
    end
    local function saveSlots(row, list)
        local saved = save('entity', withSlots(row, list))
        if saved then remember({ kind = 'update', record = 'entity', before = row }) end
        mode('slots', { count = #list, max = s.slots.max })
        return saved
    end

    local function startSlots(e)
        local row = selectedRow()
        if not row or s.selected.record ~= 'entity' or type(e.key) ~= 'string' then return end
        flush()
        s.pick, s.spot = nil, nil
        s.slots = { uid = row.uid, key = e.key, max = tonumber(e.max) or 40, reach = tonumber(e.reach) or 6.0 }
        mode('slots', { count = #slotsOf(row), max = s.slots.max })
    end

    local function endSlots()
        flush()
        s.slots = nil
        mode('select')
    end

    -- Where a click puts a new spot: on something hit near the place, else on the plane facing the camera.
    local function slotPoint(row)
        local c = vec(row.coords)
        local from, dir = World.cursor.ray()
        local hit = World.cursor.hit(DRAW)
        if hit and #(vector3(hit.x - c.x, hit.y - c.y, 0.0)) < s.slots.reach then return hit end
        local flat = dir.x * dir.x + dir.y * dir.y
        if flat < 0.0001 then return nil end
        local t = ((c.x - from.x) * dir.x + (c.y - from.y) * dir.y) / flat
        return t > 0 and from + dir * t or nil
    end

    function slotDown()
        local row = selectedRow()
        if not row then return endSlots() end
        local list = slotsOf(row)
        for i, o in ipairs(list) do
            local p = slotAt(row, o)
            local d = World.cursor.distanceTo(p.x, p.y, p.z)
            if d and d < HOVER then s.slots.picked = i return end
        end
        if #list >= s.slots.max then return problem('slots_full') end
        local p = slotPoint(row)
        if not p then return problem('no_surface') end
        local dx, dy, dz = p.x - row.coords.x, p.y - row.coords.y, p.z - row.coords.z
        if dx * dx + dy * dy > s.slots.reach * s.slots.reach or math.abs(dz) > s.slots.reach * 2 then return problem('too_far') end
        local x, y = turned(row, dx, dy, true)
        local next = copy(list)
        next[#next + 1] = { x = round(x), y = round(y), z = round(dz) }
        if saveSlots(row, next) then s.slots.picked = #next end
    end

    -- Arrows move the picked spot; it is saved a moment after the last press.
    local function pushSlot(d)
        local row = selectedRow()
        local i = s.slots.picked
        local list = row and slotsOf(row)
        if not list or not list[i] then return end
        local x, y = turned(row, d.x, d.y, true)
        local next = copy(list)
        next[i] = { x = round(next[i].x + x), y = round(next[i].y + y), z = round(next[i].z + d.z) }
        changed('entity', withSlots(row, next), copy(row))
    end

    local function removeSlot()
        local row = selectedRow()
        local list = row and slotsOf(row)
        if not list or not list[s.slots.picked] then return end
        flush()
        row = selectedRow()
        local next = copy(slotsOf(row))
        table.remove(next, s.slots.picked)
        s.slots.picked = nil
        saveSlots(row, next)
    end

    local function drawSlots()
        local row = selectedRow()
        if not row then return end
        for i, o in ipairs(slotsOf(row)) do
            local p = slotAt(row, o)
            local c = i == s.slots.picked and World.draw.colors.focused or (opts.color or World.draw.colors.valid)
            World.draw.dot(p.x, p.y, p.z, c, i == s.slots.picked and 0.12 or 0.08)
            World.draw.label(p.x, p.y, p.z + 0.18, tostring(i), c)
        end
    end

    -- Commands -------------------------------------------------------------------------------------------------

    local function remove()
        local row = selectedRow()
        if not row then return end
        local record = s.selected.record
        local result = opts.call('remove', { record = record, uid = row.uid })
        if not result.ok then return problem(result.error or 'failed') end
        store(record, row, true)
        remember({ kind = 'remove', record = record, before = row })
        select(nil)
    end

    -- A copy a metre to the side (to the camera's right), with the same settings.
    local function duplicate()
        local row = selectedRow()
        if not row then return end
        local record = s.selected.record
        local pose = DL.freecam.pose()
        local z = math.rad(pose and pose.rotation.z or 0.0)
        local input = moved(record, row, vector3(math.cos(z) * 1.5, math.sin(z) * 1.5, 0.0))
        input.uid, input.revision = nil, nil
        if record == 'entity' then input = measured(input) end
        local saved = input and save(record, input)
        if not saved then return end
        remember({ kind = 'create', record = record, uid = saved.uid })
        select(record, saved.uid)
    end

    local function undo()
        if s.area then return areaBack() end
        flush()
        local step = table.remove(s.undo)
        if not step then return problem('nothing_to_undo') end
        if step.kind == 'create' then
            local row = find(step.record, step.uid)
            local result = row and opts.call('remove', { record = step.record, uid = step.uid })
            if result and result.ok then store(step.record, row, true) end
            if s.selected and s.selected.uid == step.uid then select(nil) end
        elseif step.kind == 'update' then
            local now = find(step.record, step.before.uid)
            local back = copy(step.before)
            back.revision = now and now.revision or back.revision
            if save(step.record, back) then select(step.record, back.uid) end
        elseif step.kind == 'remove' then
            local back = copy(step.before)
            back.uid, back.revision = nil, nil
            local saved = save(step.record, back)
            if saved then select(step.record, saved.uid) end
        end
    end

    -- Arrows push along the camera's facing; PgUp/PgDn up and down. Shift 50 cm, Alt 1 cm, else 5 cm.
    local function push(e)
        local step = e.shift and 0.5 or e.alt and 0.01 or 0.05
        local pose = DL.freecam.pose()
        local z = math.rad(pose and pose.rotation.z or 0.0)
        local forward, right = vector3(-math.sin(z), math.cos(z), 0.0), vector3(math.cos(z), math.sin(z), 0.0)
        local d = (forward * (e.y or 0) + right * (e.x or 0)) * step + vector3(0.0, 0.0, (e.z or 0) * step)
        if s.slots then return pushSlot(d) end
        nudge(d)
    end

    -- E: the camera's ground, for what the editor is doing (a corner, a centre, a spot, the selected spot moved there).
    local function here()
        local at, why = below()
        if s.area then return areaAdd(at, why) end
        if s.spot then return spotSet(at, why) end
        if s.pick then return placeSpot(at, why) end
        local row = selectedRow()
        if row and s.selected.record == 'entity' then
            if not at or why then return problem(why or 'no_surface') end
            local c = row.coords
            nudge(vector3(at.x - c.x, at.y - c.y, at.z - bottomOf(modelOf(row)) - c.z))
        end
    end

    local COMMANDS = {
        delete = function()
            if s.area then
                local a = s.area
                if a.shape == 'polygon' and a.hoverKind == 'corner' then
                    table.remove(a.points, a.hoverIndex)
                    a.hoverKind = nil
                    areaSettle()
                    return areaSend(true)
                end
                return areaBack()
            end
            if s.slots then removeSlot() else remove() end
        end,
        duplicate = duplicate, undo = undo, ground = ground, push = push, slots = startSlots, spot = spotStart, here = here,
        place = function()
            if s.area then return areaSave() end
            if s.spot then return spotEnd() end
            if not s.slots and s.pick then placeSpot(aim()) end
        end,
        drop = function()
            if s.area then return areaStop() end
            if s.spot then return spotEnd() end
            if s.slots then return endSlots() end
            if s.pick then s.pick = nil mode('select') else select(nil) end
        end,
        -- The selected area redrawn: its corners, centre or box as they are.
        edit = function()
            local row = selectedRow()
            if row and s.selected.record == 'zone' then areaStart(row.kind, row.label, s.kinds[row.kind] and s.kinds[row.kind].shapes, row) end
        end,
        -- The area being drawn: { op = 'set' | 'shape' | 'floorHere' | 'ceilingHere' | 'clear' | 'back' | 'save' | 'cancel', field, value }.
        area = function(e)
            if not s.area then return end
            local pose = DL.freecam.pose()
            if e.op == 'set' then areaSet(e.field, e.value == 'camera' and pose and pose.coords.z or e.value)
            elseif e.op == 'shape' then areaShape(e.value)
            elseif e.op == 'floorHere' and pose then areaSet('minZ', pose.coords.z)
            elseif e.op == 'ceilingHere' and pose then areaSet('maxZ', pose.coords.z)
            elseif e.op == 'clear' then
                local a = s.area
                a.points, a.center, a.radiusSet, a.a, a.b, a.depthAt, a.box = {}, nil, false, nil, nil, nil, nil
                areaSend(true)
            elseif e.op == 'back' then areaBack()
            elseif e.op == 'save' then areaSave()
            elseif e.op == 'cancel' then areaStop() end
        end,
        -- A number of the selected area changed in the dock ('camera': the camera's height); saved a moment after the last change.
        zoneSet = function(e)
            local row = selectedRow()
            if not row or s.selected.record ~= 'zone' then return end
            local pose = DL.freecam.pose()
            local next = zoneField(row, e.field, e.value == 'camera' and pose and pose.coords.z or e.value)
            if next then changed('zone', next, copy(row)) end
        end,
        -- The selected spot turned by a number of degrees, or raised by metres.
        turn = function(e) if s.selected and tonumber(e.degrees) then nudge(vector3(0.0, 0.0, 0.0), tonumber(e.degrees)) end end,
        lift = function(e) if s.selected and tonumber(e.metres) then nudge(vector3(0.0, 0.0, tonumber(e.metres))) end end,
        go = function(e) goTo(e.record, e.uid) end,
        select = function(e) select(e.record, e.uid) end,
        -- The name or the settings changed in the dock.
        update = function(e)
            local row = selectedRow()
            if not row then return end
            flush()
            row = selectedRow()
            local next = copy(row)
            for key, value in pairs(type(e.fields) == 'table' and e.fields or {}) do next[key] = value end
            if s.selected.record == 'entity' then next = measured(next) end
            local saved = next and save(s.selected.record, next)
            if saved then remember({ kind = 'update', record = s.selected.record, before = row }) end
        end,
    }

    -- Drawing ---------------------------------------------------------------------------------------------------

    function edit.drawAll(faint)
        local camera = GetFinalRenderedCamCoord()
        local player = GetEntityCoords(cache.ped)
        local color = opts.color or World.draw.colors.valid
        local redrawn = s and s.area and s.area.row and s.area.row.uid
        for _, record in ipairs({ 'zone', 'entity' }) do
            for _, row in ipairs(listOf(record)) do
                local at = anchor(record, row)
                if at and row.uid ~= redrawn and #(at - camera) < DRAW then
                    local picked = s and s.selected and s.selected.uid == row.uid
                    local over = s and s.over and s.over.uid == row.uid
                    local c = picked and World.draw.colors.focused or not row.active and World.draw.colors.inactive or over and { 255, 255, 255 } or color
                    local shape = DL.geo.fromRecord(row)
                    if record == 'entity' then
                        -- The ghost: far spots (near ones are the world's own), plain points (a standing person) and the
                        -- spot being moved before it is saved.
                        local model = s and modelOf(row)
                        local kind = s and kindOf(row.kind)
                        local plainPoint = kind and kind.presentation == 'point'
                        local moving = picked and (s.drag or (s.dirty and s.dirty.row.uid == row.uid))
                        -- the picked spot of a measured kind: its whole layout where it now is
                        local p = picked and not faint and previewOf(row.kind, row.coords, row.settings, false, row.uid, row.model)
                        if p then drawPreview(p)
                        elseif model and (plainPoint or moving or #(at - player) > STREAMED) then
                            ghost(row.uid, model, at, row.coords.w or 0.0, faint and 90 or (picked and 220 or (plainPoint and 130 or 190)), scenarioOf(row))
                        end
                        World.draw.dot(at.x, at.y, at.z + 0.05, c, (picked or over) and 0.3 or 0.2)
                        local h = math.rad(row.coords.w or 0.0)
                        World.draw.line(at, { x = at.x - math.sin(h) * 0.9, y = at.y + math.cos(h) * 0.9, z = at.z + 0.05 }, c, 255)
                        if shape and shape.shape ~= 'point' then World.draw.shape(shape, { color = c, faint = faint or not picked }) end
                        if not faint then World.draw.label(at.x, at.y, at.z + 1.1, row.label ~= '' and row.label or row.kind, c) end
                        -- Its point settings (where a bag comes out, a screen), with the way they face.
                        if picked and not faint then
                            for key, value in pairs(row.settings or {}) do
                                if type(value) == 'table' and value.x and value.y and value.z and value.w then
                                    local p, ph = value, math.rad(value.w)
                                    World.draw.dot(p.x, p.y, p.z + 0.03, World.draw.colors.focused, 0.14)
                                    World.draw.line(p, { x = p.x - math.sin(ph) * 0.6, y = p.y + math.cos(ph) * 0.6, z = p.z + 0.03 }, World.draw.colors.focused, 255)
                                    World.draw.line(at, p, World.draw.colors.focused, 90)
                                    World.draw.label(p.x, p.y, p.z + 0.35, key, World.draw.colors.focused)
                                end
                            end
                        end
                    elseif shape then
                        World.draw.shape(shape, { color = c, focused = picked, faint = faint, label = not faint and (row.label ~= '' and row.label or row.kind) or nil })
                    end
                end
            end
        end
    end

    -- Where E would put something: a ring on the ground under the camera.
    local function drawBelow(c)
        local at = s.belowAt
        if not at then return end
        DrawMarker(25, at.x, at.y, at.z + 0.04, 0, 0, 0, 0, 0, 0, 0.9, 0.9, 0.9, c[1], c[2], c[3], 200, false, false, 2, false, nil, nil, false)
        World.draw.line(at, { x = at.x, y = at.y, z = at.z + 1.6 }, c, 160)
        World.draw.label(at.x, at.y, at.z + 1.8, 'E', c)
    end

    -- The spot a click would place: its ghost, a dot and its facing under the pointer.
    local function drawPick()
        if not s.pick or not s.aimAt then return end
        local at, h = s.aimAt, math.rad(s.heading)
        -- a measured kind shows its whole layout (red where a check fails) instead of its one model
        local p = not s.aimProblem and previewOf(s.pick.kind, { x = at.x, y = at.y, z = at.z, w = s.heading }, s.pick.settings, false)
        local c = (s.aimProblem or (p and p.problem)) and World.draw.colors.invalid or (opts.color or World.draw.colors.valid)
        local kind = kindOf(s.pick.kind)
        if p then drawPreview(p)
        elseif kind.model then ghost('pick', kind.model, vector3(at.x, at.y, at.z - bottomOf(kind.model)), s.heading, s.aimProblem and 70 or 170, kind.scenario) end
        World.draw.dot(at.x, at.y, at.z + 0.05, c, 0.3)
        World.draw.line(at, { x = at.x - math.sin(h) * 1.0, y = at.y + math.cos(h) * 1.0, z = at.z + 0.05 }, c, 255)
        World.draw.label(at.x, at.y, at.z + 1.1, s.pick.label, c)
    end

    -- The point setting a click would put: a dot and its facing.
    local function drawSpot()
        if not s.aimAt then return end
        local c = s.aimProblem and World.draw.colors.invalid or World.draw.colors.focused
        local at, h = s.aimAt, math.rad(s.heading)
        World.draw.dot(at.x, at.y, at.z + 0.03, c, 0.2)
        World.draw.line(at, { x = at.x - math.sin(h) * 0.8, y = at.y + math.cos(h) * 0.8, z = at.z + 0.03 }, c, 255)
        World.draw.label(at.x, at.y, at.z + 0.5, s.spot.key, c)
    end

    -- The area as drawn: PolyZone-like walls, numbered corner posts, the next side to the pointer and to E.
    local function drawArea()
        local a = s.area
        local why = areaProblem()
        local bad = why and why ~= 'unfinished' and why ~= 'too_few'
        local c = bad and World.draw.colors.invalid or (opts.color or World.draw.colors.valid)
        if a.shape == 'polygon' then
            local points, n = a.points, #a.points
            if n >= 3 then World.draw.shape({ shape = 'polygon', points = points, minZ = a.minZ, maxZ = a.maxZ }, { color = c, corners = false, focused = true }) end
            for i, p in ipairs(points) do
                local hot = (a.drag and a.drag.index == i) or (a.hoverKind == 'corner' and a.hoverIndex == i)
                World.draw.handle(p, a.minZ, hot and World.draw.colors.focused or c, hot)
                World.draw.label(p.x, p.y, p.z + 0.5, tostring(i), c)
                if i < n then World.draw.line(p, points[i + 1], c, 255) end
            end
            if a.hoverKind == 'side' then World.draw.handle(sideMiddle(a.hoverIndex), nil, World.draw.colors.focused, true) end
            if n > 0 and not a.drag and not a.hoverKind then
                local last = points[n]
                if s.aimAt and not s.aimProblem then
                    World.draw.line(last, s.aimAt, c, 150)
                    if n >= 2 then World.draw.line(s.aimAt, points[1], c, 80) end
                end
                if s.belowAt then World.draw.line(last, s.belowAt, World.draw.colors.focused, 120) end
            end
            if n >= 3 and (a.drag or a.hoverKind or not s.aimAt) then World.draw.line(points[n], points[1], c, 255) end
        elseif a.shape == 'sphere' then
            local center = a.center or s.aimAt
            if center then
                World.draw.shape({ shape = 'sphere', center = center, radius = a.radius }, { color = c, focused = true })
                World.draw.handle(center, nil, a.hoverKind == 'center' and World.draw.colors.focused or c, a.hoverKind == 'center')
            end
        else
            local box = areaBox()
            if box then
                World.draw.shape({ shape = 'box', center = box.center, size = box.size, rotation = box.rotation }, { color = c, focused = true })
                if a.box then World.draw.handle(box.center, nil, a.hoverKind == 'center' and World.draw.colors.focused or c, a.hoverKind == 'center') end
            elseif a.a and s.aimAt then
                World.draw.line(a.a, s.aimAt, c, 255)
            end
            for _, p in ipairs({ a.a, a.b }) do World.draw.dot(p.x, p.y, p.z, c, 0.16) end
        end
        if s.aimAt and not a.hoverKind and not a.drag then World.draw.dot(s.aimAt.x, s.aimAt.y, s.aimAt.z, c, 0.12) end
    end

    local function frame()
        DisableAllControlActions(0)
        EnableControlAction(0, 249, true) -- push to talk
        fly()
        if s.drag then dragTo() end
        if s.area and s.area.drag then areaDragTo() end
        s.over = not s.drag and not s.pick and not s.slots and not s.area and not s.spot and hover() or nil
        local aiming = s.pick or s.area or s.spot
        if aiming then
            s.aimAt, s.aimProblem = aim()
            s.belowAt = below()
        else
            s.aimAt, s.aimProblem, s.belowAt = nil, nil, nil
        end
        if s.area then
            if not s.area.drag then s.area.hoverKind, s.area.hoverIndex = areaHover() end
            -- Until it is set, the radius follows the pointer (or the camera when the pointer is over nothing).
            local edge = s.aimAt or s.belowAt
            if s.area.shape == 'sphere' and s.area.center and not s.area.radiusSet and edge then
                s.area.radius = math.max(MIN_SIZE, #(vector3(edge.x - s.area.center.x, edge.y - s.area.center.y, 0.0)))
                areaSend(false)
            elseif s.area.shape == 'box' and s.area.b and not s.area.box then
                areaSend(false)
            end
        end
        if s.dirty and GetGameTimer() > s.dirty.at then flush() end
        edit.drawAll(s.area ~= nil)
        drawPick()
        if s.spot then drawSpot() end
        if s.area then drawArea() end
        if aiming then drawBelow(World.draw.colors.focused) end
        if s.slots then drawSlots() end
        clearGhosts(false)
        if IsEntityDead(cache.ped) then edit.stop() end
    end

    -- On and off ------------------------------------------------------------------------------------------------

    function edit.start()
        if s then return true end
        local origin = GetEntityCoords(cache.ped)
        local reach = tonumber(opts.reach) or 150.0
        local zoneReach = math.max(reach, tonumber(opts.zoneReach) or reach)
        s = { origin = origin, reach = reach, zoneReach = zoneReach, fly = zoneReach, maxPoints = tonumber(opts.maxPoints) or 32, undo = {},
            look = { x = 0, y = 0 }, heading = (GetGameplayCamRot(2).z + 180.0) % 360, kinds = {}, ghosts = {} }
        DL.freecam.start({ coords = GetGameplayCamCoord(), rotation = GetGameplayCamRot(2), fov = GetGameplayCamFov() })
        SetNuiFocusKeepInput(true)
        mode('select')
        CreateThread(function()
            while s do
                -- A point setting of another panel is placed with the place tool, which takes the camera for a while.
                if s.paused or World.placement.active() then
                    World.cursor.use(nil)
                else
                    if not DL.freecam.active() then DL.freecam.start({ coords = s.cameraAt, rotation = s.cameraRot }) end
                    frame()
                    local pose = DL.freecam.pose()
                    if pose then s.cameraAt, s.cameraRot = pose.coords, pose.rotation end
                end
                Wait(0)
            end
        end)
        return true
    end

    function edit.stop()
        if not s then return end
        if s.dirty then flush() end
        if World.placement.active() then World.placement.cancel() end
        clearGhosts(true)
        s = nil
        World.cursor.use(nil)
        SetNuiFocusKeepInput(false)
        DL.freecam.stop()
    end

    function edit.active() return s ~= nil end

    -- From the page ---------------------------------------------------------------------------------------------

    local function ok(cb, data) cb({ ok = true, data = data or {} }) end

    RegisterNUICallback('world:edit', function(data, cb)
        if type(data) == 'table' and data.enabled then
            if opts.canStart and not opts.canStart() then return cb({ ok = false, error = 'conflict' }) end
            edit.start()
            if type(data.kinds) == 'table' then s.kinds = data.kinds end
        else
            edit.stop()
        end
        ok(cb, { enabled = s ~= nil, reach = s and s.reach, zoneReach = s and s.zoneReach })
    end)

    RegisterNUICallback('world:pointer', function(e, cb)
        ok(cb)
        if not s or s.paused or type(e) ~= 'table' then return end
        if tonumber(e.x) and tonumber(e.y) then World.cursor.use(tonumber(e.x), tonumber(e.y)) end
        if s.looking and e.type == 'move' then s.look = { x = s.look.x + (tonumber(e.dx) or 0), y = s.look.y + (tonumber(e.dy) or 0) } end
        if e.type == 'down' then down(e)
        elseif e.type == 'up' then up(e)
        elseif e.type == 'wheel' then wheel(e)
        elseif e.type == 'leave' then s.looking = false end
    end)

    RegisterNUICallback('world:command', function(e, cb)
        ok(cb)
        if not s or s.paused or type(e) ~= 'table' or not COMMANDS[e.name] then return end
        COMMANDS[e.name](e)
    end)

    -- A kind to place: a spot follows the pointer, an area starts drawing at once.
    RegisterNUICallback('world:pick', function(e, cb)
        ok(cb)
        if not s or type(e) ~= 'table' then return end
        flush()
        if s.area then areaStop() end
        s.spot, s.slots = nil, nil
        if e.kind and e.record == 'zone' then
            s.pick = nil
            select(nil)
            return areaStart(e.kind, tostring(e.label or e.kind), e.shapes, nil)
        end
        -- settings: what the dock picked before placing (a station's mode)
        s.pick = e.kind and { kind = e.kind, label = tostring(e.label or e.kind), settings = type(e.settings) == 'table' and e.settings or nil } or nil
        if s.pick then select(nil) end
        mode(s.pick and 'place' or 'select', { kind = s.pick and s.pick.kind })
    end)

    RegisterNUICallback('world:typing', function(e, cb)
        typing = type(e) == 'table' and e.on == true
        ok(cb)
    end)

    return edit
end
