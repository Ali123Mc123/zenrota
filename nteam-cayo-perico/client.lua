local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1, L12_1, L13_1, L14_1, L15_1, L16_1, L17_1, L18_1, L19_1, L20_1, L21_1, L22_1, L23_1, L24_1, L25_1, L26_1, L27_1
L0_1 = GetCurrentResourceName
L0_1 = L0_1()
L1_1 = Config
L1_1 = L1_1.Features
L2_1 = true
L3_1 = false
L4_1 = false
L5_1 = {}
L6_1 = nil
L7_1 = nil
L8_1 = nil
L9_1 = nil
L10_1 = nil
L11_1 = GetResourceKvpInt
L12_1 = "nteam_path_nodes_owned"
L11_1 = L11_1(L12_1)
L11_1 = 1 == L11_1
L12_1 = {}
L13_1 = "se_dlc_aw_arena_construction_01"
L14_1 = "se_dlc_aw_arena_crowd_background_main"
L15_1 = "se_dlc_aw_crowd_exterior_lobby"
L16_1 = "se_dlc_aw_crowd_interior_lobby"
L12_1[1] = L13_1
L12_1[2] = L14_1
L12_1[3] = L15_1
L12_1[4] = L16_1
L13_1 = {}
L13_1.diamond = "pink_diamond_set"
L13_1.panther = "panther_set"
L13_1.necklace = "pearl_necklace_set"
function L14_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = A0_2.x
  L3_2 = Config
  L3_2 = L3_2.Area
  L3_2 = L3_2.center
  L3_2 = L3_2.x
  L2_2 = L2_2 - L3_2
  L3_2 = A0_2.y
  L4_2 = Config
  L4_2 = L4_2.Area
  L4_2 = L4_2.center
  L4_2 = L4_2.y
  L3_2 = L3_2 - L4_2
  if A1_2 then
    L4_2 = Config
    L4_2 = L4_2.Area
    L4_2 = L4_2.exitRadius
    if L4_2 then
      goto lbl_25
    end
  end
  L4_2 = Config
  L4_2 = L4_2.Area
  L4_2 = L4_2.enterRadius
  ::lbl_25::
  L5_2 = L2_2 * L2_2
  L6_2 = L3_2 * L3_2
  L5_2 = L5_2 + L6_2
  L6_2 = L4_2 * L4_2
  L5_2 = L5_2 < L6_2
  return L5_2
end
function L15_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2
  L0_2 = {}
  L1_2 = ipairs
  L2_2 = CayoIpls
  L2_2 = L2_2.core
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L0_2[L6_2] = true
  end
  L1_2 = pairs
  L2_2 = CayoIpls
  L2_2 = L2_2.groups
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = assert
    L8_2 = type
    L9_2 = L1_1
    L9_2 = L9_2[L5_2]
    L8_2 = L8_2(L9_2)
    L8_2 = "boolean" == L8_2
    L9_2 = "Expected boolean setting: Features."
    L10_2 = L5_2
    L9_2 = L9_2 .. L10_2
    L7_2(L8_2, L9_2)
    L7_2 = ipairs
    L8_2 = L6_2
    L7_2, L8_2, L9_2, L10_2 = L7_2(L8_2)
    for L11_2, L12_2 in L7_2, L8_2, L9_2, L10_2 do
      L13_2 = L1_1
      L13_2 = L13_2[L5_2]
      L0_2[L12_2] = L13_2
    end
  end
  L1_2 = pairs
  L2_2 = CayoIpls
  L2_2 = L2_2.variants
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = assert
    L8_2 = L1_1
    L8_2 = L8_2[L5_2]
    L8_2 = L6_2[L8_2]
    L9_2 = "Invalid variant: Features."
    L10_2 = L5_2
    L9_2 = L9_2 .. L10_2
    L7_2(L8_2, L9_2)
    L7_2 = pairs
    L8_2 = L6_2
    L7_2, L8_2, L9_2, L10_2 = L7_2(L8_2)
    for L11_2, L12_2 in L7_2, L8_2, L9_2, L10_2 do
      L13_2 = ipairs
      L14_2 = L12_2
      L13_2, L14_2, L15_2, L16_2 = L13_2(L14_2)
      for L17_2, L18_2 in L13_2, L14_2, L15_2, L16_2 do
        L19_2 = L1_1
        L19_2 = L19_2[L5_2]
        L19_2 = L19_2 == L11_2
        L0_2[L18_2] = L19_2
      end
    end
  end
  L1_2 = ipairs
  L2_2 = Config
  L2_2 = L2_2.ExtraIpls
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = assert
    L8_2 = type
    L9_2 = L6_2.name
    L8_2 = L8_2(L9_2)
    L8_2 = "string" == L8_2
    L9_2 = "Invalid ExtraIpls entry"
    L7_2(L8_2, L9_2)
    L7_2 = L6_2.name
    L8_2 = L7_2
    L7_2 = L7_2.lower
    L7_2 = L7_2(L8_2)
    L8_2 = L6_2.enabled
    L0_2[L7_2] = L8_2
  end
  L1_2 = ipairs
  L2_2 = Config
  L2_2 = L2_2.UnmanagedIpls
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = assert
    L8_2 = type
    L9_2 = L6_2
    L8_2 = L8_2(L9_2)
    L8_2 = "string" == L8_2 and "" ~= L6_2
    L9_2 = "Invalid UnmanagedIpls entry"
    L7_2(L8_2, L9_2)
    L8_2 = L6_2
    L7_2 = L6_2.lower
    L7_2 = L7_2(L8_2)
    L0_2[L7_2] = nil
  end
  return L0_2
