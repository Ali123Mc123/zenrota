------------------------------------------------------------------------
-- NoClip for EAdmin (Unified)
-- Freecam camera engine + OneSync entity sync + safe exit
--
-- Camera:    freecam module (matrix-based, frame-time compensated, gamepad, instructional buttons)
-- Scope:     entity follows camera position for OneSync entity streaming
-- Exit:      streamed ground snap + landing protection (5s timeout)
--
-- Security:  command-only entry -> lib.callback.await (server RBAC)
--            TTL cache + server-push revocation. No RegisterNetEvent toggle.
------------------------------------------------------------------------

local RESOURCE_NAME <const> = GetCurrentResourceName()
local EVENT_PREFIX <const> = RESOURCE_NAME .. ':'

------------------------------------------------------------------------
-- Permission cache
------------------------------------------------------------------------

local noClipAllowed = false
local permExpiry = 0
local PERM_TTL <const> = 5 * 60 * 1000  -- 5 minutes

---@return boolean
local function checkNoClipPermission()
    local now = GetGameTimer()
    if noClipAllowed and now < permExpiry then
        return true
    end
    local allowed = lib.callback.await(EVENT_PREFIX .. 'canNoClip', false)
    noClipAllowed = allowed or false
    permExpiry = allowed and (now + PERM_TTL) or 0
    return noClipAllowed
end

local function clearNoClipPermission()
    noClipAllowed = false
    permExpiry = 0
end

------------------------------------------------------------------------
-- Forward declarations
------------------------------------------------------------------------

local toggleNoClip
local forceDisableNoClip

------------------------------------------------------------------------
-- Server-push permission revocation
------------------------------------------------------------------------

RegisterNetEvent(EVENT_PREFIX .. 'noClipRevoked', function()
    clearNoClipPermission()
    if forceDisableNoClip then forceDisableNoClip() end
end)

------------------------------------------------------------------------
-- State
------------------------------------------------------------------------

local noClipEnabled = false
local freecamVeh = 0

local MIN_LANDING_TIMEOUT <const> = 5000
local ENTITY_SYNC_INTERVAL <const> = 100 -- ms, sufficient for OneSync streaming scope

------------------------------------------------------------------------
-- Ground detection
------------------------------------------------------------------------

local GROUND_PROBE_MAX_STEP <const> = 500.0
local GROUND_SETTLE_TIMEOUT <const> = 2000
local LANDING_CLEARANCE <const> = 1.0
local GROUND_PROBE_WAIT <const> = 50
local GROUND_RAYCAST_FLAGS <const> = 17 -- world + objects
local GROUND_FINE_STEP <const> = 25.0
local GROUND_FINE_CEILING <const> = 250.0

local function requestGroundCollision(x, y, z)
    RequestCollisionAtCoord(x, y, z)
    RequestAdditionalCollisionAtCoord(x, y, z)
    SetFocusPosAndVel(x, y, z, 0.0, 0.0, 0.0)
end

local function raycastGround(entity, x, y, startZ, endZ)
    local handle = StartShapeTestLosProbe(x, y, startZ, x, y, endZ, GROUND_RAYCAST_FLAGS, entity, 0)

    while true do
        local status, hit, endCoords = GetShapeTestResult(handle)
        if status == 1 then
            Wait(0)
        else
            local didHit = hit == 1 or hit == true
            if status == 2 and didHit then
                return vector3(endCoords.x, endCoords.y, endCoords.z)
            end
            return nil
        end
    end
end

local function probeGroundAtZ(entity, x, y, z)
    SetEntityCoordsNoOffset(entity, x, y, z, false, false, false)
    requestGroundCollision(x, y, z)
    Wait(GROUND_PROBE_WAIT)

    return GetGroundZFor_3dCoord(x, y, z, false)
end

local function scanGroundBand(entity, x, y, upperZ, lowerZ)
    local scanZ = upperZ - GROUND_FINE_STEP

    while scanZ > lowerZ do
        local found, groundZ = probeGroundAtZ(entity, x, y, scanZ)
        if found then
            return true, groundZ
        end

        scanZ = scanZ - GROUND_FINE_STEP
    end

    return false, nil
