-- Photo mode and character camera data both sides share: framings, lenses, poses, filters and the framing math.
-- No natives, so tests run it.
PMShared = PMShared or {}
local Photo = {}
PMShared.Photo = Photo

-- In the UI's order (indices on the wire are 0-based, as the UI keeps them).
Photo.LENSES = { 24, 35, 50, 85, 135 }
Photo.MOVES = { 'free', 'orbit' }
Photo.POSES = { 'none', 'hips', 'crossed', 'lean', 'victory' }
Photo.FILTERS = { 'none', 'cinematic', 'faded', 'warm', 'bw', 'night' }

-- dist: metres from the camera to the aim point (the design's numbers); the aim point is a ped bone (head 31086,
-- spine 24818, pelvis 11816) raised by aimZ; camZ: camera height over the aim point.
Photo.FRAMINGS = {
    { id = 'portrait', dist = 1.7, bone = 24818, aimZ = 0.15, camZ = 0.05 },
    { id = 'close', dist = 0.9, bone = 31086, aimZ = 0.02, camZ = 0.02 },
    { id = 'half', dist = 1.3, bone = 24818, aimZ = 0.0, camZ = 0.1 },
    { id = 'full', dist = 3.2, bone = 11816, aimZ = -0.05, camZ = 0.15 },
    { id = 'low', dist = 2.2, bone = 24818, aimZ = 0.0, camZ = -0.95 },
    { id = 'high', dist = 2.4, bone = 24818, aimZ = 0.0, camZ = 1.2 },
}

-- Pose animations (dict, clip, flag) and filters (timecycle modifier, strength); Config.Photo can replace them.
Photo.POSE_ANIMS = {
    hips = { 'random@shop_tattoo', '_idle_a', 1 },
    crossed = { 'amb@world_human_hang_out_street@female_arms_crossed@idle_a', 'idle_a', 1 },
    lean = { 'amb@world_human_leaning@male@wall@back@foot_up@idle_a', 'idle_a', 1 },
    victory = { 'rcmfanatic1celebrate', 'celebrate', 1 },
}
Photo.FILTER_MODS = {
    cinematic = { 'cinema', 1.0 },
    faded = { 'hud_def_desat_Neutral', 1.0 },
    warm = { 'glasses_orange', 0.6 },
    bw = { 'CAMERA_BW', 1.0 },
    night = { 'glasses_Darkblue', 0.8 },
}

-- The design's starting values, and the highest value of each (all start at 0).
Photo.DEFAULTS = { fr = 0, mv = 0, lock = 1, spd = 4, foc = 1, shake = 8, pose = 0, filt = 0 }
Photo.MAX = { fr = 5, mv = 1, lock = 1, spd = 10, foc = 4, shake = 10, pose = 4, filt = 5 }

-- Where the design stands the character on the 1920x1080 stage (left, top, width, height): home and photo mode. The
-- other screens have none: the sub screens sit in the middle over the blurred game, the map over GTA's own map. Kept
-- equal to the page's copy in web/apps/pausemenu/src/stage.ts.
Photo.BOXES = { pause = { 930, 196, 400, 760 }, photo = { 650, 150, 520, 900 } }

-- The ped's box on a screen, or nil for none.
function Photo.box(screen)
    return Photo.BOXES[screen]
end

-- Screens the design blurs and dims behind its panels.
Photo.SUB = { stats = true, settings = true, rules = true }

function Photo.defaults()
    local out = {}
    for key, value in pairs(Photo.DEFAULTS) do out[key] = value end
    return out
end

-- A value from the UI for one key: a whole number in range, or nil.
function Photo.normalize(key, value)
    local max = type(key) == 'string' and Photo.MAX[key]
    value = tonumber(value)
    if not max or not value or value ~= value or value % 1 ~= 0 or value < 0 or value > max then return nil end
    return math.floor(value)
end

-- Full-frame lens: vertical field of view in degrees for a focal length in mm (24 mm sensor height), and back.
function Photo.vfov(mm)
    return math.deg(2 * math.atan(12 / mm))
end

function Photo.focal(vfov)
    return 12 / math.tan(math.rad(vfov) / 2)
end

-- The lens button nearest to a field of view (0-based).
function Photo.lensIndex(vfov)
    local mm, best, gap = Photo.focal(vfov), 0, math.huge
    for i, lens in ipairs(Photo.LENSES) do
        local d = math.abs(math.log(mm / lens))
        if d < gap then best, gap = i - 1, d end
    end
    return best
end

-- A stage box on a w x h screen, letterboxed like the page: centre x and y as screen fractions, and height share.
function Photo.boxOnScreen(box, w, h)
    local k = math.min(w / 1920, h / 1080)
    local offX, offY = (w - 1920 * k) / 2, (h - 1080 * k) / 2
    return (offX + (box[1] + box[3] / 2) * k) / w, (offY + (box[2] + box[4] / 2) * k) / h, box[4] * k / h
end

-- Sideways shift of the aim point that puts something d metres away at screen fraction s (0.5 = centre).
function Photo.shift(d, vfov, aspect, s)
    local hHalf = math.atan(math.tan(math.rad(vfov) / 2) * aspect)
    return d * math.tan(hHalf) * (2 * s - 1)
end

-- Distance at which a body `height` metres tall fills `share` of the screen height.
function Photo.fitDistance(height, share, vfov)
    return height / (share * 2 * math.tan(math.rad(vfov) / 2))
end

-- Sharp band (near, far) around a subject `dist` metres away (thin lens, 0.03 mm circle of confusion).
function Photo.dofPlanes(dist, vfov, aperture)
    local f, c = Photo.focal(vfov) / 1000, 0.00003
    local hyper = f * f / (aperture * c) + f
    local near = dist * (hyper - f) / (hyper + dist - 2 * f)
    local far = hyper > dist and dist * (hyper - f) / (hyper - dist) or 1000.0
    if far - near < 0.4 then
        local mid = (near + far) / 2
        near, far = mid - 0.2, mid + 0.2
    end
    return math.max(0.05, near), math.min(far, 1000.0)
end

-- Camera speed factor for the speed bar (the design shows spd / 4) and the hand shake amplitude (100% = 0.15).
function Photo.speed(spd)
    return spd / 4
end

function Photo.shakeAmp(shake, scale)
    return 0.15 * (tonumber(scale) or 1.0) * shake / 10
end
