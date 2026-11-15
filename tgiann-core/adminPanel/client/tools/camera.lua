-- tgiann-core admin lib: a fixed camera set by flying a free camera to the view and saving what is on screen.
local Tools = AdminPanel.Tools

---@class AdminToolCameraKey
---@field control integer
---@field onPress fun()

---@class AdminToolCameraOptions
---@field origin? vector3 the camera stays within maxDistance of it
---@field maxDistance? number
---@field rows? fun(): table[] extra key help rows (asked again after a key press, so they can show a state)
---@field keys? AdminToolCameraKey[] extra keys
---@field onFrame? fun(camCoords: vector3) every frame (draw lights, markers)
---@field hidePlayer? boolean the admin's character is not drawn

---@param opts AdminToolCameraOptions
---@return table[]
local function rows(opts)
    local lang = Tools.Lang()
    local out = {
        { icon = { "wKey", "aKey", "sKey", "dKey" }, label = lang.ADMIN_TOOL_CAMERA_MOVE },
        { icon = { "shiftKey", "ctrlKey" }, label = lang.ADMIN_TOOL_SPEED },
        { icon = "mouseRightClick", label = lang.ADMIN_TOOL_CAMERA_LOOK },
        { icon = "mouseScroll", label = lang.ADMIN_TOOL_CAMERA_ZOOM },
    }
    for _, row in ipairs(opts.rows and opts.rows() or {}) do out[#out + 1] = row end
    out[#out + 1] = { icon = "enterKey", label = lang.ADMIN_TOOL_SAVE }
    out[#out + 1] = { icon = { "escKey", "backspaceKey" }, label = lang.ADMIN_TOOL_CANCEL }
    return out
end

---Starts at coords / rotation / fov; the admin flies (slowly), looks with the right mouse button, zooms with the
---wheel. Enter returns the rendered view, nil when cancelled.
---@param coords vector3
---@param rotation vector3 pitch, roll, heading
---@param fov number
---@param opts? AdminToolCameraOptions
---@return { coords: vector3, rotation: vector3, fov: number }|nil
function Tools.EditCamera(coords, rotation, fov, opts)
    opts = opts or {}
    tgiCoreExports:CreateFreeCam({
        coords = coords,
        pitch = rotation.x + 0.0,
        heading = rotation.z + 0.0,
        fov = fov + 0.0,
        maxFov = 120.0,
        speed = Tools.FREECAM_FINE.speed,
        shiftMultiplier = Tools.FREECAM_FINE.shiftMultiplier,
        slowMultiplier = Tools.FREECAM_FINE.slowMultiplier,
        scroll = "zoom",
        lookButton = "right",
        freezePlayer = true,
        transitionTime = 500,
        origin = opts.origin or coords,
        maxDistance = opts.maxDistance or 8.0,
    })
    tgiCoreExports:OpenKeyHelpMenu(rows(opts))

    local result = nil
    while true do
        -- Esc must not open the pause menu, it cancels the tool
        DisableControlAction(0, 200, true)
        DisableControlAction(0, 322, true)
        if opts.hidePlayer then SetEntityLocallyInvisible(cache.ped) end
        for _, key in ipairs(opts.keys or {}) do
            DisableControlAction(0, key.control, true)
            if IsDisabledControlJustPressed(0, key.control) then
                key.onPress()
                tgiCoreExports:OpenKeyHelpMenu(rows(opts))
            end
        end
        if opts.onFrame then opts.onFrame(GetFinalRenderedCamCoord()) end
        if Tools.JustPressed(Tools.CONFIRM_KEYS) then
            result = { coords = GetFinalRenderedCamCoord(), rotation = GetFinalRenderedCamRot(2), fov = GetFinalRenderedCamFov() }
            break
        end
        if Tools.JustPressed(Tools.CANCEL_KEYS) then break end
        Wait(0)
    end

    tgiCoreExports:CloseKeyHelpMenu()
    tgiCoreExports:DestroyFreeCam(0)
    return result
end
