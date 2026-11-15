local rad = math.rad
local sin = math.sin
local cos = math.cos
local min = math.min
local max = math.max
local type = type

function Clamp(x, lo, hi)
  return min(max(x, lo), hi)
end

function ClampCameraRotation(rotX, rotY, rotZ)
  return Clamp(rotX, -90.0, 90.0), rotY % 360, rotZ % 360
end

function IsGamepadControl()
  return not IsUsingKeyboard(2)
end

function GetSmartControlNormal(control)
  if type(control) == 'table' then
    return GetDisabledControlNormal(0, control[1]) - GetDisabledControlNormal(0, control[2])
  end
  return GetDisabledControlNormal(0, control)
end

function EulerToMatrix(rotX, rotY, rotZ)
  local rX, rY, rZ = rad(rotX), rad(rotY), rad(rotZ)
  local sX, sY, sZ = sin(rX), sin(rY), sin(rZ)
  local cX, cY, cZ = cos(rX), cos(rY), cos(rZ)

  return
    vector3(cY*cZ,             cY*sZ,             -sY),
    vector3(cZ*sX*sY - cX*sZ, cX*cZ - sX*sY*sZ,  cY*sX),
    vector3(sX*sZ - cX*cZ*sY, cX*sY*sZ - cZ*sX,  cX*cY)
end
