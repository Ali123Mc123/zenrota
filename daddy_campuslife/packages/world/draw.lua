-- Drawing world shapes for one frame: the editor's preview and the admin's debug view use the same lines,
-- so what is placed looks exactly like what is saved. Call every frame.
World = World or {}
World.draw = {}

-- Gold for the focused record, red for an inactive or invalid one, green for a placed point.
World.draw.colors = {
    focused = { 250, 204, 21 }, inactive = { 239, 68, 68 }, valid = { 34, 197, 94 }, invalid = { 239, 68, 68 },
}

-- '#D43D45' -> { 212, 61, 69 }
function World.draw.rgb(hex)
    hex = tostring(hex or ''):gsub('#', '')
    return { tonumber(hex:sub(1, 2), 16) or 46, tonumber(hex:sub(3, 4), 16) or 123, tonumber(hex:sub(5, 6), 16) or 255 }
end

-- A wall seen from both sides (one DrawPoly is invisible from behind).
local function wall(x1, y1, x2, y2, low, high, c, alpha)
    local r, g, b = c[1], c[2], c[3]
    DrawPoly(x1, y1, low, x2, y2, low, x2, y2, high, r, g, b, alpha)
    DrawPoly(x1, y1, low, x2, y2, high, x1, y1, high, r, g, b, alpha)
    DrawPoly(x2, y2, high, x2, y2, low, x1, y1, low, r, g, b, alpha)
    DrawPoly(x1, y1, high, x2, y2, high, x1, y1, low, r, g, b, alpha)
end

-- Floor or ceiling as a fan; right for convex outlines.
local function cap(points, z, c, alpha)
    local p1 = points[1]
    for i = 2, #points - 1 do
        local p2, p3 = points[i], points[i + 1]
        DrawPoly(p1.x, p1.y, z, p2.x, p2.y, z, p3.x, p3.y, z, c[1], c[2], c[3], alpha)
        DrawPoly(p3.x, p3.y, z, p2.x, p2.y, z, p1.x, p1.y, z, c[1], c[2], c[3], alpha)
    end
end

function World.draw.dot(x, y, z, c, size, alpha)
    size = size or 0.2
    DrawMarker(28, x, y, z, 0, 0, 0, 0, 0, 0, size, size, size, c[1], c[2], c[3], alpha or 220, false, false, 2, false, nil, nil, false)
end

local function line(a, b, c, alpha)
    DrawLine(a.x, a.y, a.z, b.x, b.y, b.z, c[1], c[2], c[3], alpha)
end
World.draw.line = line

-- A corner the editor can grab: a ball on a post down to the floor, bigger while the cursor is on it.
function World.draw.handle(p, floor, c, hot)
    World.draw.dot(p.x, p.y, p.z, c, hot and 0.32 or 0.2, hot and 255 or 210)
    if floor and floor < p.z then line({ x = p.x, y = p.y, z = floor }, p, c, 160) end
end

-- The eight corners of a turned box: bottom four, top four.
local function boxCorners(shape)
    local c, s = shape.center, shape.size
    local rot = math.rad(shape.rotation or 0.0)
    local cos, sin = math.cos(rot), math.sin(rot)
    local low, high = {}, {}
    for i, o in ipairs({ { -1, -1 }, { 1, -1 }, { 1, 1 }, { -1, 1 } }) do
        local lx, ly = o[1] * s.x * 0.5, o[2] * s.y * 0.5
        local x, y = c.x + lx * cos - ly * sin, c.y + lx * sin + ly * cos
        low[i], high[i] = { x = x, y = y, z = c.z - s.z * 0.5 }, { x = x, y = y, z = c.z + s.z * 0.5 }
    end
    return low, high
end

-- Text with a dark plate, centred on a world point.
function World.draw.label(x, y, z, text, c)
    local onScreen, sx, sy = World3dToScreen2d(x, y, z)
    if not onScreen then return end
    SetTextScale(0.30, 0.30)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(c and c[1] or 255, c and c[2] or 255, c and c[3] or 255, 240)
    SetTextCentre(true)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(sx, sy)
    DrawRect(sx, sy + 0.012, 0.015 + #text / 360, 0.024, 10, 12, 18, 210)
end

-- style: { color = {r,g,b}, focused, faint (other places behind the editor), label, corners = false }
function World.draw.shape(shape, style)
    if type(shape) ~= 'table' then return end
    style = style or {}
    local c, focused, faint = style.color or { 255, 255, 255 }, style.focused == true, style.faint == true
    local edge, side, lid = focused and 255 or 210, focused and 160 or 100, focused and 85 or 45
    if faint then edge, side, lid = 120, 28, 10 end
    local top

    if shape.shape == 'polygon' and shape.points and #shape.points >= 3 then
        local points, low = shape.points, shape.minZ or 0.0
        local high = shape.maxZ or low + 3.0
        for i, a in ipairs(points) do
            local b = points[i % #points + 1]
            wall(a.x, a.y, b.x, b.y, low, high, c, side)
            line({ x = a.x, y = a.y, z = low }, { x = b.x, y = b.y, z = low }, c, edge)
            line({ x = a.x, y = a.y, z = high }, { x = b.x, y = b.y, z = high }, c, edge)
            line({ x = a.x, y = a.y, z = low }, { x = a.x, y = a.y, z = high }, c, focused and 255 or edge)
            if style.corners ~= false and not faint then
                World.draw.dot(a.x, a.y, low, c)
                World.draw.dot(a.x, a.y, high, c)
            end
        end
        cap(points, low, c, lid)
        cap(points, high, c, lid)
        top = high
    elseif shape.shape == 'sphere' and shape.center then
        local p, d = shape.center, (shape.radius or 1.0) * 2.0
        DrawMarker(28, p.x, p.y, p.z, 0, 0, 0, 0, 0, 0, d, d, d, c[1], c[2], c[3], faint and 30 or focused and 120 or 70, false, false, 2, false, nil, nil, false)
        top = p.z + (shape.radius or 1.0)
    elseif shape.shape == 'box' and shape.center and shape.size then
        local low, high = boxCorners(shape)
        for i = 1, 4 do
            local n = i % 4 + 1
            wall(low[i].x, low[i].y, low[n].x, low[n].y, low[i].z, high[i].z, c, side)
            line(low[i], low[n], c, edge)
            line(high[i], high[n], c, edge)
            line(low[i], high[i], c, edge)
        end
        cap(low, low[1].z, c, lid)
        cap(high, high[1].z, c, lid)
        top = high[1].z
    elseif shape.center then
        local p = shape.center
        World.draw.dot(p.x, p.y, p.z + 0.03, c, 0.15, faint and 120 or nil)
        if (shape.radius or 0) > 0.15 then
            local d = shape.radius * 2.0
            DrawMarker(1, p.x, p.y, p.z - 0.95, 0, 0, 0, 0, 0, 0, d, d, 1.0, c[1], c[2], c[3], 40, false, false, 2, false, nil, nil, false)
        end
        top = p.z + 1.0
    end

    if top and not faint and style.label and style.label ~= '' then
        local center = DL.geo.centroid(shape)
        if center then World.draw.label(center.x, center.y, top + 0.3, style.label, c) end
    end
end
