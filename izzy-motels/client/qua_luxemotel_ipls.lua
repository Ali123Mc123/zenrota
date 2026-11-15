  Citizen.CreateThread(function()
    interiorID = GetInteriorAtCoords(94.15188000, -485.12310000, -108.86161800)
    RequestIpl("qua_luxemotel_milo")
      if IsValidInterior(interiorID) then      
        EnableInteriorProp(interiorID, "tint")
        EnableInteriorProp(interiorID, "props")          
      RefreshInterior(interiorID)
      end
  end)

  CreateThread(function()
    SetInteriorEntitySetColor(interiorID, "tint", 55)
  end)

  local emitters = {
    "se_dlc_apt_yacht_bedroom",
  }
  
  Citizen.CreateThread(function()
    for i = 1, #emitters do
      SetStaticEmitterEnabled(emitters[i], false)
    end
  end)

  local autoexbbmin, autoexbbmax = vec3(-422.51450000, -994.09080000, -610.01180000), vec3(596.91326900, 27.38360600, 395.41192600)
  if not DoesScenarioBlockingAreaExist(autoexbbmin, autoexbbmax) then
    AddScenarioBlockingArea(autoexbbmin, autoexbbmax, 0, 1, 1, 1)
  end