-- The editor's measurement of a station (10-cpr-deney.md section 3.2), asked by the world editor while a lab bench or a
-- first aid station is placed, dragged or turned (World.worldedit opts.preview): where the work surface is, whether it
-- is level and clear above, where the student stands or kneels, whether the cameras and the layout fit. What it finds
-- is saved with the spot as settings.surface; the editor shows the whole layout as see-through ghosts, the top's
-- outline, a line per camera and a green or red dot for every check. Admins only: synchronous rays are fine here.
local PC = Core.PracticalClient
if not PC then return end

local cfg, Frame = PC.cfg, PracticalFrame
local S = cfg.Survey or {}
local KINDS = { lab_bench = true, first_aid_station = true }
local FLAGS = 1 | 16 | 64 -- the map, objects, glass
local Survey = {}
Core.PracticalSurvey = Survey

-- The surface kinds by the game's material names (for sounds and sparks).
local MATERIAL = {}
for kind, names in pairs({
    wood = { 'WOOD_SOLID_SMALL', 'WOOD_SOLID_MEDIUM', 'WOOD_SOLID_LARGE', 'WOOD_SOLID_POLISHED', 'WOOD_FLOOR_DUST', 'WOOD_HOLLOW_SMALL',
        'WOOD_HOLLOW_MEDIUM', 'WOOD_HOLLOW_LARGE', 'WOOD_CHIPBOARD', 'WOOD_OLD_CREAKY', 'WOOD_HIGH_DENSITY', 'WOOD_LATTICE' },
    metal = { 'METAL_SOLID_SMALL', 'METAL_SOLID_MEDIUM', 'METAL_SOLID_LARGE', 'METAL_HOLLOW_SMALL', 'METAL_HOLLOW_MEDIUM', 'METAL_HOLLOW_LARGE',
        'METAL_CHAINLINK_SMALL', 'METAL_CHAINLINK_LARGE', 'METAL_CORRUGATED_IRON', 'METAL_GRILLE', 'METAL_RAILING', 'METAL_DUCT' },
    glass = { 'GLASS_SHOOT_THROUGH', 'GLASS_BULLETPROOF', 'GLASS_OPAQUE', 'PERSPEX' },
    plastic = { 'PLASTIC', 'PLASTIC_HOLLOW', 'PLASTIC_HIGH_DENSITY', 'PLASTIC_CLEAR', 'PLASTIC_HOLLOW_CLEAR', 'PLASTIC_HIGH_DENSITY_CLEAR',
        'FIBREGLASS_HOLLOW', 'RUBBER', 'RUBBER_HOLLOW', 'LINOLEUM' },
    stone = { 'CONCRETE', 'CONCRETE_POTHOLE', 'CONCRETE_DUSTY', 'TARMAC', 'STONE', 'MARBLE', 'TILE', 'BRICK', 'CERAMIC', 'ROCK', 'PAVING_SLAB',
        'BRICK_PAVEMENT', 'BREEZE_BLOCK', 'PLASTER_SOLID', 'PLASTER_BRITTLE', 'GRANITE' },
    cloth = { 'CARPET_SOLID', 'CARPET_SOLID_DUSTY', 'CARPET_FLOORBOARD', 'CLOTH', 'LEATHER', 'FOAM', 'FEATHER_PILLOW' },
}) do
    for _, name in ipairs(names) do
        MATERIAL[joaat(name) % 4294967296] = kind
    end
end

-- The config's model records by hash (a map object is known only by its hash).
local RECORDS = {}
for name, record in pairs(cfg.Models or {}) do RECORDS[joaat(name)] = record end

-- Rays and shapes -----------------------------------------------------------------------------------------------

-- Straight down through x, y from z + above to z - below: the first surface met, our own collisionless props skipped
-- (option 4); again with option 0 for MLO surfaces the first pass misses. -> at, normal, entity, material | nil
local function down(x, y, z, above, below, ignore)
    for _, option in ipairs({ 4, 0 }) do
        local probe = StartExpensiveSynchronousShapeTestLosProbe(x, y, z + above, x, y, z - below, FLAGS, ignore or 0, option)
        local _, hit, at, normal, material, entity = GetShapeTestResultIncludingMaterial(probe)
        if hit == 1 then return vector3(at.x, at.y, at.z), normal, entity, MATERIAL[(material or 0) % 4294967296] end
    end
end

-- An async shape test's answer (a frame or two). -> hit, where
local function answer(probe)
    local status, hit, at = 1, 0, nil
    local untilMs = GetGameTimer() + 500
    repeat
        Wait(0)
        status, hit, at = GetShapeTestResult(probe)
    until status ~= 1 or GetGameTimer() > untilMs
    return hit == 1, at
