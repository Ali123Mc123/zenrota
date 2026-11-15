-- The mod menu: camera, preview, buy or order.

Menu = {}

local open, info, vehicle, before = false, nil, nil, nil
local opening = false
local bought = false
local cam, view = nil, { heading = 135.0, pitch = 10.0, dist = 6.0, focus = vec3(0, 0, 0) }
local target = { heading = 135.0, pitch = 10.0, dist = 6.0, focus = vec3(0, 0, 0) }

function Menu.isOpen() return open or opening end

local ZONE = {
    modEngine = 'engine', modTransmission = 'engine', modTurbo = 'engine', modEngineBlock = 'engine', modAirFilter = 'engine', modStruts = 'engine',
    modBrakes = 'wheel', modSuspension = 'wheel', modFender = 'wheel', modRightFender = 'wheel', modArchCover = 'wheel', modHydrolic = 'wheel',
    modSpoilers = 'trunk', modTrunk = 'trunk', modFrontBumper = 'front', modGrille = 'front', modHorns = 'front', modVanityPlate = 'front',
    modRearBumper = 'rear', modTank = 'rear', modExhaust = 'exhaust', modHood = 'hood', modRoof = 'roof', modAerials = 'roof',
    modPlateHolder = 'plate', plateIndex = 'plate', modTrimA = 'interior', modOrnaments = 'interior', modDashboard = 'interior', modDial = 'interior',
    modDoorSpeaker = 'interior', modSeats = 'interior', modSteeringWheel = 'interior', modShifterLeavers = 'interior', modAPlate = 'interior',
    modSpeakers = 'interior', wheelColor = 'wheel', interiorColor = 'interior', dashboardColor = 'interior', modSideSkirt = 'side',
}
local CATEGORY_ZONE = { wheels = 'wheel', headlights = 'front', tyreSmoke = 'wheel', bulletproofTyres = 'wheel', stance = 'wheel' }

