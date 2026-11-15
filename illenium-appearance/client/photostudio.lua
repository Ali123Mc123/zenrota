-- Photo studio (admins): one transparent picture of every clothing item and colourway for the editor's catalogue,
-- saved as pictures/<collection folder>/<slot>_<idx>_t<tex>_a000.webp (server/photostudio.js). A local, invisible copy
-- of the freemode ped wears each item in front of a green wall; the camera looks at the item from its best side and
-- frames it tight, and the page (web/src/photostudio/lab.ts) keys the wall away, from a second frame with the wall pink
-- where it reads the view itself (true transparency for hair, glass and green cloth). The empty head is a clothing
-- collection of its own that this resource streams (stream/, data/), or no head at all where the client allows it.
local client = client
local S = Config.PhotoStudio
if not S then return end

local COMPS = { berd = 1, hair = 2, uppr = 3, lowr = 4, hand = 5, feet = 6, teef = 7, accs = 8, task = 9, decl = 10, jbib = 11 }
local PROPS = { p_head = 0, p_eyes = 1, p_ears = 2, p_lwrist = 6, p_rwrist = 7 }
local ORDER = { "jbib", "lowr", "feet", "accs", "task", "uppr", "hand", "teef", "decl", "berd", "hair", "p_head", "p_eyes", "p_ears", "p_lwrist", "p_rwrist" }

-- the invisible ped: no piece (-1) in every slot but the head, which the game always fills. GTA's own "empty" pieces
-- (drawable 0 of masks, bags, accessories, armour and decals) are a 3 cm square at the stomach that only the body hides.
-- The head becomes an empty one once the set check has found it (ready)
local GHOST = { [0] = { 0, 1 } }
for c = 1, 11 do GHOST[c] = { -1, 0 } end
-- the studio head's collections (stream/, built with K3D from an empty model)
local HEADS = { m = "mp_m_illenium_studio", f = "mp_f_illenium_studio" }
-- one pose in every picture: the freemode ped's own standing idle, stopped on its first frame (left to itself the ped
-- breathes and shifts its weight, and the clothes moved between pictures)
local POSE = { m = { "move_m@generic", "idle" }, f = { "move_f@multiplayer", "idle" } }

local BONES = { head = 31086, neck = 39317, chest = 24818, spine = 24817, pelvis = 11816, lhand = 18905, rhand = 57005,
    lfoot = 14201, rfoot = 52301, lcalf = 63931, rcalf = 36864,
    -- the face's own bones, for the face looks
    lbrow = 58331, rbrow = 1356, leye = 25260, reye = 27474, upperlip = 20178, lowerlip = 17188, jaw = 46240,
    lcheek = 21550, rcheek = 19336 }

-- where each slot's item sits (its bones, averaged) and how much to look at first (half height, metres), the sides
-- worth a look (degrees the ped turns; positive shows its right side; the one showing most wins, the first on a near
-- tie) and how far above it the camera rises (degrees)
local PLAN = {
    jbib = { bones = { "spine" }, half = 0.6, sides = { 0 } },
    accs = { bones = { "spine" }, half = 0.55, sides = { 0 } },
    task = { bones = { "spine" }, half = 0.55, sides = { 0 } },
    uppr = { bones = { "spine" }, half = 0.75, sides = { 0 } },
    decl = { bones = { "spine" }, half = 0.55, sides = { 0, 180 }, flat = false }, -- a small square patch is no "none" piece
    hand = { bones = { "spine" }, half = 0.6, sides = { 180, 0 } },
    teef = { bones = { "neck", "chest" }, half = 0.35, sides = { 0 } },
    lowr = { bones = { "pelvis", "lcalf", "rcalf" }, half = 0.6, sides = { 0 } },
    feet = { bones = { "lfoot", "rfoot" }, half = 0.25, sides = { 35 } },
    berd = { bones = { "head" }, half = 0.3, sides = { 0 } },
    hair = { bones = { "head" }, half = 0.32, sides = { 30 }, rise = 5 },
    p_head = { bones = { "head" }, half = 0.28, sides = { 15 }, rise = 8 },
    p_eyes = { bones = { "head" }, half = 0.2, sides = { 0 } },
    p_ears = { bones = { "head" }, half = 0.2, sides = { 90, -90 } },
    p_lwrist = { bones = { "lhand" }, half = 0.22, sides = { -90, 90, 0 } },
    p_rwrist = { bones = { "rhand" }, half = 0.22, sides = { 90, -90, 0 } },
}

local UP = vec3(0.0, 0.0, 1.0)
local TOWARD = vec3(0.0, 1.0, 0.0) -- from the ped to the camera: the ped faces it at heading 0, the wall stands behind
local RIGHT = vec3(-1.0, 0.0, 0.0) -- the picture's right, seen from the camera
local LENS, NEAR, FAR = 18.0, 0.45, 3.5 -- the usual field of view; the camera moves between NEAR and FAR metres to frame
local WALL, KEY = 2.0, { 0, 255, 0 } -- the green wall: metres behind what the camera looks at, and its colour
local PINK = { 255, 170, 255 } -- its colour for each picture's second frame (about as bright, so the exposure holds)
local wall = KEY -- the colour drawn now
local pair = 0 -- numbers the green / pink frame pairs
-- hair is shot on a bust: a ped with a real head (a parent face) and medium brown hair with lighter highlights (the
-- game's hair colours 8 and 12; one dark colour hid the strands)
local FACE, HAIR = { m = 0, f = 21 }, { 8, 12 }
local FOOT = 0.08 -- the foot bones' height over the soles

-- how long a piece may take to stream in (ms): a first try and the try on a fresh ped, longer in a retry run (pieces
-- that did not load before); a colour the game itself calls invalid gets only a short look
local LOAD = { first = 4000, again = 8000, retryFirst = 8000, retryAgain = 15000, invalid = 1500 }
local load = { first = LOAD.first, again = LOAD.again }

local running, stopping = false, false
local set = {} -- ped, platform, cam, feet (height of the soles), home (where the player was)
local view -- the camera's framing: target, up, dist, fov, wall (the green wall's corners)
-- picture names the current folder already has, its items an earlier run found empty, and its colours that did not
-- stream in on an earlier run (slot_idx_tN; a normal run skips them, a retry run tries only those and the empty items)
local have, gone, failed = {}, {}, {}
local stats = { folder = "", done = 0, todo = 0, empty = 0, unloaded = 0, start = 0 }

local function notify(key, kind, ...)
    lib.notify({ title = _L("photostudio.title"), description = _L("photostudio." .. key):format(...), type = kind or "inform",
        position = Config.NotifyOptions.position })
end

-- the screen that covers the set during a run (web/src/photostudio/StudioOverlay.vue): the page reads the game frame
-- under every page, so the set works on behind it and nobody has to watch the wall flash green and pink
local function ui(data)
    data.type = "photostudio_ui"
    SendNUIMessage(data)
end

-- what the run does now; folder nil keeps the one shown
local function phase(key, folder) ui({ phase = _L("photostudio.ui." .. key), folder = folder }) end

local function report()
    local each = stats.done > 0 and (GetGameTimer() - stats.start) / 1000 / stats.done or 0
    ui({ done = stats.done, todo = stats.todo, each = each, empty = stats.empty,
        left = math.ceil(each * math.max(0, stats.todo - stats.done) / 60) })
end

-- ---- the page --------------------------------------------------------------------------------------------------------
local pending, seq = {}, 0

RegisterNUICallback("photostudio_done", function(data, cb)
    cb(1)
    local p = data and pending[data.id]
    if p then
        pending[data.id] = nil
        p:resolve(data)
    end
end)

-- a promise the page answers on the returned id (an error after 30 s)
local function ask()
    seq = seq + 1
    local id, p = seq, promise.new()
    pending[id] = p
    SetTimeout(30000, function()
        if pending[id] then
            pending[id] = nil
            p:resolve({ error = "timeout" })
        end
    end)
    return id, p
