-- A free camera for placing things: WASD moves, mouse looks, Shift fast, Ctrl slow, E/Q up and down.
local freecam = {}
local camera, frozenPed, wasFrozen
local fov = 50.0

local SETTINGS = { moveSpeed = 0.35, fast = 3.0, slow = 0.25, lookSpeed = 3.0, minFov = 20.0, maxFov = 90.0 }

local function setting(opts, key)
    return opts and tonumber(opts[key]) or SETTINGS[key]
end

function freecam.direction(rotation)
    local z, x = math.rad(rotation.z), math.rad(rotation.x)
    local c = math.abs(math.cos(x))
    return vector3(-math.sin(z) * c, math.cos(z) * c, math.sin(x))
end

function freecam.active()
    return camera ~= nil and DoesCamExist(camera)
end

function freecam.start(opts)
    if freecam.active() then return false end
    opts = opts or {}
    local coords, rotation = opts.coords or GetGameplayCamCoord(), opts.rotation or GetGameplayCamRot(2)
    camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    pcall(function() exports['FeloxAC']:createCam(camera) end) --[[FeloxAC:auto]]
    if opts.freezePed ~= false then
        frozenPed = PlayerPedId()
        wasFrozen = IsEntityPositionFrozen(frozenPed)
        FreezeEntityPosition(frozenPed, true)
    end
    fov = math.max(setting(opts, 'minFov'), math.min(setting(opts, 'maxFov'), opts.fov or GetGameplayCamFov()))
    SetCamCoord(camera, coords.x, coords.y, coords.z)
    SetCamRot(camera, rotation.x, rotation.y, rotation.z, 2)
    SetCamFov(camera, fov + 0.0)
    SetCamActive(camera, true)
    RenderScriptCams(true, false, 0, true, true)
    return true
end

-- Call every frame with the controls disabled; returns the new coords and rotation.
function freecam.step(opts)
    if not freecam.active() then return nil end
    local coords, rotation = GetCamCoord(camera), GetCamRot(camera, 2)
    local forward = freecam.direction(rotation)
    local right = vector3(forward.y, -forward.x, 0.0)
    local speed = setting(opts, 'moveSpeed')
    if IsDisabledControlPressed(0, 21) then speed = speed * setting(opts, 'fast')
    elseif IsDisabledControlPressed(0, 36) then speed = speed * setting(opts, 'slow') end
    if IsDisabledControlPressed(0, 32) then coords = coords + forward * speed end
    if IsDisabledControlPressed(0, 33) then coords = coords - forward * speed end
    if IsDisabledControlPressed(0, 34) then coords = coords - right * speed end
    if IsDisabledControlPressed(0, 35) then coords = coords + right * speed end
    if IsDisabledControlPressed(0, opts and opts.upControl or 38) then coords = coords + vector3(0.0, 0.0, speed) end
    if IsDisabledControlPressed(0, opts and opts.downControl or 44) then coords = coords - vector3(0.0, 0.0, speed) end
    local look = setting(opts, 'lookSpeed')
    rotation = vector3(math.max(-89.0, math.min(89.0, rotation.x - GetDisabledControlNormal(0, 2) * look)), 0.0, rotation.z - GetDisabledControlNormal(0, 1) * look)
    SetCamCoord(camera, coords.x, coords.y, coords.z)
    SetCamRot(camera, rotation.x, rotation.y, rotation.z, 2)
    SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    return coords, rotation
end

function freecam.zoom(delta, opts)
    fov = math.max(setting(opts, 'minFov'), math.min(setting(opts, 'maxFov'), fov + delta))
    if freecam.active() then SetCamFov(camera, fov + 0.0) end
    return fov
end

-- Moves the running camera to a fixed pose, as a CCTV viewer does.
function freecam.place(coords, rotation, newFov, opts)
    if not freecam.active() then return false end
    if newFov then fov = math.max(setting(opts, 'minFov'), math.min(setting(opts, 'maxFov'), newFov)) end
    SetCamCoord(camera, coords.x, coords.y, coords.z)
    SetCamRot(camera, rotation.x, rotation.y, rotation.z, 2)
    SetCamFov(camera, fov + 0.0)
    SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    return true
end

function freecam.pose()
    if not freecam.active() then return nil end
    return { coords = GetCamCoord(camera), rotation = GetCamRot(camera, 2), fov = fov }
end

function freecam.stop()
    if not camera then return end
    RenderScriptCams(false, false, 0, true, true)
    if DoesCamExist(camera) then pcall(function() exports['FeloxAC']:destroyCam(camera) end) --[[FeloxAC:auto]] DestroyCam(camera, false) end
    camera = nil
    ClearFocus()
    if frozenPed and DoesEntityExist(frozenPed) and not wasFrozen then FreezeEntityPosition(frozenPed, false) end
    frozenPed = nil
end

AddEventHandler('onResourceStop', function(resource)
    if resource == DL.resource then freecam.stop() end
end)

return freecam
