-- Pure camp rules shared by both sides (and the unit tests): models, room, limits, fire, roasting, recipes.
Camp = Camp or {}

function Camp.firstState(def)
    return def.states and def.states[1] or 'default'
end

function Camp.hasState(def, state)
    if not def.states then return state == 'default' end
    for _, s in ipairs(def.states) do if s == state then return true end end
    return false
end

-- The pack model of a state, and the GTA model used when the pack is not installed.
function Camp.modelOf(def, state)
    local models = def.models or {}
    return models[state] or models[Camp.firstState(def)] or models.default, def.fallback
end

local function dist2(a, b)
    return (a.x - b.x) ^ 2 + (a.y - b.y) ^ 2
end

-- What a new piece at pos would stand on (its snap target) or collide with: snap, blocker.
function Camp.room(pieces, defs, def, pos)
    local snap
    for _, piece in pairs(pieces) do
        local other = defs[piece.key]
        if other and math.abs(piece.z - pos.z) < 3.0 then
            local d = math.sqrt(dist2(piece, pos))
            if def.over and def.over[other.kind] and d < other.radius + 0.6 then
                snap = snap or piece
            elseif not (def.small and other.surface) and d < ((other.radius or 0.3) + (def.radius or 0.3)) * 0.8 then
                if not (other.over and other.over[def.kind]) then return nil, piece end
            end
        end
    end
    if snap then
        for _, piece in pairs(pieces) do
            local other = defs[piece.key]
            if piece ~= snap and other and other.over and other.over[defs[snap.key].kind] and dist2(piece, snap) < 0.25 then return nil, piece end
        end
    end
    return snap, nil
end

function Camp.inZone(zones, pos)
    for _, zone in ipairs(zones or {}) do
        local c = zone.coords
        if (c.x - pos.x) ^ 2 + (c.y - pos.y) ^ 2 + (c.z - pos.z) ^ 2 < zone.radius ^ 2 then return true end
    end
    return false
end

-- How many pieces a character has, in all and of one kind.
function Camp.count(pieces, defs, owner, kind)
    local total, same = 0, 0
    for _, piece in pairs(pieces) do
        if piece.owner == owner then
            total = total + 1
            if defs[piece.key] and defs[piece.key].kind == kind then same = same + 1 end
        end
    end
    return total, same
end

-- A camp's middle: the owner's first tent or fire, else their first piece of any kind.
function Camp.centerOf(pieces, defs, owner)
    local center, any
    for _, piece in pairs(pieces) do
        if piece.owner == owner then
            local kind = defs[piece.key] and defs[piece.key].kind
            if (kind == 'tent' or kind == 'fire') and (not center or piece.id < center.id) then center = piece end
            if not any or piece.id < any.id then any = piece end
        end
    end
    return center or any
end

-- Whether owner may set def down at pos (Config.Camp rules and limits): nil, or the problem's locale key.
function Camp.allow(pieces, defs, def, owner, pos, rules, limits)
    local total, same, crowd, gap2, area2 = 0, 0, 0, rules.Gap ^ 2, rules.Area ^ 2
    for _, piece in pairs(pieces) do
        local d2 = dist2(piece, pos)
        if piece.owner == owner then
            total = total + 1
            if defs[piece.key] and defs[piece.key].kind == def.kind then same = same + 1 end
        elseif d2 < gap2 then
            return 'camp_near'
        end
        if d2 < area2 then crowd = crowd + 1 end
    end
    local perKind = limits.PerKind[def.kind]
    if total >= limits.Total or (perKind and same >= perKind) then return 'limit' end
    local center = Camp.centerOf(pieces, defs, owner)
    if not center and def.kind ~= 'tent' and def.kind ~= 'fire' then return 'need_camp' end
    if center and dist2(center, pos) > rules.Radius ^ 2 then return 'camp_far' end
    if crowd >= rules.AreaMax then return 'area_full' end
    return nil
end

