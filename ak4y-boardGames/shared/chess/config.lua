chessConfig = {}

chessConfig.Tables = {
    [2] = { coords = vec4(-1428.95, -1046.04, 4.17, 228.6), price = 500, requiredResource = "AuraStudio-GameYard" },
}

if chessConfig.Tables and FilterRequiredResourceSpawns then
    chessConfig.Tables = FilterRequiredResourceSpawns(chessConfig.Tables)
end
