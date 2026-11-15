-- The dealerships in the world: a blip each, a visible marker at the open point, and E to open its showroom.
local near, desk, hinted
local nearbyMarkers = {}

local function accentRgb()
    local hex = (Config.Theme and Config.Theme.Accent or '#ff1f6d'):gsub('#', '')
    return tonumber(hex:sub(1, 2), 16) or 255, tonumber(hex:sub(3, 4), 16) or 31, tonumber(hex:sub(5, 6), 16) or 109
end

CreateThread(function()
    local markerDist = Config.Markers and Config.Markers.Distance or 25.0
    for _, d in pairs(Dealers.all) do
        if d.blip and d.open then
            local blip = AddBlipForCoord(d.open.x, d.open.y, d.open.z)
            SetBlipSprite(blip, d.blip.sprite or 523)
            SetBlipColour(blip, d.blip.colour or 0)
            SetBlipScale(blip, d.blip.scale or 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(d.label)
            EndTextCommandSetBlipName(blip)
        end
        if d.manage then
            lib.points.new({
                coords = d.manage,
                distance = 2.0,
                onEnter = function() desk = d end,
                onExit = function()
                    if desk == d then desk = nil end
                end,
            })
            if not Config.Markers or Config.Markers.Show ~= false then
                lib.points.new({
                    coords = d.manage,
                    distance = markerDist,
                    onEnter = function() nearbyMarkers[d.id .. ':desk'] = d.manage end,
                    onExit = function() nearbyMarkers[d.id .. ':desk'] = nil end,
                })
            end
        end
        if d.open then
            lib.points.new({
                coords = d.open,
                distance = d.size,
                onEnter = function() near = d end,
                onExit = function()
                    if near == d then near = nil end
                end,
            })
            if not Config.Markers or Config.Markers.Show ~= false then
                lib.points.new({
                    coords = d.open,
                    distance = markerDist,
                    onEnter = function() nearbyMarkers[d.id] = d.open end,
                    onExit = function() nearbyMarkers[d.id] = nil end,
                })
            end
        end
    end
end)

-- The server checks the place and sends the catalogue; the hall opens with it, on a car when focus names one. False
-- when it did not open.
Showroom = { busy = false }

-- The server's answer to an open, or nil when it does not come within 8 s.
local function ask(id, mode)
    local p, settled = promise.new(), false
    local function settle(res)
        if settled then return end
        settled = true
        p:resolve(res)
    end
    lib.callback('daddy_dealerships:open', false, settle, id, mode)
    SetTimeout(8000, settle)
    return Citizen.Await(p)
end

function Showroom.open(id, focus, mode)
    if Showroom.busy or Hall.active or Hall.closing or (Panel and Panel.active) or not Page.await(5000) then return false end
    Showroom.busy = true
    local asked, res = pcall(ask, id, mode)
    if not asked then res = nil end
    local ok = false
    if res and res.ok then
        ok = Hall.open(res.dealer, res.vehicles, res.money, focus) == true
    else
        Page.notice('msg.' .. (res and res.error or 'open_failed'), 'error')
    end
    Showroom.busy = false
    return ok
end

-- The hint and world marker show while near a dealership on foot, and not while its showroom is open.
CreateThread(function()
    local mr, mg, mb = accentRgb()
    while true do
        local free = not Showroom.busy and not Hall.active and not Hall.closing and not Panel.active and not IsPedInAnyVehicle(PlayerPedId(), false)
        local here = free and near or nil
        local staff = free and not here and desk and desk.job and Bridge.fw.job() == desk.job and desk or nil
        local target = here or staff
        if target ~= hinted then
            hinted = target
            Showroom.at = target
            Bridge.hint(staff and { label = staff.label, verb = 'ui.manage' } or here)
        end
        local hasMarkers = false
        if free and (not Config.Markers or Config.Markers.Show ~= false) then
            -- the showroom's open point and the management desk
            for key, c in pairs(nearbyMarkers) do
                local d = Dealers.get(key:match('^[^:]+'))
                if d and d.enabled ~= false then
                    hasMarkers = true
                    -- two arrows, one over the other, pointing down (the smaller on top)
                    DrawMarker(2, c.x, c.y, c.z + 0.52, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.26, 0.26, 0.26, mr, mg, mb, 200, true, false, 2, true, nil, nil, false)
                    DrawMarker(2, c.x, c.y, c.z + 0.26, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.35, 0.35, 0.35, mr, mg, mb, 235, true, false, 2, true, nil, nil, false)
                end
            end
        end
        if target then
            if IsControlJustPressed(0, 38) then
                -- its own thread: a slow server never stalls this loop
                if here then CreateThread(function() Showroom.open(here.id) end) else Manage.open(staff.id) end
            end
            Wait(0)
        elseif hasMarkers then
            Wait(0)
        else
            Wait((near or desk) and 250 or 750)
        end
    end
end)
