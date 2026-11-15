-- Camera maths without natives: easing, Catmull-Rom channels, angles and the scene's local frame.
-- Poses are { x, y, z, rx, ry, rz, fov } in world space (rotation order 2); keys are { pos, look | rot, fov, ms?, cut? }.
do
    CamMath = {}

    local sin, cos, rad, deg, sqrt, pi = math.sin, math.cos, math.rad, math.deg, math.sqrt, math.pi
    local CHANNELS = { 'x', 'y', 'z', 'rx', 'rz', 'fov' }
    CamMath.CHANNELS = CHANNELS

    function CamMath.clamp(v, lo, hi)
        if v < lo then return lo end
        if v > hi then return hi end
        return v
    end

    function CamMath.lerp(a, b, t)
        return a + (b - a) * t
    end

    local EASE = {
        linear = function(t) return t end,
        smooth = function(t) return t * t * (3 - 2 * t) end,
        smoother = function(t) return t * t * t * (t * (t * 6 - 15) + 10) end,
        inQuad = function(t) return t * t end,
        outQuad = function(t) return 1 - (1 - t) * (1 - t) end,
        inOutQuad = function(t) return t < 0.5 and 2 * t * t or 1 - (-2 * t + 2) ^ 2 / 2 end,
        inCubic = function(t) return t * t * t end,
        outCubic = function(t) return 1 - (1 - t) ^ 3 end,
        inOutCubic = function(t) return t < 0.5 and 4 * t * t * t or 1 - (-2 * t + 2) ^ 3 / 2 end,
        inSine = function(t) return 1 - cos(t * pi / 2) end,
        outSine = function(t) return sin(t * pi / 2) end,
        inOutSine = function(t) return -(cos(pi * t) - 1) / 2 end,
    }
    CamMath.EASES = EASE

    -- Eased progress for t in 0..1; unknown names ease 'smooth'.
    function CamMath.ease(name, t)
        t = tonumber(t) or 0
        if t ~= t or t <= 0 then return 0 end
        if t >= 1 then return 1 end
        return (EASE[name] or EASE.smooth)(t)
    end

    -- Catmull-Rom on one scalar channel: b at t = 0, c at t = 1.
    function CamMath.catmull(a, b, c, d, t)
        local t2, t3 = t * t, t * t * t
        return 0.5 * (2 * b + (c - a) * t + (2 * a - 5 * b + 4 * c - d) * t2 + (3 * b - a - 3 * c + d) * t3)
    end

    -- The angle equal to `to` that lies within 180 degrees of `from`: unwrap(350, 10) is 370.
    function CamMath.unwrap(from, to)
        return to + 360 * math.floor((from - to) / 360 + 0.5)
    end

    -- Pitch and yaw (rotation order 2) that look from p at t; yaw 0 faces +y, 90 faces -x.
    function CamMath.lookRot(px, py, pz, tx, ty, tz)
        local dx, dy, dz = tx - px, ty - py, tz - pz
        return deg(math.atan(dz, sqrt(dx * dx + dy * dy))), deg(math.atan(-dx, dy))
    end

    -- Unit view direction of a pitch and yaw.
    function CamMath.forward(pitch, yaw)
        local p, y = rad(pitch), rad(yaw)
        return -sin(y) * cos(p), cos(y) * cos(p), sin(p)
    end

    -- Horizontal right axis of a yaw (or a heading).
    function CamMath.right(yaw)
        local y = rad(yaw)
        return cos(y), sin(y)
    end

    -- A local point (x right, y forward, z up) of a frame { x, y, z, h } in world space.
    function CamMath.toWorld(anchor, x, y, z)
        local h = rad(anchor.h or anchor.w or 0)
        local c, s = cos(h), sin(h)
        return anchor.x + x * c - y * s, anchor.y + x * s + y * c, anchor.z + (z or 0)
    end

    function CamMath.toLocal(anchor, wx, wy, wz)
        local h = rad(anchor.h or anchor.w or 0)
        local c, s = cos(h), sin(h)
        local dx, dy = wx - anchor.x, wy - anchor.y
        return dx * c + dy * s, -dx * s + dy * c, (wz or 0) - anchor.z
    end

    -- pos rotated by deg degrees around the vertical axis through center.
    function CamMath.orbit(pos, center, degrees)
        local a = rad(degrees)
        local dx, dy = pos.x - center.x, pos.y - center.y
        return center.x + dx * cos(a) - dy * sin(a), center.y + dx * sin(a) + dy * cos(a), pos.z
    end

    function CamMath.dist(a, b)
        local dx, dy, dz = b.x - a.x, b.y - a.y, b.z - a.z
        return sqrt(dx * dx + dy * dy + dz * dz)
    end

    local function number(v)
        v = tonumber(v)
        return v and v == v and v or nil
    end

    -- x, y, z of a vector or a { x, y, z } table; nil without three numbers.
    local function point(v)
        if v == nil then return nil end
        local x, y, z = number(v.x), number(v.y), number(v.z)
        if x and y and z then return x, y, z end
        return nil
    end
    CamMath.point = point

    -- A pose from a key or a pose; anchor turns local keys into world ones. nil when the key has no position.
    function CamMath.pose(key, anchor)
        if type(key) ~= 'table' then return nil end
        local fov = number(key.fov) or 40.0
        if number(key.x) and number(key.rz) then
            return { x = key.x, y = key.y, z = key.z, rx = number(key.rx) or 0, ry = number(key.ry) or 0, rz = key.rz, fov = fov }
        end
        local x, y, z = point(key.pos)
        if not x then return nil end
        if anchor then x, y, z = CamMath.toWorld(anchor, x, y, z) end
        local rx, rz = 0, 0
        local lx, ly, lz = point(key.look)
        if lx then
            if anchor then lx, ly, lz = CamMath.toWorld(anchor, lx, ly, lz) end
            rx, rz = CamMath.lookRot(x, y, z, lx, ly, lz)
        elseif type(key.rot) == 'table' then
            rx, rz = number(key.rot.x) or 0, (number(key.rot.z) or 0) + (anchor and (anchor.h or 0) or 0)
        end
        return { x = x, y = y, z = z, rx = rx, ry = number(key.roll) or 0, rz = rz, fov = fov, ms = number(key.ms), cut = key.cut == true }
    end

    -- Poses of a key list with pitch and yaw unwrapped along it, so 350 -> 10 turns through 360.
    function CamMath.path(keys, anchor)
        local out = {}
        for _, key in ipairs(type(keys) == 'table' and keys or {}) do
            local pose = CamMath.pose(key, anchor)
            local prev = out[#out]
            if pose and prev then
                pose.rx, pose.rz = CamMath.unwrap(prev.rx, pose.rx), CamMath.unwrap(prev.rz, pose.rz)
            end
            out[#out + 1] = pose
        end
        return out
    end

    -- Time share of each segment: the keys' ms when all have one, else chord length (turns count a little).
    function CamMath.chordShares(points)
        local n = #points
        if n < 2 then return {} end
        local lengths, total, timed = {}, 0, true
        for i = 2, n do timed = timed and (number(points[i].ms) or 0) > 0 end
        for i = 2, n do
            local a, b = points[i - 1], points[i]
            local len = timed and number(b.ms) or CamMath.dist(a, b) + 0.02 * (math.abs(b.rx - a.rx) + math.abs(b.rz - a.rz))
            lengths[i - 1] = math.max(len, 1e-4)
            total = total + lengths[i - 1]
        end
        for i = 1, n - 1 do lengths[i] = lengths[i] / total end
        return lengths
    end

    -- Segment index and local t for global progress u over cumulative shares.
    function CamMath.segment(shares, u)
        local start = 0
        for i, share in ipairs(shares) do
            if u <= start + share or i == #shares then
                return i, CamMath.clamp((u - start) / share, 0, 1)
            end
            start = start + share
        end
        return 1, 0
    end

    -- Pose at progress u along a path: Catmull-Rom per channel, phantom end points 2*p1 - p2.
    function CamMath.spline(points, shares, u)
        local n = #points
        if n == 1 then return CamMath.copy(points[1]) end
        local i, t = CamMath.segment(shares, u)
        local p1, p2 = points[i], points[i + 1]
        local p0, p3 = points[i - 1], points[i + 2]
        local out = { ry = CamMath.lerp(p1.ry or 0, p2.ry or 0, t) }
        for _, key in ipairs(CHANNELS) do
            local a = p0 and p0[key] or 2 * p1[key] - p2[key]
            local d = p3 and p3[key] or 2 * p2[key] - p1[key]
            out[key] = CamMath.catmull(a, p1[key], p2[key], d, t)
        end
        return out
    end

    function CamMath.copy(pose)
        return { x = pose.x, y = pose.y, z = pose.z, rx = pose.rx, ry = pose.ry or 0, rz = pose.rz, fov = pose.fov }
    end

    -- Midpoint of a and b pushed away from the anchor by k times their distance (moves stay in the aisle).
    function CamMath.arcMid(a, b, anchor, k)
        local mx, my, mz = (a.x + b.x) / 2, (a.y + b.y) / 2, (a.z + b.z) / 2
        local len = CamMath.dist(a, b)
        if not anchor or not k or k <= 0 or len < 1e-6 then return { x = mx, y = my, z = mz } end
        local dx, dy = mx - anchor.x, my - anchor.y
        local d = sqrt(dx * dx + dy * dy)
        if d < 1e-6 then
            dx, dy = a.y - b.y, b.x - a.x
            d = sqrt(dx * dx + dy * dy)
        end
        return { x = mx + dx / d * k * len, y = my + dy / d * k * len, z = mz }
    end

    -- A shot { ms, ease, keys } split into moves at keys with cut = true; ms shared by segment count.
    function CamMath.splitShots(shot)
        local groups, units = {}, 0
        for i, key in ipairs(type(shot) == 'table' and type(shot.keys) == 'table' and shot.keys or {}) do
            if i == 1 or key.cut == true then groups[#groups + 1] = { keys = {}, cut = key.cut == true or i > 1 } end
            local keys = groups[#groups].keys
            keys[#keys + 1] = key
        end
        for _, group in ipairs(groups) do units = units + math.max(1, #group.keys - 1) end
        local total = number(shot and shot.ms) or 6000
        for _, group in ipairs(groups) do
            group.ms = total * math.max(1, #group.keys - 1) / units
            group.ease = shot.ease
        end
        return groups
    end

    -- Idle sway offsets at time t (seconds): along the camera's right axis, up, and yaw; ramp scales them in.
    function CamMath.sway(cfg, t, ramp)
        local period = math.max(number(cfg.period) or 9, 1)
        local w = 2 * pi * t / period
        return sin(w) * (number(cfg.x) or 0) * ramp, sin(0.7 * w) * (number(cfg.z) or 0) * ramp, sin(0.5 * w) * (number(cfg.yaw) or 0) * ramp
    end

    -- A clock hour (0..24, fractional) between a and b the short way round midnight.
    function CamMath.hourLerp(a, b, t)
        local d = (b - a + 12) % 24 - 12
        return (a + d * CamMath.clamp(t, 0, 1)) % 24
    end

    -- Hours, minutes and seconds of a fractional clock hour.
    function CamMath.clock(hour)
        local s = math.floor((hour % 24) * 3600 + 0.5) % 86400
        return math.floor(s / 3600), math.floor(s / 60) % 60, s % 60
    end

    -- Framing maths from the pause menu's character camera: put a body into a box of the 1920x1080 stage.
    -- Boxes are { x, y, w, h } (Config.Theme.ActorBox) or { left, top, width, height }. No natives, so tests run it.
    Framing = {}

    local function parts(box)
        return box.x or box[1], box.y or box[2], box.w or box[3], box.h or box[4]
    end

    -- A stage box on a w x h screen, letterboxed like the page: centre x and y as screen fractions, and height share.
    function Framing.boxOnScreen(box, w, h)
        local bx, by, bw, bh = parts(box)
        local k = math.min(w / 1920, h / 1080)
        local offX, offY = (w - 1920 * k) / 2, (h - 1080 * k) / 2
        return (offX + (bx + bw / 2) * k) / w, (offY + (by + bh / 2) * k) / h, bh * k / h
    end

    -- Sideways shift of the aim point that puts something d metres away at screen fraction s (0.5 = centre).
    function Framing.shift(d, vfov, aspect, s)
        local hHalf = math.atan(math.tan(math.rad(vfov) / 2) * aspect)
        return d * math.tan(hHalf) * (2 * s - 1)
    end

    -- Distance at which a body `height` metres tall fills `share` of the screen height.
    function Framing.fitDistance(height, share, vfov)
        return height / (share * 2 * math.tan(math.rad(vfov) / 2))
    end

    -- Where the body lands and how far the camera wants to be: { dist, sx, sy, share }. body = { top, bottom }.
    function Framing.plan(body, box, w, h, aspect, fov, margin)
        local sx, sy, share = Framing.boxOnScreen(box, w, h)
        local span = math.max(body.top - body.bottom, 0.3) * (margin or 1.1)
        return { dist = Framing.fitDistance(span, share, fov), sx = sx, sy = sy, share = share, aspect = aspect }
    end

    -- Camera pose reach metres from body { x, y, h, top, bottom } at yaw degrees off its front, the body in the box.
    function Framing.pose(body, plan, reach, yaw, fov)
        local r = math.rad(yaw)
        local frame = { x = body.x, y = body.y, z = 0, h = body.h }
        local centre = body.centre or (body.top + body.bottom) / 2
        local px, py = CamMath.toWorld(frame, math.sin(r) * reach, math.cos(r) * reach, 0)
        local side = Framing.shift(reach, fov, plan.aspect, plan.sx)
        local ax, ay = CamMath.toWorld(frame, side * math.cos(r), -side * math.sin(r), 0)
        local az = centre - reach * math.tan(math.rad(fov) / 2) * (1 - 2 * plan.sy)
        local pitch, heading = CamMath.lookRot(px, py, centre, ax, ay, az)
        return { x = px, y = py, z = centre, rx = pitch, ry = 0, rz = heading, fov = fov, dist = reach }
    end

    -- Degrees of yaw that slide the picture `frac` of the screen width (a positive frac moves the subject left).
    function Framing.panYaw(fov, aspect, frac)
        local half = math.tan(math.rad(fov) / 2) * aspect
        return math.deg(math.atan(2 * frac * half))
    end

    -- How far the box centre moves left from one box to another, as a share of the 1920 stage width.
    function Framing.boxShift(from, to)
        local fx, _, fw = parts(from)
        local tx, _, tw = parts(to)
        return ((fx + fw / 2) - (tx + tw / 2)) / 1920
    end
end

-- Where a role scene's partner and crew stand: around the focused character by the scene's group settings, never
-- one by one. Pure math in the focused character's frame (x right, y forward, h turned from its heading), shared by
-- the selection and the editor.
--   group = { pose = 'together' | 'scene', formation = 'arc' | 'row', distance (m), spread (degrees),
--     direction (0 front, 90 right, 180 behind) }
-- Together (the default) the focused character and its company hold one pose (Formation.POSES); the formation
-- places them while the character cannot join (sitting, CPR) or when the scene keeps everyone at its own work.
do
    Formation = {}

    Formation.DEFAULT = { formation = 'arc', distance = 1.6, spread = 120.0, direction = 180.0 }

    local PARTNER_GAP = 0.78 -- metres between the partner and the focused character, shoulder to shoulder

    -- Config.Selection.Group's values, these when a server's config is older than the groups.
    local GROUP = {
        Every = 13000,
        Moments = { 'partner', 'greet', 'team', 'cheer', 'dance', 'selfie' },
        Greet = {
            { dict = 'anim@mp_player_intcelebrationpaired@{pair}_manly_handshake', a = 'manly_handshake_left', b = 'manly_handshake_right' },
            { dict = 'anim@mp_player_intcelebrationpaired@{pair}_fist_bump', a = 'fist_bump_left', b = 'fist_bump_right' },
            { dict = 'anim@mp_player_intcelebrationpaired@{pair}_bro_hug', a = 'bro_hug_left', b = 'bro_hug_right' },
            { dict = 'anim@mp_player_intcelebrationpaired@{pair}_backslap', a = 'backslap_left', b = 'backslap_right' },
            { dict = 'mp_ped_interaction', a = 'handshake_guy_a', b = 'handshake_guy_b' },
        },
        Idle = {
            m = { { dict = 'mp_corona@team_idles@male_a', clip = 'idle', flag = 1 }, { dict = 'mp_corona@team_idles@male_b', clip = 'idle', flag = 1 },
                { dict = 'mp_corona@team_idles@male_c', clip = 'idle', flag = 1 } },
            f = { { dict = 'mp_corona@team_idles@female_a', clip = 'idle', flag = 1 } },
        },
    }

    -- The poses a focused character holds with its company (looped synced scenes, played from where it stands): a
    -- couple's embrace (the man takes the m part; two of a sex: the focused one does), and GTA Online's heist crew
    -- lineup for a friend or a crew (the focused character in the middle, up to three beside it).
    Formation.POSES = {
        couple = { dict = 'misscarsteal2chad_goodbye', m = 'chad_armsaround_chad', f = 'chad_armsaround_girl' },
        team = { dict = 'mp_corona@single_team', lead = 'single_team_loop_boss',
            parts = { 'single_team_loop_one', 'single_team_loop_two', 'single_team_loop_three' } },
    }

    -- Couple poses, as emote menus place them (scully_emotemenu, rpemotes): the partner (b) stands front metres before
    -- the character (a) and side metres to its right, turned to face it, or is attached to it (attach = { bone, pos,
    -- rot }). lead: the sex that takes a (the other way round the parts swap; attached poses then skip). Poses whose
    -- dictionaries are not on the server are skipped, so a server's own emote packs add theirs by name.
    Formation.COUPLE = {
        { a = { 'misscarsteal2chad_goodbye', 'chad_armsaround_chad' }, b = { 'misscarsteal2chad_goodbye', 'chad_armsaround_girl' },
            front = 0.52, side = -0.05, lead = 'm' },
        { a = { 'littlespoon@friendship007', 'friendship007' }, b = { 'littlespoon@friendship008', 'friendship008' } },
        { a = { 'anim@scripted@robbery@tun_prep_uni_ig1_couple@', 'action_var_01_bank_manager' },
            b = { 'anim@scripted@robbery@tun_prep_uni_ig1_couple@', 'action_var_01_female' }, front = 0.11, side = -0.04125, lead = 'm' },
        { a = { 'couplepose1pack1anim2@animation', 'couplepose1pack1anim2_clip' }, b = { 'couplepose1pack1anim1@animation', 'couplepose1pack1anim1_clip' },
            attach = { bone = 0, pos = { 0.002, 0.287, 0.25 }, rot = { 0.0, 0.0, 180.0 } }, lead = 'm' },
        { a = { 'couplepose2pack1anim2@animation', 'couplepose2pack1anim2_clip' }, b = { 'couplepose2pack1anim1@animation', 'couplepose2pack1anim1_clip' },
            attach = { bone = 0, pos = { 0.01, 0.48, 0.53 }, rot = { 0.0, 0.0, 180.0 } }, lead = 'm' },
        { a = { 'couplepose3pack1anim2@animation', 'couplepose3pack1anim2_clip' }, b = { 'couplepose3pack1anim1@animation', 'couplepose3pack1anim1_clip' },
            attach = { bone = 0, pos = { -0.212, -0.54, -0.1 }, rot = { 0.0, 0.0, 0.0 } }, lead = 'm' },
    }

    -- Crew stances, each member its own (by sex, in turn); the character leads with folded arms.
    Formation.STANCES = {
        lead = { 'anim@heists@heist_corona@single_team', 'single_team_loop_boss' },
        m = {
            { 'random@street_race', '_car_b_lookout' }, { 'anim@amb@nightclub@peds@', 'rcmme_amanda1_stand_loop_cop' },
            { 'random@shop_gunstore', '_idle' }, { 'rcmnigel1a_band_groupies', 'base_m2' }, { 'bzzz@animations@hands', 'bz_hands' },
            { 'anim@mp_corona_idles@male_c@idle_a', 'idle_a' }, { 'anim@mp_corona_idles@male_d@idle_a', 'idle_a' },
        },
        f = {
            { 'amb@world_human_hang_out_street@female_arms_crossed@idle_a', 'idle_a' }, { 'anim@mp_corona_idles@female_b@idle_a', 'idle_a' },
            { 'anim@mp_celebration@idles@female', 'celebration_idle_f_a' }, { 'handinpocket@sharror', 'handinpocket_clip' },
            { 'anim@heists@heist_corona@team_idles@female_a', 'idle' },
        },
    }

    -- Whether a scene's company holds the pose with the focused character (the default) or keeps to the scene's acts.
    function Formation.together(group)
        return type(group) == 'table' and group.pose ~= 'scene'
    end

    function Formation.config(key)
        local g = type(Config) == 'table' and type(Config.Selection) == 'table' and Config.Selection.Group or nil
        local value = type(g) == 'table' and g[key] or nil
        if value == nil then return GROUP[key] end
        return value
    end

    -- The heading (GTA: forward is (-sin h, cos h)) that looks along dx, dy.
    local function headingTo(dx, dy)
        return math.deg(math.atan(-dx, dy))
    end

    local function wrap(h)
        return (h + 180.0) % 360.0 - 180.0
    end

    -- A member faces the focused character, less so the further behind it stands (a group behind faces the camera).
    local function facing(x, y, direction)
        local look = wrap(headingTo(-x, 0.4 - y))
        local behind = math.max(0.0, -math.cos(math.rad(direction)))
        return look * (0.9 - 0.55 * behind)
    end

    local function settings(group)
        local g = type(group) == 'table' and group or {}
        local d = Formation.DEFAULT
        return g.formation == 'row' and 'row' or 'arc', tonumber(g.distance) or d.distance, tonumber(g.spread) or d.spread,
            (tonumber(g.direction) or d.direction) % 360.0
    end

    -- The places of n members: an arc at distance over spread degrees round direction (a full ring keeps a gap), or a
    -- row across direction whose gaps grow with spread.
    function Formation.slots(group, n)
        local kind, distance, spread, direction = settings(group)
        local out = {}
        if (tonumber(n) or 0) < 1 then return out end
        -- Together: a row beside the character (right, left, right), a step back, all facing front.
        if Formation.together(group) then
            for i = 1, n do
                local side, step = i % 2 == 1 and 1 or -1, math.ceil(i / 2)
                out[i] = { x = side * 0.95 * step, y = -0.25 * step, h = -6.0 * side }
            end
            return out
        end
        local d = math.rad(direction)
        if kind == 'row' then
            local gap = 0.7 + spread / 180.0
            local cx, cy = distance * math.sin(d), distance * math.cos(d)
            for i = 1, n do
                local k = (i - (n + 1) / 2) * gap
                local x, y = cx + math.cos(d) * k, cy - math.sin(d) * k
                out[i] = { x = x, y = y, h = facing(x, y, direction) }
            end
            return out
        end
        local width = n > 1 and math.min(spread, 360.0 - 360.0 / n) or 0.0
        for i = 1, n do
            local a = math.rad(direction + (n > 1 and width * ((i - 1) / (n - 1) - 0.5) or 0.0))
            local x, y = distance * math.sin(a), distance * math.cos(a)
            out[i] = { x = x, y = y, h = facing(x, y, direction) }
        end
        return out
    end

    -- The partner: at the focused character's side towards the middle of the picture (the camera faces the character,
    -- so with the character framed on the right the partner stands at its right hand), turned a little in.
    function Formation.partner(_, frame)
        local side = frame == 'left' and -1 or 1
        return { x = PARTNER_GAP * side, y = -0.05, h = 14.0 * side }
    end

    -- A place in the focused character's frame as a point of the scene (its at: x, y, z, h in the anchor's frame).
    function Formation.place(at, slot)
        local r = math.rad(tonumber(at.h) or 0.0)
        local c, s = math.cos(r), math.sin(r)
        return { x = at.x + slot.x * c - slot.y * s, y = at.y + slot.x * s + slot.y * c, z = tonumber(at.z) or 0.0,
            h = ((tonumber(at.h) or 0.0) + slot.h + 180.0) % 360.0 - 180.0 }
    end
end

-- Config.Onboarding read the same way on both sides; the old NewCharacter.Onboarding flag still counts when it is missing.
-- Callers ask Core.product.resource('onboarding') themselves: no running daddy_onboarding, nothing of this.
do
    Onboard = {}

    local function settings()
        return type(Config.Onboarding) == 'table' and Config.Onboarding or {}
    end

    -- Onboarding runs after a new character arrives.
    function Onboard.enabled()
        local on = settings().Enabled
        if on == nil then on = (Config.NewCharacter or {}).Onboarding end
        return on ~= false
    end

    -- The casting form offers civilian / student / teacher.
    function Onboard.roles()
        return settings().Roles == true
    end

    -- The College point's settings when it is on, else nil.
    function Onboard.college()
        local college = settings().College
        return type(college) == 'table' and college.Enabled == true and college or nil
    end
end

-- Scene data in one checked shape, for the server (presets, packs, editor saves) and the client (before a scene opens).
-- Local coordinates: x right, y forward (the way the actors face), z up, turned by the anchor heading.
do
    SceneSchema = {}

    local MAX = { spots = 10, keys = 24, props = 24, ipls = 16, sets = 4, setNames = 16, extras = 12, cars = 6, doors = 6, walk = 6 }
    local WORLD = 10000.0 -- metres from the map centre (anchors, camera keys, interior sets)
    local LOCAL = 200.0 -- metres from the anchor (spots, props, the vehicle)
    local NAME = '^[%w_%-]+$'
    local DICT = '^[%w_%-@%.%^]+$' -- animation dictionaries and clips (anim@amb@carmeet@checkout_engine@male_a@base)
    local ID = '^[%w_:%-]+$'
    local WEATHER = {
        EXTRASUNNY = true, CLEAR = true, NEUTRAL = true, SMOG = true, FOGGY = true, OVERCAST = true, CLOUDS = true,
        CLEARING = true, RAIN = true, THUNDER = true, SNOW = true, BLIZZARD = true, SNOWLIGHT = true, XMAS = true,
        HALLOWEEN = true, RAIN_HALLOWEEN = true, SNOW_HALLOWEEN = true,
    }
    local EASES = {
        linear = true, smooth = true, inQuad = true, outQuad = true, inOutQuad = true, inCubic = true, outCubic = true,
        inOutCubic = true, inSine = true, outSine = true, inOutSine = true, inExpo = true, outExpo = true, inOutExpo = true,
    }
    local MODES = { single = true, lineup = true }
    local SETUPS = { 'solo', 'partner', 'crew' } -- a role scene's layouts by the crew's size
    local FORMATIONS = { arc = true, row = true }
    local KINDS = { solo = true, partner = true, crew = true } -- who a role scene is made for -- how a role scene's crew stands round the focused character (Formation)
    local SEXES = { m = true, f = true }
    local FRAMES = { left = true, center = true, right = true }
    local SEASONS = { winter = true, halloween = true, xmas = true } -- season packs (SeasonRules)
    local AUDIO = { ogg = true, mp3 = true, wav = true, webm = true }

    -- A finite number, or nil (NaN and infinities are refused).
    local function number(value)
        local n = tonumber(value)
        if not n or n ~= n or n == math.huge or n == -math.huge then return nil end
        return n
    end

    local function clamp(value, min, max, default)
        local n = number(value)
        if not n then return default end
        return math.max(min, math.min(max, n))
    end

    local function name(value)
        if type(value) ~= 'string' or #value == 0 or #value > 64 or not value:match(NAME) then return nil end
        return value
    end

    -- Up to max checked items of a list; the ones the check refuses are left out.
    local function list(raw, max, check)
        local out = {}
        if type(raw) ~= 'table' then return out end
        for _, item in ipairs(raw) do
            if #out >= max then break end
            local value = check(item)
            if value ~= nil then out[#out + 1] = value end
        end
        return out
    end

    -- { x, y, z, h } from a vector, a { x, y, z, h|w|heading } table or a JSON array; nil past the bound.
    function SceneSchema.point(raw, bound)
        local kind = type(raw)
        local x, y, z, h
        if kind == 'table' then
            x, y, z = number(raw.x or raw[1]), number(raw.y or raw[2]), number(raw.z or raw[3])
            h = raw.h or raw.w or raw.heading or raw[4]
        elseif kind == 'vector3' or kind == 'vector4' then
            x, y, z = number(raw.x), number(raw.y), number(raw.z)
            h = kind == 'vector4' and raw.w or 0.0
        end
        if not (x and y and z) then return nil end
        bound = bound or WORLD
        if math.abs(x) > bound or math.abs(y) > bound or math.abs(z) > bound then return nil end
        return { x = x, y = y, z = z, h = (number(h) or 0.0) % 360.0 }
    end

    local function vec(raw, bound)
        local p = SceneSchema.point(raw, bound)
        return p and { x = p.x, y = p.y, z = p.z } or nil
    end

    -- One line of text, at most max characters (48 by default).
    local function label(value, fallback, max)
        if type(value) ~= 'string' or not utf8.len(value) then return fallback end
        local text = (value:gsub('%c', '')):match('^%s*(.-)%s*$')
        if text == '' then return fallback end
        local stop = utf8.offset(text, (max or 48) + 1)
        return stop and text:sub(1, stop - 1) or text
    end

    -- A model name or a whole hash.
    local function model(value)
        if type(value) == 'number' then
            return value % 1 == 0 and value >= -2147483648 and value <= 4294967295 and value or nil
        end
        return name(value)
    end

    -- '' (the built-in drone), 'file.ogg' in media/, or '@resource/path.ogg'; anything else is ''.
    local function music(value)
        if type(value) ~= 'string' or value == '' or #value > 128 or value:find('..', 1, true) then return '' end
        local resource, path = value:match('^@([%w_%-]+)/(.+)$')
        local file = path or value
        local ext = file:match('%.(%w+)$')
        if not ext or not AUDIO[ext:lower()] or not file:match('^[%w_%-%. /]+$') or file:sub(1, 1) == '/' then return '' end
        if not resource and file:find('/', 1, true) then return '' end
        return value
    end

    -- A camera key: pos plus look (a point) or rot (pitch, roll, yaw); fov 10..90; cut starts a new shot.
    local function key(raw)
        if type(raw) ~= 'table' then return nil end
        local pos, look, rot = vec(raw.pos, WORLD), vec(raw.look, WORLD), vec(raw.rot, 360.0)
        if not pos or not (look or rot) then return nil end
        return {
            pos = pos, look = look, rot = not look and rot or nil, fov = clamp(raw.fov, 10, 90, 40.0),
            ms = raw.ms ~= nil and clamp(raw.ms, 0, 60000, nil) or nil, cut = raw.cut == true or nil,
        }
    end

    local function shot(raw, msMin, msMax, msDefault)
        if type(raw) ~= 'table' then return nil end
        local keys = list(raw.keys, MAX.keys, key)
        if #keys == 0 then return nil end
        return { ms = clamp(raw.ms, msMin, msMax, msDefault), ease = EASES[raw.ease] and raw.ease or 'smooth', keys = keys }
    end

    local function shots(raw)
        raw = type(raw) == 'table' and raw or {}
        local establish = shot(raw.establish, 500, 120000, 7000)
        if not establish then return nil end
        local move, sway = type(raw.move) == 'table' and raw.move or {}, type(raw.sway) == 'table' and raw.sway or nil
        return {
            establish = establish,
            focus = shot(raw.focus, 300, 20000, 2500),
            move = { ms = clamp(move.ms, 300, 5000, 1400), arc = clamp(move.arc, 0, 1, 0.25) },
            sway = sway and { x = clamp(sway.x, 0, 1, 0.08), z = clamp(sway.z, 0, 1, 0.04), yaw = clamp(sway.yaw, 0, 5, 0.6),
                period = clamp(sway.period, 2, 60, 9.0) } or false,
        }
    end

    local function dict(value)
        if type(value) ~= 'string' or #value == 0 or #value > 128 or not value:match(DICT) then return nil end
        return value
    end

    -- A prop held in a hand: model, bone and its offset.
    local function held(raw)
        if type(raw) ~= 'table' then return nil end
        local m = model(raw.model)
        if not m then return nil end
        return { model = m, bone = math.floor(clamp(raw.bone, 0, 65535, 28422)), pos = vec(raw.pos, 2.0) or { x = 0, y = 0, z = 0 },
            rot = vec(raw.rot, 360.0) or { x = 0, y = 0, z = 0 } }
    end

    -- What a scene ped does: a scenario, or an animation (dict + clip, flag), with a held prop.
    local function act(raw)
        if type(raw) ~= 'table' then return nil end
        local out = { scenario = name(raw.scenario), dict = dict(raw.dict), clip = dict(raw.clip), prop = held(raw.prop),
            aim = name(raw.aim), weapon = name(raw.weapon), enter = dict(raw.enter), chair = model(raw.chair), chairClip = dict(raw.chairClip), origin = raw.origin == true or nil,
            ready = raw.ready == true or nil } -- ready: a long gun held low towards the target, not aimed
        if not out.scenario and not (out.dict and out.clip) and not out.aim then return nil end
        if out.dict then out.flag = math.floor(clamp(raw.flag, 0, 1023, 1)) end
        return out
    end

    -- An act that may carry a female one.
    local function acted(a)
        local out = act(a)
        if out then out.female = act(a.female) end
        return out
    end

    -- Two peds in one synced animation: dict ({pair} becomes m_m, f_m or f_f by the two sexes), clip a for the actor,
    -- b for the extra named with; every: ms between plays (a pair), absent for one that never stops (a sync).
    local function pairing(raw, timed)
        if type(raw) ~= 'table' then return nil end
        local d, a, b, with = dict(raw.dict), dict(raw.a), dict(raw.b), name(raw.with)
        if not (d and a and b and with) then return nil end
        return { dict = d, a = a, b = b, with = with, every = timed and math.floor(clamp(raw.every, 4000, 120000, 12000)) or nil,
            offset = vec(raw.offset, 5.0), walk = raw.walk == true or nil, dictB = dict(raw.dictB) } -- dictB: the other one's own dictionary
    end

    -- Hides while this many companions stand in (true is one).
    local function fillOf(v)
        local n = v == true and 1 or tonumber(v)
        return n and n >= 1 and math.min(10, math.floor(n)) or nil
    end

    -- A scene's own ped (a passer-by, a colleague, the one on the ground): model, place, what it does.
    local function extra(raw)
        if type(raw) ~= 'table' then return nil end
        local m, at = model(raw.model), SceneSchema.point(raw.at, LOCAL)
        if not m or not at then return nil end
        -- walk: points (x, y near the anchor) it walks to in turn and back again, at speed (1 walk, 2 jog, 3 run)
        local walk = list(raw.walk, MAX.walk, function(p)
            return type(p) == 'table' and SceneSchema.point({ x = p.x, y = p.y, z = p.z or 0.0 }, LOCAL) or nil
        end)
        return { id = name(raw.id), model = m, at = at, act = act(raw.act), sex = SEXES[raw.sex] and raw.sex or 'm',
            fill = fillOf(raw.fill), walk = #walk > 0 and walk or nil, speed = tonumber(raw.speed) and clamp(raw.speed, 0.5, 3.0, 1.0) or nil,
            alpha = tonumber(raw.alpha) and math.floor(clamp(raw.alpha, 30, 255, 255)) or nil } -- alpha: see-through (a ghost)
    end

    -- A scene's own vehicle: model, place, lights or sirens on, doors open (0-5: front left .. boot), engine running.
    local function car(raw)
        if type(raw) ~= 'table' then return nil end
        local m, at = model(raw.model), SceneSchema.point(raw.at, LOCAL)
        if not m or not at then return nil end
        local doors = list(raw.doors, MAX.doors, function(d)
            local n = tonumber(d)
            return n and n >= 0 and n <= 5 and math.floor(n) or nil
        end)
        return { model = m, at = at, lights = raw.lights == true or nil, siren = raw.siren == true or nil, engine = raw.engine == true or nil,
            doors = #doors > 0 and doors or nil, wrecked = raw.wrecked == true or nil, smoke = raw.smoke == true or nil, tuned = raw.tuned == true or nil,
            tilt = tonumber(raw.tilt) and clamp(raw.tilt, -30, 30, 0.0) or nil } -- degrees nose up (a car on a tow hook)
    end

    -- A place for an actor: a ground point near the anchor, its idle anim id, a small nudge and an optional camera.
    local function spot(raw)
        if type(raw) ~= 'table' then return nil end
        local at = SceneSchema.point(raw.at, LOCAL)
        if not at then return nil end
        local n = (type(raw.nudge) == 'table' or type(raw.nudge) == 'vector3') and raw.nudge or {}
        return {
            at = at, anim = name(raw.anim) or 'random', cam = key(raw.cam),
            nudge = { x = clamp(n.x or n[1], -2, 2, 0.0), y = clamp(n.y or n[2], -2, 2, 0.0), z = clamp(n.z or n[3], -2, 2, 0.0) },
            act = acted(raw.act), female = act(raw.female), pair = pairing(raw.pair, true), sync = pairing(raw.sync, false),
            low = (raw.low == 'crouch' or raw.low == 'seat') and raw.low or nil, -- how the camera frames it before the pose
        }
    end

    -- A role scene's layouts: solo, partner and crew, each a list of spots (the first is the focused character's).
    local function setups(raw, max)
        if type(raw) ~= 'table' then return nil end
        local out, any = {}, false
        for _, kind in ipairs(SETUPS) do
            local spots = list(raw[kind], max, spot)
            if #spots > 0 then out[kind], any = spots, true end
        end
        return any and out or nil
    end

    -- A role scene's partner and crew: where they stand round the focused character (formation, distance, spread,
    -- direction), what they do while they wait (acts, cycled), an own place for the partner (a second lounger) and the
    -- moments the scene allows (Config.Selection.Group).
    local function group(raw)
        if type(raw) ~= 'table' then return nil end
        return {
            pose = raw.pose == 'scene' and 'scene' or 'together',
            formation = FORMATIONS[raw.formation] and raw.formation or 'arc',
            distance = clamp(raw.distance, 0.6, 6.0, 1.6), spread = clamp(raw.spread, 0, 360, 120.0),
            direction = clamp(raw.direction, 0, 360, 180.0), places = list(raw.places, 3, spot), acts = list(raw.acts, 4, acted), partner = spot(raw.partner), partnerAct = acted(raw.partnerAct),
            moments = type(raw.moments) == 'table' and list(raw.moments, 8, name) or nil,
        }
    end

    local function prop(raw)
        if type(raw) ~= 'table' then return nil end
        local m, at = model(raw.model), SceneSchema.point(raw.at, LOCAL)
        if not m or not at then return nil end
        return { model = m, at = at, collision = raw.collision == true }
    end

    -- Interior entity sets: a world point inside the interior and the set names to switch on.
    local function set(raw)
        if type(raw) ~= 'table' then return nil end
        local at, names = SceneSchema.point(raw, WORLD), list(raw.names, MAX.setNames, name)
        if not at or #names == 0 then return nil end
        return { x = at.x, y = at.y, z = at.z, names = names }
    end

    local function time(raw)
        if type(raw) ~= 'table' then return nil end
        local h, m = number(raw.h or raw.hour), number(raw.m or raw.minute or 0)
        if not h or not m then return nil end
        return { h = math.floor(clamp(h, 0, 23, 12)), m = math.floor(clamp(m, 0, 59, 0)) }
    end

    local function weather(value)
        local upper = type(value) == 'string' and value:upper() or nil
        return WEATHER[upper] and upper or nil
    end

    local function timecycle(raw)
        if type(raw) ~= 'table' or not name(raw.name) then return nil end
        return { name = raw.name, strength = clamp(raw.strength, 0, 1, 1.0) }
    end

    local function dof(raw)
        if type(raw) ~= 'table' then return false end
        return { near = clamp(raw.near, 0, 10, 1.0), far = clamp(raw.far, 0, 50, 2.5), strength = clamp(raw.strength, 0, 1, 0.8) }
    end

    local function light(raw)
        if type(raw) ~= 'table' then return false end
        local c = type(raw.color) == 'table' and raw.color or {}
        local function byte(v) return math.floor(clamp(v, 0, 255, 255)) end
        return {
            color = { r = byte(c.r or c[1]), g = byte(c.g or c[2]), b = byte(c.b or c[3]) },
            range = clamp(raw.range, 1, 50, 15.0), intensity = clamp(raw.intensity, 0, 20, 5.0),
        }
    end

    local function vehicle(raw)
        local at = type(raw) == 'table' and SceneSchema.point(raw.at, LOCAL) or nil
        return at and { at = at } or nil
    end

    local function maxSpots()
        local wanted = type(Config) == 'table' and type(Config.Scenes) == 'table' and tonumber(Config.Scenes.MaxSpots) or nil
        return math.max(1, math.min(MAX.spots, wanted or MAX.spots))
    end

    -- The checked scene, or nil and why: invalid | id | anchor | spots | shots. id is used when raw has none.
    function SceneSchema.normalize(raw, id)
        if type(raw) ~= 'table' then return nil, 'invalid' end
        id = raw.id or id
        if type(id) ~= 'string' or #id > 64 or not id:match(ID) then return nil, 'id' end
        local anchor = SceneSchema.point(raw.anchor, WORLD)
        if not anchor or anchor.z < -200 or anchor.z > 2500 then return nil, 'anchor' end
        local spots, layouts = list(raw.spots, maxSpots(), spot), setups(raw.setups, maxSpots())
        if #spots == 0 and layouts then spots = layouts.solo or layouts.partner or layouts.crew end -- a role scene's own spots
        if #spots == 0 and id ~= 'intro' then return nil, 'spots' end
        local cameras = shots(raw.shots)
        if not cameras then return nil, 'shots' end
        return {
            id = id, label = label(raw.label, id), desc = label(raw.desc, nil, 64), mode = MODES[raw.mode] and raw.mode or (#spots > 1 and 'lineup' or 'single'),
            anchor = anchor, time = time(raw.time), weather = weather(raw.weather), timecycle = timecycle(raw.timecycle),
            ipls = list(raw.ipls, MAX.ipls, name), sets = list(raw.sets, MAX.sets, set), stream = clamp(raw.stream, 20, 250, 80),
            music = music(raw.music), volume = clamp(raw.volume, 0, 1, 0.5), dof = dof(raw.dof), light = light(raw.light),
            props = list(raw.props, MAX.props, prop), spots = spots, vehicle = vehicle(raw.vehicle), shots = cameras,
            frame = FRAMES[raw.frame] and raw.frame or 'right',
            population = raw.population == true or (raw.population == nil and id == 'intro'),
            season = SEASONS[raw.season] and raw.season or nil,
            role = name(raw.role), extras = list(raw.extras, MAX.extras, extra), cars = list(raw.cars, MAX.cars, car),
            setups = layouts, group = group(raw.group), film = name(raw.film), kind = KINDS[raw.kind] and raw.kind or 'solo',
        }
    end

    -- A local point in world space (GetOffsetFromEntityInWorldCoords: right = (cos h, sin h), forward = (-sin h, cos h)).
    function SceneSchema.toWorld(anchor, p)
        local r = math.rad(anchor.h or 0.0)
        local c, s = math.cos(r), math.sin(r)
        return { x = anchor.x + p.x * c - p.y * s, y = anchor.y + p.x * s + p.y * c, z = anchor.z + p.z }
    end

    -- A camera key in world space; a rot key turns with the anchor.
    function SceneSchema.worldKey(anchor, k)
        local rot = k.rot and { x = k.rot.x, y = k.rot.y, z = k.rot.z + (anchor.h or 0.0) } or nil
        return { pos = SceneSchema.toWorld(anchor, k.pos), look = k.look and SceneSchema.toWorld(anchor, k.look) or nil,
            rot = rot, fov = k.fov, ms = k.ms, cut = k.cut }
    end

    -- Pitch and yaw in degrees (GTA camera rotation, yaw 0 = north, 90 = west) that look from a to b.
    function SceneSchema.aim(a, b)
        local dx, dy, dz = b.x - a.x, b.y - a.y, b.z - a.z
        return math.deg(math.atan(dz, math.sqrt(dx * dx + dy * dy))), math.deg(math.atan(-dx, dy))
    end

    -- The unit vector a camera with this pitch and yaw looks along.
    function SceneSchema.forward(rx, rz)
        local p, y = math.rad(rx), math.rad(rz)
        return -math.sin(y) * math.cos(p), math.cos(y) * math.cos(p), math.sin(p)
    end

    -- A camera pose { x, y, z, rx, ry, rz, fov } in world space for a local key.
    function SceneSchema.pose(anchor, k)
        local w = SceneSchema.worldKey(anchor, k)
        local rx, ry, rz = 0.0, 0.0, 0.0
        if w.look then
            rx, rz = SceneSchema.aim(w.pos, w.look)
        elseif w.rot then
            rx, ry, rz = w.rot.x, w.rot.y, w.rot.z
        end
        return { x = w.pos.x, y = w.pos.y, z = w.pos.z, rx = rx, ry = ry, rz = rz, fov = w.fov or 40.0 }
    end

    -- A shot split into moves at its cut keys; each move gets an equal part of the shot's time.
    function SceneSchema.cuts(s)
        local moves = {}
        for _, k in ipairs(type(s) == 'table' and s.keys or {}) do
            if k.cut or #moves == 0 then moves[#moves + 1] = { keys = {}, ease = s.ease, cut = k.cut == true } end
            local keys = moves[#moves].keys
            keys[#keys + 1] = k
        end
        for _, move in ipairs(moves) do move.ms = math.floor(s.ms / #moves) end
        return moves
    end
end
