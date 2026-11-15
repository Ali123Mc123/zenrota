-- The world editor: a setup panel's places edited in the world itself, like a level editor. The page keeps the
-- focus and owns the mouse (a dock on the left, the rest is the view): it sends the pointer and the shortcuts here,
-- the game keeps WASD for flying (SetNuiFocusKeepInput). A click places the picked kind and saves it at once; a place
-- is clicked to pick it, dragged to move it, turned with the wheel, nudged with the arrows; Del, Ctrl+D and Ctrl+Z.
-- A kind with a model shows it under the pointer as a see-through ghost standing on the surface (Enter or a click
-- puts it there), and placed props are drawn where they stand even far from the player.
--   local edit = World.worldedit({ call = fn(name, data), records = fn, refresh = fn, send = fn(action, data),
--                                  reach = 150, color = { r, g, b }, suspend = fn, resume = fn, maxPoints = 32 })
-- NUI: world:edit { enabled, models = { kind = model } }, world:pointer { type, x, y, button, dx, dy, delta, ctrl, shift, alt },
--      world:command { name, ... }, world:pick { kind, label, record, presentation, model }, world:typing { on }
-- It sends: world:selected { uid, record } | nil, world:mode { mode, kind }, world:problem { code }.
World = World or {}

local MOVE, FAST, FINE, LOOK = 8.0, 4.0, 0.2, 0.25 -- fly metres a second, Shift and Alt multipliers, degrees a pixel
local HOVER, DRAW = 0.03, 120.0                     -- how near the pointer picks a place (screen heights); draw range
local STREAMED = 80.0                               -- props this near the player are the world's own (anchors), no ghost
local KEY = { forward = 32, back = 33, left = 34, right = 35, up = 38, down = 44, fast = 21, fine = 19 }

