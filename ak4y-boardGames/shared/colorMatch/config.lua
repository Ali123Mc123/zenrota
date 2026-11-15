enoConfig = enoConfig or {}

enoConfig.TableSpawns = {
    [2] = { coords = vec4(-1424.09, -1045.91, 4.17, 47.47), price = 500, requiredResource = "AuraStudio-GameYard" },
}

if enoConfig.TableSpawns and FilterRequiredResourceSpawns then
    enoConfig.TableSpawns = FilterRequiredResourceSpawns(enoConfig.TableSpawns)
end
