local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1
L0_1 = nil
L1_1 = nil
L2_1 = false
L3_1 = {}
L4_1 = {}
L5_1 = false
function L6_1()
  local L0_2, L1_2, L2_2
  L0_2 = L0_1
  if L0_2 then
    L0_2 = HasScaleformMovieLoaded
    L1_2 = L0_1
    L0_2 = L0_2(L1_2)
    if L0_2 then
      L0_2 = BeginScaleformMovieMethod
      L1_2 = L0_1
      L2_2 = "CLEAR_TEXTURES"
      L0_2(L1_2, L2_2)
      L0_2 = EndScaleformMovieMethod
      L0_2()
    end
  end
end
function L7_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2
  L2_2 = AddBlipForCoord
  L3_2 = A0_2
  L4_2 = A1_2
  L5_2 = 0.0
  L2_2 = L2_2(L3_2, L4_2, L5_2)
  L3_2 = SetBlipSprite
  L4_2 = L2_2
  L5_2 = 575
  L3_2(L4_2, L5_2)
  L3_2 = SetBlipDisplay
  L4_2 = L2_2
  L5_2 = 4
  L3_2(L4_2, L5_2)
  L3_2 = SetBlipScale
  L4_2 = L2_2
  L5_2 = 0.0
  L3_2(L4_2, L5_2)
  L3_2 = SetBlipAlpha
  L4_2 = L2_2
  L5_2 = 255
  L3_2(L4_2, L5_2)
  L3_2 = SetBlipAsShortRange
  L4_2 = L2_2
  L5_2 = true
  L3_2(L4_2, L5_2)
  L3_2 = BeginTextCommandSetBlipName
  L4_2 = "STRING"
  L3_2(L4_2)
  L3_2 = AddTextComponentString
  L4_2 = "Map boundary"
  L3_2(L4_2)
  L3_2 = EndTextCommandSetBlipName
  L4_2 = L2_2
  L3_2(L4_2)
  L3_2 = L4_1
  L3_2 = #L3_2
  L4_2 = L3_2 + 1
  L3_2 = L4_1
  L3_2[L4_2] = L2_2
end
function L8_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2
  L2_2 = 5.333333333333333
  L3_2 = BeginScaleformMovieMethod
  L4_2 = L0_1
  L5_2 = "DRAW_TEXTURE"
  L3_2(L4_2, L5_2)
  L3_2 = _ENV
  L4_2 = "PushScaleformMovieFunctionParameterString"
  L3_2 = L3_2[L4_2]
  L4_2 = A0_2.name
  L3_2(L4_2)
  L3_2 = _ENV
  L4_2 = "PushScaleformMovieFunctionParameterString"
  L3_2 = L3_2[L4_2]
  L4_2 = A0_2.dictionary
  L3_2(L4_2)
  L3_2 = _ENV
  L4_2 = "PushScaleformMovieFunctionParameterString"
  L3_2 = L3_2[L4_2]
  L4_2 = A0_2.name
  L3_2(L4_2)
  L3_2 = PushScaleformMovieFunctionParameterFloat
  L4_2 = A0_2.x
  L4_2 = L4_2 / L2_2
  L4_2 = 864.0 + L4_2
  L3_2(L4_2)
  L3_2 = PushScaleformMovieFunctionParameterFloat
  L4_2 = A0_2.y
  L4_2 = L4_2 / L2_2
  L5_2 = 1440.0
  L4_2 = L5_2 - L4_2
  L3_2(L4_2)
  L3_2 = PushScaleformMovieFunctionParameterFloat
  L4_2 = A0_2.width
  L4_2 = L4_2 / L2_2
  L3_2(L4_2)
  L3_2 = PushScaleformMovieFunctionParameterFloat
  L4_2 = A0_2.height
  L4_2 = L4_2 / L2_2
  L3_2(L4_2)
  L3_2 = PushScaleformMovieFunctionParameterBool
  L4_2 = false
  L3_2(L4_2)
  L3_2 = PushScaleformMovieFunctionParameterInt
  L4_2 = A1_2
  L3_2(L4_2)
  L3_2 = PushScaleformMovieFunctionParameterFloat
  L4_2 = 0.0
  L3_2(L4_2)
  L3_2 = EndScaleformMovieMethod
  L3_2()
