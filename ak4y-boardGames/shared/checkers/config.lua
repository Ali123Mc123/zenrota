checkersConfig = {}

checkersConfig.Tables = {
    [2] = { coords = vec4(-1427.9, -1049.89, 4.17, 232.98), price = 500, requiredResource = "AuraStudio-GameYard" },
}

if checkersConfig.Tables and FilterRequiredResourceSpawns then
    checkersConfig.Tables = FilterRequiredResourceSpawns(checkersConfig.Tables)
end