local function mid(lo, hi, f) return lo.z + (hi.z - lo.z) * f end
local AREAS = {
    body = { at = function(lo, hi) return vec3(0.0, 0.0, mid(lo, hi, 0.5)) end, out = vec3(-0.7, 0.7, 0), pitch = 12.0, dist = 1.05 },
    front = { bone = 'bumper_f', at = function(lo, hi) return vec3(0.0, hi.y, mid(lo, hi, 0.35)) end, out = vec3(0, 1, 0), pitch = 8.0, dist = 0.75,
        ray = function(lo, hi) local z = mid(lo, hi, 0.3) return vec3(0.0, hi.y + 1.0, z), vec3(0.0, 0.0, z) end },
    hood = { bone = 'bonnet', at = function(_, hi) return vec3(0.0, hi.y * 0.55, hi.z * 0.8) end, out = vec3(0, 0.6, 0.8), pitch = 28.0, dist = 0.7,
        ray = function(lo, hi, b) local y = b and (b.y + hi.y) / 2 or hi.y * 0.55 return vec3(0.0, y, hi.z + 1.0), vec3(0.0, y, lo.z) end },
    engine = { bone = 'engine', at = function(_, hi) return vec3(0.0, hi.y * 0.6, hi.z * 0.6) end, out = vec3(0, 0.6, 0.8), pitch = 40.0, dist = 0.6, door = 4 },
    wheel = { bone = 'wheel_lf', other = 'wheel_rf', at = function(lo, hi) return vec3(lo.x, hi.y * 0.62, lo.z + 0.35) end, out = vec3(-1, 0, 0), pitch = 4.0, dist = 0.5 },
    side = { bone = 'door_dside_f', other = 'door_pside_f', at = function(lo, hi) return vec3(lo.x, 0.0, mid(lo, hi, 0.45)) end, out = vec3(-1, 0, 0), pitch = 6.0, dist = 0.85,
        ray = function(lo, hi, b, sx) local y, z = b and b.y - 0.5 or 0.0, mid(lo, hi, 0.4) return vec3(sx * (lo.x - 1.0), y, z), vec3(0.0, y, z) end },
    roof = { at = function(_, hi) return vec3(0.0, 0.0, hi.z) end, out = vec3(0, 0, 1), pitch = 45.0, dist = 0.8,
        ray = function(lo, hi) return vec3(0.0, -0.2, hi.z + 1.0), vec3(0.0, -0.2, lo.z) end },
    interior = { bone = 'seat_dside_f', other = 'seat_pside_f', at = function(lo, hi) return vec3(lo.x * 0.4, 0.2, hi.z * 0.5) end, out = vec3(-1, 0, 0), pitch = 18.0, dist = 0.4 },
    rear = { bone = 'bumper_r', at = function(lo, hi) return vec3(0.0, lo.y, mid(lo, hi, 0.35)) end, out = vec3(0, -1, 0), pitch = 8.0, dist = 0.75,
        ray = function(lo, hi) local z = mid(lo, hi, 0.3) return vec3(0.0, lo.y - 1.0, z), vec3(0.0, 0.0, z) end },
    trunk = { bone = 'boot', at = function(lo, hi) return vec3(0.0, lo.y * 0.8, hi.z * 0.65) end, out = vec3(0, -0.7, 0.7), pitch = 22.0, dist = 0.75,
        ray = function(lo, hi, b) local y = b and (b.y + lo.y) / 2 or lo.y * 0.8 return vec3(0.0, y, hi.z + 1.0), vec3(0.0, y, lo.z) end },
    exhaust = { bone = 'exhaust', at = function(lo) return vec3(lo.x * 0.4, lo.y, lo.z + 0.25) end, out = vec3(0, -1, 0), pitch = 3.0, dist = 0.45 },
    plate = { bone = 'platelight', at = function(lo) return vec3(0.0, lo.y, lo.z + 0.4) end, out = vec3(0, -1, 0), pitch = 5.0, dist = 0.5,
        ray = function(lo, _, b) local z = b and b.z or lo.z + 0.4 return vec3(0.0, lo.y - 1.0, z), vec3(0.0, 0.0, z) end },
}
local POINTS = { 'body', 'front', 'hood', 'wheel', 'side', 'trunk', 'rear', 'exhaust' }

local function camRight()
    local h = view.heading % 360.0
    return h > 180.0
end

local function hit(from, to)
    local a, b = GetOffsetFromEntityInWorldCoords(vehicle, from.x, from.y, from.z), GetOffsetFromEntityInWorldCoords(vehicle, to.x, to.y, to.z)
    local _, did, at, _, entity = GetShapeTestResult(StartExpensiveSynchronousShapeTestLosProbe(a.x, a.y, a.z, b.x, b.y, b.z, 2, 0, 7))
    if (did == true or did == 1) and entity == vehicle then return GetOffsetFromEntityGivenWorldCoords(vehicle, at.x, at.y, at.z) end
end

local spots = {}

local function areaAt(zone)
    local a = AREAS[zone] or AREAS.body
    local lo, hi = GetModelDimensions(GetEntityModel(vehicle))
    local right = a.out.x ~= 0 and camRight()
    local out = right and vec3(-a.out.x, a.out.y, a.out.z) or a.out
    local key = zone .. (right and 'r' or 'l')
    if spots[key] then return spots[key], out, a, #(hi - lo) end
    local name = right and a.other or a.bone
    local bone = name and GetEntityBoneIndexByName(vehicle, name) or -1
    local b = bone ~= -1 and GetOffsetFromEntityGivenWorldCoords(vehicle, GetWorldPositionOfEntityBone(vehicle, bone)) or nil
    local at
    if a.ray then
        local from, to = a.ray(lo, hi, b, right and -1 or 1)
        at = hit(from, to)
    end
    if not at then
        at = b or a.at(lo, hi)
        if right and not b then at = vec3(-at.x, at.y, at.z) end
    end
    spots[key] = at
    return at, out, a, #(hi - lo)
