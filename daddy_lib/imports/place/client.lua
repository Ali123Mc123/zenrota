-- Crosshair placement: a wall surface from three corners, then an optional floor zone.
-- Both block the calling thread and return nil when cancelled.
local place = {}

local KEY_PICK, KEY_DONE, KEY_DONE_PAD, KEY_UNDO, KEY_CANCEL = 38, 191, 201, 177, 200
local MARK = { 255, 180, 60 }

local function direction(rot)
    local z, x = math.rad(rot.z), math.rad(rot.x)
    local cosX = math.abs(math.cos(x))
    return vector3(-math.sin(z) * cosX, math.cos(z) * cosX, math.sin(x))
end

-- Camera ray; option 0 also catches MLO walls that the default flags skip.
local function aim()
    local from = GetFinalRenderedCamCoord()
    local to = from + direction(GetFinalRenderedCamRot(2)) * 50.0
    for _, option in ipairs({ 7, 0 }) do
        local handle = StartExpensiveSynchronousShapeTestLosProbe(from.x, from.y, from.z, to.x, to.y, to.z, 511, PlayerPedId(), option)
        local _, hit, coords = GetShapeTestResult(handle)
        if hit == 1 and #coords > 0.01 then return coords end
    end
end

local function pressed(control)
    return IsDisabledControlJustPressed(0, control)
end

local function dot(point, size, color)
    DrawMarker(28, point.x, point.y, point.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, size, size, size, color[1], color[2], color[3], 230, false, false, 2, false, nil, nil, false)
end

local function line(a, b, alpha)
    DrawLine(a.x, a.y, a.z, b.x, b.y, b.z, 255, 255, 255, alpha or 220)
end

local function crosshair()
    DrawRect(0.5, 0.5, 0.012, 0.002, 255, 255, 255, 220)
    DrawRect(0.5, 0.5, 0.002, 0.020, 255, 255, 255, 220)
end

-- Runs step(cursor) every frame until it returns a result; Esc returns nil.
local function session(step)
    local hud, result, cancelled
    repeat
        for _, control in ipairs({ KEY_PICK, KEY_DONE, KEY_DONE_PAD, KEY_UNDO, KEY_CANCEL }) do DisableControlAction(0, control, true) end
        crosshair()
        local text
        result, text = step(aim())
        if text and text ~= hud then
            hud = text
            lib.showTextUI(text, { position = 'top-center' })
        end
        cancelled = result == nil and pressed(KEY_CANCEL)
        Wait(0)
    until result ~= nil or cancelled
    lib.hideTextUI()
    return result
end

-- Top-left, top-right, bottom-left corners -> { coords, heading, width, height }.
function place.surface(options)
    options = options or {}
    local corners, geometry = {}, nil
    return session(function(cursor)
        if cursor and #corners < 3 then dot(cursor, 0.05, MARK) end
        for i, corner in ipairs(corners) do
            dot(corner, 0.08, MARK)
            if i > 1 then line(corners[1], corner) end
        end
        if geometry then
            local a, b, c = corners[1], corners[2], corners[3]
            local d = b + (c - a)
            line(b, d, 160)
            line(c, d, 160)
        end

        if pressed(KEY_PICK) and cursor and #corners < 3 then
            corners[#corners + 1] = cursor
            if #corners == 3 then
                local a, b, c = corners[1], corners[2], corners[3]
                geometry = {
                    coords = (b + c) * 0.5,
                    heading = (math.deg(math.atan(b.y - a.y, b.x - a.x)) - 90.0) % 360.0,
                    width = DL.util.clamp(#(b - a), 0.2, 8.0),
                    height = DL.util.clamp(#(c - a), 0.2, 8.0),
                }
                if options.preview then options.preview(geometry) end
            end
        elseif pressed(KEY_UNDO) and #corners > 0 then
            corners, geometry = {}, nil
            if options.preview then options.preview(nil) end
        elseif geometry and (pressed(KEY_DONE) or pressed(KEY_DONE_PAD)) then
            return geometry
        end

        if geometry then
            return nil, DL.locale.lib('place.surface_ready', geometry.width, geometry.height)
        end
        return nil, DL.locale.lib(('place.corner_%d'):format(#corners + 1))
    end)
end

-- Floor points -> { points, minZ, maxZ }; Enter with no points returns false (no zone).
function place.zone(options)
    options = options or {}
    local maxPoints = options.maxPoints or 8
    local points = {}
    return session(function(cursor)
        for i, point in ipairs(points) do
            dot(point, 0.1, MARK)
            if i > 1 then line(points[i - 1], point) end
        end
        if #points > 2 then line(points[#points], points[1], 160) end
        if cursor and #points < maxPoints then
            dot(cursor, 0.06, MARK)
            if #points > 0 then line(points[#points], cursor, 120) end
        end

        if pressed(KEY_PICK) and cursor and #points < maxPoints then
            points[#points + 1] = cursor
        elseif pressed(KEY_UNDO) and #points > 0 then
            points[#points] = nil
        elseif pressed(KEY_DONE) or pressed(KEY_DONE_PAD) then
            if #points == 0 and options.optional then return false end
            if #points >= 3 then
                local list = {}
                for i, point in ipairs(points) do list[i] = { x = point.x, y = point.y, z = point.z } end
                return DL.geo.zone({ points = list }, options.margin)
            end
        end

        return nil, DL.locale.lib(options.optional and 'place.zone_optional' or 'place.zone', #points, maxPoints)
    end)
end

return place
