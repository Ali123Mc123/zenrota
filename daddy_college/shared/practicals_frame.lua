-- Station geometry on both sides, without natives: points in a station's frame, where a model's origin goes so it
-- sits on a surface, a saved surface as a frame, the layout solver, clip origins, a camera pulled in front of a wall,
-- and which stations a client builds. Tests:
-- docs/yeni-sistemler/tests/cpr-deney.test.mjs.
PracticalFrame = {}
local Frame = PracticalFrame

-- x, y turned by heading h (degrees), the way the game turns an entity's own axes (x right, y forward).
function Frame.turn(h, x, y)
    local r = math.rad(h or 0.0)
    return x * math.cos(r) - y * math.sin(r), x * math.sin(r) + y * math.cos(r)
end

-- A point given in a frame { x, y, z, h }, in the world.
function Frame.point(frame, v)
    local x, y = Frame.turn(frame.h, v.x, v.y)
    return frame.x + x, frame.y + y, frame.z + (v.z or 0.0)
end

-- Where a model's origin goes so it sits on a surface point at heading h: the middle of its footprint on the point,
-- its bottom on the surface, wherever its pivot is (min, max: GetModelDimensions). pivot = true: a part that turns on
-- its own pivot (the manikin's chest pad and head) has the pivot itself on the point.
function Frame.seat(at, h, min, max, pivot)
    if pivot then return at.x, at.y, at.z end
    local x, y = Frame.turn(h, (min.x + max.x) / 2, (min.y + max.y) / 2)
    return at.x - x, at.y - y, at.z - min.z
end

-- A camera in front of what stands between it and its target: hit is where a capsule from the target out to the
-- camera first touched something. The camera comes back along the line to margin before it, never nearer the target
-- than nearest.
function Frame.pullIn(target, cam, hit, margin, nearest)
    local dx, dy, dz = cam.x - target.x, cam.y - target.y, cam.z - target.z
    local length = math.sqrt(dx * dx + dy * dy + dz * dz)
    if length < 0.001 then return cam.x, cam.y, cam.z end
    dx, dy, dz = dx / length, dy / length, dz / length
    local along = (hit.x - target.x) * dx + (hit.y - target.y) * dy + (hit.z - target.z) * dz
    local d = math.min(length, math.max(nearest or 0.0, along - (margin or 0.0)))
    return target.x + dx * d, target.y + dy * d, target.z + dz * d
end

-- Surfaces (10-cpr-deney.md section 3) ---------------------------------------------------------------------------
-- settings.surface, measured once in the editor: { v, mode = 'body' | 'map', at = { x, y } (the usable top's middle),
-- top, floor (world z), heading (the student faces it), rect = { x0, x1, y0, y1 } (from the middle; y0 is the
-- student's side), normal, material, side }.

-- A station's frame from its surface: the middle of the top at its height, the floor under it, its heading, the rect.
function Frame.fromSurface(s)
    local h, r = (s.heading or 0.0) % 360.0, s.rect
    return { h = h, mode = s.mode, side = s.side or 'right', material = s.material,
        top = { x = s.at.x, y = s.at.y, z = s.top, h = h }, floor = { x = s.at.x, y = s.at.y, z = s.floor, h = h },
        rect = { x0 = r.x0, x1 = r.x1, y0 = r.y0, y1 = r.y1 }, front = r.y0 }
end

-- A body's surface from its model box (min, max) and the config's record for the model (top, rect in the model's own
-- metres; missing parts come from the box), standing at origin (x, y, z) with heading h.
function Frame.bodySurface(origin, h, min, max, rec)
    rec = rec or {}
    local r = rec.rect or {}
    local x0, x1, y0, y1 = r.x0 or min.x, r.x1 or max.x, r.y0 or min.y, r.y1 or max.y
    local mx, my = (x0 + x1) / 2, (y0 + y1) / 2
    local dx, dy = Frame.turn(h, mx, my)
    return { v = 1, mode = 'body', heading = h % 360.0, top = origin.z + (rec.top or max.z), floor = origin.z + min.z,
        at = { x = origin.x + dx, y = origin.y + dy }, rect = { x0 = x0 - mx, x1 = x1 - mx, y0 = y0 - my, y1 = y1 - my } }
end

-- A spot on the top by the rect's edges: x 'left' | 'right' (dx in from that edge) or the middle (dx to the right),
-- y 'front' | 'back' (dy in from that edge) or the middle (dy forward). Front is the student's side.
function Frame.edge(rect, slot)
    local dx, dy = slot.dx or 0.0, slot.dy or 0.0
    local x = slot.x == 'left' and rect.x0 + dx or slot.x == 'right' and rect.x1 - dx or (rect.x0 + rect.x1) / 2 + dx
    local y = slot.y == 'front' and rect.y0 + dy or slot.y == 'back' and rect.y1 - dy or (rect.y0 + rect.y1) / 2 + dy
    return x, y
end

local function fits(rect, f, margin)
    return f.x - f.w / 2 >= rect.x0 + margin - 1e-6 and f.x + f.w / 2 <= rect.x1 - margin + 1e-6
        and f.y - f.d / 2 >= rect.y0 + margin - 1e-6 and f.y + f.d / 2 <= rect.y1 - margin + 1e-6
end

-- A spot pulled in so a footprint w x d stays inside the rect less margin (left as it is when it cannot).
local function inside(rect, x, y, w, d, margin)
    local lx, hx, ly, hy = rect.x0 + margin + w / 2, rect.x1 - margin - w / 2, rect.y0 + margin + d / 2, rect.y1 - margin - d / 2
    if lx <= hx then x = math.max(lx, math.min(hx, x)) end
    if ly <= hy then y = math.max(ly, math.min(hy, y)) end
    return x, y
end

local function clear(f, placed)
    for _, o in ipairs(placed) do
        if o.stack ~= f.stack and math.abs(f.x - o.x) * 2 < f.w + o.w - 1e-6 and math.abs(f.y - o.y) * 2 < f.d + o.d - 1e-6 then return false end
    end
    return true
end

-- Where the layout's props stand on the top (section 3.3.2), placed in the given order. items:
--   { name, w, d (footprint), x, dx, y, dy (Frame.edge), on = name (stands on another: its spot, no clash with it),
--     decor = true (dropped when it does not fit), count, gap (a row of count side by side, two rows when one fails) }
-- Each footprint plus pad stays inside the rect less margin and clear of the others; loose: each goes on its spot
-- regardless (a station the editor already accepted). -> { name = { x, y } | { { x, y }, ... } } | nil, the name
function Frame.layout(rect, items, pad, margin, loose)
    pad, margin = pad or 0.01, margin or 0.03
    local out, placed, stackOf = {}, {}, {}
    local function try(list)
        for _, f in ipairs(list) do
            if not loose and (not fits(rect, f, margin) or not clear(f, placed)) then return false end
        end
        for _, f in ipairs(list) do placed[#placed + 1] = f end
        return true
    end
    for _, item in ipairs(items) do
        local w, d = item.w + pad, item.d + pad
        if item.count then
            local x, y = Frame.edge(rect, item)
            local step, back = math.max(item.gap or 0.0, w), item.y == 'front' and 1 or -1
            local done
            for rows = 1, 2 do
                local list, per = {}, math.ceil(item.count / rows)
                local rx, ry = inside(rect, x, y, (per - 1) * step + w, d, margin)
                for i = 1, item.count do
                    local row, col = math.floor((i - 1) / per), (i - 1) % per
                    local inRow = math.min(per, item.count - row * per)
                    list[i] = { stack = item.name .. i, x = rx + (col - (inRow - 1) / 2) * step, y = ry + back * row * (d + 0.02), w = w, d = d }
                end
                if try(list) then done = list break end
            end
            if done then
                out[item.name] = {}
                for i, f in ipairs(done) do out[item.name][i] = { x = f.x, y = f.y } end
            elseif not item.decor then
                return nil, item.name
            end
        else
            local base = item.on and out[item.on]
            local x, y
            if base then
                x, y = base.x, base.y
            else
                local ex, ey = Frame.edge(rect, item)
                x, y = inside(rect, ex, ey, w, d, margin)
            end
            local f = { stack = base and stackOf[item.on] or item.name, x = x, y = y, w = w, d = d }
            if try({ f }) then
                out[item.name], stackOf[item.name] = { x = x, y = y }, f.stack
            elseif not item.decor then
                return nil, item.name
            end
        end
    end
    return out
end

-- A camera shot given in a frame (on: where it stands, look: what it looks at) as two world points.
function Frame.shot(frame, shot)
    local fx, fy, fz = Frame.point(frame, shot.on)
    local lx, ly, lz = Frame.point(frame, shot.look)
    return { x = fx, y = fy, z = fz }, { x = lx, y = ly, z = lz }
end

-- The origin a clip plays at so its point at (in the clip's own frame) lands on target with the clip turned to h
-- (section 5.1): origin = target - R(h) * at.
function Frame.origin(target, h, at)
    local x, y = Frame.turn(h, at.x, at.y)
    return target.x - x, target.y - y, target.z - (at.z or 0.0)
end

-- Where the rescuer's CPR clip starts (section 5.6), from the manikin's frame { x, y, z, h } and its chest pad's point
-- in it: the clips turned cal.turn from the manikin with char_b's chest (cal.chest) on the pad, char_a starting at
-- cal.rescuer facing cal.yaw. -> x, y, heading, and the clips' origin { x, y, h }
function Frame.kneel(manikin, chest, cal)
    local h = (manikin.h + (cal.turn or 180.0)) % 360.0
    local px, py = Frame.point(manikin, chest)
    local ox, oy = Frame.origin({ x = px, y = py, z = 0.0 }, h, cal.chest)
    local kx, ky = Frame.point({ x = ox, y = oy, z = 0.0, h = h }, cal.rescuer)
    return kx, ky, (h + (cal.yaw or 0.0)) % 360.0, { x = ox, y = oy, h = h }
end

-- How far a pad is pressed: the hands' height under where they first touch it (rest), at most travel.
function Frame.depth(rest, handZ, travel) return math.max(0.0, math.min(travel, rest - handZ)) end

-- The signed angle from a to b (radians, -pi..pi): summed while the pointer circles, 2 pi is one turn.
function Frame.swept(a, b)
    local d = (b - a) % (2 * math.pi)
    if d > math.pi then d = d - 2 * math.pi end
    return d
end

-- The stations a client builds: its own first, then the nearest, limit in all. rows: { { key, own, d } } -> { key = true }
function Frame.keep(rows, limit)
    local list = {}
    for _, row in ipairs(rows) do list[#list + 1] = row end
    table.sort(list, function(a, b)
        local ownA, ownB = a.own == true, b.own == true
        if ownA ~= ownB then return ownA end
        return a.d < b.d
    end)
    local out = {}
    for i = 1, math.min(#list, limit) do out[list[i].key] = true end
    for _, row in ipairs(list) do
        if row.own then out[row.key] = true end
    end
    return out
end
