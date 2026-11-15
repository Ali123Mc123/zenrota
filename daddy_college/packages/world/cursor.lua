-- The mouse in the world while a script camera runs: the game's own cursor, the ray under it and how close it
-- is to a point drawn on screen.
World = World or {}
World.cursor = {}

-- Forward, right and up of a camera rotation (no roll).
local function basis(rotation)
    local z, x = math.rad(rotation.z), math.rad(rotation.x)
    local c = math.cos(x)
    local forward = vector3(-math.sin(z) * c, math.cos(z) * c, math.sin(x))
    local right = vector3(math.cos(z), math.sin(z), 0.0)
    local up = vector3(right.y * forward.z - right.z * forward.y, right.z * forward.x - right.x * forward.z, right.x * forward.y - right.y * forward.x)
    return forward, right, up
end

-- Shows the cursor this frame; sprite 1 is the arrow, 3 an open hand, 4 a closed one, 11 an arrow with a plus.
function World.cursor.show(sprite)
    SetMouseCursorActiveThisFrame()
    SetMouseCursorSprite(sprite or 1)
end

local outside -- { x, y } when a page owns the mouse and tells where it is

-- Where the cursor is, from 0 to 1 across and down the screen.
function World.cursor.position()
    if outside then return outside.x, outside.y end
    return GetDisabledControlNormal(0, 239), GetDisabledControlNormal(0, 240)
end

-- A page with the focus moves the pointer instead of the game; nil hands it back.
function World.cursor.use(x, y)
    outside = x and { x = x, y = y } or nil
end

-- The ray under the cursor: origin and unit direction.
function World.cursor.ray()
    local origin, rotation = GetFinalRenderedCamCoord(), GetFinalRenderedCamRot(2)
    local forward, right, up = basis(rotation)
    local x, y = World.cursor.position()
    local v = math.tan(math.rad(GetFinalRenderedCamFov()) * 0.5)
    local dir = forward + right * ((x * 2.0 - 1.0) * v * GetAspectRatio(false)) + up * ((1.0 - y * 2.0) * v)
    return origin, dir / #dir
end

-- What the cursor points at (map and props), or nil over the sky.
function World.cursor.hit(range, ignore)
    local from, dir = World.cursor.ray()
    local to = from + dir * (range or 300.0)
    local probe = StartExpensiveSynchronousShapeTestLosProbe(from.x, from.y, from.z, to.x, to.y, to.z, 1 | 16, ignore or 0, 7)
    local _, hit, coords = GetShapeTestResult(probe)
    if hit ~= 1 then return nil end
    return vector3(coords.x, coords.y, coords.z)
end

-- How far the cursor is from a world point on screen, in screen heights; nil when the point is off screen.
function World.cursor.distanceTo(x, y, z)
    local onScreen, sx, sy = GetScreenCoordFromWorldCoord(x, y, z)
    if not onScreen then return nil end
    local cx, cy = World.cursor.position()
    local dx = (sx - cx) * GetAspectRatio(false)
    return math.sqrt(dx * dx + (sy - cy) * (sy - cy))
end