end

local CAPS = { speed = 50.0, accel = 0.42, brake = 1.6, grip = 3.2 }

local function bar(value, cap)
    return math.floor(math.max(0.0, math.min(10.0, value / cap * 10.0)) * 10 + 0.5) / 10
end

local function stats()
    local p = Props.get(vehicle) or {}
    local level = function(v) return (tonumber(v) or -1) + 1 end
    local turbo = p.modTurbo == true or p.modTurbo == 1
    local model = GetEntityModel(vehicle)
    local speed = GetVehicleModelEstimatedMaxSpeed(model) * (1.0 + level(p.modEngine) * 0.012 + (turbo and 0.01 or 0.0))
    return {
        speed = bar(speed, CAPS.speed),
        accel = bar(GetVehicleModelAcceleration(model) * (1.0 + level(p.modEngine) * 0.035 + level(p.modTransmission) * 0.025 + (turbo and 0.05 or 0.0)), CAPS.accel),
        brake = bar(GetVehicleModelMaxBraking(model) * (1.0 + level(p.modBrakes) * 0.06), CAPS.brake),
        grip = bar(GetVehicleModelMaxTraction(model) * (1.0 + level(p.modSuspension) * 0.02), CAPS.grip),
        top = math.floor(speed * 3.6),
    }
end

local function modLabel(slot, index)
    if index < 0 then return Core.t('ui.stock') end
    local label = GetLabelText(GetModTextLabel(vehicle, slot, index))
    return label ~= 'NULL' and label or ('%s %d'):format(Core.t('ui.level'), index + 1)
end