end
L16_1 = assert
L17_1 = Config
L17_1 = L17_1.Area
L17_1 = L17_1.enterRadius
L17_1 = L17_1 > 0
L18_1 = "exitRadius must exceed enterRadius"
L16_1(L17_1, L18_1)
L16_1 = assert
L17_1 = Config
L17_1 = L17_1.Area
L17_1 = L17_1.pollMs
L17_1 = L17_1 >= 100
L18_1 = "Area.pollMs must be at least 100"
L16_1(L17_1, L18_1)
L16_1 = assert
L17_1 = Config
L17_1 = L17_1.Vault
L17_1 = L17_1.activationRadius
L17_1 = L17_1 > 0
L18_1 = "Invalid Vault radius or retry interval"
L16_1(L17_1, L18_1)
L16_1 = assert
L17_1 = L1_1.vault
L17_1 = L1_1.vault
L17_1 = "none" == L17_1 or L17_1
L18_1 = "Invalid Features.vault selection"
L16_1(L17_1, L18_1)
L16_1 = ipairs
L17_1 = {}
L18_1 = "islandPeds"
L19_1 = "ambientAudio"
L20_1 = "disableFlightMusic"
L21_1 = "islandRadioMode"
L17_1[1] = L18_1
L17_1[2] = L19_1
L17_1[3] = L20_1
L17_1[4] = L21_1
L16_1, L17_1, L18_1, L19_1 = L16_1(L17_1)
for L20_1, L21_1 in L16_1, L17_1, L18_1, L19_1 do
  L22_1 = assert
  L23_1 = type
  L24_1 = L1_1[L21_1]
  L23_1 = L23_1(L24_1)
  L23_1 = "boolean" == L23_1
  L24_1 = "Expected boolean setting: Features."
  L25_1 = L21_1
  L24_1 = L24_1 .. L25_1
  L22_1(L23_1, L24_1)
end
L16_1 = ipairs
L17_1 = {}
L18_1 = "peds"
L19_1 = "scenarios"
L20_1 = "vehicles"
L21_1 = "randomVehicles"
L22_1 = "parkedVehicles"
L17_1[1] = L18_1
L17_1[2] = L19_1
L17_1[3] = L20_1
L17_1[4] = L21_1
L17_1[5] = L22_1
L16_1, L17_1, L18_1, L19_1 = L16_1(L17_1)
for L20_1, L21_1 in L16_1, L17_1, L18_1, L19_1 do
  L22_1 = Config
  L22_1 = L22_1.Population
  L22_1 = L22_1[L21_1]
  L23_1 = assert
  L24_1 = type
  L25_1 = L22_1
  L24_1 = L24_1(L25_1)
  L24_1 = "number" == L24_1 and L22_1 >= 0 and L22_1 <= 1
  L25_1 = "Population values must be between 0 and 1: "
  L26_1 = L21_1
  L25_1 = L25_1 .. L26_1
  L23_1(L24_1, L25_1)
