armwrestlingConfig = {}

armwrestlingConfig.Tables = {

    {
        label  = "armwresting2",
        prop   = `prop_arm_wrestle_01`,
        coords = vec4(-1430.49, -1047.58, 4.17, 229.65),
        price  = 500,
        requiredResource = "AuraStudio-GameYard",
        seats  = {
            A = vec3(-0.1225, -0.5975, 0.533),
            B = vec3( 0.1225,  0.5975, 0.533),
        },
    },
    {
        label  = "armwresting3",
        prop   = `prop_arm_wrestle_01`,
        coords = vec4(-1426.89, -1043.69, 4.17, 317.64),
        price  = 500,
        requiredResource = "AuraStudio-GameYard",
        seats  = {
            A = vec3(-0.1225, -0.5975, 0.533),
            B = vec3( 0.1225,  0.5975, 0.533),
        },
    },
}

armwrestlingConfig.Controls = {
    Join  = 38,
    Mash  = 38,
    Leave = 177,
}

armwrestlingConfig.InteractDistance = 1.8
armwrestlingConfig.MarkerDistance   = 2.5

armwrestlingConfig.Match = {
    TickMs          = 50,
    InputPower      = 0.18,
    InputCapPerTick = 6.0,
    PowerGain       = 0.028,
    PowerDecay      = 0.68,
    ReturnForce     = 0.975,
    ReadyTimeoutMs  = 20000,
}

armwrestlingConfig.Debug = false

if armwrestlingConfig.Tables and FilterRequiredResourceSpawns then
    armwrestlingConfig.Tables = FilterRequiredResourceSpawns(armwrestlingConfig.Tables)
end