end

local function capsule(a, b, radius, ignore) return answer(StartShapeTestCapsule(a.x, a.y, a.z, b.x, b.y, b.z, radius, 1 | 16, ignore or 0, 4)) end

local function boxFree(center, size, h, ignore)
    local hit = answer(StartShapeTestBox(center.x, center.y, center.z, size.x, size.y, size.z, 0.0, 0.0, h, 2, 1 | 16, ignore or 0, 4))
    return not hit
end

-- The result ---------------------------------------------------------------------------------------------------

-- A check: its dot (green or red) and, when it fails, the first problem (the editor shows it and refuses to save).
local function check(r, at, ok, code)
    r.dots[#r.dots + 1] = { at = at, ok = ok == true }
    if not ok and code and not r.problem then r.problem = code end
    return ok
end

local function ghost(r, key, model, at, heading, scenario)
    if model and at then r.ghosts[#r.ghosts + 1] = { key = key, model = model, at = at, heading = heading or 0.0, scenario = scenario } end
end

-- A person standing (or kneeling: scenario) on a floor point.
local function person(r, key, floor, heading, scenario)
    local model = PC.model(S.Standin or 'a_m_y_business_01')
    if not model then return end
    local min = PC.box(model)
    ghost(r, key, model, vector3(floor.x, floor.y, floor.z - min.z), heading, scenario)
end

-- The usable top's outline, 5 mm over it.
local function outline(r, view, ok)
    local f = view.frame.rect
    local c = {}
    for i, p in ipairs({ { f.x0, f.y0 }, { f.x1, f.y0 }, { f.x1, f.y1 }, { f.x0, f.y1 } }) do c[i] = PC.on(view, vector3(p[1], p[2], 0.005)) end
    for i = 1, 4 do r.lines[#r.lines + 1] = { c[i], c[i % 4 + 1], ok = ok } end
end

-- Surfaces ------------------------------------------------------------------------------------------------------

-- A body on the floor (section 3.2 step 3): the floor under the point level, its footprint's corners within FloorStep,
-- the origin on the highest one (no side sunk). rec: the model's record (map mode for the manikin: { top = 0 }).
local function onFloor(r, model, at, h, ignore, rec)
    local floor, normal = down(at.x, at.y, at.z, 0.5, 1.5, ignore)
    if not floor then return nil end
    check(r, floor, normal.z >= (S.FloorNormal or 0.985), 'floor_tilted')
    local min, max = PC.box(model)
    local high, low
    for _, p in ipairs({ { min.x, min.y }, { max.x, min.y }, { max.x, max.y }, { min.x, max.y } }) do
        local x, y = Frame.turn(h, p[1], p[2])
        local c = down(floor.x + x, floor.y + y, floor.z, 0.3, 0.6, ignore)
        if c then high, low = math.max(high or c.z, c.z), math.min(low or c.z, c.z)
        else check(r, vector3(floor.x + x, floor.y + y, floor.z), false, 'floor_edge') end
    end
    check(r, floor, high ~= nil and high - low <= (S.FloorStep or 0.015), 'floor_tilted')
    local origin = vector3(floor.x, floor.y, (high or floor.z) - min.z)
    local surface = Frame.bodySurface(origin, h, min, max, rec or (cfg.Models or {})[model])
    surface.normal, surface.material = normal.z, (rec or (cfg.Models or {})[model] or {}).material or 'other'
    return surface, origin
end

-- A table the map has (section 3.2 steps 1-3): an object's box top checked at its corners, or for the map's own
-- collision the largest rect round the point (stepping out until the top ends or steps); then turned a quarter at a
-- time until the student's side faces the camera; level at the middle and corners within MapFlat.
local function onTable(r, at, h, ignore)
    local top, normal, entity, material = down(at.x, at.y, at.z, 0.5, 1.5, ignore)
    if not top then return nil end
    check(r, top, normal.z >= (S.TableNormal or 0.995), 'table_tilted')
    local surface
    if entity and entity ~= 0 and GetEntityType(entity) == 3 then
        local model = GetEntityModel(entity)
        local min, max = GetModelDimensions(model)
        surface = Frame.bodySurface(GetEntityCoords(entity), GetEntityHeading(entity), min, max, RECORDS[model])
        local f = surface.rect
        for _, p in ipairs({ { f.x0 + 0.01, f.y0 + 0.01 }, { f.x1 - 0.01, f.y0 + 0.01 }, { f.x1 - 0.01, f.y1 - 0.01 }, { f.x0 + 0.01, f.y1 - 0.01 } }) do
            local x, y = Frame.turn(surface.heading, p[1], p[2])
            local c = down(surface.at.x + x, surface.at.y + y, surface.top, 0.1, 0.1, ignore)
            check(r, vector3(surface.at.x + x, surface.at.y + y, surface.top), c ~= nil and math.abs(c.z - surface.top) <= (S.Corner or 0.02), 'table_unmeasured')
        end
    else
        local reach, step = {}, S.EdgeStep or 0.02
        for i, dir in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
            local last, d = 0.0, step
            while d <= (S.EdgeMax or 1.5) + 1e-6 do
                local dx, dy = Frame.turn(h, dir[1] * d, dir[2] * d)
                local p = down(top.x + dx, top.y + dy, top.z, 0.05, 0.1, ignore)
                if not p or math.abs(p.z - top.z) > (S.EdgeRise or 0.015) then break end
                last, d = d, d + step
            end
            reach[i] = last
        end
        local cx, cy = Frame.turn(h, (reach[1] - reach[2]) / 2, (reach[3] - reach[4]) / 2)
        local hw, hd = (reach[1] + reach[2]) / 2, (reach[3] + reach[4]) / 2
        surface = { v = 1, at = { x = top.x + cx, y = top.y + cy }, top = top.z, floor = top.z - 0.9, heading = h % 360.0,
            rect = { x0 = -hw, x1 = hw, y0 = -hd, y1 = hd } }
    end
    -- the front (the student's side, -y) toward the camera
    local cam, best, turns = GetFinalRenderedCamCoord(), -2.0, 0
    local vx, vy = cam.x - surface.at.x, cam.y - surface.at.y
    local n = math.max(1e-6, math.sqrt(vx * vx + vy * vy))
    for k = 0, 3 do
        local fx, fy = Frame.turn(surface.heading + 90.0 * k, 0.0, -1.0)
        local dot = (fx * vx + fy * vy) / n
        if dot > best then best, turns = dot, k end
    end
    if turns % 2 == 1 then
        local f = surface.rect
        surface.rect = { x0 = f.y0, x1 = f.y1, y0 = f.x0, y1 = f.x1 }
    end
    surface.heading = (surface.heading + 90.0 * turns) % 360.0
    local f = surface.rect
    for _, p in ipairs({ { 0.0, 0.0 }, { f.x0 + 0.01, f.y0 + 0.01 }, { f.x1 - 0.01, f.y0 + 0.01 }, { f.x1 - 0.01, f.y1 - 0.01 }, { f.x0 + 0.01, f.y1 - 0.01 } }) do
        local x, y = Frame.turn(surface.heading, p[1], p[2])
        local c = down(surface.at.x + x, surface.at.y + y, surface.top, 0.05, 0.05, ignore)
        check(r, vector3(surface.at.x + x, surface.at.y + y, surface.top), c ~= nil and math.abs(c.z - surface.top) <= (S.MapFlat or 0.005), 'table_uneven')
    end
    surface.normal, surface.material = normal.z, material or 'other'
    return surface
end

-- Checks on a frame ---------------------------------------------------------------------------------------------

-- Where the student stands (the lab) or kneels (CPR): the floor there (the body's own within StandFloor; under a map
-- table at least half a metre down) and a free capsule (section 3.2 step 5). -> floor point, heading | nil
local function standing(r, view, mode, ignore)
    local kind = view.kind
    local point, heading
    if kind == 'first_aid_station' then point, heading = PC.games.cpr.kneel(view)
    else point, heading = PC.stand(view, cfg.Kinds.lab_bench.Layout.stand), PC.heading(view) end
    local top = view.frame.top.z
    local floor = down(point.x, point.y, top, 0.3, 2.5, ignore)
    if not floor then return check(r, point, false, 'stand_floor') and nil end
    local fits
    if mode == 'body' then fits = math.abs(floor.z - view.frame.floor.z) <= (S.StandFloor or 0.03)
    else fits = kind ~= 'lab_bench' or top - floor.z >= 0.5 end
    check(r, floor, fits, mode == 'body' and 'stand_floor' or 'not_a_table')
    local st = (S.Stand or {})[kind] or { low = 0.3, high = 1.7, radius = 0.3 }
    local blocked = capsule(floor + vector3(0.0, 0.0, st.low), floor + vector3(0.0, 0.0, st.high), st.radius, ignore)
    return floor, heading, not blocked
end

-- The shots' cameras (shared/practicals_shots.lua) from the layout's points, else the kind's one Camera: a free
-- capsule to each (step 6). The overview needs one free try; the others only warn (the runtime solver turns them).
local function cameras(r, view, game, ignore)
    local def, Sh = cfg.Kinds[view.kind], PracticalShots
    local pts = { centre = PC.on(view, vector3(0.0, 0.0, 0.0)) }
    for _, p in ipairs(game.points and game.points(view) or {}) do pts[p.name] = p.at end
    local facing, side = PC.heading(view), 1
    if game.facing then facing, side = game.facing(view) end
    local radius, nearest = S.CameraRadius or 0.18, S.CameraNearest or 0.6
    local function free(look, from)
        local hit, at = capsule(look, from, radius, ignore)
        if not hit or not at then return true end
        local x, y, z = Frame.pullIn(look, from, at, 0.12, 0.3)
        return #(vector3(x, y, z) - look) >= nearest
    end
    if not (Sh and type(Sh.pose) == 'function' and type(Sh.heading) == 'function' and def.Shots) then
        local on = view.kind == 'first_aid_station' and PC.games.cpr.at(view, def.Camera.on) or PC.on(view, def.Camera.on)
        local look = view.kind == 'first_aid_station' and PC.games.cpr.at(view, def.Camera.look) or PC.on(view, def.Camera.look)
        local ok = free(look, on)
        r.lines[#r.lines + 1] = { on, look, ok = ok }
        check(r, on, ok, 'camera_blocked')
        return
    end
    for name, shot in pairs(def.Shots) do
        local t = pts[shot.target]
        if t then
            local look = vector3(t.x, t.y, t.z + (shot.up or 0.0))
            local tries = name == 'overview' and (Sh.TRIES or { { 0, 0 } }) or { { 0, 0 } }
            local ok, first
            for _, try in ipairs(tries) do
                local x, y, z = Sh.pose(look, Sh.heading(facing, side, (shot.yaw or 0.0) + try[1]), (shot.pitch or 0.0) + try[2], shot.dist or 1.0)
                first = first or vector3(x, y, z)
                if free(look, vector3(x, y, z)) then
                    ok, first = true, vector3(x, y, z)
                    break
                end
            end
            r.lines[#r.lines + 1] = { first, look, ok = ok == true }
            if name == 'overview' then check(r, first, ok, 'camera_blocked') end
        end
    end
end

-- The lab's layout fits the top (step 7) and shows as ghosts; the manikin fits the mat.
local function layout(r, view)
    if view.kind == 'lab_bench' then
        local game = PC.games.lab_mix
        local m = game.models()
        local fits, name = game.layout(view.frame.rect, m)
        check(r, PC.on(view, vector3(0.0, 0.0, 0.02)), fits ~= nil, 'top_narrow')
        if not fits then r.narrow = name end
        local s = game.spots(view)
        local h = PC.heading(view)
        for _, key in ipairs({ 'heater', 'tripod', 'beaker', 'rod', 'rack' }) do
            if s[key] then ghost(r, key, m[key], PC.seat(m[key], s[key], h), h) end
        end
        for i, at in ipairs(s.bottles) do
            local model = PC.model(cfg.Kinds.lab_bench.Layout.bottles.model:format(cfg.Caps[i] or 'white'), cfg.Kinds.lab_bench.Layout.bottles.fallback)
            if model then ghost(r, 'bottle' .. i, model, PC.seat(model, at, h), h) end
        end
        return
    end
    local parts = PC.games.cpr.parts(view)
    for _, p in ipairs(parts) do ghost(r, p.key, p.model, p.at, p.heading) end
    local manikin = parts[1]
    if manikin then
        local min, max = PC.box(manikin.model)
        local f = view.frame.rect
        local turned = math.abs(((manikin.heading - view.frame.h) % 180.0) - 90.0) < 45.0
        local w, d = max.x - min.x, max.y - min.y
        if turned then w, d = d, w end
        check(r, PC.on(view, vector3(0.0, 0.0, 0.02)), w <= f.x1 - f.x0 + 0.05 and d <= f.y1 - f.y0 + 0.05, 'top_narrow')
    end
end

-- The whole measurement of one spot. coords: where the pointer put it (body mode: the floor; map mode: the table),
-- w the heading; uid: the spot being moved (its own body is not in the way); model: the spot's own body model.
local function measure(kind, coords, settings, uid, model)
    local r = { kind = kind, ghosts = {}, lines = {}, dots = {} }
    local def = cfg.Kinds[kind]
    local mode = settings and settings.mode == 'map' and 'map' or 'body'
    local h = (tonumber(coords.w) or 0.0) % 360.0
    local at = vector3(coords.x + 0.0, coords.y + 0.0, (coords.z or 0.0) + 0.0)
    local view0 = uid and PC.views[uid]
    local ignore = view0 and view0.body or 0
    local body = PC.model((model and model ~= '') and model or def.Model, def.Model)
    local surface, origin
    if mode == 'map' and kind == 'lab_bench' then surface = onTable(r, at, h, ignore)
    elseif body then surface, origin = onFloor(r, body, at, h, ignore, mode == 'map' and { top = 0.0 } or nil) end
    if not surface then
        r.problem = r.problem or 'no_surface'
        return r
    end
    surface.v, surface.mode, surface.side = 1, mode, 'right'
    local view = { kind = kind, frame = Frame.fromSurface(surface) }
    -- the student's place: CPR tries the manikin's other side (turned round) when the first is taken
    local floor, heading, free = standing(r, view, mode, ignore)
    if kind == 'first_aid_station' and floor and not free then
        surface.side = 'left'
        view.frame = Frame.fromSurface(surface)
        floor, heading, free = standing(r, view, mode, ignore)
    end
    if floor then
        check(r, floor + vector3(0.0, 0.0, 0.05), free, kind == 'first_aid_station' and 'kneel_blocked' or 'stand_blocked')
        surface.floor = floor.z
        view.frame = Frame.fromSurface(surface)
        person(r, 'person', floor, heading, kind == 'first_aid_station' and (S.Kneel or 'CODE_HUMAN_MEDIC_KNEEL') or nil)
    end
    -- the free height over the top (step 4), its body not counted
    local clear, rect = (S.Clear or {})[kind] or 0.45, view.frame.rect
    local middle = PC.on(view, vector3((rect.x0 + rect.x1) / 2, (rect.y0 + rect.y1) / 2, 0.01 + clear / 2))
    check(r, middle, boxFree(middle, vector3(rect.x1 - rect.x0 - 0.02, rect.y1 - rect.y0 - 0.02, clear), view.frame.h, ignore), 'top_blocked')
    layout(r, view)
    cameras(r, view, PC.games[kind == 'lab_bench' and 'lab_mix' or 'cpr'], ignore)
    outline(r, view, r.problem == nil)
    if origin and mode == 'body' then ghost(r, 'body', body, origin, h) end
    r.settings = { surface = surface, mode = mode }
    r.coords = origin and { x = origin.x, y = origin.y, z = origin.z, w = h } or { x = surface.at.x, y = surface.at.y, z = surface.top, w = surface.heading }
    return r
end

-- The world editor's hook ---------------------------------------------------------------------------------------

local last = { key = nil, result = nil, busy = false, next = 0 }

local function keyOf(kind, c, settings, uid, model)
    return ('%s|%s|%s|%s|%d|%d|%d|%d'):format(kind, settings and settings.mode or 'body', uid or '', model or '', math.floor(c.x * 50 + 0.5),
        math.floor(c.y * 50 + 0.5), math.floor((c.z or 0.0) * 50 + 0.5), math.floor((c.w or 0.0) + 0.5))
end

local function run(kind, coords, settings, uid, model)
    local ok, result = pcall(measure, kind, coords, settings, uid, model)
    if ok then return result end
    print(('^1[daddy_college] station survey: %s^7'):format(result))
    return { kind = kind, ghosts = {}, lines = {}, dots = {}, problem = 'failed' }
end

-- nil for kinds it does not measure; else the last measurement (one at a time on its own thread, again when the spot
-- moved 2 cm or turned a degree). final: a save waits for this very spot's measurement.
function Survey.preview(kind, coords, settings, final, uid, model)
    if not KINDS[kind] or type(coords) ~= 'table' or not tonumber(coords.x) then return nil end
    local key = keyOf(kind, coords, settings, uid, model)
    if final then
        while last.busy do Wait(0) end
        if last.key ~= key or not last.result then last.key, last.result = key, run(kind, coords, settings, uid, model) end
        return last.result
    end
    if last.key ~= key and not last.busy and GetGameTimer() >= last.next then
        last.busy, last.next = true, GetGameTimer() + 100
        CreateThread(function()
            local result = run(kind, coords, settings, uid, model)
            last.key, last.result, last.busy = key, result, false
        end)
    end
    if last.result and last.result.kind == kind then return last.result end
    return { kind = kind, ghosts = {}, lines = {}, dots = {} }
end