local function held(control) return IsDisabledControlPressed(0, control) end
local function copy(t) return json.decode(json.encode(t)) end
local function vec(p) return p and vector3(p.x + 0.0, p.y + 0.0, (p.z or 0.0) + 0.0) end

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

    -- The model a spot shows: its own, else its kind's.
    local function modelOf(row)
        if row.model and row.model ~= '' then return row.model end
        return s.models[row.kind]
    end

    -- A see-through copy of a model, one per key, moved where asked; ghosts not drawn this frame go.
    local function ghost(key, model, at, heading, alpha)
        local g = s.ghosts[key]
        if g and g.model ~= model then
            DeleteEntity(g.entity)
            g, s.ghosts[key] = nil, nil
        end
        if not g then
            local hash = joaat(model)
            if not IsModelInCdimage(hash) then return end
            RequestModel(hash)
            if not HasModelLoaded(hash) then return end
            pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
            local entity = CreateObject(hash, at.x, at.y, at.z, false, false, false)
            SetEntityCollision(entity, false, false)
            FreezeEntityPosition(entity, true)
            SetModelAsNoLongerNeeded(hash)
            g = { entity = entity, model = model }
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

    local function select(record, uid)
        if s.slots and s.slots.uid ~= uid then s.slots = nil send('world:mode', { mode = 'select' }) end
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
        local saved = save(d.record, d.row)
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
        if #away > s.reach then coords = s.origin + away * (s.reach / #away) end
        DL.freecam.place(coords, rotation)
    end

    -- Flies to look down at a place.
    local function goTo(record, uid)
        local row = find(record, uid)
        local at = row and anchor(record, row)
        if not at then return end
        if #(at - s.origin) > s.reach then return problem('too_far') end
        local pose = DL.freecam.pose()
        local z = math.rad(pose and pose.rotation.z or 0.0)
        DL.freecam.place(vector3(at.x + math.sin(z) * 7.0, at.y - math.cos(z) * 7.0, at.z + 5.0), vector3(-35.0, 0.0, pose and pose.rotation.z or 0.0))
        select(record, uid)
    end

    -- Pointer ------------------------------------------------------------------------------------------------

    local function aim()
        local hit = World.cursor.hit(s.reach * 2.0)
        if hit and #(hit - s.origin) > s.reach then return hit, 'too_far' end
        return hit
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

    -- A spot of the picked kind where the pointer is; saved at once.
    local function placeSpot()
        local hit, why = aim()
        if not hit or why then return problem(why or 'no_surface') end
        local pick = s.pick
        -- a prop stands on the surface: its origin goes up by how far its bottom is below it
        local z = hit.z - bottomOf(pick.model)
        local saved = save('entity', { kind = pick.kind, label = pick.label, active = true, settings = {}, shape = 'point',
            coords = { x = hit.x, y = hit.y, z = z, w = s.heading } })
        if not saved then return end
        remember({ kind = 'create', record = 'entity', uid = saved.uid })
        select('entity', saved.uid)
    end

    -- An area is drawn with the place tool (corners, box or sphere), then saved.
    local function drawArea(pick, row)
        s.paused = true
        World.cursor.use(nil)
        if opts.suspend then opts.suspend() end
        local shape = row and row.shape or (pick.shapes and pick.shapes[1]) or 'polygon'
        World.placement.start({ shape = shape, presentation = 'point', label = row and row.label or pick.label, reach = s.reach,
            maxPoints = opts.maxPoints, color = opts.color, existing = row and copy(row) or nil, backdrop = function() edit.drawAll(true) end }, {
            hud = function(hud) send('world:placementHud', hud) end,
            done = function(result)
                if opts.resume then opts.resume() end
                send('world:placementHud', { visible = false })
                if s then s.paused = false end
                if not result or not s then return end
                local input = row and copy(row) or { kind = pick.kind, label = pick.label, active = true, settings = {} }
                for key, value in pairs(result) do input[key] = value end
                local saved = save('zone', input)
                if not saved then return end
                remember(row and { kind = 'update', record = 'zone', before = row } or { kind = 'create', record = 'zone', uid = saved.uid })
                select('zone', saved.uid)
            end,
        })
    end

    local slotDown -- the slots section below fills it in

    local function down(e)
        if e.button == 2 then s.looking = true return end
        if e.button ~= 0 then return end
        if s.slots then return slotDown() end
        if s.pick then
            if s.pick.record == 'zone' then return drawArea(s.pick) end
            return placeSpot()
        end
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
        local d = s.drag
        s.drag = nil
        if not d or not d.moved or not s.selected then return end
        local row = find(s.selected.record, s.selected.uid)
        local saved = row and save(s.selected.record, row)
        if saved then remember({ kind = 'update', record = s.selected.record, before = d.before })
        else store(s.selected.record, d.before) end
    end

    local function wheel(e)
        if s.slots then return end
        local step = (e.delta or 0) > 0 and -1 or 1
        local angle = e.ctrl and 15.0 or e.shift and 45.0 or e.alt and 1.0 or 5.0
        if s.pick and s.pick.record ~= 'zone' then s.heading = (s.heading + step * angle) % 360 return end
        if s.selected then nudge(vector3(0.0, 0.0, 0.0), step * angle) end
    end

    -- Slots ---------------------------------------------------------------------------------------------------
    -- A setting of type 'offsets' (places for wish cards on a tree): spots round the selected place, kept as
    -- offsets from its origin and turned with it. A click adds one where the pointer meets the upright plane through
    -- the place (or what it hits close by), a click on a spot picks it, arrows move it, Del takes it away.

    local function round(v) return math.floor(v * 100 + 0.5) / 100 end
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
        send('world:mode', { mode = 'slots', count = #list, max = s.slots.max })
        return saved
    end

    local function startSlots(e)
        local row = selectedRow()
        if not row or s.selected.record ~= 'entity' or type(e.key) ~= 'string' then return end
        flush()
        s.pick = nil
        s.slots = { uid = row.uid, key = e.key, max = tonumber(e.max) or 40, reach = tonumber(e.reach) or 6.0 }
        send('world:mode', { mode = 'slots', count = #slotsOf(row), max = s.slots.max })
    end

    local function endSlots()
        flush()
        s.slots = nil
        send('world:mode', { mode = 'select' })
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
        local saved = save(record, input)
        if not saved then return end
        remember({ kind = 'create', record = record, uid = saved.uid })
        select(record, saved.uid)
    end

    local function undo()
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

    local COMMANDS = {
        delete = function() if s.slots then removeSlot() else remove() end end,
        duplicate = duplicate, undo = undo, ground = ground, push = push, slots = startSlots,
        place = function() if not s.slots and s.pick and s.pick.record ~= 'zone' then placeSpot() end end,
        drop = function()
            if s.slots then return endSlots() end
            if s.pick then s.pick = nil send('world:mode', { mode = 'select' }) else select(nil) end
        end,
        edit = function()
            local row = selectedRow()
            if row and s.selected.record == 'zone' then drawArea({ kind = row.kind, label = row.label }, row) end
        end,
        go = function(e) goTo(e.record, e.uid) end,
        select = function(e) select(e.record, e.uid) end,
        -- The name or the settings changed in the dock.
        update = function(e)
            local row = selectedRow()
            if not row then return end
            local next = copy(row)
            for key, value in pairs(type(e.fields) == 'table' and e.fields or {}) do next[key] = value end
            local saved = save(s.selected.record, next)
            if saved then remember({ kind = 'update', record = s.selected.record, before = row }) end
        end,
    }

    -- Drawing ---------------------------------------------------------------------------------------------------

    function edit.drawAll(faint)
        local camera = GetFinalRenderedCamCoord()
        local color = opts.color or World.draw.colors.valid
        for _, record in ipairs({ 'zone', 'entity' }) do
            for _, row in ipairs(listOf(record)) do
                local at = anchor(record, row)
                if at and #(at - camera) < DRAW then
                    local picked = s and s.selected and s.selected.uid == row.uid
                    local over = s and s.over and s.over.uid == row.uid
                    local c = picked and World.draw.colors.focused or not row.active and World.draw.colors.inactive or over and { 255, 255, 255 } or color
                    local shape = DL.geo.fromRecord(row)
                    if record == 'entity' then
                        local model = s and not faint and modelOf(row)
                        if model and #(at - GetEntityCoords(cache.ped)) > STREAMED then ghost(row.uid, model, at, row.coords.w or 0.0, picked and 230 or 200) end
                        World.draw.dot(at.x, at.y, at.z + 0.05, c, (picked or over) and 0.3 or 0.2)
                        local h = math.rad(row.coords.w or 0.0)
                        World.draw.line(at, { x = at.x - math.sin(h) * 0.9, y = at.y + math.cos(h) * 0.9, z = at.z + 0.05 }, c, 255)
                        if shape and shape.shape ~= 'point' then World.draw.shape(shape, { color = c, faint = faint or not picked }) end
                        if not faint then World.draw.label(at.x, at.y, at.z + 1.1, row.label ~= '' and row.label or row.kind, c) end
                    elseif shape then
                        World.draw.shape(shape, { color = c, focused = picked, faint = faint, label = not faint and (row.label ~= '' and row.label or row.kind) or nil })
                    end
                end
            end
        end
    end

    -- The spot a click would place: a dot and its facing under the pointer.
    local function drawPick()
        if not s.pick or s.pick.record == 'zone' or not s.aim then return end
        local c = s.aimProblem and World.draw.colors.invalid or (opts.color or World.draw.colors.valid)
        local at, h = s.aim, math.rad(s.heading)
        if s.pick.model then ghost('pick', s.pick.model, vector3(at.x, at.y, at.z - bottomOf(s.pick.model)), s.heading, s.aimProblem and 70 or 170) end
        World.draw.dot(at.x, at.y, at.z + 0.05, c, 0.3)
        World.draw.line(at, { x = at.x - math.sin(h) * 1.0, y = at.y + math.cos(h) * 1.0, z = at.z + 0.05 }, c, 255)
        World.draw.label(at.x, at.y, at.z + 1.1, s.pick.label, c)
    end

    local function frame()
        DisableAllControlActions(0)
        EnableControlAction(0, 249, true) -- push to talk
        fly()
        if s.drag then dragTo() end
        s.over = not s.drag and not s.pick and not s.slots and hover() or nil
        if s.pick then s.aim, s.aimProblem = aim() end
        if s.dirty and GetGameTimer() > s.dirty.at then flush() end
        edit.drawAll(false)
        drawPick()
        if s.slots then drawSlots() end
        clearGhosts(false)
        if IsEntityDead(cache.ped) then edit.stop() end
    end

    -- On and off ------------------------------------------------------------------------------------------------

    function edit.start()
        if s then return true end
        local origin = GetEntityCoords(cache.ped)
        s = { origin = origin, reach = tonumber(opts.reach) or 150.0, undo = {}, look = { x = 0, y = 0 }, heading = (GetGameplayCamRot(2).z + 180.0) % 360,
            models = {}, ghosts = {} }
        DL.freecam.start({ coords = GetGameplayCamCoord(), rotation = GetGameplayCamRot(2), fov = GetGameplayCamFov() })
        SetNuiFocusKeepInput(true)
        send('world:mode', { mode = 'select' })
        CreateThread(function()
            while s do
                -- A point setting is placed with the place tool, which takes the camera for a while.
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
            if type(data.models) == 'table' then s.models = data.models end
        else
            edit.stop()
        end
        ok(cb, { enabled = s ~= nil })
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

    RegisterNUICallback('world:pick', function(e, cb)
        ok(cb)
        if not s or type(e) ~= 'table' then return end
        flush()
        s.pick = e.kind and { kind = e.kind, label = tostring(e.label or e.kind), record = e.record, shapes = e.shapes,
            model = type(e.model) == 'string' and e.model ~= '' and e.model or nil } or nil
        if s.pick then select(nil) end
        send('world:mode', { mode = s.pick and 'place' or 'select', kind = s.pick and s.pick.kind })
    end)

    RegisterNUICallback('world:typing', function(e, cb)
        typing = type(e) == 'table' and e.on == true
        ok(cb)
    end)

    return edit
end
