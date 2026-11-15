-- Campus shots behind the forms: each glides from `from` to `to` while looking at `look`, then cuts to the next one.
Camera = {}

local active = false
local cams = {}

local function make(pos, look, fov)
    local cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, fov, false, 2)
    pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
    PointCamAtCoord(cam, look.x, look.y, look.z)
    cams[#cams + 1] = cam
    return cam
end

-- Drops every cam except the ones still in use.
local function sweep(keep)
    local left = {}
    for _, cam in ipairs(cams) do
        if keep[cam] then left[#left + 1] = cam elseif DoesCamExist(cam) then pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]] DestroyCam(cam, false) end
    end
    cams = left
end

function Camera.available() return #Config.Cameras > 0 end

-- Starts the loop; true once the first shot is on screen.
function Camera.start()
    if active or #Config.Cameras == 0 then return false end
    active = true
    local shown = promise.new()
    CreateThread(function()
        local index, first = 1, true
        while active do
            local shot = Config.Cameras[index]
            local fov = shot.fov or 50.0
            SetFocusPosAndVel(shot.from.x, shot.from.y, shot.from.z, 0.0, 0.0, 0.0)
            if first then Wait(1500) end -- let the area stream in behind the fade
            local from = make(shot.from, shot.look, fov)
            local to = make(shot.to or shot.from, shot.look, fov)
            SetCamActive(from, true)
            if first then
                RenderScriptCams(true, false, 0, true, true)
                shown:resolve(true)
                first = false
            end
            SetCamActiveWithInterp(to, from, math.floor((shot.seconds or 12) * 1000), 1, 1)
            sweep({ [from] = true, [to] = true })
            local stop = GetGameTimer() + math.floor((shot.seconds or 12) * 1000)
            while active and GetGameTimer() < stop do Wait(100) end
            index = index % #Config.Cameras + 1
        end
    end)
    return Citizen.Await(shown)
end

function Camera.stop()
    if not active then return end
    active = false
    RenderScriptCams(false, true, 800, true, true)
    sweep({})
    ClearFocus()
end
