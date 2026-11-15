local Crouched = false
local CrouchedForce = false
local Aimed = false
local CoolDown = false
local CoolDownTime = 500

local function NormalWalk()
  local ped = cache.ped
  if not ped then return end
  SetPedMaxMoveBlendRatio(ped, 1.0)
  ResetPedMovementClipset(ped, 0.55)
  ResetPedStrafeClipset(ped)
  SetPedCanPlayAmbientAnims(ped, true)
  SetPedCanPlayAmbientBaseAnims(ped, true)
  ResetPedWeaponMovementClipset(ped)
  Crouched = false
end

local function SetupCrouch()
  if not HasAnimSetLoaded('move_ped_crouched') then
    RequestAnimSet('move_ped_crouched')
    while not HasAnimSetLoaded('move_ped_crouched') do
      Wait(0)
    end
  end
end

local function RemoveCrouchAnim()
  RemoveAnimSet('move_ped_crouched')
end

local function CanCrouch()
  local ped = cache.ped
  if not ped then return false end

  if IsPedOnFoot(ped) and not IsPedInAnyVehicle(ped, false) and
      not IsPedJumping(ped) and not IsPedFalling(ped) and not IsPedDeadOrDying(ped) then
    return true
  end

  return false
end

local function CrouchPlayer()
  local ped = cache.ped
  SetPedUsingActionMode(ped, false, -1, "DEFAULT_ACTION")
  SetPedMovementClipset(ped, 'move_ped_crouched', 0.55)
  SetPedStrafeClipset(ped, 'move_ped_crouched_strafing')
  SetWeaponAnimationOverride(ped, "Ballistic")
  Crouched = true
  Aimed = false
end

local function SetPlayerAimSpeed()
  SetPedMaxMoveBlendRatio(cache.ped, 0.2)
  Aimed = true
end

local function IsPlayerFreeAimed()
  return IsPlayerFreeAiming(cache.playerId) or IsAimCamActive() or IsAimCamThirdPersonActive()
end

local function CrouchLoop()
  SetupCrouch()
  while CrouchedForce do
    DisableFirstPersonCamThisFrame()
    local ped = cache.ped

    if IsPedArmed(ped, 7) then
      CrouchedForce = false
      break
    end

    local CanDo = CanCrouch()
    if CanDo and Crouched and IsPlayerFreeAimed() then
      SetPlayerAimSpeed()
    elseif CanDo and (not Crouched or Aimed) then
      CrouchPlayer()
    elseif not CanDo and Crouched then
      CrouchedForce = false
      NormalWalk()
    end

    Wait(0)
  end
  NormalWalk()
  RemoveCrouchAnim()
end

RegisterCommand('crouch', function()
  if not CoolDown then
    local ped = cache.ped
    if not ped or IsPedArmed(ped, 7) then return end

    local CanDo = CanCrouch()
    CrouchedForce = CanDo and not CrouchedForce or false

    if CrouchedForce then
      CreateThread(CrouchLoop)
    end

    if CoolDownTime and CoolDownTime ~= 0 then
      CoolDown = true
      SetTimeout(CoolDownTime, function()
        CoolDown = false
      end)
    end
  end
end, false)

RegisterKeyMapping('crouch', 'Crouch', 'keyboard', 'LCONTROL')

exports("IsCrouched", function()
  return Crouched
end)