end

local function waitForCollision(entity, x, y, z, timeout)
    SetEntityLoadCollisionFlag(entity, true)

    local deadline = GetGameTimer() + timeout
    while GetGameTimer() < deadline do
        requestGroundCollision(x, y, z)
        if HasCollisionLoadedAroundEntity(entity) and not IsEntityWaitingForWorldCollision(entity) then
            return true
        end
        Wait(0)
    end

    return HasCollisionLoadedAroundEntity(entity) and not IsEntityWaitingForWorldCollision(entity)
end

local function settleGroundZ(entity, x, y, initialZ)
    local probeZ = initialZ + 3.0
    SetEntityCoordsNoOffset(entity, x, y, probeZ, false, false, false)
    waitForCollision(entity, x, y, initialZ, GROUND_SETTLE_TIMEOUT)

    local ok, refinedZ = GetGroundZFor_3dCoord(x, y, probeZ + 2.0, false)
    return ok and refinedZ or initialZ
end

local function getGroundCoords(entity, coords)
    local x, y = coords.x, coords.y
    requestGroundCollision(x, y, coords.z)

    local found, groundZ = GetGroundZFor_3dCoord(x, y, coords.z, false)
    if found then
        groundZ = settleGroundZ(entity, x, y, groundZ)
        return vector3(x, y, groundZ)
    end

    local z = coords.z
    local step = 100.0

    while z > -50.0 do
        local previousZ = z
        local nextZ = math.max(previousZ - step, -50.0)

        if previousZ > GROUND_FINE_CEILING and nextZ < GROUND_FINE_CEILING then
            nextZ = GROUND_FINE_CEILING
        end

        z = nextZ
        found, groundZ = probeGroundAtZ(entity, x, y, z)
        if found then
            groundZ = settleGroundZ(entity, x, y, groundZ)
            return vector3(x, y, groundZ)
        end

        if previousZ - z > GROUND_FINE_STEP and z <= GROUND_FINE_CEILING then
            found, groundZ = scanGroundBand(entity, x, y, previousZ, z)
            if found then
                groundZ = settleGroundZ(entity, x, y, groundZ)
                return vector3(x, y, groundZ)
            end

            step = GROUND_FINE_STEP
        elseif z <= GROUND_FINE_CEILING then
            step = GROUND_FINE_STEP
        else
            step = math.min(step * 2, GROUND_PROBE_MAX_STEP)
        end
    end

    local raycastCoords = raycastGround(entity, x, y, coords.z + 25.0, -100.0)
    if raycastCoords then
        waitForCollision(entity, x, y, raycastCoords.z, GROUND_SETTLE_TIMEOUT)
        return raycastCoords
    end

    return vector3(x, y, 0.0)
end

local function prepareLanding(entity, coords)
    FreezeEntityPosition(entity, true)

    local groundCoords = getGroundCoords(entity, coords)
    local targetZ = groundCoords.z + LANDING_CLEARANCE

    SetEntityCoordsNoOffset(entity, groundCoords.x, groundCoords.y, targetZ, false, false, false)
    waitForCollision(entity, groundCoords.x, groundCoords.y, groundCoords.z, GROUND_SETTLE_TIMEOUT)

    local ok, refinedZ = GetGroundZFor_3dCoord(groundCoords.x, groundCoords.y, targetZ + 5.0, false)
    if ok then
        groundCoords = vector3(groundCoords.x, groundCoords.y, refinedZ)
        SetEntityCoordsNoOffset(entity, groundCoords.x, groundCoords.y, refinedZ + LANDING_CLEARANCE, false, false, false)
        waitForCollision(entity, groundCoords.x, groundCoords.y, refinedZ, GROUND_SETTLE_TIMEOUT)
    end
end

------------------------------------------------------------------------
-- Landing protection
------------------------------------------------------------------------

