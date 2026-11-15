-- The tour: /<command> puts the admin at the next stop (or stop n); while it runs, every moved point near the admin
-- shows a marker (and its name up close), so a point that floats or stands in a wall is seen at once.
local points, index, active

local function load()
    if points then return points end
    points = json.decode(LoadResourceFile(cache.resource, 'data/points.json') or '[]') or {}
    for _, p in ipairs(points) do p.v = vec3(p.x, p.y, p.z); p.c = Config.Colors[p.k] or Config.Colors.other end
    return points
end

local function text3d(v, label)
    SetDrawOrigin(v.x, v.y, v.z + 0.25, 0)
    SetTextScale(0.0, 0.28); SetTextFont(4); SetTextCentre(true); SetTextOutline()
    BeginTextCommandDisplayText('STRING'); AddTextComponentSubstringPlayerName(label); EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

local function draw()
    CreateThread(function()
        while active do
            local me = GetEntityCoords(cache.ped)
            for _, p in ipairs(points) do
                local d = #(me - p.v)
                if d < Config.MarkerDistance then
                    DrawMarker(28, p.v.x, p.v.y, p.v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.14, 0.14, 0.14, p.c[1], p.c[2], p.c[3], 210, false, false, 2, false, nil, nil, false)
                    if d < Config.LabelDistance then text3d(p.v, p.l) end
                end
            end
            Wait(0)
        end
    end)
end

-- A long jump: fade, hold the ped until the floor (and the interior) under the stop has loaded.
local function land(c)
    local ped = cache.ped
    DoScreenFadeOut(300)
    while not IsScreenFadedOut() do Wait(0) end
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(ped, c.x, c.y, c.z, false, false, false, false)
    SetEntityHeading(ped, c.w)
    FreezeEntityPosition(ped, true)
    local interior = GetInteriorAtCoords(c.x, c.y, c.z)
    if interior ~= 0 then PinInteriorInMemory(interior) end
    local deadline = GetGameTimer() + Config.LoadMs
    while GetGameTimer() < deadline and (not HasCollisionLoadedAroundEntity(ped) or (interior ~= 0 and not IsInteriorReady(interior))) do
        RequestCollisionAtCoord(c.x, c.y, c.z)
        Wait(50)
    end
    FreezeEntityPosition(ped, false)
    DoScreenFadeIn(300)
end

RegisterCommand(Config.Command, function(_, args)
    if not lib.callback.await('daddy_campustour:allowed', false) then
        return lib.notify({ type = 'error', description = Config.Text.denied })
    end
    if args[1] == Config.Text.closeWord then
        active = false
        return lib.notify({ description = Config.Text.closed })
    end
    local n = tonumber(args[1]) or (index or 0) % #Config.Stops + 1
    local stop = Config.Stops[n]
    if not stop then return lib.notify({ type = 'error', description = Config.Text.usage }) end
    index = n
    load()
    if not active then active = true; draw() end
    land(stop.coords)
    lib.notify({ title = Config.Text.stop:format(n, #Config.Stops, stop.label), description = stop.check, duration = Config.NoticeMs })
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then active = false end
end)
