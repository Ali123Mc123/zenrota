-- The stance kit panel.

local panel = { open = false, vehicle = nil, cam = nil, heading = -45.0, pitch = 6.0, want = { -45.0, 6.0 } }

local function limits()
    local s = Config.Stance
    return { height = s.Height, camber = s.Camber, track = s.Track }
end

local function spot()
    local lo, hi = GetModelDimensions(GetEntityModel(panel.vehicle))
    local d = math.max(3.4, #(hi - lo) * 0.95)
    local h, p = math.rad(panel.heading), math.rad(panel.pitch)
    local z = lo.z + (hi.z - lo.z) * 0.35
    local at = GetOffsetFromEntityInWorldCoords(panel.vehicle, math.sin(h) * math.cos(p) * d, math.cos(h) * math.cos(p) * d, z + math.sin(p) * d)
    return at, GetOffsetFromEntityInWorldCoords(panel.vehicle, 0.0, 0.0, z)
end

local close

local function camLoop()
    CreateThread(function()
        while panel.open and panel.cam do
            if not DoesEntityExist(panel.vehicle) then return close() end
            panel.heading = panel.heading + (panel.want[1] - panel.heading) * 0.15
            panel.pitch = panel.pitch + (panel.want[2] - panel.pitch) * 0.15
            local at, look = spot()
            SetCamCoord(panel.cam, at.x, at.y, at.z)
            PointCamAtCoord(panel.cam, look.x, look.y, look.z)
            DisableAllControlActions(0)
            HideHudAndRadarThisFrame()
            Wait(0)
        end
    end)
end

close = function()
    if not panel.open then return end
    panel.open = false
    UiFocus(false)
    SendNUIMessage({ action = 'mech:stance', data = false })
    if DoesEntityExist(panel.vehicle) then
        Stance.preview(panel.vehicle, nil)
        FreezeEntityPosition(panel.vehicle, false)
    end
    if panel.cam then
        RenderScriptCams(false, true, 500, true, false)
        DestroyCam(panel.cam, false)
        panel.cam = nil
    end
end

RegisterNetEvent('daddy_mechanic:stanceMenu', function()
    local vehicle = cache.vehicle
    if panel.open or not vehicle or Menu.isOpen() then return end
    if not IsThisModelACar(GetEntityModel(vehicle)) then return Bridge.notify(nil, Core.t('msg.wont_fit'), 'error') end
    panel.open, panel.vehicle = true, vehicle
    panel.heading, panel.pitch, panel.want = -45.0, 6.0, { -45.0, 6.0 }
    FreezeEntityPosition(vehicle, true)
    panel.cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamFov(panel.cam, 40.0)
    local at, look = spot()
    SetCamCoord(panel.cam, at.x, at.y, at.z)
    PointCamAtCoord(panel.cam, look.x, look.y, look.z)
    RenderScriptCams(true, true, 600, true, false)
    camLoop()
    SendNUIMessage({ action = 'mech:stance', data = {
        value = Stance.of(vehicle), limits = limits(),
        car = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))), plate = GetVehicleNumberPlateText(vehicle),
    } })
    UiFocus(true)
end)

RegisterNUICallback('stancePreview', function(data, cb)
    cb({})
    if panel.open then Stance.preview(panel.vehicle, data.value ~= false and Catalog.stanceOf(data.value) or false) end
end)

RegisterNUICallback('stanceSave', function(data, cb)
    if not panel.open then return cb({ ok = false }) end
    local ok, why = lib.callback.await('daddy_mechanic:setStance', false, data.value)
    cb({ ok = ok == true, error = not ok and (why or Core.t('msg.failed')) or nil })
    if ok then
        Bridge.notify(nil, Core.t('msg.stance_saved'), 'success')
        close()
    end
end)

RegisterNUICallback('stanceClose', function(_, cb)
    cb({})
    close()
end)

RegisterNUICallback('stanceOrbit', function(data, cb)
    cb({})
    panel.want[1] = panel.want[1] + (tonumber(data.dx) or 0) * 0.35
    panel.want[2] = math.max(-4.0, math.min(40.0, panel.want[2] + (tonumber(data.dy) or 0) * 0.2))
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() or not panel.open then return end
    UiFocus(false)
    if DoesEntityExist(panel.vehicle) then FreezeEntityPosition(panel.vehicle, false) end
    if panel.cam then
        RenderScriptCams(false, false, 0, true, false)
        DestroyCam(panel.cam, false)
    end
end)
