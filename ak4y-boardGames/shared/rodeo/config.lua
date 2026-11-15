rodeoConfig = {}

rodeoConfig.SpeedMultiplier = 2.0 -- Controls how fast the bull spins and moves

rodeoConfig.Rodeos = {
    [2] = { coords = vec4(-1429.84, -1040.44, 4.17, 0.03), price = 500, requiredResource = "AuraStudio-GameYard" },
}

if rodeoConfig.Rodeos and FilterRequiredResourceSpawns then
    rodeoConfig.Rodeos = FilterRequiredResourceSpawns(rodeoConfig.Rodeos)
end
