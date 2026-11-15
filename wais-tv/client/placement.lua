Placement = {}

local DEFAULTS = {
    gizmoSize = 0.14, pickRadius = 0.24, ringSegments = 40, snap = true, rotateSnap = 15.0, spinStep = 15.0,
    spinFine = 2.0, nudgeSteps = { 0.01, 0.05, 0.25 }, screenSide = -1, floorNormalZ = 0.7, rayDistance = 60.0, rayFlags = 19,
}
Config.Placement = type(Config.Placement) == 'table' and Config.Placement or {}
local Cfg = Config.Placement
for k, v in pairs(DEFAULTS) do
    if Cfg[k] == nil then Cfg[k] = v end
end

Config.CameraSettings = type(Config.CameraSettings) == 'table' and Config.CameraSettings or {}
for k, v in pairs({ lookSensitivity = 5.0, moveSpeed = 7.0, zoomSpeed = 2.0, minFov = 5.0, maxFov = 90.0, fitMargin = 1.15, transitionTime = 800 }) do
    if Config.CameraSettings[k] == nil then Config.CameraSettings[k] = v end
end

local _DrawLine, _DrawPoly, _GetNuiCursorPosition, _SetEntityMatrix = DrawLine, DrawPoly, GetNuiCursorPosition, SetEntityMatrix
local sin, cos, tan, asin, atan, rad, deg, exp = math.sin, math.cos, math.tan, math.asin, math.atan, math.rad, math.deg, math.exp
local sqrt, abs, floor, min, max = math.sqrt, math.abs, math.floor, math.min, math.max
local PI, TWO_PI = math.pi, math.pi * 2

local COLOR_AXIS = { { 232, 62, 62 }, { 78, 196, 96 }, { 62, 128, 240 } }
local COLOR_HOT, COLOR_CENTER, COLOR_SNAP = { 255, 214, 10 }, { 240, 242, 247 }, { 64, 200, 230 }

local PLANE_A, PLANE_B, PLANE_N = { 1, 1, 2 }, { 2, 3, 3 }, { 3, 2, 1 }
local MODES = { move = true, rotate = true }
local SPACES = { world = true, ['local'] = true }
local AXIS_INDEX = { x = 1, y = 2, z = 3 }

local RING_N = max(12, floor(Cfg.ringSegments or 40))
local RING_COS, RING_SIN = {}, {}
for j = 0, RING_N do
    local a = j * TWO_PI / RING_N
    RING_COS[j], RING_SIN[j] = cos(a), sin(a)
end

local CONE_N = 6
local CONE_COS, CONE_SIN = {}, {}
for j = 1, CONE_N + 1 do
    local a = (j - 1) * TWO_PI / CONE_N
    CONE_COS[j], CONE_SIN[j] = cos(a), sin(a)
end

local P = {
    open = false, active = false, ready = false, cam = false,
    mode = 'move', space = 'world', snap = true,
    hover = 0, drag = nil, dirty = true,
    cx = -1, cy = -1,
    hasHit = false, outOfRange = false, surf = 'floor', spin = 0.0, roll = 0.0,
}

local function Apply()
    _SetEntityMatrix(P.entity, P.fx, P.fy, P.fz, P.rx, P.ry, P.rz, P.ux, P.uy, P.uz, P.px, P.py, P.pz)
end

local function Reorth()
    local fx, fy, fz = P.fx, P.fy, P.fz
    local l = sqrt(fx * fx + fy * fy + fz * fz)
    fx, fy, fz = fx / l, fy / l, fz / l
    local rx, ry, rz = fy * P.uz - fz * P.uy, fz * P.ux - fx * P.uz, fx * P.uy - fy * P.ux
    l = sqrt(rx * rx + ry * ry + rz * rz)
    rx, ry, rz = rx / l, ry / l, rz / l
    P.fx, P.fy, P.fz, P.rx, P.ry, P.rz = fx, fy, fz, rx, ry, rz
    P.ux, P.uy, P.uz = ry * fz - rz * fy, rz * fx - rx * fz, rx * fy - ry * fx
end

local function Save(t)
    t[1], t[2], t[3], t[4], t[5], t[6] = P.px, P.py, P.pz, P.fx, P.fy, P.fz
    t[7], t[8], t[9], t[10], t[11], t[12] = P.rx, P.ry, P.rz, P.ux, P.uy, P.uz
    return t
end

local function Load(t)
    P.px, P.py, P.pz, P.fx, P.fy, P.fz = t[1], t[2], t[3], t[4], t[5], t[6]
    P.rx, P.ry, P.rz, P.ux, P.uy, P.uz = t[7], t[8], t[9], t[10], t[11], t[12]
end

local function SyncFromEntity()
    local f, r, u, a = GetEntityMatrix(P.entity)
    P.fx, P.fy, P.fz = f.x, f.y, f.z
    P.rx, P.ry, P.rz = r.x, r.y, r.z
    P.ux, P.uy, P.uz = u.x, u.y, u.z
    P.px, P.py, P.pz = a.x, a.y, a.z
end

local function RotVec(x, y, z, kx, ky, kz, c, s, kk)
    local d = kx * x + ky * y + kz * z
    return x * c + (ky * z - kz * y) * s + kx * d * kk,
           y * c + (kz * x - kx * z) * s + ky * d * kk,
           z * c + (kx * y - ky * x) * s + kz * d * kk
end

local function RotateAround(kx, ky, kz, a, cx, cy, cz)
    local c, s = cos(a), sin(a)
    local kk = 1.0 - c

    P.fx, P.fy, P.fz = RotVec(P.fx, P.fy, P.fz, kx, ky, kz, c, s, kk)
    P.rx, P.ry, P.rz = RotVec(P.rx, P.ry, P.rz, kx, ky, kz, c, s, kk)
    P.ux, P.uy, P.uz = RotVec(P.ux, P.uy, P.uz, kx, ky, kz, c, s, kk)
    local x, y, z = RotVec(P.px - cx, P.py - cy, P.pz - cz, kx, ky, kz, c, s, kk)
    P.px, P.py, P.pz = cx + x, cy + y, cz + z
    Reorth()
