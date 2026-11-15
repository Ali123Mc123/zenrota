-- CCTV from the tablet: watch saved cameras, or fly a new one into place.
if not Core.ModuleEnabled('tablet') then return end

local cctv = Config.Tablet.Cctv
local CONTROLS = { exit = 177, save = 18, previous = 174, following = 175, zoomIn = 241, zoomOut = 242 }
local active, cameras, index = false, {}, 1

local function fovOf(value)
    return tonumber(('%.1f'):format(math.max(cctv.MinFov, math.min(cctv.MaxFov, tonumber(value) or 50.0)))) + 0.0
end

local function vec(x, y, z) return vector3(tonumber(x) or 0.0, tonumber(y) or 0.0, tonumber(z) or 0.0) end

local function begin(coords, rotation, fov)
    if active then return false end
    active = true
    Core.Nui.Suspend()
    if not DL.freecam.start({ coords = coords, rotation = rotation, fov = fov, minFov = cctv.MinFov, maxFov = cctv.MaxFov }) then
        active = false
        Core.Nui.Resume()
        return false
    end
    return true
end

local function finish()
    DL.freecam.stop()
    active, cameras, index = false, {}, 1
    Core.Nui.Send('cctv:hide', {})
    Core.Nui.Resume()
end

local function viewerState(action)
    local camera = cameras[index]
    Core.Nui.Send(action, { id = camera.id, name = camera.name, index = index, total = #cameras, fov = ('%.1f'):format(DL.freecam.pose().fov) })
end

local function show(i)
    local camera = cameras[i]
    if not camera then return end
    index = i
    DL.freecam.place(vec(camera.pos_x, camera.pos_y, camera.pos_z), vec(camera.rot_x, camera.rot_y, camera.rot_z), fovOf(camera.fov), cctv)
    viewerState('cctv:update')
end

-- Viewer: arrows step through the cameras, the wheel zooms, Backspace leaves.
Core.Nui.SafeCallback('tablet:cctvView', function(input)
    local id = input.camera and tonumber(input.camera.id)
    if not id then return { ok = false, error = 'validation' } end
    local response = lib.callback.await('daddy_college:tablet:getCameraView', false, { id = id })
    if not response or not response.ok then return response or { ok = false, error = 'db_unavailable' } end
    local first = response.data.camera
    if not begin(vec(first.pos_x, first.pos_y, first.pos_z), vec(first.rot_x, first.rot_y, first.rot_z), fovOf(first.fov)) then return { ok = false, error = 'conflict' } end
    cameras = response.data.cameras
    index = response.data.index
    viewerState('cctv:show')

    CreateThread(function()
        while active do
            Wait(0)
            if IsEntityDead(cache.ped) then break end
            DisableAllControlActions(0)
            HideHudAndRadarThisFrame()
            if IsDisabledControlJustPressed(0, CONTROLS.exit) then break end
            if #cameras > 1 and IsDisabledControlJustPressed(0, CONTROLS.previous) then show((index - 2) % #cameras + 1) end
            if #cameras > 1 and IsDisabledControlJustPressed(0, CONTROLS.following) then show(index % #cameras + 1) end
            local step = (IsDisabledControlJustPressed(0, CONTROLS.zoomIn) and -cctv.FovStep) or (IsDisabledControlJustPressed(0, CONTROLS.zoomOut) and cctv.FovStep) or 0
            if step ~= 0 then
                DL.freecam.zoom(step, cctv)
                viewerState('cctv:update')
            end
        end
        finish()
    end)
    return { ok = true, data = {} }
end)

-- Editor: fly with WASD/QE and the mouse, the wheel zooms, Enter saves, Backspace cancels.
Core.Nui.SafeCallback('tablet:cctvCapture', function(input)
    local allowed = lib.callback.await('daddy_college:tablet:authorizeCameraEdit', false, {})
    if not allowed or not allowed.ok then return allowed or { ok = false, error = 'db_unavailable' } end
    local camera, here, look = input.camera or {}, GetGameplayCamCoord(), GetGameplayCamRot(2)
    local coords = vector3(tonumber(camera.pos_x) or here.x, tonumber(camera.pos_y) or here.y, tonumber(camera.pos_z) or here.z)
    local rotation = vector3(tonumber(camera.rot_x) or look.x, tonumber(camera.rot_y) or look.y, tonumber(camera.rot_z) or look.z)
    if not begin(coords, rotation, fovOf(camera.fov or GetGameplayCamFov())) then return { ok = false, error = 'conflict' } end
    Core.Nui.Send('cctv:show', { edit = true, name = camera.name or '', fov = ('%.1f'):format(DL.freecam.pose().fov) })

    local saved = false
    while active do
        Wait(0)
        if IsEntityDead(cache.ped) then break end
        DisableAllControlActions(0)
        DL.freecam.step(cctv)
        local step = (IsDisabledControlJustPressed(0, CONTROLS.zoomIn) and -cctv.FovStep) or (IsDisabledControlJustPressed(0, CONTROLS.zoomOut) and cctv.FovStep) or 0
        if step ~= 0 then Core.Nui.Send('cctv:update', { fov = ('%.1f'):format(DL.freecam.zoom(step, cctv)) }) end
        if IsDisabledControlJustPressed(0, CONTROLS.save) then saved = true break end
        if IsDisabledControlJustPressed(0, CONTROLS.exit) then break end
    end
    local pose = DL.freecam.pose()
    finish()
    if not saved or not pose then return { ok = false, error = 'cancelled' } end
    return { ok = true, data = {
        position = { x = pose.coords.x, y = pose.coords.y, z = pose.coords.z },
        rotation = { x = pose.rotation.x, y = pose.rotation.y, z = pose.rotation.z },
        fov = ('%.1f'):format(pose.fov),
    } }
end, 600000)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource and active then DL.freecam.stop() end
end)
