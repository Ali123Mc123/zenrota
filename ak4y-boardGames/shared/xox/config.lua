xoxConfig = {}

xoxConfig.Tables = {
    [2] = { coords = vec4(-1454.4, -1048.25, 3.37, 229.55), price = 500, requiredResource = "AuraStudio-GameYard" }
}

if xoxConfig.Tables and FilterRequiredResourceSpawns then
    xoxConfig.Tables = FilterRequiredResourceSpawns(xoxConfig.Tables)
end