end

local function lab(op, args)
    local id, done = ask()
    args.type, args.op, args.id = "photostudio", op, id
    SendNUIMessage(args)
    return Citizen.Await(done)
end

local direct = true -- the page reads the game view itself; screenshot-basic (about 2 s a frame) when it cannot

-- a change shows in the view a few frames later (the game draws a frame behind, the page reads a copy of it): a look
-- waits for the frame from which the last change shows
local still = 0
local function moved() still = GetFrameCount() + 4 end

-- a screenshot-basic frame, or nil after 10 s (the resource restarted or its page failed)
local function screenshot()
    local p = promise.new()
    exports["screenshot-basic"]:requestScreenshot({ encoding = "jpg", quality = 0.95 }, function(data) p:resolve(data) end)
    SetTimeout(10000, function() p:resolve(nil) end)
    return Citizen.Await(p)
end

-- captures the view now and returns a promise for the page's answer about it
local function snap(op, args)
    while GetFrameCount() < still do Wait(0) end
    args = args or {}
    args.type, args.op = "photostudio", op
    if not direct then
        args.img = screenshot()
        local id, done = ask()
        if not args.img then
            pending[id] = nil
            done:resolve({ error = "no screenshot" })
            return done
        end
        args.id = id
        SendNUIMessage(args)
        return done
    end
    for try = 1, 4 do
        local grab, grabbed = ask()
        local id, done = ask()
        args.grab, args.id = grab, id
        SendNUIMessage(args)
        if not Citizen.Await(grabbed).error or try == 4 then return done end
        Wait(200) -- a black frame (the game was minimised or hitched): once more
    end
end

-- ---- camera ----------------------------------------------------------------------------------------------------------
-- looks straight at target (rise degrees from above) so that half metres up and down fill the picture's height; the
-- green wall stands WALL metres behind the target facing the camera, larger than the view on every side
local function aim(target, half, rise)
    rise = math.rad(rise or 0.0)
    local dist = math.min(FAR, math.max(NEAR, half / math.tan(math.rad(LENS / 2))))
    local fov = math.max(1.0, math.deg(2 * math.atan(half / dist)))
    local back = TOWARD * math.cos(rise) + UP * math.sin(rise)
    local pos = target + back * dist
    SetCamCoord(set.cam, pos.x, pos.y, pos.z)
    PointCamAtCoord(set.cam, target.x, target.y, target.z)
    SetCamFov(set.cam, fov)
    local up = UP * math.cos(rise) - TOWARD * math.sin(rise)
    local h = (dist + WALL) * math.tan(math.rad(fov) / 2.0) * 1.5
    local c, u, r = target - back * WALL, up * h, RIGHT * (h * 2.5)
    view = { target = target, up = up, dist = dist, fov = fov, wall = { c - r + u, c + r + u, c + r - u, c - r - u } }
    moved()
end

local function anchor(ped, bones)
    local sum = vec3(0.0, 0.0, 0.0)
    for _, name in ipairs(bones) do sum = sum + GetPedBoneCoords(ped, BONES[name], 0.0, 0.0, 0.0) end
    return sum / #bones
end

-- the ped turns side degrees away from facing the camera (its desired heading too, so the game never turns it back)
local function turn(ped, side)
    local h = side % 360.0
    SetPedDesiredHeading(ped, h)
    SetEntityHeading(ped, h)
    moved()
end

-- the ped stands still in the pose, played again when something ended it
local function hold(ped)
    local dict, clip = set.pose[1], set.pose[2]
    if not IsEntityPlayingAnim(ped, dict, clip, 3) then
        TaskPlayAnim(ped, dict, clip, 1000.0, 1000.0, -1, 1, 0.0, false, false, false)
        local t = GetGameTimer()
        while not IsEntityPlayingAnim(ped, dict, clip, 3) and GetGameTimer() - t < 2000 do Wait(0) end
    end
    SetEntityAnimCurrentTime(ped, dict, clip, 0.0)
    SetEntityAnimSpeed(ped, dict, clip, 0.0)
    moved()
end