end
L16_1 = assert
L17_1 = Config
L17_1 = L17_1.Environment
L17_1 = L17_1.water
L17_1 = L17_1.type
L17_1 = 0 == L17_1 or 1 == L17_1
L18_1 = "Water type must be 0 or 1"
L16_1(L17_1, L18_1)
L16_1 = assert
L17_1 = Config
L17_1 = L17_1.Environment
L17_1 = L17_1.waves
L17_1 = L17_1.intensity
L17_1 = L17_1 >= 0
L18_1 = "Wave intensity must be between 0 and 3"
L16_1(L17_1, L18_1)
L16_1 = L15_1
L16_1 = L16_1()
function L17_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L0_2 = pairs
  L1_2 = L16_1
  L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
  for L4_2 in L0_2, L1_2, L2_2, L3_2 do
    L5_2 = L5_1
    L6_2 = IsIplActive
    L7_2 = L4_2
    L6_2 = L6_2(L7_2)
    L5_2[L4_2] = L6_2
  end
  L0_2 = pairs
  L1_2 = L16_1
  L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
  for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
    if not L5_2 then
      L6_2 = RemoveIpl
      L7_2 = L4_2
      L6_2(L7_2)
    end
  end
  L0_2 = pairs
  L1_2 = L16_1
  L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
  for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
    if L5_2 then
      L6_2 = RequestIpl
      L7_2 = L4_2
      L6_2(L7_2)
    end
  end
end
function L18_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = L6_1
  if not L0_2 then
    return
  end
  L0_2 = SetAudioFlag
  L1_2 = "DisableFlightMusic"
  L2_2 = L1_1.disableFlightMusic
  L0_2(L1_2, L2_2)
  L0_2 = SetAudioFlag
  L1_2 = "PlayerOnDLCHeist4Island"
  L2_2 = L1_1.islandRadioMode
  L0_2(L1_2, L2_2)
  L0_2 = SetAmbientZoneListStatePersistent
  L1_2 = "AZL_DLC_Hei4_Island_Zones"
  L2_2 = L1_1.ambientAudio
  L3_2 = true
  L0_2(L1_2, L2_2, L3_2)
  L0_2 = SetAmbientZoneListStatePersistent
  L1_2 = "AZL_DLC_Hei4_Island_Disabled_Zones"
  L2_2 = L1_1.ambientAudio
  L2_2 = not L2_2
  L3_2 = true
  L0_2(L1_2, L2_2, L3_2)
end
function L19_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L0_2 = {}
  L6_1 = L0_2
  L0_2 = Config
  L0_2 = L0_2.Environment
  L0_2 = L0_2.waves
  L0_2 = L0_2.enabled
  if L0_2 then
    L0_2 = GetDeepOceanScaler
    L0_2 = L0_2()
    L6_1.waves = L0_2
  end
  L0_2 = Config
  L0_2 = L0_2.Environment
  L0_2 = L0_2.water
  L0_2 = L0_2.enabled
  if L0_2 then
    L0_2 = GetGlobalWaterType
    L0_2 = L0_2()
    L6_1.water = L0_2
    L0_2 = LoadGlobalWaterType
    L1_2 = Config
    L1_2 = L1_2.Environment
    L1_2 = L1_2.water
    L1_2 = L1_2.type
    L0_2(L1_2)
  end
  L0_2 = Config
  L0_2 = L0_2.Environment
  L0_2 = L0_2.waves
  L0_2 = L0_2.enabled
  if L0_2 then
    L0_2 = SetDeepOceanScaler
    L1_2 = Config
    L1_2 = L1_2.Environment
    L1_2 = L1_2.waves
    L1_2 = L1_2.intensity
    L1_2 = L1_2 + 0.0
    L0_2(L1_2)
  end
  L0_2 = Config
  L0_2 = L0_2.Environment
  L0_2 = L0_2.disablePrologueZone
  if L0_2 then
    L0_2 = GetZoneFromNameId
    L1_2 = "PrLog"
    L0_2 = L0_2(L1_2)
    if -1 ~= L0_2 then
      L6_1.zone = L0_2
      L1_2 = SetZoneEnabled
      L2_2 = L0_2
      L3_2 = false
      L1_2(L2_2, L3_2)
    end
  end
  L0_2 = Config
  L0_2 = L0_2.Environment
  L0_2 = L0_2.disableArenaEmitters
  if L0_2 then
    L0_2 = ipairs
    L1_2 = L12_1
    L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
    for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
      L6_2 = SetStaticEmitterEnabled
      L7_2 = L5_2
      L8_2 = false
      L6_2(L7_2, L8_2)
    end
  end
  L0_2 = Config
  L0_2 = L0_2.Environment
  L0_2 = L0_2.managePathNodes
  if L0_2 then
    L0_2 = SetAiGlobalPathNodesType
    L1_2 = 1
    L0_2(L1_2)
    L0_2 = true
    L11_1 = L0_2
    L0_2 = SetResourceKvpInt
    L1_2 = "nteam_path_nodes_owned"
    L2_2 = 1
    L0_2(L1_2, L2_2)
  end
  L0_2 = L18_1
  L0_2()