end
L9_1 = CreateThread
function L10_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L0_2 = math
  L0_2 = L0_2.floor
  L1_2 = math
  L1_2 = L1_2.max
  L2_2 = 0
  L3_2 = math
  L3_2 = L3_2.min
  L4_2 = 100
  L5_2 = tonumber
  L6_2 = Config
  L6_2 = L6_2.Opacity
  L5_2 = L5_2(L6_2)
  if not L5_2 then
    L5_2 = 100
  end
  L3_2 = L3_2(L4_2, L5_2)
  L1_2 = L1_2(L2_2, L3_2)
  L0_2 = L0_2(L1_2)
  L1_2 = Config
  L1_2 = L1_2.Enabled
  if not L1_2 or 0 == L0_2 then
    return
  end
  L1_2 = ipairs
  L2_2 = MapTiles
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L8_2 = L6_2.dictionary
    L7_2 = L3_1
    L7_2 = L7_2[L8_2]
    if not L7_2 then
      L8_2 = L6_2.dictionary
      L7_2 = L3_1
      L7_2[L8_2] = true
      L7_2 = RequestStreamedTextureDict
      L8_2 = L6_2.dictionary
      L9_2 = false
      L7_2(L8_2, L9_2)
    end
  end
  L1_2 = pairs
  L2_2 = L3_1
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2 in L1_2, L2_2, L3_2, L4_2 do
    while true do
      L6_2 = L5_1
      if L6_2 then
        break
      end
      L6_2 = HasStreamedTextureDictLoaded
      L7_2 = L5_2
      L6_2 = L6_2(L7_2)
      if L6_2 then
        break
      end
      L6_2 = Wait
      L7_2 = 50
      L6_2(L7_2)
    end
    L6_2 = L5_1
    if L6_2 then
      return
    end
  end
  while true do
    L1_2 = L5_1
    if L1_2 then
      break
    end
    L1_2 = IsMinimapRendering
    L1_2 = L1_2()
    if L1_2 then
      break
    end
    L1_2 = Wait
    L2_2 = 100
    L1_2(L2_2)
  end
  L1_2 = L5_1
  if L1_2 then
    return
  end
  L1_2 = RequestScaleformMovie
  L2_2 = "minimap_main_map"
  L1_2 = L1_2(L2_2)
  L0_1 = L1_2
  while true do
    L1_2 = L5_1
    if L1_2 then
      break
    end
    L1_2 = HasScaleformMovieLoaded
    L2_2 = L0_1
    L1_2 = L1_2(L2_2)
    if L1_2 then
      break
    end
    L1_2 = Wait
    L2_2 = 50
    L1_2(L2_2)
  end
  L1_2 = L5_1
  if L1_2 then
    return
  end
  L1_2 = L6_1
  L1_2()
  L1_2 = ipairs
  L2_2 = MapTiles
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = L8_1
    L8_2 = L6_2
    L9_2 = L0_2
    L7_2(L8_2, L9_2)
  end
  L1_2 = RequestScaleformMovie
  L2_2 = "minimap"
  L1_2 = L1_2(L2_2)
  L1_1 = L1_2
  while true do
    L1_2 = L5_1
    if L1_2 then
      break
    end
    L1_2 = HasScaleformMovieLoaded
    L2_2 = L1_1
    L1_2 = L1_2(L2_2)
    if L1_2 then
      break
    end
    L1_2 = Wait
    L2_2 = 50
    L1_2(L2_2)
  end
  L1_2 = L5_1
  if L1_2 then
    return
  end
  L1_2 = IsBigmapActive
  L1_2 = L1_2()
  if not L1_2 then
    L1_2 = true
    L2_1 = L1_2
    L1_2 = SetBigmapActive
    L2_2 = true
    L3_2 = false
    L1_2(L2_2, L3_2)
    L1_2 = Wait
    L2_2 = 0
    L1_2(L2_2)
    L1_2 = L5_1
    if not L1_2 then
      L1_2 = SetBigmapActive
      L2_2 = false
      L3_2 = false
      L1_2(L2_2, L3_2)
      L1_2 = false
      L2_1 = L1_2
    end
  end
  L1_2 = L5_1
  if L1_2 then
    return
  end
  L1_2 = SetScaleformMovieAsNoLongerNeeded
  L2_2 = L1_1
  L1_2(L2_2)
  L1_2 = nil
  L1_1 = L1_2
  L1_2 = Config
  L1_2 = L1_2.ExpandPauseMap
  if L1_2 then
    L1_2 = L5_1
    if not L1_2 then
      L1_2 = math
      L1_2 = L1_2.max
      L2_2 = 0.0
      L3_2 = math
      L3_2 = L3_2.min
      L4_2 = 5000.0
      L5_2 = tonumber
      L6_2 = Config
      L6_2 = L6_2.MapBoundaryPadding
      L5_2 = L5_2(L6_2)
      if not L5_2 then
        L5_2 = 2500.0
      end
      L3_2 = L3_2(L4_2, L5_2)
      L1_2 = L1_2(L2_2, L3_2)
      L2_2 = L7_1
      L3_2 = MapBounds
      L3_2 = L3_2.maxX
      L3_2 = L3_2 + L1_2
      L4_2 = MapBounds
      L4_2 = L4_2.minY
      L4_2 = L4_2 - L1_2
      L2_2(L3_2, L4_2)
    end
  end
end
L9_1(L10_1)
L9_1 = AddEventHandler
L10_1 = "onResourceStop"
function L11_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L1_2 = GetCurrentResourceName
  L1_2 = L1_2()
  if A0_2 ~= L1_2 then
    return
  end
  L1_2 = true
  L5_1 = L1_2
  L1_2 = L2_1
  if L1_2 then
    L1_2 = SetBigmapActive
    L2_2 = false
    L3_2 = false
    L1_2(L2_2, L3_2)
    L1_2 = false
    L2_1 = L1_2
  end
  L1_2 = L6_1
  L1_2()
  L1_2 = ipairs
  L2_2 = L4_1
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = RemoveBlip
    L8_2 = L6_2
    L7_2(L8_2)
  end
  L1_2 = pairs
  L2_2 = L3_1
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2 in L1_2, L2_2, L3_2, L4_2 do
    L6_2 = SetStreamedTextureDictAsNoLongerNeeded
    L7_2 = L5_2
    L6_2(L7_2)
  end
  L1_2 = L0_1
  if L1_2 then
    L1_2 = SetScaleformMovieAsNoLongerNeeded
    L2_2 = L0_1
    L1_2(L2_2)
  end
  L1_2 = L1_1
  if L1_2 then
    L1_2 = SetScaleformMovieAsNoLongerNeeded
    L2_2 = L1_1
    L1_2(L2_2)
  end
end
L9_1(L10_1, L11_1)