-- ---- dressing --------------------------------------------------------------------------------------------------------
-- waits until the drawable has streamed in, so a picture never catches a half-loaded garment; false when it did not
-- (the ped's clothing memory is full: the caller starts a fresh ped)
local function setComp(ped, c, d, t, wait)
    if d < 0 then
        SetPedComponentVariation(ped, c, -1, 0, 0)
        moved()
        return true
    end
    wait = wait or load.first
    if not IsPedComponentVariationValid(ped, c, d, t) then wait = math.min(wait, LOAD.invalid) end
    SetPedPreloadVariationData(ped, c, d, t)
    local s = GetGameTimer()
    while not HasPedPreloadVariationDataFinished(ped) and GetGameTimer() - s < wait do Wait(0) end
    local ok = HasPedPreloadVariationDataFinished(ped)
    SetPedComponentVariation(ped, c, d, t, 0)
    ReleasePedPreloadVariationData(ped)
    moved()
    return ok
end

local function setProp(ped, p, d, t, wait)
    wait = wait or load.first
    SetPedPreloadPropData(ped, p, d, t)
    local s = GetGameTimer()
    while not HasPedPreloadPropDataFinished(ped) and GetGameTimer() - s < wait do Wait(0) end
    local ok = HasPedPreloadPropDataFinished(ped)
    SetPedPropIndex(ped, p, d, t, true)
    ReleasePedPreloadPropData(ped)
    moved()
    return ok
end

-- the invisible ped, or it with some slots set (over); the empty pieces need no streaming wait, the head does (the
-- studio head loads on first use)
local function dress(ped, over)
    for c = 0, 11 do
        local v = over and over[c] or GHOST[c]
        if c == 0 and set.head then v = { set.head, 0 } end
        local t = v[2]
        if c == 0 and not IsPedComponentVariationValid(ped, 0, v[1], t) then t = 0 end
        if (over and over[c]) or c == 0 then setComp(ped, c, v[1], t) else SetPedComponentVariation(ped, c, v[1], t, 0) end
    end
    ClearAllPedProps(ped)
    moved()
end

local function recolour(ped, it, tex, wait)
    if it.prop then return setProp(ped, it.prop, it.global, tex, wait) end
    return setComp(ped, it.comp, it.global, tex, wait)
end

-- the item on the invisible ped; host: a top under it (a decal that shows nothing on its own is shot on a plain top)
local function wear(ped, it, tex, wait, host)
    hold(ped)
    dress(ped)
    if host and not setComp(ped, 11, host, 0, wait) then return false end
    return recolour(ped, it, tex, wait)
end

-- ---- the set ---------------------------------------------------------------------------------------------------------
local function prop(name, x, y, z)
    local model = joaat(name)
    if not IsModelInCdimage(model) then return nil end
    lib.requestModel(model, 10000)
    pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
    local obj = CreateObject(model, x, y, z, false, false, false)
    SetModelAsNoLongerNeeded(model)
    FreezeEntityPosition(obj, true)
    return obj
end

local function remove(entity)
    if entity and DoesEntityExist(entity) then DeleteEntity(entity) end
end

-- the bust's face bare but for the brows every card wears: a fresh ped can come with makeup, other head overlays or
-- tattoos (the female one showed eye makeup and a neck tattoo in its pictures)
local BROWS, DARK = 0, 1
local function bareFace(ped, brows)
    for o = 0, 12 do SetPedHeadOverlay(ped, o, 255, 0.0) end
    if brows then
        SetPedHeadOverlay(ped, 2, BROWS, 1.0)
        SetPedHeadOverlayColor(ped, 2, 1, DARK, DARK)
    end
    ClearPedDecorations(ped)
    ClearPedFacialDecorations(ped)
end

-- a fresh ped on the platform in the pose (one that wore a few hundred garments runs out of clothing memory): the
-- invisible one, or the bust for hair. Hair takes its colour from the head's blend data, which brings the face back, so
-- on the invisible ped it shows the game's raw, green tint texture
local function makePed(g, bust)
    local model = g == "f" and `mp_f_freemode_01` or `mp_m_freemode_01`
    lib.requestModel(model, 10000)
    set.pose = POSE[g]
    lib.requestAnimDict(set.pose[1], 10000)
    pcall(function() exports['FeloxAC']:CreatePed(model) end) --[[FeloxAC:auto]]
    local ped = CreatePed(4, model, S.Place.x, S.Place.y, set.feet, 0.0, false, false)
    SetModelAsNoLongerNeeded(model)
    SetEntityAsMissionEntity(ped, true, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanHeadIk(ped, false)
    SetPedCanArmIk(ped, false)
    SetPedCanLegIk(ped, false)
    SetPedCanPlayAmbientAnims(ped, false)
    SetPedCanPlayAmbientBaseAnims(ped, false)
    SetPedDefaultComponentVariation(ped) -- no head blend on the invisible ped: the empty head breaks apart under one
    if bust then
        SetEntityCollision(ped, false, false) -- it stands where the invisible ped stands
        SetEntityVisible(ped, false, false) -- shown only while it wears the hair
        SetPedHeadBlendData(ped, FACE[g], FACE[g], 0, FACE[g], FACE[g], 0, 0.0, 0.0, 0.0, false)
        SetPedHairColor(ped, HAIR[1], HAIR[2])
        bareFace(ped, true)
    end
    Wait(600)
    SetEntityCoords(ped, S.Place.x, S.Place.y, set.feet, false, false, false, false) -- exactly on the spot, standing
    FreezeEntityPosition(ped, true)
    SetPedAoBlobRendering(ped, false)
    turn(ped, 0.0)
    if bust then
        for c = 1, 11 do SetPedComponentVariation(ped, c, -1, 0, 0) end
        ClearAllPedProps(ped)
        bareFace(ped, true) -- again once the head blend has settled, which can bring overlays back
        moved()
    else
        dress(ped)
    end
    hold(ped)
    Wait(300)
    -- its soles on the platform whatever the game did with the height (the checks and the framing count from them)
    local foot = math.min(GetPedBoneCoords(ped, BONES.lfoot, 0.0, 0.0, 0.0).z, GetPedBoneCoords(ped, BONES.rfoot, 0.0, 0.0, 0.0).z)
    local off = set.feet + FOOT - foot
    if math.abs(off) > 0.15 then
        local at = GetEntityCoords(ped)
        SetEntityCoordsNoOffset(ped, at.x, at.y, at.z + off, false, false, false)
        moved()
        Wait(100)
    end
    return ped
end

local function spawnPed(g)
    remove(set.ped)
    set.ped = makePed(g)
end

-- the set floats Lift metres over Place: no ground or traffic in sight, an invisible platform to stand on. The floor is
-- found once, with the platform: the second gender's look at the ground landed on the platform itself and stood that
-- ped Lift metres over it, in the air, where it played its fall in every picture
local function build(g)
    if not (set.platform and DoesEntityExist(set.platform)) then
        RequestCollisionAtCoord(S.Place.x, S.Place.y, S.Place.z)
        local t = GetGameTimer()
        while not HasCollisionLoadedAroundEntity(cache.ped) and GetGameTimer() - t < 5000 do Wait(50) end
        local found, ground = GetGroundZFor_3dCoord(S.Place.x, S.Place.y, S.Place.z + 50.0, false)
        set.feet = (found and ground or S.Place.z) + S.Lift
        for _, name in ipairs({ "prop_helipad_01", "prop_helipad_02", "prop_dock_float_1" }) do
            local model = joaat(name)
            if IsModelInCdimage(model) then
                lib.requestModel(model, 10000)
                local _, high = GetModelDimensions(model)
                set.platform = prop(name, S.Place.x, S.Place.y, set.feet - high.z)
                SetEntityVisible(set.platform, false, false) -- unseen, it still holds the ped
                break
            end
        end
    end
    set.cam = set.cam or CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(set.cam, true)
    RenderScriptCams(true, false, 0, true, true)
    set.head = nil -- each gender finds its own empty head (ready)
    remove(set.bust)
    set.bust = nil
    spawnPed(g)
    aim(vec3(S.Place.x, S.Place.y, set.feet + 0.9), 1.0, 0.0)
end

-- the player waits under the set, unseen and frozen, and comes back where they were
local function park()
    local ped = cache.ped
    set.home = { coords = GetEntityCoords(ped), heading = GetEntityHeading(ped) }
    RequestCollisionAtCoord(S.Place.x, S.Place.y, S.Place.z)
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(ped, S.Place.x, S.Place.y + 8.0, S.Place.z, false, false, false, false)
    FreezeEntityPosition(ped, true)
    pcall(function() exports['FeloxAC']:isVisible(false) end) --[[FeloxAC:auto]]
    SetEntityVisible(ped, false, false)
    pcall(function() exports['FeloxAC']:isInvincible(true) end) --[[FeloxAC:auto]]
    SetEntityInvincible(ped, true)
    SetEntityCollision(ped, false, false)
    -- a weather sync (Renewed-Weathersync's syncWeather) would change the light mid-run
    set.sync = LocalPlayer.state.syncWeather
    if set.sync ~= nil then LocalPlayer.state:set("syncWeather", false, false) end
    SetWeatherTypeNowPersist("EXTRASUNNY")
end

local function teardown()
    view, wall = nil, KEY
    RenderScriptCams(false, false, 0, true, true)
    if set.cam then pcall(function() exports['FeloxAC']:destroyCam(set.cam) end) --[[FeloxAC:auto]] DestroyCam(set.cam, false) end
    remove(set.ped)
    remove(set.bust)
    remove(set.platform)
    local ped = cache.ped
    if set.home then
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoords(ped, set.home.coords.x, set.home.coords.y, set.home.coords.z - 1.0, false, false, false, false)
        SetEntityHeading(ped, set.home.heading)
    end
    SetEntityCollision(ped, true, true)
    pcall(function() exports['FeloxAC']:isVisible(true) end) --[[FeloxAC:auto]]
    SetEntityVisible(ped, true, false)
    pcall(function() exports['FeloxAC']:isInvincible(false) end) --[[FeloxAC:auto]]
    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ped, false)
    NetworkClearClockTimeOverride()
    ClearWeatherTypePersist()
    ClearOverrideWeather()
    -- last: the weather sync puts the server's clock and weather back when it is switched on again
    if set.sync ~= nil then LocalPlayer.state:set("syncWeather", set.sync, false) end
    set = {}
end

local function poly(a, b, c) DrawPoly(a.x, a.y, a.z, b.x, b.y, b.z, c.x, c.y, c.z, wall[1], wall[2], wall[3], 255) end

-- every frame of a run: noon, no HUD or traffic, the pause menu shut, the green wall behind the item and a soft key
-- light in front of it
local function studioLoop()
    CreateThread(function()
        local weather = 0
        while running do
            HideHudAndRadarThisFrame()
            NetworkOverrideClockTime(12, 0, 0)
            SetVehicleDensityMultiplierThisFrame(0.0)
            SetPedDensityMultiplierThisFrame(0.0)
            DisableControlAction(0, 199, true)
            DisableControlAction(0, 200, true)
            if view then
                local w = view.wall -- both windings: a poly shows from one side only
                poly(w[1], w[2], w[3])
                poly(w[1], w[3], w[4])
                poly(w[1], w[3], w[2])
                poly(w[1], w[4], w[3])
            end
            -- the bust (hair, faces) is lit from nearly straight ahead, as bright as brighten() found it needs
            local bust = set.bust and IsEntityVisible(set.bust)
            local light = bust and set.light or S.Light
            if view and light > 0 then
                local key = view.target + TOWARD * (bust and 1.3 or 1.6) + UP * (bust and 0.35 or 0.9)
                DrawLightWithRange(key.x, key.y, key.z, 255, 250, 242, 6.0, light)
            end
            if GetGameTimer() > weather then
                SetWeatherTypeNowPersist("EXTRASUNNY")
                weather = GetGameTimer() + 10000
            end
            Wait(0)
        end
    end)
end

-- ---- checks ----------------------------------------------------------------------------------------------------------
-- one look at the view. A failed capture (the game minimised, a hitch) is tried again; when the view stays unreadable
-- the run stops (nil) instead of calling items empty
local function look()
    for _ = 1, 10 do
        local r = Citizen.Await(snap("probe"))
        if not r.error then return r end
        Wait(500)
    end
    print("[photo studio] the game view cannot be read (keep the game window in front): stopping")
    stopping, stats.blind = true, true
end

-- whether and how the view can be read: the game draws a magenta mark in the frame's top left corner (in every frame,
-- whatever the set shows) and the page looks for it in its own read of the view, else in a screenshot-basic frame
local function calibrate()
    phase("calibrating", "")
    local marking = true
    CreateThread(function()
        while marking and running do
            DrawRect(0.06, 0.1, 0.08, 0.12, 255, 0, 255, 255)
            Wait(0)
        end
    end)
    direct = true
    local r = lab("calib", {})
    if r.ok ~= true and GetResourceState("screenshot-basic") == "started" then
        print(("[photo studio] the page cannot read the game view itself (%s): trying screenshot-basic"):format(tostring(r.error)))
        direct = false
        r = Citizen.Await(snap("calib"))
    end
    marking = false
    moved()
    if r.ok == true then
        print("[photo studio] game view: " .. (direct and "read by the page" or "screenshot-basic (slow, about 2 s a picture)"))
        return true
    end
    print(("[photo studio] the game view cannot be read: %s"):format(tostring(r.error)))
    if direct then print("[photo studio] (screenshot-basic is not running; ensure it to try the slower way)") end
    return false
end

-- the empty ped against the wall: nothing may show anywhere the camera will look (its bones, as the items are framed).
-- Returns the zones that do.
local ZONES = { { "head", { "head" }, 0.35 }, { "chest", { "chest" }, 0.45 }, { "hips", { "pelvis" }, 0.5 }, { "feet", { "lfoot", "rfoot" }, 0.4 } }
local function dirty()
    local bad = {}
    for _, z in ipairs(ZONES) do
        aim(anchor(set.ped, z[2]), z[3], 0.0)
        Wait(200)
        local r = look()
        if not r or (r.box and r.cover > 0.0005) then bad[#bad + 1] = z[1] end
    end
    return bad
end

-- the empty heads to try: no head at all (needs the client setting allowEmptyHeadDrawable), then the studio head (its
-- collection loads when the player joins)
local function heads(ped, g)
    local list = {}
    SetPedComponentVariation(ped, 0, -1, 0, 0)
    if GetPedDrawableVariation(ped, 0) == -1 then list[#list + 1] = -1 end
    local studio = GetPedDrawableGlobalIndexFromCollection(ped, 0, HEADS[g], 0)
    if studio >= 0 then list[#list + 1] = studio end
    return list
end

local function only(bad, allowed)
    for _, zone in ipairs(bad) do
        if not allowed[zone] then return false end
    end
    return true
end

local function headName(head) return head == -1 and "no head (allowEmptyHeadDrawable)" or "the studio head" end

-- the slots the game kept a piece in although the invisible ped has none there
local function kept(ped)
    local out = {}
    for _, slot in ipairs(ORDER) do
        local c = COMPS[slot]
        if c and GetPedDrawableVariation(ped, c) ~= -1 then out[#out + 1] = slot end
    end
    return out
end

-- the set must be clean before a run: the first empty head that leaves nothing in view anywhere the camera looks (a
-- visible head also shows at the chest: its chin and neck)
local function ready(g)
    phase("checking", "")
    local list = heads(set.ped, g)
    if #list == 0 then
        print("[photo studio] the studio head is not loaded: reconnect once (a new clothing collection loads when you join)")
        notify("rejoin", "error")
        return false
    end
    local bad = {}
    for _, head in ipairs(list) do
        set.head = head
        dress(set.ped)
        Wait(300)
        bad = dirty()
        if stopping then return false end -- the view could not be read
        if #bad == 0 then
            print("[photo studio] empty head: " .. headName(head))
            return true
        end
        print(("[photo studio] %s: something shows at %s"):format(headName(head), table.concat(bad, ", ")))
    end
    set.head = nil
    dress(set.ped)
    if only(bad, { head = true, chest = true }) then
        print("[photo studio] the empty head still shows something at: " .. table.concat(bad, ", "))
        notify("headVisible", "error")
    else
        local w = kept(set.ped)
        print("[photo studio] something besides the clothes shows on the set: " .. table.concat(bad, ", ")
            .. (#w > 0 and "; the game kept a piece in " .. table.concat(w, ", ") or ""))
        notify("screen", "error")
    end
    return false
end

-- ---- framing ---------------------------------------------------------------------------------------------------------
-- the side that shows most of the item; nil when no side shows anything
local function bestSide(ped, plan)
    if #plan.sides == 1 then return plan.sides[1] end
    local best, most = nil, 0.0
    for _, side in ipairs(plan.sides) do
        turn(ped, side)
        Wait(120)
        aim(anchor(ped, plan.bones), plan.half * 1.3, plan.rise)
        Wait(80)
        local r = look()
        if not r then return end
        local cover = r.box and r.cover or 0.0
        if cover > most * 1.15 then best, most = side, cover end
    end
    return best
end

-- the item's outline from a green and a pink look (a green item has holes in the green key)
local function outline()
    pair = pair + 1
    snap("hold", { pair = pair })
    wall = PINK
    moved()
    local r = Citizen.Await(snap("probe", { pair = pair }))
    wall = KEY
    moved()
    return r
end

-- GTA's "none" pieces (no mask, bag, glasses, undershirt, hair ...) are one flat 3 cm square: an item this small whose
-- outline fills its box is one of them (narrower when seen from a side)
local function flat(r, need)
    if need >= 0.04 then return false end
    if direct then r = outline() end
    local b = r.box
    return b ~= nil and math.min(b.w, b.h) > math.max(b.w, b.h) * 0.8 and r.cover * r.w * r.h > b.w * b.h * 0.9
end

-- aims at the item's bones, then follows what the page sees until the item fills Fill of the picture and the next
-- look agrees; false when nothing shows, "none" when GTA's empty square does
local function locate(ped, plan)
    local target, half, settled = anchor(ped, plan.bones), plan.half, false
    for _ = 1, 7 do
        aim(target, half, plan.rise)
        Wait(80)
        local r = look()
        if not r then return false end
        if not r.box then
            if half > 1.0 then return false end
            half, settled = half * 1.8, false
        else
            local mpp = 2.0 * view.dist * math.tan(math.rad(view.fov) / 2.0) / r.h -- metres per pixel on the target's plane
            target = target + RIGHT * ((r.box.x + r.box.w / 2.0 - r.w / 2.0) * mpp) + view.up * ((r.h / 2.0 - r.box.y - r.box.h / 2.0) * mpp)
            local need = math.max(r.box.w, r.box.h) / 2.0 * mpp
            if r.edge then
                if half >= 1.6 then -- as wide as the set allows: shoot it as it is
                    aim(target, half, plan.rise)
                    return true
                end
                half, settled = math.min(1.6, math.max(half * 1.6, need * 1.3)), false
            else
                local tight = math.max(0.025, need / S.Fill)
                if settled and math.abs(tight - half) < half * 0.06 then
                    -- GTA's empty squares are base game pieces only: in a DLC or a pack a small square is a real item
                    if plan.flat ~= false and set.base and flat(r, need) then return "none" end
                    aim(target, tight, plan.rise)
                    return true
                end
                half, settled = tight, true
            end
        end
    end
    aim(target, half, plan.rise)
    return settled
end

-- an item that shows nothing from its usual side is looked for all around the ped, from level, above and below: first a
-- wide view of its own area, then of the whole body. Returns the plan to frame it with (that height) and the side, or
-- nil when it shows nowhere
local SWEEP = { sides = { 0, 180, 90, -90, 45, -45, 135, -135 }, rises = { 0, 40, -30 } }
local function sweep(ped, plan)
    local areas = { { bones = plan.bones, half = math.max(0.9, plan.half * 1.8), rises = SWEEP.rises },
        { bones = { "spine" }, half = 1.15, rises = { 0 } } }
    for _, area in ipairs(areas) do
        for _, rise in ipairs(area.rises) do
            for _, side in ipairs(SWEEP.sides) do
                if stopping then return end
                turn(ped, side)
                Wait(60)
                aim(anchor(ped, area.bones), area.half, rise)
                Wait(40)
                local r = look()
                if not r then return end
                if r.box then
                    return { bones = area.bones, half = area.half, rise = rise, sides = { side }, flat = plan.flat }, side
                end
            end
        end
    end
end

-- puts the item on, finds its best side and frames it; "unloaded" when it did not stream in (that says nothing about
-- the item: a retry run looks again), false when it loaded and the game draws nothing from any side, "none" for GTA's
-- empty square
local function frame(it, tex, wait)
    local ped = set.ped
    if not wear(ped, it, tex, wait) then return "unloaded" end
    Wait(250)
    local plan = PLAN[it.slot]
    local side = bestSide(ped, plan)
    local found = false
    if side then
        turn(ped, side)
        Wait(150)
        found = locate(ped, plan)
    end
    -- nothing where it should be: look all around (a decal goes on a top instead, see onTop)
    if found == false and it.slot ~= "decl" and not stopping then
        local p, s = sweep(ped, plan)
        if p then
            turn(ped, s)
            Wait(150)
            found, side = locate(ped, p), s
            if found == true then print(("[photo studio] %s_%03d found from side %d, height %d"):format(it.slot, it.idx, s, p.rise)) end
        end
    end
    return found, side
end

-- a decal that shows nothing on its own goes on a top: on each host top and from the front and the back the view is
-- compared without and with it, and the one where it changes most wins. The camera then frames that change (the decal
-- and a little of the top around it), not the whole top. true, the side and the host top; "none" when it changes
-- nothing on any of them (the picture would show the top alone)
local DECAL_SEEN = 0.0002 -- share of the view a decal must change (a 2 cm sleeve patch is about 0.0004)
local function onTop(it, tex, wait, hosts)
    local ped = set.ped
    local best
    for _, host in ipairs(hosts) do
        if stopping then return false end
        if not wear(ped, it, tex, wait, host) then return "unloaded" end
        Wait(250)
        for _, side in ipairs({ 0, 180 }) do
            turn(ped, side)
            Wait(120)
            aim(anchor(ped, { "spine" }), 0.55)
            Wait(80)
            SetPedComponentVariation(ped, it.comp, -1, 0, 0)
            moved()
            local before = Citizen.Await(snap("ref"))
            recolour(ped, it, tex)
            local r = Citizen.Await(snap("diff"))
            if not before.error and not r.error and r.box and r.changed > DECAL_SEEN and (not best or r.changed > best.r.changed) then
                best = { host = host, side = side, r = r }
            end
        end
    end
    if not best then return "none" end
    if best.host ~= hosts[#hosts] and not wear(ped, it, tex, wait, best.host) then return "unloaded" end
    turn(ped, best.side)
    Wait(150)
    aim(anchor(ped, { "spine" }), 0.55)
    local r, b = best.r, best.r.box
    local mpp = 2.0 * view.dist * math.tan(math.rad(view.fov) / 2.0) / r.h
    local target = view.target + RIGHT * ((b.x + b.w / 2.0 - r.w / 2.0) * mpp) + view.up * ((r.h / 2.0 - b.y - b.h / 2.0) * mpp)
    aim(target, math.min(0.55, math.max(0.14, math.max(b.w, b.h) / 2.0 * mpp * 1.8)))
    Wait(80)
    return true, best.side, best.host
end

-- hair: once the invisible ped has shown it is no empty piece, the bust wears it for its pictures; true when it shows
-- the bust's light: the bright green wall sets the game's exposure and leaves a face dark, so the light grows until the
-- bare head reads about BRIGHT (0-255, the mean of what the camera sees of it)
local BRIGHT = 135
local function brighten(ped)
    set.light = set.light or S.Light
    if S.Light <= 0 then return end
    turn(ped, 0.0)
    locate(ped, { bones = { "head" }, half = 0.3, sides = { 0 } })
    for _ = 1, 5 do
        Wait(150)
        local r = look()
        if not (r and r.lum and r.lum > 0) or math.abs(r.lum - BRIGHT) < 12 then return end
        set.light = math.min(S.Light * 12.0, math.max(S.Light, set.light * (BRIGHT / r.lum) ^ 2))
        moved()
    end
end

local function onBust(g, it, tex, side)
    SetPedComponentVariation(set.ped, it.comp, -1, 0, 0) -- off the invisible ped
    for _ = 1, 2 do
        if not (set.bust and DoesEntityExist(set.bust)) then
            set.bust = makePed(g, true)
            SetEntityVisible(set.bust, true, false)
            brighten(set.bust) -- still bald
        end
        SetEntityVisible(set.bust, true, false)
        if recolour(set.bust, it, tex, load.again) then
            turn(set.bust, side)
            Wait(250)
            if locate(set.bust, PLAN[it.slot]) == true then return true end
        end
        if stopping then return false end
        remove(set.bust) -- not streamed in: once more on a fresh bust
        set.bust = nil
    end
    return false
end

-- ---- what to shoot ---------------------------------------------------------------------------------------------------
-- every clothing collection the game has loaded for this ped: { name, folder, items = { slot, idx, global, tex, comp|prop } }
local function collections(ped, g)
    local list = {}
    for i = 0, GetPedCollectionsCount(ped) - 1 do
        local name = GetPedCollectionName(ped, i) or ""
        local col = { name = name, folder = client.pictureFolder(name, g), items = {} }
        for _, slot in ipairs(ORDER) do
            local c, p = COMPS[slot], PROPS[slot]
            local n = c and GetNumberOfPedCollectionDrawableVariations(ped, c, name) or GetNumberOfPedCollectionPropDrawableVariations(ped, p, name)
            for idx = 0, n - 1 do
                local it = { slot = slot, idx = idx, comp = c, prop = p }
                if c then
                    it.global = GetPedDrawableGlobalIndexFromCollection(ped, c, name, idx)
                    it.tex = GetNumberOfPedCollectionTextureVariations(ped, c, name, idx)
                else
                    it.global = GetPedPropGlobalIndexFromCollection(ped, p, name, idx)
                    it.tex = GetNumberOfPedCollectionPropTextureVariations(ped, p, name, idx)
                end
                if it.global >= 0 and it.tex > 0 then col.items[#col.items + 1] = it end
            end
        end
        if name ~= HEADS[g] then list[#list + 1] = col end -- not the studio's own empty head
    end
    return list
end

-- "lspd,lscso" / "base" / "all" -> the matching collections
local function pick(list, target)
    local out = {}
    for _, col in ipairs(list) do
        for t in target:gmatch("[^,]+") do
            t = t:lower()
            if t == "all" or (t == "base" and col.name == "") or (col.name ~= "" and col.name:lower():find(t, 1, true)) then
                out[#out + 1] = col
                break
            end
        end
    end
    return out
end

-- the server's list of a folder's pictures (false when it refused), of the items found empty and of the colours that
-- did not stream in
local answer, known, unknown
RegisterNetEvent("illenium-appearance:photostudio:state", function(folder, list, empty, unloaded)
    if folder == stats.folder then answer, known, unknown = list or false, empty or {}, unloaded or {} end
end)

-- the pictures a folder already has and the items an earlier run found empty (redo forgets both); false when the
-- server refused or did not answer
local function loadState(folder)
    stats.folder, answer = folder, nil
    TriggerServerEvent("illenium-appearance:photostudio:state", folder)
    local t = GetGameTimer()
    while answer == nil and GetGameTimer() - t < 10000 do Wait(20) end
    if not answer then return false end
    have, gone, failed = {}, {}, {}
    for _, name in ipairs(answer) do have[name] = true end
    for _, key in ipairs(known) do gone[key] = true end
    for _, key in ipairs(unknown) do failed[key] = true end
    return true
end

-- ---- run -------------------------------------------------------------------------------------------------------------
local inflight, unsaved = 0, 0 -- pictures the page is keying; pictures sent that the server has not written yet
local manifested -- the folder whose manifest the server last confirmed
RegisterNetEvent("illenium-appearance:photostudio:manifested", function(folder) manifested = folder end)

RegisterNetEvent("illenium-appearance:photostudio:saved", function(written)
    unsaved = math.max(0, unsaved - 1)
    if written == false and running and not stopping then -- the server stopped taking pictures (restarted?)
        print("[photo studio] the server refused a picture: stopping")
        stopping = true
    end
end)

-- waits for the page and the server to be done with every picture (the manifest and the end of a run come after)
local function settle()
    if inflight > 0 or unsaved > 0 then phase("finishing") end
    while inflight > 0 do Wait(50) end
    local t = GetGameTimer()
    while unsaved > 0 and GetGameTimer() - t < 60000 do Wait(100) end
    if unsaved > 0 then print(("[photo studio] %d pictures were not confirmed by the server"):format(unsaved)) end
    unsaved = 0
end

local function progress()
    local spent = (GetGameTimer() - stats.start) / 1000
    local each = stats.done > 0 and spent / stats.done or 0
    return ("%s %d/%d, %.2f s a picture, about %d min left"):format(stats.folder, stats.done, stats.todo, each, math.ceil(each * (stats.todo - stats.done) / 60))
end

local function shoot(folder, name)
    while inflight >= 3 do Wait(10) end
    local opts = { size = S.Size, format = S.Format, quality = S.Quality, pad = S.Pad, name = folder .. "/" .. name }
    if direct then -- the green frame first, then the same view with the wall pink: the page keys the two together
        pair = pair + 1
        snap("hold", { pair = pair })
        wall, opts.pair = PINK, pair
        moved()
    end
    local job = snap("key", opts)
    wall = KEY
    moved()
    inflight = inflight + 1
    have[name] = true
    CreateThread(function()
        local r = Citizen.Await(job)
        inflight = inflight - 1
        if r.data then
            unsaved = unsaved + 1
            TriggerLatentServerEvent("illenium-appearance:photostudio:save", 5000000, folder, name, r.data)
            stats.done = stats.done + 1
            report()
            if stats.done % 50 == 0 then print("[photo studio] " .. progress()) end
        else
            have[name] = nil
            print(("[photo studio] %s/%s: %s"):format(folder, name, r.error or "nothing left after keying"))
        end
    end)
end

-- frames the item with its first missing colour that streams in (each tried once more on a fresh ped); up to three
-- colours, the ones that never loaded are noted. Returns what frame() found, the side and the colour it used
local function frameAny(g, job, unloaded)
    for i, tex in ipairs(job.missing) do
        if i > 3 or stopping then break end
        local ok, side = frame(job.it, tex, load.first)
        if ok == "unloaded" and not stopping then
            spawnPed(g)
            ok, side = frame(job.it, tex, load.again)
        end
        -- a decal that shows alone but small or sparse (a sleeve patch, a pin floating in the air) reads better on a
        -- top; when it changes no top it is shot alone after all
        if ok == true and job.hosts and not stopping then
            local r = look()
            local size = 2.0 * view.dist * math.tan(math.rad(view.fov) / 2.0) * S.Fill
            if r and (size < 0.15 or (r.cover or 0) < 0.04) then
                local on, onSide, host = onTop(job.it, tex, load.first, job.hosts)
                if on == true then
                    ok, side, job.on = on, onSide, host
                elseif not stopping then
                    ok, side = frame(job.it, tex, load.first)
                end
            end
        end
        -- a decal that loaded but shows nothing on its own: on the top it shows best on (its colours then stay there)
        if (ok == false or ok == "none") and job.hosts and not stopping then
            local host
            ok, side, host = onTop(job.it, tex, load.first, job.hosts)
            if ok == true then job.on = host end
        end
        if ok ~= "unloaded" then return ok, side, tex end
        unloaded[#unloaded + 1] = ("%s_t%d"):format(job.key, tex)
        job.skip[tex] = true
    end
    return "unloaded"
end

-- retry: only the items an earlier run found empty and the colours that did not load, with longer waits
local function runCollection(g, col, slot, firstOnly, retry)
    if not col.folder:find("^[a-z0-9_]+$") then
        return print(("[photo studio] %s: the collection's name cannot be a folder name, skipped"):format(col.folder))
    end
    if not loadState(col.folder) then
        print(("[photo studio] %s: the server did not answer or refused: stopping"):format(col.folder))
        stopping = true
        return
    end
    set.base = col.folder:find("^base_") ~= nil
    load.first = retry and LOAD.retryFirst or LOAD.first
    load.again = retry and LOAD.retryAgain or LOAD.again
    local jobs, total, info, empty, unloaded, tried = {}, 0, {}, {}, {}, {}
    -- the tops a decal that shows nothing on its own is tried on: GTA's first (a plain T-shirt) and the collection's
    -- first (decals are made for their collection's tops); the one it shows best on is used
    local hosts = { 0 }
    for _, it in ipairs(col.items) do
        if it.slot == "jbib" then
            if it.global ~= 0 then hosts[2] = it.global end
            break
        end
    end
    for _, it in ipairs(col.items) do
        local key = ("%s_%03d"):format(it.slot, it.idx)
        info[key] = { textures = it.tex } -- every item's colour count; the side is added when it is shot
        if not slot or it.slot == slot then
            local missing = {}
            for tex = 0, firstOnly and 0 or it.tex - 1 do
                local name = ("%s_t%d"):format(key, tex)
                local want
                if retry then want = gone[key] or failed[name] else want = not gone[key] and not failed[name] end
                if want and not have[name .. "_a000"] then missing[#missing + 1] = tex end
            end
            if #missing > 0 then
                jobs[#jobs + 1] = { it = it, key = key, missing = missing, skip = {}, hosts = it.slot == "decl" and hosts or nil }
                total = total + #missing
            end
        end
    end
    stats.done, stats.todo, stats.start = 0, total, GetGameTimer()
    print(("[photo studio] %s: %d items, %d pictures to take%s"):format(col.folder, #jobs, total, retry and " (retry)" or ""))
    phase("shooting", col.folder)
    report()
    for n, job in ipairs(jobs) do
        if stopping then break end
        if n % 25 == 0 then
            spawnPed(g)
            remove(set.bust)
            set.bust = nil
        end
        local ok, side, first = frameAny(g, job, unloaded)
        if stopping then break end -- an unreadable view says nothing about the item
        for _, tex in ipairs(job.missing) do tried[#tried + 1] = ("%s_t%d"):format(job.key, tex) end
        local ped = set.ped
        if ok == true and job.it.slot == "hair" then
            ok = onBust(g, job.it, first, side)
            ped = set.bust
        end
        if ok == "unloaded" then -- it never streamed in: not empty, a retry run looks again
            stats.unloaded = stats.unloaded + 1
            stats.todo = stats.todo - #job.missing
            report()
            print(("[photo studio] %s %s did not load, left for a retry run"):format(col.folder, job.key))
        elseif ok ~= true then -- it loaded and showed nothing from any side, or GTA's "none" piece: no picture
            local it, why = job.it, ""
            if it.comp then
                local okG9, g9 = pcall(IsPedComponentVariationGen9Exclusive, set.ped, it.comp, it.global)
                why = (" valid %s, %d colours%s"):format(tostring(IsPedComponentVariationValid(set.ped, it.comp, it.global, 0)),
                    GetNumberOfPedTextureVariations(set.ped, it.comp, it.global), okG9 and g9 and ", PS5/XS only (PC draws nothing)" or "")
            end
            print(("[photo studio] %s %s (global %d): %s;%s"):format(col.folder, job.key, it.global, ok == "none" and "GTA's empty piece"
                or "nothing shows from any side", why))
            empty[#empty + 1] = job.key
            stats.empty = stats.empty + 1
            stats.todo = stats.todo - #job.missing
            report()
        else
            -- the colour it was framed with first, then the others but those that did not load already
            local order = { first }
            for _, tex in ipairs(job.missing) do
                if tex ~= first and not job.skip[tex] then order[#order + 1] = tex end
            end
            stats.todo = stats.todo - (#job.missing - #order)
            for i, tex in ipairs(order) do
                if stopping or not ped then break end
                local shown = true
                if i > 1 then
                    shown = recolour(ped, job.it, tex, load.first)
                    if not shown then -- the colour did not stream in: once more on a fresh ped in the same pose
                        if ped == set.bust then
                            remove(set.bust)
                            set.bust = nil
                            shown = onBust(g, job.it, tex, side)
                            ped = set.bust
                        else
                            spawnPed(g)
                            ped = set.ped
                            shown = wear(ped, job.it, tex, load.again, job.on)
                            turn(ped, side)
                            Wait(250)
                        end
                    end
                    Wait(120)
                end
                -- a colour that never streamed in would be saved showing the one before: noted for a retry run
                if shown then
                    shoot(col.folder, ("%s_t%d_a000"):format(job.key, tex))
                else
                    unloaded[#unloaded + 1] = ("%s_t%d"):format(job.key, tex)
                    stats.todo = stats.todo - 1
                    report()
                    print(("[photo studio] %s %s colour %d did not load, left for a retry run"):format(col.folder, job.key, tex))
                end
            end
            info[job.key].angle = side
        end
        if set.bust then SetEntityVisible(set.bust, false, false) end -- only hair shows on it
    end
    settle()
    -- the manifest is large and goes latent: wait for the server to confirm it, or the run's end (which closes the
    -- server's door) could overtake it and the last collection's manifest would be refused
    manifested = nil
    TriggerLatentServerEvent("illenium-appearance:photostudio:manifest", 1000000, col.folder,
        { collection = col.name, gender = g, size = S.Size, format = S.Format, items = info, empty = empty,
            unloaded = unloaded, tried = tried })
    local sent = GetGameTimer()
    while manifested ~= col.folder and GetGameTimer() - sent < 60000 do Wait(100) end
    if manifested ~= col.folder then print(("[photo studio] %s: the server did not confirm the manifest"):format(col.folder)) end
    if #unloaded > 0 then print(("[photo studio] %s: %d colours did not load (/%s retry)"):format(col.folder, #unloaded, S.Command)) end
    print("[photo studio] " .. progress())
end

-- ---- faces -----------------------------------------------------------------------------------------------------------
-- the editor's face cards, shot on the bust into head_m / head_f: every parent's face (face_<n>, n its head blend number)
-- and the face looks the editor lists as cards. A look is a head overlay: its colour type and colour, where the camera
-- looks and how much it shows (half height, metres)
-- DARK (with bareFace): brows, beard and chest hair in a near black, which shows on any skin
local LOOKS = {
    { slot = "brows", overlay = 2, colour = { 1, DARK }, bones = { "lbrow", "rbrow", "leye", "reye" }, half = 0.085 },
    { slot = "makeup", overlay = 4, colour = { 2, 0 }, bones = { "leye", "reye" }, half = 0.085 },
    { slot = "blush", overlay = 5, colour = { 2, 1 }, bones = { "lcheek", "rcheek" }, half = 0.11 },
    { slot = "lipstick", overlay = 8, colour = { 2, 3 }, bones = { "upperlip", "lowerlip" }, half = 0.07 },
    { slot = "beard", overlay = 1, colour = { 1, DARK }, bones = { "jaw", "lowerlip" }, half = 0.12 },
    { slot = "chest", overlay = 10, colour = { 1, DARK }, bones = { "chest" }, half = 0.3, body = true },
}
-- BROWS (with bareFace): the brows every card wears but the brows' own

-- skin tones (tone_<n>, the editor's Skin › Tone cards): a close look at the cheek of the bust's own face wearing skin
-- n, nothing but skin in the picture. Fades (fade_<i>, i the editor's index in the gender's ZONE_HAIR list): the bald
-- bust wearing that hair tattoo, seen from behind its right side
local TONES = 46
local TONE = { slot = "tone", bones = { "lcheek" }, half = 0.03, bare = true }
local FADE = { slot = "fade", bones = { "head" }, half = 0.16, side = 145, rise = 12, bare = true }

local function fades(g)
    local out, key = {}, g == "f" and "hashFemale" or "hashMale"
    for _, tat in ipairs(Config.Tattoos and Config.Tattoos.ZONE_HAIR or {}) do
        if tat[key] and tat[key] ~= "" then out[#out + 1] = { collection = tat.collection, hash = tat[key] } end
    end
    return out
end

-- the bust as parent n (face and skin; skin its own when given) with the brows on and one look (style) or none; chest
-- hair needs the bare torso; a fade (a hair tattoo) goes on after the face is bare
local function face(ped, n, look, style, skin, fade)
    -- an added face (46 and up) has no skin of its own (a skin past 45 blends no face at all): it wears the bust's
    skin = skin or n
    if skin >= TONES then skin = GetEntityModel(ped) == `mp_f_freemode_01` and FACE.f or FACE.m end
    local id = n .. ":" .. skin
    if set.face ~= id then
        SetPedHeadBlendData(ped, n, n, 0, skin, skin, 0, 0.0, 0.0, 0.0, false)
        local t = GetGameTimer()
        while not HasPedHeadBlendFinished(ped) and GetGameTimer() - t < 3000 do Wait(0) end
        set.face = id
    end
    bareFace(ped, not (look and (look.overlay == 2 or look.bare)))
    if look and look.overlay then
        SetPedHeadOverlay(ped, look.overlay, style, 1.0)
        SetPedHeadOverlayColor(ped, look.overlay, look.colour[1], look.colour[2], look.colour[2])
    end
    if fade then AddPedDecorationFromHashes(ped, joaat(fade.collection), joaat(fade.hash)) end
    SetPedComponentVariation(ped, 3, look and look.body and 15 or -1, 0, 0)
    moved()
end

-- faces: the whole head, as the first one fills the picture (all faces keep that framing); a look: its part of the face
local function frameHead(ped, look)
    turn(ped, look and look.side or 0.0)
    Wait(150)
    if not look then return locate(ped, { bones = { "head" }, half = 0.3, sides = { 0 } }) == true end
    local at = anchor(ped, look.bones)
    if not look.body and #(at - GetPedBoneCoords(ped, BONES.head, 0.0, 0.0, 0.0)) > 0.35 then -- a bone this head lacks
        at = GetPedBoneCoords(ped, BONES.head, 0.0, 0.0, 0.0)
    end
    aim(at, look.half, look.rise or 0.0)
    return true
end

local function runHead(g)
    local folder = "head_" .. g
    if not loadState(folder) then
        print(("[photo studio] %s: the server did not answer or refused: stopping"):format(folder))
        stopping = true
        return
    end
    if not (set.bust and DoesEntityExist(set.bust)) then set.bust = makePed(g, true) end
    local ped = set.bust
    SetEntityVisible(ped, true, false)
    set.face = nil
    face(ped, FACE[g])
    brighten(ped)
    -- every head the game has but the studio's own empty one, then every style of every look
    local jobs, todo, info = {}, {}, {}
    local studio = GetPedDrawableGlobalIndexFromCollection(ped, 0, HEADS[g], 0)
    for n = 0, GetNumberOfPedDrawableVariations(ped, 0) - 1 do
        if n ~= studio then jobs[#jobs + 1] = { slot = "face", n = n } end
    end
    for _, look in ipairs(LOOKS) do
        for n = 0, GetPedHeadOverlayNum(look.overlay) - 1 do jobs[#jobs + 1] = { slot = look.slot, n = n, look = look } end
    end
    for n = 0, TONES - 1 do jobs[#jobs + 1] = { slot = "tone", n = n, look = TONE, skin = n } end
    for i, fade in ipairs(fades(g)) do jobs[#jobs + 1] = { slot = "fade", n = i - 1, look = FADE, fade = fade } end
    for _, job in ipairs(jobs) do
        job.key = ("%s_%03d"):format(job.slot, job.n)
        info[job.key] = { textures = 1 }
        if not have[job.key .. "_t0_a000"] then todo[#todo + 1] = job end
    end
    stats.done, stats.todo, stats.start = 0, #todo, GetGameTimer()
    print(("[photo studio] %s: %d faces and looks, %d pictures to take"):format(folder, #jobs, #todo))
    phase("faces", folder)
    report()
    local framed
    for _, job in ipairs(todo) do
        if stopping then break end
        face(ped, job.look and FACE[g] or job.n, job.look, job.n, job.skin, job.fade)
        if framed ~= job.slot then
            if not frameHead(ped, job.look) then break end
            framed = job.slot
        end
        Wait(100)
        shoot(folder, job.key .. "_t0_a000")
    end
    settle()
    SetEntityVisible(ped, false, false)
    TriggerServerEvent("illenium-appearance:photostudio:manifest", folder,
        { collection = "head", gender = g, size = S.Size, format = S.Format, items = info, empty = {} })
    print("[photo studio] " .. progress())
end

local function runAll(target, genders, slot, firstOnly, retry)
    park()
    studioLoop()
    for n, g in ipairs(genders) do
        build(g)
        if n == 1 and not calibrate() then return notify("capture", "error") end
        if not ready(g) then return end
        if target == "faces" then
            runHead(g)
        else
            local cols = pick(collections(set.ped, g), target)
            if #cols == 0 then print(("[photo studio] no %s collection matches %s (see the list action)"):format(g, target)) end
            for _, col in ipairs(cols) do
                runCollection(g, col, slot, firstOnly, retry)
                if stopping then return end
            end
        end
        if stopping then return end
    end
end

local function start(target, gender, extra, retry)
    if running then return notify("busy", "error") end
    if not target or (retry and target == "faces") then
        print(("[photo studio] usage: /%s run <collection[,collection] | base | all> [m | f | both] [slot | first]"):format(S.Command))
        return notify("usage", "inform", S.Command)
    end
    if client.isCustomizing() then return notify("editorOpen", "error") end
    if IsPedInAnyVehicle(cache.ped, false) then return notify("vehicle", "error") end
    if gender and gender ~= "m" and gender ~= "f" and gender ~= "both" then
        print(("[photo studio] the gender is m, f or both (got %s); usage: /%s run <collections> [m | f | both] [slot | first]"):format(gender, S.Command))
        return notify("usage", "inform", S.Command)
    end
    local slot = extra ~= "first" and extra or nil
    if slot and not PLAN[slot] then
        print("[photo studio] unknown slot " .. slot .. "; slots: " .. table.concat(ORDER, " "))
        return notify("usage", "inform", S.Command)
    end
    local genders = gender == "m" and { "m" } or gender == "f" and { "f" } or { "m", "f" }
    running, stopping = true, false
    stats.empty, stats.unloaded, stats.blind = 0, 0, false
    -- the server lets this player write pictures from now on (it checks the admin right again)
    TriggerServerEvent("illenium-appearance:photostudio:started")
    notify("started", "inform", target)
    -- the screen goes up before the player is parked, so the set is never seen
    ui({ on = true, reset = true, labels = _L("photostudio.ui"), phase = _L("photostudio.ui.calibrating"), folder = "",
        done = 0, todo = 0, each = 0, left = 0, empty = 0 })
    CreateThread(function()
        local ok, err = pcall(runAll, target, genders, slot, extra == "first", retry)
        if not ok then print("[photo studio] stopped by an error: " .. tostring(err)) end
        settle()
        teardown()
        ui({ on = false })
        TriggerServerEvent("illenium-appearance:photostudio:finished")
        running = false
        notify(stats.blind and "capture" or stopping and "stopped" or "finished", stats.blind and "error" or "success", stats.empty)
        if not stats.blind and stats.unloaded > 0 then notify("unloaded", "warning", stats.unloaded, S.Command) end
    end)
end

-- the collections this game has for a gender, with item counts
local function list(gender)
    local g = gender == "f" and "f" or "m"
    local model = g == "f" and `mp_f_freemode_01` or `mp_m_freemode_01`
    lib.requestModel(model, 10000)
    local c = GetEntityCoords(cache.ped)
    pcall(function() exports['FeloxAC']:CreatePed(model) end) --[[FeloxAC:auto]]
    local ped = CreatePed(4, model, c.x, c.y, c.z - 20.0, 0.0, false, false)
    SetModelAsNoLongerNeeded(model)
    SetEntityVisible(ped, false, false)
    FreezeEntityPosition(ped, true)
    for _, col in ipairs(collections(ped, g)) do
        local pictures = 0
        for _, it in ipairs(col.items) do pictures = pictures + it.tex end
        print(("[photo studio] %-44s %5d items %6d pictures"):format(col.folder, #col.items, pictures))
    end
    DeleteEntity(ped)
end

-- how to use the command: every form in F8, the first step as a notice
local function usage()
    for _, line in ipairs({
        "/%s run <collection[,collection] | base | all> [m | f | both] [slot | first]   shoot what is missing",
        "/%s retry <collection[,collection] | base | all> [m | f | both] [slot | first]   only what did not load or showed nothing before, with longer waits",
        "/%s run faces [m | f | both]   the parents' faces and the face looks (brows, beard, chest hair, makeup) for the editor",
        "/%s stop | status | list [m | f]   stop after the item, progress, the collections this game has",
        "/%s redo <folder | all | all_m | all_f> [slot] [idx]   shoot again on the next run, e.g. redo base_m jbib 4, redo all decl",
    }) do print("[photo studio] " .. line:format(S.Command)) end
    notify("usage", "inform", S.Command)
end

RegisterNetEvent("illenium-appearance:client:photostudio", function(action, a, b, c)
    if action == "run" then
        start(a, b, c)
    elseif action == "retry" then
        start(a, b, c, true)
    elseif action == "stop" then
        if running then
            stopping = true
            phase("stopping")
            print("[photo studio] stopping after the current item")
            notify("stopping", "inform")
        else
            notify("idle", "inform")
        end
    elseif action == "status" then
        print("[photo studio] " .. (running and progress() or "not running"))
        if running then
            local each = stats.done > 0 and (GetGameTimer() - stats.start) / 1000 / stats.done or 0
            notify("progress", "inform", stats.folder, stats.done, stats.todo, math.ceil(each * (stats.todo - stats.done) / 60))
        else
            notify("idle", "inform")
        end
    elseif action == "list" then
        list(a)
        notify("listed", "inform")
    else
        usage()
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() or not running then return end
    teardown()
    TriggerServerEvent("illenium-appearance:photostudio:finished")
end)