end

local function InRange(x, y, z)
    local dx, dy, dz = x - P.startx, y - P.starty, z - P.startz
    return dx * dx + dy * dy + dz * dz <= P.maxDist2
end

local function Center()
    return P.px + P.rx * P.bcx + P.fx * P.bcy + P.ux * P.bcz,
           P.py + P.ry * P.bcx + P.fy * P.bcy + P.uy * P.bcz,
           P.pz + P.rz * P.bcx + P.fz * P.bcy + P.uz * P.bcz
end

local function Axis(i)
    if P.space == 'local' then
        if i == 1 then return P.rx, P.ry, P.rz end
        if i == 2 then return P.fx, P.fy, P.fz end
        return P.ux, P.uy, P.uz
    end

    if i == 1 then return 1.0, 0.0, 0.0 end
    if i == 2 then return 0.0, 1.0, 0.0 end
    return 0.0, 0.0, 1.0
end

local function Perp(kx, ky, kz)
    local ux, uy = ky, -kx
    local l = sqrt(ux * ux + uy * uy)
    if l < 0.001 then ux, uy, l = 1.0, 0.0, 1.0 end
    ux, uy = ux / l, uy / l
    return ux, uy, 0.0, ky * 0.0 - kz * uy, kz * ux - kx * 0.0, kx * uy - ky * ux
end

local function UpdateCamera()
    local fc = FreeCam
    local c = fc.coords
    local yaw, pitch = rad(fc.yaw), rad(fc.pitch)
    local cp = cos(pitch)
    local fx, fy, fz = -sin(yaw) * cp, cos(yaw) * cp, sin(pitch)
    local rx, ry = cos(yaw), sin(yaw)

    P.ox, P.oy, P.oz = c.x, c.y, c.z
    P.cfx, P.cfy, P.cfz = fx, fy, fz
    P.crx, P.cry, P.crz = rx, ry, 0.0
    P.cux, P.cuy, P.cuz = ry * fz, -rx * fz, rx * fy - ry * fx
    P.tanH = tan(rad(fc.fov) * 0.5)
end

local function UpdateRay()
    local a = ((P.cx / P.sw) * 2.0 - 1.0) * P.tanH * P.aspect
    local b = (1.0 - (P.cy / P.sh) * 2.0) * P.tanH
    local x, y, z = P.cfx + P.crx * a + P.cux * b, P.cfy + P.cry * a + P.cuy * b, P.cfz + P.crz * a + P.cuz * b
    local l = sqrt(x * x + y * y + z * z)
    P.dx, P.dy, P.dz = x / l, y / l, z / l
end

local function MinFov()
    local cs = Config.CameraSettings
    local cx, cy, cz = Center()
    local dx, dy, dz = P.ox - cx, P.oy - cy, P.oz - cz
    local dist = sqrt(dx * dx + dy * dy + dz * dz)
    if dist <= 0.001 then return cs.maxFov end

    local fov = deg(2.0 * asin(min(P.radius / dist, 1.0))) * cs.fitMargin
    return max(cs.minFov, min(fov, cs.maxFov))
end

local function PlaceOnSurface()
    local nx, ny, nz = P.nrx, P.nry, P.nrz
    local hx, hy, hz = P.hitx, P.hity, P.hitz
    local side = Cfg.screenSide
    local fx, fy, fz, rx, ry, rz, ux, uy, uz, px, py, pz, surf

    if abs(nz) >= Cfg.floorNormalZ then
        local tx, ty = P.ox - hx, P.oy - hy
        local l = sqrt(tx * tx + ty * ty)
        if l < 0.001 then tx, ty = 0.0, 1.0 else tx, ty = tx / l, ty / l end

        local s = atan(-side * tx, side * ty) + rad(P.spin)
        fx, fy, fz = -sin(s), cos(s), 0.0
        rx, ry, rz = cos(s), sin(s), 0.0
        ux, uy, uz = 0.0, 0.0, 1.0
        px = hx - rx * P.bcx - fx * P.bcy
        py = hy - ry * P.bcx - fy * P.bcy
        pz = hz - (nz > 0.0 and P.minZ or P.maxZ)
        surf = 'floor'
    else
        local l = sqrt(nx * nx + ny * ny)
        if l < 0.001 then return false end

        fx, fy, fz = side * nx / l, side * ny / l, 0.0
        local r0x, r0y = fy, -fx
        local cr, sr = cos(rad(P.roll)), sin(rad(P.roll))
        rx, ry, rz = r0x * cr, r0y * cr, sr
        ux, uy, uz = -r0x * sr, -r0y * sr, cr
        local yb = side < 0 and P.maxY or P.minY
        px = hx - fx * yb - rx * P.bcx - ux * P.bcz
        py = hy - fy * yb - ry * P.bcx - uy * P.bcz
        pz = hz - fz * yb - rz * P.bcx - uz * P.bcz
        surf = 'wall'
    end

    if not InRange(px, py, pz) then
        P.outOfRange = true
        return false
    end

    P.outOfRange, P.surf = false, surf
    P.fx, P.fy, P.fz, P.rx, P.ry, P.rz, P.ux, P.uy, P.uz = fx, fy, fz, rx, ry, rz, ux, uy, uz
    P.px, P.py, P.pz = px, py, pz
    return true
end

local function SnapFloor()
    local cx, cy, cz = Center()
    local handle = StartExpensiveSynchronousShapeTestLosProbe(cx, cy, cz, cx, cy, cz - 30.0, Cfg.rayFlags, P.entity, 4)
    local _, hit, pos, nrm = GetShapeTestResult(handle)
    if not hit or hit == 0 or nrm.z < Cfg.floorNormalZ then return end

    local l = sqrt(P.fx * P.fx + P.fy * P.fy)
    local s = l > 0.01 and atan(-P.fx, P.fy) or 0.0
    local fx, fy = -sin(s), cos(s)
    local rx, ry = cos(s), sin(s)
    local px = pos.x - rx * P.bcx - fx * P.bcy
    local py = pos.y - ry * P.bcx - fy * P.bcy
    local pz = pos.z - P.minZ
    if not InRange(px, py, pz) then return end

    P.fx, P.fy, P.fz, P.rx, P.ry, P.rz, P.ux, P.uy, P.uz = fx, fy, 0.0, rx, ry, 0.0, 0.0, 0.0, 1.0
    P.px, P.py, P.pz = px, py, pz
    Apply()
    P.dirty = true
