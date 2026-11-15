-- The lab bench: a burner with a tripod and the beaker on it, a glass rod, a tube rack and the reagent bottles, each
-- where the layout solver puts it on the bench's top (shared/practicals_frame.lua). The player clicks a bottle to take
-- it (the student steps along the bench and picks it up), holds the button on the beaker to pour, puts it back (right
-- click or its spot); holds the burner's button to heat; takes the glass rod and circles the mouse over the beaker to
-- stir. Everyone near sees the bottle in hand, the stream from its mouth, the flame and the rod turning. The worksheet
-- on screen is views/practicals/Lab.vue; the liquid and the reactions are look.lua.
local PC = Core.PracticalClient
if not PC then return end

local cfg = PC.cfg
local Frame = PracticalFrame
local def = cfg.Kinds.lab_bench
local L, A, C = def.Layout, def.Anims, cfg.Calibration or {}

local game = {}
PC.games.lab_mix = game

local function tint(colour) return (cfg.Liquids[colour] or cfg.Liquids.clear or {}).tint end

local function flat(x, y) return vector3(x, y, 0.0) end

local function bottleModel(cap) return PC.model(L.bottles.model:format(cap or 'white'), L.bottles.fallback) end

local function size(model)
    local min, max = PC.box(model)
    return max.x - min.x, max.y - min.y, max.z - min.z
end

-- Layout --------------------------------------------------------------------------------------------------------

-- The models this client has for the bench (custom first, then the fallback; none: that prop stays out).
function game.models()
    return { heater = PC.model(L.heater.model, L.heater.fallback), tripod = PC.model(L.tripod.model), beaker = PC.model(L.beaker.model, L.beaker.fallback),
        rod = PC.model(L.rod.model, L.rod.fallback), bottle = bottleModel('white'), rack = PC.model(L.rack.model, L.rack.fallback) }
end