local function numbers(lo, hi, stockAt)
    local out = {}
    for i = lo, hi do out[#out + 1] = { value = i, label = i == stockAt and Core.t('ui.stock') or tostring(i) } end
    return out
end

local SIDES = { 'left', 'right', 'front', 'back' }

local function partOf(category, key, spec, props)
    local current = props[key]
    local p = { key = key, label = Core.t('keys.' .. key), options = {}, group = spec.group or key, zone = ZONE[key] or CATEGORY_ZONE[category] or 'body' }
    p.flat = spec.kind ~= 'mod' or spec.flat == true
    if spec.kind == 'mod' then
        local count = GetNumVehicleMods(vehicle, spec.slot)
        if category == 'performance' then count = math.min(count, spec.max + 1) end
        if count <= 0 then return nil end
        p.kind = category == 'performance' and 'levels' or 'range'
        for i = -1, count - 1 do p.options[#p.options + 1] = { value = i, label = modLabel(spec.slot, i) } end
        p.current = tonumber(current) or -1
    elseif spec.kind == 'toggle' then
        p.kind = 'toggle'
        p.options = { { value = false, label = Core.t('ui.off') }, { value = true, label = Core.t('ui.on') } }
        p.current = current == true or current == 1
    elseif spec.kind == 'colour' then
        p.kind = 'colour'
        p.options = {}
        p.current = type(current) == 'number' and current or 0
    elseif spec.kind == 'paint' then
        p.kind = 'paint'
        local names = (Core.locale().ui or {}).paints or {}
        for i = 0, 5 do p.options[i + 1] = { value = i, label = names[i + 1] or tostring(i) } end
        p.current = tonumber(current) or 0
    elseif spec.kind == 'range' then
        p.kind = 'range'
        p.options = numbers(spec.lo, spec.hi, -1)
        p.current = tonumber(current) or spec.lo
        local names = (Core.locale().ui or {})[key == 'wheels' and 'wheel_types' or key == 'windowTint' and 'tints' or '']
        if names then
            for _, o in ipairs(p.options) do o.label = names[o.value + (key == 'windowTint' and 2 or 1)] or o.label end
        end
    elseif spec.kind == 'rgb' then
        p.kind = 'rgb'
        p.current = type(current) == 'table' and current or { 255, 255, 255 }
    elseif spec.kind == 'neon' then
        p.kind = 'neon'
        for i, side in ipairs(SIDES) do p.options[i] = { value = i - 1, label = Core.t('ui.' .. side) } end
        local on = type(current) == 'table' and current or {}
        p.current = { on[1] == true, on[2] == true, on[3] == true, on[4] == true }
    elseif spec.kind == 'extras' then
        p.kind = 'extra'
        p.current = {}
        for id = 0, 20 do
            if DoesExtraExist(vehicle, id) then
                p.options[#p.options + 1] = { value = id, label = Core.t('ui.extra', id) }
                p.current[tostring(id)] = IsVehicleExtraTurnedOn(vehicle, id)
            end
        end
        if #p.options == 0 then return nil end
    elseif spec.kind == 'stance' then
        if not IsThisModelACar(GetEntityModel(vehicle)) then return nil end
        p.kind = 'stance'
        p.current = Stance.of(vehicle)
    elseif spec.kind == 'livery' then
        local count = spec.roof and GetVehicleRoofLiveryCount(vehicle) or GetVehicleLiveryCount(vehicle)
        if count <= 0 then return nil end
        p.kind = 'range'
        for i = 0, count - 1 do
            local name = not spec.roof and GetLiveryName(vehicle, i)
            local text = name and GetLabelText(name)
            p.options[#p.options + 1] = { value = i, label = text and text ~= 'NULL' and text or ('%s %d'):format(p.label, i + 1) }
        end
        p.current = tonumber(current) or 0
    end
    return p
end

local function categories(props)
    local out = {}
    for _, category in ipairs(info.sells) do
        local keys = Catalog.keys[category]
        if keys then
            local list = {}
            for key, spec in pairs(keys) do
                local p = not Catalog.hidden(key) and partOf(category, key, spec, props)
                if p then
                    p.order = ('%03d%s'):format(spec.slot or 999, key)
                    list[#list + 1] = p
                end
            end
            table.sort(list, function(a, b) return a.order < b.order end)
            if #list > 0 then out[#out + 1] = { id = category, parts = list } end
        end
    end
    return out
end

local function snapshot()
    local props = Props.get(vehicle)
    for _, key in ipairs({ 'bodyHealth', 'engineHealth', 'tankHealth', 'fuelLevel', 'dirtLevel', 'oilLevel', 'windows', 'doors', 'tyres' }) do
        props[key] = nil
    end
    return props
end

local function camLoop()
    CreateThread(function()
        while open and cam do
            view.heading = view.heading + (target.heading - view.heading) * 0.12
            view.pitch = view.pitch + (target.pitch - view.pitch) * 0.12
            view.dist = view.dist + (target.dist - view.dist) * 0.12
            view.focus = view.focus + (target.focus - view.focus) * 0.12
            local centre = GetOffsetFromEntityInWorldCoords(vehicle, view.focus.x, view.focus.y, view.focus.z)
            local h = math.rad(GetEntityHeading(vehicle) + view.heading)
            local p = math.rad(view.pitch)
            SetCamCoord(cam, centre.x - math.sin(h) * math.cos(p) * view.dist, centre.y + math.cos(h) * math.cos(p) * view.dist, centre.z + math.sin(p) * view.dist)
            PointCamAtCoord(cam, centre.x, centre.y, centre.z)
            DisableAllControlActions(0)
            HideHudAndRadarThisFrame()
            Wait(0)
        end
    end)
end

local function aim(zone)
    local at, out, a, size = areaAt(zone)
    target.heading = (math.deg(math.atan(-out.x, out.y)) + 360.0) % 360.0
    target.pitch, target.dist, target.focus = a.pitch, math.max(2.2, size * a.dist), at
    if a.door then SetVehicleDoorOpen(vehicle, a.door, false, false) else SetVehicleDoorShut(vehicle, 4, false) end
end

local function pointLoop()
    CreateThread(function()
        while open and cam do
            local camAt = GetOffsetFromEntityGivenWorldCoords(vehicle, GetCamCoord(cam))
            local list = {}
            for _, zone in ipairs(POINTS) do
                local at, out = areaAt(zone)
                local world = GetOffsetFromEntityInWorldCoords(vehicle, at.x, at.y, at.z)
                local seen, x, y = GetScreenCoordFromWorldCoord(world.x, world.y, world.z)
                if seen then
                    local d = camAt - at
                    list[#list + 1] = { zone = zone, x = x, y = y, front = d.x * out.x + d.y * out.y + d.z * out.z > 0.0 }
                end
            end
            SendNUIMessage({ action = 'mech:points', points = list })
            Wait(50)
        end
    end)
end

local function finish(bought)
    if not open then return end
    open = false
    UiFocus(false)
    SendNUIMessage({ action = 'mech:close' })
    if DoesEntityExist(vehicle) then
        SetVehicleDoorShut(vehicle, 4, false)
        if not bought and before then Props.set(vehicle, before) end
        Stance.preview(vehicle, nil)
        FreezeEntityPosition(vehicle, false)
    end
    if cam then
        RenderScriptCams(false, true, 600, true, false)
        DestroyCam(cam, false)
        cam = nil
    end
    DisplayRadar(true)
    HideHud(false)
    lib.callback.await('daddy_mechanic:close', false)
end

local setup

function Menu.open(shopId)
    if open or opening or not cache.vehicle then return end
    opening = true
    local result, reason = lib.callback.await('daddy_mechanic:open', false, shopId)
    opening = false
    if not result then return Bridge.notify(nil, reason or Core.t('msg.not_here'), 'error') end
    info, vehicle, open, bought = result, cache.vehicle, true, false
    local ok, err = pcall(setup)
    if not ok then
        print(('^1[daddy_mechanic] menu: %s^0'):format(err))
        finish(false)
    end
end

setup = function()
    before = snapshot()
    FreezeEntityPosition(vehicle, true)
    DisplayRadar(false)
    Props.kit(vehicle)
    spots = {}

    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamFov(cam, 45.0)
    view.heading, view.pitch, view.dist, view.focus = 135.0, 10.0, 9.0, vec3(0, 0, 0)
    local cats = categories(Props.get(vehicle))
    aim('body')
    HideHud(true)
    RenderScriptCams(true, true, 800, true, false)
    camLoop()
    pointLoop()

    local repair = Core.has(info.sells, 'repair') and lib.callback.await('daddy_mechanic:repairPrice', false) or nil
    SendNUIMessage({ action = 'mech:open', data = {
        shop = { label = info.label, mode = info.mode, society = info.society, canFree = info.freeChoice == true, freeWhy = info.freeWhy },
        car = {
            name = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))), plate = GetVehicleNumberPlateText(vehicle),
            value = info.value, engine = math.floor(GetVehicleEngineHealth(vehicle) / 10), body = math.floor(GetVehicleBodyHealth(vehicle) / 10),
        },
        repair = repair, categories = cats, stats = stats(),
        stance = { height = Config.Stance.Height, camber = Config.Stance.Camber, track = Config.Stance.Track },
        pricing = {
            prices = info.prices, value = info.value, byValue = Config.PriceByValue, min = Config.MinPrice,
            free = not info.freeChoice and info.free or nil, freeList = info.free,
        },
    } })
    UiFocus(true)
end

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() or not open then return end
    UiFocus(false)
    if DoesEntityExist(vehicle) then
        if not bought and before then Props.set(vehicle, before) end
        FreezeEntityPosition(vehicle, false)
    end
    if cam then
        RenderScriptCams(false, false, 0, true, false)
        DestroyCam(cam, false)
    end
    DisplayRadar(true)
    HideHud(false)
end)

RegisterNetEvent('daddy_mechanic:closed', function() finish(false) end)

RegisterNUICallback('boot', function(_, cb)
    SendNUIMessage({ action = 'mech:boot', locale = Core.locale(), lang = Config.Locale, theme = { accent = Config.Accent }, currency = Config.Currency })
    cb({ ok = true })
end)

RegisterNUICallback('preview', function(data, cb)
    if not open or type(data.key) ~= 'string' or not Catalog.categoryOf[data.key] then return cb({}) end
    if data.key == 'stance' then
        Stance.preview(vehicle, data.value ~= false and Catalog.stanceOf(data.value) or false)
        return cb({ stats = stats() })
    end
    Props.set(vehicle, { [data.key] = data.value })
    if data.key == 'modHorns' then StartVehicleHorn(vehicle, 1500, `HELDDOWN`, false) end
    if data.key == 'wheels' then SendNUIMessage({ action = 'mech:categories', categories = categories(Props.get(vehicle)) }) end
    Wait(0)
    spots = {}
    cb({ stats = stats() })
end)

RegisterNUICallback('horn', function(_, cb)
    cb({})
    if open then StartVehicleHorn(vehicle, 1500, `HELDDOWN`, false) end
end)

RegisterNUICallback('quote', function(data, cb)
    local total, lines = lib.callback.await('daddy_mechanic:quote', false, data.cart, data.account)
    cb(total and { total = total, lines = lines } or {})
end)

RegisterNUICallback('buy', function(data, cb)
    local ok, result, kind = lib.callback.await('daddy_mechanic:buy', false, data.cart, data.account, data.repair == true)
    if not ok then return cb({ ok = false, error = result or Core.t('msg.failed') }) end
    cb({ ok = true, kind = kind })
    Bridge.notify(nil, Core.t(kind == 'order' and 'msg.ordered' or 'msg.bought', result), 'success')
    bought = kind ~= 'order'
end)

RegisterNUICallback('done', function(_, cb)
    cb({})
    finish(bought)
end)

RegisterNUICallback('repair', function(data, cb)
    local ok, result = lib.callback.await('daddy_mechanic:repair', false, data.account)
    if ok then Bridge.notify(nil, Core.t('msg.repaired', result), 'success') end
    cb({ ok = ok == true, error = not ok and (result or Core.t('msg.failed')) or nil })
end)

RegisterNUICallback('compare', function(data, cb)
    cb({})
    if not open or not before then return end
    Props.set(vehicle, before)
    Stance.preview(vehicle, nil)
    if data.on then return end
    local cart = {}
    for key, value in pairs(type(data.cart) == 'table' and data.cart or {}) do
        if key == 'stance' then
            Stance.preview(vehicle, value ~= false and Catalog.stanceOf(value) or false)
        elseif Catalog.categoryOf[key] then
            cart[key] = value
        end
    end
    Props.set(vehicle, cart)
end)

local SOUNDS = {
    step = { 'NAV_LEFT_RIGHT', 'HUD_FRONTEND_DEFAULT_SOUNDSET' }, row = { 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET' },
    section = { 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET' }, buy = { 'PURCHASE', 'HUD_LIQUOR_STORE_SOUNDSET' },
    error = { 'ERROR', 'HUD_FRONTEND_DEFAULT_SOUNDSET' },
}

RegisterNUICallback('sound', function(data, cb)
    cb({})
    local s = Config.Sounds and SOUNDS[data.name]
    if s then PlaySoundFrontend(-1, s[1], s[2], true) end
end)

RegisterNUICallback('camera', function(data, cb)
    if open and type(data.zone) == 'string' then aim(data.zone) end
    cb({})
end)

RegisterNUICallback('orbit', function(data, cb)
    target.heading = target.heading - (tonumber(data.dx) or 0) * 0.35
    target.pitch = math.max(-5.0, math.min(45.0, target.pitch + (tonumber(data.dy) or 0) * 0.2))
    cb({})
end)

RegisterNUICallback('close', function(_, cb)
    cb({})
    finish(bought)
end)

exports('openMenu', function(shopId) Menu.open(shopId) end)
exports('closeMenu', function() finish(false) end)
exports('isMenuOpen', function() return open end)