end

local function SnapWall()
    local cx, cy, cz = Center()
    local fl, rl = sqrt(P.fx * P.fx + P.fy * P.fy), sqrt(P.rx * P.rx + P.ry * P.ry)
    if fl < 0.01 or rl < 0.01 then return end

    local fx, fy, rx, ry = P.fx / fl, P.fy / fl, P.rx / rl, P.ry / rl
    local dirs = { fx, fy, -fx, -fy, rx, ry, -rx, -ry }
    local bestD, found = 1e9, false

    for i = 1, 8, 2 do
        local dx, dy = dirs[i], dirs[i + 1]
        local handle = StartExpensiveSynchronousShapeTestLosProbe(cx, cy, cz, cx + dx * 3.0, cy + dy * 3.0, cz, Cfg.rayFlags, P.entity, 4)
        local _, hit, pos, nrm = GetShapeTestResult(handle)
        if hit and hit ~= 0 and abs(nrm.z) < Cfg.floorNormalZ then
            local ex, ey = pos.x - cx, pos.y - cy
            local d = ex * ex + ey * ey
            if d < bestD then
                bestD, found = d, true
                P.hitx, P.hity, P.hitz = pos.x, pos.y, pos.z
                P.nrx, P.nry, P.nrz = nrm.x, nrm.y, nrm.z
            end
        end
    end

    if not found then return end
    P.roll = 0.0
    if PlaceOnSurface() then
        Apply()
        P.dirty = true
    end
end

local function GizmoSize(cx, cy, cz)
    local dx, dy, dz = cx - P.ox, cy - P.oy, cz - P.oz
    local dist = sqrt(dx * dx + dy * dy + dz * dz)

    return max(dist * P.tanH * Cfg.gizmoSize, P.radius * 1.15), dist
end

local function SetHover(v)
    local old = P.hover
    P.hover = v
    if (v >= 8 or old >= 8) and v ~= old then
        SendNUIMessage({ type = 'PLACEMENT_HOVER', id = v >= 8 and v or 0 })
    end
end

local BTN_X = { [8] = -0.2, [9] = 0.0, [10] = 0.2 }
local function HandlePos(k, L, cx, cy, cz)
    local sx, sy = BTN_X[k] * L, -0.95 * L
    return cx + P.crx * sx + P.cux * sy, cy + P.cry * sx + P.cuy * sy, cz + P.crz * sx + P.cuz * sy
end

local function RingSize(L)
    return max(L * 0.6, P.radius * 0.85)
end

local function RayPointDist(cx, cy, cz)
    local wx, wy, wz = cx - P.ox, cy - P.oy, cz - P.oz
    local s = max(P.dx * wx + P.dy * wy + P.dz * wz, 0.0)
    local qx, qy, qz = wx - P.dx * s, wy - P.dy * s, wz - P.dz * s
    return sqrt(qx * qx + qy * qy + qz * qz)
end

local function RayAxisDist(cx, cy, cz, bx, by, bz, len)
    local wx, wy, wz = P.ox - cx, P.oy - cy, P.oz - cz
    local b = P.dx * bx + P.dy * by + P.dz * bz
    local d0 = P.dx * wx + P.dy * wy + P.dz * wz
    local e = bx * wx + by * wy + bz * wz
    local den = 1.0 - b * b
    local t = den > 1e-4 and (e - b * d0) / den or 0.0
    t = max(0.0, min(t, len))
    local s = max(b * t - d0, 0.0)
    local qx = cx + bx * t - (P.ox + P.dx * s)
    local qy = cy + by * t - (P.oy + P.dy * s)
    local qz = cz + bz * t - (P.oz + P.dz * s)
    return sqrt(qx * qx + qy * qy + qz * qz)
end

local function RayPlane(cx, cy, cz, kx, ky, kz)
    local den = P.dx * kx + P.dy * ky + P.dz * kz
    if abs(den) < 0.03 then return nil end

    local s = ((cx - P.ox) * kx + (cy - P.oy) * ky + (cz - P.oz) * kz) / den
    if s <= 0.0 then return nil end
    return P.ox + P.dx * s, P.oy + P.dy * s, P.oz + P.dz * s
end

local function UpdateHover()
    do
        local cx, cy, cz = Center()
        local L = GizmoSize(cx, cy, cz)
        for k = 8, 10 do
            local x, y, z = HandlePos(k, L, cx, cy, cz)
            if RayPointDist(x, y, z) < L * 0.1 then
                SetHover(k)
                return
            end
        end
    end

    local best = 0
    do
        local cx, cy, cz = Center()
        local L = GizmoSize(cx, cy, cz)

        if P.mode == 'move' then
            if RayPointDist(cx, cy, cz) < L * 0.1 then
                best = 4
            else
                local bestD = L * Cfg.pickRadius
                for i = 1, 3 do
                    local bx, by, bz = Axis(i)
                    local d = RayAxisDist(cx, cy, cz, bx, by, bz, L)
                    if d < bestD then bestD, best = d, i end
                end

                if best == 0 then
                    for k = 1, 3 do
                        local nx, ny, nz = Axis(PLANE_N[k])
                        local x, y, z = RayPlane(cx, cy, cz, nx, ny, nz)
                        if x then
                            local ax, ay, az = Axis(PLANE_A[k])
                            local bx, by, bz = Axis(PLANE_B[k])
                            local qx, qy, qz = x - cx, y - cy, z - cz
                            local a = (qx * ax + qy * ay + qz * az) / L
                            local b = (qx * bx + qy * by + qz * bz) / L
                            if a > 0.12 and a < 0.52 and b > 0.12 and b < 0.52 then
                                best = 4 + k
                                break
                            end
                        end
                    end
                end
            end
        else
            L = RingSize(L)
            local bestE = L * Cfg.pickRadius
            for i = 1, 3 do
                local kx, ky, kz = Axis(i)
                local x, y, z = RayPlane(cx, cy, cz, kx, ky, kz)
                if x then
                    local qx, qy, qz = x - cx, y - cy, z - cz
                    local err = abs(sqrt(qx * qx + qy * qy + qz * qz) - L)
                    if err < bestE then bestE, best = err, i end
                end
            end
        end
    end

    SetHover(best)
