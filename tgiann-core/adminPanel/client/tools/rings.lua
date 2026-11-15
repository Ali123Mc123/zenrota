-- tgiann-core admin lib: distances around a point as coloured rings on the ground, seen from above.
local Tools = AdminPanel.Tools

local LEFT, RIGHT, UP, DOWN = 174, 175, 172, 173
local FAST, SLOW = 21, 36
local CONFIRM, CANCEL = 191, 194

---@class AdminToolRing
---@field key string value name
---@field label string text shown in the key help (already translated)
---@field min number
---@field max number
---@field color integer[] r, g, b

---@param rings AdminToolRing[]
---@param values table<string, number>
---@param selected integer
---@return table[]
local function rows(rings, values, selected)
    local lang = Tools.Lang()
    local out = {}
    -- one ring: nothing to pick, only its size
    if #rings > 1 then out[1] = { icon = { "arrowLeftKey", "arrowRightKey" }, label = ("%s: %s"):format(lang.ADMIN_TOOL_RING_PICK, rings[selected].label) } end
    for i, ring in ipairs(rings) do
        out[#out + 1] = { label = ("%s%s: %.1f m"):format(#rings > 1 and i == selected and "> " or "", ring.label, values[ring.key]), style = i == selected and "title" or "hint" }
    end
    out[#out + 1] = { icon = { "arrowUpKey", "arrowDownKey" }, label = lang.ADMIN_TOOL_RING_RESIZE }
    out[#out + 1] = { icon = { "shiftKey", "ctrlKey" }, label = lang.ADMIN_TOOL_SPEED }
    out[#out + 1] = { icon = "enterKey", label = lang.ADMIN_TOOL_SAVE }
    out[#out + 1] = { icon = "backspaceKey", label = lang.ADMIN_TOOL_CANCEL }
    return out
end

---Left / right picks a ring, up / down resizes it (faster for big rings, shift / ctrl faster / slower); the camera
---rises with the picked ring. onChange may correct the values after each change (one ring inside another).
---Returns the values, nil when cancelled.
---@param origin vector3
---@param heading number the camera looks from behind this heading
---@param rings AdminToolRing[]
---@param values table<string, number>
---@param opts? { selected?: integer, onChange?: fun(values: table<string, number>, key: string) }
---@return table<string, number>|nil
function Tools.EditRings(origin, heading, rings, values, opts)
    opts = opts or {}
    local v, raw = {}, {}
    for k, n in pairs(values) do
        v[k] = n + 0.0
        raw[k] = n + 0.0
    end
    local selected = opts.selected or 1
    -- the rings stand on the ground under the origin (an origin is often a ped position, 1 m above it)
    local found, groundZ = GetGroundZFor_3dCoord(origin.x, origin.y, origin.z + 1.0, false)
    local floor = found and math.abs(groundZ - origin.z) < 3.0 and groundZ or origin.z - 1.0
    local h = math.rad(heading)
    local back = vector3(math.sin(h), -math.cos(h), 0.0)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
    pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
    local camHeight = 6.0
    local function aim()
        local want = math.max(4.0, v[rings[selected].key] * 2.2)
        camHeight = camHeight + (want - camHeight) * math.min(1.0, GetFrameTime() * 6.0)
        local pos = origin + back * (camHeight * 0.45) + vector3(0.0, 0.0, camHeight)
        SetCamCoord(cam, pos.x, pos.y, pos.z)
        PointCamAtCoord(cam, origin.x, origin.y, origin.z)
    end
    aim()
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 400, true, true)
    tgiCoreExports:OpenKeyHelpMenu(rows(rings, v, selected))

    local result, lastHelp = nil, 0
    while true do
        DisableAllControlActions(0)
        HideHudAndRadarThisFrame()
        if IsDisabledControlJustPressed(0, CONFIRM) then
            result = v
            break
        end
        if IsDisabledControlJustPressed(0, CANCEL) then break end
        local changed = false
        if #rings > 1 and IsDisabledControlJustPressed(0, LEFT) then
            selected = selected == 1 and #rings or selected - 1
            changed = true
        elseif #rings > 1 and IsDisabledControlJustPressed(0, RIGHT) then
            selected = selected == #rings and 1 or selected + 1
            changed = true
        end
        local mult = IsDisabledControlPressed(0, FAST) and 4.0 or IsDisabledControlPressed(0, SLOW) and 0.2 or 1.0
        local dir = (IsDisabledControlPressed(0, UP) and 1 or 0) - (IsDisabledControlPressed(0, DOWN) and 1 or 0)
        if dir ~= 0 then
            local ring = rings[selected]
            -- speed follows the ring size: a big ring moves in meters, a small one in centimetres
            local speed = math.max(0.5, raw[ring.key] * 0.6)
            -- the unrounded size keeps the small per frame steps, the shown value is rounded
            raw[ring.key] = math.max(ring.min, math.min(ring.max, raw[ring.key] + dir * speed * GetFrameTime() * mult))
            v[ring.key] = Tools.Round(raw[ring.key], 1)
            if opts.onChange then
                opts.onChange(v, ring.key)
                for k, n in pairs(v) do
                    if Tools.Round(raw[k], 1) ~= n then raw[k] = n end
                end
            end
            changed = true
        end
        aim()
        for i, ring in ipairs(rings) do
            local r = v[ring.key]
            local c = ring.color
            local picked = i == selected
            -- a wall tall enough to read from the camera above, and a bright line on the ground at the edge
            DrawMarker(1, origin.x, origin.y, floor - 0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, r * 2.0, r * 2.0, picked and 2.5 or 1.2, c[1], c[2], c[3], picked and 90 or 35, false, false, 2, false, nil, nil, false)
            DrawMarker(25, origin.x, origin.y, floor + 0.03, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, r * 2.0, r * 2.0, 1.0, c[1], c[2], c[3], picked and 230 or 90, false, false, 2, false, nil, nil, false)
        end
        if changed then
            local now = GetGameTimer()
            if now - lastHelp > 120 then
                lastHelp = now
                tgiCoreExports:OpenKeyHelpMenu(rows(rings, v, selected))
            end
        end
        Wait(0)
    end

    tgiCoreExports:CloseKeyHelpMenu()
    RenderScriptCams(false, true, 400, true, true)
    pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]]
    DestroyCam(cam, false)
    return result
end
