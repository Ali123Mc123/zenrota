-- The showroom: the chosen car as a local copy on the garage's show spot and the camera round it (Director). The camera
-- moves only for a reason: in from the game camera as the garage opens, to a detail spot and back, out to the game
-- camera as the garage closes or a car drives out. Browsing keeps it still: a new car is made unseen (its model loaded
-- ahead with its neighbours') and takes the old one's place in one frame. Left alone it breathes or walks round the
-- car. Also the call-out marks, the flight over an outside car (Nerede) and photo mode.
Showroom = {}
local S = { session = 0, token = 0, yaw = 38.0, zoom = 1.0, lift = 0.0, idleSince = 0, spin = 0.0, shot = 'hero', near = {} }

-- Geometry -------------------------------------------------------------------------------------------------------------
local function size()
    local min, max = GetModelDimensions(GetEntityModel(S.car))
    return max.y - min.y, max.x - min.x, max.z - min.z
end

-- A point in the car's own frame (x right, y forward, z up from its middle).
local function spot(x, y, z)
    return GetOffsetFromEntityInWorldCoords(S.car, x, y, z)
end

-- A point around the car: yaw from its nose (90 = its left side), distance, height above its middle.
local function around(yaw, dist, height)
    local r = math.rad(yaw)
    return spot(-math.sin(r) * dist, math.cos(r) * dist, height)
end

-- How far back the wide shots stand: the whole car fits left of the column at every yaw.
local function reach()
    local length, width, height = size()
    return (math.max(length * 0.95, width * 1.5, height * 1.6, 4.0) + 1.6) * 1.25
end

-- The middle of the screen the page leaves free, as a fraction of its width: the 1920x1080 stage is scaled to fit and
-- centred, and its column starts at x 1380. Photo mode and a car driving out have no column, so there it is the middle.
local function freeMiddle()
    if S.photo or S.leaving then return 0.5 end
    local w, h = GetActiveScreenResolution()
    local zoom = math.min(w / 1920, h / 1080)
    return ((w - 1920 * zoom) / 2 + 1380 * zoom) / 2 / w
end

-- Where a wide shot from this yaw puts the car: the near corner of a three-quarter view pulls its mass to one side,
-- so the aim leans against it.
local function lean(yaw)
    return freeMiddle() + 0.03 * math.sin(math.rad(2 * yaw))
end

-- The aim slides to the camera's right so the target shows at x (a fraction of the screen width) for this fov.
local function aim(from, target, fov, x)
    local dir = target - from
    local flat = math.sqrt(dir.x * dir.x + dir.y * dir.y)
    if flat < 0.001 then return target end
    local w, h = GetActiveScreenResolution()
    local shift = #dir * 2 * math.tan(math.rad(fov) / 2) * (w / h) * (0.5 - x)
    return target + vector3(dir.y / flat, -dir.x / flat, 0.0) * shift
end

-- A camera spot pulled in short of walls and other cars between it and what it films.
local function clear(target, pos, ignore)
    local probe = StartExpensiveSynchronousShapeTestLosProbe(target.x, target.y, target.z, pos.x, pos.y, pos.z, 1 | 2 | 16, ignore or S.car, 7)
    local _, hit, at = GetShapeTestResult(probe)
    if hit ~= 1 then return pos end
    local dir = pos - target
    return target + dir * (math.max(0.6, #(at - target) - 0.3) / #dir)
end

-- True when a wall stands between two points (the camera would fly through it).
local function blocked(a, b)
    local probe = StartExpensiveSynchronousShapeTestLosProbe(a.x, a.y, a.z, b.x, b.y, b.z, 1 | 16, PlayerPedId(), 7)
    local _, hit = GetShapeTestResult(probe)
    return hit == 1
end

local function bone(names)
    for _, name in ipairs(names) do
        local index = GetEntityBoneIndexByName(S.car, name)
        if index ~= -1 then return GetWorldPositionOfEntityBone(S.car, index) end
    end
    return nil
end

-- Each shot as { from, at, fov } for the current car. Orbit shots (hero, side, rear) follow yaw, zoom and lift.
local SHOTS = {}

local function orbitShot(yaw, distScale, heightScale, fov)
    local _, _, height = size()
    local dist = reach() * distScale * S.zoom
    local centre = spot(0.0, 0.0, height * 0.1)
    local from = around(yaw, dist, height * heightScale + 0.25 + S.lift)
    return { from = from, at = aim(from, centre, fov, lean(yaw)), fov = fov }
end

SHOTS.hero = function() return orbitShot(S.yaw, 1.0, 0.45, 38.0) end
SHOTS.side = function() return orbitShot(90.0, 1.12, 0.3, 34.0) end
SHOTS.rear = function() return orbitShot(150.0, 1.0, 0.5, 38.0) end
SHOTS.damage = function() return orbitShot(60.0, 0.7, 0.4, 40.0) end

SHOTS.engine = function()
    local length, _, height = size()
    local at = bone({ 'bonnet', 'engine' }) or spot(0.0, length * 0.3, height * 0.3)
    local from = around(12.0, length * 0.5 + 1.8, height * 0.5 + 1.0)
    return { from = from, at = aim(from, at, 42.0, freeMiddle()), fov = 42.0 }
end

SHOTS.wheels = function()
    local _, width = size()
    local at = bone({ 'wheel_lf' }) or spot(-width * 0.5, 1.2, -0.3)
    local localWheel = GetOffsetFromEntityGivenWorldCoords(S.car, at.x, at.y, at.z)
    local from = spot(-(width * 0.5 + 1.9), localWheel.y + 0.9, localWheel.z + 0.25)
    return { from = from, at = aim(from, at, 40.0, freeMiddle()), fov = 40.0 }
end

SHOTS.fuel = function()
    local length, width = size()
    local at = bone({ 'petrolcap', 'petroltank', 'wheel_lr' }) or spot(-width * 0.5, -length * 0.3, 0.0)
    local localCap = GetOffsetFromEntityGivenWorldCoords(S.car, at.x, at.y, at.z)
    local side = localCap.x >= 0.0 and 1.0 or -1.0
    local from = spot(side * (width * 0.5 + 1.8), localCap.y - 0.6, localCap.z + 0.35)
    return { from = from, at = aim(from, at, 40.0, freeMiddle()), fov = 40.0 }
end

SHOTS.trunk = function()
    local length, _, height = size()
    local at = bone({ 'boot' }) or spot(0.0, -length * 0.45, height * 0.2)
    local from = around(180.0, length * 0.5 + 2.2, height * 0.5 + 0.8)
    return { from = from, at = aim(from, at, 42.0, freeMiddle()), fov = 42.0 }
end

-- Low at a real car's left rear wheel, looking along it to its nose: where driving out begins.
local function rearCorner(veh)
    local min, max = GetModelDimensions(GetEntityModel(veh))
    local at = GetOffsetFromEntityInWorldCoords(veh, 0.0, max.y * 0.4, (min.z + max.z) / 2)
    local from = GetOffsetFromEntityInWorldCoords(veh, min.x - 0.8, min.y - 1.3, min.z + 0.5)
    return { from = clear(at, from, veh), at = at, fov = 40.0 }
end

-- The idle camera ----------------------------------------------------------------------------------------------------------

-- Someone touched the page: a walk round stops, the idle clock starts again.
local function hush()
    S.idleSince = GetGameTimer()
    S.spin = 0.0
end

-- The real car stays unseen here, and clear of the copy, until it takes the copy's place.
local function hide(veh)
    if not DoesEntityExist(veh) then return end
    SetEntityLocallyInvisible(veh)
    if S.car then SetEntityNoCollisionEntity(veh, S.car, true) end
end

-- The cars standing near the copy (as a set).
local function nearby()
    local here, set = GetEntityCoords(S.car), {}
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if veh ~= S.car and #(GetEntityCoords(veh) - here) < 6.0 then set[veh] = true end
    end
    return set
end

-- Each frame while the showroom runs: the breath or the walk round on the hero shot, the Nerede ring, the real car
-- kept hidden.
local function frame(session)
    while S.active and S.session == session do
        local resting = S.car and S.shot == 'hero' and not S.photo and not S.locate and not S.leaving
        Director.drift(resting and Prefs.camera == 'calm')
        if resting and Prefs.camera == 'orbit' and GetGameTimer() - S.idleSince > 4000 and not Director.moving() then
            -- The walk round speeds up gently instead of starting at full pace.
            S.spin = math.min(1.0, S.spin + GetFrameTime() / 2.0)
            S.yaw = (S.yaw + GetFrameTime() * 6.0 * S.spin) % 360.0
            Director.cut(SHOTS.hero())
        end
        if S.incoming then
            hide(S.incoming)
        elseif S.before and S.car then
            -- Before its handle comes back, a car new on the copy's spot is the real one on its way.
            for veh in pairs(nearby()) do
                if not S.before[veh] then SetEntityLocallyInvisible(veh) end
            end
        end
        if S.locate then
            local p = S.locate
            DrawMarker(1, p.x, p.y, p.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 6.0, 6.0, 1.2, 255, 255, 255, 90, false, false, 2, false, nil, nil, false)
        end
        -- With the focus away (Nerede's flight, the studio) the ground under the player is kept, or they fall through it.
        if S.locate or Config.Showroom.Mode == 'studio' then
            local me = GetEntityCoords(PlayerPedId())
            RequestCollisionAtCoord(me.x, me.y, me.z)
        end
        Wait(0)
    end
end

-- The call-out marks: once the side shot settles, the bonnet, a door, the fuel cap and the front wheel on screen.
local function sendMarks()
    local token = S.token
    CreateThread(function()
        while Director.moving() do Wait(50) end
        Wait(80)
        if token ~= S.token or S.shot ~= 'side' or not S.car then return end
        local marks = {}
        local spots = {
            { 'engine', { 'bonnet', 'engine' } },
            { 'body', { 'door_dside_f', 'door_dside_r' } },
            { 'fuel', { 'petrolcap', 'petroltank', 'wheel_lr' } },
            { 'wheels', { 'wheel_lf' } },
        }
        for _, s in ipairs(spots) do
            local p = bone(s[2])
            if p then
                local onScreen, x, y = GetScreenCoordFromWorldCoord(p.x, p.y, p.z)
                if onScreen then marks[#marks + 1] = { id = s[1], x = x, y = y } end
            end
        end
        Page.send('garage:marks', { marks = marks })
    end)
end

-- The preview car --------------------------------------------------------------------------------------------------------
local modsLoaded = IsVehicleModLoadDone

local function dropCar()
    if S.car and DoesEntityExist(S.car) then DeleteEntity(S.car) end
    S.car = nil
end

-- A car's alpha from a to b over ms; at 255 it is opaque for good.
local function fade(veh, a, b, ms)
    CreateThread(function()
        local t0 = GetGameTimer()
        while DoesEntityExist(veh) do
            local t = ms > 0 and math.min(1.0, (GetGameTimer() - t0) / ms) or 1.0
            local v = math.floor(a + (b - a) * t)
            if v >= 255 then ResetEntityAlpha(veh) else SetEntityAlpha(veh, v, false) end
            if t >= 1 then return end
            Wait(0)
        end
    end)
end

-- The height that puts a model's wheels on the ground under the spot; the ground is found once per opening. Spots saved
-- where someone stood (private garages) are a metre up, and a frozen copy would hang there. Boats keep the spot's own
-- height: the ground under water is the sea floor.
local function groundZ(hash)
    local p = S.spot
    if GetVehicleClassFromName(hash) == 14 then return p.z end
    if S.ground == nil then
        S.ground = false
        for _ = 1, 20 do
            local found, z = GetGroundZFor_3dCoord(p.x, p.y, p.z + 1.0, false)
            if found then
                S.ground = z
                break
            end
            RequestCollisionAtCoord(p.x, p.y, p.z)
            Wait(50)
        end
    end
    if not S.ground then return p.z end
    local min = GetModelDimensions(hash)
    return S.ground - min.z
end

-- A local, frozen copy of the car with its saved look, standing on the ground and unseen until it is swapped in; nil
-- when its model is missing or a newer choice came while it loaded (wanted() turns false).
local function spawnCar(entry, wanted)
    local hash = Car.hash(entry.model)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then return nil end
    RequestModel(hash)
    local since, waiting = GetGameTimer(), false
    while not HasModelLoaded(hash) and wanted() and GetGameTimer() - since < 10000 do
        if not waiting and GetGameTimer() - since > 350 then
            waiting = true
            Page.send('garage:loading', { on = true })
        end
        Wait(0)
    end
    if waiting then Page.send('garage:loading', { on = false }) end
    local loaded = HasModelLoaded(hash) and wanted()
    pcall(function() exports['FeloxAC']:CreateVehicle(hash) end) --[[FeloxAC:auto]]
    local veh = loaded and CreateVehicle(hash, S.spot.x, S.spot.y, groundZ(hash), S.spot.w, false, false) or nil
    if not S.near[hash] then SetModelAsNoLongerNeeded(hash) end
    if not veh or veh == 0 then return nil end
    -- Keep the entity visible to the renderer (hidden via alpha 0) while mods and paint stream, so GTA doesn't cull
    -- mod-kit mesh loading until after the car is shown.
    SetEntityAlpha(veh, 0, false)
    SetEntityVisible(veh, true, false)
    SetVehicleOnGroundProperly(veh)
    FreezeEntityPosition(veh, true)
    SetEntityInvincible(veh, true)
    SetVehicleDoorsLocked(veh, 2)
    if entry.props then Car.setProps(veh, entry.props, true) end
    pcall(function() exports['FeloxAC']:ChangeVehiclePlate(veh, entry.plate or '') end) --[[FeloxAC:auto]]
    SetVehicleNumberPlateText(veh, entry.plate or '')
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleLights(veh, 2)
    -- Its paint and parts settle for a few frames before it is seen.
    local made = GetGameTimer()
    repeat Wait(0) until GetGameTimer() - made > 30 and (not modsLoaded or modsLoaded(veh) or GetGameTimer() - made > 250)
    return veh
end

-- The opening: the camera leaves the game camera and glides to the hero shot as the car fades in; the page comes in as
-- the camera nears its place. A spot far off or behind the player, a wall in the way or no cinematics: a short dip to
-- black instead.
local function opening(veh)
    local session, hero, game = S.session, SHOTS.hero(), Director.game()
    local ms = Page.ms(1200)
    local dark = IsScreenFadedOut() or IsScreenFadingOut()
    local view, toCar = game.at - game.from, hero.at - game.from
    local ahead = (view.x * toCar.x + view.y * toCar.y + view.z * toCar.z) / math.max(0.001, #view * #toCar) > 0.2
    if ms > 0 and not dark and ahead and #(game.from - hero.from) < 45.0 and not blocked(game.from, hero.from) then
        SetEntityAlpha(veh, 0, false)
        SetEntityVisible(veh, true, false)
        local mid = { from = (game.from + hero.from) / 2 + vector3(0.0, 0.0, 0.8), at = (game.at + hero.at) / 2, fov = (game.fov + hero.fov) / 2 }
        Director.to(hero, ms, 'inOutSine', nil, { mid })
        fade(veh, 0, 255, ms * 0.5)
        SetTimeout(math.floor(ms * 0.55), function()
            if S.session == session then Garage.reveal() end
        end)
        return
    end
    if ms > 0 and not dark then
        DoScreenFadeOut(200)
        local stop = GetGameTimer() + 1000
        while not IsScreenFadedOut() and GetGameTimer() < stop do Wait(0) end
        -- Closed meanwhile: the way back to the game camera is already under way.
        if S.session ~= session or S.leaving then return DoScreenFadeIn(200) end
    end
    ResetEntityAlpha(veh)
    SetEntityVisible(veh, true, false)
    Director.cut(hero)
    if IsScreenFadedOut() or IsScreenFadingOut() then DoScreenFadeIn(Page.ms(400)) end
    Garage.reveal()
end

-- One choice: the new car is made, then in one frame the old one goes and the new one is seen. The camera keeps its
-- angle and only settles on the new car's size; the first car opens the garage instead.
local function swap(entry)
    local session = S.session
    local function wanted() return S.session == session and S.active and not S.leaving and not S.want end
    local veh = spawnCar(entry, wanted)
    if not veh or not wanted() then
        if veh then DeleteEntity(veh) end
        -- A missing model leaves the stand empty, not showing the car chosen before.
        if wanted() then
            dropCar()
            Page.notice('msg.model_missing', 'error')
            if S.first then Garage.reveal() end
        end
        return
    end
    dropCar()
    S.car = veh
    Showroom.patch(entry.plate, veh)
    if S.first then
        S.first = false
        return opening(veh)
    end
    ResetEntityAlpha(veh)
    SetEntityVisible(veh, true, false)
    Page.sound('move')
    local hero, pose = SHOTS.hero(), Director.pose()
    local far = pose and #(pose.from - hero.from) > 2.0
    Director.to(hero, Page.ms(far and 900 or 450), 'smooth')
end

-- Starting / stopping ----------------------------------------------------------------------------------------------------

-- Begins at the garage's show spot (or the studio): our camera takes the game camera's place at once (nothing changes
-- on screen) and waits there for the first car.
function Showroom.start(spot)
    S.spot = Config.Showroom.Mode == 'studio' and Core.vec4(Config.Showroom.Studio) or Core.vec4(spot)
    if not S.spot then return false end
    if Config.Showroom.Mode == 'studio' then
        DoScreenFadeOut(Page.ms(300))
        SetFocusPosAndVel(S.spot.x, S.spot.y, S.spot.z, 0.0, 0.0, 0.0)
    end
    S.session = S.session + 1
    S.active, S.first, S.leaving, S.shot, S.yaw, S.zoom, S.lift = true, true, false, 'hero', 38.0, 1.0, 0.0
    S.photo, S.locate, S.want, S.incoming, S.before, S.ground = false, nil, nil, nil, nil, nil
    hush()
    Director.start()
    local session = S.session
    CreateThread(function() frame(session) end)
    return true
end

-- Sadece fotograf modunun kendi koydugu timecycle temizlenir; ardindan oyuncunun /fps
-- (FPSBoost) ayari geri uygulanir. Eskiden garaj her kapanista ClearTimecycleModifier()
-- cagirip /fps ayarlarini sifirliyordu.
local function restoreLook()
    ClearTimecycleModifier()
    if GetResourceState('FPSBoost') == 'started' then
        pcall(function() exports.FPSBoost:reapply() end)
    end
end

-- Ends at once (the camera blends back over ms): the copy goes, the models asked for ahead are let go.
function Showroom.stop(ms)
    S.session = S.session + 1
    S.active, S.photo, S.locate, S.leaving, S.want, S.incoming, S.before = false, false, nil, false, nil, nil, nil
    if S.looked then S.looked = false; restoreLook() end
    ClearFocus()
    Director.stop(ms or 0)
    dropCar()
    Showroom.preload({})
end

-- Leaving: the page is gone; the copy fades out while the camera glides back to the game camera, then it all ends.
function Showroom.leave()
    if not S.active then return end
    local session, ms = S.session, Page.ms(900)
    S.leaving, S.want = true, nil
    -- The studio's dip to black ends here when no car came to open it.
    if IsScreenFadedOut() or IsScreenFadingOut() then DoScreenFadeIn(Page.ms(400)) end
    if ms == 0 or not Director.active() then return Showroom.stop(0) end
    if S.car then fade(S.car, 255, 0, ms * 0.6) end
    Director.aimGame(Director.pose())
    Director.toGame(ms, 'inOutSine', function()
        if S.session == session then Showroom.stop(150) end
    end, 0.5)
end

-- Models asked for ahead (the chosen car's and its neighbours' in the list); the others are let go.
function Showroom.preload(models)
    local keep = {}
    for _, model in ipairs(models) do
        local hash = Car.hash(model)
        if IsModelInCdimage(hash) then
            keep[hash] = true
            if not S.near[hash] then RequestModel(hash) end
        end
    end
    for hash in pairs(S.near) do
        if not keep[hash] then SetModelAsNoLongerNeeded(hash) end
    end
    S.near = keep
end

-- Shows a car. A choice made while another loads replaces it, so fast browsing makes only the last one.
function Showroom.show(entry)
    if not S.active or S.leaving then return end
    hush()
    S.want, S.shot = entry, 'hero'
    S.token = S.token + 1
    Page.send('garage:marks', { marks = {} })
    if S.swapping then return end
    S.swapping = true
    CreateThread(function()
        while S.active and S.want do
            local want = S.want
            S.want = nil
            -- One car failing must not stop the ones after it.
            local ok, err = pcall(swap, want)
            if not ok then Bridge.warn('showroom: %s', err) end
        end
        S.swapping = false
    end)
end

-- Taking a car out -------------------------------------------------------------------------------------------------------

-- The server makes the real car: the page is gone, the camera eases in on the copy and centres it.
function Showroom.wait()
    if not S.active then return end
    hush()
    S.leaving, S.want = true, nil
    if S.locate then
        S.locate = nil
        if Config.Showroom.Mode ~= 'studio' then ClearFocus() end
    end
    -- The real car may come on the copy's own spot: the copy stops colliding and new cars there stay unseen.
    if S.car then
        SetEntityCollision(S.car, false, false)
        S.before = nearby()
    end
    if not S.car or not Director.active() or Page.ms(1000) == 0 then return end
    S.zoom = S.zoom * 0.9
    Director.to(SHOTS.hero(), 3000, 'inOutSine')
end

-- The real car is on its way: hidden here (and kept off the copy) until it takes the copy's place.
function Showroom.incoming(veh)
    S.incoming = veh
    hide(veh)
end

-- Driving out: under a short dip to black the copy gives way to the real car, seat() puts the player in it and the game
-- camera turns behind it. The picture comes back low at the car's rear corner and the camera rises behind it into the
-- game camera's place.
function Showroom.driveOff(veh, seat)
    local session, ms = S.session, Page.ms(1700)
    local function swapIn()
        S.incoming, S.before = nil, nil
        dropCar()
        local ok, err = pcall(seat)
        if not ok then print(('^1[daddy_garages] seating failed: %s^7'):format(err)) end
        SetGameplayCamRelativeHeading(0.0)
        SetGameplayCamRelativePitch(-6.0, 1.0)
    end
    if not S.active or not Director.active() or ms == 0 or not DoesEntityExist(veh) then
        swapIn()
        return Showroom.stop(0)
    end
    DoScreenFadeOut(Page.ms(300))
    local stop = GetGameTimer() + 1000
    while not IsScreenFadedOut() and GetGameTimer() < stop do Wait(0) end
    swapIn()
    if S.session ~= session then return DoScreenFadeIn(300) end
    if not DoesEntityExist(veh) then
        DoScreenFadeIn(300)
        return Showroom.stop(0)
    end
    Director.cut(rearCorner(veh))
    Wait(0)
    DoScreenFadeIn(Page.ms(500))
    Director.around(veh, { 'game' }, ms, 'inOutSine', function()
        if S.session == session then Showroom.stop(150) end
    end)
    -- The game camera settles into the car's own view after the warp; it is turned behind once more as it does.
    SetTimeout(250, function()
        if S.session ~= session then return end
        SetGameplayCamRelativeHeading(0.0)
        SetGameplayCamRelativePitch(-6.0, 1.0)
    end)
end

-- Parking: a low shot at the driver's door (the other side when a wall stands there) and the slide along the car to its
-- front corner, for a real car about to be parked.
function Showroom.parkShots(veh)
    local min, max = GetModelDimensions(GetEntityModel(veh))
    local mid = (min.z + max.z) / 2
    local index = GetEntityBoneIndexByName(veh, 'door_dside_f')
    local door = vector3(min.x, max.y * 0.15, mid)
    if index ~= -1 then
        local p = GetWorldPositionOfEntityBone(veh, index)
        door = GetOffsetFromEntityGivenWorldCoords(veh, p.x, p.y, p.z)
    end
    -- x: -1 the driver's side, 1 the other; the door shot always looks at the driver's door.
    local function side(x)
        local edge = x < 0 and min.x or max.x
        local doorShot = {
            from = GetOffsetFromEntityInWorldCoords(veh, edge + x * 2.0, door.y + 2.4, min.z + 0.65),
            at = GetOffsetFromEntityInWorldCoords(veh, min.x * 0.6, door.y, door.z + 0.35),
            fov = 40.0,
        }
        local alongShot = {
            from = GetOffsetFromEntityInWorldCoords(veh, edge + x * 2.6, max.y + 1.8, mid + 0.6),
            at = GetOffsetFromEntityInWorldCoords(veh, 0.0, 0.0, mid),
            fov = 42.0,
        }
        return doorShot, alongShot
    end
    local doorShot, alongShot = side(-1.0)
    if #(clear(doorShot.at, doorShot.from, veh) - doorShot.from) > 0.5 then doorShot, alongShot = side(1.0) end
    doorShot.from = clear(doorShot.at, doorShot.from, veh)
    alongShot.from = clear(alongShot.at, alongShot.from, veh)
    return doorShot, alongShot
end

-- The rest of the page's camera --------------------------------------------------------------------------------------------

-- Facts only a spawned car has (drive, weight, liveries, extras) go to the page once the copy stands.
function Showroom.patch(plate, veh)
    local front = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fDriveBiasFront')
    local drive = front >= 0.99 and 'FWD' or front <= 0.01 and 'RWD' or 'AWD'
    local extras = {}
    for id = 0, 20 do
        if DoesExtraExist(veh, id) then extras[#extras + 1] = id end
    end
    local on = {}
    for _, id in ipairs(extras) do
        if IsVehicleExtraTurnedOn(veh, id) then on[#on + 1] = id end
    end
    -- Liveries and extras are picked only in job and gang garages; the pickers start at what the car wears.
    local group = Garage.current and (Garage.current.kind == 'job' or Garage.current.kind == 'gang')
    local liveries = GetVehicleLiveryCount(veh)
    Page.send('garage:car', { plate = plate, patch = {
        drive = drive,
        mass = math.floor(GetVehicleHandlingFloat(veh, 'CHandlingData', 'fMass')),
        liveries = group and liveries > 0 and liveries or nil,
        livery = group and liveries > 0 and math.max(1, GetVehicleLivery(veh) + 1) or nil,
        extras = group and #extras > 0 and extras or nil,
        extrasOn = group and #extras > 0 and on or nil,
    } })
end

-- Moves to a named shot; the side shot then sends the call-out marks.
function Showroom.shot(name)
    if not S.active or S.leaving or not S.car or not SHOTS[name] then return end
    hush()
    S.shot = name
    S.token = S.token + 1
    Page.send('garage:marks', { marks = {} })
    Director.to(SHOTS[name](), Page.ms(name == 'hero' and 900 or 1000), 'smooth')
    if name == 'side' then sendMarks() end
end

-- Any key or click on the page: the idle clock starts again.
function Showroom.wake()
    hush()
end

-- Drag turns the car (orbit shots and photo mode), the wheel pulls in and out, dy lifts the camera in photo mode.
function Showroom.orbit(dx, dy, wheel)
    if not S.active or S.leaving or not S.car or (S.shot ~= 'hero' and not S.photo) then return end
    hush()
    S.yaw = (S.yaw - (tonumber(dx) or 0) * 0.25) % 360.0
    S.zoom = math.max(S.photo and 0.45 or 0.75, math.min(1.5, S.zoom + (tonumber(wheel) or 0) * 0.0008))
    if S.photo then S.lift = math.max(-0.6, math.min(4.0, S.lift + (tonumber(dy) or 0) * 0.01)) end
    if Director.moving() then return end
    Director.cut(SHOTS.hero())
end

-- Opens or shuts every door, the bonnet and the boot.
function Showroom.doors(open)
    if not S.car then return end
    for door = 0, 5 do
        if open then SetVehicleDoorOpen(S.car, door, false, false) else SetVehicleDoorShut(S.car, door, false) end
    end
end

-- Nerede: the camera rises over a point with a ring on the ground (the area streams in); nil comes back down.
function Showroom.locate(point)
    if not S.active or S.leaving then return end
    hush()
    S.token = S.token + 1
    if point then
        S.locate = point
        SetFocusPosAndVel(point.x, point.y, point.z, 0.0, 0.0, 0.0)
        local from = vector3(point.x - 18.0, point.y - 26.0, point.z + 48.0)
        Director.to({ from = from, at = aim(from, vector3(point.x, point.y, point.z), 45.0, freeMiddle()), fov = 45.0 }, Page.ms(2200), 'inOutSine')
    else
        S.locate = nil
        if Config.Showroom.Mode ~= 'studio' then ClearFocus() end
        S.shot = 'hero'
        if S.car then Director.to(SHOTS.hero(), Page.ms(1800), 'inOutSine') end
    end
end

-- Photo mode: the page shows only its bar, drag and wheel move freely, a look (timecycle) colours the frame.
function Showroom.photo(on, look)
    if not S.active or S.leaving then return end
    hush()
    S.photo = on == true
    S.shot = 'hero'
    S.zoom, S.lift = 1.0, 0.0
    Showroom.look(on and look or 'none')
    if S.car then Director.to(SHOTS.hero(), Page.ms(600), 'smooth') end
end

function Showroom.look(id)
    local look = (Config.Photo.Looks or {})[id]
    if type(look) == 'table' then
        S.looked = true
        SetTimecycleModifier(look[1])
        SetTimecycleModifierStrength(look[2] or 1.0)
    elseif S.looked then
        S.looked = false
        restoreLook()
    end
end

function Showroom.active() return S.active == true end

-- Open, still waiting for its first car to stand.
function Showroom.waiting() return S.active == true and S.first == true end