end

local function EndDrag()
    if P.drag then
        P.drag = nil
        P.dirty = true
    end
end

local function StartDrag()
    local hv = P.hover
    if hv == 0 then return end

    UpdateRay()
    local cx, cy, cz = Center()
    local d = { i = hv, s = Save({}), cx = cx, cy = cy, cz = cz }

    if P.mode == 'move' and hv <= 3 then
        local bx, by, bz = Axis(hv)
        local wx, wy, wz = P.ox - cx, P.oy - cy, P.oz - cz
        local b = P.dx * bx + P.dy * by + P.dz * bz
        local den = 1.0 - b * b
        if den < 1e-4 then return end

        d.bx, d.by, d.bz = bx, by, bz
        d.t0 = (bx * wx + by * wy + bz * wz - b * (P.dx * wx + P.dy * wy + P.dz * wz)) / den
    elseif P.mode == 'move' then

        local nx, ny, nz = P.cfx, P.cfy, P.cfz
        if hv >= 5 then nx, ny, nz = Axis(PLANE_N[hv - 4]) end

        local x, y, z = RayPlane(cx, cy, cz, nx, ny, nz)
        if not x then return end
        d.x0, d.y0, d.z0 = x, y, z
        d.nx, d.ny, d.nz = nx, ny, nz
    else
        local kx, ky, kz = Axis(hv)
        local x, y, z = RayPlane(cx, cy, cz, kx, ky, kz)
        if not x then return end

        local ux, uy, uz, vx, vy, vz = Perp(kx, ky, kz)
        local rx, ry, rz = x - cx, y - cy, z - cz
        d.kx, d.ky, d.kz = kx, ky, kz
        d.ux, d.uy, d.uz, d.vx, d.vy, d.vz = ux, uy, uz, vx, vy, vz
        d.last = atan(vx * rx + vy * ry + vz * rz, ux * rx + uy * ry + uz * rz)
        d.acc, d.applied, d.a0, d.label = 0.0, 0.0, d.last, '0\194\176'
        d.hx, d.hy, d.hz = x, y, z
    end

    P.drag = d
end

local function DragStep()
    local d = P.drag
    local s = d.s

    if P.mode == 'move' then
        local nx, ny, nz
        if d.i <= 3 then
            local wx, wy, wz = P.ox - d.cx, P.oy - d.cy, P.oz - d.cz
            local b = P.dx * d.bx + P.dy * d.by + P.dz * d.bz
            local den = 1.0 - b * b
            if den < 1e-4 then return end

            local t = (d.bx * wx + d.by * wy + d.bz * wz - b * (P.dx * wx + P.dy * wy + P.dz * wz)) / den - d.t0
            nx, ny, nz = s[1] + d.bx * t, s[2] + d.by * t, s[3] + d.bz * t
        else
            local x, y, z = RayPlane(d.cx, d.cy, d.cz, d.nx, d.ny, d.nz)
            if not x then return end
            nx, ny, nz = s[1] + x - d.x0, s[2] + y - d.y0, s[3] + z - d.z0
        end

        if InRange(nx, ny, nz) then
            P.px, P.py, P.pz = nx, ny, nz
            Apply()
        end
    else
        local x, y, z = RayPlane(d.cx, d.cy, d.cz, d.kx, d.ky, d.kz)
        if not x then return end

        local rx, ry, rz = x - d.cx, y - d.cy, z - d.cz
        local angle = atan(d.vx * rx + d.vy * ry + d.vz * rz, d.ux * rx + d.uy * ry + d.uz * rz)
        local da = angle - d.last
        if da > PI then da = da - TWO_PI elseif da < -PI then da = da + TWO_PI end
        d.last, d.acc = angle, d.acc + da
        d.hx, d.hy, d.hz = x, y, z

        local total = d.acc
        if P.snap then
            local step = rad(Cfg.rotateSnap)
            total = floor(total / step + 0.5) * step
        end

        if total ~= d.applied then
            d.applied = total
            d.label = ('%d\194\176'):format(floor(deg(total) + (total < 0 and -0.5 or 0.5)))
            Load(s)
            RotateAround(d.kx, d.ky, d.kz, total, d.cx, d.cy, d.cz)
            Apply()
        end
    end
end

local function Tri(x1, y1, z1, x2, y2, z2, x3, y3, z3, r, g, b, a)
    _DrawPoly(x1, y1, z1, x2, y2, z2, x3, y3, z3, r, g, b, a)
    _DrawPoly(x1, y1, z1, x3, y3, z3, x2, y2, z2, r, g, b, a)
end

local function Handle() return P.drag and P.drag.i or P.hover end

local function Ribbon(ax, ay, az, ex, ey, ez, bx, by, bz, w, r, g, b, a)
    local wx, wy, wz = by * P.cfz - bz * P.cfy, bz * P.cfx - bx * P.cfz, bx * P.cfy - by * P.cfx
    local wl = sqrt(wx * wx + wy * wy + wz * wz)
    if wl < 0.05 then return end

    local k = w / wl
    wx, wy, wz = wx * k, wy * k, wz * k
    Tri(ax + wx, ay + wy, az + wz, ax - wx, ay - wy, az - wz, ex - wx, ey - wy, ez - wz, r, g, b, a)
    Tri(ax + wx, ay + wy, az + wz, ex - wx, ey - wy, ez - wz, ex + wx, ey + wy, ez + wz, r, g, b, a)
end

local function DrawLabel(x, y, z, str, r, g, b, scale)
    local ok, sx, sy = GetScreenCoordFromWorldCoord(x, y, z)
    if not ok then return end

    SetTextFont(4)
    SetTextScale(0.0, scale)
    SetTextColour(r, g, b, 255)
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(str)
    EndTextCommandDisplayText(sx, sy)