end
function L20_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L0_2 = L6_1
  if not L0_2 then
    return
  end
  L0_2 = L6_1.water
  if nil ~= L0_2 then
    L0_2 = LoadGlobalWaterType
    L1_2 = L6_1.water
    L0_2(L1_2)
  end
  L0_2 = L6_1.waves
  if nil ~= L0_2 then
    L0_2 = SetDeepOceanScaler
    L1_2 = L6_1.waves
    L0_2(L1_2)
  end
  L0_2 = L6_1.zone
  if L0_2 then
    L0_2 = SetZoneEnabled
    L1_2 = L6_1.zone
    L2_2 = Config
    L2_2 = L2_2.Environment
    L2_2 = L2_2.restorePrologueZone
    L0_2(L1_2, L2_2)
  end
  L0_2 = Config
  L0_2 = L0_2.Environment
  L0_2 = L0_2.disableArenaEmitters
  if L0_2 then
    L0_2 = ipairs
    L1_2 = L12_1
    L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
    for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
      L6_2 = SetStaticEmitterEnabled
      L7_2 = L5_2
      L8_2 = Config
      L8_2 = L8_2.Environment
      L8_2 = L8_2.restoreArenaEmitters
      L6_2(L7_2, L8_2)
    end
  end
  L0_2 = SetAudioFlag
  L1_2 = "DisableFlightMusic"
  L2_2 = false
  L0_2(L1_2, L2_2)
  L0_2 = SetAudioFlag
  L1_2 = "PlayerOnDLCHeist4Island"
  L2_2 = false
  L0_2(L1_2, L2_2)
  L0_2 = SetAmbientZoneListStatePersistent
  L1_2 = "AZL_DLC_Hei4_Island_Zones"
  L2_2 = false
  L3_2 = true
  L0_2(L1_2, L2_2, L3_2)
  L0_2 = SetAmbientZoneListStatePersistent
  L1_2 = "AZL_DLC_Hei4_Island_Disabled_Zones"
  L2_2 = true
  L3_2 = true
  L0_2(L1_2, L2_2, L3_2)
  L0_2 = nil
  L6_1 = L0_2
end
function L21_1(A0_2)
  local L1_2, L2_2, L3_2
  L1_2 = L11_1
  if L1_2 then
    L1_2 = L14_1
    L2_2 = A0_2
    L3_2 = true
    L1_2 = L1_2(L2_2, L3_2)
    if not L1_2 then
      L1_2 = SetAiGlobalPathNodesType
      L2_2 = 0
      L1_2(L2_2)
      L1_2 = false
      L11_1 = L1_2
      L1_2 = DeleteResourceKvp
      L2_2 = "nteam_path_nodes_owned"
      L1_2(L2_2)
    end
  end
end
function L22_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L0_2 = L8_1
  if L0_2 then
    L0_2 = L9_1
    if L0_2 then
      L0_2 = IsValidInterior
      L1_2 = L8_1
      L0_2 = L0_2(L1_2)
      if L0_2 then
        L0_2 = pairs
        L1_2 = L9_1
        L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
        for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
          if L5_2 then
            L6_2 = ActivateInteriorEntitySet
            L7_2 = L8_1
            L8_2 = L4_2
            L6_2(L7_2, L8_2)
          else
            L6_2 = DeactivateInteriorEntitySet
            L7_2 = L8_1
            L8_2 = L4_2
            L6_2(L7_2, L8_2)
          end
        end
        L0_2 = RefreshInterior
        L1_2 = L8_1
        L0_2(L1_2)
      end
    end
  end
  L0_2 = nil
  L1_2 = nil
  L2_2 = nil
  L10_1 = L2_2
  L9_1 = L1_2
  L8_1 = L0_2