-- The grid cell a point is in, and the keys of the 3 x 3 cells around it.
function Camp.cell(x, y, size)
    return math.floor(x / size), math.floor(y / size)
end

function Camp.cellKey(cx, cy)
    return cx .. ':' .. cy
end

function Camp.around(cx, cy)
    local keys = {}
    for dx = -1, 1 do
        for dy = -1, 1 do keys[#keys + 1] = Camp.cellKey(cx + dx, cy + dy) end
    end
    return keys
end

-- The item (and its metadata) a piece goes back as; nil when nothing is left of it (a lit or burnt torch).
function Camp.itemOf(p, def)
    if p.key == 'torch' and p.state ~= 'unlit' then return nil end
    local meta = {}
    if p.data.stash then meta.stash = p.data.stash end
    if def.kind == 'stack' then meta.wood = p.data.wood end
    if p.key == 'torch' and p.data.burnLeft then meta.burnLeft = p.data.burnLeft end
    return def.item, next(meta) and meta or nil
end

-- Fire: { wood = seconds of fuel at `at`, lit, at, outAt }; rate: fuel seconds burnt per second (rain burns faster).
Camp.fire = {}
local Fire = Camp.fire

function Fire.left(f, now, rate)
    if not f.lit then return f.wood or 0 end
    return math.max(0, (f.wood or 0) - (now - (f.at or now)) * rate)
end

function Fire.state(f, now, rate, cfg)
    local left = Fire.left(f, now, rate)
    if f.lit and left > 0 then return left <= cfg.EmbersMinutes * 60 and 'embers' or 'burning' end
    if not f.lit and left > 0 then return 'laid' end
    local outAt = f.outAt
    if f.lit then outAt = (f.at or now) + (f.wood or 0) / rate end
    if outAt and now < outAt + cfg.OutMinutes * 60 then return 'out' end
    return 'empty'
end

-- Writes the burnt fuel down so the rate can change from now on.
function Fire.settle(f, now, rate)
    if f.lit then
        local left = Fire.left(f, now, rate)
        if left <= 0 then
            f.outAt, f.lit = (f.at or now) + (f.wood or 0) / rate, false
        end
        f.wood = left
    end
    f.at = now
    return f
end

function Fire.addWood(f, now, rate, cfg)
    Fire.settle(f, now, rate)
    local bundle = cfg.WoodMinutes * 60
    if (f.wood or 0) + bundle > cfg.MaxWood * bundle + 1 then return false end
    f.wood = (f.wood or 0) + bundle
    return true
end

function Fire.light(f, now)
    if f.lit or (f.wood or 0) <= 0 then return false end
    f.lit, f.at = true, now
    return true
end

function Fire.douse(f, now, rate)
    Fire.settle(f, now, rate)
    if not f.lit and (f.wood or 0) <= 0 then return false end
    f.lit, f.wood, f.outAt = false, 0, now
    return true
end

-- Roasting: the good window moves a little each time; pulled at share t of the time it is raw, golden or burnt.
function Camp.roastWindow(cfg, rnd)
    local shift = ((rnd or 0.5) * 2 - 1) * (cfg.Jitter or 0)
    return { cfg.Golden[1] + shift, cfg.Golden[2] + shift }
end

function Camp.roast(elapsed, seconds, window)
    local t = elapsed / seconds
    if t < window[1] then return 'raw' end
    if t < window[2] then return 'golden' end
    return 'burnt'
end

-- The stacks a recipe takes from someone, or nil: for each input the first listed item they have enough of.
function Camp.inputs(recipe, countOf)
    local out = {}
    for _, input in ipairs(recipe.inputs) do
        local found
        for _, item in ipairs(input.items) do
            if countOf(item) >= (input.count or 1) then found = item break end
        end
        if not found then return nil end
        out[#out + 1] = { item = found, count = input.count or 1 }
    end
    return out
end

-- Firewood stack: full while at least half of it is left.
function Camp.stackState(wood, capacity)
    return wood * 2 >= capacity and 'full' or 'low'
end