local function waitForLanding(ped, entity)
    local timeout = MIN_LANDING_TIMEOUT
    local startTime = GetGameTimer()

    while GetGameTimer() - startTime < timeout do
        if noClipEnabled then break end

        if GetVehiclePedIsIn(ped, false) ~= 0 then
            if not IsEntityInAir(entity) and IsVehicleOnAllWheels(entity) then
                break
            end
        elseif not IsEntityInAir(entity) and not IsPedFalling(entity) and not IsPedRagdoll(entity) then
            break
        end

        Wait(0)
    end

    if not noClipEnabled then
        if entity ~= ped then
            SetEntityInvincible(entity, false)
        end
        pcall(function() exports['FeloxAC']:isInvincible(false) end) --[[FeloxAC:auto]]
        SetPlayerInvincible(PlayerId(), false)
    end
end

------------------------------------------------------------------------
-- Enable
------------------------------------------------------------------------

local function enableNoClip()
    noClipEnabled = true
    LocalPlayer.state:set('noclip', true, false) -- daddy_pausemenu opens while it flies
    local ped = cache.ped

    local veh = GetVehiclePedIsIn(cache.ped, false)
    local inVehicle = veh ~= 0 and ped == GetPedInVehicleSeat(veh, -1)
    if inVehicle then
        freecamVeh = veh
        SetVehicleEngineOn(veh, false, true, true)
        NetworkSetEntityInvisibleToNetwork(veh, true)
        FreezeEntityPosition(veh, true)
        SetEntityCollision(veh, false, false)
    else
        freecamVeh = 0
    end

    if not inVehicle then
        ClearPedTasksImmediately(ped)
    end
    FreezeEntityPosition(ped, true)
    pcall(function() exports['FeloxAC']:isVisible(false) end) --[[FeloxAC:auto]]
    SetEntityVisible(ped, false, false)
    SetEntityCollision(ped, false, false)
    pcall(function() exports['FeloxAC']:isInvincible(true) end) --[[FeloxAC:auto]]
    SetPlayerInvincible(PlayerId(), true)
    if inVehicle then
        SetEntityInvincible(freecamVeh, true)
    end
    SetEveryoneIgnorePlayer(ped, true)
    SetPoliceIgnorePlayer(ped, true)

    PlaySoundFromEntity(-1, 'SELECT', ped, 'HUD_LIQUOR_STORE_SOUNDSET', 0, 0)
    SetUserRadioControlEnabled(false)

    SetFreecamActive(true)
    StartFreecamThread()

    local lastEntitySync = 0

    Citizen.CreateThread(function()
        while IsFreecamActive() do
            HudWeaponWheelIgnoreSelection()
            DisableAllControlActions(0)
            DisableAllControlActions(1)
            DisableAllControlActions(2)
            EnableControlAction(0, 220, true)
            EnableControlAction(0, 221, true)
            EnableControlAction(0, 245, true)

            SetEntityLocallyInvisible(ped)

            local camPos = GetFreecamPosition()
            local now = GetGameTimer()
            if camPos and now - lastEntitySync >= ENTITY_SYNC_INTERVAL then
                lastEntitySync = now
                if freecamVeh > 0 and DoesEntityExist(freecamVeh) then
                    SetEntityCoordsNoOffset(freecamVeh, camPos.x, camPos.y, camPos.z)
                else
                    SetEntityCoordsNoOffset(ped, camPos.x, camPos.y, camPos.z)
                end
            end

            if freecamVeh > 0 then
                if DoesEntityExist(freecamVeh) then
                    SetEntityLocallyInvisible(freecamVeh)
                else
                    freecamVeh = 0
                end
            end

            Wait(0)
        end

        local exitEntity = (freecamVeh > 0 and DoesEntityExist(freecamVeh)) and freecamVeh or ped
        local exitInVehicle = exitEntity ~= ped

        prepareLanding(exitEntity, GetEntityCoords(exitEntity))
        local camRot = GetFreecamRotation()
        if camRot then
            SetEntityHeading(exitEntity, camRot.z % 360)
        end

        if exitInVehicle then
            SetEntityCollision(exitEntity, true, true)
            if GetVehiclePedIsIn(cache.ped, false) ~= exitEntity then
                SetPedIntoVehicle(ped, exitEntity, -1)
            end
        end
        SetEntityCollision(ped, true, true)
        SetEntityVelocity(exitEntity, 0.0, 0.0, 0.0)

        if exitInVehicle then
            FreezeEntityPosition(exitEntity, false)
        end
        FreezeEntityPosition(ped, false)

        Wait(0)

        PlaySoundFromEntity(-1, 'CANCEL', ped, 'HUD_LIQUOR_STORE_SOUNDSET', 0, 0)

        pcall(function() exports['FeloxAC']:isVisible(true) end) --[[FeloxAC:auto]]
        SetEntityVisible(ped, true, false)
        SetLocalPlayerVisibleLocally(true)
        SetEveryoneIgnorePlayer(ped, false)
        SetPoliceIgnorePlayer(ped, false)

        if freecamVeh > 0 and DoesEntityExist(freecamVeh) then
            NetworkSetEntityInvisibleToNetwork(freecamVeh, false)
            SetVehicleEngineOn(freecamVeh, true, true, false)
            freecamVeh = 0
        end

        SetGameplayCamRelativeHeading(0)
        SetUserRadioControlEnabled(true)

        waitForLanding(ped, exitEntity)
        SetEntityLoadCollisionFlag(exitEntity, false)
        ClearFocus()
    end)