-- Where the bench's props stand on a top (rect from its middle; the editor checks it fits, section 3.3.2): name ->
-- { x, y }, the bottles a list; nil and the name that does not fit. loose: everything on its spot regardless.
function game.layout(rect, m, loose)
    local items = {}
    local function add(name, spot, model, extra)
        if not model then return end
        local w, d = size(model)
        local item = { name = name, w = w, d = d, x = spot.x, dx = spot.dx, y = spot.y, dy = spot.dy, on = spot.on, decor = spot.decor }
        for k, v in pairs(extra or {}) do item[k] = v end
        items[#items + 1] = item
    end
    add('heater', L.heater, m.heater)
    add('tripod', L.tripod, m.tripod)
    add('beaker', L.beaker, m.beaker, { on = m.tripod and 'tripod' or 'heater' })
    add('rod', L.rod, m.rod)
    add('bottles', L.bottles, m.bottle, { count = #cfg.Caps, gap = L.bottles.gap })
    add('rack', L.rack, m.rack)
    return Frame.layout(rect, items, nil, nil, loose)
end

-- The bench's spots on its top (world points; the beaker over what it stands on), solved once per build.
local function spots(view)
    if view.spots then return view.spots end
    local m = game.models()
    local out = game.layout(view.frame.rect, m) or game.layout(view.frame.rect, m, true) or {}
    local base = m.tripod or m.heater
    local lift = base and select(3, size(base)) or 0.0
    local s = { models = m, bottles = {} }
    for name, p in pairs(out) do
        if name == 'bottles' then
            for i, b in ipairs(p) do s.bottles[i] = PC.on(view, vector3(b.x, b.y, 0.0)) end
        else
            s[name] = PC.on(view, vector3(p.x, p.y, name == 'beaker' and lift or 0.0))
        end
    end
    view.spots = s
    return s
end
game.spots = spots

local function slotAt(view, slot) local s = spots(view) return s.bottles[slot] or s.bottles[1] or PC.on(view, vector3(0.0, 0.0, 0.0)) end
local function beakerAt(view) return spots(view).beaker or PC.on(view, vector3(0.0, 0.0, 0.0)) end
local function heaterAt(view) return spots(view).heater or beakerAt(view) end
local function rodAt(view) return spots(view).rod or PC.on(view, vector3(-0.24, 0.0, 0.0)) end

-- The beaker's mouth (world).
local function beakerTop(view)
    local m = spots(view).models.beaker
    return beakerAt(view) + vector3(0.0, 0.0, m and select(3, size(m)) or 0.12)
end

-- The burner's button: our burner's gas valve (L.heater.knob from its base), else the middle of the plate's front.
local function knobAt(view)
    local m, h = spots(view).models.heater, PC.heading(view)
    local k = m == L.heater.model and L.heater.knob
    if k then return heaterAt(view) + flat(Frame.turn(h, k.x, k.y)) + vector3(0.0, 0.0, k.z) end
    local d = m and select(2, size(m)) or 0.2
    return heaterAt(view) + flat(Frame.turn(h, 0.0, -d / 2 + 0.02)) + vector3(0.0, 0.0, 0.03)
end

-- Moves an entity so its own point (local offset) lands on a world point, turned as it is now.
local function pinAt(entity, offset, target)
    local p, c = GetOffsetFromEntityInWorldCoords(entity, offset.x, offset.y, offset.z), GetEntityCoords(entity)
    SetEntityCoordsNoOffset(entity, c.x + target.x - p.x, c.y + target.y - p.y, c.z + target.z - p.z, false, false, false)
end

-- How long after a clip starts its hand touches what it takes (Calibration[key].contact).
local function contact(view, clip, key)
    return ((C[key] or {}).contact or 0.4) * PC.clipMs(clip, view.ped or cache.ped)
end

-- Bottles on the bench, the one in hand on its user's hand. A pick or a put back moves it at the clip's contact on
-- every client (view.moving keeps the slot as it is until then).
local function placeBottles(view, scene)
    local ped = PC.userPed(scene)
    view.home, view.moving = view.home or {}, view.moving or {}
    for _, s in ipairs(scene.slots or {}) do
        local name = 'bottle' .. s.slot
        local entity = view.objects[name] or PC.object(view, name, bottleModel(s.cap), slotAt(view, s.slot))
        if entity and not view.moving[s.slot] then
            if scene.held == s.slot then
                if ped and not IsEntityAttachedToEntity(entity, ped) then PC.attach(entity, ped) end
                view.home[name] = false
            elseif IsEntityAttached(entity) or view.home[name] ~= true then
                DetachEntity(entity, false, false)
                PC.put(entity, slotAt(view, s.slot), PC.heading(view))
                FreezeEntityPosition(entity, true)
                view.home[name] = true
            end
        end
    end
end

-- The rod (its origin is the grip, L.rod.tip its lower end): lying on its spot, or standing in the beaker leaning a
-- little with its tip on a small circle at angle (radians).
local function placeRod(view, angle)
    local entity = view.objects.rod
    if not entity or not DoesEntityExist(entity) then return end
    local min = PC.box(GetEntityModel(entity))
    local tip = GetEntityModel(entity) == joaat(L.rod.model) and L.rod.tip or vector3(0.0, 0.0, min.z)
    local h = PC.heading(view)
    if angle == nil then
        SetEntityRotation(entity, 0.0, 90.0, h, 2, true)
        return pinAt(entity, tip * 0.5, rodAt(view) + vector3(0.0, 0.0, 0.006))
    end
    local r = L.rod.radius or 0.018
    SetEntityRotation(entity, 8.0, 0.0, (h + math.deg(angle) + 90.0) % 360.0, 2, true)
    pinAt(entity, tip, beakerAt(view) + vector3(math.cos(angle) * r, math.sin(angle) * r, (L.liquid and L.liquid.lift or 0.005) + 0.004))
end

-- The rod turning in the beaker while someone stirs: the player's own follows their mouse, others' turn steadily.
local function turning(view)
    if view.turning then return end
    view.turning = true
    CreateThread(function()
        local start = GetGameTimer()
        while view.stirOn and view.built and not view.gone do
            placeRod(view, PC.mine(view) and view.stirAngle or (GetGameTimer() - start) / 1000 * 3.0 * math.pi)
            Wait(0)
        end
        view.turning = false
    end)
end

-- While a bottle pours (pourOn until the pour): the stream from its mouth, only while it is tipped past L.tilt; every
-- client works it out from the pose it sees (section 5.3).
local function streaming(view, slot)
    if view.streaming then return end
    view.streaming = true
    CreateThread(function()
        local entity = view.objects['bottle' .. slot]
        local limit = math.cos(math.rad(L.tilt or 70.0))
        local s = (view.scene and view.scene.slots or {})[slot] or {}
        -- our bottle's cap from its grip (L.bottles.mouth); a stand-in's top of its box
        local custom = entity and GetEntityModel(entity) == joaat(L.bottles.model:format(s.cap or 'white'))
        local _, max = PC.box(entity and GetEntityModel(entity) or 0)
        local mouth = custom and L.bottles.mouth or vector3(0.0, 0.0, max.z)
        while entity and DoesEntityExist(entity) and view.built and not view.gone and view.scene and view.scene.pouring == slot do
            local _, _, up = GetEntityMatrix(entity)
            local tipped = up.z < limit
            if tipped and not view.fx.pour then PC.fxOn(view, def.Fx.pour, entity, mouth, 'pour', tint(s.tint or 'clear'))
            elseif not tipped and view.fx.pour then PC.stopFx(view, 'pour') end
            Wait(0)
        end
        PC.stopFx(view, 'pour')
        view.streaming = false
    end)
end

function game.build(view, scene)
    view.home, view.moving, view.spots, view.rodIn, view.stirOn = {}, {}, nil, false, false
    local s = spots(view)
    for _, name in ipairs({ 'heater', 'tripod', 'beaker', 'rod', 'rack' }) do
        if s[name] then PC.object(view, name, s.models[name], s[name]) end
    end
    placeBottles(view, scene)
end

-- The burner: a spark at the button's contact, then the flame (the custom burner) and the heat haze while it is on;
-- the button again puts it out (section 5.5).
local function burner(view, scene, op)
    local flameAt = heaterAt(view) + vector3(0.0, 0.0, L.heater.flame or 0.16)
    -- our burner: its flame model at the mouth (else the candle flame effect); the stand-in plate has none
    local ours = spots(view).models.heater == L.heater.model
    local function on()
        if not (view.scene and view.scene.heat) then return end
        PC.fx(view, def.Fx.spark, flameAt)
        PC.sound('ignite', flameAt)
        local flame = ours and L.heater.flameModel and PC.model(L.heater.flameModel)
        if flame then PC.object(view, 'flame', flame, flameAt, PC.heading(view), true)
        elseif ours then PC.fx(view, def.Fx.flame, flameAt, 'flame') end
        PC.fx(view, def.Fx.heat, beakerTop(view), 'heat')
    end
    local function off()
        PC.remove(view, 'flame')
        PC.stopFx(view, 'flame')
        PC.stopFx(view, 'heat')
    end
    if op == 'heatOn' then PC.later(view, contact(view, A.button, 'button'), on)
    elseif op == 'heat' then PC.later(view, contact(view, A.button, 'button'), off)
    elseif scene.heat and not view.fx.heat then on()
    elseif not scene.heat and view.fx.heat then off() end
end

-- The rod: into the beaker at the pickup's contact, turning while stirOn, back on its spot after (section 5.4).
local function rod(view, scene, op)
    local function set(on)
        view.rodIn = on
        placeRod(view, on and (view.stirAngle or 0.0) or nil)
    end
    if op == 'rod' then PC.later(view, contact(view, A.pickup, 'pickup'), function() set(true) end)
    elseif op == 'stirOn' then
        view.stirOn = true
        PC.fx(view, def.Fx.stir, beakerTop(view) - vector3(0.0, 0.0, 0.04), 'stir')
        turning(view)
    elseif op == 'stir' or op == 'rodBack' then
        view.stirOn = false
        PC.stopFx(view, 'stir')
        PC.later(view, contact(view, A.pickup, 'pickup'), function() set(false) end)
    elseif op == nil then -- built late: as the scene is now
        if scene.rod and not view.rodIn then set(true) end
        if scene.stir and not view.stirOn then
            view.stirOn = true
            turning(view)
        end
    end
end

-- The props and the interaction effects (the bottle in hand, the stream, the burner, the rod). The liquid's colour
-- and level, each step's reaction and the end are client/practicals/look.lua (section 7), from the same scene.
function game.apply(view, scene, event)
    local op = event.op
    if (op == 'pick' or op == 'putback') and event.slot then
        local slot = event.slot
        view.moving = view.moving or {}
        view.moving[slot] = true
        PC.later(view, contact(view, A.pickup, 'pickup'), function()
            view.moving[slot] = nil
            placeBottles(view, view.scene)
        end)
    end
    placeBottles(view, scene)
    burner(view, scene, op)
    rod(view, scene, op)
    if scene.pouring and (op == 'pourOn' or op == nil) then streaming(view, scene.pouring) end
end

function game.clear(view)
    for _, name in ipairs({ 'heat', 'flame', 'pour', 'stir' }) do PC.stopFx(view, name) end
    view.home, view.moving, view.spots, view.stirOn, view.rodIn = nil, nil, nil, false, false
end

-- Someone new watches: the student's loops start again so their game gets the task (section 5.8).
function game.resync(_, mine)
    PC.anim(A.idle, true)
    if mine.carry or mine.rodIn then PC.anim(A.hold, true) end
end

-- The way the student faces here (the camera's shots turn from it).
function game.facing(view) return PC.heading(view), 1 end

-- Named points for /practicaldebug (the camera's shots look at them too).
function game.points(view)
    local s = spots(view)
    local out = { { name = 'stand', at = PC.stand(view, L.stand), r = 255, g = 80, b = 80 },
        { name = 'beaker', at = beakerAt(view) }, { name = 'heater', at = heaterAt(view) },
        { name = 'pour', at = beakerTop(view) + vector3(0.0, 0.0, 0.05), r = 120, g = 255, b = 120 },
        { name = 'camera', at = PC.on(view, def.Camera.on), r = 255, g = 255, b = 0 } }
    for _, name in ipairs({ 'rack', 'rod', 'tripod' }) do
        if s[name] then out[#out + 1] = { name = name, at = s[name] } end
    end
    for i, at in ipairs(s.bottles) do out[#out + 1] = { name = 'bottle ' .. i, at = at } end
    return out
end

-- Playing --------------------------------------------------------------------------------------------------------

-- The things the mouse can pick (section 5.2): the bottles on the bench (the one in hand: its empty spot, to put it
-- back), the beaker, the burner's button and the rod while it lies on the bench.
local function marksFor(view, data, mine)
    local list = { { id = 'beaker', kind = 'beaker', at = beakerTop(view) - vector3(0.0, 0.0, 0.03), r = 0.06 },
        { id = 'heater', kind = 'heater', at = knobAt(view), r = 0.05 } }
    if not mine.rodIn and view.objects.rod then list[#list + 1] = { id = 'rod', kind = 'rod', at = rodAt(view) + vector3(0.0, 0.0, 0.02), r = 0.045 } end
    for _, s in ipairs(data.slots) do
        local at = slotAt(view, s.slot)
        if s.slot == mine.carry then list[#list + 1] = { id = 'slot:' .. s.slot, kind = 'slot', label = s.name, cap = s.cap, at = at + vector3(0.0, 0.0, 0.02), r = 0.05 }
        else list[#list + 1] = { id = 'bottle:' .. s.slot, kind = 'bottle', label = s.name, cap = s.cap, at = at + vector3(0.0, 0.0, 0.1), r = 0.05 } end
    end
    return PC.marks(list)
end

-- The pour clip (section 5.3): at its origin from the beaker once calibrated (pour.mouth: the beaker's mouth in the
-- clip's frame; a networked scene of the ped when Sync.PourScene), else where the student stands, upper body only.
-- It stops at the pour phase while the button is held (this client: G2); let go plays it out.
local function pourClip(view, mine)
    local calib = C.pour or {}
    local h, ped = PC.heading(view), cache.ped
    local dict = (not IsPedMale(ped) and A.pour.female) or A.pour.dict
    if calib.mouth and pcall(lib.requestAnimDict, dict, 2000) then
        local o = vector3(Frame.origin(beakerTop(view), h, calib.mouth))
        if cfg.Sync and cfg.Sync.PourScene then
            mine.pourScene = NetworkCreateSynchronisedScene(o.x, o.y, o.z, 0.0, 0.0, h, 2, false, false, 1.0, 0, 1.0)
            NetworkAddPedToSynchronisedScene(ped, mine.pourScene, dict, A.pour.clip, 8.0, -8.0, 0, 0, 1000.0, 0)
            NetworkStartSynchronisedScene(mine.pourScene)
        else
            TaskPlayAnimAdvanced(ped, dict, A.pour.clip, o.x, o.y, o.z, 0.0, 0.0, h, 8.0, -8.0, -1, 0, 0.0, 0, 0)
        end
    else
        PC.anim(A.pour)
    end
    local hold = calib.hold or 0.42
    CreateThread(function()
        local untilMs = GetGameTimer() + 4000
        while mine.pourAt and not mine.over and GetGameTimer() < untilMs do
            local scene = mine.pourScene and NetworkGetLocalSceneFromNetworkId(mine.pourScene)
            local phase = scene and scene ~= -1 and GetSynchronizedScenePhase(scene) or PC.phase(ped, A.pour)
            if phase and phase >= hold then
                if scene and scene ~= -1 then SetSynchronizedSceneRate(scene, 0.0) else PC.animSpeed(ped, A.pour, 0.0) end
                return
            end
            Wait(0)
        end
    end)
end

-- Let go: the clip plays out (the bottle comes up), then the student holds the bottle again.
local function pourOut(mine)
    local ped = cache.ped
    local scene = mine.pourScene and NetworkGetLocalSceneFromNetworkId(mine.pourScene)
    if scene and scene ~= -1 then SetSynchronizedSceneRate(scene, 1.0) else PC.animSpeed(ped, A.pour, 1.0) end
    CreateThread(function()
        local untilMs = GetGameTimer() + 6000
        while not mine.over and GetGameTimer() < untilMs do
            local id = mine.pourScene and NetworkGetLocalSceneFromNetworkId(mine.pourScene)
            local phase = id and id ~= -1 and GetSynchronizedScenePhase(id) or PC.phase(ped, A.pour)
            if not phase or phase > 0.97 then break end
            Wait(50)
        end
        if mine.pourScene then
            NetworkStopSynchronisedScene(mine.pourScene)
            mine.pourScene = nil
        end
        if mine.over then return end
        if (C.pour or {}).mouth then PC.anim(A.idle, true) end
        if mine.carry then PC.anim(A.hold, true) end
    end)
end

function game.play(view, mine)
    local data = mine.game.data
    local h = PC.heading(view)
    local along = flat(Frame.turn(h, 1.0, 0.0))
    local home = PC.freeSpot(view, PC.stand(view, L.stand), along)
    if not home then return Core.NotifyL('practicals.spot_taken', 'error') end
    PC.walkTo(home, h)
    PC.anim(A.idle, true)
    if PC.shot then PC.shot(view, 'overview') end
    PC.open(mine, 'practicals.lab', { goal = data.goal, slots = data.slots, steps = data.steps, mistakes = data.mistakes, pour = data.pour, heat = data.heat,
        stir = data.stir, seconds = data.seconds })
    Wait(150)

    local over, busy, heatAt, stirAt, swept, lastAngle = false, false, nil, nil, 0.0, nil
    local done, mistakes, pours = 0, 0, 0
    local marks = marksFor(view, data, mine)
    local function refresh() marks = marksFor(view, data, mine) end
    local function poses() -- back to the bench's loops after a walk
        PC.anim(A.idle, true)
        if mine.carry or mine.rodIn then PC.anim(A.hold, true) end
    end

    -- A step along the bench to stand in front of a point (at most L.step from where the student came in).
    local function reach(target)
        local x = (target.x - home.x) * along.x + (target.y - home.y) * along.y
        local to = home + along * math.max(-L.step, math.min(L.step, x))
        if #(GetEntityCoords(cache.ped).xy - to.xy) < 0.12 then return end
        PC.walkTo(to, h)
        poses()
    end

    -- A clip that has to end before the next click (the pickup), then fn.
    local function clip(anim, fn)
        busy = true
        PC.anim(anim)
        SetTimeout(math.floor(PC.clipMs(anim) * 0.9), function()
            busy = false
            if not mine.over and fn then fn() end
        end)
    end

    -- What a pour, a heat or a stir step hands back.
    local function after(out)
        if out then
            if out.right then done = out.level or done else mistakes = mistakes + 1 end
            PC.state({ last = out, done = done, mistakes = mistakes, pours = pours })
        end
        SetTimeout(250, function() if not mine.over then refresh() end end)
    end

    local function pick(slot)
        reach(slotAt(view, slot))
        busy = true
        PC.send('pick', { slot = slot }, function(out)
            busy = false
            if not out then return end
            mine.carry = slot
            PC.state({ carry = slot, target = data.pour.targets[pours + 1] })
            refresh()
            clip(A.pickup, function() PC.anim(A.hold, true) end)
        end)
    end

    local function putBack()
        busy = true
        PC.send('putback', {}, function(out)
            busy = false
            if not out then return end
            mine.carry, over = nil, false
            PC.stopAnim(A.hold)
            PC.state({ carry = false, over = false })
            refresh()
            clip(A.pickup)
        end)
    end

    local function pourStart(t)
        reach(beakerAt(view))
        mine.pourAt = t
        PC.state({ pouring = true, target = data.pour.targets[pours + 1] })
        pourClip(view, mine)
        PC.send('pourStart', {}, function(out)
            if out or not mine.pourAt then return end
            mine.pourAt = nil
            pourOut(mine)
            PC.state({ pouring = false })
        end)
    end

    local function pourEnd(t)
        local ms = t - mine.pourAt
        mine.pourAt, pours = nil, pours + 1
        PC.state({ pouring = false })
        pourOut(mine)
        PC.send('pourEnd', { ms = ms }, after)
    end

    local function heatStart(t)
        reach(heaterAt(view))
        heatAt = t
        PC.anim(A.button)
        PC.state({ heating = true })
        PC.send('heatStart', {}, function(out)
            if not out or out.op ~= 'heatOn' then
                heatAt = nil
                PC.state({ heating = false })
                after(out)
            end
        end)
    end

    local function heatEnd(t)
        local ms = t - heatAt
        heatAt = nil
        PC.anim(A.button)
        PC.state({ heating = false })
        PC.send('heatEnd', { ms = ms }, after)
    end

    -- The rod into the beaker, the hand over it (section 5.4).
    local function takeRod()
        reach(beakerAt(view))
        busy = true
        PC.send('rod', {}, function(out)
            busy = false
            if not out then return end
            mine.rodIn = true
            PC.state({ rod = true })
            refresh()
            clip(A.pickup, function() PC.anim(A.hold, true) end)
        end)
    end

    local function rodBack()
        busy = true
        PC.send('rodBack', {}, function(out)
            busy = false
            if not out then return end
            mine.rodIn = false
            PC.stopAnim(A.hold)
            PC.state({ rod = false })
            refresh()
            clip(A.pickup)
        end)
    end

    -- The pointer's angle round the beaker on screen: the turns drawn so far; the player's own rod follows it.
    local function stirMove(e)
        local c = PC.screen(beakerTop(view))
        if not c or not e.x then return end
        local angle = math.atan(e.y - c.y, (e.x - c.x) * GetAspectRatio(false))
        if lastAngle then swept = swept + Frame.swept(lastAngle, angle) end
        lastAngle, view.stirAngle = angle, -angle
        local turns = math.floor(math.abs(swept) / (2 * math.pi))
        if turns ~= mine.turns then
            mine.turns = turns
            PC.sound('stir', beakerTop(view))
            PC.state({ turns = turns })
        end
    end

    local function stirStart(e)
        stirAt, swept, lastAngle, mine.turns = e.at, 0.0, nil, 0
        PC.state({ stirring = true, turns = 0 })
        stirMove(e)
        PC.send('stirStart', {}, function(out)
            if out and out.op == 'stirOn' then return end
            stirAt, mine.rodIn = nil, false
            PC.stopAnim(A.hold)
            PC.state({ stirring = false, rod = false })
            after(out)
        end)
    end

    local function stirEnd(t)
        local ms = t - stirAt
        stirAt, mine.rodIn = nil, false
        PC.stopAnim(A.hold)
        PC.state({ stirring = false, rod = false })
        PC.send('stirEnd', { ms = ms, turns = math.floor(math.abs(swept) / (2 * math.pi)) }, after)
        clip(A.pickup)
    end

    while not PC.stopped(mine) do
        for _, e in ipairs(PC.events()) do
            if e.type == 'quit' then PC.leave(mine)
            elseif e.type == 'move' then
                if stirAt then stirMove(e)
                elseif mine.carry and not mine.pourAt then
                    local m = PC.markAt(marks, e.x, e.y)
                    local near = m ~= nil and m.kind == 'beaker'
                    if near ~= over then
                        over = near
                        PC.state({ over = over })
                    end
                end
            elseif e.type == 'down' and e.button == 2 then
                if mine.carry and not mine.pourAt and not busy then putBack()
                elseif mine.rodIn and not stirAt and not busy then rodBack() end
            elseif e.type == 'down' and not busy and not mine.pourAt and not heatAt and not stirAt then
                local m = PC.markAt(marks, e.x, e.y)
                local kind = m and m.kind
                if mine.carry then
                    if kind == 'beaker' then pourStart(e.at)
                    elseif kind == 'slot' then putBack() end
                elseif mine.rodIn then
                    if kind == 'beaker' then stirStart(e) end
                elseif kind == 'bottle' then pick(tonumber(m.id:match('%d+')))
                elseif kind == 'heater' then heatStart(e.at)
                elseif kind == 'rod' then takeRod() end
            elseif e.type == 'up' and e.button ~= 2 then
                if mine.pourAt then pourEnd(e.at)
                elseif heatAt then heatEnd(e.at)
                elseif stirAt then stirEnd(e.at) end
            end
        end
        Wait(0)
    end
    if mine.pourScene then NetworkStopSynchronisedScene(mine.pourScene) end
end
