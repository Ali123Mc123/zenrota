-- daddy_uiprobe: the page boots once per session; a second boot means the UI process crashed and came back.
-- Then (and now and then as a healthy sample) it sends what was around the player. Reads only, changes nothing.
local joined = GetGameTimer()
local boots, beats, fps = 0, {}, {}

local function set(list)
    local out = {}
    for _, name in ipairs(list) do out[joaat(name)] = true end
    return out
end
local BOOMBOX, SCREENS = set(Config.Boombox), set(Config.Screens)

local function round(v, d)
    local m = 10 ^ (d or 0)
    return math.floor((tonumber(v) or 0) * m + 0.5) / m
end

local function mb(bytes)
    return bytes and round(bytes / 1048576, 1) or nil
end

-- Players, cars with a player driving (CarPlay music), boomboxes and screens near the player.
local function around(ped, coords, own)
    local near, crowd, cars, driven, boombox, screens = 0, 0, 0, 0, 0, 0
    for _, id in ipairs(GetActivePlayers()) do
        local other = GetPlayerPed(id)
        if other ~= ped then
            local d = #(GetEntityCoords(other) - coords)
            if d < Config.Near.Players then near = near + 1 end
            if d < Config.Near.Crowd then crowd = crowd + 1 end
        end
    end
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        local d = #(GetEntityCoords(veh) - coords)
        if d < Config.Near.Vehicles then cars = cars + 1 end
        local driver = d < Config.Near.Music and veh ~= own and GetPedInVehicleSeat(veh, -1) or 0
        if driver ~= 0 and IsPedAPlayer(driver) then driven = driven + 1 end
    end
    for _, obj in ipairs(GetGamePool('CObject')) do
        local model = GetEntityModel(obj)
        if BOOMBOX[model] or SCREENS[model] then
            local d = #(GetEntityCoords(obj) - coords)
            if BOOMBOX[model] and d < Config.Near.Music then boombox = boombox + 1 end
            if SCREENS[model] and d < Config.Near.Screens then screens = screens + 1 end
        end
    end
    return { players = near, crowd = crowd, cars = cars, driven = driven, boombox = boombox, screens = screens }
end

local function fpsStats()
    if #fps == 0 then return nil, nil end
    local sum, low = 0, math.huge
    for _, v in ipairs(fps) do sum, low = sum + v, math.min(low, v) end
    return round(sum / #fps), round(low)
end

local function snapshot(kind)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local veh = GetVehiclePedIsIn(ped, false)
    local avg, low = fpsStats()
    local beat = beats[#beats] or {}
    local heap = {}
    for i, b in ipairs(beats) do heap[i] = b.used end
    return {
        kind = kind,
        boots = boots,
        up = round((GetGameTimer() - joined) / 60000, 1),
        pos = { round(coords.x), round(coords.y), round(coords.z) },
        zone = GetNameOfZone(coords.x, coords.y, coords.z),
        street = GetStreetNameFromHashKey((GetStreetNameAtCoord(coords.x, coords.y, coords.z))),
        inside = GetInteriorFromEntity(ped) ~= 0,
        car = veh ~= 0 and GetDisplayNameFromVehicleModel(GetEntityModel(veh)) or nil,
        speed = veh ~= 0 and round(GetEntitySpeed(veh) * 3.6) or nil,
        near = around(ped, coords, veh),
        fps = avg, fpsLow = low,
        heap = heap, heapTotal = beat.total, heapLimit = beat.limit,
        lag = beat.lag, frames = beat.frames,
        gpu = GetConvarInt('nui_useInProcessGpu', 0) ~= 0,
        build = GetGameBuildNumber(),
    }
end

local function send(kind)
    TriggerServerEvent('daddy_uiprobe:report', kind, snapshot(kind))
end

RegisterNUICallback('boot', function(_, cb)
    cb('ok')
    boots = boots + 1
    if boots > 1 then send('crash') end
end)

-- The last 8 heartbeats (2 minutes) go with every report.
RegisterNUICallback('beat', function(data, cb)
    cb('ok')
    if type(data) ~= 'table' then return end
    beats[#beats + 1] = { used = mb(data.used), total = mb(data.total), limit = mb(data.limit), lag = tonumber(data.lag), frames = tonumber(data.frames) }
    if #beats > 8 then table.remove(beats, 1) end
end)

-- Frame rate over the last 15 seconds, one reading a second.
CreateThread(function()
    while true do
        Wait(1000)
        local frame = GetFrameTime()
        fps[#fps + 1] = frame > 0 and 1.0 / frame or 0
        if #fps > 15 then table.remove(fps, 1) end
    end
end)

-- Healthy samples at random moments, to compare the crashes with.
CreateThread(function()
    Wait(math.random(60, Config.Sample.Every) * 1000)
    while true do
        if math.random() < Config.Sample.Chance then send('sample') end
        Wait(Config.Sample.Every * 1000)
    end
end)

-- /merdiventest: el merdiveninde Shift (INPUT_SPRINT 21) bir script tarafından kapatılıyor mu, ekranda gösterir.
local ladderTest = false
RegisterCommand('merdiventest', function()
    ladderTest = not ladderTest
    if not ladderTest then return end
    CreateThread(function()
        while ladderTest do
            local ped = PlayerPedId()
            local onLadder = GetIsTaskActive(ped, 1) or IsPedClimbing(ped)
            local lines = {
                ('Merdivende: %s'):format(onLadder and 'EVET' or 'hayir'),
                ('Shift basili (gercek tus): %s'):format(IsDisabledControlPressed(0, 21) and 'EVET' or 'hayir'),
                ('Shift oyuna ulasiyor: %s'):format(IsControlPressed(0, 21) and 'EVET' or 'hayir'),
                ('Shift kontrolu acik: %s'):format(IsControlEnabled(0, 21) and 'EVET' or 'HAYIR (bir script kapatiyor)'),
            }
            for i, txt in ipairs(lines) do
                SetTextFont(4); SetTextScale(0.0, 0.45); SetTextOutline()
                SetTextColour(255, 255, 255, 255)
                BeginTextCommandDisplayText('STRING'); AddTextComponentSubstringPlayerName(txt)
                EndTextCommandDisplayText(0.02, 0.30 + (i - 1) * 0.03)
            end
            Wait(0)
        end
    end)
end, false)
