-- Setting a piece down: a see-through copy follows the aim, the ring under it is green where it may stand, red with the reason where not.
local defs = Config.Pieces
Place = { active = false }

local function aim(ignore)
    local cam, rot = GetGameplayCamCoord(), GetGameplayCamRot(2)
    local x, z = math.rad(rot.x), math.rad(rot.z)
    local dir = vec3(-math.sin(z) * math.abs(math.cos(x)), math.cos(z) * math.abs(math.cos(x)), math.sin(x))
    local to = cam + dir * 12.0
    local ray = StartExpensiveSynchronousShapeTestLosProbe(cam.x, cam.y, cam.z, to.x, to.y, to.z, 1 + 16, ignore, 4)
    local _, hit, at, normal = GetShapeTestResult(ray)
    return hit == 1, at, normal
end

local function wet(at)
    local found, height = GetWaterHeightNoWaves(at.x, at.y, at.z + 1.0)
    return found and height > at.z - 0.1
end

-- Ground materials a camp may stand on, as unsigned hashes (natives give them signed).
local ground = {}
for _, hash in pairs(Config.Ground) do ground[hash & 0xFFFFFFFF] = true end
local slope = math.cos(math.rad(Config.Camp.MaxSlope))

-- The map's material under a point (props are looked through, so a mug on a table checks the grass below).
local function material(at)
    local ray = StartExpensiveSynchronousShapeTestLosProbe(at.x, at.y, at.z + 0.5, at.x, at.y, at.z - 3.0, 1, 0, 7)
    local _, hit, _, _, hash = GetShapeTestResultIncludingMaterial(ray)
    return hit == 1 and hash & 0xFFFFFFFF or nil
end

-- Any road within RoadGap: the middle, then rings at half and full distance.
local function nearRoad(at)
    if IsPointOnRoad(at.x, at.y, at.z, 0) then return true end
    local gap = Config.Camp.RoadGap
    for _, r in ipairs({ gap * 0.5, gap }) do
        for i = 0, 7 do
            local a = i * math.pi / 4
            if IsPointOnRoad(at.x + math.cos(a) * r, at.y + math.sin(a) * r, at.z, 0) then return true end
        end
    end
    return false
end

-- The slow checks (material, roads) run again only when the spot moved.
local cache = { at = nil, problem = nil }
local function groundProblem(at)
    if cache.at and #(cache.at - at) < 0.5 then return cache.problem end
    local problem
    if GetInteriorAtCoords(at.x, at.y, at.z) ~= 0 then problem = 'indoors'
    elseif not ground[material(at) or 0] then problem = 'bad_ground'
    elseif nearRoad(at) then problem = 'near_road' end
    cache.at, cache.problem = at, problem
    return problem
end

-- Why the ground here is no place for a camp (also used when a held light is set down), or nil.
function Place.ground(at, normal)
    if IsPedInAnyVehicle(PlayerPedId(), false) then return 'in_vehicle' end
    if wet(at) then return 'water' end
    if normal and normal.z < slope then return 'slope' end
    if Camp.inZone(Config.Areas, at) then return 'no_camp_zone' end
    return groundProblem(at)
end

-- The camp rules the client can see (the server checks them again): nil or the problem, and the piece it would sit on.
function Place.check(def, at, normal, me, center)
    if #(at.xy - me.xy) > Config.Reach - 0.3 then return 'too_far' end
    local snap, blocker = Camp.room(Client.pieces, defs, def, at)
    if blocker then return 'crowded' end
    if center and #(vec2(center.x, center.y) - at.xy) > Config.Camp.Radius then return 'camp_far' end
    local problem = Place.ground(at, not snap and normal or nil)
        or Camp.allow(Client.pieces, defs, def, Client.me, at, Config.Camp, Config.Limits)
    return problem, snap
end

local function ring(at, radius, ok)
    local r, g = ok and 60 or 220, ok and 200 or 60
    DrawMarker(25, at.x, at.y, at.z + 0.03, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, radius * 2.0, radius * 2.0, 1.0, r, g, 70, 140, false, false, 2, false, nil, nil, false)
end

RegisterNetEvent('daddy_camp:place', function(key, center)
    if Place.active then return end
    local def = defs[key]
    local hash = Client.model(def, Camp.firstState(def))
    if not Client.load(hash) then return Client.notify('camp.no_model', 'error') end
    Place.active = true
    local ped = PlayerPedId()
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local ghost = CreateObjectNoOffset(hash, GetEntityCoords(ped), false, false, false)
    SetEntityAlpha(ghost, 170, false)
    SetEntityCollision(ghost, false, false)
    FreezeEntityPosition(ghost, true)
    SetModelAsNoLongerNeeded(hash)
    local heading, pos, ok, said = GetEntityHeading(ped) + 180.0, nil, false, false
    while true do
        for _, control in ipairs({ 14, 15, 24, 25, 38, 44, 140, 141, 142 }) do DisableControlAction(0, control, true) end
        local hit, at, normal = aim(ped)
        if IsDisabledControlPressed(0, 14) then heading = heading - 4.0 end
        if IsDisabledControlPressed(0, 15) then heading = heading + 4.0 end
        local snap, problem
        if hit then problem, snap = Place.check(def, at, normal, GetEntityCoords(ped), center) end
        ok = hit and not problem
        if said ~= (problem or '') then -- the help line, and below it why this spot is refused
            said = problem or ''
            lib.showTextUI(Client.t('camp.place_help') .. (problem and '  \n' .. Client.t('camp.' .. problem) or ''))
        end
        pos = snap and vec3(snap.x, snap.y, snap.z) or at
        if hit then
            SetEntityCoordsNoOffset(ghost, pos.x, pos.y, pos.z, false, false, false)
            SetEntityHeading(ghost, heading % 360.0)
            ring(pos, def.radius or 0.4, ok)
        end
        if IsDisabledControlJustPressed(0, 38) and ok then break end
        if IsDisabledControlJustPressed(0, 25) or IsControlJustPressed(0, 177) then pos = nil break end
        Wait(0)
    end
    lib.hideTextUI()
    DeleteEntity(ghost)
    Place.active = false
    if not pos then return end
    local long = def.kind == 'tent'
    if not Client.work(long and 'camp.work_pitch' or 'camp.work_place', long and 5000 or 1500) then return end
    lib.callback.await('daddy_camp:place', false, { x = pos.x, y = pos.y, z = pos.z, h = heading % 360.0 })
end)
