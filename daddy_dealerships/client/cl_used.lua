-- Used cars on the client: what a car sold back is like (read at the sell point) and putting that back on a car (in
-- the hall, and on the bought car at the door). Dents are kept as daddy_garages keeps them, so the two agree.
Used = {}

-- Its props, and its dents: the deformation sampled on a grid over the model's box, the deepest 80 spots kept.
function Used.read(veh)
    local min, max = GetModelDimensions(GetEntityModel(veh))
    local function cut(n, k) return math.floor(n * k + 0.5) / k end
    local dents = {}
    local span = math.max(max.x - min.x, max.y - min.y, max.z - min.z)
    local step = math.max(0.4, span / 10.0)
    for x = min.x, max.x, step do
        for y = min.y, max.y, step do
            for z = min.z, max.z, step do
                local depth = #GetVehicleDeformationAtPos(veh, x, y, z)
                if depth > 0.03 then dents[#dents + 1] = { cut(x, 100), cut(y, 100), cut(z, 100), cut(depth, 1000) } end
            end
        end
    end
    table.sort(dents, function(a, b) return a[4] > b[4] end)
    for i = #dents, 81, -1 do dents[i] = nil end
    return { props = lib.getVehicleProperties(veh), dents = dents }
end

-- Puts a used car's state on a car: its props, its dents (the same spots dented a little at a time until each is about
-- as deep again), then its health and the windows that were whole. It waits between passes: call it in a thread.
function Used.apply(veh, car)
    if not DoesEntityExist(veh) then return end
    if type(car.props) == 'table' then lib.setVehicleProperties(veh, car.props) end
    local dents = type(car.dents) == 'table' and car.dents or {}
    for _ = 1, 4 do
        local short = false
        for _, p in ipairs(dents) do
            local now = #GetVehicleDeformationAtPos(veh, p[1], p[2], p[3])
            if now < p[4] * 0.8 then
                short = true
                SetVehicleDamage(veh, p[1], p[2], p[3], math.min(800.0, (p[4] - now) * 1200.0 + 40.0), 0.45, true)
            end
        end
        if not short then break end
        Wait(0)
        if not DoesEntityExist(veh) then return end
    end
    SetVehicleEngineHealth(veh, (tonumber(car.engine) or 1000) + 0.0)
    SetVehicleBodyHealth(veh, (tonumber(car.body) or 1000) + 0.0)
    if #dents > 0 then
        local broken = type(car.props) == 'table' and car.props.windows or {}
        for i = 0, 7 do
            if not Core.contains(broken, i) then FixVehicleWindow(veh, i) end
        end
    end
end