end

local function HLine(cx, cy, cz, hs, a1, b1, a2, b2, r, g, b, al)
    local rx, ry, rz, ux, uy, uz = P.crx * hs, P.cry * hs, P.crz * hs, P.cux * hs, P.cuy * hs, P.cuz * hs
    _DrawLine(cx + rx * a1 + ux * b1, cy + ry * a1 + uy * b1, cz + rz * a1 + uz * b1,
        cx + rx * a2 + ux * b2, cy + ry * a2 + uy * b2, cz + rz * a2 + uz * b2, r, g, b, al)
end

local function HTri(cx, cy, cz, hs, a1, b1, a2, b2, a3, b3, r, g, b, al)
    local rx, ry, rz, ux, uy, uz = P.crx * hs, P.cry * hs, P.crz * hs, P.cux * hs, P.cuy * hs, P.cuz * hs
    Tri(cx + rx * a1 + ux * b1, cy + ry * a1 + uy * b1, cz + rz * a1 + uz * b1,
        cx + rx * a2 + ux * b2, cy + ry * a2 + uy * b2, cz + rz * a2 + uz * b2,
        cx + rx * a3 + ux * b3, cy + ry * a3 + uy * b3, cz + rz * a3 + uz * b3, r, g, b, al)
end

local DISC_N = 28
local DISC_COS, DISC_SIN = {}, {}
for j = 0, DISC_N do
    local a = j * TWO_PI / DISC_N
    DISC_COS[j], DISC_SIN[j] = cos(a), sin(a)
end

local function HQuad(x, y, z, hs, a1, b1, a2, b2, c)
    HTri(x, y, z, hs, a1, b1, a2, b1, a2, b2, c, c, c, 255)
    HTri(x, y, z, hs, a1, b1, a2, b2, a1, b2, c, c, c, 255)
end

local function DrawSnapHandles(L, cx, cy, cz)
    local hot = Handle()
    local hs = L * 0.075

    for k = 8, 10 do
        local x, y, z = HandlePos(k, L, cx, cy, cz)
        local on = hot == k

        local pc, gc = on and 245 or 14, on and 14 or 245

        for j = 1, DISC_N do
            HTri(x, y, z, hs, 0.0, 0.0, DISC_COS[j - 1], DISC_SIN[j - 1], DISC_COS[j], DISC_SIN[j], pc, pc, pc, 255)
        end

        local gx, gy, gz = x - P.cfx * hs * 0.08, y - P.cfy * hs * 0.08, z - P.cfz * hs * 0.08

        if k == 8 then

            HQuad(gx, gy, gz, hs, -0.55, -0.62, 0.55, -0.45, gc)
            HQuad(gx, gy, gz, hs, -0.1, 0.6, 0.1, 0.0, gc)
            HTri(gx, gy, gz, hs, -0.38, 0.0, 0.38, 0.0, 0.0, -0.32, gc, gc, gc, 255)
        elseif k == 9 then

            HQuad(gx, gy, gz, hs, 0.45, -0.6, 0.62, 0.6, gc)
            HQuad(gx, gy, gz, hs, -0.6, -0.1, 0.0, 0.1, gc)
            HTri(gx, gy, gz, hs, 0.0, 0.38, 0.0, -0.38, 0.32, 0.0, gc, gc, gc, 255)
        elseif P.mode == 'move' then

            local R0, R1, a0, a1 = 0.38, 0.56, 0.7, 5.4
            for j = 1, 8 do
                local t0, t1 = a0 + (a1 - a0) * (j - 1) / 8, a0 + (a1 - a0) * j / 8
                local c0, s0, c1, s1 = cos(t0), sin(t0), cos(t1), sin(t1)
                HTri(gx, gy, gz, hs, c0 * R0, s0 * R0, c0 * R1, s0 * R1, c1 * R1, s1 * R1, gc, gc, gc, 255)
                HTri(gx, gy, gz, hs, c0 * R0, s0 * R0, c1 * R1, s1 * R1, c1 * R0, s1 * R0, gc, gc, gc, 255)
            end
            local c, sn, Rm = cos(a1), sin(a1), 0.47
            local px, py = c * Rm, sn * Rm
            HTri(gx, gy, gz, hs, px + c * 0.3, py + sn * 0.3, px - c * 0.3, py - sn * 0.3, px - sn * 0.42, py + c * 0.42, gc, gc, gc, 255)
        else

            HQuad(gx, gy, gz, hs, -0.5, -0.07, 0.5, 0.07, gc)
            HQuad(gx, gy, gz, hs, -0.07, -0.5, 0.07, 0.5, gc)
            HTri(gx, gy, gz, hs, 0.72, 0.0, 0.42, 0.26, 0.42, -0.26, gc, gc, gc, 255)
            HTri(gx, gy, gz, hs, -0.72, 0.0, -0.42, 0.26, -0.42, -0.26, gc, gc, gc, 255)
            HTri(gx, gy, gz, hs, 0.0, 0.72, 0.26, 0.42, -0.26, 0.42, gc, gc, gc, 255)
            HTri(gx, gy, gz, hs, 0.0, -0.72, 0.26, -0.42, -0.26, -0.42, gc, gc, gc, 255)
        end
    end
end

