-- Admin tool: mark a place on the map. Inside an MLO the zone fits the building by itself, otherwise it is a box you size
-- with the arrow keys. The loops here only run while a tool or the zone view of the admin window is on.

local KEY = { next = 191, cancel = 73, here = 47, up = 172, down = 173, left = 174, right = 175, scrollUp = 241, scrollDown = 242, higher = 10, lower = 11, fine = 21 }

local busy = false
local overview = false
local aboveCam -- the camera of fromAbove while it runs, so a resource stop can give the normal camera back

local function ground()
    local at = GetEntityCoords(cache.ped)
    return { x = at.x, y = at.y, z = at.z - 1.0 }
end

local function pressed(key) return IsControlJustPressed(0, key) end
local function held(key) return IsControlPressed(0, key) end

local function blockControls()
    for _, control in ipairs({ 14, 15, 16, 17, 24, 25, 27, 37, 99, 100, 261, 262 }) do DisableControlAction(0, control, true) end
end

local function outline(poly, minZ, maxZ, r, g, b)
    for i = 1, #poly do
        local a, c = poly[i], poly[i % #poly + 1]
        DrawLine(a.x, a.y, minZ, c.x, c.y, minZ, r, g, b, 200)
        DrawLine(a.x, a.y, maxZ, c.x, c.y, maxZ, r, g, b, 200)
        DrawLine(a.x, a.y, minZ, a.x, a.y, maxZ, r, g, b, 120)
    end
end

local function spot(at, r, g, b)
    DrawMarker(28, at.x, at.y, at.z + 0.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, r, g, b, 200, false, false, 2, false, nil, nil, false)
end

local function label(at, text)
    SetDrawOrigin(at.x, at.y, at.z, 0)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

local templates = {}

local function fetch()
    local res = lib.callback.await('daddy_venue:placeList', false)
    if res and res.ok then templates = res.templates or {} end
    return res and res.ok and res.places or nil
end

local function save(body)
    local res = lib.callback.await('daddy_venue:placeSave', false, body)
    if res and res.ok then
        lib.notify({ type = 'success', description = L('zone_saved', res.id) })
    else
        lib.notify({ type = 'error', description = L('zone_failed', res and res.error or '-') })
    end
    return res and res.ok
end

-- the rooms of the MLO you stand in, as one box turned like the building
local function fromInterior()
    local interior = GetInteriorFromEntity(cache.ped)
    if not interior or interior == 0 then return nil end
    local lo, hi
    for room = 1, GetInteriorRoomCount(interior) - 1 do
        local ax, ay, az, bx, by, bz = GetInteriorRoomExtents(interior, room)
        if ax and bx then
            lo = lo and vec3(math.min(lo.x, ax), math.min(lo.y, ay), math.min(lo.z, az)) or vec3(ax, ay, az)
            hi = hi and vec3(math.max(hi.x, bx), math.max(hi.y, by), math.max(hi.z, bz)) or vec3(bx, by, bz)
        end
    end
    if not lo then return nil end
    local w, l, height = hi.x - lo.x, hi.y - lo.y, hi.z - lo.z
    if w < 2.0 or l < 2.0 or w > 150.0 or l > 150.0 or height > 60.0 then return nil end

    local px, py, pz = GetInteriorPosition(interior)
    local qx, qy, qz, qw = GetInteriorRotation(interior)
    local yaw = math.atan(2.0 * (qw * qz + qx * qy), 1.0 - 2.0 * (qy * qy + qz * qz))
    local mx, my = (lo.x + hi.x) / 2, (lo.y + hi.y) / 2
    return {
        x = px + mx * math.cos(yaw) - my * math.sin(yaw), y = py + mx * math.sin(yaw) + my * math.cos(yaw), z = pz + lo.z,
        w = w, l = l, h = math.deg(yaw) % 360, height = math.max(height, 3.0),
    }
end

local function aroundMe()
    local at = ground()
    return { x = at.x, y = at.y, z = at.z, w = 10.0, l = 10.0, h = GetEntityHeading(cache.ped), height = Config.Places.Height }
end

local function corners(box)
    local h = math.rad(box.h)
    local rx, ry = math.cos(h) * box.w / 2, math.sin(h) * box.w / 2
    local fx, fy = -math.sin(h) * box.l / 2, math.cos(h) * box.l / 2
    return {
        { x = box.x - rx - fx, y = box.y - ry - fy, z = box.z },
        { x = box.x + rx - fx, y = box.y + ry - fy, z = box.z },
        { x = box.x + rx + fx, y = box.y + ry + fy, z = box.z },
        { x = box.x - rx + fx, y = box.y - ry + fy, z = box.z },
    }
end

local function drawBox(box, r, g, b)
    local poly = corners(box)
    outline(poly, box.z, box.z + box.height, r, g, b)
    local z = box.z + 0.02
    local a, c, d, e = poly[1], poly[2], poly[3], poly[4]
    DrawPoly(a.x, a.y, z, c.x, c.y, z, d.x, d.y, z, r, g, b, 40)
    DrawPoly(a.x, a.y, z, d.x, d.y, z, e.x, e.y, z, r, g, b, 40)
    DrawPoly(d.x, d.y, z, c.x, c.y, z, a.x, a.y, z, r, g, b, 40)
    DrawPoly(e.x, e.y, z, d.x, d.y, z, a.x, a.y, z, r, g, b, 40)
end

local function drawOthers(others, skip)
    for _, place in ipairs(others) do
        if place.id ~= skip then outline(place.poly, place.minZ, place.maxZ, 90, 90, 90) end
    end
end

-- size the box, true when confirmed
local function shape(box, others, skip, fitted)
    lib.showTextUI(table.concat({
        fitted and L('zone_fitted') or L('zone_size'),
        L('zone_box_keys'),
        L('zone_done_keys'),
    }, '  \n'))
    local ok = false
    while busy do
        Wait(0)
        blockControls()
        drawOthers(others, skip)
        drawBox(box, 61, 220, 151)
        label(vec3(box.x, box.y, box.z + 1.0), L('zone_box_size', box.w, box.l, box.height))

        local step = held(KEY.fine) and 0.02 or 0.1
        if held(KEY.right) then box.w = math.min(box.w + step, 150.0) end
        if held(KEY.left) then box.w = math.max(box.w - step, 2.0) end
        if held(KEY.up) then box.l = math.min(box.l + step, 150.0) end
        if held(KEY.down) then box.l = math.max(box.l - step, 2.0) end
        if held(KEY.higher) then box.height = math.min(box.height + step, 60.0) end
        if held(KEY.lower) then box.height = math.max(box.height - step, 2.0) end
        local turn = held(KEY.fine) and 1.0 or 5.0
        if IsDisabledControlJustPressed(0, KEY.scrollUp) then box.h = (box.h + turn) % 360 end
        if IsDisabledControlJustPressed(0, KEY.scrollDown) then box.h = (box.h - turn) % 360 end
        if pressed(KEY.here) then
            local at = ground()
            box.x, box.y, box.z = at.x, at.y, at.z
        end
        if pressed(KEY.cancel) then break end
        if pressed(KEY.next) then ok = true break end
    end
    lib.hideTextUI()
    return ok
end

-- a camera straight above, the corners are picked under the crosshair; returns the corners and the height
local SPEEDS = { 0.5, 1.5, 4.0, 10.0, 25.0 }
local CAM = { forward = 32, back = 33, left = 34, right = 35, slower = 44, faster = 38, turnLeft = 20, turnRight = 26, slow = 36, straight = 22, add = 24, remove = 25 }

local function fromAbove(others, skip, floor, height)
    local me = GetEntityCoords(cache.ped)
    local pos = vec3(me.x, me.y, floor + 25.0)
    local heading = GetEntityHeading(cache.ped)
    local level = 2
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    aboveCam = cam
    pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
    SetCamCoord(cam, pos.x, pos.y, pos.z)
    SetCamRot(cam, -90.0, 0.0, heading, 2)
    SetCamFov(cam, 60.0)
    RenderScriptCams(true, true, 400, true, false)
    if GetResourceState('wais-primehud') == 'started' then exports['wais-primehud']:showHud() end
    FreezeEntityPosition(cache.ped, true)

    local poly, ok = {}, false
    local function help()
        lib.showTextUI(table.concat({
            L('zone_corners', #poly),
            L('zone_cam_keys', level, #SPEEDS),
            L('zone_turn_keys'),
            L('zone_click_keys'),
            L('zone_cam_done'),
        }, '  \n'))
    end
    local function down(key) return IsDisabledControlPressed(0, key) end
    local function hit(key) return IsDisabledControlJustPressed(0, key) end
    help()
    while busy do
        Wait(0)
        DisableAllControlActions(0)
        HideHudAndRadarThisFrame()
        local dt = GetFrameTime()
        local scale = down(KEY.fine) and 3.0 or down(CAM.slow) and 0.2 or 1.0

        if hit(CAM.faster) and level < #SPEEDS then level = level + 1 help() end
        if hit(CAM.slower) and level > 1 then level = level - 1 help() end
        if down(CAM.turnLeft) then heading = (heading + 60.0 * scale * dt) % 360 end
        if down(CAM.turnRight) then heading = (heading - 60.0 * scale * dt) % 360 end

        local h = math.rad(heading)
        local forward, right = vec3(-math.sin(h), math.cos(h), 0.0), vec3(math.cos(h), math.sin(h), 0.0)
        local move = vec3(0.0, 0.0, 0.0)
        if down(CAM.forward) then move = move + forward end
        if down(CAM.back) then move = move - forward end
        if down(CAM.left) then move = move - right end
        if down(CAM.right) then move = move + right end
        pos = pos + move * (SPEEDS[level] * scale * dt)
        if hit(KEY.scrollUp) then pos = vec3(pos.x, pos.y, math.max(pos.z - 1.0, floor + 3.0)) end
        if hit(KEY.scrollDown) then pos = vec3(pos.x, pos.y, math.min(pos.z + 1.0, floor + 120.0)) end
        local away = vec3(pos.x - me.x, pos.y - me.y, 0.0)
        if #away > 150.0 then pos = vec3(me.x, me.y, pos.z) + away / #away * 150.0 end
        if down(KEY.higher) then height = math.min(height + 2.0 * dt, 60.0) end
        if down(KEY.lower) then height = math.max(height - 2.0 * dt, 2.0) end
        SetCamCoord(cam, pos.x, pos.y, pos.z)
        SetCamRot(cam, -90.0, 0.0, heading, 2)
        SetFocusPosAndVel(pos.x, pos.y, pos.z, 0.0, 0.0, 0.0)

        local last = poly[#poly]
        if last then
            local nudge = 0.5 * (down(CAM.slow) and 0.2 or 1.0) * dt
            local shift = vec3(0.0, 0.0, 0.0)
            if down(KEY.up) then shift = shift + forward end
            if down(KEY.down) then shift = shift - forward end
            if down(KEY.left) then shift = shift - right end
            if down(KEY.right) then shift = shift + right end
            if #shift > 0.0 then
                last.x, last.y = last.x + shift.x * nudge, last.y + shift.y * nudge
            end
        end

        local cursor = { x = pos.x, y = pos.y, z = floor }
        -- a straight line from the last corner, along the camera axes
        if last and down(CAM.straight) then
            local d = vec3(cursor.x - last.x, cursor.y - last.y, 0.0)
            local f, r = d.x * forward.x + d.y * forward.y, d.x * right.x + d.y * right.y
            local along = math.abs(f) >= math.abs(r) and forward * f or right * r
            cursor.x, cursor.y = last.x + along.x, last.y + along.y
        end

        drawOthers(others, skip)
        if #poly > 0 then
            outline(poly, floor, floor + height, 61, 220, 151)
            local first = poly[1]
            DrawLine(last.x, last.y, floor, cursor.x, cursor.y, floor, 255, 255, 255, 200)
            DrawLine(cursor.x, cursor.y, floor, first.x, first.y, floor, 255, 255, 255, 90)
        end
        for _, corner in ipairs(poly) do spot(corner, 61, 220, 151) end
        if last then spot(last, 255, 184, 28) end
        DrawLine(cursor.x, cursor.y, floor, cursor.x, cursor.y, floor + height, 255, 255, 255, 200)
        DrawRect(0.5, 0.5, 0.014, 0.0025, 255, 255, 255, 220)
        DrawRect(0.5, 0.5, 0.0014, 0.025, 255, 255, 255, 220)
        local text = L('zone_high', height)
        if last then text = L('zone_edge', #(vec3(cursor.x - last.x, cursor.y - last.y, 0.0))) .. '  ·  ' .. text end
        label(vec3(cursor.x, cursor.y, floor + height), text)

        if hit(CAM.add) and #poly < Config.Places.PolyMax then
            poly[#poly + 1] = cursor
            help()
        elseif hit(CAM.remove) and #poly > 0 then
            poly[#poly] = nil
            help()
        elseif hit(KEY.cancel) then
            break
        elseif hit(KEY.next) then
            if #poly >= 3 then ok = true break end
            lib.notify({ type = 'error', description = L('zone_min') })
        end
    end
    lib.hideTextUI()
    RenderScriptCams(false, true, 400, true, false)
    if GetResourceState('wais-primehud') == 'started' then exports['wais-primehud']:hideHud() end
    pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]]
    DestroyCam(cam, false)
    aboveCam = nil
    ClearFocus()
    FreezeEntityPosition(cache.ped, false)
    if ok then return poly, height end
end

-- a single spot, picked by walking there; true when confirmed
local function stand(draw, text, colour)
    lib.showTextUI(text .. '  \n' .. L('zone_here'))
    local at
    while busy do
        Wait(0)
        draw()
        local me = ground()
        spot(me, colour[1], colour[2], colour[3])
        if pressed(KEY.cancel) then break end
        if pressed(KEY.next) then
            at = me
            at.h = GetEntityHeading(cache.ped)
            break
        end
    end
    lib.hideTextUI()
    return at
end

local function zone(box)
    return corners(box), box.z - 0.5, box.z + box.height
end


local SHAPES = {
    { value = 'above', label = L('zone_above') },
    { value = 'box', label = L('zone_box') },
}

-- draws a new place, or the shape of `place` again; the admin window hands `fields` in already filled
local function drawTool(place, fields)
    if busy then return end
    local input, method
    if place and fields and fields.method then
        method = fields.method == 'box' and 'box' or 'above'
    elseif place then
        local pick = lib.inputDialog(L('zone_again', place.label), {
            { type = 'select', label = L('zone_how'), default = 'above', required = true, options = SHAPES },
        })
        if not pick then return end
        method = pick[1]
    elseif fields then
        method = fields.method == 'box' and 'box' or 'above'
    else
        input = lib.inputDialog(L('zone_new'), {
            { type = 'input', label = L('zone_name'), required = true, max = 40 },
            { type = 'number', label = L('zone_buy'), default = 0, min = 0 },
            { type = 'number', label = L('zone_week'), default = 0, min = 0 },
            { type = 'select', label = L('zone_interior'), default = 'mlo', required = true, options = {
                { value = 'mlo', label = L('zone_mlo') },
                { value = 'shell', label = L('zone_shell') },
            } },
            { type = 'select', label = L('zone_kind'), default = 'above', required = true, options = SHAPES },
        })
        if not input then return end
        method = input[5]
        if (input[2] or 0) == 0 and (input[3] or 0) == 0 then
            return lib.notify({ type = 'error', description = L('zone_no_price') })
        end
        fields = { label = input[1], kind = input[4], buyPrice = input[2] or 0, rentWeek = input[3] or 0, deposit = input[3] or 0 }
    end
    local kind = place and place.kind or (fields.kind == 'shell' and 'shell' or 'mlo')

    busy = true
    local others = fetch() or {}
    local start = ground()
    start.h = GetEntityHeading(cache.ped)
    local poly, minZ, maxZ
    if method == 'above' then
        local corners, height = fromAbove(others, place and place.id, start.z, Config.Places.Height)
        if corners then poly, minZ, maxZ = corners, start.z - 1.0, start.z + height end
    else
        local box = fromInterior()
        local fitted = box ~= nil
        box = box or aroundMe()
        if shape(box, others, place and place.id, fitted) then poly, minZ, maxZ = zone(box) end
    end

    local entry, interior
    if poly then
        entry = stand(function() outline(poly, minZ, maxZ, 61, 220, 151) end, L('zone_door'), { 46, 196, 255 })
        if entry and kind == 'shell' then interior = start end
    end
    busy = false
    if not entry then return lib.notify({ type = 'inform', description = L('zone_cancel') }) end
    entry.h = nil
    local body = { poly = poly, minZ = minZ, maxZ = maxZ, entry = entry, delivery = entry, interior = interior }
    if place then
        body.id = place.id
    else
        body.label, body.kind, body.buyPrice, body.rentWeek, body.rentMonth, body.deposit = fields.label, kind, fields.buyPrice or 0, fields.rentWeek or 0, fields.rentMonth or 0, fields.deposit or 0
        body.propLimit, body.template, body.pack = fields.propLimit, fields.template, fields.pack
    end
    save(body)
end

local function setDelivery(place)
    busy = true
    lib.showTextUI(L('zone_delivery_walk') .. '  \n' .. L('zone_here'))
    local at
    while busy do
        Wait(0)
        outline(place.poly, place.minZ, place.maxZ, 61, 220, 151)
        local me = ground()
        spot(me, 255, 184, 28)
        if pressed(KEY.cancel) then break end
        if pressed(KEY.next) then at = me break end
    end
    lib.hideTextUI()
    busy = false
    if at then save({ id = place.id, delivery = at }) end
end

-- the Zones button of the admin window shows every zone close to you, with its name
local function toggleZones()
    if overview then overview = false return end
    local places = fetch()
    if not places then return lib.notify({ type = 'error', description = L('not_allowed') }) end
    if #places == 0 then return lib.notify({ type = 'inform', description = L('zone_none') }) end
    overview = true
    lib.notify({ type = 'inform', description = L('zone_showing') })
    CreateThread(function()
        while overview do
            Wait(0)
            local at = GetEntityCoords(cache.ped)
            for _, place in ipairs(places) do
                local entry = place.entry
                if entry and #(at - vec3(entry.x, entry.y, entry.z)) < Config.Places.Draw then
                    outline(place.poly, place.minZ, place.maxZ, 61, 220, 151)
                    spot(entry, 46, 196, 255)
                    label(vec3(entry.x, entry.y, entry.z + 1.2), ('#%d %s'):format(place.id, place.label))
                    if place.delivery then spot(place.delivery, 255, 184, 28) end
                end
            end
        end
    end)
end

-- DaddyRP: map work the admin window asks for; the window has closed and opens again on the same place after
AddEventHandler('daddy_venue:adminMap', function(body)
    if type(body) ~= 'table' or body.tool == 'prop' then return end
    CreateThread(function()
        if body.tool == 'zones' then return toggleZones() end
        if body.tool == 'draw' then
            if type(body.fields) == 'table' then drawTool(nil, body.fields) end
            return TriggerEvent('daddy_venue:adminBack', 'adminPlaces')
        end
        local place
        for _, entry in ipairs(fetch() or {}) do
            if entry.id == body.id then place = entry break end
        end
        if not place then return end
        if body.tool == 'teleport' then
            DoScreenFadeOut(250)
            Wait(300)
            pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
            SetEntityCoords(cache.ped, place.entry.x, place.entry.y, place.entry.z + 1.0, false, false, false, false)
            Wait(300)
            DoScreenFadeIn(250)
            return
        end
        -- no teleport: inside the place the build menu opens right away, outside it opens once the admin walks in
        if body.tool == 'build' then
            local at = GetEntityCoords(cache.ped)
            if not Venue.inPlace(place, at.x, at.y, at.z) then
                lib.showTextUI(L('zone_walk_in') .. '  \n' .. L('zone_cancel_key'))
                while not Venue.inPlace(place, at.x, at.y, at.z) and not pressed(KEY.cancel) do
                    Wait(0)
                    outline(place.poly, place.minZ, place.maxZ, 61, 220, 151)
                    at = GetEntityCoords(cache.ped)
                end
                lib.hideTextUI()
            end
            if Venue.inPlace(place, at.x, at.y, at.z) then Venue.Local.build() end
            return
        end
        if body.tool == 'redraw' then drawTool(place, { method = body.method })
        elseif body.tool == 'delivery' then setDelivery(place) end
        TriggerEvent('daddy_venue:adminBack', 'adminPlaces', place.id)
    end)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    busy, overview = false, false
    lib.hideTextUI()
    -- stopped in the middle of the camera tool: the player gets the normal camera and can move again
    if aboveCam then
        RenderScriptCams(false, false, 0, true, false)
        if DoesCamExist(aboveCam) then DestroyCam(aboveCam, false) end
        aboveCam = nil
        ClearFocus()
        FreezeEntityPosition(cache.ped, false)
        if GetResourceState('wais-primehud') == 'started' then pcall(function() exports['wais-primehud']:hideHud() end) end
    end
end)