end

------------------------------------------------------------------------
-- Disable
------------------------------------------------------------------------

local function disableNoClip()
    noClipEnabled = false
    LocalPlayer.state:set('noclip', false, false)
    if IsFreecamActive() then
        SetFreecamActive(false)
    end
end

toggleNoClip = function()
    if noClipEnabled then
        disableNoClip()
    else
        enableNoClip()
    end
end

forceDisableNoClip = function()
    if noClipEnabled then
        disableNoClip()
    end
end

------------------------------------------------------------------------
-- Resource stop
------------------------------------------------------------------------

AddEventHandler('onResourceStop', function(resName)
    if resName ~= RESOURCE_NAME then return end
    if not noClipEnabled then return end

    noClipEnabled = false
    LocalPlayer.state:set('noclip', false, false)
    local ped = cache.ped

    if ped and DoesEntityExist(ped) then
        FreezeEntityPosition(ped, false)
        SetEntityCollision(ped, true, true)
        SetEntityLoadCollisionFlag(ped, false)
        pcall(function() exports['FeloxAC']:isVisible(true) end) --[[FeloxAC:auto]]
        SetEntityVisible(ped, true, false)
        pcall(function() exports['FeloxAC']:isInvincible(false) end) --[[FeloxAC:auto]]
        SetPlayerInvincible(PlayerId(), false)
        SetEveryoneIgnorePlayer(ped, false)
        SetPoliceIgnorePlayer(ped, false)
    end

    if freecamVeh > 0 and DoesEntityExist(freecamVeh) then
        NetworkSetEntityInvisibleToNetwork(freecamVeh, false)
        FreezeEntityPosition(freecamVeh, false)
        SetEntityCollision(freecamVeh, true, true)
        SetEntityLoadCollisionFlag(freecamVeh, false)
        SetEntityInvincible(freecamVeh, false)
        SetVehicleEngineOn(freecamVeh, true, true, false)
        freecamVeh = 0
    end

    SetLocalPlayerVisibleLocally(true)

    if IsFreecamActive() then
        SetFreecamActive(false)
    end
    ClearFocus()
    SetGameplayCamRelativeHeading(0)
    SetUserRadioControlEnabled(true)
end)

------------------------------------------------------------------------
-- Command and key mapping (permission-gated)
------------------------------------------------------------------------

local toggleInProgress = false

lib.addKeybind({
    name = Config.noClipCommand,
    description = Config.noClipKeyLabel,
    defaultKey = Config.noClipKeybind and Config.noClipKey or nil,
    defaultMapper = 'keyboard',
    onPressed = function(self)
        if toggleInProgress then return end
        toggleInProgress = true
        local allowed = checkNoClipPermission()
        toggleInProgress = false
        if not allowed then return end
        toggleNoClip()
    end
})