end
function L23_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L1_2 = Config
  L1_2 = L1_2.Vault
  L1_2 = L1_2.coords
  L2_2 = A0_2.x
  L3_2 = L1_2.x
  L2_2 = L2_2 - L3_2
  L3_2 = A0_2.y
  L4_2 = L1_2.y
  L3_2 = L3_2 - L4_2
  L4_2 = L2_2 * L2_2
  L5_2 = L3_2 * L3_2
  L4_2 = L4_2 + L5_2
  L5_2 = Config
  L5_2 = L5_2.Vault
  L5_2 = L5_2.activationRadius
  L5_2 = L5_2 ^ 2
  if L4_2 > L5_2 then
    L4_2 = L8_1
    if L4_2 then
      L4_2 = L22_1
      L4_2()
    end
    return
  end
  L4_2 = GetInteriorAtCoords
  L5_2 = L1_2.x
  L6_2 = L1_2.y
  L7_2 = L1_2.z
  L4_2 = L4_2(L5_2, L6_2, L7_2)
  if 0 ~= L4_2 then
    L5_2 = IsValidInterior
    L6_2 = L4_2
    L5_2 = L5_2(L6_2)
    if L5_2 then
      L5_2 = IsInteriorReady
      L6_2 = L4_2
      L5_2 = L5_2(L6_2)
      if L5_2 then
        goto lbl_49
      end
    end
  end
  do return end
  ::lbl_49::
  L5_2 = L8_1
  if L4_2 ~= L5_2 then
    L5_2 = L22_1
    L5_2()
    L5_2 = L4_2
    L6_2 = {}
    L9_1 = L6_2
    L8_1 = L5_2
    L5_2 = pairs
    L6_2 = L13_1
    L5_2, L6_2, L7_2, L8_2 = L5_2(L6_2)
    for L9_2, L10_2 in L5_2, L6_2, L7_2, L8_2 do
      L11_2 = L9_1
      L12_2 = IsInteriorEntitySetActive
      L13_2 = L4_2
      L14_2 = L10_2
      L12_2 = L12_2(L13_2, L14_2)
      L11_2[L10_2] = L12_2
    end
  end
  L5_2 = L10_1
  L6_2 = L1_1.vault
  if L5_2 == L6_2 then
    return
  end
  L5_2 = pairs
  L6_2 = L13_1
  L5_2, L6_2, L7_2, L8_2 = L5_2(L6_2)
  for L9_2, L10_2 in L5_2, L6_2, L7_2, L8_2 do
    L11_2 = DeactivateInteriorEntitySet
    L12_2 = L4_2
    L13_2 = L10_2
    L11_2(L12_2, L13_2)
  end
  L6_2 = L1_1.vault
  L5_2 = L13_1
  L5_2 = L5_2[L6_2]
  if L5_2 then
    L6_2 = ActivateInteriorEntitySet
    L7_2 = L4_2
    L8_2 = L5_2
    L6_2(L7_2, L8_2)
  end
  L6_2 = RefreshInterior
  L7_2 = L4_2
  L6_2(L7_2)
  L6_2 = L1_1.vault
  L10_1 = L6_2
end
function L24_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L0_2 = false
  L3_1 = L0_2
  L0_2 = L20_1
  L0_2()
  L0_2 = L22_1
  L0_2()
  L0_2 = L21_1
  L1_2 = GetEntityCoords
  L2_2 = PlayerPedId
  L2_2, L3_2, L4_2, L5_2, L6_2, L7_2 = L2_2()
  L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2 = L1_2(L2_2, L3_2, L4_2, L5_2, L6_2, L7_2)
  L0_2(L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2)
  L0_2 = L7_1
  if nil ~= L0_2 then
    L0_2 = SetScenarioGroupEnabled
    L1_2 = "Heist_Island_Peds"
    L2_2 = L7_1
    L0_2(L1_2, L2_2)
    L0_2 = nil
    L7_1 = L0_2
  end
  L0_2 = pairs
  L1_2 = L5_1
  L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
  for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
    if not L5_2 then
      L6_2 = RemoveIpl
      L7_2 = L4_2
      L6_2(L7_2)
    end
  end
  L0_2 = pairs
  L1_2 = L5_1
  L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
  for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
    if L5_2 then
      L6_2 = RequestIpl
      L7_2 = L4_2
      L6_2(L7_2)
    end
  end
  L0_2 = {}
  L5_1 = L0_2
  L0_2 = false
  L4_1 = L0_2