local function DrawMove(L, cx, cy, cz)
    local hot = Handle()
    local drag = P.drag

    if drag and drag.i <= 3 then
        local col = COLOR_HOT
        _DrawLine(drag.cx - drag.bx * 6.0, drag.cy - drag.by * 6.0, drag.cz - drag.bz * 6.0,
            drag.cx + drag.bx * 6.0, drag.cy + drag.by * 6.0, drag.cz + drag.bz * 6.0, col[1], col[2], col[3], 255)
    end

    for k = 1, 3 do
        local ax, ay, az = Axis(PLANE_A[k])
        local bx, by, bz = Axis(PLANE_B[k])
        local on = hot == 4 + k
        local col = on and COLOR_HOT or COLOR_AXIS[PLANE_N[k]]
        local r, g, b = col[1], col[2], col[3]
        local s0, s1 = L * 0.22, L * 0.42
        local x1, y1, z1 = cx + ax * s0 + bx * s0, cy + ay * s0 + by * s0, cz + az * s0 + bz * s0
        local x2, y2, z2 = cx + ax * s1 + bx * s0, cy + ay * s1 + by * s0, cz + az * s1 + bz * s0
        local x3, y3, z3 = cx + ax * s1 + bx * s1, cy + ay * s1 + by * s1, cz + az * s1 + bz * s1
        local x4, y4, z4 = cx + ax * s0 + bx * s1, cy + ay * s0 + by * s1, cz + az * s0 + bz * s1
        local fa = on and 215 or 150
        Tri(x1, y1, z1, x2, y2, z2, x3, y3, z3, r, g, b, fa)
        Tri(x1, y1, z1, x3, y3, z3, x4, y4, z4, r, g, b, fa)
        _DrawLine(x1, y1, z1, x2, y2, z2, r, g, b, 255)
        _DrawLine(x2, y2, z2, x3, y3, z3, r, g, b, 255)
        _DrawLine(x3, y3, z3, x4, y4, z4, r, g, b, 255)
        _DrawLine(x4, y4, z4, x1, y1, z1, r, g, b, 255)
    end

    for i = 1, 3 do
        local bx, by, bz = Axis(i)
        local on = hot == i
        local col = on and COLOR_HOT or COLOR_AXIS[i]
        local r, g, b = col[1], col[2], col[3]
        local s0, s1 = L * 0.14, L * 0.8

        Ribbon(cx + bx * s0, cy + by * s0, cz + bz * s0, cx + bx * s1, cy + by * s1, cz + bz * s1,
            bx, by, bz, L * (on and 0.024 or 0.018), r, g, b, 255)

        local ux, uy, uz, vx, vy, vz = Perp(bx, by, bz)
        local rad = L * (on and 0.05 or 0.04)
        local hx, hy, hz = cx + bx * s1, cy + by * s1, cz + bz * s1
        local tx, ty, tz = cx + bx * L, cy + by * L, cz + bz * L
        local px, py, pz = hx + (ux * CONE_COS[1] + vx * CONE_SIN[1]) * rad,
            hy + (uy * CONE_COS[1] + vy * CONE_SIN[1]) * rad,
            hz + (uz * CONE_COS[1] + vz * CONE_SIN[1]) * rad

        for j = 2, CONE_N + 1 do
            local c, s = CONE_COS[j], CONE_SIN[j]
            local qx, qy, qz = hx + (ux * c + vx * s) * rad, hy + (uy * c + vy * s) * rad, hz + (uz * c + vz * s) * rad
            Tri(tx, ty, tz, px, py, pz, qx, qy, qz, r, g, b, 255)
            px, py, pz = qx, qy, qz
        end
    end

    local on = hot == 4
    local col = on and COLOR_HOT or COLOR_CENTER
    local r, g, b = col[1], col[2], col[3]
    local q = L * (on and 0.05 or 0.04)
    local ax, ay, az = P.crx * q, P.cry * q, P.crz * q
    local bx, by, bz = P.cux * q, P.cuy * q, P.cuz * q
    Tri(cx + ax, cy + ay, cz + az, cx + bx, cy + by, cz + bz, cx - ax, cy - ay, cz - az, r, g, b, 255)
    Tri(cx + ax, cy + ay, cz + az, cx - ax, cy - ay, cz - az, cx - bx, cy - by, cz - bz, r, g, b, 255)
end

local function DrawRotate(L, cx, cy, cz, dist)
    L = RingSize(L)
    local hot = Handle()
    local drag = P.drag

    local tcx, tcy, tcz = (P.ox - cx) / dist, (P.oy - cy) / dist, (P.oz - cz) / dist
    local thr = min(L / dist, 0.9)
    local th = L * 0.009

    for i = 1, 3 do
        local kx, ky, kz = Axis(i)
        local ux, uy, uz, vx, vy, vz = Perp(kx, ky, kz)
        local on = hot == i
        local col = on and COLOR_HOT or COLOR_AXIS[i]
        local r, g, b = col[1], col[2], col[3]
        local alpha = 255

        local px, py, pz = cx + ux * L, cy + uy * L, cz + uz * L
        local pf = (ux * tcx + uy * tcy + uz * tcz) > thr
        for j = 1, RING_N do
            local c, s = RING_COS[j], RING_SIN[j]
            local ox, oy, oz = ux * c + vx * s, uy * c + vy * s, uz * c + vz * s
            local x, y, z = cx + ox * L, cy + oy * L, cz + oz * L
            local f = (ox * tcx + oy * tcy + oz * tcz) > thr

            if f and pf then

                local w = on and th * 1.9 or th
                local ex, ey, ez = ox * w, oy * w, oz * w
                _DrawLine(px, py, pz, x, y, z, r, g, b, alpha)
                _DrawLine(px + ex, py + ey, pz + ez, x + ex, y + ey, z + ez, r, g, b, alpha)
                _DrawLine(px - ex, py - ey, pz - ez, x - ex, y - ey, z - ez, r, g, b, alpha)
            end
            px, py, pz, pf = x, y, z, f
        end
    end

    if drag and drag.i <= 3 then
        local total = drag.applied
        local n = min(floor(abs(total) / 0.1745) + 1, 36)
        local col = COLOR_HOT
        local r, g, b = col[1], col[2], col[3]
        local a0 = drag.a0
        local pc, ps = cos(a0), sin(a0)
        local px, py, pz = cx + (drag.ux * pc + drag.vx * ps) * L, cy + (drag.uy * pc + drag.vy * ps) * L, cz + (drag.uz * pc + drag.vz * ps) * L

        _DrawLine(cx, cy, cz, px, py, pz, r, g, b, 255)
        for j = 1, n do
            local a = a0 + total * j / n
            local c, s = cos(a), sin(a)
            local x, y, z = cx + (drag.ux * c + drag.vx * s) * L, cy + (drag.uy * c + drag.vy * s) * L, cz + (drag.uz * c + drag.vz * s) * L
            Tri(cx, cy, cz, px, py, pz, x, y, z, r, g, b, 120)
            px, py, pz = x, y, z
        end
        _DrawLine(cx, cy, cz, px, py, pz, r, g, b, 255)

        DrawLabel(cx + (px - cx) * 1.18, cy + (py - cy) * 1.18, cz + (pz - cz) * 1.18, drag.label, 255, 255, 255, 0.42)
    end
