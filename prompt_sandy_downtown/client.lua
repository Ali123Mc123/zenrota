Citizen.CreateThread(function()
    InteriorID = GetInteriorAtCoords(1696.953, 3755.445, 33.70526)
    RemoveIpl("lr_cs4_07_interior_v_gun2_milo_")
    
    DisableInterior(InteriorID, true)
    RefreshInterior(InteriorID)
end)