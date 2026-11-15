Citizen.CreateThread(function()


RequestIpl("v_kivo_fleeca") --1  Hawick Avenue and Metero Street, in Alta.

    interiorID = GetInteriorAtCoords(309.756683, -277.651184, 53.22837)
    
    if IsValidInterior(interiorID) then                  -- goldrobbery, artrobbery, diamondrobbery, coinrobbery
            EnableInteriorProp(interiorID, "goldrobbery") --You can change the entity set by changing here
            
    RefreshInterior(interiorID)

    end



RequestIpl("v_kivo_fleeca") --2 Legion Square, on Vespucci Boulevard.

    interiorID = GetInteriorAtCoords(145.433, -1039.27417, 28.4376335)
    
    if IsValidInterior(interiorID) then                  -- goldrobbery, artrobbery, diamondrobbery, coinrobbery
            EnableInteriorProp(interiorID, "goldrobbery") --You can change the entity set by changing here
            
    RefreshInterior(interiorID)

    end



RequestIpl("v_kivo_fleeca") --3 Along Hawick Avenue, in Burton.

    interiorID = GetInteriorAtCoords(-355.423859, -48.52128, 48.1134529)
    
    if IsValidInterior(interiorID) then                  -- goldrobbery, artrobbery, diamondrobbery, coinrobbery
            EnableInteriorProp(interiorID, "diamondrobbery") --You can change the entity set by changing here
            
    RefreshInterior(interiorID)

    end



RequestIpl("v_kivo_fleeca") --4 Boulevard Del Perro, in Morningwood.

    interiorID = GetInteriorAtCoords(-1216.75232, -332.978241, 36.8693)
    
    if IsValidInterior(interiorID) then                  -- goldrobbery, artrobbery, diamondrobbery, coinrobbery
            EnableInteriorProp(interiorID, "diamondrobbery") --You can change the entity set by changing here
            
    RefreshInterior(interiorID)

    end



RequestIpl("v_kivo_fleeca") --5 Blaine County, Route 68 in Harmony.

    interiorID = GetInteriorAtCoords(1179.73035, 2706.934, 37.226944)
    
    if IsValidInterior(interiorID) then                  -- goldrobbery, artrobbery, diamondrobbery, coinrobbery
            EnableInteriorProp(interiorID, "coinrobbery") --You can change the entity set by changing here
            
    RefreshInterior(interiorID)

    end



RequestIpl("v_kivo_fleeca") --6 The Great Ocean Highway, in Banham Canyon.

    interiorID = GetInteriorAtCoords(-2962.59814, 478.268036, 14.7698488)
    
    if IsValidInterior(interiorID) then                  -- goldrobbery, artrobbery, diamondrobbery, coinrobbery
            EnableInteriorProp(interiorID, "artrobbery") --You can change the entity set by changing here
            
    RefreshInterior(interiorID)

    end

end)