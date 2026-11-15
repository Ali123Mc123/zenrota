santosPolyConfig = santosPolyConfig or {}

santosPolyConfig.FlagZOffset = -0.05       
santosPolyConfig.HouseZOffset = -0.04      
santosPolyConfig.HouseGap = 0.02          

santosPolyConfig.JailFine = 500           

santosPolyConfig.ChanceCardOffset = vector3(-0.145, 0.16, -0.04)  
santosPolyConfig.ChanceCardRotation = vector3(0.0, 0.0, 135.0)   
santosPolyConfig.ChanceCardHeightGap = 0.0015                   

santosPolyConfig.ChestCardOffset = vector3(0.145, -0.16, -0.04)  
santosPolyConfig.ChestCardRotation = vector3(0.0, 0.0, 315.0)   
santosPolyConfig.ChestCardHeightGap = 0.0015                   

santosPolyConfig.TableSpawns = {
    [2] = { coords = vec4(-1431.81, -1050.33, 4.17, 51.18), price = 500, requiredResource = "AuraStudio-GameYard" }
}

-- do not touch
santosPolyConfig.Regions = {
    [1] = { name = "GO", hasCard = false },
    [2] = { name = "GROVE STREET", price = 60, hasCard = true, colorHex = "#8B4513", rent = 2, house1 = 10, house2 = 30, house3 = 90, house4 = 160, hotel = 250, houseCost = 50, mortgage = 30 },
    [3] = { name = "COMMUNITY CHEST", hasCard = false },
    [4] = { name = "BROUGE AVENUE", price = 60, hasCard = true, colorHex = "#8B4513", rent = 4, house1 = 20, house2 = 60, house3 = 180, house4 = 320, hotel = 450, houseCost = 50, mortgage = 30 },
    [5] = { name = "CHAMBERLAIN HILLS", price = 60, hasCard = true, colorHex = "#8B4513", rent = 4, house1 = 20, house2 = 60, house3 = 180, house4 = 320, hotel = 450, houseCost = 50, mortgage = 30 },
    [6] = { name = "GOLOCO RAILROADS", price = 200, hasCard = true, isRailroad = true, colorHex = "#FFFFFF", rent = 25, mortgage = 100 },
    [7] = { name = "VESPUCCI CANALS", price = 100, hasCard = true, colorHex = "#87CEEB", rent = 6, house1 = 30, house2 = 90, house3 = 270, house4 = 400, hotel = 550, houseCost = 50, mortgage = 50 },
    [8] = { name = "COMMUNITY CHEST", hasCard = false },
    [9] = { name = "VESPUCCI BEACH", price = 100, hasCard = true, colorHex = "#87CEEB", rent = 6, house1 = 30, house2 = 90, house3 = 270, house4 = 400, hotel = 550, houseCost = 50, mortgage = 50 },
    [10] = { name = "DEL PERRO PIER", price = 120, hasCard = true, colorHex = "#87CEEB", rent = 8, house1 = 40, house2 = 100, house3 = 300, house4 = 450, hotel = 600, houseCost = 50, mortgage = 60 },
    [11] = { name = "REVERSE DIRECTION", hasCard = false },
    [12] = { name = "LEGION SQUARE", price = 140, hasCard = true, colorHex = "#FF69B4", rent = 10, house1 = 50, house2 = 150, house3 = 450, house4 = 625, hotel = 750, houseCost = 100, mortgage = 70 },
    [13] = { name = "LSPD FINE", price = 100, hasCard = true, isUtility = true, colorHex = "#FFFFFF", mortgage = 50 },
    [14] = { name = "MISSION ROW", price = 140, hasCard = true, colorHex = "#FF69B4", rent = 10, house1 = 50, house2 = 150, house3 = 450, house4 = 625, hotel = 750, houseCost = 100, mortgage = 70 },
    [15] = { name = "TEXTILE CITY", price = 160, hasCard = true, colorHex = "#FF69B4", rent = 12, house1 = 60, house2 = 180, house3 = 500, house4 = 700, hotel = 900, houseCost = 100, mortgage = 80 },
    [16] = { name = "LOS SANTOS INTERNATION AIRPORT", price = 200, hasCard = true, isRailroad = true, colorHex = "#FFFFFF", rent = 25, mortgage = 100 },
    [17] = { name = "LITTLE SEOUL", price = 150, hasCard = true, colorHex = "#FFA500", rent = 12, house1 = 60, house2 = 180, house3 = 500, house4 = 700, hotel = 900, houseCost = 100, mortgage = 75 },
    [18] = { name = "COMMUNITY CHEST", hasCard = false },
    [19] = { name = "PILLBOX HILL", price = 190, hasCard = true, colorHex = "#FFA500", rent = 15, house1 = 75, house2 = 210, house3 = 575, house4 = 775, hotel = 975, houseCost = 100, mortgage = 95 },
    [20] = { name = "HAWICK", price = 200, hasCard = true, colorHex = "#FFA500", rent = 16, house1 = 80, house2 = 220, house3 = 600, house4 = 800, hotel = 1000, houseCost = 100, mortgage = 100 },
    [21] = { name = "JUST WAIT", hasCard = false },
    [22] = { name = "ALTA STREET", price = 220, hasCard = true, colorHex = "#FF0000", rent = 18, house1 = 90, house2 = 250, house3 = 700, house4 = 875, hotel = 1050, houseCost = 150, mortgage = 110 },
    [23] = { name = "COMMUNITY CHEST", hasCard = false },
    [24] = { name = "BURTON", price = 220, hasCard = true, colorHex = "#FF0000", rent = 18, house1 = 90, house2 = 250, house3 = 700, house4 = 875, hotel = 1050, houseCost = 150, mortgage = 110 },
    [25] = { name = "DOWNTOWN VINEWOOD", price = 240, hasCard = true, colorHex = "#FF0000", rent = 20, house1 = 100, house2 = 300, house3 = 750, house4 = 925, hotel = 1100, houseCost = 150, mortgage = 120 },
    [26] = { name = "BUS CENTER", price = 200, hasCard = true, isRailroad = true, colorHex = "#FFFFFF", rent = 25, mortgage = 100 },
    [27] = { name = "VINEWOOD BOULEVARD", price = 260, hasCard = true, colorHex = "#FFFF00", rent = 22, house1 = 110, house2 = 330, house3 = 800, house4 = 975, hotel = 1150, houseCost = 150, mortgage = 130 },
    [28] = { name = "MIRROR PARK", price = 260, hasCard = true, colorHex = "#FFFF00", rent = 22, house1 = 110, house2 = 330, house3 = 800, house4 = 975, hotel = 1150, houseCost = 150, mortgage = 130 },
    [29] = { name = "LSPD FINE", price = 150, hasCard = true, isUtility = true, colorHex = "#FFFFFF", mortgage = 75 },
    [30] = { name = "CHUMASH", price = 280, hasCard = true, colorHex = "#FFFF00", rent = 24, house1 = 120, house2 = 360, house3 = 850, house4 = 1025, hotel = 1200, houseCost = 150, mortgage = 140 },
    [31] = { name = "IN JAIL", hasCard = false },
    [32] = { name = "ROCKFORD HILLS", price = 300, hasCard = true, colorHex = "#008000", rent = 26, house1 = 130, house2 = 390, house3 = 900, house4 = 1100, hotel = 1275, houseCost = 200, mortgage = 150 },
    [33] = { name = "PORTOLA DRIVE", price = 300, hasCard = true, colorHex = "#008000", rent = 26, house1 = 130, house2 = 390, house3 = 900, house4 = 1100, hotel = 1275, houseCost = 200, mortgage = 150 },
    [34] = { name = "COMMUNITY CHEST", hasCard = false },
    [35] = { name = "RICHMAN", price = 320, hasCard = true, colorHex = "#008000", rent = 28, house1 = 150, house2 = 450, house3 = 1000, house4 = 1200, hotel = 1400, houseCost = 200, mortgage = 160 },
    [36] = { name = "DOWNTOWN CAB CO.", price = 200, hasCard = true, isRailroad = true, colorHex = "#FFFFFF", rent = 25, mortgage = 100 },
    [37] = { name = "COMMUNITY CHEST", hasCard = false },
    [38] = { name = "VINEWOOD HILLS", price = 350, hasCard = true, colorHex = "#00008B", rent = 35, house1 = 175, house2 = 500, house3 = 1100, house4 = 1300, hotel = 1500, houseCost = 200, mortgage = 175 },
    [39] = { name = "TAX", hasCard = false },
    [40] = { name = "ECLIPSE TOWERS", price = 400, hasCard = true, colorHex = "#00008B", rent = 50, house1 = 200, house2 = 600, house3 = 1400, house4 = 1700, hotel = 2000, houseCost = 200, mortgage = 200 },
}

if santosPolyConfig.TableSpawns and FilterRequiredResourceSpawns then
    santosPolyConfig.TableSpawns = FilterRequiredResourceSpawns(santosPolyConfig.TableSpawns)
end
