jengoConfig = {}

jengoConfig.TableSpawns = {
    [2] = { coords = vec4(-1458.22, -1052.21, 3.29, 231.23), price = 500, requiredResource = "AuraStudio-GameYard" },
}

if jengoConfig.TableSpawns and FilterRequiredResourceSpawns then
    jengoConfig.TableSpawns = FilterRequiredResourceSpawns(jengoConfig.TableSpawns)
end