end
L25_1 = CreateThread
function L26_1()
  local L0_2, L1_2, L2_2, L3_2
  while true do
    L0_2 = L2_1
    if not L0_2 then
      break
    end
    L0_2 = NetworkIsSessionStarted
    L0_2 = L0_2()
    if L0_2 then
      break
    end
    L0_2 = Wait
    L1_2 = 250
    L0_2(L1_2)
  end
  L0_2 = L2_1
  if not L0_2 then
    return
  end
  L0_2 = L17_1
  L0_2()
  L0_2 = IsScenarioGroupEnabled
  L1_2 = "Heist_Island_Peds"
  L0_2 = L0_2(L1_2)
  L7_1 = L0_2
  L0_2 = SetScenarioGroupEnabled
  L1_2 = "Heist_Island_Peds"
  L2_2 = L1_1.islandPeds
  L0_2(L1_2, L2_2)
  L0_2 = true
  L3_1 = L0_2
  while true do
    L0_2 = L2_1
    if not L0_2 then
      break
    end
    L0_2 = GetEntityCoords
    L1_2 = PlayerPedId
    L1_2, L2_2, L3_2 = L1_2()
    L0_2 = L0_2(L1_2, L2_2, L3_2)
    L1_2 = L14_1
    L2_2 = L0_2
    L3_2 = L4_1
    L1_2 = L1_2(L2_2, L3_2)
    L2_2 = L4_1
    if L1_2 ~= L2_2 then
      L4_1 = L1_2
      L2_2 = L4_1
      if L2_2 then
        L2_2 = L19_1
        L2_2()
      else
        L2_2 = L20_1
        L2_2()
      end
    end
    L2_2 = L21_1
    L3_2 = L0_2
    L2_2(L3_2)
    L2_2 = Wait
    L3_2 = Config
    L3_2 = L3_2.Area
    L3_2 = L3_2.pollMs
    L2_2(L3_2)
  end
end
L25_1(L26_1)
L25_1 = CreateThread
function L26_1()
  local L0_2, L1_2, L2_2
  while true do
    L0_2 = L2_1
    if not L0_2 then
      break
    end
    L0_2 = L3_1
    if L0_2 then
      L0_2 = L4_1
      if L0_2 then
        L0_2 = L23_1
        L1_2 = GetEntityCoords
        L2_2 = PlayerPedId
        L2_2 = L2_2()
        L1_2, L2_2 = L1_2(L2_2)
        L0_2(L1_2, L2_2)
    end
    else
      L0_2 = L8_1
      if L0_2 then
        L0_2 = L22_1
        L0_2()
      end
    end
    L0_2 = Wait
    L1_2 = Config
    L1_2 = L1_2.Vault
    L1_2 = L1_2.retryMs
    L0_2(L1_2)
  end
end
L25_1(L26_1)
L25_1 = Config
L25_1 = L25_1.Population
L25_1 = L25_1.enabled
if L25_1 then
  L25_1 = CreateThread
  function L26_1()
    local L0_2, L1_2, L2_2, L3_2
    L0_2 = Config
    L0_2 = L0_2.Population
    while true do
      L1_2 = L2_1
      if not L1_2 then
        break
      end
      L1_2 = L3_1
      if L1_2 then
        L1_2 = L4_1
        if L1_2 then
          L1_2 = SetPedDensityMultiplierThisFrame
          L2_2 = L0_2.peds
          L2_2 = L2_2 + 0.0
          L1_2(L2_2)
          L1_2 = SetScenarioPedDensityMultiplierThisFrame
          L2_2 = L0_2.scenarios
          L2_2 = L2_2 + 0.0
          L3_2 = L0_2.scenarios
          L3_2 = L3_2 + 0.0
          L1_2(L2_2, L3_2)
          L1_2 = SetVehicleDensityMultiplierThisFrame
          L2_2 = L0_2.vehicles
          L2_2 = L2_2 + 0.0
          L1_2(L2_2)
          L1_2 = _ENV
          L2_2 = "SetRandomVehicleDensityMultiplierThisFrame"
          L1_2 = L1_2[L2_2]
          L2_2 = L0_2.randomVehicles
          L2_2 = L2_2 + 0.0
          L1_2(L2_2)
          L1_2 = _ENV
          L2_2 = "SetParkedVehicleDensityMultiplierThisFrame"
          L1_2 = L1_2[L2_2]
          L2_2 = L0_2.parkedVehicles
          L2_2 = L2_2 + 0.0
          L1_2(L2_2)
          L1_2 = Wait
          L2_2 = 0
          L1_2(L2_2)
      end
      else
        L1_2 = Wait
        L2_2 = 250
        L1_2(L2_2)
      end
    end
  end
  L25_1(L26_1)
end
L25_1 = AddEventHandler
L26_1 = "onResourceStop"
function L27_1(A0_2)
  local L1_2
  L1_2 = L0_1
  if A0_2 ~= L1_2 then
    return
  end
  L1_2 = false
  L2_1 = L1_2
  L1_2 = L24_1
  L1_2()
end
L25_1(L26_1, L27_1)
