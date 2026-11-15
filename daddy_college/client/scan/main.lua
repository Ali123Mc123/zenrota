-- Scanner gates on the client: the gates at their spots, the walk through a gate noticed only near
-- one, and the green or red light and the beep everyone near sees and hears. The server decides every scan.
if not Core.ModuleEnabled('scan') or not Core.ModuleEnabled('security') or not Config.Scan then return end

local cfg = Config.Scan
local box = cfg.Gate.Box
local gates, walks = {}, {} -- uid -> spot; uid -> { inside, from, along }

function Core.ScanModel(names)
    for _, name in ipairs(names or {}) do
        if IsModelInCdimage(joaat(name)) then return name end
    end
end

-- A point's prop: the spot's own model, else the first of the config the game has; a plain point without one.
function Core.ScanAnchor(uid, spot, models)
    local model = (spot.model or '') ~= '' and spot.model or Core.ScanModel(models)
    return { uid = uid, label = spot.label, coords = spot.coords, revision = spot.revision, presentation = model and 'prop' or 'point',
        model = model, streamDistance = spot.streamDistance }
end

local function sync()
    local defs, lamp = {}, cfg.Gate.Lamp
    gates = {}
    for _, spot in ipairs(Core.World.entities({ kind = 'scan_gate' })) do
        gates[spot.uid] = spot
        defs[#defs + 1] = Core.ScanAnchor('scan:gate:' .. spot.uid, spot, cfg.Gate.Models)
        if lamp and (lamp.Model or '') ~= '' then
            local c = spot.coords
            defs[#defs + 1] = { uid = 'scan:lamp:' .. spot.uid, coords = { x = c.x, y = c.y, z = c.z + lamp.Height, w = c.w },
                revision = spot.revision, presentation = 'prop', model = lamp.Model }
        end
    end
    -- The island checkpoint's lockers: every player's own stash by the gate.
    local cp = cfg.Checkpoint
    for _, spot in ipairs(cp and cp.Enabled and Core.World.entities({ kind = 'scan_locker' }) or {}) do
        local def = Core.ScanAnchor('scan:locker:' .. spot.uid, spot, cp.Locker.Models)
        def.distance = 2.0
        def.options = { { name = 'scan_locker', label = DL.locale.t('scan.locker_open'), icon = 'fa-solid fa-box-archive', distance = 2.0,
            onSelect = function()
                CreateThread(function()
                    local result = Core.NormalizeResult(lib.callback.await('daddy_college:scan:locker', false, {}))
                    if not result.ok then return Core.HandleResult(result, 'scan') end
                    exports.ox_inventory:openInventory('stash', result.id)
                end)
            end } }
        defs[#defs + 1] = def
    end
    Core.World.anchors.sync('scan', defs)
end

Core.World.subscribe(sync)

-- Walking through ------------------------------------------------------------------------------------

local function sign(value) return value >= 0 and 1 or -1 end

-- Inside the gate's box, from across / along / height in its own axes.
local function inside(across, along, up)
    return math.abs(across) <= box.width * 0.5 and math.abs(along) <= box.depth * 0.5 and up > -0.6 and up < box.height
end

-- One look at a gate: entering its box keeps the side the player came from; leaving on the other side is a walk through.
local function watch(spot, here)
    local c = spot.coords
    local across, along = ScanGeometry.toGate(c, here.x, here.y)
    local walk = walks[spot.uid] or {}
    walks[spot.uid] = walk
    local now = inside(across, along, here.z - c.z)
    -- Stand style: stepping into the frame starts the body scan; the server holds the player for it. Someone fast
    -- (a skateboard) may jump the frame between two looks: going from one side of it to the other counts too.
    if cfg.Gate.Style == 'stand' then
        local jumped = not now and not walk.inside and walk.along and sign(walk.along) ~= sign(along) and math.abs(across) <= box.width * 0.5 + 0.4
            and math.abs(walk.along - along) <= 12.0
        if (now and not walk.inside or jumped) and GetGameTimer() >= (walk.sent or 0) + 1000 then
            walk.sent = GetGameTimer()
            TriggerServerEvent('daddy_college:scan:stand', { gate = spot.uid })
        end
        walk.inside, walk.along = now, along
        return
    end
    if now and not walk.inside then
        walk.inside, walk.from = true, sign(walk.along or along)
    elseif not now and walk.inside then
        walk.inside = false
        if math.abs(across) <= box.width * 0.5 + 0.4 and sign(along) ~= walk.from then
            TriggerServerEvent('daddy_college:scan:crossed', { gate = spot.uid, way = walk.from < 0 and 'in' or 'out' })
        end
    end
    walk.along = along
end

-- Sleeps while every switched-on gate is far (gates stand at the campus edge, so this goes by distance, not by the
-- campus area), a second when one is within 100 m, looks ten times a second at a gate and every frame right at it.
CreateThread(function()
    while true do
        local here, near, closest, on = GetEntityCoords(cache.ped), false, math.huge, GlobalState['daddy_college:scanGates'] or {}
        for uid, spot in pairs(gates) do
            local c = spot.coords
            local d = #(here - vector3(c.x, c.y, c.z))
            if on[uid] and d < closest then closest = d end
            if on[uid] and d <= cfg.Gate.ListenDistance then
                near = true
                watch(spot, here)
            elseif walks[uid] then
                walks[uid] = nil
            end
        end
        Wait(closest <= 8.0 and 0 or near and 100 or closest <= 100.0 and 1000 or 3000)
    end
end)

-- Light and sound ------------------------------------------------------------------------------------

local COLORS = { clear = { 80, 220, 120 }, hit = { 235, 45, 45 } }

local function play(sound, c)
    if sound then PlaySoundFromCoord(-1, sound[1], c.x, c.y, c.z + 2.0, sound[2], false, math.floor(cfg.Gate.Alarm.Radius), false) end
end

-- Green for a moment and one beep; or red, blinking, with the alarm, for Alarm.Seconds.
local function flash(c, result)
    local color, hit = COLORS[result] or COLORS.clear, result == 'hit'
    local ends = GetGameTimer() + (hit and cfg.Gate.Alarm.Seconds * 1000 or 1200)
    local nextBeep = 0
    while GetGameTimer() < ends do
        local now = GetGameTimer()
        if not hit or (now // 250) % 2 == 0 then
            DrawLightWithRange(c.x, c.y, c.z + box.height, color[1], color[2], color[3], hit and 8.0 or 3.0, hit and 6.0 or 3.0)
        end
        if now >= nextBeep then
            play(hit and cfg.Gate.Sounds.alarm or cfg.Gate.Sounds.clear, c)
            nextBeep = hit and now + 500 or ends
        end
        Wait(0)
    end
end

-- The body scan (Gate.Style 'stand') --------------------------------------------------------------------

local function pedOf(serverId)
    local player = GetPlayerFromServerId(tonumber(serverId) or -1)
    local ped = player ~= -1 and GetPlayerPed(player) or 0
    return ped ~= 0 and DoesEntityExist(ped) and ped or nil
end

-- From the feet to the head of a ped, by its bones (the model's box when the pose hides them).
local function bodySpan(ped)
    local feet = math.min(GetPedBoneCoords(ped, 14201, 0.0, 0.0, -0.05).z, GetPedBoneCoords(ped, 52301, 0.0, 0.0, -0.05).z)
    local head = GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.15).z
    if head <= feet + 0.4 then
        local low, high = GetModelDimensions(GetEntityModel(ped))
        local z = GetEntityCoords(ped).z
        feet, head = z + low.z, z + high.z
    end
    return feet, head
end

-- What carries a ped: its vehicle, or the root of what it is attached to (a skateboard); never another player.
-- -> entity | 0
local function carrierOf(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= 0 then return vehicle end
    local root = ped
    for _ = 1, 4 do
        if not IsEntityAttached(root) then break end
        root = GetEntityAttachedTo(root)
    end
    return root ~= ped and root ~= 0 and not IsEntityAPed(root) and root or 0
end

-- Whether no one but this ped rides it.
local function alone(carrier, ped)
    if not IsEntityAVehicle(carrier) then return true end
    if GetVehicleNumberOfPassengers(carrier) > 0 then return false end
    return IsVehicleSeatFree(carrier, -1) or GetPedInVehicleSeat(carrier, -1) == ped
end

local mySweep = 0 -- bumped by a send-back: my running sweep ends at once

-- A ring of light runs from the feet to the head and back while the player stands still in the pose. On a
-- skateboard, bike or in a car the ride stops in the frame instead (no pose).
RegisterNetEvent('daddy_college:scan:sweep', function(data)
    if type(data) ~= 'table' then return end
    local s, ped = cfg.Gate.Stand, pedOf(data.scanned)
    if not ped then return end
    local mine = ped == cache.ped
    local carrier = carrierOf(ped)
    local held = mine and carrier ~= 0 and NetworkHasControlOfEntity(carrier) and carrier or nil
    local pose = carrier == 0 and s.Pose or nil
    if mine then mySweep = mySweep + 1 end
    local sweep = mySweep
    CreateThread(function()
        if pose and pcall(lib.requestAnimDict, pose.dict, 2000) then TaskPlayAnim(ped, pose.dict, pose.clip, 2.0, 2.0, -1, 1, 0.0, false, false, false) end
        if held then
            SetEntityVelocity(held, 0.0, 0.0, 0.0)
            FreezeEntityPosition(held, true)
        end
        if mine then FreezeEntityPosition(ped, true) end
        local started, ms = GetGameTimer(), tonumber(data.ms) or 1300
        local r = s.Ring
        local c = r.color
        if s.Sound then PlaySoundFromEntity(-1, s.Sound[1], ped, s.Sound[2], false, 0) end
        while GetGameTimer() - started < ms and (not mine or sweep == mySweep) do
            local t = GetGameTimer() - started
            local leg = (t % s.SweepMs) / s.SweepMs
            if (t // s.SweepMs) % 2 == 1 then leg = 1.0 - leg end
            local fade = math.min(1.0, t / 200.0, (ms - t) / 300.0)
            local feet, head = bodySpan(ped)
            local p = GetEntityCoords(ped)
            local z, d = feet + (head - feet) * leg, r.radius * 2.0
            local a = math.floor(c[4] * fade)
            DrawMarker(1, p.x, p.y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, d, d, r.thickness, c[1], c[2], c[3], a, false, false, 2, false, nil, nil, false)
            DrawMarker(25, p.x, p.y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, d, d, r.thickness * 0.35, c[1], c[2], c[3], math.floor(a * 0.7), false, false, 2, false, nil, nil, false)
            DrawLightWithRange(p.x, p.y, z, c[1], c[2], c[3], r.lightRange, r.lightIntensity * fade)
            if mine then
                for _, control in ipairs({ 21, 22, 24, 25, 30, 31, 32, 33, 34, 35 }) do DisableControlAction(0, control, true) end
            end
            Wait(0)
        end
        if pose then StopAnimTask(ped, pose.dict, pose.clip, 1.0) end
        if held and DoesEntityExist(held) then FreezeEntityPosition(held, false) end
        if mine then FreezeEntityPosition(ped, false) end
    end)
end)

-- Sent back from the island gate (server's call): off the skateboard, bike or car, to the send-back point; what
-- carried the player comes along and is put down beside them, if no one else is in it.
RegisterNetEvent('daddy_college:scan:sendback', function(at)
    if type(at) ~= 'table' or not at.x then return end
    mySweep = mySweep + 1
    local ped = cache.ped
    local carrier = carrierOf(ped)
    local bring = carrier ~= 0 and alone(carrier, ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= 0 then TaskLeaveVehicle(ped, vehicle, 16) end -- 16: out at once
    if IsEntityAttached(ped) then DetachEntity(ped, true, false) end
    FreezeEntityPosition(ped, false)
    ClearPedTasksImmediately(ped)
    RequestCollisionAtCoord(at.x, at.y, at.z)
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(ped, at.x, at.y, at.z, false, false, false, false)
    SetEntityHeading(ped, at.w or 0.0)
    if not bring or not DoesEntityExist(carrier) or not NetworkHasControlOfEntity(carrier) then return end
    local low, high = GetModelDimensions(GetEntityModel(carrier))
    local h = math.rad(at.w or 0.0)
    local gap = (tonumber(at.gap) or 2.5) + (high.x - low.x) * 0.5
    FreezeEntityPosition(carrier, false)
    SetEntityVelocity(carrier, 0.0, 0.0, 0.0)
    SetEntityCoords(carrier, at.x + math.cos(h) * gap, at.y + math.sin(h) * gap, at.z, false, false, false, false)
    SetEntityHeading(carrier, at.w or 0.0)
    if IsEntityAVehicle(carrier) then SetVehicleOnGroundProperly(carrier) end
end)

-- A hit after a body scan: a red light blinks on the person as well as on the gate.
local function redLight(ped)
    local ends, l = GetGameTimer() + cfg.Gate.Alarm.Seconds * 1000, cfg.Gate.Stand.HitLight
    while GetGameTimer() < ends and DoesEntityExist(ped) do
        if (GetGameTimer() // l.pulseMs) % 2 == 0 then
            local p = GetEntityCoords(ped)
            DrawLightWithRange(p.x, p.y, p.z + l.offsetZ, 255, 16, 16, l.range, l.intensity)
        end
        Wait(0)
    end
end

RegisterNetEvent('daddy_college:scan:result', function(data)
    local spot = type(data) == 'table' and Core.World.entity(data.point)
    if spot then CreateThread(function() flash(spot.coords, data.result) end) end
    local ped = type(data) == 'table' and data.result == 'hit' and data.scanned and cfg.Gate.Stand and pedOf(data.scanned)
    if ped then CreateThread(function() redLight(ped) end) end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then Core.World.anchors.clear('scan') end
end)
