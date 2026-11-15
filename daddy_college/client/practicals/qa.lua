-- Debug only (Config.Debug): what the QA resource (daddy-suite tools/practicals-qa, /pqa) asks the stations here,
-- through local events because the checks wait for the game: TriggerEvent('daddy_college:practicals:qa', id, what,
-- ...) and the answer comes back as 'daddy_college:practicals:qa:answer' (id, result). Nothing is networked.
local PC = Core.PracticalClient
if not PC or Config.Debug ~= true then return end

local cfg = PC.cfg
local QA = {}
local ASPECTS = { { '16:9', 16 / 9 }, { '21:9', 21 / 9 }, { '16:10', 16 / 10 }, { '4:3', 4 / 3 } }

-- The nearest station with a frame here (of a kind, when given).
local function nearest(kind)
    local here, best, bestD = GetEntityCoords(cache.ped), nil, nil
    for _, view in pairs(PC.views) do
        if view.frame and (not kind or kind == '' or view.kind == kind) then
            local top = view.frame.top
            local d = #(here - vector3(top.x, top.y, top.z))
            if not bestD or d < bestD then best, bestD = view, d end
        end
    end
    return best
end

-- The stations near, and the shots of the nearest one's kind.
function QA.views()
    local out = {}
    for uid, view in pairs(PC.views) do
        out[#out + 1] = { uid = uid, kind = view.kind, built = view.built == true, state = view.scene and view.scene.state or '?', frame = view.frame ~= nil }
    end
    return out
end

function QA.shots(kind)
    local view = nearest(kind)
    if not view then return { error = 'no station near' } end
    local names = {}
    for name in pairs((cfg.Kinds[view.kind] or {}).Shots or {}) do names[#names + 1] = name end
    table.sort(names)
    return { kind = view.kind, uid = view.uid, shots = names }
end

-- One shot of the nearest station solved and played (back once the camera is there): how it was found, its distance,
-- whether a head is in the way, and whether the points sit in the free part at four screen shapes.
function QA.shot(kind, name)
    local view = nearest(kind)
    if not view then return { error = 'no station near' } end
    local pose = PC.solve(view, name)
    if not pose then return { shot = name, ok = false, error = 'no shot' } end
    local zone = { edge = cfg.Camera.Edge, panels = PC.panels or (cfg.Camera.Panels or {})[view.kind] or {} }
    local row = { station = view.uid, kind = view.kind, shot = name, how = pose.how, fov = pose.fov, framed = pose.framed,
        head = pose.head == true, distance = #(pose.cam - pose.look), aspects = {} }
    for _, a in ipairs(ASPECTS) do
        local all, inside = PracticalShots.framed(pose.keys, pose.cam, pose.look, pose.fov, a[2], zone)
        row.aspects[a[1]] = all and 'PASS' or ('%d/%d'):format(inside, #pose.keys)
    end
    row.ok = pose.how ~= 'fixed' and not row.head and row.aspects['16:9'] == 'PASS'
    PC.shot(view, name)
    Wait(cfg.Camera.MoveMs + 150)
    return row
end

function QA.off() PC.cameraOff() return { ok = true } end

-- Every effect the stations use, 2 m ahead for a moment: its handle must not be 0.
function QA.fx()
    local rows, probe = {}, { uid = 'qa', kind = 'lab_bench', objects = {}, fx = {} }
    local at = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 2.0, 0.2)
    for kind, def in pairs(cfg.Kinds) do
        for name, fx in pairs(def.Fx or {}) do
            PC.fx(probe, fx, at, name)
            local handle = probe.fx[name]
            rows[#rows + 1] = { kind = kind, name = name, asset = fx.asset, effect = fx.name, ok = handle ~= nil and handle ~= 0 }
            Wait(1200)
            PC.stopFx(probe, name)
        end
    end
    PC.releaseFx(probe)
    return rows
end

-- Every sound the stations play, 2 m ahead one after another (sounds cannot say they played: the tester listens).
function QA.sounds()
    local rows, at = {}, GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 2.0, 0.5)
    for name, s in pairs(cfg.Sounds or {}) do
        PC.sound(name, at)
        rows[#rows + 1] = { name = name, sound = s.name, set = s.set }
        Wait(1500)
    end
    return rows
end

-- The scene events this client got (since the last reset) and the largest one in bytes.
function QA.net(reset)
    if reset then PC.net.events, PC.net.bytes = 0, 0 end
    return { events = PC.net.events, bytes = PC.net.bytes }
end

-- After a game: nothing left over (props, effects, a camera, the game itself).
function QA.clean()
    local objects, effects = 0, 0
    for _, view in pairs(PC.views) do
        if not view.built then
            for name in pairs(view.objects) do if name ~= 'idle' then objects = objects + 1 end end
            for _ in pairs(view.fx) do effects = effects + 1 end
        end
    end
    local camera = GetRenderingCam() ~= -1
    return { objects = objects, effects = effects, camera = camera, playing = PC.playing ~= nil,
        ok = objects == 0 and effects == 0 and not camera and PC.playing == nil }
end

AddEventHandler('daddy_college:practicals:qa', function(id, what, ...)
    local fn, args = QA[what], { ... }
    CreateThread(function()
        local ok, result = false, 'unknown check ' .. tostring(what)
        if fn then ok, result = pcall(fn, table.unpack(args)) end
        TriggerEvent('daddy_college:practicals:qa:answer', id, ok and result or { error = tostring(result) })
    end)
end)