end

local function Draw()
    local cx, cy, cz = Center()
    local L, dist = GizmoSize(cx, cy, cz)
    if P.mode == 'move' then DrawMove(L, cx, cy, cz) else DrawRotate(L, cx, cy, cz, dist) end
    DrawSnapHandles(L, cx, cy, cz)
end

local function EnterCamera()
    if P.cam or not P.open then return end

    P.cam, P.drag, P.zoom, P.camAt = true, nil, 0, GetGameTimer()
    SetHover(0)

    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'PLACEMENT_CAMERA', active = true })
end

local function ExitCamera()
    if not P.cam then return end

    P.cam, P.dirty = false, true
    UpdateCamera()
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
    SendNUIMessage({ type = 'PLACEMENT_CAMERA', active = false })
end

local function CameraStep()
    local cs, fc = Config.CameraSettings, FreeCam
    local changed = false

    DisableControlAction(0, 1, true)
    DisableControlAction(0, 2, true)
    DisableControlAction(0, 25, true)
    DisableControlAction(0, 73, true)
    DisableControlAction(0, 194, true)
    DisableControlAction(0, 241, true)
    DisableControlAction(0, 242, true)

    if IsDisabledControlJustPressed(0, 200) or IsDisabledControlJustPressed(0, 73) or IsDisabledControlJustPressed(0, 194) then
        PreviewTv.accepted = false
        return
    end

    if GetGameTimer() - P.camAt > 250 and IsDisabledControlJustPressed(0, 25) then
        ExitCamera()
        return
    end

    local lx, ly = GetDisabledControlNormal(0, 1), GetDisabledControlNormal(0, 2)
    if lx ~= 0.0 or ly ~= 0.0 then

        local sens = cs.lookSensitivity * fc.fov / 60.0
        fc.yaw = fc.yaw - lx * sens
        fc.pitch = max(-89.0, min(89.0, fc.pitch - ly * sens))
        UpdateCamera()
        changed = true
    end

    local mx, my, mz = 0.0, 0.0, 0.0
    if IsDisabledControlPressed(0, 32) then mx, my, mz = mx + P.cfx, my + P.cfy, mz + P.cfz end
    if IsDisabledControlPressed(0, 33) then mx, my, mz = mx - P.cfx, my - P.cfy, mz - P.cfz end
    if IsDisabledControlPressed(0, 34) then mx, my, mz = mx - P.crx, my - P.cry, mz - P.crz end
    if IsDisabledControlPressed(0, 35) then mx, my, mz = mx + P.crx, my + P.cry, mz + P.crz end
    local ml = sqrt(mx * mx + my * my + mz * mz)
    if ml > 0.0 then
        local k = cs.moveSpeed * GetFrameTime() / ml
        local nx, ny, nz = P.ox + mx * k, P.oy + my * k, P.oz + mz * k
        if InRange(nx, ny, nz) then
            fc.coords = vector3(nx, ny, nz)
            changed = true
        end
    end

    if IsDisabledControlJustPressed(0, 241) then fc.fov, changed = fc.fov - cs.zoomSpeed * 2.0, true end
    if IsDisabledControlJustPressed(0, 242) then fc.fov, changed = fc.fov + cs.zoomSpeed * 2.0, true end

    if changed then
        UpdateCamera()
        fc.fov = max(MinFov(), min(fc.fov, cs.maxFov))
        P.tanH = tan(rad(fc.fov) * 0.5)

        local c = fc.coords
        SetCamCoord(Camera, c.x, c.y, c.z)
        SetCamRot(Camera, fc.pitch, 0.0, fc.yaw, 2)
        SetCamFov(Camera, fc.fov)
    end
end

local function CursorStep()
    if not P.ready then
        if GetGameTimer() < P.readyAt then return end
        P.ready, P.dirty = true, true
    end

    local x, y = _GetNuiCursorPosition()
    if x ~= P.cx or y ~= P.cy or P.dirty then
        P.cx, P.cy, P.dirty = x, y, false
        UpdateRay()

        if P.drag then
            DragStep()
        else
            UpdateHover()
        end
    end
end

local function Step()

    lib.disableControls()
    DisableControlAction(0, 199, true)
    DisableControlAction(0, 200, true)

    if P.cam then CameraStep() else CursorStep() end
    if P.ready then Draw() end
end

local function Loop()
    while P.active and PreviewTv ~= nil and PreviewTv.accepted == nil do
        Wait(0)

        local t = (PreviewTv.timeout or 18000) - 1
        PreviewTv.timeout = t
        if t <= 0 then
            Config.Debug("[^2INFO - TV PLACING^0] TV placement timed out.")
            PreviewTv.accepted = false
            PreviewTv.reason = "place_timeout"
            break
        end

        if not DoesEntityExist(P.entity) then
            Config.Debug("[^2WARNING - TV PLACING^0] The preview TV no longer exists, cancelling the placement.")
            PreviewTv.accepted = false
            PreviewTv.reason = "place_cancelled"
            break
        end

        local ok, err = pcall(Step)
        if not ok then
            Config.Debug(("[^1ERROR - TV PLACING^0] Placement frame failed, cancelling: %s"):format(tostring(err)))
            PreviewTv.accepted = false
            PreviewTv.reason = "place_cancelled"
            break
        end
    end

    P.active = false
end

local function SetMode(mode, notify)
    P.mode, P.drag, P.dirty = mode, nil, true
    SetHover(0)
    if notify then SendNUIMessage({ type = 'PLACEMENT_MODE', mode = mode }) end
end

local function SpinBy(dg)
    local cx, cy, cz = Center()
    RotateAround(0.0, 0.0, 1.0, rad(dg), cx, cy, cz)
    Apply()
    P.dirty = true
