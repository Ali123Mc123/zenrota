local floor = math.floor
local SetCamRot = SetCamRot
local IsCamActive = IsCamActive
local SetCamCoord = SetCamCoord
local SetFocusPosAndVel = SetFocusPosAndVel
local LockMinimapAngle = LockMinimapAngle
local LockMinimapPosition = LockMinimapPosition

local cam = nil
local pos, rot
local vecX, vecY

--------------------------------------------------------------------------------

function GetFreecamPosition() return pos end

function SetFreecamPosition(x, y, z)
  pos = vector3(x, y, z)
  SetFocusPosAndVel(x, y, z, 0.0, 0.0, 0.0)
  SetCamCoord(cam, x, y, z)
  LockMinimapPosition(x, y)
end

--------------------------------------------------------------------------------

function GetFreecamRotation() return rot end

function SetFreecamRotation(x, y, z)
  local rx, ry, rz = ClampCameraRotation(x, y, z)
  vecX, vecY = EulerToMatrix(rx, ry, rz)
  rot = vector3(rx, ry, rz)
  LockMinimapAngle(floor(rz))
  SetCamRot(cam, rx, ry, rz, 2)
end

--------------------------------------------------------------------------------

function GetFreecamMatrix() return vecX, vecY end

--------------------------------------------------------------------------------

function IsFreecamActive()
  return IsCamActive(cam) == 1
end

function SetFreecamActive(active)
  if active == IsFreecamActive() then return end

  local cfg = FreecamConfig.CAMERA

  if active then
    local initPos = GetGameplayCamCoord()
    local initRot = GetGameplayCamRot(2)

    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
    SetCamFov(cam, Clamp(cfg.FOV, 0.0, 90.0))
    SetFreecamPosition(initPos.x, initPos.y, initPos.z)
    SetFreecamRotation(initRot.x, 0.0, initRot.z)
  else
    pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]]
    DestroyCam(cam)
    ClearFocus()
    UnlockMinimapAngle()
    UnlockMinimapPosition()
  end

  RenderScriptCams(active, cfg.ENABLE_EASING, cfg.EASING_DURATION, true, true)
end
