local Wait = Citizen.Wait
local IsPauseMenuActive = IsPauseMenuActive
local GetSmartControlNormal = GetSmartControlNormal

local VEC_UP = vector3(0, 0, 1)

-------------------------------------------------------------------------------

local function GetSpeedMultiplier(controls, settings)
  local fastNormal = GetSmartControlNormal(controls.MOVE_FAST)
  local slowNormal = GetSmartControlNormal(controls.MOVE_SLOW)

  local baseSpeed = settings.BASE_MOVE_MULTIPLIER
  local fastSpeed = 1 + ((settings.FAST_MOVE_MULTIPLIER - 1) * fastNormal)
  local slowSpeed = 1 + ((settings.SLOW_MOVE_MULTIPLIER - 1) * slowNormal)

  return baseSpeed * fastSpeed / slowSpeed * GetFrameTime() * 60
end

local function UpdateCamera()
  if not IsFreecamActive() or IsPauseMenuActive() then return end

  local useGamepad = IsGamepadControl()
  local controls = useGamepad and FreecamConfig.GAMEPAD_CONTROLS or FreecamConfig.KEYBOARD_CONTROLS
  local settings = useGamepad and FreecamConfig.GAMEPAD_SETTINGS or FreecamConfig.KEYBOARD_SETTINGS

  local vecX, vecY = GetFreecamMatrix()
  local pos = GetFreecamPosition()
  local rot = GetFreecamRotation()

  local speed = GetSpeedMultiplier(controls, settings)

  local lookX = GetSmartControlNormal(controls.LOOK_X)
  local lookY = GetSmartControlNormal(controls.LOOK_Y)

  local moveX = GetSmartControlNormal(controls.MOVE_X)
  local moveY = GetSmartControlNormal(controls.MOVE_Y)
  local moveZ = GetSmartControlNormal(controls.MOVE_Z)

  pos = pos + (vecX * moveX * speed) + (vecY * -moveY * speed) + (VEC_UP * moveZ * speed)

  SetFreecamPosition(pos.x, pos.y, pos.z)
  SetFreecamRotation(
    rot.x + (-lookY * settings.LOOK_SENSITIVITY_X),
    rot.y,
    rot.z + (-lookX * settings.LOOK_SENSITIVITY_Y)
  )
end

-------------------------------------------------------------------------------

local function buildInstructionalScaleform()
  local useGamepad = IsGamepadControl()
  local controls = useGamepad and FreecamConfig.GAMEPAD_CONTROLS or FreecamConfig.KEYBOARD_CONTROLS
  local keys = {
    { 'Slower',     controls.MOVE_SLOW },
    { 'Faster',     controls.MOVE_FAST },
    { 'Down',       controls.MOVE_Z[2] },
    { 'Up',         controls.MOVE_Z[1] },
    { 'Left/Right', controls.MOVE_X },
    { 'Fwd/Back',   controls.MOVE_Y },
  }

  local sf = RequestScaleformMovie('instructional_buttons')
  while not HasScaleformMovieLoaded(sf) do Wait(10) end

  BeginScaleformMovieMethod(sf, 'CLEAR_ALL')
  EndScaleformMovieMethod()

  BeginScaleformMovieMethod(sf, 'SET_CLEAR_SPACE')
  ScaleformMovieMethodAddParamInt(200)
  EndScaleformMovieMethod()

  for i, key in ipairs(keys) do
    BeginScaleformMovieMethod(sf, 'SET_DATA_SLOT')
    ScaleformMovieMethodAddParamInt(i - 1)
    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0, key[2], true))
    BeginTextCommandScaleformString('STRING')
    AddTextComponentSubstringKeyboardDisplay(key[1])
    EndTextCommandScaleformString()
    EndScaleformMovieMethod()
  end

  BeginScaleformMovieMethod(sf, 'DRAW_INSTRUCTIONAL_BUTTONS')
  EndScaleformMovieMethod()

  BeginScaleformMovieMethod(sf, 'SET_BACKGROUND_COLOUR')
  ScaleformMovieMethodAddParamInt(0)
  ScaleformMovieMethodAddParamInt(0)
  ScaleformMovieMethodAddParamInt(0)
  ScaleformMovieMethodAddParamInt(80)
  EndScaleformMovieMethod()

  return sf
end

function StartFreecamThread()
  Citizen.CreateThread(function()
    local initialPos = GetEntityCoords(PlayerPedId())
    SetFreecamPosition(initialPos.x, initialPos.y, initialPos.z)

    while IsFreecamActive() do
      UpdateCamera()
      Wait(0)
    end
  end)

  CreateThread(function()
    local sf = buildInstructionalScaleform()
    while IsFreecamActive() do
      DrawScaleformMovieFullscreen(sf, 255, 255, 255, 255, 0)
      Wait(0)
    end
    SetScaleformMovieAsNoLongerNeeded(sf)
  end)
end