end

function Placement.Start()
    if P.open or PreviewTv == nil or PreviewTv.entity == nil or FreeCam == nil or Camera == nil then return false end

    local entity = PreviewTv.entity
    if not DoesEntityExist(entity) then return false end

    local mn, mx = GetModelDimensions(GetEntityModel(entity))
    local w, h = GetActiveScreenResolution()
    if not w or not h or w <= 0 or h <= 0 then w, h = 1920, 1080 end
    local first = PreviewTv.firstcoords or GetEntityCoords(entity)
    local po, cs = Config.PlaceOptions or {}, Config.CameraSettings or {}

    P.entity = entity
    P.bcx, P.bcy, P.bcz = (mn.x + mx.x) * 0.5, (mn.y + mx.y) * 0.5, (mn.z + mx.z) * 0.5
    P.minY, P.maxY, P.minZ, P.maxZ = mn.y, mx.y, mn.z, mx.z
    P.radius = max(#(mx - mn) * 0.5, 0.1)
    P.sw, P.sh, P.aspect = w, h, w / h
    P.startx, P.starty, P.startz = first.x, first.y, first.z
    local maxDist = tonumber(po.maxDistance) or 10.0
    P.maxDist2 = maxDist * maxDist

    SyncFromEntity()
    P.initial = Save({})
    P.spin, P.roll, P.surf = 0.0, 0.0, 'floor'
    P.mode, P.space, P.snap = 'move', 'world', Cfg.snap == true
    P.hover, P.drag, P.outOfRange, P.cam = 0, nil, false, false
    P.cx, P.cy, P.dirty = -1, -1, true
    P.ready, P.readyAt = false, GetGameTimer() + (tonumber(cs.transitionTime) or 1000)
    UpdateCamera()

    P.open, P.active = true, true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
    SendNUIMessage({
        type = 'PLACEMENT_OPEN',
        data = {
            mode = P.mode, space = P.space, snap = P.snap,
            snapDeg = Cfg.rotateSnap, steps = Cfg.nudgeSteps,
        }
    })

    CreateThread(Loop)
    return true
end

function Placement.Stop()
    if not P.open then return end

    P.open, P.active, P.cam, P.drag = false, false, false, nil
    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'PLACEMENT_CLOSE' })
end

local function Usable() return P.open and P.ready and not P.cam end

RegisterNUICallback('placementPointer', function(data, cb)
    if type(data) ~= 'table' then data = {} end
    cb('ok')
    if not P.open or not P.ready then return end

    local button = data.button
    if button == 2 then
        if data.down == true then EnterCamera() end
    elseif P.cam then
        return
    elseif button == 0 then
        if data.down == true then
            if P.hover == 8 then SnapFloor()
            elseif P.hover == 9 then SnapWall()
            elseif P.hover == 10 then SetMode(P.mode == 'move' and 'rotate' or 'move', true)
            elseif P.hover > 0 then StartDrag() end
        else
            EndDrag()
        end
    end
end)

RegisterNUICallback('placementWheel', function(data, cb)
    if type(data) ~= 'table' then data = {} end
    cb('ok')
    if not P.open or not P.ready then return end

    local dir = tonumber(data.dir)
    if not dir then return end

    if not P.cam then SpinBy((dir < 0 and -1 or 1) * (P.snap and Cfg.spinStep or Cfg.spinFine)) end
end)

RegisterNUICallback('placementSpin', function(data, cb)
    if type(data) ~= 'table' then data = {} end
    cb('ok')
    if not Usable() then return end

    local dir = tonumber(data.dir)
    if not dir then return end
    SpinBy((dir < 0 and -1 or 1) * (P.snap and Cfg.spinStep or Cfg.spinFine))
end)

RegisterNUICallback('placementMode', function(data, cb)
    if type(data) ~= 'table' then data = {} end
    cb('ok')
    if not P.open or not MODES[data.mode] then return end
    SetMode(data.mode, false)
end)

RegisterNUICallback('placementSpace', function(data, cb)
    if type(data) ~= 'table' then data = {} end
    cb('ok')
    if not P.open or not SPACES[data.space] then return end
    P.space, P.dirty = data.space, true
end)

RegisterNUICallback('placementSnap', function(data, cb)
    if type(data) ~= 'table' then data = {} end
    cb('ok')
    if not P.open then return end
    P.snap = data.snap == true
end)

RegisterNUICallback('placementNudge', function(data, cb)
    if type(data) ~= 'table' then data = {} end
    cb('ok')
    if not Usable() then return end

    local i, dir, step = AXIS_INDEX[data.axis], tonumber(data.dir), tonumber(data.step)
    if not i or not dir or not step then return end

    step = min(abs(step), 1.0) * (dir < 0 and -1 or 1)
    local bx, by, bz = Axis(i)
    local x, y, z = P.px + bx * step, P.py + by * step, P.pz + bz * step
    if not InRange(x, y, z) then return end

    P.px, P.py, P.pz = x, y, z
    Apply()
    P.dirty = true
end)

RegisterNUICallback('placementGround', function(_, cb)
    cb('ok')
    if not Usable() then return end

    PlaceObjectOnGroundProperly(P.entity)
    SyncFromEntity()
    P.dirty = true
end)

RegisterNUICallback('placementReset', function(_, cb)
    cb('ok')
    if not Usable() then return end

    Load(P.initial)
    P.spin, P.roll = 0.0, 0.0
    Apply()
    P.dirty = true
end)

RegisterNUICallback('placementAccept', function(_, cb)
    cb('ok')
    if not P.open or PreviewTv.accepted ~= nil then return end
    Config.Debug("[^2INFO - TV PLACING^0] Player accepted the TV placement.")
    PreviewTv.accepted = true
end)

RegisterNUICallback('placementCancel', function(_, cb)
    cb('ok')
    if not P.open or PreviewTv.accepted ~= nil then return end
    Config.Debug("[^2INFO - TV PLACING^0] Player cancelled the TV placement.")
    PreviewTv.accepted = false
end)
