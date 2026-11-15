-- Closed campus on the client: the warning, being put outside the main gate, and the pass option for staff.
-- The server decides who is let in and when someone is moved.
local cfg = Config.ClosedCampus
if not cfg or not cfg.Enabled or #(cfg.Points or {}) < 3 then return end

local t = DL.locale.t

RegisterNetEvent('daddy_college:closed:warn', function(data)
    if not data then return Core.Nui.Send('outOfBounds:hide', {}) end
    data.tag, data.banner, data.action = t('closed.tag'), t('closed.banner'), t('closed.action')
    Core.Nui.Send('outOfBounds:tick', data)
    Core.NotifyL('closed.warn', 'error', data.remaining)
    PlaySoundFrontend(-1, 'CHECKPOINT_MISSED', 'HUD_MINI_GAME_SOUNDSET', true)
end)

-- Holds the entity still until the ground under the drop point is there, then sets it on that ground.
local function land(entity, c)
    FreezeEntityPosition(entity, true)
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoordsNoOffset(entity, c.x, c.y, c.z + 1.0, false, false, false)
    SetEntityHeading(entity, c.w or 0.0)
    SetEntityVelocity(entity, 0.0, 0.0, 0.0)
    local stop = GetGameTimer() + 5000
    repeat
        RequestCollisionAtCoord(c.x, c.y, c.z)
        Wait(0)
    until HasCollisionLoadedAroundEntity(entity) or GetGameTimer() > stop
    local found, z = GetGroundZFor_3dCoord(c.x, c.y, c.z + 30.0, false)
    if found then SetEntityCoordsNoOffset(entity, c.x, c.y, z + 0.05, false, false, false) end
    FreezeEntityPosition(entity, false)
end

local function moveOut(data)
    local ped = PlayerPedId()
    Core.Nui.Send('outOfBounds:hide', {})
    DoScreenFadeOut(data.fadeMs)
    local stop = GetGameTimer() + 3000
    while not IsScreenFadedOut() and GetGameTimer() < stop do Wait(0) end
    local veh = GetVehiclePedIsIn(ped, false)
    local own = data.vehicle and veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped
    if own and not NetworkHasControlOfEntity(veh) then
        NetworkRequestControlOfEntity(veh)
        local until_ = GetGameTimer() + 1000
        while not NetworkHasControlOfEntity(veh) and GetGameTimer() < until_ do Wait(0) end
        own = NetworkHasControlOfEntity(veh)
    end
    if own then
        SetVehicleEngineOn(veh, false, true, false)
        SetVehicleForwardSpeed(veh, 0.0)
        land(veh, data.coords)
        SetVehicleOnGroundProperly(veh)
    else
        ClearPedTasksImmediately(ped)
        land(ped, data.coords)
    end
end

-- An error mid-move must not leave the screen black or the player frozen.
RegisterNetEvent('daddy_college:closed:out', function(data)
    CreateThread(function()
        local ok, err = pcall(moveOut, data)
        if not ok then
            print(('^1[daddy_college] closed campus move failed: %s^7'):format(err))
            FreezeEntityPosition(PlayerPedId(), false)
        end
        DoScreenFadeIn(data.fadeMs)
        if ok then Core.NotifyL('closed.moved', 'warning') end
    end)
end)

-- Teachers and security hand a visitor a pass with the visitorpass command (server/security/closed.lua).
